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
        
    def get_base_sfm(self, material, tool_type, geometry="Square"):
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
            
        return sfm
        
    def get_base_ipt(self, material, tool_type, diameter, geometry="Square"):
        """Lookup chipload (Inch Per Tooth) from DB"""
        diameters = [0.0625, 0.125, 0.1875, 0.25, 0.375, 0.5, 0.75, 1, 1.5, 2, 3, 4, 5]
        ipt = 0.001
        for row in self.ipt_data:
            if row[0] == material and row[1] == tool_type:
                # Interpolate or exact match
                matched = False
                for i, d in enumerate(diameters):
                    if diameter <= d:
                        ipt = row[2 + i]
                        matched = True
                        break
                if not matched: ipt = row[-1]
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
        
        if operation == "Adaptive":
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
        
    def tool_deflection(self, diameter, shank_size, stickout, cut_depth, cut_width, feedrate, rpm, flutes, is_carbide=True):
        """
        Calculate Tool Deflection (inches).
        Simplified mechanical deflection equation for an endmill modeled as a cantilever beam.
        F = Cutting Force, L = Stickout, E = Elastic Modulus, I = Moment of Inertia
        Deflection = (F * L^3) / (3 * E * I)
        """
        if rpm <= 0: return 0
        
        # Horsepower rough estimate based on MRR and Material Factor (MF)
        mrr = self.calc_mrr(cut_depth, cut_width, feedrate, diameter=diameter)
        
        # Standard unit horsepower for material (K-factor), 1.0 is a rough default for mild steel
        unit_hp = 1.0 
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
        
        # Moment of Inertia for a cylinder I = (pi * d^4) / 64
        # GWizard uses shank_size^4 / 12 as a simplified approximation in its code: 
        # _loc16_ = Math.pow(shankSize,4) / 12;
        I = (shank_size ** 4) / 12.0
        
        if I <= 0: return 0
        
        # Classic cantilever deflection formula: Deflection = (F * L^3) / (3 * E * I)
        deflection = (cutting_force * (stickout ** 3)) / (3 * E * I)
        return deflection

    def recommend_cut_parameters(self, diameter, shank_size, stickout, flutes, rpm, base_ipt, is_carbide=True, operation="Roughing", aggressiveness=0.5, geometry="Square", cutter_thickness=0.125):
        """
        Iteratively calculates safe max DOC and WOC targeting physical deflection limits
        and spindle power caps (Brother Speedio ~ 10 HP max continuous payload).
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
        elif operation == "Adaptive":
            target_woc = diameter * 0.15 # Trochoidal
        else:
            target_woc = diameter * 0.5 # Standard stepover
            
        if geometry in ["T-Slot", "Dovetail", "Keyseat"]:
            # T-Slots must mathematically plunge exactly their own thickness
            return cutter_thickness, min(diameter * 0.35, target_woc), target_deflection
            
        max_doc = diameter * 4.0 # Limit recommended cuts to 4xD flute lengths
        best_doc = 0.010
        current_doc = 0.010
        step = max(diameter * 0.05, 0.005) # Iteration step
        
        while current_doc <= max_doc:
            # We assume effective_diameter = diameter for generalized standard recommendations
            adj_ipt = self.calc_adjusted_chipload(base_ipt, current_doc, target_woc, diameter, diameter, operation=operation)
            feed = self.calc_feedrate(rpm, flutes, adj_ipt)
            
            deflect = self.tool_deflection(diameter, shank_size, stickout, current_doc, target_woc, feed, rpm, flutes, is_carbide)
            
            # Unit HP of 1.0 is standard aluminum/mild steel average
            est_hp = self.calc_mrr(current_doc, target_woc, feed, diameter=diameter) * 1.0 
            
            # S500X2 limit around 10-12 HP continuous
            if deflect >= target_deflection or est_hp >= 10.0:
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
