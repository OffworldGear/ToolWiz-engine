"""Optimizer inputs from the calibrated parameter files (design §4.1; written by tools/calibrate_v2.py).

data/model_v2/materials.json holds, per GWizard family, the Sandvik Kienzle groups and the fitted speed law,
plus the force scale and the engagement law; every value carries its `source`. The files are PROPOSED
parameters until the user adopts them; nothing in the optimizer reads them by default. This module only
turns them into `optimize.Material` keyword arguments, so step 5 (integration) and the calibration report
use one construction.

    >>> from physics_v2 import params
    >>> m = params.material("Stainless - PH Series (17-4)", hb=356.0)
    >>> m.kienzle.kc1_1, m.hb_ref, m.vc_engagement_basis
    (1800.0, 200.0, 'ae')
"""
import json
import os

from physics_v2 import forces
from physics_v2 import optimize as o

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MATERIALS_PATH = os.path.join(ROOT, "data", "model_v2", "materials.json")
TOOLS_PATH = os.path.join(ROOT, "data", "model_v2", "tools.json")
CONSENSUS_PATH = o.CONSENSUS_DEFAULT_PATH
# C14 by vendor (owner decisions 2026-11-12): brand, unbranded default (Helical HEM, Harvey + Helical), consensus.
VENDOR_TABLE_PATH = o.VENDOR_TABLE_DEFAULT_PATH
ENVELOPE_PATH = o.ENVELOPE_DEFAULT_PATH
# C15 chip space (2026-11-12): gullet room against the chip, K per material group from the most packed published full
# slot (tools/calibrate_chip_space.py; sources in the file and docs/research/chip_space.md).
from physics_v2 import chipspace as _chipspace  # noqa: E402
CHIP_SPACE_PATH = _chipspace.CHIP_SPACE_PATH
# C2 basis of the calibrated model: "nominal" (runout-free chip fz·sin φe ≤ the vendor median nominal chip, plus the
# worst-flute chip ≤ the vendor p90, C2o) keeps the feed from collapsing at the first microns of runout on micro
# tools; "worst" (worst-flute chip ≤ the median) is optimize.py's own default. See docs/V3_IMPLEMENTATION_PLAN.md M1.
C2_BASIS = "nominal"
# Roughing objective (owner, 2026-11-11): the highest-MRR cut that meets every hard limit and the vendor envelope; the cut closest
# to the vendor medians is chosen only among candidates within this fraction of the best MRR.
MRR_TIE_BAND = 0.03
_CACHE = {}


def load(path=None):
    path = path or MATERIALS_PATH
    if path not in _CACHE:
        with open(path, encoding="utf-8") as fh:
            _CACHE[path] = json.load(fh)
    return _CACHE[path]


SPEED_BY_FAMILY_PATH = os.path.join(ROOT, "data", "model_v2", "speed_by_family.json")


def speed_by_family():
    """The per-family refit of the C7 law (families -> parameters), {} when the file is absent."""
    if SPEED_BY_FAMILY_PATH not in _CACHE:
        try:
            with open(SPEED_BY_FAMILY_PATH, encoding="utf-8") as fh:
                _CACHE[SPEED_BY_FAMILY_PATH] = json.load(fh).get("families", {})
        except OSError:
            _CACHE[SPEED_BY_FAMILY_PATH] = {}
    return _CACHE[SPEED_BY_FAMILY_PATH]


def coating_class(label):
    """Coating chemistry from a catalog label; proprietary names without a chemistry are 'unspecified'."""
    if not label:
        return "unspecified"
    s = label.lower()
    if "uncoated" in s:
        return "uncoated"
    if "dlc" in s:
        return "DLC"
    if any(k in s for k in ("altisin", "tialsin", "tialcrsin", "tisinos")):
        return "Si-doped"
    if "alcr" in s:
        return "AlCrN"
    if "altin" in s or "tialn" in s:
        return "AlTiN/TiAlN"
    return "unspecified"


def material(family, hb=None, coating=None, path=None, **overrides):
    """An optimize.Material for a family at hardness hb (HB) with the calibrated force scale and speed law.

    The Kienzle group is the family's Sandvik row nearest hb (as the calibration evaluated the vendor rows);
    hb None uses the first group's nominal hardness. coating is a catalog label or a coating class.
    """
    p = load(path)
    fam = p["families"].get(family)
    if fam is None:
        raise KeyError(f"no calibrated parameters for {family!r}")
    groups = fam["kienzle_groups"]
    g = min(groups, key=lambda x: abs(x["hb_ref"] - hb)) if hb else groups[0]
    k = forces.Kienzle(float(g["kc1_1_n_mm2"]), float(g["mc"]), 0.0,
                       (("code", g["code"]), ("hardness", f"{g['hb_ref']:g} HB"), ("source", g["source"])))
    force = p["force"]
    kw = dict(name=f"{family}, {hb or g['hb_ref']:g} HB (calibrated {p['version']}, {g['code']})", kienzle=k,
              family=family,
              hb_ref=float(g["hb_ref"]), hb=float(hb or g["hb_ref"]),
              kc_hardness_exp=float(fam["kc_hardness_exp"]["value"]),
              tool_factor=float(force["tool_factor"]["value"]), k_r=float(force["k_r"]["value"]),
              k_te=float(force["k_te_n_mm"]["value"]), k_re=float(force["k_re_n_mm"]["value"]))
    sp = fam.get("speed")
    if sp:
        cc = coating if coating in p["coating_speed_factor"] else coating_class(coating)
        cf = p["coating_speed_factor"].get(cc, {"value": 1.0})["value"]
        eng = p["speed_engagement"]
        kw.update(vc_ref_sfm=float(sp["vc_ref_sfm"]["value"]) * float(cf), vc_hb_ref=float(sp["hb_ref"]["value"]),
                  vc_hardness_exp=float(sp["vc_hardness_exp"]["value"]), taylor_n=float(sp["taylor_n"]["value"]),
                  vc_engagement_exp=float(eng["k"]["value"]), vc_engagement_ae_min=float(eng["ae_min"]["value"]),
                  vc_engagement_basis=eng["basis"],
                  vc_engagement_ae_ref=float((eng.get("ae_ref") or {"value": 1.0})["value"]))
        so = p.get("speed_operation")
        if so:
            kw.update(vc_op_factor=tuple((k, float(v["value"])) for k, v in so["factors"].items()))
        dia = p.get("speed_diameter")
        if dia:
            kw.update(vc_diameter_exp=float(dia["m"]["value"]), vc_d_knee_in=float(dia["knee_in"]["value"]))
    ov = speed_by_family().get(family)
    if ov and ov.get("applied") and sp:
        # V3 round 4: per-family level, engagement exponent and diameter term (tools/fit_speed_by_family.py), applied
        # only where the refit did not do worse on the hold-out groups.
        kw.update(vc_ref_sfm=float(ov["vc_ref_sfm"]) * float(cf), vc_engagement_exp=float(ov["engagement_k"]),
                  vc_diameter_exp=float(ov["diameter_m"]), vc_d_knee_in=float(ov["diameter_knee_in"]))
    off = p.get("consensus_offsets")
    if off:
        kw["c2_scale"] = float(off["c2"]["value"])
    kw.update(overrides)
    return o.Material(**kw)


def margins(aggressiveness=0.5):
    """The consensus aggressiveness scheme (user decision 2026-10-17): 75 % ≈ the vendor median."""
    return o.Margins(aggressiveness, scheme="consensus")


def machine(tir_in=0.0002):
    """The Speedio 16k with the machine profile's spindle/holder stiffness (holder_stiffness in
    machines/speedio_s500x2.json, provisional BT30 until the user's push-load test) in series in C3."""
    return o.speedio_16k(tir_in, holder=True)


speedio_bt30 = machine


def optimize(tool, material_, operation="adaptive", aggressiveness=0.5, machine_=None, **kw):
    """optimize.optimize with the calibrated defaults (user decisions 2026-10-17): the consensus aggressiveness
    scheme, C14 from data/model_v2/consensus_by_vendor.json (brand, default, consensus; `brand` = a vendor key or None),
    the machine profile's holder stiffness, (V3) the vendor engagement envelope and the chip-load floor, and C15 chip
    space (data/model_v2/chip_space.json)."""
    kw.setdefault("consensus", CONSENSUS_PATH)
    kw.setdefault("consensus_shaped", o.CONSENSUS_SHAPED_DEFAULT_PATH)
    kw.setdefault("vendor_table", VENDOR_TABLE_PATH)
    kw.setdefault("envelope", ENVELOPE_PATH)
    kw.setdefault("chip_floor", "vendor")
    kw.setdefault("c2_basis", C2_BASIS)
    kw.setdefault("depth_trade", MRR_TIE_BAND)
    kw.setdefault("select_tir_in", o.REFERENCE_TIR_IN)
    kw.setdefault("chip_space", CHIP_SPACE_PATH)
    return o.optimize(tool, material_, machine_ or machine(), operation, margins=margins(aggressiveness), **kw)


def evaluate_user_engagement(tool, material_, operation, ap_in, ae_in, aggressiveness=0.5, machine_=None, **kw):
    """optimize.evaluate_user_engagement with the same calibrated defaults: rpm and fz for the user's own ap and ae."""
    kw.setdefault("consensus", CONSENSUS_PATH)
    kw.setdefault("consensus_shaped", o.CONSENSUS_SHAPED_DEFAULT_PATH)
    kw.setdefault("vendor_table", VENDOR_TABLE_PATH)
    kw.setdefault("c2_basis", C2_BASIS)
    kw.setdefault("chip_space", CHIP_SPACE_PATH)
    return o.evaluate_user_engagement(tool, material_, machine_ or machine(), operation, ap_in, ae_in,
                                      margins=margins(aggressiveness), **kw)


# C3 deflection allowance for roughing, adaptive and slots (V3 plan M2, REVIEW Part 5.3 item 2):
# allow = min(50 % of the stock to leave, k·D), k = C3_K_BASE + C3_K_SLOPE·aggressiveness, i.e. 0.5 % of D at
# aggressiveness 0, 1.0 % at 50 %, 1.5 % at 100 % (owner decision D7). The stock term governs above 3/32".
C3_K_BASE = 0.005
C3_K_SLOPE = 0.010


def c3_k(aggressiveness):
    """k of the C3 allowance k·D (fraction of the diameter) at aggressiveness a in [0, 1]."""
    return C3_K_BASE + C3_K_SLOPE * min(max(float(aggressiveness), 0.0), 1.0)
