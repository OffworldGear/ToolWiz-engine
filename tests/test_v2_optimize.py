"""v2 constraints and optimizer (physics_v2/optimize.py) against hand calculations.

Every expected value below is worked out here from a stated formula:
  * cantilever with a lateral load F at distance a from the free end (Roark; virtual work):
    tip deflection F·(2L³ − 3aL² + a³)/(6EI), deflection under the load F·(L − a)³/(3EI);
  * bending and torsion of a round section: σ = 32M/(πd³), τ = 16T/(πd³); largest principal stress
    σ1 = σ/2 + √((σ/2)² + τ²);
  * runout chips (Kline & DeVor): h_k(φ) = max(0, min over m of m·fz·sin φ + r_k − r_(k−m)), with flute k
    engaging ae − (r_max − r_k); eccentric runout r_k = (TIR/2)·cos(phase − 2πk/z), whose worst phase
    thins one flute by TIR·sin(π/z) (0.71·TIR on 4 flutes);
  * Taylor speed placeholder: v = 262 SFM·(200/HB)·(φe/π)^−0.4·(T/T_ref)^−0.25, φe ≥ φe(0.1·D);
  * Speedio 16k continuous rating: 5.1 kW flat above 4500 rpm; max cutting feed 30 m/min = 1181 IPM
    (machines/speedio_s500x2.json).

Defaults under test (user, 2026-10-16): C1 on every flute, eccentric runout, provisional C3/C4 limits
from data/model_v2/provisional_limits.json, C11 feed caps, C12 ae ≥ 2·TIR.

The user's tools: T1 1/8" 4FL, LCF 0.5, stickout 0.6, 1/8" shank; T12 1/16" 4FL, LCF 0.1875, 1/8" shank,
stickout 0.5 (tests/test_micro_tools.py). Material 17-4 PH H1025, 356 HB.
"""
import math
import unittest

from gwizard_physics import BeamDeflectionEngine
from physics_v2 import forces as f
from physics_v2 import optimize as o
from toolwiz_common.tool_profile import Segment

M17_4 = o.material_17_4(356)
SPEEDIO = o.speedio_16k(0.0002)
T1 = o.Tool.build(0.125, 4, 0.5, 0.6, shank=0.125, label="T1")
T12 = o.Tool.build(0.0625, 4, 0.1875, 0.5, shank=0.125, label="T12")


class TestInputs(unittest.TestCase):
    def test_17_4_is_p5_annealed_scaled_by_hardness(self):
        k = M17_4.kienzle_at_hb()
        self.assertEqual(dict(M17_4.kienzle.source)["code"], "P5.0.Z.AN")
        self.assertAlmostEqual(k.kc1_1, 1800.0 * (356.0 / 200.0) ** 0.41, places=6)
        self.assertAlmostEqual(k.kc1_1, 2280.0, delta=1.0)
        self.assertEqual(k.mc, 0.21)

    def test_margins_from_aggressiveness(self):
        m = o.Margins(0.5)
        self.assertAlmostEqual(m.limit_scale, 1.0)
        self.assertAlmostEqual(m.life_ratio, 1.0)
        self.assertAlmostEqual(m.limit_margin, 0.1)
        self.assertAlmostEqual(o.Margins(1.0).life_ratio, 0.5)
        self.assertAlmostEqual(o.Margins(0.0).life_ratio, 2.0)
        self.assertAlmostEqual(M17_4.lam(0.0), 0.4)
        self.assertAlmostEqual(M17_4.lam(1.0), 0.2)
        with self.assertRaises(ValueError):
            o.Margins(1.5)

    def test_every_placeholder_is_labelled(self):
        r = o.optimize(T12, M17_4, SPEEDIO, "slot", robustness=False)
        params = r["parameters"]
        for name in ("k_r", "tool_factor", "kc_hardness_exp", "vc_ref_sfm", "vc_hardness_exp",
                     "vc_engagement_exp", "taylor_n", "edge_radius_mm", "effective_feed_ipm", "k_tir"):
            self.assertTrue(params[name]["placeholder"], name)
            self.assertTrue(params[name]["basis"], name)
        self.assertFalse(params["E_mpa"]["placeholder"])
        for name in ("chip_limit_mm", "deflection_allow_in", "stress_limit_mpa"):    # adopted basis
            self.assertFalse(params[name]["placeholder"], name)


class TestConstraintsByHand(unittest.TestCase):
    def test_c1_minimum_chip(self):
        c = o.c1_min_chip(0.001, 0.002, 0.3)
        self.assertAlmostEqual(c.limit, 0.0006)
        self.assertAlmostEqual(c.margin, (0.001 - 0.0006) / 0.0006)
        self.assertTrue(c.ok)
        self.assertFalse(o.c1_min_chip(0.0005, 0.002, 0.3).ok)

    def test_c2_tooth_strength(self):
        c = o.c2_tooth_strength(0.010, 0.0127, 0.9)
        self.assertAlmostEqual(c.limit, 0.9 * 0.0127)
        self.assertAlmostEqual(c.margin, (0.01143 - 0.010) / 0.01143)
        self.assertFalse(o.c2_tooth_strength(0.012, 0.0127, 0.9).ok)

    def test_c2_limit_is_the_vendor_chip_median(self):
        band = o.chip_limit(T12.D)
        self.assertEqual(band["band"], "1/16–3/32")
        self.assertLess(band["p10"], band["h_worst_over_D"])
        self.assertLess(band["h_worst_over_D"], band["p90"])
        ctx = o._Context(T12, M17_4, SPEEDIO, "adaptive", o.Margins(0.5))
        self.assertAlmostEqual(ctx.h_tooth, band["h_worst_over_D"] * T12.D_mm)
        # Aggressiveness scales it: ×0.7 at 0, ×1.3 at 1.
        c = o.CutPoint(o._Context(T12, M17_4, SPEEDIO, "adaptive", o.Margins(1.0)), 0.1, 0.01).c2([0.001])
        self.assertAlmostEqual(c.limit, 1.3 * ctx.h_tooth)

    def test_c3_deflection_check(self):
        c = o.c3_deflection(0.0002, 0.00025)
        self.assertAlmostEqual(c.margin, 0.2)

    def test_c3_c4_adopted_defaults(self):
        ctx = o._Context(T12, M17_4, SPEEDIO, "adaptive", o.Margins(0.5))
        self.assertAlmostEqual(ctx.delta_allow, 0.5 * 0.05 / 25.4)            # 50 % of 0.05 mm stock
        self.assertAlmostEqual(ctx.stress_limit, 0.375 * 3800.0)              # fatigue, 10⁷ cycles
        ctx = o._Context(T12, M17_4, SPEEDIO, "slot", o.Margins(0.5), stock_to_leave_in=0.1 / 25.4)
        self.assertAlmostEqual(ctx.delta_allow, 0.5 * 0.1 / 25.4)
        self.assertAlmostEqual(o._Context(T12, M17_4, SPEEDIO, "adaptive", o.Margins(0.0)).stress_limit,
                               0.7 * 1425.0)

    def test_c4_stress_limit(self):
        c = o.c4_stress(500.0, 1288.0)
        self.assertAlmostEqual(c.margin, (1288.0 - 500.0) / 1288.0)
        self.assertFalse(o.c4_stress(1300.0, 1288.0).ok)

    def test_c11_feed(self):
        self.assertAlmostEqual(SPEEDIO.max_feed_ipm, 30000 / 25.4)
        c = o.c11_feed(150.0, SPEEDIO.max_feed_ipm, 200.0)
        self.assertEqual(c.limit, 200.0)
        self.assertAlmostEqual(c.margin, 0.25)
        self.assertAlmostEqual(o.c11_feed(150.0, SPEEDIO.max_feed_ipm, None).limit, 1181.1, places=1)
        self.assertFalse(o.c11_feed(150.0).applies)

    def test_c12_every_flute_reaches_the_stock(self):
        c = o.c12_radial_reach(0.0005, 0.0002)
        self.assertAlmostEqual(c.limit, 0.0004)
        self.assertAlmostEqual(c.margin, 0.25)
        self.assertFalse(o.c12_radial_reach(0.0003, 0.0002).ok)

    def test_c5_spindle_continuous_rating(self):
        # Above the 4500 rpm base speed the continuous rating is 5.1 kW flat: T = P/ω.
        rpm = 8000.0
        t_avail = 5100.0 / (2 * math.pi * rpm / 60.0)
        c = o.c5_spindle(1.0, 0.2, rpm, SPEEDIO.spindle, "continuous", margin=0.1)
        self.assertAlmostEqual(c.value, 1.0 / t_avail, places=3)
        self.assertAlmostEqual(c.limit, 0.9)
        # Below base speed the continuous torque is ~10.82 N·m (constant torque).
        c = o.c5_spindle(10.0, 0.2, 2000.0, SPEEDIO.spindle, "continuous")
        self.assertAlmostEqual(c.value, 10.0 / 10.82, places=3)

    def test_c6_geometry(self):
        self.assertAlmostEqual(o.c6_geometry(0.1875, 0.01, 0.0625, 0.1875).margin, 0.0)
        self.assertFalse(o.c6_geometry(0.2, 0.01, 0.0625, 0.1875).ok)
        c = o.c6_geometry(0.1, 0.01, 0.0625, 0.1875, depth_in=0.08)
        self.assertAlmostEqual(c.value, 0.1 / 0.08)
        self.assertFalse(c.ok)

    def test_c7_taylor_speed(self):
        phi = f.engagement_angle(0.25, 1.0)                       # 60°
        v = o.taylor_speed_m_min(M17_4, phi) * o.FT_PER_M
        self.assertAlmostEqual(v, 262.0 * (200.0 / 356.0) * (1.0 / 3.0) ** -0.4, places=6)
        # No speed credit below 0.1·D: 0.05·D gets the 0.1·D speed.
        v01 = o.taylor_speed_m_min(M17_4, f.engagement_angle(0.1, 1.0)) * o.FT_PER_M
        v005 = o.taylor_speed_m_min(M17_4, f.engagement_angle(0.05, 1.0)) * o.FT_PER_M
        self.assertAlmostEqual(v01, 262.0 * (200.0 / 356.0) * (math.acos(0.8) / math.pi) ** -0.4, places=6)
        self.assertAlmostEqual(v005, v01)
        # Half the tool life (aggressiveness 1): ×0.5^−0.25.
        v_fast = o.taylor_speed_m_min(M17_4, phi, life_ratio=0.5) * o.FT_PER_M
        self.assertAlmostEqual(v_fast / v, 0.5 ** -0.25)

    def test_c7_rpm_cap_binds(self):
        # T12 at 0.1·D asks 277.6 SFM = 16,962 rpm; the 16k spindle caps it.
        rpm, vc, c = o.c7_speed(M17_4, f.engagement_angle(0.1, 1.0), T12.D_mm, 16000.0)
        want = 12.0 * 262.0 * (200.0 / 356.0) * (math.acos(0.8) / math.pi) ** -0.4 / (math.pi * 0.0625)
        self.assertAlmostEqual(want, 16962.0, delta=1.0)
        self.assertEqual(rpm, 16000.0)
        self.assertAlmostEqual(c.margin, 0.0)
        self.assertIn(f"{want:.0f} rpm", c.detail)

    def test_c8_micro_slot_depth(self):
        self.assertEqual(o.slot_depth_ratio(0.03125), 0.14)
        self.assertEqual(o.slot_depth_ratio(0.0625), 0.35)
        self.assertIsNone(o.slot_depth_ratio(0.125))
        c = o.c8_slot_depth(0.03, 0.0625, "slot")
        self.assertAlmostEqual(c.limit, 0.35 * 0.0625)
        self.assertFalse(c.ok)
        self.assertFalse(o.c8_slot_depth(0.03, 0.0625, "adaptive").applies)
        self.assertFalse(o.c8_slot_depth(0.03, 0.125, "slot").applies)

    def test_c9_stickout(self):
        factor, c = o.c9_stickout(0.375, 0.0625)                 # 6·D: 1 − 0.1·2
        self.assertAlmostEqual(factor, 0.8)
        self.assertAlmostEqual(c.value, 6.0)
        self.assertTrue(c.ok)                                     # a derating, never a violation
        self.assertEqual(o.c9_stickout(0.25, 0.0625)[0], 1.0)

    def test_c10_work_hardening(self):
        self.assertFalse(o.c10_work_hardening(0.001).applies)
        c = o.c10_work_hardening(0.001, 0.002)
        self.assertAlmostEqual(c.margin, -0.5)
        self.assertFalse(c.ok)


class TestBeam(unittest.TestCase):
    L, d = 0.6, 0.125
    rod = [Segment("shank", 0.0, 0.6, 0.125, 0.125, False)]

    def test_load_at_a_matches_the_cantilever_formula(self):
        I = math.pi * self.d ** 4 / 64.0
        E, F = 90e6, 5.0
        for a in (0.0, 0.1, 0.3):
            tip = o.deflection_in(F, self.rod, a, 0.0, E_psi=E)
            under = o.deflection_in(F, self.rod, a, a, E_psi=E)
            self.assertAlmostEqual(tip, F * (2 * self.L ** 3 - 3 * a * self.L ** 2 + a ** 3) / (6 * E * I), places=12)
            self.assertAlmostEqual(under, F * (self.L - a) ** 3 / (3 * E * I), places=12)

    def test_tip_load_is_v1s_exact_integral(self):
        for tool in (T1, T12):
            v1 = BeamDeflectionEngine.deflection_from_segments(3.0, tool.segments, tool.z, tool.helix_deg)
            v2 = o.deflection_in(3.0, tool.segments, 0.0, 0.0, tool.z, tool.helix_deg, E_psi=90e6)
            self.assertAlmostEqual(v2, v1, places=12)

    def test_stepped_profile_against_numeric_integration(self):
        segs, a = T12.segments, 0.09
        n, total = 20000, 0.0                  # midpoint rule; one cell straddles the 0.1875" step
        L = segs[-1].end
        for i in range(n):
            x = a + (L - a) * (i + 0.5) / n
            sg = next(s for s in segs if s.start <= x <= s.end)
            inertia = (BeamDeflectionEngine.fluted_core_inertia(sg.d0, 4, 35.0) if sg.fluted
                       else BeamDeflectionEngine.solid_circular_inertia(sg.d0))
            total += (x - a) * x / inertia * (L - a) / n
        self.assertAlmostEqual(o.compliance_integral(segs, a, 0.0, 4, 35.0) / total, 1.0, places=4)

    def test_load_at_centroid_deflects_less_than_at_tip(self):
        tip = o.deflection_in(3.0, T12.segments, 0.0, 0.0, 4, 35.0)
        mid = o.deflection_in(3.0, T12.segments, 0.09, 0.0, 4, 35.0)
        self.assertLess(mid, 0.6 * tip)

    def test_section_stress(self):
        F, a, x, d, T = 10.0, 0.1, 0.5, 1.905, 0.01
        m, sigma, tau, s1 = o.section_stress(F, a, T, x, *o.circle(d))
        self.assertAlmostEqual(m, 10.0 * 0.4 * 25.4)
        self.assertAlmostEqual(sigma, 32 * 101.6 / (math.pi * d ** 3))
        self.assertAlmostEqual(tau, 16 * 10.0 / (math.pi * d ** 3))
        self.assertAlmostEqual(s1, sigma / 2 + math.hypot(sigma / 2, tau))

    def test_critical_sections_of_t12(self):
        core = o.critical_sections(T12.segments, 4, 35.0, "core", 0.6)
        self.assertEqual([(round(x, 4), k) for x, k, _, _ in core], [(0.1875, "flute root"), (0.5, "holder face")])
        self.assertAlmostEqual(core[0][2], math.pi * (0.6 * 0.0625 * 25.4) ** 4 / 64)
        self.assertAlmostEqual(core[1][2], math.pi * (0.125 * 25.4) ** 4 / 64)
        # Round 3 default: the flute root uses the deflection's own fluted inertia, outer fibre at D/2.
        fl = o.critical_sections(T12.segments, 4, 35.0)
        self.assertAlmostEqual(fl[0][2], BeamDeflectionEngine.fluted_core_inertia(0.0625, 4, 35.0) * 25.4 ** 4)
        self.assertAlmostEqual(fl[0][3], 0.0625 * 25.4 / 2)
        # That section is about a 0.8·D cylinder (Kops & Vo 1990): (64·I/π)^¼ / D.
        d_eq = (64 * fl[0][2] / math.pi) ** 0.25 / (0.0625 * 25.4)
        self.assertAlmostEqual(d_eq, 0.8, delta=0.02)
        # Core circle: the flute root (0.95 mm, lever 0.0975") outweighs the holder face.
        top = o.bending_sections(T12.segments, 10.0, 0.09, 0.0, 4, 35.0, "core", 0.6)[0]
        self.assertEqual(top["kind"], "flute root")
        fluted = o.bending_sections(T12.segments, 10.0, 0.09, 0.0, 4, 35.0)
        root = next(b for b in fluted if b["kind"] == "flute root")
        self.assertLess(root["sigma1_mpa"], top["sigma1_mpa"] / 1.8)


class TestRunoutChips(unittest.TestCase):
    def test_bound_runout_by_hand(self):
        # T12, Harvey SF_875400 roughing: fz 0.00026", ae 0.4·D, TIR 0.0002" on flute 0.
        D, fz, tir = 0.0625, 0.00026, 0.0002
        eng = o.Engagement(D, 4, 0.0372, 0.4 * D, 35.0)
        chips = eng.max_chips(fz, f.runout_offsets(tir, 4))
        s_hi = math.sin(math.acos(1 - 2 * 0.4))                           # flute 0 engages ae
        s_lo = math.sin(math.acos(1 - 2 * (0.4 * D - tir) / D))           # the others ae − TIR
        expect = [min(fz * s_hi + tir, 4 * fz * s_hi),
                  max(0.0, fz * s_lo - tir),
                  min(fz * s_lo, 2 * fz * s_lo - tir),
                  min(fz * s_lo, 2 * fz * s_lo, 3 * fz * s_lo - tir)]
        for got, want in zip(chips, expect):
            self.assertAlmostEqual(got, want, places=12)
        self.assertAlmostEqual(chips[0], 0.000454748, places=8)

    def test_offset_is_not_scaled_by_engagement(self):
        # At 0.1·D the worst chip is fz·0.6 + TIR, not (fz + TIR)·0.6 as step 2 approximates.
        D, fz, tir = 1.0, 0.001, 0.0005
        chips = o.Engagement(D, 4, 1.0, 0.1 * D).max_chips(fz, f.runout_offsets(tir, 4))
        self.assertAlmostEqual(chips[0], fz * 0.6 + tir, places=12)

    def test_eccentric_worst_phase(self):
        offs = o.runout_offsets_worst(1.0, 4)
        self.assertAlmostEqual(max(offs) - min(offs), math.sin(math.pi / 4), places=3)   # spread at that phase
        deficit = max(offs[(k - 1) % 4] - offs[k] for k in range(4))
        self.assertAlmostEqual(deficit, math.sin(math.pi / 4), places=3)          # 0.71·TIR
        offs3 = o.runout_offsets_worst(1.0, 3)
        self.assertAlmostEqual(max(offs3[(k - 1) % 3] - offs3[k] for k in range(3)), math.sin(math.pi / 3), places=3)

    def test_eccentric_thinnest_flute_by_hand(self):
        # Harvey SF_875400 on T12: fz 0.00026", ae 0.4·D, TIR 0.0002". The thinnest flute keeps
        # fz·sin φe − 0.71·TIR ≈ 0.44·fz (the user's 0.46–0.85·fz range for vendor cuts).
        D, fz, tir = 0.0625, 0.00026, 0.0002
        chips = o.Engagement(D, 4, 0.0372, 0.4 * D).max_chips(fz, o.runout_offsets_worst(tir, 4))
        self.assertAlmostEqual(min(chips) / fz, 0.44, delta=0.01)

    def test_stepover_inside_the_runout_leaves_one_flute(self):
        chips = o.Engagement(1.0, 4, 1.0, 0.0004).max_chips(0.001, f.runout_offsets(0.0005, 4))
        self.assertGreater(chips[0], 0.0)
        self.assertEqual(chips[1:], [0.0, 0.0, 0.0])


class TestForceKernel(unittest.TestCase):
    """Engagement.loads without runout reproduces step 2's lateral force, torque and power."""
    coeffs = M17_4.coefficients()

    def check(self, D, z, ap, ae, helix, fz=0.01):
        cut = f.Cut(D, z, ap, ae, fz, 6000.0, helix)
        ktc = self.coeffs.kc(f.mean_chip_thickness(fz, ae, D))
        ref = f.lateral_force(cut, ktc, self.coeffs.k_r * ktc, n_theta=720, n_axial=512)
        got = o.Engagement(D, z, ap, ae, helix).loads(fz, [0.0] * z, self.coeffs, 1440, 192)
        self.assertAlmostEqual(got["mean_n"] / ref["mean_n"], 1.0, places=4)
        self.assertAlmostEqual(got["peak_n"] / ref["peak_n"], 1.0, delta=0.01)
        total = f.cutting_forces(cut, self.coeffs)["total"]
        self.assertAlmostEqual(got["torque_mean_nm"] / total["torque_nm"], 1.0, places=3)

    def test_t12_harvey_cut(self):
        self.check(1.5875, 4, 0.945, 0.635, 35.0)

    def test_deep_narrow_helix(self):
        self.check(1.5875, 4, 4.76, 0.159, 35.0)

    def test_slot_and_straight_flutes(self):
        self.check(10.0, 4, 5.0, 10.0, 30.0)
        self.check(10.0, 3, 2.0, 2.5, 0.0)

    def test_centroid_of_a_uniform_load_is_mid_depth(self):
        # Full slot, 4 flutes: the engaged edge length is constant, so the load sits at ap/2.
        r = o.Engagement(10.0, 4, 5.0, 10.0, 30.0).loads(0.01, [0.0] * 4, self.coeffs, 720, 96)
        self.assertAlmostEqual(r["centroid_mm"], 2.5, delta=0.02)


class TestEvaluateCut(unittest.TestCase):
    def test_every_constraint_has_a_source(self):
        r = o.evaluate_cut(T12, M17_4, SPEEDIO, "adaptive", 0.0372, 0.025, 0.00026, rpm=6112)
        for c in r["checks"].values():
            self.assertTrue(c["source"])
            self.assertIn("value", c)
            self.assertIn("limit", c)
            self.assertIn("margin", c)

    def test_reports_all_twelve_constraints_and_the_bound_warning(self):
        r = o.evaluate_cut(T12, M17_4, SPEEDIO, "adaptive", 0.0372, 0.025, 0.00026, rpm=6112)
        self.assertEqual(list(r["checks"]), [f"C{i}" for i in range(1, 14)])
        self.assertIn("runout_bound", r)
        self.assertAlmostEqual(r["cut"]["toolpath_in_per_in3"], 1 / (0.0372 * 0.025))

    def test_v1_cut_under_v2_physics(self):
        # v1's adaptive answer for T12 (17-4 H1025, aggressiveness 50): 0.0119" × 0.0156", 16,000 rpm,
        # fz 0.00054". Its worst-flute chip is well over the vendor median; the vendor-median C3 of Round 2
        # (now only reported) would also reject it.
        r = o.evaluate_cut(T12, M17_4, SPEEDIO, "adaptive", 0.0119, 0.0156, 0.00054, rpm=16000)
        self.assertIn("C2", r["violated"])
        self.assertGreater(r["vendor_median_comparison"]["deflection_ratio"], 1.8)


class TestOptimizer(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.t12 = o.optimize(T12, M17_4, SPEEDIO, "adaptive")

    def test_t12_adaptive_is_deep_and_narrow(self):
        r = self.t12
        c = r["cut"]
        self.assertTrue(r["feasible"])
        self.assertEqual(r["violated"], [])
        self.assertGreaterEqual(c["ap_in"], 2.0 * T12.D)          # deep: at least 2·D
        self.assertLessEqual(c["ae_in"], 0.25 * T12.D)            # narrow: at most 0.25·D
        self.assertGreaterEqual(c["ap_in"] / c["ae_in"], 4.0)
        self.assertIn("C2", r["binding"])                         # the chip invariant sets the feed
        self.assertGreaterEqual(c["ae_in"], 2 * SPEEDIO.tir_in)   # C12
        self.assertLessEqual(c["feed_ipm"], 200.0 + 1e-6)          # C11

    def test_speed_comes_from_tool_life(self):
        c = self.t12["cut"]
        rpm, _, _ = o.c7_speed(M17_4, f.engagement_angle(c["ae_in"], T12.D), T12.D_mm, 16000.0,
                               reach_factor=o.reach_sfm_factor(
                                   BeamDeflectionEngine.equivalent_stickout(T12.segments, T12.D, 4, 35.0), T12.D))
        self.assertAlmostEqual(c["rpm"], rpm)

    def test_result_carries_provenance_and_robustness(self):
        r = self.t12
        self.assertTrue(any(p.startswith("selection:") for p in r["provenance"]))
        self.assertTrue(any(p.startswith("binding:") for p in r["provenance"]))
        self.assertEqual(set(r["robustness"]), {"TIR ×2", "K_r 0.6 (top of 0.3–0.6)", "C2 chip limit −25 %",
                                                "kc +20 % (hardness/tool factor)"})

    def test_why_full_depth_must_be_narrow(self):
        # Every flute must cut: fz·sin φe ≥ 0.71·TIR + λ·r_β. At full flute length and 0.25·D that fz
        # already deflects T12 past C3, so no fz is feasible there; with C1 on the worst flute only it is.
        ctx = o._Context(T12, M17_4, SPEEDIO, "adaptive", o.Margins(0.5))
        win = o.CutPoint(ctx, T12.lcf, 0.25 * T12.D).fz_window()
        self.assertIsNotNone(win)
        self.assertIsNone(win[1])
        ctx_w = o._Context(T12, M17_4, SPEEDIO, "adaptive", o.Margins(0.5), c1_flute="worst")
        self.assertIsNotNone(o.CutPoint(ctx_w, T12.lcf, 0.25 * T12.D).fz_window()[1])

    def test_vendor_median_limits_are_reported_only(self):
        self.assertEqual(o.provisional_limits(0.0625)["band"], "1/16–3/32")
        self.assertEqual(o.provisional_limits(0.125)["band"], "1/8–3/16")
        r = self.t12
        band = o.provisional_limits(T12.D)
        cmp = r["vendor_median_comparison"]
        self.assertAlmostEqual(cmp["vendor_median_deflection_in"], band["deflection_over_D"] * T12.D)
        self.assertAlmostEqual(cmp["vendor_median_sigma1_mpa"], band["sigma1_mpa"])
        self.assertAlmostEqual(r["parameters"]["stress_limit_mpa"]["value"], 1425.0)

    def test_slot_fixes_ae_and_c8_caps_depth(self):
        r = o.optimize(T12, M17_4, SPEEDIO, "slot", robustness=False)
        self.assertTrue(r["feasible"])
        self.assertAlmostEqual(r["cut"]["ae_in"], T12.D)
        self.assertLessEqual(r["cut"]["ap_in"], 0.35 * T12.D + 1e-12)

    def test_finish_maximizes_feed_at_the_fixed_cut(self):
        # Feasible only with (near) zero runout: see the next test.
        tight = o.speedio_16k(0.0)
        r = o.optimize(T1, M17_4, tight, "finish", stock=0.005, wall_height=0.125, robustness=False)
        c = r["cut"]
        self.assertTrue(r["feasible"])
        self.assertAlmostEqual(c["ap_in"], 0.125)
        self.assertAlmostEqual(c["ae_in"], 0.005)
        self.assertIn("C3", r["binding"])
        looser = o.optimize(T1, M17_4, tight, "finish", stock=0.005, wall_height=0.125,
                            deflection_allow=2 * r["parameters"]["deflection_allow_in"]["value"], robustness=False)
        self.assertGreater(looser["cut"]["fz_in"], c["fz_in"])

    def test_finish_at_0002_runout_cannot_hold_the_finish_tolerance(self):
        # Every flute needs fz·sin φe ≥ 0.71·TIR; that chip's load already deflects T1 past v1's
        # 0.00025" finishing limit on a 0.25" wall, so the result is infeasible and says why.
        r = o.optimize(T1, M17_4, SPEEDIO, "finish", stock=0.005, wall_height=0.25, robustness=False)
        self.assertFalse(r["feasible"])
        self.assertIn("C3", r["binding"])

    def test_real_depth_gives_even_levels(self):
        r = o.optimize(T12, M17_4, SPEEDIO, "adaptive", depth=0.25, grid=(8, 8), robust=False, robustness=False)
        n = 0.25 / r["cut"]["ap_in"]
        self.assertAlmostEqual(n, round(n), places=9)
        self.assertGreaterEqual(round(n), 2)                      # LCF 0.1875 < 0.25

    def test_level_overhead_score(self):
        r = o.optimize(T12, M17_4, SPEEDIO, "adaptive", depth=0.25, level_time_s=3.0,
                       path_length_per_level_in=20.0, grid=(8, 8), robust=False, robustness=False)
        c = r["cut"]
        self.assertAlmostEqual(r["score"], c["mrr_in3_min"] / (1 + 3.0 * c["feed_ipm"] / 60.0 / 20.0))

    def test_higher_aggressiveness_never_removes_less(self):
        lo = o.optimize(T1, M17_4, SPEEDIO, "adaptive", 0.2, grid=(10, 8), robust=False, robustness=False)
        hi = o.optimize(T1, M17_4, SPEEDIO, "adaptive", 0.8, grid=(10, 8), robust=False, robustness=False)
        self.assertGreater(hi["cut"]["mrr_in3_min"], lo["cut"]["mrr_in3_min"])

    def test_infeasible_reports_why(self):
        # A 1/32" tool with 0.002" runout cannot cut at all.
        tiny = o.Tool.build(0.03125, 4, 0.09375, 0.5, shank=0.125)
        r = o.optimize(tiny, M17_4, o.speedio_16k(0.002), "adaptive", grid=(4, 4), robustness=False)
        self.assertFalse(r["feasible"])
        self.assertTrue(r["infeasible_counts"])
        self.assertTrue(r["binding"])


if __name__ == "__main__":
    unittest.main()


class TestProvisionalLimits(unittest.TestCase):
    def test_file_matches_the_generator(self):
        import importlib.util
        import os
        path = os.path.join(o.ROOT, "tools", "v2_provisional_limits.py")
        spec = importlib.util.spec_from_file_location("v2_provisional_limits", path)
        gen = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(gen)
        fresh = gen.build()
        stored = o._limits(o.LIMITS_PATH)
        self.assertEqual([b["band"] for b in fresh["bands"]], [b["band"] for b in stored["bands"]])
        for a, b in zip(fresh["bands"], stored["bands"]):
            self.assertEqual(a["n"], b["n"])
            self.assertAlmostEqual(a["deflection_over_D"], b["deflection_over_D"], places=9)
            self.assertAlmostEqual(a["sigma1_mpa"], b["sigma1_mpa"], places=6)
        self.assertTrue(stored["status"].startswith("PROVISIONAL"))

    def test_row_hardness_conversions(self):
        import importlib.util
        import os
        spec = importlib.util.spec_from_file_location(
            "v2_provisional_limits", os.path.join(o.ROOT, "tools", "v2_provisional_limits.py"))
        gen = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(gen)
        self.assertEqual(gen.row_hb({"min": 300, "max": 350, "scale": "HBn"}), 325.0)
        self.assertAlmostEqual(gen.row_hb({"min": 29, "max": 37, "scale": "HRC"}),
                               gen.ASTMHardnessConverter.hrc_to_brinell(33.0))
        self.assertIsNone(gen.row_hb(None))


class TestRound3Tooling(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        import importlib.util
        import os
        spec = importlib.util.spec_from_file_location(
            "v2_invariants", os.path.join(o.ROOT, "tools", "v2_invariants.py"))
        cls.vi = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cls.vi)
        cls.row = next(r for r in cls.vi.load_rows() if r["id"] == "harvey_SF875400_ss_ph_300-350HBn_rough_0.062")

    def test_stats(self):
        s = self.vi.stats([1.0, 2.0, 3.0, 4.0])
        self.assertAlmostEqual(s["median"], 2.5)
        self.assertAlmostEqual(s["cv"], math.sqrt(1.25) / 2.5)
        self.assertGreater(s["p90_p10"], 1.0)

    def test_flute_root_stress_does_not_depend_on_stickout(self):
        # M at the flute root is F·(x_root − a): nothing beyond the root enters it.
        m = o.speedio_16k(0.0002)
        a = self.vi.evaluate(self.row, m, stickout_extra=0.0, n_theta=120, n_quad=32)
        b = self.vi.evaluate(self.row, m, stickout_extra=2.0, n_theta=120, n_quad=32)
        self.assertAlmostEqual(a["sigma_root"], b["sigma_root"], places=6)
        self.assertGreater(b["delta_in"], 1.3 * a["delta_in"])   # deflection does (1.34× here)

    def test_fluted_section_halves_the_core_circle_stress(self):
        m = o.speedio_16k(0.0002)
        core = self.vi.evaluate(self.row, m, section="core", n_theta=120, n_quad=32)
        fl = self.vi.evaluate(self.row, m, section="v1_section", n_theta=120, n_quad=32)
        self.assertGreater(core["sigma_root"] / fl["sigma_root"], 1.8)

    def test_optimizer_stress_matches_the_analysis_section(self):
        # The optimizer's default C4 section is the analysis's "v1_section".
        I, c = o.section_props(0.0625, True, 4, 35.0)
        I2, c2, _ = self.vi.section_props(None, 0.0625, 4, 35.0, "v1_section", 0.6)
        self.assertAlmostEqual(I, I2)
        self.assertAlmostEqual(c, c2)


class TestProgramSizeAndWall(unittest.TestCase):
    """User's NC-file model (2026-10-16) and the finishing wall tolerance."""

    def test_program_bytes_by_hand(self):
        # 23.1 bytes/line × L_cut/s, L_cut = V/(ap·ae)·1.15; 1 in³ at 0.1875" × 0.0078", s 0.22 mm.
        l_in = 1.0 / (0.1875 * 0.0078) * 1.15
        self.assertAlmostEqual(o.program_bytes(0.1875, 0.0078), 23.1 * l_in * 25.4 / 0.22)
        self.assertAlmostEqual(o.program_bytes(0.1875, 0.0078, 2.0, 0.04), 2 * 23.1 * l_in * 25.4 / 0.04)
        # Per inch of cutting path: 2,667 bytes at 0.22 mm (the user's 2,860 ≈ s 0.205 mm), 14,669 at 0.04.
        self.assertAlmostEqual(23.1 * 25.4 / 0.22, 2667, delta=1)
        self.assertAlmostEqual(23.1 * 25.4 / 0.04, 14669, delta=1)

    def test_c13_is_off_by_default_and_binds_when_on(self):
        self.assertFalse(o.c13_program_size(0.1875, 0.0078, None, None).applies)
        c = o.c13_program_size(0.1875, 0.0008, 1.0, 6e6)
        self.assertFalse(c.ok)                                  # ~19 MB for 1 in³ at 0.012·D
        r = o.optimize(T12, M17_4, SPEEDIO, "adaptive", limit_program_size=True, removal_volume_in3=1.0,
                       deflection_allow=1.0, stress_limit=1425.0, grid=(10, 10), robust=False, robustness=False)
        self.assertLessEqual(r["cut"]["program"]["bytes_for_volume"]["s=0.22mm"], 6e6)
        with self.assertRaises(ValueError):
            o.optimize(T12, M17_4, SPEEDIO, "adaptive", limit_program_size=True, robustness=False)

    def test_finish_default_tolerance_is_0005mm(self):
        ctx = o._Context(T1, M17_4, SPEEDIO, "finish", o.Margins(0.5))
        self.assertAlmostEqual(ctx.delta_allow, 0.005 / 25.4)
        ctx = o._Context(T1, M17_4, SPEEDIO, "finish", o.Margins(0.5), wall_tolerance_in=0.001 / 25.4)
        self.assertAlmostEqual(ctx.delta_allow, 0.001 / 25.4)

    def test_wall_error_is_reported_and_split(self):
        r = o.evaluate_cut(T1, M17_4, o.speedio_16k(0.0), "finish", 0.125, 0.005, 0.0001, rpm=7800)
        w = r["loads"]["wall_error_in"]
        self.assertLessEqual(w["max_in"], r["loads"]["deflection_tip_in"] + 1e-12)
        self.assertGreater(w["mean_in"], 0.0)                 # pushed off the wall: stock left
        self.assertAlmostEqual(r["checks"]["C3"]["value"], w["max_in"])
        rough = o.evaluate_cut(T1, M17_4, SPEEDIO, "adaptive", 0.5, 0.01, 0.0005, rpm=7800)
        self.assertIn("wall_error_in", rough["loads"])

    def test_trade_front_is_monotone(self):
        r = o.optimize(T1, M17_4, SPEEDIO, "adaptive", grid=(10, 10), robust=False, robustness=False)
        front = r["trade"]
        self.assertGreater(len(front), 1)
        for a, b in zip(front, front[1:]):
            self.assertLessEqual(a["toolpath_in_per_in3"], b["toolpath_in_per_in3"])
            self.assertLess(a["mrr_in3_min"], b["mrr_in3_min"])


class TestC1WallFlute(unittest.TestCase):
    def test_wall_flute_variant_checks_the_outermost_flute(self):
        ctx = o._Context(T1, M17_4, SPEEDIO, "finish", o.Margins(0.5), c1_flute="wall")
        pt = o.CutPoint(ctx, 0.25, 0.002)
        chips = pt.max_chips_mm(0.0003)
        k = max(range(4), key=lambda i: pt.offsets[i])
        self.assertAlmostEqual(pt.lower_checks(chips)["C1"].value, chips[k])
        thin = o.CutPoint(o._Context(T1, M17_4, SPEEDIO, "finish", o.Margins(0.5)), 0.25, 0.002)
        self.assertLessEqual(thin.fz_window()[0], 1.0)
        self.assertLess(pt.fz_window()[0], thin.fz_window()[0])      # fewer flutes to satisfy → lower min fz
