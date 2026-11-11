"""v3 web panels: markup ids, static scripts parse, /api/shop_tools, request fields the page sends."""
import json
import os
import re
import shutil
import subprocess
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import app as app_module

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
NODE = shutil.which("node")

IDS = [
    # results
    "v3Results", "engagementCard", "limitedByLine", "runoutCard", "stockCard", "holderCard", "toolAdviceCard", "tslotCard",
    "finishCard", "runoutGroup", "runoutHint", "engagementRangeNote", "finishModeBox", "targetRa", "wallTolerance",
    # T-slot
    "tslotInputs", "shopToolSelect", "toothForm", "teethPerFace", "faceperiphery", "facetop", "facebottom",
    "tslotOperation", "slotHeight", "radialDepthTotal",
    # tabs and planner
    "tabPlannerBtn", "tabAdvisorBtn", "plannerView", "advisorView", "plFeature", "plFamily", "plAlloy", "plAggr", "plRunout",
    "plTools", "plRun", "plResults", "wearRuleBox",
    # twin
    "mlSets", "mlPreviewBtn", "mlStart", "mlProgress", "mlResults", "mlAggr", "mlStrats", "mlTypes", "mlEditor",
    "auRun", "auResults", "twinSortSelect",
    # advisor
    "advBody", "advRefresh",
]
SCRIPTS = ["tw_common", "results_v3", "tslot_ui", "planner_ui", "twin_ui", "master_ui", "advisor_ui", "tw_boot"]


class TestWebV3(unittest.TestCase):
    def setUp(self):
        self.client = app_module.app.test_client()
        self.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
        self.html = self.client.get("/").get_data(as_text=True)

    def test_markup_ids(self):
        for eid in IDS:
            self.assertIn(f'id="{eid}"', self.html, eid)

    def test_scripts_are_served_and_parse(self):
        for name in SCRIPTS:
            self.assertIn(f"/static/js/{name}.js", self.html)
            r = self.client.get(f"/static/js/{name}.js")
            self.assertEqual(r.status_code, 200, name)
            if NODE:
                path = os.path.join(ROOT, "static", "js", f"{name}.js")
                out = subprocess.run([NODE, "--check", path], capture_output=True, text=True)
                self.assertEqual(out.returncode, 0, out.stderr)
        self.assertEqual(self.client.get("/static/v3.css").status_code, 200)

    def test_twin_buttons_address_tools_by_guid(self):
        js = open(os.path.join(ROOT, "static", "js", "twin_ui.js"), encoding="utf-8").read()
        self.assertIn("tool_guid", js)
        self.assertIn("tool_guids", js)
        self.assertNotIn("tool_index: toolIndex", js)

    def test_shop_tools_endpoint(self):
        d = self.client.get("/api/shop_tools").get_json()
        self.assertTrue(d["success"])
        ids = {t["id"] for t in d["tools"]}
        self.assertIn("klot_6x2", ids)
        self.assertIn("harvey_867330", ids)

    def test_page_sends_new_request_fields(self):
        js = open(os.path.join(ROOT, "static", "js", "tslot_ui.js"), encoding="utf-8").read()
        for key in ("toothForm", "cuttingFaces", "teethPerFace", "tslotOperation", "slotHeight", "radialDepthTotal"):
            self.assertIn(key, js)
        fin = open(os.path.join(ROOT, "static", "js", "results_v3.js"), encoding="utf-8").read()
        for key in ("finishMode", "targetRa", "wallTolerance"):
            self.assertIn(key, fin)

    def test_strategy_compare_round_trip_used_by_planner(self):
        body = {"family": "Aluminum - Wrought (6061)", "alloy": "6061-T6", "aggressiveness": 0.5, "runout": 0.0002,
                "feature": {"type": "slot", "width": 0.25, "depth": 0.25, "length": 6},
                "candidate_tools": [{"diameter": 0.25, "flutes": 3, "flute_length": 0.75, "shank_diameter": 0.25,
                                     "stickout": 1.0, "coating": "Uncoated", "geometry": "Square"}]}
        r = self.client.post("/api/strategy/compare", json=body)
        self.assertEqual(r.status_code, 200, r.get_data(as_text=True))
        d = r.get_json()
        self.assertTrue(d["options"])
        for k in ("recommended", "reasoning", "assumptions", "wear_ratio_limit"):
            self.assertIn(k, d)

    def test_material_sets_and_audit_endpoints_the_page_uses(self):
        d = self.client.get("/api/twin/material_sets").get_json()
        self.assertTrue(d["success"])
        self.assertTrue(d["material_sets"]["sets"])
        r = self.client.post("/api/twin/audit", json={"tools": []})
        self.assertIn(r.status_code, (200, 400))


if __name__ == "__main__":
    unittest.main()
