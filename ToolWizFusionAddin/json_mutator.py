import json
import uuid

class MutatedToolResult(str):
    def __new__(cls, json_str, preset_name=None, was_updated=False):
        instance = super().__new__(cls, json_str)
        instance.json_str = json_str
        instance.preset_name = preset_name
        instance.was_updated = was_updated
        return instance

    def __iter__(self):
        return iter((str(self), self.preset_name, self.was_updated))

    def __getitem__(self, item):
        if isinstance(item, int) and 0 <= item <= 2:
            return (str(self), self.preset_name, self.was_updated)[item]
        return super().__getitem__(item)

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
    
    tool_unit = tool_dict.get("unit", tool_dict.get("geometry", {}).get("unit", "inches"))
    is_metric = (str(tool_unit).lower() in ["millimeters", "mm"])
    
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
        
    # Autodesk CAM expects native numeric floats in tool preset structures
    rpm_num = float(round(rpm_val, 2))
    sfm_num = float(round(sfm_val if not is_metric else sfm_val * 0.3048, 2))
    ipt_num = float(round(ipt_val if not is_metric else ipt_val * 25.4, 6))
    feed_num = float(round(feed_val if not is_metric else feed_val * 25.4, 2))
    doc_num = float(round(doc_val if not is_metric else doc_val * 25.4, 4))
    woc_num = float(round(woc_val if not is_metric else woc_val * 25.4, 4))
    rf_num = float(round(rf if not is_metric else rf * 25.4, 2))
    pf_num = float(round(pf if not is_metric else pf * 25.4, 2))

    mapped_data = {
        "guid": str(uuid.uuid4()),
        "name": preset_name,
        "description": f"{preset_name} - {material_label}",
        "material": {
            "category": new_preset_data.get("material_category", "metal"),
            "query": material_label,
            "use-hardness": False
        },
        "n": rpm_num,
        "n_ramp": rpm_num,
        "v_c": sfm_num,
        "f_z": ipt_num,
        "f_n": float(round(ipt_num * flutes, 6)),
        "v_f": feed_num,
        "v_f_leadIn": feed_num,
        "v_f_leadOut": feed_num,
        "v_f_transition": float(round(feed_num * 1.5, 2)),
        "v_f_ramp": rf_num,
        "v_f_plunge": pf_num,
        "stepdown": doc_num,
        "stepover": woc_num,
        "use-stepdown": True,
        "use-stepover": True,
        "ramp-angle": 2.0,
        "tool-coolant": "flood"
    }
    
    # Preserve tool number in post-process section ONLY if a valid positive tool number is provided
    t_num = new_preset_data.get("tool_number") or new_preset_data.get("number")
    if t_num is not None:
        try:
            t_val = int(t_num)
            if t_val > 0:
                if "post-process" not in tool_dict or not isinstance(tool_dict["post-process"], dict):
                    tool_dict["post-process"] = {}
                tool_dict["post-process"]["number"] = t_val
                tool_dict["post-process"]["diameter-offset"] = t_val
                tool_dict["post-process"]["length-offset"] = t_val
        except (ValueError, TypeError):
            pass

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
        
    return MutatedToolResult(json.dumps(tool_dict), preset_name, was_updated)
