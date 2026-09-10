import unittest
from app import app

class TestToolFamiliesValidation(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()

    def test_drilling_kinematics(self):
        # Drill: WOC is locked to tool diameter, lateral deflection is zero, plunge is 90 deg
        res = self.client.post('/api/calculate', json={
            'material_family': 'Steel',
            'alloy': '1018 Plain Carbon Steel',
            'tool': 'Carbide Twist Drill',
            'diameter': 0.25,
            'shank_size': 0.25,
            'flutes': 2,
            'cut_depth': 0.5,
            'cut_width': 0.25,
            'operation': 'Drilling',
            'geometry': 'Drill',
            'stickout': 1.0,
            'flute_length': 1.0,
            'is_carbide': True,
            'coating': 'AlTiN',
            'aggressiveness': 50.0
        }).get_json()
        self.assertTrue(res['success'])
        self.assertEqual(res['deflection'], 0.0)
        self.assertEqual(res['ramp_angle'], 90.0)
        self.assertGreater(res['rpm'], 0)
        self.assertGreater(res['feedrate'], 0)

    def test_reaming_kinematics(self):
        # Reamer: No radial chip thinning multiplication, lateral deflection zero
        res = self.client.post('/api/calculate', json={
            'material_family': 'Steel',
            'alloy': '1018 Plain Carbon Steel',
            'tool': 'Carbide Reamer',
            'diameter': 0.25,
            'shank_size': 0.25,
            'flutes': 4,
            'cut_depth': 0.75,
            'cut_width': 0.25,
            'operation': 'Precision Reaming',
            'geometry': 'Square',
            'stickout': 1.0,
            'flute_length': 1.0,
            'is_carbide': True,
            'coating': 'Uncoated',
            'aggressiveness': 50.0
        }).get_json()
        self.assertTrue(res['success'])
        self.assertEqual(res['deflection'], 0.0)
        self.assertEqual(res['ramp_angle'], 90.0)

    def test_rigid_tapping_kinematics(self):
        # Rigid Tapping: Feedrate = RPM * Pitch, lateral deflection zero
        pitch = 0.05 # 20 TPI
        res = self.client.post('/api/calculate', json={
            'material_family': 'Steel',
            'alloy': '1018 Plain Carbon Steel',
            'tool': 'Carbide Tapping',
            'diameter': 0.25,
            'shank_size': 0.25,
            'flutes': 4,
            'cut_depth': 0.5,
            'cut_width': 0.25,
            'pitch': pitch,
            'operation': 'Rigid Tapping',
            'geometry': 'Square',
            'stickout': 1.0,
            'flute_length': 1.0,
            'is_carbide': True,
            'coating': 'Uncoated',
            'aggressiveness': 50.0
        }).get_json()
        self.assertTrue(res['success'])
        self.assertEqual(res['deflection'], 0.0)
        self.assertEqual(res['ramp_angle'], 90.0)
        expected_feed = round(res['rpm'] * pitch, 2)
        self.assertEqual(res['feedrate'], expected_feed)

    def test_form_tool_keyseat(self):
        # Keyseat cutter: Kerf locks to cutter thickness, ramping is locked to 0
        res = self.client.post('/api/calculate', json={
            'material_family': 'Aluminum',
            'alloy': '6061-T6 Aluminum',
            'tool': 'Carbide Saws & Woodruff Cutters',
            'diameter': 0.5,
            'shank_size': 0.375,
            'flutes': 6,
            'cut_depth': 0.125,
            'cutter_thickness': 0.125,
            'neck_diameter': 0.25,
            'neck_length': 0.5,
            'cut_width': 0.05,
            'operation': 'Slotting',
            'geometry': 'Keyseat',
            'stickout': 1.0,
            'flute_length': 0.125,
            'is_carbide': True,
            'coating': 'AlTiN',
            'aggressiveness': 50.0
        }).get_json()
        self.assertTrue(res['success'])
        self.assertGreater(res['deflection'], 0.0)
        self.assertEqual(res['ramp_angle'], 0.0)
        self.assertEqual(res['ramp_feed'], 0.0)
        self.assertEqual(res['rec_doc'], 0.125)

    def test_thread_mill(self):
        # Thread Mill: Radial thread depth recommendation is 10% diameter
        res = self.client.post('/api/calculate', json={
            'material_family': 'Steel',
            'alloy': '1018 Plain Carbon Steel',
            'tool': 'Carbide Thread Mill',
            'diameter': 0.25,
            'shank_size': 0.25,
            'flutes': 4,
            'cut_depth': 0.375,
            'cut_width': 0.025,
            'operation': 'Thread Milling - ID',
            'geometry': 'Thread Mill',
            'stickout': 1.0,
            'flute_length': 0.5,
            'is_carbide': True,
            'coating': 'AlTiN',
            'aggressiveness': 50.0
        }).get_json()
        self.assertTrue(res['success'])
        self.assertEqual(res['rec_woc'], 0.025)

    def test_standard_milling(self):
        # Standard Endmill: Ramping > 0, normal deflection calculation
        res = self.client.post('/api/calculate', json={
            'material_family': 'Aluminum',
            'alloy': '6061-T6 Aluminum',
            'tool': 'Carbide Endmill',
            'diameter': 0.5,
            'shank_size': 0.5,
            'flutes': 3,
            'cut_depth': 0.5,
            'cut_width': 0.1,
            'operation': 'Adaptive Roughing',
            'geometry': 'Square',
            'stickout': 1.5,
            'flute_length': 1.0,
            'is_carbide': True,
            'coating': 'AlTiN',
            'aggressiveness': 50.0
        }).get_json()
        self.assertTrue(res['success'])
        self.assertGreater(res['ramp_angle'], 0.0)
        self.assertGreater(res['deflection'], 0.0)

if __name__ == '__main__':
    unittest.main()
