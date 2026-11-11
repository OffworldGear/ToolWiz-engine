"""Google Gemini over httpx (the approach ``ai_machinist.py`` already uses) with Gemini function calling.

Model discovery is shared with ``ai_machinist.get_available_gemini_models`` (``ListModels``). The assistant's parts (including any
``thoughtSignature``) are echoed back unchanged on the next call, as the Gemini 3 models require for function calling. The effort
setting is not used by Gemini.
"""
from __future__ import annotations

import copy
import uuid
from typing import Any, Dict, List

import httpx

from .. import settings
from .base import ModelInfo, Provider, ProviderError, ToolCall, ToolSpec, Turn

BASE = "https://generativelanguage.googleapis.com/v1beta/models"
FALLBACK_MODELS = ["gemini-2.5-pro", "gemini-2.5-flash"]
MAX_OUTPUT_TOKENS = 8192
_BLOCKED = {"SAFETY", "PROHIBITED_CONTENT", "BLOCKLIST", "SPII", "RECITATION", "IMAGE_SAFETY"}


def _strip_schema(s: Any) -> Any:
    """JSON schema -> the OpenAPI subset Gemini accepts (no additionalProperties)."""
    if isinstance(s, dict):
        return {k: _strip_schema(v) for k, v in s.items() if k not in ("additionalProperties", "strict", "$schema")}
    if isinstance(s, list):
        return [_strip_schema(x) for x in s]
    return s


def _parse_json(text: str) -> Any:
    import json
    try:
        return json.loads(text)
    except (TypeError, ValueError):
        return text


class GeminiProvider(Provider):
    id = "gemini"
    label = "Google Gemini"
    supports_images = True

    def default_model(self) -> str:
        return ""

    def list_models(self, api_key: str) -> Dict[str, Any]:
        fb = [ModelInfo(m, m) for m in FALLBACK_MODELS]
        if not api_key:
            return {"models": fb, "source": "fallback", "error": "No Gemini API key set: showing the default list."}
        import ai_machinist
        names, err = ai_machinist.get_available_gemini_models(api_key)
        names = [n for n in names if n.startswith("gemini")]
        if names:
            return {"models": [ModelInfo(n, n) for n in names], "source": "api", "error": None}
        return {"models": fb, "source": "fallback", "error": settings.scrub(err or "No Gemini models found") + ": showing the default list."}

    def to_native(self, messages: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        out: List[Dict[str, Any]] = []
        for m in messages:
            role = m.get("role")
            if role == "user":
                parts: List[Dict[str, Any]] = [{"text": m.get("content") or ""}]
                for im in m.get("images") or []:
                    if im.get("data"):
                        parts.append({"inlineData": {"mimeType": im.get("media_type") or "image/png", "data": im["data"]}})
                out.append({"role": "user", "parts": parts})
            elif role == "assistant":
                raw = m.get("raw") or {}
                if raw.get("provider") == "gemini" and raw.get("content"):
                    out.append({"role": "model", "parts": copy.deepcopy(raw["content"])})
                else:
                    parts = []
                    if (m.get("text") or "").strip():
                        parts.append({"text": m["text"]})
                    for tc in m.get("tool_calls") or []:
                        parts.append({"functionCall": {"name": tc["name"], "args": tc.get("arguments") or {}}})
                    if parts:
                        out.append({"role": "model", "parts": parts})
            elif role == "tool":
                parts = []
                images = []
                for r in m.get("results") or []:
                    val = _parse_json(r.get("content") or "")
                    resp = {"error": val} if r.get("is_error") else {"result": val}
                    parts.append({"functionResponse": {"name": r.get("name") or "tool", "response": resp}})
                    if r.get("image") and r["image"].get("data"):
                        images.append({"inlineData": {"mimeType": r["image"].get("media_type") or "image/png", "data": r["image"]["data"]}})
                out.append({"role": "user", "parts": parts + images})
            elif role == "system":
                out.append({"role": "user", "parts": [{"text": "[session instruction] " + (m.get("content") or "")}]})
        return out

    def send(self, *, api_key: str, model: str, system: str, messages: List[Dict[str, Any]], tools: List[ToolSpec],
             effort: str = "medium") -> Turn:
        if not api_key:
            raise ProviderError("No Gemini API key: add one in the Advisor Chat settings (or set GEMINI_API_KEY).", "auth")
        if not model:
            models = self.list_models(api_key)["models"]
            model = models[0].id if models else FALLBACK_MODELS[0]
        clean = model.replace("models/", "").strip()
        payload: Dict[str, Any] = {
            "system_instruction": {"parts": [{"text": system}]},
            "contents": self.to_native(messages),
            "tools": [{"functionDeclarations": [
                {"name": t.name, "description": t.description, "parameters": _strip_schema(t.input_schema)}
                for t in sorted(tools, key=lambda t: t.name)]}],
            "toolConfig": {"functionCallingConfig": {"mode": "AUTO"}},
            "generationConfig": {"temperature": 0.2, "maxOutputTokens": MAX_OUTPUT_TOKENS},
        }
        try:
            with httpx.Client(timeout=120.0) as client:
                resp = client.post(f"{BASE}/{clean}:generateContent", json=payload,
                                   headers={"x-goog-api-key": api_key, "Content-Type": "application/json"})
        except httpx.TimeoutException:
            raise ProviderError("Gemini did not answer in time. Try again.", "connection") from None
        except httpx.HTTPError as ex:
            raise ProviderError("Could not reach Gemini: " + settings.scrub(ex)[:150], "connection") from None
        if resp.status_code != 200:
            try:
                msg = resp.json().get("error", {}).get("message", resp.text[:200])
            except ValueError:
                msg = resp.text[:200]
            msg = settings.scrub(msg)
            if resp.status_code in (400, 401, 403) and ("api key" in msg.lower() or "permission" in msg.lower() or resp.status_code in (401, 403)):
                raise ProviderError("Gemini rejected the API key. Check the key in the Advisor Chat settings.", "auth", resp.status_code)
            if resp.status_code == 429:
                raise ProviderError("Gemini rate limit reached. Wait a minute and try again.", "rate_limit", 429)
            if resp.status_code >= 500:
                raise ProviderError(f"Gemini had a server problem (HTTP {resp.status_code}). Try again in a moment.", "server", resp.status_code)
            raise ProviderError(f"Gemini rejected the request (HTTP {resp.status_code}): {msg[:200]}", "bad_request", resp.status_code)
        return self._turn(resp.json(), clean)

    @staticmethod
    def _turn(data: Dict[str, Any], model: str) -> Turn:
        fb = data.get("promptFeedback") or {}
        if fb.get("blockReason"):
            return Turn(stop="refusal", model=model, served_model=model, raw=None,
                        refusal={"category": str(fb["blockReason"]).lower(), "explanation": "Gemini blocked the prompt."})
        cands = data.get("candidates") or []
        if not cands:
            raise ProviderError("Gemini returned no answer.", "other")
        cand = cands[0]
        parts = (cand.get("content") or {}).get("parts") or []
        text, calls, keep = [], [], []
        for p in parts:
            if p.get("thought") is True:
                continue
            keep.append(p)
            if "text" in p:
                text.append(p["text"])
            elif "functionCall" in p:
                fc = p["functionCall"]
                calls.append(ToolCall("g_" + uuid.uuid4().hex[:10], str(fc.get("name")), dict(fc.get("args") or {})))
        reason = str(cand.get("finishReason") or "STOP")
        if reason in _BLOCKED:
            stop = "refusal"
        elif reason == "MAX_TOKENS":
            stop = "max_tokens"
        elif calls:
            stop = "tool_use"
        else:
            stop = "end_turn"
        um = data.get("usageMetadata") or {}
        return Turn(text="".join(text), tool_calls=calls, stop=stop, raw={"provider": "gemini", "model": model, "content": keep},
                    model=model, served_model=model,
                    refusal={"category": reason.lower(), "explanation": "Gemini stopped the reply (%s)." % reason} if stop == "refusal" else None,
                    usage={"input_tokens": um.get("promptTokenCount"), "output_tokens": um.get("candidatesTokenCount")})
