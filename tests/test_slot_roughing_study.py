"""tools/slot_roughing_study.py: chart arithmetic, the cycle-time model and a quick run (docs/SLOT_ROUGHING_STUDY.md)."""
import math
import os
import sys
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import slot_roughing_study as s  # noqa: E402

DYN = s.DYNAMICS["nominal"]


class TestArithmetic(unittest.TestCase):
    def test_chart_feed_is_rpm_z_fz_with_the_spindle_cap(self):
        rpm, feed, lim = s.chart_feed(300.0, 0.125, 4, 0.0027, 16000.0)
        self.assertAlmostEqual(rpm, 300.0 * 12.0 / (math.pi * 0.125))
        self.assertAlmostEqual(feed, rpm * 4 * 0.0027)
        self.assertFalse(lim)
        rpm, feed, lim = s.chart_feed(377.0, 0.0625, 4, 0.00115, 16000.0)
        self.assertEqual(rpm, 16000.0)            # 377 SFM at 1/16" needs about 23,000 rpm
        self.assertAlmostEqual(feed, 16000.0 * 4 * 0.00115)
        self.assertTrue(lim)

    def test_slot_time_is_levels_times_path_over_feed_plus_dynamics(self):
        t = s.slot_time(0.150, 0.008, 60.0, 3.0, 0.5, DYN)
        self.assertEqual(t["levels"], 19)
        self.assertAlmostEqual(t["cut_min"], 19 * s.PERIMETER_IN / 60.0)
        run = (0.150 / 19) / math.tan(math.radians(3.0))
        self.assertAlmostEqual(t["ramp_min"], 19 * run / 30.0)
        self.assertAlmostEqual(t["corner_min"], 19 * 4 * s.corner_loss_s(60.0, DYN) / 60.0)
        self.assertGreater(t["total_min"], t["cut_min"] + t["ramp_min"] + t["corner_min"])
        self.assertEqual(s.slot_time(0.150, 0.2, 10.0, 3.0, 0.5, DYN)["levels"], 1)

    def test_hem_loop_speed_cap(self):
        fast = s.hem_time(0.15, 0.15, 0.005, 1000.0, 0.12, 0.0625, DYN, 1181.0)
        self.assertTrue(fast["accel_limited"])
        slow = s.hem_time(0.15, 0.15, 0.005, 10.0, 0.12, 0.0625, DYN, 1181.0)
        self.assertFalse(slow["accel_limited"])
        self.assertAlmostEqual(slow["loops_per_level"], s.PERIMETER_IN / 0.005)

    def test_chart_rows_pick_the_hardness_class(self):
        rows = s.load_rows()
        ti = s.chart_rows(rows, "Titanium Alloy", 330.0, 0.125, "hf")
        harvey = [r for r in ti if r["_vendor"] == "harvey"]
        self.assertEqual({s.nominal(r["cut"]["sfm"]) for r in harvey}, {300.0})   # the 21-36 HRC class
        self.assertTrue(any(r["_vendor"] == "seco" for r in ti))
        sixteenth = s.chart_rows(rows, "Titanium Alloy", 330.0, 0.0625, "hf")   # 1/16"-class: Niagara SN200R, Seco JHF980 1.5 mm
        self.assertEqual({(r["_vendor"], r["tool"]["series"], r["tool"]["flutes"]) for r in sixteenth},
                         {("seco", "SN200R", 2), ("seco", "JHF980", 2)})


class TestQuickRun(unittest.TestCase):
    def test_quick_run_tables(self):
        data = s.run(quick=True)
        case = data["cases"][0]
        names = [o["name"] for o in case["options"]]
        self.assertIn("high-feed Niagara SN400R", names)
        self.assertTrue(any(n.startswith('high-feed Seco JHF980 4FL [3 mm = 0.118" tool') for n in names))   # true metric size
        self.assertTrue(any(n.startswith("HEM") for n in names))
        text = s.render(data)
        self.assertIn("| high-feed Harvey |", text)
        ch, tw = s.ranking(case)
        self.assertTrue(ch and tw)
        hf = next(o for o in case["options"] if o["name"] == "high-feed Niagara SN400R")
        c = hf["chart"][0.150]
        self.assertAlmostEqual(c["feed_ipm"], c["rpm"] * c["z"] * c["fz"])
        self.assertAlmostEqual(c["cut_min"], c["levels"] * s.PERIMETER_IN / c["feed_ipm"])
        self.assertEqual(c["levels"], math.ceil(0.150 / c["ap"] - 1e-9))


if __name__ == "__main__":
    unittest.main()
