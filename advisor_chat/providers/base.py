"""Provider interface for the Advisor Chat.

A provider turns the provider-neutral conversation (see ``advisor_chat.engine``) plus a tool list into one assistant turn:
text and tool calls. ``list_models`` feeds the model picker. Another provider (OpenAI, a local model) only has to implement
``Provider`` and be registered in ``providers/__init__.py``.

Neutral messages (JSON-able, what is stored on disk):
  {"role": "user", "content": str, "images": [{"media_type", "data"(base64)}]?}
  {"role": "assistant", "text": str, "tool_calls": [{"id", "name", "arguments"}], "raw": {"provider", "model", "content"}, "meta": {...}}
  {"role": "tool", "results": [{"tool_call_id", "name", "content": str, "is_error": bool, "image": {...}?}]}
  {"role": "system", "content": str}          # a session instruction appended after a user turn (history is append-only)
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional


@dataclass
class ToolSpec:
    name: str
    description: str
    input_schema: Dict[str, Any]


@dataclass
class ToolCall:
    id: str
    name: str
    arguments: Dict[str, Any]


@dataclass
class ModelInfo:
    id: str
    label: str = ""
    note: str = ""

    def as_dict(self) -> Dict[str, Any]:
        return {"id": self.id, "label": self.label or self.id, "note": self.note}


class ProviderError(Exception):
    """A provider call failed. ``kind``: auth | rate_limit | server | connection | bad_request | other. ``str(e)`` is a
    message for the owner (never contains an API key)."""

    def __init__(self, message: str, kind: str = "other", status: Optional[int] = None):
        super().__init__(message)
        self.kind = kind
        self.status = status


@dataclass
class Turn:
    """One provider response."""
    text: str = ""
    tool_calls: List[ToolCall] = field(default_factory=list)
    stop: str = "end_turn"          # end_turn | tool_use | max_tokens | refusal | pause_turn | other
    raw: Any = None                 # provider-native assistant content (JSON-able), echoed back unchanged on the next call
    model: str = ""                 # the model that was asked
    served_model: str = ""          # the model that answered (differs after a server-side fallback)
    fallback: Optional[Dict[str, Any]] = None   # {"from", "to"} when a fallback model answered
    refusal: Optional[Dict[str, Any]] = None    # {"category", "explanation"} when stop == "refusal"
    usage: Dict[str, Any] = field(default_factory=dict)
    thinking: bool = False          # the response contained thinking blocks


class Provider:
    id = ""
    label = ""
    supports_images = False

    def list_models(self, api_key: str) -> Dict[str, Any]:
        """``{"models": [ModelInfo...], "source": "api" | "fallback", "error": str | None}``."""
        raise NotImplementedError

    def default_model(self) -> str:
        raise NotImplementedError

    def send(self, *, api_key: str, model: str, system: str, messages: List[Dict[str, Any]], tools: List[ToolSpec],
             effort: str = "medium") -> Turn:
        """One model call over the neutral ``messages``. Raises ``ProviderError``."""
        raise NotImplementedError
