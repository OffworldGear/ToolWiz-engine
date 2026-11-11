"""Strategy planner (strategy_planner, routes_strategy) and the holder / tool advice wiring into the pipeline."""
import math
import os
import sys
import time

import pytest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, ROOT)

import app as toolwiz_app  # noqa: E402
import strategy_planner as sp  # noqa: E402
from pipeline import CutRequest, run_cut  # noqa: E402

HDR = {"X-ToolWiz-Client": "unit-test"}
MATERIALS = [("Aluminum - Wrought (6061)", "6061-T6"),
             ("Titanium Alloy", "Ti-6Al-4V"),
             ("Stainless - PH Series (17-4)", "17-4 PH (H 1025)")]
TOOL_L = {"diameter": 0.125, "flutes": 2, "flute_length": 0.375, "shank_diameter": 0.125, "stickout": 0.6}
TOOL_S = {"diameter": 0.0625, "flutes": 2, "flute_length": 0.1875, "shank_diameter": 0.125, "stickout": 0.4}


def cutout_request(family, alloy, agg=0.5, **kw):
    r = {"family": family, "alloy": alloy, "aggressiveness": agg, "runout": 0.0002, "model": "v2",
         "feature": {"type": "profile_cutout", "depth": 0.25, "length": 12.0,
                     "tabs": {"count": 4, "width": 0.1, "height": 0.04}},
         "candidate_tools": [TOOL_L, TOOL_S]}
    r.update(kw)
    return r


def compare(req):
    return sp.compare(req, physics=toolwiz_app.physics, machine_profile=toolwiz_app.active_machine())


def direct_cut(family, alloy, tool, operation, agg=0.5):
    """The same cut run straight through the pipeline, built independently of the planner."""
    mach = toolwiz_app.active_machine()
    geo = {"DC": tool["diameter"], "NOF": tool["flutes"], "LCF": tool["flute_length"],
           "SFDM": tool["shank_diameter"], "LB": tool["stickout"]}
    return run_cut(toolwiz_app.physics, CutRequest(
        family=family, alloy=alloy, tool="Carbide Endmill", geometry="Square", operation=operation, coating="Uncoated",
        diameter=tool["diameter"], flutes=tool["flutes"], flute_length=tool["flute_length"],
        shank_diameter=tool["shank_diameter"], stickout=tool["stickout"], aggressiveness=agg,
        max_rpm=mach["max_rpm"], max_hp=mach["max_hp"], runout=0.0002,
        fusion_tool={"type": "flat end mill", "unit": "inches", "geometry": geo}, model="v2", machine_profile=mach))


@pytest.fixture(scope="module", params=MATERIALS, ids=["6061", "Ti-6Al-4V", "17-4"])
def cutout(request):
    fam, alloy = request.param
    return fam, alloy, compare(cutout_request(fam, alloy))


def by_strategy(res, strategy, d):
    for o in res["options"]:
        if o["strategy"] == strategy and abs(o["tool"]["diameter"] - d) < 1e-9:
            return o
    raise AssertionError(f"no {strategy} option for D {d}")


def test_profile_cutout_three_options_positive_finite(cutout):
    fam, alloy, res = cutout
    strategies = sorted(o["strategy"] for o in res["options"])
    assert strategies == ["adaptive", "contour_slot", "contour_slot_small_tool"]
    for o in res["options"]:
        for k in ("cycle_time_min", "path_length_in", "rpm", "feed_ipm", "relative_tool_life", "tool_wear_per_part"):
            assert o[k] is not None and math.isfinite(o[k]) and o[k] > 0, (o["name"], k, o[k])
        assert o["levels"] >= 1
        assert o["fusion_hints"]["fusion_strategy"]
        assert o["fusion_hints"]["stock_to_leave"]
        assert o["fusion_hints"]["ramp"]
    assert min(o["tool_wear_per_part"] for o in res["options"] if o["feasible"]) == pytest.approx(1.0)
    assert res["tab_advice"] and res["assumptions"] and res["reasoning"]


def test_option_numbers_equal_run_cut(cutout):
    fam, alloy, res = cutout
    for strategy, tool, op in (("contour_slot", TOOL_L, "Slotting"), ("contour_slot_small_tool", TOOL_S, "Slotting"),
                               ("adaptive", TOOL_S, "Adaptive Roughing")):
        o = by_strategy(res, strategy, tool["diameter"])
        r = direct_cut(fam, alloy, tool, op)
        assert o["rpm"] == round(r.rpm)
        assert o["feed_ipm"] == pytest.approx(r.feed_ipm, abs=5e-4)
        assert o["ap"] == pytest.approx(r.doc, abs=5e-6)
        assert o["ae"] == pytest.approx(r.woc, abs=5e-6)
        assert o["levels"] == math.ceil(0.25 / min(r.doc, tool["flute_length"]) - 1e-9)
        assert o["stock_to_leave_in"]["radial"] == r.recommended_radial_stock_in


def test_cycle_time_covers_path_over_feed(cutout):
    fam, alloy, res = cutout
    for o in res["options"]:
        # cutting path / feed is a floor for the time; links and ramps only add
        assert o["cycle_time_min"] >= o["path_length_in"] / o["feed_ipm"] * 0.9 or o["strategy"] == "adaptive"
        assert o["cycle_time_min"] == pytest.approx(sum(o["time_breakdown_min"].values()), abs=2e-4)
    ad = by_strategy(res, "adaptive", 0.0625)
    assert ad["time_breakdown_min"]["links_and_retracts"] > 0.05 * ad["cycle_time_min"]   # return arcs at link feed


def test_tabs_shorten_only_bottom_levels():
    base = cutout_request(*MATERIALS[0])
    no_tabs = dict(base, feature=dict(base["feature"], tabs={"count": 0}))
    with_tabs = compare(base)
    without = compare(no_tabs)
    a = by_strategy(with_tabs, "contour_slot", 0.125)
    b = by_strategy(without, "contour_slot", 0.125)
    assert a["tabbed_levels"] >= 1 and b["tabbed_levels"] == 0
    assert a["path_length_in"] < b["path_length_in"]
    # tabs skip at most count x (width + D) per tabbed level
    assert b["path_length_in"] - a["path_length_in"] <= a["tabbed_levels"] * 4 * (0.1 + 0.125) + 1e-6
    two_d = compare(dict(base, feature=dict(base["feature"], tabs=dict(base["feature"]["tabs"], style="2d"))))
    assert by_strategy(two_d, "contour_slot", 0.125)["time_breakdown_min"]["ramp_entries"] >= a["time_breakdown_min"]["ramp_entries"]


@pytest.mark.parametrize("agg", [0.0, 0.5, 1.0])
def test_recommendation_obeys_wear_ratio_rule(agg):
    for fam, alloy in MATERIALS:
        res = compare(cutout_request(fam, alloy, agg))
        allowed = res["wear_ratio_limit"]
        assert allowed == pytest.approx({0.0: 1.1, 0.5: 1.3, 1.0: 2.0}[agg])
        feas = [o for o in res["options"] if o["feasible"]]
        rec = next(o for o in res["options"] if o["name"] == res["recommended"])
        ok = [o for o in feas if o["tool_wear_per_part"] <= allowed + 1e-9]
        assert rec in ok
        assert rec["cycle_time_min"] == min(o["cycle_time_min"] for o in ok)
        assert any("saved" in line or "least-wear" in line for line in res["reasoning"])


def test_allowed_ratio_interpolates():
    assert sp.allowed_wear_ratio(0.0) == pytest.approx(1.1)
    assert sp.allowed_wear_ratio(0.25) == pytest.approx(1.2)
    assert sp.allowed_wear_ratio(0.75) == pytest.approx(1.65)
    assert sp.allowed_wear_ratio(1.0) == pytest.approx(2.0)


def test_slot_feature_options():
    req = {"family": MATERIALS[0][0], "alloy": MATERIALS[0][1], "aggressiveness": 0.5,
           "feature": {"type": "slot", "width": 0.25, "depth": 0.25, "length": 3.0},
           "candidate_tools": [{"diameter": 0.25, "flutes": 2, "flute_length": 0.5, "shank_diameter": 0.25, "stickout": 1.0},
                               TOOL_L, TOOL_S]}
    res = compare(req)
    names = {o["strategy"] for o in res["options"]}
    assert {"contour_slot", "contour_slot_side_passes", "adaptive"} <= names
    full = next(o for o in res["options"] if o["strategy"] == "contour_slot")
    assert full["tool"]["diameter"] == 0.25 and len(full["phases"]) == 1
    side = next(o for o in res["options"] if o["strategy"] == "contour_slot_side_passes" and o["tool"]["diameter"] == 0.125)
    assert [p["name"] for p in side["phases"]] == ["centre slot", "side roughing", "wall finishing (both walls)"]
    assert all(o["cycle_time_min"] > 0 for o in res["options"])
    big = dict(req, candidate_tools=[dict(TOOL_L, diameter=0.5, flute_length=1.0, shank_diameter=0.5, stickout=2.0)])
    with pytest.raises(ValueError):
        compare(big)


def test_tslot_titanium_shop_cutters():
    ids = ["klot_8x0.5", "harvey_867330", "klot_8x1.6", "klot_4x0.5", "klot_6x2"]
    req = {"family": "Titanium Alloy", "alloy": "Ti-6Al-4V", "aggressiveness": 0.5, "runout": 0.0002,
           "feature": {"type": "tslot", "slot_height": 0.0787, "radial_depth": 0.03, "length": 2.0},
           "candidate_tools": [{"id": i} for i in ids]}
    res = compare(req)
    assert len(res["options"]) == 5
    for o in res["options"]:
        assert o["cycle_time_min"] > 0 and math.isfinite(o["cycle_time_min"])
        assert o["radial_passes"] >= 1 and o["levels"] >= 1 and o["neck_deflection_in"] >= 0
        assert o["relative_tool_life"] > 0 and o["tool_wear_per_part"] >= 1.0 - 1e-9
    k = next(o for o in res["options"] if o["tool"]["id"] == "klot_8x0.5")
    h = next(o for o in res["options"] if o["tool"]["id"] == "harvey_867330")
    assert k["provisional_geometry"] and not h["provisional_geometry"]
    assert "physics only" in k["data_basis"] and "vendor data" in h["data_basis"]
    assert k["levels"] > h["levels"]                       # 0.5 mm kerf needs more Z cuts than the 1.6 mm kerf
    assert any("harvey_867330" in line and "vendor data" in line for line in res["reasoning"])
    assert res["recommended"]
    # a radial depth beyond the neck clearance makes the cutter infeasible
    deep = compare(dict(req, feature=dict(req["feature"], radial_depth=0.2)))
    assert all(not o["feasible"] for o in deep["options"] if o["tool"]["id"] != "harvey_867330")


def test_tslot_by_geometry():
    req = {"family": "Titanium Alloy", "alloy": "Ti-6Al-4V", "aggressiveness": 0.5,
           "feature": {"type": "tslot", "slot_height": 0.08, "radial_depth": 0.03, "length": 1.0},
           "candidate_tools": [{"geometry": {"diameter_mm": 8, "kerf_mm": 2, "neck_diameter_mm": 4.6, "reach_mm": 10, "teeth": 4}}]}
    res = compare(req)
    assert res["options"][0]["cycle_time_min"] > 0


@pytest.mark.parametrize("model", ["v1", "v2"])
def test_advice_fields_in_calculate(model):
    c = toolwiz_app.app.test_client()
    body = {"family": "Aluminum - Wrought (6061)", "alloy": "6061-T6", "tool": "Carbide Endmill", "geometry": "Square",
            "operation": "Slotting", "diameter": 0.125, "flutes": 2, "fluteLength": 0.375, "shankDiameter": 0.125,
            "stickout": 0.6, "aggressiveness": 50, "model": model}
    for url in ("/api/calculate", "/api/calculate_for_fusion"):
        r = c.post(url, json=body, headers=HDR)
        assert r.status_code == 200
        j = r.get_json()
        assert set(j["holder_advice"]) >= {"required_tir_in", "class", "recommended", "acceptable", "avoid", "reason",
                                           "high_speed_spindle", "sources"}
        assert isinstance(j["tool_advice"], list)
        for t in j["tool_advice"]:
            assert {"vendor", "series", "applies_to", "why", "expected_gain", "evidence"} <= set(t)


def test_advice_hook_is_cheap():
    r = direct_cut(*MATERIALS[0], TOOL_L, "Slotting")
    import advice_wiring
    req = build_req = sp.build_cut_request(
        {"family": MATERIALS[0][0], "alloy": MATERIALS[0][1], "aggressiveness": 0.5, "runout": 0.0002, "model": "v2"},
        sp._tool_spec(TOOL_L, 0), "Slotting")
    advice_wiring.fill_advice(r, req)          # warm
    t = time.perf_counter()
    for _ in range(20):
        advice_wiring.fill_advice(r, req)
    assert (time.perf_counter() - t) / 20 < 0.02
    assert r.holder_advice and isinstance(r.tool_advice, list)


class TestEndpoint:
    def setup_method(self):
        self.c = toolwiz_app.app.test_client()

    def test_ok(self):
        r = self.c.post("/api/strategy/compare", json=cutout_request(*MATERIALS[0]), headers=HDR)
        assert r.status_code == 200
        j = r.get_json()
        assert j["success"] and j["recommended"] and len(j["options"]) == 3
        assert {"name", "tool", "strategy", "levels", "ap", "ae", "rpm", "feed_ipm", "path_length_in", "cycle_time_min",
                "relative_tool_life", "tool_wear_per_part", "risks", "notes", "fusion_hints"} <= set(j["options"][0])

    def test_requires_client_header(self):
        r = self.c.post("/api/strategy/compare", json=cutout_request(*MATERIALS[0]))
        assert r.status_code == 403

    @pytest.mark.parametrize("mutate,needle", [
        (lambda b: b.pop("family"), "family"),
        (lambda b: b.update(aggressiveness=1.5), "aggressiveness"),
        (lambda b: b.update(candidate_tools=[]), "candidate_tools"),
        (lambda b: b["feature"].update(type="pocket"), "pocket"),
        (lambda b: b["feature"].update(type="bogus"), "feature.type"),
        (lambda b: b["feature"].pop("depth"), "depth"),
        (lambda b: b["feature"]["tabs"].update(height=0.5), "tab height"),
        (lambda b: b["candidate_tools"][0].update(diameter=-1), "diameter"),
        (lambda b: b.update(model="v9"), "model"),
    ])
    def test_bad_input(self, mutate, needle):
        body = cutout_request(*MATERIALS[0])
        mutate(body)
        r = self.c.post("/api/strategy/compare", json=body, headers=HDR)
        assert r.status_code == 400
        assert needle in r.get_json()["error"]

    def test_not_json(self):
        r = self.c.post("/api/strategy/compare", data="x", headers=HDR)
        assert r.status_code == 400
