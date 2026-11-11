#!/usr/bin/env python3
"""Build ``data/tool_series_performance.json`` from the v2 vendor benchmark rows.

For every bucket (material group, operation slot/side/hem/rough/finish, diameter band) the script
computes each row's material removal rate

    MRR [in^3/min] = ap [in] x ae [in] x fz [in/tooth] x flutes x rpm,   rpm = SFM x 12 / (pi x DC)

(nominal SFM and fz, or the mid-point of a published min/max), the bucket median over all rows,
and the median per tool series.  A series is recommended when its median MRR is at least
``GAIN_MIN`` (1.3) x the bucket median and at least ``MIN_ROWS`` (2) of its rows are in the bucket.

The output is deterministic (sorted keys, no timestamps).  Run from the repo root:

    python tools/build_tool_series_performance.py

The published values are the vendors' own recommendations, so a "gain" here means "the vendor
publishes a more aggressive recommendation for this series", not an independent test result.
"""
from __future__ import annotations

import glob
import json
import math
import os
import re
import statistics
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)
from toolwiz_common import tooling_advisor as _advisor  # noqa: E402
BENCH_GLOB = os.path.join(ROOT, "tests", "benchmarks", "v2", "*.json")
OUT_PATH = os.path.join(ROOT, "data", "tool_series_performance.json")

GAIN_MIN = 1.3
MIN_ROWS = 2
MIN_BUCKET_ROWS = 5          # rows in a bucket before a median means anything
MIN_BUCKET_GROUPS = 2        # vendor groups in a bucket
OPERATIONS = ("slot", "side", "hem", "rough", "finish")
EPS = 1e-6


def diameter_band(dc_in: float) -> str:
    """Diameter band label for a cutter diameter in inches (shared with the advisor)."""
    return _advisor.diameter_band(dc_in)


def material_group(family: str, hardness: dict | None) -> str | None:
    """Material group of a benchmark row (shared with the advisor); steels >= 45 HRC are 'hardened'."""
    return _advisor.material_group(family, hardness)


def _mid(spec: dict | None) -> float | None:
    if not spec:
        return None
    if spec.get("nominal") is not None:
        return float(spec["nominal"])
    lo, hi = spec.get("min"), spec.get("max")
    if lo is not None and hi is not None:
        return (float(lo) + float(hi)) / 2.0
    return None


def row_mrr(row: dict) -> float | None:
    """Material removal rate of a benchmark row in in^3/min, or None when a factor is missing."""
    cut, tool = row["cut"], row["tool"]
    sfm, fz = _mid(cut.get("sfm")), _mid(cut.get("fz"))
    ap, ae, z, dc = cut.get("ap"), cut.get("ae"), tool.get("flutes"), tool.get("DC")
    if None in (sfm, fz, ap, ae, z, dc) or dc <= 0:
        return None
    rpm = sfm * 12.0 / (math.pi * dc)
    return float(ap) * float(ae) * fz * z * rpm


def series_label(vendor: str, row: dict, docs: dict) -> str:
    """Readable series name: the vendor's product-line name where the row's series is only a part-number list."""
    series = (row["tool"].get("series") or "").strip()
    title = docs.get(row["source"].get("doc_id"), "")
    if vendor.startswith("Harvey Tool"):
        t = re.sub(r"^Speeds & Feeds:\s*", "", title)
        t = t.split(" (")[0].strip()
        return f"{t}, {row['tool'].get('flutes')} flute" if t else series
    if vendor.startswith("OSG"):
        t = re.split(r"\s+(?:Lists?\b|Tech\b|technical\b|Standard Carbide)", title)[0].strip()
        t = re.sub(r"^OSG Tooling Solutions Product Catalog.*?:\s*", "", t)
        return f"{t} (list {series})" if t else series
    s = series.split(" (")[0]
    s = re.sub(r",\s*grade .*$", "", s)
    return s.strip()


def load_rows() -> list[dict]:
    """Load every non-ramp benchmark row with its vendor and derived MRR fields."""
    out = []
    for path in sorted(glob.glob(BENCH_GLOB)):
        with open(path, encoding="utf-8") as fh:
            d = json.load(fh)
        docs = {x["doc_id"]: x.get("title", "") for x in d.get("documents", [])}
        for r in d["rows"]:
            if r.get("operation") not in OPERATIONS:
                continue
            if str(r["tool"].get("end") or "").strip().lower() != "square":
                continue   # ball and bull-nose series are not compared with square-end buckets (the advisor has no end-form key yet)
            mrr = row_mrr(r)
            grp = material_group(r["material"].get("toolwiz_family"), r["material"].get("hardness"))
            if mrr is None or grp is None:
                continue
            out.append({
                "id": r["id"], "vendor": d["vendor"], "vendor_group": d["vendor_group"],
                "series": series_label(d["vendor"], r, docs), "op": r["operation"], "group": grp,
                "band": diameter_band(r["tool"]["DC"]), "mrr": mrr,
                "flutes": r["tool"].get("flutes"), "coating": r["tool"].get("coating")})
    return out


def build() -> dict:
    """Return the full performance document (buckets keyed ``group|operation|band``)."""
    rows = load_rows()
    buckets: dict[str, list[dict]] = {}
    for r in rows:
        buckets.setdefault(f"{r['group']}|{r['op']}|{r['band']}", []).append(r)
    result = {}
    for key in sorted(buckets):
        rs = buckets[key]
        if len(rs) < MIN_BUCKET_ROWS or len({r["vendor_group"] for r in rs}) < MIN_BUCKET_GROUPS:
            continue
        bmed = statistics.median(r["mrr"] for r in rs)
        by_series: dict[tuple, list[dict]] = {}
        for r in rs:
            by_series.setdefault((r["vendor"], r["series"]), []).append(r)
        entries = []
        for (vendor, series), srs in sorted(by_series.items()):
            if len(srs) < MIN_ROWS:
                continue
            smed = statistics.median(r["mrr"] for r in srs)
            gain = smed / bmed if bmed > 0 else 0.0
            if gain < GAIN_MIN:
                continue
            srs_sorted = sorted(srs, key=lambda r: (-r["mrr"], r["id"]))
            fl = sorted({r["flutes"] for r in srs if r["flutes"]})
            coat = sorted({str(r["coating"]) for r in srs if r["coating"]})
            entries.append({
                "vendor": vendor, "vendor_group": srs[0]["vendor_group"], "series": series,
                "rows": len(srs), "median_mrr_in3_min": round(smed, 5),
                "gain_vs_bucket_median": round(gain, 3),
                "flutes": fl, "coatings": coat,
                "evidence": [r["id"] for r in srs_sorted[:6]]})
        entries.sort(key=lambda e: (-e["gain_vs_bucket_median"], -e["rows"], e["vendor"], e["series"]))
        result[key] = {"bucket_rows": len(rs), "bucket_median_mrr_in3_min": round(bmed, 5),
                       "vendor_groups": sorted({r["vendor_group"] for r in rs}),
                       "recommended": entries[:8]}
    return {
        "description": "Series whose median published MRR (ap x ae x fz x flutes x rpm) is >= 1.3 x the "
                       "bucket median over all vendors, with >= 2 supporting rows. Generated by "
                       "tools/build_tool_series_performance.py from tests/benchmarks/v2/*.json.",
        "gain_min": GAIN_MIN, "min_rows": MIN_ROWS, "min_bucket_rows": MIN_BUCKET_ROWS,
        "bands": [b for b, _ in _advisor.DIAMETER_BANDS], "buckets": result}


def main() -> int:
    doc = build()
    with open(OUT_PATH, "w", encoding="utf-8", newline="\n") as fh:
        json.dump(doc, fh, indent=1, sort_keys=True)
        fh.write("\n")
    n = sum(len(b["recommended"]) for b in doc["buckets"].values())
    print(f"wrote {OUT_PATH}: {len(doc['buckets'])} buckets, {n} recommendations")
    return 0


if __name__ == "__main__":
    sys.exit(main())
