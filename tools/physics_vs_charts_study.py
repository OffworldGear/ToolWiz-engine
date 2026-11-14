#!/usr/bin/env python3
"""Physics versus vendor charts: how much of the shipped answer is chart, how much is physics (a STUDY; nothing in the
engine, the data files or the tests is changed).

For every conformance group (tests/test_vendor_conformance.py: family x operation x diameter band x engagement class,
square end, >= 2 cited rows) the engine runs on the group's median tool at the group's median ap/D and ae/D
(evaluate_user_engagement, as the conformance test does) in three ways:
  a  as shipped, unbranded (vendor guardrail C14 on: Harvey + Helical default chart, else cross-vendor consensus)
  b  physics only: C14 off (params.CONSENSUS_PATH and VENDOR_TABLE_PATH set to None in the worker), everything else as shipped
  c  "pure mechanics": C14 off AND the vendor-fitted C7 speed level and C2 chip limit relaxed x RELAX through the
     aggressiveness margins (Margins.speed_scale, Margins.limit_scale) and Material.c2_scale (C2, C2o); nothing in the engine is edited
  d  as c but only C2 relaxed (C7 speed kept), to separate the chip-limit effect from the speed effect
Machines: machines/test_generic_60k.json (runout 0.0001") and the owner's machines/speedio_s500x2.json (16k, runout 0.0002").
Aggressiveness 0.5 (all three modes), 0 and 100 % (modes a and b).
Also: the chart as printed (group median SFM and fz) is evaluated against the physics checks (C1, C3, C4, C5, C15 = mechanics;
C2, C7 = vendor-fitted), a stickout / runout / machine second pass on 20 groups, a what-if pass for a "generic import" tool
(lower TRS, larger edge radius, more runout, lower aggressiveness), the unbranded-tool and "tool grade" probes, and the
chart coverage of the (family, operation, diameter band) cells.

Usage (repo root):  python3 tools/physics_vs_charts_study.py [--quick] [--out data/studies/physics_vs_charts.json]
Environment: TOOLWIZ_CONFORMANCE_WORKERS (processes), TOOLWIZ_MP_START (fork | spawn).
"""
import argparse
import collections
import concurrent.futures
import contextlib
import dataclasses
import glob
import json
import math
import multiprocessing
import os
import re
import statistics
import sys
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
for _p in (ROOT, os.path.join(ROOT, "tests"), os.path.join(ROOT, "tools")):
    if _p not in sys.path:
        sys.path.insert(0, _p)
os.environ.setdefault("TOOLWIZ_MODEL", "v2")

import test_vendor_conformance as C  # noqa: E402
import app  # noqa: E402
import pipeline  # noqa: E402
import v2_bridge  # noqa: E402
from pipeline import run_cut  # noqa: E402
from physics_v2 import params, optimize as O  # noqa: E402

OUT_DEFAULT = os.path.join(ROOT, "data", "studies", "physics_vs_charts.json")
SPEEDIO_PATH = os.path.join(ROOT, "machines", "speedio_s500x2.json")
MACHINES = {"test60k": (C.PROFILE_PATH, 0.0001), "speedio": (SPEEDIO_PATH, 0.0002)}
RELAX = 10.0                     # mode c: x10 on the C7 speed level and the C2 chip limit
TOL = 0.01                       # 1 % tolerance when placing a value against a published range / comparing two runs
BIND_TOL = 0.03                  # optimize._binding
VENDOR_IDS = ("C14v", "C14f", "C14m", "C14lo")
FITTED_IDS = ("C2", "C2o")       # C7 (tool life) is fitted too; its rpm-cap face is the machine
MECH_IDS = ("C1", "C3", "C4", "C5", "C6", "C8", "C10", "C12", "C13", "C15")
FZ_IDS = ("C2", "C2o", "C3", "C4", "C5", "C10", "C11", "C14f", "C14m", "C15")   # 'max' checks that set the upper chip load
CHART_MECH_IDS = ("C1", "C3", "C4", "C5", "C15", "C6", "C10", "C11", "C12")
STICK_K = (2, 4, 6, 8)
TIRS = (0.0001, 0.0004, 0.001)
BAND3 = {"<=1/32": "micro (<=1/16)", "1/32-1/16": "micro (<=1/16)", "1/16-1/8": "1/16-1/8"}


def band3(b):
    return BAND3.get(b, "larger (>1/8)")


def category(cid):
    if cid in VENDOR_IDS:
        return "vendor guardrail"
    if cid in FITTED_IDS or cid == "C7life":
        return "vendor-fitted physics"
    if cid in ("machine", "C11"):   # C11 = the machine's max cutting feed / the effective adaptive feed
        return "machine"
    return "mechanics"


# --------------------------------------------------------------------------------------------------------------------
# worker
# --------------------------------------------------------------------------------------------------------------------

_PROFILES = {}


def profile(name):
    if name not in _PROFILES:
        with open(MACHINES[name][0], encoding="utf-8") as fh:
            _PROFILES[name] = json.load(fh)
    return _PROFILES[name]


def machine_max_rpm(prof):
    sp = (prof.get("spindle_options") or {})
    s = sp.get(prof.get("active_spindle")) or next(iter(sp.values()))
    return min(float(s.get("max_rpm") or C.MAX_RPM), C.MAX_RPM)


@contextlib.contextmanager
def patched(mode, whatif=None):
    """Mode a/b/c (module-level switches of physics_v2.params; no engine edit) plus optional what-if tool/material changes."""
    saved = (params.CONSENSUS_PATH, params.VENDOR_TABLE_PATH, params.margins, v2_bridge.tool_for, params.material)
    try:
        if mode in ("b", "c", "d"):
            params.CONSENSUS_PATH = None
            params.VENDOR_TABLE_PATH = None
        if mode in ("c", "d"):
            orig = saved[2]

            def relaxed(a):
                mg = orig(a)
                return dataclasses.replace(mg, speed_scale=mg.speed_scale * (RELAX if mode == "c" else 1.0),
                                           limit_scale=mg.limit_scale * RELAX)
            params.margins = relaxed
            mat0 = saved[4]

            def material(*a, **k):   # C2o (worst-flute chip <= vendor p90) is the next vendor-fitted limit: scale it too
                m = mat0(*a, **k)
                return dataclasses.replace(m, c2_scale=m.c2_scale * RELAX)
            params.material = material
        if whatif:
            tf = saved[3]

            def tool_for(r):
                t = tf(r)
                return dataclasses.replace(t, edge_radius_mm=t.edge_radius_mm * whatif.get("edge", 1.0),
                                           trs_mpa=t.trs_mpa * whatif.get("trs", 1.0))
            v2_bridge.tool_for = tool_for
        v2_bridge._CACHE.clear()
        yield
    finally:
        params.CONSENSUS_PATH, params.VENDOR_TABLE_PATH, params.margins, v2_bridge.tool_for, params.material = saved
        v2_bridge._CACHE.clear()


def margin_of(c):
    """Margin of a shipped check (v2["checks"] holds id, value, limit, margin, ok, detail; margin None when it does not apply)."""
    return c.get("margin")


def decide(res, max_rpm):
    """(speed decider, chip decider, details) from the shipped checks and the binding list."""
    v2 = res.v2 or {}
    ck = v2.get("checks") or {}
    binding = list(v2.get("binding") or [])
    c14v = ck.get("C14v") or {}
    c7 = ck.get("C7") or {}
    m = re.search(r"C9 ([0-9.]+) =", c7.get("detail") or "")
    reach = float(m.group(1)) if m else 1.0
    if margin_of(c14v) is not None and margin_of(c14v) <= BIND_TOL:
        speed = "C14v"
    elif res.rpm >= 0.995 * max_rpm:
        speed = "machine"
    elif reach < 0.995:
        speed = "C9"
    else:
        speed = "C7life"
    if not res.feasible:
        viol = list(v2.get("violated") or [])
        chip = "infeasible:" + "+".join(viol)
        chip_primary = viol[0] if viol else "?"
    else:
        cands = [(margin_of(ck[k]), k) for k in FZ_IDS if k in ck and margin_of(ck[k]) is not None]
        cands.sort()
        chip_primary = cands[0][1] if cands else "?"
        chip = chip_primary
    chip_vendor_binds = any(k in binding for k in ("C14f", "C14m"))
    return speed, chip, chip_primary, chip_vendor_binds, binding, reach


def evaluate_chart(req, prof, g, chart, agg, max_rpm):
    """The chart as printed (group median SFM and fz at the group's ap/ae) against the physics checks."""
    r = pipeline._normalize(req)
    op = v2_bridge.OPERATION_MAP[str(r.operation).strip().lower()]
    hb, tool, machine, _, _ = v2_bridge._setup(app.physics, r, op, prof)
    material = params.material(r.family, hb=hb, coating=r.coating)
    D = g["D"]
    rpm_want = chart["sfm_med"] * 12.0 / (math.pi * D)
    rpm = min(rpm_want, machine.max_rpm)
    opts = dict(c2_basis=params.C2_BASIS, chip_space=params.CHIP_SPACE_PATH, chip_flutes=params.CHIP_FLUTES_PATH,
                user_engagement=True)
    rep = O.evaluate_cut(tool, material, machine, op, float(req.cut_depth), float(req.cut_width), chart["fz_med"], rpm,
                         margins=params.margins(agg), n_theta=O.HIRES_THETA, n_quad=O.HIRES_QUAD, **opts)
    viol = {k: round(v["over_by"], 3) if v.get("over_by") is not None else None
            for k, v in ((x["id"], x) for x in _violations(rep))}
    return {"rpm_wanted": round(rpm_want), "rpm_reachable": rpm_want <= machine.max_rpm * 1.0001,
            "rpm_used": round(rpm), "sfm_used": round(math.pi * D * rpm / 12.0, 1), "violated": viol,
            "mech": sorted(k for k in viol if k in CHART_MECH_IDS), "fitted": sorted(k for k in viol if k in ("C2", "C2o", "C7")),
            "margins": {k: round(rep["checks"][k]["margin"], 3) for k in ("C1", "C2", "C3", "C4", "C5", "C15")
                        if k in rep["checks"] and rep["checks"][k].get("margin") is not None and rep["checks"][k].get("applies")}}


def _violations(rep):
    out = []
    for k in rep.get("violated") or []:
        c = rep["checks"][k]
        lim, val = c.get("limit"), c.get("value")
        over = None
        if lim:
            over = (val - lim) / lim if c.get("kind") == "max" else (lim - val) / lim
        out.append({"id": k, "over_by": over})
    return out


def run_variant(job):
    """Worker: job = {rows, var} -> one compact record."""
    rows, var = job["rows"], job["var"]
    prof = profile(var["machine"])
    max_rpm = machine_max_rpm(prof)
    try:
        g = C.median_tool(rows)
        op = rows[0]["operation"]
        D = g["D"]
        ap = C.med([float(r["cut"]["ap"]) / float(r["tool"]["DC"]) for r in rows])
        ae = C.med([min(float(r["cut"]["ae"]) / float(r["tool"]["DC"]), 1.0) for r in rows])
        tir = var.get("tir", MACHINES[var["machine"]][1])
        req, _ = C.request_for(rows, op, prof, ap, ae, tir)
        upd = {"aggressiveness": var["agg"]}
        if var.get("stick_k"):
            stick = max(var["stick_k"] * D, g["lcf"])
            upd["stickout"] = stick
            if req.has_relieved_neck:
                upd["neck_length"] = stick
        if var.get("tool"):
            upd["tool"] = var["tool"]
        req = dataclasses.replace(req, **upd)
    except Exception as ex:   # a crash is a failed job
        return {"var": var, "error": f"{type(ex).__name__}: {ex}"}
    real = app.physics.resolve_alloy_hardness
    app.physics.resolve_alloy_hardness = lambda family, alloy: g["hb"]
    try:
        with patched(var["mode"], var.get("whatif")):
            res = run_cut(app.physics, req)
            rec = {"var": var}
            if res.model != "v2":
                rec["error"] = f"model {res.model}"
                return rec
            speed, chip, chip_primary, chip_vendor, binding, reach = decide(res, max_rpm)
            ck = (res.v2 or {}).get("checks") or {}
            ap_in, ae_in, feed = float(res.rec_doc), float(res.rec_woc), float(res.feed_ipm)
            vb = res.vendor_basis or {}
            rec.update(feasible=bool(res.feasible), sfm=round(res.sfm, 1), rpm=round(res.rpm), fz=round(res.adj_ipt, 6),
                       ap=round(ap_in, 5), ae=round(ae_in, 5), feed=round(feed, 2), mrr=round(ap_in * ae_in * feed, 4),
                       binding=binding, speed_decider=speed, chip_decider=chip, chip_primary=chip_primary,
                       chip_vendor_binds=chip_vendor, reach=reach, flutes_cutting=res.flutes_cutting, z=int(req.flutes),
                       basis={k: vb.get(k) for k in ("mode", "vendor", "chart_class", "rows")},
                       sfm_range=vb.get("sfm_range"), fz_range=vb.get("fz_range"),
                       margins={k: round(margin_of(ck[k]), 3) for k in ("C1", "C2", "C3", "C4", "C5", "C14f", "C14v", "C15")
                                if k in ck and margin_of(ck[k]) is not None},
                       violated=list((res.v2 or {}).get("violated") or []))
            if var.get("chart"):
                rec["chart_check"] = evaluate_chart(req, prof, g, var["chart"], var["agg"], max_rpm)
    except Exception as ex:
        return {"var": var, "error": f"{type(ex).__name__}: {ex}"}
    finally:
        app.physics.resolve_alloy_hardness = real
    return rec


def pool_map(items, fn=run_variant):
    """Process pool with the spawn-safe pattern of tests/test_vendor_conformance.py::_pool_map."""
    ctx = multiprocessing.get_context(os.environ.get("TOOLWIZ_MP_START") or (
        "fork" if "fork" in multiprocessing.get_all_start_methods() else "spawn"))
    workers = int(os.environ.get("TOOLWIZ_CONFORMANCE_WORKERS") or max(1, min(os.cpu_count() or 1, 8)))
    saved = list(sys.path)
    sys.path[:] = [e for e in sys.path if os.path.basename(os.path.normpath(e or ".")) != "ToolWizFusionAddin"]
    try:
        with concurrent.futures.ProcessPoolExecutor(max_workers=workers, mp_context=ctx) as ex:
            return list(ex.map(fn, items, chunksize=4))
    finally:
        sys.path[:] = saved


# --------------------------------------------------------------------------------------------------------------------
# groups, chart statistics
# --------------------------------------------------------------------------------------------------------------------

def vmid(rows, key):
    vals = []
    for r in rows:
        c = r["cut"][key]
        v = c.get("nominal")
        if v is None and c.get("min") is not None and c.get("max") is not None:
            v = (c["min"] + c["max"]) / 2
        if v is None:
            v = c.get("max") or c.get("min")
        if v is not None:
            vals.append(v)
    return statistics.median(vals) if vals else None


def vendor_of(path):
    stem = os.path.basename(path)[:-5]
    return {"harvey_ball_cr": "harvey", "osg_ball": "osg"}.get(stem, stem)


def load_groups():
    fams = set(params.load()["families"])
    rows, vend = [], {}
    for path in sorted(glob.glob(os.path.join(C.BENCH_DIR, "*.json"))):
        v = vendor_of(path)
        for r in json.load(open(path, encoding="utf-8"))["rows"]:
            r["_vendor"] = v
            rows.append(r)
    scope = [r for r in rows if C.in_scope(r, fams)]
    groups = collections.defaultdict(list)
    for r in scope:
        groups[C.group_of(r)].append(r)
    groups = {k: v for k, v in groups.items() if len(v) >= C.MIN_GROUP_ROWS}
    return fams, rows, scope, groups


def chart_stats(rows):
    smin, smax = C.span(rows, "sfm")
    fmin, fmax = C.span(rows, "fz")
    return {"sfm_min": smin, "sfm_med": vmid(rows, "sfm"), "sfm_max": smax,
            "fz_min": fmin, "fz_med": vmid(rows, "fz"), "fz_max": fmax}


def gkey(k):
    return "|".join(k)


def pick_second_pass(groups, n=20):
    """Deterministic spread over operations, families and diameter bands (groups with >= 3 rows, larger first)."""
    per_op = max(1, n // 4)
    chosen, used_fam, used_band = [], collections.Counter(), collections.Counter()
    for op in C.OPERATIONS:
        cands = sorted((k for k, v in groups.items() if k[1] == op and len(v) >= 3), key=lambda k: (-len(groups[k]), k))
        got = 0
        while got < per_op and cands:
            cands.sort(key=lambda k: (used_fam[k[0]] + used_band[k[2]], -len(groups[k]), k))
            k = cands.pop(0)
            chosen.append(k)
            used_fam[k[0]] += 1
            used_band[k[2]] += 1
            got += 1
    return chosen[:n]


# --------------------------------------------------------------------------------------------------------------------
# aggregation
# --------------------------------------------------------------------------------------------------------------------

def pct(n, d):
    return round(100.0 * n / d, 1) if d else None


def quantiles(vals):
    vals = sorted(v for v in vals if v is not None)
    if not vals:
        return None
    q = lambda p: vals[min(len(vals) - 1, int(p * (len(vals) - 1) + 0.5))]
    return {"n": len(vals), "min": round(vals[0], 3), "p10": round(q(0.1), 3), "p25": round(q(0.25), 3),
            "median": round(q(0.5), 3), "p75": round(q(0.75), 3), "p90": round(q(0.9), 3), "max": round(vals[-1], 3)}


def place(x, lo, hi):
    if x > hi * (1 + TOL):
        return "above"
    if x < lo * (1 - TOL):
        return "below"
    return "inside"


def ok_run(runs, *key):
    r = runs.get("|".join(map(str, key)))
    return r if r and "error" not in r else None


def share_table(recs, keyfn, pred):
    d = collections.defaultdict(lambda: [0, 0])
    for r in recs:
        k = keyfn(r)
        d[k][1] += 1
        d[k][0] += 1 if pred(r) else 0
    return {k: {"n": v[1], "count": v[0], "pct": pct(v[0], v[1])} for k, v in sorted(d.items())}


def aggregate(records):
    """records: per-group dicts with meta, chart and runs {"machine|agg|mode": run}."""
    out = {}
    for mach in MACHINES:
        for agg in (0.5, 0.0, 1.0):
            sec = {}
            recs = [r for r in records if ok_run(r["runs"], mach, agg, "a") and ok_run(r["runs"], mach, agg, "b")]
            A = lambda r: r["runs"][f"{mach}|{agg}|a"]
            B = lambda r: r["runs"][f"{mach}|{agg}|b"]
            sec["n_groups"] = len(recs)
            # deciders (binding based) at (a)
            vs = lambda r: A(r)["speed_decider"] == "C14v"
            vc = lambda r: A(r)["chip_vendor_binds"]
            sec["vendor_binds_speed"] = {"count": sum(map(vs, recs)), "pct": pct(sum(map(vs, recs)), len(recs))}
            sec["vendor_binds_chip"] = {"count": sum(map(vc, recs)), "pct": pct(sum(map(vc, recs)), len(recs))}
            both = lambda r: vs(r) and vc(r)
            either = lambda r: vs(r) or vc(r)
            sec["vendor_binds_both"] = {"count": sum(map(both, recs)), "pct": pct(sum(map(both, recs)), len(recs))}
            sec["vendor_binds_either"] = {"count": sum(map(either, recs)), "pct": pct(sum(map(either, recs)), len(recs))}
            # counterfactual: removing C14 changes the answer by > 1 %
            cs = lambda r: B(r)["sfm"] > A(r)["sfm"] * (1 + TOL)
            cc = lambda r: B(r)["fz"] > A(r)["fz"] * (1 + TOL)
            sec["cf_vendor_changes_speed"] = {"count": sum(map(cs, recs)), "pct": pct(sum(map(cs, recs)), len(recs))}
            sec["cf_vendor_changes_chip"] = {"count": sum(map(cc, recs)), "pct": pct(sum(map(cc, recs)), len(recs))}
            cb = lambda r: cs(r) and cc(r)
            ce = lambda r: cs(r) or cc(r)
            sec["cf_vendor_changes_both"] = {"count": sum(map(cb, recs)), "pct": pct(sum(map(cb, recs)), len(recs))}
            sec["cf_vendor_changes_either"] = {"count": sum(map(ce, recs)), "pct": pct(sum(map(ce, recs)), len(recs))}
            fa = lambda r: A(r)["feed"] * A(r)["ae"] * A(r)["ap"]
            sec["cf_vendor_mrr_gain_pct_median"] = round(100 * (statistics.median(
                B(r)["mrr"] / A(r)["mrr"] - 1 for r in recs if A(r)["mrr"] > 0)), 1) if recs else None
            # decider categories
            sec["speed_decider"] = dict(collections.Counter(A(r)["speed_decider"] for r in recs))
            sec["chip_decider_primary"] = dict(collections.Counter(
                ("vendor:C14f" if A(r)["chip_vendor_binds"] else A(r)["chip_decider"]) for r in recs))
            sec["chip_category"] = dict(collections.Counter(
                "vendor guardrail" if A(r)["chip_vendor_binds"] else
                ("infeasible (mechanics)" if not A(r)["feasible"] else category(A(r)["chip_primary"])) for r in recs))
            sec["speed_category"] = dict(collections.Counter(category(A(r)["speed_decider"] if A(r)["speed_decider"] != "C9" else "C6")
                                                             for r in recs))
            sec["infeasible_at_chart_engagement"] = {"count": sum(1 for r in recs if not A(r)["feasible"]),
                                                     "pct": pct(sum(1 for r in recs if not A(r)["feasible"]), len(recs))}
            sec["basis_mode"] = dict(collections.Counter((A(r)["basis"] or {}).get("mode") for r in recs))
            for name, kf in (("op", lambda r: r["meta"]["op"]), ("family", lambda r: r["meta"]["family"]),
                             ("band", lambda r: band3(r["meta"]["band"])), ("band6", lambda r: r["meta"]["band"])):
                sec["by_" + name] = {
                    "vendor_binds_speed": share_table(recs, kf, vs), "vendor_binds_chip": share_table(recs, kf, vc),
                    "vendor_binds_both": share_table(recs, kf, both), "cf_changes_either": share_table(recs, kf, ce)}
            # (b) against the published range
            def rng_check(r):
                m = r["meta"]
                cap = math.pi * m["D"] * machine_rpm(mach) / 12.0
                c = r["chart"]
                lo, hi = min(c["sfm_min"], cap), min(c["sfm_max"], cap)
                b = B(r)
                return {"sfm": place(b["sfm"], lo, hi), "fz": place(b["fz"], c["fz_min"], c["fz_max"]),
                        "sfm_hi": b["sfm"] / hi, "sfm_lo": b["sfm"] / lo, "fz_hi": b["fz"] / c["fz_max"], "fz_lo": b["fz"] / c["fz_min"],
                        "sfm_med": b["sfm"] / c["sfm_med"], "fz_med": b["fz"] / c["fz_med"],
                        "feed_med": b["sfm"] * b["fz"] / (c["sfm_med"] * c["fz_med"]),
                        "a_sfm_med": A(r)["sfm"] / c["sfm_med"], "a_fz_med": A(r)["fz"] / c["fz_med"],
                        "a_feed_med": A(r)["sfm"] * A(r)["fz"] / (c["sfm_med"] * c["fz_med"]), "cap_limited": c["sfm_min"] > cap}
            rc = [(r, rng_check(r)) for r in recs]
            sec["physics_only_vs_range"] = {}
            for q in ("sfm", "fz"):
                n = len(rc)
                c = collections.Counter(x[q] for _, x in rc)
                both_in = None
                sec["physics_only_vs_range"][q] = {k: {"count": c.get(k, 0), "pct": pct(c.get(k, 0), n)} for k in ("inside", "above", "below")}
            allin = sum(1 for _, x in rc if x["sfm"] == "inside" and x["fz"] == "inside")
            sec["physics_only_vs_range"]["both_inside"] = {"count": allin, "pct": pct(allin, len(rc))}
            sec["physics_only_vs_range"]["either_above"] = {"count": sum(1 for _, x in rc if "above" in (x["sfm"], x["fz"])),
                                                           "pct": pct(sum(1 for _, x in rc if "above" in (x["sfm"], x["fz"])), len(rc))}
            sec["ratio_b_over_chart_median"] = {q: quantiles([x[q] for _, x in rc]) for q in ("sfm_med", "fz_med", "feed_med")}
            sec["ratio_a_over_chart_median"] = {q: quantiles([x[q] for _, x in rc]) for q in ("a_sfm_med", "a_fz_med", "a_feed_med")}
            sec["ratio_b_over_chart_max"] = {q: quantiles([x[q] for _, x in rc]) for q in ("sfm_hi", "fz_hi")}
            sec["ratio_b_over_chart_min"] = {q: quantiles([x[q] for _, x in rc]) for q in ("sfm_lo", "fz_lo")}
            for name, kf in (("op", lambda r: r["meta"]["op"]), ("band", lambda r: band3(r["meta"]["band"])),
                             ("family", lambda r: r["meta"]["family"])):
                d = collections.defaultdict(list)
                for r, x in rc:
                    d[kf(r)].append(x)
                sec["physics_only_by_" + name] = {k: {
                    "n": len(v), "sfm_above_pct": pct(sum(1 for x in v if x["sfm"] == "above"), len(v)),
                    "sfm_below_pct": pct(sum(1 for x in v if x["sfm"] == "below"), len(v)),
                    "fz_above_pct": pct(sum(1 for x in v if x["fz"] == "above"), len(v)),
                    "fz_below_pct": pct(sum(1 for x in v if x["fz"] == "below"), len(v)),
                    "median_feed_ratio": round(statistics.median(x["feed_med"] for x in v), 2)} for k, v in sorted(d.items())}

            def row(r, x):
                b = B(r)
                return {"group": r["key"], "n": r["meta"]["n"], "D": r["meta"]["D"], "sfm_chart": [round(r["chart"][k]) for k in ("sfm_min", "sfm_med", "sfm_max")],
                        "fz_chart": [round(r["chart"][k], 5) for k in ("fz_min", "fz_med", "fz_max")],
                        "sfm_b": b["sfm"], "fz_b": b["fz"], "feed_ratio": round(x["feed_med"], 2), "sfm_ratio": round(x["sfm_med"], 2),
                        "fz_ratio": round(x["fz_med"], 2), "speed_by": b["speed_decider"], "chip_by": b["chip_decider"], "binding_b": b["binding"]}
            srt = sorted(rc, key=lambda p: p[1]["feed_med"])
            sec["worst_above_feed"] = [row(r, x) for r, x in srt[::-1][:15]]
            sec["worst_below_feed"] = [row(r, x) for r, x in srt[:15]]
            sec["worst_above_sfm"] = [row(r, x) for r, x in sorted(rc, key=lambda p: -p[1]["sfm_hi"])[:15]]
            sec["worst_above_fz"] = [row(r, x) for r, x in sorted(rc, key=lambda p: -p[1]["fz_hi"])[:15]]
            sec["worst_below_sfm"] = [row(r, x) for r, x in sorted(rc, key=lambda p: p[1]["sfm_lo"])[:15]]
            sec["worst_below_fz"] = [row(r, x) for r, x in sorted(rc, key=lambda p: p[1]["fz_lo"])[:15]]
            # what decides at (b): physics only
            sec["b_speed_decider"] = dict(collections.Counter(B(r)["speed_decider"] for r in recs))
            sec["b_chip_decider"] = dict(collections.Counter(B(r)["chip_decider"] if B(r)["feasible"] else "infeasible" for r in recs))
            sec["b_chip_category"] = dict(collections.Counter(
                "infeasible (mechanics)" if not B(r)["feasible"] else category(B(r)["chip_primary"]) for r in recs))
            # mechanics decides: at (b) the chip load is set by a mechanics limit (or no feasible chip), or the machine caps speed
            mech = [(r, x) for r, x in rc if (not B(r)["feasible"]) or category(B(r)["chip_primary"]) == "mechanics"]
            sec["mechanics_decides_chip_b"] = {"count": len(mech), "pct": pct(len(mech), len(rc))}
            sec["mechanics_decides_chip_b_detail"] = dict(collections.Counter(
                "infeasible:" + "+".join(B(r)["violated"]) if not B(r)["feasible"] else B(r)["chip_primary"] for r, _ in mech))
            sec["mechanics_decides_chip_b_feed_ratio_vs_chart_median"] = quantiles([x["feed_med"] for _, x in mech])
            sec["mechanics_decides_chip_b_fz_ratio_vs_chart_median"] = quantiles([x["fz_med"] for _, x in mech])
            sec["mechanics_decides_chip_b_by_op"] = dict(collections.Counter(r["meta"]["op"] for r, _ in mech))
            sec["mechanics_decides_chip_b_by_band"] = dict(collections.Counter(band3(r["meta"]["band"]) for r, _ in mech))
            sec["mechanics_decides_chip_b_by_family"] = dict(collections.Counter(r["meta"]["family"] for r, _ in mech))
            sec["mechanics_decides_chip_b_by_limit_op_band"] = {}
            d = collections.defaultdict(collections.Counter)
            for r, _ in mech:
                lim = "infeasible" if not B(r)["feasible"] else B(r)["chip_primary"]
                d[lim][r["meta"]["op"] + " / " + band3(r["meta"]["band"])] += 1
            sec["mechanics_decides_chip_b_by_limit_op_band"] = {k: dict(v) for k, v in d.items()}
            mach_cap = sum(1 for r in recs if B(r)["speed_decider"] == "machine")
            sec["machine_caps_speed_b"] = {"count": mach_cap, "pct": pct(mach_cap, len(recs))}
            mech_all = [r for r in recs if (not B(r)["feasible"]) or category(B(r)["chip_primary"]) == "mechanics"
                        or B(r)["speed_decider"] in ("machine", "C9")]
            sec["mechanics_or_machine_decides_any_b"] = {"count": len(mech_all), "pct": pct(len(mech_all), len(recs))}
            # chart as printed against the physics checks
            cchk = [(r, r["runs"][f"{mach}|{agg}|a"]["chart_check"]) for r in recs if "chart_check" in r["runs"][f"{mach}|{agg}|a"]]
            if cchk:
                n = len(cchk)
                anym = sum(1 for _, c in cchk if c["mech"])
                sec["chart_as_printed"] = {
                    "n": n, "violates_mechanics": {"count": anym, "pct": pct(anym, n)},
                    "violates_mechanics_or_unreachable": {"count": sum(1 for _, c in cchk if c["mech"] or not c["rpm_reachable"]),
                                                          "pct": pct(sum(1 for _, c in cchk if c["mech"] or not c["rpm_reachable"]), n)},
                    "violates_fitted_only": {"count": sum(1 for _, c in cchk if not c["mech"] and c["fitted"]),
                                             "pct": pct(sum(1 for _, c in cchk if not c["mech"] and c["fitted"]), n)},
                    "spindle_cannot_reach_chart_speed": {"count": sum(1 for _, c in cchk if not c["rpm_reachable"]),
                                                         "pct": pct(sum(1 for _, c in cchk if not c["rpm_reachable"]), n)},
                    "by_check": {k: sum(1 for _, c in cchk if k in c["violated"])
                                 for k in sorted({k for _, c in cchk for k in c["violated"]})},
                    "by_op": share_table([r for r, _ in cchk], lambda r: r["meta"]["op"],
                                         lambda r: bool(r["runs"][f"{mach}|{agg}|a"]["chart_check"]["mech"])),
                    "by_band": share_table([r for r, _ in cchk], lambda r: band3(r["meta"]["band"]),
                                           lambda r: bool(r["runs"][f"{mach}|{agg}|a"]["chart_check"]["mech"])),
                    "by_family": share_table([r for r, _ in cchk], lambda r: r["meta"]["family"],
                                             lambda r: bool(r["runs"][f"{mach}|{agg}|a"]["chart_check"]["mech"])),
                    "shipped_over_chart_feed_where_mech_violated": quantiles([
                        A(r)["feed"] / (r["chart"]["sfm_med"] * r["chart"]["fz_med"] * 12 / (math.pi * r["meta"]["D"]) * r["meta"]["flutes"])
                        for r, c in cchk if c["mech"]]),
                    "worst_overload": sorted(
                        [{"group": r["key"], "D": r["meta"]["D"], "violated": c["violated"]} for r, c in cchk if c["mech"]],
                        key=lambda x: -max([v for v in x["violated"].values() if v is not None] or [0]))[:15]}
            if (mach, agg) in (("test60k", 0.5), ("speedio", 0.5)):
                c_ok = [r for r in recs if ok_run(r["runs"], mach, agg, "c")]
                sec["mode_c"] = mode_c_summary(c_ok, mach, agg, "c")
                sec["mode_d"] = mode_c_summary([r for r in recs if ok_run(r["runs"], mach, agg, "d")], mach, agg, "d")
            out[f"{mach}|{agg}"] = sec
    return out


def machine_rpm(mach):
    return machine_max_rpm(profile(mach))


def mode_c_summary(recs, mach, agg, mode="c"):
    if not recs:
        return None
    A = lambda r: r["runs"][f"{mach}|{agg}|a"]
    B = lambda r: r["runs"][f"{mach}|{agg}|b"]
    Cc = lambda r: r["runs"][f"{mach}|{agg}|{mode}"]
    return {"n": len(recs),
            "c_over_b_sfm": quantiles([Cc(r)["sfm"] / B(r)["sfm"] for r in recs]),
            "c_over_b_fz": quantiles([Cc(r)["fz"] / B(r)["fz"] for r in recs]),
            "c_over_b_feed": quantiles([Cc(r)["feed"] / B(r)["feed"] for r in recs]),
            "c_speed_decider": dict(collections.Counter(Cc(r)["speed_decider"] for r in recs)),
            "c_chip_category": dict(collections.Counter("infeasible (mechanics)" if not Cc(r)["feasible"] else category(Cc(r)["chip_primary"])
                                                       for r in recs)),
            "c_chip_decider": dict(collections.Counter(Cc(r)["chip_decider"] for r in recs)),
            "b_chip_category": dict(collections.Counter("infeasible (mechanics)" if not B(r)["feasible"] else category(B(r)["chip_primary"])
                                                       for r in recs)),
            "c_feed_over_chart_median": quantiles([Cc(r)["sfm"] * Cc(r)["fz"] / (r["chart"]["sfm_med"] * r["chart"]["fz_med"]) for r in recs]),
            "c_fz_over_chart_max": quantiles([Cc(r)["fz"] / r["chart"]["fz_max"] for r in recs]),
            "c_sfm_over_chart_max": quantiles([Cc(r)["sfm"] / r["chart"]["sfm_max"] for r in recs]),
            "mechanics_still_binds_pct": pct(sum(1 for r in recs if (not Cc(r)["feasible"]) or category(Cc(r)["chip_primary"]) == "mechanics"), len(recs))}


# --------------------------------------------------------------------------------------------------------------------
# coverage
# --------------------------------------------------------------------------------------------------------------------

OWNER_FAMILIES = {"Titanium Alloy": "Ti-6Al-4V (Titanium Alloy)", "Stainless - PH Series (17-4)": "17-4 PH",
                  "Aluminum - Wrought (6061)": "7075 / 6061", "Steel - Medium Carbon Alloy (4130)": "4130",
                  "Steel - Tool (H13)": "tool steel (H13)"}


def coverage(fams, rows, scope):
    cells = collections.defaultdict(lambda: collections.defaultdict(int))
    for r in scope:
        cells[C.cell_of(r)][r["_vendor"]] += 1
    out_cells, hist = [], collections.Counter()
    for fam in sorted(fams):
        for op in C.OPERATIONS:
            for band, _, _ in C.BANDS:
                v = cells.get((fam, op, band), {})
                n = len(v)
                hist["0" if n == 0 else "1" if n == 1 else "2+"] += 1
                out_cells.append({"family": fam, "op": op, "band": band, "vendors": dict(v), "n_vendors": n, "rows": sum(v.values())})
    total = len(out_cells)
    by_fam = {}
    for fam in sorted(fams):
        cs = [c for c in out_cells if c["family"] == fam]
        by_fam[fam] = {"cells": len(cs), "none": sum(1 for c in cs if c["n_vendors"] == 0),
                       "one_vendor": sum(1 for c in cs if c["n_vendors"] == 1), "two_plus": sum(1 for c in cs if c["n_vendors"] >= 2)}
    by_op = {op: dict(collections.Counter("none" if c["n_vendors"] == 0 else "one" if c["n_vendors"] == 1 else "two_plus"
                                          for c in out_cells if c["op"] == op)) for op in C.OPERATIONS}
    by_band = {b: dict(collections.Counter("none" if c["n_vendors"] == 0 else "one" if c["n_vendors"] == 1 else "two_plus"
                                           for c in out_cells if c["band"] == b)) for b, _, _ in C.BANDS}
    owner = [c for c in out_cells if c["family"] in OWNER_FAMILIES and c["band"] in ("<=1/32", "1/32-1/16", "1/16-1/8", "1/8-1/4", "1/4-1/2")]
    uncovered = [c for c in owner if c["n_vendors"] <= 1]
    # rows of the other end forms / tools in the data
    forms = collections.Counter()
    for r in rows:
        t = r["tool"]
        forms[(C.end_form_of(r) if str(t.get("end", "")).lower() != "high_feed" else "high_feed", t.get("tool_material") or "?")] += 1
    return {"cells_total": total, "histogram_vendors": dict(hist),
            "pct": {k: pct(v, total) for k, v in hist.items()}, "by_family": by_fam, "by_op": by_op, "by_band": by_band,
            "owner_cells_total": len(owner), "owner_cells_uncovered_or_single": uncovered,
            "owner_none": sum(1 for c in owner if c["n_vendors"] == 0), "owner_one": sum(1 for c in owner if c["n_vendors"] == 1),
            "owner_two_plus": sum(1 for c in owner if c["n_vendors"] >= 2),
            "rows_by_form_and_material": {f"{k[0]}|{k[1]}": v for k, v in forms.items()}, "cells": out_cells}


# --------------------------------------------------------------------------------------------------------------------
# what the unnamed tool gets today
# --------------------------------------------------------------------------------------------------------------------

def unnamed_probe(groups, keys):
    """Same request with tool 'HP Carbide Endmill' vs 'Carbide Endmill' (the add-in's Tool Performance Grade) and with a
    brand: does the v2 result change?"""
    items = []
    for k in keys:
        rows = groups[k]
        for tool in ("HP Carbide Endmill", "Carbide Endmill"):
            items.append({"rows": rows, "var": {"machine": "speedio", "agg": 0.5, "mode": "a", "tool": tool, "key": gkey(k)}})
    outs = pool_map(items)
    by = collections.defaultdict(dict)
    for o in outs:
        by[o["var"]["key"]][o["var"]["tool"]] = o
    res = []
    for k, d in by.items():
        a, b = d.get("HP Carbide Endmill"), d.get("Carbide Endmill")
        if not a or not b or "error" in a or "error" in b:
            continue
        res.append({"group": k, "hp": {x: a[x] for x in ("sfm", "fz", "feed", "mrr", "binding")},
                    "std": {x: b[x] for x in ("sfm", "fz", "feed", "mrr", "binding")},
                    "identical": all(a[x] == b[x] for x in ("sfm", "fz", "feed", "mrr", "rpm")),
                    "basis": a["basis"], "sfm_range": a["sfm_range"], "fz_range": a["fz_range"]})
    return res


def haas_probe():
    """What brand "Haas" resolves to today and what a Haas -> YG-1 mapping would change (1/8" and 1/16" 4-flute, 17-4 and Ti,
    Speedio, 50 %, runout 0.0002", stickout = flute length + 1/4")."""
    from toolwiz_common import brand as brand_mod
    prof = profile("speedio")
    out = {"resolve_Haas": brand_mod.resolve("Haas"), "resolve_Haas_Automation": brand_mod.resolve("Haas Automation"),
           "from_sources_Haas": list(brand_mod.from_sources("Haas", None)), "cases": []}
    real = app.physics.resolve_alloy_hardness
    try:
        for fam in ("Stainless - PH Series (17-4)", "Titanium Alloy"):
            app.physics.resolve_alloy_hardness = lambda f, a: 330.0
            for D, lcf in ((0.125, 0.375), (0.0625, 0.1875)):
                for op in ("Slotting", "Adaptive Roughing"):
                    case = {"family": fam, "D": D, "operation": op}
                    for label, b in (("as_shipped_Haas", "Haas"), ("yg1", "yg1")):
                        req = pipeline.CutRequest(
                            family=fam, alloy="x", tool="Carbide Endmill", coating="AlTiN", geometry="Square", operation=op,
                            diameter=D, flutes=4, flute_length=lcf, shank_diameter=max(D, 0.125), stickout=lcf + 0.25,
                            helix_angle=35, aggressiveness=0.5, max_rpm=16000, max_hp=6.8, runout=0.0002, model="v2",
                            machine_profile=prof, brand=b)
                        with patched("a"):
                            res = run_cut(app.physics, req)
                        vb = res.vendor_basis or {}
                        case[label] = {"sfm": round(res.sfm), "rpm": round(res.rpm), "fz": round(res.adj_ipt, 5),
                                       "feed": round(res.feed_ipm, 1), "ap": round(res.rec_doc, 4), "ae": round(res.rec_woc, 4),
                                       "mrr": round(res.rec_doc * res.rec_woc * res.feed_ipm, 4),
                                       "basis": {k: vb.get(k) for k in ("mode", "vendor", "chart_class", "rows")},
                                       "sfm_range": vb.get("sfm_range"), "fz_range": vb.get("fz_range"), "limited_by": res.limited_by}
                    case["mrr_ratio_yg1_over_shipped"] = round(case["yg1"]["mrr"] / case["as_shipped_Haas"]["mrr"], 2)
                    out["cases"].append(case)
    finally:
        app.physics.resolve_alloy_hardness = real
    return out


# --------------------------------------------------------------------------------------------------------------------
# main
# --------------------------------------------------------------------------------------------------------------------

def build_jobs(groups, keys, second):
    jobs = []
    for k in keys:
        rows = groups[k]
        chart = chart_stats(rows)
        for mach in MACHINES:
            for agg in (0.5, 0.0, 1.0):
                for mode in ("a", "b") + (("c", "d") if agg == 0.5 else ()):
                    var = {"gid": gkey(k), "machine": mach, "agg": agg, "mode": mode, "pass": "main"}
                    if mode == "a":
                        var["chart"] = chart
                    jobs.append({"rows": rows, "var": var})
    for k in second:
        rows = groups[k]
        chart = chart_stats(rows)
        for mach in MACHINES:
            for sk in (None,) + STICK_K:
                for tir in TIRS:
                    if sk is None and tir == MACHINES[mach][1]:
                        continue   # the main pass has it
                    var = {"gid": gkey(k), "machine": mach, "agg": 0.5, "mode": "a", "stick_k": sk, "tir": tir,
                           "pass": "second", "chart": chart}
                    jobs.append({"rows": rows, "var": var})
        for mach in MACHINES:
            for name, wi, agg in (("trs-20%", {"trs": 0.8}, 0.5), ("edge x1.5", {"edge": 1.5}, 0.5), ("edge x2", {"edge": 2.0}, 0.5),
                                  ("runout 0.0004", None, 0.5), ("slider 25%", None, 0.25),
                                  ("import: trs-20%, edge x1.5, runout 0.0004, slider 25%", {"trs": 0.8, "edge": 1.5}, 0.25)):
                var = {"gid": gkey(k), "machine": mach, "agg": agg, "mode": "a", "pass": "whatif", "name": name, "whatif": wi,
                       "chart": chart}
                if name.startswith("runout") or name.startswith("import"):
                    var["tir"] = 0.0004
                jobs.append({"rows": rows, "var": var})
    return jobs


def second_pass_summary(records, second_keys):
    """Per machine x stickout x runout: shipped change versus the baseline and chart-only violations."""
    sec = {}
    for r in records:
        if r["key"] not in second_keys:
            continue
    rows = []
    for r in records:
        if r["key"] not in second_keys:
            continue
        for mach in MACHINES:
            base = ok_run(r["runs"], mach, 0.5, "a")
            if not base:
                continue
            for sk in (None,) + STICK_K:
                for tir in TIRS:
                    run = base if (sk is None and tir == MACHINES[mach][1]) else r["runs"].get(f"{mach}|stick{sk}|tir{tir}")
                    if not run or "error" in run:
                        continue
                    cc = run.get("chart_check") or {}
                    rows.append({"group": r["key"], "machine": mach, "stick_k": sk, "tir": tir, "sfm": run["sfm"], "fz": run["fz"],
                                 "feed": run["feed"], "mrr": run["mrr"], "feasible": run["feasible"], "binding": run["binding"],
                                 "flutes_cutting": run["flutes_cutting"], "z": run["z"], "speed_by": run["speed_decider"], "chip_by": run["chip_decider"],
                                 "chart_violated": cc.get("violated"), "chart_mech": cc.get("mech"), "chart_reachable": cc.get("rpm_reachable"),
                                 "vs_base_feed": round(run["feed"] / base["feed"], 3) if base["feed"] else None,
                                 "vs_base_mrr": round(run["mrr"] / base["mrr"], 3) if base["mrr"] else None,
                                 "vs_base_fz": round(run["fz"] / base["fz"], 3), "vs_base_sfm": round(run["sfm"] / base["sfm"], 3)})
    cells = collections.defaultdict(list)
    for x in rows:
        cells[(x["machine"], x["stick_k"], x["tir"])].append(x)
    table = []
    for (mach, sk, tir), v in sorted(cells.items(), key=lambda kv: (kv[0][0], kv[0][1] or 0, kv[0][2])):
        n = len(v)
        cnt = collections.Counter(k for x in v for k in (x["chart_violated"] or {}))
        table.append({"machine": mach, "stick_k": sk, "tir": tir, "n": n,
                      "median_mrr_vs_base": round(statistics.median(x["vs_base_mrr"] for x in v if x["vs_base_mrr"] is not None), 3),
                      "median_fz_vs_base": round(statistics.median(x["vs_base_fz"] for x in v), 3),
                      "median_sfm_vs_base": round(statistics.median(x["vs_base_sfm"] for x in v), 3),
                      "p10_mrr_vs_base": quantiles([x["vs_base_mrr"] for x in v])["p10"],
                      "infeasible": sum(1 for x in v if not x["feasible"]),
                      "all_flutes_cutting_pct": pct(sum(1 for x in v if x["flutes_cutting"] is not None and x["flutes_cutting"] >= x["z"]), n),
                      "chart_violates_mech": sum(1 for x in v if x["chart_mech"]),
                      "chart_violates_by_check": {k: cnt[k] for k in sorted(cnt)},
                      "chart_speed_unreachable": sum(1 for x in v if x["chart_reachable"] is False)})
    return {"rows": rows, "table": table}


def whatif_summary(records, second_keys):
    out = {}
    for mach in MACHINES:
        names = sorted({k.split("|", 2)[2] for r in records for k in r["runs"] if k.startswith(f"{mach}|whatif|")})
        for name in names:
            vals = []
            for r in records:
                if r["key"] not in second_keys:
                    continue
                base = ok_run(r["runs"], mach, 0.5, "a")
                w = r["runs"].get(f"{mach}|whatif|{name}")
                if base and w and "error" not in w:
                    vals.append({"feed": w["feed"] / base["feed"], "mrr": w["mrr"] / base["mrr"], "fz": w["fz"] / base["fz"],
                                 "sfm": w["sfm"] / base["sfm"], "chip_by": w["chip_decider"], "infeasible": not w["feasible"]})
            if vals:
                out[f"{mach}|{name}"] = {"n": len(vals), "mrr_ratio": quantiles([v["mrr"] for v in vals]),
                                         "fz_ratio": quantiles([v["fz"] for v in vals]), "sfm_ratio": quantiles([v["sfm"] for v in vals]),
                                         "infeasible": sum(v["infeasible"] for v in vals),
                                         "chip_decider": dict(collections.Counter(v["chip_by"] for v in vals))}
    return out


COMPACT_FIELDS = ["sfm", "fz", "feed", "speed_decider", "chip_decider"]


def slim_result(result):
    """Keep the JSON near 1 MB: the shipped runs (mode a, 50 %) keep their detail, every other main-pass run is a short list
    (COMPACT_FIELDS), and the second-pass / what-if runs live only in `second_pass` and `whatif` (their per-group runs are dropped)."""
    for g in result["groups"]:
        runs = {}
        for name, run in g["runs"].items():
            parts = name.split("|")
            if parts[1].startswith(("stick", "whatif")):
                continue
            if "error" in run:
                runs[name] = run
            elif parts[2] == "a" and parts[1] == "0.5":
                cc = run.get("chart_check")
                runs[name] = {k: run[k] for k in ("sfm", "rpm", "fz", "ap", "ae", "feed", "mrr", "feasible", "binding", "speed_decider",
                                                  "chip_decider", "chip_primary", "chip_vendor_binds", "sfm_range", "fz_range")
                              } | {"basis": {k: (run.get("basis") or {}).get(k) for k in ("mode", "vendor", "chart_class")}}
                if cc:
                    runs[name]["chart_check"] = {k: cc[k] for k in ("rpm_reachable", "violated")}
            else:
                runs[name] = [run[k] for k in COMPACT_FIELDS]
        g["runs"] = runs
    for r in result["second_pass"]["rows"]:
        for k in ("binding", "chip_by", "speed_by", "flutes_cutting", "z", "feasible", "feed", "sfm", "fz", "mrr"):
            r.pop(k, None)
        r["chart_violated"] = sorted((r.pop("chart_violated", None) or {}))
    result["meta"]["runs_compact_fields"] = COMPACT_FIELDS
    for name, sec in result["aggregate"].items():
        if not name.endswith("|0.5"):
            for k in [k for k in sec if k.startswith("worst_")]:
                del sec[k]
    return result


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--quick", action="store_true", help="sample a handful of groups (fast run, for the test)")
    ap.add_argument("--out", default=OUT_DEFAULT)
    ap.add_argument("--extras", action="store_true", help="only recompute the Haas probe inside an existing --out file")
    ap.add_argument("--sample", type=int, default=8, help="groups sampled by --quick")
    args = ap.parse_args(argv)
    t0 = time.time()
    if args.extras:
        with open(args.out, encoding="utf-8") as fh:
            res = json.load(fh)
        res["haas_probe"] = haas_probe()
        with open(args.out, "w", encoding="utf-8") as fh:
            json.dump(res, fh, separators=(",", ":"))
        return res
    fams, rows, scope, groups = load_groups()
    keys = sorted(groups)
    second = pick_second_pass(groups)
    if args.quick:
        step = max(1, len(keys) // args.sample)
        keys = keys[::step][:args.sample]
        second = [k for k in second[::5][:2] if k in groups]
        keys = sorted(set(keys) | set(second))
    jobs = build_jobs(groups, keys, second)
    print(f"{len(keys)} groups, {len(jobs)} engine runs", file=sys.stderr)
    outs = pool_map(jobs)
    recs = {}
    errors = []
    for k in keys:
        rws = groups[k]
        g = C.median_tool(rws)
        recs[gkey(k)] = {"key": gkey(k), "meta": {"family": k[0], "op": k[1], "band": k[2], "eng": k[3], "n": len(rws), "D": g["D"],
                                                 "flutes": g["flutes"], "stick": g["stick"], "lcf": g["lcf"], "hb": g["hb"],
                                                 "vendors": sorted({r["_vendor"] for r in rws})},
                         "chart": chart_stats(rws), "runs": {}}
    for o in outs:
        v = o["var"]
        if "error" in o:
            errors.append({"group": v["gid"], "var": {x: v.get(x) for x in ("machine", "agg", "mode", "pass")}, "error": o["error"]})
            continue
        if v["pass"] == "main":
            name = f"{v['machine']}|{v['agg']}|{v['mode']}"
        elif v["pass"] == "second":
            name = f"{v['machine']}|stick{v.get('stick_k')}|tir{v['tir']}"
        else:
            name = f"{v['machine']}|whatif|{v['name']}"
        o = {k: x for k, x in o.items() if k != "var"}
        recs[v["gid"]]["runs"][name] = o
    records = list(recs.values())
    second_keys = {gkey(k) for k in second}
    agg = aggregate(records)
    sp = second_pass_summary(records, second_keys)
    wi = whatif_summary(records, second_keys)
    probe_keys = [k for k in (second[:6] if second else keys[:3])]
    probe = unnamed_probe(groups, probe_keys)
    cov = coverage(fams, rows, scope)
    # compact per-run records: drop the heavy chart check of non-main passes from the JSON? keep (small)
    result = {"meta": {"generated": time.strftime("%Y-%m-%d %H:%M:%S"), "quick": bool(args.quick), "groups": len(keys),
                       "engine_runs": len(jobs), "errors": len(errors), "relax_factor_mode_c": RELAX, "tol": TOL,
                       "machines": {m: {"profile": os.path.relpath(MACHINES[m][0], ROOT), "runout_in": MACHINES[m][1],
                                        "max_rpm": machine_rpm(m)} for m in MACHINES},
                       "aggressiveness": [0.5, 0.0, 1.0], "second_pass_groups": [gkey(k) for k in second],
                       "runtime_s": round(time.time() - t0, 1)},
              "aggregate": agg, "second_pass": {"table": sp["table"], "rows": sp["rows"]}, "whatif": wi, "unnamed_probe": probe, "haas_probe": haas_probe(),
              "coverage": cov, "errors": errors[:50], "groups": records}
    slim_result(result)
    os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
    with open(args.out, "w", encoding="utf-8") as fh:
        json.dump(result, fh, separators=(",", ":"))
    print(f"wrote {args.out} ({os.path.getsize(args.out) / 1e6:.2f} MB) in {time.time() - t0:.0f} s; {len(errors)} failed runs",
          file=sys.stderr)
    return result


if __name__ == "__main__":
    main()
