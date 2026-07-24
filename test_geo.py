import math
from gwizard_physics import GWizardPhysics

p = GWizardPhysics("materials_database_clean.json")
b_sfm = 1000
b_ipt = 0.002
d = 0.125
w = 0.125
flutes = 4

for geo in ['Square', 'Radiused', 'Ball', 'Drill']:
    sfm = p.get_base_sfm("Aluminum - Wrought (6061)", "Carbide Endmill", geometry=geo)
    ipt = p.get_base_ipt("Aluminum - Wrought (6061)", "Carbide Endmill", d, geometry=geo)
    
    # Let's test a very shallow cut: 0.250"
    eff_d = p.calc_effective_diameter(d, 0.250, geometry=geo, corner_radius=0.030)
    rpm = p.calc_rpm(sfm, eff_d)
    adj_ipt = p.calc_adjusted_chipload(ipt, 0.250, w, d, eff_d, geometry=geo)
    feed = p.calc_feedrate(rpm, flutes, adj_ipt)
    print(f"{geo:<10} | Eff D: {eff_d:.4f} | RPM: {rpm:6.0f} | IPT: {ipt:.5f} | Adj IPT: {adj_ipt:.5f} | Feed: {feed:.1f}")
