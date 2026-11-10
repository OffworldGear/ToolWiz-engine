"""ToolWiz Model Context Protocol (MCP) Server.

Exposes both **ToolWiz Physics & Library Tools** and **Live Fusion 360 CAD/CAM Tools**
over standard JSON-RPC 2.0 MCP (``stdio`` transport or HTTP ``/api/mcp``).

Usage (stdio MCP server for Claude Desktop / Antigravity / Cursor):
    python mcp_server.py
"""
from __future__ import annotations

import json
import sys
from typing import Any, Dict, List, Optional

import fusion_bridge
from app import app, physics, active_machine, machine_limits
from pipeline import CutRequest, run_cut
from toolwiz_common import default_shank

MCP_PROTOCOL_VERSION = "2024-11-05"
SERVER_INFO = {
    "name": "toolwiz-fusion-mcp",
    "version": "2.0.0",
}

MCP_TOOLS: List[Dict[str, Any]] = [
    {
        "name": "toolwiz_calculate_cut",
        "description": (
            "Calculate CNC milling/drilling/tapping speeds, feeds, DOC, WOC, deflection, and "
            "B-Rep corner/stickout/thin-wall adjustments using the canonical ToolWiz physics pipeline."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "family": {"type": "string", "description": "Material family (e.g. 'Titanium Alloy', 'Aluminum - Wrought (6061)')"},
                "alloy": {"type": "string", "description": "Specific alloy/condition (e.g. 'Ti-6Al-4V (Grade 5, Annealed)')"},
                "operation": {"type": "string", "description": "Operation strategy (e.g. '3D Adaptive Roughing', 'Roughing', 'Finishing', 'Slotting')"},
                "tool": {"type": "string", "description": "Tool category (default 'Carbide Endmill')"},
                "geometry": {"type": "string", "description": "Cutter geometry ('Square', 'Ball', 'Radiused', 'High Feed', 'Chamfer')"},
                "coating": {"type": "string", "description": "Tool coating ('AlTiN', 'TiAlN', 'Uncoated', 'ZrN', 'Diamond')"},
                "diameter": {"type": "number", "description": "Cutting diameter in inches"},
                "flutes": {"type": "integer", "description": "Number of flutes"},
                "fluteLength": {"type": "number", "description": "Flute length (LCF) in inches"},
                "shankDiameter": {"type": "number", "description": "Shank diameter in inches (defaults to 0.125\" for micro tools < 1/8\")"},
                "stickout": {"type": "number", "description": "Tool stickout from holder in inches"},
                "cornerRadius": {"type": "number", "description": "Corner radius in inches"},
                "aggressiveness": {"type": "number", "description": "Aggressiveness percentage (0-100, default 50)"},
                "model": {"type": "string", "enum": ["v1", "v2"], "description": "Cutting physics model ('v1' or 'v2')"},
                "feature_geometry": {
                    "type": "object",
                    "description": "Optional live B-Rep geometry metrics (feature_depth_in, min_corner_radius_in, min_wall_thickness_in, min_floor_thickness_in)",
                },
            },
            "required": ["family", "diameter"],
        },
    },
    {
        "name": "toolwiz_predict_stock_compensation",
        "description": (
            "Predict cantilever tool deflection, workpiece elastic springback, thin-wall compliance, "
            "and recommended negative/positive radial and axial stock-to-leave for CAM operations."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "family": {"type": "string", "description": "Material family"},
                "alloy": {"type": "string", "description": "Material alloy"},
                "aggressiveness": {"type": "number", "description": "Aggressiveness percentage (0-100, default 50)"},
                "radial_pct": {"type": "number", "description": "Radial compensation strength percentage (25-100, default 100)"},
                "axial_pct": {"type": "number", "description": "Axial compensation strength percentage (25-100, default 100)"},
                "operations": {
                    "type": "array",
                    "description": "List of operations with diameter, flutes, fluteLength, shankDiameter, stickout, strategy, doc, woc, and optional feature_geometry",
                    "items": {"type": "object"},
                },
            },
            "required": ["family", "operations"],
        },
    },
    {
        "name": "toolwiz_search_materials",
        "description": "Search ToolWiz material families and alloys by keyword.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "query": {"type": "string", "description": "Search substring (e.g. 'titanium', '17-4', 'nitronic', '6061')"},
            },
        },
    },
    {
        "name": "fusion_get_setup_summary",
        "description": (
            "Read the active Fusion 360 document's CAM setups, document tool count, and all operations "
            "(tool, preset, RPM, feed, stepdown, stepover) via the main-thread CustomEvent bridge."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {},
        },
    },
    {
        "name": "fusion_inspect_operation",
        "description": (
            "Inspect a specific Fusion 360 CAM operation including its full tool profile, cutting "
            "parameters, and live B-Rep feature geometry (pocket Z-depth, required safe stickout, "
            "minimum internal corner radius, corner engagement spike, and thin-wall/floor thickness)."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "operation": {
                    "type": "string",
                    "description": "Operation name, 'Setup > Operation' path, or 0-based operation index",
                },
            },
            "required": ["operation"],
        },
    },
    {
        "name": "fusion_audit_setup_sequence",
        "description": (
            "Audit an entire Fusion 360 CAM setup sequence for rest-machining gaps, micro-tool shock "
            "loading after larger roughers, stock-to-leave continuity, holder clearance collisions, "
            "tight internal corner spikes, and thin-wall push-off risks."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "setup": {
                    "type": "string",
                    "description": "Optional setup name filter (audits all setups if omitted)",
                },
            },
        },
    },
    {
        "name": "fusion_get_toolpath_status",
        "description": "Check toolpath generation status, validity, warnings, and errors for Fusion 360 CAM operations.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "operation": {
                    "type": "string",
                    "description": "Optional operation name/path filter",
                },
            },
        },
    },
    {
        "name": "fusion_apply_stock_to_leave",
        "description": (
            "Apply audited radial and axial stock-to-leave expressions to a Fusion 360 CAM operation "
            "(recorded in ToolWiz's JSONL audit trail with side-effect detection)."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "operation": {"type": "string", "description": "Target operation name or 'Setup > Operation' path"},
                "radial_stock": {"type": "string", "description": "Radial stock expression with explicit units (e.g. '-0.0008 in' or '-0.020 mm')"},
                "axial_stock": {"type": "string", "description": "Axial stock expression with explicit units (e.g. '0.0000 in' or '-0.012 mm')"},
            },
            "required": ["operation", "radial_stock", "axial_stock"],
        },
    },
    {
        "name": "toolwiz_holistic_oversight",
        "description": (
            "Run a holistic shop-floor oversight review outside of single-operation physics equations: "
            "checks tool-to-material/coating compatibility, assumed shaft taper vs. feature depth wall-rubbing, "
            "chip evacuation, v1/v2 model divergence, B-Rep thin walls/corners, and setup sequence logic."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "family": {"type": "string", "description": "Material family"},
                "alloy": {"type": "string", "description": "Material alloy"},
                "operation": {"type": "string", "description": "Machining operation"},
                "coating": {"type": "string", "description": "Tool coating (e.g. AlTiN, ZrN, Uncoated)"},
                "diameter": {"type": "number", "description": "Tool cutting diameter (in)"},
                "flutes": {"type": "integer", "description": "Flute count"},
                "fluteLength": {"type": "number", "description": "Flute length (in)"},
                "shankDiameter": {"type": "number", "description": "Shank diameter (in)"},
                "stickout": {"type": "number", "description": "Stickout below holder (in)"},
                "cutDepth": {"type": "number", "description": "Axial depth of cut (in)"},
                "cutWidth": {"type": "number", "description": "Radial width of cut (in)"},
                "feature_geometry": {"type": "object", "description": "Optional live B-Rep geometry report"},
                "setup_audit": {"type": "object", "description": "Optional setup sequence audit report"},
                "include_ai_opinion": {"type": "boolean", "description": "Include LLM Master Machinist synthesis if API key is set"},
            },
        },
    },
    {
        "name": "toolwiz_curate_tool_library",
        "description": (
            "Inspect and refine a Fusion 360 tool library (or working library): populates missing shaft taper "
            "segments (to 0.5 mm below the holder), fixes micro-tool shank diameters, and infers coatings/radii."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "tools": {"type": "array", "description": "Array of Fusion 360 tool JSON objects"},
                "use_working_library": {"type": "boolean", "description": "Curate the active working_library.json"},
                "apply_to_working_library": {"type": "boolean", "description": "Save curated changes to working_library.json (with backup)"},
                "fix_micro_shank": {"type": "boolean", "description": "Fix SFDM == DC on tools < 1/8 in"},
                "populate_shaft_taper": {"type": "boolean", "description": "Add explicit shaft.segments taper to 0.5 mm below holder"},
            },
        },
    },
]


def list_mcp_tools() -> List[Dict[str, Any]]:
    """Return the list of registered MCP tool definitions."""
    return list(MCP_TOOLS)


def call_mcp_tool_by_name(name: str, arguments: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """Execute one MCP tool by name and return a structured result dict."""
    args = dict(arguments or {})

    if name == "toolwiz_calculate_cut":
        diameter = float(args.get("diameter", 0.25))
        shank = float(args.get("shankDiameter") or default_shank(diameter))
        flute_len = float(args.get("fluteLength") or diameter * 2.0)
        limits = machine_limits()
        req = CutRequest(
            family=str(args.get("family") or "Aluminum - Wrought (6061)"),
            alloy=str(args.get("alloy") or ""),
            tool=str(args.get("tool") or "Carbide Endmill"),
            geometry=str(args.get("geometry") or "Square"),
            operation=str(args.get("operation") or "Roughing"),
            coating=str(args.get("coating") or "AlTiN"),
            diameter=diameter,
            flutes=int(args.get("flutes", 4)),
            flute_length=flute_len,
            shank_diameter=shank,
            corner_radius=float(args.get("cornerRadius", 0.0)),
            stickout=float(args["stickout"]) if args.get("stickout") is not None else None,
            aggressiveness=float(args.get("aggressiveness", 50.0)) / 100.0,
            max_rpm=float(args.get("maxRpm") or limits["max_rpm"]),
            max_hp=float(args.get("maxHp") or limits["max_hp"]),
            runout=float(args.get("runout") or limits["runout"]),
            cut_depth=float(args["cutDepth"]) if args.get("cutDepth") is not None else None,
            cut_width=float(args["cutWidth"]) if args.get("cutWidth") is not None else None,
            model=args.get("model"),
            machine_profile=active_machine(),
            feature_geometry=args.get("feature_geometry") if isinstance(args.get("feature_geometry"), dict) else None,
        )
        res = run_cut(physics, req)
        return {
            "success": True,
            "model": res.model,
            "rpm": round(res.rpm),
            "feed_ipm": round(res.feed_ipm, 2),
            "corner_feed_ipm": res.corner_feed_ipm,
            "sfm": round(res.sfm, 1),
            "adj_ipt": round(res.adj_ipt, 6),
            "doc_in": round(res.doc, 5),
            "woc_in": round(res.woc, 5),
            "deflection_in": round(res.deflection, 6),
            "springback_in": round(res.springback, 6),
            "total_error_in": round(res.total_error, 6),
            "ramp_angle_deg": round(res.ramp_angle, 2),
            "ramp_feed_ipm": round(res.ramp_feed, 2),
            "plunge_feed_ipm": round(res.plunge_feed, 2),
            "feasible": res.feasible,
            "limited_by": res.limited_by,
            "feature_geometry": res.feature_geometry,
            "tips": res.tips,
        }

    if name == "toolwiz_predict_stock_compensation":
        with app.test_client() as client:
            resp = client.post(
                "/api/stock_compensation",
                json=args,
                headers={"X-ToolWiz-Client": "mcp-server"},
            )
            return resp.get_json() or {"success": False, "error": f"HTTP {resp.status_code}"}

    if name == "toolwiz_search_materials":
        q = str(args.get("query") or "").strip().lower()
        families = physics.get_materials()
        matches = {}
        for fam in families:
            alloys = physics.get_alloys_for_family(fam)
            if not q or q in fam.lower():
                matches[fam] = alloys[:15]
            else:
                hit_alloys = [a for a in alloys if q in str(a.get("alloy", "")).lower()]
                if hit_alloys:
                    matches[fam] = hit_alloys[:15]
        return {"success": True, "query": q, "matches": matches}

    if name == "fusion_get_setup_summary":
        return fusion_bridge.execute_bridge_action("get_setup_summary", {})

    if name == "fusion_inspect_operation":
        return fusion_bridge.execute_bridge_action("inspect_operation", {"operation": args.get("operation")})

    if name == "fusion_audit_setup_sequence":
        return fusion_bridge.execute_bridge_action("audit_setup_sequence", {"setup": args.get("setup")})

    if name == "fusion_get_toolpath_status":
        return fusion_bridge.execute_bridge_action("get_toolpath_status", {"operation": args.get("operation")})

    if name == "fusion_apply_stock_to_leave":
        return fusion_bridge.execute_bridge_action(
            "apply_stock_to_leave",
            {
                "operation": args.get("operation"),
                "radial_stock": args.get("radial_stock"),
                "axial_stock": args.get("axial_stock"),
            },
        )

    if name == "toolwiz_holistic_oversight":
        with app.test_client() as client:
            resp = client.post(
                "/api/oversight_review",
                json=args,
                headers={"X-ToolWiz-Client": "mcp-server"},
            )
            return resp.get_json() or {"success": False, "error": f"HTTP {resp.status_code}"}

    if name == "toolwiz_curate_tool_library":
        with app.test_client() as client:
            resp = client.post(
                "/api/library/curate",
                json=args,
                headers={"X-ToolWiz-Client": "mcp-server"},
            )
            return resp.get_json() or {"success": False, "error": f"HTTP {resp.status_code}"}

    return {"success": False, "error": f"Unknown MCP tool: {name!r}"}


def handle_mcp_message(msg: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Process a single JSON-RPC 2.0 MCP message and return the response dict (or None for notifications)."""
    if not isinstance(msg, dict):
        return {
            "jsonrpc": "2.0",
            "id": None,
            "error": {"code": -32600, "message": "Invalid Request"},
        }

    method = msg.get("method")
    msg_id = msg.get("id")
    params = msg.get("params") if isinstance(msg.get("params"), dict) else {}

    # Notifications have no 'id' and expect no response
    if msg_id is None and method and str(method).startswith("notifications/"):
        return None

    if method == "initialize":
        return {
            "jsonrpc": "2.0",
            "id": msg_id,
            "result": {
                "protocolVersion": MCP_PROTOCOL_VERSION,
                "capabilities": {"tools": {"listChanged": False}},
                "serverInfo": SERVER_INFO,
            },
        }

    if method == "ping":
        return {"jsonrpc": "2.0", "id": msg_id, "result": {}}

    if method == "tools/list":
        return {
            "jsonrpc": "2.0",
            "id": msg_id,
            "result": {"tools": list_mcp_tools()},
        }

    if method == "tools/call":
        tool_name = str(params.get("name") or "")
        tool_args = params.get("arguments") if isinstance(params.get("arguments"), dict) else {}
        try:
            data = call_mcp_tool_by_name(tool_name, tool_args)
            is_err = not bool(data.get("success", True))
            return {
                "jsonrpc": "2.0",
                "id": msg_id,
                "result": {
                    "content": [{"type": "text", "text": json.dumps(data, indent=2)}],
                    "isError": is_err,
                },
            }
        except Exception as ex:
            return {
                "jsonrpc": "2.0",
                "id": msg_id,
                "result": {
                    "content": [{"type": "text", "text": json.dumps({"success": False, "error": str(ex)})}],
                    "isError": True,
                },
            }

    return {
        "jsonrpc": "2.0",
        "id": msg_id,
        "error": {"code": -32601, "message": f"Method not found: {method!r}"},
    }


def run_stdio_server() -> None:
    """Run the JSON-RPC 2.0 MCP server over stdin/stdout."""
    for raw_line in sys.stdin:
        line = raw_line.strip()
        if not line:
            continue
        try:
            msg = json.loads(line)
        except json.JSONDecodeError as ex:
            err_resp = {
                "jsonrpc": "2.0",
                "id": None,
                "error": {"code": -32700, "message": f"Parse error: {ex}"},
            }
            sys.stdout.write(json.dumps(err_resp) + "\n")
            sys.stdout.flush()
            continue

        resp = handle_mcp_message(msg)
        if resp is not None:
            sys.stdout.write(json.dumps(resp) + "\n")
            sys.stdout.flush()


if __name__ == "__main__":
    run_stdio_server()
