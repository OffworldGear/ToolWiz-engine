"""High-feed end mills in v2 (physics_v2/highfeed.py, endforms.HighFeedProfile, v2_bridge, tool_recommender).

The engine runs a high-feed tool from physics alone until cited high-feed vendor rows exist; the loader path for those rows
is proven here on a SYNTHETIC fixture (tests/fixtures/highfeed_synthetic, never real vendor data)."""
import glob
import math
import os
import sys
import unittest

import app
import v2_bridge
from physics_v2 import endforms, highfeed, params
from physics_v2 import optimize as o

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
TI, SS, AL = "Titanium Alloy", "Stainless - PH Series (17-4)", "Aluminum - Wrought (6061)"
FIXTURE = sorted(glob.glob(os.path.join(ROOT, "tests", "fixtures", "highfeed_synthetic", "*.json")))


def hf_tool(D=0.125, z=4, apmx=None, lead=None, rp=None):
    return o.Tool.build(D, z, 1.5 * D, 4 * D, shank=D, high_feed=highfeed.resolve(D, apmx, lead, rp))


def run(tool, family=TI, op="slot", a=0.5, **kw):
    return params.optimize(tool, params.material(family), op, a, machine_=params.machine(), robust=False, robustness=False, **kw)


def calc(**kw):
    c = app.app.test_client()
    c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
    D = kw.pop("diameter", 0.125)
    body = dict(family=TI, alloy="", tool="Carbide Endmill", coating="Uncoated", geometry="High Feed",
                operation="Slotting / Tab Milling", aggressiveness=50, diameter=D, fluteLength=1.5 * D, shankDiameter=D,
                stickout=4 * D, isCarbide=True, model="v2", flutes=4)
    body.update(kw)
    return c.post("/api/calculate", json=body).get_json()


class TestGeometry(unittest.TestCase):
    def test_profile_lead_edge_and_chip_thinning(self):
        p = endforms.HighFeedProfile(R=1.5875, lead_deg=15.0, apmx=0.19)
        self.assertAlmostEqual(p.sk, math.sin(math.radians(15.0)), places=9)
        self.assertAlmostEqual(p.radius(p.apmx), p.R, places=9)
        self.assertLess(p.radius(0.0), p.R)
        for z in (0.0, 0.05, 0.1, 0.18):
            self.assertAlmostEqual(p.sin_kappa(z), p.sk)
        self.assertEqual(p.sin_kappa(0.2), 1.0)

    def test_defaults_are_marked_assumed_and_given_values_are_used(self):
        g = highfeed.resolve(0.125)
        self.assertEqual(set(g.assumed), {"max_ap", "lead_angle"})
        self.assertAlmostEqual(g.apmx_in, highfeed.DEFAULT_APMX_OVER_D * 0.125)
        g2 = highfeed.resolve(0.125, apmx_in=0.01, lead_deg=12.0)
        self.assertEqual(g2.assumed, ())
        self.assertEqual((g2.apmx_in, g2.lead_deg), (0.01, 12.0))
        g3 = highfeed.resolve(0.125, apmx_in=0.01, programming_radius_in=0.03)
        self.assertAlmostEqual(math.tan(math.radians(g3.lead_deg)), 0.01 / 0.03, places=9)

    def test_detection(self):
        self.assertTrue(highfeed.is_high_feed("High Feed", "Carbide Endmill"))
        self.assertTrue(highfeed.is_high_feed("Square", "1/8 HFM 4FL"))
        self.assertTrue(highfeed.is_high_feed("", "high-feed end mill"))
        for geo, tool in (("Square", "Carbide Endmill"), ("Radiused", "bull nose"), ("Ball", "ball end mill"), ("Square", "Shaft 1/8")):
            self.assertFalse(highfeed.is_high_feed(geo, tool), (geo, tool))


class TestEngine(unittest.TestCase):
    def test_ap_never_exceeds_the_tools_max_ap(self):
        for fam in (TI, SS, AL):
            for apmx in (None, 0.004, 0.012):
                for a in (0.0, 0.5, 1.0):
                    for op in ("slot", "rough"):
                        t = hf_tool(apmx=apmx)
                        out = run(t, fam, op, a)
                        self.assertTrue(out["feasible"], (fam, apmx, a, op))
                        self.assertLessEqual(out["cut"]["ap_in"], t.high_feed.apmx_in * (1 + 1e-9), (fam, apmx, a, op))

    def test_user_depth_beyond_max_ap_is_clamped_to_it(self):
        t = hf_tool()
        out = params.evaluate_user_engagement(t, params.material(TI), "slot", 2 * t.high_feed.apmx_in, 0.125, 0.5,
                                              machine_=params.machine())
        self.assertLessEqual(out["cut"]["ap_in"], t.high_feed.apmx_in * (1 + 1e-9))
        self.assertTrue(any("exceeds" in w for w in out["warnings"]))

    def test_chip_is_thinned_by_the_lead_angle_and_feed_per_tooth_is_higher(self):
        hf = run(hf_tool())
        sq = run(o.Tool.build(0.125, 4, 0.375, 0.5, shank=0.125))
        g = hf_tool().high_feed
        c = hf["cut"]
        self.assertAlmostEqual(c["h_max_nominal_in"], c["fz_in"] * g.sin_kappa, places=9)
        self.assertGreater(c["fz_in"], 2.0 * sq["cut"]["fz_in"])
        self.assertEqual(hf["vendor_basis"]["chart_class"], "hf_slot")    # cited high-feed charts, never a square-end class
        self.assertEqual(c["end_form"], "high_feed")

    def test_force_is_mostly_axial_and_bending_is_small(self):
        out = run(hf_tool())
        self.assertGreater(out["loads"]["axial_peak_n"], 0.0)
        self.assertLess(out["checks"]["C3"]["value"], 0.5 * out["checks"]["C3"]["limit"])
        self.assertIn("axial_check", out["high_feed"])

    def test_more_aggressive_is_not_slower(self):
        feeds = [run(hf_tool(), TI, "slot", a)["cut"]["feed_ipm"] for a in (0.0, 0.5, 1.0)]
        self.assertLessEqual(feeds[0], feeds[1] * (1 + 1e-6))
        self.assertLessEqual(feeds[1], feeds[2] * (1 + 1e-6))

    def test_square_bull_and_ball_tools_are_not_high_feed(self):
        for cr in (0.0, 0.02, 0.0625):
            t = o.Tool.build(0.125, 4, 0.375, 0.5, shank=0.125, corner_radius_in=cr)
            self.assertIsNone(t.high_feed)
            self.assertNotEqual(t.end_form, "high_feed")
            self.assertEqual(t.ap_limit, t.lcf)


class TestVendorPath(unittest.TestCase):
    """Synthetic high-feed rows -> tools/build_vendor_consensus.py -> the high-feed chart classes, brand -> default ->
    consensus, 0/50/100 % = bottom/middle/top."""

    @classmethod
    def setUpClass(cls):
        import build_vendor_consensus as bvc
        cls.table = bvc.build(FIXTURE)

    def test_rows_land_in_high_feed_classes_only(self):
        keys = {k.split("|")[3] for v in self.table["vendors"].values() for k in v["cells"]}
        self.assertEqual(keys, {"hf_slot", "hf_rough"})

    def test_brand_default_consensus_order(self):
        look = lambda brand: o.vendor_lookup(self.table, brand, TI, 330, 0.125, "slot", 1.0, end="high_feed")
        self.assertEqual(look("seco")["mode"], "brand")
        self.assertEqual(look(None)["mode"], "default")       # harvey (+ helical) default
        self.assertEqual(look(None)["vendor"], "harvey+helical")
        self.assertIsNone(o.vendor_lookup(self.table, None, TI, 330, 0.125, "slot", 1.0))   # square tools never read them
        t2 = dict(self.table, vendors={k: v for k, v in self.table["vendors"].items() if k != "harvey"})
        cons = o.vendor_lookup(t2, None, TI, 330, 0.125, "slot", 1.0, end="high_feed")
        self.assertEqual(cons["mode"], "consensus")

    def test_engine_uses_the_chart_and_maps_aggressiveness_to_its_range(self):
        t = hf_tool()
        outs = {a: run(t, TI, "slot", a, vendor_table=self.table, brand="seco") for a in (0.0, 0.5, 1.0)}
        vb = outs[0.5]["vendor_basis"]
        self.assertEqual((vb["mode"], vb["chart_class"]), ("brand", "hf_slot"))
        lo, mid, hi = vb["sfm_range"]
        for a, want in ((0.0, lo), (0.5, mid), (1.0, hi)):
            c14 = outs[a]["checks"]["C14v"]
            self.assertAlmostEqual(c14["limit"], want, places=6)
            self.assertLessEqual(outs[a]["cut"]["sfm"], want * (1 + 1e-6))

    def test_real_rows_give_a_high_feed_chart_by_brand_and_by_default(self):
        """Cited rows (tests/benchmarks/v2/highfeed_*.json): Harvey, Helical, and Niagara filed under the Seco brand key."""
        r = calc()
        self.assertEqual(r["model"], "v2")
        self.assertEqual((r["vendor_basis"]["mode"], r["vendor_basis"]["chart_class"]), ("default", "hf_slot"))
        for brand, key in (("Harvey Tool", "harvey"), ("Niagara Cutter", "seco")):
            vb = calc(brand=brand)["vendor_basis"]
            self.assertEqual((vb["mode"], vb["vendor"], vb["chart_class"]), ("brand", key, "hf_slot"))


class TestBridge(unittest.TestCase):
    def test_result_carries_entry_and_wall_guidance(self):
        r = calc()
        titles = {t["title"] for t in r["tips"]}
        self.assertTrue({"High-feed entry", "High-feed walls", "High-feed depth", "High-feed geometry assumed"} <= titles)
        entry = next(t for t in r["tips"] if t["title"] == "High-feed entry")["message"]
        self.assertIn("Do not plunge", entry)
        self.assertIn("helix", entry)
        self.assertLessEqual(r["ramp_angle"], highfeed.RAMP_CAP_DEG + 1e-9)
        self.assertLessEqual(r["rec_doc"], highfeed.DEFAULT_APMX_OVER_D * 0.125 + 1e-9)

    def test_given_max_ap_is_used_and_changes_the_cache_key(self):
        a = calc(maxAp=0.004)
        b = calc(maxAp=0.006)
        self.assertLessEqual(a["rec_doc"], 0.004 + 1e-9)
        self.assertGreater(b["rec_doc"], 0.004)
        self.assertFalse(any(t["title"] == "High-feed geometry assumed" and "max ap" in t["message"].split("(")[0]
                             for t in a["tips"]))

    def test_high_feed_operation_names(self):
        sq = calc(geometry="Square", operation="High Feed Milling")
        self.assertNotEqual(sq.get("model"), "v2")
        hf = calc(operation="High Feed Milling")
        self.assertEqual(hf["model"], "v2")
        self.assertIn("rough", hf["model_note"])
        hs = calc(operation="High Feed Slotting")
        self.assertIn("slot", hs["model_note"])

    def test_square_request_is_not_high_feed(self):
        r = calc(geometry="Square", fluteLength=0.375)
        self.assertFalse(any(t["title"].startswith("High-feed") for t in r["tips"]))
        self.assertNotEqual(r["vendor_basis"]["mode"], "none")


class TestRecommender(unittest.TestCase):
    def test_shallow_slot_gets_a_physics_only_high_feed_candidate(self):
        import tool_recommender as tr
        tr.clear_cache()
        out = tr.recommend(dict(family=TI, operation="Slotting", diameter=0.125, flutes=4, flute_length=0.375, depth_in=0.15,
                                toolpath_length_in=4.2, aggressiveness=50, use_library=False))
        hf = [a for a in out["alternatives"] + out["below_threshold"] if a["source"] == "high_feed"]
        self.assertEqual(len(hf), 1)
        a = hf[0]
        self.assertTrue(a["physics_only"])
        self.assertEqual(a["rate_metric"], "slot_advance_in2_min")
        self.assertIn("physics only", tr._label_alt(a))
        text = " ".join(a["caveats"])
        for w in ("Physics only", "not center cutting", "stock"):
            self.assertIn(w, text)

    def test_deep_slot_gets_no_high_feed_candidate(self):
        import tool_recommender as tr
        tr.clear_cache()
        out = tr.recommend(dict(family=TI, operation="Slotting", diameter=0.125, flutes=4, flute_length=0.5, depth_in=0.4,
                                aggressiveness=50, use_library=False, use_catalog=True))
        self.assertFalse([a for a in out["alternatives"] + out["below_threshold"] if a["source"] == "high_feed"])


if __name__ == "__main__":
    unittest.main()
