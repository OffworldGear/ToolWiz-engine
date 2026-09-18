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

    def test_contextual_geometry_and_tap_dropdown(self):
        """Validate that geometry directly drives tap_type without separate tapType field."""
        d_in = 1.6 / 25.4
        pitch_in = 0.35 / 25.4

        # 1. Geometry = 'form' (Roll tap)
        res_form = self.client.post('/api/calculate', json={
            'family': 'Stainless - PH Series (17-4)',
            'alloy': '17-4 PH H1150-M',
            'tool': 'Tapping',
            'diameter': d_in,
            'pitch': pitch_in,
            'operation': 'Rigid Tapping',
            'geometry': 'form',
            'flutes': 2,
            'is_carbide': False,
            'coating': 'TiCN',
            'isMetric': True,
            'stickout': 0.5,
            'aggressiveness': 50.0
        }).get_json()
        self.assertTrue(res_form['success'])
        self.assertEqual(res_form['tap_type'], 'form')
        self.assertEqual(res_form['tap_drill']['drill_name'], '1.45 mm')

        # 2. Geometry = 'spiral_flute' (Cut tap)
        res_cut = self.client.post('/api/calculate', json={
            'family': 'Stainless - PH Series (17-4)',
            'alloy': '17-4 PH H1150-M',
            'tool': 'Tapping',
            'diameter': d_in,
            'pitch': pitch_in,
            'operation': 'Rigid Tapping',
            'geometry': 'spiral_flute',
            'flutes': 2,
            'is_carbide': False,
            'coating': 'TiCN',
            'isMetric': True,
            'stickout': 0.5,
            'aggressiveness': 50.0
        }).get_json()
        self.assertTrue(res_cut['success'])
        self.assertEqual(res_cut['tap_type'], 'spiral_flute')
        self.assertIn(res_cut['tap_drill']['drill_name'], ['#55', '1.25 mm', '1.3 mm', '1.30 mm'])

        # 3. Verify /api/data contains Tapping and Carbide Thread Mill
        data_res = self.client.get('/api/data').get_json()
        self.assertIn('Tapping', data_res['tools'])
        self.assertIn('Carbide Thread Mill', data_res['tools'])

    def test_tslot_cutter_kinematics_and_collision(self):
        """Test user's 4mm dia, 0.5mm kerf, 2mm neck, 4mm shank T-Slot cutter."""
        d_in = 4.0 / 25.4
        neck_d_in = 2.0 / 25.4
        shank_d_in = 4.0 / 25.4
        thick_in = 0.5 / 25.4

        # 1. Safe Cut: WOC = 0.5 mm (under 1.0 mm reach)
        res_safe = self.client.post('/api/calculate', json={
            'family': 'Aluminum - Wrought (6061)',
            'alloy': '6061-T6',
            'tool': 'Carbide Endmill',
            'diameter': d_in,
            'shankDiameter': shank_d_in,
            'neckDiameter': neck_d_in,
            'cutterThickness': thick_in,
            'fluteLength': thick_in,
            'neckLength': 6.0 / 25.4,
            'stickout': 10.0 / 25.4,
            'flutes': 4,
            'cutDepth': thick_in,
            'cutWidth': 0.5 / 25.4,
            'operation': 'Slotting',
            'geometry': 'T-Slot',
            'isCarbide': True,
            'coating': 'Uncoated',
            'isMetric': True
        }).get_json()
        self.assertTrue(res_safe['success'])
        # Radial reach limit must be exactly (4 - 2) / 2 = 1.0 mm
        expected_reach_in = (d_in - neck_d_in) / 2.0
        self.assertAlmostEqual(res_safe['max_radial_reach'], expected_reach_in, places=4)
        # Recommended DOC must match cutter thickness (0.5 mm = 0.0197 in)
        self.assertAlmostEqual(res_safe['rec_doc'], thick_in, places=4)
        self.assertAlmostEqual(res_safe['rec_woc'], d_in * 0.12, places=4)
        # Verify no collision tip
        collision_tips = [t for t in res_safe.get('tips', []) if 'Collision' in t.get('title', '')]
        self.assertEqual(len(collision_tips), 0)

        # 2. Collision Overreach: WOC = 1.2 mm (> 1.0 mm reach)
        res_coll = self.client.post('/api/calculate', json={
            'family': 'Aluminum - Wrought (6061)',
            'alloy': '6061-T6',
            'tool': 'Carbide Endmill',
            'diameter': d_in,
            'shankDiameter': shank_d_in,
            'neckDiameter': neck_d_in,
            'cutterThickness': thick_in,
            'fluteLength': thick_in,
            'neckLength': 6.0 / 25.4,
            'stickout': 10.0 / 25.4,
            'flutes': 4,
            'cutDepth': thick_in,
            'cutWidth': 1.2 / 25.4,
            'operation': 'Slotting',
            'geometry': 'T-Slot',
            'isCarbide': True,
            'coating': 'Uncoated',
            'isMetric': True
        }).get_json()
        self.assertTrue(res_coll['success'])
        collision_tips = [t for t in res_coll.get('tips', []) if 'Collision' in t.get('title', '') or 'Clearance' in t.get('title', '')]
        self.assertGreater(len(collision_tips), 0)

    def test_dovetail_cutter_kinematics(self):
        """Test Harvey 3/8\" 60-degree Dovetail Cutter (0.250\" neck, 0.125\" head height)."""
        res = self.client.post('/api/calculate', json={
            'family': 'Aluminum - Wrought (6061)',
            'alloy': '6061-T6',
            'tool': 'Carbide Endmill',
            'diameter': 0.375,
            'shankDiameter': 0.375,
            'neckDiameter': 0.250,
            'cutterThickness': 0.125,
            'fluteLength': 0.125,
            'neckLength': 0.500,
            'stickout': 0.750,
            'flutes': 4,
            'cutDepth': 0.125,
            'cutWidth': 0.045,
            'operation': 'Slotting',
            'geometry': 'Dovetail',
            'isCarbide': True,
            'coating': 'Uncoated'
        }).get_json()
        self.assertTrue(res['success'])
        # Radial reach limit = (0.375 - 0.250) / 2 = 0.0625"
        self.assertAlmostEqual(res['max_radial_reach'], 0.0625, places=4)
        self.assertAlmostEqual(res['rec_doc'], 0.125, places=4)
        self.assertLessEqual(res['rec_woc'], 0.0625)
        self.assertGreater(res['rpm'], 6000)
        self.assertGreater(res['feedrate'], 30.0)

    def test_chamfer_mill_kinematics(self):
        """Test 1/4\" 90-degree Chamfer Mill with depth-based effective diameter."""
        res = self.client.post('/api/calculate', json={
            'family': 'Aluminum - Wrought (6061)',
            'alloy': '6061-T6',
            'tool': 'Carbide Endmill',
            'diameter': 0.250,
            'shankDiameter': 0.250,
            'fluteLength': 0.250,
            'stickout': 0.750,
            'flutes': 4,
            'cutDepth': 0.035,
            'cutWidth': 0.035,
            'operation': 'Chamfering',
            'geometry': 'Chamfer Mill',
            'isCarbide': True,
            'coating': 'Uncoated'
        }).get_json()
        self.assertTrue(res['success'])
        # Recommended DOC & WOC for chamfering
        self.assertAlmostEqual(res['rec_doc'], 0.0375, places=4)
        self.assertAlmostEqual(res['rec_woc'], 0.0375, places=4)
        self.assertGreaterEqual(res['rpm'], 8000)
        self.assertGreaterEqual(res['feedrate'], 20.0)
    def test_spindle_rpm_limited_micro_tool(self):
        """
        Validate spindle RPM limitation physics:
        When a 1/32\" micro endmill (ideal at ~80k RPM) runs on a 16,000 RPM spindle:
        1. RPM must be clamped to machine limit (16,000 RPM).
        2. Feedrate must scale down in direct lockstep (ratio = 16k / 80k = 0.20x).
        3. Chip load per tooth (adjusted IPT) must remain 100% constant/invariant.
        4. True Chip Thickness must not drop below minimum (no rubbing).
        5. Spindle RPM Limited diagnostic advisory tip must be returned.
        """
        payload_base = {
            'family': 'Aluminum - Wrought (6061)',
            'alloy': '6061-T6',
            'tool': 'Carbide Endmill',
            'diameter': 0.03125,
            'flutes': 3,
            'stickout': 0.09375,
            'operation': 'Adaptive Roughing',
            'geometry': 'Square',
            'isCarbide': True,
            'coating': 'Uncoated'
        }

        # 1. Unconstrained machine (120,000 RPM ceiling - above ideal ~103k RPM)
        res_unconstrained = self.client.post('/api/calculate', json={
            **payload_base,
            'cutDepth': 0.0025,
            'cutWidth': 0.014,
            'maxRpm': 120000
        }).get_json()
        self.assertTrue(res_unconstrained['success'])
        self.assertFalse(res_unconstrained['is_spindle_limited'])
        self.assertAlmostEqual(res_unconstrained['rpm'], 103217, delta=1000)
        self.assertAlmostEqual(res_unconstrained['sfm'], 844.4, delta=5.0)
        self.assertGreater(res_unconstrained['feedrate'], 70.0)

        # 2. Spindle-limited machine (16,000 RPM ceiling)
        res_limited = self.client.post('/api/calculate', json={
            **payload_base,
            'cutDepth': 0.0025,
            'cutWidth': 0.014,
            'maxRpm': 16000
        }).get_json()
        self.assertTrue(res_limited['success'])
        self.assertTrue(res_limited['is_spindle_limited'])
        self.assertEqual(res_limited['rpm'], 16000)
        self.assertAlmostEqual(res_limited['ideal_rpm'], 103217, delta=1000)
        self.assertAlmostEqual(res_limited['sfm'], 130.9, delta=2.0)

        # Assert Chipload Invariance
        self.assertAlmostEqual(res_limited['adj_ipt'], res_unconstrained['adj_ipt'], places=5)

        # Assert Linear Feedrate Scaling
        expected_feed = res_unconstrained['feedrate'] * (16000.0 / res_unconstrained['rpm'])
        self.assertAlmostEqual(res_limited['feedrate'], expected_feed, delta=0.5)

        # Assert Deflection Safety and Invariance
        self.assertAlmostEqual(res_limited['deflection'], res_unconstrained['deflection'], places=4)

        # Assert Diagnostic Advisory Tip
        spindle_tips = [t for t in res_limited.get('tips', []) if t.get('title') == 'Spindle RPM Limited']
        self.assertEqual(len(spindle_tips), 1)
        self.assertIn('limits surface speed', spindle_tips[0]['message'])
        self.assertIn('synchronized your feedrate', spindle_tips[0]['message'])

        # Assert NO rubbing warning (since IPT is properly maintained)
        rub_tips = [t for t in res_limited.get('tips', []) if 'Rubbing' in t.get('title', '')]
        self.assertEqual(len(rub_tips), 0)

if __name__ == '__main__':
    unittest.main()


