"""Calibrate C15 (chip space) from the vendor benchmark rows and write data/model_v2/chip_space.json.

For every published square-end full slot (ae ≥ 0.95·D, ap, ae and fz given) in tests/benchmarks/v2/*.json the
gullet-to-chip area ratio S = A_g(D, z) / (fz·ae) is computed with the geometry below and normalised by the depth
factor (physics_v2/chipspace.py); K of a material group is the smallest normalised S any vendor publishes (the
most packed slot in the data), so at aggressiveness 1 no published slot is outside the limit.

    python3 tools/calibrate_chip_space.py           # write the file
    python3 tools/calibrate_chip_space.py --check   # exit 1 if the file differs from a fresh calibration
    python3 tools/calibrate_chip_space.py --table   # print the slot data by material group and flute count

Sources and engineering estimates are named in the file (`source`, `basis`) and in docs/research/chip_space.md.
"""
import argparse
import collections
import glob
import json
import math
import os
import statistics
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)

from physics_v2 import chipspace  # noqa: E402
from physics_v2.optimize import material_group  # noqa: E402

OUT = chipspace.CHIP_SPACE_PATH
GROUPS = ("non-ferrous", "steel", "stainless", "Ti-Ni-Co")

GEOMETRY = {
    "version": "2026-11-12",
    "core_ratio_by_flutes": {
        "1": 0.50, "2": 0.55, "3": 0.58, "4": 0.60, "5": 0.64, "6": 0.66, "7": 0.70, "8": 0.72,
        "_source": ("Design values (not measured): 2-3 flutes 50-65 % (EP 1 072 345), 40-55 % (US 11,554,426), >= 60 % "
                    "high-load (US 10,335,870); 4 flutes ~60 % (Mitsubishi 'Web thickness'), >= 58 %; 5 flutes >= 61-64 %, "
                    "6 flutes >= 63-65 % (US 10,335,870); 7 flutes flute depth 10-20 % of D, i.e. a 60-80 % core "
                    "(CA 3 000 831 C, 7 teeth 'the most preferred ... taking into account flute space'); 5-8 flutes finishing "
                    "75-85 % (EP 1 072 345). docs/research/carbide_and_edge_radius.md §5, docs/research/chip_space.md §2"),
    },
    "void_fraction": {
        "value": 0.55,
        "source": ("Engineering estimate: the share of the core-to-OD annulus that is open gullet rather than tooth body. "
                   "It multiplies every flute count alike, so it cancels in the calibration of K (only the ratio between "
                   "flute counts, set by the core table, matters)"),
    },
    "depth": {
        "enclosed_ae_over_D": {"value": 0.95, "source": "a full slot: no open side for the chip to leave by"},
        "a0_over_D": {"value": 0.5, "source": ("engineering estimate: up to D/2 the chip clears the slot within the "
                                                "half revolution the tooth is enclosed (flute advance along a 30-45° helix)")},
        "k_d": {"value": 0.5, "source": ("engineering estimate, checked on the vendor slots: with k_d 0.5 the 2-flute "
                                          "slots at 0.6·D (OSG) and 3-flute slots at 1·D (YG-1, OSG, Helical) in aluminium "
                                          "fall on the same normalised packing (5.7-6.4); k_d 0 and 1 give 6.0 / 5.3 for "
                                          "the group minimum (sensitivity in docs/research/chip_space.md). Sandvik: reduce "
                                          "full-slot ap to ~70 % of the edge length and use compressed air against chip "
                                          "congestion")},
    },
    "aggressiveness": {
        "basis": ("u_limit(a) = consensus_scale(a) / consensus_scale(1) (optimize.CONSENSUS_SCALE_POINTS): 1.0 at "
                  "aggressiveness 1 (the most packed published slot), 0.84 at 50 %, 0.69 at 0. The same margin the "
                  "engine keeps on its other vendor-anchored limit, C2, because K and the gullet geometry are uncertain "
                  "(design values, one void fraction, no measured chip packing)"),
    },
    "fallback_group": "steel",
}


def load_rows():
    rows = []
    for f in sorted(glob.glob(os.path.join(ROOT, "tests", "benchmarks", "v2", "*.json"))):
        with open(f, encoding="utf-8") as fh:
            d = json.load(fh)
        for r in d["rows"]:
            rows.append(dict(r, _vendor=d["vendor"], _file=os.path.basename(f)))
    return rows


def fz_of(r):
    z = r["cut"]["fz"]
    return z.get("nominal") or z.get("max") or z.get("min")


def slot_rows(rows, p):
    out = []
    enc = p["depth"]["enclosed_ae_over_D"]["value"]
    for r in rows:
        t, c = r["tool"], r["cut"]
        if t.get("end") != "square" or not t.get("DC") or not t.get("flutes"):
            continue
        D, ae, ap, f = float(t["DC"]), c.get("ae"), c.get("ap"), fz_of(r)
        if not (ae and ap and f) or ae < enc * D:
            continue
        z = int(t["flutes"])
        core = chipspace.core_ratio(z, p["core_ratio_by_flutes"])
        S = chipspace.gullet_area(D, z, core, p["void_fraction"]["value"]) / chipspace.chip_area(f, ae, D)
        e = chipspace.depth_factor(ap, ae, D, p)
        out.append({"id": r["id"], "vendor": r["_vendor"], "group": material_group(r["material"].get("toolwiz_family")),
                    "family": r["material"].get("toolwiz_family"), "z": z, "D": D, "ap_over_D": ap / D,
                    "fz_over_D": f / D, "S": S, "K_row": S / e})
    return out


def calibrate():
    p = json.loads(json.dumps(GEOMETRY))
    sl = slot_rows(load_rows(), p)
    packing = {}
    for g in GROUPS:
        v = sorted((x for x in sl if x["group"] == g), key=lambda x: x["K_row"])
        ks = [x["K_row"] for x in v]
        lo = v[0]
        packing[g] = {
            "K": math.floor(lo["K_row"] * 1000.0) / 1000.0,   # rounded down: the row itself stays inside the limit
            "basis": (f"most packed published full slot: {lo['id']} ({lo['vendor']}, {lo['z']} flutes, D {lo['D']:g}\", "
                      f"ap {lo['ap_over_D']:.2f}·D, fz {lo['fz_over_D']:.4f}·D)"),
            "n_slot_rows": len(v), "p10": round(ks[len(ks) // 10], 3), "median": round(statistics.median(ks), 3),
            "lowest_rows": [x["id"] for x in v[:5]],
        }
    p["packing"] = packing
    p["calibration"] = ("tools/calibrate_chip_space.py: K = the smallest A_g/(fz·ae)/depth_factor over the group's "
                        "square-end full-slot rows of tests/benchmarks/v2/*.json")
    return p, sl


def table(sl):
    """(group, flutes) -> published slot rows: n, vendors, median and max ap/D and fz/D, median S."""
    out = collections.defaultdict(list)
    for x in sl:
        out[(x["group"], x["z"])].append(x)
    lines = []
    for (g, z), v in sorted(out.items()):
        ap = sorted(x["ap_over_D"] for x in v)
        fz = sorted(x["fz_over_D"] for x in v)
        S = sorted(x["S"] for x in v)
        vend = collections.Counter(x["vendor"] for x in v)
        lines.append(f"| {g} | {z} | {len(v)} | {', '.join(f'{k} {n}' for k, n in sorted(vend.items()))} | "
                     f"{statistics.median(ap):.2f} / {ap[-1]:.2f} | {statistics.median(fz):.4f} / {fz[-1]:.4f} | "
                     f"{S[0]:.1f} / {statistics.median(S):.1f} |")
    return lines


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--table", action="store_true")
    a = ap.parse_args()
    p, sl = calibrate()
    if a.table:
        print("| group | flutes | slot rows | vendors | ap/D median / max | fz/D median / max | S min / median |")
        print("|---|---|---|---|---|---|---|")
        print("\n".join(table(sl)))
        return 0
    text = json.dumps(p, indent=1, ensure_ascii=False) + "\n"
    if a.check:
        with open(OUT, encoding="utf-8") as fh:
            same = fh.read() == text
        print("chip_space.json is current" if same else "chip_space.json differs from a fresh calibration")
        return 0 if same else 1
    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write(text)
    for g, v in p["packing"].items():
        print(f"{g:12s} K {v['K']:.3f} (p10 {v['p10']:.2f}, median {v['median']:.2f}, n {v['n_slot_rows']}): {v['basis']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
