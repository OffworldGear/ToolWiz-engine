"""Setup advisor: audit a Fusion CAM setup against ToolWiz, deterministically, with an optional LLM narrative.

``advise(setup, ...)`` implements ``POST /api/setup_advisor`` (docs/SETUP_ADVISOR.md,
docs/V3_IMPLEMENTATION_PLAN.md). For every operation it runs ToolWiz (``pipeline.run_cut``, or ``tslot_model``
for slot mills) twice: on the operation's own engagement (``engagement_source: "user"``) and on ToolWiz's
recommendation, and reports findings (STOP / CAUTION / INFO) from the difference. Setup-level checks come from
``oversight_engine.evaluate_setup_oversight``; strategy suggestions from ``strategy_planner.compare``.

Principle: the LLM never produces numbers. Every number in the result comes from a ToolWiz call (or arithmetic on
those results); the optional narrative may only repeat numbers present in the result and is rejected by
``toolwiz_common.numeric_guard`` otherwise.

Units: lengths inches, feeds IPM, speeds rpm / SFM, times minutes, MRR in^3/min.
"""
from __future__ import annotations

import dataclasses
import datetime
import json
import re
import threading
from typing import Any, Callable, Dict, List, Optional, Tuple

from toolwiz_common import numeric_guard

MM_PER_IN = 25.4

# ---- finding thresholds ---------------------------------------------------------------------------------------
CHIP_STOP_RATIO = 2.0        # current chip load / ToolWiz chip load above this: STOP
OFF_FRACTION = 0.40          # |current / ToolWiz - 1| above this: CAUTION (rpm, feed, chip load, stepdown, stepover)
SAVINGS_MIN_SPEEDUP = 1.25   # INFO when ToolWiz's recommended engagement removes material this much faster
STRATEGY_MIN_SAVING = 0.10   # INFO when the recommended strategy saves at least this fraction of the cycle time
MAX_STRATEGY_CANDIDATES = 4
EDGE_BREAK_MAX_FRACTION = 0.15   # corner radius up to this fraction of D is an edge break; larger radii use the bull-nose path

#: Fusion parameters the apply step may write (mirrors ``fusion_bridge.APPLY_ALLOWED_PARAMS``).
PARAM_KINDS = {
    "tool_spindleSpeed": "rpm", "tool_feedCutting": "feed", "tool_feedPlunge": "feed", "tool_feedRamp": "feed",
    "tool_rampAngle": "angle", "maximumStepdown": "len", "stepdown": "len", "maximumStepover": "len",
    "stepover": "len", "optimalLoad": "len", "stockToLeave": "len", "verticalStockToLeave": "len",
    "tabWidth": "len", "tabHeight": "len", "rampAngle": "angle", "helicalRampDiameter": "len",
}

_LAST: Dict[str, Any] = {"result": None, "generated_at": None}
_LAST_LOCK = threading.Lock()


# ===================================================================================================================
# last result store
# ===================================================================================================================

def set_last(result: Dict[str, Any]) -> None:
    """Remember the latest advisor result in memory (served by ``GET /api/setup_advisor/last``)."""
    with _LAST_LOCK:
        _LAST["result"] = result
        _LAST["generated_at"] = result.get("generated_at")


def get_last() -> Optional[Dict[str, Any]]:
    """The latest advisor result, or None."""
    with _LAST_LOCK:
        return _LAST["result"]


def clear_last() -> None:
    with _LAST_LOCK:
        _LAST["result"] = None
        _LAST["generated_at"] = None


# ===================================================================================================================
# parsing the add-in's snapshot
# ===================================================================================================================

_QTY = re.compile(r"^\s*([-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?)\s*([A-Za-z\"/%.°]*)\s*$")
_LEN_UNITS = {"": 1.0, "in": 1.0, "inch": 1.0, "inches": 1.0, '"': 1.0, "mm": 1 / 25.4, "cm": 1 / 2.54,
              "m": 1 / 0.0254, "ft": 12.0, "thou": 0.001, "mil": 0.001}
_FEED_UNITS = {"": 1.0, "in/min": 1.0, "ipm": 1.0, "in./min": 1.0, "mm/min": 1 / 25.4, "m/min": 1000 / 25.4,
               "ft/min": 12.0, "cm/min": 1 / 2.54, "mm/s": 60 / 25.4}
_RPM_UNITS = {"": 1.0, "rpm": 1.0, "rev/min": 1.0, "1/min": 1.0}
_ANGLE_UNITS = {"": 1.0, "deg": 1.0, "°": 1.0, "degrees": 1.0, "rad": 57.29577951308232}


def parse_quantity(x: Any, kind: str) -> Optional[float]:
    """A number from an add-in value: a plain number (inches / IPM / rpm / degrees), an expression string with units
    ("0.25 in", "6 mm", "108.14in/min", "12000 rpm") or a ``{"expr", "value"}`` parameter dict (``expr`` wins; a bare
    ``value`` is read as inches / IPM / rpm). ``kind``: "len" (-> inches), "feed" (-> IPM), "rpm", "angle" (-> degrees),
    "num" (no units). None when absent or unparseable."""
    if x is None or isinstance(x, bool):
        return None
    if isinstance(x, dict):
        for k in ("expr", "expression", "text"):
            if x.get(k) not in (None, ""):
                v = parse_quantity(x[k], kind)
                if v is not None:
                    return v
        for k in ("in", "inches", "ipm", "value"):
            if isinstance(x.get(k), (int, float)) and not isinstance(x.get(k), bool):
                return float(x[k])
        if isinstance(x.get("mm"), (int, float)):
            return float(x["mm"]) / MM_PER_IN if kind in ("len", "feed") else float(x["mm"])
        return None
    if isinstance(x, (int, float)):
        return float(x) if x == x else None
    if isinstance(x, str):
        m = _QTY.match(x)
        if not m:
            return None
        v, unit = float(m.group(1)), m.group(2).lower()
        table = {"len": _LEN_UNITS, "feed": _FEED_UNITS, "rpm": _RPM_UNITS, "angle": _ANGLE_UNITS}.get(kind)
        if table is None:
            return v
        return v * table[unit] if unit in table else None
    return None


def _first(d: Dict[str, Any], keys: Tuple[str, ...], kind: str) -> Optional[float]:
    """First parseable value among ``keys`` of ``d``; for ``*_mm`` keys the number is read as millimetres."""
    for k in keys:
        if k not in d or d[k] in (None, ""):
            continue
        v = d[k]
        if k.endswith("_mm") and isinstance(v, (int, float)):
            return float(v) / MM_PER_IN if kind in ("len", "feed") else float(v)
        q = parse_quantity(v, kind)
        if q is not None:
            return q
    return None


_COATINGS = (("altin", "AlTiN"), ("tialn", "TiAlN"), ("alcrn", "AlCrN"), ("zrn", "ZrN"), ("dlc", "DLC"),
             ("diamond", "Diamond"), ("tisin", "TiSiN"), ("ticn", "TiCN"), ("tin", "TiN"), ("uncoated", "Uncoated"),
             ("bright", "Uncoated"))


def _coating_of(tool: Dict[str, Any], desc: str) -> Optional[str]:
    """Coating from an explicit ``coating`` field or the description; None when unknown ("ti coated" is ambiguous)."""
    c = str(tool.get("coating") or "").strip()
    text = f"{c} {desc}".lower()
    for key, name in _COATINGS:
        if key in text:
            return name
    return None


def _tool_unit_factor(tool: Dict[str, Any]) -> float:
    u = str(tool.get("unit") or "").lower()
    return 1 / MM_PER_IN if u.startswith("mill") or u == "mm" else 1.0


def parse_tool(t: Any) -> Dict[str, Any]:
    """Normalize a tool (a description string, a Fusion tool JSON dict or a flat dict) to inches:
    ``diameter_in, flutes, flute_length_in, shank_diameter_in, stickout_in, corner_radius_in, coating, holder,
    holder_runout_in, type, description, number, neck_diameter_in, reach_in, kerf_in, teeth`` (None when unknown)."""
    out: Dict[str, Any] = {"diameter_in": None, "flutes": None, "flute_length_in": None, "shank_diameter_in": None,
                           "stickout_in": None, "corner_radius_in": 0.0, "coating": None, "holder": None,
                           "holder_runout_in": None, "type": "", "description": "", "number": None,
                           "neck_diameter_in": None, "reach_in": None, "kerf_in": None, "teeth": None}
    if t is None:
        return out
    if isinstance(t, str):
        out["description"] = t
        out["coating"] = _coating_of({}, t)
        return out
    if not isinstance(t, dict):
        return out
    desc = str(t.get("description") or t.get("tool_description") or t.get("name") or "")
    out["description"] = desc
    out["type"] = str(t.get("type") or t.get("tool_type") or "").lower()
    pp = t.get("post-process") or t.get("postProcess") or {}
    num = t.get("number", t.get("tool_number", pp.get("number") if isinstance(pp, dict) else None))
    out["number"] = int(num) if isinstance(num, (int, float)) and not isinstance(num, bool) else None
    geo = t.get("geometry") if isinstance(t.get("geometry"), dict) else None
    if geo and any(k in geo for k in ("DC", "NOF", "LCF")):          # Fusion library tool JSON
        f = _tool_unit_factor(t)

        def g(key):
            v = geo.get(key)
            return float(v) * f if isinstance(v, (int, float)) and not isinstance(v, bool) else None
        out.update(diameter_in=g("DC"), flute_length_in=g("LCF"), shank_diameter_in=g("SFDM"), stickout_in=g("LB"),
                   corner_radius_in=g("RE") or 0.0, neck_diameter_in=g("shoulder-diameter"),
                   reach_in=g("shoulder-length"))
        nof = geo.get("NOF")
        out["flutes"] = int(nof) if isinstance(nof, (int, float)) else None
    else:
        out["diameter_in"] = _first(t, ("diameter_in", "diameter_mm", "diameter", "DC"), "len")
        fl = t.get("flutes", t.get("NOF"))
        out["flutes"] = int(fl) if isinstance(fl, (int, float)) and not isinstance(fl, bool) else None
        out["flute_length_in"] = _first(t, ("flute_length_in", "flute_length_mm", "flute_length", "fluteLength", "LCF"), "len")
        out["shank_diameter_in"] = _first(t, ("shank_diameter_in", "shank_diameter_mm", "shank_diameter", "shankDiameter", "SFDM"), "len")
        out["stickout_in"] = _first(t, ("stickout_in", "stickout_mm", "stickout", "LB"), "len")
        out["corner_radius_in"] = _first(t, ("corner_radius_in", "corner_radius_mm", "corner_radius", "cornerRadius", "RE"), "len") or 0.0
        out["neck_diameter_in"] = _first(t, ("neck_diameter_in", "neck_diameter_mm", "neck_diameter"), "len")
        out["reach_in"] = _first(t, ("reach_in", "reach_mm", "reach"), "len")
    out["kerf_in"] = _first(t, ("kerf_in", "kerf_mm", "kerf"), "len")
    tt = t.get("teeth")
    out["teeth"] = int(tt) if isinstance(tt, (int, float)) and not isinstance(tt, bool) else None
    out["coating"] = _coating_of(t, desc)
    h = t.get("holder")
    if isinstance(h, dict):
        out["holder"] = str(h.get("description") or h.get("name") or h.get("type") or "") or None
        out["holder_runout_in"] = _first(h, ("runout_in", "runout_mm", "runout", "tir_in"), "len")
    elif isinstance(h, str):
        out["holder"] = h or None
    if out["holder_runout_in"] is None:
        out["holder_runout_in"] = _first(t, ("holder_runout_in", "runout_in", "tir_in"), "len")
    return out


_FIN = ("finish", "scallop", "parallel", "pencil", "spiral", "flat", "horizontal", "morph", "project", "steep",
        "blend", "radial", "contour3d")
_HOLE = ("drill", "bore", "tap", "thread", "ream", "spot", "circular")


def classify_op(strategy: str, name: str, tool: Dict[str, Any], geometry: Dict[str, Any],
                stock_radial: Optional[float]) -> str:
    """Operation kind: ``tslot`` (slot mill / keyseat cutter), ``adaptive``, ``slot``, ``contour`` (2D contour
    roughing), ``finish``, ``pocket``, ``face``, ``hole`` (not analysed) or ``rough``."""
    s, n = (strategy or "").lower(), (name or "").lower()
    ttype = (tool.get("type") or "").lower() + " " + (tool.get("description") or "").lower()
    if any(k in ttype for k in ("slot mill", "keyseat", "t-slot", "tslot", "t slot", "woodruff")):
        return "tslot"
    if any(k in s for k in _HOLE) or any(k in ttype for k in ("drill", "tap ", " tap")) and "mill" not in ttype:
        return "hole"
    if "adaptive" in s or "adaptive" in n:
        return "adaptive"
    if "slot" in s or "slot" in n or geometry.get("is_slot"):
        return "slot"
    if "face" in s or "facing" in n:
        return "face"
    if any(k in s for k in _FIN) or "finish" in n:
        return "finish"
    if "contour" in s or "profile" in s:
        w, d = geometry.get("slot_width_in") or geometry.get("channel_width_in"), tool.get("diameter_in")
        if w and d and w <= 1.1 * d:
            return "slot"
        if stock_radial is not None and stock_radial <= 0.00005 and "rough" not in n:
            return "finish"
        return "contour"
    if "pocket" in s or "pocket" in n:
        return "pocket"
    return "rough"


_PARAM_KEYS = {
    "rpm": ("rpm", "spindle_rpm", "spindle_speed", "tool_spindleSpeed"),
    "feed": ("feed_ipm", "feed_mm_min", "feed", "feedrate", "tool_feedCutting"),
    "stepdown": ("stepdown_in", "stepdown_mm", "stepdown", "maximumStepdown", "doc_in", "doc"),
    "stepover": ("stepover_in", "stepover_mm", "optimal_load_in", "optimalLoad", "stepover", "maximumStepover",
                 "woc_in", "woc"),
    "stock_radial": ("stock_to_leave_in", "stock_to_leave_mm", "radial_stock_in", "radial_stock", "stockToLeave"),
    "stock_axial": ("axial_stock_in", "axial_stock_mm", "axial_stock", "verticalStockToLeave", "floor_stock_in"),
}


def _op_params(raw: Dict[str, Any]) -> Dict[str, Optional[float]]:
    """rpm / feed / stepdown / stepover / stock values of an op from its ``params`` / ``cut_params`` / own keys."""
    src: Dict[str, Any] = {}
    for k in ("cut_params", "params", "current"):
        if isinstance(raw.get(k), dict):
            src.update(raw[k])
    for k, v in raw.items():          # snapshot entries keep Fusion parameter names at the top level
        if k not in src and not isinstance(v, (list,)) and k in sum(_PARAM_KEYS.values(), ()):
            src[k] = v
    out: Dict[str, Optional[float]] = {}
    for key, names in _PARAM_KEYS.items():
        kind = {"rpm": "rpm", "feed": "feed"}.get(key, "len")
        v = _first(src, names, kind)
        if key == "feed" and v is None and isinstance(src.get("feed_mm_min"), (int, float)):
            v = float(src["feed_mm_min"]) / MM_PER_IN
        out[key] = v
    return out


def _geometry_of(raw: Dict[str, Any]) -> Dict[str, Any]:
    """Feature geometry the add-in measured for the op (inches): slot / channel width, depth, toolpath length, tabs."""
    g = raw.get("geometry") if isinstance(raw.get("geometry"), dict) and not raw["geometry"].get("DC") else {}
    fg = raw.get("feature_geometry") if isinstance(raw.get("feature_geometry"), dict) else {}
    out: Dict[str, Any] = {"feature_geometry": fg or None}

    def pick(names, kind="len"):
        for src in (g, raw):
            v = _first(src, names, kind)
            if v is not None:
                return v
        return None
    out["slot_width_in"] = pick(("slot_width_in", "slot_width_mm", "slot_width"))
    out["channel_width_in"] = pick(("channel_width_in", "channel_width_mm", "channel_width"))
    out["slot_height_in"] = pick(("slot_height_in", "slot_height_mm", "slot_height"))
    out["radial_depth_in"] = pick(("radial_depth_in", "radial_depth_mm", "radial_depth", "slot_depth_in"))
    out["toolpath_length_in"] = pick(("toolpath_length_in", "toolpath_length_mm", "toolpath_length", "length_in", "length_mm"))
    depth = pick(("depth_in", "depth_mm", "depth", "feature_depth_in"))
    top, bot = pick(("top_height_in", "top_height_mm", "top_height")), pick(("bottom_height_in", "bottom_height_mm", "bottom_height"))
    if depth is None and top is not None and bot is not None:
        depth = abs(top - bot)
    if depth is None and fg.get("feature_depth_in"):
        depth = float(fg["feature_depth_in"])
    out["depth_in"] = depth
    tabs = g.get("tabs") if isinstance(g.get("tabs"), dict) else raw.get("tabs") if isinstance(raw.get("tabs"), dict) else None
    if tabs and (tabs.get("count") or 0) > 0:
        out["tabs"] = {"count": int(tabs["count"]),
                       "width": _first(tabs, ("width_in", "width_mm", "width"), "len") or 0.0,
                       "height": _first(tabs, ("height_in", "height_mm", "height"), "len") or 0.0,
                       "style": str(tabs.get("style") or "3d").lower()}
    out["is_slot"] = bool(g.get("is_slot") or raw.get("is_slot"))
    return out


def _ops_list(setup: Dict[str, Any]) -> List[Dict[str, Any]]:
    """The raw operation dicts of a snapshot, in order: ``ops`` / ``operations`` as a list or a dict keyed by
    ``"Setup > Op"`` path (the add-in's ``snapshot_document`` form)."""
    ops = setup.get("ops")
    if ops is None:
        ops = setup.get("operations")
    if isinstance(ops, dict):
        out = []
        for path, o in ops.items():
            if isinstance(o, dict):
                o = dict(o)
                o.setdefault("path", path)
                if " > " in path:
                    o.setdefault("setup", path.split(" > ", 1)[0])
                    o.setdefault("name", path.split(" > ", 1)[1])
                out.append(o)
        return out
    return [o for o in (ops or []) if isinstance(o, dict)]


def normalize_setup(setup: Dict[str, Any]) -> Dict[str, Any]:
    """Normalize the add-in's setup snapshot (docs/SETUP_ADVISOR.md) to ``{"document", "ops": [...], "notes": [...]}``.

    Missing fields are tolerated: an op without a tool or without engagement is still listed (with what is known) and
    simply gets fewer checks. Op dict keys: ``op_id, name, setup, strategy, kind, tool{...parse_tool}, current{rpm,
    feed_ipm, stepdown_in, stepover_in, stock_radial_in, stock_axial_in}, geometry{...}, family, alloy,
    rest_machining, index``."""
    if not isinstance(setup, dict):
        raise ValueError("'setup' must be an object (the add-in's setup snapshot)")
    notes: List[str] = []
    ops: List[Dict[str, Any]] = []
    for idx, raw in enumerate(_ops_list(setup)):
        tool = parse_tool(raw.get("tool") if raw.get("tool") is not None else raw.get("tool_info"))
        if raw.get("tool_description") and not tool["description"]:
            tool["description"] = str(raw["tool_description"])
        if tool["number"] is None and isinstance(raw.get("tool_number"), (int, float)):
            tool["number"] = int(raw["tool_number"])
        if tool["holder"] is None and isinstance(raw.get("holder"), str):
            tool["holder"] = raw["holder"]
        prm = _op_params(raw)
        geom = _geometry_of(raw)
        strategy = str(raw.get("strategy") or "")
        name = str(raw.get("name") or f"Operation {idx + 1}")
        kind = str(raw.get("kind") or "") or classify_op(strategy, name, tool, geom, prm["stock_radial"])
        if kind == "tslot" and tool["kerf_in"] is None and tool["flute_length_in"]:
            tool["kerf_in"] = tool["flute_length_in"]
        path = str(raw.get("path") or "")
        op_id = str(raw.get("op_id") or raw.get("id") or path or f"{raw.get('setup') or 'Setup'} > {name}")
        ops.append({
            "op_id": op_id, "name": name, "setup": str(raw.get("setup") or ""), "strategy": strategy, "kind": kind,
            "tool": tool, "geometry": geom, "index": idx,
            "current": {"rpm": prm["rpm"], "feed_ipm": prm["feed"], "stepdown_in": prm["stepdown"],
                        "stepover_in": prm["stepover"], "stock_radial_in": prm["stock_radial"],
                        "stock_axial_in": prm["stock_axial"]},
            "family": raw.get("family") or ((raw.get("material") or {}).get("family") if isinstance(raw.get("material"), dict) else None),
            "alloy": raw.get("alloy") or ((raw.get("material") or {}).get("alloy") if isinstance(raw.get("material"), dict) else None),
            "rest_machining": raw.get("rest_machining") if isinstance(raw.get("rest_machining"), bool) else None,
        })
    if not ops:
        notes.append("The setup snapshot contains no operations.")
    mat = setup.get("material") if isinstance(setup.get("material"), dict) else {}
    return {"document": setup.get("document"), "ops": ops, "notes": notes,
            "family": setup.get("family") or mat.get("family"), "alloy": setup.get("alloy") or mat.get("alloy"),
            "audit": setup.get("audit") if isinstance(setup.get("audit"), dict) else None}


# ===================================================================================================================
# running ToolWiz
# ===================================================================================================================

_KIND_OPERATION = {"adaptive": "Adaptive Roughing", "slot": "Slotting", "contour": "Roughing", "pocket": "Roughing",
                   "rough": "Roughing", "finish": "Finishing", "face": "Facing"}


def _fusion_tool_dict(tool: Dict[str, Any], stickout: float) -> Dict[str, Any]:
    geo = {"DC": tool["diameter_in"], "NOF": tool["flutes"], "LCF": tool["flute_length_in"],
           "SFDM": tool["shank_diameter_in"], "LB": stickout}
    if tool.get("corner_radius_in"):
        geo["RE"] = tool["corner_radius_in"]
    return {"type": "bull nose end mill" if tool.get("corner_radius_in") else "flat end mill", "unit": "inches",
            "geometry": geo}


def _complete_tool(tool: Dict[str, Any]) -> Tuple[Dict[str, Any], List[str]]:
    """The tool with defaults for missing fields (and a note per assumed field)."""
    t = dict(tool)
    notes: List[str] = []
    d = t["diameter_in"]
    if not t.get("flutes"):
        t["flutes"] = 4
        notes.append("flute count unknown: 4 assumed")
    if not t.get("flute_length_in"):
        t["flute_length_in"] = round(3.0 * d, 5)
        notes.append("flute length unknown: 3 x D assumed")
    if not t.get("shank_diameter_in"):
        t["shank_diameter_in"] = max(d, 0.125) if d < 0.125 else d
        notes.append("shank diameter unknown: assumed " + ("0.125 in for a micro tool" if d < 0.125 else "equal to the cutting diameter"))
    cr = t.get("corner_radius_in") or 0.0
    if cr and cr <= EDGE_BREAK_MAX_FRACTION * d:
        t["corner_radius_in"] = 0.0          # an edge break / chamfer, not a bull nose: lets the v2 model apply
        notes.append(f"corner radius {cr:.4f} in is {cr / d * 100:.0f}% of the diameter: treated as an edge break (square end mill)")
    if not t.get("stickout_in"):
        t["stickout_in"] = round(max(t["flute_length_in"] + 0.5 * t["shank_diameter_in"], 4.0 * d), 5)
        t["stickout_assumed"] = True
        notes.append("stickout unknown: flute length + half the shank assumed")
    return t, notes


def _cut_dict(res: Any, flutes: int) -> Dict[str, Any]:
    """The ToolWiz numbers the advisor keeps from a ``pipeline.CutResult`` (inches, IPM, rpm, SFM)."""
    v2 = res.v2 if isinstance(res.v2, dict) else {}
    warns = [w for w in (v2.get("warnings") or []) if isinstance(w, str) and
             ("rubbing limit" in w or w.startswith("reduced flutes") or w.startswith("WARNING"))]
    fz = (res.feed_ipm / (res.rpm * flutes)) if res.rpm and flutes else None
    ha = res.holder_advice if isinstance(res.holder_advice, dict) else None
    return {
        "operation": res.operation, "model": res.model, "engagement_source": res.engagement_source,
        "feasible": bool(res.feasible), "limited_by": res.limited_by,
        "rpm": round(res.rpm), "sfm": round(res.sfm, 1), "feed_ipm": round(res.feed_ipm, 3),
        "chip_load_ipt": round(fz, 6) if fz else None,
        "ap_in": round(res.doc, 5), "ae_in": round(res.woc, 5),
        "recommended_ap_in": round(res.rec_doc, 5), "recommended_ae_in": round(res.rec_woc, 5),
        "mrr_in3_min": round(res.mrr, 4), "deflection_in": round(res.deflection, 6),
        "runout_regime": res.runout_regime, "flutes_cutting": res.flutes_cutting,
        "tir_all_flutes_in": round(res.tir_all_flutes_in, 6) if res.tir_all_flutes_in is not None else None,
        "runout_ratio": round(res.runout_ratio, 3) if res.runout_ratio is not None else None,
        "stock_to_leave_radial_in": res.recommended_radial_stock_in, "stock_to_leave_axial_in": res.recommended_axial_stock_in,
        "ramp_angle_deg": round(res.ramp_angle, 2) if res.ramp_angle else None,
        "ramp_feed_ipm": round(res.ramp_feed, 2) if res.ramp_feed else None,
        "plunge_feed_ipm": round(res.plunge_feed, 3) if res.plunge_feed else None,
        "warnings": warns,
        "holder_advice": ha,
        "tool_advice": res.tool_advice if isinstance(res.tool_advice, list) else [],
    }


def _run_endmill(physics, machine, ctx, tool, operation, depth, width):
    """One ``pipeline.run_cut`` for ``tool`` (completed) at ``operation`` and an optional user engagement."""
    from pipeline import CutRequest, run_cut
    coating = tool.get("coating")
    req = CutRequest(
        family=ctx["family"], alloy=ctx["alloy"], operation=operation, coating=coating or "Uncoated",
        apply_coating=bool(coating), geometry="Radiused" if tool.get("corner_radius_in") else "Square",
        diameter=tool["diameter_in"], flutes=tool["flutes"], flute_length=tool["flute_length_in"],
        shank_diameter=tool["shank_diameter_in"], corner_radius=tool.get("corner_radius_in") or 0.0,
        stickout=tool["stickout_in"], aggressiveness=ctx["aggressiveness"], max_rpm=machine["max_rpm"],
        max_hp=machine["max_hp"], runout=ctx["runout"], cut_depth=depth, cut_width=width,
        fusion_tool=_fusion_tool_dict(tool, tool["stickout_in"]), model=ctx["model"],
        machine_profile=machine["profile"] if machine.get("profile", {}).get("spindle_options") else None)
    return run_cut(physics, req)


def _tslot_geometry(tool: Dict[str, Any]) -> Tuple[Dict[str, Any], List[str]]:
    """T-slot cutter geometry (inches) for ``tslot_model`` plus its provisional (assumed) fields. A shop cutter in
    ``data/shop_tools.json`` with the same diameter and kerf supplies the measured neck and reach."""
    import tslot_model
    D = tool["diameter_in"]
    kerf = tool.get("kerf_in") or tool.get("flute_length_in") or 0.0
    for t in tslot_model.load_shop_tools().values():
        if abs(t["diameter_mm"] / MM_PER_IN - D) <= 0.03 * D and abs(t["kerf_mm"] / MM_PER_IN - kerf) <= 0.03 * max(kerf, 1e-6):
            return (dict(diameter=D, kerf=kerf, neck_diameter=t["neck_diameter_mm"] / MM_PER_IN,
                         reach=t["reach_mm"] / MM_PER_IN, shank_diameter=t["shank_diameter_mm"] / MM_PER_IN,
                         teeth=int(t.get("teeth") or tool.get("flutes") or 4), tooth_form=t.get("tooth_form"),
                         teeth_per_face=t.get("teeth_per_face"), cutting_faces=t.get("cutting_faces"),
                         coating=t.get("coating") or "Uncoated"), list(t.get("provisional") or []))
    prov = []
    neck = tool.get("neck_diameter_in")
    if neck is None:
        shank = tool.get("shank_diameter_in")
        neck = shank if shank and shank < D else 0.58 * D
        prov.append("neck_diameter")
    reach = tool.get("reach_in")
    if reach is None:
        body = tool.get("stickout_in")
        reach = (body - kerf) if body and body > kerf else 1.67 * D
        prov.append("reach")
    prov.append("tooth_form")
    return (dict(diameter=D, kerf=kerf, neck_diameter=neck, reach=reach,
                 shank_diameter=tool.get("shank_diameter_in") or D, teeth=int(tool.get("flutes") or tool.get("teeth") or 4),
                 tooth_form=None, teeth_per_face=None, cutting_faces=None, coating=tool.get("coating") or "Uncoated"), prov)


def _run_tslot(physics, machine, ctx, tool, slot_height, radial_total):
    import tslot_model
    from strategy_tslot import _hrc
    g, prov = _tslot_geometry(tool)
    out = tslot_model.compute_tslot(
        physics, ctx["family"], diameter=g["diameter"], kerf=g["kerf"], neck_diameter=g["neck_diameter"],
        reach=g["reach"], shank_diameter=g["shank_diameter"], teeth=g["teeth"], tooth_form=g["tooth_form"],
        cutting_faces=g["cutting_faces"], teeth_per_face=g["teeth_per_face"], coating=g["coating"],
        hardness=_hrc(physics, ctx["family"], ctx["alloy"]), aggressiveness=ctx["aggressiveness"],
        runout=ctx["runout"], max_rpm=machine["max_rpm"], max_hp=machine["max_hp"], operation="full_slot",
        slot_height=slot_height or g["kerf"], radial_depth_total=radial_total, provisional=prov,
        name=tool.get("description") or "")
    return out, g, prov


def _tslot_dict(out: Dict[str, Any], g: Dict[str, Any], prov: List[str]) -> Dict[str, Any]:
    plan = out.get("axial_plan") or {}
    crit = [w["message"] for w in out.get("warnings", []) if w.get("type") == "critical"]
    return {
        "model": "tslot", "feasible": not crit, "limited_by": out.get("limited_by"),
        "rpm": round(out["rpm"]), "sfm": round(out["sfm"], 1), "feed_ipm": round(out["lateral_feed_ipm"], 3),
        "chip_load_ipt": round(out["chip_load_ipt"], 6),
        "axial_feed_ipm": round(out["axial_feed_ipm"], 3) if out.get("axial_feed_ipm") else None,
        "kerf_in": round(g["kerf"], 5), "z_step_in": round(plan.get("z_step_in") or g["kerf"], 5),
        "z_cuts": plan.get("cuts"), "radial_depth_per_pass_in": round(out["radial_depth_per_pass_in"], 5),
        "radial_passes": out.get("radial_passes"), "neck_deflection_in": round(out["deflection_in"], 6),
        "neck_deflection_limit_in": round(out["deflection_limit_in"], 6), "provisional_geometry": list(prov),
        "critical": crit,
        "warnings": [f"{w['title']}: {w['message']}" for w in out.get("warnings", [])
                     if w.get("type") in ("warning",) and w.get("title") not in ("Provisional geometry",)],
    }


# ===================================================================================================================
# findings
# ===================================================================================================================

def _f(sev: str, code: str, title: str, detail: str, rec: str, **numbers: Any) -> Dict[str, Any]:
    out = {"severity": sev, "code": code, "title": title, "detail": detail, "recommendation": rec}
    if numbers:
        out["numbers"] = {k: v for k, v in numbers.items() if v is not None}
    return out


def _fi(v: Optional[float]) -> str:
    """Inches for text: 4 decimals, 5 under 0.01."""
    if v is None:
        return "n/a"
    return f"{v:.5f}" if abs(v) < 0.01 else f"{v:.4f}"


_HOLDER_KEYS = (("er-up", "ER-UP"), ("ultra-precision er", "ER-UP"), ("shrink", "shrink"), ("hydraulic", "hydraulic"),
                ("powrgrip", "powRgrip"), ("rego", "powRgrip"), ("milling chuck", "milling chuck"),
                ("weldon", "weldon"), ("side-lock", "weldon"), ("side lock", "weldon"), ("sidelock", "weldon"),
                ("micro collet", "micro collet"), ("mega micro", "micro collet"), ("skc", "SK"))


def holder_key(text: Optional[str]) -> Optional[str]:
    """Holder family of a free-text holder name: shrink, hydraulic, powRgrip, SK, ER, ER-UP, milling chuck, weldon,
    micro collet (None when unrecognised)."""
    t = (text or "").lower()
    if not t:
        return None
    for k, v in _HOLDER_KEYS:
        if k in t:
            return v
    if re.search(r"(^|[^a-z])sk\d*([^a-z]|$)", t):
        return "SK"
    if re.search(r"(^|[^a-z])er\d*([^a-z]|$)", t) or "collet" in t:
        return "ER"
    return None


def _holder_keys(entries: List[str]) -> set:
    return {k for k in (holder_key(e) for e in entries) if k}


def _tw_ratio(cur: Optional[float], tw: Optional[float]) -> Optional[float]:
    return (cur / tw) if (cur is not None and tw) else None


def _endmill_findings(op: Dict[str, Any], tool: Dict[str, Any], rec: Optional[Dict[str, Any]],
                      usr: Optional[Dict[str, Any]], machine: Dict[str, Any], ctx: Dict[str, Any],
                      user_engagement: Dict[str, Optional[float]]) -> List[Dict[str, Any]]:
    """Findings for one end-mill-type operation from ToolWiz at the recommendation (``rec``) and at the op's own
    engagement (``usr``)."""
    cur = op["current"]
    kind = op["kind"]
    out: List[Dict[str, Any]] = []
    n_fl = tool["flutes"]
    d = tool["diameter_in"]
    base = usr or rec
    if rec is None and usr is None:
        return out

    # --- ToolWiz cannot find a safe cut --------------------------------------------------------------------------
    if rec is not None and not rec["feasible"]:
        out.append(_f("STOP", "toolwiz_infeasible", "ToolWiz finds no safe cut for this tool and material",
                      f"At its recommended engagement ToolWiz finds no feasible cut for the {d:.4f} in tool in {ctx['family']} "
                      f"(limited by {rec['limited_by']}).",
                      "Use a shorter stickout, a larger or stiffer tool, or a lighter cut; see the ToolWiz warnings for this tool."))
    if usr is not None and not usr["feasible"]:
        out.append(_f("STOP", "infeasible_at_engagement", "No safe cut at this operation's own stepdown / stepover",
                      f"With the operation's engagement (stepdown {_fi(cur['stepdown_in'])} in, stepover {_fi(cur['stepover_in'])} in) "
                      f"ToolWiz finds no feasible cut (limited by {usr['limited_by']}); its recommendation is stepdown "
                      f"{_fi((rec or {}).get('ap_in'))} in, stepover {_fi((rec or {}).get('ae_in'))} in.",
                      "Reduce the stepdown and/or stepover to ToolWiz's recommended values.",
                      toolwiz_stepdown_in=(rec or {}).get("ap_in"), toolwiz_stepover_in=(rec or {}).get("ae_in")))

    # --- spindle limit ----------------------------------------------------------------------------------------------
    if cur["rpm"] and cur["rpm"] > machine["max_rpm"] * 1.001:
        out.append(_f("STOP", "rpm_over_machine", "Spindle speed exceeds the machine maximum",
                      f"The operation asks for {cur['rpm']:.0f} rpm; the active machine tops out at {machine['max_rpm']:.0f} rpm.",
                      f"Set the spindle speed to ToolWiz's {base['rpm']} rpm or lower.", machine_max_rpm=machine["max_rpm"]))

    # --- geometry ---------------------------------------------------------------------------------------------------
    fl = tool["flute_length_in"]
    if cur["stepdown_in"] and fl and cur["stepdown_in"] > fl * 1.0001:
        out.append(_f("STOP", "stepdown_over_flute", "Stepdown is longer than the flutes",
                      f"Stepdown {_fi(cur['stepdown_in'])} in exceeds the flute length {_fi(fl)} in: the shank would plunge into the cut.",
                      f"Keep the stepdown within the flute length; ToolWiz's recommended stepdown is {_fi((rec or {}).get('ap_in'))} in.",
                      flute_length_in=fl))

    # --- chip load / speed / feed vs ToolWiz ----------------------------------------------------------------------
    basis = usr if usr is not None else rec
    where = "for the same engagement" if usr is not None else "at its recommended engagement"
    if basis is not None and basis["feasible"]:
        usr = basis                      # the comparisons below use ToolWiz's numbers for this op's engagement
        fz_cur = (cur["feed_ipm"] / (cur["rpm"] * n_fl)) if (cur["feed_ipm"] and cur["rpm"] and n_fl) else None
        r_fz = _tw_ratio(fz_cur, usr["chip_load_ipt"])
        if r_fz is not None:
            msg = (f"The operation's programmed chip load is {fz_cur:.5f} in/tooth ({cur['feed_ipm']:.2f} IPM at {cur['rpm']:.0f} rpm, "
                   f"{n_fl} flutes); ToolWiz gets {usr['chip_load_ipt']:.5f} in/tooth ({usr['feed_ipm']:.2f} IPM at {usr['rpm']} rpm) "
                   f"{where}, a ratio of {r_fz:.1f}x.")
            nums = dict(current_chip_load_ipt=round(fz_cur, 6), toolwiz_chip_load_ipt=usr["chip_load_ipt"], ratio_x=round(r_fz, 2),
                        toolwiz_rpm=usr["rpm"], toolwiz_feed_ipm=usr["feed_ipm"])
            if r_fz > CHIP_STOP_RATIO:
                out.append(_f("STOP", "chip_load_high", "Chip load is more than double ToolWiz's", msg,
                              f"Lower the feed to ToolWiz's {usr['feed_ipm']:.2f} IPM at {usr['rpm']} rpm for this engagement.", **nums))
            elif abs(r_fz - 1.0) > OFF_FRACTION:
                word = "above" if r_fz > 1 else "below"
                tail = (" A chip load this low rubs instead of cutting and wears the edge." if r_fz < 1 else "")
                out.append(_f("CAUTION", "chip_load_off", f"Chip load is more than 40% {word} ToolWiz's", msg + tail,
                              f"Move to ToolWiz's {usr['feed_ipm']:.2f} IPM at {usr['rpm']} rpm for this engagement.", **nums))
        if cur["rpm"] and abs(cur["rpm"] / usr["rpm"] - 1.0) > OFF_FRACTION and cur["rpm"] <= machine["max_rpm"] * 1.001:
            out.append(_f("CAUTION", "rpm_off", "Spindle speed is more than 40% away from ToolWiz's",
                          f"The operation runs {cur['rpm']:.0f} rpm; ToolWiz gives {usr['rpm']} rpm ({usr['sfm']} SFM) {where}.",
                          f"Use {usr['rpm']} rpm.", current_rpm=cur["rpm"], toolwiz_rpm=usr["rpm"], toolwiz_sfm=usr["sfm"]))
        if cur["feed_ipm"] and abs(cur["feed_ipm"] / usr["feed_ipm"] - 1.0) > OFF_FRACTION and r_fz is not None and abs(r_fz - 1.0) <= OFF_FRACTION:
            out.append(_f("CAUTION", "feed_off", "Feed rate is more than 40% away from ToolWiz's",
                          f"The operation feeds {cur['feed_ipm']:.2f} IPM; ToolWiz gives {usr['feed_ipm']:.2f} IPM {where}.",
                          f"Use {usr['feed_ipm']:.2f} IPM.", current_feed_ipm=cur["feed_ipm"], toolwiz_feed_ipm=usr["feed_ipm"]))

    # --- engagement vs recommendation ----------------------------------------------------------------------------
    if rec is not None and rec["feasible"]:
        if kind != "finish" and cur["stepdown_in"] and rec["ap_in"] and cur["stepdown_in"] > rec["ap_in"] * (1 + OFF_FRACTION):
            out.append(_f("CAUTION", "stepdown_high", "Stepdown is more than 40% above ToolWiz's recommendation",
                          f"Stepdown {_fi(cur['stepdown_in'])} in against ToolWiz's {_fi(rec['ap_in'])} in for this tool and material.",
                          f"Use a stepdown of {_fi(rec['ap_in'])} in.", current_stepdown_in=cur["stepdown_in"],
                          toolwiz_stepdown_in=rec["ap_in"]))
        if kind in ("adaptive", "pocket", "rough", "contour") and cur["stepover_in"] and rec["ae_in"] \
                and cur["stepover_in"] > rec["ae_in"] * (1 + OFF_FRACTION):
            out.append(_f("CAUTION", "stepover_high", "Stepover is more than 40% above ToolWiz's recommendation",
                          f"Stepover {_fi(cur['stepover_in'])} in against ToolWiz's {_fi(rec['ae_in'])} in.",
                          f"Use a stepover (optimal load) of {_fi(rec['ae_in'])} in.", current_stepover_in=cur["stepover_in"],
                          toolwiz_stepover_in=rec["ae_in"]))

    # --- stock to leave ---------------------------------------------------------------------------------------------
    if rec is not None and kind in ("adaptive", "pocket", "rough", "contour"):
        want_r, want_a = rec.get("stock_to_leave_radial_in"), rec.get("stock_to_leave_axial_in")
        have_r, have_a = cur["stock_radial_in"], cur["stock_axial_in"]
        if want_r and have_r is not None and have_r < want_r * 0.999:
            out.append(_f("CAUTION", "stock_radial_low", "Radial stock to leave is below ToolWiz's recommendation",
                          f"The operation leaves {_fi(have_r)} in radially; ToolWiz recommends at least {_fi(want_r)} in "
                          f"(1.5 x the predicted wall deflection plus springback) so the finishing pass can bring the wall to size.",
                          f"Set the radial stock to leave to {_fi(want_r)} in.", current_stock_in=have_r, toolwiz_stock_in=want_r))
        if want_a and have_a is not None and have_a < want_a * 0.999:
            out.append(_f("CAUTION", "stock_axial_low", "Axial stock to leave is below ToolWiz's recommendation",
                          f"The operation leaves {_fi(have_a)} in on the floor; ToolWiz recommends at least {_fi(want_a)} in.",
                          f"Set the axial stock to leave to {_fi(want_a)} in.", current_stock_in=have_a, toolwiz_stock_in=want_a))

    # --- runout / holder / reduced flutes / rubbing --------------------------------------------------------------
    ref = usr if (usr is not None and usr["feasible"]) else rec
    if ref is not None:
        if ref.get("runout_regime") == "reduced_flutes":
            out.append(_f("CAUTION", "reduced_flutes", "Only some flutes will cut at this chip load and runout",
                          f"ToolWiz finds {ref['flutes_cutting']} of {n_fl} flutes forming a chip at {ref['chip_load_ipt']:.5f} in/tooth with "
                          f"{ctx['runout']:.5f} in runout; all flutes would cut at a runout of {ref['tir_all_flutes_in']:.5f} in or less. "
                          "The cutting flutes wear faster and the others rub.",
                          "Use a lower-runout holder (shrink fit, hydraulic, powRgrip) or accept shorter tool life.",
                          flutes_cutting=ref["flutes_cutting"], tir_all_flutes_in=ref["tir_all_flutes_in"], runout_in=ctx["runout"]))
        for w in ref.get("warnings") or []:
            if "rubbing limit" in w:
                out.append(_f("CAUTION", "chip_near_rubbing", "Chip load is near the rubbing limit", w,
                              "Raise the chip load if the engagement allows, or use a lower-runout holder and a higher spindle speed."))
                break
        ha = rec.get("holder_advice") if rec else None
        if ha and ha.get("class") in ("precision", "ultra"):
            meas = tool.get("holder_runout_in")
            req_tir = ha.get("required_tir_in")
            hold = tool.get("holder")
            hk = holder_key(hold)
            avoid, good = _holder_keys(ha.get("avoid") or []), _holder_keys((ha.get("recommended") or []) + (ha.get("acceptable") or []))
            if meas is not None and req_tir and meas > req_tir * 1.0001:
                out.append(_f("CAUTION", "holder_runout", "Measured holder runout is above what this cut needs",
                              f"The holder's measured runout is {meas:.5f} in; this cut needs {req_tir:.5f} in or less ({ha['class']} class).",
                              "Recommended holders: " + ", ".join(ha.get("recommended") or []) + ".",
                              holder_runout_in=meas, required_tir_in=req_tir))
            elif hk and hk in avoid and hk not in good:
                out.append(_f("CAUTION", "holder_type", f"The {hold} holder is not suited to the runout this cut needs",
                              f"This cut needs {req_tir:.5f} in runout or less ({ha['class']} class); ToolWiz advises against this holder type.",
                              "Recommended holders: " + ", ".join(ha.get("recommended") or []) + ".", required_tir_in=req_tir))
            elif not hold:
                out.append(_f("INFO", "holder_unknown", "Holder not specified; this cut needs a low-runout holder",
                              f"This cut needs {req_tir:.5f} in runout or less ({ha['class']} class). {ha.get('reason', '')}".strip(),
                              "Recommended holders: " + ", ".join(ha.get("recommended") or []) + ".", required_tir_in=req_tir))

    # --- time saving at the recommended engagement -------------------------------------------------------------
    if rec is not None and rec["feasible"] and kind != "finish":
        ap, ae, fd = cur["stepdown_in"], cur["stepover_in"], cur["feed_ipm"]
        if kind == "slot" and ae is None:
            ae = d
        cur_mrr = ap * ae * fd if (ap and ae and fd) else (usr["mrr_in3_min"] if usr else None)
        if cur_mrr and rec["mrr_in3_min"] > cur_mrr * SAVINGS_MIN_SPEEDUP:
            sp = rec["mrr_in3_min"] / cur_mrr
            out.append(_f("INFO", "time_saving", "Faster at ToolWiz's recommended engagement",
                          f"At stepdown {_fi(rec['ap_in'])} in, stepover {_fi(rec['ae_in'])} in, {rec['feed_ipm']:.2f} IPM at {rec['rpm']} rpm, "
                          f"ToolWiz removes {rec['mrr_in3_min']:.3f} in^3/min against {cur_mrr:.3f} in^3/min for the operation as set, "
                          f"{sp:.1f}x faster ({(1 - 1 / sp) * 100:.0f}% less cutting time for the same volume).",
                          "Apply the recommended parameters (ToolWiz stays inside the deflection, chip load and holder limits).",
                          current_mrr_in3_min=round(cur_mrr, 4), toolwiz_mrr_in3_min=rec["mrr_in3_min"], speedup_x=round(sp, 2),
                          time_saving_pct=round((1 - 1 / sp) * 100)))
    return out


def _tslot_findings(op, tool, tw, g, machine, ctx) -> List[Dict[str, Any]]:
    """Findings for a slot mill / T-slot cutter operation from ``tslot_model``."""
    cur = op["current"]
    out: List[Dict[str, Any]] = []
    for msg in tw["critical"]:
        out.append(_f("STOP", "tslot_critical", "ToolWiz T-slot model: critical limit exceeded", msg,
                      "Change the cutter (larger neck, shorter reach) or reduce the slot."))
    kerf = tw["kerf_in"]
    if cur["rpm"] and cur["rpm"] > machine["max_rpm"] * 1.001:
        out.append(_f("STOP", "rpm_over_machine", "Spindle speed exceeds the machine maximum",
                      f"The operation asks for {cur['rpm']:.0f} rpm; the active machine tops out at {machine['max_rpm']:.0f} rpm.",
                      f"Set the spindle speed to ToolWiz's {tw['rpm']} rpm or lower.", machine_max_rpm=machine["max_rpm"]))
    sd = cur["stepdown_in"]
    if sd and sd > kerf * 1.0001:
        out.append(_f("STOP", "stepdown_over_kerf", "Stepdown is larger than the cutter's cutting thickness",
                      f"Stepdown {_fi(sd)} in is larger than the cutter's kerf (head thickness) {_fi(kerf)} in, so the head cannot cover the "
                      f"slot between levels and the neck or head will rub the uncut ridge. ToolWiz steps {_fi(tw['z_step_in'])} in.",
                      f"Set the stepdown to {_fi(tw['z_step_in'])} in or less.", current_stepdown_in=sd, kerf_in=kerf,
                      toolwiz_stepdown_in=tw["z_step_in"]))
    elif sd and tw["z_step_in"] and sd > tw["z_step_in"] * (1 + 0.05):
        out.append(_f("CAUTION", "stepdown_high", "Stepdown is above ToolWiz's axial step for this cutter",
                      f"Stepdown {_fi(sd)} in against ToolWiz's {_fi(tw['z_step_in'])} in (a fraction of the {_fi(kerf)} in kerf, so the face teeth overlap).",
                      f"Use {_fi(tw['z_step_in'])} in.", current_stepdown_in=sd, toolwiz_stepdown_in=tw["z_step_in"]))
    so = cur["stepover_in"]
    if so and tw["radial_depth_per_pass_in"]:
        r = so / tw["radial_depth_per_pass_in"]
        if r > 2.0:
            out.append(_f("STOP", "tslot_radial_high", "Radial depth per pass is more than double ToolWiz's",
                          f"Radial depth per pass {_fi(so)} in against ToolWiz's {_fi(tw['radial_depth_per_pass_in'])} in for this cutter and material "
                          f"({r:.1f}x): the thin neck carries the load.", f"Use {_fi(tw['radial_depth_per_pass_in'])} in per pass.",
                          current_radial_in=so, toolwiz_radial_in=tw["radial_depth_per_pass_in"], ratio_x=round(r, 2)))
        elif r > 1 + OFF_FRACTION:
            out.append(_f("CAUTION", "tslot_radial_high", "Radial depth per pass is more than 40% above ToolWiz's",
                          f"Radial depth per pass {_fi(so)} in against ToolWiz's {_fi(tw['radial_depth_per_pass_in'])} in.",
                          f"Use {_fi(tw['radial_depth_per_pass_in'])} in per pass.", current_radial_in=so,
                          toolwiz_radial_in=tw["radial_depth_per_pass_in"]))
    if cur["rpm"] and tw["rpm"] and abs(cur["rpm"] / tw["rpm"] - 1) > OFF_FRACTION and cur["rpm"] <= machine["max_rpm"] * 1.001:
        out.append(_f("CAUTION", "rpm_off", "Spindle speed is more than 40% away from ToolWiz's",
                      f"The operation runs {cur['rpm']:.0f} rpm; ToolWiz gives {tw['rpm']} rpm ({tw['sfm']} SFM) for this cutter.",
                      f"Use {tw['rpm']} rpm.", current_rpm=cur["rpm"], toolwiz_rpm=tw["rpm"]))
    if cur["feed_ipm"] and tw["feed_ipm"]:
        r = cur["feed_ipm"] / tw["feed_ipm"]
        if r > CHIP_STOP_RATIO:
            out.append(_f("STOP", "feed_high", "Lateral feed is more than double ToolWiz's",
                          f"The operation feeds {cur['feed_ipm']:.2f} IPM; ToolWiz gives {tw['feed_ipm']:.2f} IPM ({tw['chip_load_ipt']:.5f} in/tooth) "
                          f"for this cutter, a ratio of {r:.1f}x.", f"Lower the feed to {tw['feed_ipm']:.2f} IPM.",
                          current_feed_ipm=cur["feed_ipm"], toolwiz_feed_ipm=tw["feed_ipm"], ratio_x=round(r, 2)))
        elif abs(r - 1) > OFF_FRACTION:
            out.append(_f("CAUTION", "feed_off", "Lateral feed is more than 40% away from ToolWiz's",
                          f"The operation feeds {cur['feed_ipm']:.2f} IPM; ToolWiz gives {tw['feed_ipm']:.2f} IPM.",
                          f"Use {tw['feed_ipm']:.2f} IPM.", current_feed_ipm=cur["feed_ipm"], toolwiz_feed_ipm=tw["feed_ipm"]))
    if tw["provisional_geometry"]:
        out.append(_f("CAUTION", "tslot_provisional", "Cutter geometry is partly assumed",
                      f"ToolWiz assumed {', '.join(tw['provisional_geometry'])} for this cutter (neck diameter {_fi(g['neck_diameter'])} in, reach {_fi(g['reach'])} in); "
                      "the neck deflection and pass count depend on them.",
                      "Measure the neck diameter and reach (and tooth form) and put them in the tool definition."))
    for w in tw["warnings"][:2]:
        out.append(_f("CAUTION", "tslot_warning", w.split(":", 1)[0], w, "See the ToolWiz T-slot model notes."))
    return out


# ===================================================================================================================
# apply plans
# ===================================================================================================================

def _expr(kind: str, v: float) -> str:
    """Fusion expression string for a number (rpm / in/min / in / deg)."""
    if kind == "rpm":
        return f"{round(v)} rpm"
    if kind == "feed":
        return f"{v:.2f} in/min"
    if kind == "angle":
        return f"{v:.1f} deg"
    return f"{v:.5f} in"


def _apply_plans(op: Dict[str, Any], rec: Optional[Dict[str, Any]], usr: Optional[Dict[str, Any]],
                 tslot: Optional[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    """The parameter sets the advisor will let the apply step write for this op (Fusion parameter name -> expression).

    ``recommended``: ToolWiz's recommended speed, feed, stepdown, stepover / optimal load, stock to leave and ramp.
    ``keep_engagement``: speed and feed ToolWiz computes for the operation's own stepdown / stepover. None when ToolWiz
    found no feasible cut."""
    kind = op["kind"]
    plans: Dict[str, Dict[str, str]] = {}
    if tslot is not None:
        if tslot["feasible"]:
            plans["recommended"] = {"tool_spindleSpeed": _expr("rpm", tslot["rpm"]),
                                    "tool_feedCutting": _expr("feed", tslot["feed_ipm"]),
                                    "maximumStepdown": _expr("len", tslot["z_step_in"]),
                                    "stepover": _expr("len", tslot["radial_depth_per_pass_in"])}
    elif rec is not None and rec["feasible"]:
        p = {"tool_spindleSpeed": _expr("rpm", rec["rpm"]), "tool_feedCutting": _expr("feed", rec["feed_ipm"])}
        if kind != "finish":
            p["maximumStepdown"] = _expr("len", rec["ap_in"])
            if kind == "adaptive":
                p["optimalLoad"] = _expr("len", rec["ae_in"])
            elif kind in ("pocket", "rough", "contour"):
                p["stepover"] = _expr("len", rec["ae_in"])
            if kind in ("adaptive", "pocket", "rough", "contour"):
                if rec.get("stock_to_leave_radial_in"):
                    p["stockToLeave"] = _expr("len", rec["stock_to_leave_radial_in"])
                if rec.get("stock_to_leave_axial_in"):
                    p["verticalStockToLeave"] = _expr("len", rec["stock_to_leave_axial_in"])
            if rec.get("ramp_angle_deg"):
                p["tool_rampAngle"] = _expr("angle", rec["ramp_angle_deg"])
                if rec.get("ramp_feed_ipm"):
                    p["tool_feedRamp"] = _expr("feed", rec["ramp_feed_ipm"])
            if rec.get("plunge_feed_ipm"):
                p["tool_feedPlunge"] = _expr("feed", rec["plunge_feed_ipm"])
        plans["recommended"] = p
        if usr is not None and usr["feasible"]:
            plans["keep_engagement"] = {"tool_spindleSpeed": _expr("rpm", usr["rpm"]),
                                        "tool_feedCutting": _expr("feed", usr["feed_ipm"])}
    return plans or None


def _expr_equal(given: str, want: str, kind: str) -> bool:
    """True when expression ``given`` equals ``want`` after unit conversion, within 0.5 % or half the last digit given."""
    a, b = parse_quantity(given, kind), parse_quantity(want, kind)
    if a is None or b is None:
        return False
    m = re.match(r"^\s*[-+]?(\d*\.?(\d*))", given)
    dec = len(m.group(2)) if m and m.group(2) is not None else 0
    num = float(re.match(r"^\s*([-+]?\d*\.?\d*)", given).group(1) or 0) or 1.0
    unit_factor = abs(a / num) if num else 1.0
    return abs(a - b) <= max(0.005 * abs(b), 0.5 * 10.0 ** (-dec) * unit_factor)


def validate_apply(op_id: str, params: Any, last: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """Check an apply request against the last advisor result: every parameter name must be on the allow-list and every
    value must equal ToolWiz's value for that op (the ``recommended`` or ``keep_engagement`` plan).

    Returns ``{"ok", "accepted": {name: expr}, "rejected": {name: reason}, "error"}``."""
    last = last if last is not None else get_last()
    out: Dict[str, Any] = {"ok": False, "accepted": {}, "rejected": {}, "error": None}
    if not last:
        out["error"] = "No advisor result yet: run POST /api/setup_advisor first; only ToolWiz's own values can be applied."
        return out
    if not isinstance(params, dict) or not params:
        out["error"] = "'params' must be a non-empty object {Fusion parameter name: expression string}"
        return out
    ops = [o for o in last.get("operations", []) if o.get("op_id") == op_id]
    if not ops:
        out["error"] = f"Operation {op_id!r} is not in the last advisor result."
        return out
    plans = ops[0].get("apply_plan") or {}
    if not plans:
        out["error"] = f"ToolWiz has no recommended values for {op_id!r} (no feasible cut, or the op was not analysed)."
        return out
    for name, expr in params.items():
        kind = PARAM_KINDS.get(name)
        if kind is None:
            out["rejected"][name] = "parameter is not on the allow-list " + ", ".join(sorted(PARAM_KINDS))
            continue
        if not isinstance(expr, str) or not expr.strip():
            out["rejected"][name] = "value must be an expression string with units, e.g. '0.0625 in'"
            continue
        cands = [p[name] for p in plans.values() if name in p]
        if not cands:
            out["rejected"][name] = "ToolWiz has no recommended value for this parameter on this operation"
        elif not any(_expr_equal(expr, c, kind) for c in cands):
            out["rejected"][name] = f"value {expr!r} is not a ToolWiz value for this operation; ToolWiz: {' or '.join(sorted(set(cands)))}"
        else:
            out["accepted"][name] = expr
    out["ok"] = bool(out["accepted"]) and not out["rejected"]
    if out["rejected"]:
        out["error"] = "Only ToolWiz-recommended values can be applied: " + "; ".join(f"{k}: {v}" for k, v in out["rejected"].items())
    return out


# ===================================================================================================================
# strategy suggestions
# ===================================================================================================================

def _spec(tool: Dict[str, Any]) -> Dict[str, Any]:
    return {"diameter": tool["diameter_in"], "flutes": tool["flutes"], "flute_length": tool["flute_length_in"],
            "shank_diameter": tool["shank_diameter_in"], "stickout": tool["stickout_in"],
            "coating": tool.get("coating") or "Uncoated", "geometry": "Square",
            "name": (tool.get("description") or f"{tool['diameter_in']:.4f} in end mill")}


def _compact_option(o: Dict[str, Any]) -> Dict[str, Any]:
    t = o.get("tool") or {}
    return {"name": o.get("name"), "strategy": o.get("strategy"), "tool_diameter_in": t.get("diameter"),
            "levels": o.get("levels"), "ap_in": o.get("ap"), "ae_in": o.get("ae"), "rpm": o.get("rpm"),
            "feed_ipm": o.get("feed_ipm"), "path_length_in": o.get("path_length_in"),
            "cycle_time_min": o.get("cycle_time_min"), "relative_tool_life": o.get("relative_tool_life"),
            "tool_wear_per_part": o.get("tool_wear_per_part"), "feasible": o.get("feasible"),
            "risks": list(o.get("risks") or [])[:3]}


def _strategy_request(op: Dict[str, Any], tool: Dict[str, Any], others: List[Dict[str, Any]],
                      ctx: Dict[str, Any]) -> Tuple[Optional[Dict[str, Any]], Optional[str]]:
    """The ``strategy_planner.compare`` request for an op (and None plus a reason when the op's geometry is missing)."""
    kind, g, D = op["kind"], op["geometry"], tool["diameter_in"]
    base = {"family": ctx["family"], "alloy": ctx["alloy"], "aggressiveness": ctx["aggressiveness"],
            "runout": ctx["runout"], "model": ctx["model"]}
    depth, length = g.get("depth_in"), g.get("toolpath_length_in")
    if kind == "tslot":
        H = g.get("slot_height_in") or tool.get("kerf_in")
        R = g.get("radial_depth_in")
        if not (H and R and length):
            return None, "T-slot comparison needs the slot's radial depth and the toolpath length from the add-in."
        tg, prov = _tslot_geometry(tool)
        own = {"geometry": {"diameter": tg["diameter"], "kerf": tg["kerf"], "neck_diameter": tg["neck_diameter"],
                            "reach": tg["reach"], "shank_diameter": tg["shank_diameter"], "teeth": tg["teeth"],
                            "tooth_form": tg["tooth_form"], "coating": tg["coating"], "provisional": prov,
                            "name": f"{tool.get('description') or 'op cutter'} (this operation)"}}
        cands = [own]
        import tslot_model
        for tid, t in tslot_model.load_shop_tools().items():
            kerf_in, dia_in = t["kerf_mm"] / MM_PER_IN, t["diameter_mm"] / MM_PER_IN
            if abs(dia_in - tg["diameter"]) <= 0.03 * dia_in and abs(kerf_in - tg["kerf"]) <= 0.03 * kerf_in:
                continue
            if kerf_in <= H * 1.001:
                cands.append({"id": tid})
        if len(cands) < 2:
            return None, "No other shop T-slot cutter fits this slot height to compare against."
        return dict(base, feature={"type": "tslot", "slot_height": H, "radial_depth": R, "length": length},
                    candidate_tools=cands[:MAX_STRATEGY_CANDIDATES + 1]), None
    channel = g.get("channel_width_in")
    if kind == "adaptive":
        if not (channel and channel <= 3.0 * D):
            return None, None            # not in a narrow channel: nothing to compare
        width = channel
        feature = {"type": "slot", "width": width}
    elif kind in ("slot", "contour"):
        if g.get("tabs") and kind != "slot":
            feature = {"type": "profile_cutout", "tabs": g["tabs"]}
            if channel:
                feature["channel_width"] = channel
            width = None
        else:
            width = g.get("slot_width_in") or channel or D
            feature = {"type": "slot", "width": width}
    else:
        return None, None
    if not (depth and length):
        return None, "Strategy comparison needs the feature depth (op heights) and the toolpath length from the add-in."
    feature.update({"depth": depth, "length": length})
    cands, seen = [_spec(tool)], {(round(D, 5), tool["flutes"])}
    for o in others:
        t = o["tool"]
        if o["kind"] in ("tslot", "hole", "face") or not t.get("diameter_in") or "mill" not in (t.get("type") or "end mill") and t.get("type"):
            continue
        if width is not None and t["diameter_in"] > width * 1.0001:
            continue
        key = (round(t["diameter_in"], 5), t.get("flutes"))
        if key in seen:
            continue
        seen.add(key)
        full, _ = _complete_tool(t)
        cands.append(_spec(full))
    cands.sort(key=lambda c: -c["diameter"])
    if len(cands) < 2 and kind != "slot":
        return None, "No other end mill in this setup to compare against."
    if len(cands) < 2:
        return None, "No smaller end mill in this setup to compare a different strategy against."
    return dict(base, feature=feature, candidate_tools=cands[:MAX_STRATEGY_CANDIDATES]), None


def _strategy_suggestion(op, tool, others, physics, machine_profile, ctx) -> Tuple[Optional[Dict[str, Any]], Optional[str]]:
    """Run the planner for one op; returns (suggestion, note)."""
    import strategy_planner
    try:
        req, note = _strategy_request(op, tool, others, ctx)
        if req is None:
            return None, note
        cmp_ = strategy_planner.compare(req, physics=physics, machine_profile=machine_profile)
    except (ValueError, KeyError) as e:
        return None, f"strategy comparison skipped: {e}"
    opts = cmp_.get("options") or []
    best = next((o for o in opts if o.get("name") == cmp_.get("recommended")), None)
    if best is None:
        return None, "strategy comparison found no feasible option"
    kind, D = op["kind"], tool["diameter_in"]
    if kind == "tslot":
        curo = next((o for o in opts if "(this operation)" in str(o.get("name"))), None)
    elif kind == "adaptive":
        curo = next((o for o in opts if o["strategy"] == "adaptive" and abs((o["tool"] or {}).get("diameter", 0) - D) < 1e-6), None)
    else:
        curo = next((o for o in opts if o["strategy"] in ("contour_slot", "contour_slot_side_passes")
                     and abs((o["tool"] or {}).get("diameter", 0) - D) < 1e-6), None)
    same = curo is not None and curo is best
    saved = pct = None
    if curo is not None and curo.get("feasible") and best.get("feasible") and not same:
        saved = round(curo["cycle_time_min"] - best["cycle_time_min"], 4)
        pct = round(100.0 * saved / curo["cycle_time_min"]) if curo["cycle_time_min"] else None
    sug = {"op_id": op["op_id"], "name": op["name"], "feature": cmp_.get("feature"),
           "recommended": cmp_.get("recommended"), "recommended_option": _compact_option(best),
           "current_option": _compact_option(curo) if curo else None, "same_as_current": same,
           "time_saved_min": saved, "time_saved_pct": pct, "reasoning": list(cmp_.get("reasoning") or [])[:6],
           "tab_advice": list(cmp_.get("tab_advice") or [])[:3],
           "options": [_compact_option(o) for o in opts][:8]}
    return sug, None


# ===================================================================================================================
# orchestration
# ===================================================================================================================

def _short(op_tool: Dict[str, Any]) -> Dict[str, Any]:
    return {k: op_tool.get(k) for k in ("description", "type", "number", "diameter_in", "flutes", "flute_length_in",
                                         "shank_diameter_in", "stickout_in", "coating", "holder", "kerf_in")}


def _oversight_findings(op, tool, res, ctx) -> List[Dict[str, Any]]:
    """Per-operation findings of ``oversight_engine`` (tool/coating fit, shaft rub, deep slots...) as advisor findings."""
    try:
        import oversight_engine
        req = {"family": ctx["family"], "alloy": ctx["alloy"], "operation": res.operation, "coating": tool.get("coating") or "",
               "diameter": tool["diameter_in"], "flutes": tool["flutes"], "fluteLength": tool["flute_length_in"],
               "shankDiameter": tool["shank_diameter_in"], "runout": ctx["runout"], "tool": "Carbide Endmill",
               "coating_ambiguous": not tool.get("coating")}
        rep = oversight_engine.evaluate_holistic_oversight(req, dataclasses.asdict(res), feature_geometry=op["geometry"].get("feature_geometry"))
    except Exception:
        return []
    skip = ("Continuous Shaft Taper Modeled", "Low Flute Count", "Large v1 vs. v2")
    if not tool.get("coating"):
        skip += ("Non-Thermal Coating", "AlTiN / TiAlN Coating")     # the real coating is unknown: do not judge it
    out = []
    for f in rep.findings:
        if any(f.title.startswith(s) for s in skip):
            continue
        out.append(_f(f.severity, f"oversight_{f.category}", f.title, f.detail, f.recommendation))
    return out


def _order(findings: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    rank = {"STOP": 0, "CAUTION": 1, "INFO": 2}
    return sorted(findings, key=lambda f: rank.get(f["severity"], 3))


def advise(setup: Dict[str, Any], *, family: Optional[str] = None, alloy: Optional[str] = None,
           aggressiveness: float = 0.5, runout: Optional[float] = None, model: str = "v2", physics: Any = None,
           machine_profile: Optional[Dict[str, Any]] = None, use_llm: bool = False,
           llm: Optional[Callable[[str, str], Any]] = None, strategies: bool = True,
           api_key: Optional[str] = None) -> Dict[str, Any]:
    """Audit a Fusion setup snapshot against ToolWiz. See docs/SETUP_ADVISOR.md for the accepted ``setup`` and the result.

    ``aggressiveness`` 0..1 (a value above 1 is read as a percentage); ``runout`` inches (default 0.0002);
    ``llm`` is ``(system, prompt) -> text | {"text": ...}`` (default: Gemini through ``ai_machinist``). Raises
    ValueError on bad input. The result is stored for ``get_last()``."""
    import strategy_planner
    norm = normalize_setup(setup)
    fam = (family or norm["family"] or "").strip()
    alo = (alloy if alloy is not None else norm["alloy"]) or ""
    if not fam and not all(o.get("family") for o in norm["ops"]):
        raise ValueError("'family' (the ToolWiz material family, e.g. 'Titanium Alloy') is required")
    agg = float(aggressiveness)
    agg = agg / 100.0 if agg > 1.0 else agg
    if not 0.0 <= agg <= 1.0:
        raise ValueError("'aggressiveness' must be between 0 and 1 (0.5 = relatively safe)")
    ro = 0.0002 if runout is None else float(runout)
    if ro < 0:
        raise ValueError("'runout' must be >= 0")
    mdl = str(model or "v2").lower()
    if mdl not in ("v1", "v2"):
        raise ValueError("'model' must be 'v1' or 'v2'")
    physics = physics or strategy_planner._physics()
    machine = strategy_planner.machine_defaults(machine_profile)
    base_ctx = {"family": fam, "alloy": alo, "aggressiveness": agg, "runout": ro, "model": mdl}

    ops_out: List[Dict[str, Any]] = []
    strat_out: List[Dict[str, Any]] = []
    strat_notes: List[str] = []
    setup_ops: List[Dict[str, Any]] = []
    cache: Dict[Any, Any] = {}
    ops = norm["ops"]

    for op in ops:
        ctx = dict(base_ctx)
        if op.get("family"):
            ctx["family"], ctx["alloy"] = str(op["family"]), str(op.get("alloy") or "")
        tool0, kind, cur = op["tool"], op["kind"], op["current"]
        entry: Dict[str, Any] = {
            "op_id": op["op_id"], "name": op["name"], "setup": op["setup"], "strategy": op["strategy"], "kind": kind,
            "tool": _short(tool0), "current": {**cur, "chip_load_ipt": None, "mrr_in3_min": None}, "geometry": {
                k: v for k, v in op["geometry"].items() if k != "feature_geometry" and v is not None},
            "toolwiz": {"recommended": None, "at_current_engagement": None, "tslot": None},
            "findings": [], "apply_plan": None, "notes": []}
        fl = tool0.get("flutes")
        if cur["rpm"] and cur["feed_ipm"] and fl:
            entry["current"]["chip_load_ipt"] = round(cur["feed_ipm"] / (cur["rpm"] * fl), 6)
        if cur["stepdown_in"] and (cur["stepover_in"] or kind == "slot") and cur["feed_ipm"]:
            ae = cur["stepover_in"] if cur["stepover_in"] else tool0["diameter_in"]
            if ae:
                entry["current"]["mrr_in3_min"] = round(cur["stepdown_in"] * ae * cur["feed_ipm"], 4)
        rec = usr = tsl = None
        rec_res = usr_res = None
        tool = tool0
        try:
            if kind == "hole":
                entry["findings"].append(_f("INFO", "not_analysed", "Hole-making operation not analysed",
                                            "The setup advisor checks milling operations; use the drilling / tapping calculator for this one.",
                                            "Run the ToolWiz calculator for this tool."))
            elif not tool0.get("diameter_in"):
                entry["findings"].append(_f("INFO", "no_tool", "No tool diameter in the snapshot",
                                            "The add-in sent no usable tool geometry for this operation, so ToolWiz was not run.",
                                            "Update the add-in snapshot (tool diameter, flutes, flute length, stickout)."))
            elif kind == "tslot":
                tool, notes = tool0, []
                if cur["stepdown_in"] is None and cur["stepover_in"] is None and not cur["rpm"]:
                    notes.append("no cutting parameters in the snapshot")
                H = op["geometry"].get("slot_height_in") or tool0.get("kerf_in")
                out_t, g, prov = _run_tslot(physics, machine, ctx, tool0, H, op["geometry"].get("radial_depth_in"))
                tsl = _tslot_dict(out_t, g, prov)
                entry["toolwiz"]["tslot"] = tsl
                entry["findings"].extend(_tslot_findings(op, tool0, tsl, g, machine, ctx))
                entry["notes"].extend(notes)
            else:
                tool, notes = _complete_tool(tool0)
                entry["notes"].extend(notes)
                if tool0.get("coating") is None:
                    entry["notes"].append("coating unknown (generic or missing): ToolWiz applied no coating factor")
                opn = _KIND_OPERATION.get(kind, "Roughing")
                key_r = (opn, tool["diameter_in"], tool["flutes"], tool["flute_length_in"], tool["stickout_in"], tool.get("coating"), ctx["family"], ctx["alloy"], None, None)
                rec_res = cache.get(key_r) or _run_endmill(physics, machine, ctx, tool, opn, None, None)
                cache[key_r] = rec_res
                rec = _cut_dict(rec_res, tool["flutes"])
                if ctx["model"] == "v2" and rec["model"] != "v2":
                    entry["notes"].append("ToolWiz fell back to the v1 model for this tool: " + str(rec_res.model_note)[:200])
                depth = cur["stepdown_in"]
                width = tool["diameter_in"] if kind == "slot" else cur["stepover_in"]
                if (depth or (width and kind != "slot")) and kind not in ("hole",):
                    key_u = key_r[:-2] + (depth, width)
                    usr_res = cache.get(key_u) or _run_endmill(physics, machine, ctx, tool, opn, depth, width)
                    cache[key_u] = usr_res
                    usr = _cut_dict(usr_res, tool["flutes"])
                entry["toolwiz"]["recommended"], entry["toolwiz"]["at_current_engagement"] = rec, usr
                entry["findings"].extend(_endmill_findings(op, tool, rec, usr, machine, ctx, {"depth": depth, "width": width}))
                entry["findings"].extend(_oversight_findings(op, tool, usr_res or rec_res, ctx))
        except Exception as e:      # ToolWiz could not be run for this op: report, keep going
            entry["findings"].append(_f("INFO", "toolwiz_error", "ToolWiz could not be run for this operation",
                                        f"{type(e).__name__}: {e}"[:300], "Check the tool geometry and material in the snapshot."))
        entry["apply_plan"] = _apply_plans(op, rec, usr, tsl) if kind != "hole" else None

        # strategy suggestion
        if strategies and tool0.get("diameter_in") and kind in ("slot", "contour", "adaptive", "tslot"):
            sug, note = _strategy_suggestion(op, tool if kind != "tslot" else tool0, [o for o in ops if o is not op], physics, machine_profile, ctx)
            if sug:
                strat_out.append(sug)
                if not sug["same_as_current"] and sug["time_saved_pct"] and sug["time_saved_pct"] >= STRATEGY_MIN_SAVING * 100:
                    best, curo = sug["recommended_option"], sug["current_option"]
                    entry["findings"].append(_f(
                        "INFO", "strategy", f"Strategy: {best['name']} is faster than the current approach",
                        f"ToolWiz's strategy planner estimates {best['cycle_time_min']:.2f} min per part for {best['name']} against "
                        f"{curo['cycle_time_min']:.2f} min for the current approach, saving {sug['time_saved_min']:.2f} min "
                        f"({sug['time_saved_pct']:.0f}%) at similar tool wear (wear per part {best['tool_wear_per_part']:.2f}x against {curo['tool_wear_per_part']:.2f}x).",
                        "See the strategy suggestion for the options and the reasoning.",
                        recommended_cycle_time_min=best["cycle_time_min"], current_cycle_time_min=curo["cycle_time_min"],
                        time_saved_min=sug["time_saved_min"], time_saved_pct=sug["time_saved_pct"]))
            elif note:
                strat_notes.append(f"{op['name']}: {note}")
        entry["findings"] = _order(entry["findings"])
        ops_out.append(entry)
        setup_ops.append({
            "op_id": op["op_id"], "name": op["name"], "setup": op["setup"], "kind": kind,
            "tool_number": tool0.get("number"), "tool_diameter_in": tool0.get("diameter_in"),
            "stock_radial_in": cur["stock_radial_in"], "rest_machining": op.get("rest_machining"),
            "toolwiz_stock_radial_in": (rec or {}).get("stock_to_leave_radial_in"),
            "toolwiz_stock_axial_in": (rec or {}).get("stock_to_leave_axial_in")})

    import oversight_engine
    setup_findings = [_f(f.severity, f"setup_{f.category}", f.title, f.detail, f.recommendation)
                      for f in oversight_engine.evaluate_setup_oversight(setup_ops, norm.get("audit"))]
    setup_findings = _order(setup_findings)

    all_f = [f for o in ops_out for f in o["findings"]] + setup_findings
    n_stop = sum(1 for f in all_f if f["severity"] == "STOP")
    n_caution = sum(1 for f in all_f if f["severity"] == "CAUTION")
    n_info = sum(1 for f in all_f if f["severity"] == "INFO")
    result: Dict[str, Any] = {
        "success": True, "generated_at": datetime.datetime.now().isoformat(timespec="seconds"),
        "document": norm.get("document"),
        "settings": {"family": fam, "alloy": alo, "aggressiveness": agg, "runout_in": ro, "model": mdl,
                     "machine_max_rpm": machine["max_rpm"]},
        "summary": {"operations": len(ops_out), "stop": n_stop, "caution": n_caution, "info": n_info,
                    "verdict": "STOP" if n_stop else ("CAUTION" if n_caution else "PASS")},
        "operations": ops_out, "setup_findings": setup_findings, "strategy_suggestions": strat_out,
        "strategy_notes": strat_notes + list(norm["notes"]),
        "narrative": None, "narrative_check": {"ok": True, "rejected_numbers": [], "checked": 0},
        "narrative_note": None if use_llm else "LLM narrative not requested (use_llm: false).",
    }
    if use_llm:
        text, check, note = narrate(result, llm=llm, api_key=api_key)
        result["narrative"], result["narrative_check"], result["narrative_note"] = text, check, note
    set_last(result)
    return result


# ===================================================================================================================
# LLM narrative (grounded, numeric-guarded)
# ===================================================================================================================

NARRATIVE_SYSTEM = (
    "You are a senior CNC applications engineer explaining a ToolWiz setup review to the machinist who owns the job. "
    "ToolWiz is the only source of numbers. You never produce, estimate, convert, round, add, subtract or compare "
    "numbers yourself: every speed, feed, chip load, rpm, SFM, depth, width, stock, time or ratio you write must be copied "
    "exactly, with its units, from the JSON you are given. If a number you would like to quote is not in the JSON, "
    "describe it in words instead. Do not invent findings; explain, prioritise and add toolpath-strategy reasoning in words.")

NARRATIVE_PROMPT = (
    "Below is the complete ToolWiz result for a Fusion 360 setup (JSON). Write a short, plain-language review for the machinist:\n"
    "1. What to fix first (every STOP finding, in order of risk), naming the operation.\n"
    "2. What to improve next (CAUTION findings), grouped sensibly.\n"
    "3. Toolpath strategy: explain in words why the recommended strategy suggestions make sense or when to ignore them.\n"
    "4. Time and tool-life opportunities (INFO findings).\n"
    "Rules: quote a number only by copying it verbatim from the JSON; no unit conversions, no new percentages or ratios, no "
    "totals you compute; no digits at all other than copied values. Refer to operations by their name. Keep it under 350 words.\n\n"
    "ToolWiz result:\n")

STRICT_SUFFIX = (
    "\n\nYour previous answer contained numbers that are not in the JSON: {bad}. Rewrite the review. Use NO digits except values copied "
    "verbatim from the JSON (same digits, same units). Where unsure, leave the number out and describe the quantity in words.")


def llm_view(result: Dict[str, Any]) -> Dict[str, Any]:
    """The compact, numbers-only-from-ToolWiz view of a result that the LLM is shown and the guard checks against."""
    def keep(d: Optional[Dict[str, Any]], keys: Tuple[str, ...]) -> Optional[Dict[str, Any]]:
        return {k: d.get(k) for k in keys if d.get(k) is not None} if d else None
    cut_keys = ("rpm", "sfm", "feed_ipm", "chip_load_ipt", "ap_in", "ae_in", "mrr_in3_min", "deflection_in", "feasible",
                "limited_by", "runout_regime", "flutes_cutting", "stock_to_leave_radial_in", "stock_to_leave_axial_in",
                "ramp_angle_deg")
    ops = []
    for o in result["operations"]:
        tw = o["toolwiz"]
        ops.append({
            "name": o["name"], "kind": o["kind"], "strategy": o["strategy"],
            "tool": keep(o["tool"], ("description", "diameter_in", "flutes", "holder")),
            "current": {k: v for k, v in o["current"].items() if v is not None},
            "toolwiz_recommended": keep(tw["recommended"], cut_keys) or keep(tw["tslot"], (
                "rpm", "sfm", "feed_ipm", "chip_load_ipt", "kerf_in", "z_step_in", "radial_depth_per_pass_in")),
            "toolwiz_at_current_engagement": keep(tw["at_current_engagement"], cut_keys),
            "findings": [{k: f[k] for k in ("severity", "title", "detail", "recommendation")} for f in o["findings"]],
            "apply_plan": o.get("apply_plan")})
    return {
        "summary": result["summary"], "settings": {k: result["settings"][k] for k in ("family", "alloy")},
        "operations": ops,
        "setup_findings": [{k: f[k] for k in ("severity", "title", "detail", "recommendation")} for f in result["setup_findings"]],
        "strategy_suggestions": [{
            "operation": s["name"], "recommended": s["recommended"], "same_as_current": s["same_as_current"],
            "recommended_option": s["recommended_option"], "current_option": s["current_option"],
            "time_saved_min": s["time_saved_min"], "time_saved_pct": s["time_saved_pct"], "reasoning": s["reasoning"]}
            for s in result["strategy_suggestions"]],
    }


def _llm_text(r: Any) -> Tuple[Optional[str], Optional[str]]:
    if isinstance(r, dict):
        return (r.get("text") or r.get("reply") or None), r.get("error")
    return (str(r).strip() or None) if r is not None else None, None


def narrate(result: Dict[str, Any], llm: Optional[Callable[[str, str], Any]] = None,
            api_key: Optional[str] = None) -> Tuple[Optional[str], Dict[str, Any], Optional[str]]:
    """LLM narrative for a result. Returns ``(narrative | None, narrative_check, note)``.

    The prompt contains only ``llm_view(result)``. Every number in the reply must be in that view
    (``numeric_guard.check_numbers``); the first failure retries once with a stricter prompt, a second failure returns
    ``narrative None`` with ``{"ok": False, "rejected_numbers": [...]}``. Without an API key (and no ``llm``) the
    narrative is None with an explanatory note. Never raises."""
    if llm is None:
        import ai_machinist
        if not ai_machinist.api_key_available(api_key):
            return None, {"ok": True, "rejected_numbers": [], "checked": 0}, \
                "No LLM API key configured (set GEMINI_API_KEY); showing the deterministic findings only."

        def llm(system: str, prompt: str) -> Any:        # noqa: E306
            return ai_machinist.generate_text(system, prompt, api_key=api_key)
    view = llm_view(result)
    prompt = NARRATIVE_PROMPT + json.dumps(view, indent=1)
    bad: List[str] = []
    check: Dict[str, Any] = {"ok": False, "rejected_numbers": [], "checked": 0}
    for attempt in range(2):
        try:
            text, err = _llm_text(llm(NARRATIVE_SYSTEM, prompt if attempt == 0 else prompt + STRICT_SUFFIX.format(bad=", ".join(bad[:12]))))
        except Exception as e:
            return None, {"ok": True, "rejected_numbers": [], "checked": 0}, f"LLM call failed: {type(e).__name__}: {e}"[:200]
        if not text:
            return None, {"ok": True, "rejected_numbers": [], "checked": 0}, f"The LLM returned no text{': ' + err if err else ''}."
        check = numeric_guard.check_numbers(text, view)
        if check["ok"]:
            check["attempts"] = attempt + 1
            return text, check, None
        bad = check["rejected_numbers"]
    check["attempts"] = 2
    return None, check, ("The LLM narrative was rejected because it contained numbers that are not in the ToolWiz result "
                         f"({', '.join(check['rejected_numbers'][:8])}); showing the deterministic findings only.")
