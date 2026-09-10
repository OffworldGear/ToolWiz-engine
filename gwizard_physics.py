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

import math
import json
import logging
import re
from typing import Dict, List, Tuple, Any, Optional

logger = logging.getLogger("ToolWizPhysics")


# =============================================================================
# 1. HARDNESS & METALLURGY CONVERSION (ASTM E140)
# =============================================================================

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
    def axial_chip_thinning_factor(cut_depth: float, diameter: float, geometry: str = "Square", corner_radius: float = 0.0) -> float:
        """
        Calculates Axial Chip Thinning Factor (ACTF) for round/radiused insert geometry
        where depth of cut (ap) is less than insert radius.
        """
        if cut_depth <= 0.0 or diameter <= 0.0:
            return 1.0

        effective_radius = 0.0
        if "Ball" in geometry:
            effective_radius = diameter / 2.0
        elif ("Radiused" in geometry or "Bull" in geometry) and corner_radius > 0.0:
            effective_radius = corner_radius

        if effective_radius > 0.0 and cut_depth < effective_radius:
            eff_dia = 2.0 * math.sqrt(max(1e-6, effective_radius**2 - (effective_radius - cut_depth)**2))
            if eff_dia > 0.0:
                actf = diameter / eff_dia
                return min(actf, 5.0)

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
        helix_angle: float = 30.0
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
        neck_diameter: Optional[float] = None
    ) -> Tuple[float, float, float]:
        default_max_deflect = diameter * 0.002
        target_deflection = default_max_deflect * (0.2 + aggressiveness)

        op_low = operation.lower()
        if "finish" in op_low:
            target_woc = diameter * 0.05
        elif "slot" in op_low:
            target_woc = diameter
        elif "adaptive" in op_low or "trochoidal" in op_low:
            target_woc = diameter * 0.15
        elif "face" in op_low:
            target_woc = diameter * 0.75
        else:
            target_woc = diameter * 0.50

        if geometry in ["T-Slot", "Dovetail", "Keyseat"]:
            return cutter_thickness, min(diameter * 0.35, target_woc), target_deflection

        max_doc = min(diameter * 4.0, flute_length)
        min_doc = max(diameter * 0.02, 0.0005)
        step = max(diameter * 0.02, 0.0005)

        best_doc = min_doc
        current_doc = min_doc

        unit_hp = 1.0
        if material_family and material_family in physics.machinability:
            unit_hp = physics.machinability[material_family].get("unit_hp", 1.0)

        while current_doc <= max_doc:
            adj_ipt = physics.calc_adjusted_chipload(
                base_ipt, current_doc, target_woc, diameter, diameter, operation=operation, geometry=geometry
            )
            feed = physics.calc_feedrate(rpm, flutes, adj_ipt)

            deflect = physics.tool_deflection(
                diameter, shank_size, stickout, current_doc, target_woc, feed, rpm, flutes,
                is_carbide=is_carbide, material_family=material_family, helix_angle=helix_angle,
                neck_length=neck_length, taper_angle=taper_angle, flute_length=flute_length,
                neck_diameter=neck_diameter
            )

            _, _, _, est_hp = CuttingMechanics.calc_cutting_forces(
                diameter, current_doc, target_woc, feed, rpm, flutes, unit_hp, helix_angle
            )

            if deflect >= target_deflection or est_hp >= max_hp:
                break

            best_doc = current_doc
            current_doc += step

        return best_doc, target_woc, target_deflection


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
        geometry: str = "Square"
    ) -> List[Dict[str, str]]:
        tips: List[Dict[str, str]] = []
        if rpm <= 0.0 or flutes <= 0 or diameter <= 0.0:
            return tips

        mat_props = physics.machinability.get(material_family, {})
        is_work_hardening = mat_props.get("work_hardening", False)
        sb_factor = mat_props.get("springback_factor", 0.0002)
        unit_hp = mat_props.get("unit_hp", 1.0)

        mat_lower = material_family.lower() if material_family else ""
        is_highly_elastic = any(m in mat_lower for m in ["plastic", "titanium", "wood", "zirconium"])

        mct = CuttingKinematics.get_minimum_chip_thickness(coating, tool_type, diameter)
        ipt = feedrate / (rpm * flutes)
        tct = CuttingKinematics.get_true_chip_thickness(ipt, cut_width, diameter)

        # 5% tolerance prevents floating point precision artifacts on threshold cuts
        if tct < (mct * 0.95):
            tips.append({
                "title": "Rubbing & Heat Trap Warning",
                "message": (
                    f"Your True Chip Thickness ({tct:.4f}\" / {tct*25.4:.3f} mm) is smaller than the edge "
                    f"radius of your {coating} tool (~{mct:.4f}\" / {mct*25.4:.3f} mm). The tool will plow and rub "
                    f"rather than shear the metal, causing rapid heat buildup and premature failure. Increase feedrate (IPT) "
                    f"or switch to a sharper Uncoated/Polished tool."
                ),
                "type": "critical"
            })

        _, radial_force, _, _ = CuttingMechanics.calc_cutting_forces(
            diameter, cut_depth, cut_width, feedrate, rpm, flutes, unit_hp
        )
        springback_inches = sb_factor * (radial_force / 100.0) * (cut_width / diameter)
        total_error = deflection_inches + springback_inches

        if total_error > 0.0005:
            tips.append({
                "title": "Dimensional Compensation",
                "message": (
                    f"Expect the part to cut +{total_error:.4f}\" ({total_error*25.4:.3f} mm) oversized due to "
                    f"Tool Deflection ({deflection_inches:.4f}\" / {deflection_inches*25.4:.3f} mm) and Material Springback "
                    f"({springback_inches:.4f}\" / {springback_inches*25.4:.3f} mm). Apply a Negative Radial Stock-to-Leave in CAM."
                ),
                "type": "warning"
            })

        if total_error > 0.0005 and is_work_hardening:
            if total_error < mct:
                tips.append({
                    "title": "Spring Pass Trap",
                    "message": (
                        f"Do NOT use a 'Spring Pass' to clean up the {total_error:.4f}\" ({total_error*25.4:.3f} mm) "
                        f"deflection. In work-hardening alloys like {material_family}, taking a cut smaller than the Minimum "
                        f"Chip Thickness ({mct:.4f}\" / {mct*25.4:.3f} mm) will rub and destroy the cutting edge."
                    ),
                    "type": "critical"
                })
            else:
                tips.append({
                    "title": "Work-Hardening Cleanup",
                    "message": (
                        f"{material_family} is highly prone to work-hardening. Ensure your cleanup pass is at least "
                        f"{mct:.4f}\" ({mct*25.4:.3f} mm) thick so the cutting edge penetrates past the hardened skin."
                    ),
                    "type": "info"
                })

        if is_highly_elastic and cut_width < diameter * 0.15:
            tips.append({
                "title": "Conventional Milling for Finishing",
                "message": (
                    f"Because {material_family} has high elastic recovery, Conventional Milling on your final light pass "
                    f"naturally pulls the cutter into the wall, counteracting springback and giving truer dimensions."
                ),
                "type": "tip"
            })

        is_drilling = any(d in tool_type.lower() for d in ["drill", "tap", "reamer"])
        ld_ratio = stickout / diameter if diameter > 0.0 else 0.0
        critical_ld = 8.0 if is_drilling else 3.0
        if ld_ratio > critical_ld:
            tips.append({
                "title": "Resonance & Chatter Penalty",
                "message": (
                    f"Tool stickout is {ld_ratio:.1f}x diameter. Tools over {critical_ld}xD act like tuning forks, "
                    f"inducing self-excited chatter. Feeds and speeds have been scaled down to stabilize the cut."
                ),
                "type": "warning"
            })

        if diameter < 0.125:
            tips.append({
                "title": "Micro-Tool Dynamics",
                "message": (
                    "Tools under 1/8\" (3mm) have fragile core webs and reduced flute gullet volume. "
                    "Ensure high spindle concentricity (<0.0001\" TIR) and avoid aggressive axial ramping."
                ),
                "type": "warning"
            })

        if geometry in ["T-Slot", "Dovetail", "Keyseat"]:
            tips.append({
                "title": "Form Tool Constraints",
                "message": (
                    f"Because {geometry} cutters must take 100% radial engagement by design, chip evacuation is critical. "
                    "Speeds and chiploads have been constrained to prevent chip packing."
                ),
                "type": "warning"
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

    def get_base_sfm(self, material: str, tool_type: str, geometry: str = "Square", diameter: Optional[float] = None) -> float:
        """Lookup base Surface Speed (SFM) from database with geometry/size modifiers."""
        sfm = 500.0
        for entry in self.sfm_data:
            if entry["material"] == material and entry["tool"] == tool_type:
                sfm = float(entry["sfm"])
                break

        if geometry in ["T-Slot", "Thread Mill", "Lollipop", "Drill", "Spot Drill"]:
            sfm *= 0.50

        if geometry == "Rougher":
            sfm *= 0.90

        if geometry == "Indexable Mill":
            sfm *= 1.25

        # Small & Micro-Tool thermal dissipation and chip evacuation scaling:
        # Below 1/4" (0.250"), thermal conduction down the slender carbide shank drops,
        # increasing chip welding risk in sticky materials like aluminum.
        if diameter is not None and 0.0 < diameter < 0.250:
            scale = max(0.20, (diameter / 0.250) ** 0.50)
            sfm *= scale

        return sfm

    def get_base_ipt(self, material: str, tool_type: str, diameter: float, geometry: str = "Square", runout: float = 0.0002) -> float:
        """Lookup chipload (Inch Per Tooth) from database with interpolation and geometry scaling."""
        diameters = [0.0625, 0.125, 0.1875, 0.25, 0.375, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0]
        ipt = 0.001

        for row in self.ipt_data:
            if row[0] == material and row[1] == tool_type:
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

        if geometry in ["T-Slot", "Thread Mill", "Lollipop", "Drill", "Spot Drill", "Parabolic"]:
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
        tool_type: str = "end mill"
    ) -> float:
        adjusted_ipt = base_ipt

        op_low = operation.lower()
        if "finish" in op_low:
            adjusted_ipt *= 0.60
        elif "slot" in op_low:
            cut_width = diameter

        adjusted_ipt *= self.radial_chip_thinning_factor(cut_width, diameter)

        if 0.001 < effective_diameter < diameter:
            actf = diameter / effective_diameter
            adjusted_ipt *= min(actf, 5.0)

        if "adaptive" in op_low or "trochoidal" in op_low:
            adjusted_ipt *= 1.30

        if "drill" in geometry.lower() or geometry == "Parabolic":
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
        aggressiveness: float = 0.5
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

        if "Drill" in geometry or geometry == "Parabolic":
            angle = 90.0
            ramp_feed = feedrate
            plunge_feed = feedrate * (0.50 if geometry == "Spot Drill" else 1.0)
        elif geometry in ["Ball", "Radiused", "Lollipop"]:
            angle += 0.50
        elif geometry in ["T-Slot", "Dovetail", "Keyseat", "Woodruff", "Engraving"]:
            angle = 0.0
            ramp_feed = 0.0

        if 0.0 < diameter < 0.125:
            angle *= max(0.30, diameter / 0.125)

        return angle, ramp_feed, plunge_feed

    def apply_alloy_hardness_scaling(
        self,
        material_family: str,
        alloy_name: str,
        sfm: float,
        ipt: float
    ) -> Tuple[float, float]:
        """
        Dynamically scale SFM and IPT based on the alloy's Brinell Hardness (HB).
        Supports HRC, HB, and range conversions via ASTM E140.
        """
        if not alloy_name or not material_family:
            return sfm, ipt

        alloy_hardness = None
        norm_target = alloy_name.strip().lower()

        for a in self.specific_alloys:
            if a.get("family") == material_family:
                base_alloy = str(a.get("alloy", "")).strip().lower()
                condition = str(a.get("condition", "")).strip().lower()
                combined = f"{base_alloy} ({condition})".lower()

                if norm_target in [base_alloy, combined] or base_alloy in norm_target:
                    parsed_hb = ASTMHardnessConverter.parse_hardness(a.get("hardness"))
                    if parsed_hb:
                        alloy_hardness = parsed_hb
                        break

        if not alloy_hardness:
            if "hrc" in norm_target:
                alloy_hardness = ASTMHardnessConverter.parse_hardness(norm_target)

        if not alloy_hardness:
            return sfm, ipt

        mat_props = self.machinability.get(material_family)
        if not mat_props:
            return sfm, ipt

        min_bhn = float(mat_props.get("minBHN", 1.0))
        cexp = float(mat_props.get("cexp", 10.0))

        if alloy_hardness <= min_bhn:
            return sfm, ipt

        sfm_mult = (min_bhn / alloy_hardness) ** (cexp / 15.0)
        ipt_mult = (min_bhn / alloy_hardness) ** (cexp / 25.0)

        sfm_mult = max(0.05, min(1.0, sfm_mult))
        ipt_mult = max(0.20, min(1.0, ipt_mult))

        return sfm * sfm_mult, ipt * ipt_mult

    def apply_chatter_penalty(
        self,
        sfm: float,
        ipt: float,
        diameter: float,
        stickout: float,
        is_drilling: bool = False
    ) -> Tuple[float, float]:
        """Scales SFM and IPT based on Length-to-Diameter (L/D) ratio."""
        if diameter <= 0.0 or stickout <= 0.0:
            return sfm, ipt

        ld_ratio = stickout / diameter
        critical_ld = 8.0 if is_drilling else 3.0

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
        geometry: str = "Square"
    ) -> List[Dict[str, str]]:
        return AdvisoryEngine.generate_tips(
            self, material_family, diameter, cut_depth, cut_width, feedrate, rpm, flutes,
            coating, deflection_inches, tool_type, stickout, geometry
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
        neck_diameter: Optional[float] = None
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

        _, _, deflection_force, _ = CuttingMechanics.calc_cutting_forces(
            diameter, cut_depth, cut_width, feedrate, rpm, flutes, unit_hp, helix_angle
        )

        return BeamDeflectionEngine.calculate_deflection(
            cutting_force_lbs=deflection_force,
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
        neck_diameter: Optional[float] = None
    ) -> Tuple[float, float, float]:
        return OptimizationEngine.recommend_cut_parameters(
            self, diameter, shank_size, stickout, flutes, rpm, base_ipt, is_carbide,
            operation, aggressiveness, geometry, cutter_thickness, max_hp, material_family,
            helix_angle, neck_length, taper_angle, flute_length, neck_diameter
        )
