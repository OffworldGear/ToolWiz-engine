"""Fixes for docs/FUSION_BRIDGE_VERIFY2_2026-11-13.md (the shop PC's second verification against live Fusion)."""
import json
from types import SimpleNamespace

import app as toolwiz_app
import oversight_engine
import setup_advisor as sa
from test_addin_common import load_addin, param, ParamsByName

FAM = "Aluminum - Wrought (6061)"
ENDMILL = {"type": "flat end mill", "unit": "inches", "description": "1/4 4 flute endmill",
           "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.75, "SFDM": 0.25, "LB": 2.0}}
FORMULA = ("tool_isMill ? ('drilling') : ((tool_type == 'tap right hand' || tool_type == 'tap left hand') ? 'tapping' : "
           "((tool_type == 'reamer')?('reaming'):'drilling'))")
FORMULA2 = "isDrillingRefTrimming ? drillingReference.cycleType : " + FORMULA
P = {"tool_spindleSpeed": "12000 rpm", "tool_feedCutting": "30 in/min", "maximumStepdown": "0.25 in"}


def _advise(ops):
    return sa.advise({"document": "d", "ops": ops}, family=FAM, alloy="", physics=toolwiz_app.physics,
                     machine_profile=toolwiz_app.active_machine())


def _op(name, strategy, params, tool=None, **extra):
    return dict({"setup": "S", "name": name, "path": f"S > {name}", "strategy": strategy, "tool": tool or ENDMILL, "params": params}, **extra)


# ---- 1. cycle type: the evaluated value, never a substring of Fusion's formula --------------------------------------

def _hole_op(tool_type, cycle_expr, cycle_value, desc="drill"):
    tool = {"type": tool_type, "unit": "millimeters", "description": desc, "post-process": {"number": 7},
            "geometry": {"DC": 3.0, "NOF": 2, "LCF": 12.0, "SFDM": 3.0, "LB": 20.0, "TA": 118.0}}
    return SimpleNamespace(name="Drill4 (5)", strategy="drill", parameters=ParamsByName({"cycleType": param(cycle_expr, cycle_value)}),
                           tool=SimpleNamespace(toJson=lambda: json.dumps(tool)))


def _label(op, a):
    geo, _, _ = a.get_op_tool_info(op)
    return a.infer_strategy_for_op(op, geo)


def test_default_formula_expression_never_decides_the_label():
    a = load_addin()
    for expr in (FORMULA, FORMULA2):
        assert _label(_hole_op("drill", expr, "drilling"), a) == "Drilling"
        for peck in ("chip-breaking - partial retract", "deep drilling - full retract", "Chip Breaking"):
            assert _label(_hole_op("drill", expr, peck), a) == "Peck Drilling (Deep Hole)", peck
        assert _label(_hole_op("drill", expr, "reaming"), a) == "Reaming"
        assert _label(_hole_op("tap right hand", expr, "tapping", "M3 tap"), a).startswith("Tapping")
        assert _label(_hole_op("drill", expr, None), a) == "Drilling"          # value unknown: the formula is not read


def test_value_can_be_an_object_or_enum_like():
    a = load_addin()
    wrapped = SimpleNamespace(value="chip-breaking - partial retract")
    assert _label(_hole_op("drill", FORMULA, wrapped), a) == "Peck Drilling (Deep Hole)"
    enumlike = SimpleNamespace(value=3, name="deep drilling")
    assert _label(_hole_op("drill", FORMULA, enumlike), a) == "Peck Drilling (Deep Hole)"
    assert _label(_hole_op("drill", "'reaming'", None), a) == "Reaming"        # a plain quoted literal is the fallback
    assert _label(_hole_op("drill", "'drilling'", None), a) == "Drilling"


def test_snapshot_carries_value_and_expression():
    a = load_addin()
    e = a.op_advisor_entry(_hole_op("drill", FORMULA, "drilling"), "S > Drill4 (5)")
    assert e["cycle_type"] == "drilling" and e["cycle_type_expr"] == FORMULA and e["strategy_label"] == "Drilling"
    e = a.op_advisor_entry(_hole_op("drill", "'deep drilling'", None), "S > D")
    assert e["cycle_type"] == "deep drilling" and e["cycle_type_expr"] == "'deep drilling'"


# ---- 2. a measured channel narrower than the tool is not a slot -----------------------------------------------------

GEO_BAD = {"channel_width_in": 0.2429, "channel_length_in": 0.0177, "is_slot": False}


def test_channel_narrower_than_tool_is_not_a_slot():
    o = _advise([_op("2D Contour1", "contour2d", P, geometry=GEO_BAD)])["operations"][0]
    assert o["kind"] == "contour"
    assert any("measured channel 0.2429 in wide and 0.0177 in long is not treated as a slot" in n for n in o["notes"])
    assert not any("High Engagement" in f["title"] or f["code"] == "stepover_high" for f in o["findings"])
    assert o["current"]["stepover_in"] is None and "channel_width_in" not in o["geometry"]


def test_real_slot_measurements_still_classify_as_slot():
    tool = ENDMILL
    d = 0.25
    assert sa.classify_op("contour2d", "C", {"diameter_in": d}, {"channel_width_in": 0.26, "channel_length_in": 2.0}, None) == "slot"
    assert sa.classify_op("contour2d", "C", {"diameter_in": d}, {"channel_width_in": 0.26}, None) == "slot"      # no length given
    assert sa.classify_op("contour2d", "C", {"diameter_in": d}, {"channel_width_in": 0.2429, "is_slot": True}, None) == "slot"
    assert sa.classify_op("contour2d", "C", {"diameter_in": d}, {"channel_width_in": 0.2429, "channel_length_in": 0.0177}, None) == "contour"
    assert sa.classify_op("contour2d", "C", {"diameter_in": d}, {"channel_width_in": 0.26, "channel_length_in": 0.05}, None) == "contour"
    assert tool


# ---- 3. no "High Engagement" at zero engagement ---------------------------------------------------------------------

def _hi_eng(woc, op="Roughing"):
    rep = oversight_engine.evaluate_holistic_oversight(
        {"family": FAM, "alloy": "", "operation": op, "coating": "ZrN", "diameter": 0.25, "flutes": 4, "fluteLength": 0.75,
         "shankDiameter": 0.25, "runout": 0.0005, "tool": "Carbide Endmill"},
        {"operation": op, "woc": woc, "doc": 0.5, "rpm": 12000, "feed": 40})
    return [f for f in rep.findings if "High Engagement" in f.title]


def test_high_engagement_needs_a_real_positive_width():
    assert _hi_eng(0.0) == [] and _hi_eng(0.0, "Slotting") == []
    assert len(_hi_eng(0.25)) == 1


def test_contour_without_stepover_gets_no_engagement_caution():
    o = _advise([_op("2D Contour2", "contour2d", P)])["operations"][0]
    assert not any("High Engagement" in f["title"] for f in o["findings"])


# ---- 4. the snapshot does not invent AlTiN --------------------------------------------------------------------------

def _mill(desc, bmc="ti coated", grade="Mill Generic"):
    tool = {"type": "flat end mill", "unit": "inches", "description": desc, "BMC": bmc, "GRADE": grade,
            "post-process": {"number": 1}, "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.75, "SFDM": 0.25, "LB": 2.0}}
    return SimpleNamespace(name="Pocket1", strategy="pocket2d", parameters=ParamsByName({"tool_spindleSpeed": param("12000 rpm")}),
                           tool=SimpleNamespace(toJson=lambda: json.dumps(tool)))


def test_snapshot_coating_only_when_the_tool_states_one():
    a = load_addin()
    e = a.op_advisor_entry(_mill("1/4 endmill"), "S > Pocket1")
    assert e["coating"] is None and e["coating_source"] == "not set"
    geo, _, _ = a.get_op_tool_info(_mill("1/4 endmill"))
    assert geo["coating"] == "AlTiN"                                           # the dialog's preselected default is unchanged
    e = a.op_advisor_entry(_mill("1/8 Ball Endmill HRC55 AlTiN"), "S > Pocket1")
    assert e["coating"] == "AlTiN" and e["coating_source"] == "tool"
    e = a.op_advisor_entry(_mill("1/4 endmill", bmc="carbide", grade="Bright"), "S > Pocket1")
    assert e["coating"] == "Uncoated" and e["coating_source"] == "tool"


def test_ti_coated_is_coated_type_unknown_with_a_plain_message():
    t = dict(ENDMILL, BMC="ti coated", GRADE="Mill Generic")
    assert sa.parse_tool(t)["coating"] is None
    p = {"tool_spindleSpeed": "12000 rpm", "tool_feedCutting": "40 in/min", "maximumStepdown": "0.1 in", "stepover": "0.05 in"}
    res = _advise([_op("Pocket1", "pocket2d", p, tool=t, coating=None)])
    got = [f for f in res["operations"][0]["findings"] if f["title"].startswith("Tool Coating Unknown")]
    assert len(got) == 1
    assert "not which coating" in got[0]["detail"] and "all my tools are AlTiN" in got[0]["recommendation"]
