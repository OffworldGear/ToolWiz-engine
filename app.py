import os
import io
import json
import math
import uuid
from flask import Flask, render_template, request, jsonify, send_file
from gwizard_physics import GWizardPhysics
from ai_machinist import query_ai_machinist, get_available_gemini_models

app = Flask(__name__)

# Initialize physics engine
db_path = os.path.join(os.path.dirname(__file__), "materials_database_clean.json")
physics = GWizardPhysics(db_path)

@app.route("/")
def index():
    return render_template("index.html")

@app.after_request
def add_header(response):
    """Prevent browser from caching API responses and dynamic templates"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
    return response

# Tool categories grouped by type, ordered HP -> Carbide -> HSS
TOOL_GROUPS = [
    {
        "group": "End Mills",
        "tools": [
            "HP Carbide High Feed Endmill",
            "HP Carbide Bull Nose Endmill",
            "HP Carbide Endmill",
            "Carbide High Feed Endmill",
            "Carbide Bull Nose Endmill",
            "Carbide Endmill",
            "Indexable End Or Face Mill",
            "HP HSS Endmill",
            "HSS Endmill",
        ]
    },
    {
        "group": "Drills & Holemaking",
        "tools": [
            "HP Carbide Twist Drill",
            "Carbide Twist Drill",
            "Indexable Drill",
            "Cobalt Twist Drill",
            "Gun Drill",
            "HP HSS Twist Drill",
            "HSS Twist Drill",
            "HSS Spade Drill",
            "HSS Spot Drill",
        ]
    },
    {
        "group": "Reamers",
        "tools": [
            "Carbide Reamer",
            "HSS Reamer",
        ]
    },
    {
        "group": "Threading & Tapping",
        "tools": [
            "Carbide Thread Mill",
            "Tapping",
        ]
    },
    {
        "group": "Saws & Woodruff Cutters",
        "tools": [
            "Carbide Saws & Woodruff Cutters",
            "HSS Saws & Woodruff Cutters",
        ]
    },
    {
        "group": "Turning / Lathe",
        "tools": [
            "Turning: Carbide",
            "Turning: Carbide HSS",
            "Turning: HSS",
        ]
    }
]

@app.route("/api/data", methods=["GET"])
def get_data():
    """Return the data needed to populate the UI dropdowns"""
    families = list(physics.machinability.keys())
    families.sort()
    
    # Flatten tools preserving the exact grouped order (HP -> Carbide -> HSS)
    ordered_tools = []
    for g in TOOL_GROUPS:
        for t in g["tools"]:
            if t not in ordered_tools:
                ordered_tools.append(t)
        
    return jsonify({
        "families": families,
        "tools": ordered_tools,
        "tool_groups": TOOL_GROUPS,
        "alloys": physics.specific_alloys
    })

@app.route("/api/calculate", methods=["POST"])
def calculate():
    """Calculate physics engine parameters from incoming JSON data"""
    try:
        data = request.json
        family = data.get("family", "")
        tool = data.get("tool", "")
        diameter = float(data.get("diameter", 0.5))
        flutes = int(data.get("flutes", 4))
        cut_depth = float(data.get("cutDepth", 0.25))
        cut_width = float(data.get("cutWidth", 0.25))
        stickout = float(data.get("stickout", 1.5))
        is_carbide = bool(data.get("isCarbide", True))
        geometry = data.get("geometry", "Square")
        operation = data.get("operation", "Roughing")
        coating = data.get("coating", "Uncoated")
        
        # Normalize legacy baked-in coating tool names so coatings are not double-multiplied
        if "tialn" in tool.lower() or "altin" in tool.lower():
            tool = "Carbide Endmill"
            if coating == "Uncoated" or not coating:
                coating = "AlTiN"
        corner_radius = float(data.get("cornerRadius", 0.0))
        cutter_thickness = float(data.get("cutterThickness", 0.125))
        flute_length = float(data.get("fluteLength", 1.0))
        neck_length = float(data.get("neckLength", 0.5))
        taper_angle = float(data.get("taperAngle", 0.0))
        helix_angle = float(data.get("helixAngle", 30.0))
        aggressiveness = float(data.get("aggressiveness", 50.0)) / 100.0  # Scale 0-100 to 0.0-1.0
        max_rpm = float(data.get("maxRpm", 16000))
        max_hp = float(data.get("maxHp", 10.0))
        runout = float(data.get("runout", 0.0002))
        tap_type = data.get("tapType", "")
        is_metric = bool(data.get("isMetric", False))

        # Contextual resolution: extract tap style directly from geometry when tapping
        geo_lower = geometry.lower()
        if "form" in geo_lower or "roll" in geo_lower:
            tap_type = "form"
        elif "spiral_point" in geo_lower or "gun" in geo_lower:
            tap_type = "spiral_point"
        elif "straight" in geo_lower or "hand" in geo_lower:
            tap_type = "straight_flute"
        elif "spiral_flute" in geo_lower or ("spiral" in geo_lower and "point" not in geo_lower):
            tap_type = "spiral_flute"
        elif not tap_type:
            tap_type = "form"
        
        # Identify saw/woodruff tools
        is_saw_woodruff = any(s in geometry.lower() for s in ["t-slot", "woodruff", "keyseat"]) or any(s in tool.lower() for s in ["woodruff", "saw"])
        if is_saw_woodruff:
            if "t-slot" not in geometry.lower() and "keyseat" not in geometry.lower() and "woodruff" not in geometry.lower():
                geometry = "T-Slot"
            if cutter_thickness > 0.0:
                flute_length = cutter_thickness

        # Determine sizes
        has_relieved_neck = bool(data.get("hasRelievedNeck", False))
        is_form_stepped = is_saw_woodruff or any(s in geometry.lower() for s in ["lollipop", "dovetail"])
        shank_size = float(data.get("shankDiameter", diameter))
        if has_relieved_neck or is_form_stepped:
            neck_diameter = float(data.get("neckDiameter", shank_size))
        else:
            neck_diameter = diameter
        
        # 1. Lookup Base Parameters
        target_sfm = physics.get_base_sfm(
            family, tool, geometry=geometry, diameter=diameter,
            tap_type=tap_type, is_carbide=is_carbide
        )
        base_ipt = physics.get_base_ipt(
            family, tool, diameter, geometry=geometry, runout=runout,
            cut_depth=cut_depth, cut_width=cut_width, flutes=flutes, is_carbide=is_carbide
        )
        
        # Alloy-specific hardness adjustment via exponential BHN curve
        alloy = data.get("alloy", "")
        target_sfm, base_ipt = physics.apply_alloy_hardness_scaling(family, alloy, target_sfm, base_ipt)
        
        is_hole_tool = any(d in tool.lower() for d in ["drill", "tap", "reamer", "bore", "annular"]) or any(d in geometry.lower() for d in ["drill", "parabolic", "tap", "form", "spiral_flute", "spiral_point", "straight_flute", "reamer"])
        is_tapping = "tap" in tool.lower() or "tap" in operation.lower() or "form" in geo_lower or "spiral_flute" in geo_lower or "spiral_point" in geo_lower or "straight_flute" in geo_lower

        # Chatter / Resonance penalty based on stickout length (8xD threshold for hole tools vs 3.5xD for milling; bypassed for saws/woodruff)
        target_sfm, base_ipt = physics.apply_chatter_penalty(
            target_sfm, base_ipt, diameter, stickout, is_drilling=is_hole_tool, is_saw_woodruff=is_saw_woodruff, flute_length=flute_length
        )
        
        if not is_tapping:
            target_sfm, base_ipt = physics.apply_aggressiveness(target_sfm, base_ipt, aggressiveness)
            # High Efficiency Milling (HEM) low-immersion thermal cooling speed boost
            hem_sfm_mult = physics.calc_hem_thermal_sfm_multiplier(cut_width, diameter, operation=operation)
            target_sfm *= hem_sfm_mult
        
        # Apply Coating Modifier
        target_sfm *= physics.get_coating_multiplier(coating, family)
        
        effective_diameter = physics.calc_effective_diameter(diameter, cut_depth, geometry, corner_radius)
        
        # 2. Physics Equations
        ideal_rpm = (target_sfm * 12.0) / (math.pi * effective_diameter) if effective_diameter > 0 else 0.0
        is_spindle_limited = bool(max_rpm > 0 and ideal_rpm > (max_rpm * 1.005))
        rpm = physics.calc_rpm(target_sfm, effective_diameter, max_rpm=max_rpm)
        
        if is_hole_tool:
            cut_width = diameter
            if any(m in operation.lower() for m in ["rough", "adaptive", "trochoidal", "slot", "face", "finish"]):
                if "tap" in tool.lower():
                    operation = "Rigid Tapping"
                elif "ream" in tool.lower():
                    operation = "Precision Reaming"
                else:
                    operation = "Drilling"

        tap_drill_info = None
        if "tap" in tool.lower() or "tap" in operation.lower():
            pitch = float(data.get("pitch", 0.05))
            feedrate = round(rpm) * pitch
            adjusted_ipt = pitch
            tap_drill_info = physics.calc_tap_drill(
                major_dia=diameter,
                pitch=pitch,
                tap_type=tap_type,
                material_family=family,
                is_metric=is_metric
            )
        else:
            adjusted_ipt = physics.calc_adjusted_chipload(base_ipt, cut_depth, cut_width, diameter, effective_diameter, operation=operation, geometry=geometry, tool_type=tool, corner_radius=corner_radius)
            feedrate = physics.calc_feedrate(rpm, flutes, adjusted_ipt)
            
        mrr = physics.calc_mrr(cut_depth, cut_width, feedrate, geometry=geometry, diameter=diameter)
        
        actual_sfm = physics.calc_sfm(rpm, diameter)
        # 3. Ramping Params
        ramp_angle, ramp_feed, plunge_feed = physics.calc_ramping(family, diameter, feedrate, geometry, flutes, aggressiveness, tool_type=tool)
        
        if is_hole_tool:
            deflection = 0.0
            springback = 0.0
            total_error = 0.0
            wear_comp = 0.0
        else:
            deflection = physics.tool_deflection(
                diameter, shank_size, stickout, cut_depth, cut_width, feedrate, rpm, flutes, is_carbide, material_family=family,
                helix_angle=helix_angle, neck_length=neck_length, taper_angle=taper_angle, flute_length=flute_length, neck_diameter=neck_diameter,
                operation=operation, geometry=geometry, corner_radius=corner_radius
            )
            springback, total_error, wear_comp = physics.calc_springback_and_deflection(
                family, diameter, cut_depth, cut_width, feedrate, rpm, flutes, deflection, alloy=alloy
            )
        
        tips = physics.generate_advanced_strategies(
            family, diameter, cut_depth, cut_width, feedrate, rpm, flutes, coating, deflection,
            tool_type=tool, stickout=stickout, geometry=geometry, flute_length=flute_length,
            operation=operation, tap_type=tap_type, neck_diameter=neck_diameter, alloy=alloy,
            corner_radius=corner_radius
        )
        
        if is_spindle_limited:
            feed_val = feedrate if not is_metric else feedrate * 25.4
            feed_unit = "IPM" if not is_metric else "mm/min"
            tips.append({
                "title": "Spindle RPM Limited",
                "message": (
                    f"Your machine's spindle speed cap ({max_rpm:,.0f} RPM) limits surface speed to {actual_sfm:.1f} SFM "
                    f"(ideal: {target_sfm:.0f} SFM at {ideal_rpm:,.0f} RPM). Tool Wizard has synchronized your feedrate "
                    f"to {feed_val:.1f} {feed_unit} to maintain optimal chipload ({adjusted_ipt:.5f}\" IPT) and prevent tool rubbing."
                ),
                "type": "info"
            })
        
        rec_doc, rec_woc, rec_limit = physics.recommend_cut_parameters(
            diameter, shank_size, stickout, flutes, rpm, base_ipt, is_carbide, operation, aggressiveness, geometry, cutter_thickness, max_hp, material_family=family,
            helix_angle=helix_angle, neck_length=neck_length, taper_angle=taper_angle, flute_length=flute_length, neck_diameter=neck_diameter,
            corner_radius=corner_radius
        )
        
        ipr = (feedrate / rpm) if rpm > 0.0 else (adjusted_ipt * flutes)
        max_radial_reach = (diameter - neck_diameter) / 2.0 if (neck_diameter > 0.0 and neck_diameter < diameter) else diameter

        resp = {
            "success": True,
            "rpm": round(rpm),
            "feedrate": round(feedrate, 2),
            "mrr": round(mrr, 6),
            "deflection": round(deflection, 6),
            "springback": round(springback, 6),
            "total_error": round(total_error, 6),
            "wear_comp": round(wear_comp, 6),
            "sfm": round(actual_sfm, 1),
            "base_ipt": round(base_ipt, 6),
            "adj_ipt": round(adjusted_ipt, 6),
            "ipr": round(ipr, 6),
            "ramp_angle": round(ramp_angle, 1),
            "ramp_feed": round(ramp_feed, 2),
            "plunge_feed": max(round(plunge_feed, 4), 0.0001) if feedrate > 0.0 else 0.0,
            "rec_doc": round(rec_doc, 4),
            "rec_woc": round(rec_woc, 4),
            "rec_limit": round(rec_limit, 5),
            "max_radial_reach": round(max_radial_reach, 5),
            "neck_diameter": round(neck_diameter, 5),
            "shank_diameter": round(shank_size, 5),
            "flute_length": round(flute_length, 5),
            "is_spindle_limited": is_spindle_limited,
            "ideal_rpm": round(ideal_rpm),
            "target_sfm": round(target_sfm, 1),
            "tips": tips
        }
        if tap_drill_info:
            resp["tap_drill"] = tap_drill_info
            resp["tap_type"] = tap_type
        return jsonify(resp)
        
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

@app.route("/api/calculate_for_fusion", methods=["POST"])
def calculate_for_fusion():
    """Endpoint specifically designed for the Fusion 360 Add-in"""
    try:
        data = request.json
        family = data.get("family", "")
        tool = data.get("tool", "Carbide Endmill") # default fallback
        operation = data.get("operation", "Roughing")
        aggressiveness = float(data.get("aggressiveness", 50.0)) / 100.0
        max_rpm = float(data.get("maxRpm", 16000))
        max_hp = float(data.get("maxHp", 10.0))
        runout = float(data.get("runout", 0.0002))
        
        # Tool Geometry from Fusion JSON payload
        diameter = float(data.get("diameter", 0.25))
        flutes = int(data.get("flutes", 4))
        coating = data.get("coating", "Uncoated")
        geometry = data.get("geometry", "Square")
        corner_radius = float(data.get("cornerRadius", 0.0))
        cutter_thickness = float(data.get("cutterThickness", 0.125))
        flute_length = float(data.get("fluteLength", 1.0))
        neck_length = float(data.get("neckLength", 0.5))
        shank_size = float(data.get("shankDiameter", diameter))
        taper_angle = float(data.get("taperAngle", 0.0))
        helix_angle = float(data.get("helixAngle", 30.0))
        stickout = float(data.get("stickout", 1.5))
        is_carbide = True  # Assuming Fusion tool implies carbide if not specified
        
        is_saw_woodruff = any(s in geometry.lower() for s in ["t-slot", "woodruff", "keyseat"]) or any(s in tool.lower() for s in ["woodruff", "saw"])
        if is_saw_woodruff and cutter_thickness > 0.0:
            flute_length = cutter_thickness

        has_relieved_neck = bool(data.get("hasRelievedNeck", False))
        is_form_stepped = is_saw_woodruff or any(s in geometry.lower() for s in ["lollipop", "dovetail"])
        if has_relieved_neck or is_form_stepped:
            neck_diameter = float(data.get("neckDiameter", shank_size))
        else:
            neck_diameter = diameter

        # 1. Lookup Base Parameters
        target_sfm = physics.get_base_sfm(family, tool, geometry=geometry, diameter=diameter, is_carbide=is_carbide)
        base_ipt = physics.get_base_ipt(
            family, tool, diameter, geometry=geometry, runout=runout,
            cut_depth=cutter_thickness, cut_width=diameter * 0.25, flutes=flutes, is_carbide=is_carbide
        )
        
        # Alloy-specific hardness adjustment via exponential BHN curve
        alloy = data.get("alloy", "")
        target_sfm, base_ipt = physics.apply_alloy_hardness_scaling(family, alloy, target_sfm, base_ipt)
            
        target_sfm, base_ipt = physics.apply_aggressiveness(target_sfm, base_ipt, aggressiveness)
        target_sfm *= physics.get_coating_multiplier(coating, family)
        
        # 2. Physics Equations
        rpm = physics.calc_rpm(target_sfm, diameter, max_rpm=max_rpm)
        # Using recommended DOC and WOC for the final feedrate
        rec_doc, rec_woc, rec_limit = physics.recommend_cut_parameters(
            diameter, shank_size, stickout, flutes, rpm, base_ipt, is_carbide, operation, aggressiveness, geometry, cutter_thickness, max_hp, material_family=family,
            helix_angle=helix_angle, neck_length=neck_length, taper_angle=taper_angle, flute_length=flute_length, neck_diameter=neck_diameter,
            corner_radius=corner_radius
        )
        
        # High Efficiency Milling (HEM) low-immersion thermal cooling speed boost
        hem_sfm_mult = physics.calc_hem_thermal_sfm_multiplier(rec_woc, diameter, operation=operation)
        target_sfm *= hem_sfm_mult
        rpm = physics.calc_rpm(target_sfm, diameter, max_rpm=max_rpm)
        
        effective_diameter = physics.calc_effective_diameter(diameter, rec_doc, geometry, corner_radius)
        ideal_rpm = (target_sfm * 12.0) / (math.pi * effective_diameter) if effective_diameter > 0 else 0.0
        is_spindle_limited = bool(max_rpm > 0 and ideal_rpm > (max_rpm * 1.005))
        
        adjusted_ipt = physics.calc_adjusted_chipload(base_ipt, rec_doc, rec_woc, diameter, effective_diameter, operation=operation, geometry=geometry, corner_radius=corner_radius)
        feedrate = physics.calc_feedrate(rpm, flutes, adjusted_ipt)
        actual_sfm = physics.calc_sfm(rpm, diameter)
        
        # 3. Ramping Params
        tool_val = data.get("tool", "")
        ramp_angle, ramp_feed, plunge_feed = physics.calc_ramping(family, diameter, feedrate, geometry, flutes, aggressiveness, tool_type=tool_val)
        
        return jsonify({
            "success": True,
            "name": f"ToolWiz: {family} - {operation}",
            "rpm": round(rpm),
            "feed": round(feedrate, 2),
            "sfm": round(actual_sfm, 1),
            "ipt": round(adjusted_ipt, 6),
            "doc": round(rec_doc, 3),
            "woc": round(rec_woc, 3),
            "ramp_feed": round(ramp_feed, 2),
            "plunge_feed": max(round(plunge_feed, 4), 0.0001) if feedrate > 0.0 else 0.0,
            "is_spindle_limited": is_spindle_limited,
            "ideal_rpm": round(ideal_rpm)
        })
        
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

@app.route("/api/threads/standards", methods=["GET"])
def get_thread_standards():
    """Return available thread families, sizes, and classes from the database."""
    try:
        data = physics.get_thread_standards()
        return jsonify({"success": True, **data})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

@app.route("/api/threads/calculate", methods=["POST"])
def calculate_thread():
    """Calculate thread specifications, G-Wizard tapping drill table, and blind hole clearance."""
    try:
        data = request.json or {}
        family = data.get("family", "ISO Coarse")
        size = data.get("size", "M1.6-0.35")
        th_class = data.get("class", "6H")
        th_type = data.get("type", "Internal")
        is_form = bool(data.get("isForm", False))
        is_metric = bool(data.get("isMetric", False))
        lead_style = data.get("leadStyle", "form" if is_form else "plug")
        thread_depth = float(data.get("threadDepth", 0.0))
        material_family = data.get("materialFamily", "")

        # Look up thread definition from database
        entry = physics.lookup_thread(family, size, th_class, th_type)

        if entry:
            pitch_in = entry.get("pitch_in", 0.05)
            max_major_in = entry.get("max_major_in", 0.25)
            min_major_in = entry.get("min_major_in", max_major_in)
            max_pitch_in = entry.get("max_pitch_in", max_major_in - 0.6495 * pitch_in)
            min_pitch_in = entry.get("min_pitch_in", max_pitch_in)
            max_minor_in = entry.get("max_minor_in", max_major_in - 1.0825 * pitch_in)
            min_minor_in = entry.get("min_minor_in", max_minor_in)
        else:
            # Custom thread handling
            custom_major = float(data.get("customMajor", 0.25))
            custom_pitch = float(data.get("customPitch", 0.05))
            if is_metric:
                custom_major /= 25.4
                custom_pitch /= 25.4
            pitch_in = custom_pitch
            max_major_in = custom_major
            min_major_in = custom_major
            max_pitch_in = custom_major - 0.649519 * pitch_in
            min_pitch_in = max_pitch_in
            max_minor_in = custom_major - 1.082532 * pitch_in
            min_minor_in = max_minor_in

        # Units conversion for thread depth if supplied in metric
        depth_in = (thread_depth / 25.4) if (is_metric and thread_depth > 0) else thread_depth

        # Calculate drill table using G-Wizard formula
        drills = physics.calc_thread_drill_table(
            major_dia=max_major_in,
            pitch=pitch_in,
            is_form=is_form,
            is_metric=is_metric,
            material_family=material_family
        )

        # Calculate blind hole clearance using G-Wizard formula
        blind_hole = physics.calc_blind_hole_clearance(
            pitch=pitch_in,
            lead_style=lead_style,
            thread_depth=depth_in,
            is_metric=is_metric
        )

        pitch_mm = pitch_in * 25.4
        tpi = (1.0 / pitch_in) if pitch_in > 0 else 0.0

        thread_spec = {
            "name": f"{size} ({family}) - {th_class} {th_type}",
            "family": family,
            "size": size,
            "class": th_class,
            "type": th_type,
            "pitch_in": round(pitch_in, 5),
            "pitch_mm": round(pitch_mm, 4),
            "tpi": round(tpi, 2),
            "thread_angle": 60.0 if "BS" not in family and "Whitworth" not in family else 55.0,
            "major_max_in": round(max_major_in, 4),
            "major_min_in": round(min_major_in, 4),
            "major_max_mm": round(max_major_in * 25.4, 3),
            "major_min_mm": round(min_major_in * 25.4, 3),
            "pitch_dia_max_in": round(max_pitch_in, 4),
            "pitch_dia_min_in": round(min_pitch_in, 4),
            "pitch_dia_max_mm": round(max_pitch_in * 25.4, 3),
            "pitch_dia_min_mm": round(min_pitch_in * 25.4, 3),
            "minor_max_in": round(max_minor_in, 4),
            "minor_min_in": round(min_minor_in, 4),
            "minor_max_mm": round(max_minor_in * 25.4, 3),
            "minor_min_mm": round(min_minor_in * 25.4, 3),
        }

        return jsonify({
            "success": True,
            "thread": thread_spec,
            "blind_hole": blind_hole,
            "drills": drills
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

import zipfile
import io
import uuid
from backup_manager import BackupManager
from ToolWizFusionAddin.json_mutator import format_unit
from tool_merger import (
    parse_dimension_in,
    compute_tool_signature,
    deduplicate_tools,
    merge_multiple_libraries,
    clean_tool_presets
)

bm = BackupManager()

def parse_dim(val, tool_unit=""):
    """Helper to parse tool dimensions from JSON to inches"""
    return parse_dimension_in(val, tool_unit)

@app.route("/api/twin/export_receive", methods=["POST"])
def twin_export_receive():
    """Receives exported tool library (or multiple libraries) JSON from Fusion 360 Add-in"""
    try:
        data = request.json
        if not data:
            return jsonify({"success": False, "error": "No JSON payload received"}), 400
            
        libraries_list = data.get("libraries")
        auto_dedup = bool(data.get("deduplicate", True))
        
        if libraries_list and isinstance(libraries_list, list):
            lib_name = data.get("master_library_name", "Master_Shop_Tool_Crib")
            merged_data, summary = merge_multiple_libraries(libraries_list, master_library_name=lib_name, deduplicate=auto_dedup)
            backup_info = bm.save_working_library(merged_data, lib_name)
            return jsonify({
                "success": True,
                "library_name": lib_name,
                "tool_count": len(merged_data.get("tools", [])),
                "duplicates_merged": summary.get("duplicates_removed", summary.get("deduplication", {}).get("duplicates_removed", 0)),
                "summary": summary,
                "backup": backup_info
            })
        else:
            lib_name = data.get("library_name", "Fusion_Hub_Library")
            raw_tools = data.get("tools", [])
            report = {"duplicates_removed": 0}
            if auto_dedup and raw_tools:
                cleaned_tools, report = deduplicate_tools(raw_tools, preserve_presets=True)
                data["tools"] = cleaned_tools
                
            backup_info = bm.save_working_library(data, lib_name)
            return jsonify({
                "success": True,
                "library_name": lib_name,
                "tool_count": len(data.get("tools", [])),
                "report": report,
                "backup": backup_info
            })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/twin/deduplicate", methods=["POST"])
def twin_deduplicate():
    """Deduplicates tools in the active working library and creates a backup snapshot"""
    try:
        data = bm.load_working_library()
        if not data or "tools" not in data:
            return jsonify({"success": False, "error": "No working library loaded to deduplicate."}), 400

        tools = data.get("tools", [])
        initial_count = len(tools)
        deduped_tools, report = deduplicate_tools(tools, preserve_presets=True)

        data["tools"] = deduped_tools
        lib_name = data.get("library_name", "Master_Shop_Tool_Crib")
        backup_info = bm.save_working_library(data, f"{lib_name}_deduped")

        return jsonify({
            "success": True,
            "library_name": lib_name,
            "initial_tool_count": initial_count,
            "tool_count": len(deduped_tools),
            "report": report,
            "backup": backup_info
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/twin/load", methods=["GET"])
def twin_load():
    """Returns active Digital Twin working library tools, per-tool aggressiveness, presets, and backup history"""
    try:
        data = bm.load_working_library()
        backups = bm.list_backups()
        
        if not data:
            return jsonify({
                "success": True,
                "has_library": False,
                "library_name": "No Library Loaded",
                "tools": [],
                "backups": backups
            })
            
        lib_name = data.get("library_name", "Digital_Twin_Library")
        raw_tools = data.get("tools", [])
        
        tool_manifest = []
        total_presets_count = 0

        for idx, t in enumerate(raw_tools):
            t_dict = json.loads(t) if isinstance(t, str) else t
            geo = t_dict.get("geometry", {})
            tool_unit = t_dict.get("unit", geo.get("unit", ""))
            
            dia_in = parse_dim(geo.get("DC", 6.35), tool_unit)
            flutes = int(geo.get("NOF", 4))
            flute_len = parse_dim(geo.get("LCF", 25.4), tool_unit)
            shank_dia = parse_dim(geo.get("SF", dia_in), tool_unit)
            corner_rad = parse_dim(geo.get("RE", 0.0), tool_unit)
            stickout = parse_dim(t_dict.get("stickout", flute_len * 1.5), tool_unit)
            
            t_num = t_dict.get("postProcess", {}).get("number", t_dict.get("post-process", {}).get("number", 0))
            desc = t_dict.get("description", f"{dia_in:.3f}in Tool")
            t_type = geo.get("type", t_dict.get("type", "end mill"))
            custom_aggr = t_dict.get("custom_aggressiveness", None)
            
            presets = t_dict.get("start-values", {}).get("presets", [])
            preset_list = []
            materials_seen = set()

            for p in presets:
                p_name = p.get("name", "Preset")
                p_guid = p.get("guid", "")
                p_mat = ""
                if isinstance(p.get("material"), dict):
                    p_mat = p["material"].get("query", "")
                if p_mat:
                    materials_seen.add(p_mat)
                elif " - " in p_name:
                    materials_seen.add(p_name.split(" - ")[0].strip())

                preset_list.append({
                    "name": p_name,
                    "guid": p_guid,
                    "material_query": p_mat,
                    "rpm": p.get("n", 0),
                    "feed": p.get("v_f", 0),
                    "sfm": p.get("v_c", 0),
                    "ipt": p.get("f_z", 0),
                    "stepdown": p.get("stepdown", 0),
                    "stepover": p.get("stepover", 0),
                    "ramp_feed": p.get("v_f_ramp", 0),
                    "plunge_feed": p.get("v_f_plunge", 0),
                    "coolant": p.get("tool-coolant", "flood"),
                    "description": p.get("description", "")
                })

            total_presets_count += len(preset_list)
            signature = compute_tool_signature(t_dict)
            
            tool_manifest.append({
                "index": idx,
                "number": t_num,
                "description": desc,
                "type": t_type,
                "diameter_in": round(dia_in, 4),
                "diameter_mm": round(dia_in * 25.4, 2),
                "flutes": flutes,
                "flute_length_in": round(flute_len, 4),
                "shank_diameter_in": round(shank_dia, 4),
                "corner_radius_in": round(corner_rad, 4),
                "stickout_in": round(stickout, 4),
                "custom_aggressiveness": custom_aggr,
                "signature": signature,
                "presets": preset_list,
                "preset_count": len(preset_list),
                "materials": sorted(list(materials_seen))
            })
            
        return jsonify({
            "success": True,
            "has_library": True,
            "library_name": lib_name,
            "last_modified": data.get("last_modified", ""),
            "tool_count": len(tool_manifest),
            "total_presets_count": total_presets_count,
            "tools": tool_manifest,
            "backups": backups
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/twin/backups", methods=["GET", "POST"])
def twin_backups():
    """List or restore backups"""
    try:
        if request.method == "POST":
            filename = request.json.get("filename")
            if not filename:
                return jsonify({"success": False, "error": "Filename required"}), 400
            restored = bm.restore_backup(filename)
            return jsonify({"success": True, "restored": filename})
        else:
            return jsonify({"backups": bm.list_backups()})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/twin/update_tool", methods=["POST"])
def twin_update_tool():
    """Updates a single tool's metadata, custom aggressiveness override, or dimensions"""
    try:
        payload = request.json
        tool_idx = payload.get("tool_index")
        if tool_idx is None:
            return jsonify({"success": False, "error": "tool_index is required."}), 400

        library_data = bm.load_working_library()
        if not library_data or "tools" not in library_data:
            return jsonify({"success": False, "error": "No working library loaded."}), 400

        tools = library_data["tools"]
        if tool_idx < 0 or tool_idx >= len(tools):
            return jsonify({"success": False, "error": "Invalid tool index."}), 400

        t_dict = tools[tool_idx]
        if isinstance(t_dict, str):
            t_dict = json.loads(t_dict)

        if "number" in payload:
            num = int(payload["number"])
            if "postProcess" not in t_dict:
                t_dict["postProcess"] = {}
            t_dict["postProcess"]["number"] = num
            if "post-process" in t_dict:
                t_dict["post-process"]["number"] = num

        if "description" in payload:
            t_dict["description"] = str(payload["description"]).strip()

        if "custom_aggressiveness" in payload:
            val = payload["custom_aggressiveness"]
            if val is None or val == "" or str(val).lower() == "default":
                t_dict.pop("custom_aggressiveness", None)
            else:
                t_dict["custom_aggressiveness"] = float(val)

        if "stickout" in payload and payload["stickout"] is not None:
            t_dict["stickout"] = float(payload["stickout"])

        tools[tool_idx] = t_dict
        library_data["tools"] = tools
        bm.save_working_library(library_data, library_data.get("library_name", "Modified_Library"))

        return jsonify({"success": True, "tool_index": tool_idx})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/twin/delete_tool", methods=["POST"])
def twin_delete_tool():
    """Safely deletes a tool from the working library and creates a backup snapshot"""
    try:
        payload = request.json
        tool_idx = payload.get("tool_index")
        if tool_idx is None:
            return jsonify({"success": False, "error": "tool_index is required."}), 400

        library_data = bm.load_working_library()
        if not library_data or "tools" not in library_data:
            return jsonify({"success": False, "error": "No working library loaded."}), 400

        tools = library_data["tools"]
        if tool_idx < 0 or tool_idx >= len(tools):
            return jsonify({"success": False, "error": "Invalid tool index."}), 400

        deleted_tool = tools.pop(tool_idx)
        library_data["tools"] = tools
        backup_info = bm.save_working_library(library_data, library_data.get("library_name", "Modified_Library"))

        return jsonify({
            "success": True,
            "remaining_tools": len(tools),
            "backup": backup_info
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/twin/delete_preset", methods=["POST"])
def twin_delete_preset():
    try:
        payload = request.json
        tool_idx = payload.get("tool_index")
        preset_guid = payload.get("preset_guid")
        
        library_data = bm.load_working_library()
        if not library_data or "tools" not in library_data:
            return jsonify({"success": False, "error": "No working library found."})
            
        tools = library_data["tools"]
        if tool_idx < 0 or tool_idx >= len(tools):
            return jsonify({"success": False, "error": "Invalid tool index."})
            
        t_dict = tools[tool_idx]
        if isinstance(t_dict, str):
            t_dict = json.loads(t_dict)
            
        presets = t_dict.get("start-values", {}).get("presets", [])
        original_count = len(presets)
        
        presets = [p for p in presets if p.get("guid") != preset_guid]
        
        if len(presets) == original_count:
            return jsonify({"success": False, "error": "Preset not found."})
            
        if "start-values" not in t_dict:
            t_dict["start-values"] = {}
        t_dict["start-values"]["presets"] = presets
        tools[tool_idx] = t_dict
        
        library_data["tools"] = tools
        bm.save_working_library(library_data, library_data.get("library_name", "Modified_Library"))
        
        return jsonify({"success": True})
        
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/twin/batch_generate", methods=["POST"])
def twin_batch_generate():
    """
    Batch calculates and injects multi-operation presets into selected tools.
    Supports per-tool aggressiveness overrides, clean replacement of prior presets,
    and automatic springback & wear compensation calculations.
    """
    try:
        req_data = request.json
        tool_indices = req_data.get("tool_indices", []) # list of integer indices or "all"
        family = req_data.get("family", "Steel - Tool (H13)")
        alloy = req_data.get("alloy", "CPM MagnaCut (Hardened ~62 HRC)")
        strategies = req_data.get("strategies", ["Adaptive Roughing", "Roughing", "Finishing", "Slotting"])
        
        base_aggressiveness = float(req_data.get("aggressiveness", req_data.get("base_aggressiveness", 50.0)))
        use_tool_overrides = bool(req_data.get("use_tool_overrides", True))
        tool_aggr_map = req_data.get("tool_aggressiveness_map", {}) # {tool_index_str: aggr_val}
        
        clean_existing_for_material = bool(req_data.get("clean_existing_for_material", True))
        clean_all_non_toolwiz = bool(req_data.get("clean_all_non_toolwiz", False))
        
        coating = req_data.get("coating", "AlTiN")
        max_rpm = float(req_data.get("maxRpm", 16000))
        max_hp = float(req_data.get("maxHp", 10.0))
        runout = float(req_data.get("runout", 0.0002))
        
        library_data = bm.load_working_library()
        if not library_data or "tools" not in library_data:
            return jsonify({"success": False, "error": "No working library found to modify."}), 400
            
        tools = library_data["tools"]
        indices_to_update = list(range(len(tools))) if tool_indices == "all" else [int(i) for i in tool_indices]
        
        custom_preset_name = req_data.get("custom_preset_name", "").strip()
        material_label = alloy if alloy else family
        
        updated_tools_count = 0
        total_presets_injected = 0
        
        for idx in indices_to_update:
            if idx < 0 or idx >= len(tools):
                continue
                
            raw_t = tools[idx]
            t_dict = json.loads(raw_t) if isinstance(raw_t, str) else dict(raw_t)
            
            if t_dict.get("type") == "holder":
                continue
                
            tool_type = t_dict.get("type", "end mill").lower()
            valid_milling_types = [
                "end mill", "flat end mill", "ball end mill", "bull nose end mill", 
                "chamfer mill", "face mill", "slot mill", "tapered mill", 
                "dovetail mill", "lollipop mill", "radius mill", "form mill",
                "engraving chamfer mill", "thread mill"
            ]
            valid_drilling_types = [
                "drill", "spot drill", "center drill", "tap", "tap right hand", "tap left hand", "reamer", "bore", "counterbore", "countersink"
            ]
            
            is_milling = any(m in tool_type for m in ["mill", "end mill", "face", "slot", "fly", "router"])
            is_drilling = any(d in tool_type for d in ["drill", "tap", "reamer", "bore", "sink"])
            
            if not is_milling and not is_drilling:
                is_milling = True  # Default to milling physics
                
            geo = t_dict.get("geometry", {})
            tool_unit = t_dict.get("unit", geo.get("unit", ""))
            
            diameter = parse_dim(geo.get("DC", 6.35), tool_unit)
            flutes = int(geo.get("NOF", 4)) if is_milling else int(geo.get("NOF", 2))
            flute_len = parse_dim(geo.get("LCF", 25.4), tool_unit)
            shank_dia = parse_dim(geo.get("SF", diameter), tool_unit)
            corner_rad = parse_dim(geo.get("RE", 0.0), tool_unit)
            stickout = parse_dim(t_dict.get("stickout", flute_len * 1.5), tool_unit)
            is_carbide = True

            # Determine tool aggressiveness:
            # 1. Check if an explicit override was passed in tool_aggr_map
            str_idx = str(idx)
            if str_idx in tool_aggr_map:
                override_val = tool_aggr_map[str_idx]
                if override_val is not None and str(override_val).lower() != "default":
                    t_dict["custom_aggressiveness"] = float(override_val)
                else:
                    t_dict.pop("custom_aggressiveness", None)

            # 2. Resolve effective aggressiveness
            if use_tool_overrides and t_dict.get("custom_aggressiveness") is not None:
                effective_aggr_val = float(t_dict["custom_aggressiveness"])
            else:
                effective_aggr_val = float(base_aggressiveness)

            aggressiveness = effective_aggr_val / 100.0 if effective_aggr_val > 1.0 else effective_aggr_val

            # Geometry classification
            if "slot" in tool_type or "woodruff" in tool_type or "keyseat" in tool_type:
                geometry = "T-Slot"
            elif "dovetail" in tool_type:
                geometry = "Dovetail"
            elif "lollipop" in tool_type:
                geometry = "Lollipop"
            elif "thread" in tool_type:
                geometry = "Thread Mill"
            elif "chamfer" in tool_type or "engraving" in tool_type:
                geometry = "Chamfer"
            elif "ball" in tool_type or "radius" in tool_type:
                geometry = "Ball Nose"
            elif "bull" in tool_type:
                geometry = "Bull Nose"
            else:
                geometry = "Square" if corner_rad == 0 else "Radiused"

            # Clean stale or prior presets if requested
            if clean_existing_for_material or clean_all_non_toolwiz:
                target_mat = material_label if clean_existing_for_material else None
                t_dict, _ = clean_tool_presets(t_dict, clean_all_non_toolwiz=clean_all_non_toolwiz, target_material_to_replace=target_mat)

            if "start-values" not in t_dict:
                t_dict["start-values"] = {}
            if "presets" not in t_dict["start-values"]:
                t_dict["start-values"]["presets"] = []
                
            presets_list = t_dict["start-values"]["presets"]

            if is_drilling:
                is_tap = "tap" in tool_type
                db_tool_type = "Tapping" if is_tap else ("HP Carbide Twist Drill" if is_carbide else "Carbide Twist Drill")
                
                target_sfm = physics.get_base_sfm(family, db_tool_type, diameter=diameter)
                adj_ipt = physics.get_base_ipt(family, db_tool_type, diameter, runout=runout)
                
                target_sfm, adj_ipt = physics.apply_alloy_hardness_scaling(family, alloy, target_sfm, adj_ipt)
                target_sfm, adj_ipt = physics.apply_chatter_penalty(target_sfm, adj_ipt, diameter, stickout, is_drilling=True)
                
                if not is_tap:
                    target_sfm, adj_ipt = physics.apply_aggressiveness(target_sfm, adj_ipt, aggressiveness)
                
                rpm = physics.calc_rpm(target_sfm, diameter, max_rpm=max_rpm)
                
                if is_tap:
                    tp = parse_dim(geo.get("TP", 1.0), tool_unit)
                    feedrate = rpm * tp
                    adj_ipt = tp
                else:
                    feedrate = physics.calc_feedrate(rpm, flutes, adj_ipt)
                    
                actual_sfm = physics.calc_sfm(rpm, diameter)
                final_preset_name = custom_preset_name if custom_preset_name else f"{material_label} - Drilling"
                
                if tool_unit == "inches":
                    p_n = float(rpm)
                    p_vc = float(actual_sfm)
                    p_fz = float(adj_ipt)
                    p_vf = float(feedrate)
                else:
                    p_n = float(rpm)
                    p_vc = float(actual_sfm * 0.3048)
                    p_fz = float(adj_ipt * 25.4)
                    p_vf = float(feedrate * 25.4)
                    
                preset_dict = {
                    "guid": str(uuid.uuid4()),
                    "name": final_preset_name,
                    "description": final_preset_name,
                    "material": {
                        "category": "all",
                        "query": material_label,
                        "use-hardness": False
                    },
                    "n": int(p_n),
                    "v_c": p_vc,
                    "f_z": p_fz,
                    "f_n": float(p_fz * flutes),
                    "v_f": p_vf,
                    "v_f_leadIn": p_vf,
                    "v_f_leadOut": p_vf,
                    "v_f_transition": p_vf,
                    "v_f_ramp": p_vf,
                    "v_f_plunge": p_vf,
                    "v_f_retract": p_vf * 2.0,
                    "use-feed-per-revolution": False,
                    "tool-coolant": "flood"
                }
                
                existing_idx = next((i for i, p in enumerate(presets_list) if p.get("name") == final_preset_name), None)
                if existing_idx is not None:
                    preset_dict["guid"] = presets_list[existing_idx].get("guid", preset_dict["guid"])
                    presets_list[existing_idx].update(preset_dict)
                else:
                    presets_list.append(preset_dict)
                total_presets_injected += 1
                
            elif is_milling:
                is_saw = any(s in geometry.lower() for s in ["t-slot", "woodruff", "keyseat"]) or any(s in tool_type.lower() for s in ["woodruff", "saw"])
                for strat in strategies:
                    target_sfm = physics.get_base_sfm(family, "Carbide Endmill", geometry=geometry, diameter=diameter)
                    base_ipt = physics.get_base_ipt(family, "Carbide Endmill", diameter, geometry=geometry, runout=runout, flutes=flutes, is_carbide=is_carbide)
                    
                    target_sfm, base_ipt = physics.apply_alloy_hardness_scaling(family, alloy, target_sfm, base_ipt)
                    target_sfm, base_ipt = physics.apply_chatter_penalty(target_sfm, base_ipt, diameter, stickout, is_drilling=False, is_saw_woodruff=is_saw)
                    
                    target_sfm, base_ipt = physics.apply_aggressiveness(target_sfm, base_ipt, aggressiveness)
                    target_sfm *= physics.get_coating_multiplier(coating, family)
                    
                    rpm = physics.calc_rpm(target_sfm, diameter, max_rpm=max_rpm)
                    rec_doc, rec_woc, _ = physics.recommend_cut_parameters(
                        diameter, shank_dia, stickout, flutes, rpm, base_ipt, is_carbide, strat, aggressiveness, geometry, flute_len, max_hp, material_family=family, flute_length=flute_len,
                        corner_radius=corner_rad
                    )
                    
                    eff_dia = physics.calc_effective_diameter(diameter, rec_doc, geometry, corner_rad)
                    adj_ipt = physics.calc_adjusted_chipload(base_ipt, rec_doc, rec_woc, diameter, eff_dia, operation=strat, geometry=geometry, corner_radius=corner_rad)
                    feedrate = physics.calc_feedrate(rpm, flutes, adj_ipt)
                    actual_sfm = physics.calc_sfm(rpm, diameter)
                    ramp_angle, ramp_feed, plunge_feed = physics.calc_ramping(family, diameter, feedrate, geometry, flutes, aggressiveness, tool_type=tool_type)
                    
                    wear_comp_note = ""
                    if "finish" in strat.lower():
                        deflection = physics.tool_deflection(
                            diameter, shank_dia, stickout, rec_doc, rec_woc, feedrate, rpm, flutes,
                            is_carbide=is_carbide, material_family=family, flute_length=flute_len
                        )
                        sb, total_err, wear_comp = physics.calc_springback_and_deflection(
                            family, diameter, rec_doc, rec_woc, feedrate, rpm, flutes, deflection, alloy=alloy
                        )
                        if abs(wear_comp) > 0.0002:
                            wear_comp_note = f" | Wear Comp: {wear_comp:+.4f}\""

                    if custom_preset_name:
                        preset_name = f"{custom_preset_name} - {strat}"
                    else:
                        preset_name = f"{material_label} - {strat}"
                    
                    if tool_unit == "inches":
                        p_n = float(rpm)
                        p_vc = float(actual_sfm)
                        p_fz = float(adj_ipt)
                        p_vf = float(feedrate)
                        p_vf_ramp = float(ramp_feed)
                        p_vf_plunge = float(max(plunge_feed, 0.0001)) if feedrate > 0.0 else 0.0
                        p_stepdown = float(rec_doc)
                        p_stepover = float(rec_woc)
                    else:
                        p_n = float(rpm)
                        p_vc = float(actual_sfm * 0.3048)
                        p_fz = float(adj_ipt * 25.4)
                        p_vf = float(feedrate * 25.4)
                        p_vf_ramp = float(ramp_feed * 25.4)
                        p_vf_plunge = float(max(plunge_feed * 25.4, 0.0025)) if feedrate > 0.0 else 0.0
                        p_stepdown = float(rec_doc * 25.4)
                        p_stepover = float(rec_woc * 25.4)
                    
                    preset_desc = f"{preset_name}{wear_comp_note} (Aggressiveness: {int(aggressiveness*100)}%)"

                    preset_dict = {
                        "guid": str(uuid.uuid4()),
                        "name": preset_name,
                        "description": preset_desc,
                        "material": {
                            "category": "all",
                            "query": material_label,
                            "use-hardness": False
                        },
                        "n": int(p_n),
                        "n_ramp": int(p_n),
                        "v_c": p_vc,
                        "f_z": p_fz,
                        "f_n": float(p_fz * flutes),
                        "v_f": p_vf,
                        "v_f_leadIn": p_vf,
                        "v_f_leadOut": p_vf,
                        "v_f_transition": p_vf,
                        "v_f_ramp": p_vf_ramp,
                        "v_f_plunge": p_vf_plunge,
                        "stepdown": p_stepdown,
                        "stepover": p_stepover,
                        "use-stepdown": True,
                        "use-stepover": True,
                        "ramp-angle": float(ramp_angle),
                        "tool-coolant": "flood"
                    }
                    
                    existing_idx = next((i for i, p in enumerate(presets_list) if p.get("name") == preset_name), None)
                    if existing_idx is not None:
                        preset_dict["guid"] = presets_list[existing_idx].get("guid", preset_dict["guid"])
                        presets_list[existing_idx].update(preset_dict)
                    else:
                        presets_list.append(preset_dict)
                        
                    total_presets_injected += 1
                
            tools[idx] = t_dict
            updated_tools_count += 1
            
        seen_guids = set()
        for i, t in enumerate(tools):
            if isinstance(t, str):
                t = json.loads(t)
            g = t.get("guid", "")
            if g in seen_guids or not g:
                t["guid"] = str(uuid.uuid4())
            seen_guids.add(t["guid"])
            tools[i] = t
            
        library_data["tools"] = tools
        lib_name = library_data.get("library_name", "Master_Shop_Tool_Crib")
        backup_info = bm.save_working_library(library_data, lib_name)
        
        return jsonify({
            "success": True,
            "updated_tools_count": updated_tools_count,
            "total_presets_injected": total_presets_injected,
            "backup": backup_info
        })
        
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/twin/get_import_payload", methods=["GET"])
def twin_get_import_payload():
    """Serves the latest Digital Twin JSON payload for the Fusion Add-in to re-import"""
    try:
        data = bm.load_working_library()
        if not data:
            return jsonify({"success": False, "error": "No working library found."}), 404
        return jsonify({"success": True, "library": data})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/twin/upload", methods=["POST"])
def twin_upload():
    """
    Handles manual drag-and-drop file uploads.
    Supports single or MULTIPLE .tools or .json files simultaneously, with
    automatic library merging and deduplication.
    """
    try:
        uploaded_files = request.files.getlist('files')
        if not uploaded_files and 'file' in request.files:
            uploaded_files = [request.files['file']]
            
        if not uploaded_files or uploaded_files[0].filename == '':
            return jsonify({"success": False, "error": "No file uploaded"}), 400

        merge_mode = request.form.get("merge_mode", "merge_deduplicate")
        parsed_libraries = []

        for file in uploaded_files:
            filename = file.filename.lower()
            library_data = None

            if filename.endswith('.json'):
                content = file.read().decode('utf-8')
                library_data = json.loads(content)
            elif filename.endswith('.tools'):
                with zipfile.ZipFile(file, 'r') as z:
                    json_files = [n for n in z.namelist() if n.endswith('.json')]
                    if json_files:
                        with z.open(json_files[0]) as f:
                            library_data = json.loads(f.read().decode('utf-8'))
            
            if not library_data:
                continue

            tools_list = []
            if isinstance(library_data, dict) and "data" in library_data:
                tools_list = library_data["data"]
            elif isinstance(library_data, list):
                tools_list = library_data
            elif isinstance(library_data, dict) and "tools" in library_data:
                tools_list = library_data["tools"]

            lib_name = file.filename.replace('.json', '').replace('.tools', '')
            parsed_libraries.append({
                "library_name": lib_name,
                "tools": tools_list
            })

        if not parsed_libraries:
            return jsonify({"success": False, "error": "No valid tool libraries could be parsed."}), 400

        if merge_mode == "append":
            current_data = bm.load_working_library()
            if current_data and current_data.get("tools"):
                parsed_libraries.insert(0, {
                    "library_name": current_data.get("library_name", "Current_Master_Library"),
                    "tools": current_data["tools"]
                })

        master_lib_name = "Master_Shop_Tool_Crib" if len(parsed_libraries) > 1 else parsed_libraries[0]["library_name"]
        auto_dedup = merge_mode != "raw"
        merged_library, summary = merge_multiple_libraries(parsed_libraries, master_library_name=master_lib_name, deduplicate=auto_dedup)

        backup_info = bm.save_working_library(merged_library, master_lib_name)

        return jsonify({
            "success": True,
            "library_name": master_lib_name,
            "tool_count": len(merged_library.get("tools", [])),
            "files_processed": len(parsed_libraries),
            "summary": summary,
            "backup": backup_info
        })
        
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/twin/download", methods=["GET"])
def twin_download():
    """Provides the active Digital Twin library as a downloadable .json file formatted for Fusion 360"""
    try:
        data = bm.load_working_library()
        if not data:
            return "No active library found", 404
            
        fusion_format = {
            "data": data.get("tools", [])
        }
        
        json_str = json.dumps(fusion_format, indent=2)
        lib_name = data.get("library_name", "ToolWiz_Master_Crib")
        
        mem_file = io.BytesIO()
        mem_file.write(json_str.encode('utf-8'))
        mem_file.seek(0)
        
        return send_file(
            mem_file,
            mimetype='application/json',
            as_attachment=True,
            download_name=f"{lib_name}.json"
        )
    except Exception as e:
        return str(e), 500

@app.route("/api/ai_chat", methods=["POST"])
def ai_chat():
    """Handles conversational AI Machinist inquiries with live ToolWiz telemetry"""
    try:
        data = request.get_json() or {}
        message = data.get("message", "").strip()
        if not message:
            return jsonify({"success": False, "error": "Message is required"}), 400
            
        context = data.get("context", {})
        api_key = data.get("apiKey", "").strip() or None
        preferred_model = data.get("model", "").strip() or None
        
        result = query_ai_machinist(message, context=context, api_key=api_key, preferred_model=preferred_model)
        return jsonify(result)
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/ai_models", methods=["GET"])
def ai_models():
    """Returns the list of available Gemini models for the configured or provided API key"""
    try:
        api_key = request.args.get("apiKey", "").strip() or os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY") or ""
        if not api_key:
            return jsonify({
                "success": True,
                "models": [
                    {"id": "auto", "name": "⚡ Auto-Detect Best (Recommended)"},
                    {"id": "gemini-2.5-pro", "name": "Gemini 2.5 Pro (Deep CAM Reasoning)"},
                    {"id": "gemini-2.5-flash", "name": "Gemini 2.5 Flash (Fast)"}
                ]
            })
            
        models, err = get_available_gemini_models(api_key)
        if err and "Authentication Error" in err:
            return jsonify({"success": False, "error": err}), 400
            
        result_list = [{"id": "auto", "name": "⚡ Auto-Detect Best (Recommended)"}]
        for m in (models or ["gemini-2.5-pro", "gemini-2.5-flash", "gemini-2.0-flash"]):
            clean = m.replace("models/", "").replace("gemini-", "").strip()
            parts = clean.split("-")
            words = [p.capitalize() if not (p.replace(".", "").isdigit()) else p for p in parts if p]
            friendly_name = " ".join(words)
            if not friendly_name.lower().startswith("gemini"):
                friendly_name = f"Gemini {friendly_name}"

            if "pro" in m.lower():
                label = f"{friendly_name} (Deep CAM Reasoning)"
            elif "flash" in m.lower():
                label = f"{friendly_name} (Fast)"
            else:
                label = friendly_name
            result_list.append({"id": m, "name": label})
            
        return jsonify({"success": True, "models": result_list})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

if __name__ == "__main__":
    # Run the Flask app on localhost:5000
    app.run(host="127.0.0.1", port=5000, debug=True)


