# -*- coding: utf-8 -*-
from gwizard_physics import GWizardPhysics
p = GWizardPhysics("materials_database_clean.json")

tools = [
    "Carbide Endmill", "HP Carbide Endmill", "HSS Endmill", "Indexable End Or Face Mill",
    "Carbide Twist Drill", "HSS Twist Drill", "HSS Spot Drill", "Gun Drill",
    "HSS Reamer", "Tapping", "Carbide Thread Mill", "Turning: Carbide"
]

material = "Steel - Low Carbon (1020)"

print(f"{'Tool':<30} | {'SFM':<8} | {'IPT (1/4 in)':<12} | {'IPT (1/2 in)':<12}")
print("-" * 68)
for t in tools:
    try:
        sfm = p.get_base_sfm(material, t, diameter=0.5)
        ipt_quarter = p.get_base_ipt(material, t, 0.250)
        ipt_half = p.get_base_ipt(material, t, 0.500)
        print(f"{t:<30} | {sfm:<8.1f} | {ipt_quarter:<12.5f} | {ipt_half:<12.5f}")
    except Exception as e:
        print(f"{t:<30} | ERROR: {e}")
