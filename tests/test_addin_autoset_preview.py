"""Speeds & Feeds preview (docs/FIELD_TEST_LOG.md entry 20, owner 2026-11-15): before anything is written the command shows
every value it will change, old -> new, and asks OK / Cancel. Cancel leaves the operation, the tool and its presets untouched."""
from types import SimpleNamespace
from unittest.mock import MagicMock, patch

from test_addin_common import load_addin, param, ParamsByName

GEO = {"diameter": 0.0625, "flutes": 4, "fluteLength": 0.25, "shankDiameter": 0.125, "cornerRadius": 0.03125, "stickout": 0.5,
       "geometry": "Ball", "desc": "1/16 ball", "number": 6, "kind": "ball", "runout_in": 0.0001, "runout_source": "tool",
       "is_carbide": True, "raw_json": "{}"}
CALC = {"success": True, "rpm": 16000, "feed": 33.14, "doc": 0.25, "woc": 0.00492, "sfm": 262, "ipt": 0.00052,
        "ramp_feed": 36.22, "plunge_feed": 6.59, "ramp_angle": 2.97,
        "engagement_source": "user", "engagement_doc": 0.25, "engagement_woc": 0.00492}


def _op():
    """Scallop4 (6) as the shop PC saw it: rpm and feeds already at ToolWiz's values, a 2 deg ramp, preset 'Aluminum - Roughing'."""
    params = ParamsByName({
        "tool_spindleSpeed": param("16000 rpm", 16000.0),
        "tool_feedCutting": param("33.14 in/min", 33.14 * 25.4),
        "tool_feedRamp": param("36.22 in/min", 36.22 * 25.4),
        "tool_feedPlunge": param("tool_feedCutting / 5", 6.59 * 25.4),
        "tool_feedTransition": param("30 in/min", 30 * 25.4),
        "tool_rampAngle": param("2.", 2.0),
    })
    return SimpleNamespace(name="Scallop4 (6)", strategy="scallop", parameters=params, toolPreset=SimpleNamespace(name="Aluminum - Roughing"))


def _run(a, op, answer):
    if a.ui is None:
        a.ui = MagicMock()
    a.ui.messageBox.return_value = answer
    a._model_cache["model"] = "v2"
    with patch.object(a, "get_op_tool_info", return_value=(GEO, "s", [])), \
         patch.object(a, "_inspect_op_feature_geometry", return_value=None), \
         patch.object(a, "get_cam_document_units", return_value="in"), \
         patch.object(a, "_http_json", return_value=dict(CALC)), \
         patch.object(a, "get_op_cut_params", return_value=(16000.0, 33.14, 0.25, 0.00492)), \
         patch.object(a, "_log_custom_diff"), patch.object(a, "_log_op_motion_params"), patch.object(a, "_log_speed_sources"), \
         patch.object(a, "_log_preset_use_flags"), patch.object(a, "_doc_tool_count", return_value=1), \
         patch.object(a, "check_replace_safety", return_value=True) as safety, \
         patch.object(a, "_upsert_preset_in_place", return_value=(SimpleNamespace(name="x"), False)) as upsert, \
         patch.object(a, "_assign_tool_preset") as link, patch.object(a, "apply_param", return_value=True) as ap, \
         patch.object(a, "_set_expression") as setx, patch.object(a, "_regenerate_toolpath") as regen, \
         patch.object(a, "_refresh_operations_from_preset", return_value=False), \
         patch.object(a, "op_supports_stock_to_leave", return_value=False), patch.object(a, "_finish_active_command", return_value=""):
        done = a.run_autoset(op, "Op1 > Scallop4 (6)", "Aluminum - Wrought (6061)", "7075 (T6, T651)", "Finishing", 60, None, "HP", "AlTiN")
    return done, dict(safety=safety, upsert=upsert, link=link, ap=ap, setx=setx, regen=regen)


def test_preview_lists_old_and_new_before_anything_is_written_and_cancel_writes_nothing():
    a = load_addin()
    op = _op()
    before = {n: p.expression for n, p in op.parameters.mapping.items()}
    done, m = _run(a, op, a.adsk.core.DialogResults.DialogCancel)
    assert done is False
    for name in ("safety", "upsert", "link", "ap", "setx", "regen"):
        m[name].assert_not_called()
    assert {n: p.expression for n, p in op.parameters.mapping.items()} == before and op.toolPreset.name == "Aluminum - Roughing"
    assert a.ui.messageBox.call_count == 1
    args = a.ui.messageBox.call_args[0]
    text = args[0]
    assert a.adsk.core.MessageBoxButtonTypes.OKCancelButtonType in args
    assert text.split("\n")[0].startswith("QUESTION: apply these ToolWiz values to Op1 > Scallop4 (6)?")
    assert "16000 rpm, 33.14 in/min" in text
    will, already = text.split("Already at ToolWiz's value")
    assert "Tool preset linked to the operation: Aluminum - Roughing -> 7075 (T6, T651) - Finishing" in will
    assert "tool_rampAngle: 2.00 deg -> 2.97 deg" in will            # the ramp angle change is shown, not silent
    assert "tool_feedPlunge: 6.59 in/min (replaces a formula) -> 6.59 in/min" in will or "tool_feedPlunge" in already
    assert "tool_feedTransition: 30.00 in/min -> 49.71 in/min" in will
    assert "tool_feedRamp: 36.22 in/min -> 33.14 in/min" in will        # a ramp is never fed faster than the cut (2026-11-15)
    for unchanged in ("tool_spindleSpeed", "tool_feedCutting", "Stepdown", "Stepover / optimal load"):
        assert unchanged in already and f"  {unchanged}:" not in will


def test_any_answer_but_ok_writes_nothing():
    a = load_addin()
    for answer in (a.adsk.core.DialogResults.DialogNo, None, MagicMock()):
        a.ui = MagicMock()
        done, m = _run(a, _op(), answer)
        assert done is False
        m["upsert"].assert_not_called()
        m["ap"].assert_not_called()


def test_ok_goes_on_to_write_the_preset():
    a = load_addin()
    done, m = _run(a, _op(), a.adsk.core.DialogResults.DialogOK)
    assert done is True
    m["upsert"].assert_called_once()
    speed_values = dict(m["upsert"].call_args[0][3])
    assert speed_values["tool_feedCutting"] == "33.14 in/min" and speed_values["tool_rampAngle"] == "2.97"
    m["regen"].assert_called_once()
    assert a.ui.messageBox.call_args_list[0][0][0].startswith("QUESTION: apply these ToolWiz values")


def test_passes_tab_dry_run_reports_writes_and_writes_nothing():
    a = load_addin()
    params = ParamsByName({"doMultipleDepths": param("false"), "maximumStepdown": param("0.2 in"), "useEvenStepdowns": param("false"),
                           "doMultiplePasses": param("false"), "maximumStepover": param("0.05 in"),
                           "minimumRoughingStepover": param("0.1 * maximumStepover"), "maximumRoughingSteps": param("1")})
    params.mapping["maximumStepdown"].isEnabled = False
    op = SimpleNamespace(parameters=params)
    before = {n: (p.expression, p.isEnabled) for n, p in params.mapping.items()}
    plan = []
    with patch.object(a, "apply_param") as ap, patch.object(a, "_set_expression") as setx:
        a.apply_passes_tab_params(op, "Roughing", 0.1, 0.02, calc_result={}, geo_payload={"diameter": 0.25}, plan=plan)
        ap.assert_not_called()
        setx.assert_not_called()
    assert {n: (p.expression, p.isEnabled) for n, p in params.mapping.items()} == before
    names = [n for n, _, _ in plan]
    assert "doMultipleDepths" in names and "doMultiplePasses" in names and ("doMultipleDepths", "false", "true") in plan


def test_preview_text_with_nothing_to_change():
    a = load_addin()
    text = a.twlogic.format_autoset_preview("S > Op", "ToolWiz result: 16000 rpm.", [{"name": "tool_spindleSpeed", "old": "16000 rpm", "new": "16000 rpm", "same": True}])
    assert text.startswith("QUESTION:") and "Nothing on this operation changes" in text and "tool_spindleSpeed" in text


# ---- chamfer mills: the web calculator's "Chamfering" (owner, 2026-11-15) -------------------------------------------

CH_GEO = {"diameter": 0.25, "flutes": 4, "fluteLength": 0.25, "shankDiameter": 0.25, "cornerRadius": 0.0, "stickout": 1.0,
          "geometry": "Chamfer Mill", "desc": "Chamfer 4fl 90deg altin", "number": 19, "kind": "chamfer_mill", "type": "chamfer mill",
          "tool_type": "chamfer mill", "is_carbide": True,
          "raw_json": '{"type": "chamfer mill", "unit": "inches", "description": "Chamfer 4fl 90deg altin", '
                      '"geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.25, "SFDM": 0.25, "LB": 1.0, "TA": 45}}'}


def test_dialog_starts_a_chamfer_mill_on_chamfering_and_the_server_gives_the_web_numbers():
    import app as toolwiz_app
    from pipeline import CutRequest, run_cut
    a = load_addin()
    a.read_cycle_type = lambda op: ("", "")
    for strategy in ("trace", "chamfer2d", "contour2d"):
        label = a.infer_strategy_for_op(SimpleNamespace(strategy=strategy, name="Trace1 (2)", parameters=None), CH_GEO)
        assert label == "Chamfering" and a.dialog_strategy(label) == "Chamfering"
    payload = a.build_calc_payload(CH_GEO, "Aluminum - Wrought (6061)", "7075-T6", "Chamfering", 60, "HP", "AlTiN", runout_in=0.0002, model="v2")
    assert payload["operation"] == "Chamfering" and payload["geometry"] == "Chamfer Mill"
    assert payload["tool"] == "Carbide Endmill"          # never the HP grade for a chamfer mill, whatever the dropdown says
    res = toolwiz_app.app.test_client().post("/api/calculate_for_fusion", json=payload, headers={"X-ToolWiz-Client": "unit-test"}).get_json()
    web = run_cut(toolwiz_app.physics, CutRequest(family="Aluminum - Wrought (6061)", alloy="7075-T6", operation="Chamfering", coating="AlTiN",
                                                  apply_coating=True, geometry="V-Bit", diameter=0.25, flutes=4, flute_length=0.25,
                                                  shank_diameter=0.25, stickout=1.0, aggressiveness=0.6,
                                                  max_rpm=toolwiz_app.active_machine().get("max_rpm", 16000), max_hp=10, runout=0.0002, model="v2"))
    assert res["success"] and abs(res["rpm"] - web.rpm) <= 1 and abs(res["feed"] - web.feed_ipm) <= 0.02 * web.feed_ipm


def test_chamfering_writes_speed_and_feeds_only():
    a = load_addin()
    a.ui = MagicMock()
    a.ui.messageBox.return_value = a.adsk.core.DialogResults.DialogOK
    op = SimpleNamespace(name="Trace1 (2)", strategy="trace", toolPreset=SimpleNamespace(name="old"), parameters=ParamsByName({
        "tool_spindleSpeed": param("16000 rpm", 16000.0), "tool_feedCutting": param("87.36 in/min", 87.36 * 25.4),
        "tool_feedPlunge": param("25.97 in/min", 25.97 * 25.4), "tool_rampAngle": param("2.", 2.0), "maximumStepdown": param("0.05 in", 0.127)}))
    calc = {"success": True, "rpm": 10171, "feed": 120.77, "doc": 0.0375, "woc": 0.0375, "sfm": 665, "ipt": 0.00297,
            "ramp_feed": 64.69, "plunge_feed": 43.12, "ramp_angle": 5.0, "engagement_source": "recommended"}
    with patch.object(a, "get_op_tool_info", return_value=(CH_GEO, "s", [])), patch.object(a, "_inspect_op_feature_geometry", return_value=None), \
         patch.object(a, "get_cam_document_units", return_value="in"), patch.object(a, "_http_json", return_value=calc) as http, \
         patch.object(a, "get_op_cut_params", return_value=(10171.0, 120.77, 0.05, 0.0)), patch.object(a, "_log_custom_diff"), \
         patch.object(a, "_log_op_motion_params"), patch.object(a, "_log_speed_sources"), patch.object(a, "_log_preset_use_flags"), \
         patch.object(a, "_doc_tool_count", return_value=1), patch.object(a, "check_replace_safety", return_value=True), \
         patch.object(a, "_upsert_preset_in_place", return_value=(SimpleNamespace(name="x"), False)) as upsert, \
         patch.object(a, "_assign_tool_preset"), patch.object(a, "apply_param", return_value=True) as ap, \
         patch.object(a, "apply_passes_tab_params") as passes, patch.object(a, "apply_fine_stepdown_floor") as fine, \
         patch.object(a, "_regenerate_toolpath"), patch.object(a, "_refresh_operations_from_preset", return_value=False), \
         patch.object(a, "_finish_active_command", return_value=""):
        done = a.run_autoset(op, "Op1 > Trace1 (2)", "Aluminum - Wrought (6061)", "7075-T6", "Chamfering", 60, None, "HP", "AlTiN")
    assert done is True and http.call_args[0][1]["operation"] == "Chamfering"
    names = [n for n, _ in upsert.call_args[0][3]]
    assert "tool_rampAngle" not in names and {"tool_spindleSpeed", "tool_feedCutting", "tool_feedPlunge"} <= set(names)
    assert upsert.call_args.kwargs == {"doc_in": None, "woc_in": None}
    passes.assert_not_called()
    fine.assert_not_called()
    assert not [c for c in ap.call_args_list if c[0][1] in ("maximumStepdown", "stepover", "rampAngle")]
    preview = a.ui.messageBox.call_args_list[0][0][0]
    assert "tool_spindleSpeed: 16000 rpm -> 10171 rpm" in preview and "Stepdown" not in preview and "tool_rampAngle" not in preview
