"""AI provider settings and API keys, stored server-side only (``data/ai_settings.json``, git-ignored).

Keys are never returned to the browser after saving (``public_view`` reports only set / not set, the last four characters and
where the key came from) and never logged (``scrub`` removes every known key from text before it is shown or logged). A key can
also come from the environment (``ANTHROPIC_API_KEY``, ``GEMINI_API_KEY`` / ``GOOGLE_API_KEY``); a saved key wins.
"""
from __future__ import annotations

import json
import os
import tempfile
import threading
from typing import Any, Dict, List, Optional

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
_LOCK = threading.Lock()

PROVIDERS = ("anthropic", "gemini")
ENV_KEYS = {"anthropic": ("ANTHROPIC_API_KEY",), "gemini": ("GEMINI_API_KEY", "GOOGLE_API_KEY")}
EFFORTS = ("low", "medium", "high")
DEFAULT_MODELS = {"anthropic": "claude-opus-5-5", "gemini": ""}     # "" = first model Google lists for the key
DEFAULTS: Dict[str, Any] = {"provider": "anthropic", "models": dict(DEFAULT_MODELS), "effort": "medium", "strict": False,
                            "viewport_image": False}


def settings_path() -> str:
    return os.environ.get("TOOLWIZ_AI_SETTINGS_PATH") or os.path.join(ROOT, "data", "ai_settings.json")


def _read() -> Dict[str, Any]:
    try:
        with open(settings_path(), encoding="utf-8") as fh:
            d = json.load(fh)
        return d if isinstance(d, dict) else {}
    except (OSError, ValueError):
        return {}


def _write(d: Dict[str, Any]) -> None:
    path = settings_path()
    os.makedirs(os.path.dirname(path), exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix=".ai_settings.", dir=os.path.dirname(path))
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            json.dump(d, fh, indent=2)
        try:
            os.chmod(tmp, 0o600)
        except OSError:
            pass
        os.replace(tmp, path)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)


def load() -> Dict[str, Any]:
    """Settings with defaults filled in. Contains the raw keys under ``keys``: server-side use only."""
    raw = _read()
    out = {k: (dict(v) if isinstance(v, dict) else v) for k, v in DEFAULTS.items()}
    if raw.get("provider") in PROVIDERS:
        out["provider"] = raw["provider"]
    if isinstance(raw.get("models"), dict):
        out["models"].update({k: str(v) for k, v in raw["models"].items() if k in PROVIDERS and isinstance(v, str)})
    if raw.get("effort") in EFFORTS:
        out["effort"] = raw["effort"]
    out["strict"] = bool(raw.get("strict", False))
    out["viewport_image"] = bool(raw.get("viewport_image", False))
    out["keys"] = {k: str(v) for k, v in (raw.get("keys") or {}).items() if k in PROVIDERS and isinstance(v, str) and v.strip()}
    return out


def save_patch(patch: Dict[str, Any]) -> Dict[str, Any]:
    """Apply ``{provider, model, models{provider: id}, effort, strict, viewport_image, keys{provider: key | ""}}``.
    An empty string key removes the saved key. Returns ``public_view()``. Raises ValueError on a bad value."""
    if not isinstance(patch, dict):
        raise ValueError("settings must be an object")
    with _LOCK:
        cur = load()
        keys = dict(cur["keys"])
        if "provider" in patch:
            if patch["provider"] not in PROVIDERS:
                raise ValueError(f"provider must be one of {', '.join(PROVIDERS)}")
            cur["provider"] = patch["provider"]
        if isinstance(patch.get("models"), dict):
            for p, m in patch["models"].items():
                if p in PROVIDERS:
                    cur["models"][p] = str(m or "").strip()[:120]
        if "model" in patch:
            cur["models"][cur["provider"]] = str(patch["model"] or "").strip()[:120]
        if "effort" in patch:
            if patch["effort"] not in EFFORTS:
                raise ValueError(f"effort must be one of {', '.join(EFFORTS)}")
            cur["effort"] = patch["effort"]
        for flag in ("strict", "viewport_image"):
            if flag in patch:
                cur[flag] = bool(patch[flag])
        if isinstance(patch.get("keys"), dict):
            for p, k in patch["keys"].items():
                if p not in PROVIDERS:
                    raise ValueError(f"unknown provider {p!r}")
                k = str(k or "").strip()
                if k:
                    if len(k) < 8 or any(c.isspace() for c in k):
                        raise ValueError(f"the {p} API key looks malformed (too short or contains spaces)")
                    keys[p] = k
                else:
                    keys.pop(p, None)
        _write({"provider": cur["provider"], "models": cur["models"], "effort": cur["effort"], "strict": cur["strict"],
                "viewport_image": cur["viewport_image"], "keys": keys})
    return public_view()


def key_for(provider: str) -> Optional[str]:
    """The API key for a provider: the saved one, else the environment's; None when neither is set."""
    saved = load()["keys"].get(provider)
    if saved:
        return saved
    for env in ENV_KEYS.get(provider, ()):
        v = (os.environ.get(env) or "").strip()
        if v:
            return v
    return None


def key_status(provider: str) -> Dict[str, Any]:
    saved = load()["keys"].get(provider)
    if saved:
        return {"set": True, "last4": saved[-4:], "source": "saved"}
    for env in ENV_KEYS.get(provider, ()):
        v = (os.environ.get(env) or "").strip()
        if v:
            return {"set": True, "last4": v[-4:], "source": f"env:{env}"}
    return {"set": False, "last4": None, "source": None}


def all_keys() -> List[str]:
    keys = list(load()["keys"].values())
    for p, envs in ENV_KEYS.items():
        for env in envs:
            v = (os.environ.get(env) or "").strip()
            if v:
                keys.append(v)
    return keys


def scrub(text: Any) -> str:
    """``text`` with every known API key replaced by [REDACTED]."""
    s = str(text)
    for k in all_keys():
        if k and k in s:
            s = s.replace(k, "[REDACTED]")
    return s


def public_view() -> Dict[str, Any]:
    """Settings safe to send to the browser: no key material beyond the last four characters."""
    cur = load()
    return {"provider": cur["provider"], "models": cur["models"], "effort": cur["effort"], "strict": cur["strict"],
            "viewport_image": cur["viewport_image"], "providers": list(PROVIDERS), "efforts": list(EFFORTS),
            "keys": {p: key_status(p) for p in PROVIDERS}}
