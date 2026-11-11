import unittest
from unittest.mock import MagicMock

from test_addin_common import load_addin

# Fusion's default spindle formula; confirmed in Fusion that it evaluates to 5000.0 (plain RPM).
FORMULA = "tool_type == 'probe' ? 0 : tool_type == 'tap right hand' || tool_type == 'tap left hand' ? 500rpm : 5000rpm"


def param(expression, evaluated):
    p = MagicMock()
    p.expression = expression
    p.value.value = evaluated
    return p


class TestSpindleFallback(unittest.TestCase):
    def setUp(self):
        self.addin = load_addin()
        self.addin._log = lambda *a, **k: None
        self.addin._machine_max_rpm = 16000.0

    def test_formula_uses_evaluated_value_as_rpm(self):
        self.assertEqual(self.addin.parse_cam_rpm(param(FORMULA, 5000.0)), 5000.0)

    def test_plain_expression_still_parsed(self):
        self.assertEqual(self.addin.parse_cam_rpm(param("12000 rpm", 0.0)), 12000.0)

    def test_value_above_machine_max_is_discarded(self):
        self.assertEqual(self.addin.parse_cam_rpm(param(FORMULA, 47746.0)), 0.0)

    def test_unknown_machine_uses_generic_ceiling(self):
        self.addin._machine_max_rpm = None
        self.assertEqual(self.addin.parse_cam_rpm(param(FORMULA, 25000.0)), 25000.0)
        self.assertEqual(self.addin.parse_cam_rpm(param(FORMULA, 47746.0)), 0.0)


class TestPresetSpeedSource(unittest.TestCase):
    def setUp(self):
        self.addin = load_addin()
        self.addin._log = lambda *a, **k: None
        self.addin._machine_max_rpm = 16000.0

    def op(self, preset_rpm=None, preset_feed=None):
        op = MagicMock()
        op.name = "Finish"
        op_params = {"tool_spindleSpeed": param(FORMULA, 5000.0), "tool_feedCutting": param("40 in/min", 0)}
        op.parameters.itemByName.side_effect = lambda n: op_params.get(n)
        if preset_rpm is None:
            op.toolPreset = None
        else:
            pp = {"tool_spindleSpeed": param(f"{preset_rpm} rpm", 0), "tool_feedCutting": param(f"{preset_feed} in/min", 0)}
            op.toolPreset.parameters.itemByName.side_effect = lambda n: pp.get(n)
        return op

    def test_op_default_formula_falls_back_to_linked_preset(self):
        rpm, feed, _, _ = self.addin.get_op_cut_params(self.op(preset_rpm=12500, preset_feed=180), "in")
        self.assertEqual(rpm, 12500.0)          # op held only Fusion's placeholder formula
        self.assertEqual(feed, 40.0)            # op feed is a real value, so it wins

    def test_op_values_win_over_differing_preset(self):
        # Real document: preset 9500 rpm, operation edited to 14250 rpm -> the op is what posts.
        op = self.op(preset_rpm=9500, preset_feed=20)
        op_params = {"tool_spindleSpeed": param("14250.", 14250.0), "tool_feedCutting": param("30 in/min", 0)}
        op.parameters.itemByName.side_effect = lambda n: op_params.get(n)
        rpm, feed, _, _ = self.addin.get_op_cut_params(op, "in")
        self.assertEqual((rpm, feed), (14250.0, 30.0))

    def test_without_preset_default_formula_uses_evaluated_rpm(self):
        rpm, feed, _, _ = self.addin.get_op_cut_params(self.op(), "in")
        self.assertEqual((rpm, feed), (5000.0, 40.0))

    def test_evaluated_feed_is_mm_per_min(self):
        p = param("tool_type == 'probe' ? 0 : 20in/min", 489.6471438263792)
        self.assertAlmostEqual(self.addin.parse_cam_feed_to_ipm(p, "in"), 19.2774, places=3)

if __name__ == "__main__":
    unittest.main()
