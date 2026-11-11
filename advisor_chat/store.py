"""Conversations saved locally under ``data/advisor_chats/<id>.json`` (git-ignored). No API key is ever written here."""
from __future__ import annotations

import json
import os
import re
import tempfile
import threading
import time
import uuid
from typing import Any, Dict, List, Optional

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
_ID = re.compile(r"^[a-f0-9]{12}$")
_LOCKS: Dict[str, threading.Lock] = {}
_LOCKS_GUARD = threading.Lock()


def chats_dir() -> str:
    return os.environ.get("TOOLWIZ_ADVISOR_CHATS_DIR") or os.path.join(ROOT, "data", "advisor_chats")


def valid_id(cid: str) -> bool:
    return bool(_ID.match(str(cid or "")))


def lock_for(cid: str) -> threading.Lock:
    with _LOCKS_GUARD:
        return _LOCKS.setdefault(cid, threading.Lock())


def new_conversation(provider: str, model: str, effort: str) -> Dict[str, Any]:
    now = time.strftime("%Y-%m-%dT%H:%M:%S")
    return {"id": uuid.uuid4().hex[:12], "title": "New chat", "created": now, "updated": now, "provider": provider, "model": model,
            "effort": effort, "assumptions": [], "proposals": [], "messages": [], "pending_notes": []}


def _persistable(conv: Dict[str, Any]) -> Dict[str, Any]:
    """The conversation with screenshot bytes replaced by a marker (they are large and not needed on disk)."""
    out = json.loads(json.dumps(conv, default=str))
    for m in out.get("messages", []):
        for im in m.get("images") or []:
            im["data"] = None
        for r in m.get("results") or []:
            if r.get("image"):
                r["image"] = {"media_type": r["image"].get("media_type"), "data": None}
    return out


def save(conv: Dict[str, Any]) -> None:
    if not valid_id(conv.get("id")):
        raise ValueError("bad conversation id")
    conv["updated"] = time.strftime("%Y-%m-%dT%H:%M:%S")
    d = chats_dir()
    os.makedirs(d, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix=".chat.", dir=d)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            json.dump(_persistable(conv), fh, indent=1)
        os.replace(tmp, os.path.join(d, conv["id"] + ".json"))
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)


def load(cid: str) -> Optional[Dict[str, Any]]:
    if not valid_id(cid):
        return None
    try:
        with open(os.path.join(chats_dir(), cid + ".json"), encoding="utf-8") as fh:
            c = json.load(fh)
        return c if isinstance(c, dict) else None
    except (OSError, ValueError):
        return None


def delete(cid: str) -> bool:
    if not valid_id(cid):
        return False
    try:
        os.unlink(os.path.join(chats_dir(), cid + ".json"))
        return True
    except OSError:
        return False


def list_all() -> List[Dict[str, Any]]:
    d = chats_dir()
    out = []
    try:
        names = os.listdir(d)
    except OSError:
        return out
    for n in names:
        cid = n[:-5]
        if n.endswith(".json") and valid_id(cid):
            c = load(cid)
            if c:
                out.append({"id": cid, "title": c.get("title"), "updated": c.get("updated"), "provider": c.get("provider"),
                            "model": c.get("model"), "messages": len(c.get("messages") or [])})
    return sorted(out, key=lambda c: c.get("updated") or "", reverse=True)


def public_view(conv: Dict[str, Any]) -> Dict[str, Any]:
    """The conversation for the browser: provider-native content (``raw``, which holds thinking blocks) and screenshot bytes removed."""
    out = {k: v for k, v in conv.items() if k not in ("messages", "pending_notes")}
    msgs = []
    for m in conv.get("messages", []):
        m = {k: v for k, v in m.items() if k != "raw"}
        if m.get("images"):
            m["images"] = [{"media_type": i.get("media_type"), "has_data": bool(i.get("data"))} for i in m["images"]]
        if m.get("results"):
            m["results"] = [dict({k: v for k, v in r.items() if k != "image"}, has_image=bool(r.get("image"))) for r in m["results"]]
        msgs.append(m)
    out["messages"] = msgs
    return out
