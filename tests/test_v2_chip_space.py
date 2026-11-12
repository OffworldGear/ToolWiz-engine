"""C15 chip space (physics_v2/chipspace.py, data/model_v2/chip_space.json): the gullet must hold the chip.

Model and calibration: docs/research/chip_space.md, tools/calibrate_chip_space.py."""
import json
import os
import subprocess
import sys
import unittest

import app
import runout_sensitivity
import v2_bridge
from physics_v2 import chipspace, params
from physics_v2 import optimize as o

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AL = "Aluminum - Wrought (6061)"
P = chipspace.load()


def tool(z, D=0.25, lcf=None, stick=None):
    return o.Tool.build(D, z, lcf or 3 * D, stick or 4 * D, shank=D)


def max_fz(z, D, ap, ae, group="non-ferrous"):
    K, _ = chipspace.group_packing(group, P)
    core = chipspace.core_ratio(z, P["core_ratio_by_flutes"])
    return chipspace.max_fz(ap, ae, D, z, K, core, float(P["void_fraction"]["value"]), P)


def calc(**kw):
    c = app.app.test_client()
    c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
    D = kw.pop("diameter", 0.25)
    body = dict(family=AL, alloy="", tool="Carbide Endmill", coating="Uncoated", geometry="Square",
                operation="Slotting / Tab Milling", aggressiveness=50, diameter=D, fluteLength=3 * D, shankDiameter=D,
                stickout=4 * D, isCarbide=True, model="v2")
    body.update(kw)
    return c.post("/api/calculate", json=body).get_json()


class TestModel(unittest.TestCase):
    def test_full_slot_chip_per_tooth_and_per_rev_fall_with_flutes(self):
        for group in ("non-ferrous", "steel", "stainless", "Ti-Ni-Co"):
            for D in (0.0625, 0.125, 0.25, 0.5):
                for apd in (0.25, 0.5, 1.0, 1.5, 2.0):
                    tooth = [max_fz(z, D, apd * D, D, group) for z in range(2, 9)]
                    rev = [z * f for z, f in zip(range(2, 9), tooth)]
                    for a, b in zip(tooth, tooth[1:]):
                        self.assertLess(b, a, (group, D, apd))
                    for a, b in zip(rev, rev[1:]):
                        self.assertLessEqual(b, a * (1 + 1e-12), (group, D, apd))

    def test_chip_area_is_fz_times_ae(self):
        # h_m · arc length = fz·ae (Sandvik h_m = fz·(ae/D)/(φe/2), arc = φe·D/2)
        import math
        D, fz = 0.25, 0.002
        for ae in (0.01, 0.05, 0.125, 0.2, 0.25):
            phi = math.acos(1 - 2 * ae / D)
            h_m = fz * (ae / D) / (phi / 2)
            self.assertAlmostEqual(h_m * phi * D / 2, chipspace.chip_area(fz, ae, D), places=12)

    def test_depth_only_counts_in_a_full_slot(self):
        D = 0.25
        self.assertEqual(chipspace.depth_factor(2 * D, 0.5 * D, D, P), 1.0)
        self.assertEqual(chipspace.depth_factor(0.5 * D, D, D, P), 1.0)
        self.assertGreater(chipspace.depth_factor(2 * D, D, D, P), chipspace.depth_factor(D, D, D, P))

    def test_aluminium_packs_worse_than_steel(self):
        self.assertGreater(P["packing"]["non-ferrous"]["K"], P["packing"]["steel"]["K"])


class TestCalibration(unittest.TestCase):
    def test_parameter_file_is_current(self):
        r = subprocess.run([sys.executable, os.path.join(ROOT, "tools", "calibrate_chip_space.py"), "--check"],
                           capture_output=True, text=True, cwd=ROOT)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)

    def test_no_published_full_slot_is_outside_the_limit_at_full_aggressiveness(self):
        sys.path.insert(0, os.path.join(ROOT, "tools"))
        import calibrate_chip_space as cal
        p, rows = cal.calibrate()
        self.assertGreater(len(rows), 700)
        for x in rows:
            K = p["packing"][x["group"]]["K"]
            self.assertGreaterEqual(x["K_row"], K * (1 - 1e-9), x["id"])

    def test_sources_are_named(self):
        self.assertIn("US 10,335,870", P["core_ratio_by_flutes"]["_source"])
        for g in ("non-ferrous", "steel", "stainless", "Ti-Ni-Co"):
            self.assertIn("most packed published full slot", P["packing"][g]["basis"])
        for k in ("a0_over_D", "k_d", "enclosed_ae_over_D"):
            self.assertTrue(P["depth"][k]["source"])


class TestOptimizer(unittest.TestCase):
    def test_chip_space_alone_favours_fewer_flutes_in_a_6061_slot(self):
        """With the chip limit C2 and the vendor guardrail out of the way, C15 decides: the 2- and 3-flute tools take a
        bigger chip and remove at least as much as the 5-flute in a full-depth 1/4" slot in 6061."""
        m = params.material(AL)
        out = {}
        for z in (2, 3, 4, 5, 6, 7):
            r = params.evaluate_user_engagement(tool(z), m, "slot", 0.25, 0.25, 0.5, chip_limit_over_D=0.05,
                                                consensus=None, vendor_table=None, consensus_shaped=None,
                                                c2_basis="worst")
            self.assertIn("C15", r["binding"], z)
            out[z] = r["cut"]
        fz = [out[z]["fz_in"] for z in sorted(out)]
        self.assertEqual(fz, sorted(fz, reverse=True))
        self.assertGreaterEqual(out[2]["mrr_in3_min"], out[5]["mrr_in3_min"])
        self.assertGreaterEqual(out[3]["mrr_in3_min"], out[5]["mrr_in3_min"])
        # and the chip loads it allows are the vendors' aluminium slot chip loads (fz/D 0.018-0.025 for 2 flutes,
        # 0.006-0.012 for 3, 0.008-0.009 for 4: tests/benchmarks/v2) within the 50 % margin
        self.assertTrue(0.012 < out[2]["fz_in"] / 0.25 < 0.025, out[2]["fz_in"])
        self.assertTrue(0.006 < out[3]["fz_in"] / 0.25 < 0.012, out[3]["fz_in"])
        self.assertTrue(0.005 < out[4]["fz_in"] / 0.25 < 0.009, out[4]["fz_in"])

    def test_check_is_reported_and_off_without_the_file(self):
        m = params.material(AL)
        r = o.evaluate_cut(tool(5), m, params.machine(), "slot", 0.25, 0.25, 0.001)
        self.assertNotIn("C15", r["checks"])
        self.assertFalse(r["chip_space"]["applies"])
        r = o.evaluate_cut(tool(5), m, params.machine(), "slot", 0.25, 0.25, 0.001, chip_space=params.CHIP_SPACE_PATH)
        self.assertIn("C15", r["checks"])
        self.assertTrue(r["chip_space"]["applies"])

    def test_finishing_is_not_chip_space_limited(self):
        m = params.material(AL)
        r = o.evaluate_cut(tool(7), m, params.machine(), "finish", 0.5, 0.005, 0.002, chip_space=params.CHIP_SPACE_PATH)
        self.assertNotIn("C15", r["checks"])

    def test_light_radial_hem_with_many_flutes_is_unchanged(self):
        """HEM in 17-4 and titanium with 5-7 flutes: within 3 % of the result without C15."""
        for fam in ("Stainless - PH Series (17-4)", "Titanium Alloy"):
            m = params.material(fam)
            for z in (5, 6, 7):
                t = tool(z)
                a = params.optimize(t, m, "adaptive", robust=False, robustness=False)
                b = params.optimize(t, m, "adaptive", robust=False, robustness=False, chip_space=None)
                self.assertNotIn("C15", a["binding"], (fam, z))
                self.assertLess(a["chip_space"]["fill_of_limit"], 0.5, (fam, z))
                ra = a["cut"]["mrr_in3_min"] / b["cut"]["mrr_in3_min"]
                self.assertTrue(0.97 <= ra <= 1.03, (fam, z, ra))


class TestPipeline(unittest.TestCase):
    def test_deep_full_slot_chip_per_tooth_does_not_rise_with_flutes(self):
        fz = []
        for z in (2, 3, 4, 5, 6, 7):
            r = calc(flutes=z, cutDepth=0.5, cutWidth=0.25)
            fz.append(r["adj_ipt"])
            self.assertIn("chip_space", r)
            if z >= 5:
                # since 2026-11-12 the flute-aware C2 (aluminium slots, chip_by_flutes.json) holds 5-7 flutes at or below
                # the chip-room ceiling, so either limit may bind; C15 stays the ceiling
                self.assertTrue("C15" in r["limited_by"] or ("C2" in r["limited_by"] and r["chip_space"]["flute_aware"]),
                                (z, r["limited_by"]))
                self.assertLessEqual(r["adj_ipt"], r["chip_space"]["max_fz_in"] * (1 + 1e-3))
        for a, b in zip(fz, fz[1:]):
            self.assertLessEqual(b, a * (1 + 1e-6), fz)

    def test_seven_flute_full_slot_in_6061_is_limited_and_says_why(self):
        # C15 on its own (the flute-agnostic C2 of before 2026-11-12): it limits the 7-flute slot and says why
        def eng(z, **kw):
            return params.optimize(tool(z), params.material(AL), "slot", 0.5, robust=False, robustness=False, **kw)
        out = eng(7, chip_flutes=None)
        cs = out["chip_space"]
        self.assertIn("C15", out["binding"])
        self.assertTrue(cs["limiting"])
        self.assertIn("7 flutes leave too little chip room for a full slot in aluminum", cs["sentence"])
        self.assertIn("flute tool can take a larger chip", cs["sentence"])
        r3 = eng(3, chip_flutes=None)
        self.assertFalse(r3["chip_space"]["limiting"])
        self.assertGreater(r3["chip_space"]["max_fz_in"], 2 * cs["max_fz_in"])
        # with the flute-aware C2 (default) the 7-flute chip is no larger than C15 alone allowed
        r = calc(flutes=7)
        self.assertTrue(r["chip_space"]["flute_aware"])
        self.assertLessEqual(r["adj_ipt"], out["cut"]["fz_in"] * (1 + 1e-3))

    def test_every_endpoint_returns_the_block(self):
        r = calc(flutes=4, model="v1")
        self.assertEqual(r["chip_space"]["applies"], False)
        c = app.app.test_client()
        c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
        geo = {"DC": 0.25, "NOF": 5, "LCF": 0.75, "SFDM": 0.25, "LB": 1.0}
        f = c.post("/api/calculate_for_fusion", json={
            "family": AL, "alloy": "", "operation": "Slotting / Tab Milling", "aggressiveness": 50, "model": "v2",
            "tool": {"type": "flat end mill", "unit": "inches", "geometry": geo, "description": "5FL carbide"}}).get_json()
        self.assertTrue(f.get("success"), f)
        self.assertTrue(f["chip_space"]["applies"])
        import mcp_server
        m = mcp_server.call_mcp_tool_by_name("toolwiz_calculate_cut", {
            "family": AL, "alloy": "", "operation": "Slotting / Tab Milling", "diameter": 0.25, "flutes": 7,
            "aggressiveness": 0.5, "model": "v2"})
        self.assertIn("chip_space", m)

    def test_cache_key_carries_the_chip_space_file(self):
        from pipeline import CutRequest, _normalize
        geo = {"DC": 0.25, "NOF": 5, "LCF": 0.75, "SFDM": 0.25, "LB": 1.0}
        r = _normalize(CutRequest(family=AL, alloy="", tool="Carbide Endmill", coating="Uncoated", geometry="Square",
                                  operation="Slotting / Tab Milling", diameter=0.25, flutes=5, aggressiveness=0.5,
                                  max_rpm=16000.0, max_hp=6.84, runout=0.0002, stickout=None,
                                  fusion_tool={"type": "flat end mill", "unit": "inches", "geometry": geo}))
        m, _ = v2_bridge.machine_for(r)
        key = json.loads(v2_bridge._cache_key(r, "slot", None, m, {}))
        self.assertEqual(key["cs"][0], P["version"])
        self.assertIn(["non-ferrous", P["packing"]["non-ferrous"]["K"]], key["cs"][1])

    def test_c15_has_plain_words_everywhere(self):
        self.assertIn("C15", runout_sensitivity.CHECK_WORDS)
        with open(os.path.join(ROOT, "static", "js", "results_v3.js"), encoding="utf-8") as fh:
            js = fh.read()
        self.assertIn("C15:", js)
        self.assertIn("chipSpaceLine", js)
        with open(os.path.join(ROOT, "ToolWizFusionAddin", "ToolWizFusionAddin.py"), encoding="utf-8") as fh:
            self.assertIn('"C15":', fh.read())
        with open(os.path.join(ROOT, "templates", "partials", "results_v3.html"), encoding="utf-8") as fh:
            self.assertIn('id="chipSpaceLine"', fh.read())


if __name__ == "__main__":
    unittest.main()
