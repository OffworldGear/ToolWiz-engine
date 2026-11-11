"""Per-family C7 speed-law parameters fitted to the vendor rows (V3 round 4, item 2).

The calibrated law is  v = L_f * (hb_ref/HB)^q_f * max(ae/D, a0)^(-k) * (min(D, knee)/knee)^m * C9  with ONE engagement exponent
k and diameter exponent m for every material (tools/calibrate_v2.py). This tool refits L_f, k_f and m_f per family against the
vendor rows' own SFM (least absolute deviations, IRLS) with a ridge pull toward the global k and m so that small families do
not overfit, keeping q_f, hb_ref and a0 as calibrated. The 30 % hold-out groups of calibrate_v2.holdout never enter a fit;
residuals are reported before and after on both sets. Output: data/model_v2/speed_by_family.json, read by physics_v2.params (families with `applied` true only).

Run from the repo root: python tools/fit_speed_by_family.py
"""
import collections
import json
import math
import os
import statistics
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
for p in (ROOT, os.path.join(ROOT, "tools")):
    if p not in sys.path:
        sys.path.insert(0, p)

import calibrate_v2 as cal  # noqa: E402
import v2_provisional_limits as pl  # noqa: E402
from gwizard_physics import BeamDeflectionEngine, reach_sfm_factor  # noqa: E402
from physics_v2 import optimize as o  # noqa: E402

OUT = os.path.join(ROOT, "data", "model_v2", "speed_by_family.json")
KNEES = (0.125, 0.25, 0.5, 1.0)
RIDGE = 12.0   # pseudo-rows pulling k_f and m_f toward the global values


def rows_with_features():
    with open(os.path.join(ROOT, "data", "model_v2", "materials.json"), encoding="utf-8") as fh:
        mat = json.load(fh)
    out = []
    for r in cal.load_rows():
        if r["operation"] not in ("slot", "side", "rough", "hem"):
            continue
        t, c = r["tool"], r["cut"]
        fam = r["material"].get("toolwiz_family")
        if fam not in mat["families"] or t.get("tool_material") != "carbide" or str(t.get("end", "")).lower() != "square":
            continue
        if pl.missing_geometry(r):
            continue
        hb = cal.row_hb(r["material"].get("hardness"), fam)
        sfm = pl.nominal(c["sfm"])
        if not hb or not sfm:
            continue
        D = float(t["DC"])
        try:
            tool, _ = pl.row_tool(r)
            c9 = reach_sfm_factor(BeamDeflectionEngine.equivalent_stickout(tool.segments, tool.D, tool.z, tool.helix_deg), D)
        except Exception:
            c9 = 1.0
        out.append({"id": r["id"], "family": fam, "hb": hb, "sfm": sfm, "D": D, "aeD": min(float(c["ae"]) / D, 1.0),
                    "c9": c9, "hold": cal.holdout(r), "vg": r["_vendor_group"]})
    return mat, out


def predict(f, e, k, m, knee, a0):
    return (f["lvl"] * (f["hb_ref"] / e["hb"]) ** f["q"] * max(e["aeD"], a0) ** (-k) * (min(e["D"], knee) / knee) ** m * e["c9"])


def irls(X, y, w0, iters=30):
    n = len(X[0])
    w = list(w0)
    coef = [0.0] * n
    for _ in range(iters):
        A = [[sum(w[i] * X[i][a] * X[i][b] for i in range(len(X))) + (1e-9 if a == b else 0) for b in range(n)] for a in range(n)]
        B = [sum(w[i] * X[i][a] * y[i] for i in range(len(X))) for a in range(n)]
        for col in range(n):   # Gaussian elimination
            piv = max(range(col, n), key=lambda r_: abs(A[r_][col]))
            A[col], A[piv], B[col], B[piv] = A[piv], A[col], B[piv], B[col]
            for r_ in range(col + 1, n):
                fct = A[r_][col] / A[col][col]
                for cc in range(col, n):
                    A[r_][cc] -= fct * A[col][cc]
                B[r_] -= fct * B[col]
        coef = [0.0] * n
        for r_ in range(n - 1, -1, -1):
            coef[r_] = (B[r_] - sum(A[r_][cc] * coef[cc] for cc in range(r_ + 1, n))) / A[r_][r_]
        res = [y[i] - sum(coef[a] * X[i][a] for a in range(n)) for i in range(len(X))]
        w = [w0[i] / max(abs(res[i]), 1e-3) for i in range(len(X))]
    return coef


def main():
    mat, rows = rows_with_features()
    glob_k = mat["speed_engagement"]["k"]["value"]
    a0 = mat["speed_engagement"]["ae_min"]["value"]
    glob_m = mat["speed_diameter"]["m"]["value"]
    glob_knee = mat["speed_diameter"]["knee_in"]["value"]
    result = {"status": "V3 round 4 per-family C7 refit", "generated_by": "tools/fit_speed_by_family.py",
              "global": {"k": glob_k, "m": glob_m, "knee_in": glob_knee, "ae_min": a0}, "ridge_rows": RIDGE, "families": {}}
    summary = []
    for fam, fdat in mat["families"].items():
        sp = fdat["speed"]
        base = {"lvl": sp["vc_ref_sfm"]["value"], "hb_ref": sp["hb_ref"]["value"], "q": sp["vc_hardness_exp"]["value"]}
        rs = [e for e in rows if e["family"] == fam]
        tr, ho = [e for e in rs if not e["hold"]], [e for e in rs if e["hold"]]
        if len(tr) < 5:
            continue

        def resid(items, f, k, m, knee):
            return [math.log(predict(f, e, k, m, knee, a0) / e["sfm"]) for e in items]

        best = None
        for knee in KNEES:
            # y = log(sfm / (c9 (hb_ref/hb)^q)) = a - k log(max(ae/D,a0)) + m log(min(D,knee)/knee)
            X, y, w = [], [], []
            for e in tr:
                X.append([1.0, -math.log(max(e["aeD"], a0)), math.log(min(e["D"], knee) / knee)])
                y.append(math.log(e["sfm"] / (e["c9"] * (base["hb_ref"] / e["hb"]) ** base["q"])))
                w.append(1.0)
            for col, prior in ((1, glob_k), (2, glob_m)):   # ridge pseudo-rows
                for _ in range(1):
                    xr = [0.0, 0.0, 0.0]
                    xr[col] = 1.0
                    X.append(xr)
                    y.append(prior)
                    w.append(RIDGE)
            a, k, m = irls(X, y, w)
            f = dict(base, lvl=math.exp(a))
            tr_res = resid(tr, f, k, m, knee)
            score = statistics.median(abs(x) for x in tr_res)
            if best is None or score < best[0]:
                best = (score, knee, f, k, m)
        score, knee, f, k, m = best
        before = lambda items: [math.log(predict(base, e, glob_k, glob_m, glob_knee, a0) / e["sfm"]) for e in items]
        after = lambda items: resid(items, f, k, m, knee)
        def stats(res):
            return {"n": len(res), "median_abs_log": statistics.median(abs(x) for x in res) if res else None,
                    "within_25pct": sum(1 for x in res if 0.75 <= math.exp(x) <= 1.25) / len(res) if res else None}
        result["families"][fam] = {"vc_ref_sfm": f["lvl"], "engagement_k": k, "diameter_m": m, "diameter_knee_in": knee,
                                   "hb_ref": base["hb_ref"], "q": base["q"],
                                   "residuals": {"train_before": stats(before(tr)), "train_after": stats(after(tr)),
                                                 "holdout_before": stats(before(ho)), "holdout_after": stats(after(ho))}}
        r = result["families"][fam]["residuals"]
        hb_, ha_ = r["holdout_before"], r["holdout_after"]
        # Applied only where the refit does not do worse on the hold-out groups it never saw.
        applied = bool(ha_["n"] and ha_["median_abs_log"] < hb_["median_abs_log"]
                       and ha_["within_25pct"] >= hb_["within_25pct"] - 0.02)
        result["families"][fam]["applied"] = applied
        summary.append((fam + (" [applied]" if applied else " [kept global]"), r))
    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump(result, fh, indent=1, ensure_ascii=True)
        fh.write("\n")
    for fam, r in summary:
        print(f"{fam[:44]:44} " + "  ".join(f"{k}: {v['median_abs_log']:.3f}/{v['within_25pct']:.0%}(n{v['n']})"
                                            if v["n"] else f"{k}: -" for k, v in r.items()))


if __name__ == "__main__":
    main()
