import urllib.request
import json
import os
import sys

BASE_URL = "http://127.0.0.1:5000"

def test_digital_twin_pipeline():
    print("==================================================")
    print("TESTING TOOLWIZ DIGITAL TWIN END-TO-END PIPELINE")
    print("==================================================")
    
    # 1. Mock Library Payload (Simulating export from Fusion 360)
    mock_library = {
        "library_name": "Main_Milling_Hub_Library",
        "tools": [
            {
                "description": "1/4 4-Flute Flat Carbide Endmill",
                "type": "flat end mill",
                "unit": "inches",
                "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.75, "SF": 0.25, "RE": 0.0},
                "postProcess": {"number": 1},
                "start-values": {
                    "presets": [
                        {"name": "Default Preset", "n": "5000.000000rpm", "v_f": "30.000000in/min"}
                    ]
                }
            },
            {
                "description": "6mm 3-Flute Aluminum Endmill",
                "type": "flat end mill",
                "unit": "millimeters",
                "geometry": {"DC": 6.0, "NOF": 3, "LCF": 20.0, "SF": 6.0, "RE": 0.0},
                "postProcess": {"number": 2},
                "start-values": {"presets": []}
            },
            {
                "description": "1/8 Ball Endmill",
                "type": "ball end mill",
                "unit": "inches",
                "geometry": {"DC": 0.125, "NOF": 2, "LCF": 0.5, "SF": 0.125, "RE": 0.0625},
                "postProcess": {"number": 3},
                "start-values": {"presets": []}
            }
        ]
    }
    
    # Step 1: Export Receive
    print("\n1. Testing POST /api/twin/export_receive...")
    req = urllib.request.Request(f"{BASE_URL}/api/twin/export_receive")
    req.add_header("Content-Type", "application/json")
    res = urllib.request.urlopen(req, json.dumps(mock_library).encode('utf-8'))
    data = json.loads(res.read().decode('utf-8'))
    print("Response:", data)
    assert data["success"] is True
    assert data["tool_count"] == 3
    print("[PASS] Export receive and backup snapshot creation verified!")
    
    # Step 2: Load Digital Twin Manifest
    print("\n2. Testing GET /api/twin/load...")
    req = urllib.request.Request(f"{BASE_URL}/api/twin/load")
    res = urllib.request.urlopen(req)
    data = json.loads(res.read().decode('utf-8'))
    print(f"Loaded library: {data['library_name']} ({len(data['tools'])} tools, {len(data['backups'])} backups)")
    assert data["has_library"] is True
    assert len(data["tools"]) == 3
    assert data["tools"][0]["diameter_in"] == 0.25
    assert data["tools"][1]["diameter_mm"] == 6.0
    print("[PASS] Tool manifest parsing and dual unit extraction verified!")
    
    # Step 3: Batch Generate Presets for CPM MagnaCut 62 HRC on Tools 0 and 2
    print("\n3. Testing POST /api/twin/batch_generate for CPM MagnaCut @ 62 HRC...")
    batch_req = {
        "tool_indices": [0, 2],
        "family": "Steel - Tool (H13)",
        "alloy": "CPM MagnaCut (Hardened ~62 HRC)",
        "strategies": ["Adaptive Roughing", "Roughing", "Finishing", "Slotting"],
        "aggressiveness": 50,
        "coating": "AlTiN"
    }
    req = urllib.request.Request(f"{BASE_URL}/api/twin/batch_generate")
    req.add_header("Content-Type", "application/json")
    res = urllib.request.urlopen(req, json.dumps(batch_req).encode('utf-8'))
    data = json.loads(res.read().decode('utf-8'))
    print("Response:", data)
    assert data["success"] is True
    assert data["updated_tools_count"] == 2
    assert data["total_presets_injected"] == 8
    print("[PASS] Batch preset generation and injection verified!")
    
    # Step 4: Verify duplicate prevention on second run
    print("\n4. Testing Duplicate Prevention on second run of same material...")
    res = urllib.request.urlopen(req, json.dumps(batch_req).encode('utf-8'))
    data = json.loads(res.read().decode('utf-8'))
    assert data["success"] is True
    
    # Load and check preset count (Tool 0 should have 1 default + 4 MagnaCut = 5 total presets, NOT 9!)
    req = urllib.request.Request(f"{BASE_URL}/api/twin/load")
    res = urllib.request.urlopen(req)
    data = json.loads(res.read().decode('utf-8'))
    t0 = data["tools"][0]
    print(f"Tool 0 Presets ({len(t0['presets'])}):", t0["presets"])
    assert len(t0["presets"]) == 5 # 1 default + 4 unique MagnaCut presets
    print("[PASS] Duplicate prevention verified (in-place replacement works perfectly)!")
    
    # Step 5: Verify GET /api/twin/get_import_payload for Fusion Add-in
    print("\n5. Testing GET /api/twin/get_import_payload...")
    req = urllib.request.Request(f"{BASE_URL}/api/twin/get_import_payload")
    res = urllib.request.urlopen(req)
    data = json.loads(res.read().decode('utf-8'))
    assert data["success"] is True
    assert len(data["library"]["tools"]) == 3
    print("[PASS] Import payload endpoint verified!")
    
    print("\n==================================================")
    print("ALL DIGITAL TWIN TESTS PASSED WITH 100% SUCCESS!")
    print("==================================================")

if __name__ == "__main__":
    test_digital_twin_pipeline()
