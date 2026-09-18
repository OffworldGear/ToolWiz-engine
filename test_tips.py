import gwizard_physics
physics = gwizard_physics.GWizardPhysics('materials_database_clean.json')

tips = physics.generate_advanced_strategies(
    material_family="Copper Alloy - Wrought",
    diameter=0.0625,
    cut_depth=0.010,
    cut_width=0.063,
    feedrate=7.2,
    rpm=7209,
    flutes=4,
    coating="AlTiN",
    deflection_inches=0.00021,
    tool_type="end mill",
    stickout=0.188,
    geometry="Square"
)

for t in tips:
    if "Rubbing" in t["title"]:
        print(t["message"])
