# v2 step 3: constraints and optimizer, what came out

_2026-10-16. Design step 3 of §6 in `docs/PHYSICS_MODEL_DESIGN.md`. Code: `physics_v2/optimize.py`; tests: `tests/test_v2_optimize.py`. The v1 engine and the pipeline are unchanged._

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
