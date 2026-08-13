import os
from flask import Flask, render_template, request, jsonify
from gwizard_physics import GWizardPhysics

app = Flask(__name__)

# Initialize physics engine
db_path = os.path.join(os.path.dirname(__file__), "materials_database_clean.json")
physics = GWizardPhysics(db_path)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/api/data", methods=["GET"])
def get_data():
    """Return the data needed to populate the UI dropdowns"""
    families = list(physics.machinability.keys())
    families.sort()
    
    # Extract unique tools from ipt_data mapping where possible
    tools = sorted(list(set(item[1] for item in physics.ipt_data if len(item) > 1)))
    
    return jsonify({
        "families": families,
        "tools": tools,
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
        corner_radius = float(data.get("cornerRadius", 0.0))
        cutter_thickness = float(data.get("cutterThickness", 0.125))
        flute_length = float(data.get("fluteLength", 1.0))
        neck_length = float(data.get("neckLength", 0.5))
        taper_angle = float(data.get("taperAngle", 0.0))
        helix_angle = float(data.get("helixAngle", 30.0))
        aggressiveness = float(data.get("aggressiveness", 50.0)) / 100.0  # Scale 0-100 to 0.0-1.0
        max_rpm = float(data.get("maxRpm", 16000))
        max_hp = float(data.get("maxHp", 10.0))
        
        # Determine sizes
        shank_size = float(data.get("shankDiameter", diameter))
        neck_diameter = float(data.get("neckDiameter", shank_size))
        
        # 1. Lookup Base Parameters
        target_sfm = physics.get_base_sfm(family, tool, geometry=geometry)
        base_ipt = physics.get_base_ipt(family, tool, diameter, geometry=geometry)
        
        target_sfm, base_ipt = physics.apply_aggressiveness(target_sfm, base_ipt, aggressiveness)
        
        # Apply Coating Modifier
        coating_mults = {"TiN": 1.2, "TiCN": 1.3, "TiAlN": 1.4, "AlTiN": 1.4, "ZrN": 1.35, "Diamond": 2.0}
        target_sfm *= coating_mults.get(coating, 1.0)
        
        effective_diameter = physics.calc_effective_diameter(diameter, cut_depth, geometry, corner_radius)
        
        # 2. Physics Equations
        rpm = physics.calc_rpm(target_sfm, effective_diameter, max_rpm=max_rpm)
        adjusted_ipt = physics.calc_adjusted_chipload(base_ipt, cut_depth, cut_width, diameter, effective_diameter, operation=operation, geometry=geometry)
        feedrate = physics.calc_feedrate(rpm, flutes, adjusted_ipt)
        mrr = physics.calc_mrr(cut_depth, cut_width, feedrate, geometry=geometry, diameter=diameter)
        
        actual_sfm = physics.calc_sfm(rpm, diameter)
        # 3. Ramping Params
        ramp_angle, ramp_feed, plunge_feed = physics.calc_ramping(family, diameter, feedrate, geometry, flutes, aggressiveness)
        
        deflection = physics.tool_deflection(
            diameter, shank_size, stickout, cut_depth, cut_width, feedrate, rpm, flutes, is_carbide, material_family=family,
            helix_angle=helix_angle, neck_length=neck_length, taper_angle=taper_angle, flute_length=flute_length, neck_diameter=neck_diameter
        )
        
        rec_doc, rec_woc, rec_limit = physics.recommend_cut_parameters(
            diameter, shank_size, stickout, flutes, rpm, base_ipt, is_carbide, operation, aggressiveness, geometry, cutter_thickness, max_hp, material_family=family,
            helix_angle=helix_angle, neck_length=neck_length, taper_angle=taper_angle, flute_length=flute_length, neck_diameter=neck_diameter
        )
        
        return jsonify({
            "success": True,
            "rpm": round(rpm),
            "feedrate": round(feedrate, 2),
            "mrr": round(mrr, 3),
            "deflection": round(deflection, 6),
            "sfm": round(actual_sfm, 1),
            "base_ipt": round(base_ipt, 6),
            "adj_ipt": round(adjusted_ipt, 6),
            "ramp_angle": round(ramp_angle, 1),
            "ramp_feed": round(ramp_feed, 2),
            "plunge_feed": round(plunge_feed, 2),
            "rec_doc": round(rec_doc, 3),
            "rec_woc": round(rec_woc, 3)
        })
        
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

if __name__ == "__main__":
    # Run the Flask app on localhost:5000
    app.run(host="127.0.0.1", port=5000, debug=True)
