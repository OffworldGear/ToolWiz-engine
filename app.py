import os
import uuid
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
    if "Tapping" not in tools:
        tools.append("Tapping")
        tools.sort()
        
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
        runout = float(data.get("runout", 0.0002))
        
        # Determine sizes
        shank_size = float(data.get("shankDiameter", diameter))
        neck_diameter = float(data.get("neckDiameter", shank_size))
        
        # 1. Lookup Base Parameters
        target_sfm = physics.get_base_sfm(family, tool, geometry=geometry, diameter=diameter)
        base_ipt = physics.get_base_ipt(family, tool, diameter, geometry=geometry, runout=runout)
        
        # Alloy-specific hardness adjustment via exponential BHN curve
        alloy = data.get("alloy", "")
        target_sfm, base_ipt = physics.apply_alloy_hardness_scaling(family, alloy, target_sfm, base_ipt)
        
        # Chatter / Resonance penalty based on stickout length
        is_drilling = tool in ["Drill", "Tapping", "Reamer"]
        target_sfm, base_ipt = physics.apply_chatter_penalty(target_sfm, base_ipt, diameter, stickout, is_drilling=is_drilling)
        
        if tool != "Tapping":
            target_sfm, base_ipt = physics.apply_aggressiveness(target_sfm, base_ipt, aggressiveness)
        
        # Apply Coating Modifier
        target_sfm *= physics.get_coating_multiplier(coating, family)
        
        effective_diameter = physics.calc_effective_diameter(diameter, cut_depth, geometry, corner_radius)
        
        # 2. Physics Equations
        rpm = physics.calc_rpm(target_sfm, effective_diameter, max_rpm=max_rpm)
        
        is_hole_tool = any(d in tool.lower() for d in ["drill", "tap", "reamer", "bore"]) or any(d in geometry.lower() for d in ["drill", "parabolic"])
        if is_hole_tool:
            cut_width = diameter
            if any(m in operation.lower() for m in ["rough", "adaptive", "trochoidal", "slot", "face", "finish"]):
                operation = "Drilling"

        if tool == "Tapping":
            pitch = float(data.get("pitch", 0.05))
            feedrate = rpm * pitch
            adjusted_ipt = 0.0
        else:
            adjusted_ipt = physics.calc_adjusted_chipload(base_ipt, cut_depth, cut_width, diameter, effective_diameter, operation=operation, geometry=geometry, tool_type=tool)
            feedrate = physics.calc_feedrate(rpm, flutes, adjusted_ipt)
            
        mrr = physics.calc_mrr(cut_depth, cut_width, feedrate, geometry=geometry, diameter=diameter)
        
        actual_sfm = physics.calc_sfm(rpm, diameter)
        # 3. Ramping Params
        ramp_angle, ramp_feed, plunge_feed = physics.calc_ramping(family, diameter, feedrate, geometry, flutes, aggressiveness)
        
        if is_hole_tool:
            deflection = 0.0
        else:
            deflection = physics.tool_deflection(
                diameter, shank_size, stickout, cut_depth, cut_width, feedrate, rpm, flutes, is_carbide, material_family=family,
                helix_angle=helix_angle, neck_length=neck_length, taper_angle=taper_angle, flute_length=flute_length, neck_diameter=neck_diameter
            )
        
        tips = physics.generate_advanced_strategies(
            family, diameter, cut_depth, cut_width, feedrate, rpm, flutes, coating, deflection, tool_type=tool, stickout=stickout, geometry=geometry
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
            "rec_doc": round(rec_doc, 4),
            "rec_woc": round(rec_woc, 4),
            "rec_limit": round(diameter * 0.002, 5), # Return the absolute physical limit for the UI bar
            "tips": tips
        })
        
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
        neck_diameter = float(data.get("neckDiameter", shank_size))
        taper_angle = float(data.get("taperAngle", 0.0))
        helix_angle = float(data.get("helixAngle", 30.0))
        stickout = float(data.get("stickout", 1.5))
        is_carbide = True  # Assuming Fusion tool implies carbide if not specified
        
        # 1. Lookup Base Parameters
        target_sfm = physics.get_base_sfm(family, tool, geometry=geometry, diameter=diameter)
        base_ipt = physics.get_base_ipt(family, tool, diameter, geometry=geometry, runout=runout)
        
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
            helix_angle=helix_angle, neck_length=neck_length, taper_angle=taper_angle, flute_length=flute_length, neck_diameter=neck_diameter
        )
        
        effective_diameter = physics.calc_effective_diameter(diameter, rec_doc, geometry, corner_radius)
        adjusted_ipt = physics.calc_adjusted_chipload(base_ipt, rec_doc, rec_woc, diameter, effective_diameter, operation=operation, geometry=geometry)
        feedrate = physics.calc_feedrate(rpm, flutes, adjusted_ipt)
        actual_sfm = physics.calc_sfm(rpm, diameter)
        
        # 3. Ramping Params
        ramp_angle, ramp_feed, plunge_feed = physics.calc_ramping(family, diameter, feedrate, geometry, flutes, aggressiveness)
        
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
            "plunge_feed": round(plunge_feed, 2)
        })
        
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

from backup_manager import BackupManager
from ToolWizFusionAddin.json_mutator import format_unit

bm = BackupManager()

def parse_dim(val, tool_unit=""):
    """Helper to parse tool dimensions from JSON to inches"""
    if val is None: return 0.25
    if isinstance(val, (int, float)):
        u = str(tool_unit).strip().lower()
        if u in ["inches", "in", "inch"]: return float(val)
        elif u in ["millimeters", "mm", "millimeter"]: return float(val) / 25.4
        else: return float(val) / 25.4 if float(val) > 1.5 else float(val)
    if isinstance(val, str):
        v = val.strip().lower()
        if "in" in v:
            v = v.replace("in", "").strip()
            if "/" in v:
                n, d = v.split("/")
                return float(n)/float(d)
            return float(v)
        elif "mm" in v:
            v = v.replace("mm", "").strip()
            return float(v) / 25.4
        else:
            try:
                f = float(v)
                u = str(tool_unit).strip().lower()
                if u in ["inches", "in", "inch"]: return f
                elif u in ["millimeters", "mm", "millimeter"]: return f / 25.4
                return f / 25.4 if f > 1.5 else f
            except:
                return 0.25
    return 0.25

@app.route("/api/twin/export_receive", methods=["POST"])
def twin_export_receive():
    """Receives exported tool library JSON from Fusion 360 Add-in"""
    try:
        data = request.json
        if not data:
            return jsonify({"success": False, "error": "No JSON payload received"}), 400
            
        lib_name = data.get("library_name", "Fusion_Hub_Library")
        backup_info = bm.save_working_library(data, lib_name)
        
        tools = data.get("tools", [])
        return jsonify({
            "success": True,
            "library_name": lib_name,
            "tool_count": len(tools),
            "backup": backup_info
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/twin/load", methods=["GET"])
def twin_load():
    """Returns active Digital Twin working library tools and backup history"""
    try:
        data = bm.load_working_library()
        backups = bm.list_backups()
        
        if not data:
            return jsonify({
                "has_library": False,
                "library_name": "No Library Loaded",
                "tools": [],
                "backups": backups
            })
            
        lib_name = data.get("library_name", "Digital_Twin_Library")
        raw_tools = data.get("tools", [])
        
        tool_manifest = []
        for idx, t in enumerate(raw_tools):
            # t can be dict or JSON string
            t_dict = json.loads(t) if isinstance(t, str) else t
            geo = t_dict.get("geometry", {})
            tool_unit = t_dict.get("unit", geo.get("unit", ""))
            
            dia_in = parse_dim(geo.get("DC", 6.35), tool_unit)
            flutes = int(geo.get("NOF", 4))
            flute_len = parse_dim(geo.get("LCF", 25.4), tool_unit)
            t_num = t_dict.get("post-process", {}).get("number", 0)
            desc = t_dict.get("description", f"{dia_in:.3f}in Tool")
            t_type = geo.get("type", t_dict.get("type", "end mill"))
            
            presets = t_dict.get("start-values", {}).get("presets", [])
            preset_list = [{"name": p.get("name", "Preset"), "guid": p.get("guid", "")} for p in presets]
            
            tool_manifest.append({
                "index": idx,
                "number": t_num,
                "description": desc,
                "type": t_type,
                "diameter_in": round(dia_in, 4),
                "diameter_mm": round(dia_in * 25.4, 2),
                "flutes": flutes,
                "flute_length_in": round(flute_len, 4),
                "presets": preset_list,
                "preset_count": len(preset_list)
            })
            
        return jsonify({
            "has_library": True,
            "library_name": lib_name,
            "last_modified": data.get("last_modified", ""),
            "tool_count": len(tool_manifest),
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
    """Batch calculates and injects multi-operation presets into selected tools"""
    try:
        req_data = request.json
        tool_indices = req_data.get("tool_indices", []) # list of integer indices
        family = req_data.get("family", "Steel - Tool (H13)")
        alloy = req_data.get("alloy", "CPM MagnaCut (Hardened ~62 HRC)")
        strategies = req_data.get("strategies", ["Adaptive Roughing", "Roughing", "Finishing", "Slotting"])
        aggressiveness = float(req_data.get("aggressiveness", 50.0)) / 100.0
        coating = req_data.get("coating", "AlTiN")
        max_rpm = float(req_data.get("maxRpm", 16000))
        max_hp = float(req_data.get("maxHp", 10.0))
        runout = float(req_data.get("runout", 0.0002))
        
        library_data = bm.load_working_library()
        if not library_data or "tools" not in library_data:
            return jsonify({"success": False, "error": "No working library found to modify."}), 400
            
        tools = library_data["tools"]
        indices_to_update = range(len(tools)) if tool_indices == "all" else tool_indices
        
        custom_preset_name = req_data.get("custom_preset_name", "").strip()
        
        updated_tools_count = 0
        total_presets_injected = 0
        
        for idx, raw_t in enumerate(tools):
            if idx not in indices_to_update:
                continue
                
            t_dict = json.loads(raw_t) if isinstance(raw_t, str) else raw_t
            
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
            
            is_milling = tool_type in valid_milling_types
            is_drilling = tool_type in valid_drilling_types
            
            if not is_milling and not is_drilling:
                tools[idx] = t_dict
                continue

            geo = t_dict.get("geometry", {})
            tool_unit = t_dict.get("unit", geo.get("unit", ""))
            
            diameter = parse_dim(geo.get("DC", 6.35), tool_unit)
            flutes = int(geo.get("NOF", 4)) if is_milling else int(geo.get("NOF", 2))
            flute_len = parse_dim(geo.get("LCF", 25.4), tool_unit)
            shank_dia = parse_dim(geo.get("SF", diameter * 25.4), tool_unit)
            corner_rad = parse_dim(geo.get("RE", 0.0), tool_unit)
            stickout = flute_len * 1.5
            is_carbide = True
            if "slot mill" in tool_type:
                geometry = "T-Slot"
            elif "dovetail" in tool_type:
                geometry = "Dovetail"
            elif "lollipop" in tool_type:
                geometry = "Lollipop"
            elif "thread mill" in tool_type:
                geometry = "Thread Mill"
            elif "chamfer mill" in tool_type or "engraving" in tool_type:
                geometry = "Chamfer"
            elif "ball end mill" in tool_type or "radius mill" in tool_type:
                geometry = "Ball Nose"
            elif "bull nose" in tool_type:
                geometry = "Bull Nose"
            else:
                geometry = "Square" if corner_rad == 0 else "Radiused"
            
            if "start-values" not in t_dict:
                t_dict["start-values"] = {}
            if "presets" not in t_dict["start-values"]:
                t_dict["start-values"]["presets"] = []
                
            presets_list = t_dict["start-values"]["presets"]
            
            material_label = alloy if alloy else family
            
            if is_drilling:
                is_tap = "tap" in tool_type
                db_tool_type = "Tapping" if is_tap else "Carbide Twist Drill"
                
                target_sfm = physics.get_base_sfm(family, db_tool_type, diameter=diameter)
                adj_ipt = physics.get_base_ipt(family, db_tool_type, diameter, runout=runout)
                
                # Hardness modifier via exponential BHN curve
                target_sfm, adj_ipt = physics.apply_alloy_hardness_scaling(family, alloy, target_sfm, adj_ipt)
                
                # Chatter / Resonance penalty
                target_sfm, adj_ipt = physics.apply_chatter_penalty(target_sfm, adj_ipt, diameter, stickout, is_drilling=True)
                
                if not is_tap:
                    target_sfm, adj_ipt = physics.apply_aggressiveness(target_sfm, adj_ipt, aggressiveness)
                
                rpm = physics.calc_rpm(target_sfm, diameter, max_rpm=max_rpm)
                
                if is_tap:
                    tp = parse_dim(geo.get("TP", 1.0), tool_unit)
                    # For taps, feed per rev (f_n) MUST exactly equal the thread pitch
                    feedrate = rpm * tp
                    # We can set adj_ipt to the pitch, so f_z output makes sense
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
                for strat in strategies:
                    # 1. Physics lookup
                    target_sfm = physics.get_base_sfm(family, "Carbide Endmill", geometry=geometry, diameter=diameter)
                    base_ipt = physics.get_base_ipt(family, "Carbide Endmill", diameter, geometry=geometry, runout=runout)
                    
                    # Hardness modifier via exponential BHN curve
                    target_sfm, base_ipt = physics.apply_alloy_hardness_scaling(family, alloy, target_sfm, base_ipt)
                        
                    # Chatter / Resonance penalty
                    target_sfm, base_ipt = physics.apply_chatter_penalty(target_sfm, base_ipt, diameter, stickout, is_drilling=False)
                    
                    target_sfm, base_ipt = physics.apply_aggressiveness(target_sfm, base_ipt, aggressiveness)
                    target_sfm *= physics.get_coating_multiplier(coating, family)
                    
                    rpm = physics.calc_rpm(target_sfm, diameter, max_rpm=max_rpm)
                    rec_doc, rec_woc, _ = physics.recommend_cut_parameters(
                        diameter, shank_dia, stickout, flutes, rpm, base_ipt, is_carbide, strat, aggressiveness, geometry, flute_len, max_hp, material_family=family, flute_length=flute_len
                    )
                    
                    eff_dia = physics.calc_effective_diameter(diameter, rec_doc, geometry, corner_rad)
                    adj_ipt = physics.calc_adjusted_chipload(base_ipt, rec_doc, rec_woc, diameter, eff_dia, operation=strat, geometry=geometry)
                    feedrate = physics.calc_feedrate(rpm, flutes, adj_ipt)
                    actual_sfm = physics.calc_sfm(rpm, diameter)
                    ramp_angle, ramp_feed, plunge_feed = physics.calc_ramping(family, diameter, feedrate, geometry, flutes, aggressiveness)
                    
                    if custom_preset_name:
                        preset_name = f"{custom_preset_name} - {strat}"
                    else:
                        preset_name = f"{material_label} - {strat}"
                    
                    # Convert to pure numeric values based on the tool's native unit
                    if tool_unit == "inches":
                        p_n = float(rpm)
                        p_vc = float(actual_sfm)
                        p_fz = float(adj_ipt)
                        p_vf = float(feedrate)
                        p_vf_ramp = float(ramp_feed)
                        p_vf_plunge = float(plunge_feed)
                        p_stepdown = float(rec_doc)
                        p_stepover = float(rec_woc)
                    else:
                        # tool_unit == "millimeters"
                        p_n = float(rpm)
                        p_vc = float(actual_sfm * 0.3048) # SFM to m/min
                        p_fz = float(adj_ipt * 25.4)
                        p_vf = float(feedrate * 25.4)
                        p_vf_ramp = float(ramp_feed * 25.4)
                        p_vf_plunge = float(plunge_feed * 25.4)
                        p_stepdown = float(rec_doc * 25.4)
                        p_stepover = float(rec_woc * 25.4)
                    
                    preset_dict = {
                        "guid": str(uuid.uuid4()),
                        "name": preset_name,
                        "description": preset_name,
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
                    
                    # Update in place if duplicate name exists, else append
                    existing_idx = next((i for i, p in enumerate(presets_list) if p.get("name") == preset_name), None)
                    if existing_idx is not None:
                        presets_list[existing_idx].update(preset_dict)
                    else:
                        presets_list.append(preset_dict)
                        
                    total_presets_injected += 1
                
            tools[idx] = t_dict
            updated_tools_count += 1
            
        # Deduplicate tool GUIDs to prevent Fusion's library manager from silently dropping tools
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
        lib_name = library_data.get("library_name", "Modified_Library")
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

import zipfile
import io
import json
from flask import send_file

@app.route("/api/twin/upload", methods=["POST"])
def twin_upload():
    """Handles manual drag-and-drop file uploads of .tools or .json libraries"""
    try:
        if 'file' not in request.files:
            return jsonify({"success": False, "error": "No file uploaded"}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({"success": False, "error": "No selected file"}), 400
            
        filename = file.filename.lower()
        library_data = None
        
        if filename.endswith('.json'):
            library_data = json.loads(file.read().decode('utf-8'))
        elif filename.endswith('.tools'):
            with zipfile.ZipFile(file, 'r') as z:
                json_files = [n for n in z.namelist() if n.endswith('.json')]
                if not json_files:
                    return jsonify({"success": False, "error": "No .json found inside .tools archive"}), 400
                with z.open(json_files[0]) as f:
                    library_data = json.loads(f.read().decode('utf-8'))
        else:
            return jsonify({"success": False, "error": "Unsupported file type. Please upload .tools or .json"}), 400
            
        tools_list = []
        if isinstance(library_data, dict) and "data" in library_data:
            tools_list = library_data["data"]
        elif isinstance(library_data, list):
            tools_list = library_data
        elif isinstance(library_data, dict) and "tools" in library_data:
            tools_list = library_data["tools"]
            
        lib_name = file.filename.replace('.json', '').replace('.tools', '')
        normalized_data = {
            "library_name": lib_name,
            "tools": tools_list
        }
        
        backup_info = bm.save_working_library(normalized_data, lib_name)
        
        return jsonify({
            "success": True,
            "library_name": lib_name,
            "tool_count": len(tools_list),
            "backup": backup_info
        })
        
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/twin/download", methods=["GET"])
def twin_download():
    """Provides the active Digital Twin library as a downloadable .json file"""
    try:
        data = bm.load_working_library()
        if not data:
            return "No active library found", 404
            
        fusion_format = {
            "data": data.get("tools", [])
        }
        
        json_str = json.dumps(fusion_format, indent=2)
        lib_name = data.get("library_name", "ToolWiz_Digital_Twin")
        
        mem_file = io.BytesIO()
        mem_file.write(json_str.encode('utf-8'))
        mem_file.seek(0)
        
        return send_file(
            mem_file,
            mimetype='application/json',
            as_attachment=True,
            download_name=f"{lib_name}_Updated.json"
        )
    except Exception as e:
        return str(e), 500

if __name__ == "__main__":
    # Run the Flask app on localhost:5000
    app.run(host="127.0.0.1", port=5000, debug=True)

