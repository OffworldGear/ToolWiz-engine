"""v1/v2 cutting-model switch (v2_bridge): selection, scope, result mapping, endpoints, add-in message."""
import dataclasses
import os
import tempfile
import unittest
from unittest import mock

import app
import v2_bridge
from pipeline import CutRequest, run_cut

T12 = {"DC": 0.0625, "NOF": 4, "LCF": 0.1875, "SFDM": 0.125, "LB": 0.5}


def req(geo=T12, **kw):
    base = dict(family="Stainless - PH Series (17-4)", alloy="17-4 PH (H 1025)", tool="HP Carbide Endmill",
                coating="AlTiN", geometry="Square", operation="Adaptive Roughing", diameter=geo["DC"],
                flutes=geo["NOF"], aggressiveness=0.5, max_rpm=16000.0, max_hp=6.84, runout=0.0002,
                stickout=None, fusion_tool={"type": "flat end mill", "unit": "inches", "geometry": geo})
    base.update(kw)
    return CutRequest(**base)


class TestModelSelection(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.path = os.path.join(self.tmp.name, "model_settings.json")

    def test_precedence(self):
        with mock.patch.dict(os.environ, {"TOOLWIZ_MODEL": ""}):
            self.assertEqual(v2_bridge.resolve_model(None, path=self.path), ("v1", "default"))
        with mock.patch.dict(os.environ, {"TOOLWIZ_MODEL": "v2"}):
            self.assertEqual(v2_bridge.resolve_model(None, path=self.path), ("v2", "TOOLWIZ_MODEL"))
            v2_bridge.save_model("v1", self.path)
            self.assertEqual(v2_bridge.resolve_model(None, path=self.path), ("v1", "saved setting"))
            self.assertEqual(v2_bridge.resolve_model(None, use_saved=False, path=self.path), ("v2", "TOOLWIZ_MODEL"))
            self.assertEqual(v2_bridge.resolve_model("V2", path=self.path), ("v2", "request"))

    def test_bad_values(self):
        with self.assertRaises(ValueError):
            v2_bridge.save_model("v3", self.path)
        with mock.patch.dict(os.environ, {"TOOLWIZ_MODEL": "nonsense"}):
            self.assertEqual(v2_bridge.resolve_model("also bad", path=self.path)[0], "v1")


class TestPipeline(unittest.TestCase):
    def test_default_is_v1_and_unchanged(self):
        a = run_cut(app.physics, req())
        b = run_cut(app.physics, req(model="v1"))
        self.assertEqual(a.model, "v1")
        self.assertIsNone(a.v2)
        for f in ("rpm", "feed_ipm", "adj_ipt", "rec_doc", "rec_woc", "mrr"):
            self.assertEqual(getattr(a, f), getattr(b, f), f)

    def test_v2_adaptive_on_t12(self):
        v1 = run_cut(app.physics, req())
        r = run_cut(app.physics, req(model="v2"))
        self.assertEqual(r.model, "v2")
        self.assertTrue(r.feasible)
        self.assertEqual(r.v1["rpm"], v1.rpm)
        self.assertGreater(r.rec_doc, 5 * v1.rec_doc)          # deep and narrow
        self.assertLess(r.rec_woc / r.diameter, 0.5)
        self.assertGreater(r.mrr, v1.mrr)
        self.assertLessEqual(r.rpm, 16000.0)
        self.assertAlmostEqual(r.feed_ipm, r.rpm * r.adj_ipt * 4, delta=0.05)
        self.assertEqual(r.provenance, [])
        self.assertTrue(r.v2["provenance"])
        self.assertTrue(set(r.v2["binding"]) <= set(r.v2["checks"]))
        self.assertIn("C14v", r.v2["checks"])
        self.assertLessEqual(r.ramp_feed, v1.ramp_feed + 1e-9)
        self.assertEqual(r.tips[0]["title"], "Cutting model: v2")

    def test_out_of_scope_falls_back_to_v1_with_reason(self):
        cases = {
            "operation": dict(operation="Semi-Finishing"),
            "ball": dict(geometry="Ball"),
            "family": dict(family="Wood: MDF", alloy=""),
        }
        for name, kw in cases.items():
            with self.subTest(name):
                v1 = run_cut(app.physics, req(**kw))
                r = run_cut(app.physics, req(model="v2", **kw))
                self.assertEqual(r.model, "v1")
                self.assertTrue(r.model_note.startswith("v2 selected; v1 used because"))
                self.assertEqual((r.rpm, r.feed_ipm, r.rec_doc), (v1.rpm, v1.feed_ipm, v1.rec_doc))

    def test_finish_uses_the_stock(self):
        r = run_cut(app.physics, req(model="v2", operation="Wall Finishing (Deep DOC)"))
        self.assertEqual(r.model, "v2")
        self.assertAlmostEqual(r.rec_woc, 0.05 / 25.4, places=6)

    def test_infeasible_micro_tool_reports_runout(self):
        geo = {"DC": 0.0156, "NOF": 4, "LCF": 0.047, "SFDM": 0.125, "LB": 0.4}
        r = run_cut(app.physics, req(geo=geo, model="v2"))
        self.assertEqual(r.model, "v2")
        self.assertFalse(r.feasible)
        self.assertEqual(r.tips[0]["type"], "critical")
        self.assertIn("should NOT be run", r.model_note)

    def test_max_hp_override_scales_the_continuous_curve(self):
        r = dataclasses.replace(req(), max_hp=3.0)
        m, notes = v2_bridge.machine_for(r, app.active_machine())
        self.assertAlmostEqual(m.spindle["power_kw_continuous"], 3.0 / 1.341, places=3)
        self.assertTrue(notes)
        full, _ = v2_bridge.machine_for(req(), app.active_machine())
        self.assertGreater(full.spindle["power_kw_continuous"], m.spindle["power_kw_continuous"])
        self.assertIsNotNone(full.holder_k_n_um)


class TestEndpoints(unittest.TestCase):
    def setUp(self):
        self.c = app.app.test_client()
        self.c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def body(self, **kw):
        b = dict(family="Stainless - PH Series (17-4)", alloy="17-4 PH (H 1025)", tool="HP Carbide Endmill",
                 coating="AlTiN", geometry="Square", operation="Adaptive Roughing", diameter=0.0625, flutes=4,
                 aggressiveness=50, fusion_tool={"type": "flat end mill", "unit": "inches", "geometry": T12})
        b.update(kw)
        return b

    def test_fusion_endpoint_reports_the_model(self):
        v1 = self.c.post("/api/calculate_for_fusion", json=self.body()).get_json()
        v2 = self.c.post("/api/calculate_for_fusion", json=self.body(model="v2")).get_json()
        self.assertEqual(v1["model"], "v1")
        self.assertEqual(v2["model"], "v2")
        self.assertEqual(v1["name"], v2["name"])               # preset names don't change with the model
        self.assertGreater(v2["doc"], v1["doc"])
        self.assertEqual(v2["v1"]["rpm"], v1["rpm"])

    def test_saved_setting_is_ignored_by_the_test_client(self):
        with tempfile.TemporaryDirectory() as d, mock.patch.object(v2_bridge, "SETTINGS_PATH",
                                                                 os.path.join(d, "m.json")):
            v2_bridge.save_model("v2")
            r = self.c.post("/api/calculate_for_fusion", json=self.body()).get_json()
            self.assertEqual(r["model"], "v1")


class TestAddinMessage(unittest.TestCase):
    def test_message_names_the_model_and_v2_limits(self):
        import sys
        sys.path.insert(0, os.path.dirname(__file__))
        from test_addin_common import load_addin
        a = load_addin()
        geo = {"diameter": 0.0625, "flutes": 4}
        msg = a.format_autoset_message("T12", geo, "17-4", "Adaptive", 11291, 13.8, 0.0003,
                                       limited_by="C2, C3", model="v2")
        self.assertIn("Model: v2 (physics)", msg)
        self.assertIn("chip thickness (tooth strength), tool deflection", msg)
        msg = a.format_autoset_message("T12", geo, "17-4", "Adaptive", 1, 1, 0.001, model="v1",
                                       model_note="v2 selected; v1 used because x.")
        self.assertIn("Model: v1", msg)
        self.assertIn("v1 used because x.", msg)


if __name__ == "__main__":
    unittest.main()
