import unittest
from unittest.mock import MagicMock
import json
import sys
import os

for mod in ['adsk', 'adsk.core', 'adsk.cam', 'adsk.fusion']:
    sys.modules[mod] = MagicMock()

import importlib.util
addin_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'ToolWizFusionAddin', 'ToolWizFusionAddin.py'))
spec = importlib.util.spec_from_file_location("ToolWizFusionAddinModule", addin_path)
addin_mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(addin_mod)
extract_tool_number = addin_mod.extract_tool_number

class DummyVal:
    def __init__(self, val):
        self.value = val

class DummyParam:
    def __init__(self, val, expr=None):
        self.value = DummyVal(val)
        self.expression = expr

class DummyParams:
    def __init__(self, param_map):
        self.param_map = param_map
    def itemByName(self, name):
        return self.param_map.get(name)

class DummyTool:
    def __init__(self, json_str, num=None):
        self.json_str = json_str
        if num is not None:
            self.number = num
    def toJson(self):
        return self.json_str

class DummyOp:
    def __init__(self, params=None, tool=None):
        self.parameters = params
        self.tool = tool

class TestToolNumberDetection(unittest.TestCase):
    def test_op_param_number_numeric(self):
        params = DummyParams({'tool_number': DummyParam(11.0, '11')})
        op = DummyOp(params=params)
        self.assertEqual(extract_tool_number(op), 11)

    def test_op_param_number_expression_only(self):
        params = DummyParams({'tool_number': DummyParam(None, '11')})
        op = DummyOp(params=params)
        self.assertEqual(extract_tool_number(op), 11)

    def test_tool_json_post_process_hyphen(self):
        # Autodesk CAM tool library JSON format with hyphen
        t_json = json.dumps({
            "description": "1/32 Flat End Mill",
            "post-process": {
                "number": 11,
                "diameter-offset": 11,
                "length-offset": 11
            }
        })
        t_dict = json.loads(t_json)
        op = DummyOp(tool=DummyTool(t_json))
        self.assertEqual(extract_tool_number(op, t_dict), 11)

    def test_tool_json_postProcess_camel(self):
        t_json = json.dumps({
            "description": "1/32 Flat End Mill",
            "postProcess": {
                "number": 11
            }
        })
        t_dict = json.loads(t_json)
        op = DummyOp(tool=DummyTool(t_json))
        self.assertEqual(extract_tool_number(op, t_dict), 11)

    def test_tool_object_number_property(self):
        op = DummyOp(tool=DummyTool("{}", num=11))
        self.assertEqual(extract_tool_number(op), 11)

    def test_fallback_default_is_none(self):
        op = DummyOp()
        self.assertIsNone(extract_tool_number(op))

    def test_unknown_number_is_none_not_zero_or_one(self):
        t_json = json.dumps({"description": "no number", "post-process": {"number": 0}})
        op = DummyOp(tool=DummyTool(t_json))
        self.assertIsNone(extract_tool_number(op, json.loads(t_json)))
        self.assertIsNone(extract_tool_number(DummyOp(params=DummyParams({}))))
        self.assertIsNone(extract_tool_number(None))

if __name__ == '__main__':
    unittest.main()
