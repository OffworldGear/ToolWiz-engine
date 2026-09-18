import unittest
import re
import os


class TestAutoSetIndicatorProtocol(unittest.TestCase):
    """Automated Testing Protocol (TP-01 to TP-10) for ToolWiz Auto-Set indicators."""

    @classmethod
    def setUpClass(cls):
        template_path = os.path.join(os.path.dirname(__file__), "..", "templates", "index.html")
        with open(template_path, "r", encoding="utf-8") as f:
            cls.html_content = f.read()

    def test_tp01_initial_state_defaults(self):
        """TP-01: Verify default parameters are registered in autoSetTracker."""
        # Check autoSetTracker initialization
        self.assertIn("fluteLength: true", self.html_content)
        self.assertIn("flutes: true", self.html_content)
        self.assertIn("stickout: true", self.html_content)
        self.assertIn("cornerRadius: true", self.html_content)
        # Cut depth & width should start manual/off until auto-set dials is invoked
        self.assertIn("cutDepth: false", self.html_content)
        self.assertIn("cutWidth: false", self.html_content)

    def test_tp02_confirm_individual_badge(self):
        """TP-02: confirmAutoSet function exists and sets tracker to false with checkmark animation."""
        self.assertIn("function confirmAutoSet(param)", self.html_content)
        self.assertIn("autoSetTracker[param] = false", self.html_content)
        self.assertIn("badge.classList.add('confirmed')", self.html_content)
        self.assertIn("<span class=\"pulse-dot\"></span>\u2713", self.html_content)

    def test_tp03_confirm_all_button(self):
        """TP-03: confirmAllAutoSet iterates all keys in autoSetTracker and turns them false."""
        self.assertIn("function confirmAllAutoSet()", self.html_content)
        self.assertIn("for (const key in autoSetTracker)", self.html_content)
        self.assertIn("autoSetTracker[key] = false", self.html_content)

    def test_tp04_manual_typing_triggers_mark_manual_edit(self):
        """TP-04: Typing in inputs calls markManualEdit to dismiss auto badge."""
        # fluteLength input has markManualEdit
        self.assertIn('oninput="markManualEdit(\'fluteLength\')', self.html_content)
        # flutes_val has markManualEdit
        self.assertIn('oninput="markManualEdit(\'flutes\')', self.html_content)
        # stickout_val has markManualEdit
        self.assertIn('oninput="markManualEdit(\'stickout\')', self.html_content)

    def test_tp05_ratio_buttons_mark_manual_not_auto(self):
        """TP-05: Clicking 3xD, 4xD, 5xD ratio buttons marks parameters as manual user choice (false)."""
        # Ensure setFluteRatio marks fluteLength and stickout as false
        flute_ratio_func = re.search(r"function setFluteRatio\(ratio\)\s*\{([\s\S]*?)\n\s*function", self.html_content)
        self.assertIsNotNone(flute_ratio_func, "setFluteRatio function must be present")
        body = flute_ratio_func.group(1)
        self.assertIn("autoSetTracker.fluteLength = false;", body, "3xD/4xD/5xD must NOT reset fluteLength to auto")
        self.assertIn("autoSetTracker.stickout = false;", body, "3xD/4xD/5xD must NOT reset stickout to auto")

    def test_tp06_datalist_selection_triggers_onchange(self):
        """TP-06: fluteLength input includes onchange handler for datalist dropdown picks."""
        input_match = re.search(r'<input[^>]+id="fluteLength"[^>]*>', self.html_content)
        self.assertIsNotNone(input_match)
        tag = input_match.group(0)
        self.assertIn('onchange="markManualEdit(\'fluteLength\')', tag, "fluteLength must have onchange handler for datalist")

    def test_tp07_out_of_spec_respects_manual_user_choice(self):
        """TP-07: checkOutOfSpecGeometry does NOT overwrite user-edited flute length."""
        spec_func = re.search(r"function checkOutOfSpecGeometry\(newDia\)\s*\{([\s\S]*?)\n\s*function", self.html_content)
        self.assertIsNotNone(spec_func)
        body = spec_func.group(1)
        self.assertIn("isFluteAuto", body, "Must check if fluteLength is auto-set before overwriting")
        self.assertIn("isStickAuto", body, "Must check if stickout is auto-set before overwriting")

    def test_tp08_apply_recommendations_respects_manual_stickout(self):
        """TP-08: applyRecommendations only tames stickout if it was on auto-set."""
        rec_func = re.search(r"function applyRecommendations\(\)\s*\{([\s\S]*?)\n\s*function", self.html_content)
        self.assertIsNotNone(rec_func)
        body = rec_func.group(1)
        self.assertIn("autoSetTracker.stickout &&", body, "applyRecommendations must only tame auto-set stickout")

    def test_tp09_state_persistence_tracking(self):
        """TP-09: saveState and loadState preserve userEdited overrides across sessions."""
        self.assertIn("userEdited[key] = true", self.html_content)
        self.assertIn("if (state.userEdited && typeof state.userEdited === 'object')", self.html_content)
        self.assertIn("autoSetTracker[key] = false", self.html_content)


if __name__ == "__main__":
    unittest.main()
