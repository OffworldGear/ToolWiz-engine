import math
import json
import logging

class GWizardPhysics:
    def __init__(self, db_path):
        with open(db_path, 'r', encoding='utf-8') as f:
            self.db = json.load(f)
            
        self.sfm_data = self.db.get("sfm_data", [])
        self.ipt_data = self.db.get("ipt_data", [])
        self.machinability = {item["material"]: item for item in self.db.get("machinability_factors", [])}
        self.specific_alloys = self.db.get("specific_alloys", [])
        
    def get_base_sfm(self, material, tool_type, geometry="Square", diameter=None):
        """Lookup base Surface Feet per Minute (SFM) from DB"""
        sfm = 500
        for entry in self.sfm_data:
            if entry["material"] == material and entry["tool"] == tool_type:
                sfm = entry["sfm"]
                break
                
        if geometry in ["T-Slot", "Thread Mill", "Lollipop", "Drill", "Spot Drill"]:
            sfm *= 0.5  # Heavy reduction for saws/undercuts/drills due to trapped chips
            
        if geometry == "Rougher":
            sfm *= 0.9  # Corncob mills typically run ~10% slower Target SFM
            
        if geometry == "Indexable Mill":
            sfm *= 1.25 # Indexables often run higher SFMs in mild materials

        # Micro-Tool Thermal/Chip Evacuation Limit
        if diameter is not None and diameter < 0.125:
            # Below 1/8", sfm drops to prevent melting, but exponent 0.85 allows 
            # higher precision spindles to run slightly less conservative speeds.
            scale = max(0.25, (diameter / 0.125) ** 0.85)
            sfm *= scale
            
        return sfm
        
    def get_base_ipt(self, material, tool_type, diameter, geometry="Square"):
        """Lookup chipload (Inch Per Tooth) from DB"""
        diameters = [0.0625, 0.125, 0.1875, 0.25, 0.375, 0.5, 0.75, 1, 1.5, 2, 3, 4, 5]
        ipt = 0.001
        for row in self.ipt_data:
            if row[0] == material and row[1] == tool_type:
                if diameter <= diameters[0]:
                    ipt = row[2]
                    # Micro-tool chipload reduction: Scale linearly below 1/16" for high precision spindles
                    if diameter < diameters[0]:
                        scale = (diameter / diameters[0]) ** 1.0
                        ipt *= scale
                elif diameter >= diameters[-1]:
                    ipt = row[-1]
                else:
                    for i in range(len(diameters) - 1):
                        d1 = diameters[i]
                        d2 = diameters[i+1]
                        if d1 <= diameter <= d2:
                            ipt1 = row[2 + i]
                            ipt2 = row[2 + i + 1]
                            if d1 == d2:
                                ipt = ipt1
                            else:
                                ipt = ipt1 + (ipt2 - ipt1) * ((diameter - d1) / (d2 - d1))
                            break
                break
                
        if geometry in ["T-Slot", "Thread Mill", "Lollipop", "Drill", "Spot Drill", "Parabolic"]:
            ipt *= 0.5  # Lighter chipload required for trapped chip clearance
            
        if geometry == "Rougher":
            ipt *= 1.38  # GWizard uses EXACTLY 1.38x IPT multiplier for Corncob roughers
            
        if geometry == "Indexable Mill":
            ipt *= 1.25  # Indexable inserts can push harder
            
        return ipt

    def calc_effective_diameter(self, diameter, cut_depth, geometry="Square", corner_radius=0.0):
        """Calculate the real cutting diameter involved in shallow cuts on curved geometries"""
        if geometry == "Ball":
            r = diameter / 2.0
            if cut_depth < r and cut_depth > 0:
                return 2.0 * math.sqrt(r**2 - (r - cut_depth)**2)
        elif geometry == "Radiused" and corner_radius > 0:
            if cut_depth < corner_radius and cut_depth > 0:
                flat_center = diameter - (2.0 * corner_radius)
                engaged_corner = 2.0 * math.sqrt(corner_radius**2 - (corner_radius - cut_depth)**2)
                return flat_center + engaged_corner
        return diameter

    def calc_rpm(self, sfm, diameter, max_rpm=16000):
        """Calculate Spindle RPM limited by machine capability"""
        if diameter <= 0: return 0
        rpm = (sfm * 12) / (math.pi * diameter)
        return min(rpm, max_rpm)

    def calc_sfm(self, rpm, diameter):
        """Calculate SFM from RPM"""
        return (rpm * math.pi * diameter) / 12

    def apply_aggressiveness(self, sfm, ipt, aggressiveness=0.5):
        """
        Scales base parameters based on a slider from 0.0 (Conservative) to 1.0 (Aggressive).
        Middle (0.5) applies standard safe math.
        """
        # Map 0.0 -> 0.7x multiplier, 0.5 -> 1.0x, 1.0 -> 1.3x
        scalar = 0.7 + (aggressiveness * 0.6) 
        
        return sfm * scalar, ipt * scalar

    def calc_feedrate(self, rpm, flutes, chipload):
        """Calculate Feedrate (Inches Per Minute)"""
        return rpm * flutes * chipload

    def calc_mrr(self, cut_depth, cut_width, feedrate, geometry="Square", diameter=0.5):
        """Calculate Material Removal Rate (Cubic Inches Per Minute)"""
        if geometry == "Drill":
            radius = diameter / 2.0
            return math.pi * (radius**2) * feedrate
        elif "Ball" in geometry:
            return cut_depth * cut_width * feedrate * 0.785 # Roughly accounts for reduced cross-section
        return cut_depth * cut_width * feedrate

    def radial_chip_thinning_factor(self, cut_width, diameter):
        """Calculate the multiplier (RCTF) for chipload when cut_width < diameter / 2"""
        if cut_width <= 0 or diameter <= 0:
            return 1.0
        radial_engagement = cut_width / diameter
        if radial_engagement >= 0.5:
            return 1.0 # No chip thinning
        
        # RCTF = 1 / sqrt(1 - (1 - 2*W/D)^2) -> approx D / sqrt(4*W*D - 4*W^2) mapping to standard geometry model
        # GWizard essentially uses the chord length to recalculate chipload
        rctf = diameter / (2 * math.sqrt((diameter * cut_width) - (cut_width * cut_width)))
        return min(rctf, 5.0) # Cap at 5x to avoid insane feedrates on micro cuts

    def calc_adjusted_chipload(self, base_ipt, cut_depth, cut_width, diameter, effective_diameter, is_micro_tool=False, operation="Roughing", geometry="Square"):
        """Calculate chipload with Radial & Axial Chip Thinning, operation modifiers, and micro-tool guards"""
        adjusted_ipt = base_ipt
        
        if operation == "Finishing":
            adjusted_ipt *= 0.6  # Reduce chipload for better finish, usually prioritize higher RPM
        elif operation == "Slotting":
            cut_width = diameter # Force 1xD engagement profile
            
        # Radial Chip Thinning
        adjusted_ipt *= self.radial_chip_thinning_factor(cut_width, diameter)
        
        # Axial Chip Thinning (from Ballnose / Radiused geometries)
        if effective_diameter < diameter and effective_diameter > 0.001:
            axial_factor = diameter / effective_diameter
            adjusted_ipt *= min(axial_factor, 5.0) # Prevent insane scaling
        
        if "Adaptive" in operation:
            # Trochoidal cuts allow for aggressive heat dissipation
            adjusted_ipt *= 1.3
            
        if "Drill" in geometry or geometry == "Parabolic":
            # Deep Hole Drilling Feed Penalty logic based on GWizard exact constants
            depth_ratio = cut_depth / diameter
            if depth_ratio > 3.0:
                if geometry == "Parabolic":
                    # Parabolics only suffer slight feed reductions
                    if depth_ratio >= 10.0:
                        adjusted_ipt *= 0.9
                else:
                    # GWizard literal interpolation: 7xD drops to 80% feed, 15xD drops to 10%
                    scale = 1.0
                    if depth_ratio >= 7.0:
                        scale = 0.8 - (0.0875 * (depth_ratio - 7.0))
                    else:
                        scale = 1.0 - (0.05 * (depth_ratio - 3.0))
                    adjusted_ipt *= max(0.1, scale)
            
        # Micro-tool guard: avoid feeding less than the cutting edge radius (rubbing/ploughing)
        if is_micro_tool or diameter <= 0.125:
            min_ipt = diameter * 0.005 # rough heuristic if edge radius unknown
            adjusted_ipt = max(adjusted_ipt, min_ipt)
            
        return adjusted_ipt

    def get_coating_multiplier(self, coating, material_family):
        if coating == "Uncoated" or not material_family:
            return 1.0
            
        mat_lower = material_family.lower()
        is_aluminum = "aluminum" in mat_lower
        is_ferrous = "steel" in mat_lower or "iron" in mat_lower or "stainless" in mat_lower
        is_titanium = "titanium" in mat_lower or "cobalt" in mat_lower or "nickel" in mat_lower
        
        if coating in ["TiAlN", "AlTiN"]:
            if is_aluminum:
                return 0.8 # Severe galling penalty due to aluminum affinity
            if is_ferrous or is_titanium:
                return 1.4 # Optimal for high heat ferrous/titanium
            return 1.2
            
        if coating == "Diamond":
            if is_ferrous or is_titanium:
                return 0.5 # Severe chemical dissolution penalty at heat
            if is_aluminum or "graphite" in mat_lower or "plastic" in mat_lower:
                return 2.0 # Incredible performance on non-ferrous
            return 1.5
            
        if coating == "ZrN":
            if is_aluminum or "brass" in mat_lower or "copper" in mat_lower:
                return 1.4 # Optimal non-ferrous
            return 1.0 # Neutral on ferrous
            
        if coating == "TiCN":
            if is_ferrous:
                return 1.3
            return 1.1
            
        if coating == "TiN":
            if is_ferrous:
                return 1.2
            return 1.05
            
        return 1.0
        
    def calc_ramping(self, family_name, diameter, feedrate, geometry="Square", flutes=4, aggressiveness=0.5):
        """Calculate safe Ramping Angle, Ramp Feed, and Plunge Feed"""
        family_str = str(family_name).lower()
        if "steel" in family_str or "titanium" in family_str or "nickel" in family_str or "iron" in family_str:
            angle = 1.5
            ramp_feed = feedrate * 0.50
            plunge_feed = feedrate * 0.25
        elif "aluminum" in family_str or "plastic" in family_str or "wood" in family_str or "magnesium" in family_str or "brass" in family_str:
            angle = 3.0
            ramp_feed = feedrate * 0.75
            plunge_feed = feedrate * 0.50
        else:
            angle = 2.0
            ramp_feed = feedrate * 0.60
            plunge_feed = feedrate * 0.35
            
        # Adjust ramp angle dynamically based on tool constraints and aggressiveness
        # Fewer flutes = more chip clearance = steeper ramp
        if flutes <= 2:
            angle *= 1.5
        elif flutes >= 5:
            angle *= 0.75
            
        # Aggressiveness scaling: 0.0 -> 0.7x angle, 1.0 -> 1.3x angle
        aggr_scalar = 0.7 + (aggressiveness * 0.6)
        angle *= aggr_scalar
            
        if "Drill" in geometry or geometry == "Parabolic":
            angle = 90.0
            ramp_feed = feedrate
            plunge_feed = feedrate
            if geometry == "Spot Drill":
                plunge_feed = feedrate * 0.5 # Spot drills are prone to tip breaking
        elif geometry in ["Ball", "Radiused", "Lollipop"]:
            angle += 1.0 # Center clearance allows slightly more aggressive ramping
        elif geometry in ["T-Slot", "Dovetail", "Keyseat", "Woodruff", "Engraving"]:
            angle = 0.0 # Cannot ramp undercutting tools axially safely!
            ramp_feed = 0.0
            
        return angle, ramp_feed, plunge_feed
        
    def tool_deflection(self, diameter, shank_size, stickout, cut_depth, cut_width, feedrate, rpm, flutes, is_carbide=True, material_family=None, helix_angle=30.0, neck_length=0.5, taper_angle=0.0, flute_length=1.0, neck_diameter=None):
        """
        Calculate Tool Deflection (inches).
        Simplified mechanical deflection equation for an endmill modeled as a cantilever beam.
        F = Cutting Force, L = Stickout, E = Elastic Modulus, I = Moment of Inertia
        Deflection = (F * L^3) / (3 * E * I)
        """
        if rpm <= 0: return 0
        
        # Horsepower rough estimate based on MRR and Material Factor (MF)
        mrr = self.calc_mrr(cut_depth, cut_width, feedrate, diameter=diameter)
        
        # Unit horsepower for material (K-factor)
        unit_hp = 1.0 
        if material_family and material_family in self.machinability:
            unit_hp = self.machinability[material_family].get("unit_hp", 1.0)
            
        estimated_hp = mrr * unit_hp 
        
        if estimated_hp <= 0: return 0
        
        # Torque (in-lbs) = (63025 * HP) / RPM
        torque = (63030 * estimated_hp) / rpm
        
        # Cutting Force (lbs) = Torque / Radius
        radius = diameter / 2.0
        if radius <= 0: return 0
        cutting_force = torque / radius
        
        # For micro tools, force acts closer to the center, effectively doubling leverage in GWizard's math
        if diameter < 0.125:
            cutting_force *= 2
            
        # Elastic Modulus (psi). Carbide is 3x stiffer than HSS.
        E = 90000000.0 if is_carbide else 30000000.0
        
        # Segment 1: Fluted section
        # Core diameter is roughly reduced by flute depth. Standard endmill core is ~60-70% of diameter.
        # Helix angle increases the effective length of the flutes and weakens the moment of inertia.
        core_dia = diameter * max(0.4, (1.0 - (flutes * 0.05))) * max(0.5, math.cos(math.radians(helix_angle)))
        I1 = (core_dia ** 4) / 12.0
        L1 = min(flute_length, stickout)
        
        # Segment 2: Neck / Taper
        if neck_diameter is None:
            neck_diameter = shank_size
            
        L2 = max(0.0, min(neck_length, stickout) - L1)
        if taper_angle > 0:
            # Average diameter for a simplified taper
            avg_neck_dia = neck_diameter + (L2 * math.tan(math.radians(taper_angle)))
            I2 = (avg_neck_dia ** 4) / 12.0
        else:
            I2 = (neck_diameter ** 4) / 12.0
            
        # Segment 3: Solid Shank
        L3 = max(0.0, stickout - L1 - L2)
        I3 = (shank_size ** 4) / 12.0
        
        # Superposition of cantilever beam segments under a single end load (cutting force)
        # Deflection at tip = sum of deflections contributed by each segment's bending
        deflection = 0.0
        
        if I1 > 0 and L1 > 0:
            deflection += (cutting_force * (L1 ** 3)) / (3 * E * I1)
        if I2 > 0 and L2 > 0:
            deflection += (cutting_force * (L2 ** 3)) / (3 * E * I2) + ((cutting_force * (L2 ** 2)) / (2 * E * I2)) * L1
        if I3 > 0 and L3 > 0:
            deflection += (cutting_force * (L3 ** 3)) / (3 * E * I3) + ((cutting_force * (L3 ** 2)) / (2 * E * I3)) * (L1 + L2)
            
        return deflection

    def recommend_cut_parameters(self, diameter, shank_size, stickout, flutes, rpm, base_ipt, is_carbide=True, operation="Roughing", aggressiveness=0.5, geometry="Square", cutter_thickness=0.125, max_hp=10.0, material_family=None, helix_angle=30.0, neck_length=0.5, taper_angle=0.0, flute_length=1.0, neck_diameter=None):
        """
        Iteratively calculates safe max DOC and WOC targeting physical deflection limits
        and spindle power caps (customizable max_hp).
        """
        # Baseline breaking geometry rule of thumb: ~0.002" per inch of diameter
        default_max_deflect = diameter * 0.002 
        
        # 0.0 (Conservative) -> 0.2x physical limit. Very safe, high finish
        # 0.5 (Mid) -> 0.7x physical limit. Good robust prototyping
        # 1.0 (Aggressive) -> 1.2x physical limit. Approaching breakage/chatter bounds
        target_deflection = default_max_deflect * (0.2 + aggressiveness) 
        
        # Typical engagement widths
        if operation == "Finishing":
            target_woc = diameter * 0.05
        elif operation == "Slotting":
            target_woc = diameter
        elif "Adaptive" in operation:
            target_woc = diameter * 0.15 # Trochoidal
        else:
            target_woc = diameter * 0.5 # Standard stepover
            
        if geometry in ["T-Slot", "Dovetail", "Keyseat"]:
            # T-Slots must mathematically plunge exactly their own thickness
            return cutter_thickness, min(diameter * 0.35, target_woc), target_deflection
            
        max_doc = min(diameter * 4.0, flute_length) # Limit recommended cuts to 4xD flute lengths or physical flute length
        best_doc = 0.010
        current_doc = 0.010
        step = max(diameter * 0.05, 0.005) # Iteration step
        
        while current_doc <= max_doc:
            # We assume effective_diameter = diameter for generalized standard recommendations
            adj_ipt = self.calc_adjusted_chipload(base_ipt, current_doc, target_woc, diameter, diameter, operation=operation)
            feed = self.calc_feedrate(rpm, flutes, adj_ipt)
            
            deflect = self.tool_deflection(diameter, shank_size, stickout, current_doc, target_woc, feed, rpm, flutes, is_carbide, material_family, helix_angle, neck_length, taper_angle, flute_length, neck_diameter)
            
            unit_hp = 1.0 
            if material_family and material_family in self.machinability:
                unit_hp = self.machinability[material_family].get("unit_hp", 1.0)
                
            est_hp = self.calc_mrr(current_doc, target_woc, feed, diameter=diameter) * unit_hp 
            
            # S500X2 limit around custom HP continuous
            if deflect >= target_deflection or est_hp >= max_hp:
                break
                
            best_doc = current_doc
            current_doc += step
            
        return best_doc, target_woc, target_deflection

# Example Usage
if __name__ == "__main__":
    physics = GWizardPhysics("materials_database_clean.json")
    # Quick test case
    sfm = physics.get_base_sfm("Aluminum - Wrought (6061)", "Carbide Endmill")
    ipt = physics.get_base_ipt("Aluminum - Wrought (6061)", "Carbide Endmill", 0.5)
    
    rpm = physics.calc_rpm(sfm, 0.5)
    feed = physics.calc_feedrate(rpm, 4, ipt)
    mrr = physics.calc_mrr(0.25, 0.1, feed)
    deflect = physics.tool_deflection(0.5, 0.5, 1.5, 0.25, 0.1, feed, rpm, 4, True)
    
    print(f"Test Cut -> RPM: {rpm:.0f}, Feed: {feed:.1f} IPM, MRR: {mrr:.2f} cubic-in/min, Deflection: {deflect:.5f} in")
