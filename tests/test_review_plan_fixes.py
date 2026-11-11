import os
import tempfile
import unittest

import app as app_module
from app import app, physics
from ai_machinist import _scrub_key
from backup_manager import BackupManager
from pipeline import CutRequest, run_cut
from ToolWizFusionAddin.json_mutator import mutate_tool_json


class TestReviewPlanFixes(unittest.TestCase):
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

    def test_wp0_backup_manager_respects_toolwiz_data_dir_env(self):
        with tempfile.TemporaryDirectory() as env_dir:
            prev = os.environ.get("TOOLWIZ_DATA_DIR")
            try:
                os.environ["TOOLWIZ_DATA_DIR"] = env_dir
                bm_env = BackupManager()
                self.assertTrue(bm_env.data_dir.startswith(env_dir))
                self.assertTrue(bm_env.backups_dir.startswith(env_dir))
            finally:
                if prev is None:
                    os.environ.pop("TOOLWIZ_DATA_DIR", None)
                else:
                    os.environ["TOOLWIZ_DATA_DIR"] = prev

    def test_wp1c_json_mutator_uses_calculated_ramp_angle(self):
        raw_json = '{"type": "flat end mill", "unit": "inches", "geometry": {"DC": 0.25}, "start-values": {"presets": []}}'
        mutated, _, _ = mutate_tool_json(raw_json, {
            "name": "ToolWiz: 304 SS - Roughing",
            "rpm": 4000,
            "feed": 15.0,
            "sfm": 260.0,
            "ipt": 0.001,
            "doc": 0.125,
            "woc": 0.025,
            "ramp_feed": 7.5,
            "plunge_feed": 3.0,
            "ramp_angle": 1.3,
        })
        import json
        parsed = json.loads(mutated)
        preset = parsed["start-values"]["presets"][0]
        self.assertAlmostEqual(preset["ramp-angle"], 1.3, places=3)

    def test_wp1d_batch_generate_respects_hss_and_cobalt_and_reamer_types(self):
        carbide_drill = {
            "guid": "d-carb",
            "type": "drill",
            "unit": "inches",
            "description": "1/4 Carbide Drill",
            "BMC": "carbide",
            "geometry": {"DC": 0.25, "NOF": 2, "LCF": 1.25, "SFDM": 0.25, "LB": 1.5},
            "post-process": {"number": 1},
        }
        hss_drill = {
            "guid": "d-hss",
            "type": "drill",
            "unit": "inches",
            "description": "1/4 HSS Twist Drill",
            "BMC": "hss",
            "geometry": {"DC": 0.25, "NOF": 2, "LCF": 1.25, "SFDM": 0.25, "LB": 1.5},
            "post-process": {"number": 2},
        }
        cobalt_drill = {
            "guid": "d-cob",
            "type": "drill",
            "unit": "inches",
            "description": "1/4 M42 Cobalt Twist Drill",
            "BMC": "cobalt",
            "geometry": {"DC": 0.25, "NOF": 2, "LCF": 1.25, "SFDM": 0.25, "LB": 1.5},
            "post-process": {"number": 3},
        }
        hss_endmill = {
            "guid": "em-hss",
            "type": "flat end mill",
            "unit": "inches",
            "description": "1/4 HSS 4FL Endmill",
            "BMC": "hss",
            "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.75, "SFDM": 0.25, "LB": 1.0},
            "post-process": {"number": 4},
        }
        carbide_endmill = {
            "guid": "em-carb",
            "type": "flat end mill",
            "unit": "inches",
            "description": "1/4 Carbide 4FL Endmill",
            "BMC": "carbide",
            "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.75, "SFDM": 0.25, "LB": 1.0},
            "post-process": {"number": 5},
        }
        self.bm.save_working_library(
            {"library_name": "BatchTypeTest", "tools": [carbide_drill, hss_drill, cobalt_drill, hss_endmill, carbide_endmill]},
            "BatchTypeTest",
        )
        resp = self.client.post("/api/twin/batch_generate", json={
            "tool_indices": "all",
            "family": "Steel - Medium Carbon Alloy (4130)",
            "alloy": "4140 (Annealed)",
            "strategies": ["Roughing"],
            "aggressiveness": 50,
        })
        self.assertEqual(resp.status_code, 200)
        tools = self.bm.load_working_library()["tools"]
        rpm_carb_drill = tools[0]["start-values"]["presets"][0]["n"]
        rpm_hss_drill = tools[1]["start-values"]["presets"][0]["n"]
        rpm_cob_drill = tools[2]["start-values"]["presets"][0]["n"]
        rpm_hss_em = tools[3]["start-values"]["presets"][0]["n"]
        rpm_carb_em = tools[4]["start-values"]["presets"][0]["n"]

        self.assertGreater(rpm_carb_drill, rpm_cob_drill)
        self.assertGreater(rpm_cob_drill, rpm_hss_drill)
        self.assertGreater(rpm_carb_em, rpm_hss_em * 1.8)

    def test_wp1h_drill_clamps_stale_four_flutes_to_two(self):
        r4 = run_cut(physics, CutRequest(
            family="Aluminum - Wrought (6061)",
            alloy="6061-T6",
            tool="Carbide Twist Drill",
            geometry="Drill",
            operation="Drilling",
            diameter=0.25,
            flutes=4,  # stale end mill default
            flute_length=1.25,
            stickout=1.5,
        ))
        r2 = run_cut(physics, CutRequest(
            family="Aluminum - Wrought (6061)",
            alloy="6061-T6",
            tool="Carbide Twist Drill",
            geometry="Drill",
            operation="Drilling",
            diameter=0.25,
            flutes=2,
            flute_length=1.25,
            stickout=1.5,
        ))
        self.assertEqual(round(r4.ipr / r4.adj_ipt), 2)
        self.assertAlmostEqual(r4.feed_ipm, r2.feed_ipm, places=4)

    def test_wp6_zero_runout_preserved_in_v2(self):
        r_zero = self.client.post("/api/calculate", json={
            "family": "Steel - Medium Carbon Alloy (4130)",
            "alloy": "4140 (Annealed)",
            "tool": "Carbide Endmill",
            "operation": "Finishing",
            "diameter": 0.0625,
            "flutes": 4,
            "fluteLength": 0.1875,
            "stickout": 0.35,
            "cutDepth": 0.05,
            "cutWidth": 0.005,
            "runout": 0.0,
            "model": "v2",
        }).get_json()
        r_def = self.client.post("/api/calculate", json={
            "family": "Steel - Medium Carbon Alloy (4130)",
            "alloy": "4140 (Annealed)",
            "tool": "Carbide Endmill",
            "operation": "Finishing",
            "diameter": 0.0625,
            "flutes": 4,
            "fluteLength": 0.1875,
            "stickout": 0.35,
            "cutDepth": 0.05,
            "cutWidth": 0.005,
            "runout": 0.0005,
            "model": "v2",
        }).get_json()
        self.assertTrue(r_zero["success"])
        self.assertTrue(r_def["success"])
        self.assertGreaterEqual(r_zero["feedrate"], r_def["feedrate"])

    def test_sec16_scrub_key_and_curate_working_library(self):
        secret = "AIzaSySecretKey12345"
        msg = _scrub_key(f"Failed with key={secret} on request", secret)
        self.assertNotIn(secret, msg)
        self.assertIn("[REDACTED]", msg)

        # Test /api/library/curate with working library
        self.bm.save_working_library({
            "library_name": "CurateTest",
            "tools": [{
                "type": "flat end mill",
                "unit": "inches",
                "description": "1/32 3FL AlTiN",
                "geometry": {"DC": 0.03125, "NOF": 3, "LCF": 0.09375, "SFDM": 0.03125, "LB": 0.35},
            }],
        }, "CurateTest")
        resp = self.client.post("/api/library/curate", json={
            "use_working_library": True,
            "apply_to_working_library": True,
        }).get_json()
        self.assertTrue(resp["success"])
        self.assertTrue(resp.get("applied_to_working_library"))
        saved = self.bm.load_working_library()["tools"][0]
        self.assertAlmostEqual(saved["geometry"]["SFDM"], 0.125, places=4)

    def test_wp1a_json_mutator_preserves_5_decimal_micro_stepdown_and_stepover(self):
        raw_json = '{"type": "flat end mill", "unit": "inches", "geometry": {"DC": 0.0156}, "start-values": {"presets": []}}'
        mutated, _, _ = mutate_tool_json(raw_json, {
            "name": "ToolWiz: Micro",
            "rpm": 16000,
            "feed": 4.0,
            "sfm": 65.0,
            "ipt": 0.00008,
            "doc": 0.00156,
            "woc": 0.00078,
        })
        import json
        parsed = json.loads(mutated)
        preset = parsed["start-values"]["presets"][0]
        self.assertAlmostEqual(preset["stepdown"], 0.00156, places=5)
        self.assertAlmostEqual(preset["stepover"], 0.00078, places=5)

    def test_aggressiveness_one_percent_not_treated_as_100_percent(self):
        em = {
            "guid": "em-1",
            "type": "flat end mill",
            "unit": "inches",
            "description": "1/4 Carbide 4FL Endmill",
            "BMC": "carbide",
            "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.75, "SFDM": 0.25, "LB": 1.0},
            "post-process": {"number": 1},
        }
        self.bm.save_working_library({"library_name": "Aggr1", "tools": [em]}, "Aggr1")
        self.client.post("/api/twin/batch_generate", json={
            "tool_indices": "all",
            "family": "Aluminum - Wrought (6061)",
            "alloy": "6061-T6",
            "strategies": ["Roughing"],
            "aggressiveness": 1,
        })
        p_1 = self.bm.load_working_library()["tools"][0]["start-values"]["presets"][0]
        self.assertIn("Aggressiveness: 1%", p_1["description"])

    def test_stock_compensation_trim_slider_plus_minus_25_percent(self):
        def query_trim(pct):
            resp = self.client.post("/api/stock_compensation", json={
                "family": "Titanium Alloy",
                "alloy": "Ti-6Al-4V (Grade 5)",
                "comp_adjust_pct": pct,
                "mode": "auto_compensate",
                "operations": [{
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
                    "current_axial_stock": "0.0000 in",
                }],
            })
            self.assertEqual(resp.status_code, 200)
            return resp.get_json()["results"][0]

        r_rec = query_trim(0)
        r_minus25 = query_trim(-25)
        r_plus25 = query_trim(25)
        self.assertAlmostEqual(r_minus25["total_error_in"], r_rec["total_error_in"] * 0.75, places=5)
        self.assertAlmostEqual(r_plus25["total_error_in"], r_rec["total_error_in"] * 1.25, places=5)


if __name__ == "__main__":
    unittest.main()
