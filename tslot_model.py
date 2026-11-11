"""Physics-based speeds and feeds for T-slot, keyseat and woodruff cutters (a side-cutting head on a neck).

All lengths are inches, feeds are IPM (inches per minute), chip loads are inches per tooth, speeds are
SFM (surface feet per minute) and RPM, forces are lbf, stresses are ksi, power is hp.

The v2 model does not cover these cutters (see ``v2_bridge.NOT_SQUARE``); this module is used for them
whichever cutting model is selected.

Model in one paragraph
----------------------
Speed is the existing carbide-endmill SFM for the material (``GWizardPhysics.get_base_sfm`` with the
saw/keyseat 0.75 reduction) times a per-family fit factor, times a hardness curve, times the
aggressiveness scalar. Chip load per tooth is a per-family chip load per inch of cutter diameter, times
hardness / flute-count / coating / aggressiveness factors, times the radial chip-thinning ratio between the
actual radial depth and the reference radial depth the fit was made at. Radial depth per pass is a fraction
of the cutter diameter (chip packing in a deep narrow slot), reduced for wide cutters, then limited by neck
clearance and by neck bending deflection (stepped beam head / neck / shank loaded at the head). Both-side
engagement multiplies the chip load by 0.55 (vendor: "reduce chiploads to 50-60% of posted values").
Axial (Z) face cutting uses the face chip load = posted chip load x 0.55, times the teeth that cut on that
face (``teeth_per_face``).

Calibration data (fit, not looked up): the Harvey Tool keyseat / undercut speeds-and-feeds sheets and the
Ingersoll NEW-379 T-slot guidelines in ``tests/benchmarks/tslot/`` (see ``tests/test_tslot_conformance.py``).
The fit constants are in ``_FAMILY`` below; each is the median over the sheet rows of its family.
"""
from __future__ import annotations

import json
import math
import os
from typing import Any, Dict, List, Optional

from gwizard_physics import BeamDeflectionEngine, CuttingMechanics

OPERATIONS = ("full_slot", "side_cut", "both_sides", "axial_step")
TOOTH_FORMS = ("straight", "staggered", None)
FACES = ("periphery", "top", "bottom")

BOTH_SIDES_FACTOR = 0.55           # Harvey: "engaged on both sides: reduce chiploads to 50-60% of posted values"
COATING_MAX_BONUS = 0.15           # Harvey: "may be increased up to 15% if coated"
FERROUS_SOFT_BONUS = 0.15          # Harvey: "ferrous materials with hardness <= 28 Rc: chip loads +10-20%"
SIDE_CUT_FACTOR = 1.40             # Ingersoll NEW-379: side-cut vs full-slot feed/tooth, midpoints 3.5 / 2.5 thou
AXIAL_STEP_FRACTION = 0.8          # axial step per cut as a fraction of the kerf (cut overlap)
TRS_KSI = 500.0                    # transverse rupture strength of fine-grain carbide (~3.4 GPa)
FATIGUE_FRACTION = 0.375           # allowable bending stress = 0.375 x TRS (same fatigue rule as physics_v2 C4)
HOLDER_CLEARANCE_IN = 0.10         # shank stickout beyond the end of the neck (assumed)
CONSENSUS_SCALE_POINTS = ((0.0, 0.76), (0.5, 0.92), (0.75, 1.00), (1.0, 1.10))   # same anchors as physics_v2.optimize

PROVISIONAL_WARNING = "provisional geometry: measure neck diameter, reach and tooth form"

# Per material family: kind, default hardness (HRC) when none is given, SFM fit factor against the
# database carbide-endmill value (after the 0.75 saw reduction), chip load per inch of diameter at the
# reference hardness and the reference radial depth as a fraction of diameter.
_FAMILY: Dict[str, Dict[str, Any]] = {
    "Aluminum - Wrought (6061)":     dict(kind="nonferrous", hrc=None, sfm_fit=1.00, k_fz=0.00604, ae=0.12),
    "Aluminum - Cast":               dict(kind="nonferrous", hrc=None, sfm_fit=0.96, k_fz=0.00544, ae=0.12),
    "Brass":                         dict(kind="nonferrous", hrc=None, sfm_fit=0.83, k_fz=0.00484, ae=0.12),
    "Steel - Low Carbon (1020)":     dict(kind="steel", hrc=20.0, sfm_fit=2.29, k_fz=0.0022, ae=0.08),
    "Steel - Medium Carbon (1045)":  dict(kind="steel", hrc=20.0, sfm_fit=1.06, k_fz=0.0020, ae=0.08),
    "Steel - Tool (H13)":            dict(kind="steel", hrc=20.0, sfm_fit=1.00, k_fz=0.00128, ae=0.08),
    "Stainless - 300 Series (316)":  dict(kind="stainless", hrc=20.0, sfm_fit=1.06, k_fz=0.0020, ae=0.08),
    "Stainless - PH Series (17-4)":  dict(kind="stainless", hrc=33.0, sfm_fit=0.67, k_fz=0.00128, ae=0.08),
    "Titanium Alloy":                dict(kind="titanium", hrc=36.0, sfm_fit=1.15, k_fz=0.00128, ae=0.08),
    "High Temp Nickel Alloy":        dict(kind="nickel", hrc=33.0, sfm_fit=1.55, k_fz=0.00128, ae=0.08),
}
_FALLBACK = dict(kind="steel", hrc=20.0, sfm_fit=1.0, k_fz=0.0015, ae=0.08)

KNOWN_COATINGS = ("tin", "ticn", "tialn", "altin", "titanium", "alcrn", "zrn", "nano", "c6", "black", "diamond")


# --------------------------------------------------------------------------------------------------
# small helpers
# --------------------------------------------------------------------------------------------------

def _interp(points, x: float) -> float:
    """Piecewise-linear interpolation through ((x, y), ...) sorted by x, clamped at the ends."""
    if x <= points[0][0]:
        return points[0][1]
    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        if x <= x1:
            return y0 + (y1 - y0) * (x - x0) / (x1 - x0)
    return points[-1][1]


def aggressiveness_scale(aggressiveness: float) -> float:
    """Chip-load multiplier for aggressiveness 0..1: 0.92 at 50 %, 1.00 at 75 %, 1.10 at 100 %."""
    return _interp(CONSENSUS_SCALE_POINTS, max(0.0, min(1.0, aggressiveness)))


def hardness_hrc(hardness: Any, default: Optional[float]) -> Optional[float]:
    """HRC from a number, a {"min","max"} dict (midpoint, or the one end given) or None -> default."""
    if hardness is None:
        return default
    if isinstance(hardness, (int, float)):
        return float(hardness)
    if isinstance(hardness, dict):
        lo, hi = hardness.get("min"), hardness.get("max")
        vals = [float(v) for v in (lo, hi) if v is not None]
        if vals:
            return sum(vals) / len(vals)
    return default


def sfm_hardness_factor(hrc: Optional[float], kind: str) -> float:
    """SFM multiplier against the 33 HRC reference: falls to ~0.33 for very hard material and rises to 2.2
    for annealed ferrous/stainless material below 33 HRC."""
    if hrc is None or kind == "nonferrous":
        return 1.0
    if hrc >= 33.0:
        return 0.33 + 0.67 * math.exp(-(hrc - 33.0) / 10.0)
    return min(2.2, math.exp((33.0 - hrc) / 12.0))


def fz_hardness_factor(hrc: Optional[float], kind: str) -> float:
    """Chip-load multiplier against the 33 HRC reference: -1.2 %/HRC above 33 (floor 0.7); +15 % for
    ferrous material at or below 28 HRC (Harvey note)."""
    if hrc is None or kind == "nonferrous":
        return 1.0
    if hrc > 33.0:
        return max(0.7, 1.0 - 0.012 * (hrc - 33.0))
    if hrc <= 28.0 and kind in ("steel", "stainless"):
        return 1.0 + FERROUS_SOFT_BONUS
    return 1.0


def radial_hardness_factor(hrc: Optional[float], kind: str) -> float:
    """Radial depth-per-pass multiplier against the <= 37 HRC reference (hard material: shallower)."""
    if hrc is None or kind == "nonferrous" or hrc <= 37.0:
        return 1.0
    return 1.0 - 0.45 * (1.0 - math.exp(-(hrc - 37.0) / 9.0))


def width_radial_factor(kerf: float, diameter: float) -> float:
    """Radial step-over multiplier for wide cutters: 0.8 for width > 0.5 x D, 0.6 for width > 0.6 x D
    (Harvey sheets)."""
    r = kerf / diameter if diameter > 0 else 0.0
    if r > 0.6:
        return 0.6
    if r > 0.5:
        return 0.8
    return 1.0


def chip_thinning(x: float) -> float:
    """Radial chip-thinning factor 1 / (2 sqrt(x (1 - x))) for radial immersion x = ae / D, clamped to
    [1, 2.5] (the factor is 1 at and above 50 % immersion)."""
    x = max(1e-4, min(1.0, x))
    if x >= 0.5:
        return 1.0
    return min(2.5, 1.0 / (2.0 * math.sqrt(x * (1.0 - x))))


def is_coated(coating: Optional[str]) -> bool:
    s = str(coating or "").lower()
    if not s or "uncoated" in s or s in ("none", "bright"):
        return False
    return any(k in s for k in KNOWN_COATINGS)


def _warn(title: str, message: str, kind: str = "warning") -> Dict[str, str]:
    return {"title": title, "message": message, "type": kind}


# --------------------------------------------------------------------------------------------------
# beam model
# --------------------------------------------------------------------------------------------------

def neck_beam(force_lbf: float, kerf: float, neck_diameter: float, reach: float, shank_diameter: float,
              stickout_extra: float = HOLDER_CLEARANCE_IN) -> Dict[str, float]:
    """Bending of the stepped cantilever head / neck / shank under a lateral force applied at the middle of
    the head. Returns the deflection at the load point (in), the bending stress at the neck root (ksi) and at
    the shank at the holder (ksi). Virtual-work integral from ``BeamDeflectionEngine`` with x measured from
    the load point (carbide E = 90e6 psi); stress = 32 M / (pi d^3) with M = F x."""
    from toolwiz_common.tool_profile import Segment
    a = 0.5 * kerf
    neck_end = a + reach
    stick = neck_end + stickout_extra
    segs = [Segment("neck", a, neck_end, neck_diameter, neck_diameter, False),
            Segment("shank", neck_end, stick, shank_diameter, shank_diameter, False)]
    defl = BeamDeflectionEngine.deflection_from_segments(force_lbf, segs, 1, 0.0, True)
    s_neck = 32.0 * force_lbf * neck_end / (math.pi * neck_diameter ** 3) / 1000.0 if neck_diameter > 0 else 0.0
    s_shank = 32.0 * force_lbf * stick / (math.pi * shank_diameter ** 3) / 1000.0 if shank_diameter > 0 else 0.0
    return {"deflection_in": defl, "neck_stress_ksi": s_neck, "shank_stress_ksi": s_shank, "stickout_in": stick}


# --------------------------------------------------------------------------------------------------
# main entry point
# --------------------------------------------------------------------------------------------------

def compute_tslot(
    physics: Any,
    material_family: str,
    diameter: float,
    kerf: float,
    neck_diameter: float,
    reach: float,
    shank_diameter: Optional[float] = None,
    teeth: int = 4,
    tooth_form: Optional[str] = None,
    cutting_faces: Optional[List[str]] = None,
    teeth_per_face: Optional[int] = None,
    coating: str = "Uncoated",
    hardness: Any = None,
    aggressiveness: float = 0.5,
    runout: float = 0.0002,
    max_rpm: float = 16000.0,
    max_hp: float = 10.0,
    operation: str = "full_slot",
    slot_height: Optional[float] = None,
    radial_depth_total: Optional[float] = None,
    provisional: Optional[List[str]] = None,
    name: str = "",
) -> Dict[str, Any]:
    """Speeds, feeds, depths and checks for one T-slot / keyseat cut.

    Args (inches unless noted):
        diameter: cutter (head) diameter D. kerf: head thickness = slot width. neck_diameter, reach: neck
        below the head. shank_diameter: shank (None -> D). teeth: teeth on the head. tooth_form: "straight",
        "staggered" or None (unknown: treated as staggered, the conservative case). cutting_faces: subset of
        periphery/top/bottom (None -> all three for staggered/unknown, periphery only for straight).
        teeth_per_face: teeth cutting on one face (None -> teeth/2 for staggered/unknown, teeth for straight).
        hardness: HRC number or {"min","max"} (None -> family default). aggressiveness 0..1. runout: TIR (in).
        max_rpm / max_hp: machine limits. operation: full_slot | side_cut | both_sides | axial_step.
        slot_height: finished slot height along Z (for axial_step planning; None -> kerf).
        radial_depth_total: total radial depth wanted (None -> one pass at the recommended depth).
        provisional: names of geometry fields that are assumed, not measured.

    Returns a dict: rpm, sfm, chip_load_ipt (programmed, per tooth), peak_chip_thickness_in, feed_ipm
    (the feed to program for this operation), lateral_feed_ipm, axial_feed_ipm, face_chip_load_ipt,
    radial_depth_per_pass_in, radial_passes, radial_depth_total_in, neck_clearance_in, axial_plan,
    deflection_in, deflection_limit_in, neck_stress_ksi, stress_limit_ksi, power_hp, limited_by, basis,
    warnings (list of {title, message, type}) and echoes of the inputs used.
    """
    if operation not in OPERATIONS:
        raise ValueError(f"operation must be one of {OPERATIONS}")
    if diameter <= 0 or kerf <= 0:
        raise ValueError("diameter and kerf must be positive")
    fam = _FAMILY.get(material_family, _FALLBACK)
    shank = float(shank_diameter) if shank_diameter else diameter
    teeth = max(1, int(teeth or 1))
    warnings: List[Dict[str, str]] = []
    prov = list(provisional or [])
    if prov:
        warnings.append(_warn("Provisional geometry", f"{PROVISIONAL_WARNING} (assumed: {', '.join(prov)}).", "warning"))

    form = tooth_form if tooth_form in ("straight", "staggered") else None
    faces = list(cutting_faces) if cutting_faces else (["periphery"] if form == "straight"
                                                       else ["periphery", "top", "bottom"])
    both_faces = "top" in faces and "bottom" in faces
    tpf_default = teeth if form == "straight" else max(1, teeth // 2)
    tpf = int(teeth_per_face) if teeth_per_face else tpf_default
    if form is None:
        warnings.append(_warn("Tooth form unknown", "Tooth form not given: treated as staggered-tooth (half the "
                              "teeth cut on each face), which is the conservative case.", "info"))

    # ---- material, speed -------------------------------------------------------------------------
    hrc = hardness_hrc(hardness, fam["hrc"])
    base_sfm = physics.get_base_sfm(material_family, "Carbide Endmill", geometry="T-Slot", diameter=diameter,
                                    is_carbide=True)
    sfm_target = (base_sfm * fam["sfm_fit"] * sfm_hardness_factor(hrc, fam["kind"])
                  * (0.70 + 0.60 * max(0.0, min(1.0, aggressiveness))))
    ideal_rpm = sfm_target * 12.0 / (math.pi * diameter)
    rpm = min(ideal_rpm, max_rpm) if max_rpm and max_rpm > 0 else ideal_rpm
    sfm = rpm * math.pi * diameter / 12.0
    if rpm < ideal_rpm * 0.995:
        warnings.append(_warn("Spindle RPM limited", f"Speed is capped at {rpm:,.0f} RPM ({sfm:.0f} SFM, ideal "
                              f"{sfm_target:.0f} SFM); chip load is kept so the feed follows the lower RPM.", "info"))

    # ---- radial depth per pass --------------------------------------------------------------------
    clearance = max(0.0, (diameter - neck_diameter) / 2.0)
    x_ref = fam["ae"] * radial_hardness_factor(hrc, fam["kind"])
    ae_frac = x_ref * width_radial_factor(kerf, diameter) * aggressiveness_scale(aggressiveness) / 0.92
    ae_pass = ae_frac * diameter
    limited_by: List[str] = []
    if ae_pass > clearance > 0:
        ae_pass = clearance
        limited_by.append("neck_clearance")

    # ---- chip load --------------------------------------------------------------------------------
    teeth_factor = (6.0 / teeth) ** 0.87 if teeth > 6 else 1.0
    coat = is_coated(coating)
    coat_bonus = COATING_MAX_BONUS * min(1.0, aggressiveness / 0.75) if coat else 0.0
    fz_ref = (fam["k_fz"] * diameter * fz_hardness_factor(hrc, fam["kind"]) * teeth_factor * (1.0 + coat_bonus)
              * aggressiveness_scale(aggressiveness))
    # A spherical (undercut / lollipop) head, kerf >= 0.7 D, cuts along an arc whether slotting or profiling and
    # Harvey posts one base chip load for both; a disc-type head gains SIDE_CUT_FACTOR when only a side is cut.
    side_cut_gain = SIDE_CUT_FACTOR if kerf < 0.7 * diameter else 1.0
    side_factor = {"full_slot": 1.0, "side_cut": side_cut_gain, "both_sides": BOTH_SIDES_FACTOR,
                   "axial_step": 1.0}[operation]
    fz_post = fz_ref * side_factor          # per-tooth chip load at the reference radial depth

    # ---- cutting force, deflection, stress, power: reduce depth then chip load until within limits -
    unit_hp = 1.0
    try:
        unit_hp = float(physics.machinability.get(material_family, {}).get("unit_hp", 1.0) or 1.0)
    except Exception:
        pass
    defl_limit = CuttingMechanics.calc_deflection_limit(diameter, "Slotting", aggressiveness, True)
    stress_limit = FATIGUE_FRACTION * TRS_KSI

    def evaluate(ae: float, chip_scale: float) -> Dict[str, float]:
        fz = fz_post * chip_scale * min(1.6, max(0.5, chip_thinning(ae / diameter) / chip_thinning(x_ref)))
        feed = rpm * teeth * fz
        _, _, f_defl, hp = CuttingMechanics.calc_cutting_forces(diameter, kerf, ae, feed, rpm, teeth, unit_hp)
        beam = neck_beam(f_defl, kerf, neck_diameter, reach, shank)
        return {"fz": fz, "feed": feed, "force": f_defl, "hp": hp, **beam}

    ae_use, chip_scale = ae_pass, 1.0
    ev = evaluate(ae_use, chip_scale)
    ae_floor = 0.5 * ae_frac * diameter
    for _ in range(40):
        over_defl = ev["deflection_in"] > defl_limit
        over_stress = max(ev["neck_stress_ksi"], ev["shank_stress_ksi"]) > stress_limit
        over_hp = ev["hp"] > 0.8 * max_hp
        if not (over_defl or over_stress or over_hp):
            break
        if ae_use > ae_floor * 1.001 and not over_hp:
            ae_use = max(ae_floor, ae_use * 0.9)
            tag = "neck_deflection" if over_defl else "neck_stress"
        else:
            if chip_scale <= 0.4:
                tag = "neck_deflection" if over_defl else ("neck_stress" if over_stress else "spindle_power")
                limited_by.append(tag)
                break
            chip_scale *= 0.9
            tag = "spindle_power" if over_hp and not (over_defl or over_stress) else (
                "neck_deflection" if over_defl else "neck_stress")
        if tag not in limited_by:
            limited_by.append(tag)
        ev = evaluate(ae_use, chip_scale)
    still_over = ev["deflection_in"] > defl_limit * 1.001 or max(ev["neck_stress_ksi"], ev["shank_stress_ksi"]) > stress_limit
    if still_over:
        warnings.append(_warn(
            "Neck too slender for this cut",
            f"Even at half the radial depth and {chip_scale:.0%} chip load the neck bends {ev['deflection_in']:.5f}\" "
            f"(limit {defl_limit:.5f}\") at {max(ev['neck_stress_ksi'], ev['shank_stress_ksi']):.0f} ksi "
            f"(limit {stress_limit:.0f} ksi). Do not run this as is: shorten the reach, use a thicker neck, or take "
            f"a much lighter cut.", "critical"))
    if "neck_deflection" in limited_by or "neck_stress" in limited_by:
        warnings.append(_warn(
            "Slender neck limits the cut",
            f"Neck {neck_diameter:.3f}\" x {reach:.3f}\" reach bends {ev['deflection_in']:.5f}\" "
            f"(limit {defl_limit:.5f}\") at {ev['neck_stress_ksi']:.0f} ksi (limit {stress_limit:.0f} ksi); radial "
            f"depth per pass was cut to {ae_use:.4f}\" and the chip load scaled to {chip_scale:.0%}. A shorter "
            f"reach or a thicker neck allows more.", "warning"))
    if "spindle_power" in limited_by:
        warnings.append(_warn("Spindle power", f"Cut needs {ev['hp']:.2f} hp (limit {0.8 * max_hp:.1f} hp = 80% of "
                              f"machine): chip load reduced.", "warning"))

    fz = ev["fz"]
    feed_lateral = ev["feed"]

    # ---- passes and neck clearance ----------------------------------------------------------------
    total = float(radial_depth_total) if radial_depth_total else None
    passes = 1
    if total is not None:
        if clearance > 0 and total > clearance + 1e-9:
            warnings.append(_warn(
                "Neck clearance exceeded",
                f"Requested radial depth {total:.4f}\" is more than the neck clearance (D - neck)/2 = "
                f"{clearance:.4f}\": the neck would rub the slot wall. Use a smaller neck-to-head step, a "
                f"larger cutter, or a depth of at most {clearance:.4f}\".", "critical"))
            limited_by.append("neck_clearance")
        passes = max(1, math.ceil(total / ae_use - 1e-9))
        if passes > 1:
            warnings.append(_warn("Multiple radial passes", f"{total:.4f}\" radial depth in {passes} passes of "
                                  f"{total / passes:.4f}\" (chip packing in the narrow slot limits one pass to "
                                  f"{ae_use:.4f}\").", "info"))
    elif kerf < 0.1 * diameter:
        warnings.append(_warn("Chip packing", "Narrow kerf: take the radial depth in passes of at most "
                              f"{ae_use:.4f}\" and clear chips with air blast or coolant.", "info"))
    ae_per_pass = (total / passes) if total is not None else ae_use

    # ---- axial (Z) face cutting -------------------------------------------------------------------
    face_fz = fz_ref * BOTH_SIDES_FACTOR
    axial_feed = rpm * tpf * face_fz if both_faces else None
    height = float(slot_height) if slot_height else kerf
    plan: Dict[str, Any] = {"slot_height_in": height, "kerf_in": kerf}
    if height <= kerf * 1.001:
        plan.update(cuts=1, z_step_in=0.0, method="single radial entry at one Z level")
    elif both_faces:
        step = AXIAL_STEP_FRACTION * kerf
        cuts = math.ceil((height - kerf) / step - 1e-9) + 1
        plan.update(cuts=cuts, z_step_in=step, face_cuts=cuts - 1,
                    method=("radial cut at the first Z, then step Z by up to the z_step with the cutter faces "
                            "cutting, repeating; both faces cut so the cutter can move up or down"))
    else:
        cuts = math.ceil(height / kerf - 1e-9)
        plan.update(cuts=cuts, z_step_in=kerf, face_cuts=0,
                    method="enter radially at each Z level (straight-tooth cutter cannot cut with its faces)")
    if operation == "axial_step" and not both_faces:
        warnings.append(_warn(
            "Cannot step up into material",
            "This cutter has no cutting edges on its top and bottom faces (straight-tooth): it cannot cut while "
            "moving in Z. It must enter radially at each Z level; a staggered-tooth or double-sided cutter is "
            "needed for up and down cutting.", "warning"))
    if operation == "axial_step" and both_faces:
        warnings.append(_warn(
            "Face cutting direction",
            f"Z feed {axial_feed:.2f} IPM = {tpf} teeth per face x {face_fz:.5f}\" face chip load x "
            f"{rpm:,.0f} RPM. Use climb milling on the top and bottom faces where the setup allows; keep the "
            f"Z step within {plan['z_step_in']:.4f}\" ({AXIAL_STEP_FRACTION:.0%} of the kerf).", "info"))
    if operation == "both_sides":
        warnings.append(_warn("Both sides engaged", f"Chip load is {BOTH_SIDES_FACTOR:.0%} of the one-side value "
                              "because both faces of the cutter are cutting.", "info"))
    if kerf / diameter > 0.5:
        warnings.append(_warn("Wide cutter", "Cutter width is more than half the diameter: radial step-over "
                              f"is reduced to {width_radial_factor(kerf, diameter):.0%} of the posted value.", "info"))
    warnings.append(_warn("Chip evacuation", "T-slot cutters pack chips in the slot: use air blast or flood "
                          "coolant aimed into the slot, and do not re-cut chips.", "info"))
    if runout and fz > 0 and runout >= 0.5 * fz:
        warnings.append(_warn("Runout vs chip load", f"Runout {runout:.5f}\" is {runout / fz:.0%} of the chip load "
                              f"({fz:.5f}\"): one tooth will do most of the cutting. Use a precision holder.",
                              "warning"))
    if not neck_diameter or neck_diameter >= diameter:
        warnings.append(_warn("No neck relief", "Neck is not smaller than the head: this is a woodruff-style "
                              "cutter; the shank must stay clear of the slot.", "info"))

    feed_out = axial_feed if (operation == "axial_step" and axial_feed is not None) else feed_lateral
    power = ev["hp"]
    return {
        "model": "tslot",
        "name": name,
        "operation": operation,
        "material_family": material_family,
        "hardness_hrc": hrc,
        "rpm": rpm,
        "sfm": sfm,
        "target_sfm": sfm_target,
        "chip_load_ipt": fz,
        "peak_chip_thickness_in": fz / chip_thinning(ae_use / diameter),
        "feed_ipm": feed_out,
        "lateral_feed_ipm": feed_lateral,
        "axial_feed_ipm": axial_feed,
        "face_chip_load_ipt": face_fz,
        "teeth": teeth,
        "teeth_per_face": tpf,
        "tooth_form": form,
        "cutting_faces": faces,
        "radial_depth_per_pass_in": ae_per_pass,
        "radial_depth_limit_per_pass_in": ae_use,
        "radial_passes": passes,
        "radial_depth_total_in": total if total is not None else ae_use,
        "neck_clearance_in": clearance,
        "axial_plan": plan,
        "deflection_in": ev["deflection_in"],
        "deflection_limit_in": defl_limit,
        "neck_stress_ksi": ev["neck_stress_ksi"],
        "shank_stress_ksi": ev["shank_stress_ksi"],
        "stress_limit_ksi": stress_limit,
        "cutting_force_lbf": ev["force"],
        "power_hp": power,
        "mrr_in3_min": ae_per_pass * kerf * feed_lateral,
        "limited_by": limited_by[0] if limited_by else None,
        "limited_by_all": sorted(set(limited_by)),
        "provisional": prov,
        "geometry": {"diameter": diameter, "kerf": kerf, "neck_diameter": neck_diameter, "reach": reach,
                     "shank_diameter": shank, "stickout": ev["stickout_in"]},
        "basis": {
            "speed": "database carbide-endmill SFM x 0.75 saw reduction x family fit x hardness curve x aggressiveness",
            "chip_load": ("posted-style chip load per tooth for one-side engagement (family fit on Harvey keyseat "
                          "sheets) x hardness x flute count x coating x aggressiveness x radial chip-thinning ratio; "
                          "both sides x0.55"),
            "axial_feed": ("no vendor publishes an axial feed: face chip load = posted chip load x 0.55 (Harvey "
                           "both-sides rule), axial feed per rev = teeth_per_face x face chip load"),
            "radial_depth": "fraction of diameter (Harvey radial x Dia), width and hardness reduced, then neck clearance and deflection",
        },
        "warnings": warnings,
    }


# --------------------------------------------------------------------------------------------------
# shop cutters
# --------------------------------------------------------------------------------------------------

SHOP_TOOLS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "shop_tools.json")


def load_shop_tools(path: Optional[str] = None) -> Dict[str, Dict[str, Any]]:
    """Shop cutter presets from data/shop_tools.json, keyed by id. Each has geometry in millimetres as
    entered by the owner plus `provisional` (field names that are assumed) and `planned` flags."""
    with open(path or SHOP_TOOLS_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)
    return {t["id"]: t for t in data.get("tools", [])}


def compute_shop_tool(physics: Any, tool_id: str, material_family: str, operation: str = "full_slot",
                      path: Optional[str] = None, **kwargs: Any) -> Dict[str, Any]:
    """Run the model for a shop cutter preset (mm in the file, inches into the model). Extra keyword
    arguments override model arguments (aggressiveness, radial_depth_total, slot_height, hardness ...)."""
    t = load_shop_tools(path)[tool_id]
    mm = 1.0 / 25.4
    args: Dict[str, Any] = dict(
        diameter=t["diameter_mm"] * mm, kerf=t["kerf_mm"] * mm, neck_diameter=t["neck_diameter_mm"] * mm,
        reach=t["reach_mm"] * mm, shank_diameter=t["shank_diameter_mm"] * mm, teeth=t["teeth"],
        tooth_form=t.get("tooth_form"), coating=t.get("coating", "Uncoated"),
        teeth_per_face=t.get("teeth_per_face"), cutting_faces=t.get("cutting_faces"),
        provisional=t.get("provisional", []), name=t.get("name", tool_id))
    args.update(kwargs)
    return compute_tslot(physics, material_family, operation=operation, **args)


# --------------------------------------------------------------------------------------------------
# pipeline hook
# --------------------------------------------------------------------------------------------------

def run_for_request(physics: Any, r: Any) -> Dict[str, Any]:
    """Run the model for a normalized ``pipeline.CutRequest`` (T-slot / keyseat / woodruff geometry).
    Reads r.diameter, r.cutter_thickness, r.neck_diameter, r.neck_length, r.shank_diameter, r.flutes,
    r.coating, r.family/r.alloy, r.aggressiveness, r.runout, r.max_rpm, r.max_hp and the optional
    r.tooth_form, r.cutting_faces, r.teeth_per_face, r.tslot_operation, r.slot_height, r.radial_depth_total."""
    hardness = None
    try:
        hb = physics.resolve_alloy_hardness(r.family, r.alloy) if r.alloy else None
        if hb:
            from gwizard_physics import ASTMHardnessConverter
            hrc = ASTMHardnessConverter.brinell_to_hrc(float(hb))
            hardness = max(0.0, hrc) if hrc is not None else None
    except Exception:
        hardness = None
    op = r.tslot_operation if r.tslot_operation in OPERATIONS else "full_slot"
    neck = r.neck_diameter if r.neck_diameter else r.shank_diameter
    out = compute_tslot(
        physics, r.family, r.diameter, r.cutter_thickness, neck, r.neck_length, r.shank_diameter,
        teeth=r.flutes, tooth_form=r.tooth_form, cutting_faces=r.cutting_faces, teeth_per_face=r.teeth_per_face,
        coating=r.coating if r.apply_coating else "Uncoated", hardness=hardness,
        aggressiveness=r.aggressiveness, runout=r.runout, max_rpm=r.max_rpm, max_hp=r.max_hp,
        operation=op, slot_height=r.slot_height,
        radial_depth_total=r.radial_depth_total)
    return out


def apply_to_result(res: Any, out: Dict[str, Any], r: Any) -> None:
    """Write the T-slot model's outputs into a ``pipeline.CutResult`` (rpm, sfm, chip load, feed, radial depth
    per pass as rec_woc, kerf as rec_doc, deflection, mrr, warnings as tips) and store the full dict in
    ``res.tslot``. A critical finding (neck clearance) marks the result infeasible."""
    res.tslot = out
    old_prov = list(res.provenance)
    res.rpm = out["rpm"]
    res.sfm = res.contact_sfm = out["sfm"]
    res.target_sfm = out["target_sfm"]
    res.ideal_rpm = out["target_sfm"] * 12.0 / (math.pi * r.diameter)
    res.is_spindle_limited = out["rpm"] < res.ideal_rpm * 0.995
    res.adj_ipt = res.base_ipt = out["chip_load_ipt"]
    res.feed_ipm = out["feed_ipm"]
    res.ipr = out["feed_ipm"] / out["rpm"] if out["rpm"] > 0 else 0.0
    res.rec_doc = res.doc = r.cutter_thickness
    res.rec_woc = res.woc = out["radial_depth_per_pass_in"]
    res.rec_limit = out["deflection_limit_in"]
    res.deflection = out["deflection_in"]
    res.mrr = out["mrr_in3_min"]
    res.limited_by = out["limited_by"]
    res.model_note = "T-slot / keyseat model (tslot_model)"
    if res.feed_ipm > 0:
        res.plunge_feed = min(res.plunge_feed, res.feed_ipm)
    crit = False
    tips = []
    for w in out["warnings"]:
        crit = crit or w["type"] == "critical"
        tips.append({"title": w["title"], "message": w["message"], "type": w["type"],
                     "fusion": w["type"] in ("critical", "warning")})
    res.tips = tips + [t for t in res.tips if t.get("title") == "Check Shank Diameter"]
    if crit:
        res.feasible = False
    _rewrite_provenance(res, out, old_prov, r)


def _rewrite_provenance(res: Any, out: Dict[str, Any], steps: List[Dict[str, Any]], r: Any) -> None:
    """Keep the pipeline's provenance step names but give them the T-slot model's multipliers so that
    base_sfm x product == target_sfm and base_ipt x product == adj_ipt still hold."""
    agg = 0.70 + 0.60 * max(0.0, min(1.0, r.aggressiveness))
    base_sfm = res.base_sfm or 1.0
    base_ipt = res.base_ipt_lookup or 1.0
    new = []
    for p in steps:
        q = dict(p)
        step, qty = q["step"], q["quantity"]
        if qty == "sfm":
            if step == "base_lookup":
                pass
            elif step == "hardness":
                q["multiplier"] = out["target_sfm"] / (base_sfm * agg)
                q["value_after"] = base_sfm * q["multiplier"]
                q["reason"] = (f"T-slot model: family fit x hardness curve ({out['hardness_hrc']} HRC)"
                               if out["hardness_hrc"] is not None else "T-slot model: family fit")
            elif step == "aggressiveness":
                q["multiplier"] = agg
                q["value_after"] = out["target_sfm"]
                q["reason"] = f"aggressiveness {r.aggressiveness * 100:.0f}%"
            elif step == "spindle_cap":
                q["multiplier"] = out["sfm"] / out["target_sfm"] if out["target_sfm"] else 1.0
                q["value_after"] = out["sfm"]
            else:
                q["multiplier"] = 1.0
                q["value_after"] = out["target_sfm"]
                q["reason"] = "T-slot model: not applied"
        else:
            if step == "chip_thinning":
                q["multiplier"] = out["chip_load_ipt"] / base_ipt
                q["value_after"] = out["chip_load_ipt"]
                q["reason"] = ("T-slot model: chip load per tooth (family fit x hardness x flutes x coating x "
                               "aggressiveness x radial thinning; both sides x0.55)")
            elif step != "base_lookup":
                q["multiplier"] = 1.0
                q["value_after"] = base_ipt
                q["reason"] = "T-slot model: not applied"
        new.append(q)
    res.provenance = new
