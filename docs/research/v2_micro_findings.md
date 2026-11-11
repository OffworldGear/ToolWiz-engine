# v2 micro-tool findings (V3 round 4)

Question: why does v2 return "no cut" for vendor-median micro slots (17-4, H13, Ti at 1/32" and below)? Is the force or stress
prediction too high at tiny chips?

## What was checked
| Item | Finding | Change |
|---|---|---|
| Binding checks | At the group's median engagement the failures were C3 (deflection beyond 2·k·D) and, for H13, C4 (σ1 2,100 MPa against 1,340). C5 was not binding after the conformance spindle was made ample. | none |
| Force against a sanity estimate | 17-4 slot, D 0.031", ap 0.0087", vendor fz 7.5e-5": the model's mean lateral force is 2.4 N, a per-flute kc·h·b estimate with kc1.1 1800, mc 0.21, tool factor 0.79 and the hardness law is 2.7 N. The force model agrees with Kienzle. | none |
| Kienzle extrapolation below 5 µm | kc ∝ h^(−mc) continues below the table range. docs: measured kc keeps rising below the edge radius (calibration_report.json "thin_chip": de Oliveira 2015, Soriano Gonzalez 2023), so an upward extrapolation is the supported direction. | none |
| K_te / K_re | 0 by calibration: Sandvik's kc1 is fitted to total force, so an edge term double-counts (materials.json force.k_te_n_mm source). | none |
| r_β = 2 µm flat | docs/research/carbide_and_edge_radius.md §3: "No source gives r_beta as a function of diameter"; measured micro-tool values (0.41–3.5 µm) conflict. Scaling it with D would be invented. r_β only sets the C1 minimum chip, which was not the forbidding check. | none |
| C4 section | Default is the fluted section (same I as C3), outer fibre at D/2; the critical section on a necked tool is the neck. The 2,100 MPa is the neck: a 0.0146" neck 3 mm long under about 4 N. | none |
| Load centroid | 0.25 mm up the flute for ap 0.5 mm, i.e. mid-depth as expected for a helical band. | none |
| Runout | At TIR 0.0002" the wall flute carries a chip of at least 5 µm whatever fz is (reduced-flute regime), so the force has a floor of about 4 N on a 0.031" tool. With TIR ≤ 0.0001" the H13 side group passes (fz 4.7e-5 inside the span). | none (planner fixed TIR 0.0002") |
| Test geometry | The cause that mattered was how the group's median tool was built: the neck diameter was the median of the published neck diameters (0.0146", from 0.015" tools) put on the median D 0.031", and the reach was the median of LB over only the rows that publish one. | tests/test_vendor_conformance.py: reach is the median of each row's own stickout (LB, else LCF + 0.5 x SFDM); necked only if most rows reach beyond the flutes; neck = median neck/D x median D. |

Conclusion: the force and stress model is consistent with Kienzle at tiny chips; I found no cited basis to change K_te, r_β or the core ratio. The remaining micro "no cut" groups (17-4 slots at 1/32" and below, H13 side at ≤0.10 ae/D) are physical at TIR 0.0002" on 0.0146"–0.02" necks.

## Speed law (item 2): per-family refit, tools/fit_speed_by_family.py
The calibrated C7 law has one engagement exponent k and one diameter exponent m for every material. The tool refits level, k and m per family to the rows' own SFM (L1, IRLS, ridge pull toward the global values) on the training groups of calibrate_v2.holdout and reports the hold-out groups, which it never sees. A family's refit is applied only if its hold-out median |log error| falls and its within-25% rate does not fall by more than 2 points. Median |ln(pred/vendor)| / share within ±25%:

| Family | train before | train after | hold-out before | hold-out after | applied |
|---|---|---|---|---|---|
| 17-4 PH | 0.293 / 40% | 0.232 / 55% | 0.330 / 38% | 0.332 / 40% | no |
| 420 | 0.138 / 100% | 0.102 / 81% | 0.348 / 50% | 0.264 / 50% | yes |
| 316 | 0.177 / 70% | 0.153 / 68% | 0.192 / 67% | 0.205 / 65% | no |
| 1020 | 0.332 / 44% | 0.301 / 44% | 1.158 / 0% | 1.128 / 0% | yes (hold-out still poor: rows publish only "≤28 HRC") |
| 1045 | 0.209 / 60% | 0.098 / 61% | 0.209 / 58% | 0.074 / 58% | yes |
| 4130 | 0.299 / 47% | 0.191 / 53% | 0.250 / 56% | 0.190 / 78% | yes |
| H13 | 0.473 / 25% | 0.362 / 33% | 0.857 / 28% | 0.974 / 16% | no (overfits) |
| 6061 | 0.659 / 18% | 0.504 / 12% | no hold-out rows | | no |
| Nickel | 0.359 / 38% | 0.213 / 53% | 0.309 / 45% | 0.301 / 38% | no |
| Ti | 0.225 / 52% | 0.191 / 64% | 0.256 / 58% | 0.212 / 60% | yes |

Many groups are still limited by the C14v consensus cap (0.92 x the bucket median), not by C7, so the refit moved few conformance groups.
