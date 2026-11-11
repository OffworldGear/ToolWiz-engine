"""M6 v1 clean-up: monotonic deflection limit, ramp/plunge from the un-thinned chip load."""
import os
import sys
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from gwizard_physics import CuttingMechanics, GWizardPhysics
from pipeline import CutRequest, run_cut

OPS = ["Roughing", "Standard Roughing", "3D Roughing", "Facing", "Slotting", "Adaptive Roughing",
       "High Feed Milling", "Semi-Finishing", "Finishing"]


class TestDeflectionLimitMonotonic(unittest.TestCase):
    def test_non_decreasing_in_diameter(self):
        diams = [i / 1000.0 for i in range(5, 1001, 3)] + [0.124, 0.125, 0.126]
        diams = sorted(set(diams))
        for op in OPS:
            for a in (0.0, 0.25, 0.5, 0.75, 1.0):
                prev = 0.0
                for d in diams:
                    lim = CuttingMechanics.calc_deflection_limit(d, op, a)
                    self.assertGreaterEqual(lim + 1e-15, prev, f"{op} a={a} D={d}")
                    prev = lim

    def test_no_step_at_one_eighth(self):
        lo = CuttingMechanics.calc_deflection_limit(0.125, "Roughing", 0.5)
        hi = CuttingMechanics.calc_deflection_limit(0.126, "Roughing", 0.5)
        self.assertGreaterEqual(hi, lo)


class TestRampFromUnthinnedChipload(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.physics = GWizardPhysics('materials_database_clean.json')

    def _run(self, family, d, op, woc, doc, geo="Square"):
        return run_cut(self.physics, CutRequest(
            family=family, tool="Carbide Endmill", geometry=geo, operation=op, coating="AlTiN",
            diameter=d, flutes=4, flute_length=d * 1.5, stickout=d * 3.5, shank_diameter=d,
            cut_depth=doc, cut_width=woc, max_rpm=60000.0))

    def test_ramp_not_above_slotting_feed_at_same_rpm(self):
        for fam in ("Aluminum - Wrought (6061)", "Steel - Medium Carbon (1045)", "Titanium Alloy"):
            for d in (0.125, 0.25, 0.5):
                r = self._run(fam, d, "Adaptive Roughing", d * 0.1, d * 1.5)
                slot_ipt = self.physics.calc_adjusted_chipload(
                    r.base_ipt, r.doc, d, d, r.effective_diameter, operation="Slotting", geometry="Square",
                    tool_type="Carbide Endmill")
                slot_feed = self.physics.calc_feedrate(r.rpm, 4, slot_ipt)
                self.assertLessEqual(r.ramp_feed, slot_feed + 1e-6, (fam, d))
                self.assertLessEqual(r.plunge_feed, r.ramp_feed + 1e-6)

    def test_ramp_independent_of_radial_thinning(self):
        a = self._run("Steel - Medium Carbon (1045)", 0.5, "Adaptive Roughing", 0.025, 0.75)
        b = self._run("Steel - Medium Carbon (1045)", 0.5, "Adaptive Roughing", 0.15, 0.75)
        self.assertGreater(a.feed_ipm, b.feed_ipm)          # thinning raises the cutting feed
        # rpm differs (HEM speed boost), so compare ramp feed per revolution
        self.assertAlmostEqual(a.ramp_feed / a.rpm, b.ramp_feed / b.rpm, delta=0.02 * b.ramp_feed / b.rpm)


if __name__ == "__main__":
    unittest.main()
