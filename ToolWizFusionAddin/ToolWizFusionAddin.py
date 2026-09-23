import adsk.core, adsk.cam, adsk.fusion, traceback
import urllib.request, json
import os, re
from . import json_mutator

app = None
ui = None
handlers = []

exportCommandId = 'ToolWizExportTwinCmd'
importCommandId = 'ToolWizImportTwinCmd'
calcCommandId = 'ToolWizCalcCmd'
stockCommandId = 'ToolWizStockToLeaveCmd'

workspaceToUse = 'CAMEnvironment'
panelToUse = 'CAMManagePanel'

available_ops_map = {}
discovered_libraries_map = {}
stock_ops_cache = {}
stock_setups_cache = {}
stock_table_input = None
_is_updating_ui = False

# Global caches
families_list = [
    "Aluminum - Wrought (6061)",
    "Aluminum - Cast",
    "Steel - Low Carbon (1020)",
    "Steel - Medium Carbon (1045)",
    "Steel - Medium Carbon Alloy (4130)",
    "Steel - Tool (H13)",
    "Stainless - 300 Series (316)",
    "Stainless - 400 Series (420)",
    "Titanium Alloy",
    "Brass",
    "Plastics: Hard (ABS, Nylon, Foam Bd)"
]
alloys_dict = {
    "Aluminum - Wrought (6061)": ["6061 - T6", "7075 - T6"],
    "Steel - Tool (H13)": [
        "CPM MagnaCut (Hardened ~62 HRC)",
        "CPM MagnaCut (Annealed ~22 HRC)",
        "H13 - Annealed",
        "D2 - Hardened ~60 HRC"
    ],
    "Steel - Low Carbon (1020)": ["1018 - Cold Drawn", "1020 - Hot Rolled"],
    "Steel - Medium Carbon Alloy (4130)": ["4140 - Pre-Hardened (~30 HRC)", "4130 - Annealed"],
    "Stainless - 300 Series (316)": ["304 - Annealed", "316 - Annealed"]
}


def parse_dim_to_inches(val, default=0.25, tool_unit=""):
    """Safely converts Fusion dimension expressions/floats/strings to inches, respecting tool unit context."""
    if val is None:
        return default
    if isinstance(val, (int, float)):
        try:
            f = float(val)
            u = str(tool_unit).strip().lower()
            if u in ["inches", "in", "inch"]:
                return f
            elif u in ["millimeters", "mm", "millimeter"]:
                return f / 25.4
            else:
                return f / 25.4 if f > 1.5 else f
        except:
            return default
    if isinstance(val, str):
        v = val.strip().lower()
        try:
            # Handle fraction like "1/4", "3/8", "1/2 in"
            if "/" in v and not any(c in v for c in ['(', ')', ';', '*', '+', 'math', 'min', 'max']):
                clean_v = v.replace("in", "").replace('"', '').strip()
                if "/" in clean_v:
                    n, d = clean_v.split("/")
                    return float(n) / float(d)
            # Regex for pure numbers with optional unit suffix: e.g. "0.25", "0.25 in", "6.35 mm", "0.5\""
            import re
            m = re.match(r'^([-+]?[0-9]*\.?[0-9]+)\s*(in|inch|inches|mm|millimeter|millimetre|")?$', v)
            if m:
                num = float(m.group(1))
                unit = m.group(2) or tool_unit
                if unit and any(u in str(unit).lower() for u in ['mm', 'milli']):
                    return num / 25.4
                return num
        except:
            pass
    return default

def parse_cam_param_to_inches(p, default=0.0, doc_unit="in"):
    """Safely retrieves a CAM parameter's evaluated length in inches.
    Fusion CAM parameters evaluate internal length in centimeters (cm).
    """
    if not p:
        return default
    # 1. Primary: Use evaluated value if available (already evaluated by Fusion CAM engine)
    try:
        if hasattr(p, 'value') and hasattr(p.value, 'value') and isinstance(p.value.value, (int, float)):
            val_cm = float(p.value.value)
            if val_cm > 0:
                return val_cm / 2.54  # cm to inches
    except:
        pass
    # 2. Fallback: Parse expression string respecting document unit context
    try:
        if hasattr(p, 'expression') and p.expression:
            return parse_dim_to_inches(p.expression, default, tool_unit=doc_unit)
    except:
        pass
    return default

def format_cutter_type(raw_type, desc=""):
    """Normalizes cutter types into clean, readable labels (e.g. Flat End Mill, T-Slot Cutter, Chamfer Mill)"""
    t_str = (raw_type or "").lower().replace('_', ' ').replace('-', ' ').strip()
    d_str = (desc or "").lower()
    
    if "chamfer" in t_str or "chamfer" in d_str:
        return "Chamfer Mill"
    elif "t-slot" in t_str or "t slot" in t_str or "tslot" in t_str or "tslot" in d_str:
        return "T-Slot Cutter"
    elif "dovetail" in t_str or "dovetail" in d_str:
        return "Dovetail Cutter"
    elif "thread" in t_str or "thread" in d_str:
        return "Thread Mill"
    elif "ball" in t_str or "ball" in d_str:
        return "Ball End Mill"
    elif "bull" in t_str or "bull" in d_str or "corner rad" in d_str:
        return "Bull Nose Mill"
    elif "face" in t_str or "face" in d_str:
        return "Face Mill"
    elif "slot" in t_str or "slot" in d_str:
        return "Slot Mill"
    elif "flat" in t_str or "end mill" in t_str or "endmill" in d_str:
        return "Flat End Mill"
    elif t_str:
        return t_str.title()
    return "Flat End Mill"

def get_op_tool_info(op):
    """Extracts tool metadata and geometry formatted in inches with dual unit display"""
    if not op or not hasattr(op, 'tool') or not op.tool:
        return None, "No Tool Found", []
    
    try:
        t = op.tool
        raw_json = t.toJson()
        t_dict = json.loads(raw_json)
        geo = t_dict.get("geometry", {})
        tool_unit = t_dict.get("unit", geo.get("unit", ""))
        
        diameter = parse_dim_to_inches(geo.get("DC", 6.35), 0.25, tool_unit)
        flutes = int(geo.get("NOF", 4))
        flute_length = parse_dim_to_inches(geo.get("LCF", 25.4), diameter * 3, tool_unit)
        shank_diameter = parse_dim_to_inches(geo.get("SF", diameter * 25.4), diameter, tool_unit)
        corner_radius = parse_dim_to_inches(geo.get("RE", 0.0), 0.0, tool_unit)
        desc = t_dict.get("description", f"{diameter:.3f}in Endmill")
        t_num = t_dict.get("postProcess", {}).get("number", 1)
        raw_type = t_dict.get("type", "")
        cutter_type = format_cutter_type(raw_type, desc)
        
        presets = t_dict.get("start-values", {}).get("presets", [])
        preset_names = [p.get("name", "Unnamed Preset") for p in presets if p.get("name")]
        
        # Check Length Below Holder (LB) or body length from tool geometry
        lb_raw = geo.get("LB") or geo.get("bodyLength")
        if lb_raw:
            stickout = parse_dim_to_inches(lb_raw, flute_length + diameter * 0.5, tool_unit)
        else:
            # Default realistic stickout: flute_length + 0.125" clamped to 3.5xD unless tool has long flutes
            default_stick = flute_length + min(0.25, diameter * 0.5)
            stickout = max(flute_length * 1.05, min(default_stick, diameter * 3.5))

        geo_payload = {
            "diameter": diameter,
            "flutes": flutes,
            "fluteLength": flute_length,
            "shankDiameter": shank_diameter,
            "cornerRadius": corner_radius,
            "stickout": stickout,
            "coating": "Uncoated",
            "geometry": "Square" if corner_radius == 0 else "Radiused",
            "desc": desc,
            "number": t_num,
            "tool_type": cutter_type,
            "raw_json": raw_json
        }
        
        dia_mm = diameter * 25.4
        fl_mm = flute_length * 25.4
        summary = f"T{t_num}: {desc} | {cutter_type} | Dia: {diameter:.3f}\" ({dia_mm:.2f}mm), {flutes} Flutes, Flute L: {flute_length:.3f}\" ({fl_mm:.1f}mm)"
        return geo_payload, summary, preset_names
    except Exception as e:
        return None, f"Error extracting tool: {str(e)}", []

def apply_param(op, name, expr_str, force=False):
    """Safely updates a single CAMParameter on an Operation"""
    try:
        p = op.parameters.itemByName(name)
        if p and (p.isEnabled or force):
            p.expression = str(expr_str)
            return True
    except:
        pass
    return False

# ==============================================================================
# COMMAND 1: EXPORT DIGITAL TWIN
# ==============================================================================

class ToolWizExportExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            eventArgs = adsk.core.CommandEventArgs.cast(args)
            inputs = eventArgs.command.commandInputs
            lib_select = inputs.itemById('libSelect')
            if not lib_select:
                ui.messageBox('Please select library items to export.')
                return
                
            selected_items = [item.name for item in lib_select.listItems if item.isSelected]
            if not selected_items:
                ui.messageBox('Please check at least one library to export.')
                return

            merge_input = inputs.itemById('mergeIntoMaster')
            dedup_input = inputs.itemById('autoDeduplicate')
            merge_into_master = merge_input.value if merge_input else True
            auto_dedup = dedup_input.value if dedup_input else True

            libraries_payload = []
            total_extracted_tools = 0

            for selected_name in selected_items:
                lib_info = discovered_libraries_map.get(selected_name)
                if not lib_info:
                    continue
                    
                tools_json_list = []
                if lib_info["type"] == "document":
                    camObj = adsk.cam.CAM.cast(app.activeDocument.products.itemByProductType('CAMProductType'))
                    seen_tools = set()
                    if camObj:
                        for setup in camObj.setups:
                            for op in setup.allOperations:
                                if hasattr(op, 'tool') and op.tool:
                                    t_json = op.tool.toJson()
                                    t_dict = json.loads(t_json)
                                    t_desc = t_dict.get("description", "")
                                    t_num = t_dict.get("postProcess", {}).get("number", 0)
                                    key = f"{t_num}_{t_desc}"
                                    if key not in seen_tools:
                                        seen_tools.add(key)
                                        tools_json_list.append(t_dict)
                else:
                    lib_obj = lib_info.get("obj")
                    if lib_obj:
                        for i in range(lib_obj.count):
                            t = lib_obj.item(i)
                            tools_json_list.append(json.loads(t.toJson()))

                if tools_json_list:
                    total_extracted_tools += len(tools_json_list)
                    libraries_payload.append({
                        "library_name": selected_name,
                        "tools": tools_json_list
                    })

            if not libraries_payload:
                ui.messageBox("No tools found in the selected libraries to export.")
                return

            if len(libraries_payload) > 1 or merge_into_master:
                payload = {
                    "libraries": libraries_payload,
                    "master_library_name": "Master_Shop_Tool_Crib",
                    "deduplicate": auto_dedup
                }
            else:
                payload = {
                    "library_name": libraries_payload[0]["library_name"],
                    "tools": libraries_payload[0]["tools"],
                    "deduplicate": auto_dedup
                }

            # Post to ToolWiz server
            req = urllib.request.Request("http://127.0.0.1:5000/api/twin/export_receive")
            req.add_header('Content-Type', 'application/json; charset=utf-8')
            jsondata = json.dumps(payload).encode('utf-8')
            
            response = urllib.request.urlopen(req, jsondata, timeout=5.0)
            res_data = json.loads(response.read().decode('utf-8'))
            
            if res_data.get("success"):
                lib_display_name = res_data.get("library_name", "Master_Shop_Tool_Crib")
                final_count = res_data.get("tool_count", total_extracted_tools)
                backup_name = res_data.get("backup", {}).get("filename", "")
                
                dedup_info = ""
                summary = res_data.get("summary") or res_data.get("report") or {}
                if summary.get("duplicates_removed", 0) > 0:
                    dedup_info = f"Duplicates Removed & Merged: {summary.get('duplicates_removed')}\n"

                msg = (
                    f"Tool Libraries Exported Successfully!\n"
                    f"====================================\n"
                    f"Target Library: {lib_display_name}\n"
                    f"Libraries Processed: {len(libraries_payload)}\n"
                    f"Total Unique Tools: {final_count}\n"
                    f"{dedup_info}"
                    f"Backup Snapshot: {backup_name}\n\n"
                    f"Next Steps:\n"
                    f"1. Open http://127.0.0.1:5000 in your browser.\n"
                    f"2. Switch to 'Digital Twin Library Manager'.\n"
                    f"3. Select material & tweak aggressiveness per tool or material.\n"
                    f"4. Click 'Import Digital Twin' in Fusion when done."
                )
                ui.messageBox(msg, 'ToolWiz Digital Twin Export')
            else:
                ui.messageBox(f"Export failed: {res_data.get('error')}")
                
        except Exception as e:
            if ui:
                ui.messageBox(f"Digital Twin Export Failed:\n{traceback.format_exc()}")

class ToolWizExportCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            cmd = args.command
            cmd.isExecutedWhenPreEmpted = False
            cmd.isRepeatable = False
            cmd.isAutoExecute = False
            onExecute = ToolWizExportExecuteHandler()
            cmd.execute.add(onExecute)
            handlers.append(onExecute)
            
            inputs = cmd.commandInputs
            global discovered_libraries_map
            discovered_libraries_map.clear()
            
            camMgr = adsk.cam.CAMManager.get()
            toolLibs = camMgr.libraryManager.toolLibraries
            
            # 1. Cloud Libraries
            try:
                cloud_url = toolLibs.urlByLocation(adsk.cam.LibraryLocations.CloudLibraryLocation)
                if cloud_url:
                    child_urls = toolLibs.childAssetURLs(cloud_url)
                    for i in range(child_urls.count if hasattr(child_urls, 'count') else len(child_urls)):
                        u = child_urls.item(i) if hasattr(child_urls, 'item') else child_urls[i]
                        lib = toolLibs.toolLibraryAtUrl(u)
                        if lib:
                            name = f"Cloud: {u.leafPath if hasattr(u, 'leafPath') else u.toString()}"
                            discovered_libraries_map[name] = {"type": "cloud", "url": u, "obj": lib}
            except:
                pass
                
            # 2. Local Libraries
            try:
                local_url = toolLibs.urlByLocation(adsk.cam.LibraryLocations.LocalLibraryLocation)
                if local_url:
                    child_urls = toolLibs.childAssetURLs(local_url)
                    for i in range(child_urls.count if hasattr(child_urls, 'count') else len(child_urls)):
                        u = child_urls.item(i) if hasattr(child_urls, 'item') else child_urls[i]
                        lib = toolLibs.toolLibraryAtUrl(u)
                        if lib:
                            name = f"Local: {u.leafPath if hasattr(u, 'leafPath') else u.toString()}"
                            discovered_libraries_map[name] = {"type": "local", "url": u, "obj": lib}
            except:
                pass
                
            # 3. Active Document Tools (Always accessible)
            discovered_libraries_map["Active Document: All Tools in Use"] = {"type": "document", "obj": None}
            
            lib_select = inputs.addDropDownCommandInput('libSelect', 'Select Libraries to Export', adsk.core.DropDownStyles.CheckBoxDropDownStyle)
            for i, name in enumerate(discovered_libraries_map.keys()):
                lib_select.listItems.add(name, i == 0)

            inputs.addBoolValueCommandInput('mergeIntoMaster', 'Merge into Master Tool Crib', True, '', True)
            inputs.addBoolValueCommandInput('autoDeduplicate', 'Deduplicate Identical Cutters', True, '', True)
                
            info = inputs.addTextBoxCommandInput('info', '', 'Select one or more libraries above. ToolWiz will consolidate your cutters, combine unique cutting presets, and eliminate redundant duplicates.', 3, True)
            info.isFullWidth = True
            
        except Exception as e:
            if ui:
                ui.messageBox(f"Command Created Failed:\n{traceback.format_exc()}")

# ==============================================================================
# COMMAND 2: IMPORT DIGITAL TWIN
# ==============================================================================

class ToolWizImportExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            # Fetch latest mutated library JSON from ToolWiz server
            req = urllib.request.Request("http://127.0.0.1:5000/api/twin/get_import_payload")
            response = urllib.request.urlopen(req, timeout=5.0)
            res_data = json.loads(response.read().decode('utf-8'))
            
            if not res_data.get("success") or not res_data.get("library"):
                ui.messageBox("No modified Digital Twin library found on ToolWiz server.\nPlease generate presets in ToolWiz first.")
                return
                
            library_data = res_data["library"]
            lib_name = library_data.get("library_name", "ToolWiz_Twin_Library")
            tools_list = library_data.get("tools", [])
            
            if not tools_list:
                ui.messageBox("The Digital Twin library has 0 tools.")
                return
                
            # Save local staging copy
            local_appdata = os.environ.get('APPDATA', '')
            staging_dir = os.path.join(local_appdata, 'Autodesk', 'CAM360', 'libraries', 'Local')
            os.makedirs(staging_dir, exist_ok=True)
            staging_file = os.path.join(staging_dir, f"{lib_name.replace(':', '_')}.json")
            
            with open(staging_file, "w", encoding="utf-8") as f:
                json.dump({"data": tools_list}, f, indent=2)
                
            msg = (
                f"Digital Twin Ready for Synchronization!\n"
                f"====================================\n"
                f"Library: {lib_name}\n"
                f"Tools Processed: {len(tools_list)}\n\n"
                f"The updated library has been saved to your Fusion Local Libraries directory:\n"
                f"📂 {staging_file}\n\n"
                f"Your tools now contain all material presets (Roughing, Adaptive, Finishing, Slotting) in their Cutting Data tab!"
            )
            ui.messageBox(msg, 'ToolWiz Digital Twin Import')
            
        except Exception as e:
            if ui:
                ui.messageBox(f"Digital Twin Import Failed:\n{traceback.format_exc()}")

class ToolWizImportCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            cmd = args.command
            cmd.isExecutedWhenPreEmpted = False
            cmd.isRepeatable = False
            cmd.isAutoExecute = False
            onExecute = ToolWizImportExecuteHandler()
            cmd.execute.add(onExecute)
            handlers.append(onExecute)
        except Exception as e:
            if ui:
                ui.messageBox(f"Command Created Failed:\n{traceback.format_exc()}")

# ==============================================================================
# COMMAND 3: FAST CAM OPERATION AUTO-SETTER
# ==============================================================================

class ToolWizExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            eventArgs = adsk.core.CommandEventArgs.cast(args)
            inputs = eventArgs.command.commandInputs
            
            op_input = inputs.itemById('targetOp')
            preset_action_input = inputs.itemById('presetAction')
            family_input = inputs.itemById('matFamily')
            alloy_input = inputs.itemById('matAlloy')
            strat_input = inputs.itemById('strategy')
            agg_input = inputs.itemById('aggressiveness')
            
            if not op_input or not family_input or not strat_input or not agg_input:
                ui.messageBox('Error: Dialog inputs could not be read.')
                return
                
            op_name = op_input.selectedItem.name if op_input.selectedItem else ""
            target_op = available_ops_map.get(op_name)
            if not target_op:
                ui.messageBox('No valid CAM operation selected!')
                return
                
            family = family_input.selectedItem.name if family_input.selectedItem else "Aluminum - Wrought (6061)"
            alloy = alloy_input.selectedItem.name if (alloy_input and alloy_input.selectedItem) else ""
            strategy = strat_input.selectedItem.name if strat_input.selectedItem else "Adaptive Roughing"
            aggressiveness = agg_input.valueOne
            
            preset_choice = preset_action_input.selectedItem.name if (preset_action_input and preset_action_input.selectedItem) else "+ Create New Preset (Auto-Named)"
            target_preset_to_replace = preset_choice.replace("Replace: ", "").strip() if preset_choice.startswith("Replace: ") else None
                
            geo_payload, summary_str, existing_presets = get_op_tool_info(target_op)
            if not geo_payload:
                ui.messageBox(f'Could not read tool geometry: {summary_str}')
                return
                
            payload = {
                "family": family, "alloy": alloy, "operation": strategy, "aggressiveness": aggressiveness,
                "diameter": geo_payload["diameter"], "flutes": geo_payload["flutes"], "fluteLength": geo_payload["fluteLength"],
                "shankDiameter": geo_payload["shankDiameter"], "cornerRadius": geo_payload["cornerRadius"],
                "stickout": geo_payload["stickout"], "coating": geo_payload["coating"], "geometry": geo_payload["geometry"]
            }
            
            req = urllib.request.Request("http://127.0.0.1:5000/api/calculate_for_fusion")
            req.add_header('Content-Type', 'application/json; charset=utf-8')
            response = urllib.request.urlopen(req, json.dumps(payload).encode('utf-8'), timeout=5.0)
            calc_result = json.loads(response.read().decode('utf-8'))
            
            if not calc_result.get("success"):
                ui.messageBox(f"ToolWiz Calculation Error: {calc_result.get('error')}")
                return
                
            material_label = alloy if alloy else family
            calc_result["name"] = f"{material_label} - {strategy}"
            
            rpm = calc_result.get("rpm", 5000)
            feed = calc_result.get("feed", 30.0)
            doc = calc_result.get("doc", 0.25)
            woc = calc_result.get("woc", 0.05)
            ramp_feed = calc_result.get("ramp_feed", feed * 0.5)
            plunge_feed = calc_result.get("plunge_feed", feed * 0.25)
            if plunge_feed <= 0:
                plunge_feed = ramp_feed if ramp_feed > 0 else (feed * 0.25 if feed > 0 else 5.0)
            if ramp_feed <= 0:
                ramp_feed = feed * 0.5 if feed > 0 else 10.0
            sfm = calc_result.get("sfm", 300)
            ipt = calc_result.get("ipt", 0.002)
            
            # Mutate tool JSON
            mutated_json, final_preset_name, was_updated = json_mutator.mutate_tool_json(
                geo_payload["raw_json"], calc_result, target_preset_to_replace=target_preset_to_replace
            )
            
            applied = []
            if apply_param(target_op, 'tool_spindleSpeed', f"{rpm} rpm"):
                applied.append(f"Spindle Speed: {rpm:,} RPM ({sfm:.1f} SFM)")
            apply_param(target_op, 'tool_spindleSpeedRamp', f"{rpm} rpm", force=True)
            
            if apply_param(target_op, 'tool_feedCutting', f"{feed:.2f} in/min"):
                applied.append(f"Cutting Feed: {feed:.2f} in/min ({ipt:.4f} IPT)")
            apply_param(target_op, 'tool_feedEntry', f"{feed:.2f} in/min", force=True)
            apply_param(target_op, 'tool_feedExit', f"{feed:.2f} in/min", force=True)
            apply_param(target_op, 'tool_feedRamp', f"{ramp_feed:.2f} in/min", force=True)
            apply_param(target_op, 'tool_feedPlunge', f"{plunge_feed:.2f} in/min", force=True)
            apply_param(target_op, 'tool_feedTransition', f"{feed * 1.5:.2f} in/min", force=True)
            
            if "Adaptive" in strategy:
                if apply_param(target_op, 'optimalLoad', f"{woc:.4f} in"):
                    applied.append(f"Optimal Load (WOC): {woc:.4f} in")
            else:
                if apply_param(target_op, 'stepover', f"{woc:.4f} in") or apply_param(target_op, 'maximumStepover', f"{woc:.4f} in"):
                    applied.append(f"Stepover (WOC): {woc:.4f} in")
                    
            if apply_param(target_op, 'maximumStepdown', f"{doc:.4f} in"):
                applied.append(f"Max Stepdown (DOC): {doc:.4f} in")
                
            action_desc = "Updated preset in-place" if was_updated else "Created new preset"
            applied_summary = "\n".join([f" • {item}" for item in applied])
            msg = (
                f"Cutting Parameters Applied!\n"
                f"====================================\n"
                f"Preset: {final_preset_name} ({action_desc})\n"
                f"Operation: {op_name}\n\n"
                f"{applied_summary}\n\n"
                f"Ramp Feed: {ramp_feed:.2f} in/min | Plunge Feed: {plunge_feed:.2f} in/min"
            )
            ui.messageBox(msg, 'ToolWiz CAM Auto-Setter')
            
        except Exception as e:
            if ui:
                ui.messageBox(f"Auto-Setter Failed:\n{traceback.format_exc()}")

class ToolWizInputChangedHandler(adsk.core.InputChangedEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            eventArgs = adsk.core.InputChangedEventArgs.cast(args)
            inputs = eventArgs.inputs
            cmdInput = eventArgs.input
            
            if cmdInput.id == 'targetOp':
                op_name = cmdInput.selectedItem.name if cmdInput.selectedItem else ""
                target_op = available_ops_map.get(op_name)
                tool_info_box = inputs.itemById('toolInfo')
                preset_action_input = inputs.itemById('presetAction')
                if target_op:
                    _, summary_str, existing_presets = get_op_tool_info(target_op)
                    if tool_info_box: tool_info_box.text = summary_str
                    if preset_action_input:
                        preset_action_input.listItems.clear()
                        preset_action_input.listItems.add("+ Create New Preset (Auto-Named)", True)
                        for p in existing_presets:
                            preset_action_input.listItems.add(f"Replace: {p}", False)
                            
            elif cmdInput.id == 'matFamily':
                family = cmdInput.selectedItem.name if cmdInput.selectedItem else ""
                alloy_input = inputs.itemById('matAlloy')
                if alloy_input:
                    alloy_input.listItems.clear()
                    alloys = alloys_dict.get(family, [])
                    if not alloys:
                        alloy_input.listItems.add("Standard Grade", True)
                    else:
                        for i, a in enumerate(alloys):
                            alloy_input.listItems.add(a, True if i == 0 else False)
        except Exception as e:
            pass

class ToolWizCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            cmd = args.command
            cmd.isExecutedWhenPreEmpted = False
            cmd.isRepeatable = False
            cmd.isAutoExecute = False
            onExecute = ToolWizExecuteHandler()
            cmd.execute.add(onExecute)
            handlers.append(onExecute)
            
            onInputChanged = ToolWizInputChangedHandler()
            cmd.inputChanged.add(onInputChanged)
            handlers.append(onInputChanged)
            
            inputs = cmd.commandInputs
            global available_ops_map
            available_ops_map.clear()
            
            camObj = adsk.cam.CAM.cast(app.activeDocument.products.itemByProductType('CAMProductType'))
            if not camObj:
                ui.messageBox('Please switch to the Manufacture (CAM) workspace with an active setup.')
                return
                
            preselect_op_name = None
            try:
                sel = ui.activeSelections
                if sel.count > 0:
                    ent = sel.item(0).entity
                    if ent.objectType == adsk.cam.Operation.classType():
                        parent_setup = ent.parent
                        setup_name = parent_setup.name if parent_setup else "Setup"
                        preselect_op_name = f"{setup_name} > {ent.name}"
            except:
                pass
                
            for setup in camObj.setups:
                for op in setup.allOperations:
                    if hasattr(op, 'tool') and op.tool:
                        op_label = f"{setup.name} > {op.name}"
                        available_ops_map[op_label] = op
                        if not preselect_op_name:
                            preselect_op_name = op_label
                            
            if not available_ops_map:
                ui.messageBox('No operations with tools found in active document.')
                return
                
            op_input = inputs.addDropDownCommandInput('targetOp', 'Target Operation', adsk.core.DropDownStyles.TextListDropDownStyle)
            for op_label in available_ops_map.keys():
                op_input.listItems.add(op_label, op_label == preselect_op_name)
                
            initial_op = available_ops_map.get(preselect_op_name)
            _, initial_summary, existing_presets = get_op_tool_info(initial_op)
            tool_info_box = inputs.addTextBoxCommandInput('toolInfo', 'Detected Tool', initial_summary, 2, True)
            tool_info_box.isFullWidth = True
            
            preset_input = inputs.addDropDownCommandInput('presetAction', 'Cutting Data Preset', adsk.core.DropDownStyles.TextListDropDownStyle)
            preset_input.listItems.add('+ Create New Preset (Auto-Named)', True)
            for p in existing_presets:
                preset_input.listItems.add(f"Replace: {p}", False)
            
            global families_list, alloys_dict
            try:
                response = urllib.request.urlopen("http://127.0.0.1:5000/api/data", timeout=1.5)
                data = json.loads(response.read().decode('utf-8'))
                if "families" in data and len(data["families"]) > 0: families_list = data["families"]
                if "alloys" in data:
                    new_alloys = {}
                    for a in data["alloys"]:
                        f = a.get("family", "")
                        name = f"{a.get('alloy', '')} ({a.get('condition', '')})" if a.get('condition') else a.get('alloy', '')
                        if f and name:
                            if f not in new_alloys: new_alloys[f] = []
                            if name not in new_alloys[f]: new_alloys[f].append(name)
                    if new_alloys: alloys_dict = new_alloys
            except:
                pass
                
            mat_input = inputs.addDropDownCommandInput('matFamily', 'Material Family', adsk.core.DropDownStyles.TextListDropDownStyle)
            default_family = "Steel - Tool (H13)" if "Steel - Tool (H13)" in families_list else families_list[0]
            for m in families_list:
                mat_input.listItems.add(m, m == default_family)
                
            alloy_input = inputs.addDropDownCommandInput('matAlloy', 'Specific Alloy', adsk.core.DropDownStyles.TextListDropDownStyle)
            init_alloys = alloys_dict.get(default_family, ["Standard Grade"])
            for i, a in enumerate(init_alloys):
                alloy_input.listItems.add(a, i == 0)
                
            strat_input = inputs.addDropDownCommandInput('strategy', 'Strategy', adsk.core.DropDownStyles.TextListDropDownStyle)
            strat_input.listItems.add('Adaptive Roughing', True)
            strat_input.listItems.add('Roughing', False)
            strat_input.listItems.add('Finishing', False)
            strat_input.listItems.add('Slotting', False)
            strat_input.listItems.add('Facing', False)
            
            agg_input = inputs.addIntegerSliderCommandInput('aggressiveness', 'Aggressiveness', 0, 100)
            agg_input.valueOne = 50
            
        except Exception as e:
            if ui:
                ui.messageBox(f"Command Created Failed:\n{traceback.format_exc()}")

# ==============================================================================
# COMMAND 4: STOCK TO LEAVE & DEFLECTION MANAGER
# ==============================================================================

def op_supports_stock_to_leave(op):
    """Checks if an operation supports stock to leave parameters."""
    if not op or not hasattr(op, 'parameters') or not op.parameters:
        return False
    strat = getattr(op, 'strategy', '').lower()
    op_name = getattr(op, 'name', '').lower()
    # Exclude hole-making operations (drilling, tapping, boring, reaming)
    if any(h in strat for h in ['drill', 'tap', 'bore', 'thread', 'hole', 'circular', 'ream']):
        return False
    if op_name.startswith('drill') or op_name.startswith('tap') or 'drill' in op_name:
        if any(h in strat for h in ['drill', 'bore', 'hole', 'tap']):
            return False
            
    for p_name in ['stockToLeave', 'radialStockToLeave', 'useStockToLeave', 'isStockToLeave']:
        p = op.parameters.itemByName(p_name)
        if p is not None:
            return True
    return False

def get_cam_document_units():
    """Detects whether active CAM workspace / document is in millimeters or inches."""
    try:
        des = app.activeDocument.products.itemByProductType('DesignProductType')
        if des and hasattr(des, 'unitsManager') and des.unitsManager:
            u = str(des.unitsManager.defaultLengthUnits).lower()
            if any(m in u for m in ['mm', 'millimeter', 'milli']):
                return "mm"
            if any(m in u for m in ['in', 'inch']):
                return "in"
    except:
        pass
    try:
        prod = app.activeProduct
        if prod and hasattr(prod, 'unitsManager') and prod.unitsManager:
            u = str(prod.unitsManager.defaultLengthUnits).lower()
            if any(m in u for m in ['mm', 'millimeter', 'milli']):
                return "mm"
            if any(m in u for m in ['in', 'inch']):
                return "in"
    except:
        pass
    try:
        camObj = app.activeDocument.products.itemByProductType('CAMProductType')
        if camObj and hasattr(camObj, 'unitsManager') and camObj.unitsManager:
            u = str(camObj.unitsManager.defaultLengthUnits).lower()
            if any(m in u for m in ['mm', 'millimeter', 'milli']):
                return "mm"
            if any(m in u for m in ['in', 'inch']):
                return "in"
    except:
        pass
    try:
        doc = app.activeDocument
        if doc and hasattr(doc, 'unitsManager') and doc.unitsManager:
            u = str(doc.unitsManager.defaultLengthUnits).lower()
            if any(m in u for m in ['mm', 'millimeter', 'milli']):
                return "mm"
            if any(m in u for m in ['in', 'inch']):
                return "in"
    except:
        pass
    return "in"

def clean_and_eval_stock_expr(expr_str, doc_unit="in"):
    """Evaluates dimension expressions like '(-.1) * 1mm', '(.1)*1mm', or '0mm'
    into clean, formatted numeric strings like '-0.100 mm' or '0.000 mm'.
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
        
    # Try Fusion's native unitsManager first if available
    try:
        prod = app.activeProduct
        if prod and hasattr(prod, 'unitsManager') and prod.unitsManager:
            # evaluateExpression always returns database units (centimeters)
            val_cm = prod.unitsManager.evaluateExpression(s, unit)
            if unit == "mm":
                val = val_cm * 10.0  # cm to mm
            else:
                val = val_cm / 2.54  # cm to inches
            if abs(val) < 1e-6:
                val = 0.0
            if unit == "mm":
                return f"{val:.3f} mm"
            else:
                return f"{val:.4f} in"
    except:
        pass

    # Regex arithmetic fallback
    try:
        math_str = re.sub(r'([0-9\.\)])\s*(?:mm|millimeter|millimetre|inches|inch|in|\")', r'\1 * 1.0', s, flags=re.I)
        math_str = re.sub(r'(?:mm|millimeter|millimetre|inches|inch|in|\")', r' 1.0 ', math_str, flags=re.I)
        if re.match(r'^[0-9\.\+\-\*\/\(\)\s]+$', math_str):
            val = float(eval(math_str, {'__builtins__': None}, {}))
            if abs(val) < 1e-6:
                val = 0.0
            if unit == "mm":
                return f"{val:.3f} mm"
            else:
                return f"{val:.4f} in"
    except:
        pass
        
    return s

def is_op_stock_to_leave_active(op):
    """Determines whether Stock to Leave is actively checked / enabled on an operation."""
    if not op or not hasattr(op, 'parameters') or not op.parameters:
        return False
        
    for chk_name in ['useStockToLeave', 'isStockToLeave']:
        p_chk = op.parameters.itemByName(chk_name)
        if p_chk is not None:
            # 1. Check expression string
            if hasattr(p_chk, 'expression') and p_chk.expression is not None:
                expr = str(p_chk.expression).strip().lower()
                if expr in ['true', '1', 'yes']:
                    return True
                if expr in ['false', '0', 'no']:
                    return False
            # 2. Check value object
            try:
                v = getattr(p_chk, 'value', None)
                if v is not None:
                    if hasattr(v, 'value'):
                        return bool(v.value)
                    return bool(v)
            except:
                pass
                
    # 3. Fallback: check if radial parameter exists and is enabled
    for r_name in ['stockToLeave', 'radialStockToLeave']:
        p_rad = op.parameters.itemByName(r_name)
        if p_rad is not None:
            if hasattr(p_rad, 'isEnabled'):
                return bool(p_rad.isEnabled)
                
    return False

def get_op_stock_values(op, doc_unit="in"):
    """Retrieves current radial and axial stock to leave expressions cleanly formatted.
    Returns (is_active, rad_val, ax_val).
    If Stock to Leave is not actively checked, returns (False, zero_str, zero_str).
    """
    zero_str = "0.000 mm" if doc_unit == "mm" else "0.0000 in"
    is_active = is_op_stock_to_leave_active(op)
    
    rad_val = zero_str
    for r_name in ['stockToLeave', 'radialStockToLeave']:
        p = op.parameters.itemByName(r_name)
        if p is not None and p.expression:
            rad_val = clean_and_eval_stock_expr(p.expression, doc_unit)
            break
            
    ax_val = zero_str
    for a_name in ['verticalStockToLeave', 'axialStockToLeave']:
        p = op.parameters.itemByName(a_name)
        if p is not None and p.expression:
            raw_ax = str(p.expression).strip()
            # If axial stock references radial stock expression (e.g. 'stockToLeave'), resolve to rad_val
            if raw_ax in ['stockToLeave', 'radialStockToLeave', 'useStockToLeave']:
                ax_val = rad_val
            else:
                ax_val = clean_and_eval_stock_expr(raw_ax, doc_unit)
            break
            
    if not is_active:
        return False, zero_str, zero_str
        
    return True, rad_val, ax_val

def get_op_cut_params(op, doc_unit="in"):
    """Extracts feeds, speeds, DOC, and WOC from operation, correctly converting metric values to inches."""
    rpm = 0.0
    feed = 0.0
    doc = 0.0
    woc = 0.0
    try:
        # 1. Spindle Speed (RPM)
        p_rpm = op.parameters.itemByName('tool_spindleSpeed')
        if p_rpm:
            try:
                # Expression has highest priority for user-entered RPM string (e.g. "3500 rpm" or "3500")
                if p_rpm.expression:
                    import re
                    m = re.search(r'([0-9]+(?:\.[0-9]+)?)', str(p_rpm.expression))
                    if m:
                        rpm = float(m.group(1))
                # Fallback to evaluated value
                if rpm <= 0 and hasattr(p_rpm, 'value') and hasattr(p_rpm.value, 'value'):
                    val = float(p_rpm.value.value)
                    # Fusion CAM angular velocity database unit is rad/s (1 rad/s = 9.5493 RPM)
                    if 0 < val < 2000:
                        rpm = val * 60.0 / (2.0 * math.pi)
                    else:
                        rpm = val
            except:
                pass
                
        # 2. Cutting Feedrate (IPM)
        p_feed = op.parameters.itemByName('tool_feedCutting')
        if p_feed:
            try:
                # Primary: parse expression string
                if p_feed.expression:
                    import re
                    m = re.search(r'([0-9]+(?:\.[0-9]+)?)', str(p_feed.expression))
                    if m:
                        raw_feed = float(m.group(1))
                        expr_str = str(p_feed.expression).lower()
                        # If feed is above 100 or metric unit detected, it is mm/min
                        if 'mm' in expr_str or doc_unit == 'mm' or raw_feed > 120:
                            feed = raw_feed / 25.4  # mm/min to IPM
                        else:
                            feed = raw_feed
                # Secondary: evaluated internal value in cm/s (1 cm/s = 60 cm/min = 600 mm/min = 23.622 in/min)
                if feed <= 0 and hasattr(p_feed, 'value') and hasattr(p_feed.value, 'value') and isinstance(p_feed.value.value, (int, float)):
                    val_cm_s = float(p_feed.value.value)
                    if val_cm_s > 0:
                        feed = val_cm_s * 60.0 / 2.54  # cm/s to in/min (IPM)
            except:
                pass
                
        # Sanity check: cutting feedrate in IPM should almost never exceed 150 IPM for precision milling
        if feed > 150:
            feed = feed / 25.4

        # 3. Axial Depth of Cut (DOC) - only if parameter is enabled
        for doc_name in ['maximumStepdown', 'stepdown']:
            p = op.parameters.itemByName(doc_name)
            if p and getattr(p, 'isEnabled', True):
                doc = parse_cam_param_to_inches(p, 0.0, doc_unit)
                if doc > 0:
                    break
                    
        # 4. Radial Width of Cut (WOC)
        # Check finishing stepover first (for 2D Contour and finishing ops)
        for woc_fin in ['finishingStepover']:
            p = op.parameters.itemByName(woc_fin)
            if p and getattr(p, 'isEnabled', True):
                woc = parse_cam_param_to_inches(p, 0.0, doc_unit)
                if woc > 0:
                    break
                    
        if woc <= 0:
            for woc_name in ['stepover', 'optimalLoad', 'maximumStepover']:
                p = op.parameters.itemByName(woc_name)
                if p and getattr(p, 'isEnabled', True):
                    woc = parse_cam_param_to_inches(p, 0.0, doc_unit)
                    if woc > 0:
                        break
    except:
        pass
        
    return rpm, feed, doc, woc

def query_toolwiz_stock_compensation(family, alloy, aggressiveness, mode, custom_rad="0.0000 in", custom_ax="0.0000 in", doc_unit="in"):
    """Queries http://127.0.0.1:5000/api/stock_compensation for all cached operations"""
    try:
        ops_payload = []
        for op_id, op_info in stock_ops_cache.items():
            geo = op_info.get("geo", {})
            op_unit = op_info.get("unit", doc_unit)
            zero_val = "0.000 mm" if op_unit == "mm" else "0.0000 in"
            ops_payload.append({
                "id": op_id,
                "name": op_info["name"],
                "strategy": op_info["strategy"],
                "unit": op_unit,
                "diameter": geo.get("diameter", 0.375),
                "flutes": geo.get("flutes", 4),
                "fluteLength": geo.get("fluteLength", 0.75),
                "shankDiameter": geo.get("shankDiameter", 0.375),
                "stickout": geo.get("stickout", 1.25),
                "coating": geo.get("coating", "Uncoated"),
                "geometry": geo.get("geometry", "Square"),
                "rpm": op_info.get("rpm", 0.0),
                "feedrate": op_info.get("feed", 0.0),
                "doc": op_info.get("doc", 0.0),
                "woc": op_info.get("woc", 0.0),
                "current_radial_stock": op_info.get("current_radial", zero_val),
                "current_axial_stock": op_info.get("current_axial", zero_val)
            })
            
        payload = {
            "family": family,
            "alloy": alloy,
            "aggressiveness": aggressiveness,
            "mode": mode,
            "unit": doc_unit,
            "custom_radial_offset": custom_rad,
            "custom_axial_offset": custom_ax,
            "operations": ops_payload
        }
        
        req = urllib.request.Request("http://127.0.0.1:5000/api/stock_compensation")
        req.add_header('Content-Type', 'application/json; charset=utf-8')
        response = urllib.request.urlopen(req, json.dumps(payload).encode('utf-8'), timeout=2.5)
        res_data = json.loads(response.read().decode('utf-8'))
        if res_data.get("success"):
            return res_data.get("results", [])
    except:
        pass
    return []

def find_table_input(inputs, table, input_id):
    """Finds an input control in either dialog inputs or table commandInputs"""
    item = inputs.itemById(input_id)
    if not item and table and hasattr(table, 'commandInputs'):
        item = table.commandInputs.itemById(input_id)
    return item

def escape_html(text):
    """Escapes HTML special characters for safe formattedText rendering."""
    if not text:
        return ""
    return str(text).replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')

def format_cell_html(text, bg_color=None, align="left"):
    """Wraps text in a formatted HTML table container with custom background color and padding."""
    if not bg_color:
        return text
    inner_text = text if (text and text.strip()) else "&nbsp;"
    return (
        f'<table width="100%" bgcolor="{bg_color}" cellpadding="3" cellspacing="0" '
        f'style="background-color:{bg_color}; border-radius:3px;">'
        f'<tr><td align="{align}" style="color:#222222; font-size:11px; font-family:sans-serif;">'
        f'{inner_text}'
        f'</td></tr></table>'
    )

def add_cell_text(parent_inputs, item_id, text, num_rows=1, is_read_only=True, bg_color=None, align="left"):
    """Helper to create formatted text with background contrast or fallback to string value input for table cells."""
    formatted = format_cell_html(text, bg_color, align) if bg_color else text
    try:
        return parent_inputs.addTextBoxCommandInput(item_id, '', formatted, num_rows, is_read_only)
    except:
        plain_text = text.replace('<b>', '').replace('</b>', '').replace('<br>', ' ').replace('<br/>', ' ')
        inp = parent_inputs.addStringValueInput(item_id, '', plain_text)
        inp.isReadOnly = is_read_only
        return inp



class ToolWizStockExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            eventArgs = adsk.core.CommandEventArgs.cast(args)
            inputs = eventArgs.command.commandInputs
            
            applied_ops = []
            for op_id, op_info in stock_ops_cache.items():
                chk = op_info.get("chk")
                if chk and chk.value and getattr(chk, 'isVisible', True):
                    inp_rad = op_info.get("inp_rad")
                    inp_ax = op_info.get("inp_ax")
                    
                    rad_raw = inp_rad.value.strip() if inp_rad else op_info["current_radial"]
                    ax_raw = inp_ax.value.strip() if inp_ax else op_info["current_axial"]
                    
                    doc_u = op_info.get("unit", "in")
                    rad_val = clean_and_eval_stock_expr(rad_raw, doc_u)
                    ax_val = clean_and_eval_stock_expr(ax_raw, doc_u)
                    
                    op = op_info["op"]
                    
                    # 1. Enable Stock to Leave checkbox
                    for chk_name in ['useStockToLeave', 'isStockToLeave']:
                        p_chk = op.parameters.itemByName(chk_name)
                        if p_chk:
                            try: p_chk.expression = "true"
                            except:
                                try: p_chk.value.value = True
                                except: pass
                                
                    # 2. Unlock independent radial and axial stock
                    p_simple = op.parameters.itemByName('simpleStockToLeave')
                    if p_simple:
                        try: p_simple.expression = "false"
                        except:
                            try: p_simple.value.value = False
                            except: pass
                            
                    # 3. Set Radial Stock to Leave
                    for r_name in ['stockToLeave', 'radialStockToLeave']:
                        p_rad = op.parameters.itemByName(r_name)
                        if p_rad:
                            p_rad.expression = str(rad_val)
                            break
                            
                    # 4. Set Axial Stock to Leave
                    for a_name in ['verticalStockToLeave', 'axialStockToLeave']:
                        p_ax = op.parameters.itemByName(a_name)
                        if p_ax:
                            p_ax.expression = str(ax_val)
                            break
                            
                    applied_ops.append(f" • {op_info['label']}: Radial {rad_val} | Axial {ax_val}")
                    
            if applied_ops:
                summary = "\n".join(applied_ops)
                msg = (
                    f"Stock to Leave Compensation Applied!\n"
                    f"====================================\n"
                    f"Operations Updated: {len(applied_ops)}\n\n"
                    f"{summary}\n\n"
                    f"Deflection and material springback compensation values are now active in your toolpaths."
                )
                ui.messageBox(msg, 'ToolWiz Stock to Leave Manager')
            else:
                ui.messageBox('No operations were selected to update.', 'ToolWiz Stock to Leave Manager')
                
        except Exception as e:
            if ui:
                ui.messageBox(f"Stock Manager Apply Failed:\n{traceback.format_exc()}")

class ToolWizStockInputChangedHandler(adsk.core.InputChangedEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        global _is_updating_ui
        if _is_updating_ui:
            return
        cmdInput = None
        try:
            eventArgs = adsk.core.InputChangedEventArgs.cast(args)
            inputs = eventArgs.inputs
            cmdInput = eventArgs.input
            if not cmdInput:
                return
                
            mat_family_input = adsk.core.DropDownCommandInput.cast(inputs.itemById('stockMatFamily'))
            alloy_input = adsk.core.DropDownCommandInput.cast(inputs.itemById('stockMatAlloy'))
            agg_input = inputs.itemById('stockAggressiveness')
            mode_input = adsk.core.DropDownCommandInput.cast(inputs.itemById('stockBatchMode'))
            custom_rad = inputs.itemById('customRadOffset')
            custom_ax = inputs.itemById('customAxOffset')
            
            # 1. Update Alloy Dropdown if Material Family changed
            if cmdInput.id == 'stockMatFamily':
                family = cmdInput.selectedItem.name if cmdInput.selectedItem else ""
                if alloy_input:
                    alloy_input.listItems.clear()
                    alloys = alloys_dict.get(family, [])
                    if not alloys:
                        alloy_input.listItems.add("Standard Grade", True)
                    else:
                        for i, a in enumerate(alloys):
                            alloy_input.listItems.add(a, i == 0)
                            
            # 2. Toggle custom offset input visibility
            if cmdInput.id == 'stockBatchMode':
                is_custom = mode_input.selectedItem.name == 'Batch Apply Custom Offset' if mode_input.selectedItem else False
                if custom_rad: custom_rad.isVisible = is_custom
                if custom_ax: custom_ax.isVisible = is_custom
                
            # 3. Handle Setup Master ON/OFF Switches
            if cmdInput.id == 'setup_master_toggle':
                master_sw = adsk.core.BoolValueCommandInput.cast(cmdInput)
                is_master_active = master_sw.value if master_sw else getattr(cmdInput, 'value', True)
                
                _is_updating_ui = True
                try:
                    for s_name, s_data in stock_setups_cache.items():
                        sw_id = s_data.get("sw_id")
                        sw_input = adsk.core.BoolValueCommandInput.cast(inputs.itemById(sw_id))
                        if sw_input:
                            sw_input.value = is_master_active
                        
                        for op_id in s_data.get("ops", []):
                            op_info = stock_ops_cache.get(op_id)
                            if not op_info:
                                continue
                            
                            # Update Checkbox (Col 0)
                            chk = op_info.get("chk")
                            if chk:
                                if not is_master_active:
                                    chk.value = False
                                else:
                                    chk.value = op_info.get("is_finishing", False)
                                    
                            # Set isVisible on all cells in the row to collapse or show the row in the table
                            for cell in op_info.get("cells", []):
                                try:
                                    cell.isVisible = is_master_active
                                except:
                                    pass
                finally:
                    _is_updating_ui = False
                return

            if cmdInput.id.startswith('setup_sw_'):
                sw = adsk.core.BoolValueCommandInput.cast(cmdInput)
                is_active = sw.value if sw else getattr(cmdInput, 'value', True)
                
                target_setup = None
                for s_name, s_data in stock_setups_cache.items():
                    if s_data.get("sw_id") == cmdInput.id:
                        target_setup = s_data
                        break
                        
                if target_setup:
                    _is_updating_ui = True
                    try:
                        for op_id in target_setup.get("ops", []):
                            op_info = stock_ops_cache.get(op_id)
                            if not op_info:
                                continue
                            
                            # Update Checkbox (Col 0)
                            chk = op_info.get("chk")
                            if chk:
                                if not is_active:
                                    chk.value = False
                                else:
                                    chk.value = op_info.get("is_finishing", False)
                                    
                            # Set isVisible on all cells in the row to collapse or show the row in the table
                            for cell in op_info.get("cells", []):
                                try:
                                    cell.isVisible = is_active
                                except:
                                    pass

                        # Sync master toggle checkbox state
                        master_sw = adsk.core.BoolValueCommandInput.cast(inputs.itemById('setup_master_toggle'))
                        if master_sw:
                            all_checked = all(
                                getattr(inputs.itemById(s['sw_id']), 'value', False)
                                for s in stock_setups_cache.values()
                                if inputs.itemById(s['sw_id'])
                            )
                            master_sw.value = all_checked
                    finally:
                        _is_updating_ui = False
                return
                
            # 4. Handle Material / Aggressiveness / Mode changes
            if cmdInput.id in ['stockMatFamily', 'stockMatAlloy', 'stockAggressiveness', 'stockBatchMode', 'customRadOffset', 'customAxOffset']:
                family = mat_family_input.selectedItem.name if (mat_family_input and mat_family_input.selectedItem) else "Aluminum - Wrought (6061)"
                alloy = alloy_input.selectedItem.name if (alloy_input and alloy_input.selectedItem) else ""
                agg = 50
                if agg_input:
                    slider_input = adsk.core.IntegerSliderCommandInput.cast(agg_input)
                    if slider_input:
                        agg = slider_input.valueOne
                    elif hasattr(agg_input, 'valueOne'):
                        agg = agg_input.valueOne
                    elif hasattr(agg_input, 'value'):
                        agg = agg_input.value
                mode_choice = mode_input.selectedItem.name if (mode_input and mode_input.selectedItem) else "Auto-Compensate Finishing (Negative Stock)"
                
                mode_code = "auto_compensate"
                if "Zero-Out" in mode_choice:
                    mode_code = "zero_finishing"
                elif "Custom" in mode_choice:
                    mode_code = "custom"
                
                doc_u = "in"
                for o_info in stock_ops_cache.values():
                    doc_u = o_info.get("unit", "in")
                    break
                zero_str = "0.000 mm" if doc_u == "mm" else "0.0000 in"
                c_rad = custom_rad.value if custom_rad else zero_str
                c_ax = custom_ax.value if custom_ax else zero_str
                
                calc_results = query_toolwiz_stock_compensation(family, alloy, agg, mode_code, c_rad, c_ax, doc_unit=doc_u)
                if calc_results:
                    _is_updating_ui = True
                    try:
                        for res in calc_results:
                            op_id = res.get("id")
                            op_info = stock_ops_cache.get(op_id)
                            if not op_info:
                                continue
                                
                            rad_val = res.get("recommended_radial_stock")
                            ax_val = res.get("recommended_axial_stock")
                            adv_text = res.get("advisory")
                            is_fin = res.get("is_finishing", False)
                            op_info["is_finishing"] = is_fin
                            
                            inp_r = op_info.get("inp_rad")
                            inp_a = op_info.get("inp_ax")
                            lbl_adv = op_info.get("lbl_adv")
                            chk = op_info.get("chk")
                            
                            if inp_r and rad_val is not None:
                                inp_r.value = clean_and_eval_stock_expr(str(rad_val), doc_u)
                            if inp_a and ax_val is not None:
                                inp_a.value = clean_and_eval_stock_expr(str(ax_val), doc_u)
                            if lbl_adv and adv_text:
                                adv_html = str(adv_text).replace('\n', '<br>')
                                bg_col = op_info.get("bg_color", "#ffffff")
                                formatted_val = format_cell_html(adv_html, bg_col)
                                adv_box = adsk.core.TextBoxCommandInput.cast(lbl_adv)
                                if adv_box:
                                    adv_box.formattedText = formatted_val
                                elif hasattr(lbl_adv, 'formattedText'):
                                    lbl_adv.formattedText = formatted_val
                                elif hasattr(lbl_adv, 'value'):
                                    lbl_adv.value = str(adv_text)

                                    
                            if cmdInput.id == 'stockBatchMode' and chk and "Finishing" in mode_choice and chk.isVisible:
                                chk.value = is_fin
                    finally:
                        _is_updating_ui = False
                        
        except Exception as e:
            try:
                log_path = os.path.expanduser('~/.gemini/antigravity/scratch/stock_manager_debug.log')
                with open(log_path, 'a', encoding='utf-8') as f:
                    f.write(f"InputChanged error on {getattr(cmdInput, 'id', 'unknown')}:\n{traceback.format_exc()}\n")
            except:
                pass


class ToolWizStockCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            cmd = args.command
            cmd.isExecutedWhenPreEmpted = False
            cmd.isRepeatable = False
            cmd.isAutoExecute = False
            onExecute = ToolWizStockExecuteHandler()
            cmd.execute.add(onExecute)
            handlers.append(onExecute)
            
            onInputChanged = ToolWizStockInputChangedHandler()
            cmd.inputChanged.add(onInputChanged)
            handlers.append(onInputChanged)
            
            inputs = cmd.commandInputs
            global stock_ops_cache, stock_setups_cache, stock_table_input
            stock_ops_cache.clear()
            stock_setups_cache.clear()
            stock_table_input = None
            
            camObj = adsk.cam.CAM.cast(app.activeDocument.products.itemByProductType('CAMProductType'))
            if not camObj:
                ui.messageBox('Please switch to the Manufacture (CAM) workspace with an active setup.')
                return
                
            doc_unit = get_cam_document_units()
            
            # Scan setups and operations
            op_idx = 0
            for setup in camObj.setups:
                setup_name = setup.name
                for op in setup.allOperations:
                    try:
                        if op_supports_stock_to_leave(op):
                            op_idx += 1
                            op_id = f"op_{op_idx}"
                            op_label = f"{setup_name} > {op.name}"
                            geo_payload, tool_summary, _ = get_op_tool_info(op)
                            is_active, rad_val, ax_val = get_op_stock_values(op, doc_unit)
                            if is_active and ("mm" in str(rad_val).lower() or "mm" in str(ax_val).lower()):
                                doc_unit = "mm"
                            rpm, feed, doc, woc = get_op_cut_params(op, doc_unit)
                            strat = getattr(op, 'strategy', 'contour2d')
                            
                            tool_short = "Tool"
                            if geo_payload:
                                t_num = geo_payload.get('number', 1)
                                t_dia = geo_payload.get('diameter', 0.25)
                                t_flutes = geo_payload.get('flutes', 4)
                                t_type = geo_payload.get('tool_type', 'Flat End Mill')
                                tool_short = f"T{t_num}: {t_dia:.3f}\" {t_type} ({t_flutes}FL)"
                            elif tool_summary:
                                tool_short = tool_summary.split('|')[0].strip()
                                
                            if setup_name not in stock_setups_cache:
                                s_idx = len(stock_setups_cache)
                                stock_setups_cache[setup_name] = {
                                    "sw_id": f"setup_sw_{s_idx}",
                                    "ops": [],
                                    "name": setup_name,
                                    "idx": s_idx
                                }
                            stock_setups_cache[setup_name]["ops"].append(op_id)
                                
                            stock_ops_cache[op_id] = {
                                "op": op,
                                "op_id": op_id,
                                "setup_name": setup_name,
                                "label": op_label,
                                "name": op.name,
                                "strategy": strat,
                                "tool_summary": tool_short,
                                "unit": doc_unit,
                                "geo": geo_payload or {
                                    "diameter": 0.375, "flutes": 4, "fluteLength": 0.75,
                                    "shankDiameter": 0.375, "stickout": 1.25, "coating": "Uncoated"
                                },
                                "stock_active": is_active,
                                "current_radial": rad_val,
                                "current_axial": ax_val,
                                "rpm": rpm,
                                "feed": feed,
                                "doc": doc,
                                "woc": woc
                            }
                    except:
                        pass
                        
            if not stock_ops_cache:
                ui.messageBox('No operations supporting Stock to Leave were found in the active document.')
                return
                
            # Populate Materials from Tool Wizard DB
            global families_list, alloys_dict
            try:
                response = urllib.request.urlopen("http://127.0.0.1:5000/api/data", timeout=1.5)
                data = json.loads(response.read().decode('utf-8'))
                if "families" in data and len(data["families"]) > 0:
                    families_list = data["families"]
                if "alloys" in data:
                    new_alloys = {}
                    for a in data["alloys"]:
                        f = a.get("family", "")
                        name = f"{a.get('alloy', '')} ({a.get('condition', '')})" if a.get('condition') else a.get('alloy', '')
                        if f and name:
                            if f not in new_alloys: new_alloys[f] = []
                            if name not in new_alloys[f]: new_alloys[f].append(name)
                    if new_alloys:
                        alloys_dict = new_alloys
            except:
                pass

            # Instructions Header
            intro_box = inputs.addTextBoxCommandInput(
                'stockIntro', '',
                '<b>ToolWiz Stock to Leave & Deflection Manager</b><br>'
                'Pre-populates recommended <b>negative radial stock to leave</b> on finishing toolpaths '
                'based on predicted cutter deflection and workpiece elastic springback.',
                2, True
            )
            intro_box.isFullWidth = True

            # Material Dropdowns
            mat_family_input = inputs.addDropDownCommandInput('stockMatFamily', 'Workpiece Material', adsk.core.DropDownStyles.TextListDropDownStyle)
            default_family = "Titanium Alloy" if "Titanium Alloy" in families_list else families_list[0]
            for m in families_list:
                mat_family_input.listItems.add(m, m == default_family)
                
            alloy_input = inputs.addDropDownCommandInput('stockMatAlloy', 'Specific Alloy', adsk.core.DropDownStyles.TextListDropDownStyle)
            init_alloys = alloys_dict.get(default_family, ["Standard Grade"])
            for i, a in enumerate(init_alloys):
                alloy_input.listItems.add(a, i == 0)
                
            agg_input = inputs.addIntegerSliderCommandInput('stockAggressiveness', 'Aggressiveness', 0, 100)
            agg_input.valueOne = 50
            
            mode_input = inputs.addDropDownCommandInput('stockBatchMode', 'Compensation Preset', adsk.core.DropDownStyles.TextListDropDownStyle)
            mode_input.listItems.add('Auto-Compensate Finishing (Negative Stock)', True)
            mode_input.listItems.add('Zero-Out Finishing (0.0000")', False)
            mode_input.listItems.add('Batch Apply Custom Offset', False)
            
            zero_str = "0.000 mm" if doc_unit == "mm" else "0.0000 in"
            custom_rad = inputs.addStringValueInput('customRadOffset', 'Custom Radial Stock', zero_str)
            custom_ax = inputs.addStringValueInput('customAxOffset', 'Custom Axial Stock', zero_str)
            custom_rad.isVisible = False
            custom_ax.isVisible = False
            
            # Setup Master ON/OFF switches (if multiple setups exist)
            if len(stock_setups_cache) > 1:
                setup_group = inputs.addGroupCommandInput('setupGroup', 'Setups to Include')
                setup_group.isExpanded = True
                setup_group.children.addBoolValueInput(
                    'setup_master_toggle', '<b>Select / Deselect All Setups</b>', True, '', True
                )
                for s_name, s_data in stock_setups_cache.items():
                    s_ops = s_data["ops"]
                    sw_id = s_data["sw_id"]
                    setup_group.children.addBoolValueInput(
                        sw_id, f'{s_name} ({len(s_ops)} ops)', True, '', True
                    )
            
            # Initial calculation from Tool Wizard
            init_results = query_toolwiz_stock_compensation(
                default_family, init_alloys[0] if init_alloys else "", 50, "auto_compensate", doc_unit=doc_unit
            )
            res_map = {r.get("id"): r for r in init_results} if init_results else {}
            
            # Column ratios (7 columns): Apply, Toolpath Operation, Cutter, Current Stock To Leave, New Radial Stock, New Axial Stock, ToolWiz Advisory
            col_ratio = '2:10:6:5:4:4:7'
            
            # 1. Fixed Header Table (Never scrolls away)
            header_table = inputs.addTableCommandInput('stockHeaderTable', 'Operations List', 7, col_ratio)
            header_table.isFullWidth = True
            header_table.minimumVisibleRows = 1
            header_table.maximumVisibleRows = 1
            header_table.hasGrid = False
            header_table.columnSpacing = 4
            header_table.rowSpacing = 3
            header_table.tablePresentationStyle = adsk.core.TablePresentationStyles.transparentBackgroundTablePresentationStyle
            
            # Row 0 of Header Table (2-line wrapping headers with clean header background)
            hdr_bg = "#d9e1e8"
            h_apply = add_cell_text(header_table.commandInputs, 'hdr_apply', '', 2, True, hdr_bg, align="center")
            header_table.addCommandInput(h_apply, 0, 0)
            
            h_op = add_cell_text(header_table.commandInputs, 'hdr_op', '<b>Toolpath Operation</b>', 2, True, hdr_bg)
            header_table.addCommandInput(h_op, 0, 1)
            
            h_tool = add_cell_text(header_table.commandInputs, 'hdr_tool', '<b>Cutter</b>', 2, True, hdr_bg)
            header_table.addCommandInput(h_tool, 0, 2)
            
            h_curr = add_cell_text(header_table.commandInputs, 'hdr_curr', f'<b>Current Stock<br>To Leave ({doc_unit})</b>', 2, True, hdr_bg)
            header_table.addCommandInput(h_curr, 0, 3)
            
            h_rad = add_cell_text(header_table.commandInputs, 'hdr_rad', f'<b>New Radial<br>Stock ({doc_unit})</b>', 2, True, hdr_bg)
            header_table.addCommandInput(h_rad, 0, 4)
            
            h_ax = add_cell_text(header_table.commandInputs, 'hdr_ax', f'<b>New Axial<br>Stock ({doc_unit})</b>', 2, True, hdr_bg)
            header_table.addCommandInput(h_ax, 0, 5)
            
            h_adv = add_cell_text(header_table.commandInputs, 'hdr_adv', '<b>ToolWiz Physics<br>Advisory</b>', 2, True, hdr_bg)
            header_table.addCommandInput(h_adv, 0, 6)
            
            # 2. Scrollable Operations Table
            table = inputs.addTableCommandInput('stockTable', '', 7, col_ratio)
            stock_table_input = table
            table.isFullWidth = True
            table.minimumVisibleRows = 4
            table.maximumVisibleRows = 6
            table.hasGrid = False
            table.columnSpacing = 4
            table.rowSpacing = 3
            table.tablePresentationStyle = adsk.core.TablePresentationStyles.transparentBackgroundTablePresentationStyle
            
            # Rows 0..N-1: Operations
            row_idx = 0
            for op_id, op_info in stock_ops_cache.items():
                calc_r = res_map.get(op_id, {})
                init_rad = clean_and_eval_stock_expr(calc_r.get("recommended_radial_stock", op_info["current_radial"]), doc_unit)
                init_ax = clean_and_eval_stock_expr(calc_r.get("recommended_axial_stock", op_info["current_axial"]), doc_unit)
                init_adv = calc_r.get("advisory", "Ready")
                is_finish_op = calc_r.get("is_finishing", False)
                op_info["is_finishing"] = is_finish_op
                op_info["row_idx"] = row_idx
                
                # Alternating row contrast: White on even rows, Light Gray on odd rows
                bg_color = "#ffffff" if (row_idx % 2 == 0) else "#e8edf2"
                op_info["bg_color"] = bg_color
                
                # Col 0: Checkbox (finishing ops checked by default, roughing unchecked)
                chk = table.commandInputs.addBoolValueInput(f'chk_{op_id}', '', True, '', is_finish_op)
                table.addCommandInput(chk, row_idx, 0)
                
                # Col 1: Op Label (2-line auto-wrapping rich text with row background contrast)
                s_clean = escape_html(op_info.get('setup_name', ''))
                n_clean = escape_html(op_info.get('name', ''))
                op_html = f"{s_clean}<br><b>{n_clean}</b>"
                lbl_op = add_cell_text(table.commandInputs, f'lbl_op_{op_id}', op_html, 2, True, bg_color)
                table.addCommandInput(lbl_op, row_idx, 1)
                
                # Col 2: Tool with Cutter Type (2-line auto-wrapping text with row background contrast)
                tool_html = escape_html(op_info.get("tool_summary", ""))
                lbl_tool = add_cell_text(table.commandInputs, f'lbl_tool_{op_id}', tool_html, 2, True, bg_color)
                table.addCommandInput(lbl_tool, row_idx, 2)
                
                # Col 3: Current Stock To Leave (Comparison column with row background contrast)
                if op_info.get("stock_active", False):
                    curr_rad = op_info["current_radial"]
                    curr_ax = op_info["current_axial"]
                    curr_html = f"Rad: {curr_rad}<br>Ax: {curr_ax}"
                else:
                    curr_html = ""
                lbl_curr = add_cell_text(table.commandInputs, f'lbl_curr_{op_id}', curr_html, 2, True, bg_color)
                table.addCommandInput(lbl_curr, row_idx, 3)
                
                # Col 4: Editable New Radial Stock
                inp_rad = table.commandInputs.addStringValueInput(f'inp_rad_{op_id}', '', str(init_rad))
                table.addCommandInput(inp_rad, row_idx, 4)
                
                # Col 5: Editable New Axial Stock
                inp_ax = table.commandInputs.addStringValueInput(f'inp_ax_{op_id}', '', str(init_ax))
                table.addCommandInput(inp_ax, row_idx, 5)
                
                # Col 6: Multi-line Advisory (Formatted 2-line wrapped text with row background contrast)
                adv_html = str(init_adv).replace('\n', '<br>')
                lbl_adv = add_cell_text(table.commandInputs, f'lbl_adv_{op_id}', adv_html, 2, True, bg_color)
                table.addCommandInput(lbl_adv, row_idx, 6)


                
                # Store direct references in op_info for lightning-fast, 100% reliable UI manipulation
                op_info["chk"] = chk
                op_info["inp_rad"] = inp_rad
                op_info["inp_ax"] = inp_ax
                op_info["lbl_adv"] = lbl_adv
                op_info["cells"] = [chk, lbl_op, lbl_tool, lbl_curr, inp_rad, inp_ax, lbl_adv]
                
                row_idx += 1


                
        except Exception as e:
            if ui:
                ui.messageBox(f"Stock Manager Created Failed:\n{traceback.format_exc()}")

# ==============================================================================
# ADD-IN RUN / STOP
# ==============================================================================

def run(context):
    global app, ui
    app = adsk.core.Application.get()
    ui = app.userInterface
    
    try:
        # 1. Export Digital Twin Command
        exportDef = ui.commandDefinitions.itemById(exportCommandId)
        if not exportDef:
            exportDef = ui.commandDefinitions.addButtonDefinition(
                exportCommandId, 'Export Digital Twin', 'Exports selected Hub / Cloud / Local library to ToolWiz with automated backup.'
            )
        onExportCreated = ToolWizExportCreatedHandler()
        exportDef.commandCreated.add(onExportCreated)
        handlers.append(onExportCreated)
        
        # 2. Import Digital Twin Command
        importDef = ui.commandDefinitions.itemById(importCommandId)
        if not importDef:
            importDef = ui.commandDefinitions.addButtonDefinition(
                importCommandId, 'Import Digital Twin', 'Imports modified Digital Twin library from ToolWiz into Fusion with presets.'
            )
        onImportCreated = ToolWizImportCreatedHandler()
        importDef.commandCreated.add(onImportCreated)
        handlers.append(onImportCreated)
        
        # 3. Speeds & Feeds Fast Calculator Command
        calcDef = ui.commandDefinitions.itemById(calcCommandId)
        if not calcDef:
            calcDef = ui.commandDefinitions.addButtonDefinition(
                calcCommandId, 'ToolWiz Speeds & Feeds', 'Calculates and injects cutting parameters directly into selected CAM operation.'
            )
        onCalcCreated = ToolWizCreatedHandler()
        calcDef.commandCreated.add(onCalcCreated)
        handlers.append(onCalcCreated)
        
        # 4. Stock to Leave & Deflection Manager Command
        stockDef = ui.commandDefinitions.itemById(stockCommandId)
        if not stockDef:
            stockDef = ui.commandDefinitions.addButtonDefinition(
                stockCommandId, 'Stock to Leave Manager', 'Batch inspect and apply Stock to Leave with automatic ToolWiz deflection & springback compensation.'
            )
        onStockCreated = ToolWizStockCreatedHandler()
        stockDef.commandCreated.add(onStockCreated)
        handlers.append(onStockCreated)
        
        workSpace = ui.workspaces.itemById(workspaceToUse)
        if workSpace:
            panel = workSpace.toolbarPanels.itemById(panelToUse)
            if panel:
                if not panel.controls.itemById(exportCommandId): panel.controls.addCommand(exportDef)
                if not panel.controls.itemById(importCommandId): panel.controls.addCommand(importDef)
                if not panel.controls.itemById(calcCommandId): panel.controls.addCommand(calcDef)
                if not panel.controls.itemById(stockCommandId): panel.controls.addCommand(stockDef)
                    
    except Exception as e:
        if ui:
            ui.messageBox(f"Add-in Start Failed:\n{traceback.format_exc()}")

def stop(context):
    global app, ui
    try:
        workSpace = ui.workspaces.itemById(workspaceToUse)
        if workSpace:
            panel = workSpace.toolbarPanels.itemById(panelToUse)
            if panel:
                for cid in [exportCommandId, importCommandId, calcCommandId, stockCommandId]:
                    ctrl = panel.controls.itemById(cid)
                    if ctrl: ctrl.deleteMe()
                    
        for cid in [exportCommandId, importCommandId, calcCommandId, stockCommandId]:
            cmdDef = ui.commandDefinitions.itemById(cid)
            if cmdDef: cmdDef.deleteMe()
            
    except Exception as e:
        if ui:
            ui.messageBox(f"Add-in Stop Failed:\n{traceback.format_exc()}")

