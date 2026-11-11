"""Machine definitions v4 (taper, dual contact, stiffness defaults, simple mode), shop shank rule, curator and
audit shank findings, runout sensitivity, the 4 x 0.5 T-slot cutter."""
import copy
import dataclasses
import json
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import app as app_module
import library_audit
import machine_profiles as mp
import runout_sensitivity
import tool_library_curator
import v2_bridge
from toolwiz_common import ToolProfile, default_shank, shank_looks_wrong

ROOT = os.path.join(os.path.dirname(__file__), "..")
OWNER_LIB = os.path.join(ROOT, "data", "shop_library", "Offworldgear_TI_Steel1_Updated4_20261019_125408_v6.json")


def load(path):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


class TestShankRule(unittest.TestCase):
    def test_inch_rule(self):
        for d, want in ((0.03125, 0.125), (0.0625, 0.125), (0.125, 0.125), (0.1875, 0.25), (0.2, 0.25),
                        (0.25, 0.25), (0.375, 0.375), (0.5, 0.5)):
            self.assertAlmostEqual(default_shank(d), want, msg=d)
            self.assertAlmostEqual(default_shank(d, "inches"), want, msg=d)

    def test_metric_rule(self):
        for d, want in ((1.0, 4.0), (3.0, 4.0), (3.175, 6.0), (4.0, 6.0), (5.9, 6.0), (6.0, 6.0), (8.0, 8.0), (10.0, 10.0)):
            self.assertAlmostEqual(default_shank(d, "mm"), want, msg=d)
            self.assertAlmostEqual(default_shank(d, "millimeters"), want, msg=d)

    def test_shank_looks_wrong(self):
        self.assertTrue(shank_looks_wrong(0.0625, 0.0625))
        self.assertTrue(shank_looks_wrong(0.0625, 0.062))
        self.assertTrue(shank_looks_wrong(0.1875, 0.1875))
        self.assertFalse(shank_looks_wrong(0.0625, 0.125))
        self.assertFalse(shank_looks_wrong(0.125, 0.125))
        self.assertFalse(shank_looks_wrong(0.1875, 0.25))
        self.assertFalse(shank_looks_wrong(0.5, 0.5))
        self.assertTrue(shank_looks_wrong(2.0, 3.0, "mm"))
        self.assertFalse(shank_looks_wrong(2.0, 4.0, "mm"))
        self.assertFalse(shank_looks_wrong(4.0, 6.0, "mm"))

    def test_missing_shank_in_metric_tool(self):
        tool = {"type": "flat end mill", "unit": "millimeters", "geometry": {"DC": 2.0, "NOF": 3, "LCF": 5, "LB": 12}}
        self.assertAlmostEqual(ToolProfile.from_fusion(tool).geometry.shank_diameter * 25.4, 4.0)


class TestCuratorAndAudit(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.lib = load(OWNER_LIB)

    def test_owner_sixteenth_inch_tool_gets_rule_shank_and_taper(self):
        tool = self.lib["tools"][2]
        self.assertEqual(tool["geometry"]["SFDM"], 0.0625)
        r = tool_library_curator.curate_tool_dict(tool)
        self.assertEqual(r.curated_tool["geometry"]["SFDM"], 0.125)
        change = next(c for c in r.changes if c.field == "geometry.SFDM")
        self.assertIn("taper", change.reason)
        segs = r.curated_tool["shaft"]["segments"]
        self.assertAlmostEqual(segs[0]["lower-diameter"], 0.0625, places=4)
        self.assertAlmostEqual(segs[0]["upper-diameter"], 0.125, places=4)
        self.assertEqual(tool["geometry"]["SFDM"], 0.0625, "input is not mutated")

    def test_larger_tool_with_small_shank(self):
        tool = {"type": "flat end mill", "unit": "inches", "description": "3/16 endmill",
                "geometry": {"DC": 0.1875, "NOF": 4, "LCF": 0.5, "SFDM": 0.1875, "LB": 1.0, "OAL": 2.5}}
        r = tool_library_curator.curate_tool_dict(tool)
        self.assertAlmostEqual(r.curated_tool["geometry"]["SFDM"], 0.25)

    def test_correct_tools_untouched(self):
        for idx in (10, 11, 19):
            self.assertAlmostEqual(self.lib["tools"][idx]["geometry"]["SFDM"], 0.125)
            r = tool_library_curator.curate_tool_dict(self.lib["tools"][idx])
            self.assertEqual(r.curated_tool["geometry"]["SFDM"], 0.125)

    def test_audit_reports_shank_suspect(self):
        lib = {"tools": [self.lib["tools"][2], self.lib["tools"][12], self.lib["tools"][11]]}
        rep = library_audit.audit_library(lib, app_module.physics, material="Titanium Alloy")
        found = [f for f in rep["findings"] if f["code"] == "shank_suspect"]
        self.assertEqual(sorted(f["tool_index"] for f in found), [0, 1])
        self.assertTrue(all(f["severity"] == "CAUTION" and f["toolwiz_value"] == 0.125 for f in found))
        self.assertIn("0.125", found[0]["message"])

    def test_whole_owner_library_findings(self):
        rep = library_audit.audit_library(self.lib, app_module.physics)
        idx = sorted(f["tool_index"] for f in rep["findings"] if f["code"] == "shank_suspect")
        self.assertEqual(idx, [2, 12])


class TestMachineProfileV4(unittest.TestCase):
    def test_speedio_metadata_and_behaviour_unchanged(self):
        p = mp.list_profiles()["speedio_s500x2"]["profile"]
        self.assertEqual((p["brand"], p["model"], p["spindle_taper"], p["dual_contact"]),
                         ("Brother", "Speedio S500X2", "BT30", False))
        self.assertEqual(p["holder_stiffness"]["k_n_um"], 31.4)
        self.assertEqual(p["spindle_options"]["optional_16k"]["torque_curve"]["ratings"]["continuous"]["points"][1], [4500, 10.82])
        hs, src = mp.effective_holder_stiffness(p)
        self.assertEqual(src, "profile")

    def test_default_stiffness_by_taper(self):
        k = {t: mp.default_holder_stiffness(t)["k_n_um"] for t in mp.TAPERS}
        self.assertLess(k["BT30"], k["BT40"])
        self.assertLess(k["BT40"], k["HSK-A63"])
        self.assertGreater(mp.default_holder_stiffness("BT30", True)["k_n_um"], k["BT30"])
        self.assertIn("estimate", mp.default_holder_stiffness("BT40")["status"].lower())
        self.assertIsNone(mp.default_holder_stiffness("nonsense"))

    def test_profile_without_taper_keeps_old_behaviour(self):
        raw = {"machine": "Old", "spindle_options": {"s": {"max_rpm": 8000, "power_kw_continuous": 3}}}
        self.assertEqual(mp.effective_holder_stiffness(raw), (None, None))
        self.assertEqual(mp._with_derived_stiffness(raw), raw)
        clean, errors = mp.validate_profile(raw)
        self.assertFalse(errors)
        self.assertNotIn("holder_stiffness", clean)
        for k in ("brand", "spindle_taper", "dual_contact", "through_spindle_coolant_bar"):
            self.assertNotIn(k, clean)

    def test_taper_default_reaches_engine_and_is_not_saved(self):
        raw = {"machine": "Mill", "brand": "Haas", "model": "VF-2", "controller": "NGC", "spindle_taper": "CAT40",
               "dual_contact": False, "through_spindle_coolant_bar": 20, "max_cutting_feed_mm_min": 20000,
               "rapid_m_min": {"x": 25, "y": 25, "z": 25},
               "spindle_options": {"s": {"max_rpm": 8100, "power_kw_continuous": 22}}}
        clean, errors = mp.validate_profile(raw)
        self.assertFalse(errors, errors)
        self.assertEqual(clean["through_spindle_coolant_bar"], 20.0)
        seen = mp._with_derived_stiffness(clean)
        self.assertTrue(seen["holder_stiffness"]["derived"])
        again, _ = mp.validate_profile(seen)
        self.assertNotIn("holder_stiffness", again)
        r = _req()
        m, _ = v2_bridge.machine_for(r, seen)
        self.assertAlmostEqual(m.holder_k_n_um, seen["holder_stiffness"]["k_n_um"])
        self.assertIn("ESTIMATE", m.holder_basis)
        m2, _ = v2_bridge.machine_for(r, clean)       # no stiffness at all: engine default, no crash
        self.assertIsNone(m2.holder_k_n_um)

    def test_override_is_kept(self):
        raw = {"machine": "Mill", "spindle_taper": "BT30", "holder_stiffness": {"k_n_um": 18.5, "ktheta_nm_urad": 0.07},
               "spindle_options": {"s": {"max_rpm": 8100, "power_kw_continuous": 5}}}
        clean, errors = mp.validate_profile(raw)
        self.assertFalse(errors)
        self.assertEqual(clean["holder_stiffness"]["k_n_um"], 18.5)
        self.assertEqual(mp.effective_holder_stiffness(clean)[1], "profile")

    def test_validation_errors(self):
        base = {"machine": "M", "spindle_options": {"s": {"max_rpm": 8000, "power_kw_continuous": 3}}}
        for patch in ({"spindle_taper": "XX99"}, {"through_spindle_coolant_bar": -4}, {"max_cutting_feed_mm_min": "x"},
                      {"rapid_m_min": {"x": 0, "y": 1, "z": 1}}):
            _, errors = mp.validate_profile(dict(base, **patch))
            self.assertTrue(errors, patch)

    def test_simple_mode_generates_curves(self):
        raw = {"machine": "M", "spindle_options": {"s": {
            "max_rpm": 12000, "simple": {"peak_torque_nm": 30, "base_rpm": 3000, "continuous_kw": 5.5}}}}
        clean, errors = mp.validate_profile(raw)
        self.assertFalse(errors, errors)
        sp = clean["spindle_options"]["s"]
        self.assertEqual(sp["base_rpm"], 3000)
        self.assertEqual(sp["max_torque_nm_momentary"], 30.0)
        cont = mp.capacity(sp, 12000)
        self.assertAlmostEqual(cont["power_kw"], 5.5, places=1)
        mom = mp.capacity(sp, 3000, "momentary")
        self.assertAlmostEqual(mom["torque_nm"], 30.0, places=2)
        self.assertTrue(sp["torque_curve"]["ratings"]["continuous"]["derived"])

    def test_summary_has_new_fields(self):
        s = mp.summarize("speedio_s500x2", mp.list_profiles()["speedio_s500x2"])
        self.assertEqual((s["brand"], s["spindle_taper"], s["dual_contact"]), ("Brother", "BT30", False))


class TestMachineApi(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self._settings, self._user = app_module.MACHINE_SETTINGS_PATH, mp.USER_DIR
        app_module.MACHINE_SETTINGS_PATH = os.path.join(self.tmp.name, "s.json")
        mp.USER_DIR = os.path.join(self.tmp.name, "machines")
        self.c = app_module.app.test_client()
        self.c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def tearDown(self):
        app_module.MACHINE_SETTINGS_PATH, mp.USER_DIR = self._settings, self._user
        self.tmp.cleanup()

    def test_stiffness_default_endpoint(self):
        r = self.c.get("/api/machines/stiffness_default?taper=BT40&dual_contact=0").get_json()
        self.assertTrue(r["success"])
        self.assertTrue(r["stiffness"]["derived"])
        self.assertEqual(self.c.get("/api/machines/stiffness_default?taper=nope").status_code, 400)

    def test_save_and_get_new_machine(self):
        prof = {"machine": "Haas VF-2", "brand": "Haas", "model": "VF-2", "controller": "NGC", "spindle_taper": "CAT40",
                "dual_contact": False, "spindle_options": {"main": {"max_rpm": 8100, "power_kw_continuous": 22,
                                                                   "simple": {"peak_torque_nm": 122, "base_rpm": 1200, "continuous_kw": 22}}}}
        r = self.c.post("/api/machines", json={"profile": prof}).get_json()
        self.assertTrue(r["success"], r)
        g = self.c.get(f"/api/machines/{r['id']}").get_json()
        self.assertEqual(g["stiffness_source"], "taper_default")
        self.assertEqual(g["profile"]["controller"], "NGC")
        sel = self.c.post("/api/machines/select", json={"machine_id": r["id"]}).get_json()
        self.assertTrue(sel["success"])
        cut = self.c.post("/api/calculate", json=dict(family="Aluminum - Wrought (6061)", alloy="", tool="Carbide Endmill",
                          coating="Uncoated", geometry="Square", operation="Adaptive Roughing", diameter=0.25, flutes=3,
                          aggressiveness=50, model="v2")).get_json()
        self.assertTrue(cut["success"])

    def test_page_has_v4_elements(self):
        html = self.c.get("/").get_data(as_text=True)
        for eid in ("machineSwitchTop", "machineEdBrand", "machineEdModel", "machineEdController", "machineEdTaper",
                    "machineEdDual", "machineEdStiffK", "machineEdSimpleTorque", "runoutSensCard"):
            self.assertIn(f'id="{eid}"', html, eid)
        for js in ("machine_editor_v4.js", "runout_sens_v4.js"):
            self.assertIn(js, html)


def _req():
    from pipeline import CutRequest
    geo = {"DC": 0.0625, "NOF": 3, "LCF": 0.1875, "SFDM": 0.125, "LB": 0.5}
    return CutRequest(family="Stainless - PH Series (17-4)", alloy="17-4 PH (H 1025)", tool="HP Carbide Endmill",
                      coating="AlTiN", geometry="Square", operation="Adaptive Roughing", diameter=0.0625, flutes=3,
                      aggressiveness=0.5, max_rpm=16000.0, max_hp=6.84, runout=0.0002, stickout=None,
                      fusion_tool={"type": "flat end mill", "unit": "inches", "geometry": geo})


class TestRunoutSensitivity(unittest.TestCase):
    def setUp(self):
        self.c = app_module.app.test_client()
        self.c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
        g = {"DC": 0.0625, "NOF": 3, "LCF": 0.1875, "SFDM": 0.125, "LB": 0.4}
        self.body = dict(family="Stainless - PH Series (17-4)", alloy="", tool="HP Carbide Endmill", coating="AlTiN",
                         geometry="Square", operation="Slotting", diameter=0.0625, flutes=3, fluteLength=0.1875,
                         aggressiveness=50, fusion_tool={"type": "flat end mill", "unit": "inches", "geometry": g})

    def test_endpoint_table_and_summary(self):
        r = self.c.post("/api/runout_sensitivity", json=self.body)
        self.assertEqual(r.status_code, 200, r.get_data(as_text=True))
        d = r.get_json()
        self.assertEqual([row["runout_in"] for row in d["rows"]], runout_sensitivity.DEFAULT_RUNOUTS_IN)
        for key in ("rpm", "feed_ipm", "fz_in", "ap_in", "ae_in", "mrr_in3_min", "flutes_cutting", "runout_regime",
                    "limited_by", "feasible"):
            self.assertIn(key, d["rows"][0])
        mrr = [row["mrr_in3_min"] for row in d["rows"]]
        self.assertTrue(all(a >= b - 1e-9 for a, b in zip(mrr, mrr[1:])), mrr)    # more runout never raises MRR
        self.assertGreater(mrr[0], mrr[-1])
        self.assertEqual([c["id"] for c in d["holder_classes"]],
                         ["er_standard", "er_up", "sk", "hydraulic_shrink_powrgrip", "micro_chuck"])
        self.assertTrue(d["summary"])
        std = d["holder_classes"][0]
        self.assertAlmostEqual(std["tir_in"], 0.00059)

    def test_gain_sentence_from_standard_er(self):
        d = self.c.post("/api/runout_sensitivity", json=dict(self.body, runout=0.0006, runouts=[0, 0.0006])).get_json()
        self.assertTrue(d["success"])
        self.assertEqual(d["current"]["class_id"], "er_standard")
        self.assertTrue(any("raises MRR by" in s for s in d["summary"]), d["summary"])

    def test_custom_runouts_and_errors(self):
        d = self.c.post("/api/runout_sensitivity", json=dict(self.body, runouts=[0.0001, 0.0003])).get_json()
        self.assertEqual([r["runout_in"] for r in d["rows"]], [0.0001, 0.0003])
        self.assertEqual(self.c.post("/api/runout_sensitivity", json=dict(self.body, runouts=[-1])).status_code, 400)
        self.assertEqual(self.c.post("/api/runout_sensitivity", json=dict(self.body, runouts="x")).status_code, 400)
        self.assertEqual(self.c.post("/api/runout_sensitivity", data="nope", content_type="application/json").status_code, 400)

    def test_formatting(self):
        self.assertEqual(runout_sensitivity.fmt_in(0.0002), '0.0002"')
        self.assertEqual(runout_sensitivity.fmt_in(0.00012), '0.00012"')
        self.assertEqual(runout_sensitivity.fmt_in(0), '0"')


class TestShopTSlot(unittest.TestCase):
    def test_4x05_scaled_from_8x1(self):
        tools = {t["id"]: t for t in load(os.path.join(ROOT, "data", "shop_tools.json"))["tools"]}
        a, b = tools["klot_4x0.5"], tools["fusion_klot_8x1"]
        self.assertEqual(a["geometry_basis"], "scaled from fusion_klot_8x1")
        self.assertAlmostEqual(a["neck_diameter_mm"] / a["diameter_mm"], b["neck_diameter_mm"] / b["diameter_mm"])
        self.assertAlmostEqual(a["reach_mm"] / a["diameter_mm"], b["reach_mm"] / b["diameter_mm"])
        self.assertEqual((a["coating"], a["teeth"]), ("AlTiN", 4))
        self.assertIn("reach", a["provisional"])
        self.assertIn("suspects", a["source_note"])


if __name__ == "__main__":
    unittest.main()
