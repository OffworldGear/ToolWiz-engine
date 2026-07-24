import os
import math
from gwizard_physics import GWizardPhysics

# Initialize our engine
physics = GWizardPhysics("materials_database_clean.json")

# Define our industrial benchmarks (Derived from Harvey Tool / Valor Speed & Feed Catalogs)
# These represent baseline 1.0x non-scaled performance recommendations.
BENCHMARKS = [
    {
        "name": "Harvey 0.125 Square Endmill - Aluminum 6061 (Roughing)",
        "inputs": {
            "family": "Aluminum - Wrought (6061)",
            "tool": "Carbide Endmill",
            "diameter": 0.125,
            "flutes": 3,
            "rpm_cap": 100000,
            "aggressiveness": 0.5 # 1.0x baseline scalar
        },
        "expected": {
            "sfm": 840,   # Harvey target typically 800-900 sfm for micro tools in alum
            "ipt": 0.0011 # Typical micro tool chipload target 
        }
    },
    {
        "name": "Valor 0.500 High Perf Endmill - Steel 1018 (Roughing)",
        "inputs": {
            "family": "Low Carbon Steel (1018)",
            "tool": "Carbide Endmill",
            "diameter": 0.5,
            "flutes": 4,
            "rpm_cap": 100000,
            "aggressiveness": 0.5
        },
        "expected": {
            "sfm": 435,   # Valor standard speed for low carbon
            "ipt": 0.0028 # Standard chipload
        }
    },
    {
        "name": "Harvey 0.250 T-Slot Cutter - Aluminum",
        "inputs": {
            "family": "Aluminum - Wrought (6061)",
            "tool": "Carbide Endmill",
            "diameter": 0.250,
            "flutes": 4,
            "rpm_cap": 100000,
            "aggressiveness": 0.5
        },
        "expected": {
            "sfm": 420,  # 50% penalty for T-Slots
            "ipt": 0.0008 # Restricted chipload for delicate T-slot necks
        }
    }
]

print("="*60)
print(" BENCHMARK REPORT: GWIZARD ENGINE vs HARVEY/VALOR TARGETS")
print("="*60)

for b in BENCHMARKS:
    family = b["inputs"]["family"]
    tool = b["inputs"]["tool"]
    dia = b["inputs"]["diameter"]
    aggr = b["inputs"]["aggressiveness"]
    
    geometry = "Square"
    if "T-Slot" in b["name"]:
        geometry = "T-Slot"
        
    b_sfm = physics.get_base_sfm(family, tool, geometry=geometry)
    b_ipt = physics.get_base_ipt(family, tool, dia, geometry=geometry)
    
    t_sfm, t_ipt = physics.apply_aggressiveness(b_sfm, b_ipt, aggr)
    
    print(f"\n[TEST]: {b['name']}")
    print(f"  -> Generated SFM: {t_sfm:<5.0f} | Target: {b['expected']['sfm']} | Error: {abs(t_sfm - b['expected']['sfm'])/b['expected']['sfm']*100:.1f}%")
    print(f"  -> Generated IPT: {t_ipt:<6.5f}| Target: {b['expected']['ipt']} | Error: {abs(t_ipt - b['expected']['ipt'])/b['expected']['ipt']*100:.1f}%")

print("\nAll benchmarks evaluated against baseline constraints successfully.")
