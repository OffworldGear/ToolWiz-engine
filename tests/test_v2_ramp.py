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
FAST = dict(n_alpha=10, n_dh=2, n_theta=48, n_quad=24, n_theta_final=72, n_quad_final=24)   # for the exhaustive runs


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
        cls.r50 = ramp.optimize_ramp(t12(), cls.mat, cls.mach, 0.5, consensus=params.CONSENSUS_PATH, coating="AlTiN")
        cls.r75 = ramp.optimize_ramp(t12(), cls.mat, cls.mach, 0.75, consensus=params.CONSENSUS_PATH, coating="AlTiN")

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
            for k in ("C1", "C2", "C3", "C4", "C5", "C8", "R2", "R6"):
                if c[k]["applies"]:
                    self.assertTrue(c[k]["ok"], (k, c[k]["detail"]))
            for k in ("R1", "R1p"):     # enforced, or a reported warning when a vendor cap wins (D2)
                self.assertTrue(c[k]["ok"] or k in r["warned"], (k, c[k]["detail"]))

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

    def test_vendor_cap_wins_over_the_rubbing_floor(self):
        # User decision 2026-10-18 (D2): T12 in 17-4 H1025 (AlTiN, r_β 1.2 µm) can't meet λ·r_β under the vendor cap,
        # so the cap holds and R1 is a reported warning.
        for r in (self.r50, self.r75):
            self.assertTrue(r["feasible"])
            self.assertLessEqual(r["ramp_angle_deg"], r["checks"]["R14a"]["limit"] * (1 + 1e-9))
            self.assertNotIn("R14a", r["overridden"])
        r = self.r50
        self.assertTrue(r["r1_warning"])
        self.assertIn("R1", r["warned"])
        self.assertNotIn("R1", r["violated"])
        self.assertLess(r["end_chip_in"], r["end_chip_floor_in"])
        self.assertTrue(any(w.startswith("WARNING: the end teeth") for w in r["warnings"]))

    def test_sourced_edge_radius(self):
        self.assertAlmostEqual(self.r50["edge_radius_mm"], 0.0012)            # AlTiN micro, Liang 2018
        self.assertAlmostEqual(ramp.edge_radius(0.0625, "AlTiN")[0], 0.0012)
        self.assertAlmostEqual(ramp.edge_radius(0.125, "AlCrN")[0], 0.0009)
        self.assertAlmostEqual(ramp.edge_radius(0.0625, "Uncoated")[0], 0.0015)
        self.assertAlmostEqual(ramp.edge_radius(0.0625, "TiN")[0], 0.0015)
        self.assertAlmostEqual(ramp.edge_radius(0.5, "AlTiN")[0], 0.0035)     # Wojciechowski 2024, 8 mm
        mid = ramp.edge_radius(0.1875, "AlTiN")[0]
        self.assertTrue(0.0012 < mid < 0.0035)
        r = ramp.optimize_ramp(t12(), self.mat, self.mach, 0.5, consensus=params.CONSENSUS_PATH, edge_radius_mm=0.0004)
        self.assertAlmostEqual(r["edge_radius_mm"], 0.0004)
        self.assertEqual(r["edge_radius_basis"], "given")
        self.assertFalse(r["r1_warning"])                                     # 0.12 µm floor is met under the cap

    def test_feeds_at_the_operation_rpm(self):
        # D4: Fusion ramps at the cutting speed; fz and α are chosen at C7's speed, the feeds are at op_rpm.
        r = ramp.optimize_ramp(t12(), self.mat, self.mach, 0.5, consensus=params.CONSENSUS_PATH, coating="AlTiN",
                               op_rpm=11291.0, op_feed_ipm=13.77)
        self.assertAlmostEqual(r["fz_in"], self.r50["fz_in"], places=9)
        self.assertAlmostEqual(r["ramp_angle_deg"], self.r50["ramp_angle_deg"], places=9)
        self.assertEqual(r["spindle_rpm"], 11291.0)
        self.assertAlmostEqual(r["ramp_feed_ipm"], r["fz_in"] * 4 * 11291.0, places=6)
        self.assertAlmostEqual(r["ramp_feed_at_c7_rpm_ipm"], r["fz_in"] * 4 * r["rpm"], places=6)
        self.assertIn("11291 rpm", r["checks"]["C5"]["detail"])
        self.assertTrue(any("above C7's slot-engagement speed" in w for w in r["warnings"]))
        self.assertIn("feed height", r["plunge_note"])

    def test_fast_search_matches_exhaustive(self):
        import time
        kw = dict(consensus=params.CONSENSUS_PATH, coating="AlTiN", **FAST)
        t0 = time.time()
        f = ramp.optimize_ramp(t12(), self.mat, self.mach, 0.5, method="fast", **kw)
        dt = time.time() - t0
        x = ramp.optimize_ramp(t12(), self.mat, self.mach, 0.5, method="exhaustive", **kw)
        self.assertAlmostEqual(f["ramp_angle_deg"], x["ramp_angle_deg"], places=2)
        self.assertAlmostEqual(f["helix_diameter_over_D"], x["helix_diameter_over_D"], places=6)
        for k in ("fz_in", "ramp_feed_ipm", "plunge_feed_ipm"):
            self.assertAlmostEqual(f[k] / x[k], 1.0, places=3, msg=k)
        self.assertEqual(f["binding"], x["binding"])
        self.assertLess(dt, 1.5)    # ~0.1 s; guards against a return to the multi-second brute-force search

    def test_empty_end_chip_window_uses_the_floor(self):
        tab = {"end_chip": {"bands": [{"band": "all", "d_min": 0.0, "d_max": 1e9, "h_a_over_D": 1e-6, "n": 1,
                                       "groups": ["X"]}]}, "consensus": None}
        r = ramp.optimize_ramp(t12(), self.mat, self.mach, 0.5, table=tab, consensus=params.CONSENSUS_PATH)
        self.assertIn("R2", r["overridden"])         # no vendor angle: physics, R1's floor wins over R2
        self.assertTrue(any("physics-only" in p for p in r["provenance"]))
        self.assertGreaterEqual(r["end_chip_in"], r["end_chip_floor_in"] * (1 - 1e-9))
        self.assertTrue(r["feasible"])

    def test_without_data_r2_and_r14_are_inactive(self):
        r = ramp.optimize_ramp(t12(), self.mat, self.mach, 0.5, table=None)
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


AL = "Aluminum - Wrought (6061)"
TI = "Titanium Alloy"
ST = "Steel - Medium Carbon Alloy (4130)"
HB = {AL: 150.0, TI: 334.0, FAM: 356.0, ST: 217.0}
# The engine before the R14a fix (2026-11-13 owner report; Speedio, AlTiN, 1/4" 4FL 2xD, optimize_ramp at C7's speed is
# close to the bridge): 7075 18.2 / 18.8 deg at 50 / 60 %; Ti 4.10 / 4.24, 17-4 H1025 2.73 / 2.83, 4130 4.55 / 4.71.
BEFORE_50_60 = {TI: (4.10, 4.24), FAM: (2.73, 2.83), ST: (4.55, 4.71)}


def _ramp(D, z, lcf, family, a, brand=None, shank=None, stickout=None):
    tool = o.Tool.build(D, z, lcf, stickout or lcf + 0.5, shank=shank or D)
    mat = params.material(family, hb=HB[family], coating="AlTiN")
    return ramp.optimize_ramp(tool, mat, params.machine(), a, coating="AlTiN", brand=brand, **params.ramp_defaults())


class TestAngleLookupRules(unittest.TestCase):
    """R14a's selection on a synthetic table: brand -> Harvey + Helical -> consensus, flute and reach coverage, larger-tool
    rows, a missing chart."""
    BANDS = [{"band": "s", "d_min": 0.0, "d_max": 0.1}, {"band": "m", "d_min": 0.1, "d_max": 0.4},
             {"band": "l", "d_min": 0.4, "d_max": 1e9}]

    def table(self):
        def row(lo, hi, z, reach, D, rid, derived=0):
            return [lo, 0.5 * (lo + hi), hi, z, reach, D, derived, rid]
        return {"angle": {"bands": self.BANDS, "hb_bin": 50, "min_vendor_groups": 2, "default_sources": ["harvey", "helical"],
                          "max_only_rule": {"text": "bottom = 0.50 × max"},
                          "vendors": {
                              "sandvik": {"group": "Sandvik", "cells": {"A|x|m": [row(10, 20, 3, 1.5, 0.25, "s15", 1),
                                                                                   row(10, 20, 3, 2.17, 0.25, "s2", 1),
                                                                                   row(2.5, 5, 3, 3.0, 0.25, "s3", 1)]}},
                              "helical": {"group": "Harvey Performance", "cells": {"A|x|m": [row(3, 10, 5, 2.0, 0.25, "h5"),
                                                                                            row(3, 10, 3, 2.0, 0.25, "h3")]}},
                              "yg1": {"group": "YG-1", "cells": {"A|x|m": [row(10, 20, 3, 2.0, 0.25, "y", 1)],
                                                                "B|x|l": [row(4, 8, 4, 2.0, 0.5, "yb", 1)]}},
                              "osg": {"group": "OSG", "cells": {"B|x|l": [row(2, 6, 4, 2.0, 0.5, "ob")]}}}}}

    def test_brand_first_then_default(self):
        t = self.table()
        b = ramp.angle_lookup(t, "sandvik", "A", None, 0.25, 3, 1.5)
        self.assertEqual((b["mode"], b["range"], b["row_ids"]), ("brand", (10, 15, 20), ["s15"]))
        b = ramp.angle_lookup(t, None, "A", None, 0.25, 3, 1.5)
        self.assertEqual((b["mode"], b["vendor"]), ("default", "helical"))
        self.assertEqual(b["range"], (3, 6.5, 10))
        self.assertAlmostEqual(ramp.angle_cap(b, 0.5), 6.5)
        self.assertAlmostEqual(ramp.angle_cap(b, 1.0), 10)
        self.assertIn("no brand given", ramp.angle_text(b, 0.5))

    def test_reach_class(self):
        t = self.table()
        self.assertEqual(ramp.angle_lookup(t, "sandvik", "A", None, 0.25, 3, 2.0)["row_ids"], ["s2"])
        b = ramp.angle_lookup(t, "sandvik", "A", None, 0.25, 3, 3.0)
        self.assertEqual((b["row_ids"], b["range"][2]), (["s3"], 5))

    def test_more_flutes_than_the_brand_charts_falls_back(self):
        b = ramp.angle_lookup(self.table(), "sandvik", "A", None, 0.25, 4, 1.5)
        self.assertEqual((b["mode"], b["row_ids"]), ("default", ["h5"]))
        self.assertIn("up to 3 flutes", b["brand_missing"])

    def test_no_covering_chart_takes_the_bottom(self):
        b = ramp.angle_lookup(self.table(), None, "A", None, 0.25, 6, 2.0)   # nobody charts 6 flutes
        self.assertTrue(b["uncovered"])
        self.assertEqual(ramp.angle_cap(b, 1.0), b["range"][0])
        self.assertIn("bottom of their range", ramp.angle_text(b, 1.0))

    def test_larger_tool_rows_only_take_the_bottom(self):
        b = ramp.angle_lookup(self.table(), None, "B", None, 0.0625, 4, 2.0)
        self.assertEqual(b["mode"], "consensus")
        self.assertTrue(b["larger_only"])
        for a in (0.0, 0.5, 1.0):
            self.assertEqual(ramp.angle_cap(b, a), 2)
        self.assertIn("larger tools only", ramp.angle_text(b, 0.5))
        self.assertIsNone(ramp.angle_lookup(self.table(), None, "C", None, 0.25, 4, 2.0))


class TestCalibratedAngleTable(unittest.TestCase):
    def test_max_only_rule_is_fitted_from_published_ranges(self):
        rule = ramp.load_table()["angle"]["max_only_rule"]
        self.assertTrue(rule["fitted"])
        self.assertGreaterEqual(rule["rows"], 20)
        self.assertGreaterEqual(len(rule["groups"]), 2)
        self.assertTrue(0.0 < rule["lo_over_hi"] < 1.0)

    def test_rows_carry_lo_mid_hi(self):
        for v in ramp.load_table()["angle"]["vendors"].values():
            for rows in v["cells"].values():
                for r in rows:
                    self.assertLessEqual(r[0], r[1])
                    self.assertLessEqual(r[1], r[2])


class TestVendorRampAngle(unittest.TestCase):
    """The owner's 2026-11-13 report: a generic 4-flute AlTiN end mill in 7075 got 18.2-18.8 deg (a vendor maximum for
    3-flute aluminium tools, used near 50 %)."""

    def test_unbranded_4fl_aluminium_is_in_the_harvey_helical_range(self):
        for D in (0.25, 0.125):
            r50 = _ramp(D, 4, 2 * D, AL, 0.5)
            self.assertTrue(r50["feasible"])
            self.assertEqual(r50["angle_basis"]["mode"], "default")
            self.assertEqual(r50["angle_basis"]["range_deg"], [3.0, 6.5, 10.0])
            self.assertTrue(3.0 * 0.95 <= r50["ramp_angle_deg"] <= 6.5 + 1e-6, r50["ramp_angle_deg"])
            self.assertIn("no brand given", r50["checks"]["R14a"]["detail"])
            self.assertLessEqual(_ramp(D, 4, 2 * D, AL, 1.0)["ramp_angle_deg"], 10.0 + 1e-6)

    def test_sandvik_short_tool_reaches_its_top_only_at_100(self):
        top = 20.0
        for a in (0.0, 0.5, 0.75):
            r = _ramp(0.25, 3, 0.375, AL, a, brand="sandvik")
            self.assertEqual(r["angle_basis"]["mode"], "brand")
            self.assertLessEqual(r["ramp_angle_deg"], o.range_at(r["angle_basis"]["range_deg"], a) + 1e-6)
            self.assertLess(r["ramp_angle_deg"], top)
        self.assertLessEqual(_ramp(0.25, 3, 0.375, AL, 1.0, brand="sandvik")["ramp_angle_deg"], top + 1e-6)

    def test_long_reach_row_limits_the_long_tool(self):
        for a in (0.5, 1.0):
            r = _ramp(0.25, 3, 0.75, AL, a, brand="sandvik")       # 3·D: Sandvik's 1K253 row, 5 deg maximum
            self.assertLessEqual(r["ramp_angle_deg"], 5.0 + 1e-6)
            self.assertAlmostEqual(r["angle_basis"]["row_reach_over_D"][0], 3.0, places=6)

    def test_monotonic_in_aggressiveness(self):
        for fam, brand, z in ((AL, None, 4), (AL, "sandvik", 3), (FAM, None, 4), (TI, None, 4)):
            rs = [_ramp(0.25, z, 0.5 if z == 4 else 0.375, fam, a, brand=brand) for a in (0.0, 0.25, 0.5, 0.75, 1.0)]
            caps = [r["checks"]["R14a"]["limit"] for r in rs]
            angles = [r["ramp_angle_deg"] for r in rs]
            for x, y in zip(caps, caps[1:]):
                self.assertLessEqual(x, y * (1 + 1e-9), (fam, brand, caps))     # the vendor cap: strictly monotone
            for (x, y, ry) in zip(angles, angles[1:], rs[1:]):
                # the angle too, except where a physics limit (not R14a) takes over at the higher setting: Sandvik's
                # 1.5·D aluminium tool at 100 % stops at R2 (end-edge chip) at 16.9 deg against 17.1 at 75 %
                # (fz rises, so the end chip fz·sin α reaches R2 at a slightly smaller angle)
                if y < x * (1 - 1e-6):
                    self.assertNotIn("R14a", ry["binding"], (fam, brand, angles))
                    self.assertIn("R2", ry["binding"], (fam, brand, angles))
                    self.assertGreater(ry["descent_ipm"], 0)

    def test_hard_materials_do_not_rise_at_the_working_settings(self):
        # At 50 % and 60 % the new ranges are at or under the old consensus caps; at 100 % titanium may reach the
        # consensus top (5.5 deg, median of the groups' maxima) against 4.9 before: the range rule's top, reported.
        for fam, before in BEFORE_50_60.items():
            for a, old in zip((0.5, 0.6), before):
                self.assertLessEqual(_ramp(0.25, 4, 0.5, fam, a)["ramp_angle_deg"], old + 0.01, (fam, a))
            r = _ramp(0.25, 4, 0.5, fam, 1.0)
            self.assertLessEqual(r["ramp_angle_deg"], r["angle_basis"]["range_deg"][2] + 1e-6)

    def test_micro_tool_angle_not_above_the_larger_tool(self):
        for fam in (FAM, TI):
            for a in (0.5, 1.0):
                big = _ramp(0.25, 4, 0.5, fam, a)["ramp_angle_deg"]
                for D, z, so in ((0.0625, 4, 0.25), (0.0625, 2, 0.25), (0.03125, 4, 0.15), (0.03125, 2, 0.15)):
                    r = _ramp(D, z, 3 * D, fam, a, shank=0.125, stickout=so)
                    self.assertLessEqual(r["ramp_angle_deg"], big + 1e-6, (fam, D, z, a))
                    self.assertLessEqual(r["ramp_angle_deg"], 3.0 + 1e-6, (fam, D, z, a))

    def test_micro_tool_reading_larger_tool_rows_takes_the_bottom(self):
        # Titanium: no vendor charts a ramp angle under 1/8"; 1/32" in 17-4: Harvey + Helical chart 1/16" and up.
        for fam, D in ((TI, 0.0625), (TI, 0.03125), (FAM, 0.03125)):
            for a in (0.5, 1.0):
                r = _ramp(D, 4, 3 * D, fam, a, shank=0.125, stickout=0.25)
                b = r["angle_basis"]
                self.assertTrue(b["larger_only"], (fam, D))
                self.assertAlmostEqual(r["checks"]["R14a"]["limit"], b["range_deg"][0])
                self.assertIn("larger tools only", r["checks"]["R14a"]["detail"])

    def test_side_cut_is_the_slot_cut(self):
        # flute-aware chip load (C2 × F(z)) and chip space C15 on the full-width side cut, as the slot cut has them
        r3, r4 = _ramp(0.25, 3, 0.5, AL, 0.5), _ramp(0.25, 4, 0.5, AL, 0.5)
        self.assertIn("C15", r4["checks"])
        self.assertTrue(r4["checks"]["C15"]["applies"])
        self.assertGreater(r3["side_flute_factor"], r4["side_flute_factor"])
        self.assertIn("for 3 flutes", r3["checks"]["C2"]["detail"])


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
        # v1 ramps from the un-thinned chip load, so it is never above the fraction of the thinned feed
        self.assertLessEqual(r.ramp_feed, feed + 1e-9)
        self.assertLessEqual(r.plunge_feed, plunge + 1e-9)
        self.assertGreater(r.ramp_feed, 0.0)

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
        # D4: ramp feed at the cutting rpm (Fusion's ramp spindle speed = spindle speed); ramp_rpm is information
        self.assertAlmostEqual(rp["spindle_rpm"], r.rpm)
        self.assertAlmostEqual(r.ramp_feed, rp["fz_in"] * 4 * r.rpm, places=6)
        self.assertAlmostEqual(rp["edge_radius_mm"], 0.0012)       # AlTiN request → Liang 2018 micro value (D1)
        # D6: the plunge-feed note reaches Fusion
        self.assertTrue(any(t["title"] == "Plunge feed" and "feed height" in t["message"] for t in r.tips))
        # which chart set the angle, in plain words, in the ramp block and the v2 result
        self.assertTrue(r.v2["ramp_basis"].startswith("Ramp angle from "))
        self.assertEqual(rp["angle_basis"]["text"], r.v2["ramp_basis"])
        self.assertIn("C15", rp["checks"])

    def test_cache_key_has_the_ramp_inputs(self):
        import json
        import v2_bridge
        from test_v2_bridge import req
        from pipeline import _normalize
        r = _normalize(req(model="v2"))
        k = json.loads(v2_bridge._cache_key(r, "adaptive", 356.0, params.machine(), {}))
        for f in ("rp", "brand", "z", "d", "prof", "a", "fam", "hb"):
            self.assertIn(f, k)
        self.assertEqual(k["rp"], ramp.load_table()["version"])

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
