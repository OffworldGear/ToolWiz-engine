import requests
import json

base = {
    'family': 'Aluminum - Wrought (6061)',
    'tool': 'Carbide Endmill',
    'diameter': 0.125,
    'flutes': 4,
    'cutDepth': 0.25,
    'cutWidth': 0.1,
    'stickout': 1.5,
    'isCarbide': True,
    'cornerRadius': 0.030,
    'operation': 'Roughing'
}

for geo in ['Square', 'Radiused', 'Ball', 'Drill']:
    base['geometry'] = geo
    try:
        res = requests.post('http://127.0.0.1:5000/api/calculate', json=base)
        print(f"{geo:<10}: {res.json()}")
    except Exception as e:
        print(f"{geo:<10} failed: {e}")
