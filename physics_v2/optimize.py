"""Constraints C1–C10 and the cut optimizer for square end mills.

Design: docs/PHYSICS_MODEL_DESIGN.md §3.4–3.6 (step 3 of §6). Pure functions and frozen inputs; no
pipeline state. Forces come from `physics_v2.forces` (step 2).

Units: the public API takes the pipeline's inches (tool geometry, ap, ae, fz, TIR) and reports inches
and SI side by side. Forces are computed in mm and N, stress in MPa, deflection in inches with the
v1 profile integral.

What is decided, and where it comes from
----------------------------------------
* Speed is never a free variable (user, 2026-10-15). v_c comes from C7, Taylor tool life at the alloy's
  real hardness and the engagement, capped by the spindle's max rpm; only then is MRR maximized over
  fz, ap and ae.
* Objective by operation (design §3.6): roughing and adaptive maximize MRR with a Z-level credit;
  slotting fixes ae = D and C8 caps ap; finishing fixes ap and ae and maximizes the feed.
* Z-level credit (design §7.2): with the operation's real depth, ap is one of depth/N (even levels) and
  an optional per-level overhead enters the score; without it, the 10 % rule approved 2026-10-13
  (v1 `DEPTH_TRADE_MRR`): the deepest cut whose score is within 10 % of the best.
* Robust optimum: aggressiveness sets the margins (design §3.6): λ in C1, a scale on the C3/C4 limits,
  the tool-life target in C7, and a margin on the uncertain upper limits C2 and C5. fz then sits at the
  highest value that keeps every margin.
* User decisions 2026-10-16:
  - C1 holds on every flute (the thinnest flute's chip ≥ λ·r_β).
  - Runout is the eccentric model (TIR = 2e) at its worst phase; the bound model (one flute high by the
    full TIR) is only reported as a warning.
  - C3/C4 are provisional limits: per diameter band, the median deflection/D and σ1 of the vendor side,
    rough and HEM rows on their catalog geometry (tools/v2_provisional_limits.py →
    data/model_v2/provisional_limits.json). Finishing keeps v1's tolerance limit for C3.
  - C11 caps the feed at the machine's max cutting feed and, for adaptive, an effective adaptive feed
    (200 IPM, empirical, user-settable). C12 requires ae ≥ k·TIR, k = 2 (see K_TIR).
  - The score is MRR with the feed capped, i.e. 1/(machining time per volume); every result reports
    the toolpath length per in³, 1/(ap·ae). 0.02·D is only a reported sanity check on ae.
* 17-4 PH is P5.0.Z.AN (1800 / 0.21 at 200 HB) scaled by its real hardness (user, 2026-10-15;
  docs/research/material_mapping_v2.md).
* C5 uses the spindle's continuous rating (user, 2026-10-15).

Placeholders (calibration, design §6 step 4)
-------------------------------------------
Every parameter only calibration can set is an explicit argument whose default is labelled in
`PLACEHOLDERS` and echoed in each result. None is fitted here: K_r, the tool factor (~0.79 against
Sandvik's ToolGuide), the kc and v_c hardness exponents, the Taylor anchor, exponent and engagement
exponent, and the h_tooth fit (c·D^n). The aggressiveness → margin mapping is a placeholder too.

Mechanics
---------
Runout and forces: see `Engagement`. Each flute carries its own runout chip, h = m·fz·sin φ + Δr (the
offset is radial and is not scaled by sin φ), and its own radial depth ae − (r_max − r_k); each flute's
kc is taken at its own mean chip. The lateral force is integrated along the helical edge at every
rotation sample (Altintas ch. 2, as `forces.lateral_force`): its first moment about the tip gives the
load centroid a = (Σz·f)·F̂/|F| (the helix moves it up and down the flute as the tool turns), and
Σ dF_t·D/2 the torque. C3 and C4 take the largest deflection and stress over the revolution, not the
values at the peak force: with one helical load band travelling up the flute, the force barely changes
while its lever arm does.

Deflection (design §3.4): the v1 profile integral (`BeamDeflectionEngine`, same segments, same fluted
and solid inertia) generalized from a tip load to a load at a. By virtual work the deflection at x = b
from a lateral force F at x = a, both measured from the tip, is

    δ(b) = F/E · ∫_{max(a,b)}^{L} (x − a)(x − b) / I(x) dx

which is v1's F/E·∫x²/I dx when a = b = 0. C3 checks the tip (b = 0), the largest error along the cut.
E is 570 GPa (CERATIZIT, 10 % Co submicron); v1 uses 90·10⁶ psi (620 GPa).

Stress (design §3.4): σ = M·c/I = 32·M/(π·d³) with M = F·(x − a) at the far end of every segment:
the flute root at the top of the flutes (core circle only, d = core ratio·D from the research, so
conservative against the real fluted section), every diameter step, and the holder face. Torsion τ = 16·T/(π·d³); carbide is brittle, so C4 checks the largest
principal stress σ1 = σ/2 + √((σ/2)² + τ²) (Rankine). Stress concentration at the steps is not
modelled; the stress fraction covers it.
"""
import json
import math
import os
from dataclasses import dataclass, replace
from typing import Optional

import machine_profiles
from gwizard_physics import DEPTH_TRADE_MRR, BeamDeflectionEngine, CuttingMechanics, reach_sfm_factor
from physics_v2 import forces
from toolwiz_common.tool_profile import ToolProfile

MM_PER_IN = forces.MM_PER_IN
N_PER_LBF = 4.4482216152605
MPA_PER_PSI = 0.0068947572932
FT_PER_M = 1.0 / 0.3048

OPERATIONS = ("rough", "adaptive", "slot", "finish")
C1_FLUTES = ("worst", "thinnest")

# Radial engagement searched for roughing/adaptive: from C12's k·TIR up to AE_MAX·D.
AE_MAX = 0.9
# C12: ae ≥ k·TIR. With the eccentric model the flutes' reach differs by up to TIR, so the lowest flute
# engages ae − TIR. k = 2 keeps that at least ae/2: its engagement angle is then ≥ ~0.7× the highest
# flute's (φe ∝ √ae for light cuts), so every flute stays in the multi-flute regime the chip and force
# model assume. At k = 1 the lowest flute's arc shrinks to nothing and the cut becomes one-flute.
K_TIR = 2.0
# Reported only: the lightest side-milling engagement any vendor publishes (OSG EXOCARB WXL 3604, 0.02·D).
AE_SANITY = 0.02
# C11, empirical: the feed an adaptive toolpath sustains on the user's machine (short arcs, direction
# changes, look-ahead), user-settable. Not the control's programmed maximum.
EFFECTIVE_ADAPTIVE_FEED_IPM = 200.0
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIMITS_PATH = os.path.join(ROOT, "data", "model_v2", "provisional_limits.json")
V1_OPERATION_NAME = {"rough": "Roughing", "adaptive": "Adaptive Roughing", "slot": "Slotting",
                     "finish": "Finishing"}

# ---------------------------------------------------------------------------
# Sources
# ---------------------------------------------------------------------------

SRC = {
    "C1": "Minimum chip thickness h_min = λ·r_β: λ 0.2–0.4 for steel and 304 stainless (Wojciechowski, "
          "Materials 15:59 (2022) Table 1; Li et al., Mech. Sci. 12:487 (2021)); r_β of micro end mills "
          "0.4–3.5 µm (Liang et al. 2018; Jäckel et al. 2024). docs/research/carbide_and_edge_radius.md §3–4",
    "C2": "Tooth/edge strength h_tooth = c·D^n (design §3.5). PLACEHOLDER until calibration (§6 step 4) "
          "fits c and n to several vendors' chip loads",
    "C3": "PROVISIONAL (user, 2026-10-16): median tip deflection / D of the vendor side, rough and HEM rows "
          "in this diameter band, each on its catalog geometry and material (data/model_v2/"
          "provisional_limits.json, tools/v2_provisional_limits.py); finishing keeps v1's tolerance "
          "limit (CuttingMechanics.calc_deflection_limit). Step 4 refines it",
    "C4": "PROVISIONAL (user, 2026-10-16): median flute-root/step σ1 of the vendor side, rough and HEM rows "
          "in this diameter band (data/model_v2/provisional_limits.json). Reference: carbide fatigue "
          "0.35–0.4 × TRS 3.8 GPa = 1.3–1.5 GPa (docs/research/carbide_and_edge_radius.md §1–2)",
    "C5": "Spindle capacity at rpm, continuous rating (user decision 2026-10-15): "
          "machines/*.json via machine_profiles.capacity",
    "C6": "Geometry: ap ≤ LCF (and ≤ the operation's depth), ae ≤ D; ae and ap fixed for finishing",
    "C7": "Taylor tool life v_c·T^n = C at the real hardness and engagement (design §3.5 C7; decision "
          "§7.1). Hardness and engagement shape from Sandvik CoroPlus ToolGuide probes (v_c ∝ HB^−1.0; "
          "1.8× at ~10 % engagement), docs/research/sandvik_toolguide_probes.md; rpm ≤ machine max",
    "C8": "Empirical (design §3.5 C8): micro slot depth, Harvey miniature guide (step down 5–15 % of D) "
          "and SF_73000 slot ADOC (0.14·D for 0.015–0.047\", 0.35·D for 0.062\" and up)",
    "C9": "Empirical (design §3.5 C9): OSG overhang speed reduction on the equivalent stickout, "
          "v1 reach_sfm_factor (1.0 to 4·D, −10 %/D, ≥ 40 %)",
    "C11": "Feed: v_f ≤ the machine's max cutting feed (machine profile) and, for adaptive, an effective "
           "adaptive feed (empirical, user-settable, default 200 IPM)",
    "C12": "Every flute reaches the stock: ae ≥ k·TIR, k = 2 (lowest flute engages ae − TIR ≥ ae/2)",
    "C10": "Empirical (design §3.5 C10): cut under the work-hardened layer, h ≥ h_wh. No sourced "
           "per-alloy value yet; inactive unless h_wh is given (17-4 PH is not in v1's "
           "work-hardening list)",
}

# Every default that only calibration can set, with the basis for the placeholder value.
PLACEHOLDERS = {
    "k_r": "0.4: middle of the design's 0.3–0.6 (§3.2); fitted in calibration",
    "tool_factor": "1.0: kc not reduced; Sandvik's ToolGuide implies ~0.79 for its Dura (probe doc), "
                   "calibration decides",
    "kc_hardness_exp": "0.41: Sandvik ToolGuide 17-4 probe (P5 table rows give 0.49)",
    "vc_ref_sfm": "262 SFM: Sandvik CoroMill Dura sheet, P5.0.Z.AN 200 HB, full slot (Taylor anchor at "
                  "default aggressiveness, decision §7.1)",
    "vc_hardness_exp": "1.0: Sandvik ToolGuide 17-4 probe, v_c ∝ HB^−0.99…−1.03",
    "vc_engagement_exp": "0.4: v_c ∝ (φe/π)^−k reproduces Sandvik Dura's 1.88× at 0.1·D "
                         "(262 → 492 SFM); it overstates 0.5·D (1.32× vs 1.13×). Shape to fit",
    "vc_engagement_ae_min": "0.1: Sandvik Dura's lightest published engagement; no extrapolated speed "
                            "credit below it",
    "taylor_n": "0.25: carbide range 0.2–0.5 (Kalpakjian); only used to trade life for speed",
    "h_tooth_c": "0.008 (h_tooth = 0.8 % of D): order of magnitude of 17-4 vendor chips at 1/16–1/4\" "
                 "plus 0.0002\" TIR; not a fit",
    "h_tooth_n": "1.0: geometric similarity of the tooth and edge with D",
    "edge_radius_mm": "0.002: micro end mills 1–4 µm (Ducobu 2017), no data vs diameter",
    "aggressiveness_map": "C3/C4 provisional limits ×(0.7 + 0.6·a) (the vendor median at a = 0.5), tool "
                          "life ×4^(0.5 − a), C2/C5 margin 0.2·(1 − a), λ from the top to the bottom of "
                          "its range",
    "effective_feed_ipm": "200 IPM: empirical effective adaptive feed (user, 2026-10-16), user-settable",
    "k_tir": "2: C12 ae ≥ k·TIR, see K_TIR",
}

# Core (web) diameter / D by flute count: patents and Mitsubishi ("usually about 60 %"),
# docs/research/carbide_and_edge_radius.md §5. Design targets, none measured for micro tools.
CORE_RATIO_BY_FLUTES = {1: 0.55, 2: 0.60, 3: 0.60, 4: 0.60, 5: 0.62, 6: 0.64}

# Harvey SF_73000 slotting ADOC for its miniature columns (tests/benchmarks/v2/harvey.json).
SLOT_DEPTH_RATIO_MICRO = ((0.0625, 0.14), (0.125, 0.35))   # (D below, k_slot)


# ---------------------------------------------------------------------------
# Inputs
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Material:
    """Work material for v2: Kienzle at the source row's hardness, scaled to the alloy's real HB."""
    name: str
    kienzle: forces.Kienzle
    hb_ref: float
    hb: float
    vc_ref_sfm: float = 262.0           # PLACEHOLDER (Taylor anchor at hb_ref, full slot)
    kc_hardness_exp: float = 0.41       # PLACEHOLDER
    vc_hardness_exp: float = 1.0        # PLACEHOLDER
    vc_engagement_exp: float = 0.4      # PLACEHOLDER
    vc_engagement_ae_min: float = 0.1   # no speed credit below the lightest sourced engagement (ae/D)
    taylor_n: float = 0.25              # PLACEHOLDER
    k_r: float = 0.4                    # PLACEHOLDER
    k_te: float = 0.0                   # edge force N/mm (calibration; 0 reproduces Sandvik)
    k_re: float = 0.0
    tool_factor: float = 1.0            # PLACEHOLDER
    h_tooth_c: float = 0.008            # PLACEHOLDER: h_tooth = c·D^n, D and h in mm
    h_tooth_n: float = 1.0              # PLACEHOLDER
    lambda_range: tuple = (0.2, 0.4)    # sourced (C1)
    h_wh_mm: Optional[float] = None     # C10 off unless given

    def kc_scale(self):
        """kc1.1 at the real hardness over kc1.1 at the source row: (HB/HB_ref)^p · tool factor."""
        return (self.hb / self.hb_ref) ** self.kc_hardness_exp * self.tool_factor

    def kienzle_at_hb(self):
        k = self.kienzle
        src = k.source + (("hardness_scaling", f"×(HB {self.hb:g}/{self.hb_ref:g})^{self.kc_hardness_exp:g}"),
                          ("tool_factor", self.tool_factor))
        return forces.Kienzle(k.kc1_1 * self.kc_scale(), k.mc, k.rake_ref_deg, src)

    def coefficients(self, rake_deg=0.0):
        return forces.ForceCoefficients(self.kienzle_at_hb(), self.k_r, self.k_te, self.k_re, rake_deg)

    def h_tooth_mm(self, D_mm):
        return self.h_tooth_c * D_mm ** self.h_tooth_n

    def lam(self, aggressiveness):
        lo, hi = self.lambda_range
        return hi - aggressiveness * (hi - lo)


def material_17_4(hb=356.0, **overrides):
    """17-4 PH (any condition) as P5.0.Z.AN 1800/0.21 at 200 HB, scaled to hb (user decision 2026-10-15).

    H1025 is 356 HB (ToolWiz alloy table, '17-4 PH', 'H 1025').
    """
    kw = dict(name=f"17-4 PH, {hb:g} HB (P5.0.Z.AN scaled)", kienzle=forces.load_kienzle("P5.0.Z.AN"),
              hb_ref=200.0, hb=float(hb))
    kw.update(overrides)
    return Material(**kw)


@dataclass(frozen=True)
class Tool:
    """A square end mill: its v1 profile (inches) plus the v2 properties."""
    profile: ToolProfile
    D: float
    z: int
    lcf: float
    helix_deg: float = 35.0
    rake_deg: float = 0.0
    edge_radius_mm: float = 0.002       # PLACEHOLDER (data gap)
    core_ratio: Optional[float] = None  # None: CORE_RATIO_BY_FLUTES
    E_mpa: float = 570000.0             # CERATIZIT p.22, 10 % Co submicron (CTS20D / CT-GS20Y)
    trs_mpa: float = 3800.0             # CERATIZIT CT-GS20Y; Hyperion K10F 3700
    fatigue_fraction: float = 0.375     # 0.35–0.4 × TRS, fully reversed bending
    climb: bool = True
    label: str = ""

    @classmethod
    def build(cls, D, z, lcf, stickout, shank=None, neck_diameter=None, neck_length=None, **kw):
        prof = ToolProfile.from_legacy(D, z, lcf, shank, stickout, has_relieved_neck=bool(neck_length),
                                       neck_diameter=neck_diameter, neck_length=neck_length)
        return cls(prof, float(D), int(z), float(lcf), **kw)

    @classmethod
    def from_fusion(cls, tool_dict, **kw):
        prof = ToolProfile.from_fusion(tool_dict)
        g = prof.geometry
        return cls(prof, g.diameter, int(g.flutes), g.flute_length, **kw)

    @property
    def segments(self):
        return self.profile.segments

    @property
    def stickout(self):
        return self.profile.stickout

    @property
    def D_mm(self):
        return self.D * MM_PER_IN

    @property
    def E_psi(self):
        return self.E_mpa / MPA_PER_PSI

    def core(self):
        return self.core_ratio if self.core_ratio else CORE_RATIO_BY_FLUTES.get(self.z, 0.64)


@dataclass(frozen=True)
class Machine:
    spindle: dict
    max_rpm: float
    rating: str = "continuous"
    tir_in: float = 0.0002              # design §7.4 default for micro tools
    runout_model: str = "eccentric"     # physical default (user, 2026-10-16); "bound" is reported only
    label: str = ""
    max_feed_ipm: Optional[float] = None


def speedio_16k(tir_in=0.0002, rating="continuous", runout_model="eccentric"):
    """Brother Speedio S500X2 with the 16k non-dual-contact spindle (machines/speedio_s500x2.json)."""
    with open(os.path.join(machine_profiles.BUILTIN_DIR, "speedio_s500x2.json"), encoding="utf-8") as fh:
        prof = json.load(fh)
    sp = prof["spindle_options"]["optional_16k"]
    feed = prof.get("max_cutting_feed_mm_min")
    return Machine(sp, float(sp["max_rpm"]), rating, float(tir_in), runout_model, "Speedio S500X2 16k",
                   feed / MM_PER_IN if feed else None)


@dataclass(frozen=True)
class Margins:
    """Safety margins from aggressiveness a ∈ [0, 1] (design §3.6). The mapping is a placeholder."""
    aggressiveness: float = 0.5
    limit_scale: float = None           # on the provisional C3/C4 limits
    life_ratio: float = None            # T / T_ref in C7
    limit_margin: float = None          # on C2 and C5

    def __post_init__(self):
        a = self.aggressiveness
        if not 0.0 <= a <= 1.0:
            raise ValueError("aggressiveness must be in [0, 1]")
        if self.limit_scale is None:
            object.__setattr__(self, "limit_scale", 0.7 + 0.6 * a)
        if self.life_ratio is None:
            object.__setattr__(self, "life_ratio", 4.0 ** (0.5 - a))
        if self.limit_margin is None:
            object.__setattr__(self, "limit_margin", 0.2 * (1.0 - a))


# ---------------------------------------------------------------------------
# Constraint records
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Check:
    """One constraint at one cut. kind 'max': value ≤ limit; 'min': value ≥ limit; 'info': a derating
    (C9) reported against its onset, never violated."""
    id: str
    name: str
    kind: str
    value: float
    limit: Optional[float]
    units: str
    source: str
    applies: bool = True
    detail: str = ""

    @property
    def margin(self):
        """Fraction of the limit still unused (negative when violated); None when not applicable."""
        if not self.applies or self.limit is None:
            return None
        if self.kind in ("max", "info"):
            return (self.limit - self.value) / self.limit if self.limit else -math.inf
        if self.limit <= 0:
            return math.inf
        return (self.value - self.limit) / self.limit

    @property
    def ok(self):
        m = self.margin
        return True if (m is None or self.kind == "info") else m >= -1e-9

    def to_dict(self):
        m = self.margin
        return {"id": self.id, "name": self.name, "kind": self.kind, "value": self.value,
                "limit": self.limit, "units": self.units, "margin": m, "ok": self.ok,
                "applies": self.applies, "detail": self.detail, "source": self.source}


# ---------------------------------------------------------------------------
# Constraints, one pure function each
# ---------------------------------------------------------------------------

def c1_min_chip(h_mm, edge_radius_mm, lam, flute="worst"):
    """C1: maximum chip of the checked flute ≥ λ·r_β (no ploughing). h includes runout.

    flute names which flute h belongs to: "worst" (largest chip, the design's worst flute, §3.3) or
    "thinnest" (every flute must form a chip).
    """
    lim = lam * edge_radius_mm
    return Check("C1", "minimum chip (no ploughing)", "min", h_mm, lim, "mm", SRC["C1"],
                 detail=f"h_min = λ·r_β = {lam:.3g}·{edge_radius_mm * 1000:.2g} µm = {lim * 1000:.3g} µm; "
                        f"{flute} flute h_max = {h_mm * 1000:.3g} µm")


def c2_tooth_strength(h_worst_mm, h_tooth_mm, margin=0.0):
    """C2: the worst flute's maximum chip ≤ (1 − margin)·h_tooth."""
    lim = h_tooth_mm * (1.0 - margin)
    return Check("C2", "tooth/edge strength", "max", h_worst_mm, lim, "mm", SRC["C2"],
                 detail=f"h_tooth = {h_tooth_mm * 1000:.3g} µm, margin {margin:.0%}; "
                        f"worst flute h_max = {h_worst_mm * 1000:.3g} µm")


def c3_deflection(delta_in, allow_in, load_at_in=None):
    """C3: the largest tip deflection over a revolution, each load at its centroid, ≤ δ_allow."""
    where = f" (load at {load_at_in:.4f}\" from the tip)" if load_at_in is not None else ""
    return Check("C3", "tool deflection", "max", delta_in, allow_in, "in", SRC["C3"],
                 detail=f"δ_tip = {delta_in:.6f}\"{where}; δ_allow = {allow_in:.6f}\"")


def c4_stress(sigma1_mpa, limit_mpa, section="", basis=""):
    """C4: largest principal stress at the critical section (flute root, steps, holder) ≤ limit."""
    return Check("C4", "bending stress", "max", sigma1_mpa, limit_mpa, "MPa", SRC["C4"],
                 detail=f"σ1 = {sigma1_mpa:.0f} MPa at {section or 'critical section'}; limit {limit_mpa:.0f} MPa"
                        + (f" ({basis})" if basis else ""))


def c5_spindle(torque_nm, power_kw, rpm, spindle, rating="continuous", margin=0.0):
    """C5: torque and power within the spindle's rating at rpm; value is the larger utilization."""
    s = forces.spindle_check(torque_nm, power_kw, rpm, spindle, rating)
    utils = [u for u in (s["torque_utilization"], s["power_utilization"]) if u is not None]
    if not utils:
        return Check("C5", "spindle torque/power", "max", 0.0, None, "fraction", SRC["C5"], applies=False,
                     detail=s["basis"] or "no spindle data")
    return Check("C5", "spindle torque/power", "max", max(utils), 1.0 - margin, "fraction", SRC["C5"],
                 detail=f"{rating}: T = {torque_nm:.4f} of {s['available_torque_nm']:.2f} N·m, "
                        f"P = {power_kw * 1000:.1f} W of {s['available_power_kw'] * 1000:.0f} W at {rpm:.0f} rpm")


def c6_geometry(ap_in, ae_in, D_in, lcf_in, depth_in=None, slot=False):
    """C6: ap ≤ min(LCF, depth) and ae ≤ D; value is the larger of ap/ap_max and ae/D (ap only for a slot,
    where ae = D by definition)."""
    ap_max = min(lcf_in, depth_in) if depth_in else lcf_in
    ratio = ap_in / ap_max if slot and ae_in <= D_in * (1 + 1e-9) else max(ap_in / ap_max, ae_in / D_in)
    return Check("C6", "geometry", "max", ratio, 1.0, "fraction", SRC["C6"],
                 detail=f"ap {ap_in:.4f}\" of {ap_max:.4f}\" ({'depth' if depth_in and depth_in < lcf_in else 'LCF'}); "
                        f"ae {ae_in:.4f}\" of D {D_in:.4f}\"")


def taylor_speed_m_min(material, phi_e, life_ratio=1.0):
    """C7 speed: v_ref·(HB_ref/HB)^q·(φe/π)^(−k)·(T/T_ref)^(−n), m/min.

    φe is held at or above the engagement of ae = vc_engagement_ae_min·D (0.1·D, the lightest
    engagement in Sandvik's Dura sheet): the placeholder exponent gives no speed credit beyond its data.
    """
    v = material.vc_ref_sfm / FT_PER_M
    v *= (material.hb_ref / material.hb) ** material.vc_hardness_exp
    floor = forces.engagement_angle(material.vc_engagement_ae_min, 1.0)
    v *= (max(phi_e, floor) / math.pi) ** (-material.vc_engagement_exp)
    v *= life_ratio ** (-material.taylor_n)
    return v


def c7_speed(material, phi_e, D_mm, max_rpm, life_ratio=1.0, reach_factor=1.0):
    """C7: v_c from tool life (and the C9 factor); rpm = v_c/(π·D), capped at the machine's max.

    Returns (rpm_used, v_c_m_min_used, Check). The check's value is the rpm used, so it binds (margin 0)
    when the spindle's max rpm caps the tool-life speed.
    """
    vc_life = taylor_speed_m_min(material, phi_e, life_ratio) * reach_factor
    rpm_want = 1000.0 * vc_life / (math.pi * D_mm)
    rpm = min(rpm_want, max_rpm)
    vc = math.pi * D_mm * rpm / 1000.0
    chk = Check("C7", "speed (tool life, rpm cap)", "max", rpm, max_rpm, "rpm", SRC["C7"],
                detail=f"v_c = {material.vc_ref_sfm:g} SFM·({material.hb_ref:g}/{material.hb:g})^"
                       f"{material.vc_hardness_exp:g}·(φe/π = {phi_e / math.pi:.3f})^−{material.vc_engagement_exp:g}"
                       f"·(T/T_ref = {life_ratio:.2f})^−{material.taylor_n:g}·C9 {reach_factor:.2f} = "
                       f"{vc_life * FT_PER_M:.0f} SFM → {rpm_want:.0f} rpm; used {rpm:.0f} rpm "
                       f"({vc * FT_PER_M:.0f} SFM)")
    return rpm, vc, chk


def slot_depth_ratio(D_in):
    for below, k in SLOT_DEPTH_RATIO_MICRO:
        if D_in < below - 1e-9:
            return k
    return None


def c8_slot_depth(ap_in, D_in, operation, k_slot=None):
    """C8: full-slot depth of a micro tool (D < 1/8") ≤ k_slot·D. Not applied to other cuts."""
    k = k_slot if k_slot is not None else slot_depth_ratio(D_in)
    applies = operation == "slot" and k is not None
    lim = k * D_in if applies else None
    return Check("C8", "micro slot depth (chip packing)", "max", ap_in, lim, "in", SRC["C8"], applies=applies,
                 detail=(f"k_slot = {k:g} → {lim:.4f}\"" if applies else "not a micro full slot"))


def c9_stickout(eq_stickout_in, D_in):
    """C9: speed factor from the equivalent stickout (OSG). value L_eq/D vs the 4·D onset; never violated."""
    f = reach_sfm_factor(eq_stickout_in, D_in)
    return f, Check("C9", "stickout speed reduction (chatter)", "info", eq_stickout_in / D_in, 4.0, "L/D",
                    SRC["C9"], detail=f"equivalent stickout {eq_stickout_in / D_in:.2f}·D → speed ×{f:.2f}")


def c10_work_hardening(h_mm, h_wh_mm=None):
    """C10: the checked flute's chip ≥ h_wh (cut under the hardened layer). Inactive without h_wh."""
    applies = h_wh_mm is not None
    return Check("C10", "work-hardened layer", "min", h_mm, h_wh_mm, "mm", SRC["C10"], applies=applies,
                 detail=(f"h_wh = {h_wh_mm * 1000:.3g} µm" if applies else "no h_wh for this alloy"))


def c11_feed(vf_ipm, machine_max_ipm=None, effective_ipm=None):
    """C11: feed ≤ the machine's max cutting feed and, when given, the effective adaptive feed."""
    caps = [(c, n) for c, n in ((machine_max_ipm, "machine max"), (effective_ipm, "effective adaptive"))
            if c]
    if not caps:
        return Check("C11", "feed rate", "max", vf_ipm, None, "IPM", SRC["C11"], applies=False,
                     detail="no feed limit")
    lim, name = min(caps)
    return Check("C11", "feed rate", "max", vf_ipm, lim, "IPM", SRC["C11"],
                 detail=f"v_f = {vf_ipm:.1f} IPM; limit {lim:.0f} IPM ({name})")


def c12_radial_reach(ae_in, tir_in, k=K_TIR):
    """C12: ae ≥ k·TIR so every flute reaches the stock (the lowest engages ae − TIR)."""
    lim = k * tir_in
    return Check("C12", "every flute reaches the stock", "min", ae_in, lim, "in", SRC["C12"],
                 detail=f"ae {ae_in:.5f}\" vs k·TIR = {k:g}·{tir_in:.5f}\" = {lim:.5f}\"")


def runout_offsets_worst(tir_mm, z, model="eccentric"):
    """Flute offsets at the phase that thins one flute most (largest r_(k−1) − r_k), as forces.runout_offsets.

    For the eccentric model (r_k = e·cos(phase − 2πk/z), TIR = 2e) that deficit is TIR·sin(π/z) on a
    4-flute tool (0.71·TIR). The bound model is phase-free.
    """
    if model != "eccentric" or tir_mm <= 0:
        return forces.runout_offsets(tir_mm, z, model)
    best, best_d = None, -1.0
    for i in range(64):
        offs = forces.runout_offsets(tir_mm, z, "eccentric", 2.0 * math.pi / z * i / 64.0)
        d = max(offs[(k - 1) % z] - offs[k] for k in range(z))
        if d > best_d + 1e-15:
            best, best_d = offs, d
    return best


def provisional_limits(D_in, path=None):
    """The provisional C3/C4 band for a diameter: {"band", "deflection_over_D", "sigma1_mpa", "n", ...}."""
    data = _limits(path or LIMITS_PATH)
    for band in data["bands"]:
        if band["d_min"] <= D_in < band["d_max"]:
            return band
    return data["bands"][-1] if D_in >= data["bands"][-1]["d_min"] else data["bands"][0]


_LIMIT_CACHE = {}


def _limits(path):
    if path not in _LIMIT_CACHE:
        with open(path, encoding="utf-8") as fh:
            _LIMIT_CACHE[path] = json.load(fh)
    return _LIMIT_CACHE[path]


# ---------------------------------------------------------------------------
# Beam: deflection and stress on the v1 profile
# ---------------------------------------------------------------------------

_GX = BeamDeflectionEngine._GAUSS_X
_GW = BeamDeflectionEngine._GAUSS_W


def _inertia(d, fluted, flutes, helix_deg):
    """Exactly v1's section inertia (BeamDeflectionEngine._segment_integral)."""
    d = max(0.001, d)
    if fluted:
        return BeamDeflectionEngine.fluted_core_inertia(d, flutes, helix_deg)
    return BeamDeflectionEngine.solid_circular_inertia(d)


def compliance_integral(segments, a, b=0.0, flutes=4, helix_deg=30.0):
    """∫_{max(a,b)}^{L} (x − a)(x − b)/I(x) dx over the profile (inches, 1/in).

    a = b = 0 is v1's ∫x²/I dx (BeamDeflectionEngine.deflection_from_segments).
    """
    lo = max(a, b)
    total = 0.0
    for sg in segments:
        x0, x1 = max(float(sg.start), lo), float(sg.end)
        if x1 <= x0:
            continue
        d0, d1 = float(sg.d0), float(sg.d1)
        s0, s1 = float(sg.start), float(sg.end)

        if abs(d1 - d0) <= 1e-12 * max(d0, d1, 1.0):
            i_c = _inertia(d0, sg.fluted, flutes, helix_deg)
            if i_c <= 0:
                continue

            def prim(x):
                return x ** 3 / 3.0 - (a + b) * x ** 2 / 2.0 + a * b * x
            total += (prim(x1) - prim(x0)) / i_c
            continue
        panels = BeamDeflectionEngine._PANELS_TAPER
        for k in range(panels):
            pa = x0 + (x1 - x0) * k / panels
            pb = x0 + (x1 - x0) * (k + 1) / panels
            mid, half = 0.5 * (pa + pb), 0.5 * (pb - pa)
            for xi, wi in zip(_GX, _GW):
                x = mid + half * xi
                d_x = d0 + (d1 - d0) * (x - s0) / (s1 - s0)
                i_x = _inertia(d_x, sg.fluted, flutes, helix_deg)
                if i_x > 0:
                    total += wi * half * (x - a) * (x - b) / i_x
    return total


def deflection_in(force_lbf, segments, load_at_in, at_in=0.0, flutes=4, helix_deg=30.0, E_psi=90e6):
    """Deflection (in) at x = at_in from a lateral force at x = load_at_in (both from the tip)."""
    if force_lbf <= 0 or not segments:
        return 0.0
    return force_lbf / E_psi * compliance_integral(segments, load_at_in, at_in, flutes, helix_deg)


def critical_sections(segments, core_ratio=0.6):
    """(x, d_mm, kind) at the far end of every segment, plus a tapered segment's narrow start.

    Within a constant section the moment grows toward the holder, so each segment's far end is its
    critical point: the flute root at the top of the flutes (core diameter d·core_ratio), every
    diameter step, and the holder face.
    """
    out = []
    last = float(segments[-1].end) if segments else 0.0
    for sg in segments:
        pts = [(float(sg.end), float(sg.d1))]
        if abs(sg.d0 - sg.d1) > 1e-12:
            pts.append((float(sg.start), float(sg.d0)))
        for x, d in pts:
            d_mm = d * MM_PER_IN * (core_ratio if sg.fluted else 1.0)
            kind = "holder face" if x >= last - 1e-12 else ("flute root" if sg.fluted else f"{sg.kind} at step")
            out.append((x, d_mm, kind))
    return out


def section_stress(force_n, load_at_in, torque_nm, x_in, d_mm):
    """σ = 32·M/(π·d³), τ = 16·T/(π·d³), σ1 = σ/2 + √((σ/2)² + τ²) at x (MPa); M = F·(x − a)."""
    m_nmm = force_n * max(x_in - load_at_in, 0.0) * MM_PER_IN
    k = math.pi * d_mm ** 3
    sigma, tau = 32.0 * m_nmm / k, 16.0 * abs(torque_nm) * 1000.0 / k
    return m_nmm, sigma, tau, sigma / 2.0 + math.hypot(sigma / 2.0, tau)


def bending_sections(segments, force_n, load_at_in, torque_nm=0.0, core_ratio=0.6):
    """Stress at every critical section above the load, largest σ1 first (dicts)."""
    out = []
    for x, d_mm, kind in critical_sections(segments, core_ratio):
        if x <= load_at_in + 1e-12:
            continue
        m, sigma, tau, s1 = section_stress(force_n, load_at_in, torque_nm, x, d_mm)
        out.append({"kind": kind, "x_in": x, "d_mm": d_mm, "moment_nmm": m, "sigma_mpa": sigma,
                    "tau_mpa": tau, "sigma1_mpa": s1})
    out.sort(key=lambda s: -s["sigma1_mpa"])
    return out


# ---------------------------------------------------------------------------
# Lateral force with per-flute chips (runout), load centroid and torque
# ---------------------------------------------------------------------------

class Engagement:
    """One (ap, ae) pass with per-flute runout, integrated along the helical cutting edge.

    Runout (design §3.3). Flute k reaches r_k beyond nominal (`forces.runout_offsets`). The outermost
    flute generates the wall, so flute k engages the radial depth ae_k = ae − (r_max − r_k) (not at all
    when ae_k ≤ 0), and its chip at immersion φ is (Kline & DeVor; Bao & Tansel 2000)

        h_k(φ) = max(0, min over m = 1..z of (m·fz·sin φ + r_k − r_(k−m)))

    The radial offset adds to the chip at every angle; it is not scaled by sin φ. (Step 2's
    `cutting_forces` reports the worst flute as (fz + TIR)·sin φe, which is close for wide cuts and
    understates narrow ones: at ae = 0.1·D the worst chip is fz·0.6 + TIR, not (fz + TIR)·0.6.)

    Forces (Altintas ch. 2) per unit axial length: dF_t = K_tc,k·h + K_te, dF_r = K_r·K_tc,k·h + K_re
    where the flute touches (h > 0), with K_tc,k = kc at flute k's own mean chip. A helix of lag
    ψ = 2·tan β/D rad/mm puts the slice at height z at φ = θ_k − ψ·z, so the force of flute k at rotation
    θ is (1/ψ)·∫ f(φ) dφ over the part of its arc inside [θ_k − ψ·ap, θ_k]: cumulative integrals over the
    arc make each rotation sample two interpolations per flute. The first moment of the same integrand
    about the tip gives the load centroid, and dF_t·D/2 the torque.
    """

    def __init__(self, D_mm, z, ap_mm, ae_mm, helix_deg=0.0, climb=True):
        if not 0 < ae_mm <= D_mm or ap_mm <= 0:
            raise ValueError("need 0 < ae ≤ D and ap > 0")
        self.D, self.z, self.ap, self.ae, self.climb = D_mm, int(z), ap_mm, ae_mm, climb
        self.lag = 2.0 * math.tan(math.radians(helix_deg)) / D_mm
        self.R = D_mm / 2.0

    def arcs(self, offsets):
        """Per flute (φ_start, φ_end, max sin φ on the arc), or None when the flute misses the stock."""
        r_max = max(offsets)
        out = []
        for r in offsets:
            ae_k = self.ae - (r_max - r)
            if ae_k <= 1e-12:
                out.append(None)
                continue
            pe = forces.engagement_angle(min(ae_k, self.D), self.D)
            arc = (math.pi - pe, math.pi) if self.climb else (0.0, pe)
            out.append(arc + (math.sin(pe) if pe < math.pi / 2.0 else 1.0,))
        return out

    @staticmethod
    def chip_terms(fz, offsets):
        z = len(offsets)
        return [[(m * fz, offsets[k] - offsets[(k - m) % z]) for m in range(1, z + 1)] for k in range(z)]

    @staticmethod
    def chip(terms, s):
        return max(0.0, min(a * s + c for a, c in terms))

    def max_chips(self, fz, offsets):
        """Each flute's largest chip on its arc (mm); 0 for a flute that only rubs or misses."""
        arcs, terms = self.arcs(offsets), self.chip_terms(fz, offsets)
        return [self.chip(terms[k], arcs[k][2]) if arcs[k] else 0.0 for k in range(self.z)]

    def loads(self, fz, offsets, coeffs, n_theta=144, n_quad=48):
        """Peak and mean lateral force (N), load centroid at the peak (mm), torque (N·m), flute data."""
        z, two_pi = self.z, 2.0 * math.pi
        pitch = two_pi / z
        arcs, terms = self.arcs(offsets), self.chip_terms(fz, offsets)
        flutes, kcs = [], []
        for k in range(z):
            if not arcs[k]:
                kcs.append(None)
                continue
            a0, a1, _ = arcs[k]
            d = (a1 - a0) / n_quad
            phis = [a0 + j * d for j in range(n_quad + 1)]
            hs = [self.chip(terms[k], math.sin(p)) for p in phis]
            h_mean = sum((hs[j] + hs[j + 1]) * 0.5 for j in range(n_quad)) / n_quad
            if h_mean <= 0:
                kcs.append(None)
                continue
            ktc = coeffs.kc(h_mean)
            kcs.append(ktc)
            vals = []
            for p, h in zip(phis, hs):
                if h > 0:
                    ft = ktc * h + coeffs.k_te
                    fr = coeffs.k_r * ktc * h + coeffs.k_re
                else:
                    ft = fr = 0.0
                s, c = math.sin(p), math.cos(p)
                fx, fy = -ft * c - fr * s, ft * s - fr * c
                vals.append((fx, fy, ft, p * fx, p * fy))
            cum = [(0.0, 0.0, 0.0, 0.0, 0.0)]
            for j in range(n_quad):
                prev, v0, v1 = cum[-1], vals[j], vals[j + 1]
                cum.append(tuple(prev[i] + 0.5 * (v0[i] + v1[i]) * d for i in range(5)))
            # Runout flute k sits at geometric flute (−k) mod z: geometric flute j+1 leads flute j,
            # so flute k − 1 cuts just before flute k, as in forces.flute_chip_loads.
            flutes.append((((-k) % z) * pitch, a0, a1, d, vals, cum))

        def at(table, a0, d, phi):
            x = (phi - a0) / d
            i = min(max(int(x), 0), len(table) - 2)
            f = x - i
            t0, t1 = table[i], table[i + 1]
            return tuple(t0[q] + f * (t1[q] - t0[q]) for q in range(5))

        lag, ap, R = self.lag, self.ap, self.R
        span = lag * ap
        sx = sy = st = 0.0
        best = (-1.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        samples = []
        for i in range(n_theta):
            theta = (i + 0.5) * two_pi / n_theta
            fx = fy = mx = my = t = 0.0
            for g, a0, a1, d, vals, cum in flutes:
                top = (theta + g) % two_pi
                if lag == 0:
                    if a0 <= top <= a1:
                        v = at(vals, a0, d, top)
                        fx += ap * v[0]
                        fy += ap * v[1]
                        mx += 0.5 * ap * ap * v[0]
                        my += 0.5 * ap * ap * v[1]
                        t += ap * v[2] * R
                    continue
                j0 = math.floor((top - span - a1) / two_pi)
                j1 = math.ceil((top - a0) / two_pi)
                for j in range(j0, j1 + 1):
                    off = two_pi * j
                    lo, hi = max(top - span, a0 + off), min(top, a1 + off)
                    if hi <= lo:
                        continue
                    c_hi, c_lo = at(cum, a0, d, hi - off), at(cum, a0, d, lo - off)
                    dx, dy, dt = c_hi[0] - c_lo[0], c_hi[1] - c_lo[1], c_hi[2] - c_lo[2]
                    hx, hy = c_hi[3] - c_lo[3], c_hi[4] - c_lo[4]
                    fx += dx / lag
                    fy += dy / lag
                    # z = (top − φ − 2πj)/ψ for the slice at arc angle φ
                    mx += ((top - off) * dx - hx) / (lag * lag)
                    my += ((top - off) * dy - hy) / (lag * lag)
                    t += dt / lag * R
            sx += fx
            sy += fy
            st += t
            mag2 = fx * fx + fy * fy
            cen = min(max((mx * fx + my * fy) / mag2, 0.0), ap) if mag2 > 0 else 0.5 * ap
            samples.append((math.sqrt(mag2), cen, t / 1000.0))
            if mag2 > best[0]:
                best = (mag2, fx, fy, cen, t)
        mag2, fx, fy, cen, t = best
        return {"peak_n": math.sqrt(max(mag2, 0.0)), "peak_feed_n": fx, "peak_normal_n": fy,
                "centroid_mm": cen, "torque_peak_nm": t / 1000.0,
                "mean_feed_n": sx / n_theta, "mean_normal_n": sy / n_theta,
                "mean_n": math.hypot(sx / n_theta, sy / n_theta), "torque_mean_nm": st / n_theta / 1000.0,
                "flute_kc_n_mm2": kcs, "samples": samples}


# ---------------------------------------------------------------------------
# One cut: every constraint
# ---------------------------------------------------------------------------

def deflection_limit(tool, operation, aggressiveness):
    """C3's δ_allow: v1's per-operation limit for this diameter and aggressiveness (inches)."""
    return CuttingMechanics.calc_deflection_limit(tool.D, V1_OPERATION_NAME[operation], aggressiveness, True)


OPTION_DEFAULTS = {"deflection_allow": None, "stress_limit": None, "depth": None, "c1_flute": "thinnest",
                   "effective_feed_ipm": EFFECTIVE_ADAPTIVE_FEED_IPM, "k_tir": K_TIR, "limits_path": None}


class _Context:
    """Everything fixed for one tool, material, machine, operation, margin set and options.

    Options (OPTION_DEFAULTS): deflection_allow (in) and stress_limit (MPa) override the provisional
    C3/C4 limits; depth is the operation's real depth; c1_flute "thinnest" (every flute must form a
    chip, user 2026-10-16) or "worst"; effective_feed_ipm is C11's adaptive feed (None for none);
    k_tir is C12's k.
    """

    def __init__(self, tool, material, machine, operation, margins, n_theta=144, n_quad=48, **opts):
        unknown = set(opts) - set(OPTION_DEFAULTS)
        if unknown:
            raise TypeError(f"unknown options {sorted(unknown)}")
        o = dict(OPTION_DEFAULTS, **opts)
        if operation not in OPERATIONS:
            raise ValueError(f"operation must be one of {OPERATIONS}")
        if o["c1_flute"] not in C1_FLUTES:
            raise ValueError(f"c1_flute must be one of {C1_FLUTES}")
        self.opts = o
        self.c1_flute, self.depth, self.k_tir = o["c1_flute"], o["depth"], o["k_tir"]
        self.tool, self.mat, self.mach, self.op, self.mg = tool, material, machine, operation, margins
        self.n_theta, self.n_quad = n_theta, n_quad
        self.coeffs = material.coefficients(tool.rake_deg)
        self.lam = material.lam(margins.aggressiveness)
        self.h_tooth = material.h_tooth_mm(tool.D_mm)
        tir_mm = machine.tir_in * MM_PER_IN
        self.offsets_per_in = runout_offsets_worst(tir_mm, tool.z, machine.runout_model)
        self.offsets_bound = forces.runout_offsets(tir_mm, tool.z, "bound")
        band = None
        if o["deflection_allow"] is None or o["stress_limit"] is None:
            band = provisional_limits(tool.D, o["limits_path"])
        self.band = band
        if o["deflection_allow"] is not None:
            self.delta_allow, self.delta_basis = o["deflection_allow"], "given"
        elif operation == "finish":
            self.delta_allow = deflection_limit(tool, operation, margins.aggressiveness)
            self.delta_basis = "v1 finishing tolerance limit"
        else:
            self.delta_allow = band["deflection_over_D"] * tool.D * margins.limit_scale
            self.delta_basis = (f"provisional: vendor median δ/D {band['deflection_over_D']:.5f} for "
                                f"{band['band']} (n {band['n']})·{margins.limit_scale:.2f}")
        if o["stress_limit"] is not None:
            self.stress_limit, self.stress_basis = o["stress_limit"], "given"
        else:
            self.stress_limit = band["sigma1_mpa"] * margins.limit_scale
            self.stress_basis = (f"provisional: vendor median σ1 {band['sigma1_mpa']:.0f} MPa for "
                                 f"{band['band']} (n {band['n']})·{margins.limit_scale:.2f}")
        self.feed_cap = o["effective_feed_ipm"] if operation == "adaptive" else None
        eq = BeamDeflectionEngine.equivalent_stickout(tool.segments, tool.D, tool.z, tool.helix_deg)
        self.eq_stickout = eq if eq else tool.stickout
        self.reach_factor, self.c9 = c9_stickout(self.eq_stickout, tool.D)
        self._speed = {}

    def speed(self, ae_in):
        key = round(ae_in, 9)
        if key not in self._speed:
            phi_e = forces.engagement_angle(ae_in * MM_PER_IN, self.tool.D_mm)
            self._speed[key] = c7_speed(self.mat, phi_e, self.tool.D_mm, self.mach.max_rpm,
                                        self.mg.life_ratio, self.reach_factor)
        return self._speed[key]


class CutPoint:
    """One (ap, ae) for a context: the fz-independent parts, and every check at a given fz."""

    def __init__(self, ctx, ap_in, ae_in, rpm=None):
        self.ctx, self.ap, self.ae = ctx, float(ap_in), float(ae_in)
        t = ctx.tool
        self.D_mm, self.ap_mm, self.ae_mm = t.D_mm, ap_in * MM_PER_IN, ae_in * MM_PER_IN
        rpm_life, _, self.c7 = ctx.speed(ae_in)
        self.rpm = float(rpm) if rpm else rpm_life
        self.eng = Engagement(self.D_mm, t.z, self.ap_mm, self.ae_mm, t.helix_deg, t.climb)
        self.c6 = c6_geometry(self.ap, self.ae, t.D, t.lcf, ctx.depth, ctx.op == "slot")
        self.c8 = c8_slot_depth(self.ap, t.D, ctx.op)
        self.c12 = c12_radial_reach(self.ae, ctx.mach.tir_in, ctx.k_tir)
        self._ctab = None

    @property
    def offsets(self):
        return self.ctx.offsets_per_in

    def max_chips_mm(self, fz_in):
        return self.eng.max_chips(fz_in * MM_PER_IN, self.offsets)

    def loads(self, fz_in):
        ctx = self.ctx
        f = self.eng.loads(fz_in * MM_PER_IN, self.offsets, ctx.coeffs, ctx.n_theta, ctx.n_quad)
        f["power_kw"] = max(f["torque_mean_nm"], 0.0) * machine_profiles.rad_s(self.rpm) / 1000.0
        return f

    def _compliance(self, a_in):
        """∫ (x − a)·x/I dx for a load at a (tip deflection), interpolated on a table over [0, ap]."""
        if self._ctab is None:
            t, n = self.ctx.tool, 40
            self._ctab = [compliance_integral(t.segments, self.ap * i / n, 0.0, t.z, t.helix_deg)
                          for i in range(n + 1)]
        n = len(self._ctab) - 1
        x = min(max(a_in / self.ap * n, 0.0), n)
        i = min(int(x), n - 1)
        return self._ctab[i] + (x - i) * (self._ctab[i + 1] - self._ctab[i])

    def _beam(self, f):
        """Largest tip deflection and largest σ1 over the revolution (the load band moves with the helix)."""
        t = self.ctx.tool
        samples = f["samples"]
        delta, gov_d = -1.0, None
        for mag, cen, tq in samples:
            a_in = cen / MM_PER_IN
            d = mag / N_PER_LBF * self._compliance(a_in) / t.E_psi
            if d > delta:
                delta, gov_d = d, (mag, a_in, tq)
        s1_max, gov_s = -1.0, None
        for x, d_mm, kind in critical_sections(t.segments, t.core()):
            for mag, cen, tq in samples:
                a_in = cen / MM_PER_IN
                if x <= a_in:
                    continue
                s1 = section_stress(mag, a_in, tq, x, d_mm)[3]
                if s1 > s1_max:
                    s1_max, gov_s = s1, (mag, a_in, tq)
        gov_s = gov_s or gov_d
        secs = bending_sections(t.segments, gov_s[0], gov_s[1], gov_s[2], t.core())
        return {"delta_in": max(delta, 0.0), "delta_load_n": gov_d[0], "delta_load_at_in": gov_d[1],
                "stress_load_n": gov_s[0], "stress_load_at_in": gov_s[1], "sections": secs}

    # --- checks ----------------------------------------------------------
    def c2(self, chips):
        return c2_tooth_strength(max(chips), self.ctx.h_tooth, self.ctx.mg.limit_margin)

    def c11(self, fz_in):
        return c11_feed(fz_in * self.ctx.tool.z * self.rpm, self.ctx.mach.max_feed_ipm, self.ctx.feed_cap)

    def force_checks(self, fz_in):
        ctx = self.ctx
        f = self.loads(fz_in)
        beam = self._beam(f)
        top = beam["sections"][0] if beam["sections"] else {"sigma1_mpa": 0.0, "kind": "none", "x_in": 0.0}
        return {
            "C3": c3_deflection(beam["delta_in"], ctx.delta_allow, beam["delta_load_at_in"]),
            "C4": c4_stress(top["sigma1_mpa"], ctx.stress_limit, f"{top['kind']} x = {top['x_in']:.4f}\"",
                            ctx.stress_basis),
            "C5": c5_spindle(abs(f["torque_mean_nm"]), f["power_kw"], self.rpm, ctx.mach.spindle,
                             ctx.mach.rating, ctx.mg.limit_margin),
        }, f, beam

    def lower_checks(self, chips):
        ctx = self.ctx
        h = max(chips) if ctx.c1_flute == "worst" else min(chips)
        return {"C1": c1_min_chip(h, ctx.tool.edge_radius_mm, ctx.lam, ctx.c1_flute),
                "C10": c10_work_hardening(h, ctx.mat.h_wh_mm)}

    def checks(self, fz_in):
        chips = self.max_chips_mm(fz_in)
        fc, f, beam = self.force_checks(fz_in)
        out = self.lower_checks(chips)
        out["C2"] = self.c2(chips)
        out.update(fc)
        out.update({"C6": self.c6, "C7": self.c7, "C8": self.c8, "C9": self.ctx.c9, "C11": self.c11(fz_in),
                    "C12": self.c12})
        return {k: out[k] for k in sorted(out, key=lambda s: int(s[1:]))}, f, beam, chips

    def upper_ok(self, fz_in):
        if not (self.c11(fz_in).ok and self.c2(self.max_chips_mm(fz_in)).ok):
            return False
        return all(c.ok for c in self.force_checks(fz_in)[0].values())

    def lower_ok(self, fz_in):
        return all(c.ok for c in self.lower_checks(self.max_chips_mm(fz_in)).values())

    # --- fz window -------------------------------------------------------
    def fz_window(self, rel_tol=0.002):
        """(fz_lo, fz_hi) in inches: the smallest fz meeting C1/C10 and the largest meeting C2–C5."""
        if not (self.c6.ok and self.c8.ok and self.c12.ok):
            return None
        fz_lo = _bisect_min(self.lower_ok, 1e-7, 0.05, rel_tol)
        if fz_lo is None:
            return None
        if not self.upper_ok(fz_lo):
            return (fz_lo, None)
        lo, hi = fz_lo, fz_lo * 2.0
        while self.upper_ok(hi):
            lo, hi = hi, hi * 2.0
            if hi > 0.1:
                return (fz_lo, lo)
        while hi / lo > 1.0 + rel_tol:
            mid = math.sqrt(lo * hi)
            if self.upper_ok(mid):
                lo = mid
            else:
                hi = mid
        return (fz_lo, lo)

    def mrr_in3_min(self, fz_in):
        return self.ap * self.ae * fz_in * self.ctx.tool.z * self.rpm


def _bisect_min(pred, lo, hi, rel_tol):
    """Smallest x in [lo, hi] with pred(x) true, assuming pred is monotone (false then true)."""
    if pred(lo):
        return lo
    if not pred(hi):
        return None
    while hi / lo > 1.0 + rel_tol:
        mid = math.sqrt(lo * hi)
        if pred(mid):
            hi = mid
        else:
            lo = mid
    return hi


def evaluate_cut(tool, material, machine, operation, ap_in, ae_in, fz_in, rpm=None, aggressiveness=0.5,
                 margins=None, n_theta=720, n_quad=96, **opts):
    """Every constraint C1–C12 for one cut (inches). rpm defaults to C7's speed for the engagement.

    opts: see OPTION_DEFAULTS.
    """
    mg = margins or Margins(aggressiveness)
    ctx = _Context(tool, material, machine, operation, mg, n_theta, n_quad, **opts)
    pt = CutPoint(ctx, ap_in, ae_in, rpm)
    checks, f, beam, chips = pt.checks(fz_in)
    return _report(pt, fz_in, checks, f, beam, chips)


def _report(pt, fz_in, checks, f, beam, chips):
    t = pt.ctx.tool
    vf = fz_in * t.z * pt.rpm
    cut = {"ap_in": pt.ap, "ae_in": pt.ae, "fz_in": fz_in, "rpm": pt.rpm,
           "sfm": math.pi * t.D * pt.rpm / 12.0, "feed_ipm": vf, "mrr_in3_min": pt.mrr_in3_min(fz_in),
           "ap_over_D": pt.ap / t.D, "ae_over_D": pt.ae / t.D,
           "h_max_nominal_in": forces.max_chip_thickness(fz_in, pt.ae, t.D),
           "h_m_nominal_in": forces.mean_chip_thickness(fz_in, pt.ae, t.D),
           "h_max_worst_in": max(chips) / MM_PER_IN, "h_max_thinnest_in": min(chips) / MM_PER_IN}
    lbf = beam["delta_load_n"] / N_PER_LBF
    loads = {"lateral_peak_n": f["peak_n"], "lateral_peak_lbf": f["peak_n"] / N_PER_LBF,
             "lateral_mean_n": f["mean_n"], "torque_mean_nm": f["torque_mean_nm"],
             "power_w": f["power_kw"] * 1000.0,
             "deflection_tip_in": beam["delta_in"],
             "deflection_load_n": beam["delta_load_n"], "deflection_load_at_in": beam["delta_load_at_in"],
             "deflection_if_tip_load_in": deflection_in(lbf, t.segments, 0.0, 0.0, t.z, t.helix_deg, t.E_psi),
             "sections": beam["sections"], "flute_h_max_in": [h / MM_PER_IN for h in chips],
             "flute_kc_n_mm2": f["flute_kc_n_mm2"]}
    ctx = pt.ctx
    bound = pt.eng.max_chips(fz_in * MM_PER_IN, ctx.offsets_bound)
    h_min = ctx.lam * t.edge_radius_mm
    warnings = []
    if min(bound) < h_min:
        warnings.append(f"bound runout (one flute high by the full TIR): the thinnest flute's chip "
                        f"{min(bound) / MM_PER_IN:.6f}\" is under h_min {h_min / MM_PER_IN:.6f}\" — it would rub")
    if max(bound) > ctx.h_tooth:
        warnings.append(f"bound runout: the worst flute's chip {max(bound) / MM_PER_IN:.6f}\" exceeds h_tooth "
                        f"{ctx.h_tooth / MM_PER_IN:.6f}\"")
    if pt.ae < AE_SANITY * t.D:
        warnings.append(f"ae {pt.ae:.5f}\" is under {AE_SANITY:g}·D, lighter than any vendor-published side cut")
    cut["toolpath_in_per_in3"] = 1.0 / (pt.ap * pt.ae)
    cut["time_min_per_in3"] = 1.0 / cut["mrr_in3_min"] if cut["mrr_in3_min"] > 0 else math.inf
    return {"cut": cut, "loads": loads, "checks": {k: c.to_dict() for k, c in checks.items()},
            "violated": [k for k, c in checks.items() if not c.ok],
            "runout_bound": {"flute_h_max_in": [h / MM_PER_IN for h in bound],
                             "c1_ok": min(bound) >= h_min, "c2_ok": max(bound) <= ctx.h_tooth},
            "warnings": warnings}


# ---------------------------------------------------------------------------
# Optimizer
# ---------------------------------------------------------------------------

def _logspace(lo, hi, n):
    if n <= 1 or hi <= lo:
        return [hi]
    r = (hi / lo) ** (1.0 / (n - 1))
    return [lo * r ** i for i in range(n)]


def _parameters(tool, material, machine, mg, ctx):
    p = {
        "k_r": material.k_r, "tool_factor": material.tool_factor, "kc_hardness_exp": material.kc_hardness_exp,
        "vc_ref_sfm": material.vc_ref_sfm, "vc_hardness_exp": material.vc_hardness_exp,
        "vc_engagement_exp": material.vc_engagement_exp, "vc_engagement_ae_min": material.vc_engagement_ae_min,
        "taylor_n": material.taylor_n,
        "h_tooth_c": material.h_tooth_c, "h_tooth_n": material.h_tooth_n, "edge_radius_mm": tool.edge_radius_mm,
    }
    out = {k: {"value": v, "placeholder": True, "basis": PLACEHOLDERS[k]} for k, v in p.items()}
    out.update({
        "aggressiveness": {"value": mg.aggressiveness, "placeholder": False, "basis": "input"},
        "aggressiveness_map": {"value": {"limit_scale": mg.limit_scale, "life_ratio": mg.life_ratio,
                                         "limit_margin": mg.limit_margin, "lambda": ctx.lam},
                               "placeholder": True, "basis": PLACEHOLDERS["aggressiveness_map"]},
        "kc1_1_at_hb": {"value": ctx.coeffs.kienzle.kc1_1, "placeholder": False,
                        "basis": f"{material.kienzle.kc1_1:g}·{material.kc_scale():.4f} ({material.name})"},
        "mc": {"value": material.kienzle.mc, "placeholder": False, "basis": "Sandvik MC table"},
        "tir_in": {"value": machine.tir_in, "placeholder": False, "basis": f"machine setting, {machine.runout_model} model"},
        "fatigue_reference_mpa": {"value": tool.fatigue_fraction * tool.trs_mpa, "placeholder": False,
                                  "basis": "0.35–0.4 × TRS 3.8 GPa, fully reversed bending (reported, not the C4 limit)"},
        "E_mpa": {"value": tool.E_mpa, "placeholder": False, "basis": "CERATIZIT p-line p.22, 10 % Co"},
        "core_ratio": {"value": tool.core(), "placeholder": False, "basis": "patents/Mitsubishi, by flute count"},
        "deflection_allow_in": {"value": ctx.delta_allow, "placeholder": True, "basis": ctx.delta_basis},
        "stress_limit_mpa": {"value": ctx.stress_limit, "placeholder": True, "basis": ctx.stress_basis},
        "effective_feed_ipm": {"value": ctx.feed_cap, "placeholder": True, "basis": PLACEHOLDERS["effective_feed_ipm"]},
        "machine_max_feed_ipm": {"value": machine.max_feed_ipm, "placeholder": False, "basis": "machine profile"},
        "k_tir": {"value": ctx.k_tir, "placeholder": True, "basis": PLACEHOLDERS["k_tir"]},
        "h_tooth_mm": {"value": ctx.h_tooth, "placeholder": True, "basis": "c·D^n"},
    })
    return out


def optimize(tool, material, machine, operation="adaptive", aggressiveness=0.5, *, margins=None,
             stock=None, wall_height=None, level_time_s=None, path_length_per_level_in=None,
             depth_trade=DEPTH_TRADE_MRR, grid=(20, 16), ae_max=AE_MAX, n_theta=144, n_quad=48,
             robustness=True, robust=True, flat_tol=0.05, **opts):
    """Choose fz, ap and ae for one operation (inches). Speed comes from C7 for each engagement.

    operation: "rough" | "adaptive" | "slot" | "finish".
    depth: the operation's real top-to-bottom depth (Z-level credit, design §7.2); ap is then depth/N.
    stock, wall_height: finishing's fixed ae and ap (wall_height defaults to min(LCF, depth)).
    level_time_s, path_length_per_level_in: optional per-level overhead (retract, link, re-entry) and
        cutting path per level; with both, the score is MRR/(1 + t_level·v_f/L_path).
    depth_trade: without the overhead terms, the deepest candidate within this fraction of the best
        score wins (10 % rule, 2026-10-13).
    robust: among the candidates the depth rule leaves (or, with the overhead terms, those within
        flat_tol of the best), take the one with the largest worst-case margin when TIR, K_r, h_tooth or
        kc is pushed the wrong way (`robustness_report`): where MRR is flat, an error in an uncertain
        input then costs little MRR rather than a tool (design §3.6).
    opts (OPTION_DEFAULTS): depth, the operation's real depth; deflection_allow / stress_limit to override
        the provisional C3/C4 limits; c1_flute ("thinnest" by default: every flute forms a chip);
        effective_feed_ipm (C11, adaptive only; None for none); k_tir (C12).

    The score is MRR with the feed capped by C11, i.e. the inverse of machining time per volume: a narrow
    ae needs a long toolpath (1/(ap·ae) inches per in³), and once the feed is capped that path costs time.
    """
    mg = margins or Margins(aggressiveness)
    ctx = _Context(tool, material, machine, operation, mg, n_theta, n_quad, **opts)
    depth = ctx.depth
    D, lcf = tool.D, tool.lcf
    ap_max = min(lcf, depth) if depth else lcf
    prov = [f"{tool.label or 'tool'}: D {D:.4f}\", {tool.z} flutes, LCF {lcf:.4f}\", stickout "
            f"{tool.stickout:.4f}\" (equivalent {ctx.eq_stickout / D:.2f}·D), helix {tool.helix_deg:g}°",
            f"material: {material.name}; kc1.1 = {ctx.coeffs.kienzle.kc1_1:.0f} N/mm², mc {material.kienzle.mc:g}",
            f"machine: {machine.label or 'spindle'}, max {machine.max_rpm:.0f} rpm, C5 {machine.rating}, "
            f"TIR {machine.tir_in:.5f}\" ({machine.runout_model})",
            f"margins (aggressiveness {mg.aggressiveness:.2f}): λ {ctx.lam:.2f}, tool life ×{mg.life_ratio:.2f}, "
            f"C2/C5 margin {mg.limit_margin:.0%}; C3 δ_allow {ctx.delta_allow:.6f}\" ({ctx.delta_basis}); "
            f"C4 {ctx.stress_limit:.0f} MPa ({ctx.stress_basis})",
            f"C1 on the {ctx.c1_flute} flute; C11 feed cap "
            f"{min(c for c in (machine.max_feed_ipm, ctx.feed_cap, math.inf) if c):.0f} IPM; "
            f"C12 ae ≥ {ctx.k_tir:g}·TIR = {ctx.k_tir * machine.tir_in:.5f}\""]

    # Candidate (ap, ae) pairs per operation.
    if operation == "finish":
        if stock is None:
            raise ValueError("finishing needs stock (the fixed ae)")
        wall = wall_height if wall_height is not None else ap_max
        pairs = [(min(wall, ap_max), min(stock, D))]
        prov.append(f"finish: ap fixed at {pairs[0][0]:.4f}\", ae at the stock {pairs[0][1]:.4f}\"; maximize feed")
    else:
        if depth:
            n_min = max(1, math.ceil(depth / ap_max - 1e-9))
            aps = sorted({depth / n for n in range(n_min, n_min + grid[0]) if depth / n >= 0.01 * D})
            prov.append(f"Z-level credit from the real depth {depth:.4f}\": ap = depth/N, N ≥ {n_min}")
        else:
            aps = _logspace(max(0.02 * D, ap_max / 200.0), ap_max, grid[0])
        if operation == "slot":
            k = slot_depth_ratio(D)
            if k is not None:
                aps = [a for a in aps if a <= k * D + 1e-12] or [k * D]
                if not depth and k * D < ap_max and all(abs(a - k * D) > 1e-12 for a in aps):
                    aps.append(k * D)
            pairs = [(a, D) for a in aps]
            prov.append("slot: ae = D; maximize MRR over fz and ap" + (f"; C8 caps ap at {k:g}·D" if k else ""))
        else:
            ae_lo = max(ctx.k_tir * machine.tir_in, 0.002 * D)
            aes = _logspace(ae_lo, ae_max * D, grid[1])
            pairs = [(a, e) for a in aps for e in aes]
            prov.append(f"{operation}: maximize MRR over fz, ap ∈ [{aps[0]:.4f}, {aps[-1]:.4f}]\", "
                        f"ae ∈ [{aes[0]:.4f}, {aes[-1]:.4f}]\"")

    cands, infeasible = [], {}
    for ap, ae in pairs:
        pt = CutPoint(ctx, ap, ae)
        win = pt.fz_window()
        if win is None or win[1] is None:
            if not (pt.c6.ok and pt.c8.ok and pt.c12.ok):
                reason = "C6/C8/C12 geometry"
            elif win is None:
                reason = "C1/C10 unreachable"
            else:
                reason = "upper limits (C2–C5) below the C1/C10 minimum fz"
            infeasible[reason] = infeasible.get(reason, 0) + 1
            continue
        fz = win[1]
        mrr = pt.mrr_in3_min(fz)
        score = mrr
        if level_time_s and path_length_per_level_in:
            vf = fz * tool.z * pt.rpm
            score = mrr / (1.0 + level_time_s * (vf / 60.0) / path_length_per_level_in)
        cands.append({"pt": pt, "ap": ap, "ae": ae, "fz": fz, "fz_lo": win[0], "mrr": mrr, "score": score})

    if not cands:
        pt = CutPoint(ctx, pairs[-1][0], pairs[-1][1])
        win = pt.fz_window()
        fz = win[0] if win else 1e-4
        checks, f, beam, chips = pt.checks(fz)
        rep = _report(pt, fz, checks, f, beam, chips)
        prov.append(f"no feasible cut: {infeasible}; checks shown at ap {pt.ap:.4f}\", ae {pt.ae:.4f}\", "
                    f"fz {fz:.6f}\" (smallest fz that meets C1/C10)")
        return {"operation": operation, "feasible": False, "infeasible_counts": infeasible, **rep,
                "binding": rep["violated"], "parameters": _parameters(tool, material, machine, mg, ctx),
                "provenance": prov}

    best = max(cands, key=lambda c: c["score"])
    overhead = bool(level_time_s and path_length_per_level_in)
    if operation == "finish":
        chosen, rule = best, "finish: the highest feed at the fixed cut"
    else:
        tol = flat_tol if overhead else depth_trade
        band = [c for c in cands if c["score"] >= (1.0 - tol) * best["score"]]
        if overhead:
            pool = band
            rule = f"within {tol:.0%} of the best score with the per-level overhead"
        else:
            ap_star = max(c["ap"] for c in band)
            pool = [c for c in band if abs(c["ap"] - ap_star) < 1e-12]
            rule = (f"deepest cut within {depth_trade:.0%} of the best score (10 % rule, 2026-10-13): "
                    f"ap {ap_star:.4f}\"")
        if robust and len(pool) > 1:
            for c in pool:
                rep_c = robustness_report(tool, material, machine, operation,
                                          {"ap_in": c["ap"], "ae_in": c["ae"], "fz_in": c["fz"], "rpm": c["pt"].rpm},
                                          ctx, n_theta=n_theta, n_quad=n_quad)
                c["robust_margins"] = sorted(round(v["margin"], 2) for v in rep_c.values())
            # Leximin: the largest worst-case margin, then the largest second-worst, ..., then score.
            chosen = max(pool, key=lambda c: (tuple(c["robust_margins"]), c["score"]))
            rule += (f"; of {len(pool)} candidates there, the most robust with TIR, K_r, h_tooth or kc pushed "
                     f"the wrong way (leximin of the scenario margins {chosen['robust_margins']})")
        else:
            chosen = max(pool, key=lambda c: c["score"])

    # Final evaluation at full resolution, rpm and fz as chosen.
    ctx_hi = _Context(tool, material, machine, operation, mg, 720, 96, **opts)
    pt_hi = CutPoint(ctx_hi, chosen["ap"], chosen["ae"], chosen["pt"].rpm)
    fz = chosen["fz"]
    checks, f, beam, chips = pt_hi.checks(fz)
    if not all(c.ok for c in checks.values()):
        # The coarse search can sit a hair over a limit at full resolution: back fz off onto it.
        win = pt_hi.fz_window()
        if win and win[1]:
            fz = min(fz, win[1])
            checks, f, beam, chips = pt_hi.checks(fz)
    rep = _report(pt_hi, fz, checks, f, beam, chips)
    binding = _binding(checks)
    prov.append(f"selection: {rule}")
    prov.append(f"best score {best['score']:.5f} in³/min at ap {best['ap']:.4f}\", ae {best['ae']:.4f}\", "
                f"fz {best['fz']:.6f}\"; chosen ap {rep['cut']['ap_in']:.4f}\", ae {rep['cut']['ae_in']:.4f}\", "
                f"fz {fz:.6f}\", MRR {rep['cut']['mrr_in3_min']:.5f} in³/min")
    prov.extend(f"{k}: {c.detail}" for k, c in checks.items() if c.applies)
    prov.append("binding: " + (", ".join(binding) or "none"))
    prov.extend(f"warning: {w}" for w in rep["warnings"])

    score = rep["cut"]["mrr_in3_min"]
    if overhead:
        score /= 1.0 + level_time_s * (rep["cut"]["feed_ipm"] / 60.0) / path_length_per_level_in
    out = {"operation": operation, "feasible": not rep["violated"], **rep, "binding": binding, "score": score,
           "best_score_point": {"ap_in": best["ap"], "ae_in": best["ae"], "fz_in": best["fz"],
                                "rpm": best["pt"].rpm, "mrr_in3_min": best["mrr"], "score": best["score"]},
           "candidates": len(cands), "infeasible_counts": infeasible,
           "parameters": _parameters(tool, material, machine, mg, ctx), "provenance": prov}
    if robustness:
        out["robustness"] = robustness_report(tool, material, machine, operation, rep["cut"], ctx)
    return out


def _binding(checks, tol=0.03):
    """Constraints within tol of their limit (C6 at LCF or depth, C7 at the rpm cap)."""
    out = []
    for k, c in checks.items():
        if not c.applies or c.kind == "info":
            continue
        m = c.margin
        if m is not None and m <= tol:
            out.append(k)
    return out


UNCERTAIN_CHECKS = ("C1", "C2", "C3", "C4", "C5", "C10", "C12")


def robustness_report(tool, material, machine, operation, cut, ctx, n_theta=360, n_quad=64):
    """Re-check a cut (same ap, ae, fz, rpm) with each uncertain input pushed the wrong way.

    Limits are the context's C3/C4 limits with no C2/C5 margin. Returns, per scenario, the constraint
    with the least margin among C1–C5, C10 and C12, its margin and any violations.
    """
    scenarios = {
        "TIR ×2": (tool, material, replace(machine, tir_in=machine.tir_in * 2.0)),
        "K_r 0.6 (top of 0.3–0.6)": (tool, replace(material, k_r=0.6), machine),
        "h_tooth −25 %": (tool, replace(material, h_tooth_c=material.h_tooth_c * 0.75), machine),
        "kc +20 % (hardness/tool factor)": (tool, replace(material, tool_factor=material.tool_factor * 1.2), machine),
    }
    nominal = Margins(ctx.mg.aggressiveness, ctx.mg.limit_scale, ctx.mg.life_ratio, 0.0)
    opts = dict(ctx.opts, deflection_allow=ctx.delta_allow, stress_limit=ctx.stress_limit)
    out = {}
    for name, (t, m, mc) in scenarios.items():
        r = evaluate_cut(t, m, mc, operation, cut["ap_in"], cut["ae_in"], cut["fz_in"], cut["rpm"],
                         margins=nominal, n_theta=n_theta, n_quad=n_quad, **opts)
        ms = [(k, r["checks"][k]["margin"]) for k in UNCERTAIN_CHECKS if r["checks"][k]["margin"] is not None]
        worst = min(ms, key=lambda kv: kv[1])
        out[name] = {"worst": worst[0], "margin": worst[1],
                     "violated": [k for k in r["violated"] if k in UNCERTAIN_CHECKS]}
    return out
