"""v2 calibration (step 4): tools/calibrate_v2.py helpers, the calibrated parameter files, physics_v2.params."""
import json
import math
import os
import sys
import unittest
from dataclasses import replace

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
for p in (ROOT, os.path.join(ROOT, "tools")):
    if p not in sys.path:
        sys.path.insert(0, p)

import calibrate_v2 as cal  # noqa: E402
from physics_v2 import forces  # noqa: E402
from physics_v2 import optimize as o  # noqa: E402
from physics_v2 import params  # noqa: E402

MODEL_DIR = os.path.join(ROOT, "data", "model_v2")


def _walk(obj, path=""):
    if isinstance(obj, dict):
        yield path, obj
        for k, v in obj.items():
            yield from _walk(v, f"{path}/{k}")
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            yield from _walk(v, f"{path}[{i}]")


class TestSpeedLaw(unittest.TestCase):
    def test_default_engagement_basis_unchanged(self):
        m = o.material_17_4(356.0)
        phi = forces.engagement_angle(0.25, 1.0)
        want = 262.0 / o.FT_PER_M * (200.0 / 356.0) * (phi / math.pi) ** -0.4
        self.assertAlmostEqual(o.taylor_speed_m_min(m, phi), want, places=9)

    def test_ae_basis_and_floor(self):
        m = replace(o.material_17_4(300.0), vc_engagement_basis="ae", vc_engagement_exp=0.15,
                    vc_engagement_ae_min=0.05, vc_hb_ref=300.0, vc_ref_sfm=200.0)
        for ae, eff in ((1.0, 1.0), (0.2, 0.2), (0.01, 0.05)):
            phi = forces.engagement_angle(ae, 1.0)
            self.assertAlmostEqual(o.taylor_speed_m_min(m, phi) * o.FT_PER_M, 200.0 * eff ** -0.15, places=6)

    def test_bad_basis(self):
        m = replace(o.material_17_4(), vc_engagement_basis="nope")
        with self.assertRaises(ValueError):
            o.taylor_speed_m_min(m, 1.0)


class TestHelpers(unittest.TestCase):
    def test_rm_band_is_converted(self):
        hb = cal.row_hb({"min": 500, "max": 1200, "scale": "N/mm2 (Rm)"})
        self.assertAlmostEqual(hb, 850 / 3.38, places=6)
        self.assertIsNone(cal.row_hb({"min": None, "max": None, "scale": "none published"}))

    def test_within_range(self):
        cell = {"min": 100.0, "max": 200.0, "nominal": None}
        self.assertTrue(cal.within_range(91.0, cell))
        self.assertFalse(cal.within_range(90.0, cell))
        self.assertTrue(cal.within_range(220.0, cell))
        self.assertFalse(cal.within_range(221.0, cell))
        self.assertTrue(cal.within_range(109.0, {"min": None, "max": None, "nominal": 100.0}))

    def test_wls_recovers_coefficients(self):
        X = [[1.0, x, x * x] for x in range(10)]
        y = [2.0 - 0.5 * x + 0.1 * x * x for x in range(10)]
        coef, se = cal.wls(X, y, [1.0] * 10)
        for c, want in zip(coef, (2.0, -0.5, 0.1)):
            self.assertAlmostEqual(c, want, places=8)

    def test_within_fit_ignores_group_levels(self):
        items = [{"g": g, "x": x, "y": 10.0 * g + 3.0 * x} for g in range(4) for x in range(3)]
        r = cal.within_fit(items, lambda e: e["g"], [lambda e: e["x"]], lambda e: e["y"])
        self.assertAlmostEqual(r["coef"][0], 3.0, places=9)

    def test_force_scale_from_toolguide(self):
        f = cal.fit_force_scale()
        self.assertAlmostEqual(f["tool_factor"], 0.79, delta=0.005)
        self.assertLess(f["log_sd"], 0.01)
        self.assertAlmostEqual(f["kc_hardness_exp_17_4"], 0.41, delta=0.01)
        for r in f["runs"]:
            self.assertAlmostEqual(r["qq_check_ap_ae_vf_over_qq"], 1.0, delta=0.01)

    def test_titanium_kienzle_is_seco_mc(self):
        k = cal.titanium_kienzle()
        self.assertEqual((k.kc1_1, k.mc), (1400.0, 0.23))

    def test_holdout_is_deterministic_and_grouped(self):
        rows = cal.load_rows()
        a = [cal.holdout(r) for r in rows]
        self.assertEqual(a, [cal.holdout(r) for r in rows])
        groups = {}
        for r, h in zip(rows, a):
            groups.setdefault((r["_vendor_group"], r["source"]["doc_id"], r["material"]["toolwiz_family"]), set()).add(h)
        self.assertTrue(all(len(v) == 1 for v in groups.values()))
        frac = sum(1 for v in groups.values() if True in v) / len(groups)
        self.assertGreater(frac, 0.2)
        self.assertLess(frac, 0.4)


@unittest.skipUnless(os.path.exists(os.path.join(MODEL_DIR, "materials.json")), "run tools/calibrate_v2.py")
class TestParameterFiles(unittest.TestCase):
    def test_ascii_and_every_value_sourced(self):
        for name in ("materials.json", "tools.json"):
            path = os.path.join(MODEL_DIR, name)
            with open(path, "rb") as fh:
                raw = fh.read()
            raw.decode("ascii")
            data = json.loads(raw)
            self.assertIn("version", data)
            for where, d in _walk(data):
                if "value" in d:
                    self.assertTrue(d.get("source"), f"{name}{where} has a value without a source")

    def test_material_from_params(self):
        m = params.material("Stainless - PH Series (17-4)", hb=356.0)
        p = params.load()
        self.assertEqual(m.kienzle.kc1_1, 1800.0)
        self.assertAlmostEqual(m.tool_factor, p["force"]["tool_factor"]["value"])
        self.assertEqual(m.vc_engagement_basis, "ae")
        ti = params.material("Titanium Alloy", hb=330.0)
        self.assertEqual(ti.kienzle.mc, 0.23)
        r = o.optimize(o.Tool.build(0.125, 4, 0.5, 0.6, shank=0.125), m, o.speedio_16k(), "slot",
                       robustness=False, find_tir=False, grid=(6, 4))
        self.assertTrue(r["feasible"])

    def test_bt30_machine_and_consensus_file(self):
        if not os.path.exists(params.CONSENSUS_PATH) or "machine_bt30" not in params.load(params.TOOLS_PATH):
            self.skipTest("run tools/calibrate_v2.py (consensus.json, tools.json machine_bt30)")
        m = params.speedio_bt30()
        self.assertGreater(m.holder_k_n_um, 0)
        self.assertIn("PROVISIONAL", m.holder_basis)
        with open(params.CONSENSUS_PATH, encoding="utf-8") as fh:
            table = json.load(fh)
        b = o.consensus_lookup(table, "Stainless - PH Series (17-4)", 356.0, 0.25, "slot", 1.0)
        self.assertIsNotNone(b)
        self.assertGreater(b["sfm"], 0)
        mat = params.material("Stainless - PH Series (17-4)", hb=356.0)
        r = o.optimize(o.Tool.build(0.25, 4, 0.75, 1.0), mat, m, "slot", margins=params.margins(0.5),
                       consensus="default", robustness=False, find_tir=False, grid=(6, 4))
        self.assertIn("C14v", r["checks"])

    def test_coating_class(self):
        self.assertEqual(params.coating_class("BALIQ ALCRONOS (AlCrN)"), "AlCrN")
        self.assertEqual(params.coating_class("PVD TiAlSiN"), "Si-doped")
        self.assertEqual(params.coating_class("AlTiN Nano (C6)"), "AlTiN/TiAlN")
        self.assertEqual(params.coating_class("DUARISE"), "unspecified")
        self.assertEqual(params.coating_class(None), "unspecified")


class TestConsensusScheme(unittest.TestCase):
    T1 = o.Tool.build(0.125, 4, 0.5, 0.6, shank=0.125, label="T1")

    def test_scale_points_and_monotone(self):
        for a, v in o.CONSENSUS_SCALE_POINTS:
            self.assertAlmostEqual(o.consensus_scale(a), v, places=12)
        xs = [i / 100 for i in range(101)]
        ys = [o.consensus_scale(x) for x in xs]
        self.assertTrue(all(b >= a - 1e-12 for a, b in zip(ys, ys[1:])))
        self.assertLessEqual(o.consensus_scale(0.5), 1.0)

    def test_margins_consensus_never_relaxes_physics(self):
        for a in (0.0, 0.25, 0.5, 0.75, 1.0):
            m = o.Margins(a, scheme="consensus")
            self.assertLessEqual(m.stress_scale, 1.0)
            self.assertEqual(m.lambda_value, o.CONSENSUS_LAMBDA)
            self.assertAlmostEqual(m.limit_scale, o.consensus_scale(a))
            self.assertAlmostEqual(m.speed_scale, o.consensus_scale(a))
            self.assertEqual(m.life_ratio, 1.0)
        self.assertAlmostEqual(o.Margins(0.75, scheme="consensus").limit_scale, 1.0)
        legacy = o.Margins(0.5)
        self.assertEqual((legacy.limit_scale, legacy.speed_scale, legacy.lambda_value), (1.0, 1.0, None))
        with self.assertRaises(ValueError):
            o.Margins(0.5, scheme="nope")

    def test_speed_scale_and_diameter_term(self):
        m = replace(o.material_17_4(300.0), vc_diameter_exp=0.1, vc_d_knee_in=0.5)
        phi = math.pi
        v_big = o.taylor_speed_m_min(m, phi, D_mm=25.4)
        v_small = o.taylor_speed_m_min(m, phi, D_mm=0.125 * 25.4)
        self.assertAlmostEqual(v_small / v_big, 0.25 ** 0.1, places=9)
        self.assertAlmostEqual(o.taylor_speed_m_min(m, phi, D_mm=25.4, speed_scale=0.92) / v_big, 0.92, places=12)

    def _table(self, sfm=100.0, fz_over_D=0.002, mrr_over_D3=1e9, feed_per_flute_ipm=1e9):
        bands = [{"band": "1/8-3/16", "d_min": 0.1, "d_max": 0.2}]
        eng = [["light", 0.0, 0.1], ["medium", 0.1, 0.25], ["heavy", 0.25, 0.99], ["slot", 0.99, 1e9]]
        b = {"sfm": sfm, "fz_over_D": fz_over_D, "mrr_over_D3": mrr_over_D3,
             "feed_per_flute_ipm": feed_per_flute_ipm, "n_rows": 5,
             "vendor_groups": ["A", "B"]}
        return {"bands": bands, "engagement_classes": eng, "hb_bin_fine": 50, "hb_bin_coarse": 100,
                "buckets": {"L1|Stainless - PH Series (17-4)|7|1/8-3/16|slot|slot": b}}

    def test_c14_caps_speed_and_chip(self):
        mat = o.material_17_4(356.0)
        mg = o.Margins(0.75, scheme="consensus")
        ctx = o._Context(self.T1, mat, o.speedio_16k(), "slot", mg, 72, 24, consensus=self._table())
        pt = o.CutPoint(ctx, 0.02, 0.125)
        self.assertAlmostEqual(math.pi * 0.125 * pt.rpm / 12.0, 100.0, places=6)
        self.assertEqual(pt.c14v.limit, 100.0)
        win = pt.fz_window()
        self.assertLessEqual(win[1], 0.002 * 0.125 * (1 + 1e-6))
        r = o.evaluate_cut(self.T1, mat, o.speedio_16k(), "slot", 0.02, 0.125, 0.0003, margins=mg,
                           consensus=self._table())
        self.assertIn("vendor median", r["checks"]["C14f"]["detail"])

    def test_c14_mrr_cap_is_feed_per_flute(self):
        mat = o.material_17_4(356.0)
        mg = o.Margins(0.5, scheme="consensus")
        ctx = o._Context(self.T1, mat, o.speedio_16k(), "slot", mg, 72, 24,
                         consensus=self._table(feed_per_flute_ipm=1.5))
        pt = o.CutPoint(ctx, 0.02, 0.125)
        s = o.consensus_scale(0.5)
        fz_cap = s * 1.5 / pt.rpm
        c = pt.c14_checks(fz_cap)["C14m"]
        self.assertAlmostEqual(c.value, c.limit, delta=1e-9 * c.limit)
        self.assertLessEqual(pt.fz_window()[1], fz_cap * (1 + 1e-6))

    def test_c14_without_matching_bucket_uses_physics(self):
        mat = o.material_17_4(356.0)
        ctx = o._Context(self.T1, mat, o.speedio_16k(), "adaptive", o.Margins(0.5, scheme="consensus"), 72, 24,
                         consensus=self._table())
        pt = o.CutPoint(ctx, 0.2, 0.01)
        self.assertFalse(pt.c14v.applies)
        self.assertIn("no vendor data", pt.c14v.detail)
        self.assertEqual(pt.c14_checks(0.001), {})

    def test_holder_compliance_in_series(self):
        m = o.Machine({}, 1e9, holder_k_n_um=20.0, holder_ktheta_nm_urad=0.1)
        self.assertAlmostEqual(m.holder_compliance_mm(0.0), 1.0 / 20000.0)
        self.assertAlmostEqual(m.holder_compliance_mm(10.0), 1.0 / 20000.0 + 0.01 ** 2 / 1e5 * 1000.0)
        mat = o.material_17_4(356.0)
        rigid, soft = o.speedio_16k(), replace(o.speedio_16k(), holder_k_n_um=20.0, holder_ktheta_nm_urad=0.1)
        a = o.evaluate_cut(self.T1, mat, rigid, "rough", 0.25, 0.01, 0.001, n_theta=144, n_quad=48)
        b = o.evaluate_cut(self.T1, mat, soft, "rough", 0.25, 0.01, 0.001, n_theta=144, n_quad=48)
        self.assertGreater(b["loads"]["wall_error_in"]["max_in"], a["loads"]["wall_error_in"]["max_in"])
        self.assertEqual(a["checks"]["C4"]["value"], b["checks"]["C4"]["value"])


if __name__ == "__main__":
    unittest.main()
