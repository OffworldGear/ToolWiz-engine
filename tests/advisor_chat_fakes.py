"""Test doubles for the Advisor Chat: a scripted provider (no real LLM is ever called) and a fake Anthropic client built from the
SDK's own response types."""
from __future__ import annotations

import copy
import itertools
import json
from typing import Any, Callable, Dict, List

from advisor_chat.providers.base import ModelInfo, Provider, ProviderError, ToolCall, Turn

_ids = itertools.count(1)


def turn(text: str = "", calls=(), stop=None, **kw) -> Turn:
    """A provider turn: ``calls`` is [(tool name, arguments)]; stop defaults to tool_use / end_turn."""
    tcs = [ToolCall(f"toolu_{next(_ids):04d}", n, dict(a)) for n, a in calls]
    return Turn(text=text, tool_calls=tcs, stop=stop or ("tool_use" if tcs else "end_turn"),
                raw={"provider": "anthropic", "model": "claude-opus-5-5", "content": [{"type": "thinking", "thinking": "t", "signature": "sig"}]
                     + ([{"type": "text", "text": text}] if text else [])
                     + [{"type": "tool_use", "id": c.id, "name": c.name, "input": c.arguments} for c in tcs]},
                model="claude-opus-5-5", served_model=kw.pop("served_model", "claude-opus-5-5"), **kw)


class ScriptedProvider(Provider):
    """Returns the scripted turns in order (a step may be a callable ``f(messages) -> Turn``) and records every call."""
    id = "anthropic"
    label = "Scripted"

    def __init__(self, steps: List[Any]):
        self.steps = list(steps)
        self.calls: List[Dict[str, Any]] = []

    def default_model(self) -> str:
        return "claude-opus-5-5"

    def list_models(self, api_key: str) -> Dict[str, Any]:
        return {"models": [ModelInfo("claude-opus-5-5", "claude-opus-5-5", "default"), ModelInfo("claude-sonnet-5-5", "claude-sonnet-5-5", "cheaper")],
                "source": "fallback", "error": None}

    def send(self, *, api_key, model, system, messages, tools, effort="medium") -> Turn:
        self.calls.append({"api_key": api_key, "model": model, "system": system, "messages": copy.deepcopy(messages),
                           "tools": [t.name for t in tools], "effort": effort})
        if not self.steps:
            raise AssertionError("the scripted provider was called more often than scripted")
        step = self.steps.pop(0)
        if isinstance(step, Exception):
            raise step
        return step(messages) if callable(step) else step


def last_tool_json(messages: List[Dict[str, Any]], name: str) -> Any:
    for m in reversed(messages):
        if m["role"] == "tool":
            for r in m["results"]:
                if r["name"] == name:
                    return json.loads(r["content"])
    return None
