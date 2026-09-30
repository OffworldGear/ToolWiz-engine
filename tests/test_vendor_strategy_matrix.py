import os
import sys
import json
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from app import app
from gwizard_physics import GWizardPhysics

class TestVendorStrategyMatrix(unittest.TestCase):
    """
    Automated Industrial Vendor Benchmark Strategy Test Suite.
    Benchmarks cutting parameters against canonical manufacturer catalog data
    (Harvey Tool, Helical Solutions, Garr Tool, M.A. Ford, OSG) across geometries,
    size tiers (Micro, Intermediate, Medium, Macro), and strategies.
    """
    @classmethod
    def setUpClass(cls):
        cls.client = app.test_client()
        cls.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
        db_path = os.path.join(os.path.dirname(__file__), '..', 'materials_database_clean.json')
        cls.physics = GWizardPhysics(db_path)
        
        bench_path = os.path.join(os.path.dirname(__file__), 'benchmarks', 'vendor_catalog_data.json')
        with open(bench_path, 'r', encoding='utf-8') as f:
            cls.benchmark_data = json.load(f)

    def test_vendor_strategy_matrix(self):
        print("\n" + "=" * 112)
        print("                 INDUSTRIAL VENDOR STRATEGY BENCHMARK EVALUATION")
        print("=" * 112)
        print(f"{'Benchmark ID':<42} | {'RPM':<7} | {'SFM':<6} | {'Feed (IPM)':<11} | {'DOC (in)':<9} | {'WOC (in)':<9} | {'Status'}")
        print("-" * 112)

        passed_count = 0
        total_count = len(self.benchmark_data['benchmarks'])

        for tc in self.benchmark_data['benchmarks']:
            b_id = tc['id']
            dia = tc['diameter']
            flutes = tc['flutes']
            fam = tc['material_family']
            alloy = tc.get('alloy', '')
            coating = tc.get('coating', 'Uncoated')
            geo = tc['geometry']
            strat = tc['strategy']
            stickout = tc.get('stickout', dia * 3.0)
            flute_len = tc.get('flute_length', dia * 1.5)
            cutter_thick = tc.get('cutter_thickness', 0.125)
            neck_dia = tc.get('neck_diameter', dia)
            neck_len = tc.get('neck_length', 0.5)
            shank_dia = tc.get('shank_diameter', dia)
            cr = tc.get('corner_radius', 0.0)
            pitch = tc.get('pitch', 0.05)
            target = tc['target']
            max_rpm = tc.get('max_rpm', 80000 if dia <= 0.03125 else 30000)
            tool_val = tc.get('tool') or tc.get('tool_type') or ('Tapping' if 'tap' in strat.lower() or geo == 'form' else ('End Mill' if 'mill' in geo.lower() or geo in ['Square', 'Ball', 'Radiused'] else geo))

            # Post calculation request to Tool Wizard engine
            payload = {
                'family': fam,
                'alloy': alloy,
                'tool': tool_val,
                'coating': coating,
                'geometry': geo,
                'operation': strat,
                'diameter': dia,
                'flutes': flutes,
                'stickout': stickout,
                'fluteLength': flute_len,
                'cutterThickness': cutter_thick,
                'neckDiameter': neck_dia,
                'neckLength': neck_len,
                'shankDiameter': shank_dia,
                'cornerRadius': cr,
                'pitch': pitch,
                'isCarbide': tc.get('is_carbide', True),
                'maxRpm': max_rpm,
                'maxHp': 15.0
            }
            if 'cut_depth' in tc:
                payload['cutDepth'] = tc['cut_depth']
            if 'cut_width' in tc:
                payload['cutWidth'] = tc['cut_width']

            res = self.client.post('/api/calculate', json=payload)
            self.assertEqual(res.status_code, 200)
            d = res.get_json()
            self.assertTrue(d.get('success', False))

            rpm = d['rpm']
            sfm = d['sfm']
            feed = d['feedrate']
            doc = d['rec_doc']
            woc = d['rec_woc']

            # Calculate maximum achievable SFM given machine spindle limit
            max_achievable_sfm = (3.141592653589793 * dia * max_rpm) / 12.0
            is_spindle_limited = bool(max_rpm > 0 and 'sfm_min' in target and max_achievable_sfm < (target['sfm_min'] * 0.95))

            # Check Spindle Speed / SFM
            if is_spindle_limited:
                self.assertAlmostEqual(rpm, max_rpm, delta=5, msg=f"{b_id}: RPM {rpm} should be clamped to machine max_rpm {max_rpm}")
                self.assertAlmostEqual(sfm, max_achievable_sfm, delta=1.5, msg=f"{b_id}: SFM {sfm} should equal max achievable SFM {max_achievable_sfm}")
                self.assertTrue(d.get('is_spindle_limited', False), f"{b_id}: Expected is_spindle_limited flag to be True")
            elif 'sfm_min' in target and 'sfm_max' in target:
                self.assertGreaterEqual(sfm, target['sfm_min'] * 0.80, f"{b_id}: SFM {sfm} below minimum threshold {target['sfm_min']}")
                self.assertLessEqual(sfm, target['sfm_max'] * 1.30, f"{b_id}: SFM {sfm} exceeds maximum threshold {target['sfm_max']}")

            # Check Recommended Depths of Cut
            if 'doc_inch_min' in target:
                self.assertGreaterEqual(doc, target['doc_inch_min'] * 0.80, f"{b_id}: DOC {doc} below target {target['doc_inch_min']}")
            if 'doc_inch_max' in target:
                self.assertLessEqual(doc, target['doc_inch_max'] * 1.30, f"{b_id}: DOC {doc} exceeds target {target['doc_inch_max']}")

            # Check Recommended Widths of Cut
            if 'woc_inch_min' in target:
                self.assertGreaterEqual(woc, target['woc_inch_min'] * 0.80, f"{b_id}: WOC {woc} below target {target['woc_inch_min']}")
            if 'woc_inch_max' in target:
                self.assertLessEqual(woc, target['woc_inch_max'] * 1.30, f"{b_id}: WOC {woc} exceeds target {target['woc_inch_max']}")

            # Check Feedrate (scale minimum feedrate requirement if machine is spindle limited)
            feed_scale = (max_achievable_sfm / target['sfm_min']) if (is_spindle_limited and 'sfm_min' in target and target['sfm_min'] > 0) else 1.0
            if 'feedrate_ipm_min' in target:
                scaled_min_feed = target['feedrate_ipm_min'] * feed_scale * 0.80
                self.assertGreaterEqual(feed, scaled_min_feed, f"{b_id}: Feed {feed} below min {scaled_min_feed}")
            if 'feedrate_ipm_max' in target:
                scaled_max_feed = target['feedrate_ipm_max'] * feed_scale * 1.30
                self.assertLessEqual(feed, scaled_max_feed, f"{b_id}: Feed {feed} above max {scaled_max_feed}")

            # Check Drill IPR
            if 'ipr_min' in target:
                ipr = d.get('ipr', feed / max(1.0, rpm))
                self.assertGreaterEqual(ipr, target['ipr_min'] * 0.80, f"{b_id}: IPR {ipr} below min {target['ipr_min']}")

            # Check Tap synchronization
            if 'pitch_lead_inch' in target:
                ipr = d.get('ipr', feed / max(1.0, rpm))
                self.assertAlmostEqual(ipr, target['pitch_lead_inch'], places=4, msg=f"{b_id}: Tapping lead mismatch")

            passed_count += 1
            print(f"{b_id:<42} | {rpm:<7} | {sfm:<6.1f} | {feed:<11.1f} | {doc:<9.4f} | {woc:<9.4f} | PASS")

        print("=" * 112)
        print(f"                  ALL {passed_count}/{total_count} VENDOR STRATEGY BENCHMARKS PASSED")
        print("=" * 112 + "\n")

if __name__ == '__main__':
    unittest.main()
