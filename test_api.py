import urllib.request
import json

payload = {
    "family": "Copper Alloy - Wrought",
    "alloy": "C72900 - Toughmet 3 Nickel Bronze (Annealed)",
    "tool": "TiAlN Carbide Endmill",
    "geometry": "Square",
    "coating": "AlTiN",
    "diameter": 0.0625,
    "flutes": 4,
    "cutDepth": 0.010,
    "cutWidth": 0.063,
    "stickout": 0.188,
    "operation": "Full Slotting",
    "aggressiveness": 0.52,
    "max_rpm": 16000,
    "max_hp": 10.0,
    "runout": 0.0002,
    "isMetric": False,
    "fluteLength": 0.188
}
data = json.dumps(payload).encode('utf-8')
req = urllib.request.Request("http://127.0.0.1:5000/api/calculate", data=data, headers={'Content-Type': 'application/json'})
try:
    with urllib.request.urlopen(req) as response:
        print(json.dumps(json.loads(response.read()), indent=2))
except Exception as e:
    print(e)
