"""Provenance and unified-pipeline behaviour tests for pipeline.run_cut."""
import os
import sys
import unittest
from unittest import mock

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
import app as app_module
from app import app
import pipeline
from pipeline import CutRequest, run_cut, provenance_product
from tests.test_pipeline_parity import all_payloads

REQUIRED_KEYS = {"step", "quantity", "multiplier", "value_after", "reason"}
EXPECTED_SFM_STEPS = ["base_lookup", "hardness", "chatter", "aggressiveness", "hem_thermal", "slot_engagement", "coating", "spindle_cap"]
EXPECTED_IPT_STEPS = ["base_lookup", "hardness", "chatter", "aggressiveness", "chip_thinning"]


class _Capture:
    """Wrap app.run_cut so tests see the exact (unrounded) CutResult an endpoint produced."""

    def __init__(self):
        self.results = []

    def __call__(self, physics, req):
        res = run_cut(physics, req)
        self.results.append(res)
        return res


class TestProvenanceMultipliesOut(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.client = app.test_client()
        cls.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def _call(self, route, payload):
        cap = _Capture()
        with mock.patch.object(app_module, "run_cut", cap):
            resp = self.client.post(route, json=payload)
        self.assertEqual(resp.status_code, 200, resp.get_data(as_text=True))
        self.assertEqual(len(cap.results), 1)
        return resp.get_json(), cap.results[0]

    def _assert_multiplies_out(self, name, res):
        for p in res.provenance:
            self.assertTrue(REQUIRED_KEYS <= set(p), f"{name}: bad provenance entry {p}")
            self.assertIn(p["quantity"], ("sfm", "ipt"))
        sfm_steps = [p["step"] for p in res.provenance if p["quantity"] == "sfm"]
        ipt_steps = [p["step"] for p in res.provenance if p["quantity"] == "ipt"]
        self.assertEqual(sfm_steps, EXPECTED_SFM_STEPS, name)
        self.assertEqual(ipt_steps, EXPECTED_IPT_STEPS, name)

        # SFM: base * product(multipliers before the spindle cap) == target SFM
        base_sfm = next(p for p in res.provenance if p["quantity"] == "sfm")["value_after"]
        self.assertAlmostEqual(base_sfm, res.base_sfm, delta=abs(res.base_sfm) * 1e-9 + 1e-12, msg=name)
        got = base_sfm * provenance_product(res, "sfm")
        self.assertAlmostEqual(got, res.target_sfm, delta=abs(res.target_sfm) * 0.005 + 1e-9,
                               msg=f"{name}: sfm product {got} vs target {res.target_sfm}")

        # Spindle cap lands on the contact SFM the final RPM actually produces
        cap = next(p for p in res.provenance if p["step"] == "spindle_cap")
        self.assertLessEqual(cap["multiplier"], 1.0 + 1e-9, name)
        self.assertAlmostEqual(cap["value_after"], res.contact_sfm, delta=abs(res.contact_sfm) * 0.005 + 1e-6, msg=name)
        if not res.is_spindle_limited:
            self.assertAlmostEqual(cap["multiplier"], 1.0, delta=0.005, msg=name)

        # IPT: base * product(multipliers) == adjusted chipload
        base_ipt = next(p for p in res.provenance if p["quantity"] == "ipt")["value_after"]
        self.assertAlmostEqual(base_ipt, res.base_ipt_lookup, delta=abs(res.base_ipt_lookup) * 1e-9 + 1e-12, msg=name)
        got_ipt = base_ipt * provenance_product(res, "ipt")
        self.assertAlmostEqual(got_ipt, res.adj_ipt, delta=abs(res.adj_ipt) * 0.005 + 1e-12,
                               msg=f"{name}: ipt product {got_ipt} vs adj {res.adj_ipt}")

    def test_every_parity_case_multiplies_out(self):
        for name, payload in all_payloads().items():
            with self.subTest(case=name):
                body, res = self._call("/api/calculate", payload)
                self.assertIn("provenance", body)
                self.assertEqual(body["provenance"], res.provenance)
                self._assert_multiplies_out(name, res)

    def test_fusion_endpoint_multiplies_out_and_reports_provenance(self):
        payload = {
            "family": "Steel - Medium Carbon Alloy (4130)", "alloy": "4140 (Annealed)", "operation": "Adaptive Roughing",
            "aggressiveness": 50, "tool": "Carbide Endmill", "coating": "AlTiN", "diameter": 0.5, "flutes": 4,
            "fluteLength": 1.0, "shankDiameter": 0.5, "cornerRadius": 0.0, "stickout": 1.5, "geometry": "Square",
        }
        body, res = self._call("/api/calculate_for_fusion", payload)
        self.assertIn("provenance", body)
        self._assert_multiplies_out("fusion", res)
        # cut actually computed at the recommended engagement
        self.assertAlmostEqual(res.doc, res.rec_doc, places=9)
        self.assertAlmostEqual(res.woc, res.rec_woc, places=9)
        self.assertAlmostEqual(body["doc"], round(res.rec_doc, 3), places=9)
        self.assertAlmostEqual(body["woc"], round(res.rec_woc, 3), places=9)

    def test_hard_milling_is_recorded_in_hardness_step(self):
        payload = all_payloads()["extra_ball_h13_hard"]
        _, res = self._call("/api/calculate", payload)
        hard = next(p for p in res.provenance if p["step"] == "hardness" and p["quantity"] == "sfm")
        self.assertLess(hard["multiplier"], 1.0)
        self.assertIn("hard-milling", hard["reason"])

    def test_tap_skips_aggressiveness_hem_and_coating(self):
        _, res = self._call("/api/calculate", all_payloads()["extra_tap_form"])
        for step in ("aggressiveness", "hem_thermal", "coating"):
            entry = next(p for p in res.provenance if p["step"] == step and p["quantity"] == "sfm")
            self.assertEqual(entry["multiplier"], 1.0)
            self.assertIn("skipped", entry["reason"])


class TestRunCutDirect(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.physics = app_module.physics

    def _req(self, **kw):
        base = dict(family="Aluminum - Wrought (6061)", alloy="6061-T6", tool="Carbide Endmill", geometry="Square",
                    operation="Roughing", coating="Uncoated", diameter=0.5, flutes=3, flute_length=1.0,
                    stickout=1.5, max_rpm=16000.0, max_hp=10.0)
        base.update(kw)
        return CutRequest(**base)

    def test_none_cut_uses_recommendation(self):
        res = run_cut(self.physics, self._req())
        self.assertEqual(res.doc, res.rec_doc)
        self.assertEqual(res.woc, res.rec_woc)
        self.assertGreater(res.rpm, 0)
        self.assertGreater(res.feed_ipm, 0)
        self.assertGreater(res.mrr, 0)

    def test_explicit_cut_is_respected(self):
        res = run_cut(self.physics, self._req(cut_depth=0.2, cut_width=0.1))
        self.assertEqual((res.doc, res.woc), (0.2, 0.1))

    def test_request_not_mutated(self):
        req = self._req(geometry="T-Slot", tool="Woodruff Saw", cutter_thickness=0.1, flute_length=1.0)
        snapshot = dict(vars(req))
        run_cut(self.physics, req)
        self.assertEqual(vars(req), snapshot)

    def test_spindle_cap_recorded(self):
        res = run_cut(self.physics, self._req(diameter=0.0625, max_rpm=5000.0, cut_depth=0.05, cut_width=0.03))
        self.assertTrue(res.is_spindle_limited)
        cap = next(p for p in res.provenance if p["step"] == "spindle_cap")
        self.assertLess(cap["multiplier"], 1.0)
        self.assertTrue(any(t["title"] == "Spindle RPM Limited" for t in res.tips))

    def test_infeasible_adds_critical_tip_first(self):
        res = run_cut(self.physics, self._req(diameter=0.03125, stickout=2.0, flute_length=0.1,
                                              family="Titanium Alloy", alloy="", aggressiveness=1.0))
        if not res.feasible:
            self.assertEqual(res.tips[0]["title"], "Infeasible Setup")
        else:  # still must carry provenance
            self.assertTrue(res.provenance)


class TestStockCompensationUsesPipeline(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.client = app.test_client()
        cls.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def test_missing_rpm_and_feed_come_from_run_cut(self):
        cap = _Capture()
        payload = {
            "family": "Aluminum - Wrought (6061)", "alloy": "6061-T6", "aggressiveness": 50, "mode": "auto_compensate",
            "operations": [{
                "id": "op1", "name": "2D Contour - Finish Wall", "strategy": "contour2d", "unit": "inches",
                "diameter": 0.375, "flutes": 3, "fluteLength": 0.75, "shankDiameter": 0.375, "stickout": 1.25,
                "rpm": 0, "feedrate": 0, "doc": 0.5, "woc": 0.015,
            }],
        }
        with mock.patch.object(app_module, "run_cut", cap):
            resp = self.client.post("/api/stock_compensation", json=payload)
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(cap.results), 1)
        self.assertTrue(resp.get_json()["results"][0]["is_finishing"])
        self.assertGreater(cap.results[0].rpm, 0)

    def test_supplied_rpm_and_feed_skip_the_pipeline(self):
        cap = _Capture()
        payload = {
            "family": "Aluminum - Wrought (6061)", "alloy": "", "aggressiveness": 50, "mode": "auto_compensate",
            "operations": [{"id": "op1", "name": "rough", "strategy": "adaptive", "unit": "inches", "diameter": 0.5,
                            "flutes": 3, "rpm": 8000, "feedrate": 60, "doc": 0.5, "woc": 0.2}],
        }
        with mock.patch.object(app_module, "run_cut", cap):
            resp = self.client.post("/api/stock_compensation", json=payload)
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(cap.results, [])


if __name__ == "__main__":
    unittest.main()
