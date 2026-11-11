"""
Probe the v2 optimizer's candidate cuts for one tool.

Runs one /api/calculate request with model=v2 (Flask test client, no server needed), then
evaluates a fixed grid of (depth, width) candidates with the same tool, material and machine
objects the optimizer used. For each candidate it prints the feasible feed-per-tooth window,
the MRR at the top of the window, wall-normal and total tip deflection, peak stress and the
binding checks. Use it to see why the optimizer chose what it chose.

Usage (from the repository root):
    python scripts/v2_candidate_probe.py --diameter 0.25 --flutes 4 --operation "Slotting" \
        --family "Steel - Medium Carbon Alloy (4130)" --coating AlTiN --runout 0.0002
    python scripts/v2_candidate_probe.py --diameter 0.02 --flutes 2 --c1-flute wall

See docs/REVIEW_AND_FIX_PLAN.md, Part 5.
"""

import argparse
import os
import sys
import tempfile

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
os.environ.setdefault("TOOLWIZ_DATA_DIR", tempfile.mkdtemp())

import app as toolwiz_app  # noqa: E402
from physics_v2 import optimize as o  # noqa: E402


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--diameter", type=float, default=0.0625)
    p.add_argument("--flutes", type=int, default=2)
    p.add_argument("--family", default="Aluminum - Wrought (6061)")
    p.add_argument("--coating", default="Uncoated")
    p.add_argument("--operation", default="Adaptive Roughing")
    p.add_argument("--runout", type=float, default=0.0002)
    p.add_argument("--stickout", type=float, default=None, help="default: max(0.5, 3.5 x diameter)")
    p.add_argument("--aggressiveness", type=float, default=50.0)
    p.add_argument("--c1-flute", default=None, choices=("thinnest", "wall", "worst"),
                   help="override which flute must exceed the minimum chip thickness")
    a = p.parse_args()
    d = a.diameter

    captured = {}
    real_optimize = o.optimize

    def spy(tool, material, machine, operation="adaptive", aggressiveness=0.5, **kw):
        if kw.get("find_tir", True):
            captured.update(tool=tool, material=material, machine=machine, operation=operation, kw=kw)
        return real_optimize(tool, material, machine, operation, aggressiveness, **kw)

    o.optimize = spy
    client = toolwiz_app.app.test_client()
    client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "probe"
    payload = dict(
        family=a.family, tool="Carbide Endmill", coating=a.coating, geometry="Square", operation=a.operation,
        diameter=d, flutes=a.flutes, cutDepth=0.01, cutWidth=0.01, fluteLength=3.0 * d,
        stickout=a.stickout or max(0.5, 3.5 * d), shankDiameter=max(d, 0.125), helixAngle=30, isCarbide=True,
        aggressiveness=a.aggressiveness, maxRpm=16000, maxHp=10, runout=a.runout, model="v2",
    )
    r = client.post("/api/calculate", json=payload).get_json()
    if not captured:
        raise SystemExit(f"v2 did not run for this request: {r.get('model_note')}")
    print(f"chosen: feasible={r.get('feasible')} DOC {r['rec_doc']} ({r['rec_doc'] / d:.2f} x D), "
          f"WOC {r['rec_woc']} ({r['rec_woc'] / d:.2f} x D), {r['rpm']} rpm, {r['feedrate']} IPM")
    print(f"note: {r.get('model_note')}")

    tool, op = captured["tool"], captured["operation"]
    opts = {k: v for k, v in captured["kw"].items() if k in o.OPTION_DEFAULTS}
    if a.c1_flute:
        opts["c1_flute"] = a.c1_flute
    ctx = o._Context(tool, captured["material"], captured["machine"], op,
                     o.Margins(a.aggressiveness / 100.0), 144, 48, **opts)
    print(f"C3 allow {ctx.delta_allow:.5f}\" ({ctx.delta_basis}); C4 limit {ctx.stress_limit:.0f} MPa; "
          f"C2 chip limit {ctx.h_tooth / 25.4:.6f}\"; C1 flute: {ctx.c1_flute}")
    print(" ap/D  ae/D   fz_lo     fz_hi     IPM     MRR      wall-normal  total tip  tip %D  MPa   binding")
    widths = [1.0] if op == "slot" else [0.05, 0.10, 0.20, 0.40, 0.90]
    for ap_ratio in (0.25, 0.5, 1.0, 2.0, 3.0):
        for ae_ratio in widths:
            pt = o.CutPoint(ctx, ap_ratio * d, ae_ratio * d)
            window = pt.fz_window()
            if not window or window[1] is None:
                print(f" {ap_ratio:4.2f} {ae_ratio:5.2f}  no feasible feed: {o._eliminators(pt, window)}")
                continue
            fz = window[1]
            checks, _, beam, _ = pt.checks(fz)
            top = beam["sections"][0]
            print(f" {ap_ratio:4.2f} {ae_ratio:5.2f}  {window[0]:.6f}  {fz:.6f}  {fz * tool.z * pt.rpm:6.1f}  "
                  f"{pt.mrr_in3_min(fz):.5f}   {beam['wall']['max_in']:.5f}      {beam['delta_in']:.5f}   "
                  f"{100 * beam['delta_in'] / d:5.2f}  {top['sigma1_mpa']:5.0f}  {o._binding(checks)}")


if __name__ == "__main__":
    main()
