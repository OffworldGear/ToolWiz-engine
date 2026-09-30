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


if __name__ == "__main__":
    unittest.main()
