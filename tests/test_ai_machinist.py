import unittest
from app import app
import ai_machinist


class TestAiMachinist(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.client = app.test_client()

    def test_context_formatting(self):
        """Verify format_context_for_prompt serializes live telemetry."""
        context = {
            "material": "Nitronic 60 (Annealed)",
            "materialFamily": "Stainless - 300 Series (316)",
            "tool": "HP Carbide Bull Nose Endmill",
            "geometry": "Square Endmill",
            "diameter": 0.500,
            "flutes": 4,
            "fluteLength": 1.500,
            "stickout": 1.875,
            "operation": "Finishing",
            "cutDepth": 0.010,
            "cutWidth": 0.250,
            "rpm": 4114,
            "feedrate": 18.3,
            "sfm": 269.3,
            "ipt": 0.0011,
            "deflection": 0.00018,
            "spindleLoadPct": 14.5,
            "mrr": 0.046,
            "tips": ["Optimal Parameters", "Wear Compensation Active"]
        }
        text = ai_machinist.format_context_for_prompt(context)
        self.assertIn("Nitronic 60 (Annealed)", text)
        self.assertIn("0.5\" dia", text)
        self.assertIn("4114 rpm", text.lower())
        self.assertIn("deflection: 0.00018\"", text.lower())
        self.assertIn("wear compensation active", text.lower())

    def test_context_formatting_metric(self):
        """Verify format_context_for_prompt serializes metric telemetry with explicit mm and dual units."""
        context = {
            "isMetric": True,
            "material": "Black Titanium 5545",
            "materialFamily": "Titanium Alloy",
            "tool": "HP Carbide Bull Nose Endmill",
            "geometry": "Bullnose / Radiused",
            "diameter_in": 0.375,
            "diameter_mm": 9.525,
            "flutes": 4,
            "fluteLength_in": 1.125,
            "fluteLength_mm": 28.575,
            "stickout_in": 1.205,
            "stickout_mm": 30.607,
            "operation": "3D Adaptive Roughing",
            "cutDepth_in": 0.375,
            "cutDepth_mm": 9.525,
            "cutWidth_in": 0.030,
            "cutWidth_mm": 0.762,
            "rpm": 2632,
            "feedrate_ipm": 24.65,
            "feedrate_mmpm": 626.1,
            "sfm": 258.4,
            "smm": 78.8,
            "ipt_in": 0.00234,
            "ipt_mm": 0.0594,
            "plungeFeed_ipm": 6.16,
            "plungeFeed_mmpm": 156.5,
            "rampFeed_ipm": 12.33,
            "rampFeed_mmpm": 313.1,
            "deflection_in": 0.00082,
            "deflection_mm": 0.0208,
            "deflection_um": 20.8,
            "spindleLoadPct": 12.0,
            "mrr_in3": 0.28,
            "mrr_cm3": 4.54
        }
        text = ai_machinist.format_context_for_prompt(context)
        self.assertIn("Metric (UI in mm & mm/min)", text)
        self.assertIn("9.525 mm", text)
        self.assertIn("626.1 mm/min", text)
        self.assertIn("24.65 IPM", text)
        self.assertIn("78.8 m/min", text)
        self.assertIn("258.4 SFM", text)
        self.assertIn("0.0208 mm", text)
        self.assertIn("0.00082\"", text)
        self.assertIn("4.54 cm³/min", text)

    def test_offline_negative_stock_response(self):
        """Verify offline expert response answers flat finishing & springback questions."""
        res = ai_machinist.query_ai_machinist(
            prompt="Should I do negative stock to leave on the flats during finishing?",
            context={"material": "Nitronic 60 (Annealed)", "diameter": 0.500, "operation": "Finishing"}
        )
        self.assertTrue(res["success"])
        self.assertEqual(res["mode"], "offline_expert")
        reply = res["reply"]
        self.assertIn("Negative Stock to Leave", reply)
        self.assertIn("Springback", reply)
        self.assertIn("Spring Pass", reply)
        self.assertIn("Nitronic 60", reply)

    def test_offline_chatter_response(self):
        """Verify offline expert response addresses chatter inquiries."""
        res = ai_machinist.query_ai_machinist(
            prompt="How do I reduce chatter with high tool stickout?",
            context={"material": "Steel - Medium Carbon Alloy (4130)", "diameter": 0.500}
        )
        self.assertTrue(res["success"])
        self.assertIn("Chatter", res["reply"])
        self.assertIn("Adaptive", res["reply"])

    def test_api_endpoint_success(self):
        """Verify POST /api/ai_chat returns 200 with structured JSON."""
        payload = {
            "message": "Should I use negative stock to leave on flat pocket floors?",
            "context": {
                "material": "Nitronic 60 (Annealed)",
                "diameter": 0.500,
                "operation": "Finishing"
            }
        }
        resp = self.client.post("/api/ai_chat", json=payload)
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertTrue(data.get("success"))
        self.assertIn("reply", data)
        self.assertGreater(len(data["reply"]), 100)

    def test_api_endpoint_empty_message(self):
        """Verify POST /api/ai_chat rejects empty queries."""
        resp = self.client.post("/api/ai_chat", json={"message": "   "})
        self.assertEqual(resp.status_code, 400)
        data = resp.get_json()
        self.assertFalse(data.get("success"))

    def test_get_ai_models_endpoint(self):
        """Verify GET /api/ai_models returns available models list."""
        resp = self.client.get("/api/ai_models")
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertTrue(data.get("success"))
        model_ids = [m["id"] for m in data.get("models", [])]
        self.assertIn("auto", model_ids)
        self.assertIn("gemini-2.5-pro", model_ids)
        self.assertIn("gemini-2.5-flash", model_ids)

    def test_get_ai_models_endpoint_formatting(self):
        """Verify GET /api/ai_models formats friendly, human-readable labels."""
        resp = self.client.get("/api/ai_models")
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        names = {m["id"]: m["name"] for m in data.get("models", [])}
        self.assertEqual(names.get("gemini-2.5-pro"), "Gemini 2.5 Pro (Deep CAM Reasoning)")
        self.assertEqual(names.get("gemini-2.5-flash"), "Gemini 2.5 Flash (Fast)")

    def test_api_endpoint_with_model_preference(self):
        """Verify POST /api/ai_chat accepts preferred model parameter."""
        payload = {
            "message": "Should I use climb milling for finishing Nitronic 60?",
            "model": "gemini-2.5-pro",
            "context": {"material": "Nitronic 60", "diameter": 0.5}
        }
        resp = self.client.post("/api/ai_chat", json=payload)
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertTrue(data.get("success"))
        self.assertIn("reply", data)


if __name__ == "__main__":
    unittest.main()
