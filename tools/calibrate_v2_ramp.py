"""v2 ramp calibration: the end-chip limit (R2) and the vendor ramp consensus (R14) from the ramp rows, residuals
by vendor, band and material, a hold-out check, and T1/T12 in 17-4 H1025.

Reads tests/benchmarks/v2/*.json rows with operation "ramp" (SCHEMA.md "Ramp rows") and, for the vendor's slot
chip, the same files' slot rows. Writes data/model_v2/ramp.json (read by physics_v2/ramp.py) and
data/model_v2/ramp_calibration_report.json. Design and results: docs/research/v2_ramp_findings.md.

    PYTHONPATH=. python tools/calibrate_v2_ramp.py            # full (residuals take a few minutes)
    PYTHONPATH=. python tools/calibrate_v2_ramp.py --quick    # tables and T1/T12 only

R2 (end-edge limit) per row: the plunge chip per tooth h_p (axial feed per tooth): stated (OSG, Kennametal, Kyocera
SGS plunge tables) or the vendor's plunge/drilling factor × its slot fz (Seco). Band median of the vendor-group
medians of h_p/D.

Ramp end chip per row (h_a = descent per tooth; reported against R2 and the model, not a constraint):
  * "stated":  the vendor prints a ramp chip load with the angle (Kyocera SGS Z-Carb XPR 3°/6° rows, Sandvik ToolGuide):
               h_a = fz·sin α;
  * "rule":    the vendor prints the ramp feed as a factor of its slot data (Seco recalculation table, SGS "at slotting
               feed"): h_a = factor × the vendor's slot fz for that tool and material × sin α_max (source.derivation);
  * "assumed": angle only: h_a = the vendor's slot fz × sin α_max (the side cut is slot-like, so the slot chip is the
               natural ramp chip; an assumption, reported as a variant only).
Plunge-capable angles (≥ 45°, e.g. SGS Z1P 90°, Seco JS553 45°) state a plunge capability, not a ramp chip, and stay
out of R2 and of the angle consensus.
"""
import argparse
import collections
import datetime
import glob
import hashlib
import json
import math
import os
import statistics
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)

from physics_v2 import optimize as o  # noqa: E402
from physics_v2 import params  # noqa: E402
from physics_v2 import ramp  # noqa: E402
from tools import calibrate_v2 as cv  # noqa: E402

VERSION = "2026-10-18.2"
OUT_DIR = os.path.join(ROOT, "data", "model_v2")
BANDS = cv.BANDS
HB_BIN = 50
PLUNGE_CAPABLE_DEG = 45.0
HOLDOUT_FRACTION = cv.HOLDOUT_FRACTION
FAMILY_174 = "Stainless - PH Series (17-4)"
T1_T12_COATING = "AlTiN"   # the user's T1/T12 (as in tests/test_v2_bridge.py); sets r_β (ramp.edge_radius)


# ---------------------------------------------------------------------------
# Rows
# ---------------------------------------------------------------------------

def load_all():
    ramp_rows, other = [], []
    for path in sorted(glob.glob(os.path.join(ROOT, "tests", "benchmarks", "v2", "*.json"))):
        with open(path, encoding="utf-8") as fh:
            d = json.load(fh)
        for r in d["rows"]:
            r = dict(r, _vendor_group=d["vendor_group"], _file=os.path.basename(path))
            (ramp_rows if r["operation"] == "ramp" else other).append(r)
    return ramp_rows, other


def rng(block, key):
    v = (block or {}).get(key) or {}
    return v.get("min"), v.get("max"), v.get("nominal")


def upper(block, key):
    """The top of a published range: max, else nominal, else min."""
    lo, hi, nom = rng(block, key)
    return hi if hi is not None else nom if nom is not None else lo


def lower(block, key):
    lo, hi, nom = rng(block, key)
    return lo if lo is not None else nom if nom is not None else hi


def holdout(row):
    key = f"{row['_vendor_group']}|{row['source']['doc_id']}|{row['material']['toolwiz_family']}"
    return int(hashlib.sha256(key.encode()).hexdigest()[:8], 16) / 0xFFFFFFFF < HOLDOUT_FRACTION


class SlotIndex:
    """The vendor's own slot chip for a ramp row's tool and material (non-ramp rows of the same files)."""

    def __init__(self, rows):
        self.by_part, self.by_dc = collections.defaultdict(list), collections.defaultdict(list)
        for r in rows:
            if r["operation"] != "slot":
                continue
            fz = cv.pl.nominal(r["cut"].get("fz"))
            if not fz:
                continue
            t = r["tool"]
            fam = r["material"]["toolwiz_family"]
            self.by_part[(r["_vendor_group"], str(t.get("part_number")), fam)].append(fz)
            self.by_dc[(r["_vendor_group"], round(float(t["DC"]), 3), fam)].append(fz)

    def fz(self, row):
        t, fam, vg = row["tool"], row["material"]["toolwiz_family"], row["_vendor_group"]
        v = self.by_part.get((vg, str(t.get("part_number")), fam))
        if v:
            return statistics.median(v), "same part number"
        v = self.by_dc.get((vg, round(float(t["DC"]), 3), fam))
        if v:
            return statistics.median(v), "same vendor, diameter and family"
        return None, None


def features(row, slots):
    """Everything calibration uses from one ramp row."""
    rp, t = row["ramp"], row["tool"]
    D = float(t["DC"])
    hb = cv.row_hb(row["material"].get("hardness"))
    a_hi = upper(rp, "angle_deg")
    plunge_capable = bool(a_hi and a_hi >= PLUNGE_CAPABLE_DEG)
    e = {"id": row["id"], "vendor_group": row["_vendor_group"], "doc": row["source"]["doc_id"],
         "family": row["material"]["toolwiz_family"], "hb": hb, "D": D, "band": cv.band_of(D),
         "kind": rp["kind"], "angle_hi": a_hi, "angle_lo": lower(rp, "angle_deg"),
         "plunge_capable": plunge_capable, "hole_min": lower(rp, "hole_diameter_over_D"),
         "hole_max": (rng(rp, "hole_diameter_over_D")[1]), "ramp_ff": upper(rp, "ramp_feed_factor"),
         "plunge_ff": upper(rp, "plunge_feed_factor"), "holdout": holdout(row),
         "derived": bool(row["source"].get("derivation")), "h_a": None, "h_basis": None, "row": row}
    fz = cv.pl.nominal(row["cut"].get("fz"))
    if rp["kind"] == "plunge":
        if fz:
            e["plunge_h"], e["plunge_h_basis"] = fz, "stated plunge chip (axial feed per tooth)"
        elif e["plunge_ff"]:
            sfz, how = slots.fz(row)
            if sfz:
                e["plunge_h"], e["plunge_h_basis"] = e["plunge_ff"] * sfz, f"rule (factor × slot fz, {how})"
        return e
    if not a_hi or plunge_capable:
        return e
    s = math.sin(math.radians(a_hi))
    if fz:
        e["h_a"], e["h_basis"] = fz * s, "stated"
        return e
    sfz, how = slots.fz(row)
    if sfz:
        if e["ramp_ff"]:
            e["h_a"], e["h_basis"] = e["ramp_ff"] * sfz * s, f"rule (factor {e['ramp_ff']:g} × slot fz, {how})"
        else:
            e["h_a_assumed"] = sfz * s
            e["h_assumed_basis"] = f"assumed slot fz ({how})"
    return e


# ---------------------------------------------------------------------------
# Tables
# ---------------------------------------------------------------------------

def _median_of_groups(items, key):
    by = collections.defaultdict(list)
    for e in items:
        if e.get(key) is not None:
            by[e["vendor_group"]].append(e[key])
    meds = {g: statistics.median(v) for g, v in by.items()}
    return (statistics.median(meds.values()) if meds else None), meds, sum(len(v) for v in by.values())


def end_chip_bands(items, key="h_a", min_groups=2):
    """R2: per diameter band, the median over vendor groups of each group's median h_a/D; a band with fewer than
    min_groups groups pools its neighbouring bands (stepwise)."""
    vals = [dict(e, _hD=e[key] / e["D"]) for e in items if e.get(key)]
    names = [b[0] for b in BANDS]
    out = []
    for name, lo, hi in BANDS:
        i = names.index(name)
        for width, label in ((0, "band"), (1, "+ neighbouring bands"), (2, "+ two bands either side")):
            sel = [v for v in vals if abs(names.index(v["band"]) - i) <= width]
            med, meds, n = _median_of_groups(sel, "_hD")
            if len(meds) >= min_groups:
                hs = sorted(v["_hD"] for v in sel)
                out.append({"band": name, "d_min": lo, "d_max": hi if math.isfinite(hi) else 1e9,
                            "h_a_over_D": med, "group_medians": meds, "groups": sorted(meds), "n": n,
                            "widening": label, "p10": cv.quantile(hs, 0.1), "p90": cv.quantile(hs, 0.9)})
                break
    return out


def consensus_cells(items):
    cells = collections.defaultdict(lambda: collections.defaultdict(list))
    for e in items:
        a = e["angle_hi"] if (e["angle_hi"] and not e["plunge_capable"] and e["kind"] != "plunge") else None
        vec = [a, e["hole_min"], e["hole_max"], e["ramp_ff"] if e["kind"] != "plunge" else None, e["plunge_ff"]]
        if all(v is None for v in vec):
            continue
        hbin = str(int(e["hb"] // HB_BIN)) if e["hb"] else "x"
        cells["|".join((e["family"], hbin, e["band"]))][e["vendor_group"]].append(vec)
    return {k: dict(v) for k, v in cells.items()}


def build_table(items, end_key="h_a"):
    return {
        "version": VERSION, "status": "PROPOSED (ramp calibration)", "generated_by": "tools/calibrate_v2_ramp.py",
        "date": datetime.date.today().isoformat(),
        "end_chip": {"basis": "R2: median over vendor groups of each group's median plunge chip per tooth h_p/D (stated "
                              "plunge fz, or the vendor's plunge/drilling factor × its slot fz), per diameter band, ≥ 2 "
                              "groups (neighbouring bands pooled when fewer)",
                     "bands": end_chip_bands(items, "plunge_h")},
        "ramp_end_chip_reported": {"basis": "vendor ramp chip × sin(maximum ramp angle) ('stated' and 'rule' rows); "
                                            "reported, not a constraint", "bands": end_chip_bands(items, end_key)},
        "consensus": {"basis": ramp.SRC["R14"], "fields": list(ramp.RAMP_FIELDS), "min_vendor_groups": 2,
                      "bands": [{"band": b, "d_min": lo, "d_max": hi if math.isfinite(hi) else 1e9}
                                for b, lo, hi in BANDS],
                      "hb_bin": HB_BIN, "plunge_capable_deg": PLUNGE_CAPABLE_DEG, "cells": consensus_cells(items)},
    }


# ---------------------------------------------------------------------------
# Model runs
# ---------------------------------------------------------------------------

def run_model(e, table, aggressiveness, consensus_c14, method="fast"):
    row = e["row"]
    try:
        tool, _ = cv.pl.row_tool(row)
    except (KeyError, TypeError, ValueError) as ex:
        return {"skip": f"geometry: {ex}"}
    fam = e["family"]
    if fam not in params.load()["families"]:
        return {"skip": f"no calibrated v2 family {fam!r}"}
    mat = params.material(fam, hb=e["hb"], coating=row["tool"].get("coating"))
    try:
        r = ramp.optimize_ramp(tool, mat, params.machine(), aggressiveness, table=table, consensus=consensus_c14,
                               coating=row["tool"].get("coating"), method=method)
    except Exception as ex:   # report, never hide
        return {"skip": f"error: {type(ex).__name__}: {ex}"}
    if not r.get("feasible") and "ramp_angle_deg" not in r:
        return {"skip": "infeasible", "eliminated_by": r.get("eliminated_by")}
    return {"alpha": r["ramp_angle_deg"], "h_a": r["end_chip_in"], "dh": r["helix_diameter_over_D"],
            "fz": r["fz_in"], "rpm": r["rpm"], "binding": r["binding"], "conflicts": r["conflicts"],
            "r1_warning": r.get("r1_warning"), "ramp_feed": r["ramp_feed_ipm"], "plunge": r["plunge_feed_ipm"]}


def residuals(items, table, aggressiveness, consensus_c14, label):
    """log(model angle / vendor maximum angle) and the share inside the vendor's range, by vendor group, band and
    family, over unique (tool, material) combinations."""
    seen, res = {}, []
    for e in items:
        if not e["angle_hi"] or e["plunge_capable"] or e["kind"] == "plunge":
            continue
        t = e["row"]["tool"]
        key = (e["vendor_group"], t.get("part_number"), e["family"], e["hb"])
        if key not in seen:
            seen[key] = run_model(e, table, aggressiveness, consensus_c14)
            if len(seen) % 25 == 0:
                print(f"    [{label}] {len(seen)} tool/material combinations", flush=True)
        m = seen[key]
        if "skip" in m:
            res.append({"id": e["id"], "skip": m["skip"]})
            continue
        lo = e["angle_lo"] or 0.0
        res.append({"id": e["id"], "vendor_group": e["vendor_group"], "band": e["band"], "family": e["family"],
                    "holdout": e["holdout"], "vendor_hi": e["angle_hi"], "vendor_lo": lo, "model": m["alpha"],
                    "log_ratio": math.log(m["alpha"] / e["angle_hi"]),
                    "inside": lo - 1e-9 <= m["alpha"] <= e["angle_hi"] * (1 + 1e-6),
                    "h_a_model": m["h_a"], "h_a_vendor": e.get("h_a"), "binding": m["binding"],
                    "r1_warning": bool(m.get("r1_warning"))})
    ok = [r for r in res if "skip" not in r]

    def summ(sel):
        if not sel:
            return None
        lr = [r["log_ratio"] for r in sel]
        return {"n": len(sel), "r1_warning_share": sum(r["r1_warning"] for r in sel) / len(sel),
                "median_log_ratio": statistics.median(lr),
                "median_abs_log": statistics.median(abs(x) for x in lr),
                "inside_vendor_range": sum(r["inside"] for r in sel) / len(sel)}
    out = {"label": label, "aggressiveness": aggressiveness, "overall": summ(ok),
           "skipped": dict(collections.Counter(r["skip"].split(":")[0] for r in res if "skip" in r)),
           "by_vendor": {g: summ([r for r in ok if r["vendor_group"] == g])
                         for g in sorted({r["vendor_group"] for r in ok})},
           "by_band": {b: summ([r for r in ok if r["band"] == b]) for b, _, _ in BANDS if any(r["band"] == b for r in ok)},
           "by_family": {f: summ([r for r in ok if r["family"] == f]) for f in sorted({r["family"] for r in ok})},
           "binding": dict(collections.Counter(k for r in ok for k in r["binding"]))}
    return out, res


def t1_t12(table, consensus_c14):
    """T1 and T12 in 17-4 H1025 at 50 % and 75 %, against v1's rule (gwizard_physics.calc_ramping)."""
    from gwizard_physics import GWizardPhysics
    phys = GWizardPhysics(os.path.join(ROOT, "materials_database_clean.json"))
    tools = (o.Tool.build(0.125, 4, 0.5, 0.6, shank=0.125, label="T1"),
             o.Tool.build(0.0625, 4, 0.1875, 0.5, shank=0.125, label="T12"))
    out = []
    mat = params.material(FAMILY_174, hb=356.0, coating=T1_T12_COATING)
    for tool in tools:
        for a in (0.5, 0.75):
            op = params.optimize(tool, mat, "adaptive", a, robustness=False, find_tir=False)
            c = op["cut"]
            r = ramp.optimize_ramp(tool, mat, params.machine(), a, table=table, consensus=consensus_c14,
                                   op_feed_ipm=c["feed_ipm"], op_rpm=c["rpm"], coating=T1_T12_COATING)
            v1_angle, v1_ramp, v1_plunge = phys.calc_ramping(FAMILY_174, tool.D, c["feed_ipm"], "Square", tool.z, a)
            out.append({
                "tool": tool.label, "aggressiveness": a,
                "adaptive": {"ap_in": c["ap_in"], "ae_in": c["ae_in"], "rpm": c["rpm"], "feed_ipm": c["feed_ipm"],
                             "fz_in": c["fz_in"]},
                "v2_ramp": {k: r.get(k) for k in ("feasible", "ramp_angle_deg", "helix_diameter_over_D", "helix_diameter_in",
                                                  "helix_min_diameter_in", "bore_diameter_in", "pitch_in", "rpm", "sfm",
                                                  "spindle_rpm", "fz_in", "ramp_feed_ipm", "ramp_feed_at_c7_rpm_ipm",
                                                  "descent_ipm", "plunge_feed_ipm", "end_chip_in", "end_chip_floor_in",
                                                  "end_chip_cap_in", "edge_radius_mm", "edge_radius_basis", "r1_warning",
                                                  "binding", "warned", "conflicts", "warnings")},
                "v2_ramp_checks": {k: {"value": v["value"], "limit": v["limit"], "ok": v["ok"]}
                                   for k, v in r["checks"].items() if v["applies"]},
                "v1": {"ramp_angle_deg": v1_angle,
                       "ramp_feed_ipm_v1_rule_on_v2_feed": v1_ramp, "plunge_feed_ipm_v1_rule_on_v2_feed": v1_plunge,
                       "end_chip_in_at_v2_ramp_fz": r["fz_in"] * math.sin(math.radians(v1_angle))},
            })
    return out


def search_check(items, table, consensus_c14, n=24):
    """The fast search against the exhaustive one (user requirement 2026-10-18: identical within reporting precision)
    on T1/T12 and a spread of vendor rows, with the time per call."""
    import time
    picks, seen = [], set()
    for e in sorted(items, key=lambda e: e["id"]):
        k = (e["vendor_group"], e["band"], e["family"])
        if e["angle_hi"] and not e["plunge_capable"] and e["family"] in params.load()["families"] and k not in seen:
            seen.add(k)
            picks.append(e)
    picks = picks[:n]
    worst = {"angle_deg": 0.0, "helix_over_D": 0.0, "fz_rel": 0.0, "ramp_feed_rel": 0.0, "plunge_rel": 0.0}
    t_fast, t_exh, n_ok, mismatched = [], [], 0, []
    for e in picks:
        t0 = time.time()
        f = run_model(e, table, 0.5, consensus_c14, "fast")
        t1 = time.time()
        x = run_model(e, table, 0.5, consensus_c14, "exhaustive")
        t2 = time.time()
        if "skip" in f or "skip" in x:
            if ("skip" in f) != ("skip" in x):
                mismatched.append(e["id"])
            continue
        n_ok += 1
        t_fast.append(t1 - t0)
        t_exh.append(t2 - t1)
        worst["angle_deg"] = max(worst["angle_deg"], abs(f["alpha"] - x["alpha"]))
        worst["helix_over_D"] = max(worst["helix_over_D"], abs(f["dh"] - x["dh"]))
        for k, kk in (("fz_rel", "fz"), ("ramp_feed_rel", "ramp_feed"), ("plunge_rel", "plunge")):
            worst[k] = max(worst[k], abs(f[kk] / x[kk] - 1.0))
        if f["binding"] != x["binding"]:
            mismatched.append(e["id"])
    return {"rows": n_ok, "worst_difference": worst, "binding_or_feasibility_mismatch": mismatched,
            "median_s_fast": statistics.median(t_fast) if t_fast else None,
            "max_s_fast": max(t_fast) if t_fast else None,
            "median_s_exhaustive": statistics.median(t_exh) if t_exh else None}


def _round(x, nd=4):
    if isinstance(x, float):
        return float(f"{x:.{nd}g}") if math.isfinite(x) else None
    if isinstance(x, dict):
        return {k: _round(v, nd) for k, v in x.items()}
    if isinstance(x, (list, tuple)):
        return [_round(v, nd) for v in x]
    return x


def write_json(name, data):
    with open(os.path.join(OUT_DIR, name), "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=1, ensure_ascii=False)
        fh.write("\n")


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--quick", action="store_true", help="tables and T1/T12 only (no residuals)")
    args = ap.parse_args(argv)
    ramp_rows, other = load_all()
    slots = SlotIndex(other)
    items = [features(r, slots) for r in ramp_rows]
    print(f"{len(items)} ramp rows from {len({e['vendor_group'] for e in items})} vendor groups")
    basis = collections.Counter(e["h_basis"].split(" ")[0] if e["h_basis"] else
                                ("assumed" if e.get("h_a_assumed") else "none") for e in items)
    print(f"end chip basis: {dict(basis)}")

    table_all = build_table(items)
    table_train = build_table([e for e in items if not e["holdout"]])
    alt = [dict(e, h_a_any=e.get("h_a") or e.get("h_a_assumed")) for e in items]
    r2_with_assumed = end_chip_bands(alt, "h_a_any")   # ramp end chip including the angle-only rows
    for b in table_all["ramp_end_chip_reported"]["bands"]:
        print(f"  ramp end chip {b['band']:10} h_a/D {b['h_a_over_D']:.2e} ({b['widening']}, n {b['n']}, groups "
              + ", ".join(f"{g} {v:.1e}" for g, v in sorted(b["group_medians"].items())) + ")")
    for b in table_all["end_chip"]["bands"]:
        print(f"  R2 (plunge chip) {b['band']:10} h_p/D {b['h_a_over_D']:.2e} ({b['widening']}, n {b['n']}, groups "
              + ", ".join(f"{g} {v:.1e}" for g, v in sorted(b["group_medians"].items())) + ")")
    plunge = [e for e in items if e.get("plunge_h")]
    plunge_stats = {"n": len(plunge), "median_h_over_D": statistics.median(e["plunge_h"] / e["D"] for e in plunge)
                    if plunge else None, "groups": sorted({e["vendor_group"] for e in plunge})}

    cons17 = {}
    for D in (0.0625, 0.125, 0.25, 0.5):
        cons17[str(D)] = {k: {"median": v["median"], "widening": v["widening"],
                              "groups": v["group_medians"]}
                          for k, v in ramp.consensus_lookup(table_all, FAMILY_174, 356.0, D).items()}
    print("17-4 H1025 ramp consensus: " + json.dumps(_round(cons17, 3)))

    os.makedirs(OUT_DIR, exist_ok=True)
    write_json("ramp.json", table_all)
    ramp._CACHE.clear()
    c14 = params.CONSENSUS_PATH
    t12 = t1_t12(table_all, c14)
    for r in t12:
        v = r["v2_ramp"]
        print(f"  {r['tool']:3} {r['aggressiveness']:.0%}: v2 α {v['ramp_angle_deg']:.2f}° (v1 {r['v1']['ramp_angle_deg']:.2f}°), "
              f"D_h {v['helix_diameter_over_D']:.2f}·D, {v['rpm']:.0f} rpm, fz {v['fz_in']:.6f}, ramp {v['ramp_feed_ipm']:.2f} IPM, "
              f"plunge {v['plunge_feed_ipm']:.2f} IPM, h_a {v['end_chip_in'] * 25400:.2f} µm, binding {v['binding']}; "
              f"conflicts {len(v['conflicts'])}")

    report = {"version": VERSION, "generated_by": "tools/calibrate_v2_ramp.py", "date": datetime.date.today().isoformat(),
              "rows": len(items), "vendor_groups": sorted({e["vendor_group"] for e in items}),
              "rows_by_vendor": dict(collections.Counter(e["vendor_group"] for e in items)),
              "rows_by_family": dict(collections.Counter(e["family"] for e in items)),
              "rows_by_band": dict(collections.Counter(e["band"] for e in items)),
              "end_chip_basis": dict(basis), "end_chip_bands_R2_plunge": table_all["end_chip"]["bands"],
              "ramp_end_chip_bands_reported": table_all["ramp_end_chip_reported"]["bands"],
              "end_chip_bands_holdout_train": table_train["end_chip"]["bands"],
              "ramp_end_chip_bands_with_assumed_rows": r2_with_assumed, "plunge_chips": plunge_stats,
              "consensus_17_4_h1025": cons17, "t1_t12": t12,
              "end_chip_rows": [{k: e[k] for k in ("id", "vendor_group", "family", "D", "angle_hi", "h_a", "h_basis")}
                                for e in items if e.get("h_a")]}
    sc = search_check(items, table_all, c14)
    report["search_check_fast_vs_exhaustive"] = sc
    print(f"fast vs exhaustive search on {sc['rows']} rows: {json.dumps(_round(sc['worst_difference'], 3))}, mismatches "
          f"{sc['binding_or_feasibility_mismatch']}; median {sc['median_s_fast']:.3f} s (max {sc['max_s_fast']:.3f} s) vs "
          f"{sc['median_s_exhaustive']:.2f} s")
    if not args.quick:
        res = {}
        for a in (0.75, 0.5):
            s, _ = residuals(items, table_all, a, c14, f"all rows, tables from all rows, {a:.0%}")
            res[f"all_{a:g}"] = s
            print(f"residuals [{s['label']}]: {json.dumps(_round(s['overall'], 3))}")
        hold = [e for e in items if e["holdout"]]
        s, _ = residuals(hold, table_train, 0.75, c14, "hold-out rows, tables from training rows, 75%")
        res["holdout_0.75"] = s
        print(f"residuals [{s['label']}]: {json.dumps(_round(s['overall'], 3))}")
        s, _ = residuals([e for e in items if e["family"] in params.load()["families"]],
                         dict(table_all, consensus=None), 0.75, c14, "physics only (R14 off), 75%")
        res["physics_only_0.75"] = s
        print(f"residuals [{s['label']}]: {json.dumps(_round(s['overall'], 3))}")
        report["residuals"] = res
    write_json("ramp_calibration_report.json", _round(report, 5))
    print(f"wrote {OUT_DIR}/ramp.json and ramp_calibration_report.json")


if __name__ == "__main__":
    main()
