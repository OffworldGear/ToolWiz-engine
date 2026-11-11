"""Ball and bull-nose end mills in v2 (physics_v2/endforms.py, optimize.ShapedEngagement, v2_bridge scope)."""
import math
import unittest

import app
from pipeline import CutRequest, run_cut
from physics_v2 import endforms, forces
from physics_v2 import optimize as o
from physics_v2 import params


def _request(geometry, cr=0.0, D=0.125, op="Adaptive Roughing", family="Aluminum - Wrought (6061)", alloy="6061-T6", flutes=2, **kw):
    return CutRequest(family=family, alloy=alloy, tool="HP Carbide Endmill", coating="AlTiN", geometry=geometry, operation=op,
                      diameter=D, flutes=flutes, flute_length=1.5 * D, shank_diameter=max(D, 0.125), stickout=1.5 * D + 0.25,
                      corner_radius=cr, aggressiveness=0.5, max_rpm=60000.0, max_hp=10.0, runout=0.0001, model="v2", **kw)


H13 = "Steel - Tool (H13)"


class TestProfile(unittest.TestCase):
    def test_ball_effective_diameter(self):
        D = 3.175
        R = D / 2
        for ap in (0.1, 0.5, 1.0, R):
            self.assertAlmostEqual(endforms.effective_diameter(ap, D, R), 2 * math.sqrt(R * R - (R - ap) ** 2), places=9)
        self.assertAlmostEqual(endforms.effective_diameter(2 * R, D, R), D, places=9)

    def test_bull_effective_diameter_matches_v1(self):
        D, rc, ap = 6.35, 1.0, 0.4
        v1 = app.physics.calc_effective_diameter(D, ap, "Radiused", rc)
        self.assertAlmostEqual(endforms.effective_diameter(ap, D, rc), v1, places=9)
        self.assertEqual(endforms.effective_diameter(2.0, D, rc), D)   # ap beyond the corner: the full diameter

    def test_lead_angle(self):
        R = 1.0
        self.assertAlmostEqual(endforms.sin_kappa(R, R, R), 1.0)                 # ball equator
        self.assertAlmostEqual(endforms.sin_kappa(0.0, R, R), 0.0)               # ball tip
        self.assertAlmostEqual(endforms.sin_kappa(0.5, 2.0, 1.0), math.sqrt(1 - 0.25))
        self.assertEqual(endforms.sin_kappa(5.0, 2.0, 1.0), 1.0)                 # cylinder

    def test_end_form(self):
        self.assertEqual(endforms.end_form(6.0, 0.0), "square")
        self.assertEqual(endforms.end_form(6.0, 0.5), "bull")
        self.assertEqual(endforms.end_form(6.0, 3.0), "ball")


class TestEngagement(unittest.TestCase):
    co = params.material("Aluminum - Wrought (6061)", hb=95).coefficients(0.0)

    def test_corner_to_zero_gives_the_square_result(self):
        offs = forces.runout_offsets(0.0025, 2, "eccentric", 0.3)
        sq = o.Engagement(3.175, 2, 4.0, 0.6, 35.0, True)
        sh = o.ShapedEngagement(3.175, 2, 4.0, 0.6, 35.0, True, 1e-3)
        a, b = sq.loads(0.02, offs, self.co), sh.loads(0.02, offs, self.co)
        self.assertAlmostEqual(b["mean_n"] / a["mean_n"], 1.0, delta=0.03)
        self.assertAlmostEqual(b["peak_n"] / a["peak_n"], 1.0, delta=0.12)
        self.assertAlmostEqual(b["torque_mean_nm"] / a["torque_mean_nm"], 1.0, delta=0.05)
        self.assertAlmostEqual(sh.h_unit, sq.h_unit, places=6)

    def test_bull_with_ap_below_the_radius_is_a_high_feed_lead_angle(self):
        D, rc, ap = 12.7, 3.0, 0.6          # ap < rc: all of the cut is on the corner
        sh = o.ShapedEngagement(D, 4, ap, 4.0, 30.0, True, rc)
        sq = o.Engagement(D, 4, ap, 4.0, 30.0, True)
        sk = endforms.sin_kappa(ap, D / 2, rc)
        self.assertLess(sk, 0.7)
        self.assertLess(sh.h_unit, sq.h_unit)                     # the chip is thinner at the same fz ...
        self.assertAlmostEqual(sh.h_unit / sq.h_unit, sk, delta=0.08)   # ... by the lead angle (≈ sin κ at the cut's top)
        # the same fz therefore gives a lower largest chip: more fz fits under the C2 chip limit
        offs = forces.runout_offsets(0.0, 4, "bound")
        self.assertLess(max(sh.max_chips(0.05, offs)), max(sq.max_chips(0.05, offs)))

    def test_slices_cover_the_depth(self):
        sl = endforms.slice_heights(5.0, 1.5, helix_lag_per_mm=0.3)
        self.assertAlmostEqual(sum(dz for _, dz in sl), 5.0, places=9)


class TestPipeline(unittest.TestCase):
    def test_speed_at_depth_ball(self):
        """C7 turns a ball tool faster below its radius: v_c is set at the effective diameter 2·sqrt(R² − (R − ap)²)."""
        m = params.material(H13, hb=300)
        tool = o.Tool.build(0.125, 2, 0.1875, 0.5, corner_radius_in=0.0625)
        from dataclasses import replace
        mach = replace(o.speedio_16k(), max_rpm=1e6)
        ctx = o._Context(tool, m, mach, "adaptive", params.margins(0.5))
        shallow, deep = ctx.speed(0.2, 0.01), ctx.speed(0.2, 0.125)   # a slot: the same engagement angle
        d_eff = 2 * math.sqrt(0.0625 ** 2 - (0.0625 - 0.01) ** 2)
        self.assertAlmostEqual(deep[1] / shallow[1], 1.0, delta=0.02)          # same cutting speed (m/min) ...
        self.assertAlmostEqual(shallow[0] / deep[0], 0.125 / d_eff, delta=0.02)  # ... so the rpm scales with 1/D_eff
        # the pipeline reports the effective diameter and SFM on both diameters
        r = run_cut(app.physics, _request("Ball", cut_depth=0.01, cut_width=0.01, family=H13, alloy="H13"))
        self.assertEqual(r.model, "v2")
        self.assertAlmostEqual(r.effective_diameter, d_eff, places=5)
        self.assertLess(r.contact_sfm, r.sfm)

    def test_bull_is_v2_and_close_to_square_at_tiny_radius(self):
        sq = run_cut(app.physics, _request("Square", D=0.25, flutes=4, cut_depth=0.25, cut_width=0.025))
        bn = run_cut(app.physics, _request("Radiused", cr=0.005, D=0.25, flutes=4, cut_depth=0.25, cut_width=0.025))
        self.assertEqual(bn.model, "v2")
        self.assertAlmostEqual(bn.feed_ipm / sq.feed_ipm, 1.0, delta=0.12)
        self.assertAlmostEqual(bn.rpm / sq.rpm, 1.0, delta=0.05)

    def test_bull_radius_is_reported_as_the_end_form(self):
        r = run_cut(app.physics, _request("Radiused", cr=0.030, D=0.25, flutes=4, family="Steel - Medium Carbon Alloy (4130)",
                                          alloy="4130", cut_depth=0.25, cut_width=0.025))
        self.assertEqual(r.model, "v2")
        self.assertEqual(r.v2["cut"]["end_form"], "bull")
        self.assertGreater(r.feed_ipm, 0)


if __name__ == "__main__":
    unittest.main()
