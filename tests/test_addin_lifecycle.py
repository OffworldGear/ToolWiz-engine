import unittest
from unittest.mock import MagicMock

from test_addin_common import load_addin


class FakeUI:
    """Minimal Fusion UI: command definitions and one toolbar panel, keyed by id."""

    def __init__(self):
        self.defs = {}
        self.controls = {}
        ui = self

        class Defs:
            def itemById(self, cid):
                return ui.defs.get(cid)

            def addButtonDefinition(self, cid, name, tooltip):
                d = MagicMock(name=cid)
                d.created_handlers = []
                d.commandCreated.add.side_effect = d.created_handlers.append
                d.deleteMe.side_effect = lambda: ui.defs.pop(cid, None)
                ui.defs[cid] = d
                return d

        class Controls:
            def itemById(self, cid):
                return ui.controls.get(cid)

            def addCommand(self, d):
                cid = next(k for k, v in ui.defs.items() if v is d)
                c = MagicMock()
                c.deleteMe.side_effect = lambda: ui.controls.pop(cid, None)
                ui.controls[cid] = c

        self.commandDefinitions = Defs()
        panel = MagicMock()
        panel.controls = Controls()
        ws = MagicMock()
        ws.toolbarPanels.itemById.return_value = panel
        self.workspaces = MagicMock()
        self.workspaces.itemById.return_value = ws


class TestAddinLifecycle(unittest.TestCase):
    def setUp(self):
        self.addin = load_addin()
        self.fake_ui = FakeUI()
        self.addin.adsk.core.Application.get.return_value.userInterface = self.fake_ui

    def test_stale_definition_from_previous_copy_is_replaced(self):
        # A previously loaded copy left a Stock command with its own created handler attached.
        stale = self.fake_ui.commandDefinitions.addButtonDefinition(self.addin.stockCommandId, "old", "")
        stale.commandCreated.add(object())
        self.addin.run(None)
        fresh = self.fake_ui.defs[self.addin.stockCommandId]
        self.assertIsNot(fresh, stale)
        self.assertEqual(len(fresh.created_handlers), 1)

    def test_run_twice_never_duplicates_handlers_or_controls(self):
        self.addin.run(None)
        self.addin.run(None)
        for cid, *_ in self.addin.COMMAND_SPECS:
            self.assertEqual(len(self.fake_ui.defs[cid].created_handlers), 1, cid)
        self.assertEqual(len(self.fake_ui.controls), len(self.addin.COMMAND_SPECS))
        self.assertEqual(len(self.addin.handlers), len(self.addin.COMMAND_SPECS))

    def test_stop_removes_everything(self):
        self.addin.run(None)
        self.addin.stop(None)
        self.assertEqual(self.fake_ui.defs, {})
        self.assertEqual(self.fake_ui.controls, {})


if __name__ == "__main__":
    unittest.main()
