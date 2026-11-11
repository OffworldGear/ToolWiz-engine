"""Unit tests for tslot_model: chip-load rules, axial (up and down) cutting, limits, shop cutters, API."""
import math
import os
import sys
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from gwizard_physics import GWizardPhysics
import tslot_model as tm

AL = 'Aluminum - Wrought (6061)'
SS304 = 'Stainless - 300 Series (316)'
TI = 'Titanium Alloy'
PH = 'Stainless - PH Series (17-4)'
PROVISIONAL = 'provisional geometry: measure neck diameter, reach and tooth form'


def titles(out):
    return {w['title'] for w in out['warnings']}


def finite(out):
    for k in ('rpm', 'sfm', 'chip_load_ipt', 'feed_ipm', 'radial_depth_per_pass_in', 'deflection_in',
              'neck_stress_ksi', 'power_hp'):
        if not (isinstance(out[k], float) or isinstance(out[k], int)) or not math.isfinite(out[k]) or out[k] <= 0:
            return False
    return True


class TestTSlotModel(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.p = GWizardPhysics('materials_database_clean.json')

    def run_tool(self, **kw):
        a = dict(material_family=SS304, diameter=0.5, kerf=0.0625, neck_diameter=0.25, reach=0.5, shank_diameter=0.5,
                 teeth=6, tooth_form='staggered', max_rpm=60000.0)
        a.update(kw)
        return tm.compute_tslot(self.p, **a)

    def test_both_sides_is_055_of_one_side(self):
        one = self.run_tool(operation='full_slot')
        both = self.run_tool(operation='both_sides')
        self.assertAlmostEqual(both['chip_load_ipt'], 0.55 * one['chip_load_ipt'], places=9)
        self.assertAlmostEqual(both['feed_ipm'], 0.55 * one['feed_ipm'], places=6)

    def test_axial_step_feed_uses_teeth_per_face(self):
        a = self.run_tool(operation='axial_step', teeth=6, slot_height=0.3)
        self.assertEqual(a['teeth_per_face'], 3)                       # staggered: teeth / 2
        self.assertAlmostEqual(a['axial_feed_ipm'], a['rpm'] * 3 * a['face_chip_load_ipt'], places=6)
        self.assertAlmostEqual(a['feed_ipm'], a['axial_feed_ipm'], places=9)
        one = self.run_tool(operation='full_slot')
        self.assertAlmostEqual(a['face_chip_load_ipt'], 0.55 * one['chip_load_ipt'], places=9)
        b = self.run_tool(operation='axial_step', teeth=6, teeth_per_face=6, slot_height=0.3)
        self.assertAlmostEqual(b['axial_feed_ipm'], 2.0 * a['axial_feed_ipm'], places=6)

    def test_axial_plan_cut_count(self):
        k = 0.0625
        a = self.run_tool(operation='axial_step', slot_height=0.3, kerf=k)
        self.assertEqual(a['axial_plan']['cuts'], math.ceil((0.3 - k) / (0.8 * k)) + 1)
        self.assertEqual(self.run_tool(slot_height=k)['axial_plan']['cuts'], 1)

    def test_straight_tooth_axial_step_warns(self):
        s = self.run_tool(operation='axial_step', tooth_form='straight', slot_height=0.25)
        self.assertIn('Cannot step up into material', titles(s))
        self.assertIsNone(s['axial_feed_ipm'])
        self.assertEqual(s['axial_plan']['cuts'], math.ceil(0.25 / 0.0625))
        self.assertNotIn('Cannot step up into material', titles(self.run_tool(operation='axial_step')))

    def test_neck_clearance_violation_is_critical(self):
        out = self.run_tool(radial_depth_total=0.30)               # clearance (0.5 - 0.25) / 2 = 0.125
        crit = [w for w in out['warnings'] if w['type'] == 'critical']
        self.assertTrue(crit)
        self.assertIn('Neck clearance exceeded', titles(out))
        ok = self.run_tool(radial_depth_total=0.10)
        self.assertFalse([w for w in ok['warnings'] if w['type'] == 'critical'])

    def test_passes_for_requested_depth(self):
        out = self.run_tool(radial_depth_total=0.10)
        self.assertEqual(out['radial_passes'], math.ceil(0.10 / out['radial_depth_limit_per_pass_in'] - 1e-9))
        self.assertLessEqual(out['radial_depth_per_pass_in'], out['radial_depth_limit_per_pass_in'] + 1e-12)

    def test_slender_neck_is_limited_by_deflection_or_stress(self):
        out = self.run_tool(material_family=TI, diameter=0.5, kerf=0.125, neck_diameter=0.06, reach=1.0,
                            shank_diameter=0.25, aggressiveness=1.0)
        self.assertTrue(out['limited_by_all'])
        self.assertIn('Neck too slender for this cut', titles(out))
        sane = self.run_tool(material_family=TI, diameter=0.5, kerf=0.125, neck_diameter=0.3, reach=0.4,
                             shank_diameter=0.5, aggressiveness=0.5)
        self.assertLessEqual(sane['deflection_in'], sane['deflection_limit_in'] * 1.001)

    def test_coating_and_aggressiveness(self):
        base = self.run_tool(coating='Uncoated')
        coated = self.run_tool(coating='AlTiN')
        self.assertGreater(coated['chip_load_ipt'], base['chip_load_ipt'])
        self.assertLessEqual(coated['chip_load_ipt'], 1.15 * base['chip_load_ipt'] * 1.0001)
        self.assertGreater(self.run_tool(aggressiveness=0.9)['chip_load_ipt'], base['chip_load_ipt'])

    def test_vendor_example_harvey_quarter_inch_staggered(self):
        # Harvey SF_907000, 972162 (1/4 x .062, 6 flutes, staggered) in 316 at 29-37 HRC: 200 SFM, .0005, .02 radial
        out = self.run_tool(diameter=0.25, kerf=0.062, neck_diameter=0.125, reach=0.375, shank_diameter=0.25,
                            hardness={'min': 29, 'max': 37})
        self.assertTrue(150 <= out['sfm'] <= 250)
        self.assertTrue(0.0003 <= out['chip_load_ipt'] <= 0.000625)
        self.assertTrue(0.01 <= out['radial_depth_per_pass_in'] <= 0.025)


class TestShopCutters(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.p = GWizardPhysics('materials_database_clean.json')
        cls.tools = tm.load_shop_tools()

    def test_file_has_the_owner_cutters(self):
        for tid in ('klot_6x2', 'klot_4x0.5', 'klot_8x0.5', 'harvey_867330', 'klot_8x1.6'):
            self.assertIn(tid, self.tools)
        six = self.tools['klot_6x2']
        self.assertEqual((six['diameter_mm'], six['kerf_mm'], six['teeth'], six['shank_diameter_mm'], six['oal_mm']),
                         (6.0, 2.0, 4, 6.0, 50.0))
        self.assertEqual((six['neck_diameter_mm'], six['reach_mm']), (3.5, 10.0))
        self.assertIsNone(six['tooth_form'])
        self.assertTrue(self.tools['harvey_867330']['planned'])
        self.assertTrue(self.tools['klot_8x1.6']['planned'])

    def test_provisional_cutters_warn_and_are_finite(self):
        cases = [('klot_6x2', AL), ('klot_6x2', SS304), ('klot_4x0.5', PH), ('klot_4x0.5', TI),
                 ('klot_8x0.5', TI), ('klot_8x1.6', TI)]
        for tid, fam in cases:
            for op in ('full_slot', 'axial_step'):
                with self.subTest(tool=tid, material=fam, op=op):
                    out = tm.compute_shop_tool(self.p, tid, fam, operation=op, max_rpm=20000.0,
                                               radial_depth_total=0.03,
                                               slot_height=0.2)
                    self.assertTrue(finite(out), out)
                    msgs = [w['message'] for w in out['warnings']]
                    self.assertTrue(any(PROVISIONAL in m for m in msgs), msgs)
                    self.assertTrue(out['provisional'])

    def test_six_by_two_in_6061_and_304_one_mm_radial(self):
        for fam in (AL, SS304):
            out = tm.compute_shop_tool(self.p, 'klot_6x2', fam, radial_depth_total=1.0 / 25.4, max_rpm=60000.0)
            self.assertTrue(finite(out))
            self.assertLessEqual(out['radial_depth_per_pass_in'], 1.0 / 25.4 + 1e-9)
            self.assertFalse([w for w in out['warnings'] if w['type'] == 'critical'])
            self.assertTrue(any(PROVISIONAL in w['message'] for w in out['warnings']))
            self.assertEqual(out['teeth_per_face'], 2)                     # unknown form -> staggered, 4 / 2

    def test_planned_harvey_part_has_full_catalog_geometry(self):
        out = tm.compute_shop_tool(self.p, 'harvey_867330', TI, radial_depth_total=0.08)
        self.assertTrue(finite(out))
        self.assertEqual(out['provisional'], [])
        self.assertNotIn('Provisional geometry', titles(out))
        self.assertEqual(out['teeth_per_face'], 4)


class TestTSlotApi(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        import app
        cls.client = app.app.test_client()
        cls.client.environ_base['HTTP_X_TOOLWIZ_CLIENT'] = 'test'

    def payload(self, **kw):
        d = dict(family=AL, alloy='6061-T6', tool='Carbide Endmill', geometry='T-Slot', operation='Slotting',
                 coating='Titanium', diameter=0.2362, flutes=4, cutterThickness=0.0787, neckDiameter=0.1378,
                 shankDiameter=0.2362, neckLength=0.3937, maxRpm=24000, maxHp=5)
        d.update(kw)
        return d

    def test_calculate_returns_tslot_object(self):
        r = self.client.post('/api/calculate', json=self.payload(toothForm='staggered', tslotOperation='axial_step',
                                                                  slotHeight=0.3, radialDepthTotal=0.04))
        self.assertEqual(r.status_code, 200, r.get_data(as_text=True))
        b = r.get_json()
        t = b['tslot']
        self.assertEqual(t['operation'], 'axial_step')
        self.assertEqual(t['teeth_per_face'], 2)
        self.assertGreater(t['axial_plan']['cuts'], 1)
        self.assertEqual(b['rpm'], round(t['rpm']))
        self.assertAlmostEqual(b['feedrate'], round(t['feed_ipm'], 2))

    def test_fusion_endpoint_and_defaults(self):
        r = self.client.post('/api/calculate_for_fusion', json=self.payload())
        self.assertEqual(r.status_code, 200, r.get_data(as_text=True))
        b = r.get_json()
        self.assertIn('tslot', b)
        self.assertEqual(b['tslot']['operation'], 'full_slot')
        self.assertGreater(b['feed'], 0)

    def test_neck_clearance_makes_result_infeasible(self):
        b = self.client.post('/api/calculate', json=self.payload(radialDepthTotal=0.5)).get_json()
        self.assertFalse(b['feasible'])
        self.assertTrue(any(t['type'] == 'critical' for t in b['tips']))

    def test_non_tslot_has_no_tslot_object(self):
        b = self.client.post('/api/calculate', json=dict(family=AL, tool='Carbide Endmill', diameter=0.25, flutes=3,
                                                         stickout=1.0, cutDepth=0.2, cutWidth=0.05)).get_json()
        self.assertNotIn('tslot', b)


if __name__ == '__main__':
    unittest.main()
