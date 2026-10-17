# v2 step 3: constraints and optimizer, what came out

_2026-10-16. Design step 3 of §6 in `docs/PHYSICS_MODEL_DESIGN.md`. Code: `physics_v2/optimize.py`; tests: `tests/test_v2_optimize.py`. The v1 engine and the pipeline are unchanged._

**Round 2 (end of this file) supersedes the defaults below:** C1 now applies to every flute, runout is eccentric, C3/C4 are provisional vendor-derived limits, and C11/C12 replace the 0.02·D floor. The Round 1 sections are kept as the record of why.

## What is built

| Part | Where | Notes |
|---|---|---|
| C1–C10, one pure function each | `c1_min_chip` … `c10_work_hardening` | Each returns value, limit, margin, units and a cited source (`SRC`). |
| Runout chips per flute | `Engagement.max_chips` | h_k(φ) = max(0, min_m(m·fz·sin φ + r_k − r_(k−m))), flute k engaging ae − (r_max − r_k). |
| Lateral force, centroid, torque | `Engagement.loads` | Integrated along the helical edge at every rotation sample. Without runout it matches step 2's `lateral_force` mean exactly, and its peak to < 1 %. |
| Deflection | `compliance_integral`, `deflection_in` | v1's exact profile integral and inertia, with the load at a: δ(b) = F/E·∫(x − a)(x − b)/I dx. Identical to v1 for a tip load. |
| Stress | `critical_sections`, `section_stress` | Flute root (core circle), every diameter step, holder face; σ1 with torsion. |
| Optimizer | `optimize` | Rough/adaptive, slot, finish; Z-level credit; robust choice; provenance; robustness report. |

C3 and C4 take the **largest deflection and stress over a revolution**. In a deep, narrow cut a single helical load band travels up the flute, so the force barely changes while its lever arm does. Taking the centroid at the peak-force instant gave deflections that jumped 8× between neighbouring cuts.

## Difference from step 2 (not changed there)

`forces.cutting_forces` reports the worst flute's chip as (fz + TIR)·sin φe. The radial offset is not scaled by sin φe, so the chip is fz·sin φe + TIR. The two agree for wide cuts (Harvey's 0.4·D example: 0.000450" vs 0.000455"). The step-2 form understates narrow cuts: at 0.1·D it gives 0.6·(fz + TIR) instead of 0.6·fz + TIR. `optimize.py` uses the correct form. The step-2 doctest is untouched.

## T12 and T1 in 17-4 H1025 (Speedio 16k, TIR 0.0002", aggressiveness 50 %)

| Tool | Op | Model | ap | ae | SFM | fz | IPM | MRR in³/min | Peak side load | Binding |
|---|---|---|---|---|---|---|---|---|---|---|
| T12 | adaptive | v1 | 0.0119" (0.19·D) | 0.0156" (0.25·D) | 262 | 0.00054 | 34.6 | 0.0064 | 30 N (v2 forces) | v1: deflection |
| T12 | adaptive | v2 | 0.1875" (3·D, LCF) | 0.0013" (0.02·D) | 262 | 0.00026 | 16.8 | 0.0039 | 9.5 N | C3, C6, C7, ae floor |
| T1 | adaptive | v1 | 0.025" (0.2·D) | 0.0125" (0.1·D) | 383 | 0.00133 | 62.1 | 0.0194 | 79 N (v2 forces) | v1: deflection |
| T1 | adaptive | v2 | 0.5" (4·D, LCF) | 0.0025" (0.02·D) | 255 | 0.00024 | 7.6 | 0.0095 | 18 N | C3, C6, ae floor |

- **Shape: deep and narrow, as the design expects.** At v1's deflection limit, every T12 and T1 optimum sits at full flute length.
- **Removal: lower than v1.** v1's own cut, run through the v2 forces, deflects T12 3.2× and T1 4.4× past the limit v1 itself uses, and breaks C2 and C4. v1 meets its limit only because its power-based force is 5–20× below Kienzle's.

## Vendor cuts on the same tools

Each 17-4 vendor row at 1/16" and 1/8" is evaluated on T12/T1 geometry (4 flutes):
- C3 is v1's adaptive deflection limit.
- C4 is 0.75·0.375·3.8 GPa.

| Tool | Source (flutes) | ap × ae (·D) | SFM | fz | Peak side load N | δ / C3 | σ1 / C4 |
|---|---|---|---|---|---|---|---|
| T12 | OSG 3604 (4) | 1.50 × 0.05 | 229 | 0.00040 | 31 | 2.8× | 1.4× |
| T12 | Helical HEV-5 (5) | 2.00 × 0.22 | 200 | 0.00040 | 102 | 7.8× | 4.0× |
| T12 | Helical HSV-4 (4) | 2.00 × 0.35 | 200 | 0.00030 | 122 | 8.9× | 4.6× |
| T1 | Harvey SF_73000 (4) | 3.00 × 0.25 | 150 | 0.00019 | 166 | 6.4× | 2.2× |
| T1 | Harvey SF_875400 (4) | 0.60 × 0.40 | 140 | 0.00053 | 178 | 9.2× | 2.9× |
| T1 | OSG 3604 (4) | 1.50 × 0.10 | 229 | 0.00090 | 169 | 7.6× | 2.5× |
| T1 | Helical HSV-4 (4) | 2.00 × 0.35 | 200 | 0.00060 | 372 | 14.6× | 4.9× |
| T1 | Kennametal HARVI I TE (4) | 1.50 × 0.50 | 330 | 0.00070 | 404 | 17.3× | 5.6× |

**Every published cut is 3–17× over v1's deflection limit and 1.3–5.6× over the C4 placeholder.** v2's MRR is set by C3. C3 is v1's limit, tuned against v1's low force model, so calibration (step 4) has to set C3 and C4 from these rows. Either:
- the limits rise to what vendors run; or
- the force model comes down (K_r, the ~0.79 tool factor, the core-circle stress section).

If C3 doubles, C4 (the stress placeholder) binds next and the cut stays deep and narrow:
- T12: 3·D × 0.026·D, 34 IPM, 0.010 in³/min;
- T1: 4·D × 0.02·D, 37.5 IPM, 0.047 in³/min (at 4× C3).

## Decisions for the user (not made here)

1. **Which flute C1 applies to.**
   - Default: the flute with the largest chip, §3.3's "worst flute". Rubbing flutes are allowed, and runout reaches the result through C2 and the forces.
   - The alternative, `c1_flute="thinnest"`, requires every flute to form a chip: fz·sin φe ≥ TIR + λ·r_β. At 0.0002" TIR that fz already breaks C3, so T12 and T1 come out shallow and wide (0.07·D × 0.9·D), like v1. With TIR 0.0001" both readings agree on deep and narrow.
   - A Blum-measured runout settles most of this.
2. **The C3 and C4 limits** (above), in calibration.
3. **The radial-engagement floor.** At the C3 limit, MRR keeps rising as ae shrinks:
   - The Kienzle size effect favours a thicker mean chip at a fixed force, and C2 only stops it near 0.002·D on T12.
   - The search therefore stops at 0.02·D, the lightest side-milling engagement any vendor publishes (OSG EXOCARB WXL 3604), and reports `ae_floor` as binding. T12 and T1 both sit on it.
   - Options: a physical term for very light engagement, an empirical floor (from vendors or from Fusion's stepover practice), or this value.
4. **Speed at light engagement.** The Taylor engagement term gives no extra speed below 0.1·D (Sandvik Dura's lightest point); extrapolating it would push ae to the floor regardless.

## Placeholders (all labelled in `PLACEHOLDERS` and echoed in every result)

- **Material:** K_r 0.4; tool factor 1.0 (Sandvik implies ~0.79); kc hardness exponent 0.41.
- **Taylor speed:** anchor 262 SFM (Dura, P5.0.Z.AN, slot); v_c ∝ HB^−1; engagement exponent 0.4 with no credit below 0.1·D; n 0.25.
- **Tool:** h_tooth = 0.008·D (n = 1); r_β 2 µm.
- **Aggressiveness map:** stress fraction 0.6 + 0.3·a; tool life ×4^(0.5 − a); C2/C5 margin 0.2·(1 − a); λ across 0.4–0.2.

## Round 2 (user decisions, 2026-10-16)

### What changed

| Decision | Implementation |
|---|---|
| C1 on **every** flute | `c1_flute="thinnest"` is the default; "worst" stays as an option. |
| Eccentric runout (TIR = 2e) is the physical default | `runout_offsets_worst`: eccentric at the phase that thins one flute most. On 4 flutes that flute loses 0.71·TIR. The bound model (one flute high by the full TIR) is evaluated on every cut and reported as a warning only. |
| Provisional C3/C4 from the vendor rows | `tools/v2_provisional_limits.py` → `data/model_v2/provisional_limits.json` (see below). C3 for finishing stays v1's tolerance limit. Aggressiveness scales both limits by 0.7 + 0.6·a (1.0 at the default 50 %). |
| Minimum stepover from physics | **C12**: ae ≥ k·TIR with k = 2. At the eccentric worst phase the lowest flute engages ae − 0.71·TIR, and over all phases down to ae − TIR. At k = 2 that is still at least ae/2, so its engagement angle stays ≥ ~0.7× the highest flute's (φe ∝ √ae). At k = 1 its arc shrinks to nothing and the cut turns into a one-flute cut. **C11**: v_f ≤ the machine's max cutting feed (Speedio 30 m/min = 1181 IPM) and, for adaptive, an effective adaptive feed of 200 IPM (empirical, user-settable). The score is MRR with the feed capped, i.e. 1/(time per in³). Every result reports the toolpath length per in³, 1/(ap·ae). 0.02·D is only a reported sanity check. |

### Provisional limits (258 side/rough/HEM rows; 246 evaluated, 12 titanium rows skipped for lack of mc)

How each row is evaluated:
- **Model:** the row's own material, with the family's Sandvik row nearest its hardness scaled by (HB/HB_ref)^p.
- **Geometry:** catalog geometry; stickout is the reach (LB) or LCF, plus one shank diameter.
- **Runout:** 0.0002" eccentric.
- **Deflection:** the largest tip deflection over a revolution, with the load at its centroid.
- **Stress:** the largest σ1 at the flute root (core circle), the diameter steps and the holder face.

| Band | n | δ/D median (IQR; range) | σ1 MPa median (IQR; range) | Mean side load N (median; range) |
|---|---|---|---|---|
| 1/64–3/64 | 17 | 0.0059 (0.0050–0.0110; 0.0035–0.027) | 1577 (627–2439; 541–5396) | 2.8 (0.5–12) |
| 1/16–3/32 | 27 | 0.0060 (0.0017–0.0149; 0.0011–0.044) | 1288 (768–2771; 543–4335) | 35 (4.7–203) |
| 1/8–3/16 | 45 | 0.0097 (0.0070–0.0157; 0.0008–0.036) | 1946 (1113–2294; 523–3364) | 190 (20–552) |
| 1/4–3/8 | 79 | 0.0077 (0.0050–0.0119; 0.0007–0.032) | 1313 (913–1810; 265–3814) | 594 (46–2186) |
| 1/2–3/4 | 59 | 0.0053 (0.0026–0.0085; 0.0006–0.026) | 978 (578–1454; 199–2511) | 1783 (250–6472) |
| 1 and up | 19 | 0.0043 (0.0012–0.0062; 0.0003–0.0081) | 910 (371–1145; 96–1612) | 7137 (590–12913) |

- **Check against your side loads:** the 17-4 rows at 1/16" carry 4.7–75 N mean side load (one 3/32" Helical row 203 N). That matches your 10–67 N.
- **Spread:** within a band it is 10–40×. Some micro rows reach σ1 above TRS (5.4 GPa on a 1/32" 3-flute Harvey SF_958500 row), so either the core-circle section or the force model is conservative there. A median is robust to that; a percentile or a per-vendor weighting is calibration's call.
- **Against v1's adaptive limit** (0.0040·D at 1/16"), the band median is 1.5× at 1/16" and 2.4× at 1/8".

### T1 and T12 in 17-4 H1025 (Speedio 16k, TIR 0.0002", aggressiveness 50 %)

| Tool | Op | Model | ap | ae | fz | SFM | IPM | MRR in³/min | Toolpath in/in³ | Peak side load | Binding |
|---|---|---|---|---|---|---|---|---|---|---|---|
| T1 | adaptive | v1 | 0.0250" (0.20·D) | 0.0125" (0.10·D) | 0.00133 | 383 | 62.1 | 0.0194 | 3200 | 75 N | v1: deflection (v2 physics: violates C2, C3) |
| T1 | adaptive | v2 | 0.5000" (4·D) | 0.0012" (0.010·D) | 0.00263 | 255 | 82.0 | 0.0507 | 1619 | 79 N | C3, C6 |
| T1 | slot | v1 | 0.0050" (0.04·D) | D | 0.00072 | 253 | 22.3 | 0.0139 | 1600 | 16 N | v1: deflection |
| T1 | slot | v2 | 0.0133" (0.11·D) | D | 0.00067 | 135 | 11.0 | 0.0184 | 600 | 42 N | C3 |
| T12 | adaptive | v1 | 0.0119" (0.19·D) | 0.0156" (0.25·D) | 0.00054 | 262 | 34.6 | 0.0064 | 5389 | 28 N | v1: deflection (v2 physics: violates C2, C3, C4) |
| T12 | adaptive | v2 | 0.1875" (3·D) | 0.0008" (0.012·D) | 0.00113 | 262 | 72.5 | 0.0105 | 6895 | 23 N | C3, C6, C7 (rpm cap) |
| T12 | slot | v1 | 0.0044" (0.07·D) | D | 0.00036 | 262 | 23.0 | 0.0063 | 3653 | 9 N | v1: deflection (v2 physics: violates C2) |
| T12 | slot | v2 | 0.0079" (0.13·D) | D | 0.00025 | 141 | 8.5 | 0.0042 | 2021 | 14 N | C3 |

**Why the stepover is so narrow.** It is forced, not chosen:
- Every flute must cut, so fz·sin φe ≥ 0.71·TIR + λ·r_β.
- The side load of that minimum chip grows with ae (F ∝ ap·ae·fz·kc). At full flute length it breaks C3 for ae ≥ 0.02·D on T12 and ae ≥ 0.05·D on T1.
- On T12 at full depth the feasible window is 0.0064·D (C12) to about 0.015·D. C2 (the h_tooth placeholder) binds at the narrow end and C3 at the wide end.
- The 200 IPM cap does not bind: C3 holds the feed at 72–82 IPM, so toolpath length costs no extra time in the objective.

**Results:**
- T1 removes 2.6× v1 with half v1's toolpath.
- T12 removes 1.6× v1 but with 28 % **more** toolpath per in³ (6,900 vs 5,400 in), so on T12 the G-code size problem is not solved at 0.0002" TIR.
- T12's cut is runout-sensitive: at TIR ×2 it fails C1 and C12 outright.
- Slots stay shallow (C3); the C8 cap of 0.35·D does not bind.

**Finishing is infeasible at 0.0002" TIR.** The every-flute chip's side load already exceeds v1's finishing tolerance (0.00025" on T1, 0.000125" on T12), even for a 0.1" wall with 0.005" stock. On T1 it becomes feasible only near zero runout (0.00002" for a 0.125" wall).

### Open
- Program size needs its own cost (a time per path length, or a cap on toolpath per in³) if it matters beyond machining time. At the C3-limited feed, toolpath length is free in a time objective.
- The finishing conflict between C1-every-flute and the tolerance limit needs a rule. For example, finishing could check C1 on the wall-generating (highest) flute only, since the others never touch the finished wall.
- A measured TIR (Blum) moves every result above. At 0.0001" the T12 window roughly doubles.

## Round 3 (2026-10-16): find the invariant, fix the stress model, explain the T12 window

The user asked for physics before tuning, so no limit was tuned in this round:
- The C4 flute-root **section** changed (a model fix).
- The provisional C3/C4 medians were regenerated with that section.
- The three open decisions (program-size cost, finishing tolerance, measured runout) are held.

Tools:
- `tools/v2_invariants.py` writes `data/model_v2/invariants.json` (about 25 s).
- `tools/v2_provisional_limits.py` is unchanged in method.

### 1. What vendors design to

Each of the 246 side/rough/HEM rows (12 titanium rows skipped, no mc) is evaluated with weight 1, generic sheets included, on its own catalog geometry and material. The model is the optimizer's: eccentric runout at 0.0002" TIR, the fluted section, and stickout = reach + 1 shank diameter.

Spread (p90/p10) per band, from 1/64–3/64" to 1":

| Quantity | Overall CV | Overall p90/p10 | 1/64 | 1/16 | 1/8 | 1/4 | 1/2 | 1 |
|---|---|---|---|---|---|---|---|---|
| **worst-flute h_max / D** | **0.38** | **2.7** | 5.2 | **2.3** | 3.3 | 3.0 | 2.3 | 2.2 |
| F_t per tooth per mm of edge, kc·h_m (N/mm) | 0.75 | 10.8 | 5.7 | 2.9 | 2.9 | 3.2 | 2.7 | 2.2 |
| worst-flute h_max (mm) | 0.83 | 11.7 | 7.8 | 2.3 | 3.2 | 3.0 | 2.4 | 2.2 |
| h_m / D | 0.49 | 4.3 | 5.0 | 4.7 | 4.5 | 4.2 | 2.9 | 2.5 |
| F peak (N) | 1.57 | 124 | 21 | 4.9 | 4.5 | 4.1 | 4.6 | 2.9 |
| σ flute root (MPa) | 0.60 | 5.4 | 8.0 | 5.4 | 5.0 | 4.5 | 8.6 | 5.3 |
| F mean / D² | 0.61 | 5.4 | 6.3 | 7.5 | 5.3 | 4.0 | 5.2 | 3.7 |
| δ / D | 0.82 | 13.7 | 5.4 | **17.2** | 9.9 | 7.0 | 14.9 | 8.6 |
| δ (in) | 0.92 | 25 | 10 | 15 | 10 | 6.6 | 15 | 8.6 |
| σ in the shank at the step | 0.73 | 19 | 110 | 10 | 9.9 | 4.3 | 7.2 | 5.3 |
| power / D² | 0.94 | 15 | 54 | 13 | 15 | 16 | 10 | 7.4 |

**The invariant is the worst flute's chip, not deflection or stress.**
- At 0.0002" TIR the median h_worst/D is **0.0047–0.0054 in every band from 1/64" to 1"** (overall 0.0052; p10 0.0030, p90 0.0082).
- Edge load kc·h, which follows from the chip, is next.
- Deflection is among the loosest quantities (p90/p10 7–17 per band). It also depends on the stickout assumption: the δ/D median is 0.0036, 0.0071 and 0.0137 for reach + 0, 1 and 2 shank diameters.
- At TIR 0 the chip's spread widens (overall p90/p10 3.9; micro median 0.0018·D). Vendors' chips are consistent once a realistic runout is included.

**Proposal (for the user, not applied):**
- **C2 becomes the vendor-derived limit:** worst-flute h_max ≤ c·D, with c from these rows. The median is 0.0050·D at 1/16"; the current h_tooth placeholder 0.008·D × 0.9 sits at the 1/16" p90 (0.0082).
- **C3 and C4 stop being vendor medians.** Vendors don't hold them, and a median of a 5–17× spread rejects half of all published cuts by construction.
  - C4: the carbide fatigue limit on the corrected section (2 below).
  - C3: a process requirement, not a statistic. For finishing, the wall tolerance. For roughing, for example, the deflection must stay below the stock left for finishing.

### 2. The stress model

The flute-root stress of all 246 rows was evaluated under each assumption. The fatigue reference is 0.375 × 3.8 GPa = 1425 MPa.

| Variant | Median MPa | p90 | Max | Over fatigue | Over TRS |
|---|---|---|---|---|---|
| Round 1–2: core circle 0.6·D, K_r 0.4, kc ×1, TIR 0.0002 | 1254 | 2633 | 5396 | 104/246 | 5 |
| core circle 0.75·D | 668 | 1348 | 2763 | 17 | 0 |
| **fluted section = C3's own inertia (v1), outer fibre D/2 (now the default)** | **682** | **1377** | **2782** | **21** | **0** |
| equivalent cylinder 0.8·D, fibre 0.4·D | 551 | 1111 | 2276 | 5 | 0 |
| K_r 0.3 | 1217 | 2555 | 5233 | 99 | 4 |
| kc ×0.79 (Sandvik ToolGuide tool factor) | 991 | 2080 | 4263 | 67 | 1 |
| TIR 0 | 1146 | 2267 | 3956 | 89 | 1 |
| fluted section + kc ×0.79 | 538 | 1088 | 2198 | 5 | 0 |
| fluted section + kc ×0.79 + TIR 0 | 493 | 929 | 1611 | 3 | 0 |
| fluted section + kc ×0.79 + K_r 0.3 + TIR 0 | 479 | 901 | 1563 | 3 | 0 |

Each assumption:
- **Section (the main error).** The core circle ignores the teeth.
  - The deflection model the design says to reuse (v1 `fluted_core_inertia`) already gives the fluted section an inertia equal to a 0.805·D cylinder on 4 flutes. Kops & Vo (1990, CIRP Annals 39(1):93) report that end mill compliance matches an equivalent diameter of about 0.8·D.
  - Using that same section for stress is not a free choice; it makes C3 and C4 consistent. It removes every above-TRS case and cuts over-fatigue cases from 104 to 21.
  - **Citation caveat:** the Kops & Vo figure and Kivanc & Budak (2004, IJMTM 44:1151, which adds flute-arc and two-axis inertia) were seen only in secondary search summaries; the lookup could not fetch the papers.
  - One micro-milling breakage paper (JMMP 8(3):122, 2024; also secondary) still uses the core circle, and places the maximum stress at the tool–shank transition.
  - No source gives a flute-root stress concentration factor or a measured micro-tool core ratio.
- **Load position.** The centroid already moves with the helix at every rotation sample, and the root moment F·(x_root − a) is exact for the distributed load. Nothing to change.
- **K_r.** No primary steel or stainless Ktc/Krc table was found. Going from 0.4 to 0.3 moves the maximum by 3 %, so it is not the cause.
- **Edge forces.** Sandvik's kc1.1 is fitted to total force, so adding K_te/K_re would double-count. They can only raise force; there is no reduction to be had there.
- **Stickout** does not enter flute-root stress at all: the root moment involves nothing beyond the root (tested). It drives deflection (above) and the holder-face stress only.
- **Runout and the tool factor** each lower the maximum by 10–25 %.

**Which change brings every published cut below the fatigue limit?** None does on its own without being arbitrary.
- The fluted section is the physics fix and is now the default: 21 rows remain over.
- Adding Sandvik's measured 0.79 kc factor leaves 5. It is a calibration value, so it is not applied by default.
- Adding zero runout as well leaves 3, with a maximum of 1611 MPa, 1.13× the 10⁷-cycle limit:
  - Harvey SF_958500 3-flute at 1/32" and 1/16", 0.75·D × 0.5·D;
  - Sandvik Plura HD in P3.0 hardened, 1·D × 0.5·D.
- At 10⁶ cycles, about a tool's life, the fully reversed fatigue fraction is about 0.42 × TRS = 1596 MPa (Kursawe 2001 via Preis 2004). Only one row stays over at that level.

### 3. The T12 window vs published 1/16" cuts

Each published cut is evaluated:
- on its own catalog tool and material;
- on T12 (17-4 H1025, 3·D flutes, 0.5" stickout);
- at 0.0001" and 0.0002" TIR.

C3/C4 here are the current provisional medians, so the C4 limit is 664 MPa at 1/16".

| Cut | Tool | TIR | h_thin µin | h_worst µin | δ (in) | σ MPa | Fails |
|---|---|---|---|---|---|---|---|
| Helical HEV-5, 5FL, 2·D × 0.22·D, fz 0.0004, 200 SFM | catalog (LCF 2·D, stickout 0.375") | 0.0001 / 0.0002 | 275 / 215 | 382 / 429 | 0.00021 / 0.00025 | 1027 / 1150 | C4 |
| | T12 | 0.0001 / 0.0002 | 263 / 191 | 405 / 475 | 0.0016 / 0.0018 | 1771 / 1982 | C3, C4 (+C2 at 0.0002) |
| Kennametal GOmill GP, 1.75·D × 0.10·D, fz 0.0004, 340 SFM (316 row) | catalog (LCF 1.75·D, stickout 0.234") | 0.0001 / 0.0002 | 168 / 96 | 311 / 381 | 0.00008 / 0.00010 | 368 / 430 | none |
| | T12 (17-4) | both | 168 / 96 | 311 / 381 | 0.0009 / 0.0010 | 974 / 1099 | C3, C4 |
| Harvey SF_875400, 0.6·D × 0.4·D, fz 0.00026, 140 SFM | catalog (LCF 3·D, stickout 0.311") | 0.0001 / 0.0002 | 184 / 113 | 325 / 396 | 0.0008 / 0.0010 | 1197 / 1431 | C3, C4 |
| | T12 | both | 184 / 113 | 325 / 396 | 0.0011 / 0.0014 | 1223 / 1463 | C3, C4 |

**Why the model's window (0.006–0.015·D at full depth) disagrees with these cuts:**
1. **Not C1, C2 or C12.** Every published cut keeps every flute cutting at both TIRs, because their thinnest chip is 96–275 µin against h_min 24 µin. They are wide enough, at 0.1–0.4·D, that sin φe is large, so a modest fz clears 0.71·TIR.
2. **C3 and C4 are medians of the vendor rows**, so about half the vendor cuts break them by construction.
   - At full depth on T12 the C3 allowance is 0.000375", which permits only about 10–25 N of side load.
   - Any ae wide enough for a comfortable chip then needs more force than that. Only the sliver between C12 (2·TIR) and about 0.015·D survives, where chip thinning lets a large fz clear 0.71·TIR at low force.
3. **T12 is a weaker tool than the catalog tools it is compared with.**
   - Its flute is 3·D long against 1.75–2·D.
   - It sticks out 0.5" against 0.23–0.38".
   - The same HEV-5 cut deflects T12 7.4× more than its own tool, and the GOmill cut 11×.
   - The vendors' "deep" cut is deep relative to a shorter flute.

**With the proposed physics basis** (C4 = 1425 MPa fatigue on the fluted section, no vendor-median C3 for roughing), T12 at full depth opens to 0.006–0.25·D at 0.0002" (0.003–0.50·D at 0.0001"). The best cut is about 0.12·D, which is GOmill's width.

T12 and T1 adaptive, current defaults vs the proposed physics basis (what-if, not applied):

| Tool | TIR | Basis | ap | ae | fz | SFM | IPM | MRR in³/min | Toolpath in/in³ | δ (in) | σ MPa | Binding |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| T12 | 0.0002 | current | 3·D | 0.012·D | 0.00113 | 262 | 72.5 | 0.0105 | 6895 | 0.00037 | 416 | C3, C6, C7 |
| T12 | 0.0002 | physics | 3·D | 0.124·D | 0.00045 | 253 | 27.8 | **0.0405** | **686** | 0.00127 | 1424 | C2, C4, C6 |
| T12 | 0.0001 | current | 3·D | 0.007·D | 0.00231 | 262 | 147.8 | 0.0118 | 12573 | 0.00034 | 385 | C2, C6, C7 |
| T12 | 0.0001 | physics | 3·D | 0.137·D | 0.00045 | 248 | 27.4 | 0.0441 | 621 | 0.00123 | 1425 | C4, C6 |
| T1 | 0.0002 | current | 4·D | 0.010·D | 0.00263 | 255 | 82.0 | 0.0507 | 1619 | 0.00121 | 486 | C3, C6 |
| T1 | 0.0002 | physics | 4·D | 0.065·D | 0.00130 | 255 | 40.5 | **0.1639** | **247** | 0.00339 | 1425 | C4, C6 |
| T1 | 0.0001 | physics | 4·D | 0.078·D | 0.00110 | 255 | 34.3 | 0.1676 | 205 | 0.00332 | 1424 | C4, C6 |

v1 for reference: T12 0.0064 in³/min at 5389 in/in³; T1 0.0194 at 3200.

Under the physics basis:
- T12 removes 6.3× v1 with 7.9× less toolpath per in³.
- T1 removes 8.4× v1 with 13× less toolpath.
- Both stay at full flute length.

The cost is deflection: 0.0013" on T12 and 0.0034" on T1 at the tip during roughing. That is the quantity a process-based C3 (the stock left for finishing) would bound.

## Round 3, part 2 (2026-10-16): program size and finishing tolerance, from the user's NC files

Runout default stays 0.0002" (eccentric). All numbers are 17-4 H1025 on the Speedio 16k at aggressiveness 50 %.

### Program-size model (user's 239 Fusion → Brother C00 programs, 100 adaptive ops)

- size ≈ 23.1 bytes/line × L_cut / s, with L_cut = V/(ap·ae)·(1 + 0.15).
  - 23.1 bytes per motion line (p10–p90 21.5–26.1).
  - 0.15 linking factor, empirical.
  - s is the mean point spacing: 0.22 mm typical (p10–p90 0.10–0.40); 0.04 mm is the bad case for micro tools at tight tolerance (T12, O0175).
- That is 2,667 bytes per inch of cutting path at s = 0.22 mm and 14,669 at 0.04 mm. The user's "about 2,860" corresponds to s ≈ 0.205 mm.
- `optimize.program_bytes`. Every result reports bytes per in³, in³ per 6 MB at both spacings, and bytes for the operation when `removal_volume_in3` is given.
- **"Limit program size"** is the optional C13: `limit_program_size=True`, `program_limit_bytes` (default 6 MB), `removal_volume_in3` (required when on), `point_spacing_mm` (default 0.22). It is off by default.
- **CAM-side fix:** the largest real files came from Fusion "Fine stepdown" levels 0.002–0.005 mm apart (hundreds of Z levels). That is a CAM setting, not part of the cut model. Set Fine Stepdown to at least ¼ of the stepdown and never under 0.05 mm (OPEN_ITEMS, Fusion add-in).

| Tool | Basis | ap | ae | IPM | MRR in³/min | Toolpath in/in³ | MB/in³ at s 0.22 / 0.04 mm | in³ per 6 MB at 0.22 / 0.04 | Binding |
|---|---|---|---|---|---|---|---|---|---|
| T12 | v1 | 0.19·D | 0.25·D | 34.6 | 0.0064 | 5387 | 16.5 / 90.9 | 0.36 / 0.07 | |
| T12 | current (provisional C3/C4) | 3·D | 0.012·D | 72.5 | 0.0105 | 6895 | 21.1 / 116 | 0.28 / 0.05 | C3, C6, C7 |
| T12 | proposed physics (C4 fatigue, no roughing C3) | 3·D | 0.124·D | 27.8 | 0.0405 | 686 | 2.1 / 11.6 | 2.85 / 0.52 | C2, C4, C6 |
| T1 | v1 | 0.20·D | 0.10·D | 62.1 | 0.0194 | 3200 | 9.8 / 54.0 | 0.61 / 0.11 | |
| T1 | current | 4·D | 0.010·D | 82.0 | 0.0507 | 1619 | 5.0 / 27.3 | 1.21 / 0.22 | C3, C6 |
| T1 | proposed physics | 4·D | 0.065·D | 40.5 | 0.1639 | 247 | 0.76 / 4.2 | 7.9 / 1.44 | C4, C6 |

**MRR vs program size** (`optimize(...)["trade"]`: the cuts no other cut beats on both MRR and program size).

| Tool, basis | Cut (ap × ae) | MRR in³/min | MB/in³ at 0.22 / 0.04 mm |
|---|---|---|---|
| T12, physics | 3·D × 0.241·D | 0.0322 | 1.09 / 5.98 |
| | 3·D × 0.173·D | 0.0361 | 1.51 / 8.32 |
| | 3·D × 0.124·D (chosen) | 0.0405 | 2.10 / 11.6 |
| T12, current | 0.13·D × 0.9·D | 0.0043 | 6.9 / 37.9 |
| | 3·D × 0.017·D | 0.0095 | 15.2 / 83.6 |
| | 3·D × 0.012·D (chosen) | 0.0106 | 21.2 / 116 |
| | 3·D × 0.009·D | 0.0110 | 29.4 / 162 |
| T1, physics | 4·D × 0.291·D | 0.108 | 0.17 / 0.93 |
| | 4·D × 0.137·D | 0.139 | 0.36 / 1.96 |
| | 4·D × 0.094·D | 0.156 | 0.52 / 2.86 |
| | 4·D × 0.065·D (chosen) | 0.164 | 0.76 / 4.17 |
| T1, current | 4·D × 0.044·D | 0.036 | 1.10 / 6.07 |
| | 4·D × 0.010·D (chosen) | 0.051 | 4.96 / 27.3 |
| | 4·D × 0.007·D | 0.055 | 7.23 / 39.8 |

- On the physics basis, T12 halves its program size for 20 % less MRR (0.124·D → 0.241·D).
- T1 cuts its program 4.5× for 34 % less MRR.
- On the current basis every T12 adaptive cut needs 15–29 MB per in³ at typical spacing, so a 6 MB program holds under 0.4 in³.

### Finishing: user wall tolerance, wall error, C1 on every flute

- C3 for finishing is now the user's wall tolerance: `wall_tolerance_in`, default 0.005 mm (0.0002"), sometimes 0.001 mm. It replaces v1's fixed 0.00025".
- It is checked against the **wall error**: the tip deflection normal to the wall (positive = pushed off the wall, stock left), largest over a revolution.
- Every result reports the wall error as max, **mean** (systematic, which Blum wear compensation removes) and **ripple** (max − min over a revolution, which it cannot). The ripple is an approximation of the error's variation along the wall height. C1 still holds on every flute.

| Tool | Wall | Stock | TIR | Feasible | fz | IPM | Wall error max / mean / ripple (µm) |
|---|---|---|---|---|---|---|---|
| T1 | 0.4" | 0.002" | 0.0002 | no | 0.00068 | 21.3 | 9.8 / 5.5 / 8.3 |
| T1 | 0.125" | 0.002" | 0.0002 | no | 0.00068 | 21.3 | 8.0 / 2.9 / 8.0 |
| T1 | 0.125" | 0.002" | 0.0001 | **yes** | 0.00041 | 12.7 | 5.0 / 2.0 / 5.0 |
| T1 | 0.4" | 0.005" | 0.0002 | no | 0.00043 | 13.3 | 17.6 / 10.2 / 14.6 |
| T12 | 0.1875" (3·D) | 0.002" | 0.0002 | no | 0.00049 | 31.1 | 7.0 / 3.7 / 6.0 |
| T12 | 0.1875" | 0.002" | 0.0001 | **yes** | 0.00033 | 21.3 | 5.0 / 2.8 / 4.0 |
| T12 | 0.0625" | 0.002" | 0.0001 | **yes** | 0.00057 | 36.2 | 5.0 / 2.6 / 4.9 |
| T12 | 0.1875" | 0.005" | 0.0002 | no | 0.00031 | 19.8 | 12.8 / 7.1 / 10.8 |

For infeasible rows, fz is the smallest feed C1 allows and the wall error is at that feed.

**At 0.0002" TIR no finishing pass holds 5 µm**, because the chip every flute needs (fz·sin φe ≥ 0.71·TIR) already deflects the tool 6–18 µm.
- Blum compensation of the mean is not enough: the ripple alone is 6–15 µm.
- At 0.0001" TIR, a light pass (0.002" stock) holds 5 µm on both tools.
- Finishing is therefore where a measured runout matters most. A thinner stock, or C1 on the wall-generating flute only, are the other levers (still an open decision).

## Round 4 (2026-10-16): the adopted basis

### What changed

The user adopted the Round 3 proposal. Defaults now:

| Constraint | Basis |
|---|---|
| **C2** | Worst-flute h_max (eccentric runout included) ≤ the **vendor median of worst-flute h_max/D** for the diameter band, ×(0.7 + 0.6·a) for aggressiveness (×1.0 at 50 %). Source: `data/model_v2/chip_limits.json`, written by `python tools\v2_invariants.py --chip-only`. `Material.h_tooth_c` remains as an explicit override. |
| **C3**, roughing/adaptive/slot | Wall-normal tip deflection (largest over a revolution) ≤ **50 % of the radial stock to leave**. `stock_to_leave_in`, default 0.05 mm, user-settable; the user typically leaves 0.05–0.1 mm. |
| **C3**, finishing | Unchanged: wall tolerance (default 0.005 mm). Wall error reported as max / mean (Blum-compensable) / ripple. |
| **C4** | Carbide fatigue at 10⁷ cycles: 0.375 × TRS 3.8 GPa = **1425 MPa**, ×(0.7 + 0.6·a), on the fluted section shared with C3. Sandvik's 0.79 force factor stays off (calibration, step 4). |
| Vendor-median C3/C4 (Round 2) | Removed from the default path. Reported per cut as `vendor_median_comparison`. |
| C13 "Limit program size" | Unchanged: off by default, 6 MB. |
| Finishing C1 | Still every flute (open with the user). `c1_flute="wall"` checks only the wall-generating (outermost) flute and is reported alongside. |

C2 limits by band (worst-flute h_max / D, TIR 0.0002" eccentric):

| Band | n | Median (limit at a = 50 %) | p10 | p90 |
|---|---|---|---|---|
| 1/64–3/64 | 17 | 0.00538 | 0.00224 | 0.01154 |
| 1/16–3/32 | 27 | 0.00504 | 0.00361 | 0.00817 |
| 1/8–3/16 | 45 | 0.00544 | 0.00328 | 0.01093 |
| 1/4–3/8 | 79 | 0.00539 | 0.00281 | 0.00829 |
| 1/2–3/4 | 59 | 0.00495 | 0.00304 | 0.00697 |
| 1 and up | 19 | 0.00470 | 0.00285 | 0.00638 |

### T1 and T12 (17-4 H1025, Speedio 16k, aggressiveness 50 %, stock to leave 0.05 mm → C3 0.000984")

| Tool | Op | TIR | ap | ae | fz | SFM | IPM | MRR in³/min | MB/in³ at s 0.22 / 0.04 mm | Wall deflection / allowed (in) | σ1 MPa | Binding |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| T1 | adaptive | 0.0002 | 0.500" (4·D) | 0.0026" (0.021·D) | 0.00188 | 255 | 58.6 | 0.0768 | 2.34 / 12.9 | 0.000962 / 0.000984 | 726 | C2, C3, C6 |
| T1 | adaptive | 0.0001 | 0.500" (4·D) | 0.0029" (0.023·D) | 0.00184 | 255 | 57.5 | 0.0828 | 2.13 / 11.7 | 0.000983 / 0.000984 | 751 | C3, C6 |
| T1 | slot | 0.0002 | 0.0133" (0.11·D) | D | 0.00053 | 135 | 8.8 | 0.0147 | 1.84 / 10.1 | 0.000984 / 0.000984 | 344 | C2, C3 |
| T1 | slot | 0.0001 | 0.0133" (0.11·D) | D | 0.00060 | 135 | 10.0 | 0.0166 | 1.84 / 10.1 | 0.000983 / 0.000984 | 347 | C2, C3 |
| T12 | adaptive | 0.0002 | 0.1875" (3·D) | 0.0108" (0.173·D) | 0.00023 | 236 | 13.2 | 0.0269 | 1.51 / 8.3 | 0.000874 / 0.000984 | 1173 | C2, C6 |
| T12 | adaptive | 0.0001 | 0.1875" (3·D) | 0.0125" (0.200·D) | 0.00028 | 229 | 15.4 | 0.0362 | 1.31 / 7.2 | 0.000984 / 0.000984 | 1352 | C3, C6 |
| T12 | slot | 0.0002 | 0.0219" (0.35·D) | D | 0.00017 | 141 | 6.0 | 0.0081 | 2.24 / 12.3 | 0.000801 / 0.000984 | 876 | C2, C8 |
| T12 | slot | 0.0001 | 0.0219" (0.35·D) | D | 0.00024 | 141 | 8.4 | 0.0115 | 2.24 / 12.3 | 0.000797 / 0.000984 | 887 | C2, C8 |

v1 for reference: T12 adaptive 0.0064 in³/min (16.5 MB/in³); T1 adaptive 0.0194 (9.8 MB/in³); T12 slot 0.0063; T1 slot 0.0139.

**Against v1:**
- T12 adaptive: 4.2× the MRR with 11× less program per in³.
- T1 adaptive: 4.0× the MRR with 4× less program.
- Every roughing cut sits at full flute length.

**Slots:**
- T1 slot: 1.06× v1's MRR.
- T12 slot: 1.3× v1 at 0.0002" TIR, 1.8× at 0.0001". It reaches the 0.35·D micro-slot cap (C8).

**MRR vs program size (adaptive):**
- **T12 at 0.0002"** has no trade. The C1/C2 window leaves fz·sin φe only 0.000165–0.000174", so MRR rises with ae, and the widest feasible cut is both fastest and smallest.
- **T12 at 0.0001":**

  | ae | MRR | MB/in³ at 0.22 / 0.04 mm |
  |---|---|---|
  | 0.42·D | 0.0225 | 0.62 / 3.4 |
  | 0.29·D | 0.0284 | 0.90 / 4.9 |
  | 0.20·D (chosen) | 0.0362 | 1.31 / 7.2 |

- **T1 at 0.0002":**

  | ae | MRR | MB/in³ at 0.22 / 0.04 mm |
  |---|---|---|
  | 0.065·D | 0.0459 | 0.76 / 4.2 |
  | 0.044·D | 0.0560 | 1.10 / 6.1 |
  | 0.031·D | 0.0673 | 1.61 / 8.8 |
  | 0.021·D (chosen) | 0.0768 | 2.34 / 12.9 |

  Widening from 0.021·D to 0.065·D gives up 40 % of MRR for a 3× smaller program.

### Finishing (full-flute wall, stock = the roughing's 0.05 mm or 0.1 mm, tolerance 0.005 mm)

| Tool | TIR | Stock | C1 every flute (default) | C1 wall-generating flute only |
|---|---|---|---|---|
| T1 | 0.0002 | 0.05 mm | **infeasible**: wall error 9.7 µm (mean 5.3, ripple 7.7) | 8.7 IPM, wall 5.0 µm (mean 2.5, ripple 4.8) |
| T1 | 0.0002 | 0.10 mm | infeasible (14.9 µm) | 3.6 IPM |
| T1 | 0.0001 | 0.05 mm | infeasible: 6.1 µm (mean 3.4, ripple 4.7) | 9.0 IPM, 5.0 µm (mean 2.7, ripple 4.2) |
| T12 | 0.0002 | 0.05 mm | infeasible: 6.9 µm (mean 3.7, ripple 6.0) | 19.7 IPM, 5.0 µm (mean 2.5, ripple 4.6) |
| T12 | 0.0002 | 0.10 mm | infeasible (10.9 µm) | 7.9 IPM |
| T12 | 0.0001 | 0.05 mm | **21.8 IPM**, 5.0 µm (mean 2.8, ripple 4.0) | same |
| T12 | 0.0001 | 0.10 mm | infeasible (6.9 µm) | 7.9 IPM |

**Finishing C1 decision (open):**
- With every flute cutting, only T12 at 0.0001" with 0.05 mm stock finishes inside 5 µm.
- Checking only the wall-generating flute makes every case feasible, at 3.6–21.8 IPM. The other flutes then rub lightly behind it.
- In the feasible cases the mean wall error, which Blum compensation removes, is 2.5–2.8 µm, and the ripple is 4.0–4.8 µm.

### Step 3 status

Ready for review and merge by the local session. Items for step 4 (calibration):
- the 0.79 force factor;
- K_r;
- the Taylor constants and engagement exponent;
- the aggressiveness map.

Items still open with the user:
- finishing C1 (every flute or wall flute);
- measured runout per tool (Blum).

## Round 5 (2026-10-17): merged data, review fixes, finishing as a target, micro tools

### A. The merged vendor data (`origin/toolwiz/v2-data2`)

| Set | Rows in | Evaluated | Skipped |
|---|---|---|---|
| Side / rough / HEM | 1,777 | 1,466 (Round 4: 246) | 307 titanium (no Kienzle mc), 4 Helical GB2016 rows with no LCF |
| Slot | 756 | 628 | 128 titanium |

**Generator fixes:**
- **Null LCF/SFDM crash.** Both generators now skip a row missing required geometry and print the counts by reason. The counts are also stored as `skipped` / `skipped_slot` in `chip_limits.json`.
- **Mojibake en dash.** The file was valid UTF-8. Windows reads it as cp1252, so "–" showed as "â€“". Band labels are now ASCII ("1/64-3/64") and all three files are written with `ensure_ascii=True`. A test checks that the file is pure ASCII and equals the generator's output.

**C2 limits (worst-flute h_max / D at TIR 0.0002", eccentric runout, max over phase):**

| Band | Round 4 median (n 246) | Round 5 n | Round 5 median | p10 | p90 | p90/p10 | B5 phase effect alone |
|---|---|---|---|---|---|---|---|
| 1/64-3/64 | 0.00538 | 115 | **0.00863** | 0.00399 | 0.01536 | 3.8 | +19.5 % |
| 1/16-3/32 | 0.00504 | 149 | **0.00580** | 0.00335 | 0.00791 | 2.4 | +9.0 % |
| 1/8-3/16 | 0.00544 | 226 | **0.00486** | 0.00256 | 0.00894 | 3.5 | +2.9 % |
| 1/4-3/8 | 0.00539 | 396 | **0.00441** | 0.00226 | 0.00760 | 3.4 | +1.0 % |
| 1/2-3/4 | 0.00495 | 382 | **0.00388** | 0.00224 | 0.00669 | 3.0 | 0 |
| 1 and up | 0.00470 | 198 | **0.00328** | 0.00164 | 0.00525 | 3.2 | 0 |

**How C2 moved:**
- **What moved it.** The "phase effect" column is the B5 change (worst chip at the worst phase) on the merged data. Everything else is the new data.
- **Trend with D.** The median used to be flat with D (0.0047–0.0054). It now falls with D, from 0.0086 to 0.0033. At micro sizes the fixed 0.0002" TIR is a large share of the worst-flute chip, so the micro median rises. At 1" and up the new Sandvik, Seco and Kennametal rows run thinner chips.
- **Spread.** It widened a little: p90/p10 per band is now 2.4–3.8, against 2.2–3.3 in Round 4.
- **Still the tightest invariant.** h_worst/D is still the best-collapsing quantity of the 15 tested: per-band p90/p10 2.4–3.8, against 2.8–3.4 for edge load per mm and 4.4–8.7 for flute-root stress (`data/model_v2/invariants.json`).

**Slot and runout-free invariants (new, D3):**

| Band | Slot worst-flute median (n) | p10–p90 | Nominal fz·sin φe/D, side (p10–p90) | Nominal, slot |
|---|---|---|---|---|
| 1/64-3/64 | 0.00803 (94) | 0.00540–0.01905 | 0.00324 (0.00112–0.00887) | 0.00323 |
| 1/16-3/32 | 0.00577 (103) | 0.00411–0.00977 | 0.00343 (0.00140–0.00539) | 0.00339 |
| 1/8-3/16 | 0.00441 (106) | 0.00283–0.00789 | 0.00384 (0.00162–0.00769) | 0.00328 |
| 1/4-3/8 | 0.00423 (154) | 0.00257–0.00651 | 0.00397 (0.00169–0.00720) | 0.00370 |
| 1/2-3/4 | 0.00408 (114) | 0.00253–0.00628 | 0.00368 (0.00200–0.00641) | 0.00380 |
| 1 and up | 0.00332 (57) | 0.00227–0.00534 | 0.00316 (0.00153–0.00513) | 0.00320 |

- Slots now use `slot_bands`. If a band has no slot rows, they fall back to the side bands and the result says so.
- The nominal chip is flat with D (0.0032–0.0040), but its spread is wider: p90/p10 3.2–4.7, and 7.9 at micro sizes.

**Provisional (vendor-median) C3/C4 on the merged data.** These are reported only, as `vendor_median_comparison`.

| Band | δ/D median | σ1 median (MPa) |
|---|---|---|
| 1/64-3/64 | 0.00928 | 1401 |
| 1/16-3/32 | 0.00591 | 1001 |
| 1/8-3/16 | 0.00805 | 859 |
| 1/4-3/8 | 0.00903 | 771 |
| 1/2-3/4 | 0.00628 | 605 |
| 1 and up | 0.00348 | 387 |

**Outliers to flag for calibration:**
- **Stress outliers.** On the fluted section, 162 of 1,466 rows exceed carbide fatigue and 12 exceed TRS (max 7,085 MPa). They are mostly Harvey nickel-alloy micro rows (1/64–1/32" at 50 SFM, fz 5e-5–1.4e-4") and the SF_711700 5×LOC HEM rows.
- **Why.** The Kienzle size effect (mc 0.25 for the S2.0 group) extrapolated to chips of a few µm overstates force. This is a step-4 calibration item, not a reason to loosen C4.
- **Deflection outliers.** The provisional δ/D has absurd outliers, up to 1.26·D, for the same reason. It stays reported only.

### B. Review fixes

| # | Fix | Check |
|---|---|---|
| B1 | **C7 checks a supplied rpm.** The limit is machine max when rpm ≤ the tool-life rpm, else min(machine max, tool-life rpm). | T1 at 40,000 rpm fails C7. So does 12,000 rpm, which is above the 7,802 rpm tool-life speed. |
| B2 | **C6 bounds ap by the exposed flute.** ap ≤ min(LCF, depth, flute exposed below the holder), from ToolProfile. ToolProfile warnings such as "Holder over flutes" appear in the result. | ap 0.7" on a tool with 0.4" stickout fails C6 and carries the warning. |
| B3 | **Wider depth search.** The Z-level grid now spans N = n_min … depth/ap_floor, log-spaced. Slot depth caps (C8) apply as the top of the grid. | A 1/8" tool at depth 3.0" was falsely "infeasible" and is now feasible at N = 6. |
| B4 | **Per-constraint infeasibility.** "Infeasible" now names the constraint that eliminated the most candidates. `eliminated_by` counts each constraint separately, and the checks are shown at the closest candidate. | |
| B5 | **C2 uses the worst phase.** It takes the worst flute's chip at the runout phase that maximizes it (24 phases). The invariant is regenerated the same way. | A 3-flute worst chip is 17.8 % higher at the worst phase than at phase 0. |
| B6 | **C3 wall-normal uses the fy-only centroid.** The deflection uses cen_y = m_y/F_y, not the resultant's centroid. | |
| B7 | **Local ae refinement and an explicit fz cap.** A golden-section search on ae (log) runs between the chosen cut's grid neighbours. FZ_MAX_IN = 0.1" is now an explicit ceiling, warned when reached. | |
| B8 | **Binding at the search resolution.** Binding is judged at the resolution the window was found at, or at full resolution after fz backs off, and the result labels which (`binding_resolution`). With no active limit it reports "binding: none" with the margins. | `_Context` no longer swallows OSError/ValueError: a failed vendor-median load is logged and noted in the result. |

**Finishing feed placed at full resolution.** The finishing feed is also placed on the wall target at full resolution. This removes the earlier "target missed by 0.0 µm" readout.

### C. Finishing (user decisions 2026-10-17)

- **C1:** only the wall-generating flute must form a chip. Flutes that rub are a `WARNING: n flute(s) rub` in the result.
- **Wall target:** the 0.005 mm wall tolerance is a **target**. The optimizer takes the fastest feed that meets it. If no feed does, it returns the feed with the smallest predicted wall error and reports the shortfall. It never returns "infeasible" for this.
- **Hard part tolerance:** `part_tolerance_in` is optional and off by default. When set, it is a hard C3 limit.
- **What the target is checked on:** the ripple (`wall_metric="ripple"`) counts fully against the target. The mean is reported separately as `mean_blum_compensable_in`, together with max and ripple, under `wall_target`.

### D. Micro tools (reported; the C2 basis is unchanged)

- **Max feasible TIR.** Every infeasible cut now reports `max_feasible_tir_in`, found by bisection over coarse runs. This is the runout a holder or Blum check must show for the cut to work.
- **TIR mismatch.** When the machine TIR differs from the TIR `chip_limits.json` was built at (0.0002"), the result notes that the worst-flute limit is not like-for-like.
- **Slot invariant:** see A.
- **Alternative C2 basis** (`c2_basis="nominal"`):
  - C2 is checked on the runout-free chip fz·sin φe/D against the band median.
  - A second check, C2o, requires the worst-flute chip ≤ the band p90.
  - It was evaluated but **not adopted**.

| Tool, op | Worst-flute basis (adopted): MRR at TIR 0.0002 / 0.0001 | Nominal basis: MRR at TIR 0.0002 / 0.0001 |
|---|---|---|
| T12 adaptive | 0.0341 / 0.0428 | 0.0334 / 0.0359 (ae 0.211·D at 0.0001) |
| T12 slot | 0.0103 / 0.0136 | 0.0099 / 0.0099 |
| 1/32" adaptive | infeasible (max TIR 0.00017") / 0.0047 | infeasible (max TIR 0.00011") / 0.0041 (ae 0.155·D) |
| 1/32" slot | infeasible (max TIR 0.00016") / 0.0016 | infeasible (max TIR 0.00011") / 0.0009 |
| 1/64" adaptive | infeasible at both (max TIR 0.00008") | infeasible at both (max TIR 0.00004") |
| 1/64" slot | infeasible at both (max TIR 0.00007") | infeasible at both (max TIR 0.00004") |

**Why micro tools fail, and why the basis doesn't fix it:**
- Every-flute C1 in roughing needs the thinnest flute to cut. That forces fz·sin φe ≥ about 0.71·TIR plus the edge-radius minimum chip.
- At TIR 0.0002" and D < ~1/16", that exceeds the vendor *nominal* median chip, so the nominal basis is stricter there, not looser.
- So runout decides micro feasibility, not the C2 basis. The useful output is `max_feasible_tir_in`.

### E. Reruns

Conditions: 17-4 H1025, Speedio 16k, aggressiveness 50 %, stock to leave 0.05 mm (C3 0.000984"). Finishing is a full-flute wall with 0.05 mm stock. The 1/32" tool is 4FL, LCF 0.09375" (3·D), 1/8" shank, 0.5" stickout.

| Tool | Op | TIR | Cut | fz | SFM | IPM | MRR in³/min | MB/in³ at s 0.22 / 0.04 mm | Binding / wall |
|---|---|---|---|---|---|---|---|---|---|
| T1 | adaptive | 0.0002 | 4·D × 0.026·D | 0.00147 | 255 | 45.8 | 0.0738 | 1.91 / 10.5 | C2, C3, C6 |
| T1 | adaptive | 0.0001 | 4·D × 0.024·D | 0.00175 | 255 | 54.6 | 0.0822 | 2.04 / 11.2 | C2, C3, C6 |
| T1 | slot | 0.0002 | 0.14·D × D | 0.00034 | 135 | 5.6 | 0.0122 | 1.39 / 7.7 | C3 |
| T1 | slot | 0.0001 | 0.14·D × D | 0.00041 | 135 | 6.7 | 0.0148 | 1.39 / 7.7 | C3 |
| T1 | finish | 0.0002 | 4·D × 0.016·D | 0.00029 | 255 | 9.2 | 0.0090 | 3.12 / 17.1 | ripple 5.0 µm (met), mean 2.6, max 5.2; 2 flutes rub |
| T1 | finish | 0.0001 | 4·D × 0.016·D | 0.00046 | 255 | 14.4 | 0.0142 | 3.12 / 17.1 | ripple 5.0 (met), mean 4.0, max 6.7 |
| T12 | adaptive | 0.0002 | 3·D × 0.172·D | 0.00029 | 236 | 16.9 | 0.0341 | 1.52 / 8.4 | C2, C3, C6 |
| T12 | adaptive | 0.0001 | 3·D × 0.151·D | 0.00041 | 243 | 24.2 | 0.0428 | 1.74 / 9.5 | C2, C3, C4, C6 |
| T12 | slot | 0.0002 | 0.35·D × D | 0.00022 | 141 | 7.5 | 0.0103 | 2.24 / 12.3 | C2, C8 |
| T12 | slot | 0.0001 | 0.35·D × D | 0.00029 | 141 | 10.0 | 0.0136 | 2.24 / 12.3 | C2, C8 |
| T12 | finish | 0.0002 | 3·D × 0.031·D | 0.00037 | 262 | 24.0 | 0.0089 | 8.31 / 45.7 | ripple 5.0 (met), mean 2.9, max 5.7; 1 flute rubs |
| T12 | finish | 0.0001 | 3·D × 0.031·D | 0.00064 | 262 | 40.7 | 0.0150 | 8.31 / 45.7 | ripple 5.0 (met), mean 4.7, max 7.3 |
| 1/32" | adaptive | 0.0002 | **infeasible**: eliminated by C2 320, C4 79, C3 27; max feasible TIR 0.00017" | | | | | | C2 |
| 1/32" | adaptive | 0.0001 | 3·D × 0.061·D | 0.00041 | 131 | 26.5 | 0.0047 | 17.2 / 94.3 | C2, C4, C6, C7 |
| 1/32" | slot | 0.0002 | **infeasible**: C2; max feasible TIR 0.00016" | | | | | | C2 |
| 1/32" | slot | 0.0001 | 0.14·D × D (C8) | 0.00018 | 131 | 11.5 | 0.0016 | 22.4 / 123.4 | C2, C7, C8 |
| 1/32" | finish | 0.0002 | 3·D × 0.063·D | 0.00015 | 131 | 9.9 | 0.0018 | 16.6 / 91.4 | ripple 5.0 (met), mean 2.4, max 5.0; 2 flutes rub |
| 1/32" | finish | 0.0001 | 3·D × 0.063·D | 0.00023 | 131 | 14.8 | 0.0027 | 16.6 / 91.4 | ripple 5.0 (met), mean 3.5, max 6.2 |

**Against Round 4** (same conditions):
- **T1 adaptive** 0.0768 → 0.0738. The 1/8" C2 band fell from 0.00544 to 0.00486.
- **T12 adaptive** 0.0269 → 0.0341 at TIR 0.0002", and 0.0362 → 0.0428 at 0.0001". The 1/16" band rose from 0.00504 to 0.00580.
- **T1 slot** 0.0147 → 0.0122. The slot band is 0.00441 and C3 now binds.
- **T12 slot** 0.0081 → 0.0103 (slot band 0.00577).
- **Finishing.** Every case now meets 5 µm, because C1 needs only the wall flute. T12 finishes at 24.0 IPM at TIR 0.0002", against 19.7 IPM for Round 4's wall-flute variant.

**Against v1:** v1 gives T12 adaptive 0.0064, T1 adaptive 0.0194, T12 slot 0.0063 and T1 slot 0.0139 in³/min. Against those:
- T12 adaptive: 5.3× v1;
- T1 adaptive: 3.8× v1;
- T12 slot: 1.6× v1;
- T1 slot: 0.88× v1, since the new slot invariant is thinner than the side band it used before.

### Step 3 status

Round 5 items A–E are done. Items for step 4 (calibration):
- the 0.79 force factor;
- K_r;
- the Taylor constants and engagement exponent;
- the aggressiveness map;
- the Kienzle size effect at µm chips (the stress outliers above).

Items open with the user:
- whether to change the C2 basis for micro tools (evidence above: runout decides, not the basis);
- measured runout per tool.
