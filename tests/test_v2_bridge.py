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
            self.assertEqual(v2_bridge.resolve_model(None, path=self.path), ("v2", "default"))
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
            self.assertEqual(v2_bridge.resolve_model("also bad", path=self.path)[0], "v2")


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
        # V3 round 3: ae stays at or above the narrowest vendor cut (0.15·D for 17-4 here), so C3 = k·D limits the depth
        self.assertGreater(r.rec_doc, 1.5 * v1.rec_doc)
        self.assertLess(r.rec_woc / r.diameter, 0.5)
        self.assertGreater(r.mrr, 0.3 * v1.mrr)   # v1 ignores deflection; v2 holds ae at the vendor minimum and C3 = k·D
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
            "chamfer": dict(geometry="Chamfer"),
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

    def test_micro_tool_at_default_runout_cuts_with_reduced_flutes(self):
        # V3 M1: runout alone no longer makes a micro tool infeasible (C1 on the wall flute); it cuts on fewer flutes.
        geo = {"DC": 0.0156, "NOF": 4, "LCF": 0.047, "SFDM": 0.125, "LB": 0.4}
        r = run_cut(app.physics, req(geo=geo, model="v2"))
        self.assertEqual(r.model, "v2")
        self.assertTrue(r.feasible)
        self.assertEqual(r.runout_regime, "reduced_flutes")
        self.assertLess(r.flutes_cutting, 4)
        self.assertTrue(any(t["title"] == "Reduced flutes cutting" for t in r.tips))

    def test_infeasible_micro_tool_reports_runout(self):
        geo = {"DC": 0.0156, "NOF": 4, "LCF": 0.047, "SFDM": 0.125, "LB": 0.4}
        r = run_cut(app.physics, req(geo=geo, model="v2", runout=0.003))   # C12: ae >= 2·TIR is past the adaptive limit
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
        self.assertIn("Model: physics engine (current)", msg)
        self.assertIn("chip thickness (tooth strength), tool deflection", msg)
        msg = a.format_autoset_message("T12", geo, "17-4", "Adaptive", 1, 1, 0.001, model="v1",
                                       model_note="v2 selected; v1 used because x.")
        self.assertIn("Model: legacy tables and rules", msg)
        self.assertIn("v1 used because x.", msg)
        self.assertEqual(
            a._limited_by_text("v2: C14f, C14m"),
            "v2: vendor chart chip load, vendor chart removal rate",
        )

    def test_v2_t12_slotting_17_4_annealed_vendor_depth_and_reduced_flutes(self):
        # V3: the depth is the vendor envelope's (stainless 1/16-1/8" slots), not the old 0.35·D micro table, and the
        # wall-flute C1 (M1) replaces the C14-versus-every-flute-C1 fallback this test used to pin.
        r = run_cut(app.physics, req(alloy="17-4 PH (Annealed)", operation="Slotting", aggressiveness=0.60, model="v2"))
        self.assertEqual(r.model, "v2")
        self.assertTrue(r.feasible)
        self.assertAlmostEqual(r.rec_woc, 0.0625, places=5)
        self.assertLess(r.rec_doc, 0.35 * 0.0625 + 1e-9)    # the cut here is deflection-limited, well under the cap
        self.assertLess(r.feed_ipm, 10.0)
        self.assertIn(r.runout_regime, ("all_flutes", "reduced_flutes"))   # all flutes cut since the hardness recalibration
        self.assertEqual(any(w.startswith("reduced flutes:") for w in r.v2["warnings"]), r.runout_regime == "reduced_flutes")

    def test_addin_drilling_and_tapping_support(self):
        import json
        import sys
        from types import SimpleNamespace
        sys.path.insert(0, os.path.dirname(__file__))
        from test_addin_common import load_addin
        a = load_addin()

        drill_tool_json = json.dumps({
            "type": "drill",
            "unit": "inches",
            "description": "1/8\" Carbide Drill",
            "BMC": "carbide",
            "post-process": {"number": 21},
            "geometry": {"DC": 0.125, "NOF": 2, "LCF": 0.75, "SFDM": 0.125, "LB": 1.0, "TA": 118.0},
        })
        drill_op = SimpleNamespace(
            name="Drill1", strategy="drill",
            tool=SimpleNamespace(toJson=lambda: drill_tool_json),
            parameters=SimpleNamespace(itemByName=lambda _: None),
        )
        g_drill, summary_drill, _ = a.get_op_tool_info(drill_op)
        self.assertTrue(g_drill["isHoleTool"])
        self.assertFalse(g_drill["isTap"])
        self.assertIn("Twist Drill", summary_drill)
        self.assertEqual(a.infer_strategy_for_op(drill_op, g_drill), "Drilling")
        p_drill = a.build_calc_payload(g_drill, "Stainless - PH Series (17-4)", "17-4 PH (Annealed)",
                                       "Drilling", 50, "HP High Performance Carbide", "AlTiN (Black)")
        self.assertEqual(p_drill["tool"], "HP Carbide Twist Drill")
        self.assertEqual(p_drill["geometry"], "Drill")

        tap_tool_json = json.dumps({
            "type": "tap right hand",
            "unit": "inches",
            "description": "1/4-20 Form Tap",
            "BMC": "hss",
            "post-process": {"number": 22},
            "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.625, "SFDM": 0.25, "LB": 1.25, "TP": 0.05},
        })
        tap_op = SimpleNamespace(
            name="Tap1", strategy="drill",
            tool=SimpleNamespace(toJson=lambda: tap_tool_json),
            parameters=SimpleNamespace(itemByName=lambda _: None),
        )
        g_tap, summary_tap, _ = a.get_op_tool_info(tap_op)
        self.assertTrue(g_tap["isTap"])
        self.assertAlmostEqual(g_tap["threadPitch"], 0.05, places=5)
        self.assertIn("20.0 TPI", summary_tap)
        self.assertEqual(a.infer_strategy_for_op(tap_op, g_tap), "Tapping (Form / Roll)")
        p_tap = a.build_calc_payload(g_tap, "Stainless - PH Series (17-4)", "17-4 PH (Annealed)",
                                     "Tapping (Form / Roll)", 50, "High Speed Steel (HSS)", "TiN (Gold)")
        self.assertEqual(p_tap["tool"], "Tapping")
        self.assertEqual(p_tap["tapType"], "form")
        self.assertAlmostEqual(p_tap["pitch"], 0.05, places=5)
        c = app.app.test_client()
        c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
        res_tap = c.post("/api/calculate_for_fusion", json=p_tap).get_json()
        self.assertTrue(res_tap["success"])
        self.assertAlmostEqual(res_tap["feed"], res_tap["rpm"] * 0.05, delta=0.1)

        # 1.45 mm (0.0571") drill with 16 mm (11xD) stickout in 17-4 PH (Annealed):
        # axial drills must not be crushed by lateral milling overhang penalties.
        res_drill = c.post("/api/calculate_for_fusion", json={
            "family": "Stainless - PH Series (17-4)",
            "alloy": "17-4 PH (Annealed)",
            "tool": "Carbide Twist Drill",
            "coating": "Uncoated",
            "geometry": "Drill",
            "operation": "Drilling",
            "diameter": 1.45 / 25.4,
            "flutes": 2,
            "fluteLength": 9.0 / 25.4,
            "stickout": 16.0 / 25.4,
            "shankDiameter": 1.45 / 25.4,
            "aggressiveness": 60,
            "isCarbide": True,
        }).get_json()
        self.assertTrue(res_drill["success"])
        self.assertGreater(res_drill["rpm"], 5000)
        self.assertGreater(res_drill["feed"], 5.0)
        self.assertGreater(res_drill["ipt"], 0.00035)

        # Metric tool in an inch document: unit-less expression '5.842' with evaluated value 5.842 mm/min
        from test_addin_common import param
        self.assertAlmostEqual(a.parse_cam_feed_to_ipm(param("5.842", 5.842), "in"), 5.842 / 25.4, places=3)


if __name__ == "__main__":
    unittest.main()


class TestProductionDefault(unittest.TestCase):
    def test_production_default_is_v2(self):
        """With no request model, saved setting or TOOLWIZ_MODEL, both clients get the v2 physics model."""
        with tempfile.TemporaryDirectory() as d, mock.patch.dict(os.environ, {"TOOLWIZ_MODEL": ""}):
            self.assertEqual(v2_bridge.resolve_model(None, path=os.path.join(d, "none.json")), ("v2", "default"))


def test_result_cache_separates_flute_counts_and_corner_radius():
    """Regression: the cache key had no flute count, so the first tool's answer was returned for every flute count."""
    import app as A
    from pipeline import CutRequest, run_cut

    def cut(z, cr=0.0):
        r = CutRequest(family="Titanium Alloy", alloy="", operation="Adaptive Roughing", diameter=0.25, flutes=z, flute_length=0.75,
                       shank_diameter=0.25, stickout=1.0, aggressiveness=0.5, max_rpm=16000, max_hp=10, runout=0.0002, model="v2",
                       corner_radius=cr, geometry="Radiused" if cr else "Square", machine_profile=A.active_machine())
        return run_cut(A.physics, r)
    five, two = cut(5), cut(2)
    assert five.model == two.model == "v2"
    assert abs(five.feed_ipm / (five.rpm * five.adj_ipt) - 5) < 1e-6 and abs(two.feed_ipm / (two.rpm * two.adj_ipt) - 2) < 1e-6
    assert (five.v2["cut"]["flutes_cutting"], two.v2["cut"]["flutes_cutting"]) == (5, 2)
    assert cut(5, 0.03).v2["cut"]["end_form"] != five.v2["cut"]["end_form"]
