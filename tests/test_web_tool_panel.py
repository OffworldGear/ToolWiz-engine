"""Tool Properties panel (Fusion-style Cutter fields): markup, script syntax and the pure helpers.

The page's logic lives in one big inline <script>, so these tests (a) check the served markup with the
Flask test client, (b) run `node --check` on the extracted script and (c) execute a few of the pure
functions (state migration, Fusion type mapping, profile drawing) in node.
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
import app as app_module  # noqa: E402

NODE = shutil.which("node")

COMMON_IDS = [
    "diameter", "flutes_val", "fluteLength", "shoulderLength", "shoulderDiameter", "shaftDiameter",
    "stickout_val", "cornerRadius", "cornerRadiusGroup", "helix_val",
]
MORE_IDS = ["toolMoreToggle", "toolMoreFields", "overallLength", "taperAngle", "tipDiameter", "pitch", "pitchGroup"]
LOADER_IDS = ["loadLibraryBtn", "libraryLoaderModal", "libraryLoaderList", "libraryLoadStatus"]
REMOVED_IDS = ["hasRelievedNeck", "relievedNeckToggleGroup", "neckDiameter", "neckLength", "shankDiameter",
               "shankGroup", "neckGroup"]


def _scripts(html):
    return [b for b in re.findall(r"<script(?:\s[^>]*)?>(.*?)</script>", html, re.S) if b.strip()]


def _extract_function(js, name):
    """Source text of `function name(...) { ... }` (brace matched)."""
    m = re.search(r"(?:async\s+)?function\s+%s\s*\(" % re.escape(name), js)
    assert m, "function %s not found" % name
    i = js.index("{", m.end())
    depth = 0
    for j in range(i, len(js)):
        if js[j] == "{":
            depth += 1
        elif js[j] == "}":
            depth -= 1
            if depth == 0:
                return js[m.start():j + 1]
    raise AssertionError("unbalanced braces in %s" % name)


def _extract_const(js, name):
    m = re.search(r"const\s+%s\s*=\s*\{.*?\n        \};" % re.escape(name), js, re.S)
    assert m, "const %s not found" % name
    return m.group(0)


class TestToolPanelMarkup(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        client = app_module.app.test_client()
        client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "web"
        r = client.get("/")
        assert r.status_code == 200
        cls.html = r.get_data(as_text=True)

    def test_new_field_ids_present(self):
        for eid in COMMON_IDS + MORE_IDS + LOADER_IDS:
            self.assertIn('id="%s"' % eid, self.html, eid)

    def test_old_relieved_neck_controls_are_gone(self):
        for eid in REMOVED_IDS:
            self.assertNotIn('id="%s"' % eid, self.html, eid)
        self.assertNotIn("Relieved Neck / Stepped Shank", self.html)
        self.assertNotIn("toggleRelievedNeck", self.html)
        self.assertNotIn("getElementById('hasRelievedNeck')", self.html)

    def test_fusion_labels_with_abbreviations(self):
        for text in ("Diameter", "Number of flutes", "Flute length", "Shoulder length", "Shoulder diameter",
                     "Shaft diameter", "Length below holder", "Corner radius", "Helix angle",
                     "Overall length", "Taper angle", "Tip diameter", "Thread pitch"):
            self.assertIn(text, self.html, text)
        for abbr in ("DC", "NOF", "LCF", "SFDM", "LB", "RE", "OAL", "TA", "TP"):
            self.assertRegex(self.html, r'class="abbr">[^<]*\b%s\b' % abbr, abbr)

    def test_more_is_collapsed_by_default_and_remembered_safely(self):
        tag = re.search(r'<div id="toolMoreFields"[^>]*>', self.html).group(0)
        self.assertIn("display: none", tag)
        self.assertIn('aria-expanded="false"', re.search(r'<button[^>]*id="toolMoreToggle"[^>]*>', self.html).group(0))
        # localStorage access for the toggle is wrapped in try/catch
        js = "\n".join(_scripts(self.html))
        fn = _extract_function(js, "toggleToolMore")
        self.assertIn("try {", fn)
        self.assertIn("catch", fn)
        self.assertIn("toolwiz_tool_more", js)

    def test_corner_radius_group_hidden_until_geometry_needs_it(self):
        tag = re.search(r'<div[^>]*id="cornerRadiusGroup"[^>]*>', self.html).group(0)
        self.assertIn("display: none", tag)
        js = "\n".join(_scripts(self.html))
        self.assertIn("geo === 'Ball'", _extract_function(js, "updateGeometryDisplay"))

    def test_stickout_default_unchanged(self):
        self.assertIn('id="stickout_val" class="tool-dialog-input" step="0.001" value="1.575"', self.html)

    def test_auto_badges_for_shoulder_and_shaft(self):
        for key in ("shoulderLength", "shoulderDiameter", "shaftDiameter"):
            self.assertIn('id="badge_%s"' % key, self.html)
            self.assertIn("%s: true" % key, self.html)

    def test_calculate_sends_fusion_tool_and_legacy_keys(self):
        js = "\n".join(_scripts(self.html))
        calc = _extract_function(js, "calculate")
        for key in ("fusion_tool:", "diameter:", "flutes:", "fluteLength:", "stickout:", "shankDiameter:",
                    "cornerRadius:", "helixAngle:", "hasRelievedNeck:", "neckDiameter:", "neckLength:"):
            self.assertIn(key, calc, key)
        build = _extract_function(js, "buildFusionTool")
        for key in ("'DC'", "'NOF'", "'LCF'", "'shoulder-length'", "'shoulder-diameter'", "'SFDM'", "'LB'",
                    "'OAL'", "'TA'", "'tip-diameter'", "'RE'", "'TP'"):
            self.assertIn(key, build, key)


@unittest.skipUnless(NODE, "node is not installed")
class TestToolPanelScript(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        client = app_module.app.test_client()
        client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "web"
        cls.html = client.get("/").get_data(as_text=True)
        cls.js = "\n".join(_scripts(cls.html))
        cls.tmp = tempfile.TemporaryDirectory()
        cls.addClassCleanup(cls.tmp.cleanup)

    def _run_node(self, source):
        path = os.path.join(self.tmp.name, "snippet.js")
        with open(path, "w", encoding="utf-8") as f:
            f.write(source)
        r = subprocess.run([NODE, path], capture_output=True, text=True, timeout=60)
        self.assertEqual(r.returncode, 0, r.stderr)
        return r.stdout

    def test_inline_script_passes_node_check(self):
        path = os.path.join(self.tmp.name, "index_inline.js")
        with open(path, "w", encoding="utf-8") as f:
            f.write(self.js)
        r = subprocess.run([NODE, "--check", path], capture_output=True, text=True, timeout=60)
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_old_neck_shank_state_migrates_to_new_fields(self):
        src = _extract_function(self.js, "migrateToolFieldsState")
        out = self._run_node(src + """
const old = {diameter: '0.5', hasRelievedNeck: true, shankDiameter: '0.375', neckDiameter: '0.3', neckLength: '1.6'};
const a = migrateToolFieldsState(old);
const plain = migrateToolFieldsState({diameter: '0.5', hasRelievedNeck: false, shankDiameter: '0.5', neckDiameter: '0.125', neckLength: '0.5'});
const fresh = migrateToolFieldsState({diameter: '0.5', shaftDiameter: '0.4', shankDiameter: '0.25'});
console.log(JSON.stringify({a, plain, fresh, none: migrateToolFieldsState(null)}));
""")
        res = json.loads(out)
        self.assertEqual(res["a"]["fields"], {"shaftDiameter": 0.375, "shoulderDiameter": 0.3, "shoulderLength": 1.6})
        self.assertEqual(set(res["a"]["userEdited"]), {"shaftDiameter", "shoulderDiameter", "shoulderLength"})
        # No relieved neck and a shank equal to the diameter: nothing to carry over, everything stays Auto.
        self.assertEqual(res["plain"]["fields"], {})
        # A state that already has the new fields is left alone.
        self.assertEqual(res["fresh"]["fields"], {})
        self.assertEqual(res["none"]["fields"], {})

    def test_fusion_type_mapping(self):
        parts = [_extract_const(self.js, n) for n in
                 ("FUSION_TYPE_BY_GEOMETRY", "FUSION_TYPE_BY_TOOL_TYPE", "UI_BY_FUSION_TYPE")]
        parts.append(_extract_function(self.js, "fusionTypeFor"))
        out = self._run_node("\n".join(parts) + """
console.log(JSON.stringify({
  flat: fusionTypeFor('End Mill', 'Square', 0), ball: fusionTypeFor('End Mill', 'Ball', 0),
  bull: fusionTypeFor('End Mill', 'Radiused', 0), tapered: fusionTypeFor('End Mill', 'Square', 5),
  chamfer: fusionTypeFor('End Mill', 'V-Bit', 0), slot: fusionTypeFor('End Mill', 'T-Slot', 0),
  dove: fusionTypeFor('End Mill', 'Dovetail', 0), lolli: fusionTypeFor('End Mill', 'Lollipop', 0),
  drill: fusionTypeFor('Drill', 'Drill', 0), spot: fusionTypeFor('Spot Drill', 'Spot Drill', 0),
  reamer: fusionTypeFor('Reamer', 'Reamer', 0), tap: fusionTypeFor('Tap', 'form', 0),
  thread: fusionTypeFor('Thread Mill', 'Thread Mill', 0),
  back: UI_BY_FUSION_TYPE['ball end mill'], backTap: UI_BY_FUSION_TYPE['tap left hand']
}));""")
        m = json.loads(out)
        self.assertEqual(m["flat"], "flat end mill")
        self.assertEqual(m["ball"], "ball end mill")
        self.assertEqual(m["bull"], "bull nose end mill")
        self.assertEqual(m["tapered"], "tapered mill")
        self.assertEqual(m["chamfer"], "chamfer mill")
        self.assertEqual(m["slot"], "slot mill")
        self.assertEqual(m["dove"], "dovetail mill")
        self.assertEqual(m["lolli"], "lollipop mill")
        self.assertEqual(m["drill"], "drill")
        self.assertEqual(m["spot"], "spot drill")
        self.assertEqual(m["reamer"], "reamer")
        self.assertEqual(m["tap"], "tap right hand")
        self.assertEqual(m["thread"], "thread mill")
        self.assertEqual(m["back"], ["End Mill", "Ball"])
        self.assertEqual(m["backTap"], ["Tap", None])

    def test_profile_drawing_uses_one_vertical_scale(self):
        funcs = "\n".join(_extract_function(self.js, n) for n in
                          ("toolSvgDefs", "toolHolderSvg", "renderProfileSvg"))
        out = self._run_node("let isMetric = false;\n" + funcs + """
const segs = [
  {kind: 'flute', start: 0, end: 1.5, d0: 0.5, d1: 0.5, fluted: true},
  {kind: 'neck', start: 1.5, end: 2.2, d0: 0.3, d1: 0.3, fluted: false},
  {kind: 'shank', start: 2.2, end: 3.0, d0: 0.5, d1: 0.5, fluted: false}];
const svg = renderProfileSvg({segs, stickIn: 3.0, cx: 240, yCollet: 38, yTip: 245,
  isBall: false, isLollipop: false, isRadiused: false, isChamfer: false, isDrill: false, isTap: false, isFormTool: false,
  reIn: 0, depthIn: 0.25, widthIn: 0.1, stickVal: 3.0, diaVal: 0.5, depthVal: 0.25, widthVal: 0.1, unit: 'in',
  effNeckDia: 0.3, maxReach: 0.1, shoulderIn: 2.2, isNeckCollision: false, isColletCollision: false});
const firstY = cls => { const m = svg.match(new RegExp('class="' + cls + '"[^>]*>\\\\s*<path d="M [-0-9.e]+ ([-0-9.e]+)')); return m ? parseFloat(m[1]) : null; };
console.log(JSON.stringify({flute: firstY('cutting-head'), neck: firstY('tool-neck'), shank: firstY('tool-shank'),
  paths: (svg.match(/<path d="M/g) || []).length}));
""")
        r = json.loads(out)
        ppi = (245 - 38) / 3.0
        self.assertAlmostEqual(r["flute"], 245 - 1.5 * ppi, places=3)
        self.assertAlmostEqual(r["neck"], 245 - 2.2 * ppi, places=3)
        self.assertAlmostEqual(r["shank"], 245 - 3.0 * ppi, places=3)
        self.assertGreaterEqual(r["paths"], 3)


if __name__ == "__main__":
    unittest.main()
