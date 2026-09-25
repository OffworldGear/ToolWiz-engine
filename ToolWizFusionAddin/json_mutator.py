import json
import uuid

def format_unit(value, unit_string):
    """
    Enforces unit concatenation to bypass Fusion's unitless metric default bug.
    Must always return a string with the explicit unit marker.
    """
    return f"{float(value):.6f}{unit_string}"

def mutate_tool_json(original_json_string, new_preset_data, target_preset_to_replace=None):
    """
    Safely mutates a Fusion Tool JSON string by injecting or updating a preset 
    in the start-values.presets array.
    
    Parameters:
      - original_json_string: raw tool JSON string
      - new_preset_data: dictionary with rpm, feed, sfm, ipt, doc, woc, name, etc.
      - target_preset_to_replace: optional name of an existing preset to overwrite
    """
    tool_dict = json.loads(original_json_string)
    
    # Ensure nested structures exist
    if "start-values" not in tool_dict:
        tool_dict["start-values"] = {}
    if "presets" not in tool_dict["start-values"]:
        tool_dict["start-values"]["presets"] = []
        
    presets = tool_dict["start-values"]["presets"]
    
    preset_name = new_preset_data.get("name", "ToolWiz Auto Preset")
    material_label = new_preset_data.get("material_query") or new_preset_data.get("alloy") or new_preset_data.get("family") or "Generic"
    
    rpm_val = float(new_preset_data.get("rpm", 0))
    sfm_val = float(new_preset_data.get("sfm", 0))
    ipt_val = float(new_preset_data.get("ipt", 0))
    feed_val = float(new_preset_data.get("feed", 0))
    doc_val = float(new_preset_data.get("doc", 0))
    woc_val = float(new_preset_data.get("woc", 0))
    flutes = int(new_preset_data.get("flutes", tool_dict.get("geometry", {}).get("NOF", 4)))
    
    # Plunge and Ramp feedrates (guaranteed non-zero)
    rf = new_preset_data.get("ramp_feed")
    if rf is None or rf <= 0:
        rf = feed_val * 0.50 if feed_val > 0 else 10.0
    pf = new_preset_data.get("plunge_feed")
    if pf is None or pf <= 0:
        pf = rf if rf > 0 else (feed_val * 0.25 if feed_val > 0 else 5.0)
        
    mapped_data = {
        "guid": str(uuid.uuid4()),
        "name": preset_name,
        "description": f"{preset_name} - {material_label}",
        "material": {
            "category": new_preset_data.get("material_category", "metal"),
            "query": material_label,
            "use-hardness": False
        },
        "n": format_unit(rpm_val, "rpm"),
        "n_ramp": format_unit(rpm_val, "rpm"),
        "v_c": format_unit(sfm_val, "ft/min"),
        "f_z": format_unit(ipt_val, "in"),
        "f_n": format_unit(ipt_val * flutes, "in"),
        "v_f": format_unit(feed_val, "in/min"),
        "v_f_leadIn": format_unit(feed_val, "in/min"),
        "v_f_leadOut": format_unit(feed_val, "in/min"),
        "v_f_transition": format_unit(feed_val * 1.5, "in/min"),
        "v_f_ramp": format_unit(rf, "in/min"),
        "v_f_plunge": format_unit(pf, "in/min"),
        "stepdown": format_unit(doc_val, "in"),
        "stepover": format_unit(woc_val, "in"),
        "use-stepdown": True,
        "use-stepover": True,
        "ramp-angle": 2.0,
        "tool-coolant": "flood"
    }
    
    # Preserve tool number in post-process section if provided
    t_num = new_preset_data.get("tool_number") or new_preset_data.get("number")
    if t_num:
        if "post-process" not in tool_dict or not isinstance(tool_dict["post-process"], dict):
            tool_dict["post-process"] = {}
        tool_dict["post-process"]["number"] = int(t_num)
        tool_dict["post-process"]["diameter-offset"] = int(t_num)
        tool_dict["post-process"]["length-offset"] = int(t_num)

    was_updated = False
    
    # 1. If user explicitly selected an existing preset to replace:
    if target_preset_to_replace and target_preset_to_replace != "+ Create New Preset (Auto-Named)":
        for p in presets:
            if p.get("name") == target_preset_to_replace:
                if "guid" in p:
                    mapped_data["guid"] = p["guid"]
                p.update(mapped_data)
                was_updated = True
                break
                
    # 2. If not already updated, check for name collision with preset_name
    if not was_updated:
        for p in presets:
            if p.get("name") == preset_name:
                if "guid" in p:
                    mapped_data["guid"] = p["guid"]
                p.update(mapped_data)
                was_updated = True
                break
                
    # 3. If no match found, append as a new preset
    if not was_updated:
        presets.append(mapped_data)
        
    return json.dumps(tool_dict), preset_name, was_updated
