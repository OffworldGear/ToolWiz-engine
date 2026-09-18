import gwizard_physics
physics = gwizard_physics.GWizardPhysics('materials_database_clean.json')

angle, ramp, plunge = physics.calc_ramping('Copper Alloy', 0.0625, 7.2, geometry='Square', flutes=4, aggressiveness=0.52)
print(f"Angle: {angle}, Ramp Feed: {ramp}, Plunge Feed: {plunge}")
