"""v1/v2 cutting-model selector: page markup and the API round trips it relies on."""
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import app as app_module
import machine_profiles
import v2_bridge

PAGE_IDS = [
    "cutModelSelect", "cutModelSource", "modelBadge", "modelNote",
    "v2Panel", "v2Status", "v2Binding", "v2Consensus", "v2Warnings", "v2CompareRows", "v2Provenance",
    "whyPanel",
]

PAGE_FUNCTIONS = [
    "showCutModel", "loadCutModel", "onCutModelChange", "setCalcBusy", "renderModelBadge",
    "fmtV2Num", "renderV2Check", "renderV2List", "renderV2Compare", "renderV2Panel",
]

GEOMETRY = {"DC": 0.0625, "NOF": 4, "LCF": 0.1875, "SFDM": 0.125, "LB": 0.5}


def cut_request(**extra):
    body = dict(family="Stainless - PH Series (17-4)", alloy="17-4 PH (H 1025)", tool="HP Carbide Endmill",
                coating="AlTiN", geometry="Square", operation="Adaptive Roughing", diameter=GEOMETRY["DC"],
                flutes=GEOMETRY["NOF"], fluteLength=GEOMETRY["LCF"], shankDiameter=GEOMETRY["SFDM"],
                stickout=GEOMETRY["LB"], aggressiveness=65, isCarbide=True,
                fusion_tool={"type": "flat end mill", "unit": "inches", "geometry": GEOMETRY})
    body.update(extra)
    return body


class TestModelSwitch(unittest.TestCase):
    def setUp(self):
        # Never touch the user's real data/model_settings.json, machine settings or machine profiles.
        self.tmp = tempfile.TemporaryDirectory()
        self._model_path = v2_bridge.SETTINGS_PATH
        self._settings = app_module.MACHINE_SETTINGS_PATH
        self._user_dir = machine_profiles.USER_DIR
        v2_bridge.SETTINGS_PATH = os.path.join(self.tmp.name, "model_settings.json")
        app_module.MACHINE_SETTINGS_PATH = os.path.join(self.tmp.name, "machine_settings.json")
        machine_profiles.USER_DIR = os.path.join(self.tmp.name, "machines")
        self._env = os.environ.pop("TOOLWIZ_MODEL", None)
        self.client = app_module.app.test_client()
        self.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def tearDown(self):
        v2_bridge.SETTINGS_PATH = self._model_path
        app_module.MACHINE_SETTINGS_PATH = self._settings
        machine_profiles.USER_DIR = self._user_dir
        if self._env is not None:
            os.environ["TOOLWIZ_MODEL"] = self._env
        self.tmp.cleanup()

    # -- page ------------------------------------------------------------------------------------
    def test_page_has_selector_badge_panel_and_functions(self):
        html = self.client.get("/").get_data(as_text=True)
        for eid in PAGE_IDS:
            self.assertIn(f'id="{eid}"', html, eid)
        for fn in PAGE_FUNCTIONS:
            self.assertIn(f"function {fn}(", html, fn)
        self.assertIn('<option value="v1">v1 (GWizard tables + rules)</option>', html)
        self.assertIn('<option value="v2">v2 (physics, beta)</option>', html)
        self.assertIn("v2 numbers: see the v2 panel", html)

    # -- /api/model_settings ---------------------------------------------------------------------
    def test_get_returns_a_model(self):
        d = self.client.get("/api/model_settings").get_json()
        self.assertTrue(d["success"])
        self.assertIn(d["model"], ("v1", "v2"))
        self.assertEqual(d["models"], ["v1", "v2"])

    def test_post_saves_and_get_reports_saved_setting(self):
        r = self.client.post("/api/model_settings", json={"model": "v2"})
        self.assertEqual(r.status_code, 200)
        d = self.client.get("/api/model_settings").get_json()
        self.assertEqual(d["model"], "v2")
        self.assertEqual(d["source"], "saved setting")
        self.assertTrue(os.path.exists(v2_bridge.SETTINGS_PATH))
        self.client.post("/api/model_settings", json={"model": "v1"})
        self.assertEqual(self.client.get("/api/model_settings").get_json()["model"], "v1")

    def test_post_bad_model_is_rejected(self):
        r = self.client.post("/api/model_settings", json={"model": "bogus"})
        self.assertEqual(r.status_code, 400)
        self.assertFalse(r.get_json()["success"])
        self.assertFalse(os.path.exists(v2_bridge.SETTINGS_PATH))

    # -- /api/calculate --------------------------------------------------------------------------
    def calc(self, model):
        r = self.client.post("/api/calculate", json=cut_request(model=model))
        self.assertEqual(r.status_code, 200)
        d = r.get_json()
        self.assertTrue(d["success"], d)
        return d

    def test_calculate_v2_fills_the_v2_fields(self):
        d = self.calc("v2")
        self.assertEqual(d["model"], "v2")
        self.assertIsInstance(d["v1"], dict)
        self.assertIsInstance(d["v2"]["binding"], list)
        self.assertTrue(d["v2"]["binding"])
        self.assertTrue(d["model_note"])
        for cid in d["v2"]["binding"]:
            self.assertIn(cid, d["v2"]["checks"])
        for cid in ("C14v", "C14f", "C14m"):
            self.assertIn(cid, d["v2"]["checks"])
        self.assertGreater(d["rec_doc"], d["v1"]["doc"])
        self.assertEqual(d["provenance"], [])
        self.assertTrue(d["v2"]["provenance"])

    def test_calculate_v1_has_no_v2_block(self):
        d = self.calc("v1")
        self.assertEqual(d["model"], "v1")
        self.assertIsNone(d["v2"])
        self.assertIsNone(d["v1"])


if __name__ == "__main__":
    unittest.main()
