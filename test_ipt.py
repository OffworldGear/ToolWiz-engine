import gwizard_physics
physics = gwizard_physics.GWizardPhysics('materials_database_clean.json')

family = "Copper Alloy - Wrought"
alloy = "C72900 - Toughmet 3 Nickel Bronze" # without (Annealed)
tool = "TiAlN Carbide Endmill"
diameter = 0.0625

base_sfm = physics.get_base_sfm(family, tool)
base_ipt = physics.get_base_ipt(family, tool, diameter)
print(f"Raw base_ipt for {family}, {tool}, {diameter}: {base_ipt}")

h_sfm, h_ipt = physics.apply_alloy_hardness_scaling(family, alloy, base_sfm, base_ipt)
print(f"After hardness scaling: {h_ipt}")
