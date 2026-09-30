import json
import os
import tempfile
import unittest
from unittest.mock import MagicMock

from test_addin_common import load_addin


class AddinTmpBase(unittest.TestCase):
    def setUp(self):
        self.addin = load_addin()
        self._tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self._tmp.cleanup)
        self.addin._toolwiz_dir = lambda: self._tmp.name
        self.addin.app = MagicMock()
        self.addin.ui = MagicMock()


class TestPrefs(AddinTmpBase):
    def test_missing_file_gives_empty(self):
        self.assertEqual(self.addin.load_prefs(), {})

    def test_roundtrip_and_merge(self):
        self.assertTrue(self.addin.save_prefs(family="Titanium Alloy", alloy="Ti-6Al-4V",
                                              aggressiveness=70, strategy="Finishing"))
        self.assertEqual(self.addin.load_prefs(), {"family": "Titanium Alloy", "alloy": "Ti-6Al-4V",
                                                   "aggressiveness": 70, "strategy": "Finishing"})
        # A later save that omits strategy (Stock to Leave) must keep it.
        self.addin.save_prefs(family="Brass", alloy="", aggressiveness=None)
        got = self.addin.load_prefs()
        self.assertEqual(got["family"], "Brass")
        self.assertEqual(got["alloy"], "Ti-6Al-4V")
        self.assertEqual(got["strategy"], "Finishing")
        self.assertEqual(got["aggressiveness"], 70)

    def test_corrupt_file_is_tolerated(self):
        with open(os.path.join(self._tmp.name, "addin_prefs.json"), "w") as f:
            f.write("{not json")
        self.assertEqual(self.addin.load_prefs(), {})
        self.assertTrue(self.addin.save_prefs(family="Brass"))
        self.assertEqual(self.addin.load_prefs(), {"family": "Brass"})

    def test_bad_types_are_dropped_and_aggressiveness_clamped(self):
        with open(os.path.join(self._tmp.name, "addin_prefs.json"), "w") as f:
            json.dump({"family": 5, "alloy": ["x"], "aggressiveness": 400, "strategy": "Facing", "junk": 1}, f)
        self.assertEqual(self.addin.load_prefs(), {"aggressiveness": 100, "strategy": "Facing"})

    def test_non_dict_file(self):
        with open(os.path.join(self._tmp.name, "addin_prefs.json"), "w") as f:
            f.write("[1, 2]")
        self.assertEqual(self.addin.load_prefs(), {})

    def test_save_failure_never_raises(self):
        self.addin._toolwiz_dir = lambda: os.path.join(self._tmp.name, "f.txt", "sub")
        with open(os.path.join(self._tmp.name, "f.txt"), "w") as f:
            f.write("x")
        self.assertFalse(self.addin.save_prefs(family="Brass"))

    def test_pick_saved_falls_back(self):
        self.assertEqual(self.addin.pick_saved("B", ["A", "B"], "A"), "B")
        self.assertEqual(self.addin.pick_saved("Z", ["A", "B"], "A"), "A")
        self.assertEqual(self.addin.pick_saved(None, ["A", "B"], "A"), "A")


PROV = [
    {"step": "base_lookup", "quantity": "sfm", "multiplier": 1.0},
    {"step": "hardness", "quantity": "sfm", "multiplier": 0.72},
    {"step": "hardness", "quantity": "ipt", "multiplier": 0.10},
    {"step": "coating", "quantity": "sfm", "multiplier": 1.40},
    {"step": "chatter", "quantity": "sfm", "multiplier": 1.0},
    {"step": "hem_thermal", "quantity": "sfm", "multiplier": 0.85},
    {"step": "aggressiveness", "quantity": "sfm", "multiplier": 1.04},
    {"step": "spindle_cap", "quantity": "sfm", "multiplier": 0.2},
]


class TestMessages(AddinTmpBase):
    GEO = {"diameter": 0.5, "flutes": 4}

    def test_provenance_top_three_largest_non_unity(self):
        self.assertEqual(self.addin.format_provenance_line(PROV),
                         "SFM: coating \u00d71.40, hardness \u00d70.72, hem-thermal \u00d70.85")

    def test_provenance_empty_or_all_unity(self):
        self.assertEqual(self.addin.format_provenance_line(None), "")
        self.assertEqual(self.addin.format_provenance_line([]), "")
        self.assertEqual(self.addin.format_provenance_line(
            [{"step": "a", "quantity": "sfm", "multiplier": 1.0}, {"step": "b", "quantity": "ipt", "multiplier": 0.5},
             {"step": "c", "quantity": "sfm", "multiplier": "bad"}]), "")

    def test_autoset_message_with_provenance(self):
        msg = self.addin.format_autoset_message(
            "T12", self.GEO, "Nitronic 60", "Wall Finishing", 12500, 48.0, 0.0019,
            doc=0.25, woc=0.02, limited_by="deflection", provenance=PROV)
        lines = msg.split("\n")
        self.assertEqual(lines[0], 'T12 \u00b7 0.500" 4FL \u00b7 Nitronic 60 \u2014 Wall Finishing')
        self.assertEqual(lines[1], "12,500 RPM \u00b7 48.0 IPM \u00b7 0.0019 IPT")
        self.assertEqual(lines[2], 'DOC 0.250" \u00b7 WOC 0.020"')
        self.assertEqual(lines[3], "Limited by: deflection")
        self.assertTrue(lines[4].startswith("SFM: coating"))
        self.assertEqual(len(lines), 5)

    def test_autoset_message_without_provenance_or_limit(self):
        msg = self.addin.format_autoset_message(
            "T3", self.GEO, "Brass", "Roughing", 9000, 30, 0.002, doc=None, woc=0.05, limited_by=None)
        self.assertEqual(msg.split("\n"), [
            'T3 \u00b7 0.500" 4FL \u00b7 Brass \u2014 Roughing',
            "9,000 RPM \u00b7 30.0 IPM \u00b7 0.0020 IPT",
            'WOC 0.050"',
        ])

    def test_limited_by_list(self):
        msg = self.addin.format_autoset_message("T1", self.GEO, "m", "s", 1, 1, 0.001,
                                                limited_by=["deflection", "power"])
        self.assertIn("Limited by: deflection, power", msg)

    def test_stock_summary(self):
        msg = self.addin.format_stock_summary(
            "Titanium Alloy / Ti-6Al-4V",
            [("S1 > Wall", "-0.0012 in", "-0.0004 in")], [("S1 > Floor", ["radial stock"])], "C:\\log")
        self.assertEqual(msg.split("\n"), [
            "Stock to leave set on 1 op \u2014 Titanium Alloy / Ti-6Al-4V",
            " \u2022 S1 > Wall: Rad -0.0012 in \u00b7 Ax -0.0004 in",
            "",
            "Could not write (details in C:\\log):",
            " \u2022 S1 > Floor: radial stock",
        ])
        only_failed = self.addin.format_stock_summary("", [], [("A", ["x"])], "L")
        self.assertTrue(only_failed.startswith("Could not write"))


class TestCalibrationText(AddinTmpBase):
    def test_status_text(self):
        f = self.addin.format_calibration_status
        self.assertEqual(f({"status": "calibrated", "n": 12, "applied_factor": 1.154}), "Calibrated from 12 cuts \u00d71.15")
        self.assertEqual(f({"status": "provisional", "n": 4}), "Provisional (4)")
        self.assertEqual(f({"status": "insufficient", "n": 1}), "Not calibrated \u2014 use Log Cut Result")
        self.assertEqual(f(None), "")

    def test_fetch_failure_is_blank_and_success_is_cached(self):
        a = self.addin
        a._http_json = MagicMock(side_effect=OSError("down"))
        self.assertEqual(a.calibration_text_for("Brass"), "")
        a._http_json = MagicMock(return_value={"success": True, "calibration": [
            {"family": "Brass", "n": 3, "status": "provisional"}]})
        self.assertEqual(a.calibration_text_for("Brass"), "Provisional (3)")
        self.assertEqual(a.calibration_text_for("Brass"), "Provisional (3)")
        self.assertEqual(a._http_json.call_count, 1)
        self.assertIn("family=Brass", a._http_json.call_args[0][0])

    def test_unknown_family_is_not_calibrated(self):
        a = self.addin
        a._http_json = MagicMock(return_value={"success": True, "calibration": []})
        self.assertEqual(a.calibration_text_for("Steel - Tool (H13)"), "Not calibrated \u2014 use Log Cut Result")
        self.assertIn("Steel%20-%20Tool%20%28H13%29", a._http_json.call_args[0][0])


GEO = {"diameter": 0.5, "flutes": 4, "fluteLength": 1.0, "shankDiameter": 0.5, "stickout": 1.5,
       "coating": "AlTiN", "geometry": "Square", "desc": "0.5 endmill", "number": 12}
PRED = {"deflection_in": 0.0008, "springback_in": 0.0004, "total_error_in": 0.0012}


class TestLogCut(AddinTmpBase):
    def build(self, **kw):
        args = dict(family="Titanium Alloy", alloy="Ti-6Al-4V", op_name="Wall Finishing", geo=GEO,
                    cut=(12500, 48.0, 0.25, 0.02), prediction=PRED, measured_error_in=0.0008,
                    spindle_load_pct=62, chatter=False, surface_ok=True, notes=" gritty ")
        args.update(kw)
        return self.addin.build_cutlog_payload(**args)

    def test_payload_fields(self):
        p = self.build()
        self.assertEqual(p["source"], "fusion")
        self.assertEqual((p["family"], p["alloy"], p["operation"]), ("Titanium Alloy", "Ti-6Al-4V", "Wall Finishing"))
        self.assertEqual((p["diameter_in"], p["flutes"], p["stickout_in"]), (0.5, 4, 1.5))
        self.assertEqual((p["rpm"], p["feed_ipm"], p["doc_in"], p["woc_in"]), (12500, 48.0, 0.25, 0.02))
        self.assertEqual(p["predicted_total_error_in"], 0.0012)
        self.assertEqual(p["measured_wall_error_in"], 0.0008)
        self.assertEqual(p["spindle_load_pct"], 62.0)
        self.assertIs(p["chatter"], False)
        self.assertIs(p["surface_ok"], True)
        self.assertEqual(p["notes"], "gritty")
        self.assertEqual(p["tool_number"], 12)

    def test_payload_passes_server_validation(self):
        import cutlog
        clean = cutlog.validate_cut(self.build())
        self.assertEqual(clean["source"], "fusion")
        cutlog.validate_cut(self.build(measured_error_in=None, spindle_load_pct=0, notes="", alloy=""))

    def test_optional_fields_blank(self):
        p = self.build(measured_error_in=None, spindle_load_pct=0, notes="  ", alloy="")
        self.assertIsNone(p["measured_wall_error_in"])
        self.assertIsNone(p["spindle_load_pct"])
        self.assertIsNone(p["notes"])
        self.assertIsNone(p["alloy"])

    def test_missing_cut_params_named(self):
        with self.assertRaises(ValueError) as cm:
            self.build(cut=(0, 48.0, 0.0, 0.02))
        self.assertIn("spindle speed", str(cm.exception))
        self.assertIn("DOC", str(cm.exception))

    def test_bad_prediction(self):
        with self.assertRaises(ValueError):
            self.build(prediction={"deflection_in": 0.1})

    def test_measured_error_parsing(self):
        f = self.addin.parse_measured_error_in
        self.assertAlmostEqual(f("0.0008 in"), 0.0008)
        self.assertAlmostEqual(f("0.0254 mm"), 0.001)
        self.assertAlmostEqual(f("-0.0005"), -0.0005)
        self.assertAlmostEqual(f("0.02", "mm"), 0.02 / 25.4)
        self.assertIsNone(f("   "))
        for bad in ("abc", "0.001 in + 1 mm", "5 in", "1/0"):
            with self.assertRaises(ValueError):
                f(bad)

    def test_single_op_compensation_payload(self):
        p = self.addin.build_single_op_compensation_payload(
            "Brass", "", 60, "Wall", "contour2d", GEO, (9000, 30.0, 0.2, 0.01))
        self.assertEqual(len(p["operations"]), 1)
        op = p["operations"][0]
        self.assertEqual((op["length_unit"], op["feed_unit"]), ("in", "ipm"))
        self.assertEqual((op["rpm"], op["feedrate"], op["doc"], op["woc"]), (9000, 30.0, 0.2, 0.01))
        self.assertEqual(p["aggressiveness"], 60)

    def _wire(self, post):
        a = self.addin
        a.get_cam_document_units = lambda: "in"
        a.get_op_tool_info = lambda op: (dict(GEO), "sum", [])
        a.get_op_cut_params = lambda op, u="in": (12500, 48.0, 0.25, 0.02)
        a._http_json = post
        return MagicMock(strategy="contour2d")

    def test_log_cut_result_end_to_end(self):
        calls = []

        def post(path, payload=None, timeout=5.0, retries=0):
            calls.append((path, payload))
            if path == '/api/stock_compensation':
                return {"success": True, "results": [dict(PRED, id="op_1")]}
            if path == '/api/cutlog':
                return {"success": True, "id": 7}
            return {"success": True, "calibration": [{"family": "Brass", "n": 12, "status": "calibrated",
                                                      "applied_factor": 1.2}]}
        op = self._wire(post)
        msg = self.addin.log_cut_result(op, "Setup1 > Wall Finishing", "Brass", "", "0.0008 in", 55, False, True, "")
        self.assertEqual([c[0].split("?")[0] for c in calls],
                         ['/api/stock_compensation', '/api/cutlog', '/api/calibration'])
        self.assertEqual(calls[1][1]["source"], "fusion")
        self.assertEqual(calls[1][1]["operation"], "Wall Finishing")
        self.assertIn("Logged: T12", msg)
        self.assertIn("+0.0008", msg)
        self.assertIn("Brass: Calibrated from 12 cuts \u00d71.20", msg)

    def test_server_down_is_clear_error(self):
        import urllib.error
        op = self._wire(MagicMock(side_effect=urllib.error.URLError("refused")))
        with self.assertRaises(self.addin.LogCutError) as cm:
            self.addin.log_cut_result(op, "S > Op", "Brass", "", "", 0, False, True, "")
        self.assertIn("addin.log", str(cm.exception))

    def test_server_rejection_message(self):
        def post(path, payload=None, timeout=5.0, retries=0):
            if path == '/api/stock_compensation':
                return {"success": True, "results": [dict(PRED)]}
            return {"success": False, "error": "flutes must be between 1 and 100"}
        op = self._wire(post)
        with self.assertRaises(self.addin.LogCutError) as cm:
            self.addin.log_cut_result(op, "S > Op", "Brass", "", "", 0, False, True, "")
        self.assertIn("flutes must be", str(cm.exception))

    def test_bad_measurement_stops_before_any_request(self):
        post = MagicMock()
        op = self._wire(post)
        with self.assertRaises(self.addin.LogCutError):
            self.addin.log_cut_result(op, "S > Op", "Brass", "", "oops", 0, False, True, "")
        post.assert_not_called()


class TestCommandSpecs(AddinTmpBase):
    def test_log_cut_command_registered(self):
        a = self.addin
        self.assertEqual(a.logCutCommandId, 'ToolWizLogCutCmd')
        spec = [s for s in a.COMMAND_SPECS if s[0] == 'ToolWizLogCutCmd']
        self.assertEqual(len(spec), 1)
        self.assertEqual(spec[0][1], 'Log Cut Result')
        self.assertTrue(hasattr(a, spec[0][3]))
        ids = [s[0] for s in a.COMMAND_SPECS]
        self.assertEqual(len(ids), len(set(ids)))


class TestDialogOrder(AddinTmpBase):
    def test_material_inputs_sit_under_tool_info_and_use_saved_choice(self):
        a = self.addin
        op = MagicMock()
        op.name = "Op"
        setup = MagicMock()
        setup.name = "S"
        setup.allOperations = [op]
        cam = MagicMock()
        cam.setups = [setup]
        a.adsk.cam.CAM.cast.return_value = cam
        a.ui.activeSelections.count = 0
        a._materials.update(families=["Brass", "Titanium Alloy"],
                            alloys={"Titanium Alloy": ["Ti-6Al-4V", "Ti-5553"]}, status="cache")
        a.load_materials = lambda: None
        a.get_op_tool_info = lambda o: ({"is_carbide": True, "coating": "AlTiN"}, "sum", [])
        a.save_prefs(family="Titanium Alloy", alloy="Ti-5553", aggressiveness=80)
        args = MagicMock()
        a.ToolWizCreatedHandler().notify(args)
        ins = args.command.commandInputs
        ids = [c[1][0] for c in ins.mock_calls if c[0].startswith("add") and not c[0].endswith("listItems.add")
               and "listItems" not in c[0]]
        self.assertEqual(ids[:6], ["targetOp", "toolInfo", "matFamily", "matAlloy", "presetAction", "toolGrade"])
        self.assertLess(ids.index("matAlloy"), ids.index("toolCoating"))
        fam_adds = [c[1] for c in ins.mock_calls if c[0] == "addDropDownCommandInput().listItems.add"
                    and c[1][0] in ("Brass", "Titanium Alloy")]
        self.assertIn(("Titanium Alloy", True), fam_adds)
        alloy_adds = [c[1] for c in ins.mock_calls if c[0] == "addDropDownCommandInput().listItems.add"
                      and c[1][0] in ("Ti-6Al-4V", "Ti-5553")]
        self.assertIn(("Ti-5553", True), alloy_adds)
        self.assertEqual(ins.addIntegerSliderCommandInput.return_value.valueOne, 80)


if __name__ == "__main__":
    unittest.main()
