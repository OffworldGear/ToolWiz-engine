"""Fine stepdown: the auto-setter replaces Fusion's 10 % default, keeps user values, and audits the change."""
import json
import os
import tempfile
import unittest
from types import SimpleNamespace
from unittest.mock import MagicMock

from test_addin_common import load_addin, param, ParamsByName


class TestFineStepdownFloor(unittest.TestCase):
    def setUp(self):
        self.a = load_addin()
        self._tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self._tmp.cleanup)
        self.a._toolwiz_dir = lambda: self._tmp.name
        self.a.app = SimpleNamespace(activeDocument=SimpleNamespace(name="Pawl v1", products=MagicMock()))
        self.a.ui = MagicMock()

    def op(self, fine):
        params = {} if fine is None else {"fineStepdown": fine}
        return SimpleNamespace(name="Adaptive1", parent=SimpleNamespace(name="Setup1", allOperations=[]),
                               tool=MagicMock(), toolPreset=None, parameters=ParamsByName(params))

    def audit_rows(self):
        path = os.path.join(self._tmp.name, "audit.jsonl")
        if not os.path.exists(path):
            return []
        with open(path, encoding="utf-8") as f:
            return [json.loads(line) for line in f if line.strip()]

    def test_replaces_fusion_default_and_audits_it(self):
        p = param("Math.min(tool_diameter * 0.5; maximumStepdown * 0.1)", 0.00048)
        self.assertEqual(self.a.apply_fine_stepdown_floor(self.op(p)), "written")
        self.assertEqual(p.expression, self.a.FINE_STEPDOWN_EXPR)
        rows = [r for r in self.audit_rows() if r.get("param") == "fineStepdown"]
        self.assertEqual(len(rows), 1)
        self.assertIn("maximumStepdown * 0.1", rows[0]["old_expression"])

    def test_default_match_ignores_whitespace(self):
        p = param("Math.min(tool_diameter*0.5;maximumStepdown*0.1)", 0.001)
        self.assertEqual(self.a.apply_fine_stepdown_floor(self.op(p)), "written")

    def test_user_value_is_kept(self):
        p = param("0.01 mm", 0.001)
        self.assertEqual(self.a.apply_fine_stepdown_floor(self.op(p)), "kept")
        self.assertEqual(p.expression, "0.01 mm")
        self.assertEqual(self.audit_rows(), [])

    def test_already_ours_is_not_rewritten(self):
        p = param(self.a.FINE_STEPDOWN_EXPR, 0.005)
        self.assertEqual(self.a.apply_fine_stepdown_floor(self.op(p)), "already")
        self.assertEqual(self.audit_rows(), [])

    def test_missing_or_disabled_parameter(self):
        self.assertIsNone(self.a.apply_fine_stepdown_floor(self.op(None)))
        p = param("Math.min(tool_diameter * 0.5; maximumStepdown * 0.1)")
        p.isEnabled = False
        self.assertIsNone(self.a.apply_fine_stepdown_floor(self.op(p)))
        self.assertEqual(p.expression, "Math.min(tool_diameter * 0.5; maximumStepdown * 0.1)")

    def test_expression_evaluates_to_the_rule(self):
        # Evaluate the Fusion expression with plain Python to check the rule's numbers (mm).
        def fine(stepdown_mm, dia_mm):
            expr = (self.a.FINE_STEPDOWN_EXPR.replace("Math.min", "min").replace("Math.max", "max")
                    .replace(";", ",").replace("0.05 mm", "0.05"))
            return eval(expr, {"min": min, "max": max}, {"maximumStepdown": stepdown_mm, "tool_diameter": dia_mm})
        self.assertAlmostEqual(fine(0.048, 1.5875), 0.048)   # T12 v1 stepdown: no extra levels
        self.assertAlmostEqual(fine(0.30, 3.175), 0.075)     # 25 % of the stepdown
        self.assertAlmostEqual(fine(0.15, 3.175), 0.05)      # floor at 0.05 mm
        self.assertAlmostEqual(fine(4.76, 1.5875), 0.79375)  # capped at half the diameter


if __name__ == "__main__":
    unittest.main()
