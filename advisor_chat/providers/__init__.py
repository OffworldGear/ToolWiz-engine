"""Provider registry for the Advisor Chat."""
from __future__ import annotations

from typing import Dict, List

from .base import ModelInfo, Provider, ProviderError, ToolCall, ToolSpec, Turn  # noqa: F401

_FACTORIES = {}


def register(provider_id: str, factory) -> None:
    _FACTORIES[provider_id] = factory


def get_provider(provider_id: str) -> Provider:
    if not _FACTORIES:
        _load_builtin()
    if provider_id not in _FACTORIES:
        raise ProviderError(f"Unknown provider {provider_id!r}", "bad_request")
    return _FACTORIES[provider_id]()


def provider_ids() -> List[str]:
    if not _FACTORIES:
        _load_builtin()
    return list(_FACTORIES)


def _load_builtin() -> None:
    from .anthropic_provider import AnthropicProvider
    from .gemini_provider import GeminiProvider
    register("anthropic", AnthropicProvider)
    register("gemini", GeminiProvider)
