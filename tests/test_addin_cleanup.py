"""Clean Up Duplicate Tools: the planner must never remove a used tool, the last copy, or presets."""
import json
import unittest
from unittest.mock import MagicMock

from test_addin_common import load_addin


def tool(number, desc="1/4 flat", presets=(), guid=None, dc=0.25, ttype="flat end mill"):
    t = {"type": ttype, "unit": "inches", "description": desc,
         "geometry": {"DC": dc, "NOF": 4, "LCF": 0.75, "SFDM": 0.25, "LB": 1.0},
         "post-process": {"number": number},
         "start-values": {"presets": [{"name": n} for n in presets]}}
    if guid:
        t["guid"] = guid
    return t


class TestPlanner(unittest.TestCase):
    def setUp(self):
        self.a = load_addin()

    def plan(self, entries):
        return self.a.plan_duplicate_cleanup(
            [{"index": i, "tool": t, "used": u} for i, (t, u) in enumerate(entries)])

    def test_unused_duplicate_removed_used_kept(self):
        remove, skipped = self.plan([(tool(17, presets=["A"]), True), (tool(17, presets=["A"]), False)])
        self.assertEqual([r["index"] for r in remove], [1])
        self.assertEqual(skipped, [])

    def test_used_tools_never_removed(self):
        remove, _ = self.plan([(tool(17), True), (tool(17), True)])
        self.assertEqual(remove, [])

    def test_one_copy_always_kept_when_none_used(self):
        remove, _ = self.plan([(tool(5), False), (tool(5), False), (tool(5), False)])
        self.assertEqual(len(remove), 2)

    def test_copy_with_extra_presets_is_skipped(self):
        remove, skipped = self.plan([(tool(17, presets=["A"]), True), (tool(17, presets=["A", "B"]), False)])
        self.assertEqual(remove, [])
        self.assertIn("B", skipped[0]["reason"])

    def test_different_numbers_or_geometry_are_not_duplicates(self):
        remove, _ = self.plan([(tool(17), True), (tool(18), False), (tool(17, dc=0.5), False)])
        self.assertEqual(remove, [])

    def test_holders_ignored(self):
        remove, _ = self.plan([(tool(0, ttype="holder"), False), (tool(0, ttype="holder"), False)])
        self.assertEqual(remove, [])


class TestCollectorFailSafe(unittest.TestCase):
    def test_guid_mismatch_protects_whole_group(self):
        a = load_addin()
        lib_tools = [tool(17, guid="lib-1"), tool(17, guid="lib-2")]
        op_tool = tool(17, guid="copy-9")        # operation's copy has a different guid
        lib = MagicMock(); lib.count = 2
        lib.item.side_effect = lambda i: MagicMock(toJson=lambda i=i: json.dumps(lib_tools[i]))
        op = MagicMock(); op.tool.toJson.return_value = json.dumps(op_tool)
        setup = MagicMock(); setup.allOperations = [op]
        cam = MagicMock(); cam.documentToolLibrary = lib; cam.setups = [setup]
        a.adsk.cam.CAM.cast.return_value = cam
        a.app = MagicMock()
        _, entries = a._collect_document_tools()
        self.assertTrue(all(e["used"] for e in entries))
        remove, _ = a.plan_duplicate_cleanup(entries)
        self.assertEqual(remove, [])

    def test_registered_as_command(self):
        a = load_addin()
        self.assertIn(a.cleanupCommandId, [c[0] for c in a.COMMAND_SPECS])


if __name__ == "__main__":
    unittest.main()
