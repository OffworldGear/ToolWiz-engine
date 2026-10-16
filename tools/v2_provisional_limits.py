"""Provisional C3/C4 limits for the v2 optimizer from the vendor benchmark rows (user decision 2026-10-16).

For every side, rough and HEM row in tests/benchmarks/v2/*.json this evaluates, with the optimizer's own
force, runout and beam model (physics_v2/optimize.py), the published cut on the row's catalog geometry
and its own material:
  * the largest tip deflection over a revolution, load at its centroid (C3's quantity), as δ/D;
  * the largest principal stress at the flute root (core circle), diameter steps and holder face (C4's).
Per diameter band it writes the median and the spread (min, quartiles, max) to
data/model_v2/provisional_limits.json; the optimizer uses the medians as provisional C3/C4 limits.
Step 4 (calibration) replaces them.

Assumptions, all recorded in the output:
  * Material: the family's Sandvik MC row nearest the row's hardness, scaled by (HB/HB_ref)^p with p from
    that family's own Sandvik condition rows (docs/research/material_mapping_v2.md); 17-4 PH is always
    P5.0.Z.AN with p = 0.41 (user decision 2026-10-15). Titanium rows are skipped (Sandvik gives no mc).
    A row with no hardness uses the group row's nominal HB.
  * Stickout: the published reach (LB) or LCF, plus one shank diameter of clearance before the holder.
    A reach longer than LCF is a neck of the published neck diameter (DC when not published).
  * Runout: 0.0002" TIR, eccentric model at its worst phase (the optimizer's default).
  * Cut: ap capped at LCF; SFM and fz the nominal value, else the middle of the published range.
  * Helix: the published angle, else 35°. Flute count as published.

Run from the repo root (Windows: python tools\\v2_provisional_limits.py).
"""
import datetime
import glob
import json
import math
import os
import statistics
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

from gwizard_physics import ASTMHardnessConverter  # noqa: E402
from physics_v2 import forces  # noqa: E402
from physics_v2 import optimize as o  # noqa: E402

OPERATIONS = ("side", "rough", "hem")
TIR_IN = 0.0002

# family → (Sandvik MC rows to choose from by hardness, hardness exponent p, basis)
FAMILY_GROUPS = {
    "Stainless - PH Series (17-4)": (["P5.0.Z.AN"], 0.41, "user decision 2026-10-15 (ToolGuide probe)"),
    "Stainless - 400 Series (420)": (["P5.0.Z.AN", "P5.0.Z.HT"], 0.49, "P5.0 AN→HT"),
    "Stainless - 300 Series (316)": (["M1.0.Z.AQ"], 0.45, "M1.0 AQ→PH"),
    "Steel - Low Carbon (1020)": (["P1.1.Z.AN", "P1.1.Z.HT"], 0.40, "P1.1 AN→HT"),
    "Steel - Medium Carbon (1045)": (["P1.2.Z.AN", "P1.2.Z.HT"], 0.68, "P1.2 AN→HT"),
    "Steel - Medium Carbon Alloy (4130)": (["P2.2.Z.AN", "P2.5.Z.HT"], 0.26, "P2.1 AN→P2.5 HT"),
    "Steel - Tool (H13)": (["P3.0.Z.AN", "P3.0.Z.HT", "H1.1.Z.HA", "H1.2.Z.HA"], 0.72, "P3.0 AN→HT"),
    "Aluminum - Wrought (6061)": (["N1.2.Z.AG"], 0.0, "no hardness scaling"),
    "High Temp Nickel Alloy": (["S2.0.Z.AN", "S2.0.Z.AG"], 0.27, "S2.0 AN→AG"),
}

BANDS = [("1/64–3/64", 0.0, 0.05), ("1/16–3/32", 0.05, 0.1), ("1/8–3/16", 0.1, 0.2),
         ("1/4–3/8", 0.2, 0.4), ("1/2–3/4", 0.4, 0.8), ("1 and up", 0.8, math.inf)]


def row_hb(hardness):
    """Brinell for a row's hardness range: the middle, else the one bound given; None when unpublished."""
    if not hardness:
        return None
    lo, hi, scale = hardness.get("min"), hardness.get("max"), (hardness.get("scale") or "").upper()
    vals = [v for v in (lo, hi) if v is not None]
    if not vals or not scale:
        return None
    v = sum(vals) / len(vals)
    if scale == "HRC":
        return ASTMHardnessConverter.hrc_to_brinell(v)
    if scale == "HRB":
        return ASTMHardnessConverter.hrb_to_brinell(v)
    return float(v)


def group_hb(kienzle):
    h = dict(kienzle.source).get("hardness", "")
    value, scale = h.split()[0], h.split()[-1].upper()
    value = float(value)
    return ASTMHardnessConverter.hrc_to_brinell(value) if scale == "HRC" else value


def row_material(row):
    fam = row["material"].get("toolwiz_family")
    spec = FAMILY_GROUPS.get(fam)
    if spec is None:
        return None, f"no Kienzle mapping with mc for {fam}"
    codes, p, basis = spec
    hb = row_hb(row["material"].get("hardness"))
    groups = [(c, forces.load_kienzle(c)) for c in codes]
    groups = [(c, k, group_hb(k)) for c, k in groups]
    code, k, ref = min(groups, key=lambda g: abs(g[2] - hb)) if hb else groups[0]
    mat = o.Material(name=f"{fam} via {code}", kienzle=k, hb_ref=ref, hb=hb or ref, kc_hardness_exp=p)
    return mat, f"{code} ({k.kc1_1:g} at {ref:.0f} HB) ×(HB {hb or ref:.0f}/{ref:.0f})^{p:g} [{basis}]"


def row_tool(row):
    t = row["tool"]
    D, lcf, shank = float(t["DC"]), float(t["LCF"]), float(t.get("SFDM") or t["DC"])
    reach = float(t["LB"]) if t.get("LB") else lcf
    neck = reach > lcf * 1.01
    stickout = reach + shank
    tool = o.Tool.build(D, int(t["flutes"]), lcf, stickout, shank=shank,
                        neck_diameter=(t.get("neck_diameter") or D) if neck else None,
                        neck_length=reach if neck else None, helix_deg=float(t.get("helix_deg") or 35.0))
    return tool, stickout


def nominal(v):
    if isinstance(v, (int, float)):
        return float(v)
    if v.get("nominal") is not None:
        return float(v["nominal"])
    vals = [x for x in (v.get("min"), v.get("max")) if x is not None]
    return sum(vals) / len(vals) if vals else None


def evaluate_row(row, machine):
    mat, mat_basis = row_material(row)
    if mat is None:
        return {"id": row["id"], "skipped": mat_basis}
    tool, stickout = row_tool(row)
    c = row["cut"]
    sfm, fz = nominal(c["sfm"]), nominal(c["fz"])
    ap, ae = min(float(c["ap"]), tool.lcf), min(float(c["ae"]), tool.D)
    rpm = 12.0 * sfm / (math.pi * tool.D)
    r = o.evaluate_cut(tool, mat, machine, "rough", ap, ae, fz, rpm=rpm, n_theta=360, n_quad=64,
                       deflection_allow=1.0, stress_limit=1e9, effective_feed_ipm=None)
    top = r["loads"]["sections"][0] if r["loads"]["sections"] else {"kind": "none", "sigma1_mpa": 0.0}
    return {
        "id": row["id"], "doc": row["source"]["doc_id"], "family": row["material"]["toolwiz_family"],
        "material": mat_basis, "D": tool.D, "z": tool.z, "stickout": stickout,
        "ap_over_D": ap / tool.D, "ae_over_D": ae / tool.D, "ap_capped": ap < float(c["ap"]) - 1e-9,
        "sfm": sfm, "fz": fz, "mrr_in3_min": r["cut"]["mrr_in3_min"],
        "lateral_mean_n": r["loads"]["lateral_mean_n"], "lateral_peak_n": r["loads"]["lateral_peak_n"],
        "deflection_in": r["loads"]["deflection_tip_in"],
        "deflection_over_D": r["loads"]["deflection_tip_in"] / tool.D,
        "sigma1_mpa": top["sigma1_mpa"], "section": top["kind"],
        "hardness_published": bool(row["material"].get("hardness") and row_hb(row["material"]["hardness"])),
    }


def spread(vals):
    vals = sorted(vals)
    if not vals:
        return None
    q = statistics.quantiles(vals, n=4) if len(vals) >= 2 else [vals[0]] * 3
    return {"median": statistics.median(vals), "p25": q[0], "p75": q[2], "min": vals[0], "max": vals[-1]}


def build(rows_glob=None):
    machine = o.speedio_16k(TIR_IN)
    rows = []
    for path in sorted(glob.glob(rows_glob or os.path.join(ROOT, "tests", "benchmarks", "v2", "*.json"))):
        with open(path, encoding="utf-8") as fh:
            rows += [r for r in json.load(fh)["rows"] if r["operation"] in OPERATIONS]
    evaluated = [evaluate_row(r, machine) for r in rows]
    done = [e for e in evaluated if "skipped" not in e]
    bands = []
    for name, lo, hi in BANDS:
        sel = [e for e in done if lo <= e["D"] < hi]
        if not sel:
            continue
        ph = [e for e in sel if e["family"].startswith("Stainless - PH")]
        d, s = spread([e["deflection_over_D"] for e in sel]), spread([e["sigma1_mpa"] for e in sel])
        bands.append({
            "band": name, "d_min": lo, "d_max": hi if hi != math.inf else 1e9, "n": len(sel),
            "deflection_over_D": d["median"], "sigma1_mpa": s["median"],
            "deflection_over_D_spread": d, "sigma1_spread": s,
            "lateral_mean_n_spread": spread([e["lateral_mean_n"] for e in sel]),
            "ph_17_4": {"n": len(ph), "deflection_over_D": spread([e["deflection_over_D"] for e in ph]),
                        "sigma1_mpa": spread([e["sigma1_mpa"] for e in ph])} if ph else None,
        })
    return {
        "status": "PROVISIONAL (user decision 2026-10-16); calibration (design §6 step 4) refines it",
        "generated_by": "tools/v2_provisional_limits.py", "date": datetime.date.today().isoformat(),
        "quantities": {"deflection_over_D": "largest tip deflection over a revolution, load at its centroid, / D",
                       "sigma1_mpa": "largest principal stress at flute root (core circle), steps, holder face"},
        "assumptions": [
            "material: family's Sandvik row nearest the row hardness, ×(HB/HB_ref)^p; 17-4 PH P5.0.Z.AN p 0.41",
            "stickout: published reach (LB) or LCF, plus one shank diameter",
            "runout: 0.0002\" TIR, eccentric model at its worst phase",
            "force model placeholders as physics_v2/optimize.py (K_r 0.4, tool factor 1.0)",
            "ap capped at LCF; SFM and fz nominal, else the middle of the range; helix 35° when unpublished",
        ],
        "bands": bands,
        "skipped": [e for e in evaluated if "skipped" in e],
        "rows": done,
    }


def main():
    out = build()
    path = os.path.join(ROOT, "data", "model_v2", "provisional_limits.json")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=1, ensure_ascii=False)
        fh.write("\n")
    for b in out["bands"]:
        d, s = b["deflection_over_D_spread"], b["sigma1_spread"]
        print(f"{b['band']:10} n {b['n']:3}  δ/D median {d['median']:.5f} (IQR {d['p25']:.5f}–{d['p75']:.5f}, "
              f"{d['min']:.5f}–{d['max']:.5f})  σ1 median {s['median']:5.0f} MPa (IQR {s['p25']:.0f}–{s['p75']:.0f}, "
              f"{s['min']:.0f}–{s['max']:.0f})")
    print(f"skipped {len(out['skipped'])}: {sorted({e['skipped'] for e in out['skipped']})}")
    print(f"wrote {path}")


if __name__ == "__main__":
    main()
