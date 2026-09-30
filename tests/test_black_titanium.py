import unittest
import os
import sys
import json

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from gwizard_physics import GWizardPhysics, ASTMHardnessConverter
from app import app

class TestBlackTitanium5545(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.db_path = os.path.join(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')), 'materials_database_clean.json')
        with open(cls.db_path, 'r', encoding='utf-8') as f:
            cls.db = json.load(f)
        cls.physics = GWizardPhysics(cls.db_path)
        cls.client = app.test_client()

    def test_materials_database_entry(self):
        # 1. Family check
        fam_names = [f['name'] for f in self.db.get('material_families', [])]
        self.assertIn('Black Titanium 5545', fam_names)

        # 2. Machinability factors check
        mf = self.physics.machinability.get('Black Titanium 5545')
        self.assertIsNotNone(mf, "Black Titanium 5545 missing from machinability dictionary")
        self.assertEqual(mf.get('unit_hp'), 1.20)
        self.assertAlmostEqual(mf.get('density', 0), 0.1987, places=4)
        self.assertEqual(mf.get('minBHN'), 300)
        self.assertEqual(mf.get('maxBHN'), 340)
        self.assertEqual(mf.get('youngs_modulus_ksi'), 15200)
        self.assertTrue(mf.get('work_hardening'))
        self.assertAlmostEqual(mf.get('springback_factor', 0), 0.0010, places=4)

    def test_specific_alloys_and_properties(self):
        alloys = [a for a in self.physics.specific_alloys if a.get('alloy') == 'Black Titanium 5545']
        self.assertGreaterEqual(len(alloys), 2, "Should be present under both Black Titanium and Titanium Alloy families")

        families = [a.get('family') for a in alloys]
        self.assertIn('Black Titanium 5545', families)
        self.assertIn('Titanium Alloy', families)

        for a in alloys:
            self.assertEqual(a.get('hardness'), '33.7 HRC')
            if 'tensile_strength_mpa' in a:
                self.assertEqual(a.get('tensile_strength_mpa'), 1012)
                self.assertEqual(a.get('yield_strength_mpa'), 777)
                self.assertEqual(a.get('elongation_pct'), 13.5)
                self.assertEqual(a.get('density_g_cm3'), 5.5)

    def test_astm_hardness_conversion(self):
        # 33.7 HRC converts via ASTM E140 interpolation to ~316.3 HB
        parsed_hb = ASTMHardnessConverter.parse_hardness('33.7 HRC')
        self.assertIsNotNone(parsed_hb)
        self.assertAlmostEqual(parsed_hb, 316.3, delta=1.0)

    def test_cutting_parameters_lookup(self):
        sfm = self.physics.get_base_sfm('Black Titanium 5545', 'Carbide Endmill')
        self.assertGreater(sfm, 0)
        self.assertEqual(sfm, 122.0)

        hss_sfm = self.physics.get_base_sfm('Black Titanium 5545', 'HSS Endmill')
        self.assertEqual(hss_sfm, 49.0)

        ipt = self.physics.get_base_ipt('Black Titanium 5545', 'Carbide Endmill', 0.5)
        self.assertGreater(ipt, 0)

    def test_alloy_hardness_scaling(self):
        base_sfm = self.physics.get_base_sfm('Black Titanium 5545', 'Carbide Endmill')
        base_ipt = self.physics.get_base_ipt('Black Titanium 5545', 'Carbide Endmill', 0.5)

        scaled_sfm, scaled_ipt = self.physics.apply_alloy_hardness_scaling(
            'Black Titanium 5545', 'Black Titanium 5545', base_sfm, base_ipt
        )
        # 316.3 HB is below the family midpoint (320 HB), so under GWizard's bounded linear model,
        # SFM scales up toward the upper boundary of the sfmrange.
        self.assertGreater(scaled_sfm, base_sfm)
        self.assertAlmostEqual(scaled_sfm, 126.51, delta=0.5)
        self.assertEqual(scaled_ipt, base_ipt)

    def test_springback_and_deflection(self):
        # Test springback calculation with Black Titanium 5545
        sb, err, wear_comp = self.physics.calc_springback_and_deflection(
            material_family='Black Titanium 5545',
            diameter=0.5,
            cut_depth=0.25,
            cut_width=0.05,
            feedrate=20.0,
            rpm=3000.0,
            flutes=4,
            deflection_inches=0.0003,
            alloy='Black Titanium 5545'
        )
        self.assertGreater(sb, 0.0005, "Springback factor 0.0010 should yield noticeable springback")
        self.assertAlmostEqual(err, 0.0003 + sb, places=6)
        self.assertEqual(wear_comp, -err)

    def test_flask_api_data_dropdowns(self):
        resp = self.client.get('/api/data')
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()

        self.assertIn('Black Titanium 5545', data['families'])
        found_alloy = any(a.get('alloy') == 'Black Titanium 5545' for a in data['alloys'])
        self.assertTrue(found_alloy, "Black Titanium 5545 should be returned in alloys list")

if __name__ == '__main__':
    unittest.main()
