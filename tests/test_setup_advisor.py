"""Setup advisor (setup_advisor, routes_setup_advisor), the apply bridge action, the MCP tools and the guarded LLM paths.

The setup snapshot is built from the owner's real tools in data/shop_library/ (1/16" end mill, 1/8" end mill, 8 mm x 1 mm slot
mill, 3/8" bull nose). Titanium Ti-6Al-4V, aggressiveness 0.5, v2 model. The LLM is never called: it is mocked."""
import copy
import json
import os
import sys

import pytest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, ROOT)

import ai_machinist  # noqa: E402
import app as toolwiz_app  # noqa: E402
import fusion_bridge  # noqa: E402
import mcp_server  # noqa: E402
import setup_advisor as sa  # noqa: E402
from pipeline import CutRequest, run_cut  # noqa: E402
from toolwiz_common import numeric_guard  # noqa: E402

HDR = {"X-ToolWiz-Client": "unit-test"}
FAMILY, ALLOY = "Titanium Alloy", "Ti-6Al-4V (Grade 5, Annealed)"
LIB = os.path.join(ROOT, "data", "shop_library", "Offworldgear_TI_Steel1_Updated4_20261019_125408_v6.json")


def _lib_tool(pred):
    with open(LIB, encoding="utf-8") as fh:
        tools = json.load(fh)["tools"]
    return copy.deepcopy(next(t for t in tools if pred(t)))


def make_setup():
    """Four operations on the owner's tools: adaptive (1/16"), 2D contour slot (1/8"), T-slot (8 x 1 mm slot mill), finishing (3/8")."""
    t16 = _lib_tool(lambda t: t.get("description", "").startswith('1/16" Dia. Carbide'))
    t18 = _lib_tool(lambda t: t.get("description", "").startswith('1/8" 4FL HI PERF'))
    slot = _lib_tool(lambda t: t.get("type") == "slot mill" and "8mm x 1mm" in t.get("description", ""))
    t38 = _lib_tool(lambda t: t.get("description", "").startswith('3/8" Bullnose .06R'))
    return {"document": "Ti bracket", "ops": [
        {"setup": "Setup1", "name": "Adaptive pocket", "path": "Setup1 > Adaptive pocket", "strategy": "adaptive2d", "tool": t16,
         "params": {"tool_spindleSpeed": "12000 rpm", "tool_feedCutting": "30 in/min", "maximumStepdown": "0.1875 in",
                    "optimalLoad": "0.02 in", "stockToLeave": "0 in", "verticalStockToLeave": "0 in"},
         "geometry": {"channel_width_in": 0.1, "depth_in": 0.1875, "toolpath_length_in": 40}},
        {"setup": "Setup1", "name": "Slot contour", "path": "Setup1 > Slot contour", "strategy": "contour2d", "tool": t18,
         "params": {"tool_spindleSpeed": "8000 rpm", "tool_feedCutting": "20 in/min", "maximumStepdown": "0.25 in"},
         "geometry": {"slot_width_in": 0.25, "depth_in": 0.25, "toolpath_length_in": 8}},
        {"setup": "Setup1", "name": "T-slot", "path": "Setup1 > T-slot", "strategy": "contour2d", "tool": slot,
         "params": {"tool_spindleSpeed": "3000 rpm", "tool_feedCutting": "4 in/min", "maximumStepdown": "2 mm", "optimalLoad": "3 mm"},
         "geometry": {"slot_height_mm": 1, "radial_depth_mm": 3, "toolpath_length_mm": 40}},
        {"setup": "Setup1", "name": "Finish walls", "path": "Setup1 > Finish walls", "strategy": "contour2d", "tool": t38,
         "params": {"tool_spindleSpeed": "3000 rpm", "tool_feedCutting": "12 in/min", "stockToLeave": "0 in"}},
    ]}


def advise(setup, **kw):
    kw.setdefault("family", FAMILY)
    kw.setdefault("alloy", ALLOY)
    kw.setdefault("physics", toolwiz_app.physics)
    kw.setdefault("machine_profile", toolwiz_app.active_machine())
    return sa.advise(setup, **kw)


@pytest.fixture(scope="module")
def result():
    return advise(make_setup())


def op(result, name):
    return next(o for o in result["operations"] if o["name"] == name)


def codes(o, sev=None):
    return {f["code"] for f in o["findings"] if sev is None or f["severity"] == sev}


@pytest.fixture(autouse=True)
def _clean():
    fusion_bridge.reset_bridge_state()
    yield
    fusion_bridge.reset_bridge_state()


# ---------------------------------------------------------------------------------------------- deterministic findings
def test_result_shape_and_summary(result):
    assert set(result) >= {"operations", "setup_findings", "strategy_suggestions", "narrative", "narrative_check", "summary"}
    assert result["narrative"] is None and result["narrative_check"]["ok"] is True
    for o in result["operations"]:
        assert set(o) >= {"op_id", "name", "strategy", "current", "toolwiz", "findings"}
        for f in o["findings"]:
            assert f["severity"] in ("STOP", "CAUTION", "INFO") and f["title"] and f["detail"] and f["recommendation"]
        sev = [f["severity"] for f in o["findings"]]
        assert sev == sorted(sev, key=["STOP", "CAUTION", "INFO"].index)          # STOP first
    allf = [f for o in result["operations"] for f in o["findings"]] + result["setup_findings"]
    s = result["summary"]
    assert (s["stop"], s["caution"], s["info"]) == tuple(sum(1 for f in allf if f["severity"] == k) for k in ("STOP", "CAUTION", "INFO"))
    assert s["verdict"] == "STOP"
    json.dumps(result)                                                              # serialisable


def test_adaptive_micro_tool_in_titanium(result):
    o = op(result, "Adaptive pocket")
    assert o["kind"] == "adaptive"
    assert "chip_load_high" in codes(o, "STOP")                                     # 0.000625 in/tooth vs ToolWiz's
    assert {"stock_radial_low", "stock_axial_low", "stepover_high", "reduced_flutes"} <= codes(o, "CAUTION")
    assert "holder_type" in codes(o, "CAUTION")                                     # ER16 collet vs an ultra-class requirement
    rec, usr = o["toolwiz"]["recommended"], o["toolwiz"]["at_current_engagement"]
    assert rec["engagement_source"] == "recommended" and usr["engagement_source"] == "user"
    # the ToolWiz numbers are the pipeline's: reproduce the user-engagement run independently
    mach = toolwiz_app.active_machine()
    geo = {"DC": 0.0625, "NOF": 4, "LCF": 0.188, "SFDM": 0.125, "LB": 0.3937007874015748}
    res = run_cut(toolwiz_app.physics, CutRequest(
        family=FAMILY, alloy=ALLOY, operation="Adaptive Roughing", coating="TiAlN", diameter=0.0625, flutes=4, flute_length=0.188,
        shank_diameter=0.125, stickout=0.3937007874015748, aggressiveness=0.5, max_rpm=mach["max_rpm"], max_hp=mach["max_hp"],
        runout=0.0002, cut_depth=0.1875, cut_width=0.02, fusion_tool={"type": "flat end mill", "unit": "inches", "geometry": geo},
        model="v2", machine_profile=mach))
    assert usr["rpm"] == round(res.rpm) and usr["feed_ipm"] == pytest.approx(res.feed_ipm, abs=5e-4)
    # every number in a finding is traceable: the STOP text quotes the ToolWiz chip load
    f = next(f for f in o["findings"] if f["code"] == "chip_load_high")
    assert f["numbers"]["toolwiz_chip_load_ipt"] == usr["chip_load_ipt"]
    assert f["numbers"]["ratio_x"] > 2.0


def test_slot_contour_findings_and_strategy_suggestion(result):
    o = op(result, "Slot contour")
    assert o["kind"] == "slot"
    assert "chip_load_high" in codes(o, "STOP")
    assert "stepdown_high" in codes(o, "CAUTION")
    sug = next(s for s in result["strategy_suggestions"] if s["name"] == "Slot contour")
    assert sug["feature"]["type"] == "slot" and sug["feature"]["width"] == pytest.approx(0.25)
    assert sug["recommended"] and sug["recommended_option"]["cycle_time_min"] > 0
    names = [x["name"] for x in sug["options"]]
    assert sug["recommended"] in names and len(names) >= 3
    strategies = {x["strategy"] for x in sug["options"]}
    assert {"adaptive", "contour_slot_side_passes"} <= strategies
    assert sug["current_option"]["strategy"] == "contour_slot_side_passes"
    if not sug["same_as_current"] and sug["time_saved_min"] is not None:
        assert sug["time_saved_min"] == pytest.approx(
            sug["current_option"]["cycle_time_min"] - sug["recommended_option"]["cycle_time_min"], abs=1e-3)


def test_tslot_stepdown_beyond_kerf_is_stop(result):
    o = op(result, "T-slot")
    assert o["kind"] == "tslot"
    assert "stepdown_over_kerf" in codes(o, "STOP")
    tw = o["toolwiz"]["tslot"]
    assert tw["kerf_in"] == pytest.approx(1 / 25.4, rel=1e-3)
    assert o["current"]["stepdown_in"] == pytest.approx(2 / 25.4, rel=1e-6)           # "2 mm" parsed to inches
    assert "tslot_provisional" in codes(o, "CAUTION")                                  # neck/reach/tooth form are assumed
    sug = next(s for s in result["strategy_suggestions"] if s["name"] == "T-slot")
    assert sug["feature"]["type"] == "tslot"
    assert any("klot_" in x["name"] for x in sug["options"])                           # the owner's shop cutters are compared
    assert any("(this operation)" in x["name"] for x in sug["options"])


def test_finishing_after_roughing_with_zero_stock(result):
    sf = [f for f in result["setup_findings"] if "no stock for the finishing pass" in f["title"]]
    assert sf and sf[0]["severity"] == "CAUTION" and "Finish walls" in sf[0]["title"]
    fin = op(result, "Finish walls")
    assert fin["kind"] == "finish"


def test_apply_plan_values_come_from_toolwiz(result):
    o = op(result, "Adaptive pocket")
    plan = o["apply_plan"]["recommended"]
    rec = o["toolwiz"]["recommended"]
    assert plan["tool_spindleSpeed"] == f"{rec['rpm']} rpm"
    assert plan["optimalLoad"] == f"{rec['ae_in']:.5f} in"
    assert set(plan) <= set(sa.PARAM_KINDS) and set(sa.PARAM_KINDS) == set(fusion_bridge.APPLY_ALLOWED_PARAMS)
    assert "keep_engagement" in o["apply_plan"]


def test_rpm_over_machine_max_is_stop():
    s = make_setup()
    s["ops"] = [s["ops"][1]]
    s["ops"][0]["params"]["tool_spindleSpeed"] = "30000 rpm"
    r = advise(s, strategies=False)
    assert "rpm_over_machine" in codes(r["operations"][0], "STOP")


def test_recommended_values_give_no_stop_or_speed_findings():
    """An op set exactly to ToolWiz's own numbers must not be flagged on speed, feed, chip load or engagement."""
    s = make_setup()
    s["ops"] = [s["ops"][1]]
    first = advise(s, strategies=False)["operations"][0]
    rec = first["toolwiz"]["recommended"]
    s["ops"][0]["params"] = {"tool_spindleSpeed": f"{rec['rpm']} rpm", "tool_feedCutting": f"{rec['feed_ipm']} in/min",
                             "maximumStepdown": f"{rec['ap_in']} in"}
    o = advise(s, strategies=False)["operations"][0]
    assert not codes(o, "STOP")
    assert not (codes(o) & {"chip_load_off", "rpm_off", "feed_off", "stepdown_high", "chip_load_high"})


def test_missing_fields_are_tolerated():
    s = {"ops": [
        {"name": "Mystery"},                                                           # nothing but a name
        {"name": "No tool", "strategy": "adaptive", "params": {"tool_spindleSpeed": "9000 rpm"}},
        {"name": "Drill", "strategy": "drill", "tool": {"type": "drill", "diameter_in": 0.1875}},
        {"name": "Bare end mill", "strategy": "pocket2d", "tool": {"diameter_in": 0.25}},     # only a diameter
        {"name": "Fusion style", "strategy": "adaptive", "tool": {"diameter": 0.25, "flutes": 3, "stickout_in": 1.0},
         "tool_spindleSpeed": {"expr": "8000", "value": 8000}, "tool_feedCutting": {"expr": "40 in/min"}},
    ]}
    r = advise(s, strategies=False)
    assert [o["name"] for o in r["operations"]] == ["Mystery", "No tool", "Drill", "Bare end mill", "Fusion style"]
    assert "no_tool" in codes(r["operations"][0])
    assert "not_analysed" in codes(r["operations"][2])
    bare = r["operations"][3]
    assert bare["toolwiz"]["recommended"]["feasible"] is not None and any("assumed" in n for n in bare["notes"])
    assert r["operations"][4]["current"]["rpm"] == 8000.0 and r["operations"][4]["current"]["feed_ipm"] == 40.0


def test_ops_as_path_keyed_snapshot_dict():
    snap = make_setup()
    snap["ops"] = {o["path"]: {k: v for k, v in o.items() if k != "path"} for o in snap["ops"]}
    r = advise(snap, strategies=False)
    assert [o["op_id"] for o in r["operations"]][0] == "Setup1 > Adaptive pocket"
    assert r["operations"][0]["setup"] == "Setup1"


def test_bad_input():
    with pytest.raises(ValueError):
        sa.advise({"ops": []}, physics=toolwiz_app.physics)                                 # no family
    with pytest.raises(ValueError):
        advise({"ops": []}, aggressiveness=-0.1)
    with pytest.raises(ValueError):
        sa.normalize_setup("not a dict")
    assert advise({"ops": []})["summary"]["operations"] == 0


def test_parse_quantity_units():
    assert sa.parse_quantity("6 mm", "len") == pytest.approx(6 / 25.4)
    assert sa.parse_quantity("0.25 in", "len") == 0.25
    assert sa.parse_quantity("3000 mm/min", "feed") == pytest.approx(3000 / 25.4)
    assert sa.parse_quantity({"expr": "108.14in/min", "value": 4.5}, "feed") == pytest.approx(108.14)
    assert sa.parse_quantity("12000 rpm", "rpm") == 12000.0
    assert sa.parse_quantity("banana", "len") is None and sa.parse_quantity(None, "len") is None
    assert sa.parse_quantity("5 furlongs", "len") is None


# ---------------------------------------------------------------------------------------------------------- apply
def test_validate_apply_accepts_only_toolwiz_values(result):
    sa.set_last(result)
    o = op(result, "Adaptive pocket")
    plan = o["apply_plan"]["recommended"]
    good = sa.validate_apply(o["op_id"], {"tool_spindleSpeed": plan["tool_spindleSpeed"], "optimalLoad": plan["optimalLoad"]})
    assert good["ok"] and set(good["accepted"]) == {"tool_spindleSpeed", "optimalLoad"}
    # the same value written in mm is the same number
    mm = f"{float(plan['optimalLoad'].split()[0]) * 25.4:.4f} mm"
    assert sa.validate_apply(o["op_id"], {"optimalLoad": mm})["ok"]
    # a value ToolWiz did not recommend is rejected, with the ToolWiz value in the message
    bad = sa.validate_apply(o["op_id"], {"tool_spindleSpeed": "20000 rpm"})
    assert not bad["ok"] and "tool_spindleSpeed" in bad["rejected"] and plan["tool_spindleSpeed"] in bad["rejected"]["tool_spindleSpeed"]
    # one bad value rejects the whole request
    mixed = sa.validate_apply(o["op_id"], {"tool_spindleSpeed": plan["tool_spindleSpeed"], "optimalLoad": "0.5 in"})
    assert not mixed["ok"] and list(mixed["rejected"]) == ["optimalLoad"]
    # names outside the allow-list, non-string values, unknown ops
    assert "not on the allow-list" in sa.validate_apply(o["op_id"], {"coolant": "on"})["rejected"]["coolant"]
    assert not sa.validate_apply(o["op_id"], {"tool_spindleSpeed": 12000})["ok"]
    assert "not in the last advisor result" in sa.validate_apply("nope", {"tool_spindleSpeed": "1 rpm"})["error"]
    # keep_engagement speeds are ToolWiz values too
    keep = o["apply_plan"]["keep_engagement"]
    assert sa.validate_apply(o["op_id"], {"tool_feedCutting": keep["tool_feedCutting"]})["ok"]


def test_validate_apply_without_result():
    sa.clear_last()
    assert "run POST /api/setup_advisor first" in sa.validate_apply("x", {"tool_spindleSpeed": "1 rpm"})["error"]


def test_bridge_action_allowlist_and_queue():
    assert "apply_operation_parameters" in fusion_bridge.ALLOWED_ACTIONS
    bad = fusion_bridge.execute_bridge_action("apply_operation_parameters", {"op_id": "a", "params": {"coolant": "on"}})
    assert not bad["success"] and "may not be written" in bad["error"]
    assert not fusion_bridge.execute_bridge_action("apply_operation_parameters", {"params": {"tool_spindleSpeed": "1 rpm"}})["success"]
    queued = fusion_bridge.submit_command("apply_operation_parameters", {"op_id": "S > O", "params": {"tool_spindleSpeed": "9000 rpm"}, "reason": "t"})
    assert queued["queued"] and fusion_bridge.pop_next_command()["action"] == "apply_operation_parameters"
    assert fusion_bridge.peek_result(queued["request_id"]) is None
    assert fusion_bridge.record_command_result(queued["request_id"], {"ok": True, "applied": {"tool_spindleSpeed": "9000 rpm"}})
    assert fusion_bridge.peek_result(queued["request_id"])["ok"] is True


# ------------------------------------------------------------------------------------------------------- endpoints
@pytest.fixture()
def client():
    c = toolwiz_app.app.test_client()
    c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "unit-test"
    return c


def test_endpoint_run_last_and_apply(client):
    sa.clear_last()
    assert client.get("/api/setup_advisor/last").status_code == 404
    body = {"setup": make_setup(), "family": FAMILY, "alloy": ALLOY, "aggressiveness": 50, "strategies": False, "model": "v2"}
    r = client.post("/api/setup_advisor", json=body)
    assert r.status_code == 200, r.get_json()
    data = r.get_json()
    assert data["summary"]["verdict"] == "STOP" and data["settings"]["aggressiveness"] == 0.5
    assert client.get("/api/setup_advisor/last").get_json()["generated_at"] == data["generated_at"]
    o = next(x for x in data["operations"] if x["name"] == "Adaptive pocket")
    plan = o["apply_plan"]["recommended"]

    calls = []
    fusion_bridge.register_direct_executor(lambda action, params: calls.append((action, params)) or
                                           {"ok": True, "applied": dict(params["params"]), "skipped": {}, "error": None})
    bad = client.post("/api/setup_advisor/apply", json={"op_id": o["op_id"], "params": {"tool_spindleSpeed": "20000 rpm"}})
    assert bad.status_code == 400 and "tool_spindleSpeed" in bad.get_json()["rejected"] and not calls
    ok = client.post("/api/setup_advisor/apply", json={"op_id": o["op_id"], "reason": "advisor",
                                                       "params": {"tool_spindleSpeed": plan["tool_spindleSpeed"], "stockToLeave": plan["stockToLeave"]}})
    assert ok.status_code == 200, ok.get_json()
    assert calls[0][0] == "apply_operation_parameters"
    assert calls[0][1]["op_id"] == o["op_id"] and calls[0][1]["params"]["stockToLeave"] == plan["stockToLeave"]
    assert ok.get_json()["applied"]["tool_spindleSpeed"] == plan["tool_spindleSpeed"]


def test_endpoint_errors(client):
    assert client.post("/api/setup_advisor", json={"setup": {"ops": []}}).status_code == 400          # no family
    assert client.post("/api/setup_advisor", json={"setup": "x", "family": FAMILY}).status_code == 400
    assert client.post("/api/setup_advisor", json={"family": FAMILY}).status_code == 400             # no setup, add-in not connected
    assert client.post("/api/setup_advisor/apply", json={"params": {"tool_spindleSpeed": "1 rpm"}}).status_code == 400
    assert client.post("/api/setup_advisor", json=[1]).status_code == 400
    assert toolwiz_app.app.test_client().post("/api/setup_advisor", json={}).status_code in (400, 403)   # CSRF header required


def test_endpoint_uses_live_bridge_state(client):
    s = make_setup()
    fusion_bridge.update_live_state({"document": "live", "ops": s["ops"][1:2]})
    r = client.post("/api/setup_advisor", json={"from_bridge": True, "family": FAMILY, "alloy": ALLOY, "strategies": False, "model": "v2"})
    assert r.status_code == 200 and r.get_json()["document"] == "live" and len(r.get_json()["operations"]) == 1


# ------------------------------------------------------------------------------------------------------- LLM path
def compliant_text(result):
    o = op(result, "Adaptive pocket")
    rec = o["toolwiz"]["at_current_engagement"]
    return (f"1. Start with the {o['name']} operation: it is a STOP. ToolWiz gives {rec['rpm']} rpm and {rec['feed_ipm']} IPM "
            f"for the engagement as set, with a chip load of {rec['chip_load_ipt']} in/tooth. Use the recommended stock to leave of "
            f"{o['toolwiz']['recommended']['stock_to_leave_radial_in']:.4f} in on the same tool.")


def test_llm_compliant_narrative_is_accepted(result):
    seen = []

    def llm(system, prompt):
        seen.append((system, prompt))
        return compliant_text(result)
    text, check, note = sa.narrate(result, llm=llm)
    assert text == compliant_text(result) and check["ok"] and check["attempts"] == 1 and note is None
    system, prompt = seen[0]
    assert "never produce" in system and "copied" in system
    assert json.dumps(sa.llm_view(result), indent=1) in prompt                       # the prompt is built only from the result JSON


def test_llm_fabricated_number_is_rejected_after_one_stricter_retry(result):
    prompts = []

    def llm(system, prompt):
        prompts.append(prompt)
        return compliant_text(result) + " Then run it at 0.003 IPT for a longer tool life."
    text, check, note = sa.narrate(result, llm=llm)
    assert text is None and check["ok"] is False and any("0.003" in n for n in check["rejected_numbers"])
    assert len(prompts) == 2 and "Your previous answer contained numbers" in prompts[1] and "0.003" in prompts[1]
    assert "rejected" in note


def test_llm_retry_with_stricter_prompt_can_succeed(result):
    replies = iter([compliant_text(result) + " Use 0.003 IPT.", compliant_text(result)])
    text, check, note = sa.narrate(result, llm=lambda s, p: next(replies))
    assert text and check["ok"] and check["attempts"] == 2


def test_advise_with_llm_returns_deterministic_findings_either_way():
    base = advise(make_setup(), strategies=False)
    good = advise(make_setup(), strategies=False, use_llm=True, llm=lambda s, p: compliant_text(base))
    assert good["narrative"] == compliant_text(base) and good["narrative_check"]["ok"]
    bad = advise(make_setup(), strategies=False, use_llm=True, llm=lambda s, p: "Run at 0.003 IPT and 99999 rpm.")
    assert bad["narrative"] is None and bad["narrative_check"]["ok"] is False
    assert {"0.003 IPT", "99999 rpm"} <= set(bad["narrative_check"]["rejected_numbers"])
    assert bad["summary"] == good["summary"] and [o["findings"] for o in bad["operations"]] == [o["findings"] for o in good["operations"]]


def test_no_api_key_gives_null_narrative_with_note(monkeypatch):
    monkeypatch.delenv("GEMINI_API_KEY", raising=False)
    monkeypatch.delenv("GOOGLE_API_KEY", raising=False)
    r = advise(make_setup(), strategies=False, use_llm=True)
    assert r["narrative"] is None and "API key" in r["narrative_note"]
    assert r["summary"]["verdict"] == "STOP"


def test_llm_exception_does_not_break_the_advisor(result):
    def boom(s, p):
        raise RuntimeError("network down")
    text, check, note = sa.narrate(result, llm=boom)
    assert text is None and "network down" in note


# ------------------------------------------------------------------------------------------- chat (ai_machinist)
CTX = {"material": "Ti-6Al-4V", "materialFamily": "Titanium Alloy", "diameter": 0.25, "flutes": 4, "operation": "Roughing",
       "rpm": 4114, "feedrate": 18.3, "sfm": 269.3, "ipt": 0.0011}


def _chat(monkeypatch, reply):
    monkeypatch.setattr(ai_machinist, "_gemini_generate", lambda *a, **k: {"text": reply, "model": "mock", "error": None, "auth_error": False})
    return ai_machinist.query_ai_machinist("What speed and feed should I run?", context=dict(CTX), api_key="test-key")


def test_chat_reply_with_toolwiz_numbers_is_shown(monkeypatch):
    r = _chat(monkeypatch, "ToolWiz gives 4114 rpm and 18.3 IPM; that is 269.3 SFM.")
    assert r["mode"] == "gemini_live" and r["numeric_check"]["ok"]


def test_chat_reply_with_invented_number_falls_back_to_toolwiz_numbers(monkeypatch):
    r = _chat(monkeypatch, "Run 0.003 IPT at 9000 rpm.")
    assert r["mode"] == "guard_fallback" and "0.003" not in r["reply"].split("withheld")[0]
    assert "4114" in r["reply"] and "withheld" in r["reply"] and not r["numeric_check"]["ok"]


def test_ask_machinist_is_guarded(monkeypatch):
    monkeypatch.setattr(ai_machinist, "generate_text", lambda *a, **k: {"success": True, "text": "Use 7777 rpm.", "model": "m", "error": None})
    r = ai_machinist.ask_machinist("which rpm?", context=dict(CTX), api_key="k")
    assert not r["success"] and "7777 rpm" in r["rejected_numbers"]
    monkeypatch.setattr(ai_machinist, "generate_text", lambda *a, **k: {"success": True, "text": "Use 4114 rpm.", "model": "m", "error": None})
    assert ai_machinist.ask_machinist("which rpm?", context=dict(CTX), api_key="k")["answer"] == "Use 4114 rpm."
    monkeypatch.delenv("GEMINI_API_KEY", raising=False)
    monkeypatch.delenv("GOOGLE_API_KEY", raising=False)
    assert not ai_machinist.ask_machinist("x", context={})["success"]


# ----------------------------------------------------------------------------------------------------------- MCP
def rpc(method, params=None, id_=1):
    return mcp_server.handle_mcp_message({"jsonrpc": "2.0", "id": id_, "method": method, "params": params or {}})


def call(name, args):
    r = rpc("tools/call", {"name": name, "arguments": args})
    return json.loads(r["result"]["content"][0]["text"]), r["result"]["isError"]


def test_mcp_instructions_and_tool_list():
    init = rpc("initialize")["result"]
    assert "NEVER invent" in init["instructions"] and "toolwiz_" in init["instructions"]
    tools = {t["name"]: t for t in rpc("tools/list")["result"]["tools"]}
    for name in ("toolwiz_calculate_cut", "toolwiz_strategy_compare", "toolwiz_holder_advice", "toolwiz_tool_advice",
                 "toolwiz_setup_advisor", "toolwiz_library_audit", "toolwiz_master_library_build"):
        assert name in tools
    for t in tools.values():
        assert "never invent" in t["description"] and "toolwiz_" in t["description"], t["name"]
        assert t["inputSchema"]["type"] == "object"


def test_mcp_holder_and_tool_advice():
    h, err = call("toolwiz_holder_advice", {"diameter": 0.0625, "fz_in": 0.0003, "flutes": 4, "runout_in": 0.0002, "rpm": 12000, "operation": "hem"})
    assert not err and h["class"] in ("precision", "ultra") and h["required_tir_in"] > 0
    t, err = call("toolwiz_tool_advice", {"family": FAMILY, "diameter": 0.125, "operation": "side"})
    assert not err and isinstance(t["tools"], list)
    bad, err = call("toolwiz_holder_advice", {"diameter": -1, "fz_in": 0.0003})
    assert err and bad["success"] is False


def test_mcp_strategy_compare():
    d, err = call("toolwiz_strategy_compare", {
        "family": "Aluminum - Wrought (6061)", "alloy": "6061-T6", "aggressiveness": 0.5, "runout": 0.0002, "model": "v2",
        "feature": {"type": "profile_cutout", "depth": 0.25, "length": 12.0, "tabs": {"count": 4, "width": 0.1, "height": 0.04}},
        "candidate_tools": [{"diameter": 0.125, "flutes": 2, "flute_length": 0.375, "shank_diameter": 0.125, "stickout": 0.6}]})
    assert not err and d["recommended"] and d["options"][0]["cycle_time_min"] > 0


def test_mcp_setup_advisor_and_master_library_status():
    d, err = call("toolwiz_setup_advisor", {"setup": make_setup(), "family": FAMILY, "alloy": ALLOY, "aggressiveness": 50, "model": "v2"})
    assert not err and d["summary"]["verdict"] == "STOP" and d["strategy_suggestions"]
    none, err = call("toolwiz_setup_advisor", {"family": FAMILY})                                   # no setup and no add-in
    assert err and "add-in" in none["error"]
    st, err = call("toolwiz_master_library_build", {"action": "status", "job_id": "does-not-exist"})
    assert err and st["success"] is False
    st, err = call("toolwiz_master_library_build", {"action": "status"})
    assert err and "job_id" in st["error"]
    st, err = call("toolwiz_master_library_build", {"action": "explode"})
    assert err


def test_mcp_library_audit_on_shop_library():
    with open(LIB, encoding="utf-8") as fh:
        tools = json.load(fh)["tools"][:3]
    d, err = call("toolwiz_library_audit", {"tools": tools, "aggressiveness": 50})
    assert not err and "summary" in d


def test_mcp_existing_calculate_cut_still_works():
    d, err = call("toolwiz_calculate_cut", {"family": FAMILY, "alloy": ALLOY, "diameter": 0.25, "flutes": 4, "operation": "Roughing"})
    assert not err and d["rpm"] > 0 and d["feed_ipm"] > 0


def test_guard_accepts_numbers_from_the_real_result(result):
    """The guard grounds on the advisor's own numbers: a sentence built from the result passes, with unit conversions."""
    view = sa.llm_view(result)
    rec = op(result, "Slot contour")["toolwiz"]["recommended"]
    ok = f"ToolWiz recommends {rec['rpm']} rpm, {rec['feed_ipm']} IPM, which is {rec['feed_ipm'] * 25.4:.0f} mm/min."
    assert numeric_guard.check_numbers(ok, view)["ok"]
    assert not numeric_guard.check_numbers("ToolWiz recommends 0.003 IPT.", view)["ok"]
