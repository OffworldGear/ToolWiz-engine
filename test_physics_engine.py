import unittest
import math
from gwizard_physics import (
    GWizardPhysics, ASTMHardnessConverter, CuttingKinematics,
    CuttingMechanics, BeamDeflectionEngine
)

class TestToolWizPhysics(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.physics = GWizardPhysics('materials_database_clean.json')

    def test_astm_hardness_conversion(self):
        """Verify ASTM E140 hardness conversions and string parsing."""
        self.assertAlmostEqual(ASTMHardnessConverter.hrc_to_brinell(20.0), 226.0, delta=1.0)
        self.assertAlmostEqual(ASTMHardnessConverter.hrc_to_brinell(45.0), 421.0, delta=1.0)
        self.assertAlmostEqual(ASTMHardnessConverter.hrc_to_brinell(60.0), 654.0, delta=2.0)
        self.assertAlmostEqual(ASTMHardnessConverter.hrc_to_brinell(62.0), 688.0, delta=2.0)

        # String parsing
        self.assertAlmostEqual(ASTMHardnessConverter.parse_hardness('62 HRC'), 688.0, delta=2.0)
        self.assertEqual(ASTMHardnessConverter.parse_hardness('60-90'), 90.0)
        self.assertEqual(ASTMHardnessConverter.parse_hardness('250 HB'), 250.0)
        self.assertEqual(ASTMHardnessConverter.parse_hardness(180), 180.0)

    def test_material_database_unit_hp(self):
        """Verify that all material families have proper unit_hp mapped to mf."""
        alum = self.physics.machinability.get('Aluminum - Wrought (6061)')
        self.assertIsNotNone(alum)
        self.assertEqual(alum.get('unit_hp'), 0.32)

        steel = self.physics.machinability.get('Steel - Low Carbon (1020)')
        self.assertIsNotNone(steel)
        self.assertEqual(steel.get('unit_hp'), 1.1)

        tool_steel = self.physics.machinability.get('Steel - Tool (H13)')
        self.assertIsNotNone(tool_steel)
        self.assertEqual(tool_steel.get('unit_hp'), 2.1)

        copper = self.physics.machinability.get('Copper Alloy - Wrought')
        self.assertIsNotNone(copper)
        self.assertEqual(copper.get('unit_hp'), 0.64)

    def test_analytical_beam_deflection(self):
        """Verify cantilever deflection matches classical Euler-Bernoulli beam theory."""
        # Solid carbide cylinder: D=0.5 in, L=1.5 in, F=100 lbs, E=90e6 psi
        F = 100.0
        E = 90000000.0
        d = 0.5
        L = 1.5
        I_solid = (math.pi * (d**4)) / 64.0
        exact_deflection = (F * (L**3)) / (3.0 * E * I_solid)

        engine_deflection = BeamDeflectionEngine.calculate_deflection(
            cutting_force_lbs=F,
            diameter=d,
            shank_diameter=d,
            stickout=L,
            flute_length=0.0,  # Pure solid shank
            is_carbide=True
        )
        self.assertAlmostEqual(engine_deflection, exact_deflection, places=9)

    def test_flute_core_reduction(self):
        """Fluted end mill must be more flexible than solid cylinder of same OD."""
        d = 0.5
        i_solid = BeamDeflectionEngine.solid_circular_inertia(d)
        i_fluted = BeamDeflectionEngine.fluted_core_inertia(d, flutes=4, helix_angle=30.0)
        # Fluted section inertia should be between 40% and 60% of solid cylinder
        ratio = i_fluted / i_solid
        self.assertGreater(ratio, 0.40)
        self.assertLess(ratio, 0.65)

    def test_chip_thinning_factors(self):
        """Verify Radial Chip Thinning Factor (RCTF)."""
        d = 0.5
        # 100% engagement (slotting) -> RCTF = 1.0
        self.assertEqual(CuttingKinematics.radial_chip_thinning_factor(0.5, d), 1.0)
        # 50% engagement -> RCTF = 1.0
        self.assertEqual(CuttingKinematics.radial_chip_thinning_factor(0.25, d), 1.0)
        # 10% engagement (ae = 0.05) -> RCTF > 1.0
        rctf_10 = CuttingKinematics.radial_chip_thinning_factor(0.05, d)
        self.assertGreater(rctf_10, 1.5)
        self.assertLessEqual(rctf_10, 5.0)

    def test_minimum_chip_thickness_scaling(self):
        """Verify MCT scales continuously from macro to micro tools."""
        mct_macro_altin = CuttingKinematics.get_minimum_chip_thickness('AlTiN', 'Carbide Endmill', diameter=0.500)
        mct_micro_altin = CuttingKinematics.get_minimum_chip_thickness('AlTiN', 'Carbide Endmill', diameter=0.0625)
        mct_micro_uncoated = CuttingKinematics.get_minimum_chip_thickness('Uncoated', 'Carbide Endmill', diameter=0.0625)

        # Micro tool AlTiN should be sharper than macro tool AlTiN
        self.assertLess(mct_micro_altin, mct_macro_altin)
        # Uncoated micro tool should be sharper than coated micro tool
        self.assertLess(mct_micro_uncoated, mct_micro_altin)

    def test_cpm_magnacut_scaling(self):
        """Hardened MagnaCut (62 HRC) must receive significant feeds/speeds scaling."""
        sfm_base = self.physics.get_base_sfm('Steel - Tool (H13)', 'Carbide Endmill')
        ipt_base = self.physics.get_base_ipt('Steel - Tool (H13)', 'Carbide Endmill', 0.5)

        sfm_sc, ipt_sc = self.physics.apply_alloy_hardness_scaling(
            'Steel - Tool (H13)', 'CPM MagnaCut (Hardened ~62 HRC)', sfm_base, ipt_base
        )
        # 62 HRC is ~688 HB vs minBHN ~185 for H13 tool steel -> must be scaled down
        self.assertLess(sfm_sc, sfm_base * 0.60)
        self.assertLess(ipt_sc, ipt_base * 0.85)

    def test_micro_tool_recommendations(self):
        """1/16\" micro-tool in Toughmet C72900 must receive safe non-deflecting recommendations."""
        d = 0.0625
        flute_len = 0.188
        stickout = 0.188
        sfm = self.physics.get_base_sfm('Copper Alloy - Wrought', 'Carbide Endmill')
        ipt = self.physics.get_base_ipt('Copper Alloy - Wrought', 'Carbide Endmill', d)
        sfm, ipt = self.physics.apply_alloy_hardness_scaling(
            'Copper Alloy - Wrought', 'C72900 - Toughmet 3 Nickel Bronze (Annealed)', sfm, ipt
        )
        rpm = self.physics.calc_rpm(sfm, d)
        doc, woc, def_lim = self.physics.recommend_cut_parameters(
            d, d, stickout, 4, rpm, ipt, True, 'Roughing', 0.5,
            material_family='Copper Alloy - Wrought', flute_length=flute_len
        )
        # Recommended DOC must be positive, <= flute length, and safe for micro-tool
        self.assertGreater(doc, 0.0)
        self.assertLessEqual(doc, flute_len)
        # Deflection at recommended cut must not exceed target limit
        feed = self.physics.calc_feedrate(rpm, 4, ipt)
        deflect = self.physics.tool_deflection(d, d, stickout, doc, woc, feed, rpm, 4, True, 'Copper Alloy - Wrought')
        self.assertLessEqual(deflect, def_lim * 1.05)

    def test_macro_tool_power_capping(self):
        """A 2\" cutter taking large cuts must cap cut depth to stay under max_hp."""
        d = 2.0
        rpm = 800.0
        ipt = 0.005
        # Very low max_hp constraint (e.g. 2 HP spindle)
        doc, woc, _ = self.physics.recommend_cut_parameters(
            d, d, 2.0, 6, rpm, ipt, True, 'Roughing', 0.5,
            cutter_thickness=0.5, max_hp=2.0, material_family='Steel - Low Carbon (1020)', flute_length=1.0
        )
        feed = self.physics.calc_feedrate(rpm, 6, ipt)
        _, _, _, est_hp = CuttingMechanics.calc_cutting_forces(d, doc, woc, feed, rpm, 6, unit_hp=1.1)
        self.assertLessEqual(est_hp, 2.2)  # Within 10% iteration step boundary

if __name__ == '__main__':
    unittest.main()
