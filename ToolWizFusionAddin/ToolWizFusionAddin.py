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

# Global materials list cache
materials_list = ["Aluminum - Wrought", "Aluminum - Cast", "Steel - Low Carbon", "Steel - Alloy", "Stainless - 300 Series", "Titanium - Alloys", "Brass", "Plastics"]

class ToolWizExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            eventArgs = adsk.core.CommandEventArgs.cast(args)
            inputs = eventArgs.command.commandInputs
            
            # 1. Get User Intent from UI
            family_input = inputs.itemById('matFamily')
            op_input = inputs.itemById('operation')
            agg_input = inputs.itemById('aggressiveness')
            
            family = family_input.selectedItem.name if family_input.selectedItem else "Aluminum - Wrought"
            operation = op_input.selectedItem.name if op_input.selectedItem else "Roughing"
            aggressiveness = agg_input.valueOne
            
            # 2. Get Target Tool
            selections = ui.activeSelections
            target_tool = None
            for i in range(selections.count):
                obj = selections.item(i).entity
                if obj.objectType == adsk.cam.Tool.classType():
                    target_tool = obj
                    break
                    
            if not target_tool:
                ui.messageBox('No tool selected! Please select a tool in the local Tool Library.')
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
            
            # 3. Extract Geometry for Physics Engine
            # Fusion stores geometry in mm internally. We need to parse and convert to inch for our physics engine if it assumes inches.
            # Actually, `tool.toJson()` might return the values as they are in the JSON schema which defaults to mm if unitless, 
            # BUT the schema usually stores explicitly with units OR as base metric (mm).
            # Wait, `tool.toJson()` returns mm or unit-suffixed strings?
            # Fusion CAM tool JSON `geometry.DC` is typically in metric (mm) natively.
            
            def parse_dim_to_inches(val):
                if isinstance(val, (int, float)):
                    return val / 25.4 # Assume base mm
                if isinstance(val, str):
                    if "in" in val: return float(val.replace("in", ""))
                    if "mm" in val: return float(val.replace("mm", "")) / 25.4
                return 0.25 # safe fallback
                
            diameter = parse_dim_to_inches(geo.get("DC", 6.35))
            flutes = int(geo.get("NOF", 4))
            flute_length = parse_dim_to_inches(geo.get("LCF", 25.4))
            shank_diameter = parse_dim_to_inches(geo.get("SF", diameter * 25.4))
            corner_radius = parse_dim_to_inches(geo.get("RE", 0.0))
            
            # Payload for calculation
            payload = {
                "family": family,
                "operation": operation,
                "aggressiveness": aggressiveness,
                "diameter": diameter,
                "flutes": flutes,
                "fluteLength": flute_length,
                "shankDiameter": shank_diameter,
                "cornerRadius": corner_radius,
                # Safe defaults for un-extracted complex geometry
                "stickout": flute_length * 1.5,
                "coating": "Uncoated", # Would parse from JSON if available
                "geometry": "Square" if corner_radius == 0 else "Radiused"
            }
            
            # 4. Call ToolWiz API
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
                
            # 5. Inject Result and Update Tool
            # Shadow copy rollback safety
            temp_dir = tempfile.gettempdir()
            shadow_path = os.path.join(temp_dir, 'toolwiz_pristine_tool.json')
            with open(shadow_path, 'w') as f:
                f.write(raw_json)
                
            # Mutate
            mutated_json = json_mutator.mutate_tool_json(raw_json, calc_result)
            temp_tool = adsk.cam.Tool.createFromJson(mutated_json)
            
            if not temp_tool:
                raise Exception("Failed to reconstitute tool from mutated JSON.")
                
            parent_lib.updateTool(target_tool, temp_tool)
            ui.messageBox(f'Successfully injected cutting data preset:\n{calc_result.get("name")}\n\nRPM: {calc_result.get("rpm")}\nFeed: {calc_result.get("feed")} IPM\nDOC: {calc_result.get("doc")} in\nWOC: {calc_result.get("woc")} in')
            
        except Exception as e:
            if ui:
                ui.messageBox(f'Command Execute Failed:\n{traceback.format_exc()}')

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
            
            onDestroy = ToolWizDestroyHandler()
            cmd.destroy.add(onDestroy)
            handlers.append(onDestroy)
            
            inputs = cmd.commandInputs
            
            # Fetch dynamic materials from server if possible
            global materials_list
            try:
                response = urllib.request.urlopen("http://127.0.0.1:5000/api/data", timeout=1.0)
                data = json.loads(response.read().decode('utf-8'))
                if "families" in data:
                    materials_list = data["families"]
            except:
                pass # Use cached/fallback list
                
            # Build UI
            mat_input = inputs.addDropDownCommandInput('matFamily', 'Material Family', adsk.core.DropDownStyles.TextListDropDownStyle)
            for m in materials_list:
                mat_input.listItems.add(m, True if m == "Aluminum - Wrought" else False)
                
            op_input = inputs.addDropDownCommandInput('operation', 'Strategy', adsk.core.DropDownStyles.TextListDropDownStyle)
            op_input.listItems.add('Roughing', True)
            op_input.listItems.add('Finishing', False)
            op_input.listItems.add('Slotting', False)
            
            agg_input = inputs.addIntegerSliderCommandInput('aggressiveness', 'Aggressiveness', 0, 100)
            agg_input.valueOne = 50
            
            msg = inputs.addTextBoxCommandInput('info', '', 'Select a tool in the local Tool Library, then click OK to fetch and inject optimized cutting data.', 3, True)
            msg.isFullWidth = True
            
        except Exception as e:
            if ui:
                ui.messageBox(f'Command Created Failed:\n{traceback.format_exc()}')

def run(context):
    global app, ui
    app = adsk.core.Application.get()
    ui = app.userInterface
    
    try:
        # Create Command Definition
        cmdDef = ui.commandDefinitions.itemById(commandId)
        if not cmdDef:
            cmdDef = ui.commandDefinitions.addButtonDefinition(commandId, 'ToolWiz Calculator', 'Calculate and inject optimal speeds and feeds.')
            
        onCommandCreated = ToolWizCreatedHandler()
        cmdDef.commandCreated.add(onCommandCreated)
        handlers.append(onCommandCreated)
        
        # Add to UI
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
