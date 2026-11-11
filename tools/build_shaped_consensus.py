"""C14 vendor consensus for ball and bull-nose (corner-radius) end mills (V4).

Same buckets as data/model_v2/consensus.json (family, 50-HB bin, diameter band, operation class, engagement class; each vendor
group's rows, medians per group, then over groups: physics_v2.optimize.consensus_lookup), but built from the rows of one end form
only: `tool.end` "ball" -> table "ball"; "corner_radius" (legacy spelling "corner radius") with a corner radius of at least 1 % of D
-> "bull". Square-end rows (and square rows with an edge-break radius) never enter. Row values are [SFM, fz/D, fz*n (in/min),
MRR/D^3] on the row's own catalog diameter; SFM is the vendor's (nominal diameter) value. No physics is evaluated, so this runs in seconds.

Writes data/model_v2/consensus_shaped.json: {"ball": table, "bull": table}. Run from the repo root: python tools/build_shaped_consensus.py
"""
import collections
import datetime
import json
import math
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
for p in (ROOT, os.path.join(ROOT, "tools")):
    if p not in sys.path:
        sys.path.insert(0, p)

import calibrate_v2 as cal  # noqa: E402
import v2_provisional_limits as pl  # noqa: E402
from physics_v2 import optimize as o  # noqa: E402

OUT = os.path.join(ROOT, "data", "model_v2", "consensus_shaped.json")
OPERATIONS = ("slot", "side", "rough", "hem", "finish")
EDGE_BREAK_OVER_D = 0.01


def form_of(row):
    """'ball', 'bull' or None (square end, edge break, or an unknown end) for a benchmark row."""
    end = pl.end_of(row)
    t = row["tool"]
    if end == "ball":
        return "ball"
    if end == "corner_radius" and float(t.get("corner_radius") or 0.0) >= EDGE_BREAK_OVER_D * float(t.get("DC") or 1.0):
        return "bull"
    return None


def evaluated(row):
    """The consensus fields of a row, or None when it lacks geometry, a material mapping or a hardness."""
    if pl.missing_geometry(row):
        return None
    fam = row["material"].get("toolwiz_family")
    mat, info = cal.row_material(row)
    if mat is None:
        return None
    t, c = row["tool"], row["cut"]
    D = float(t["DC"])
    sfm, fz = pl.nominal(c["sfm"]), pl.nominal(c["fz"])
    ap, ae = min(float(c["ap"]), float(t["LCF"])), min(float(c["ae"]), D)
    rpm = 12.0 * sfm / (math.pi * D)
    z = int(t["flutes"])
    return {"family": fam, "hb": info["hb"], "D": D, "band": cal.band_of(D), "operation": row["operation"],
            "ae_over_D": ae / D, "sfm": sfm, "fz": fz, "mrr": ap * ae * fz * z * rpm}


def main():
    tables = {}
    for form in ("ball", "bull"):
        cells = collections.defaultdict(lambda: collections.defaultdict(list))
        n = 0
        for r in cal.load_rows():
            if r["operation"] not in OPERATIONS or form_of(r) != form:
                continue
            e = evaluated(r)
            if e is None:
                continue
            n += 1
            e["vendor_group"] = r["_vendor_group"]
            e["operation"] = r["operation"]
            cells[cal.cell_key(e)][e["vendor_group"]].append(
                [e["sfm"], e["fz"] / e["D"], e["fz"] * 12.0 * e["sfm"] / (math.pi * e["D"]), e["mrr"] / e["D"] ** 3])
        t = cal.build_consensus([])
        t.update(cells={k: dict(v) for k, v in cells.items()}, form=form, n_rows=n,
                 status=f"C14 vendor consensus for {form}-nose end mills (V4)", date=datetime.date.today().isoformat(),
                 generated_by="tools/build_shaped_consensus.py",
                 source=f"tests/benchmarks/v2 rows with end {'ball' if form == 'ball' else 'corner_radius (R >= 1 % of D)'}; "
                        + "SFM is the vendor's nominal-diameter value")
        tables[form] = t
        print(f"{form}: {n} rows, {len(cells)} cells")
    with open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        json.dump(tables, fh, indent=1, sort_keys=True, ensure_ascii=True)
        fh.write("\n")
    print("wrote", OUT)


if __name__ == "__main__":
    main()
