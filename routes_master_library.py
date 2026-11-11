"""Flask blueprint for the master library builder (WP-B5).

  GET  /api/twin/material_sets                  the material sets (user-edited file, else the shipped defaults)
  POST /api/twin/material_sets                  replace them ({"sets": [...]} or {"reset": true}); validated
  POST /api/twin/master_library/merge           merge harvested libraries (preview, optionally save as working library)
  POST /api/twin/build_sets                     start a background build job -> {"job_id"}
  GET  /api/twin/build_sets/<job_id>            progress, and the libraries (audit, skipped items) when finished
  GET  /api/twin/build_sets/<job_id>/download?set=<id|name>   one library as Fusion import JSON {"data": [...]}

See ``master_library`` for the algorithms and docs/TOOL_LIBRARY_NOTES.md for request / response examples.
"""
from __future__ import annotations

import io
import json
import re
import threading
import time
import uuid
from typing import Any, Dict, List, Optional

from flask import Blueprint, jsonify, request, send_file

import master_library as ml

bp = Blueprint("master_library", __name__)

_JOBS: Dict[str, Dict[str, Any]] = {}
_JOBS_LOCK = threading.Lock()
_MAX_JOBS = 20


def _A():
    import app as A      # late import: app registers this blueprint
    return A


def _bad(msg: str, code: int = 400):
    return jsonify({"success": False, "error": msg}), code


# ------------------------------------------------------------------ material sets
@bp.route("/api/twin/material_sets", methods=["GET", "POST"])
def material_sets():
    """GET: the sets. POST ``{"sets": [...]}``: validate (every alloy must resolve to a materials-database row)
    and save to the data directory; ``{"reset": true}`` returns to the shipped defaults."""
    A = _A()
    try:
        data_dir = A.bm.data_dir
        if request.method == "GET":
            import os
            user = os.path.exists(os.path.join(data_dir, "material_sets.json"))
            return jsonify({"success": True, "source": "user" if user else "default",
                            "material_sets": ml.load_material_sets(data_dir)})
        body = A._json_body()
        if body.get("reset"):
            import os
            path = os.path.join(data_dir, "material_sets.json")
            if os.path.exists(path):
                os.remove(path)
            return jsonify({"success": True, "source": "default", "material_sets": ml.load_material_sets(data_dir)})
        doc, errors = ml.validate_material_sets(body.get("material_sets", body), A.physics)
        if errors:
            return jsonify({"success": False, "error": "Invalid material sets", "errors": errors}), 400
        ml.save_material_sets(doc, data_dir)
        return jsonify({"success": True, "source": "user", "material_sets": doc})
    except Exception as e:
        return A._api_error(e)


# ------------------------------------------------------------------ request parsing
def _source_libraries(A, body: dict) -> List[dict]:
    libs = body.get("libraries")
    out: List[dict] = []
    if libs is not None:
        if not isinstance(libs, list):
            raise ValueError("libraries must be a list of {library_name, source, tools}")
        for i, lib in enumerate(libs):
            if not isinstance(lib, dict) or not isinstance(ml._library_tools(lib), list):
                raise ValueError(f"libraries[{i}] must be an object with a 'tools' list")
            out.append(lib)
    if libs is None or body.get("use_working_library"):
        wl = A.bm.load_working_library()
        if wl and wl.get("tools"):
            out.append({"library_name": wl.get("library_name", "Working library"), "source": "working",
                        "tools": wl["tools"]})
    if not out or not any(ml._library_tools(l) for l in out):
        raise ValueError("No tools: send 'libraries' or load a working library first.")
    return out


def _parse(A, body: dict) -> Dict[str, Any]:
    """Validate a build request; returns the merged tools, the chosen sets and the numeric settings."""
    sets_doc = ml.load_material_sets(A.bm.data_dir)
    sets = ml.select_sets(sets_doc, _str_list(body.get("sets"), "sets"), _str_list(body.get("materials"), "materials"))
    strategies = ml.check_strategies(body.get("strategies"))
    raw_aggr = body.get("aggressiveness", 50)
    aggr = ml.normalize_aggressiveness(raw_aggr)
    if not (0.0 < aggr <= 1.0):
        raise ValueError("aggressiveness must be above 0 and at most 100 (percent)")
    limits = A.machine_limits()
    max_rpm = float(body.get("maxRpm") or limits["max_rpm"])
    max_hp = float(body.get("maxHp") or limits["max_hp"])
    runout = A._runout_arg(body)
    if runout < 0 or max_rpm <= 0 or max_hp <= 0:
        raise ValueError("runout must be >= 0 and maxRpm / maxHp positive")
    filt = body.get("filter") or {}
    if not isinstance(filt, dict):
        raise ValueError("filter must be an object")
    for k in ("types", "libraries", "sources", "tool_ids"):
        _str_list(filt.get(k), f"filter.{k}")
    for k in ("diameter_min", "diameter_max"):
        if filt.get(k) not in (None, ""):
            float(filt[k])
    merged, merge_report = ml.merge_libraries(_source_libraries(A, body), repair=bool(body.get("repair", True)),
                                              deduplicate=bool(body.get("deduplicate", True)))
    selected = ml.select_tools(merged["tools"], filt)
    if not selected:
        types = sorted({str(t.get("type")) for t in merged["tools"]})
        raise ValueError(f"No tools match the filter ({len(merged['tools'])} tools merged; tool types present: {types}).")
    return {"tools": selected, "holders": merged["holders"] if body.get("include_holders", True) else [],
            "merge": merge_report, "sets": sets, "strategies": strategies, "aggressiveness": aggr,
            "use_tool_overrides": bool(body.get("use_tool_overrides", True)), "max_rpm": max_rpm, "max_hp": max_hp,
            "runout": runout, "model": A._request_model(body), "machine": A.active_machine(),
            "filter": filt}


def _str_list(v: Any, name: str) -> Optional[List[str]]:
    if v in (None, ""):
        return None
    if not isinstance(v, list) or not all(isinstance(x, str) for x in v):
        raise ValueError(f"{name} must be a list of strings")
    return v


def _merge_summary(report: dict) -> dict:
    return {k: report[k] for k in ("sources", "tools_in", "tools_out", "duplicates_merged", "holders",
                                   "repaired_tools", "stickout_variants", "merged_details", "repairs", "unreadable")}


# ------------------------------------------------------------------ merge only
@bp.route("/api/twin/master_library/merge", methods=["POST"])
def merge_only():
    """Merge harvested libraries without generating presets. ``save_working: true`` stores the merged tools as the
    working library (with a backup); otherwise nothing is written. Returns the merge report (sources, repairs,
    merged duplicates, stickout variants)."""
    A = _A()
    try:
        body = A._json_body()
        merged, report = ml.merge_libraries(_source_libraries(A, body), repair=bool(body.get("repair", True)),
                                            deduplicate=bool(body.get("deduplicate", True)))
        out: Dict[str, Any] = {"success": True, **_merge_summary(report)}
        if body.get("save_working"):
            name = str(body.get("master_library_name") or "Master_Shop_Tool_Crib")
            lib = {"library_name": name, "tools": merged["tools"] + merged["holders"]}
            out["backup"] = A.bm.save_working_library(lib, name)
            out["library_name"] = name
        return jsonify(out)
    except Exception as e:
        return A._api_error(e)


# ------------------------------------------------------------------ build job
@bp.route("/api/twin/build_sets", methods=["POST"])
def build_sets():
    """Start a background build of one library per material set; returns ``{"job_id"}`` at once.

    Body (all optional except a source of tools): ``libraries`` [{library_name, source, tools}] (else the working
    library), ``use_working_library``, ``filter`` {types, diameter_min, diameter_max, diameter_unit, libraries,
    sources, tool_ids}, ``sets`` [ids], ``materials`` [ids], ``strategies`` [names], ``aggressiveness`` (percent,
    default 50), ``runout`` (in), ``maxRpm``, ``maxHp``, ``model``, ``use_tool_overrides``, ``repair``,
    ``deduplicate``, ``include_holders``."""
    A = _A()
    try:
        params = _parse(A, A._json_body())
        job_id = uuid.uuid4().hex[:12]
        n_tools = len(params["tools"])
        job = {"id": job_id, "state": "queued", "phase": "queued", "tools_done": 0, "tools_total": n_tools,
               "current_tool": "", "created": time.time(), "started": None, "finished": None, "error": None,
               "result": None, "libraries": {},
               "request": {"sets": [s["id"] for s in params["sets"]],
                           "materials": sorted({m["id"] for s in params["sets"] for m in s["materials"]}),
                           "strategies": params["strategies"], "aggressiveness": round(params["aggressiveness"] * 100, 1),
                           "runout_in": params["runout"], "model": params["model"] or "v1", "tools": n_tools,
                           "filter": params["filter"]}}
        with _JOBS_LOCK:
            _JOBS[job_id] = job
            finished = sorted((j for j in _JOBS.values() if j["state"] in ("done", "error")), key=lambda j: j["created"])
            for old in finished[:max(0, len(_JOBS) - _MAX_JOBS)]:
                _JOBS.pop(old["id"], None)
        threading.Thread(target=_run_job, args=(job, params, A.bm, A.physics), daemon=True,
                         name=f"build-sets-{job_id}").start()
        return jsonify({"success": True, "job_id": job_id, "tools": n_tools, "sets": job["request"]["sets"],
                        "status_url": f"/api/twin/build_sets/{job_id}"}), 202
    except Exception as e:
        return A._api_error(e)


def _run_job(job: dict, p: dict, bm: Any, physics: Any) -> None:
    """Thread body: generate, audit + prune, back up, publish the result on the job."""
    t0 = time.time()
    job.update(state="running", phase="generating", started=t0)

    def progress(done: int, total: int, current: str) -> None:
        job["tools_done"], job["tools_total"], job["current_tool"] = done, total, current

    try:
        common = dict(max_rpm=p["max_rpm"], max_hp=p["max_hp"], runout=p["runout"], model=p["model"],
                      machine_profile=p["machine"])
        libs = ml.build_libraries(p["tools"], p["holders"], p["sets"], strategies=p["strategies"],
                                  aggressiveness=p["aggressiveness"], physics=physics,
                                  use_tool_overrides=p["use_tool_overrides"], progress=progress, **common)
        t_gen = time.time() - t0
        out = []
        for lib in libs:
            job["phase"] = f"auditing {lib['name']}"
            audit = ml.audit_and_prune(lib, physics, aggressiveness=p["aggressiveness"], **common)
            job["phase"] = f"saving {lib['name']}"
            tools_only = [t for t in lib["tools"] if str(t.get("type", "")).lower() != "holder"]
            n_presets = sum(len((t.get("start-values") or {}).get("presets") or []) for t in tools_only)
            n_tw = sum(1 for t in tools_only for q in (t.get("start-values") or {}).get("presets") or []
                       if ml.is_toolwiz_preset(q))
            meta = {"generator": ml.GENERATOR, "version": ml.GENERATOR_VERSION, "set": lib["id"],
                    "aggressiveness": round(p["aggressiveness"] * 100, 1), "runout_in": p["runout"],
                    "model": p["model"] or "v1", "strategies": p["strategies"], "materials": lib["materials"]}
            backup = bm.create_backup(lib["name"], {"library_name": lib["name"], "tools": lib["tools"],
                                                    "toolwiz_build": meta})
            job["libraries"][lib["id"]] = {"data": lib["tools"], "name": lib["name"]}
            out.append({
                "id": lib["id"], "name": lib["name"], "tool_count": len(tools_only),
                "holder_count": len(lib["tools"]) - len(tools_only), "preset_count": n_presets,
                "toolwiz_preset_count": n_tw, "previous_toolwiz_presets_replaced": lib["removed_old_toolwiz"],
                "materials": lib["materials"],
                "audit": {"summary": audit["summary"], "cautions_by_code": audit["cautions_by_code"],
                          "dropped_presets": audit["dropped"], "owner_preset_stop_findings": audit["owner_stop"]},
                "skipped": lib["skipped"], "backup": {"filename": backup["filename"]},
                "download_url": f"/api/twin/build_sets/{job['id']}/download?set={lib['id']}"})
        job["result"] = {"merge": _merge_summary(p["merge"]), "libraries": out,
                         "timing": {"generate_s": round(t_gen, 1), "total_s": round(time.time() - t0, 1)}}
        job["phase"] = "done"
        job["state"] = "done"
    except Exception as exc:        # reported on the job; the server log has the traceback
        import logging
        logging.getLogger(__name__).exception("build_sets job %s failed", job["id"])
        job["error"] = f"{type(exc).__name__}: {exc}"[:400]
        job["state"] = "error"
        job["phase"] = "error"
    finally:
        job["finished"] = time.time()


def _job_or_404(job_id: str):
    with _JOBS_LOCK:
        job = _JOBS.get(job_id)
    return job


@bp.route("/api/twin/build_sets/<job_id>", methods=["GET"])
def build_sets_status(job_id: str):
    """Job state: ``state`` queued / running / done / error, ``phase``, ``progress`` {tools_done, tools_total,
    current_tool, percent}; when done also ``result`` {merge, libraries[], timing}; on error ``error``."""
    job = _job_or_404(job_id)
    if job is None:
        return _bad(f"Unknown job {job_id!r}", 404)
    total = job["tools_total"] or 1
    now = job["finished"] or time.time()
    body = {"success": True, "job_id": job["id"], "state": job["state"], "phase": job["phase"],
            "progress": {"tools_done": job["tools_done"], "tools_total": job["tools_total"],
                         "current_tool": job["current_tool"], "percent": round(100.0 * job["tools_done"] / total, 1)},
            "elapsed_s": round(now - (job["started"] or job["created"]), 1), "request": job["request"]}
    if job["state"] == "done":
        body["result"] = job["result"]
    if job["state"] == "error":
        body["error"] = job["error"]
    return jsonify(body)


@bp.route("/api/twin/build_sets/<job_id>/download", methods=["GET"])
def build_sets_download(job_id: str):
    """One built library as a Fusion import file ``{"data": [...]}``; ``?set=`` is the set id or library name
    (optional when the job built one library). 404 unknown job / set, 409 while the job is not finished."""
    job = _job_or_404(job_id)
    if job is None:
        return _bad(f"Unknown job {job_id!r}", 404)
    if job["state"] != "done":
        return _bad(f"Job {job_id} is {job['state']}; download when it is done.", 409)
    want = (request.args.get("set") or "").strip()
    libs = job["libraries"]
    if not want:
        if len(libs) != 1:
            return _bad(f"Job built {len(libs)} libraries; pass ?set= one of {sorted(libs)}.")
        want = next(iter(libs))
    lib = libs.get(want) or next((l for l in libs.values() if l["name"].lower() == want.lower()), None)
    if lib is None:
        return _bad(f"Unknown set {want!r}; built: {sorted(libs)}", 404)
    mem = io.BytesIO(json.dumps({"data": lib["data"]}, indent=2).encode("utf-8"))
    safe = re.sub(r"[^A-Za-z0-9._ -]+", "_", lib["name"]).strip() or "ToolWiz_Library"
    return send_file(mem, mimetype="application/json", as_attachment=True, download_name=f"{safe}.json")
