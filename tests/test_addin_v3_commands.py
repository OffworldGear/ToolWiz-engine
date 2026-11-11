"""v3 add-in behaviour with Fusion mocked: auto-setter payload and confirmations, bridge action, harvest, scan,
library import by name, setup advisor apply, master library flow, roughing stock."""
import json
import os
import unittest
from types import SimpleNamespace
from unittest.mock import MagicMock, patch

from test_addin_audit import AuditBase, make_op, make_tool
from test_addin_common import param, ParamsByName


def cam_with(a, ops_by_setup):
    """Make the add-in's active document a CAM product with the given {setup: [ops]}."""
    setups = [SimpleNamespace(name=s, allOperations=ops) for s, ops in ops_by_setup.items()]
    for s in setups:
        for op in s.allOperations:
            op.parent = s
    cam = SimpleNamespace(setups=setups, documentToolLibrary=None)
    a.adsk.cam.CAM.cast.return_value = cam
    return cam


class TestApplyOperationParameters(AuditBase):
    def setUp(self):
        super().setUp()
        self.params = {"maximumStepdown": param("0.25 in"), "stockToLeave": param("0 in"), "verticalStockToLeave": param("0 in"),
                       "tool_spindleSpeed": param("8000 rpm"), "useStockToLeave": param("false"), "simpleStockToLeave": param("true")}
        self.op = make_op("Adaptive1", params=self.params)
        cam_with(self.a, {"Setup1": [self.op]})
        self.yes = self.a.adsk.core.DialogResults.DialogYes
        self.no = self.a.adsk.core.DialogResults.DialogNo

    def call(self, params, answer=None, **kw):
        self.a.ui.messageBox.return_value = answer or self.yes
        return self.a.dispatch_bridge_action("apply_operation_parameters", dict(
            {"op_id": "Setup1 > Adaptive1", "reason": "ToolWiz setup advisor", "params": params}, **kw))

    def test_confirmed_apply_shows_old_and_new_audits_and_returns_dicts(self):
        r = self.call({"maximumStepdown": "0.1 in", "tool_spindleSpeed": "11522 rpm"})
        self.assertTrue(r["ok"])
        self.assertEqual(r["applied"]["maximumStepdown"], {"old": "0.25 in", "new": "0.1 in"})
        self.assertEqual(r["applied"]["tool_spindleSpeed"], {"old": "8000 rpm", "new": "11522 rpm"})
        self.assertEqual(r["skipped"], {})
        self.assertIsNone(r["error"])
        text = self.a.ui.messageBox.call_args[0][0]
        self.assertIn("maximumStepdown: 0.25 in -> 0.1 in", text)
        self.assertIn("tool_spindleSpeed: 8000 rpm -> 11522 rpm", text)
        self.assertIn("Setup1 > Adaptive1", text)
        self.assertIn("ToolWiz setup advisor", text)
        self.assertIn(self.a.adsk.core.MessageBoxButtonTypes.YesNoButtonType, self.a.ui.messageBox.call_args[0])
        ev = [e for e in self.entries() if e["event"] == "param_change"]
        self.assertEqual({e["param"] for e in ev}, {"maximumStepdown", "tool_spindleSpeed"})
        self.assertTrue(all(e["command"] == "apply_operation_parameters" for e in ev))
        revert = [f for f in os.listdir(self._tmp.name) if f.startswith("revert_")]
        with open(os.path.join(self._tmp.name, revert[0])) as f:
            self.assertEqual(json.load(f)["previous"]["maximumStepdown"], "0.25 in")

    def test_declined_writes_nothing_and_says_so(self):
        r = self.call({"maximumStepdown": "0.1 in"}, answer=self.no)
        self.assertFalse(r["ok"])
        self.assertEqual(r["error"], "declined by the user")
        self.assertEqual(r["applied"], {})
        self.assertEqual(self.params["maximumStepdown"].expression, "0.25 in")
        self.assertEqual([e for e in self.entries() if e["event"] == "param_change"], [])

    def test_allow_list_enforced_locally(self):
        r = self.call({"tool_number": "9", "useStockToLeave": "true", "maximumStepdown": "0.1 in", "stepover": "0.05 in $(x)"})
        self.assertEqual(set(r["applied"]), {"maximumStepdown"})
        self.assertIn("allowed list", r["skipped"]["tool_number"])
        self.assertIn("allowed list", r["skipped"]["useStockToLeave"])
        self.assertIn("unsupported characters", r["skipped"]["stepover"])
        self.assertEqual(self.params["useStockToLeave"].expression, "false")      # a requested gating write is refused
        only_bad = self.call({"tool_number": "9"})
        self.assertFalse(only_bad["ok"])
        self.assertEqual(only_bad["error"], "nothing to apply")

    def test_missing_parameter_is_skipped_not_failed(self):
        r = self.call({"maximumStepdown": "0.1 in", "tabWidth": "0.1 in"})
        self.assertTrue(r["ok"])
        self.assertEqual(r["skipped"]["tabWidth"], "operation has no such parameter")
        self.assertNotIn("tabWidth", self.a.ui.messageBox.call_args[0][0].split("Reason")[0].split("(skipped")[0])

    def test_stock_to_leave_switches_stock_on_and_says_it_is_audited(self):
        r = self.call({"stockToLeave": "0.003 in", "verticalStockToLeave": "0.002 in"})
        self.assertTrue(r["ok"])
        self.assertEqual(self.params["useStockToLeave"].expression, "true")
        self.assertEqual(self.params["simpleStockToLeave"].expression, "false")
        self.assertEqual(self.params["stockToLeave"].expression, "0.003 in")
        self.assertIn("useStockToLeave", {e["param"] for e in self.entries() if e["event"] == "param_change"})

    def test_unknown_operation(self):
        self.a.ui.messageBox.return_value = self.yes
        r = self.a.dispatch_bridge_action("apply_operation_parameters", {"op_id": "Nope > x", "params": {"maximumStepdown": "0.1 in"}})
        self.assertFalse(r["ok"])
        self.assertIn("not found", r["error"])
        self.a.ui.messageBox.assert_not_called()

    def test_disabled_parameter_skipped(self):
        self.params["maximumStepdown"].isEnabled = False
        r = self.call({"maximumStepdown": "0.1 in"})
        self.assertFalse(r["ok"])
        self.assertIn("disabled", r["skipped"]["maximumStepdown"])
        self.assertEqual(self.params["maximumStepdown"].expression, "0.25 in")

    def test_preapproved_in_advisor_dialog_does_not_prompt_twice(self):
        changes = {"Setup1 > Adaptive1": {"maximumStepdown": "0.1 in"}}
        self.a.preapprove_changes(changes)
        r = self.call({"maximumStepdown": "0.1 in"})
        self.assertTrue(r["ok"])
        self.a.ui.messageBox.assert_not_called()
        r = self.call({"maximumStepdown": "0.05 in"})        # a different value was never approved: asks
        self.assertEqual(self.a.ui.messageBox.call_count, 1)

    def test_fusion_rejecting_a_value_is_reported_not_raised(self):
        class Bad:
            isEnabled = True
            value = SimpleNamespace(value=1)

            @property
            def expression(self):
                return "1 in"

            @expression.setter
            def expression(self, v):
                raise RuntimeError("invalid expression")
        self.op.parameters = ParamsByName({"maximumStepdown": Bad()})
        r = self.call({"maximumStepdown": "0.1 in"})
        self.assertFalse(r["ok"])
        self.assertIn("Fusion rejected", r["skipped"]["maximumStepdown"])

    def test_duplicate_op_names_get_unique_ids(self):
        op2 = make_op("Adaptive1", params={"maximumStepdown": param("0.3 in")})
        cam_with(self.a, {"Setup1": [self.op, op2]})
        self.assertEqual([p for _, p, _ in self.a._iter_ops_unique()], ["Setup1 > Adaptive1", "Setup1 > Adaptive1 #2"])
        self.a.ui.messageBox.return_value = self.yes
        self.a.apply_operation_parameters("Setup1 > Adaptive1 #2", {"maximumStepdown": "0.05 in"})
        self.assertEqual(op2.parameters.itemByName("maximumStepdown").expression, "0.05 in")
        self.assertEqual(self.params["maximumStepdown"].expression, "0.25 in")


class TestAutoSetV3(AuditBase):
    GEO = {"diameter": 0.25, "flutes": 4, "fluteLength": 0.75, "shankDiameter": 0.25, "cornerRadius": 0.0, "stickout": 1.0,
           "geometry": "Square", "desc": "1/4 flat", "number": 5, "kind": "flat", "runout_in": 0.0001, "runout_source": "tool",
           "is_carbide": True, "raw_json": json.dumps({"type": "flat end mill", "unit": "inches", "description": "1/4 flat",
                                                       "geometry": {"DC": 0.25, "NOF": 4}, "holder": {"description": "ER16"}})}
    CALC = {"success": True, "rpm": 10000, "feed": 50.0, "doc": 0.2, "woc": 0.04, "sfm": 650, "ipt": 0.002,
            "engagement_source": "recommended", "engagement_doc": 0.2, "engagement_woc": 0.04}

    def run_it(self, calc=None, op_cut=(10000, 50.0, 0.3, 0.06), strategy="Adaptive Roughing", yes=True, **kw):
        a = self.a
        a.ui.messageBox.return_value = a.adsk.core.DialogResults.DialogYes if yes else a.adsk.core.DialogResults.DialogNo
        a._model_cache["model"] = "v2"
        with patch.object(a, "get_op_tool_info", return_value=(self.GEO, "s", [])), \
             patch.object(a, "_http_json", return_value=calc or self.CALC) as http, \
             patch.object(a, "_upsert_preset_in_place", return_value=(MagicMock(), False)) as up, \
             patch.object(a, "get_op_cut_params", return_value=op_cut), \
             patch.object(a, "op_supports_stock_to_leave", return_value=True), \
             patch.object(a, "apply_stock_to_op", return_value=[]) as stock:
            done = a.run_autoset(MagicMock(), "Setup > Op", "Aluminum - Wrought (6061)", "6061-T6", strategy, 50, None, "HP", "AlTiN", **kw)
        return done, http, up, stock

    def test_payload_has_model_runout_engagement_and_full_tool(self):
        done, http, _, _ = self.run_it()
        self.assertTrue(done)
        sent = http.call_args[0][1]
        self.assertEqual(sent["model"], "v2")
        self.assertEqual(sent["runout"], 0.0001)
        self.assertEqual((sent["stepdown"], sent["stepover"]), (0.3, 0.06))
        self.assertTrue(sent["isCarbide"])
        self.assertEqual(sent["fusion_tool"]["description"], "1/4 flat")
        self.assertEqual(sent["fusion_tool"]["holder"], {"description": "ER16"})

    def test_dialog_runout_overrides_and_recommendation_path_sends_no_engagement(self):
        _, http, _, _ = self.run_it(runout_in=0.0005, use_op_engagement=False)
        sent = http.call_args[0][1]
        self.assertEqual(sent["runout"], 0.0005)
        self.assertNotIn("stepdown", sent)
        self.assertNotIn("stepover", sent)

    def test_user_engagement_is_written_back_not_the_recommendation(self):
        calc = dict(self.CALC, engagement_source="user", engagement_doc=0.3, engagement_woc=0.06, doc=0.5, woc=0.1)
        _, _, up, _ = self.run_it(calc=calc)
        self.assertEqual(up.call_args.kwargs["doc_in"], 0.3)
        self.assertEqual(up.call_args.kwargs["woc_in"], 0.06)

    def test_finishing_sends_finish_fields_and_remembers_mode(self):
        _, http, _, _ = self.run_it(strategy="Finishing", finish_opts={"mode": "surface", "ra_uin": 16.0, "wall_in": 0.0005})
        sent = http.call_args[0][1]
        self.assertEqual((sent["finishMode"], sent["targetRa"]), ("surface", 16.0))
        self.assertNotIn("wallTolerance", sent)
        self.assertEqual(self.a._finish_prefs["Setup > Op"]["mode"], "surface")
        _, http, _, _ = self.run_it(strategy="Finishing", finish_opts={"mode": "accuracy", "ra_uin": 16.0, "wall_in": 0.0003})
        self.assertEqual(http.call_args[0][1]["wallTolerance"], 0.0003)

    def test_roughing_ignores_finish_options(self):
        _, http, _, _ = self.run_it(strategy="Adaptive Roughing", finish_opts={"mode": "surface", "ra_uin": 16.0, "wall_in": 0.001})
        self.assertNotIn("finishMode", http.call_args[0][1])

    def test_missing_finish_block_is_fine_and_present_block_is_shown(self):
        self.run_it(strategy="Finishing", finish_opts={"mode": "cleanup"})   # no `finish` in the response: no error
        calc = dict(self.CALC, finish={"mode": "cleanup", "predicted_ra_uin": 40, "advice": ["Spring pass"]})
        self.run_it(calc=calc, strategy="Finishing", finish_opts={"mode": "cleanup"})
        self.assertIn("predicted Ra 40 uin", self.a.ui.messageBox.call_args[0][0])
        self.assertIn("Spring pass", self.a.ui.messageBox.call_args[0][0])

    def test_critical_tip_needs_explicit_yes_before_writing(self):
        calc = dict(self.CALC, alerts=[{"title": "Holder Clearance / Stickout Too Short", "message": "collision risk"}])
        done, _, up, _ = self.run_it(calc=calc, yes=False)
        self.assertFalse(done)
        up.assert_not_called()
        self.assertIn("collision risk", self.a.ui.messageBox.call_args[0][0])
        self.assertIn("Apply anyway?", self.a.ui.messageBox.call_args[0][0])
        done, _, up, _ = self.run_it(calc=calc, yes=True)
        self.assertTrue(done)
        up.assert_called_once()

    def test_warnings_only_need_no_confirmation_and_are_listed(self):
        calc = dict(self.CALC, alerts=[{"title": "Runout vs Chip Load", "message": "one flute cuts"}], holder_advice={"class": "ultra", "recommended": ["shrink fit"]})
        done, _, up, _ = self.run_it(calc=calc)
        self.assertTrue(done)
        text = self.a.ui.messageBox.call_args[0][0]
        self.assertIn("Warning: Runout vs Chip Load", text)
        self.assertIn("Holder: ultra class", text)

    def test_recommended_stock_offered_and_applied_on_yes(self):
        calc = dict(self.CALC, recommended_radial_stock_in=0.004, recommended_axial_stock_in=0.002, flutes_cutting=2, runout_regime="reduced_flutes")
        done, _, _, stock = self.run_it(calc=calc, yes=True)
        self.assertTrue(done)
        stock.assert_called_once()
        self.assertEqual(stock.call_args[0][1:], ("0.0040 in", "0.0020 in"))
        text = self.a.ui.messageBox.call_args_list[0][0][0]
        self.assertIn("Apply the recommended stock to leave", text)
        self.assertIn("Flutes cutting: 2 of 4", text)

    def test_recommended_stock_declined_writes_nothing(self):
        calc = dict(self.CALC, recommended_radial_stock_in=0.004, recommended_axial_stock_in=0.002)
        _, _, _, stock = self.run_it(calc=calc, yes=False)
        stock.assert_not_called()

    def test_checkbox_applies_stock_without_asking(self):
        calc = dict(self.CALC, recommended_radial_stock_in=0.004, recommended_axial_stock_in=0.002)
        _, _, _, stock = self.run_it(calc=calc, apply_rec_stock=True)
        stock.assert_called_once()
        self.assertEqual(self.a.ui.messageBox.call_count, 1)
        self.assertIn("Stock to leave written", self.a.ui.messageBox.call_args[0][0])


class TestModelSetting(AuditBase):
    def test_reads_server_model_never_hardcodes(self):
        with patch.object(self.a, "_http_json", return_value={"success": True, "model": "v1", "source": "saved", "models": ["v1", "v2"]}):
            self.assertEqual(self.a.load_model_setting(), "v1")
        with patch.object(self.a, "_http_json", return_value={"success": True, "model": "v2", "source": "env"}):
            self.assertEqual(self.a.load_model_setting(), "v2")
        with patch.object(self.a, "_http_json", side_effect=OSError("offline")):
            self.assertEqual(self.a.load_model_setting(), "v2")      # last known
        self.a._model_cache["model"] = None
        with patch.object(self.a, "_http_json", side_effect=OSError("offline")):
            self.assertIsNone(self.a.load_model_setting())          # unknown: requests carry no model


class FakeLibs:
    """ToolLibraries stand-in: libraries keyed by (location, name)."""
    def __init__(self, libs=None):
        self.libs = dict(libs or {})
        self.updated, self.imported = [], []

    def urlByLocation(self, loc):
        return f"root:{loc}"

    def childAssetURLs(self, root):
        return [SimpleNamespace(leafName=n, root=r) for (r, n) in self.libs if r == root]

    def childFolderURLs(self, root):
        return []

    def toolLibraryAtURL(self, u):
        return self.libs.get((u.root, u.leafName))

    def updateToolLibrary(self, url, lib):
        self.updated.append((url.leafName, lib))
        return True

    def importToolLibrary(self, lib, root, name):
        self.imported.append((root, name, lib))
        return SimpleNamespace(leafName=name)


def fake_lib(tool_dicts):
    return SimpleNamespace(count=len(tool_dicts), item=lambda i: SimpleNamespace(toJson=lambda: json.dumps(tool_dicts[i])))


class TestLibraries(AuditBase):
    def setUp(self):
        super().setUp()
        self.libs = FakeLibs()
        self.a.adsk.cam.CAMManager.get.return_value.libraryManager.toolLibraries = self.libs
        self.a.adsk.cam.LibraryLocations = SimpleNamespace(LocalLibraryLocation="L", CloudLibraryLocation="C", HubLibraryLocation="H")
        self.a.adsk.cam.ToolLibrary.createFromJson.side_effect = lambda text: ("lib", json.loads(text))

    def test_import_creates_then_updates_in_place_without_duplicates(self):
        st, _ = self.a.import_library_by_name("ToolWiz - Non-ferrous", [{"guid": "a"}], "local")
        self.assertEqual(st, "created")
        self.assertEqual(self.libs.imported[0][:2], ("root:L", "ToolWiz - Non-ferrous"))
        self.assertEqual(self.libs.imported[0][2][1], {"data": [{"guid": "a"}]})
        self.libs.libs[("root:L", "ToolWiz - Non-ferrous.json")] = object()     # now exists (Fusion adds an extension)
        st, _ = self.a.import_library_by_name("ToolWiz - Non-ferrous", [{"guid": "a"}, {"guid": "b"}], "local")
        self.assertEqual(st, "updated")
        self.assertEqual(len(self.libs.imported), 1)                             # no second library
        self.assertEqual(self.libs.updated[0][0], "ToolWiz - Non-ferrous.json")

    def test_cloud_location_and_other_libraries_untouched(self):
        self.libs.libs[("root:L", "My Library")] = object()
        self.a.import_library_by_name("ToolWiz - Steels & exotics", [{}], "cloud")
        self.assertEqual(self.libs.imported[0][0], "root:C")
        self.assertEqual(self.libs.updated, [])

    def test_falls_back_to_file_when_api_fails(self):
        self.a.adsk.cam.ToolLibrary.createFromJson.side_effect = RuntimeError("no such API")
        os.environ["APPDATA"], old = self._tmp.name, os.environ.get("APPDATA")
        try:
            st, path = self.a.import_library_by_name("ToolWiz - Test", [{"guid": "a"}])
        finally:
            os.environ.pop("APPDATA") if old is None else os.environ.__setitem__("APPDATA", old)
        self.assertEqual(st, "file")
        with open(path) as f:
            self.assertEqual(json.load(f), {"data": [{"guid": "a"}]})

    def test_discover_uses_toolLibraryAtURL_all_locations_and_open_documents(self):
        self.libs.libs[("root:L", "Mill.json")] = fake_lib([{"guid": "1"}])
        self.libs.libs[("root:C", "Cloud lib")] = fake_lib([{"guid": "2"}])
        self.libs.libs[("root:H", "Team lib")] = fake_lib([{"guid": "3"}])
        doc_lib = fake_lib([{"guid": "4"}, {"guid": "5"}])
        cam = SimpleNamespace(documentToolLibrary=doc_lib)
        self.a.adsk.cam.CAM.cast.return_value = cam
        self.a.app = SimpleNamespace(documents=[SimpleNamespace(name="Bracket", products=MagicMock())])
        found = self.a.discover_libraries()
        self.assertEqual(set(found), {"Local: Mill.json", "Cloud: Cloud lib", "Hub: Team lib", "Open document: Bracket"})
        self.assertEqual([k for k, v in found.items() if v["type"] == "hub"], ["Hub: Team lib"])
        entries = self.a.harvest_selected(list(found), found)
        by = {e["library_name"]: e for e in entries}
        self.assertEqual(by["Hub: Team lib"]["source"], "hub")
        self.assertEqual(len(by["Open document: Bracket"]["tools"]), 2)
        self.assertEqual(by["Open document: Bracket"]["source"], "document")

    def test_missing_hub_location_is_skipped_not_fatal(self):
        self.a.adsk.cam.LibraryLocations = SimpleNamespace(LocalLibraryLocation="L", CloudLibraryLocation="C")
        self.libs.libs[("root:L", "Mill.json")] = fake_lib([{"guid": "1"}])
        self.a.app = SimpleNamespace(documents=[])
        found = self.a.discover_libraries()
        self.assertEqual(list(found), ["Local: Mill.json"])
        self.assertIn("HubLibraryLocation is not available", self.log_text())


class FakeDocs(list):
    def __init__(self, items=(), opener=None):
        super().__init__(items)
        self.opened = []
        self.opener = opener

    def open(self, data_file, visible=True):
        self.opened.append((data_file, visible))
        return self.opener(data_file)


class TestHubScan(AuditBase):
    def setUp(self):
        super().setUp()
        self.closed = []

        def make_doc(df):
            doc = SimpleNamespace(name=df.name, products=MagicMock(), close=lambda save: self.closed.append((df.name, save)))
            doc.cam = SimpleNamespace(documentToolLibrary=fake_lib([{"guid": f"g-{df.name}"}]))
            return doc
        self.make_doc = make_doc
        df = lambda n, ext="f3d": SimpleNamespace(name=n, id=f"id-{n}", fileExtension=ext)
        sub = SimpleNamespace(name="Fixtures", dataFiles=[df("C")], dataFolders=[])
        root = SimpleNamespace(dataFiles=[df("A"), df("B"), df("notes", "pdf")], dataFolders=[sub])
        proj = SimpleNamespace(name="Shop", rootFolder=root)
        other = SimpleNamespace(name="Other", rootFolder=SimpleNamespace(dataFiles=[df("Z")], dataFolders=[]))
        self.docs = FakeDocs([], make_doc)
        self.a.app = SimpleNamespace(data=SimpleNamespace(dataProjects=[proj, other]), documents=self.docs)
        self.a.adsk.cam.CAM.cast.side_effect = lambda prod: getattr(prod, "cam", prod)
        self._orig_item = None

    def _wire(self):
        # doc.products.itemByProductType(...) must return the doc's cam
        orig = self.make_doc

        def mk(df):
            d = orig(df)
            d.products = SimpleNamespace(itemByProductType=lambda t: d.cam)
            return d
        self.docs.opener = mk

    def test_opens_read_only_invisible_reads_library_and_closes_without_saving(self):
        self._wire()
        entries, rep = self.a.scan_hub_projects(["Shop"])
        self.assertEqual(rep["opened"], 3)                      # A, B and Fixtures/C; the pdf and the other project are not opened
        self.assertEqual([v for _, v in self.docs.opened], [False, False, False])
        self.assertEqual(self.closed, [("A", False), ("B", False), ("C", False)])
        self.assertEqual({e["library_name"] for e in entries}, {"Hub: Shop/A", "Hub: Shop/B", "Hub: Shop/Fixtures/C"})
        self.assertTrue(all(e["source"] == "hub" for e in entries))

    def test_cancel_stops_and_still_closes_what_was_opened(self):
        self._wire()
        calls = []

        def progress(done, total, label):
            calls.append((done, total))
            return done < 1                                      # cancel before the second design
        entries, rep = self.a.scan_hub_projects(["Shop"], progress)
        self.assertTrue(rep["cancelled"])
        self.assertEqual(len(entries), 1)
        self.assertEqual(self.closed, [("A", False)])
        self.assertEqual(calls[0], (0, 3))

    def test_open_failure_is_skipped_and_document_already_open_is_left_open(self):
        self._wire()
        already = SimpleNamespace(name="A", dataFile=SimpleNamespace(id="id-A"),
                                  products=SimpleNamespace(itemByProductType=lambda t: SimpleNamespace(documentToolLibrary=fake_lib([{"guid": "x"}]))),
                                  close=lambda save: self.closed.append(("A-already", save)))
        self.docs.append(already)
        real = self.docs.opener
        self.docs.opener = lambda df: None if df.name == "B" else real(df)
        entries, rep = self.a.scan_hub_projects(["Shop"])
        self.assertNotIn(("A-already", False), self.closed)
        self.assertEqual([n for n, _ in rep["skipped"]], ["Shop/B"])
        self.assertEqual(rep["opened"], 2)


class TestAsyncAndAdvisorApply(AuditBase):
    def test_run_async_falls_back_to_inline_without_custom_event(self):
        got = []
        self.a._async_event = None
        self.a.run_async(lambda: 41 + 1, lambda r, e: got.append((r, e)))
        self.assertEqual(got, [(42, None)])
        self.a.run_async(lambda: 1 / 0, lambda r, e: got.append((r, type(e).__name__)))
        self.assertEqual(got[-1], (None, "ZeroDivisionError"))

    def test_async_event_hands_result_to_main_thread_callback(self):
        got = []
        self.a._async_event = object()
        fired = []
        self.a.app = SimpleNamespace(fireCustomEvent=lambda eid, info: fired.append((eid, info)))
        job = self.a.run_async(lambda: "done", lambda r, e: got.append(r))
        import time
        for _ in range(100):
            if fired:
                break
            time.sleep(0.01)
        self.assertEqual(fired[0][0], self.a.ASYNC_EVENT_ID)
        self.assertEqual(got, [])                                # nothing ran on the worker thread
        self.a.ToolWizAsyncCustomEventHandler().notify(SimpleNamespace(additionalInfo=fired[0][1]))
        self.assertEqual(got, ["done"])
        self.assertEqual(job, fired[0][1])

    def test_apply_done_reports_results_per_operation(self):
        out = [("Setup1 > A", {"success": True, "ok": True, "accepted": {}, "applied": {"maximumStepdown": {"old": "0.25 in", "new": "0.1 in"}}, "skipped": {}, "error": None}, None),
               ("Setup1 > B", {"success": False, "error": "ToolWiz rejected", "rejected": {"stockToLeave": "not recommended"}}, None),
               ("Setup1 > C", None, OSError("404"))]
        self.a._advisor_apply_done(out, None)
        text = self.a.ui.messageBox.call_args[0][0]
        self.assertIn("Setup1 > A: 1 applied", text)
        self.assertIn("maximumStepdown: 0.25 in -> 0.1 in", text)
        self.assertIn("Setup1 > B: 0 applied - ToolWiz rejected", text)
        self.assertIn("too old for /api/setup_advisor/apply", text)

    def test_the_add_in_never_writes_parameters_itself_after_the_server_call(self):
        op = make_op("Adaptive1", params={"maximumStepdown": param("0.25 in")})
        cam_with(self.a, {"Setup1": [op]})
        self.a._advisor_apply_done([("Setup1 > Adaptive1", None, OSError("down"))], None)
        self.assertEqual(op.parameters.itemByName("maximumStepdown").expression, "0.25 in")

    def test_confirm_then_post_per_op_with_wait(self):
        a = self.a
        a._async_event = None
        a._advisor_state.update(parsed={"operations": []}, recs=[{"id": "r1", "kind": "apply_plan", "op_id": "S > A", "severity": "INFO",
                                                              "title": "A: ToolWiz recommended engagement and cutting data", "changes": {"S > A": {"maximumStepdown": "0.1 in"}}}])
        dd = MagicMock()
        item = SimpleNamespace(name=a._rec_label(a._advisor_state["recs"][0]), isSelected=True)
        dd.listItems = [item]
        inputs = SimpleNamespace(itemById=lambda i: dd if i == "advRecs" else None)
        a.ui.messageBox.return_value = a.adsk.core.DialogResults.DialogYes
        posted = []
        with patch.object(a, "_http_json", side_effect=lambda path, body=None, **k: (posted.append((path, body)), {"success": True, "ok": True, "applied": {}, "skipped": {}})[1]), \
             patch.object(a, "current_param_expressions", return_value={"S > A": {"maximumStepdown": "0.25 in"}}):
            args = SimpleNamespace(command=SimpleNamespace(commandInputs=inputs))
            a.adsk.core.CommandEventArgs.cast.return_value = args
            a.ToolWizSetupAdvisorResultExecuteHandler().notify(args)
        self.assertIn("maximumStepdown: 0.25 in -> 0.1 in", a.ui.messageBox.call_args_list[0][0][0])
        self.assertEqual(posted[0][0], "/api/setup_advisor/apply")
        self.assertEqual(posted[0][1]["op_id"], "S > A")
        self.assertEqual(posted[0][1]["wait"], 60)
        self.assertEqual(posted[0][1]["params"], {"maximumStepdown": "0.1 in"})


class TestSetupSnapshot(AuditBase):
    def build(self, strategy="Finishing", extra=None, finish=None, geo=None):
        a = self.a
        params = {"stockToLeave": param("0.01 in", 0.0254), "verticalStockToLeave": param("0.005 in", 0.0127),
                  "useStockToLeave": param("true"), "topHeight_value": param("0 in", 0.0), "bottomHeight_value": param("-0.5 in", -1.27),
                  "tool_feedPlunge": param("20 in/min", 50.8), "doRestMachining": param("true")}
        params.update(extra or {})
        op = make_op("Op1", params=params)
        op.strategy = "contour2d"
        op.hasToolpath = False
        op.isSuppressed = False
        cam_with(a, {"Setup1": [op]})
        geo = geo or dict(TestAutoSetV3.GEO)
        with patch.object(a, "get_op_tool_info", return_value=(geo, "s", [])), \
             patch.object(a, "get_op_cut_params", return_value=(9000, 40.0, 0.25, 0.01)), \
             patch.object(a, "infer_strategy_for_op", return_value=strategy):
            return a.build_setup_snapshot("Setup1", "in", finish)

    def test_fields_follow_the_advisor_doc(self):
        snap = self.build(finish={"mode": "surface", "ra_uin": 32.0, "wall_in": 0.0002})
        self.assertEqual(snap["document"], "Bracket v3")
        e = snap["ops"][0]
        self.assertEqual((e["op_id"], e["path"], e["name"], e["setup"], e["strategy"]), ("Setup1 > Op1", "Setup1 > Op1", "Op1", "Setup1", "contour2d"))
        self.assertEqual(e["tool"]["description"], "1/4 flat")                    # the parsed tool JSON
        self.assertEqual(e["holder"]["description"], "ER16")
        self.assertEqual(e["holder"]["runout_in"], 0.0001)                         # only when the tool carries its own runout
        p = e["params"]
        self.assertEqual((p["tool_spindleSpeed"], p["tool_feedCutting"], p["maximumStepdown"], p["stepover"]),
                         ("9000 rpm", "40.000 in/min", "0.25000 in", "0.01000 in"))
        self.assertEqual((p["stockToLeave"], p["verticalStockToLeave"]), ("0.01000 in", "0.00500 in"))
        self.assertEqual(p["tool_feedPlunge"], "20.000 in/min")
        self.assertIs(e["rest_machining"], True)
        g = e["geometry"]
        self.assertAlmostEqual(g["depth_in"], 0.5)
        self.assertEqual((g["top_height_in"], g["bottom_height_in"]), (0.0, -0.5))
        self.assertNotIn("toolpath_length_in", g)                                   # no toolpath generated
        self.assertEqual((e["finishMode"], e["targetRa"]), ("surface", 32.0))

    def test_adaptive_uses_optimal_load_stock_off_omits_stock_and_no_rest_param_is_none(self):
        snap = self.build(strategy="Adaptive Roughing", extra={"useStockToLeave": param("false"), "doRestMachining": None})
        e = snap["ops"][0]
        self.assertIn("optimalLoad", e["params"])
        self.assertNotIn("stepover", e["params"])
        self.assertNotIn("stockToLeave", e["params"])
        self.assertIsNone(e["rest_machining"])
        self.assertNotIn("finishMode", e)

    def test_tabs_and_slot_height_are_best_effort_geometry(self):
        extra = {"useTabs": param("true"), "tabWidth": param("0.1 in", 0.254), "tabHeight": param("0.04 in", 0.1016),
                 "tabCount": param("4", 4)}
        snap = self.build(extra=extra)
        self.assertEqual(snap["ops"][0]["geometry"]["tabs"], {"count": 4, "width_in": 0.1, "height_in": 0.04})
        geo = dict(TestAutoSetV3.GEO, kind="slot", fluteLength=0.0787)
        self.assertEqual(self.build(geo=geo)["ops"][0]["geometry"]["slot_height_in"], 0.0787)

    def test_toolpath_length_from_machining_time(self):
        a = self.a
        cam = cam_with(a, {"S": [make_op("O")]})
        cam.getMachiningTime = lambda op, scale, rapid, change: SimpleNamespace(feedDistance=254.0)
        op = cam.setups[0].allOperations[0]
        op.hasToolpath = True
        self.assertAlmostEqual(a._toolpath_length_in(op), 100.0)

    def test_per_op_finish_choice_wins_over_dialog_default(self):
        self.a._finish_prefs["Setup1 > Op1"] = {"mode": "accuracy", "ra_uin": 16.0, "wall_in": 0.0003}
        e = self.build(finish={"mode": "surface"})["ops"][0]
        self.assertEqual((e["finishMode"], e["wallTolerance"]), ("accuracy", 0.0003))

    def test_get_setup_summary_returns_rich_ops_and_pushes_state(self):
        a = self.a
        pushed = []
        with patch.object(a, "_http_json", side_effect=lambda path, body=None, **k: (pushed.append((path, body)), {"success": True})[1]):
            self.build()   # builds a document for the cam mock
            op_geo = dict(TestAutoSetV3.GEO)
            with patch.object(a, "get_op_tool_info", return_value=(op_geo, "s", [])), \
                 patch.object(a, "get_op_cut_params", return_value=(9000, 40.0, 0.25, 0.01)):
                res = a.dispatch_bridge_action("get_setup_summary", {})
        self.assertTrue(res["success"])
        self.assertEqual(res["ops"][0]["op_id"], "Setup1 > Op1")
        self.assertEqual(pushed[-1][0], "/api/fusion_bridge/state")
        self.assertEqual(pushed[-1][1]["ops"][0]["op_id"], "Setup1 > Op1")


class TestMasterLibraryFlow(AuditBase):
    def setUp(self):
        super().setUp()
        self.a._async_event = None                   # run_async runs inline
        self.a.ML_POLL_SECONDS = 0
        self.shown = []
        self.a.show_text_result = lambda title, text, jumps=None: self.shown.append(text)

    def test_poll_progress_then_download_then_import_in_place(self):
        a = self.a
        prog = SimpleNamespace(wasCancelled=False, progressValue=0, message="", hide=MagicMock())
        result = {"merge": {"tools_in": 3, "tools_out": 3}, "libraries": [
            {"name": "ToolWiz - Non-ferrous", "download_url": "/dl/1", "tool_count": 1, "preset_count": 2, "toolwiz_preset_count": 2,
             "audit": {"summary": {"toolwiz_STOP": 0}}}]}
        responses = iter([{"state": "running", "phase": "generating", "progress": {"percent": 40, "tools_done": 1, "tools_total": 3}},
                          {"state": "done", "result": result}])
        seen = []

        def fake_http(path, payload=None, timeout=5.0, retries=0, log_errors=True):
            seen.append(path)
            if path.startswith("/dl/"):
                return {"data": [{"guid": "a"}]}
            return next(responses)
        imported = []
        with patch.object(a, "_http_json", side_effect=fake_http), \
             patch.object(a, "import_library_by_name", side_effect=lambda n, t, loc: (imported.append((n, t, loc)), ("updated", n))[1]):
            a._ml_poll("job1", "local", prog, "", 0)
        self.assertEqual(prog.progressValue, 40)
        self.assertEqual(seen, ["/api/twin/build_sets/job1", "/api/twin/build_sets/job1", "/dl/1"])
        self.assertEqual(imported, [("ToolWiz - Non-ferrous", [{"guid": "a"}], "local")])
        prog.hide.assert_called()
        self.assertIn("updated in place", self.shown[0])
        self.assertIn("0 STOP", self.shown[0])

    def test_error_state_is_reported_and_cancel_stops_polling(self):
        a = self.a
        prog = SimpleNamespace(wasCancelled=False, hide=MagicMock())
        with patch.object(a, "_http_json", return_value={"state": "error", "error": "boom"}):
            a._ml_poll("j", "local", prog, "", 0)
        self.assertIn("boom", a.ui.messageBox.call_args[0][0])
        prog = SimpleNamespace(wasCancelled=True, hide=MagicMock())
        with patch.object(a, "_http_json") as http:
            a._ml_poll("j", "local", prog, "", 0)
        self.assertIn("Stopped waiting", a.ui.messageBox.call_args[0][0])

    def test_repeated_poll_errors_give_up(self):
        a = self.a
        prog = SimpleNamespace(wasCancelled=False, hide=MagicMock())
        with patch.object(a, "_http_json", side_effect=OSError("down")) as http:
            a._ml_poll("j", "local", prog, "", 0)
        self.assertEqual(http.call_count, a.ML_MAX_POLL_ERRORS)


class TestRoughingStock(AuditBase):
    def test_recommended_stock_per_roughing_op_uses_runout_model_engagement(self):
        a = self.a
        a._model_cache["model"] = "v2"
        a._rough_stock_cache.clear()
        geo = dict(TestAutoSetV3.GEO)
        a.stock_ops_cache.clear()
        a.stock_ops_cache["op_1"] = {"op": MagicMock(), "label": "S > Rough", "strategy": "adaptive2d", "geo": geo, "doc": 0.4, "woc": 0.03, "is_finishing": False}
        a.stock_ops_cache["op_2"] = {"op": MagicMock(), "label": "S > Fin", "strategy": "contour2d", "geo": geo, "doc": 0.4, "woc": 0.03, "is_finishing": True}
        calls = []

        def fake_http(path, payload=None, **kw):
            calls.append((path, payload))
            return {"success": True, "recommended_radial_stock_in": 0.0041, "recommended_axial_stock_in": 0.002}
        with patch.object(a, "_http_json", side_effect=fake_http), patch.object(a, "infer_strategy_for_op", return_value="Adaptive Roughing"):
            out = a.query_roughing_stock("Aluminum - Wrought (6061)", "6061-T6", 50)
            again = a.query_roughing_stock("Aluminum - Wrought (6061)", "6061-T6", 50)
        self.assertEqual(list(out), ["op_1"])                  # finishing op skipped
        self.assertEqual(out["op_1"]["radial_in"], 0.0041)
        self.assertEqual(len(calls), 1)                        # cached the second time
        sent = calls[0][1]
        self.assertEqual((sent["model"], sent["runout"], sent["stepdown"], sent["stepover"]), ("v2", 0.0001, 0.4, 0.03))
        a.stock_ops_cache.clear()

    def test_stock_payload_sends_runout_carbide_and_full_tool(self):
        a = self.a
        cache = {"op_1": {"name": "x", "strategy": "adaptive", "unit": "in", "geo": dict(TestAutoSetV3.GEO), "rpm": 1, "feed": 1, "doc": 0.1, "woc": 0.1}}
        p = a.build_stock_ops_payload(cache, "in")[0]
        self.assertEqual(p["runout"], 0.0001)
        self.assertTrue(p["isCarbide"])
        self.assertEqual(p["fusion_tool"]["description"], "1/4 flat")


class TestCommandRegistration(AuditBase):
    def test_new_commands_registered_with_handlers_and_icons(self):
        a = self.a
        specs = {s[0]: s for s in a.COMMAND_SPECS}
        for cid in (a.advisorCommandId, a.strategyCommandId, a.masterLibCommandId, a.libAuditCommandId):
            self.assertIn(cid, specs)
            self.assertTrue(hasattr(a, specs[cid][3]), cid)
        hidden = {s[0] for s in a.HIDDEN_COMMAND_SPECS}
        self.assertEqual(hidden, {a.advisorResultCommandId, a.textResultCommandId})
        repo = os.path.join(os.path.dirname(__file__), "..", "ToolWizFusionAddin", "resources")
        for cid, *_ in a.COMMAND_SPECS:
            for f in ("16x16.png", "32x32.png"):
                self.assertTrue(os.path.exists(os.path.join(repo, cid, f)), f"{cid}/{f}")

    def test_manifest_version_bumped(self):
        with open(os.path.join(os.path.dirname(__file__), "..", "ToolWizFusionAddin", "ToolWizFusionAddin.manifest")) as f:
            m = json.load(f)
        self.assertEqual(m["version"], "2.0.0")
        self.assertIn("Setup Advisor", m["description"][""])


if __name__ == "__main__":
    unittest.main()
