"""Fit the high-feed chart class level (C7 speed and C2 chip limit) per material family; write
data/model_v2/high_feed_level.json.

Why a separate level. A high-feed end mill (shallow ap at a low lead angle, chip thinned to fz·sin κ) is run by the
engine through the square-end tool-life speed (C7) and the square-end vendor chip limit (C2). The cited high-feed
charts (tests/benchmarks/v2/highfeed_{harvey,helical,seco}.json, 438 rows; Harvey + Helical = one vendor group, Seco /
Niagara the second) sit well above both: 1/8" 4FL Ti slot, Niagara SN400R 377 SFM (328-427), Harvey 300 SFM, against
the square-end C7 level of about 160 SFM at 75 %. The vendors say why in their own notes (HIGHFEED_NOTES.md and the
documents): a high-feed cut is a thin chip (fz·sin κ) at a shallow ap with a short arc of edge in contact per tooth,
so the heat and the edge load per tooth are lower than a square-end slot at the same feed per tooth; Harvey's sheet
title is "High Feed End Mills for High Temp Alloys", Niagara's catalog says the SN400R focuses on "ISO P, S and K
materials including stainless steel, Inconel and titanium" with start values 2-3x the speed of its square-end Ti
rows. This tool measures that offset from the rows instead of guessing it.

Method (as calibrate_v2.fit_level_consensus fitted the adaptive / rough-side operation levels):

* Row targets: each row's L1 bucket vendor median, bucket = (family, 50-HB bin, diameter band, high-feed chart
  class); within a bucket each vendor group's median, then the median over groups.
* Speed: base(row) = the engine's square-end C7 law at 75 % (consensus scale 1.0, T/T_ref 1) for the row's family,
  hardness, diameter, engagement and stickout (C9), with the slot level for hf_slot and the rough level for hf_rough.
  factor(family, class) = exp(median over rows of log(target SFM / base)) (least absolute deviations of a constant).
* Chip: base(row) = C2's nominal chip limit at 75 % (data/model_v2/chip_limits.json, slot nominal band for slots, side
  nominal band otherwise, × the calibrated c2 offset) at the row's diameter; target = the bucket median of the row's
  nominal thinned chip fz·sin φmax·sin κ (κ from the row's max ap and programming radius as physics_v2.highfeed.resolve
  reads them: Harvey publishes no max ap, so 0.06·D is assumed there). factor = exp(median log(target / base)).
* Hold-out: leave one vendor group out. The factor fitted on one group's rows predicts the other group's own bucket
  medians; the median |log error| (as a fraction) is reported each way. In-sample residual is reported too.
* Applied: per (family, class) when both independent vendor groups have rows ("two groups"); with one group the
  factor is applied with confidence "one group (lower)"; a family with no rows keeps the square-end level. The
  aggressiveness map is unchanged (0 / 50 / 100 % = 0.76 / 0.92 / 1.10 x the level, the guardrail 0 / 50 / 100 % =
  bottom / middle / top of the chart). Every other physics limit (C1, C3-C6, C8-C15) stays active.

    python3 tools/fit_high_feed_level.py            # write the file
    python3 tools/fit_high_feed_level.py --check    # exit 1 if the file differs from a fresh fit
    python3 tools/fit_high_feed_level.py --table    # print the table
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
import calibrate_v2 as cv  # noqa: E402
from gwizard_physics import reach_sfm_factor  # noqa: E402
from physics_v2 import forces, highfeed, params  # noqa: E402
from physics_v2 import optimize as o  # noqa: E402

OUT = os.path.join(ROOT, "data", "model_v2", "high_feed_level.json")
VERSION = "2026-11-12.1"
CLASSES = ("hf_slot", "hf_rough")
BASE_OP = {"hf_slot": "slot", "hf_rough": "rough"}   # the square-end C7 level the factor multiplies
JUSTIFICATION = (
    "High-feed cuts are a thin chip (fz·sin κ, κ the lead angle) at a shallow ap with a short arc of edge in contact per "
    "tooth; the heat and the edge load per tooth are lower than in a square-end cut at the same feed per tooth, so the "
    "vendors publish higher speeds and feeds per tooth for this tool class. Vendors' own words: Harvey SF_709800 'High Feed "
    "End Mills for High Temp Alloys' (one table for 3x/5x/8x reach, 'suggested starting values that may be increased given "
    "optimal setup conditions'); Niagara Cutter SN400R (Seco): 'focus on ISO P, S and K materials including stainless "
    "steel, Inconel and titanium', Ti-6Al-4V start value 377 SFM (328-427) at ap max .008\" on 1/8\"; Helical HEVF-C-5 "
    "'Combination Feed & HEM', slot ADOC 3-5 % D. The factor is empirical (fitted to these charts), not derived from a "
    "thermal model.")


def hf_rows():
    """[(vendor key, vendor group, row, entry)] for every high-feed row in scope (the rows C14's hf classes are built from)."""
    out = []
    for key, group, row in bvc.vendor_rows():
        if row["tool"].get("end") != "high_feed":
            continue
        e = bvc.row_entry(row)
        cc = bvc.chart_class(row)
        if e is None or cc is None:
            continue
        out.append((key, group, row, e, cc[0]))
    return out


def row_kappa(row):
    t = row["tool"]
    return highfeed.resolve(float(t["DC"]), t.get("apmx"), t.get("lead_angle_deg"), t.get("programming_radius"))


def chip_base_over_D(fam, D, cls):
    """C2's nominal chip limit / D at 75 % (consensus scale 1.0), as the engine sets it for this diameter and class."""
    data = o._limits(o.CHIP_LIMITS_PATH)
    keys = ("slot_nominal_bands", "nominal_bands") if cls == "hf_slot" else ("nominal_bands",)
    for k in keys:
        band = o._band_for(data.get(k) or [], D)
        if band and band.get("n", 0) >= 3:
            return band["h_worst_over_D"] * params.material(fam).c2_scale
    raise ValueError(f"no chip band for D {D}")


def items():
    """One dict per row: family, class, bucket, vendor group, speed and chip (vendor nominal, engine base)."""
    out = []
    mats = {}
    for key, group, row, e, cls in hf_rows():
        fam, hb, D, aeD, vals = e
        if fam not in params.load()["families"]:
            continue
        mk = (fam, round(hb, 1))
        if mk not in mats:
            mats[mk] = params.material(fam, hb)
        mat = mats[mk]
        D_mm = D * o.MM_PER_IN
        phi = forces.engagement_angle(min(aeD, 1.0) * D_mm, D_mm)
        stick = row["tool"].get("LB") or 3.0 * D
        c9 = reach_sfm_factor(float(stick), D)
        base_sfm = o.taylor_speed_m_min(mat, phi, 1.0, D_mm, 1.0, BASE_OP[cls]) * o.FT_PER_M * c9
        geo = row_kappa(row)
        sin_phi = 1.0 if aeD >= 0.5 else math.sin(phi)
        chip = vals[4] * sin_phi * geo.sin_kappa   # nominal fz/D × sin φmax × sin κ
        out.append(dict(vendor=key, group=group, id=row["id"], family=fam, cls=cls, D=D, hb=hb, doc=row["source"]["doc_id"],
                        op=row["operation"], q_sq=mat.vc_hardness_exp, hb_vc_ref=mat.vc_hb_ref or mat.hb_ref,
                        bucket=bvc.cell_key(fam, hb, D, aeD, cls).rsplit("|", 1)[0],
                        sfm=vals[1], base_sfm=base_sfm, chip=chip, base_chip=chip_base_over_D(fam, D, cls),
                        lead_deg=geo.lead_deg, kappa_assumed=list(geo.assumed)))
    return out


def hardness_exponents(its):
    """{family: (q, n_pairs)}: the high-feed charts' own hardness slope from within-chart contrasts (same vendor, document,
    diameter and operation at two hardness classes): median of log(SFM_soft / SFM_hard) / log(HB_hard / HB_soft)."""
    by = collections.defaultdict(dict)
    for it in its:
        by[(it["family"], it["vendor"], it["doc"], it["D"], it["op"])][round(it["hb"])] = it["sfm"]
    qs = collections.defaultdict(list)
    for (fam, *_), cells in by.items():
        hbs = sorted(cells)
        for i in range(len(hbs)):
            for j in range(i + 1, len(hbs)):
                qs[fam].append(math.log(cells[hbs[i]] / cells[hbs[j]]) / math.log(hbs[j] / hbs[i]))
    return {f: (max(statistics.median(v), 0.0), len(v)) for f, v in qs.items()}


def apply_hardness(its):
    """Re-express each row's base speed with its family's high-feed hardness exponent (the square-end exponent where the
    charts give no contrast)."""
    q = hardness_exponents(its)
    for it in its:
        qf = q.get(it["family"], (it["q_sq"], 0))[0]
        it["q_hf"] = qf
        it["base_sfm"] *= (it["hb_vc_ref"] / it["hb"]) ** (qf - it["q_sq"])
    return q


def bucket_targets(its, field):
    """{bucket: median over vendor groups of each group's median of `field`}."""
    by = collections.defaultdict(lambda: collections.defaultdict(list))
    for it in its:
        by[it["bucket"]][it["group"]].append(it[field])
    return {b: statistics.median([statistics.median(v) for v in g.values()]) for b, g in by.items()}


def fit_factor(its, field, base):
    """exp(median log(bucket target / base)) over the rows (L1 constant)."""
    tg = bucket_targets(its, field)
    return math.exp(statistics.median([math.log(tg[it["bucket"]] / it[base]) for it in its]))


def abs_err(its, factor, field, base):
    """Median |predicted / target − 1| against the rows' own bucket targets (their own vendor group's medians)."""
    tg = bucket_targets(its, field)
    return statistics.median([abs(factor * it[base] / tg[it["bucket"]] - 1.0) for it in its])


def fit():
    its = items()
    qhf = apply_hardness(its)
    fams = collections.defaultdict(list)
    for it in its:
        fams[(it["family"], it["cls"])].append(it)
    families = {}
    for (fam, cls), rows in sorted(fams.items()):
        groups = sorted({r["group"] for r in rows})
        ent = {"n_rows": len(rows), "vendor_groups": groups,
               "vendors": sorted({r["vendor"] for r in rows}),
               "rows_by_group": dict(collections.Counter(r["group"] for r in rows)),
               "diameters_in": sorted({r["D"] for r in rows}),
               "confidence": "two groups" if len(groups) >= 2 else "one group (lower)"}
        for what, field, base in (("speed", "sfm", "base_sfm"), ("chip", "chip", "base_chip")):
            f = fit_factor(rows, field, base)
            res = {"value": round(f, 4), "in_sample_median_abs_err": round(abs_err(rows, f, field, base), 4)}
            if len(groups) >= 2:
                ho = {}
                for g in groups:
                    train = [r for r in rows if r["group"] != g]
                    test = [r for r in rows if r["group"] == g]
                    ft = fit_factor(train, field, base)
                    ho[g] = {"factor_from_others": round(ft, 4), "median_abs_err": round(abs_err(test, ft, field, base), 4),
                             "n_test": len(test)}
                res["holdout_leave_one_group_out"] = ho
                res["holdout_median_abs_err"] = round(statistics.median([v["median_abs_err"] for v in ho.values()]), 4)
            else:
                res["holdout_leave_one_group_out"] = None
                res["holdout_median_abs_err"] = None
            ent[what] = res
        q = qhf.get(fam)
        ent["hardness_exp"] = ({"value": round(q[0], 4), "n_pairs": q[1], "square_end_value": round(rows[0]["q_sq"], 4),
                                "basis": "within-chart contrasts (same vendor, document, diameter, operation at two hardness "
                                         "classes), median"} if q else
                               {"value": None, "n_pairs": 0, "square_end_value": round(rows[0]["q_sq"], 4),
                                "basis": "no within-chart hardness contrast: the square-end exponent is kept"})
        ent["applied"] = True
        ent["lead_angle_deg_rows"] = [round(min(r["lead_deg"] for r in rows), 1), round(max(r["lead_deg"] for r in rows), 1)]
        ent["max_ap_assumed_rows"] = sum(1 for r in rows if "max_ap" in r["kappa_assumed"])
        families.setdefault(fam, {})[cls] = ent
    return {
        "version": VERSION,
        "generated_by": "tools/fit_high_feed_level.py",
        "form": ("high-feed tool: C7 level = square-end level (with the high-feed charts' own hardness exponent where they "
                 "publish hardness classes) (slot level for slots, rough level for roughing, adaptive "
                 "and side) × speed factor of (family, chart class); C2 nominal chip limit (and C2o) × chip factor"),
        "justification": JUSTIFICATION,
        "classes": {"hf_slot": "engine operation slot", "hf_rough": "engine operations rough, adaptive (and side)"},
        "rows": len(its),
        "families": families,
        "not_fitted": ("aluminium and every family without high-feed rows keep the square-end level (no vendor publishes a "
                       "high-feed solid end mill chart in aluminium in the dataset); Cobalt Chrome rows have no engine family"),
    }


def _q(e):
    h = e["hardness_exp"]
    return (f"{h['value']:.2f} ({h['square_end_value']:.2f})" if h["value"] is not None else f"- ({h['square_end_value']:.2f})")


def table(data):
    lines = ["| family | class | rows (groups) | hardness exp (square) | speed factor | hold-out err | chip factor | hold-out err "
             "| confidence |", "|---|---|---|---|---|---|---|---|---|"]
    for fam, classes in data["families"].items():
        for cls, e in classes.items():
            def ho(x):
                return "-" if x is None else f"{x:.0%}"
            lines.append(f"| {fam} | {cls} | {e['n_rows']} ({', '.join(f'{g} {n}' for g, n in e['rows_by_group'].items())}) "
                         f"| {_q(e)} | {e['speed']['value']:.2f} | {ho(e['speed']['holdout_median_abs_err'])} "
                         f"| {e['chip']['value']:.2f} | {ho(e['chip']['holdout_median_abs_err'])} | {e['confidence']} |")
    return "\n".join(lines)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--table", action="store_true")
    a = ap.parse_args(argv)
    data = fit()
    if a.table:
        print(table(data))
        return 0
    text = json.dumps(data, indent=1, ensure_ascii=False) + "\n"
    if a.check:
        try:
            with open(OUT, encoding="utf-8") as fh:
                same = fh.read() == text
        except OSError:
            same = False
        print("current" if same else "differs from a fresh fit")
        return 0 if same else 1
    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write(text)
    print(f"wrote {OUT}")
    print(table(data))
    return 0


if __name__ == "__main__":
    sys.exit(main())
