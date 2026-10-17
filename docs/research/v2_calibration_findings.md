# v2 step 4: calibration, what came out

_2026-10-17. Design step 4 of §6 in `docs/PHYSICS_MODEL_DESIGN.md`. Branch `toolwiz/v2-step4` from `toolwiz/hardening` (b03ee1b). The v1 engine and the pipeline are unchanged._

## Summary for the user

- **Everything below is a proposal.** The optimizer's defaults are unchanged. The calibrated values sit in `data/model_v2/materials.json` and `tools.json`, marked PROPOSED. `physics_v2/params.py` builds optimizer inputs from them for step 5.
- **The §5 gate is not met as written, and on this data it cannot be.** The gate asks for each row within the vendor's own range ±10 % and a median error ≤ 25 % per band. The vendors themselves are further apart than that:
  - Predict each row from the other vendors' median in the same cell (material, size band, operation, engagement class, 50 HB bin). That passes only **30 % of rows on SFM and 17 % on fz**, at a median error of **0.39 / 0.37** (log).
  - The calibrated model does as well or better: **33 % / 19 %** pass, median error **0.32 / 0.28**, and on the hold-out rows **38 % / 18 %** and **0.29 / 0.29**.
  - §5 has a replacement gate for you to choose (decision 9).
- **Force scale.** Sandvik's own power gives a tool factor of **0.791** on the three 17-4 PH readings (spread 0.1 %). It is not yet applied.
- **Thin chips.** The literature does not support the Round 5 suspicion that Kienzle overstates force at µm chips. Measured kc keeps rising below the edge radius, and an edge-force split *raises* the force there.
  - Runout and the tool factor explain most of the stress outliers: 391 → 112 rows over fatigue, 24 → 2 over TRS.
  - C4 is unchanged.
- **Titanium.** mc 0.23 from Seco SMG 22 (Ti6Al-4V), with Sandvik's kc1 1400. All 506 square-end Ti rows are now evaluated.
- **Speed (C7).** A fitted law per material family, with the hardness and engagement terms taken only from within-chart contrasts, anchored at the median vendor.
  - Engagement: v ∝ max(ae/D, 0.05)^−0.156.
  - 17-4 hardness exponent: the data says **1.82**, against your prior of about 1.0. It moves T1/T12 by about 8 % (decision 2).
- **C2.** On hold-out, no fitted alternative beats the band medians in `chip_limits.json`, so it stays the basis.
- **T1 and T12 change little.** T1 adaptive goes 0.074 → 0.080 in³/min with 31 % less program; T12 adaptive goes 0.034 → 0.033 with 29 % less program. Finishing is 33–38 % faster at the same 5 µm wall.

## Files

| What | Where |
|---|---|
| Calibration script | `tools/calibrate_v2.py`. Run from the repo root: `python tools\calibrate_v2.py` (about 25 min on the cloud box; `--quick` skips the process benchmark and T1/T12) |
| Proposed parameters (each value has a `source`) | `data/model_v2/materials.json`, `data/model_v2/tools.json` (version `2026-10-17.1`) |
| Fits, residuals, hold-out, §5 metrics before/after, T1/T12 | `data/model_v2/calibration_report.json` |
| Per-row predictions before/after | `data/model_v2/calibration_rows.json` |
| Optimizer inputs from the files | `physics_v2/params.py` (`params.material(family, hb, coating)`) |
| Optimizer change (backward compatible) | `optimize.Material.vc_engagement_basis` (`"phi"` default, `"ae"` for the fitted law) and `vc_hb_ref` (the hardness the speed anchor is quoted at) |
| Tests | `tests/test_v2_calibration.py` (13 tests) |

**Method.**
- **Hold-out.** 30 % of (vendor group, document, family) groups, chosen by a hash and never seen by any fit. Rows from one chart are correlated, so a row-level split would leak. That leaves 1,912 training rows and 892 hold-out rows.
- **Weighting.** Every fit weights each of the 8 vendor groups equally. Harvey alone has a third of the rows.
- **Scope.** 2,804 square-end rows were evaluated. Left out: 47 corner-radius rows (v2.0 scope) and 4 rows with no LCF.
- **Hardness fix.** `tools/v2_provisional_limits.py` read Seco's Rm bands (N/mm²) as HB, giving "HB 850". The calibration converts them with HB ≈ Rm/3.38 (ASTM A370 Table 3: Rm/HB is 3.33–3.42 over 226–371 HB). This affects 59 Seco rows.

## 1. Force scale

**Tool/rake factor, from Sandvik's own power** (`sandvik_toolguide_probes.md`). kc_Sandvik = P·60·10⁶/Q, divided by the model's kc at the same h_m.

| Reading (CoroMill Dura 2 mm, 4 FL) | h_m (µm) | Model kc (N/mm²) | Sandvik kc | Ratio |
|---|---|---|---|---|
| 17-4 PH 200 HB, dynamic, ae 0.10·D | 4.86 | 5510 | 4361 | 0.792 |
| 17-4 PH 345 HB, full slot | 4.85 | 6892 | 5441 | 0.789 |
| 17-4 PH 345 HB, dynamic | 4.86 | 6890 | 5451 | 0.791 |
| 45 NCD 16 420 HB, dynamic (P2.5.Z.HT) | 4.86 | 8066 | 5156 | 0.639 |

Check: Q = ap·ae·vf agrees with Sandvik's QQ within 0.3 % on every reading.

- **Tool factor 0.791** (geometric mean of the three 17-4 readings, log sd 0.001).
  - The same ratio holds from a slot to 0.1·D engagement, so the h_m + Kienzle structure matches Sandvik's.
  - It is supported by **one vendor and one tool** and holds at one chip thickness (4.9 µm).
- **The 45 NCD 16 reading is a cross-check, not part of the fit.** With Sandvik's printed mc for P2.5.Z.HT (0.25) it gives 0.64; with mc 0.21 it gives 0.791.
  - The probe doc's arithmetic had used 0.21. That is corrected in `sandvik_toolguide_probes.md`.
  - So the calculator does not use its own table's mc for this steel, and part of the "tool factor" may be material-side. With one h_m this cannot be split.
- **17-4 kc hardness exponent:** 0.41 from the like-for-like dynamic pair, which confirms the adopted value.
- **K_r is not identifiable from power,** which is tangential only. The literature found:
  - Kr/Kt 0.34–0.38 for carbide end mills in 45 steel (Sun et al. 2023, *Sensors* 23:8954, Table 2; primary).
  - Krc/Ktc 0.50 for Ti6Al4V (Li et al. 2014, *J. Vibroeng.* 16:2657, citing Altintas; secondary).
  - No stainless value was found.
  - **K_r stays 0.4,** now inside a sourced 0.34–0.50 band. No published end-mill force data with full conditions was found for 17-4, 316, H13 or Inconel 718. The lookup was blocked on most publisher sites; the candidate sources are listed in the report.
- **K_te, K_re stay 0.**
  - Published edge coefficients are 12–43 N/mm: Ti6Al4V Kte 24 / Kfe 43 (Altintas, MAL review Table 1); 16MnCr5 28.8 (Popović et al. 2017, FME Trans. 45:4); 1020 steel 12.25 (Salehi et al. 2018, Procedia CIRP).
  - Sandvik's kc1 is fitted to total force, so adding them would double-count.
  - The probes all sit at one h_m, so they cannot separate an edge term.

## 2. Thin-chip size effect and the C4 outliers

**What the literature says** (cited treatments; lookup report in the session; primary unless marked):
- **No standard gives a lower limit for Kienzle.** The tables stop at h = 0.05–0.06 mm (Westermann; Europa).
- Biró & Szalay 2016 (*IJAMT* 84:2735) split the size effect into zones: ≥ 0.1, 0.01–0.1, 0.003–0.01 and < 0.003 mm. They find a regime boundary at 3–4 µm for S960QL steel.
- **Measured kc keeps rising below the edge radius; it does not saturate.**
  - AISI 1045: ~70 GPa at fz ≈ r_e/10 (de Oliveira et al. 2015, *IJMTM* 89:39; abstract only).
  - CMSX-4 nickel superalloy: 600–1000 GPa at 0.16 µm/tooth (Soriano Gonzalez et al. 2023, *Micromachines* 14:313).
- **The edge-force split** F = Kc·A + Ke·b (Altintas, MAL review Eq. 1) bounds the force per unit width at Ke. Its apparent kc = Kc + Ke/h *rises* faster than h^−mc.

**Effect on the vendor cuts** (each row's own cut on its catalog tool; 2,804 rows; fatigue 1425 MPa, TRS 3800 MPa):

| Variant | Over fatigue | Over TRS | 1/64–3/64 | 1/16–3/32 | 1/8–3/16 | 1/4–3/8 | 1/2–3/4 | ≥ 1 |
|---|---|---|---|---|---|---|---|---|
| Round 5 basis (TIR 0.0002", tool factor 1) | 391 | 24 | 132 | 92 | 72 | 63 | 27 | 5 |
| TIR 0 | 205 | 4 | 25 | 43 | 52 | 55 | 25 | 5 |
| Tool factor 0.79 | 236 | 10 | 86 | 61 | 42 | 33 | 12 | 2 |
| **TIR 0 + tool factor 0.79** | **112** | **2** | 15 | 31 | 25 | 28 | 11 | 2 |
| kc held constant below 0.05 mm (not supported by the literature) | 154 | 0 | 31 | 39 | 30 | 32 | 17 | 5 |
| Edge-force split fitted to Kienzle over 0.05–0.2 mm | 1040 | 361 | 329 | 274 | 223 | 169 | 38 | 7 |

**Reading:**
- **Runout dominates in the micro band.** At 0.0002" TIR the worst flute's chip is set by the runout (5 µm), not by Harvey's 1–3 µm fz. 132 micro rows drop to 25 at TIR 0. Harvey's micro charts evidently assume a much smaller runout than 0.0002".
- **The tool factor** removes about 40 % of the rest.
- **The two thin-chip treatments:**
  - The saturating kc would remove outliers, but no source supports it.
  - The cited edge-force split makes them three times worse.
- **No size-effect change is proposed.** C4 is unchanged.

The 112 that remain (listed in `calibration_report.json`, `thin_chip`):
- **39 full slots ≥ 1·D deep.** Garr VRX at 1.5·D in H13, Inconel and 4140, rated "< 40 HRC" and read as 40 HRC; Kennametal HARVI II TE in H1; Sandvik Plura HD P3.0.
- **22 deep side/HEM cuts (ap ≥ 3·D).** Harvey SF_711700 5×LOC HEM in nickel 36–50 HRC is the worst, at 3.6–5.2 GPa.
- **20 hardened (≥ 400 HB).**
- **15 micro.**
- **16 other.**

These vendor cuts sit above a 10⁷-cycle fully reversed fatigue limit. A tool's life is about 10⁶ cycles, where the limit is 0.42·TRS = 1596 MPa (Kursawe 2001 via Preis 2004). Even there, 75 of the 112 rows stay over. They stay as written exceptions; C4 is not loosened.

## 3. Titanium mc

- **Value:** Sandvik prints kc1 1400 for S4.2–S4.4 with no mc. The calibration takes **Seco SMG 22 (ISO S), Ti6Al-4V annealed: kc1.1 210 ksi = 1448 N/mm², mc 0.23** (`kc_mc_sources.json`, SE-NC).
- **Why Seco:** it is the independent second source, with a median ratio of 0.97 to Sandvik (`kc_mc_survey.md` §5). It is on the same 0° rake basis, and it names Ti-6Al-4V.
- **Other sources, for the record:** Sandvik's own CP-Ti row S4.1 (mc 0.23), Europa TiAl6V4 (0.21) and group S (0.22) on a +6° basis, and Walter (0.25, which mirrors Sandvik for S groups).
- **What is used:** kc1 1400 (Sandvik) with mc 0.23 (Seco). Ti hardness exponent 0, because Sandvik prints the same kc1 at 330 and 375 HB.
- **Effect:** 506 square-end Ti rows are evaluated (307 side/rough/HEM, 128 slot and the finishing rows).
- **Effect on C2:** adding Ti rows to the C2 bands would move each band median by ≤ 3 % (1/4–3/8 side 0.00441 → 0.00447). The worst-flute chip does not depend on mc, so the Ti rows were left out only by the old mapping.

## 4. C7: tool life and speed

The law fitted for each family is

  v = vc_ref · coating · (HB_ref/HB)^q · max(ae/D, ae_min)^(−k) · C9(stickout) · (T/T_ref)^(−n)

C9 (the OSG overhang factor) is divided out of the vendor SFM before fitting, as the optimizer multiplies it back in.

### Engagement

**What was fitted:**
- **Data:** within-chart contrasts only (same document, material, hardness and tool, different ae), each vendor weighted equally. That is 1,271 training rows in 516 charts, finishing excluded.
- **Result:** **k = 0.156 ± 0.004** on ae/D, with no credit below **ae_min = 0.05** (grid search). The φe-based form fits worse.

| ae/D | 0–0.03 | 0.03–0.06 | 0.06–0.09 | 0.09–0.13 | 0.13–0.18 | 0.18–0.26 | 0.26–0.36 | 0.36–0.51 |
|---|---|---|---|---|---|---|---|---|
| Vendor factor vs slot (within-chart) | 1.43 | 2.00 | 1.57 | 1.47 | 1.12 | 1.22 | 1.05 | 1.08 |
| Model | 1.60 | 1.60 | 1.50 | 1.41 | 1.34 | 1.27 | 1.20 | 1.14 |

**Vendors disagree about the speed credit at all:**

| Vendor group | Harvey Perf. | Garr | Kennametal | Emuge | OSG | Sandvik | Kyocera | YG-1 |
|---|---|---|---|---|---|---|---|---|
| k (within-chart) | 0.00 | 0.00 | 0.07 | 0.13 | 0.17 | 0.19 | 0.22 | 0.27 |

- Harvey and Garr print one SFM for slot, side and HEM within a chart. The others raise it at light engagement.
- **Sandvik checks:**
  - Dura at 0.5·D: 1.13× Sandvik against 1.11× model.
  - Dura at 0.1·D: 1.88× against 1.43×.
  - ToolGuide dynamic at about 0.09·D: 1.8× against 1.46×.
  - Sandvik is at the steep end of the vendors.

### Hardness

The speed hardness exponent q comes only from within-chart contrasts (same document, operation, tool and engagement, different hardness):

| Family | q | Rows (groups) | Vendors | Basis |
|---|---|---|---|---|
| 17-4 PH | **1.82 ± 0.06** | 153 | Harvey Perf. 141, Kennametal 12 | within-chart |
| H13 | 1.14 ± 0.06 | 66 | Emuge 40, Kennametal 18, Harvey 8 | within-chart |
| Ti alloys | 0.31 | 18 | Harvey only | within-chart (one vendor) |
| Nickel alloys | 0.18 | 26 | Harvey only | within-chart (one vendor) |
| Others | 0.84 ± 0.05 | 272 (pooled) | | pooled within-chart |

**17-4 against your prior (v ∝ about 1/HB):**
- Every Harvey 17-4 sheet steps 140 → 100 SFM from 300–350 to 350–400 HBn (q 2.35). SF_875400 gives 160/140/100/80 over its four bands (2.18).
- Kennametal HARVI I TE gives 2.56.
- Helical HEV-5/HEV-7 give 0.86 (in the hold-out), and the Sandvik ToolGuide probes 1.03.
- So the two Harvey Performance brands disagree with each other, and the steep value rests on Harvey's charts plus one Kennametal pair.

**The fz exponent:** in the same contrasts, vendors also cut fz as HB^−0.48 ± 0.04. That is what a tooth-force limit predicts (HB^(−0.41/0.79) = HB^−0.52); see §6.

### Level

**How it is fitted:** WLS of the residual log SFM on family, vendor and coating effects. The family level is then set at the **median vendor group** (decision §7.1, vendor-typical life).

| Family | vc_ref SFM (slot, at HB_ref, AlTiN or unspecified coating) | HB_ref (median of rows) | Model error on all rows (median \|log\|, bias) |
|---|---|---|---|
| 17-4 PH | 183 | 325 | 0.35, +0.04 |
| 316 | 206 | 262 | 0.21, −0.05 |
| 420 | 306 | 200 | 0.13, −0.01 |
| 4130/4140 | 352 | 294 | 0.20, −0.10 |
| 1045 | 388 | 237 | 0.30, −0.02 |
| 1020 | 196 | 271 | 0.98, −0.94 (Kyocera HSM rows at 760–915 SFM, in the hold-out) |
| H13 | 190 | 432 | 0.48, +0.05 |
| Ti alloys | 203 | 325 | 0.28, +0.20 |
| Nickel alloys | 79 | 375 | 0.33, +0.19 |
| 6061 | 918 | 100 | 0.47, −0.47 |

**Vendor speed levels against the median vendor (log):** Kennametal +0.23, Garr +0.14, Sandvik +0.13, Emuge +0.02, Kyocera −0.02, OSG −0.26, YG-1 −0.32, Harvey Performance −0.38. So Harvey runs 0.68× the median vendor, Kennametal 1.26×.

**Diameter:** within a chart SFM does not vary with D at all (slope −0.001 ± 0.002), so no D term is used.

### Coating and Taylor n

**Coating** (within-vendor contrasts, confounded with tool series):

| Class | Factor | Applied? |
|---|---|---|
| AlCrN | 1.21 ± 0.04 | Applied (Emuge, Garr, Sandvik) |
| Si-doped (AlTiSiN, TiAlSiN, TiAlCrSiN) | 1.20 ± 0.05 | Applied (Garr, Sandvik) |
| Uncoated | 1.29 | Not applied: Harvey only |
| DLC | 3.3 | Not applied: aluminium only, so it is the material, not the coating |
| Proprietary names with no chemistry | — | "Unspecified", factor 1 |

**Taylor n = 0.25.** Tatar & Sjöberg 2020 (*Heliyon* 6:e04217, Eq. 3: Ti-6Al-4V, coated carbide, n = 1/4.01) is the one sourced value, and it rests on a narrow speed range. n only trades life for speed under aggressiveness. vc_ref is "C at vendor-typical life", because the vendors never state T.

**Speed model alone:** median |log error| is 0.33 on training rows and **0.29 on hold-out**. Finishing passes are biased +0.59. Most vendors do not speed up a finishing pass for its light engagement (Harvey finishes at its roughing SFM), while the law gives it the engagement credit (decision 3b). OSG's "High Speed Light Milling" rows at about 1,200 SFM go the other way.

## 5. Aggressiveness map (proposal; you decide)

| Margin | Now (Round 1 placeholder) | Proposed | Basis |
|---|---|---|---|
| C2 limit | ×(0.7 + 0.6·a) | ×0.76 / 1.00 / 1.24 at a = 0 / 0.5 / 1, piecewise linear | The vendors' own spread of worst-flute h/D around each band median: p25 and p75, median over bands (per band 0.68–0.82 and 1.17–1.33) |
| C4 limit | 1425 MPa ×(0.7 + 0.6·a), which reaches 0.49·TRS at a = 1 | 1254 / 1425 / 1596 MPa = 0.33 / 0.375 / 0.42 × TRS | Cited fatigue fractions: Schleinkofer 1996 (R = −1, 10⁷), Round 4 basis, Kursawe 2001 (10⁶ cycles ≈ a tool's life). No cited fully reversed level reaches 0.49 |
| Tool life | ×4^(0.5 − a) | Unchanged | With n = 0.25 it moves speed ×0.84 … ×1.19, about the inter-quartile spread of vendor speed levels |
| λ (C1) | 0.4 → 0.2 | Unchanged | Sourced range |
| C5 margin | 0.2·(1 − a) | Unchanged | The spindle is a hard limit |
| C3 | not scaled | Not scaled | Your process requirement (50 % of the stock to leave) |

## 6. C2 per band

Each row's fz is predicted from its C2 limit alone (C2 binding, at the row's own engagement, 0.0002" eccentric runout). The limits are fitted on the training rows only.

| C2 basis | Hold-out median \|log fz error\| | Training | Worst family on hold-out |
|---|---|---|---|
| **A: band median of worst-flute h/D (chip_limits.json method)** | **0.305** | 0.272 | H13 0.83 |
| A2: smooth in D, log(h/D) = a + b·log D (+ slot) | 0.308 | 0.291 | H13 0.80 |
| B: A2 + family offsets + hardness slope | 0.313 | 0.276 | H13 0.71 (6061 improves 0.52 → 0.30) |
| C: tooth edge load kc1(HB)·h^(1−mc)/D, smooth in D | 0.434 | 0.413 | 6061 0.94 |
| C2: C + family offsets | 0.328 | 0.277 | H13 0.72 |

- **Keep the band medians.** No fitted alternative beats them on hold-out. The smooth fit A2 gives log(h/D) = −5.77 + 0.078·slot − 0.225·log D, so h_worst/D falls as D^−0.23. That is the band trend, carried by runout at small D.
- **Runout stays explicit.** The limit is on the worst flute's chip at 0.0002" TIR, eccentric, at the worst phase.
- **The tooth-load invariant (C) explains the within-chart hardness effect** (its slope with HB is −0.03 ± 0.03, against −0.41 for h/D), but not the scatter between vendors.
- **Two small notes on `chip_limits.json`:**
  - Its generator does not filter on end form, so 47 corner-radius HEM rows are in the side bands.
  - Ti rows could be added (≤ 3 % change).
  - Neither changed here.
- **The irreducible part.** Within a band the vendors' worst-flute chip has p25/p75 at 0.76/1.24 of the median, so ±10 % of each vendor's fz cannot be met by any single chip limit.

## 7. The optimizer on every benchmark row

**Setup:**
- **Rows:** all 2,804 square-end rows (slot → slot; side and rough → rough; HEM → adaptive; finish → finish), each at the vendor's own ap and ae on its catalog tool.
- **Speed:** from C7. **fz:** the largest that meets every constraint.
- **Machine:** a vendor-reference machine with no rpm, power or feed cap, since vendor values are machine-independent.
- **Runout:** 0.0002" eccentric.
- **Aggressiveness:** 50 %.
- **"Tool capability" (the §5 comparison):** C3 off and no finishing wall target. The stock to leave and the 5 µm wall are your process requirements, which no vendor chart knows.
- **"Process":** C3 at 0.05 mm stock plus the 5 µm wall target, reported alongside.
- **C8/C12 conflicts:** C8 (micro slot depth) and C12 (ae ≥ 2·TIR) judge the vendor's chosen engagement. Where they conflict (C8 235 rows, C12 4), the row is still compared at the vendor's engagement.
- **"Before":** step-3 defaults: placeholder speed anchor, tool factor 1, no titanium.

| Model | Rows | Feasible | In range ±10 %: SFM / fz / both | Median \|log\|: SFM / fz / MRR | Bias: SFM / fz |
|---|---|---|---|---|---|
| Vendor consensus (other vendors' cell median) | 1999 | — | 30.1 % / 17.3 % / — | 0.385 / 0.373 / — | — |
| Before (step 3 defaults; no Ti) | 2298 | 1964 | 21.9 % / 18.9 % / 5.6 % | 0.476 / 0.284 / 0.63 | +0.19 / +0.01 |
| **After (calibrated, tool capability)** | 2804 | 2417 | **33.1 % / 19.0 % / 8.7 %** | **0.317 / 0.275 / 0.46** | +0.07 / +0.02 |
| After, hold-out rows only | 892 | 756 | 37.9 % / 18.0 % / 9.6 % | 0.289 / 0.29 / 0.45 | +0.04 / +0.06 |
| After, process (C3 0.05 mm, 5 µm wall) | 2804 | 2089 | 33.1 % / 9.2 % / 4.3 % | 0.317 / 0.73 / 0.80 | +0.07 / -0.53 |

**By diameter band** (after, tool capability; hold-out in brackets):

| Band | Rows | Feasible | Median \|log\| SFM | Median \|log\| fz | Bias SFM / fz | §5 25 % (0.223 log) met? |
|---|---|---|---|---|---|---|
| 1/64–3/64 | 348 | 86 | 0.45 (0.41) | 0.28 (0.43) | +0.33 / +0.03 | no |
| 1/16–3/32 | 370 | 248 | 0.40 (0.39) | 0.28 (0.30) | +0.24 / +0.08 | no |
| 1/8–3/16 | 449 | 446 | 0.35 (0.31) | 0.29 (0.23) | +0.15 / +0.00 | no |
| 1/4–3/8 | 711 | 711 | 0.31 (0.29) | 0.30 (0.31) | +0.04 / +0.02 | no |
| 1/2–3/4 | 608 | 608 | 0.26 (0.24) | 0.24 (0.29) | −0.06 / +0.02 | no (fz close) |
| 1 and up | 318 | 318 | 0.23 (0.23) | 0.27 (0.29) | −0.08 / +0.05 | SFM borderline, fz no |

**By vendor group** (after; bias in log, + = model above vendor):

| Vendor | Rows | In range SFM / fz | Bias SFM / fz |
|---|---|---|---|
| Garr | 240 | 76 % / 75 % | −0.18 / 0.00 |
| Kennametal | 293 | 53 % / 15 % | −0.24 / −0.22 |
| OSG | 392 | 53 % / 11 % | +0.09 / −0.09 |
| Kyocera | 248 | 45 % / 16 % | +0.01 / +0.22 |
| Sandvik (incl. Seco) | 333 | 34 % / 9 % | −0.16 / −0.27 |
| Emuge | 288 | 30 % / 16 % | +0.01 / +0.20 |
| YG-1 | 76 | 24 % / 17 % | +0.11 / +0.17 |
| Harvey Performance | 934 | 6 % / 15 % | +0.46 / +0.10 |

**By material** (after): median |log| SFM / fz.

| Material | SFM | fz |
|---|---|---|
| 316 | 0.21 | 0.27 |
| 4130 | 0.20 | 0.24 |
| 17-4 | 0.35 | 0.21 |
| Ti | 0.28 | 0.24 |
| Ni | 0.33 | 0.30 |
| H13 | 0.48 | 0.36 |
| 1045 | 0.30 | 0.46 |
| 6061 | 0.47 | 0.78 (chips 2× thicker than the steel-dominated C2 band) |
| 1020 | 0.98 | 0.30 |

**By operation** (after): median |log| SFM / fz.

| Operation | SFM | fz | Note |
|---|---|---|---|
| HEM | 0.25 | 0.27 | |
| Slot | 0.30 | 0.24 | |
| Side | 0.26 | 0.35 | |
| Rough | 0.45 | 0.21 | Harvey's generic "rough" columns |
| Finish | 0.64 | 0.30 | Speed bias +0.59 |

### Rows outside, and why (no target was loosened)

1. **Not feasible: 387 rows, all at 3/16" and below** (262 of the 348 micro rows, 122 at 1/16–3/32).
   - Eliminated by C2 (204), C2 + C4 (154) and C4 (29).
   - **Cause: runout.** Every-flute C1 at 0.0002" TIR needs a chip of at least 0.71·TIR, and below about 1/16" that exceeds the C2 band median (Round 5 §D). The C4 cases are the vendor cuts over fatigue (§2).
   - A measured TIR per tool (Blum) is the fix, not a looser limit.
2. **SFM outside: 1,875 rows.**
   - Harvey Performance accounts for 878 of them: 764 where the model is above Harvey, including 241 finishing rows. Harvey runs 0.68× the median vendor and does not vary SFM with engagement.
   - Of the other vendors' rows, 584 are below the vendor and 413 above. Kennametal, Garr and Sandvik run 1.14–1.26× the median vendor; OSG and YG-1 run 0.72–0.77×.
   - The cross-vendor spread, not the model, sets this (the consensus line above).
3. **fz outside: 1,884 of the 2,417 feasible rows.**
   - With C2 binding, the model sits about evenly over and under the vendors: 963 over, 800 under (C2 alone or with C6/C3; the 12 largest categories in `fz_outside_range_by_binding`).
   - This is the ±24 % inter-quartile spread of vendor chips within a band (§6).
   - With C4 binding, 64 rows sit under: the vendor cut is over fatigue.
4. **6061:** fz bias −0.78. Aluminium chips run about 2× the steel-dominated band median; basis B fixes that for 6061 but not overall.
5. **Finishing:** the speed bias +0.59 comes from the engagement credit (decision 3b). In the process variant the 5 µm wall target holds fz 3.6× below vendor finishing feeds (bias −1.27). That is your tolerance, which vendor finishing rows do not assume.
6. **Not evaluated:** 47 corner-radius rows (v2.0 scope) and the 4 Helical Guidebook case studies, which publish no LCF or part number (`missing` in the row).

## 8. T1 and T12 in 17-4 H1025 (356 HB), Speedio 16k, TIR 0.0002", aggressiveness 50 %, stock 0.05 mm

"After" uses the proposed parameters: tool factor 0.79, the fitted speed law with q 1.82, and coating unspecified.

| Tool | Op | Model | ap | ae | fz | SFM | IPM | MRR in³/min | MB/in³ at s 0.22 mm | σ1 MPa | Binding / wall |
|---|---|---|---|---|---|---|---|---|---|---|---|
| T1 | adaptive | before | 4·D | 0.026·D | 0.00147 | 255 | 45.8 | 0.0738 | 1.91 | 723 | C2, C3, C6 |
| T1 | adaptive | after | 4·D | 0.037·D | 0.00123 | 228 | 34.2 | **0.0796** | **1.32** | 685 | C2, C3, C6 |
| T1 | slot | before | 0.14·D | D | 0.00034 | 135 | 5.6 | 0.0122 | 1.39 | 342 | C3 |
| T1 | slot | after | 0.19·D | D | 0.00031 | 142 | 5.5 | **0.0159** | 1.05 | 342 | C3 |
| T1 | finish | before | 4·D | 0.016·D | 0.00029 | 255 | 9.2 | 0.0090 | 3.12 | 144 | ripple 5.0 µm (met), mean 2.6, max 5.2 |
| T1 | finish | after | 4·D | 0.016·D | 0.00044 | 228 | **12.2** | 0.0120 | 3.12 | 156 | ripple 5.0 (met), mean 2.9, max 5.6 |
| T12 | adaptive | before | 3·D | 0.172·D | 0.00029 | 236 | 16.9 | 0.0341 | 1.52 | 1372 | C2, C3, C6 |
| T12 | adaptive | after | 3·D | 0.243·D | 0.00026 | 184 | 11.6 | **0.0330** | **1.08** | 1288 | C2, C3, C6 |
| T12 | slot | before | 0.35·D | D | 0.00022 | 141 | 7.5 | 0.0103 | 2.24 | 976 | C2, C8 |
| T12 | slot | after | 0.35·D | D | 0.00022 | 148 | 7.9 | 0.0108 | 2.24 | 772 | C2, C8 |
| T12 | finish | before | 3·D | 0.031·D | 0.00037 | 262 | 24.0 | 0.0089 | 8.31 | 421 | ripple 5.0 (met), mean 2.9, max 5.7 |
| T12 | finish | after | 3·D | 0.031·D | 0.00057 | 236 | **33.1** | 0.0122 | 8.31 | 447 | ripple 5.0 (met), mean 3.3, max 6.0 |

**What moved:**
- **The tool factor** lowers the force, so C3 allows a wider ae and the program shrinks by about 30 %. Finishing can take a larger fz at the same wall error.
- **The speed law** lowers SFM for 17-4 at 356 HB (q 1.82 from the 325 HB anchor). The engagement credit gives back part of it.
- **With q = 1.0 instead of 1.82,** T1 adaptive is 0.0858 in³/min at 245 SFM and T12 0.0356 at 199 SFM, about 8 % more.
- **Against v1** (T12 0.0064, T1 0.0194 adaptive): T12 is 5.2× and T1 4.1×.

## 9. Decisions for you (nothing below is applied)

1. **Tool factor 0.79** (Sandvik ToolGuide, one vendor, one h_m). Recommended: adopt. It lowers every force by 21 %, removes about 40 % of the C4 outliers, and moves T1/T12 as above.
2. **17-4 speed hardness exponent:** the fitted **1.82** (Harvey Performance and Kennametal charts) or your prior **1.0** (Sandvik ToolGuide; Helical HEV 0.86). About 8 % on T1/T12. The files carry 1.82.
3. **The engagement law:**
   - 3a. Adopt v ∝ max(ae/D, 0.05)^−0.156 (all vendors, within-chart) in place of the placeholder (φe/π)^−0.4 with its floor at 0.1·D (Sandvik Dura only). Recommended: adopt.
   - 3b. Should a finishing pass get the engagement credit? Vendors mostly don't give it (finish bias +0.59).
4. **Speed levels per family** at the median vendor, and the AlCrN and Si-doped factors (1.21, 1.20). Both are confounded with tool series.
5. **Aggressiveness map** (§5): C2 from the vendor quartiles (0.76–1.24), and C4 at the cited fatigue fractions (0.33/0.375/0.42·TRS) instead of ×0.7–1.3.
6. **C2:** keep `chip_limits.json` (confirmed). Optional, small: add the Ti rows, and drop the 47 corner-radius rows from its generator.
7. **K_r 0.4 and K_te = K_re = 0** stay. Better data needs measured forces for 17-4/316; the candidate sources are in the report.
8. **Thin chips:** no change to Kienzle or C4. The residual outliers are documented exceptions.
9. **The §5 gate.** As written it cannot be met: the vendors agree with each other only at 30 % (SFM) and 17 % (fz) within ±10 %. A gate tied to the data instead, for example:
   - median |log| error per band ≤ the cross-vendor value in that band;
   - |bias| per band ≤ 0.10;
   - |bias| per vendor reported, not gated, since Harvey sits 0.38 below the median vendor by its own choice.

   **Against that gate:**
   - The first criterion is met in every band, for SFM and fz. The cross-vendor median |log| per band, 1/64" up to 1", is SFM 0.72 / 0.73 / 0.45 / 0.38 / 0.29 / 0.27 and fz 1.10 / 0.65 / 0.39 / 0.35 / 0.30 / 0.27 (`vendor_consensus_ceiling`). The model gets SFM 0.45 / 0.40 / 0.35 / 0.31 / 0.26 / 0.23 and fz 0.28 / 0.28 / 0.29 / 0.30 / 0.24 / 0.27.
   - The second criterion holds for fz in every band. For SFM it holds from 1/4" up, and fails at 3/16" and below (bias +0.15 / +0.24 / +0.33), where Harvey's slow micro charts dominate.
   - Most micro rows are infeasible at 0.0002" TIR (§7, item 1).
10. **The benchmark comparison basis:** tool capability, with C3 and the wall target off (as reported). The process variant is shown alongside.

## Sources

Listed in full with each value in `materials.json` / `tools.json` and in `calibration_report.json` (`sources`):
- **Sandvik:** CoroPlus ToolGuide probes; Sandvik MC table (kc_mc_sources.json SV-WEB).
- **Seco:** SMG table (SE-NC).
- **Literature:**
  - Altintas MAL review (Eq. 1, Table 1).
  - Popović et al. 2017; Salehi et al. 2018.
  - Sun et al. 2023; Li et al. 2014.
  - Biró & Szalay 2016; de Oliveira et al. 2015; Soriano Gonzalez et al. 2023.
  - Tatar & Sjöberg 2020.
  - Preis 2004 (Schleinkofer 1996, Kursawe 2001).
- **Standards:** ASTM A370 Table 3.
- **Vendor rows:** the 2,855 rows in `tests/benchmarks/v2` (SCHEMA.md).
