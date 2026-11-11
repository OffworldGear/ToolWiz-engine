"""The conversation loop: model <-> ToolWiz tools, plus the numeric guard.

``ChatEngine.send(conv, text)`` appends the owner's message, then loops: call the provider, append its assistant turn exactly as
received, run EVERY tool call of that turn, append ALL results in ONE tool message, and repeat until the model ends its turn. History
is append-only (earlier messages are never edited or removed). Afterwards the final reply is checked with
``toolwiz_common.numeric_guard`` against all tool results of the conversation plus the owner's own words.
"""
from __future__ import annotations

import json
from typing import Any, Callable, Dict, List, Optional

from toolwiz_common import numeric_guard

from . import settings as aisettings
from . import store, tools
from .prompts import SYSTEM_PROMPT
from .providers import ProviderError, get_provider
from .providers.base import Turn

MAX_ROUNDS = 14          # model calls per owner message (tool loops included)
STRICT_RETRY_NOTE = ("Your last reply was withheld because it contained numbers that no tool result in this conversation supports: {nums}. "
                     "Answer again. Use only numbers copied from tool results (call a tool if you need one) or describe the point in words.")


def _loads(s: Any) -> Any:
    try:
        return json.loads(s)
    except (TypeError, ValueError):
        return s


def guard(conv: Dict[str, Any], text: str, upto: Optional[int] = None) -> Dict[str, Any]:
    """Numeric-guard ``text`` against every tool result of the conversation (up to message index ``upto``), the owner's messages,
    session notes and the owner's assumptions."""
    msgs = conv["messages"] if upto is None else conv["messages"][:upto]
    grounding: List[Any] = []
    extra: List[str] = []
    for m in msgs:
        if m["role"] == "tool":
            grounding.extend(_loads(r.get("content")) for r in m.get("results") or [])
        elif m["role"] in ("user", "system"):
            extra.append(str(m.get("content") or ""))
        elif m["role"] == "assistant" and m.get("source") == "advisor_summary":
            pass
    grounding.append([a.get("value") for a in conv.get("assumptions", [])])
    r = numeric_guard.check_numbers(text, grounding, extra)
    return {"ok": r["ok"], "rejected_numbers": r["rejected_numbers"], "checked": r["checked"]}


class ChatEngine:
    def __init__(self, provider_factory: Callable[[str], Any] = get_provider, tool_runner: Callable = tools.run_tool,
                 post: Optional[Callable] = None):
        self.provider_factory = provider_factory
        self.tool_runner = tool_runner
        self.post = post

    # ---- helpers ----------------------------------------------------------------------------------------------
    def _ctx(self, conv: Dict[str, Any], viewport: bool) -> tools.ToolContext:
        return tools.ToolContext(assumptions=conv["assumptions"], proposals=conv["proposals"], viewport_enabled=viewport, post=self.post)

    @staticmethod
    def _provider_messages(conv: Dict[str, Any]) -> List[Dict[str, Any]]:
        return [m for m in conv["messages"] if m["role"] in ("user", "assistant", "tool", "system")]

    def _flush_notes(self, conv: Dict[str, Any]) -> None:
        """Session instructions that arrived since the last turn become appended system messages (never edits)."""
        for p in conv["proposals"]:
            if p.get("result") is not None and not p.get("reported"):
                r = p["result"]
                state = "applied" if r.get("ok") and r.get("applied") else ("declined by the owner in Fusion" if "declined" in str(r.get("error") or "") else "failed")
                conv["pending_notes"].append(f"Proposal {p['id']} ({p['summary']}) was {state} in Fusion. Result: "
                                             + json.dumps({k: r.get(k) for k in ("ok", "applied", "skipped", "error")}, default=str))
                p["reported"] = True
        for note in conv["pending_notes"]:
            conv["messages"].append({"role": "system", "content": note})
        conv["pending_notes"] = []

    # ---- the loop ---------------------------------------------------------------------------------------------
    def send(self, conv: Dict[str, Any], text: str, images: Optional[List[Dict[str, Any]]] = None) -> Dict[str, Any]:
        """Run one owner message to completion. Mutates ``conv``. Returns ``{"ok": bool, "error": str | None}``."""
        st = aisettings.load()
        provider_id = conv.get("provider") or st["provider"]
        model = conv.get("model") or st["models"].get(provider_id, "")
        effort = conv.get("effort") or st["effort"]
        strict = bool(st["strict"])
        text = (text or "").strip()
        if not text:
            return {"ok": False, "error": "Type a message first."}
        user = {"role": "user", "content": text}
        if images:
            user["images"] = images
        conv["messages"].append(user)
        if conv.get("title") in (None, "", "New chat"):
            conv["title"] = text[:60]
        self._flush_notes(conv)
        try:
            provider = self.provider_factory(provider_id)
            key = aisettings.key_for(provider_id)
            if not key:
                raise ProviderError(f"No {provider.label} API key is set. Open the settings (gear) and add one, or set the "
                                    f"{aisettings.ENV_KEYS[provider_id][0]} environment variable.", "auth")
            ctx = self._ctx(conv, st["viewport_image"])
            specs = tools.specs(st["viewport_image"])
            self._loop(conv, provider, key, model, effort, ctx, specs)
            final = self._last_assistant(conv)
            if final is not None and final.get("text") and final.get("guard"):
                if strict and not final["guard"]["ok"]:
                    self._strict_retry(conv, final, provider, key, model, effort, ctx, specs)
        except ProviderError as ex:
            conv["messages"].append({"role": "notice", "kind": "error", "error_kind": ex.kind, "content": aisettings.scrub(str(ex))})
            return {"ok": False, "error": aisettings.scrub(str(ex))}
        return {"ok": True, "error": None}

    @staticmethod
    def _last_assistant(conv: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        for m in reversed(conv["messages"]):
            if m["role"] == "assistant" and m.get("source") != "advisor_summary":
                return m
            if m["role"] == "user":
                return None
        return None

    def _loop(self, conv, provider, key, model, effort, ctx, specs) -> None:
        for _ in range(MAX_ROUNDS):
            turn: Turn = provider.send(api_key=key, model=model, system=SYSTEM_PROMPT, messages=self._provider_messages(conv),
                                       tools=specs, effort=effort)
            if turn.stop == "refusal":
                conv["messages"].append({"role": "notice", "kind": "refusal", "refusal": turn.refusal or {},
                                         "content": self._refusal_text(turn)})
                return
            msg = {"role": "assistant", "text": turn.text, "tool_calls": [{"id": c.id, "name": c.name, "arguments": c.arguments} for c in turn.tool_calls],
                   "raw": turn.raw, "meta": {"provider": provider.id, "model": turn.model, "served_model": turn.served_model,
                                             "fallback": turn.fallback, "usage": turn.usage, "thinking": turn.thinking, "stop": turn.stop}}
            conv["messages"].append(msg)
            idx = len(conv["messages"]) - 1
            if turn.text.strip():
                msg["guard"] = guard(conv, turn.text, idx)
            if turn.fallback:
                conv["messages"].append({"role": "notice", "kind": "fallback", "content":
                                         f"{turn.fallback.get('from') or model} declined this request; {turn.fallback.get('to') or turn.served_model} answered instead (server-side fallback)."})
            if turn.stop == "max_tokens":
                if turn.tool_calls:
                    self._error_results(conv, turn, "The reply was cut off before the tool call was complete.")
                conv["messages"].append({"role": "notice", "kind": "max_tokens", "content":
                                         "The reply hit the length limit and was cut off. Ask for it in smaller pieces (one operation at a time)."})
                return
            if turn.tool_calls:
                results = []
                for c in turn.tool_calls:          # every tool call of the turn runs; all results go back in ONE message
                    out = self.tool_runner(ctx, c.name, c.arguments)
                    r = {"tool_call_id": c.id, "name": c.name, "content": out["content"], "is_error": bool(out["is_error"])}
                    if out.get("image"):
                        r["image"] = out["image"]
                    results.append(r)
                conv["messages"].append({"role": "tool", "results": results})
                continue
            if turn.stop == "pause_turn":
                continue
            return
        conv["messages"].append({"role": "notice", "kind": "loop_limit", "content":
                                 "Stopped after many tool rounds without a final answer. Ask again, more specifically."})

    @staticmethod
    def _error_results(conv, turn: Turn, why: str) -> None:
        conv["messages"].append({"role": "tool", "results": [
            {"tool_call_id": c.id, "name": c.name, "content": json.dumps({"success": False, "error": why}), "is_error": True}
            for c in turn.tool_calls]})

    @staticmethod
    def _refusal_text(turn: Turn) -> str:
        cat = (turn.refusal or {}).get("category")
        return ("The model declined to answer this request" + (f" (category: {cat})" if cat else "") +
                ". Rephrase the question, pick another model in the settings, or ask a narrower machining question.")

    def _strict_retry(self, conv, final, provider, key, model, effort, ctx, specs) -> None:
        """Strict mode: withhold the reply, tell the model which numbers were rejected, let it answer once more."""
        nums = final["guard"]["rejected_numbers"]
        final["withheld"] = True
        conv["messages"].append({"role": "system", "content": STRICT_RETRY_NOTE.format(nums=", ".join(nums))})
        self._loop(conv, provider, key, model, effort, ctx, specs)
        again = self._last_assistant(conv)
        if again is not None and again is not final and again.get("text"):
            again["guard"]["attempt"] = 2
            if not again["guard"]["ok"]:
                again["withheld"] = True
                conv["messages"].append({"role": "notice", "kind": "guard", "content":
                                         "The second reply also contained numbers ToolWiz did not provide (" + ", ".join(again["guard"]["rejected_numbers"]) +
                                         "), so it was withheld. The tool results above are the verified numbers."})
        else:
            conv["messages"].append({"role": "notice", "kind": "guard", "content":
                                     "The reply contained numbers ToolWiz did not provide (" + ", ".join(nums) + ") and was withheld."})

    # ---- seeding a chat with the advisor's summary ----------------------------------------------------------------
    def start_from_advisor(self, conv: Dict[str, Any], args: Dict[str, Any]) -> Dict[str, Any]:
        """Run the Setup Advisor (ToolWiz only, no model call) and open the chat with its summary. The tool exchange is in the
        history, so the model can use the result from the first question on."""
        st = aisettings.load()
        ctx = self._ctx(conv, st["viewport_image"])
        out = self.tool_runner(ctx, "run_setup_advisor", args)
        data = out["data"]
        cid = "seed_" + conv["id"]
        conv["messages"].append({"role": "user", "content": "Run the Setup Advisor on my open Fusion setup and show me what it found."})
        conv["messages"].append({"role": "assistant", "text": "", "tool_calls": [{"id": cid, "name": "run_setup_advisor", "arguments": args}],
                                 "raw": None, "meta": {"source": "start_button"}})
        conv["messages"].append({"role": "tool", "results": [{"tool_call_id": cid, "name": "run_setup_advisor", "content": out["content"],
                                                              "is_error": bool(out["is_error"])}]})
        if not data.get("success"):
            text = "I could not run the Setup Advisor: " + str(data.get("error") or "unknown error")
        else:
            s = data["summary"]
            lines = [f"Setup Advisor result for {data.get('document') or 'the open document'}: verdict {s['verdict']}, "
                     f"{s['stop']} STOP, {s['caution']} CAUTION and {s['info']} INFO findings across {s['operations']} operations."]
            for o in data["operations"]:
                stops = [f["title"] for f in o["findings"] if f["severity"] == "STOP"]
                if stops:
                    lines.append(f"- STOP, {o['name']}: " + "; ".join(stops[:3]))
            lines.append("Tell me where to start, or tell me what to assume (material, coatings, holders, runout) and I will re-run it.")
            text = "\n".join(lines)
        msg = {"role": "assistant", "text": text, "tool_calls": [], "raw": None, "source": "advisor_summary",
               "meta": {"source": "start_button"}}
        msg["guard"] = guard(conv, text)
        conv["messages"].append(msg)
        if conv.get("title") in (None, "", "New chat"):
            conv["title"] = "Setup Advisor review"
        return {"ok": bool(data.get("success")), "error": None if data.get("success") else data.get("error")}
