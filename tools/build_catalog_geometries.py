#!/usr/bin/env python3
"""Build ``data/model_v2/catalog_geometries.json``: the real square-end carbide geometries in the v2 vendor benchmark rows.

The tool recommender (``tool_recommender.py``) needs flute counts and flute lengths that exist at a diameter for a vendor,
a material and an operation. The benchmark rows cite them from the vendors' catalog pages (``tool.series``, ``tool.flutes``,
``tool.DC``, ``tool.LCF``, ``tool.SFDM``, coating, part number). One entry per distinct (vendor, family, operation, series,
flutes, DC, LCF); ball and corner-radius files are left out because ToolWiz applies vendor charts to square-end tools only.

The output is deterministic (sorted, no timestamps). From the repo root:

    python tools/build_catalog_geometries.py            # write
    python tools/build_catalog_geometries.py --check    # exit 1 when the file is stale
"""
from __future__ import annotations

import glob
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BENCH_GLOB = os.path.join(ROOT, "tests", "benchmarks", "v2", "*.json")
OUT_PATH = os.path.join(ROOT, "data", "model_v2", "catalog_geometries.json")
FIELDS = ["vendor", "family", "op", "series", "flutes", "dc", "lcf", "shank", "coating", "part_number", "row_id", "doc_id"]


def build():
    seen, out = set(), []
    for path in sorted(glob.glob(BENCH_GLOB)):
        vendor = os.path.basename(path)[:-5]
        if "ball" in vendor:
            continue
        with open(path, encoding="utf-8") as fh:
            rows = json.load(fh).get("rows", [])
        for r in rows:
            t, m = r.get("tool") or {}, r.get("material") or {}
            if t.get("end") != "square" or t.get("tool_material") not in (None, "carbide"):
                continue
            dc, z, fam, op = t.get("DC"), t.get("flutes"), m.get("toolwiz_family"), r.get("operation")
            if not (dc and z and fam and op):
                continue
            key = (vendor, fam, op, t.get("series"), int(z), float(dc), t.get("LCF"))
            if key in seen:
                continue
            seen.add(key)
            out.append([vendor, fam, op, t.get("series"), int(z), float(dc), t.get("LCF"), t.get("SFDM"), t.get("coating"),
                        t.get("part_number"), r.get("id"), (r.get("source") or {}).get("doc_id")])
    out.sort(key=lambda e: tuple("" if v is None else str(v).zfill(9) if isinstance(v, (int, float)) else str(v) for v in e[:7]))
    return {"version": "2026-11-12.1", "generated_by": "tools/build_catalog_geometries.py",
            "source": "tests/benchmarks/v2 square-end carbide rows (catalog geometry of the cited part number)",
            "fields": FIELDS, "rows": out}


def main(argv):
    text = json.dumps(build(), separators=(",", ":"), ensure_ascii=False) + "\n"
    if "--check" in argv:
        try:
            with open(OUT_PATH, encoding="utf-8") as fh:
                ok = fh.read() == text
        except OSError:
            ok = False
        print("catalog_geometries.json is up to date" if ok else "catalog_geometries.json is stale")
        return 0 if ok else 1
    with open(OUT_PATH, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(text)
    print(f"wrote {OUT_PATH} ({len(build()['rows'])} geometries)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
