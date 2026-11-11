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


@unittest.skipUnless(NODE, "node not installed")
class TestRunoutCardFlutes(unittest.TestCase):
    """The runout card must count flutes from the same value the request sends (flutes_val), not a stale default."""

    def run_card(self, response, flutes_val="2", stale_range="4"):
        js = r"""
        const vm = require('vm'), fs = require('fs'), path = require('path');
        const root = %s;
        const els = { flutes_val: { value: %s }, flutes: { value: %s } };
        const ctx = { document: { getElementById: id => els[id] || null }, isMetric: false, runoutInches: 0.0002, console };
        ctx.window = ctx; ctx.esc = v => String(v == null ? '' : v);
        vm.createContext(ctx);
        vm.runInContext("function currentFlutes(){const n=parseInt(document.getElementById('flutes_val')?.value); if(n>0) return n; const r=parseInt(document.getElementById('flutes')?.value); return r>0?r:2;}", ctx);
        for (const f of ['tw_common', 'results_v3']) vm.runInContext(fs.readFileSync(path.join(root, 'static', 'js', f + '.js'), 'utf8'), ctx);
        process.stdout.write(ctx.runoutCardHtml(%s));
        """ % (json.dumps(ROOT), json.dumps(flutes_val), json.dumps(stale_range), json.dumps(response))
        out = subprocess.run([NODE, "-e", js], capture_output=True, text=True)
        self.assertEqual(out.returncode, 0, out.stderr)
        return out.stdout

    RES = {"flutes_cutting": 1, "runout_regime": "reduced_flutes", "tir_all_flutes_in": 0.000196, "runout_ratio": 0.66}

    def test_two_flute_tool_says_of_2_even_if_range_slider_is_stale(self):
        html = self.run_card(self.RES, flutes_val="2", stale_range="4")
        self.assertIn("1 of 2 flutes cutting", html)
        self.assertNotIn("of 4", html)

    def test_response_flute_count_wins(self):
        html = self.run_card(dict(self.RES, flutes=3), flutes_val="2")
        self.assertIn("1 of 3 flutes cutting", html)

    def test_page_sends_and_draws_the_same_flute_value(self):
        html = app_module.app.test_client().get("/").get_data(as_text=True)
        self.assertIn("function currentFlutes()", html)
        self.assertIn("flutes: currentFlutes(),", html)
        self.assertNotIn("flutes: document.getElementById('flutes').value", html)
        self.assertNotIn("parseInt(document.getElementById('flutes')?.value) || 1", html)
        self.assertNotIn("(4 FL)", html)


@unittest.skipUnless(NODE, "node not installed")
class TestAdvisorUi(unittest.TestCase):
    def _eval(self, expr):
        js = r"""
        const vm = require('vm'), fs = require('fs'), path = require('path');
        const ctx = { document: { getElementById: () => null, querySelectorAll: () => [] }, isMetric: false, console };
        ctx.window = ctx; ctx.esc = v => String(v == null ? '' : v); vm.createContext(ctx);
        for (const f of ['tw_common', 'advisor_ui']) vm.runInContext(fs.readFileSync(path.join(%s, 'static', 'js', f + '.js'), 'utf8'), ctx);
        process.stdout.write(String(vm.runInContext(%s, ctx)));
        """ % (json.dumps(ROOT), json.dumps(expr))
        out = subprocess.run([NODE, "-e", js], capture_output=True, text=True)
        self.assertEqual(out.returncode, 0, out.stderr)
        return out.stdout

    def test_chat_badge_only_when_numeric_check_ok(self):
        self.assertIn("numbers verified by ToolWiz", self._eval("aiVerifiedBadge({mode:'gemini_live', numeric_check:{ok:true}})"))
        self.assertEqual(self._eval("aiVerifiedBadge({mode:'gemini_live'})"), "")
        self.assertEqual(self._eval("aiVerifiedBadge({numeric_check:{ok:false}})"), "")
        self.assertIn("AI text withheld: unverified numbers", self._eval("aiVerifiedBadge({mode:'guard_fallback', numeric_check:{ok:false}})"))
        self.assertEqual(self._eval("aiVerifiedBadge({numbers_verified:true})"), "")   # guessed field names are gone

    def test_apply_sends_exactly_the_plan(self):
        js = open(os.path.join(ROOT, "static", "js", "advisor_ui.js"), encoding="utf-8").read()
        self.assertIn("/api/setup_advisor/apply", js)
        self.assertIn("params: o.apply_plan[kind]", js)
        self.assertIn("rejected", js)
        self.assertIn("Fusion will ask you to confirm", js)
