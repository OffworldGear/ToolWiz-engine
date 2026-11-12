"""Flute-aware chip load (owner decision 2026-11-12, aluminium first): C2 and C14's chip range x F(flutes) from
data/model_v2/chip_by_flutes.json (tools/fit_chip_by_flutes.py)."""
import json
import os
import subprocess
import sys
import unittest

from physics_v2 import params
from physics_v2 import optimize as o

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AL, SS, TI, ST = ("Aluminum - Wrought (6061)", "Stainless - PH Series (17-4)", "Titanium Alloy",
                  "Steel - Medium Carbon Alloy (4130)")
TABLE = json.load(open(os.path.join(ROOT, "data", "model_v2", "chip_by_flutes.json"), encoding="utf-8"))


def tool(z, D=0.25, stick=4.0):
    return o.Tool.build(D, z, 3 * D, stick * D, shank=D)


def run(z, family=AL, op="slot", D=0.25, stick=4.0, a=0.5):
    return params.optimize(tool(z, D, stick), params.material(family), op, a, machine_=params.machine(), robust=False,
                           robustness=False)


def ctx(z, family=AL, op="slot", D=0.25):
    return o._Context(tool(z, D), params.material(family), params.machine(), op, params.margins(0.5), c2_basis="nominal",
                      chip_flutes=o.CHIP_FLUTES_DEFAULT_PATH, vendor_table=o.VENDOR_TABLE_DEFAULT_PATH)


class TestFit(unittest.TestCase):
    def test_file_is_current(self):
        r = subprocess.run([sys.executable, os.path.join(ROOT, "tools", "fit_chip_by_flutes.py"), "--check"],
                           capture_output=True, text=True, cwd=ROOT)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)

    def test_applied_only_for_aluminium_slot_and_side(self):
        applied = {(g, c) for g, cls in TABLE["groups"].items() for c, e in cls.items() if e["applied"]}
        self.assertEqual(applied, {("non-ferrous", "slot"), ("non-ferrous", "side")})

    def test_factors_never_rise_with_flute_count_and_4_flutes_is_1(self):
        for cls in ("slot", "side"):
            f = TABLE["groups"]["non-ferrous"][cls]["factors"]
            self.assertEqual(f["4"], 1.0)
            vals = [f[str(z)] for z in range(1, 9)]
            for a, b in zip(vals, vals[1:]):
                self.assertLessEqual(b, a)
        self.assertGreater(TABLE["groups"]["non-ferrous"]["slot"]["factors"]["2"], 2.0)

    def test_every_charted_count_has_rows_from_two_vendor_groups(self):
        for cls in ("slot", "side"):
            e = TABLE["groups"]["non-ferrous"][cls]
            for z, b in e["factor_basis"].items():
                if b == "measured":
                    m = e["measured"][z]
                    self.assertGreaterEqual(m["n"], TABLE["min_rows"])
                    self.assertGreaterEqual(m["vendor_groups"], TABLE["min_vendor_groups"])


class TestEngine(unittest.TestCase):
    def test_c2_limit_scales_with_the_factor(self):
        base = ctx(4)
        for z in (2, 3, 5, 7):
            c = ctx(z)
            f = TABLE["groups"]["non-ferrous"]["slot"]["factors"][str(z)]
            self.assertAlmostEqual(c.h_nominal / base.h_nominal, f, places=9)
            self.assertAlmostEqual(c.h_overload / base.h_overload, f, places=9)
            self.assertTrue(c.flute_aware)

    def test_other_materials_and_hem_are_flute_agnostic(self):
        for fam, op in ((SS, "slot"), (TI, "slot"), (ST, "rough"), (AL, "adaptive")):
            for z in (2, 5):
                c = ctx(z, fam, op)
                self.assertFalse(c.flute_aware, (fam, op))
                self.assertEqual(c.flute_factor, 1.0)
            self.assertAlmostEqual(ctx(2, fam, op).h_nominal, ctx(5, fam, op).h_nominal, places=12)

    def test_vendor_chip_range_follows_the_flute_count(self):
        r2 = ctx(2).consensus_for(0.25)["ranges"]["fz_over_D"]
        r4 = ctx(4).consensus_for(0.25)["ranges"]["fz_over_D"]
        f = TABLE["groups"]["non-ferrous"]["slot"]["factors"]
        for a, b in zip(r2, r4):
            self.assertAlmostEqual(a / b, f["2"] / f["4"], places=6)

    def test_few_flute_slot_out_removes_the_five_flute(self):
        # 1/2" at 4xD stickout and 1/4" at 3xD stickout: the 2-flute tool removes at least as much as the 5-flute
        for D, stick in ((0.5, 4.0), (0.25, 3.0), (0.125, 3.0)):
            m = {z: run(z, AL, "slot", D, stick)["cut"]["mrr_in3_min"] for z in (2, 3, 5)}
            self.assertGreaterEqual(max(m[2], m[3]), m[5] * (1 - 1e-6), (D, stick, m))

    def test_result_flags(self):
        out = run(2, AL, "slot", 0.125)
        self.assertTrue(out["chip_space"]["flute_aware"])
        self.assertTrue(out["vendor_basis"]["flute_aware"])
        out = run(2, TI, "slot", 0.125)
        self.assertFalse(out["chip_space"]["flute_aware"])


class TestRecommenderCaveat(unittest.TestCase):
    def test_caveat_dropped_only_where_flute_aware(self):
        import tool_recommender as tr
        spec = tr.parse_request(dict(family=AL, operation="Slotting", diameter=0.25, flutes=3, flute_length=0.75))
        cut = tr.Cut(spec, {"max_rpm": 16000, "max_hp": 10})

        class R:
            pass
        aware, agnostic = R(), R()
        aware.chip_space = {"flute_aware": True}
        agnostic.chip_space = {"flute_aware": False}
        self.assertIsNone(tr._chip_space_caveat(cut, {"flutes": 5}, aware, aware))
        self.assertIn("optimistic", tr._chip_space_caveat(cut, {"flutes": 5}, aware, agnostic))
        self.assertIn("optimistic", tr._chip_space_caveat(cut, {"flutes": 5}, agnostic, agnostic))


if __name__ == "__main__":
    unittest.main()
