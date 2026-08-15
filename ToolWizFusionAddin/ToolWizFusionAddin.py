import adsk.core, adsk.cam, adsk.fusion, traceback
import urllib.request, json
import tempfile, os
from . import json_mutator

app = None
ui = None
handlers = []
commandId = 'ToolWizCalcCmd'
workspaceToUse = 'CAMEnvironment'
panelToUse = 'CAMManagePanel'

# Global caches
families_list = ["Aluminum - Wrought", "Aluminum - Cast", "Steel - Low Carbon"]
alloys_dict = {
    "Aluminum - Wrought": ["6061", "7075"],
    "Aluminum - Cast": ["A356"],
    "Steel - Low Carbon": ["1018"]
}
# Map dropdown string -> adsk.cam.Tool
available_tools_map = {}

class ToolWizExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            eventArgs = adsk.core.CommandEventArgs.cast(args)
            inputs = eventArgs.command.commandInputs
            
            tool_input = inputs.itemById('targetTool')
            family_input = inputs.itemById('matFamily')
            alloy_input = inputs.itemById('matAlloy')
            op_input = inputs.itemById('operation')
            agg_input = inputs.itemById('aggressiveness')
            
            if not family_input or not op_input or not agg_input or not tool_input:
                ui.messageBox('Error: UI elements did not load correctly. Please restart the Add-in.')
                return
                
            family = family_input.selectedItem.name if family_input.selectedItem else "Aluminum - Wrought"
            alloy = alloy_input.selectedItem.name if (alloy_input and alloy_input.selectedItem) else ""
            operation = op_input.selectedItem.name if op_input.selectedItem else "Roughing"
            aggressiveness = agg_input.valueOne
            
            tool_name = tool_input.selectedItem.name if tool_input.selectedItem else ""
            target_tool = available_tools_map.get(tool_name)
            
            if not target_tool:
                ui.messageBox('No tool selected! Please select a tool from the dropdown.')
                return
                
            # Check library safety
            try:
                parent_lib = target_tool.parent
                if parent_lib and hasattr(parent_lib, 'url'):
                    if parent_lib.url.protocol == 'hub':
                        ui.messageBox('SECURITY REJECTION: Cannot safely update tools in a Cloud/Hub library due to sync overwrites. Please copy the tool to your Local Document library first.')
                        return
            except:
                pass
                
            raw_json = target_tool.toJson()
            tool_dict = json.loads(raw_json)
            geo = tool_dict.get("geometry", {})
            
            def parse_dim_to_inches(val):
                if isinstance(val, (int, float)):
                    return val / 25.4
                if isinstance(val, str):
                    if "in" in val: return float(val.replace("in", ""))
                    if "mm" in val: return float(val.replace("mm", "")) / 25.4
                return 0.25
                
            diameter = parse_dim_to_inches(geo.get("DC", 6.35))
            flutes = int(geo.get("NOF", 4))
            flute_length = parse_dim_to_inches(geo.get("LCF", 25.4))
            shank_diameter = parse_dim_to_inches(geo.get("SF", diameter * 25.4))
            corner_radius = parse_dim_to_inches(geo.get("RE", 0.0))
            
            payload = {
                "family": family,
                "alloy": alloy,
                "operation": operation,
                "aggressiveness": aggressiveness,
                "diameter": diameter,
                "flutes": flutes,
                "fluteLength": flute_length,
                "shankDiameter": shank_diameter,
                "cornerRadius": corner_radius,
                "stickout": flute_length * 1.5,
                "coating": "Uncoated",
                "geometry": "Square" if corner_radius == 0 else "Radiused"
            }
            
            req = urllib.request.Request("http://127.0.0.1:5000/api/calculate_for_fusion")
            req.add_header('Content-Type', 'application/json; charset=utf-8')
            jsondata = json.dumps(payload).encode('utf-8')
            
            try:
                response = urllib.request.urlopen(req, jsondata, timeout=5.0)
                res_body = response.read().decode('utf-8')
                calc_result = json.loads(res_body)
                
                if not calc_result.get("success"):
                    ui.messageBox(f"ToolWiz Calculation Error: {calc_result.get('error')}")
                    return
            except Exception as e:
                ui.messageBox(f"Failed to connect to ToolWiz server at http://127.0.0.1:5000.\nError: {str(e)}")
                return
                
            temp_dir = tempfile.gettempdir()
            shadow_path = os.path.join(temp_dir, 'toolwiz_pristine_tool.json')
            with open(shadow_path, 'w') as f:
                f.write(raw_json)
                
            mutated_json = json_mutator.mutate_tool_json(raw_json, calc_result)
            temp_tool = adsk.cam.Tool.createFromJson(mutated_json)
            
            if not temp_tool:
                raise Exception("Failed to reconstitute tool from mutated JSON.")
                
            parent_lib.updateTool(target_tool, temp_tool)
            ui.messageBox(f'Successfully injected cutting data preset:\n{calc_result.get("name")}\n\nRPM: {calc_result.get("rpm")}\nFeed: {calc_result.get("feed")} IPM\nDOC: {calc_result.get("doc")} in\nWOC: {calc_result.get("woc")} in')
            
        except Exception as e:
            if ui:
                ui.messageBox(f'Command Execute Failed:\n{traceback.format_exc()}')

class ToolWizInputChangedHandler(adsk.core.InputChangedEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            eventArgs = adsk.core.InputChangedEventArgs.cast(args)
            inputs = eventArgs.inputs
            cmdInput = eventArgs.input
            
            if cmdInput.id == 'matFamily':
                family = cmdInput.selectedItem.name if cmdInput.selectedItem else ""
                alloy_input = inputs.itemById('matAlloy')
                if alloy_input:
                    alloy_input.listItems.clear()
                    alloys = alloys_dict.get(family, [])
                    if not alloys:
                        alloy_input.listItems.add("Default", True)
                    else:
                        for i, a in enumerate(alloys):
                            alloy_input.listItems.add(a, True if i == 0 else False)
        except Exception as e:
            pass

class ToolWizDestroyHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            pass
        except:
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
            
            # --- 1. POPULATE TOOLS ---
            global available_tools_map
            available_tools_map.clear()
            
            camObj = adsk.cam.CAM.cast(app.activeDocument.products.itemByProductType('CAMProductType'))
            if camObj:
                # Iterate operations to find tools in use
                for setup in camObj.setups:
                    for op in setup.allOperations:
                        if hasattr(op, 'tool') and op.tool:
                            t = op.tool
                            try:
                                t_dict = json.loads(t.toJson())
                                desc = t_dict.get("description", "Unnamed Tool")
                                t_num = t_dict.get("postProcess", {}).get("number", 0)
                                # Keep it short and readable
                                name = f"T{t_num} - {desc}"
                                # If same tool used in multiple ops, it just overwrites map with same tool, which is fine.
                                if name not in available_tools_map:
                                    available_tools_map[name] = t
                            except:
                                pass
            
            tool_input = inputs.addDropDownCommandInput('targetTool', 'Target Tool', adsk.core.DropDownStyles.TextListDropDownStyle)
            if not available_tools_map:
                tool_input.listItems.add("No tools found. Add an operation first.", True)
            else:
                # Pre-select based on active selection if it's an operation
                preselect_name = None
                try:
                    sel = ui.activeSelections
                    if sel.count > 0:
                        ent = sel.item(0).entity
                        if ent.objectType == adsk.cam.Operation.classType():
                            t = ent.tool
                            if t:
                                t_dict = json.loads(t.toJson())
                                t_num = t_dict.get("postProcess", {}).get("number", 0)
                                desc = t_dict.get("description", "Unnamed Tool")
                                preselect_name = f"T{t_num} - {desc}"
                except:
                    pass
                
                for i, t_name in enumerate(available_tools_map.keys()):
                    is_selected = (t_name == preselect_name) if preselect_name else (i == 0)
                    tool_input.listItems.add(t_name, is_selected)
            
            # --- 2. POPULATE MATERIALS ---
            global families_list, alloys_dict
            try:
                response = urllib.request.urlopen("http://127.0.0.1:5000/api/data", timeout=1.0)
                data = json.loads(response.read().decode('utf-8'))
                
                if "families" in data and isinstance(data["families"], list):
                    families_list = data["families"]
                    
                if "alloys" in data and isinstance(data["alloys"], list):
                    new_alloys_dict = {}
                    for a in data["alloys"]:
                        if isinstance(a, dict):
                            f = a.get("family", "")
                            name = f"{a.get('alloy', '')} - {a.get('condition', '')}".strip(" -")
                            if f and name:
                                if f not in new_alloys_dict:
                                    new_alloys_dict[f] = []
                                new_alloys_dict[f].append(name)
                    if new_alloys_dict:
                        alloys_dict = new_alloys_dict
            except:
                pass 
                
            mat_input = inputs.addDropDownCommandInput('matFamily', 'Material Family', adsk.core.DropDownStyles.TextListDropDownStyle)
            for m in families_list:
                mat_input.listItems.add(m, True if m == "Aluminum - Wrought" else False)
                
            alloy_input = inputs.addDropDownCommandInput('matAlloy', 'Specific Alloy', adsk.core.DropDownStyles.TextListDropDownStyle)
            init_alloys = alloys_dict.get("Aluminum - Wrought", ["Default"])
            for i, a in enumerate(init_alloys):
                alloy_input.listItems.add(a, True if i == 0 else False)
                
            op_input = inputs.addDropDownCommandInput('operation', 'Strategy', adsk.core.DropDownStyles.TextListDropDownStyle)
            op_input.listItems.add('Roughing', True)
            op_input.listItems.add('Adaptive Roughing', False)
            op_input.listItems.add('Finishing', False)
            op_input.listItems.add('Slotting', False)
            
            agg_input = inputs.addIntegerSliderCommandInput('aggressiveness', 'Aggressiveness', 0, 100)
            agg_input.valueOne = 50
            
            msg = inputs.addTextBoxCommandInput('info', '', 'Tools are extracted automatically from the operations in your active Document. Select a tool above to update its preset parameters.', 3, True)
            msg.isFullWidth = True
            
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
            cmdDef = ui.commandDefinitions.addButtonDefinition(commandId, 'ToolWiz Calculator', 'Calculate and inject optimal speeds and feeds.')
            
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
