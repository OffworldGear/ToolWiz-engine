"""Tool recommender (tool_recommender, routes_tool_recommender, the Setup Advisor ``better_tool`` finding, the chat and MCP tools).

Every number is an engine number (pipeline.run_cut, model v2, 50 %). The honesty rules are tested as wording: a brand gain names the
vendor chart and says it is published, not measured; a catalog tool is a cited geometry; an unbranded tool is compared on the default
chart; the flute-count chip-space caveat disappears as soon as the engine result carries a ``chip_space`` block."""
import copy
import json
import os
import sys

import pytest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, ROOT)

import app as toolwiz_app  # noqa: E402
import setup_advisor as sa  # noqa: E402
import strategy_planner  # noqa: E402
import tool_recommender as tr  # noqa: E402

HDR = {"X-ToolWiz-Client": "unit-test"}
F174 = ("Stainless - PH Series (17-4)", "17-4 PH")
FTI = ("Titanium Alloy", "Ti-6Al-4V")
FAL = ("Aluminum - Wrought (6061)", "6061")
ARTIFACT = "data/model_v2/catalog_geometries.json"


@pytest.fixture(autouse=True)
def _fresh_cache():
    tr.clear_cache()
    yield
    tr.clear_cache()


def haas_eighth(fam, **kw):
    """The owner's HAAS 1/8" 4FL tool with a .015" corner radius (an edge break at 12 % of D), slotting at 50 %, unbranded for ToolWiz."""
    body = {"family": fam[0], "alloy": fam[1], "operation": "Slotting", "diameter": 0.125, "flutes": 4, "flute_length": 0.375,
            "shank_diameter": 0.125, "stickout": 0.5, "corner_radius": 0.015, "brand": "Haas Automation", "coating": "AlTiN",
            "aggressiveness": 0.5, "model": "v2", "sources": ["catalog"]}
    body.update(kw)
    return body


def lib_tool(desc, d, z, flen, cr=0.0, ttype="flat end mill", vendor=None, number=None, coating=None, stick=None):
    return {"description": desc, "raw_type": ttype, "type": ttype, "diameter_in": d, "flutes": z, "flute_length_in": flen,
            "shank_diameter_in": d, "stickout_in": stick, "corner_radius_in": cr, "coating": coating, "vendor": vendor, "number": number,
            "reach_in": None, "library": "test", "is_carbide": True}


def cut_for(body):
    spec = tr.parse_request(body)
    return tr.Cut(spec, strategy_planner.machine_defaults(None))


# ---- input ------------------------------------------------------------------------------------------------------------

def test_request_validation():
    with pytest.raises(ValueError, match="family"):
        tr.recommend({"operation": "Slotting", "diameter": 0.125})
    with pytest.raises(ValueError, match="diameter"):
        tr.recommend({"family": F174[0], "operation": "Slotting"})
    with pytest.raises(ValueError, match="operation"):
        tr.recommend({"family": F174[0], "diameter": 0.125})
    with pytest.raises(ValueError, match="unknown source"):
        tr.recommend({"family": F174[0], "operation": "Slotting", "diameter": 0.125, "sources": ["web"]})
    with pytest.raises(ValueError, match="not one the recommender covers"):
        tr.recommend({"family": F174[0], "operation": "Tapping", "diameter": 0.125})
    assert tr.op_info("Slotting / Tab Milling") == ("Slotting", "slot")
    assert tr.op_info("3D Adaptive Clearing")[1] == "adaptive"
    assert tr.op_info("Wall Finishing (Deep DOC)")[1] == "finish"
    assert tr.op_info("Contour (Roughing)") == ("Roughing", "rough")


def test_edge_break_rule_matches_the_setup_advisor():
    assert tr.EDGE_BREAK_MAX_FRACTION == sa.EDGE_BREAK_MAX_FRACTION


def test_catalog_geometries_file_is_current():
    import importlib.util
    spec = importlib.util.spec_from_file_location("bcg", os.path.join(ROOT, "tools", "build_catalog_geometries.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    assert mod.main(["--check"]) == 0


# ---- candidate generation ---------------------------------------------------------------------------------------------

def test_library_candidates_respect_width_reach_and_tool_family():
    cut = cut_for(haas_eighth(F174, max_diameter_in=0.25, min_reach_in=0.3))
    tools = [
        lib_tool("1/4 4FL flat", 0.25, 4, 0.75, number=1),
        lib_tool("3/8 bullnose", 0.375, 4, 1.0, cr=0.06, ttype="bull nose end mill", number=2),          # wider than the 1/4" limit
        lib_tool("3/16 short", 0.1875, 4, 0.2, number=3),                                                # flute shorter than the 0.3" reach
        lib_tool("3/16 ok", 0.1875, 4, 0.5, number=4),
        lib_tool("Renishaw probe", 0.25, 1, 0.5, ttype="probe", number=5),
        lib_tool("keyseat 1/4", 0.25, 8, 0.031, ttype="slot mill", number=6),
        lib_tool("1/4 drill", 0.25, 2, 1.0, ttype="drill", number=7),
        lib_tool("1/4 tap", 0.25, 3, 0.5, ttype="tap", number=8),
        lib_tool("face mill", 0.25, 5, 0.25, ttype="face mill", number=9),
        lib_tool("lollipop", 0.25, 2, 0.25, ttype="lollipop mill", number=10),
        lib_tool("1/4 ball", 0.25, 2, 0.5, ttype="ball end mill", number=11),
        lib_tool("1/16 flat", 0.0625, 2, 0.19, number=12),                                               # smaller than the current tool
        lib_tool("6mm aluminum 3FL", 0.2362, 3, 0.79, number=13),                                        # aluminum-only in 17-4
    ]
    cands, skipped = tr.library_candidates(cut, tools)
    nums = sorted(c["library"]["number"] for c in cands)
    assert nums == [1, 4]
    assert all(c["diameter"] <= 0.25 + 1e-9 and c["flute_length"] >= 0.3 for c in cands)
    assert any("3/8 bullnose" in s and "wider" in s for s in skipped)
    assert any("3/16 short" in s and "reach" in s for s in skipped)
    assert any("aluminum" in s for s in skipped)


def test_probe_ops_and_non_end_mills_are_never_candidates():
    for ttype in ("probe", "holder", "drill", "tap", "reamer", "chamfer mill", "dovetail mill", "slot mill", "thread mill", "spot drill"):
        cands, _ = tr.library_candidates(cut_for(haas_eighth(F174, max_diameter_in=0.5)), [lib_tool(ttype, 0.25, 2, 0.5, ttype=ttype)])
        assert not cands, ttype


def test_library_never_offers_the_current_tool_itself():
    cut = cut_for(haas_eighth(F174, max_diameter_in=0.25))
    same = lib_tool("1/8 4FL Haas", 0.125, 4, 0.375, cr=0.015, ttype="bull nose end mill", vendor="Haas Automation")
    cands, _ = tr.library_candidates(cut, [same])
    assert not cands


def test_no_candidate_is_wider_than_the_limit_or_shorter_than_the_reach():
    r = tr.recommend(haas_eighth(F174, max_diameter_in=0.1875, min_reach_in=0.4, sources=["catalog"]), physics=toolwiz_app.physics)
    seen = r["alternatives"] + r["below_threshold"]
    assert seen
    assert all(a["diameter"] <= 0.1875 + 1e-6 for a in seen)
    assert all(a["flute_length"] >= 0.4 - 1e-9 for a in seen)


def test_full_slot_without_a_width_limit_tries_the_same_diameter_only():
    r = tr.recommend(haas_eighth(F174), physics=toolwiz_app.physics)
    assert all(abs(a["diameter"] - 0.125) < 1e-6 for a in r["alternatives"] + r["below_threshold"])
    assert any("slot is taken to be as wide as the current tool" in a for a in r["assumptions"])


def test_larger_tools_up_to_the_limit_and_the_assumption_when_no_limit_is_known():
    r = tr.recommend(haas_eighth(F174, operation="Roughing", full_slot=False, max_diameter_in=0.25), physics=toolwiz_app.physics)
    bigger = [a for a in r["alternatives"] if a["diameter"] > 0.126]
    assert bigger and all(a["diameter"] <= 0.25 + 1e-6 for a in bigger)
    r2 = tr.recommend(haas_eighth(F174, operation="Roughing", full_slot=False), physics=toolwiz_app.physics)
    big2 = [a for a in r2["alternatives"] + r2["below_threshold"] if a["diameter"] > 0.126]
    assert big2 and all(a["diameter"] <= 0.25 + 1e-6 for a in big2)             # twice the current diameter at most
    assert any("no feature size limit given" in a for a in r2["assumptions"])
    assert any("No feature size limit was given" in c for a in big2 for c in a["caveats"])


# ---- gains, thresholds, honesty ---------------------------------------------------------------------------------------

@pytest.mark.parametrize("fam", [F174, FTI])
def test_small_slot_in_17_4_and_titanium_has_a_brand_alternative_that_names_its_chart(fam):
    r = tr.recommend(haas_eighth(fam), physics=toolwiz_app.physics)
    brand = [a for a in r["alternatives"] if "brand" in a["changes"] and (a["vendor_basis"] or {}).get("mode") == "brand"]
    assert brand and brand[0]["gain_pct"] > 30
    a = brand[0]
    assert a["source"] == "catalog" and a["brand"] and f"The {a['brand']} chart" in a["why"]
    assert "published chart" in a["why"] and "not a measured tool test" in a["why"]
    assert a["why"].endswith(".") and a["why"].count(". ") == 0                    # one sentence
    assert any("not a measured tool test" in c for c in a["caveats"])
    assert any("cited catalog row" in c and "in stock" in c for c in a["caveats"])
    assert a["rpm"] > 0 and a["feed"] > 0 and a["ap"] > 0 and a["ae"] > 0 and a["mrr"] > 0
    assert all(x["gain_pct"] >= r["min_gain_pct"] for x in r["alternatives"])
    assert r["alternatives"] == sorted(r["alternatives"], key=lambda x: (x["short_flute"], -x["gain_pct"], x["source"] != "library",
                                                                          x["diameter"], x["flutes"], str(x.get("brand") or "")))
    # the unbranded / unknown-brand comparison is stated
    assert "Haas Automation" in r["current"]["basis"] and "conservative default chart" in r["current"]["basis"]
    assert any("conservative default chart" in d for d in r["disclaimers"])
    assert any("published chart" in d for d in r["disclaimers"]) and any("exists or is in stock" in d or "in stock" in d for d in r["disclaimers"])


def test_threshold_filtering_and_below_threshold_list():
    lo = tr.recommend(haas_eighth(F174, min_gain_pct=0), physics=toolwiz_app.physics)
    hi = tr.recommend(haas_eighth(F174, min_gain_pct=500), physics=toolwiz_app.physics)
    mid = tr.recommend(haas_eighth(F174, min_gain_pct=30), physics=toolwiz_app.physics)
    assert len(lo["alternatives"]) >= len(mid["alternatives"]) > 0
    assert hi["alternatives"] == [] and hi["not_recommended_reasons"] and hi["summary"].startswith("No tool change is worth it")
    assert hi["below_threshold"] and hi["below_threshold"][0]["gain_pct"] < 500
    assert all(a["gain_pct"] >= 30 for a in mid["alternatives"]) and all(b["gain_pct"] < 30 for b in mid["below_threshold"])


def test_spindle_limited_aluminum_returns_no_brand_alternative_and_says_why():
    r = tr.recommend(haas_eighth(FAL, corner_radius=0.0, flutes=4, flute_length=0.375, coating=None), physics=toolwiz_app.physics)
    assert r["current"]["is_spindle_limited"] and r["current"]["rpm"] == 16000
    assert not any("brand" in a["changes"] for a in r["alternatives"])
    assert r["alternatives"] == []
    reason = r["not_recommended_reasons"][0]
    assert reason.startswith("spindle-limited at 16,000 rpm") and "brand makes no difference" in reason
    assert r["summary"].startswith("No tool change is worth it: spindle-limited")


def test_library_tool_is_preferred_when_it_passes():
    tools = [lib_tool("1/4 4FL flat", 0.25, 4, 0.75, number=7)]
    r = tr.recommend(haas_eighth(F174, max_diameter_in=0.25, sources=["library", "catalog"], operation="Roughing", full_slot=False),
                     physics=toolwiz_app.physics, library_tools=tools)
    lib = r["best_library"]
    assert lib and lib["source"] == "library" and lib["library_tool"]["number"] == 7 and lib["gain_pct"] >= 30
    assert "your T7 1/4 4FL flat" in lib["why"].lower() or "Your T7 1/4 4FL flat" in lib["why"]
    top = r["alternatives"][0]
    same_gain = [a for a in r["alternatives"] if abs(a["gain_pct"] - top["gain_pct"]) < 1e-9]
    assert any(a["source"] == "library" for a in same_gain) or top["gain_pct"] >= lib["gain_pct"]
    # at equal gain the library tool sorts ahead of a catalog tool
    cat_same = [a for a in r["alternatives"] if a["source"] == "catalog" and a["gain_pct"] == lib["gain_pct"] and a["diameter"] == lib["diameter"]]
    for c in cat_same:
        assert r["alternatives"].index(lib) < r["alternatives"].index(c)


def test_sources_switch():
    tools = [lib_tool("1/4 4FL flat", 0.25, 4, 0.75, number=7)]
    only_lib = tr.recommend(haas_eighth(F174, max_diameter_in=0.25, sources=["library"], operation="Roughing", full_slot=False),
                            physics=toolwiz_app.physics, library_tools=tools)
    assert {a["source"] for a in only_lib["alternatives"] + only_lib["below_threshold"]} == {"library"}
    only_cat = tr.recommend(haas_eighth(F174, max_diameter_in=0.25, sources=["catalog"], operation="Roughing", full_slot=False),
                            physics=toolwiz_app.physics, library_tools=tools)
    assert {a["source"] for a in only_cat["alternatives"] + only_cat["below_threshold"]} == {"catalog"}


def test_real_corner_radius_gets_no_brand_alternative_and_says_so():
    r = tr.recommend(haas_eighth(F174, corner_radius=0.0375, max_diameter_in=0.125), physics=toolwiz_app.physics)
    assert not any("brand" in a["changes"] for a in r["alternatives"] + r["below_threshold"])
    assert any("real corner radius" in s for s in r["skipped"])
    r2 = tr.recommend(haas_eighth(F174, corner_radius=0.0375, max_diameter_in=0.125, keep_corner_radius=False), physics=toolwiz_app.physics)
    sq = [a for a in r2["alternatives"] if "square" in a["changes"]]
    assert sq and any("corner radius" in c and "dropped" in c for c in sq[0]["caveats"])


def test_edge_break_radius_is_treated_as_square_like_the_setup_advisor():
    r = tr.recommend(haas_eighth(F174), physics=toolwiz_app.physics)
    assert any("edge break" in a for a in r["assumptions"])
    assert r["current"]["tool"]["geometry"] == "Square"


def test_flute_count_caveat_in_a_full_slot_and_it_disappears_with_a_chip_space_block(monkeypatch):
    body = haas_eighth(FTI, flutes=3, min_gain_pct=0)
    r = tr.recommend(body, physics=toolwiz_app.physics)
    more = [a for a in r["alternatives"] + r["below_threshold"] if a["flutes"] > 3]
    assert more
    assert all(any("does not yet limit chip space by flute count" in c for c in a["caveats"]) for a in more)
    assert not any("chip space" in c for a in r["alternatives"] + r["below_threshold"] if a["flutes"] <= 3 for c in a["caveats"])

    import pipeline
    real = pipeline.run_cut

    def with_chip_space(physics, req):
        res = real(physics, req)
        res.chip_space = {"flutes": req.flutes, "limit": "stub"}
        return res
    monkeypatch.setattr(pipeline, "run_cut", with_chip_space)
    tr.clear_cache()
    r2 = tr.recommend(body, physics=toolwiz_app.physics)
    more2 = [a for a in r2["alternatives"] + r2["below_threshold"] if a["flutes"] > 3]
    assert more2
    assert not any("chip space" in c for a in more2 for c in a["caveats"])
    assert all(a.get("chip_space") for a in more2) and r2["current"].get("chip_space")


def test_flute_caveat_is_only_for_full_slots():
    cut = cut_for(haas_eighth(FTI, flutes=3, operation="Roughing", full_slot=False))
    cand = {"flutes": 5}

    class R:
        pass
    assert tr._chip_space_caveat(cut, cand, R(), R()) is None
    cut2 = cut_for(haas_eighth(FTI, flutes=3))
    assert "chip space" in tr._chip_space_caveat(cut2, cand, R(), R())
    r = R()
    r.chip_space = {"x": 1}
    assert tr._chip_space_caveat(cut2, cand, r, R()) is None
    r3 = R()
    r3.v2 = {"chip_space": {"x": 1}}
    assert tr._chip_space_caveat(cut2, cand, R(), r3) is None
    assert tr._chip_space_caveat(cut2, {"flutes": 2}, R(), R()) is None


# ---- finishing --------------------------------------------------------------------------------------------------------

def test_finishing_is_compared_at_the_same_ra_target_and_reports_ra_and_wall_error():
    body = {"family": F174[0], "alloy": F174[1], "operation": "Finishing", "diameter": 0.25, "flutes": 4, "flute_length": 0.75, "stickout": 1.0,
            "coating": "AlTiN", "model": "v2", "finish_mode": "surface", "target_ra": 32, "max_diameter_in": 0.5, "min_reach_in": 0.5,
            "sources": ["catalog"], "min_gain_pct": 0}
    r = tr.recommend(body, physics=toolwiz_app.physics)
    assert r["kind"] == "finishing" and r["rate_metric"] == "finish_wall_area_rate_in2_min"
    cur = r["current"]["finish"]
    assert cur["target_ra_uin"] == 32 and cur["mode"] == "surface" and cur["meets_targets"]
    allalts = r["alternatives"] + r["below_threshold"]
    assert allalts
    for a in allalts:
        f = a["finish"]
        assert f["target_ra_uin"] == 32 and f["wall_tolerance_in"] == cur["wall_tolerance_in"]
        assert f["predicted_ra_uin"] <= 32 * 1.001 and f["predicted_wall_error_in"] <= f["wall_tolerance_in"] * 1.001
        assert f["meets_targets"] and a["vendor_basis"] is not None and "feasible" in a and "limited_by" in a and "deflection_in" in a
    assert "finish rate" in r["alternatives"][0]["why"] if r["alternatives"] else True


def test_floor_finish_uses_the_stepover_area_rate():
    body = {"family": F174[0], "alloy": F174[1], "operation": "Finishing", "diameter": 0.25, "flutes": 4, "flute_length": 0.75, "stickout": 1.0,
            "model": "v2", "finish_mode": "surface", "target_ra": 32, "sources": ["catalog"], "max_runs": 3, "geometry": "Ball"}
    r = tr.recommend(body, physics=toolwiz_app.physics)
    assert r["rate_metric"] in ("finish_area_rate_in2_min", "finish_wall_area_rate_in2_min")
    assert r["current"]["rate"] > 0


# ---- bounds and determinism -------------------------------------------------------------------------------------------

def test_engine_run_cap_is_respected(monkeypatch):
    import pipeline
    calls = []
    real = pipeline.run_cut
    monkeypatch.setattr(pipeline, "run_cut", lambda p, r: (calls.append(1), real(p, r))[1])
    r = tr.recommend(haas_eighth(F174, max_diameter_in=0.375, max_runs=5), physics=toolwiz_app.physics)
    assert r["engine_runs"] <= 5 and len(calls) <= 5 and r["run_cap"] == 5
    assert any("engine-run cap reached" in s for s in r["skipped"])
    assert tr.MAX_RUNS <= 40
    tr.clear_cache()
    calls.clear()
    full = tr.recommend(haas_eighth(F174, max_diameter_in=0.375), physics=toolwiz_app.physics)
    assert full["engine_runs"] <= tr.MAX_RUNS and len(calls) == full["engine_runs"]


def test_shared_budget_is_decremented_and_stops_the_run():
    budget = {"runs": 4}
    r = tr.recommend(haas_eighth(F174, max_diameter_in=0.375), physics=toolwiz_app.physics, budget=budget, run_cache={})
    assert budget["runs"] == 0 and r["engine_runs"] == 4
    with pytest.raises(ValueError, match="run budget used up|could not run"):
        tr.recommend(haas_eighth(F174), physics=toolwiz_app.physics, budget={"runs": 0}, run_cache={})


def test_deterministic_and_cached(monkeypatch):
    import pipeline
    calls = []
    real = pipeline.run_cut
    monkeypatch.setattr(pipeline, "run_cut", lambda p, r: (calls.append(1), real(p, r))[1])
    a = tr.recommend(haas_eighth(F174), physics=toolwiz_app.physics)
    n = len(calls)
    b = tr.recommend(haas_eighth(F174), physics=toolwiz_app.physics)
    assert len(calls) == n and a == b                                      # cached by request
    tr.clear_cache()
    c = tr.recommend(haas_eighth(F174), physics=toolwiz_app.physics)
    assert len(calls) == 2 * n and c == a                                  # recomputed, same answer


def test_stickout_rule_is_the_same_for_every_candidate():
    r = tr.recommend(haas_eighth(F174, max_diameter_in=0.25, min_gain_pct=0), physics=toolwiz_app.physics)
    assert r["current"]["tool"]["stickout_in"] == 0.5
    assert all(a["stickout"] == 0.5 for a in r["alternatives"] + r["below_threshold"])
    assert any("same stickout" in a or "current tool's stickout" in a for a in r["assumptions"])
    r2 = tr.recommend(haas_eighth(F174, stickout=None, max_diameter_in=0.25, min_gain_pct=0), physics=toolwiz_app.physics)
    assert any("scales with the diameter" in a for a in r2["assumptions"])
    big = [a for a in r2["alternatives"] + r2["below_threshold"] if a["diameter"] > 0.2]
    small = [a for a in r2["alternatives"] + r2["below_threshold"] if a["diameter"] < 0.13]
    if big and small:
        assert max(a["stickout"] for a in big) > min(a["stickout"] for a in small)


def test_cycle_time_with_a_toolpath_length():
    r = tr.recommend(haas_eighth(F174, toolpath_length_in=24.0, min_reach_in=0.25, min_gain_pct=0), physics=toolwiz_app.physics)
    assert r["current"]["cycle_time_min"] > 0
    best = r["alternatives"][0]
    assert best["cycle_time_min"] < r["current"]["cycle_time_min"] and best["cycle_time_saved_pct"] > 0


# ---- the Setup Advisor ------------------------------------------------------------------------------------------------

def _setup(strategy="contour2d", geometry=None, tool=None, name="Slot contour"):
    t = tool or {"type": "bull nose end mill", "description": '1/8" 4FL HI PERF EM W .015" RADIUS', "vendor": "Haas Automation", "unit": "inches",
                 "geometry": {"DC": 0.125, "NOF": 4, "LCF": 0.375, "SFDM": 0.125, "LB": 0.46875, "RE": 0.015}}
    return {"document": "t", "ops": [
        {"setup": "S1", "name": name, "path": f"S1 > {name}", "strategy": strategy, "tool": t,
         "params": {"tool_spindleSpeed": "8000 rpm", "tool_feedCutting": "20 in/min", "maximumStepdown": "0.25 in"},
         "geometry": geometry or {"slot_width_in": 0.25, "depth_in": 0.25, "toolpath_length_in": 8}}]}


def _advise(setup, **kw):
    kw.setdefault("family", F174[0])
    kw.setdefault("alloy", F174[1])
    kw.setdefault("physics", toolwiz_app.physics)
    kw.setdefault("machine_profile", toolwiz_app.active_machine())
    kw.setdefault("model", "v2")
    kw.setdefault("strategies", False)
    kw.setdefault("runout", 0.0002)
    return sa.advise(setup, **kw)


def test_setup_advisor_adds_one_better_tool_finding_from_the_owners_library():
    out = _advise(_setup(strategy="slot", name="Slot"))
    op = out["operations"][0]
    better = [f for f in op["findings"] if f["code"] == "better_tool"]
    assert len(better) == 1 and better[0]["severity"] == "INFO"
    blk = op["tool_alternatives"]
    assert blk["best_library"] and blk["best_library"]["source"] == "library"
    assert blk["best_library"]["diameter"] <= 0.25 + 1e-9                  # the slot is 1/4" wide
    assert "Best of your library" in better[0]["detail"] and blk["best_library"]["library_tool"]["description"] in better[0]["detail"]
    assert "published chart" in better[0]["detail"] or "not a measured tool test" in better[0]["detail"] or "cited" in better[0]["detail"]
    assert blk["limits_from"]["max_diameter_in"] == "slot width" and blk["limits_from"]["min_reach_in"] == "feature depth"
    assert better[0]["numbers"]["best_gain_pct"] == blk["best_library"]["gain_pct"] or better[0]["numbers"]["best_gain_pct"] >= blk["best_library"]["gain_pct"]
    assert blk["engine_runs"] <= sa.ALT_RUNS_PER_OP


def test_setup_advisor_finding_numbers_are_engine_numbers_the_guard_accepts():
    from toolwiz_common import numeric_guard
    out = _advise(_setup(strategy="slot", name="Slot"))
    better = next(f for f in out["operations"][0]["findings"] if f["code"] == "better_tool")
    check = numeric_guard.check_numbers(better["detail"], {"op": out["operations"][0]["tool_alternatives"], "f": better})
    assert check.ok if hasattr(check, "ok") else check["ok"]


def test_setup_advisor_skips_probes_holes_and_tslots_and_the_switch_turns_it_off():
    probe = _advise({"document": "t", "ops": [{"setup": "S1", "name": "Probe", "strategy": "probe", "tool": {"type": "probe", "description": "Renishaw probe"}}]})
    op = probe["operations"][0]
    assert op["kind"] == "probe" and "tool_alternatives" not in op and not any(f["code"] == "better_tool" for f in op["findings"])
    hole = _advise(_setup(strategy="drill", name="Drill holes", tool={"type": "drill", "description": '1/8" drill', "unit": "inches",
                                                                      "geometry": {"DC": 0.125, "NOF": 2, "LCF": 1.0, "SFDM": 0.125}}))
    assert hole["operations"][0]["kind"] == "hole" and "tool_alternatives" not in hole["operations"][0]
    off = _advise(_setup(strategy="slot", name="Slot"), tool_alternatives=False)
    assert "tool_alternatives" not in off["operations"][0] and not any(f["code"] == "better_tool" for f in off["operations"][0]["findings"])


def test_setup_advisor_without_feature_limits_only_tries_the_same_diameter():
    out = _advise(_setup(strategy="adaptive2d", name="Adaptive", geometry={"depth_in": 0.25}))
    blk = out["operations"][0]["tool_alternatives"]
    assert all(abs(a["diameter"] - 0.125) < 1e-6 for a in blk["alternatives"])
    assert blk["limits_from"].get("max_diameter_in") is None


def test_setup_advisor_run_budget_is_capped_per_setup(monkeypatch):
    monkeypatch.setattr(sa, "ALT_RUNS_PER_SETUP", 2)
    s = _setup(strategy="slot", name="Slot A")
    s["ops"].append(copy.deepcopy(s["ops"][0]))
    s["ops"][1]["name"] = "Slot B"
    s["ops"][1]["path"] = "S1 > Slot B"
    s["ops"][1]["tool"] = {"type": "flat end mill", "description": "3/16 flat", "unit": "inches", "geometry": {"DC": 0.1875, "NOF": 3, "LCF": 0.5, "SFDM": 0.1875}}
    out = _advise(s)
    runs = sum((o.get("tool_alternatives") or {}).get("engine_runs", 0) for o in out["operations"])
    assert runs <= 2
    assert any("skipped" in (o.get("tool_alternatives") or {}) for o in out["operations"])


def test_advisor_route_accepts_the_switch():
    c = toolwiz_app.app.test_client()
    body = {"setup": _setup(strategy="slot", name="Slot"), "family": F174[0], "alloy": F174[1], "strategies": False, "model": "v2",
            "tool_alternatives": False}
    r = c.post("/api/setup_advisor", json=body, headers=HDR)
    assert r.status_code == 200 and "tool_alternatives" not in r.get_json()["operations"][0]


# ---- the API, the chat tool and the MCP tool --------------------------------------------------------------------------

def test_route_and_errors():
    c = toolwiz_app.app.test_client()
    body = haas_eighth(F174)
    r = c.post("/api/advice/alternative_tools", json=body, headers=HDR)
    assert r.status_code == 200
    d = r.get_json()
    assert d["success"] and d["alternatives"] and d["current"]["rpm"] > 0 and d["disclaimers"]
    assert c.post("/api/advice/alternative_tools", json={"family": F174[0]}, headers=HDR).status_code == 400
    assert c.post("/api/advice/alternative_tools", json=[1], headers=HDR).status_code == 400
    assert c.post("/api/advice/alternative_tools", json=body).status_code in (400, 403)      # the CSRF guard needs the client header
    # the web calculator's own field names work
    web = {"family": F174[0], "alloy": F174[1], "operation": "Slotting", "diameter": 0.125, "flutes": 4, "fluteLength": 0.375, "shankDiameter": 0.125,
           "stickout": 0.5, "cornerRadius": 0.015, "coating": "AlTiN", "brand": "Haas", "aggressiveness": 50, "model": "v2", "sources": ["catalog"]}
    d2 = c.post("/api/advice/alternative_tools", json=web, headers=HDR).get_json()
    assert d2["success"] and d2["current"]["rpm"] == d["current"]["rpm"]


def test_older_series_advice_still_works():
    c = toolwiz_app.app.test_client()
    r = c.post("/api/advice/tools", json={"family": F174[0], "diameter": 0.125, "operation": "side"}, headers=HDR)
    assert r.status_code == 200 and isinstance(r.get_json()["tools"], list)


def test_chat_tool_and_mcp_tool(monkeypatch):
    monkeypatch.setenv("TOOLWIZ_MODEL", "v2")          # the chat tool uses the app's default model (tests pin v1)
    from advisor_chat import tools as chat_tools
    names = {t.name for t in chat_tools.specs(False)}
    assert "alternative_tools" in names and "tool_advice" in names
    ctx = chat_tools.ToolContext()
    out = chat_tools.run_tool(ctx, "alternative_tools", {"family": FTI[0], "diameter": 0.125, "operation": "Slotting", "flutes": 4,
                                                          "stickout": 0.5, "brand": "Haas", "sources": ["catalog"]})
    assert not out["is_error"], out["content"][:200]
    d = out["data"]
    assert d["success"] and d["alternatives"] and "inputs_assumed" in d
    bad = chat_tools.run_tool(ctx, "alternative_tools", {"diameter": 0.125, "operation": "Slotting"})
    assert bad["is_error"] and "family" in bad["data"]["error"]
    import mcp_server
    listed = {t["name"]: t for t in mcp_server.list_mcp_tools()}
    assert "toolwiz_alternative_tools" in listed and "never invent" in listed["toolwiz_alternative_tools"]["description"]
    m = mcp_server.call_mcp_tool_by_name("toolwiz_alternative_tools", {"family": FTI[0], "operation": "Slotting", "diameter": 0.125, "flutes": 4,
                                                                      "stickout": 0.5, "brand": "Haas", "sources": ["catalog"], "model": "v2"})
    assert m["success"] and m["alternatives"]
