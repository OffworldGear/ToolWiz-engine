"""The tools the chat model can call. Every one is backed by ToolWiz; none returns a number the model made up.

``TOOLS`` lists the specs (strict-compatible JSON schemas: flat objects, ``additionalProperties: false``); ``run_tool`` executes
one call against a ``ToolContext`` (the conversation's assumptions and proposals) and returns a JSON-able dict
(``success: false`` + ``error`` on failure). Nothing here changes Fusion: ``propose_fusion_change`` only queues a proposal that
the owner approves in the chat and then confirms in Fusion.
"""
from __future__ import annotations

import json
import time
from dataclasses import dataclass, field
from typing import Any, Callable, Dict, List, Optional

import fusion_bridge
import setup_advisor

from . import assumptions as asm
from .providers.base import ToolSpec

STALE_AFTER_S = 120
MAX_RESULT_CHARS = 120_000
NUMBERS_RULE = (" Every number you tell the owner must be copied from a tool result in this conversation (never estimated or "
                "recalled).")

_STR, _NUM, _INT, _BOOL = {"type": "string"}, {"type": "number"}, {"type": "integer"}, {"type": "boolean"}


def _obj(props: Dict[str, Any], required: Optional[List[str]] = None) -> Dict[str, Any]:
    return {"type": "object", "properties": props, "required": required or [], "additionalProperties": False}


def _d(t: Dict[str, Any], text: str) -> Dict[str, Any]:
    return dict(t, description=text)


_APPLY_PARAMS = {n: _d(_STR, "expression with units, e.g. '0.0625 in', '12000 rpm', '40 in/min'; must equal ToolWiz's value")
                 for n in sorted(fusion_bridge.APPLY_ALLOWED_PARAMS)}
_FIELDS = {
    "coating": _d(_STR, "coating name: AlTiN, TiAlN, AlCrN, ZrN, DLC, Diamond, TiSiN, TiCN, TiN, Uncoated"),
    "BMC": _d(_STR, "Fusion base material code, e.g. carbide, hss"),
    "GRADE": _d(_STR, "grade text"),
    "comment": _d(_STR, "comment text"),
    "description": _d(_STR, "full replacement description"),
    "add_keywords": _d({"type": "array", "items": _STR}, "words to add to the description, e.g. staggered"),
    "remove_keywords": _d({"type": "array", "items": _STR}, "words to remove from the description"),
}
_CAND = _obj({
    "tool_number": _INT, "diameter": _d(_NUM, "inches"), "flutes": _INT, "flute_length": _d(_NUM, "inches"),
    "shank_diameter": _d(_NUM, "inches"), "stickout": _d(_NUM, "inches"), "coating": _STR,
    "geometry": _d(_STR, "Square, Radiused, Ball"), "shop_tool_id": _d(_STR, "id from data/shop_tools.json (T-slot cutters)")})

TOOLS: List[ToolSpec] = [
    ToolSpec("get_live_setup",
             "The Fusion setup the add-in last sent to ToolWiz: document, operations (tool, current speeds, feeds, stepdown, stepover, stock "
             "to leave, geometry) and how old the snapshot is. Says when Fusion is not connected or the snapshot is stale. "
             "refresh: true first asks the add-in for a fresh snapshot (takes a few seconds)." + NUMBERS_RULE,
             _obj({"refresh": _BOOL})),
    ToolSpec("run_setup_advisor",
             "Run the ToolWiz Setup Advisor on the live Fusion setup with this conversation's assumptions applied: STOP / CAUTION / INFO "
             "findings per operation, ToolWiz's recommended numbers, the values that can be applied (apply_plan) and strategy suggestions. "
             "Needs the material (family) from the owner unless an assumption or argument gives it." + NUMBERS_RULE,
             _obj({"family": _d(_STR, "ToolWiz material family, e.g. 'Titanium Alloy'"), "alloy": _STR,
                   "aggressiveness": _d(_NUM, "0..1, 0.5 = relatively safe"), "runout_in": _d(_NUM, "holder runout, inches"),
                   "model": {"type": "string", "enum": ["v1", "v2"]}, "strategies": _BOOL})),
    ToolSpec("toolwiz_calculate",
             "ToolWiz speeds and feeds for one cut (rpm, feed, SFM, chip load, depth, width, deflection, ramp and plunge feeds, feasibility). "
             "Assumptions for the tool (coating, runout, material) are applied." + NUMBERS_RULE,
             _obj({"family": _STR, "alloy": _STR, "operation": _d(_STR, "Roughing, Finishing, Slotting, Adaptive Roughing, ..."),
                   "tool_number": _INT, "diameter": _d(_NUM, "inches"), "flutes": _INT, "flute_length": _NUM, "shank_diameter": _NUM,
                   "stickout": _NUM, "corner_radius": _NUM, "coating": _STR, "geometry": _STR, "aggressiveness": _NUM,
                   "runout_in": _NUM, "cut_depth": _d(_NUM, "inches"), "cut_width": _d(_NUM, "inches"),
                   "model": {"type": "string", "enum": ["v1", "v2"]}}, ["diameter"])),
    ToolSpec("strategy_compare",
             "Compare machining strategies with ToolWiz for a feature (profile cutout with tabs, slot, T-slot, pocket): options with ap, ae, rpm, feed, "
             "cycle time, relative tool wear, the recommended option and reasoning." + NUMBERS_RULE,
             _obj({"family": _STR, "alloy": _STR, "aggressiveness": _NUM, "runout_in": _NUM,
                   "feature_type": {"type": "string", "enum": ["profile_cutout", "slot", "tslot", "pocket"]},
                   "depth": _NUM, "length": _NUM, "width": _NUM, "slot_height": _NUM, "radial_depth": _NUM, "channel_width": _NUM,
                   "tabs_count": _INT, "tab_width": _NUM, "tab_height": _NUM, "tab_style": {"type": "string", "enum": ["2d", "3d"]},
                   "area": _NUM, "perimeter": _NUM, "corner_radius": _NUM,
                   "candidate_tools": {"type": "array", "items": _CAND}}, ["feature_type", "candidate_tools"])),
    ToolSpec("holder_advice",
             "Toolholder advice from the runout a cut needs (required tip runout, holder class, recommended and avoided holder types)." + NUMBERS_RULE,
             _obj({"diameter": _NUM, "fz_in": _d(_NUM, "chip load per tooth (in), from a ToolWiz result"), "flutes": _INT, "runout_in": _NUM,
                   "rpm": _NUM, "operation": _d(_STR, "slot, side, hem, rough, finish"), "stickout": _NUM, "taper": _STR}, ["diameter", "fz_in"])),
    ToolSpec("tool_advice",
             "Tool-series recommendations and cited application notes for a material, diameter and operation." + NUMBERS_RULE,
             _obj({"family": _STR, "diameter": _NUM, "operation": _d(_STR, "slot, side, hem, rough, finish"), "flutes": _INT, "coating": _STR},
                  ["diameter", "operation"])),
    ToolSpec("runout_sensitivity",
             "How the recommended numbers change with holder runout (calls ToolWiz's runout sensitivity analysis when this ToolWiz has it)." + NUMBERS_RULE,
             _obj({"family": _STR, "alloy": _STR, "operation": _STR, "tool_number": _INT, "diameter": _NUM, "flutes": _INT,
                   "flute_length": _NUM, "shank_diameter": _NUM, "stickout": _d(_NUM, "inches from holder face; ask, the 1.5\" default is far too long for micro tools"), "coating": _STR, "aggressiveness": _NUM}, ["family", "diameter"])),
    ToolSpec("set_assumption",
             "Record something the owner told you that Fusion does not say, for every advisor / calculation run in this chat, without changing "
             "Fusion. Keys: " + "; ".join(f"{k} ({v})" for k, v in setup_advisor.ASSUMPTION_KEYS.items()) + ". With no scope it applies to all "
             "tools. Re-run the advisor afterwards so the findings reflect it.",
             _obj({"key": {"type": "string", "enum": list(setup_advisor.ASSUMPTION_KEYS)},
                   "value": _d(_STR, "the value as text, e.g. 'AlTiN', 'carbide', '0.0003', 'surface'"),
                   "unit": {"type": "string", "enum": ["in", "mm"]},
                   "scope_tools": _d({"type": "array", "items": _INT}, "tool numbers (T3 = 3)"),
                   "scope_diameter_in": _d(_NUM, "all tools of this diameter, inches"),
                   "scope_op_ids": _d({"type": "array", "items": _STR}, "'Setup > Operation' paths or operation names"),
                   "override": _d(_BOOL, "also replace what the snapshot already says (default: only fill gaps for coating, material, grade, holder)")},
                  ["key", "value"])),
    ToolSpec("clear_assumption", "Remove one assumption by id, every assumption of a key, or all of them.",
             _obj({"id": _STR, "key": {"type": "string", "enum": list(setup_advisor.ASSUMPTION_KEYS)}, "all": _BOOL})),
    ToolSpec("list_assumptions", "The assumptions active in this conversation.", _obj({})),
    ToolSpec("propose_fusion_change",
             "Queue a change for the owner to approve. Nothing changes in Fusion until the owner presses Approve in the chat AND confirms in "
             "Fusion. kind 'operation_parameters': op_id plus parameters whose values must equal ToolWiz's apply_plan values of the last advisor run. "
             "kind 'tool_fields': tool_number (or tool_guid) plus fields (coating, BMC, GRADE, comment, description, add_keywords, remove_keywords) "
             "for a tool of the document tool library. Always give a short reason.",
             _obj({"kind": {"type": "string", "enum": ["operation_parameters", "tool_fields"]}, "reason": _STR, "op_id": _STR,
                   "parameters": _obj(_APPLY_PARAMS), "tool_number": _INT, "tool_guid": _STR, "fields": _obj(_FIELDS)}, ["kind", "reason"])),
    ToolSpec("get_viewport_image",
             "A screenshot of Fusion's active viewport so you can see what the owner sees (only when enabled in the chat settings). Describe it; "
             "do not read numbers off it: use ToolWiz tools for numbers.", _obj({})),
]


@dataclass
class ToolContext:
    """What a tool call may touch: the conversation's assumption list and proposal list (both mutated in place)."""
    assumptions: List[Dict[str, Any]] = field(default_factory=list)
    proposals: List[Dict[str, Any]] = field(default_factory=list)
    viewport_enabled: bool = False
    post: Optional[Callable[[str, Dict[str, Any]], Dict[str, Any]]] = None     # (path, body) -> JSON; default: the Flask app, in process
    now: Callable[[], float] = time.time

    def call_endpoint(self, path: str, body: Dict[str, Any]) -> Dict[str, Any]:
        if self.post is not None:
            return self.post(path, body)
        import app as A
        with A.app.test_client() as client:
            resp = client.post(path, json=body, headers={"X-ToolWiz-Client": "advisor-chat"})
            data = resp.get_json(silent=True)
            if not isinstance(data, dict):
                return {"success": False, "error": f"HTTP {resp.status_code}"}
            if resp.status_code >= 400:
                data.setdefault("success", False)
            return data


def specs(viewport_enabled: bool = False) -> List[ToolSpec]:
    return [t for t in TOOLS if viewport_enabled or t.name != "get_viewport_image"]


# ---- helpers ------------------------------------------------------------------------------------------------------

def _clean(args: Dict[str, Any]) -> Dict[str, Any]:
    return {k: v for k, v in args.items() if v is not None and v != ""}


def _live_setup() -> Dict[str, Any]:
    live = fusion_bridge.get_live_state()
    if not live.get("connected"):
        return {"connected": False}
    return {"connected": True, "setup": {"document": live.get("document"), "ops": live.get("ops") or []}, "document": live.get("document"),
            "updated_at": live.get("updated_at"), "tool_count": live.get("tool_count"), "setups": live.get("setups")}


def _apply_to_calc(ctx: ToolContext, args: Dict[str, Any]) -> tuple:
    """Merge the conversation's assumptions into calculation args: returns (args, notes)."""
    a = dict(args)
    notes: List[str] = []
    res = asm.resolve(ctx.assumptions, a.get("tool_number"), a.get("diameter"))
    for key, dest in (("family", "family"), ("alloy", "alloy"), ("aggressiveness", "aggressiveness"), ("runout", "runout_in")):
        if key in res:
            a[dest] = res[key]["value"]
            notes.append(f"{key} {res[key]['value']} from your assumption")
    if "coating" in res and (not a.get("coating") or res["coating"]["override"]):
        a["coating"] = res["coating"]["value"]
        notes.append(f"coating {a['coating']} from your assumption")
    if "tool_material" in res:
        a["tool_material"] = res["tool_material"]["value"]
        notes.append(f"tool material {a['tool_material']} from your assumption")
    return a, notes


def _default_model() -> str:
    """The cutting model the app uses (saved setting, TOOLWIZ_MODEL, else the default), outside a web request."""
    import v2_bridge
    return v2_bridge.resolve_model(None)[0]


def _pct(v: Any) -> float:
    f = float(v)
    return f * 100.0 if f <= 1.0 else f


# ---- the tools ----------------------------------------------------------------------------------------------------

def get_live_setup(ctx: ToolContext, args: Dict[str, Any]) -> Dict[str, Any]:
    refreshed = None
    if args.get("refresh"):
        r = fusion_bridge.execute_bridge_action("get_setup_summary", {}, timeout=10.0)
        refreshed = not r.get("cached") and r.get("success") is not False
    live = _live_setup()
    if not live["connected"]:
        return {"success": True, "connected": False, "stale": None,
                "message": "Fusion is not connected: the add-in has not sent a setup to ToolWiz. In Fusion, run the ToolWiz Setup Advisor command "
                           "(or make sure the add-in is running) and ask again."}
    age = max(0.0, ctx.now() - float(live["updated_at"] or ctx.now()))
    norm = setup_advisor.normalize_setup(live["setup"])
    ops = []
    for o in norm["ops"]:
        t = o["tool"]
        ops.append({"op_id": o["op_id"], "name": o["name"], "setup": o["setup"], "strategy": o["strategy"], "kind": o["kind"],
                    "tool": {k: t.get(k) for k in ("number", "description", "type", "diameter_in", "flutes", "flute_length_in",
                                                   "shank_diameter_in", "stickout_in", "corner_radius_in", "coating", "holder")},
                    "current": {k: v for k, v in o["current"].items() if v is not None},
                    "geometry": {k: v for k, v in o["geometry"].items() if k != "feature_geometry" and v is not None},
                    "family": o.get("family"), "alloy": o.get("alloy")})
    out = {"success": True, "connected": True, "document": live["document"], "snapshot_age_seconds": round(age),
           "stale": age > STALE_AFTER_S, "operations_count": len(ops), "document_tool_count": live.get("tool_count"), "operations": ops,
           "assumptions": [asm.public(r) for r in ctx.assumptions]}
    if refreshed is False:
        out["refresh_note"] = "Fusion did not answer the refresh request; this is the last snapshot it sent."
    if out["stale"]:
        out["message"] = ("The snapshot is older than %d seconds: Fusion may have changed since. Ask the owner to run the Setup Advisor "
                          "command in Fusion again if they changed anything." % STALE_AFTER_S)
    return out


def _advisor_view(result: Dict[str, Any]) -> Dict[str, Any]:
    view = setup_advisor.llm_view(result)
    for v, o in zip(view["operations"], result["operations"]):
        v["op_id"] = o["op_id"]
        v["tool_number"] = o["tool"].get("number")
        v["tool"] = dict(v.get("tool") or {}, coating=o["tool"].get("coating"), number=o["tool"].get("number"))
        v["findings"] = [{k: f.get(k) for k in ("severity", "code", "title", "detail", "recommendation", "numbers")} for f in o["findings"]]
        if o.get("notes"):
            v["notes"] = o["notes"]
        if o.get("assumptions_applied"):
            v["assumptions_applied"] = o["assumptions_applied"]
        if o.get("multi_stepover"):
            v["multi_stepover"] = {k: o["multi_stepover"].get(k) for k in ("effective_cut_width_in", "safe_numbers", "explanation")}
    view["generated_at"] = result["generated_at"]
    view["document"] = result.get("document")
    view["settings"] = result["settings"]
    view["assumptions"] = result.get("assumptions") or []
    view["strategy_notes"] = result.get("strategy_notes") or []
    view["how_to_apply"] = ("Only each operation's apply_plan values can be applied (propose_fusion_change kind operation_parameters, "
                            "with the op_id).")
    return view


def run_setup_advisor(ctx: ToolContext, args: Dict[str, Any]) -> Dict[str, Any]:
    live = _live_setup()
    if not live["connected"]:
        return {"success": False, "error": "Fusion is not connected: the add-in has not sent a setup to ToolWiz. Ask the owner to run the "
                                           "ToolWiz Setup Advisor command in Fusion."}
    import app as A
    limits = A.machine_limits()
    a = _clean(args)
    has_family = bool(a.get("family")) or any(r["key"] == "family" and r["scope"].get("all") for r in ctx.assumptions)
    if not has_family and not live["setup"].get("family"):
        ops = live["setup"].get("ops") or []
        if not ops or not all(isinstance(o, dict) and (o.get("family") or isinstance(o.get("material"), dict)) for o in ops):
            return {"success": False, "error": "The material is not known. Ask the owner which material (ToolWiz family and alloy) this "
                                               "setup cuts, then call again with family (and alloy) or set_assumption key family."}
    result = setup_advisor.advise(
        live["setup"], family=a.get("family"), alloy=a.get("alloy"), aggressiveness=a.get("aggressiveness", 0.5),
        runout=a.get("runout_in", limits["runout"]), model=a.get("model") or _default_model(), physics=A.physics,
        machine_profile=A.active_machine(), strategies=a.get("strategies", True) is not False, assumptions=ctx.assumptions)
    return dict(_advisor_view(result), success=True)


def _calc_body(a: Dict[str, Any], notes: List[str]) -> tuple:
    """Calculation request body in /api/calculate's field names (fluteLength, shankDiameter, ...): returns (body, assumed)."""
    assumed: List[str] = list(notes)
    if not a.get("coating"):
        assumed.append("coating not given: ToolWiz's default (AlTiN) was used")
    if a.get("stickout") is None:
        assumed.append("stickout not given: ToolWiz's default (1.5\") was used; micro tools are usually much shorter, ask the owner")
    body = {"family": a["family"], "alloy": a.get("alloy") or "", "operation": a.get("operation") or "Roughing", "diameter": a["diameter"],
            "flutes": a.get("flutes", 4), "coating": a.get("coating") or "AlTiN", "model": a.get("model") or _default_model()}
    for src, dst in (("flute_length", "fluteLength"), ("shank_diameter", "shankDiameter"), ("stickout", "stickout"),
                     ("corner_radius", "cornerRadius"), ("geometry", "geometry"), ("cut_depth", "cutDepth"), ("cut_width", "cutWidth"),
                     ("runout_in", "runout")):
        if a.get(src) is not None:
            body[dst] = a[src]
    if a.get("aggressiveness") is not None:
        body["aggressiveness"] = _pct(a["aggressiveness"])
    if a.get("tool_material") in ("hss", "cobalt"):
        body["isCarbide"] = False
    return body, assumed


def toolwiz_calculate(ctx: ToolContext, args: Dict[str, Any]) -> Dict[str, Any]:
    a, notes = _apply_to_calc(ctx, _clean(args))
    if not a.get("family"):
        return {"success": False, "error": "family (the ToolWiz material family) is required: ask the owner or set_assumption key family."}
    body, assumed = _calc_body(a, notes)
    import mcp_server
    out = mcp_server.call_mcp_tool_by_name("toolwiz_calculate_cut", body)
    out["inputs_assumed"] = assumed
    return out


def strategy_compare(ctx: ToolContext, args: Dict[str, Any]) -> Dict[str, Any]:
    a = _clean(args)
    base, notes = _apply_to_calc(ctx, {k: a.get(k) for k in ("family", "alloy", "aggressiveness", "runout_in")})
    if not base.get("family"):
        return {"success": False, "error": "family is required: ask the owner or set_assumption key family."}
    ft = a["feature_type"]
    feat: Dict[str, Any] = {"type": ft}
    for k in ("depth", "length", "width", "slot_height", "radial_depth", "channel_width", "area", "perimeter", "corner_radius"):
        if a.get(k) is not None:
            feat[k] = a[k]
    if a.get("tabs_count"):
        feat["tabs"] = _clean({"count": a["tabs_count"], "width": a.get("tab_width"), "height": a.get("tab_height"),
                               "style": a.get("tab_style") or "3d"})
    cands = []
    for c in a.get("candidate_tools") or []:
        c = _clean(c)
        if c.get("shop_tool_id"):
            cands.append({"id": c["shop_tool_id"]})
            continue
        res = asm.resolve(ctx.assumptions, c.get("tool_number"), c.get("diameter"))
        t = {k: c[k] for k in ("diameter", "flutes", "flute_length", "shank_diameter", "stickout", "geometry") if k in c}
        coat = c.get("coating") or (res["coating"]["value"] if "coating" in res else None)
        if coat:
            t["coating"] = coat
        cands.append(t)
    body = {"family": base["family"], "alloy": base.get("alloy") or "", "aggressiveness": base.get("aggressiveness", 0.5),
            "runout": base.get("runout_in", 0.0002), "model": "v2", "feature": feat, "candidate_tools": cands}
    out = ctx.call_endpoint("/api/strategy/compare", body)
    out["inputs_assumed"] = notes
    return out


def holder_advice(ctx: ToolContext, args: Dict[str, Any]) -> Dict[str, Any]:
    a = _clean(args)
    res = asm.resolve(ctx.assumptions, None, a.get("diameter"))
    if "runout" in res and "runout_in" not in a:
        a["runout_in"] = res["runout"]["value"]
    return ctx.call_endpoint("/api/advice/holder", a)


def tool_advice(ctx: ToolContext, args: Dict[str, Any]) -> Dict[str, Any]:
    a = _clean(args)
    res = asm.resolve(ctx.assumptions, None, a.get("diameter"))
    if "family" in res:
        a["family"] = res["family"]["value"]
    if "coating" in res and not a.get("coating"):
        a["coating"] = res["coating"]["value"]
    if not a.get("family"):
        return {"success": False, "error": "family is required: ask the owner or set_assumption key family."}
    return ctx.call_endpoint("/api/advice/tools", a)


def runout_sensitivity(ctx: ToolContext, args: Dict[str, Any]) -> Dict[str, Any]:
    if ctx.post is None:
        import app as A
        if not any(r.rule == "/api/runout_sensitivity" for r in A.app.url_map.iter_rules()):
            return {"success": False, "available": False,
                    "error": "Runout sensitivity is not available in this ToolWiz build (POST /api/runout_sensitivity does not exist yet). "
                             "Use toolwiz_calculate with different runout_in values and compare the results instead."}
    a, notes = _apply_to_calc(ctx, _clean(args))
    if not a.get("family") or not a.get("diameter"):
        return {"success": False, "error": "family and diameter are required: ask the owner or set_assumption key family."}
    body, assumed = _calc_body(a, notes)
    body.pop("runout", None)   # the analysis sweeps runout itself; the current value is the machine's
    out = ctx.call_endpoint("/api/runout_sensitivity", body)
    if out.get("success") is False and "HTTP 404" in str(out.get("error", "")):
        return {"success": False, "available": False, "error": "Runout sensitivity is not available in this ToolWiz build."}
    out["inputs_assumed"] = assumed
    return out


def set_assumption(ctx: ToolContext, args: Dict[str, Any]) -> Dict[str, Any]:
    a = args
    scope: Dict[str, Any] = {}
    if a.get("scope_tools"):
        scope["tools"] = a["scope_tools"]
    if a.get("scope_diameter_in") is not None:
        scope["diameter_in"] = a["scope_diameter_in"]
    if a.get("scope_op_ids"):
        scope["op_ids"] = a["scope_op_ids"]
    raw = {"key": a.get("key"), "value": a.get("value"), "scope": scope or {"all": True}}
    if a.get("unit"):
        raw["unit"] = a["unit"]
    if a.get("override") is not None:
        raw["override"] = a["override"]
    try:
        rec = asm.add(ctx.assumptions, raw)
    except ValueError as ex:
        return {"success": False, "error": str(ex)}
    return {"success": True, "assumption": asm.public(rec), "active_assumptions": [asm.public(r) for r in ctx.assumptions],
            "note": "Recorded for this chat only; Fusion is unchanged. Run run_setup_advisor again so the findings reflect it."}


def clear_assumption(ctx: ToolContext, args: Dict[str, Any]) -> Dict[str, Any]:
    if not (args.get("id") or args.get("key") or args.get("all")):
        return {"success": False, "error": "give an assumption id, a key, or all: true"}
    gone = asm.remove(ctx.assumptions, rec_id=args.get("id"), key=args.get("key"), all_=bool(args.get("all")))
    return {"success": True, "removed": [asm.public(r) for r in gone], "active_assumptions": [asm.public(r) for r in ctx.assumptions]}


def list_assumptions(ctx: ToolContext, args: Dict[str, Any]) -> Dict[str, Any]:
    return {"success": True, "active_assumptions": [asm.public(r) for r in ctx.assumptions]}


def _new_proposal(ctx: ToolContext, kind: str, payload: Dict[str, Any], reason: str, summary: str) -> Dict[str, Any]:
    n = 1 + max([int(p["id"][1:]) for p in ctx.proposals if str(p["id"])[1:].isdigit()] or [0])
    prop = {"id": f"p{n}", "kind": kind, "status": "pending", "payload": payload, "reason": reason, "summary": summary,
            "created": time.strftime("%Y-%m-%dT%H:%M:%S"), "result": None, "request_id": None, "reported": False}
    ctx.proposals.append(prop)
    return prop


def propose_fusion_change(ctx: ToolContext, args: Dict[str, Any]) -> Dict[str, Any]:
    kind, reason = args.get("kind"), str(args.get("reason") or "").strip() or "ToolWiz Advisor Chat"
    if kind == "operation_parameters":
        op_id, params = str(args.get("op_id") or "").strip(), _clean(args.get("parameters") or {})
        if not op_id:
            return {"success": False, "error": "op_id is required (use the op_id from run_setup_advisor)"}
        chk = setup_advisor.validate_apply(op_id, params)
        if not chk["ok"]:
            return {"success": False, "error": chk["error"] or "invalid parameters", "rejected": chk["rejected"],
                    "hint": "Only ToolWiz's apply_plan values from the last run_setup_advisor can be proposed. Run it again if the advisor result is old."}
        summary = f"{op_id}: " + ", ".join(f"{k} = {v}" for k, v in chk["accepted"].items())
        prop = _new_proposal(ctx, kind, {"op_id": op_id, "params": chk["accepted"]}, reason, summary)
    elif kind == "tool_fields":
        fields = _clean(args.get("fields") or {})
        fields = {k: v for k, v in fields.items() if v not in ([], {})}
        payload: Dict[str, Any] = {"fields": fields}
        if args.get("tool_number") is not None:
            payload["tool_number"] = args["tool_number"]
        if args.get("tool_guid"):
            payload["tool_guid"] = args["tool_guid"]
        err = fusion_bridge.check_tool_fields(payload)
        if err:
            return {"success": False, "error": err}
        who = f"T{payload['tool_number']}" if "tool_number" in payload else f"tool {payload['tool_guid']}"
        summary = f"{who}: " + ", ".join(f"{k} = {v}" for k, v in fields.items())
        prop = _new_proposal(ctx, kind, payload, reason, summary)
    else:
        return {"success": False, "error": "kind must be 'operation_parameters' or 'tool_fields'"}
    return {"success": True, "proposal_id": prop["id"], "status": "pending_owner_approval", "summary": prop["summary"],
            "note": "Queued for the owner. Nothing has changed in Fusion: the owner presses Approve in the chat, then Fusion asks them to confirm."}


def get_viewport_image(ctx: ToolContext, args: Dict[str, Any]) -> Dict[str, Any]:
    if not ctx.viewport_enabled:
        return {"success": False, "error": "Viewport screenshots are switched off in the Advisor Chat settings."}
    res = fusion_bridge.execute_bridge_action("get_viewport_image", {"width": 1280, "height": 800}, timeout=20.0)
    if not res.get("success") or not res.get("data_base64"):
        return {"success": False, "error": res.get("error") or "Fusion did not return a screenshot (is the add-in running?)."}
    return {"success": True, "media_type": res.get("media_type") or "image/png", "_image": {
        "media_type": res.get("media_type") or "image/png", "data": res["data_base64"]},
        "note": "Screenshot attached. Describe what you see; take numbers only from ToolWiz tools."}


_RUNNERS: Dict[str, Callable[[ToolContext, Dict[str, Any]], Dict[str, Any]]] = {
    "get_live_setup": get_live_setup, "run_setup_advisor": run_setup_advisor, "toolwiz_calculate": toolwiz_calculate,
    "strategy_compare": strategy_compare, "holder_advice": holder_advice, "tool_advice": tool_advice,
    "runout_sensitivity": runout_sensitivity, "set_assumption": set_assumption, "clear_assumption": clear_assumption,
    "list_assumptions": list_assumptions, "propose_fusion_change": propose_fusion_change, "get_viewport_image": get_viewport_image,
}


def run_tool(ctx: ToolContext, name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
    """Execute one tool call. Never raises. Returns ``{"content": str (JSON), "is_error": bool, "image": {...}?, "data": dict}``."""
    fn = _RUNNERS.get(name)
    if fn is None:
        data: Dict[str, Any] = {"success": False, "error": f"Unknown tool {name!r}"}
    else:
        try:
            data = fn(ctx, dict(arguments or {}))
        except ValueError as ex:
            data = {"success": False, "error": str(ex)}
        except Exception as ex:          # a tool bug must not end the chat
            data = {"success": False, "error": f"{type(ex).__name__}: {ex}"[:300]}
    image = data.pop("_image", None)
    text = json.dumps(data, default=str, separators=(",", ":"))
    if len(text) > MAX_RESULT_CHARS:
        data = {"success": False, "error": "The result was too large to return. Narrow the request (one operation, fewer candidates)."}
        text = json.dumps(data)
    out = {"content": text, "is_error": data.get("success") is False, "data": data}
    if image:
        out["image"] = image
    return out
