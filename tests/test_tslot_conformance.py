"""Conformance of tslot_model against the cited vendor rows in tests/benchmarks/tslot/.

For every full_slot and side_cut row with complete geometry (diameter, kerf, neck) the model runs at
aggressiveness 0.5, runout 0.0002", max rpm 60,000 at the row's material, hardness and radial depth.
Pass when SFM is within [0.75 x vendor min, 1.25 x vendor max] and chip load within [0.60 x min, 1.25 x max]
(min = max = nominal when only a nominal is published). Required pass rate: >= 90 % overall and >= 85 % per
vendor; the recommended radial depth per pass must be within [0.5, 1.25] x the vendor radial depth for
>= 85 % of the rows that publish one. The tolerances and the vendor rows must not be changed to pass.
"""
import json
import os
import sys
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from gwizard_physics import GWizardPhysics
import tslot_model

HERE = os.path.dirname(__file__)
BENCH_DIR = os.path.join(HERE, 'benchmarks', 'tslot')
SFM_LO, SFM_HI = 0.75, 1.25
FZ_LO, FZ_HI = 0.60, 1.25
AE_LO, AE_HI = 0.5, 1.25
MIN_OVERALL, MIN_VENDOR, MIN_RADIAL = 0.90, 0.85, 0.85


def _rng(d):
    lo = d.get('min') if d.get('min') is not None else d.get('nominal')
    hi = d.get('max') if d.get('max') is not None else d.get('nominal')
    return lo, hi


def load_rows():
    rows = []
    for vendor in ('harvey', 'ingersoll'):
        with open(os.path.join(BENCH_DIR, vendor + '.json'), encoding='utf-8') as f:
            for r in json.load(f)['rows']:
                t = r['tool']
                if r['operation'] not in ('full_slot', 'side_cut'):
                    continue
                if any(t.get(k) is None for k in ('cutter_diameter', 'cutter_thickness', 'neck_diameter')):
                    continue
                rows.append((vendor, r))
    return rows


def run_row(physics, r):
    t, c = r['tool'], r['cut']
    ae = c['ae_radial'].get('nominal')
    engaged_both = 'both sides' in str(c.get('fz_basis', '')).lower() and 'one side' not in str(c['fz_basis']).lower()
    op = 'both_sides' if engaged_both else r['operation']
    return tslot_model.compute_tslot(
        physics, r['material']['toolwiz_family'], t['cutter_diameter'], t['cutter_thickness'], t['neck_diameter'],
        t.get('neck_length') or 3 * t['cutter_diameter'] / 2, t.get('shank_diameter') or t['cutter_diameter'],
        teeth=t['teeth'], tooth_form=t.get('tooth_form'), cutting_faces=t.get('cutting_faces'),
        teeth_per_face=t.get('teeth_per_face'), coating=t.get('coating', 'Uncoated'),
        hardness=r['material'].get('hardness'), aggressiveness=0.5, runout=0.0002, max_rpm=60000.0,
        operation=op), ae


def evaluate_all(physics):
    results = []
    for vendor, r in load_rows():
        out, ae_v = run_row(physics, r)
        c = r['cut']
        s_lo, s_hi = _rng(c['sfm'])
        f_lo, f_hi = _rng(c['fz'])
        sfm_ok = s_lo * SFM_LO <= out['sfm'] <= s_hi * SFM_HI
        fz_ok = f_lo * FZ_LO <= out['chip_load_ipt'] <= f_hi * FZ_HI
        ae_ok = None
        if ae_v:
            ae_ok = AE_LO * ae_v <= out['radial_depth_per_pass_in'] <= AE_HI * ae_v
        results.append(dict(vendor=vendor, id=r['id'], sfm=out['sfm'], sfm_rng=(s_lo, s_hi), sfm_ok=sfm_ok,
                            fz=out['chip_load_ipt'], fz_rng=(f_lo, f_hi), fz_ok=fz_ok,
                            ae=out['radial_depth_per_pass_in'], ae_v=ae_v, ae_ok=ae_ok, limited=out['limited_by']))
    return results


class TestTSlotConformance(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.physics = GWizardPhysics('materials_database_clean.json')
        cls.results = evaluate_all(cls.physics)

    def test_rows_present(self):
        self.assertGreater(len(self.results), 200)

    def test_pass_rates(self):
        res = self.results
        passed = lambda x: x['sfm_ok'] and x['fz_ok']
        overall = sum(map(passed, res)) / len(res)
        per = {}
        for v in ('harvey', 'ingersoll'):
            rs = [x for x in res if x['vendor'] == v]
            per[v] = sum(map(passed, rs)) / len(rs)
        rad = [x for x in res if x['ae_ok'] is not None]
        rad_rate = sum(x['ae_ok'] for x in rad) / len(rad)
        fails = [x for x in res if not passed(x)]
        if fails:
            print(f"\nSFM / chip load failures ({len(fails)} of {len(res)}):")
            print(f"{'row':70s} {'sfm':>7s} {'vendor sfm':>13s} {'fz':>9s} {'vendor fz':>17s}")
            for x in fails:
                print(f"{x['id'][:70]:70s} {x['sfm']:7.0f} {x['sfm_rng'][0]:6.0f}-{x['sfm_rng'][1]:<6.0f} "
                      f"{x['fz']:9.5f} {x['fz_rng'][0]:8.5f}-{x['fz_rng'][1]:<8.5f}"
                      f"{'' if x['sfm_ok'] else ' SFM'}{'' if x['fz_ok'] else ' FZ'}")
        rfails = [x for x in rad if not x['ae_ok']]
        if rfails:
            print(f"\nRadial depth failures ({len(rfails)} of {len(rad)}):")
            for x in rfails:
                print(f"{x['id'][:70]:70s} model {x['ae']:.4f}  vendor {x['ae_v']:.4f}  ({x['limited']})")
        print(f"\npass rate overall {overall:.1%}; harvey {per['harvey']:.1%}; ingersoll {per['ingersoll']:.1%}; "
              f"radial depth {rad_rate:.1%} of {len(rad)}")
        self.assertGreaterEqual(overall, MIN_OVERALL)
        for v, p in per.items():
            self.assertGreaterEqual(p, MIN_VENDOR, v)
        self.assertGreaterEqual(rad_rate, MIN_RADIAL)


if __name__ == '__main__':
    unittest.main()
