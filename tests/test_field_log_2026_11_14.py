"""Regression tests for docs/FIELD_TEST_LOG.md, entries 1, 3, 4 and 5 (the owner's first real apply, Op1EndCap7075, 60 %).

3: a finishing op is offered speed and feed only for the cut it really takes; none when its engagement is not known, and none
   when the pass is too heavy for the wall tolerance (never a feed for ToolWiz's own 0.002 in skim).
4: an operation with a chamfer mill (or another form tool) is never analysed as an end-mill cut, whatever the strategy.
5: a ball end mill goes to the engine and to the tool comparison as a ball: no flat end mill is offered for a scallop pass.
1: the "Ramp is off" note does not say "at each depth" on a single-depth slot."""
import json

import app as toolwiz_app
import setup_advisor as sa

FAM = "Aluminum - Wrought (6061)"
F16 = {"type": "flat end mill", "unit": "inches", "description": '1/16" Flat Endmill AlTiN',
       "geometry": {"DC": 0.0625, "NOF": 4, "LCF": 0.1875, "SFDM": 0.125, "LB": 0.5}}
B16 = {"type": "ball end mill", "unit": "inches", "description": '1/16" Ball Endmill AlTiN',
       "geometry": {"DC": 0.0625, "NOF": 4, "LCF": 0.25, "SFDM": 0.125, "LB": 0.5}}
CHAMFER = {"type": "chamfer mill", "unit": "inches", "description": "Chamfer 4fl 90deg altin",
           "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.25, "SFDM": 0.25, "LB": 1.0, "TA": 45}}
S = {"tool_spindleSpeed": "11999 rpm", "tool_feedCutting": "25.56 in/min"}


def _op(name, strategy, tool, params, **extra):
    return dict({"setup": "Op1", "name": name, "path": f"Op1 > {name}", "strategy": strategy, "tool": tool, "params": params}, **extra)


def _advise(ops, **kw):
    return sa.advise({"document": "d", "ops": ops}, family=FAM, alloy="7075-T6", aggressiveness=0.6, physics=toolwiz_app.physics,
                     machine_profile=toolwiz_app.active_machine(), **kw)["operations"]


def _codes(o):
    return [f["code"] for f in o["findings"]]


# ---- entry 3 ---------------------------------------------------------------------------------------------------------

def test_finish_plan_is_for_the_ops_own_engagement_not_toolwiz_skim():
    o = _advise([_op("Flat34", "flat", F16, dict(S, maximumStepdown="0.0394 in", stepover="0.01875 in"))], tool_alternatives=False)[0]
    assert o["kind"] == "finish"
    rec, usr = o["toolwiz"]["recommended"], o["toolwiz"]["at_current_engagement"]
    assert usr["ae_in"] == 0.01875 and usr["ap_in"] == 0.0394 and rec["ae_in"] < 0.005        # rec is the default skim
    assert usr["feed_ipm"] < rec["feed_ipm"]
    plan = o["apply_plan"]
    assert set(plan) == {"recommended"}
    assert plan["recommended"] == {"tool_spindleSpeed": f"{usr['rpm']} rpm", "tool_feedCutting": f"{usr['feed_ipm']:.2f} in/min"}
    assert f"{rec['feed_ipm']:.2f} in/min" not in json.dumps(plan)


def test_planned_finish_feed_is_never_one_the_same_run_flags():
    """The feed the plan writes, put back into the operation, gives no chip-load STOP or CAUTION."""
    o = _advise([_op("Scallop4", "scallop", B16, dict(S, stepover="0.0049 in"))], tool_alternatives=False)[0]
    p = o["apply_plan"]["recommended"]
    again = _advise([_op("Scallop4", "scallop", B16, dict(p, stepover="0.0049 in"))], tool_alternatives=False)[0]
    assert not [c for c in _codes(again) if c in ("chip_load_high", "chip_load_off", "feed_off", "rpm_off")]
    assert again["apply_plan"] is None


def test_finish_contour_without_stepover_gets_no_feed_and_says_why():
    o = _advise([_op("2D Contour7", "contour2d", F16, dict(S, stockToLeave="0 in"))], tool_alternatives=False)[0]
    assert o["kind"] == "finish" and o["apply_plan"] is None and o["toolwiz"]["at_current_engagement"] is None
    assert any(n.startswith("No speed or feed is proposed: this finishing pass has no stepover") for n in o["notes"])
    assert not [c for c in _codes(o) if c in ("chip_load_high", "chip_load_off", "feed_off", "rpm_off")]


def test_finish_pass_too_heavy_for_the_wall_tolerance_gets_caution_and_no_feed():
    long_tool = dict(F16, geometry=dict(F16["geometry"], LB=0.75))
    o = _advise([_op("Flat34", "flat", long_tool, dict(S, maximumStepdown="0.0394 in", stepover="0.01875 in"))], tool_alternatives=False)[0]
    assert "wall error" in o["toolwiz"]["at_current_engagement"]["limited_by"]
    f = [x for x in o["findings"] if x["code"] == "finish_cut_too_heavy"]
    assert len(f) == 1 and f[0]["severity"] == "CAUTION"
    n = f[0]["numbers"]
    assert n["toolwiz_feed_at_tolerance_ipm"] < sa.FINISH_MIN_FZ_FRACTION * n["toolwiz_feed_without_tolerance_ipm"]
    assert o["apply_plan"] is None and "chip_load_high" not in _codes(o)


# ---- entry 4 ---------------------------------------------------------------------------------------------------------

def test_trace_with_a_chamfer_mill_is_not_an_end_mill_cut():
    ops = _advise([_op("Trace1 (2)", "trace", CHAMFER, {"tool_spindleSpeed": "12224 rpm", "tool_feedCutting": "146.7 in/min",
                                                       "tool_feedPlunge": "13.12 in/min"})])
    o = ops[0]
    assert o["kind"] == "edge" and o["apply_plan"] is None and o["findings"] == []
    assert o["toolwiz"]["recommended"] is None and "tool_alternatives" not in o
    assert any(n.startswith("Form tool (chamfer mill)") for n in o["notes"])


def test_form_tools_are_recognised_by_type_not_by_a_word_in_the_description():
    tool = sa.parse_tool
    for t in ("chamfer mill", "dovetail mill", "lollipop mill", "tapered mill", "thread mill", "countersink"):
        assert sa.classify_op("trace", "T", tool({"type": t, "description": "x"}), {}, None) == "edge", t
        assert sa.classify_op("contour2d", "T", tool({"type": t, "description": "x"}), {}, 0.0) == "edge", t
    haas = tool({"type": "bull nose end mill", "description": '1/16" Carbide End Mill, 4 Flute, 0.004" Chamfer, HSPM1'})
    assert not sa.is_form_tool(haas) and sa.classify_op("adaptive", "A", haas, {}, None) == "adaptive"
    assert sa.classify_op("trace", "T", tool({"type": "flat end mill", "description": "1/4 endmill"}), {}, None) == "rough"
    assert sa.classify_op("drill", "D", tool({"type": "spot drill", "description": "3mm Spot Drill"}), {}, None) == "hole"
    assert sa.classify_op("slot", "S", tool({"type": "slot mill", "description": "keyseat"}), {}, None) == "tslot"


# ---- entry 5 ---------------------------------------------------------------------------------------------------------

def test_ball_end_mill_reaches_the_engine_and_the_tool_comparison_as_a_ball():
    t, _ = sa._complete_tool(sa.parse_tool(B16))
    assert sa.is_ball_tool(t) and sa._engine_geometry(t) == "Ball" and t["corner_radius_in"] == 0.03125
    assert sa._fusion_tool_dict(t, 0.5)["type"] == "ball end mill"
    body, _ = sa._alt_request({"kind": "finish", "geometry": {}}, t, {"family": FAM, "alloy": "", "aggressiveness": 0.6, "runout": 0.0002, "model": "v2"})
    assert body["geometry"] == "ball"
    assert not sa.is_ball_tool(sa.parse_tool({"type": "lollipop mill", "description": "ball lollipop"}))


def test_no_flat_end_mill_is_offered_for_a_ball_scallop_pass():
    o = _advise([_op("Scallop4 (6)", "scallop", B16, dict(S, stepover="0.0049 in"))])[0]
    blk = o["tool_alternatives"]
    offered = [blk.get("best_library"), blk.get("best_catalog")] + list(blk.get("alternatives") or [])
    for a in offered:
        if a:
            assert "flat" not in json.dumps(a).lower(), a
    f = [x for x in o["findings"] if x["code"] == "better_tool"]
    assert not f or "Flat" not in f[0]["title"]


def test_advisor_cache_does_not_mix_ball_and_flat_tools_of_the_same_size():
    """Same diameter, flutes, flute length and stickout: the per-run cache must key on the end form (see HANDOFF, "Things that bit us")."""
    flat = dict(F16, geometry=dict(F16["geometry"], LCF=0.25))
    ops = _advise([_op("A", "scallop", flat, dict(S, stepover="0.0049 in")), _op("B", "scallop", B16, dict(S, stepover="0.0049 in"))],
                  tool_alternatives=False)
    assert ops[0]["tool"]["type"] == "flat end mill" and ops[1]["tool"]["type"] == "ball end mill"
    key = lambda tool: (sa._engine_geometry(tool), round(tool.get("corner_radius_in") or 0.0, 6))
    ta, tb = sa._complete_tool(sa.parse_tool(flat))[0], sa._complete_tool(sa.parse_tool(B16))[0]
    assert key(ta) != key(tb)


# ---- entry 1 ---------------------------------------------------------------------------------------------------------

def test_ramp_off_note_on_a_single_depth_slot_does_not_say_at_each_depth():
    em = {"type": "flat end mill", "unit": "inches", "description": "1/4 4 flute endmill AlTiN",
          "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.4375, "SFDM": 0.25, "LB": 1.5}}
    p = {"tool_spindleSpeed": "9000 rpm", "tool_feedCutting": "20 in/min", "tool_rampAngle": "3.0 deg"}
    off = {"enabled": False, "type": "profile", "raw": {"doRamp": "false"}}
    geo = {"slot_width_in": 0.25, "is_slot": True}
    one = _advise([_op("2D Contour206 (3)", "contour2d", em, p, ramp=off, multiple_depths=False, geometry=geo)], tool_alternatives=False)[0]
    many = _advise([_op("2D Contour206 (3)", "contour2d", em, dict(p, maximumStepdown="0.1 in"), ramp=off, multiple_depths=True, geometry=geo)],
                   tool_alternatives=False)[0]
    d1 = [f["detail"] for f in one["findings"] if f["code"] == "ramp_off"]
    d2 = [f["detail"] for f in many["findings"] if f["code"] == "ramp_off"]
    assert d1 and d1[0].startswith("Turning on Ramp in Fusion would ease the entry; ")
    assert d2 and d2[0].startswith("Turning on Ramp in Fusion would ease the entry at each depth; ")
