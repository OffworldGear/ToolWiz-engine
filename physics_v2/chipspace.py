"""C15, chip space: the chip one tooth cuts must fit in the gullet (flute valley) in front of it.

Model (docs/research/chip_space.md). Per unit length of edge, the chip one tooth removes over its engagement arc has
the cross-section h_m·L_arc = fz·ae (the mean chip thickness times the arc length; Sandvik's h_m = fz·(ae/D)/(φe/2)
and L_arc = φe·D/2 multiply to exactly fz·ae). The curled, loosely packed chip needs K times that area (the "chip
space number" of broaching practice: gullet area ≥ K × uncut chip area). The room available is the gullet area in
the transverse section,

    A_g = φ_void · (π/4)·D²·(1 − c_z²) / z

the annulus between the core (web) circle c_z·D and the cutting diameter, shared by z flutes, of which the fraction
φ_void is open gullet rather than tooth body. More flutes split the same annulus more ways and need a larger core,
so A_g per flute falls faster than 1/z.

In a full slot the chip cannot leave sideways while the tooth is in the cut; it has to climb the flute out of the
slot, so a deeper slot packs the gullet more: K_eff = K·(1 + k_d·max(0, ap/D − a0)) for ae ≥ enclosed·D (ae/D
0.95 and up); a side cut with one open side (any ae below that) releases the chip radially when the tooth leaves the
stock, K_eff = K. The check is the utilisation

    u = K_eff · fz · ae / A_g ≤ 1

K is calibrated per material group as the most packed full slot any vendor publishes (u = 1 at aggressiveness 1;
tools/calibrate_chip_space.py, data/model_v2/chip_space.json) and divided by the consensus aggressiveness scale
relative to aggressiveness 1 (the margin the engine keeps on C2) below that: at 50 % the gullet may be filled to
0.84 of the most packed published slot.
"""
import json
import math
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CHIP_SPACE_PATH = os.path.join(ROOT, "data", "model_v2", "chip_space.json")
_CACHE = {}


def load(path=None):
    """The chip-space parameter file (dict), cached."""
    path = path or CHIP_SPACE_PATH
    if path not in _CACHE:
        with open(path, encoding="utf-8") as fh:
            _CACHE[path] = json.load(fh)
    return _CACHE[path]


def core_ratio(z, table):
    """Core (web) diameter / D for z flutes from the parameter file's table (nearest listed count at the ends)."""
    t = {int(k): float(v) for k, v in table.items() if not str(k).startswith("_")}
    if z in t:
        return t[z]
    ks = sorted(t)
    return t[ks[0]] if z < ks[0] else t[ks[-1]]


def gullet_area(D, z, core, void_fraction):
    """Transverse gullet area per flute (units of D²): φ_void·(π/4)·D²·(1 − c²)/z."""
    return void_fraction * math.pi / 4.0 * D * D * (1.0 - core * core) / max(int(z), 1)


def chip_area(fz, ae, D):
    """Uncut chip area per tooth per unit edge length: h_m·L_arc = fz·ae (ae capped at D)."""
    return fz * min(ae, D)


def depth_factor(ap, ae, D, p):
    """K_eff / K: 1 for a cut with an open side; for a full slot (ae ≥ enclosed·D) 1 + k_d·max(0, ap/D − a0)."""
    d = p["depth"]
    if ae < float(d["enclosed_ae_over_D"]["value"]) * D:
        return 1.0
    return 1.0 + float(d["k_d"]["value"]) * max(0.0, ap / D - float(d["a0_over_D"]["value"]))


def group_packing(group, p):
    """(K at aggressiveness 1, basis) for a material group; unknown groups use the file's fallback group."""
    g = p["packing"].get(group)
    if g is None:
        fb = p["fallback_group"]
        g = p["packing"][fb]
        return float(g["K"]), f"no calibration for {group!r}; {fb} used"
    return float(g["K"]), g.get("basis", "")


def utilisation(fz, ap, ae, D, z, K, core, void_fraction, p):
    """u = K·depth_factor·fz·ae / A_g (1 = the gullet is as full as the limit allows)."""
    return K * depth_factor(ap, ae, D, p) * chip_area(fz, ae, D) / gullet_area(D, z, core, void_fraction)


def max_fz(ap, ae, D, z, K, core, void_fraction, p):
    """The chip load per tooth (in) at which u = 1."""
    return gullet_area(D, z, core, void_fraction) / (K * depth_factor(ap, ae, D, p) * min(ae, D))
