"""Holistic AI & Physics Oversight Engine for ToolWiz.

Takes a step back outside of single-operation physics equations (v1/v2) to evaluate whether
the complete machining plan makes sense on the shop floor:
  1. Tool-to-Material & Coating compatibility (e.g., AlTiN in 6061 aluminum, flute count vs. chip valley).
  2. Shaft Taper & Wall Rubbing reality (assumed 0.5 mm holder taper vs. feature depth > flute/neck length).
  3. Chip evacuation, deep-slot recutting, and thermal shock hazards.
  4. Physics model divergence (v1 vs. v2) and narrow "knife-edge" operating windows (runout vs. MCT vs. breakage).
  5. Part rigidity (B-Rep thin walls/floors, internal corner shock) and multi-operation setup sequence logic.
  6. Optional LLM "Master Machinist Second Opinion" synthesis when Gemini API is available.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional


@dataclass
class OversightFinding:
    category: str          # "tool_material" | "shaft_clearance" | "chip_evacuation" | "model_window" | "sequence_brep"
    severity: str          # "STOP" | "CAUTION" | "INFO"
    title: str
    detail: str
    recommendation: str

    def to_dict(self) -> Dict[str, Any]:
        return {
            "category": self.category,
            "severity": self.severity,
            "title": self.title,
            "detail": self.detail,
            "recommendation": self.recommendation,
        }


@dataclass
class OversightReport:
    verdict: str = "PASS"   # "PASS" | "CAUTION" | "STOP"
    score: int = 100        # 0..100 holistic confidence score
    summary: str = ""
    findings: List[OversightFinding] = field(default_factory=list)
    ai_second_opinion: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "verdict": self.verdict,
            "score": self.score,
            "summary": self.summary,
            "findings": [f.to_dict() for f in self.findings],
            "ai_second_opinion": self.ai_second_opinion,
        }


def audit_issue_findings(setup_audit: Dict[str, Any]) -> List[OversightFinding]:
    """Findings for the ``issues`` of a Fusion ``audit_setup_sequence`` report ({operation, severity, message})."""
    out: List[OversightFinding] = []
    sev_map = {"error": "STOP", "warning": "CAUTION", "info": "INFO"}
    for issue in (setup_audit or {}).get("issues") or []:
        out.append(OversightFinding(
            category="sequence_brep",
            severity=sev_map.get(str(issue.get("severity", "warning")).lower(), "CAUTION"),
            title=f"Setup Sequence Issue ({issue.get('operation', 'Op')})",
            detail=str(issue.get("message", "")),
            recommendation="Enable Rest Machining in Fusion or adjust the preceding roughing operation's Stock to Leave."
        ))
    return out


ROUGH_KINDS = ("adaptive", "pocket", "rough")
FINISH_KINDS = ("finish",)


def evaluate_setup_oversight(ops: List[Dict[str, Any]], setup_audit: Optional[Dict[str, Any]] = None) -> List[OversightFinding]:
    """Setup-level sequence checks over an ordered list of operations (deterministic, no physics here).

    Each op dict: ``op_id``, ``name``, ``setup``, ``kind`` ("adaptive", "pocket", "rough", "contour", "slot",
    "finish", "tslot", ...), ``tool_number``, ``tool_diameter_in``, ``stock_radial_in`` (what the op leaves),
    ``rest_machining`` (True / False / None), ``toolwiz_stock_radial_in`` and ``toolwiz_stock_axial_in`` (ToolWiz's
    recommended stock to leave for that op, None when unknown). Lengths inches. Checks, per setup:
    micro tool after a much larger rougher without a rest op, roughing without a later finishing op (stock never
    removed, or no stock so the part comes off at the roughing size), finishing stock from the roughing op vs
    ToolWiz's recommendation, finishing before roughing, tool used again after other tools (avoidable changes).
    ``setup_audit`` issues from the add-in are appended."""
    findings: List[OversightFinding] = []
    by_setup: Dict[str, List[Dict[str, Any]]] = {}
    for o in ops:
        by_setup.setdefault(str(o.get("setup") or ""), []).append(o)

    for sname, seq in by_setup.items():
        label = f" in setup '{sname}'" if sname else ""
        for i, o in enumerate(seq):
            kind = o.get("kind")
            d = o.get("tool_diameter_in") or 0.0
            earlier = seq[:i]
            # 1. micro tool after a much larger rougher with nothing in between and no rest machining
            if d and d <= 0.125 and kind not in ("drill", "hole") and o.get("rest_machining") is not True:
                big = [e for e in earlier if e.get("kind") in ROUGH_KINDS and (e.get("tool_diameter_in") or 0) >= 2.5 * d]
                mids = [e for e in earlier if e.get("kind") in ROUGH_KINDS
                        and d * 1.2 < (e.get("tool_diameter_in") or 0) < (big[-1].get("tool_diameter_in") or 0) * 0.8] if big else []
                if big and not mids:
                    findings.append(OversightFinding(
                        category="setup_sequence", severity="CAUTION",
                        title=f"{o.get('name')}: micro tool follows a much larger rougher{label}",
                        detail=(f"{big[-1].get('name')} uses a {big[-1].get('tool_diameter_in'):.4f} in tool and {o.get('name')} a "
                                f"{d:.4f} in tool with no intermediate tool and rest machining not confirmed, so the small tool may "
                                f"see full-slot corners and uneven stock."),
                        recommendation="Enable rest machining on the small tool's operation or add an intermediate semi-finishing tool."))
            # 2/3. finishing ops: stock from the roughing that precedes them
            if kind in FINISH_KINDS:
                rough_before = [e for e in earlier if e.get("kind") in ROUGH_KINDS]
                rough_after = [e for e in seq[i + 1:] if e.get("kind") in ROUGH_KINDS]
                if rough_after and not rough_before:
                    findings.append(OversightFinding(
                        category="setup_sequence", severity="CAUTION",
                        title=f"{o.get('name')}: finishing runs before roughing{label}",
                        detail=f"Finishing operation {o.get('name')} is ahead of {rough_after[0].get('name')}, so the roughing pass will disturb the finished surface.",
                        recommendation="Move the finishing operation after the roughing operations that feed it."))
                if rough_before:
                    r = rough_before[-1]
                    have, want = r.get("stock_radial_in"), r.get("toolwiz_stock_radial_in")
                    if have is not None and have <= 0.00005:
                        findings.append(OversightFinding(
                            category="setup_sequence", severity="CAUTION",
                            title=f"{o.get('name')}: roughing leaves no stock for the finishing pass{label}",
                            detail=(f"{r.get('name')} leaves {have:.4f} in radial stock, so {o.get('name')} has nothing to cut: the "
                                    f"finishing tool rubs and the part keeps the roughing error."
                                    + (f" ToolWiz recommends leaving {want:.4f} in." if want else "")),
                            recommendation="Set the roughing stock to leave to ToolWiz's recommendation so the finishing pass makes a real cut."))
                    elif have is not None and want is not None and have < want * 0.999:
                        findings.append(OversightFinding(
                            category="setup_sequence", severity="CAUTION",
                            title=f"{o.get('name')}: finishing stock below ToolWiz's recommendation{label}",
                            detail=(f"{r.get('name')} leaves {have:.4f} in radial stock; ToolWiz recommends {want:.4f} in so the finisher "
                                    f"removes the roughing deflection and springback instead of rubbing."),
                            recommendation=f"Raise the roughing stock to leave to {want:.4f} in."))
        # roughing without a later finishing op
        finishes = [e for e in seq if e.get("kind") in FINISH_KINDS]
        for i, o in enumerate(seq):
            if o.get("kind") not in ROUGH_KINDS:
                continue
            later_fin = [e for e in seq[i + 1:] if e.get("kind") in FINISH_KINDS]
            later_cont = [e for e in seq[i + 1:] if e.get("kind") in ("contour", "slot")]
            if later_fin or later_cont:
                continue
            have, want = o.get("stock_radial_in"), o.get("toolwiz_stock_radial_in")
            if have is not None and have > 0.00005:
                findings.append(OversightFinding(
                    category="setup_sequence", severity="CAUTION",
                    title=f"{o.get('name')}: stock is left but no finishing operation follows{label}",
                    detail=f"{o.get('name')} leaves {have:.4f} in radial stock and nothing later in the setup removes it, so the part stays oversize.",
                    recommendation="Add a finishing contour/parallel operation after it, or set the stock to leave to zero if rough-to-size is intended."))
            elif not finishes:
                findings.append(OversightFinding(
                    category="setup_sequence", severity="CAUTION",
                    title=f"{o.get('name')}: no finishing pass for a true-to-size part{label}",
                    detail=(f"{o.get('name')} roughs to size with no stock left and no finishing operation, so tool deflection and springback go straight into the part."
                            + (f" ToolWiz recommends leaving {want:.4f} in radially for a finishing pass." if want else "")),
                    recommendation="Leave ToolWiz's stock to leave on the roughing operation and add a finishing pass."))
        # tool changes: a tool used again after other tools
        seen: Dict[Any, int] = {}
        order: List[Any] = []
        for o in seq:
            key = o.get("tool_number") if o.get("tool_number") is not None else o.get("tool_key")
            if key is None:
                continue
            if not order or order[-1] != key:
                order.append(key)
        extra = len(order) - len(set(order))
        for k in order:
            seen[k] = seen.get(k, 0) + 1
        repeated = [k for k, n in seen.items() if n > 1]
        if extra > 0:
            findings.append(OversightFinding(
                category="setup_sequence", severity="INFO",
                title=f"Avoidable tool changes{label}",
                detail=(f"Tool(s) {', '.join(str(k) for k in repeated)} are used again after other tools, giving {extra} avoidable tool "
                        f"change(s) in this setup's order of operations."),
                recommendation="Group operations by tool where the geometry allows (finish with the same tool in one go) to save tool changes."))

    if isinstance(setup_audit, dict):
        findings.extend(audit_issue_findings(setup_audit))
    return findings


def evaluate_holistic_oversight(
    cut_request: Dict[str, Any],
    cut_result: Dict[str, Any],
    feature_geometry: Optional[Dict[str, Any]] = None,
    setup_audit: Optional[Dict[str, Any]] = None,
    include_ai_opinion: bool = False,
) -> OversightReport:
    """Run holistic shop-floor oversight checks outside the base speed/feed equations."""
    findings: List[OversightFinding] = []

    family = str(cut_request.get("family") or cut_result.get("family") or "").strip()
    alloy = str(cut_request.get("alloy") or cut_result.get("alloy") or "").strip()
    operation = str(cut_request.get("operation") or cut_result.get("operation") or "Roughing").strip()
    coating = str(cut_request.get("coating") or cut_result.get("coating") or "Uncoated").strip()
    tool_type = str(cut_request.get("tool") or cut_result.get("tool") or "Carbide Endmill").strip()
    dia = float(cut_result.get("diameter") or cut_request.get("diameter") or 0.25)
    flutes = int(cut_request.get("flutes") or (cut_result.get("profile") or {}).get("flutes") or 4)
    flute_len = float(cut_result.get("flute_length") or cut_request.get("fluteLength") or (dia * 3.0))
    shank_dia = float(cut_result.get("shank_diameter") or cut_request.get("shankDiameter") or dia)
    doc = float(cut_result.get("doc") or cut_request.get("cutDepth") or 0.0)
    woc = float(cut_result.get("woc") or cut_request.get("cutWidth") or 0.0)
    rpm = float(cut_result.get("rpm") or 0.0)
    feed_ipm = float(cut_result.get("feed_ipm") or cut_result.get("feedrate") or 0.0)
    adj_ipt = float(cut_result.get("adj_ipt") or cut_result.get("ipt") or 0.0)
    deflection = float(cut_result.get("deflection") or 0.0)
    rec_limit = float(cut_result.get("rec_limit") or 0.001)
    profile = cut_result.get("profile") or {}
    segments = profile.get("segments") or []
    fgeo = feature_geometry or cut_result.get("feature_geometry") or cut_request.get("feature_geometry") or {}

    fam_low = f"{family} {alloy}".lower()
    coat_low = coating.lower()
    op_low = operation.lower()

    # -------------------------------------------------------------------------
    # 1. Tool-to-Material & Coating Compatibility
    # -------------------------------------------------------------------------
    is_aluminum = any(k in fam_low for k in ("aluminum", "6061", "7075", "2024", "5052", "non-ferrous", "镁", "brass", "copper"))
    is_gummy_exotic = any(k in fam_low for k in ("stainless", "17-4", "304", "316", "titanium", "ti-6al", "inconel", "nickel", "hastelloy", "monel"))
    is_hard_steel = any(k in fam_low for k in ("tool steel", "hardened", "h13", "d2", "a2", "s7", "m2", "4140"))

    raw_coat = str(cut_request.get("coating") or cut_result.get("coating") or "").strip()
    ft_bmc = str((cut_request.get("fusion_tool") or {}).get("BMC") or "").strip().lower()
    # An explicit "Uncoated" / "bright" / "none" in the request is a known coating; a coating the request left empty is not.
    explicit_bare = str(cut_request.get("coating") or "").strip().lower() in ("uncoated", "bright", "none", "no coating")
    coat_ambiguous = not explicit_bare and (bool(cut_request.get("coating_ambiguous")) or (
        raw_coat.lower() in ("", "unknown", "unspecified", "ambiguous", "ti coated", "generic")
    ) or (ft_bmc in ("ti coated", "unspecified", "unknown") and not cut_request.get("coating")))
    if coat_ambiguous:
        findings.append(OversightFinding(
            category="tool_material",
            severity="CAUTION",
            title="Tool Coating Unknown or Ambiguous — Flagged (Not Guessed)",
            detail=(f"Tool coating is unspecified or generic ({str(cut_request.get('coating') or '').strip() or ft_bmc or 'not set'}). "
                    "ToolWiz will not guess an ambiguous coating; verify the physical cutter's coating."),
            recommendation="Set the exact coating (e.g., Uncoated, ZrN, AlTiN, TiAlN) in the Fusion tool library or UI."
        ))

    if is_aluminum:
        if any(k in coat_low for k in ("altin", "tialn")):
            findings.append(OversightFinding(
                category="tool_material",
                severity="CAUTION",
                title="AlTiN / TiAlN Coating in Aluminum (BUE / Galling Advisory)",
                detail=(f"Coating '{coating}' works in aluminum with good chip evacuation/coolant, but its aluminum "
                        f"content has higher chemical affinity with wrought aluminum ({family or alloy}) and can increase built-up edge (BUE) risk."),
                recommendation="Monitor flutes for chip sticking, or prefer Uncoated polished, ZrN, TiB2, or DLC for heavy aluminum cuts."
            ))
        if flutes >= 4 and woc > 0 and ("slot" in op_low or (dia > 0 and woc / dia >= 0.5) or dia <= 0.125):
            findings.append(OversightFinding(
                category="tool_material",
                severity="CAUTION",
                title=f"{flutes}-Flute Tool in Aluminum with High Engagement",
                detail=(f"A {flutes}-flute cutter has smaller chip gullets. At WOC = {woc:.4f}\" ({woc / max(dia, 1e-6) * 100:.0f}% D) "
                        f"in aluminum, chips can pack in the flutes and weld the tool."),
                recommendation="Prefer a 2-flute or 3-flute high-helix end mill for aluminum slotting or micro-machining."
            ))

    if is_gummy_exotic:
        if any(k in coat_low for k in ("zrn", "dlc", "diamond")) or "uncoated" in coat_low:
            findings.append(OversightFinding(
                category="tool_material",
                severity="CAUTION",
                title=f"Non-Thermal Coating ({coating}) in {family or alloy}",
                detail=(f"Machining {family or alloy} generates intense shear-zone heat. '{coating}' lacks the "
                        "thermal barrier oxidation resistance of AlTiN / TiAlN."),
                recommendation="Use an AlTiN, TiAlN, or nACo coated carbide end mill to prevent rapid crater/flank wear."
            ))
        if flutes <= 2 and dia >= 0.125 and "slot" not in op_low:
            findings.append(OversightFinding(
                category="tool_material",
                severity="INFO",
                title=f"Low Flute Count ({flutes}FL) in {family or alloy}",
                detail=(f"A {flutes}-flute end mill has a smaller core diameter (~52% D) and lower bending stiffness "
                        f"than a 4- or 5-flute tool (~62-68% D) for side/adaptive milling in {family or alloy}."),
                recommendation="Consider a 4- or 5-flute variable-helix end mill for higher core rigidity and MRR."
            ))

    # -------------------------------------------------------------------------
    # 2. Shaft Taper & Wall-Rubbing / Clearance Reality
    # -------------------------------------------------------------------------
    taper_segs = [s for s in segments if s.get("kind") == "taper"]
    neck_segs = [s for s in segments if s.get("kind") == "neck"]
    flute_segs = [s for s in segments if s.get("kind") == "flute"]
    max_cleared_reach = max(
        [float(s.get("end", 0.0)) for s in (flute_segs + neck_segs)] or [flute_len]
    )

    if taper_segs and shank_dia > dia * 1.01:
        t0 = taper_segs[0]
        findings.append(OversightFinding(
            category="shaft_clearance",
            severity="INFO",
            title="Continuous Shaft Taper Modeled (0.5 mm Below Holder)",
            detail=(f"Because the shank ({shank_dia:.4f}\") is larger than the cutter/neck ({t0.get('d0', dia):.4f}\"), "
                    f"ToolWiz modeled a continuous taper from z = {t0.get('start', flute_len):.4f}\" to "
                    f"z = {t0.get('end', 0.0):.4f}\" (0.5 mm below the holder)."),
            recommendation=("If this tool has a steeper vendor neck taper or longer reduced neck, use the ToolWiz "
                            "Library Curator to populate explicit shaft segments in Fusion's Shaft tab.")
        ))

    feat_depth = fgeo.get("feature_depth_in")
    effective_depth = max(doc, float(feat_depth or 0.0))
    if effective_depth > max_cleared_reach + 1e-4 and shank_dia > dia * 1.01:
        findings.append(OversightFinding(
            category="shaft_clearance",
            severity="STOP",
            title="Shaft Taper / Shank Will Rub Vertical Feature Wall",
            detail=(f"Feature/cut depth ({effective_depth:.4f}\") exceeds the cleared flute/neck length "
                    f"({max_cleared_reach:.4f}\") on a tool whose shaft expands from {dia:.4f}\" to {shank_dia:.4f}\"."),
            recommendation=(f"Switch to a relieved-neck (long-reach) tool with shoulder length >= {effective_depth + 0.020:.3f}\", "
                            "or step the pocket wall outward.")
        ))

    # -------------------------------------------------------------------------
    # 3. Chip Evacuation, Deep-Slot Recutting & Thermal Shock
    # -------------------------------------------------------------------------
    if dia > 0 and woc > 0 and doc / dia > 1.25 and ("slot" in op_low or (woc / dia >= 0.75)):
        sev = "STOP" if (dia <= 0.125 and doc / dia > 1.5) else "CAUTION"
        findings.append(OversightFinding(
            category="chip_evacuation",
            severity=sev,
            title=f"Deep Full-Width Slot ({doc / dia:.2f}xD Axial Depth)",
            detail=(f"Slotting {doc:.4f}\" deep ({doc / dia:.2f}xD) at {woc / dia * 100:.0f}% radial engagement traps chips "
                    "in the slot channel. Even if bending stress passes, chip recutting can snap the cutter."),
            recommendation=("Reduce stepdown to <= 0.5xD (<= 0.25xD for micro tools) with high-pressure air/coolant blast, "
                            "or switch to an adaptive/trochoidal clearing strategy.")
        ))

    if is_hard_steel and "adaptive" in op_low and rpm * 3.14159 * dia / 12.0 > 350.0:
        findings.append(OversightFinding(
            category="chip_evacuation",
            severity="INFO",
            title="Thermal Shock Advisory for High-Speed Hard Milling",
            detail="High-SFM adaptive roughing in hardened/alloy steel cycles the carbide flutes through extreme temperatures.",
            recommendation="Prefer high-pressure air blast or MQL over flood coolant to prevent thermal-shock micro-fractures."
        ))

    # -------------------------------------------------------------------------
    # 4. Physics Model Divergence (v1 vs. v2) & Narrow Operating Window
    # -------------------------------------------------------------------------
    v1_data = cut_result.get("v1")
    v2_data = cut_result.get("v2")
    if isinstance(v1_data, dict) and isinstance(v2_data, dict):
        v1_feed = float(v1_data.get("feed_ipm") or 0.0)
        if v1_feed > 0 and feed_ipm > 0:
            rel_diff = abs(feed_ipm - v1_feed) / max(v1_feed, feed_ipm)
            if rel_diff > 0.35 and feed_ipm > v1_feed:      # only worth a caution when the current engine is the faster one
                binding = ", ".join(v2_data.get("binding") or []) or "mechanistic constraints"
                findings.append(OversightFinding(
                    category="model_window",
                    severity="CAUTION",
                    title=f"Feed is {rel_diff * 100:.0f}% above the older table-based estimate",
                    detail=(f"The physics engine gives {feed_ipm:.1f} IPM; the older table-based engine would give {v1_feed:.1f} IPM."),
                    recommendation="Start at a reduced feed override and work up while watching the cut."
                ))

    runout = float(cut_request.get("runout") or 0.0002)
    if adj_ipt > 0 and runout / adj_ipt >= 0.45 and rec_limit > 0 and deflection / rec_limit >= 0.75:
        findings.append(OversightFinding(
            category="model_window",
            severity="CAUTION",
            title="Narrow 'Knife-Edge' Operating Window (Runout + Deflection)",
            detail=(f"Spindle/holder runout ({runout:.5f}\") is {runout / adj_ipt * 100:.0f}% of the chip load ({adj_ipt:.5f}\") "
                    f"while tool deflection is already at {deflection / rec_limit * 100:.0f}% of the limit."),
            recommendation="Use a high-precision collet/shrink-fit holder (TIR <= 0.0001\") or reduce DOC by 25% to widen the safe margin."
        ))

    # -------------------------------------------------------------------------
    # 5. Live B-Rep Geometry & Setup Sequence Synthesis
    # -------------------------------------------------------------------------
    if fgeo.get("stickout_collision"):
        findings.append(OversightFinding(
            category="sequence_brep",
            severity="STOP",
            title="Holder / Collet Will Collide with Feature Top",
            detail=(f"B-Rep feature depth ({fgeo.get('feature_depth_in', 0):.3f}\") + clearance requires "
                    f"{fgeo.get('required_reach_in', 0):.3f}\" reach, exceeding stickout ({fgeo.get('stickout_in', 0):.3f}\")."),
            recommendation="Increase tool stickout in the holder or select a longer-reach tool."
        ))

    if fgeo.get("corner_radius_warning"):
        findings.append(OversightFinding(
            category="sequence_brep",
            severity="CAUTION",
            title="Internal Corner Radius Smaller Than Cutter Radius",
            detail=str(fgeo.get("corner_radius_warning")),
            recommendation="Add a subsequent rest-machining contour pass with a smaller-diameter end mill."
        ))

    if fgeo.get("is_thin_wall") or fgeo.get("is_thin_floor"):
        findings.append(OversightFinding(
            category="sequence_brep",
            severity="CAUTION",
            title="Thin-Wall / Thin-Floor Part Deflection Risk",
            detail=(f"B-Rep inspection found min wall = {fgeo.get('min_wall_thickness_in')} in, "
                    f"min floor = {fgeo.get('min_floor_thickness_in')} in "
                    f"(compliance factor {fgeo.get('workpiece_compliance_factor', 1.0):.2f}x)."),
            recommendation="Use watermark/stepped Z-level passes supporting the thin wall with uncut stock, and apply Stock Compensation."
        ))

    if isinstance(setup_audit, dict):
        findings.extend(audit_issue_findings(setup_audit))

    # Compute overall verdict & confidence score
    n_stop = sum(1 for f in findings if f.severity == "STOP")
    n_caution = sum(1 for f in findings if f.severity == "CAUTION")
    if n_stop > 0 or not cut_result.get("feasible", True):
        verdict = "STOP"
    elif n_caution > 0:
        verdict = "CAUTION"
    else:
        verdict = "PASS"

    score = max(0, 100 - (n_stop * 35) - (n_caution * 12))
    if verdict == "PASS":
        summary = f"Holistic Oversight PASS ({score}/100): Tool geometry, material pairing, and cut engagement look sound."
    elif verdict == "CAUTION":
        summary = f"Holistic Oversight CAUTION ({score}/100): {n_caution} shop-floor advisory item(s) warrant review before cutting."
    else:
        summary = f"Holistic Oversight STOP ({score}/100): {n_stop} critical physical or sequence hazard(s) detected."

    report = OversightReport(verdict=verdict, score=score, summary=summary, findings=findings)

    if include_ai_opinion:
        try:
            import ai_machinist
            if ai_machinist.is_available():
                prompt = (
                    "Give a concise 2-3 sentence Master Machinist second-opinion oversight summary for this cut. "
                    f"Verdict: {verdict} ({score}/100). "
                    f"Findings: {[f.to_dict() for f in findings]}."
                )
                ai_res = ai_machinist.ask_machinist(
                    question=prompt,
                    context={"inputs": cut_request, "outputs": cut_result, "feature_geometry": fgeo},
                )
                if ai_res.get("success") and ai_res.get("answer"):
                    report.ai_second_opinion = ai_res["answer"]
        except Exception:
            pass

    return report
