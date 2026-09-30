import unittest
import math
from gwizard_physics import GWizardPhysics, CuttingKinematics, CuttingMechanics
import app as flask_app


class TestHighFeedMilling(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.physics = GWizardPhysics("materials_database_clean.json")
        cls.client = flask_app.app.test_client()
        cls.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def test_axial_chip_thinning_factor(self):
        """Verify Axial Chip Thinning Factor (ACTF) calculations for high feed and bullnose."""
        # 1. Dedicated High Feed Mill (lead angle ~13.5 deg -> ACTF ~ 4.28x)
        actf_hf = CuttingKinematics.axial_chip_thinning_factor(
            cut_depth=0.020, diameter=0.500, geometry="High Feed", operation="High Feed Milling"
        )
        self.assertAlmostEqual(actf_hf, 1.0 / math.sin(math.radians(13.5)), places=2)
        self.assertGreater(actf_hf, 4.0)

        # 2. Bullnose / Radiused end mill with corner radius = 0.060"
        # At very shallow DOC (0.005" = 8.3% of R), ACTF should thin significantly (~2.5x)
        actf_bn_shallow = CuttingKinematics.axial_chip_thinning_factor(
            cut_depth=0.005, diameter=0.500, geometry="Radiused", corner_radius=0.060, operation="High Feed Milling"
        )
        self.assertGreater(actf_bn_shallow, 2.0)

        # At moderate DOC (0.015" = 25% of R), ACTF is ~1.5x
        actf_bn_mid = CuttingKinematics.axial_chip_thinning_factor(
            cut_depth=0.015, diameter=0.500, geometry="Radiused", corner_radius=0.060, operation="High Feed Milling"
        )
        self.assertGreater(actf_bn_mid, 1.3)
        self.assertLess(actf_bn_mid, actf_bn_shallow)

        # Beyond corner radius (DOC = 0.080" > 0.060"), vertical flute engaged, ACTF drops to 1.0
        actf_bn_deep = CuttingKinematics.axial_chip_thinning_factor(
            cut_depth=0.080, diameter=0.500, geometry="Radiused", corner_radius=0.060, operation="High Feed Milling"
        )
        self.assertEqual(actf_bn_deep, 1.0)

        # 3. Square End Mill produces NO axial chip thinning
        actf_square_trad = CuttingKinematics.axial_chip_thinning_factor(
            cut_depth=0.020, diameter=0.500, geometry="Square", operation="Roughing"
        )
        self.assertEqual(actf_square_trad, 1.0)

    def test_adjusted_chipload_high_feed_slotting(self):
        """Verify adjusted chipload in High Feed full slotting (window machining)."""
        base_ipt = 0.003
        dia = 0.500
        doc = 0.015
        woc = 0.500  # Full slotting (WOC = D)

        adj_ipt_trad = self.physics.calc_adjusted_chipload(
            base_ipt, doc, woc, dia, dia, operation="Slotting", geometry="Square"
        )
        # In traditional full slotting, RCTF = 1.0 and ACTF = 1.0, so adj_ipt == base_ipt
        self.assertAlmostEqual(adj_ipt_trad, base_ipt, places=5)

        adj_ipt_hf = self.physics.calc_adjusted_chipload(
            base_ipt, doc, woc, dia, dia, operation="High Feed Slotting / Window Profiling", geometry="High Feed"
        )
        # In high feed full slotting, RCTF = 1.0, but ACTF is ~4.28x
        self.assertGreater(adj_ipt_hf, base_ipt * 4.0)

    def test_deflection_reduction_in_high_feed(self):
        """Verify high feed cutting force redirects axially, dramatically lowering lateral deflection."""
        dia = 0.500
        shank = 0.500
        stickout = 2.0
        doc = 0.020
        woc = 0.325
        feed = 120.0
        rpm = 5000.0
        flutes = 4
        mat = "Steel - Carbon (1018)"

        # Standard roughing deflection
        deflect_trad = self.physics.tool_deflection(
            dia, shank, stickout, doc, woc, feed, rpm, flutes,
            material_family=mat, operation="Roughing", geometry="Square"
        )

        # High feed deflection
        deflect_hf = self.physics.tool_deflection(
            dia, shank, stickout, doc, woc, feed, rpm, flutes,
            material_family=mat, operation="High Feed Milling", geometry="High Feed"
        )

        self.assertGreater(deflect_trad, 0.0)
        self.assertGreater(deflect_hf, 0.0)
        # High feed lateral deflection should be significantly lower than traditional square roughing
        self.assertLess(deflect_hf, deflect_trad * 0.50)

    def test_recommend_cut_parameters_high_feed(self):
        """Verify recommended DOC and WOC for High Feed Milling and Slotting."""
        dia = 0.500
        shank = 0.500
        stickout = 1.5
        flutes = 4
        rpm = 5000
        base_ipt = 0.003
        mat = "Steel - Carbon (1018)"

        # 1. Dedicated High Feed Mill
        rec_doc, rec_woc, _ = self.physics.recommend_cut_parameters(
            dia, shank, stickout, flutes, rpm, base_ipt,
            operation="High Feed Milling", geometry="High Feed", material_family=mat
        )
        # DOC should be ~0.035 * D (0.0175"), WOC should be 0.65 * D (0.325")
        self.assertAlmostEqual(rec_doc, 0.0175, places=3)
        self.assertAlmostEqual(rec_woc, 0.325, places=3)

        # 2. High Feed Slotting / Window Profiling (WOC = 1.0 * D)
        rec_doc_slot, rec_woc_slot, _ = self.physics.recommend_cut_parameters(
            dia, shank, stickout, flutes, rpm, base_ipt,
            operation="High Feed Slotting / Window Profiling", geometry="High Feed", material_family=mat
        )
        self.assertAlmostEqual(rec_doc_slot, 0.0175, places=3)
        self.assertAlmostEqual(rec_woc_slot, 0.500, places=3)

        # 3. Bullnose End Mill in High Feed (R = 0.060")
        rec_doc_bn, rec_woc_bn, _ = self.physics.recommend_cut_parameters(
            dia, shank, stickout, flutes, rpm, base_ipt,
            operation="High Feed Milling", geometry="Radiused", material_family=mat, corner_radius=0.060
        )
        # Bullnose DOC should be 20% of corner radius (0.012")
        self.assertAlmostEqual(rec_doc_bn, 0.012, places=3)
        self.assertAlmostEqual(rec_woc_bn, 0.325, places=3)

    def test_advisory_critical_rule_violations(self):
        """Verify that true rule violations are marked as 'critical' (red) in the Advisor."""
        dia = 0.500
        mat = "Steel - Carbon (1018)"

        # 1. Square Endmill with High Feed operation -> CRITICAL RED
        tips_square = self.physics.generate_advanced_strategies(
            material_family=mat, diameter=dia, cut_depth=0.020, cut_width=0.300,
            feedrate=100.0, rpm=5000.0, flutes=4, coating="AlTiN", deflection_inches=0.0002,
            operation="High Feed Milling", geometry="Square"
        )
        crit_square = [t for t in tips_square if t.get("type") == "critical" and "Incompatibility" in t.get("title", "")]
        self.assertEqual(len(crit_square), 1)

        # 2. Bullnose with zero corner radius -> CRITICAL RED
        tips_zero_rad = self.physics.generate_advanced_strategies(
            material_family=mat, diameter=dia, cut_depth=0.020, cut_width=0.300,
            feedrate=100.0, rpm=5000.0, flutes=4, coating="AlTiN", deflection_inches=0.0002,
            operation="High Feed Milling", geometry="Radiused", corner_radius=0.0
        )
        crit_rad = [t for t in tips_zero_rad if t.get("type") == "critical" and "Violation" in t.get("title", "")]
        self.assertEqual(len(crit_rad), 1)

        # 3. Dedicated High Feed Mill with excessive DOC (> 0.05 * D = 0.025") -> CRITICAL RED
        tips_hf_doc = self.physics.generate_advanced_strategies(
            material_family=mat, diameter=dia, cut_depth=0.040, cut_width=0.300,
            feedrate=100.0, rpm=5000.0, flutes=4, coating="AlTiN", deflection_inches=0.0002,
            operation="High Feed Milling", geometry="High Feed"
        )
        crit_doc = [t for t in tips_hf_doc if t.get("type") == "critical" and "DOC Exceeded" in t.get("title", "")]
        self.assertEqual(len(crit_doc), 1)

        # 4. Bullnose with DOC exceeding 35% of Corner Radius (R=0.060, max 0.021", cut 0.035") -> CRITICAL RED
        tips_bn_doc = self.physics.generate_advanced_strategies(
            material_family=mat, diameter=dia, cut_depth=0.035, cut_width=0.300,
            feedrate=100.0, rpm=5000.0, flutes=4, coating="AlTiN", deflection_inches=0.0002,
            operation="High Feed Milling", geometry="Radiused", corner_radius=0.060
        )
        crit_bn = [t for t in tips_bn_doc if t.get("type") == "critical" and "Threshold Exceeded" in t.get("title", "")]
        self.assertEqual(len(crit_bn), 1)

        # 5. High Feed Slotting / Window Machining advice for tabs
        tips_slot = self.physics.generate_advanced_strategies(
            material_family=mat, diameter=dia, cut_depth=0.015, cut_width=0.500,
            feedrate=150.0, rpm=5000.0, flutes=4, coating="AlTiN", deflection_inches=0.0001,
            operation="High Feed Slotting / Window Profiling", geometry="High Feed"
        )
        tab_tip = [t for t in tips_slot if "Tab Preservation" in t.get("title", "")]
        self.assertEqual(len(tab_tip), 1)
        self.assertEqual(tab_tip[0]["type"], "tip")

    def test_ramping_limit_high_feed(self):
        """Verify ramping angle is limited to <= 1.5 deg for High Feed tools."""
        angle_hf, _, _ = self.physics.calc_ramping(
            "Aluminum - Wrought (6061)", 0.500, 100.0, geometry="High Feed", aggressiveness=1.0
        )
        self.assertLessEqual(angle_hf, 1.5)

    def test_api_calculate_high_feed(self):
        """Verify Flask /api/calculate endpoint handles High Feed Milling and Slotting."""
        payload = {
            "family": "Steel - Carbon (1018)",
            "tool": "HP Carbide High Feed Endmill",
            "diameter": 0.500,
            "flutes": 4,
            "cutDepth": 0.018,
            "cutWidth": 0.325,
            "stickout": 1.5,
            "isCarbide": True,
            "geometry": "High Feed",
            "operation": "High Feed Milling",
            "coating": "AlTiN"
        }
        res = self.client.post("/api/calculate", json=payload)
        data = res.get_json()
        self.assertTrue(data["success"])
        self.assertGreater(data["feedrate"], 60.0)
        self.assertGreater(data["mrr"], 0.0)

    def test_api_data_tool_groups(self):
        """Verify /api/data returns tool_groups containing the new high feed tools."""
        res = self.client.get("/api/data")
        data = res.get_json()
        end_mill_group = next((g for g in data["tool_groups"] if g["group"] == "End Mills"), None)
        self.assertIsNotNone(end_mill_group)
        tools = end_mill_group["tools"]
        self.assertIn("HP Carbide High Feed Endmill", tools)
        self.assertIn("Carbide High Feed Endmill", tools)
        self.assertIn("HP Carbide Bull Nose Endmill", tools)
        self.assertIn("Carbide Bull Nose Endmill", tools)


if __name__ == "__main__":
    unittest.main()
