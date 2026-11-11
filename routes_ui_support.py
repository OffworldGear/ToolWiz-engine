"""Read-only GET endpoints that only the web UI needs.

  GET /api/shop_tools   the owner's T-slot / keyseat cutters from data/shop_tools.json (lengths in millimetres,
                        `provisional` lists assumed fields, `planned` marks cutters not yet bought).
  GET /api/shop_tools?library=<name|working>   the same list with the slot cutters of that Fusion library merged in
                        (preview, nothing is written; `library_added` lists the library-derived ids).
  POST /api/shop_tools/refresh {"library": "<name|working>"}   merge and save data/shop_tools.json
                        (shop_tool_builder; needs the X-ToolWiz-Client header).
"""
from __future__ import annotations

import json
import os

from flask import Blueprint, jsonify, request

bp = Blueprint("ui_support", __name__)
SHOP_TOOLS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "shop_tools.json")


@bp.route("/api/shop_tools", methods=["GET"])
def shop_tools():
    """Return ``{"success": true, "tools": [...]}`` from data/shop_tools.json (empty list when the file is absent)."""
    lib = (request.args.get("library") or "").strip()
    if lib:
        import shop_tool_builder as stb
        try:
            r = stb.refresh_shop_tools(lib, write=False)
        except (ValueError, OSError) as e:
            return jsonify({"success": False, "error": str(e)}), 400
        return jsonify({"success": True, "tools": r["tools"], "library": r["library"], "library_added": r["added"], "written": False})
    try:
        with open(SHOP_TOOLS_PATH, "r", encoding="utf-8") as f:
            tools = json.load(f).get("tools", [])
    except (OSError, ValueError):
        tools = []
    return jsonify({"success": True, "tools": tools})


@bp.route("/api/shop_tools/refresh", methods=["POST"])
def shop_tools_refresh():
    """Rebuild the library-derived shop cutters from a Fusion library (``{"library": "<file name>|working"}``) and save them."""
    import shop_tool_builder as stb
    body = request.get_json(silent=True) or {}
    try:
        r = stb.refresh_shop_tools(str(body.get("library") or "working"), write=True)
    except (ValueError, OSError) as e:
        return jsonify({"success": False, "error": str(e)}), 400
    return jsonify({"success": True, "tools": r["tools"], "library": r["library"], "library_added": r["added"], "written": True})
