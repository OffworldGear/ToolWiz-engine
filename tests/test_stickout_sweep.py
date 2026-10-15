"""Stickout sweep: behaviour that must hold as a tool is extended from 3xD to 10xD.

Milling: speeds and chipload are not penalised for stickout (GWizard only length-adjusts
drills); the deflection limit shrinks the recommended engagement instead, and the
recommended cut always stays within that limit. The web calculator and the Fusion
endpoint must agree at every stickout.
"""
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import app as app_module

LD_STEPS = (3.0, 4.0, 6.0, 8.0, 10.0)

MILLING_TOOLS = {
    "1/16in adaptive, phosphor bronze": dict(
        family="Copper Alloy - Wrought", alloy="C51000 - Phosphor Bronze 5% Sn (H02 (1/2 Hard))",
        tool="HP Carbide Endmill", coating="AlTiN", geometry="Square", operation="Adaptive Roughing",
        diameter=0.0625, flutes=4, fluteLength=0.187),
    "1/4in roughing, 4140": dict(
        family="Steel - Medium Carbon Alloy (4130)", alloy="", tool="Carbide Endmill", coating="AlTiN",
        geometry="Square", operation="Standard Roughing", diameter=0.25, flutes=4, fluteLength=0.75),
    "1/2in wall finish, 316": dict(
        family="Stainless - 300 Series (316)", alloy="", tool="HP Carbide Endmill", coating="AlTiN",
        geometry="Square", operation="Wall Finishing (Deep DOC)", diameter=0.5, flutes=5, fluteLength=1.25),
    "3mm bull nose adaptive, 6061": dict(
        family="Aluminum - Wrought (6061)", alloy="6061 (T6, T651)", tool="HP Carbide Endmill", coating="Uncoated",
        geometry="Radiused", cornerRadius=0.02, operation="Adaptive Roughing", diameter=3.0 / 25.4, flutes=3,
        fluteLength=9.0 / 25.4),
}


class StickoutSweepBase(unittest.TestCase):
    def setUp(self):
        self.client = app_module.app.test_client()
        self.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def calc(self, payload, endpoint="/api/calculate"):
        r = self.client.post(endpoint, json={"aggressiveness": 50, "maxRpm": 16000, "maxHp": 6.84, **payload})
        self.assertEqual(r.status_code, 200, r.get_data(as_text=True)[:200])
        d = r.get_json()
        self.assertTrue(d.get("success", True), d)
        return d

    @staticmethod
    def chatter_multipliers(d):
        return {p["quantity"]: p["multiplier"] for p in d.get("provenance", []) if p["step"] == "chatter"}


class TestMillingStickoutSweep(StickoutSweepBase):
    def test_speed_follows_osg_overhang_line_on_equivalent_stickout(self):
        # OSG: 100% to 4xD, then about -10% per D (4-5xD 90%, 5-6xD 80%; PHOENIX 6-10xD 40-60%),
        # applied to the stiffness-equivalent stickout (a micro tool on a 1/8" shank counts as shorter).
        from gwizard_physics import BeamDeflectionEngine
        from toolwiz_common.tool_profile import Segment
        for name, tool in MILLING_TOOLS.items():
            for ld in LD_STEPS:
                with self.subTest(tool=name, ld=ld):
                    d = self.calc({**tool, "stickout": tool["diameter"] * ld})
                    seg = [Segment(x["kind"], x["start"], x["end"], x["d0"], x["d1"], x["fluted"])
                           for x in d["profile"]["segments"]]
                    eq = BeamDeflectionEngine.equivalent_stickout(seg, tool["diameter"], tool["flutes"])
                    eld = eq / tool["diameter"]
                    expected = 1.0 if eld <= 4 else max(0.4, 1.0 - 0.1 * (eld - 4))
                    m = self.chatter_multipliers(d)
                    self.assertAlmostEqual(m.get("sfm", 1.0), expected, places=6)
                    self.assertEqual(m.get("ipt", 1.0), 1.0)
                    self.assertLessEqual(eld, ld * 1.0001)   # never longer than the real stickout here

    def test_straight_tool_equivalent_stickout_is_its_stickout(self):
        from gwizard_physics import BeamDeflectionEngine
        from toolwiz_common.tool_profile import ToolProfile
        prof = ToolProfile.from_fusion({"type": "flat end mill", "unit": "inches", "geometry": {
            "DC": 0.25, "NOF": 4, "LCF": 0.75, "SFDM": 0.25, "LB": 1.5}})
        self.assertAlmostEqual(BeamDeflectionEngine.equivalent_stickout(prof.segments, 0.25, 4), 1.5, places=9)

    def test_removal_rate_never_grows_with_stickout(self):
        # The long-reach trade may take a deeper, lighter cut (larger DOC x WOC at a lower feed), so the
        # invariant is the removal rate of the recommended cut, not its area.
        for name, tool in MILLING_TOOLS.items():
            rates = []
            for ld in LD_STEPS:
                p = {**tool, "stickout": tool["diameter"] * ld}
                rec = self.calc(p)
                applied = self.calc({**p, "cutDepth": rec["rec_doc"], "cutWidth": rec["rec_woc"]})
                rates.append(rec["rec_doc"] * rec["rec_woc"] * applied["feedrate"])
            with self.subTest(tool=name, rates=rates):
                for shorter, longer in zip(rates, rates[1:]):
                    self.assertLessEqual(longer, shorter * 1.001)

    def test_recommended_cut_stays_within_deflection_limit(self):
        for name, tool in MILLING_TOOLS.items():
            for ld in LD_STEPS:
                with self.subTest(tool=name, ld=ld):
                    p = {**tool, "stickout": tool["diameter"] * ld}
                    rec = self.calc(p)
                    applied = self.calc({**p, "cutDepth": rec["rec_doc"], "cutWidth": rec["rec_woc"]})
                    if rec.get("feasible", True):
                        self.assertLessEqual(applied["deflection"], applied["rec_limit"] * 1.005)
                    else:
                        titles = [t["title"] for t in applied["tips"]]
                        self.assertTrue(any("Infeasible" in t for t in titles), titles)

    def test_web_and_fusion_agree_at_every_stickout(self):
        for name, tool in MILLING_TOOLS.items():
            for ld in LD_STEPS:
                with self.subTest(tool=name, ld=ld):
                    p = {**tool, "stickout": tool["diameter"] * ld}
                    fusion = self.calc(p, "/api/calculate_for_fusion")
                    # Same engagement on both sides (Fusion applies the recommended DOC/WOC,
                    # which it rounds to 3 decimals, hence the 2% tolerance).
                    web = self.calc({**p, "cutDepth": fusion["doc"], "cutWidth": fusion["woc"]})
                    self.assertAlmostEqual(fusion["rpm"], web["rpm"], delta=max(web["rpm"] * 0.02, 1))
                    self.assertAlmostEqual(fusion["ipt"], web["adj_ipt"], delta=web["adj_ipt"] * 0.02)

    def test_long_carbide_stickout_warns(self):
        tool = MILLING_TOOLS["1/4in roughing, 4140"]
        short = [t["title"] for t in self.calc({**tool, "stickout": 0.25 * 3})["tips"]]
        long = [t["title"] for t in self.calc({**tool, "stickout": 0.25 * 8})["tips"]]
        self.assertFalse(any("Stickout" in t for t in short if "Extended" not in t), short)
        self.assertTrue(any("Stickout" in t for t in long), long)


class TestDrillStickoutSweep(StickoutSweepBase):
    def test_drills_keep_length_penalty_beyond_8xd(self):
        drill = dict(family="Steel - Medium Carbon Alloy (4130)", alloy="", tool="HP Carbide Twist Drill",
                     coating="AlTiN", geometry="Drill", operation="Drilling", diameter=0.25, flutes=2,
                     fluteLength=1.5, cutDepth=0.75)
        short = self.calc({**drill, "stickout": 0.25 * 6})
        long = self.calc({**drill, "stickout": 0.25 * 10})
        self.assertEqual(self.chatter_multipliers(short).get("ipt", 1.0), 1.0)
        self.assertLess(self.chatter_multipliers(long).get("ipt", 1.0), 1.0)


if __name__ == "__main__":
    unittest.main()
