import os
import io
import json
import math
import uuid
import re
import logging
from flask import Flask, render_template, request, jsonify, send_file
from werkzeug.exceptions import HTTPException
from gwizard_physics import GWizardPhysics, is_tap_tool_type, is_drilling_tool_type
from ai_machinist import query_ai_machinist, get_available_gemini_models
from toolwiz_common import (
    ToolKind, classify, is_hole_kind, is_tap_kind, is_milling_kind,
    ToolGeometry, default_stickout, to_inches, UnitError, safe_eval_length,
    tool_unit as tool_unit_of,
)

safe_eval_expr = safe_eval_length  # backwards-compatible alias

app = Flask(__name__)
app.config["MAX_CONTENT_LENGTH"] = 50 * 1024 * 1024  # 50 MB upload/request cap

# Initialize physics engine
db_path = os.path.join(os.path.dirname(__file__), "materials_database_clean.json")
physics = GWizardPhysics(db_path)

# ---------------------------------------------------------------------------
# Machine profile (defaults for max RPM / max HP)
# ---------------------------------------------------------------------------
MACHINE_PROFILE_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "machines", "speedio_s500x2.json")
KW_TO_HP = 1.341
FALLBACK_MAX_RPM = 16000.0
FALLBACK_MAX_HP = 10.0


def load_machine_profile(path=MACHINE_PROFILE_PATH):
    """Load the machine profile and derive default max RPM / HP from the active spindle."""
    profile = {}
    try:
        with open(path, "r", encoding="utf-8") as fh:
            profile = json.load(fh)
    except (OSError, ValueError) as exc:
        logging.getLogger(__name__).warning("Machine profile %s unavailable: %s", path, exc)
        profile = {}
    max_rpm, max_hp, active = FALLBACK_MAX_RPM, FALLBACK_MAX_HP, None
    try:
        active = profile.get("active_spindle")
        spindle = (profile.get("spindle_options") or {}).get(active) or {}
        if spindle.get("max_rpm"):
            max_rpm = float(spindle["max_rpm"])
        if spindle.get("power_kw_continuous"):
            max_hp = round(float(spindle["power_kw_continuous"]) * KW_TO_HP, 2)
    except (TypeError, ValueError):
        max_rpm, max_hp = FALLBACK_MAX_RPM, FALLBACK_MAX_HP
    profile = dict(profile)
    profile["active_spindle"] = active
    profile["max_rpm"] = max_rpm
    profile["max_hp"] = max_hp
    return profile


MACHINE = load_machine_profile()
DEFAULT_MAX_RPM = MACHINE["max_rpm"]
DEFAULT_MAX_HP = MACHINE["max_hp"]

ALLOWED_ORIGINS = ("http://127.0.0.1:5000", "http://localhost:5000")
CLIENT_HEADER = "X-ToolWiz-Client"


@app.before_request
def csrf_guard():
    """Drive-by / CSRF protection for state-changing API calls.

    Browsers cannot attach a custom header cross-origin without a CORS preflight
    (which this server never grants), so requiring X-ToolWiz-Client blocks drive-by
    form posts. A present Origin header must additionally be our own origin.
    """
    if request.method in ("POST", "PUT", "PATCH", "DELETE") and request.path.startswith("/api/"):
        if not (request.headers.get(CLIENT_HEADER) or "").strip():
            return jsonify({"success": False, "error": f"Missing {CLIENT_HEADER} header"}), 403
        origin = request.headers.get("Origin")
        if origin is not None and origin.rstrip("/") not in ALLOWED_ORIGINS:
            return jsonify({"success": False, "error": "Cross-origin request rejected"}), 403
    return None


def _json_body():
    """Request JSON body as a dict ({} when missing/invalid)."""
    data = request.get_json(silent=True)
    return data if isinstance(data, dict) else {}


def _api_error(exc):
    """Map an exception from an API handler to a JSON error response."""
    if isinstance(exc, HTTPException):
        return jsonify({"success": False, "error": exc.description or exc.name}), (exc.code or 500)
    if isinstance(exc, KeyError):
        key = exc.args[0] if exc.args else ""
        return jsonify({"success": False, "error": f"Missing required field: {key}"}), 400
    if isinstance(exc, (ValueError, TypeError)):
        return jsonify({"success": False, "error": f"Invalid input: {exc}"[:300]}), 400
    app.logger.error("Unhandled error in %s %s", request.method, request.path, exc_info=exc)
    return jsonify({"success": False, "error": "Internal server error"}), 500


@app.errorhandler(413)
def _too_large(_e):
    return jsonify({"success": False, "error": "Request too large (limit 50 MB)"}), 413

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
        "alloys": physics.specific_alloys,
        "machine": MACHINE
    })

@app.route("/api/calculate", methods=["POST"])
def calculate():
    """Calculate physics engine parameters from incoming JSON data"""
    try:
        data = _json_body()
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
        max_rpm = float(data.get("maxRpm", DEFAULT_MAX_RPM))
        max_hp = float(data.get("maxHp", DEFAULT_MAX_HP))
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
        
        is_hole_tool = is_drilling_tool_type(tool, geometry)
        is_tapping = is_tap_tool_type(tool) or is_tap_tool_type(operation) or (is_hole_tool and any(t in geo_lower for t in ["form", "spiral_flute", "spiral_point", "straight_flute"]))

        # Chatter / Resonance penalty based on stickout length (8xD threshold for hole tools vs 3.5xD for milling; bypassed for saws/woodruff)
        target_sfm, base_ipt = physics.apply_chatter_penalty(
            target_sfm, base_ipt, diameter, stickout, is_drilling=is_hole_tool, is_saw_woodruff=is_saw_woodruff, flute_length=flute_length
        )
        
        if not is_tapping:
            target_sfm, base_ipt = physics.apply_aggressiveness(target_sfm, base_ipt, aggressiveness)
            # High Efficiency Milling (HEM) low-immersion thermal cooling speed boost
            hem_sfm_mult = physics.calc_hem_thermal_sfm_multiplier(cut_width, diameter, operation=operation)
            target_sfm *= hem_sfm_mult
        
        # Apply Coating Modifier (never for taps: tapping SFM already includes the form/cut factor)
        if not is_tapping:
            target_sfm *= physics.get_coating_multiplier(coating, family)
        
        effective_diameter = physics.calc_effective_diameter(diameter, cut_depth, geometry, corner_radius)
        
        # 2. Physics Equations
        ideal_rpm = (target_sfm * 12.0) / (math.pi * effective_diameter) if effective_diameter > 0 else 0.0
        is_spindle_limited = bool(max_rpm > 0 and ideal_rpm > (max_rpm * 1.005))
        rpm = physics.calc_rpm(target_sfm, effective_diameter, max_rpm=max_rpm)
        
        if is_hole_tool:
            cut_width = diameter
            if any(m in operation.lower() for m in ["rough", "adaptive", "trochoidal", "slot", "face", "finish"]):
                if is_tap_tool_type(tool):
                    operation = "Rigid Tapping"
                elif "ream" in tool.lower():
                    operation = "Precision Reaming"
                else:
                    operation = "Drilling"

        tap_drill_info = None
        if is_tap_tool_type(tool) or is_tap_tool_type(operation):
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
        contact_sfm = physics.calc_sfm(rpm, effective_diameter)
        # 3. Ramping Params
        ramp_angle, ramp_feed, plunge_feed = physics.calc_ramping(family, diameter, feedrate, geometry, flutes, aggressiveness, tool_type=tool)
        
        op_lower = str(operation).lower()
        is_roughing_op = any(r in op_lower for r in ["rough", "adaptive", "clearing", "pocket", "trochoidal", "hem", "slot"])
        is_floor_finish = any(s in op_lower for s in ["floor", "facing", "flat", "horizontal", "face"]) and not is_roughing_op
        is_finishing = ("finish" in op_lower or is_floor_finish or (cut_width <= (diameter * 0.15) and not is_roughing_op)) and not is_roughing_op

        if is_hole_tool:
            deflection = 0.0
            springback = 0.0
            total_error = 0.0
            wear_comp = 0.0
            radial_comp = 0.0
            axial_comp = 0.0
        else:
            deflection = physics.tool_deflection(
                diameter, shank_size, stickout, cut_depth, cut_width, feedrate, rpm, flutes, is_carbide, material_family=family,
                helix_angle=helix_angle, neck_length=neck_length, taper_angle=taper_angle, flute_length=flute_length, neck_diameter=neck_diameter,
                operation=operation, geometry=geometry, corner_radius=corner_radius
            )
            springback, total_error, wear_comp = physics.calc_springback_and_deflection(
                family, diameter, cut_depth, cut_width, feedrate, rpm, flutes, deflection, alloy=alloy
            )
            radial_comp = wear_comp
            axial_comp = -springback
        
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
        
        rec_details = {}
        rec_doc, rec_woc, rec_limit = physics.recommend_cut_parameters(
            diameter, shank_size, stickout, flutes, rpm, base_ipt, is_carbide, operation, aggressiveness, geometry, cutter_thickness, max_hp, material_family=family,
            helix_angle=helix_angle, neck_length=neck_length, taper_angle=taper_angle, flute_length=flute_length, neck_diameter=neck_diameter,
            corner_radius=corner_radius, details=rec_details
        )
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
            "radial_comp": round(radial_comp, 6),
            "axial_comp": round(axial_comp, 6),
            "is_floor_finish": is_floor_finish,
            "is_finishing": is_finishing,
            "sfm": round(actual_sfm, 1),
            "effective_diameter": round(effective_diameter, 5),
            "contact_sfm": round(contact_sfm, 1),
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
            "feasible": feasible,
            "limited_by": limited_by,
            "tips": tips
        }
        if tap_drill_info:
            resp["tap_drill"] = tap_drill_info
            resp["tap_type"] = tap_type
        return jsonify(resp)
        
    except Exception as e:
        return _api_error(e)

@app.route("/api/calculate_for_fusion", methods=["POST"])
def calculate_for_fusion():
    """Endpoint specifically designed for the Fusion 360 Add-in"""
    try:
        data = _json_body()
        family = data.get("family", "")
        tool = data.get("tool", "Carbide Endmill") # default fallback
        operation = data.get("operation", "Roughing")
        aggressiveness = float(data.get("aggressiveness", 50.0)) / 100.0
        max_rpm = float(data.get("maxRpm", DEFAULT_MAX_RPM))
        max_hp = float(data.get("maxHp", DEFAULT_MAX_HP))
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
        
        # Alloy-specific hardness adjustment
        alloy = data.get("alloy", "")
        target_sfm, base_ipt = physics.apply_alloy_hardness_scaling(family, alloy, target_sfm, base_ipt)
        
        is_hole_tool = is_drilling_tool_type(tool, geometry)
        is_tapping = is_tap_tool_type(tool) or is_tap_tool_type(geometry)
        target_sfm, base_ipt = physics.apply_chatter_penalty(
            target_sfm, base_ipt, diameter, stickout, is_drilling=is_hole_tool, is_saw_woodruff=is_saw_woodruff, flute_length=flute_length
        )

        target_sfm, base_ipt = physics.apply_aggressiveness(target_sfm, base_ipt, aggressiveness)
        if not is_tapping:
            target_sfm *= physics.get_coating_multiplier(coating, family)
        
        # 2. Physics Equations
        rpm = physics.calc_rpm(target_sfm, diameter, max_rpm=max_rpm)
        # Using recommended DOC and WOC for the final feedrate
        rec_details = {}
        rec_doc, rec_woc, rec_limit = physics.recommend_cut_parameters(
            diameter, shank_size, stickout, flutes, rpm, base_ipt, is_carbide, operation, aggressiveness, geometry, cutter_thickness, max_hp, material_family=family,
            helix_angle=helix_angle, neck_length=neck_length, taper_angle=taper_angle, flute_length=flute_length, neck_diameter=neck_diameter,
            corner_radius=corner_radius, details=rec_details
        )
        
        # High Efficiency Milling (HEM) low-immersion thermal cooling speed boost
        hem_sfm_mult = physics.calc_hem_thermal_sfm_multiplier(rec_woc, diameter, operation=operation)
        target_sfm *= hem_sfm_mult
        rpm = physics.calc_rpm(target_sfm, diameter, max_rpm=max_rpm)
        
        effective_diameter = physics.calc_effective_diameter(diameter, rec_doc, geometry, corner_radius)
        ideal_rpm = (target_sfm * 12.0) / (math.pi * effective_diameter) if effective_diameter > 0 else 0.0
        is_spindle_limited = bool(max_rpm > 0 and ideal_rpm > (max_rpm * 1.005))
        rpm = physics.calc_rpm(target_sfm, effective_diameter, max_rpm=max_rpm)
        
        adjusted_ipt = physics.calc_adjusted_chipload(base_ipt, rec_doc, rec_woc, diameter, effective_diameter, operation=operation, geometry=geometry, corner_radius=corner_radius)
        feedrate = physics.calc_feedrate(rpm, flutes, adjusted_ipt)
        actual_sfm = physics.calc_sfm(rpm, diameter)
        contact_sfm = physics.calc_sfm(rpm, effective_diameter)
        
        # 3. Ramping Params
        tool_val = data.get("tool", "")
        ramp_angle, ramp_feed, plunge_feed = physics.calc_ramping(family, diameter, feedrate, geometry, flutes, aggressiveness, tool_type=tool_val)
        
        return jsonify({
            "success": True,
            "name": f"ToolWiz: {family} - {operation}",
            "rpm": round(rpm),
            "feed": round(feedrate, 2),
            "sfm": round(actual_sfm, 1),
            "effective_diameter": round(effective_diameter, 5),
            "contact_sfm": round(contact_sfm, 1),
            "ipt": round(adjusted_ipt, 6),
            "doc": round(rec_doc, 3),
            "woc": round(rec_woc, 3),
            "ramp_feed": round(ramp_feed, 2),
            "plunge_feed": max(round(plunge_feed, 4), 0.0001) if feedrate > 0.0 else 0.0,
            "is_spindle_limited": is_spindle_limited,
            "ideal_rpm": round(ideal_rpm),
            "feasible": bool(rec_details.get("feasible", True)),
            "limited_by": rec_details.get("limited_by")
        })
        
    except Exception as e:
        return _api_error(e)

@app.route("/api/threads/standards", methods=["GET"])
def get_thread_standards():
    """Return available thread families, sizes, and classes from the database."""
    try:
        data = physics.get_thread_standards()
        return jsonify({"success": True, **data})
    except Exception as e:
        return _api_error(e)

@app.route("/api/threads/calculate", methods=["POST"])
def calculate_thread():
    """Calculate thread specifications, G-Wizard tapping drill table, and blind hole clearance."""
    try:
        data = _json_body()
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
        return _api_error(e)

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

_HSS_RE = re.compile(r"\b(hss|hss-e|hsse|hss-co|cobalt|high[\s-]?speed(?:\s+steel)?|powder\s+metal|pm)\b", re.I)

def tool_is_carbide(t_dict):
    """Carbide unless the tool's material/grade/description clearly says HSS/cobalt/HSS-E/PM."""
    geo = t_dict.get("geometry") or {}
    parts = [t_dict.get("material"), geo.get("material"), t_dict.get("grade"), geo.get("grade"),
             (t_dict.get("postProcess") or {}).get("material"), t_dict.get("description")]
    text = " ".join(json.dumps(p) if isinstance(p, (dict, list)) else str(p) for p in parts if p)
    if "carbide" in text.lower():
        return True
    return not _HSS_RE.search(text)

def parse_dim(val, tool_unit=""):
    """Helper to parse tool dimensions from JSON to inches"""
    return parse_dimension_in(val, tool_unit)

@app.route("/api/twin/export_receive", methods=["POST"])
def twin_export_receive():
    """Receives exported tool library (or multiple libraries) JSON from Fusion 360 Add-in"""
    try:
        data = _json_body()
        if not data:
            return jsonify({"success": False, "error": "No JSON payload received"}), 400
            
        libraries_list = data.get("libraries")
        auto_dedup = bool(data.get("deduplicate", False))
        
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
        return _api_error(e)

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
        return _api_error(e)

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
            kind = classify(t_dict.get("type"))
            geo_error = None
            try:
                unit_label = tool_unit_of(t_dict)
            except (UnitError, ValueError, TypeError):
                unit_label = None
            try:
                g = ToolGeometry.from_fusion(t_dict, stickout_override=t_dict.get("stickout"))
                dia_in, flutes, flute_len = g.diameter, g.flutes, g.flute_length
                shank_dia, corner_rad = g.shank_diameter, g.corner_radius
                stickout, stickout_source = g.stickout, g.stickout_source
            except (UnitError, ValueError, TypeError) as ge:
                geo_error = str(ge)
                dia_in = flutes = flute_len = shank_dia = corner_rad = stickout = 0
                stickout_source = "unavailable"

            t_num = t_dict.get("postProcess", {}).get("number", t_dict.get("post-process", {}).get("number", 0))
            desc = t_dict.get("description", f"{dia_in:.3f}in Tool")
            t_type = t_dict.get("type") or geo.get("type") or "end mill"
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
                    "operation_type": p.get("operation_type", ""),
                    "is_toolwiz": bool(p.get("operation_type")) or " - " in p_name,
                    "material_query": p_mat,
                    "rpm": p.get("n", p.get("rpm", 0)),
                    "n": p.get("n", p.get("rpm", 0)),
                    "feed": p.get("v_f", p.get("feed", 0)),
                    "v_f": p.get("v_f", p.get("feed", 0)),
                    "sfm": p.get("v_c", p.get("sfm", 0)),
                    "v_c": p.get("v_c", p.get("sfm", 0)),
                    "ipt": p.get("f_z", p.get("ipt", 0)),
                    "f_z": p.get("f_z", p.get("ipt", 0)),
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
                "stickout_source": stickout_source,
                "tool_kind": kind.value,
                "unit": unit_label,
                "is_metric": unit_label == "millimeters",
                "geometry_error": geo_error,
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
        return _api_error(e)

@app.route("/api/twin/backups", methods=["GET", "POST"])
def twin_backups():
    """List or restore backups"""
    try:
        if request.method == "POST":
            filename = _json_body().get("filename")
            if not filename:
                return jsonify({"success": False, "error": "Filename required"}), 400
            restored = bm.restore_backup(filename)
            return jsonify({"success": True, "restored": filename})
        else:
            return jsonify({"backups": bm.list_backups()})
    except Exception as e:
        return _api_error(e)

@app.route("/api/twin/update_tool", methods=["POST"])
def twin_update_tool():
    """Updates a single tool's metadata, custom aggressiveness override, or dimensions"""
    try:
        payload = _json_body()
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
        return _api_error(e)

@app.route("/api/twin/delete_tool", methods=["POST"])
def twin_delete_tool():
    """Safely deletes a tool from the working library and creates a backup snapshot"""
    try:
        payload = _json_body()
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
        return _api_error(e)

@app.route("/api/twin/delete_preset", methods=["POST"])
def twin_delete_preset():
    try:
        payload = _json_body()
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
        return _api_error(e)

@app.route("/api/twin/batch_generate", methods=["POST"])
def twin_batch_generate():
    """
    Batch calculates and injects multi-operation presets into selected tools.
    Supports per-tool aggressiveness overrides, clean replacement of prior presets,
    and automatic springback & wear compensation calculations.
    """
    try:
        req_data = _json_body()
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
        max_rpm = float(req_data.get("maxRpm", DEFAULT_MAX_RPM))
        max_hp = float(req_data.get("maxHp", DEFAULT_MAX_HP))
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
        skipped = []
        
        for idx in indices_to_update:
            if idx < 0 or idx >= len(tools):
                continue
                
            raw_t = tools[idx]
            t_dict = json.loads(raw_t) if isinstance(raw_t, str) else dict(raw_t)
            
            tool_type = str(t_dict.get("type") or "").lower()
            geo = t_dict.get("geometry", {}) or {}
            kind = classify(t_dict.get("type"))
            tool_number = t_dict.get("postProcess", {}).get("number", t_dict.get("post-process", {}).get("number"))

            def _skip(reason, idx=idx, t_dict=t_dict, tool_number=tool_number):
                skipped.append({
                    "tool_index": idx,
                    "number": tool_number,
                    "description": t_dict.get("description", ""),
                    "type": t_dict.get("type", ""),
                    "reason": reason,
                })

            if kind in (ToolKind.HOLDER, ToolKind.PROBE):
                _skip(f"{kind.value} is not a cutting tool")
                continue
            if kind is ToolKind.UNKNOWN:
                _skip(f"unrecognized tool type {t_dict.get('type')!r}")
                continue
            try:
                g = ToolGeometry.from_fusion(t_dict, stickout_override=t_dict.get("stickout"))
                t_unit = tool_unit_of(t_dict)
            except (UnitError, ValueError, TypeError) as ge:
                _skip(f"invalid geometry: {ge}")
                continue
            if is_tap_kind(kind) and g.thread_pitch is None:
                _skip("tap has no thread pitch (TP); refusing to assume one")
                continue

            is_drilling = is_hole_kind(kind)
            is_tap = is_tap_kind(kind)
            is_milling = is_milling_kind(kind)
            diameter, flutes, flute_len = g.diameter, g.flutes, g.flute_length
            shank_dia, corner_rad, stickout = g.shank_diameter, g.corner_radius, g.stickout
            is_carbide = tool_is_carbide(t_dict)

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
            if kind is ToolKind.SLOT:
                geometry = "T-Slot"
            elif kind is ToolKind.DOVETAIL:
                geometry = "Dovetail"
            elif kind is ToolKind.LOLLIPOP:
                geometry = "Lollipop"
            elif kind is ToolKind.THREAD_MILL:
                geometry = "Thread Mill"
            elif kind is ToolKind.CHAMFER:
                geometry = "Chamfer"
            elif kind in (ToolKind.BALL, ToolKind.RADIUS):
                geometry = "Ball Nose"
            elif kind is ToolKind.BULL:
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
                db_tool_type = "Tapping" if is_tap else ("HP Carbide Twist Drill" if is_carbide else "Carbide Twist Drill")
                
                target_sfm = physics.get_base_sfm(family, db_tool_type, diameter=diameter)
                adj_ipt = physics.get_base_ipt(family, db_tool_type, diameter, runout=runout)
                
                target_sfm, adj_ipt = physics.apply_alloy_hardness_scaling(family, alloy, target_sfm, adj_ipt)
                target_sfm, adj_ipt = physics.apply_chatter_penalty(target_sfm, adj_ipt, diameter, stickout, is_drilling=True)
                
                if not is_tap:
                    target_sfm, adj_ipt = physics.apply_aggressiveness(target_sfm, adj_ipt, aggressiveness)
                
                rpm = physics.calc_rpm(target_sfm, diameter, max_rpm=max_rpm)
                
                if is_tap:
                    tp = g.thread_pitch
                    feedrate = rpm * tp
                    adj_ipt = tp
                else:
                    feedrate = physics.calc_feedrate(rpm, flutes, adj_ipt)
                    
                actual_sfm = physics.calc_sfm(rpm, diameter)
                op_suffix = "Tapping" if is_tap else "Drilling"
                final_preset_name = custom_preset_name if custom_preset_name else f"{material_label} - {op_suffix}"
                
                if t_unit == "inches":
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
                    rec_details = {}
                    rec_doc, rec_woc, _ = physics.recommend_cut_parameters(
                        diameter, shank_dia, stickout, flutes, rpm, base_ipt, is_carbide, strat, aggressiveness, geometry, flute_len, max_hp, material_family=family, flute_length=flute_len,
                        corner_radius=corner_rad, details=rec_details
                    )
                    if not rec_details.get("feasible", True):
                        skipped.append({
                            "tool_index": idx,
                            "number": tool_number,
                            "description": t_dict.get("description", ""),
                            "type": t_dict.get("type", ""),
                            "strategy": strat,
                            "reason": f"infeasible strategy {strat!r}: no safe cut (limited by {rec_details.get('limited_by') or 'unknown'}); preset not written",
                        })
                        continue
                    
                    hem_sfm_mult = physics.calc_hem_thermal_sfm_multiplier(rec_woc, diameter, operation=strat)
                    target_sfm *= hem_sfm_mult
                    rpm = physics.calc_rpm(target_sfm, diameter, max_rpm=max_rpm)
                    
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
                    
                    if t_unit == "inches":
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
                        "operation_type": strat,
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
            "skipped": skipped,
            "backup": backup_info
        })
        
    except Exception as e:
        return _api_error(e)

@app.route("/api/twin/get_import_payload", methods=["GET"])
def twin_get_import_payload():
    """Serves the latest Digital Twin JSON payload for the Fusion Add-in to re-import"""
    try:
        data = bm.load_working_library()
        if not data:
            return jsonify({"success": False, "error": "No working library found."}), 404
        return jsonify({"success": True, "library": data})
    except Exception as e:
        return _api_error(e)

@app.route("/api/twin/upload", methods=["POST"])
def twin_upload():
    """
    Handles manual drag-and-drop file uploads.
    Supports single or MULTIPLE .tools or .json files simultaneously, with
    automatic library merging and deduplication.
    """
    try:
        uploaded_files = request.files.getlist('files') + request.files.getlist('file')
            
        if not uploaded_files or uploaded_files[0].filename == '':
            return jsonify({"success": False, "error": "No file uploaded"}), 400

        merge_mode = request.form.get("merge_mode", "merge")
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
        auto_dedup = merge_mode == "merge_deduplicate"
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
        return _api_error(e)

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
        app.logger.error("Library download failed", exc_info=e)
        return "Internal server error", 500

@app.route("/api/ai_chat", methods=["POST"])
def ai_chat():
    """Handles conversational AI Machinist inquiries with live ToolWiz telemetry"""
    try:
        data = _json_body()
        message = data.get("message", "").strip()
        if not message:
            return jsonify({"success": False, "error": "Message is required"}), 400
            
        context = data.get("context", {})
        api_key = data.get("apiKey", "").strip() or None
        preferred_model = data.get("model", "").strip() or None
        
        result = query_ai_machinist(message, context=context, api_key=api_key, preferred_model=preferred_model)
        return jsonify(result)
    except Exception as e:
        return _api_error(e)

@app.route("/api/ai_models", methods=["GET", "POST"])
def ai_models():
    """Returns the list of available Gemini models for the configured or provided API key"""
    try:
        data = _json_body()
        api_key = (
            request.headers.get("x-goog-api-key")
            or request.headers.get("x-api-key")
            or data.get("apiKey")
            or os.environ.get("GEMINI_API_KEY")
            or os.environ.get("GOOGLE_API_KEY")
            or ""
        )
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
        return _api_error(e)

def clean_and_eval_stock_expr(expr_str, doc_unit="in"):
    """Evaluates dimension expressions like '(-.1) * 1mm', '(.1)*1mm', or '0mm'
    into clean, formatted numeric strings like '-0.100 mm' or '0.000 mm'.
    Uses safe AST parser without eval().
    """
    if expr_str is None or str(expr_str).strip() == "":
        return "0.000 mm" if doc_unit == "mm" else "0.0000 in"
    s = str(expr_str).strip()
    
    unit = doc_unit
    s_lower = s.lower()
    if "mm" in s_lower or "milli" in s_lower:
        unit = "mm"
    elif "in" in s_lower or '"' in s:
        unit = "in"
        
    try:
        math_str = re.sub(r'([0-9\.\)])\s*(?:mm|millimeter|millimetre|inches|inch|in|\")', r'\1 * 1.0', s, flags=re.I)
        math_str = re.sub(r'(?:mm|millimeter|millimetre|inches|inch|in|\")', r' 1.0 ', math_str, flags=re.I)
        if re.match(r'^[0-9\.\+\-\*\/\(\)\s]+$', math_str):
            val = float(safe_eval_length(math_str))
            if abs(val) < 1e-6:
                val = 0.0
            if unit == "mm":
                return f"{val:.3f} mm"
            else:
                return f"{val:.4f} in"
    except Exception:
        pass
    return s

@app.route("/api/stock_compensation", methods=["POST"])
def stock_compensation():
    """Calculates tool deflection, material springback, and recommended radial/axial stock to leave
    for a batch of Fusion 360 CAM operations.
    """
    try:
        data = _json_body()
        family = data.get("family", "Aluminum - Wrought (6061)")
        alloy = data.get("alloy", "")
        agg_raw = data.get("aggressiveness", 50)
        aggressiveness = float(agg_raw) / 100.0 if float(agg_raw) > 1.0 else float(agg_raw)
        mode = data.get("mode", "auto_compensate")  # auto_compensate, zero_finishing, custom
        custom_radial_offset = str(data.get("custom_radial_offset", "0.0000 in")).strip()
        custom_axial_offset = str(data.get("custom_axial_offset", "0.0000 in")).strip()
        operations = data.get("operations", [])
        
        results = []
        for op in operations:
            op_id = op.get("id", "")
            op_name = op.get("name", "Unknown Op")
            strat = op.get("strategy", "").lower()
            unit = str(op.get("unit", "")).lower()
            raw_rad = str(op.get("current_radial_stock", "")).strip()
            raw_ax = str(op.get("current_axial_stock", "")).strip()
            is_metric = "mm" in unit or "milli" in unit or "mm" in raw_rad.lower() or "mm" in raw_ax.lower()
            doc_unit = "mm" if is_metric else "in"
            
            # Explicit, deterministic units. Defaults: lengths in inches, feed in IPM.
            length_unit = str(op.get("length_unit", "in")).strip().lower()
            feed_unit = str(op.get("feed_unit", "ipm")).strip().lower()
            if length_unit in ("in", "inch", "inches"):
                len_factor = 1.0
            elif length_unit in ("mm", "millimeter", "millimeters"):
                len_factor = 1.0 / 25.4
            else:
                return jsonify({"success": False, "error": f"Operation {op_id!r}: invalid length_unit {length_unit!r} (use 'in' or 'mm')"}), 400
            if feed_unit in ("ipm", "in/min", "in_min"):
                feed_factor = 1.0
            elif feed_unit in ("mm_min", "mm/min", "mmpm"):
                feed_factor = 1.0 / 25.4
            else:
                return jsonify({"success": False, "error": f"Operation {op_id!r}: invalid feed_unit {feed_unit!r} (use 'ipm' or 'mm_min')"}), 400

            def _len_in(key, default_in):
                raw_v = op.get(key)
                return default_in if raw_v is None else float(raw_v) * len_factor

            # Geometry and cut parameters, converted to inches / IPM
            diameter = _len_in("diameter", 0.375)
            flutes = max(int(op.get("flutes", 4)), 1)
            flute_len = _len_in("fluteLength", diameter * 2.0)
            shank_dia = _len_in("shankDiameter", diameter)
            stickout = _len_in("stickout", 0.0)
            if stickout <= 0:
                stickout = default_stickout(diameter, flute_len)
            coating = op.get("coating", "Uncoated")
            geometry = op.get("geometry", "Square")

            rpm = float(op.get("rpm", 0.0))
            feedrate_ipm = float(op.get("feedrate", 0.0)) * feed_factor
            doc_in = _len_in("doc", 0.0)
            woc_in = _len_in("woc", 0.0)

            zero_rad_str = "0.000 mm" if is_metric else "0.0000 in"
            zero_ax_str = "0.000 mm" if is_metric else "0.0000 in"
            default_rough_rad = "0.500 mm" if is_metric else "0.0200 in"
            default_rough_ax = "0.250 mm" if is_metric else "0.0100 in"
            
            current_radial = clean_and_eval_stock_expr(raw_rad, doc_unit) if raw_rad else default_rough_rad
            current_axial = clean_and_eval_stock_expr(raw_ax, doc_unit) if raw_ax else default_rough_ax
            
            # Identify if Finishing vs Roughing, and Floor vs Wall
            strat_lower = strat.lower()
            name_lower = op_name.lower()
            
            is_floor_finish = any(s in strat_lower for s in ["flat", "face", "horizontal", "facing", "floor"])
            is_wall_finish = any(s in strat_lower for s in [
                "contour", "scallop", "pencil", "parallel", "morf", "ramp", "flow", "spiral", "finish", "swarf", "3d"
            ])
            is_rough_strat = any(s in strat_lower for s in [
                "adaptive", "pocket", "rough", "clearing", "cavity", "rest"
            ])
            
            if is_floor_finish or is_wall_finish:
                is_finishing = True
            elif is_rough_strat:
                is_finishing = False
                is_floor_finish = False
                is_wall_finish = False
            else:
                # Strategy unrecognized; inspect operation name
                if any(s in name_lower for s in ["rough", "adaptive", "clearing"]):
                    is_finishing = False
                    is_floor_finish = False
                    is_wall_finish = False
                elif any(s in name_lower for s in ["flat", "horizontal", "face", "facing", "floor", "skim"]):
                    is_finishing = True
                    is_floor_finish = True
                    is_wall_finish = False
                elif any(s in name_lower for s in ["finish", "contour", "wall", "scallop", "3d"]):
                    is_finishing = True
                    is_floor_finish = False
                    is_wall_finish = True
                else:
                    is_finishing = False
                
            # If doc/woc or feeds/speeds are missing, use standard finishing or roughing defaults
            if is_finishing:
                if is_floor_finish:
                    if doc_in <= 0:
                        doc_in = max(0.005, min(0.015, diameter * 0.05))
                    if woc_in <= 0:
                        woc_in = diameter * 0.65  # 65% stepover for floor/face
                elif any(s in strat_lower for s in ["3d", "scallop", "parallel"]) or any(s in name_lower for s in ["3d", "scallop"]):
                    if doc_in <= 0:
                        doc_in = min(0.015, max(0.003, diameter * 0.04))
                    if woc_in <= 0:
                        woc_in = max(0.005, min(0.040, diameter * 0.10))
                else:
                    if doc_in <= 0:
                        doc_in = flute_len * 0.75 if flute_len > 0 else diameter * 1.5
                    if woc_in <= 0:
                        woc_in = max(diameter * 0.04, 0.008)  # 4% D light finishing cut
                    woc_in = min(woc_in, max(diameter * 0.10, 0.025))
            else:
                if doc_in <= 0:
                    doc_in = diameter * 1.0
                if woc_in <= 0:
                    woc_in = diameter * 0.40  # 40% D roughing
                    
            if rpm <= 0 or feedrate_ipm <= 0:
                target_sfm = physics.get_base_sfm(family, "Carbide Endmill", geometry=geometry, diameter=diameter)
                base_ipt = physics.get_base_ipt(family, "Carbide Endmill", diameter, geometry=geometry, flutes=flutes, is_carbide=True)
                target_sfm, base_ipt = physics.apply_alloy_hardness_scaling(family, alloy, target_sfm, base_ipt)
                target_sfm, base_ipt = physics.apply_aggressiveness(target_sfm, base_ipt, aggressiveness)
                target_sfm *= physics.get_coating_multiplier(coating, family)
                if rpm <= 0:
                    rpm = physics.calc_rpm(target_sfm, diameter)
                if feedrate_ipm <= 0:
                    feedrate_ipm = physics.calc_feedrate(rpm, flutes, base_ipt)
                    
            defl = physics.tool_deflection(
                diameter=diameter, shank_size=shank_dia, stickout=stickout, cut_depth=doc_in, cut_width=woc_in,
                feedrate=feedrate_ipm, rpm=rpm, flutes=flutes, is_carbide=True, material_family=family,
                flute_length=flute_len, operation="Finishing" if is_finishing else "Roughing"
            )
            sb, total_err, wear_comp = physics.calc_springback_and_deflection(
                material_family=family, diameter=diameter, cut_depth=doc_in, cut_width=woc_in,
                feedrate=feedrate_ipm, rpm=rpm, flutes=flutes, deflection_inches=defl, alloy=alloy
            )
            
            # Aggressiveness scaling (0% = 0.60x conservative, 50% = 1.00x nominal, 100% = 1.40x aggressive)
            agg_scalar = 0.60 + (aggressiveness * 0.80)
            defl *= agg_scalar
            sb *= agg_scalar
            total_err = defl + sb
            wear_comp = -total_err
            
            if mode == "zero_finishing":
                if is_finishing:
                    rec_rad = zero_rad_str
                    rec_ax = zero_ax_str
                    advisory = "Finishing Pass\nZero Stock (0.0000)"
                else:
                    rec_rad = current_radial
                    rec_ax = current_axial
                    advisory = f"Roughing Pass\nRetaining stock ({rec_rad})"
            elif mode == "custom":
                rec_rad = clean_and_eval_stock_expr(custom_radial_offset, doc_unit) if custom_radial_offset else zero_rad_str
                rec_ax = clean_and_eval_stock_expr(custom_axial_offset, doc_unit) if custom_axial_offset else zero_ax_str
                advisory = f"Custom Batch\nRad: {rec_rad} | Ax: {rec_ax}"
            else:  # auto_compensate
                if is_finishing:
                    # Maximum safe negative radial/axial stock compensation ceiling for finishing passes
                    # Precision finish cuts should never exceed 0.0025" (0.065 mm) or 2.5% of tool diameter
                    # to prevent any risk of part gouging or scrap.
                    max_safe_comp_in = min(0.0025, max(0.0008, diameter * 0.025))
                    eff_total_err = min(total_err, max_safe_comp_in)
                    eff_sb = min(sb, max_safe_comp_in)
                    
                    if is_floor_finish:
                        if is_metric:
                            rec_ax_val = -eff_sb * 25.4
                            rec_rad_val = -eff_total_err * 25.4
                            rec_ax = f"{rec_ax_val:.3f} mm"
                            rec_rad = f"{rec_rad_val:.3f} mm"
                            advisory = f"Floor Ax: {rec_ax} | Comb Rad: {rec_rad}\nTip: Use Rad +0.150mm if floor-only"
                        else:
                            rec_ax_val = -eff_sb
                            rec_rad_val = -eff_total_err
                            rec_ax = f"{rec_ax_val:.4f} in"
                            rec_rad = f"{rec_rad_val:.4f} in"
                            advisory = f"Floor Ax: {rec_ax} | Comb Rad: {rec_rad}\nTip: Use Rad +0.005\" if floor-only"
                    else:  # Wall finishing / lateral contour
                        if is_metric:
                            rec_rad_val = -eff_total_err * 25.4
                            rec_ax_val = -eff_sb * 25.4
                            rec_rad = f"{rec_rad_val:.3f} mm"
                            rec_ax = f"{rec_ax_val:.3f} mm"
                            advisory = f"Wall Rad: {rec_rad} | Floor Ax: {rec_ax}\nKeep Ax: 0.000 if floor pre-cut"
                        else:
                            rec_rad_val = -eff_total_err
                            rec_ax_val = -eff_sb
                            rec_rad = f"{rec_rad_val:.4f} in"
                            rec_ax = f"{rec_ax_val:.4f} in"
                            advisory = f"Wall Rad: {rec_rad} | Floor Ax: {rec_ax}\nKeep Ax: 0.000\" if floor pre-cut"
                else:
                    rec_rad = current_radial
                    rec_ax = current_axial
                    advisory = f"Roughing Pass\nRetaining stock ({rec_rad})"
                    
            results.append({
                "id": op_id,
                "name": op_name,
                "strategy": strat,
                "is_finishing": is_finishing,
                "is_floor_finish": is_floor_finish,
                "is_wall_finish": is_wall_finish,
                "deflection_in": round(defl, 6),
                "springback_in": round(sb, 6),
                "total_error_in": round(total_err, 6),
                "wear_comp_offset_in": round(wear_comp, 6),
                "recommended_radial_stock": rec_rad,
                "recommended_axial_stock": rec_ax,
                "advisory": advisory
            })
            
        return jsonify({
            "success": True,
            "family": family,
            "alloy": alloy,
            "results": results
        })
    except Exception as e:
        return _api_error(e)

if __name__ == "__main__":
    debug_mode = os.environ.get("FLASK_DEBUG", "0") == "1"
    app.run(host="127.0.0.1", port=5000, debug=debug_mode)


