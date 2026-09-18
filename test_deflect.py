import urllib.request, json
def test_agg(agg):
    p = json.dumps({'family': 'Aluminum - Wrought (6061)', 'alloy': '', 'tool': 'End Mill', 'coating': 'Uncoated', 'geometry': 'Square', 'operation': 'Roughing', 'cornerRadius': 0, 'shankDiameter': 0.5, 'neckDiameter': 0.5, 'neckLength': 0, 'taperAngle': 0, 'helixAngle': 30, 'fluteLength': 1.0, 'cutterThickness': 1.0, 'aggressiveness': agg, 'maxRpm': 16000, 'maxHp': 10, 'runout': 0.0002, 'diameter': 0.5, 'flutes': 4, 'pitch': 0, 'cutDepth': 0.5, 'cutWidth': 0.25, 'stickout': 1.5, 'isCarbide': True}).encode('utf-8')
    res = json.loads(urllib.request.urlopen(urllib.request.Request('http://127.0.0.1:5000/api/calculate', data=p, headers={'Content-Type': 'application/json'})).read())
    print(f"Agg {agg}: RPM={res['rpm']} Feed={res['feedrate']} Def={res['deflection']}")
test_agg(100)
test_agg(50)
test_agg(0)
