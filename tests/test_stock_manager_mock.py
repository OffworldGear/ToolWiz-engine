import unittest
import urllib.request
import json

class TestStockManagerMock(unittest.TestCase):
    def test_end_to_end_stock_manager_flow(self):
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
        response = urllib.request.urlopen(req, json.dumps(req_payload).encode('utf-8'), timeout=3.0)
        res_data = json.loads(response.read().decode('utf-8'))

        self.assertTrue(res_data.get("success"))
        results = res_data.get("results")
        self.assertEqual(len(results), 3)

        # op_1: Finishing contour -> negative radial stock
        r1 = results[0]
        self.assertTrue(r1["is_finishing"])
        self.assertTrue(r1["recommended_radial_stock"].startswith("-0.00"))
        self.assertEqual(r1["recommended_axial_stock"], "0.0000 in")

        # op_2: Roughing -> retains positive stock
        r2 = results[1]
        self.assertFalse(r2["is_finishing"])
        self.assertEqual(r2["recommended_radial_stock"], "0.0200 in")
        self.assertEqual(r2["recommended_axial_stock"], "0.0100 in")

        # 2. Test Zero-Out Finishing mode
        req_payload["mode"] = "zero_finishing"
        req = urllib.request.Request("http://127.0.0.1:5000/api/stock_compensation")
        req.add_header('Content-Type', 'application/json; charset=utf-8')
        response = urllib.request.urlopen(req, json.dumps(req_payload).encode('utf-8'), timeout=3.0)
        res_data_zero = json.loads(response.read().decode('utf-8'))
        results_zero = res_data_zero.get("results")

        self.assertEqual(results_zero[0]["recommended_radial_stock"], "0.0000 in")
        self.assertEqual(results_zero[1]["recommended_radial_stock"], "0.0200 in")

if __name__ == '__main__':
    unittest.main()
