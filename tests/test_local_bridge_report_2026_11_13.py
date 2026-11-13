"""Fixes for docs/FUSION_BRIDGE_LOCAL_TEST_2026-11-13.md (the shop PC's first live bridge test)."""
import json
import socket
from types import SimpleNamespace

import app as toolwiz_app
import fusion_bridge
import setup_advisor as sa
from test_addin_common import load_addin


def _op(strategy, name="op", tool=None):
    return SimpleNamespace(name=name, strategy=strategy, parameters=SimpleNamespace(itemByName=lambda _: None),
                           tool=SimpleNamespace(toJson=lambda: json.dumps(tool or {})))


def test_second_server_is_detected_and_free_port_is_not():
    with socket.socket() as s:
        s.bind(("127.0.0.1", 0))
        s.listen(1)
        port = s.getsockname()[1]
        assert toolwiz_app.already_running("127.0.0.1", port, timeout=0.5) == "another program, or an older ToolWiz"
    assert toolwiz_app.already_running("127.0.0.1", port, timeout=0.3) is None


def test_bridge_reports_addin_polling_separately_from_the_snapshot():
    fusion_bridge.reset_bridge_state()
    st = fusion_bridge.get_live_state()
    assert st["connected"] is False and st["addin_polling"] is False and st["addin_last_poll_age_s"] is None
    fusion_bridge.pop_next_command()                       # what the add-in's poll does
    st = fusion_bridge.get_live_state()
    assert st["addin_polling"] is True and st["snapshot_present"] is False
    assert fusion_bridge.addin_poll_status(now=__import__("time").time() + 60)["addin_polling"] is False


def test_inspect_operation_requires_an_operation():
    import pytest
    for params in ({}, {"operation": ""}, {"operation_name": "Drill4"}):
        with pytest.raises(ValueError, match="'operation' is required"):
            fusion_bridge.enqueue_command("inspect_operation", params)


def test_setup_advisor_does_not_treat_chamfer_deburr_engrave_as_roughing():
    tool = {"type": "chamfer mill", "unit": "inches", "description": "1/4 chamfer mill",
            "geometry": {"DC": 0.25, "NOF": 2, "LCF": 0.25, "SFDM": 0.25, "LB": 1.0}}
    for strat in ("chamfer2d", "deburr", "engrave"):
        assert sa.classify_op(strat, "x", sa.parse_tool(tool), {}, None) == "edge"
    res = sa.advise({"document": "d", "ops": [{"setup": "S", "name": "2D Chamfer1", "path": "S > 2D Chamfer1", "strategy": "chamfer2d",
                                              "tool": tool, "params": {"tool_spindleSpeed": "8000 rpm", "tool_feedCutting": "20 in/min"}}]},
                    family="Aluminum - Wrought (6061)", alloy="", physics=toolwiz_app.physics, machine_profile=toolwiz_app.active_machine())
    o = res["operations"][0]
    assert o["kind"] == "edge" and o["findings"] == [] and o["apply_plan"] is None
    assert o["toolwiz"]["recommended"] is None


def test_addin_labels_probe_chamfer_engrave_deburr_and_unknown_without_claiming_roughing():
    a = load_addin()
    from ToolWizFusionAddin import twlogic
    cases = {"probe": a.STRATEGY_PROBE, "chamfer2d": a.STRATEGY_CHAMFER, "deburr": a.STRATEGY_CHAMFER, "engrave": a.STRATEGY_ENGRAVE,
             "some_future_strategy": a.STRATEGY_UNKNOWN}
    for strat, label in cases.items():
        got = a.infer_strategy_for_op(_op(strat), {"kind": "flat_end_mill"})
        assert got == label, (strat, got)
        assert twlogic.is_roughing_strategy(got, "op") is False
        assert a.dialog_strategy(got) == "Finishing"            # the dropdown has no such item
    assert a.infer_strategy_for_op(_op("adaptive"), {"kind": "flat_end_mill"}) == "Adaptive Roughing"
    assert a.infer_strategy_for_op(_op("contour2d"), {"kind": "probe"}) == a.STRATEGY_PROBE      # a probe tool is never a cut


def test_a_drill_described_as_for_a_form_tap_is_a_drill():
    a = load_addin()
    assert a.format_cutter_type("drill", "1.45mm carbide drill for M1.6 form tap") == "Twist Drill"
    assert a.format_cutter_type("tap right hand", "M1.6 form tap") == "Form Tap"
    assert a.format_cutter_type("", "M3 spiral tap") == "Tap"                    # no type: the description is the hint
    tool = {"type": "drill", "unit": "millimeters", "description": "1.45mm carbide drill for M1.6 form tap",
            "post-process": {"number": 7}, "geometry": {"DC": 1.45, "NOF": 2, "LCF": 8.0, "SFDM": 3.0, "LB": 12.0, "TA": 118.0}}
    op = _op("drill", "Drill4 (5)", tool)
    geo, summary, _ = a.get_op_tool_info(op)
    assert geo["isHoleTool"] and not geo["isTap"] and "Tap" not in summary
    assert a.infer_strategy_for_op(op, geo) == "Drilling"


def test_find_cam_operation_does_not_fall_back_to_the_first_operation():
    a = load_addin()
    ops = [("S", "S > Probe WCS1", SimpleNamespace(name="Probe WCS1")), ("S", "S > Drill4", SimpleNamespace(name="Drill4"))]
    a._iter_all_cam_operations = lambda: iter(ops)
    assert a._find_cam_operation("") == (None, None, None) and a._find_cam_operation(None) == (None, None, None)
    assert a._find_cam_operation("Drill4")[1] == "S > Drill4"


def test_version_reports_local_changes():
    info = toolwiz_app.build_info()
    assert isinstance(info["dirty"], bool) and (("with local changes" in info["label"]) == info["dirty"])
