"""Read-only GET endpoints that only the web UI needs.

  GET /api/shop_tools   the owner's T-slot / keyseat cutters from data/shop_tools.json (lengths in millimetres,
                        `provisional` lists assumed fields, `planned` marks cutters not yet bought).
"""
from __future__ import annotations

import json
import os

from flask import Blueprint, jsonify

bp = Blueprint("ui_support", __name__)
SHOP_TOOLS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "shop_tools.json")


@bp.route("/api/shop_tools", methods=["GET"])
def shop_tools():
    """Return ``{"success": true, "tools": [...]}`` from data/shop_tools.json (empty list when the file is absent)."""
    try:
        with open(SHOP_TOOLS_PATH, "r", encoding="utf-8") as f:
            tools = json.load(f).get("tools", [])
    except (OSError, ValueError):
        tools = []
    return jsonify({"success": True, "tools": tools})
