"""Web-layer hardening tests: CSRF guard, feasibility fields, infeasible batch skipping,
machine profile defaults and error mapping."""
import copy
import json
import os
import sys
import tempfile
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, ROOT)

import app as app_module
from app import app
from backup_manager import BackupManager

FIX_DIR = os.path.join(os.path.dirname(__file__), "fixtures")
HDR = {"X-ToolWiz-Client": "web"}

FEASIBLE = {"family": "Steel - Tool (H13)", "tool": "Carbide Endmill", "diameter": 0.5,
            "flutes": 4, "stickout": 1.5, "fluteLength": 1.0, "operation": "Roughing"}
INFEASIBLE = dict(FEASIBLE, diameter=0.0625, stickout=3.0, fluteLength=3.0)


def fixture(name):
    with open(os.path.join(FIX_DIR, name), "r", encoding="utf-8") as f:
        return json.load(f)


def long_skinny_tool():
    t = copy.deepcopy(fixture("flat_inch_sfdm_lb.json"))
    t["geometry"].update({"DC": 0.0625, "SFDM": 0.0625, "LCF": 3.0, "LB": 3.0, "NOF": 4})
    t["postProcess"] = {"number": 7}
    t["guid"] = "skinny-1"
    return t


class TestCsrfGuard(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()  # deliberately no default header

    def test_post_without_header_is_403(self):
        r = self.client.post("/api/calculate", json=FEASIBLE)
        self.assertEqual(r.status_code, 403)
        self.assertFalse(r.get_json()["success"])

    def test_empty_header_is_403(self):
        r = self.client.post("/api/calculate", json=FEASIBLE, headers={"X-ToolWiz-Client": " "})
        self.assertEqual(r.status_code, 403)

    def test_foreign_origin_is_403(self):
        r = self.client.post("/api/calculate", json=FEASIBLE,
                             headers=dict(HDR, Origin="http://evil.example"))
        self.assertEqual(r.status_code, 403)

    def test_local_origins_allowed(self):
        for origin in ("http://127.0.0.1:5000", "http://localhost:5000"):
            r = self.client.post("/api/calculate", json=FEASIBLE, headers=dict(HDR, Origin=origin))
            self.assertEqual(r.status_code, 200, origin)

    def test_header_allows_request(self):
        r = self.client.post("/api/calculate", json=FEASIBLE, headers=HDR)
        self.assertEqual(r.status_code, 200)
        self.assertTrue(r.get_json()["success"])

    def test_fusion_addin_client_value_allowed(self):
        r = self.client.post("/api/calculate_for_fusion", json=FEASIBLE,
                             headers={"X-ToolWiz-Client": "fusion-addin"})
        self.assertEqual(r.status_code, 200)

    def test_get_does_not_need_header(self):
        self.assertEqual(self.client.get("/api/data").status_code, 200)

    def test_max_content_length(self):
        self.assertEqual(app.config["MAX_CONTENT_LENGTH"], 50 * 1024 * 1024)


class TestFeasibilityFields(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()
        self.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def test_calculate_feasible(self):
        d = self.client.post("/api/calculate", json=FEASIBLE).get_json()
        self.assertTrue(d["feasible"])
        self.assertIn(d["limited_by"], ("deflection", "power", "flute_length", "geometry_rule"))
        self.assertFalse(any(t["type"] == "critical" and t["title"] == "Infeasible Setup" for t in d["tips"]))

    def test_calculate_infeasible_adds_critical_tip(self):
        d = self.client.post("/api/calculate", json=INFEASIBLE).get_json()
        self.assertFalse(d["feasible"])
        self.assertTrue(d["limited_by"])
        self.assertTrue(any(t["type"] == "critical" and t["title"] == "Infeasible Setup" for t in d["tips"]))

    def test_fusion_endpoint_reports_feasibility(self):
        ok = self.client.post("/api/calculate_for_fusion", json=FEASIBLE).get_json()
        bad = self.client.post("/api/calculate_for_fusion", json=INFEASIBLE).get_json()
        self.assertTrue(ok["feasible"])
        self.assertFalse(bad["feasible"])
        self.assertIn("limited_by", bad)


class TestBatchSkipsInfeasible(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.orig_bm = app_module.bm
        self.bm = BackupManager(base_dir=self.tmp.name)
        app_module.bm = self.bm
        self.client = app.test_client()
        self.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def tearDown(self):
        app_module.bm = self.orig_bm
        self.tmp.cleanup()

    def test_infeasible_strategy_not_written_and_reported(self):
        self.bm.save_working_library({"library_name": "T", "tools": [long_skinny_tool()]}, "T")
        r = self.client.post("/api/twin/batch_generate", json={
            "tool_indices": "all", "family": "Steel - Tool (H13)", "alloy": "",
            "aggressiveness": 50, "strategies": ["Roughing", "Finishing"]})
        self.assertEqual(r.status_code, 200, r.get_data(as_text=True))
        data = r.get_json()
        self.assertTrue(data["success"])
        skipped = [s for s in data["skipped"] if s.get("strategy")]
        self.assertTrue(skipped, data)
        for s in skipped:
            self.assertEqual(s["tool_index"], 0)
            self.assertEqual(s["number"], 7)
            self.assertIn("infeasible", s["reason"])
        lib = self.bm.load_working_library()
        names = [p["name"] for p in lib["tools"][0]["start-values"]["presets"]]
        skipped_strats = {s["strategy"] for s in skipped}
        for strat in skipped_strats:
            self.assertFalse(any(n.endswith(f" - {strat}") for n in names), (strat, names))
        self.assertEqual(data["total_presets_injected"], len(names))


class TestMachineProfileAndErrors(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()
        self.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def test_data_exposes_machine_defaults(self):
        m = self.client.get("/api/data").get_json()["machine"]
        self.assertEqual(m["max_rpm"], 16000.0)
        self.assertAlmostEqual(m["max_hp"], 5.1 * 1.341, places=1)
        self.assertEqual(m["active_spindle"], "optional_16k")

    def test_default_max_rpm_comes_from_profile(self):
        self.assertEqual(app_module.MACHINE["max_rpm"], 16000.0)
        self.assertAlmostEqual(app_module.MACHINE["max_hp"], 6.84, places=1)

    def test_bad_input_is_400(self):
        r = self.client.post("/api/calculate", json=dict(FEASIBLE, diameter="abc"))
        self.assertEqual(r.status_code, 400)
        d = r.get_json()
        self.assertFalse(d["success"])
        self.assertIn("error", d)

    def test_unexpected_error_is_500_generic(self):
        orig = app_module.physics.get_base_sfm
        def boom(*a, **k):
            raise RuntimeError("secret internals")
        app_module.physics.get_base_sfm = boom
        try:
            with self.assertLogs(app.logger, level="ERROR"):
                r = self.client.post("/api/calculate", json=FEASIBLE)
        finally:
            app_module.physics.get_base_sfm = orig
        self.assertEqual(r.status_code, 500)
        self.assertNotIn("secret", r.get_data(as_text=True))


if __name__ == "__main__":
    unittest.main()
