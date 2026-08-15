import adsk.core
import adsk.cam
import traceback
import threading
import json
import queue
import socket
import os
import tempfile
from . import json_mutator

# Globals
app = None
ui = None
handlers = []
task_queue = queue.Queue()
custom_event_id = 'ToolWizDataEvent'
stop_flag = threading.Event()
response_event = threading.Event()
shared_response = {}

class ToolWizCustomEventHandler(adsk.core.CustomEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            while not task_queue.empty():
                payload = task_queue.get()
                process_tool_update(payload)
        except Exception as e:
            if ui:
                ui.messageBox(f'Error processing ToolWiz payload:\n{traceback.format_exc()}')

def process_tool_update(payload):
    global app, ui
    cam = adsk.cam.CAM.cast(app.activeProduct)
    if not cam:
        ui.messageBox('Please switch to the Manufacture workspace before importing ToolWiz data.')
        return

    # Identify target tool from selection
    selections = ui.activeSelections
    target_tool = None
    for i in range(selections.count):
        obj = selections.item(i).entity
        if obj.objectType == adsk.cam.Tool.classType():
            target_tool = obj
            break
            
    if not target_tool:
        shared_response['error'] = 'No tool selected! Please select a tool in the local Tool Library.'
        response_event.set()
        return
        
    action = payload.get("action")
    if action == "get_selected_tool":
        shared_response['tool_name'] = target_tool.description
        response_event.set()
        return

    # Check library safety (prevent cloud overwrites)
    try:
        parent_lib = target_tool.parent
        if parent_lib and hasattr(parent_lib, 'url'):
            if parent_lib.url.protocol == 'hub':
                shared_response['error'] = 'SECURITY REJECTION: Cannot safely update tools in a Cloud/Hub library.'
                response_event.set()
                return
    except:
        pass

    try:
        raw_json = target_tool.toJson()
        temp_dir = tempfile.gettempdir()
        shadow_path = os.path.join(temp_dir, 'toolwiz_pristine_tool.json')
        with open(shadow_path, 'w') as f:
            f.write(raw_json)
            
        mutated_json = json_mutator.mutate_tool_json(raw_json, payload)
        temp_tool = adsk.cam.Tool.createFromJson(mutated_json)
        
        if not temp_tool:
            raise Exception("Failed to reconstitute tool from mutated JSON.")
            
        parent_lib.updateTool(target_tool, temp_tool)
        shared_response['success'] = f"Successfully injected preset into {target_tool.description}"
        response_event.set()
        
    except Exception as e:
        shared_response['error'] = f"Data Corruption Safety Rollback Triggered: {str(e)}"
        response_event.set()


def tcp_server_thread():
    HOST = '127.0.0.1'
    PORT = 8001
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            s.bind((HOST, PORT))
            s.listen()
            s.settimeout(1.0) # Allows checking stop_flag
            while not stop_flag.is_set():
                try:
                    conn, addr = s.accept()
                    with conn:
                        data = conn.recv(8192)
                        if data:
                            payload = json.loads(data.decode('utf-8'))
                            
                            # Clear event and shared response
                            response_event.clear()
                            shared_response.clear()
                            
                            task_queue.put(payload)
                            app.fireCustomEvent(custom_event_id, '')
                            
                            # Wait up to 5 seconds for the main thread to process it
                            response_event.wait(timeout=5.0)
                            
                            conn.sendall(json.dumps(shared_response).encode('utf-8'))
                except socket.timeout:
                    continue
                except Exception as e:
                    print(f"TCP error: {e}")
        except Exception as e:
            if ui:
                ui.messageBox(f'ToolWiz TCP Bind Error: {e}')

def run(context):
    global app, ui, handlers, custom_event_id, stop_flag
    app = adsk.core.Application.get()
    ui = app.userInterface
    
    try:
        # Register custom event
        custom_event = app.registerCustomEvent(custom_event_id)
        if not custom_event:
            ui.messageBox('Failed to register ToolWiz custom event.')
            return
            
        on_custom_event = ToolWizCustomEventHandler()
        custom_event.add(on_custom_event)
        handlers.append(on_custom_event)
        
        # Start TCP listener thread
        stop_flag.clear()
        t = threading.Thread(target=tcp_server_thread)
        t.daemon = True
        t.start()
        
    except:
        if ui:
            ui.messageBox(f'ToolWiz Addin Init Failed:\n{traceback.format_exc()}')

def stop(context):
    global app, ui, custom_event_id, stop_flag
    try:
        stop_flag.set()
        app.unregisterCustomEvent(custom_event_id)
    except:
        if ui:
            ui.messageBox(f'ToolWiz Addin Stop Failed:\n{traceback.format_exc()}')
