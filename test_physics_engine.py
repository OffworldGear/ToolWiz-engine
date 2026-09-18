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

    def test_tslot_cutter_alignment_with_gwizard(self):
        """
        Benchmark: 4mm dia, 0.5mm thick, 4FL carbide T-slot cutter (2mm neck, 4mm shank).
        Verify G-Wizard speed, feed, chipload, and diagnostic alignment.
        """
        dia = 4.0 / 25.4
        thick = 0.5 / 25.4
        neck = 2.0 / 25.4
        radial_doc = (dia - neck) / 2.0  # 1.0 mm

        # 1. Aluminum 6061-T6
        sfm_al = self.physics.get_base_sfm("Aluminum - Wrought (6061)", "Carbide Endmill", geometry="T-Slot", diameter=dia, is_carbide=True)
        self.assertAlmostEqual(sfm_al, 900.0, delta=1.0)
        rpm_al = self.physics.calc_rpm(sfm_al, dia, max_rpm=16000)
        self.assertEqual(rpm_al, 16000.0)
        ipt_al = self.physics.get_base_ipt("Aluminum - Wrought (6061)", "Carbide Endmill", dia, geometry="T-Slot", cut_depth=thick, cut_width=radial_doc, flutes=4, is_carbide=True)
        self.assertGreaterEqual(ipt_al, 0.00030)
        feed_al = self.physics.calc_feedrate(rpm_al, 4, ipt_al)
        self.assertTrue(450.0 <= feed_al * 25.4 <= 2100.0)

        # Verify no false rubbing or chatter warnings
        tips_al = self.physics.generate_advanced_strategies(
            "Aluminum", dia, thick, radial_doc, feed_al, rpm_al, 4, "Uncoated", 0.0001,
            tool_type="Carbide Endmill", stickout=1.5, geometry="T-Slot", flute_length=thick
        )
        titles = [t["title"] for t in tips_al]
        self.assertNotIn("Rubbing & Heat Trap Warning", titles)
        self.assertNotIn("Resonance & Chatter Penalty", titles)

        # 2. 17-4 PH Stainless
        sfm_ss = self.physics.get_base_sfm("Stainless - PH Series (17-4)", "Carbide Endmill", geometry="T-Slot", diameter=dia, is_carbide=True)
        self.assertAlmostEqual(sfm_ss, 225.0, delta=1.0)
        rpm_ss = self.physics.calc_rpm(sfm_ss, dia, max_rpm=16000)
        self.assertTrue(5000 <= rpm_ss <= 5600)
        ipt_ss = self.physics.get_base_ipt("Stainless - PH Series (17-4)", "Carbide Endmill", dia, geometry="T-Slot", cut_depth=thick, cut_width=radial_doc, flutes=4, is_carbide=True)
        self.assertGreaterEqual(ipt_ss, 0.00030)
        feed_ss = self.physics.calc_feedrate(rpm_ss, 4, ipt_ss)
        self.assertTrue(150.0 <= feed_ss * 25.4 <= 600.0)

        # 3. 1018 Steel
        sfm_st = self.physics.get_base_sfm("Steel - Low Carbon (1020)", "Carbide Endmill", geometry="T-Slot", diameter=dia, is_carbide=True)
        self.assertAlmostEqual(sfm_st, 262.5, delta=1.0)
        rpm_st = self.physics.calc_rpm(sfm_st, dia, max_rpm=16000)
        self.assertTrue(6000 <= rpm_st <= 6600)
        ipt_st = self.physics.get_base_ipt("Steel - Low Carbon (1020)", "Carbide Endmill", dia, geometry="T-Slot", cut_depth=thick, cut_width=radial_doc, flutes=4, is_carbide=True)
        self.assertGreaterEqual(ipt_st, 0.00020)
        feed_st = self.physics.calc_feedrate(rpm_st, 4, ipt_st)
        self.assertTrue(150.0 <= feed_st * 25.4 <= 850.0)

    def test_neck_clearance_and_collision_diagnostics(self):
        """Verify physical radial reach calculations and collision alert diagnostics."""
        # 4.0 mm cutter with 2.0 mm neck
        dia_in = 4.0 / 25.4
        neck_in = 2.0 / 25.4
        max_reach_in = (dia_in - neck_in) / 2.0
        self.assertAlmostEqual(max_reach_in * 25.4, 1.0, places=4)

        # 1. Safe Cut Width (0.8 mm < 1.0 mm reach)
        safe_woc = 0.8 / 25.4
        tips_safe = self.physics.generate_advanced_strategies(
            "Aluminum - Wrought (6061)", dia_in, 0.5 / 25.4, safe_woc, 50.0, 10000, 4, "Uncoated", 0.0001,
            tool_type="Carbide Endmill", stickout=1.0, geometry="T-Slot", neck_diameter=neck_in
        )
        safe_titles = [t["title"] for t in tips_safe]
        self.assertNotIn("Neck Clearance Collision", safe_titles)

        # 2. Collision Cut Width (1.2 mm > 1.0 mm reach)
        collision_woc = 1.2 / 25.4
        tips_collision = self.physics.generate_advanced_strategies(
            "Aluminum - Wrought (6061)", dia_in, 0.5 / 25.4, collision_woc, 50.0, 10000, 4, "Uncoated", 0.0001,
            tool_type="Carbide Endmill", stickout=1.0, geometry="T-Slot", neck_diameter=neck_in
        )
        collision_titles = [t["title"] for t in tips_collision]
        self.assertIn("Neck Clearance Collision", collision_titles)
        neck_tip = next(t for t in tips_collision if t["title"] == "Neck Clearance Collision")
        self.assertEqual(neck_tip["type"], "critical")
        self.assertIn("exceeds maximum neck clearance", neck_tip["message"])

        # 3. Tool Holder Stickout Collision (Cut depth 1.2" > Stickout 1.0")
        tips_holder = self.physics.generate_advanced_strategies(
            "Aluminum - Wrought (6061)", dia_in, 1.2, safe_woc, 50.0, 10000, 4, "Uncoated", 0.0001,
            tool_type="Carbide Endmill", stickout=1.0, geometry="T-Slot", neck_diameter=neck_in
        )
        holder_titles = [t["title"] for t in tips_holder]
        self.assertIn("Tool Holder Collision", holder_titles)

    def test_hem_thermal_sfm_multiplier(self):
        """Verify High Efficiency Milling (HEM) low-immersion thermal cooling speed boost."""
        d = 0.5
        # Standard operations should receive 1.0x (no thermal boost)
        self.assertEqual(self.physics.calc_hem_thermal_sfm_multiplier(0.05, d, operation="Roughing"), 1.0)
        self.assertEqual(self.physics.calc_hem_thermal_sfm_multiplier(0.05, d, operation="Slotting"), 1.0)
        
        # Adaptive operations with ae/D >= 0.25 receive 1.0x
        self.assertEqual(self.physics.calc_hem_thermal_sfm_multiplier(0.15, d, operation="Adaptive Roughing"), 1.0) # 0.15 / 0.5 = 0.30 >= 0.25
        self.assertAlmostEqual(self.physics.calc_hem_thermal_sfm_multiplier(0.075, d, operation="Adaptive Roughing"), 1.14, places=2) # 0.075 / 0.5 = 0.15 -> 1.14x

        # Adaptive operations with ae/D = 0.05 receive +28% boost (scaling up to +35% as ae approaches 0)
        mult_05 = self.physics.calc_hem_thermal_sfm_multiplier(0.025, d, operation="Adaptive Roughing") # 0.025 / 0.5 = 0.05 -> 1.28x
        self.assertAlmostEqual(mult_05, 1.28, places=2)

    def test_adaptive_roughing_doc_and_mrr_scaling(self):
        """Verify Adaptive Roughing recommends deep axial engagement and produces higher MRR than standard roughing."""
        d = 0.5
        flute_len = 1.25
        stickout = 1.5
        mat = "Aluminum - Wrought (6061)"
        base_sfm = self.physics.get_base_sfm(mat, "Carbide Endmill", diameter=d, is_carbide=True)
        base_ipt = self.physics.get_base_ipt(mat, "Carbide Endmill", d, flutes=3, is_carbide=True)

        # 1. Standard Roughing recommendations
        rpm_trad = self.physics.calc_rpm(base_sfm, d, max_rpm=16000)
        doc_trad, woc_trad, _ = self.physics.recommend_cut_parameters(
            d, d, stickout, 3, rpm_trad, base_ipt, True, "Roughing", 0.5,
            material_family=mat, flute_length=flute_len
        )
        feed_trad = self.physics.calc_feedrate(rpm_trad, 3, self.physics.calc_adjusted_chipload(base_ipt, doc_trad, woc_trad, d, d, operation="Roughing"))
        mrr_trad = self.physics.calc_mrr(doc_trad, woc_trad, feed_trad, diameter=d)

        # 2. Adaptive Roughing recommendations (Square Endmill)
        doc_ad, woc_ad, _ = self.physics.recommend_cut_parameters(
            d, d, stickout, 3, rpm_trad, base_ipt, True, "Adaptive Roughing", 0.5,
            material_family=mat, flute_length=flute_len
        )
        hem_mult = self.physics.calc_hem_thermal_sfm_multiplier(woc_ad, d, operation="Adaptive Roughing")
        rpm_ad = self.physics.calc_rpm(base_sfm * hem_mult, d, max_rpm=16000)
        feed_ad = self.physics.calc_feedrate(rpm_ad, 3, self.physics.calc_adjusted_chipload(base_ipt, doc_ad, woc_ad, d, d, operation="Adaptive Roughing"))
        mrr_ad = self.physics.calc_mrr(doc_ad, woc_ad, feed_ad, diameter=d)

        # Assertions for Square Endmill:
        # DOC in Adaptive should be at least 1.5x D (up to flute length)
        self.assertGreaterEqual(doc_ad, 0.75)
        self.assertGreater(doc_ad, doc_trad)
        # MRR in Adaptive should be significantly greater than Traditional Roughing (>= 1.5x)
        self.assertGreater(mrr_ad, mrr_trad * 1.5)

        # 3. Ball Endmill Comparison
        doc_ball_trad, woc_ball_trad, _ = self.physics.recommend_cut_parameters(
            d, d, stickout, 3, rpm_trad, base_ipt, True, "Roughing", 0.5,
            geometry="Ball", material_family=mat, flute_length=flute_len
        )
        doc_ball_ad, woc_ball_ad, _ = self.physics.recommend_cut_parameters(
            d, d, stickout, 3, rpm_trad, base_ipt, True, "Adaptive Roughing", 0.5,
            geometry="Ball", material_family=mat, flute_length=flute_len
        )
        # Ball tool traditional DOC capped at 0.25 D (0.125")
        self.assertLessEqual(doc_ball_trad, 0.126)
        # Ball tool adaptive DOC deep engagement (>= 1.5x D)
        self.assertGreaterEqual(doc_ball_ad, 0.75)

    def test_micro_tool_adaptive_recommendations(self):
        """1/16\" 4FL AlTiN micro-tool must recommend CAM-standard shallow stepdown and wide optimal load."""
        d = 0.0625  # 1/16 in (1.5875 mm)
        mat = 'Steel - Tool (H13)'
        sfm = self.physics.get_base_sfm(mat, 'Carbide Endmill', diameter=d, is_carbide=True)
        sfm *= self.physics.get_coating_multiplier('AlTiN', mat)
        rpm = self.physics.calc_rpm(sfm, d, max_rpm=12000)

        # Micro tool surface speed should hit ~12,000 RPM in tool steel/titanium
        self.assertAlmostEqual(rpm, 12000, delta=100)

        base_ipt = self.physics.get_base_ipt(mat, 'Carbide Endmill', d, flutes=4, is_carbide=True)
        rec_doc, rec_woc, _ = self.physics.recommend_cut_parameters(
            d, d, d * 3.0, 4, rpm, base_ipt, True, 'Adaptive Roughing', 0.5,
            material_family=mat, flute_length=d * 3.0
        )

        # Recommended WOC must match optimal load 0.635 mm (0.025" / 40% D)
        self.assertAlmostEqual(rec_woc, 0.025, places=4)
        self.assertAlmostEqual(rec_woc * 25.4, 0.635, places=3)

        # Recommended DOC must match max roughing stepdown 0.152 mm (0.006" / ~10% D)
        self.assertAlmostEqual(rec_doc, 0.006, places=4)
        self.assertAlmostEqual(rec_doc * 25.4, 0.152, places=2)

        # Feedrate must be >= 20 IPM (> 500 mm/min)
        adj_ipt = self.physics.calc_adjusted_chipload(base_ipt, rec_doc, rec_woc, d, d, operation='Adaptive Roughing')
        feed = self.physics.calc_feedrate(rpm, 4, adj_ipt)
        self.assertGreaterEqual(feed, 20.0)

if __name__ == '__main__':
    unittest.main()


