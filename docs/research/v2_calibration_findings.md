# v2 step 4: calibration, what came out

_2026-10-17. Design step 4 of §6 in `docs/PHYSICS_MODEL_DESIGN.md`. Branch `toolwiz/v2-step4` from `toolwiz/hardening` (b03ee1b). The v1 engine and the pipeline are unchanged._

## Round 2 (2026-10-17): aggressiveness anchored to the vendor consensus

The user's refinement replaces items 4, 5 and 6 of Round 1's decisions (speed levels and coating, the aggressiveness map, C2 per band). **Round 1 (§1–§9 below) is kept as the record.** Its force scale, thin-chip, titanium, engagement and hardness results stand. Its speed level (§4 "Level"), aggressiveness map (§5), benchmark tables (§7) and T1/T12 (§8) are superseded by this section.

### R2.1 What was built

| Piece | Where | What it does |
|---|---|---|
| Consensus aggressiveness | `optimize.Margins(a, scheme="consensus")`, `CONSENSUS_SCALE_POINTS`, `pchip` | Scale on the C7 speed level, the C2 chip limit and the C14 caps: **0.76 / 0.92 / 1.00 / 1.10 at 0 / 50 / 75 / 100 %**, monotone cubic (Fritsch–Carlson) between the points. The tool-life target is that speed scale: T/T_ref = scale^(−1/n). |
| Physics never relaxed | same | C4 ≤ the fatigue limit, ×0.88 (0.33·TRS) at 0 % rising linearly to ×1.00 at 100 %. λ fixed at 0.3. C1, C3, C5 and C9 are not scaled up. |
| **C14** vendor-consensus guardrail | `optimize.consensus_lookup`, `c14_speed`, `c14_feed_checks`; option `consensus=` (a path, `"default"` or a dict) | Caps at scale(a) × the bucket's vendor median: SFM (C14v caps the C7 speed), fz (C14f) and MRR (C14m, see R2.5). When it binds, the check shows the median, the bucket and its vendor groups. With no matching data: "no vendor data matches this bucket; the physics (C7) speed stands". |
| Consensus buckets | `data/model_v2/consensus.json` (from `tools/calibrate_v2.py`) | 1,986 buckets at three levels. Per bucket: each vendor group's median, then the median over groups (each group counted once). |
| BT30 compliance | `optimize.Machine.holder_k_n_um`, `holder_ktheta_nm_urad`; `params.speedio_bt30()` | The spindle/holder in series with the tool in C3: tip deflection += F·(1/k + L²/k_θ), with L measured from the holder face. Stress is unchanged. |
| C7 diameter term | `Material.vc_diameter_exp`, `vc_d_knee_in` | Level ×(min(D, D_knee)/D_knee)^m, **empirical** (R2.3). |
| Gate | `calibrate_v2.gate` | Your §5 gate, per band (R2.6). |

**Bucket levels:**
- L1: family, 50-HB bin, diameter band, operation class (slot / side / HEM / finish), engagement class (slot ≥ 0.99·D; heavy 0.25–0.99; medium 0.10–0.25; light < 0.10).
- L2: the same with a 100-HB bin.
- L3: L2 with any operation.

**Defaults are unchanged.** `Margins()` is still the legacy scheme, C14 is off, and the holder is rigid, so every step-3 test stands. Step 5 switches them; `physics_v2/params.py` gives `margins(a)`, `speedio_bt30()` and `material(...)` for it.

### R2.2 The aggressiveness points against the vendor spread

Spread of each vendor group's median around its bucket median (L1 buckets with ≥ 3 groups, 333 group medians):

| | p10 | p25 | p75 | p90 |
|---|---|---|---|---|
| SFM | 0.64 | 0.82 | 1.09 | 1.38 |
| fz/D | 0.70 | 0.89 | 1.15 | 1.45 |

**The data does not argue for moving the points:**
- 100 % at 1.10 sits at the vendor-group p75 for speed (1.09), just under it for chip load (1.15), and at the low end of vendors' "may increase 10–20 %".
- 0 % at 0.76 is below the speed and chip p25 (0.82, 0.89) and equal to the worst-flute h/D p25 (0.76, Round 1).
- **Kept as given:** 75 % = 1.00, 50 % = 0.92.

### R2.3 Speed level against the vendor median, and the diameter term

**Level.** The C7 level is now fitted directly to the target, not to rows with vendor fixed effects. For each training row the target is its L1 bucket's vendor median, with the row's own engagement, hardness and C9 terms taken out. The fit is least absolute deviations, so the fit's per-band median and the gate's are the same statistic.

**What that changed:** with the Round 1 level the micro bands ran +0.24…+0.33 fast against the vendor rows, and the step-3 defaults +0.23…+0.49 against the vendor median. Most of that was Harvey's slow micro charts counted once per row instead of once per vendor group. On the new basis the bands sit within ±0.13 without any diameter term.

**Diameter term:** **v ∝ (min(D, 0.5")/0.5")^0.075**, i.e. a 1/16" tool runs 0.86× a ½" tool. It is **empirical**:
- Within a chart vendors print one SFM for every diameter (within-chart slope −0.001 ± 0.002), so the trend is between tool series.
- The cited lookup found no v_c ∝ D^m law. The micro-milling literature explains thinner allowable chips (h/r_β), not slower speeds.
- The likeliest cause is that micro tools are "starved for spindle rpm" (MSC/Iscar, second-hand). One vendor-adjacent source (an Autodesk class handout citing Harvey) argues the opposite.
- The knee was chosen by grid (0.125 / 0.25 / 0.5 / 1"), judged by the worst per-band bias on the training rows.

| Speed law alone vs bucket vendor median (log) | 1/64–3/64 | 1/16–3/32 | 1/8–3/16 | 1/4–3/8 | 1/2–3/4 | ≥ 1 |
|---|---|---|---|---|---|---|
| Training rows | −0.012 | −0.015 | +0.001 | −0.009 | 0.000 | −0.006 |
| Hold-out rows | −0.171 | −0.123 | +0.002 | −0.091 | −0.085 | −0.141 |

**On hold-out the law runs 0.09–0.17 slow** in five bands. A hold-out group is a whole document for one material, so this is the document-to-document spread of vendor speed levels, which no level can absorb.

**Levels** (slot, at the family's median HB, D ≥ ½", vendor median → ×1.025 consensus offset, R2.4):

| Family | SFM | HB_ref |
|---|---|---|
| 17-4 PH | 203 → 208 | 325 |
| 316 | 235 → 241 | 262 |
| 420 | 417 → 427 | 200 |
| 4130/4140 | 407 → 417 | 294 |
| 1045 | 476 → 488 | 237 |
| 1020 | 183 → 188 | 271 |
| H13 | 231 → 237 | 432 |
| Ti alloys | 184 → 189 | 325 |
| Nickel alloys | 75 → 77 | 375 |
| 6061 | 1577 → 1616 | 100 |

**Coating** factors are reported but no longer applied: the level is fitted to bucket medians, which mix coatings.

### R2.4 Why the physics side sits a little above the median (consensus offsets)

- **The problem:** at 75 % C14 caps at 1.00 × the bucket median, so the output is min(physics, median). A physics value centred on the median leaves half the rows below it, which gives a negative median bias.
- **The fix:** for the 75 % output to land on the median, the physics side has to sit a little above it. Two offsets were fitted on the training rows against the realized (after-C14) bias, each the smallest that brings every band to ≥ −0.02:
  - **C7 level ×1.025.**
  - **C2 limit ×1.075** on the chip_limits.json band median.
- **Where it shows:** both offsets only matter where no vendor bucket exists, which is when C14 doesn't cap. They are in `materials.json` `consensus_offsets`, and `params.material` applies the C2 one.

### R2.5 The MRR cap: what "MRR" has to mean

**The literal cap fails.** Vendors' depth follows their own flute length and their flute counts differ, so their MRR is not comparable across those. With MRR/D³ as the cap, the optimizer gives up T1's deep, narrow cut: at 50 % it picks 0.14·D × 0.90·D at **0.015 in³/min**, half the 0.029 it gets otherwise.

**What was tried in order:**
1. MRR/D³ (literal).
2. MRR per inch of depth.
3. MRR per unit engaged area (the feed rate).
4. **MRR per unit engaged area and per flute = the feed per flute fz·n (in/min), which is scale-free in D.** This is what C14m now compares. In MRR terms the cap at a cut is scale × median(fz·n)·z·ap·ae.

**The structural MRR finding.**
- Within a bucket, vendors who run faster also run thicker chips: the correlation of log SFM and log fz/D across vendor groups is **+0.24**.
- So the median of the products (speed × chip) is higher than the product of the medians.
- With speed and chip each capped at their own median, MRR lands **≈ 0.15 below the MRR median at 75 %** and about 0.32 below at 50 %. That holds even with speed and chip bias ≈ 0.
- This is a property of the vendors' data, not of the fit (decision R-B).

### R2.6 The new gate (§5, user 2026-10-17)

**Gate rules, per band:**
- median |log error| vs rows ≤ the vendors' own disagreement in that band;
- at 75 %: |bias vs vendor median| ≤ 0.10;
- at 50 %: −0.20 ≤ bias ≤ 0;
- applied to SFM, fz and MRR (like-for-like, R2.5). Vendor bias is reported, not gated.

**The product: all 2,804 rows, C14 from all rows:**

| Band | Median \|log\| SFM / fz at 75 % (vendors' own) | Bias at 75 %: SFM / fz / MRR | Bias at 50 %: SFM / fz / MRR | Gate |
|---|---|---|---|---|
| 1/64–3/64 | 0.16 / 0.31 (0.72 / 1.10) | −0.045 / −0.045 / **−0.196** | −0.129 / −0.088 / **−0.319** | fails on MRR |
| 1/16–3/32 | 0.20 / 0.21 (0.73 / 0.65) | −0.042 / −0.011 / **−0.258** | −0.125 / −0.085 / **−0.400** | fails on MRR |
| 1/8–3/16 | 0.18 / 0.24 (0.45 / 0.39) | −0.000 / −0.009 / −0.084 | −0.083 / −0.085 / **−0.251** | fails on MRR at 50 % |
| 1/4–3/8 | 0.21 / 0.22 (0.38 / 0.35) | −0.000 / −0.021 / **−0.153** | −0.083 / −0.085 / **−0.325** | fails on MRR |
| 1/2–3/4 | 0.20 / 0.18 (0.29 / 0.30) | −0.000 / −0.022 / **−0.151** | −0.083 / −0.085 / **−0.320** | fails on MRR |
| ≥ 1 | 0.17 / 0.15 (0.27 / 0.27) | −0.026 / −0.001 / **−0.155** | −0.110 / −0.084 / **−0.325** | fails on MRR |

- **Speed and chip load pass in every band at both settings, and the accuracy criterion passes everywhere.**
- **MRR fails** for the structural reason in R2.5.
- **Overall at 75 %:** 52 % of rows within ±10 % on SFM (Round 1: 33 %) and 30 % on fz (19 %); median |log| 0.19 / 0.20 (0.32 / 0.28).

**Generalization: hold-out rows, C14 built from the training rows only.**
- At 75 % the SFM bias is −0.11 to −0.27 (fails); fz −0.02 to −0.10 (passes).
- At 50 % SFM is −0.19 to −0.35 (fails in 4 bands); fz −0.05 to −0.14 (passes).
- C14 can only lower a value, so when the training buckets miss a hold-out document's faster vendor, the output lands below that document's median. The product uses every row's data, so this is the out-of-sample margin, not the product's behaviour.

**Process variant** (BT30, C3 at 0.05 mm stock, 5 µm wall, 50 %): fz −0.25 to −2.4 against the vendor median. These are your process limits, which vendor charts do not assume; the largest tools lose most to the 25 µm roughing wall limit.

### R2.7 BT30 compliance (provisional; measure it)

**No measured BT30 spindle/taper stiffness was found.** The values used, in series:

| Element | Stiffness | Source |
|---|---|---|
| Spindle | ≥ 80 N/µm radial | NK Enginex ATC-BT30 spindle spec; a vendor minimum, not Brother |
| Holder-tool joint | 51.6 N/µm and 0.126 N·m/µrad | Özşahin, Ertürk, Özgüven, Budak 2009, IJMTM 49:25, Table 2: a 16 mm carbide tool in a BT40 holder |
| **Combined translational** | **31.4 N/µm** | the two above in series |

**Measurement to make:** a tap test or a static push with a dial indicator on the Speedio would replace these (Duncan/Schmitz receptance coupling). On T1/T12 the holder is **4–8 % of the wall deflection** (table below), so the provisional value moves results little.

### R2.8 T1 and T12 in 17-4 H1025 (356 HB), Speedio 16k + provisional BT30, TIR 0.0002", stock 0.05 mm

"Before" is the step-3 defaults with a rigid holder. "After" uses the calibrated material, the consensus scheme and C14 from all rows.

| Tool | Op | Model | ap | ae | fz | SFM | IPM | MRR in³/min | Binding | Holder share of wall | C14 bucket (vendor groups) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| T1 | adaptive | before | 4·D | 0.026·D | 0.00147 | 255 | 45.8 | 0.0738 | C2, C3, C6 | — | — |
| T1 | adaptive | 50 % | 4·D | 0.071·D | 0.00041 | 129 | 6.5 | **0.0290** | C3, C6, **C14f, C14v** | 7 % | L3 17-4 1/8" light, **Harvey only (3 rows)**: SFM 140, fz 0.00045 |
| T1 | adaptive | 75 % | 4·D | 0.067·D | 0.00045 | 140 | 7.7 | 0.0324 | C3, C6, C14f, C14m, C14v | 8 % | same |
| T1 | adaptive | 50 %, literal MRR/D³ cap | 0.14·D | 0.90·D | 0.00045 | 137 | 7.5 | 0.0148 | C2, C3, C14f | 4 % | L3 heavy (4 groups) |
| T1 | slot | before | 0.14·D | D | 0.00034 | 135 | 5.6 | 0.0122 | C3 | — | — |
| T1 | slot | 50 % | 0.19·D | D | 0.00029 | 129 | 4.5 | 0.0132 | C3, C14v | 4 % | L1 slot, Harvey + OSG: SFM 140, fz 0.000425 |
| T1 | slot | 75 % | 0.14·D | D | 0.00043 | 140 | 7.3 | 0.0160 | C14f, C14v | 4 % | same |
| T1 | finish | before | 4·D | 0.016·D | 0.00029 | 255 | 9.2 | 0.0090 | C3, C6 | — | — |
| T1 | finish | 50 % | 4·D | 0.016·D | 0.00040 | 113 | 5.5 | 0.0054 | C3 (5 µm met), C6, C14v | 6 % | L1 finish, Harvey only: SFM 122 |
| T1 | finish | 75 % | 4·D | 0.016·D | 0.00040 | 122 | 6.0 | 0.0059 | C3, C6, C14v | 6 % | same |
| T12 | adaptive | before | 3·D | 0.172·D | 0.00029 | 236 | 16.9 | 0.0341 | C2, C3, C6 | — | — |
| T12 | adaptive | 50 % | 3·D | 0.223·D | 0.00026 | 168 | 10.7 | **0.0279** | C2, C3, C6 | 7 % | L1 HEM medium, **Garr only (2 rows)**: SFM 341, not binding |
| T12 | adaptive | 75 % | 3·D | 0.198·D | 0.00031 | 186 | 14.1 | 0.0328 | C2, C3, C6 | 7 % | same |
| T12 | slot | before | 0.35·D | D | 0.00022 | 141 | 7.5 | 0.0103 | C2, C8 | — | — |
| T12 | slot | 50 % | 0.35·D | D | 0.00022 | 132 | 7.0 | 0.0095 | C2, C8 | 5 % | L1 slot, Garr + Harvey: SFM 182, not binding |
| T12 | slot | 75 % | 0.35·D | D | 0.00025 | 144 | 8.7 | 0.0118 | C2, C8 | 5 % | same |
| T12 | finish | before | 3·D | 0.031·D | 0.00037 | 262 | 24.0 | 0.0089 | C3, C6, C7 | — | — |
| T12 | finish | 50 % | 3·D | 0.031·D | 0.00029 | 92 | 6.6 | 0.0024 | C6, C14f, C14v | 5 % | L1 finish, Harvey only: SFM 100, fz 0.000318 |
| T12 | finish | 75 % | 3·D | 0.031·D | 0.00032 | 100 | 7.8 | 0.0029 | C6, C14f, C14m, C14v | 5 % | same |

**Reading:**
- **T1 adaptive** is now held by C14 to the vendor median for 17-4 at 1/8" and light engagement: 140 SFM and 0.00045" at 75 %. Its MRR is 0.029–0.032 in³/min, 0.4× the uncapped physics (0.074) and 1.5× v1 (0.019).
  - That bucket has one vendor group (Harvey, 3 rows), because no L1/L2 light-engagement 1/8" 17-4 bucket exists at 350–399 HB. Decision R-C.
- **T12 adaptive** stays physics-bound (C2, C3): 0.028 / 0.033 in³/min, 4.4× / 5.1× v1. C14's only bucket there is two Garr rows at 341 SFM, which do not bind.
- **Finishing speed falls** to the vendors' finishing SFM (Harvey only: 100–122). Vendors run finishing passes at their roughing speed or slower, as Round 1 found.
- **The BT30 compliance** adds 4–8 % to the wall deflection. It binds through C3 wherever C3 binds (T1 adaptive at both settings, T1 slot at 50 %, T12 adaptive), without changing which constraint binds.

### R2.9 Decisions for you (Round 2)

- **R-A. Accept the four aggressiveness points** (R2.2: the data supports them as given) and the C4 ramp ×0.88 → ×1.00 with λ fixed. Recommended: yes.
- **R-B. The MRR gate,** given the +0.24 speed–chip correlation (R2.5). Options:
  - (a) Gate MRR against the product of the speed and chip medians (consistent with capping each). Then MRR bias = SFM bias + fz bias, and the gate passes in every band except 1/64–3/32" at 50 %. There it gives −0.22 / −0.21, because the runout chip limit (C2/C1, a physics floor) holds fz below 0.92× the median.
  - (b) Keep MRR against its own median, and let 75 % run speed and chip at about ×1.075 their medians each. They stay within your ±0.10, and MRR lands on its median. 50 % then sits near −0.01 / −0.01 / −0.17.
  - (c) Accept the MRR shortfall as a deliberate conservatism of capping speed and chip separately.

  Recommended: (a). It is what capping two medians implies.
- **R-C. Single-vendor buckets.** C14 now accepts a bucket with one vendor group: T1 adaptive is capped by 3 Harvey rows, and T12 finishing by Harvey alone. Options:
  - require ≥ 2 vendor groups at a level, falling back to the next level and then to physics;
  - or keep single-vendor buckets but report them as weak.

  Recommended: require 2 groups.
- **R-D. The MRR cap's meaning** (R2.5). Per unit engaged area and per flute (as built), or the literal MRR/D³, which ends T1's deep, narrow roughing. Recommended: as built.
- **R-E. Measure BT30 stiffness** on the Speedio (R2.7). Until then the values are provisional and marked so.
- **R-F. The hold-out margin:** −0.11 to −0.27 on SFM out of sample (R2.6). Accept, or widen the buckets (fewer, larger cells generalize better but follow the user's material less closely).

## Summary for the user (Round 1)

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
