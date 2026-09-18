import unittest
from gwizard_physics import GWizardPhysics


class TestAutoSetAdvisory(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.physics = GWizardPhysics("materials_database_clean.json")

    def test_extended_and_severe_stickout_warnings(self):
        """Verify Machining Advisor audits tool stickout ratios."""
        dia = 0.500
        mat = "Steel - Medium Carbon Alloy (4130)"

        # 1. Normal stickout (2.5xD = 1.25") -> No stickout warnings
        tips_norm = self.physics.generate_advanced_strategies(
            material_family=mat, diameter=dia, cut_depth=0.200, cut_width=0.200,
            feedrate=30.0, rpm=3000.0, flutes=4, coating="AlTiN", deflection_inches=0.0005,
            stickout=1.25, flute_length=0.75, tool_type="Carbide Endmill", geometry="Square"
        )
        so_norm = [t for t in tips_norm if "Stickout" in t.get("title", "")]
        self.assertEqual(len(so_norm), 0)

        # 2. Extended stickout (3.8xD = 1.90") -> Extended Stickout Notice (info)
        tips_ext = self.physics.generate_advanced_strategies(
            material_family=mat, diameter=dia, cut_depth=0.200, cut_width=0.200,
            feedrate=30.0, rpm=3000.0, flutes=4, coating="AlTiN", deflection_inches=0.0010,
            stickout=1.90, flute_length=0.75, tool_type="Carbide Endmill", geometry="Square"
        )
        so_ext = [t for t in tips_ext if "Extended Stickout Notice" in t.get("title", "")]
        self.assertEqual(len(so_ext), 1)
        self.assertEqual(so_ext[0]["type"], "info")

        # 3. Severe stickout (5.0xD = 2.50") -> Severe Tool Stickout Warning (warning)
        tips_sev = self.physics.generate_advanced_strategies(
            material_family=mat, diameter=dia, cut_depth=0.200, cut_width=0.200,
            feedrate=30.0, rpm=3000.0, flutes=4, coating="AlTiN", deflection_inches=0.0025,
            stickout=2.50, flute_length=0.75, tool_type="Carbide Endmill", geometry="Square"
        )
        so_sev = [t for t in tips_sev if "Severe Tool Stickout Warning" in t.get("title", "")]
        self.assertEqual(len(so_sev), 1)
        self.assertEqual(so_sev[0]["type"], "warning")

    def test_aluminum_flute_count_advisory(self):
        """Verify Machining Advisor warns when 4+ flutes are selected for standard aluminum roughing."""
        dia = 0.500
        mat = "Aluminum - Wrought (6061)"

        # 1. 3 Flutes in Aluminum -> No warning
        tips_3fl = self.physics.generate_advanced_strategies(
            material_family=mat, diameter=dia, cut_depth=0.250, cut_width=0.150,
            feedrate=80.0, rpm=8000.0, flutes=3, coating="Uncoated", deflection_inches=0.0003,
            stickout=1.50, flute_length=1.00, tool_type="Carbide Endmill", geometry="Square",
            operation="Roughing"
        )
        al_3fl = [t for t in tips_3fl if "Aluminum Flute" in t.get("title", "")]
        self.assertEqual(len(al_3fl), 0)

        # 2. 4 Flutes in Aluminum (traditional roughing) -> Flute Evacuation Warning
        tips_4fl = self.physics.generate_advanced_strategies(
            material_family=mat, diameter=dia, cut_depth=0.250, cut_width=0.150,
            feedrate=80.0, rpm=8000.0, flutes=4, coating="Uncoated", deflection_inches=0.0003,
            stickout=1.50, flute_length=1.00, tool_type="Carbide Endmill", geometry="Square",
            operation="Roughing"
        )
        al_4fl = [t for t in tips_4fl if "Aluminum Flute Evacuation Warning" in t.get("title", "")]
        self.assertEqual(len(al_4fl), 1)
        self.assertEqual(al_4fl[0]["type"], "warning")

    def test_collet_gripping_on_flutes_warning(self):
        """Verify warning when flute length meets or exceeds tool stickout."""
        dia = 0.500
        mat = "Steel - Medium Carbon Alloy (4130)"

        # Flute length = 1.50", Stickout = 1.50" (collet gripping flutes)
        tips_grip = self.physics.generate_advanced_strategies(
            material_family=mat, diameter=dia, cut_depth=0.200, cut_width=0.200,
            feedrate=30.0, rpm=3000.0, flutes=4, coating="AlTiN", deflection_inches=0.0005,
            stickout=1.50, flute_length=1.50, tool_type="Carbide Endmill", geometry="Square"
        )
        grip = [t for t in tips_grip if "Collet Gripping on Flutes" in t.get("title", "")]
        self.assertEqual(len(grip), 1)
        self.assertEqual(grip[0]["type"], "warning")

    def test_neck_clearance_collision_advisory(self):
        """Verify neck clearance collision alerts only fire when physically engaged."""
        mat = "Stainless - 300 Series (316)"

        # 1. 3.2 mm End Mill with 0.125" default neck remnant, cut depth within flutes
        # Flute length = 0.125", cut depth = 0.0504" (1.28 mm), cut width = 0.063" (1.6 mm)
        tips_safe = self.physics.generate_advanced_strategies(
            material_family=mat, diameter=0.12598, cut_depth=0.0504, cut_width=0.063,
            feedrate=15.0, rpm=8000.0, flutes=4, coating="AlTiN", deflection_inches=0.0002,
            stickout=0.200, flute_length=0.125, neck_diameter=0.125, tool_type="Carbide Endmill", geometry="Square"
        )
        neck_safe = [t for t in tips_safe if "Neck Clearance Collision" in t.get("title", "")]
        self.assertEqual(len(neck_safe), 0, "Cut depth within flutes must not trigger neck collision alert")

        # 2. Relieved neck tool plunging beyond flutes into the neck zone
        # Dia = 0.500", Neck = 0.400" (max radial reach = 0.050")
        # Cut depth 0.75" > flute length 0.50", cut width 0.100" > max reach 0.050"
        tips_neck_crash = self.physics.generate_advanced_strategies(
            material_family=mat, diameter=0.500, cut_depth=0.750, cut_width=0.100,
            feedrate=30.0, rpm=3000.0, flutes=4, coating="AlTiN", deflection_inches=0.0005,
            stickout=1.50, flute_length=0.500, neck_diameter=0.400, tool_type="Carbide Endmill", geometry="Square"
        )
        neck_crash = [t for t in tips_neck_crash if "Neck Clearance Collision" in t.get("title", "")]
        self.assertEqual(len(neck_crash), 1, "Cut depth beyond flutes with excessive WOC must trigger collision alert")

        # 3. Form cutter (T-Slot) where neck is immediately above cutting teeth
        # Dia = 0.500", Neck = 0.250" (max reach = 0.125"), cut width = 0.150"
        tips_tslot_crash = self.physics.generate_advanced_strategies(
            material_family=mat, diameter=0.500, cut_depth=0.050, cut_width=0.150,
            feedrate=20.0, rpm=3000.0, flutes=4, coating="AlTiN", deflection_inches=0.0002,
            stickout=1.00, flute_length=0.0625, neck_diameter=0.250, tool_type="Form Tool", geometry="T-Slot"
        )
        tslot_crash = [t for t in tips_tslot_crash if "Neck Clearance Collision" in t.get("title", "")]
        self.assertEqual(len(tslot_crash), 1, "Form cutter exceeding radial neck reach must trigger collision alert")

    def test_auto_set_dials_deflection_safety(self):
        """Verify Auto-Set Dials cut parameters never exceed safe deflection limit for micro-tools."""
        dia = 0.0625
        stickout = 0.268
        flutes = 4
        flute_length = 0.1875
        corner_radius = 0.030
        family = "Stainless - 300 Series (316)"
        op = "Standard 3D Roughing"

        rec_doc, rec_woc, rec_lim = self.physics.recommend_cut_parameters(
            dia, dia, stickout, flutes, 13795, 0.00076, True, op, 0.5,
            'Bullnose / Radiused', max_hp=10.0, material_family=family,
            flute_length=flute_length, corner_radius=corner_radius
        )

        # Calculate actual deflection at recommended cut
        adj_ipt = self.physics.calc_adjusted_chipload(
            0.00076, rec_doc, rec_woc, dia, dia, operation=op, geometry='Bullnose / Radiused', corner_radius=corner_radius
        )
        feed = self.physics.calc_feedrate(13795, flutes, adj_ipt)
        deflect = self.physics.tool_deflection(
            dia, dia, stickout, rec_doc, rec_woc, feed, 13795, flutes,
            is_carbide=True, material_family=family, flute_length=flute_length,
            operation=op, geometry='Bullnose / Radiused', corner_radius=corner_radius
        )

        self.assertGreater(rec_doc, 0.0, "Recommended DOC must be positive")
        self.assertGreater(rec_woc, 0.0, "Recommended WOC must be positive")
        self.assertLessEqual(
            deflect, rec_lim,
            f"Deflection {deflect:.6f}\" must not exceed recommended safe limit {rec_lim:.6f}\""
        )


if __name__ == "__main__":
    unittest.main()
