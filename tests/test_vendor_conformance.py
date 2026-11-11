"""Vendor conformance: the v2 engine at aggressiveness 50 % against the published ranges (V3 plan, "Acceptance test").

Data: every tests/benchmarks/v2/*.json file (rows added later are picked up). Machine: machines/test_generic_60k.json
(60,000 rpm, ample power, the Speedio's holder stiffness), runout 0.0002", model v2, aggressiveness 0.5. Vendor
tool geometry comes from the row (DC, LCF, flutes, helix, SFDM); stickout = LB when given, else LCF + 0.5 x SFDM.
The material is the row's own family at the row's own hardness (the alloy lookup is replaced by the row's HB).

1. Fixed engagement, per row (operations slot, side, hem, rough). The request carries the row's own ap and ae.
   Pass when SFM is within [0.75 x vendor min, 1.25 x vendor max] and fz within [0.60 x vendor min,
   1.25 x vendor max] (min = max = nominal when only a nominal is published). Pass rate >= 90 % overall and
   >= 85 % for each operation and for tools at or below 1/16".
2. Recommended engagement, per cell. Cell = (material family, operation, diameter band) with >= 3 rows. The
   request carries no depth or width; the engine's ae/D must lie within [0.8 x cell min, 1.25 x cell max]
   (operations side, hem, rough) and its ap/D within [0.5 x cell min, 1.25 x cell max] (slot, hem). The engine's
   value for a cell is the median over the (sampled) rows of the cell, each run on its own tool and material.
   Pass rate >= 85 % of cells.

Scope: square-end carbide rows of the families the v2 model is calibrated for; other rows (corner radius, cast iron,
graphite, copper, cast aluminum, ...) run on v1 and are counted in the printed summary only.

The full set is slow, so by default a deterministic stratified sample runs: every cell, up to SAMPLE_PER_CELL rows
each (evenly spaced over the cell's rows sorted by id). TOOLWIZ_FULL_CONFORMANCE=1 runs every row. These tolerances
are fixed by the planner; do not change them to make the test pass.

Environment (diagnostics only; none changes a tolerance): TOOLWIZ_CONFORMANCE_PER_CELL (rows per cell in the sample,
default 5), TOOLWIZ_CONFORMANCE_WORKERS (processes, default one per core up to 8), TOOLWIZ_CONFORMANCE_DUMP (path of a
JSON file that receives every row's result). The run takes about 15 minutes on four idle cores; `pytest -k summary -s`
prints the pass rates and the failure tables without asserting.
"""
import collections
import concurrent.futures
import glob
import json
import multiprocessing
import os
import statistics
import sys
import time

import pytest

import app
import machine_profiles
from pipeline import CutRequest, run_cut
from physics_v2 import params

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import v2_provisional_limits as pl  # noqa: E402

BENCH_DIR = os.path.join(ROOT, "tests", "benchmarks", "v2")
PROFILE_PATH = os.path.join(ROOT, "machines", "test_generic_60k.json")
FULL = os.environ.get("TOOLWIZ_FULL_CONFORMANCE") == "1"
SAMPLE_PER_CELL = int(os.environ.get("TOOLWIZ_CONFORMANCE_PER_CELL") or 5)

OPERATIONS = ("slot", "side", "hem", "rough")
OP_NAME = {"slot": "Slotting", "side": "Roughing", "rough": "Roughing", "hem": "Adaptive Roughing"}
BANDS = (("<=1/32", 0.0, 1 / 32), ("1/32-1/16", 1 / 32, 1 / 16), ("1/16-1/8", 1 / 16, 1 / 8),
         ("1/8-1/4", 1 / 8, 1 / 4), ("1/4-1/2", 1 / 4, 1 / 2), (">1/2", 1 / 2, 1e9))
MICRO_MAX_D = 1 / 16 + 1e-9

OVERALL_MIN, PER_GROUP_MIN, CELL_MIN = 0.90, 0.85, 0.85
SFM_LO, SFM_HI, FZ_LO, FZ_HI = 0.75, 1.25, 0.60, 1.25
AE_LO, AE_HI, AP_LO, AP_HI = 0.8, 1.25, 0.5, 1.25


def band_of(d):
    for name, _, hi in BANDS:
        if d <= hi + 1e-9:
            return name
    return BANDS[-1][0]


def load_rows():
    rows = []
    for path in sorted(glob.glob(os.path.join(BENCH_DIR, "*.json"))):
        with open(path, encoding="utf-8") as fh:
            rows += json.load(fh)["rows"]
    return rows


def in_scope(row, families):
    t, c = row["tool"], row["cut"]
    return (row["operation"] in OPERATIONS and t.get("tool_material") == "carbide"
            and str(t.get("end", "")).lower() == "square" and not (t.get("corner_radius") or 0.0)
            and row["material"].get("toolwiz_family") in families
            and not pl.missing_geometry(row) and c.get("ap") and c.get("ae"))


def cell_of(row):
    return (row["material"]["toolwiz_family"], row["operation"], band_of(float(row["tool"]["DC"])))


def stratified(rows_by_cell, per_cell):
    """Up to per_cell rows of every cell, evenly spaced over the rows sorted by id (deterministic)."""
    out = []
    for key in sorted(rows_by_cell):
        rows = sorted(rows_by_cell[key], key=lambda r: r["id"])
        if len(rows) <= per_cell:
            out += rows
        else:
            out += [rows[int(i * len(rows) / per_cell)] for i in range(per_cell)]
    return out


def rng(v):
    """(min, max) of a published value block; a nominal-only block gives min = max = nominal."""
    if v is None:
        return None, None
    lo, hi, nom = v.get("min"), v.get("max"), v.get("nominal")
    lo = lo if lo is not None else nom
    hi = hi if hi is not None else nom
    lo = lo if lo is not None else hi
    hi = hi if hi is not None else lo
    return lo, hi


def request_for(row, profile, recommended):
    t, c = row["tool"], row["cut"]
    D, lcf = float(t["DC"]), float(t["LCF"])
    shank = float(t.get("SFDM") or D)
    lb = t.get("LB")
    stick = max(float(lb) if lb else lcf + 0.5 * shank, lcf)
    neck = bool(lb) and float(lb) > lcf * 1.01
    return CutRequest(
        family=row["material"]["toolwiz_family"], alloy="vendor row", tool="HP Carbide Endmill",
        coating=t.get("coating") or "Uncoated", geometry="Square", operation=OP_NAME[row["operation"]],
        diameter=D, flutes=int(t["flutes"]), flute_length=lcf, shank_diameter=shank,
        has_relieved_neck=neck, neck_diameter=float(t.get("neck_diameter") or D) if neck else None,
        neck_length=stick if neck else 0.5, helix_angle=float(t.get("helix_deg") or 35.0), stickout=stick,
        aggressiveness=0.5, max_rpm=60000.0, max_hp=50.0, runout=0.0002,
        cut_depth=None if recommended else min(float(c["ap"]), lcf),
        cut_width=None if recommended else min(float(c["ae"]), D),
        model="v2", machine_profile=profile)


def run_row(args):
    """Worker: one row -> a small result dict (picklable).

    The request carries the row's own ap and ae (fixed engagement) unless recommended is True. The result holds
    the speed and feed for that engagement and, in rec_doc / rec_woc, the engine's own recommendation for the
    row's tool and material, which the per-cell test reads (so one run per row serves both tests).
    """
    row, recommended = args
    with open(PROFILE_PATH, encoding="utf-8") as fh:
        profile = json.load(fh)
    hb = pl.row_hb(row["material"].get("hardness"))
    real = app.physics.resolve_alloy_hardness
    app.physics.resolve_alloy_hardness = lambda family, alloy: hb
    try:
        res = run_cut(app.physics, request_for(row, profile, recommended))
    except Exception as ex:   # a crash is a failed row, not a crashed run
        return {"id": row["id"], "error": f"{type(ex).__name__}: {ex}"}
    finally:
        app.physics.resolve_alloy_hardness = real
    D = float(row["tool"]["DC"])
    return {"id": row["id"], "model": res.model, "feasible": bool(res.feasible), "sfm": res.sfm,
            "fz": res.adj_ipt, "ap_over_D": res.rec_doc / D, "ae_over_D": res.rec_woc / D,
            "engagement_source": res.engagement_source, "rec_ok": bool((res.v2 or {}).get("recommended")),
            "limited_by": res.limited_by, "note": res.model_note}


def _pool_map(items):
    ctx = multiprocessing.get_context("fork")
    workers = int(os.environ.get("TOOLWIZ_CONFORMANCE_WORKERS") or max(1, min(os.cpu_count() or 1, 8)))
    with concurrent.futures.ProcessPoolExecutor(max_workers=workers, mp_context=ctx) as ex:
        return list(ex.map(run_row, items, chunksize=4))


@pytest.fixture(scope="module")
def conformance():
    t0 = time.time()
    families = set(params.load()["families"])
    all_rows = load_rows()
    rows = [r for r in all_rows if in_scope(r, families)]
    by_cell = collections.defaultdict(list)
    for r in rows:
        by_cell[cell_of(r)].append(r)
    sample = rows if FULL else stratified(by_cell, SAMPLE_PER_CELL)

    fixed = {r["id"]: (r, out) for r, out in zip(sample, _pool_map([(r, False) for r in sample]))}
    cells = {k: v for k, v in by_cell.items() if len(v) >= 3}
    cell_sample = {k: [r for r in sample if cell_of(r) == k] for k in cells}
    rec_out = {(k, r["id"]): fixed[r["id"]][1] for k in cells for r in cell_sample[k]}

    dump = os.environ.get("TOOLWIZ_CONFORMANCE_DUMP")
    if dump:   # raw per-row results, for diagnosing failures without re-running the engine
        with open(dump, "w", encoding="utf-8") as fh:
            json.dump({rid: out for rid, (_, out) in fixed.items()}, fh)
    info = {"rows_total": len(all_rows), "rows_in_scope": len(rows), "rows_run": len(sample),
            "cells": len(cells), "mode": "full" if FULL else f"stratified sample (<= {SAMPLE_PER_CELL} per cell)",
            "seconds": time.time() - t0}
    return {"fixed": fixed, "cells": cells, "cell_sample": cell_sample, "rec": rec_out, "info": info}


def fixed_verdict(row, out):
    """(passed, reason) for the fixed-engagement test."""
    if "error" in out:
        return False, "error: " + out["error"]
    if out["model"] != "v2" or not out["feasible"]:
        return False, f"v2 gave no cut ({out['limited_by'] or out['note']})"
    c = row["cut"]
    s_lo, s_hi = rng(c.get("sfm"))
    f_lo, f_hi = rng(c.get("fz"))
    bad = []
    if out["sfm"] < SFM_LO * s_lo or out["sfm"] > SFM_HI * s_hi:
        bad.append(f"SFM {out['sfm']:.0f} not in [{SFM_LO * s_lo:.0f}, {SFM_HI * s_hi:.0f}]")
    if out["fz"] < FZ_LO * f_lo or out["fz"] > FZ_HI * f_hi:
        bad.append(f"fz {out['fz']:.5f} not in [{FZ_LO * f_lo:.5f}, {FZ_HI * f_hi:.5f}]")
    return not bad, "; ".join(bad)


def _rate(passed):
    return sum(passed) / len(passed) if passed else 1.0


def fixed_report(conformance):
    results = []
    for rid, (row, out) in conformance["fixed"].items():
        ok, why = fixed_verdict(row, out)
        results.append({"row": row, "ok": ok, "why": why, "op": row["operation"],
                        "micro": float(row["tool"]["DC"]) <= MICRO_MAX_D})
    return results


def failure_table(results, limit=60):
    bad = [r for r in results if not r["ok"]]
    lines = [f"{len(bad)} failing rows (first {min(limit, len(bad))}):"]
    for r in bad[:limit]:
        row = r["row"]
        lines.append(f"  {row['id']:<70} D {float(row['tool']['DC']):.4f} {r['op']:<5} {r['why']}")
    return "\n".join(lines)


def cell_report(conformance):
    out = []
    for key, rows in sorted(conformance["cells"].items()):
        fam, op, band = key
        got = [conformance["rec"][(key, r["id"])] for r in conformance["cell_sample"][key]]
        errs = [g for g in got if "error" in g or g["model"] != "v2" or not g["rec_ok"]]
        entry = {"cell": key, "n_rows": len(rows), "n_run": len(got), "checks": [], "ok": True}
        if len(errs) * 2 > len(got):
            entry.update(ok=False, why=f"v2 gave no cut for {len(errs)} of {len(got)} rows")
            out.append(entry)
            continue
        got = [g for g in got if g not in errs]
        for what, lo_f, hi_f, applies in (("ae/D", AE_LO, AE_HI, op != "slot"), ("ap/D", AP_LO, AP_HI, op in ("slot", "hem"))):
            if not applies:
                continue
            idx = "ae" if what == "ae/D" else "ap"
            vals = [r["cut"][idx] / float(r["tool"]["DC"]) for r in rows]
            lo, hi = lo_f * min(vals), hi_f * max(vals)
            mine = statistics.median(g[f"{idx}_over_D"] for g in got)
            ok = lo <= mine <= hi
            entry["checks"].append((what, mine, lo, hi, ok))
            entry["ok"] &= ok
        out.append(entry)
    return out


def cell_table(report):
    bad = [e for e in report if not e["ok"]]
    lines = [f"{len(bad)} failing cells of {len(report)}:"]
    for e in bad:
        fam, op, band = e["cell"]
        detail = e.get("why") or "; ".join(f"{w} {m:.3f} not in [{lo:.3f}, {hi:.3f}]" for w, m, lo, hi, ok in e["checks"] if not ok)
        lines.append(f"  {fam[:34]:<34} {op:<5} {band:<10} rows {e['n_rows']:>3}  {detail}")
    return "\n".join(lines)


def test_conformance_summary(conformance, capsys):
    results = fixed_report(conformance)
    cells = cell_report(conformance)
    by_op = {op: _rate([r["ok"] for r in results if r["op"] == op]) for op in OPERATIONS}
    with capsys.disabled():
        i = conformance["info"]
        print(f"\nvendor conformance [{i['mode']}]: {i['rows_run']} of {i['rows_in_scope']} in-scope rows "
              f"({i['rows_total']} in the dataset), {i['cells']} cells, {i['seconds']:.0f} s")
        print(f"  fixed engagement: overall {_rate([r['ok'] for r in results]):.1%}; "
              + ", ".join(f"{op} {v:.1%}" for op, v in by_op.items())
              + f"; micro <= 1/16\" {_rate([r['ok'] for r in results if r['micro']]):.1%}")
        print(f"  recommended engagement: {_rate([e['ok'] for e in cells]):.1%} of {len(cells)} cells")
        print(failure_table(results))
        print(cell_table(cells))


def test_fixed_engagement_overall(conformance):
    results = fixed_report(conformance)
    rate = _rate([r["ok"] for r in results])
    assert rate >= OVERALL_MIN, f"overall {rate:.1%} < {OVERALL_MIN:.0%}\n{failure_table(results)}"


@pytest.mark.parametrize("op", OPERATIONS)
def test_fixed_engagement_per_operation(conformance, op):
    results = [r for r in fixed_report(conformance) if r["op"] == op]
    rate = _rate([r["ok"] for r in results])
    assert rate >= PER_GROUP_MIN, f"{op}: {rate:.1%} < {PER_GROUP_MIN:.0%}\n{failure_table(results)}"


def test_fixed_engagement_micro_tools(conformance):
    results = [r for r in fixed_report(conformance) if r["micro"]]
    rate = _rate([r["ok"] for r in results])
    assert rate >= PER_GROUP_MIN, f"tools <= 1/16\": {rate:.1%} < {PER_GROUP_MIN:.0%}\n{failure_table(results)}"


def test_recommended_engagement_cells(conformance):
    report = cell_report(conformance)
    rate = _rate([e["ok"] for e in report])
    assert rate >= CELL_MIN, f"{rate:.1%} of cells < {CELL_MIN:.0%}\n{cell_table(report)}"
