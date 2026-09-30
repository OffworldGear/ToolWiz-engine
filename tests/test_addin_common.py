"""Shared loader for the Fusion add-in tests (adsk is mocked; Fusion is not needed)."""
import importlib.util
import os
import sys
from unittest.mock import MagicMock

ADDIN_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'ToolWizFusionAddin', 'ToolWizFusionAddin.py'))
REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))


def load_addin():
    """Load a fresh copy of the add-in module with adsk mocked."""
    adsk, core, cam, fusion = MagicMock(), MagicMock(), MagicMock(), MagicMock()
    # Real (empty) handler base classes so the add-in's handler classes are genuine classes.
    for name in ('CommandEventHandler', 'CommandCreatedEventHandler', 'InputChangedEventHandler'):
        setattr(core, name, type(name, (object,), {}))
    adsk.core, adsk.cam, adsk.fusion = core, cam, fusion
    sys.modules.update({'adsk': adsk, 'adsk.core': core, 'adsk.cam': cam, 'adsk.fusion': fusion})
    spec = importlib.util.spec_from_file_location("ToolWizFusionAddinModule", ADDIN_PATH)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def param(expr, value=None):
    """A MagicMock CAM parameter with the given expression (and optional evaluated value)."""
    p = MagicMock()
    p.expression = expr
    p.value.value = value
    p.isEnabled = True
    return p


class ParamsByName:
    """op.parameters stand-in: itemByName returns the mapped param or None."""
    def __init__(self, mapping):
        self.mapping = mapping

    def itemByName(self, name):
        return self.mapping.get(name)
