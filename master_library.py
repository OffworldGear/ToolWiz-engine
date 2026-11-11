"""Master library builder: merge harvested Fusion libraries, generate tagged ToolWiz presets, build one library per set.

Pure functions (no Flask, no global state). ``routes_master_library`` wraps them in endpoints and a background job.

Units: Fusion tools and presets are stored in the tool's own unit (inches or millimeters; ``v_c`` in ft/min or
m/min). The engine works in inches / IPM / SFM; every conversion to a tool's unit happens in
``_preset_units`` and nowhere else.

Provenance: a merged tool carries ``toolwiz.provenance`` = [{"library", "source", "guid", "number"}] for every
input copy it absorbed. A preset written by ToolWiz carries a ``toolwiz`` object (see ``preset_tag``); a rebuild
removes exactly the presets that have one and keeps every other preset untouched.
"""
from __future__ import annotations

import copy
import datetime as _dt
import hashlib
import json
import os
import re
import uuid
from typing import Any, Callable, Dict, Iterable, List, Optional, Tuple

from pipeline import CutRequest, run_cut
from tool_library_curator import curate_tool_dict
from tool_merger import compute_tool_signature, merge_presets_lists
from toolwiz_common import (
    ToolGeometry, ToolKind, UnitError, classify, is_hole_kind, is_milling_kind, is_tap_kind, tool_unit, to_inches,
)
from toolwiz_common.tool_strategy import END_MILL_STRATEGIES, plan_strategies, slot_faces

GENERATOR = "toolwiz-master-library"
GENERATOR_VERSION = "1"
STICKOUT_TOLERANCE = 0.10          # tools of one cutter whose stickout / gauge differs by more than this stay separate
MM = 25.4
FT_PER_M = 0.3048                  # SFM -> m/min

DEFAULT_SETS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "material_sets.json")

_HSS_RE = re.compile(r"\b(hss|hss-e|hsse|hss-co|cobalt|high[\s-]?speed(?:\s+steel)?|powder\s+metal|pm)\b", re.I)
_COBALT_RE = re.compile(r"\b(cobalt|hss-e|hsse|hss-co|m35|m42)\b", re.I)
_COATING_RE = re.compile(r"(altin|tialn|alcrn|ticn|tin|nacro|diamond|zrn|crn)", re.I)
_COATING_NAMES = {"altin": "AlTiN", "tialn": "AlTiN", "alcrn": "AlCrN", "ticn": "TiCN", "tin": "TiN",
                  "nacro": "nACo", "diamond": "Diamond", "zrn": "ZrN", "crn": "CrN"}


# ------------------------------------------------------------------ small helpers
def parse_tool(raw: Any) -> Optional[Dict[str, Any]]:
    """A tool dict from a dict or a JSON string; None when it is neither."""
    if isinstance(raw, str):
        try:
            raw = json.loads(raw)
        except ValueError:
            return None
    return raw if isinstance(raw, dict) else None


def normalize_aggressiveness(raw: Any) -> float:
    """Aggressiveness as a fraction 0..1. An integer 1 is 1%, a float <= 1.0 is already a fraction (1.0 is
    100%), anything larger is a percentage (50 and 50.0 are 50%)."""
    if isinstance(raw, bool):
        raise ValueError("aggressiveness must be a number")
    v = float(raw)
    if isinstance(raw, int) and raw == 1:
        return 0.01
    return v / 100.0 if v > 1.0 else v


def tool_number(tool: dict) -> Optional[int]:
    """The tool's post-process number (None when absent)."""
    post = tool.get("post-process") or tool.get("postProcess") or {}
    try:
        return int(post.get("number")) if isinstance(post, dict) and post.get("number") is not None else None
    except (TypeError, ValueError):
        return None


def tool_is_carbide(tool: dict) -> bool:
    """Carbide unless the tool's material/grade/description clearly says HSS / cobalt / HSS-E / PM."""
    geo = tool.get("geometry") or {}
    parts = [tool.get("material"), geo.get("material"), tool.get("BMC"), geo.get("BMC"),
             tool.get("grade"), geo.get("grade"),
             (tool.get("postProcess") or {}).get("material"), tool.get("description")]
    text = " ".join(json.dumps(p) if isinstance(p, (dict, list)) else str(p) for p in parts if p)
    if "carbide" in text.lower():
        return True
    return not _HSS_RE.search(text)


def tool_coating(tool: dict, default: str = "AlTiN") -> str:
    """Coating named in the description / BMC field, else ``default``."""
    m = _COATING_RE.search(f"{tool.get('description') or ''} {tool.get('BMC') or ''}")
    return _COATING_NAMES.get(m.group(1).lower(), default) if m else default


def db_tool_type(kind: ToolKind, tool: dict, is_carbide: bool) -> str:
    """G-Wizard DB tool category (speed / feed table key) for a Fusion tool."""
    geo = tool.get("geometry") or {}
    parts = [tool.get("material"), geo.get("material"), tool.get("BMC"), geo.get("BMC"),
             tool.get("grade"), geo.get("grade"),
             (tool.get("postProcess") or {}).get("material"), tool.get("description")]
    text = " ".join(json.dumps(p) if isinstance(p, (dict, list)) else str(p) for p in parts if p)
    text_low = text.lower()
    is_cobalt = bool(_COBALT_RE.search(text))
    if kind is ToolKind.TAP:
        return "Tapping"
    if kind is ToolKind.REAMER:
        return "Carbide Reamer" if is_carbide else "HSS Reamer"
    if kind in (ToolKind.SPOT_DRILL, ToolKind.CENTER_DRILL):
        return "HP Carbide Twist Drill" if is_carbide else "HSS Spot Drill"
    if is_hole_kind(kind):
        if is_carbide:
            return "HP Carbide Twist Drill"
        return "Cobalt Twist Drill" if is_cobalt else "HSS Twist Drill"
    if kind is ToolKind.SLOT and any(k in text_low for k in ("saw", "slitting", "woodruff", "keyseat")):
        return "Carbide Saws & Woodruff Cutters" if is_carbide else "HSS Saws & Woodruff Cutters"
    if kind is ToolKind.THREAD_MILL:
        return "Carbide Thread Mill"
    if kind is ToolKind.FACE and "indexable" in text_low:
        return "Indexable End Or Face Mill"
    return "Carbide Endmill" if is_carbide else "HSS Endmill"


def fusion_payload(tool: dict) -> dict:
    """The {"type","unit","geometry"} slice of a Fusion tool dict (plus description and shaft segments) that
    ``pipeline.run_cut`` reads as the authoritative tool geometry."""
    out = {"type": tool.get("type"), "unit": tool.get("unit"), "geometry": tool.get("geometry") or {}}
    if tool.get("description"):
        out["description"] = tool["description"]
    shaft = tool.get("shaft")
    if isinstance(shaft, dict) and shaft.get("segments"):
        out["shaft"] = shaft
    return out


def _cut_geometry_name(kind: ToolKind, corner_radius: float) -> str:
    """Pipeline geometry label for a milling tool."""
    return {ToolKind.SLOT: "T-Slot", ToolKind.DOVETAIL: "Dovetail", ToolKind.LOLLIPOP: "Lollipop",
            ToolKind.THREAD_MILL: "Thread Mill", ToolKind.CHAMFER: "Chamfer", ToolKind.BALL: "Ball Nose",
            ToolKind.RADIUS: "Ball Nose", ToolKind.BULL: "Bull Nose"}.get(
        kind, "Square" if corner_radius == 0 else "Radiused")


def is_toolwiz_preset(preset: Any) -> bool:
    """True for a preset written by ToolWiz (it carries a ``toolwiz`` object)."""
    return isinstance(preset, dict) and isinstance(preset.get("toolwiz"), dict)


def strip_toolwiz_presets(tool: dict) -> int:
    """Remove every ToolWiz-tagged preset from ``tool`` in place; returns how many were removed. The owner's
    own presets (no ``toolwiz`` tag) are never touched."""
    sv = tool.get("start-values")
    if not isinstance(sv, dict) or not isinstance(sv.get("presets"), list):
        return 0
    keep = [p for p in sv["presets"] if not is_toolwiz_preset(p)]
    removed = len(sv["presets"]) - len(keep)
    sv["presets"] = keep
    return removed


def preset_tag(material: dict, strategy: str, aggressiveness: float, model: Optional[str], runout_in: float,
               stickout_in: float, now: Optional[_dt.date] = None) -> Dict[str, Any]:
    """The ``toolwiz`` object stored in every ToolWiz-generated preset. aggressiveness is a fraction."""
    return {
        "generator": GENERATOR, "version": GENERATOR_VERSION,
        "material": material["label"], "material_id": material.get("id"),
        "family": material["family"], "alloy": material.get("alloy", ""),
        "strategy": strategy, "aggressiveness": round(aggressiveness * 100.0, 1),
        "model": model or "v1", "runout_in": round(float(runout_in), 6), "stickout_in": round(float(stickout_in), 4),
        "date": (now or _dt.date.today()).isoformat(),
    }


def _fmt_len(inches: float, unit: str, places: int = 2) -> str:
    return f"{inches * MM:.{places}f} mm" if unit == "millimeters" else f"{inches:.{places + 1}f} in"


def _preset_units(unit: str, *, sfm: float, ipt: float, ipm: float, lengths: Iterable[float] = ()) -> Tuple[float, ...]:
    """Convert engine values (SFM, in/tooth, IPM, inches...) to the tool's unit: (v_c, f_z, v_f, *lengths).
    Fusion stores v_c in ft/min (inch tools) or m/min (mm tools)."""
    if unit == "inches":
        return (round(float(sfm), 2), round(float(ipt), 6), round(float(ipm), 3),
                *[round(float(x), 5) for x in lengths])
    return (round(float(sfm) * FT_PER_M, 2), round(float(ipt) * MM, 6), round(float(ipm) * MM, 3),
            *[round(float(x) * MM, 4) for x in lengths])


# ------------------------------------------------------------------ material sets
def validate_material_sets(doc: Any, physics: Any) -> Tuple[Dict[str, Any], List[str]]:
    """(normalised document, errors). Each material needs ``id`` (unique), ``label``, ``family`` (a family of
    the materials database) and ``alloy`` ("" for family level, else a string ``physics.match_alloy`` resolves
    to a specific_alloys row of that family)."""
    errors: List[str] = []
    if not isinstance(doc, dict) or not isinstance(doc.get("sets"), list) or not doc["sets"]:
        return {}, ["material sets document must be an object with a non-empty 'sets' list"]
    out_sets, set_ids, mat_ids = [], set(), set()
    for si, s in enumerate(doc["sets"]):
        if not isinstance(s, dict):
            errors.append(f"sets[{si}] must be an object")
            continue
        sid = str(s.get("id") or "").strip()
        name = str(s.get("name") or "").strip()
        if not re.fullmatch(r"[a-z0-9_]+", sid):
            errors.append(f"sets[{si}].id must be lowercase letters, digits and underscores")
        elif sid in set_ids:
            errors.append(f"duplicate set id {sid!r}")
        set_ids.add(sid)
        if not name:
            errors.append(f"set {sid!r} needs a name (it is the library name)")
        mats = s.get("materials")
        if not isinstance(mats, list) or not mats:
            errors.append(f"set {sid!r} needs a non-empty 'materials' list")
            continue
        out_m = []
        for mi, m in enumerate(mats):
            where = f"set {sid!r} materials[{mi}]"
            if not isinstance(m, dict):
                errors.append(f"{where} must be an object")
                continue
            mid, label = str(m.get("id") or "").strip(), str(m.get("label") or "").strip()
            fam, alloy = str(m.get("family") or "").strip(), str(m.get("alloy") or "").strip()
            if not re.fullmatch(r"[a-z0-9_]+", mid):
                errors.append(f"{where}.id must be lowercase letters, digits and underscores")
            if not label:
                errors.append(f"{where}.label is required")
            if fam not in physics.machinability:
                errors.append(f"{where}.family {fam!r} is not a family of the materials database")
            elif alloy and not physics.match_alloy(fam, alloy):
                errors.append(f"{where}.alloy {alloy!r} does not resolve to a {fam!r} row of specific_alloys")
            out_m.append({"id": mid, "label": label, "family": fam, "alloy": alloy, "note": str(m.get("note") or "")})
        out_sets.append({"id": sid, "name": name, "materials": out_m})
    # a material id may repeat across sets (the same alloy in two sets) but must be unique within one
    for s in out_sets:
        ids = [m["id"] for m in s["materials"]]
        for d in {i for i in ids if ids.count(i) > 1}:
            errors.append(f"set {s['id']!r} lists material id {d!r} twice")
    return {"version": int(doc.get("version") or 1), "description": str(doc.get("description") or ""),
            "sets": out_sets}, errors


def load_material_sets(data_dir: Optional[str] = None) -> Dict[str, Any]:
    """The user's edited material sets (``<data_dir>/material_sets.json``) or the shipped defaults."""
    for path in ([os.path.join(data_dir, "material_sets.json")] if data_dir else []) + [DEFAULT_SETS_PATH]:
        if os.path.exists(path):
            with open(path, "r", encoding="utf-8") as f:
                return json.load(f)
    raise FileNotFoundError(DEFAULT_SETS_PATH)


def save_material_sets(doc: Dict[str, Any], data_dir: str) -> str:
    """Write the edited sets atomically to ``<data_dir>/material_sets.json``; returns the path."""
    os.makedirs(data_dir, exist_ok=True)
    path = os.path.join(data_dir, "material_sets.json")
    tmp = f"{path}.tmp.{os.getpid()}"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(doc, f, indent=2)
    os.replace(tmp, path)
    return path


# ------------------------------------------------------------------ preset generation (the one implementation)
class _Skip(Exception):
    pass


def effective_aggressiveness(tool: dict, base: Any, use_tool_overrides: bool = True) -> float:
    """Aggressiveness (fraction) for a tool: its ``custom_aggressiveness`` override when allowed, else ``base``."""
    if use_tool_overrides and tool.get("custom_aggressiveness") not in (None, ""):
        return normalize_aggressiveness(tool["custom_aggressiveness"])
    return normalize_aggressiveness(base)


def _cache_key(tool: dict, g: ToolGeometry, material: dict, label: str, aggr: float, model, runout, max_rpm,
               max_hp, coating, extra) -> Tuple:
    blob = hashlib.md5(json.dumps([fusion_payload(tool), tool_is_carbide(tool)], sort_keys=True,
                                  default=str).encode()).hexdigest()
    return (blob, round(g.stickout, 5), material["family"], material.get("alloy", ""), label, round(aggr, 4),
            model or "v1", round(runout, 6), max_rpm, max_hp, coating, extra)


def generate_presets(tool: dict, materials: List[dict], strategies: List[str], aggressiveness: float, *,
                     physics: Any, max_rpm: float, max_hp: float, runout: float, model: Optional[str] = None,
                     machine_profile: Optional[dict] = None, coating: Optional[str] = None,
                     cache: Optional[dict] = None, name_prefix: Optional[str] = None, tag: bool = True,
                     now: Optional[_dt.date] = None) -> Tuple[List[dict], List[dict]]:
    """ToolWiz presets for one Fusion tool: one per (material, strategy). Returns ``(presets, skipped)``.

    ``materials``: dicts with ``label`` (used in the preset name), ``family``, ``alloy`` and optional ``id``.
    ``strategies``: end-mill strategy names; ``tool_strategy.plan_strategies`` decides what applies to this
    tool type (slot mills get T-slot presets, drills / taps / reamers get one hole preset, other form tools none).
    ``aggressiveness``: fraction 0..1. ``runout`` in inches; ``coating`` None = read from the tool.
    The tool's real geometry and stickout are used (the tool dict is passed to ``pipeline.run_cut`` as
    ``fusion_tool``). Values are written in the tool's own unit. Presets are named ``<label> - <strategy>``
    (``name_prefix`` replaces the label), carry the key assumptions in ``description`` and, with ``tag``, a
    ``toolwiz`` object (see ``preset_tag``). ``cache`` (a dict) memoises pipeline results across tools and calls.
    ``skipped`` entries are {"material", "strategy", "reason"}; "material" is None for tool-level reasons,
    which carry ``"fatal": True`` when the tool cannot take any preset at all.
    """
    skipped: List[dict] = []
    presets: List[dict] = []
    kind = classify(tool.get("type"))

    def tool_skip(reason: str):
        # "fatal": the tool cannot take any preset (not a cutting tool, unreadable geometry), as opposed to a
        # tool type for which no strategy applies
        skipped.append({"material": None, "strategy": None, "reason": reason, "fatal": True})
        return presets, skipped

    if kind in (ToolKind.HOLDER, ToolKind.PROBE):
        return tool_skip(f"{kind.value} is not a cutting tool")
    if kind is ToolKind.UNKNOWN:
        return tool_skip(f"unrecognized tool type {tool.get('type')!r}")
    if kind is ToolKind.BORE:
        return tool_skip("boring bar: no drilling or milling preset applies")
    try:
        g = ToolGeometry.from_fusion(tool, stickout_override=tool.get("stickout"))
        unit = tool_unit(tool)
    except (UnitError, ValueError, TypeError) as ge:
        return tool_skip(f"invalid geometry: {ge}")
    if is_tap_kind(kind) and g.thread_pitch is None:
        return tool_skip("tap has no thread pitch (TP); refusing to assume one")

    cache = cache if cache is not None else {}
    carbide = tool_is_carbide(tool)
    hole = is_hole_kind(kind)
    coat = coating or tool_coating(tool)
    payload = fusion_payload(tool)
    pct = int(round(aggressiveness * 100.0))
    assumptions = (f"Aggressiveness: {pct}%, stickout {_fmt_len(g.stickout, unit)}, "
                   f"runout {_fmt_len(runout, unit, 3)}, model {model or 'v1'}")

    def cut(material: dict, label: str, req_kwargs: dict, key_extra) -> Any:
        key = _cache_key(tool, g, material, label, aggressiveness, model, runout, max_rpm, max_hp, coat, key_extra)
        if key not in cache:
            cache[key] = run_cut(physics, CutRequest(
                family=material["family"], alloy=material.get("alloy", ""), diameter=g.diameter, flutes=g.flutes,
                flute_length=g.flute_length, shank_diameter=g.shank_diameter, corner_radius=g.corner_radius,
                stickout=g.stickout, is_carbide=carbide, aggressiveness=aggressiveness, max_rpm=max_rpm,
                max_hp=max_hp, runout=runout, fusion_tool=payload, model=model, machine_profile=machine_profile,
                **req_kwargs))
        return cache[key]

    def common(material: dict, name: str, desc: str) -> dict:
        p = {"guid": str(uuid.uuid4()), "name": name, "description": desc,
             "material": {"category": "all", "query": material["label"], "use-hardness": False}}
        return p

    if hole:
        is_tap = is_tap_kind(kind)
        hole_op = "Tapping" if is_tap else ("Precision Reaming" if kind is ToolKind.REAMER else "Drilling")
        hole_geo = ("Reamer" if kind is ToolKind.REAMER
                    else ("Spot Drill" if kind in (ToolKind.SPOT_DRILL, ToolKind.CENTER_DRILL) else "Square"))
        suffix = "Tapping" if is_tap else ("Reaming" if kind is ToolKind.REAMER else "Drilling")
        tap_type = ("form" if any(k in str(tool.get("description", "")).lower() for k in ("form", "roll"))
                    else "spiral_flute")
        for m in materials:
            res = cut(m, hole_op, dict(
                tool=db_tool_type(kind, tool, carbide), geometry=hole_geo, operation=hole_op, coating=coat,
                tap_type=tap_type, pitch=g.thread_pitch if is_tap else None,
                apply_coating=False), (hole_op, tap_type, g.thread_pitch))
            v_c, f_z, v_f = _preset_units(unit, sfm=res.sfm, ipt=res.adj_ipt, ipm=res.feed_ipm)
            name = name_prefix if name_prefix else f"{m['label']} - {suffix}"
            p = common(m, name, f"{name} ({assumptions})")
            p.update({"n": int(float(res.rpm)), "v_c": v_c, "f_z": f_z, "f_n": round(f_z * g.flutes, 6), "v_f": v_f,
                      "v_f_leadIn": v_f, "v_f_leadOut": v_f, "v_f_transition": v_f, "v_f_ramp": v_f,
                      "v_f_plunge": v_f, "v_f_retract": round(v_f * 2.0, 3), "use-feed-per-revolution": False,
                      "tool-coolant": "flood"})
            if tag:
                p["toolwiz"] = preset_tag(m, suffix, aggressiveness, model, runout, g.stickout, now)
            presets.append(p)
        return presets, skipped

    if not is_milling_kind(kind):
        return tool_skip(f"no preset defined for tool kind {kind.value}")
    jobs, reasons = plan_strategies(kind, tool, list(strategies))
    for why in reasons:
        skipped.append({"material": None, "strategy": None, "reason": why})
    if not jobs:
        return presets, skipped
    geometry = _cut_geometry_name(kind, g.corner_radius)
    mill_db = db_tool_type(kind, tool, carbide)
    tooth_form, cut_faces = slot_faces(tool) if kind is ToolKind.SLOT else (None, None)
    for m in materials:
        for job in jobs:
            strat = job["label"]
            is_axial = job["tslot_operation"] == "axial_step"
            extra = ({"tslot_operation": job["tslot_operation"], "tooth_form": tooth_form, "cutting_faces": cut_faces,
                      # the Z step does not depend on the slot height, but is 0 for a one-level slot
                      "slot_height": 2.0 * g.flute_length if is_axial else None} if job["tslot_operation"] else {})
            res = cut(m, strat, dict(tool=mill_db, geometry=geometry, operation=job["operation"], coating=coat,
                                     cutter_thickness=g.flute_length, **extra),
                      (job["operation"], job["tslot_operation"], tooth_form, tuple(cut_faces or ())))
            if not res.feasible:
                skipped.append({"material": m["label"], "strategy": strat,
                                "reason": f"infeasible strategy {strat!r}: no safe cut (limited by "
                                          f"{res.limited_by or 'unknown'}); preset not written"})
                continue
            rec_doc, rec_woc = res.doc, res.woc
            rpm, adj_ipt, feed = res.rpm, res.adj_ipt, res.feed_ipm
            if job["tslot_operation"]:
                # T-slot: stepdown = kerf (the head's cutting width), stepover = radial depth per pass.
                # Axial step: stepdown = Z step; the Z feed is the preset feed, so f_z reproduces it.
                rec_woc = res.tslot["radial_depth_per_pass_in"]
                rec_doc = res.tslot["axial_plan"]["z_step_in"] if is_axial else res.tslot["geometry"]["kerf"]
                if is_axial and rpm > 0:
                    adj_ipt = feed / (rpm * g.flutes)
            wear_note = ""
            if "finish" in strat.lower() and abs(res.wear_comp) > 0.0002:
                wear_note = f" | Wear Comp: {res.wear_comp:+.4f}\""
            name = f"{name_prefix or m['label']} - {strat}"
            v_c, f_z, v_f, v_ramp, v_plunge, stepdown, stepover = _preset_units(
                unit, sfm=res.sfm, ipt=adj_ipt, ipm=feed, lengths=(res.ramp_feed, res.plunge_feed, rec_doc, rec_woc))
            plunge_floor = 0.0001 if unit == "inches" else 0.0025
            v_plunge = max(v_plunge, plunge_floor) if feed > 0.0 else 0.0
            p = common(m, name, f"{name}{wear_note} ({assumptions})")
            p["operation_type"] = strat
            p.update({"n": int(float(rpm)), "n_ramp": int(float(rpm)), "v_c": v_c, "f_z": f_z, "f_n": round(f_z * g.flutes, 6),
                      "v_f": v_f, "v_f_leadIn": v_f, "v_f_leadOut": v_f, "v_f_transition": v_f, "v_f_ramp": v_ramp,
                      "v_f_plunge": v_plunge, "stepdown": stepdown, "stepover": stepover, "use-stepdown": True,
                      "use-stepover": True, "ramp-angle": float(res.ramp_angle), "tool-coolant": "flood"})
            if tag:
                p["toolwiz"] = preset_tag(m, strat, aggressiveness, model, runout, g.stickout, now)
            presets.append(p)
    return presets, skipped


# ------------------------------------------------------------------ merge
def _stickout_facts(tool: dict) -> Dict[str, Optional[float]]:
    """Stickout-relevant lengths of a tool in inches: effective stickout (LB, else gauge, else default), the
    assembly gauge length and the holder's gauge length (None when absent)."""
    try:
        unit = tool_unit(tool)
        g = ToolGeometry.from_fusion(tool)
    except (UnitError, ValueError, TypeError):
        return {"stickout": None, "gauge": None, "holder_gauge": None}
    geo = tool.get("geometry") or {}

    def length(v):
        try:
            return to_inches(v, unit) if v not in (None, "", 0) else None
        except (UnitError, ValueError, TypeError):
            return None

    holder = tool.get("holder") if isinstance(tool.get("holder"), dict) else {}
    return {"stickout": g.stickout, "gauge": length(geo.get("assemblyGaugeLength", tool.get("assemblyGaugeLength"))),
            "holder_gauge": length(holder.get("gaugeLength"))}


def stickout_differs(a: Dict[str, Optional[float]], b: Dict[str, Optional[float]],
                     tol: float = STICKOUT_TOLERANCE) -> bool:
    """True when any stickout-relevant length present on both tools differs by more than ``tol`` (relative to
    the larger). Presets depend on stickout, so such tools must stay separate library entries."""
    for k in ("stickout", "gauge", "holder_gauge"):
        x, y = a.get(k), b.get(k)
        if x and y and abs(x - y) / max(x, y) > tol:
            return True
    return False


def _score(t: dict) -> int:
    score = 0
    desc = str(t.get("description") or "")
    if desc and "unnamed" not in desc.lower():
        score += 20
    if (tool_number(t) or 0) > 0:
        score += 15
    score += 10 if t.get("holder") else 0
    score += 5 if t.get("vendor") else 0
    score += 5 if t.get("product-id") else 0
    score += len((t.get("start-values") or {}).get("presets") or [])
    return score


def _library_tools(lib: dict) -> List[Any]:
    for key in ("tools", "data"):
        if isinstance(lib.get(key), list):
            return lib[key]
    inner = lib.get("library")
    if isinstance(inner, dict):
        return inner.get("tools") or inner.get("data") or []
    return inner if isinstance(inner, list) else []


def merge_libraries(libraries: List[dict], *, repair: bool = True, deduplicate: bool = True) -> Tuple[dict, dict]:
    """Merge harvested libraries into one list of tools with provenance.

    ``libraries``: [{"library_name", "source": "document|hub|cloud|local|upload|working", "tools": [...]}] (tools
    may be dicts or JSON strings). Steps: (1) the curator's safe geometry repairs (``repair``): missing or wrong
    micro-tool shank, flute length, stickout LB, shoulder, OAL, shaft taper (no guessing of units, coatings or corner
    radii); (2) group tools by cutter geometry signature (``tool_merger.compute_tool_signature``); (3) inside a
    group, tools whose stickout / assembly gauge / holder gauge differ by more than 10% stay separate entries,
    named ``<description> [stickout <value>]``; the rest merge into one tool whose presets are the union of the
    copies' presets (same name and numbers collapse; same name with different numbers are all kept).
    Returns ``({"tools": [...], "holders": [...]}, report)``; the report lists sources, repairs, merges,
    stickout variants and unreadable tools.
    """
    holders: List[dict] = []
    holder_keys: set = set()
    entries: List[dict] = []        # {"tool", "sig", "facts", "prov"}
    sources, repairs, unreadable = [], [], []
    for li, lib in enumerate(libraries):
        lname = str(lib.get("library_name") or lib.get("name") or f"Library {li + 1}")
        src = str(lib.get("source") or "upload")
        n_in = n_hold = 0
        for raw in _library_tools(lib):
            t = parse_tool(raw)
            if t is None:
                unreadable.append({"library": lname, "reason": "entry is not a tool object"})
                continue
            if str(t.get("type") or "").lower() == "holder":
                n_hold += 1
                hk = str(t.get("guid") or "") or str(t.get("description") or "")
                if hk not in holder_keys:
                    holder_keys.add(hk)
                    holders.append(copy.deepcopy(t))
                continue
            n_in += 1
            t = copy.deepcopy(t)
            desc = str(t.get("description") or t.get("product-id") or "Unnamed Tool")
            if repair:
                r = curate_tool_dict(t, infer_metadata_from_description=False)
                if r.modified or r.warnings:
                    repairs.append({"library": lname, "description": r.description, "tool_number": r.tool_number,
                                    "changes": [c.to_dict() for c in r.changes], "warnings": list(r.warnings)})
                t = r.curated_tool
            prov = {"library": lname, "source": src, "guid": str(t.get("guid") or ""), "number": tool_number(t)}
            entries.append({"tool": t, "sig": compute_tool_signature(t), "facts": _stickout_facts(t),
                            "prov": [prov], "desc": desc})
        sources.append({"library_name": lname, "source": src, "tools": n_in, "holders": n_hold})

    # cluster: signature -> list of clusters (each a list of entries whose stickout is within tolerance)
    by_sig: Dict[str, List[List[dict]]] = {}
    order: List[List[dict]] = []
    for e in entries:
        clusters = by_sig.setdefault(e["sig"], [])
        placed = False
        if deduplicate and not e["sig"].startswith("nosig:"):
            for c in clusters:
                if not stickout_differs(c[0]["facts"], e["facts"]):
                    c.append(e)
                    placed = True
                    break
        if not placed:
            c = [e]
            clusters.append(c)
            order.append(c)

    merged: List[dict] = []
    merged_of: Dict[int, dict] = {}
    used_guids: set = set()
    merged_details, variants = [], []
    for c in order:
        best = max(c, key=lambda e: _score(e["tool"]))
        tool = copy.deepcopy(best["tool"])
        presets: List[dict] = []
        for e in [best] + [x for x in c if x is not best]:
            presets = merge_presets_lists(presets, (e["tool"].get("start-values") or {}).get("presets") or [])
        tool.setdefault("start-values", {})["presets"] = presets
        for e in c:
            if tool.get("custom_aggressiveness") is None and e["tool"].get("custom_aggressiveness") is not None:
                tool["custom_aggressiveness"] = e["tool"]["custom_aggressiveness"]
            if not tool.get("holder") and e["tool"].get("holder"):
                tool["holder"] = copy.deepcopy(e["tool"]["holder"])
        tw = tool.get("toolwiz") if isinstance(tool.get("toolwiz"), dict) else {}
        prov: List[dict] = list(tw.get("provenance") or [])
        for e in c:
            prov.extend(e["prov"])
        seen, uniq = set(), []
        for p in prov:
            k = (p.get("library"), p.get("source"), p.get("guid"), p.get("number"))
            if k not in seen:
                seen.add(k)
                uniq.append(p)
        tw = dict(tw)
        tw["provenance"] = uniq
        tw["libraries"] = sorted({p["library"] for p in uniq})
        tool["toolwiz"] = tw
        g = str(tool.get("guid") or "")
        if not g or g in used_guids:
            tool["guid"] = str(uuid.uuid4())
        used_guids.add(tool["guid"])
        if len(c) > 1:
            merged_details.append({"description": best["desc"], "copies_merged": len(c), "presets": len(presets),
                                   "libraries": tw["libraries"]})
        merged.append(tool)
        merged_of[id(c)] = tool

    # distinct names for stickout variants of one cutter
    for sig, clusters in by_sig.items():
        if len(clusters) < 2 or sig.startswith("nosig:"):
            continue
        detail = []
        for c in clusters:
            t = merged_of[id(c)]
            unit = tool_unit(t)
            so = c[0]["facts"]["stickout"]
            label = _fmt_len(so, unit) if so else "default"
            base_desc = str(t.get("description") or "Tool")
            tag = f"[stickout {label}]"
            if tag not in base_desc:
                t["description"] = f"{base_desc} {tag}"
            t["toolwiz"]["stickout_variant"] = True
            detail.append({"description": t["description"], "stickout_in": round(so or 0, 4),
                           "libraries": t["toolwiz"]["libraries"]})
        variants.append({"signature": sig, "variants": detail})

    report = {"sources": sources, "tools_in": len(entries), "tools_out": len(merged),
              "duplicates_merged": len(entries) - len(merged), "holders": len(holders),
              "merged_details": merged_details, "stickout_variants": variants, "repairs": repairs,
              "repaired_tools": len([r for r in repairs if r["changes"]]), "unreadable": unreadable}
    return {"tools": merged, "holders": holders}, report


# ------------------------------------------------------------------ selection
def select_tools(tools: List[dict], filt: Optional[dict]) -> List[dict]:
    """Tools passing ``filt``: {"types": [Fusion type or tool kind, ...], "diameter_min", "diameter_max",
    "diameter_unit": "in"|"mm" (default "in"), "libraries": [source library names], "sources": [document|hub|...],
    "tool_ids": [tool guid, also matches the guids the tool had in its source libraries]}. All given keys must
    match; an absent or empty key does not filter."""
    f = filt or {}
    types = {str(x).strip().lower() for x in (f.get("types") or [])}
    libs = {str(x).strip().lower() for x in (f.get("libraries") or [])}
    srcs = {str(x).strip().lower() for x in (f.get("sources") or [])}
    ids = {str(x).strip() for x in (f.get("tool_ids") or [])}
    scale = 1.0 / MM if str(f.get("diameter_unit") or "in").lower() in ("mm", "millimeters") else 1.0
    dmin = float(f["diameter_min"]) * scale if f.get("diameter_min") not in (None, "") else None
    dmax = float(f["diameter_max"]) * scale if f.get("diameter_max") not in (None, "") else None
    out = []
    for t in tools:
        if types:
            kind = classify(t.get("type"))
            if str(t.get("type") or "").strip().lower() not in types and kind.value not in types:
                continue
        prov = (t.get("toolwiz") or {}).get("provenance") or []
        if libs and not any(str(p.get("library") or "").lower() in libs for p in prov):
            continue
        if srcs and not any(str(p.get("source") or "").lower() in srcs for p in prov):
            continue
        if ids and not (str(t.get("guid") or "") in ids or any(p.get("guid") in ids for p in prov)):
            continue
        if dmin is not None or dmax is not None:
            try:
                dia = to_inches((t.get("geometry") or {}).get("DC"), tool_unit(t))
            except (UnitError, ValueError, TypeError):
                continue
            if (dmin is not None and dia < dmin - 1e-9) or (dmax is not None and dia > dmax + 1e-9):
                continue
        out.append(t)
    return out


# ------------------------------------------------------------------ build
def _unique_name(name: str, taken: set) -> str:
    if name.lower() not in taken:
        return name
    cand = f"{name} (ToolWiz)"
    n = 2
    while cand.lower() in taken:
        cand = f"{name} (ToolWiz {n})"
        n += 1
    return cand


def build_libraries(tools: List[dict], holders: List[dict], sets: List[dict], *, strategies: List[str],
                    aggressiveness: Any, physics: Any, max_rpm: float, max_hp: float, runout: float,
                    model: Optional[str] = None, machine_profile: Optional[dict] = None,
                    use_tool_overrides: bool = True, cache: Optional[dict] = None,
                    progress: Optional[Callable[[int, int, str], None]] = None,
                    now: Optional[_dt.date] = None) -> List[dict]:
    """One library per material set: the same ``tools`` with that set's ToolWiz presets.

    Each tool first loses its previous ToolWiz-tagged presets (the owner's own presets stay), then gets one
    preset per (material of the set, applicable strategy); a generated name that equals one of the owner's
    preset names gets a " (ToolWiz)" suffix so names stay unique per tool. ``sets``: [{"id","name","materials"}].
    Returns [{"id","name","tools": [...tools then holders...], "skipped": [...], "stats": {...}}]; call
    ``audit_and_prune`` on each next.
    """
    cache = cache if cache is not None else {}
    libs = [{"id": s["id"], "name": s["name"], "tools": [], "skipped": [], "toolwiz_presets": 0,
             "removed_old_toolwiz": 0, "materials": [m["label"] for m in s["materials"]]} for s in sets]
    total = len(tools)
    for i, tool in enumerate(tools):
        desc = str(tool.get("description") or "tool")
        if progress:
            progress(i, total, desc)
        aggr = effective_aggressiveness(tool, aggressiveness, use_tool_overrides)
        base = copy.deepcopy(tool)
        removed = strip_toolwiz_presets(base)
        for s, lib in zip(sets, libs):
            t = copy.deepcopy(base)
            new, skipped = generate_presets(t, s["materials"], strategies, aggr, physics=physics, max_rpm=max_rpm,
                                            max_hp=max_hp, runout=runout, model=model,
                                            machine_profile=machine_profile, cache=cache, now=now)
            sv = t.setdefault("start-values", {})
            existing = sv.setdefault("presets", [])
            taken = {str(p.get("name") or "").lower() for p in existing}
            for p in new:
                p["name"] = _unique_name(p["name"], taken)
                taken.add(p["name"].lower())
            existing.extend(new)
            lib["tools"].append(t)
            lib["toolwiz_presets"] += len(new)
            lib["removed_old_toolwiz"] += removed
            for sk in skipped:
                lib["skipped"].append({"tool": desc, "number": tool_number(tool), "type": tool.get("type"), **sk})
    if progress:
        progress(total, total, "")
    for lib in libs:
        lib["tools"].extend(copy.deepcopy(holders))
    return libs


def audit_and_prune(lib: dict, physics: Any, *, aggressiveness: Any, max_rpm: float, max_hp: float, runout: float,
                    model: Optional[str] = None, machine_profile: Optional[dict] = None) -> Dict[str, Any]:
    """Audit a built library with ``library_audit`` and drop every ToolWiz-generated preset that has a STOP finding
    (the library dict is edited in place). Returns {"summary": {STOP, CAUTION, INFO, tools, presets} after the
    drops, "dropped": [{"tool","preset","code","message"}], "owner_stop": [...STOP findings on the owner's own
    presets, untouched], "cautions_by_code": {...}}. The summary counts the findings that remain; it is not re-audited."""
    import library_audit
    report = library_audit.audit_library(
        {"tools": lib["tools"]}, physics, max_rpm=max_rpm, max_hp=max_hp, runout_in=runout,
        aggressiveness=normalize_aggressiveness(aggressiveness), model=model, machine_profile=machine_profile)
    drop: Dict[Tuple[int, str], dict] = {}
    owner_stop: List[dict] = []
    for f in report["findings"]:
        if f["severity"] != library_audit.STOP:
            continue
        t = lib["tools"][f["tool_index"]]
        name = f.get("preset")
        presets = (t.get("start-values") or {}).get("presets") or []
        mine = [p for p in presets if p.get("name") == name and is_toolwiz_preset(p)]
        if mine:
            drop[(f["tool_index"], name)] = {"tool": f["tool"], "preset": name, "code": f["code"],
                                             "message": f["message"]}
        else:
            owner_stop.append({k: f[k] for k in ("tool", "preset", "code", "message")})
    for (idx, name), _ in drop.items():
        sv = lib["tools"][idx]["start-values"]
        sv["presets"] = [p for p in sv["presets"] if not (p.get("name") == name and is_toolwiz_preset(p))]
    kept = [f for f in report["findings"] if (f["tool_index"], f.get("preset")) not in drop]
    summary = {s: sum(1 for f in kept if f["severity"] == s) for s in ("STOP", "CAUTION", "INFO")}
    summary.update(tools=report["summary"]["tools"], presets=report["summary"]["presets"] - len(drop))
    # STOP findings left on ToolWiz presets: zero by construction (they were dropped above)
    summary["toolwiz_STOP"] = sum(1 for f in kept if f["severity"] == "STOP" and
                                  any(p.get("name") == f.get("preset") and is_toolwiz_preset(p)
                                      for p in (lib["tools"][f["tool_index"]].get("start-values") or {}).get("presets") or []))
    by_code: Dict[str, int] = {}
    for f in kept:
        if f["severity"] == "CAUTION":
            by_code[f["code"]] = by_code.get(f["code"], 0) + 1
    return {"summary": summary, "dropped": list(drop.values()), "owner_stop": owner_stop,
            "cautions_by_code": by_code}


def select_sets(doc: dict, set_ids: Optional[List[str]], material_ids: Optional[List[str]]) -> List[dict]:
    """Sets of ``doc`` restricted to ``set_ids`` (None = all) and, inside them, to ``material_ids`` (None = all).
    Raises ValueError for unknown ids or when nothing is left."""
    all_sets = {s["id"]: s for s in doc["sets"]}
    if set_ids:
        unknown = [s for s in set_ids if s not in all_sets]
        if unknown:
            raise ValueError(f"unknown set id(s) {unknown}; known: {sorted(all_sets)}")
        chosen = [all_sets[s] for s in set_ids]
    else:
        chosen = list(doc["sets"])
    if material_ids:
        known = {m["id"] for s in doc["sets"] for m in s["materials"]}
        unknown = [m for m in material_ids if m not in known]
        if unknown:
            raise ValueError(f"unknown material id(s) {unknown}; known: {sorted(known)}")
        chosen = [{**s, "materials": [m for m in s["materials"] if m["id"] in material_ids]} for s in chosen]
        chosen = [s for s in chosen if s["materials"]]
    if not chosen:
        raise ValueError("no material set / material selected")
    return chosen


def check_strategies(strategies: Any) -> List[str]:
    """Validated strategy list (subset of the four end-mill strategies; case-insensitive input)."""
    if strategies in (None, ""):
        return list(END_MILL_STRATEGIES)
    if not isinstance(strategies, list) or not strategies:
        raise ValueError("strategies must be a non-empty list")
    canon = {s.lower(): s for s in END_MILL_STRATEGIES}
    out = []
    for s in strategies:
        if str(s).strip().lower() not in canon:
            raise ValueError(f"unknown strategy {s!r}; known: {list(END_MILL_STRATEGIES)}")
        out.append(canon[str(s).strip().lower()])
    return out
