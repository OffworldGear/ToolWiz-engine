import os
import unittest
from gwizard_physics import GWizardPhysics

class TestTSlotBenchmark(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.physics = GWizardPhysics('materials_database_clean.json')

    def test_tslot_cutter(self):
        d = 4.0 / 25.4
        t = 0.5 / 25.4
        n = 2.0 / 25.4
        w = (d - n) / 2.0

        # Aluminum
        sfm = self.physics.get_base_sfm('Aluminum - Wrought (6061)', 'Carbide Endmill', geometry='T-Slot', diameter=d, is_carbide=True)
        self.assertAlmostEqual(sfm, 900.0, delta=1.0)
        rpm = self.physics.calc_rpm(sfm, d, 16000)
        self.assertEqual(rpm, 16000.0)
        ipt = self.physics.get_base_ipt('Aluminum - Wrought (6061)', 'Carbide Endmill', d, geometry='T-Slot', cut_depth=t, cut_width=w, flutes=4, is_carbide=True)
        self.assertGreaterEqual(ipt, 0.00030)
        feed = self.physics.calc_feedrate(rpm, 4, ipt)
        self.assertTrue(450.0 <= feed * 25.4 <= 2100.0)

if __name__ == '__main__':
    unittest.main()
