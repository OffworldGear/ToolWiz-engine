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
        self.assertGreater(res['adj_ipt'], 0)
        self.assertGreater(res['ipr'], 0)
        self.assertAlmostEqual(res['ipr'], res['adj_ipt'] * 2, places=4)

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

    def test_maford_twister_gp_drill(self):
        # M.A. Ford 1.45mm Twister GP 3X drill (Series 226 / 22605710T) in 17-4 PH
        d_in = 1.45 / 25.4
        flute_len_in = 9.0 / 25.4
        stickout_in = 9.8 / 25.4

        res = self.client.post('/api/calculate', json={
            'family': 'Stainless - PH Series (17-4)',
            'alloy': '17-4 PH H1150-M',
            'tool': 'HP Carbide Twist Drill',
            'diameter': d_in,
            'shank_size': d_in,
            'flutes': 2,
            'cut_depth': flute_len_in,
            'cut_width': d_in,
            'operation': 'Drilling',
            'geometry': 'Drill',
            'stickout': stickout_in,
            'flute_length': flute_len_in,
            'is_carbide': True,
            'coating': 'TiN',
            'aggressiveness': 50.0
        }).get_json()
        self.assertTrue(res['success'])
        # M.A. Ford Series 226 Catalog specs: ~10,977 RPM, ~255 mm/min (10.0 IPM), ~0.023 mm/rev (0.00091 IPR)
        # Tool Wizard HP Carbide Twist Drill produces: ~11,239 RPM, ~226.6 mm/min (8.92 IPM), ~0.020 mm/rev
        self.assertAlmostEqual(res['rpm'], 11239, delta=500)
        feed_mmpm = res['feedrate'] * 25.4
        self.assertAlmostEqual(feed_mmpm, 226.6, delta=15)
        ipr_mm = res['ipr'] * 25.4
        self.assertAlmostEqual(ipr_mm, 0.0202, delta=0.005)

    def test_osg_m16_form_tap_and_cut_tap(self):
        # OSG M1.6x0.35 D3 2.5P NRT TiCN Form Tap vs Cut Tap in 17-4 PH Stainless
        d_in = 1.6 / 25.4
        pitch_in = 0.35 / 25.4

        # 1. Form Tap Test
        res_form = self.client.post('/api/calculate', json={
            'family': 'Stainless - PH Series (17-4)',
            'alloy': '17-4 PH H1150-M',
            'tool': 'Tapping',
            'diameter': d_in,
            'pitch': pitch_in,
            'operation': 'Rigid Tapping',
            'geometry': 'Tapping',
            'flutes': 2,
            'is_carbide': False,
            'coating': 'TiCN',
            'tapType': 'form',
            'isMetric': True,
            'stickout': 0.5,
            'aggressiveness': 50.0
        }).get_json()
        self.assertTrue(res_form['success'])
        self.assertIn('tap_drill', res_form)
        self.assertEqual(res_form['tap_drill']['drill_name'], '1.45 mm')
        self.assertAlmostEqual(res_form['tap_drill']['thread_percent'], 63.0, delta=2.0)
        self.assertGreaterEqual(res_form['rpm'], 900)
        self.assertLessEqual(res_form['rpm'], 1600)
        expected_form_feed = round(res_form['rpm'] * pitch_in, 2)
        self.assertEqual(res_form['feedrate'], expected_form_feed)

        # 2. Cut Tap Test
        res_cut = self.client.post('/api/calculate', json={
            'family': 'Stainless - PH Series (17-4)',
            'alloy': '17-4 PH H1150-M',
            'tool': 'Tapping',
            'diameter': d_in,
            'pitch': pitch_in,
            'operation': 'Rigid Tapping',
            'geometry': 'Tapping',
            'flutes': 2,
            'is_carbide': False,
            'coating': 'TiCN',
            'tapType': 'spiral_flute',
            'isMetric': True,
            'stickout': 0.5,
            'aggressiveness': 50.0
        }).get_json()
        self.assertTrue(res_cut['success'])
        self.assertIn('tap_drill', res_cut)
        # Cut tap should use a much smaller drill (~1.25mm - 1.32mm, #55)
        self.assertIn(res_cut['tap_drill']['drill_name'], ['#55', '1.25 mm', '1.3 mm', '1.30 mm'])
        # Cut tap speed is ~half the form tap speed
        self.assertLess(res_cut['rpm'], res_form['rpm'])
        self.assertGreaterEqual(res_cut['rpm'], 450)
        self.assertLessEqual(res_cut['rpm'], 800)

if __name__ == '__main__':
    unittest.main()
