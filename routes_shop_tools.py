"""Flask blueprint: ``GET /api/shop_tools`` (read-only list of the shop's T-slot / keyseat cutters).

Returns ``{"success": true, "tools": [{id, name, planned, diameter_mm, kerf_mm, provisional, ...}]}`` from
``data/shop_tools.json``. The Fusion add-in's Strategy Planner lists these as T-slot candidates (`{"id": ...}` in
``/api/strategy/compare``). Nothing is modified.
"""
from __future__ import annotations

import json
import os

from flask import Blueprint, jsonify

bp = Blueprint("shop_tools", __name__)
_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "shop_tools.json")


@bp.route("/api/shop_tools", methods=["GET"])
def shop_tools():
    """The shop's T-slot cutters (id, name, planned flag, size and provisional-geometry fields)."""
    try:
        with open(_PATH, "r", encoding="utf-8") as f:
            data = json.load(f)
    except (OSError, ValueError) as ex:
        return jsonify({"success": False, "error": f"shop tool list unavailable: {ex}"}), 500
    return jsonify({"success": True, "tools": data.get("tools", [])})
