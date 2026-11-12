"""Pure helpers of the Fusion add-in (ToolWizFusionAddin/twlogic.py): no Fusion needed."""
import importlib.util
import os
import unittest

# Loaded by path (the add-in folder also holds a json_mutator.py that must not shadow the server's).
_spec = importlib.util.spec_from_file_location(
    "twlogic_under_test", os.path.join(os.path.dirname(__file__), "..", "ToolWizFusionAddin", "twlogic.py"))
t = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(t)


class TestToolHelpers(unittest.TestCase):
    def test_runout_per_tool_and_default(self):
        self.assertEqual(t.tool_runout_in({}), (0.0002, "default"))
        self.assertEqual(t.tool_runout_in({"toolwiz": {"runout_in": 0.0001}}), (0.0001, "tool"))
        v, src = t.tool_runout_in({"unit": "millimeters", "toolwiz": {"runout": 0.005}})
        self.assertAlmostEqual(v, 0.005 / 25.4)
        self.assertEqual(src, "tool")
        self.assertEqual(t.tool_runout_in({"toolwiz": {"runout_in": 5.0}})[1], "default")   # implausible

    def test_parse_runout_text(self):
        self.assertAlmostEqual(t.parse_runout_text("0.005 mm"), 0.005 / 25.4)
        self.assertEqual(t.parse_runout_text(".0003"), 0.0003)
        self.assertIsNone(t.parse_runout_text("", None))
        with self.assertRaises(ValueError):
            t.parse_runout_text("lots")

    def test_carbide_from_tool_material(self):
        self.assertTrue(t.tool_is_carbide({"BMC": "carbide"}))
        self.assertFalse(t.tool_is_carbide({"BMC": "hss"}))
        self.assertFalse(t.tool_is_carbide({"description": "1/4 cobalt end mill"}))
        self.assertTrue(t.tool_is_carbide({"description": "6 mm solid carbide T slot"}))

    def test_fusion_tool_keeps_shaft_holder_description(self):
        ft = t.fusion_tool_for_server({"type": "slot mill", "unit": "millimeters", "geometry": {"DC": 6}, "description": "T slot",
                                       "shaft": {"segments": [{"height": 1}]}, "holder": {"description": "ER20"}, "junk": 1})
        self.assertEqual(set(ft), {"type", "unit", "geometry", "description", "shaft", "holder"})
        self.assertIsNone(t.fusion_tool_for_server({"type": "x"}))

    def test_fusion_tool_carries_the_vendor_as_brand(self):
        """Owner decisions 2026-11-12: the server's vendor guardrail uses the tool's brand (Fusion's `vendor`)."""
        ft = t.fusion_tool_for_server({"type": "flat end mill", "unit": "inches", "geometry": {"DC": 0.25}, "vendor": " Harvey Tool "})
        self.assertEqual(ft["vendor"], "Harvey Tool")
        self.assertNotIn("vendor", t.fusion_tool_for_server({"type": "x", "geometry": {"DC": 1}, "vendor": "  "}))
        self.assertEqual(t.tool_vendor({"vendor": "Klot (Amazon Ebay)"}), "Klot (Amazon Ebay)")
        self.assertIsNone(t.tool_vendor({}))


class TestAutoSetReport(unittest.TestCase):
    CALC = {"rpm": 9000, "engagement_source": "user", "engagement_doc": 0.2, "engagement_woc": 0.05, "doc": 0.3, "woc": 0.1,
            "flutes_cutting": 2, "runout_regime": "reduced_flutes", "tir_all_flutes_in": 0.00008, "runout_ratio": 0.8,
            "recommended_radial_stock_in": 0.004, "recommended_axial_stock_in": 0.002,
            "holder_advice": {"class": "precision", "required_tir_in": 0.0001, "recommended": ["shrink fit"], "avoid": ["ER"], "reason": "r"},
            "tool_advice": [{"vendor": "Harvey Tool", "series": "S1", "expected_gain": "+40% MRR", "why": "w"}],
            "alerts": [{"title": "Runout vs Chip Load", "message": "m"}], "feasible": True}

    def test_sections(self):
        txt = t.format_advisor_sections(self.CALC, flutes_total=4, unit="in")
        for s in ("operation's own stepdown", "ToolWiz recommends ADOC 0.3000", "Flutes cutting: 2 of 4", "reduced flutes",
                  "0.00008", "radial 0.0040 in, axial 0.0020 in", "Holder: precision class", "Recommended: shrink fit",
                  "Harvey Tool S1", "Warning: Runout vs Chip Load"):
            self.assertIn(s, txt)

    def test_metric_units(self):
        self.assertIn("0.102 mm", t.format_advisor_sections(self.CALC, 4, "mm"))

    def test_critical_detection_and_confirmation(self):
        self.assertEqual(t.critical_findings(self.CALC), [])
        self.assertEqual(t.format_critical_confirmation(self.CALC), "")
        calc = dict(self.CALC, alerts=[{"title": "Holder Clearance / Stickout Too Short", "message": "collision"}],
                    oversight={"findings": [{"severity": "STOP", "title": "Too deep", "detail": "d", "recommendation": "r"},
                                            {"severity": "CAUTION", "title": "c", "detail": "x"}]})
        crit = t.critical_findings(calc)
        self.assertEqual({c["title"] for c in crit}, {"Holder Clearance / Stickout Too Short", "Too deep"})
        self.assertIn("Apply anyway?", t.format_critical_confirmation(calc))
        # an explicit type from the server wins over the title heuristic
        self.assertEqual(t.alert_level({"title": "Infeasible Setup", "type": "warning"}), "warning")
        self.assertTrue(t.critical_findings({"feasible": False, "limited_by": "C3"}))

    def test_tslot_block_has_passes_zsteps_axial_feed_and_provisional_warning(self):
        ts = {"operation": "axial_step", "radial_passes": 2, "radial_depth_per_pass_in": 0.015, "radial_depth_total_in": 0.03,
              "axial_plan": {"cuts": 3, "z_step_in": 0.02, "method": "steps"}, "axial_feed_ipm": 1.5, "lateral_feed_ipm": 2.2,
              "provisional": ["neck_diameter", "reach"], "warnings": [{"title": "Chip evacuation", "message": "air", "type": "info"}]}
        txt = t.format_advisor_sections({"tslot": ts}, 4, "in")
        for s in ("Radial passes: 2 x 0.0150", "Z: 3 cut(s), step 0.0200", "Axial (Z) feed: 1.5 IPM", "provisional geometry", "Note: Chip evacuation"):
            self.assertIn(s, txt)

    def test_engagement_fields(self):
        self.assertEqual(t.engagement_fields(0.1, 0.05, True), {"stepdown": 0.1, "stepover": 0.05})
        self.assertEqual(t.engagement_fields(0.1, 0.05, False), {})
        self.assertEqual(t.engagement_fields(0, 0.05, True), {"stepover": 0.05})


class TestFinishModes(unittest.TestCase):
    def test_strategy_classes(self):
        for s in ("Adaptive Roughing", "Roughing", "Slotting"):
            self.assertTrue(t.is_roughing_strategy(s), s)
            self.assertFalse(t.is_finishing_strategy(s), s)
        for s in ("Finishing", "3D Contouring / Scallop Finishing", "Floor Finishing (Skim)"):
            self.assertTrue(t.is_finishing_strategy(s), s)
            self.assertFalse(t.is_roughing_strategy(s), s)

    def test_fields_per_mode(self):
        self.assertEqual(t.finish_fields("cleanup", 16, 0.001), {"finishMode": "cleanup"})
        self.assertEqual(t.finish_fields("surface", 16, 0.001), {"finishMode": "surface", "targetRa": 16.0})
        self.assertEqual(t.finish_fields("accuracy", 16, 0.0003), {"finishMode": "accuracy", "wallTolerance": 0.0003})
        self.assertEqual(t.finish_fields("Surface finish (target Ra)")["targetRa"], 32.0)
        self.assertEqual(t.finish_fields("accuracy")["wallTolerance"], 0.0002)

    def test_ra_units(self):
        self.assertAlmostEqual(t.parse_ra_text("0.8 um"), 31.496, 2)
        self.assertEqual(t.parse_ra_text("32"), 32.0)
        self.assertAlmostEqual(t.parse_ra_text("0.8", "mm"), 31.496, 2)   # bare number: um in a metric document
        self.assertEqual(t.ra_uin_to_text(32, "in"), "32 uin")
        self.assertEqual(t.ra_uin_to_text(32, "mm"), "0.81 um")
        with self.assertRaises(ValueError):
            t.parse_ra_text("smooth")

    def test_finish_block_and_absence(self):
        self.assertEqual(t.format_finish_lines(None), [])
        fin = {"mode": "surface", "predicted_ra_uin": 28, "target_ra_uin": 32, "predicted_cusp_in": 0.0001,
               "predicted_wall_error_in": 0.0004, "wall_tolerance_in": 0.001, "limited_by": ["feed marks"], "advice": ["Climb mill"]}
        txt = "\n".join(t.format_finish_lines(fin, "in"))
        for s in ("surface", "predicted Ra 28 uin (target 32 uin)", "cusp height 0.000100", "predicted wall error 0.00040", "feed marks", "Climb mill"):
            self.assertIn(s, txt)


class TestAdvisor(unittest.TestCase):
    RES = {"success": True, "operations": [
        {"op_id": "S > A", "name": "A", "strategy": "adaptive", "findings": [
            {"severity": "CAUTION", "title": "Stepdown high", "detail": "d",
             "recommendation": {"text": "lower", "params": {"maximumStepdown": "0.1 in"}}},
            {"severity": "STOP", "title": "Feed too high", "detail": "d2", "recommendation": "slow down"}]},
        {"op_id": "S > B", "name": "B", "strategy": "contour", "findings": []}],
        "setup_findings": [], "strategy_suggestions": [
            {"title": "Tab milling slot", "time_saved_min": 4.2, "apply": [{"op_id": "S > B", "params": {"tool_feedCutting": "30 in/min"}}]}],
        "narrative": "Cut at 9000 rpm.", "narrative_check": {"ok": True, "rejected_numbers": []}}

    def test_parse_and_summary(self):
        p = t.parse_advisor_response(self.RES)
        self.assertTrue(p["ok"])
        self.assertTrue(p["narrative_verified"])
        txt = t.format_advisor_summary(p)
        self.assertIn("1 STOP, 1 CAUTION", txt)
        self.assertLess(txt.index("Feed too high"), txt.index("Stepdown high"))   # STOP first
        self.assertIn("numbers verified", txt)
        self.assertIn("saves about 4.2 min", txt)

    def test_narrative_not_verified_unless_check_ok(self):
        for chk in ({}, {"ok": False, "rejected_numbers": [123]}, None):
            res = dict(self.RES, narrative_check=chk)
            p = t.parse_advisor_response(res)
            self.assertFalse(p["narrative_verified"])
            self.assertNotIn("numbers verified", t.format_advisor_summary(p))
            self.assertIn("NOT verified", t.format_advisor_summary(p))

    def test_recommendations_and_selection(self):
        p = t.parse_advisor_response(self.RES)
        recs = t.extract_recommendations(p)
        self.assertEqual(len(recs), 2)    # the finding without parameters is not applicable
        merged, conflicts = t.merge_selected_changes(recs, {r["id"] for r in recs})
        self.assertEqual(merged, {"S > A": {"maximumStepdown": "0.1 in"}, "S > B": {"tool_feedCutting": "30 in/min"}})
        self.assertEqual(conflicts, [])
        lines = t.summarize_changes(merged, {"S > A": {"maximumStepdown": "0.25 in"}})
        self.assertIn("S > A: maximumStepdown: 0.25 in -> 0.1 in", lines)
        only, _ = t.merge_selected_changes(recs, {recs[0]["id"]})
        self.assertEqual(list(only), ["S > A"])

    def test_apply_plan_gives_recommended_and_keep_engagement_choices(self):
        res = {"success": True, "operations": [
            {"op_id": "S > A", "name": "A", "findings": [], "apply_plan": {
                "recommended": {"tool_spindleSpeed": "11522 rpm", "maximumStepdown": "0.02313 in"},
                "keep_engagement": {"tool_spindleSpeed": "9000 rpm"}}},
            {"op_id": "S > B", "name": "B", "findings": [], "apply_plan": None}]}
        recs = t.extract_recommendations(t.parse_advisor_response(res))
        self.assertEqual([r["kind"] for r in recs], ["apply_plan", "apply_plan"])
        self.assertEqual(recs[0]["changes"], {"S > A": {"tool_spindleSpeed": "11522 rpm", "maximumStepdown": "0.02313 in"}})
        self.assertIn("current stepdown/stepover", recs[1]["title"])
        merged, conflicts = t.merge_selected_changes(recs, {recs[0]["id"], recs[1]["id"]})
        self.assertTrue(conflicts)     # the two choices disagree about the speed: reported, later wins

    def test_apply_requests_are_per_op_with_wait(self):
        reqs = t.build_apply_requests({"S > A": {"maximumStepdown": "0.1 in"}, "S > B": {"stockToLeave": "0.003 in"}}, "why", 30)
        self.assertEqual(reqs[0], {"op_id": "S > A", "params": {"maximumStepdown": "0.1 in"}, "reason": "why", "wait": 30})
        self.assertEqual(len(reqs), 2)

    def test_apply_result_shapes(self):
        r = t.normalize_apply_result({"success": True, "ok": True, "accepted": {}, "applied": {"tool_spindleSpeed": {"old": "12000 rpm", "new": "11522 rpm"}},
                                      "skipped": {"optimalLoad": "operation has no such parameter"}, "error": None})
        self.assertTrue(r["ok"])
        self.assertEqual(r["applied"], [{"param": "tool_spindleSpeed", "old": "12000 rpm", "new": "11522 rpm"}])
        self.assertEqual(r["skipped"][0]["param"], "optimalLoad")
        txt = t.format_apply_results([dict(r, op_id="S > A")])
        self.assertIn("tool_spindleSpeed: 12000 rpm -> 11522 rpm", txt)
        self.assertIn("skipped optimalLoad", txt)
        bad = t.normalize_apply_result({"success": False, "error": "x", "rejected": {"stockToLeave": "not recommended"}})
        self.assertFalse(bad["ok"])
        self.assertEqual(bad["error"], "x")
        self.assertIn("not recommended", t.normalize_apply_result({"success": False, "rejected": {"stockToLeave": "not recommended"}})["error"])
        self.assertFalse(t.normalize_apply_result({"success": True, "ok": False, "error": "declined by the user"})["ok"])


class TestParameterValidation(unittest.TestCase):
    def test_allowed_and_rejected(self):
        ok, skipped = t.validate_parameter_changes({"maximumStepdown": "0.1 in", "tool_number": "5", "stockToLeave": "",
                                                    "optimalLoad": "0.05 in $(x)", "useStockToLeave": "true",
                                                    "tabWidth": "0.1 in"})
        self.assertEqual(set(ok), {"maximumStepdown", "tabWidth"})
        self.assertEqual(len(t.ALLOWED_PARAMS), 16)
        reasons = {s["param"]: s["reason"] for s in skipped}
        self.assertIn("allowed list", reasons["tool_number"])
        self.assertIn("allowed list", reasons["useStockToLeave"])
        self.assertIn("empty", reasons["stockToLeave"])


class TestPlannerLibraryAudit(unittest.TestCase):
    def test_candidate_from_fusion_metric(self):
        c = t.tool_candidate_from_fusion({"unit": "millimeters", "geometry": {"DC": 3.175, "NOF": 2, "LCF": 9.525, "SFDM": 3.175, "LB": 15.24}})
        self.assertEqual(c, {"diameter": 0.125, "flutes": 2, "flute_length": 0.375, "shank_diameter": 0.125, "stickout": 0.6})
        self.assertIsNone(t.tool_candidate_from_fusion({"geometry": {}}))

    def test_feature_requests(self):
        f = t.strategy_feature_from_inputs("profile_cutout", 0.25, 12.0, tabs={"count": 4, "width": 0.1, "height": 0.04})
        self.assertEqual(f["tabs"]["count"], 4)
        self.assertEqual(t.strategy_feature_from_inputs("tslot", None, 2.0, slot_height_in=0.08, radial_depth_in=0.03)["radial_depth"], 0.03)
        with self.assertRaises(ValueError):
            t.strategy_feature_from_inputs("nope", 1, 1)

    def test_strategy_text_has_table_recommendation_and_hints(self):
        res = {"options": [{"name": "contour_slot A", "levels": 3, "ap": 0.08, "ae": 0.125, "rpm": 16000, "feed_ipm": 13.5,
                            "cycle_time_min": 2.63, "relative_tool_life": 10, "tool_wear_per_part": 1.0, "risks": ["holder"],
                            "fusion_hints": {"maximumStepdown": "0.08 in", "tabs": {"useTabs": True, "tabHeight": "0.04 in"}}}],
               "recommended": "contour_slot A", "reasoning": ["fastest"], "tab_advice": ["Stagger the tabs"], "assumptions": ["a"]}
        txt = t.format_strategy_result(res)
        for s in ("* contour_slot A", "2.63", "RECOMMENDED: contour_slot A", "tabs.useTabs: True", "maximumStepdown: 0.08 in", "risk: holder", "Tabs: Stagger"):
            self.assertIn(s, txt)

    def test_harvest_and_build_request(self):
        e = t.harvest_entry("Local: X", "local", [{"guid": "a"}, {"guid": "a"}, {"guid": "b"}, {}])
        self.assertEqual(len(e["tools"]), 3)     # duplicate guid dropped, guid-less kept
        self.assertIsNone(t.harvest_entry("E", "local", []))
        body = t.build_sets_request([e], ["non_ferrous"], [], ["Roughing"], 50, model="v2", runout=0.0002, tool_filter={"types": ["slot mill"]})
        self.assertEqual(body["sets"], ["non_ferrous"])
        self.assertNotIn("materials", body)
        self.assertEqual(body["filter"], {"types": ["slot mill"]})
        self.assertEqual(body["model"], "v2")

    def test_build_progress_and_result(self):
        pct, txt = t.format_build_progress({"phase": "generating", "progress": {"tools_done": 7, "tools_total": 22, "current_tool": "1/4 flat", "percent": 31.8}})
        self.assertEqual(pct, 31.8)
        self.assertIn("7 of 22", txt)
        res = {"merge": {"tools_in": 27, "tools_out": 26, "duplicates_merged": 1, "repaired_tools": 9},
               "libraries": [{"name": "ToolWiz - Non-ferrous", "tool_count": 22, "preset_count": 599, "toolwiz_preset_count": 280,
                              "audit": {"summary": {"toolwiz_STOP": 0, "CAUTION": 231, "INFO": 70}, "cautions_by_code": {"chip_load_low": 69},
                                        "dropped_presets": [{"tool": "T1", "preset": "P", "message": "too high"}]},
                              "skipped": [{"tool": "Probe", "type": "probe", "reason": "no presets for probes"}]}]}
        txt = t.format_build_result(res)
        for s in ("Merged 27 tools into 26", "ToolWiz - Non-ferrous", "0 STOP", "chip_load_low: 69", "dropped (audit STOP): T1 / P", "no presets for probes"):
            self.assertIn(s, txt)

    def test_audit_report_orders_tools_by_worst_finding(self):
        rep = {"summary": {"STOP": 1, "CAUTION": 1, "INFO": 0, "tools": 2, "presets": 3},
               "tools": [{"index": 0, "description": "A", "findings": [{"severity": "CAUTION", "message": "c"}]},
                         {"index": 1, "description": "B", "findings": [{"severity": "STOP", "message": "s", "preset": "P1"}]},
                         {"index": 2, "description": "C", "findings": []}]}
        txt, jumps = t.format_audit_report(rep)
        self.assertEqual([j[1] for j in jumps], [1, 0])
        self.assertIn("[STOP] s [preset: P1]", txt)

    def test_stock_consistency(self):
        ops = [{"label": "R", "is_finishing": False, "rad_in": 0.0002}, {"label": "F", "is_finishing": True, "rad_in": -0.001, "woc_in": 0.01}]
        self.assertIn("cannot true up", t.stock_consistency_notes(ops)["F"][0])
        ops[0]["rad_in"] = 0.004
        self.assertIn("heavier cut", t.stock_consistency_notes(ops)["F"][0])
        ops[0]["rad_in"] = 0.02
        self.assertEqual(t.stock_consistency_notes(ops), {})


if __name__ == "__main__":
    unittest.main()
