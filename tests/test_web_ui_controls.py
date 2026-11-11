"""Smoke tests for the web UI additions (provenance panel, cut log, material filter...)."""
import os
import re
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import app as app_module

NEW_IDS = [
    "whyPanel", "whyRows", "whyShowAll", "whyStatus",
    "logCutBtn", "cutLogModal", "cutLogMeasured", "cutLogSubmit",
    "calibrationStatus", "roughingStockNote", "materialFilter",
    "twinBatchPanel", "threadClassWarning",
]

CUT = {
    "family": "Stainless - 300 Series (316)", "operation": "Wall Finishing (Deep DOC)",
    "diameter_in": 0.25, "flutes": 4, "stickout_in": 1.0, "rpm": 9500, "feed_ipm": 20.0,
    "doc_in": 0.5, "woc_in": 0.01, "predicted_deflection_in": 0.0004,
    "predicted_springback_in": 0.0003, "predicted_total_error_in": 0.0007,
}


class TestWebUi(unittest.TestCase):
    def setUp(self):
        import tempfile
        import cutlog
        # Never touch the user's real data/cutlog.db.
        self._tmp = tempfile.TemporaryDirectory()
        self._prev_db = cutlog._configured_db_path
        cutlog._configured_db_path = os.path.join(self._tmp.name, "cutlog.db")
        self.addCleanup(self._restore_db, cutlog)
        self.client = app_module.app.test_client()
        self.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "web"

    def _restore_db(self, cutlog):
        cutlog._configured_db_path = self._prev_db
        self._tmp.cleanup()

    def test_index_contains_new_elements(self):
        r = self.client.get("/")
        self.assertEqual(r.status_code, 200)
        html = r.get_data(as_text=True)
        for eid in NEW_IDS:
            self.assertIn(f'id="{eid}"', html, eid)

    def test_ui_fixes_present_in_markup(self):
        html = self.client.get("/").get_data(as_text=True)
        self.assertNotIn("Tortoise to Hare", html)
        # Only one clickable Auto-Set button remains (next to the DOC/WOC inputs).
        self.assertEqual(len(re.findall(r'<button[^>]*applyRecommendations\(\)', html)), 1)
        # Flute-length-equal default stickout is gone (3*D*1.05 = 1.575 for the 0.5" default).
        self.assertIn('id="stickout_val" class="tool-dialog-input" step="0.001" value="1.575"', html)

    def test_type_scale_has_no_tiny_fonts(self):
        css = open(os.path.join(os.path.dirname(__file__), "..", "static", "style.css"), encoding="utf-8").read()
        for name in ("xs", "sm", "md", "lg", "xl", "display"):
            self.assertIn(f"--fs-{name}:", css)
        for m in re.finditer(r"font-size:\s*([0-9.]+)(px|rem)", css):
            px = float(m.group(1)) * (16 if m.group(2) == "rem" else 1)
            self.assertGreaterEqual(px, 12.0)

    def test_data_alloys_include_hardness(self):
        data = self.client.get("/api/data").get_json()
        alloys = data["alloys"]
        self.assertTrue(alloys)
        self.assertTrue(all("hardness" in a for a in alloys))
        self.assertTrue(any(a["hardness"] for a in alloys))

    def test_calculate_exposes_ui_fields(self):
        r = self.client.post("/api/calculate", json={
            "family": "Steel - Tool (H13)", "tool": "Carbide Endmill", "coating": "AlTiN",
            "geometry": "Square", "operation": "Standard Roughing", "diameter": 0.5, "flutes": 4,
            "cutDepth": 0.5, "cutWidth": 0.1, "stickout": 1.575, "fluteLength": 1.5, "isCarbide": True,
        })
        body = r.get_json()
        for key in ("provenance", "feasible", "limited_by", "is_finishing"):
            self.assertIn(key, body)
        self.assertFalse(body["is_finishing"])
        # New default stickout (== backend auto rule) must not raise the collet-on-flutes warning.
        self.assertFalse(any("Collet Gripping" in t.get("title", "") for t in body["tips"]))

    def test_cutlog_post_with_header_returns_201(self):
        r = self.client.post("/api/cutlog", json=CUT)
        self.assertEqual(r.status_code, 201)
        body = r.get_json()
        self.assertTrue(body["success"])
        # Clean up the row so the local cut log is not polluted.
        d = self.client.delete(f"/api/cutlog/{body['id']}")
        self.assertEqual(d.status_code, 200)

    def test_cutlog_post_without_header_is_rejected(self):
        client = app_module.app.test_client()
        r = client.post("/api/cutlog", json=CUT)
        self.assertGreaterEqual(r.status_code, 400)

    def test_thread_class_fallback_fields(self):
        item = next(i for i in app_module.physics.threads_db if i.get("type", "").lower() == "internal")
        base = {"family": item["family"], "size": item["size"], "type": "Internal"}
        ok = self.client.post("/api/threads/calculate", json={**base, "class": item["class"]}).get_json()
        self.assertFalse(ok["class_fallback"])
        self.assertEqual(ok["class_used"], item["class"])
        fb = self.client.post("/api/threads/calculate", json={**base, "class": "ZZ"}).get_json()
        self.assertTrue(fb["class_fallback"])
        self.assertEqual(fb["class_used"], item["class"])

    def test_calibration_endpoint_shape(self):
        r = self.client.get("/api/calibration?family=" + CUT["family"])
        self.assertEqual(r.status_code, 200)
        self.assertIn("calibration", r.get_json())


if __name__ == "__main__":
    unittest.main()
