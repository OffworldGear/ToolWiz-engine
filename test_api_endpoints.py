import unittest
import json
from app import app

class TestAPIEndpoints(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()

    def test_get_data(self):
        res = self.client.get('/api/data')
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertIn('families', data)
        self.assertIn('tools', data)
        self.assertIn('alloys', data)
        self.assertNotIn('Tool', data['tools'])

    def test_calculate_micro_tool(self):
        payload = {
            'family': 'Copper Alloy - Wrought',
            'alloy': 'C72900 - Toughmet 3 Nickel Bronze (Annealed)',
            'tool': 'TiAlN Carbide Endmill',
            'coating': 'AlTiN',
            'geometry': 'Square',
            'diameter': 0.0625,
            'flutes': 4,
            'cutDepth': 0.003,
            'cutWidth': 0.031,
            'stickout': 0.188,
            'fluteLength': 0.188,
            'operation': 'Roughing',
            'aggressiveness': 50.0,
            'maxRpm': 16000,
            'maxHp': 10.0,
            'runout': 0.0001
        }
        res = self.client.post('/api/calculate', json=payload)
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertTrue(data['success'])
        self.assertGreater(data['rpm'], 0)
        self.assertGreater(data['feedrate'], 0)
        self.assertLess(data['deflection'], 0.0002)
        self.assertGreater(data['rec_doc'], 0.0)
        self.assertLessEqual(data['rec_doc'], 0.188)

    def test_calculate_magnacut_hardened(self):
        payload = {
            'family': 'Steel - Tool (H13)',
            'alloy': 'CPM MagnaCut (Hardened ~62 HRC)',
            'tool': 'Carbide Endmill',
            'coating': 'AlTiN',
            'geometry': 'Square',
            'diameter': 0.5,
            'flutes': 4,
            'cutDepth': 0.100,
            'cutWidth': 0.100,
            'stickout': 1.5,
            'operation': 'Roughing',
            'aggressiveness': 50.0,
            'maxRpm': 16000,
            'maxHp': 10.0
        }
        res = self.client.post('/api/calculate', json=payload)
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertTrue(data['success'])
        # Scaled SFM in 62 HRC must be heavily reduced
        self.assertLess(data['sfm'], 250)

    def test_calculate_large_face_mill(self):
        payload = {
            'family': 'Aluminum - Wrought (6061)',
            'alloy': '',
            'tool': 'Indexable End Or Face Mill',
            'coating': 'Uncoated',
            'geometry': 'Square',
            'diameter': 2.0,
            'flutes': 5,
            'cutDepth': 0.080,
            'cutWidth': 1.500,
            'stickout': 2.5,
            'operation': 'Facing',
            'aggressiveness': 60.0,
            'maxRpm': 10000,
            'maxHp': 5.0
        }
        res = self.client.post('/api/calculate', json=payload)
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertTrue(data['success'])
        self.assertGreater(data['mrr'], 0)
        self.assertGreater(data['feedrate'], 10.0)

    def test_calculate_for_fusion(self):
        payload = {
            'family': 'Aluminum - Wrought (6061)',
            'diameter': 0.25,
            'flutes': 3,
            'operation': 'Adaptive Roughing',
            'aggressiveness': 50.0,
            'maxRpm': 16000,
            'maxHp': 10.0
        }
        res = self.client.post('/api/calculate_for_fusion', json=payload)
        self.assertEqual(res.status_code, 200)
        data = res.get_json()
        self.assertTrue(data['success'])
        self.assertIn('doc', data)
        self.assertIn('woc', data)
        self.assertIn('feed', data)

if __name__ == '__main__':
    unittest.main()
