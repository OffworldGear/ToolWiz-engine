import copy
import hashlib
import json
import os
import sys
import tempfile
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, ROOT)

import app as app_module
from app import app
from backup_manager import BackupManager
from tool_merger import deduplicate_tools, merge_multiple_libraries
from toolwiz_common import (
    ToolKind, classify, is_hole_kind, is_milling_kind, is_tap_kind,
    ToolGeometry, UnitError, to_inches, tool_unit, safe_eval_length,
)

FIX_DIR = os.path.join(os.path.dirname(__file__), "fixtures")
WORKING_LIB = os.path.join(ROOT, "data", "working_library.json")


def _sha(path):
    if not os.path.exists(path):
        return None
    with open(path, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()


def fixture(name):
    with open(os.path.join(FIX_DIR, name), "r", encoding="utf-8") as f:
        return json.load(f)


def all_fixture_names():
    return sorted(n for n in os.listdir(FIX_DIR) if n.endswith(".json"))


_HASH_BEFORE = _sha(WORKING_LIB)


def tearDownModule():
    # The real data/working_library.json must never be touched by the tests.
    assert _sha(WORKING_LIB) == _HASH_BEFORE, "data/working_library.json was modified by tests"


class TestToolKinds(unittest.TestCase):
    def test_exact_classification(self):
        self.assertIs(classify("flat end mill"), ToolKind.FLAT)
        self.assertIs(classify("Tapered Mill"), ToolKind.TAPERED)
        self.assertIs(classify("tap left hand"), ToolKind.TAP)
        self.assertIs(classify("tap right hand"), ToolKind.TAP)
        self.assertIs(classify("holder"), ToolKind.HOLDER)
        self.assertIs(classify("probe"), ToolKind.PROBE)
        self.assertIs(classify("mystery cutter"), ToolKind.UNKNOWN)
        self.assertIs(classify(None), ToolKind.UNKNOWN)

    def test_tapered_is_not_tap_or_hole(self):
        k = classify("tapered mill")
        self.assertTrue(is_milling_kind(k))
        self.assertFalse(is_tap_kind(k))
        self.assertFalse(is_hole_kind(k))

    def test_unknown_never_milling(self):
        for k in (ToolKind.UNKNOWN, ToolKind.HOLDER, ToolKind.PROBE):
            self.assertFalse(is_milling_kind(k))
        self.assertTrue(is_hole_kind(ToolKind.TAP))


class TestUnitsAndExpr(unittest.TestCase):
    def test_to_inches(self):
        self.assertAlmostEqual(to_inches(25.4, "millimeters"), 1.0)
        self.assertAlmostEqual(to_inches("6.35 mm", "inches"), 0.25)
        self.assertAlmostEqual(to_inches("0.25 in"), 0.25)
        self.assertAlmostEqual(to_inches('0.25"'), 0.25)
        self.assertAlmostEqual(to_inches("1/4", "in"), 0.25)

    def test_to_inches_unknown_unit_raises(self):
        with self.assertRaises(UnitError):
            to_inches(6.35, "furlongs")
        with self.assertRaises(UnitError):
            to_inches(6.35, "")
        with self.assertRaises(UnitError):
            to_inches(6.35)

    def test_tool_unit(self):
        self.assertEqual(tool_unit({"unit": "millimeters"}), "millimeters")
        self.assertEqual(tool_unit({"geometry": {"unit": "in"}}), "inches")
        with self.assertRaises(UnitError):
            tool_unit({"geometry": {}})

    def test_safe_eval_length(self):
        self.assertAlmostEqual(safe_eval_length("(-.1) * 1mm"), -0.1)
        self.assertAlmostEqual(safe_eval_length("2 * (3 + 4) - 1"), 13.0)
        with self.assertRaises(ValueError):
            safe_eval_length("9**9")
        with self.assertRaises(ValueError):
            safe_eval_length("__import__('os')")
        with self.assertRaises(ValueError):
            safe_eval_length("1+" * 150 + "1")


class TestGeometry(unittest.TestCase):
    def test_inch_lb_source(self):
        g = ToolGeometry.from_fusion(fixture("flat_inch_sfdm_lb.json"))
        self.assertEqual(g.stickout_source, "fusion_LB")
        self.assertAlmostEqual(g.stickout, 1.25)

    def test_override_wins(self):
        g = ToolGeometry.from_fusion(fixture("flat_inch_sfdm_lb.json"), stickout_override=2.0)
        self.assertEqual(g.stickout_source, "override")
        self.assertAlmostEqual(g.stickout, 2.0)

    def test_nonpositive_falls_through(self):
        t = fixture("flat_inch_sfdm_lb.json")
        t["geometry"]["LB"] = 0
        t["geometry"]["assemblyGaugeLength"] = 4.0
        g = ToolGeometry.from_fusion(t, stickout_override=0)
        self.assertEqual(g.stickout_source, "fusion_gauge")
        t["geometry"]["assemblyGaugeLength"] = -1
        g = ToolGeometry.from_fusion(t, stickout_override=-3)
        self.assertEqual(g.stickout_source, "default")
        self.assertAlmostEqual(g.stickout, 3.15 * 0.5)

    def test_metric_default_stickout(self):
        g = ToolGeometry.from_fusion(fixture("flat_metric_10mm_no_lb.json"))
        self.assertEqual(g.stickout_source, "default")
        self.assertAlmostEqual(g.stickout, 3.15 * (10.0 / 25.4), places=6)

    def test_metric_and_inch_equivalent_stickout(self):
        metric = fixture("flat_metric_10mm_no_lb.json")
        inch = _metric_to_inch(metric)
        gm = ToolGeometry.from_fusion(metric)
        gi = ToolGeometry.from_fusion(inch)
        self.assertAlmostEqual(gm.diameter, 0.3937, places=3)
        self.assertAlmostEqual(gm.stickout, gi.stickout, places=6)
        self.assertAlmostEqual(gi.stickout / gi.diameter, 3.15, places=6)

    def test_tap_pitch(self):
        self.assertAlmostEqual(ToolGeometry.from_fusion(fixture("tap_rh_with_tp.json")).thread_pitch, 0.05)
        self.assertIsNone(ToolGeometry.from_fusion(fixture("tap_rh_no_tp.json")).thread_pitch)

    def test_stickout_positive_for_every_fixture(self):
        checked = 0
        for name in all_fixture_names():
            t = fixture(name)
            if classify(t["type"]) is ToolKind.HOLDER:
                continue  # holders have no cutter diameter
            g = ToolGeometry.from_fusion(t)
            self.assertGreater(g.stickout, 0, name)
            checked += 1
        self.assertGreaterEqual(checked, 5)


def _metric_to_inch(tool):
    t = copy.deepcopy(tool)
    t["unit"] = "inches"
    for k, v in list(t["geometry"].items()):
        if k in ("DC", "LCF", "SFDM", "RE", "OAL", "LB", "TP", "assemblyGaugeLength"):
            t["geometry"][k] = v / 25.4
    return t


class SandboxedAppCase(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.orig_bm = app_module.bm
        self.bm = BackupManager(base_dir=self.temp_dir.name)
        app_module.bm = self.bm
        self.client = app.test_client()

    def tearDown(self):
        app_module.bm = self.orig_bm
        self.temp_dir.cleanup()

    def seed(self, tools, name="Hardening_Test"):
        self.bm.save_working_library({"library_name": name, "tools": tools}, name)

    def batch(self, **extra):
        payload = {
            "tool_indices": "all",
            "family": "Aluminum - Wrought (6061)",
            "alloy": "",
            "aggressiveness": 50,
        }
        payload.update(extra)
        resp = self.client.post("/api/twin/batch_generate", json=payload)
        self.assertEqual(resp.status_code, 200, resp.get_data(as_text=True))
        data = resp.get_json()
        self.assertTrue(data["success"], data)
        return data


class TestBatchGenerate(SandboxedAppCase):
    def test_tapered_mill_gets_milling_presets(self):
        self.seed([fixture("tapered_mill.json")])
        data = self.batch()
        self.assertEqual(data["skipped"], [])
        tool = self.bm.load_working_library()["tools"][0]
        presets = tool["start-values"]["presets"]
        self.assertGreaterEqual(len(presets), 1)
        for p in presets:
            self.assertNotIn("Drilling", p["name"])
            self.assertNotIn("Tapping", p["name"])
            self.assertTrue(0.0005 < p["f_z"] < 0.02, p["f_z"])
            self.assertGreater(p["v_f"], 0)
            self.assertIn("stepdown", p)

    def test_tap_without_tp_skipped_and_not_modified(self):
        self.seed([fixture("tap_rh_no_tp.json"), fixture("tap_rh_with_tp.json")])
        data = self.batch()
        self.assertEqual(len(data["skipped"]), 1)
        sk = data["skipped"][0]
        self.assertEqual(sk["tool_index"], 0)
        self.assertEqual(sk["number"], 5)
        self.assertIn("thread pitch", sk["reason"])
        tools = self.bm.load_working_library()["tools"]
        self.assertEqual(tools[0]["start-values"]["presets"], [])
        tap_presets = tools[1]["start-values"]["presets"]
        self.assertEqual(len(tap_presets), 1)
        self.assertIn("Tapping", tap_presets[0]["name"])
        # feed = rpm * pitch
        self.assertAlmostEqual(tap_presets[0]["v_f"], tap_presets[0]["n"] * 0.05, delta=tap_presets[0]["v_f"] * 0.01)

    def test_holder_and_probe_skipped_holder_preserved(self):
        self.seed([fixture("holder.json"), fixture("probe.json"), fixture("flat_inch_sfdm_lb.json")])
        data = self.batch()
        reasons = {s["tool_index"]: s for s in data["skipped"]}
        self.assertEqual(set(reasons), {0, 1})
        for s in reasons.values():
            self.assertIn("reason", s)
            self.assertIn("description", s)
        lib_tools = self.bm.load_working_library()["tools"]
        self.assertEqual(len(lib_tools), 3)
        self.assertEqual(lib_tools[0]["type"], "holder")
        self.assertEqual(lib_tools[0]["start-values"]["presets"], [])
        self.assertGreater(len(lib_tools[2]["start-values"]["presets"]), 0)

    def test_unknown_type_skipped(self):
        t = fixture("flat_inch_sfdm_lb.json")
        t["type"] = "space laser"
        self.seed([t])
        data = self.batch()
        self.assertEqual(len(data["skipped"]), 1)
        self.assertEqual(self.bm.load_working_library()["tools"][0]["start-values"]["presets"], [])

    def test_missing_unit_skipped(self):
        t = fixture("flat_inch_sfdm_lb.json")
        del t["unit"]
        self.seed([t])
        data = self.batch()
        self.assertEqual(len(data["skipped"]), 1)
        self.assertIn("unit", data["skipped"][0]["reason"])

    def test_metric_and_inch_equivalent_presets(self):
        metric = fixture("flat_metric_10mm_no_lb.json")
        inch = _metric_to_inch(metric)
        self.seed([metric, inch])
        self.batch()
        tools = self.bm.load_working_library()["tools"]
        pm = {p["name"]: p for p in tools[0]["start-values"]["presets"]}
        pi = {p["name"]: p for p in tools[1]["start-values"]["presets"]}
        self.assertEqual(set(pm), set(pi))
        self.assertGreater(len(pm), 0)

        def close(a, b):
            self.assertAlmostEqual(a, b, delta=abs(b) * 0.01 + 1e-9)

        for name in pm:
            m, i = pm[name], pi[name]
            close(m["n"], i["n"])
            close(m["v_c"] / 0.3048, i["v_c"])
            close(m["f_z"] / 25.4, i["f_z"])
            close(m["v_f"] / 25.4, i["v_f"])
            close(m["stepdown"] / 25.4, i["stepdown"])
            close(m["stepover"] / 25.4, i["stepover"])

    def test_stickout_override_respected_in_twin_load(self):
        t = fixture("flat_inch_sfdm_lb.json")
        self.seed([t, fixture("flat_metric_10mm_no_lb.json")])
        resp = self.client.get("/api/twin/load")
        self.assertEqual(resp.status_code, 200)
        tools = resp.get_json()["tools"]
        self.assertEqual(tools[0]["stickout_source"], "fusion_LB")
        self.assertEqual(tools[1]["stickout_source"], "default")
        self.assertAlmostEqual(tools[1]["stickout_in"], 3.15 * 10 / 25.4, places=3)
        lib = self.bm.load_working_library()
        lib["tools"][0]["stickout"] = 2.5
        self.bm.save_working_library(lib, "Hardening_Test")
        tools = self.client.get("/api/twin/load").get_json()["tools"]
        self.assertEqual(tools[0]["stickout_source"], "override")
        self.assertAlmostEqual(tools[0]["stickout_in"], 2.5)

    def test_twin_load_survives_holder(self):
        self.seed([fixture("holder.json"), fixture("flat_inch_sfdm_lb.json")])
        data = self.client.get("/api/twin/load").get_json()
        self.assertTrue(data["success"])
        self.assertEqual(data["tool_count"], 2)
        self.assertIsNotNone(data["tools"][0]["geometry_error"])


class TestMergerDefaults(SandboxedAppCase):
    def test_holder_preserved_on_dedupe(self):
        tools = [fixture("holder.json"), fixture("flat_inch_sfdm_lb.json"), fixture("flat_inch_sfdm_lb.json")]
        out, report = deduplicate_tools(tools)
        self.assertEqual(sum(1 for t in out if t.get("type") == "holder"), 1)

    def test_merge_default_no_dedupe(self):
        libs = [{"library_name": "A", "tools": [fixture("flat_inch_sfdm_lb.json")]},
                {"library_name": "B", "tools": [fixture("flat_inch_sfdm_lb.json")]}]
        _, summary = merge_multiple_libraries(libs)
        self.assertEqual(summary["final_tool_count"], 2)
        _, summary = merge_multiple_libraries(libs, deduplicate=True)
        self.assertEqual(summary["final_tool_count"], 1)

    def test_export_receive_default_no_dedupe(self):
        tools = [fixture("flat_inch_sfdm_lb.json"), fixture("flat_inch_sfdm_lb.json")]
        resp = self.client.post("/api/twin/export_receive", json={"library_name": "X", "tools": tools})
        self.assertEqual(resp.get_json()["tool_count"], 2)
        resp = self.client.post("/api/twin/export_receive", json={"library_name": "X", "tools": tools, "deduplicate": True})
        self.assertEqual(resp.get_json()["tool_count"], 1)

    def test_unit_missing_never_merged(self):
        a = fixture("flat_inch_sfdm_lb.json")
        b = copy.deepcopy(a)
        del a["unit"]
        del b["unit"]
        out, _ = deduplicate_tools([a, b])
        self.assertEqual(len(out), 2)


class TestStockCompensation(SandboxedAppCase):
    def _op(self, feed, **kw):
        op = {
            "id": "op1", "name": "Adaptive Clearing", "strategy": "adaptive", "unit": "in",
            "diameter": 0.5, "flutes": 4, "fluteLength": 1.0, "shankDiameter": 0.5,
            "rpm": 10000, "feedrate": feed, "doc": 0.5, "woc": 0.1,
            "current_radial_stock": "0.02 in", "current_axial_stock": "0.01 in",
        }
        op.update(kw)
        return op

    def _post(self, op):
        resp = self.client.post("/api/stock_compensation", json={
            "family": "Aluminum - Wrought (6061)", "alloy": "", "mode": "auto_compensate", "operations": [op]})
        self.assertEqual(resp.status_code, 200, resp.get_data(as_text=True))
        data = resp.get_json()
        self.assertTrue(data["success"], data)
        return data["results"][0]

    def test_deflection_monotonic_in_feed(self):
        low = self._post(self._op(140.0))
        high = self._post(self._op(300.0))
        self.assertGreater(high["deflection_in"], low["deflection_in"])

    def test_no_magnitude_heuristic_metric_label(self):
        # 'unit': 'mm' only affects stock-string formatting; numbers stay inches/IPM unless units are explicit.
        a = self._post(self._op(300.0, unit="mm"))
        b = self._post(self._op(300.0, unit="in"))
        self.assertEqual(a["deflection_in"], b["deflection_in"])

    def test_explicit_units_equivalent(self):
        a = self._post(self._op(200.0))
        mm = self._post(self._op(
            200.0 * 25.4, length_unit="mm", feed_unit="mm_min", diameter=12.7, fluteLength=25.4,
            shankDiameter=12.7, doc=12.7, woc=2.54))
        self.assertAlmostEqual(a["deflection_in"], mm["deflection_in"], places=5)

    def test_invalid_units_rejected(self):
        resp = self.client.post("/api/stock_compensation", json={"operations": [self._op(100.0, feed_unit="furlongs")]})
        self.assertEqual(resp.status_code, 400)

    def test_default_stickout_rule(self):
        a = self._post(self._op(200.0))
        b = self._post(self._op(200.0, stickout=3.15 * 0.5))
        self.assertEqual(a["deflection_in"], b["deflection_in"])

    def test_expression_rejects_power(self):
        from app import clean_and_eval_stock_expr
        self.assertEqual(clean_and_eval_stock_expr("9**9", "in"), "9**9")


class TestTapCoating(SandboxedAppCase):
    def _calc(self, route, coating):
        payload = {
            "family": "Steel - Low Carbon (1020)", "alloy": "1018", "tool": "Tapping", "geometry": "form",
            "operation": "Rigid Tapping", "diameter": 0.25, "flutes": 4, "coating": coating,
            "stickout": 1.25, "aggressiveness": 50, "isCarbide": False,
        }
        resp = self.client.post(route, json=payload)
        data = resp.get_json()
        self.assertTrue(data.get("success"), data)
        return data

    def test_tap_ignores_coating(self):
        for route in ("/api/calculate", "/api/calculate_for_fusion"):
            plain = self._calc(route, "Uncoated")
            tin = self._calc(route, "TiN")
            altin = self._calc(route, "AlTiN")
            self.assertEqual(plain["rpm"], tin["rpm"], route)
            self.assertEqual(plain["rpm"], altin["rpm"], route)

    def test_milling_still_uses_coating(self):
        payload = {"family": "Steel - Low Carbon (1020)", "alloy": "1018", "tool": "Carbide Endmill",
                   "geometry": "Square", "operation": "Roughing", "diameter": 0.5, "flutes": 4,
                   "stickout": 1.5, "aggressiveness": 50}
        a = self.client.post("/api/calculate", json=dict(payload, coating="Uncoated")).get_json()
        b = self.client.post("/api/calculate", json=dict(payload, coating="AlTiN")).get_json()
        self.assertNotEqual(a["rpm"], b["rpm"])


if __name__ == "__main__":
    unittest.main()
