"""Build data/model_v2/consensus_by_vendor.json: the C14 vendor guardrail per vendor (owner decisions 2026-11-12).

For every benchmark vendor (the file names of tests/benchmarks/v2/*.json; harvey_ball_cr.json counts as harvey and
osg_ball.json as osg) and every bucket (family, 50-HB bin, diameter band, chart class, engagement class), the rows'
values as [lo, nominal, hi] triples of SFM, fz/D and the feed per flute fz·n (in/min, C14m's MRR per unit engaged area
and per flute). The rows are the ones tools/calibrate_v2.py uses for data/model_v2/consensus.json (square end, complete
geometry, a family with a Kienzle mapping), with the same bands, engagement classes and hardness bins, so the
cross-vendor section below reproduces consensus.json's medians.

Chart classes keep the vendors' own operation labels: hem, rough (traditional roughing), side (side milling /
profiling), slot, finish. HEM and roughing never share a cell. The cross-vendor section ("consensus") keeps
consensus.json's classes (rough and side rows pooled as "side"; HEM separate) and its vendor groups.

lo / hi of a row: the smallest and largest of its published min, nominal and max. A value published as a single number
(Harvey, Helical, Emuge, Sandvik, Titan and YG-1 publish one value; others publish SFM ranges but one chip load) gets
the default spread SINGLE_VALUE_SPREAD around it: 0.76x to 1.10x, the old consensus aggressiveness anchors at 0 % and
100 % (vendors' lower quartile; "may be increased 10-20 %", low end). The feed per flute's lo / hi multiply the lo / hi of
SFM and chip load.

Usage: python3 tools/build_vendor_consensus.py [--check]   (--check: compare the medians with consensus.json)
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

import calibrate_v2 as cv  # noqa: E402
import v2_provisional_limits as pl  # noqa: E402
from physics_v2 import optimize as o  # noqa: E402
from toolwiz_common import brand  # noqa: E402

OUT = os.path.join(ROOT, "data", "model_v2", "consensus_by_vendor.json")
VERSION = "2026-11-12.1"
SINGLE_VALUE_SPREAD = (0.76, 1.10)
CHART_CLASS = {"slot": "slot", "side": "side", "rough": "rough", "hem": "hem", "finish": "finish"}
FILE_VENDOR = {"harvey_ball_cr": "harvey", "osg_ball": "osg"}


def triple(v):
    """(lo, nominal, hi) of a published value block; one number -> the default spread around it."""
    nom = pl.nominal(v)
    if nom is None:
        return None
    vals = [float(x) for x in (v.get("min"), v.get("nominal"), v.get("max")) if x is not None] if isinstance(v, dict) else [nom]
    lo, hi = min(vals), max(vals)
    if hi <= lo * (1 + 1e-9):
        lo, hi = SINGLE_VALUE_SPREAD[0] * nom, SINGLE_VALUE_SPREAD[1] * nom
    return lo, nom, hi


def vendor_rows():
    """(vendor key, vendor group, row) for every row of the benchmark files except ramps."""
    out = []
    for path in sorted(glob.glob(os.path.join(ROOT, "tests", "benchmarks", "v2", "*.json"))):
        stem = os.path.basename(path)[:-5]
        key = FILE_VENDOR.get(stem, stem)
        with open(path, encoding="utf-8") as fh:
            d = json.load(fh)
        for r in d["rows"]:
            if r["operation"] != "ramp":
                out.append((key, d["vendor_group"], r))
    return out


def row_entry(row):
    """(family, hb, D, ae/D, values) for a row in scope, else None (calibrate_v2.evaluate's filters)."""
    if row["tool"].get("end") != "square" or pl.missing_geometry(row):
        return None
    mat, info = cv.row_material(row)
    if mat is None:
        return None
    tool, _ = pl.row_tool(row)
    c = row["cut"]
    ae = min(float(c["ae"]), tool.D)
    s, f = triple(c["sfm"]), triple(c["fz"])
    if s is None or f is None:
        return None
    D = tool.D
    fzd = [x / D for x in f]
    ffpf = [f[i] * 12.0 * s[i] / (math.pi * D) for i in range(3)]
    return info["family"], info["hb"], D, ae / D, [round(x, 7) for x in (*s, *fzd, *ffpf, ae / D)]


def cell_key(family, hb, D, ae_over_D, cls):
    return "|".join((family, str(int(hb // cv.HB_BIN)), cv.band_of(D), cls,
                     o.engagement_class(ae_over_D, cv.ENGAGEMENT_CLASSES)))


def build():
    vendors = {k: {"name": brand.display_name(k), "vendor_group": None, "cells": collections.defaultdict(list), "rows": 0}
               for k in brand.VENDORS}
    cons = collections.defaultdict(lambda: collections.defaultdict(list))
    skipped = collections.Counter()
    for key, group, row in vendor_rows():
        e = row_entry(row)
        if e is None:
            skipped[key] += 1
            continue
        fam, hb, D, aeD, vals = e
        v = vendors[key]
        v["vendor_group"] = group
        v["cells"][cell_key(fam, hb, D, aeD, CHART_CLASS[row["operation"]])].append(vals)
        v["rows"] += 1
        cons[cell_key(fam, hb, D, aeD, cv.OPERATION_CLASS[row["operation"]])][group].append(vals)
    for v in vendors.values():
        v["cells"] = dict(v["cells"])
        v["chart_classes"] = dict(collections.Counter(k.split("|")[3] for k, rows in v["cells"].items() for _ in rows))
    return {
        "version": VERSION, "generated_by": "tools/build_vendor_consensus.py",
        "status": "C14 per vendor (owner decisions 2026-11-12: brand first; unbranded default Helical HEM, Harvey + Helical "
                  "otherwise; then the cross-vendor consensus; 50 % = middle of the vendor's range, 0 % its bottom, 100 % its top)",
        "source": "tests/benchmarks/v2 square-end rows on their own catalog geometry (the rows of data/model_v2/consensus.json)",
        "fields": ["sfm_lo", "sfm", "sfm_hi", "fz_over_D_lo", "fz_over_D", "fz_over_D_hi",
                   "feed_per_flute_ipm_lo", "feed_per_flute_ipm", "feed_per_flute_ipm_hi", "ae_over_D"],
        "single_value_spread": list(SINGLE_VALUE_SPREAD),
        "single_value_basis": "a value published as one number spans 0.76x-1.10x of it (the former consensus anchors at "
                              "0 % and 100 %: vendors' lower quartile, and 'may be increased 10-20 %', low end)",
        "bands": [{"band": n, "d_min": lo, "d_max": hi if hi != math.inf else 1e9} for n, lo, hi in cv.BANDS],
        "engagement_classes": [[n, lo, hi] for n, lo, hi in cv.ENGAGEMENT_CLASSES],
        "hb_bin": cv.HB_BIN,
        "min_vendor_groups": o.CONSENSUS_MIN_GROUPS,
        "vendors": vendors,
        "consensus": {"cells": {k: dict(v) for k, v in cons.items()},
                      "classes": "consensus.json's: rough and side rows pooled as side; hem, slot, finish separate"},
        "skipped_rows": dict(skipped),
    }


def check(table):
    """The cross-vendor medians against consensus.json (same rows, same buckets): returns the mismatches."""
    old = o.load_consensus(o.CONSENSUS_DEFAULT_PATH)["cells"]
    bad = []
    for key, groups in table["consensus"]["cells"].items():
        if key not in old:
            bad.append((key, "missing in consensus.json"))
            continue
        for g, rows in groups.items():
            a = sorted(r[1] for r in rows)
            b = sorted(r[0] for r in old[key].get(g, []))
            if len(a) != len(b) or any(abs(x - y) > 1e-3 * max(1.0, y) for x, y in zip(a, b)):
                bad.append((key, g))
    bad += [(k, "missing here") for k in old if k not in table["consensus"]["cells"]]
    return bad


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--check", action="store_true", help="compare the cross-vendor medians with consensus.json")
    args = ap.parse_args(argv)
    table = build()
    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump(table, fh, separators=(",", ":"))
        fh.write("\n")
    for k, v in table["vendors"].items():
        print(f"  {k:12} {v['rows']:5} rows, {len(v['cells']):4} cells, classes {v['chart_classes']}")
    print(f"consensus cells {len(table['consensus']['cells'])}; skipped {table['skipped_rows']}; wrote {OUT}")
    if args.check:
        bad = check(table)
        print(f"check against consensus.json: {len(bad)} mismatches" + "".join(f"\n    {b}" for b in bad[:20]))
        return 1 if bad else 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
