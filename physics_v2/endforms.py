"""End forms of solid end mills: square, bull-nose (corner radius) and ball. Pure geometry, lengths in mm.

A cutting profile is a cylinder of radius R = D/2 whose tip is rounded by a corner radius rc (0 square, 0 < rc < R bull
nose, rc = R ball). z is the height above the tip. In the corner (0 <= z < rc) the local cutting radius is

    r(z) = R - rc + sqrt(rc^2 - (rc - z)^2),

and the profile's surface normal makes the angle kappa with the tool axis, sin(kappa) = (r(z) - (R - rc))/rc, 1 on the
cylinder (z >= rc). Consequences used by the v2 model (docs/research/v4_engine_findings.md):

* Effective cutting diameter at an axial depth ap: D_eff = 2 r(ap) (v_c = pi D_eff n; vendors' ball-nose sheets
  tell you to set the rpm from it). For a ball tool with ap < R it is 2 sqrt(R^2 - (R - ap)^2).
* Axial (lead-angle) chip thinning: the chip normal to the edge is h_n = fz sin(phi) sin(kappa). The edge element is
  ds = dz / sin(kappa), so the chip area per slice dz stays fz sin(phi) dz (continuity with the square tool).
* Helix: the lag per unit height is tan(beta)/r(z).
"""
import math

MIN_SIN_KAPPA = 0.02    # edge length element dz/sin(kappa) is not integrated below this (the very tip)
MIN_R_OVER_R = 0.10     # helix lag uses r(z) >= 0.1 R


def clamp_corner(R, rc):
    """The corner radius limited to [0, R]."""
    return max(0.0, min(float(rc or 0.0), R))


def radius(z, R, rc):
    """Local cutting radius at height z above the tip (mm)."""
    if rc <= 0.0 or z >= rc:
        return R
    z = max(z, 0.0)
    return R - rc + math.sqrt(max(rc * rc - (rc - z) ** 2, 0.0))


def sin_kappa(z, R, rc):
    """Sine of the angle between the surface normal and the tool axis at height z (1 on the cylinder)."""
    if rc <= 0.0 or z >= rc:
        return 1.0
    z = max(z, 0.0)
    return math.sqrt(max(rc * rc - (rc - z) ** 2, 0.0)) / rc


def effective_diameter(ap, D, rc):
    """Effective cutting diameter at axial depth ap (mm): 2 r(ap)."""
    return 2.0 * radius(ap, D / 2.0, clamp_corner(D / 2.0, rc))


def end_form(D, rc):
    """'square', 'bull' or 'ball' for a tool of diameter D and corner radius rc (same units)."""
    rc = clamp_corner(D / 2.0, rc)
    if rc <= 1e-9:
        return "square"
    return "ball" if rc >= D / 2.0 - 1e-9 else "bull"


def slice_heights(ap, rc, n_corner=10, n_cyl=None, helix_lag_per_mm=0.0, max_dpsi=0.08):
    """Midpoints and widths of the axial slices over [0, ap]: n_corner over the corner (z < min(ap, rc)) and over the
    cylinder above it as many as keep each slice's helix lag under max_dpsi rad (6 to 40). Returns [(z, dz), ...]."""
    out = []
    top_c0 = min(ap, rc) if rc > 0 else 0.0
    if n_cyl is None:
        n_cyl = int(min(40, max(6, math.ceil((ap - top_c0) * helix_lag_per_mm / max_dpsi))))
    top_c = min(ap, rc) if rc > 0 else 0.0
    if top_c > 0:
        dz = top_c / n_corner
        out += [((i + 0.5) * dz, dz) for i in range(n_corner)]
    if ap > top_c + 1e-12:
        span = ap - top_c
        dz = span / n_cyl
        out += [(top_c + (i + 0.5) * dz, dz) for i in range(n_cyl)]
    return out
