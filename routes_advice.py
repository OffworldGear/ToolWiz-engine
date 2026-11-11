"""Flask blueprint for tooling advice: ``POST /api/advice/holder`` and ``POST /api/advice/tools``.

Both endpoints take JSON, call the pure functions in ``toolwiz_common.tooling_advisor`` and return
400 with ``{"success": false, "error": "<message>"}`` on bad input.  Lengths are inches.
"""
from __future__ import annotations

from flask import Blueprint, jsonify, request

from toolwiz_common import tooling_advisor as adv

bp = Blueprint("advice", __name__)


def _bad(msg: str):
    return jsonify({"success": False, "error": msg}), 400


def _num(body: dict, key: str, *, required: bool = False, default=None, positive: bool = False):
    """Read a finite number from ``body[key]``; raises ValueError with a clear message."""
    v = body.get(key)
    if v is None or v == "":
        if required:
            raise ValueError(f"'{key}' is required")
        return default
    if isinstance(v, bool):
        raise ValueError(f"'{key}' must be a number")
    try:
        f = float(v)
    except (TypeError, ValueError):
        raise ValueError(f"'{key}' must be a number") from None
    if f != f or f in (float("inf"), float("-inf")):
        raise ValueError(f"'{key}' must be a finite number")
    if positive and f <= 0:
        raise ValueError(f"'{key}' must be > 0")
    return f


@bp.route("/api/advice/holder", methods=["POST"])
def advice_holder():
    """Body: diameter, runout_in, fz_in, rpm, operation, stickout, flutes, taper (+ optional max_rpm, sfm_target)."""
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _bad("JSON object body required")
    try:
        d = _num(body, "diameter", required=True, positive=True)
        fz = _num(body, "fz_in", required=True, positive=True)
        flutes = _num(body, "flutes", default=2, positive=True)
        if flutes != int(flutes):
            raise ValueError("'flutes' must be a whole number")
        runout = _num(body, "runout_in", default=0.0)
        if runout < 0:
            raise ValueError("'runout_in' must be >= 0")
        rpm = _num(body, "rpm", default=0.0)
        stick = _num(body, "stickout", positive=True)
        max_rpm = _num(body, "max_rpm", default=16000.0, positive=True)
        sfm = _num(body, "sfm_target", positive=True)
        operation = str(body.get("operation") or "side")
        taper = str(body.get("taper") or "BT30")
        out = adv.holder_advice(d, runout, fz, int(flutes), rpm, operation, stick,
                                max_rpm=max_rpm, sfm_target=sfm, taper=taper)
    except ValueError as e:
        return _bad(str(e))
    return jsonify(out)


@bp.route("/api/advice/tools", methods=["POST"])
def advice_tools():
    """Body: family, diameter, operation, flutes?, coating?  Returns ``{"tools": [...]}``."""
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _bad("JSON object body required")
    try:
        d = _num(body, "diameter", required=True, positive=True)
        family = str(body.get("family") or "").strip()
        if not family:
            raise ValueError("'family' is required")
        operation = str(body.get("operation") or "").strip()
        if not operation:
            raise ValueError("'operation' is required")
        fl = _num(body, "flutes", positive=True)
        coating = body.get("coating")
        out = adv.tool_advice(family, d, operation, int(fl) if fl else None,
                              str(coating) if coating else None)
    except ValueError as e:
        return _bad(str(e))
    return jsonify({"tools": out})
