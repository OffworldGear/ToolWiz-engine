"""Flask blueprint: ``POST /api/strategy/compare`` (strategy_planner.compare).

Body and result: docs/V3_IMPLEMENTATION_PLAN.md and docs/STRATEGY_PLANNER.md. Lengths are inches. Bad input
returns 400 with ``{"success": false, "error": "<message>"}``. The header ``X-ToolWiz-Client`` is required by the
app's CSRF guard.
"""
from __future__ import annotations

from flask import Blueprint, jsonify, request

import strategy_planner

bp = Blueprint("strategy", __name__)


@bp.route("/api/strategy/compare", methods=["POST"])
def strategy_compare():
    """Compare machining strategies / T-slot cutters for a feature; see ``strategy_planner.compare``."""
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return jsonify({"success": False, "error": "JSON object body required"}), 400
    try:
        import app as _app   # late import: app registers this blueprint
        out = strategy_planner.compare(body, physics=_app.physics, machine_profile=_app.active_machine())
    except ValueError as e:
        return jsonify({"success": False, "error": str(e)}), 400
    except KeyError as e:
        return jsonify({"success": False, "error": f"unknown or missing value: {e}"}), 400
    out["success"] = True
    return jsonify(out)
