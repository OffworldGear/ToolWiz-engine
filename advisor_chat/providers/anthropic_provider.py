"""Claude through the official ``anthropic`` SDK (no raw HTTP).

Rules this module follows (they are API requirements for the Claude 5.5 / Fable 5.2 models):
  * thinking is always on for Opus 5.5 / Sonnet 5.5 / Fable 5.2: the ``thinking`` parameter is never sent (``{"type": "disabled"}``
    or ``budget_tokens`` return 400); depth is set with ``output_config={"effort": low|medium|high}``;
  * tools are JSON-schema tools (``additionalProperties: false``; ``"strict": True`` on as many as the API's optional-parameter limit allows); ``tool_choice`` is left at its default
    ``auto`` (forcing ``any`` / ``tool`` returns 400);
  * the assistant turn is echoed back EXACTLY as received (thinking blocks included): history is append-only, nothing earlier is edited;
  * Opus 5.5 / Sonnet 5.5 / Fable 5.2 requests use the server-side refusal fallback (``client.beta.messages.create(...,
    betas=["server-side-fallback-2026-07-01"], fallbacks="default")``); ``Turn.fallback`` says when a fallback model answered;
  * prompt caching: the system prompt and the (name-sorted) tool list are stable, and ``cache_control={"type": "ephemeral"}`` is set
    at the top level (automatic caching of the growing conversation prefix).
"""
from __future__ import annotations

import copy
from typing import Any, Dict, List, Optional

import anthropic

from .. import settings
from .base import ModelInfo, Provider, ProviderError, ToolCall, ToolSpec, Turn

DEFAULT_MODEL = "claude-opus-5-5"
FALLBACK_MODELS = ["claude-opus-5-5", "claude-sonnet-5-5", "claude-haiku-5-5", "claude-fable-5-2"]
MODEL_NOTES = {
    "claude-opus-5-5": "most capable, default",
    "claude-sonnet-5-5": "cheaper and faster, good for routine reviews",
    "claude-haiku-5-5": "cheapest and fastest",
    "claude-fable-5-2": "fable 5.2",
}
FALLBACK_BETA = "server-side-fallback-2026-07-01"
STRICT_OPTIONAL_LIMIT = 24      # API limit on optional parameters across all strict tool schemas
STRICT_OPTIONAL_BUDGET = 20     # what we spend of it


def _optional_count(schema: Dict[str, Any]) -> int:
    """Optional parameters in a JSON schema, nested objects and array items included."""
    n = 0
    if schema.get("type") == "object":
        props = schema.get("properties") or {}
        n += len(set(props) - set(schema.get("required") or []))
        n += sum(_optional_count(v) for v in props.values() if isinstance(v, dict))
    if schema.get("type") == "array" and isinstance(schema.get("items"), dict):
        n += _optional_count(schema["items"])
    return n


FALLBACK_MODEL_IDS = {"claude-opus-5-5", "claude-sonnet-5-5", "claude-fable-5-2"}
MAX_TOKENS = 16000
REQUEST_TIMEOUT = 600.0


def _dump(block: Any) -> Dict[str, Any]:
    """A response content block as a JSON-able dict that can be sent back unchanged (the fallback block's ``from`` keeps its name)."""
    if isinstance(block, dict):
        return copy.deepcopy(block)
    return block.model_dump(mode="json", exclude_none=True, by_alias=True)


def _image_block(img: Dict[str, Any]) -> Dict[str, Any]:
    return {"type": "image", "source": {"type": "base64", "media_type": img.get("media_type") or "image/png", "data": img["data"]}}


class AnthropicProvider(Provider):
    id = "anthropic"
    label = "Anthropic Claude"
    supports_images = True

    def __init__(self) -> None:
        self._system_role_ok = True
        self._key = ""

    def default_model(self) -> str:
        return DEFAULT_MODEL

    # ---- models -----------------------------------------------------------------------------------------------
    def list_models(self, api_key: str) -> Dict[str, Any]:
        self._key = api_key or ""
        fallback = [ModelInfo(m, m, MODEL_NOTES.get(m, "")) for m in FALLBACK_MODELS]
        if not api_key:
            return {"models": fallback, "source": "fallback", "error": "No Anthropic API key set: showing the default list."}
        try:
            client = anthropic.Anthropic(api_key=api_key, max_retries=1, timeout=20.0)
            found: List[ModelInfo] = []
            for m in client.models.list():
                mid = getattr(m, "id", None)
                if mid and str(mid).startswith("claude"):
                    found.append(ModelInfo(str(mid), str(getattr(m, "display_name", None) or mid), MODEL_NOTES.get(str(mid), "")))
            if found:
                return {"models": found, "source": "api", "error": None}
            return {"models": fallback, "source": "fallback", "error": "The API listed no Claude models: showing the default list."}
        except Exception as ex:      # the picker must always work
            return {"models": fallback, "source": "fallback", "error": "Could not list models (" + self._explain(ex) + "): showing the default list."}

    # ---- conversion -------------------------------------------------------------------------------------------
    def to_native(self, messages: List[Dict[str, Any]], model: str) -> List[Dict[str, Any]]:
        out: List[Dict[str, Any]] = []
        for m in messages:
            role = m.get("role")
            if role == "user":
                blocks: List[Dict[str, Any]] = [_image_block(i) for i in m.get("images") or [] if i.get("data")]
                if blocks:
                    blocks.append({"type": "text", "text": m.get("content") or ""})
                    out.append({"role": "user", "content": blocks})
                else:
                    out.append({"role": "user", "content": m.get("content") or ""})
            elif role == "assistant":
                raw = m.get("raw") or {}
                if raw.get("provider") == "anthropic" and raw.get("model") == model and raw.get("content"):
                    out.append({"role": "assistant", "content": copy.deepcopy(raw["content"])})
                else:
                    blocks = []
                    if (m.get("text") or "").strip():
                        blocks.append({"type": "text", "text": m["text"]})
                    for tc in m.get("tool_calls") or []:
                        blocks.append({"type": "tool_use", "id": tc["id"], "name": tc["name"], "input": tc.get("arguments") or {}})
                    if blocks:
                        out.append({"role": "assistant", "content": blocks})
            elif role == "tool":
                blocks = []
                for r in m.get("results") or []:
                    content: Any = r.get("content") or ""
                    if r.get("image") and r["image"].get("data"):
                        content = [{"type": "text", "text": content or "image"}, _image_block(r["image"])]
                    b: Dict[str, Any] = {"type": "tool_result", "tool_use_id": r["tool_call_id"], "content": content}
                    if r.get("is_error"):
                        b["is_error"] = True
                    blocks.append(b)
                out.append({"role": "user", "content": blocks})
            elif role == "system":
                if self._system_role_ok:
                    out.append({"role": "system", "content": m.get("content") or ""})
                else:
                    out.append({"role": "user", "content": "[session instruction] " + (m.get("content") or "")})
        return out

    @staticmethod
    def tools_native(tools: List[ToolSpec]) -> List[Dict[str, Any]]:
        # The API allows at most STRICT_OPTIONAL_LIMIT optional parameters over all strict tools together (HTTP 400 otherwise).
        # Strict goes to the tools with the fewest optional parameters until the budget is spent; the rest are ordinary tools,
        # whose arguments tools.run_tool validates against the same schema.
        budget, strict_names = STRICT_OPTIONAL_BUDGET, set()
        for n, name in sorted((_optional_count(t.input_schema), t.name) for t in tools):
            if n <= budget:
                budget -= n
                strict_names.add(name)
        out = []
        for t in sorted(tools, key=lambda t: t.name):          # deterministic order keeps the prompt cache valid
            schema = copy.deepcopy(t.input_schema)
            schema.setdefault("type", "object")
            schema.setdefault("properties", {})
            schema.setdefault("required", [])
            schema["additionalProperties"] = False
            spec = {"name": t.name, "description": t.description, "input_schema": schema}
            if t.name in strict_names:
                spec["strict"] = True
            out.append(spec)
        return out

    # ---- the call ---------------------------------------------------------------------------------------------
    def send(self, *, api_key: str, model: str, system: str, messages: List[Dict[str, Any]], tools: List[ToolSpec],
             effort: str = "medium") -> Turn:
        if not api_key:
            raise ProviderError("No Anthropic API key: add one in the Advisor Chat settings (or set ANTHROPIC_API_KEY).", "auth")
        model = model or DEFAULT_MODEL
        self._key = api_key
        client = anthropic.Anthropic(api_key=api_key, max_retries=2, timeout=REQUEST_TIMEOUT)
        use_effort = effort in ("low", "medium", "high")
        for attempt in range(3):
            kwargs: Dict[str, Any] = dict(
                model=model, max_tokens=MAX_TOKENS, system=system, messages=self.to_native(messages, model),
                tools=self.tools_native(tools), cache_control={"type": "ephemeral"})
            if use_effort:
                kwargs["output_config"] = {"effort": effort}
            try:
                if model in FALLBACK_MODEL_IDS:
                    resp = client.beta.messages.create(betas=[FALLBACK_BETA], fallbacks="default", **kwargs)
                else:
                    resp = client.messages.create(**kwargs)
                return self._turn(resp, model)
            except anthropic.BadRequestError as ex:
                msg = str(getattr(ex, "message", ex)).lower()
                if attempt < 2 and self._system_role_ok and "role" in msg and "system" in msg:
                    self._system_role_ok = False         # this API build wants session notes as user turns
                    continue
                if attempt < 2 and use_effort and "effort" in msg:
                    use_effort = False                   # a model without the effort control
                    continue
                raise self._error(ex) from None
            except Exception as ex:
                raise self._error(ex) from None
        raise ProviderError("The request could not be completed.", "bad_request")

    # ---- response -> Turn ---------------------------------------------------------------------------------------
    def _turn(self, resp: Any, model: str) -> Turn:
        stop = str(getattr(resp, "stop_reason", None) or "end_turn")
        content = list(getattr(resp, "content", None) or [])
        text_parts: List[str] = []
        calls: List[ToolCall] = []
        thinking = False
        fallback: Optional[Dict[str, Any]] = None
        for b in content:
            t = getattr(b, "type", None) if not isinstance(b, dict) else b.get("type")
            if t == "text":
                text_parts.append(getattr(b, "text", None) if not isinstance(b, dict) else b.get("text", ""))
            elif t == "tool_use":
                g = (lambda k: b.get(k)) if isinstance(b, dict) else (lambda k: getattr(b, k, None))
                calls.append(ToolCall(str(g("id")), str(g("name")), dict(g("input") or {})))
            elif t in ("thinking", "redacted_thinking"):
                thinking = True
            elif t == "fallback":
                fr = getattr(b, "from_", None) if not isinstance(b, dict) else b.get("from")
                to = getattr(b, "to", None) if not isinstance(b, dict) else b.get("to")
                fallback = {"from": getattr(fr, "model", None) if not isinstance(fr, dict) else fr.get("model"),
                            "to": getattr(to, "model", None) if not isinstance(to, dict) else to.get("model")}
        usage = getattr(resp, "usage", None)
        served = str(getattr(resp, "model", None) or model)
        its = getattr(usage, "iterations", None) or []
        for it in its:
            if getattr(it, "type", None) == "fallback_message":
                served = str(getattr(it, "model", served))
                fallback = fallback or {"from": model, "to": served}
                fallback["to"] = fallback.get("to") or served
        if fallback and fallback.get("to"):
            served = fallback["to"]
        refusal = None
        if stop == "refusal":
            sd = getattr(resp, "stop_details", None)
            refusal = {"category": getattr(sd, "category", None) if sd is not None else None,
                       "explanation": getattr(sd, "explanation", None) if sd is not None else None}
        u: Dict[str, Any] = {}
        if usage is not None:
            for k in ("input_tokens", "output_tokens", "cache_read_input_tokens", "cache_creation_input_tokens"):
                v = getattr(usage, k, None)
                if isinstance(v, int):
                    u[k] = v
        return Turn(text="".join(p or "" for p in text_parts), tool_calls=calls, stop=stop if stop in (
            "end_turn", "tool_use", "max_tokens", "refusal", "pause_turn") else "other",
            raw={"provider": "anthropic", "model": model, "content": [_dump(b) for b in content]},
            model=model, served_model=served, fallback=fallback, refusal=refusal, usage=u, thinking=thinking)

    # ---- errors -----------------------------------------------------------------------------------------------
    def _explain(self, ex: Exception) -> str:
        body = getattr(ex, "body", None)
        msg = ((body or {}).get("error") or {}).get("message") if isinstance(body, dict) and isinstance(body.get("error"), dict) else None
        text = settings.scrub(msg or getattr(ex, "message", None) or str(ex))
        return (text.replace(self._key, "[REDACTED]") if self._key else text)[:200]

    def _error(self, ex: Exception) -> ProviderError:
        if isinstance(ex, anthropic.AuthenticationError):
            return ProviderError("Anthropic rejected the API key. Check the key in the Advisor Chat settings.", "auth", 401)
        if isinstance(ex, anthropic.RateLimitError):
            return ProviderError("Anthropic rate limit reached. Wait a minute and try again, or pick a cheaper model.", "rate_limit", 429)
        if isinstance(ex, anthropic.APIStatusError):
            code = getattr(ex, "status_code", 0) or 0
            if code >= 500:
                return ProviderError(f"Anthropic had a server problem (HTTP {code}). Try again in a moment.", "server", code)
            if code == 403:
                return ProviderError("Anthropic refused this key for that model (permission denied). Pick another model or check the key's access.", "auth", 403)
            return ProviderError(f"Anthropic rejected the request (HTTP {code}): {self._explain(ex)}", "bad_request", code)
        if isinstance(ex, anthropic.APIConnectionError):
            return ProviderError("Could not reach Anthropic. Check the internet connection and try again.", "connection")
        return ProviderError("Unexpected error calling Anthropic: " + self._explain(ex), "other")
