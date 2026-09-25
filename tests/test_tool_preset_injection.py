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

from ToolWizFusionAddin import json_mutator

class TestToolPresetInjection(unittest.TestCase):
    def setUp(self):
        self.sample_tool_json = json.dumps({
            "description": "1/32\" 4 Flute Carbide Endmill",
            "geometry": {
                "DC": 0.03125,
                "NOF": 4,
                "LCF": 0.09375
            },
            "post-process": {
                "number": 11,
                "diameter-offset": 11,
                "length-offset": 11
            },
            "start-values": {
                "presets": [
                    {
                        "guid": "existing-preset-guid-1234",
                        "name": "Default preset",
                        "description": "Default preset",
                        "n": "5000.000000rpm",
                        "v_f": "20.000000in/min"
                    }
                ]
            }
        })

    def test_mutate_tool_json_injects_full_material_preset(self):
        new_preset_data = {
            "name": "Black Titanium 5545 - Finishing",
            "material_query": "Black Titanium 5545",
            "material_category": "metal",
            "rpm": 12224,
            "feed": 12.2,
            "doc": 0.005,
            "woc": 0.002,
            "sfm": 100,
            "ipt": 0.00025,
            "tool_number": 11,
            "flutes": 4
        }
        
        mutated_json, final_preset_name, was_updated = json_mutator.mutate_tool_json(
            self.sample_tool_json, new_preset_data
        )
        
        self.assertEqual(final_preset_name, "Black Titanium 5545 - Finishing")
        self.assertFalse(was_updated)
        
        mutated_dict = json.loads(mutated_json)
        presets = mutated_dict["start-values"]["presets"]
        self.assertEqual(len(presets), 2)
        
        bt_preset = presets[1]
        self.assertEqual(bt_preset["name"], "Black Titanium 5545 - Finishing")
        self.assertIn("guid", bt_preset)
        self.assertTrue(len(bt_preset["guid"]) > 0)
        self.assertEqual(bt_preset["material"]["query"], "Black Titanium 5545")
        self.assertEqual(bt_preset["material"]["category"], "metal")
        self.assertEqual(bt_preset["n"], 12224.0)
        self.assertEqual(bt_preset["v_f"], 12.2)
        self.assertEqual(bt_preset["stepdown"], 0.005)
        self.assertEqual(bt_preset["stepover"], 0.002)
        self.assertTrue(bt_preset["use-stepdown"])
        self.assertTrue(bt_preset["use-stepover"])
        
        # Verify tool number was preserved
        self.assertEqual(mutated_dict["post-process"]["number"], 11)

    def test_mutate_tool_json_replaces_existing_preset_preserving_guid(self):
        update_data = {
            "name": "Default preset",
            "material_query": "Black Titanium 5545",
            "rpm": 15000,
            "feed": 15.0,
            "doc": 0.01,
            "woc": 0.005,
            "sfm": 120,
            "ipt": 0.0003
        }
        
        mutated_json, final_preset_name, was_updated = json_mutator.mutate_tool_json(
            self.sample_tool_json, update_data, target_preset_to_replace="Default preset"
        )
        
        self.assertTrue(was_updated)
        mutated_dict = json.loads(mutated_json)
        presets = mutated_dict["start-values"]["presets"]
        self.assertEqual(len(presets), 1)
        self.assertEqual(presets[0]["guid"], "existing-preset-guid-1234")
        self.assertEqual(presets[0]["n"], 15000.0)
        self.assertEqual(presets[0]["material"]["query"], "Black Titanium 5545")

if __name__ == '__main__':
    unittest.main()
