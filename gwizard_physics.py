"""
ToolWiz Cutting Physics & Machining Advisory Engine
===================================================
A high-fidelity computational cutting mechanics and tool deflection engine
modeled after standard machining physics, industrial tool manufacturer data
(Harvey Tool, Sandvik Coromant, Kennametal, Kyocera), and classical mechanical
engineering references (Machinery's Handbook, Kienzle force equations, ASTM E140).

Key Physical Modules:
---------------------
1. ASTMHardnessConverter:
   - Certified ASTM E140 Rockwell-C (HRC) to Brinell (HB) conversion.
   - Robust hardness string parser handling ranges, condition codes, and tolerances.

2. CuttingKinematics:
   - Spindle Speed (RPM) and Surface Speed (SFM) conversions.
   - Exact circular chordal Radial Chip Thinning (RCTF) and Axial Chip Thinning (ACTF).
   - Dynamic Minimum Chip Thickness (MCT) scaling for micro vs. macro tools and coatings.
   - True Chip Thickness (TCT) calculation and rubbing detection.

3. CuttingMechanics:
   - Specific cutting energy (kc) derived from material unit horsepower (mf).
   - Kienzle size-effect model: physically predicts elevated cutting energy on micro chips.
   - Tangential, radial separating, and transverse deflecting forces.
   - Material Removal Rate (MRR) and Spindle Horsepower/Torque demand.

4. BeamDeflectionEngine:
   - Area moment of inertia for circular shafts (pi * d^4 / 64).
   - Effective fluted section core web inertia accounting for flutes and helix angle.
   - Exact virtual work integral for multi-segment stepped and tapered cantilever beams.
   - Bending stress analysis and transverse rupture strength safety margins.

5. OptimizationEngine:
   - Multi-objective parameter optimization for 'Auto-Set Dials'.
   - Safely balances tool deflection caps, machine spindle power, and chip clearance.
   - Micro-tool adaptive search floor preventing instantaneous cutter fracture.

6. AdvisoryEngine:
   - Diagnostic feedback for rubbing/burnishing, chatter resonance, work hardening,
     springback error compensation, and form tool immersion constraints.

7. GWizardPhysics:
   - Unified facade class maintaining 100% backward-compatible API.
"""

import os
import math
import json
import logging
import re
from typing import Dict, List, Tuple, Any, Optional

logger = logging.getLogger("ToolWizPhysics")


def is_tap_tool_type(name: str) -> bool:
    """Return True if name indicates a tapping tool, strictly excluding tapered mills."""
    if not name:
        return False
    s = str(name).lower()
    if "taper" in s:
        return False
    return bool(re.search(r'\b(tap|taps|tapping)\b', s))


def is_drilling_tool_type(tool_type: str, geometry: str = "") -> bool:
    """Return True if tool_type or geometry represents an axial hole-making tool (drill, tap, reamer, bore)."""
    t_str = str(tool_type or "").lower()
    g_str = str(geometry or "").lower()
    if is_tap_tool_type(t_str) or is_tap_tool_type(g_str):
        return True
    combined = f"{t_str} {g_str}"
    if "taper" in combined and not any(k in combined for k in ["drill", "reamer", "bore", "tap"]):
        return False
    return bool(re.search(r'\b(drill|drills|drilling|reamer|reamers|reaming|bore|boring|counterbore|countersink|spot drill|center drill|annular|parabolic)\b', combined))


# =============================================================================
# 1. HARDNESS & METALLURGY CONVERSION (ASTM E140)
# =============================================================================

# Vendor-fitted hard-milling correction, relative to the same tool at 45 HRC.
# Sources (manufacturer PDFs, retrieved 2026-09-30):
#   OSG AE-CPR4-H 6 mm, up to 45 / 45-55 / 55-65 HRC: SFM 1.00 / 0.90 / 0.70-0.82, IPT 1.00 / 0.83-0.90 / 0.68-0.70
#   Harvey hardened-steel finishers, 56-68 vs 45-55 Rc: SFM 0.857, IPT 0.80
# GWizard's bounded linear model gives ~0.90 SFM and no IPT reduction at 60 HRC, which is too aggressive.
# Band midpoints are used as knots; beyond 65 HRC the last value is held and a critical tip is raised.
HARD_MILL_ONSET_HRC = 45.0
HARD_MILL_FACTORS: List[Tuple[float, float, float]] = [
    # (HRC, SFM factor, IPT factor)
    (45.0, 1.00, 1.00),
    (50.0, 0.90, 0.87),
    (60.0, 0.75, 0.70),
    (65.0, 0.68, 0.65),
]


def hard_milling_factors(hrc: float) -> Tuple[float, float]:
    """Piecewise-linear (SFM, IPT) multipliers for hardened work above 45 HRC."""
    pts = HARD_MILL_FACTORS
    if hrc <= pts[0][0]:
        return 1.0, 1.0
    if hrc >= pts[-1][0]:
        return pts[-1][1], pts[-1][2]
    for (h0, s0, i0), (h1, s1, i1) in zip(pts, pts[1:]):
        if h0 <= hrc <= h1:
            t = (hrc - h0) / (h1 - h0)
            return s0 + (s1 - s0) * t, i0 + (i1 - i0) * t
    return 1.0, 1.0


class ASTMHardnessConverter:
    """
    Standard hardness conversion utilities based on ASTM E140 (Standard Hardness
    Conversion Tables for Metals).
    """

    # Certified ASTM E140 Table 1: Rockwell C (HRC) to Brinell Hardness (HB, 3000 kgf, 10mm ball)
    _HRC_TO_HB_TABLE: List[Tuple[float, float]] = [
        (20.0, 226.0), (22.0, 237.0), (24.0, 247.0), (26.0, 258.0),
        (28.0, 271.0), (30.0, 286.0), (32.0, 301.0), (34.0, 319.0),
        (36.0, 336.0), (38.0, 353.0), (40.0, 371.0), (42.0, 390.0),
        (44.0, 409.0), (46.0, 432.0), (48.0, 455.0), (50.0, 481.0),
        (52.0, 507.0), (54.0, 534.0), (56.0, 577.0), (58.0, 615.0),
        (60.0, 654.0), (62.0, 688.0), (64.0, 722.0), (66.0, 757.0),
        (68.0, 790.0), (70.0, 820.0)
    ]

    @classmethod
    def hrc_to_brinell(cls, hrc: float) -> float:
        """Convert Rockwell C (HRC) to equivalent Brinell Hardness Number (HB)."""
        if hrc <= cls._HRC_TO_HB_TABLE[0][0]:
            return cls._HRC_TO_HB_TABLE[0][1]
        if hrc >= cls._HRC_TO_HB_TABLE[-1][0]:
            return cls._HRC_TO_HB_TABLE[-1][1]
            
        for i in range(len(cls._HRC_TO_HB_TABLE) - 1):
            x0, y0 = cls._HRC_TO_HB_TABLE[i]
            x1, y1 = cls._HRC_TO_HB_TABLE[i + 1]
            if x0 <= hrc <= x1:
                return y0 + (y1 - y0) * ((hrc - x0) / (x1 - x0))
                
        return hrc

    @classmethod
    def brinell_to_hrc(cls, hb: float) -> Optional[float]:
        """Inverse of hrc_to_brinell. Returns None below the HRC scale (< ~226 HB)."""
        table = cls._HRC_TO_HB_TABLE
        if hb < table[0][1]:
            return None
        if hb >= table[-1][1]:
            return table[-1][0]
        for (h0, b0), (h1, b1) in zip(table, table[1:]):
            if b0 <= hb <= b1:
                return h0 + (h1 - h0) * ((hb - b0) / (b1 - b0))
        return None

    @classmethod
    def parse_hardness(cls, hardness_val: Any) -> Optional[float]:
        """
        Parses raw hardness input into a standardized Brinell Hardness (HB).
        Supports:
          - Numbers or numeric strings ("220" -> 220.0)
          - Ranges ("60-90" -> 90.0 upper bound for conservative cutting)
          - Rockwell C ("62 HRC" -> 688.0 HB)
          - Brinell with units ("250 HB" -> 250.0 HB)
        """
        if hardness_val is None:
            return None
            
        if isinstance(hardness_val, (int, float)):
            return float(hardness_val)
            
        h_str = str(hardness_val).strip()
        if not h_str:
            return None
            
        is_hrc = "hrc" in h_str.lower()
        
        # Extract all numbers (integers or decimals)
        nums = [float(n) for n in re.findall(r'\d+(?:\.\d+)?', h_str)]
        if not nums:
            return None
            
        raw_val = max(nums)  # Use upper bound of range for conservative tool safety
        
        if is_hrc:
            return cls.hrc_to_brinell(raw_val)
            
        return raw_val


# =============================================================================
# 2. CUTTING KINEMATICS & CHIP THINNING
# =============================================================================

class CuttingKinematics:
    """
    Kinematics calculations governing cutting speed, rotational frequency,
    feed velocity, radial and axial chip thinning geometry.
    """

    @staticmethod
    def calc_rpm(sfm: float, diameter: float, max_rpm: float = 16000.0) -> float:
        """Calculate Spindle RPM from Surface Feet per Minute (SFM) and Diameter (in)."""
        if diameter <= 0.0 or sfm <= 0.0:
            return 0.0
        rpm = (sfm * 12.0) / (math.pi * diameter)
        return min(rpm, max_rpm)

    @staticmethod
    def calc_sfm(rpm: float, diameter: float) -> float:
        """Calculate Surface Speed (SFM) from Spindle RPM and Diameter (in)."""
        if diameter <= 0.0 or rpm <= 0.0:
            return 0.0
        return (rpm * math.pi * diameter) / 12.0

    @staticmethod
    def calc_feedrate(rpm: float, flutes: int, chipload: float) -> float:
        """Calculate linear feedrate (Inches Per Minute, IPM)."""
        if rpm <= 0.0 or flutes <= 0 or chipload <= 0.0:
            return 0.0
        return rpm * flutes * chipload

    @staticmethod
    def calc_effective_diameter(diameter: float, cut_depth: float, geometry: str = "Square", corner_radius: float = 0.0) -> float:
        """
        Calculate the true effective cutting diameter for curved cutting tools
        (Ball Nose and Bull Nose) engaging shallow depths of cut.
        """
        if diameter <= 0.0 or cut_depth <= 0.0:
            return diameter

        if "Ball" in geometry:
            radius = diameter / 2.0
            if cut_depth < radius:
                return 2.0 * math.sqrt(max(0.0, radius**2 - (radius - cut_depth)**2))
            return diameter

        if "Radiused" in geometry or "Bull" in geometry:
            if corner_radius > 0.0 and cut_depth < corner_radius:
                flat_center = max(0.0, diameter - (2.0 * corner_radius))
                engaged_corner = 2.0 * math.sqrt(max(0.0, corner_radius**2 - (corner_radius - cut_depth)**2))
                return flat_center + engaged_corner
            return diameter

        if any(c in geometry for c in ["V-Bit", "Chamfer", "Engraving"]):
            # Standard 90-degree included angle (45-degree half angle) chamfer mill:
            # Effective cutting diameter at depth of cut with 20% D minimum floor to prevent infinite RPM at zero depth
            eff = min(diameter, max(diameter * 0.20, 2.0 * cut_depth))
            return eff

        return diameter

    @staticmethod
    def radial_chip_thinning_factor(cut_width: float, diameter: float) -> float:
        """
        Calculates Radial Chip Thinning Factor (RCTF).
        When Radial Width of Cut (WOC, ae) is less than tool radius (D/2):
            h_max = f_z * 2 * sqrt((ae/D) * (1 - ae/D))
            RCTF = f_z / h_max = D / (2 * sqrt(ae * D - ae^2))
        """
        if cut_width <= 0.0 or diameter <= 0.0:
            return 1.0
        if cut_width >= (diameter / 2.0):
            return 1.0  # Full engagement produces true chipload at cutter centerline

        try:
            radial_ratio = cut_width / diameter
            geom_factor = 2.0 * math.sqrt(max(1e-6, radial_ratio * (1.0 - radial_ratio)))
            rctf = 1.0 / geom_factor
            return min(rctf, 5.0)  # Cap at 5.0x to prevent runaway feedrates
        except (ValueError, ZeroDivisionError):
            return 1.0

    @staticmethod
    def axial_chip_thinning_factor(cut_depth: float, diameter: float, geometry: str = "Square", corner_radius: float = 0.0, operation: str = "Roughing") -> float:
        """
        Calculates Axial Chip Thinning Factor (ACTF) for round/radiused insert geometry
        and dedicated high-feed cutters where depth of cut (ap) produces chip thinning.
        """
        if cut_depth <= 0.0 or diameter <= 0.0:
            return 1.0

        op_low = str(operation).lower()
        geo_low = str(geometry).lower()
        is_high_feed_mode = "high feed" in op_low or "high feed" in geo_low

        if is_high_feed_mode:
            # Bullnose / Radiused endmill in high feed:
            if ("radiused" in geo_low or "bull" in geo_low) and corner_radius > 0.0:
                if cut_depth < corner_radius:
                    ratio = min(0.99, max(0.01, cut_depth / corner_radius))
                    sin_kr = math.sqrt(max(0.04, 2.0 * ratio - ratio**2))
                    return min(1.0 / sin_kr, 5.0)
                else:
                    return 1.0
            else:
                # Dedicated High Feed Mill with ~12-15 degree lead angle (~13.5 deg lead)
                lead_angle_rad = math.radians(13.5)
                actf = 1.0 / math.sin(lead_angle_rad)
                return min(actf, 5.0)

        # Standard Ball Nose milling
        if "ball" in geo_low:
            effective_radius = diameter / 2.0
            if cut_depth < effective_radius:
                eff_dia = 2.0 * math.sqrt(max(1e-6, effective_radius**2 - (effective_radius - cut_depth)**2))
                if eff_dia > 0.0:
                    actf = diameter / eff_dia
                    return min(actf, 5.0)

        # Standard Bullnose / Radiused milling
        elif ("radiused" in geo_low or "bull" in geo_low) and corner_radius > 0.0:
            if cut_depth < corner_radius:
                ratio = min(0.99, max(0.01, cut_depth / corner_radius))
                sin_kr = math.sqrt(max(0.04, 2.0 * ratio - ratio**2))
                return min(1.0 / sin_kr, 5.0)

        return 1.0

    @classmethod
    def get_true_chip_thickness(cls, ipt: float, cut_width: float, diameter: float) -> float:
        """
        Computes maximum instantaneous uncut chip thickness (True Chip Thickness, TCT)
        accounting for radial chip thinning.
        """
        if diameter <= 0.0 or ipt <= 0.0:
            return ipt
        if cut_width >= (diameter / 2.0):
            return ipt

        rctf = cls.radial_chip_thinning_factor(cut_width, diameter)
        return ipt / rctf if rctf > 0.0 else ipt

    @staticmethod
    def calc_hem_thermal_sfm_multiplier(cut_width: float, diameter: float, operation: str = "Roughing") -> float:
        """
        Calculates High Efficiency Milling (HEM) / Trochoidal thermal relief SFM multiplier.
        When radial engagement (ae) is low (ae < 0.25*D), cutting flutes are in contact
        with the workpiece for only a small fraction (<50 deg) of each 360 deg revolution,
        spending >85% of the time cooling in air/coolant.
        This cooling duty cycle permits a +15% to +35% SFM boost without thermal tool breakdown.
        """
        op_low = str(operation).lower()
        if not ("adaptive" in op_low or "trochoidal" in op_low):
            return 1.0
        if diameter <= 0.0 or cut_width <= 0.0:
            return 1.0

        immersion = cut_width / diameter
        if immersion < 0.25:
            # +35% boost at ~5-10% immersion, tapering down to 0% at 25% immersion
            boost = 0.35 * max(0.0, 1.0 - (immersion / 0.25))
            return 1.0 + boost
        return 1.0

    @staticmethod
    def get_minimum_chip_thickness(coating: str, tool_type: str = "end mill", diameter: float = 0.5) -> float:
        """
        Calculates Minimum Chip Thickness (MCT) based on cutting edge hone radius (r_beta).
        Under Merchant/Albrecht cutting mechanics, h_min is roughly 0.30 - 0.40 * r_beta.
        
        Tool ground razor sharp (uncoated, polished, diamond) has low MCT.
        Thick multi-layer PVD/CVD coatings (AlTiN, TiAlN) have larger edge hones.
        Micro tools (<1/8") use ultra-thin PVD layers and micro-grain carbide,
        yielding proportionally sharper cutting edges.
        """
        mct = 0.00020  # Uncoated polished micro-grain carbide (~5 um)
        
        c_low = str(coating).lower() if coating else ""
        t_low = str(tool_type).lower() if tool_type else ""

        if "hss" in t_low or "cobalt" in t_low:
            mct = 0.00012  # HSS can be ground to a very keen razor edge
        elif "diamond" in c_low or "pcd" in c_low or "dlc" in c_low:
            mct = 0.00015  # Extremely sharp, low friction
        elif "tin" in c_low or "ticn" in c_low or "zrn" in c_low:
            mct = 0.00030  # Standard single/dual layer PVD
        elif "tialn" in c_low or "altin" in c_low:
            mct = 0.00045  # Tough wear-resistant PVD coating hone (~11 um)

        # Micro-Tool scaling: tools under 1/8" have physically thinner coatings and sharper edges
        if diameter < 0.125 and diameter > 0.0:
            micro_scale = max(0.25, diameter / 0.125)
            mct *= micro_scale

        return mct

    # Standard drill sizes: (diameter_inches, drill_label)
    _STANDARD_DRILLS: List[Tuple[float, str]] = [
        # Number drills (#80 to #1)
        (0.0135, "#80"), (0.0145, "#79"), (0.0160, "#78"), (0.0180, "#77"), (0.0200, "#76"),
        (0.0210, "#75"), (0.0225, "#74"), (0.0240, "#73"), (0.0250, "#72"), (0.0260, "#71"),
        (0.0280, "#70"), (0.0292, "#69"), (0.0310, "#68"), (0.0320, "#67"), (0.0330, "#66"),
        (0.0350, "#65"), (0.0360, "#64"), (0.0370, "#63"), (0.0380, "#62"), (0.0390, "#61"),
        (0.0400, "#60"), (0.0410, "#59"), (0.0420, "#58"), (0.0430, "#57"), (0.0465, "#56"),
        (0.0520, "#55"), (0.0550, "#54"), (0.0595, "#53"), (0.0635, "#52"), (0.0670, "#51"),
        (0.0700, "#50"), (0.0730, "#49"), (0.0760, "#48"), (0.0785, "#47"), (0.0810, "#46"),
        (0.0820, "#45"), (0.0860, "#44"), (0.0890, "#43"), (0.0935, "#42"), (0.0960, "#41"),
        (0.0980, "#40"), (0.0995, "#39"), (0.1015, "#38"), (0.1040, "#37"), (0.1065, "#36"),
        (0.1100, "#35"), (0.1110, "#34"), (0.1130, "#33"), (0.1160, "#32"), (0.1200, "#31"),
        (0.1285, "#30"), (0.1360, "#29"), (0.1405, "#28"), (0.1440, "#27"), (0.1470, "#26"),
        (0.1495, "#25"), (0.1520, "#24"), (0.1540, "#23"), (0.1570, "#22"), (0.1590, "#21"),
        (0.1610, "#20"), (0.1660, "#19"), (0.1695, "#18"), (0.1730, "#17"), (0.1770, "#16"),
        (0.1800, "#15"), (0.1820, "#14"), (0.1850, "#13"), (0.1890, "#12"), (0.1910, "#11"),
        (0.1935, "#10"), (0.1960, "#9"), (0.1990, "#8"), (0.2010, "#7"), (0.2040, "#6"),
        (0.2055, "#5"), (0.2090, "#4"), (0.2130, "#3"), (0.2210, "#2"), (0.2280, "#1"),
        # Letter drills (A to Z)
        (0.2340, "Letter A"), (0.2380, "Letter B"), (0.2420, "Letter C"), (0.2460, "Letter D"), (0.2500, "Letter E"),
        (0.2570, "Letter F"), (0.2610, "Letter G"), (0.2660, "Letter H"), (0.2720, "Letter I"), (0.2770, "Letter J"),
        (0.2810, "Letter K"), (0.2900, "Letter L"), (0.2950, "Letter M"), (0.3020, "Letter N"), (0.3160, "Letter O"),
        (0.3230, "Letter P"), (0.3320, "Letter Q"), (0.3390, "Letter R"), (0.3480, "Letter S"), (0.3580, "Letter T"),
        (0.3680, "Letter U"), (0.3770, "Letter V"), (0.3860, "Letter W"), (0.3970, "Letter X"), (0.4040, "Letter Y"), (0.4130, "Letter Z")
    ]
    # Add Fractional drills (1/64" to 1")
    for _i in range(1, 65):
        _gcd = math.gcd(_i, 64)
        _num = _i // _gcd
        _den = 64 // _gcd
        _label = f"{_num}/{_den}\"" if _den > 1 else f"{_num}\""
        _STANDARD_DRILLS.append((_i / 64.0, _label))
    # Add Metric drills (0.35mm to 25.0mm in 0.05mm steps)
    for _m in range(7, 501):
        _mm = _m * 0.05
        _STANDARD_DRILLS.append((_mm / 25.4, f"{_mm:.2f} mm".rstrip('0').rstrip('.')))
    _STANDARD_DRILLS.sort(key=lambda x: x[0])

    @classmethod
    def calc_tap_drill(
        cls,
        major_dia: float,
        pitch: float,
        tap_type: str = "form",
        material_family: str = "Steel",
        is_metric: bool = False
    ) -> Dict[str, Any]:
        """
        Calculates recommended Tap Drill pilot hole size and resulting thread percentage
        based on ANSI/ISO cutting and cold-forming tap mechanics.
        """
        if major_dia <= 0.0 or pitch <= 0.0:
            return {
                "theoretical_in": 0.0, "theoretical_mm": 0.0,
                "recommended_in": 0.0, "recommended_mm": 0.0,
                "drill_name": "N/A", "thread_percent": 0.0, "target_percent": 0.0, "is_form": False
            }

        is_form = tap_type.lower() == "form"
        is_tough = any(m in material_family.lower() for m in ["stainless", "titanium", "nickel", "high temp", "tool", "die"])
        
        # Target thread height engagement:
        # In tough/work-hardening materials, form taps target 65% (avoiding tap snapping),
        # while cutting taps target 70-75%.
        if is_form:
            target_pct = 65.0 if is_tough else 72.0
        else:
            target_pct = 70.0 if is_tough else 75.0

        d_mm = major_dia * 25.4
        p_mm = pitch * 25.4

        if is_form:
            # OSG / ANSI Cold Forming Tap: Hole(mm) = MajorDia(mm) - (Thread% * Pitch(mm) / 147.06)
            theo_hole_mm = d_mm - (target_pct * p_mm / 147.06)
            theo_hole_in = theo_hole_mm / 25.4
        else:
            # Standard 60 deg Cutting Tap: Hole(mm) = MajorDia(mm) - (Thread% * Pitch(mm) * 1.082532 / 100)
            theo_hole_mm = d_mm - (target_pct * p_mm * 1.082532 / 100.0)
            theo_hole_in = theo_hole_mm / 25.4

        # Match nearest standard drill
        best_diff = 1e9
        best_drill = cls._STANDARD_DRILLS[0]
        for d_in, name in cls._STANDARD_DRILLS:
            diff = abs(d_in - theo_hole_in)
            # Prioritize matching unit system if within 2% margin
            if is_metric and "mm" in name and diff < best_diff * 1.05:
                best_diff = diff
                best_drill = (d_in, name)
            elif not is_metric and "mm" not in name and diff < best_diff * 1.05:
                best_diff = diff
                best_drill = (d_in, name)
            elif diff < best_diff:
                best_diff = diff
                best_drill = (d_in, name)

        rec_hole_in = best_drill[0]
        rec_hole_mm = rec_hole_in * 25.4

        # Compute resulting actual thread percentage with chosen drill
        if is_form:
            actual_pct = ((d_mm - rec_hole_mm) * 147.06) / p_mm if p_mm > 0 else target_pct
        else:
            actual_pct = ((d_mm - rec_hole_mm) / (p_mm * 1.082532)) * 100.0 if p_mm > 0 else target_pct

        return {
            "theoretical_in": theo_hole_in,
            "theoretical_mm": theo_hole_mm,
            "recommended_in": rec_hole_in,
            "recommended_mm": rec_hole_mm,
            "drill_name": best_drill[1],
            "thread_percent": round(max(0.0, min(100.0, actual_pct)), 1),
            "target_percent": target_pct,
            "is_form": is_form
        }

    @classmethod
    def calc_thread_drill_table(
        cls,
        major_dia_in: float,
        pitch_in: float,
        is_form: bool = False,
        is_metric: bool = False,
        material_family: str = ""
    ) -> List[Dict[str, Any]]:
        """
        Replicates G-Wizard GWizTappingDrill engine.
        Evaluates standard drills and calculates % thread engagement and clearance hole sizing.
        """
        if major_dia_in <= 0.0 or pitch_in <= 0.0:
            return []

        tpi = 1.0 / pitch_in
        # G-Wizard constant: 0.0068 for form tap, 0.013 for cutting tap
        factor = 0.0068 if is_form else 0.013
        
        # Target sweet spot
        is_tough = any(m in material_family.lower() for m in ["stainless", "titanium", "nickel", "tool", "die", "inconel"])
        if is_form:
            target_min = 58.0 if is_tough else 60.0
            target_max = 68.0 if is_tough else 72.0
        else:
            target_min = 68.0
            target_max = 78.0

        drill_rows = []
        for d_in, name in cls._STANDARD_DRILLS:
            diff = major_dia_in - d_in
            pct = (diff / factor) * tpi
            # G-Wizard shows drills down to -25% (clearance holes) up to 100% thread
            if -25.0 <= pct <= 100.0:
                pct_val = round(pct, 1)
                
                # Determine status
                if pct_val < -10.0:
                    status = "free_clearance"
                    note = "Free Fit Clearance Hole"
                elif -10.0 <= pct_val < 0.0:
                    status = "close_clearance"
                    note = "Close Fit Clearance Hole"
                elif target_min <= pct_val <= target_max:
                    status = "recommended"
                    note = "Target Sweet Spot (Optimal Strength & Tap Life)"
                elif pct_val > (75.0 if is_form else 80.0):
                    status = "tight"
                    note = "High Engagement (>75%): Soft Alloys Only / High Tap Breakage Risk"
                else:
                    status = "loose"
                    note = "Moderate Engagement: Easy Tapping / Reduced Load"

                drill_rows.append({
                    "name": name,
                    "diameter_in": round(d_in, 4),
                    "diameter_mm": round(d_in * 25.4, 3),
                    "pct_thread": pct_val,
                    "status": status,
                    "note": note,
                    "is_target": (target_min <= pct_val <= target_max)
                })

        # Sort by diameter ascending
        drill_rows.sort(key=lambda x: x["diameter_in"])
        return drill_rows

    @classmethod
    def calc_blind_hole_clearance(
        cls,
        pitch_in: float,
        lead_style: str = "form",
        thread_depth_in: float = 0.0,
        is_metric: bool = False
    ) -> Dict[str, Any]:
        """
        Replicates G-Wizard bhClearanceRecalc:
        blindHoleClearance = (lead + 1) * Pitch + (1.0 / 25.4)
        """
        leads = {
            "bottoming": 1.5,
            "form": 2.5,
            "roll": 2.5,
            "plug": 4.0,
            "taper": 8.5
        }
        lead = leads.get(lead_style.lower(), 2.5)
        safety_margin_in = 1.0 / 25.4  # 1mm safety margin in G-Wizard
        clearance_in = (lead + 1.0) * pitch_in + safety_margin_in
        total_depth_in = thread_depth_in + clearance_in if thread_depth_in > 0 else clearance_in
        
        return {
            "lead_style": lead_style,
            "lead_threads": lead,
            "clearance_in": round(clearance_in, 4),
            "clearance_mm": round(clearance_in * 25.4, 3),
            "total_depth_in": round(total_depth_in, 4),
            "total_depth_mm": round(total_depth_in * 25.4, 3)
        }


# =============================================================================
# 3. CUTTING MECHANICS & FORCES (KIENZLE MODEL & SIZE EFFECT)
# =============================================================================

class CuttingMechanics:
    """
    Cutting forces, specific cutting energy, spindle power, and torque mechanics.
    """

    @staticmethod
    def calc_mrr(cut_depth: float, cut_width: float, feedrate: float, geometry: str = "Square", diameter: float = 0.5) -> float:
        """Calculate Material Removal Rate (MRR) in cubic inches per minute (in^3/min)."""
        if cut_depth <= 0.0 or cut_width <= 0.0 or feedrate <= 0.0:
            return 0.0

        if "Drill" in geometry:
            radius = diameter / 2.0
            return math.pi * (radius ** 2) * feedrate
        elif "Ball" in geometry:
            return cut_depth * cut_width * feedrate * 0.785  # Elliptical chord adjustment

        return cut_depth * cut_width * feedrate

    @classmethod
    def calc_specific_cutting_force(cls, unit_hp: float, chip_thickness: float) -> float:
        """
        Calculates specific cutting force kc (psi) using the Kienzle equation
        incorporating the physical micro-machining size effect:
            kc(h) = kc_ref * (h_ref / h)^mc
        where h_ref = 0.004", mc = 0.22 (standard metal cutting exponent).
        As chip thickness approaches microscopic dimensions (h < 0.001"), specific
        energy increases naturally as cutting transitions from shear to plastic plowing.
        """
        kc_ref = max(0.05, unit_hp) * 396000.0
        h_ref = 0.004

        h = max(0.00005, chip_thickness)
        mc = 0.22  # Kienzle cutting force slope exponent

        size_effect = (h_ref / h) ** mc
        size_effect = max(0.70, min(3.50, size_effect))

        return kc_ref * size_effect

    @staticmethod
    def calc_deflection_limit(
        diameter: float,
        operation: str = "Roughing",
        aggressiveness: float = 0.5,
        is_carbide: bool = True
    ) -> float:
        """
        Calculates the physically realistic safe deflection limit (inches)
        based on tool diameter, operation type, and machining aggressiveness.
        
        G-Wizard & machining physics standards:
        - Finishing: tight tolerance (0.002 x D, clamped to 0.0001" - 0.0005") to guarantee surface finish & dimensional accuracy.
        - Adaptive / HEM: roughing allowable deflection with chip thinning (up to 0.006x - 0.008x D, max 0.0030").
        - Roughing / 3D Roughing / Facing / Slotting: roughing allowance (0.006x - 0.010x D, clamped to 0.0004" - 0.0020")
          governed by tool breakage and chatter threshold, not mirror finish tolerance.
        """
        op_low = str(operation).lower()
        is_finish = "finish" in op_low
        is_adaptive = "adaptive" in op_low or "trochoidal" in op_low or "hem" in op_low
        
        if "high feed" in op_low or "hf" in op_low:
            lim = diameter * 0.002 * (0.5 + aggressiveness * 0.8)
            return max(0.0005, min(0.0030, lim))
        elif "semi" in op_low:
            # Semi-finishing: intermediate tolerance between roughing and finishing (up to 0.0010")
            lim = diameter * 0.003 * (0.5 + aggressiveness * 0.5)
            return max(0.0003, min(0.0010, lim))
        elif is_finish:
            # Finishing: tight tolerance (0.001x to 0.002x D, max 0.0005")
            lim = diameter * 0.002 * (0.7 + aggressiveness * 0.6)
            return max(0.0001, min(0.0005, lim))
        elif is_adaptive:
            # High Efficiency Milling (HEM) uses roughing-grade allowable deflection (0.001" - 0.003" based on aggressiveness)
            lim = diameter * 0.006 * (0.35 + aggressiveness * 0.65)
            return max(0.0004, min(0.0030, lim))
        else:
            # Traditional roughing / 3D roughing / slotting / facing:
            lim = diameter * 0.002 * (0.2 + aggressiveness)
            if diameter <= 0.125:
                # Micro-tool transverse compliance floor to prevent false alerts on sub-100 microinch deflections
                lim = max(0.00035, lim)
            return min(0.0010, lim)

    @classmethod
    def calc_cutting_forces(
        cls,
        diameter: float,
        cut_depth: float,
        cut_width: float,
        feedrate: float,
        rpm: float,
        flutes: int,
        unit_hp: float,
        helix_angle: float = 30.0,
        operation: str = "Roughing",
        geometry: str = "Square",
        corner_radius: float = 0.0
    ) -> Tuple[float, float, float, float]:
        """
        Calculates cutting forces (lbs), torque (in-lbs), and spindle power (HP).
        
        Returns:
            (tangential_force, radial_force, resultant_deflection_force, spindle_hp)
        """
        if rpm <= 0.0 or diameter <= 0.0 or cut_depth <= 0.0 or cut_width <= 0.0 or feedrate <= 0.0:
            return 0.0, 0.0, 0.0, 0.0

        mrr = cls.calc_mrr(cut_depth, cut_width, feedrate, diameter=diameter)
        if mrr <= 0.0:
            return 0.0, 0.0, 0.0, 0.0

        ipt = feedrate / (rpm * max(1, flutes))
        tct = CuttingKinematics.get_true_chip_thickness(ipt, cut_width, diameter)
        kc = cls.calc_specific_cutting_force(unit_hp, tct)

        spindle_hp = (kc * mrr) / 396000.0
        sfm = CuttingKinematics.calc_sfm(rpm, diameter)
        if sfm <= 0.0:
            return 0.0, 0.0, 0.0, spindle_hp

        tangential_force = (33000.0 * spindle_hp) / sfm

        radial_immersion = min(1.0, cut_width / diameter)
        kr_ratio = 0.35 + 0.25 * max(0.0, 1.0 - 2.0 * radial_immersion)
        radial_force = tangential_force * kr_ratio

        op_low = str(operation).lower()
        is_high_feed = "high feed" in op_low or geometry == "High Feed"
        if is_high_feed:
            lead_angle_rad = math.radians(13.0)
            if ("radiused" in geometry.lower() or "bull" in geometry.lower()) and corner_radius > 0.0:
                if cut_depth < corner_radius:
                    ratio = min(0.95, cut_depth / corner_radius)
                    lead_angle_rad = max(math.radians(10.0), math.acos(1.0 - ratio) / 1.7)
            sin_lead = math.sin(lead_angle_rad)
            # In high feed, ~85% of force is axial into spindle; lateral bending force is scaled by sin(lead_angle)
            deflection_force = math.sqrt(tangential_force**2 + (radial_force * sin_lead)**2) * sin_lead * 1.5
        else:
            deflection_force = math.sqrt(tangential_force**2 + radial_force**2)

        return tangential_force, radial_force, deflection_force, spindle_hp


# =============================================================================
# 4. BEAM DEFLECTION MECHANICS (EXACT VIRTUAL WORK INTEGRAL)
# =============================================================================

class BeamDeflectionEngine:
    """
    Precision tool deflection engine implementing exact virtual work integration
    for multi-segment stepped and tapered cantilever beams.
    
    Classical Mechanics Reference:
        delta_tip = (F_transverse / E) * Integral_0^L [ x^2 / I(x) ] dx
    where x is the axial distance measured from the cutting tip (x=0) to the collet (x=L).
    """

    _GAUSS_X: List[float] = [-0.9061798459, -0.5384693101, 0.0, 0.5384693101, 0.9061798459]
    _GAUSS_W: List[float] = [0.2369268850, 0.4786286705, 0.5688888889, 0.4786286705, 0.2369268850]

    @staticmethod
    def solid_circular_inertia(diameter: float) -> float:
        """Area moment of inertia for a solid circular shaft: I = (pi * d^4) / 64."""
        if diameter <= 0.0:
            return 0.0
        return (math.pi * (diameter ** 4)) / 64.0

    @classmethod
    def fluted_core_inertia(cls, diameter: float, flutes: int = 4, helix_angle: float = 30.0) -> float:
        """
        Area moment of inertia for a fluted end mill section.
        Accounts for core web diameter (d_core) and helix angle pitch.
        Fluted section inertia is typically 45% to 55% of solid cylinder inertia.
        """
        if diameter <= 0.0:
            return 0.0

        flute_core_ratio = 1.0 - (0.045 * min(flutes, 6))
        helix_factor = math.cos(math.radians(max(0.0, min(60.0, helix_angle)) / 2.0))
        d_core = diameter * max(0.50, min(0.75, flute_core_ratio * helix_factor))

        i_core = cls.solid_circular_inertia(d_core)
        i_solid = cls.solid_circular_inertia(diameter)

        return i_core + 0.15 * max(0.0, i_solid - i_core)

    @classmethod
    def calc_tapered_neck_integral(cls, x_start: float, x_end: float, d_start: float, taper_angle_deg: float) -> float:
        """
        Evaluates Integral_{x_start}^{x_end} [ x^2 / I(x) ] dx for a tapered neck
        where d(x) = d_start + 2 * (x - x_start) * tan(taper_angle).
        """
        if x_end <= x_start:
            return 0.0

        tan_alpha = math.tan(math.radians(max(0.0, taper_angle_deg)))
        if tan_alpha <= 1e-6:
            i_neck = cls.solid_circular_inertia(d_start)
            return (x_end**3 - x_start**3) / (3.0 * i_neck) if i_neck > 0.0 else 0.0

        mid = 0.5 * (x_end + x_start)
        half_len = 0.5 * (x_end - x_start)
        total = 0.0

        for xi, wi in zip(cls._GAUSS_X, cls._GAUSS_W):
            x = mid + half_len * xi
            d_x = max(0.001, d_start + 2.0 * (x - x_start) * tan_alpha)
            i_x = (math.pi * (d_x ** 4)) / 64.0
            total += wi * (x ** 2) / i_x

        return total * half_len

    @classmethod
    def calculate_deflection(
        cls,
        cutting_force_lbs: float,
        diameter: float,
        shank_diameter: float,
        stickout: float,
        flute_length: float,
        neck_diameter: Optional[float] = None,
        neck_length: float = 0.0,
        taper_angle: float = 0.0,
        flutes: int = 4,
        helix_angle: float = 30.0,
        is_carbide: bool = True
    ) -> float:
        """
        Calculates tool tip deflection (inches) for a stepped cantilever beam.
        """
        if cutting_force_lbs <= 0.0 or stickout <= 0.0 or diameter <= 0.0:
            return 0.0

        E = 90000000.0 if is_carbide else 30000000.0
        shank_dia = shank_diameter if shank_diameter > 0.0 else diameter
        neck_dia = neck_diameter if (neck_diameter is not None and neck_diameter > 0.0) else shank_dia

        L1 = max(0.0, min(flute_length, stickout))
        L2 = max(0.0, min(neck_length, stickout) - L1)
        L3 = max(0.0, stickout - L1 - L2)

        integral_sum = 0.0

        if L1 > 0.0:
            i_flute = cls.fluted_core_inertia(diameter, flutes, helix_angle)
            if i_flute > 0.0:
                integral_sum += (L1 ** 3) / (3.0 * i_flute)

        if L2 > 0.0:
            integral_sum += cls.calc_tapered_neck_integral(L1, L1 + L2, neck_dia, taper_angle)

        if L3 > 0.0:
            x_start = L1 + L2
            x_end = stickout
            i_shank = cls.solid_circular_inertia(shank_dia)
            if i_shank > 0.0:
                integral_sum += (x_end**3 - x_start**3) / (3.0 * i_shank)

        tip_deflection = (cutting_force_lbs / E) * integral_sum
        return max(0.0, tip_deflection)


# =============================================================================
# 5. PARAMETER OPTIMIZER ('AUTO-SET DIALS')
# =============================================================================

class OptimizationEngine:
    """
    Automated optimization algorithm for 'Auto-Set Dials', determining safe,
    high-productivity Axial Depth of Cut (DOC) and Radial Width of Cut (WOC).
    """

    @staticmethod
    def recommend_cut_parameters(
        physics: Any,
        diameter: float,
        shank_size: float,
        stickout: float,
        flutes: int,
        rpm: float,
        base_ipt: float,
        is_carbide: bool = True,
        operation: str = "Roughing",
        aggressiveness: float = 0.5,
        geometry: str = "Square",
        cutter_thickness: float = 0.125,
        max_hp: float = 10.0,
        material_family: Optional[str] = None,
        helix_angle: float = 30.0,
        neck_length: float = 0.5,
        taper_angle: float = 0.0,
        flute_length: float = 1.0,
        neck_diameter: Optional[float] = None,
        corner_radius: float = 0.0,
        details: Optional[Dict[str, Any]] = None
    ) -> Tuple[float, float, float]:
        """Returns (doc, woc, deflection_limit). If `details` is a dict it is filled with
        {"feasible": bool, "limited_by": "deflection"|"power"|"flute_length"|"geometry_rule"}."""
        if details is None:
            details = {}
        details.update({"feasible": True, "limited_by": "geometry_rule"})
        default_max_deflect = diameter * 0.002
        op_low = operation.lower()
        is_adaptive = "adaptive" in op_low or "trochoidal" in op_low
        is_high_feed = "high feed" in op_low or geometry == "High Feed" or "high feed" in str(geometry).lower()
        mat_fam_low = str(material_family).lower() if material_family else ""
        is_non_ferrous = any(m in mat_fam_low for m in ["aluminum", "brass", "copper", "magnesium", "plastic", "wood"])
        is_superalloy = any(m in mat_fam_low for m in ["titanium", "inconel", "nickel", "cobalt", "waspaloy", "hastelloy"])
        is_ball_radiused = any(b in str(geometry).lower() for b in ["ball", "radiused", "bull"])

        if is_high_feed:
            # High feed operations direct ~85% force axially into spindle; lateral deflection is minimal
            target_deflection = default_max_deflect * (0.5 + aggressiveness * 0.8)
        else:
            target_deflection = CuttingMechanics.calc_deflection_limit(
                diameter, operation=operation, aggressiveness=aggressiveness, is_carbide=is_carbide
            )

        is_floor_finish = "floor" in op_low
        is_semi_finish = "semi" in op_low
        is_3d_contour = any(s in op_low for s in ["scallop", "contour finishing", "surfacing"]) or ("3d" in op_low and not is_adaptive and "rough" not in op_low)

        if is_3d_contour:
            # 3D Contouring / Scallop: light stepover (8-12% D, min 0.005", max 0.040")
            target_woc = max(0.005, min(0.040, diameter * 0.10))
        elif is_floor_finish:
            # Floor Finishing: wide radial pass (50-75% D) across pocket/feature bottom
            target_woc = diameter * 0.65
        elif is_semi_finish:
            # Semi-Finishing: moderate radial cut (6-10% D) leaving ~0.005"-0.010" skin for finish
            target_woc = max(0.008, diameter * 0.08)
        elif "finish" in op_low:
            # Wall Finishing: light radial stepover (2% to 4% D, max 0.015") enabling deep single-pass DOC
            target_woc = max(0.003, min(0.015, diameter * 0.035))
        elif "slot" in op_low:
            target_woc = diameter
        elif is_high_feed:
            target_woc = diameter * 0.65
        elif is_adaptive:
            # High Efficiency Milling (HEM) chip-thinning radial stepover window:
            # Continuous physics scaling across tool diameters (from micro 1/32" up to macro 1/4"+):
            # Micro-tools lack transverse core stiffness (I ~ D^4) and use wider WOC (~40-45% D)
            # with shallow axial stepdowns (~8-10% D).
            # As tool size increases, tool core rigidity scales with D^4, allowing a smooth transition
            # into deep axial engagement (1.0 - 2.0x D) and light radial stepover (8-18% D).
            if is_non_ferrous:
                macro_woc_ratio = 0.18
            elif is_superalloy:
                macro_woc_ratio = 0.08
            else:
                macro_woc_ratio = 0.10

            t = max(0.0, min(1.0, (diameter - 0.03125) / (0.250 - 0.03125)))
            woc_ratio = 0.45 * (1.0 - t) + macro_woc_ratio * t
            target_woc = diameter * woc_ratio
        elif "face" in op_low:
            target_woc = diameter * 0.75
        else:
            target_woc = diameter * 0.50

        if geometry in ["T-Slot", "Dovetail", "Keyseat", "Woodruff"]:
            physical_radial_reach = (diameter - neck_diameter) / 2.0 if (neck_diameter is not None and 0.0 < neck_diameter < diameter) else diameter * 0.25
            
            # Harvey Tool standard: 0.12xD for non-ferrous, 0.08xD for ferrous/stainless
            standard_ratio = 0.12 if is_non_ferrous else 0.08
            rec_woc = min(physical_radial_reach, diameter * standard_ratio)
            if "finish" in op_low:
                rec_woc = min(rec_woc, diameter * 0.04)

            doc = cutter_thickness if cutter_thickness > 0.0 else flute_length
            return doc, rec_woc, target_deflection

        if "drill" in geometry.lower() or geometry == "Parabolic" or "drill" in str(op_low):
            rec_woc = diameter
            rec_doc = min(flute_length, diameter * 3.0)
            return rec_doc, rec_woc, target_deflection

        if "reamer" in str(geometry).lower() or "ream" in str(op_low):
            rec_woc = diameter
            rec_doc = min(flute_length, diameter * 4.0)
            return rec_doc, rec_woc, target_deflection

        if geometry in ["Thread Mill"] or "thread" in str(op_low):
            rec_woc = diameter * 0.10
            rec_doc = min(flute_length, diameter * 1.5)
            return rec_doc, rec_woc, target_deflection

        if geometry in ["V-Bit", "Engraving", "Chamfer", "Chamfer Mill"] or any(c in str(op_low) for c in ["chamfer", "engrav"]):
            rec_woc = diameter * 0.15 if geometry in ["V-Bit", "Chamfer", "Chamfer Mill"] else diameter * 0.05
            rec_doc = diameter * 0.15 if geometry in ["V-Bit", "Chamfer", "Chamfer Mill"] else diameter * 0.05
            return rec_doc, rec_woc, target_deflection

        if is_high_feed:
            if ("radiused" in geometry.lower() or "bull" in geometry.lower()) and corner_radius > 0.0:
                rec_doc = min(corner_radius * 0.20, diameter * 0.035)
            else:
                rec_doc = diameter * 0.035
            rec_doc = max(rec_doc, 0.001)
            return rec_doc, target_woc, target_deflection

        if is_3d_contour:
            # 3D Contouring / Scallop Finishing: light axial stepdown and shallow radial stepover
            rec_doc = min(0.015, max(0.003, diameter * 0.04))
            return rec_doc, target_woc, target_deflection

        if is_floor_finish:
            # Floor finishing takes a shallow skim depth (0.003"-0.010") to clean up floor stock
            rec_doc = min(0.010, max(0.003, diameter * 0.04))
            return rec_doc, target_woc, target_deflection

        if is_adaptive:
            if is_non_ferrous:
                macro_doc_mult = 2.0
            elif is_superalloy:
                macro_doc_mult = 1.0
            else:
                macro_doc_mult = 1.5

            t = max(0.0, min(1.0, (diameter - 0.03125) / (0.250 - 0.03125)))
            s_doc = t ** 2.305
            doc_ratio = 0.08 * (1.0 - s_doc) + macro_doc_mult * s_doc
            target_adaptive_doc = diameter * doc_ratio

            avail_flute = flute_length if flute_length > 0.0 else target_adaptive_doc
            max_doc = min(avail_flute, target_adaptive_doc)
            min_doc = max(diameter * 0.02, 0.0005)
            step = max(diameter * 0.01, 0.0002)
        elif is_ball_radiused and ("rough" in op_low or "contour" in op_low):
            # Traditional 3D roughing with ball endmills uses shallow stepdowns (0.15xD to 0.25xD)
            avail_flute = flute_length if flute_length > 0.0 else diameter * 0.25
            max_doc = min(diameter * 0.25, avail_flute)
            min_doc = max(diameter * 0.02, 0.0005)
            step = max(diameter * 0.02, 0.0005)
        else:
            max_doc = min(diameter * 4.0, flute_length if flute_length > 0.0 else diameter * 1.5)
            min_doc = max(diameter * 0.02, 0.0005)
            step = max(diameter * 0.02, 0.0005)

        best_doc = min_doc
        best_woc = target_woc
        current_doc = min_doc

        unit_hp = 1.0
        if material_family and material_family in physics.machinability:
            unit_hp = physics.machinability[material_family].get("unit_hp", 1.0)

        # Thermal relief speed boost in Adaptive evaluation
        hem_sfm_mult = CuttingKinematics.calc_hem_thermal_sfm_multiplier(target_woc, diameter, operation=operation)
        eval_rpm = rpm * hem_sfm_mult

        found_safe = False
        while current_doc <= max_doc:
            adj_ipt = physics.calc_adjusted_chipload(
                base_ipt, current_doc, target_woc, diameter, diameter, operation=operation, geometry=geometry, corner_radius=corner_radius
            )
            feed = physics.calc_feedrate(eval_rpm, flutes, adj_ipt)

            deflect = physics.tool_deflection(
                diameter, shank_size, stickout, current_doc, target_woc, feed, eval_rpm, flutes,
                is_carbide=is_carbide, material_family=material_family, helix_angle=helix_angle,
                neck_length=neck_length, taper_angle=taper_angle, flute_length=flute_length,
                neck_diameter=neck_diameter, operation=operation, geometry=geometry, corner_radius=corner_radius
            )

            _, _, _, est_hp = CuttingMechanics.calc_cutting_forces(
                diameter, current_doc, target_woc, feed, eval_rpm, flutes, unit_hp, helix_angle,
                operation=operation, geometry=geometry, corner_radius=corner_radius
            )

            if deflect > target_deflection or est_hp > max_hp:
                details["limited_by"] = "deflection" if deflect > target_deflection else "power"
                break
            details["limited_by"] = "flute_length"

            found_safe = True
            best_doc = current_doc
            if current_doc < max_doc and (current_doc + step) > max_doc:
                current_doc = max_doc
            else:
                current_doc += step

        # If even min_doc exceeded target_deflection at target_woc (e.g. tough alloy, high stickout, or non-carbide):
        # Step down radial immersion (WOC) to reduce cutting force and guarantee a safe cut within deflection limits
        if not found_safe:
            best_doc = min_doc
            for woc_ratio in [0.35, 0.25, 0.15, 0.10, 0.05]:
                cand_woc = max(diameter * 0.02, diameter * woc_ratio)
                if cand_woc >= target_woc:
                    continue
                adj_ipt = physics.calc_adjusted_chipload(
                    base_ipt, min_doc, cand_woc, diameter, diameter, operation=operation, geometry=geometry, corner_radius=corner_radius
                )
                feed = physics.calc_feedrate(eval_rpm, flutes, adj_ipt)
                deflect = physics.tool_deflection(
                    diameter, shank_size, stickout, min_doc, cand_woc, feed, eval_rpm, flutes,
                    is_carbide=is_carbide, material_family=material_family, helix_angle=helix_angle,
                    neck_length=neck_length, taper_angle=taper_angle, flute_length=flute_length,
                    neck_diameter=neck_diameter, operation=operation, geometry=geometry, corner_radius=corner_radius
                )
                best_woc = cand_woc
                if deflect <= target_deflection:
                    break
            else:
                # Even the lightest candidate cut exceeds the deflection limit: no safe cut exists.
                details["feasible"] = False
            details["limited_by"] = "deflection"

        return best_doc, best_woc, target_deflection


# =============================================================================
# 6. MACHINING ADVISORY ENGINE
# =============================================================================

class AdvisoryEngine:
    """
    Generates intelligent physics-driven diagnostic advice, warnings, and tips.
    """

    @staticmethod
    def generate_tips(
        physics: Any,
        material_family: str,
        diameter: float,
        cut_depth: float,
        cut_width: float,
        feedrate: float,
        rpm: float,
        flutes: int,
        coating: str,
        deflection_inches: float,
        tool_type: str = "end mill",
        stickout: float = 1.5,
        geometry: str = "Square",
        flute_length: float = 1.0,
        operation: str = "Roughing",
        tap_type: str = "form",
        neck_diameter: float = 0.0,
        alloy: str = "",
        corner_radius: float = 0.0
    ) -> List[Dict[str, str]]:
        tips: List[Dict[str, str]] = []
        if rpm <= 0.0 or flutes <= 0 or diameter <= 0.0:
            return tips

        mat_props = physics.machinability.get(material_family, {})
        is_work_hardening = mat_props.get("work_hardening", False) or any(w in str(alloy).lower() for w in ["nitronic", "inconel", "titanium", "316", "304"])
        sb_factor = mat_props.get("springback_factor", 0.0002)
        if "nitronic 60" in str(alloy).lower():
            sb_factor = max(sb_factor, 0.0006)
        unit_hp = mat_props.get("unit_hp", 1.0)

        mat_lower = (str(material_family) + " " + str(alloy)).lower()
        is_highly_elastic = any(m in mat_lower for m in ["plastic", "titanium", "wood", "zirconium", "delrin", "acetal", "nylon", "peek", "teflon", "rubber"])
        has_high_springback = sb_factor >= 0.0004 or is_highly_elastic or any(s in mat_lower for s in ["nitronic", "titanium", "inconel", "316", "304", "plastic", "zirconium", "peek", "delrin", "acetal", "nylon"])

        is_drilling = is_drilling_tool_type(tool_type, geometry)
        is_saw = geometry in ["T-Slot", "Keyseat", "Woodruff"] or "saw" in str(tool_type).lower() or "woodruff" in str(tool_type).lower()
        ld_ratio = stickout / diameter if diameter > 0.0 else 0.0
        fl_ratio = (flute_length / diameter) if (diameter > 0.0 and flute_length > 0.0) else 0.0
        critical_ld = 8.0 if is_drilling else max(3.5, fl_ratio * 1.15)

        mct = CuttingKinematics.get_minimum_chip_thickness(coating, tool_type, diameter)
        ipt = feedrate / (rpm * flutes) if (rpm > 0 and flutes > 0) else 0.0
        tct = ipt if is_saw else CuttingKinematics.get_true_chip_thickness(ipt, cut_width, diameter)

        # 5% tolerance prevents floating point precision artifacts on threshold cuts
        # For saws and woodruff cutters, G-Wizard bestFinishChipload floor (~0.00031") is considered safe shearing
        if not is_saw and tct < (mct * 0.95) and tct > 0.0:
            penalty_note = ""
            if ld_ratio > critical_ld:
                penalty_note = f" (drastically reduced by the {ld_ratio:.1f}xD stickout chatter penalty)"
            tips.append({
                "title": "Rubbing & Heat Trap Warning",
                "message": (
                    f"Your True Chip Thickness ({tct:.4f}\" / {tct*25.4:.3f} mm){penalty_note} is smaller than the edge "
                    f"radius of your {coating} tool (~{mct:.4f}\" / {mct*25.4:.3f} mm). The tool will plow and rub "
                    f"rather than shear the metal, causing rapid heat buildup and premature failure. Increase feedrate (IPT) "
                    f"or shorten tool stickout in the collet."
                ),
                "type": "critical"
            })

        # Deflection / springback warnings apply to lateral milling cuts, not balanced axial hole tools
        if not is_drilling:
            springback_inches, total_error, wear_comp = physics.calc_springback_and_deflection(
                material_family, diameter, cut_depth, cut_width, feedrate, rpm, flutes, deflection_inches, alloy=alloy
            )

            mat_display_name = alloy if (alloy and alloy.strip()) else material_family
            op_lower = str(operation).lower()
            is_roughing_op = any(r in op_lower for r in ["rough", "adaptive", "clearing", "pocket", "trochoidal", "hem", "slot"])
            is_floor_finishing = any(s in op_lower for s in ["floor", "facing", "flat", "horizontal", "face"]) and not is_roughing_op
            is_finishing = ("finish" in op_lower or is_floor_finishing or (cut_width <= (diameter * 0.15) and not is_roughing_op)) and not is_roughing_op
            # Negative stock-to-leave only makes sense on finishing passes; roughing must keep stock.
            should_advise_wear_comp = is_finishing and (
                total_error >= 0.00025
                or has_high_springback
                or springback_inches >= 0.0003
            )

            if should_advise_wear_comp:
                if is_floor_finishing:
                    tip_type = "warning" if springback_inches > 0.0005 else "info"
                    tips.append({
                        "title": "Floor Finishing (Axial Springback & Z-Compensation)",
                        "message": (
                            f"Floor finish cuts experience axial tool push-up and material springback ({springback_inches:.4f}\" / {springback_inches*25.4:.3f} mm) "
                            f"rather than lateral wall deflection. To hit nominal print floor height, apply a **Negative Axial Stock-to-Leave** of "
                            f"{-springback_inches:.4f}\" ({-springback_inches*25.4:.3f} mm) in CAM (or lower your tool Z-offset at the CNC controller)."
                        ),
                        "type": tip_type
                    })
                    tips.append({
                        "title": "Radial Stock Strategy for Floors (Floor-Only vs Combined)",
                        "message": (
                            f"• **Floor-Only Cut:** Set **Positive Radial Stock-to-Leave** (+0.0050\" to +0.0100\" / +0.13 to +0.25 mm). "
                            f"This keeps the cutter flutes off finished pocket walls, avoiding wall rubbing, corner chatter, and chip drag marks.\n"
                            f"• **Combined Floor + Wall Cut** (e.g. Fusion 360 'Flat' with finishing pass enabled): If your toolpath cuts both the floor "
                            f"and sweeps perimeter walls, enter **BOTH** compensation values in CAM: Axial Stock {-springback_inches:.4f}\" "
                            f"({-springback_inches*25.4:.3f} mm) and Radial Stock {wear_comp:.4f}\" ({wear_comp*25.4:.3f} mm)."
                        ),
                        "type": "warning"
                    })
                else:
                    tip_type = "warning" if total_error > 0.0005 else "info"
                    spring_note = ""
                    if is_work_hardening:
                        spring_note = (
                            f" Note: In work-hardening {mat_display_name}, never take a zero-offset 'spring pass' to clean up "
                            f"this error--cutting below the Minimum Chip Thickness ({mct:.4f}\" / {mct*25.4:.3f} mm) will rub, "
                            f"burnish the surface, and destroy the cutting edge. Apply wear compensation directly to the finish pass."
                        )
                    tips.append({
                        "title": "Tool Wear Compensation (Wall Deflection & Axial Springback)",
                        "message": (
                            f"• **Wall (Radial):** Expect the machined wall to cut +{total_error:.4f}\" ({total_error*25.4:.3f} mm) oversized due to "
                            f"Material Springback ({springback_inches:.4f}\" / {springback_inches*25.4:.3f} mm) and Tool Deflection ({deflection_inches:.4f}\" / {deflection_inches*25.4:.3f} mm). "
                            f"Set a **Negative Radial Stock-to-Leave** of {wear_comp:.4f}\" ({wear_comp*25.4:.3f} mm) (or D-offset in G41/G42).\n"
                            f"• **Floor (Axial):** If finishing down to a floor or shoulder that was not previously cut by a floor operation, apply a "
                            f"**Negative Axial Stock-to-Leave** of {-springback_inches:.4f}\" ({-springback_inches*25.4:.3f} mm) to account for vertical springback. "
                            f"*(If floor was already finished by a prior floor pass, keep Axial Stock at 0.0000\" / 0.000 mm).*{spring_note}"
                        ),
                        "type": tip_type
                    })

            if total_error > 0.0005 and is_work_hardening:
                if total_error < mct:
                    tips.append({
                        "title": "Spring Pass Trap",
                        "message": (
                            f"Do NOT use a 'Spring Pass' to clean up the {total_error:.4f}\" ({total_error*25.4:.3f} mm) "
                            f"deflection. In work-hardening alloys like {mat_display_name}, taking a cut smaller than the Minimum "
                            f"Chip Thickness ({mct:.4f}\" / {mct*25.4:.3f} mm) will rub and destroy the cutting edge."
                        ),
                        "type": "critical"
                    })
                else:
                    tips.append({
                        "title": "Work-Hardening Cleanup",
                        "message": (
                            f"{mat_display_name} is highly prone to work-hardening. Ensure your cleanup pass is at least "
                            f"{mct:.4f}\" ({mct*25.4:.3f} mm) thick so the cutting edge penetrates past the hardened skin."
                        ),
                        "type": "info"
                    })

            if is_highly_elastic and cut_width < diameter * 0.15 and not is_floor_finishing:
                tips.append({
                    "title": "Conventional Milling for Finishing",
                    "message": (
                        f"Because {mat_display_name} has high elastic recovery, Conventional Milling on your final light pass "
                        f"naturally pulls the cutter into the wall, counteracting springback and giving truer dimensions."
                    ),
                    "type": "tip"
                })

        # Overhang checks: distinguish severe flute/stickout mismatch vs general L/D ratio
        # Exempt saws and woodruff cutters (G-Wizard adjustSFMForLength = false)
        if not is_saw:
            if flute_length > 0.0 and stickout > (flute_length * 2.0) and ld_ratio > 8.0:
                rec_st = max(flute_length * 1.25, flute_length + 0.10)
                tips.append({
                    "title": "Excessive Stickout Overhang",
                    "message": (
                        f"Tool stickout is {ld_ratio:.1f}xD ({stickout:.3f}\" / {stickout*25.4:.1f} mm), which is "
                        f"{stickout/flute_length:.1f}x longer than the flutes ({flute_length:.3f}\" / {flute_length*25.4:.1f} mm). "
                        f"This extreme overhang forces severe speed and feed reductions to avoid chatter. Choking the tool up in the collet "
                        f"(~{rec_st:.3f}\" / {rec_st*25.4:.1f} mm) will eliminate chatter penalties and dramatically boost performance."
                    ),
                    "type": "warning"
                })
            elif ld_ratio > critical_ld:
                tips.append({
                    "title": "Resonance & Chatter Penalty",
                    "message": (
                        f"Tool stickout is {ld_ratio:.1f}x diameter. For {'drilling' if is_drilling else 'milling'}, overhangs over {critical_ld:.1f}xD "
                        f"induce self-excited chatter. Feeds and speeds have been scaled down to stabilize the cut."
                    ),
                    "type": "warning"
                })

        if is_saw:
            # G-Wizard GWizFeedSpeedMath.as:2680: Recommend bestTeeth for chip clearance
            min_bhn = float(mat_props.get("minBHN", 100.0))
            woc = cut_width if cut_width > 0.0 else (diameter * 0.25)
            tpi = 10.0 if woc < 0.5 else 6.0
            if min_bhn <= 150:
                tpi *= 1.2
            best_teeth = diameter * math.pi * tpi
            if flutes > best_teeth and best_teeth >= 1.0:
                tips.append({
                    "title": "Cutter Tooth Clearance",
                    "message": f"Recommend {math.floor(best_teeth)} teeth for chip clearance in this cut width (current cutter has {flutes} flutes).",
                    "type": "info"
                })

        # Physical clearance and collision diagnostics
        if neck_diameter > 0.0 and neck_diameter < (diameter * 0.999):
            max_reach = (diameter - neck_diameter) / 2.0
            is_form_cutter = any(s in str(geometry).lower() for s in ["t-slot", "woodruff", "keyseat", "lollipop", "dovetail"])
            # Neck can only collide if it's a form cutter cutting radially into a wall (T-Slot, etc.)
            # OR if the axial cut depth penetrates deeper than the flute length into the neck zone!
            neck_is_engaged = is_form_cutter or (flute_length > 0.0 and cut_depth > (flute_length * 1.001))
            if neck_is_engaged and cut_width > (max_reach * 1.001):
                tips.append({
                    "title": "Neck Clearance Collision",
                    "message": (
                        f"Radial cut width ({cut_width:.4f}\" / {cut_width*25.4:.2f} mm) exceeds maximum neck clearance "
                        f"({max_reach:.4f}\" / {max_reach*25.4:.2f} mm). The tool neck will crash into the workpiece wall."
                    ),
                    "type": "critical"
                })

        if cut_depth > stickout and stickout > 0.0:
            tips.append({
                "title": "Tool Holder Collision",
                "message": (
                    f"Axial cut depth ({cut_depth:.4f}\" / {cut_depth*25.4:.2f} mm) exceeds tool stickout "
                    f"({stickout:.4f}\" / {stickout*25.4:.2f} mm). The collet chuck will strike the workpiece."
                ),
                "type": "critical"
            })

        # Ball Nose & Radiused Cutter 3D Contouring Effective Diameter & Speed Diagnostic
        is_ball_or_radiused = any(b in str(geometry).lower() for b in ["ball", "radiused", "bull"]) or "ball" in str(tool_type).lower()
        if is_ball_or_radiused and not is_drilling and diameter > 0.0 and cut_depth > 0.0:
            eff_dia = CuttingKinematics.calc_effective_diameter(diameter, cut_depth, geometry, corner_radius)
            if eff_dia < (diameter * 0.92):
                eff_ratio = eff_dia / diameter
                contact_sfm = physics.calc_sfm(rpm, eff_dia)
                nominal_sfm = physics.calc_sfm(rpm, diameter)
                
                is_ball = "ball" in str(geometry).lower() or "ball" in str(tool_type).lower()
                tip_type = "warning" if (is_ball and eff_ratio < 0.40) else "info"
                speed_line = (
                    f"• **Spindle Speed:** RPM is sized for the contact circle ({contact_sfm:.0f} SFM there); "
                    f"at the full diameter the surface speed is {nominal_sfm:.0f} SFM."
                )
                if is_ball:
                    tips.append({
                        "title": "Ball Mill Effective Diameter & 3D Contouring Dynamics",
                        "message": (
                            f"At your shallow cut depth ({cut_depth:.4f}\" / {cut_depth*25.4:.3f} mm), cutting occurs on the ball radius at an "
                            f"**Effective Cutting Diameter (Deff) of {eff_dia:.4f}\" ({eff_dia*25.4:.3f} mm)** ({eff_ratio*100:.0f}% of nominal {diameter:.4f}\").\n"
                            f"{speed_line}\n"
                            f"• **Zero-SFM Dead Center Trap:** Surface speed is 0 SFM at the tip of the ball. "
                            f"Avoid dragging the tip across flat floors; use sloped toolpaths or a 10°–15° tool tilt so the cut happens on the radius."
                        ),
                        "type": tip_type
                    })
                else:
                    flat = max(0.0, diameter - 2.0 * corner_radius)
                    tips.append({
                        "title": "Corner Radius Effective Diameter",
                        "message": (
                            f"At {cut_depth:.4f}\" ({cut_depth*25.4:.3f} mm) depth, less than the {corner_radius:.4f}\" corner radius, "
                            f"the engaged diameter is **{eff_dia:.4f}\" ({eff_dia*25.4:.3f} mm)** ({eff_ratio*100:.0f}% of nominal), "
                            f"including the {flat:.4f}\" ({flat*25.4:.3f} mm) flat bottom.\n"
                            f"{speed_line}\n"
                            f"• The flat bottom cuts floors cleanly; there is no zero-speed center as on a ball mill."
                        ),
                        "type": tip_type
                    })

        if diameter < 0.125:
            if is_drilling:
                tips.append({
                    "title": "Micro-Drill Dynamics",
                    "message": (
                        "Micro-drills (<1/8\" / 3mm) have fragile web cores and reduced flute gullet volume. "
                        "Ensure high spindle concentricity (<0.0001\" TIR), avoid heavy axial thrust, and use frequent pecks to prevent drill wandering and breakage."
                    ),
                    "type": "warning"
                })
            else:
                tips.append({
                    "title": "Micro-Tool Dynamics",
                    "message": (
                        "Tools under 1/8\" (3mm) have fragile core webs and reduced flute gullet volume. "
                        "Ensure high spindle concentricity (<0.0001\" TIR) and avoid aggressive axial ramping."
                    ),
                    "type": "warning"
                })

        if geometry in ["T-Slot", "Dovetail", "Keyseat", "Woodruff"]:
            tips.append({
                "title": "Form Tool Constraints",
                "message": (
                    f"Because {geometry} cutters engage the full kerf width axially and have narrow neck clearance, chip evacuation is critical. "
                    "Speeds and chiploads have been constrained to prevent chip packing and neck deflection."
                ),
                "type": "warning"
            })

        if is_drilling or "drill" in geometry.lower() or geometry == "Parabolic":
            depth_ratio = cut_depth / diameter if diameter > 0.0 else 0.0
            is_peck_cycle = any(p in str(operation).lower() for p in ["peck", "g83"])
            if depth_ratio > 3.0:
                if not is_peck_cycle:
                    tips.append({
                        "title": "Deep Hole Peck Drilling (G83)",
                        "message": (
                            f"Hole depth is {depth_ratio:.1f}x diameter. At depths over 3xD, chips cannot evacuate continuously up the flutes. "
                            "Switch to a peck drilling cycle (G83) with chip retraction to prevent drill binding and breakage."
                        ),
                        "type": "warning"
                    })
                else:
                    tips.append({
                        "title": "Deep Hole Pecking Parameters",
                        "message": (
                            f"Deep hole drilling active ({depth_ratio:.1f}xD). Ensure initial peck step (Q) is 0.8-1.0xD and decreases to 0.5xD at depth with full chip retraction to clear flutes."
                        ),
                        "type": "info"
                    })

            if tool_type == "Carbide Twist Drill":
                tips.append({
                    "title": "Standard vs HP Solid Carbide Drill",
                    "message": (
                        "Current category is 'Carbide Twist Drill' (conservative baseline). If using a modern high-performance solid carbide CNC drill (e.g. M.A. Ford Twister GP/XD, Guhring, OSG, Mitsubishi), select 'HP Carbide Twist Drill' for higher speeds and feeds."
                    ),
                    "type": "info"
                })

        is_tap_tool = is_tap_tool_type(tool_type) or is_tap_tool_type(operation)
        if is_tap_tool:
            if str(tap_type).lower() == "form":
                is_brittle = any(b in material_family.lower() for b in ["cast iron", "graphite"])
                if is_brittle:
                    tips.append({
                        "title": "Material Incompatible with Form Tapping",
                        "message": (
                            f"{material_family} lacks sufficient ductility (minimum 8-10% elongation required). "
                            "Cold-forming in brittle materials will crumble the thread or fracture the tap. Switch to a cutting tap."
                        ),
                        "type": "critical"
                    })
                else:
                    tips.append({
                        "title": "Form Tapping High-Pressure Lubrication",
                        "message": (
                            "Cold form tapping relies on continuous plastic metal displacement without producing chips. "
                            "Use high-lubricity extreme-pressure (EP) tapping fluid or rich soluble coolant (10-12% concentration) "
                            "to prevent galling and tap seizure in tough materials like stainless steel."
                        ),
                        "type": "info"
                    })
                    tips.append({
                        "title": "Form Tap Pilot Hole Warning",
                        "message": (
                            "Form taps require significantly larger pilot holes than cutting taps (~65-70% thread target). "
                            "Never drill a standard cut-tap hole for a form tap, or the displaced metal will jam and snap the tap."
                        ),
                        "type": "warning"
                    })

        # High Feed Milling (HFM) validation and advisory
        is_hf_op = "high feed" in str(operation).lower() or geometry == "High Feed" or "high feed" in str(geometry).lower() or "high feed" in str(tool_type).lower()
        if is_hf_op:
            is_bullnose = "radiused" in geometry.lower() or "bull" in geometry.lower() or "bull" in tool_type.lower()
            is_dedicated_hf = geometry == "High Feed" or "high feed" in tool_type.lower() or "high feed" in geometry.lower()

            if not is_bullnose and not is_dedicated_hf:
                tips.append({
                    "title": "High Feed Tool Incompatibility",
                    "message": (
                        "High Feed Milling cannot be performed with a Square End Mill. The 90° lead angle creates full uncut chip "
                        "thickness and massive lateral loads, leading to immediate tool failure at high feedrates. Switch tool geometry "
                        "to Bullnose / Radiused or a dedicated High Feed End Mill."
                    ),
                    "type": "critical"
                })
            elif is_bullnose and corner_radius <= 0.001:
                tips.append({
                    "title": "High Feed Geometry Violation",
                    "message": (
                        "High Feed Milling with a Bullnose tool requires a defined Corner Radius to activate Axial Chip Thinning. "
                        "With zero corner radius, cutting edges generate 100% radial deflection force, risking tool fracture. "
                        "Specify your tool's corner radius in the input field."
                    ),
                    "type": "critical"
                })

            if is_dedicated_hf:
                max_hf_doc = 0.05 * diameter
                if cut_depth > (max_hf_doc * 1.05):
                    tips.append({
                        "title": "High Feed DOC Exceeded",
                        "message": (
                            f"Axial Depth of Cut ({cut_depth:.4f}\" / {cut_depth*25.4:.2f} mm) exceeds the maximum high-feed threshold "
                            f"(0.05xD = {max_hf_doc:.4f}\" / {max_hf_doc*25.4:.2f} mm). Beyond this depth, the cut engages the tool heel "
                            f"or vertical transition, overloading the spindle and destroying the cutter."
                        ),
                        "type": "critical"
                    })
            elif is_bullnose and corner_radius > 0.001:
                max_bn_doc = 0.35 * corner_radius
                if cut_depth > (max_bn_doc * 1.05):
                    tips.append({
                        "title": "Bullnose High-Feed Threshold Exceeded",
                        "message": (
                            f"Axial Depth of Cut ({cut_depth:.4f}\" / {cut_depth*25.4:.2f} mm) exceeds 35% of Corner Radius "
                            f"(0.35xR = {max_bn_doc:.4f}\" / {max_bn_doc*25.4:.2f} mm). At deeper cuts, the effective entering angle climbs "
                            f"toward 90°, eliminating axial chip thinning and shifting cutting forces from the rigid Z-axis into lateral tool bending."
                        ),
                        "type": "critical"
                    })

            if "slot" in str(operation).lower() or "window" in str(operation).lower():
                tips.append({
                    "title": "High Feed Window Machining & Tab Preservation",
                    "message": (
                        "High Feed Slotting at shallow DOC directs ~85% of cutting forces downward into the machine table along the rigid Z-axis. "
                        "This near-zero radial force protects thin holding tabs from lateral bending or snapping during part profiling. "
                        "Ensure strong compressed air blast is active to blast chips out of the deep slot channel, avoiding re-cutting."
                    ),
                    "type": "tip"
                })
            else:
                tips.append({
                    "title": "High Feed Dynamics",
                    "message": (
                        "High Feed Milling leverages axial chip thinning via low lead angles (~12°-15°), allowing chip loads 3x-5x higher than "
                        "traditional milling. Up to 85% of cutting forces are axial into the spindle, enabling high feedrates with minimal lateral tool deflection."
                    ),
                    "type": "info"
                })

        # Geometry Sanity Audits: Stickout Ratio, Aluminum Flute Count, and Collet Grip
        is_hole_tool = is_drilling_tool_type(tool_type, geometry)
        if not is_hole_tool and diameter > 0.0:
            l_d = stickout / diameter
            has_relieved_neck = neck_diameter > 0.0 and neck_diameter < (diameter * 0.98)
            if l_d > 4.5 and not has_relieved_neck:
                tips.append({
                    "title": "Severe Tool Stickout Warning",
                    "message": (
                        f"Tool stickout ({stickout:.3f}\" / {stickout*25.4:.1f} mm) is {l_d:.1f}xD. "
                        "Bending deflection scales with the cube of length (L³), risking severe chatter, taper, or tool breakage. "
                        "Choke up in the holder or use a relieved-neck cutter."
                    ),
                    "type": "warning"
                })
            elif l_d > 3.5 and not has_relieved_neck:
                tips.append({
                    "title": "Extended Stickout Notice",
                    "message": (
                        f"Tool stickout is extended ({l_d:.1f}xD). Ensure this matches your actual gage stickout in the holder "
                        "to avoid unpredicted tool deflection."
                    ),
                    "type": "info"
                })

            if flute_length > 0.0 and stickout > 0.0 and flute_length >= (stickout * 0.999):
                tips.append({
                    "title": "Collet Gripping on Flutes Warning",
                    "message": (
                        f"Flute length ({flute_length:.3f}\" / {flute_length*25.4:.1f} mm) meets or exceeds tool stickout ({stickout:.3f}\" / {stickout*25.4:.1f} mm). "
                        "Ensure the holder collet is gripping on the solid cylindrical shank, never directly across cutting flutes."
                    ),
                    "type": "warning"
                })

        if "aluminum" in str(material_family).lower() and flutes >= 4 and not is_hf_op and not is_hole_tool:
            tips.append({
                "title": "Aluminum Flute Evacuation Warning",
                "message": (
                    f"{flutes} flutes selected for aluminum milling. Standard aluminum roughers utilize 2 or 3 flutes to provide "
                    "large chip gullet volume. 4 flutes can rapidly pack chips and weld unless high-pressure through-spindle coolant or air blast is active."
                ),
                "type": "warning"
            })

        hb = physics.resolve_alloy_hardness(material_family, alloy) if alloy else None
        hrc = ASTMHardnessConverter.brinell_to_hrc(hb) if hb else None
        if hrc is not None and hrc > HARD_MILL_ONSET_HRC and not is_drilling:
            sfm_f, ipt_f = hard_milling_factors(hrc)
            if hrc > HARD_MILL_FACTORS[-1][0]:
                tips.append({
                    "title": "Hardness Beyond Vendor Data",
                    "message": (
                        f"~{hrc:.0f} HRC is above the highest hardness in the vendor data behind the hard-milling "
                        f"correction (65 HRC). Speeds are held at the 65 HRC values (SFM x{sfm_f:.2f}, IPT x{ipt_f:.2f}); "
                        "confirm with the tool manufacturer before cutting."
                    ),
                    "type": "critical"
                })
            else:
                tips.append({
                    "title": "Hard Milling Correction Applied",
                    "message": (
                        f"Workpiece ~{hrc:.0f} HRC: speeds scaled SFM x{sfm_f:.2f} and chipload x{ipt_f:.2f} relative to 45 HRC "
                        "(fitted to OSG AE-H and Harvey hardened-steel data). Use a hard-milling grade end mill; "
                        "generic carbide drops far more steeply above 40 HRC."
                    ),
                    "type": "info"
                })

        if not tips:
            tips.append({
                "title": "Optimal Parameters",
                "message": "Dial settings are mathematically safe for this material and geometry. Deflection and heat generation are within optimal boundaries.",
                "type": "tip"
            })

        return tips


# =============================================================================
# 7. UNIFIED FACADE CLASS (GWizardPhysics)
# =============================================================================

class GWizardPhysics:
    """
    Main physics interface providing backward compatibility with app.py,
    Fusion 360 add-ins, and automated testing suites.
    """

    def __init__(self, db_path: str):
        with open(db_path, "r", encoding="utf-8") as f:
            self.db = json.load(f)

        self.sfm_data: List[Dict[str, Any]] = self.db.get("sfm_data", [])
        self.ipt_data: List[List[Any]] = [r for r in self.db.get("ipt_data", []) if r[1] != "Tool"]
        
        self.machinability: Dict[str, Dict[str, Any]] = {}
        for item in self.db.get("machinability_factors", []):
            mat_name = item["material"]
            item_copy = dict(item)
            if "unit_hp" not in item_copy or item_copy["unit_hp"] is None:
                item_copy["unit_hp"] = item_copy.get("mf", 1.0)
            self.machinability[mat_name] = item_copy

        self.specific_alloys: List[Dict[str, Any]] = self.db.get("specific_alloys", [])

        # Load threads database (G-Wizard replica)
        threads_path = os.path.join(os.path.dirname(db_path), "threads_db.json")
        self.threads_db: List[Dict[str, Any]] = []
        if os.path.exists(threads_path):
            with open(threads_path, "r", encoding="utf-8") as f:
                self.threads_db = json.load(f)

    def get_thread_standards(self) -> Dict[str, Any]:
        """Return available thread families, sizes, and classes from the database."""
        desired_family_order = ["ISO Coarse", "ISO Fine", "UNC", "UNF", "UNEF", "NPT", "UN", "UNS"]
        sizes_by_family: Dict[str, List[str]] = {}
        classes_by_family: Dict[str, List[str]] = {}
        
        for item in self.threads_db:
            fam = item.get("family", "")
            size = item.get("size", "")
            th_class = item.get("class", "")
            
            if fam not in sizes_by_family:
                sizes_by_family[fam] = []
            if size and size not in sizes_by_family[fam]:
                sizes_by_family[fam].append(size)
                
            if fam not in classes_by_family:
                classes_by_family[fam] = []
            if th_class and th_class not in classes_by_family[fam]:
                classes_by_family[fam].append(th_class)
                
        active_families = [f for f in desired_family_order if f in sizes_by_family]
        for f in sizes_by_family:
            if f not in active_families:
                active_families.append(f)

        return {
            "families": active_families,
            "sizes_by_family": sizes_by_family,
            "classes_by_family": classes_by_family
        }

    def lookup_thread(
        self,
        family: str,
        size: str,
        thread_class: str = "6H",
        thread_type: str = "Internal"
    ) -> Optional[Dict[str, Any]]:
        """Find a specific thread definition in the database with smart class fallback."""
        clean_size = size.strip()
        # 1. Exact match on family, size, type, class
        for item in self.threads_db:
            if item.get("family") == family and item.get("size", "").strip() == clean_size:
                if item.get("type", "").lower() == thread_type.lower():
                    if item.get("class", "").upper() == thread_class.upper():
                        return item
        # 2. Match on family, size, type
        for item in self.threads_db:
            if item.get("family") == family and item.get("size", "").strip() == clean_size:
                if item.get("type", "").lower() == thread_type.lower():
                    return item
        # 3. Match on family and size only
        for item in self.threads_db:
            if item.get("family") == family and item.get("size", "").strip() == clean_size:
                return item
        return None

    def calc_thread_drill_table(
        self,
        major_dia: float,
        pitch: float,
        is_form: bool = False,
        is_metric: bool = False,
        material_family: str = ""
    ) -> List[Dict[str, Any]]:
        """Delegate thread drill table calculations to CuttingKinematics."""
        return CuttingKinematics.calc_thread_drill_table(major_dia, pitch, is_form, is_metric, material_family)

    def calc_blind_hole_clearance(
        self,
        pitch: float,
        lead_style: str = "form",
        thread_depth: float = 0.0,
        is_metric: bool = False
    ) -> Dict[str, Any]:
        """Delegate blind hole clearance calculations to CuttingKinematics."""
        return CuttingKinematics.calc_blind_hole_clearance(pitch, lead_style, thread_depth, is_metric)

    def get_base_sfm(
        self,
        material: str,
        tool_type: str,
        geometry: str = "Square",
        diameter: Optional[float] = None,
        tap_type: str = "form",
        is_carbide: bool = False
    ) -> float:
        """Lookup base Surface Speed (SFM) from database with geometry/size/tap modifiers."""
        sfm = 500.0
        lookup_tool = tool_type
        t_low = str(tool_type).lower()
        is_saw = geometry in ["T-Slot", "Keyseat", "Woodruff"] or "saw" in t_low or "woodruff" in t_low

        known_sfm_tools = {e["tool"] for e in self.sfm_data}
        if lookup_tool not in known_sfm_tools:
            if "thread" in t_low or geometry == "Thread Mill":
                lookup_tool = "Carbide Thread Mill"
            elif "ream" in t_low or geometry == "Reamer":
                lookup_tool = "HSS Reamer"
            elif is_drilling_tool_type(t_low, geometry) and not is_tap_tool_type(t_low):
                lookup_tool = "Carbide Twist Drill" if is_carbide else "HSS Twist Drill"
            elif is_tap_tool_type(t_low) or tool_type == "Tapping":
                lookup_tool = "Tapping"
            elif is_saw or any(s in t_low for s in ["end", "mill", "slot", "chamfer", "dovetail"]) or geometry in ["Square", "Ball", "Radiused", "High Feed", "T-Slot", "Keyseat", "Woodruff", "Rougher", "V-Bit", "Engraving", "Chamfer", "Chamfer Mill", "Dovetail"]:
                if "hp" in t_low:
                    lookup_tool = "HP Carbide Endmill" if is_carbide else "HP HSS Endmill"
                else:
                    lookup_tool = "Carbide Endmill" if is_carbide else "HSS Endmill"

        for entry in self.sfm_data:
            if entry["material"] == material and entry["tool"] == lookup_tool:
                sfm = float(entry["sfm"])
                if tool_type == "Tapping" or is_tap_tool_type(tool_type):
                    if tap_type == "form":
                        mult_key = "CarbideForm" if is_carbide else "HSSForm"
                        mult = float(entry.get(mult_key, 0.0) or 0.0)
                        if mult <= 0.0:
                            mult = 1.0  # Fallback to standard SFM (never 2.0x in tough alloys)
                        sfm *= mult
                    elif tap_type == "spiral_point":
                        sfm *= 1.15  # Through-hole gun tap
                    elif tap_type == "straight_flute":
                        sfm *= 0.85  # General hand tap
                    elif tap_type == "spiral_flute":
                        sfm *= 1.00  # Standard blind-hole cut tap
                break

        if tool_type != "Tapping" and not is_tap_tool_type(tool_type):
            if is_saw:
                sfm *= 0.75  # G-Wizard GWizFeedSpeedMath.as:522: 25% reduction for Saws & Woodruff
            elif geometry in ["Thread Mill", "Lollipop"]:
                sfm *= 0.50
            elif geometry in ["Drill", "Spot Drill"] and not is_drilling_tool_type(tool_type):
                sfm *= 0.50

        if geometry == "Rougher":
            sfm *= 0.90

        if geometry == "Indexable Mill":
            sfm *= 1.25

        # Pointed chamfer/V-bit tips are fragile: Harvey chamfer-cutter tables top out
        # at ~1000 SFM in 6061 vs ~1200+ for end mills of the same size (~0.8x).
        if geometry in ["V-Bit", "Chamfer", "Chamfer Mill", "Engraving"]:
            sfm *= 0.80

        # Small & Micro-Tool thermal dissipation and chip evacuation scaling:
        # Micro-drills (< 1/4") have fragile web cores and restricted hole chip evacuation,
        # requiring conservative SFM scaling to prevent wandering and binding.
        # Conversely, coated solid carbide endmills (AlTiN, TiAlN) in peripheral/adaptive milling
        # exit into open space each revolution and must maintain proper shear velocity (180-250 SFM)
        # to prevent built-up edge (BUE) and chipping.
        if diameter is not None and 0.0 < diameter < 0.250:
            is_drill_tool = is_drilling_tool_type(tool_type, str(geometry)) and not is_tap_tool_type(tool_type)
            if is_drill_tool:
                scale = max(0.20, (diameter / 0.250) ** 0.50)
                sfm *= scale
            elif diameter < 0.125 and tool_type != "Tapping" and not is_tap_tool_type(tool_type) and not is_saw:
                mat_lower = str(material).lower()
                is_gummy = any(g in mat_lower for g in ["plastic", "lead", "gold", "silver"])
                if is_gummy:
                    scale = max(0.50, (diameter / 0.125) ** 0.25)
                    sfm *= scale

        return sfm

    def calc_tap_drill(
        self,
        major_dia: float,
        pitch: float,
        tap_type: str = "form",
        material_family: str = "Steel",
        is_metric: bool = False
    ) -> Dict[str, Any]:
        """Delegate tap drill calculations to CuttingKinematics."""
        return CuttingKinematics.calc_tap_drill(major_dia, pitch, tap_type, material_family, is_metric)

    def get_base_ipt(
        self,
        material: str,
        tool_type: str,
        diameter: float,
        geometry: str = "Square",
        runout: float = 0.0002,
        cut_depth: float = 0.0,
        cut_width: float = 0.0,
        flutes: int = 4,
        is_carbide: bool = True
    ) -> float:
        """Lookup chipload (Inch Per Tooth) from database with interpolation and geometry scaling."""
        is_saw = geometry in ["T-Slot", "Keyseat", "Woodruff"] or "saw" in str(tool_type).lower() or "woodruff" in str(tool_type).lower()
        diameters = [0.0625, 0.125, 0.1875, 0.25, 0.375, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0]
        ipt = 0.001

        lookup_tool = tool_type
        t_low = str(tool_type).lower()
        is_saw = geometry in ["T-Slot", "Keyseat", "Woodruff"] or "saw" in t_low or "woodruff" in t_low

        known_ipt_tools = {row[1] for row in self.ipt_data if len(row) > 1}
        if lookup_tool not in known_ipt_tools:
            if "thread" in t_low or geometry == "Thread Mill":
                lookup_tool = "Carbide Endmill"
            elif is_drilling_tool_type(t_low, geometry) and not is_tap_tool_type(t_low):
                lookup_tool = "Carbide Twist Drill" if is_carbide else "HSS Twist Drill"
            elif is_tap_tool_type(t_low) or tool_type == "Tapping":
                lookup_tool = "Carbide Twist Drill"
            elif is_saw or any(s in t_low for s in ["end", "mill", "slot", "chamfer", "dovetail"]) or geometry in ["Square", "Ball", "Radiused", "High Feed", "T-Slot", "Keyseat", "Woodruff", "Rougher", "V-Bit", "Engraving", "Chamfer", "Chamfer Mill", "Dovetail"]:
                if "hp" in t_low:
                    lookup_tool = "HP Carbide Endmill" if is_carbide else "HP HSS Endmill"
                else:
                    lookup_tool = "Carbide Endmill" if is_carbide else "HSS Endmill"

        for row in self.ipt_data:
            if row[0] == material and row[1] == lookup_tool:
                if diameter <= diameters[0]:
                    ipt = float(row[2])
                    if diameter < diameters[0] and diameters[0] > 0:
                        ipt *= (diameter / diameters[0])
                elif diameter >= diameters[-1]:
                    ipt = float(row[-1])
                else:
                    for i in range(len(diameters) - 1):
                        d1 = diameters[i]
                        d2 = diameters[i + 1]
                        if d1 <= diameter <= d2:
                            ipt1 = float(row[2 + i])
                            ipt2 = float(row[2 + i + 1])
                            if d1 == d2:
                                ipt = ipt1
                            else:
                                ipt = ipt1 + (ipt2 - ipt1) * ((diameter - d1) / (d2 - d1))
                            break
                break

        if is_saw:
            # G-Wizard GWizFeedSpeedMath.as:2039-2042 & 2246-2291: sawTPIAdjust on base endmill IPT
            base_em_ipt = ipt
            woc = cut_width if cut_width > 0.0 else (diameter * 0.25)
            if woc < 0.5:
                tpi_factor = 10.0
            elif woc < 0.7:
                tpi_factor = 8.0
            elif woc < 1.0:
                tpi_factor = 6.0
            elif woc < 1.34:
                tpi_factor = 5.0
            elif woc < 1.85:
                tpi_factor = 4.0
            elif woc < 3.15:
                tpi_factor = 3.0
            elif woc < 4.92:
                tpi_factor = 2.0
            else:
                tpi_factor = 1.0

            mat_props = self.machinability.get(material, {})
            min_bhn = float(mat_props.get("minBHN", 100.0))
            if min_bhn <= 150:
                tpi_factor *= 1.2

            circumference = diameter * math.pi
            best_teeth = circumference * tpi_factor
            flute_cnt = max(1, flutes)
            tooth_ratio = min(best_teeth / float(flute_cnt), 1.5)

            saw_ipt = base_em_ipt * tooth_ratio
            saw_ipt = max(saw_ipt, 0.0001)
            saw_ipt *= (0.0004 / 0.0013)

            doc = cut_depth if cut_depth > 0.0 else 0.032
            if doc < 0.031:
                saw_ipt *= 0.5

            # Micro-mill bestFinishChipload floor (GWizFeedSpeedMath.as:2426 & 3123)
            # rubChipload = mfgIPT / 3.0 for diameter < 0.250
            rub = (base_em_ipt / 3.0) if diameter < 0.25 else (base_em_ipt / 5.0)
            best_finish = min(rub, 0.001) * 1.1

            return max(best_finish, saw_ipt)

        if not is_tap_tool_type(tool_type):
            # Dovetails share the lollipop's narrow neck and angled edge; Harvey dovetail
            # chiploads run ~50% of an end mill of the same diameter.
            if geometry in ["Thread Mill", "Lollipop", "Dovetail"]:
                ipt *= 0.50
            elif geometry in ["Drill", "Spot Drill", "Parabolic"] and not is_drilling_tool_type(tool_type):
                ipt *= 0.50

        if geometry == "Rougher":
            ipt *= 1.38

        if geometry == "Indexable Mill":
            ipt *= 1.25

        return ipt

    def calc_effective_diameter(self, diameter: float, cut_depth: float, geometry: str = "Square", corner_radius: float = 0.0) -> float:
        return CuttingKinematics.calc_effective_diameter(diameter, cut_depth, geometry, corner_radius)

    def calc_rpm(self, sfm: float, diameter: float, max_rpm: float = 16000.0) -> float:
        return CuttingKinematics.calc_rpm(sfm, diameter, max_rpm)

    def calc_sfm(self, rpm: float, diameter: float) -> float:
        return CuttingKinematics.calc_sfm(rpm, diameter)

    def apply_aggressiveness(self, sfm: float, ipt: float, aggressiveness: float = 0.5) -> Tuple[float, float]:
        scalar = 0.70 + (aggressiveness * 0.60)
        return sfm * scalar, ipt * scalar

    def calc_feedrate(self, rpm: float, flutes: int, chipload: float) -> float:
        return CuttingKinematics.calc_feedrate(rpm, flutes, chipload)

    def calc_mrr(self, cut_depth: float, cut_width: float, feedrate: float, geometry: str = "Square", diameter: float = 0.5) -> float:
        return CuttingMechanics.calc_mrr(cut_depth, cut_width, feedrate, geometry=geometry, diameter=diameter)

    def radial_chip_thinning_factor(self, cut_width: float, diameter: float) -> float:
        return CuttingKinematics.radial_chip_thinning_factor(cut_width, diameter)

    def calc_hem_thermal_sfm_multiplier(self, cut_width: float, diameter: float, operation: str = "Roughing") -> float:
        return CuttingKinematics.calc_hem_thermal_sfm_multiplier(cut_width, diameter, operation)

    def calc_adjusted_chipload(
        self,
        base_ipt: float,
        cut_depth: float,
        cut_width: float,
        diameter: float,
        effective_diameter: float,
        is_micro_tool: bool = False,
        operation: str = "Roughing",
        geometry: str = "Square",
        coating: str = "AlTiN",
        tool_type: str = "end mill",
        corner_radius: float = 0.0
    ) -> float:
        adjusted_ipt = base_ipt

        # If tool is a drill or hole tool, bypass milling adjustments (RCTF, ACTF, adaptive/finishing multipliers)
        if "drill" in geometry.lower() or geometry == "Parabolic" or "drill" in str(tool_type).lower() or "annular" in str(tool_type).lower():
            depth_ratio = cut_depth / diameter if diameter > 0.0 else 0.0
            if depth_ratio > 3.0:
                if geometry == "Parabolic":
                    if depth_ratio >= 10.0:
                        adjusted_ipt *= 0.90
                else:
                    if depth_ratio >= 7.0:
                        scale = 0.80 - (0.0875 * (depth_ratio - 7.0))
                    else:
                        scale = 1.0 - (0.05 * (depth_ratio - 3.0))
                    adjusted_ipt *= max(0.10, scale)
            return adjusted_ipt

        if "reamer" in str(tool_type).lower() or "ream" in str(geometry).lower() or "ream" in str(operation).lower():
            return adjusted_ipt

        is_saw = geometry in ["T-Slot", "Keyseat", "Woodruff"] or "saw" in str(tool_type).lower() or "woodruff" in str(tool_type).lower()
        if is_saw:
            # G-Wizard: "chipThin": "no" for Saws & Woodruff Cutters. Chip thinning is handled via sawTPIAdjust
            return adjusted_ipt

        op_low = operation.lower()
        if "finish" in op_low:
            if "semi" in op_low:
                adjusted_ipt *= 0.80
            else:
                adjusted_ipt *= 0.60
        elif "slot" in op_low:
            cut_width = diameter

        rctf = self.radial_chip_thinning_factor(cut_width, diameter)
        actf = CuttingKinematics.axial_chip_thinning_factor(cut_depth, diameter, geometry=geometry, corner_radius=corner_radius, operation=operation)

        if actf == 1.0 and 0.001 < effective_diameter < diameter and "ball" in geometry.lower():
            actf = min(diameter / effective_diameter, 5.0)

        combined_tf = min(rctf * actf, 5.5)
        adjusted_ipt *= combined_tf

        if "adaptive" in op_low or "trochoidal" in op_low:
            adjusted_ipt *= 1.30

        return adjusted_ipt

    def get_coating_multiplier(self, coating: str, material_family: str) -> float:
        if coating == "Uncoated" or not material_family:
            return 1.0

        mat_lower = material_family.lower()
        is_aluminum = "aluminum" in mat_lower
        is_ferrous = any(m in mat_lower for m in ["steel", "iron", "stainless"])
        is_titanium = any(m in mat_lower for m in ["titanium", "cobalt", "nickel"])

        if coating in ["TiAlN", "AlTiN"]:
            if is_aluminum:
                return 0.80
            if is_ferrous or is_titanium:
                return 1.40
            return 1.20

        if coating in ["Diamond", "DLC", "PCD"]:
            if is_ferrous or is_titanium:
                return 0.50
            if is_aluminum or "graphite" in mat_lower or "plastic" in mat_lower:
                return 2.00
            return 1.50

        if coating == "ZrN":
            if is_aluminum or "brass" in mat_lower or "copper" in mat_lower:
                return 1.40
            return 1.00

        if coating == "TiCN":
            return 1.30 if is_ferrous else 1.10

        if coating == "TiN":
            return 1.20 if is_ferrous else 1.05

        return 1.0

    def calc_ramping(
        self,
        family_name: str,
        diameter: float,
        feedrate: float,
        geometry: str = "Square",
        flutes: int = 4,
        aggressiveness: float = 0.5,
        tool_type: str = ""
    ) -> Tuple[float, float, float]:
        family_str = str(family_name).lower()
        if any(m in family_str for m in ["steel", "titanium", "nickel", "iron"]):
            angle = 1.5
            ramp_feed = feedrate * 0.50
            plunge_feed = feedrate * 0.25
        elif any(m in family_str for m in ["aluminum", "plastic", "wood", "magnesium", "brass"]):
            angle = 3.0
            ramp_feed = feedrate * 0.75
            plunge_feed = feedrate * 0.50
        else:
            angle = 2.0
            ramp_feed = feedrate * 0.60
            plunge_feed = feedrate * 0.35

        if flutes <= 2:
            angle *= 1.30
        elif flutes >= 5:
            angle *= 0.75

        aggr_scalar = 0.70 + (aggressiveness * 0.60)
        angle *= aggr_scalar

        is_hole = is_drilling_tool_type(tool_type, geometry)

        if is_hole:
            angle = 90.0
            ramp_feed = feedrate
            is_spot = "spot" in str(geometry).lower() or "spot" in str(tool_type).lower() or "center" in str(tool_type).lower()
            plunge_feed = feedrate * (0.50 if is_spot else 1.0)
        elif geometry in ["Ball", "Radiused", "Lollipop"]:
            angle += 0.50
        elif geometry == "High Feed" or "high feed" in str(geometry).lower() or "high feed" in str(tool_type).lower():
            angle = min(angle, 1.5)
        elif geometry in ["T-Slot", "Dovetail", "Keyseat", "Woodruff", "Engraving"]:
            angle = 0.0
            ramp_feed = 0.0
            if plunge_feed <= 0.0:
                plunge_feed = feedrate * 0.25

        if not is_hole and 0.0 < diameter < 0.125:
            angle *= max(0.30, diameter / 0.125)

        # Safety floor: whenever feedrate is positive, plunge and ramp feed must never be zero
        if feedrate > 0.0:
            if plunge_feed <= 0.0:
                plunge_feed = ramp_feed if ramp_feed > 0.0 else feedrate * 0.25
            if ramp_feed <= 0.0 and geometry not in ["T-Slot", "Dovetail", "Keyseat", "Woodruff", "Engraving"]:
                ramp_feed = feedrate * 0.50

        return angle, ramp_feed, plunge_feed

    def match_alloy(self, material_family: str, alloy_name: str) -> Optional[Dict[str, Any]]:
        """
        Resolve a user alloy string ("6061-T6", "6061 (T6, T651)", "4140") to one row of
        specific_alloys within the given family only.

        Score = alloy-name match + matched condition tokens (word-boundary). Ties, and bare
        alloy names with several conditions, resolve to the HARDEST row so speeds err low.
        """
        target = str(alloy_name or "").strip().lower()
        if not target:
            return None

        def norm(s: str) -> str:
            return " ".join(re.sub(r'[()\[\],;/\-]+', ' ', s).split())

        best, best_key = None, None
        for a in self.specific_alloys:
            if a.get("family") != material_family:
                continue
            base = str(a.get("alloy", "")).strip().lower()
            if not base or not re.search(r'(?<![a-z0-9])' + re.escape(base) + r'(?![a-z0-9])', target):
                continue
            condition = str(a.get("condition", "")).strip().lower()
            # Whatever remains after removing the alloy name is the user's condition text.
            exact = bool(condition) and norm(target.replace(base, " ", 1)) == norm(condition)
            tokens = [t.strip() for t in re.split(r'[,/;]', condition) if t.strip()]
            cond_hits = sum(1 for t in tokens
                            if re.search(r'(?<![a-z0-9])' + re.escape(t) + r'(?![a-z0-9])', target))
            hb = ASTMHardnessConverter.parse_hardness(a.get("hardness")) or 0.0
            key = (len(base), exact, cond_hits, (cond_hits - len(tokens)) if cond_hits else 0, hb)
            if best_key is None or key > best_key:
                best, best_key = a, key
        return best

    def resolve_alloy_hardness(self, material_family: str, alloy_name: str) -> Optional[float]:
        """Brinell hardness for an alloy string: DB row first, else an explicit 'NN HRC' in the text."""
        row = self.match_alloy(material_family, alloy_name)
        hb = ASTMHardnessConverter.parse_hardness(row.get("hardness")) if row else None
        if not hb and "hrc" in str(alloy_name).lower():
            hb = ASTMHardnessConverter.parse_hardness(alloy_name)
        return hb

    def apply_alloy_hardness_scaling(
        self,
        material_family: str,
        alloy_name: str,
        sfm: float,
        ipt: float,
        is_carbide: bool = True
    ) -> Tuple[float, float]:
        """
        Dynamically scale SFM based on the alloy's Brinell Hardness (HB).
        Supports HRC, HB, and range conversions via ASTM E140.
        Uses G-Wizard's genuine bounded linear adjustment model (adjSFMForHardness).
        """
        if not alloy_name or not material_family:
            return sfm, ipt

        alloy_hardness = None
        norm_target = alloy_name.strip().lower()

        alloy_hardness = self.resolve_alloy_hardness(material_family, alloy_name)
        if not alloy_hardness:
            return sfm, ipt

        mat_props = self.machinability.get(material_family)
        if not mat_props:
            return sfm, ipt

        min_bhn = float(mat_props.get("minBHN", 1.0))
        max_bhn = float(mat_props.get("maxBHN", 450.0))
        sfm_range = float(mat_props.get("sfmrange", 0.0) if is_carbide else (mat_props.get("sfmrangehss", 0.0) or mat_props.get("sfmrange", 0.0)))

        # G-Wizard genuine bounded linear adjustment (GWizFeedSpeedMath.as:356-370)
        # adjSFMForHardness(param1: base_sfm, param2: sfmrange, param3: minBHN, param4: maxBHN, param5: bhn)
        # Above HARD_MILL_ONSET_HRC, GWizard's linear model is used only up to the onset and the
        # vendor-fitted curve takes over for both SFM and IPT (see HARD_MILL_FACTORS).
        hrc = ASTMHardnessConverter.brinell_to_hrc(float(alloy_hardness))
        is_hard_milling = hrc is not None and hrc > HARD_MILL_ONSET_HRC
        gw_bhn = ASTMHardnessConverter.hrc_to_brinell(HARD_MILL_ONSET_HRC) if is_hard_milling else float(alloy_hardness)

        if sfm_range > 0 and max_bhn > min_bhn:
            range_adj = sfm_range * 0.7
            range_adj = min(0.4 * sfm, range_adj)
            clamped_bhn = min(max_bhn, max(min_bhn, gw_bhn))
            bhn_span = max_bhn - min_bhn
            norm = (clamped_bhn - min_bhn) / bhn_span
            adj = (0.5 - norm) * range_adj
            sfm = max(10.0, sfm + adj)

        if is_hard_milling:
            sfm_f, ipt_f = hard_milling_factors(hrc)
            sfm *= sfm_f
            ipt *= ipt_f

        return sfm, ipt

    def apply_chatter_penalty(
        self,
        sfm: float,
        ipt: float,
        diameter: float,
        stickout: float,
        is_drilling: bool = False,
        is_saw_woodruff: bool = False,
        flute_length: float = 0.0
    ) -> Tuple[float, float]:
        """Scales SFM and IPT based on Length-to-Diameter (L/D) ratio."""
        if is_saw_woodruff:
            # G-Wizard GWizFeedsSpeeds2.as:1604: this.fsm.adjustSFMForLength = false
            return sfm, ipt

        if diameter <= 0.0 or stickout <= 0.0:
            return sfm, ipt

        ld_ratio = stickout / diameter
        fl_ratio = (flute_length / diameter) if (diameter > 0.0 and flute_length > 0.0) else 0.0
        critical_ld = 8.0 if is_drilling else max(3.5, fl_ratio * 1.15)

        if ld_ratio <= critical_ld:
            return sfm, ipt

        overage = ld_ratio - critical_ld
        sfm_mult = max(0.20, 1.0 - (overage * 0.15))
        ipt_mult = max(0.15, 1.0 - (overage * 0.20))

        return sfm * sfm_mult, ipt * ipt_mult

    def get_minimum_chip_thickness(self, coating: str, tool_type: str = "end mill", diameter: float = 0.5) -> float:
        return CuttingKinematics.get_minimum_chip_thickness(coating, tool_type, diameter)

    def get_true_chip_thickness(self, ipt: float, cut_width: float, diameter: float) -> float:
        return CuttingKinematics.get_true_chip_thickness(ipt, cut_width, diameter)

    def calc_springback_and_deflection(
        self,
        material_family: str,
        diameter: float,
        cut_depth: float,
        cut_width: float,
        feedrate: float,
        rpm: float,
        flutes: int,
        deflection_inches: float,
        alloy: str = ""
    ) -> Tuple[float, float, float]:
        """
        Calculates material springback (inches), total wall dimensional error (deflection + springback),
        and recommended negative tool wear compensation offset (inches).
        
        Returns:
            (springback_inches, total_error_inches, wear_comp_offset_inches)
        """
        mat_props = self.machinability.get(material_family, {})
        sb_factor = mat_props.get("springback_factor", 0.0002)
        if "nitronic 60" in str(alloy).lower():
            sb_factor = max(sb_factor, 0.0006)
        elif "black titanium" in str(alloy).lower():
            sb_factor = max(sb_factor, 0.0010)
        unit_hp = mat_props.get("unit_hp", 1.0)

        _, radial_force, _, _ = CuttingMechanics.calc_cutting_forces(
            diameter, cut_depth, cut_width, feedrate, rpm, flutes, unit_hp
        )
        force_mod = 0.75 + 0.25 * min(3.0, max(0.2, radial_force / 20.0))
        springback_inches = sb_factor * force_mod
        total_error = deflection_inches + springback_inches
        wear_comp = -total_error

        return springback_inches, total_error, wear_comp

    def generate_advanced_strategies(
        self,
        material_family: str,
        diameter: float,
        cut_depth: float,
        cut_width: float,
        feedrate: float,
        rpm: float,
        flutes: int,
        coating: str,
        deflection_inches: float,
        tool_type: str = "end mill",
        stickout: float = 1.5,
        geometry: str = "Square",
        flute_length: float = 1.0,
        operation: str = "Roughing",
        tap_type: str = "form",
        neck_diameter: float = 0.0,
        alloy: str = "",
        corner_radius: float = 0.0
    ) -> List[Dict[str, str]]:
        return AdvisoryEngine.generate_tips(
            self, material_family, diameter, cut_depth, cut_width, feedrate, rpm, flutes,
            coating, deflection_inches, tool_type, stickout, geometry, flute_length, operation,
            tap_type=tap_type, neck_diameter=neck_diameter, alloy=alloy, corner_radius=corner_radius
        )

    def tool_deflection(
        self,
        diameter: float,
        shank_size: float,
        stickout: float,
        cut_depth: float,
        cut_width: float,
        feedrate: float,
        rpm: float,
        flutes: int,
        is_carbide: bool = True,
        material_family: Optional[str] = None,
        helix_angle: float = 30.0,
        neck_length: float = 0.5,
        taper_angle: float = 0.0,
        flute_length: float = 1.0,
        neck_diameter: Optional[float] = None,
        operation: str = "Roughing",
        geometry: str = "Square",
        corner_radius: float = 0.0
    ) -> float:
        """
        Calculates tool tip deflection (inches) from cutting forces and stepped
        cantilever beam mechanics.
        """
        if rpm <= 0.0 or diameter <= 0.0 or cut_depth <= 0.0 or cut_width <= 0.0 or feedrate <= 0.0:
            return 0.0

        unit_hp = 1.0
        if material_family and material_family in self.machinability:
            unit_hp = self.machinability[material_family].get("unit_hp", 1.0)

        _, radial_force, deflection_force, _ = CuttingMechanics.calc_cutting_forces(
            diameter, cut_depth, cut_width, feedrate, rpm, flutes, unit_hp, helix_angle,
            operation=operation, geometry=geometry, corner_radius=corner_radius
        )

        # For finishing operations, wall dimensional error is governed by the radial force pushing the cutter normal to the wall
        applied_force = radial_force if "finish" in str(operation).lower() else deflection_force

        return BeamDeflectionEngine.calculate_deflection(
            cutting_force_lbs=applied_force,
            diameter=diameter,
            shank_diameter=shank_size,
            stickout=stickout,
            flute_length=flute_length,
            neck_diameter=neck_diameter,
            neck_length=neck_length,
            taper_angle=taper_angle,
            flutes=flutes,
            helix_angle=helix_angle,
            is_carbide=is_carbide
        )

    def recommend_cut_parameters(
        self,
        diameter: float,
        shank_size: float,
        stickout: float,
        flutes: int,
        rpm: float,
        base_ipt: float,
        is_carbide: bool = True,
        operation: str = "Roughing",
        aggressiveness: float = 0.5,
        geometry: str = "Square",
        cutter_thickness: float = 0.125,
        max_hp: float = 10.0,
        material_family: Optional[str] = None,
        helix_angle: float = 30.0,
        neck_length: float = 0.5,
        taper_angle: float = 0.0,
        flute_length: float = 1.0,
        neck_diameter: Optional[float] = None,
        corner_radius: float = 0.0,
        details: Optional[Dict[str, Any]] = None
    ) -> Tuple[float, float, float]:
        return OptimizationEngine.recommend_cut_parameters(
            self, diameter, shank_size, stickout, flutes, rpm, base_ipt, is_carbide,
            operation, aggressiveness, geometry, cutter_thickness, max_hp, material_family,
            helix_angle, neck_length, taper_angle, flute_length, neck_diameter,
            corner_radius=corner_radius, details=details
        )

    def calc_deflection_limit(
        self,
        diameter: float,
        operation: str = "Roughing",
        aggressiveness: float = 0.5,
        is_carbide: bool = True
    ) -> float:
        return CuttingMechanics.calc_deflection_limit(
            diameter, operation=operation, aggressiveness=aggressiveness, is_carbide=is_carbide
        )

