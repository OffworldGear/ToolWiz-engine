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
_CACHE = {}


def load(path=None):
    path = path or MATERIALS_PATH
    if path not in _CACHE:
        with open(path, encoding="utf-8") as fh:
            _CACHE[path] = json.load(fh)
    return _CACHE[path]


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
                  vc_engagement_basis=eng["basis"])
    kw.update(overrides)
    return o.Material(**kw)
