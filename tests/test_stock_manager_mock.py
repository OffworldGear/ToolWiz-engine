import unittest
import urllib.request
import json

def _server_running():
    try:
        urllib.request.urlopen("http://127.0.0.1:5000/api/data", timeout=1.0).close()
        return True
    except Exception:
        return False


class TestStockManagerMock(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls._server_up = _server_running()

    def test_end_to_end_stock_manager_flow(self):
        if not self._server_up:
            self.skipTest("ToolWiz server not running on 127.0.0.1:5000")
        self._end_to_end()

    def _end_to_end(self):
        # Simulate an operation list scanned from a Fusion 360 setup:
        # 1 finishing 2D contour, 1 2D adaptive roughing, 1 semi-finish wall
        ops_payload = [
            {
                "id": "op_1",
                "name": "2D Contour - Outer Wall Finish",
                "strategy": "contour2d",
                "diameter": 0.375,
                "flutes": 4,
                "fluteLength": 0.75,
                "shankDiameter": 0.375,
                "stickout": 1.25,
                "rpm": 5200,
                "feedrate": 35.0,
                "doc": 0.50,
                "woc": 0.015,
                "current_radial_stock": "0.0000 in",
                "current_axial_stock": "0.0000 in"
            },
            {
                "id": "op_2",
                "name": "2D Adaptive Clearing",
                "strategy": "adaptive2d",
                "diameter": 0.50,
                "flutes": 3,
                "fluteLength": 1.0,
                "shankDiameter": 0.50,
                "stickout": 1.5,
                "rpm": 4000,
                "feedrate": 60.0,
                "doc": 0.75,
                "woc": 0.060,
                "current_radial_stock": "0.0200 in",
                "current_axial_stock": "0.0100 in"
            },
            {
                "id": "op_3",
                "name": "Semi-Finish Wall Contour",
                "strategy": "contour2d",
                "diameter": 0.375,
                "flutes": 4,
                "fluteLength": 0.75,
                "shankDiameter": 0.375,
                "stickout": 1.25,
                "rpm": 5200,
                "feedrate": 45.0,
                "doc": 0.50,
                "woc": 0.030,
                "current_radial_stock": "0.0050 in",
                "current_axial_stock": "0.0000 in"
            }
        ]

        # 1. Test Titanium Ti-6Al-4V auto-compensation
        req_payload = {
            "family": "Titanium Alloy",
            "alloy": "Ti-6Al-4V (Grade 5)",
            "aggressiveness": 50,
            "mode": "auto_compensate",
            "operations": ops_payload
        }

        req = urllib.request.Request("http://127.0.0.1:5000/api/stock_compensation")
        req.add_header('Content-Type', 'application/json; charset=utf-8')
        req.add_header('X-ToolWiz-Client', 'fusion-addin')
        response = urllib.request.urlopen(req, json.dumps(req_payload).encode('utf-8'), timeout=3.0)
        res_data = json.loads(response.read().decode('utf-8'))

        self.assertTrue(res_data.get("success"))
        results = res_data.get("results")
        self.assertEqual(len(results), 3)

        # op_1: Finishing contour -> negative radial stock and negative axial stock for un-cut floor
        r1 = results[0]
        self.assertTrue(r1["is_finishing"])
        self.assertTrue(r1["recommended_radial_stock"].startswith("-0.00"))
        self.assertTrue(r1["recommended_axial_stock"].startswith("-0.00"))

        # op_2: Roughing -> retains positive stock
        r2 = results[1]
        self.assertFalse(r2["is_finishing"])
        self.assertEqual(r2["recommended_radial_stock"], "0.0200 in")
        self.assertEqual(r2["recommended_axial_stock"], "0.0100 in")

        # 2. Test Zero-Out Finishing mode
        req_payload["mode"] = "zero_finishing"
        req = urllib.request.Request("http://127.0.0.1:5000/api/stock_compensation")
        req.add_header('Content-Type', 'application/json; charset=utf-8')
        req.add_header('X-ToolWiz-Client', 'fusion-addin')
        response = urllib.request.urlopen(req, json.dumps(req_payload).encode('utf-8'), timeout=3.0)
        res_data_zero = json.loads(response.read().decode('utf-8'))
        results_zero = res_data_zero.get("results")

        self.assertEqual(results_zero[0]["recommended_radial_stock"], "0.0000 in")
        self.assertEqual(results_zero[1]["recommended_radial_stock"], "0.0200 in")

    def test_formula_expression_handling(self):
        # Exercises the add-in's real parsers (no server needed).
        from test_addin_common import load_addin
        addin = load_addin()

        class MockVal:
            def __init__(self, v): self.value = v
        class MockParam:
            def __init__(self, expr, val_cm):
                self.expression = expr
                self.value = MockVal(val_cm)

        # 1. Exact string that once crashed Fusion: unparseable formula with no evaluated value -> default
        formula = 'math.min(tool_flutelength * 0.75; tool_diameter * 2.5)'
        self.assertEqual(addin.parse_cam_param_to_inches(MockParam(formula, None), 0.0), 0.0)

        # 2. Standard dimensions in expressions
        self.assertAlmostEqual(addin.parse_cam_param_to_inches(MockParam('0.25 in', None), 0.0), 0.25)
        self.assertAlmostEqual(addin.parse_cam_param_to_inches(MockParam('0.5"', None), 0.0), 0.50)
        self.assertAlmostEqual(addin.parse_cam_param_to_inches(MockParam('12.7 mm', None), 0.0), 0.50)
        self.assertAlmostEqual(addin.parse_cam_param_to_inches(MockParam('3/8 in', None), 0.0), 0.375)

        # 3. Evaluated value in cm (Fusion database unit) wins: 1.27 cm -> 0.5 in
        self.assertAlmostEqual(addin.parse_cam_param_to_inches(MockParam(formula, 1.27)), 0.50)

if __name__ == '__main__':
    unittest.main()

