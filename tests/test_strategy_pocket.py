"""Pocket strategies in the strategy planner (strategy_pocket) and the pocket / multi-stepover paths of the setup advisor."""
import math
import os
import sys

import pytest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
import app as toolwiz_app  # noqa: E402
import setup_advisor as sa  # noqa: E402
import strategy_planner as sp  # noqa: E402
from pipeline import CutRequest, run_cut  # noqa: E402

HDR = {"X-ToolWiz-Client": "unit-test"}
T_HALF = {"diameter": 0.5, "flutes": 3, "flute_length": 1.0, "shank_diameter": 0.5, "stickout": 2.0}
T_QTR = {"diameter": 0.25, "flutes": 3, "flute_length": 0.75, "shank_diameter": 0.25, "stickout": 1.5}
POCKET = {"type": "pocket", "depth": 0.75, "length": 3.0, "width": 2.0, "corner_radius": 0.125}
MATS = [("Aluminum - Wrought (6061)", "6061-T6"), ("Titanium Alloy", "Ti-6Al-4V (Grade 5, Annealed)")]


def compare(fam, alloy, feature, tools=(T_HALF, T_QTR), **kw):
    req = {"family": fam, "alloy": alloy, "aggressiveness": 0.5, "runout": 0.0002, "model": "v2", "feature": feature,
           "candidate_tools": [dict(t) for t in tools]}
    req.update(kw)
    return sp.compare(req, physics=toolwiz_app.physics, machine_profile=toolwiz_app.active_machine())


@pytest.fixture(scope="module", params=MATS, ids=["6061", "Ti"])
def res(request):
    fam, alloy = request.param
    return fam, alloy, compare(fam, alloy, POCKET)


def opt(r, strategy, d):
    return next(o for o in r["options"] if o["strategy"] == strategy and abs(o["tool"]["diameter"] - d) < 1e-9)


def test_four_options_positive_finite_with_hints(res):
    fam, alloy, r = res
    assert sorted(o["strategy"] for o in r["options"]) == ["pocket_adaptive"] * 2 + ["pocket_offset"] * 2
    for o in r["options"]:
        for k in ("cycle_time_min", "path_length_in", "rpm", "feed_ipm", "relative_tool_life", "tool_wear_per_part"):
            assert o[k] is not None and math.isfinite(o[k]) and o[k] > 0, (o["name"], k)
        h = o["fusion_hints"]
        assert h["fusion_strategy"] and h["stock_to_leave"] and h["ramp"] and h["finishing_pass"] and "rest_machining" in h
        assert [p["name"] for p in o["phases"]][-2:] == ["wall finishing", "floor finishing"]
    assert min(o["tool_wear_per_part"] for o in r["options"] if o["feasible"]) == pytest.approx(1.0)
    assert r["recommended"] and r["reasoning"] and r["assumptions"]


def test_numbers_are_toolwiz(res):
    fam, alloy, r = res
    mach = toolwiz_app.active_machine()

    def direct(op, tool, **kw):
        return run_cut(toolwiz_app.physics, CutRequest(
            family=fam, alloy=alloy, tool="Carbide Endmill", geometry="Square", operation=op, coating="Uncoated",
            diameter=tool["diameter"], flutes=tool["flutes"], flute_length=tool["flute_length"], shank_diameter=tool["shank_diameter"],
            stickout=tool["stickout"], aggressiveness=0.5, max_rpm=mach["max_rpm"], max_hp=mach["max_hp"], runout=0.0002,
            fusion_tool={"type": "flat end mill", "unit": "inches", "geometry": {"DC": tool["diameter"], "NOF": tool["flutes"],
                         "LCF": tool["flute_length"], "SFDM": tool["shank_diameter"], "LB": tool["stickout"]}},
            model="v2", machine_profile=mach, **kw))
    a = direct("Adaptive Roughing", T_HALF)
    o = opt(r, "pocket_adaptive", 0.5)
    assert o["rpm"] == round(a.rpm) and o["feed_ipm"] == pytest.approx(a.feed_ipm, abs=1e-3) and o["ae"] == pytest.approx(a.woc, abs=1e-5)
    ro = direct("Roughing", T_QTR)
    o2 = opt(r, "pocket_offset", 0.25)
    # the option's headline numbers are its longest phase's, which can be a finishing phase: compare the roughing phase
    ph = next(p for p in o2["phases"] if p["name"] == "offset roughing")
    assert ph["rpm"] == round(ro.rpm) and o2["ae"] == pytest.approx(ro.woc, abs=1e-5)


def test_offset_has_full_slot_entry_and_adaptive_path_formula(res):
    fam, alloy, r = res
    o = opt(r, "pocket_offset", 0.5)
    assert any(p["name"] == "full-slot entry pass" and p["ae"] == pytest.approx(0.5) for p in o["phases"])
    assert any("FULL SLOT" in n for n in o["notes"])
    ad = opt(r, "pocket_adaptive", 0.25)
    assert any("A_clear / ae + P_walls" in n for n in ad["notes"])
    assert any("helical" in n or "plunge" in n for n in ad["notes"])


def test_rest_machining_when_tool_radius_exceeds_corner_radius():
    r = compare(*MATS[0], POCKET)
    big, small = opt(r, "pocket_offset", 0.5), opt(r, "pocket_offset", 0.25)
    assert big["rest_machining_needed"] and big["fusion_hints"]["rest_machining"]["needed"]
    assert big["fusion_hints"]["rest_machining"]["max_rest_tool_diameter_in"] == pytest.approx(0.25)
    assert any("rest machining" in x for x in big["risks"])
    assert not small["rest_machining_needed"]          # radius 0.125 = corner radius 0.125 still fits (equal)


def test_corner_spike_slows_the_corner_moves():
    sharp = compare(*MATS[0], dict(POCKET, corner_radius=0.2), tools=(T_QTR,))
    big_r = compare(*MATS[0], dict(POCKET, corner_radius=0.9), tools=(T_QTR,))
    a_sharp, a_big = opt(sharp, "pocket_adaptive", 0.25), opt(big_r, "pocket_adaptive", 0.25)
    assert a_sharp["corner_feed_scale"] < 1.0 and a_big["corner_feed_scale"] == pytest.approx(1.0, abs=0.35)
    assert any("corner engagement spike" in n for n in a_sharp["notes"])


def test_island_adds_wall_and_less_area():
    plain = compare(*MATS[0], POCKET, tools=(T_QTR,))
    isl = compare(*MATS[0], dict(POCKET, island_area=1.0), tools=(T_QTR,))
    p, i = opt(plain, "pocket_offset", 0.25), opt(isl, "pocket_offset", 0.25)
    assert "island" in " ".join(isl["assumptions"])
    assert i["time_breakdown_min"]["cutting"] != p["time_breakdown_min"]["cutting"]
    assert i["path_length_in"] != p["path_length_in"]


def test_area_and_perimeter_equivalent_to_the_rectangle():
    rect = compare(*MATS[0], POCKET, tools=(T_QTR,))
    area = 3.0 * 2.0 - (4 - math.pi) * 0.125 ** 2
    per = 2 * 5.0 - (8 - 2 * math.pi) * 0.125
    ap = compare(*MATS[0], {"type": "pocket", "depth": 0.75, "area": area, "perimeter": per, "corner_radius": 0.125}, tools=(T_QTR,))
    for s in ("pocket_adaptive", "pocket_offset"):
        a, b = opt(rect, s, 0.25), opt(ap, s, 0.25)
        assert a["cycle_time_min"] == pytest.approx(b["cycle_time_min"], rel=0.02)


@pytest.mark.parametrize("feature,msg", [
    ({"type": "pocket", "depth": 0.5}, "length"),
    ({"type": "pocket", "length": 3, "width": 2}, "depth"),
    ({"type": "pocket", "depth": 0.5, "area": 10, "perimeter": 5}, "too short"),
    ({"type": "pocket", "depth": 0.5, "length": 3, "width": 2, "corner_radius": 1.5}, "corner_radius"),
    ({"type": "pocket", "depth": 0.5, "length": 3, "width": 2, "island_area": 9}, "island_area"),
])
def test_validation(feature, msg):
    with pytest.raises(ValueError, match=msg):
        compare(*MATS[0], feature)


def test_tool_wider_than_pocket_is_skipped_and_all_wide_raises():
    r = compare(*MATS[0], dict(POCKET, width=0.4, length=2.0, corner_radius=0.05), tools=(T_HALF, T_QTR))
    assert all(o["tool"]["diameter"] == 0.25 for o in r["options"]) and r["skipped"]
    with pytest.raises(ValueError, match="fits"):
        compare(*MATS[0], dict(POCKET, width=0.2, length=2.0, corner_radius=0.05), tools=(T_HALF,))


def test_finish_mode_is_passed_to_toolwiz():
    r = compare(*MATS[0], dict(POCKET, finish_mode="accuracy"), tools=(T_QTR,))
    o = opt(r, "pocket_offset", 0.25)
    assert any("finish mode accuracy" in n for n in o["notes"])


def test_route_pocket():
    c = toolwiz_app.app.test_client()
    body = {"family": MATS[0][0], "alloy": MATS[0][1], "aggressiveness": 0.5, "runout": 0.0002, "model": "v2",
            "feature": POCKET, "candidate_tools": [T_QTR]}
    j = c.post("/api/strategy/compare", json=body, headers=HDR).get_json()
    assert j["success"] and len(j["options"]) == 2
    bad = c.post("/api/strategy/compare", json=dict(body, feature={"type": "pocket", "depth": 1}), headers=HDR)
    assert bad.status_code == 400


# ---- setup advisor: pocket and multiple stepovers ------------------------------------------------------------------

TOOL = {"diameter_in": 0.25, "flutes": 3, "flute_length_in": 0.75, "shank_diameter_in": 0.25, "stickout_in": 1.5, "description": "1/4 3FL"}


def advise(op, **kw):
    s = {"document": "t", "ops": [op]}
    return sa.advise(s, family=MATS[0][0], alloy=MATS[0][1], physics=toolwiz_app.physics,
                     machine_profile=toolwiz_app.active_machine(), **kw)["operations"][0]


def contour(count=4, so=0.06, feed="90 in/min", length=24):
    return {"op_id": "S > Slot", "name": "Slot2D", "strategy": "contour2d", "tool": TOOL,
            "params": {"tool_spindleSpeed": "12000 rpm", "tool_feedCutting": feed, "maximumStepdown": "0.25 in", "maximumStepover": f"{so} in"},
            "geometry": {"depth_in": 0.5, "toolpath_length_in": length, "multi_stepover": {"enabled": True, "count": count, "stepover_in": so},
                         "effective_cut_width_in": 0.25 + (count - 1) * so, "sources": {"effective_cut_width_in": "measured"}}}


def test_multi_stepover_overloaded_slot_pass_is_a_stop_and_apply_plan_uses_slot_numbers():
    o = advise(contour())
    ms = o["multi_stepover"]
    f = next(x for x in o["findings"] if x["code"] == "multi_stepover_overload")
    assert f["severity"] == "STOP" and "full slot" in f["detail"]
    sl = ms["slot_pass"]
    assert ms["safe_numbers"]["feed_ipm"] == sl["feed_ipm"] and ms["effective_cut_width_in"] == pytest.approx(0.43)
    assert o["apply_plan"]["recommended"]["tool_feedCutting"] == f"{sl['feed_ipm']:.2f} in/min"
    assert "stepover" not in o["apply_plan"]["recommended"]         # the op's own stepovers are kept
    assert sl["ae_in"] == 0.25 and ms["side_passes"]["ae_in"] == pytest.approx(0.06)
    assert any("Slotting means full radial width" in e for e in ms["explanation"])
    assert not any(x["code"] in ("chip_load_high", "chip_load_off") for x in o["findings"])
    assert o["geometry_sources"]["effective_cut_width_in"] == "measured"


def test_multi_stepover_feed_at_slot_numbers_is_fine_and_reports_the_side_headroom():
    base = advise(contour())["multi_stepover"]
    o = advise(contour(feed=f"{base['slot_pass']['feed_ipm']:.2f} in/min"))
    codes = [x["code"] for x in o["findings"]]
    assert "multi_stepover_overload" not in codes
    assert "multi_stepover_underfed" in codes or "multi_stepover_info" in codes or o["multi_stepover"]["side_over_slot_feed_x"] < 1.25
    t = o["multi_stepover"]["times"]
    assert t["single_op_at_slot_feed_min"] > 0 and o["multi_stepover"]["alternatives"]["adaptive"]["cycle_time_min"] > 0


def test_multi_stepover_off_or_single_is_a_normal_contour():
    op = contour()
    op["geometry"]["multi_stepover"]["enabled"] = False
    assert "multi_stepover" not in advise(op)
    assert "multi_stepover" not in advise(contour(count=1))


def test_pocket_metrics_drive_a_pocket_strategy_suggestion_and_sources():
    op = {"op_id": "S > Pocket", "name": "Pocket", "strategy": "adaptive2d", "tool": TOOL,
          "params": {"tool_spindleSpeed": "12000 rpm", "tool_feedCutting": "60 in/min", "maximumStepdown": "0.5 in", "optimalLoad": "0.05 in"},
          "geometry": {"depth_in": 0.75, "toolpath_length_in": 200, "pocket_area_in2": 5.7, "pocket_perimeter_in": 9.6,
                       "pocket_min_corner_radius_in": 0.125, "sources": {"pocket_area_in2": "measured"}}}
    r = sa.advise({"document": "t", "ops": [op]}, family=MATS[0][0], alloy=MATS[0][1], physics=toolwiz_app.physics,
                  machine_profile=toolwiz_app.active_machine())
    sug = r["strategy_suggestions"][0]
    assert sug["feature"]["type"] == "pocket" and sug["current_option"]["strategy"] == "pocket_adaptive"
    gs = r["operations"][0]["geometry_sources"]
    assert gs["pocket_area_in2"] == "measured" and gs["pocket_min_corner_radius_in"] == "measured"
    op["geometry"].pop("pocket_min_corner_radius_in")
    gs2 = advise(op)["geometry_sources"]
    assert gs2["pocket_min_corner_radius_in"] == "assumed"
