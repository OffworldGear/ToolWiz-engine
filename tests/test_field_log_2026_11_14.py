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
    o = _advise([_op("Wall", "contour2d", F16, dict(S, maximumStepdown="0.0394 in", stepover="0.01875 in", stockToLeave="0 in"))],
                tool_alternatives=False)[0]
    assert o["kind"] == "finish"
    rec, usr = o["toolwiz"]["recommended"], o["toolwiz"]["at_current_engagement"]
    assert usr["ae_in"] == 0.01875 and usr["ap_in"] == 0.0394 and rec["ae_in"] < 0.005        # rec is the default skim
    assert usr["feed_ipm"] < rec["feed_ipm"]
    plan = o["apply_plan"]
    assert set(plan) == {"recommended"}
    p = plan["recommended"]
    assert p["tool_spindleSpeed"] == f"{usr['rpm']} rpm" and p["tool_feedCutting"] == f"{usr['feed_ipm']:.2f} in/min"
    assert set(p) <= {"tool_spindleSpeed", "tool_feedCutting", "tool_feedRamp", "tool_feedPlunge"}
    if usr.get("plunge_feed_ipm"):       # owner 2026-11-15: ramp and plunge feed on every cutting op, finishing included
        assert p["tool_feedPlunge"] == f"{usr['plunge_feed_ipm']:.2f} in/min"
    if usr.get("ramp_feed_ipm"):
        assert p["tool_feedRamp"] == f"{usr['ramp_feed_ipm']:.2f} in/min"
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
    o = _advise([_op("Wall", "contour2d", long_tool, dict(S, maximumStepdown="0.0394 in", stepover="0.01875 in", stockToLeave="0 in"))],
                tool_alternatives=False)[0]
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
    assert any(n.startswith("Chamfer pass with a chamfer mill (a finishing cut)") for n in o["notes"])


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


# ---- owner's answers, 2026-11-15 ------------------------------------------------------------------------------------

def test_flat_op_uses_floor_finishing_like_the_speeds_and_feeds_dialog():
    """Flat34: the dialog that set the op uses "Floor Finishing (Skim)" for a Flat strategy; the advisor must use the same
    operation, so it does not flag ToolWiz's own numbers. The wall tolerance does not cut a floor pass down to a rubbing feed."""
    from pipeline import CutRequest, run_cut
    long_tool = dict(F16, geometry=dict(F16["geometry"], LB=0.75))
    for strategy in ("flat", "horizontal"):
        o = _advise([_op("Flat34", strategy, long_tool, dict(S, maximumStepdown="0.0394 in", stepover="0.01875 in"))], tool_alternatives=False)[0]
        usr = o["toolwiz"]["at_current_engagement"]
        assert o["kind"] == "finish" and usr["operation"] == sa.FLOOR_FINISH_OPERATION
        assert "finish_cut_too_heavy" not in _codes(o) and "chip_load_high" not in _codes(o)
    direct = run_cut(toolwiz_app.physics, CutRequest(
        family=FAM, alloy="7075-T6", operation="Floor Finishing (Skim)", coating="AlTiN", apply_coating=True, geometry="Square",
        diameter=0.0625, flutes=4, flute_length=0.1875, shank_diameter=0.125, stickout=0.75, aggressiveness=0.6,
        max_rpm=usr["rpm"] and toolwiz_app.active_machine().get("max_rpm", 16000) or 16000, runout=0.0002,
        cut_depth=0.0394, cut_width=0.01875, model="v2"))
    assert abs(direct.feed_ipm - usr["feed_ipm"]) <= 0.02 * usr["feed_ipm"]      # advisor and calculator agree
    o = _advise([_op("Scallop", "scallop", B16, dict(S, stepover="0.0049 in"))], tool_alternatives=False)[0]
    assert o["toolwiz"]["at_current_engagement"]["operation"] == "Finishing"


POCKET_TOOL = {"type": "flat end mill", "unit": "inches", "description": "1/4 4 flute endmill AlTiN",
               "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.4375, "SFDM": 0.25, "LB": 1.5}}
PP = {"tool_spindleSpeed": "9000 rpm", "tool_feedCutting": "20 in/min", "maximumStepdown": "0.2 in", "stepover": "0.05 in",
      "tool_feedRamp": "10 in/min", "tool_feedPlunge": "5 in/min"}


def test_ramp_and_plunge_feed_are_proposed_even_when_the_angle_is_kept_or_ramp_is_off():
    base = _advise([_op("P", "pocket2d", POCKET_TOOL, dict(PP, tool_rampAngle="30 deg"))], tool_alternatives=False)[0]
    tw = base["toolwiz"]["recommended"]
    want_ramp, want_plunge = f"{tw['ramp_feed_ipm']:.2f} in/min", f"{tw['plunge_feed_ipm']:.2f} in/min"
    kept = _advise([_op("P", "pocket2d", POCKET_TOOL, dict(PP, tool_rampAngle="1 deg"))], tool_alternatives=False)[0]
    p = kept["apply_plan"]["recommended"]
    assert "tool_rampAngle" not in p and p["tool_feedRamp"] == want_ramp and p["tool_feedPlunge"] == want_plunge
    off = {"enabled": False, "type": "profile", "raw": {"doRamp": "false"}}
    c = _advise([_op("C", "contour2d", POCKET_TOOL, dict(PP, tool_rampAngle="1 deg", stockToLeave="0.01 in"), ramp=off, multiple_depths=True)],
                tool_alternatives=False)[0]
    p = c["apply_plan"]["recommended"]
    assert "tool_rampAngle" not in p and "tool_feedRamp" in p and "tool_feedPlunge" in p


def test_shallow_ramp_on_an_aggressive_cut_is_named_as_such():
    tw = _advise([_op("P", "pocket2d", POCKET_TOOL, dict(PP, tool_rampAngle="30 deg"))], tool_alternatives=False)[0]["toolwiz"]["recommended"]
    shallow = f"{0.3 * tw['ramp_angle_deg']:.2f} deg"
    hot = dict(PP, tool_rampAngle=shallow, maximumStepdown=f"{min(0.43, 2.2 * tw['ap_in']):.4f} in", stepover=f"{3 * tw['ae_in']:.4f} in",
               tool_feedCutting=f"{3 * tw['feed_ipm']:.2f} in/min", tool_spindleSpeed=f"{tw['rpm']} rpm")
    o = _advise([_op("P", "pocket2d", POCKET_TOOL, hot)], tool_alternatives=False)[0]
    f = [x for x in o["findings"] if x["code"] == "ramp_shallow_cut_aggressive"]
    assert len(f) == 1 and f[0]["severity"] == "CAUTION" and "tool_rampAngle" not in o["apply_plan"]["recommended"]
    assert f"{tw['ramp_angle_deg']:.1f} deg" in f[0]["detail"]
    calm = dict(PP, tool_rampAngle=shallow, maximumStepdown=f"{tw['ap_in']:.5f} in", stepover=f"{tw['ae_in']:.5f} in",
                tool_feedCutting=f"{tw['feed_ipm']:.2f} in/min", tool_spindleSpeed=f"{tw['rpm']} rpm", tool_feedRamp=f"{tw['ramp_feed_ipm']:.2f} in/min")
    o = _advise([_op("P", "pocket2d", POCKET_TOOL, calm)], tool_alternatives=False)[0]
    assert "ramp_shallow_cut_aggressive" not in _codes(o)        # a shallow ramp on a sensible cut is the owner's choice


def test_sk_and_sx_collet_chucks_are_rated_at_3_microns_everywhere():
    import json as _json
    from toolwiz_common import runout as ro
    assert ro.SK_SX_TIR_IN == round(0.003 / 25.4, 6)
    for text in ("Lyndex SK10", "Pioneer SX10 collet chuck"):
        assert ro.holder_runout(text) == ("SK/SX collet", ro.SK_SX_TIR_IN)
    h = [x for x in _json.load(open("data/holders.json"))["holders"] if x["id"] == "sk_collet_chuck"][0]
    assert h["tir_mm"] == 0.003


# ---- owner's answers, 2026-11-15 (second round) and log entries 7 and 13 -------------------------------------------

def test_finishing_plan_carries_ramp_and_plunge_feed():
    o = _advise([_op("Wall", "contour2d", F16, dict(S, maximumStepdown="0.0394 in", stepover="0.01875 in", stockToLeave="0 in"))],
                tool_alternatives=False)[0]
    usr, p = o["toolwiz"]["at_current_engagement"], o["apply_plan"]["recommended"]
    assert usr["plunge_feed_ipm"] and p["tool_feedPlunge"] == f"{usr['plunge_feed_ipm']:.2f} in/min"
    assert "tool_rampAngle" not in p


def test_no_wall_finish_tool_comparison_on_a_flat_op():
    o = _advise([_op("Flat33 (5)", "flat", POCKET_TOOL, {"tool_spindleSpeed": "15584 rpm", "tool_feedCutting": "92 in/min",
                                                        "maximumStepdown": "0.039 in", "stepover": "0.075 in"})])[0]
    assert "skipped" in o["tool_alternatives"] and "better_tool" not in _codes(o)


def test_speeds_and_feeds_dialog_uses_wall_finishing_for_scallop_like_the_advisor():
    import re
    src = open("ToolWizFusionAddin/ToolWizFusionAddin.py", encoding="utf-8").read()
    m = re.search(r"if any\(s in op_strat for s in \['scallop', 'parallel', 'morphed', 'ramp', 'flow'\]\):\n(?:\s*#.*\n)*\s*return '([^']+)'", src)
    assert m and m.group(1) == "Finishing" == sa._finish_operation({"strategy": "scallop"})
    assert "return 'Floor Finishing (Skim)'" in src and sa._finish_operation({"strategy": "flat"}) == "Floor Finishing (Skim)"


def test_result_dialog_rounds_old_values():
    sys_path_addin = "ToolWizFusionAddin"
    import sys
    if sys_path_addin not in sys.path:
        sys.path.insert(0, sys_path_addin)
    import twlogic as tw
    assert tw.tidy_old_value("tool_feedCutting", "50.1921790628448in/min") == "50.19 in/min"
    assert tw.tidy_old_value("tool_spindleSpeed", "11999.11612839420377") == "11999 rpm"
    assert tw.tidy_old_value("tool_spindleSpeed", "12224.") == "12224 rpm"
    assert tw.tidy_old_value("maximumStepdown", "0.45in") == "0.45 in"
    assert tw.tidy_old_value("tool_feedPlunge", "tool_feedCutting * 0.3") == "tool_feedCutting * 0.3"
    text = tw.format_apply_results([{"op_id": "S > Op", "applied": [{"param": "tool_feedCutting", "old": "50.1921790628448in/min", "new": "47.74 in/min"}]}])
    assert "tool_feedCutting: 50.19 in/min -> 47.74 in/min" in text


def test_micro_tool_with_shank_equal_to_diameter_is_flagged_once_per_tool():
    thin = dict(F16, geometry=dict(F16["geometry"], SFDM=0.0625))
    p = dict(S, maximumStepdown="0.0394 in", stepover="0.01875 in")
    ops = _advise([_op("A", "flat", thin, p), _op("B", "flat", thin, p), _op("C", "flat", F16, p)], tool_alternatives=False)
    assert [("shank_equals_diameter" in _codes(o)) for o in ops] == [True, False, False]
    f = [x for x in ops[0]["findings"] if x["code"] == "shank_equals_diameter"][0]
    assert f["severity"] == "INFO" and "1/8 in" in f["detail"]


def test_dialog_and_advisor_pick_the_same_calculation_for_the_strategies_that_agree():
    """Owner, 2026-11-15: he assumed the Setup Advisor and the Speeds & Feeds dialog give identical results. They choose
    their ToolWiz operation in two separate places; this pins the Fusion strategies on which they agree today, so the two
    cannot drift apart again unnoticed. The known differences are listed in docs/SETUP_ADVISOR.md ("Dialog and advisor")."""
    from types import SimpleNamespace
    from test_addin_common import load_addin
    a = load_addin()
    a.read_cycle_type = lambda op: ("", "")
    agree = {"adaptive": "Adaptive Roughing", "adaptive2d": "Adaptive Roughing", "pocket2d": "Roughing", "pocket": "Roughing",
             "slot": "Slotting", "face": "Facing", "flat": "Floor Finishing (Skim)", "horizontal": "Floor Finishing (Skim)",
             "scallop": "Finishing", "parallel": "Finishing", "morphed_spiral": "Finishing"}
    for tt in ("flat end mill", "ball end mill"):
        tool = sa.parse_tool({"type": tt, "description": "1/4 " + tt, "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.5, "SFDM": 0.25, "LB": 1.0}})
        gp = {"kind": "milling", "type": tt, "tool_type": tt, "desc": "1/4 " + tt, "diameter": 0.25}
        for strategy, want in agree.items():
            dialog = a.infer_strategy_for_op(SimpleNamespace(strategy=strategy, name="Op", parameters=None), gp)
            for stock in (0.0, 0.01):
                kind = sa.classify_op(strategy, "Op", tool, {}, stock)
                advisor = sa._finish_operation({"strategy": strategy}) if kind == "finish" else sa._KIND_OPERATION.get(kind)
                assert dialog == advisor == want, (strategy, tt, stock, dialog, advisor)
