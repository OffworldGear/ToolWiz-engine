# ToolWiz v4 engine notes (before / after)

Branch `v4/e1-engine`. Reasoning and evidence: `docs/research/v4_engine_findings.md`. Conformance at aggressiveness 50 %, runout 0.0001"
(gated), model v2, machine test profile (60,000 rpm). "Before" is `docs/V3_EVALUATION.md` (2026-11-11), "after" the run of this branch
(`pytest tests/test_vendor_conformance.py -k summary -s`).

## Conformance (square-end groups, gated)

| Measure | Gate | Before | After |
|---|---|---|---|
| Groups, overall | 90 % | 90.3 % | 92.4 % |
| slot | 85 % | 97.9 % | 95.8 % |
| side | 85 % | 93.5 % | 94.3 % |
| hem | 85 % | 85.9 % | 93.0 % |
| rough | 85 % | 80.9 % (xfail) | 83.0 % (xfail) |
| micro, D <= 1/16" | 85 % | 79.7 % (xfail) | 78.0 % (xfail) |
| Cells (recommended engagement) | 85 % | 97.5 % | 97.5 % |
| At 0.0002" (not gated) | | 90.0 % | 92.0 % |

Ball and bull-nose groups (V4, ungated, 161 and 209 groups): ball 71.4 % (slot 81.1, rough 73.1, finish 77.0, side 0 of 5, hem 0 of 6);
bull 73.2 % (slot 87.5, rough 70.3, finish 73.9, side 64.7, hem 57.9). Neither meets the 90 % / 85 % targets, so neither is gated.

## Engine / vendor group median at 50 % (planner table, 289 groups)

| Operation | SFM ratio median (p25-p75), before | after | fz ratio before | after | feed (SFM x fz) before | after |
|---|---|---|---|---|---|---|
| hem | 0.80 (0.67-0.92) | 0.92 (0.77-1.00) | 0.89 | 0.89 | 0.69 | 0.78 |
| side | 0.83 (0.74-0.92) | 0.82 (0.69-0.91) | 0.92 | 0.93 | 0.74 | 0.74 |
| slot | 0.94 (0.83-1.06) | 0.95 (0.88-1.13) | 0.89 | 0.90 | 0.87 | 0.86 |
| rough | 1.19 (1.05-1.41) | 1.20 (0.95-1.36) | 0.88 | 0.88 | 1.04 | 1.00 |

(The planner's 0.71 / 0.78 / 0.54 for HEM were measured on its own sample; this table is the same quantity on the conformance groups, medians
of per-group ratios.) 50 % is by design 0.92 x the vendor median, so a ratio of 0.92 is on target. Rough stays high because its groups
are one vendor group (Harvey) against a cross-vendor cap.

## Failing groups left (22 of 289)

* Rough (8 of 47; gate needs <= 7): High Temp Nickel 0.30-0.60 x3 (SFM 66 against 38-62; C14v, bucket median of Harvey 50 and Sandvik 94),
  17-4 1/4-1/2 and > 1/2 at 0.10-0.30 (302 and 273 against 109-250 and 150-250; C14v), 1045 <= 1/32 (361 against 150-250; C7),
  H13 1/32-1/16 and <= 1/32 (SFM 133 and 191 against 45-75; C14v).
* Micro (D <= 1/16", 13 of 59): HTN slot and side <= 1/32, hem 1/32-1/16, rough 1/32-1/16 and <= 1/32 (SFM 66-115 against 21-94; C7, C14v), 316 side <= 1/32 (no cut,
  C14m), 1020 side 1/32-1/16 (SFM 551 against 34-286; C7), 4130 side 1/32-1/16 (fz 0.00057 against <= 0.00050; C2), H13 side <= 1/32
  (fz 0.00017 against <= 0.00010; C1/C2 floor), Ti hem 1/32-1/16 (SFM 245 against 120-225, fz; C4), H13 rough x2, 1045 rough <= 1/32 (above).
* Others: 6061 fz below the vendor floor x4 (C2), 420 hem 1/4-1/2 fz above the span x2 (C14f), 4130 side 1/32-1/16 (above).

## Stability

113 passed, 7 xfailed (six from V3, plus 0.020" 4130 adaptive aggressiveness +10 %: feed +31 % along a flat MRR ridge; reason in the test).

## Runout defaults (API `runout_in`, `runout_source`)

| Request | runout_in | runout_source |
|---|---|---|
| 1/16" 2FL, none given | 0.0001 | default by diameter |
| 1/4" 4FL, none given | 0.0002 | default by diameter |
| 1/4" tool, holder "ER32 Collet Holder" | 0.0004 | holder: standard ER |
| 1/8" tool, holder "Lyndex SK10" | 0.0001 | holder: precision |
| any tool, holder "ER16 UP collet" | 0.0002 | holder: ER-UP |
| any tool, holder "Weldon 3/8" | 0.0012 | holder: weldon |
| runout 0.0003 sent | 0.0003 | request |

## Ball and bull-nose examples (v2, 50 %, Speedio 16k, runout default by diameter)

| Tool, material, operation | rpm | SFM nominal (contact) | fz (in) | feed IPM | ap / ae (in) | limited by |
|---|---|---|---|---|---|---|
| 1/8" ball 2FL, 6061, adaptive | 16000 | 524 | 0.00099 | 31.8 | 0.1875 / 0.0125 | C2, C6, C7 |
| 1/8" ball 2FL, 6061, 3D finish ap 0.010 ae 0.008 | 16000 | 524 (284) | 0.00159 | 51.0 | 0.010 / 0.008 | C7, C14f |
| 1/8" ball 2FL, H13, adaptive | 9066 | 297 | 0.00053 | 9.6 | 0.1875 / 0.0156 | C6, C14f, C14v |
| 1/8" ball 2FL, H13, 3D finish ap 0.010 ae 0.008 | 16000 | 524 (284) | 0.00180 | 57.7 | 0.010 / 0.008 | C2, C7 |
| 1/4" bull 4FL R 0.030, 4130, adaptive | 9365 | 613 | 0.00115 | 43.0 | 0.375 / 0.0375 | C6, C14f |
| 1/4" bull 4FL R 0.030, Ti-6Al-4V, adaptive | 3908 | 256 | 0.00107 | 16.7 | 0.375 / 0.0250 | C6, C14f |

The 3D finish rows are spindle-capped (C7): at ap 0.010" the 1/8" ball's effective diameter is 0.068", so 16,000 rpm is only 284 SFM at the
cutting edge. The finish pass then meets the finish mode's Ra target through `finish_modes` (scallop h = ae^2/(8 R), 32 uin at 0.008" stepover).

## Brand first (owner decisions 2026-11-12, branch `v4/g1-brand`)

Decisions (full text in `docs/V3_IMPLEMENTATION_PLAN.md`, "Owner decisions, 2026-11-12"): the vendor guardrail C14 uses the
tool brand's own charts; no brand (or an uncharted brand) uses Helical HEM / Harvey + Helical charts, then the cross-vendor
consensus; 50 % = the middle of the chart's range, 0 % its bottom, 100 % its top; HEM and traditional roughing never share a
bucket.

**Implementation.**
* `toolwiz_common/brand.py`: free text to a vendor key (harvey, helical, kennametal, kyocera_sgs, osg, sandvik, seco, emuge,
  garr, yg1, titan) by aliases; unknown text gives no brand and is kept for the note. Sources, in order: request field
  `brand` (`/api/calculate`, `/api/calculate_for_fusion`, MCP `toolwiz_calculate_cut`, advisor chat `toolwiz_calculate` and
  `runout_sensitivity`, setup-advisor assumption key `brand`), then the Fusion tool dict's `vendor`.
* `data/model_v2/consensus_by_vendor.json` (`tools/build_vendor_consensus.py`): per vendor and bucket (family, 50-HB bin,
  diameter band, chart class hem | rough | side | slot | finish, engagement class) every row's [lo, nominal, hi] of SFM, fz/D
  and feed per flute (C14m), plus its ae/D; and the cross-vendor section, which reproduces `consensus.json` exactly
  (`--check`: 0 mismatches). A single published value spans 0.76-1.10x of it (the former 0 % / 100 % anchors). Square end
  only; ball and bull-nose tools keep `consensus_shaped.json` with the old scale x median caps (mode "consensus", no range).
  Titan has no square-end rows (all its rows are corner-radius tools), so brand Titan uses the default.
* `physics_v2/optimize.vendor_lookup`: brand (its own chart class; a roughing cut reads the vendor's roughing chart, else its
  side-milling chart, and when it has both, the one whose rows' ae/D is closest to the cut's; widened within the vendor by
  band, engagement, hardness up to 200 HB, then any engagement class) -> default (adaptive: Helical HEM, then Harvey HEM;
  rough, slot, finish: Harvey + Helical pooled) -> cross-vendor consensus (>= 2 vendor groups) -> none (physics only).
  `range_at` maps aggressiveness linearly lo (0) -> mid (0.5) -> hi (1); `c14_cap` applies it to C14v, C14f and C14m. The
  chip-load floor C14lo stays 40-50 % of the middle chip load of the source in use. C2 and C7 keep their aggressiveness
  scales (`CONSENSUS_SCALE_POINTS`): they are physics limits and are not relaxed.
* `v2_bridge.OPERATION_MAP`: pockets ("pocket", "2d pocket", "3d pocket", "pocket clearing") are traditional roughing now (they
  were mapped to adaptive); "dynamic", "hem", "trochoidal milling" are HEM. `setup_advisor._KIND_OPERATION` and the add-in's
  `infer_strategy_for_op` already sent pockets as "Roughing".
* Result field `vendor_basis` {mode, vendor, vendor_name, brand_text, brand_key, brand_source, chart_class, rows,
  sfm_range [lo, mid, hi], fz_range, bucket, widening, note} on every endpoint; one line "Vendor basis: ..." in the web result
  panel; a Brand box (text + list of charted vendors) in the web tool form; the Fusion add-in sends the tool's vendor.

**The 741 SFM jump (1/4" 4FL 17-4, Adaptive Roughing, stickout 0.75", Speedio 16k).** Before: 80 % gave 463 SFM, 90-100 %
gave 731-741 SFM with C14v not listed. Cause: the 17-4 default hardness (230 HB, bin 4) and the wider engagement the optimizer
picks at 90-100 % (ae/D 0.25 -> "heavy") had vendor HEM rows only at bins 6-7; the consensus lookup widened hardness by one bin
only, found no bucket, and C14 switched off, so the speed jumped to the C7 value. Fix: widening steps up to 100 HB and 200 HB
and then any engagement class (`WIDENING_STEPS`), for the vendor sources and the consensus alike. After: 228 / 455 / 554 / 620
SFM at 0 / 50 / 80 / 100 %, the 100 % value being the top of the range (cross-vendor HEM consensus 228-455-620; Helical and
Harvey have no 17-4 HEM rows). Regression test: `tests/test_vendor_brand.py::test_17_4_adaptive_never_exceeds_the_top_of_the_vendor_range`.

**The Seco 17-4 groups at 31-53 SFM.** A test-harness problem, not the engine: Seco publishes hardness as tensile strength
("N/mm2 (Rm)", 500-1200 and 1200-1650); `tools/v2_provisional_limits.row_hb` reads it as Brinell, so the conformance run cut
those groups as 850 HB and 1425 HB material (C2 / C4 limited, no vendor bucket). `tools/calibrate_v2.row_hb` already converts
(HB ~ Rm / 3.38) and so did the consensus tables; the conformance harness now does too (`tests/test_vendor_conformance.row_hb`).
After the fix 5 of Seco's 13 branded 17-4 groups still miss (C7 / C2 limited, listed below; e.g. HEM 1/8-1/4 at
289 SFM against 0.75 x 460). `tools/v2_provisional_limits.row_hb` (used to build the engagement
envelope and the provisional limits) still reads Rm as HB; those data files were not rebuilt here.

### Conformance at 50 % (gated groups, runout 0.0001", test machine 60k)

| Run | Overall (gate 90 %) | slot | side | hem | rough | micro <= 1/16" |
|---|---|---|---|---|---|---|
| Branded, each vendor's own groups and ranges (526 groups) | **89.9 % (xfail)** | 94.1 % | **82.2 % (xfail)** | 91.4 % | 100.0 % | 86.5 % |
| Unbranded, Helical HEM + Harvey/Helical roughing groups (48) | 95.8 % | | | **80.0 % (xfail, n 10)** | 100.0 % | 100.0 % |
| Cross-vendor (part 1, reported; 297 groups) before -> after | 92.4 % -> **84.1 % (xfail)** | 95.8 % -> 95.8 % | 94.3 % -> **74.8 % (xfail)** | 93.0 % -> 88.7 % | 83.0 % -> 89.4 % | 78.0 % -> 79.7 % (xfail) |
| Recommended engagement cells (157) | 97.5 % -> 96.8 % | | | | | |

(The "before" cross-vendor column is the V4 table above; it was measured with the Rm hardness misread.)

Branded per vendor: Emuge 68.8 % (n 64), Garr 100 % (66), Harvey 89.3 % (56), Helical 94.9 % (39), Kennametal 98.7 % (78),
Kyocera SGS 100 % (64), OSG 89.0 % (73), Sandvik 64.5 % (31), Seco 87.2 % (39), YG-1 100 % (16). Every branded group ran on its
own vendor's chart (mode "brand"; `test_branded_runs_use_the_brand`).

Missed gates and why (strict xfails in `tests/test_vendor_conformance.py`):
* Branded overall 89.9 % (53 of 526 fail; 1 group short). Branded side 82.2 % (31 of 174). Nearly all are physics-limited
  below the vendor's minimum: Emuge H13 side and slot, 20 groups at 225-362 SFM against 0.75 x Emuge's minimum 270-379 (C7
  tool-life speed at 50 %); Sandvik HEM / side (C7: 316, 4130, Ti, Inconel, H13); OSG Inconel side (C7); Seco 17-4 micro
  (C2 floor); OSG 6061 slot fz (C2). Six groups are above a vendor's range: five Harvey H13 Profiling (side) groups run on
  Harvey's Roughing chart (its rows' ae/D was closer to the group's) and their fz is above the Profiling chip load (0.00016
  against <= 0.00015, etc.); one Kennametal 17-4 HEM > 1/2" group read a widened bucket (fz 0.00402 against <= 0.00395).
  Raising C7 or C2 to meet a vendor would relax a physics limit, which the owner ruled out.
* Unbranded HEM 80.0 % (2 of 10): Helical 6061 HEM 1/8-1/4 and 1/4-1/2, fz 0.00109 / 0.00218 against 0.6 x Helical's
  minimum 0.00138 / 0.00270 (C2 chip limit).
* Cross-vendor gates (part 1): built for the single cross-vendor average; the unbranded engine now follows the conservative
  Harvey/Helical charts on purpose, so against the pooled ranges of every vendor it sits under the faster ones (side 74.8 %).
  Kept as strict xfails with the measured numbers; the per-vendor gates carry the acceptance. Rough (89.4 %) now passes, so its
  old xfail mark was removed.

Stability (`tests/test_v2_stability.py`): 113 passed, 7 xfailed, unchanged. Pipeline parity snapshot: unchanged (the parity
payloads run on v1).

### Engine / vendor median ratio per vendor at 50 % (`tools/vendor_compare.py`, groups of each vendor's own rows)

SFM ratio / fz ratio; "above max" = groups with engine SFM above the vendor's published maximum. Before = `toolwiz/v4-advisor`
at `cbfc483` (with the Rm hardness fix in the harness).

| Vendor, op (groups) | Before | After, unbranded | After, brand = vendor |
|---|---|---|---|
| Harvey rough (54) | 1.32 / 1.00, above max 41 | 1.00 / 1.00, 1 | 1.00 / 1.00, 1 |
| Harvey HEM (6) | 1.43 / 0.70, 6 | 1.00 / 0.72, 0 | 1.00 / 0.72, 0 |
| Harvey side (9) | 2.45 / 2.58, 9 | 1.00 / 1.89, 0 | 1.00 / 1.48, 0 |
| Helical rough (35) | 1.15 / 0.74, 27 | 1.00 / 0.89, 0 | 1.00 / 0.96, 0 |
| Helical HEM (12) | 1.51 / 0.65, 8 | 1.00 / 0.72, 0 | 1.00 / 0.72, 0 |
| Kennametal rough (10) | 0.74 / 0.87, 0 | 0.71 / 0.81, 0 | 0.74 / 0.94, 0 |
| Kennametal HEM (13) | 0.85 / 0.72, 2 | 0.88 / 0.78, 2 | 0.88 / 0.85, 2 |
| Kennametal side (44) | 0.76 / 0.83, 0 | 0.71 / 0.88, 0 | 0.78 / 0.96, 0 |
| Kyocera SGS HEM (48) | 0.88 / 1.15, 5 | 0.82 / 1.26, 1 | 0.94 / 1.00, 0 |
| Kyocera SGS side (53) | 0.85 / 0.92, 10 | 0.73 / 1.24, 9 | 0.89 / 1.00, 0 |
| OSG HEM (22) | 1.02 / 0.65, 0 | 0.84 / 0.80, 3 | 0.94 / 0.88, 0 |
| OSG side (76) | 0.89 / 0.86, 11 | 0.65 / 0.84, 10 | 0.81 / 0.94, 4 |
| Sandvik HEM (36) | 0.69 / 1.11, 7 | 0.69 / 1.32, 7 | 0.71 / 1.00, 0 |
| Sandvik side (62) | 0.57 / 0.63, 0 | 0.51 / 0.63, 0 | 0.60 / 0.67, 0 |
| Seco HEM (16) | 0.75 / 0.73, 2 | 0.72 / 0.78, 1 | 0.75 / 0.78, 0 |
| Seco side (38) | 0.68 / 0.64, 1 | 0.62 / 0.65, 0 | 0.76 / 0.82, 0 |
| Emuge HEM (16) | 0.84 / 0.93, 0 | 0.70 / 1.04, 2 | 0.93 / 1.00, 0 |
| Emuge side (120) | 0.78 / 1.01, 10 | 0.68 / 1.20, 9 | 0.89 / 1.00, 0 |
| Garr HEM (36) | 0.79 / 0.90, 0 | 0.83 / 1.00, 0 | 0.80 / 0.88, 0 |
| Garr side (30) | 0.84 / 0.98, 4 | 0.68 / 1.07, 0 | 0.90 / 0.91, 0 |
| YG-1 HEM (20) | 0.85 / 1.04, 0 | 0.62 / 1.27, 0 | 0.95 / 1.00, 0 |
| YG-1 side (20) | 0.92 / 1.04, 5 | 0.78 / 1.14, 0 | 0.94 / 1.00, 0 |

Reading: unbranded, the engine now sits on Harvey/Helical (ratio 1.00, none above their maximum) and below the faster
vendors, as decided; with the brand given it moves to that vendor's middle wherever the physics allows (ratios 0.9-1.0),
and where it stays lower (Sandvik, Seco, Kennametal roughing) the C7 tool-life speed or C2 is the limit. Unbranded fz ratios
above 1 (Kyocera, YG-1, Emuge side) come from the default chart's chip load being higher than that vendor's; with the brand
they come to 1.00.

## Chip space, C15 (branch `v4/h1-chipspace`, 2026-11-12)

Reasoning, sources and calibration: `docs/research/chip_space.md`. New check C15: the chip one tooth cuts (fz·ae per unit
edge length, times a packing factor K) must fit the gullet in front of it, φ·(π/4)·D²·(1 − c_z²)/z, with the core ratio
c_z rising with flute count (0.55 at 2 flutes to 0.70 at 7). K per material group is the most packed full slot any vendor
publishes (aluminium 5.74, steel 4.11, stainless and titanium/nickel 4.80; `tools/calibrate_chip_space.py` writes
`data/model_v2/chip_space.json`), raised for full slots deeper than D/2 (×(1 + 0.5·(ap/D − 0.5))). Limit: 100 % of that
packing at aggressiveness 1, 84 % at 50 %. Open-sided cuts (anything under 0.95·D) are not depth-penalised, so HEM is
untouched. Every endpoint returns `chip_space` {utilisation, limit, fill_of_limit, limiting, max_fz_in,
max_fz_by_flutes_in, sentence, ...}; the web panel shows a "Chip room" line only when C15 limits; C15 has plain words in
`runout_sensitivity`, the add-in and `results_v3.js`. The v2 cache key carries the parameter file's version and K values.

MRR (in³/min) at 50 %, Speedio 16k, `/api/calculate` model v2, stickout 4·D, LCF 3·D (17-4 and titanium with no alloy given,
as in the request that produced the problem report). "before → after" only where it changed; "your depth" rows send
cutDepth / cutWidth = D (user engagement).

| Case (50 %, Speedio 16k) | 2FL | 3FL | 4FL | 5FL | 6FL | 7FL |
|---|---|---|---|---|---|---|
| 6061 slot 1/8" | 0.254 | 0.381 | 0.508 | 0.578 | 0.51 | 0.517 |
| 6061 slot 1/4" | 2.3 | 3.45 | 4.6 | 5.57 | 4.98 | 4.86 → **4.8** (C15) |
| 6061 adaptive 1/8" | 0.0982 | 0.147 | 0.196 | 0.245 | 0.295 | 0.344 |
| 6061 adaptive 1/4" | 0.923 | 1.38 | 1.85 | 2.3 | 2.76 | 2.91 |
| 17-4 slot 1/8" | 0.0357 | 0.0559 | 0.0763 | 0.0786 | 0.0789 | 0.0773 |
| 17-4 slot 1/4" | 0.175 | 0.272 | 0.366 | 0.344 | 0.322 | 0.314 |
| 17-4 adaptive 1/8" | 0.0862 | 0.129 | 0.172 | 0.215 | 0.246 | 0.259 |
| 17-4 adaptive 1/4" | 0.432 | 0.647 | 0.863 | 1.06 | 1.04 | 1.03 |
| Ti slot 1/8" | 0.0195 | 0.0293 | 0.0391 | 0.0489 | 0.0549 | 0.0552 |
| Ti slot 1/4" | 0.0959 | 0.144 | 0.192 | 0.24 | 0.249 | 0.242 |
| Ti adaptive 1/8" | 0.0341 | 0.0512 | 0.0683 | 0.0853 | 0.102 | 0.116 |
| Ti adaptive 1/4" | 0.135 | 0.203 | 0.271 | 0.338 | 0.406 | 0.474 |
| 6061 slot 1/4", your depth 1.5·D | 3.44 | 5.17 | 6.88 | 8.61 | 10.3 → **8.87** (C15) | 12 → **8.03** (C15) |
| 6061 slot 1/4", your depth 2·D | 4.59 | 6.89 | 9.18 | 11.5 → **10.6** (C15) | 11.6 → **10.2** (C15) | 11 → **9.17** (C15) |
| 17-4 slot 1/4", your depth 1.5·D | 0.458 | 0.687 | 0.906 | 0.826 | 0.709 | 0.674 |
| 17-4 slot 1/4", your depth 2·D | 0.611 | 0.917 | 0.957 | 0.872 | 0.754 | 0.713 |

Reading:
* What changed: 6061 full slots with 7 flutes, and deep 6061 slots (1.5·D: 6-7 flutes; 2·D: 5-7 flutes). The sentence
  there reads e.g. "5 flutes leave too little chip room for a full slot in aluminum; a 2- or 3-flute tool can take a
  larger chip." (2·D deep; flute counts whose gullets take at least a 50 % larger chip are named) In a 2·D 6061 slot the chip per tooth now falls with flute count (0.00115" up to 4 flutes, 0.00106 /
  0.00085 / 0.00065" for 5 / 6 / 7).
* What did not: 2-5 flute slots at the recommended depth, every 17-4 and titanium cut, every adaptive cut. C15 uses
  12-60 % of its limit in those slots and under 20 % in HEM.
* Why the 5-flute 6061 slot still out-removes the 3-flute: C2 holds every flute count to the same chip (0.0046·D at
  1/4"), half of what vendors run on 3- and 4-flute tools in aluminium; at that chip a 5-flute's gullets are 76 % full
  (of the 50 % limit) at 1·D. With C2 and the guardrail off, C15 alone gives fz/D 0.018 / 0.011 / 0.008 / 0.006 for
  2 / 3 / 4 / 5 flutes (the vendors' aluminium slot chip loads) and the 2- and 3-flute tools remove more than the 5-flute
  (8.8 / 8.4 against 7.4 in³/min). A flute-aware C2 would relax an existing limit; left for the owner.

Conformance (gated runs, 50 %, runout 0.0001"): identical before and after on every gate and every listed group:
cross-vendor overall 84.1 % (slot 95.8, side 74.8, hem 88.7, rough 89.4, micro 79.7; xfails unchanged), recommended
engagement cells 96.8 % of 157, branded 89.9 % of 526 (slot 94.1, side 82.2, hem 91.4, rough 100, micro 86.5; per vendor
unchanged), unbranded 95.8 % of 48 (hem 80.0, rough 100). Stability (`tests/test_v2_stability.py`) 128 passed, 13 xfailed,
before and after. Tests: `tests/test_v2_chip_space.py`.

## Flute-aware chip load (branch `v4/i1-flutes-hf`, 2026-11-12; owner decision: yes, aluminium first)

**Change.** C2's vendor-chip limit (and C2o's worst-flute limit) is multiplied by F(z) of the material group and chart class,
and C14's chip-load and feed-per-flute range reads each vendor row of a z_row-flute tool at F(z)/F(z_row) (each row of
`consensus_by_vendor.json` now carries its flute count, field 10), so the brand / default / consensus guardrail no longer holds
a 2-flute tool to a 4-flute chart value. 0 / 50 / 100 % keep mapping to the (scaled) range's bottom / middle / top.
`tools/fit_chip_by_flutes.py` writes `data/model_v2/chip_by_flutes.json`: per group, class and flute count the rows, vendors
and the median of (row nominal chip fz·sin φe / D) / (C2's band value at the row's diameter); F(z) = that median / the
4-flute median (4 flutes keep their limit). A flute count is used when at least 3 rows from 2 vendor groups chart it; below the
lowest charted count F is held, above the highest it falls with the gullet area per flute (1 − c_z²)/z in full slots and is
held in open-sided cuts; F never rises with flute count. Square-end tools only. C15 stays the ceiling; C1 and C3-C8 untouched.

Applied (`python3 tools/fit_chip_by_flutes.py --table`):

| group, class | 2FL | 3FL | 4FL | 5FL | 6FL | 7FL | rows (vendor groups) by flute count |
|---|---|---|---|---|---|---|---|
| aluminium slot | 2.53 | 1.13 | 1.00 | 0.74 (gullet) | 0.59 (gullet) | 0.46 (gullet) | 2FL 6 (2: Harvey, OSG), 3FL 9 (3), 4FL 11 (3) |
| aluminium side / roughing | 1.48 (held) | 1.48 | 1.00 | 1.00 (held) | 1.00 | 1.00 | 2FL 2 (not charted), 3FL 9 (3), 4FL 24 (4) |

Not applied, measured F (charted counts only): aluminium HEM (one vendor per flute count); steel slot 3FL 1.20, 5FL 0.80;
stainless slot 2FL 4.12 (Seco, Kennametal, Harvey slots at 0.3·D depth), 3FL 1.14, 5FL 0.99; stainless side 0.95-1.25; titanium
slot 3FL 1.15, 5FL 0.91; titanium side 0.94-0.96; HEM in steel, stainless and titanium mixed (0.6-1.6, no trend). Apart from
the stainless 2-flute slots (shallow, three vendors) these are within ±20 % and inside the rows' own spread, so steels,
stainless and titanium stay flute-agnostic.

Results: `chip_space.flute_aware`, `chip_space.flute_factor`, `chip_space.flute_basis`, `vendor_basis.flute_aware`,
`vendor_basis.row_flutes`. The tool recommender drops its "Flute-count gain is optimistic" caveat when both results are
flute-aware (aluminium slots), and keeps it elsewhere. The v2 cache key carries the file's version.

fz (in) / feed (IPM) / MRR (in³/min) at 50 %, `/api/calculate` model v2, Speedio 16k, stickout 4·D, LCF 3·D, no alloy given;
"before → **after**" where it changed:

| Case | 2FL | 3FL | 4FL | 5FL | 6FL | 7FL |
|---|---|---|---|---|---|---|
| 6061 slot 1/8" | 0.00051/16.3/0.254 → **0.00128/41.1/0.362** | 0.00051/24.4/0.381 → **0.00057/27.5/0.429** | 0.00051/32.5/0.508 | 0.00051/40.6/0.578 → **0.00038/30.0/0.469** | 0.00051/48.8/0.510 → **0.00030/28.7/0.449** | 0.00051/56.9/0.517 → **0.00023/25.9/0.405** |
| 6061 slot 1/4" | 0.00115/36.8/2.30 → **0.00260/83.3/3.31** | 0.00115/55.2/3.45 → **0.00129/62.1/3.88** | 0.00115/73.5/4.60 | 0.00115/91.9/5.57 → **0.00085/67.8/4.24** | 0.00113/108.9/4.98 → **0.00067/64.7/4.04** | 0.00107/119.4/4.80 → **0.00052/58.6/3.66** |
| 6061 slot 1/2" | 0.00235/51.1/12.8 → **0.00472/102.4/16.3** | 0.00234/76.1/14.4 → **0.00264/85.9/14.9** | 0.00233/101.2/14.4 → **0.00212/92.1/14.1** | 0.00220/119.1/14.2 → **0.00172/93.3/13.4** | 0.00215/139.6/14.1 → **0.00133/86.2/12.5** | 0.00219/166.0/14.2 → **0.00104/79.0/11.8** |
| 6061 adaptive 1/8" | 0.00100/32.0/0.0982 | 0.00100/48.0/0.147 | 0.00100/64.1/0.196 | 0.00100/80.1/0.245 | 0.00100/96.1/0.295 | 0.00100/112.1/0.344 |
| 6061 adaptive 1/4" | 0.00201/64.3/0.923 | 0.00201/96.5/1.38 | 0.00201/128.6/1.85 | 0.00201/161.2/2.30 | 0.00201/193.4/2.76 | 0.00178/199.7/2.91 |
| 6061 adaptive 1/2" | 0.00376/120.3/7.37 | 0.00375/180.0/11.1 | 0.00313/200.0/12.5 | 0.00249/199.6/12.2 | 0.00207/199.0/11.7 | 0.00178/199.0/11.3 |

17-4 and titanium (slot and adaptive, 1/8", 1/4", 1/2", 2-7 flutes): every value unchanged (flute-agnostic by decision).
6061 adaptive: unchanged (HEM rows do not show the trend).

Reading:
* 1/2" slot: the 2-flute tool now removes the most (16.3 against 13.4 in³/min for 5 flutes; C3-limited), the 3-flute 14.9.
* 1/8" and 1/4" slots at 4·D stickout: the 2-flute tool's chip doubled (0.0102·D) but C3 (deflection, 1 % of D at 50 %) binds
  it at ap 0.77·D (1/4") and 0.59·D (1/8"): 3.31 against 4.24 (1/4") and 0.362 against 0.469 (1/8") for the 5-flute. The
  3-flute is C2-limited at F 1.13 (3.88 / 0.429). The expected "2 or 3 flutes at least the 5-flute" holds at 1/2" and, at
  3·D stickout, at 1/4" (2FL 5.80 against 4.24) and 1/8" (0.642 against 0.469) (`tests/test_v2_flute_aware.py`); at 4·D
  stickout below 1/2" the stiffer 4- and 5-flute sections win on deflection, which is physics, not the chip limit.
* 5-7 flute aluminium slots are now held by C2 at the 4-flute gullet fill (before: the same chip as 4 flutes, C15 only at 7).

Conformance: see "Conformance after flute-aware chip load and high-feed tools" at the end.

## High-feed end mills in v2 (branch `v4/i1-flutes-hf`, 2026-11-12)

Before: geometry "High Feed" ran as an ordinary corner-radius end mill (1/8" 4FL Ti slot at 50 %: ap 0.050", fz 0.0002",
3.4 IPM); v1 had a fixed-lead-angle rule. Now (`physics_v2/highfeed.py`, `endforms.HighFeedProfile`, design doc §3.5):
straight lead edge at κ0 from r_in to the OD at apmx; chip normal to the edge fz·sin φ·sin κ0 through the shaped-tool slice
model (C1, C2 on it), in-plane radial force × sin κ0, axial force reported (`loads.axial_peak_n`; no axial-load check exists),
speed at the effective diameter, C6 ap ≤ apmx, C15 on fz·sin κ0, no square-end engagement envelope. Selection: geometry
"High Feed" or tool text "high feed" / HF / HFM; operation names with "high feed" map to slot ("slot"/"window" in the name) or
rough for a high-feed tool and stay on v1 for other tools; finishing with a high-feed tool stays on v1. Inputs `maxAp` /
`apmx`, `leadAngle` (request), else the programming radius (`cornerRadius`: tan κ0 = apmx / r), else 15° and 0.06·D, marked
assumed. Every input is in the v2 cache key. Tips: no plunge, max ramp angle min(atan(apmx/D), 3°), helix ≥ 1.15·2·r_in,
stepped walls with the radial / axial stock to leave, depth per level, assumed geometry, axial load, and a warning when the
physics speed is over 1.1× the square-end chart's (`high_feed.square_end_chart_sfm`, reference only).

Vendor basis: mode "none", note "Vendor basis: none: no vendor chart for high-feed tools yet; physics limits only." The
loader is ready: rows with `tool.end = "high_feed"` go to chart classes `hf_slot` (slot rows) and `hf_rough` (rough, side,
HEM, pocket, face rows) in `consensus_by_vendor.json`, per vendor and cross-vendor, never pooled with square-end classes;
a high-feed tool reads them in the brand -> default (Harvey + Helical) -> consensus (≥ 2 vendor groups) order with 0/50/100 %
= bottom/middle/top (`tests/test_v2_high_feed.py::TestVendorPath`, on the SYNTHETIC fixture `tests/fixtures/highfeed_synthetic`).
**Done 2026-11-12:** 438 cited high-feed rows are in `tests/benchmarks/v2/highfeed_{harvey,helical,seco}.json` (Niagara Cutter
SN200R/SN400R is filed under the Seco brand key; sources and gaps in `tests/benchmarks/v2/HIGHFEED_NOTES.md`). Harvey and
Helical are one vendor group, so there are two independent sources. With the charts loaded the engine's titanium high-feed
result stays below them (1/8" 4FL slot at 50%: 147 SFM and 0.0020 in/tooth against Niagara's 377 SFM and 0.0023; the speed is
the square-end tool-life speed, the chip is C2): a level fit for the high-feed class from these rows is the open follow-up.
The commands that were run:

```
git mv tests/benchmarks/v2_staged/highfeed_*.json tests/benchmarks/v2/   # file highfeed_<vendor>.json -> vendor key <vendor>
python3 tools/build_vendor_consensus.py --check        # rebuilds consensus_by_vendor.json; square-end cross-vendor check must stay 0
python3 tools/fit_chip_by_flutes.py --check            # square-end rows only: must still say "current"
timeout 3000 python3 -m pytest -q -p no:cacheprovider tests/test_v2_high_feed.py tests/test_v2_benchmark_dataset.py
```

(`tests/test_v2_benchmark_dataset.py` checks `tool.end` against its END_TYPES; "high_feed" has to be accepted there by
whoever adds the rows.) The square-end consumers (calibrate_v2, v2_invariants, calibrate_chip_space, the conformance harness,
the recommender catalog) skip non-square rows already.

1/8" 4-flute, slot, Speedio 16k, stickout 0.5", `/api/calculate` model v2; time for a 4.2" slot 0.15" deep = levels ×
4.2" / feed (levels = ceil(0.15 / ap)). High-feed geometry assumed (15°, apmx 0.0075"). Ti = "Titanium Alloy", alloy
Ti-6Al-4V (Grade 5, Annealed); 17-4 with no alloy given.

| Material | Tool | a | rpm | SFM | fz (in) | feed IPM | ap (in) | levels | time min | limited by |
|---|---|---|---|---|---|---|---|---|---|---|
| Ti-6Al-4V | HF 4FL | 0 | 3708 | 121 | 0.00162 | 24.1 | 0.0075 | 20 | 3.49 | C2, C6 |
| Ti-6Al-4V | HF 4FL | 50 | 4489 | 147 | 0.00196 | 35.2 | 0.0075 | 20 | 2.39 | C2, C6 |
| Ti-6Al-4V | HF 4FL | 100 | 5367 | 176 | 0.00234 | 50.3 | 0.0075 | 20 | 1.67 | C2, C6 |
| Ti-6Al-4V | square 4FL | 0 | 2903 | 95 | 0.00020 | 2.4 | 0.0375 | 5 | 8.82 | C8, C14f, C14m, C14v |
| Ti-6Al-4V | square 4FL | 50 | 3820 | 125 | 0.00041 | 6.2 | 0.0500 | 3 | 2.02 | C8, C14f, C14m, C14v |
| Ti-6Al-4V | square 4FL | 100 | 4202 | 138 | 0.00052 | 8.7 | 0.1036 | 2 | 0.97 | C14f, C14m, C14v |
| Ti-6Al-4V | square 3FL | 0 | 2903 | 95 | 0.00020 | 1.8 | 0.0375 | 5 | 11.73 | C8, C14f, C14m, C14v |
| Ti-6Al-4V | square 3FL | 50 | 3820 | 125 | 0.00041 | 4.7 | 0.0500 | 3 | 2.69 | C8, C14f, C14m, C14v |
| Ti-6Al-4V | square 3FL | 100 | 4202 | 138 | 0.00052 | 6.5 | 0.1051 | 2 | 1.29 | C14f, C14m, C14v |
| 17-4 | HF 4FL | 0 | 11815 | 387 | 0.00162 | 76.7 | 0.0075 | 20 | 1.10 | C2, C6 |
| 17-4 | HF 4FL | 50 | 14302 | 468 | 0.00196 | 112.2 | 0.0075 | 20 | 0.75 | C2, C6 |
| 17-4 | HF 4FL | 100 | 16000 | 524 | 0.00234 | 150.1 | 0.0075 | 20 | 0.56 | C2, C6, C7 |
| 17-4 | square 4FL | 0 | 3716 | 122 | 0.00023 | 3.4 | 0.0350 | 5 | 6.21 | C8, C14f, C14v |
| 17-4 | square 4FL | 50 | 6112 | 200 | 0.00040 | 9.8 | 0.0625 | 3 | 1.29 | C8, C14f, C14m, C14v |
| 17-4 | square 4FL | 100 | 6723 | 220 | 0.00049 | 13.3 | 0.0880 | 2 | 0.63 | C14f, C14m, C14v |
| 17-4 | square 3FL | 0 | 3716 | 122 | 0.00023 | 2.5 | 0.0350 | 5 | 8.30 | C8, C14f, C14v |
| 17-4 | square 3FL | 50 | 6112 | 200 | 0.00040 | 7.3 | 0.0611 | 3 | 1.72 | C8, C14f, C14m, C14v |
| 17-4 | square 3FL | 100 | 6723 | 220 | 0.00049 | 10.0 | 0.0864 | 2 | 0.84 | C14f, C14m, C14v |

Reading: in titanium the high-feed tool runs 4.8× the chip per tooth of the square tool (C2 on the thinned chip, sin 15° =
0.26) and 5.7× the feed, but at 0.0075" per level it needs 20 levels against 2-5: at 50 % it is about 15 % slower than the
square 4-flute (2.39 against 2.02 min) and faster than the 3-flute (2.69); at 0 % it is 2.5× faster (the square tools are
held to the bottom of the vendor range), at 100 % 1.7× slower (the square tools take 2 levels). Its speed is C7's (147 SFM at
50 %, no vendor cap).
In 17-4 the square tools are held by the vendor charts (200 SFM at 50 %) and the high-feed tool is not: its 468 SFM is
C7's physics value (warned in the result). The unverified Seco-style figure (7,640 rpm, 0.0035"/tooth, 107 IPM, ap 0.0079" in Ti)
is 1.7× our rpm and 1.8× our chip per tooth: our C7 Ti slot speed and C2 (the square-end vendor chip invariant applied to
the thinned chip) both sit below it; the binding limits are C2 and C6 (ap = max ap). Not calibrated to it.

## Conformance after flute-aware chip load and high-feed tools (branch `v4/i1-flutes-hf`)

Gated runs at 50 %, runout 0.0001", test machine 60k (`pytest tests/test_vendor_conformance.py -s`), before = this branch's
base `850ec19` run the same way:

| Gate | Before | After |
|---|---|---|
| Branded overall (gate 90 %, 526 groups) | 89.9 % (strict xfail) | **90.3 % (passes; xfail mark removed)** |
| Branded slot / side / hem / rough / micro | 94.1 / 82.2 (xfail) / 91.4 / 100 / 86.5 | **95.4** / 82.2 (xfail) / 91.4 / 100 / 86.5 |
| Branded OSG | 89.0 % (n 73) | 91.8 % (the two OSG 6061 slot groups, fz under OSG's minimum, now pass) |
| Unbranded overall / hem / rough / micro | 95.8 / 80.0 (xfail) / 100 / 100 | unchanged |
| Cross-vendor overall / slot / side / hem / rough / micro | 84.1 (xfail) / 95.8 / 74.8 (xfail) / 88.7 / 89.4 / 79.7 (xfail) | unchanged |
| Recommended engagement cells | 96.8 % of 157 | unchanged |
| Ball / bull-nose groups (not gated) | 71.4 % / 72.7 % | unchanged |

The only other change in any listed group: the cross-vendor 6061 slot 1/16-1/8 group's fz rose 0.00051 -> 0.00057" (still
under the 0.00060 floor). High-feed tools are not in the conformance data (no rows). Stability (`tests/test_v2_stability.py`):
113 passed, 7 xfailed before; 115 passed, 5 xfailed after (the 1/16" and 1/32" 2-flute 6061 slot "+10 % stickout" cases now
pass and their strict marks were removed). Tests: `tests/test_v2_flute_aware.py`, `tests/test_v2_high_feed.py`.

## High-feed level fit (branch `v4/j1-hf-fit`, 2026-11-12)

**Change.** A high-feed end mill now runs C7 at the square-end level × a high-feed speed factor and C2 (C2o) at the square-end
nominal chip limit × a high-feed chip factor, per material family and chart class (`hf_slot` for slots, `hf_rough` for
roughing, side and adaptive; the factor multiplies the slot level for slots and the rough level otherwise).
`tools/fit_high_feed_level.py` writes `data/model_v2/high_feed_level.json` from the 399 cited high-feed rows in engine
families (438 less 39 Cobalt Chrome): target = each row's bucket median (family, 50-HB bin, band, class; each vendor group's
median, then the median over groups), factor = exp(median log(target / the engine's square-end value at 75 %)), as
`fit_level_consensus` fitted the adaptive / rough levels. Hold-out: leave one vendor group out (Harvey + Helical vs
Seco / Niagara), the other group's fit predicting its own bucket medians. Families with both groups: two-group factors;
17-4 and 420 (Harvey only): one-group factors, applied, marked "one group (lower)"; aluminium and families without rows keep
the square-end level. Justification (written in the file): thin chip fz·sin κ, shallow ap and a short arc of edge in contact
per tooth, i.e. less heat and edge load per tooth; Harvey SF_709800 ("High Feed End Mills for High Temp Alloys"), Niagara
SN400R ("ISO P, S and K ... stainless steel, Inconel and titanium", Ti start value 377 SFM at ap .008"). Everything else
(C1, C3-C6, C8-C15, the 0/50/100 % map, the guardrail) is unchanged. Results carry `high_feed.level_speed_factor`,
`level_chip_factor`, `level_basis` and `high_feed.spindle_limited` (a sentence and a warning when the chart speed needs more
rpm than the spindle has and the spindle binds; the chip stays at or below the chart's). The "not chart-capped" tip now shows
only when no high-feed chart applies. The v2 cache key carries the file's version.

| family | class | rows (groups) | hardness exp (square) | speed factor | hold-out err | chip factor | hold-out err | confidence |
|---|---|---|---|---|---|---|---|---|
| High Temp Nickel Alloy | hf_rough | 22 (Harvey Performance 15, Seco Tools 7) | 0.34 (0.35) | 2.01 | 75% | 2.07 | 28% | two groups |
| High Temp Nickel Alloy | hf_slot | 31 (Harvey Performance 24, Seco Tools 7) | 0.34 (0.35) | 0.98 | 31% | 1.83 | 26% | two groups |
| Stainless - 300 Series (316) | hf_rough | 21 (Harvey Performance 15, Seco Tools 6) | 0.26 (0.32) | 1.95 | 27% | 3.11 | 11% | two groups |
| Stainless - 300 Series (316) | hf_slot | 36 (Harvey Performance 24, Seco Tools 12) | 0.26 (0.32) | 1.39 | 19% | 1.87 | 23% | two groups |
| Stainless - 400 Series (420) | hf_rough | 10 (Harvey Performance 10) | 0.30 (0.42) | 1.81 | - | 3.14 | - | one group (lower) |
| Stainless - 400 Series (420) | hf_slot | 16 (Harvey Performance 16) | 0.30 (0.42) | 1.12 | - | 1.89 | - | one group (lower) |
| Stainless - PH Series (17-4) | hf_rough | 10 (Harvey Performance 10) | 0.31 (1.84) | 2.16 | - | 2.41 | - | one group (lower) |
| Stainless - PH Series (17-4) | hf_slot | 16 (Harvey Performance 16) | 0.31 (1.84) | 1.35 | - | 1.62 | - | one group (lower) |
| Steel - Low Carbon (1020) | hf_rough | 12 (Harvey Performance 5, Seco Tools 7) | - (0.42) | 2.34 | 13% | 4.14 | 9% | two groups |
| Steel - Low Carbon (1020) | hf_slot | 15 (Harvey Performance 8, Seco Tools 7) | - (0.42) | 1.99 | 59% | 2.22 | 29% | two groups |
| Steel - Medium Carbon (1045) | hf_rough | 17 (Harvey Performance 10, Seco Tools 7) | 0.15 (0.42) | 1.58 | 11% | 2.94 | 48% | two groups |
| Steel - Medium Carbon (1045) | hf_slot | 23 (Harvey Performance 16, Seco Tools 7) | 0.15 (0.42) | 1.22 | 29% | 1.58 | 77% | two groups |
| Steel - Medium Carbon Alloy (4130) | hf_rough | 27 (Harvey Performance 20, Seco Tools 7) | 0.72 (0.42) | 1.47 | 12% | 3.11 | 21% | two groups |
| Steel - Medium Carbon Alloy (4130) | hf_slot | 39 (Harvey Performance 32, Seco Tools 7) | 0.72 (0.42) | 1.15 | 33% | 1.83 | 24% | two groups |
| Steel - Tool (H13) | hf_rough | 26 (Harvey Performance 20, Seco Tools 6) | 0.31 (0.24) | 1.87 | 69% | 2.91 | 22% | two groups |
| Steel - Tool (H13) | hf_slot | 38 (Harvey Performance 32, Seco Tools 6) | 0.31 (0.24) | 1.10 | 36% | 1.81 | 27% | two groups |
| Titanium Alloy | hf_rough | 17 (Harvey Performance 10, Seco Tools 7) | 0.49 (0.31) | 1.88 | 16% | 2.19 | 25% | two groups |
| Titanium Alloy | hf_slot | 23 (Harvey Performance 16, Seco Tools 7) | 0.49 (0.31) | 1.72 | 58% | 1.83 | 30% | two groups |

(`python3 tools/fit_high_feed_level.py --table`.) Hardness: where the high-feed charts print two hardness classes for the same
tool (Harvey), their own slope replaces the square-end C7 hardness exponent for high-feed tools (17-4: 0.31 instead of 1.84;
without it a 420 HB 17-4 ran at 151 SFM against Harvey's 400). The hold-out errors are large where the two groups publish different
levels for the same family: Ti slots, Helical's HEVF-C-5 (a combination feed / HEM tool, 1/4"-1/2") at 160-180 SFM, Harvey's
high-temp-alloy series at 250-300, Niagara at 377; a single factor sits between them. It is a level, not a law.

1/8" 4FL Ti slot at 50 % (Speedio 16k, `params.optimize`): before 147 SFM / fz 0.0020"; now unbranded (Harvey + Helical
default chart, C14v binding at the chart middle) 250 SFM / 0.0020-0.0026" (geometry-dependent); brand Niagara with the SN400R
geometry (ap .008", rp .0148") 253 SFM / 0.00196" (C2, C6; 67 % of Niagara's 377 SFM and 86 % of its 0.0023"); 17-4 at
the engine's default 200 HB 450 SFM = the Harvey chart middle (C14v), at 420 HB (database "17-4 PH", H900 class) 239 SFM against
Harvey's 400 (60 %; one-group factor, Harvey's 17-4 chart is well above Helical's). 1/16" in 17-4 at 200 HB is
spindle-limited (the chart's 450 SFM needs 27,500 rpm; 262 SFM at 16,000), fz held at the chart middle; 1/16" Ti stays under the spindle (C7 240 SFM at 14,700 rpm; Niagara's 377 SFM would
need 23,000 rpm), and the result says the spindle is not what limits it.

Conformance (new part 6 of `tests/test_vendor_conformance.py`, 50 %, runout 0.0001", 60k test machine, same tolerances):
branded high-feed groups 88.8 % of 80 (gate 85 %, passes; slot 82.0 % of 50 strict xfail, side 100 % of 12, rough 100 % of
18; Harvey 77.8 %, Helical 100 %, Seco 96.3 %); unbranded (Harvey + Helical groups on the default chart) 77.4 % of 53 (strict
xfail; rough 100 % passes, slot 65.7 % strict xfail). The failures are Harvey slot groups whose speed sits under 0.75 x
Harvey's minimum (Inconel, 17-4, 420, H13 slots: the factor is the median over both groups, and Harvey publishes more than
Niagara / Helical for these) and one Seco 1045 fz just under the floor. No other gate changed (the square-end, ball and
bull-nose paths do not read the file). The decision study that uses this is `docs/SLOT_ROUGHING_STUDY.md`.
