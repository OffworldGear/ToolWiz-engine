"""Flask blueprint for the setup advisor (docs/SETUP_ADVISOR.md).

``POST /api/setup_advisor``        audit a Fusion setup snapshot against ToolWiz (optional LLM narrative, numeric-guarded)
``GET  /api/setup_advisor/last``   the latest result, kept in memory
``POST /api/setup_advisor/apply``  enqueue ``apply_operation_parameters`` for ToolWiz-recommended values only

Bad input returns 400 ``{"success": false, "error": ...}``. The ``X-ToolWiz-Client`` header is required (app CSRF guard).
"""
from __future__ import annotations

from flask import Blueprint, jsonify, request

import fusion_bridge
import setup_advisor

bp = Blueprint("setup_advisor", __name__)


def _bad(msg: str, code: int = 400, **extra):
    return jsonify({"success": False, "error": msg, **extra}), code


def _num(body: dict, key: str, default=None):
    v = body.get(key)
    if v is None or v == "":
        return default
    if isinstance(v, bool):
        raise ValueError(f"'{key}' must be a number")
    try:
        f = float(v)
    except (TypeError, ValueError):
        raise ValueError(f"'{key}' must be a number") from None
    if f != f or f in (float("inf"), float("-inf")):
        raise ValueError(f"'{key}' must be a finite number")
    return f


@bp.route("/api/setup_advisor", methods=["POST"])
def setup_advisor_run():
    """Body: ``{setup, family, alloy, aggressiveness, runout, model, use_llm, strategies, apiKey, assumptions}``.

    ``setup`` is the add-in's snapshot; omit it (or send ``from_bridge: true``) to use the live state the add-in last
    pushed to ``/api/fusion_bridge/state``. ``aggressiveness`` is a fraction (0.5) or a percentage (50)."""
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _bad("JSON object body required")
    try:
        import app as A
        setup = body.get("setup")
        if setup is None or body.get("from_bridge"):
            live = fusion_bridge.get_live_state()
            if not live.get("connected"):
                return _bad("No 'setup' in the request and the Fusion add-in has not pushed a setup snapshot to the bridge.")
            setup = {"document": live.get("document"), "ops": live.get("ops")}
        limits = A.machine_limits()
        ro = _num(body, "runout", limits["runout"])
        out = setup_advisor.advise(
            setup, family=(body.get("family") or None), alloy=body.get("alloy"),
            aggressiveness=_num(body, "aggressiveness", 0.5), runout=ro, model=A._request_model(body),
            physics=A.physics, machine_profile=A.active_machine(), use_llm=bool(body.get("use_llm")),
            strategies=body.get("strategies", True) is not False, api_key=(body.get("apiKey") or None),
            assumptions=body.get("assumptions"))
    except ValueError as e:
        return _bad(str(e))
    except Exception as e:
        import app as A
        return A._api_error(e)
    return jsonify(out)


@bp.route("/api/setup_advisor/last", methods=["GET"])
def setup_advisor_last():
    """The latest advisor result (404 until one has been computed)."""
    res = setup_advisor.get_last()
    if res is None:
        return _bad("No advisor result yet; POST /api/setup_advisor first.", 404)
    return jsonify(res)


@bp.route("/api/setup_advisor/apply", methods=["POST"])
def setup_advisor_apply():
    """Body: ``{op_id, params: {Fusion parameter: expression}, reason, wait}``.

    Every parameter must be on the allow-list and every value must equal a ToolWiz-recommended value of the last advisor
    result for that op; otherwise 400 with ``rejected``. On success the bridge action ``apply_operation_parameters`` is
    queued (``wait`` seconds, default 0, to block for the add-in's confirmed result)."""
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _bad("JSON object body required")
    op_id = str(body.get("op_id") or "").strip()
    if not op_id:
        return _bad("'op_id' is required")
    chk = setup_advisor.validate_apply(op_id, body.get("params"))
    if not chk["ok"]:
        return _bad(chk["error"] or "invalid parameters", 400, rejected=chk["rejected"])
    try:
        wait = float(body.get("wait") or 0.0)
    except (TypeError, ValueError):
        return _bad("'wait' must be a number of seconds")
    last = setup_advisor.get_last() or {}
    res = fusion_bridge.submit_command("apply_operation_parameters", {
        "op_id": op_id, "params": chk["accepted"], "reason": str(body.get("reason") or "ToolWiz setup advisor recommendation"),
        "advisor_generated_at": last.get("generated_at")}, wait=min(max(wait, 0.0), 120.0))
    res["accepted"] = chk["accepted"]
    return jsonify(res), (200 if res.get("success") else 502)
