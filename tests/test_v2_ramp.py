"""v2 helical ramp entry (physics_v2/ramp.py): geometry, consensus lookup, optimize_ramp limits, bridge and endpoint."""
import math
import os
import sys
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)

from physics_v2 import optimize as o  # noqa: E402
from physics_v2 import params  # noqa: E402
from physics_v2 import ramp  # noqa: E402

FAM = "Stainless - PH Series (17-4)"
FAST = dict(n_alpha=10, n_dh=2, n_theta=48, n_quad=24, n_theta_final=72, n_quad_final=24)


def t12():
    return o.Tool.build(0.0625, 4, 0.1875, 0.5, shank=0.125, label="T12")


class TestGeometry(unittest.TestCase):
    def test_pitch_and_angle_are_inverse(self):
        p = ramp.pitch(0.05, 3.0)
        self.assertAlmostEqual(p, math.pi * 0.05 * math.tan(math.radians(3.0)))
        self.assertAlmostEqual(ramp.angle_for_pitch(0.05, p), 3.0)

    def test_sandvik_toolguide_345hb_pitch(self):
        # 2 mm tool in a 4 mm hole: helix 2 mm; RMP 4.852° gives the printed AP 0.021" per turn.
        self.assertAlmostEqual(ramp.pitch(2.0, 4.852) / 25.4, 0.021, places=4)

    def test_end_chip_is_descent_per_tooth(self):
        self.assertAlmostEqual(ramp.end_chip(0.0003, 4.852), 0.0003 * math.sin(math.radians(4.852)))
        self.assertAlmostEqual(ramp.end_chip(0.001, 90.0), 0.001)    # a plunge

    def test_bore_core_and_side_depth(self):
        D = 0.1
        self.assertAlmostEqual(ramp.bore_diameter(D, 0.5 * D), 1.5 * D)
        self.assertEqual(ramp.core_diameter(D, 0.8 * D), 0.0)
        self.assertAlmostEqual(ramp.core_diameter(D, 1.4 * D), 0.4 * D)
        for dh, share in ((0.5, 0.625), (1.0, 0.75)):
            p = ramp.pitch(dh * D, 4.0)
            self.assertAlmostEqual(ramp.side_equivalent_depth(D, dh * D, 4.0) / p, share, places=9)
        self.assertAlmostEqual(ramp.side_equivalent_depth(D, 1e-12, 4.0), 0.0, places=9)   # plunge: end only

    def test_end_torque_matches_power_balance(self):
        # T·ω = kc·h·(end MRR): z·kc·h·R²/2·ω = kc·h·(πR²)·(z·n)·... (per radian: z·kc·h·R²/2)
        coeffs = params.material(FAM, hb=356.0).coefficients()
        h, D, z = 0.0006, 1.5875, 4
        tq = ramp.end_torque_nm(h, D, z, coeffs)
        n = 1000.0
        p_w = tq * 2 * math.pi * n / 60.0
        mrr_mm3_s = h * z * n / 60.0 * math.pi * (D / 2) ** 2
        self.assertAlmostEqual(p_w, coeffs.kc(h) * mrr_mm3_s / 1000.0, places=9)


class TestConsensusLookup(unittest.TestCase):
    TABLE = {"consensus": {"min_vendor_groups": 2, "hb_bin": 50,
                           "bands": [{"band": "a", "d_min": 0.0, "d_max": 0.1}, {"band": "b", "d_min": 0.1, "d_max": 0.2}],
                           "cells": {f"{FAM}|7|a": {"G1": [[3.0, None, None, None, None]]},
                                     f"{FAM}|7|b": {"G2": [[5.0, 1.3, None, None, 0.25]]},
                                     f"{FAM}|x|a": {"G3": [[1.0, 1.1, None, None, None]]}}}}

    def test_widens_stepwise_to_two_groups(self):
        c = ramp.consensus_lookup(self.TABLE, FAM, 356.0, 0.0625)
        self.assertEqual(c["angle_deg"]["widening"], "+ neighbouring diameter band")
        self.assertEqual(c["angle_deg"]["median"], 4.0)
        self.assertEqual(sorted(c["angle_deg"]["group_medians"]), ["G1", "G2"])
        # the hole minimum only reaches 2 groups once the no-hardness bin joins
        self.assertEqual(c["hole_min_over_D"]["widening"], "+ neighbouring hardness bin")
        self.assertNotIn("plunge_feed_factor", c)        # one group only, even family-wide

    def test_none_without_table(self):
        self.assertEqual(ramp.consensus_lookup(None, FAM, 356.0, 0.0625), {})


class TestOptimizeRamp(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mat = params.material(FAM, hb=356.0)
        cls.mach = params.machine()
        cls.r50 = ramp.optimize_ramp(t12(), cls.mat, cls.mach, 0.5, consensus=params.CONSENSUS_PATH, **FAST)
        cls.r75 = ramp.optimize_ramp(t12(), cls.mat, cls.mach, 0.75, consensus=params.CONSENSUS_PATH, **FAST)

    def test_feasible_with_all_outputs(self):
        for r in (self.r50, self.r75):
            self.assertTrue(r["feasible"], r.get("violated"))
            for k in ("ramp_angle_deg", "helix_diameter_in", "helix_min_diameter_in", "rpm", "ramp_feed_ipm",
                      "plunge_feed_ipm", "binding", "provenance"):
                self.assertIn(k, r)
            self.assertTrue(r["provenance"])

    def test_physics_limits_hold(self):
        for r in (self.r50, self.r75):
            c = r["checks"]
            for k in ("R1", "R1p", "C1", "C2", "C3", "C4", "C5", "C8"):
                if c[k]["applies"]:
                    self.assertTrue(c[k]["ok"], (k, c[k]["detail"]))
            self.assertGreaterEqual(r["end_chip_in"], r["end_chip_floor_in"] * (1 - 1e-9))

    def test_feeds_follow_the_geometry(self):
        for r in (self.r50, self.r75):
            self.assertAlmostEqual(r["ramp_feed_ipm"], r["fz_in"] * 4 * r["rpm"], places=6)
            self.assertAlmostEqual(r["end_chip_in"], r["fz_in"] * math.sin(math.radians(r["ramp_angle_deg"])))
            self.assertAlmostEqual(r["descent_ipm"], r["end_chip_in"] * 4 * r["rpm"], places=6)
            self.assertAlmostEqual(r["pitch_in"], ramp.pitch(r["helix_diameter_in"], r["ramp_angle_deg"]))
            self.assertLessEqual(r["rpm"], self.mach.max_rpm)
            self.assertLessEqual(r["helix_diameter_over_D"], ramp.DH_MAX_OVER_D + 1e-9)
            self.assertGreaterEqual(r["helix_diameter_in"], r["helix_min_diameter_in"] - 1e-12)

    def test_aggressiveness_raises_speed_and_chip_not_physics(self):
        self.assertGreaterEqual(self.r75["rpm"], self.r50["rpm"])
        self.assertGreaterEqual(self.r75["fz_in"], self.r50["fz_in"] * (1 - 1e-6))
        self.assertAlmostEqual(self.r75["end_chip_floor_in"], self.r50["end_chip_floor_in"])   # λ fixed

    def test_vendor_cap_never_overrides_the_rubbing_floor(self):
        # A micro tool in 17-4 H1025: the vendor angle cap would leave the end teeth under λ·r_β, so R1 wins and the
        # conflict is reported.
        r = self.r50
        if "R14a" in r["overridden"]:
            self.assertGreater(r["ramp_angle_deg"], r["checks"]["R14a"]["limit"])
            self.assertTrue(any("R14a" in c for c in r["conflicts"]))
            self.assertIn("R1", r["binding"])

    def test_empty_end_chip_window_uses_the_floor(self):
        tab = {"end_chip": {"bands": [{"band": "all", "d_min": 0.0, "d_max": 1e9, "h_a_over_D": 1e-6, "n": 1,
                                       "groups": ["X"]}]}, "consensus": None}
        r = ramp.optimize_ramp(t12(), self.mat, self.mach, 0.5, table=tab, consensus=params.CONSENSUS_PATH, **FAST)
        self.assertIn("R2", r["overridden"])
        self.assertGreaterEqual(r["end_chip_in"], r["end_chip_floor_in"] * (1 - 1e-9))
        self.assertTrue(r["feasible"])

    def test_without_data_r2_and_r14_are_inactive(self):
        r = ramp.optimize_ramp(t12(), self.mat, self.mach, 0.5, table=None, **FAST)
        self.assertFalse(r["checks"]["R2"]["applies"])
        self.assertFalse(r["checks"]["R14a"]["applies"])
        self.assertTrue(any("R2 inactive" in w for w in r["warnings"]))


class TestCalibratedTable(unittest.TestCase):
    def test_ramp_json_has_r2_bands_and_consensus(self):
        tab = ramp.load_table()
        self.assertIsNotNone(tab, "data/model_v2/ramp.json (tools/calibrate_v2_ramp.py)")
        bands = tab["end_chip"]["bands"]
        self.assertTrue(bands)
        for b in bands:
            self.assertGreaterEqual(len(b["groups"]), 2)
            self.assertGreater(b["h_a_over_D"], 0)
        c = ramp.consensus_lookup(tab, FAM, 356.0, 0.125)
        self.assertGreaterEqual(len(c["angle_deg"]["group_medians"]), 2)


class TestBridge(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        import app
        from test_v2_bridge import req
        from pipeline import run_cut
        cls.app = app
        cls.v1 = run_cut(app.physics, req())
        cls.v2 = run_cut(app.physics, req(model="v2"))

    def test_v1_unchanged(self):
        r = self.v1
        self.assertIsNone(r.ramp_diameter)
        self.assertIsNone(r.ramp_rpm)
        angle, feed, plunge = self.app.physics.calc_ramping(FAM, r.diameter, r.feed_ipm, "Square", 4, 0.5,
                                                           tool_type="HP Carbide Endmill")
        self.assertAlmostEqual(r.ramp_angle, angle)
        self.assertAlmostEqual(r.ramp_feed, feed)
        self.assertAlmostEqual(r.plunge_feed, plunge)

    def test_v2_carries_the_ramp_model(self):
        r = self.v2
        rp = r.v2["ramp"]
        self.assertTrue(rp["feasible"])
        self.assertAlmostEqual(r.ramp_angle, rp["ramp_angle_deg"])
        self.assertAlmostEqual(r.ramp_feed, rp["ramp_feed_ipm"])
        self.assertAlmostEqual(r.plunge_feed, rp["plunge_feed_ipm"])
        self.assertAlmostEqual(r.ramp_diameter, rp["helix_diameter_in"])
        self.assertAlmostEqual(r.ramp_rpm, rp["rpm"])
        self.assertIn("R1", rp["checks"])

    def test_fusion_endpoint_returns_ramp_fields(self):
        from test_v2_bridge import T12
        c = self.app.app.test_client()
        c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
        body = dict(family=FAM, alloy="17-4 PH (H 1025)", tool="HP Carbide Endmill", coating="AlTiN",
                    geometry="Square", operation="Adaptive Roughing", diameter=0.0625, flutes=4, aggressiveness=50,
                    fusion_tool={"type": "flat end mill", "unit": "inches", "geometry": T12})
        v1 = c.post("/api/calculate_for_fusion", json=body).get_json()
        v2 = c.post("/api/calculate_for_fusion", json=dict(body, model="v2")).get_json()
        for k in ("ramp_angle", "ramp_diameter_in", "ramp_min_diameter_in", "ramp_rpm", "ramp_feed", "plunge_feed"):
            self.assertIn(k, v1)
            self.assertIn(k, v2)
        self.assertIsNone(v1["ramp_diameter_in"])
        self.assertAlmostEqual(v2["ramp_angle"], v2["v2"]["ramp"]["ramp_angle_deg"], places=2)
        self.assertAlmostEqual(v2["ramp_diameter_in"], v2["v2"]["ramp"]["helix_diameter_in"], places=5)


if __name__ == "__main__":
    unittest.main()
