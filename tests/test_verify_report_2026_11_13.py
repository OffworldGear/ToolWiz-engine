"""Fixes for docs/FUSION_BRIDGE_VERIFY_2026-11-13.md (the shop PC's verification against live Fusion)."""
import json
import unittest
from types import SimpleNamespace

import app as toolwiz_app
import setup_advisor as sa
from test_addin_audit import AuditBase, make_op
from test_addin_common import load_addin, param, ParamsByName
from test_addin_v3_commands import cam_with

FAM = "Aluminum - Wrought (6061)"
ENDMILL = {"type": "flat end mill", "unit": "inches", "description": "1/4 4 flute endmill",
           "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.75, "SFDM": 0.25, "LB": 2.0}}


def _advise(ops):
    return sa.advise({"document": "d", "ops": ops}, family=FAM, alloy="", physics=toolwiz_app.physics,
                     machine_profile=toolwiz_app.active_machine())


def _op(name, strategy, params, tool=None):
    return {"setup": "S", "name": name, "path": f"S > {name}", "strategy": strategy, "tool": tool or ENDMILL, "params": params}


# ---- 1. drill ops are not "Reaming" ---------------------------------------------------------------------------------

def _drill_op(cycle):
    tool = {"type": "drill", "unit": "millimeters", "description": "1.45mm carbide drill for M1.6 form tap",
            "post-process": {"number": 7}, "geometry": {"DC": 1.45, "NOF": 2, "LCF": 8.0, "SFDM": 3.0, "LB": 12.0, "TA": 118.0}}
    params = ParamsByName({"cycleType": param(cycle)}) if cycle else ParamsByName({})
    return SimpleNamespace(name="Drill4 (5)", strategy="drill", parameters=params, tool=SimpleNamespace(toJson=lambda: json.dumps(tool)))


def test_drill_tool_is_never_reaming_unless_the_cycle_is_exactly_reaming():
    a = load_addin()
    for cyc in (None, "'drilling'", "'deep drilling'", "'breakthrough'", "'streaming'", "'chip breaking'"):
        op = _drill_op(cyc)
        geo, _, _ = a.get_op_tool_info(op)
        label = a.infer_strategy_for_op(op, geo)
        assert label != "Reaming", (cyc, label)
    op = _drill_op("'reaming'")                                      # a genuine reaming cycle stays "Reaming"
    geo, _, _ = a.get_op_tool_info(op)
    assert a.infer_strategy_for_op(op, geo) == "Reaming"
    reamer = SimpleNamespace(name="Ream1", strategy="drill", parameters=ParamsByName({}),
                             tool=SimpleNamespace(toJson=lambda: json.dumps({"type": "reamer", "unit": "inches", "description": "1/4 reamer",
                                                                            "geometry": {"DC": 0.25, "NOF": 6, "LCF": 1.0, "SFDM": 0.25, "LB": 3.0}})))
    geo, _, _ = a.get_op_tool_info(reamer)
    assert a.infer_strategy_for_op(reamer, geo) == "Reaming"        # a reamer tool still is


def test_snapshot_entry_carries_the_raw_cycle_type():
    a = load_addin()
    op = _drill_op("'deep drilling'")
    e = a.op_advisor_entry(op, "S > Drill4 (5)")
    assert e["cycle_type"] == "'deep drilling'" and e["strategy_label"] != "Reaming"
    assert a.op_advisor_entry(_drill_op(None), "S > D")["cycle_type"] is None


# ---- 2. no-op values are not listed or written ----------------------------------------------------------------------

def test_plan_drops_values_equal_to_the_current_ones_and_says_nothing_to_change():
    p = {"tool_spindleSpeed": "12000 rpm", "tool_feedCutting": "40 in/min", "maximumStepdown": "0.1 in", "stepover": "0.05 in"}
    first = _advise([_op("Pocket1", "pocket2d", p)])["operations"][0]
    rec = first["apply_plan"]["recommended"]
    # feed the advisor its own recommendation: nothing is left to change
    again = _advise([_op("Pocket1", "pocket2d", dict(p, **{k: v for k, v in rec.items() if k in p}))])["operations"][0]
    assert again["apply_plan"] is None or all(
        not sa._expr_equal(dict(p, **{k: v for k, v in rec.items() if k in p}).get(k, "?"), v, sa.PARAM_KINDS[k])
        for plan in again["apply_plan"].values() for k, v in plan.items())
    assert any("nothing to change" in n or "already match" in n for n in again["notes"])


def test_plan_keeps_only_real_changes():
    op = {"op_id": "S > A", "current": {"rpm": 12000.0, "feed_ipm": 50.0, "stepdown_in": 0.1, "stepover_in": 0.05,
                                        "stock_radial_in": None, "stock_axial_in": None}, "rich": True, "current_extra": {}}
    notes = []
    out = sa._finalize_plans(op, {"recommended": {"tool_spindleSpeed": "12000 rpm", "tool_feedCutting": "60.00 in/min",
                                                  "maximumStepdown": "0.10000 in"}}, notes)
    assert out == {"recommended": {"tool_feedCutting": "60.00 in/min"}}
    assert sa._finalize_plans(op, {"recommended": {"tool_spindleSpeed": "12000 rpm"}}, notes) is None
    assert "nothing to change" in notes[-1]


class TestApplyNoChange(AuditBase):
    def setUp(self):
        super().setUp()
        self.params = {"maximumStepdown": param("0.25 in"), "tool_feedCutting": param("535.29 in/min"), "tool_spindleSpeed": param("8000 rpm")}
        cam_with(self.a, {"Setup1": [make_op("Adaptive1", params=self.params)]})
        self.a.ui.messageBox.return_value = self.a.adsk.core.DialogResults.DialogYes

    def call(self, params):
        return self.a.dispatch_bridge_action("apply_operation_parameters", {"op_id": "Setup1 > Adaptive1", "reason": "r", "params": params})

    def test_equal_values_are_not_written_nor_listed(self):
        r = self.call({"maximumStepdown": "0.25000 in", "tool_feedCutting": "140.77 in/min", "tool_spindleSpeed": "8000 rpm"})
        assert r["ok"] and list(r["applied"]) == ["tool_feedCutting"]
        assert set(r["unchanged"]) == {"maximumStepdown", "tool_spindleSpeed"}
        text = self.a.ui.messageBox.call_args[0][0]
        assert "tool_feedCutting: 535.29 in/min -> 140.77 in/min" in text and "maximumStepdown" not in text
        assert {e["param"] for e in self.entries() if e["event"] == "param_change"} == {"tool_feedCutting"}

    def test_nothing_changes_says_so_and_writes_nothing(self):
        self.a.ui.messageBox.reset_mock()
        r = self.call({"maximumStepdown": "0.25 in", "tool_spindleSpeed": "8000.0 rpm"})
        assert r["ok"] and r["applied"] == {} and "No change" in r["message"]
        self.a.ui.messageBox.assert_not_called()
        assert not [e for e in self.entries() if e["event"] == "param_change"]


def test_dialog_helpers_drop_no_ops_and_prune_recs():
    from ToolWizFusionAddin import twlogic as t
    cur = {"S > A": {"tool_spindleSpeed": "12000 rpm", "tool_feedCutting": "535.29 in/min", "maximumStepdown": "tool_stepdown"}}
    ch, n = t.drop_unchanged({"S > A": {"tool_spindleSpeed": "12000 rpm", "tool_feedCutting": "140.77 in/min",
                                        "maximumStepdown": "0.25 in"}}, cur)
    assert ch == {"S > A": {"tool_feedCutting": "140.77 in/min", "maximumStepdown": "0.25 in"}} and n == 1   # a named expression is kept
    recs = [{"id": "r1", "changes": {"S > A": {"tool_spindleSpeed": "12000.0 rpm"}}}, {"id": "r2", "changes": {"S > A": {"tool_feedCutting": "1 in/min"}}}]
    kept, n = t.prune_unchanged_recs(recs, cur)
    assert [r["id"] for r in kept] == ["r2"] and n == 1
    assert t.expr_equal("25.4 mm", "1.0 in") and not t.expr_equal("1 in", "1 in/min") and not t.expr_equal("?", "1 in")


# ---- 3. the two apply plans are mutually exclusive ------------------------------------------------------------------

def _plan_recs():
    from ToolWizFusionAddin import twlogic as t
    res = {"success": True, "operations": [{"op_id": "S > A", "name": "A", "findings": [], "apply_plan": {
        "recommended": {"tool_spindleSpeed": "11522 rpm", "tool_feedCutting": "131.66 in/min"},
        "keep_engagement": {"tool_spindleSpeed": "11522 rpm", "tool_feedCutting": "132.02 in/min"}}}]}
    return t, t.extract_recommendations(t.parse_advisor_response(res))


def test_recommended_plan_is_the_default_and_only_one_plan_stays_selected():
    t, recs = _plan_recs()
    rec_id, keep_id = recs[0]["id"], recs[1]["id"]
    assert (recs[0]["plan"], recs[1]["plan"]) == ("recommended", "keep_engagement")
    assert t.default_selected_rec_ids(recs) == {rec_id}
    # ticking the second one while the first is ticked: the newly ticked plan wins; the reverse as well
    assert t.enforce_exclusive_plans(recs, {rec_id, keep_id}, previous_ids={rec_id}) == {keep_id}
    assert t.enforce_exclusive_plans(recs, {rec_id, keep_id}, previous_ids={keep_id}) == {rec_id}
    merged, conflicts = t.merge_selected_changes(recs, {rec_id, keep_id})      # even a stale selection never reaches the apply
    assert conflicts == [] and merged["S > A"]["tool_feedCutting"] == "131.66 in/min"


def test_web_advisor_offers_the_two_plans_as_separate_buttons_not_checkboxes():
    src = open("static/js/advisor_ui.js", encoding="utf-8").read()
    assert "advisorApply(" in src and "type=\"checkbox\"" not in src.split("function applyBlock")[1].split("window.advisorApply")[0]


# ---- 4. no plan entries for parameters the operation does not have --------------------------------------------------

def test_contour_without_stepover_or_stepdown_gets_neither_in_its_plan():
    p = {"tool_spindleSpeed": "12000 rpm", "tool_feedCutting": "30 in/min"}        # a snapshot lists only what the op has
    o = _advise([_op("2D Contour1", "contour2d", p)])["operations"][0]
    assert o["apply_plan"], o
    for plan in o["apply_plan"].values():
        assert not {"maximumStepdown", "stepover", "optimalLoad"} & set(plan), plan
        assert "tool_spindleSpeed" in plan or "tool_feedCutting" in plan
    notes = " ".join(o["notes"])
    assert "Not proposed: maximumStepdown" in notes and "Not proposed: stepover" in notes and "no stepover" in notes


def test_stepdown_and_stepover_stay_when_the_snapshot_has_them():
    p = {"tool_spindleSpeed": "6000 rpm", "tool_feedCutting": "10 in/min", "maximumStepdown": "0.5 in", "stepover": "0.2 in"}
    o = _advise([_op("2D Contour3", "contour2d", p)])["operations"][0]
    assert "maximumStepdown" in o["apply_plan"]["recommended"] and "stepover" in o["apply_plan"]["recommended"]


# ---- 5. a contour with no stepover is not read as a full slot -------------------------------------------------------

def test_contour_without_stepover_has_no_width_numbers_and_no_stepover_finding():
    p = {"tool_spindleSpeed": "12000 rpm", "tool_feedCutting": "30 in/min", "maximumStepdown": "0.25 in"}
    o = _advise([_op("2D Contour1", "contour2d", p)])["operations"][0]
    assert o["kind"] == "contour" and o["current"]["stepover_in"] is None and o["current"]["mrr_in3_min"] is None
    assert o["toolwiz"]["at_current_engagement"] is None
    codes = {f["code"] for f in o["findings"]}
    assert not codes & {"stepover_high", "oversight_engagement"} and not any("High Engagement" in f["title"] for f in o["findings"])


def test_addin_snapshot_has_no_stepover_for_a_contour_without_one():
    a = load_addin()
    op = SimpleNamespace(name="2D Contour1", strategy="contour2d", tool=SimpleNamespace(toJson=lambda: json.dumps(ENDMILL)),
                         parameters=ParamsByName({"tool_spindleSpeed": param("12000 rpm"), "tool_feedCutting": param("30 in/min"),
                                                  "maximumStepdown": param("0.25 in"), "stepover": param("0.25 in")}))
    op.parameters.mapping["stepover"].isEnabled = False
    e = a.op_advisor_entry(op, "S > 2D Contour1")
    assert "stepover" not in e["params"] and "optimalLoad" not in e["params"]


# ---- 6. "Uncoated" is a known coating; unknown is flagged once per tool ---------------------------------------------

def _coating_findings(res):
    return [(o["name"], f) for o in res["operations"] for f in o["findings"] if f["title"].startswith("Tool Coating Unknown")]


def test_uncoated_is_known_and_not_flagged():
    for label in ("Uncoated", "bright", "none"):
        assert sa.parse_tool(dict(ENDMILL, coating=label))["coating"] == "Uncoated"
    assert sa.parse_tool(dict(ENDMILL, description="1/4 endmill uncoated"))["coating"] == "Uncoated"
    assert sa.parse_tool(dict(ENDMILL, BMC="carbide", GRADE="Bright"))["coating"] == "Uncoated"
    p = {"tool_spindleSpeed": "12000 rpm", "tool_feedCutting": "40 in/min", "maximumStepdown": "0.1 in", "stepover": "0.05 in"}
    res = _advise([dict(_op("Pocket1", "pocket2d", p), tool=dict(ENDMILL, coating="Uncoated")),
                   dict(_op("Pocket2", "pocket2d", p), coating="Uncoated")])
    assert _coating_findings(res) == []


def test_unknown_coating_is_flagged_once_per_tool_with_an_honest_message():
    p = {"tool_spindleSpeed": "12000 rpm", "tool_feedCutting": "40 in/min", "maximumStepdown": "0.1 in", "stepover": "0.05 in"}
    other = dict(ENDMILL, description="3/8 endmill", geometry={"DC": 0.375, "NOF": 3, "LCF": 1.0, "SFDM": 0.375, "LB": 2.5})
    res = _advise([_op("Pocket1", "pocket2d", p), _op("Pocket2", "pocket2d", p), _op("Pocket3", "pocket2d", p, tool=other)])
    got = _coating_findings(res)
    assert [n for n, _ in got] == ["Pocket1", "Pocket3"]                       # one per tool, not per operation
    assert "(Uncoated)" not in got[0][1]["detail"] and "not set" in got[0][1]["detail"]


if __name__ == "__main__":
    unittest.main()


def test_a_current_zero_is_not_equal_to_a_small_new_value():
    from ToolWizFusionAddin import twlogic as t
    assert not t.expr_equal("0 in", "0.003 in") and t.expr_equal("0 in", "0.0 in")
