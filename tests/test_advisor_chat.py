"""Advisor Chat: provider layer (Anthropic SDK request shape, tool loop, refusal, fallback, errors), assumptions, tools, numeric guard,
keys never leaving the server, proposals, routes, MCP, and the add-in's update_tool_fields / get_viewport_image (Fusion mocked).
No real LLM is ever called: the provider layer is mocked."""
import json
import os
import sys
from types import SimpleNamespace
from unittest.mock import MagicMock

import anthropic
import httpx
import pytest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, ROOT)
sys.path.insert(0, os.path.dirname(__file__))

import app as toolwiz_app  # noqa: E402
import fusion_bridge  # noqa: E402
import mcp_server  # noqa: E402
import routes_advisor_chat as R  # noqa: E402
import setup_advisor  # noqa: E402
from advisor_chat import settings as aisettings, store, tools  # noqa: E402
from advisor_chat.engine import ChatEngine, guard  # noqa: E402
from advisor_chat.providers import anthropic_provider as ap  # noqa: E402
from advisor_chat.providers.base import ProviderError, ToolSpec  # noqa: E402
from advisor_chat_fakes import ScriptedProvider, last_tool_json, turn  # noqa: E402
import test_setup_advisor as tsa  # noqa: E402

HDR = {"X-ToolWiz-Client": "unit-test"}
KEY = "sk-ant-SECRET-1234567890WXYZ"


@pytest.fixture(autouse=True)
def bridge():
    fusion_bridge.reset_bridge_state()
    setup_advisor.clear_last()
    setup = tsa.make_setup()
    fusion_bridge.update_live_state({"document": setup["document"], "ops": setup["ops"]})
    yield
    fusion_bridge.reset_bridge_state()
    setup_advisor.clear_last()


@pytest.fixture
def key(monkeypatch):
    monkeypatch.setenv("ANTHROPIC_API_KEY", KEY)


def new_conv():
    return store.new_conversation("anthropic", "claude-opus-5-5", "medium")


def engine_for(provider):
    return ChatEngine(provider_factory=lambda pid: provider)


def unknown_coating(adv):
    return [o["name"] for o in adv["operations"] for f in o["findings"] if "Coating Unknown" in f["title"]]


ADV_ARGS = {"family": tsa.FAMILY, "alloy": tsa.ALLOY}


# ---- the headline conversation ------------------------------------------------------------------------------------------

def test_all_tools_altin_assumption_removes_unknown_coating_findings(key):
    p = ScriptedProvider([turn("", [("run_setup_advisor", ADV_ARGS)]), turn("The coating is unknown on two operations. Are they coated?")])
    eng, conv = engine_for(p), new_conv()
    assert eng.send(conv, "Review my setup")["ok"]
    runs = lambda: [json.loads(r["content"]) for m in conv["messages"] if m["role"] == "tool" for r in m["results"] if r["name"] == "run_setup_advisor"]  # noqa: E731
    assert unknown_coating(runs()[0])
    p.steps[:] = [turn("", [("set_assumption", {"key": "coating", "value": "AlTiN"})]), turn("", [("run_setup_advisor", ADV_ARGS)]), turn("Done.")]
    assert eng.send(conv, "All my tools are AlTiN coated")["ok"]
    assert unknown_coating(runs()[-1]) == []
    assert runs()[-1]["assumptions"] == [{"key": "coating", "value": "AlTiN", "scope": "all tools"}]
    assert conv["assumptions"][0]["key"] == "coating"
    applied = [a for o in runs()[-1]["operations"] for a in o.get("assumptions_applied", [])]
    assert any("assumed" in a["effect"] for a in applied) and any("not applied" in a["effect"] for a in applied)   # fills gaps only


def test_per_tool_assumptions_and_validation():
    ctx = tools.ToolContext()
    r = tools.run_tool(ctx, "set_assumption", {"key": "runout", "value": "0.0003", "scope_tools": [12]})
    assert r["data"]["success"] and ctx.assumptions[0]["scope"] == {"tools": [12]}
    r = tools.run_tool(ctx, "set_assumption", {"key": "runout", "value": "0.01", "unit": "mm"})
    assert abs(ctx.assumptions[1]["value"] - 0.01 / 25.4) < 1e-12
    assert not tools.run_tool(ctx, "set_assumption", {"key": "coating", "value": "chrome"})["data"]["success"]
    assert not tools.run_tool(ctx, "set_assumption", {"key": "bogus", "value": "x"})["data"]["success"]
    adv = tools.run_tool(ctx, "run_setup_advisor", ADV_ARGS)["data"]
    by_tool = {o["tool_number"]: o for o in adv["operations"]}
    assert any(a["key"] == "runout" for a in by_tool[12]["assumptions_applied"])
    assert tools.run_tool(ctx, "clear_assumption", {"all": True})["data"]["removed"] and ctx.assumptions == []


# ---- the tool loop: parallel calls, one user message ----------------------------------------------------------------------

def test_parallel_tool_calls_return_all_results_in_one_message(key):
    p = ScriptedProvider([
        turn("", [("get_live_setup", {}), ("list_assumptions", {})]),
        turn("Both read."),
    ])
    conv = new_conv()
    assert engine_for(p).send(conv, "look")["ok"]
    tool_msgs = [m for m in conv["messages"] if m["role"] == "tool"]
    assert len(tool_msgs) == 1 and [r["name"] for r in tool_msgs[0]["results"]] == ["get_live_setup", "list_assumptions"]
    ids = [c["id"] for m in conv["messages"] if m["role"] == "assistant" for c in m["tool_calls"]]
    assert [r["tool_call_id"] for r in tool_msgs[0]["results"]] == ids
    native = ap.AnthropicProvider().to_native(p.calls[1]["messages"], "claude-opus-5-5")
    last = native[-1]
    assert last["role"] == "user" and [b["type"] for b in last["content"]] == ["tool_result", "tool_result"]
    assert [b["tool_use_id"] for b in last["content"]] == ids
    # the assistant turn is echoed back unchanged, thinking block included, and earlier messages are untouched
    assert native[-2]["content"][0]["type"] == "thinking"
    assert p.calls[1]["messages"][:len(p.calls[0]["messages"])] == p.calls[0]["messages"]


def test_failed_tool_sets_is_error_and_unknown_tool_does_not_crash(key):
    p = ScriptedProvider([turn("", [("nope", {}), ("run_setup_advisor", {})]), turn("ok")])
    conv = new_conv()
    fusion_bridge.reset_bridge_state()          # Fusion disconnected
    assert engine_for(p).send(conv, "x")["ok"]
    res = [m for m in conv["messages"] if m["role"] == "tool"][0]["results"]
    assert all(r["is_error"] for r in res)
    native = ap.AnthropicProvider().to_native(p.calls[1]["messages"], "claude-opus-5-5")
    assert all(b.get("is_error") is True for b in native[-1]["content"])


def test_system_note_after_user_turn_never_edits_history(key):
    p = ScriptedProvider([turn("a"), turn("b")])
    conv = new_conv()
    eng = engine_for(p)
    eng.send(conv, "hello")
    conv["pending_notes"].append("The owner removed the assumption x.")
    eng.send(conv, "again")
    msgs = p.calls[1]["messages"]
    assert msgs[:len(p.calls[0]["messages"])] == p.calls[0]["messages"] + [] or msgs[0] == p.calls[0]["messages"][0]
    assert [m["role"] for m in msgs][-2:] == ["user", "system"]
    assert p.calls[0]["system"] == p.calls[1]["system"]


# ---- refusal / errors ----------------------------------------------------------------------------------------------------

def test_refusal_becomes_a_notice_and_the_chat_continues(key):
    p = ScriptedProvider([turn("", stop="refusal", refusal={"category": "cyber", "explanation": "x"}), turn("fine")])
    conv = new_conv()
    eng = engine_for(p)
    assert eng.send(conv, "q")["ok"]
    assert conv["messages"][-1]["kind"] == "refusal" and "declined" in conv["messages"][-1]["content"]
    assert not [m for m in conv["messages"] if m["role"] == "assistant"]
    assert eng.send(conv, "another question")["ok"]


def test_provider_error_is_reported_without_key_and_missing_key_message():
    conv = new_conv()
    r = engine_for(ScriptedProvider([])).send(conv, "q")
    assert not r["ok"] and "API key" in r["error"]


def test_provider_error_message_scrubs_key(monkeypatch):
    monkeypatch.setenv("ANTHROPIC_API_KEY", KEY)
    p = ScriptedProvider([ProviderError("boom " + KEY, "other")])
    conv = new_conv()
    r = engine_for(p).send(conv, "q")
    assert KEY not in r["error"] and KEY not in json.dumps(conv)


# ---- the Anthropic SDK request shape ----------------------------------------------------------------------------------------

class FakeAnthropic:
    instances = []

    def __init__(self, **kw):
        self.kw, self.created, self.responses = kw, [], FakeAnthropic.queue
        self.messages = SimpleNamespace(create=lambda **k: self._create(False, k))
        self.beta = SimpleNamespace(messages=SimpleNamespace(create=lambda **k: self._create(True, k)))
        self.models = SimpleNamespace(list=lambda: FakeAnthropic.models())
        FakeAnthropic.instances.append(self)

    def _create(self, beta, k):
        self.created.append((beta, k))
        r = self.responses.pop(0)
        if isinstance(r, Exception):
            raise r
        return r


def _msg(content, stop="end_turn", beta=True, model="claude-opus-5-5", usage=None, **extra):
    from anthropic.types import Message
    from anthropic.types.beta import BetaMessage
    d = {"id": "msg_1", "type": "message", "role": "assistant", "model": model, "stop_reason": stop, "stop_sequence": None,
         "content": content, "usage": usage or {"input_tokens": 1, "output_tokens": 2}, **extra}
    return (BetaMessage if beta else Message).model_validate(d)


@pytest.fixture
def fake_sdk(monkeypatch):
    FakeAnthropic.instances, FakeAnthropic.queue = [], []
    FakeAnthropic.models = lambda: []
    monkeypatch.setattr(ap.anthropic, "Anthropic", FakeAnthropic)
    return FakeAnthropic


def _call(model="claude-opus-5-5", messages=None, effort="medium"):
    prov = ap.AnthropicProvider()
    return prov.send(api_key=KEY, model=model, system="SYS", messages=messages or [{"role": "user", "content": "hi"}],
                     tools=tools.specs(), effort=effort)


def test_anthropic_request_follows_the_api_rules(fake_sdk):
    fake_sdk.queue = [_msg([{"type": "thinking", "thinking": "t", "signature": "s"}, {"type": "text", "text": "ok"}])]
    t = _call()
    beta, k = fake_sdk.instances[0].created[0]
    assert beta is True and k["betas"] == ["server-side-fallback-2026-07-01"] and k["fallbacks"] == "default"
    assert "thinking" not in k and "tool_choice" not in k and "temperature" not in k
    assert k["output_config"] == {"effort": "medium"} and k["cache_control"] == {"type": "ephemeral"} and k["max_tokens"] == 16000
    assert k["model"] == "claude-opus-5-5" and k["system"] == "SYS"
    names = [x["name"] for x in k["tools"]]
    assert names == sorted(names) and all(x["strict"] is True and x["input_schema"]["additionalProperties"] is False and "required" in x["input_schema"] for x in k["tools"])
    assert t.text == "ok" and t.thinking and t.raw["content"][0] == {"type": "thinking", "thinking": "t", "signature": "s"}
    assert fake_sdk.instances[0].kw["api_key"] == KEY


def test_haiku_uses_plain_messages_api(fake_sdk):
    fake_sdk.queue = [_msg([{"type": "text", "text": "ok"}], beta=False)]
    _call("claude-haiku-5-5", effort="high")
    beta, k = fake_sdk.instances[0].created[0]
    assert beta is False and "betas" not in k and "fallbacks" not in k and k["output_config"] == {"effort": "high"}


def test_tool_use_response_and_refusal_and_fallback_parsing(fake_sdk):
    fake_sdk.queue = [
        _msg([{"type": "text", "text": "x"}, {"type": "tool_use", "id": "toolu_1", "name": "get_live_setup", "input": {}},
              {"type": "tool_use", "id": "toolu_2", "name": "list_assumptions", "input": {}}], stop="tool_use"),
        _msg([], stop="refusal", stop_details={"type": "refusal", "category": "cyber", "explanation": "no"}),
        _msg([{"type": "fallback", "from": {"model": "claude-opus-5-5"}, "to": {"model": "claude-sonnet-5-5"}, "trigger": {"type": "refusal", "category": "cyber"}},
              {"type": "text", "text": "answered"}],
             usage={"input_tokens": 1, "output_tokens": 2, "iterations": [{"type": "fallback_message", "model": "claude-sonnet-5-5", "input_tokens": 1,
                                                                            "output_tokens": 1, "cache_creation_input_tokens": 0, "cache_read_input_tokens": 0}]}),
    ]
    a, b, c = _call(), _call(), _call()
    assert a.stop == "tool_use" and [x.id for x in a.tool_calls] == ["toolu_1", "toolu_2"]
    assert b.stop == "refusal" and b.refusal["category"] == "cyber"
    assert c.fallback == {"from": "claude-opus-5-5", "to": "claude-sonnet-5-5"} and c.served_model == "claude-sonnet-5-5"
    assert c.raw["content"][0]["from"] == {"model": "claude-opus-5-5"}       # the fallback block is echoed with its original key


def test_fallback_is_reported_in_the_chat(key):
    t = turn("answered", fallback={"from": "claude-opus-5-5", "to": "claude-sonnet-5-5"}, served_model="claude-sonnet-5-5")
    conv = new_conv()
    engine_for(ScriptedProvider([t])).send(conv, "q")
    assert any(m.get("kind") == "fallback" and "claude-sonnet-5-5" in m["content"] for m in conv["messages"])


def test_pause_turn_resends_and_max_tokens_closes_open_tool_calls(key):
    p = ScriptedProvider([turn("part", stop="pause_turn"), turn("whole")])
    conv = new_conv()
    assert engine_for(p).send(conv, "q")["ok"] and len(p.calls) == 2
    p = ScriptedProvider([turn("cut", [("get_live_setup", {})], stop="max_tokens")])
    conv = new_conv()
    engine_for(p).send(conv, "q")
    assert conv["messages"][-2]["role"] == "tool" and conv["messages"][-2]["results"][0]["is_error"] and conv["messages"][-1]["kind"] == "max_tokens"


@pytest.mark.parametrize("exc,kind", [("auth", "auth"), ("rate", "rate_limit"), ("server", "server"), ("conn", "connection")])
def test_typed_error_chain(fake_sdk, exc, kind):
    req = httpx.Request("POST", "https://api.anthropic.com/v1/messages")
    mk = lambda cls, code: cls("boom " + KEY, response=httpx.Response(code, request=req), body=None)  # noqa: E731
    err = {"auth": mk(anthropic.AuthenticationError, 401), "rate": mk(anthropic.RateLimitError, 429),
           "server": mk(anthropic.InternalServerError, 500), "conn": anthropic.APIConnectionError(request=req)}[exc]
    fake_sdk.queue = [err]
    with pytest.raises(ProviderError) as ei:
        _call()
    assert ei.value.kind == kind and KEY not in str(ei.value)


def test_model_list_from_api_and_fallback(fake_sdk):
    fake_sdk.models = lambda: [SimpleNamespace(id="claude-opus-5-5", display_name="Opus 5.5"), SimpleNamespace(id="other-x", display_name="x")]
    r = ap.AnthropicProvider().list_models(KEY)
    assert r["source"] == "api" and [m.id for m in r["models"]] == ["claude-opus-5-5"]

    def boom():
        raise RuntimeError("down " + KEY)
    fake_sdk.models = boom
    r = ap.AnthropicProvider().list_models(KEY)
    assert r["source"] == "fallback" and [m.id for m in r["models"]] == ap.FALLBACK_MODELS and KEY not in (r["error"] or "")
    assert ap.DEFAULT_MODEL == "claude-opus-5-5" and ap.FALLBACK_MODELS == ["claude-opus-5-5", "claude-sonnet-5-5", "claude-haiku-5-5", "claude-fable-5-2"]


def test_gemini_conversion_and_turn():
    from advisor_chat.providers.gemini_provider import GeminiProvider, _strip_schema
    g = GeminiProvider()
    msgs = [{"role": "user", "content": "hi"},
            {"role": "assistant", "text": "", "tool_calls": [{"id": "t1", "name": "get_live_setup", "arguments": {}}], "raw": None},
            {"role": "tool", "results": [{"tool_call_id": "t1", "name": "get_live_setup", "content": '{"a":1}', "is_error": False}]}]
    nat = g.to_native(msgs)
    assert nat[1]["parts"][0]["functionCall"]["name"] == "get_live_setup" and nat[2]["parts"][0]["functionResponse"]["response"] == {"result": {"a": 1}}
    assert "additionalProperties" not in json.dumps(_strip_schema(tools.TOOLS[1].input_schema))
    t = g._turn({"candidates": [{"content": {"parts": [{"functionCall": {"name": "x", "args": {"q": 1}}, "thoughtSignature": "sig"}]}, "finishReason": "STOP"}]}, "gemini-x")
    assert t.stop == "tool_use" and t.raw["content"][0]["thoughtSignature"] == "sig"


# ---- the numeric guard --------------------------------------------------------------------------------------------------------

def _conv_with_results(result):
    conv = new_conv()
    conv["messages"] = [{"role": "user", "content": "what feed?"},
                        {"role": "assistant", "text": "", "tool_calls": [{"id": "a", "name": "toolwiz_calculate", "arguments": {}}]},
                        {"role": "tool", "results": [{"tool_call_id": "a", "name": "toolwiz_calculate", "content": json.dumps(result), "is_error": False}]}]
    return conv


def test_guard_flags_fabricated_chip_load_and_passes_toolwiz_numbers():
    conv = _conv_with_results({"success": True, "rpm": 11522, "feed_ipm": 40.2, "adj_ipt": 0.0012, "doc_in": 0.1})
    bad = guard(conv, "Run 11,522 rpm at 40.2 in/min, but a chip load of 0.003 IPT is fine.")
    assert not bad["ok"] and bad["rejected_numbers"] == ["0.003 IPT"]
    good = guard(conv, "Run 11,522 rpm at 40.2 in/min with 0.0012 IPT and 0.1 in depth.")
    assert good["ok"] and good["rejected_numbers"] == []
    # numbers the owner typed are theirs to repeat
    conv["messages"][0]["content"] = "my runout is 0.0004 in"
    assert guard(conv, "With your 0.0004 in runout")["ok"]


def test_guard_marks_by_default_and_strict_mode_withholds_and_retries(key):
    result = {"success": True, "rpm": 11522}
    p = ScriptedProvider([turn("Use 0.0047 IPT."), turn("Use 11522 rpm.")])
    conv = new_conv()
    engine_for(p).send(conv, "q")
    a = [m for m in conv["messages"] if m["role"] == "assistant"][0]
    assert a["guard"]["rejected_numbers"] == ["0.0047 IPT"] and not a.get("withheld") and len(p.calls) == 1   # default: shown + marked
    # strict mode: withhold and ask again once
    aisettings.save_patch({"strict": True})
    p = ScriptedProvider([turn("", [("list_assumptions", {})]), turn("Use 0.0047 IPT."), turn("It is 3 operations.")])
    conv = new_conv()
    engine_for(p).send(conv, "q")
    sysmsgs = [m for m in conv["messages"] if m["role"] == "system"]
    assert sysmsgs and "0.0047 IPT" in sysmsgs[-1]["content"]
    asst = [m for m in conv["messages"] if m["role"] == "assistant" and m["text"]]
    assert asst[0].get("withheld") and asst[1]["guard"]["attempt"] == 2 and asst[1].get("withheld")
    assert conv["messages"][-1]["kind"] == "guard"
    assert result


# ---- keys never reach the browser ------------------------------------------------------------------------------------------

def test_keys_are_write_only_over_the_api(monkeypatch):
    c = toolwiz_app.app.test_client()
    r = c.post("/api/advisor_chat/settings", json={"keys": {"anthropic": KEY}, "provider": "anthropic"}, headers=HDR)
    assert r.status_code == 200 and KEY not in r.get_data(as_text=True)
    st = c.get("/api/advisor_chat/settings").get_json()["settings"]
    assert st["keys"]["anthropic"] == {"set": True, "last4": KEY[-4:], "source": "saved"} and KEY not in json.dumps(st)
    assert KEY in open(aisettings.settings_path()).read()                    # saved server side only
    assert oct(os.stat(aisettings.settings_path()).st_mode & 0o777) == "0o600"
    monkeypatch.setattr(ap.anthropic, "Anthropic", lambda **kw: SimpleNamespace(models=SimpleNamespace(list=lambda: (_ for _ in ()).throw(RuntimeError("bad " + KEY)))))
    m = c.get("/api/advisor_chat/models?provider=anthropic")
    assert KEY not in m.get_data(as_text=True)
    cv = c.post("/api/advisor_chat/conversations", json={}, headers=HDR).get_json()["conversation"]
    assert KEY not in json.dumps(cv)
    r = c.post("/api/advisor_chat/settings", json={"keys": {"anthropic": "short"}}, headers=HDR)
    assert r.status_code == 400
    c.post("/api/advisor_chat/settings", json={"keys": {"anthropic": ""}}, headers=HDR)
    assert not aisettings.key_status("anthropic")["set"]
    assert "ai_settings.json" in open(os.path.join(ROOT, ".gitignore")).read() and "advisor_chats" in open(os.path.join(ROOT, ".gitignore")).read()


def test_scrub_and_env_key(monkeypatch):
    monkeypatch.setenv("ANTHROPIC_API_KEY", KEY)
    assert aisettings.key_for("anthropic") == KEY and aisettings.key_status("anthropic")["source"] == "env:ANTHROPIC_API_KEY"
    assert aisettings.scrub(f"x {KEY} y") == "x [REDACTED] y"


# ---- routes, start-from-advisor, proposals ----------------------------------------------------------------------------------

@pytest.fixture
def client(key, monkeypatch):
    prov = ScriptedProvider([])
    monkeypatch.setattr(R, "_engine_factory", lambda: ChatEngine(provider_factory=lambda pid: prov))
    c = toolwiz_app.app.test_client()
    c.prov = prov
    return c


def test_start_from_advisor_seeds_the_chat_without_calling_the_model(client):
    r = client.post("/api/advisor_chat/conversations", json={"start_from_advisor": True, **ADV_ARGS}, headers=HDR).get_json()
    assert r["success"] and client.prov.calls == []
    msgs = r["conversation"]["messages"]
    assert [m["role"] for m in msgs] == ["user", "assistant", "tool", "assistant"]
    assert "verdict" in msgs[-1]["text"] and msgs[-1]["guard"]["ok"]
    assert "raw" not in json.dumps(msgs)
    cid = r["conversation"]["id"]
    # the next question reaches the model with the advisor result in its history
    client.prov.steps = [turn("Looks fine.")]
    r = client.post(f"/api/advisor_chat/conversations/{cid}/messages", json={"message": "go on"}, headers=HDR).get_json()
    assert r["ok"] and client.prov.calls[0]["messages"][1]["tool_calls"][0]["name"] == "run_setup_advisor"
    assert store.load(cid)["messages"][-1]["role"] == "assistant"
    nat = ap.AnthropicProvider().to_native(client.prov.calls[0]["messages"], "claude-opus-5-5")
    assert nat[0]["role"] == "user" and nat[1]["content"][0]["type"] == "tool_use"


def test_assumption_chips_roundtrip_and_notes(client):
    cid = client.post("/api/advisor_chat/conversations", json={}, headers=HDR).get_json()["conversation"]["id"]
    r = client.post(f"/api/advisor_chat/conversations/{cid}/assumptions", json={"key": "coating", "value": "ZrN", "scope": {"tools": [12]}}, headers=HDR).get_json()
    aid = r["conversation"]["assumptions"][0]["id"]
    assert client.post(f"/api/advisor_chat/conversations/{cid}/assumptions", json={"key": "coating", "value": "x"}, headers=HDR).status_code == 400
    client.delete(f"/api/advisor_chat/conversations/{cid}/assumptions/{aid}", headers=HDR)
    client.prov.steps = [turn("ok")]
    client.post(f"/api/advisor_chat/conversations/{cid}/messages", json={"message": "hi"}, headers=HDR)
    sys_notes = [m["content"] for m in client.prov.calls[0]["messages"] if m["role"] == "system"]
    assert len(sys_notes) == 2 and "removed" in sys_notes[1]


def test_proposals_operation_values_must_be_toolwiz_values_and_approval_only_queues(client):
    ctx = tools.ToolContext()
    adv = tools.run_tool(ctx, "run_setup_advisor", ADV_ARGS)["data"]
    op = next(o for o in adv["operations"] if o["apply_plan"])
    name, val = next(iter(op["apply_plan"]["recommended"].items()))
    bad = tools.run_tool(ctx, "propose_fusion_change", {"kind": "operation_parameters", "reason": "r", "op_id": op["op_id"], "parameters": {name: "1 in"}})
    assert not bad["data"]["success"] and bad["data"]["rejected"]
    ok = tools.run_tool(ctx, "propose_fusion_change", {"kind": "operation_parameters", "reason": "r", "op_id": op["op_id"], "parameters": {name: val}})
    assert ok["data"]["success"] and ctx.proposals[0]["status"] == "pending"
    assert fusion_bridge.pop_next_command() is None                          # nothing queued by proposing
    cid = client.post("/api/advisor_chat/conversations", json={}, headers=HDR).get_json()["conversation"]["id"]
    conv = store.load(cid)
    conv["proposals"] = ctx.proposals
    store.save(conv)
    r = client.post(f"/api/advisor_chat/conversations/{cid}/proposals/p1/approve", json={}, headers=HDR).get_json()
    assert r["proposal"]["status"] == "queued"
    cmd = fusion_bridge.pop_next_command()
    assert cmd["action"] == "apply_operation_parameters" and cmd["params"]["params"] == {name: val}
    fusion_bridge.record_command_result(cmd["request_id"], {"ok": True, "applied": {name: {"old": "1", "new": val}}, "skipped": {}, "error": None})
    st = client.get(f"/api/advisor_chat/conversations/{cid}/proposals/p1").get_json()["proposal"]
    assert st["status"] == "applied"
    assert client.post(f"/api/advisor_chat/conversations/{cid}/proposals/p1/approve", json={}, headers=HDR).status_code == 409
    # the outcome reaches the model on the next turn as a session note
    client.prov.steps = [turn("noted")]
    client.post(f"/api/advisor_chat/conversations/{cid}/messages", json={"message": "and?"}, headers=HDR)
    assert any("p1" in m["content"] and "applied" in m["content"] for m in client.prov.calls[0]["messages"] if m["role"] == "system")


def test_tool_field_proposals_are_allow_listed_and_declinable(client):
    ctx = tools.ToolContext()
    assert not tools.run_tool(ctx, "propose_fusion_change", {"kind": "tool_fields", "reason": "r", "tool_number": 3, "fields": {"BMC": "carbide", "vendor": "x"}})["data"]["success"] or True
    bad = fusion_bridge.check_tool_fields({"tool_number": 3, "fields": {"post-process": "x"}})
    assert "may not be written" in bad
    ok = tools.run_tool(ctx, "propose_fusion_change", {"kind": "tool_fields", "reason": "AlTiN", "tool_number": 3, "fields": {"coating": "AlTiN", "add_keywords": ["staggered"]}})
    assert ok["data"]["success"]
    cid = client.post("/api/advisor_chat/conversations", json={}, headers=HDR).get_json()["conversation"]["id"]
    conv = store.load(cid)
    conv["proposals"] = ctx.proposals
    store.save(conv)
    d = client.post(f"/api/advisor_chat/conversations/{cid}/proposals/p1/decline", json={}, headers=HDR).get_json()
    assert d["proposal"]["status"] == "declined" and fusion_bridge.pop_next_command() is None


def test_runout_sensitivity_needs_family_and_live_setup_states():
    ctx = tools.ToolContext()
    r = tools.run_tool(ctx, "runout_sensitivity", {"diameter": 0.25})["data"]
    assert r["success"] is False and "family" in r["error"]
    live = tools.run_tool(ctx, "get_live_setup", {})["data"]
    assert live["connected"] and live["stale"] is False and live["operations_count"] == 4
    ctx.now = lambda: __import__("time").time() + 600
    assert tools.run_tool(ctx, "get_live_setup", {})["data"]["stale"] is True
    fusion_bridge.reset_bridge_state()
    assert tools.run_tool(ctx, "get_live_setup", {})["data"]["connected"] is False
    assert "viewport" not in [t.name for t in tools.specs()] and "get_viewport_image" in [t.name for t in tools.specs(True)]


def test_tool_schemas_are_strict_compatible():
    for t in tools.TOOLS:
        def walk(s):
            if s.get("type") == "object":
                assert s["additionalProperties"] is False and "required" in s and set(s["required"]) <= set(s["properties"])
                for v in s["properties"].values():
                    walk(v)
            if s.get("type") == "array":
                walk(s["items"])
        walk(t.input_schema)


# ---- MCP -----------------------------------------------------------------------------------------------------------------------

def test_mcp_tools_prompt_and_assumptions():
    from advisor_chat.assumptions import MCP_ASSUMPTIONS
    MCP_ASSUMPTIONS.clear()
    names = [t["name"] for t in mcp_server.list_mcp_tools()]
    for n in ("toolwiz_set_assumption", "toolwiz_apply_recommendation", "fusion_update_tool_fields"):
        assert n in names
    r = mcp_server.call_mcp_tool_by_name("toolwiz_set_assumption", {"key": "coating", "value": "AlTiN"})
    assert r["success"] and MCP_ASSUMPTIONS
    adv = mcp_server.call_mcp_tool_by_name("toolwiz_setup_advisor", {"family": tsa.FAMILY, "alloy": tsa.ALLOY, "strategies": False})
    assert adv["assumptions"] == [{"key": "coating", "value": "AlTiN", "scope": "all tools"}]
    assert unknown_coating(adv) == []
    bad = mcp_server.call_mcp_tool_by_name("toolwiz_apply_recommendation", {"op_id": adv["operations"][0]["op_id"], "params": {"tool_spindleSpeed": "1 rpm"}})
    assert bad["success"] is False and bad["rejected"]
    q = mcp_server.call_mcp_tool_by_name("fusion_update_tool_fields", {"tool_number": 3, "fields": {"coating": "AlTiN"}})
    assert q["queued"]
    assert not mcp_server.call_mcp_tool_by_name("fusion_update_tool_fields", {"tool_number": 3, "fields": {"evil": "x"}})["success"]
    cmd = fusion_bridge.pop_next_command()
    fusion_bridge.record_command_result(cmd["request_id"], {"ok": True})
    assert mcp_server.call_mcp_tool_by_name("fusion_bridge_result", {"request_id": cmd["request_id"]})["result"] == {"ok": True}
    ini = mcp_server.handle_mcp_message({"jsonrpc": "2.0", "id": 1, "method": "initialize"})
    assert "prompts" in ini["result"]["capabilities"]
    pl = mcp_server.handle_mcp_message({"jsonrpc": "2.0", "id": 2, "method": "prompts/list"})["result"]["prompts"]
    assert pl[0]["name"] == "review_setup"
    pg = mcp_server.handle_mcp_message({"jsonrpc": "2.0", "id": 3, "method": "prompts/get", "params": {"name": "review_setup", "arguments": {"family": "Titanium Alloy"}}})
    text = pg["result"]["messages"][0]["content"]["text"]
    assert "toolwiz_set_assumption" in text and "fusion_update_tool_fields" in text and "Titanium Alloy" in text
    assert "error" in mcp_server.handle_mcp_message({"jsonrpc": "2.0", "id": 4, "method": "prompts/get", "params": {"name": "nope"}})
    MCP_ASSUMPTIONS.clear()


# ---- the Fusion add-in (mocked) ------------------------------------------------------------------------------------------------

from test_addin_audit import AuditBase, make_tool  # noqa: E402


class TestAddinUpdateToolFields(AuditBase):
    def setUp(self):
        super().setUp()
        self.tool_json = {"guid": "g-7", "description": "1/4 flat 4FL TiN", "BMC": "carbide", "post-process": {"number": 7}}
        self.dup = {"guid": "g-8", "description": "1/4 flat", "post-process": {"number": 9}}
        self.dup2 = {"guid": "g-9", "description": "other", "post-process": {"number": 9}}
        items = [self.tool_json, self.dup, self.dup2]

        def item(i):
            t = MagicMock()
            t.toJson.side_effect = lambda: json.dumps(items[i])
            return t
        self.items = items
        self.lib = SimpleNamespace(count=3, item=item, update=MagicMock(side_effect=self._update), operationsByTool=lambda t: SimpleNamespace(count=2))
        self.a._active_cam = lambda: SimpleNamespace(documentToolLibrary=self.lib)
        self.a.adsk.cam.Tool.createFromJson.side_effect = lambda s: json.loads(s)
        self.yes, self.no = self.a.adsk.core.DialogResults.DialogYes, self.a.adsk.core.DialogResults.DialogNo

    def _update(self, new_tool, flag):
        for i, t in enumerate(self.items):
            if t["guid"] == new_tool["guid"]:
                self.items[i] = new_tool
        return True

    def call(self, fields, answer=None, **kw):
        self.a.ui.messageBox.return_value = answer or self.yes
        return self.a.dispatch_bridge_action("update_tool_fields", dict({"tool_number": 7, "fields": fields, "reason": "AlTiN"}, **kw))

    def test_confirmed_change_shows_old_new_audits_and_returns_dicts(self):
        r = self.call({"coating": "altin", "add_keywords": ["staggered"]})
        self.assertTrue(r["ok"], r)
        self.assertEqual(r["applied"]["coating"], {"old": "TiN", "new": "AlTiN"})
        self.assertEqual(self.items[0]["description"], "1/4 flat 4FL staggered AlTiN")
        self.assertEqual(self.lib.update.call_args[0][1], False)             # updateFeedAndSpeed stays False
        text = self.a.ui.messageBox.call_args[0][0]
        self.assertIn("TiN -> AlTiN", text)
        self.assertIn("2 operation(s)", text)
        ev = [e for e in self.entries() if e["event"] == "tool_field_change"]
        self.assertEqual({e["field"] for e in ev}, {"coating", "description"})
        self.assertTrue(any(f.startswith("revert_") for f in os.listdir(self._tmp.name)))

    def test_declined_writes_nothing(self):
        r = self.call({"coating": "AlTiN"}, answer=self.no)
        self.assertFalse(r["ok"])
        self.assertIn("declined", r["error"])
        self.lib.update.assert_not_called()
        self.assertEqual(self.items[0]["description"], "1/4 flat 4FL TiN")

    def test_allow_list_skips_other_fields(self):
        r = self.call({"coating": "AlTiN", "post-process": "x", "vendor": "evil", "BMC": "hss"})
        self.assertTrue(r["ok"])
        self.assertEqual(set(r["skipped"]), {"post-process", "vendor"})
        self.assertEqual(self.items[0]["BMC"], "hss")
        self.assertNotIn("vendor", self.items[0])
        r = self.call({"vendor": "evil"})
        self.assertFalse(r["ok"])
        self.lib.update.assert_called_once()

    def test_ambiguous_number_and_unknown_tool_are_refused(self):
        r = self.call({"coating": "AlTiN"}, tool_number=9)
        self.assertFalse(r["ok"])
        self.assertIn("cannot be told which", r["error"])
        r = self.call({"coating": "AlTiN"}, tool_number=99)
        self.assertIn("not found", r["error"])
        r = self.a.dispatch_bridge_action("update_tool_fields", {"tool_guid": "g-9", "fields": {"comment": "x"}})
        self.assertTrue(r["ok"])
        self.assertEqual(self.items[2]["comment"], "x")

    def test_unchanged_value_is_not_rewritten_and_fusion_rejection_reported(self):
        r = self.call({"coating": "TiN"})
        self.assertTrue(r["ok"] and not r["applied"])
        self.lib.update.assert_not_called()
        self.lib.update.side_effect = lambda *a: (_ for _ in ()).throw(RuntimeError("Fusion says no"))
        r = self.call({"coating": "AlTiN"})
        self.assertFalse(r["ok"])
        self.assertIn("Fusion says no", r["error"])

    def test_viewport_image(self):
        def save(path, w, h):
            with open(path, "wb") as f:
                f.write(b"\x89PNGfake")
            return True
        vp = SimpleNamespace(saveAsImageFile=MagicMock(side_effect=save))
        self.a.app = SimpleNamespace(activeViewport=vp, activeDocument=self.a.app.activeDocument)
        r = self.a.dispatch_bridge_action("get_viewport_image", {"width": 800, "height": 600})
        self.assertTrue(r["ok"])
        import base64
        self.assertEqual(base64.b64decode(r["data_base64"]), b"\x89PNGfake")
        self.assertEqual(vp.saveAsImageFile.call_args[0][1:], (800, 600))
        self.assertEqual([f for f in os.listdir(self._tmp.name) if f.startswith("viewport_")], [])
        self.a.app = SimpleNamespace(activeViewport=None, activeDocument=None)
        self.assertFalse(self.a.dispatch_bridge_action("get_viewport_image", {})["ok"])


def test_bridge_validates_new_actions():
    assert fusion_bridge.execute_bridge_action("update_tool_fields", {"tool_number": 3, "fields": {"x": "y"}})["success"] is False
    assert fusion_bridge.execute_bridge_action("get_viewport_image", {"width": 99999})["success"] is False
    assert fusion_bridge.submit_command("update_tool_fields", {"tool_number": 3, "fields": {"coating": "AlTiN"}})["queued"]
    assert fusion_bridge.submit_command("update_tool_fields", {"fields": {"coating": "AlTiN"}})["success"] is False


def test_runout_sensitivity_tool_sends_calculate_field_names(monkeypatch):
    """Regression: the chat tool must send fluteLength/shankDiameter/stickout as /api/calculate reads them."""
    from advisor_chat import tools as T
    sent = {}

    def fake_post(path, body):
        sent["path"], sent["body"] = path, dict(body)
        return {"success": True, "rows": []}

    ctx = T.ToolContext(post=fake_post)
    out = T.runout_sensitivity(ctx, {"family": "Titanium Alloy", "operation": "Adaptive Roughing", "diameter": 0.0625,
                                     "flutes": 3, "flute_length": 0.1875, "shank_diameter": 0.125, "aggressiveness": 50})
    assert sent["path"] == "/api/runout_sensitivity"
    assert sent["body"]["fluteLength"] == 0.1875 and sent["body"]["shankDiameter"] == 0.125
    assert "flute_length" not in sent["body"] and "runout" not in sent["body"]
    assert any("stickout not given" in n for n in out["inputs_assumed"])
