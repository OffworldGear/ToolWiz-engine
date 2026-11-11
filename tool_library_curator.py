"""AI-Assisted & Rule-Based Tool Library Curator for Fusion 360 (Local, Cloud & Hub Libraries).

Inspects Fusion 360 tool definitions and libraries to automatically detect and repair:
  1. Missing or mistaken miniature tool shank diameters (e.g., SFDM == DC on tools < 1/8").
  2. Unmodeled shaft tapers in Fusion's Shaft tab (`shaft.segments` empty when SFDM > DC/neck),
     populating explicit Fusion-compliant frustum + straight shank segments with a 0.5 mm holder margin.
  3. Missing `shoulder-length`, `shoulder-diameter`, `LB` (stickout), and `OAL` fields.
  4. Coating (`BMC`) and corner-radius (`RE`) mismatches inferred from the tool's description/SKU.
  5. Optional AI Machinist catalog review for complex or ambiguous vendor tools.
"""
from __future__ import annotations

import copy
import re
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional

from toolwiz_common import (
    HOLDER_TAPER_MARGIN_IN,
    HOLDER_TAPER_MARGIN_MM,
    ToolKind,
    classify,
    default_shank_inches,
    default_stickout,
    shank_looks_wrong,
    to_inches,
    tool_unit,
)


_SHANK_RULE_KINDS = frozenset({ToolKind.FLAT, ToolKind.BALL, ToolKind.BULL, ToolKind.RADIUS})


@dataclass
class ToolFieldChange:
    field: str
    before: Any
    after: Any
    reason: str

    def to_dict(self) -> Dict[str, Any]:
        return {
            "field": self.field,
            "before": self.before,
            "after": self.after,
            "reason": self.reason,
        }


@dataclass
class CuratedToolResult:
    tool_number: Optional[int]
    description: str
    curated_tool: Dict[str, Any]
    changes: List[ToolFieldChange] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)
    ai_notes: Optional[str] = None

    @property
    def modified(self) -> bool:
        return len(self.changes) > 0

    def to_dict(self) -> Dict[str, Any]:
        return {
            "tool_number": self.tool_number,
            "description": self.description,
            "modified": self.modified,
            "changes": [c.to_dict() for c in self.changes],
            "warnings": list(self.warnings),
            "ai_notes": self.ai_notes,
            "curated_tool": self.curated_tool,
        }


def _from_inches(val_in: float, unit: str) -> float:
    return round(val_in * 25.4, 5) if unit == "millimeters" else round(val_in, 6)


def curate_tool_dict(
    tool_dict: Dict[str, Any],
    fix_micro_shank: bool = True,
    populate_shaft_taper: bool = True,
    infer_metadata_from_description: bool = True,
    use_ai: bool = False,
) -> CuratedToolResult:
    """Inspect and refine a single Fusion 360 tool dictionary without mutating the input."""
    t = copy.deepcopy(tool_dict)
    changes: List[ToolFieldChange] = []
    warnings: List[str] = []

    post = t.get("post-process") or t.get("postProcess") or {}
    t_num = post.get("number") if isinstance(post, dict) else None
    desc = str(t.get("description") or t.get("product-id") or "Unnamed Tool").strip()

    if t.get("type") == "holder" or not isinstance(t.get("geometry"), dict):
        return CuratedToolResult(tool_number=t_num, description=desc, curated_tool=t)

    try:
        unit = tool_unit(t)
    except Exception:
        # Never guess a unit: every length below would be scaled wrongly by 25.4 if the guess were off.
        warnings.append("Tool has no recognisable unit (inches or millimeters); not curated.")
        return CuratedToolResult(tool_number=t_num, description=desc, curated_tool=t, warnings=warnings)

    geo = t["geometry"]
    dc_raw = geo.get("DC")
    if dc_raw in (None, "") or float(dc_raw or 0) <= 0:
        warnings.append("Tool is missing a positive cutting diameter (DC).")
        return CuratedToolResult(tool_number=t_num, description=desc, curated_tool=t, warnings=warnings)

    dc_in = to_inches(dc_raw, unit)
    f_unit = 25.4 if unit == "millimeters" else 1.0
    lcf_raw = geo.get("LCF")
    lcf_in = to_inches(lcf_raw, unit) if lcf_raw not in (None, "") else 0.0
    if lcf_in <= 0.0:
        lcf_in = dc_in * 3.0
        new_lcf = _from_inches(lcf_in, unit)
        changes.append(ToolFieldChange("geometry.LCF", lcf_raw, new_lcf, "Populated missing flute length (3xD default)."))
        geo["LCF"] = new_lcf

    # 1. Shank diameter (SFDM) check & micro-tool repair
    sfdm_raw = geo.get("SFDM") if geo.get("SFDM") not in (None, "") else geo.get("SF")
    sfdm_in = to_inches(sfdm_raw, unit) if sfdm_raw not in (None, "") else 0.0

    if sfdm_in <= 0.0:
        sfdm_in = default_shank_inches(dc_in, unit)
        new_sfdm = _from_inches(sfdm_in, unit)
        changes.append(ToolFieldChange(
            "geometry.SFDM", sfdm_raw, new_sfdm,
            "Populated missing shaft diameter from the shop rule (1/8\" up to 1/8\" tools, 1/4\" up to 1/4\", "
            "else DC; 4 mm / 6 mm / DC for metric tools)."
        ))
        geo["SFDM"] = new_sfdm
    elif fix_micro_shank and classify(t.get("type")) in _SHANK_RULE_KINDS and shank_looks_wrong(
            dc_in * f_unit, sfdm_in * f_unit, unit):
        new_sfdm_in = default_shank_inches(dc_in, unit)
        new_sfdm = _from_inches(new_sfdm_in, unit)
        changes.append(ToolFieldChange(
            "geometry.SFDM", sfdm_raw, new_sfdm,
            f"Shaft diameter {sfdm_raw} is smaller than the shop rule's shank for a {dc_raw} {'mm' if unit == 'millimeters' else 'in'} "
            f"tool; proposed {new_sfdm}. The shank is assumed to taper from the shank diameter to the cutting "
            f"diameter (continuous taper below)."
        ))
        geo["SFDM"] = new_sfdm
        sfdm_in = new_sfdm_in

    # 2. Stickout (LB), Shoulder Length, Shoulder Diameter, and OAL consistency
    lb_raw = geo.get("LB")
    lb_in = to_inches(lb_raw, unit) if lb_raw not in (None, "") else 0.0
    if lb_in <= lcf_in:
        lb_in = default_stickout(dc_in, lcf_in)
        new_lb = _from_inches(lb_in, unit)
        changes.append(ToolFieldChange(
            "geometry.LB", lb_raw, new_lb,
            "Set body length below holder (LB) to safe stickout above flute length."
        ))
        geo["LB"] = new_lb

    sl_raw = geo.get("shoulder-length")
    sl_in = to_inches(sl_raw, unit) if sl_raw not in (None, "") else 0.0
    if sl_in < lcf_in - 1e-6:
        sl_in = lcf_in
        new_sl = _from_inches(sl_in, unit)
        changes.append(ToolFieldChange(
            "geometry.shoulder-length", sl_raw, new_sl,
            "Aligned shoulder-length to flute length (LCF)."
        ))
        geo["shoulder-length"] = new_sl

    sd_raw = geo.get("shoulder-diameter")
    sd_in = to_inches(sd_raw, unit) if sd_raw not in (None, "") else 0.0
    if sd_in <= 0.0:
        sd_in = dc_in
        new_sd = _from_inches(sd_in, unit)
        changes.append(ToolFieldChange(
            "geometry.shoulder-diameter", sd_raw, new_sd,
            "Populated missing shoulder-diameter with cutting diameter (DC)."
        ))
        geo["shoulder-diameter"] = new_sd

    oal_raw = geo.get("OAL")
    oal_in = to_inches(oal_raw, unit) if oal_raw not in (None, "") else 0.0
    min_oal_in = max(lb_in + sfdm_in * 2.5, 1.5 if dc_in <= 0.125 else lb_in + 0.75)
    if oal_in < lb_in + 0.1:
        oal_in = min_oal_in
        new_oal = _from_inches(oal_in, unit)
        changes.append(ToolFieldChange(
            "geometry.OAL", oal_raw, new_oal,
            "Populated overall length (OAL) to accommodate stickout + collet grip length."
        ))
        geo["OAL"] = new_oal

    # 3. Populate explicit Fusion `shaft.segments` when unmodeled and SFDM != shoulder/cutting diameter
    shaft_node = t.get("shaft") if isinstance(t.get("shaft"), dict) else {}
    existing_segs = shaft_node.get("segments") if isinstance(shaft_node, dict) else None
    d_start_in = sd_in if (sl_in > lcf_in * 1.01 and sd_in > 0) else dc_in

    if populate_shaft_taper and not existing_segs and abs(sfdm_in - d_start_in) > 1e-6 and lb_in > sl_in + 1e-5:
        rem_in = lb_in - sl_in
        margin_in = min(HOLDER_TAPER_MARGIN_IN, 0.25 * rem_in) if rem_in <= HOLDER_TAPER_MARGIN_IN * 1.25 else HOLDER_TAPER_MARGIN_IN
        taper_h_in = max(0.0, rem_in - margin_in)
        upper_shank_h_in = max(margin_in, (oal_in - lb_in) + margin_in)

        new_segments = []
        if taper_h_in > 1e-6:
            new_segments.append({
                "height": _from_inches(taper_h_in, unit),
                "lower-diameter": _from_inches(d_start_in, unit),
                "upper-diameter": _from_inches(sfdm_in, unit),
            })
        new_segments.append({
            "height": _from_inches(upper_shank_h_in, unit),
            "lower-diameter": _from_inches(sfdm_in, unit),
            "upper-diameter": _from_inches(sfdm_in, unit),
        })
        t["shaft"] = {
            "description": f"ToolWiz Continuous Taper (to {HOLDER_TAPER_MARGIN_MM:g}mm below holder)",
            "segments": new_segments,
        }
        changes.append(ToolFieldChange(
            "shaft.segments",
            [],
            new_segments,
            (f"Added continuous shaft taper from {_from_inches(d_start_in, unit)} to {_from_inches(sfdm_in, unit)} "
             f"({unit}) ending {HOLDER_TAPER_MARGIN_MM:g} mm below the tool holder for accurate physics & 3D collision checking."),
        ))

    # 4. Infer missing coating / corner radius from description (never guess when unknown or ambiguous)
    if infer_metadata_from_description and desc:
        desc_low = desc.lower()
        bmc_cur = str(t.get("BMC") or "").strip()
        if not bmc_cur or bmc_cur.lower() in ("carbide", "unspecified", "unknown", "ti coated", "coated"):
            matched_coatings: List[str] = []
            for pattern, label in (
                (r"\baltin\b", "AlTiN"),
                (r"\btialn\b", "TiAlN"),
                (r"\bzrn\b", "ZrN"),
                (r"\b(?:dlc|diamond)\b", "DLC"),
                (r"\bticn\b", "TiCN"),
                (r"\btin\b", "TiN"),
                (r"\b(?:uncoated|bright)\b", "Uncoated"),
            ):
                if re.search(pattern, desc_low) and label not in matched_coatings:
                    matched_coatings.append(label)

            if len(matched_coatings) == 1:
                label = matched_coatings[0]
                t["BMC"] = label
                changes.append(ToolFieldChange(
                    "BMC", bmc_cur or None, label,
                    f"Inferred unambiguous tool coating '{label}' from description '{desc}'."
                ))
            elif len(matched_coatings) > 1:
                warnings.append(
                    f"Ambiguous tool coating in description '{desc}' (matched {', '.join(matched_coatings)}); "
                    "flagged for manual verification without guessing."
                )
            else:
                warnings.append(
                    f"Tool coating (BMC={bmc_cur or 'empty'!r}) is unspecified or ambiguous on '{desc}'; "
                    "flagged for manual verification without guessing."
                )

        re_cur = geo.get("RE")
        if re_cur in (None, "", 0, 0.0) and ("bull" in str(t.get("type", "")).lower() or "cr" in desc_low or "r0." in desc_low or "r." in desc_low):
            m = re.search(r"\b(?:cr|r)\s*(0?\.\d+)\b", desc_low)
            if m:
                inferred_re = float(m.group(1))
                geo["RE"] = inferred_re
                changes.append(ToolFieldChange(
                    "geometry.RE", re_cur, inferred_re,
                    f"Extracted corner radius ({inferred_re}) from tool description '{desc}'."
                ))

    if use_ai:
        try:
            import ai_machinist
            if ai_machinist.is_available():
                prompt = (
                    f"Briefly review this Fusion 360 tool definition ('{desc}', unit={unit}, geometry={geo}) "
                    f"and our auto-curated changes ({[c.to_dict() for c in changes]}). "
                    "In 1-2 sentences, note any additional vendor catalog geometry or preset improvements. "
                    "Do NOT guess the tool coating if it is unknown or ambiguous; simply flag it."
                )
                res = ai_machinist.ask_machinist(prompt, context={"inputs": {"tool": desc}, "outputs": {}})
                if res.get("success") and res.get("answer"):
                    return CuratedToolResult(
                        tool_number=t_num, description=desc, curated_tool=t,
                        changes=changes, warnings=warnings, ai_notes=res["answer"]
                    )
        except Exception:
            pass

    return CuratedToolResult(
        tool_number=t_num,
        description=desc,
        curated_tool=t,
        changes=changes,
        warnings=warnings,
    )


def curate_tool_library(
    tools_or_library: Any,
    fix_micro_shank: bool = True,
    populate_shaft_taper: bool = True,
    infer_metadata_from_description: bool = True,
    use_ai: bool = False,
) -> Dict[str, Any]:
    """Curate a list of Fusion tools or a library dict (`{"tools": [...]}` or `{"data": [...]}`)."""
    if isinstance(tools_or_library, dict):
        raw_tools = tools_or_library.get("tools") or tools_or_library.get("data") or []
    elif isinstance(tools_or_library, list):
        raw_tools = tools_or_library
    else:
        raw_tools = []

    results: List[CuratedToolResult] = []
    curated_tools: List[Dict[str, Any]] = []
    total_changes = 0
    modified_count = 0

    for item in raw_tools:
        if not isinstance(item, dict):
            continue
        r = curate_tool_dict(
            item,
            fix_micro_shank=fix_micro_shank,
            populate_shaft_taper=populate_shaft_taper,
            infer_metadata_from_description=infer_metadata_from_description,
            use_ai=use_ai,
        )
        results.append(r)
        curated_tools.append(r.curated_tool)
        if r.modified:
            modified_count += 1
            total_changes += len(r.changes)

    return {
        "total_tools": len(results),
        "modified_tools": modified_count,
        "total_changes": total_changes,
        "results": [r.to_dict() for r in results],
        "curated_tools": curated_tools,
    }
