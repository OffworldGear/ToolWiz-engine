"""Micro tools: shank default and warning, equivalent stickout, roughing deflection floor, runout."""
import json
import os
import tempfile
import unittest
from unittest import mock

import app
from gwizard_physics import BeamDeflectionEngine
from toolwiz_common import default_shank, shank_looks_wrong
from toolwiz_common.tool_profile import SHANK_WARNING, ToolProfile


def fusion_calc(geo, **kw):
    c = app.app.test_client()
    c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
    body = dict(family="Stainless - PH Series (17-4)", alloy="17-7 PH (Annealed)", tool="HP Carbide Endmill",
                coating="AlTiN", geometry="Square", operation="Adaptive Roughing", diameter=geo["DC"],
                flutes=geo.get("NOF", 4), aggressiveness=65,
                fusion_tool={"type": "flat end mill", "unit": "inches", "geometry": geo})
    body.update(kw)
    return c.post("/api/calculate_for_fusion", json=body).get_json()


T12_ROD = {"DC": 0.0625, "NOF": 4, "LCF": 0.1875, "SFDM": 0.0625, "LB": 0.5}
T12_STUB = dict(T12_ROD, SFDM=0.125)


class TestShank(unittest.TestCase):
    def test_default_shank(self):
        self.assertEqual(default_shank(0.03125), 0.125)
        self.assertEqual(default_shank(0.125), 0.125)
        self.assertEqual(default_shank(0.25), 0.25)

    def test_missing_fusion_shank_uses_default(self):
        geo = {k: v for k, v in T12_ROD.items() if k != "SFDM"}
        prof = ToolProfile.from_fusion({"type": "flat end mill", "unit": "inches", "geometry": geo})
        self.assertEqual(prof.geometry.shank_diameter, 0.125)

    def test_shank_equal_to_micro_diameter_is_flagged_everywhere(self):
        self.assertTrue(shank_looks_wrong(0.0625, 0.0625))
        self.assertFalse(shank_looks_wrong(0.0625, 0.125))
        self.assertFalse(shank_looks_wrong(0.125, 0.125))
        r = fusion_calc(T12_ROD)
        self.assertIn(SHANK_WARNING, r["profile"]["warnings"])
        self.assertNotIn(SHANK_WARNING, fusion_calc(T12_STUB)["profile"]["warnings"])

    def test_web_request_without_shank_uses_micro_default(self):
        c = app.app.test_client()
        c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
        r = c.post("/api/calculate", json=dict(
            family="Aluminum - Wrought (6061)", alloy="", tool="Carbide Endmill", coating="Uncoated",
            geometry="Square", operation="Adaptive Roughing", diameter=0.03125, flutes=3, fluteLength=0.09375,
            stickout=0.5, cutDepth=0.01, cutWidth=0.005, aggressiveness=50)).get_json()
        shank = [s for s in r["profile"]["segments"] if s["kind"] == "shank"]
        self.assertAlmostEqual(shank[0]["d0"], 0.125)


class TestEquivalentStickout(unittest.TestCase):
    def eq_ld(self, geo):
        prof = ToolProfile.from_fusion({"type": "flat end mill", "unit": "inches", "geometry": geo})
        return BeamDeflectionEngine.equivalent_stickout(prof.segments, geo["DC"], geo["NOF"]) / geo["DC"]

    def test_stub_on_big_shank_counts_short_and_rod_counts_full(self):
        self.assertAlmostEqual(self.eq_ld(T12_ROD), 8.0, places=6)
        self.assertLess(self.eq_ld(T12_STUB), 5.0)
        self.assertLess(self.eq_ld({"DC": 0.03125, "NOF": 3, "LCF": 0.09375, "SFDM": 0.125, "LB": 0.5}), 5.0)

    def test_long_slim_neck_counts_long(self):
        geo = {"DC": 0.0625, "NOF": 4, "LCF": 0.1875, "SFDM": 0.125, "LB": 0.6,
               "shoulder-length": 0.5, "shoulder-diameter": 0.059}
        self.assertGreater(self.eq_ld(geo), 8.0)

    def test_stub_micro_tool_keeps_its_speed(self):
        chat = next(p for p in fusion_calc(T12_STUB)["provenance"] if p["step"] == "chatter" and p["quantity"] == "sfm")
        rod = next(p for p in fusion_calc(T12_ROD)["provenance"] if p["step"] == "chatter" and p["quantity"] == "sfm")
        self.assertGreater(chat["multiplier"], 0.9)       # equivalent ~4.5xD: about -5%
        self.assertAlmostEqual(rod["multiplier"], 0.6)    # a true 1/16" rod at 8xD: -40%


class TestRoughingFloor(unittest.TestCase):
    def test_floor_scales_with_diameter_and_one_eighth_unchanged(self):
        p = app.physics
        self.assertAlmostEqual(p.calc_deflection_limit(0.125, "Standard Roughing", 0.5), 0.00035)
        for d in (0.015625, 0.03125, 0.0625):
            lim = p.calc_deflection_limit(d, "Standard Roughing", 0.5)
            self.assertLessEqual(lim, d * 0.003 + 1e-12)
            self.assertLessEqual(lim, p.calc_deflection_limit(d, "Adaptive Roughing", 0.5) + 1e-12)


class TestRunout(unittest.TestCase):
    def test_warning_when_runout_reaches_half_the_chip(self):
        hi = fusion_calc(T12_STUB, runout=0.0004)
        lo = fusion_calc(T12_STUB, runout=0.00002)
        self.assertTrue(any(a["title"] == "Runout vs Chip Load" for a in hi["alerts"]))
        self.assertFalse(any(a["title"] == "Runout vs Chip Load" for a in lo["alerts"]))

    def test_runout_is_a_machine_setting(self):
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "machine_settings.json")
            with mock.patch.object(app, "MACHINE_SETTINGS_PATH", path):
                c = app.app.test_client()
                c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
                self.assertEqual(c.get("/api/machine_limits").get_json()["runout"], app.DEFAULT_RUNOUT_IN)
                r = c.post("/api/machine_limits", json={"runout": 0.0001}).get_json()
                self.assertEqual(r["runout"], 0.0001)
                with open(path, encoding="utf-8") as fh:
                    self.assertEqual(json.load(fh)["runout"], 0.0001)
                self.assertEqual(c.post("/api/machine_limits", json={"runout": 0.01}).status_code, 400)


if __name__ == "__main__":
    unittest.main()
