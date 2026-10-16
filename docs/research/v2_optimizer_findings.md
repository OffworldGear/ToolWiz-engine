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
