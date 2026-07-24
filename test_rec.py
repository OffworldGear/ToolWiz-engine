import math
from gwizard_physics import GWizardPhysics

p = GWizardPhysics("materials_database_clean.json")
b_sfm = p.get_base_sfm('Aluminum - Wrought (6061)', 'Carbide Endmill')
b_ipt = p.get_base_ipt('Aluminum - Wrought (6061)', 'Carbide Endmill', 0.5)

for diff in [0.0, 0.5, 1.0]:
    t_sfm, t_ipt = p.apply_aggressiveness(b_sfm, b_ipt, diff)
    rpm = p.calc_rpm(t_sfm, 0.5, 16000)
    doc, woc, def_lim = p.recommend_cut_parameters(0.5, 0.5, 1.5, 4, rpm, t_ipt, True, "Roughing", diff)
    print(f"Aggr: {diff} | RPM: {rpm:<5.0f} | SFM: {t_sfm:<5.0f} | IPT: {t_ipt:<6.5f} | Rec DOC: {doc:<5.3f} | Rec WOC: {woc:<5.3f} | Deflect Lim: {def_lim:<7.5f}")
