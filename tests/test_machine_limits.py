import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import app as app_module


class TestMachineLimits(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self._orig = app_module.MACHINE_SETTINGS_PATH
        app_module.MACHINE_SETTINGS_PATH = os.path.join(self.tmp.name, "machine_settings.json")
        self.client = app_module.app.test_client()
        self.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def tearDown(self):
        app_module.MACHINE_SETTINGS_PATH = self._orig
        self.tmp.cleanup()

    def fusion_calc(self, **extra):
        payload = {"family": "Steel - Tool (H13)", "tool": "Carbide Endmill", "operation": "Roughing",
                   "diameter": 1.0, "flutes": 4, "fluteLength": 2.0, "stickout": 2.5, "geometry": "Square"}
        payload.update(extra)
        return self.client.post("/api/calculate_for_fusion", json=payload).get_json()

    def test_defaults_come_from_16k_spindle_profile(self):
        d = self.client.get("/api/machine_limits").get_json()
        self.assertEqual(d["max_rpm"], 16000.0)
        self.assertAlmostEqual(d["max_hp"], 5.1 * 1.341, places=2)
        self.assertEqual(d["overridden"], [])

    def test_override_persists_and_is_used_when_request_omits_hp(self):
        r = self.client.post("/api/machine_limits", json={"maxHp": 9.9}).get_json()
        self.assertTrue(r["success"])
        self.assertEqual(r["max_hp"], 9.9)
        self.assertEqual(self.client.get("/api/data").get_json()["machine"]["max_hp"], 9.9)
        # The Fusion add-in doesn't send maxHp; the server-side override must apply.
        low = self.fusion_calc(maxHp=1.0)
        default = self.fusion_calc()
        self.assertGreater(default["doc"], low["doc"])

    def test_clearing_reverts_to_profile(self):
        self.client.post("/api/machine_limits", json={"maxHp": 9.9})
        r = self.client.post("/api/machine_limits", json={"maxHp": None}).get_json()
        self.assertAlmostEqual(r["max_hp"], r["profile_max_hp"])
        self.assertEqual(r["overridden"], [])

    def test_rejects_out_of_range_and_non_numeric(self):
        self.assertEqual(self.client.post("/api/machine_limits", json={"maxHp": 0}).status_code, 400)
        self.assertEqual(self.client.post("/api/machine_limits", json={"maxRpm": "fast"}).status_code, 400)

    def test_requires_client_header(self):
        bare = app_module.app.test_client()
        self.assertEqual(bare.post("/api/machine_limits", json={"maxHp": 5}).status_code, 403)


if __name__ == "__main__":
    unittest.main()
