"""Stock to Leave strength settings (server + add-in) and pre-selecting the highlighted operation."""
import unittest
from unittest.mock import MagicMock

from app import app
from test_addin_common import load_addin
from test_addin_usability import AddinTmpBase


def wall_op(name="2D Contour - Finish Wall", strategy="contour2d"):
    return {"id": "op1", "name": name, "strategy": strategy, "unit": "inches",
            "diameter": 0.375, "flutes": 4, "fluteLength": 0.75, "shankDiameter": 0.375,
            "stickout": 1.25, "rpm": 4500, "feedrate": 35.0, "doc": 0.50, "woc": 0.015,
            "current_radial_stock": "0.0000 in", "current_axial_stock": "0.0000 in"}


class TestStockStrengthServer(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()
        self.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def run_op(self, op=None, **extra):
        body = {"family": "Titanium Alloy", "alloy": "Ti-6Al-4V (Grade 5)", "aggressiveness": 50,
                "mode": "auto_compensate", "operations": [op or wall_op()], **extra}
        resp = self.client.post("/api/stock_compensation", json=body)
        self.assertEqual(resp.status_code, 200)
        return resp.get_json()["results"][0]

    @staticmethod
    def inches(text):
        return float(text.split()[0])

    def test_default_is_full_strength(self):
        r = self.run_op()
        self.assertEqual((r["radial_scale"], r["axial_scale"]), (1.0, 1.0))

    def test_strength_scales_radial_and_axial_independently(self):
        full = self.run_op()
        part = self.run_op(radial_pct=25, axial_pct=75)
        self.assertAlmostEqual(self.inches(part["recommended_radial_stock"]),
                               self.inches(full["recommended_radial_stock"]) * 0.25, delta=0.00006)
        self.assertAlmostEqual(self.inches(part["recommended_axial_stock"]),
                               self.inches(full["recommended_axial_stock"]) * 0.75, delta=0.00006)
        # the physics (deflection) is reported unscaled
        self.assertEqual(part["deflection_in"], full["deflection_in"])

    def test_bad_strength_falls_back_to_full(self):
        r = self.run_op(radial_pct="abc", axial_pct=500)
        self.assertEqual((r["radial_scale"], r["axial_scale"]), (1.0, 1.0))

    def test_roughing_keeps_stock_whatever_the_strength(self):
        op = dict(wall_op("Adaptive Rough", "adaptive2d"), current_radial_stock="0.0200 in")
        r = self.run_op(op, radial_pct=25)
        self.assertEqual(r["recommended_radial_stock"], "0.0200 in")

    def test_hole_note_and_inputs_reported(self):
        r = self.run_op(wall_op("Bore 0.500 finish", "contour2d"))
        self.assertIn("diameter changes 2x", r["advisory"])
        self.assertIn("doc_in", r)
        self.assertIn("woc_in", r)
        self.assertNotIn("diameter changes 2x", self.run_op()["advisory"])


class TestStrengthAddin(AddinTmpBase):
    def test_dropdown_parsing(self):
        a = self.addin
        dd = MagicMock()
        dd.selectedItem.name = "75%"
        self.assertEqual(a.stock_strength_pct(dd), 75)
        dd.selectedItem.name = "60%"
        self.assertEqual(a.stock_strength_pct(dd), a.STOCK_STRENGTH_DEFAULT)
        self.assertIsNone(a.stock_strength_pct(None, None))

    def test_strengths_are_remembered(self):
        a = self.addin
        a.save_prefs(stock_radial_pct=25, stock_axial_pct=100)
        p = a.load_prefs()
        self.assertEqual((p["stock_radial_pct"], p["stock_axial_pct"]), (25, 100))
        a.save_prefs(stock_radial_pct=33)          # not one of the choices: ignored
        self.assertEqual(a.load_prefs()["stock_radial_pct"], 25)

    def test_query_sends_strengths(self):
        a = self.addin
        sent = {}
        a._http_json = lambda path, payload, timeout=0: sent.update(payload) or {"success": True, "results": []}
        a.query_toolwiz_stock_compensation("Titanium Alloy", "Ti-6Al-4V", 50, "auto_compensate",
                                           radial_pct=25, axial_pct=50)
        self.assertEqual((sent["radial_pct"], sent["axial_pct"]), (25, 50))


class TestHighlightedOperation(unittest.TestCase):
    def setUp(self):
        self.a = load_addin()

    def cam(self, *setups):
        c = MagicMock()
        c.setups = list(setups)
        return c

    def setup(self, name, ops):
        s = MagicMock()
        s.name = name
        s.allOperations = ops
        return s

    def op(self, name):
        o = MagicMock()
        o.name = name
        o.objectType = self.a.adsk.cam.Operation.classType()
        return o

    def select(self, *ents):
        sel = MagicMock()
        sel.count = len(ents)
        sel.item.side_effect = lambda i: MagicMock(entity=ents[i])
        self.a.ui = MagicMock()
        self.a.ui.activeSelections = sel

    def test_operation_inside_a_folder_is_preselected(self):
        a = self.a
        first, in_folder = self.op("Face"), self.op("Bore")
        in_folder.parent = MagicMock(name="CAMFolder")     # parent is a folder, not the setup
        self.select(in_folder)
        ops = {}
        label = a.discover_tool_ops(self.cam(self.setup("Setup1", [first, in_folder])), ops)
        self.assertEqual(label, "Setup1 > Bore")
        self.assertIs(ops[label], in_folder)

    def test_duplicate_names_pick_the_highlighted_one(self):
        a = self.a
        one, two = self.op("Contour"), self.op("Contour")
        self.select(two)
        ops = {}
        label = a.discover_tool_ops(self.cam(self.setup("S", [one, two])), ops)
        self.assertEqual(label, "S > Contour #2")
        self.assertIs(ops[label], two)

    def test_nothing_selected_defaults_to_first(self):
        a = self.a
        self.select()
        ops = {}
        label = a.discover_tool_ops(self.cam(self.setup("S", [self.op("A"), self.op("B")])), ops)
        self.assertEqual(label, "S > A")

    def test_selected_setup_is_ignored(self):
        a = self.a
        not_an_op = MagicMock()
        not_an_op.objectType = "adsk::cam::Setup"
        self.select(not_an_op)
        ops = {}
        label = a.discover_tool_ops(self.cam(self.setup("S", [self.op("A")])), ops)
        self.assertEqual(label, "S > A")


if __name__ == "__main__":
    unittest.main()
