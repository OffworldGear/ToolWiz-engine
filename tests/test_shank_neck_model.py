"""The beam model must see the real tool profile: flutes, optional reduced neck, then shank."""
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import app as app_module
from toolwiz_common import ToolGeometry

BASE = {"family": "Copper Alloy - Wrought", "alloy": "C51000 - Phosphor Bronze 5% Sn (H02 (1/2 Hard))",
        "operation": "Adaptive Roughing", "aggressiveness": 50, "tool": "HP Carbide Endmill", "coating": "AlTiN",
        "diameter": 0.0625, "flutes": 4, "fluteLength": 0.187, "geometry": "Square", "maxRpm": 16000,
        "maxHp": 6.84, "stickout": 0.5}


class TestShankAndNeck(unittest.TestCase):
    def setUp(self):
        self.c = app_module.app.test_client()
        self.c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def doc(self, **extra):
        return self.c.post("/api/calculate_for_fusion", json={**BASE, **extra}).get_json()["doc"]

    def test_larger_shank_allows_deeper_cut(self):
        self.assertGreater(self.doc(shankDiameter=0.125), self.doc(shankDiameter=0.0625) * 3)

    def test_reduced_neck_sits_between(self):
        thin = self.doc(shankDiameter=0.0625)
        necked = self.doc(shankDiameter=0.125, hasRelievedNeck=True, neckDiameter=0.06, neckLength=0.375)
        stout = self.doc(shankDiameter=0.125)
        self.assertLess(thin, necked)
        self.assertLess(necked, stout)

    def test_fusion_shoulder_fields_become_neck(self):
        tool = {"type": "flat end mill", "unit": "inches",
                "geometry": {"DC": 0.0625, "NOF": 4, "LCF": 0.187, "SFDM": 0.125, "LB": 0.5,
                             "shoulder-length": 0.375, "shoulder-diameter": 0.06}}
        g = ToolGeometry.from_fusion(tool)
        self.assertAlmostEqual(g.neck_length, 0.375)
        self.assertAlmostEqual(g.neck_diameter, 0.06)

    def test_plain_tool_has_no_neck(self):
        tool = {"type": "flat end mill", "unit": "inches",
                "geometry": {"DC": 0.125, "NOF": 3, "LCF": 0.375, "SFDM": 0.125, "LB": 0.47,
                             "shoulder-length": 0.375, "shoulder-diameter": 0.125}}
        g = ToolGeometry.from_fusion(tool)
        self.assertIsNone(g.neck_length)


if __name__ == "__main__":
    unittest.main()
