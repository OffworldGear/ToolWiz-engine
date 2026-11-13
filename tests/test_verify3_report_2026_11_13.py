"""Fixes for the owner's Fusion dialog check and coating notes (docs/FUSION_BRIDGE_VERIFY2_2026-11-13.md, last sections)."""
import math
import sys
import os
from types import SimpleNamespace

import pytest

import app as toolwiz_app
import setup_advisor as sa
from test_addin_common import load_addin, param, ParamsByName

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "ToolWizFusionAddin"))
import twlogic as tw  # noqa: E402

FAM = "Aluminum - Wrought (6061)"
ENDMILL = {"type": "flat end mill", "unit": "inches", "description": "1/8 3 flute endmill",
           "geometry": {"DC": 0.125, "NOF": 3, "LCF": 0.5, "SFDM": 0.125, "LB": 1.5}}


def _advise(ops):
    return sa.advise({"document": "d", "ops": ops}, family=FAM, alloy="", physics=toolwiz_app.physics,
                     machine_profile=toolwiz_app.active_machine())


def _op(name, strategy, params, **extra):
    return dict({"setup": "S", "name": name, "path": f"S > {name}", "strategy": strategy, "tool": ENDMILL, "params": params}, **extra)


# ---- 1. current side shows the evaluated value ----------------------------------------------------------------------

def test_display_current_uses_evaluated_value_in_the_new_values_unit():
    d = tw.display_current
    assert d("stockToLeave", "0.1mm", "0.00250 in", 0.01) == "0.00394 in"                      # cm -> in
    assert d("tool_feedCutting", "50.1921790628448in/min", "47.74 in/min", 50.1921790628448 * 25.4) \
        == "50.19 in/min"                                                                         # mm/min -> in/min
    assert d("tool_rampAngle", "2.", "18.6 deg", math.radians(2.0)) == "2.0 deg"                 # radians -> deg
    assert d("tool_spindleSpeed", "11999.11612839420377", "16000 rpm", 11999.116) == "11999 rpm"
    assert d("stockToLeave", "0.1mm", "0.0635 mm", 0.01) == "0.1000 mm"                         # new side in mm: same unit


def test_display_current_notes_links_and_formulas_but_not_plain_numbers():
    assert tw.display_current("maximumStepdown", "tool_stepdown", "0.19947 in", 0.5) == \
        "0.19685 in (replaces the link to tool_stepdown)"
    f = "(tool_type=='drill' || tool_type=='reamer')?(1000mmpm):(tool_feedCutting/3)"
    out = tw.display_current("tool_feedPlunge", f, "13.17 in/min", 16.73 * 25.4)
    assert out == "16.73 in/min (replaces a formula)"
    assert "replaces" not in tw.display_current("tool_rampAngle", "2.", "18.6 deg", math.radians(2))
    assert tw.display_current("stockToLeave", "?", "0.0025 in") == "?"                          # unknown: no invented note


def test_display_current_without_evaluated_value_converts_a_plain_expression():
    assert tw.display_current("stockToLeave", "0.1mm", "0.00250 in") == "0.00394 in"
    assert tw.display_current("tool_feedCutting", "50.1921790628448in/min", "47.74 in/min") == "50.19 in/min"


def test_summarize_changes_shows_evaluated_current_values():
    lines = tw.summarize_changes({"S > Op": {"stockToLeave": "0.00250 in", "tool_rampAngle": "18.6 deg"}},
                                 {"S > Op": {"stockToLeave": "0.1mm", "tool_rampAngle": "2."}},
                                 {"S > Op": {"stockToLeave": 0.01, "tool_rampAngle": math.radians(2)}})
    assert lines == ["S > Op: stockToLeave: 0.00394 in -> 0.00250 in", "S > Op: tool_rampAngle: 2.0 deg -> 18.6 deg"]


def test_expr_equal_compares_evaluated_values():
    assert tw.expr_equal("0.1mm", "0.00394 in", 0.01, "stockToLeave")
    assert tw.expr_equal("2.", "2 deg", math.radians(2), "tool_rampAngle")
    assert not tw.expr_equal("0.1mm", "0.00250 in", 0.01, "stockToLeave")
    assert tw.expr_equal("tool_stepdown", "0.25 in", 0.635, "maximumStepdown")                  # a link that evaluates to it
    assert not tw.expr_equal("tool_stepdown", "0.25 in")                                          # no value: never dropped (old rule)
    ch, same = tw.drop_unchanged({"o": {"stockToLeave": "0.00394 in", "tool_rampAngle": "18.6 deg"}},
                                 {"o": {"stockToLeave": "0.1mm", "tool_rampAngle": "2."}},
                                 {"o": {"stockToLeave": 0.01, "tool_rampAngle": math.radians(2)}})
    assert ch == {"o": {"tool_rampAngle": "18.6 deg"}} and same == 1


def test_addin_confirmation_and_current_values_show_evaluated_numbers():
    a = load_addin()
    text = a.format_apply_confirmation("S > Op", {"stockToLeave": ("0.1mm", "0.00250 in"), "maximumStepdown": ("tool_stepdown", "0.2 in")},
                                       {}, "r", {"stockToLeave": 0.01, "maximumStepdown": 0.5})
    assert "stockToLeave: 0.00394 in -> 0.00250 in" in text
    assert "maximumStepdown: 0.20 in (replaces the link to tool_stepdown) -> 0.2 in" in text
    op = SimpleNamespace(parameters=ParamsByName({"stockToLeave": param("0.1mm", 0.01), "tool_rampAngle": param("2.", math.radians(2))}))
    a._op_by_id = lambda op_id: ("S", "S > Op", op)
    vals = a.current_param_values({"S > Op": {"stockToLeave": "x", "tool_rampAngle": "y", "missing": "z"}})
    assert vals["S > Op"]["stockToLeave"] == 0.01 and vals["S > Op"]["missing"] is None
    assert math.isclose(vals["S > Op"]["tool_rampAngle"], math.radians(2))


# ---- 2. the owner's stock and ramp angle ----------------------------------------------------------------------------

P_ROUGH = {"tool_spindleSpeed": "9000 rpm", "tool_feedCutting": "20 in/min", "maximumStepdown": "0.2 in", "stepover": "0.05 in"}


def _plan(res, name="Op"):
    o = next(o for o in res["operations"] if o["name"] == name)
    return (o["apply_plan"] or {}).get("recommended") or {}, o["notes"]


def test_nonzero_owner_stock_is_kept_and_noted():
    res = _advise([_op("Op", "pocket2d", dict(P_ROUGH, stockToLeave="0.1mm", verticalStockToLeave="0.1mm"))])
    plan, notes = _plan(res)
    assert "stockToLeave" not in plan and "verticalStockToLeave" not in plan
    assert any("Stock to leave kept at your 0.0039 in; ToolWiz would leave" in n for n in notes)


def test_stock_is_proposed_only_when_zero_or_unset_on_roughing():
    plan0, _ = _plan(_advise([_op("Op", "pocket2d", dict(P_ROUGH, stockToLeave="0 in"))]))
    plan_unset, _ = _plan(_advise([_op("Op", "pocket2d", P_ROUGH)]))
    assert plan0["stockToLeave"] == "0.00250 in" and plan_unset["stockToLeave"] == "0.00250 in"
    assert "verticalStockToLeave" in plan_unset


def test_finishing_ops_never_get_stock():
    res = _advise([_op("Op", "contour2d", dict(P_ROUGH, stockToLeave="0 in"), kind="finish")])
    plan, _ = _plan(res)
    assert "stockToLeave" not in plan and "verticalStockToLeave" not in plan


def _ramp_op(cur):
    p = dict(P_ROUGH)
    if cur is not None:
        p["tool_rampAngle"] = cur
    return _op("Op", "pocket2d", p)


def test_ramp_angle_only_lowered_never_raised():
    rec = _advise([_ramp_op("2 deg")])["operations"][0]["toolwiz"]["recommended"]
    tw_ang = rec["ramp_angle_deg"]
    assert tw_ang > 2.5, "test premise: ToolWiz ramp angle is above 2 deg for this op"
    plan, notes = _plan(_advise([_ramp_op("2 deg")]))
    assert "tool_rampAngle" not in plan and "tool_feedRamp" not in plan
    assert any(n.startswith("Ramp angle kept at your 2.0 deg; ToolWiz's limit is") for n in notes)
    high = f"{tw_ang + 10:.1f} deg"
    plan, notes = _plan(_advise([_ramp_op(high)]))
    assert plan["tool_rampAngle"] == f"{tw_ang:.1f} deg"


def test_unknown_current_ramp_angle_proposes_none():
    plan, _ = _plan(_advise([_ramp_op(None)]))
    assert "tool_rampAngle" not in plan and "tool_feedRamp" not in plan


def test_addin_snapshot_reports_current_ramp_angle():
    a = load_addin()
    assert "tool_rampAngle" in open(a.__file__, encoding="utf-8").read()
    op = SimpleNamespace(parameters=ParamsByName({"tool_rampAngle": param("2.", math.radians(2))}))
    got = None
    for n in ("tool_rampAngle", "rampAngle"):
        p = a._param(op.parameters, n)
        if p is not None:
            got = math.degrees(a._numeric_param_value(p))
            break
    assert round(got, 3) == 2.0


# ---- 3. coating words, not substrings -------------------------------------------------------------------------------

CASES = [("1/4 cutting endmill", None), ("1/8 EM AlTiN", "AlTiN"), ("TiN coated HSS drill", "TiN"), ("3 flute ZrN", "ZrN"),
         ("fluting cutter tinted", None), ("coating test Martin", None), ("plunging tool", None),
         ("x TiAlN", "TiAlN"), ("x TiCN", "TiCN"), ("x TiSiN", "TiSiN"), ("x AlCrN", "AlCrN"), ("x DLC", "DLC"),
         ("x diamond", "Diamond"), ("x TiB2", "TiB2"), ("1/4 uncoated", "Uncoated"), ("Chamfer 4fl 90deg altin", "AlTiN")]


@pytest.mark.parametrize("text,want", CASES)
def test_server_coating_rule(text, want):
    assert sa.coating_in_text(text) == want
    assert sa.parse_tool(dict(ENDMILL, description=text))["coating"] == want


@pytest.mark.parametrize("text,want", CASES)
def test_addin_coating_rule_matches_server(text, want):
    got = tw.coating_in_text(text)
    assert got == ({"DLC": "Diamond"}.get(want, want))      # the add-in names DLC and diamond "Diamond"


def test_addin_tool_info_uses_whole_word_coating():
    a = load_addin()
    import json
    for desc, want in (("1/4 cutting endmill", None), ("1/8 EM AlTiN", "AlTiN"), ("fluting cutter tinted", None)):
        t = dict(ENDMILL, description=desc)
        op = SimpleNamespace(name="Op", strategy="adaptive2d", parameters=ParamsByName({}),
                             tool=SimpleNamespace(toJson=lambda t=t: json.dumps(t)))
        geo, _, _ = a.get_op_tool_info(op)
        assert geo.get("stated_coating") == want, desc


# ---- 4. caution text and guide --------------------------------------------------------------------------------------

def test_coating_caution_points_to_the_description_convention_and_guide_has_the_section():
    res = _advise([_op("A", "pocket2d", P_ROUGH)])
    texts = [f["recommendation"] for o in res["operations"] for f in o["findings"] if "Coating Unknown" in f["title"]]
    assert texts and all("as its own word in the tool description" in t for t in texts)
    guide = open(os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "docs", "ADDIN_USER_GUIDE.md"), encoding="utf-8").read()
    assert "### Recording coating and tool material" in guide and "HSS" in guide
