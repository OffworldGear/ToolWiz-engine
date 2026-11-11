"""Flask blueprint: ``POST /api/runout_sensitivity`` (docs/RUNOUT_SENSITIVITY.md).

Body: the same tool / material / operation fields as ``/api/calculate`` (or ``fusion_tool``), plus
``aggressiveness`` (0-100), optional ``runouts`` (inches; default 0 to 0.0005), optional ``model`` (default
"v2") and optional ``current_runout`` (inches; default the machine's runout setting). Every runout is one
``/api/calculate`` computation, so the numbers are exactly what the Speeds & Feeds page shows for that runout.
"""
from __future__ import annotations


from flask import Blueprint, current_app, jsonify, request

import runout_sensitivity

bp = Blueprint("runout", __name__)


def _call_view(name: str, method: str, body=None):
    with current_app.test_request_context("/api/_internal", method=method, json=body):
        rv = current_app.view_functions[name]()
    resp, status = (rv if isinstance(rv, tuple) else (rv, 200))
    return resp.get_json(silent=True) or {}, status


@bp.route("/api/runout_sensitivity", methods=["POST"])
def runout_sensitivity_run():
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return jsonify({"success": False, "error": "JSON object body required"}), 400
    body = dict(body)
    runouts = body.pop("runouts", None)
    current = body.pop("current_runout", None)
    if runouts is not None and (not isinstance(runouts, list) or any(
            isinstance(r, bool) or not isinstance(r, (int, float)) for r in runouts)):
        return jsonify({"success": False, "error": "runouts must be a list of numbers (inches)"}), 400
    body.setdefault("model", "v2")
    try:
        if current not in (None, ""):
            current = float(current)
        if body.get("runout") in (None, ""):
            body["runout"] = _call_view("api_machine_limits", "GET")[0].get("runout", 0.0002)

        def run(b):
            data, status = _call_view("calculate", "POST", b)
            if status != 200 or not data.get("success"):
                raise RuntimeError(data.get("error") or f"calculation failed ({status})")
            return data

        out = runout_sensitivity.analyze(run, body, runouts, current)
    except (ValueError, TypeError) as ex:
        return jsonify({"success": False, "error": str(ex)}), 400
    except RuntimeError as ex:
        return jsonify({"success": False, "error": str(ex)}), 422
    return jsonify({"success": True, "model": body["model"], "aggressiveness": body.get("aggressiveness", 50),
                    "diameter_in": body.get("diameter"), **out})
