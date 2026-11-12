"""Fit the flute-count factor on the C2 chip limit from the vendor rows; write data/model_v2/chip_by_flutes.json.

C2 holds the chip to the vendor median nominal chip k·D of the tool's diameter band, pooled over every material and
flute count (data/model_v2/chip_limits.json). Vendors do not run every flute count at the same chip: in aluminium full
slots the published fz/D is about 0.018-0.025 for 2 flutes, 0.006-0.012 for 3 and 0.008-0.009 for 4 (owner decision
2026-11-12: make the chip load flute-aware, aluminium first). This tool measures, per material group, chart class and
flute count, how far the vendors' chip sits from C2's own band value:

    ratio(row) = (nominal chip of the row / D) / (C2's band value at the row's diameter)

with the nominal chip fz·sin(phi_e) (fz itself for ae >= D/2: every slot), the same quantity C2's nominal basis checks,
and C2's slot bands for slot rows, its side bands otherwise. The factor of a flute count is the median ratio of its rows
over the median ratio of the reference flute count (4: most of C2's rows are 4-flute tools, so a 4-flute tool keeps its
C2 limit):

    F(z) = median ratio(z) / median ratio(4)

A flute count is "charted" when it has at least MIN_ROWS rows from at least MIN_GROUPS independent vendor groups.
Between and at charted counts F is the measured value; below the lowest charted count F is held (no extrapolated
increase); above the highest, in full slots, it falls with the gullet area per flute (data/model_v2/chip_space.json's
core ratios: A_g ~ (1 - c_z^2)/z), i.e. the next flute counts keep the gullet fill of the highest charted count, which
is what the vendors do across the charted counts (docs/research/chip_space.md §1); in open-sided cuts (side, roughing,
HEM), where the chip leaves the gullet radially, it is held.

Rows: the square-end rows of tests/benchmarks/v2/*.json that build data/model_v2/consensus_by_vendor.json (complete
geometry, a family with a Kienzle mapping; tools/build_vendor_consensus.row_entry). Chart classes: slot; side (side
milling, profiling and traditional roughing pooled, as C14's cross-vendor table does); hem.

Which (group, class) pairs the engine applies is a decision recorded in APPLY with its reason; every other pair is
written for the record (`applied: false`, with the reason).

    python3 tools/fit_chip_by_flutes.py            # write the file
    python3 tools/fit_chip_by_flutes.py --check    # exit 1 if the file differs from a fresh fit
    python3 tools/fit_chip_by_flutes.py --table    # print the measured ratios
"""
import argparse
import collections
import json
import math
import os
import statistics
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)
sys.path.insert(0, os.path.join(ROOT, "tools"))

import build_vendor_consensus as bvc  # noqa: E402
from physics_v2 import chipspace, forces  # noqa: E402
from physics_v2 import optimize as o  # noqa: E402

OUT = os.path.join(ROOT, "data", "model_v2", "chip_by_flutes.json")
VERSION = "2026-11-12.1"
REFERENCE_FLUTES = 4
MIN_ROWS, MIN_GROUPS = 3, 2
MAX_FLUTES = 8
CLASS_OF = {"slot": "slot", "side": "side", "rough": "side", "hem": "hem"}
GROUPS = ("non-ferrous", "steel", "stainless", "Ti-Ni-Co", "hardened")
# Decision per (material group, class): applied or not, and why (owner decision 2026-11-12: aluminium first; other
# groups only where the rows clearly show a flute-count trend). Reasons are checked against the fitted numbers in
# docs/V4_ENGINE_NOTES.md ("Flute-aware chip load").
APPLY = {
    ("non-ferrous", "slot"): (True, "aluminium full slots: 2, 3 and 4 flutes charted by 2-4 vendor groups each; the chip "
                                    "falls with flute count (2 flutes about twice the 4-flute chip)"),
    ("non-ferrous", "side"): (True, "aluminium side milling and roughing: 3 and 4 flutes charted (2 flutes by 2 rows only, "
                                    "so held at the 3-flute factor); the 3-flute chip is above the 4-flute chip"),
    ("non-ferrous", "hem"): (False, "aluminium HEM: one vendor per flute count (YG-1 3FL, Seco 4FL, Helical 5FL); no count "
                                    "is charted by 2 vendor groups"),
}
DEFAULT_REASON = ("not applied: aluminium first (owner decision 2026-11-12); the rows of this group do not show a clear, "
                  "multi-vendor flute-count trend (see the measured ratios)")


def gullet_per_flute(z, core_table):
    c = chipspace.core_ratio(z, core_table)
    return (1.0 - c * c) / z


def nominal_chip_over_D(fz, ae, D):
    return forces.max_chip_thickness(fz, min(ae, D), D) / D


def rows():
    """[(group, class, flutes, vendor key, vendor group, row id, D, ratio)] over the rows in scope."""
    data = o._limits(o.CHIP_LIMITS_PATH)
    out = []
    for key, vgroup, row in bvc.vendor_rows():
        cls = CLASS_OF.get(row["operation"])
        if cls is None or not row["tool"].get("flutes") or row["tool"].get("end") != "square":
            continue
        e = bvc.row_entry(row)
        if e is None:
            continue
        fam, hb, D, aeD, vals = e
        fzD = vals[4]
        h = nominal_chip_over_D(fzD * D, aeD * D, D)
        band = o._band_for(data["slot_nominal_bands" if cls == "slot" else "nominal_bands"], D)
        out.append((o.material_group(fam, hb), cls, int(row["tool"]["flutes"]), key, vgroup, row["id"], D,
                    h / band["h_worst_over_D"]))
    return out


def fit():
    core_table = chipspace.load()["core_ratio_by_flutes"]
    by = collections.defaultdict(list)
    for g, cls, z, key, vg, rid, D, ratio in rows():
        by[(g, cls, z)].append((key, vg, rid, D, ratio))
    groups = {}
    for g in GROUPS:
        groups[g] = {}
        for cls in ("slot", "side", "hem"):
            measured = {}
            for z in range(1, MAX_FLUTES + 1):
                v = by.get((g, cls, z))
                if not v:
                    continue
                ratios = sorted(x[4] for x in v)
                vgs = sorted({x[1] for x in v})
                measured[z] = {"n": len(v), "vendors": dict(collections.Counter(x[0] for x in v)),
                               "vendor_groups": len(vgs), "median_ratio": round(statistics.median(ratios), 4),
                               "p25_ratio": round(ratios[len(ratios) // 4], 4), "p75_ratio": round(ratios[(3 * len(ratios)) // 4], 4),
                               "charted": len(v) >= MIN_ROWS and len(vgs) >= MIN_GROUPS,
                               "rows": sorted(x[2] for x in v)}
            applied, reason = APPLY.get((g, cls), (False, DEFAULT_REASON))
            ent = {"measured": measured, "applied": False, "reason": reason}
            ref = measured.get(REFERENCE_FLUTES)
            charted = sorted(z for z, m in measured.items() if m["charted"])
            if ref and ref["charted"] and len(charted) >= 2:
                f_meas = {z: measured[z]["median_ratio"] / ref["median_ratio"] for z in charted}
                ent["measured_factor"] = {str(z): round(f, 4) for z, f in f_meas.items()}
                if applied:
                    lo, hi = charted[0], charted[-1]
                    factors, basis = {}, {}
                    for z in range(1, MAX_FLUTES + 1):
                        if z in f_meas:
                            factors[z], basis[z] = f_meas[z], "measured"
                        elif z < lo:
                            factors[z], basis[z] = f_meas[lo], f"held at the {lo}-flute factor (no rows below)"
                        elif z > hi and cls == "slot":
                            factors[z] = f_meas[hi] * gullet_per_flute(z, core_table) / gullet_per_flute(hi, core_table)
                            basis[z] = f"{hi}-flute factor x gullet area per flute ({z} vs {hi} flutes)"
                        elif z > hi:
                            factors[z], basis[z] = f_meas[hi], f"held at the {hi}-flute factor (no rows above; open-sided cut)"
                        else:   # between charted counts: geometric interpolation
                            a = max(c for c in charted if c < z)
                            b = min(c for c in charted if c > z)
                            t = (z - a) / (b - a)
                            factors[z] = f_meas[a] * (f_meas[b] / f_meas[a]) ** t
                            basis[z] = f"interpolated between {a} and {b} flutes"
                    # never more chip with more flutes (the chip-room argument the data follows)
                    for z in range(2, MAX_FLUTES + 1):
                        if factors[z] > factors[z - 1]:
                            factors[z] = factors[z - 1]
                            basis[z] += "; capped at the next lower flute count's factor"
                    ent.update(applied=True, factors={str(z): round(f, 4) for z, f in factors.items()},
                               factor_basis={str(z): b for z, b in basis.items()})
            elif applied:
                ent["reason"] = reason + " (NOT applied: the reference or a second flute count is not charted)"
            groups[g][cls] = ent
    return {
        "version": VERSION, "generated_by": "tools/fit_chip_by_flutes.py",
        "status": "C2 flute-count factor (owner decision 2026-11-12: flute-aware chip load, aluminium first)",
        "quantity": ("ratio = nominal chip fz·sin(phi_e)/D of a vendor row over C2's band value at its diameter (slot rows: "
                     "slot_nominal_bands; others: nominal_bands of data/model_v2/chip_limits.json); F(z) = median ratio of "
                     "the z-flute rows / median ratio of the 4-flute rows"),
        "source": "tests/benchmarks/v2/*.json square-end rows in data/model_v2/consensus_by_vendor.json's scope",
        "reference_flutes": REFERENCE_FLUTES, "min_rows": MIN_ROWS, "min_vendor_groups": MIN_GROUPS,
        "extrapolation": ("below the lowest charted count: held; above the highest: in full slots x the gullet area per "
                          "flute (1 - c_z^2)/z with data/model_v2/chip_space.json's core ratios, in open-sided cuts held; "
                          "never rising with flute count"),
        "classes": {"slot": "full slots", "side": "side milling, profiling and traditional roughing (C14 chart classes "
                    "rough and side; the engine's rough operation)", "hem": "HEM / adaptive"},
        "groups": groups,
    }


def factor_table(fit_):
    lines = []
    for g, classes in fit_["groups"].items():
        for cls, ent in classes.items():
            for z, m in sorted(ent["measured"].items(), key=lambda kv: int(kv[0])):
                f = (ent.get("factors") or {}).get(str(z))
                mf = (ent.get("measured_factor") or {}).get(str(z))
                lines.append(f"| {g} | {cls} | {z} | {m['n']} | {m['vendor_groups']} | {m['median_ratio']:.2f} | "
                             f"{'' if mf is None else format(mf, '.2f')} | {'' if f is None else format(f, '.2f')} |")
            if ent.get("applied"):
                lines.append(f"| {g} | {cls} | applied | " + ", ".join(f"{z}: {f:.2f}" for z, f in ent["factors"].items())
                             + " | | | | |")
    return lines


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--table", action="store_true")
    args = ap.parse_args(argv)
    new = fit()
    if args.table:
        print("| group | class | flutes | rows | vendor groups | median ratio to C2 | measured F | applied F |")
        print("|---|---|---|---|---|---|---|---|")
        print("\n".join(factor_table(new)))
        return 0
    text = json.dumps(new, indent=1, sort_keys=True) + "\n"
    if args.check:
        try:
            with open(OUT, encoding="utf-8") as fh:
                old = fh.read()
        except OSError:
            old = None
        same = old == text
        print("chip_by_flutes.json is " + ("current" if same else "out of date: run tools/fit_chip_by_flutes.py"))
        return 0 if same else 1
    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write(text)
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
