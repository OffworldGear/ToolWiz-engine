import unittest
import json
import os
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from app import app

class TestStockCompensationAPI(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()

    def test_finishing_contour_titanium(self):
        payload = {
            "family": "Titanium Alloy",
            "alloy": "Ti-6Al-4V (Grade 5)",
            "aggressiveness": 50,
            "mode": "auto_compensate",
            "operations": [
                {
                    "id": "op1",
                    "name": "2D Contour - Finish Wall",
                    "strategy": "contour2d",
                    "unit": "inches",
                    "diameter": 0.375,
                    "flutes": 4,
                    "fluteLength": 0.75,
                    "shankDiameter": 0.375,
                    "stickout": 1.25,
                    "rpm": 4500,
                    "feedrate": 35.0,
                    "doc": 0.50,
                    "woc": 0.015,
                    "current_radial_stock": "0.0000 in",
                    "current_axial_stock": "0.0000 in"
                }
            ]
        }
        resp = self.client.post("/api/stock_compensation", json=payload)
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertTrue(data.get("success"))
        results = data.get("results", [])
        self.assertEqual(len(results), 1)
        r0 = results[0]
        self.assertTrue(r0["is_finishing"])
        # In Titanium, deflection + springback should be > 0.0008 in
        self.assertGreater(r0["total_error_in"], 0.0008)
        self.assertTrue(r0["recommended_radial_stock"].startswith("-0.00"))
        self.assertEqual(r0["recommended_axial_stock"], "0.0000 in")

    def test_roughing_preserves_positive_stock(self):
        payload = {
            "family": "Aluminum - Wrought (6061)",
            "alloy": "6061 - T6",
            "aggressiveness": 50,
            "mode": "auto_compensate",
            "operations": [
                {
                    "id": "op_rough",
                    "name": "2D Adaptive Roughing",
                    "strategy": "adaptive2d",
                    "unit": "inches",
                    "diameter": 0.50,
                    "flutes": 3,
                    "fluteLength": 1.0,
                    "shankDiameter": 0.50,
                    "stickout": 1.5,
                    "current_radial_stock": "0.0200 in",
                    "current_axial_stock": "0.0100 in"
                }
            ]
        }
        resp = self.client.post("/api/stock_compensation", json=payload)
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        r = data["results"][0]
        self.assertFalse(r["is_finishing"])
        # Roughing should retain positive stock, NOT negative!
        self.assertEqual(r["recommended_radial_stock"], "0.0200 in")
        self.assertEqual(r["recommended_axial_stock"], "0.0100 in")

    def test_metric_conversion(self):
        payload = {
            "family": "Stainless - 300 Series (316)",
            "alloy": "Nitronic 60 (Annealed)",
            "mode": "auto_compensate",
            "operations": [
                {
                    "id": "op_metric",
                    "name": "Wall Finish Contour",
                    "strategy": "contour2d",
                    "unit": "mm",
                    "diameter": 0.375,  # tool info in inches internally
                    "flutes": 4,
                    "fluteLength": 0.75,
                    "shankDiameter": 0.375,
                    "stickout": 1.25,
                    "rpm": 5000,
                    "feedrate": 35.0,
                    "doc": 0.50,
                    "woc": 0.015,
                    "current_radial_stock": "0.000 mm",
                    "current_axial_stock": "0.000 mm"
                }
            ]
        }
        resp = self.client.post("/api/stock_compensation", json=payload)
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        r = data["results"][0]
        self.assertTrue("mm" in r["recommended_radial_stock"])
        self.assertTrue(r["recommended_radial_stock"].startswith("-0."))

    def test_zero_finishing_mode(self):
        payload = {
            "family": "Steel - Tool (H13)",
            "alloy": "CPM MagnaCut (Hardened ~62 HRC)",
            "mode": "zero_finishing",
            "operations": [
                {
                    "id": "op_fin",
                    "name": "2D Contour Wall Finish",
                    "strategy": "contour2d",
                    "unit": "inches",
                    "diameter": 0.375,
                    "flutes": 4
                },
                {
                    "id": "op_rough",
                    "name": "2D Adaptive Clearing",
                    "strategy": "adaptive2d",
                    "unit": "inches",
                    "diameter": 0.375,
                    "flutes": 4,
                    "current_radial_stock": "0.0250 in",
                    "current_axial_stock": "0.0150 in"
                }
            ]
        }
        resp = self.client.post("/api/stock_compensation", json=payload)
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        r_fin = data["results"][0]
        r_rough = data["results"][1]
        self.assertEqual(r_fin["recommended_radial_stock"], "0.0000 in")
        self.assertEqual(r_fin["recommended_axial_stock"], "0.0000 in")
        self.assertEqual(r_rough["recommended_radial_stock"], "0.0250 in")

    def test_aggressiveness_slider_scales_offsets(self):
        def query_agg(agg_val):
            payload = {
                "family": "Titanium Alloy",
                "alloy": "Ti-6Al-4V (Grade 5)",
                "aggressiveness": agg_val,
                "mode": "auto_compensate",
                "operations": [
                    {
                        "id": "op_fin",
                        "name": "Wall Finishing Contour",
                        "strategy": "contour2d",
                        "unit": "inches",
                        "diameter": 0.25,
                        "flutes": 4,
                        "fluteLength": 0.75,
                        "stickout": 1.25,
                        "rpm": 5000,
                        "feedrate": 20.0,
                        "doc": 0.25,
                        "woc": 0.015,
                        "current_radial_stock": "0.0000 in",
                        "current_axial_stock": "0.0000 in"
                    }
                ]
            }
            resp = self.client.post("/api/stock_compensation", json=payload)
            self.assertEqual(resp.status_code, 200)
            return resp.get_json()["results"][0]

        r_low = query_agg(10)
        r_mid = query_agg(50)
        r_high = query_agg(90)

        # Higher aggressiveness should produce larger total wall error / more negative compensation
        self.assertLess(r_low["total_error_in"], r_mid["total_error_in"])
        self.assertLess(r_mid["total_error_in"], r_high["total_error_in"])
        self.assertNotEqual(r_low["recommended_radial_stock"], r_high["recommended_radial_stock"])

if __name__ == '__main__':
    unittest.main()
