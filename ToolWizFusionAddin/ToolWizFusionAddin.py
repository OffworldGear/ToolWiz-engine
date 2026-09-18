import adsk.core, adsk.cam, adsk.fusion, traceback
import urllib.request, json
import os
from . import json_mutator

app = None
ui = None
handlers = []

exportCommandId = 'ToolWizExportTwinCmd'
importCommandId = 'ToolWizImportTwinCmd'
calcCommandId = 'ToolWizCalcCmd'

workspaceToUse = 'CAMEnvironment'
panelToUse = 'CAMManagePanel'

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

available_ops_map = {}
discovered_libraries_map = {}

def parse_dim_to_inches(val, default=0.25, tool_unit=""):
    """Safely converts Fusion dimension expressions/floats/strings to inches, respecting tool unit context."""
    if val is None: return default
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
                return default
    return default

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
        
        presets = t_dict.get("start-values", {}).get("presets", [])
        preset_names = [p.get("name", "Unnamed Preset") for p in presets if p.get("name")]
        
        geo_payload = {
            "diameter": diameter,
            "flutes": flutes,
            "fluteLength": flute_length,
            "shankDiameter": shank_diameter,
            "cornerRadius": corner_radius,
            "stickout": flute_length * 1.5,
            "coating": "Uncoated",
            "geometry": "Square" if corner_radius == 0 else "Radiused",
            "desc": desc,
            "number": t_num,
            "raw_json": raw_json
        }
        
        dia_mm = diameter * 25.4
        fl_mm = flute_length * 25.4
        summary = f"T{t_num}: {desc} | Dia: {diameter:.3f}\" ({dia_mm:.2f}mm), {flutes} Flutes, Flute L: {flute_length:.3f}\" ({fl_mm:.1f}mm)"
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
            if not lib_select or not lib_select.selectedItem:
                ui.messageBox('Please select a library to export.')
                return
                
            selected_name = lib_select.selectedItem.name
            lib_info = discovered_libraries_map.get(selected_name)
            if not lib_info:
                ui.messageBox('Selected library could not be resolved.')
                return
                
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
                        
            if not tools_json_list:
                ui.messageBox(f"No tools found in '{selected_name}' to export.")
                return
                
            payload = {
                "library_name": selected_name,
                "tools": tools_json_list
            }
            
            # Post to ToolWiz server
            req = urllib.request.Request("http://127.0.0.1:5000/api/twin/export_receive")
            req.add_header('Content-Type', 'application/json; charset=utf-8')
            jsondata = json.dumps(payload).encode('utf-8')
            
            response = urllib.request.urlopen(req, jsondata, timeout=5.0)
            res_data = json.loads(response.read().decode('utf-8'))
            
            if res_data.get("success"):
                backup_name = res_data.get("backup", {}).get("filename", "")
                msg = (
                    f"Digital Twin Exported Successfully!\n"
                    f"====================================\n"
                    f"Library: {selected_name}\n"
                    f"Tools Exported: {len(tools_json_list)}\n"
                    f"Backup Snapshot: {backup_name}\n\n"
                    f"Next Steps:\n"
                    f"1. Open http://127.0.0.1:5000 in your browser.\n"
                    f"2. Switch to the 'Digital Twin Library Manager' tab.\n"
                    f"3. Select tools and batch-generate speeds & feeds for any material!\n"
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
            
            lib_select = inputs.addDropDownCommandInput('libSelect', 'Select Library to Clone', adsk.core.DropDownStyles.TextListDropDownStyle)
            for i, name in enumerate(discovered_libraries_map.keys()):
                lib_select.listItems.add(name, i == 0)
                
            info = inputs.addTextBoxCommandInput('info', '', 'This will export your library to the ToolWiz Digital Twin workspace and create a timestamped backup in your project.', 3, True)
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
        
        workSpace = ui.workspaces.itemById(workspaceToUse)
        if workSpace:
            panel = workSpace.toolbarPanels.itemById(panelToUse)
            if panel:
                if not panel.controls.itemById(exportCommandId): panel.controls.addCommand(exportDef)
                if not panel.controls.itemById(importCommandId): panel.controls.addCommand(importDef)
                if not panel.controls.itemById(calcCommandId): panel.controls.addCommand(calcDef)
                    
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
                for cid in [exportCommandId, importCommandId, calcCommandId]:
                    ctrl = panel.controls.itemById(cid)
                    if ctrl: ctrl.deleteMe()
                    
        for cid in [exportCommandId, importCommandId, calcCommandId]:
            cmdDef = ui.commandDefinitions.itemById(cid)
            if cmdDef: cmdDef.deleteMe()
            
    except Exception as e:
        if ui:
            ui.messageBox(f"Add-in Stop Failed:\n{traceback.format_exc()}")
