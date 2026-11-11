"""Ramp: Auto-Set writes the server's ramp angle to the preset and a v2 helical ramp diameter to the
operation (only over Fusion's default), audited; the Fusion endpoint returns the angle."""
import json
import os
import tempfile
import unittest
from types import SimpleNamespace
from unittest.mock import MagicMock

from test_addin_common import load_addin, param, ParamsByName


class TestRampAngleExpr(unittest.TestCase):
    def setUp(self):
        self.a = load_addin()

    def test_values(self):
        f = self.a.ramp_angle_expr
        self.assertEqual(f({"ramp_angle": 0.75}), "0.75")
        self.assertEqual(f({"ramp_angle": "1.5"}), "1.50")
        for bad in ({}, {"ramp_angle": 0}, {"ramp_angle": 90.0}, {"ramp_angle": "x"}, {"ramp_angle": None}):
            self.assertIsNone(f(bad), bad)


class TestRampDiameter(unittest.TestCase):
    def setUp(self):
        self.a = load_addin()
        self._tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self._tmp.cleanup)
        self.a._toolwiz_dir = lambda: self._tmp.name
        self.a.app = SimpleNamespace(activeDocument=SimpleNamespace(name="Pawl v1", products=MagicMock()))
        self.a.ui = MagicMock()

    def op(self, p):
        params = {} if p is None else {"helicalRampDiameter": p}
        return SimpleNamespace(name="Adaptive1", parent=SimpleNamespace(name="Setup1", allOperations=[]),
                               tool=MagicMock(), toolPreset=None, parameters=ParamsByName(params))

    def audit_rows(self):
        path = os.path.join(self._tmp.name, "audit.jsonl")
        if not os.path.exists(path):
            return []
        with open(path, encoding="utf-8") as f:
            return [json.loads(line) for line in f if line.strip()]

    def test_writes_over_fusion_default_and_audits(self):
        p = param(self.a.FUSION_DEFAULT_RAMP_DIAMETER, 0.15)
        self.assertEqual(self.a.apply_ramp_diameter(self.op(p), 0.03125), "written")
        self.assertEqual(p.expression, "0.0312 in")
        self.assertEqual([r["param"] for r in self.audit_rows()], ["helicalRampDiameter"])

    def test_keeps_user_value_and_ignores_missing_values(self):
        p = param("0.5 mm", 0.05)
        self.assertEqual(self.a.apply_ramp_diameter(self.op(p), 0.03), "kept")
        self.assertEqual(p.expression, "0.5 mm")
        self.assertIsNone(self.a.apply_ramp_diameter(self.op(p), None))
        self.assertIsNone(self.a.apply_ramp_diameter(self.op(None), 0.03))
        self.assertEqual(self.audit_rows(), [])


class TestEndpointRampAngle(unittest.TestCase):
    def test_fusion_endpoint_returns_ramp_angle(self):
        import app
        c = app.app.test_client()
        c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
        geo = {"DC": 0.0625, "NOF": 4, "LCF": 0.1875, "SFDM": 0.125, "LB": 0.5}
        r = c.post("/api/calculate_for_fusion", json={
            "family": "Stainless - PH Series (17-4)", "alloy": "17-4 PH (H 1025)", "tool": "HP Carbide Endmill",
            "geometry": "Square", "operation": "Adaptive Roughing", "diameter": 0.0625, "flutes": 4,
            "aggressiveness": 50, "fusion_tool": {"type": "flat end mill", "unit": "inches", "geometry": geo}}).get_json()
        self.assertTrue(r["success"])
        self.assertGreater(r["ramp_angle"], 0.0)
        self.assertLess(r["ramp_angle"], 3.0)


if __name__ == "__main__":
    unittest.main()
