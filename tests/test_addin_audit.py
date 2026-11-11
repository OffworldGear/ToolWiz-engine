"""Change audit trail: audit(), snapshots, diffs, side-effect detection and Replace safety."""
import json
import os
import tempfile
import unittest
from types import SimpleNamespace
from unittest.mock import MagicMock

from test_addin_common import load_addin, param, ParamsByName


class AuditBase(unittest.TestCase):
    def setUp(self):
        self.a = load_addin()
        self._tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self._tmp.cleanup)
        self.a._toolwiz_dir = lambda: self._tmp.name
        self.a.app = SimpleNamespace(activeDocument=SimpleNamespace(name="Bracket v3", products=MagicMock()))
        self.a.ui = MagicMock()

    def entries(self):
        path = os.path.join(self._tmp.name, "audit.jsonl")
        if not os.path.exists(path):
            return []
        with open(path, encoding="utf-8") as f:
            return [json.loads(line) for line in f if line.strip()]

    def log_text(self):
        path = os.path.join(self._tmp.name, "addin.log")
        if not os.path.exists(path):
            return ""
        with open(path, encoding="utf-8") as f:
            return f.read()


def make_tool(number=7, desc="1/4 flat", guid="g-1", presets=()):
    t = MagicMock()
    t.toJson.return_value = json.dumps({"guid": guid, "description": desc, "post-process": {"number": number}})
    t.description = desc
    t.presets = list(presets)
    return t


def make_preset(name, mapping=None):
    pr = SimpleNamespace(name=name, parameters=ParamsByName(mapping or {}))
    return pr


def make_op(name="Adaptive1", setup="Setup1", tool=None, preset=None, params=None):
    return SimpleNamespace(name=name, parent=SimpleNamespace(name=setup, allOperations=[]),
                           tool=tool or make_tool(), toolPreset=preset,
                           parameters=ParamsByName(params or {}))


class TestAuditWriter(AuditBase):
    def test_writes_valid_json_lines_with_common_fields(self):
        self.a.audit({"event": "param_change", "param": "x"})
        self.a.audit({"event": "command_start", "target": "t"})
        rows = self.entries()
        self.assertEqual(len(rows), 2)
        for r in rows:
            for k in ("ts", "session_id", "document", "command"):
                self.assertIn(k, r)
        self.assertEqual(rows[0]["document"], "Bracket v3")
        self.assertEqual(rows[0]["session_id"], rows[1]["session_id"])
        self.assertEqual(rows[0]["param"], "x")

    def test_document_unknown_is_question_mark(self):
        self.a.app = None
        self.a.audit({"event": "x"})
        self.assertEqual(self.entries()[0]["document"], "?")

    def test_rotates_at_limit(self):
        self.a._AUDIT_MAX_BYTES = 300
        for i in range(30):
            self.a.audit({"event": "e", "n": i, "pad": "x" * 40})
        self.assertTrue(os.path.exists(os.path.join(self._tmp.name, "audit.1.jsonl")))
        live = os.path.getsize(os.path.join(self._tmp.name, "audit.jsonl"))
        self.assertLess(live, 600)
        for fn in ("audit.jsonl", "audit.1.jsonl"):
            with open(os.path.join(self._tmp.name, fn), encoding="utf-8") as f:
                for line in f:
                    json.loads(line)

    def test_never_raises(self):
        self.a._toolwiz_dir = lambda: os.path.join(self._tmp.name, "a\0b")
        self.a.audit({"event": "x"})
        self.a._toolwiz_dir = lambda: self._tmp.name
        self.a.audit({"event": "x", "obj": object()})   # non-JSON value is stringified
        self.assertEqual(len(self.entries()), 1)


class TestWritesAreRecorded(AuditBase):
    def test_apply_param_records_old_and_new_expression(self):
        p = param("1000 rpm", 1000.0)
        op = make_op(params={"tool_spindleSpeed": p})
        self.assertTrue(self.a.apply_param(op, "tool_spindleSpeed", "6000 rpm"))
        row = self.entries()[-1]
        self.assertEqual(row["event"], "param_change")
        self.assertEqual(row["op_path"], "Setup1 > Adaptive1")
        self.assertEqual(row["tool_number"], 7)
        self.assertEqual(row["param"], "tool_spindleSpeed")
        self.assertEqual(row["old_expression"], "1000 rpm")
        self.assertEqual(row["new_expression"], "6000 rpm")
        self.assertEqual(row["old_value"], 1000.0)

    def test_disabled_param_not_written_or_recorded(self):
        p = param("1000 rpm", 1000.0)
        p.isEnabled = False
        op = make_op(params={"tool_spindleSpeed": p})
        self.assertFalse(self.a.apply_param(op, "tool_spindleSpeed", "6000 rpm"))
        self.assertEqual(self.entries(), [])

    def test_stock_to_leave_write_is_recorded(self):
        rad = param("0.01 in", 0.0254)
        op = make_op(params={"stockToLeave": rad, "useStockToLeave": param("false", False)})
        self.a.apply_stock_to_op(op, "0.02 in", "0.01 in")
        by_param = {r["param"]: r for r in self.entries() if r["event"] == "param_change"}
        self.assertEqual(by_param["stockToLeave"]["old_expression"], "0.01 in")
        self.assertEqual(by_param["stockToLeave"]["new_expression"], "0.02 in")
        self.assertEqual(by_param["useStockToLeave"]["new_expression"], "true")

    def test_preset_rename_and_field_writes_recorded(self):
        spindle = param("5000 rpm", 5000.0)
        old = make_preset("Old Name", {"tool_spindleSpeed": spindle})
        tool = make_tool(presets=[old])
        op = make_op(tool=tool, preset=old)
        pr, was_updated = self.a._upsert_preset_in_place(
            op, "New Name", "Old Name", [("tool_spindleSpeed", "8000 rpm")])
        self.assertTrue(was_updated)
        rows = [r for r in self.entries() if r["event"] == "preset_change"]
        name_row = next(r for r in rows if r["field"] == "name")
        self.assertEqual((name_row["old"], name_row["new"]), ("Old Name", "New Name"))
        self.assertEqual(name_row["tool_number"], 7)
        self.assertEqual(name_row["tool_description"], "1/4 flat")
        spd = next(r for r in rows if r["field"] == "tool_spindleSpeed")
        self.assertEqual((spd["old"], spd["new"]), ("5000 rpm", "8000 rpm"))
        self.assertEqual((spd["preset_before"], spd["preset_after"]), ("Old Name", "New Name"))

    def test_tool_preset_assignment_recorded_as_preset_link(self):
        old = make_preset("A")
        new = make_preset("B")
        tool = make_tool(presets=[old, new])
        op = make_op(tool=tool, preset=old)
        self.assertTrue(self.a._refresh_operations_from_preset(op, "B"))
        row = [r for r in self.entries() if r["event"] == "preset_link"][-1]
        self.assertEqual((row["preset_before"], row["preset_after"]), ("A", "B"))
        self.assertEqual(row["op_path"], "Setup1 > Adaptive1")

    def test_cleanup_removal_recorded(self):
        lib = MagicMock()
        lib.count = 2
        lib.remove.return_value = True
        entries = [{"index": 0, "tool": {"type": "flat end mill", "description": "d", "post-process": {"number": 3},
                                         "geometry": {"DC": 0.25}}, "used": True},
                   {"index": 1, "tool": {"type": "flat end mill", "description": "d", "post-process": {"number": 3},
                                         "geometry": {"DC": 0.25}}, "used": False}]
        self.a._collect_document_tools = lambda: (lib, entries)
        self.a.snapshot_document = lambda: {"ops": {}, "tool_count": 2, "tool_numbers": [3, 3]}
        self.a.ToolWizCleanupExecuteHandler().notify(None)
        removed = [r for r in self.entries() if r["event"] == "tool_removed"]
        self.assertEqual(len(removed), 1)
        self.assertEqual((removed[0]["library_index"], removed[0]["tool_number"], removed[0]["description"]),
                         (1, 3, "d"))
        kinds = [r["event"] for r in self.entries()]
        self.assertEqual(kinds[0], "command_start")
        self.assertEqual(kinds[-1], "command_end")


class TestSnapshotAndDiff(AuditBase):
    def entry(self, **kw):
        base = {"tool_number": 7, "tool_guid": "g-1", "tool_description": "1/4 flat", "preset_name": "Alu - Adaptive",
                "tool_spindleSpeed": {"expr": "6000 rpm", "value": 6000.0},
                "tool_feedCutting": {"expr": "30 in/min", "value": 12.7}}
        base.update(kw)
        return base

    def test_reserialised_number_is_not_a_change(self):
        a = self.a
        f = lambda e: {"Setup1 > A": self.entry(tool_feedCutting={"expr": e, "value": 2746.756})}
        self.assertEqual(a.diff_snapshots(f("108.13999999999999in/min"), f("108.13999999999997in/min")), [])
        self.assertEqual(len(a.diff_snapshots(f("108.14in/min"), f("108.14mm/min"))), 1)
        self.assertEqual(len(a.diff_snapshots(f("108.14in/min"), f("110in/min"))), 1)
        self.assertEqual(len(a.diff_snapshots(f("tool_feedCutting"), f("108.14in/min"))), 1)

    def test_preset_change_on_non_target_op_detected(self):
        before = {"Setup1 > A": self.entry(), "Setup1 > B": self.entry()}
        after = {"Setup1 > A": self.entry(), "Setup1 > B": self.entry(preset_name="Alu - Finishing")}
        changes = self.a.diff_snapshots(before, after)
        self.assertEqual(changes, [{"kind": "preset_change", "path": "Setup1 > B",
                                    "before": "Alu - Adaptive", "after": "Alu - Finishing"}])

    def test_field_changes_added_and_removed_ops(self):
        before = {"S > A": self.entry(), "S > Gone": self.entry()}
        after = {"S > A": self.entry(tool_spindleSpeed={"expr": "7000 rpm", "value": 7000.0}), "S > New": self.entry()}
        changes = self.a.diff_snapshots(before, after)
        kinds = {(c["kind"], c["path"]) for c in changes}
        self.assertEqual(kinds, {("op_added", "S > New"), ("op_removed", "S > Gone"),
                                 ("field_change", "S > A")})
        fields = {c["field"] for c in changes if c["kind"] == "field_change"}
        self.assertEqual(fields, {"tool_spindleSpeed.expr", "tool_spindleSpeed.value"})

    def test_no_changes_and_float_noise_ignored(self):
        a = {"S > A": self.entry()}
        b = {"S > A": self.entry(tool_feedCutting={"expr": "30 in/min", "value": 12.7 + 1e-13})}
        self.assertEqual(self.a.diff_snapshots(a, b), [])

    def test_document_level_changes(self):
        b = {"ops": {}, "tool_count": 64, "tool_numbers": [1, 2]}
        a = {"ops": {}, "tool_count": 65, "tool_numbers": [1, 2, 2]}
        kinds = {c["kind"] for c in self.a.diff_snapshots(b, a)}
        self.assertEqual(kinds, {"tool_count", "tool_numbers"})

    def test_snapshot_document_reads_every_operation_and_modifies_nothing(self):
        t = make_tool()
        pr = make_preset("P1")
        op1 = make_op("Op1", tool=t, preset=pr, params={"tool_spindleSpeed": param("6000 rpm", 6000.0),
                                                       "maximumStepdown": param("0.2 in", 0.508)})
        op2 = make_op("Op1", tool=t, preset=None)
        lib = SimpleNamespace(count=1, item=lambda i: t)
        cam = SimpleNamespace(setups=[SimpleNamespace(name="Setup1", allOperations=[op1, op2])],
                              documentToolLibrary=lib)
        self.a.adsk.cam.CAM.cast.return_value = cam
        snap = self.a.snapshot_document()
        self.assertEqual(set(snap["ops"]), {"Setup1 > Op1", "Setup1 > Op1 #2"})
        e = snap["ops"]["Setup1 > Op1"]
        self.assertEqual((e["tool_number"], e["tool_guid"], e["preset_name"]), (7, "g-1", "P1"))
        self.assertEqual(e["tool_spindleSpeed"], {"expr": "6000 rpm", "value": 6000.0})
        self.assertIsNone(e["stepover"])
        self.assertEqual((snap["tool_count"], snap["tool_numbers"]), (1, [7]))
        json.dumps(snap)   # serialisable
        self.assertEqual(op1.parameters.mapping["tool_spindleSpeed"].expression, "6000 rpm")

    def test_snapshot_never_raises(self):
        self.a.adsk.cam.CAM.cast.side_effect = RuntimeError("boom")
        snap = self.a.snapshot_document()
        self.assertEqual(snap["ops"], {})


class TestSideEffects(AuditBase):
    def snaps(self, before, after):
        it = iter([before, after])
        return lambda: next(it)

    def test_classification_target_vs_other(self):
        changes = [{"kind": "field_change", "path": "S > Target", "field": "f", "before": 1, "after": 2},
                   {"kind": "preset_change", "path": "S > Other", "before": "a", "after": "b"},
                   {"kind": "tool_count", "path": None, "before": 1, "after": 2}]
        mine, other = self.a.classify_changes(changes, ["S > Target"])
        self.assertEqual([c["path"] for c in mine], ["S > Target"])
        self.assertEqual([c["path"] for c in other], ["S > Other", None])
        mine, other = self.a.classify_changes(changes, ["S > Target"], expected_doc_changes=True)
        self.assertEqual([c["path"] for c in other], ["S > Other"])

    def test_command_records_side_effect_log_and_note(self):
        entry = lambda p: {"preset_name": p, "tool_number": 7}
        before = {"ops": {"S > Target": entry("A"), "S > Other": entry("A")}}
        after = {"ops": {"S > Target": entry("B"), "S > Other": entry("B")}}
        ac = self.a.AuditedCommand("autoset", target="S > Target", targets=["S > Target"],
                                   snapshot_fn=self.snaps(before, after)).begin()
        note = ac.finish("ok")
        rows = self.entries()
        side = [r for r in rows if r["event"] == "side_effect"]
        self.assertEqual([r["op_path"] for r in side], ["S > Other"])
        self.assertEqual((side[0]["before"], side[0]["after"]), ("A", "B"))
        self.assertTrue(all(r["command"] == "autoset" for r in rows))
        # change on the intended target is a normal change, not a side effect
        normal = [r for r in rows if r["event"] == "preset_link"]
        self.assertEqual([r["op_path"] for r in normal], ["S > Target"])
        self.assertIn("SIDE EFFECT:", self.log_text())
        self.assertIn("Note: 1 other operation(s) changed as a side effect", note)
        self.assertIn("audit.jsonl", note)
        end = rows[-1]
        self.assertEqual((end["event"], end["result"], end["side_effect_ops"]), ("command_end", "ok", 1))
        self.assertEqual(ac.finish("again"), note)   # idempotent

    def test_no_side_effects_no_note(self):
        snap = {"ops": {"S > T": {"preset_name": "A"}}}
        ac = self.a.AuditedCommand("c", targets=["S > T"], snapshot_fn=self.snaps(snap, json.loads(json.dumps(snap)))).begin()
        self.assertEqual(ac.finish(), "")
        self.assertFalse([r for r in self.entries() if r["event"] == "side_effect"])

    def test_snapshot_failure_is_swallowed(self):
        def boom():
            raise RuntimeError("no doc")
        ac = self.a.AuditedCommand("c", snapshot_fn=boom).begin()
        self.assertEqual(ac.finish(), "")
        self.assertEqual(self.entries()[-1]["event"], "command_end")

    def test_import_flags_any_op_change_and_records_staging_path(self):
        a = self.a
        a._http_json = lambda *x, **k: {"success": True, "library": {"library_name": "Lib", "tools": [{"t": 1}]}}
        base = {"ops": {"S > Op": {"preset_name": "A"}}}
        changed = {"ops": {"S > Op": {"preset_name": "B"}}}
        a.snapshot_document = self.snaps(base, changed)
        os.environ["APPDATA"], old = self._tmp.name, os.environ.get("APPDATA")
        try:
            a.ToolWizImportExecuteHandler().notify(None)
        finally:
            if old is None:
                del os.environ["APPDATA"]
            else:
                os.environ["APPDATA"] = old
        end = [r for r in self.entries() if r["event"] == "command_end"][-1]
        self.assertTrue(end["target"].endswith("Lib.json"))
        self.assertEqual(end["side_effect_ops"], 1)
        self.assertIn("side effect", a.ui.messageBox.call_args[0][0])


class TestReplaceSafety(AuditBase):
    def setup_shared(self):
        t = make_tool(presets=[make_preset("Alu - Adaptive")])
        target = make_op("Target", tool=t, preset=SimpleNamespace(name="Alu - Adaptive"))
        ops = {"Setup1 > Target": {"tool_guid": "g-1", "tool_number": 7, "tool_description": "1/4 flat",
                                   "preset_name": "Alu - Adaptive"}}
        for i in range(12):
            ops[f"Setup1 > Other{i:02d}"] = {"tool_guid": "g-1", "tool_number": 7, "tool_description": "1/4 flat",
                                             "preset_name": "Alu - Adaptive"}
        ops["Setup1 > DifferentTool"] = {"tool_guid": "g-2", "tool_number": 9, "tool_description": "other",
                                         "preset_name": "Alu - Adaptive"}
        ops["Setup1 > OtherPreset"] = {"tool_guid": "g-1", "tool_number": 7, "tool_description": "1/4 flat",
                                       "preset_name": "Something else"}
        self.a.snapshot_document = lambda: {"ops": ops}
        return target

    def test_find_sharing_ops_matches_guid_or_number_and_description(self):
        ops = {"A": {"tool_guid": "x", "tool_number": 1, "tool_description": "d", "preset_name": "P"},
               "B": {"tool_guid": "y", "tool_number": 1, "tool_description": "d", "preset_name": "P"},
               "C": {"tool_guid": "y", "tool_number": 1, "tool_description": "zz", "preset_name": "P"},
               "D": {"tool_guid": "x", "tool_number": 5, "tool_description": "q", "preset_name": "Q"}}
        self.assertEqual(self.a.find_sharing_ops(ops, "T", "x", 1, "d", ["P"]), ["A", "B"])

    def test_prompt_lists_ten_then_and_n_more(self):
        text = self.a.format_shared_preset_prompt([f"S > Op{i}" for i in range(13)])
        self.assertIn("Replacing this preset also changes these operations", text)
        self.assertIn("S > Op9", text)
        self.assertNotIn("S > Op10", text)
        self.assertIn("and 3 more", text)
        self.assertTrue(text.rstrip().endswith("Continue?"))

    def test_no_aborts_and_decision_is_audited(self):
        target = self.setup_shared()
        self.a.ui.messageBox.return_value = self.a.adsk.core.DialogResults.DialogNo
        ok = self.a.check_replace_safety(target, "Setup1 > Target", "Alu - Adaptive", "Alu - Adaptive")
        self.assertFalse(ok)
        shown = self.a.ui.messageBox.call_args[0][0]
        self.assertIn("Setup1 > Other00", shown)
        self.assertNotIn("DifferentTool", shown)
        self.assertNotIn("OtherPreset", shown)
        self.assertIn("and 2 more", shown)
        row = [r for r in self.entries() if r["event"] == "replace_decision"][-1]
        self.assertEqual(row["decision"], "no")
        self.assertEqual(len(row["shared_with"]), 12)

    def test_yes_continues(self):
        target = self.setup_shared()
        self.a.ui.messageBox.return_value = self.a.adsk.core.DialogResults.DialogYes
        self.assertTrue(self.a.check_replace_safety(target, "Setup1 > Target", "Alu - Adaptive", "X"))
        self.assertEqual([r for r in self.entries() if r["event"] == "replace_decision"][-1]["decision"], "yes")

    def test_unshared_preset_does_not_prompt(self):
        t = make_tool(presets=[make_preset("Alu - Adaptive")])
        target = make_op("Target", tool=t)
        self.a.snapshot_document = lambda: {"ops": {"Setup1 > Target": {"tool_guid": "g-1", "preset_name": "Alu - Adaptive"}}}
        self.assertTrue(self.a.check_replace_safety(target, "Setup1 > Target", "Alu - Adaptive", "Alu - Adaptive"))
        self.a.ui.messageBox.assert_not_called()

    def test_run_autoset_aborts_with_nothing_changed_on_no(self):
        a = self.a
        target = self.setup_shared()
        a.get_op_tool_info = lambda op: ({"number": 7, "flutes": 4}, "summary", [])
        a.build_calc_payload = lambda *x, **k: {}
        a._http_json = lambda *x, **k: {"success": True, "rpm": 6000, "feed": 30.0, "doc": 0.2, "woc": 0.05}
        a._log_custom_diff = a._log_op_motion_params = lambda *x, **k: None
        a._upsert_preset_in_place = MagicMock()
        a.apply_param = MagicMock()
        a.ui.messageBox.return_value = a.adsk.core.DialogResults.DialogNo
        done = a.run_autoset(target, "Setup1 > Target", "Aluminum", "6061", "Adaptive Roughing", 50,
                             "Alu - Adaptive", "HP", "AlTiN")
        self.assertFalse(done)
        a._upsert_preset_in_place.assert_not_called()
        a.apply_param.assert_not_called()
        self.assertEqual(a.ui.messageBox.call_count, 1)   # only the Yes/No prompt


class TestSnapshotCommand(AuditBase):
    def test_command_registered_with_handler(self):
        specs = {s[0]: s for s in self.a.COMMAND_SPECS}
        self.assertIn(self.a.snapshotCommandId, specs)
        self.assertIn("Snapshot", specs[self.a.snapshotCommandId][1])
        self.assertTrue(hasattr(self.a, specs[self.a.snapshotCommandId][3]))

    def test_save_then_compare_reports_changes(self):
        ops = {"S > A": {"preset_name": "P1", "tool_number": 7}}
        snap1 = {"document": "Bracket v3", "ts": "t0", "tool_count": 5, "tool_numbers": [7], "ops": ops}
        msg = self.a.run_snapshot_action(self.a.SNAPSHOT_SAVE, snapshot_fn=lambda: snap1)
        self.assertIn("Snapshot saved", msg)
        files = os.listdir(os.path.join(self._tmp.name, "snapshots"))
        self.assertEqual(len(files), 1)
        self.assertTrue(files[0].startswith("Bracket_") and files[0].endswith(".json"))   # " v3" stripped
        snap2 = dict(snap1, ops={"S > A": {"preset_name": "P2", "tool_number": 7}, "S > B": {"preset_name": "P1"}})
        msg = self.a.run_snapshot_action(self.a.SNAPSHOT_COMPARE, snapshot_fn=lambda: snap2)
        self.assertIn("2 change(s)", msg)
        self.assertIn("S > A: preset 'P1' -> 'P2'", msg)
        self.assertIn("S > B: operation added", msg)
        self.assertIn("SNAPSHOT DIFF:", self.log_text())

    def test_compare_uses_newest_and_caps_listing(self):
        d = os.path.join(self._tmp.name, "snapshots")
        os.makedirs(d)
        for stamp, preset in (("20260101_000000", "OLD"), ("20260102_000000", "NEW")):
            with open(os.path.join(d, f"Bracket_{stamp}.json"), "w", encoding="utf-8") as f:
                json.dump({"document": "Bracket", "ts": stamp, "ops": {f"S > Op{i}": {"preset_name": preset}
                                                                        for i in range(40)}}, f)
        cur = {"document": "Bracket v9", "ops": {f"S > Op{i}": {"preset_name": "NEW"} for i in range(40)}}
        text, changes, path = self.a.compare_with_last_snapshot(cur)
        self.assertEqual(changes, [])
        self.assertTrue(path.endswith("20260102_000000.json"))
        cur["ops"] = {f"S > Op{i}": {"preset_name": "Z"} for i in range(40)}
        text, changes, _ = self.a.compare_with_last_snapshot(cur)
        self.assertEqual(len(changes), 40)
        self.assertIn("and 15 more", text)
        self.assertEqual(text.count("\n - "), 25)

    def test_compare_without_snapshot(self):
        msg = self.a.run_snapshot_action(
            self.a.SNAPSHOT_COMPARE, snapshot_fn=lambda: {"document": "X", "ops": {"S > A": {}}})
        self.assertIn("No saved snapshot", msg)


if __name__ == "__main__":
    unittest.main()
