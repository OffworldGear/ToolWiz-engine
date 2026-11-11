import unittest
import json
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from json_mutator import format_unit, mutate_tool_json

class TestFusionJsonMutator(unittest.TestCase):
    
    def test_unit_concatenation(self):
        # The document specifically states we MUST stringify numerical floats with units
        # e.g., "100in/min", "0.125in" to bypass the metric scaling bug
        self.assertEqual(format_unit(100.5, "in/min"), "100.500000in/min")
        self.assertEqual(format_unit(0.125, "in"), "0.125000in")
        self.assertEqual(format_unit(12000, "rpm"), "12000.000000rpm")

    def test_mutate_tool_json_new_preset(self):
        # A mock pristine Fusion tool json
        raw_json = json.dumps({
            "description": "1/4 Flat Endmill",
            "geometry": {"DC": 0.25},
            "start-values": {
                "presets": [
                    {"name": "Default", "n": "5000rpm", "v_f": "20in/min"}
                ]
            }
        })
        
        new_data = {
            "name": "ToolWiz Adaptive Roughing",
            "rpm": 12000,
            "feed": 100,
            "doc": 0.25,
            "woc": 0.05,
            "sfm": 800,
            "ipt": 0.002
        }
        
        mutated_json_str, preset_name, was_updated = mutate_tool_json(raw_json, new_data)
        mutated_dict = json.loads(mutated_json_str)
        
        self.assertEqual(preset_name, "ToolWiz Adaptive Roughing")
        self.assertFalse(was_updated)
        self.assertIsInstance(mutated_json_str, str)
        self.assertNotIn("post-process", mutated_dict)

        # Ensure geometry was NOT touched
        self.assertEqual(mutated_dict["geometry"]["DC"], 0.25)
        
        # Ensure preset was appended
        presets = mutated_dict["start-values"]["presets"]
        self.assertEqual(len(presets), 2)
        self.assertEqual(presets[0]["name"], "Default")
        
        # Ensure our payload was injected correctly with native numeric values
        our_preset = presets[1]
        self.assertEqual(our_preset["name"], "ToolWiz Adaptive Roughing")
        self.assertEqual(our_preset["n"], 12000.0)
        self.assertEqual(our_preset["v_f"], 100.0)
        self.assertEqual(our_preset["stepdown"], 0.25)
        self.assertEqual(our_preset["stepover"], 0.05)

    def test_mutate_tool_json_update_existing(self):
        raw_json = json.dumps({
            "start-values": {
                "presets": [
                    {"name": "ToolWiz Auto", "n": 5000, "v_f": 20}
                ]
            }
        })
        
        new_data = {
            "name": "ToolWiz Auto",
            "rpm": 15000,
            "feed": 150
        }
        
        mutated_json_str, preset_name, was_updated = mutate_tool_json(raw_json, new_data)
        mutated_dict = json.loads(mutated_json_str)
        presets = mutated_dict["start-values"]["presets"]
        
        self.assertTrue(was_updated)
        # Ensure it updated in place rather than appending
        self.assertEqual(len(presets), 1)
        self.assertEqual(presets[0]["n"], 15000.0)

if __name__ == '__main__':
    unittest.main()
