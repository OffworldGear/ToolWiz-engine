import json
import os
import re
import tempfile
import unittest
import urllib.error
from unittest.mock import MagicMock, patch

from test_addin_common import load_addin, ADDIN_PATH


class FakeResponse:
    def __init__(self, payload):
        self._raw = json.dumps(payload).encode("utf-8")

    def read(self):
        return self._raw

    def close(self):
        pass


class ServerTestBase(unittest.TestCase):
    def setUp(self):
        self.addin = load_addin()
        self._tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self._tmp.cleanup)
        self.addin._toolwiz_dir = lambda: self._tmp.name
        self.addin.app = MagicMock()
        self.addin.ui = MagicMock()
        patcher = patch.object(self.addin.time, "sleep", lambda s: None)
        patcher.start()
        self.addCleanup(patcher.stop)


DATA = {
    "families": ["Aluminum - Wrought (6061)", "Titanium Alloy", "Brass"],
    "alloys": [
        {"family": "Titanium Alloy", "alloy": "Ti-6Al-4V", "condition": "Annealed"},
        {"family": "Titanium Alloy", "alloy": "Ti-6Al-4V", "condition": "Annealed"},
        {"family": "Titanium Alloy", "alloy": "Grade 2", "condition": ""},
        {"family": "Brass", "alloy": "C360", "condition": "Half Hard"},
    ],
}


class TestHttp(ServerTestBase):
    def test_header_sent_on_get_and_post(self):
        seen = []

        def fake_urlopen(req, timeout=None):
            seen.append((req, timeout))
            return FakeResponse({"ok": True})

        with patch.object(self.addin.urllib.request, "urlopen", fake_urlopen):
            self.addin._http_json("/api/data", timeout=10.0)
            self.addin._http_json("/api/calculate_for_fusion", {"a": 1}, timeout=5.0)
        self.assertEqual(len(seen), 2)
        for req, _ in seen:
            self.assertEqual(req.get_header("X-toolwiz-client"), "fusion-addin")
        self.assertEqual(seen[0][0].get_method(), "GET")
        self.assertEqual(seen[1][0].get_method(), "POST")
        self.assertTrue(seen[1][0].full_url.startswith(self.addin.SERVER_BASE_URL))

    def test_single_base_url_constant(self):
        with open(ADDIN_PATH, encoding="utf-8") as f:
            src = f.read()
        self.assertEqual(len(re.findall(r"127\.0\.0\.1", src)), 1)
        self.assertEqual(src.count("urlopen("), 1)  # only _http_json talks to the server

    def test_retry_then_raise(self):
        calls = []

        def boom(req, timeout=None):
            calls.append(timeout)
            raise urllib.error.URLError("refused")

        with patch.object(self.addin.urllib.request, "urlopen", boom):
            with self.assertRaises(urllib.error.URLError):
                self.addin._http_json("/api/data", timeout=10.0, retries=1)
        self.assertEqual(calls, [10.0, 10.0])

    def test_http_error_with_json_body_is_returned(self):
        def deny(req, timeout=None):
            raise urllib.error.HTTPError(req.full_url, 403, "Forbidden", {}, FakeResponse({"success": False, "error": "nope"}))

        with patch.object(self.addin.urllib.request, "urlopen", deny):
            res = self.addin._http_json("/api/x", {"a": 1})
        self.assertEqual(res["error"], "nope")


class TestLog(ServerTestBase):
    def test_log_writes_and_rotates(self):
        self.addin._log("hello")
        path = os.path.join(self._tmp.name, "addin.log")
        with open(path, encoding="utf-8") as f:
            self.assertIn("hello", f.read())
        try:
            raise RuntimeError("kaboom")
        except RuntimeError as e:
            self.addin._log("failed", e)
        with open(path, encoding="utf-8") as f:
            self.assertIn("kaboom", f.read())
        self.addin._LOG_MAX_BYTES = 10
        self.addin._log("after rotation")
        self.assertTrue(os.path.exists(path + ".1"))
        with open(path, encoding="utf-8") as f:
            self.assertIn("after rotation", f.read())

    def test_log_never_raises(self):
        self.addin._toolwiz_dir = lambda: os.path.join(self._tmp.name, "a\0b")
        self.addin._log("x", RuntimeError("y"))


class TestMaterials(ServerTestBase):
    def cache_path(self):
        return os.path.join(self._tmp.name, "materials_cache.json")

    def test_no_hardcoded_lists(self):
        self.assertFalse(hasattr(self.addin, "families_list"))
        self.assertFalse(hasattr(self.addin, "alloys_dict"))

    def test_online_load_builds_labels_and_caches(self):
        with patch.object(self.addin, "_http_json", return_value=DATA) as m:
            mats = self.addin.load_materials()
        m.assert_called_once_with("/api/data", timeout=10.0, retries=1)
        self.assertEqual(mats["status"], "online")
        self.assertIsNone(mats["notice"])
        self.assertEqual(mats["families"], DATA["families"])
        self.assertEqual(self.addin.alloys_for("Titanium Alloy"), ["Ti-6Al-4V (Annealed)", "Grade 2"])
        self.assertEqual(self.addin.alloys_for("Brass"), ["C360 (Half Hard)"])
        self.assertTrue(self.addin.materials_ready())
        with open(self.cache_path(), encoding="utf-8") as f:
            cached = json.load(f)
        self.assertEqual(cached["families"], DATA["families"])
        self.assertIn("saved_at", cached)

    def test_offline_uses_cache_with_notice(self):
        with patch.object(self.addin, "_http_json", return_value=DATA):
            self.addin.load_materials()
        with patch.object(self.addin, "_http_json", side_effect=urllib.error.URLError("down")):
            mats = self.addin.load_materials()
        self.assertEqual(mats["status"], "cache")
        self.assertTrue(mats["notice"].startswith("Server offline"))
        self.assertIn("using material list cached", mats["notice"])
        self.assertIn(mats["cached_at"][:4], mats["notice"])
        self.assertEqual(mats["families"], DATA["families"])
        self.assertEqual(self.addin.alloys_for("Brass"), ["C360 (Half Hard)"])
        self.assertTrue(self.addin.materials_ready())

    def test_offline_without_cache_blocks_calculation(self):
        with patch.object(self.addin, "_http_json", side_effect=OSError("down")):
            mats = self.addin.load_materials()
        self.assertEqual(mats["status"], "none")
        self.assertEqual(mats["families"], [])
        self.assertIn("Calculation is disabled", mats["notice"])
        self.assertFalse(self.addin.materials_ready())

    def test_empty_server_response_falls_back(self):
        with patch.object(self.addin, "_http_json", return_value={"families": [], "alloys": []}):
            mats = self.addin.load_materials()
        self.assertEqual(mats["status"], "none")
        self.assertFalse(os.path.exists(self.cache_path()))

    def test_corrupt_cache_is_treated_as_missing(self):
        with open(self.cache_path(), "w", encoding="utf-8") as f:
            f.write("{not json")
        with patch.object(self.addin, "_http_json", side_effect=OSError("down")):
            mats = self.addin.load_materials()
        self.assertEqual(mats["status"], "none")

    def test_both_commands_share_the_single_loader(self):
        with open(ADDIN_PATH, encoding="utf-8") as f:
            src = f.read()
        self.assertEqual(src.count("'/api/data'"), 1)
        self.assertGreaterEqual(src.count("load_materials()"), 3)  # def + S&F + Stock

    def test_execute_handlers_refuse_when_no_materials(self):
        with patch.object(self.addin, "_http_json", side_effect=OSError("down")):
            self.addin.load_materials()
        with patch.object(self.addin, "run_autoset") as run:
            self.addin.ToolWizExecuteHandler().notify(MagicMock())
        run.assert_not_called()
        self.assertTrue(self.addin.ui.messageBox.called)
        self.addin.ui.messageBox.reset_mock()
        self.addin.ToolWizStockExecuteHandler().notify(MagicMock())
        self.assertTrue(self.addin.ui.messageBox.called)


class TestFeasibility(ServerTestBase):
    def _yes(self):
        return self.addin.adsk.core.DialogResults.DialogYes

    def test_feasible_true_and_missing_do_not_prompt(self):
        self.assertTrue(self.addin.confirm_feasibility({"success": True, "feasible": True}))
        self.assertTrue(self.addin.confirm_feasibility({"success": True}))
        self.assertTrue(self.addin.confirm_feasibility({"success": True, "feasible": None}))
        self.addin.ui.messageBox.assert_not_called()

    def test_infeasible_yes_applies(self):
        self.addin.ui.messageBox.return_value = self._yes()
        ok = self.addin.confirm_feasibility({"feasible": False, "limited_by": "tool deflection"})
        self.assertTrue(ok)
        text = self.addin.ui.messageBox.call_args[0][0]
        self.assertIn("No safe cut found", text)
        self.assertIn("limited by tool deflection", text)
        self.assertIn("Apply anyway?", text)
        self.assertIn(self.addin.adsk.core.MessageBoxButtonTypes.YesNoButtonType, self.addin.ui.messageBox.call_args[0])

    def test_infeasible_no_declines(self):
        self.addin.ui.messageBox.return_value = self.addin.adsk.core.DialogResults.DialogNo
        self.assertFalse(self.addin.confirm_feasibility({"feasible": False, "limited_by": "spindle power"}))


class TestAutoSet(ServerTestBase):
    GEO = {"diameter": 0.5, "flutes": 4, "fluteLength": 1.0, "shankDiameter": 0.5, "cornerRadius": 0.0,
           "stickout": 1.6, "geometry": "Square", "desc": "1/2 flat", "number": 5, "raw_json": "{}"}
    CALC = {"success": True, "rpm": 10000, "feed": 50.0, "doc": 0.1, "woc": 0.05, "sfm": 300, "ipt": 0.002}

    def _run(self, geo, calc, yes=True):
        addin = self.addin
        addin.ui.messageBox.return_value = addin.adsk.core.DialogResults.DialogYes if yes else addin.adsk.core.DialogResults.DialogNo
        with patch.object(addin, "get_op_tool_info", return_value=(geo, "summary", [])), \
             patch.object(addin, "_http_json", return_value=calc) as http, \
             patch.object(addin.json_mutator, "mutate_tool_json", return_value=("{}", "P", False)) as mut:
            result = addin.run_autoset(MagicMock(), "Setup > Op", "Titanium Alloy", "Grade 2", "Finishing", 50,
                                       None, "HP High Performance Carbide", "AlTiN (Black)")
        return result, http, mut

    def test_unknown_tool_number_aborts_before_any_request(self):
        geo = dict(self.GEO, number=None)
        result, http, mut = self._run(geo, self.CALC)
        self.assertFalse(result)
        http.assert_not_called()
        mut.assert_not_called()
        self.assertIn("no tool number", self.addin.ui.messageBox.call_args[0][0])

    def test_feasible_applies(self):
        result, http, mut = self._run(self.GEO, self.CALC)
        self.assertTrue(result)
        mut.assert_called_once()
        self.assertEqual(http.call_args[0][0], "/api/calculate_for_fusion")
        sent = http.call_args[0][1]
        self.assertEqual(sent["stickout"], 1.6)
        self.assertNotIn("tool_number", mut.call_args[0][1])

    def test_infeasible_declined_does_not_apply(self):
        calc = dict(self.CALC, feasible=False, limited_by="deflection")
        result, http, mut = self._run(self.GEO, calc, yes=False)
        self.assertFalse(result)
        mut.assert_not_called()

    def test_infeasible_accepted_applies(self):
        calc = dict(self.CALC, feasible=False, limited_by="deflection")
        result, http, mut = self._run(self.GEO, calc, yes=True)
        self.assertTrue(result)
        mut.assert_called_once()

    def test_unreadable_geometry_aborts(self):
        result, http, mut = self._run(None, self.CALC)
        self.assertFalse(result)
        http.assert_not_called()


if __name__ == "__main__":
    unittest.main()
