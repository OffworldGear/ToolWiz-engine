"""Solid-carbide high-feed end mills in v2: geometry, entry (ramp) guidance and wall stock.

A high-feed end mill cuts with a low lead angle kappa0 (10-20 degrees from the axis-normal plane) over a short axial
depth (its maximum ap, apmx). The chip normal to the edge is h = fz sin(kappa0), so for the same chip as a square end mill
the feed per tooth is 1/sin(kappa0) larger (3.9x at 15 degrees); the cutting force acts mostly along the axis and the
lateral load sits at the tip, so bending (C3, C4) is small. The engine models the edge with
`physics_v2.endforms.HighFeedProfile` (straight lead edge, per-slice radius and lead angle in `ShapedEngagement`); every
other limit (C1-C5, C7, C11, C14, C15) applies as for any end mill, and C6 caps ap at apmx.

Geometry from the request: diameter, flutes, apmx ("max ap"), and the lead angle or the CAM programming radius (a bull-nose
radius r_p that approximates the profile: tan(kappa0) = apmx / r_p). Missing values take the defaults below and are named
as assumed in the result.

Defaults (estimates, marked "assumed" in every result; no vendor data in the repository yet):
* lead angle 15 degrees: the middle of the 10-20 degrees of solid high-feed end mills in general descriptions; not read
  from a specific catalog.
* apmx 0.06 x D: solid high-feed tools are rated for a few percent of D per level; the unverified Seco-style example of a
  1/8" tool at ap 0.0079" (0.063 x D) is of that order. Not calibrated to it.
"""
import math
from dataclasses import dataclass, field

DEFAULT_LEAD_DEG = 15.0
DEFAULT_APMX_OVER_D = 0.06
LEAD_RANGE_DEG = (5.0, 45.0)
# Entry (ramp) guidance. A non-center-cutting high-feed tool must not plunge. The ramp may not drop more than apmx over
# the tool's diameter (geometric bound) and is capped at RAMP_CAP_DEG (estimate: published solid high-feed ramp limits are
# a few degrees; not verified for a specific tool). The helical entry's tool-centre path must be at least 2 r_in across so
# the uncut core under the dished end face is cut away (r_in: the radius where the lead edge starts), with HELIX_MARGIN.
RAMP_CAP_DEG = 3.0
HELIX_MARGIN = 1.15
RAMP_FEED_FRACTION = 0.5     # ramp feed as a fraction of the cutting feed (estimate)
PLUNGE_FEED_FRACTION = 0.25  # only for the CAM's plunge field; the tips say not to plunge
STOCK_MIN_IN = 0.05 / 25.4


@dataclass(frozen=True)
class Geometry:
    """A high-feed end mill's cutting geometry (inches, degrees) and which values were assumed."""
    D_in: float
    lead_deg: float
    apmx_in: float
    assumed: tuple = ()
    basis: str = ""
    programming_radius_in: float = 0.0

    def profile_mm(self):
        from physics_v2 import endforms
        return endforms.HighFeedProfile(self.D_in * 25.4 / 2.0, self.lead_deg, self.apmx_in * 25.4)

    @property
    def r_in_in(self):
        return self.profile_mm().r_in / 25.4

    @property
    def sin_kappa(self):
        return self.profile_mm().sk

    def to_dict(self):
        return {"lead_angle_deg": self.lead_deg, "max_ap_in": self.apmx_in, "inner_radius_in": self.r_in_in,
                "programming_radius_in": self.programming_radius_in or None, "assumed": list(self.assumed),
                "basis": self.basis, "chip_thinning_factor": 1.0 / self.sin_kappa}


def resolve(D_in, apmx_in=None, lead_deg=None, programming_radius_in=None):
    """The geometry from what the request gives; defaults are listed in `assumed`."""
    D = float(D_in)
    assumed, why = [], []
    if apmx_in and apmx_in > 0:
        apmx = min(float(apmx_in), 0.5 * D)
        why.append(f"max ap {apmx:.4f}\" given")
    else:
        apmx = DEFAULT_APMX_OVER_D * D
        assumed.append("max_ap")
        why.append(f"max ap {apmx:.4f}\" assumed ({DEFAULT_APMX_OVER_D:g} x D)")
    rp = float(programming_radius_in or 0.0)
    if lead_deg and lead_deg > 0:
        lead = float(lead_deg)
        why.append(f"lead angle {lead:g} deg given")
    elif rp > 0:
        lead = math.degrees(math.atan2(apmx, rp))
        why.append(f"lead angle {lead:.1f} deg from the programming radius {rp:.4f}\" (tan = max ap / radius)")
    else:
        lead = DEFAULT_LEAD_DEG
        assumed.append("lead_angle")
        why.append(f"lead angle {lead:g} deg assumed")
    lead = min(max(lead, LEAD_RANGE_DEG[0]), LEAD_RANGE_DEG[1])
    return Geometry(D, lead, apmx, tuple(assumed), "; ".join(why), rp)


def is_high_feed(geometry="", tool="", operation=""):
    """True for a high-feed end mill: geometry "High Feed", or tool text naming one ("high feed", "high-feed", HF, HFM)."""
    import re
    g = str(geometry or "").strip().lower()
    t = str(tool or "").lower()
    if g in ("high feed", "high-feed", "highfeed", "hf", "hfm"):
        return True
    text = f"{g} {t}"
    return bool(re.search(r"high[\s_-]?feed|\bhfm?\b", text))


def entry_guidance(geo, feed_ipm, rpm):
    """Ramp and helical-entry guidance for a non-center-cutting high-feed tool (a ramp dict like physics_v2.ramp's)."""
    D, r_in = geo.D_in, geo.r_in_in
    angle = min(math.degrees(math.atan(geo.apmx_in / D)), RAMP_CAP_DEG)
    helix_min = max(2.0 * r_in * HELIX_MARGIN, 0.25 * D)
    helix = max(helix_min, 0.5 * D)
    pitch = math.pi * helix * math.tan(math.radians(angle))
    return {
        "feasible": True, "high_feed": True, "ramp_angle_deg": angle, "helix_diameter_in": helix,
        "helix_min_diameter_in": helix_min, "helix_diameter_over_D": helix / D, "helix_min_diameter_over_D": helix_min / D,
        "bore_diameter_in": helix + D, "pitch_in": pitch, "rpm": rpm, "ramp_feed_ipm": RAMP_FEED_FRACTION * feed_ipm,
        "plunge_feed_ipm": PLUNGE_FEED_FRACTION * feed_ipm,
        "plunge_note": "Do not plunge: a high-feed end mill is not center cutting (its end face is dished inside the lead edge)",
        "binding": [], "basis": (f"ramp angle = min(atan(max ap / D), {RAMP_CAP_DEG:g} deg); helix diameter >= "
                                 f"{HELIX_MARGIN:g} x 2 x the lead edge's inner radius ({r_in:.4f}\") so the uncut core is cut "
                                 f"away; ramp feed {RAMP_FEED_FRACTION:.0%} of the cutting feed (estimates)"),
    }


def wall_stock(geo, ap_in, ae_in):
    """(radial, axial) stock to leave (in): the lead edge leaves a stepped, sloped wall: at each level's floor the cut
    radius is r_in, so up to R - r(0) of radial material stays; between pocket passes wider than 2 r_in the floor keeps
    cusps of (ae/2 - r_in) tan(kappa0)."""
    p = geo.profile_mm()
    R = geo.D_in / 2.0
    radial = max(R - p.radius(0.0) / 25.4, STOCK_MIN_IN)
    cusp = 0.0
    if ae_in < 0.95 * geo.D_in:   # pocket passes side by side; a full slot is one pass (its floor is flat within r_in)
        cusp = max(0.0, (ae_in / 2.0 - geo.r_in_in) * math.tan(math.radians(geo.lead_deg)))
    axial = max(cusp, STOCK_MIN_IN)
    return math.ceil(radial / 0.0005 - 1e-9) * 0.0005, math.ceil(axial / 0.0005 - 1e-9) * 0.0005


def tips(geo, cut, entry, axial_force_n=None):
    """Plain-sentence tips for a high-feed result (the web panel and the add-in show `tips`)."""
    ap, ae = cut["ap_in"], cut["ae_in"]
    radial, axial = wall_stock(geo, ap, ae)
    out = [
        {"title": "High-feed entry", "type": "warning", "fusion": True,
         "message": (f"Do not plunge: this high-feed end mill is not center cutting. Ramp at {entry['ramp_angle_deg']:.1f} deg or "
                     f"less, or enter on a helix of at least {entry['helix_min_diameter_in']:.4f}\" tool-centre diameter "
                     f"(bore {entry['helix_min_diameter_in'] + geo.D_in:.4f}\"), at {entry['ramp_feed_ipm']:.1f} IPM.")},
        {"title": "High-feed walls", "type": "info", "fusion": True,
         "message": (f"The walls come out stepped by the tool's lead edge, not square: leave at least {radial:.4f}\" radial and "
                     f"{axial:.4f}\" axial stock and finish walls and corners with a square end mill.")},
        {"title": "High-feed depth", "type": "info", "fusion": True,
         "message": (f"Depth per level {ap:.4f}\" (the tool's max ap is {geo.apmx_in:.4f}\"); take the feature depth in many "
                     f"shallow levels. The chip is thinned by the {geo.lead_deg:.0f} deg lead angle "
                     f"({1.0 / geo.sin_kappa:.1f}x the feed per tooth of a square end mill for the same chip).")},
    ]
    if geo.assumed:
        names = {"max_ap": "max ap", "lead_angle": "lead angle"}
        out.append({"title": "High-feed geometry assumed", "type": "warning", "fusion": True,
                    "message": (f"The tool's {' and '.join(names.get(a, a) for a in geo.assumed)} "
                                f"{'was' if len(geo.assumed) == 1 else 'were'} not given ({geo.basis}). Enter the catalog values (max ap, lead angle or programming radius) "
                                f"for numbers that match your tool.")})
    ref = (cut.get("_square_chart_sfm") if isinstance(cut, dict) else None)
    no_chart = (cut.get("_vendor_mode") in (None, "none", "off")) if isinstance(cut, dict) else True
    sl = (cut.get("_spindle_limited") or {}) if isinstance(cut, dict) else {}
    if sl.get("limited"):
        out.append({"title": "High-feed spindle-limited", "type": "warning", "fusion": True, "message": sl["sentence"]})
    if no_chart and ref and cut.get("sfm") and cut["sfm"] > 1.1 * ref:
        out.append({"title": "High-feed speed not chart-capped", "type": "warning", "fusion": True,
                    "message": (f"{cut['sfm']:.0f} SFM is the physics (tool-life) speed with no vendor cap: ToolWiz has no "
                                f"high-feed chart yet, and the square-end chart for this material reads {ref:.0f} SFM at this "
                                f"aggressiveness. Start nearer that speed until the tool maker's chart says otherwise.")})
    if axial_force_n is not None:
        out.append({"title": "High-feed axial load", "type": "info", "fusion": True,
                    "message": (f"Most of the cutting force pushes up the spindle: about {axial_force_n / 4.448:.0f} lbf "
                                f"({axial_force_n:.0f} N) axial. ToolWiz has no axial-load limit for the spindle or holder; "
                                f"it is reported, not checked.")})
    return out
