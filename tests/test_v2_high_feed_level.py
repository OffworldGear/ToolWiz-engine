"""High-feed chart class level (tools/fit_high_feed_level.py, data/model_v2/high_feed_level.json) and its use in C7 / C2."""
import math
import os
import sys
import unittest

from physics_v2 import highfeed, params
from physics_v2 import optimize as o

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import fit_high_feed_level as fit  # noqa: E402

TI, SS, AL = "Titanium Alloy", "Stainless - PH Series (17-4)", "Aluminum - Wrought (6061)"


def run(family, D=0.125, a=0.5, brand=None, apmx=None, rp=None):
    tool = o.Tool.build(D, 4, apmx or 0.06 * D, 3 * D, shank=0.25, high_feed=highfeed.resolve(D, apmx, None, rp))
    return params.optimize(tool, params.material(family), "slot", a, machine_=params.machine(), robust=False,
                           robustness=False, brand=brand)


class TestFitFile(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.data = fit.fit()
        cls.levels = params.high_feed_level()

    def test_file_is_current(self):
        self.assertEqual(fit.main(["--check"]), 0)

    def test_row_counts_vendors_and_holdout(self):
        fams = self.data["families"]
        self.assertGreaterEqual(self.data["rows"], 399)   # 438 cited rows less 39 Cobalt Chrome (no engine family)
        ti = fams[TI]["hf_slot"]
        self.assertEqual(ti["vendor_groups"], ["Harvey Performance", "Seco Tools"])
        self.assertEqual(ti["confidence"], "two groups")
        self.assertIsNotNone(ti["speed"]["holdout_median_abs_err"])
        self.assertEqual(fams[SS]["hf_slot"]["confidence"], "one group (lower)")
        self.assertIsNone(fams[SS]["hf_slot"]["speed"]["holdout_median_abs_err"])
        self.assertNotIn(AL, fams)
        for classes in fams.values():
            for e in classes.values():
                self.assertGreater(e["speed"]["value"], 0.5)
                self.assertGreater(e["chip"]["value"], 0.5)
                self.assertEqual(sum(e["rows_by_group"].values()), e["n_rows"])

    def test_material_loader(self):
        m = params.material(TI)
        self.assertEqual(dict(m.vc_hf_factor)["hf_slot"], self.levels[TI]["hf_slot"]["speed"]["value"])
        self.assertEqual(dict(m.c2_hf_factor)["hf_rough"], self.levels[TI]["hf_rough"]["chip"]["value"])
        self.assertIn("two groups", m.hf_level_basis)
        self.assertEqual(params.material(AL).vc_hf_factor, ())

    def test_square_end_speed_is_unchanged(self):
        m = params.material(TI)
        for op in ("slot", "rough", "adaptive", "finish"):
            self.assertEqual(o.speed_level_factor(m, op), o.operation_speed_factor(m, op))
        f = dict(m.vc_hf_factor)
        self.assertAlmostEqual(o.speed_level_factor(m, "adaptive", "high_feed"),
                               o.operation_speed_factor(m, "rough") * f["hf_rough"])
        # no high-feed level (aluminium): the square-end operation factor
        al = params.material(AL)
        self.assertEqual(o.speed_level_factor(al, "slot", "high_feed"), o.operation_speed_factor(al, "slot"))


class TestEngine(unittest.TestCase):
    def test_ti_eighth_slot_reaches_the_chart_middle(self):
        r = run(TI)
        vb = r["vendor_basis"]
        self.assertEqual(vb["chart_class"], "hf_slot")
        mid = vb["sfm_range"][1]
        self.assertGreaterEqual(r["cut"]["sfm"], 0.85 * mid)      # was 147 SFM (0.59 x 250) before the level fit
        self.assertLessEqual(r["cut"]["sfm"], mid * 1.0001)
        self.assertLessEqual(r["cut"]["fz_in"], vb["fz_range"][1] * 1.0001)
        self.assertEqual(r["high_feed"]["level_chart_class"], "hf_slot")
        self.assertIn("C2", r["checks"]["C2"]["id"])
        self.assertIn("high-feed hf_slot level", r["checks"]["C2"]["detail"])

    def test_niagara_eighth_titanium(self):
        r = run(TI, brand="seco", apmx=0.008, rp=0.0148)
        self.assertEqual(r["vendor_basis"]["mode"], "brand")
        self.assertGreater(r["cut"]["sfm"], 200.0)
        self.assertLessEqual(r["cut"]["fz_in"], 0.0023 * 1.0001)

    def test_sixteenth_spindle_limited_is_said_and_chip_not_raised(self):
        r = run(SS, D=0.0625)
        sl = r["high_feed"]["spindle_limited"]
        self.assertTrue(sl["limited"])
        self.assertGreater(sl["rpm_needed"], 16000)
        self.assertAlmostEqual(r["cut"]["rpm"], 16000.0, delta=1.0)
        self.assertIn("Spindle-limited", sl["sentence"])
        self.assertTrue(any("Spindle-limited" in w for w in r["warnings"]))
        self.assertLessEqual(r["cut"]["fz_in"], r["vendor_basis"]["fz_range"][1] * 1.0001)   # never above the chart middle

    def test_tool_life_bound_sixteenth_is_not_called_spindle_limited(self):
        # With the 2-flute SN200R rows in the fit the Ti factor reaches the spindle at 50 % (262 SFM at 16,000 rpm), so the
        # tool-life-bound case is the bottom of the chart (0 %).
        r = run(TI, D=0.0625, brand="seco", a=0.0)
        sl = r["high_feed"]["spindle_limited"]
        self.assertFalse(sl["limited"])
        self.assertLess(r["cut"]["rpm"], 16000.0)
        self.assertGreater(sl["rpm_needed"], 20000.0)   # Niagara's 377 SFM needs about 23,000 rpm at 1/16"
        self.assertIn("not what limits", sl["sentence"])
        self.assertTrue(run(TI, D=0.0625, brand="seco")["high_feed"]["spindle_limited"]["limited"])

    def test_aggressiveness_is_monotone(self):
        sfm = [run(TI, a=a)["cut"]["sfm"] for a in (0.0, 0.5, 1.0)]
        self.assertLess(sfm[0], sfm[1])
        self.assertLessEqual(sfm[1], sfm[2])
        self.assertTrue(math.isfinite(sfm[2]))


if __name__ == "__main__":
    unittest.main()
