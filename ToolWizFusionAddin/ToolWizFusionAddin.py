import adsk.core, adsk.cam, adsk.fusion, traceback
import urllib.request, json
import os

app = None
ui = None
handlers = []
commandId = 'ToolWizCalcCmd'
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

# Maps dropdown display name -> adsk.cam.Operation
available_ops_map = {}

def parse_dim_to_inches(val, default=0.25, tool_unit=""):
    """Safely converts Fusion dimension expressions/floats/strings to inches, respecting tool unit context."""
    if val is None:
        return default
    if isinstance(val, (int, float)):
        u = str(tool_unit).strip().lower()
        if u in ["inches", "in", "inch"]:
            return float(val)
        elif u in ["millimeters", "mm", "millimeter"]:
            return float(val) / 25.4
        else:
            # Heuristic fallback if unit is unspecified:
            # Standard cutting tools > 1.5 are almost certainly metric mm (3mm, 6mm, 10mm, etc.)
            # Values <= 1.5 are standard inch sizes (0.125", 0.250", 0.500", etc.)
            if float(val) > 1.5:
                return float(val) / 25.4
            return float(val)
            
    if isinstance(val, str):
        val_clean = val.strip().lower()
        if "in" in val_clean:
            val_clean = val_clean.replace("in", "").strip()
            if "/" in val_clean:
                num, den = val_clean.split("/")
                return float(num) / float(den)
            return float(val_clean)
        elif "mm" in val_clean:
            val_clean = val_clean.replace("mm", "").strip()
            return float(val_clean) / 25.4
        else:
            try:
                if "/" in val_clean:
                    num, den = val_clean.split("/")
                    return float(num) / float(den)
                f = float(val_clean)
                u = str(tool_unit).strip().lower()
                if u in ["inches", "in", "inch"]:
                    return f
                elif u in ["millimeters", "mm", "millimeter"]:
                    return f / 25.4
                else:
                    if f > 1.5:
                        return f / 25.4
                    return f
            except:
                return default
    return default

def get_op_tool_info(op):
    """Extracts tool metadata and geometry formatted in inches with dual unit display"""
    if not op or not hasattr(op, 'tool') or not op.tool:
        return None, "No Tool Found"
    
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
            "number": t_num
        }
        
        dia_mm = diameter * 25.4
        fl_mm = flute_length * 25.4
        summary = f"T{t_num}: {desc} | Dia: {diameter:.3f}\" ({dia_mm:.2f}mm), {flutes} Flutes, Flute L: {flute_length:.3f}\" ({fl_mm:.1f}mm)"
        return geo_payload, summary
    except Exception as e:
        return None, f"Error extracting tool: {str(e)}"

def apply_param(op, name, expr_str):
    """Safely updates a single CAMParameter on an Operation"""
    try:
        p = op.parameters.itemByName(name)
        if p and p.isEnabled:
            p.expression = str(expr_str)
            return True
    except:
        pass
    return False

class ToolWizExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            eventArgs = adsk.core.CommandEventArgs.cast(args)
            inputs = eventArgs.command.commandInputs
            
            op_input = inputs.itemById('targetOp')
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
                ui.messageBox('No valid CAM operation selected! Please choose an operation from the list.')
                return
                
            family = family_input.selectedItem.name if family_input.selectedItem else "Aluminum - Wrought (6061)"
            alloy = alloy_input.selectedItem.name if (alloy_input and alloy_input.selectedItem) else ""
            strategy = strat_input.selectedItem.name if strat_input.selectedItem else "Adaptive Roughing"
            aggressiveness = agg_input.valueOne
            
            geo_payload, summary_str = get_op_tool_info(target_op)
            if not geo_payload:
                ui.messageBox(f'Could not read tool geometry: {summary_str}')
                return
                
            # Prepare API request payload
            payload = {
                "family": family,
                "alloy": alloy,
                "operation": strategy,
                "aggressiveness": aggressiveness,
                "diameter": geo_payload["diameter"],
                "flutes": geo_payload["flutes"],
                "fluteLength": geo_payload["fluteLength"],
                "shankDiameter": geo_payload["shankDiameter"],
                "cornerRadius": geo_payload["cornerRadius"],
                "stickout": geo_payload["stickout"],
                "coating": geo_payload["coating"],
                "geometry": geo_payload["geometry"]
            }
            
            # Send to ToolWiz server
            req = urllib.request.Request("http://127.0.0.1:5000/api/calculate_for_fusion")
            req.add_header('Content-Type', 'application/json; charset=utf-8')
            jsondata = json.dumps(payload).encode('utf-8')
            
            try:
                response = urllib.request.urlopen(req, jsondata, timeout=5.0)
                calc_result = json.loads(response.read().decode('utf-8'))
                
                if not calc_result.get("success"):
                    ui.messageBox(f"ToolWiz Calculation Error: {calc_result.get('error')}")
                    return
            except Exception as e:
                ui.messageBox(f"Failed to connect to ToolWiz server at http://127.0.0.1:5000.\nPlease verify app.py is running.\n\nError: {str(e)}")
                return
                
            # Extract calculated values
            rpm = calc_result.get("rpm", 5000)
            feed = calc_result.get("feed", 30.0)
            doc = calc_result.get("doc", 0.25)
            woc = calc_result.get("woc", 0.05)
            ramp_feed = calc_result.get("ramp_feed", feed * 0.5)
            plunge_feed = calc_result.get("plunge_feed", feed * 0.25)
            sfm = calc_result.get("sfm", 300)
            ipt = calc_result.get("ipt", 0.002)
            
            # Direct Operation Parameter Injection
            applied = []
            
            # Speeds & Feedrates
            if apply_param(target_op, 'tool_spindleSpeed', f"{rpm} rpm"):
                applied.append(f"Spindle Speed: {rpm:,} RPM ({sfm:.1f} SFM)")
            apply_param(target_op, 'tool_spindleSpeedRamp', f"{rpm} rpm")
            
            if apply_param(target_op, 'tool_feedCutting', f"{feed:.2f} in/min"):
                applied.append(f"Cutting Feed: {feed:.2f} in/min ({ipt:.4f} IPT)")
            apply_param(target_op, 'tool_feedEntry', f"{feed:.2f} in/min")
            apply_param(target_op, 'tool_feedExit', f"{feed:.2f} in/min")
            apply_param(target_op, 'tool_feedRamp', f"{ramp_feed:.2f} in/min")
            apply_param(target_op, 'tool_feedPlunge', f"{plunge_feed:.2f} in/min")
            apply_param(target_op, 'tool_feedTransition', f"{feed * 1.5:.2f} in/min")
            
            # Depths of Cut & Stepover (DOC & WOC)
            if "Adaptive" in strategy:
                if apply_param(target_op, 'optimalLoad', f"{woc:.4f} in"):
                    applied.append(f"Optimal Load (WOC): {woc:.4f} in")
            else:
                if apply_param(target_op, 'stepover', f"{woc:.4f} in") or apply_param(target_op, 'maximumStepover', f"{woc:.4f} in"):
                    applied.append(f"Stepover (WOC): {woc:.4f} in")
                    
            if apply_param(target_op, 'maximumStepdown', f"{doc:.4f} in"):
                applied.append(f"Max Stepdown (DOC): {doc:.4f} in")
                
            # Confirmation Display
            applied_summary = "\n".join([f" • {item}" for item in applied])
            msg = (
                f"ToolWiz Parameters Applied Successfully!\n"
                f"====================================\n"
                f"Operation: {op_name}\n"
                f"Material: {family} ({alloy})\n"
                f"Strategy: {strategy}\n\n"
                f"Applied Parameters:\n"
                f"{applied_summary}\n\n"
                f"Ramp Feed: {ramp_feed:.2f} in/min | Plunge Feed: {plunge_feed:.2f} in/min"
            )
            ui.messageBox(msg, 'ToolWiz CAM Auto-Setter')
            
        except Exception as e:
            if ui:
                ui.messageBox(f'Operation Auto-Setter Failed:\n{traceback.format_exc()}')

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
                if tool_info_box and target_op:
                    _, summary_str = get_op_tool_info(target_op)
                    tool_info_box.text = summary_str
                    
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

class ToolWizDestroyHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
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
            
            onDestroy = ToolWizDestroyHandler()
            cmd.destroy.add(onDestroy)
            handlers.append(onDestroy)
            
            inputs = cmd.commandInputs
            
            # --- 1. SCAN AND POPULATE OPERATIONS ---
            global available_ops_map
            available_ops_map.clear()
            
            camObj = adsk.cam.CAM.cast(app.activeDocument.products.itemByProductType('CAMProductType'))
            if not camObj:
                ui.messageBox('Please switch to the Manufacture (CAM) workspace with an active setup.')
                return
                
            preselect_op_name = None
            
            # Check active UI selection first
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
                
            # Collect all operations from all setups
            for setup in camObj.setups:
                for op in setup.allOperations:
                    if hasattr(op, 'tool') and op.tool:
                        op_label = f"{setup.name} > {op.name}"
                        available_ops_map[op_label] = op
                        if not preselect_op_name:
                            preselect_op_name = op_label
                            
            if not available_ops_map:
                ui.messageBox('No operations with tools found in active document. Please create an operation first.')
                return
                
            op_input = inputs.addDropDownCommandInput('targetOp', 'Target Operation', adsk.core.DropDownStyles.TextListDropDownStyle)
            for op_label in available_ops_map.keys():
                op_input.listItems.add(op_label, op_label == preselect_op_name)
                
            # Initial Tool Info Display
            initial_op = available_ops_map.get(preselect_op_name)
            _, initial_summary = get_op_tool_info(initial_op)
            tool_info_box = inputs.addTextBoxCommandInput('toolInfo', 'Detected Tool', initial_summary, 2, True)
            tool_info_box.isFullWidth = True
            
            # --- 2. FETCH DYNAMIC MATERIAL DATABASE ---
            global families_list, alloys_dict
            try:
                response = urllib.request.urlopen("http://127.0.0.1:5000/api/data", timeout=1.5)
                data = json.loads(response.read().decode('utf-8'))
                
                if "families" in data and isinstance(data["families"], list) and len(data["families"]) > 0:
                    families_list = data["families"]
                    
                if "alloys" in data and isinstance(data["alloys"], list):
                    new_alloys_dict = {}
                    for a in data["alloys"]:
                        if isinstance(a, dict):
                            f = a.get("family", "")
                            alloy_name = a.get("alloy", "")
                            condition = a.get("condition", "")
                            name = f"{alloy_name} ({condition})" if condition else alloy_name
                            if f and name:
                                if f not in new_alloys_dict:
                                    new_alloys_dict[f] = []
                                if name not in new_alloys_dict[f]:
                                    new_alloys_dict[f].append(name)
                    if new_alloys_dict:
                        alloys_dict = new_alloys_dict
            except:
                pass # Use robust built-in fallbacks
                
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
                ui.messageBox(f'Command Created Failed:\n{traceback.format_exc()}')

def run(context):
    global app, ui
    app = adsk.core.Application.get()
    ui = app.userInterface
    
    try:
        cmdDef = ui.commandDefinitions.itemById(commandId)
        if not cmdDef:
            cmdDef = ui.commandDefinitions.addButtonDefinition(
                commandId, 
                'ToolWiz Speeds & Feeds', 
                'Calculates and applies optimal speeds, feeds, stepover, and stepdown directly to the selected CAM operation.'
            )
            
        onCommandCreated = ToolWizCreatedHandler()
        cmdDef.commandCreated.add(onCommandCreated)
        handlers.append(onCommandCreated)
        
        workSpace = ui.workspaces.itemById(workspaceToUse)
        if workSpace:
            toolbarPanels = workSpace.toolbarPanels
            panel = toolbarPanels.itemById(panelToUse)
            if panel:
                buttonControl = panel.controls.itemById(commandId)
                if not buttonControl:
                    panel.controls.addCommand(cmdDef)
                    
    except Exception as e:
        if ui:
            ui.messageBox(f'Add-in Start Failed:\n{traceback.format_exc()}')

def stop(context):
    global app, ui
    try:
        workSpace = ui.workspaces.itemById(workspaceToUse)
        if workSpace:
            panel = workSpace.toolbarPanels.itemById(panelToUse)
            if panel:
                buttonControl = panel.controls.itemById(commandId)
                if buttonControl:
                    buttonControl.deleteMe()
                    
        cmdDef = ui.commandDefinitions.itemById(commandId)
        if cmdDef:
            cmdDef.deleteMe()
            
    except Exception as e:
        if ui:
            ui.messageBox(f'Add-in Stop Failed:\n{traceback.format_exc()}')
