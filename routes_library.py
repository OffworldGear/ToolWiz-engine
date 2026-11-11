"""Flask blueprint for library tools: ``POST /api/twin/audit``.

Body (all optional): ``{"library": {...} | "tools": [...], "material": "Titanium Alloy", "aggressiveness": 50,
"runout": 0.0002, "model": "v1" | "v2"}``. ``model`` defaults to the cutting model ``/api/calculate`` would use. A Fusion library JSON (``{"tools": [...]}``) may also be posted directly as the body. With no
library in the body the working library is audited. Returns ``{"success": true, "summary", "findings", "tools"}``
(see ``library_audit.audit_library``); nothing is modified.
"""
from __future__ import annotations

from flask import Blueprint, jsonify, request

import library_audit
import v2_bridge

bp = Blueprint("library", __name__)


def _request_model(body: dict) -> str:
    """Cutting model for the audit, resolved as ``/api/calculate`` does (app._request_model): the request's
    ``model``, else the saved setting, else TOOLWIZ_MODEL, else v1. Flask's test client (host "localhost") ignores
    the saved setting, so a model saved from the web page cannot change what the test suite checks."""
    use_saved = request.host != "localhost"
    return v2_bridge.resolve_model(body.get("model"), use_saved=use_saved)[0]


@bp.route("/api/twin/audit", methods=["POST"])
def twin_audit():
    """Audit a Fusion tool library against ToolWiz (STOP / CAUTION / INFO per tool and preset)."""
    import app as A      # late import: app registers this blueprint
    try:
        body = request.get_json(silent=True)
        body = body if isinstance(body, dict) else {}
        lib = body.get("library") if isinstance(body.get("library"), dict) else None
        if lib is None and isinstance(body.get("tools"), list):
            lib = body
        if lib is None:
            lib = A.bm.load_working_library()
            if not lib or not lib.get("tools"):
                return jsonify({"success": False, "error": "No library in the request and no working library found."}), 400
        aggr = float(body.get("aggressiveness", 50.0))
        limits = A.machine_limits()
        runout = body.get("runout")
        report = library_audit.audit_library(
            lib, A.physics, material=(body.get("material") or None),
            max_rpm=float(body.get("maxRpm") or limits["max_rpm"]), max_hp=float(body.get("maxHp") or limits["max_hp"]),
            runout_in=float(runout) if runout not in (None, "") else float(limits["runout"]),
            aggressiveness=(aggr / 100.0 if aggr > 1.0 else aggr), model=_request_model(body),
            machine_profile=A.active_machine())
        return jsonify({"success": True, **report})
    except Exception as e:
        return A._api_error(e)
