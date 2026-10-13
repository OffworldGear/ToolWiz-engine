"""Coating SFM follows GWizard's per-material TiAlN carbide rating; full-width slots run slower."""
import unittest

import app
from pipeline import FULL_SLOT_SFM_FACTOR


def calc(**kw):
    c = app.app.test_client()
    c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
    body = dict(family="Stainless - PH Series (17-4)", alloy="17-7 PH (Annealed) [162 HB]",
                tool="HP Carbide Endmill", coating="AlTiN", geometry="Square", operation="Slotting / Tab Milling",
                aggressiveness=50, maxRpm=30000, maxHp=10, diameter=0.125, flutes="4", fluteLength=0.375,
                shankDiameter=0.125, stickout=0.5, isCarbide=True, cutDepth=0.02, cutWidth=0.125)
    body.update(kw)
    return c.post("/api/calculate", json=body).get_json()


def step(res, name):
    return next(p for p in res["provenance"] if p["quantity"] == "sfm" and p["step"] == name)


class TestCoating(unittest.TestCase):
    def setUp(self):
        self.p = app.physics

    def test_hp_carbide_altin_adds_nothing_where_gwizard_rates_them_equal(self):
        for fam in ("Stainless - PH Series (17-4)", "Stainless - 300 Series (316)", "Steel - Tool (H13)"):
            self.assertEqual(self.p.get_coating_multiplier("AlTiN", fam, "HP Carbide Endmill", "Square", True), 1.0, fam)

    def test_plain_carbide_altin_uses_gwizard_tialn_rating(self):
        m = self.p.get_coating_multiplier("AlTiN", "Stainless - PH Series (17-4)", "Carbide Endmill", "Square", True)
        self.assertAlmostEqual(m, 360 / 300)

    def test_aluminum_and_non_endmills_unchanged(self):
        self.assertEqual(self.p.get_coating_multiplier("AlTiN", "Aluminum - Wrought (6061)", "HP Carbide Endmill", "Square", True), 0.80)
        self.assertEqual(self.p.get_coating_multiplier("AlTiN", "Stainless - PH Series (17-4)", "Carbide Twist Drill", "Drill", True), 1.40)

    def test_user_case_no_longer_double_counts_coating(self):
        self.assertEqual(step(calc(), "coating")["multiplier"], 1.0)


class TestFullSlot(unittest.TestCase):
    def test_full_width_slot_is_slower(self):
        slot, profile = calc(cutWidth=0.125), calc(cutWidth=0.05, operation="Standard Roughing")
        self.assertAlmostEqual(step(slot, "slot_engagement")["multiplier"], FULL_SLOT_SFM_FACTOR)
        self.assertEqual(step(profile, "slot_engagement")["multiplier"], 1.0)
        self.assertLess(slot["rpm"], profile["rpm"])

    def test_user_slot_is_within_vendor_style_range(self):
        r = calc(aggressiveness=52, maxRpm=16000, maxHp=6.84)
        self.assertLess(r["sfm"], 340)          # was 524 SFM at the 16k cap
        self.assertLess(r["rpm"], 11000)

    def test_form_tools_are_not_treated_as_slots(self):
        r = calc(geometry="Chamfer Mill", tool="HP Carbide Endmill", cutWidth=0.125, operation="Chamfering")
        self.assertEqual(step(r, "slot_engagement")["multiplier"], 1.0)


if __name__ == "__main__":
    unittest.main()
