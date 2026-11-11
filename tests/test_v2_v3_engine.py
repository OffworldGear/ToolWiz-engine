"""V3 engine changes (WP-A1): reduced-flute regime, diameter-scaled C3, engagement envelope and chip floor,
consensus-anchored selection, the user-engagement path and the new result fields."""
import json
import os
import sys
import unittest

import app
from physics_v2 import optimize as o
from physics_v2 import params
from pipeline import CutRequest, run_cut

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import v2_invariants  # noqa: E402

AL = "Aluminum - Wrought (6061)"
ST = "Steel - Medium Carbon Alloy (4130)"


def req(d=0.0625, z=2, family=AL, op="Adaptive Roughing", coating="Uncoated", **kw):
    base = dict(family=family, alloy="", tool="HP Carbide Endmill", coating=coating, geometry="Square", operation=op,
                diameter=d, flutes=z, flute_length=3 * d, shank_diameter=max(d, 0.125), helix_angle=35.0,
                stickout=max(0.5, 3.5 * d), aggressiveness=0.5, max_rpm=16000.0, max_hp=10.0, runout=0.0002,
                model="v2")
    base.update(kw)
    return CutRequest(**base)


def tool_material(d=0.0625, z=2, family=AL):
    tool = o.Tool.build(d, z, 3 * d, max(0.5, 3.5 * d), shank=max(d, 0.125), helix_deg=35.0)
    return tool, params.material(family)


class TestC3Allowance(unittest.TestCase):
    def test_k_coefficients(self):
        self.assertAlmostEqual(params.c3_k(0.0), 0.005)
        self.assertAlmostEqual(params.c3_k(0.5), 0.010)
        self.assertAlmostEqual(params.c3_k(1.0), 0.015)

    def test_sixteenth_inch_allowance_is_the_diameter_term(self):
        tool, mat = tool_material(0.0625)
        ctx = o._Context(tool, mat, params.machine(), "adaptive", params.margins(0.5))
        self.assertAlmostEqual(ctx.delta_allow, 0.000625, places=7)

    def test_quarter_inch_is_also_the_diameter_term(self):
        tool, mat = tool_material(0.25, 4)
        ctx = o._Context(tool, mat, params.machine(), "adaptive", params.margins(0.5))
        self.assertAlmostEqual(ctx.delta_allow, 0.0025, places=7)

    def test_finishing_keeps_the_wall_tolerance(self):
        tool, mat = tool_material(0.0625)
        ctx = o._Context(tool, mat, params.machine(), "finish", params.margins(0.5))
        self.assertAlmostEqual(ctx.delta_allow, o.WALL_TOLERANCE_IN)


class TestEnvelopeFile(unittest.TestCase):
    def test_file_matches_the_generator(self):
        with open(o.ENVELOPE_DEFAULT_PATH, encoding="utf-8") as fh:
            on_disk = json.load(fh)
        fresh = json.loads(json.dumps(v2_invariants.engagement_envelope()))
        self.assertEqual(on_disk, fresh)

    def test_every_bucket_filled_with_quartiles_in_order(self):
        with open(o.ENVELOPE_DEFAULT_PATH, encoding="utf-8") as fh:
            table = json.load(fh)
        self.assertEqual(len(table["buckets"]), 5 * 5 * 6)
        for key, b in table["buckets"].items():
            self.assertIsNotNone(b, key)
            self.assertGreaterEqual(b["n"], table["min_rows"], key)
            for what in ("ap_over_D", "ae_over_D"):
                q = b[what]
                self.assertLessEqual(q["p25"], q["median"] + 1e-12, key)
                self.assertLessEqual(q["median"], q["p75"] + 1e-12, key)
                self.assertLessEqual(q["p75"], q["max"] + 1e-12, key)

    def test_groups_and_bands(self):
        self.assertEqual(o.material_group("Aluminum - Wrought (6061)"), "non-ferrous")
        self.assertEqual(o.material_group("Steel - Medium Carbon Alloy (4130)", 300), "steel")
        self.assertEqual(o.material_group("Steel - Tool (H13)", 600), "hardened")
        self.assertEqual(o.material_group("Stainless - 300 Series (316)", 200), "stainless")
        self.assertEqual(o.material_group("Titanium Alloy", 330), "Ti-Ni-Co")
        self.assertEqual(o.diameter_band(1 / 16), "1/32-1/16")
        self.assertEqual(o.diameter_band(0.0626), "1/16-1/8")
        self.assertEqual(o.diameter_band(0.5), "1/4-1/2")

    def test_depth_cap_interpolates_p25_median_max(self):
        b = {"ap_over_D": {"p25": 0.5, "median": 1.0, "max": 3.0}}
        self.assertAlmostEqual(o.depth_cap_over_D(b, 0.0), 0.5)
        self.assertAlmostEqual(o.depth_cap_over_D(b, 0.5), 1.0)
        self.assertAlmostEqual(o.depth_cap_over_D(b, 1.0), 3.0)
        self.assertAlmostEqual(o.depth_cap_over_D(b, 0.75), 3.0 ** 0.5)   # geometric between the median and the max

    def test_c8_reads_the_table(self):
        with open(o.ENVELOPE_DEFAULT_PATH, encoding="utf-8") as fh:
            table = json.load(fh)
        k = o.slot_depth_ratio(0.25, table, "Steel - Medium Carbon Alloy (4130)", 200, 0.5)
        self.assertGreater(k, 0.0)
        self.assertEqual(o.slot_depth_ratio(0.0625), 0.35)   # the legacy fallback is unchanged
        tool, mat = tool_material(0.25, 4, ST)
        ctx = o._Context(tool, mat, params.machine(), "slot", params.margins(0.5), envelope="default")
        self.assertAlmostEqual(ctx.depth_cap_ratio, k * 1.0, delta=0.5)
        pt = o.CutPoint(ctx, 0.2, 0.25)
        self.assertTrue(pt.c8.applies)


class TestEnvelopes(unittest.TestCase):
    def test_adaptive_width_is_at_most_040_of_the_diameter(self):
        for fam, d, z in ((AL, 0.0625, 2), (ST, 0.125, 3), (AL, 0.25, 4)):
            r = run_cut(app.physics, req(d, z, fam, coating="AlTiN" if fam == ST else "Uncoated"))
            self.assertTrue(r.feasible, (fam, d))
            self.assertLessEqual(r.rec_woc / d, 0.40 + 1e-9, (fam, d))
        r = run_cut(app.physics, req(0.25, 4, ST, coating="AlTiN"))
        self.assertLessEqual(r.rec_woc / 0.25, 0.30 + 1e-9)

    def test_slot_depth_is_inside_the_envelope_and_chip_is_not_starved(self):
        r = run_cut(app.physics, req(0.25, 4, ST, "Slotting", coating="AlTiN", runout=0.0))
        self.assertTrue(r.feasible)
        cut = r.v2["cut"]
        self.assertLessEqual(cut["ap_over_D"], 1.5 + 1e-9)
        self.assertGreaterEqual(cut["fz_in"], 2.0 * cut["rubbing_limit_in"])

    def test_floor_is_relaxed_with_a_warning_when_physics_forces_it(self):
        # A long, thin stickout cannot meet the vendor chip floor at any depth.
        r = run_cut(app.physics, req(0.0625, 2, ST, "Slotting", coating="AlTiN", stickout=1.5, runout=0.0))
        self.assertTrue(r.feasible, r.model_note)
        self.assertGreaterEqual(r.v2["cut"]["fz_in"], r.v2["cut"]["rubbing_limit_in"] * 0.999)


class TestReducedFlutes(unittest.TestCase):
    def test_every_micro_case_is_feasible_at_default_runout(self):
        for d in (0.010, 0.020, 1 / 32):
            for fam, coat in ((AL, "Uncoated"), (ST, "AlTiN")):
                for op in ("Adaptive Roughing", "Slotting"):
                    r = run_cut(app.physics, req(d, 2, fam, op, coating=coat))
                    self.assertEqual(r.model, "v2")
                    self.assertTrue(r.feasible, (d, fam, op, r.model_note))
                    self.assertIn(r.runout_regime, ("all_flutes", "reduced_flutes"))
                    self.assertIsNotNone(r.tir_all_flutes_in)

    def test_reduced_flutes_fields_and_tip(self):
        r = run_cut(app.physics, req(0.010, 2, AL, "Adaptive Roughing"))
        self.assertEqual(r.runout_regime, "reduced_flutes")
        self.assertLess(r.flutes_cutting, 2)
        self.assertLess(r.tir_all_flutes_in, 0.0002)
        self.assertGreater(r.runout_ratio, 0.0)
        tip = next(t for t in r.tips if t["title"] == "Reduced flutes cutting")
        self.assertIn(f"{r.tir_all_flutes_in:.5f}", tip["message"])

    def test_zero_runout_cuts_with_every_flute(self):
        r = run_cut(app.physics, req(0.0625, 2, AL, runout=0.0))
        self.assertEqual(r.runout_regime, "all_flutes")
        self.assertEqual(r.flutes_cutting, 2)
        self.assertEqual(r.runout_ratio, 0.0)

    def test_v1_leaves_the_fields_empty(self):
        r = run_cut(app.physics, req(model="v1"))
        self.assertIsNone(r.flutes_cutting)
        self.assertIsNone(r.runout_regime)
        self.assertEqual(r.engagement_source, "recommended")


class TestUserEngagement(unittest.TestCase):
    def test_feed_is_computed_for_the_users_depth_and_width(self):
        rec = run_cut(app.physics, req(0.25, 4, ST, "Slotting", coating="AlTiN"))
        self.assertEqual(rec.engagement_source, "recommended")
        user = run_cut(app.physics, req(0.25, 4, ST, "Slotting", coating="AlTiN", cut_depth=0.6, cut_width=0.25))
        self.assertEqual(user.engagement_source, "user")
        self.assertAlmostEqual(user.doc, 0.6, places=6)
        self.assertAlmostEqual(user.woc, 0.25, places=6)
        self.assertAlmostEqual(user.rec_doc, rec.rec_doc, places=6)
        self.assertAlmostEqual(user.rec_woc, rec.rec_woc, places=6)
        self.assertLess(user.feed_ipm, 0.8 * rec.feed_ipm)          # the deep cut is deflection-limited
        self.assertEqual(user.v2["engagement_source"], "user")

    def test_a_lighter_cut_gets_a_feed_at_least_as_high(self):
        deep = run_cut(app.physics, req(0.25, 4, ST, "Roughing", coating="AlTiN", cut_depth=0.75, cut_width=0.12))
        light = run_cut(app.physics, req(0.25, 4, ST, "Roughing", coating="AlTiN", cut_depth=0.2, cut_width=0.12))
        self.assertGreaterEqual(light.feed_ipm, deep.feed_ipm * 0.999)

    def test_infeasible_engagement_still_returns_a_feed_and_a_critical_tip(self):
        r = run_cut(app.physics, req(0.0625, 2, ST, "Slotting", coating="AlTiN", cut_depth=0.18, cut_width=0.0625,
                                     stickout=0.8))
        self.assertEqual(r.engagement_source, "user")
        self.assertFalse(r.feasible)
        self.assertGreater(r.feed_ipm, 0.0)
        tip = next(t for t in r.tips if t["title"] == "Your depth and width exceed a limit")
        self.assertEqual(tip["type"], "critical")
        self.assertRegex(tip["message"], r"C[0-9]+")
        self.assertRegex(tip["message"], r"[+-]\d+%")

    def test_unset_engagement_is_the_recommendation(self):
        r = run_cut(app.physics, req(0.125, 3, AL))
        self.assertEqual(r.engagement_source, "recommended")
        self.assertAlmostEqual(r.doc, r.rec_doc, places=9)


class TestRound2(unittest.TestCase):
    def test_stock_to_leave_fields_and_tip(self):
        r = run_cut(app.physics, req(0.25, 4, ST, "Roughing", coating="AlTiN"))
        mm = 1 / 25.4
        self.assertGreaterEqual(r.recommended_radial_stock_in, 0.05 * mm - 1e-9)
        self.assertGreaterEqual(r.recommended_radial_stock_in, 1.5 * r.deflection + r.springback - 1e-9)
        self.assertAlmostEqual(r.recommended_radial_stock_in / 0.0005, round(r.recommended_radial_stock_in / 0.0005), places=6)
        self.assertGreaterEqual(r.recommended_axial_stock_in, 0.05 * mm - 1e-9)
        tip = next(t for t in r.tips if t["title"] == "Stock to leave")
        self.assertIn("for the finish pass", tip["message"])

    def test_finishing_and_v1_have_no_stock_fields(self):
        self.assertIsNone(run_cut(app.physics, req(0.25, 4, AL, "Finishing")).recommended_radial_stock_in)
        self.assertIsNone(run_cut(app.physics, req(0.25, 4, AL, "Roughing", model="v1")).recommended_radial_stock_in)

    def test_ceiling_wins_with_a_warning_on_a_tiny_tool(self):
        r = run_cut(app.physics, req(0.010, 2, ST, "Slotting", coating="AlTiN"))
        cut = r.v2["cut"]
        self.assertLess(cut["fz_in"], 2.0 * cut["rubbing_limit_in"])
        self.assertTrue(any(t["title"] == "Chip near the rubbing limit" for t in r.tips))

    def test_engagement_source_is_user_only_when_explicit(self):
        client = app.app.test_client()
        client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
        body = dict(family=AL, tool="Carbide Endmill", geometry="Square", operation="Roughing", diameter=0.25, flutes=4,
                    fluteLength=0.75, stickout=1.0, shankDiameter=0.25, aggressiveness=50, maxRpm=16000, maxHp=10)
        self.assertEqual(client.post("/api/calculate", json=dict(body, model="v1")).get_json()["engagement_source"],
                         "recommended")
        r = client.post("/api/calculate", json=dict(body, model="v1", cutDepth=0.2, cutWidth=0.1)).get_json()
        self.assertEqual(r["engagement_source"], "user")
        self.assertIn("recommended_radial_stock_in", r)

    def test_adaptive_call_is_fast_when_warm(self):
        import time
        import v2_bridge
        run_cut(app.physics, req(0.25, 4, ST, "Adaptive Roughing", coating="AlTiN"))
        v2_bridge._CACHE.clear()
        t0 = time.time()
        run_cut(app.physics, req(0.25, 4, ST, "Adaptive Roughing", coating="AlTiN"))
        self.assertLess(time.time() - t0, 2.0)


class TestEndpoints(unittest.TestCase):
    def setUp(self):
        self.client = app.app.test_client()
        self.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def payload(self, **kw):
        base = dict(family=AL, tool="Carbide Endmill", coating="Uncoated", geometry="Square",
                    operation="Adaptive Roughing", diameter=0.0625, flutes=2, fluteLength=0.1875, stickout=0.5,
                    shankDiameter=0.125, aggressiveness=50, maxRpm=16000, maxHp=10, runout=0.0002, model="v2")
        base.update(kw)
        return base

    def test_calculate_returns_the_contract_fields_and_follows_the_sliders(self):
        r = self.client.post("/api/calculate", json=self.payload(cutDepth=0.05, cutWidth=0.01)).get_json()
        for key in ("flutes_cutting", "runout_regime", "tir_all_flutes_in", "runout_ratio", "engagement_source"):
            self.assertIn(key, r)
        self.assertEqual(r["engagement_source"], "user")
        rec = self.client.post("/api/calculate", json=self.payload()).get_json()
        self.assertEqual(rec["engagement_source"], "recommended")
        self.assertAlmostEqual(r["rec_doc"], rec["rec_doc"], places=4)
        self.assertNotAlmostEqual(r["feedrate"], rec["feedrate"], places=1)

    def test_fusion_uses_the_operations_stepdown_and_stepover(self):
        rec = self.client.post("/api/calculate_for_fusion", json=self.payload()).get_json()
        usr = self.client.post("/api/calculate_for_fusion", json=self.payload(stepdown=0.05, stepover=0.01)).get_json()
        for r in (rec, usr):
            for key in ("flutes_cutting", "runout_regime", "tir_all_flutes_in", "runout_ratio", "engagement_source"):
                self.assertIn(key, r)
        self.assertEqual(rec["engagement_source"], "recommended")
        self.assertEqual(usr["engagement_source"], "user")
        self.assertAlmostEqual(usr["doc"], rec["doc"], places=5)
        self.assertAlmostEqual(usr["engagement_doc"], 0.05, places=5)


if __name__ == "__main__":
    unittest.main()
