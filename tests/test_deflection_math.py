import os
import sys
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from gwizard_physics import BeamDeflectionEngine as B, GWizardPhysics
from toolwiz_common import Segment, ToolProfile

E_CARBIDE = 90000000.0
I = B.solid_circular_inertia


class TestDeflectionMath(unittest.TestCase):
    def test_uniform_shank_rod_textbook(self):
        d, L, F = 0.25, 2.0, 10.0
        got = B.deflection_from_segments(F, [Segment("shank", 0.0, L, d, d, False)], 4, 30.0, True)
        self.assertAlmostEqual(got, F * L ** 3 / (3 * E_CARBIDE * I(d)), delta=got * 0.001)

    def test_hss_modulus(self):
        d, L, F = 0.25, 2.0, 10.0
        got = B.deflection_from_segments(F, [Segment("shank", 0.0, L, d, d, False)], 4, 30.0, False)
        self.assertAlmostEqual(got, F * L ** 3 / (3 * 30000000.0 * I(d)), delta=got * 0.001)

    def test_two_step_rod_closed_form(self):
        d1, d2, L1, L, F = 0.1, 0.25, 0.6, 2.0, 7.5
        segs = [Segment("neck", 0.0, L1, d1, d1, False), Segment("shank", L1, L, d2, d2, False)]
        got = B.deflection_from_segments(F, segs, 4, 30.0, True)
        exp = (F / E_CARBIDE) * (L1 ** 3 / (3 * I(d1)) + (L ** 3 - L1 ** 3) / (3 * I(d2)))
        self.assertAlmostEqual(got, exp, delta=exp * 0.001)

    def test_fluted_segment_uses_core_inertia(self):
        d, L, F = 0.25, 0.75, 5.0
        got = B.deflection_from_segments(F, [Segment("flute", 0.0, L, d, d, True)], 4, 30.0, True)
        exp = F * L ** 3 / (3 * E_CARBIDE * B.fluted_core_inertia(d, 4, 30.0))
        self.assertAlmostEqual(got, exp, delta=exp * 0.001)

    def test_tapered_segment_converges(self):
        d0, d1, x0, x1, F = 0.1, 0.25, 0.0, 1.0, 4.0
        got = B.deflection_from_segments(F, [Segment("shank", x0, x1, d0, d1, False)], 4, 30.0, True)
        n = 200000
        h = (x1 - x0) / n
        tot = 0.0
        for k in range(n):
            x = x0 + (k + 0.5) * h
            d = d0 + (d1 - d0) * (x - x0) / (x1 - x0)
            tot += x * x / I(d) * h
        exp = F / E_CARBIDE * tot
        self.assertAlmostEqual(got, exp, delta=exp * 0.005)

    def test_tapered_fluted_converges(self):
        d0, d1, x1, F = 0.08, 0.25, 1.0, 4.0
        got = B.deflection_from_segments(F, [Segment("flute", 0.0, x1, d0, d1, True)], 3, 35.0, True)
        n = 200000
        h = x1 / n
        tot = sum(((k + .5) * h) ** 2 / B.fluted_core_inertia(d0 + (d1 - d0) * (k + .5) * h / x1, 3, 35.0) * h
                  for k in range(n))
        self.assertAlmostEqual(got, F / E_CARBIDE * tot, delta=got * 0.005)

    def test_empty_and_zero_force(self):
        self.assertEqual(B.deflection_from_segments(0.0, [Segment("shank", 0, 1, .25, .25, False)]), 0.0)
        self.assertEqual(B.deflection_from_segments(5.0, []), 0.0)


class TestLegacyParity(unittest.TestCase):
    """calculate_deflection with legacy args must equal the old three-section closed form."""

    @staticmethod
    def old(F, dia, shank, stick, fl, neck_d, neck_l, flutes, helix, carbide):
        E = 90000000.0 if carbide else 30000000.0
        nd = neck_d if (neck_d and neck_d > 0) else shank
        L1 = max(0.0, min(fl, stick))
        L2 = max(0.0, min(neck_l, stick) - L1)
        s = 0.0
        if L1 > 0:
            s += L1 ** 3 / (3 * B.fluted_core_inertia(dia, flutes, helix))
        if L2 > 0:
            s += ((L1 + L2) ** 3 - L1 ** 3) / (3 * I(nd))
        if stick - L1 - L2 > 0:
            s += (stick ** 3 - (L1 + L2) ** 3) / (3 * I(shank))
        return F / E * s

    def test_matches_old_closed_form(self):
        cases = [
            (10, .5, .5, 2.0, 1.0, None, 0.5, 4, 30, True),
            (3, .0625, .125, .5, .1875, .0625, .1875, 2, 30, True),
            (6, .25, .25, 1.5, .5, .2, 1.0, 3, 40, True),
            (6, .25, .375, 1.5, .5, .2, 1.0, 3, 40, False),
            (6, .25, .25, .4, .5, .2, 1.0, 4, 30, True),   # holder over flutes
            (6, .25, .25, .7, .5, .2, 1.0, 4, 30, True),   # holder over neck
            (6, .25, .25, 3.0, .5, None, 0.2, 4, 30, True),
        ]
        for c in cases:
            F, dia, shank, stick, fl, nd, nl, nof, hx, carb = c
            got = B.calculate_deflection(F, dia, shank, stick, fl, nd, nl, 0.0, nof, hx, carb)
            exp = self.old(*c)
            self.assertAlmostEqual(got, exp, delta=exp * 1e-6, msg=str(c))

    def test_tool_deflection_profile_equals_legacy(self):
        ph = GWizardPhysics(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "materials_database_clean.json"))
        kw = dict(diameter=.0625, shank_size=.125, stickout=.5, cut_depth=.1, cut_width=.03, feedrate=10.0,
                  rpm=20000, flutes=2, material_family="Aluminum - Wrought (6061)", flute_length=.1875,
                  neck_length=.1875, neck_diameter=.0625)
        legacy = ph.tool_deflection(**kw)
        prof = ToolProfile.from_legacy(.0625, 2, .1875, .125, .5)
        self.assertGreater(legacy, 0.0)
        self.assertAlmostEqual(ph.tool_deflection(profile=prof, **kw), legacy, delta=legacy * 1e-9)


if __name__ == '__main__':
    unittest.main()
