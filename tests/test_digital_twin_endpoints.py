import unittest
import json
import os
import sys
import tempfile

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
import app as app_module
from app import app
from backup_manager import BackupManager

class TestDigitalTwinEndpoints(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.orig_bm = app_module.bm
        self.bm = BackupManager(base_dir=self.temp_dir.name)
        app_module.bm = self.bm
        self.client = app.test_client()

        # Seed mock working library with duplicates and presets
        mock_library = {
            "library_name": "Test_Master_Crib",
            "tools": [
                {
                    "description": "1/2 4FL Flat Carbide Endmill (Copy 1)",
                    "type": "flat end mill",
                    "unit": "inches",
                    "geometry": {"DC": 0.5, "NOF": 4, "LCF": 1.0, "SF": 0.5, "RE": 0.0},
                    "postProcess": {"number": 5},
                    "start-values": {
                        "presets": [
                            {"name": "6061-T6 - Roughing", "v_f": "60 in/min", "material": {"query": "6061-T6"}}
                        ]
                    }
                },
                {
                    "description": "1/2 4FL Flat Carbide Endmill (Copy 2 - Duplicate)",
                    "type": "flat end mill",
                    "unit": "inches",
                    "geometry": {"DC": 0.5, "NOF": 4, "LCF": 1.0, "SF": 0.5, "RE": 0.0},
                    "postProcess": {"number": 5},
                    "start-values": {
                        "presets": [
                            {"name": "Black Titanium 5545 - Finishing", "v_f": "12 in/min", "material": {"query": "Black Titanium 5545"}}
                        ]
                    }
                },
                {
                    "description": "1/4 4FL Flat Endmill (Extended Reach)",
                    "type": "flat end mill",
                    "unit": "inches",
                    "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.75, "SF": 0.25, "RE": 0.0},
                    "postProcess": {"number": 12},
                    "custom_aggressiveness": 25.0, # Conservative override!
                    "start-values": {"presets": []}
                }
            ]
        }
        self.bm.save_working_library(mock_library, "Test_Master_Crib")

    def tearDown(self):
        app_module.bm = self.orig_bm
        self.temp_dir.cleanup()

    def test_twin_load(self):
        resp = self.client.get('/api/twin/load')
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertTrue(data['has_library'])
        self.assertEqual(data['tool_count'], 3)
        self.assertEqual(data['total_presets_count'], 2)
        # Check that tool #12 has custom_aggressiveness
        t12 = next(t for t in data['tools'] if t['number'] == 12)
        self.assertEqual(t12['custom_aggressiveness'], 25.0)

    def test_twin_deduplicate_endpoint(self):
        resp = self.client.post('/api/twin/deduplicate')
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertTrue(data['success'])
        self.assertEqual(data['initial_tool_count'], 3)
        self.assertEqual(data['tool_count'], 2, "Duplicate 1/2in cutter should be merged")
        self.assertEqual(data['report']['duplicates_removed'], 1)

        # Check that both presets were consolidated into the single 1/2in cutter
        load_resp = self.client.get('/api/twin/load')
        load_data = load_resp.get_json()
        half_in_tool = next(t for t in load_data['tools'] if t['diameter_in'] == 0.5)
        self.assertEqual(half_in_tool['preset_count'], 2)
        preset_names = [p['name'] for p in half_in_tool['presets']]
        self.assertIn("6061-T6 - Roughing", preset_names)
        self.assertIn("Black Titanium 5545 - Finishing", preset_names)

    def test_twin_update_tool_and_aggressiveness(self):
        # Update tool 1's description and custom aggressiveness
        resp = self.client.post('/api/twin/update_tool', json={
            "tool_index": 0,
            "description": "Custom Updated 1/2 Rougher",
            "custom_aggressiveness": 85.0
        })
        self.assertEqual(resp.status_code, 200)

        load_resp = self.client.get('/api/twin/load')
        load_data = load_resp.get_json()
        self.assertEqual(load_data['tools'][0]['description'], "Custom Updated 1/2 Rougher")
        self.assertEqual(load_data['tools'][0]['custom_aggressiveness'], 85.0)

    def test_batch_generate_with_per_tool_aggressiveness(self):
        # First deduplicate
        self.client.post('/api/twin/deduplicate')

        # Batch generate for Black Titanium 5545 with 50% baseline
        # Tool 0 (1/2 in) has no override -> uses 50%
        # Tool 1 (1/4 in) has custom_aggressiveness = 25.0 -> uses 25%
        resp = self.client.post('/api/twin/batch_generate', json={
            "tool_indices": "all",
            "family": "Black Titanium 5545",
            "alloy": "Black Titanium 5545",
            "strategies": ["Adaptive Roughing", "Finishing", "Floor Finishing"],
            "base_aggressiveness": 50.0,
            "use_tool_overrides": True,
            "clean_existing_for_material": True
        })
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertTrue(data['success'])
        self.assertEqual(data['updated_tools_count'], 2)

        # Verify that Tool 1 received 25% aggressiveness in preset description and lower chipload
        load_resp = self.client.get('/api/twin/load')
        load_data = load_resp.get_json()
        t_quarter = next(t for t in load_data['tools'] if t['diameter_in'] == 0.25)
        p_finish = next(p for p in t_quarter['presets'] if "Black Titanium 5545 - Finishing" in p['name'])
        self.assertIn("Aggressiveness: 25%", p_finish['description'])

    def test_twin_delete_tool(self):
        resp = self.client.post('/api/twin/delete_tool', json={"tool_index": 0})
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertTrue(data['success'])
        self.assertEqual(data['remaining_tools'], 2)

if __name__ == '__main__':
    unittest.main()
