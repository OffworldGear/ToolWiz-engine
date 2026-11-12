"""Slot roughing decision study: high-feed vs square vs bull-nose slotting vs HEM with a smaller tool.

Regenerates the tables of docs/SLOT_ROUGHING_STUDY.md (between the GENERATED markers) and
data/studies/slot_roughing_study.json from the cited vendor rows (tests/benchmarks/v2/*.json) and the engine
(pipeline.run_cut, model v2, Speedio 16k profile, runout default rule; strategy_planner.compare for HEM).

Feature: a closed contour slot exactly one tool diameter wide, perimeter 4.2", four corners, depths 0.050/0.150/0.300".
For every option two sets of numbers: "vendor chart" (a cited row: rpm = SFM·12/(π·D) capped at the spindle, feed =
rpm·z·fz, levels = ceil(depth / ap)) and "ToolWiz" (the engine's result and its limiting checks). Both are timed with the
same cycle-time model (cutting + ramp entry per level + corner stops), see `slot_time` / `hem_time` and DYNAMICS.

    python3 tools/slot_roughing_study.py               # full study: JSON + doc tables
    python3 tools/slot_roughing_study.py --quick       # Ti, 1/8", 50 % only, prints a table (for tests)
"""
import argparse
import collections
import glob
import json
import math
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)
sys.path.insert(0, os.path.join(ROOT, "tools"))

import v2_provisional_limits as pl  # noqa: E402

DOC = os.path.join(ROOT, "docs", "SLOT_ROUGHING_STUDY.md")
OUT_JSON = os.path.join(ROOT, "data", "studies", "slot_roughing_study.json")
PROFILE = os.path.join(ROOT, "machines", "speedio_s500x2.json")
BENCH = os.path.join(ROOT, "tests", "benchmarks", "v2")
BEGIN, END = "<!-- BEGIN GENERATED (tools/slot_roughing_study.py) -->", "<!-- END GENERATED -->"

PERIMETER_IN = 4.2
CORNERS = 4
DEPTHS = (0.050, 0.150, 0.300)
DIAMETERS = (0.125, 0.0625)
AGGRESSIVENESS = (0.0, 0.5, 1.0)
HEM_TOOL = {0.125: 0.0625, 0.0625: 0.03125}   # next size down that leaves room for a trochoid
MATERIALS = {
    "Ti-6Al-4V": {"family": "Titanium Alloy", "alloy": "", "hf": True,
                  "note": "no alloy given: the engine's Ti-6Al-4V hardness 330 HB (about 35 HRC, annealed)"},
    "17-4 PH": {"family": "Stainless - PH Series (17-4)", "alloy": "17-4 PH", "hf": True,
                "note": "alloy '17-4 PH' resolves to the material database's 420 HB (about 44 HRC, H900-class)"},
    "6061": {"family": "Aluminum - Wrought (6061)", "alloy": "6061-T6", "hf": False,
             "note": "6061-T6, 95 HB; standard tools only (no high-feed chart in aluminium in the dataset)"},
}
# Machine dynamics. The profile (machines/speedio_s500x2.json) gives rapid 50 m/min and max cutting feed 30 m/min but no
# acceleration; these are ASSUMPTIONS for a Speedio-class machine (fast BT30 tapping centre) under contouring look-ahead.
DYNAMICS = {
    "nominal": {"accel_g": 0.5, "corner_settle_s": 0.005,
                "basis": "ASSUMED: 0.5 g cutting-feed acceleration (Speedio-class rapid axes are faster; contouring with "
                         "look-ahead / smoothing is slower than rapid), 5 ms settle per corner"},
    "pessimistic": {"accel_g": 0.2, "corner_settle_s": 0.030,
                    "basis": "ASSUMED: 0.2 g and 30 ms per corner (high-accuracy mode, conservative)"},
}
G_IN_S2 = 386.09
HF_RAMP_FEED_FRACTION = 0.5    # physics_v2.highfeed.RAMP_FEED_FRACTION
DEFAULT_RAMP_DEG = 3.0         # when a tool's ramp angle is not known (vendor rows publish none)


# ---------------------------------------------------------------------------------------------------------------------
# machine
# ---------------------------------------------------------------------------------------------------------------------

def machine():
    with open(PROFILE, encoding="utf-8") as fh:
        prof = json.load(fh)
    sp = prof["spindle_options"][prof["active_spindle"]]
    rapid = prof["rapid_m_min"]
    return {"profile": prof, "max_rpm": float(sp["max_rpm"]), "max_hp": float(sp["power_kw_continuous"]) * 1.341,
            "max_feed_ipm": prof["max_cutting_feed_mm_min"] / 25.4,
            "rapid_ipm": min(rapid["x"], rapid["y"]) * 1000.0 / 25.4,
            "label": f"{prof['machine']} {sp['label']} ({prof['spindle_taper']})"}


# ---------------------------------------------------------------------------------------------------------------------
# cycle-time model (shared by vendor-chart and ToolWiz numbers)
# ---------------------------------------------------------------------------------------------------------------------

def chart_feed(sfm, D, z, fz, max_rpm, max_feed_ipm=1e9):
    """(rpm, feed IPM, spindle_limited) of a vendor chart row on this machine: rpm = SFM·12/(π·D) capped at max_rpm,
    feed = rpm·z·fz (capped at the machine's max cutting feed)."""
    rpm_want = sfm * 12.0 / (math.pi * D)
    rpm = min(rpm_want, max_rpm)
    return rpm, min(rpm * z * fz, max_feed_ipm), rpm_want > max_rpm * 1.0001


def corner_loss_s(feed_ipm, dyn):
    """Time lost at one stop-and-go corner (s): decelerate to 0 and back to the feed, v/a, plus the settle allowance."""
    v = feed_ipm / 60.0
    return v / (dyn["accel_g"] * G_IN_S2) + dyn["corner_settle_s"]


def slot_time(depth, ap, feed, ramp_deg, ramp_frac, dyn, perimeter=PERIMETER_IN, corners=CORNERS, rapid_ipm=1968.5):
    """Minutes for a closed contour slot: levels = ceil(depth / ap) of equal depth; per level one ramp entry along the
    contour (horizontal run ap_eff / tan(angle) at ramp_frac x feed, then a full lap at depth: the ramp's wedge is cleared
    by the lap) and `corners` stop-and-go corners; plus one approach and retract at rapid.
    `cut` = levels x perimeter / feed (the pure chart arithmetic)."""
    levels = max(1, math.ceil(depth / ap - 1e-9))
    ap_eff = depth / levels
    run = ap_eff / math.tan(math.radians(ramp_deg))
    cut = levels * perimeter / feed
    ramp = levels * run / (ramp_frac * feed)
    corner = levels * corners * corner_loss_s(feed, dyn) / 60.0
    pos = 2.0 * 0.1 / rapid_ipm
    return {"levels": levels, "ap_eff": ap_eff, "cut_min": cut, "ramp_min": ramp, "corner_min": corner,
            "total_min": cut + ramp + corner + pos, "ramp_run_in": run}


def hem_time(depth, ap, ae, feed, w_channel, D, dyn, max_feed_ipm, ramp_deg=DEFAULT_RAMP_DEG, ramp_frac=0.5,
             perimeter=PERIMETER_IN, finish_min=0.0):
    """Minutes for adaptive (trochoidal) clearing of a channel w_channel wide with a D tool, the planner's path model
    (strategy_planner._adaptive_geometry: loops = path / ae, cutting arc max(π·r + ae, W) per loop at the feed, return
    arc π·r at the link feed 2 x feed capped at the machine), with the loop speed capped by the assumed acceleration on
    the loop radius (v ≤ sqrt(a·r)), one ramp per level, plus `finish_min` for the wall finishing pass."""
    import strategy_planner as sp
    levels = max(1, math.ceil(depth / ap - 1e-9))
    ap_eff = depth / levels
    geo = sp._adaptive_geometry(w_channel, D, ae)
    r = max(geo["radius"], 1e-6)
    v_cap = math.sqrt(dyn["accel_g"] * G_IN_S2 * r) * 60.0   # IPM
    f_cut = min(feed, v_cap)
    f_link = min(sp.LINK_FEED_FACTOR * feed, max_feed_ipm, v_cap)
    loops = perimeter / ae
    cut = levels * loops * geo["cut_per_loop"] / f_cut
    link = levels * loops * geo["return_per_loop"] / f_link
    run = ap_eff / math.tan(math.radians(ramp_deg))
    ramp = levels * run / (ramp_frac * feed)
    return {"levels": levels, "ap_eff": ap_eff, "cut_min": cut, "link_min": link, "ramp_min": ramp,
            "finish_min": finish_min, "total_min": cut + link + ramp + finish_min, "loop_radius_in": r,
            "loop_speed_cap_ipm": v_cap, "loops_per_level": loops, "accel_limited": feed > v_cap}


# ---------------------------------------------------------------------------------------------------------------------
# vendor rows
# ---------------------------------------------------------------------------------------------------------------------

def load_rows():
    out = []
    for path in sorted(glob.glob(os.path.join(BENCH, "*.json"))):
        stem = os.path.basename(path)[:-5]
        key = {"harvey_ball_cr": "harvey", "osg_ball": "osg"}.get(stem) or stem.replace("highfeed_", "")
        with open(path, encoding="utf-8") as fh:
            d = json.load(fh)
        for r in d["rows"]:
            out.append(dict(r, _vendor=key, _group=d["vendor_group"], _file=stem))
    return out


def end_class(row):
    t = row["tool"]
    end = pl.end_of(row) if t.get("end") != "high_feed" else "high_feed"
    if end == "high_feed":
        return "hf"
    if end == "ball":
        return "ball"
    cr = float(t.get("corner_radius") or 0.0)
    return "bull" if cr >= 0.01 * float(t["DC"]) else "square"


def hb_range(row, family):
    """(lo, hi) Brinell of a row's hardness class, or None."""
    import calibrate_v2 as cv
    h = row["material"].get("hardness") or {}
    if not h.get("scale"):
        return None
    lo = cv.row_hb({"min": h.get("min"), "max": None, "scale": h["scale"]}) if h.get("min") is not None else None
    hi = cv.row_hb({"min": None, "max": h.get("max"), "scale": h["scale"]}) if h.get("max") is not None else None
    if lo is None and hi is None:
        return None
    return (lo if lo is not None else 0.0, hi if hi is not None else 1e9)


def nominal(block):
    if not block:
        return None
    if block.get("nominal") is not None:
        return float(block["nominal"])
    vals = [v for v in (block.get("min"), block.get("max")) if v is not None]
    return sum(vals) / len(vals) if vals else None


def chart_rows(rows, family, hb, D, cls, z=None, op="slot"):
    """Cited rows of a material family, operation, diameter (±6 %), end class and flute count, in the hardness class that
    contains hb (else the nearest class; rows with no hardness are kept)."""
    sel = [r for r in rows if r["material"].get("toolwiz_family") == family and r["operation"] == op
           and r["tool"].get("DC") and abs(float(r["tool"]["DC"]) - D) <= 0.06 * D and end_class(r) == cls
           and (z is None or int(r["tool"].get("flutes") or 0) == z) and r["tool"].get("tool_material", "carbide") == "carbide"
           and nominal(r["cut"].get("sfm")) and nominal(r["cut"].get("fz")) and r["cut"].get("ap")]
    by = collections.defaultdict(list)
    for r in sel:
        by[(r["_vendor"], r["tool"].get("series") or r["tool"].get("part_number"))].append(r)
    out = []
    for rs in by.values():
        def dist(r):
            rng = hb_range(r, family)
            if rng is None:
                return 0.0
            lo, hi = rng
            return 0.0 if lo <= hb <= hi else min(abs(hb - lo), abs(hb - hi))
        best = min(dist(r) for r in rs)
        out += [r for r in rs if dist(r) == best]
    return out


def chart_option(row, D, depth, mach, dyn, ramp_deg, ramp_frac, ae_over_D=1.0):
    t, c = row["tool"], row["cut"]
    z = int(t["flutes"])
    sfm, fz = nominal(c["sfm"]), nominal(c["fz"])
    ap = float(c["ap"])
    rpm, feed, limited = chart_feed(sfm, float(t["DC"]), z, fz, mach["max_rpm"], mach["max_feed_ipm"])
    tm = slot_time(depth, ap, feed, ramp_deg, ramp_frac, dyn, rapid_ipm=mach["rapid_ipm"])
    return {"source": f"{row['_vendor']} {row['source']['doc_id']} p.{row['source'].get('page')}: "
                      f"{row['source'].get('row_label')} / {row['source'].get('column_label')}",
            "row_id": row["id"], "vendor": row["_vendor"], "series": t.get("series") or t.get("part_number"),
            "D": float(t["DC"]), "z": z, "corner_radius": t.get("corner_radius"), "sfm": sfm, "fz": fz, "ap": ap,
            "rpm": rpm, "feed_ipm": feed, "spindle_limited": limited,
            "sfm_on_machine": math.pi * float(t["DC"]) * rpm / 12.0, **tm}


# ---------------------------------------------------------------------------------------------------------------------
# engine
# ---------------------------------------------------------------------------------------------------------------------

_PHYS = None


def physics():
    global _PHYS
    if _PHYS is None:
        import app
        _PHYS = app.physics
    return _PHYS


def toolwiz(mat, D, z, geometry, agg, mach, brand=None, corner=0.0, max_ap=None, op="Slotting", stickout=None,
            runout=None):
    """pipeline.run_cut on the Speedio profile, model v2, runout default rule (runout None)."""
    from pipeline import CutRequest, run_cut
    lcf = max_ap if geometry == "High Feed" and max_ap else 3.0 * D
    shank = 0.25 if geometry == "High Feed" else max(D, 0.125)
    req = CutRequest(family=mat["family"], alloy=mat["alloy"], tool="Carbide Endmill", geometry=geometry, operation=op,
                     coating="AlTiN", diameter=D, flutes=z, flute_length=lcf if geometry == "High Feed" else 3.0 * D,
                     shank_diameter=shank, stickout=stickout or 4.0 * D, aggressiveness=agg, max_rpm=mach["max_rpm"],
                     max_hp=mach["max_hp"], runout=runout, corner_radius=corner, max_ap=max_ap, model="v2", brand=brand,
                     machine_profile=mach["profile"])
    return run_cut(physics(), req)


def model_estimates(mat, D, z, geometry, corner, max_ap, ap, ae, fz, rpm, agg, tir, op="slot", stickout=None):
    """Engine model at a given cut (ToolWiz's or a vendor chart's): loads, deflection, power per edge, the checks a chart
    cut would fail, and the Taylor wear index (in-cut time / relative life at the C7 level of this tool class)."""
    from physics_v2 import highfeed, params
    from physics_v2 import optimize as o
    hb = physics().resolve_alloy_hardness(mat["family"], mat["alloy"]) if mat["alloy"] else None
    m = params.material(mat["family"], hb)
    hf = highfeed.resolve(D, max_ap, None, corner or None) if geometry == "High Feed" else None
    tool = o.Tool.build(D, z, max_ap if hf else 3.0 * D, stickout or 4.0 * D, shank=0.25 if hf else max(D, 0.125),
                        corner_radius_in=0.0 if hf else (corner or 0.0), high_feed=hf)
    rep = o.evaluate_cut(tool, m, params.machine(tir), op, ap, ae, fz, rpm=rpm, aggressiveness=agg, n_theta=180,
                         n_quad=32, chip_space=None)
    loads = rep["loads"]
    phi = o.forces.engagement_angle(min(ae, D) * 25.4, D * 25.4)
    v_life = o.taylor_speed_m_min(m, phi, 1.0, D * 25.4, o.consensus_scale(0.5), op,
                                  "high_feed" if hf else None) * o.FT_PER_M
    sfm = math.pi * D * rpm / 12.0
    life = min((v_life / sfm) ** (1.0 / m.taylor_n), 10.0)
    edge_len_mm = (ap / hf.sin_kappa if hf else ap) * 25.4
    return {"lateral_peak_n": loads["lateral_peak_n"], "deflection_in": loads["deflection_tip_in"],
            "axial_peak_n": loads.get("axial_peak_n"), "power_w": loads["power_w"],
            "power_per_edge_w": loads["power_w"] / z, "power_per_mm_edge_w": loads["power_w"] / z / max(edge_len_mm, 1e-6),
            "violated": rep["violated"], "life_ratio": life, "v_life_sfm": v_life, "taylor_n": m.taylor_n}


def tw_option(res, D, z, depth, dyn, mach, hf=False):
    ramp_deg = res.ramp_angle or DEFAULT_RAMP_DEG
    frac = (res.ramp_feed / res.feed_ipm) if (res.ramp_feed and res.feed_ipm) else 0.5
    ap = res.rec_doc if res.rec_doc and res.rec_doc > 0 else res.doc
    tm = slot_time(depth, ap, res.feed_ipm, ramp_deg, frac, dyn, rapid_ipm=mach["rapid_ipm"])
    vb = res.vendor_basis or {}
    hfo = (res.v2 or {}).get("high_feed") or {}
    return {"rpm": res.rpm, "sfm": res.sfm, "fz": res.adj_ipt, "feed_ipm": res.feed_ipm, "ap": ap, "z": z, "D": D,
            "feasible": bool(res.feasible), "limited_by": res.limited_by, "ramp_deg": ramp_deg, "ramp_frac": frac,
            "spindle_limited": bool(res.rpm >= mach["max_rpm"] * 0.999),
            "spindle_sentence": (hfo.get("spindle_limited") or {}).get("sentence"),
            "vendor_basis": {k: vb.get(k) for k in ("mode", "vendor", "chart_class", "rows", "sfm_range", "fz_range", "note")},
            "runout_in": res.runout_in, "stock_radial_in": res.recommended_radial_stock_in, **tm}


# ---------------------------------------------------------------------------------------------------------------------
# the study
# ---------------------------------------------------------------------------------------------------------------------

HF_BRANDS = (("Harvey", "harvey"), ("Helical", "helical"), ("Niagara SN400R", "seco"))
STD_FLUTES = (2, 3, 4)


def pick(rows_opts, key="total_min"):
    return min(rows_opts, key=lambda x: x[key]) if rows_opts else None


def median_pick(opts, key="total_min"):
    if not opts:
        return None
    s = sorted(opts, key=lambda x: x[key])
    return s[(len(s) - 1) // 2]


def study_case(mat_name, D, aggs, depths, mach, dyn, rows, with_estimates=True):
    """Every option for one material and slot width D: vendor chart and ToolWiz, per depth and aggressiveness."""
    mat = MATERIALS[mat_name]
    hb = physics().resolve_alloy_hardness(mat["family"], mat["alloy"]) if mat["alloy"] else None
    if hb is None:
        from physics_v2 import params
        hb = params.material(mat["family"]).hb
    options = []

    def add(name, kind, tool, chart, tw_by_agg, notes):
        options.append({"name": name, "kind": kind, "tool": tool, "chart": chart, "toolwiz": tw_by_agg, "notes": notes})

    def chart_for(cands, depth, ramp_deg, ramp_frac, how="median"):
        opts = [chart_option(r, D, depth, mach, dyn, ramp_deg, ramp_frac) for r in cands]
        return (median_pick if how == "median" else pick)(opts)

    # 1. high-feed
    if mat["hf"]:
        for label, key in HF_BRANDS + (("unbranded", None),):
            cands = [r for r in chart_rows(rows, mat["family"], hb, D, "hf") if r["_vendor"] == key] if key else []
            geo_row = cands[0]["tool"] if cands else None
            rp = (geo_row or {}).get("programming_radius")
            apmx = (geo_row or {}).get("apmx")
            z = int(geo_row["flutes"]) if geo_row else 4
            notes = []
            if key and not cands:
                any_size = sorted({float(r["tool"]["DC"]) for r in rows if r["_vendor"] == key and end_class(r) == "hf"
                                   and r["material"].get("toolwiz_family") == mat["family"]})
                notes.append(f"no {label} high-feed chart row at {D:g}\" in this material (charted diameters: "
                             f"{', '.join(f'{x:g}' for x in any_size) or 'none'})")
                add(f"high-feed {label}", "hf", {"D": D, "z": None}, None, {}, notes)
                continue
            tw = {}
            for a in aggs:
                res = toolwiz(mat, D, z, "High Feed", a, mach, brand=(label.split()[0] if key else None),
                              corner=rp or 0.0, max_ap=apmx, stickout=3.0 * D)
                tw[a] = {dep: tw_option(res, D, z, dep, dyn, mach, hf=True) for dep in depths}
                if a == 0.5 and with_estimates:
                    t0 = tw[a][depths[0]]
                    tw[a]["estimates"] = model_estimates(mat, D, z, "High Feed", rp, apmx or ((res.v2 or {}).get("high_feed") or {}).get("max_ap_in"),
                                                         t0["ap"], D, t0["fz"], t0["rpm"], a, res.runout_in, stickout=3.0 * D)
            hfo = ((res.v2 or {}).get("high_feed") or {})
            ramp_deg = hfo and min(math.degrees(math.atan(hfo["max_ap_in"] / D)), 3.0) or DEFAULT_RAMP_DEG
            chart = {dep: chart_for(cands, dep, ramp_deg, HF_RAMP_FEED_FRACTION) for dep in depths} if cands else None
            if chart and with_estimates:
                c0 = chart[depths[0]]
                chart["estimates"] = model_estimates(mat, D, z, "High Feed", rp, apmx or hfo.get("max_ap_in"), min(c0["ap"], hfo.get("max_ap_in") or c0["ap"]),
                                                     D, c0["fz"], c0["rpm"], 0.5, res.runout_in, stickout=3.0 * D)
            if not key:
                notes.append("generic high-feed geometry: lead angle and max ap assumed by the engine (15 deg, 0.06 x D)")
            if hfo.get("assumed"):
                notes.append("engine assumed: " + ", ".join(hfo["assumed"]))
            add(f"high-feed {label}", "hf", {"D": D, "z": z, "programming_radius": rp, "apmx": apmx}, chart, tw, notes)

    # 2./3. square and bull-nose
    for cls, geometry in (("square", "Square"), ("bull", "Radiused")):
        for z in STD_FLUTES:
            cands = chart_rows(rows, mat["family"], hb, D, cls, z)
            by_vendor = collections.defaultdict(list)
            for r in cands:
                by_vendor[r["_vendor"]].append(r)
            default_rows = by_vendor.get("harvey", []) + by_vendor.get("helical", [])
            corner = 0.0
            if cls == "bull":
                crs = sorted(float(r["tool"]["corner_radius"]) for r in cands) if cands else []
                corner = crs[len(crs) // 2] if crs else (0.015 if D >= 0.125 else 0.005)
            brands = [("unbranded default", None, default_rows), ("Helical", "helical", by_vendor.get("helical", []))]
            # the best charted brand: the vendor whose median row gives the shortest chart time at 0.150"
            best_key, best_t = None, None
            for v, rs in by_vendor.items():
                tmid = chart_for(rs, 0.150, DEFAULT_RAMP_DEG, 0.5)["total_min"]
                if best_t is None or tmid < best_t:
                    best_key, best_t = v, tmid
            if best_key and best_key not in ("helical",):
                brands.append((f"best charted ({best_key})", best_key, by_vendor[best_key]))
            for label, key, rs in brands:
                if cls == "bull" and key is not None:
                    continue   # the engine reads no brand for bull-nose tools (shaped consensus table); one unbranded run
                notes = []
                tw = {}
                for a in aggs:
                    from toolwiz_common import brand as brand_mod
                    res = toolwiz(mat, D, z, geometry, a, mach, brand=brand_mod.display_name(key) if key else None,
                                  corner=corner)
                    tw[a] = {dep: tw_option(res, D, z, dep, dyn, mach) for dep in depths}
                    if a == 0.5 and with_estimates:
                        t0 = tw[a][depths[1]]
                        tw[a]["estimates"] = model_estimates(mat, D, z, geometry, corner, None, t0["ap_eff"], D, t0["fz"],
                                                             t0["rpm"], a, res.runout_in)
                ramp = tw[aggs[0]][depths[0]]["ramp_deg"], tw[aggs[0]][depths[0]]["ramp_frac"]
                chart = {dep: chart_for(rs, dep, ramp[0], ramp[1]) for dep in depths} if rs else None
                if chart and with_estimates:
                    c1 = chart[depths[1]]
                    chart["estimates"] = model_estimates(mat, D, z, geometry, corner, None, c1["ap_eff"], D, c1["fz"],
                                                         c1["rpm"], 0.5, res.runout_in)
                if not rs:
                    notes.append(f"no cited {cls} {z}-flute slot row at {D:g}\" for this material")
                vb = tw[0.5 if 0.5 in tw else aggs[0]][depths[0]]["vendor_basis"]
                if cls == "bull":
                    notes.append(f"engine vendor basis for the bull nose: {vb.get('mode')} {vb.get('chart_class') or ''} "
                                 f"({vb.get('note') or 'shaped consensus table; falls back to the square-end table when it has too few vendor groups'})")
                name = f"{'square' if cls == 'square' else 'bull-nose'} {z}FL {label}"
                add(name, cls, {"D": D, "z": z, "corner_radius": corner}, chart, tw, notes)

    # 4. HEM with the next size down
    d_small = HEM_TOOL[D]
    import strategy_planner as sp
    for z in (3, 4):
        tw = {}
        notes = []
        for a in aggs:
            probe = toolwiz(mat, d_small, z, "Square", a, mach, op="Adaptive Roughing")
            tir = probe.runout_in
            req = {"family": mat["family"], "alloy": mat["alloy"], "aggressiveness": a, "runout": tir, "model": "v2",
                   "use_cutlog": False,
                   "candidate_tools": [{"diameter": d_small, "flutes": z, "flute_length": 3.0 * d_small,
                                        "shank_diameter": 0.125, "stickout": 4.0 * d_small, "coating": "AlTiN"}]}
            per = {}
            for dep in depths:
                out = sp.compare(dict(req, feature={"type": "slot", "width": D, "depth": dep, "length": PERIMETER_IN}),
                                 physics(), mach["profile"])
                opt = next((o_ for o_ in out["options"] if o_["strategy"] == "adaptive"), None)
                if opt is None:
                    per[dep] = None
                    continue
                stock = (opt.get("stock_to_leave_in") or {}).get("radial") or probe.recommended_radial_stock_in or 0.0
                fin = sum(p["in_cut_min"] for p in opt["phases"][1:])
                w_eff = D - 2.0 * stock
                ht = hem_time(dep, opt["ap"], opt["ae"], opt["feed_ipm"], w_eff, d_small, dyn, mach["max_feed_ipm"],
                              finish_min=fin)
                per[dep] = {"rpm": opt["rpm"], "sfm": opt["sfm"], "fz": opt["fz_in"], "feed_ipm": opt["feed_ipm"],
                            "ap": opt["ap"], "ae": opt["ae"], "planner_cycle_min": opt["cycle_time_min"],
                            "planner_breakdown": opt["time_breakdown_min"], "feasible": opt["feasible"],
                            "limited_by": probe.limited_by, "runout_in": tir, "stock_radial_in": stock,
                            "channel_in": w_eff, "spindle_limited": bool(opt["rpm"] >= mach["max_rpm"] * 0.999), **ht}
            tw[a] = per
            if a == 0.5 and with_estimates and per.get(depths[1]):
                p1 = per[depths[1]]
                tw[a]["estimates"] = model_estimates(mat, d_small, z, "Square", 0.0, None, p1["ap_eff"], p1["ae"], p1["fz"],
                                                     p1["rpm"], a, tir, op="adaptive")
        cands = chart_rows(rows, mat["family"], hb, d_small, "square", z, op="hem")
        chart = None
        if cands:
            chart = {}
            for dep in depths:
                opts = []
                p_tw = (tw.get(0.5) or tw[aggs[0]]).get(dep) or {}
                for r in cands:
                    c = r["cut"]
                    rpm, feed, lim = chart_feed(nominal(c["sfm"]), float(r["tool"]["DC"]), z, nominal(c["fz"]),
                                                mach["max_rpm"], mach["max_feed_ipm"])
                    ht = hem_time(dep, float(c["ap"]), min(float(c["ae"]), 0.5 * d_small), feed,
                                  p_tw.get("channel_in", D), d_small, dyn, mach["max_feed_ipm"],
                                  finish_min=p_tw.get("finish_min", 0.0))
                    opts.append({"source": f"{r['_vendor']} {r['source']['doc_id']}: {r['source'].get('row_label')} / "
                                           f"{r['source'].get('column_label')}", "row_id": r["id"], "vendor": r["_vendor"],
                                 "series": r["tool"].get("series"), "D": float(r["tool"]["DC"]), "z": z,
                                 "sfm": nominal(c["sfm"]), "fz": nominal(c["fz"]), "ap": float(c["ap"]),
                                 "ae": float(c["ae"]), "rpm": rpm, "feed_ipm": feed, "spindle_limited": lim, **ht})
                chart[dep] = median_pick(opts)
        else:
            notes.append(f"no cited {z}-flute HEM row at {d_small:g}\" for this material: vendor-chart column empty")
        notes.append(f"HEM tool {d_small:g}\" {z}FL in a {D:g}\" slot; path by strategy_planner (trochoid loops, return arcs "
                     f"at link feed, both walls finished at ToolWiz finishing numbers, included)")
        add(f"HEM {d_small:g}\" {z}FL (adaptive)", "hem", {"D": d_small, "z": z}, chart, tw, notes)
    return {"material": mat_name, "family": mat["family"], "hb": hb, "material_note": mat["note"], "D": D,
            "options": options}


def run(quick=False):
    mach = machine()
    rows = load_rows()
    dyn = DYNAMICS["nominal"]
    cases = []
    if quick:
        cases.append(study_case("Ti-6Al-4V", 0.125, (0.5,), (0.150,), mach, dyn, rows, with_estimates=False))
    else:
        for mname in ("Ti-6Al-4V", "17-4 PH", "6061"):
            for D in DIAMETERS:
                cases.append(study_case(mname, D, AGGRESSIVENESS, DEPTHS, mach, dyn, rows))
    sens = None
    if not quick:
        sens = sensitivity(cases, mach)
    return {"machine": {k: v for k, v in mach.items() if k != "profile"}, "dynamics": DYNAMICS, "perimeter_in": PERIMETER_IN,
            "corners": CORNERS, "depths": DEPTHS if not quick else (0.150,), "cases": cases, "sensitivity": sens}


def sensitivity(cases, mach):
    """Total time at 0.150" and 50 % with the pessimistic dynamics, for every option with numbers."""
    dyn = DYNAMICS["pessimistic"]
    out = []
    for c in cases:
        for o_ in c["options"]:
            tw = (o_["toolwiz"].get(0.5) or {}).get(0.150)
            if not tw:
                continue
            if o_["kind"] == "hem":
                t = hem_time(0.150, tw["ap"], tw["ae"], tw["feed_ipm"], tw["channel_in"], o_["tool"]["D"], dyn,
                             mach["max_feed_ipm"], finish_min=tw["finish_min"])["total_min"]
            else:
                t = slot_time(0.150, tw["ap"], tw["feed_ipm"], tw["ramp_deg"], tw["ramp_frac"], dyn,
                              rapid_ipm=mach["rapid_ipm"])["total_min"]
            out.append({"material": c["material"], "D": c["D"], "option": o_["name"], "nominal_min": tw["total_min"],
                        "pessimistic_min": t})
    return out


# ---------------------------------------------------------------------------------------------------------------------
# tables
# ---------------------------------------------------------------------------------------------------------------------

def _f(x, nd=1):
    return "-" if x is None else f"{x:.{nd}f}"


def headline_rows(case, depth=0.150, agg=0.5):
    """[(option, chart dict or None, toolwiz dict or None)] at one depth and aggressiveness."""
    out = []
    for o_ in case["options"]:
        ch = (o_["chart"] or {}).get(depth) if o_["chart"] else None
        tw = (o_["toolwiz"].get(agg) or {}).get(depth) if o_["toolwiz"] else None
        out.append((o_, ch, tw))
    return out


def _basis(tw):
    vb = tw.get("vendor_basis") or {}
    if not vb.get("mode"):
        return ""
    return f"[{vb['mode']}{' ' + vb['vendor'] if vb.get('vendor') else ''}]"


def table_case(case, depth=0.150, agg=0.5):
    lines = [f"#### {case['material']}, {case['D']:g}\" slot, depth {depth:.3f}\", aggressiveness {agg:.0%}",
             "",
             "| option | vendor chart: source | SFM (on machine) | rpm | fz | ap | feed IPM | levels | time min | "
             "ToolWiz: SFM | rpm | fz | ap | feed IPM | levels | time min | limited by |",
             "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|"]
    for o_, ch, tw in headline_rows(case, depth, agg):
        if ch:
            sp_ = " (spindle-limited)" if ch.get("spindle_limited") else ""
            c = (f"{ch['vendor']} {ch.get('series') or ''} | {ch['sfm']:.0f} ({ch['sfm_on_machine'] if 'sfm_on_machine' in ch else math.pi * ch['D'] * ch['rpm'] / 12:.0f}){sp_} "
                 f"| {ch['rpm']:.0f} | {ch['fz']:.5f} | {ch['ap']:.4f} | {ch['feed_ipm']:.1f} | {ch['levels']} | {ch['total_min']:.2f}")
        else:
            c = "no cited row | - | - | - | - | - | - | -"
        if tw:
            sl = " (spindle-limited)" if tw.get("spindle_limited") else ""
            t = (f"{tw['sfm']:.0f}{sl} | {tw['rpm']:.0f} | {tw['fz']:.5f} | {tw['ap']:.4f} | {tw['feed_ipm']:.1f} | "
                 f"{tw['levels']} | {tw['total_min']:.2f} | {tw.get('limited_by') or ''} {_basis(tw)}")
        else:
            t = "- | - | - | - | - | - | - | -"
        lines.append(f"| {o_['name']} | {c} | {t} |")
    return "\n".join(lines)


def time_matrix(case):
    """Total minutes per option: vendor chart / ToolWiz at every depth and aggressiveness."""
    aggs = sorted({a for o_ in case["options"] for a in o_["toolwiz"] if isinstance(a, float)})
    head = "| option | " + " | ".join(f"{d:.3f}\" chart | " + " | ".join(f"TW {a:.0%}" for a in aggs) for d in DEPTHS) + " |"
    sep = "|---|" + "|".join(["---"] * (len(DEPTHS) * (1 + len(aggs)))) + "|"
    lines = [f"#### {case['material']}, {case['D']:g}\" slot: total minutes (vendor chart / ToolWiz at 0, 50, 100 %)", "",
             head, sep]
    for o_ in case["options"]:
        cells = []
        for d in DEPTHS:
            ch = (o_["chart"] or {}).get(d) if o_["chart"] else None
            cells.append(_f(ch["total_min"], 2) if ch else "-")
            for a in aggs:
                tw = (o_["toolwiz"].get(a) or {}).get(d)
                cells.append(_f(tw["total_min"], 2) if tw else "-")
        lines.append(f"| {o_['name']} | " + " | ".join(cells) + " |")
    return "\n".join(lines)


def estimates_table(case):
    lines = [f"#### {case['material']}, {case['D']:g}\": model estimates at 50 % (engine model, not measured)", "",
             "| option | at | lateral peak N | tip deflection in | axial peak N | power W | W per edge | W per mm edge | "
             "relative Taylor life | wear index per slot | chart cut fails |", "|---|---|---|---|---|---|---|---|---|---|---|"]
    for o_ in case["options"]:
        for where, block, tblock in (("ToolWiz", (o_["toolwiz"].get(0.5) or {}).get("estimates"), (o_["toolwiz"].get(0.5) or {}).get(0.150)),
                                     ("chart", (o_["chart"] or {}).get("estimates") if o_["chart"] else None,
                                      (o_["chart"] or {}).get(0.150) if o_["chart"] else None)):
            if not block or not tblock:
                continue
            in_cut = tblock["cut_min"] + tblock.get("ramp_min", 0.0) + (tblock.get("finish_min") or 0.0)
            wear = in_cut / block["life_ratio"] if block["life_ratio"] else None
            lines.append(f"| {o_['name']} | {where} | {block['lateral_peak_n']:.1f} | {block['deflection_in']:.5f} | "
                         f"{_f(block['axial_peak_n'])} | {block['power_w']:.0f} | {block['power_per_edge_w']:.1f} | "
                         f"{block['power_per_mm_edge_w']:.2f} | {block['life_ratio']:.2f} | {_f(wear, 2)} | "
                         f"{', '.join(block['violated']) if where == 'chart' else ''} |")
    return "\n".join(lines)


def ranking(case, depth=0.150, agg=0.5):
    """Options sorted by vendor-chart time, and by ToolWiz time."""
    ch = sorted([(o_["name"], o_["chart"][depth]["total_min"]) for o_ in case["options"] if o_["chart"] and o_["chart"].get(depth)],
                key=lambda x: x[1])
    tw = sorted([(o_["name"], o_["toolwiz"][agg][depth]["total_min"]) for o_ in case["options"]
                 if (o_["toolwiz"].get(agg) or {}).get(depth) and o_["toolwiz"][agg][depth].get("feasible", True)],
                key=lambda x: x[1])
    return ch, tw


def render(data):
    parts = [f"Machine: {data['machine']['label']}, max feed {data['machine']['max_feed_ipm']:.0f} IPM, rapid "
             f"{data['machine']['rapid_ipm']:.0f} IPM (profile). Dynamics: {DYNAMICS['nominal']['basis']}. Feature: closed "
             f"contour slot one tool diameter wide, perimeter {PERIMETER_IN}\", {CORNERS} corners per level.", ""]
    parts.append("### Headline (0.150\" deep, 50 %)\n")
    for case in data["cases"]:
        parts.append(table_case(case))
        ch, tw = ranking(case)
        if ch:
            parts.append("\nFastest on vendor-chart numbers: " + "; ".join(f"{n} {t:.2f}" for n, t in ch[:4]) + " min.")
        if tw:
            parts.append("Fastest on ToolWiz numbers: " + "; ".join(f"{n} {t:.2f}" for n, t in tw[:4]) + " min.")
        parts.append("")
    parts.append("### All depths and aggressiveness levels (total minutes)\n")
    for case in data["cases"]:
        parts.append(time_matrix(case))
        parts.append("")
    parts.append("### Model estimates (tool load, heat, relative wear)\n")
    for case in data["cases"]:
        parts.append(estimates_table(case))
        parts.append("")
    if data.get("sensitivity"):
        parts += ["### Dynamics sensitivity (0.150\", 50 %, ToolWiz numbers)", "",
                  f"Pessimistic: {DYNAMICS['pessimistic']['basis']}.", "",
                  "| material | D | option | nominal min | pessimistic min | change |", "|---|---|---|---|---|---|"]
        for s in data["sensitivity"]:
            parts.append(f"| {s['material']} | {s['D']:g} | {s['option']} | {s['nominal_min']:.2f} | {s['pessimistic_min']:.2f} | "
                         f"{s['pessimistic_min'] / s['nominal_min'] - 1:+.0%} |")
        parts.append("")
    notes = []
    for case in data["cases"]:
        for o_ in case["options"]:
            for n in o_["notes"]:
                notes.append(f"* {case['material']} {case['D']:g}\" {o_['name']}: {n}")
            for a, per in (o_["toolwiz"] or {}).items():
                for d, tw in per.items():
                    if isinstance(tw, dict) and tw.get("spindle_sentence") and a == 0.5 and d == 0.150:
                        notes.append(f"* {case['material']} {case['D']:g}\" {o_['name']} (50 %): {tw['spindle_sentence']}")
    parts += ["### Option notes (generated)", ""] + sorted(set(notes))
    return "\n".join(parts)


def write_doc(text):
    with open(DOC, encoding="utf-8") as fh:
        doc = fh.read()
    i, j = doc.index(BEGIN), doc.index(END)
    with open(DOC, "w", encoding="utf-8") as fh:
        fh.write(doc[:i + len(BEGIN)] + "\n\n" + text + "\n\n" + doc[j:])


def _jsonable(x):
    if isinstance(x, dict):
        return {str(k): _jsonable(v) for k, v in x.items()}
    if isinstance(x, (list, tuple)):
        return [_jsonable(v) for v in x]
    if isinstance(x, float):
        return round(x, 6)
    return x


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--quick", action="store_true")
    a = ap.parse_args(argv)
    data = run(quick=a.quick)
    text = render(data)
    if a.quick:
        print(text)
        return 0
    os.makedirs(os.path.dirname(OUT_JSON), exist_ok=True)
    with open(OUT_JSON, "w", encoding="utf-8") as fh:
        json.dump(_jsonable(data), fh, indent=1, ensure_ascii=False)
        fh.write("\n")
    write_doc(text)
    print(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
