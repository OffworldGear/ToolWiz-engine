"""Single calculation pipeline for every speeds-and-feeds endpoint.

All endpoints (/api/calculate, /api/calculate_for_fusion, /api/twin/batch_generate,
/api/stock_compensation) build a :class:`CutRequest` and call :func:`run_cut`, so the
physics is applied in ONE canonical order and every SFM / IPT change is recorded in
``CutResult.provenance``.

Canonical order (the order /api/calculate has always used):

    base SFM / IPT lookup
      -> alloy hardness scaling (incl. the >45 HRC hard-milling correction)
      -> chatter / stickout penalty
      -> aggressiveness            (not taps)
      -> HEM thermal SFM boost     (not taps)
      -> coating multiplier        (not taps)
      -> effective diameter -> ideal RPM -> spindle cap -> RPM
      -> chip thinning / adjusted chipload (or tap lead) -> feed
      -> ramping -> deflection / springback -> tips -> recommended DOC/WOC

``cut_depth`` / ``cut_width`` may be ``None``: the pipeline then runs a recommendation
pre-pass (speed chain at a provisional engagement, plain-diameter RPM, then
``recommend_cut_parameters``) and uses the recommended DOC/WOC as the cut.

Provenance entries: ``{"step", "quantity": "sfm"|"ipt", "multiplier", "value_after", "reason"}``.
Each multiplier is ``after / before`` of that step, so::

    base_sfm * prod(sfm multipliers except "spindle_cap") == target_sfm
    base_ipt * prod(ipt multipliers)                      == adj_ipt
"""
from __future__ import annotations

import dataclasses
import math
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional

from toolwiz_common import (
    ToolProfile,
    default_stickout,
    calc_corner_engagement,
    calc_thin_wall_compliance_factor,
    is_wall_only_operation,
)
from toolwiz_common.tool_profile import SHANK_WARNING
from toolwiz_common.runout import default_runout, holder_description_of
from gwizard_physics import (
    ASTMHardnessConverter,
    BeamDeflectionEngine,
    HARD_MILL_ONSET_HRC,
    WORK_HARDENING_CHIPLOAD_FLOOR,
    alloy_work_hardens,
    is_drilling_tool_type,
    is_tap_tool_type,
    reach_chipload_floor,
)


@dataclass
class CutRequest:
    """Every input the endpoints feed into the physics. Lengths in inches, feeds in IPM."""
    family: str = ""
    alloy: str = ""
    tool: str = "Carbide Endmill"          # tool category (DB lookup key / tool type text)
    geometry: str = "Square"
    operation: str = "Roughing"
    coating: str = "Uncoated"
    diameter: float = 0.5
    flutes: int = 4
    flute_length: float = 1.0
    shank_diameter: Optional[float] = None  # None -> diameter
    neck_diameter: Optional[float] = None   # None -> shank diameter (when relieved/form-stepped)
    neck_length: float = 0.5
    has_relieved_neck: bool = False
    corner_radius: float = 0.0
    taper_angle: float = 0.0
    helix_angle: float = 30.0
    stickout: Optional[float] = 1.5         # None -> Fusion LB (with fusion_tool) / default 3.15xD
    cutter_thickness: float = 0.125
    is_carbide: bool = True
    aggressiveness: float = 0.5             # 0.0 - 1.0
    max_rpm: float = 16000.0
    max_hp: float = 10.0
    # TIR at the tool tip (in). None: not given, so _normalize defaults it (toolwiz_common.runout): the Fusion tool's holder
    # class when `holder` or fusion_tool["holder"] names one, else 0.0001" for tools <= 1/8" and 0.0002" above.
    runout: Optional[float] = None
    runout_source: Optional[str] = None     # set by _normalize
    holder: Optional[str] = None            # holder description ("Lyndex SK10"); fusion_tool["holder"] is used when absent
    cut_depth: Optional[float] = None       # None -> use the recommended DOC
    cut_width: Optional[float] = None       # None -> use the recommended WOC
    tap_type: str = ""
    pitch: Optional[float] = 0.05           # thread pitch (in); taps only
    is_metric: bool = False                 # only affects tip text units
    apply_coating: bool = True              # False when the coating isn't known for this tool (batch hole tools)
    # Fusion tool dict ({"type","unit","geometry"}): when given it is the single authoritative
    # source of diameter / flutes / flute length / shank / stickout / corner radius / neck.
    fusion_tool: Optional[Dict[str, Any]] = None
    profile: Optional[ToolProfile] = None   # built in _normalize
    # Cutting model (v2_bridge): "v1" (default) or "v2". The endpoints resolve it from the request,
    # the saved setting and TOOLWIZ_MODEL; None here means v1.
    model: Optional[str] = None
    machine_profile: Optional[Dict[str, Any]] = None   # active machine profile (v2 spindle/holder data)
    # True when cut_depth/cut_width came from the user (sliders, Fusion stepdown/stepover); None: infer from them.
    engagement_explicit: Optional[bool] = None
    # Finish modes (finish_modes.py): "cleanup" (default) | "surface" | "accuracy"; Ra target (micro-inches) and wall
    # tolerance (inches) override the mode's defaults.
    finish_mode: Optional[str] = None
    target_ra: Optional[float] = None
    wall_tolerance: Optional[float] = None
    feature_geometry: Optional[Dict[str, Any]] = None  # live B-Rep geometry from cam_geometry_inspector
    # T-slot / keyseat / woodruff cutters (tslot_model); all optional
    tooth_form: Optional[str] = None                 # "straight" | "staggered" | None (unknown -> staggered)
    cutting_faces: Optional[List[str]] = None        # subset of periphery / top / bottom
    teeth_per_face: Optional[int] = None
    tslot_operation: str = "full_slot"               # full_slot | side_cut | both_sides | axial_step
    slot_height: Optional[float] = None              # finished slot height along Z (in)
    radial_depth_total: Optional[float] = None       # total radial depth wanted (in)


@dataclass
class CutResult:
    rpm: float = 0.0
    diameter: float = 0.0           # nominal cutting diameter actually used (from the profile when fusion_tool is given)
    sfm: float = 0.0                # actual SFM at the nominal diameter
    contact_sfm: float = 0.0        # SFM at the effective (contact) diameter
    ideal_rpm: float = 0.0
    is_spindle_limited: bool = False
    effective_diameter: float = 0.0
    base_ipt: float = 0.0           # chipload after hardness/chatter/aggressiveness
    adj_ipt: float = 0.0            # chipload after chip thinning / tap lead
    feed_ipm: float = 0.0
    doc: float = 0.0                # depth of cut the feed was computed for
    woc: float = 0.0                # width of cut the feed was computed for
    rec_doc: float = 0.0
    rec_woc: float = 0.0
    rec_limit: float = 0.0
    feasible: bool = True
    limited_by: Optional[str] = None
    ramp_angle: float = 0.0
    ramp_feed: float = 0.0
    plunge_feed: float = 0.0
    # v2 ramp model only (physics_v2/ramp.py via v2_bridge); v1 has no helix diameter or ramp speed (None).
    ramp_diameter: Optional[float] = None       # tool-centre helix diameter (in)
    ramp_min_diameter: Optional[float] = None   # smallest helix diameter the model allows (in)
    ramp_rpm: Optional[float] = None            # spindle speed the ramp feed is computed at
    # Runout regime and engagement source (v2; V3 plan "API contracts"). flutes_cutting / runout_regime /
    # tir_all_flutes_in / runout_ratio stay None under v1.
    flutes_cutting: Optional[int] = None        # flutes that form a chip at the chosen feed under the given runout
    runout_regime: Optional[str] = None         # "all_flutes" | "reduced_flutes"
    tir_all_flutes_in: Optional[float] = None   # largest runout (in) at which every flute would cut at this feed
    runout_ratio: Optional[float] = None        # tooth-to-tooth radial offset / feed per tooth
    engagement_source: str = "recommended"      # "user": rpm/feed computed for the request's DOC/WOC
    # Stock the finishing pass needs (v2 roughing, adaptive and slotting): radial = max(0.05 mm, 1.5 x wall-normal
    # deflection + springback) rounded up to 0.0005"; axial = max(0.05 mm, 1.5 x axial springback).
    recommended_radial_stock_in: Optional[float] = None
    recommended_axial_stock_in: Optional[float] = None
    finish: Optional[Dict[str, Any]] = None     # finish_modes block for finishing operations
    mrr: float = 0.0
    deflection: float = 0.0
    springback: float = 0.0
    total_error: float = 0.0
    wear_comp: float = 0.0
    tips: List[Dict[str, Any]] = field(default_factory=list)
    provenance: List[Dict[str, Any]] = field(default_factory=list)
    # Extras the endpoints echo back
    base_sfm: float = 0.0           # raw DB lookup, before any multiplier
    base_ipt_lookup: float = 0.0    # raw DB lookup, before any multiplier
    target_sfm: float = 0.0         # SFM target before the spindle cap
    ipr: float = 0.0
    is_floor_finish: bool = False
    is_finishing: bool = False
    is_hole_tool: bool = False
    is_tapping: bool = False
    operation: str = ""             # operation after hole-tool remapping
    geometry: str = ""
    tool: str = ""
    coating: str = ""
    tap_type: str = ""
    tap_drill: Optional[Dict[str, Any]] = None
    flute_length: float = 0.0
    shank_diameter: float = 0.0
    neck_diameter: float = 0.0
    profile: Optional[Dict[str, Any]] = None   # ToolProfile.to_dict()
    model: str = "v1"               # the model that produced rpm/feed/doc/woc
    model_note: str = ""            # why v1 was used when v2 was selected, or the v2 summary
    v1: Optional[Dict[str, Any]] = None   # v1's core numbers when v2 produced the result
    v2: Optional[Dict[str, Any]] = None   # v2 details: binding limits, checks, warnings, provenance
    feature_geometry: Optional[Dict[str, Any]] = None
    corner_feed_ipm: Optional[float] = None
    tslot: Optional[Dict[str, Any]] = None  # tslot_model output for T-slot / keyseat / woodruff cutters
    runout_in: Optional[float] = None         # the runout (TIR, in) the result was computed with
    runout_source: Optional[str] = None       # "request" | "holder: <class>" | "default by diameter"
    holder_advice: Optional[Dict[str, Any]] = None   # toolwiz_common.tooling_advisor.holder_advice (advice_wiring)
    tool_advice: List[Dict[str, Any]] = field(default_factory=list)   # tooling_advisor.tool_advice (advice_wiring)


def _ratio(after: float, before: float) -> float:
    return (after / before) if before else 1.0


class _Prov:
    """Collects provenance steps for one SFM chain and one IPT chain."""

    def __init__(self):
        self.steps: List[Dict[str, Any]] = []

    def add(self, step: str, quantity: str, before: float, after: float, reason: str):
        self.steps.append({
            "step": step,
            "quantity": quantity,
            "multiplier": float(_ratio(after, before)),
            "value_after": float(after),
            "reason": reason,
        })


# Legacy tool categories that baked a geometry into the category name. They map to the base
# endmill category plus a Geometry selection ("Radiused" is the Bullnose / Radiused option value).
_LEGACY_GEOMETRY_TOOLS = {
    "hp carbide bull nose endmill": ("HP Carbide Endmill", "Radiused"),
    "hp carbide high feed endmill": ("HP Carbide Endmill", "High Feed"),
    "carbide bull nose endmill": ("Carbide Endmill", "Radiused"),
    "carbide high feed endmill": ("Carbide Endmill", "High Feed"),
}


def _normalize(req: CutRequest) -> CutRequest:
    """Contextual resolution shared by all endpoints (copy; never mutates the caller's request)."""
    r = dataclasses.replace(req)
    r.tool = str(r.tool or "")
    r.geometry = str(r.geometry or "Square")
    r.operation = str(r.operation or "Roughing")
    r.coating = r.coating or "Uncoated"
    r.family = r.family or ""
    r.alloy = r.alloy or ""

    # Legacy geometry-in-category names -> base category + geometry (only when none was chosen)
    legacy = _LEGACY_GEOMETRY_TOOLS.get(r.tool.strip().lower())
    if legacy:
        r.tool = legacy[0]
        if r.geometry.strip().lower() in ("", "square"):
            r.geometry = legacy[1]

    # Legacy baked-in coating tool names: don't double-multiply the coating
    if "tialn" in r.tool.lower() or "altin" in r.tool.lower():
        r.tool = "Carbide Endmill"
        if r.coating == "Uncoated" or not r.coating:
            r.coating = "AlTiN"

    # Tap style: explicit geometry wins, then the requested tap type, then "form"
    geo_lower = r.geometry.lower()
    if "form" in geo_lower or "roll" in geo_lower:
        r.tap_type = "form"
    elif "spiral_point" in geo_lower or "gun" in geo_lower:
        r.tap_type = "spiral_point"
    elif "straight" in geo_lower or "hand" in geo_lower:
        r.tap_type = "straight_flute"
    elif "spiral_flute" in geo_lower or ("spiral" in geo_lower and "point" not in geo_lower):
        r.tap_type = "spiral_flute"
    elif not r.tap_type:
        r.tap_type = "form"

    # Saw / woodruff / keyseat cutters: chatter penalty bypassed, flute length = cutter thickness
    is_saw = (any(s in geo_lower for s in ["t-slot", "woodruff", "keyseat"])
              or any(s in r.tool.lower() for s in ["woodruff", "saw"]))
    if is_saw:
        if not any(s in geo_lower for s in ["t-slot", "keyseat", "woodruff"]):
            r.geometry = "T-Slot"
        if r.cutter_thickness > 0.0:
            r.flute_length = r.cutter_thickness

    shank = r.shank_diameter if r.shank_diameter is not None else r.diameter
    r.shank_diameter = float(shank)
    is_form_stepped = is_saw or any(s in r.geometry.lower() for s in ["lollipop", "dovetail"])
    if r.has_relieved_neck or is_form_stepped:
        r.neck_diameter = float(r.neck_diameter) if r.neck_diameter is not None else r.shank_diameter
    else:
        # No relieved neck: the shank starts right after the flutes. (Previously a default
        # 0.5" neck at the CUTTING diameter was assumed, so a 1/16" tool on a 1/8" shank was
        # modelled as a 1/16" rod out to 0.5" and the shank never counted.)
        r.neck_diameter = r.diameter
        r.neck_length = r.flute_length

    is_plain_drill = (
        is_drilling_tool_type(r.tool, r.geometry)
        and not is_tap_tool_type(r.tool)
        and "ream" not in r.tool.lower()
        and "ream" not in r.geometry.lower()
    )
    if is_plain_drill and r.flutes > 3:
        r.flutes = 2

    if r.fusion_tool:
        # Fusion's own fields are authoritative; stickout only overrides when explicitly set.
        ov = r.stickout if (r.stickout is not None and r.stickout > 0) else None
        ft_copy = dict(r.fusion_tool)
        if is_plain_drill and isinstance(ft_copy.get("geometry"), dict):
            nof = ft_copy["geometry"].get("NOF")
            if nof is not None and int(nof) > 3:
                ft_copy["geometry"] = dict(ft_copy["geometry"], NOF=2)
        prof = ToolProfile.from_fusion(ft_copy, stickout_override=ov)
        g = prof.geometry
        r.diameter, r.flutes, r.flute_length = g.diameter, g.flutes, g.flute_length
        r.shank_diameter, r.corner_radius, r.stickout = g.shank_diameter, g.corner_radius, prof.stickout
        if g.thread_pitch and g.thread_pitch > 0.0 and (req.pitch is None or req.pitch == 0.05):
            r.pitch = g.thread_pitch
        neck = next((sg for sg in prof.segments if sg.kind == "neck"), None)
        if neck is not None:
            r.has_relieved_neck = True
            r.neck_diameter, r.neck_length = neck.d0, neck.end
        else:
            r.has_relieved_neck = False
            r.neck_diameter, r.neck_length = r.diameter, r.flute_length
        if prof.slot:
            # Slot / keyseat / T-slot cutter: kerf = LCF, neck and reach from the shaft segments.
            r.cutter_thickness = prof.slot["kerf"]
            r.has_relieved_neck = True
            r.neck_diameter, r.neck_length = prof.slot["neck_diameter"], prof.slot["reach"]
            if "t-slot" not in r.geometry.lower() and "keyseat" not in r.geometry.lower() \
                    and "woodruff" not in r.geometry.lower():
                r.geometry = "T-Slot"
    else:
        if r.stickout is None or r.stickout <= 0:
            r.stickout = default_stickout(r.diameter, r.flute_length)
        prof = ToolProfile.from_legacy(
            r.diameter, r.flutes, r.flute_length, r.shank_diameter, r.stickout,
            has_relieved_neck=bool(r.has_relieved_neck or is_form_stepped),
            neck_diameter=r.neck_diameter, neck_length=r.neck_length,
            taper_angle=r.taper_angle, corner_radius=r.corner_radius, assume_shaft_taper=True)
    r.profile = prof
    if r.runout is None:
        holder = r.holder or holder_description_of(r.fusion_tool)
        r.runout, r.runout_source = default_runout(r.diameter, holder)
    else:
        r.runout, r.runout_source = float(r.runout), "request"
    return r


class _Ctx:
    """Derived flags computed once from the normalized request."""

    def __init__(self, r: CutRequest, geo_lower_original: str):
        self.is_saw = (any(s in geo_lower_original for s in ["t-slot", "woodruff", "keyseat"])
                       or any(s in r.tool.lower() for s in ["woodruff", "saw"])
                       or (r.profile is not None and r.profile.slot is not None))
        self.is_hole_tool = is_drilling_tool_type(r.tool, r.geometry)
        self.is_tapping = (
            is_tap_tool_type(r.tool) or is_tap_tool_type(r.operation)
            or (self.is_hole_tool and any(t in geo_lower_original
                                          for t in ["form", "spiral_flute", "spiral_point", "straight_flute"]))
        )


def _hardness_reason(physics, family: str, alloy: str) -> str:
    if not alloy:
        return "no alloy specified; no hardness scaling"
    hb = None
    try:
        hb = physics.resolve_alloy_hardness(family, alloy)
    except Exception:
        hb = None
    if not hb:
        return f"alloy {alloy!r} hardness unresolved; no scaling"
    txt = f"alloy {alloy!r} hardness scaling ({float(hb):.0f} HB)"
    try:
        hrc = ASTMHardnessConverter.brinell_to_hrc(float(hb))
        if hrc is not None and hrc > HARD_MILL_ONSET_HRC:
            txt += f"; includes hard-milling correction at {hrc:.0f} HRC"
    except Exception:
        pass
    return txt


FULL_SLOT_IMMERSION = 0.9      # radial engagement (fraction of D) treated as a full slot
FULL_SLOT_SFM_FACTOR = 0.80
# Form tools: their "cut width" is a radial depth, not immersion, so the slot rule doesn't apply.
FORM_TOOL_GEOMETRIES = ("chamfer", "v-bit", "engrav", "dovetail", "thread", "lollipop", "t-slot",
                        "keyseat", "woodruff", "drill", "ream", "tap")


def _speed_chain(physics, r: CutRequest, ctx: _Ctx, cut_depth: float, cut_width: float,
                 prov: Optional[_Prov] = None):
    """Base lookup -> hardness -> chatter -> aggressiveness -> HEM -> coating.

    Returns (base_sfm, base_ipt_lookup, target_sfm, ipt).
    """
    p = prov if prov is not None else _Prov()

    sfm = physics.get_base_sfm(
        r.family, r.tool, geometry=r.geometry, diameter=r.diameter,
        tap_type=r.tap_type, is_carbide=r.is_carbide
    )
    ipt = physics.get_base_ipt(
        r.family, r.tool, r.diameter, geometry=r.geometry, runout=r.runout,
        cut_depth=cut_depth, cut_width=cut_width, flutes=r.flutes, is_carbide=r.is_carbide
    )
    base_sfm, base_ipt_lookup = sfm, ipt
    p.add("base_lookup", "sfm", sfm, sfm, f"database SFM for {r.family} / {r.tool}")
    p.add("base_lookup", "ipt", ipt, ipt, f"database chipload for {r.family} / {r.tool}")

    b_sfm, b_ipt = sfm, ipt
    sfm, ipt = physics.apply_alloy_hardness_scaling(r.family, r.alloy, sfm, ipt)
    reason = _hardness_reason(physics, r.family, r.alloy)
    p.add("hardness", "sfm", b_sfm, sfm, reason)
    p.add("hardness", "ipt", b_ipt, ipt, reason)

    b_sfm, b_ipt = sfm, ipt
    # Milling reach rules use the equivalent stickout (stiffness-based), so a stub tool on a big
    # shank is not treated as long; drills keep G-Wizard's length rule on the real stickout.
    reach = r.stickout if ctx.is_hole_tool else _reach_stickout(r)
    sfm, ipt = physics.apply_chatter_penalty(
        sfm, ipt, r.diameter, reach, is_drilling=ctx.is_hole_tool,
        is_saw_woodruff=ctx.is_saw, flute_length=r.flute_length
    )
    if ctx.is_saw:
        reason = "saw/woodruff: stickout penalty bypassed"
    elif sfm != b_sfm or ipt != b_ipt:
        reason = ((f"long reach (equivalent L/D = {reach / r.diameter:.1f}): surface speed reduced per OSG "
                   f"overhang guidance" if not ctx.is_hole_tool
                   else f"stickout/chatter penalty (L/D = {r.stickout / r.diameter:.1f})")
                  if r.diameter > 0 else "stickout penalty")
    else:
        reason = "stickout within limit; no penalty"
    p.add("chatter", "sfm", b_sfm, sfm, reason)
    p.add("chatter", "ipt", b_ipt, ipt, reason)

    if not ctx.is_tapping:
        b_sfm, b_ipt = sfm, ipt
        sfm, ipt = physics.apply_aggressiveness(sfm, ipt, r.aggressiveness)
        reason = f"aggressiveness {r.aggressiveness * 100:.0f}%"
        p.add("aggressiveness", "sfm", b_sfm, sfm, reason)
        p.add("aggressiveness", "ipt", b_ipt, ipt, reason)

        b_sfm = sfm
        hem = physics.calc_hem_thermal_sfm_multiplier(cut_width, r.diameter, operation=r.operation)
        sfm *= hem
        reason = (f"HEM thermal boost at {cut_width / r.diameter * 100:.0f}% radial immersion"
                  if hem != 1.0 and r.diameter > 0 else "no HEM low-immersion boost")
        p.add("hem_thermal", "sfm", b_sfm, sfm, reason)

        # Full-width slot: the edge never leaves the cut, so it runs hotter than in a profile cut.
        # Vendor slotting speeds (Harvey AlTiN in 4130: 150-280 / 180-320 SFM) sit about 20% below
        # the general coated rating. Saws/T-slots/keyseats report radial depth, not immersion.
        b_sfm = sfm
        immersion = cut_width / r.diameter if r.diameter > 0 else 0.0
        geo = str(r.geometry).lower()
        is_endmill_shape = not any(k in geo for k in FORM_TOOL_GEOMETRIES)
        if immersion >= FULL_SLOT_IMMERSION and is_endmill_shape and not ctx.is_saw and not ctx.is_hole_tool:
            sfm *= FULL_SLOT_SFM_FACTOR
            reason = f"full-width slot ({immersion * 100:.0f}% radial engagement)"
        else:
            reason = "not a full-width slot"
        p.add("slot_engagement", "sfm", b_sfm, sfm, reason)

        b_sfm = sfm
        if r.apply_coating:
            sfm *= physics.get_coating_multiplier(r.coating, r.family, tool_type=r.tool,
                                                  geometry=r.geometry, is_carbide=r.is_carbide)
            p.add("coating", "sfm", b_sfm, sfm, f"{r.coating} coating on {r.family}")
        else:
            p.add("coating", "sfm", b_sfm, sfm, "coating not applied (tool coating unknown)")
    else:
        for step in ("aggressiveness", "hem_thermal", "slot_engagement", "coating"):
            p.add(step, "sfm", sfm, sfm, "skipped for taps")
        p.add("aggressiveness", "ipt", ipt, ipt, "skipped for taps")

    return base_sfm, base_ipt_lookup, sfm, ipt


def _reach_stickout(r: CutRequest) -> float:
    """Equivalent stickout for the long-reach rules (see BeamDeflectionEngine.equivalent_stickout)."""
    if r.profile is not None and r.profile.segments:
        eq = BeamDeflectionEngine.equivalent_stickout(r.profile.segments, r.diameter, r.flutes, r.helix_angle)
        if eq is not None:
            return eq
    return r.stickout or 0.0


RUNOUT_CHIP_RATIO = 0.5


_ROUGHING_WORDS = ("rough", "adaptive", "clearing", "pocket", "trochoidal", "hem", "slot")


def _chipload_floor(physics, r: CutRequest, ctx, base_ipt: float) -> float:
    """Lowest chip-load factor the long-reach rule may use for this cut (1.0 = no reduction):
    OSG overhang band for L/D, raised for work-hardening alloys and kept >= 2x the edge's minimum
    chip thickness. Roughing/adaptive/slotting end mills only."""
    op = str(r.operation).lower()
    geo = str(r.geometry).lower()
    if (ctx.is_hole_tool or ctx.is_tapping or ctx.is_saw or "finish" in op
            or not any(w in op for w in _ROUGHING_WORDS)
            or any(k in geo for k in FORM_TOOL_GEOMETRIES) or "high feed" in op or geo == "high feed"):
        return 1.0
    floor = reach_chipload_floor(_reach_stickout(r), r.diameter)
    if floor >= 1.0:
        return 1.0
    try:
        if alloy_work_hardens(r.family, r.alloy, physics.machinability.get(r.family)):
            floor = max(floor, WORK_HARDENING_CHIPLOAD_FLOOR)
    except Exception:
        floor = max(floor, WORK_HARDENING_CHIPLOAD_FLOOR)
    if base_ipt > 0:
        mct = physics.get_minimum_chip_thickness(r.coating, r.tool, r.diameter)
        floor = max(floor, min(1.0, 2.0 * mct / base_ipt))
    return floor


def _recommend(physics, r: CutRequest, rpm: float, base_ipt: float, details: Dict[str, Any],
               min_chipload_factor: float = 1.0):
    return physics.recommend_cut_parameters(
        r.diameter, r.shank_diameter, r.stickout, r.flutes, rpm, base_ipt, r.is_carbide,
        r.operation, r.aggressiveness, r.geometry, r.cutter_thickness, r.max_hp,
        material_family=r.family, helix_angle=r.helix_angle, neck_length=r.neck_length,
        taper_angle=r.taper_angle, flute_length=r.flute_length, neck_diameter=r.neck_diameter,
        corner_radius=r.corner_radius, details=details, profile=r.profile,
        min_chipload_factor=min_chipload_factor
    )


def run_cut(physics, req: CutRequest) -> CutResult:
    """Run the canonical speeds-and-feeds pipeline for one cut and record provenance."""
    geo_lower_original = str(req.geometry or "Square").lower()
    r = _normalize(req)
    ctx = _Ctx(r, geo_lower_original)

    diameter, flutes = r.diameter, r.flutes
    cut_depth, cut_width = r.cut_depth, r.cut_width
    rec_doc = rec_woc = rec_limit = None
    rec_details: Dict[str, Any] = {}

    if cut_depth is None or cut_width is None:
        # Recommendation pre-pass: provisional engagement, plain-diameter RPM, then recommend.
        prov_depth = cut_depth if cut_depth is not None else r.cutter_thickness
        prov_width = cut_width if cut_width is not None else diameter * 0.25
        _, _, pre_sfm, pre_ipt = _speed_chain(physics, r, ctx, prov_depth, prov_width)
        pre_rpm = physics.calc_rpm(pre_sfm, diameter, max_rpm=r.max_rpm)
        rec_doc, rec_woc, rec_limit = _recommend(physics, r, pre_rpm, pre_ipt, rec_details,
                                                 _chipload_floor(physics, r, ctx, pre_ipt))
        if cut_depth is None:
            cut_depth = rec_doc
        if cut_width is None:
            cut_width = rec_woc

    prov = _Prov()
    base_sfm, base_ipt_lookup, target_sfm, base_ipt = _speed_chain(physics, r, ctx, cut_depth, cut_width, prov)

    effective_diameter = physics.calc_effective_diameter(diameter, cut_depth, r.geometry, r.corner_radius)
    # Chamfer/V-bit/engraving: vendors (Harvey chamfer cutters) size RPM on the major diameter;
    # the smaller contact diameter only feeds chip thinning. Ball/bull nose use the contact diameter.
    is_pointed = any(k in str(r.geometry).lower() for k in ("chamfer", "v-bit", "engrav"))
    rpm_diameter = diameter if is_pointed else effective_diameter
    ideal_rpm = (target_sfm * 12.0) / (math.pi * rpm_diameter) if rpm_diameter > 0 else 0.0
    max_rpm = r.max_rpm
    is_spindle_limited = bool(max_rpm > 0 and ideal_rpm > (max_rpm * 1.005))
    rpm = physics.calc_rpm(target_sfm, rpm_diameter, max_rpm=max_rpm)
    cap_sfm = physics.calc_sfm(rpm, rpm_diameter)
    prov.add("spindle_cap", "sfm", target_sfm, cap_sfm if ideal_rpm > 0 else target_sfm,
             (f"spindle capped at {max_rpm:,.0f} RPM (ideal {ideal_rpm:,.0f})" if is_spindle_limited
              else "spindle speed not limiting"))

    operation = r.operation
    if ctx.is_hole_tool:
        cut_width = diameter
        if any(m in operation.lower() for m in ["rough", "adaptive", "trochoidal", "slot", "face", "finish"]):
            if is_tap_tool_type(r.tool):
                operation = "Rigid Tapping"
            elif "ream" in r.tool.lower():
                operation = "Precision Reaming"
            else:
                operation = "Drilling"

    tap_drill_info = None
    pitch = r.pitch
    if (is_tap_tool_type(r.tool) or is_tap_tool_type(operation)) and pitch is not None and pitch > 0:
        feedrate = round(rpm) * pitch
        adjusted_ipt = pitch
        tap_drill_info = physics.calc_tap_drill(
            major_dia=diameter, pitch=pitch, tap_type=r.tap_type,
            material_family=r.family, is_metric=r.is_metric
        )
        prov.add("reach_chipload", "ipt", base_ipt, base_ipt, "not applied to taps")
        prov.add("chip_thinning", "ipt", base_ipt, adjusted_ipt, f"tap feed = thread lead ({pitch:g} in/rev)")
    else:
        def _feed_for(scale):
            a_ipt = physics.calc_adjusted_chipload(
                base_ipt * scale, cut_depth, cut_width, diameter, effective_diameter, operation=operation,
                geometry=r.geometry, tool_type=r.tool, corner_radius=r.corner_radius
            )
            return a_ipt, physics.calc_feedrate(rpm, flutes, a_ipt)

        # Long reach: if this cut deflects past the limit at the full chip load, lighten the chip
        # (down to the OSG overhang band floor) before anything else.
        chip_factor, reason = 1.0, "no long-reach chip load reduction"
        floor = 1.0 if ctx.is_hole_tool else _chipload_floor(physics, r, ctx, base_ipt)
        if floor < 1.0:
            limit = physics.calc_deflection_limit(diameter, operation, r.aggressiveness, r.is_carbide)

            def _defl(feed_s):
                return physics.tool_deflection(
                    diameter, r.shank_diameter, r.stickout, cut_depth, cut_width, feed_s, rpm, flutes,
                    r.is_carbide, material_family=r.family, helix_angle=r.helix_angle,
                    neck_length=r.neck_length, taper_angle=r.taper_angle, flute_length=r.flute_length,
                    neck_diameter=r.neck_diameter, operation=operation, geometry=r.geometry,
                    corner_radius=r.corner_radius, profile=r.profile)

            if _defl(_feed_for(1.0)[1]) > limit * 1.001:
                f = 0.95
                while f >= floor - 1e-9:
                    chip_factor = round(f, 2)
                    if _defl(_feed_for(chip_factor)[1]) <= limit * 1.001:
                        break
                    f -= 0.05
                ld = (r.stickout or 0.0) / diameter if diameter > 0 else 0.0
                reason = (f"long reach (L/D {ld:.1f}): chip load {chip_factor:.0%} so the stepdown "
                          f"stays within the deflection limit (OSG overhang floor {floor:.0%})")
        prov.add("reach_chipload", "ipt", base_ipt, base_ipt * chip_factor, reason)
        adjusted_ipt, feedrate = _feed_for(chip_factor)
        prov.add("chip_thinning", "ipt", base_ipt * chip_factor, adjusted_ipt,
                 "chip thinning / engagement adjustment (adjusted chipload / base)")

    mrr = physics.calc_mrr(cut_depth, cut_width, feedrate, geometry=r.geometry, diameter=diameter)
    actual_sfm = physics.calc_sfm(rpm, diameter)
    contact_sfm = physics.calc_sfm(rpm, effective_diameter)

    # Ramping and plunging are full-width cuts: derive their feeds from the un-thinned chip load
    # (never above the slotting feed for this tool), not from the chip-thinned cutting feed.
    ramp_basis_feed = feedrate
    if not (ctx.is_hole_tool or ctx.is_tapping or is_tap_tool_type(operation)):
        ramp_basis_feed = physics.ramp_basis_feed(
            rpm, flutes, base_ipt * chip_factor, cut_depth, diameter, effective_diameter, r.geometry,
            r.corner_radius, r.tool, feedrate)
    ramp_angle, ramp_feed, plunge_feed = physics.calc_ramping(
        r.family, diameter, ramp_basis_feed, r.geometry, flutes, r.aggressiveness, tool_type=r.tool
    )

    op_lower = str(operation).lower()
    is_roughing_op = any(x in op_lower for x in ["rough", "adaptive", "clearing", "pocket", "trochoidal", "hem", "slot"])
    is_floor_finish = any(s in op_lower for s in ["floor", "facing", "flat", "horizontal", "face"]) and not is_roughing_op
    is_finishing = ("finish" in op_lower or is_floor_finish
                    or (cut_width <= (diameter * 0.15) and not is_roughing_op)) and not is_roughing_op

    if ctx.is_hole_tool:
        deflection = springback = total_error = wear_comp = 0.0
    else:
        deflection = physics.tool_deflection(
            diameter, r.shank_diameter, r.stickout, cut_depth, cut_width, feedrate, rpm, flutes, r.is_carbide,
            material_family=r.family, helix_angle=r.helix_angle, neck_length=r.neck_length,
            taper_angle=r.taper_angle, flute_length=r.flute_length, neck_diameter=r.neck_diameter,
            operation=operation, geometry=r.geometry, corner_radius=r.corner_radius,
            profile=r.profile
        )
        springback, total_error, wear_comp = physics.calc_springback_and_deflection(
            r.family, diameter, cut_depth, cut_width, feedrate, rpm, flutes, deflection, alloy=r.alloy
        )

    tips = physics.generate_advanced_strategies(
        r.family, diameter, cut_depth, cut_width, feedrate, rpm, flutes, r.coating, deflection,
        tool_type=r.tool, stickout=r.stickout, geometry=r.geometry, flute_length=r.flute_length,
        operation=operation, tap_type=r.tap_type, neck_diameter=r.neck_diameter, alloy=r.alloy,
        corner_radius=r.corner_radius
    )

    # Runout vs chip load: once the holder's TIR reaches about half the chip per tooth, one flute
    # takes most of the cut (the others rub), which breaks small tools.
    if (not ctx.is_hole_tool and not ctx.is_tapping and r.runout and r.runout > 0
            and adjusted_ipt > 0 and r.runout >= RUNOUT_CHIP_RATIO * adjusted_ipt):
        if r.is_metric:
            ro_txt, ch_txt = f"{r.runout * 25.4 * 1000:.1f} um", f"{adjusted_ipt * 25.4 * 1000:.1f} um"
        else:
            ro_txt, ch_txt = f"{r.runout:.5f}\"", f"{adjusted_ipt:.5f}\""
        tips.insert(0, {
            "title": "Runout vs Chip Load",
            "message": (f"Holder runout ({ro_txt}) is {r.runout / adjusted_ipt:.0%} of the chip load per tooth "
                        f"({ch_txt}), so one flute does most of the cutting and the others rub. Check the "
                        f"runout at the tool tip; a shrink-fit, hydraulic or precision collet chuck "
                        f"(< 0.0001\" / 2.5 um TIR) protects small tools. Set your holder's runout in "
                        f"Machine & Cut Parameters."),
            "type": "warning", "fusion": True,
        })

    if r.profile is not None and SHANK_WARNING in (r.profile.warnings or []):
        tips.insert(0, {"title": "Check Shank Diameter", "message": SHANK_WARNING, "type": "warning"})

    if is_spindle_limited:
        feed_val = feedrate if not r.is_metric else feedrate * 25.4
        feed_unit = "IPM" if not r.is_metric else "mm/min"
        tips.append({
            "title": "Spindle RPM Limited",
            "message": (
                f"Your machine's spindle speed cap ({max_rpm:,.0f} RPM) limits surface speed to {actual_sfm:.1f} SFM "
                f"(ideal: {target_sfm:.0f} SFM at {ideal_rpm:,.0f} RPM). Tool Wizard has synchronized your feedrate "
                f"to {feed_val:.1f} {feed_unit} to maintain optimal chipload ({adjusted_ipt:.5f}\" IPT) and prevent tool rubbing."
            ),
            "type": "info"
        })

    if rec_doc is None:
        rec_details = {}
        rec_doc, rec_woc, rec_limit = _recommend(physics, r, rpm, base_ipt, rec_details,
                                                 _chipload_floor(physics, r, ctx, base_ipt))
    feasible = bool(rec_details.get("feasible", True))
    limited_by = rec_details.get("limited_by")
    if not feasible:
        tips.insert(0, {
            "title": "Infeasible Setup",
            "message": (
                f"No safe cut was found for this tool/material/stickout (limited by: {limited_by or 'unknown'}). "
                "The numbers shown are a minimum-engagement fallback and should NOT be run as-is. "
                "Reduce stickout, use a larger or shorter tool, or lower aggressiveness."
            ),
            "type": "critical"
        })

    ipr = (feedrate / rpm) if rpm > 0.0 else (adjusted_ipt * flutes)

    result = CutResult(
        rpm=rpm, diameter=diameter, sfm=actual_sfm, contact_sfm=contact_sfm, ideal_rpm=ideal_rpm,
        is_spindle_limited=is_spindle_limited, effective_diameter=effective_diameter,
        base_ipt=base_ipt, adj_ipt=adjusted_ipt, feed_ipm=feedrate,
        doc=cut_depth, woc=cut_width, rec_doc=rec_doc, rec_woc=rec_woc, rec_limit=rec_limit,
        feasible=feasible, limited_by=limited_by,
        ramp_angle=ramp_angle, ramp_feed=ramp_feed, plunge_feed=plunge_feed, mrr=mrr,
        deflection=deflection, springback=springback, total_error=total_error, wear_comp=wear_comp,
        tips=tips, provenance=prov.steps,
        base_sfm=base_sfm, base_ipt_lookup=base_ipt_lookup, target_sfm=target_sfm, ipr=ipr,
        is_floor_finish=is_floor_finish, is_finishing=is_finishing,
        is_hole_tool=ctx.is_hole_tool, is_tapping=ctx.is_tapping,
        operation=operation, geometry=r.geometry, tool=r.tool, coating=r.coating,
        tap_type=r.tap_type, tap_drill=tap_drill_info, flute_length=r.flute_length,
        shank_diameter=r.shank_diameter, neck_diameter=r.neck_diameter,
        profile=r.profile.to_dict() if r.profile is not None else None,
        runout_in=r.runout, runout_source=r.runout_source,
        engagement_source=("user" if (r.engagement_explicit if r.engagement_explicit is not None
                                      else (r.cut_depth is not None or r.cut_width is not None)) else "recommended"),
    )
    if ctx.is_saw:
        import tslot_model
        tslot_model.apply_to_result(result, tslot_model.run_for_request(physics, r), r)
    if req.model == "v2":
        import v2_bridge
        result = v2_bridge.apply(physics, r, result, machine_profile=req.machine_profile)
    if result.is_finishing and not (ctx.is_hole_tool or ctx.is_tapping or ctx.is_saw) and result.feed_ipm > 0:
        import finish_modes
        finish_modes.apply(physics, r, result)
    if r.feature_geometry:
        _apply_feature_geometry(r, result)
    import advice_wiring
    advice_wiring.fill_advice(result, r)
    return result


def _apply_feature_geometry(r: CutRequest, res: CutResult) -> None:
    """Incorporate live B-Rep feature geometry (corner radius, feature depth, thin wall/floor)
    into the CutResult's warnings, corner feed, and compliance-adjusted deflection."""
    fg = dict(r.feature_geometry or {})
    dia = res.diameter or r.diameter
    woc = res.woc or res.rec_woc or (dia * 0.15)
    stick = r.stickout or 0.0
    existing_titles = {t.get("title") for t in res.tips if isinstance(t, dict)}

    # 1. Feature Z-depth vs stickout
    f_depth = fg.get("feature_depth_in")
    if f_depth is not None and float(f_depth) > 0:
        f_depth = float(f_depth)
        req_reach = float(fg.get("required_reach_in") or (f_depth + 0.100))
        fg["required_reach_in"] = round(req_reach, 5)
        if stick > 0 and req_reach > stick + 1e-4:
            fg["stickout_collision"] = True
            res.feasible = False
            res.limited_by = "holder_clearance"
            if "Holder Clearance / Stickout Too Short" not in existing_titles:
                res.tips.insert(0, {
                    "title": "Holder Clearance / Stickout Too Short",
                    "message": (
                        f"Feature depth is {f_depth:.3f}\" (requires >= {req_reach:.3f}\" stickout with "
                        f"clearance), but tool stickout is only {stick:.3f}\". Holder collision risk!"
                    ),
                    "type": "critical",
                    "fusion": True,
                })
        elif stick - req_reach >= 0.25:
            excess = stick - req_reach
            gain_pct = (1.0 - (1.0 / max((stick / max(req_reach, 0.05)) ** 3, 1.0))) * 100.0
            fg["excess_stickout_in"] = round(excess, 5)
            fg["choke_up_stiffness_gain_pct"] = round(gain_pct, 1)
            if "Excessive Stickout vs Feature Depth" not in existing_titles:
                res.tips.append({
                    "title": "Excessive Stickout vs Feature Depth",
                    "message": (
                        f"Feature depth only requires {req_reach:.3f}\" stickout, but tool is set to "
                        f"{stick:.3f}\". Choking up by {excess:.3f}\" reduces tool deflection by {gain_pct:.0f}%."
                    ),
                    "type": "info",
                    "fusion": True,
                })

    # 2. Minimum internal corner radius engagement spike
    min_cr = fg.get("min_corner_radius_in")
    if min_cr is not None and float(min_cr) > 0 and dia > 0:
        min_cr = float(min_cr)
        eff_woc, feed_scale, overloaded = calc_corner_engagement(dia, min_cr, woc)
        fg["corner_woc_spike_in"] = round(eff_woc, 5)
        fg["corner_feed_scale"] = round(feed_scale, 3)
        fg["corner_overload"] = bool(overloaded)
        fg["corner_ratio"] = round((dia * 0.5) / min_cr, 3)
        res.corner_feed_ipm = round(res.feed_ipm * feed_scale, 2)
        fg["corner_feed_ipm"] = res.corner_feed_ipm
        if overloaded and "Tight Internal Corner Engagement Spike" not in existing_titles:
            r_tool = dia * 0.5
            res.tips.insert(0, {
                "title": "Tight Internal Corner Engagement Spike",
                "message": (
                    f"Internal corner radius ({min_cr:.4f}\") is tight relative to cutter radius "
                    f"({r_tool:.4f}\"). Radial engagement spikes to {eff_woc:.4f}\" in the corner; "
                    f"reduce corner feedrate to {res.corner_feed_ipm:.1f} IPM ({feed_scale * 100:.0f}%) "
                    f"via Fusion Feed Optimization."
                ),
                "type": "warning",
                "fusion": True,
            })

    # 3. Thin-wall & thin-floor compliance
    wt = fg.get("min_wall_thickness_in")
    ft = fg.get("min_floor_thickness_in")
    wh = fg.get("wall_height_in")
    wt_f = float(wt) if (wt is not None and float(wt) > 0) else None
    ft_f = float(ft) if (ft is not None and float(ft) > 0) else None
    wh_f = float(wh) if (wh is not None and float(wh) > 0) else None
    check_floor = not is_wall_only_operation(r.operation)
    if not check_floor:
        ft_f = None
        fg["min_floor_thickness_in"] = None
    is_tw, is_tf, comp_factor = calc_thin_wall_compliance_factor(
        wt_f, wh_f, ft_f, tool_diameter_in=dia, check_floor=check_floor
    )
    fg["is_thin_wall"] = bool(is_tw)
    fg["is_thin_floor"] = bool(is_tf)
    fg["workpiece_compliance_factor"] = round(comp_factor, 3)
    if comp_factor > 1.0:
        res.springback *= comp_factor
        res.total_error = res.deflection + res.springback
        res.wear_comp = -res.total_error
    if is_tw and wt_f is not None and "Thin-Wall Workpiece Compliance Detected" not in existing_titles:
        res.tips.insert(0, {
            "title": "Thin-Wall Workpiece Compliance Detected",
            "message": (
                f"B-Rep inspection detected a thin wall ({wt_f:.4f}\" thickness). Workpiece elastic push-off "
                f"increases total wall error by ~{(comp_factor - 1.0) * 100:.0f}%. Use light radial passes "
                f"and a spring pass."
            ),
            "type": "warning",
            "fusion": True,
        })
    if is_tf and ft_f is not None and "Thin-Floor Workpiece Compliance Detected" not in existing_titles:
        res.tips.insert(0, {
            "title": "Thin-Floor Workpiece Compliance Detected",
            "message": (
                f"B-Rep inspection detected a thin pocket floor ({ft_f:.4f}\" thickness). Axial tool thrust "
                f"will deflect the floor downward and leave it proud on springback."
            ),
            "type": "warning",
            "fusion": True,
        })

    # Also merge any pre-populated warnings from inspect_operation_geometry without duplicating titles
    existing_titles = {t.get("title") for t in res.tips if isinstance(t, dict)}
    for w in fg.get("warnings") or []:
        if isinstance(w, dict) and w.get("title") not in existing_titles:
            res.tips.insert(0, w)
            existing_titles.add(w.get("title"))

    res.feature_geometry = fg


def provenance_product(result: CutResult, quantity: str, exclude=("spindle_cap",)) -> float:
    """Product of the recorded multipliers for ``quantity`` (spindle cap excluded by default)."""
    prod = 1.0
    for s in result.provenance:
        if s["quantity"] == quantity and s["step"] not in exclude:
            prod *= s["multiplier"]
    return prod
