"""What do vendors design to? Spread of candidate invariants over the vendor side/rough/HEM rows (Round 3).

For every side, rough and HEM row in tests/benchmarks/v2 (generic and material-specific sheets alike,
weight 1 each), on the row's catalog geometry and its own material (the same mapping and stickout rule as
tools/v2_provisional_limits.py), with the optimizer's force, runout and beam model:

  δ/D, δ (in)                tip deflection, largest over a revolution, load at its centroid
  σ_root, σ_shank (MPa)      largest σ1 at the flute root (fluted section, as the optimizer) and in the
                             shank at the step into it
  F_mean, F_peak (N)         lateral force; F_mean/D² (N/mm²)
  h_worst, h_thin, h_m (mm)  worst flute's h_max, thinnest flute's h_max, nominal mean chip
  q_edge (N/mm)              tangential force per unit engaged edge length per tooth at the mean chip,
                             kc(h_m)·h_m (+K_te)
  P/D² (W/mm²)               spindle power per D²
plus h_m/D, h_worst/D.

For each quantity it reports, per diameter band and overall, n, median, CV (σ/mean) and p90/p10.
A second part re-evaluates the flute-root stress under alternative stress-model assumptions.

Run from the repo root (Windows: python tools\\v2_invariants.py). Writes data/model_v2/invariants.json.
"""
import json
import math
import os
import statistics
import sys
from dataclasses import replace

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)
TOOLS = os.path.join(ROOT, "tools")
if TOOLS not in sys.path:
    sys.path.insert(0, TOOLS)

import v2_provisional_limits as pl  # noqa: E402
from gwizard_physics import BeamDeflectionEngine  # noqa: E402
from physics_v2 import optimize as o  # noqa: E402

MM = o.MM_PER_IN
FATIGUE_MPA = 0.375 * 3800.0          # 0.35–0.4 × TRS 3.8 GPa, fully reversed bending (research doc §2)
TRS_MPA = 3800.0

QUANTITIES = [
    ("delta_over_D", "δ/D", ""), ("delta_in", "δ", "in"),
    ("sigma_root", "σ flute root", "MPa"), ("sigma_shank", "σ shank at step", "MPa"),
    ("F_mean", "F mean", "N"), ("F_peak", "F peak", "N"), ("F_over_D2", "F mean / D²", "N/mm²"),
    ("h_worst", "worst-flute h_max", "mm"), ("h_thin", "thinnest-flute h_max", "mm"), ("h_m", "h_m", "mm"),
    ("h_m_over_D", "h_m / D", ""), ("h_worst_over_D", "h_worst / D", ""),
    ("q_edge", "F_t per tooth per mm of edge", "N/mm"), ("P_over_D2", "power / D²", "W/mm²"),
]


def section_props(seg, D_in, z, helix, model, core_ratio):
    """(I mm⁴, c mm, J mm⁴) of the flute-root section for a stress model."""
    D = D_in * MM
    if model == "core":                     # core circle d = core_ratio·D (round 1–2 model)
        d = core_ratio * D
        I = math.pi * d ** 4 / 64.0
        return I, d / 2.0, 2.0 * I
    if model == "v1_section":               # the deflection model's own fluted inertia, outer fibre at D/2
        I = BeamDeflectionEngine.fluted_core_inertia(D_in, z, helix) * MM ** 4
        return I, D / 2.0, 2.0 * I
    if model == "equiv_0.8D":               # equivalent cylinder 0.8·D (Kops & Vo 1990, compliance)
        d = 0.8 * D
        I = math.pi * d ** 4 / 64.0
        return I, d / 2.0, 2.0 * I
    raise ValueError(model)


def sigma1(m_nmm, t_nmm, I, c, J):
    s = m_nmm * c / I
    tau = t_nmm * c / J
    return s / 2.0 + math.hypot(s / 2.0, tau)


def evaluate(row, machine, mat_over=None, section="v1_section", stickout_extra=1.0, n_theta=360, n_quad=64):
    mat, mat_basis = pl.row_material(row)
    if mat is None:
        return None
    if mat_over:
        mat = replace(mat, **mat_over)
    t = row["tool"]
    D, lcf, shank = float(t["DC"]), float(t["LCF"]), float(t.get("SFDM") or t["DC"])
    reach = float(t["LB"]) if t.get("LB") else lcf
    neck = reach > lcf * 1.01
    tool = o.Tool.build(D, int(t["flutes"]), lcf, reach + stickout_extra * shank, shank=shank,
                        neck_diameter=(t.get("neck_diameter") or D) if neck else None,
                        neck_length=reach if neck else None, helix_deg=float(t.get("helix_deg") or 35.0))
    c = row["cut"]
    sfm, fz = pl.nominal(c["sfm"]), pl.nominal(c["fz"])
    ap, ae = min(float(c["ap"]), tool.lcf), min(float(c["ae"]), tool.D)
    rpm = 12.0 * sfm / (math.pi * tool.D)
    ctx = o._Context(tool, mat, machine, "rough", o.Margins(0.5), n_theta, n_quad,
                     deflection_allow=1.0, stress_limit=1e9, effective_feed_ipm=None)
    pt = o.CutPoint(ctx, ap, ae, rpm)
    chips = pt.max_chips_mm(fz)
    f = pt.loads(fz)
    beam = pt._beam(f)
    segs = tool.segments
    root_x = next(s.end for s in segs if s.fluted)
    shank_seg = segs[-1]
    I, cc, J = section_props(segs[0], D, tool.z, tool.helix_deg, section, tool.core())
    I_s = math.pi * (shank_seg.d0 * MM) ** 4 / 64.0
    s_root = s_shank = 0.0
    for mag, cen, tq, _ in f["samples"]:
        a = cen / MM
        if root_x > a:
            s_root = max(s_root, sigma1(mag * (root_x - a) * MM, abs(tq) * 1000.0, I, cc, J))
        if shank_seg.start > a:
            s_shank = max(s_shank, sigma1(mag * (shank_seg.start - a) * MM, abs(tq) * 1000.0, I_s,
                                          shank_seg.d0 * MM / 2.0, 2.0 * I_s))
    D_mm = D * MM
    h_m = o.forces.mean_chip_thickness(fz * MM, ae * MM, D_mm)
    return {
        "id": row["id"], "doc": row["source"]["doc_id"], "family": row["material"]["toolwiz_family"],
        "generic": row["source"]["doc_id"] in ("SF_73000", "SF_72000", "SF_47800", "SF_34600"),
        "D": D, "z": tool.z, "ap_over_D": ap / D, "ae_over_D": ae / D, "sfm": sfm, "fz": fz,
        "delta_in": beam["delta_in"], "delta_over_D": beam["delta_in"] / D,
        "sigma_root": s_root, "sigma_shank": s_shank,
        "F_mean": f["mean_n"], "F_peak": f["peak_n"], "F_over_D2": f["mean_n"] / D_mm ** 2,
        "h_worst": max(chips), "h_thin": min(chips), "h_m": h_m,
        "h_m_over_D": h_m / D_mm, "h_worst_over_D": max(chips) / D_mm,
        "q_edge": ctx.coeffs.kc(h_m) * h_m + ctx.coeffs.k_te,
        "P_over_D2": f["power_kw"] * 1000.0 / D_mm ** 2,
    }


def stats(vals):
    vals = sorted(v for v in vals if v is not None and v > 0)
    n = len(vals)
    if n < 2:
        return {"n": n}
    q = statistics.quantiles(vals, n=10)
    mean = statistics.fmean(vals)
    return {"n": n, "median": statistics.median(vals), "cv": statistics.pstdev(vals) / mean,
            "p10": q[0], "p90": q[-1], "p90_p10": q[-1] / q[0], "max": vals[-1]}


def load_rows():
    import glob
    rows = []
    for path in sorted(glob.glob(os.path.join(ROOT, "tests", "benchmarks", "v2", "*.json"))):
        with open(path, encoding="utf-8") as fh:
            rows += [r for r in json.load(fh)["rows"] if r["operation"] in pl.OPERATIONS]
    return rows


def invariants(rows, tir=0.0002):
    mach = o.speedio_16k(tir)
    ev = [e for e in (evaluate(r, mach) for r in rows) if e]
    out = {"tir_in": tir, "n_rows": len(ev), "bands": {}, "overall": {}}
    for key, _, _ in QUANTITIES:
        out["overall"][key] = stats([e[key] for e in ev])
    for name, lo, hi in pl.BANDS:
        sel = [e for e in ev if lo <= e["D"] < hi]
        out["bands"][name] = {key: stats([e[key] for e in sel]) for key, _, _ in QUANTITIES}
    return out, ev


STRESS_VARIANTS = [
    ("baseline: core circle 0.6·D, K_r 0.4, kc ×1, TIR 0.0002", {}, "core", 0.0002),
    ("core circle 0.75·D (v1's 4FL core)", {"_core": 0.75}, "core", 0.0002),
    ("v1 fluted section (same I as C3), fibre at D/2", {}, "v1_section", 0.0002),
    ("equivalent cylinder 0.8·D (Kops & Vo)", {}, "equiv_0.8D", 0.0002),
    ("K_r 0.3", {"k_r": 0.3}, "core", 0.0002),
    ("kc ×0.79 (Sandvik ToolGuide tool factor)", {"tool_factor": 0.79}, "core", 0.0002),
    ("TIR 0 (no runout)", {}, "core", 0.0),
    ("TIR 0.0001", {}, "core", 0.0001),
    ("v1 section + kc ×0.79", {"tool_factor": 0.79}, "v1_section", 0.0002),
    ("v1 section + kc ×0.79 + TIR 0.0001", {"tool_factor": 0.79}, "v1_section", 0.0001),
    ("v1 section + kc ×0.79 + TIR 0", {"tool_factor": 0.79}, "v1_section", 0.0),
    ("v1 section + kc ×0.79 + K_r 0.3 + TIR 0", {"tool_factor": 0.79, "k_r": 0.3}, "v1_section", 0.0),
]


def stress_variants(rows):
    out = []
    for name, over, section, tir in STRESS_VARIANTS:
        mach = o.speedio_16k(tir)
        over = dict(over)
        core = over.pop("_core", None)
        ev = []
        for r in rows:
            if core:
                # override the core ratio through the tool: evaluate() reads tool.core(); patch via flutes map
                saved = dict(o.CORE_RATIO_BY_FLUTES)
                o.CORE_RATIO_BY_FLUTES.update({k: core for k in saved})
                try:
                    e = evaluate(r, mach, over or None, section)
                finally:
                    o.CORE_RATIO_BY_FLUTES.clear()
                    o.CORE_RATIO_BY_FLUTES.update(saved)
            else:
                e = evaluate(r, mach, over or None, section)
            if e:
                ev.append(e)
        s = [e["sigma_root"] for e in ev]
        worst = max(ev, key=lambda e: e["sigma_root"])
        out.append({"variant": name, "n": len(s), "median": statistics.median(s), "p90": statistics.quantiles(s, n=10)[-1],
                    "max": max(s), "max_row": worst["id"], "over_fatigue": sum(v > FATIGUE_MPA for v in s),
                    "over_trs": sum(v > TRS_MPA for v in s)})
    return out


def stickout_sensitivity(rows):
    mach = o.speedio_16k(0.0002)
    out = []
    for extra in (0.0, 1.0, 2.0):
        ev = [e for e in (evaluate(r, mach, stickout_extra=extra) for r in rows) if e]
        out.append({"stickout": f"reach + {extra:g}·shank", "delta_over_D": stats([e["delta_over_D"] for e in ev]),
                    "sigma_root_median": statistics.median(e["sigma_root"] for e in ev),
                    "sigma_shank_median": statistics.median(e["sigma_shank"] for e in ev)})
    return out


def main():
    rows = load_rows()
    inv, ev = invariants(rows)
    inv0, _ = invariants(rows, 0.0)
    result = {"status": "Round 3 analysis (2026-10-16)", "generated_by": "tools/v2_invariants.py",
              "fatigue_reference_mpa": FATIGUE_MPA, "invariants_tir_0002": inv, "invariants_tir_0": inv0,
              "stress_variants": stress_variants(rows), "stickout_sensitivity": stickout_sensitivity(rows),
              "rows": ev}
    path = os.path.join(ROOT, "data", "model_v2", "invariants.json")
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(result, fh, indent=1, ensure_ascii=False)
        fh.write("\n")
    print(f"{'quantity':32} {'overall CV':>10} {'p90/p10':>8} | per band p90/p10")
    for key, label, unit in QUANTITIES:
        ov = inv["overall"][key]
        bands = " ".join(f"{inv['bands'][b][key].get('p90_p10', float('nan')):6.1f}" for b, _, _ in pl.BANDS)
        print(f"{label + (' ' + unit if unit else ''):32} {ov['cv']:10.2f} {ov['p90_p10']:8.1f} | {bands}")
    print("\nstress variants (flute root):")
    for v in result["stress_variants"]:
        print(f"  {v['variant']:58} median {v['median']:5.0f} p90 {v['p90']:5.0f} max {v['max']:5.0f} "
              f"over fatigue {v['over_fatigue']}/{v['n']}, over TRS {v['over_trs']}")
    print("\nstickout:")
    for s in result["stickout_sensitivity"]:
        print(f"  {s['stickout']:22} δ/D median {s['delta_over_D']['median']:.5f} p90/p10 {s['delta_over_D']['p90_p10']:.1f}; "
              f"σ root median {s['sigma_root_median']:.0f}; σ shank median {s['sigma_shank_median']:.0f}")
    print(f"wrote {path}")


if __name__ == "__main__":
    main()
