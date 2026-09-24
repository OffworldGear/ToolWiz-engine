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
        self.assertTrue(r0["recommended_axial_stock"].startswith("-0.00"))
        self.assertIn("Wall Rad", r0["advisory"])
        self.assertIn("Keep Ax: 0", r0["advisory"])

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

    def test_evaluates_formula_expressions(self):
        from app import clean_and_eval_stock_expr
        # Direct evaluation tests
        self.assertEqual(clean_and_eval_stock_expr("(-.1) * 1mm", "mm"), "-0.100 mm")
        self.assertEqual(clean_and_eval_stock_expr("(.1)*1mm", "mm"), "0.100 mm")
        self.assertEqual(clean_and_eval_stock_expr("(-0.1) * 1 mm", "mm"), "-0.100 mm")
        self.assertEqual(clean_and_eval_stock_expr("0mm", "mm"), "0.000 mm")
        self.assertEqual(clean_and_eval_stock_expr("0.0 mm", "mm"), "0.000 mm")
        self.assertEqual(clean_and_eval_stock_expr("(-.002) * 1 in", "in"), "-0.0020 in")
        self.assertEqual(clean_and_eval_stock_expr("0.0000 in", "in"), "0.0000 in")

        # API integration test with raw formula expressions on roughing pass
        payload = {
            "family": "Titanium Alloy",
            "alloy": "Ti-6Al-4V (Grade 5)",
            "mode": "auto_compensate",
            "operations": [
                {
                    "id": "op_adaptive",
                    "name": "2D Adaptive Roughing",
                    "strategy": "adaptive2d",
                    "unit": "mm",
                    "diameter": 0.125,
                    "flutes": 4,
                    "current_radial_stock": "0mm",
                    "current_axial_stock": "(-.1) * 1mm"
                }
            ]
        }
        resp = self.client.post("/api/stock_compensation", json=payload)
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        r = data["results"][0]
        self.assertEqual(r["recommended_radial_stock"], "0.000 mm")
        self.assertEqual(r["recommended_axial_stock"], "-0.100 mm")
        self.assertNotIn("(", r["recommended_axial_stock"])
        self.assertNotIn("*", r["recommended_axial_stock"])

    def test_floor_finishing_operations(self):
        """Verify Flat, Horizontal, and Facing operations output floor axial springback and dual advice."""
        payload = {
            "family": "Titanium Alloy",
            "alloy": "Ti-6Al-4V (Grade 5)",
            "aggressiveness": 50,
            "mode": "auto_compensate",
            "operations": [
                {
                    "id": "op_flat",
                    "name": "Flat Finishing (Pocket Floor)",
                    "strategy": "flat",
                    "unit": "inches",
                    "diameter": 0.375,
                    "flutes": 4,
                    "fluteLength": 0.75,
                    "current_radial_stock": "0.0000 in",
                    "current_axial_stock": "0.0000 in"
                },
                {
                    "id": "op_facing",
                    "name": "Facing Top Surface",
                    "strategy": "face",
                    "unit": "mm",
                    "diameter": 0.50,
                    "flutes": 4,
                    "current_radial_stock": "0.000 mm",
                    "current_axial_stock": "0.000 mm"
                }
            ]
        }
        resp = self.client.post("/api/stock_compensation", json=payload)
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertTrue(data.get("success"))
        results = data.get("results", [])
        self.assertEqual(len(results), 2)
        
        # Op 1: Flat (Inches)
        r_flat = results[0]
        self.assertTrue(r_flat["is_finishing"])
        self.assertTrue(r_flat["is_floor_finish"])
        self.assertTrue(r_flat["recommended_axial_stock"].startswith("-0.00"))
        self.assertTrue(r_flat["recommended_radial_stock"].startswith("-0.00"))
        self.assertIn("Floor Ax", r_flat["advisory"])
        self.assertIn("Comb Rad", r_flat["advisory"])
        self.assertIn("Tip: Use Rad +0.005\"", r_flat["advisory"])

        # Op 2: Facing (Metric)
        r_face = results[1]
        self.assertTrue(r_face["is_finishing"])
        self.assertTrue(r_face["is_floor_finish"])
        self.assertTrue(r_face["recommended_axial_stock"].startswith("-0."))
        self.assertTrue("mm" in r_face["recommended_axial_stock"])
        self.assertIn("Floor Ax", r_face["advisory"])
        self.assertIn("Comb Rad", r_face["advisory"])
        self.assertIn("Tip: Use Rad +0.150mm", r_face["advisory"])

    def test_calculate_floor_vs_wall_finishing(self):
        """Verify /api/calculate returns radial_comp, axial_comp, is_floor_finish, and tailored tips."""
        # 1. Floor Finishing
        payload_floor = {
            "family": "Titanium Alloy",
            "alloy": "Ti-6Al-4V (Grade 5)",
            "tool": "Carbide Endmill",
            "diameter": 0.50,
            "flutes": 4,
            "cutDepth": 0.005,
            "cutWidth": 0.35,
            "operation": "Floor Finishing (Skim)"
        }
        resp = self.client.post("/api/calculate", json=payload_floor)
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertTrue(data["success"])
        self.assertTrue(data["is_floor_finish"])
        self.assertTrue(data["is_finishing"])
        self.assertIn("radial_comp", data)
        self.assertIn("axial_comp", data)
        self.assertLess(data["axial_comp"], 0)
        
        # Check tips for yellow warning on positive radial stock & axial floor springback
        tip_titles = [t["title"] for t in data["tips"]]
        self.assertIn("Floor Finishing (Axial Springback & Z-Compensation)", tip_titles)
        self.assertIn("Radial Stock Strategy for Floors (Floor-Only vs Combined)", tip_titles)
        rad_tip = next(t for t in data["tips"] if t["title"] == "Radial Stock Strategy for Floors (Floor-Only vs Combined)")
        self.assertEqual(rad_tip["type"], "warning")
        self.assertIn("+0.0050\"", rad_tip["message"])
        self.assertIn("Combined Floor + Wall", rad_tip["message"])

        # 2. Wall Finishing
        payload_wall = {
            "family": "Titanium Alloy",
            "alloy": "Ti-6Al-4V (Grade 5)",
            "tool": "Carbide Endmill",
            "diameter": 0.50,
            "flutes": 4,
            "cutDepth": 0.75,
            "cutWidth": 0.015,
            "operation": "Wall Finishing (Deep DOC)"
        }
        resp_wall = self.client.post("/api/calculate", json=payload_wall)
        self.assertEqual(resp_wall.status_code, 200)
        data_wall = resp_wall.get_json()
        self.assertTrue(data_wall["success"])
        self.assertFalse(data_wall["is_floor_finish"])
        self.assertTrue(data_wall["is_finishing"])
        self.assertLess(data_wall["radial_comp"], 0)
        self.assertLess(data_wall["axial_comp"], 0)
        
        wall_tip_titles = [t["title"] for t in data_wall["tips"]]
        self.assertIn("Tool Wear Compensation (Wall Deflection & Axial Springback)", wall_tip_titles)
        wall_tip = next(t for t in data_wall["tips"] if "Wear Compensation" in t["title"])
        self.assertIn("Wall (Radial)", wall_tip["message"])
        self.assertIn("Floor (Axial)", wall_tip["message"])
        self.assertIn("keep Axial Stock at 0.0000\"", wall_tip["message"])

    def test_ball_mill_3d_contouring_effective_diameter(self):
        # 1/4" Ball mill doing shallow 3D contour pass (DOC = 0.005")
        payload = {
            "family": "Titanium Alloy",
            "alloy": "Ti-6Al-4V (Grade 5)",
            "tool": "Carbide Endmill",
            "geometry": "Ball",
            "diameter": 0.25,
            "flutes": 4,
            "cutDepth": 0.005,
            "cutWidth": 0.015,
            "operation": "3D Contouring / Scallop Finishing",
            "aggressiveness": 50,
            "maxRpm": 16000
        }
        resp = self.client.post("/api/calculate", json=payload)
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertTrue(data["success"])
        
        # Effective diameter for 0.25" ball mill at 0.005" DOC is 2 * sqrt(0.005 * (0.25 - 0.005)) = ~0.070"
        eff_dia = data.get("effective_diameter")
        self.assertIsNotNone(eff_dia)
        self.assertAlmostEqual(eff_dia, 0.070, places=2)
        self.assertLess(eff_dia, 0.10)
        
        # Verify contact_sfm is returned
        self.assertIn("contact_sfm", data)
        self.assertGreater(data["rpm"], 4000)
        
        # Verify 3D contour ball mill tip is present
        tip_titles = [t["title"] for t in data["tips"]]
        self.assertIn("Ball Mill Effective Diameter & 3D Contouring Dynamics", tip_titles)
        ball_tip = next(t for t in data["tips"] if "Ball Mill Effective Diameter" in t["title"])
        self.assertIn("Effective Cutting Diameter (Deff)", ball_tip["message"])
        self.assertIn("Zero-SFM Dead Center Trap", ball_tip["message"])

    def test_stock_compensation_3d_contouring(self):
        payload = {
            "family": "Titanium Alloy",
            "alloy": "Ti-6Al-4V (Grade 5)",
            "aggressiveness": 50,
            "mode": "auto_compensate",
            "operations": [
                {
                    "id": "op_3d_1",
                    "name": "3D Scallop Finish",
                    "strategy": "scallop",
                    "unit": "inches",
                    "diameter": 0.25,
                    "geometry": "Ball",
                    "flutes": 4,
                    "fluteLength": 0.50,
                    "shankDiameter": 0.25,
                    "stickout": 1.0,
                    "rpm": 8500,
                    "feedrate": 40.0,
                    "doc": 0.006,
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
        self.assertTrue(r0["recommended_radial_stock"].startswith("-0.00"))
        self.assertTrue(r0["recommended_axial_stock"].startswith("-0.00"))

if __name__ == '__main__':
    unittest.main()

