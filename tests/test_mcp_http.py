"""MCP over HTTP (POST /api/mcp), the transport that shares the running server's Fusion bridge queue."""
import unittest

from flask import Flask

import fusion_bridge
import mcp_server


def _client():
    flask_app = Flask(__name__)
    mcp_server.register_http(flask_app)
    return flask_app.test_client()


class McpHttpTest(unittest.TestCase):
    def setUp(self):
        fusion_bridge.reset_bridge_state()
        self.c = _client()

    def test_initialize_and_tools_list(self):
        r = self.c.post("/api/mcp", json={"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}})
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.get_json()["result"]["serverInfo"]["name"], "toolwiz-fusion-mcp")
        r = self.c.post("/api/mcp", json={"jsonrpc": "2.0", "id": 2, "method": "tools/list"})
        names = {t["name"] for t in r.get_json()["result"]["tools"]}
        self.assertIn("fusion_get_setup_summary", names)

    def test_notification_gets_202_with_no_body(self):
        r = self.c.post("/api/mcp", json={"jsonrpc": "2.0", "method": "notifications/initialized"})
        self.assertEqual(r.status_code, 202)
        self.assertEqual(r.data, b"")

    def test_batch_and_parse_error(self):
        r = self.c.post("/api/mcp", json=[{"jsonrpc": "2.0", "id": 1, "method": "ping"},
                                          {"jsonrpc": "2.0", "method": "notifications/initialized"}])
        self.assertEqual(r.get_json(), [{"jsonrpc": "2.0", "id": 1, "result": {}}])
        r = self.c.post("/api/mcp", data="not json", content_type="application/json")
        self.assertEqual(r.status_code, 400)
        self.assertEqual(r.get_json()["error"]["code"], -32700)

    def test_get_is_not_allowed(self):
        self.assertEqual(self.c.get("/api/mcp").status_code, 405)


if __name__ == "__main__":
    unittest.main()
