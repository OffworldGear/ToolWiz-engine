import json

def format_unit(value, unit_string):
    """
    Enforces unit concatenation to bypass Fusion's unitless metric default bug.
    Must always return a string with the explicit unit marker.
    """
    return f"{float(value):.6f}{unit_string}"

def mutate_tool_json(original_json_string, new_preset_data):
    """
    Safely mutates a Fusion Tool JSON string by injecting or updating a preset 
    in the start-values.presets array.
    """
    tool_dict = json.loads(original_json_string)
    
    # Ensure nested structures exist
    if "start-values" not in tool_dict:
        tool_dict["start-values"] = {}
    if "presets" not in tool_dict["start-values"]:
        tool_dict["start-values"]["presets"] = []
        
    presets = tool_dict["start-values"]["presets"]
    
    # Map external app variables to Fusion schema and force stringification
    preset_name = new_preset_data.get("name", "ToolWiz Auto Preset")
    
    mapped_data = {
        "description": preset_name,
        "name": preset_name,
        "n": format_unit(new_preset_data.get("rpm", 0), "rpm"),
        "v_c": format_unit(new_preset_data.get("sfm", 0), "ft/min"),
        "f_z": format_unit(new_preset_data.get("ipt", 0), "in"),
        "v_f": format_unit(new_preset_data.get("feed", 0), "in/min"),
        "stepdown": format_unit(new_preset_data.get("doc", 0), "in"),
        "stepover": format_unit(new_preset_data.get("woc", 0), "in"),
        "tool-coolant": "flood"
    }
    
    # Plunge and Ramp feedrates (guaranteed non-zero)
    feed_val = new_preset_data.get("feed", 0)
    rf = new_preset_data.get("ramp_feed")
    if rf is None or rf <= 0:
        rf = feed_val * 0.50 if feed_val > 0 else 10.0
    pf = new_preset_data.get("plunge_feed")
    if pf is None or pf <= 0:
        pf = rf if rf > 0 else (feed_val * 0.25 if feed_val > 0 else 5.0)
        
    mapped_data["v_f_ramp"] = format_unit(rf, "in/min")
    mapped_data["v_f_plunge"] = format_unit(pf, "in/min")
        
    # Check for name collision
    existing_preset = next((p for p in presets if p.get("name") == preset_name), None)
    if existing_preset:
        # Update in place
        existing_preset.update(mapped_data)
    else:
        # Append new
        presets.append(mapped_data)
        
    return json.dumps(tool_dict)
