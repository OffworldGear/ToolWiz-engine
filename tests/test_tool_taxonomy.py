"""Tool Properties taxonomy: Tool Type + Tool Material + Geometry (no geometry-in-category names)."""
import re
import unittest

import app as flask_app

LEGACY = {
    "HP Carbide Bull Nose Endmill": ("HP Carbide Endmill", "Radiused"),
    "HP Carbide High Feed Endmill": ("HP Carbide Endmill", "High Feed"),
    "Carbide Bull Nose Endmill": ("Carbide Endmill", "Radiused"),
    "Carbide High Feed Endmill": ("Carbide Endmill", "High Feed"),
}


class TestToolTaxonomy(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.client = flask_app.app.test_client()
        cls.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def _calc(self, tool, geometry, operation="Roughing"):
        payload = {
            "family": "Steel - Tool", "alloy": "", "tool": tool, "coating": "AlTiN",
            "geometry": geometry, "operation": operation, "cornerRadius": 0.03,
            "diameter": 0.5, "flutes": 4, "fluteLength": 1.0, "stickout": 2.0,
            "cutDepth": 0.25, "cutWidth": 0.1, "isCarbide": True,
            "aggressiveness": 50, "maxRpm": 12000, "maxHp": 10,
        }
        res = self.client.post("/api/calculate", json=payload)
        self.assertEqual(res.status_code, 200, res.get_data(as_text=True)[:300])
        return res.get_json()

    @staticmethod
    def _strip(data):
        # The echoed tool/geometry labels may legitimately differ; compare everything computed.
        return {k: v for k, v in data.items() if k not in ("tool", "geometry")}

    def test_legacy_names_equal_base_category_plus_geometry(self):
        for legacy, (base, geo) in LEGACY.items():
            for op in ("Roughing", "High Feed Milling"):
                with self.subTest(legacy=legacy, op=op):
                    a = self._calc(legacy, "Square", op)        # legacy name, geometry left at default
                    b = self._calc(base, geo, op)               # base category + explicit geometry
                    self.assertEqual(self._strip(a), self._strip(b))
                    c = self._calc(legacy, "", op)              # empty geometry also migrates
                    self.assertEqual(self._strip(c), self._strip(b))

    def test_legacy_name_keeps_explicit_geometry(self):
        a = self._calc("Carbide High Feed Endmill", "Ball")
        b = self._calc("Carbide Endmill", "Ball")
        self.assertEqual(self._strip(a), self._strip(b))

    def test_api_data_tool_categories(self):
        data = self.client.get("/api/data").get_json()
        cats = data["tool_categories"]
        for legacy in LEGACY:
            self.assertNotIn(legacy, cats)
            self.assertNotIn(legacy, data["tools"])
        for g in data["tool_groups"]:
            for legacy in LEGACY:
                self.assertNotIn(legacy, g["tools"])
        for expected in ("HP Carbide Endmill", "Carbide Endmill", "HSS Endmill", "PCD Endmill",
                         "Carbide Twist Drill", "Tapping", "HSS Reamer", "Carbide Thread Mill"):
            self.assertIn(expected, cats)
        self.assertNotIn("TiAlN Carbide Endmill", cats)
        self.assertFalse([c for c in cats if c.startswith("Turning:")])
        self.assertEqual(cats, sorted(set(cats)))

    def test_index_has_type_material_selects_and_no_carbide_checkbox(self):
        html = self.client.get("/").get_data(as_text=True)
        for ident in ("toolType", "toolMaterial", "geometry", "coating"):
            self.assertRegex(html, r'<select id="%s"' % ident)
        self.assertRegex(html, r'<input type="hidden" id="tool"')
        self.assertNotIn("Tool is Solid Carbide", html)
        for m in re.finditer(r"<input[^>]*>", html):
            tag = m.group(0)
            if 'id="isCarbide"' in tag:
                self.fail("isCarbide checkbox still present: " + tag)
        self.assertNotIn("getElementById('isCarbide')", html)


if __name__ == "__main__":
    unittest.main()
