import json
import socket
from http.server import BaseHTTPRequestHandler, HTTPServer
import threading

FUSION_TCP_PORT = 8001
MCP_HTTP_PORT = 8000

class MCPRequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(content_length)
        
        if self.path == '/push_to_fusion':
            try:
                # Validate JSON payload from ToolWiz
                payload = json.loads(post_data.decode('utf-8'))
                payload['action'] = 'update_tool'
                
                # Send to Fusion Add-in via TCP socket
                response_msg = self.send_to_fusion(payload)
                
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(response_msg.encode('utf-8'))
                
            except ConnectionRefusedError:
                self.send_error(503, "Fusion Add-in is not running or listening on port 8001")
            except Exception as e:
                self.send_error(500, f"Error processing payload: {str(e)}")
                
        elif self.path == '/get_selected_tool':
            try:
                response_msg = self.send_to_fusion({"action": "get_selected_tool"})
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(response_msg.encode('utf-8'))
            except ConnectionRefusedError:
                self.send_error(503, "Fusion Add-in is not running")
            except Exception as e:
                self.send_error(500, f"Error: {str(e)}")
        else:
            self.send_error(404, "Endpoint not found")

    def do_OPTIONS(self):
        # Allow CORS for web app
        self.send_response(200, "ok")
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, OPTIONS')
        self.send_header("Access-Control-Allow-Headers", "X-Requested-With, Content-type")
        self.end_headers()
        
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

    def send_to_fusion(self, payload):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(5.0)
            s.connect(('127.0.0.1', FUSION_TCP_PORT))
            message = json.dumps(payload) + "\n"
            s.sendall(message.encode('utf-8'))
            
            # Wait for Fusion Add-in response
            data = s.recv(4096)
            return data.decode('utf-8').strip()

def start_mcp_server():
    server = HTTPServer(('127.0.0.1', MCP_HTTP_PORT), MCPRequestHandler)
    print(f"ToolWiz MCP Server listening on http://127.0.0.1:{MCP_HTTP_PORT}")
    server.serve_forever()

if __name__ == '__main__':
    start_mcp_server()
