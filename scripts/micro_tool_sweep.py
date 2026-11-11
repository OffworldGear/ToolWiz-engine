"""
Micro-tool characterization sweep for the ToolWiz engine.

Prints the Auto-Set recommendation (DOC, WOC, feed, deflection, bending stress)
for a range of small end mills, so a change to the physics engine can be
compared before and after. It only calls /api/calculate through Flask's test
client, so it needs no running server and writes no files.

Usage (from the repository root):
    python scripts/micro_tool_sweep.py
    python scripts/micro_tool_sweep.py --stickout 0.5     # realistic 1/8" shank gauge length
    python scripts/micro_tool_sweep.py --runout 0.001

See docs/REVIEW_AND_FIX_PLAN.md for how the output is used as an acceptance check.
"""

import argparse
import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

import app as toolwiz_app  # noqa: E402
from gwizard_physics import BeamDeflectionEngine, CuttingMechanics  # noqa: E402

DIAMETERS = [0.010, 0.020, 0.03125, 0.046875, 0.0625, 0.09375, 0.125, 0.25]
MATERIALS = [
    ("Aluminum - Wrought (6061)", "Uncoated"),
    ("Steel - Medium Carbon Alloy (4130)", "AlTiN"),
    ("Stainless - 300 Series (316)", "AlTiN"),
    ("Titanium Alloy", "AlTiN"),
]
OPERATIONS = ["Adaptive Roughing", "Slotting", "Roughing"]


def calculate(client, **overrides):
    """POST one request to /api/calculate and return the parsed response."""
    payload = dict(
        family="Aluminum - Wrought (6061)", tool="Carbide Endmill", coating="Uncoated",
        geometry="Square", operation="Adaptive Roughing", diameter=0.0625, flutes=2,
        cutDepth=0.01, cutWidth=0.01, stickout=0.25, fluteLength=0.1875,
        shankDiameter=0.125, helixAngle=30, isCarbide=True, aggressiveness=50,
        maxRpm=16000, maxHp=10, runout=0.0002,
    )
    payload.update(overrides)
    result = client.post("/api/calculate", json=payload).get_json()
    if not result.get("success"):
        raise SystemExit(f"/api/calculate failed: {result}")
    return result


def auto_set(client, **overrides):
    """Apply the recommended DOC/WOC back into the request, as the UI's Auto-Set does."""
    result = calculate(client, **overrides)
    for _ in range(3):
        result = calculate(client, **dict(overrides, cutDepth=result["rec_doc"], cutWidth=result["rec_woc"]))
    return result


def bending_stress_ksi(physics, family, operation, diameter, flutes, flute_length, result):
    """Bending stress at the flute root, with the whole cutting force applied at the tip."""
    unit_hp = physics.machinability[family]["unit_hp"]
    woc = diameter if "slot" in operation.lower() else result["rec_woc"]
    _, _, force, _ = CuttingMechanics.calc_cutting_forces(
        diameter, result["rec_doc"], woc, result["feedrate"], result["rpm"], flutes, unit_hp, operation=operation
    )
    inertia = BeamDeflectionEngine.fluted_core_inertia(diameter, flutes, 30.0)
    equivalent_dia = (64.0 * inertia / math.pi) ** 0.25
    return force * flute_length * (equivalent_dia / 2.0) / inertia / 1000.0


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--stickout", type=float, default=None,
                        help="Stickout in inches for every tool (default: 3.5 x diameter)")
    parser.add_argument("--runout", type=float, default=0.0002, help="Runout (TIR) in inches")
    parser.add_argument("--aggressiveness", type=float, default=50.0)
    args = parser.parse_args()

    client = toolwiz_app.app.test_client()
    client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "sweep"
    physics = toolwiz_app.physics

    for operation in OPERATIONS:
        for family, coating in MATERIALS:
            print(f"\n### {operation} | {family}")
            print("   dia  fl    rpm    feed   adj_ipt  doc/D  woc/D   defl(in)  defl%D  limit(in)  stress(ksi)  critical tips")
            for dia in DIAMETERS:
                flutes = 2 if dia < 0.03 or "Aluminum" in family else (3 if dia < 0.0625 else 4)
                flute_length = 3.0 * dia
                stickout = args.stickout if args.stickout else 3.5 * dia
                shank = max(dia, 0.125)
                r = auto_set(
                    client, family=family, coating=coating, operation=operation, diameter=dia, flutes=flutes,
                    fluteLength=flute_length, stickout=max(stickout, flute_length), shankDiameter=shank,
                    runout=args.runout, aggressiveness=args.aggressiveness,
                )
                stress = bending_stress_ksi(physics, family, operation, dia, flutes, flute_length, r)
                critical = [t["title"] for t in r["tips"] if t["type"] == "critical"]
                print(
                    f"{dia:6.4f}  {flutes}  {r['rpm']:6d} {r['feedrate']:7.2f}  {r['adj_ipt']:.6f}  "
                    f"{r['rec_doc'] / dia:5.2f}  {r['rec_woc'] / dia:5.2f}  {r['deflection']:.6f}  "
                    f"{100 * r['deflection'] / dia:5.2f}   {r['rec_limit']:.5f}   {stress:8.0f}     {critical}"
                )


if __name__ == "__main__":
    main()
