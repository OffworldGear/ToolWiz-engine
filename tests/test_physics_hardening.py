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


if __name__ == "__main__":
    unittest.main()
