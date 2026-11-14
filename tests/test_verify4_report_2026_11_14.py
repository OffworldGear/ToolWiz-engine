"""Fixes for docs/FUSION_BRIDGE_VERIFY3_2026-11-13.md (items A to F): ramp angle unit, stock only where enabled, no noise
notes, the 4-flute caution gate, ramp only where the operation ramps, the ramp chart sentence."""
import json
import os
import sys
from types import SimpleNamespace

import app as toolwiz_app
import oversight_engine
import setup_advisor as sa
from test_addin_common import load_addin, param, ParamsByName

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "ToolWizFusionAddin"))
import twlogic as tw  # noqa: E402

FAM = "Aluminum - Wrought (6061)"
ENDMILL = {"type": "flat end mill", "unit": "inches", "description": "1/4 4 flute endmill",
           "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.4375, "SFDM": 0.25, "LB": 1.5}}
P = {"tool_spindleSpeed": "9000 rpm", "tool_feedCutting": "20 in/min", "maximumStepdown": "0.2 in", "stepover": "0.05 in"}
RAMP_ON = {"enabled": True, "type": "Ramp", "raw": {}}


def _advise(ops):
    return sa.advise({"document": "d", "ops": ops}, family=FAM, alloy="", physics=toolwiz_app.physics,
                     machine_profile=toolwiz_app.active_machine())


def _op(name, strategy, params, **extra):
    return dict({"setup": "S", "name": name, "path": f"S > {name}", "strategy": strategy, "tool": ENDMILL, "params": params}, **extra)


def _one(op):
    o = _advise([op])["operations"][0]
    return (o["apply_plan"] or {}).get("recommended") or {}, o["notes"], o


def _tw_ramp():
    return _advise([_op("Op", "pocket2d", dict(P, tool_rampAngle="30 deg"))])["operations"][0]["toolwiz"]["recommended"]["ramp_angle_deg"]


# ---- A. ramp angle is degrees ---------------------------------------------------------------------------------------

def test_ramp_angle_deg_prefers_expression_and_treats_evaluated_as_degrees():
    assert tw.ramp_angle_deg("2.", 114.59) == 2.0 and tw.ramp_angle_deg("2 deg", None) == 2.0
    assert tw.ramp_angle_deg("Math.max(1; 2)", 2.0) == 2.0            # formula: the evaluated value, as degrees
    assert tw.ramp_angle_deg("tool_rampAngle", 114.59) is None        # above 90 deg: not believed
    assert tw.ramp_angle_deg("2.", None) == 2.0 and tw.ramp_angle_deg("0", 0) is None


def test_evaluated_angle_is_degrees_in_display_and_equality():
    assert tw.evaluated_to_base("tool_rampAngle", 2.0) == 2.0
    assert tw.display_current("tool_rampAngle", "tool_rampAngle", "7.1 deg", 18.2) .startswith("18.2 deg")
    assert tw.expr_equal("x", "2 deg", 2.0, "tool_rampAngle")


def test_snapshot_ramp_angle_from_degree_valued_parameter():
    a = load_addin()
    tool = dict(ENDMILL, **{"post-process": {"number": 1}})
    op = SimpleNamespace(name="Pocket1", strategy="pocket2d", tool=SimpleNamespace(toJson=lambda: json.dumps(tool)),
                         parameters=ParamsByName({"tool_spindleSpeed": param("12000 rpm"),
                                                  "tool_rampAngle": param("2.", 2.0)}))
    assert a.op_advisor_entry(op, "S > Pocket1")["params"]["tool_rampAngle"] == "2.00 deg"
    op.parameters = ParamsByName({"tool_rampAngle": param("tool_rampAngle", 2.0)})       # a link: the evaluated value, in degrees
    assert a.op_advisor_entry(op, "S > Pocket1")["params"]["tool_rampAngle"] == "2.00 deg"
    op.parameters = ParamsByName({"tool_rampAngle": param("x", 114.59)})
    assert "tool_rampAngle" not in a.op_advisor_entry(op, "S > Pocket1")["params"]


def test_owner_2_deg_kept_and_18_deg_lowered():
    ang = _tw_ramp()
    assert ang > 2.5
    plan, notes, _ = _one(_op("Op", "pocket2d", dict(P, tool_rampAngle="2.0 deg")))
    assert "tool_rampAngle" not in plan and f"Ramp angle kept at your 2.0 deg; ToolWiz's limit is {ang:.1f} deg." in notes
    plan, _, _ = _one(_op("Op", "pocket2d", dict(P, tool_rampAngle=f"{ang + 11.1:.1f} deg")))
    assert plan["tool_rampAngle"] == f"{ang:.1f} deg"
    plan, notes, _ = _one(_op("Op", "pocket2d", dict(P, tool_rampAngle="114.59 deg")))       # not believed: nothing proposed
    assert "tool_rampAngle" not in plan and not any(n.startswith("Ramp angle kept") for n in notes)


# ---- B / C. stock only where enabled; no "kept" noise ----------------------------------------------------------------

def test_stock_not_proposed_when_the_stock_option_is_off():
    plan, notes, _ = _one(_op("Contour", "contour2d", P, stock_to_leave_enabled=False))
    assert "stockToLeave" not in plan and "verticalStockToLeave" not in plan
    assert any("Stock to leave is off on this operation" in n and "ToolWiz would leave" in n for n in notes)
    plan, _, _ = _one(_op("Pocket", "pocket2d", P))                                           # flat snapshot: round-4 behaviour
    assert "stockToLeave" in plan
    plan, _, _ = _one(_op("Pocket", "pocket2d", dict(P, stockToLeave="0 in"), stock_to_leave_enabled=True))
    assert "stockToLeave" in plan


def test_contour_stock_only_when_clearly_roughing():
    plan, notes, _ = _one(_op("2D Contour3", "contour2d", dict(P, stockToLeave="0 in"), stock_to_leave_enabled=True, kind="contour"))
    assert "stockToLeave" not in plan and any("not clearly a roughing pass" in n for n in notes)
    plan, _, _ = _one(_op("Rough Contour", "contour2d", dict(P, stockToLeave="0 in"), stock_to_leave_enabled=True, kind="contour"))
    assert "stockToLeave" in plan


def test_snapshot_reports_whether_stock_to_leave_is_enabled():
    a = load_addin()
    tool = dict(ENDMILL, **{"post-process": {"number": 1}})
    op = SimpleNamespace(name="C", strategy="contour2d", tool=SimpleNamespace(toJson=lambda: json.dumps(tool)),
                         parameters=ParamsByName({"tool_spindleSpeed": param("12000 rpm")}))
    a.is_op_stock_to_leave_active = lambda o: False
    e = a.op_advisor_entry(op, "S > C")
    assert e["stock_to_leave_enabled"] is False and "stockToLeave" not in e["params"]


def test_kept_notes_only_when_values_differ():
    _, notes, _ = _one(_op("Pocket", "pocket2d", dict(P, stockToLeave="0.0050 in", verticalStockToLeave="0.1mm")))
    assert not any("Stock to leave kept" in n for n in notes)                                 # equal to ToolWiz's 0.0050
    assert any("Vertical stock to leave kept at your 0.0039 in" in n for n in notes)
    ang = _tw_ramp()
    _, notes, _ = _one(_op("Pocket", "pocket2d", dict(P, tool_rampAngle=f"{ang:.2f} deg")))
    assert not any(n.startswith("Ramp angle kept") for n in notes)


# ---- D. High Engagement caution ---------------------------------------------------------------------------------------

def _hi(woc, op, dia=0.25):
    rep = oversight_engine.evaluate_holistic_oversight(
        {"family": FAM, "alloy": "", "operation": op, "coating": "ZrN", "diameter": dia, "flutes": 4, "fluteLength": 0.75,
         "shankDiameter": 0.25, "runout": 0.0005, "tool": "Carbide Endmill"},
        {"operation": op, "woc": woc, "doc": 0.5, "rpm": 12000, "feed": 40})
    return [f for f in rep.findings if "High Engagement" in f.title]


def test_high_engagement_gated_on_half_diameter_roughing_only():
    assert len(_hi(0.125, "Roughing")) == 1 and len(_hi(0.25, "Slotting")) == 1
    assert _hi(0.025, "Roughing") == [] and _hi(0.025, "Slotting") == []                     # 10 % D: not high
    assert _hi(0.0121, "Roughing", dia=0.125) == []                                           # micro tool at 10 % D
    for op in ("Finishing", "Chamfer", "Deburr", "Engrave", "Probe", "Drilling"):
        assert _hi(0.25, op) == [], op


# ---- E. ramp only where the operation ramps ---------------------------------------------------------------------------

def _ramping(kind_strategy, name="Op", ramp=RAMP_ON, **extra):
    return _one(_op(name, kind_strategy, dict(P, tool_rampAngle="30 deg"), ramp=ramp, **extra))


def test_contour_ramp_needs_ramp_entry_and_material_removal():
    plan, _, _ = _ramping("contour2d", multiple_depths=True)
    assert "tool_rampAngle" in plan
    plan, notes, _ = _ramping("contour2d", multiple_depths=False, ramp=RAMP_ON)
    assert "tool_rampAngle" not in plan and "light finishing pass: ramp angle not proposed" in notes
    plan, notes, _ = _ramping("contour2d", multiple_depths=True, ramp={"enabled": None, "type": None, "raw": {}})
    assert "tool_rampAngle" not in plan and "ramp entry not detected; ramp angle not proposed" in notes
    plan, notes, _ = _ramping("contour2d", multiple_depths=True, ramp={"enabled": False, "type": "Plunge", "raw": {}})
    assert "tool_rampAngle" not in plan and any("does not ramp" in n for n in notes)


def test_contour_with_wide_stepover_counts_as_material_removal():
    plan, _, _ = _one(_op("Op", "contour2d", dict(P, stepover="0.1 in", tool_rampAngle="30 deg"), ramp=RAMP_ON, multiple_depths=False))
    assert "tool_rampAngle" in plan


def test_adaptive_and_pocket_ramp_when_flag_unknown_but_not_edge_or_trace():
    unknown = {"enabled": None, "type": None, "raw": {}}
    assert "tool_rampAngle" in _ramping("adaptive2d", ramp=unknown)[0]
    assert "tool_rampAngle" in _ramping("pocket2d", ramp=unknown)[0]
    assert "tool_rampAngle" not in _ramping("pocket2d", ramp={"enabled": False, "type": "Plunge", "raw": {}})[0]
    assert "tool_rampAngle" not in _ramping("chamfer2d")[0]
    assert "tool_rampAngle" not in _ramping("trace", name="Trace1", kind="rough")[0]
    assert "tool_rampAngle" not in _ramping("contour2d", kind="finish")[0]


def test_snapshot_records_the_ramp_entry_and_multiple_depths():
    a = load_addin()
    tool = dict(ENDMILL, **{"post-process": {"number": 1}})

    def op(params):
        return SimpleNamespace(name="C", strategy="contour2d", tool=SimpleNamespace(toJson=lambda: json.dumps(tool)),
                               parameters=ParamsByName(params))
    p = ParamsByName({"doMultipleDepths": param("true"), "rampType": param("'ramp'"), "rampAngle": param("2.", 2.0)})
    p.__iter__ = lambda self: iter([])
    e = a.op_advisor_entry(op({"doMultipleDepths": param("true"), "rampType": param("'ramp'")}), "S > C")
    assert e["multiple_depths"] is True and e["ramp"]["enabled"] is True and e["ramp"]["type"] == "ramp"
    e = a.op_advisor_entry(op({"tool_spindleSpeed": param("9000 rpm")}), "S > C")
    assert e["multiple_depths"] is None and e["ramp"]["enabled"] is None


# ---- F. the ramp chart sentence ---------------------------------------------------------------------------------------

def test_ramp_chart_sentence_in_advisor_notes_and_addin_dialog():
    plan, notes, _ = _one(_op("Op", "pocket2d", dict(P, tool_rampAngle="30 deg")))
    assert "tool_rampAngle" in plan and any(n.startswith("Ramp angle from") for n in notes)
    assert tw.ramp_basis_text({"v2": {"ramp_basis": "Ramp angle from X chart"}}) == "Ramp angle from X chart"
    assert tw.ramp_basis_text({"v2": {"ramp": {"angle_basis": {"text": "T"}}}}) == "T" and tw.ramp_basis_text({}) == ""
