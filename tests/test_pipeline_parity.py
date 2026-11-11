"""Parity guard for the unified calculation pipeline.

Snapshots /api/calculate outputs for every vendor benchmark plus extra cases
(tests/fixtures/pipeline/pipeline_parity.json (a subdirectory because test_toolwiz_hardening globs every *.json directly in tests/fixtures), generated from the pre-refactor code).
The refactor onto pipeline.run_cut must reproduce them within 0.1%.

Regenerate deliberately with:  PIPELINE_PARITY_UPDATE=1 python -m unittest tests.test_pipeline_parity
"""
import json
import os
import sys
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from app import app

HERE = os.path.dirname(__file__)
SNAPSHOT = os.path.join(HERE, 'fixtures', 'pipeline', 'pipeline_parity.json')
BENCH = os.path.join(HERE, 'benchmarks', 'vendor_catalog_data.json')

NUMERIC_KEYS = [
    'rpm', 'feedrate', 'adj_ipt', 'base_ipt', 'sfm', 'contact_sfm', 'target_sfm',
    'rec_doc', 'rec_woc', 'rec_limit', 'deflection', 'springback', 'total_error',
    'wear_comp', 'mrr', 'ramp_angle', 'ramp_feed', 'plunge_feed',
    'effective_diameter', 'ideal_rpm',
]
EXACT_KEYS = ['is_spindle_limited', 'feasible', 'limited_by', 'is_finishing', 'is_floor_finish']

# Extra hand-built payloads (same payload schema /api/calculate takes).
EXTRA_CASES = {
    'extra_drill_steel': dict(family='Steel - Medium Carbon Alloy (4130)', alloy='4140 (Annealed)', tool='HP Carbide Twist Drill',
                              coating='AlTiN', geometry='Twist Drill', operation='Drilling', diameter=0.25, flutes=2,
                              stickout=1.5, fluteLength=1.0, maxRpm=20000, maxHp=15.0),
    'extra_drill_deep_alu': dict(family='Aluminum - Wrought (6061)', alloy='6061-T6', tool='Carbide Twist Drill',
                                 coating='Uncoated', geometry='Twist Drill', operation='Drilling', diameter=0.125, flutes=2,
                                 stickout=1.6, fluteLength=1.2, maxRpm=30000, maxHp=15.0),
    'extra_tap_form': dict(family='Steel - Low Carbon (1020)', alloy='1018', tool='Tapping', coating='TiN', geometry='form',
                           operation='Rigid Tapping', diameter=0.25, flutes=4, pitch=0.05, stickout=1.25, isCarbide=False,
                           maxRpm=12000, maxHp=15.0),
    'extra_tap_metric_m6': dict(family='Stainless - 300 Series (316)', alloy='', tool='Tapping', coating='Uncoated',
                                geometry='spiral_point', operation='Rigid Tapping', diameter=0.23622, flutes=3, pitch=0.03937,
                                stickout=1.0, isCarbide=False, isMetric=True, maxRpm=12000, maxHp=15.0),
    'extra_tslot_alu': dict(family='Aluminum - Wrought (6061)', alloy='6061-T6', tool='Carbide Endmill', coating='Uncoated',
                            geometry='T-Slot', operation='Slotting', diameter=0.75, flutes=6, stickout=1.25, fluteLength=0.125,
                            cutterThickness=0.125, neckDiameter=0.3, shankDiameter=0.375, maxRpm=16000, maxHp=10.0),
    'extra_ball_h13_hard': dict(family='Steel - Tool (H13)', alloy='H13 (Hardened ~52 HRC)', tool='Carbide Endmill',
                                coating='AlTiN', geometry='Ball Nose', operation='Finishing', diameter=0.25, flutes=4,
                                stickout=1.0, fluteLength=0.5, cutDepth=0.01, cutWidth=0.02, maxRpm=30000, maxHp=10.0),
    'extra_bull_nose_ti': dict(family='Titanium Alloy', alloy='', tool='Carbide Endmill', coating='AlTiN', geometry='Bull Nose',
                               operation='Roughing', diameter=0.5, flutes=5, cornerRadius=0.03, stickout=1.5, fluteLength=1.0,
                               cutDepth=0.5, cutWidth=0.1, aggressiveness=70, maxRpm=12000, maxHp=10.0),
    'extra_high_feed_steel': dict(family='Steel - Medium Carbon Alloy (4130)', alloy='4140 (Annealed)', tool='Carbide Endmill',
                                  coating='AlTiN', geometry='High Feed', operation='High Feed Milling', diameter=0.5, flutes=4,
                                  stickout=1.5, fluteLength=0.75, cutDepth=0.04, cutWidth=0.3, maxRpm=16000, maxHp=10.0),
    'extra_finishing_sq_alu': dict(family='Aluminum - Wrought (6061)', alloy='6061-T6', tool='Carbide Endmill', coating='ZrN',
                                   geometry='Square', operation='Finishing', diameter=0.375, flutes=3, stickout=1.25,
                                   fluteLength=0.75, cutDepth=0.75, cutWidth=0.02, aggressiveness=30, maxRpm=24000, maxHp=10.0),
    'extra_adaptive_hem_ss': dict(family='Stainless - 300 Series (316)', alloy='', tool='Carbide Endmill', coating='AlTiN',
                                  geometry='Square', operation='Adaptive Roughing', diameter=0.5, flutes=5, stickout=1.5,
                                  fluteLength=1.0, cutDepth=1.0, cutWidth=0.05, aggressiveness=60, maxRpm=16000, maxHp=10.0),
    'extra_long_stickout_chatter': dict(family='Steel - Low Carbon (1020)', alloy='1018', tool='Carbide Endmill', coating='TiAlN',
                                        geometry='Square', operation='Roughing', diameter=0.25, flutes=4, stickout=1.6,
                                        fluteLength=0.75, cutDepth=0.25, cutWidth=0.1, maxRpm=16000, maxHp=10.0),
    'extra_metric_flag_alu': dict(family='Aluminum - Wrought (6061)', alloy='', tool='Carbide Endmill', coating='Uncoated',
                                  geometry='Square', operation='Roughing', diameter=0.3937, flutes=3, stickout=1.0,
                                  fluteLength=0.8, cutDepth=0.3, cutWidth=0.15, isMetric=True, maxRpm=16000, maxHp=10.0),
    'extra_spindle_limited_micro': dict(family='Aluminum - Wrought (6061)', alloy='6061-T6', tool='Carbide Endmill',
                                        coating='Uncoated', geometry='Square', operation='Roughing', diameter=0.0625, flutes=2,
                                        stickout=0.25, fluteLength=0.1875, cutDepth=0.05, cutWidth=0.03, maxRpm=10000, maxHp=5.0),
}


def build_benchmark_payloads():
    """Payload-building code mirrored from tests/test_vendor_strategy_matrix.py."""
    with open(BENCH, 'r', encoding='utf-8') as f:
        data = json.load(f)
    out = {}
    for tc in data['benchmarks']:
        dia = tc['diameter']
        fam = tc['material_family']
        geo = tc['geometry']
        strat = tc['strategy']
        max_rpm = tc.get('max_rpm', 80000 if dia <= 0.03125 else 30000)
        tool_val = tc.get('tool') or tc.get('tool_type') or (
            'Tapping' if 'tap' in strat.lower() or geo == 'form' else (
                'End Mill' if 'mill' in geo.lower() or geo in ['Square', 'Ball', 'Radiused'] else geo))
        payload = {
            'family': fam, 'alloy': tc.get('alloy', ''), 'tool': tool_val,
            'coating': tc.get('coating', 'Uncoated'), 'geometry': geo, 'operation': strat,
            'diameter': dia, 'flutes': tc['flutes'], 'stickout': tc.get('stickout', dia * 3.0),
            'fluteLength': tc.get('flute_length', dia * 1.5),
            'cutterThickness': tc.get('cutter_thickness', 0.125),
            'neckDiameter': tc.get('neck_diameter', dia), 'neckLength': tc.get('neck_length', 0.5),
            'shankDiameter': tc.get('shank_diameter', dia), 'cornerRadius': tc.get('corner_radius', 0.0),
            'pitch': tc.get('pitch', 0.05), 'isCarbide': tc.get('is_carbide', True),
            'maxRpm': max_rpm, 'maxHp': 15.0,
        }
        if 'cut_depth' in tc:
            payload['cutDepth'] = tc['cut_depth']
        if 'cut_width' in tc:
            payload['cutWidth'] = tc['cut_width']
        out['bench:' + tc['id']] = payload
    return out


def all_payloads():
    p = build_benchmark_payloads()
    p.update(EXTRA_CASES)
    return p


def summarize(d):
    s = {k: d.get(k) for k in NUMERIC_KEYS + EXACT_KEYS}
    s['tips_titles'] = [t.get('title') for t in d.get('tips', [])]
    return s


class TestPipelineParity(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.client = app.test_client()
        cls.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def _calc(self, payload):
        res = self.client.post('/api/calculate', json=payload)
        self.assertEqual(res.status_code, 200, res.get_data(as_text=True))
        d = res.get_json()
        self.assertTrue(d.get('success'))
        return d

    def test_snapshot_parity(self):
        payloads = all_payloads()
        if os.environ.get('PIPELINE_PARITY_UPDATE') == '1':
            snap = {k: summarize(self._calc(p)) for k, p in payloads.items()}
            os.makedirs(os.path.dirname(SNAPSHOT), exist_ok=True)
            with open(SNAPSHOT, 'w', encoding='utf-8') as f:
                json.dump(snap, f, indent=1, sort_keys=True)
            self.skipTest('snapshot regenerated')
        with open(SNAPSHOT, 'r', encoding='utf-8') as f:
            snap = json.load(f)
        self.assertEqual(set(snap), set(payloads), 'snapshot cases out of sync with test payloads')
        for name, payload in payloads.items():
            with self.subTest(case=name):
                got = summarize(self._calc(payload))
                exp = snap[name]
                for k in NUMERIC_KEYS:
                    e, g = exp[k], got[k]
                    tol = max(abs(e) * 0.001, 1e-6)
                    if k in ('rec_limit', 'deflection'):
                        # Snapshot was taken when the API rounded these to 5-6 decimals; it now sends 7.
                        tol = max(tol, 5.1e-6)  # half of the old 1e-5 rounding step
                    self.assertAlmostEqual(g, e, delta=tol, msg=f'{name}.{k}: {g} vs snapshot {e}')
                for k in EXACT_KEYS:
                    self.assertEqual(got[k], exp[k], f'{name}.{k}')
                self.assertEqual(got['tips_titles'], exp['tips_titles'], f'{name}: tips titles')


if __name__ == '__main__':
    unittest.main()
