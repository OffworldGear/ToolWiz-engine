# ToolWiz v3 evaluation

Date: 2026-11-11. Branch `v3/d-eval`. Engine: cutting model v2 (`physics_v2/`). Owner settings: aggressiveness 50 %, runout 0.0002 in (TIR), machine Brother Speedio S500X2 (max 16,000 rpm). Nothing in code, data or tests was changed for this report. All numbers below were copied from the runs listed in "How to reproduce".

## Summary

- The test suite passes: 1220 passed, 1 skipped, 8 expected failures (xfail). The xfails are known gaps listed below, not hidden errors.
- Vendor conformance at 50 % passes the overall gate (90.3 % of groups, gate 90 %). Slot (97.9 %), side (93.5 %) and hem (85.9 %) pass their 85 % per-operation gates.
- Two gates fail: rough at 80.9 % (gate 85 %) and micro tools at 1/16 in and below at 79.7 % (gate 85 %). Both are marked xfail with the reason "known gap".
- The recommended-engagement cell test passes: 97.5 % of 157 cells (gate 85 %).
- Micro groups (D <= 1/16 in) pass 79.7 %, below the 85 % gate. The engine notes attribute part of the micro "no cut" results to the 0.0002 in runout assumption. Measured runout is not in the data.
- Stability: 114 pass, 6 xfail. The xfails are sensitivity cases (runout and stickout), each with a stated physical reason.
- T-slot conformance: 98.9 % of 279 rows pass. 3 Ingersoll rows fail on chip load.
- Strategy planner: for the profile cut-out in 6061, 17-4 and titanium, the planner recommends the full-width 1/8 in contour slot. For the T-slot job, it recommends the planned Harvey 3/8 x 1/16 keyseat cutter.
- Every wear number is low confidence. The planner uses a placeholder Taylor exponent and has no logged tool lives.
- Master library: both sets build in about 42 s. The audit finds 0 STOP findings on ToolWiz presets in either set. 36 items (non-ferrous) and 64 items (steels & exotics) are skipped with reasons. Nothing is dropped.

## Test suite

Command: `python -m pytest -q -p no:cacheprovider -rx` (run with `TOOLWIZ_MODEL` unset).

| Passed | Failed | Xfailed | Skipped | Subtests | Time |
|---|---|---|---|---|---|
| 1220 | 0 | 8 | 1 | 17,792 | 468.7 s |

The baseline in the implementation plan was 684 passed, 1 skipped. The count is higher because the v3 test files were added.

Every xfail (from `-rx`):

| Test | Reason (as written in the test) |
|---|---|
| `test_v2_stability.py::test_feed_is_non_increasing_in_runout[0.0312in-2fl-Steel-Adaptive]` | 1/32 in 4130 adaptive: the radial runout offset adds 1:1 to the worst-flute chip at ae = 0.15 D, so the feed falls 16 % between TIR 0 and 0.1 x fz (limit 15 %) |
| `test_v2_stability.py::test_feed_is_non_increasing_in_runout[0.0625in-2fl-Steel-Adaptive]` | 1/16 in 4130 adaptive: same 1:1 chip effect at ae = 0.15 D; feed 10.08 -> 8.35 IPM (17 %) between TIR 0 and 0.1 x fz |
| `test_v2_stability.py::test_ten_percent_input_change...[stickout+10%-0.0312in-2fl-Aluminum-Slotting]` | 1/32 in 6061 slot: +10 % stickout cuts the stiffness by about 25-30 % (L^3), so the deflection-limited depth moves with it |
| `test_v2_stability.py::test_ten_percent_input_change...[stickout+10%-0.0625in-2fl-Aluminum-Slotting]` | 1/16 in 6061 slot: +10 % stickout cuts the stiffness about 30 % (L^3); depth 0.0314 -> 0.0218 in (31 %) |
| `test_v2_stability.py::test_ten_percent_input_change...[stickout+10%-0.0625in-2fl-Steel-Adaptive]` | 1/16 in 4130 adaptive: for a narrow cut the force stops growing with depth, so depth is free until deflection fails; the C3 margin falls 12.9 % -> 5.1 % -> -3.2 % over +0 %, +5 %, +10 % stickout; past zero the deep cut is infeasible: depth 0.125 -> 0.0127 in |
| `test_v2_stability.py::test_ten_percent_input_change...[stickout+10%-0.0625in-2fl-Steel-Slotting]` | 1/16 in 4130 slot: +10 % stickout cuts the stiffness by about 25-30 % (L^3), so the deflection-limited depth moves with it |
| `test_vendor_conformance.py::test_fixed_engagement_per_operation[rough]` | Known gap: below the 85 % gate (v3 engine, 2026-11-11) |
| `test_vendor_conformance.py::test_fixed_engagement_micro_tools` | Known gap: below the 85 % gate (v3 engine, 2026-11-11) |

The two conformance xfails are discussed under "Vendor conformance". The six stability xfails are discussed under "Stability".

## Vendor conformance

Command: `TOOLWIZ_MODEL=` (empty, so the production default v2 applies), `TOOLWIZ_CONFORMANCE_DUMP=<scratchpad>/conf.json python -m pytest -q -p no:cacheprovider tests/test_vendor_conformance.py -rx -s`. Result: 6 passed, 2 xfailed, 367 s. The full dump is in `conf.json` next to the scratchpad copy of the run output.

Scope: 297 groups and 157 cells from 2,420 in-scope rows (3,423 rows in the dataset). Eight groups are excluded because their geometry is incomplete (reach beyond the flutes, no published neck). All excluded groups are rough groups for High Temp Nickel, 17-4, and Titanium.

### Pass rates against the gates

| Test | Measured | Gate | Result |
|---|---|---|---|
| Fixed engagement, all groups | 90.3 % (289 groups; 28 fail) | >= 90 % | Pass (narrow) |
| Fixed engagement, slot | 97.9 % | >= 85 % | Pass |
| Fixed engagement, side | 93.5 % | >= 85 % | Pass |
| Fixed engagement, hem | 85.9 % | >= 85 % | Pass (narrow) |
| Fixed engagement, rough | 80.9 % | >= 85 % | **Fail (xfail)** |
| Fixed engagement, micro (D <= 1/16 in) | 79.7 % | >= 85 % | **Fail (xfail)** |
| Recommended engagement, cells | 97.5 % of 157 (4 fail) | >= 85 % | Pass |
| Diagnostic: per-row fixed engagement, 203 rows | 41.9 % | not gated | Printed only |

### Runout lines printed by the conformance run (not gated)

The conformance run prints two runout lines. The gated numbers above are the first line. The second line is printed without a stated basis in the test, so it is reported as printed.

| Measure | Value |
|---|---|
| "at 0.0002 in" groups overall | 90.0 % (slot 97.9, side 92.7, hem 85.9, rough 80.9, micro 78.0) |
| Feed at 0.0002 in relative to 0.0001 in (median over groups) | 100 % in every diameter band (<=1/32 n=23; 1/32-1/16 n=40; 1/16-1/8 n=57; 1/8-1/4 n=63; 1/4-1/2 n=62; >1/2 n=50) |

The median feed in each band is the same at 0.0001 in and 0.0002 in. This run did not produce a gated micro result at 0.0001 in.

### Failing groups (28 of 289), grouped by material

Format: operation, diameter band, engagement class, number of vendor rows, and the failure text printed by the test. "fz" is chip load (in/tooth); "SFM" is surface speed.

**Aluminum - Wrought (6061)**

| Operation | Band | Engagement | n | Failure |
|---|---|---|---|---|
| hem | 1/16-1/8 | <=0.10 | 2 | fz 0.00083 not in [0.00108, 0.00262] (spindle-limited group) |
| side | 1/16-1/8 | 0.30-0.60 | 2 | fz 0.00058 not in [0.00060, 0.00141] |
| side | 1/8-1/4 | 0.30-0.60 | 4 | fz 0.00119 not in [0.00120, 0.00375] |
| slot | 1/16-1/8 | slot | 5 | fz 0.00049 not in [0.00060, 0.00250] |

**High Temp Nickel Alloy**

| Operation | Band | Engagement | n | Failure |
|---|---|---|---|---|
| hem | 1/32-1/16 | 0.10-0.30 | 2 | SFM 75 not in [75, 300] |
| hem | 1/32-1/16 | <=0.10 | 3 | fz 0.00018 not in [0.00024, 0.00075] |
| hem | <=1/32 | 0.10-0.30 | 2 | SFM 70 not in [75, 300] |
| rough | 1/16-1/8 | 0.30-0.60 | 5 | SFM 64 not in [38, 62] |
| side | 1/32-1/16 | <=0.10 | 3 | SFM 81 not in [82, 237] |

**Stainless - 300 Series (316)**

| Operation | Band | Engagement | n | Failure |
|---|---|---|---|---|
| side | <=1/32 | <=0.10 | 3 | v2 gave no cut (v2: C14m) |

**Stainless - 400 Series (420)**

| Operation | Band | Engagement | n | Failure |
|---|---|---|---|---|
| hem | 1/4-1/2 | 0.10-0.30 | 2 | fz 0.00291 not in [0.00109, 0.00226] |
| hem | 1/4-1/2 | <=0.10 | 2 | fz 0.00373 not in [0.00168, 0.00354] |
| side | 1/16-1/8 | <=0.10 | 2 | fz 0.00067 not in [0.00071, 0.00171] |

**Stainless - PH Series (17-4)**

| Operation | Band | Engagement | n | Failure |
|---|---|---|---|---|
| rough | 1/16-1/8 | 0.30-0.60 | 3 | SFM 289 not in [105, 250] |
| rough | 1/4-1/2 | 0.10-0.30 | 7 | SFM 317 not in [109, 250] |
| rough | >1/2 | 0.10-0.30 | 2 | SFM 273 not in [150, 250] |

**Steel - Low Carbon (1020)**

| Operation | Band | Engagement | n | Failure |
|---|---|---|---|---|
| hem | 1/4-1/2 | 0.10-0.30 | 2 | SFM 422 not in [490, 1268] |
| hem | 1/8-1/4 | 0.10-0.30 | 2 | SFM 422 not in [490, 1268] |
| hem | >1/2 | 0.10-0.30 | 2 | SFM 422 not in [490, 1268] |
| side | 1/32-1/16 | <=0.10 | 2 | SFM 526 not in [34, 286] |

**Steel - Medium Carbon (1045)**

| Operation | Band | Engagement | n | Failure |
|---|---|---|---|---|
| rough | <=1/32 | 0.10-0.30 | 2 | SFM 361 not in [150, 250] |

**Steel - Medium Carbon Alloy (4130)**

| Operation | Band | Engagement | n | Failure |
|---|---|---|---|---|
| side | 1/32-1/16 | <=0.10 | 2 | fz 0.00054 not in [0.00022, 0.00050] |

**Steel - Tool (H13)**

| Operation | Band | Engagement | n | Failure |
|---|---|---|---|---|
| rough | 1/32-1/16 | 0.10-0.30 | 3 | SFM 133 not in [45, 75]; fz 0.00036 not in [0.00008, 0.00021] |
| rough | <=1/32 | 0.10-0.30 | 2 | SFM 191 not in [45, 75]; fz 0.00017 not in [0.00005, 0.00011] |
| side | <=1/32 | 0.10-0.30 | 13 | fz 0.00017 not in [0.00001, 0.00010] |

**Titanium Alloy**

| Operation | Band | Engagement | n | Failure |
|---|---|---|---|---|
| hem | 1/32-1/16 | <=0.10 | 3 | fz 0.00032 not in [0.00036, 0.00075] |
| rough | 1/16-1/8 | 0.30-0.60 | 6 | SFM 164 not in [94, 156] |
| rough | 1/8-1/4 | 0.30-0.60 | 3 | SFM 171 not in [94, 156] |

Count by operation: rough 9 (17-4 x3, H13 x2, Titanium x2, High Temp Nickel x1, 1045 x1), side 8, hem 10, slot 1. Total 28. Groups at D <= 1/16 in: 12.

### Failing cells (recommended engagement, 4 of 157)

| Material | Operation | Band | Rows | Failure |
|---|---|---|---|---|
| Stainless - 400 Series (420) | side | 1/8-1/4 | 3 | ae/D 0.200 not in [0.200, 0.625] |
| Steel - Medium Carbon (1045) | rough | 1/32-1/16 | 3 | ae/D 0.172 not in [0.180, 0.625] |
| Steel - Medium Carbon Alloy (4130) | rough | 1/4-1/2 | 3 | ae/D 0.196 not in [0.100, 0.156] |
| Steel - Tool (H13) | rough | 1/32-1/16 | 3 | ae/D 0.080 not in [0.120, 0.188] |

### Interpretation

What the numbers say:

- Slot and side pass well. Rough and micro do not reach the 85 % gate.
- Every rough failure is a speed (SFM) above the vendor range (17-4, H13, High Temp Nickel, Titanium, 1045). Micro failures are mixed: some chip loads below the vendor floor, some speeds outside the range in either direction, and one "no cut" result (316 side, <=1/32 in).
- The conformance test ran at the production default (model v2) and aggressiveness 50 %. The test does not use the planner or the library builder.

What the engine agent wrote in `docs/research/v2_micro_findings.md` (quoted, not checked again here):

> Conclusion: the force and stress model is consistent with Kienzle at tiny chips; I found no cited basis to change K_te, r_β or the core ratio. The remaining micro "no cut" groups (17-4 slots at 1/32" and below, H13 side at ≤0.10 ae/D) are physical at TIR 0.0002" on 0.0146"–0.02" necks.

> Runout: At TIR 0.0002" the wall flute carries a chip of at least 5 µm whatever fz is (reduced-flute regime), so the force has a floor of about 4 N on a 0.031" tool. With TIR ≤ 0.0001" the H13 side group passes (fz 4.7e-5 inside the span).

> Many groups are still limited by the C14v consensus cap (0.92 x the bucket median), not by C7, so the refit moved few conformance groups.

How this run compares with that note:

- The 17-4 slot groups at 1/32 in and below are not in the failing list in this run. The note's explanation for them cannot be checked against this run.
- The H13 failing group in this run is "side, <=1/32, 0.10-0.30" (13 rows), not the "side, <=0.10 ae/D" group named in the note. The note's runout test (TIR 0.0001 in) is the one that matters for it. This run did not repeat that test at 0.0001 in as a gated result.
- The 316 side group "v2 gave no cut (v2: C14m)" is a separate case. The note does not cover it.
- The rough failures for 17-4 and titanium (SFM above the vendor range) are in the same direction as the note's C14v cap statement. The note does not say that the cap causes these specific failures.

## Stability

Command: `TOOLWIZ_MODEL=` (empty), `python -m pytest -q -p no:cacheprovider tests/test_v2_stability.py -rx`.

Result: 114 passed, 6 xfailed, 41 s. The six xfail reasons are in the test table above. Summary:

- Feed non-increasing in runout: 2 xfails, both 4130 adaptive at 1/32 in and 1/16 in. Cause: the radial runout adds directly to the worst-flute chip at ae = 0.15 D.
- Stickout +10 % changes depth by less than 25 %: 4 xfails. Cause: stiffness falls as stickout cubed, so the deflection-limited depth falls by 25-31 %. The 4130 adaptive 1/16 in case becomes infeasible at +10 %.

## T-slot

Command: `python -m pytest -q -p no:cacheprovider tests/test_tslot_conformance.py -s`. Result: 2 passed, 0.08 s.

| Group | Pass rate |
|---|---|
| Overall | 98.9 % (276 of 279 rows) |
| Harvey | 100.0 % |
| Ingersoll | 95.7 % |
| Radial depth | 100.0 % of 137 |

Failing rows (3 of 279), all chip load (fz) below the vendor range:

| Row | SFM | Vendor SFM | fz (in) | Vendor fz (in) |
|---|---|---|---|---|
| ingersoll NEW379 18T-5012TQRN01, h side cut | 330 | 400-600 | 0.00104 | 0.00200-0.00500 |
| ingersoll NEW379 18T-5012TQRN01, Ti side cut | 125 | 65-150 | 0.00087 | 0.00200-0.00400 |
| ingersoll NEW379 18T-6212T6RN01, Ti side cut | 125 | 65-150 | 0.00109 | 0.00200-0.00400 |

The T-slot test covers vendor rows. The shop cutters (Klot/Harfington, Harvey) have no vendor cutting data. Their numbers come from the physics model and the Harvey data, as the implementation plan states.

## Micro sweep

Commands: `TOOLWIZ_MODEL= python scripts/micro_tool_sweep.py` and `TOOLWIZ_MODEL= python scripts/micro_tool_sweep.py --stickout 0.5`. Runout 0.0002 in, aggressiveness 50 %, model v2 (production default). Diameters: 0.010 in, 1/32 in, 1/16 in, 1/8 in, 1/4 in. Only adaptive ("Adaptive Roughing") and slotting rows for 6061 and 4130 are shown.

The sweep prints programmed flutes (`fl`), not the flutes that cut. The "flutes cutting" value (`flutes_cutting`) is not printed, so it is not reported here.

Column meanings: rpm; feed in IPM; chip load per tooth (`adj_ipt`); ap/D (`doc/D`); ae/D (`woc/D`); deflection (in); deflection limit (in); bending stress at the flute root (ksi).

### Stickout 0.5 in (realistic 1/8 in shank gauge length)

**Adaptive Roughing**

| Dia | Material | rpm | Feed | Chip load | ap/D | ae/D | Defl (in) | Limit (in) | Stress (ksi) |
|---|---|---|---|---|---|---|---|---|---|
| 0.010 in | 6061 | 16000 | 2.07 | 0.000065 | 2.00 | 0.10 | 0.000103 | 0.00020 | 18 |
| 1/32 in | 6061 | 16000 | 6.46 | 0.000202 | 2.00 | 0.10 | 0.000221 | 0.00063 | 15 |
| 1/16 in | 6061 | 16000 | 13.74 | 0.000429 | 2.00 | 0.10 | 0.000324 | 0.00125 | 13 |
| 1/8 in | 6061 | 16000 | 30.83 | 0.000963 | 2.00 | 0.10 | 0.000344 | 0.00250 | 13 |
| 1/4 in | 6061 | 16000 | 63.91 | 0.001997 | 2.33 | 0.10 | 0.000383 | 0.00500 | 13 |
| 0.010 in | 4130 | 16000 | 1.74 | 0.000054 | 0.08 | 0.15 | 0.000117 | 0.00020 | 5 |
| 1/32 in | 4130 | 16000 | 8.15 | 0.000170 | 0.09 | 0.15 | 0.000318 | 0.00063 | 7 |
| 1/16 in | 4130 | 16000 | 20.16 | 0.000315 | 0.22 | 0.15 | 0.000672 | 0.00125 | 19 |
| 1/8 in | 4130 | 16000 | 55.45 | 0.000866 | 2.00 | 0.10 | 0.001208 | 0.00250 | 132 |
| 1/4 in | 4130 | 7524 | 35.97 | 0.001195 | 2.00 | 0.15 | 0.001603 | 0.00500 | 121 |

**Slotting**

| Dia | Material | rpm | Feed | Chip load | ap/D | ae/D | Defl (in) | Limit (in) | Stress (ksi) |
|---|---|---|---|---|---|---|---|---|---|
| 0.010 in | 6061 | 16000 | 1.23 | 0.000039 | 0.24 | 1.00 | 0.000117 | 0.00020 | 12 |
| 1/32 in | 6061 | 16000 | 3.86 | 0.000121 | 0.67 | 1.00 | 0.000624 | 0.00063 | 28 |
| 1/16 in | 6061 | 16000 | 8.10 | 0.000253 | 0.50 | 1.00 | 0.000677 | 0.00125 | 18 |
| 1/8 in | 6061 | 16000 | 15.68 | 0.000490 | 1.00 | 1.00 | 0.001072 | 0.00250 | 31 |
| 1/4 in | 6061 | 16000 | 35.38 | 0.001105 | 1.00 | 1.00 | 0.001288 | 0.00500 | 29 |
| 0.010 in | 4130 | 16000 | 1.23 | 0.000039 | 0.08 | 1.00 | 0.000117 | 0.00020 | 22 |
| 1/32 in | 4130 | 16000 | 5.79 | 0.000121 | 0.09 | 1.00 | 0.000315 | 0.00063 | 30 |
| 1/16 in | 4130 | 16000 | 16.19 | 0.000253 | 0.16 | 1.00 | 0.000632 | 0.00125 | 69 |
| 1/8 in | 4130 | 12075 | 23.68 | 0.000490 | 0.35 | 1.00 | 0.001291 | 0.00250 | 122 |
| 1/4 in | 4130 | 5948 | 26.32 | 0.001106 | 0.65 | 1.00 | 0.002854 | 0.00500 | 216 |

### Default stickout (3.5 x D, the script default)

**Adaptive Roughing**

| Dia | Material | rpm | Feed | Chip load | ap/D | ae/D | Defl (in) | Limit (in) | Stress (ksi) |
|---|---|---|---|---|---|---|---|---|---|
| 0.010 in | 6061 | 16000 | 2.07 | 0.000065 | 2.00 | 0.10 | 0.000032 | 0.00020 | 18 |
| 1/32 in | 6061 | 16000 | 6.46 | 0.000202 | 2.00 | 0.10 | 0.000079 | 0.00063 | 15 |
| 1/16 in | 6061 | 16000 | 13.74 | 0.000429 | 2.00 | 0.10 | 0.000141 | 0.00125 | 13 |
| 1/8 in | 6061 | 16000 | 30.83 | 0.000963 | 2.00 | 0.10 | 0.000275 | 0.00250 | 13 |
| 1/4 in | 6061 | 16000 | 63.91 | 0.001997 | 2.33 | 0.10 | 0.000462 | 0.00500 | 13 |
| 0.010 in | 4130 | 16000 | 1.66 | 0.000052 | 0.38 | 0.15 | 0.000113 | 0.00020 | 23 |
| 1/32 in | 4130 | 16000 | 6.15 | 0.000128 | 2.00 | 0.15 | 0.000340 | 0.00063 | 128 |
| 1/16 in | 4130 | 16000 | 20.16 | 0.000315 | 2.00 | 0.15 | 0.000580 | 0.00125 | 171 |
| 1/8 in | 4130 | 16000 | 55.45 | 0.000866 | 2.00 | 0.10 | 0.000940 | 0.00250 | 132 |
| 1/4 in | 4130 | 7524 | 35.97 | 0.001195 | 2.00 | 0.15 | 0.001958 | 0.00500 | 121 |

**Slotting**

| Dia | Material | rpm | Feed | Chip load | ap/D | ae/D | Defl (in) | Limit (in) | Stress (ksi) |
|---|---|---|---|---|---|---|---|---|---|
| 0.010 in | 6061 | 16000 | 1.23 | 0.000039 | 1.00 | 1.00 | 0.000115 | 0.00020 | 51 |
| 1/32 in | 6061 | 16000 | 3.86 | 0.000121 | 1.00 | 1.00 | 0.000283 | 0.00063 | 42 |
| 1/16 in | 6061 | 16000 | 8.10 | 0.000253 | 1.00 | 1.00 | 0.000490 | 0.00125 | 37 |
| 1/8 in | 6061 | 16000 | 15.68 | 0.000490 | 1.00 | 1.00 | 0.000851 | 0.00250 | 31 |
| 1/4 in | 6061 | 16000 | 35.38 | 0.001105 | 1.00 | 1.00 | 0.001556 | 0.00500 | 29 |
| 0.010 in | 4130 | 16000 | 1.23 | 0.000039 | 0.20 | 1.00 | 0.000097 | 0.00020 | 57 |
| 1/32 in | 4130 | 16000 | 5.79 | 0.000121 | 0.20 | 1.00 | 0.000271 | 0.00063 | 71 |
| 1/16 in | 4130 | 16000 | 16.19 | 0.000253 | 0.38 | 1.00 | 0.000630 | 0.00125 | 161 |
| 1/8 in | 4130 | 12075 | 23.68 | 0.000490 | 0.45 | 1.00 | 0.001304 | 0.00250 | 156 |
| 1/4 in | 4130 | 5948 | 26.32 | 0.001106 | 0.56 | 1.00 | 0.003023 | 0.00500 | 187 |

### Reading the sweep

- With the realistic 0.5 in stickout, the adaptive depth for 6061 is 2.0 x D at ae 0.10 D for 1/8 in and below, and the deflection stays under the limit at every size shown.
- In the 0.5 in table, the 4130 adaptive stress at 1/8 in and 1/4 in is 132 and 121 ksi, the highest values in that table. The sweep prints the stress but does not print a stress limit, so the table does not show whether these are acceptable.
- Slotting 4130 at 0.5 in stickout uses 0.08 x D depth at 0.010 in and 0.65 x D at 1/4 in. At the default stickout the depth is larger at 0.010 in through 1/8 in (0.20, 0.20, 0.38, 0.45 x D) and smaller at 1/4 in (0.56 x D).
- The sweep was run at one runout only (0.0002 in). No runout variation was run for this report.

## Strategy planner examples

Command: POST `/api/strategy/compare` through Flask's test client, header `X-ToolWiz-Client: eval`, body model v2, aggressiveness 0.5, runout 0.0002 in. Script: `<scratchpad>/eval/strategy_run.py`; full response in `<scratchpad>/eval/strategy.json`.

Cut-out job: 0.25 in thick, 12 in perimeter, 4 tabs (0.1 in x 0.04 in, 3D style). Candidate tools: 0.125 in 2FL, flute 0.375 in, stickout 0.6 in, shank 0.125 in; and 0.0625 in 2FL, flute 0.1875 in, stickout 0.4 in, shank 0.125 in.

| Material | Option | Tool | Time per part (min) | Wear per part (least-wear = 1.0) | Recommended | Wear confidence |
|---|---|---|---|---|---|---|
| Aluminum - Wrought (6061) | contour_slot | 0.125 in 2FL | 2.28 | 1.00 | **Yes** | low |
| Aluminum - Wrought (6061) | contour_slot_small_tool | 0.0625 in 2FL | 8.88 | 3.93 | No | low |
| Aluminum - Wrought (6061) | adaptive (channel 0.125 in) | 0.0625 in 2FL | 48.08 | 15.36 | No | low |
| Titanium Alloy | contour_slot | 0.125 in 2FL | 25.15 | 1.00 | **Yes** | low |
| Titanium Alloy | contour_slot_small_tool | 0.0625 in 2FL | 52.98 | 1.74 | No | low |
| Titanium Alloy | adaptive (channel 0.125 in) | 0.0625 in 2FL | 111.94 | 3.56 | No | low |
| Stainless - PH Series (17-4) | contour_slot | 0.125 in 2FL | 38.49 | 1.00 | **Yes** | low |
| Stainless - PH Series (17-4) | contour_slot_small_tool | 0.0625 in 2FL | 77.35 | 2.23 | No | low |
| Stainless - PH Series (17-4) | adaptive (channel 0.125 in) | 0.0625 in 2FL | 121.68 | 2.53 | No | low |

Notes from the planner:

- The adaptive option for the 0.125 in tool is skipped in all three materials: "channel 0.1250 in is under 1.25 x D (it would be cut as a slot)".
- For titanium, the recommended 0.125 in contour slot has a holder risk: "needs ultra-class runout (required TIR 0.00009 in); recommended: micro collet chuck (Mega Micro), shrink fit, powRgrip, hydraulic". This applies to the owner's 0.0002 in runout assumption.
- Relative tool life is reported at the cap (10.0) for several options. Only the ratios of wear mean anything.

T-slot job: titanium, slot height 0.0787 in, radial depth 0.030 in, length 2 in. Candidates: every entry in `data/shop_tools.json` (5 cutters, including one planned tool that is not bought).

| Option | Tool | Time per part (min) | Wear per part (least-wear = 1.0) | Recommended | Wear confidence |
|---|---|---|---|---|---|
| tslot | Harvey 867330, 3/8 x 1/16 staggered keyseat (planned, not owned) | 1.24 | 1.00 | **Yes** | low |
| tslot | Klot/Harfington 6 mm x 2 mm, Ti-coated, 4 flute | 1.69 | 1.27 | No | low |
| tslot | Klot/Harfington 8 mm x 1.6 mm (fallback) | 3.80 | 2.86 | No | low |
| tslot | Klot/Harfington 8 mm x 0.5 mm | 9.39 | 7.06 | No | low |
| tslot | Klot/Harfington 4 mm x 0.5 mm | 14.02 | 10.81 | No | low |

Notes from the planner:

- The Harvey cutter is recommended. Its cycle time is 26 % shorter than the fastest owned alternative (6 mm x 2 mm), and its wear is 1.00 against 1.27. The planner's basis for the Harvey data is `tests/benchmarks/tslot/harvey.json`.
- The Harvey cutter is planned, not owned. Its runout risk is printed: "Runout 0.00020" is 60 % of the chip load (0.00033"): one tooth will do most of the cutting. Use a precision holder."
- Four of the five cutters carry the warning "provisional geometry (neck_diameter, reach, tooth_form...)". Their neck and reach values are assumed until measured.
- The 6 mm x 2 mm cutter's risk is a runout warning: "Runout 0.00020" is 68 % of the chip load (0.00029")". The cutters' runout checks use the owner's 0.0002 in assumption.

Wear confidence for every response is "low". The reason given is the same for all: `material.taylor_n = 0.25` is a literature placeholder (one Ti-6Al-4V paper) and no measured tool lives are logged for any family. The planner's wear ratios are therefore not used as a basis for choosing between options on their own. The planner's own reasoning says: "Because the wear estimate is low-confidence, weigh the time difference above more than the wear ratio."

## Master library build

Command: `POST /api/twin/build_sets` with the shop library `data/shop_library/Offworldgear_TI_Steel1_Updated4_20261019_125408_v6.json` sent as `libraries`, both default material sets (`non_ferrous`, `steels_exotics`), aggressiveness 50, model v2, runout 0.0002 in. Polled with `GET /api/twin/build_sets/<id>`. Script: `<scratchpad>/eval/build_run.py`; status in `<scratchpad>/eval/build_status.json`.

Time: 41.6 s from job start to done (limit 20 min; not exceeded).

Tools: 23 in the source library; 1 duplicate merged (a 1/16 in flat end mill, 25 presets); 22 tools out; 1 holder entry; 7 tools repaired by the merge (for example OAL populated for a 2 in face mill, and a 1/16 micro-tool shaft diameter corrected from 0.0625 to 0.125 in).

| Set | Materials | Tools | Presets (all) | ToolWiz presets | Skipped | Dropped | ToolWiz STOP | CAUTION | INFO |
|---|---|---|---|---|---|---|---|---|---|
| ToolWiz - Non-ferrous | 6061-T6, 7075-T6, Brass C36000, Phosphor Bronze C54400, Ni-Al Bronze C63000, Copper C11000 | 22 | 599 | 280 | 36 | 0 | **0** | 108 | 22 |
| ToolWiz - Steels & exotics | 4140 pre-hard 30 HRC, 304, 316, 17-4 PH, Ti-6Al-4V, Zr 702, tool steel 54 HRC, MagnaCut annealed, MagnaCut 62 HRC, Black Ti 5545 | 22 | 775 | 456 | 64 | 0 | **0** | 64 | 22 |

The owner-preset STOP list is empty in both sets (`owner_preset_stop_findings`: []). The "previous ToolWiz presets replaced" count was 0, because this was the first build.

Skipped presets, most frequent reasons (top six per set; the full list is in the status file):

| Reason | Non-ferrous | Steels & exotics |
|---|---|---|
| Infeasible strategy: Slotting, no safe cut (limited by deflection) | 8 | 24 |
| Infeasible strategy: Adaptive Roughing, no safe cut (limited by deflection) | 6 | 10 |
| Infeasible strategy: Roughing, no safe cut (limited by deflection) | 6 | 10 |
| Infeasible strategy: Finishing, no safe cut (limited by deflection, ...) | 4 | 10 |
| Lollipop tool: end-mill strategies do not apply, no form-tool strategy | 3 | 3 |
| Axial-step preset not written: cutting faces unknown | 3 | 3 |

Other skips in the list: the 2 in face mill (Adaptive Roughing and Slotting do not apply to a face mill). The chamfer tool (number 6) has no preset written.

Caution codes in the audit:

| Code | Non-ferrous | Steels & exotics |
|---|---|---|
| duplicate_preset | 94 | 47 |
| er_holder | 5 | 8 |
| long_stickout | 9 | 9 |

## Known gaps and what would close them

Each item is taken from the docs named. Items marked "not run" were outside this evaluation.

| Gap | Evidence | What would close it (from the docs) |
|---|---|---|
| Rough fixed-engagement pass rate 80.9 % (gate 85 %) | Conformance, xfail | Rework the rough groups above; the failing groups are listed. Not addressed in this report. |
| Micro (D <= 1/16 in) pass rate 79.7 % (gate 85 %) | Conformance, xfail | Measured runout (see next row). The engine note in `docs/research/v2_micro_findings.md` says that at TIR 0.0001 in the H13 side group passes. This run did not test the other micro failures at 0.0001 in. |
| Runout is assumed, not measured | `docs/OPEN_ITEMS.md`: "A measured TIR (Blum) moves every micro result." `docs/SHOP_LIBRARY_AUDIT.md`: "Measure runout and record it (`toolwiz.runout_in`) on each tool." | Measure TIR on each tool and record it. The planner and library use the recorded value. |
| Wear estimate is low confidence | Every planner response: "Wear confidence: low", taylor_n 0.25 placeholder | Log tool lives at `POST /api/toollife` (at least 3 records per family for a measured life; at least 5 with a speed spread for the exponent). `docs/STRATEGY_PLANNER.md`. |
| Shop T-slot cutters have provisional geometry (neck, reach, tooth form) | Planner warnings for 4 of 5 cutters | Measure neck diameter, reach and tooth form. The owner's note in `docs/V3_IMPLEMENTATION_PLAN.md` says the same. |
| Harvey 3/8 x 1/16 cutter is not owned | Planner: "planned tool (not owned yet)" | Buy and test it. The planner's T-slot recommendation depends on Harvey vendor data, not on a test of this tool. |
| Klot 4 mm x 0.5 mm has no source listing | `data/shop_tools.json` source note | Find a listing or measure. Its geometry other than diameter and kerf is assumed. |
| Stability xfails (6) | `test_v2_stability.py` | The reasons are physical (see the stability section). The docs do not state a closing change for these cases. |
| Micro sweep does not print flutes cutting or the runout regime | Sweep output columns | Add those columns to the sweep script (not done in this evaluation). |
| Library skips (36 and 64 presets) | Build result | Add form-tool strategies for lollipop and face mills, or accept the skips. |
| Not evaluated here | Add-in commands, web UI, LLM advisor and MCP tools, holder and tool advice endpoints | Run their own tests and a manual check. The full suite includes the add-in and web tests; they passed, but this report did not exercise them by hand. |

## How to reproduce

Run from the repository root (`/home/user/wt/d-eval` for this report). Use `TOOLWIZ_MODEL=` (empty) so the production default (v2) applies.

```bash
export TOOLWIZ_MODEL=

# 1. Full suite (about 8 min on a loaded 4-core host)
python -m pytest -q -p no:cacheprovider -rx

# 2. Vendor conformance (about 6 min); dump file optional
TOOLWIZ_CONFORMANCE_DUMP=/path/to/conf.json python -m pytest -q -p no:cacheprovider tests/test_vendor_conformance.py -rx -s

# 3. Stability
python -m pytest -q -p no:cacheprovider tests/test_v2_stability.py -rx

# 4. T-slot conformance
python -m pytest -q -p no:cacheprovider tests/test_tslot_conformance.py -s

# 5. Micro sweeps
python scripts/micro_tool_sweep.py
python scripts/micro_tool_sweep.py --stickout 0.5

# 6. Strategy planner: POST /api/strategy/compare through the Flask test client
#    (body and candidate tools as in the "Strategy planner examples" section;
#     header X-ToolWiz-Client: eval; model "v2"; aggressiveness 0.5; runout 0.0002)

# 7. Master library build
#    POST /api/twin/build_sets with
#      {"libraries": [<contents of data/shop_library/Offworldgear_TI_Steel1_Updated4_20261019_125408_v6.json>],
#       "aggressiveness": 50, "model": "v2"}
#    then GET /api/twin/build_sets/<job_id> until state is "done" or "error".
```

Output files from this run (in the scratchpad, not in the repository): `full_suite.txt`, `conf.txt`, `conf.json`, `stab.txt`, `tslot.txt`, `sweep_v3_stick_default.txt`, `sweep_v3_stick05.txt`, `eval/strategy.json`, `eval/build_status.json`.
