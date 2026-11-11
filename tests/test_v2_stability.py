"""v2 stability: the recommendation must not jump, and must stay inside the envelope (REVIEW Part 5.4 M1 and M4).

Tools: 2-flute 0.010", 0.020", 1/32", 1/16" and 3-4 flute 1/8", 1/4" (the 1/8" has 3 flutes, the 1/4" 4), in 6061 and 4130,
adaptive roughing and slotting, on the built-in Speedio (16k) profile, aggressiveness 50 %, no user engagement
(the optimizer's own recommendation).

  (a) feed is non-increasing as runout goes 0, 0.00005, 0.0001, 0.0002, 0.0005", and the step 0 -> 0.00005" changes
      the feed by less than 15 %
  (b) +10 % runout, stickout or aggressiveness changes the recommended depth, width and feed by less than 25 % each
  (c) no result has a feed per tooth under twice the rubbing limit (the C1 minimum chip)
  (d) adaptive width of cut is at most 0.40 x D
  (e) every case is feasible (v2 gives a cut, no "no safe cut")
"""
import concurrent.futures
import multiprocessing
import os

import pytest

import app
from pipeline import CutRequest, run_cut

TOOLS = ((0.010, 2), (0.020, 2), (1 / 32, 2), (1 / 16, 2), (1 / 8, 3), (1 / 4, 4))
MATERIALS = (("Aluminum - Wrought (6061)", "Uncoated"), ("Steel - Medium Carbon Alloy (4130)", "AlTiN"))
OPERATIONS = ("Adaptive Roughing", "Slotting")
RUNOUTS = (0.0, 0.00005, 0.0001, 0.0002, 0.0005)
BASE_RUNOUT = 0.0002
STEP_MAX, PERTURB_MAX, AE_ADAPTIVE_MAX = 0.15, 0.25, 0.40


def case_id(d, z, family, op):
    return f"{d:.4f}in-{z}fl-{family.split(' - ')[0].split()[0]}-{op.split()[0]}"


CASES = [(d, z, fam, coat, op) for d, z in TOOLS for fam, coat in MATERIALS for op in OPERATIONS]


def run_case(args):
    """One calculation through the pipeline; returns the numbers the checks need."""
    (d, z, fam, coat, op), runout, stick_scale, aggressiveness = args
    stick = max(0.5, 3.5 * d) * stick_scale
    req = CutRequest(family=fam, alloy="", tool="HP Carbide Endmill", coating=coat, geometry="Square", operation=op,
                     diameter=d, flutes=z, flute_length=3.0 * d, shank_diameter=max(d, 0.125), helix_angle=35.0,
                     stickout=stick, aggressiveness=aggressiveness, max_rpm=16000.0, max_hp=10.0, runout=runout,
                     cut_depth=None, cut_width=None, model="v2")
    res = run_cut(app.physics, req)
    cut = (res.v2 or {}).get("cut") or {}
    return {"feasible": bool(res.feasible) and res.model == "v2", "note": res.model_note, "feed": res.feed_ipm,
            "ap": res.rec_doc, "ae": res.rec_woc, "fz": res.adj_ipt, "rpm": res.rpm, "D": d,
            "rubbing": cut.get("rubbing_limit_in"), "flutes_cutting": getattr(res, "flutes_cutting", None)}


def _run_all(jobs):
    ctx = multiprocessing.get_context("fork")
    with concurrent.futures.ProcessPoolExecutor(max_workers=max(1, min(os.cpu_count() or 1, 8)), mp_context=ctx) as ex:
        return list(ex.map(run_case, jobs, chunksize=2))


@pytest.fixture(scope="module")
def sweep():
    jobs, keys = [], []
    for case in CASES:
        for ro in RUNOUTS:
            jobs.append((case, ro, 1.0, 0.5))
            keys.append((case, "runout", ro))
        jobs.append((case, BASE_RUNOUT * 1.1, 1.0, 0.5))
        keys.append((case, "runout+10%", None))
        jobs.append((case, BASE_RUNOUT, 1.1, 0.5))
        keys.append((case, "stickout+10%", None))
        jobs.append((case, BASE_RUNOUT, 1.0, 0.55))
        keys.append((case, "aggressiveness+10%", None))
    return dict(zip(keys, _run_all(jobs)))


def _ids():
    return [case_id(d, z, fam, op) for d, z, fam, _, op in CASES]


@pytest.mark.parametrize("case", CASES, ids=_ids())
def test_feed_is_non_increasing_in_runout(sweep, case):
    feeds = [sweep[(case, "runout", ro)]["feed"] for ro in RUNOUTS]
    for (r0, f0), (r1, f1) in zip(zip(RUNOUTS, feeds), zip(RUNOUTS[1:], feeds[1:])):
        assert f1 <= f0 * 1.005, f"feed rises from {f0:.3f} at runout {r0} to {f1:.3f} at {r1}: {feeds}"
    assert abs(feeds[1] - feeds[0]) / feeds[0] < STEP_MAX, f"runout 0 -> 0.00005\" changes the feed {feeds[0]:.3f} -> {feeds[1]:.3f}"


@pytest.mark.parametrize("case", CASES, ids=_ids())
@pytest.mark.parametrize("what", ("runout+10%", "stickout+10%", "aggressiveness+10%"))
def test_ten_percent_input_change_moves_the_cut_less_than_25_percent(sweep, case, what):
    base, pert = sweep[(case, "runout", BASE_RUNOUT)], sweep[(case, what, None)]
    for key in ("ap", "ae", "feed"):
        if case[4] == "Slotting" and key == "ae":
            continue
        change = abs(pert[key] - base[key]) / base[key]
        assert change < PERTURB_MAX, f"{what}: {key} {base[key]:.5f} -> {pert[key]:.5f} ({change:.0%})"


@pytest.mark.parametrize("case", CASES, ids=_ids())
def test_every_case_is_feasible_and_not_starved(sweep, case):
    for ro in RUNOUTS:
        r = sweep[(case, "runout", ro)]
        assert r["feasible"], f"runout {ro}: {r['note']}"
        assert r["rubbing"], "v2 cut must report its rubbing limit"
        assert r["fz"] >= 2.0 * r["rubbing"] * 0.999, f"runout {ro}: fz {r['fz']:.6f} under 2 x rubbing {r['rubbing']:.6f}"
        if case[4] == "Adaptive Roughing":
            assert r["ae"] <= AE_ADAPTIVE_MAX * r["D"] + 1e-9, f"runout {ro}: ae/D {r['ae'] / r['D']:.2f}"
