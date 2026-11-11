"""Audit a Fusion 360 tool library against ToolWiz: per tool and per preset findings (STOP / CAUTION / INFO).

Pure functions: ``audit_library(library, physics, ...)`` reads a library dict (``{"tools": [...]}``) and returns a
report dict; nothing is written. Lengths in a Fusion tool and its presets are in the tool's own unit
(millimeters or inches); every comparison is made in inches and reported in the tool's unit.

The ToolWiz recommendation for a preset comes from ``pipeline.run_cut`` for the preset's material (mapped from
its material query or name to a ToolWiz family, see ``resolve_material``) and operation (``operation_type`` or the
name, see ``classify_operation``) at 50% aggressiveness. A preset whose material or operation is not recognised
gets an INFO finding and no numeric comparison.

Findings
  STOP     stepdown > cutting length (LCF; the kerf of a slot mill); stepover > D (or > the T-slot neck
           reach (D - neck) / 2); chip load f_z > 2 x ToolWiz; rpm x f_z x flutes differs from v_f by > 10%;
           an end-mill strategy on a form tool; missing or zero feed / speed.
  CAUTION  f_z < 0.5 x or > 1.4 x ToolWiz; rpm above the machine maximum; a shank smaller than the shop rule (shank_suspect: 1/8" up to 1/8" tools,
           1/4" up to 1/4", else D; 4 mm / 6 mm / D metric) with the proposed value; a standard ER collet on a tool whose
           required runout is in the precision / ultra class; stickout LB > 4 x D on a tool of 1/8" or less
           without a reduced neck; duplicate presets; a tool that cannot be read (no unit).
  INFO     no presets for the selected material; measured runout missing; material or operation not recognised.
"""
from __future__ import annotations

import math
import re
from typing import Any, Callable, Dict, List, Optional, Tuple

from master_library import GENERATOR, cached_cut, cut_request
from toolwiz_common.geometry import ToolGeometry, default_shank_inches, shank_looks_wrong
from toolwiz_common.tool_profile import ToolProfile
from toolwiz_common.tool_strategy import END_MILL_STRATEGIES, FORM_KINDS, T_SLOT_AXIAL, T_SLOT_FULL
from toolwiz_common.tool_types import ToolKind, classify, is_hole_kind, is_milling_kind
from toolwiz_common.units import UnitError, tool_unit

STOP, CAUTION, INFO = "STOP", "CAUTION", "INFO"
MAX_RPM_DEFAULT = 16000.0          # machines/speedio_s500x2.json, spindle option "optional_16k"
FZ_STOP_RATIO = 2.0
FZ_HIGH_RATIO = 1.4
FZ_LOW_RATIO = 0.5
FEED_CONSISTENCY = 0.10
MICRO_IN = 0.125
LB_OVER_D = 4.0
MM = 25.4

# (regex on the preset's material text, ToolWiz family). First match wins; order matters.
_MATERIALS: List[Tuple[str, str]] = [
    (r"zirconium\s*705", "Zirconium 705 (Alloyed)"),
    (r"zirconium", "Zirconium 702 (Commercially Pure)"),
    (r"17[\s-]?4|\bph\b|15[\s-]?5", "Stainless - PH Series (17-4)"),
    (r"ti-?6al|titanium|super alloys and ti|\bti\b", "Titanium Alloy"),
    (r"magnacut|stainless.*\b4\d\d\b|\b420\b|\b440\b", "Stainless - 400 Series (420)"),
    (r"stainless|\bss\b|\b3(04|16)l?\b", "Stainless - 300 Series (316)"),
    (r"copper|bronze|nickel silver", "Copper Alloy - Wrought"),
    (r"inconel|nickel|hastelloy|waspaloy", "High Temp Nickel Alloy"),
    (r"aluminum|aluminium|\b6061\b|\b7075\b", "Aluminum - Wrought (6061)"),
    (r"brass", "Brass"),
    (r"cast iron", "Cast Iron - Gray"),
    (r"h13|tool steel|hard material", "Steel - Tool (H13)"),
    (r"high carbon", "Steel - High Carbon (1090)"),
    (r"low carbon", "Steel - Low Carbon (1020)"),
    (r"4140|4130|alloy steel", "Steel - Medium Carbon Alloy (4130)"),
    (r"steel", "Steel - Medium Carbon (1045)"),
    (r"plastic|delrin|acetal|nylon|peek|\babs\b", "Plastics: Soft (Acetal, HDPE, PEEK)"),
]

_SHANK_RULE_KINDS = frozenset({ToolKind.FLAT, ToolKind.BALL, ToolKind.BULL, ToolKind.RADIUS})

# Words that make a preset name a non-cutting / generic preset (no numeric comparison).
_GENERIC_NAMES = ("default", "deburr")

_ER_RE = re.compile(r"(?<![A-Za-z])ER(?![A-Za-z])")


# ---------------------------------------------------------------- mapping helpers
def resolve_material(*texts: str, physics: Any = None) -> Optional[Dict[str, str]]:
    """Map a preset's material query and / or name to ``{"family", "alloy"}`` (alloy "" unless ``physics``
    resolves the text to a specific alloy row), or None when no rule matches. The first non-empty text that
    matches a rule decides."""
    for text in texts:
        t = (text or "").strip()
        if not t or any(w in t.lower() for w in _GENERIC_NAMES):
            continue
        low = t.lower()
        for pat, fam in _MATERIALS:
            if re.search(pat, low):
                alloy = ""
                if physics is not None:
                    try:
                        if physics.match_alloy(fam, t):
                            alloy = t
                    except Exception:
                        alloy = ""
                return {"family": fam, "alloy": alloy}
    return None


def material_of_preset(preset: dict, physics: Any = None) -> Optional[Dict[str, str]]:
    """Material of a preset: the family and alloy row ToolWiz wrote in its ``toolwiz`` tag (the exact material the
    preset was computed for), else its ``material.query``, else its name without the operation suffix."""
    tag = preset.get("toolwiz")
    if isinstance(tag, dict) and tag.get("generator") == GENERATOR and tag.get("family"):
        return {"family": str(tag["family"]), "alloy": str(tag.get("alloy") or "")}
    mat = preset.get("material") or {}
    name = str(preset.get("name") or "")
    return resolve_material(str(mat.get("query") or ""), name.split(" - ")[0], name, physics=physics)


def classify_operation(preset: dict) -> Optional[str]:
    """Canonical operation of a preset from ``operation_type`` or its name: "Adaptive Roughing", "Roughing",
    "Finishing", "Slotting", "Drilling", "T-Slot Full Slot", "T-Slot Axial Step", "High Feed Milling", or None."""
    text = f"{preset.get('operation_type') or ''} {preset.get('name') or ''}".lower()
    if "t-slot" in text or "tslot" in text or "keyseat" in text:
        return T_SLOT_AXIAL if "axial" in text else T_SLOT_FULL
    if "drill" in text and "deburr" not in text:
        return "Drilling"
    if "high feed" in text:
        return "High Feed Milling"
    if "adaptive" in text or "dynamic" in text:
        return "Adaptive Roughing"
    if "slot" in text:
        return "Slotting"
    if "finish" in text or "skim" in text:
        return "Finishing"
    if "rough" in text or "side milling" in text:
        return "Roughing"
    return None


# ---------------------------------------------------------------- findings
class _Report:
    def __init__(self) -> None:
        self.findings: List[Dict[str, Any]] = []

    def add(self, severity: str, code: str, message: str, *, tool_index: int, tool: dict,
            preset: Optional[str] = None, toolwiz_value: Any = None, preset_value: Any = None) -> None:
        self.findings.append({
            "severity": severity, "code": code, "message": message, "tool_index": tool_index,
            "tool": tool.get("description", ""), "type": tool.get("type", ""), "preset": preset,
            "toolwiz_value": toolwiz_value, "preset_value": preset_value})


def _fmt(v: float, unit: str) -> str:
    return f"{v:.4g} {'mm' if unit == 'millimeters' else 'in'}"


# ---------------------------------------------------------------- ToolWiz recommendation
class _Recommender:
    """ToolWiz recommendation per (tool, family, alloy, operation), from the same ``CutRequest`` the build uses
    (``master_library.cut_request``). ``cache`` is the build's cache (a dict of pipeline results keyed by request):
    cuts the build already made are reused, and new ones are added to it. ``aggressiveness_for(tool)`` gives each
    tool's aggressiveness (its own override, as in the build)."""

    def __init__(self, physics: Any, max_rpm: float, max_hp: float, runout_in: float, aggressiveness: float,
                 model: Optional[str], machine_profile: Optional[dict], *, cache: Optional[dict] = None,
                 aggressiveness_for: Optional[Callable[[dict], float]] = None) -> None:
        self.physics, self.max_rpm, self.max_hp = physics, max_rpm, max_hp
        self.runout, self.aggr, self.model, self.machine = runout_in, aggressiveness, model, machine_profile
        self.cache = cache if cache is not None else {}
        self.aggr_for = aggressiveness_for or (lambda tool: self.aggr)
        self._memo: Dict[Tuple, Optional[Dict[str, float]]] = {}

    def get(self, idx: int, tool: dict, kind: ToolKind, family: str, alloy: str, op: str) -> Optional[Dict[str, float]]:
        key = (idx, family, alloy, op)
        if key in self._memo:
            return self._memo[key]
        out: Optional[Dict[str, float]] = None
        try:
            g = ToolGeometry.from_fusion(tool, stickout_override=tool.get("stickout"))
            slot_op = op if op in (T_SLOT_FULL, T_SLOT_AXIAL) else ""
            tslot = ("axial_step" if op == T_SLOT_AXIAL else "full_slot") if slot_op else ""
            req = cut_request(tool, g, kind, {"family": family, "alloy": alloy},
                              operation=("Slotting" if slot_op else op), tslot_operation=tslot,
                              aggressiveness=self.aggr_for(tool), max_rpm=self.max_rpm, max_hp=self.max_hp,
                              runout=self.runout, model=self.model, machine_profile=self.machine)
            r = cached_cut(self.physics, req, self.cache)
            fz = r.adj_ipt
            if tslot == "axial_step" and r.rpm > 0:
                fz = r.feed_ipm / (r.rpm * g.flutes)      # the Z feed expressed as a per-tooth value
            if all(math.isfinite(x) for x in (fz, r.feed_ipm, r.rpm)) and fz > 0:
                out = {"fz_in": fz, "feed_ipm": r.feed_ipm, "rpm": r.rpm, "doc_in": r.rec_doc, "woc_in": r.rec_woc,
                       "diameter_in": g.diameter, "flutes": g.flutes, "feasible": bool(r.feasible)}
        except Exception:
            out = None
        self._memo[key] = out
        return out


# ---------------------------------------------------------------- tool-level checks
def _has_reduced_neck(prof: ToolProfile) -> bool:
    d = prof.geometry.diameter
    return any(s.kind != "flute" and min(s.d0, s.d1) < d * 0.999 for s in prof.segments)


def _holder_text(tool: dict) -> str:
    h = tool.get("holder") or {}
    return " ".join(str(x) for x in (h.get("description"), h.get("product-id")) if x)


def _tool_checks(rep: _Report, idx: int, tool: dict, kind: ToolKind, prof: ToolProfile, unit: str,
                 ref: Optional[Dict[str, float]], ref_op: str, runout_in: float, max_rpm: float) -> None:
    g = prof.geometry
    d_in = g.diameter
    if d_in <= MICRO_IN + 1e-9 and prof.stickout_source == "fusion_LB" and prof.stickout > LB_OVER_D * d_in + 1e-9 \
            and not _has_reduced_neck(prof):
        rep.add(CAUTION, "long_stickout",
                f"Stickout LB {_fmt(prof.stickout * (MM if unit == 'millimeters' else 1), unit)} is "
                f"{prof.stickout / d_in:.1f} x D on a tool of 1/8\" or less with no reduced neck.",
                tool_index=idx, tool=tool, toolwiz_value=f"<= {LB_OVER_D:g} x D or add a reduced neck")
    if kind in _SHANK_RULE_KINDS:
        f = MM if unit == "millimeters" else 1.0
        if shank_looks_wrong(d_in * f, g.shank_diameter * f, unit):
            want = default_shank_inches(d_in, unit)
            rep.add(CAUTION, "shank_suspect",
                    f"Shank {_fmt(g.shank_diameter * f, unit)} on a {_fmt(d_in * f, unit)} {tool.get('type', 'tool')} is "
                    f"smaller than the shop's shank rule; proposed {_fmt(want * f, unit)}, tapering to the cutting "
                    f"diameter. The tool is modelled as a thinner (more flexible) rod until corrected.",
                    tool_index=idx, tool=tool, toolwiz_value=round(want * f, 5),
                    preset_value=round(g.shank_diameter * f, 5))
    htxt = _holder_text(tool)
    if htxt and _ER_RE.search(htxt) and ref is not None:
        try:
            from toolwiz_common.tooling_advisor import holder_advice
            adv = holder_advice(d_in, runout_in, ref["fz_in"], int(ref["flutes"]), ref["rpm"], ref_op,
                                prof.stickout, max_rpm=max_rpm)
            if adv.get("class") in ("ultra", "precision"):
                rep.add(CAUTION, "er_holder",
                        f"Standard ER collet holder ({htxt}) on a tool that needs {adv['class']}-class runout "
                        f"(required TIR {adv['required_tir_in']:.5f}\" at the recommended chip load).",
                        tool_index=idx, tool=tool, toolwiz_value=", ".join(adv.get("recommended") or []),
                        preset_value=htxt)
        except Exception:
            pass
    tw = tool.get("toolwiz") if isinstance(tool.get("toolwiz"), dict) else {}
    if not (tw.get("runout_in") or any(tool.get(k) for k in ("runout", "measured_runout", "runout_in"))):
        rep.add(INFO, "runout_missing",
                "No measured runout recorded for this tool (add toolwiz.runout_in); ToolWiz assumes the machine default.",
                tool_index=idx, tool=tool)


# ---------------------------------------------------------------- preset checks
def _num(v: Any) -> Optional[float]:
    try:
        f = float(v)
    except (TypeError, ValueError):
        return None
    return f if math.isfinite(f) else None


def _preset_checks(rep: _Report, idx: int, tool: dict, kind: ToolKind, prof: ToolProfile, unit: str,
                   preset: dict, rec: _Recommender, max_rpm: float) -> Optional[Dict[str, float]]:
    """Checks for one preset; returns the ToolWiz recommendation used (or None)."""
    g = prof.geometry
    scale = 1.0 / MM if unit == "millimeters" else 1.0       # tool-unit length -> inches
    name = str(preset.get("name") or "")
    n, vf, fz = _num(preset.get("n")), _num(preset.get("v_f")), _num(preset.get("f_z"))
    fn = _num(preset.get("f_n"))
    per_rev = bool(preset.get("use-feed-per-revolution"))
    flutes = g.flutes
    add = lambda sev, code, msg, **kw: rep.add(sev, code, msg, tool_index=idx, tool=tool, preset=name, **kw)

    hole = is_hole_kind(kind)
    if hole and not vf:
        vf = _num(preset.get("v_f_plunge"))      # Fusion drilling presets carry their feed as v_f_plunge
    if vf is None or vf <= 0:
        add(STOP, "missing_feed", "Missing or zero feed (" + ("v_f_plunge" if hole else "v_f") + ").",
            preset_value=preset.get("v_f_plunge" if hole else "v_f"))
    if n is None or n <= 0:
        add(STOP, "missing_speed", "Missing or zero spindle speed (n).", preset_value=preset.get("n"))
    if n and n > max_rpm * 1.001:
        add(CAUTION, "rpm_over_max", f"Spindle speed {n:,.0f} rpm is above the machine maximum {max_rpm:,.0f} rpm.",
            toolwiz_value=f"<= {max_rpm:,.0f}", preset_value=round(n))
    if vf and vf > 0 and n and n > 0 and not hole:
        per_tooth = fn if per_rev else (fz * flutes if fz is not None else None)
        if per_tooth is not None and per_tooth > 0:
            expect = n * per_tooth
            if abs(expect - vf) / vf > FEED_CONSISTENCY:
                add(STOP, "feed_inconsistent",
                    f"n x {'f_n' if per_rev else 'f_z x flutes'} = {expect:,.4g} but v_f = {vf:,.4g} "
                    f"(differ by {abs(expect - vf) / vf:.0%}; limit {FEED_CONSISTENCY:.0%}).",
                    toolwiz_value=round(expect, 4), preset_value=round(vf, 4))
        elif fz is None and fn is None:
            add(STOP, "missing_chip_load", "Missing chip load (f_z).", preset_value=None)

    op = classify_operation(preset)
    if op in END_MILL_STRATEGIES and (kind is ToolKind.SLOT or kind in FORM_KINDS or is_hole_kind(kind)):
        add(STOP, "end_mill_strategy_on_form_tool",
            f"End-mill strategy {op!r} on a {tool.get('type')}: its stepdown and stepover are meaningless for this "
            f"tool. Use the T-slot / form-tool preset instead.",
            toolwiz_value=(T_SLOT_FULL if kind is ToolKind.SLOT else "no end-mill strategy"), preset_value=op)

    lcf = g.flute_length
    if _num(preset.get("stepdown")) and preset.get("use-stepdown", True) is not False and not is_hole_kind(kind):
        sd = float(preset["stepdown"])
        if lcf > 0 and sd * scale > lcf * 1.001:
            add(STOP, "stepdown_over_cutting_length",
                f"Stepdown {_fmt(sd, unit)} is more than the cutting length "
                f"{_fmt(lcf / scale, unit)} ({'kerf' if kind is ToolKind.SLOT else 'LCF'}).",
                toolwiz_value=round(lcf / scale, 5), preset_value=round(sd, 5))
    if _num(preset.get("stepover")) and preset.get("use-stepover", True) is not False and not is_hole_kind(kind):
        so = float(preset["stepover"])
        limit_in, label = g.diameter, "the diameter"
        if kind is ToolKind.SLOT and prof.slot:
            limit_in, label = max(0.0, (g.diameter - prof.slot["neck_diameter"]) / 2.0), "the neck reach (D - neck) / 2"
        if so * scale > limit_in * 1.001:
            add(STOP, "stepover_over_limit", f"Stepover {_fmt(so, unit)} is more than {label} {_fmt(limit_in / scale, unit)}.",
                toolwiz_value=round(limit_in / scale, 5), preset_value=round(so, 5))

    # ToolWiz numbers: need a recognised material and operation
    mat = material_of_preset(preset, rec.physics)
    if op is None or mat is None:
        add(INFO, "not_compared",
            "Material " + ("not recognised" if mat is None else "recognised") + ", operation "
            + ("not recognised" if op is None else "recognised") + ": chip load not compared with ToolWiz.")
        return None
    if op == "High Feed Milling":
        add(INFO, "not_compared", "High feed milling has no ToolWiz model: chip load not compared.")
        return None
    use_op = op
    if kind is ToolKind.SLOT and op in END_MILL_STRATEGIES:
        use_op = T_SLOT_FULL          # the only model that applies to a slot mill
    if kind in FORM_KINDS and op in END_MILL_STRATEGIES:
        return None
    r = rec.get(idx, tool, kind, mat["family"], mat["alloy"], use_op)
    if r is None:
        add(INFO, "not_compared", f"ToolWiz could not compute a recommendation for {mat['family']} / {use_op}.")
        return None
    if fz and fz > 0 and not per_rev:
        ref_fz = r["fz_in"] / scale
        ratio = fz / ref_fz
        msg = (f"Chip load f_z {_fmt(fz, unit)} is {ratio:.2f} x the ToolWiz value {_fmt(ref_fz, unit)} "
               f"({mat['family']}, {use_op}, 50%).")
        kw = dict(toolwiz_value=round(ref_fz, 6), preset_value=round(fz, 6))
        if ratio > FZ_STOP_RATIO:
            add(STOP, "chip_load_too_high", msg, **kw)
        elif ratio > FZ_HIGH_RATIO:
            add(CAUTION, "chip_load_high", msg, **kw)
        elif ratio < FZ_LOW_RATIO:
            add(CAUTION, "chip_load_low", msg + " Too light: the edge rubs instead of cutting.", **kw)
    return r


def _duplicates(rep: _Report, idx: int, tool: dict, presets: List[dict], physics: Any) -> None:
    """Same name twice, or the same speed, feed and depths twice for one material."""
    seen_name: Dict[str, int] = {}
    seen_val: Dict[Tuple, str] = {}
    for p in presets:
        name = str(p.get("name") or "")
        m = material_of_preset(p, physics)
        key = (m["family"] if m else name.split(" - ")[0],) + tuple(
            round(_num(p.get(k)) or 0.0, 4) for k in ("n", "v_f", "f_z", "stepdown", "stepover"))
        if name in seen_name:
            rep.add(CAUTION, "duplicate_preset", f"Preset name {name!r} appears more than once.",
                    tool_index=idx, tool=tool, preset=name)
        elif key in seen_val and key[1] > 0:
            rep.add(CAUTION, "duplicate_preset",
                    f"Same speed, feed and depths as preset {seen_val[key]!r} for the same material.",
                    tool_index=idx, tool=tool, preset=name)
        seen_name[name] = seen_name.get(name, 0) + 1
        seen_val.setdefault(key, name)


# ---------------------------------------------------------------- entry point
def audit_library(library: Dict[str, Any], physics: Any, *, material: Optional[str] = None,
                  max_rpm: float = MAX_RPM_DEFAULT, max_hp: float = 10.0, runout_in: float = 0.0002,
                  aggressiveness: float = 0.5, model: Optional[str] = None,
                  machine_profile: Optional[dict] = None, cache: Optional[dict] = None,
                  aggressiveness_for: Optional[Callable[[dict], float]] = None) -> Dict[str, Any]:
    """Audit every tool and preset of a Fusion library dict.

    ``material``: optional ToolWiz family (or free text such as "Ti-6Al-4V") the shop is cutting; tools with no
    preset for it get an INFO finding. ``runout_in``: runout assumed for the holder check. Returns
    ``{"summary": {"STOP", "CAUTION", "INFO", "tools", "presets"}, "findings": [...], "tools": [...]}`` where
    each finding has severity, code, message, tool_index, tool, type, preset, toolwiz_value, preset_value.

    The recommendations must be made with the settings the presets were built with: ``model``, ``runout_in``,
    ``machine_profile`` and ``max_rpm`` / ``max_hp``; ``aggressiveness_for(tool)`` returns a tool's own
    aggressiveness (default: ``aggressiveness`` for every tool). ``cache`` is a dict of pipeline results shared with
    the build (see ``master_library.cached_cut``); pass the build's cache so identical cuts are computed once.
    """
    tools = library.get("tools") if isinstance(library, dict) else None
    if not isinstance(tools, list):
        raise ValueError("library must be an object with a 'tools' list")
    rep = _Report()
    rec = _Recommender(physics, max_rpm, max_hp, runout_in, aggressiveness, model, machine_profile,
                       cache=cache, aggressiveness_for=aggressiveness_for)
    want = resolve_material(material or "", physics=physics) if material else None
    tool_rows, n_presets = [], 0
    for idx, t in enumerate(tools):
        if not isinstance(t, dict):
            continue
        kind = classify(t.get("type"))
        if kind in (ToolKind.HOLDER, ToolKind.PROBE):
            continue
        before = len(rep.findings)
        row = {"index": idx, "description": t.get("description", ""), "type": t.get("type", "")}
        try:
            unit = tool_unit(t)
            prof = ToolProfile.from_fusion(t)
        except (UnitError, ValueError, TypeError) as ex:
            rep.add(CAUTION, "unreadable_tool", f"Tool cannot be audited: {ex}.", tool_index=idx, tool=t)
            row["findings"] = rep.findings[before:]
            tool_rows.append(row)
            continue
        presets = [p for p in ((t.get("start-values") or {}).get("presets") or []) if isinstance(p, dict)]
        n_presets += len(presets)
        ref, ref_op = None, ""
        matched_selected = False
        for p in presets:
            used = _preset_checks(rep, idx, t, kind, prof, unit, p, rec, max_rpm)
            m = material_of_preset(p, physics)
            if want and m and m["family"] == want["family"]:
                matched_selected = True
            if used is not None and ref is None:
                ref, ref_op = used, ("slot" if (classify_operation(p) or "") in ("Slotting", T_SLOT_FULL, T_SLOT_AXIAL)
                                     else "rough")
        if ref is None and is_milling_kind(kind):
            fam = want["family"] if want else "Titanium Alloy"
            default_op = T_SLOT_FULL if kind is ToolKind.SLOT else "Adaptive Roughing"
            if kind in END_MILL_KINDS_FOR_REF:
                ref = rec.get(idx, t, kind, fam, "", default_op)
                ref_op = "slot" if kind is ToolKind.SLOT else "hem"
        _tool_checks(rep, idx, t, kind, prof, unit, ref, ref_op, runout_in, max_rpm)
        _duplicates(rep, idx, t, presets, physics)
        if want and not matched_selected:
            rep.add(INFO, "no_presets_for_material", f"No preset for {want['family']}.", tool_index=idx, tool=t)
        row["findings"] = rep.findings[before:]
        tool_rows.append(row)
    summary = {s: sum(1 for f in rep.findings if f["severity"] == s) for s in (STOP, CAUTION, INFO)}
    summary.update(tools=len(tool_rows), presets=n_presets)
    return {"summary": summary, "findings": rep.findings, "tools": tool_rows}


END_MILL_KINDS_FOR_REF = frozenset({ToolKind.FLAT, ToolKind.BULL, ToolKind.BALL, ToolKind.RADIUS, ToolKind.SLOT})
