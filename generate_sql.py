import json
import logging

def clean_str(s):
    if s is None:
        return "NULL"
    if isinstance(s, bool):
        return "true" if s else "false"
    if isinstance(s, (int, float)):
        return str(s)
    
    # Escape single quotes for SQL
    return "'" + str(s).replace("'", "''") + "'"

with open('materials_database_clean.json', 'r', encoding='utf-8') as f:
    db = json.load(f)

sql = []

sql.append("-- GWizard Postgres Export")
sql.append("-- Generated based on extracted logic and parameters")
sql.append("")

sql.append("BEGIN;")
sql.append("")

# Table: material_families
sql.append("""CREATE TABLE IF NOT EXISTS material_families (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb
);""")

# Table: machinability
sql.append("""CREATE TABLE IF NOT EXISTS machinability (
    family_id INTEGER REFERENCES material_families(id) ON DELETE CASCADE PRIMARY KEY,
    machinability_factor NUMERIC,
    density NUMERIC,
    min_bhn INTEGER,
    max_bhn INTEGER,
    dry_multiplier NUMERIC,
    sfm_range INTEGER,
    sfm_range_hss INTEGER,
    cexp NUMERIC,
    coating_rec VARCHAR(255),
    drill_style VARCHAR(255),
    point_style VARCHAR(255),
    point_angle VARCHAR(255),
    thread_mill NUMERIC,
    pcd_em NUMERIC
);""")

# Table: specific_alloys
sql.append("""CREATE TABLE IF NOT EXISTS specific_alloys (
    id SERIAL PRIMARY KEY,
    family_id INTEGER REFERENCES material_families(id) ON DELETE CASCADE,
    alloy_name VARCHAR(255),
    condition VARCHAR(255),
    hardness VARCHAR(255),
    metadata JSONB DEFAULT '{}'::jsonb
);""")

# Table: tool_types
sql.append("""CREATE TABLE IF NOT EXISTS tool_types (
    id SERIAL PRIMARY KEY,
    label VARCHAR(255) UNIQUE NOT NULL,
    is_lathe BOOLEAN,
    is_mill BOOLEAN,
    is_carbide BOOLEAN,
    chip_thinning BOOLEAN,
    has_coating BOOLEAN,
    metadata JSONB DEFAULT '{}'::jsonb
);""")

# Table: sfm_data
sql.append("""CREATE TABLE IF NOT EXISTS sfm_data (
    family_id INTEGER REFERENCES material_families(id) ON DELETE CASCADE,
    tool_type_id INTEGER REFERENCES tool_types(id) ON DELETE CASCADE,
    base_sfm NUMERIC,
    tsc_multiplier NUMERIC,
    PRIMARY KEY(family_id, tool_type_id)
);""")

# Table: ipt_data
# Diameters map: 0.0625,0.125,0.1875,0.25,0.375,0.5,0.75,1,1.5,2,3,4,5
sql.append("""CREATE TABLE IF NOT EXISTS ipt_data (
    family_id INTEGER REFERENCES material_families(id) ON DELETE CASCADE,
    tool_type_id INTEGER REFERENCES tool_types(id) ON DELETE CASCADE,
    d_0_0625 NUMERIC,
    d_0_125 NUMERIC,
    d_0_1875 NUMERIC,
    d_0_25 NUMERIC,
    d_0_375 NUMERIC,
    d_0_5 NUMERIC,
    d_0_75 NUMERIC,
    d_1_0 NUMERIC,
    d_1_5 NUMERIC,
    d_2_0 NUMERIC,
    d_3_0 NUMERIC,
    d_4_0 NUMERIC,
    d_5_0 NUMERIC,
    PRIMARY KEY(family_id, tool_type_id)
);""")

sql.append("")

family_map = {} # name -> id
tool_map = {} # name -> id

# INSERT: material_families
family_names = set([x.get("name") for x in db.get("material_families", []) if isinstance(x, dict) and "name" in x])
# Add missing from machinability
for m in db.get("machinability_factors", []):
    if m.get("material"): family_names.add(m["material"])

family_id_counter = 1
for name in sorted(family_names):
    sql.append(f"INSERT INTO material_families (id, name) VALUES ({family_id_counter}, {clean_str(name)}) ON CONFLICT (name) DO NOTHING;")
    family_map[name] = family_id_counter
    family_id_counter += 1

sql.append("")

# INSERT: machinability
for m in db.get("machinability_factors", []):
    name = m.get("material")
    if not name or name not in family_map: continue
    fid = family_map[name]
    mf = m.get("mf", "NULL")
    dens = m.get("density", "NULL")
    minb = m.get("minBHN", "NULL")
    maxb = m.get("maxBHN", "NULL")
    dry = m.get("dry", "NULL")
    sfmr = m.get("sfmrange", "NULL")
    sfmrh = m.get("sfmrangehss", "NULL")
    cexp = m.get("cexp", "NULL")
    coat = clean_str(m.get("coating"))
    drill = clean_str(m.get("drillStyle"))
    pts = clean_str(m.get("pointStyle"))
    pta = clean_str(m.get("pointAngle"))
    tm = m.get("threadMill", "NULL")
    pcd = m.get("pcdEM", "NULL")
    
    sql.append(f"INSERT INTO machinability (family_id, machinability_factor, density, min_bhn, max_bhn, dry_multiplier, sfm_range, sfm_range_hss, cexp, coating_rec, drill_style, point_style, point_angle, thread_mill, pcd_em) VALUES ({fid}, {mf}, {dens}, {minb}, {maxb}, {dry}, {sfmr}, {sfmrh}, {cexp}, {coat}, {drill}, {pts}, {pta}, {tm}, {pcd}) ON CONFLICT DO NOTHING;")

sql.append("")

# INSERT: specific_alloys
# In extracting specific alloys, sometimes they have arbitrary keys depending on how it was built
for i, al in enumerate(db.get("specific_alloys", [])):
    fam = al.get("family")
    fid = family_map.get(fam, "NULL")
    alloy = clean_str(al.get("alloy"))
    cond = clean_str(al.get("condition"))
    hard = clean_str(al.get("hardness"))
    
    sql.append(f"INSERT INTO specific_alloys (family_id, alloy_name, condition, hardness) VALUES ({fid}, {alloy}, {cond}, {hard});")

sql.append("")

# INSERT: tool_types
tool_id_counter = 1
for tt in db.get("tool_types", []):
    label = tt.get("label")
    if not label: continue
    lathe = str(tt.get("lathe") == "yes").lower()
    mill = str(tt.get("mill") == "yes").lower()
    carbide = str(tt.get("carbide") == "yes").lower()
    thin = str(tt.get("chipThin") == "yes").lower()
    coat = str(tt.get("coating") == "yes").lower()
    
    sql.append(f"INSERT INTO tool_types (id, label, is_lathe, is_mill, is_carbide, chip_thinning, has_coating) VALUES ({tool_id_counter}, {clean_str(label)}, {lathe}, {mill}, {carbide}, {thin}, {coat}) ON CONFLICT DO NOTHING;")
    tool_map[label] = tool_id_counter
    tool_id_counter += 1

sql.append("")

# INSERT: sfm_data
for sfm in db.get("sfm_data", []):
    mat = sfm.get("material")
    tool = sfm.get("tool")
    fid = family_map.get(mat)
    tid = tool_map.get(tool)
    if not fid or not tid: continue
    
    sfm_val = sfm.get("sfm", "NULL")
    tsc = sfm.get("tsc", "NULL")
    sql.append(f"INSERT INTO sfm_data (family_id, tool_type_id, base_sfm, tsc_multiplier) VALUES ({fid}, {tid}, {sfm_val}, {tsc}) ON CONFLICT DO NOTHING;")

sql.append("")

# INSERT: ipt_data
for ipt in db.get("ipt_data", []):
    # ipt format: [material, tool, d1, d2, d3, ...]
    if len(ipt) < 15: continue
    mat = ipt[0]
    tool = ipt[1]
    fid = family_map.get(mat)
    tid = tool_map.get(tool)
    if not fid or not tid: continue
    
    d_vals = ipt[2:15]
    d_str = ", ".join(str(d) for d in d_vals)
    sql.append(f"INSERT INTO ipt_data (family_id, tool_type_id, d_0_0625, d_0_125, d_0_1875, d_0_25, d_0_375, d_0_5, d_0_75, d_1_0, d_1_5, d_2_0, d_3_0, d_4_0, d_5_0) VALUES ({fid}, {tid}, {d_str}) ON CONFLICT DO NOTHING;")

sql.append("")

# Sequence Resets
sql.append(f"SELECT setval('material_families_id_seq', {family_id_counter});")
sql.append(f"SELECT setval('tool_types_id_seq', {tool_id_counter});")

sql.append("")
sql.append("COMMIT;")

with open('gwizard_database.sql', 'w', encoding='utf-8') as f:
    f.write("\n".join(sql))

print("Successfully written to gwizard_database.sql")
