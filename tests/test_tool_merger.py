import unittest
import json
import os
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from tool_merger import (
    parse_dimension_in,
    compute_tool_signature,
    merge_presets_lists,
    deduplicate_tools,
    merge_multiple_libraries,
    clean_tool_presets
)

class TestToolMerger(unittest.TestCase):

    def test_parse_dimension_in(self):
        # Imperial floats and strings
        self.assertAlmostEqual(parse_dimension_in(0.5, "inches"), 0.5)
        self.assertAlmostEqual(parse_dimension_in("0.5 in", "inches"), 0.5)
        self.assertAlmostEqual(parse_dimension_in("1/4 in", "inches"), 0.25)
        self.assertAlmostEqual(parse_dimension_in("3/8", "inches"), 0.375)

        # Metric floats and strings
        self.assertAlmostEqual(parse_dimension_in(25.4, "millimeters"), 1.0)
        self.assertAlmostEqual(parse_dimension_in("6.35 mm", "millimeters"), 0.25)
        self.assertAlmostEqual(parse_dimension_in("12 mm", "mm"), 12.0 / 25.4)

    def test_tool_signature_matching(self):
        # Two tools with same geometry defined in inches vs mm
        tool_in = {
            "type": "flat end mill",
            "unit": "inches",
            "geometry": {"DC": 0.5, "NOF": 4, "LCF": 1.25, "SF": 0.5, "RE": 0.0}
        }
        tool_mm = {
            "type": "end mill",
            "unit": "millimeters",
            "geometry": {"DC": 12.7, "NOF": 4, "LCF": 31.75, "SF": 12.7, "RE": 0.0}
        }
        sig_in = compute_tool_signature(tool_in)
        sig_mm = compute_tool_signature(tool_mm)
        self.assertEqual(sig_in, sig_mm, "Inch and metric representations of 0.5in 4-flute endmill should produce identical signatures")

    def test_preset_merging(self):
        presets_a = [
            {"name": "6061-T6 - Roughing", "v_f": "50.0in/min", "n": "10000rpm"},
            {"name": "Default Preset", "v_f": "0in/min", "n": "5000rpm"}
        ]
        presets_b = [
            {"name": "6061-T6 - Finishing", "v_f": "30.0in/min", "n": "12000rpm"},
            {"name": "Default Preset", "v_f": "25.0in/min", "n": "5000rpm"}
        ]
        merged = merge_presets_lists(presets_a, presets_b)
        names = [p["name"] for p in merged]
        self.assertEqual(len(merged), 3)
        self.assertIn("6061-T6 - Roughing", names)
        self.assertIn("6061-T6 - Finishing", names)
        self.assertIn("Default Preset", names)
        # Verify higher-information preset was chosen
        default_preset = next(p for p in merged if p["name"] == "Default Preset")
        self.assertEqual(default_preset["v_f"], "25.0in/min")

    def test_deduplicate_tools(self):
        tool1 = {
            "description": "1/2in 4FL Endmill (Copy A)",
            "unit": "inches",
            "geometry": {"DC": 0.5, "NOF": 4, "LCF": 1.0, "SF": 0.5, "RE": 0.0},
            "postProcess": {"number": 1},
            "start-values": {"presets": [{"name": "Aluminum Roughing", "v_f": "80 in/min"}]}
        }
        tool2 = {
            "description": "1/2in 4FL Carbide Endmill (Copy B)",
            "unit": "inches",
            "geometry": {"DC": 0.5, "NOF": 4, "LCF": 1.0, "SF": 0.5, "RE": 0.0},
            "postProcess": {"number": 0},
            "start-values": {"presets": [{"name": "Titanium Finishing", "v_f": "15 in/min"}]}
        }
        tool3 = {
            "description": "1/4in 2FL Ball Endmill",
            "type": "ball end mill",
            "unit": "inches",
            "geometry": {"DC": 0.25, "NOF": 2, "LCF": 0.5, "SF": 0.25, "RE": 0.125},
            "postProcess": {"number": 2},
            "start-values": {"presets": [{"name": "Mold 3D Finishing", "v_f": "45 in/min"}]}
        }

        tools_list = [tool1, tool2, tool3]
        deduped, report = deduplicate_tools(tools_list, preserve_presets=True)

        self.assertEqual(len(deduped), 2, "Should collapse 3 tools into 2 unique physical tools")
        self.assertEqual(report["duplicates_removed"], 1)

        # Check merged 1/2in tool
        half_in_tool = next(t for t in deduped if t["geometry"]["DC"] == 0.5)
        # Should retain Tool #1 (greater than 0)
        self.assertEqual(half_in_tool["postProcess"]["number"], 1)
        # Should have both presets
        presets = half_in_tool["start-values"]["presets"]
        preset_names = [p["name"] for p in presets]
        self.assertIn("Aluminum Roughing", preset_names)
        self.assertIn("Titanium Finishing", preset_names)

    def test_merge_multiple_libraries(self):
        lib1 = {
            "library_name": "Aluminum_Cutters",
            "tools": [
                {
                    "description": "3/8 Flat Endmill",
                    "geometry": {"DC": 0.375, "NOF": 3, "LCF": 0.75, "SF": 0.375, "RE": 0.0},
                    "start-values": {"presets": [{"name": "6061 - Adaptive", "v_f": "120 in/min"}]}
                }
            ]
        }
        lib2 = {
            "library_name": "Steel_Cutters",
            "tools": [
                {
                    "description": "3/8 Flat Endmill",
                    "geometry": {"DC": 0.375, "NOF": 3, "LCF": 0.75, "SF": 0.375, "RE": 0.0},
                    "start-values": {"presets": [{"name": "4140 - Adaptive", "v_f": "45 in/min"}]}
                },
                {
                    "description": "1/8 2FL Drill",
                    "type": "drill",
                    "geometry": {"DC": 0.125, "NOF": 2, "LCF": 1.0, "SF": 0.125, "RE": 0.0},
                    "start-values": {"presets": [{"name": "Drill 4140", "v_f": "10 in/min"}]}
                }
            ]
        }

        master_lib, summary = merge_multiple_libraries([lib1, lib2], "Master_Shop_Crib", deduplicate=True)
        self.assertEqual(summary["total_incoming_tools"], 3)
        self.assertEqual(summary["final_tool_count"], 2)
        self.assertEqual(summary["duplicates_removed"], 1)

        # Verify the 3/8 cutter in master crib contains presets from both libraries
        t_3_8 = next(t for t in master_lib["tools"] if t["geometry"]["DC"] == 0.375)
        p_names = [p["name"] for p in t_3_8["start-values"]["presets"]]
        self.assertIn("6061 - Adaptive", p_names)
        self.assertIn("4140 - Adaptive", p_names)

    def test_clean_tool_presets(self):
        tool = {
            "start-values": {
                "presets": [
                    {"name": "Default Preset"},
                    {"name": "Black Titanium 5545 - Adaptive Roughing"},
                    {"name": "Black Titanium 5545 - Finishing"},
                    {"name": "6061-T6 Aluminum - Finishing"}
                ]
            }
        }
        # Replace only Black Titanium presets
        cleaned_tool, removed = clean_tool_presets(tool, clean_all_non_toolwiz=False, target_material_to_replace="Black Titanium 5545")
        self.assertEqual(removed, 2)
        remaining_names = [p["name"] for p in cleaned_tool["start-values"]["presets"]]
        self.assertNotIn("Black Titanium 5545 - Adaptive Roughing", remaining_names)
        self.assertIn("6061-T6 Aluminum - Finishing", remaining_names)
        self.assertIn("Default Preset", remaining_names)

        # Now clean generic default
        cleaned_tool2, removed2 = clean_tool_presets(cleaned_tool, clean_all_non_toolwiz=True)
        self.assertEqual(removed2, 1)
        remaining_names2 = [p["name"] for p in cleaned_tool2["start-values"]["presets"]]
        self.assertNotIn("Default Preset", remaining_names2)
        self.assertIn("6061-T6 Aluminum - Finishing", remaining_names2)

if __name__ == '__main__':
    unittest.main()
