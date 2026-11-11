"""Two-way bridge between the ToolWiz server/MCP layer and the Fusion 360 add-in.

Architecture (adapted from the main-thread ``CustomEvent`` queue pattern in ``fusion360-mcp``,
tailored to ToolWiz's ``adsk.cam`` operations and ``AuditedCommand`` safety model):

1. Fusion 360's API is not thread-safe: any ``adsk.cam`` or ``adsk.fusion`` call from a background
   thread can crash Fusion. Inside ``ToolWizFusionAddin.py``, a background poller/sender communicates
   with this module over ``127.0.0.1:5000`` and fires ``app.fireCustomEvent('ToolWizMCPBridgeEvent', ...)``
   so that every CAD/CAM read or audited mutation runs strictly on Fusion's main UI thread.
2. When a direct executor is registered (e.g., in unit tests or in-process tools), commands are
   dispatched synchronously through the executor without network round-trips.
"""
from __future__ import annotations

import threading
import time
import uuid
from typing import Any, Callable, Dict, List, Optional

from flask import Blueprint, jsonify, request

ALLOWED_ACTIONS = (
    "get_setup_summary",
    "inspect_operation",
    "audit_setup_sequence",
    "get_toolpath_status",
    "apply_stock_to_leave",
    "snapshot_compare",
)

_lock = threading.Lock()
_live_state: Dict[str, Any] = {
    "connected": False,
    "updated_at": None,
    "document": None,
    "setups": [],
    "ops": [],
    "tool_count": None,
}
_pending_queue: List[Dict[str, Any]] = []
_results: Dict[str, Dict[str, Any]] = {}
_result_events: Dict[str, threading.Event] = {}
_direct_executor: Optional[Callable[[str, Dict[str, Any]], Dict[str, Any]]] = None


def register_direct_executor(fn: Optional[Callable[[str, Dict[str, Any]], Dict[str, Any]]]) -> None:
    """Register an in-process callable ``fn(action, params) -> dict`` (used by tests and local callers)."""
    global _direct_executor
    with _lock:
        _direct_executor = fn


def update_live_state(state: Dict[str, Any]) -> Dict[str, Any]:
    """Store the latest setup/operation snapshot pushed from the Fusion add-in."""
    with _lock:
        _live_state.update({
            "connected": True,
            "updated_at": time.time(),
            "document": state.get("document"),
            "setups": state.get("setups") or [],
            "ops": state.get("ops") or [],
            "tool_count": state.get("tool_count"),
        })
        return dict(_live_state)


def get_live_state() -> Dict[str, Any]:
    """Return a copy of the latest cached Fusion state."""
    with _lock:
        return dict(_live_state)


def reset_bridge_state() -> None:
    """Clear state, queues, and direct executor (for isolated unit tests)."""
    global _direct_executor
    with _lock:
        _direct_executor = None
        _pending_queue.clear()
        _results.clear()
        _result_events.clear()
        _live_state.update({
            "connected": False,
            "updated_at": None,
            "document": None,
            "setups": [],
            "ops": [],
            "tool_count": None,
        })


def enqueue_command(action: str, params: Optional[Dict[str, Any]] = None) -> str:
    """Queue a command for the Fusion add-in's CustomEvent handler and return its ``request_id``."""
    if action not in ALLOWED_ACTIONS:
        raise ValueError(f"Unsupported bridge action {action!r}. Allowed: {', '.join(ALLOWED_ACTIONS)}")
    req_id = str(uuid.uuid4())
    ev = threading.Event()
    item = {
        "request_id": req_id,
        "action": action,
        "params": dict(params or {}),
        "queued_at": time.time(),
    }
    with _lock:
        _result_events[req_id] = ev
        _pending_queue.append(item)
    return req_id


def pop_next_command() -> Optional[Dict[str, Any]]:
    """Pop the oldest queued command for the Fusion add-in to execute on the main thread."""
    with _lock:
        if not _pending_queue:
            return None
        return _pending_queue.pop(0)


def record_command_result(request_id: str, result: Dict[str, Any]) -> bool:
    """Store the result posted back from the Fusion add-in's CustomEvent handler."""
    with _lock:
        ev = _result_events.get(request_id)
        if ev is None:
            return False
        _results[request_id] = dict(result or {})
        ev.set()
        return True


def execute_bridge_action(
    action: str,
    params: Optional[Dict[str, Any]] = None,
    timeout: float = 5.0,
) -> Dict[str, Any]:
    """Execute a Fusion bridge action via the direct executor (if registered), cached state fallback
    for read-only summary calls, or the main-thread CustomEvent queue."""
    if action not in ALLOWED_ACTIONS:
        return {"success": False, "error": f"Unsupported bridge action {action!r}"}

    params = dict(params or {})
    with _lock:
        direct = _direct_executor

    if direct is not None:
        try:
            res = direct(action, params)
            if isinstance(res, dict):
                res.setdefault("success", True)
                return res
            return {"success": True, "result": res}
        except Exception as ex:
            return {"success": False, "error": str(ex)}

    # Queue for the live Fusion add-in CustomEvent poller
    req_id = enqueue_command(action, params)
    with _lock:
        ev = _result_events.get(req_id)

    if ev is not None and ev.wait(timeout=max(0.05, float(timeout))):
        with _lock:
            res = _results.pop(req_id, {"success": False, "error": "missing result"})
            _result_events.pop(req_id, None)
        return res

    # Clean up timed-out request
    with _lock:
        _pending_queue[:] = [item for item in _pending_queue if item["request_id"] != req_id]
        _result_events.pop(req_id, None)
        _results.pop(req_id, None)
        cached = dict(_live_state)

    # If the caller only asked for get_setup_summary and we have a cached state, return it gracefully
    if action == "get_setup_summary" and cached.get("connected"):
        return {"success": True, "cached": True, **cached}

    return {
        "success": False,
        "error": (
            "Fusion 360 add-in did not respond within timeout. Ensure Fusion 360 is open with "
            "ToolWizFusionAddin enabled."
        ),
    }


def register(app) -> None:
    """Attach ``/api/fusion_bridge/*`` endpoints to the Flask app."""
    bp = Blueprint("fusion_bridge", __name__)

    @bp.route("/api/fusion_bridge/state", methods=["GET", "POST"])
    def bridge_state():
        if request.method == "POST":
            data = request.get_json(silent=True) or {}
            st = update_live_state(data)
            return jsonify({"success": True, "state": st})
        return jsonify({"success": True, "state": get_live_state()})

    @bp.route("/api/fusion_bridge/next", methods=["GET"])
    def bridge_next():
        cmd = pop_next_command()
        return jsonify({"success": True, "command": cmd})

    @bp.route("/api/fusion_bridge/result", methods=["POST"])
    def bridge_result():
        data = request.get_json(silent=True) or {}
        req_id = str(data.get("request_id") or "")
        result = data.get("result") if isinstance(data.get("result"), dict) else data
        if not req_id:
            return jsonify({"success": False, "error": "request_id is required"}), 400
        ok = record_command_result(req_id, result)
        return jsonify({"success": ok})

    @bp.route("/api/fusion_bridge/command", methods=["POST"])
    def bridge_command():
        data = request.get_json(silent=True) or {}
        action = str(data.get("action") or "").strip()
        params = data.get("params") if isinstance(data.get("params"), dict) else {}
        timeout = float(data.get("timeout", 5.0))
        res = execute_bridge_action(action, params, timeout=timeout)
        status = 200 if res.get("success") else 400
        return jsonify(res), status

    app.register_blueprint(bp)
