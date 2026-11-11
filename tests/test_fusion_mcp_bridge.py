import json
import unittest
from types import SimpleNamespace
from unittest.mock import MagicMock

import ai_machinist
import fusion_bridge
import mcp_server
from app import app
import os, sys; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from test_addin_common import ParamsByName, load_addin, param
from toolwiz_common import CM_TO_IN


def _make_fake_op(name, strategy, tool_dia_in, tool_num, rpm=6000, feed_ipm=40.0,
                  doc_in=0.20, woc_in=0.025, rad_stock_in=0.010, stickout_in=0.80,
                  selected_faces=None):
    tool_json = json.dumps({
        "type": "flat end mill",
        "unit": "inches",
        "geometry": {
            "DC": tool_dia_in,
            "NOF": 4,
            "LCF": tool_dia_in * 2.0,
            "SFDM": max(tool_dia_in, 0.125),
            "LB": stickout_in,
            "RE": 0.0,
        },
        "post-process": {"number": tool_num},
    })
    tool = MagicMock()
    tool.toJson.return_value = tool_json
    tool.presets = []
    params = ParamsByName({
        "tool_spindleSpeed": param(f"{rpm} rpm", rpm),
        "tool_feedCutting": param(f"{feed_ipm} in/min", feed_ipm * 25.4 / 60.0),
        "maximumStepdown": param(f"{doc_in} in", doc_in * 2.54),
        "optimalLoad": param(f"{woc_in} in", woc_in * 2.54),
        "stockToLeave": param(f"{rad_stock_in} in", rad_stock_in * 2.54),
        "useStockToLeave": param("true", True),
        "simpleStockToLeave": param("false", False),
        "verticalStockToLeave": param("0.0000 in", 0.0),
    })
    op = SimpleNamespace(
        name=name,
        strategy=strategy,
        tool=tool,
        toolPreset=None,
        parameters=params,
        hasToolpath=True,
        isToolpathValid=True,
        hasWarning=False,
        hasError=False,
        isSuppressed=False,
        selected_faces=selected_faces or [],
    )
    return op


class _FakeCol:
    def __init__(self, items):
        self._items = list(items)
        self.count = len(self._items)

    def item(self, idx):
        return self._items[idx]

    def __iter__(self):
        return iter(self._items)


class TestFusionMcpBridge(unittest.TestCase):
    def setUp(self):
        fusion_bridge.reset_bridge_state()
        self.client = app.test_client()
        self.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
        self.addin = load_addin()

        # Build a 2-operation setup: 3/8" Adaptive Roughing followed by a 1/32" micro contour
        # with a tight 0.020" internal corner fillet
        pt_cor = SimpleNamespace(x=0.020 / CM_TO_IN, y=0.0, z=-0.10 / CM_TO_IN)
        orig_cor = SimpleNamespace(x=0.0, y=0.0, z=-0.10 / CM_TO_IN)
        fillet_face = SimpleNamespace(
            boundingBox=SimpleNamespace(
                minPoint=SimpleNamespace(x=0, y=0, z=-0.20 / CM_TO_IN),
                maxPoint=SimpleNamespace(x=0.05 / CM_TO_IN, y=0.05 / CM_TO_IN, z=0.0),
            ),
            pointOnFace=pt_cor,
            normal=SimpleNamespace(x=-1.0, y=0.0, z=0.0),
            geometry=SimpleNamespace(
                radius=0.020 / CM_TO_IN,
                origin=orig_cor,
                axis=SimpleNamespace(x=0.0, y=0.0, z=1.0),
            ),
        )
        self.op_rough = _make_fake_op(
            "Adaptive1", "adaptive", tool_dia_in=0.375, tool_num=1,
            rpm=5000, feed_ipm=45.0, doc_in=0.50, woc_in=0.0375, rad_stock_in=0.0002,
        )
        self.op_micro_finish = _make_fake_op(
            "MicroContour", "contour2d", tool_dia_in=0.03125, tool_num=12,
            rpm=16000, feed_ipm=12.0, doc_in=0.030, woc_in=0.003, rad_stock_in=0.0,
            stickout_in=0.50, selected_faces=[fillet_face],
        )
        setup = SimpleNamespace(
            name="Op1 Top",
            allOperations=_FakeCol([self.op_rough, self.op_micro_finish]),
        )
        cam_prod = SimpleNamespace(
            setups=_FakeCol([setup]),
            documentToolLibrary=SimpleNamespace(count=2),
        )
        doc = SimpleNamespace(
            name="TitaniumHousing v4",
            products=SimpleNamespace(itemByProductType=lambda _: cam_prod),
            unitsManager=SimpleNamespace(defaultLengthUnits="in"),
        )
        self.addin.app = SimpleNamespace(activeDocument=doc)
        self.addin.adsk.cam.CAM.cast.side_effect = lambda x: x

    def tearDown(self):
        fusion_bridge.reset_bridge_state()

    def test_addin_dispatch_inspect_and_sequence_audit(self):
        # 1. Inspect the micro-tool operation
        insp = self.addin.dispatch_bridge_action("inspect_operation", {"operation": "MicroContour"})
        self.assertTrue(insp["success"])
        self.assertEqual(insp["setup"], "Op1 Top")
        self.assertAlmostEqual(insp["tool"]["diameter"], 0.03125, places=5)
        self.assertAlmostEqual(insp["feature_geometry"]["min_corner_radius_in"], 0.020, places=4)
        self.assertTrue(insp["feature_geometry"]["corner_overload"])

        # 2. Audit the full setup sequence
        audit_res = self.addin.dispatch_bridge_action("audit_setup_sequence", {"setup": "Op1 Top"})
        self.assertTrue(audit_res["success"])
        self.assertEqual(audit_res["operations_audited"], 2)
        kinds = {i["kind"] for i in audit_res["issues"]}
        # Should catch: (a) 1/32" micro tool following 3/8" rougher (12x step!),
        # (b) rougher left only 0.0002" stock for finisher, and (c) tight internal corner B-Rep spike
        self.assertIn("micro_rest_machining_gap", kinds)
        self.assertIn("insufficient_roughing_stock_for_finish", kinds)
        self.assertIn("brep_geometry", kinds)

    def test_bridge_http_queue_and_direct_executor(self):
        # Enqueue & poll round-trip via Flask endpoints
        req_id = fusion_bridge.enqueue_command("get_toolpath_status", {"operation": "Adaptive1"})
        nxt = self.client.get("/api/fusion_bridge/next").get_json()
        self.assertEqual(nxt["command"]["request_id"], req_id)
        self.assertEqual(nxt["command"]["action"], "get_toolpath_status")

        res_payload = self.addin.dispatch_bridge_action("get_toolpath_status", {"operation": "Adaptive1"})
        post_r = self.client.post("/api/fusion_bridge/result", json={
            "request_id": req_id,
            "result": res_payload,
        }).get_json()
        self.assertTrue(post_r["success"])

        # Register direct executor and call via /api/fusion_bridge/command
        fusion_bridge.register_direct_executor(self.addin.dispatch_bridge_action)
        cmd_resp = self.client.post("/api/fusion_bridge/command", json={
            "action": "apply_stock_to_leave",
            "params": {
                "operation": "MicroContour",
                "radial_stock": "-0.0006 in",
                "axial_stock": "0.0000 in",
            },
        }).get_json()
        self.assertTrue(cmd_resp["success"])
        self.assertEqual(cmd_resp["failed_params"], [])

    def test_mcp_server_jsonrpc_protocol_and_all_tools(self):
        fusion_bridge.register_direct_executor(self.addin.dispatch_bridge_action)

        # 1. initialize
        init_resp = mcp_server.handle_mcp_message({"jsonrpc": "2.0", "id": 1, "method": "initialize"})
        self.assertEqual(init_resp["result"]["serverInfo"]["name"], "toolwiz-fusion-mcp")

        # 2. tools/list
        list_resp = mcp_server.handle_mcp_message({"jsonrpc": "2.0", "id": 2, "method": "tools/list"})
        tool_names = {t["name"] for t in list_resp["result"]["tools"]}
        self.assertIn("toolwiz_calculate_cut", tool_names)
        self.assertIn("fusion_inspect_operation", tool_names)
        self.assertIn("fusion_audit_setup_sequence", tool_names)

        # 3. tools/call -> toolwiz_calculate_cut with B-Rep feature_geometry
        calc_call = mcp_server.handle_mcp_message({
            "jsonrpc": "2.0",
            "id": 3,
            "method": "tools/call",
            "params": {
                "name": "toolwiz_calculate_cut",
                "arguments": {
                    "family": "Titanium Alloy",
                    "alloy": "Ti-6Al-4V (Grade 5, Annealed)",
                    "operation": "3D Adaptive Roughing",
                    "diameter": 0.0625,
                    "flutes": 4,
                    "feature_geometry": {"min_corner_radius_in": 0.035, "feature_depth_in": 0.15},
                },
            },
        })
        self.assertFalse(calc_call["result"]["isError"])
        calc_data = json.loads(calc_call["result"]["content"][0]["text"])
        self.assertTrue(calc_data["success"])
        self.assertIsNotNone(calc_data["corner_feed_ipm"])

        # 4. tools/call -> fusion_audit_setup_sequence
        audit_call = mcp_server.handle_mcp_message({
            "jsonrpc": "2.0",
            "id": 4,
            "method": "tools/call",
            "params": {"name": "fusion_audit_setup_sequence", "arguments": {"setup": "Op1 Top"}},
        })
        self.assertFalse(audit_call["result"]["isError"])
        audit_data = json.loads(audit_call["result"]["content"][0]["text"])
        self.assertEqual(audit_data["operations_audited"], 2)

    def test_ai_machinist_prompt_includes_brep_feature_geometry(self):
        prompt_block = ai_machinist.format_context_for_prompt({
            "material": "Ti-6Al-4V",
            "materialFamily": "Titanium Alloy",
            "diameter": 0.25,
            "operation": "Finishing",
            "feature_geometry": {
                "feature_depth_in": 0.625,
                "min_corner_radius_in": 0.140,
                "min_wall_thickness_in": 0.045,
            },
        })
        self.assertIn("Live Fusion B-Rep Geometry", prompt_block)
        self.assertIn("Feature Depth: 0.625\"", prompt_block)
        self.assertIn("Min Internal Corner Radius: 0.1400\"", prompt_block)
        self.assertIn("Wall Thickness: 0.0450\"", prompt_block)


if __name__ == "__main__":
    unittest.main()
