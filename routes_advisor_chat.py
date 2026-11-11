"""Flask blueprint for the Advisor Chat (docs/ADVISOR_CHAT.md). All state-changing calls need the ``X-ToolWiz-Client`` header.

``GET/POST /api/advisor_chat/settings``                         provider, model, effort, strict mode, keys (keys are write-only)
``GET  /api/advisor_chat/models?provider=``                     the model picker list
``GET  /api/advisor_chat/status``                               live Fusion setup status
``GET/POST /api/advisor_chat/conversations``                    list / create (``start_from_advisor`` runs the Setup Advisor first)
``GET/DELETE /api/advisor_chat/conversations/<id>``
``POST /api/advisor_chat/conversations/<id>/messages``          send a message (runs the model <-> tools loop)
``POST/DELETE .../assumptions[/<aid>]``                          add / remove an assumption chip
``GET  .../proposals/<pid>``  ``POST .../proposals/<pid>/approve|decline``
"""
from __future__ import annotations

import time
from typing import Any, Dict

from flask import Blueprint, jsonify, request

import fusion_bridge
import setup_advisor
from advisor_chat import assumptions as asm
from advisor_chat import settings as aisettings
from advisor_chat import store
from advisor_chat.engine import ChatEngine
from advisor_chat.providers import ProviderError, get_provider

bp = Blueprint("advisor_chat", __name__)
_engine_factory = ChatEngine          # tests replace this with a factory that returns an engine over a mocked provider


def get_engine() -> ChatEngine:
    return _engine_factory()


def _bad(msg: str, code: int = 400, **extra):
    return jsonify({"success": False, "error": aisettings.scrub(msg), **extra}), code


def _body() -> Dict[str, Any]:
    d = request.get_json(silent=True)
    return d if isinstance(d, dict) else {}


def _conv_or_404(cid: str):
    c = store.load(cid)
    return c


def _view(conv: Dict[str, Any], **extra):
    return jsonify({"success": True, "conversation": store.public_view(conv), **extra})


# ---- settings / models / status --------------------------------------------------------------------------------------

@bp.route("/api/advisor_chat/settings", methods=["GET", "POST"])
def chat_settings():
    if request.method == "POST":
        try:
            view = aisettings.save_patch(_body())
        except ValueError as ex:
            return _bad(str(ex))
        return jsonify({"success": True, "settings": view})
    return jsonify({"success": True, "settings": aisettings.public_view()})


@bp.route("/api/advisor_chat/models", methods=["GET"])
def chat_models():
    pid = request.args.get("provider") or aisettings.load()["provider"]
    try:
        provider = get_provider(pid)
    except ProviderError as ex:
        return _bad(str(ex))
    res = provider.list_models(aisettings.key_for(pid) or "")
    st = aisettings.load()
    return jsonify({"success": True, "provider": pid, "models": [m.as_dict() for m in res["models"]], "source": res["source"],
                    "error": aisettings.scrub(res["error"]) if res["error"] else None,
                    "selected": st["models"].get(pid) or provider.default_model()})


@bp.route("/api/advisor_chat/status", methods=["GET"])
def chat_status():
    live = fusion_bridge.get_live_state()
    age = (time.time() - live["updated_at"]) if live.get("updated_at") else None
    return jsonify({"success": True, "connected": bool(live.get("connected")), "document": live.get("document"),
                    "operations": len(live.get("ops") or []), "snapshot_age_seconds": round(age) if age is not None else None,
                    "stale": (age is not None and age > 120), "tool_count": live.get("tool_count")})


# ---- conversations ----------------------------------------------------------------------------------------------------

@bp.route("/api/advisor_chat/conversations", methods=["GET", "POST"])
def conversations():
    if request.method == "GET":
        return jsonify({"success": True, "conversations": store.list_all()})
    body = _body()
    st = aisettings.load()
    provider = body.get("provider") if body.get("provider") in aisettings.PROVIDERS else st["provider"]
    model = str(body.get("model") or st["models"].get(provider) or "").strip()
    conv = store.new_conversation(provider, model, body.get("effort") if body.get("effort") in aisettings.EFFORTS else st["effort"])
    try:
        for a in body.get("assumptions") or []:
            asm.add(conv["assumptions"], a)
    except ValueError as ex:
        return _bad(str(ex))
    extra = {}
    if body.get("start_from_advisor"):
        args = {k: body[k] for k in ("family", "alloy", "aggressiveness", "runout_in") if body.get(k) not in (None, "")}
        res = get_engine().start_from_advisor(conv, args)
        extra["advisor"] = {"ok": res["ok"], "error": res["error"]}
    store.save(conv)
    return _view(conv, **extra)


@bp.route("/api/advisor_chat/conversations/<cid>", methods=["GET", "DELETE"])
def conversation(cid):
    conv = _conv_or_404(cid)
    if conv is None:
        return _bad("conversation not found", 404)
    if request.method == "DELETE":
        store.delete(cid)
        return jsonify({"success": True})
    return _view(conv)


@bp.route("/api/advisor_chat/conversations/<cid>/messages", methods=["POST"])
def post_message(cid):
    conv = _conv_or_404(cid)
    if conv is None:
        return _bad("conversation not found", 404)
    body = _body()
    lock = store.lock_for(cid)
    if not lock.acquire(blocking=False):
        return _bad("The assistant is still answering the previous message.", 409)
    try:
        for k in ("provider", "model", "effort"):          # the pickers apply to the next turn
            if body.get(k):
                if k == "provider" and body[k] not in aisettings.PROVIDERS:
                    return _bad("unknown provider")
                if k == "effort" and body[k] not in aisettings.EFFORTS:
                    return _bad("unknown effort")
                conv[k] = str(body[k])
        if body.get("provider") and not body.get("model"):
            conv["model"] = aisettings.load()["models"].get(conv["provider"], "")
        res = get_engine().send(conv, str(body.get("message") or ""))
        store.save(conv)
    finally:
        lock.release()
    return _view(conv, ok=res["ok"], error=res["error"])


# ---- assumption chips -------------------------------------------------------------------------------------------------

@bp.route("/api/advisor_chat/conversations/<cid>/assumptions", methods=["POST"])
def add_assumption(cid):
    conv = _conv_or_404(cid)
    if conv is None:
        return _bad("conversation not found", 404)
    body = _body()
    try:
        rec = asm.add(conv["assumptions"], {"key": body.get("key"), "value": body.get("value"), "scope": body.get("scope"),
                                            "unit": body.get("unit"), **({"override": body["override"]} if "override" in body else {})})
    except ValueError as ex:
        return _bad(str(ex))
    conv["pending_notes"].append(f"The owner added the assumption {rec['key']} = {rec['value']} for "
                                 f"{setup_advisor.describe_scope(rec['scope'])} (it is applied to every run from now on).")
    store.save(conv)
    return _view(conv)


@bp.route("/api/advisor_chat/conversations/<cid>/assumptions/<aid>", methods=["DELETE"])
def remove_assumption(cid, aid):
    conv = _conv_or_404(cid)
    if conv is None:
        return _bad("conversation not found", 404)
    gone = asm.remove(conv["assumptions"], rec_id=aid)
    if not gone:
        return _bad("assumption not found", 404)
    conv["pending_notes"].append(f"The owner removed the assumption {gone[0]['key']} = {gone[0]['value']}: it no longer applies to runs. "
                                 "Re-run the advisor to see the effect.")
    store.save(conv)
    return _view(conv)


# ---- proposals ------------------------------------------------------------------------------------------------------

def _find_proposal(conv, pid):
    return next((p for p in conv["proposals"] if p["id"] == pid), None)


def _settle(prop: Dict[str, Any], res: Dict[str, Any]) -> None:
    """Record the add-in's result on a proposal."""
    prop["result"] = {k: res.get(k) for k in ("ok", "success", "applied", "skipped", "error", "operation", "tool")}
    if res.get("ok") or (res.get("success") and res.get("applied")):
        prop["status"] = "applied"
    elif "declined" in str(res.get("error") or ""):
        prop["status"] = "declined_in_fusion"
    else:
        prop["status"] = "failed"


@bp.route("/api/advisor_chat/conversations/<cid>/proposals/<pid>", methods=["GET"])
def proposal_status(cid, pid):
    conv = _conv_or_404(cid)
    prop = _find_proposal(conv, pid) if conv else None
    if prop is None:
        return _bad("proposal not found", 404)
    if prop["status"] == "queued" and prop.get("request_id"):
        res = fusion_bridge.peek_result(prop["request_id"])
        if res is not None:
            _settle(prop, res)
            store.save(conv)
    return jsonify({"success": True, "proposal": prop})


@bp.route("/api/advisor_chat/conversations/<cid>/proposals/<pid>/approve", methods=["POST"])
def proposal_approve(cid, pid):
    """Queue the change for the add-in. Fusion then asks the owner to confirm; nothing is written before that."""
    conv = _conv_or_404(cid)
    prop = _find_proposal(conv, pid) if conv else None
    if prop is None:
        return _bad("proposal not found", 404)
    if prop["status"] != "pending":
        return _bad(f"this proposal is already {prop['status']}", 409)
    pl = prop["payload"]
    if prop["kind"] == "operation_parameters":
        chk = setup_advisor.validate_apply(pl["op_id"], pl["params"])     # against the CURRENT last advisor result
        if not chk["ok"]:
            prop["status"], prop["result"] = "rejected", {"ok": False, "error": chk["error"], "rejected": chk["rejected"]}
            store.save(conv)
            return _bad(chk["error"] or "ToolWiz no longer recommends these values", 400, proposal=prop)
        last = setup_advisor.get_last() or {}
        res = fusion_bridge.submit_command("apply_operation_parameters", {
            "op_id": pl["op_id"], "params": chk["accepted"], "reason": prop["reason"] or "ToolWiz Advisor Chat",
            "advisor_generated_at": last.get("generated_at")})
    else:
        err = fusion_bridge.check_tool_fields(pl)
        if err:
            prop["status"], prop["result"] = "rejected", {"ok": False, "error": err}
            store.save(conv)
            return _bad(err, 400, proposal=prop)
        res = fusion_bridge.submit_command("update_tool_fields", dict(pl, reason=prop["reason"] or "ToolWiz Advisor Chat"))
    if res.get("queued") and res.get("request_id"):
        prop["status"], prop["request_id"] = "queued", res["request_id"]
    elif res.get("success") is False and "ok" not in res:
        prop["status"], prop["result"] = "failed", {"ok": False, "error": res.get("error")}
    else:
        _settle(prop, res)               # a direct executor answered at once
    store.save(conv)
    return jsonify({"success": True, "proposal": prop})


@bp.route("/api/advisor_chat/conversations/<cid>/proposals/<pid>/decline", methods=["POST"])
def proposal_decline(cid, pid):
    conv = _conv_or_404(cid)
    prop = _find_proposal(conv, pid) if conv else None
    if prop is None:
        return _bad("proposal not found", 404)
    if prop["status"] != "pending":
        return _bad(f"this proposal is already {prop['status']}", 409)
    prop["status"], prop["result"] = "declined", {"ok": False, "error": "declined by the owner in the chat"}
    store.save(conv)
    return jsonify({"success": True, "proposal": prop})
