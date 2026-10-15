"""Coverage report for the v2 benchmark dataset (design §4.2).

Prints, for each target material x diameter x operation cell, how many independent vendor
groups have a row. Harvey Tool and Helical share a vendor group, so they count once.

    python tools\v2_coverage.py            (Markdown table to stdout)
"""
import glob
import json
import math
import os
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
V2_DIR = os.path.join(ROOT, "tests", "benchmarks", "v2")

DIAMETERS = [("1/64", 1 / 64), ("1/32", 1 / 32), ("1/16", 1 / 16), ("1/8", 1 / 8),
             ("1/4", 1 / 4), ("1/2", 1 / 2), ("1", 1.0)]
MATERIALS = [
    ("6061", {"Aluminum - Wrought (6061)"}),
    ("1018/1045", {"Steel - Low Carbon (1020)", "Steel - Medium Carbon (1045)"}),
    ("4140", {"Steel - Medium Carbon Alloy (4130)"}),
    ("17-4 PH", {"Stainless - PH Series (17-4)"}),
    ("316", {"Stainless - 300 Series (316)"}),
    ("Ti-6Al-4V", {"Titanium Alloy"}),
    ("H13 45-50", {"Steel - Tool (H13)"}),
    ("Inconel 718", {"High Temp Nickel Alloy"}),
]
OPERATIONS = [("slot", {"slot"}), ("side/rough", {"side", "rough"}), ("hem", {"hem"}), ("finish", {"finish"})]


def diameter_band(dc):
    """Nearest target diameter on a log scale, or None if more than ~25% away."""
    label, target = min(DIAMETERS, key=lambda d: abs(math.log(dc / d[1])))
    return label if abs(math.log(dc / target)) < 0.23 else None


def load_rows():
    rows = []
    for path in sorted(glob.glob(os.path.join(V2_DIR, "*.json"))):
        with open(path, encoding="utf-8") as fh:
            data = json.load(fh)
        for row in data.get("rows", []):
            rows.append((data["vendor_group"], row))
    return rows


def coverage(rows):
    cells = defaultdict(set)
    for group, row in rows:
        band = diameter_band(row["tool"]["DC"])
        family = row["material"]["toolwiz_family"]
        if family == "Steel - Tool (H13)":
            hard = row["material"].get("hardness") or {}
            if (hard.get("scale") or "").upper() != "HRC" or (hard.get("max") or 0) < 45 or (hard.get("min") or 99) > 52:
                continue
        for mlabel, fams in MATERIALS:
            if family not in fams:
                continue
            for olabel, ops in OPERATIONS:
                if row["operation"] in ops and band:
                    cells[(mlabel, band, olabel)].add(group)
    return cells


def main(out=sys.stdout):
    rows = load_rows()
    cells = coverage(rows)
    derived = sum(1 for _, r in rows if r["source"].get("derivation"))
    out.write(f"{len(rows)} rows ({derived} derived by a vendor rule). Each cell: number of independent vendor groups (target 2).\n\n")
    for olabel, _ in OPERATIONS:
        out.write(f"### {olabel}\n\n| Material | " + " | ".join(d for d, _ in DIAMETERS) + " |\n")
        out.write("|---|" + "---|" * len(DIAMETERS) + "\n")
        for mlabel, _ in MATERIALS:
            vals = [str(len(cells.get((mlabel, d, olabel), ()))) for d, _ in DIAMETERS]
            out.write(f"| {mlabel} | " + " | ".join(vals) + " |\n")
        out.write("\n")
    full = sum(1 for v in cells.values() if len(v) >= 2)
    total = len(MATERIALS) * len(DIAMETERS) * len(OPERATIONS)
    out.write(f"Cells with two or more vendor groups: {full} of {total}.\n")


if __name__ == "__main__":
    main()
