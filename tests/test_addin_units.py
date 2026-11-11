import json
import os
import tempfile
import unittest
from unittest.mock import MagicMock

from test_addin_common import load_addin, param, ParamsByName


class AddinTestBase(unittest.TestCase):
    def setUp(self):
        self.addin = load_addin()
        self._tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self._tmp.cleanup)
        self.addin._toolwiz_dir = lambda: self._tmp.name
        self.addin.app = None
        self.addin.ui = MagicMock()


class TestFeedParsing(AddinTestBase):
    def test_inch_feed_in_metric_document_stays_ipm(self):
        self.assertAlmostEqual(self.addin.parse_cam_feed_to_ipm(param("250 in/min"), "mm"), 250.0)

    def test_metric_feed_converts(self):
        self.assertAlmostEqual(self.addin.parse_cam_feed_to_ipm(param("6350 mm/min"), "in"), 250.0)

    def test_unitless_uses_document_unit(self):
        self.assertAlmostEqual(self.addin.parse_cam_feed_to_ipm(param("250"), "in"), 250.0)
        self.assertAlmostEqual(self.addin.parse_cam_feed_to_ipm(param("6350"), "mm"), 250.0)

    def test_ipm_token(self):
        self.assertAlmostEqual(self.addin.parse_cam_feed_to_ipm(param("80 ipm"), "mm"), 80.0)

    def test_never_rescales_by_magnitude(self):
        # A large unit-less number in an inch document is NOT treated as mm/min.
        self.assertAlmostEqual(self.addin.parse_cam_feed_to_ipm(param("5000"), "in"), 5000.0)
        self.assertAlmostEqual(self.addin.parse_cam_feed_to_ipm(param("30 in/min"), "mm"), 30.0)


class TestLengthParsing(AddinTestBase):
    def test_inch_expression_in_metric_document(self):
        self.assertAlmostEqual(self.addin.parse_cam_param_to_inches(param("0.5 in"), 0.0, "mm"), 0.5)

    def test_metric_expression_in_inch_document(self):
        self.assertAlmostEqual(self.addin.parse_cam_param_to_inches(param("12.7 mm"), 0.0, "in"), 0.5)

    def test_unitless_uses_document_unit(self):
        self.assertAlmostEqual(self.addin.parse_cam_param_to_inches(param("0.5"), 0.0, "in"), 0.5)
        self.assertAlmostEqual(self.addin.parse_cam_param_to_inches(param("12.7"), 0.0, "mm"), 0.5)

    def test_small_unitless_metric_not_treated_as_inches(self):
        # 0.5 in a metric document is 0.5 mm, regardless of magnitude.
        self.assertAlmostEqual(self.addin.parse_cam_param_to_inches(param("0.5"), 0.0, "mm"), 0.5 / 25.4)

    def test_quote_and_fraction(self):
        self.assertAlmostEqual(self.addin.parse_cam_param_to_inches(param('0.5"'), 0.0, "mm"), 0.5)
        self.assertAlmostEqual(self.addin.parse_cam_param_to_inches(param("3/8 in"), 0.0, "mm"), 0.375)

    def test_arithmetic_with_unit(self):
        self.assertAlmostEqual(self.addin.parse_cam_param_to_inches(param("(-.1) * 1mm"), 0.0, "in"), -0.1 / 25.4)

    def test_mixed_units_rejected(self):
        with self.assertRaises(ValueError):
            self.addin.parse_length_expr_to_inches("1 in + 2 mm", "in")

    def test_evaluated_cm_value_preferred(self):
        self.assertAlmostEqual(self.addin.parse_cam_param_to_inches(param("tool_diameter * 2", 1.27), 0.0, "mm"), 0.5)

    def test_unparseable_returns_default(self):
        p = param("math.min(tool_flutelength * 0.75; tool_diameter * 2.5)")
        self.assertEqual(self.addin.parse_cam_param_to_inches(p, 0.0, "in"), 0.0)
        self.assertEqual(self.addin.parse_cam_param_to_inches(None, 0.25, "in"), 0.25)

    def test_no_eval_of_malicious_expression(self):
        p = param("__import__('os').system('echo hi')")
        self.assertEqual(self.addin.parse_cam_param_to_inches(p, 0.0, "in"), 0.0)


class TestRpmParsing(AddinTestBase):
    def test_rpm(self):
        self.assertEqual(self.addin.parse_cam_rpm(param("3500 rpm")), 3500.0)
        self.assertEqual(self.addin.parse_cam_rpm(param("3500")), 3500.0)
        self.assertEqual(self.addin.parse_cam_rpm(None), 0.0)

    def test_small_rpm_not_rescaled(self):
        self.assertEqual(self.addin.parse_cam_rpm(param("1500 rpm")), 1500.0)


class TestCutParams(AddinTestBase):
    def _op(self, **kw):
        return MagicMock(parameters=ParamsByName(kw))

    def test_mixed_units_in_metric_document(self):
        op = self._op(
            tool_spindleSpeed=param("8000 rpm"),
            tool_feedCutting=param("250 in/min"),
            maximumStepdown=param("0.5 in"),
            stepover=param("12.7 mm"),
        )
        rpm, feed, doc, woc = self.addin.get_op_cut_params(op, "mm")
        self.assertEqual(rpm, 8000.0)
        self.assertAlmostEqual(feed, 250.0)
        self.assertAlmostEqual(doc, 0.5)
        self.assertAlmostEqual(woc, 0.5)

    def test_metric_feed_in_inch_document(self):
        op = self._op(tool_spindleSpeed=param("8000 rpm"), tool_feedCutting=param("6350 mm/min"))
        _, feed, _, _ = self.addin.get_op_cut_params(op, "in")
        self.assertAlmostEqual(feed, 250.0)


class TestStockExpr(AddinTestBase):
    def test_clean_eval(self):
        f = self.addin.clean_and_eval_stock_expr
        self.assertEqual(f("(-.1) * 1mm", "in"), "-0.100 mm")
        self.assertEqual(f("0mm", "in"), "0.000 mm")
        self.assertEqual(f("0.02 in", "mm"), "0.0200 in")
        self.assertEqual(f("", "in"), "0.0000 in")
        self.assertEqual(f("0.5", "mm"), "0.500 mm")

    def test_no_eval(self):
        expr = "__import__('os').getcwd()"
        self.assertEqual(self.addin.clean_and_eval_stock_expr(expr, "in"), expr)
        self.assertFalse(hasattr(self.addin, "safe_eval_expr"))


class TestStockPayload(AddinTestBase):
    def test_payload_units_and_skip_unreadable(self):
        geo = {"diameter": 0.5, "flutes": 4, "fluteLength": 1.0, "shankDiameter": 0.5,
               "stickout": 1.6, "coating": "AlTiN", "geometry": "Square"}
        cache = {
            "op_1": {"name": "A", "strategy": "contour2d", "unit": "mm", "geo": geo,
                     "rpm": 8000.0, "feed": 250.0, "doc": 0.5, "woc": 0.1,
                     "current_radial": "0.000 mm", "current_axial": "0.000 mm"},
            "op_2": {"name": "B", "strategy": "contour2d", "unit": "in", "geo": None},
        }
        payload = self.addin.build_stock_ops_payload(cache, "in")
        self.assertEqual([o["id"] for o in payload], ["op_1"])
        op = payload[0]
        self.assertEqual(op["feed_unit"], "ipm")
        self.assertEqual(op["length_unit"], "in")
        self.assertEqual(op["unit"], "mm")
        self.assertEqual(op["feedrate"], 250.0)
        self.assertEqual(op["diameter"], 0.5)


class TestToolInfo(AddinTestBase):
    def _op(self, tool_dict):
        tool = MagicMock(spec=['toJson'])
        tool.toJson.return_value = json.dumps(tool_dict)
        return MagicMock(tool=tool, parameters=ParamsByName({}))

    def test_metric_tool_auto_stickout_is_labelled(self):
        op = self._op({"unit": "millimeters", "type": "flat end mill", "description": "12.7 mm",
                       "geometry": {"DC": 12.7, "NOF": 4, "LCF": 25.4},
                       "post-process": {"number": 7}})
        geo, summary, _ = self.addin.get_op_tool_info(op)
        self.assertAlmostEqual(geo["diameter"], 0.5)
        self.assertEqual(geo["stickoutSource"], "default")
        self.assertIn("Stickout", summary)
        self.assertIn("Auto", summary)
        self.assertIn("verify", summary)
        self.assertEqual(geo["number"], 7)

    def test_fusion_lb_stickout(self):
        op = self._op({"unit": "inches", "type": "flat end mill", "description": "1/2",
                       "geometry": {"DC": 0.5, "NOF": 3, "LCF": 1.0, "LB": 1.24}})
        geo, summary, _ = self.addin.get_op_tool_info(op)
        self.assertAlmostEqual(geo["stickout"], 1.24)
        self.assertIn('Stickout 1.240" (Fusion LB)', summary)
        self.assertIsNone(geo["number"])
        self.assertIn("T?", summary)

    def test_no_unit_is_user_error_not_guess(self):
        op = self._op({"type": "flat end mill", "geometry": {"DC": 6.35, "NOF": 4}})
        geo, summary, presets = self.addin.get_op_tool_info(op)
        self.assertIsNone(geo)
        self.assertIn("Cannot read tool geometry", summary)
        self.assertEqual(presets, [])

    def test_old_helpers_removed(self):
        self.assertFalse(hasattr(self.addin, "parse_dim_to_inches"))


if __name__ == "__main__":
    unittest.main()
