"""v2 calibration (design docs/PHYSICS_MODEL_DESIGN.md §4.3 and §6 step 4).

Fits or settles the v2 model's calibration parameters against the vendor benchmark rows
(tests/benchmarks/v2/*.json) and Sandvik's CoroPlus ToolGuide outputs, then runs the optimizer on every
in-scope row and reports the §5 acceptance metrics. Vendor data calibrates and validates; no table is
copied into the model.

What it writes (every value carries a `source`):
  data/model_v2/materials.json        Kienzle groups, force scale, Taylor speed law per family
  data/model_v2/tools.json            carbide, edge, C2 basis, aggressiveness proposal
  data/model_v2/calibration_report.json   fits, residuals by vendor / diameter band / material,
                                      hold-out validation, §5 metrics before and after, T1/T12
  data/model_v2/calibration_rows.json per-row predictions (before and after) for review

The files are PROPOSED parameters. Adopting them as the optimizer's defaults is the user's decision
(step 5 integrates). physics_v2/params.py builds optimizer inputs from them.

Parameters (task list, step 4):
  1. Force scale: tool/rake factor from Sandvik's own power outputs (sandvik_toolguide_probes.md); K_r and
     the edge terms K_te/K_re from the literature (not identifiable from power data).
  2. Thin-chip size effect: the C4 outliers under each candidate explanation; the cited treatments.
  3. Titanium mc: Seco SMG 22 (Ti6Al-4V annealed) 0.23 with Sandvik's kc1 1400 (S4.3.Z.AN).
  4. C7: engagement law, hardness exponent and level per family (× coating), anchored at the median vendor
     (decision §7.1, vendor-typical life).
  5. Aggressiveness map: a proposal (the user decides).
  6. C2: the band medians in chip_limits.json against fitted alternatives, on the hold-out rows.

Hold-out: 30 % of (vendor group, document, material family) groups, chosen by a hash, never seen by any
fit. Rows from one chart are correlated, so a row-level split would leak.

Run from the repo root (Windows: python tools\\calibrate_v2.py). About 10 minutes; --quick skips the
benchmark's C3-on variant and the T1/T12 runs.
"""
import argparse
import collections
import datetime
import glob
import hashlib
import json
import math
import os
import statistics
import sys
from dataclasses import replace

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
for p in (ROOT, os.path.join(ROOT, "tools")):
    if p not in sys.path:
        sys.path.insert(0, p)

import v2_provisional_limits as pl  # noqa: E402
from gwizard_physics import ASTMHardnessConverter  # noqa: E402
from physics_v2 import forces  # noqa: E402
from physics_v2 import optimize as o  # noqa: E402
from physics_v2 import params  # noqa: E402

VERSION = "2026-10-17.1"
OUT_DIR = os.path.join(ROOT, "data", "model_v2")
MM = o.MM_PER_IN
HOLDOUT_FRACTION = 0.30
TIR_IN = 0.0002
HP_KW = 0.745699872
FATIGUE_MPA = 0.375 * 3800.0
TRS_MPA = 3800.0
BANDS = pl.BANDS
OPERATION = {"slot": "slot", "side": "rough", "rough": "rough", "hem": "adaptive", "finish": "finish"}

# ---------------------------------------------------------------------------
# Citations (docs/research/v2_calibration_findings.md lists them in full)
# ---------------------------------------------------------------------------

SRC = {
    "probes": "Sandvik CoroPlus ToolGuide cutting-data screens, CoroMill Dura 1K344-0200-XC 1730 (2 mm, 4 FL), "
              "17-4 PH at 200 and 345 HB and 45 NCD 16 at 420 HB (user screenshots 2026-10-15); "
              "docs/research/sandvik_toolguide_probes.md",
    "sandvik_mc": "Sandvik Coromant 'Workpiece materials' MC table (docs/research/data/kc_mc_sources.json, SV-WEB)",
    "seco_ti": "Seco/Niagara SMG table, SMG 22 (ISO S) Ti6Al-4V annealed: kc1.1 210 ksi (1448 N/mm²), mc 0.23 "
               "(docs/research/data/kc_mc_sources.json, SE-NC; Seco is the independent second source, median "
               "ratio 0.97 to Sandvik, kc_mc_survey.md §5)",
    "k_r": "Kr/Kt 0.34–0.38 for carbide end mills in 45 steel (Sun, Ding, Deng, Xiong 2023, Sensors 23:8954, "
           "Table 2); Krc/Ktc 0.50 for Ti6Al4V (Li, Zhao, Li, He 2014, J. Vibroeng. 16:2657, citing Altintas, "
           "Manufacturing Automation 2nd ed.); no stainless value found",
    "k_te": "Edge coefficients 12–43 N/mm (Ti6Al4V Kte 24 / Kfe 43, Altintas MAL review Table 1; 16MnCr5 28.8 "
            "N/mm, Popović et al. 2017 FME Trans. 45:4 Table 1; 1020 steel 12.25 N/mm, Salehi et al. 2018 "
            "Procedia CIRP). Sandvik's kc1 is fitted to total force, so adding them double-counts; the ToolGuide "
            "probes all sit at one h_m (4.9 µm), so they cannot separate an edge term",
    "taylor_n": "n ≈ 0.25 (Tatar & Sjöberg 2020, Heliyon 6:e04217, Eq. 3, Ti-6Al-4V shoulder milling, coated "
                "carbide: ln T = 25.99 − 1.00 ln ae − 4.01 ln vc); carbide range 0.2–0.5 (Kalpakjian). Only used "
                "to trade life for speed",
    "rm_hb": "Rm → HB: HB ≈ Rm/3.38 (ASTM A370 Table 3 approximate tensile strength vs hardness for steels, "
             "Rm/HB 3.33–3.42 over 226–371 HB); used only for Seco's Rm-banded rows",
    "thin_chip": "Kienzle tables stop at h = 0.05–0.06 mm (Westermann; Europa); Biró & Szalay 2016 (IJAMT "
                 "84:2735) zones h ≥ 0.1, 0.01–0.1, 0.003–0.01, < 0.003 mm; measured kc keeps rising below the "
                 "edge radius (de Oliveira et al. 2015 IJMTM 89:39, AISI 1045; Soriano Gonzalez et al. 2023 "
                 "Micromachines 14:313, CMSX-4); edge-force split F = Kc·A + Ke·b (Altintas, MAL review Eq. 1)",
    "fatigue": "Carbide fatigue / TRS: 0.33–0.42 fully reversed or 10⁶–10⁸ cycles (Schleinkofer 1996, Kursawe "
               "2001, Brookes, Schedler via Preis 2004); 0.375 × 3.8 GPa = 1425 MPa adopted for C4 (Round 4); "
               "docs/research/carbide_and_edge_radius.md §2",
}

# ---------------------------------------------------------------------------
# Rows
# ---------------------------------------------------------------------------


def load_rows():
    rows = []
    for path in sorted(glob.glob(os.path.join(ROOT, "tests", "benchmarks", "v2", "*.json"))):
        with open(path, encoding="utf-8") as fh:
            d = json.load(fh)
        for r in d["rows"]:
            rows.append(dict(r, _vendor_group=d["vendor_group"], _file=os.path.basename(path)))
    return rows


def row_hb(hardness):
    """Brinell for a row's hardness: the middle of a range, else the one bound; Rm converted (SRC rm_hb).

    tools/v2_provisional_limits.py reads a Rm band (N/mm²) as HB; this corrects that for calibration.
    """
    if not hardness:
        return None
    vals = [v for v in (hardness.get("min"), hardness.get("max")) if v is not None]
    scale = (hardness.get("scale") or "").upper()
    if not vals or not scale:
        return None
    v = sum(vals) / len(vals)
    if scale == "HRC":
        return ASTMHardnessConverter.hrc_to_brinell(v)
    if scale == "HRB":
        return ASTMHardnessConverter.hrb_to_brinell(v)
    if "RM" in scale or "N/MM" in scale:
        return v / 3.38
    return float(v)


coating_class = params.coating_class


def holdout(row):
    """True for the 30 % validation groups: hash of (vendor group, document, family)."""
    key = f"{row['_vendor_group']}|{row['source']['doc_id']}|{row['material']['toolwiz_family']}"
    return int(hashlib.sha256(key.encode()).hexdigest()[:8], 16) / 0xFFFFFFFF < HOLDOUT_FRACTION


def band_of(D):
    for name, lo, hi in BANDS:
        if lo <= D < hi:
            return name
    return BANDS[-1][0]


# ---------------------------------------------------------------------------
# Materials (Kienzle mapping as tools/v2_provisional_limits.py, plus titanium)
# ---------------------------------------------------------------------------

TITANIUM = "Titanium Alloy"


def titanium_kienzle():
    """Sandvik S4.3.Z.AN kc1 1400 at 330 HB (no mc printed) with Seco SMG 22's mc 0.23 (SRC seco_ti)."""
    sv = [r for r in forces._sources(forces.KC_SOURCES_PATH)
          if r.get("source_id") == "SV-WEB" and r.get("material_group_code") == "S4.3.Z.AN"][0]
    se = forces.load_kienzle("SMG 22 (ISO S)", "SE-NC")
    src = (("source_id", "SV-WEB kc1 + SE-NC mc"), ("code", "S4.3.Z.AN"), ("url", sv["url"]),
           ("hardness", "330 HB"), ("quoted", sv["quoted_cells"] + " || mc from " + dict(se.source)["quoted"]))
    return forces.Kienzle(float(sv["kc1_1_N_mm2"]), se.mc, 0.0, src)


def family_groups():
    groups = {fam: (codes, p, basis) for fam, (codes, p, basis) in pl.FAMILY_GROUPS.items()}
    groups[TITANIUM] = (["S4.3.Z.AN"], 0.0, "Sandvik prints the same kc1 1400 for S4.3 AN (330 HB) and AG (375 HB)")
    return groups


def kienzle(code):
    return titanium_kienzle() if code == "S4.3.Z.AN" else forces.load_kienzle(code)


def row_material(row, speed=None, force=None):
    """(Material, info) for a row: its family's Sandvik row nearest its hardness, scaled by (HB/HB_ref)^p.

    speed: a fitted speed law (fit_speed) applied to the Material; force: {"tool_factor", "k_r"}.
    """
    fam = row["material"]["toolwiz_family"]
    spec = family_groups().get(fam)
    if spec is None:
        return None, {"skip": f"no Kienzle mapping for {fam}"}
    codes, p, _ = spec
    hb = row_hb(row["material"].get("hardness"))
    cands = [(c, kienzle(c)) for c in codes]
    cands = [(c, k, pl.group_hb(k)) for c, k in cands]
    code, k, ref = min(cands, key=lambda g: abs(g[2] - hb)) if hb else cands[0]
    kw = dict(name=f"{fam} via {code}", kienzle=k, hb_ref=ref, hb=hb or ref, kc_hardness_exp=p, family=fam)
    if force:
        kw.update(tool_factor=force["tool_factor"], k_r=force["k_r"])
    if speed:
        kw.update(speed_kwargs(speed, fam, coating_class(row["tool"].get("coating"))))
    return o.Material(**kw), {"code": code, "hb": hb or ref, "hb_published": hb is not None, "family": fam}


def speed_kwargs(speed, fam, coat):
    """Material keyword arguments for the fitted speed law. The level is fitted to bucket vendor medians,
    which mix coatings, so no coating factor is applied (speed["coating"] is reported only)."""
    f = speed["families"][fam]
    d = speed["diameter"]
    return dict(vc_ref_sfm=f["vc_ref_sfm"], vc_hb_ref=f["hb_ref"], vc_hardness_exp=f["q"],
                vc_engagement_exp=speed["engagement"]["k"], vc_engagement_ae_min=speed["engagement"]["ae_min"],
                vc_engagement_basis="ae", taylor_n=speed["taylor_n"], vc_diameter_exp=d["m"],
                vc_d_knee_in=d["knee_in"])


# ---------------------------------------------------------------------------
# Per-row physics at the vendor's cut
# ---------------------------------------------------------------------------

def reference_machine(tir=TIR_IN):
    """Vendor reference: no rpm, power or feed cap (vendor values are machine-independent)."""
    return o.Machine({}, 1e12, "continuous", tir, "eccentric", "vendor reference (no rpm/power cap)", None)


def evaluate(row, machine, force=None, n_theta=144, n_quad=48):
    """The vendor's own cut on its catalog geometry: chips, loads, stress, the C9 factor."""
    if row["tool"].get("end") != "square":
        return {"id": row["id"], "skip": f"end {row['tool'].get('end')!r} (v2.0 scope: square end mills)"}
    miss = pl.missing_geometry(row)
    if miss:
        return {"id": row["id"], "skip": "missing geometry: " + ", ".join(miss)}
    mat, info = row_material(row, force=force)
    tool, stickout = pl.row_tool(row)
    c = row["cut"]
    sfm, fz = pl.nominal(c["sfm"]), pl.nominal(c["fz"])
    ap, ae = min(float(c["ap"]), tool.lcf), min(float(c["ae"]), tool.D)
    op = "slot" if row["operation"] == "slot" else "rough"
    ctx = o._Context(tool, mat, machine, op, o.Margins(0.5), n_theta, n_quad, deflection_allow=1.0,
                     stress_limit=1e9, effective_feed_ipm=None, chip_limit_over_D=1.0)
    pt = o.CutPoint(ctx, ap, ae, 12.0 * sfm / (math.pi * tool.D))
    chips = pt.chips_c2(fz)[0]
    f = pt.loads(fz)
    beam = pt._beam(f)
    top = beam["sections"][0] if beam["sections"] else {"sigma1_mpa": 0.0, "kind": "none"}
    D_mm = tool.D * MM
    h_m = forces.mean_chip_thickness(fz * MM, ae * MM, D_mm)
    return {
        "id": row["id"], "vendor_group": row["_vendor_group"], "doc": row["source"]["doc_id"],
        "family": info["family"], "code": info["code"], "hb": info["hb"], "hb_published": info["hb_published"],
        "operation": row["operation"], "D": tool.D, "band": band_of(tool.D), "z": tool.z, "lcf": tool.lcf,
        "reach": row["tool"].get("LB"), "stickout": stickout, "coating": coating_class(row["tool"].get("coating")),
        "derived": bool(row["source"].get("derivation")), "holdout": holdout(row),
        "ap": ap, "ae": ae, "ap_over_D": ap / tool.D, "ae_over_D": ae / tool.D, "sfm": sfm, "fz": fz,
        "c9": ctx.reach_factor,
        "mrr": ap * ae * fz * tool.z * 12.0 * sfm / (math.pi * tool.D),
        "h_worst_over_D": max(chips) / D_mm, "h_m_mm": h_m, "sigma1_mpa": top["sigma1_mpa"],
        "section": top["kind"], "deflection_in": beam["delta_in"], "power_w": f["power_kw"] * 1000.0,
    }


def evaluate_all(rows, machine, force=None):
    return [evaluate(r, machine, force) for r in rows]


# ---------------------------------------------------------------------------
# Small linear algebra (no numpy dependency in the engine)
# ---------------------------------------------------------------------------

def wls(X, y, w):
    """Weighted least squares by the normal equations (Gauss-Jordan with partial pivoting).

    Returns (coefficients, standard errors). Columns that are all zero get coefficient 0.
    """
    n = len(X[0])
    A = [[0.0] * n for _ in range(n)]
    b = [0.0] * n
    for xi, yi, wi in zip(X, y, w):
        for i in range(n):
            if xi[i] == 0.0:
                continue
            b[i] += wi * xi[i] * yi
            for j in range(n):
                A[i][j] += wi * xi[i] * xi[j]
    active = [i for i in range(n) if A[i][i] > 1e-12]
    m = len(active)
    M = [[A[i][j] for j in active] + [1.0 if k == r else 0.0 for k in range(m)] for r, i in enumerate(active)]
    rhs = [b[i] for i in active]
    for col in range(m):
        piv = max(range(col, m), key=lambda r: abs(M[r][col]))
        if abs(M[piv][col]) < 1e-14:
            continue
        M[col], M[piv] = M[piv], M[col]
        rhs[col], rhs[piv] = rhs[piv], rhs[col]
        d = M[col][col]
        M[col] = [v / d for v in M[col]]
        rhs[col] /= d
        for r in range(m):
            if r != col and M[r][col] != 0.0:
                f = M[r][col]
                M[r] = [a - f * c for a, c in zip(M[r], M[col])]
                rhs[r] -= f * rhs[col]
    coef = [0.0] * n
    for r, i in enumerate(active):
        coef[i] = rhs[r]
    resid = [yi - sum(c * x for c, x in zip(coef, xi)) for xi, yi in zip(X, y)]
    wsum = sum(w)
    dof = max(1, len(y) - m)
    s2 = sum(wi * ri * ri for wi, ri in zip(w, resid)) / wsum * len(y) / dof
    se = [0.0] * n
    for r, i in enumerate(active):
        se[i] = math.sqrt(max(s2 * M[r][m + r] * wsum / len(y), 0.0))
    return coef, se


def within_fit(items, key, xs, y, weight=lambda e: 1.0):
    """Fixed-effect (within-group) WLS: demean y and the regressors inside each group of `key`."""
    groups = collections.defaultdict(list)
    for e in items:
        groups[key(e)].append(e)
    X, Y, W, n_groups = [], [], [], 0
    for es in groups.values():
        if len(es) < 2:
            continue
        cols = [[f(e) for e in es] for f in xs]
        if all(max(c) - min(c) < 1e-12 for c in cols):
            continue
        n_groups += 1
        ws = [weight(e) for e in es]
        wt = sum(ws)
        means = [sum(w * v for w, v in zip(ws, c)) / wt for c in cols]
        ys = [y(e) for e in es]
        ym = sum(w * v for w, v in zip(ws, ys)) / wt
        for k, e in enumerate(es):
            X.append([c[k] - m for c, m in zip(cols, means)])
            Y.append(ys[k] - ym)
            W.append(ws[k])
    if not X:
        return None
    coef, se = wls(X, Y, W)
    return {"coef": coef, "se": se, "n": len(Y), "groups": n_groups}


def vendor_weights(items):
    """Each vendor group gets equal total weight (Harvey has a third of all rows)."""
    cnt = collections.Counter(e["vendor_group"] for e in items)
    return lambda e: 1.0 / cnt[e["vendor_group"]]


def quantile(vals, q):
    vals = sorted(vals)
    if not vals:
        return None
    k = (len(vals) - 1) * q
    i = int(math.floor(k))
    j = min(i + 1, len(vals) - 1)
    return vals[i] + (vals[j] - vals[i]) * (k - i)


# ---------------------------------------------------------------------------
# 1. Force scale from Sandvik's own power outputs
# ---------------------------------------------------------------------------

# Pre-machining readings (sandvik_toolguide_probes.md, "Readings"): material, Sandvik group, HB, VC ft/min,
# FZ in, AE in, AP in, QQ in³/min, PPC HP. The helical-milling steps are left out: their QQ follows
# Sandvik's helical-entry definition (the doc uses only their ratio).
PROBE_D_IN = 0.0787
PROBES = [
    ("17-4 PH 200 HB, dynamic", "P5.0.Z.AN", 200.0, 0.41, 440, 0.000618, 0.0078, 0.125, 0.0514, 0.0821),
    ("17-4 PH 345 HB, full slot", "P5.0.Z.AN", 345.0, 0.41, 142, 0.0003, 0.0787, 0.021, 0.0137, 0.0273),
    ("17-4 PH 345 HB, dynamic", "P5.0.Z.AN", 345.0, 0.41, 256, 0.000683, 0.00634, 0.125, 0.0269, 0.0537),
    ("45 NCD 16 420 HB, dynamic", "P2.5.Z.HT", 420.0, 0.26, 371, 0.000691, 0.00619, 0.125, 0.0385, 0.0727),
]


def fit_force_scale():
    """kc implied by Sandvik's power (kc = P·60·10⁶/Q) over the model's kc at the same h_m.

    The model's kc is Sandvik's own table row scaled by (HB/HB_ref)^p, i.e. what physics_v2 uses with
    tool factor 1. The ratio is the tool/rake factor. All four readings share h_m ≈ 4.9 µm, so they fix the
    level at that chip, not mc or an edge term.
    """
    out = []
    for name, code, hb, p, vc, fz, ae, ap, qq, hp in PROBES:
        k = forces.load_kienzle(code)
        ref = pl.group_hb(k)
        h_m = forces.mean_chip_thickness(fz * MM, ae * MM, PROBE_D_IN * MM)
        kc_model = k.kc1_1 * (hb / ref) ** p * h_m ** (-k.mc)
        q_mm3 = qq * MM ** 3
        kc_sv = hp * HP_KW * 60e6 / q_mm3
        # Q as ap·ae·vf: Sandvik's QQ follows its own vf; record both.
        vf = fz * 4 * 12.0 * vc / (math.pi * PROBE_D_IN)
        out.append({"run": name, "group": code, "hb": hb, "kc_hardness_exp": p, "h_m_mm": h_m,
                    "kc_model_n_mm2": kc_model, "kc_sandvik_n_mm2": kc_sv, "ratio": kc_sv / kc_model,
                    "qq_check_ap_ae_vf_over_qq": ap * ae * vf / qq})
    # The tool factor comes from the three 17-4 readings (P5, the material it is for). The 45 NCD 16 reading
    # (P2.5.Z.HT, mc 0.25) is reported as a cross-check: it gives 0.64, or 0.79 if mc 0.21 is assumed as the
    # probe doc's arithmetic did, so part of the factor is material-specific (mc or hardness), not tool-only.
    logs = [math.log(r["ratio"]) for r in out if r["group"] == "P5.0.Z.AN"]
    gm = math.exp(sum(logs) / len(logs))
    sd = statistics.pstdev(logs)
    x = out[3]
    k2 = forces.load_kienzle(x["group"])
    x["ratio_if_mc_0.21"] = x["kc_sandvik_n_mm2"] / (k2.kc1_1 * (x["hb"] / pl.group_hb(k2)) ** x["kc_hardness_exp"]
                                                    * x["h_m_mm"] ** -0.21)
    # Hardness exponent from the like-for-like 17-4 dynamic pair (same strategy, same h_m).
    a, b = out[0], out[2]
    kc_a = a["kc_sandvik_n_mm2"] * (a["h_m_mm"] / 0.0049) ** 0.21
    kc_b = b["kc_sandvik_n_mm2"] * (b["h_m_mm"] / 0.0049) ** 0.21
    p_hard = math.log(kc_b / kc_a) / math.log(345.0 / 200.0)
    return {"runs": out, "tool_factor": gm, "log_sd": sd, "n": len(logs),
            "kc_hardness_exp_17_4": p_hard,
            "identifiable": {"tool_factor": True,
                             "k_r": False, "k_te": False, "mc": False},
            "note": "Tool factor from the three 17-4 PH readings; the 45 NCD 16 (P2) reading is a cross-check. "
                    "Power is tangential only, so K_r cannot be fitted from it; every reading sits at h_m ≈ 4.9 µm, "
                    "so neither mc nor an edge term K_te can be separated from the level. Support: one vendor "
                    "(Sandvik), one tool (Dura), two materials."}


# ---------------------------------------------------------------------------
# 2. Thin-chip size effect and the C4 outliers
# ---------------------------------------------------------------------------

def thin_chip_study(rows, tool_factor):
    """Rows over carbide fatigue / TRS on their own cut, under each candidate explanation.

    Variants: the Round 5 basis; TIR 0; the fitted tool factor; both; and two thin-chip treatments:
      * kc saturating below h0 = 0.05 mm (the bottom of the tabulated Kienzle range): the force per
        mm then falls linearly with h. The literature does not support it (measured kc keeps rising).
      * the edge-force split F = Ktc·h + Kte (Altintas Eq. 1) fitted to Kienzle over 0.05–0.2 mm: at
        µm chips it gives MORE force than Kienzle, not less.
    """
    variants = {
        "Round 5 basis (TIR 0.0002\", tool factor 1)": (TIR_IN, None, None),
        "TIR 0": (0.0, None, None),
        f"tool factor {tool_factor:.2f}": (TIR_IN, {"tool_factor": tool_factor, "k_r": 0.4}, None),
        f"TIR 0 + tool factor {tool_factor:.2f}": (0.0, {"tool_factor": tool_factor, "k_r": 0.4}, None),
        "kc saturating below 0.05 mm (not supported)": (TIR_IN, None, "floor"),
        "edge-force split fitted 0.05–0.2 mm": (TIR_IN, None, "edge"),
    }
    results, per_row = {}, {}
    side = [r for r in rows if r["tool"].get("end") == "square" and not pl.missing_geometry(r)]
    for name, (tir, force, mode) in variants.items():
        mach = reference_machine(tir)
        over_f = over_t = 0
        sig = {}
        for r in side:
            if mode is None:  # noqa: SIM108
                e = evaluate(r, mach, force)
                s = e["sigma1_mpa"]
            else:
                s = _stress_with_thin_chip(r, mach, mode)
            sig[r["id"]] = s
            over_f += s > FATIGUE_MPA
            over_t += s > TRS_MPA
        by_band = collections.Counter(band_of(float(r["tool"]["DC"])) for r in side if sig[r["id"]] > FATIGUE_MPA)
        results[name] = {"over_fatigue": over_f, "over_trs": over_t, "n": len(side),
                         "over_fatigue_by_band": {b: by_band.get(b, 0) for b, _, _ in BANDS}}
        per_row[name] = sig
    return results, per_row


def _stress_with_thin_chip(row, machine, mode, h0=0.05, h1=0.2):
    """Flute-root stress with a modified size effect (see thin_chip_study)."""
    mat, _ = row_material(row)
    k = mat.kienzle_at_hb()
    if mode == "floor":
        coeffs = _SaturatingCoefficients(k, mat.k_r, h0=h0)
    else:
        # Ktc·h + Kte through Kienzle's force per mm at h0 and h1.
        f0, f1 = k.kc1_1 * h0 ** (1 - k.mc), k.kc1_1 * h1 ** (1 - k.mc)
        ktc = (f1 - f0) / (h1 - h0)
        kte = f0 - ktc * h0
        coeffs = _LinearCoefficients(k, mat.k_r, ktc=ktc, kte=kte)
    tool, _ = pl.row_tool(row)
    c = row["cut"]
    sfm, fz = pl.nominal(c["sfm"]), pl.nominal(c["fz"])
    ap, ae = min(float(c["ap"]), tool.lcf), min(float(c["ae"]), tool.D)
    op = "slot" if row["operation"] == "slot" else "rough"
    ctx = o._Context(tool, mat, machine, op, o.Margins(0.5), 144, 48, deflection_allow=1.0,
                     stress_limit=1e9, effective_feed_ipm=None, chip_limit_over_D=1.0)
    ctx.coeffs = coeffs
    pt = o.CutPoint(ctx, ap, ae, 12.0 * sfm / (math.pi * tool.D))
    beam = pt._beam(pt.loads(fz))
    return beam["sections"][0]["sigma1_mpa"] if beam["sections"] else 0.0


class _SaturatingCoefficients:
    """kc(h) = kc1·max(h, h0)^(−mc): constant specific force below h0."""

    def __init__(self, kz, k_r, h0):
        self.kienzle, self.k_r, self.k_te, self.k_re, self.h0 = kz, k_r, 0.0, 0.0, h0

    def kc(self, h_mm):
        return self.kienzle.kc1_1 * max(h_mm, self.h0) ** (-self.kienzle.mc)


class _LinearCoefficients:
    """kc(h) = Ktc + Kte/h (the edge-force split written as a specific force)."""

    def __init__(self, kz, k_r, ktc, kte):
        self.kienzle, self.k_r, self.k_te, self.k_re = kz, k_r, 0.0, 0.0
        self.ktc, self.kte = ktc, kte

    def kc(self, h_mm):
        return self.ktc + self.kte / h_mm


# ---------------------------------------------------------------------------
# 4. C7: the speed law
# ---------------------------------------------------------------------------

AE_MIN_GRID = (0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.1)
CHART_KEY_ENGAGEMENT = ("doc", "family", "hb", "D", "z", "coating", "reach")
CHART_KEY_HARDNESS = ("doc", "operation", "D", "z", "coating", "ae_over_D", "ap_over_D", "reach", "family")


def _key(fields):
    def k(e):
        return tuple(round(e[f], 6) if isinstance(e[f], float) else e[f] for f in fields)
    return k


def log_sfm_base(e):
    """log SFM with the C9 (stickout) derating divided out, as the optimizer multiplies it back in."""
    return math.log(e["sfm"] / e["c9"])


def fit_engagement(train):
    """v ∝ max(ae/D, a0)^(−k): within-chart contrasts (same document, material, hardness, tool), each vendor
    group weighted equally; a0 by grid search on the within-chart residual."""
    data = [e for e in train if e["operation"] != "finish"]
    w = vendor_weights(data)
    best = None
    for a0 in AE_MIN_GRID:
        def x(e, a0=a0):
            return math.log(max(e["ae_over_D"], a0))
        r = within_fit(data, _key(CHART_KEY_ENGAGEMENT), [x], log_sfm_base, w)
        k = -r["coef"][0]
        # within-chart weighted residual
        groups = collections.defaultdict(list)
        for e in data:
            groups[_key(CHART_KEY_ENGAGEMENT)(e)].append(e)
        sse = wsum = 0.0
        for es in groups.values():
            if len(es) < 2:
                continue
            res = [log_sfm_base(e) + k * x(e) for e in es]
            ws = [w(e) for e in es]
            m = sum(a * b for a, b in zip(ws, res)) / sum(ws)
            sse += sum(wi * (ri - m) ** 2 for wi, ri in zip(ws, res))
            wsum += sum(ws)
        cand = {"k": k, "se": r["se"][0], "ae_min": a0, "rmse": math.sqrt(sse / wsum), "n": r["n"],
                "groups": r["groups"]}
        if best is None or cand["rmse"] < best["rmse"]:
            best = cand
    a0 = best["ae_min"]
    per_vendor = {}
    for vg in sorted({e["vendor_group"] for e in data}):
        sub = [e for e in data if e["vendor_group"] == vg]
        r = within_fit(sub, _key(CHART_KEY_ENGAGEMENT), [lambda e: math.log(max(e["ae_over_D"], a0))],
                       log_sfm_base)
        if r:
            per_vendor[vg] = {"k": -r["coef"][0], "se": r["se"][0], "n": r["n"], "groups": r["groups"]}
    best["per_vendor"] = per_vendor
    # Binned shape for the report (factor relative to a slot, equal vendor weights).
    edges = [0.0, 0.03, 0.06, 0.09, 0.13, 0.18, 0.26, 0.36, 0.51, 0.99]
    def bin_of(e):
        for i in range(len(edges) - 1):
            if edges[i] <= e["ae_over_D"] < edges[i + 1]:
                return i
        return None
    xs = [(lambda i: (lambda e: 1.0 if bin_of(e) == i else 0.0))(i) for i in range(len(edges) - 1)]
    rb = within_fit(data, _key(CHART_KEY_ENGAGEMENT), xs, log_sfm_base, w)
    best["binned"] = [{"ae_over_D": [edges[i], edges[i + 1]], "factor_vs_slot": math.exp(rb["coef"][i]),
                       "n": sum(1 for e in data if bin_of(e) == i),
                       "model": max(0.5 * (edges[i] + edges[i + 1]), a0) ** (-best["k"])}
                      for i in range(len(edges) - 1)]
    sandvik_dura = {"ae 0.5·D": 295 / 262, "ae 0.1·D": 492 / 262}
    best["sandvik_dura_check"] = {k_: {"sandvik": v, "model": (0.5 if "0.5" in k_ else 0.1) ** (-best["k"])}
                                  for k_, v in sandvik_dura.items()}
    best["toolguide_check"] = {"sandvik": 1.8, "model": max(0.09, a0) ** (-best["k"]),
                               "note": "ToolGuide dynamic vs full engagement at ae ≈ 0.08–0.10·D (probe doc)"}
    return best


def fit_hardness(train, families, pooled_min_rows=10):
    """Speed hardness exponent q (v ∝ HB^−q) per family from within-chart contrasts (same document, operation,
    tool and engagement, different hardness). Families with fewer than `pooled_min_rows` contrast rows use
    the pooled value."""
    key = _key(CHART_KEY_HARDNESS)
    pooled = within_fit(train, key, [lambda e: math.log(e["hb"])], log_sfm_base)
    out = {"pooled": {"q": -pooled["coef"][0], "se": pooled["se"][0], "n": pooled["n"], "groups": pooled["groups"]}}
    for fam in families:
        sub = [e for e in train if e["family"] == fam]
        r = within_fit(sub, key, [lambda e: math.log(e["hb"])], log_sfm_base) if sub else None
        contrib = collections.Counter()
        groups = collections.defaultdict(list)
        for e in sub:
            groups[key(e)].append(e)
        for es in groups.values():
            if len(es) > 1 and max(x["hb"] for x in es) - min(x["hb"] for x in es) > 1:
                contrib[es[0]["vendor_group"]] += len(es)
        if r and r["n"] >= pooled_min_rows:
            out[fam] = {"q": -r["coef"][0], "se": r["se"][0], "n": r["n"], "groups": r["groups"],
                        "vendors": dict(contrib), "basis": "within-chart fit"}
        else:
            out[fam] = {"q": out["pooled"]["q"], "se": out["pooled"]["se"], "n": r["n"] if r else 0,
                        "vendors": dict(contrib), "basis": "pooled within-chart fit (too few contrasts)"}
    # The fz exponent in the same contrasts (vendors thin the chip with hardness), for C2's discussion.
    fz = within_fit(train, key, [lambda e: math.log(e["hb"])], lambda e: math.log(e["fz"]))
    out["fz_pooled"] = {"exp": fz["coef"][0], "se": fz["se"][0], "n": fz["n"]}
    return out


def fit_speed(evals, train_mask):
    """The whole speed law on the training rows; see the section comment above."""
    train = [e for e in evals if train_mask(e)]
    families = sorted({e["family"] for e in evals})
    eng = fit_engagement(train)
    hard = fit_hardness(train, families)
    k, a0 = eng["k"], eng["ae_min"]
    hb_ref = {f: statistics.median([e["hb"] for e in evals if e["family"] == f]) for f in families}
    data = [e for e in train if e["operation"] != "finish"]
    vgs = sorted({e["vendor_group"] for e in data})
    coats = ["AlTiN/TiAlN", "AlCrN", "Si-doped", "uncoated", "DLC", "unspecified"]

    def y(e):
        return (log_sfm_base(e) + k * math.log(max(e["ae_over_D"], a0))
                + hard[e["family"]]["q"] * math.log(e["hb"] / hb_ref[e["family"]]))

    def x(e):
        return ([1.0 if e["family"] == f else 0.0 for f in families]
                + [1.0 if e["vendor_group"] == v else 0.0 for v in vgs[1:]]
                + [1.0 if e["coating"] == c else 0.0 for c in coats[1:]])
    w = vendor_weights(data)
    coef, se = wls([x(e) for e in data], [y(e) for e in data], [w(e) for e in data])
    nf, nv = len(families), len(vgs) - 1
    vendor_eff = dict(zip(vgs, [0.0] + coef[nf:nf + nv]))
    anchor = statistics.median(vendor_eff.values())
    coat_eff = dict(zip(coats, [0.0] + coef[nf + nv:]))
    coat_se = dict(zip(coats, [0.0] + se[nf + nv:]))
    coat_out = {}
    for c in coats:
        vend = sorted({e["vendor_group"] for e in data if e["coating"] == c})
        t = coat_eff[c] / coat_se[c] if coat_se[c] else 0.0
        fams_c = {e["family"] for e in data if e["coating"] == c}
        supported = c == "AlTiN/TiAlN" or (len(vend) >= 2 and len(fams_c) >= 2 and abs(t) >= 2.0
                                           and c != "unspecified")
        coat_out[c] = {"factor": math.exp(coat_eff[c]), "se_log": coat_se[c], "vendor_groups": vend,
                       "families": sorted(fams_c),
                       "applied": math.exp(coat_eff[c]) if supported else 1.0,
                       "basis": ("reference class" if c == "AlTiN/TiAlN" else
                                 "applied: ≥ 2 vendor groups, ≥ 2 families and |t| ≥ 2; confounded with tool "
                                 "series (within-vendor contrasts)" if supported else
                                 "not applied (1.0): one vendor group, one family, |t| < 2, or no chemistry")}
    vendor_fe = {f: math.exp(coef[i] + anchor) for i, f in enumerate(families)}
    base = {"engagement": {"k": k, "ae_min": a0, "basis": "ae", **{kk: v for kk, v in eng.items()
                                                                   if kk not in ("k", "ae_min")}},
            "hardness": hard, "coating": coat_out,
            "vendor_effect_log": {v: e - anchor for v, e in vendor_eff.items()},
            "vendor_fe_level_sfm": vendor_fe, "taylor_n": 0.25,
            "anchor": "the bucket vendor median (each vendor group counted once), = 75 % aggressiveness "
                      "(user decision 2026-10-17)"}
    level = fit_level_consensus(train, base, hb_ref, families)
    base.update(level)
    return base


def _level_target(b, base, hb_ref):
    """A bucket's vendor-median SFM with the engagement, hardness and C9 terms taken out (log)."""
    eng, hard = base["engagement"], base["hardness"]
    return (math.log(b["sfm"] / b["c9"]) + eng["k"] * math.log(max(b["ae_over_D"], eng["ae_min"]))
            + hard[b["family"]]["q"] * math.log(b["hb"] / hb_ref[b["family"]]))


def irls_l1(X, y, iters=40, eps=1e-3):
    """Least absolute deviations by iteratively reweighted least squares (a median fit)."""
    w = [1.0] * len(y)
    coef = None
    for _ in range(iters):
        coef, se = wls(X, y, w)
        res = [yi - sum(c * x for c, x in zip(coef, xi)) for xi, yi in zip(X, y)]
        w = [1.0 / max(abs(r), eps) for r in res]
    return coef, se


def fit_level_consensus(train, base, hb_ref, families, knees=(0.125, 0.25, 0.5, 1.0)):
    """The C7 level per family plus a diameter term, fitted so the law sits at the vendor median.

    Target (the user's §5 definition): each training row's L1 bucket vendor median (family, 50-HB bin, band,
    operation class, engagement class; each vendor group's median, then the median over groups), with the
    row's own engagement, hardness and C9 terms taken out. Least absolute deviations over rows, so the fit's
    per-band median bias and the gate's are the same statistic. Model: level_f·(min(D, D_knee)/D_knee)^m.

    The D term is EMPIRICAL: within a chart vendors print one SFM for every diameter (slope −0.001 ± 0.002), so
    the trend is between tool series. No cited physical law was found (the likeliest cause is the rpm a micro
    tool can actually get). D_knee by grid, judged by the largest per-band bias on the training rows; m = 0 is
    reported for comparison.
    """
    table = build_consensus(train)
    eng, hard = base["engagement"], base["hardness"]
    obs = []
    for e in train:
        b = table["buckets"].get(bucket_keys(e)[0])
        if not b:
            continue
        y = (math.log(b["sfm"] / e["c9"]) + eng["k"] * math.log(max(e["ae_over_D"], eng["ae_min"]))
             + hard[e["family"]]["q"] * math.log(e["hb"] / hb_ref[e["family"]]))
        obs.append((e, y))
    results = []
    for knee in (None,) + tuple(knees):
        def x(e, knee=knee):
            row = [1.0 if e["family"] == f else 0.0 for f in families]
            if knee:
                row.append(math.log(min(e["D"], knee) / knee))
            return row
        coef, se = irls_l1([x(e) for e, _ in obs], [y for _, y in obs])
        m = coef[len(families)] if knee else 0.0
        speed = dict(base, families={f: {"vc_ref_sfm": math.exp(coef[i]), "hb_ref": hb_ref[f],
                                         "q": hard[f]["q"], "q_basis": hard[f]["basis"],
                                         "n_rows": sum(1 for e, _ in obs if e["family"] == f),
                                         "vendor_groups": sorted({e["vendor_group"] for e, _ in obs
                                                                  if e["family"] == f})}
                                     for i, f in enumerate(families)},
                     diameter={"m": m, "knee_in": knee or 1.0})
        bias = band_bias_vs_median(speed, train, table)
        results.append((max(abs(v) for v in bias.values()), knee, speed, bias))
    best = min(results, key=lambda r: r[0])
    speed = best[2]
    speed["diameter"].update(
        form="v ∝ (min(D, D_knee)/D_knee)^m (EMPIRICAL)",
        basis="least absolute deviations over training rows against their bucket vendor medians; D_knee by grid "
              "(smallest worst per-band bias)",
        grid=[{"knee_in": r[1], "m": r[2]["diameter"]["m"], "max_abs_band_bias": r[0], "band_bias": r[3]}
              for r in results])
    speed["n_level_rows"] = len(obs)
    return speed


def predict_sfm(speed, e):
    """The C7 speed law at 75 % (scale 1.0) for a row's own cut, C9 included."""
    f = speed["families"][e["family"]]
    eng = speed["engagement"]
    d = speed.get("diameter", {"m": 0.0, "knee_in": 1.0})
    return (f["vc_ref_sfm"] * (f["hb_ref"] / e["hb"]) ** f["q"]
            * max(e["ae_over_D"], eng["ae_min"]) ** (-eng["k"]) * e["c9"]
            * (min(e["D"], d["knee_in"]) / d["knee_in"]) ** d["m"])


def band_bias_vs_median(speed, items, table):
    """Median over rows in each band of log(predicted SFM / the row's L1 bucket vendor-median SFM)."""
    by = collections.defaultdict(list)
    for e in items:
        b = table["buckets"].get(bucket_keys(e)[0])
        if b:
            by[e["band"]].append(math.log(predict_sfm(speed, e) / b["sfm"]))
    return {b: statistics.median(v) for b, v in by.items()}


# ---------------------------------------------------------------------------
# C14: vendor-consensus buckets
# ---------------------------------------------------------------------------

ENGAGEMENT_CLASSES = [("light", 0.0, 0.1), ("medium", 0.1, 0.25), ("heavy", 0.25, 0.99), ("slot", 0.99, 1e9)]
OPERATION_CLASS = {"slot": "slot", "side": "side", "rough": "side", "hem": "hem", "finish": "finish"}
HB_BIN_FINE, HB_BIN_COARSE = 50, 100


def bucket_keys(e):
    """L1 (50-HB bin, operation class), L2 (100-HB bin), L3 (100-HB bin, any operation); optimize.consensus_lookup."""
    eng = o.engagement_class(e["ae_over_D"], ENGAGEMENT_CLASSES)
    opc = OPERATION_CLASS[e["operation"]]
    fam, band = e["family"], e["band"]
    return ["|".join(("L1", fam, str(int(e["hb"] // HB_BIN_FINE)), band, opc, eng)),
            "|".join(("L2", fam, str(int(e["hb"] // HB_BIN_COARSE)), band, opc, eng)),
            "|".join(("L3", fam, str(int(e["hb"] // HB_BIN_COARSE)), band, "any", eng))]


def build_consensus(evals):
    """Per bucket: each vendor group's median SFM, fz/D and MRR/D³, and the median over the groups."""
    groups = collections.defaultdict(lambda: collections.defaultdict(list))
    for e in evals:
        for k in bucket_keys(e):
            groups[k][e["vendor_group"]].append(e)
    buckets = {}
    for key, by_vg in groups.items():
        def med(f, by_vg=by_vg):
            return statistics.median(statistics.median(f(x) for x in es) for es in by_vg.values())
        rows = [x for es in by_vg.values() for x in es]
        buckets[key] = {
            "sfm": med(lambda x: x["sfm"]), "fz_over_D": med(lambda x: x["fz"] / x["D"]),
            "mrr_over_D3": med(lambda x: x["mrr"] / x["D"] ** 3),
            "mrr_per_ap_over_D2": med(lambda x: x["mrr"] / (x["ap"] * x["D"] ** 2)),
            "feed_over_D": med(lambda x: x["mrr"] / (x["ap"] * x["ae"] * x["D"])),
            "n_rows": len(rows), "vendor_groups": sorted(by_vg),
            "family": rows[0]["family"], "D": statistics.median(x["D"] for x in rows),
            "hb": statistics.median(x["hb"] for x in rows), "ae_over_D": statistics.median(x["ae_over_D"] for x in rows),
            "c9": statistics.median(x["c9"] for x in rows),
        }
    return {"version": VERSION, "generated_by": "tools/calibrate_v2.py",
            "status": "C14 vendor-consensus buckets (user decision 2026-10-17)",
            "source": "tests/benchmarks/v2 square-end rows on their own catalog geometry; each vendor group's median, "
                      "then the median over vendor groups. C14m uses feed_over_D (MRR per unit engaged area ap·ae, i.e. "
                      "the feed rate, over D); mrr_over_D3 and mrr_per_ap_over_D2 are kept for reference",
            "bands": [{"band": n, "d_min": lo, "d_max": hi if hi != math.inf else 1e9} for n, lo, hi in BANDS],
            "engagement_classes": [[n, lo, hi] for n, lo, hi in ENGAGEMENT_CLASSES],
            "hb_bin_fine": HB_BIN_FINE, "hb_bin_coarse": HB_BIN_COARSE,
            "levels": {"L1": "family, 50-HB bin, band, operation class, engagement class",
                       "L2": "family, 100-HB bin, band, operation class, engagement class",
                       "L3": "family, 100-HB bin, band, any operation, engagement class"},
            "buckets": buckets}


def fit_consensus_offsets(train, rows_by_id, speed, table, target=-0.02, grid=None):
    """Offsets on the C7 level and the C2 limit so that, AFTER the C14 caps, the 75 % output sits on the vendor
    median in every band (user, 2026-10-17: bias ≈ 0 at 75 %).

    At 75 % C14 caps speed, chip load and MRR at 1.00 × the bucket median, so the output is min(physics,
    median). A law centred on the median would leave half the rows below it and a negative median bias; the
    physics side must sit a little above the median for the caps to land the output on it. Each offset is the
    smallest (on the grid) that brings every band's median realized bias on the training rows to ≥ `target`.
    The realized values are computed directly: SFM = min(law·offset, cap); fz = min(C2 fz at the scaled limit,
    the C14 chip cap, the C14 MRR cap at that SFM). C4/C5 are left to the benchmark that follows.
    """
    grid = grid or [1.0 + 0.025 * i for i in range(41)]
    mach = reference_machine()
    recs = []
    for e in train:
        cons = o.consensus_lookup(table, e["family"], e["hb"], e["D"], OPERATION[e["operation"]], e["ae_over_D"])
        if not cons:
            continue
        key = "slot_bands" if e["operation"] == "slot" else "bands"
        band = o.chip_limit(e["D"], key=key)
        if band.get("n", 0) < 3:
            band = o.chip_limit(e["D"])
        recs.append({"e": e, "cons": cons, "law": predict_sfm(speed, e), "h_band": band["h_worst_over_D"]})

    def realized_sfm(r, k):
        return min(r["law"] * k, r["cons"]["sfm"])

    def band_bias(vals):
        by = collections.defaultdict(list)
        for r, v in vals:
            by[r["e"]["band"]].append(v)
        return {b: statistics.median(v) for b, v in by.items()}

    k_s = grid[-1]
    for k in grid:
        bb = band_bias([(r, math.log(realized_sfm(r, k) / r["cons"]["sfm"])) for r in recs])
        if min(bb.values()) >= target:
            k_s = k
            break
    sfm_bias = band_bias([(r, math.log(realized_sfm(r, k_s) / r["cons"]["sfm"])) for r in recs])
    cache = {}
    fz_unit = {}
    for r in recs:
        e = r["e"]
        # fz at which the worst-flute chip equals the band limit (scale 1); C2 fz scales almost linearly with it
        fz_unit[e["id"]] = _fz_for_worst_chip(rows_by_id[e["id"]], e, r["h_band"] * e["D"] * MM, mach, cache)

    def realized_fz(r, k_c):
        e = r["e"]
        fz_c2 = _fz_for_worst_chip(rows_by_id[e["id"]], e, k_c * r["h_band"] * e["D"] * MM, mach, cache)
        cap_f = r["cons"]["fz_over_D"] * e["D"]
        sfm = realized_sfm(r, k_s)
        rpm = 12.0 * sfm / (math.pi * e["D"])
        cap_m = r["cons"]["feed_over_D"] * e["D"] / (e["z"] * rpm)
        return min(fz_c2, cap_f, cap_m)

    k_c = grid[-1]
    for k in grid:
        bb = band_bias([(r, math.log(realized_fz(r, k) / (r["cons"]["fz_over_D"] * r["e"]["D"]))) for r in recs])
        if min(bb.values()) >= target:
            k_c = k
            break
    fz_bias = band_bias([(r, math.log(realized_fz(r, k_c) / (r["cons"]["fz_over_D"] * r["e"]["D"]))) for r in recs])
    return {"speed_offset": k_s, "c2_offset": k_c, "target_band_bias": target, "n_rows": len(recs),
            "predicted_band_bias_75": {"sfm": sfm_bias, "fz": fz_bias},
            "basis": "smallest grid value (1.000–2.000 by 0.025) bringing every band's median realized bias on the "
                     "training rows to ≥ the target, with C14 capping at 1.00 × the training-bucket vendor median"}


def consensus_spread(evals):
    """How far vendor groups sit from their bucket median: p25 and p75 of group-median / bucket-median for SFM
    and fz/D over L1 buckets with ≥ 3 vendor groups (checks the aggressiveness points)."""
    groups = collections.defaultdict(lambda: collections.defaultdict(list))
    for e in evals:
        groups[bucket_keys(e)[0]][e["vendor_group"]].append(e)
    out = {}
    for name, f in (("sfm", lambda x: x["sfm"]), ("fz_over_D", lambda x: x["fz"] / x["D"])):
        ratios = []
        for by_vg in groups.values():
            if len(by_vg) < 3:
                continue
            meds = [statistics.median(f(x) for x in es) for es in by_vg.values()]
            m = statistics.median(meds)
            ratios += [v / m for v in meds]
        out[name] = {"p10": quantile(ratios, 0.10), "p25": quantile(ratios, 0.25), "p75": quantile(ratios, 0.75),
                     "p90": quantile(ratios, 0.90), "n_group_medians": len(ratios)}
    return out


# ---------------------------------------------------------------------------
# 6. C2: band medians vs fitted alternatives (fz prediction on the hold-out rows)
# ---------------------------------------------------------------------------

def c2_study(rows_by_id, evals, train_mask):
    """Predict each row's fz from its C2 chip limit alone (C2 binding) under each basis; median |log error|.

    A  the chip_limits.json method: band median of worst-flute h/D (side and slot), training rows only;
    A2 a smooth fit log(h/D) = a + b·log D (+ slot offset);
    B  A2 plus family offsets and a hardness slope;
    C  the tooth edge load kc1(HB)·h^(1−mc)/D (tooth bending, load per mm over a root section ∝ D) smooth in D;
    C2 C plus family offsets.
    """
    data = [e for e in evals if e["operation"] != "finish"]
    train = [e for e in data if train_mask(e)]
    w = vendor_weights(train)
    fams = sorted({e["family"] for e in data})
    for e in data:
        mat, _ = row_material(rows_by_id[e["id"]])
        k = mat.kienzle_at_hb()
        e["_kc1"], e["_mc"] = k.kc1_1, k.mc
        D_mm = e["D"] * MM
        e["_q"] = k.kc1_1 * (e["h_worst_over_D"] * D_mm) ** (1 - k.mc) / D_mm

    def slot(e):
        return 1.0 if e["operation"] == "slot" else 0.0

    def fit(target, feats):
        coef, _ = wls([[f(e) for f in feats] for e in train], [math.log(target(e)) for e in train],
                      [w(e) for e in train])
        return lambda e: math.exp(sum(c * f(e) for c, f in zip(coef, feats))), coef
    one = lambda e: 1.0  # noqa: E731
    lD = lambda e: math.log(e["D"])  # noqa: E731
    lHB = lambda e: math.log(e["hb"] / 300.0)  # noqa: E731
    famf = [(lambda f: (lambda e: 1.0 if e["family"] == f else 0.0))(f) for f in fams[1:]]
    med = {}
    for name, lo, hi in BANDS:
        for s in (0.0, 1.0):
            v = [e["h_worst_over_D"] for e in train if lo <= e["D"] < hi and slot(e) == s]
            med[(name, s)] = statistics.median(v) if v else None
    variants = {"A band median (chip_limits.json method)":
                lambda e: med[(e["band"], slot(e))] * e["D"] * MM}
    f, c = fit(lambda e: e["h_worst_over_D"], [one, slot, lD])
    variants["A2 smooth in D"] = lambda e, f=f: f(e) * e["D"] * MM
    f, c = fit(lambda e: e["h_worst_over_D"], [one, slot, lD, lHB] + famf)
    variants["B smooth D + family + hardness"] = lambda e, f=f: f(e) * e["D"] * MM
    f, c = fit(lambda e: e["_q"], [one, slot, lD])
    variants["C edge load smooth in D"] = (lambda e, f=f: (f(e) * e["D"] * MM / e["_kc1"]) ** (1 / (1 - e["_mc"])))
    f, c = fit(lambda e: e["_q"], [one, slot, lD] + famf)
    variants["C2 edge load + family"] = (lambda e, f=f: (f(e) * e["D"] * MM / e["_kc1"]) ** (1 / (1 - e["_mc"])))
    mach = reference_machine()
    cache = {}
    out = {}
    for name, fn in variants.items():
        err = {}
        for e in data:
            err[e["id"]] = math.log(_fz_for_worst_chip(rows_by_id[e["id"]], e, fn(e), mach, cache) / e["fz"])
        out[name] = _error_summary(data, err, train_mask)
    return out


def _fz_for_worst_chip(row, e, h_mm, mach, cache):
    pt = cache.get(e["id"])
    if pt is None:
        mat, _ = row_material(row)
        tool, _ = pl.row_tool(row)
        op = "slot" if row["operation"] == "slot" else "rough"
        ctx = o._Context(tool, mat, mach, op, o.Margins(0.5), 24, 12, deflection_allow=1.0, stress_limit=1e9,
                         effective_feed_ipm=None, chip_limit_over_D=1.0)
        pt = cache[e["id"]] = o.CutPoint(ctx, e["ap"], e["ae"], 1000.0)
    lo, hi = 1e-7, 0.1
    if max(pt.chips_c2(lo)[0]) >= h_mm:
        return lo
    for _ in range(45):
        mid = math.sqrt(lo * hi)
        if max(pt.chips_c2(mid)[0]) > h_mm:
            hi = mid
        else:
            lo = mid
    return lo


def _error_summary(items, err, train_mask):
    out = {}
    for part, sel in (("train", lambda e: train_mask(e)), ("holdout", lambda e: not train_mask(e))):
        sub = [e for e in items if sel(e) and e["id"] in err]
        out[part] = {"n": len(sub), "median_abs_log": statistics.median(abs(err[e["id"]]) for e in sub),
                     "by_band": {b: statistics.median(abs(err[e["id"]]) for e in sub if e["band"] == b)
                                 for b, _, _ in BANDS if any(e["band"] == b for e in sub)},
                     "bias_by_vendor": {v: statistics.median(err[e["id"]] for e in sub if e["vendor_group"] == v)
                                        for v in sorted({e["vendor_group"] for e in sub})},
                     "bias_by_band": {b: statistics.median(err[e["id"]] for e in sub if e["band"] == b)
                                      for b, _, _ in BANDS if any(e["band"] == b for e in sub)},
                     "by_family": {f: {"median_abs_log": statistics.median(abs(err[e["id"]]) for e in sub
                                                                           if e["family"] == f),
                                       "bias": statistics.median(err[e["id"]] for e in sub if e["family"] == f)}
                                   for f in sorted({e["family"] for e in sub})}}
    return out


# ---------------------------------------------------------------------------
# Benchmark: the optimizer at each row's engagement
# ---------------------------------------------------------------------------

def within_range(pred, cell, slack=0.10):
    """§5: inside the published range ±10 % (nominal ±10 % when only a nominal is printed)."""
    lo = cell.get("min")
    hi = cell.get("max")
    nom = cell.get("nominal")
    if lo is None and hi is None:
        lo = hi = nom
    elif lo is None:
        lo = min(hi, nom) if nom else hi
    elif hi is None:
        hi = max(lo, nom) if nom else lo
    return lo / (1 + slack) <= pred <= hi * (1 + slack)


def benchmark_row(row, material, machine, c3_on=False, margins=None, consensus=None, n_theta=72, n_quad=24):
    """The optimizer's choice at the vendor's ap and ae: speed from C7, fz the largest that meets every
    constraint.

    c3_on False (tool capability, the §5 comparison): C3 off and no finishing wall target, since the stock to
    leave and the 5 µm wall are the user's process requirements, which no vendor chart knows. c3_on True
    (process): C3 = 50 % of 0.05 mm stock for roughing, and finishing takes the fastest feed meeting the
    5 µm wall target."""
    tool, _ = pl.row_tool(row)
    c = row["cut"]
    ap, ae = min(float(c["ap"]), tool.lcf), min(float(c["ae"]), tool.D)
    op = OPERATION[row["operation"]]
    opts = {"effective_feed_ipm": None, "consensus": consensus}
    if not c3_on and op != "finish":
        opts["deflection_allow"] = 1.0
    ctx = o._Context(tool, material, machine, op, margins or o.Margins(0.5), n_theta, n_quad, **opts)
    pt = o.CutPoint(ctx, ap, ae)
    # C8 (empirical micro slot depth) and C12 (ae ≥ 2·TIR) judge the vendor's chosen ap/ae, not fz or speed:
    # the comparison is made at the vendor's engagement regardless, and the conflict is recorded.
    conflicts = [k for k, c in (("C8", pt.c8), ("C12", pt.c12)) if not c.ok]
    if conflicts:
        pt.c8, pt.c12 = replace(pt.c8, applies=False), replace(pt.c12, applies=False)
    win = pt.fz_window()
    sfm = math.pi * tool.D * pt.rpm / 12.0
    if win is None or win[1] is None:
        why = o._eliminators(pt, win)
        return {"feasible": False, "sfm": sfm, "fz": None, "binding": why, "conflicts": conflicts}
    fz = win[1]
    if op == "finish" and c3_on:
        fz, _ = o._finish_target(pt, win[0], win[1], ctx)
    checks = pt.checks(fz)[0]
    out = {"feasible": True, "sfm": sfm, "fz": fz, "binding": o._binding(checks),
           "capped": pt.fz_capped, "conflicts": conflicts}
    if pt.cons:
        out["c14_bucket"] = pt.cons["key"]
    return out


def benchmark(rows, material_fn, machine, c3_on=False, margins=None, consensus=None):
    out = {}
    for r in rows:
        if r["tool"].get("end") != "square" or pl.missing_geometry(r):
            continue
        mat, info = material_fn(r)
        if mat is None:
            out[r["id"]] = {"skip": info["skip"]}
            continue
        out[r["id"]] = benchmark_row(r, mat, machine, c3_on, margins, consensus)
    return out


def section5(rows_by_id, evals, bench, train_mask=None, table=None):
    """§5 metrics: pass rate (range ±10 %, no slack), median |log error| per band, signed bias by vendor,
    band and material, for SFM, fz and MRR (at the vendor's engagement MRR ∝ SFM·fz).

    With `table` (the consensus buckets from all rows), also the bias against the vendor median: the median
    over rows of log(model / the row's L1 bucket vendor median), for SFM, fz (fz/D) and MRR (MRR/D³)."""
    ev = {e["id"]: e for e in evals if "skip" not in e}
    recs = []
    for rid, b in bench.items():
        if "skip" in b or rid not in ev:
            continue
        e, row = ev[rid], rows_by_id[rid]
        rec = {"id": rid, "e": e, "feasible": b["feasible"]}
        rec["log_sfm"] = math.log(b["sfm"] / e["sfm"])
        rec["sfm_ok"] = within_range(b["sfm"], row["cut"]["sfm"])
        if b["feasible"]:
            rec["log_fz"] = math.log(b["fz"] / e["fz"])
            rec["log_mrr"] = rec["log_sfm"] + rec["log_fz"]
            rec["fz_ok"] = within_range(b["fz"], row["cut"]["fz"])
        bk = table["buckets"].get(bucket_keys(e)[0]) if table else None
        if bk:
            rec["med_sfm"] = math.log(b["sfm"] / bk["sfm"])
            if b["feasible"]:
                rec["med_fz"] = math.log(b["fz"] / e["D"] / bk["fz_over_D"])
                mrr = e["mrr"] * (b["sfm"] / e["sfm"]) * (b["fz"] / e["fz"])
                rec["med_mrr"] = math.log(mrr / (e["ap"] * e["ae"] * e["D"]) / bk["feed_over_D"])
        recs.append(rec)

    def summarize(sel):
        s = [r for r in recs if sel(r)]
        f = [r for r in s if r["feasible"]]
        if not s:
            return None
        res = {"n": len(s), "feasible": len(f),
               "pass_sfm": sum(r["sfm_ok"] for r in s) / len(s),
               "pass_fz": sum(r["fz_ok"] for r in f) / len(s),
               "pass_both": sum(r["sfm_ok"] and r.get("fz_ok", False) for r in s) / len(s),
               "mal_sfm": statistics.median(abs(r["log_sfm"]) for r in s),
               "bias_sfm": statistics.median(r["log_sfm"] for r in s)}
        if f:
            res.update(mal_fz=statistics.median(abs(r["log_fz"]) for r in f),
                       bias_fz=statistics.median(r["log_fz"] for r in f),
                       mal_mrr=statistics.median(abs(r["log_mrr"]) for r in f),
                       bias_mrr=statistics.median(r["log_mrr"] for r in f))
        for q in ("sfm", "fz", "mrr"):
            v = [r["med_" + q] for r in s if "med_" + q in r]
            if v:
                res["bias_vs_median_" + q] = statistics.median(v)
        return res
    out = {"overall": summarize(lambda r: True)}
    if train_mask:
        out["holdout"] = summarize(lambda r: not train_mask(r["e"]))
        out["train"] = summarize(lambda r: train_mask(r["e"]))
    for dim, key in (("by_band", "band"), ("by_vendor", "vendor_group"), ("by_family", "family"),
                     ("by_operation", "operation")):
        vals = sorted({r["e"][key] for r in recs})
        out[dim] = {v: summarize(lambda r, v=v: r["e"][key] == v) for v in vals}
    if train_mask:
        out["holdout_by_band"] = {b: summarize(lambda r, b=b: r["e"]["band"] == b and not train_mask(r["e"]))
                                  for b, _, _ in BANDS}
    infeasible = collections.Counter()
    conflicts = collections.Counter()
    for rid, b in bench.items():
        if "skip" not in b and not b["feasible"]:
            infeasible[", ".join(b["binding"])] += 1
        for k in b.get("conflicts", ()):
            conflicts[k] += 1
    out["infeasible_by"] = dict(infeasible.most_common())
    out["engagement_conflicts"] = {"counts": dict(conflicts), "note": "vendor ap/ae outside C8 (micro slot depth) "
                                   "or C12 (ae ≥ 2·TIR); compared at the vendor's engagement anyway"}
    fz_fail = collections.Counter()
    for r in recs:
        if r["feasible"] and not r["fz_ok"]:
            b = bench[r["id"]]
            fz_fail[("over" if r["log_fz"] > 0 else "under") + ": " + (", ".join(b["binding"]) or "none")] += 1
    out["fz_outside_range_by_binding"] = dict(fz_fail.most_common(12))
    out["skipped"] = dict(collections.Counter(b["skip"] for b in bench.values() if "skip" in b))
    c14 = collections.Counter()
    for b in bench.values():
        for k in b.get("binding", ()) if b.get("feasible") else ():
            if k.startswith("C14"):
                c14[k] += 1
    out["c14_binding"] = dict(c14)
    out["c14_no_bucket"] = sum(1 for b in bench.values() if b.get("feasible") is not None and "skip" not in b
                               and "c14_bucket" not in b and b.get("feasible"))
    return out, recs


def gate(s5_75, s5_50, ceiling):
    """The §5 gate (user, 2026-10-17), per band: median |log error| vs rows ≤ the vendors' own disagreement in
    that band (vendor_consensus_ceiling), for SFM and fz; at 75 % |bias vs vendor median| ≤ 0.10; at 50 %
    −0.20 ≤ bias ≤ 0. Bias for SFM, fz and MRR. Vendor bias is reported, not gated."""
    out = {}
    for band, _, _ in BANDS:
        a, h = s5_75["by_band"].get(band), s5_50["by_band"].get(band)
        if not a or not h:
            continue
        row = {}
        for q in ("sfm", "fz"):
            ceil = ceiling[q]["median_abs_log_by_band"].get(band)
            mal = a.get("mal_" + q)
            row[f"mal_{q}_75"] = mal
            row[f"ceiling_{q}"] = ceil
            row[f"mal_{q}_ok"] = mal is not None and ceil is not None and mal <= ceil
        for q in ("sfm", "fz", "mrr"):
            b75, b50 = a.get("bias_vs_median_" + q), h.get("bias_vs_median_" + q)
            row[f"bias_{q}_75"], row[f"bias_{q}_50"] = b75, b50
            row[f"bias_{q}_75_ok"] = b75 is not None and abs(b75) <= 0.10
            row[f"bias_{q}_50_ok"] = b50 is not None and -0.20 <= b50 <= 0.0
        row["pass"] = all(v for k, v in row.items() if k.endswith("_ok"))
        out[band] = row
    return out


def vendor_consensus_ceiling(rows_by_id, evals):
    """What the other vendors agree on: predict each row from the median (over the other vendor groups) of
    each group's median in the same cell (family, band, operation class, engagement class, 50-HB bin), and
    score it with the §5 rules. No vendor-agnostic model can be expected to beat this by much."""
    def cell(e):
        opc = {"slot": "slot", "side": "side", "rough": "side", "hem": "hem", "finish": "finish"}[e["operation"]]
        aeb = 0 if e["ae_over_D"] >= 0.99 else (1 if e["ae_over_D"] >= 0.2 else 2)
        return (e["family"], e["band"], opc, aeb, int(e["hb"] // 50))
    cells = collections.defaultdict(lambda: collections.defaultdict(list))
    for e in evals:
        cells[cell(e)][e["vendor_group"]].append(e)
    out = {}
    for q in ("sfm", "fz"):
        errs, passed, by_band = [], 0, collections.defaultdict(list)
        for e in evals:
            others = [statistics.median(x[q] for x in es) for vg, es in cells[cell(e)].items()
                      if vg != e["vendor_group"]]
            if not others:
                continue
            pred = statistics.median(others)
            errs.append(abs(math.log(pred / e[q])))
            by_band[e["band"]].append(errs[-1])
            passed += within_range(pred, rows_by_id[e["id"]]["cut"][q])
        out[q] = {"rows_with_another_vendor": len(errs), "of": len(evals), "pass": passed / len(errs),
                  "median_abs_log": statistics.median(errs),
                  "median_abs_log_by_band": {b: statistics.median(by_band[b]) for b, _, _ in BANDS if by_band[b]},
                  "rows_by_band": {b: len(by_band[b]) for b, _, _ in BANDS}}
    return out


# ---------------------------------------------------------------------------
# 5. Aggressiveness map (proposal)
# ---------------------------------------------------------------------------

def aggressiveness_map(evals):
    """The consensus aggressiveness map (user decision 2026-10-17, accepted in principle), with the vendor
    spread it is checked against."""
    spread = consensus_spread(evals)
    pts = {f"a={a:g}": o.consensus_scale(a) for a in (0.0, 0.25, 0.5, 0.75, 1.0)}
    return {
        "status": "user decision 2026-10-17 (points accepted in principle); optimize.Margins(scheme='consensus')",
        "scale_points": {"value": [list(p) for p in o.CONSENSUS_SCALE_POINTS],
                         "source": "user 2026-10-17: 75 % ≈ vendor median (1.00), 50 % default 0.92 (Speedio BT30 "
                                   "starting point), 100 % 1.10 (vendors' 'may increase 10–20 %', e.g. Harvey "
                                   "speeds-feeds page), 0 % 0.76 (vendor lower quartile; worst-flute h/D p25/median "
                                   "0.76, calibration_report.json)"},
        "interpolation": "monotone cubic (Fritsch–Carlson) through the points",
        "scale_at": pts,
        "applies_to": ["C7 speed level (the tool-life target as speed: T/T_ref = scale^(−1/n))", "C2 chip limit",
                       "C14 caps on SFM, fz and MRR (scale × the bucket vendor median)"],
        "C4": {"value": [list(p) for p in o.CONSENSUS_STRESS_POINTS],
               "source": "× the fatigue limit 1425 MPa, never above it: 0.88 = 0.33/0.375 at a = 0 (Schleinkofer 1996, "
                         "R = −1, via Preis 2004), 1.0 at a = 1; linear"},
        "lambda": {"value": o.CONSENSUS_LAMBDA, "source": "fixed (C1 never relaxed); centre of 0.2–0.4 "
                                                         "(Wojciechowski 2022)"},
        "C5_margin": {"value": "0.2·(1 − a)", "source": "unchanged; the spindle is a hard limit"},
        "never_relaxed": ["C1", "C3 (with the spindle/holder compliance)", "C4", "C5", "C9"],
        "vendor_spread_check": {"value": spread,
                                "source": "vendor-group median / bucket vendor median over L1 buckets with ≥ 3 groups"},
    }


# ---------------------------------------------------------------------------
# T1 / T12
# ---------------------------------------------------------------------------

# Provisional BT30 spindle + holder compliance (no measured BT30 value was found; measure on the Speedio):
BT30 = {
    "k_spindle_n_um": {"value": 80.0, "source": "NK Enginex ATC-BT30 spindle spec 'Radial stiffness ≥80 N/μm' "
                                                "(vendor minimum, not Brother; https://nkenginex.com/products/cnc-atc-bt30-spindle)"},
    "k_holder_joint_n_um": {"value": 51.6, "source": "holder-tool joint k_yf 5.1581e7 N/m, carbide 16 mm tool in a BT40 "
                                                     "holder (Özşahin, Ertürk, Özgüven, Budak 2009, IJMTM 49:25, Table 2)"},
    "ktheta_holder_joint_nm_urad": {"value": 0.12631, "source": "holder-tool joint k_θm 1.2631e5 N·m/rad, same paper "
                                                                "and table; no size-30 taper rotational value was found"},
}
BT30_K = 1.0 / (1.0 / BT30["k_spindle_n_um"]["value"] + 1.0 / BT30["k_holder_joint_n_um"]["value"])
BT30_BASIS = ("PROVISIONAL BT30: spindle ≥80 N/µm (NK Enginex spec) in series with a holder-tool joint 51.6 N/µm and "
              "0.126 N·m/µrad (Özşahin et al. 2009, BT40, 16 mm tool); measure on the Speedio")


def speedio_bt30(tir=TIR_IN):
    return replace(o.speedio_16k(tir), holder_k_n_um=BT30_K,
                   holder_ktheta_nm_urad=BT30["ktheta_holder_joint_nm_urad"]["value"], holder_basis=BT30_BASIS)


def t1_t12(speed, force, consensus, c2_offset=1.0):
    """T1 and T12 in 17-4 H1025: before (step-3 defaults, rigid holder) and after at 50 % and 75 % (consensus
    scheme, C14, calibrated material, Speedio with the provisional BT30 compliance)."""
    T1 = o.Tool.build(0.125, 4, 0.5, 0.6, shank=0.125, label="T1")
    T12 = o.Tool.build(0.0625, 4, 0.1875, 0.5, shank=0.125, label="T12")
    rigid, bt30 = o.speedio_16k(TIR_IN), speedio_bt30()
    fam = "Stainless - PH Series (17-4)"
    before = o.material_17_4(356.0)
    after = replace(before, tool_factor=force["tool_factor"], k_r=force["k_r"], c2_scale=c2_offset,
                    **speed_kwargs(speed, fam, "unspecified"))
    # The literal MRR/D³ cap, for comparison: the same table without the per-depth MRR medians.
    literal = dict(consensus, buckets={k: {kk: vv for kk, vv in b.items() if kk != "feed_over_D"}
                                       for k, b in consensus["buckets"].items()})
    runs = [("before", before, rigid, o.Margins(0.5), None),
            ("after 50 %", after, bt30, o.Margins(0.5, scheme="consensus"), consensus),
            ("after 75 %", after, bt30, o.Margins(0.75, scheme="consensus"), consensus),
            ("after 50 %, MRR/D³ cap", after, bt30, o.Margins(0.5, scheme="consensus"), literal)]
    out = []
    for tool in (T1, T12):
        for op in ("adaptive", "slot", "finish"):
            for label, mat, mach, mg, cons in runs:
                kw = {"stock": 0.05 / MM} if op == "finish" else {}
                r = o.optimize(tool, mat, mach, op, margins=mg, robustness=False, find_tir=False,
                               consensus=cons, **kw)
                c = r["cut"]
                rec = {"tool": tool.label, "operation": op, "model": label, "feasible": r["feasible"],
                       "ap_over_D": c["ap_over_D"], "ae_over_D": c["ae_over_D"], "fz_in": c["fz_in"],
                       "sfm": c["sfm"], "ipm": c["feed_ipm"], "mrr_in3_min": c["mrr_in3_min"],
                       "MB_per_in3_s0.22": c["program"]["bytes_per_in3"]["s=0.22mm"] / 1e6,
                       "binding": r["binding"], "sigma1_mpa": r["checks"]["C4"]["value"],
                       "wall_deflection_in": r["loads"]["wall_error_in"]["max_in"],
                       "c14": {k: r["checks"][k]["detail"] for k in ("C14v", "C14f", "C14m") if k in r["checks"]}}
                if mach.holder_k_n_um:
                    # The holder's share: the same cut on a rigid holder.
                    rr = o.evaluate_cut(tool, mat, rigid, op, c["ap_in"], c["ae_in"], c["fz_in"], c["rpm"], margins=mg,
                                        consensus=cons)
                    w_rigid = rr["loads"]["wall_error_in"]["max_in"]
                    rec["wall_deflection_rigid_in"] = w_rigid
                    rec["holder_share_of_wall"] = 1.0 - w_rigid / rec["wall_deflection_in"] if rec["wall_deflection_in"] else 0.0
                if op == "finish" and "wall_target" in r:
                    wt = r["wall_target"]
                    rec["wall_um"] = {"ripple": wt["ripple_in"] * MM * 1000,
                                      "mean": wt["mean_blum_compensable_in"] * MM * 1000,
                                      "max": wt["max_in"] * MM * 1000, "met": wt["met"]}
                out.append(rec)
    return out


# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

def _round(x, nd=5):
    if isinstance(x, float):
        return float(f"{x:.{nd}g}") if math.isfinite(x) else None
    if isinstance(x, dict):
        return {k: _round(v, nd) for k, v in x.items()}
    if isinstance(x, (list, tuple)):
        return [_round(v, nd) for v in x]
    return x


def outlier_class(row):
    """A coarse label for a vendor cut that stays over the fatigue limit (for the written explanation)."""
    t, c = row["tool"], row["cut"]
    D = float(t["DC"])
    hb = row_hb(row["material"].get("hardness")) or 0.0
    if D < 0.05:
        return "micro (< 3/64\")"
    if float(c["ap"]) >= 2.9 * D and row["operation"] in ("hem", "rough", "side"):
        return "deep side/HEM cut (ap ≥ 3·D)"
    if row["operation"] == "slot" and float(c["ap"]) >= 0.99 * D:
        return "full slot ≥ 1·D deep"
    if hb >= 400:
        return "hardened (≥ 400 HB)"
    return "other"


def write_json(name, obj):
    path = os.path.join(OUT_DIR, name)
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(_round(obj), fh, indent=1, ensure_ascii=True)
        fh.write("\n")
    return path


def materials_file(force, speed):
    fams = {}
    for fam, (codes, p, basis) in family_groups().items():
        groups = []
        for c in codes:
            k = kienzle(c)
            src = dict(k.source)
            groups.append({"code": c, "kc1_1_n_mm2": k.kc1_1, "mc": k.mc, "hb_ref": pl.group_hb(k),
                           "source": SRC["seco_ti"] + "; kc1 " + SRC["sandvik_mc"] if c == "S4.3.Z.AN"
                           else f"{SRC['sandvik_mc']}: {src.get('quoted')}"})
        entry = {"kienzle_groups": groups,
                 "kc_hardness_exp": {"value": p, "source": f"exponent from the family's own Sandvik condition rows "
                                                         f"({basis}); docs/research/material_mapping_v2.md"}}
        s = speed["families"].get(fam)
        if s:
            entry["speed"] = {
                "vc_ref_sfm_median": {"value": s["vc_ref_sfm_median"], "source": "the level fitted to the bucket "
                                                                               "vendor medians, before the consensus offset"},
                "vc_ref_sfm": {"value": s["vc_ref_sfm"],
                               "at": f"slot (ae = D), {s['hb_ref']:.0f} HB, D ≥ {speed['diameter']['knee_in']:g}\", the "
                                     f"the vendor median × the consensus speed offset (75 % aggressiveness)",
                               "source": f"least absolute deviations over {s['n_rows']} training rows against their "
                                         f"bucket vendor medians (each vendor group counted once; groups "
                                         f"{', '.join(s['vendor_groups'])}); calibration_report.json speed"},
                "hb_ref": {"value": s["hb_ref"], "source": "median hardness of the family's benchmark rows"},
                "vc_hardness_exp": {"value": s["q"], "source": s["q_basis"] + " (calibration_report.json "
                                                                             "speed.hardness)"},
                "taylor_n": {"value": speed["taylor_n"], "source": SRC["taylor_n"]},
            }
        fams[fam] = entry
    return {
        "version": VERSION, "status": "PROPOSED (calibration step 4); adoption as optimizer defaults is the "
                                      "user's decision", "generated_by": "tools/calibrate_v2.py",
        "date": datetime.date.today().isoformat(),
        "force": {
            "tool_factor": {"value": force["tool_factor"], "support": "one vendor (Sandvik ToolGuide, Dura)",
                            "source": SRC["probes"] + f"; geometric mean of {force['n']} pre-machining readings, "
                                                      f"log sd {force['log_sd']:.3f}"},
            "k_r": {"value": force["k_r"], "source": SRC["k_r"] + "; 0.4 kept (inside 0.34–0.50)"},
            "k_te_n_mm": {"value": 0.0, "source": SRC["k_te"]},
            "k_re_n_mm": {"value": 0.0, "source": SRC["k_te"]},
        },
        "consensus_offsets": {
            "speed": {"value": speed["consensus_offset"]["speed_offset"],
                      "source": "folded into each family's vc_ref_sfm (vc_ref_sfm_median is the level before it): " +
                                speed["consensus_offset"]["basis"]},
            "c2": {"value": speed["consensus_offset"]["c2_offset"],
                   "source": "Material.c2_scale on the chip_limits.json band median: " + speed["consensus_offset"]["basis"]},
            "why": "at 75 % C14 caps at 1.00 × the vendor median, so the output is min(physics, median); the physics "
                   "side sits a little above the median so that the 75 % output lands on it (user 2026-10-17)",
        },
        "speed_diameter": {
            "form": speed["diameter"]["form"],
            "m": {"value": speed["diameter"]["m"], "source": "EMPIRICAL; " + speed["diameter"]["basis"]},
            "knee_in": {"value": speed["diameter"]["knee_in"], "source": speed["diameter"]["basis"]},
            "why_empirical": "within a chart vendors print one SFM for all diameters; the trend is between tool "
                             "series. No cited physical law was found (lookup: no vc ∝ D^m in the literature; micro "
                             "tools are 'starved for spindle rpm', MSC/Iscar, second-hand)",
        },
        "speed_engagement": {
            "basis": "ae", "form": "v ∝ max(ae/D, ae_min)^(−k)",
            "k": {"value": speed["engagement"]["k"],
                  "source": f"within-chart contrasts, {speed['engagement']['n']} rows in "
                            f"{speed['engagement']['groups']} charts, equal vendor weights"},
            "ae_min": {"value": speed["engagement"]["ae_min"], "source": "grid search on the within-chart residual"},
        },
        "coating_speed_factor": {c: {"value": 1.0, "fitted": v["factor"],
                                     "source": "not applied: the speed level is fitted to bucket vendor medians, "
                                               "which mix coatings; fitted within-vendor factor reported (" + v["basis"] + ")",
                                     "vendor_groups": v["vendor_groups"]} for c, v in speed["coating"].items()},
        "families": fams,
    }


def tools_file(aggr, bt30=None):
    return {
        "version": VERSION, "status": "PROPOSED (calibration step 4)", "generated_by": "tools/calibrate_v2.py",
        "date": datetime.date.today().isoformat(),
        "carbide": {
            "E_mpa": {"value": 570000.0, "source": "CERATIZIT p-line 05/2024 p.22, 10 % Co submicron"},
            "trs_mpa": {"value": TRS_MPA, "source": "CERATIZIT CT-GS20Y 3800; Hyperion K10F 3700"},
            "fatigue_fraction": {"value": 0.375, "source": SRC["fatigue"]},
        },
        "edge_radius_mm": {"value": 0.002, "source": "micro end mills 0.4–3.5 µm (Liang 2018; Jäckel 2024); no "
                                                     "data vs diameter; not calibrated (C1 rarely binds above 1/32\")"},
        "C2": {"basis": "data/model_v2/chip_limits.json (band median of worst-flute h/D, eccentric runout at "
                        "TIR 0.0002\")", "source": "confirmed on the hold-out rows against fitted alternatives "
                                                   "(calibration_report.json c2)"},
        "aggressiveness": aggr,
        "C14": {"basis": "data/model_v2/consensus.json", "source": o.SRC["C14"]},
        "machine_bt30": dict(BT30, combined_k_n_um={"value": BT30_K, "source": "series of the two translational "
                                                                               "values above"},
                             status=BT30_BASIS),
    }


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--quick", action="store_true", help="skip the C3-on benchmark and T1/T12")
    args = ap.parse_args(argv)
    rows = load_rows()
    by_id = {r["id"]: r for r in rows}
    mach = reference_machine()
    print(f"{len(rows)} rows")

    force = fit_force_scale()
    force["k_r"] = 0.4
    print(f"force: tool factor {force['tool_factor']:.3f} (log sd {force['log_sd']:.3f}); 17-4 kc hardness "
          f"exponent from the dynamic pair {force['kc_hardness_exp_17_4']:.2f}")

    evals = evaluate_all(rows, mach)
    ok = [e for e in evals if "skip" not in e]
    skipped = collections.Counter(e["skip"] for e in evals if "skip" in e)
    print(f"evaluated {len(ok)}; skipped {dict(skipped)}")
    train_mask = lambda e: not e["holdout"]  # noqa: E731

    speed = fit_speed(ok, train_mask)
    eng = speed["engagement"]
    print(f"speed: engagement k {eng['k']:.3f} (se {eng['se']:.3f}), ae_min {eng['ae_min']}")
    for f, s in speed["families"].items():
        print(f"  {f:38} vc_ref {s['vc_ref_sfm']:6.0f} SFM at {s['hb_ref']:.0f} HB, q {s['q']:.2f} ({s['q_basis']})")
    err = {e["id"]: math.log(predict_sfm(speed, e) / e["sfm"]) for e in ok}
    speed_fit = _error_summary(ok, err, train_mask)
    speed_fit_by_family = {f: {"median_abs_log": statistics.median(abs(err[e["id"]]) for e in ok if e["family"] == f),
                               "bias": statistics.median(err[e["id"]] for e in ok if e["family"] == f)}
                           for f in speed["families"]}
    print(f"speed model alone: train {speed_fit['train']['median_abs_log']:.3f}, hold-out "
          f"{speed_fit['holdout']['median_abs_log']:.3f}")

    thin, thin_rows = thin_chip_study(rows, force["tool_factor"])
    for k, v in thin.items():
        print(f"  C4 outliers [{k}]: over fatigue {v['over_fatigue']}, over TRS {v['over_trs']} of {v['n']}")

    c2 = c2_study(by_id, ok, train_mask)
    for k, v in c2.items():
        print(f"  C2 {k:40} hold-out {v['holdout']['median_abs_log']:.3f} train {v['train']['median_abs_log']:.3f}")

    d = speed["diameter"]
    print(f"speed level (bucket vendor medians, {speed['n_level_rows']} rows): D term m {d['m']:.3f}, "
          f"knee {d['knee_in']:g}\"")
    for f, s_ in speed["families"].items():
        print(f"  {f:38} vc_ref {s_['vc_ref_sfm']:6.0f} SFM at {s_['hb_ref']:.0f} HB, q {s_['q']:.2f}")
    table_all = build_consensus(ok)
    table_train = build_consensus([e for e in ok if train_mask(e)])
    law_bias = {part: band_bias_vs_median(speed, [e for e in ok if sel(e)], table_all)
                for part, sel in (("train", train_mask), ("holdout", lambda e: not train_mask(e)))}
    for part, b in law_bias.items():
        print(f"  speed law vs bucket vendor median ({part}): " + ", ".join(f"{k} {v:+.3f}" for k, v in b.items()))
    offsets = fit_consensus_offsets([e for e in ok if train_mask(e)], by_id, speed, table_train)
    speed["consensus_offset"] = offsets
    for f in speed["families"].values():
        f["vc_ref_sfm_median"] = f["vc_ref_sfm"]
        f["vc_ref_sfm"] = f["vc_ref_sfm"] * offsets["speed_offset"]
    print(f"  consensus offsets: speed ×{offsets['speed_offset']:.3f}, C2 ×{offsets['c2_offset']:.3f}; predicted 75 % "
          f"band bias {json.dumps(_round(offsets['predicted_band_bias_75'], 3))}")

    aggr = aggressiveness_map(ok)
    ceiling = vendor_consensus_ceiling(by_id, ok)
    print(f"vendor-consensus ceiling: SFM pass {ceiling['sfm']['pass']:.1%} (median |log| "
          f"{ceiling['sfm']['median_abs_log']:.3f}), fz pass {ceiling['fz']['pass']:.1%} "
          f"({ceiling['fz']['median_abs_log']:.3f})")
    print("vendor spread (group median / bucket median): " + json.dumps(_round(aggr["vendor_spread_check"]["value"], 3)))

    def before_mat(r):
        if r["material"]["toolwiz_family"] == TITANIUM:
            return None, {"skip": "titanium: no mc in the step-3 defaults"}
        m, info = row_material(r)
        return m, info

    def after_mat(r):
        m, info = row_material(r, speed=speed, force=force)
        return (replace(m, c2_scale=offsets["c2_offset"]) if m else m), info

    bt30_ref = replace(mach, holder_k_n_um=BT30_K, holder_ktheta_nm_urad=BT30["ktheta_holder_joint_nm_urad"]["value"],
                       holder_basis=BT30_BASIS)
    hold_rows = [r for r in rows if holdout(r)]
    # The gate scores the product: C14 from all rows. The hold-out check (generalization of the fitted law and
    # offsets) runs the hold-out rows with C14 built from the training rows only.
    variants = [("before (step-3 defaults, 50 %)", before_mat, mach, False, o.Margins(0.5), None, rows),
                ("after 75 %", after_mat, mach, False, o.Margins(0.75, scheme="consensus"), table_all, rows),
                ("after 50 %", after_mat, mach, False, o.Margins(0.5, scheme="consensus"), table_all, rows),
                ("hold-out 75 % (C14 from training rows)", after_mat, mach, False,
                 o.Margins(0.75, scheme="consensus"), table_train, hold_rows),
                ("hold-out 50 % (C14 from training rows)", after_mat, mach, False,
                 o.Margins(0.5, scheme="consensus"), table_train, hold_rows)]
    if not args.quick:
        variants.append(("after 50 %, process (BT30, C3 0.05 mm stock, 5 µm wall)", after_mat, bt30_ref, True,
                         o.Margins(0.5, scheme="consensus"), table_all, rows))
    results, bench_rows, holdout_s5 = {}, {}, {}
    for name, fn, machine, c3, mg, cons, rws in variants:
        b = benchmark(rws, fn, machine, c3, mg, cons)
        s5, recs = section5(by_id, ok, b, train_mask, table_all)
        results[name] = s5
        bench_rows[name] = b
        ov = s5["overall"]
        print(f"benchmark [{name}]: n {ov['n']}, feasible {ov['feasible']}, pass SFM {ov['pass_sfm']:.1%}, "
              f"fz {ov['pass_fz']:.1%}; median |log| SFM {ov['mal_sfm']:.3f}, fz {ov.get('mal_fz', float('nan')):.3f}; "
              f"bias vs vendor median SFM {ov.get('bias_vs_median_sfm', float('nan')):+.3f}, "
              f"fz {ov.get('bias_vs_median_fz', float('nan')):+.3f}, MRR {ov.get('bias_vs_median_mrr', float('nan')):+.3f}; "
              f"C14 binding {s5['c14_binding']}")
        for band, v in s5["by_band"].items():
            if v:
                print(f"    {band:10} SFM {v.get('bias_vs_median_sfm', float('nan')):+.3f} fz "
                      f"{v.get('bias_vs_median_fz', float('nan')):+.3f} MRR {v.get('bias_vs_median_mrr', float('nan')):+.3f}"
                      f" | mal SFM {v['mal_sfm']:.3f} fz {v.get('mal_fz', float('nan')):.3f}")
    gates = {"all rows, C14 from all rows (the product)": gate(results["after 75 %"], results["after 50 %"], ceiling),
             "hold-out rows, C14 from training rows": gate(results["hold-out 75 % (C14 from training rows)"],
                                                           results["hold-out 50 % (C14 from training rows)"], ceiling)}
    for part, g in gates.items():
        print(f"gate ({part}): " + ", ".join(f"{b} {'PASS' if v['pass'] else 'fail'}" for b, v in g.items()))
    t1t12 = [] if args.quick else t1_t12(speed, force, table_all, offsets["c2_offset"])
    for r in t1t12:
        print(f"  {r['tool']:3} {r['operation']:8} {r['model']:10} ap {r['ap_over_D']:.2f}·D ae {r['ae_over_D']:.3f}·D "
              f"fz {r['fz_in']:.5f} SFM {r['sfm']:.0f} IPM {r['ipm']:.1f} MRR {r['mrr_in3_min']:.4f} {r['binding']}"
              + (f" holder {r['holder_share_of_wall']:.0%} of wall" if "holder_share_of_wall" in r else ""))

    os.makedirs(OUT_DIR, exist_ok=True)
    write_json("materials.json", materials_file(force, speed))
    write_json("tools.json", tools_file(aggr))
    write_json("consensus.json", table_all)
    outliers = sorted(((rid, s) for rid, s in thin_rows[f"TIR 0 + tool factor {force['tool_factor']:.2f}"].items()
                       if s > FATIGUE_MPA), key=lambda kv: -kv[1])
    report = {
        "version": VERSION, "generated_by": "tools/calibrate_v2.py", "date": datetime.date.today().isoformat(),
        "holdout": {"fraction": HOLDOUT_FRACTION, "unit": "(vendor group, document, family) groups, sha256 hash",
                    "rows_train": sum(1 for e in ok if not e["holdout"]), "rows_holdout": sum(1 for e in ok if e["holdout"])},
        "skipped": dict(skipped),
        "force": force,
        "speed": speed, "speed_fit": speed_fit, "speed_fit_by_family": speed_fit_by_family,
        "thin_chip": {"variants": thin, "sources": SRC["thin_chip"],
                      "remaining_over_fatigue_at_tir0_tool_factor": [
                          {"id": rid, "sigma1_mpa": s, "class": outlier_class(by_id[rid])} for rid, s in outliers],
                      "remaining_by_class": dict(collections.Counter(outlier_class(by_id[rid]) for rid, _ in outliers))},
        "c2": c2, "aggressiveness": aggr, "vendor_consensus_ceiling": ceiling, "section5": results,
        "gate": gates, "speed_law_bias_vs_vendor_median": law_bias,
        "t1_t12": t1t12,
        "sources": SRC,
    }
    write_json("calibration_report.json", report)
    ev = {e["id"]: e for e in ok}
    per_row = []
    for rid, e in ev.items():
        rec = {"id": rid, "vendor_group": e["vendor_group"], "family": e["family"], "operation": e["operation"],
               "D": e["D"], "holdout": e["holdout"], "vendor_sfm": e["sfm"], "vendor_fz": e["fz"],
               "sigma1_vendor_cut_mpa": e["sigma1_mpa"], "h_worst_over_D": e["h_worst_over_D"]}
        for name, b in bench_rows.items():
            x = b.get(rid)
            if x and "skip" not in x:
                rec[name] = {"sfm": x["sfm"], "fz": x["fz"], "binding": x["binding"]}
        per_row.append(rec)
    write_json("calibration_rows.json", {"version": VERSION, "rows": per_row})
    print(f"wrote {OUT_DIR}")


if __name__ == "__main__":
    main()
