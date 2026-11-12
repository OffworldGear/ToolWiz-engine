"""Flask blueprint: ``POST /api/advice/alternative_tools`` (tool_recommender.recommend, docs/TOOL_RECOMMENDER.md).

Body: the cut (family, alloy, operation, aggressiveness, runout, model), the current tool (diameter, flutes, flute_length, shank_diameter,
stickout, corner_radius, coating, brand), optional feature limits (max_diameter_in, min_reach_in, full_slot, cut_depth, cut_width,
toolpath_length_in, volume_in3), optional finish targets (finish_mode, target_ra, wall_tolerance) and ``sources`` (["library", "catalog"]).
The web calculator's own field names (fluteLength, cornerRadius, cutDepth, ...) are accepted too. Lengths are inches. Bad input returns
400 ``{"success": false, "error": ...}``. The header ``X-ToolWiz-Client`` is required by the app's CSRF guard.
"""
from __future__ import annotations

from flask import Blueprint, jsonify, request

import tool_recommender

bp = Blueprint("tool_recommender", __name__)


@bp.route("/api/advice/alternative_tools", methods=["POST"])
def alternative_tools():
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return jsonify({"success": False, "error": "JSON object body required"}), 400
    try:
        import app as A
        body = dict(body)
        body["model"] = A._request_model(body)
        limits = A.machine_limits()
        if body.get("runout") in (None, "") and body.get("runout_in") in (None, "") and limits.get("runout_set"):
            body["runout"] = limits.get("runout")          # else the recommender uses the per-tool default (by diameter)
        for src, dst in (("max_rpm", "maxRpm"), ("max_hp", "maxHp")):
            if body.get(src) in (None, "") and body.get(dst) in (None, ""):
                body[src] = limits.get(src)
        out = tool_recommender.recommend(body, physics=A.physics, machine_profile=A.active_machine())
    except ValueError as e:
        return jsonify({"success": False, "error": str(e)}), 400
    except Exception as e:
        import app as A
        return A._api_error(e)
    return jsonify(out)
