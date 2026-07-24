import re
import os
import json

files_to_parse = [
    r"C:\Users\matti\.gemini\antigravity\scratch\gwizard_source\scripts\material\GWizMaterialsDB.as",
    r"C:\Users\matti\.gemini\antigravity\scratch\gwizard_source\scripts\configinfo\GWizConfigData.as"
]

extracted_data = {}

for as3_file in files_to_parse:
    with open(as3_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace constants
    content = content.replace('GWizMaterialsDB.', '')
    content = content.replace('PLASTICS_HARD', '"Plastics: Hard (ABS, Nylon, Foam Bd)"')
    content = content.replace('PLASTICS_SOFT', '"Plastics: Soft (Acetal, HDPE, PEEK)"')
    content = content.replace('NO_ISO_COLOR', '0')
    content = content.replace('GWizAbstractPrefs.isLathe()', 'false')

    # Extract arrays
    pattern = re.compile(r'(?:var\s+|const\s+)?([\w_]+)(?:\s*:\s*[A-Za-z0-9_]+)?\s*=\s*(?:new\s+ArrayCollection\()?(\[\{.*?\}(?:\s*,\s*\{.*?\})*\])', re.DOTALL)
    matches = pattern.findall(content)

    for name, arr_str in matches:
        arr_str = re.sub(r'([{\[,]\s*)([A-Za-z0-9_]+)\s*:', r'\1"\2":', arr_str)
        try:
            data = json.loads(arr_str)
            extracted_data[name] = data
        except Exception as e:
            pass

# Extract IPTData
ipt_data_list = []
fs_math_file = r"C:\Users\matti\.gemini\antigravity\scratch\gwizard_source\scripts\feedsspeeds\GWizFeedSpeedMath.as"
with open(fs_math_file, 'r', encoding='utf-8') as f:
    fs_content = f.read()

fs_content = fs_content.replace('GWizMaterialsDB.PLASTICS_HARD', '"Plastics: Hard (ABS, Nylon, Foam Bd)"')
fs_content = fs_content.replace('GWizMaterialsDB.PLASTICS_SOFT', '"Plastics: Soft (Acetal, HDPE, PEEK)"')

ipt_pattern = re.compile(r'this\.IPTData\[[^\]]*\]\s*=\s*(\[.*?\]);')
for match in ipt_pattern.findall(fs_content):
    try:
        ipt_data_list.append(json.loads(match))
    except:
        pass

extracted_data['IPTData'] = ipt_data_list

out_path = r"C:\Users\matti\.gemini\antigravity\scratch\gwizard_db_full.json"
with open(out_path, 'w', encoding='utf-8') as f:
    json.dump(extracted_data, f, indent=2)

print(f"Wrote to {out_path}, {len(extracted_data)} arrays exported.")
