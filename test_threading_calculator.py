import unittest
import json
from app import app
from gwizard_physics import GWizardPhysics, CuttingKinematics

class TestThreadingCalculator(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()
        self.physics = GWizardPhysics("materials_db.json")

    def test_get_thread_standards(self):
        res = self.client.get('/api/threads/standards')
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertTrue(data.get('success'))
        families = data.get('families', [])
        self.assertIn('ISO Coarse', families)
        self.assertIn('UNC', families)
        self.assertIn('UNF', families)
        
        iso_sizes = data.get('sizes_by_family', {}).get('ISO Coarse', [])
        self.assertIn('M1.6-0.35', iso_sizes)

    def test_m1_6_form_tap_sizing(self):
        payload = {
            'family': 'ISO Coarse',
            'size': 'M1.6-0.35',
            'class': '6H',
            'type': 'Internal',
            'isForm': True,
            'isMetric': True,
            'leadStyle': 'form',
            'threadDepth': 4.0
        }
        res = self.client.post('/api/threads/calculate', json=payload)
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertTrue(data.get('success'))
        
        th = data.get('thread')
        self.assertEqual(th['size'], 'M1.6-0.35')
        self.assertAlmostEqual(th['pitch_mm'], 0.35, places=2)
        
        drills = data.get('drills', [])
        self.assertTrue(len(drills) > 0)
        
        # Check 1.45 mm drill specifically
        drill_145 = next((d for d in drills if d['name'] == '1.45 mm'), None)
        self.assertIsNotNone(drill_145, '1.45 mm drill must be in candidate drill list')
        self.assertEqual(drill_145['pct_thread'], 63.0)
        self.assertTrue(drill_145['is_target'], '1.45 mm must be in recommended sweet spot')
        self.assertEqual(drill_145['status'], 'recommended')
        
        # Check 1.40 mm drill (too tight for tough alloys)
        drill_140 = next((d for d in drills if d['name'] == '1.40 mm'), None)
        self.assertIsNotNone(drill_140)
        self.assertEqual(drill_140['pct_thread'], 84.0)
        self.assertEqual(drill_140['status'], 'tight')

        # Check 1.50 mm drill (loose engagement)
        drill_150 = next((d for d in drills if d['name'] == '1.50 mm'), None)
        self.assertIsNotNone(drill_150)
        self.assertEqual(drill_150['pct_thread'], 42.0)
        self.assertEqual(drill_150['status'], 'loose')

    def test_m1_6_cut_tap_sizing(self):
        payload = {
            'family': 'ISO Coarse',
            'size': 'M1.6-0.35',
            'class': '6H',
            'type': 'Internal',
            'isForm': False,
            'isMetric': True,
            'leadStyle': 'plug',
            'threadDepth': 4.0
        }
        res = self.client.post('/api/threads/calculate', json=payload)
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertTrue(data.get('success'))
        
        drills = data.get('drills', [])
        drill_125 = next((d for d in drills if d['name'] == '1.25 mm'), None)
        self.assertIsNotNone(drill_125)
        self.assertAlmostEqual(drill_125['pct_thread'], 76.9, delta=0.5)
        self.assertTrue(drill_125['is_target'])

    def test_blind_hole_clearance(self):
        pitch_in = 0.35 / 25.4
        depth_in = 5.0 / 25.4
        res = CuttingKinematics.calc_blind_hole_clearance(pitch_in, lead_style='form', thread_depth_in=depth_in, is_metric=True)
        self.assertAlmostEqual(res['clearance_mm'], 2.225, places=2)
        self.assertAlmostEqual(res['total_depth_mm'], 7.225, places=2)

    def test_unc_1_4_20(self):
        payload = {
            'family': 'UNC',
            'size': '1/4-20',
            'class': '2B',
            'type': 'Internal',
            'isForm': False,
            'isMetric': False,
            'leadStyle': 'plug',
            'threadDepth': 0.5
        }
        res = self.client.post('/api/threads/calculate', json=payload)
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertTrue(data.get('success'))
        
        drills = data.get('drills', [])
        drill_7 = next((d for d in drills if d['name'] == '#7'), None)
        self.assertIsNotNone(drill_7)
        self.assertAlmostEqual(drill_7['pct_thread'], 75.4, delta=0.5)
        self.assertTrue(drill_7['is_target'])

if __name__ == '__main__':
    unittest.main()
