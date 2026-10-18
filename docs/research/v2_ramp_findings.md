# v2 ramp / helical-entry model: what was built and what came out

_2026-10-18. Branch `toolwiz/v2-ramp` from `toolwiz/hardening` (ca5c1cf). v1 is unchanged: `gwizard_physics.calc_ramping` still sets v1's ramp angle and feeds, and every new result field is `None` under v1._

## 1. Summary

- **Data.** 568 ramp rows from 7 independent vendor groups were added to `tests/benchmarks/v2` (new `operation: "ramp"`, schema in `SCHEMA.md`, validator in `tests/test_v2_benchmark_dataset.py`). They include the two Sandvik CoroPlus ToolGuide helical readings.
- **Physics.** `physics_v2/ramp.py` covers:
  - the exact helix geometry;
  - the end-tooth axial chip h_a = fz·sin α;
  - the side cut as a slot of depth p = π·D_h·tan α, checked through C1–C5, C7, C8, C11 and C14;
  - R1, the end-tooth rubbing floor;
  - R2, the end-edge limit, calibrated from vendor plunge chips;
  - R6, the helix bounds;
  - R14, a vendor-consensus guardrail with ≥ 2 groups and stepwise widening.

  `optimize_ramp(...)` returns:
  - the ramp angle;
  - the helix diameter, as a fraction of D and in inches, and its minimum;
  - the ramp spindle speed, ramp feed and plunge feed;
  - the binding checks, overrides, conflicts and provenance.
- **Wiring.** `v2_bridge.apply` writes `ramp_angle`, `ramp_feed`, `plunge_feed`, `ramp_diameter`, `ramp_min_diameter` and `ramp_rpm` from the model, with the details in `result.v2["ramp"]`. `/api/calculate_for_fusion` returns `ramp_angle`, `ramp_diameter_in`, `ramp_min_diameter_in` and `ramp_rpm`.
- **Headline.** For the user's micro tools in 17-4 H1025, the vendors' ramp angles (median 2.8–3°) put the end teeth **under the rubbing floor** λ·r_β = 0.6 µm at any chip load the side cut allows. Physics wins (R1 is never relaxed), so v2 ramps at **5.1–5.9° for T12** and **3.2–3.5° for T1**, against v1's 1.0–1.2° and 2.0–2.3°. The answer rests on the edge radius r_β, which is still the 2 µm placeholder (§6, decision D1).

## 2. Data (`tests/benchmarks/v2`, operation `ramp`)

| Vendor group | Rows | What it publishes | Documents |
|---|---|---|---|
| Harvey Performance | 77 | Ferrous ramp angle 1–3° and non-ferrous 3–10°, a "suggested starting" range; helical entry with a helix over 110–120 % of D (bore vs tool-centre path not stated; recorded as bore ≥ 1.1·D) | Helical Machining Guidebook 2016 p.4 (image); In The Loupe "Most Common Methods of Tool Entry" (2017-07-17) and "Ramping to Success" (2017-05-10) |
| Kyocera SGS | 114 | **Z-Carb XPR: plunge, 3° ramp and 6° ramp rows with Vc and Fz for 12 material groups at 1/4–3/4"** (the only printed ramp chip loads); max ramp angle per series (Z1P 90°, Z5 7°, T-Carb 3°, H-Carb 1°); Z5 "ramp up to 5° using slotting speed and feed"; general 1–2° at slot feed, 25 % feed near 6°; M4 micro: helical ≤ 1° at slot feed, no plunging | Z-Carb XPR brochure pp.6–9; Global catalog V26.1 pp.24–26, 67; Micro catalog V26.1 p.97 |
| Sandvik (Sandvik + Seco) | 130 | CoroMill Dura max ramping angle by series (3–20°); Plura HD 2P342 RMPX by grade (P2BM 20°, M2CM 10°); **Seco Jabro recalculation tables**: max ramp angle, ramp/helical fz as % of slotting, helical bore ≥ 1.3·D, pitch 2–3 % of D, drilling fz %; **ToolGuide 1K344-0200 helical entry into a 4 mm hole at 200/345 HB** | Dura Catalogue 2024 pp.23, 32; product-data API; Seco SEM 2023.2 pp.563–572; CoroPlus ToolGuide session 2026-10-15 |
| Kennametal | 140 | HARVI IV "Maximum ramp angle is 2°"; DUO-LOCK HARVI I TE heads: helical-interpolation fz (feed factor vs side IPT) and plunging fn by material group | kennametal.com product data (HARVI IV, DUO-LOCK) |
| OSG | 62 | AE-VTSS 8233/8333 plunge table (incl. PH stainless, Ti, hardened steel) 1/8–1/2"; AE-VTS-N / VGM3-AL plunge (Al, Cu); EXOCARB graphite ramp ≈ 3° | OSG catalog Vol.1 pp.1345–1346 etc. |
| Emuge-Franken | 39 | Ramping-angle icon per series: TOP-Cut VAR 3–5°, TiNox-Cut N 1–2°, NF 3–5°, Base 1–3° (image-only, flagged) | TOP-Cut VAR and TiNox-Cut brochures |
| YG-1 | 6 | Alu-Power HPC "vertical ramping up to 20°" (aluminium only; a marketing line) | YU-HPC26 p.3 |
| Garr | 0 | Nothing on ramp, plunge or helical entry in the six tech sheets | — |

**Coverage for the user's case (17-4, ≤ 1/8").**
- 136 rows are filed under 17-4: 12 at ≤ 3/32", 26 at 1/8–3/16".
- Ramp angles come from Harvey, Kyocera, Emuge, Sandvik/Seco and Kennametal.
- Bore minimums come only from Harvey (ambiguous) and Seco.
- Printed ramp chip loads exist only at ≥ 1/4" (Kyocera XPR) and 2 mm (ToolGuide).
- Plunge chips come from OSG (1/8" and up) and Seco drilling factors; Kennametal and Kyocera give them only at ≥ 1/4".

**Rules applied:**
- Every row quotes the cells and carries a real part number with catalog geometry.
- Rule-derived factors carry `source.derivation`: Kyocera entry/slot Fz ratios, Seco % of slotting, Kennametal and OSG ratios to the same page.
- Series-level rules (Sandvik, Seco, SGS matrix, Harvey) are replicated per representative diameter and family, and the label says so.
- Image-only rows are flagged for the second check: Emuge, the Harvey guidebook page, Sandvik Dura p.32/p.23 and the ToolGuide readings.

**ToolGuide check.**
- The 2 mm tool in a 4 mm hole gives a tool-centre helix of 2 mm.
- At 345 HB, RMP 4.852° gives a pitch of π·2·tan 4.852° = 0.533 mm = 0.0210", exactly the printed AP. So RMP is measured on the tool-centre path, the convention used here.
- At 200 HB, RMP 14.18° implies 0.0625", twice the printed AP 0.0312". That run's hole or AP definition differs, so its pitch is left null.
- End chips: 0.0003"·sin 14.18° = 1.87 µm and 0.0003"·sin 4.852° = 0.645 µm.

## 3. Physics (`physics_v2/ramp.py`)

**Geometry.** The tool-centre helix has diameter D_h; the bore is D_h + D, and a core of D_h − D stands in the bore when D_h > D. The pitch is p = π·D_h·tan α, and fz is the feed per tooth along the tool-centre path. Fusion's helical ramp diameter and ramping angle are taken on this path (decision D5).

**End teeth.**
- The bottom face is always over floor.
- Every end tooth sweeps every floor point once per tooth period while the tool drops fz·sin α.
- So each end tooth cuts a uniform axial chip **h_a = fz·sin α**, which is also its chip normal to the edge (the cutting velocity lies in the bottom plane).
- The end torque is z·(kc(h_a)·h_a + K_te)·R²/2. Its power balances kc·(end MRR) exactly; this is tested.
- The end cut adds no net lateral force.
- A dished end would raise the trailing-half chip. It is not modelled, which keeps R1 conservative.

**Side teeth.**
- Relative to the bore, the tool's motion per tooth is a rotation about the helix axis.
- The normal displacement of a peripheral point at angle β is fz·cos α·sin β, whatever D_h is (the R-dependent part is tangential). So the side chip has the full-slot distribution: maximum fz·cos α at the front.
- The uncut height in front of the tool is the previous turn's floor, at most p.
- C3 and C4 take a slot of depth p (an upper bound).
- C5 adds the end torque to the side torque, scaled to the volume-balance depth tan α·(A_bore − πD²/4)/D. That depth is 0.625·p at D_h = 0.5·D and 0.75·p at D_h = D.
- Speed is C7 at slot engagement, capped by C14v for slots, exactly as for a slot.

**Checks.**

| Id | Check | Basis |
|---|---|---|
| R1 | h_a ≥ λ·r_β | C1's sources (λ 0.2–0.4; r_β 0.4–3.5 µm). λ is fixed at 0.3 by the consensus scheme. **Never relaxed.** |
| R2 | end-tooth chip ≤ vendor-median plunge chip h_p/D (by diameter band) × the C2 aggressiveness scale | Vendor plunge tables are the only published loads on the end edges alone: OSG, Kennametal, Kyocera, Seco drilling factors |
| R6 | 0.2·D ≤ D_h ≤ D | Upper bound: no standing core for a centre-cutting tool (bore ≤ 2·D). Lower bound: vendor-median minimum bore 1.2·D (Harvey 1.1, Seco 1.3) |
| C1–C5, C7, C8, C11, C14 | side cut as a slot of depth p | as for slots (C8 caps micro slot depth at p ≤ 0.35·D) |
| R14a | α ≤ s(a) × vendor-median maximum ramp angle | ≥ 2 vendor groups. Widening: diameter band → neighbouring hardness bins (rows without hardness join here) → family-wide |
| R14p | plunge feed ≤ s(a) × vendor-median plunge/slot factor × the ramp feed | The ramp's side cut is a slot, so its feed is the slot feed at the ramp speed |
| R1p, R2p | the plunge's axial chip within R1 and R2 | — |

**Why R2 is calibrated on plunge chips, not on ramp angles.**
- The vendors' ramp recommendations put **3–5× less chip** on the end edges than their own plunge tables. Examples:
  - ramp end chip h_a/D: 1.8·10⁻⁴ at 1/16" and 3.2·10⁻⁴ at 1/4";
  - plunge chip h_p/D: 1.7·10⁻³.
- Kyocera's XPR shows this on a single tool.
- So the vendors' ramp-angle limits are not about end-edge strength; they come from chip evacuation, heat and the slot-like side cut. The angle consensus is R14a's job.
- The ramp-derived end chip is kept as a reported table (`ramp_end_chip_reported` in `ramp.json`).
- With ramp-derived R2, T12's window was empty (0.27 µm under the 0.6 µm floor). The code still handles an empty window: it sets h_a on R1's floor and reports R2 as overridden.

**Objective and aggressiveness.**
- The objective is the fastest descent v_z = z·n·fz·sin α. Within 1 % of it, take the gentlest angle, then the largest helix.
- If no angle under the R14a cap meets R1 (with fz under C2/C14f), the **smallest physics-feasible angle** is used, i.e. as close to the vendors as physics allows. R14a is then listed in `overridden` and `conflicts`.
- Aggressiveness uses the consensus scheme: s = 0.92 at 50 % and 1.00 at 75 % (the vendor median), applied to C7, C2, C14, R2 and R14. λ, C3, C4 and C5 are not relaxed.
- At the R1 floor, a higher aggressiveness allows a larger fz, so the angle comes out *lower* at 75 % than at 50 %. The end chip stays on the floor.
- The plunge uses h_p at R2, capped by R14p and never under R1.

## 4. Calibration (`tools/calibrate_v2_ramp.py` → `data/model_v2/ramp.json`, `ramp_calibration_report.json`)

R2 (plunge chip h_p/D, median of vendor-group medians):

| Band | h_p/D | Widening | Groups |
|---|---|---|---|
| 1/64–3/64 | 1.73·10⁻³ | ± 2 bands | OSG 2.0·10⁻³, Sandvik 1.4·10⁻³ |
| 1/16–3/32 | 1.73·10⁻³ | + neighbouring bands | OSG, Sandvik |
| 1/8–3/16 | 1.73·10⁻³ | band | OSG 2.0·10⁻³, Sandvik 1.4·10⁻³ |
| 1/4–3/8 | 1.71·10⁻³ | band | Kennametal 1.1, Kyocera 3.9, OSG 2.3, Sandvik 0.56 (·10⁻³) |
| 1/2–3/4 | 1.64·10⁻³ | band | Kennametal 0.95, Kyocera 4.4, OSG 2.3, Sandvik 0.53 (·10⁻³) |

Reported only: the ramp end chip h_a/D is 1.8·10⁻⁴ (≤ 3/32", Kyocera M4 at 1° and the ToolGuide) and 2.9–3.6·10⁻⁴ (1/8"–3/4").

17-4 at 356 HB, R14 consensus (75 % = these medians):

| D | Angle median | Groups | Min bore | Plunge/slot |
|---|---|---|---|---|
| 1/16" | 3.0° | Kyocera 2.0, Harvey 3.0, Sandvik 7.5 | 1.38·D (Harvey 1.1, Sandvik 1.65) | — |
| 1/8" | 3.0° | Kyocera 5, Sandvik 5, Harvey 3, Emuge 2, Kennametal 2 (at ≥ 3/8") | 1.2·D | 0.20 (OSG, Kennametal) |
| 1/4"–1/2" | 3.0° | Kennametal 2, Kyocera 6, Emuge 2, Harvey 3, Sandvik 5 | 1.2·D | 0.20 |

**Residuals of the ramp angle** (`ramp_calibration_report.json` `residuals`):
- The metric is log(model angle / the vendor's maximum angle) on each vendor row's own tool geometry and material.
- There are 248 rows, run as unique tool/material combinations. 23 are skipped: 16 have no calibrated v2 family (graphite, cast aluminium, the Nickel Alloy family) and 7 are infeasible.
- "Inside" means the model angle falls within that vendor's own published range.

| Run | n | Median log ratio | Median abs log | Inside |
|---|---|---|---|---|
| All rows, tables from all rows, 75 % | 248 | −0.013 | 0.42 | 13 % |
| All rows, 50 % | 248 | −0.095 | 0.42 | 13 % |
| Hold-out rows (30 %, hashed by vendor group/document/family), tables from training rows, 75 % | 52 | −0.23 | 0.69 | 6 % |
| Physics only (R14 off), 75 % | 248 | +1.53 | 1.53 | 0 % |

By vendor at 75 %, the median log ratio is:
- Emuge −0.01 (62 % inside);
- Harvey +0.50 and Kennametal +0.45 (their 2–3° sit under the cross-vendor median, and R1 lifts micro tools);
- Kyocera −0.23 and Sandvik −0.12 (their 5–20° maxima sit above it).

By band: 1/16–3/32" is +0.54 (R1 lifts micro tools above the vendors); 1/8" and up is −0.01 to −0.04.

By family: 17-4 is −0.013 (91 rows), 316 −0.010, 4130 −0.12, H13 −0.19, Ti −0.12, Inconel +0.25.

**What this says:**
1. **At 75 % the model sits on the vendor median** (bias −1 %). At 50 % it sits 9 % below it, as the aggressiveness rule asks.
2. **The spread is the vendors' own.** Their maximum angles for comparable tools run from 1° (SGS H-Carb, M4 micro) to 20° (Sandvik Dura), so no single angle can fall inside most vendors' ranges. The hold-out bias (−0.23) is driven by Sandvik rows (−1.6) judged against a consensus built without Sandvik's documents.
3. **Physics alone does not bound the angle from above.** With R14 off, the end-edge limit (plunge chips) and the side checks allow angles about 4.6× the vendors' (e^1.53). The vendors' angle limits encode chip evacuation, heat and practice that the force model doesn't capture.
   - **Physics sets the floor: R1 (rubbing).** It binds on 21 of 248 rows, mostly micro tools.
   - **The consensus sets the ceiling: R14a.** It binds or is overridden on 236 rows.

   This mirrors C14's role for the cut. The cap is what keeps the angle at the vendors' level, so it should stay on; D2 covers what happens when it is below the floor.
4. Binding counts at 75 % (beyond R14a): R14p 212, C14f 142, C14v 131, C2 109, R6 91, C14m 90, R2p 36, C7 25, R1 21, C3 10, C5 8.

**Margins at the ramp for T1/T12** (1 − value/limit):

| | C2 | C3 | C4 | C5 | C8 |
|---|---|---|---|---|---|
| T1 50 % | 0.07 | 0.27 | 0.82 | 0.99 | — |
| T1 75 % | 0.09 | 0.29 | 0.83 | 1.00 | — |
| T12 50 % | 0.00 (binding) | 0.29 | 0.45 | 1.00 | 0.08 |
| T12 75 % | 0.00 (binding) | 0.33 | 0.50 | 1.00 | 0.19 |


## 5. T1 and T12 in 17-4 H1025 (356 HB), Speedio 16k, provisional BT30

**Tools.**
- T1: 1/8" 4FL, LCF 0.5, LB 0.6, 1/8" shank.
- T12: 1/16" 4FL, LCF 0.1875, LB 0.5, 1/8" shank.

**Setup.** v2 adaptive from `params.optimize`. The ramp comes from `optimize_ramp` with C14 and `ramp.json`. The v1 figures come from the v1 pipeline (its own rpm and feed).

| | T1 50 % | T1 75 % | T12 50 % | T12 75 % |
|---|---|---|---|---|
| **v2 ramp angle** | **3.47°** | **3.20°** | **5.87°** | **5.13°** |
| v1 ramp angle (calc_ramping) | 2.00° | 2.30° | 1.00° | 1.15° |
| Vendor cap R14a (s × median 3.0°) | 2.76° | 3.00° | 2.76° | 3.00° |
| Helix (tool centre) | 0.075" (0.60·D) | 0.075" | 0.0625" (1.0·D) | 0.0625" |
| Bore | 0.200" | 0.200" | 0.125" | 0.125" |
| Minimum helix | 0.025" | 0.025" | 0.0234" | 0.0234" |
| Pitch per turn | 0.0143" | 0.0132" | 0.0202" (0.32·D) | 0.0176" |
| Ramp rpm (C7 at slot engagement, C14v) | 3,936 | 4,278 | 8,625 | 9,375 |
| Adaptive rpm / feed | 6,640 / 15.64 IPM | 7,217 / 18.53 | 11,291 / 13.77 | 12,484 / 18.12 |
| Ramp fz | 0.000391" | 0.000424" | 0.000231" | 0.000264" |
| **Ramp feed** (at ramp rpm) | **6.15 IPM** | **7.25** | **7.96** | **9.91** |
| Ramp feed at the adaptive rpm (same chip) | 10.38 | 12.23 | 10.42 | 13.19 |
| **Plunge feed** | **1.06 IPM** | **1.36** | **1.45** | **1.96** |
| End chip h_a | 0.60 µm (R1 floor) | 0.60 µm | 0.60 µm | 0.60 µm |
| End chip at v1's angle with the v2 ramp fz | 0.35 µm | 0.43 µm | 0.10 µm | 0.13 µm |
| Binding | C14v, C14f, R1, R14a (overridden), R14p | same | C2, R1, R14a (overridden), R14p | same |
| v1 ramp / plunge feed (v1 pipeline) | 37.26 / 21.73 | 46.38 / 27.05 | 20.75 / 12.10 | 23.86 / 13.92 |
| Before this branch, v2 ramp / plunge (v1 rule × v2/v1 feed ratio, at the adaptive rpm) | 9.38 / 5.47 | — | 8.26 / 4.82 | — |

**How to read it:**
- Both tools are **R1-bound**. The end chip sits exactly on λ·r_β = 0.6 µm, and fz sits at the largest side chip C2/C14f allow.
- The angle is the smallest that stops the end teeth rubbing. It is above the vendor median, so R14a is overridden and the Fusion alert says why.
- At 75 %, the larger fz allowed gives a *lower* angle at the same end chip.
- At v1's 1.0° (T12), the end teeth would take 0.10 µm, a sixth of the floor. That is the rubbing / work-hardening regime the user wanted to avoid.
- The side cut is light: T12's pitch is 0.32·D, under C8's 0.35·D micro-slot cap.
- C3, C4 and C5 have margin at the ramp.


## 6. Decisions needed

Each decision has a recommendation and what is in the code now.

1. **D1. The edge radius behind R1.** For micro tools in 17-4, the ramp angle is asin(λ·r_β / fz_max), where fz_max is the largest side chip that C2/C14f allow. r_β is still the 2 µm placeholder (`edge_radius_mm`; the range is 0.4–3.5 µm), and λ is 0.3.

   Sensitivity at 50 %:

   | r_β | T12 angle | T1 angle | R14a override? |
   |---|---|---|---|
   | 0.5 µm | 2.73° | 2.73° | no; the vendor cap binds |
   | 1 µm | 2.93° | 2.74° | T12 only |
   | 2 µm | 5.87° | 3.47° | both |
   | 3 µm | 8.83° | 5.20° | both |

   Recommendation: keep 2 µm (it errs toward avoiding rubbing in work-hardening 17-4) until Harvey's edge-prep figure or a measured r_β is available. **In code: 2 µm.**

2. **D2. Who wins when the vendor angle cap (R14a) is below the physics floor (R1).**
   - **Physics wins (in code):** the smallest physics-feasible angle; R14a listed in `overridden` and `conflicts`, with a Fusion alert.
   - **Vendor cap wins:** R1 is reported as violated.
   - **No ramp:** the cut is reported as infeasible.

   Recommendation: physics wins, as the user's rule "physics limits never relaxed" requires.

3. **D3. The basis for R2 (end-edge limit).**
   - **Vendor plunge chips (in code):** about 1.7·10⁻³·D.
   - **The vendors' ramp end chip:** fz·sin of their maximum angle, about 1.8·10⁻⁴·D at micro sizes. Below 1/8" it sits under R1's floor, so every micro ramp would be an R1/R2 conflict.
   - **Off.**

   Recommendation: plunge chips.

4. **D4. Ramp spindle speed.** v2 computes the ramp at C7's slot-engagement speed (T12: 8,625 rpm at 50 %, against 11,291 rpm for the adaptive) and returns it as `ramp_rpm`. `ramp_feed` (IPM) is computed at that speed.
   - Recommendation: the add-in writes Fusion's **Ramp spindle speed**.
   - If it doesn't, `result.v2["ramp"]["ramp_feed_at_op_rpm_ipm"]` (10.42 IPM for T12) keeps the same chip at the operation's rpm, but runs above the slot tool-life speed.
   - The local session should pick one; writing ramp_feed without the ramp rpm gives a smaller chip than designed (T12: fz 0.000176" instead of 0.000231", end chip 0.46 µm, under the floor).

5. **D5. Helix diameter semantics.** `ramp_diameter_in` is the **tool-centre helix diameter**; the bore is D + it. `ramp_min_diameter_in` is the smallest allowed (0.2·D from the vendor-median minimum bore 1.2·D).
   - The local session should confirm that Fusion's "Helical ramp diameter" is the toolpath (centre) diameter.
   - It should also decide whether to write the minimum to "Minimum ramp diameter".
   - Choice in code: the largest helix in [0.2·D, D] that passes the side checks at the chosen angle. That gives T12 1.0·D (bore 2·D, no core) and T1 0.6·D (bore 1.6·D; C3 limits a larger helix).

6. **D6. Plunge feed.** v2 plunge is about 7–20× slower than v1:
   - T12: 1.45 IPM (50 %) and 1.96 IPM (75 %), against v1's 12.1 and 13.9;
   - T1: 1.06 and 1.36, against v1's 21.7 and 27.1.

   It comes from the end-edge limit R2, capped by the vendor plunge/slot ratio 0.20 × the ramp feed (R14p). SGS (Z5, M4 micro) says not to plunge such tools at all. Fusion also uses the plunge feed for vertical feed moves in air, so the slower value costs time on re-entries. Recommendation: accept; it is safe and vendor-consistent. **In code: as described.**

7. **D7. Harvey's "programmed helix diameter > 110–120 % of tool diameter".**
   - Read as the bore (in code): minimum bore 1.1·D.
   - Read as the tool-centre helix: the bore would be ≥ 2.1·D, with a standing core, against Seco's ≥ 1.3·D.

   With the Harvey row dropped or reread, the 17-4 minimum bore rests on Seco alone (one group). R6 would then fall back to its 0.1·D floor.

8. **D8. Second check of image-only rows:**
   - Emuge (all 39);
   - Harvey guidebook p.4 (29);
   - Sandvik Dura catalogue pp.23/32 (44);
   - the two ToolGuide readings. The 200 HB run's pitch is twice the printed AP: was that run's hole 4 mm?

9. **D9. Bridge behaviour change.** Before, v2 kept v1's ramp angle and scaled v1's ramp and plunge feeds by the v2/v1 feed ratio. T12 at 50 % got 1.0°, 8.26 IPM ramp and 4.82 IPM plunge, all at the adaptive rpm. Now the model sets all of them. The existing test "v2 ramp feed ≤ v1 ramp feed" still passes unchanged for T12. The model has no such cap, so it could exceed v1 elsewhere.


## 7. Running it (Windows)

```
cd C:\path\to\ToolWiz-engine
set PYTHONPATH=.
python tools\calibrate_v2_ramp.py --quick
python tools\calibrate_v2_ramp.py
python -m unittest tests.test_v2_ramp tests.test_v2_benchmark_dataset
```

`--quick` writes `data\model_v2\ramp.json` and the T1/T12 part of `data\model_v2\ramp_calibration_report.json` in about 30 s. The full run adds the residuals and takes several minutes.
