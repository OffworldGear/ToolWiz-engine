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


if __name__ == "__main__":
    unittest.main()
