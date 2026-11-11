"""2D Contour with multiple stepovers in the add-in: detection from the op parameters, effective cut width, measured widths in the
snapshot, and the Auto-Setter note (Fusion mocked)."""
import unittest
from types import SimpleNamespace
from unittest.mock import MagicMock, patch

from test_addin_common import load_addin, param, ParamsByName


class ListParams(ParamsByName):
    """op.parameters that is also iterable (for the diagnostic dump)."""
    def __iter__(self):
        for n, p in self.mapping.items():
            p.name = n
            yield p


def op_with(params, strategy="contour2d"):
    return SimpleNamespace(name="Slot", strategy=strategy, parent=SimpleNamespace(name="Setup1", allOperations=[]),
                           parameters=ListParams(params), hasToolpath=False)


class TestReadMultiStepover(unittest.TestCase):
    def setUp(self):
        self.a = load_addin()

    def test_enabled_with_count_and_stepover(self):
        op = op_with({"doMultiplePasses": param("true", 1), "maximumRoughingSteps": param("4", 4),
                      "maximumStepover": param("0.06 in", 0.06 * 2.54)})
        ms = self.a.read_multi_stepover(op)
        self.assertTrue(ms["enabled"])
        self.assertEqual(ms["count"], 4)
        self.assertAlmostEqual(ms["stepover_in"], 0.06, places=4)
        self.assertEqual(ms["params"], {"flag": "doMultiplePasses", "count": "maximumRoughingSteps", "stepover": "maximumStepover"})

    def test_off_and_missing(self):
        op = op_with({"doMultiplePasses": param("false", 0), "maximumStepover": param("0.06 in", 0.06 * 2.54)})
        self.assertFalse(self.a.read_multi_stepover(op)["enabled"])
        self.assertIsNone(self.a.read_multi_stepover(op_with({"maximumStepdown": param("0.1 in")})))
        self.assertIsNone(self.a.read_multi_stepover(SimpleNamespace(parameters=None)))

    def test_op_geometry_has_effective_width_and_sources(self):
        op = op_with({"doMultiplePasses": param("true", 1), "maximumRoughingSteps": param("4", 4),
                      "maximumStepover": param("0.06 in", 0.06 * 2.54), "topHeight_value": param("0 in", 0.0),
                      "bottomHeight_value": param("-0.5 in", -0.5 * 2.54)})
        g = self.a.op_geometry(op, {"diameter": 0.25, "fluteLength": 0.75}, "flat", "in")
        self.assertAlmostEqual(g["effective_cut_width_in"], 0.25 + 3 * 0.06, places=4)
        self.assertEqual(g["sources"]["effective_cut_width_in"], "measured")
        self.assertTrue(g["multi_stepover"]["enabled"])
        self.assertIn("doMultiplePasses", g["stepover_params_seen"])
        self.assertAlmostEqual(g["depth_in"], 0.5, places=4)

    def test_op_geometry_adds_measured_widths_and_negative_stock_radial_depth(self):
        meas = {"channel_width_in": 0.4, "pocket_area_in2": 5.0}
        op = op_with({"useStockToLeave": param("true"), "stockToLeave": param("-0.1 in", -0.1 * 2.54),
                      "simpleStockToLeave": param("false")})
        with patch.object(self.a, "measure_op_widths", return_value=meas) as m:
            g = self.a.op_geometry(op, {"diameter": 0.3, "fluteLength": 0.0625}, "slot", "in")
        self.assertEqual(m.call_args[0][3], "tslot")
        self.assertEqual(g["channel_width_in"], 0.4)
        self.assertEqual(g["sources"]["channel_width_in"], "measured")
        self.assertAlmostEqual(g["radial_depth_in"], 0.1, places=4)
        self.assertEqual(g["sources"]["radial_depth_in"], "measured")

    def test_note_uses_server_numbers_for_slot_and_side_passes(self):
        ms = {"count": 4, "stepover_in": 0.06}
        calc = {"feed": 46.62, "rpm": 14057}
        with patch.object(self.a, "_http_json", return_value={"success": True, "feed": 59.1, "rpm": 14197}) as h:
            text = self.a.multi_stepover_note(ms, {"diameter": 0.25}, calc, {"family": "x"}, 0.5, 0.25)
        sent = h.call_args[0][1]
        self.assertEqual(sent["operation"], "Roughing")
        self.assertEqual(sent["stepover"], 0.06)
        self.assertIn("FULL SLOT", text)
        self.assertIn("46.62 IPM", text)
        self.assertIn("59.10 IPM", text)
        self.assertIn("Slotting means full radial width (ae = D)", text)

    def test_note_survives_a_failed_side_call(self):
        with patch.object(self.a, "_http_json", side_effect=OSError("offline")):
            text = self.a.multi_stepover_note({"count": 3, "stepover_in": 0.05}, {"diameter": 0.25}, {"feed": 40.0, "rpm": 9000}, {}, 0.5, None)
        self.assertIn("40.00 IPM", text)
        self.assertNotIn("could run", text)


class TestAutosetterUsesTheSlotPass(unittest.TestCase):
    """run_autoset asks the server for the full-slot numbers (calc strategy Slotting, stepover = D) when the op has stepovers."""
    def run_it(self, ops_params, strategy="Roughing"):
        a = load_addin()
        a.ui = MagicMock()
        a._log = lambda *x, **k: None
        op = op_with(ops_params)
        sent = []

        def http(path, payload, **kw):
            sent.append(payload)
            return {"success": False, "error": "stop here"}
        geo = {"number": 5, "diameter": 0.25, "flutes": 3, "fluteLength": 0.75, "kind": "flat", "geometry": "Square", "shankDiameter": 0.25, "cornerRadius": 0.0, "stickout": 1.5}
        with patch.object(a, "get_op_tool_info", return_value=(geo, "s", [])), \
                patch.object(a, "_inspect_op_feature_geometry", return_value=None), \
                patch.object(a, "get_cam_document_units", return_value="in"), \
                patch.object(a, "get_op_cut_params", return_value=(12000.0, 90.0, 0.25, 0.06)), \
                patch.object(a, "_log_custom_diff"), patch.object(a, "_log_op_motion_params"), \
                patch.object(a, "_doc_tool_count", return_value=1), patch.object(a, "_http_json", side_effect=http):
            a.run_autoset(op, "Slot", "Aluminum - Wrought (6061)", "6061-T6", strategy, 0.5, None, "Carbide", "Uncoated")
        return sent[0]

    def test_multiple_stepovers_run_the_full_slot(self):
        p = self.run_it({"doMultiplePasses": param("true", 1), "maximumRoughingSteps": param("4", 4),
                         "maximumStepover": param("0.06 in", 0.06 * 2.54)})
        self.assertEqual(p["operation"], "Slotting")
        self.assertAlmostEqual(p["stepover"], 0.25)
        self.assertAlmostEqual(p["stepdown"], 0.25)

    def test_single_pass_keeps_the_op_stepover(self):
        p = self.run_it({"doMultiplePasses": param("false", 0), "maximumStepover": param("0.06 in", 0.06 * 2.54)})
        self.assertEqual(p["operation"], "Roughing")
        self.assertAlmostEqual(p["stepover"], 0.06)


if __name__ == "__main__":
    unittest.main()
