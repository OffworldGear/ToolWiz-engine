"""v2 force model (physics_v2/forces.py) against hand calculations and published formulas.

Every expected value is computed here from a stated formula or quoted from a cited source:
  * Sandvik Coromant, "Milling formulas and definitions"
    (https://www.sandvik.coromant.com/en-gb/knowledge/machining-formulas-definitions/milling-formulas-definitions):
    Pc = ap·ae·vf·kc/(60·10⁶) kW;  Mc = Pc·30·10³/(π·n) N·m;
    fz = hex·Dcap/(2·√(Dcap·ae − ae²)) for side milling with ae < Dcap/2.
  * Sandvik "Specific cutting force": kc = kc1·hm^(−mc)·(1 − γ0/100).
  * ISCAR "Cutting tools user guide" p.57 worked example (row IS-UG in kc_mc_sources.json):
    kc1 = 2450 N/mm², mc = 0.23, rake 10° → kc = 3745 N/mm²; that equation gives it at hm = 0.1 mm.
  * Altintas, Manufacturing Automation ch. 2, average milling forces per tooth period: φ clockwise from
    +y, feed +x, h = c·sin φ, F_x = −F_t·cos φ − F_r·sin φ, F_y = F_t·sin φ − F_r·cos φ, integrated
    over [φst, φex] and divided by the pitch angle 2π/N (closed form in `altintas_mean_forces`). The
    slot case is also on Altintas's UBC MAL course slides "Average Cutting Force Coefficients for
    Milling": F̄x = −N·a·c·Krc/4 − N·a·Kre/π, F̄y = N·a·c·Ktc/4 + N·a·Kte/π.
"""
import doctest
import json
import math
import os
import unittest

import machine_profiles
from physics_v2 import forces as f

P5_PH = f.load_kienzle("P5.0.Z.PH")


def speedio_16k():
    with open(os.path.join(machine_profiles.BUILTIN_DIR, "speedio_s500x2.json"), encoding="utf-8") as fh:
        return json.load(fh)["spindle_options"]["optional_16k"]


def altintas_mean_forces(N, a, c, ktc, krc, kte, kre, phi_st, phi_ex):
    """Average F_x, F_y over one tooth period: closed-form integral of Altintas's force equations."""
    def fx(p):
        return (N * a * c / (8 * math.pi)) * (ktc * math.cos(2 * p) - krc * (2 * p - math.sin(2 * p))) \
            + (N * a / (2 * math.pi)) * (-kte * math.sin(p) + kre * math.cos(p))

    def fy(p):
        return (N * a * c / (8 * math.pi)) * (ktc * (2 * p - math.sin(2 * p)) + krc * math.cos(2 * p)) \
            - (N * a / (2 * math.pi)) * (kte * math.cos(p) + kre * math.sin(p))
    return fx(phi_ex) - fx(phi_st), fy(phi_ex) - fy(phi_st)


def sandvik_hm(fz, ae, D):
    """Mean of h = fz·sin φ over the arc, written with arccos in degrees: (360/π)/arccos°·fz·ae/D."""
    return (360.0 / math.pi) / math.degrees(math.acos(1 - 2 * ae / D)) * fz * ae / D


class TestChipGeometry(unittest.TestCase):
    D = 10.0

    def test_engagement_angle(self):
        self.assertAlmostEqual(f.engagement_angle(self.D, self.D), math.pi)
        self.assertAlmostEqual(f.engagement_angle(self.D / 2, self.D), math.pi / 2)
        self.assertAlmostEqual(f.engagement_angle(self.D / 4, self.D), math.pi / 3)   # arccos(0.5)

    def test_engagement_arc_climb_and_up(self):
        self.assertEqual(f.engagement_arc(self.D / 4, self.D, climb=False), (0.0, f.engagement_angle(2.5, 10)))
        st, ex = f.engagement_arc(self.D / 4, self.D, climb=True)
        self.assertAlmostEqual(st, math.pi - math.pi / 3)
        self.assertAlmostEqual(ex, math.pi)

    def test_max_chip_matches_sandvik_hex(self):
        fz = 0.05
        for ae in (0.5, 1.0, 2.5, 4.9):
            hex_ = fz * 2 * math.sqrt(self.D * ae - ae ** 2) / self.D     # Sandvik fz–hex relation, inverted
            self.assertAlmostEqual(f.max_chip_thickness(fz, ae, self.D), hex_, places=12)
        self.assertEqual(f.max_chip_thickness(fz, 5.0, self.D), fz)
        self.assertEqual(f.max_chip_thickness(fz, 8.0, self.D), fz)

    def test_mean_chip_is_the_arc_mean(self):
        fz = 0.05
        self.assertAlmostEqual(f.mean_chip_thickness(fz, self.D, self.D), fz * 2 / math.pi)   # slot: mean sin = 2/π
        for ae in (0.2, 1.0, 3.0, 7.0):
            self.assertAlmostEqual(f.mean_chip_thickness(fz, ae, self.D), sandvik_hm(fz, ae, self.D), places=12)
            pe = f.engagement_angle(ae, self.D)
            n = 20000
            riemann = sum(fz * math.sin((i + 0.5) * pe / n) for i in range(n)) / n
            self.assertAlmostEqual(f.mean_chip_thickness(fz, ae, self.D), riemann, places=9)

    def test_teeth_in_cut(self):
        self.assertAlmostEqual(f.teeth_in_cut(4, self.D, self.D), 2.0)
        self.assertAlmostEqual(f.teeth_in_cut(3, self.D / 2, self.D), 0.75)
        # Helix overlap: ap·tan β/(π·D/z) = 5·tan 30°/(π·10/4) = 2.88675/7.85398 = 0.36755
        self.assertAlmostEqual(f.teeth_in_cut_helix(4, self.D / 2, self.D, 5.0, 30.0), 1.0 + 0.367553, places=5)
        self.assertEqual(f.teeth_in_cut_helix(4, self.D, self.D, 30.0, 45.0), 4.0)    # capped at z


class TestKienzle(unittest.TestCase):
    def test_sandvik_17_4_row(self):
        # material_mapping_v2.md / kc_mc_survey.md §2: P5.0.Z.PH 330 HB, kc1 = 2800, mc = 0.21.
        self.assertEqual((P5_PH.kc1_1, P5_PH.mc, P5_PH.rake_ref_deg), (2800.0, 0.21, 0.0))
        self.assertIn(("hardness", "330.0 HB"), P5_PH.source)

    def test_kc_at_one_mm_is_kc1(self):
        self.assertAlmostEqual(P5_PH.kc(1.0), 2800.0)
        self.assertAlmostEqual(P5_PH.kc(0.01), 2800.0 * 0.01 ** -0.21)

    def test_iscar_worked_example(self):
        k = f.load_kienzle("AISI H13 (1.2344) annealed", source_id="IS-UG")
        self.assertAlmostEqual(k.kc(0.1, rake_deg=10.0), 3745.0, delta=1.0)

    def test_rake_and_wear_factors(self):
        self.assertAlmostEqual(P5_PH.kc(0.05, rake_deg=8.0), P5_PH.kc(0.05) * 0.92)
        self.assertAlmostEqual(P5_PH.kc(0.05, k_wear=1.3), P5_PH.kc(0.05) * 1.3)
        with self.assertRaises(ValueError):
            P5_PH.kc(0.0)

    def test_material_dependent_rake_basis_must_be_stated(self):
        rows = [r for r in f._sources(f.KC_SOURCES_PATH) if r["source_id"] == "EU-TB"
                and r.get("kc1_1_N_mm2") and r.get("mc") is not None]
        code = rows[0]["material_group_code"]
        with self.assertRaises(ValueError):
            f.load_kienzle(code, source_id="EU-TB")
        k = f.load_kienzle(code, source_id="EU-TB", rake_ref_deg=6.0)
        self.assertAlmostEqual(k.kc(1.0, rake_deg=6.0), k.kc1_1)

    def test_gaps_and_unknown_codes(self):
        with self.assertRaises(ValueError):
            f.load_kienzle("P5.0.C.HT")          # kc1 2100, mc not adopted (survey §2 note)
        with self.assertRaises(KeyError):
            f.load_kienzle("X9.9.Z.ZZ")


class TestPowerAgainstSandvik(unittest.TestCase):
    def check(self, D, z, ap, ae, fz, rpm, rake=0.0):
        cut = f.Cut(D, z, ap, ae, fz, rpm)
        r = f.cutting_forces(cut, f.ForceCoefficients(P5_PH, k_r=0.4, rake_deg=rake))
        hm = sandvik_hm(fz, ae, D)
        kc = 2800.0 * hm ** -0.21 * (1 - rake / 100.0)
        vf = fz * z * rpm
        pc_kw = ap * ae * vf * kc / 60e6
        mc_nm = pc_kw * 30e3 / (math.pi * rpm)
        self.assertAlmostEqual(r["kc_n_mm2"], kc, places=6)
        self.assertAlmostEqual(r["total"]["power_w"] / 1000.0, pc_kw, places=9)
        self.assertAlmostEqual(r["total"]["torque_nm"], mc_nm, places=9)
        self.assertAlmostEqual(r["total"]["torque_nm"] * cut.omega, r["total"]["power_w"], places=9)
        return r

    def test_side_slot_and_wide_cuts(self):
        self.check(10.0, 4, 10.0, 3.0, 0.05, 3183.1)
        self.check(10.0, 4, 5.0, 10.0, 0.04, 3183.1)
        self.check(12.0, 3, 6.0, 8.0, 0.06, 2000.0)
        self.check(1.5875, 4, 0.94, 0.63, 0.0066, 6112.0, rake=5.0)

    def test_edge_force_adds_teeth_in_cut_times_kte_ap_vc(self):
        cut = f.Cut(10.0, 4, 8.0, 2.5, 0.05, 2000.0)
        base = f.cutting_forces(cut, f.ForceCoefficients(P5_PH, k_r=0.4))
        edged = f.cutting_forces(cut, f.ForceCoefficients(P5_PH, k_r=0.4, k_te=20.0))
        zc = 4 * (math.pi / 3) / (2 * math.pi)
        extra_w = zc * 20.0 * 8.0 * (math.pi * 10.0 * 2000.0 / 1000.0 / 60.0)
        self.assertAlmostEqual(edged["total"]["power_w"] - base["total"]["power_w"], extra_w, places=9)

    def test_from_inch(self):
        cut = f.Cut.from_inch(D=0.0625, z=4, ap=0.0372, ae=0.0248, fz=0.00026, sfm=100)
        self.assertAlmostEqual(cut.rpm, 12 * 100 / (math.pi * 0.0625))
        self.assertAlmostEqual(cut.D, 1.5875)
        self.assertAlmostEqual(cut.vc_m_min, 100 * 0.3048, places=9)       # 100 ft/min
        with self.assertRaises(ValueError):
            f.Cut.from_inch(D=0.25, z=4, ap=0.1, ae=0.3, fz=0.001, rpm=5000)   # ae > D


class TestLateralForceAgainstAltintas(unittest.TestCase):
    KTC, KRC, KTE, KRE = 2000.0, 800.0, 20.0, 15.0

    def compare(self, cut, kte, kre, rel=0.003):
        lat = f.lateral_force(cut, self.KTC, self.KRC, kte, kre)
        st, ex = f.engagement_arc(cut.ae, cut.D, cut.climb)
        fx, fy = altintas_mean_forces(cut.z, cut.ap, cut.fz, self.KTC, self.KRC, kte, kre, st, ex)
        scale = math.hypot(fx, fy)
        self.assertAlmostEqual(lat["mean_feed_n"], fx, delta=rel * scale)
        self.assertAlmostEqual(lat["mean_normal_n"], fy, delta=rel * scale)
        return lat, fx, fy

    def test_slot_matches_mal_slide_form(self):
        cut = f.Cut(10.0, 4, 2.0, 10.0, 0.1, 1000.0)
        lat, fx, fy = self.compare(cut, self.KTE, self.KRE)
        N, a, c = 4, 2.0, 0.1
        self.assertAlmostEqual(fx, -N * a * c * self.KRC / 4 - N * a * self.KRE / math.pi, places=9)
        self.assertAlmostEqual(fy, N * a * c * self.KTC / 4 + N * a * self.KTE / math.pi, places=9)

    def test_partial_immersion_up_and_climb(self):
        for climb in (True, False):
            for ae in (1.0, 2.5, 5.0, 7.5):
                self.compare(f.Cut(10.0, 3, 4.0, ae, 0.08, 1000.0, climb=climb), self.KTE, self.KRE)
                self.compare(f.Cut(10.0, 3, 4.0, ae, 0.08, 1000.0, climb=climb), 0.0, 0.0)

    def test_helix_keeps_the_mean_and_lowers_the_peak(self):
        straight = f.Cut(10.0, 4, 10.0, 3.0, 0.05, 1000.0, helix_deg=0.0)
        helical = f.Cut(10.0, 4, 10.0, 3.0, 0.05, 1000.0, helix_deg=35.0)
        a, _, _ = self.compare(straight, 0.0, 0.0)
        b, _, _ = self.compare(helical, 0.0, 0.0)
        self.assertLess(b["peak_n"], a["peak_n"])

    def test_two_flute_slot_peak_is_one_tooth_at_90_degrees(self):
        # Without helix exactly one tooth cuts; |F| = a·c·sin φ·Ktc·√(1 + (Krc/Ktc)²), maximal at φ = 90°.
        cut = f.Cut(10.0, 2, 3.0, 10.0, 0.1, 1000.0)
        lat = f.lateral_force(cut, self.KTC, self.KRC)
        expected = 3.0 * 0.1 * self.KTC * math.sqrt(1 + (self.KRC / self.KTC) ** 2)
        self.assertAlmostEqual(lat["peak_n"], expected, delta=1e-4 * expected)


class TestRunout(unittest.TestCase):
    def test_two_flutes_fz_plus_minus_tir(self):
        for got, want in zip(f.flute_chip_loads(0.010, f.runout_offsets(0.004, 2)), [0.014, 0.006]):
            self.assertAlmostEqual(got, want)

    def test_one_flute_cuts_when_fz_below_tir(self):
        ro = f.runout_chips(0.003, 2, 0.005)
        self.assertAlmostEqual(ro["flute_chips"][0], 0.006)     # feed per rev on one flute
        self.assertEqual(ro["flute_chips"][1], 0.0)
        self.assertEqual(ro["rubbing_flutes"], [1])

    def test_four_flute_bound(self):
        chips = f.flute_chip_loads(0.010, f.runout_offsets(0.004, 4))
        for got, want in zip(chips, [0.014, 0.006, 0.010, 0.010]):
            self.assertAlmostEqual(got, want)

    def test_eccentric_worst_phase(self):
        z, fz, tir = 4, 0.010, 0.004
        phase = math.pi / 2 - math.pi / z          # puts flute 0 at the maximum of r_k − r_(k−1)
        ro = f.runout_chips(fz, z, tir, model="eccentric", phase=phase)
        self.assertEqual(ro["worst_flute"], 0)
        self.assertAlmostEqual(ro["h_worst"], fz + tir * math.sin(math.pi / z))
        self.assertAlmostEqual(sum(ro["flute_chips"]), z * fz)    # the surface still advances z·fz per rev

    def test_no_runout(self):
        self.assertEqual(f.runout_chips(0.01, 3, 0.0)["flute_chips"], [0.01, 0.01, 0.01])

    def test_worst_flute_force_in_cutting_forces(self):
        D, ae, ap, fz, tir = 6.0, 1.5, 6.0, 0.02, 0.008
        r = f.cutting_forces(f.Cut(D, 4, ap, ae, fz, 4000.0), f.ForceCoefficients(P5_PH, k_r=0.4), tir=tir)
        h = (fz + tir) * math.sin(math.acos(1 - 2 * ae / D))
        self.assertAlmostEqual(r["runout"]["h_max_worst_mm"], h)
        self.assertAlmostEqual(r["runout"]["F_t_peak_worst_n"], 2800.0 * h ** -0.21 * h * ap)
        self.assertFalse(r["runout"]["fz_below_tir"])


class TestSpindle(unittest.TestCase):
    def test_below_base_speed_uses_the_constant_torque(self):
        cut = f.Cut(10.0, 4, 10.0, 3.0, 0.05, 3000.0)
        r = f.cutting_forces(cut, f.ForceCoefficients(P5_PH, k_r=0.4), spindle=speedio_16k(), rating="continuous")
        sp = r["spindle"]
        self.assertAlmostEqual(sp["available_torque_nm"], 10.82)          # machines/speedio_s500x2.json
        self.assertAlmostEqual(sp["torque_utilization"], r["total"]["torque_nm"] / 10.82)
        self.assertTrue(sp["ok"])

    def test_overload_and_overspeed(self):
        coeffs = f.ForceCoefficients(P5_PH, k_r=0.4)
        big = f.cutting_forces(f.Cut(25.0, 4, 25.0, 25.0, 0.1, 500.0), coeffs,
                               spindle=speedio_16k(), rating="continuous")
        self.assertGreater(big["total"]["torque_nm"], 10.82)
        self.assertFalse(big["spindle"]["ok"])
        fast = f.cutting_forces(f.Cut(1.0, 2, 0.5, 0.1, 0.005, 20000.0), coeffs,
                                spindle=speedio_16k(), rating="continuous")
        self.assertFalse(fast["spindle"]["rpm_ok"])
        self.assertFalse(fast["spindle"]["ok"])

    def test_default_rating_is_continuous(self):
        # C5 uses the continuous rating (design §7.3, decided 2026-10-15); at 6000 rpm that is 5.1 kW.
        cut = f.Cut(10.0, 4, 10.0, 3.0, 0.05, 6000.0)
        r = f.cutting_forces(cut, f.ForceCoefficients(P5_PH, k_r=0.4), spindle=speedio_16k())
        self.assertEqual(r["spindle"]["rating"], "continuous")
        self.assertAlmostEqual(r["spindle"]["available_power_kw"], 5.1, places=2)


class TestWorkedExample(unittest.TestCase):
    def test_t12_docstring_example(self):
        result = doctest.testmod(f, optionflags=doctest.NORMALIZE_WHITESPACE)
        self.assertGreater(result.attempted, 10)
        self.assertEqual(result.failed, 0)


if __name__ == "__main__":
    unittest.main()
