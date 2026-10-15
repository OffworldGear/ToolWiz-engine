# v2 data step: what was found and what is missing

_Research, 2026-10-15. Design step 1 of §6 in `docs/PHYSICS_MODEL_DESIGN.md`. The v1 engine is unchanged._

## Files

| What | Where |
|---|---|
| Benchmark row schema | `tests/benchmarks/v2/SCHEMA.md` |
| Benchmark rows | `tests/benchmarks/v2/{harvey,helical,osg,sandvik,kennametal}.json` |
| Row validator (runs with the full suite) | `tests/test_v2_benchmark_dataset.py` |
| Coverage report | `python tools\v2_coverage.py` |
| Kienzle kc1.1 / mc survey (Sandvik plus four second sources) | `kc_mc_survey.md`, `data/kc_mc_sources.json` |
| GWizard family → Sandvik MC mapping (proposal) | `material_mapping_v2.md` |
| Carbide E, TRS, fatigue, edge radius, λ, core ratio | `carbide_and_edge_radius.md`, `data/carbide_edge_sources.json` |
| Corrected earlier Harvey comparison | `harvey_micro_data.md` |

## 1. Benchmark dataset

### Rows

578 rows from 4 independent vendor groups, all square end mills:

| File | Rows | Main documents |
|---|---|---|
| harvey.json | 165 | SF_73000, SF_72000, SF_47800, SF_34600 (generic miniature charts); SF_875400 (variable helix, high-temp alloys, names 17-4 and 17-7); SF_958500 (variable helix, medium alloy, 316) |
| helical.json | 124 | HEV-5, HSV-4, HEV-6, HVTI-6, H45AL-3 speeds & feeds sheets |
| osg.json | 123 | AE-VMS 8200/8205/8225, AE-VMSS 8206, AE-VTSS 8233/8333, EXOCARB WXL 3604, MAX-HARD 9140, WXL-4D-DE 3723, AERO 2022/8120 technical pages |
| sandvik.json | 74 | CoroMill Plura HD (2P342) and CoroMill Dura cutting-data sheets |
| kennametal.json | 92 | HARVI I TE, HARVI III, GOmill GP product-page tables |

- **Citations:** every row quotes the published cells and carries the part number and the catalog geometry (DC, LCF, shank, OAL, and neck where published).
- **Derived rows:** 46 rows apply a vendor's own printed rule, flagged in `source.derivation`. They are Kennametal slot rows (side IPT × 0.8), Kennametal HEM rows (its Ae/D adjustment factors) and Sandvik's +20% fz for its short tool.
- **Harvey and Helical** are one vendor group (Harvey Performance) when counting independent sources.

### Coverage

The design's target is 8 materials × 7 diameters × 4 operations = 224 cells, each with two independent vendor groups.

- **Well covered:** 77 cells have two or more groups. Slot and side/rough at 1/8–1/2" are well covered for 17-4 PH, 316, 1018/1045 and 4140 (3–4 groups each).
- **17-4 PH at 1/64–1/16":** two groups, Harvey and OSG. OSG's 0.4 and 0.8 mm rows come from a lumped "stainless" column (low confidence).

**Gaps:**

| Gap | Detail |
|---|---|
| HEM / adaptive | Almost empty. Published HEM rows come only from Helical HVTI-6 (Ti, Inconel), Sandvik Dura's light-engagement columns, and Kennametal (derived). Harvey and OSG publish no HEM table for these tools. HEM calibration will have to rely on the side-milling rows at small ae plus the HEM Guidebook envelope. |
| Micro (1/64–1/32") | Steels and stainless only (Harvey, OSG 3723, Kennametal GOmill GP). Nothing for Ti, H13 or Inconel. Sandvik starts at 1–2 mm and Kennametal HARVI at 1/8". |
| H13 at 45–50 HRC | 1/4" and 1/2" (OSG 3604/9140, Helical 36–50 HRC, Kennametal H1 44–48 HRC). No micro sizes. |
| Ti-6Al-4V, Inconel 718 | 1/4" and 1/2" only, no 1". |
| 1" | Only OSG, Helical (17-4), Kennametal, Sandvik (25 mm). |
| Long reach / necked tools | Only Helical reduced-neck rows and Harvey SF_34600 (8× reach). OSG long-neck pages (AE-VML, AE-ML, AE-CPR4-H) were not found as technical pages. The C9 chatter rule (OSG overhang) is unchanged. |
| Side milling vs roughing | Harvey and Helical print "Roughing" (a deep, narrow side cut), not a side-milling column. The coverage report merges side and rough. |

### Classification notes

- OSG's "High Speed Light Milling" rows (ae = 0.01–0.10 D at about 1,200 SFM) are filed as `finish`. Physically they are a thin-chip, high-speed regime; the calibration step should treat them as such.
- Sandvik has no explicit 17-4 PH group. Its ferritic/martensitic rows (P5.0.Z.AN, 200 HB) are filed under the 420 family.

### Corrections made during review

- **Harvey SF_73000 depth of cut.** Each row has two depth-of-cut pairs. The first belongs to 0.015–0.047" tools and the second to 0.062–0.500" tools, as the rendered page shows. Roughing at 1/16" and 3/32" is 3D × **0.25D**. `harvey_micro_data.md` had recorded 0.13D; it is corrected.
- **Scrambled text layers.** pdftotext scrambles the Sandvik Plura HD, CERATIZIT and OSG tables, which makes the text alone unreliable. The reviewer checked rows against rendered pages:
  - Plura HD: M1.0.Z.AQ, D04 = 0.049 mm at 12.7 mm.
  - OSG AE-VMS: the PH column at 1/4", 4580 rpm / 21.4 IPM side and 4050 / 17.9 slot.
  - CERATIZIT: the property table.
  
  All matched the agents' rows.

## 2. What the data already says about v1 and about the physics

### Harvey's generic charts are the conservative outlier

SF_73000 and SF_72000 cover dozens of alloys in one row. For 17-4 PH they sit at about 1/3 of every other source, including Harvey's own material-specific sheet SF_875400 (17-4 PH chip loads in in/tooth):

| D | Harvey generic (73000, 29–37 HRC) | Harvey SF_875400 | Helical HEV-5 | OSG | Kennametal |
|---|---|---|---|---|---|
| 1/16" | 0.00010 | 0.00026 | 0.00040 | 0.00040 | — |
| 1/8" | 0.00019 | 0.00053 | 0.00070 | 0.00048–0.00090 | 0.00070 |
| 1/4" | 0.00039 | 0.00105 | 0.00130 | 0.00117–0.0023 | 0.00140 |

**Consequence for the design (§1):** the "v1 is 2–7× Harvey's feeds" finding used the generic charts. Against the material-specific data v1's **chip load is roughly in line**. The real differences are speed and depth.

v1 for 17-4 PH H1025 (356 HB, about 38 HRC), AlTiN, Standard Roughing, aggressiveness 50, 4 flutes, no rpm cap:

| D | v1 SFM | Vendor SFM, 35–43 HRC | v1 fz | Vendor fz (material-specific) | v1 ap × ae | Vendor ap × ae |
|---|---|---|---|---|---|---|
| 1/16" | 329 | 100–200 | 0.00038 | 0.00026–0.00040 | 0.10D × 0.5D | 0.6–3D × 0.2–0.4D |
| 1/8" | 317 | 90–265 | 0.00065 | 0.0005–0.0009 | 0.08D × 0.5D | 0.6–2D × 0.15–0.5D |
| 1/4" | 344 | 80–300 | 0.0009 | 0.0011–0.0023 | 0.09D × 0.5D | 1–2D × 0.1–0.5D |
| 1/2" | 344 | 100–265 | 0.0018 | 0.0019–0.0045 | 0.16D × 0.5D | 0.6–2.5D × 0.1–0.5D |

- **SFM:** v1 is about 1.5–3× high at this hardness.
- **Depth:** v1 is 10–20× shallower than every vendor, at a wider ae.
- **Chip load:** within or just below the vendor range.

This supports the v2 direction, a deep and narrow cut from the force, deflection and stress limits. The target is now SFM and the ap/ae split, not a lower chip load.

### Chip thinning alone does not reconcile the vendors

Converting fz to h_max (§3.1) narrows the spread only a little (17-4 at 1/4": 12× → 10× with the generic charts, about 2× without). Each vendor trades depth against chip load:
- OSG's 3-flute AE-VTSS at ap = 1D runs fz 0.0020.
- OSG's 4-flute AE-VMS at ap = 1.5D runs 0.00117.

That is the force/deflection trade the v2 model is meant to explain. The calibration test is whether one force-plus-deflection limit reproduces both rows.

## 3. Material force data (kc1.1, mc)

- **Sandvik Coromant** publishes kc1 / mc / nominal HB for 96 MC groups (82 with kc1, 76 with mc). Eight values were re-verified on the live page.
- **17-4 PH:** Sandvik's **P5.0.Z.PH** (ferritic/martensitic PH, 330 HB, kc1 = 2800 N/mm², mc = 0.21). Sandvik files martensitic and PH stainless under ISO **P**, not M.
- **Second sources:** Walter, Seco/Niagara, the Europa and Westermann textbooks. Medians vs Sandvik:
  - Walter 1.00. It is identical to Sandvik for N, S and H, so not independent there.
  - Seco 0.97, the best independent check.
  - Europa about 1.0. It is on a +6° rake basis.
  - Westermann 1.26.
- **Kennametal:** publishes no kc table.
- **Rake correction:** Sandvik's formula gives 1% per degree of rake from 0°.
- **Not published anywhere surveyed:** a hardness correction for kc1. The mapping doc proposes using each condition's own Sandvik row and fitting a per-class exponent in the calibration step. The implied exponents from Sandvik's own rows range from 0.26 to 0.88.
- **Gaps:**
  - No kc1 for magnesium, high-strength bronze, tungsten, ADI or sintered steel.
  - No mc for titanium alloys (S4.2–S4.4).

## 4. Carbide and cutting edge

| Quantity | Value for v2 | Basis |
|---|---|---|
| E (WC-Co, 6–12% Co) | 550–625 GPa; 570 GPa at 10% Co | CERATIZIT p-line table (10 grades) |
| TRS | 3.6–4.0 GPa (ISO 3327 bars, 6–12% Co) | CERATIZIT, Mitsubishi, Hyperion. Test geometry matters: about 20% spread between bar and cylinder specimens. |
| Fatigue / TRS | 0.53–0.55 at R = 0, 10⁷ cycles (fine WC, 10–15% Co); 0.33–0.42 for fully reversed (R = −1) | Sakagami et al. 2007 (open access); Preis 2004 thesis review. An end-mill flute root sees close to R = −1 per revolution in side milling, so **use about 0.35–0.4 × TRS** for C4. |
| Edge radius r_β, micro | about 0.4 µm uncoated at D = 0.5 mm; 0.9–1.5 µm coated (AlCrN, AlTiN, TiN); 3.5 µm uncoated at D = 1 mm | Liang et al. 2018; Jäckel et al. 2024. Only two studies, about 8× apart. |
| Edge radius, macro end mills | **missing** | Insert data (5–40 µm) doesn't transfer. |
| λ = h_min / r_β | 0.2–0.4 for steel, Al, Cu, brass and 304 stainless; 0.25–0.5 for Ti-6Al-4V; 0.66–0.8 for hardened steel | Wojciechowski 2022 review; Li 2021; Ducobu 2017. λ falls as r_β grows (0.43 at 1 µm to 0.28 at 7 µm). |
| Core diameter / D | about 0.6 for 2–3 flutes; 0.58–0.65 for 4 flutes; 0.61–0.64 for 5 flutes | Patents (design targets) and Mitsubishi's "usually about 60%". None measured, none for micro tools. |

**Check of C1 on the user's tools.** Take 17-4 at 1/16", coated r_β ≈ 1.5 µm and λ ≈ 0.35. Then h_min ≈ 0.5 µm ≈ 0.00002", far below every vendor chip load (0.0001–0.0004"). The 0.0002" runout default is about the size of those chip loads. So at 1/16" the binding limits are runout (worst flute) and tooth strength (C2), not ploughing. C1 matters mainly below 1/32" and for uncoated tools.

## 5. Missing, and what to do about it

| Missing | Effect | Suggestion |
|---|---|---|
| Published HEM tables for micro tools | HEM calibration rests on derived rows and side-milling rows | Use Harvey/Helical HEM Guidebook bounds as validation only |
| Ti / H13 / Inconel below 1/8" | Hard-material micro behaviour is unvalidated | Treat as extrapolation; flag in provenance |
| r_β vs diameter for coated end mills | C1 uncertain for 1/32–1/8" | Measure on the Blum or a microscope, or keep C1 non-binding above 1/32" |
| kc1 hardness correction | Hardness scaling of force is a fit, not sourced | Fit per ISO class from Sandvik's condition rows (calibration step) |
| Kennametal kc table | No third independent kc source | Seco is the independent check |
| Spindle torque curve check | The 16k curve is user-supplied | Confirm against Brother's chart (OPEN_ITEMS) |

## 6. Decisions needed from the user (before calibration)

1. **17-4 Condition A** → P5.0.Z.HT (2300) or P5.0.Z.PH (2800)? See `material_mapping_v2.md`.
2. **Harvey's generic charts (SF_73000/72000):** keep as validation rows, or mark them "conservative generic" and fit to the material-specific sheets? Recommendation: keep them but weight the material-specific rows, because the generic charts cover dozens of alloys at one value.
3. ~~**C5 rating**~~ **Decided 2026-10-15:** the continuous rating for sustained cuts.
