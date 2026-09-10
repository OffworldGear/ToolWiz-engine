import json
import math
from gwizard_physics import GWizardPhysics, BeamDeflectionEngine, CuttingMechanics

physics = GWizardPhysics("materials_database_clean.json")

HARVEY_TEST_CASES = [
    {
        "case": "1. Harvey #909262 (1/4 in Keyseat, 4FL) in 6061-T6 Aluminum",
        "tool_number": "909262",
        "material_family": "Aluminum - Wrought (6061)",
        "alloy": "6061-T6",
        "geometry": "Keyseat",
        "flutes": 4,
        "diameter": 0.250,
        "flute_length": 0.0620,
        "neck_diameter": 0.1250,
        "neck_length": 0.3750,
        "shank_diameter": 0.250,
        "stickout": 0.500,
        "coating": "Uncoated",
        "harvey": {
            "sfm_profile": 1000,
            "ipt_profile": 0.00151,
            "ipt_slot_min": 0.00075,
            "ipt_slot_max": 0.00091,
            "rdoc": 0.030,
            "max_radial_reach": (0.250 - 0.125) / 2.0
        }
    },
    {
        "case": "2. Harvey #22393 (1/4 in Keyseat, 6FL) in 4140 Alloy Steel",
        "tool_number": "22393",
        "material_family": "Steel - Medium Carbon Alloy (4140)",
        "alloy": "4140 (Annealed)",
        "geometry": "Keyseat",
        "flutes": 6,
        "diameter": 0.250,
        "flute_length": 0.0930,
        "neck_diameter": 0.1250,
        "neck_length": 0.3750,
        "shank_diameter": 0.250,
        "stickout": 0.500,
        "coating": "AlTiN",
        "harvey": {
            "sfm_profile": 200,
            "ipt_profile": 0.00053,
            "ipt_slot_min": 0.00027,
            "ipt_slot_max": 0.00037,
            "rdoc": 0.020,
            "max_radial_reach": (0.250 - 0.125) / 2.0
        }
    },
    {
        "case": "3. Harvey #984330 (5/16 in Keyseat, 4FL) in 6061-T6 Aluminum",
        "tool_number": "984330",
        "material_family": "Aluminum - Wrought (6061)",
        "alloy": "6061-T6",
        "geometry": "Keyseat",
        "flutes": 4,
        "diameter": 0.3120,
        "flute_length": 0.0620,
        "neck_diameter": 0.1560,
        "neck_length": 0.4680,
        "shank_diameter": 0.3125,
        "stickout": 0.6250,
        "coating": "Uncoated",
        "harvey": {
            "sfm_profile": 1000,
            "ipt_profile": 0.00189,
            "ipt_slot_min": 0.00095,
            "ipt_slot_max": 0.00113,
            "rdoc": 0.037,
            "max_radial_reach": (0.3120 - 0.1560) / 2.0
        }
    },
    {
        "case": "4. Harvey #71130 (3/8 in Keyseat, 6FL) in 4140 Alloy Steel",
        "tool_number": "71130",
        "material_family": "Steel - Medium Carbon Alloy (4140)",
        "alloy": "4140 (Annealed)",
        "geometry": "Keyseat",
        "flutes": 6,
        "diameter": 0.3750,
        "flute_length": 0.0620,
        "neck_diameter": 0.1870,
        "neck_length": 0.5000,
        "shank_diameter": 0.3750,
        "stickout": 0.7500,
        "coating": "AlTiN",
        "harvey": {
            "sfm_profile": 200,
            "ipt_profile": 0.00079,
            "ipt_slot_min": 0.00040,
            "ipt_slot_max": 0.00054,
            "rdoc": 0.030,
            "max_radial_reach": (0.3750 - 0.1870) / 2.0
        }
    },
    {
        "case": "5. Harvey #71560 (1/2 in Keyseat, 6FL) in 316 Stainless Steel",
        "tool_number": "71560",
        "material_family": "Stainless - Austenitic (316)",
        "alloy": "316 (Annealed)",
        "geometry": "Keyseat",
        "flutes": 6,
        "diameter": 0.5000,
        "flute_length": 0.1250,
        "neck_diameter": 0.2500,
        "neck_length": 0.7500,
        "shank_diameter": 0.5000,
        "stickout": 1.0000,
        "coating": "AlTiN",
        "harvey": {
            "sfm_profile": 200,
            "ipt_profile": 0.00106,
            "ipt_slot_min": 0.00053,
            "ipt_slot_max": 0.00073,
            "rdoc": 0.040,
            "max_radial_reach": (0.5000 - 0.2500) / 2.0
        }
    }
]

print("=" * 88)
print("             HARVEY TOOL KEYSEAT CUTTER BENCHMARK EVALUATION REPORT")
print("=" * 88)

for tc in HARVEY_TEST_CASES:
    dia = tc["diameter"]
    fam = tc["material_family"]
    geom = tc["geometry"]
    flutes = tc["flutes"]
    flute_len = tc["flute_length"]
    neck_dia = tc["neck_diameter"]
    neck_len = tc["neck_length"]
    shank_dia = tc["shank_diameter"]
    stickout = tc["stickout"]
    coating = tc["coating"]
    alloy = tc["alloy"]
    h = tc["harvey"]
    
    # 1. Base Speeds & Feeds
    base_sfm = physics.get_base_sfm(fam, "Carbide Endmill", geometry=geom, diameter=dia)
    base_ipt = physics.get_base_ipt(fam, "Carbide Endmill", dia, geometry=geom)
    
    sfm_hard, ipt_hard = physics.apply_alloy_hardness_scaling(fam, alloy, base_sfm, base_ipt)
    sfm_chat, ipt_chat = physics.apply_chatter_penalty(sfm_hard, ipt_hard, dia, stickout, is_drilling=False)
    calc_sfm, calc_ipt = physics.apply_aggressiveness(sfm_chat, ipt_chat, 0.50)
    c_mult = physics.get_coating_multiplier(coating, fam)
    calc_sfm *= c_mult
    
    rpm = physics.calc_rpm(calc_sfm, dia, max_rpm=24000)
    
    # Auto-Set Recommendations
    rec_doc, rec_woc, rec_def = physics.recommend_cut_parameters(
        dia, shank_dia, stickout, flutes, rpm, calc_ipt, is_carbide=True,
        operation="Slotting", aggressiveness=0.50, geometry=geom,
        cutter_thickness=flute_len, max_hp=10.0, material_family=fam,
        neck_length=neck_len, flute_length=flute_len, neck_diameter=neck_dia
    )
    
    # Programmed Chipload & Feedrate with RCTF (as computed in app.py)
    adj_ipt = physics.calc_adjusted_chipload(calc_ipt, rec_doc, rec_woc, dia, dia, geometry=geom)
    feedrate = physics.calc_feedrate(rpm, flutes, adj_ipt)
    
    # Stepped Beam Deflection (Head + Neck + Shank)
    deflection_stepped = physics.tool_deflection(
        dia, shank_dia, stickout, rec_doc, rec_woc, feedrate, rpm, flutes,
        is_carbide=True, material_family=fam, neck_length=neck_len,
        flute_length=flute_len, neck_diameter=neck_dia
    )
    
    # Deflection if solid shank
    deflection_solid = physics.tool_deflection(
        dia, shank_dia, stickout, rec_doc, rec_woc, feedrate, rpm, flutes,
        is_carbide=True, material_family=fam, neck_length=0.0,
        flute_length=flute_len, neck_diameter=shank_dia
    )
    
    # True chip thickness and rubbing check
    mct = physics.get_minimum_chip_thickness(coating, "end mill", dia)
    tct = physics.get_true_chip_thickness(adj_ipt, rec_woc, dia)
    rubbing = tct < mct
    
    # Ramping check
    ramp_ang, ramp_f, plunge_f = physics.calc_ramping(fam, dia, feedrate, geometry=geom, flutes=flutes)
    
    print("\n[TEST CASE]: " + tc["case"])
    print(f"  * Tool Geometry:          Diameter = {dia}\" | Kerf = {flute_len}\" | Neck Dia = {neck_dia}\" | Reach = {neck_len}\" | Stickout = {stickout}\"")
    print(f"  * Speed (SFM):            Tool Wizard = {calc_sfm:<5.0f} | Harvey Target = {h['sfm_profile']:<5.0f} SFM")
    print(f"  * Slotting Chipload:      Tool Wizard = {calc_ipt:<7.5f} | Harvey Target = {h['ipt_slot_min']:.5f} - {h['ipt_slot_max']:.5f} IPT")
    print(f"  * Auto-Set Cut Depths:    Axial DOC   = {rec_doc:.4f}\" (Target Kerf: {flute_len:.4f}\")")
    print(f"                            Radial WOC  = {rec_woc:.4f}\" (Harvey RDOC: {h['rdoc']:.4f}\", Max Reach: {h['max_radial_reach']:.4f}\")")
    print(f"  * Kinematics with RCTF:   Spindle RPM = {rpm:<5.0f} min-1 | Programmed Feed = {feedrate:<6.2f} IPM (Adj IPT = {adj_ipt:.5f}\")")
    print(f"  * Beam Deflection:        Stepped Neck Deflection = {deflection_stepped*1000:6.3f} thou ({deflection_stepped:.5f}\")")
    print(f"                            Solid Shank Deflection  = {deflection_solid*1000:6.3f} thou ({deflection_solid:.5f}\")")
    print(f"                            Neck Flexibility Ratio  = {deflection_stepped/max(1e-6, deflection_solid):.1f}x higher deflection due to neck")
    print(f"  * Ramping Safety:         Ramp Angle = {ramp_ang:.1f} deg | Ramp Feed = {ramp_f:.1f} IPM (Locked to 0 for form tools)")
    print(f"  * Rubbing Protection:     TCT = {tct:.5f}\" vs MCT = {mct:.5f}\" -> {'SAFE (No Rubbing)' if not rubbing else 'WARNING: Rubbing'}")

print("\n" + "=" * 88)
print("                               BENCHMARK COMPLETED")
print("=" * 88)
