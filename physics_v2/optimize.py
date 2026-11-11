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
  an optional per-level overhead enters the score. Selection (V3 M4): of the candidates within 10 % of the best
  score (v1 `DEPTH_TRADE_MRR`, approved 2026-10-13), the one closest to the vendor engagement medians
  (data/model_v2/engagement_envelope.json) and chip load (consensus), locally refined off the grid; the engagement
  is chosen for the reference runout (`REFERENCE_TIR_IN`) so the actual runout only derates the feed.
* Robust optimum: aggressiveness sets the margins (design §3.6): λ in C1, a scale on the C3/C4 limits,
  the tool-life target in C7, and a margin on the uncertain upper limits C2 and C5. fz then sits at the
  highest value that keeps every margin.
* User decisions 2026-10-16:
  - C1 held on every flute (the thinnest flute's chip at least h_min). V3 M1 changed the default to the
    wall-generating flute (`c1_flute="wall"`): a flute that rubs is reported (`flutes_cutting`), not forbidden.
  - Runout is the eccentric model (TIR = 2e) at its worst phase; the bound model (one flute high by the
    full TIR) is only reported as a warning.
  - Adopted basis (Round 4): C2 is the chip invariant, worst-flute h_max ≤ the vendor median of
    h_max/D per diameter band (data/model_v2/chip_limits.json, tools/v2_invariants.py). C4 is carbide
    fatigue at 10⁷ cycles (0.375·TRS = 1425 MPa) on the fluted section shared with C3; Sandvik's 0.79
    force factor stays off (calibration). C3 is the wall-normal deflection ≤ 50 % of the radial stock to
    leave (default 0.05 mm) for roughing, adaptive and slots, and ≤ the wall tolerance (default 0.005 mm)
    for finishing. Aggressiveness scales the C2 and C4 limits by 0.7 + 0.6·a.
  - The Round 2 vendor-median C3/C4 limits (data/model_v2/provisional_limits.json) are only reported
    (`vendor_median_comparison`).
  - Program size (user's NC files): 23.1 bytes/line × L_cut/s; optional C13 limit (off, 6 MB).
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
Sandvik's ToolGuide), the kc and v_c hardness exponents, and the Taylor anchor, exponent and engagement
exponent. The aggressiveness → margin mapping is a placeholder too.

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

Stress (design §3.4): σ = M·c/I with M = F·(x − a) at the far end of every segment: the flute root
at the top of the flutes, every diameter step, and the holder face. The flute root uses the same fluted
section as the deflection (v1's inertia, ≈ a 0.8·D cylinder; Kops & Vo 1990) with the outer fibre at
D/2 (Round 3). The Round 1–2 core circle (0.6·D) put published micro cuts above TRS; it remains
available as Tool(stress_section="core"). Torsion τ = T·c/J with J = 2I; carbide is brittle, so C4 checks the largest
principal stress σ1 = σ/2 + √((σ/2)² + τ²) (Rankine). Stress concentration at the steps is not
modelled; the stress fraction covers it.
"""
import json
import logging
import math
import os
from dataclasses import dataclass, replace
from typing import Optional

import machine_profiles
from gwizard_physics import DEPTH_TRADE_MRR, BeamDeflectionEngine, CuttingMechanics, reach_sfm_factor
from physics_v2 import forces
from toolwiz_common.tool_profile import ToolProfile

LOG = logging.getLogger(__name__)
MM_PER_IN = forces.MM_PER_IN
# Explicit ceiling of the fz search (in/tooth). A window that reaches it is reported (fz_capped), not
# silently clipped.
FZ_MAX_IN = 0.1
# Runout phases sampled over one flute pitch for the eccentric model (C1 and C2 each take their worst).
N_RUNOUT_PHASES = 24
N_PER_LBF = 4.4482216152605
MPA_PER_PSI = 0.0068947572932
FT_PER_M = 1.0 / 0.3048

OPERATIONS = ("rough", "adaptive", "slot", "finish")
C1_FLUTES = ("thinnest", "wall", "worst")   # every flute / the wall-generating flute / largest chip
C2_BASES = ("worst", "nominal")             # adopted (worst-flute chip) / evaluated alternative (Round 5)
WALL_METRICS = ("ripple", "max")

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
# Stock to leave (V3 round 2): C3 for roughing, adaptive and slots is k·D only; the stock the finishing pass needs is
# reported (recommended_radial_stock_in) from the predicted deflection. STOCK_TO_LEAVE_IN/STOCK_FRACTION remain only as
# the unused legacy option `stock_to_leave_in`.
STOCK_TO_LEAVE_IN = 0.05 / 25.4
STOCK_FRACTION = 0.5
CHIP_LIMITS_PATH = None  # set below, next to LIMITS_PATH
# Finishing wall tolerance (C3 for finishing): the user's usual 0.005 mm, user-settable (sometimes 0.001 mm).
WALL_TOLERANCE_IN = 0.005 / 25.4
WALL_TARGET_RTOL = 1e-6  # float round-off only
# Program size (user's NC files, 2026-10-16: 100 adaptive ops in 239 Fusion → Brother C00 programs):
# size ≈ BYTES_PER_LINE · L_cut / s, L_cut = V/(ap·ae)·(1 + LINKING_FACTOR), s = mean point spacing.
BYTES_PER_LINE = 23.1          # p10–p90 21.5–26.1
LINKING_FACTOR = 0.15          # empirical
POINT_SPACING_MM = 0.22        # typical (p10–p90 0.10–0.40 mm)
POINT_SPACING_BAD_MM = 0.04    # micro tool at tight tolerance (T12, O0175)
PROGRAM_LIMIT_BYTES = 6_000_000
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIMITS_PATH = os.path.join(ROOT, "data", "model_v2", "provisional_limits.json")
CHIP_LIMITS_PATH = os.path.join(ROOT, "data", "model_v2", "chip_limits.json")
CONSENSUS_DEFAULT_PATH = os.path.join(ROOT, "data", "model_v2", "consensus.json")
V1_OPERATION_NAME = {"rough": "Roughing", "adaptive": "Adaptive Roughing", "slot": "Slotting",
                     "finish": "Finishing"}

# ---------------------------------------------------------------------------
# Sources
# ---------------------------------------------------------------------------

SRC = {
    "C1": "Minimum chip thickness h_min = λ·r_β: λ 0.2–0.4 for steel and 304 stainless (Wojciechowski, "
          "Materials 15:59 (2022) Table 1; Li et al., Mech. Sci. 12:487 (2021)); r_β of micro end mills "
          "0.4–3.5 µm (Liang et al. 2018; Jäckel et al. 2024). docs/research/carbide_and_edge_radius.md §3–4",
    "C2": "Chip invariant (user decision 2026-10-16): worst-flute h_max ≤ the vendor median of worst-flute "
          "h_max/D in this diameter band (eccentric runout 0.0002\", 246 vendor side/rough/HEM rows on their own "
          "geometry; data/model_v2/chip_limits.json, tools/v2_invariants.py), scaled by aggressiveness",
    "C3": "Rough/adaptive/slot (planner decision, V3 round 2): wall-normal tip deflection ≤ k·D, k = 0.5 % + 1.0 % × "
          "aggressiveness. Finishing: the user's wall tolerance (default 0.005 mm)",
    "C4": "Carbide fatigue at 10⁷ cycles, fully reversed bending: 0.375 × TRS 3.8 GPa = 1425 MPa "
          "(0.35–0.4 × TRS; Schleinkofer 1996, Kursawe 2001 via Preis 2004; CERATIZIT TRS), on the fluted "
          "section shared with C3, scaled by aggressiveness (user decision 2026-10-16)",
    "C5": "Spindle capacity at rpm, continuous rating (user decision 2026-10-15): "
          "machines/*.json via machine_profiles.capacity",
    "C6": "Geometry: ap ≤ LCF (and ≤ the operation's depth), ae ≤ D; ae and ap fixed for finishing",
    "C7": "Taylor tool life v_c·T^n = C at the real hardness and engagement (design §3.5 C7; decision "
          "§7.1). Hardness and engagement shape from Sandvik CoroPlus ToolGuide probes (v_c ∝ HB^−1.0; "
          "1.8× at ~10 % engagement), docs/research/sandvik_toolguide_probes.md; rpm ≤ machine max",
    "C8": "Vendor engagement envelope (V3 M3): ap/D from p25 (a = 0) through the median (0.5) to the max (1.0) of the "
          "vendor rows of this material group, operation and diameter band (data/model_v2/engagement_envelope.json). "
          "Without the table: Harvey miniature guide (step down 5–15 % of D) and SF_73000 slot ADOC (0.14·D for "
          "0.015–0.047\", 0.35·D for 0.062\" and up)",
    "C9": "Empirical (design §3.5 C9): OSG overhang speed reduction on the equivalent stickout, "
          "v1 reach_sfm_factor (1.0 to 4·D, −10 %/D, ≥ 40 %)",
    "C11": "Feed: v_f ≤ the machine's max cutting feed (machine profile) and, for adaptive, an effective "
           "adaptive feed (empirical, user-settable, default 200 IPM)",
    "C12": "Every flute reaches the stock: ae ≥ k·TIR, k = 2 (lowest flute engages ae − TIR ≥ ae/2)",
    "C13": "Program size (optional): 23.1 bytes/line × L_cut / s, L_cut = V/(ap·ae)·1.15, from 100 adaptive "
           "ops in the user's 239 Fusion → Brother C00 programs (2026-10-16); limit user-set (6 MB)",
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
    "edge_radius_mm": "0.002: micro end mills 1–4 µm (Ducobu 2017), no data vs diameter",
    "aggressiveness_map": "C2 and C4 limits ×(0.7 + 0.6·a) (the vendor-median chip and the 10⁷ fatigue limit "
                          "at a = 0.5; ×1.3 at a = 1 is 0.49·TRS), tool life ×4^(0.5 − a), C5 margin "
                          "0.2·(1 − a), λ from the top to the bottom of its range",
    "effective_feed_ipm": "200 IPM: empirical effective adaptive feed (user, 2026-10-16), user-settable",
    "k_tir": "2: C12 ae ≥ k·TIR, see K_TIR",
}

# Core (web) diameter / D by flute count: patents and Mitsubishi ("usually about 60 %"),
# docs/research/carbide_and_edge_radius.md §5. Design targets, none measured for micro tools.
CORE_RATIO_BY_FLUTES = {1: 0.55, 2: 0.60, 3: 0.60, 4: 0.60, 5: 0.62, 6: 0.64}

# Harvey SF_73000 slotting ADOC for its miniature columns (tests/benchmarks/v2/harvey.json).
SLOT_DEPTH_RATIO_MICRO = ((0.0625, 0.14), (0.125, 0.35))   # (D below, k_slot)

# --- V3 envelopes (docs/V3_IMPLEMENTATION_PLAN.md M3; docs/REVIEW_AND_FIX_PLAN.md Part 5.3 item 3) ---------------
# Material groups and diameter bands of data/model_v2/engagement_envelope.json (tools/v2_invariants.py).
# The limits below are the plan's: adaptive ae 0.05·D (0.40·D non-ferrous: 0.30·D others), roughing ae ≤ 0.50·D, chip
# floor 50 % of the consensus (owner decision D9). CHIP_FLOOR_CEILING_FRACTION, FLOOR_HIRES_SCALE and
# ALL_FLUTES_PENALTY are numerical choices of this implementation (no external source): the floor never exceeds 80 %
# of the C2 nominal-chip ceiling; the final full-resolution check takes the floor 5 % lower than the search; a cut
# where some flute rubs costs 0.1 of log distance in the selection.
MATERIAL_GROUPS = ("non-ferrous", "steel", "stainless", "Ti-Ni-Co", "hardened")
HARDENED_HRC = 45.0                  # steels harder than this are "hardened"
DIAMETER_BANDS = (("<=1/32", 0.0, 1 / 32), ("1/32-1/16", 1 / 32, 1 / 16), ("1/16-1/8", 1 / 16, 1 / 8),
                  ("1/8-1/4", 1 / 8, 1 / 4), ("1/4-1/2", 1 / 4, 1 / 2), (">1/2", 1 / 2, math.inf))
# Radial engagement limits (fractions of D): adaptive up to 0.30 (0.40 non-ferrous), roughing up to 0.50, and
# adaptive never below 0.05·D (nor C12's k·TIR).
AE_ADAPTIVE_MAX_OVER_D, AE_ADAPTIVE_MAX_NONFERROUS_OVER_D = 0.30, 0.40
AE_ROUGH_MAX_OVER_D, AE_ADAPTIVE_MIN_OVER_D = 0.50, 0.05
# Chip-load floor (check C14lo): fz ≥ this × the vendor-consensus median fz of the bucket, else 2 × the rubbing limit.
CHIP_FLOOR_FRACTION, CHIP_FLOOR_RUBBING_FACTOR, CHIP_FLOOR_CEILING_FRACTION = 0.5, 2.0, 0.8
CHIP_FLOOR_HARD_FRACTION = 0.4   # soft band 0.40-0.50 x the vendor median (round 8)
FLOOR_HIRES_SCALE = 0.95
GAP_NODES = 2   # consecutive infeasible grid nodes that end the connected feasible interval
# C3 in the user-engagement path is a quality limit, advisory up to this multiple of k·D (planner, round 3).
USER_C3_FACTOR = 2.0
# Search resolution (coarse-to-fine, V3 round 2): the grid and fz tolerances of the candidate search; the final cut is
# re-checked at HIRES_THETA x HIRES_QUAD rotation and quadrature samples with fz placed to HIRES_FZ_TOL.
SEARCH_FZ_TOL, SEARCH_LOWER_TOL, SEARCH_PHASES = 0.01, 0.05, 8
SEARCH_THETA, SEARCH_QUAD, SEARCH_GRID = 72, 24, (7, 5)
HIRES_THETA, HIRES_QUAD, HIRES_FZ_TOL = 360, 64, 0.004
# Vendor depth caps at aggressiveness a: p25 (a = 0) → median (a = 0.5) → max (a = 1.0), in ap/D.
DEPTH_CAP_POINTS = (("p25", 0.0), ("median", 0.5), ("max", 1.0))
# Which engagement-envelope operation each optimizer operation reads.
# The engagement is selected for this runout (the default TIR); the machine's actual runout derates fz (select_tir_in).
REFERENCE_TIR_IN = 0.0002
# Selection (M4): a cut where some flute rubs costs as much as this much log-distance from the vendor medians.
ALL_FLUTES_PENALTY = 0.1
ENVELOPE_OPERATION = {"slot": "slot", "adaptive": "hem", "rough": "side_rough"}
ENVELOPE_DEFAULT_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data", "model_v2",
                                     "engagement_envelope.json")


def diameter_band(D_in):
    """The envelope diameter band of a tool (upper bounds inclusive: 1/16" is in 1/32-1/16)."""
    for name, _, hi in DIAMETER_BANDS:
        if D_in <= hi + 1e-9:
            return name
    return DIAMETER_BANDS[-1][0]


def material_group(family, hb=None):
    """Envelope material group of a GWizard family at hardness hb (HB): hardened above 45 HRC, else by family.

    Cast iron counts as steel; graphite and copper as non-ferrous; nickel, titanium and cobalt alloys together.
    """
    f = str(family or "").lower()
    if hb:
        from gwizard_physics import ASTMHardnessConverter
        if hb >= ASTMHardnessConverter.hrc_to_brinell(HARDENED_HRC) and not f.startswith(("alum", "copper", "graph")):
            return "hardened"
    if f.startswith(("alum", "copper", "brass", "bronze", "graph", "magnes", "zinc", "plastic", "wood")):
        return "non-ferrous"
    if f.startswith("stainless"):
        return "stainless"
    if f.startswith(("titan", "high temp", "nickel", "cobalt")):
        return "Ti-Ni-Co"
    return "steel"


def envelope_bucket(table, family, hb, D_in, operation):
    """The envelope bucket (dict with ap_over_D, ae_over_D quartiles, n, widening) for a cut, or None."""
    op = ENVELOPE_OPERATION.get(operation)
    if not table or op is None:
        return None
    key = "|".join((material_group(family, hb), op, diameter_band(D_in)))
    return (table.get("buckets") or {}).get(key)


def depth_cap_over_D(bucket, aggressiveness, what="ap_over_D"):
    """Vendor depth cap ap/D (or, with what="ae_over_D", the width cap ae/D) at aggressiveness a: p25 at 0, the
    median at 0.5, the max at 1 (geometric between)."""
    if not bucket:
        return None
    pts = [(a, bucket[what][k]) for k, a in DEPTH_CAP_POINTS]
    a = min(max(aggressiveness, 0.0), 1.0)
    for (a0, v0), (a1, v1) in zip(pts, pts[1:]):
        if a <= a1:
            t = (a - a0) / (a1 - a0)
            if v0 > 0 and v1 > 0:
                return v0 * (v1 / v0) ** t   # geometric, so a wide median-to-max spread does not make the cap jumpy
            return v0 + (v1 - v0) * t
    return pts[-1][1]


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
    vc_engagement_basis: str = "phi"    # "phi": (φe/π)^−k; "ae": (ae/D)^−k (calibration, step 4)
    vc_hb_ref: Optional[float] = None   # hardness the speed anchor is quoted at (None: hb_ref)
    vc_diameter_exp: float = 0.0        # C7 level ×(min(D, vc_d_knee_in)/vc_d_knee_in)^m (calibration, step 4)
    vc_d_knee_in: float = 1.0
    family: Optional[str] = None        # GWizard family, for the C14 vendor-consensus lookup
    taylor_n: float = 0.25              # PLACEHOLDER
    k_r: float = 0.4                    # PLACEHOLDER
    k_te: float = 0.0                   # edge force N/mm (calibration; 0 reproduces Sandvik)
    k_re: float = 0.0
    tool_factor: float = 1.0            # PLACEHOLDER
    h_tooth_c: Optional[float] = None   # override C2: h_tooth = c·D^n (mm); None = the chip invariant
    h_tooth_n: float = 1.0
    c2_scale: float = 1.0               # multiplies C2's limit (robustness scenarios)
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
        """C2's nominal limit from h_tooth_c (None when C2 uses the chip invariant)."""
        return None if self.h_tooth_c is None else self.c2_scale * self.h_tooth_c * D_mm ** self.h_tooth_n

    def lam(self, aggressiveness):
        lo, hi = self.lambda_range
        return hi - aggressiveness * (hi - lo)


def material_17_4(hb=356.0, **overrides):
    """17-4 PH (any condition) as P5.0.Z.AN 1800/0.21 at 200 HB, scaled to hb (user decision 2026-10-15).

    H1025 is 356 HB (ToolWiz alloy table, '17-4 PH', 'H 1025').
    """
    kw = dict(name=f"17-4 PH, {hb:g} HB (P5.0.Z.AN scaled)", kienzle=forces.load_kienzle("P5.0.Z.AN"),
              hb_ref=200.0, hb=float(hb), family="Stainless - PH Series (17-4)")
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
    core_ratio: Optional[float] = None  # None: CORE_RATIO_BY_FLUTES (only for stress_section "core")
    stress_section: str = "fluted"      # C4 flute-root section: "fluted" (same I as C3) or "core"
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
    # Spindle + holder compliance in series with the tool (C3), at the holder face: translational stiffness
    # (N/µm) and tilting stiffness (N·m/µrad). None = rigid (the step-3 model).
    holder_k_n_um: Optional[float] = None
    holder_ktheta_nm_urad: Optional[float] = None
    holder_basis: str = ""

    def holder_compliance_mm(self, lever_mm):
        """Deflection (mm per N) at a load lever_mm out from the holder face: 1/k + L²/k_θ."""
        c = 0.0
        if self.holder_k_n_um:
            c += 1.0 / (self.holder_k_n_um * 1000.0)
        if self.holder_ktheta_nm_urad:
            c += (lever_mm / 1000.0) ** 2 / (self.holder_ktheta_nm_urad * 1e6) * 1000.0
        return c


def speedio_16k(tir_in=0.0002, rating="continuous", runout_model="eccentric", holder=False):
    """Brother Speedio S500X2 with the 16k non-dual-contact spindle (machines/speedio_s500x2.json).

    holder=True adds the profile's spindle/holder stiffness (`holder_stiffness`: k N/µm, k_θ N·m/µrad) in series
    with the tool in C3; False keeps the step-3 rigid holder."""
    with open(os.path.join(machine_profiles.BUILTIN_DIR, "speedio_s500x2.json"), encoding="utf-8") as fh:
        prof = json.load(fh)
    sp = prof["spindle_options"]["optional_16k"]
    feed = prof.get("max_cutting_feed_mm_min")
    m = Machine(sp, float(sp["max_rpm"]), rating, float(tir_in), runout_model, "Speedio S500X2 16k",
                feed / MM_PER_IN if feed else None)
    hs = prof.get("holder_stiffness") if holder else None
    if hs:
        m = replace(m, holder_k_n_um=hs.get("k_n_um"), holder_ktheta_nm_urad=hs.get("ktheta_nm_urad"),
                    holder_basis=hs.get("status", ""))
    return m


# Consensus aggressiveness (user, 2026-10-17): the scale on the vendor-median C7 speed level, the C2 chip limit
# and the C14 caps. 75 % ≈ the vendor median, 50 % (default, the Speedio BT30 starting point) a little below,
# 100 % = vendors' "may increase 10–20 %" (low end), 0 % = the vendors' lower quartile. Monotone cubic
# (Fritsch–Carlson) between the points.
CONSENSUS_SCALE_POINTS = ((0.0, 0.76), (0.5, 0.92), (0.75, 1.00), (1.0, 1.10))
# C4 under the consensus scheme: never above the physics limit (fatigue 0.375·TRS); at a = 0 the lower cited
# fully reversed level 0.33·TRS (Schleinkofer 1996 via Preis 2004) = 0.88 of it. Linear.
CONSENSUS_STRESS_POINTS = ((0.0, 0.88), (1.0, 1.0))
# C1 under the consensus scheme: λ is fixed (C1 is never relaxed by aggressiveness), the centre of the
# sourced 0.2–0.4 (the step-3 value at a = 0.5).
CONSENSUS_LAMBDA = 0.3
MARGIN_SCHEMES = ("legacy", "consensus")


def pchip(points, x):
    """Monotone cubic Hermite interpolation (Fritsch & Carlson 1980) through (x, y) points; clamped."""
    xs, ys = [p[0] for p in points], [p[1] for p in points]
    if x <= xs[0]:
        return ys[0]
    if x >= xs[-1]:
        return ys[-1]
    n = len(xs)
    if n == 2:
        return ys[0] + (ys[1] - ys[0]) * (x - xs[0]) / (xs[1] - xs[0])
    h = [xs[i + 1] - xs[i] for i in range(n - 1)]
    d = [(ys[i + 1] - ys[i]) / h[i] for i in range(n - 1)]
    m = [0.0] * n
    for i in range(1, n - 1):
        if d[i - 1] * d[i] > 0:
            w1, w2 = 2 * h[i] + h[i - 1], h[i] + 2 * h[i - 1]
            m[i] = (w1 + w2) / (w1 / d[i - 1] + w2 / d[i])
    m[0] = ((2 * h[0] + h[1]) * d[0] - h[0] * d[1]) / (h[0] + h[1])
    if m[0] * d[0] <= 0:
        m[0] = 0.0
    elif d[0] * d[1] <= 0 and abs(m[0]) > abs(3 * d[0]):
        m[0] = 3 * d[0]
    m[-1] = ((2 * h[-1] + h[-2]) * d[-1] - h[-1] * d[-2]) / (h[-1] + h[-2])
    if m[-1] * d[-1] <= 0:
        m[-1] = 0.0
    elif d[-1] * d[-2] <= 0 and abs(m[-1]) > abs(3 * d[-1]):
        m[-1] = 3 * d[-1]
    i = max(k for k in range(n - 1) if xs[k] <= x)
    t = (x - xs[i]) / h[i]
    h00, h10 = 2 * t ** 3 - 3 * t ** 2 + 1, t ** 3 - 2 * t ** 2 + t
    h01, h11 = -2 * t ** 3 + 3 * t ** 2, t ** 3 - t ** 2
    return h00 * ys[i] + h10 * h[i] * m[i] + h01 * ys[i + 1] + h11 * h[i] * m[i + 1]


def consensus_scale(aggressiveness):
    return pchip(CONSENSUS_SCALE_POINTS, aggressiveness)


@dataclass(frozen=True)
class Margins:
    """Safety margins from aggressiveness a ∈ [0, 1] (design §3.6).

    scheme "legacy" (the step-3 default, a placeholder): C2 and C4 ×(0.7 + 0.6·a), tool life ×4^(0.5 − a), λ
    from 0.4 to 0.2. scheme "consensus" (user, 2026-10-17): the C7 speed level, the C2 chip limit and the C14
    caps ×consensus_scale(a) (1.00 at a = 0.75, the vendor median); C4 ≤ the fatigue limit
    (×0.88…1.0); λ fixed. Physics limits (C1, C3, C4, C5, C9) are never relaxed by aggressiveness there.
    """
    aggressiveness: float = 0.5
    limit_scale: float = None           # on the C2 limit (and C4 under "legacy")
    life_ratio: float = None            # T / T_ref in C7
    limit_margin: float = None          # on C5
    scheme: str = "legacy"
    speed_scale: float = None           # on the C7 speed level ("consensus"; 1.0 under "legacy")
    stress_scale: float = None          # on the C4 fatigue limit (None: limit_scale)
    lambda_value: float = None          # fixed λ for C1 (None: the material's range by aggressiveness)
    consensus_cap_scale: float = None   # C14: caps at this × the vendor median

    def __post_init__(self):
        a = self.aggressiveness
        if not 0.0 <= a <= 1.0:
            raise ValueError("aggressiveness must be in [0, 1]")
        if self.scheme not in MARGIN_SCHEMES:
            raise ValueError(f"scheme must be one of {MARGIN_SCHEMES}")
        cons = self.scheme == "consensus"
        s = consensus_scale(a)
        defaults = {
            "limit_scale": s if cons else 0.7 + 0.6 * a,
            "life_ratio": 1.0 if cons else 4.0 ** (0.5 - a),
            "limit_margin": 0.2 * (1.0 - a),
            "speed_scale": s if cons else 1.0,
            "stress_scale": pchip(CONSENSUS_STRESS_POINTS, a) if cons else None,
            "lambda_value": CONSENSUS_LAMBDA if cons else None,
            "consensus_cap_scale": s,
        }
        for k, v in defaults.items():
            if getattr(self, k) is None:
                object.__setattr__(self, k, v)


# ---------------------------------------------------------------------------
# Constraint records
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Check:
    """One constraint at one cut. kind 'max': value ≤ limit; 'min': value ≥ limit; 'info': a derating
    (C9) reported against its onset, never violated; 'target': a goal (finishing wall tolerance) whose
    shortfall is reported, never a violation."""
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
        if self.kind in ("max", "info", "target"):
            return (self.limit - self.value) / self.limit if self.limit else -math.inf
        if self.limit <= 0:
            return math.inf
        return (self.value - self.limit) / self.limit

    @property
    def ok(self):
        m = self.margin
        return True if (m is None or self.kind in ("info", "target")) else m >= -1e-9

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


def c2_tooth_strength(h_worst_mm, h_tooth_mm, scale=1.0, basis="", what="worst flute h_max", cid="C2"):
    """C2: the chip (by default the worst flute's maximum chip) ≤ scale·h_tooth."""
    lim = h_tooth_mm * scale
    return Check(cid, "worst-flute chip" if cid == "C2" and what.startswith("worst") else what, "max",
                 h_worst_mm, lim, "mm", SRC["C2"],
                 detail=f"limit {h_tooth_mm * 1000:.3g} µm ×{scale:.2f} = {lim * 1000:.3g} µm"
                        + (f" ({basis})" if basis else "") + f"; {what} = {h_worst_mm * 1000:.3g} µm")


def c3_deflection(delta_in, allow_in, load_at_in=None, what="δ_tip", kind="max"):
    """C3: the largest tip deflection over a revolution, each load at its centroid, ≤ δ_allow.

    For finishing, the deflection normal to the wall against the user's wall tolerance.
    """
    where = f" (load at {load_at_in:.4f}\" from the tip)" if load_at_in is not None else ""
    return Check("C3", "tool deflection", kind, delta_in, allow_in, "in", SRC["C3"],
                 detail=f"{what} = {delta_in:.6f}\"{where}; {'target' if kind == 'target' else 'allowed'} "
                        f"{allow_in:.6f}\"")


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


def c6_geometry(ap_in, ae_in, D_in, lcf_in, depth_in=None, slot=False, flute_exposed_in=None):
    """C6: ap ≤ min(LCF, exposed flute, depth) and ae ≤ D; value is the larger of ap/ap_max and ae/D (ap only
    for a slot, where ae = D by definition). The exposed flute is the fluted length outside the holder
    (ToolProfile: min(LCF, stickout))."""
    ap_max = min(x for x in (lcf_in, depth_in, flute_exposed_in) if x)
    ratio = ap_in / ap_max if slot and ae_in <= D_in * (1 + 1e-9) else max(ap_in / ap_max, ae_in / D_in)
    return Check("C6", "geometry", "max", ratio, 1.0, "fraction", SRC["C6"],
                 detail=f"ap {ap_in:.4f}\" of {ap_max:.4f}\" ("
                        f"{'depth' if depth_in and depth_in <= ap_max + 1e-12 else 'flute outside the holder' if flute_exposed_in and flute_exposed_in < lcf_in - 1e-12 else 'LCF'}); "
                        f"ae {ae_in:.4f}\" of D {D_in:.4f}\"")


def engagement_speed_factor(material, phi_e):
    """C7's engagement factor: (φe/π)^(−k) (basis "phi") or (ae/D)^(−k) (basis "ae"), 1 for a slot.

    The engagement is held at or above ae = vc_engagement_ae_min·D: no speed credit beyond the data.
    """
    if material.vc_engagement_basis == "ae":
        ae_over_d = (1.0 - math.cos(phi_e)) / 2.0
        return max(ae_over_d, material.vc_engagement_ae_min) ** (-material.vc_engagement_exp)
    if material.vc_engagement_basis != "phi":
        raise ValueError("vc_engagement_basis must be 'phi' or 'ae'")
    floor = forces.engagement_angle(material.vc_engagement_ae_min, 1.0)
    return (max(phi_e, floor) / math.pi) ** (-material.vc_engagement_exp)


def diameter_speed_factor(material, D_mm):
    """C7 level's diameter term (min(D, D_knee)/D_knee)^m; 1 when m = 0 or D is not given."""
    if not material.vc_diameter_exp or D_mm is None:
        return 1.0
    knee = material.vc_d_knee_in * MM_PER_IN
    return (min(D_mm, knee) / knee) ** material.vc_diameter_exp


def taylor_speed_m_min(material, phi_e, life_ratio=1.0, D_mm=None, speed_scale=1.0):
    """C7 speed: v_ref·(HB_ref/HB)^q·g(engagement)·f(D)·(T/T_ref)^(−n)·s, m/min.

    g is `engagement_speed_factor`. By default (basis "phi") φe is held at or above the engagement of
    ae = vc_engagement_ae_min·D (0.1·D, the lightest engagement in Sandvik's Dura sheet): the placeholder
    exponent gives no speed credit beyond its data. HB_ref is vc_hb_ref when given, else hb_ref. f(D) is
    `diameter_speed_factor`. s is the consensus scheme's speed scale (the tool-life target expressed as speed,
    T/T_ref = s^(−1/n)).
    """
    v = material.vc_ref_sfm / FT_PER_M
    v *= ((material.vc_hb_ref or material.hb_ref) / material.hb) ** material.vc_hardness_exp
    v *= engagement_speed_factor(material, phi_e)
    v *= diameter_speed_factor(material, D_mm)
    v *= life_ratio ** (-material.taylor_n)
    return v * speed_scale


def c7_speed(material, phi_e, D_mm, max_rpm, life_ratio=1.0, reach_factor=1.0, speed_scale=1.0):
    """C7: v_c from tool life (and the C9 factor); rpm = v_c/(π·D), capped at the machine's max.

    Returns (rpm_used, v_c_m_min_used, Check, rpm_tool_life). The check's value is the rpm used, so it binds
    (margin 0) when the spindle's max rpm caps the tool-life speed.
    """
    vc_life = taylor_speed_m_min(material, phi_e, life_ratio, D_mm, speed_scale) * reach_factor
    rpm_want = 1000.0 * vc_life / (math.pi * D_mm)
    rpm = min(rpm_want, max_rpm)
    vc = math.pi * D_mm * rpm / 1000.0
    chk = Check("C7", "speed (tool life, rpm cap)", "max", rpm, max_rpm, "rpm", SRC["C7"],
                detail=f"v_c = {material.vc_ref_sfm:g} SFM·({material.vc_hb_ref or material.hb_ref:g}/{material.hb:g})^"
                       f"{material.vc_hardness_exp:g}·" + (
                           f"(ae/D = {(1.0 - math.cos(phi_e)) / 2.0:.3f}, ≥ {material.vc_engagement_ae_min:g})"
                           if material.vc_engagement_basis == "ae" else f"(φe/π = {phi_e / math.pi:.3f})")
                       + f"^−{material.vc_engagement_exp:g}"
                       + (f"·D-term {diameter_speed_factor(material, D_mm):.3f}" if material.vc_diameter_exp else "")
                       + f"·(T/T_ref = {life_ratio:.2f})^−{material.taylor_n:g}"
                       + (f"·consensus scale {speed_scale:.3f} (T/T_ref = {speed_scale ** (-1.0 / material.taylor_n):.2f})"
                          if speed_scale != 1.0 else "")
                       + f"·C9 {reach_factor:.2f} = "
                       f"{vc_life * FT_PER_M:.0f} SFM → {rpm_want:.0f} rpm; used {rpm:.0f} rpm "
                       f"({vc * FT_PER_M:.0f} SFM)")
    return rpm, vc, chk, rpm_want


def c7_check(rpm, rpm_life, max_rpm, detail=""):
    """C7 at a given rpm: ≤ the machine's max and ≤ the tool-life speed (a faster spindle shortens life)."""
    lim, why = (max_rpm, "machine max") if rpm <= rpm_life * (1.0 + 1e-6) else (min(max_rpm, rpm_life),
                                                                                 "tool-life speed")
    return Check("C7", "speed (tool life, rpm cap)", "max", rpm, lim, "rpm", SRC["C7"],
                 detail=f"rpm {rpm:.0f} given; limit {lim:.0f} ({why}); tool life asks {rpm_life:.0f}. " + detail)


def slot_depth_ratio(D_in, table=None, family=None, hb=None, aggressiveness=0.5, operation="slot"):
    """The slot depth cap ap/D. With an engagement-envelope `table` (data/model_v2/engagement_envelope.json) it reads
    the vendor rows of the material's group and the diameter band (p25 → median → max by aggressiveness); without
    one, the legacy micro-tool table (None at and above 1/8")."""
    if table is not None:
        return depth_cap_over_D(envelope_bucket(table, family, hb, D_in, operation), aggressiveness)
    for below, k in SLOT_DEPTH_RATIO_MICRO:
        if D_in < below - 1e-9:
            return k
    return None


def c8_slot_depth(ap_in, D_in, operation, k_slot=None):
    """C8: depth ap ≤ k_slot·D.

    k_slot given (the vendor engagement envelope, `depth_cap_over_D`): it caps slots, adaptive and roughing of any
    diameter. Without it, the legacy rule: a full slot (or roughing) of a micro tool (D < 1/8") ≤ the micro table.
    """
    given = k_slot is not None
    k = k_slot if given else slot_depth_ratio(D_in)
    applies = given or (operation == "slot" and k is not None) or (
        operation == "rough" and D_in < 0.0625 - 1e-9 and k is not None
    )
    lim = k * D_in if applies else None
    what = "depth cap (vendor engagement envelope)" if given else "micro slot depth (chip packing)"
    return Check("C8", what, "max", ap_in, lim, "in", SRC["C8"], applies=applies,
                 detail=(f"k = {k:.3f} → {lim:.4f}\"" if applies else "not a micro full slot"))


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


def program_bytes(ap_in, ae_in, volume_in3=1.0, spacing_mm=POINT_SPACING_MM,
                  bytes_per_line=BYTES_PER_LINE, linking=LINKING_FACTOR):
    """Estimated NC program size: bytes_per_line · L_cut / s with L_cut = V/(ap·ae)·(1 + linking).

    L_cut in mm (25.4·in), s in mm. With the defaults that is 2,667 bytes per inch of cutting path at
    s = 0.22 mm (the user's 2,860 corresponds to s ≈ 0.205 mm) and 14,669 at s = 0.04 mm.
    """
    l_cut_in = volume_in3 / (ap_in * ae_in) * (1.0 + linking)
    return bytes_per_line * l_cut_in * MM_PER_IN / spacing_mm


def c13_program_size(ap_in, ae_in, volume_in3, limit_bytes, spacing_mm=POINT_SPACING_MM):
    """C13 (optional): estimated program size for the operation's removal volume ≤ the user's limit."""
    applies = bool(limit_bytes and volume_in3)
    size = program_bytes(ap_in, ae_in, volume_in3 or 1.0, spacing_mm)
    return Check("C13", "program size", "max", size, limit_bytes if applies else None, "bytes", SRC["C13"],
                 applies=applies,
                 detail=(f"{size / 1e6:.2f} MB for {volume_in3:g} in³ at s = {spacing_mm:g} mm; limit "
                         f"{limit_bytes / 1e6:.1f} MB" if applies else
                         f"{size / 1e6:.2f} MB per in³ at s = {spacing_mm:g} mm (limit off)"))


# C14: vendor-consensus guardrail (user, 2026-10-17). data/model_v2/consensus.json (tools/calibrate_v2.py) holds,
# per bucket (family, hardness bin, diameter band, operation class, engagement class), each vendor group's median
# SFM, fz/D and MRR/D³ and their median over the groups (the vendor median, each group counted once).
CONSENSUS_OPERATION = {"slot": "slot", "rough": "side", "adaptive": "hem", "finish": "finish"}
SRC["C14"] = ("Vendor consensus (user decisions 2026-10-17): speed, chip load and MRR (per unit engaged area and flute) "
              "≤ consensus_scale(a) × the vendor median of the matching bucket (family, hardness, diameter band, "
              "operation, engagement) with ≥ 2 independent vendor groups, widened stepwise (diameter band, engagement, "
              "hardness) when fewer; data/model_v2/consensus.json from the benchmark rows; none → the physics result")


SRC["C14lo"] = ("Chip-load floor (V3 M3, owner decision D9): fz ≥ 50 % of the vendor-consensus median fz of the bucket, "
                "else 2 × the C1 rubbing limit; relaxed to 1 × the rubbing limit, with a warning, where C3/C4 force "
                "the chip below the floor at every depth (long stickout)")


def load_consensus(path):
    return _limits(path)


def engagement_class(ae_over_D, edges):
    for name, lo, hi in edges:
        if lo <= ae_over_D < hi:
            return name
    return edges[-1][0]


CONSENSUS_MIN_GROUPS = 2   # user decision 2026-10-17 (R-C): ≥ 2 independent vendor groups (Harvey + Helical = one)
CONSENSUS_WIDENING = ("exact bucket", "+ neighbouring diameter band", "+ neighbouring engagement class",
                      "+ neighbouring hardness bin")
# Row values stored per cell and vendor group in consensus.json: [SFM, fz/D, fz·n (in/min), MRR/D³].
CONSENSUS_FIELDS = ("sfm", "fz_over_D", "feed_per_flute_ipm", "mrr_over_D3")


def _neighbours(names, name, widen):
    i = names.index(name) if name in names else None
    if i is None:
        return [name]
    return names[max(0, i - 1):i + 2] if widen else [name]


def consensus_lookup(table, family, hb, D_in, operation, ae_over_D, min_groups=None):
    """The vendor consensus for a cut (user decisions 2026-10-17, R-C).

    The exact bucket is (family, 50-HB bin, diameter band, operation class, engagement class). With fewer than
    `min_groups` independent vendor groups it widens stepwise and cumulatively: the neighbouring diameter bands,
    then the neighbouring engagement classes, then the neighbouring hardness bins. Each vendor group's median is
    taken over its pooled rows, then the median over the groups. Returns None when even the widest step has too
    few groups (the caller then uses the physics result and says so)."""
    min_groups = min_groups or table.get("min_vendor_groups", CONSENSUS_MIN_GROUPS)
    band = _band_for(table["bands"], D_in)
    if band is None:
        return None
    bands = [b["band"] for b in table["bands"]]
    engs = [e[0] for e in table["engagement_classes"]]
    eng = engagement_class(ae_over_D, table["engagement_classes"])
    opc = CONSENSUS_OPERATION.get(operation, operation)
    hbin = int(hb // table["hb_bin"])
    cells = table["cells"]
    for step, label in enumerate(CONSENSUS_WIDENING):
        bset = _neighbours(bands, band["band"], step >= 1)
        eset = _neighbours(engs, eng, step >= 2)
        hset = [hbin - 1, hbin, hbin + 1] if step >= 3 else [hbin]
        pooled, used = {}, []
        for b in bset:
            for e in eset:
                for h in hset:
                    key = "|".join((family, str(h), b, opc, e))
                    c = cells.get(key)
                    if c:
                        used.append(key)
                        for vg, rows in c.items():
                            pooled.setdefault(vg, []).extend(rows)
        if len(pooled) < min_groups:
            continue
        out = {}
        for i, f in enumerate(CONSENSUS_FIELDS):
            meds = [_median([r[i] for r in rows]) for rows in pooled.values()]
            out[f] = _median(meds)
        exact = "|".join((family, str(hbin), band["band"], opc, eng))
        return dict(out, key=exact, widening=label, step=step, cells=used, vendor_groups=sorted(pooled),
                    n_rows=sum(len(r) for r in pooled.values()))
    return None


def _median(vals):
    v = sorted(vals)
    n = len(v)
    return v[n // 2] if n % 2 else 0.5 * (v[n // 2 - 1] + v[n // 2])


def _c14_detail(cons, what):
    groups = cons["vendor_groups"]
    return (f"{what}; bucket {cons['key']}, {cons['widening']} ({cons['n_rows']} rows, {len(groups)} vendor groups: "
            f"{', '.join(groups)})")


def c14_speed(pt, rpm_given=False):
    """C14v: SFM ≤ scale × the bucket's vendor-median SFM. Caps the C7 speed; a given rpm is only checked."""
    ctx, cons = pt.ctx, pt.cons
    if not cons:
        return Check("C14v", "vendor-consensus speed", "max", 0.0, None, "SFM", SRC["C14"], applies=False,
                     detail=(f"fewer than {ctx.consensus.get('min_vendor_groups', CONSENSUS_MIN_GROUPS)} vendor groups "
                             f"match this cut even after widening (band, engagement, hardness); the physics (C7) "
                             f"speed and limits stand" if ctx.consensus else "consensus guardrail off"))
    s = ctx.mg.consensus_cap_scale
    med = cons["sfm"]
    cap_sfm = s * med
    D_in = ctx.tool.D
    sfm = math.pi * D_in * pt.rpm / 12.0
    if sfm > cap_sfm * (1 + 1e-9) and not rpm_given:
        pt.rpm = 12.0 * cap_sfm / (math.pi * D_in)
        sfm = cap_sfm
    return Check("C14v", "vendor-consensus speed", "max", sfm, cap_sfm, "SFM", SRC["C14"],
                 detail=_c14_detail(cons, f"SFM {sfm:.0f} vs {s:.2f} × vendor median {med:.0f} = {cap_sfm:.0f}"))


def c14_feed_checks(pt, fz_in):
    ctx, cons = pt.ctx, pt.cons
    if not cons:
        return {}
    s = ctx.mg.consensus_cap_scale
    D = ctx.tool.D
    fz_med = cons["fz_over_D"] * D
    mrr = pt.mrr_in3_min(fz_in)
    if "feed_per_flute_ipm" in cons:
        # MRR like-for-like: per unit engaged area (ap·ae) and per flute, i.e. the feed per flute fz·n (in/min),
        # which is scale-free in D. Vendors' depth follows their own flute length, ae varies inside an engagement
        # class and their flute counts differ, so depth, width and z are left to the physics limits (C3, C4, C6).
        # In MRR terms the cap at this cut is scale × median(fz·n)·z·ap·ae.
        mrr_med = cons["feed_per_flute_ipm"] * ctx.tool.z * pt.ap * pt.ae
    else:
        mrr_med = cons["mrr_over_D3"] * D ** 3
    return {
        "C14f": Check("C14f", "vendor-consensus chip load", "max", fz_in, s * fz_med, "in", SRC["C14"],
                      detail=_c14_detail(cons, f"fz {fz_in:.6f}\" vs {s:.2f} × vendor median {fz_med:.6f}\"")),
        "C14m": Check("C14m", "vendor-consensus MRR", "max", mrr, s * mrr_med, "in³/min", SRC["C14"],
                      detail=_c14_detail(cons, f"MRR {mrr:.4f} vs {s:.2f} × vendor median {mrr_med:.4f} in³/min")),
    }


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
    """The Round 2 vendor-median C3/C4 band for a diameter (reported only since Round 4)."""
    data = _limits(path or LIMITS_PATH)
    for band in data["bands"]:
        if band["d_min"] <= D_in < band["d_max"]:
            return band
    return data["bands"][-1] if D_in >= data["bands"][-1]["d_min"] else data["bands"][0]


def _band_for(bands, D_in):
    for band in bands:
        if band["d_min"] <= D_in < band["d_max"]:
            return band
    if not bands:
        return None
    return bands[-1] if D_in >= bands[-1]["d_min"] else bands[0]


def chip_limit(D_in, path=None, key="bands"):
    """C2's band for a diameter: {"band", "h_worst_over_D" (median), "p10", "p90", "n"}.

    key: "bands" (side/rough/HEM worst-flute chip, the default C2), "slot_bands", "nominal_bands",
    "slot_nominal_bands" (runout-free fz·sin φe, for the Round 5 alternative basis).
    """
    return _band_for(_limits(path or CHIP_LIMITS_PATH)[key], D_in)


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


STRESS_SECTIONS = ("fluted", "core")


def section_props(d_in, fluted, flutes=4, helix_deg=30.0, section="fluted", core_ratio=0.6):
    """(I mm⁴, c mm) of a section for bending stress σ = M·c/I.

    Solid sections are circles. A fluted section is, by default ("fluted", Round 3), the same section the
    deflection uses (v1 BeamDeflectionEngine.fluted_core_inertia, about a 0.8·D equivalent cylinder for
    4 flutes, as Kops & Vo 1990 report for end mill compliance) with the outer fibre at D/2. "core" is
    the Round 1–2 model: the core circle d = core_ratio·D alone.
    """
    d_mm = d_in * MM_PER_IN
    if not fluted:
        return math.pi * d_mm ** 4 / 64.0, d_mm / 2.0
    if section == "core":
        dc = core_ratio * d_mm
        return math.pi * dc ** 4 / 64.0, dc / 2.0
    if section == "fluted":
        return BeamDeflectionEngine.fluted_core_inertia(d_in, flutes, helix_deg) * MM_PER_IN ** 4, d_mm / 2.0
    raise ValueError(f"section must be one of {STRESS_SECTIONS}")


def critical_sections(segments, flutes=4, helix_deg=30.0, section="fluted", core_ratio=0.6):
    """(x in, kind, I mm⁴, c mm) at the far end of every segment, plus a tapered segment's narrow start.

    Within a constant section the moment grows toward the holder, so each segment's far end is its
    critical point: the flute root at the top of the flutes, every diameter step, and the holder face.
    """
    out = []
    last = float(segments[-1].end) if segments else 0.0
    for sg in segments:
        pts = [(float(sg.end), float(sg.d1))]
        if abs(sg.d0 - sg.d1) > 1e-12:
            pts.append((float(sg.start), float(sg.d0)))
        for x, d in pts:
            I, c = section_props(d, sg.fluted, flutes, helix_deg, section, core_ratio)
            kind = "holder face" if x >= last - 1e-12 else ("flute root" if sg.fluted else f"{sg.kind} at step")
            out.append((x, kind, I, c))
    return out


def circle(d_mm):
    """(I, c) of a solid circle, for section_stress."""
    return math.pi * d_mm ** 4 / 64.0, d_mm / 2.0


def section_stress(force_n, load_at_in, torque_nm, x_in, I_mm4, c_mm):
    """σ = M·c/I, τ = T·c/J with J = 2I, σ1 = σ/2 + √((σ/2)² + τ²) at x (MPa); M = F·(x − a).

    For a circle these are 32·M/(π·d³) and 16·T/(π·d³).
    """
    m_nmm = force_n * max(x_in - load_at_in, 0.0) * MM_PER_IN
    sigma, tau = m_nmm * c_mm / I_mm4, abs(torque_nm) * 1000.0 * c_mm / (2.0 * I_mm4)
    return m_nmm, sigma, tau, sigma / 2.0 + math.hypot(sigma / 2.0, tau)


def bending_sections(segments, force_n, load_at_in, torque_nm=0.0, flutes=4, helix_deg=30.0,
                     section="fluted", core_ratio=0.6):
    """Stress at every critical section above the load, largest σ1 first (dicts)."""
    out = []
    for x, kind, I, c in critical_sections(segments, flutes, helix_deg, section, core_ratio):
        if x <= load_at_in + 1e-12:
            continue
        m, sigma, tau, s1 = section_stress(force_n, load_at_in, torque_nm, x, I, c)
        out.append({"kind": kind, "x_in": x, "d_eq_mm": (64.0 * I / math.pi) ** 0.25, "moment_nmm": m,
                    "sigma_mpa": sigma, "tau_mpa": tau, "sigma1_mpa": s1})
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
            cen_y = min(max(my / fy, 0.0), ap) if abs(fy) > 1e-12 else cen
            samples.append((math.sqrt(mag2), cen, t / 1000.0, fy, cen_y))
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


OPTION_DEFAULTS = {"deflection_allow": None, "stress_limit": None, "depth": None, "c1_flute": None,
                   "effective_feed_ipm": EFFECTIVE_ADAPTIVE_FEED_IPM, "k_tir": K_TIR, "limits_path": None,
                   "wall_tolerance_in": WALL_TOLERANCE_IN, "limit_program_size": False,
                   "program_limit_bytes": PROGRAM_LIMIT_BYTES, "removal_volume_in3": None,
                   "point_spacing_mm": POINT_SPACING_MM, "stock_to_leave_in": STOCK_TO_LEAVE_IN,
                   "chip_limit_over_D": None, "c2_basis": "worst", "part_tolerance_in": None,
                   "wall_metric": "ripple", "consensus": None, "envelope": None, "chip_floor": None,
                   "user_engagement": False, "n_phases": None, "ae_env_min": True}


class _Context:
    """Everything fixed for one tool, material, machine, operation, margin set and options.

    Options (OPTION_DEFAULTS):
      deflection_allow (in), stress_limit (MPa): override C3/C4.
      depth: the operation's real depth.
      c1_flute: "wall" (default for every operation: only the wall-generating flute must form a chip; flutes
        that rub are reported, `flutes_cutting`, and the optimizer prefers cuts where all flutes cut),
        "thinnest" (every flute forms a chip) or "worst".
      envelope: path or dict of data/model_v2/engagement_envelope.json (V3 M3): depth cap C8 from the vendor rows
        and the vendor medians the selection aims at. None: off.
      chip_floor: None (off), "vendor" (C14lo: fz ≥ 0.5 × the consensus median, else 2 × the rubbing limit) or
        "rubbing" (the relaxed floor, 1 × the rubbing limit).
      user_engagement: the (ap, ae) is the user's own, so the envelope depth cap and the chip floor are not applied.
      c2_basis: "worst" (adopted: worst-flute chip ≤ vendor median) or "nominal" (Round 5 alternative:
        runout-free chip fz·sin φe ≤ vendor median, plus C2o worst-flute chip ≤ vendor p90).
      effective_feed_ipm: C11's adaptive feed (None for none). k_tir: C12's k.
      wall_tolerance_in: finishing target; part_tolerance_in: optional hard limit; wall_metric "ripple"
        (default: the part Blum compensation cannot remove) or "max".
      stock_to_leave_in: roughing C3 = 50 % of it. C13 options: limit_program_size etc.
    Problems with data files are logged and listed in self.notes, never swallowed.
    """

    def __init__(self, tool, material, machine, operation, margins, n_theta=144, n_quad=48, **opts):
        unknown = set(opts) - set(OPTION_DEFAULTS)
        if unknown:
            raise TypeError(f"unknown options {sorted(unknown)}")
        o = dict(OPTION_DEFAULTS, **opts)
        if operation not in OPERATIONS:
            raise ValueError(f"operation must be one of {OPERATIONS}")
        if o["c1_flute"] is None:
            o["c1_flute"] = "wall"
        if o["c1_flute"] not in C1_FLUTES:
            raise ValueError(f"c1_flute must be one of {C1_FLUTES}")
        if o["c2_basis"] not in C2_BASES:
            raise ValueError(f"c2_basis must be one of {C2_BASES}")
        if o["wall_metric"] not in WALL_METRICS:
            raise ValueError(f"wall_metric must be one of {WALL_METRICS}")
        self.opts, self.notes = o, []
        self.c1_flute, self.depth, self.k_tir = o["c1_flute"], o["depth"], o["k_tir"]
        self.c2_basis, self.wall_metric = o["c2_basis"], o["wall_metric"]
        self.part_tolerance = o["part_tolerance_in"] if operation == "finish" else None
        self.tool, self.mat, self.mach, self.op, self.mg = tool, material, machine, operation, margins
        self.n_theta, self.n_quad = n_theta, n_quad
        self.coeffs = material.coefficients(tool.rake_deg)
        self.lam = margins.lambda_value if margins.lambda_value is not None else material.lam(margins.aggressiveness)
        tir_mm = machine.tir_in * MM_PER_IN
        self.n_phases = o["n_phases"] or N_RUNOUT_PHASES
        self._ctabs = {}   # compliance tables by ap, shared by every CutPoint of this context
        self.last_fz_hi = None   # the previous window's top, the start of the next search
        if machine.runout_model == "eccentric" and tir_mm > 0:
            self.phase_offsets = [forces.runout_offsets(tir_mm, tool.z, "eccentric",
                                                        2.0 * math.pi / tool.z * i / self.n_phases)
                                  for i in range(self.n_phases)]
        else:
            self.phase_offsets = [forces.runout_offsets(tir_mm, tool.z, machine.runout_model)]
        self.offsets_bound = forces.runout_offsets(tir_mm, tool.z, "bound")
        fl = [sg for sg in tool.segments if sg.fluted]
        self.flute_exposed = float(fl[-1].end) if fl else 0.0
        self.notes += [f"tool profile: {w}" for w in tool.profile.warnings]
        # C2: the chip invariant (or an explicit override).
        self.chip_band = self.h_nominal = self.h_overload = None
        self.h_nominal_basis = self.h_overload_basis = ""
        h_override = material.h_tooth_mm(tool.D_mm)
        kind = "slot" if operation == "slot" else "side"
        if o["chip_limit_over_D"] is not None:
            self.h_tooth = o["chip_limit_over_D"] * tool.D_mm * material.c2_scale
            self.h_tooth_basis = f"given {o['chip_limit_over_D']:g}·D"
        elif h_override is not None:
            self.h_tooth = h_override
            self.h_tooth_basis = f"override {material.h_tooth_c:g}·D^{material.h_tooth_n:g}"
        else:
            data = _limits(CHIP_LIMITS_PATH)
            cb = self._chip_band(data, kind, "worst")
            self.chip_band = cb
            self.h_tooth = cb["h_worst_over_D"] * tool.D_mm * material.c2_scale
            self.h_tooth_basis = (f"vendor median {cb['h_worst_over_D']:.5f}·D, {cb['source']} {cb['band']} "
                                  f"(n {cb['n']}; p10 {cb['p10']:.5f}, p90 {cb['p90']:.5f})")
            if abs(machine.tir_in - data.get("tir_in", machine.tir_in)) > 1e-9:
                self.notes.append(f"C2's chip invariant was built at TIR {data['tir_in']:.5f}\" (eccentric); this "
                                  f"machine's TIR is {machine.tir_in:.5f}\", so the worst-flute limit is not like-for-like")
            if self.c2_basis == "nominal":
                nb = self._chip_band(data, kind, "nominal")
                self.h_nominal = nb["h_worst_over_D"] * tool.D_mm * material.c2_scale
                self.h_nominal_basis = (f"vendor median nominal chip {nb['h_worst_over_D']:.5f}·D, {nb['source']} "
                                        f"{nb['band']} (n {nb['n']})")
                self.h_overload = cb["p90"] * tool.D_mm * material.c2_scale
                self.h_overload_basis = f"vendor p90 worst-flute chip {cb['p90']:.5f}·D ({cb['band']})"
        # C3
        if o["deflection_allow"] is not None:
            self.delta_allow, self.delta_basis = o["deflection_allow"], "given"
        elif operation == "finish":
            self.delta_allow = o["wall_tolerance_in"]
            self.delta_basis = (f"wall target {o['wall_tolerance_in'] * MM_PER_IN:.4f} mm on the {self.wall_metric} "
                                f"(user-set; a target, not pass/fail)")
        else:
            from physics_v2 import params
            k_d = params.c3_k(margins.aggressiveness)
            self.delta_soft = k_d * tool.D
            self.delta_allow = k_d * tool.D * (USER_C3_FACTOR if o["user_engagement"] else 1.0)
            self.delta_basis = (f"{k_d:.2%} of the diameter (k = 0.5 % + 1.0 % × aggressiveness; planner decision, "
                                f"round 2: no fixed stock-to-leave term; true-to-size comes from the finishing pass)"
                                + (f"; the user's own engagement may deflect up to {USER_C3_FACTOR:g}×k·D "
                                   f"(advisory up to there: a warning and more stock, fz reduced beyond)"
                                   if o["user_engagement"] else ""))
        if not hasattr(self, "delta_soft"):
            self.delta_soft = self.delta_allow
        # C4
        fatigue = tool.fatigue_fraction * tool.trs_mpa
        if o["stress_limit"] is not None:
            self.stress_limit, self.stress_basis = o["stress_limit"], "given"
        else:
            st = margins.stress_scale if margins.stress_scale is not None else margins.limit_scale
            self.stress_limit = fatigue * st
            self.stress_basis = (f"carbide fatigue 10⁷: {tool.fatigue_fraction:g}·{tool.trs_mpa:g} = {fatigue:.0f} MPa"
                                 f" ×{st:.2f}")
        # The Round 2 vendor-median limits, reported only.
        try:
            self.band = provisional_limits(tool.D, o["limits_path"])
        except (OSError, ValueError, KeyError) as exc:
            LOG.warning("vendor-median comparison unavailable: %s", exc)
            self.notes.append(f"vendor-median comparison unavailable ({type(exc).__name__}: {exc})")
            self.band = None
        self.feed_cap = o["effective_feed_ipm"] if operation == "adaptive" else None
        self.size_limit = (o["program_limit_bytes"] if o["limit_program_size"] and operation != "finish"
                           else None)
        if self.size_limit and not o["removal_volume_in3"]:
            raise ValueError("limit_program_size needs removal_volume_in3 (the operation's removal volume)")
        eq = BeamDeflectionEngine.equivalent_stickout(tool.segments, tool.D, tool.z, tool.helix_deg)
        self.eq_stickout = eq if eq else tool.stickout
        self.reach_factor, self.c9 = c9_stickout(self.eq_stickout, tool.D)
        self._speed = {}
        # V3 envelope: the vendor engagement medians the selection aims at and the depth cap (C8).
        self.envelope = None
        self.env_bucket = None
        self.depth_cap_ratio = None
        self.width_cap_ratio = None
        self.width_min_ratio = None
        self.user_engagement = bool(o["user_engagement"])
        if o["envelope"] is not None and operation != "finish":
            src = ENVELOPE_DEFAULT_PATH if o["envelope"] == "default" else o["envelope"]
            self.envelope = src if isinstance(src, dict) else _limits(src)
            self.env_bucket = envelope_bucket(self.envelope, material.family, material.hb, tool.D, operation)
            if self.env_bucket and not self.user_engagement:
                self.depth_cap_ratio = depth_cap_over_D(self.env_bucket, margins.aggressiveness)
                if operation in ("adaptive", "rough"):
                    self.width_cap_ratio = depth_cap_over_D(self.env_bucket, margins.aggressiveness, "ae_over_D")
                    if o["ae_env_min"]:
                        # At aggressiveness above 0.75 the minimum falls linearly to half of it at 1.0 (planner, round 4).
                        relax = 1.0 - 0.5 * min(max((margins.aggressiveness - 0.75) / 0.25, 0.0), 1.0)
                        self.width_min_ratio = self.env_bucket["ae_over_D"].get("min") * relax
            elif not self.env_bucket:
                self.notes.append("no vendor engagement envelope for this material group, operation and diameter "
                                  "band; depth is limited by the physics (C3, C4, C6) only")
        self.chip_floor = None if (self.user_engagement or operation == "finish") else o["chip_floor"]
        self.floor_scale = 1.0   # the final full-resolution check takes the floor 5 % lower (see optimize)
        if self.chip_floor not in (None, "vendor", "rubbing"):
            raise ValueError("chip_floor must be None, 'vendor' or 'rubbing'")
        self.h_min_mm = self.lam * tool.edge_radius_mm
        self.non_ferrous = material_group(material.family) == "non-ferrous"
        # C14: the vendor-consensus guardrail (user, 2026-10-17), on when a consensus table is given.
        self.consensus = None
        self._cons_cache = {}
        if o["consensus"] is not None:
            src = CONSENSUS_DEFAULT_PATH if o["consensus"] == "default" else o["consensus"]
            self.consensus = src if isinstance(src, dict) else load_consensus(src)
            if not material.family:
                self.notes.append("C14 inactive: the material names no family for the vendor-consensus lookup")
        if machine.holder_k_n_um or machine.holder_ktheta_nm_urad:
            self.notes.append(f"C3 includes the spindle/holder compliance in series with the tool: "
                              f"k {machine.holder_k_n_um or 0:g} N/µm, k_θ {machine.holder_ktheta_nm_urad or 0:g} N·m/µrad"
                              + (f" ({machine.holder_basis})" if machine.holder_basis else ""))

    def consensus_for(self, ae_in):
        """The C14 bucket for this cut (family, hardness, band, operation, engagement), or None."""
        if not self.consensus or not self.mat.family:
            return None
        aeD = ae_in / self.tool.D
        key = engagement_class(aeD, self.consensus["engagement_classes"])
        if key not in self._cons_cache:
            self._cons_cache[key] = consensus_lookup(self.consensus, self.mat.family, self.mat.hb, self.tool.D,
                                                     self.op, aeD)
        return self._cons_cache[key]

    def _chip_band(self, data, kind, basis):
        """The C2 band for this diameter: slot rows for slots when that band has data, else side rows."""
        key = {("side", "worst"): "bands", ("slot", "worst"): "slot_bands",
               ("side", "nominal"): "nominal_bands", ("slot", "nominal"): "slot_nominal_bands"}[(kind, basis)]
        for k in ((key, "bands" if basis == "worst" else "nominal_bands") if kind == "slot" else (key,)):
            band = _band_for(data.get(k) or [], self.tool.D)
            if band and band.get("n", 0) >= 3:
                if k != key:
                    self.notes.append(f"no slot chip data for {band['band']}; C2 uses the side/rough/HEM rows")
                return dict(band, source="slot rows" if k.startswith("slot") else "side/rough/HEM rows")
        raise ValueError(f"no chip-limit band for D {self.tool.D:g}\" in {CHIP_LIMITS_PATH}")

    def speed(self, ae_in):
        key = round(ae_in, 9)
        if key not in self._speed:
            phi_e = forces.engagement_angle(ae_in * MM_PER_IN, self.tool.D_mm)
            self._speed[key] = c7_speed(self.mat, phi_e, self.tool.D_mm, self.mach.max_rpm,
                                        self.mg.life_ratio, self.reach_factor, self.mg.speed_scale)
        return self._speed[key]


class CutPoint:
    """One (ap, ae) for a context: the fz-independent parts, and every check at a given fz."""

    def __init__(self, ctx, ap_in, ae_in, rpm=None):
        self.ctx, self.ap, self.ae = ctx, float(ap_in), float(ae_in)
        t = ctx.tool
        self.D_mm, self.ap_mm, self.ae_mm = t.D_mm, ap_in * MM_PER_IN, ae_in * MM_PER_IN
        rpm_used, _, c7, rpm_life = ctx.speed(ae_in)
        if rpm:
            # A caller-supplied speed is checked as it is: against the machine and the tool-life speed.
            self.rpm = float(rpm)
            self.c7 = c7_check(self.rpm, rpm_life, ctx.mach.max_rpm, c7.detail)
        else:
            self.rpm, self.c7 = rpm_used, c7
        # C14 (vendor consensus): the speed is capped at scale × the bucket's vendor-median SFM.
        self.cons = ctx.consensus_for(ae_in)
        self.c14v = c14_speed(self, rpm_given=bool(rpm))
        self.eng = Engagement(self.D_mm, t.z, self.ap_mm, self.ae_mm, t.helix_deg, t.climb)
        self.c6 = c6_geometry(self.ap, self.ae, t.D, t.lcf, ctx.depth, ctx.op == "slot", ctx.flute_exposed)
        self.c8 = (c8_slot_depth(self.ap, t.D, ctx.op, k_slot=ctx.depth_cap_ratio) if not ctx.user_engagement else
                   Check("C8", "depth cap (vendor engagement envelope)", "max", self.ap, None, "in", SRC["C8"],
                         applies=False, detail="the user's own depth; the vendor depth cap is a recommendation"))
        self.c12 = c12_radial_reach(self.ae, ctx.mach.tir_in, ctx.k_tir)
        self.c13 = c13_program_size(self.ap, self.ae, ctx.opts["removal_volume_in3"], ctx.size_limit,
                                    ctx.opts["point_spacing_mm"])
        self._ctab = None
        self._phase = {}

    # --- runout phase: C1 at the phase that thins its flute most, C2 and loads where the worst chip peaks
    def _phase_chips(self, fz_in):
        key = round(fz_in, 12)
        if key not in self._phase:
            fz = fz_in * MM_PER_IN
            self._phase[key] = [(offs, self.eng.max_chips(fz, offs)) for offs in self.ctx.phase_offsets]
        return self._phase[key]

    def c1_chip(self, chips, offs):
        mode = self.ctx.c1_flute
        if mode == "worst":
            return max(chips)
        if mode == "wall":
            return chips[max(range(len(chips)), key=lambda k: offs[k])]
        return min(chips)

    def chips_c1(self, fz_in):
        """(chips, offsets) at the runout phase where C1's flute has its smallest chip."""
        return min(((ch, offs) for offs, ch in self._phase_chips(fz_in)), key=lambda p: self.c1_chip(*p))

    def chips_c2(self, fz_in):
        """(chips, offsets) at the runout phase where the worst flute's chip is largest (C2, loads)."""
        return max(((ch, offs) for offs, ch in self._phase_chips(fz_in)), key=lambda p: max(p[0]))

    def max_chips_mm(self, fz_in):
        return self.chips_c2(fz_in)[0]

    def loads(self, fz_in):
        ctx = self.ctx
        f = self.eng.loads(fz_in * MM_PER_IN, self.chips_c2(fz_in)[1], ctx.coeffs, ctx.n_theta, ctx.n_quad)
        f["power_kw"] = max(f["torque_mean_nm"], 0.0) * machine_profiles.rad_s(self.rpm) / 1000.0
        return f

    def _compliance(self, a_in):
        """∫ (x − a)·x/I dx for a load at a (tip deflection), interpolated on a table over [0, ap]."""
        if self._ctab is None:
            key = round(self.ap, 9)
            if key not in self.ctx._ctabs:
                t, n = self.ctx.tool, 40
                self.ctx._ctabs[key] = [compliance_integral(t.segments, self.ap * i / n, 0.0, t.z, t.helix_deg)
                                        for i in range(n + 1)]
            self._ctab = self.ctx._ctabs[key]
        n = len(self._ctab) - 1
        x = min(max(a_in / self.ap * n, 0.0), n)
        i = min(int(x), n - 1)
        return self._ctab[i] + (x - i) * (self._ctab[i + 1] - self._ctab[i])

    def _beam(self, f):
        """Largest tip deflection and largest σ1 over the revolution (the load band moves with the helix).

        Also the wall error: the tip deflection normal to the wall (Altintas's y; positive = pushed off the
        wall, stock left), from F_y at the centroid of F_y alone (M_y/F_y), as its largest magnitude, its
        mean (systematic, what Blum wear compensation can take out) and its ripple over a revolution
        (max − min, what it cannot).
        """
        t = self.ctx.tool
        samples = f["samples"]
        delta, gov_d = -1.0, None
        walls = []
        mach = self.ctx.mach
        holder = bool(mach.holder_k_n_um or mach.holder_ktheta_nm_urad)
        so_mm = t.stickout * MM_PER_IN
        for mag, cen, tq, fy, cen_y in samples:
            a_in = cen / MM_PER_IN
            d = mag * self._compliance(a_in) / t.E_psi / N_PER_LBF
            w = fy * self._compliance(cen_y / MM_PER_IN) / t.E_psi / N_PER_LBF
            if holder:
                # Spindle/holder in series: the holder face moves and tilts under the load (lever from it).
                d += mag * mach.holder_compliance_mm(so_mm - cen) / MM_PER_IN
                w += fy * mach.holder_compliance_mm(so_mm - cen_y) / MM_PER_IN
            walls.append(w)
            if d > delta:
                delta, gov_d = d, (mag, a_in, tq)
        s1_max, gov_s = -1.0, None
        for x, kind, I, c in critical_sections(t.segments, t.z, t.helix_deg, t.stress_section, t.core()):
            for mag, cen, tq, _, _ in samples:
                a_in = cen / MM_PER_IN
                if x <= a_in:
                    continue
                s1 = section_stress(mag, a_in, tq, x, I, c)[3]
                if s1 > s1_max:
                    s1_max, gov_s = s1, (mag, a_in, tq)
        gov_s = gov_s or gov_d
        secs = bending_sections(t.segments, gov_s[0], gov_s[1], gov_s[2], t.z, t.helix_deg, t.stress_section,
                                t.core())
        wall = {"max_in": max(abs(w) for w in walls), "mean_in": sum(walls) / len(walls),
                "ripple_in": max(walls) - min(walls)}
        return {"delta_in": max(delta, 0.0), "wall": wall, "delta_load_n": gov_d[0], "delta_load_at_in": gov_d[1],
                "stress_load_n": gov_s[0], "stress_load_at_in": gov_s[1], "sections": secs}

    # --- checks ----------------------------------------------------------
    def c2_checks(self, fz_in):
        """C2 (and, on the nominal basis, C2o): the chip limits."""
        ctx = self.ctx
        worst = max(self.chips_c2(fz_in)[0])
        if ctx.c2_basis == "nominal":
            h_nom = forces.max_chip_thickness(fz_in * MM_PER_IN, self.ae_mm, self.D_mm)
            return {"C2": c2_tooth_strength(h_nom, ctx.h_nominal, ctx.mg.limit_scale, ctx.h_nominal_basis,
                                            "nominal chip fz·sin φe"),
                    "C2o": c2_tooth_strength(worst, ctx.h_overload, 1.0, ctx.h_overload_basis,
                                             "worst-flute chip (overload)", "C2o")}
        return {"C2": c2_tooth_strength(worst, ctx.h_tooth, ctx.mg.limit_scale, ctx.h_tooth_basis)}

    def c11(self, fz_in):
        return c11_feed(fz_in * self.ctx.tool.z * self.rpm, self.ctx.mach.max_feed_ipm, self.ctx.feed_cap)

    def wall_metric(self, beam):
        w = beam["wall"]
        return w["ripple_in"] if self.ctx.wall_metric == "ripple" else w["max_in"]

    def force_checks(self, fz_in):
        ctx = self.ctx
        f = self.loads(fz_in)
        beam = self._beam(f)
        top = beam["sections"][0] if beam["sections"] else {"sigma1_mpa": 0.0, "kind": "none", "x_in": 0.0}
        if ctx.op == "finish":
            if ctx.part_tolerance is not None:
                c3 = c3_deflection(self.wall_metric(beam), ctx.part_tolerance, beam["delta_load_at_in"],
                                   f"wall error ({ctx.wall_metric}) vs hard part tolerance")
            else:
                c3 = c3_deflection(self.wall_metric(beam), ctx.delta_allow, beam["delta_load_at_in"],
                                   f"wall error ({ctx.wall_metric}) vs target", kind="target")
        else:
            c3 = c3_deflection(beam["wall"]["max_in"], ctx.delta_allow, beam["delta_load_at_in"],
                               "wall-normal deflection")
        return {
            "C3": c3,
            "C4": c4_stress(top["sigma1_mpa"], ctx.stress_limit, f"{top['kind']} x = {top['x_in']:.4f}\"",
                            ctx.stress_basis),
            "C5": c5_spindle(abs(f["torque_mean_nm"]), f["power_kw"], self.rpm, ctx.mach.spindle,
                             ctx.mach.rating, ctx.mg.limit_margin),
        }, f, beam

    def rubbing_fz_in(self):
        """The runout-free feed per tooth (in) at which the nominal chip fz·sin φe equals h_min = λ·r_β: below it
        the cut rubs."""
        if not hasattr(self, "_rub_fz"):
            h1 = forces.max_chip_thickness(1.0, self.ae_mm, self.D_mm)
            self._rub_fz = self.ctx.h_min_mm / max(h1, 1e-12) / MM_PER_IN
        return self._rub_fz

    def c14lo(self, fz_in):
        """C14lo, the chip-load floor: fz ≥ 0.5 × the bucket's vendor-consensus median fz (and ≥ 2 × the rubbing
        limit); where there is no consensus, 2 × the rubbing limit. The relaxed floor ("rubbing") is 1 × the
        rubbing limit. Not applied to a user's own engagement or to finishing."""
        ctx = self.ctx
        rub = self.rubbing_fz_in()
        if ctx.chip_floor is None:
            return Check("C14lo", "chip-load floor", "min", fz_in, None, "in", SRC["C14lo"], applies=False,
                         detail="chip-load floor off")
        if ctx.chip_floor == "rubbing":
            return Check("C14lo", "chip-load floor", "min", fz_in, rub, "in", SRC["C14lo"],
                         detail=f"relaxed to the rubbing limit {rub:.6f}\" (fz·sin φe = h_min = "
                                f"{ctx.h_min_mm / MM_PER_IN:.6f}\")")
        pref, hard, basis = self.floor_pair()
        return Check("C14lo", "chip-load floor", "min", fz_in, hard, "in", SRC["C14lo"],
                     detail=f"fz {fz_in:.6f}\" vs hard floor {hard:.6f}\" (preferred {pref:.6f}\"): {basis}")

    def floor_pair(self):
        """(preferred, hard) chip-load floors in inches. Preferred: 0.5 × the vendor-consensus median fz (and ≥ 2 × the
        rubbing limit). Hard: 0.4 × the median, never below 2 × the rubbing limit. Between them a candidate is allowed with
        its selection score scaled by fz / preferred and a warning (soft band). The ceiling wins: neither exceeds 80 % of
        the vendor chip ceiling (C2 nominal chip, C14f)."""
        ctx = self.ctx
        rub = self.rubbing_fz_in()
        rubfloor = CHIP_FLOOR_RUBBING_FACTOR * rub
        pref = hard = rubfloor
        basis = f"2 × the rubbing limit {rub:.6f}\" (no vendor consensus for this cut)"
        if self.cons:
            med = self.cons["fz_over_D"] * ctx.tool.D * ctx.floor_scale
            if CHIP_FLOOR_FRACTION * med > rubfloor:
                pref = CHIP_FLOOR_FRACTION * med
                hard = max(CHIP_FLOOR_HARD_FRACTION * med, rubfloor)
                basis = (f"{CHIP_FLOOR_HARD_FRACTION:.0%}–{CHIP_FLOOR_FRACTION:.0%} of the vendor-consensus median "
                         f"{self.cons['fz_over_D'] * ctx.tool.D:.6f}\" ({self.cons['key']})")
        ceilings = []
        if ctx.c2_basis == "nominal":
            ceilings.append(ctx.h_nominal * ctx.mg.limit_scale / forces.max_chip_thickness(1.0, self.ae_mm, self.D_mm)
                            / MM_PER_IN)
        if self.cons:
            ceilings.append(ctx.mg.consensus_cap_scale * self.cons["fz_over_D"] * ctx.tool.D)
        if ceilings and pref > CHIP_FLOOR_CEILING_FRACTION * min(ceilings):
            cap = CHIP_FLOOR_CEILING_FRACTION * min(ceilings)
            pref, hard = cap, min(hard, cap)
            basis = f"{CHIP_FLOOR_CEILING_FRACTION:.0%} of the vendor chip ceiling (the ceiling wins)"
        return pref, hard, basis

    def flute_stats(self, fz_in, tir_in=None):
        """(flutes forming a chip, flutes) at fz: a flute cuts when its largest chip reaches h_min = λ·r_β. Counted at
        the runout phase with the fewest cutting flutes (the phase is unknown); tir_in overrides the machine's."""
        ctx = self.ctx
        z, fz = ctx.tool.z, fz_in * MM_PER_IN
        if tir_in is None:
            phases = ctx.phase_offsets
        else:
            tir_mm = tir_in * MM_PER_IN
            phases = ([forces.runout_offsets(tir_mm, z, "eccentric", 2.0 * math.pi / z * i / N_RUNOUT_PHASES)
                       for i in range(N_RUNOUT_PHASES)] if ctx.mach.runout_model == "eccentric" and tir_mm > 0
                      else [forces.runout_offsets(tir_mm, z, ctx.mach.runout_model)])
        n = min(sum(1 for h in self.eng.max_chips(fz, offs) if h >= ctx.h_min_mm) for offs in phases)
        return n, z

    def tir_all_flutes_in(self, fz_in, hi=0.01):
        """The largest runout (in, eccentric model) at which every flute still forms a chip at this fz, ae and ap:
        found by bisection on TIR (the count only falls as TIR rises). Capped at hi."""
        z = self.ctx.tool.z
        if self.flute_stats(fz_in, 0.0)[0] < z:
            return 0.0
        if self.flute_stats(fz_in, hi)[0] == z:
            return hi
        lo, up = 0.0, hi
        for _ in range(30):
            mid = 0.5 * (lo + up)
            if self.flute_stats(fz_in, mid)[0] == z:
                lo = mid
            else:
                up = mid
        return lo

    def runout_ratio(self, fz_in):
        """Tooth-to-tooth radial offset (the largest step between neighbouring flutes' reach, at the worst phase)
        over fz."""
        tir_mm = self.ctx.mach.tir_in * MM_PER_IN
        if tir_mm <= 0 or fz_in <= 0:
            return 0.0
        z = self.ctx.tool.z
        offs = runout_offsets_worst(tir_mm, z, self.ctx.mach.runout_model)
        step = max(offs[(k - 1) % z] - offs[k] for k in range(z))
        return max(step, 0.0) / (fz_in * MM_PER_IN)

    def lower_checks(self, fz_in):
        ctx = self.ctx
        chips, offs = self.chips_c1(fz_in)
        h = self.c1_chip(chips, offs)
        out = {"C1": c1_min_chip(h, ctx.tool.edge_radius_mm, ctx.lam, ctx.c1_flute),
               "C10": c10_work_hardening(h, ctx.mat.h_wh_mm)}
        if ctx.chip_floor is not None:
            out["C14lo"] = self.c14lo(fz_in)
        return out

    def checks(self, fz_in):
        fc, f, beam = self.force_checks(fz_in)
        out = self.lower_checks(fz_in)
        out.update(self.c2_checks(fz_in))
        out.update(fc)
        out.update({"C6": self.c6, "C7": self.c7, "C8": self.c8, "C9": self.ctx.c9, "C11": self.c11(fz_in),
                    "C12": self.c12, "C13": self.c13})
        if self.ctx.consensus is not None:
            out["C14v"] = self.c14v
            out.update(self.c14_checks(fz_in))
        chips = {"c2": self.chips_c2(fz_in)[0], "c1": self.chips_c1(fz_in)[0]}
        return {k: out[k] for k in sorted(out, key=_check_key)}, f, beam, chips

    def geometry_ok(self):
        return all(c.ok for c in (self.c6, self.c7, self.c8, self.c12, self.c13, self.c14v))

    def c14_checks(self, fz_in):
        """C14f (chip load) and C14m (MRR) against scale × the bucket's vendor median."""
        return c14_feed_checks(self, fz_in)

    def upper_ok(self, fz_in):
        if not (self.c11(fz_in).ok and all(c.ok for c in self.c2_checks(fz_in).values())
                and all(c.ok for c in self.c14_checks(fz_in).values())):
            return False
        return all(c.ok for c in self.force_checks(fz_in)[0].values())

    def lower_ok(self, fz_in):
        return all(c.ok for c in self.lower_checks(fz_in).values())

    def failing_upper(self, fz_in):
        """The upper constraints (C2, C2o, C3–C5, C11) that fail at fz."""
        out = [k for k, c in self.c2_checks(fz_in).items() if not c.ok]
        out += [k for k, c in self.c14_checks(fz_in).items() if not c.ok]
        if not self.c11(fz_in).ok:
            out.append("C11")
        out += [k for k, c in self.force_checks(fz_in)[0].items() if not c.ok]
        return out

    # --- fz window -------------------------------------------------------
    def fz_window(self, rel_tol=0.002, lower_tol=None):
        """(fz_lo, fz_hi) in inches: the smallest fz meeting C1/C10/C14lo and the largest meeting C2–C5, C11.

        None when the geometry fails (C6, C7, C8, C12, C13) or C1/C10 cannot be met below FZ_MAX_IN; fz_hi
        is None when the upper limits already fail at fz_lo. self.fz_capped is True when fz_hi stopped at
        FZ_MAX_IN, the search's explicit ceiling, rather than at a constraint. lower_tol: the tolerance of the
        fz_lo search (default rel_tol). The upper search starts from the previous window of this context.
        """
        self.fz_capped = False
        if not self.geometry_ok():
            return None
        fz_lo = _bisect_min(self.lower_ok, 1e-7, FZ_MAX_IN, lower_tol or rel_tol)
        if fz_lo is None:
            return None
        if not self.upper_ok(fz_lo):
            return (fz_lo, None)
        hint = self.ctx.last_fz_hi
        if hint and hint > fz_lo:
            if self.upper_ok(hint):
                lo, hi = hint, hint * 1.5
                while hi < FZ_MAX_IN and self.upper_ok(hi):
                    lo, hi = hi, hi * 1.5
            else:
                hi, lo = hint, hint / 1.5
                while lo > fz_lo and not self.upper_ok(lo):
                    hi, lo = lo, lo / 1.5
                lo = max(lo, fz_lo)
        else:
            lo, hi = fz_lo, fz_lo * 2.0
            while hi < FZ_MAX_IN and self.upper_ok(hi):
                lo, hi = hi, hi * 2.0
        if hi >= FZ_MAX_IN:
            if self.upper_ok(FZ_MAX_IN):
                self.fz_capped = True
                self.ctx.last_fz_hi = FZ_MAX_IN
                return (fz_lo, FZ_MAX_IN)
            hi = FZ_MAX_IN
        while hi / lo > 1.0 + rel_tol:
            mid = math.sqrt(lo * hi)
            if self.upper_ok(mid):
                lo = mid
            else:
                hi = mid
        self.ctx.last_fz_hi = lo
        return (fz_lo, lo)

    def mrr_in3_min(self, fz_in):
        return self.ap * self.ae * fz_in * self.ctx.tool.z * self.rpm


def _check_key(cid):
    digits = "".join(ch for ch in cid[1:] if ch.isdigit())
    return (int(digits), cid)


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
    """Every constraint C1–C13 for one cut (inches). rpm defaults to C7's speed for the engagement; a given
    rpm is checked against the machine and the tool-life speed.

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
           "h_max_worst_in": max(chips["c2"]) / MM_PER_IN, "h_max_thinnest_in": min(chips["c1"]) / MM_PER_IN}
    n_cut, n_flutes = pt.flute_stats(fz_in)
    cut.update({"rubbing_limit_in": pt.ctx.h_min_mm / MM_PER_IN, "flutes_cutting": n_cut,
                "runout_regime": "all_flutes" if n_cut == n_flutes else "reduced_flutes",
                "tir_all_flutes_in": pt.tir_all_flutes_in(fz_in), "runout_ratio": pt.runout_ratio(fz_in),
                "tir_in": pt.ctx.mach.tir_in})
    lbf = beam["delta_load_n"] / N_PER_LBF
    loads = {"lateral_peak_n": f["peak_n"], "lateral_peak_lbf": f["peak_n"] / N_PER_LBF,
             "lateral_mean_n": f["mean_n"], "torque_mean_nm": f["torque_mean_nm"],
             "power_w": f["power_kw"] * 1000.0,
             "deflection_tip_in": beam["delta_in"],
             "deflection_load_n": beam["delta_load_n"], "deflection_load_at_in": beam["delta_load_at_in"],
             "deflection_if_tip_load_in": deflection_in(lbf, t.segments, 0.0, 0.0, t.z, t.helix_deg, t.E_psi),
             "sections": beam["sections"], "flute_h_max_in": [h / MM_PER_IN for h in chips["c2"]],
             "flute_h_max_c1_phase_in": [h / MM_PER_IN for h in chips["c1"]],
             "flute_kc_n_mm2": f["flute_kc_n_mm2"]}
    ctx = pt.ctx
    bound = pt.eng.max_chips(fz_in * MM_PER_IN, ctx.offsets_bound)
    h_min = ctx.lam * t.edge_radius_mm
    warnings = list(ctx.notes)
    if ctx.c1_flute != "thinnest" and min(chips["c1"]) < h_min:
        rub = sum(1 for h in chips["c1"] if h < h_min)
        warnings.append(f"WARNING: {rub} flute(s) rub (chip {min(chips['c1']) / MM_PER_IN:.6f}\" under h_min "
                        f"{h_min / MM_PER_IN:.6f}\"); C1 is checked on the {ctx.c1_flute} flute only")
    if ctx.chip_floor == "vendor" and ctx.op != "finish" and not ctx.user_engagement:
        pref = pt.floor_pair()[0]
        if fz_in < pref * (1 - 1e-6) and pt.cons:
            med = pt.cons["fz_over_D"] * ctx.tool.D
            warnings.append(f"chip load below the preferred minimum ({fz_in / med:.0%} of vendor median) to stay within the "
                            f"deflection limit at this depth")
    if cut["fz_in"] < CHIP_FLOOR_RUBBING_FACTOR * cut["rubbing_limit_in"] and ctx.op != "finish":
        warnings.append(f"chip near the rubbing limit: fz {fz_in:.6f}\" is under twice the minimum chip "
                        f"{cut['rubbing_limit_in']:.6f}\" (the vendor chip ceiling is below the floor and wins); a low-runout "
                        f"holder and/or a higher spindle speed would help")
    if ctx.user_engagement and ctx.op != "finish" and beam["wall"]["max_in"] > ctx.delta_soft * (1 + 1e-6):
        warnings.append(f"deflection {beam['wall']['max_in']:.5f}\" exceeds k·D = {ctx.delta_soft:.5f}\" (allowed up to "
                        f"{USER_C3_FACTOR:g}× for your own engagement, fz is cut back beyond that): leave more stock for "
                        f"the finish pass")
    if n_cut < n_flutes:
        warnings.append(f"reduced flutes: only {n_cut} of {n_flutes} flutes form a chip at fz {fz_in:.6f}\" with TIR "
                        f"{ctx.mach.tir_in:.5f}\" (the others rub); all flutes cut at TIR ≤ "
                        f"{cut['tir_all_flutes_in']:.5f}\"; tool life is shorter")
    if getattr(pt, "fz_capped", False):
        warnings.append(f"fz reached the search ceiling {FZ_MAX_IN:g}\" with every limit still met")
    if min(bound) < h_min:
        warnings.append(f"bound runout (one flute high by the full TIR): the thinnest flute's chip "
                        f"{min(bound) / MM_PER_IN:.6f}\" is under h_min {h_min / MM_PER_IN:.6f}\" — it would rub")
    if max(bound) > ctx.h_tooth:
        warnings.append(f"bound runout: the worst flute's chip {max(bound) / MM_PER_IN:.6f}\" exceeds h_tooth "
                        f"{ctx.h_tooth / MM_PER_IN:.6f}\"")
    if pt.ae < AE_SANITY * t.D:
        warnings.append(f"ae {pt.ae:.5f}\" is under {AE_SANITY:g}·D, lighter than any vendor-published side cut")
    cut["toolpath_in_per_in3"] = 1.0 / (pt.ap * pt.ae)
    vol = ctx.opts["removal_volume_in3"]
    cut["program"] = {
        "bytes_per_in3": {f"s={sp:g}mm": program_bytes(pt.ap, pt.ae, 1.0, sp)
                          for sp in (POINT_SPACING_MM, POINT_SPACING_BAD_MM)},
        "in3_per_6MB": {f"s={sp:g}mm": PROGRAM_LIMIT_BYTES / program_bytes(pt.ap, pt.ae, 1.0, sp)
                        for sp in (POINT_SPACING_MM, POINT_SPACING_BAD_MM)},
        "bytes_for_volume": ({f"s={sp:g}mm": program_bytes(pt.ap, pt.ae, vol, sp)
                              for sp in (POINT_SPACING_MM, POINT_SPACING_BAD_MM)} if vol else None),
    }
    loads["wall_error_in"] = beam["wall"]
    band = ctx.band
    comparison = None
    if band:
        v_d = band["deflection_over_D"] * t.D
        comparison = {"band": band["band"], "basis": "Round 2 vendor-median limits (reported only)",
                      "deflection_tip_in": beam["delta_in"], "vendor_median_deflection_in": v_d,
                      "deflection_ratio": beam["delta_in"] / v_d,
                      "sigma1_mpa": checks["C4"].value, "vendor_median_sigma1_mpa": band["sigma1_mpa"],
                      "sigma1_ratio": checks["C4"].value / band["sigma1_mpa"]}
    cut["time_min_per_in3"] = 1.0 / cut["mrr_in3_min"] if cut["mrr_in3_min"] > 0 else math.inf
    return {"cut": cut, "loads": loads, "checks": {k: c.to_dict() for k, c in checks.items()},
            "violated": [k for k, c in checks.items() if not c.ok],
            "vendor_median_comparison": comparison,
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
        "taylor_n": material.taylor_n, "edge_radius_mm": tool.edge_radius_mm,
    }
    out = {k: {"value": v, "placeholder": True, "basis": PLACEHOLDERS[k]} for k, v in p.items()}
    out.update({
        "aggressiveness": {"value": mg.aggressiveness, "placeholder": False, "basis": "input"},
        "aggressiveness_map": {"value": {"scheme": mg.scheme, "limit_scale": mg.limit_scale,
                                         "life_ratio": mg.life_ratio, "speed_scale": mg.speed_scale,
                                         "stress_scale": mg.stress_scale, "consensus_cap_scale": mg.consensus_cap_scale,
                                         "limit_margin": mg.limit_margin, "lambda": ctx.lam},
                               "placeholder": True, "basis": PLACEHOLDERS["aggressiveness_map"]},
        "kc1_1_at_hb": {"value": ctx.coeffs.kienzle.kc1_1, "placeholder": False,
                        "basis": f"{material.kienzle.kc1_1:g}·{material.kc_scale():.4f} ({material.name})"},
        "mc": {"value": material.kienzle.mc, "placeholder": False, "basis": "Sandvik MC table"},
        "tir_in": {"value": machine.tir_in, "placeholder": False, "basis": f"machine setting, {machine.runout_model} model"},
        "fatigue_limit_mpa": {"value": tool.fatigue_fraction * tool.trs_mpa, "placeholder": False,
                              "basis": "0.35–0.4 × TRS 3.8 GPa, fully reversed bending, 10⁷ cycles (C4's basis)"},
        "E_mpa": {"value": tool.E_mpa, "placeholder": False, "basis": "CERATIZIT p-line p.22, 10 % Co"},
        "core_ratio": {"value": tool.core(), "placeholder": False, "basis": "patents/Mitsubishi, by flute count"},
        "deflection_allow_in": {"value": ctx.delta_allow, "placeholder": False, "basis": ctx.delta_basis},
        "stress_limit_mpa": {"value": ctx.stress_limit, "placeholder": False, "basis": ctx.stress_basis},
        "effective_feed_ipm": {"value": ctx.feed_cap, "placeholder": True, "basis": PLACEHOLDERS["effective_feed_ipm"]},
        "machine_max_feed_ipm": {"value": machine.max_feed_ipm, "placeholder": False, "basis": "machine profile"},
        "k_tir": {"value": ctx.k_tir, "placeholder": True, "basis": PLACEHOLDERS["k_tir"]},
        "chip_limit_mm": {"value": ctx.h_tooth, "placeholder": False, "basis": ctx.h_tooth_basis},
        "stock_to_leave_in": {"value": ctx.opts["stock_to_leave_in"], "placeholder": False, "basis": "input"},
    })
    return out


def optimize(tool, material, machine, operation="adaptive", aggressiveness=0.5, *, margins=None,
             stock=None, wall_height=None, level_time_s=None, path_length_per_level_in=None,
             depth_trade=DEPTH_TRADE_MRR, grid=SEARCH_GRID, ae_max=AE_MAX, n_theta=SEARCH_THETA, n_quad=SEARCH_QUAD,
             robustness=True, robust=True, flat_tol=0.05, find_tir=True, select_tir_in=None, **opts):
    """Choose fz, ap and ae for one operation (inches). Speed comes from C7 for each engagement.

    operation: "rough" | "adaptive" | "slot" | "finish".
    depth: the operation's real top-to-bottom depth (Z-level credit, design §7.2); ap is then depth/N.
    stock, wall_height: finishing's fixed ae and ap (wall_height defaults to min(LCF, depth)).
    level_time_s, path_length_per_level_in: optional per-level overhead (retract, link, re-entry) and
        cutting path per level; with both, the score is MRR/(1 + t_level·v_f/L_path).
    depth_trade: the candidates within this fraction of the best score are the pool the selection rule picks
        from (10 %, 2026-10-13); with the overhead terms, flat_tol.
    select_tir_in: when given (and not the machine's own TIR), the engagement (ap, ae) is chosen for this runout and
        fz, feasibility and every report are then taken at the machine's actual runout: runout derates the feed and
        never moves the engagement, unless it makes that engagement infeasible (then the next-best is taken). The
        default None selects at the machine's own runout.
    Selection (V3 M4): from that pool, prefer cuts where every flute cuts, then the cut closest to the vendor envelope
        medians (ap/D, ae/D from data/model_v2/engagement_envelope.json; fz/D from the consensus), log distance with
        equal weights; ap and ae are then refined between their grid neighbours so the result is off the grid.
        `robust`: exact ties are broken by the largest worst-case margin when TIR, K_r, h_tooth or kc is pushed the
        wrong way (`robustness_report`; design §3.6). Without envelope or consensus data the best score wins.
    opts (OPTION_DEFAULTS): depth, the operation's real depth; deflection_allow / stress_limit to override
        the C3/C4 limits; stock_to_leave_in (C3 = 50 % of it, roughing/adaptive/slot); wall_tolerance_in
        (finishing C3); c1_flute ("wall" by default: only the wall-generating flute must form a chip;
        "thinnest": every flute; "worst");
        effective_feed_ipm (C11, adaptive only; None for none); k_tir (C12); limit_program_size,
        program_limit_bytes, removal_volume_in3, point_spacing_mm (C13, off by default).

    The score is MRR with the feed capped by C11, i.e. the inverse of machining time per volume: a narrow
    ae needs a long toolpath (1/(ap·ae) inches per in³), and once the feed is capped that path costs time.
    """
    mg = margins or Margins(aggressiveness)
    search_opts = dict(opts) if operation == "finish" else dict(opts, n_phases=opts.get("n_phases") or SEARCH_PHASES)
    ctx = _Context(tool, material, machine, operation, mg, n_theta, n_quad, **search_opts)
    sel_machine = machine
    if select_tir_in is not None and operation != "finish" and abs(machine.tir_in - select_tir_in) > 1e-12:
        sel_machine = replace(machine, tir_in=select_tir_in)
    ctx_s = ctx if sel_machine is machine else _Context(tool, material, sel_machine, operation, mg, n_theta, n_quad,
                                                        **search_opts)
    depth = ctx.depth
    D, lcf = tool.D, tool.lcf
    ap_max = min(x for x in (lcf, ctx.flute_exposed or lcf, depth) if x)
    prov = [f"{tool.label or 'tool'}: D {D:.4f}\", {tool.z} flutes, LCF {lcf:.4f}\", stickout "
            f"{tool.stickout:.4f}\" (equivalent {ctx.eq_stickout / D:.2f}·D), helix {tool.helix_deg:g}°",
            f"material: {material.name}; kc1.1 = {ctx.coeffs.kienzle.kc1_1:.0f} N/mm², mc {material.kienzle.mc:g}",
            f"machine: {machine.label or 'spindle'}, max {machine.max_rpm:.0f} rpm, C5 {machine.rating}, "
            f"TIR {machine.tir_in:.5f}\" ({machine.runout_model})",
            f"margins (aggressiveness {mg.aggressiveness:.2f}, {mg.scheme} scheme): λ {ctx.lam:.2f}, tool life "
            f"×{mg.life_ratio:.2f}, speed ×{mg.speed_scale:.2f}, C2 ×{mg.limit_scale:.2f}, C5 margin "
            f"{mg.limit_margin:.0%}; C2 ({ctx.c2_basis} basis) "
            f"{(ctx.h_nominal if ctx.c2_basis == 'nominal' else ctx.h_tooth) / MM_PER_IN:.6f}\" "
            f"({ctx.h_nominal_basis if ctx.c2_basis == 'nominal' else ctx.h_tooth_basis}); "
            f"C3 {ctx.delta_allow:.6f}\" ({ctx.delta_basis}); C4 {ctx.stress_limit:.0f} MPa ({ctx.stress_basis})",
            f"C1 on the {ctx.c1_flute} flute; C11 feed cap "
            f"{min(c for c in (machine.max_feed_ipm, ctx.feed_cap, math.inf) if c):.0f} IPM; "
            f"C12 ae ≥ {ctx.k_tir:g}·TIR = {ctx.k_tir * machine.tir_in:.5f}\""]

    # Candidate (ap, ae) pairs per operation.
    ap_floor = max(0.02 * D, ap_max / 200.0)
    top = ap_max
    ae_lo = ae_hi = None
    if operation == "finish":
        if stock is None:
            raise ValueError("finishing needs stock (the fixed ae)")
        wall = wall_height if wall_height is not None else ap_max
        pairs = [(min(wall, ap_max), min(stock, D))]
        prov.append(f"finish: ap fixed at {pairs[0][0]:.4f}\", ae at the stock {pairs[0][1]:.4f}\"; the fastest "
                    f"feed that meets the wall target, else the smallest wall error")
    else:
        cap, cap_what = None, ""
        is_micro_rough = (operation == "rough" and D < 0.0625 - 1e-9)
        if ctx.depth_cap_ratio is not None:
            cap = ctx.depth_cap_ratio * D
            b = ctx.env_bucket
            cap_what = (f"; C8 caps ap at {ctx.depth_cap_ratio:.3f}·D (vendor envelope {b['n']} rows, {b['widening']}: "
                        f"p25 {b['ap_over_D']['p25']:.3f}, median {b['ap_over_D']['median']:.3f}, "
                        f"max {b['ap_over_D']['max']:.3f})")
        elif is_micro_rough or operation == "slot":
            k = slot_depth_ratio(D)
            cap = k * D if k is not None else None
            cap_what = f"; C8 caps ap at {k:g}·D" if cap else ""
        top = min(ap_max, cap) if cap else ap_max
        if depth:
            n_min = max(1, math.ceil(depth / top - 1e-9))
            n_max = max(n_min, int(depth / min(ap_floor, top)))
            ns = sorted({n_min} | {int(round(x)) for x in _logspace(n_min, n_max, grid[0])})
            aps = [depth / n for n in ns]
            prov.append(f"Z-level credit from the real depth {depth:.4f}\": ap = depth/N, N = {ns[0]}…{ns[-1]} "
                        f"({len(ns)} levels sampled)")
        else:
            aps = _logspace(min(ap_floor, top), top, grid[0])
        if operation == "slot":
            pairs = [(a, D) for a in aps]
            prov.append("slot: ae = D; maximize MRR over fz and ap" + cap_what)
        else:
            ae_lo, ae_hi = ae_bounds(ctx_s, ae_max, is_micro_rough)
            aes = _logspace(ae_lo, ae_hi, grid[1])
            pairs = [(a, e) for a in aps for e in aes]
            prov.append(f"{operation}: maximize MRR over fz, ap ∈ [{aps[0]:.4f}, {aps[-1]:.4f}]\", "
                        f"ae ∈ [{aes[0]:.4f}, {aes[-1]:.4f}]\" (≤ {ae_hi / D:.2f}·D)" + cap_what)

    if ctx_s is not ctx:
        prov.append(f"engagement chosen for a runout of {select_tir_in:.5f}\"; fz, limits and flutes cutting are taken at "
                    f"the actual {machine.tir_in:.5f}\"")
    cands, elim, failed = [], {}, []
    for ap, ae in pairs:
        c, why, win, pt = _candidate(ctx_s, ap, ae, level_time_s, path_length_per_level_in)
        if c is None:
            for k in why:
                elim[k] = elim.get(k, 0) + 1
            failed.append((pt, win, why))
        else:
            cands.append(c)

    if operation != "finish" and cands:
        # Connected feasible region only (V3 round 7): for each width walk the depth upward from the first feasible candidate and stop
        # at the first depth that fails any hard limit; likewise for width at each depth. An isolated feasible island above an
        # infeasible gap is never selected, so the choice cannot jump across a cliff.
        key = lambda a, e: (round(a, 12), round(e, 12))
        feas = {key(c["ap"], c["ae"]) for c in cands}
        apset = sorted({round(a, 12) for a, _ in pairs})
        aeset = sorted({round(e, 12) for _, e in pairs})
        def walk(lines, along):
            """Feasible nodes reachable from the first node of each line; one isolated infeasible node of the coarse grid
            is bridged, two in a row end the interval."""
            out = set()
            for fixed in lines:
                misses, started = 0, False
                for v in along:
                    node = along_key(fixed, v)
                    if node in feas:
                        out.add(node)
                        misses, started = 0, True
                    elif started:   # nodes below the first feasible one fail a lower limit (C13, C14lo): not a gap
                        misses += 1
                        if misses >= GAP_NODES:
                            break
            return out
        along_key = lambda fixed, v: (v, fixed)
        keep = walk(aeset, apset)
        along_key = lambda fixed, v: (fixed, v)
        keep2 = walk(apset, aeset)
        islands = len(cands)
        cands = [c for c in cands if key(c["ap"], c["ae"]) in keep]   # depth only: the width walk (keep2) costs vendor-envelope cells
        islands -= len(cands)
        if islands:
            prov.append(f"{islands} feasible candidates above an infeasible gap were ignored (connected region only)")

    def again(**changes):
        """optimize() once more with some arguments changed (everything else as called)."""
        kw = dict(margins=mg, stock=stock, wall_height=wall_height, level_time_s=level_time_s,
                  path_length_per_level_in=path_length_per_level_in, depth_trade=depth_trade, grid=grid,
                  ae_max=ae_max, n_theta=n_theta, n_quad=n_quad, robustness=robustness, robust=robust,
                  flat_tol=flat_tol, find_tir=find_tir, select_tir_in=select_tir_in)
        call_opts = dict(opts)
        call_opts.update({k: changes.pop(k) for k in list(changes) if k in OPTION_DEFAULTS})
        kw.update(changes)
        return optimize(tool, material, machine, operation, aggressiveness, **kw, **call_opts)

    if not cands and ctx_s.width_min_ratio:
        # Nothing cuts as wide as the narrowest vendor cut: allow narrower, and say which limit forbids the vendor width.
        out_n = again(ae_env_min=False)
        if out_n.get("feasible"):
            note = (f"ae is below the narrowest vendor cut ({ctx_s.width_min_ratio:.3f}·D): at that width every depth "
                    f"fails {', '.join(sorted(elim))}")
            out_n["warnings"].append(note)
            out_n["provenance"].append(note)
            out_n["ae_below_envelope_min"] = sorted(elim)
            return out_n
    if not cands and ctx_s is not ctx:
        return again(select_tir_in=None)
    if not cands:
        if ctx.chip_floor == "vendor":
            # C3/C4 force the chip below the floor at every depth (long stickout): relax to the rubbing limit.
            out_relaxed = again(chip_floor="rubbing")
            if out_relaxed.get("feasible"):
                note = (f"chip-load floor relaxed: deflection (C3) or stress (C4) force the chip below "
                        f"{CHIP_FLOOR_FRACTION:.0%} of the vendor median (or 2 × the rubbing limit) at every depth "
                        f"(eliminated by {', '.join(sorted(elim))}); fz is held just above the rubbing limit. "
                        f"A shorter stickout or a stiffer setup would allow the vendor chip load")
                out_relaxed["warnings"].append(note)
                out_relaxed["provenance"].append(note)
                out_relaxed["chip_floor_relaxed"] = True
                return out_relaxed
        return _infeasible(tool, material, machine, operation, mg, ctx, prov, elim, failed, find_tir,
                           dict(opts, stock=stock, wall_height=wall_height))

    best = max(cands, key=lambda c: c["score"])
    overhead = bool(level_time_s and path_length_per_level_in)
    wall_target = None
    if operation == "finish":
        chosen = best
        fz_t, wall_target = _finish_target(chosen["pt"], chosen["fz_lo"], chosen["fz"], ctx)
        chosen = dict(chosen, fz=fz_t, mrr=chosen["pt"].mrr_in3_min(fz_t))
        rule = ("finish: fastest feed meeting the wall target" if wall_target["met"]
                else "finish: no feed meets the wall target; the smallest predicted wall error")
    else:
        tol = flat_tol if overhead else depth_trade
        band = [c for c in cands if c["score"] >= (1.0 - tol) * best["score"]]
        selector = _Selector(ctx_s, band_floor=(1.0 - tol) * best["score"], best_score=best["score"], tol=tol)
        pool = band
        rule = f"among {len(band)} candidates within {tol:.0%} of the best score"
        if selector.has_targets:
            rule += (f", the one closest to the vendor medians ({selector.describe()}; log distance, equal weights; "
                     f"each flute that rubs, or 10 % of MRR given up, counts as a 10 % move)")
        else:
            rule += ", the highest score (no vendor envelope or consensus for this cut)"
        chosen = min(pool, key=lambda c: (round(selector.objective(c), 9), -c["score"]))
        ties = [c for c in pool if round(selector.objective(c), 9) == round(selector.objective(chosen), 9)]
        if robust and 1 < len(ties) <= 8 and selector.has_targets:
            for c in ties:
                rep_c = robustness_report(tool, material, machine, operation,
                                          {"ap_in": c["ap"], "ae_in": c["ae"], "fz_in": c["fz"], "rpm": c["pt"].rpm},
                                          ctx, n_theta=n_theta, n_quad=n_quad)
                c["robust_margins"] = sorted(round(v["margin"], 2) for v in rep_c.values())
            chosen = max(ties, key=lambda c: (tuple(c["robust_margins"]), c["score"]))
            rule += (f"; {len(ties)} exact ties broken by the largest worst-case margin with TIR, K_r, the C2 limit "
                     f"or kc pushed the wrong way ({chosen['robust_margins']})")
        grid_choice = chosen
        if not depth:
            chosen = _refine(ctx_s, chosen, cands, selector, level_time_s, path_length_per_level_in, "ap", (None, top))
        if ae_lo is not None:
            chosen = _refine(ctx_s, chosen, cands, selector, level_time_s, path_length_per_level_in, "ae",
                             (ae_lo, ae_hi))
        for var, others_set, bound in (("ap", apset if not depth else [], top),):
            if not others_set:
                continue
            nxt = [v for v in others_set if v > chosen[var] * (1 + 1e-9)]
            if not nxt:
                continue
            b = _to_boundary(ctx_s, chosen, var, nxt[0], selector, level_time_s, path_length_per_level_in)
            if b is not chosen:
                chosen = b
        if chosen is not grid_choice:
            rule += (f"; refined locally ap {grid_choice['ap']:.5f}\" → {chosen['ap']:.5f}\", ae "
                     f"{grid_choice['ae']:.5f}\" → {chosen['ae']:.5f}\" (score {grid_choice['score']:.5f} → "
                     f"{chosen['score']:.5f})")
        ranked = [chosen] + sorted((c for c in cands if c is not chosen),
                                   key=lambda c: (selector.objective(c), -c["score"]))[:12]
        if ctx_s is not ctx:
            # The engagement was ranked at the reference runout; take the best-ranked one that is feasible at the
            # actual runout (fz and every check there).
            actual = []
            for i, c in enumerate(ranked):
                ca = _candidate(ctx, c["ap"], c["ae"], level_time_s, path_length_per_level_in)[0]
                if ca is None and i == 0 and not depth:
                    # Shrink the chosen depth continuously toward feasibility rather than jump to another candidate.
                    ca = _shrink_ap(ctx, c, level_time_s, path_length_per_level_in)
                if ca is not None:
                    actual.append(ca)
                if len(actual) >= 4:
                    break
            if not actual:
                return again(select_tir_in=None)
            if abs(actual[0]["ap"] - chosen["ap"]) > 1e-12 or abs(actual[0]["ae"] - chosen["ae"]) > 1e-12:
                rule += (f"; the reference-runout choice is infeasible at the actual runout, so the depth is reduced "
                         f"to {actual[0]['ap']:.5f}\" (ae {actual[0]['ae']:.5f}\")")
            ranked, chosen = actual, actual[0]
        attempts_ranked = ranked

    hi_theta, hi_quad = (720, 96) if operation == "finish" else (HIRES_THETA, HIRES_QUAD)
    ctx_hi = _Context(tool, material, machine, operation, mg, hi_theta, hi_quad, **opts)
    ctx_hi.floor_scale = FLOOR_HIRES_SCALE   # the search and full-resolution windows differ by a percent or two

    def hires(c):
        """Re-check a candidate at full resolution; if that puts it a hair over a limit, fz backs off onto it there."""
        fz = c["fz"]
        checks_s, _, _, _ = c["pt"].checks(fz)
        binding, resolution = _binding(checks_s), f"search ({n_theta} rotation samples)"
        pt_hi = CutPoint(ctx_hi, c["ap"], c["ae"], c["pt"].rpm)
        if operation != "finish":
            ctx_hi.last_fz_hi = c["fz"]
            # fz is placed on the full-resolution window (a few samples of the force integral, not a search).
            win = pt_hi.fz_window(HIRES_FZ_TOL, 0.02)
            if not (win and win[1]) and not depth and c["ap"] > 0:
                # The window closes at full resolution: shrink the depth continuously until it opens.
                lo_f, hi_f, found = 0.3, 1.0, None
                for _ in range(7):
                    mid = 0.5 * (lo_f + hi_f)
                    p2 = CutPoint(ctx_hi, c["ap"] * mid, c["ae"], c["pt"].rpm)
                    w2 = p2.fz_window(HIRES_FZ_TOL, 0.02)
                    if w2 and w2[1]:
                        lo_f, found = mid, (p2, w2)
                    else:
                        hi_f = mid
                if found:
                    pt_hi, win = found
                    c["ap"] = pt_hi.ap
            if win and win[1]:
                fz = max(win[1], win[0])
            checks, f, beam, chips = pt_hi.checks(fz)
            return (fz, checks, f, beam, chips, _binding(checks),
                    f"full ({hi_theta} rotation samples), fz placed on the window", pt_hi)
        checks, f, beam, chips = pt_hi.checks(fz)
        if not all(k.ok for k in checks.values()):
            win = pt_hi.fz_window()
            if win and win[1]:
                fz = max(min(fz, win[1]), win[0])
                checks, f, beam, chips = pt_hi.checks(fz)
                binding, resolution = _binding(checks), "full (720 rotation samples), after backing fz off"
        return fz, checks, f, beam, chips, binding, resolution, pt_hi

    # Binding is judged where the window was found (the search resolution), and the cut is re-checked at full
    # resolution. A candidate that fails there (its window closes at full resolution) gives way to the next-closest.
    attempts = [chosen] if operation == "finish" else attempts_ranked
    for attempt in attempts:
        fz, checks, f, beam, chips, binding, resolution, pt_hi = hires(attempt)
        if all(k.ok for k in checks.values()):
            break
    else:
        attempt = attempts[0]
        fz, checks, f, beam, chips, binding, resolution, pt_hi = hires(attempt)
    if attempt is not chosen:
        rule += (f"; the first choice failed the full-resolution check, so the next-closest candidate "
                 f"(ap {attempt['ap']:.5f}\", ae {attempt['ae']:.5f}\") was taken")
        chosen = attempt
    if wall_target is not None and wall_target["met"]:
        # The wall target was met at search resolution; place the feed on it at full resolution too.
        fz_t, met_hi = _finish_target(pt_hi, min(chosen["fz_lo"], fz), fz, ctx_hi)
        if met_hi["met"] and fz_t < fz:
            fz = fz_t
            checks, f, beam, chips = pt_hi.checks(fz)
            binding, resolution = _binding(checks), "full (720 rotation samples), feed placed on the wall target"
    rep = _report(pt_hi, fz, checks, f, beam, chips)
    if chosen.get("capped"):
        rep["warnings"].append(f"fz reached the search ceiling {FZ_MAX_IN:g}\" with every limit still met")
    if wall_target is not None:
        wall_target = _wall_report(pt_hi, beam, ctx_hi)
        if not wall_target["met"]:
            rep["warnings"].append(
                f"wall target {wall_target['target_in'] * MM_PER_IN * 1000:.1f} µm not met: predicted "
                f"{wall_target['metric']} {wall_target['value_in'] * MM_PER_IN * 1000:.1f} µm (shortfall "
                f"{wall_target['shortfall_in'] * MM_PER_IN * 1000:.1f} µm); this is the smallest wall error "
                f"available")
    margins_out = {k: c.margin for k, c in checks.items() if c.applies and c.margin is not None and c.kind != "info"}
    prov.append(f"selection: {rule}")
    prov.append(f"best score {best['score']:.5f} in³/min at ap {best['ap']:.4f}\", ae {best['ae']:.4f}\", "
                f"fz {best['fz']:.6f}\"; chosen ap {rep['cut']['ap_in']:.4f}\", ae {rep['cut']['ae_in']:.4f}\", "
                f"fz {fz:.6f}\", MRR {rep['cut']['mrr_in3_min']:.5f} in³/min")
    prov.extend(f"{k}: {c.detail}" for k, c in checks.items() if c.applies)
    prov.append(f"binding ({resolution}): " + (", ".join(binding) or
                "none — margins " + ", ".join(f"{k} {m:+.1%}" for k, m in sorted(margins_out.items(),
                                                                                 key=lambda kv: kv[1])[:4])))
    prov.extend(f"warning: {w}" for w in rep["warnings"])

    score = rep["cut"]["mrr_in3_min"]
    if overhead:
        score /= 1.0 + level_time_s * (rep["cut"]["feed_ipm"] / 60.0) / path_length_per_level_in
    out = {"operation": operation, "feasible": not rep["violated"], **rep, "binding": binding,
           "binding_resolution": resolution, "margins": margins_out, "score": score,
           "best_score_point": {"ap_in": best["ap"], "ae_in": best["ae"], "fz_in": best["fz"],
                                "rpm": best["pt"].rpm, "mrr_in3_min": best["mrr"], "score": best["score"]},
           "candidates": len(cands), "eliminated_by": elim,
           "parameters": _parameters(tool, material, machine, mg, ctx), "provenance": prov}
    if wall_target is not None:
        out["wall_target"] = wall_target
    out["trade"] = mrr_size_front(cands)
    if robustness:
        out["robustness"] = robustness_report(tool, material, machine, operation, rep["cut"], ctx)
    return out


def evaluate_user_engagement(tool, material, machine, operation, ap_in, ae_in, aggressiveness=0.5, *, margins=None,
                             n_theta=HIRES_THETA, n_quad=HIRES_QUAD, **opts):
    """Speed and feed for the user's own engagement (inches): the optimizer's recommendation is not used.

    rpm is C7's speed for this ae (capped by C14v); fz is the highest value every limit allows, which already
    includes the consensus cap at this aggressiveness (C14f), i.e. min(window maximum, consensus target). The
    envelope depth cap (C8's vendor table) and the chip floor are recommendations and are not applied to a user's
    cut. When the engagement is infeasible the result still carries the best feed (the smallest fz that cuts, or
    the consensus target when none does) with `feasible: False`, the violated checks and by how much each exceeds
    its limit (`violations`). Returns the same structure as `optimize`, plus `engagement_source: "user"`.
    """
    mg = margins or Margins(aggressiveness)
    ctx = _Context(tool, material, machine, operation, mg, n_theta, n_quad, **dict(opts, user_engagement=True))
    D = tool.D
    ap_max = min(x for x in (tool.lcf, ctx.flute_exposed or tool.lcf) if x)
    ap_used, ae_used = min(float(ap_in), ap_max), min(float(ae_in), D)
    pt = CutPoint(ctx, ap_used, ae_used)
    win = pt.fz_window()
    prov = [f"user engagement: ap {float(ap_in):.5f}\", ae {float(ae_in):.5f}\" "
            f"(ap/D {float(ap_in) / D:.3f}, ae/D {float(ae_in) / D:.3f}); rpm from C7 at this ae"]
    if win is not None and win[1] is not None:
        fz = win[1]
        prov.append(f"fz {fz:.6f}\": the highest every limit allows (window {win[0]:.6f}\" – {win[1]:.6f}\"; the "
                    f"C14f consensus cap at aggressiveness {mg.aggressiveness:.2f} is one of them)")
    else:
        fz_cons = (mg.consensus_cap_scale * pt.cons["fz_over_D"] * D) if pt.cons else 0.002 * D
        fz = win[0] if win is not None else fz_cons
        prov.append(f"no fz meets every limit at this engagement; shown at fz {fz:.6f}\" "
                    f"({'the smallest chip that cuts' if win is not None else 'the consensus chip load'})")
    checks, f, beam, chips = pt.checks(fz)
    rep = _report(pt, fz, checks, f, beam, chips)
    clamped = None
    if ap_used < float(ap_in) - 1e-12 or ae_used < float(ae_in) - 1e-12:
        clamped = {"ap_requested_in": float(ap_in), "ae_requested_in": float(ae_in), "ap_used_in": ap_used,
                   "ae_used_in": ae_used}
        rep["warnings"].append(f"requested engagement ap {float(ap_in):.4f}\" / ae {float(ae_in):.4f}\" exceeds the "
                               f"flute length or the diameter; calculated at ap {ap_used:.4f}\" / ae {ae_used:.4f}\"")
    violations = [{"id": k, "name": c.name, "value": c.value, "limit": c.limit, "units": c.units,
                   "over_by": ((c.value - c.limit) / c.limit if c.kind == "max" else (c.limit - c.value) / c.limit)
                   if c.limit else None, "kind": c.kind, "detail": c.detail}
                  for k, c in checks.items() if not c.ok]
    margins_out = {k: c.margin for k, c in checks.items() if c.applies and c.margin is not None and c.kind != "info"}
    binding = _binding(checks)
    prov.extend(f"{k}: {c.detail}" for k, c in checks.items() if c.applies)
    prov.extend(f"warning: {w}" for w in rep["warnings"])
    out = {"operation": operation, "feasible": not rep["violated"], **rep, "binding": binding,
           "binding_resolution": f"full ({n_theta} rotation samples)", "margins": margins_out,
           "score": rep["cut"]["mrr_in3_min"], "candidates": 1,
           "eliminated_by": {} if not rep["violated"] else {k: 1 for k in rep["violated"]},
           "parameters": _parameters(tool, material, machine, mg, ctx), "provenance": prov,
           "engagement_source": "user", "violations": violations, "clamped": clamped}
    return out


def ae_bounds(ctx, ae_max=AE_MAX, is_micro_rough=False):
    """Radial engagement range (in) for roughing and adaptive: adaptive from max(k·TIR, 0.05·D) up to 0.30·D
    (0.40·D for non-ferrous), roughing up to 0.50·D, and in both up to the vendor width envelope."""
    D, tir = ctx.tool.D, ctx.mach.tir_in
    if ctx.op == "adaptive":
        hi_frac = AE_ADAPTIVE_MAX_NONFERROUS_OVER_D if ctx.non_ferrous else AE_ADAPTIVE_MAX_OVER_D
        lo = max(ctx.k_tir * tir, AE_ADAPTIVE_MIN_OVER_D * D)
    else:
        hi_frac = AE_ROUGH_MAX_OVER_D
        micro_lo = 0.25 if ctx.width_cap_ratio is None else AE_ADAPTIVE_MIN_OVER_D   # legacy micro roughing stepover
        lo = max(ctx.k_tir * tir, (micro_lo if is_micro_rough else 0.002) * D)
    hi = min(ae_max, hi_frac) * D
    if ctx.width_min_ratio:
        lo = max(lo, min(ctx.width_min_ratio * D, hi))   # not narrower than the narrowest vendor cut
    if ctx.width_cap_ratio:
        # The vendor width envelope (p25 → median → max by aggressiveness) bounds the engagement, never below k·TIR.
        hi = max(min(hi, ctx.width_cap_ratio * D), min(hi, lo))
    return min(lo, hi), hi


def _candidate(ctx, ap, ae, level_time_s=None, path_len=None):
    """(candidate, None, win, pt) for a feasible (ap, ae), else (None, eliminating checks, win, pt)."""
    pt = CutPoint(ctx, ap, ae)
    win = pt.fz_window(SEARCH_FZ_TOL, SEARCH_LOWER_TOL)
    if win is None or win[1] is None:
        return None, _eliminators(pt, win), win, pt
    fz = win[1]
    mrr = pt.mrr_in3_min(fz)
    score = mrr
    if level_time_s and path_len:
        score = mrr / (1.0 + level_time_s * (fz * ctx.tool.z * pt.rpm / 60.0) / path_len)
    if ctx.chip_floor == "vendor":
        pref = pt.floor_pair()[0]
        if fz < pref:
            score *= fz / pref       # soft band: a smooth penalty for a chip under the preferred minimum
    return {"pt": pt, "ap": ap, "ae": ae, "fz": fz, "fz_lo": win[0], "mrr": mrr, "score": score,
            "capped": pt.fz_capped}, None, win, pt


class _Selector:
    """The selection rule (V3 M4): among near-best candidates, the one closest to the vendor envelope medians.

    Distance² = Σ (ln(value / target))² over ap/D and ae/D (the envelope bucket's medians; ae/D not for slots) and fz/D
    (the consensus median × the aggressiveness scale, per candidate engagement), equal weights; a term is left out
    when its target is missing. Without any target the distance is 0 for all and the score decides.
    """

    def __init__(self, ctx, band_floor, best_score, tol=0.10):
        self.ctx, self.band_floor, self.best_score = ctx, band_floor, best_score
        # losing a fraction `tol` of the best MRR is worth a 10 % move toward the vendor medians (smooth, no cliff at the band)
        self.trade = 1.0
        b = ctx.env_bucket
        D = ctx.tool.D
        self.ap_t = b["ap_over_D"]["median"] * D if b else None
        self.ae_t = b["ae_over_D"]["median"] * D if (b and ctx.op != "slot") else None
        self.use_fz = ctx.consensus is not None
        self.has_targets = bool(self.ap_t or self.ae_t or self.use_fz)
        self._all_cut = {}

    def describe(self):
        D = self.ctx.tool.D
        parts = []
        if self.ap_t:
            parts.append(f"ap/D {self.ap_t / D:.3f}")
        if self.ae_t:
            parts.append(f"ae/D {self.ae_t / D:.3f}")
        if self.use_fz:
            parts.append("fz/D consensus")
        return ", ".join(parts)

    def fz_target(self, c):
        cons = c["pt"].cons
        return self.ctx.mg.consensus_cap_scale * cons["fz_over_D"] * self.ctx.tool.D if cons else None

    def distance(self, c):
        d2 = 0.0
        if self.ap_t:
            d2 += math.log(c["ap"] / self.ap_t) ** 2
        if self.ae_t:
            d2 += math.log(c["ae"] / self.ae_t) ** 2
        ft = self.fz_target(c) if self.use_fz else None
        if ft:
            d2 += math.log(c["fz"] / ft) ** 2
        return math.sqrt(d2)

    def all_cut(self, c):
        key = (round(c["ap"], 10), round(c["ae"], 10))
        if key not in self._all_cut:
            n, z = c["pt"].flute_stats(c["fz"])
            self._all_cut[key] = n == z
        return self._all_cut[key]

    def objective(self, c):
        """Smaller is better: the log distance to the vendor medians, plus the log of the MRR given up against the best
        candidate (so 10 % of MRR is worth a 10 % move toward the medians: a smooth trade, no cliff at the edge of the
        within-10 % band), plus 0.1 when not every flute cuts. A candidate under the score floor is penalized hard.
        With no vendor targets: the negative score."""
        if not self.has_targets:
            return -c["score"]
        pen = self.distance(c) + self.trade * math.log(self.best_score / c["score"])
        if not self.all_cut(c):
            pen += ALL_FLUTES_PENALTY
        if c["score"] < self.band_floor:
            pen += 10.0 * (1.0 - c["score"] / self.band_floor) + 1.0
        return pen


def _shrink_ap(ctx, c, level_time_s, path_len, iters=10):
    """The deepest feasible ap below c's (same ae), found by bisection on the depth scale; None when even a
    sliver is infeasible. Feasibility only worsens with depth, so the result moves continuously with the inputs."""
    lo_f, hi_f = 0.02, 1.0
    best = _candidate(ctx, c["ap"] * lo_f, c["ae"], level_time_s, path_len)[0]
    if best is None:
        return None
    for _ in range(iters):
        mid = 0.5 * (lo_f + hi_f)
        cand = _candidate(ctx, c["ap"] * mid, c["ae"], level_time_s, path_len)[0]
        if cand is None:
            hi_f = mid
        else:
            lo_f, best = mid, cand
    return best


def _to_boundary(ctx, chosen, var, nxt, selector, level_time_s, path_len, iters=9):
    """If the next grid value of `var` above the chosen candidate is infeasible, bisect between them to the largest feasible
    value (the edge of the connected feasible interval) and take it when the selection objective improves."""
    def at(v):
        ap, ae = (v, chosen["ae"]) if var == "ap" else (chosen["ap"], v)
        return _candidate(ctx, ap, ae, level_time_s, path_len)[0]
    if at(nxt) is not None:
        return chosen        # the next node is feasible: the choice is not at a boundary
    lo, hi, best = chosen[var], nxt, chosen
    for _ in range(iters):
        mid = 0.5 * (lo + hi)
        cand = at(mid)
        if cand is None:
            hi = mid
        else:
            lo, best = mid, cand
    return best if selector.objective(best) < selector.objective(chosen) - 1e-9 else chosen


def _refine(ctx, chosen, cands, selector, level_time_s, path_len, var, bounds, iters=8):
    """Golden-section search (log scale) on ap or ae of the chosen candidate between its grid neighbours, to take the
    result off the grid node: minimizes the selector's objective. Never returns a worse candidate."""
    key = var
    others = "ae" if var == "ap" else "ap"
    same = sorted({c[var] for c in cands if abs(c[others] - chosen[others]) < 1e-12} | {chosen[var]})
    i = same.index(chosen[var])
    lo_b, hi_b = bounds
    lo = same[i - 1] if i > 0 else chosen[var] / 1.3
    hi = same[i + 1] if i + 1 < len(same) else chosen[var] * 1.3
    if lo_b is not None:
        lo = max(lo, lo_b)
    if hi_b is not None:
        hi = min(hi, hi_b)
    if hi <= lo * (1 + 1e-9):
        return chosen
    start_all_cut = selector.all_cut(chosen)
    cache = {}

    def evaluate(v):
        k = round(v, 10)
        if k not in cache:
            ap, ae = (v, chosen["ae"]) if var == "ap" else (chosen["ap"], v)
            cand = _candidate(ctx, ap, ae, level_time_s, path_len)[0]
            cache[k] = cand
        return cache[k]

    def obj(c):
        if c is None:
            return math.inf
        o = selector.objective(c)
        if start_all_cut and not selector.all_cut(c):
            o += 1.0
        return o

    best, best_o = chosen, obj(chosen)
    g = (math.sqrt(5.0) - 1.0) / 2.0
    a, b = math.log(lo), math.log(hi)
    for _ in range(iters):
        c1, c2 = b - g * (b - a), a + g * (b - a)
        r1, r2 = evaluate(math.exp(c1)), evaluate(math.exp(c2))
        o1, o2 = obj(r1), obj(r2)
        for r, o in ((r1, o1), (r2, o2)):
            if r is not None and o < best_o - 1e-9:
                best, best_o = r, o
        if o1 <= o2:
            b = c2
        else:
            a = c1
    return best


def _eliminators(pt, win):
    """The constraint(s) that remove a candidate (ap, ae), each named on its own."""
    if win is None:
        geo = [k for k, c in (("C6", pt.c6), ("C7", pt.c7), ("C8", pt.c8), ("C12", pt.c12), ("C13", pt.c13),
                              ("C14v", pt.c14v)) if not c.ok]
        if geo:
            return geo
        return [k for k, c in pt.lower_checks(FZ_MAX_IN).items() if not c.ok] or ["C1"]
    return pt.failing_upper(win[0]) or ["C1"]


def _infeasible(tool, material, machine, operation, mg, ctx, prov, elim, failed, find_tir, opts):
    """No feasible cut: name the constraint that removes the most candidates, show the closest candidate,
    and (find_tir) the largest TIR at which the operation becomes feasible."""
    top = max(elim.values())
    binding = sorted(k for k, n in elim.items() if n == top)

    def closeness(item):
        pt, win, why = item
        if win is None or win[0] is None:
            return (-1e9, 0)
        ch = pt.checks(win[0])[0]
        worst = min(c.margin for k, c in ch.items() if not c.ok and c.margin is not None)
        return (worst, -len(why))
    pt, win, why = max(failed, key=closeness)
    fz = win[0] if win else 1e-4
    checks, f, beam, chips = pt.checks(fz)
    rep = _report(pt, fz, checks, f, beam, chips)
    prov.append("no feasible cut. Candidates eliminated by: "
                + ", ".join(f"{k} {n}" for k, n in sorted(elim.items(), key=lambda kv: -kv[1]))
                + f". Checks shown at the closest candidate: ap {pt.ap:.4f}\", ae {pt.ae:.4f}\", fz {fz:.6f}\" "
                  f"(the smallest fz that meets C1/C10)")
    out = {"operation": operation, "feasible": False, "eliminated_by": elim, **rep, "binding": binding,
           "binding_resolution": "candidates eliminated", "parameters": _parameters(tool, material, machine, mg, ctx),
           "provenance": prov}
    if find_tir and machine.tir_in > 0:
        out["max_feasible_tir_in"] = max_feasible_tir(tool, material, machine, operation, mg, opts)
        t = out["max_feasible_tir_in"]
        prov.append("largest TIR at which this becomes feasible: "
                    + (f"{t:.5f}\" (eccentric)" if t is not None else "none, even with zero runout"))
    return out


def max_feasible_tir(tool, material, machine, operation, margins, opts, rel_tol=0.05):
    """Largest TIR (in) at which optimize() finds a feasible cut, by bisection below the machine's TIR;
    None when even zero runout fails. Coarse grid: an indication for holder choice and Blum checks."""
    kw = {k: v for k, v in opts.items() if v is not None}

    def ok(tir):
        r = optimize(tool, material, replace(machine, tir_in=tir), operation, margins=margins, grid=(8, 8),
                     robust=False, robustness=False, find_tir=False, **kw)
        return r["feasible"]
    if not ok(0.0):
        return None
    lo, hi = 0.0, machine.tir_in
    while hi - lo > max(rel_tol * hi, 2e-6):
        mid = 0.5 * (lo + hi)
        if ok(mid):
            lo = mid
        else:
            hi = mid
    return lo


def _finish_target(pt, fz_lo, fz_hi, ctx):
    """Finishing (user 2026-10-17): the fastest fz in [fz_lo, fz_hi] whose wall metric meets the target;
    if none, the fz with the smallest wall metric. Returns (fz, {met, ...})."""
    target = ctx.delta_allow

    def metric(fz):
        return pt.wall_metric(pt._beam(pt.loads(fz)))
    if metric(fz_hi) <= target:
        return fz_hi, {"met": True}
    if metric(fz_lo) <= target:
        lo, hi = fz_lo, fz_hi
        while hi / lo > 1.002:
            mid = math.sqrt(lo * hi)
            if metric(mid) <= target:
                lo = mid
            else:
                hi = mid
        return lo, {"met": True}
    grid = _logspace(fz_lo, fz_hi, 12) if fz_hi > fz_lo else [fz_lo]
    best = min(grid, key=metric)
    return best, {"met": False}


def _wall_report(pt, beam, ctx):
    w = beam["wall"]
    value = pt.wall_metric(beam)
    met = value <= ctx.delta_allow * (1 + WALL_TARGET_RTOL)
    return {"metric": ctx.wall_metric, "target_in": ctx.delta_allow, "value_in": value,
            "met": met, "shortfall_in": 0.0 if met else value - ctx.delta_allow,
            "max_in": w["max_in"], "mean_blum_compensable_in": w["mean_in"], "ripple_in": w["ripple_in"],
            "hard_part_tolerance_in": ctx.part_tolerance}


def mrr_size_front(cands):
    """The MRR-vs-program-size trade: candidates no other candidate beats on both MRR and toolpath per in³.

    Sorted from the shortest toolpath (smallest program) up; each entry is the best MRR available at that
    program size, with the estimated bytes per in³ at the typical and the bad point spacing.
    """
    front, best = [], -1.0
    for c in sorted(cands, key=lambda c: (1.0 / (c["ap"] * c["ae"]), -c["mrr"])):
        if c["mrr"] > best * (1.0 + 1e-9):
            best = c["mrr"]
            front.append({"ap_in": c["ap"], "ae_in": c["ae"], "fz_in": c["fz"], "rpm": c["pt"].rpm,
                          "mrr_in3_min": c["mrr"], "toolpath_in_per_in3": 1.0 / (c["ap"] * c["ae"]),
                          "MB_per_in3": {f"s={sp:g}mm": program_bytes(c["ap"], c["ae"], 1.0, sp) / 1e6
                                         for sp in (POINT_SPACING_MM, POINT_SPACING_BAD_MM)}})
    return front


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

    Limits are the context's C2/C3/C4 limits with no C5 margin. Returns, per scenario, the constraint
    with the least margin among C1–C5, C10 and C12, its margin and any violations.
    """
    scenarios = {
        "TIR ×2": (tool, material, replace(machine, tir_in=machine.tir_in * 2.0)),
        "K_r 0.6 (top of 0.3–0.6)": (tool, replace(material, k_r=0.6), machine),
        "C2 chip limit −25 %": (tool, replace(material, c2_scale=material.c2_scale * 0.75), machine),
        "kc +20 % (hardness/tool factor)": (tool, replace(material, tool_factor=material.tool_factor * 1.2), machine),
    }
    nominal = replace(ctx.mg, limit_margin=0.0)
    opts = dict(ctx.opts, deflection_allow=ctx.delta_allow, stress_limit=ctx.stress_limit)
    out = {}
    for name, (t, m, mc) in scenarios.items():
        r = evaluate_cut(t, m, mc, operation, cut["ap_in"], cut["ae_in"], cut["fz_in"], cut["rpm"],
                         margins=nominal, n_theta=n_theta, n_quad=n_quad, **opts)
        ms = [(k, r["checks"][k]["margin"]) for k in UNCERTAIN_CHECKS + ("C2o",)
              if k in r["checks"] and r["checks"][k]["margin"] is not None]
        worst = min(ms, key=lambda kv: kv[1])
        out[name] = {"worst": worst[0], "margin": worst[1],
                     "violated": [k for k in r["violated"] if k in UNCERTAIN_CHECKS + ("C2o",)]}
    return out
