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
