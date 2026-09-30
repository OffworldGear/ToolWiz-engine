import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from gwizard_physics import GWizardPhysics

DB = os.path.join(os.path.dirname(__file__), "..", "materials_database_clean.json")


class TestAlloyMatching(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.p = GWizardPhysics(DB)

    def test_temper_tokens_match(self):
        fam = "Aluminum - Wrought (6061)"
        for name in ["6061-T6", "6061 (T6, T651)", "6061 T651"]:
            self.assertEqual(self.p.match_alloy(fam, name)["condition"], "T6, T651", name)
        self.assertEqual(self.p.match_alloy(fam, "6061 (O)")["condition"], "O")

    def test_bare_alloy_resolves_to_hardest_condition(self):
        row = self.p.match_alloy("Aluminum - Wrought (6061)", "6061")
        self.assertEqual(row["condition"], "T6, T651")

    def test_no_cross_family_or_partial_number_match(self):
        self.assertIsNone(self.p.match_alloy("Aluminum - Wrought (6061)", "16061"))
        self.assertIsNone(self.p.match_alloy("Titanium Alloy", "6061-T6"))

    def test_every_db_row_resolves_to_its_own_hardness(self):
        # Rows sharing alloy+condition (castings) legitimately resolve to the harder duplicate.
        dup = {}
        for a in self.p.specific_alloys:
            dup.setdefault((a["family"], a["alloy"].lower(), a["condition"].lower()), []).append(a)
        for a in self.p.specific_alloys:
            m = self.p.match_alloy(a["family"], f"{a['alloy']} ({a['condition']})")
            self.assertIsNotNone(m)
            # Empty condition = bare alloy name, which intentionally resolves to the hardest row.
            if a["condition"].strip() and len(dup[(a["family"], a["alloy"].lower(), a["condition"].lower())]) == 1:
                self.assertEqual(str(m["hardness"]), str(a["hardness"]), a)


class TestOptimizerFeasibility(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.p = GWizardPhysics(DB)

    def _rec(self, stickout):
        d = {}
        self.p.recommend_cut_parameters(
            0.125, 0.125, stickout, 4, 8000, 0.0005, True, "Roughing", 0.5, "Square", 0.125, 10,
            "Titanium Alloy", flute_length=0.375, details=d)
        return d

    def test_short_stickout_is_feasible(self):
        self.assertTrue(self._rec(0.75)["feasible"])

    def test_extreme_stickout_is_flagged_infeasible(self):
        d = self._rec(3.0)
        self.assertFalse(d["feasible"])
        self.assertEqual(d["limited_by"], "deflection")


class TestFormToolFactors(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.p = GWizardPhysics(DB)

    def test_dovetail_chipload_is_half_endmill(self):
        fam = "Aluminum - Wrought (6061)"
        em = self.p.get_base_ipt(fam, "Carbide Endmill", 0.375, geometry="Square")
        dt = self.p.get_base_ipt(fam, "Carbide Endmill", 0.375, geometry="Dovetail")
        self.assertAlmostEqual(dt, em * 0.5, places=6)

    def test_chamfer_sfm_is_reduced(self):
        fam = "Aluminum - Wrought (6061)"
        em = self.p.get_base_sfm(fam, "Carbide Endmill", geometry="Square", is_carbide=True)
        ch = self.p.get_base_sfm(fam, "Carbide Endmill", geometry="Chamfer", is_carbide=True)
        self.assertAlmostEqual(ch, em * 0.8, places=3)


class TestHardMillingCorrection(unittest.TestCase):
    """Vendor-fitted correction above 45 HRC (OSG AE-CPR4-H, Harvey hardened-steel finishers)."""
    FAM = "Steel - Tool (H13)"

    @classmethod
    def setUpClass(cls):
        cls.p = GWizardPhysics(DB)

    def ratio(self, hrc):
        s45, i45 = self.p.apply_alloy_hardness_scaling(self.FAM, "x 45 HRC", 200.0, 0.002)
        s, i = self.p.apply_alloy_hardness_scaling(self.FAM, f"x {hrc} HRC", 200.0, 0.002)
        return s / s45, i / i45

    def test_below_onset_is_pure_gwizard(self):
        s, i = self.p.apply_alloy_hardness_scaling(self.FAM, "x 30 HRC", 200.0, 0.002)
        self.assertEqual(i, 0.002)
        self.assertGreater(s, 200.0)  # below family mid-hardness GWizard speeds up

    def test_55_65_band_matches_vendor_ratios(self):
        s, i = self.ratio(60)
        self.assertTrue(0.70 <= s <= 0.82, s)   # OSG 0.70-0.82
        self.assertTrue(0.65 <= i <= 0.72, i)   # OSG 0.68-0.70

    def test_45_55_band_matches_vendor_ratios(self):
        s, i = self.ratio(50)
        self.assertAlmostEqual(s, 0.90, delta=0.02)
        self.assertTrue(0.83 <= i <= 0.90, i)

    def test_monotonic_and_held_beyond_data(self):
        vals = [self.ratio(h) for h in (46, 50, 55, 60, 65, 68)]
        for a, b in zip(vals, vals[1:]):
            self.assertLessEqual(b[0], a[0])
            self.assertLessEqual(b[1], a[1])
        self.assertEqual(vals[-1], vals[-2])

    def test_tip_flags_hardness_beyond_data(self):
        tips = self.p.generate_advanced_strategies(
            self.FAM, 0.25, 0.1, 0.025, 20, 5000, 4, "AlTiN", 0.0001, alloy="x 68 HRC")
        self.assertIn("Hardness Beyond Vendor Data", [t["title"] for t in tips])



class TestWearCompOnlyOnFinishing(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.p = GWizardPhysics(DB)

    def titles(self, op):
        tips = self.p.generate_advanced_strategies(
            "Steel - Tool (H13)", 0.5, 0.25, 0.1, 15, 1700, 4, "AlTiN", 0.0015,
            stickout=1.5, flute_length=1.0, operation=op, alloy="CPM MagnaCut (Hardened ~62 HRC)")
        return [t["title"] for t in tips]

    def test_roughing_gets_no_negative_stock_advice(self):
        for op in ("Adaptive Roughing", "Standard Roughing", "Slotting / Tab Milling"):
            self.assertNotIn("Tool Wear Compensation (Wall Deflection & Axial Springback)", self.titles(op), op)

    def test_finishing_still_gets_it(self):
        self.assertIn("Tool Wear Compensation (Wall Deflection & Axial Springback)", self.titles("Wall Finishing (Deep DOC)"))


class TestBullNoseTip(unittest.TestCase):
    def test_bull_nose_floor_finish_gets_corner_radius_tip_not_ball_tip(self):
        p = GWizardPhysics(DB)
        tips = p.generate_advanced_strategies(
            "Copper Alloy - Wrought", 0.126, 0.005, 0.082, 84, 16000, 4, "AlTiN", 0.00003,
            geometry="Bullnose / Radiused", tool_type="HP Carbide Bull Nose Endmill",
            flute_length=0.378, stickout=0.41, operation="Floor Finishing (Skim)", corner_radius=0.03)
        titles = [t["title"] for t in tips]
        self.assertIn("Corner Radius Effective Diameter", titles)
        self.assertNotIn("Ball Mill Effective Diameter & 3D Contouring Dynamics", titles)


class TestHardnessTag(unittest.TestCase):
    def test_tag_picks_exact_row_among_same_label(self):
        p = GWizardPhysics(DB)
        groups = {}
        for a in p.specific_alloys:
            groups.setdefault((a["family"], a["alloy"].lower(), a["condition"].lower()), []).append(a)
        amb = [v for v in groups.values() if len({str(x["hardness"]) for x in v}) > 1]
        self.assertTrue(amb)
        for rows in amb:
            for a in rows:
                hb = str(a["hardness"]).strip()
                tag = hb if any(c.isalpha() for c in hb) else hb + " HB"
                m = p.match_alloy(a["family"], f"{a['alloy']} ({a['condition']}) [{tag}]")
                self.assertEqual(str(m["hardness"]), str(a["hardness"]))

    def test_untagged_value_still_resolves(self):
        p = GWizardPhysics(DB)
        self.assertEqual(p.match_alloy("Aluminum - Wrought (6061)", "6061 (T6, T651)")["condition"], "T6, T651")


if __name__ == "__main__":
    unittest.main()
