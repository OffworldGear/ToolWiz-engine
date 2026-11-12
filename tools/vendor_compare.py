"""Per-vendor comparison: the v2 engine at 50 % against each vendor's own groups (hem, rough, side; square end).

Groups as in tests/test_vendor_conformance.py (family, operation, diameter band, engagement class), but per vendor file,
run at the group's median tool and engagement (machine test_generic_60k, runout 0.0001"). For each group: engine SFM and
fz against the vendor's typical value (median of the rows' nominal, else the middle of min/max) and its published maximum.

Usage (from the repo root; takes a few minutes):
    python3 tools/vendor_compare.py out.json            # unbranded (the request carries no brand)
    python3 tools/vendor_compare.py --brand out.json    # brand = each group's own vendor
Prints per vendor and operation the median engine/vendor ratios of SFM, fz and feed (SFM x fz), and how many groups are
above the vendor's published maximum SFM. The JSON holds one record per group.
"""
import argparse
import collections
import glob
import json
import os
import statistics
import sys
from concurrent.futures import ProcessPoolExecutor

sys.path.insert(0, os.getcwd())
sys.path.insert(0, os.path.join(os.getcwd(), "tests"))
os.environ["TOOLWIZ_MODEL"] = "v2"
import test_vendor_conformance as C  # noqa: E402
import app  # noqa: E402
from toolwiz_common import brand as brand_mod  # noqa: E402

FILE_VENDOR = {"harvey_ball_cr": "harvey", "osg_ball": "osg"}
OPS = ("hem", "rough", "side")


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


def groups():
    fams = set(app.physics.machinability)
    out = collections.defaultdict(list)
    for path in sorted(glob.glob(os.path.join(C.BENCH_DIR, "*.json"))):
        stem = os.path.basename(path)[:-5]
        vendor = FILE_VENDOR.get(stem, stem)
        for r in json.load(open(path))["rows"]:
            if C.in_scope(r, fams) and r["operation"] in OPS:
                out[(vendor,) + C.group_of(r)].append(r)
    return out


def summary(res):
    by = collections.defaultdict(list)
    for r in res:
        if r["ok"]:
            by[(r["vendor"], r["op"])].append(r)
    lines = [f"{'vendor':<12} {'op':<5} {'n':>3}  SFM ratio  fz ratio  feed ratio  above max SFM"]
    for (v, op), rs in sorted(by.items()):
        s = statistics.median(r["e_sfm"] / r["v_sfm"] for r in rs)
        f = statistics.median(r["e_fz"] / r["v_fz"] for r in rs)
        fe = statistics.median(r["e_sfm"] * r["e_fz"] / (r["v_sfm"] * r["v_fz"]) for r in rs)
        above = sum(r["e_sfm"] > r["v_sfm_max"] * 1.001 for r in rs)
        lines.append(f"{v:<12} {op:<5} {len(rs):>3}  {s:9.2f}  {f:8.2f}  {fe:10.2f}  {above:>3} of {len(rs)}")
    return "\n".join(lines)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("out", help="JSON file for the per-group records")
    ap.add_argument("--brand", action="store_true", help="run each group with brand = its own vendor")
    args = ap.parse_args(argv)
    g = groups()
    keys = sorted(g)
    jobs = [("engage", g[k], None, "square", brand_mod.display_name(k[0]) if args.brand else None) for k in keys]
    with ProcessPoolExecutor(max_workers=min(8, os.cpu_count() or 1)) as ex:
        outs = list(ex.map(C.run_job, jobs, chunksize=4))
    res = []
    for k, o in zip(keys, outs):
        rows = g[k]
        base = dict(vendor=k[0], family=k[1], op=k[2], band=k[3], eng=k[4], n=len(rows))
        if "error" in o or not o.get("feasible"):
            res.append(dict(base, ok=False, error=o.get("error"), limited=o.get("limited_by")))
            continue
        res.append(dict(base, ok=True, e_sfm=o["sfm"], v_sfm=vmid(rows, "sfm"), e_fz=o["fz"], v_fz=vmid(rows, "fz"),
                        v_sfm_max=C.span(rows, "sfm")[1], limited=o["limited_by"], basis=o.get("basis")))
    with open(args.out, "w") as fh:
        json.dump(res, fh)
    print(f"{len(res)} groups, {sum(r['ok'] for r in res)} with a v2 cut ({'branded' if args.brand else 'unbranded'})")
    print(summary(res))


if __name__ == "__main__":
    main()
