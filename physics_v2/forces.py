"""Cutting forces for solid end mills: chip geometry, Kienzle size effect, mechanistic forces, runout.

Design: docs/PHYSICS_MODEL_DESIGN.md §3.1–3.3 (step 2 of §6). Pure functions, no pipeline state.

Units are the source formulas' units: mm, N, N/mm², m/min, rpm, W. `Cut.from_inch` takes the
pipeline's inch inputs. Angles follow Altintas (*Manufacturing Automation*, ch. 2): the
immersion angle φ is measured clockwise from the +y axis, the feed is +x, and the chip is
h(φ) = fz·sin φ. Up milling engages φ ∈ [0, φe]; climb (down) milling φ ∈ [π − φe, π].

Model
-----
Chip geometry (§3.1):
    φe   = arccos(1 − 2·ae/D)                     engagement angle (π for a slot)
    h_max = fz·sin φe if ae < D/2 else fz
    h_m  = fz·(1 − cos φe)/φe = fz·(ae/D)/(φe/2)  mean of fz·sin φ over the arc (Sandvik form)
    z_c  = z·φe/(2π);  z_c' = min(z, z_c + ap·tan β/(π·D/z))

Forces (§3.2). Kienzle with Sandvik's rake term (`docs/research/kc_mc_survey.md` §2, SV-SCF):
    kc(h) = kc1.1·h^(−mc)·K_γ·K_wear,  K_γ = 1 − (γ − γ_ref)/100   (1 %/degree, h in mm)
The tangential coefficient is kc at the mean chip, K_tc = kc(h_m), as in Sandvik's power formula.
Per engaged tooth and unit axial length (Altintas eq. form):
    dF_t = (K_tc·h + K_te)·dz,   dF_r = (K_r·K_tc·h + K_re)·dz
K_r is the radial/tangential ratio of the shearing component; K_te, K_re are the edge
(ploughing) forces in N/mm. Sandvik's kc1.1 is fitted to total force, so K_te = K_re = 0
reproduces Sandvik exactly; the calibration step (§6 step 4) fits them.
    F_t,total = z_c·(K_tc·ap·h_m + K_te·ap)   mean over a revolution
    P = F_t,total·v_c,  T = P/ω = F_t,total·D/2
These reduce to Sandvik's Pc = ap·ae·vf·kc/(60·10⁶) kW when K_te = 0.

The lateral force is the vector sum over every engaged tooth and axial slice (helix lag
ψ = 2·z·tan β/D), sampled over one tooth pitch: its mean is Altintas's average force, its
maximum the peak used for deflection and stress (step 3).

Runout (§3.3). Flute k reaches r_k beyond nominal. The surface left by earlier flutes sets its chip:
    h_k = max(0, min over m = 1..z of (m·fz + r_k − r_(k−m)))
(Kline & DeVor; Bao & Tansel 2000). Two offset patterns:
  * "bound" (default): one flute high by TIR. This attains the worst chip any flute can see for a
    given TIR (max − min flute radius): fz + TIR, capped at the feed per rev z·fz. For two flutes
    it is the design's fz ± TIR.
  * "eccentric": a parallel-axis offset e = TIR/2, r_k = e·cos(phase − 2πk/z); worst flute
    fz + TIR·sin(π/z) at the worst phase.
In the linear force model runout moves force between flutes but leaves the mean force unchanged
(Σh_k = z·fz); it sets the worst flute's chip and peak force, which carry the C1/C2 limits.

Data: kc1.1/mc come from docs/research/data/kc_mc_sources.json via `load_kienzle`. The GWizard
family → Sandvik group mapping is the proposal in docs/research/material_mapping_v2.md; callers pass
the group code. K_r, K_te, K_re and any hardness correction are calibration outputs (step 4), so they
are arguments here with no material defaults.

Worked example: the user's T12 in 17-4 PH H1025
------------------------------------------------
T12 is a 1/16" 4-flute rougher with a 1/8" shank. The cut is Harvey SF_875400 (875462-C6, 17-4 PH,
350–400 HBn) "Roughing": 100 SFM, fz 0.00026", ap 0.6·D = 0.0372", ae 0.4·D = 0.0248"
(tests/benchmarks/v2/harvey.json). H1025 is about 356 HB, so the 350–400 HBn row applies.
Material: P5.0.Z.PH, kc1.1 = 2800 N/mm², mc = 0.21 at 330 HB (material_mapping_v2.md; no hardness
correction yet). Assumed, pending calibration: 0° rake, 35° helix, K_r = 0.4 (design range 0.3–0.6),
no edge force. TIR 0.0002" (machine default, §7.4). Spindle: Speedio 16k, continuous rating (C5,
decided 2026-10-15).

    >>> import json, os, machine_profiles
    >>> from physics_v2 import forces
    >>> cut = forces.Cut.from_inch(D=0.0625, z=4, ap=0.0372, ae=0.0248, fz=0.00026, sfm=100, helix_deg=35)
    >>> round(cut.rpm)
    6112
    >>> coeffs = forces.ForceCoefficients(forces.load_kienzle("P5.0.Z.PH"), k_r=0.4)
    >>> with open(os.path.join(machine_profiles.BUILTIN_DIR, "speedio_s500x2.json"), encoding="utf-8") as fh:
    ...     spindle = json.load(fh)["spindle_options"]["optional_16k"]
    >>> r = forces.cutting_forces(cut, coeffs, tir=0.0002 * 25.4, spindle=spindle)

6112 rpm. Engagement 78.1°; h_max = fz·sin φe = 0.0065 mm, h_m = 0.58·fz = 0.0038 mm (0.00015");
0.87 teeth in cut on average, 1.40 counting the helix overlap:

    >>> e = r["engagement"]
    >>> round(e["phi_e_deg"], 1), round(e["h_max_mm"] * 1000, 2), round(e["h_m_mm"] * 1000, 2)
    (78.1, 6.46, 3.85)
    >>> round(e["teeth_in_cut"], 2), round(e["teeth_in_cut_helix"], 2)
    (0.87, 1.4)

The chip is thin, so the size effect more than triples kc: kc = 2800·0.003845^−0.21 = 9002 N/mm².
Tangential force per engaged tooth 32.7 N. Power 14.4 W (Sandvik's ap·ae·vf·kc/60e6 gives the same),
torque 0.0225 N·m against the 7.97 N·m continuous cap at 6112 rpm (0.28 %). Power is not what limits
a 1/16" tool.

    >>> round(r["kc_n_mm2"]), round(r["per_tooth"]["F_t_n"], 1)
    (9002, 32.7)
    >>> round(r["total"]["power_w"], 1), round(r["total"]["torque_nm"], 4)
    (14.4, 0.0225)
    >>> round(r["spindle"]["available_torque_nm"], 2), round(r["spindle"]["torque_utilization"] * 100, 2), r["spindle"]["ok"]
    (7.97, 0.28, True)

Mean lateral force 29.0 N (6.5 lbf), peaking at 46.8 N (10.5 lbf) as the flutes enter and leave:

    >>> lat = r["lateral"]
    >>> round(lat["mean_n"], 1), round(lat["peak_n"], 1)
    (29.0, 46.8)

Runout dominates. TIR 0.0002" is 77 % of fz, so the worst flute carries fz + TIR = 0.00046"
(1.77·fz) and the flute behind it only 0.00006". The size effect softens the force increase:
the worst flute's peak force is 1.57× the nominal flute's, not 1.77×.

    >>> ro = r["runout"]
    >>> [round(h / 25.4, 5) for h in ro["flute_chips_mm"]]
    [0.00046, 6e-05, 0.00026, 0.00026]
    >>> round(ro["F_t_peak_worst_n"], 1), round(ro["F_t_peak_nominal_n"], 1)
    (77.4, 49.3)
"""
import functools
import json
import math
import os
from dataclasses import dataclass

import machine_profiles

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KC_SOURCES_PATH = os.path.join(ROOT, "docs", "research", "data", "kc_mc_sources.json")
MM_PER_IN = 25.4

# Reference rake for kc1.1 per source (kc_mc_survey.md §4.6). EU-TB and WE-FW are at +6° for steel
# and +2° for cast iron, which depends on the material, so the caller must state it.
REFERENCE_RAKE_DEG = {"SV-WEB": 0.0, "SE-NC": 0.0, "WA-TC": 0.0, "IS-UG": 0.0}

RUNOUT_MODELS = ("bound", "eccentric")


# ---------------------------------------------------------------------------
# Inputs
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Cut:
    """One side-milling or slotting pass with a square end mill. Lengths in mm."""
    D: float
    z: int
    ap: float
    ae: float
    fz: float
    rpm: float
    helix_deg: float = 0.0
    climb: bool = True

    def __post_init__(self):
        if self.D <= 0 or self.ap <= 0 or self.fz <= 0 or self.rpm <= 0:
            raise ValueError("D, ap, fz and rpm must be positive")
        if not 0 < self.ae <= self.D:
            raise ValueError("ae must be in (0, D]")
        if int(self.z) != self.z or self.z < 1:
            raise ValueError("z must be a positive whole number of flutes")
        if not 0 <= self.helix_deg < 90:
            raise ValueError("helix_deg must be in [0, 90)")

    @classmethod
    def from_inch(cls, D, z, ap, ae, fz, rpm=None, sfm=None, helix_deg=0.0, climb=True):
        """Build from inch lengths and either rpm or SFM (rpm = 12·SFM/(π·D))."""
        if (rpm is None) == (sfm is None):
            raise ValueError("give exactly one of rpm or sfm")
        if rpm is None:
            rpm = 12.0 * sfm / (math.pi * D)
        k = MM_PER_IN
        return cls(D * k, int(z), ap * k, ae * k, fz * k, float(rpm), float(helix_deg), climb)

    @property
    def vc_m_min(self):
        return math.pi * self.D * self.rpm / 1000.0

    @property
    def vf_mm_min(self):
        return self.fz * self.z * self.rpm

    @property
    def omega(self):
        return machine_profiles.rad_s(self.rpm)


@dataclass(frozen=True)
class Kienzle:
    """kc(h) = kc1_1·h^(−mc)·K_γ·K_wear with h in mm; kc1_1 in N/mm² at rake rake_ref_deg."""
    kc1_1: float
    mc: float
    rake_ref_deg: float = 0.0
    source: tuple = ()

    def kc(self, h_mm, rake_deg=0.0, k_wear=1.0):
        if h_mm <= 0:
            raise ValueError("kc is undefined for h <= 0")
        k_gamma = 1.0 - (rake_deg - self.rake_ref_deg) / 100.0
        return self.kc1_1 * h_mm ** (-self.mc) * k_gamma * k_wear


@dataclass(frozen=True)
class ForceCoefficients:
    """Material and edge coefficients for one tool/material pair."""
    kienzle: Kienzle
    k_r: float
    k_te: float = 0.0
    k_re: float = 0.0
    rake_deg: float = 0.0
    k_wear: float = 1.0

    def kc(self, h_mm):
        return self.kienzle.kc(h_mm, self.rake_deg, self.k_wear)


@functools.lru_cache(maxsize=4)
def _sources(path):
    with open(path, encoding="utf-8") as fh:
        return tuple(json.load(fh))


def load_kienzle(group_code, source_id="SV-WEB", rake_ref_deg=None, path=None):
    """kc1.1 and mc for a material group from kc_mc_sources.json (Sandvik MC code by default)."""
    rows = [r for r in _sources(path or KC_SOURCES_PATH)
            if r.get("source_id") == source_id and r.get("material_group_code") == group_code]
    if not rows:
        raise KeyError(f"{group_code!r} not found for source {source_id}")
    row = rows[0]
    kc1, mc = row.get("kc1_1_N_mm2"), row.get("mc")
    if kc1 is None or mc is None:
        raise ValueError(f"{source_id} {group_code}: kc1.1 or mc is not published (data gap)")
    if rake_ref_deg is None:
        rake_ref_deg = REFERENCE_RAKE_DEG.get(source_id)
        if rake_ref_deg is None:
            raise ValueError(f"{source_id} states kc1.1 at a material-dependent rake; pass rake_ref_deg")
    hardness = row.get("hardness_ref") or {}
    source = (("source_id", source_id), ("code", group_code), ("url", row.get("url")),
              ("hardness", f"{hardness.get('value')} {hardness.get('scale')}"),
              ("quoted", row.get("quoted_cells")))
    return Kienzle(float(kc1), float(mc), float(rake_ref_deg), source)


# ---------------------------------------------------------------------------
# Chip geometry (§3.1)
# ---------------------------------------------------------------------------

def engagement_angle(ae, D):
    """φe = arccos(1 − 2·ae/D), radians."""
    return math.acos(max(-1.0, min(1.0, 1.0 - 2.0 * ae / D)))


def engagement_arc(ae, D, climb=True):
    """(φst, φex) in Altintas's convention."""
    pe = engagement_angle(ae, D)
    return (math.pi - pe, math.pi) if climb else (0.0, pe)


def max_chip_thickness(fz, ae, D):
    return fz * math.sin(engagement_angle(ae, D)) if ae < D / 2.0 else fz


def mean_chip_thickness(fz, ae, D):
    """h_m = fz·(ae/D)/(φe/2), the mean of fz·sin φ over the engagement arc."""
    return fz * (ae / D) / (engagement_angle(ae, D) / 2.0)


def teeth_in_cut(z, ae, D):
    return z * engagement_angle(ae, D) / (2.0 * math.pi)


def teeth_in_cut_helix(z, ae, D, ap, helix_deg):
    """z_c + ap·tan β/(π·D/z), capped at z."""
    overlap = ap * math.tan(math.radians(helix_deg)) / (math.pi * D / z)
    return min(float(z), teeth_in_cut(z, ae, D) + overlap)


# ---------------------------------------------------------------------------
# Forces (§3.2)
# ---------------------------------------------------------------------------

def lateral_force(cut, k_tc, k_rc, k_te=0.0, k_re=0.0, n_theta=720, n_axial=None):
    """Mean and peak lateral force on the tool (N): vector sum over engaged teeth and axial slices.

    Returns feed (x) and normal (y) components in Altintas's frame. The mean is over one tooth
    pitch, which equals the mean over a revolution.
    """
    phi_st, phi_ex = engagement_arc(cut.ae, cut.D, cut.climb)
    z, pitch, two_pi = cut.z, 2.0 * math.pi / cut.z, 2.0 * math.pi
    lag = 2.0 * math.tan(math.radians(cut.helix_deg)) / cut.D        # rad per mm of axial height
    n_ax = 1 if lag == 0 else (n_axial or 32)
    dz = cut.ap / n_ax
    slices = [(s + 0.5) * dz * lag for s in range(n_ax)]
    sum_x = sum_y = 0.0
    peak = (0.0, 0.0, 0.0)
    for i in range(n_theta):
        theta = (i + 0.5) * pitch / n_theta
        fx = fy = 0.0
        for psi in slices:
            for j in range(z):
                phi = (theta + j * pitch - psi) % two_pi
                if phi_st <= phi <= phi_ex:
                    s, c = math.sin(phi), math.cos(phi)
                    h = cut.fz * s
                    dft = (k_tc * h + k_te) * dz
                    dfr = (k_rc * h + k_re) * dz
                    fx += -dft * c - dfr * s
                    fy += dft * s - dfr * c
        sum_x += fx
        sum_y += fy
        mag = math.hypot(fx, fy)
        if mag > peak[0]:
            peak = (mag, fx, fy)
    mx, my = sum_x / n_theta, sum_y / n_theta
    return {"mean_feed_n": mx, "mean_normal_n": my, "mean_n": math.hypot(mx, my),
            "peak_n": peak[0], "peak_feed_n": peak[1], "peak_normal_n": peak[2]}


# ---------------------------------------------------------------------------
# Runout (§3.3)
# ---------------------------------------------------------------------------

def runout_offsets(tir, z, model="bound", phase=0.0):
    """Radial reach of each flute beyond nominal (same units as tir)."""
    if model == "bound":
        return [float(tir)] + [0.0] * (z - 1)
    if model == "eccentric":
        e = tir / 2.0
        return [e * math.cos(phase - 2.0 * math.pi * k / z) for k in range(z)]
    raise ValueError(f"runout model must be one of {RUNOUT_MODELS}")


def flute_chip_loads(fz, offsets):
    """Feed-direction chip of each flute: max(0, min over m of m·fz + r_k − r_(k−m))."""
    z = len(offsets)
    return [max(0.0, min(m * fz + offsets[k] - offsets[(k - m) % z] for m in range(1, z + 1)))
            for k in range(z)]


def runout_chips(fz, z, tir, model="bound", phase=0.0):
    """Per-flute chips, the worst flute's index and chip, and the flutes that only rub."""
    chips = flute_chip_loads(fz, runout_offsets(tir, z, model, phase))
    worst = max(range(z), key=lambda k: chips[k])
    return {"model": model, "tir": tir, "flute_chips": chips, "worst_flute": worst,
            "h_worst": chips[worst], "rubbing_flutes": [k for k, h in enumerate(chips) if h <= 0.0]}


# ---------------------------------------------------------------------------
# Spindle (§3.5 C5)
# ---------------------------------------------------------------------------

def spindle_check(torque_nm, power_kw, rpm, spindle, rating):
    """Compare a cut with the spindle's capacity at rpm for a duty rating (machine_profiles.capacity)."""
    cap = machine_profiles.capacity(spindle, rpm, rating)
    max_rpm = spindle.get("max_rpm")
    out = {"rating": rating, "rpm": rpm, "rpm_ok": max_rpm is None or rpm <= float(max_rpm),
           "available_torque_nm": None, "available_power_kw": None,
           "torque_utilization": None, "power_utilization": None, "basis": None}
    if cap is None:
        out.update(ok=None, basis="no capacity data for this rating")
        return out
    out.update(available_torque_nm=cap["torque_nm"], available_power_kw=cap["power_kw"], basis=cap["basis"])
    if cap["torque_nm"]:
        out["torque_utilization"] = torque_nm / cap["torque_nm"]
    if cap["power_kw"]:
        out["power_utilization"] = power_kw / cap["power_kw"]
    utils = [u for u in (out["torque_utilization"], out["power_utilization"]) if u is not None]
    out["ok"] = out["rpm_ok"] and all(u <= 1.0 for u in utils)
    return out


# ---------------------------------------------------------------------------
# Everything for one cut
# ---------------------------------------------------------------------------

def cutting_forces(cut, coeffs, tir=0.0, runout_model="bound", runout_phase=0.0,
                   spindle=None, rating="continuous", n_theta=720, n_axial=None):
    """Chip geometry, forces, power, torque, runout and (optionally) the spindle check for a cut.

    tir is in mm. The spindle check runs when `spindle` (a machine profile's spindle_options entry)
    is given. C5 checks sustained cuts against the continuous rating (user decision 2026-10-15,
    design §7.3); "s3_15pct_10min" and "momentary" are there for short cuts and reporting.
    """
    D, z, ap, ae, fz = cut.D, cut.z, cut.ap, cut.ae, cut.fz
    phi_e = engagement_angle(ae, D)
    phi_st, phi_ex = engagement_arc(ae, D, cut.climb)
    h_max = max_chip_thickness(fz, ae, D)
    h_m = mean_chip_thickness(fz, ae, D)
    z_c = teeth_in_cut(z, ae, D)

    k_tc = coeffs.kc(h_m)
    k_rc = coeffs.k_r * k_tc
    ft_tooth = k_tc * ap * h_m + coeffs.k_te * ap
    fr_tooth = k_rc * ap * h_m + coeffs.k_re * ap
    ft_total = z_c * ft_tooth
    vc_m_s = cut.vc_m_min / 60.0
    power_w = ft_total * vc_m_s
    torque_nm = ft_total * D / 2000.0

    lateral = lateral_force(cut, k_tc, k_rc, coeffs.k_te, coeffs.k_re, n_theta, n_axial)

    ro = runout_chips(fz, z, tir, runout_model, runout_phase)
    sin_e = math.sin(phi_e) if ae < D / 2.0 else 1.0

    def peak_tooth_force(h_feed):
        # Whole ap at the chip's maximum: an upper bound, since the helix spreads the edge.
        h = h_feed * sin_e
        return (coeffs.kc(h) * h + coeffs.k_te) * ap if h > 0 else coeffs.k_te * ap

    h_max_worst = ro["h_worst"] * sin_e
    runout = {
        "model": runout_model, "tir_mm": tir, "flute_chips_mm": ro["flute_chips"],
        "worst_flute": ro["worst_flute"], "h_worst_mm": ro["h_worst"], "h_max_worst_mm": h_max_worst,
        "kc_worst_n_mm2": coeffs.kc(h_max_worst) if h_max_worst > 0 else None,
        "F_t_peak_worst_n": peak_tooth_force(ro["h_worst"]),
        "F_t_peak_nominal_n": peak_tooth_force(fz),
        "rubbing_flutes": ro["rubbing_flutes"],
        "fz_below_tir": fz < tir,
    }

    spindle_result = None
    if spindle is not None:
        spindle_result = spindle_check(torque_nm, power_w / 1000.0, cut.rpm, spindle, rating)

    src = dict(coeffs.kienzle.source)
    provenance = [
        f"φe = arccos(1 − 2·ae/D) = {math.degrees(phi_e):.1f}°; h_m = fz·(ae/D)/(φe/2) = {h_m:.5f} mm",
        f"kc = {coeffs.kienzle.kc1_1:g}·h_m^−{coeffs.kienzle.mc:g}·K_γ·K_wear = {k_tc:.0f} N/mm²"
        + (f" ({src.get('source_id')} {src.get('code')}, {src.get('hardness')})" if src else ""),
        f"F_t,total = z_c·(kc·ap·h_m + K_te·ap) = {z_c:.3f}·{ft_tooth:.2f} N = {ft_total:.2f} N",
        f"P = F_t,total·v_c = {power_w:.1f} W; T = F_t,total·D/2 = {torque_nm:.4f} N·m",
        f"worst flute (runout {runout_model}, TIR {tir:.4f} mm): h = {ro['h_worst']:.5f} mm",
    ]
    return {
        "inputs": {"D_mm": D, "z": z, "ap_mm": ap, "ae_mm": ae, "fz_mm": fz, "rpm": cut.rpm,
                   "helix_deg": cut.helix_deg, "climb": cut.climb},
        "engagement": {"phi_e_deg": math.degrees(phi_e), "phi_st_deg": math.degrees(phi_st),
                       "phi_ex_deg": math.degrees(phi_ex), "h_max_mm": h_max, "h_m_mm": h_m,
                       "teeth_in_cut": z_c,
                       "teeth_in_cut_helix": teeth_in_cut_helix(z, ae, D, ap, cut.helix_deg)},
        "kc_n_mm2": k_tc,
        "per_tooth": {"F_t_n": ft_tooth, "F_r_n": fr_tooth},
        "total": {"F_t_n": ft_total, "power_w": power_w, "torque_nm": torque_nm,
                  "vc_m_min": cut.vc_m_min, "vf_mm_min": cut.vf_mm_min,
                  "mrr_cm3_min": ap * ae * cut.vf_mm_min / 1000.0},
        "lateral": lateral,
        "runout": runout,
        "spindle": spindle_result,
        "provenance": provenance,
    }
