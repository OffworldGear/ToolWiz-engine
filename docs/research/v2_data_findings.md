# v2 data step: what was found and what is missing

_Research, 2026-10-15; dataset extended 2026-10-16 (§1). Design step 1 of §6 in `docs/PHYSICS_MODEL_DESIGN.md`. The v1 engine is unchanged._

## Files

| What | Where |
|---|---|
| Benchmark row schema | `tests/benchmarks/v2/SCHEMA.md` |
| Benchmark rows | `tests/benchmarks/v2/{harvey,helical,osg,sandvik,seco,kennametal,emuge,garr,kyocera_sgs,yg1}.json` |
| Row validator (runs with the full suite) | `tests/test_v2_benchmark_dataset.py` |
| Coverage report | `python tools\v2_coverage.py` |
| Kienzle kc1.1 / mc survey (Sandvik plus four second sources) | `kc_mc_survey.md`, `data/kc_mc_sources.json` |
| GWizard family → Sandvik MC mapping (proposal) | `material_mapping_v2.md` |
| Carbide E, TRS, fatigue, edge radius, λ, core ratio | `carbide_and_edge_radius.md`, `data/carbide_edge_sources.json` |
| Corrected earlier Harvey comparison | `harvey_micro_data.md` |

## 1. Benchmark dataset

_Updated 2026-10-16 (data step 2, branch `toolwiz/v2-data2`): 2,277 rows added from five new vendor files and new documents for the five existing vendors. No existing row was changed._

### Rows

2,855 rows from 9 independent vendor groups. Most are square end mills; the exceptions are listed under "Classification notes".

| File | Vendor group | Rows (was) | Main documents |
|---|---|---|---|
| harvey.json | Harvey Performance | 741 (165) | Generic miniature charts SF_73000, SF_72000, SF_47800, SF_34600. Material-specific sheets: SF_875400 and SF_958500; **new:** hardened steels 45–68 Rc (7-flute and 5-flute), variable-helix high-temp alloys (regular, plus 3×, 5×, 8×, 12× and 15× long reach), titanium SF_711700 (HEM column) |
| helical.json | Harvey Performance | 232 (124) | HEV-5, HSV-4, HEV-6, HVTI-6, H45AL-3. **New:** Machining Guidebook (2016) p.25 HEM case studies; HEM sheets HVSS-6, HVAL-5, HVNI-6/8, more HVTI-6 cells, HVTI-RN-6 reduced neck; HEV-7 |
| osg.json | OSG | 392 (123) | AE-VMS, AE-VMSS, AE-VTSS, EXOCARB WXL, MAX-HARD, WXL-4D-DE, AERO. **New:** HY-PRO CARB VGM5/VGM5-LN/VGM7, VGX VG441, HP441, AE-VML, AE-MS-H, AE-ML-H, Standard 404, UVX-Ti and AE-VTS-N reduced neck |
| sandvik.json | Sandvik | 168 (74) | Plura HD and Dura cutting-data sheets. **New:** Dura 1K354/1K365 dynamic-milling columns at 2, 3, 6, 12 and 20 mm; Dura 1–2×D light radial; more Plura HD side/slot cells; geometry from Sandvik's product-data API |
| seco.json **(new)** | Sandvik | 177 | Seco Solid End Mills catalog 2023.2: Jabro JS554/JS754/JS720 "Advanced roughing" (dynamic milling), JHP770/780, JHP170 hardened, JME542/JME142 micro (necked) |
| kennametal.json | Kennametal | 293 (92) | HARVI I TE, HARVI III, GOmill GP. **New:** more HARVI I TE inch and metric (necked), HARVI II TE, HARVI IV, GOmill PRO, KenCut MM micro 0.4–1.5 mm, Innovations 2020 case studies |
| emuge.json **(new)** | Emuge-Franken | 288 | TiNox-Cut brochure (Trochoidal 2577/2579/2581TZ, TiNox-Cut N) and TOP-Cut VAR brochure (standard, long and extra-long) |
| garr.json **(new)** | Garr Tool | 240 | Milling guides for X3, X5, X7, V5, VRX-6 and VRX ("Profile/Trochoidal" columns) |
| kyocera_sgs.json **(new)** | Kyocera | 248 | Global Catalog v26.1 (H-Carb 77, T-Carb 51, Z-Carb-HPR, -XPR, -AP), Micro Tools Catalog v26.1 (derived via its feed multipliers), Z-Carb-XPR brochure case study |
| yg1.json **(new)** | YG-1 | 76 | TitaNox-Power (HHK82 trochoidal, EMI42 peel milling) and Alu-Power HPC (JAG95) catalogs |

- **Citations:** every row quotes the published cells and carries a real part number with catalog geometry. The exception is the four Helical Guidebook case-study rows, where the guidebook names only series and diameter, so part number and LOC are null and listed in `missing`.
- **Rendered-page checks:** every lookup checked its tables against rendered pages. The reviewer re-checked these against renders:
  - Helical: HVSS-6, HVNI-6 and Guidebook p.25.
  - Harvey: SF_711700, SF_749800 and SF_985400.
  - OSG: VGM5 p.1389.
  - Sandvik: Dura p.A2.
  - Kennametal: Innovations p.20 and p.22.
  - Seco: catalog p.99.
  - Emuge: TiNox p.16.
  - Kyocera SGS: Global Catalog p.96.
- **Derived rows:** 203 (was 46) apply a vendor's own printed rule, flagged in `source.derivation`:
  - Kennametal Ae/D factors and slot × 0.8.
  - Sandvik +20% fz.
  - OSG VGM5-LN L/D 6 reduction.
  - Seco LV3/LV5 reach rules and JME142 recalculation.
  - Kyocera SGS micro feed multipliers and the Z-Carb-AP 1/64" footnote.
- **Long reach / necked:** 559 rows carry LB.
  - **Neck diameter is published** by Sandvik, Seco, Kennametal, OSG VGM5-LN/UVX-Ti/AE-VTS-N and Helical RN.
  - **Neck diameter is not published** by Harvey: its long-reach rows have LB (the printed overall reach) but `neck_diameter` is null.
  - Harvey publishes one sheet per reach multiple instead of a reduction factor.
- **Vendor groups:** Seco is owned by Sandvik, so `seco.json` uses vendor_group "Sandvik" and adds no independent vendor to a cell. Harvey and Helical remain one group.

### Coverage

Target: 8 materials × 7 diameters × 4 operations = 224 cells, each with two independent vendor groups.

**Cells with two or more groups: 149 of 224 (was 77).**

| Operation | Was | Now |
|---|---|---|
| slot | 31 | 51 |
| side/rough | 34 | 51 |
| hem | 2 | 27 |
| finish | 10 | 20 |

HEM cells (number of independent vendor groups, old→new):

| Material | 1/64 | 1/32 | 1/16 | 1/8 | 1/4 | 1/2 | 1 |
|---|---|---|---|---|---|---|---|
| 6061 | 0 | 0 | 0 | 0→2 | 0→3 | 0→3 | 0→1 |
| 1018/1045 | 0 | 0 | 0 | 0 | 0→2 | 0→2 | 0→1 |
| 4140 | 0 | 0→1 | 0→1 | 0→4 | 1→4 | 1→4 | 0→3 |
| 17-4 PH | 0 | 0→1 | 0→1 | 0→5 | 1→7 | 1→7 | 0→4 |
| 316 | 0 | 0→1 | 0→1 | 0→7 | 2→8 | 2→8 | 0→6 |
| Ti-6Al-4V | 0 | 0→1 | 0→2 | 0→6 | 1→7 | 1→7 | 0→5 |
| H13 45-50 | 0 | 0 | 0 | 0 | 0→1 | 0→1 | 0 |
| Inconel 718 | 0 | 0→1 | 0→2 | 0→6 | 1→7 | 0→8 | 0→5 |

- **Slot and side/rough** now have at least 2 groups for every target material from 1/16" to 1" except 6061 at 1/16". Ti, H13 and Inconel now reach down to 1/64" with 2–4 groups (Harvey, OSG, Kennametal KenCut MM, Seco JME542, Kyocera SGS micro).
- **HEM strength of evidence.** 573 HEM rows in all:

| Basis | Rows | Sources |
|---|---|---|
| Labelled HEM, dynamic or trochoidal by the vendor | 341 | Helical, Harvey SF_711700, Sandvik Dura A2 ("Dynamic milling / Small engagements"), Seco "Advanced roughing", Emuge Trochoidal, Garr "Profile/Trochoidal", YG-1 HHK82, Kennametal and Helical case studies |
| Labelled otherwise, filed as `hem` on engagement plus product description | 191 | Kyocera SGS "HSM" (108); OSG VGM "Side Milling" (51, product sold "for Dynamic Milling"); YG-1 peel milling and "HSM (Light)" (20); Helical HVNI (12; the column header prints "Slot" but the legend defines only HEM/Rgh/Fin) |
| Derived by a vendor rule | 37 | Kennametal Ae/D factors, OSG VGM5-LN L/D 6, Seco |
| Light-radial rows already in the file but not labelled HEM | 4 | Sandvik Dura A1 `sv_Dura_p1_*` |

  Each inferred row says so in `notes`. Counting only vendor-labelled HEM rows, 23 HEM cells still have two or more groups. 17-4 PH and 316 at 1/4–1/2" have 5 groups each.

### Classification notes

- OSG's "High Speed Light Milling" rows (ae = 0.01–0.10 D at about 1,200 SFM) are filed as `finish`. Physically they are a thin-chip, high-speed regime; the calibration step should treat them as such.
- Sandvik has no explicit 17-4 PH group. Its ferritic/martensitic rows (P5.0.Z.AN, 200 HB) are filed under the 420 family. Seco's SMG P12 (reference X5CrNiCuNb16-4) and H12 (aged PH, 1200–1650 N/mm²) are filed as 17-4.
- **Not square end:**
  - Helical HVSS-6 and HVNI-6/8 exist only with a corner radius (R.010–.030); they are `end: "corner_radius"`. They are the only Helical HEM data for 316, 17-4 and Inconel.
  - Sandvik 1K354 at 2 and 3 mm has R0.2.
  - Kyocera SGS Z-Carb-AP at 1/64" and 1/8" is a corner-radius part.
  - Filter on `tool.end` for square-only work.
- **Helical HEV-7** is filed as `rough`. Its sheet prints "Rgh (Traditional Roughing)", ADOC up to max LOC and RDOC 10–15%.
- **Case studies, not charts:** Helical Guidebook p.25, Kennametal Innovations 2020 and the Kyocera SGS XPR brochure each give one shop cut with its outcome. The Guidebook's 1/2" HEV-5 in 17-4 at 36 HRC runs at 785 SFM (6,000 rpm, 80 IPM, RDOC .062, ADOC .500). That is about 4× Helical's own chart SFM for PH stainless, so the calibration step should weight it as one shop result.
- **Hardness:**
  - Harvey's "45–55 Rc" and Emuge's H1.1 "44–50 HRC" (example Weldox 1100) are filed under H13 by hardness. Harvey's cell also lists titanium and nickel alloys. Seco H8 spans 38–64 HRC.
  - Garr (">40 HRC", no upper bound), Kyocera SGS (≤ 40 HRC) and YG-1 (no hardness) H13 rows do not count toward the 45–50 HRC cell.
  - Sandvik P3.0 "high alloyed steel" (320/380 HB) is filed under H13 but is not in the 45–50 band.
- **Kennametal AMS 5540** (one HEM case study) is alloy 600, not 718. It is filed under High Temp Nickel Alloy with a note.

### Corrections made during review

- **Harvey SF_73000 depth of cut.** Each row has two depth-of-cut pairs. The first belongs to 0.015–0.047" tools and the second to 0.062–0.500" tools, as the rendered page shows. Roughing at 1/16" and 3/32" is 3D × **0.25D**. `harvey_micro_data.md` had recorded 0.13D; it is corrected.
- **Scrambled text layers.** pdftotext scrambles the Sandvik Plura HD, CERATIZIT and OSG tables, which makes the text alone unreliable. The reviewer checked rows against rendered pages:
  - Plura HD: M1.0.Z.AQ, D04 = 0.049 mm at 12.7 mm.
  - OSG AE-VMS: the PH column at 1/4", 4580 rpm / 21.4 IPM side and 4050 / 17.9 slot.
  - CERATIZIT: the property table.
  
  All matched the agents' rows.
- **Seco JS554-3C M3 (2026-10-16).** The inch line prints "330 (300 - 320) sf/min", a value outside its own range. The numeric SFM is taken from the metric line (90–100 m/min = 295–328 SFM).
- **Source quirks noted and skipped:** OSG HP441 1/8" at 30–45 HRC (rpm inconsistent with the header SFM), OSG AE-VML 3D Ar 0.15D PH column, Harvey SF_859400 38–44 Rc profiling RDOC "1 x Dia", Seco JHP770 side (ap/DC 1.8 vs 1.6), Kennametal HARVI II TE "M" row, and one self-contradictory Kennametal case study.

### Step 2 (2026-10-16): what was found and what is still missing

**Found**
- **HEM:** explicit HEM, dynamic or trochoidal tables from 8 vendor groups:
  - Helical HVSS/HVAL/HVTI/HVNI and Harvey SF_711700.
  - Sandvik Dura 1K354/1K365.
  - Seco Jabro Advanced roughing.
  - Emuge TiNox-Cut Trochoidal (17-4 named).
  - Garr X/V/VRX Profile/Trochoidal.
  - YG-1 HHK82.
  - Kyocera SGS HSM charts (H-Carb, T-Carb and HPR; filed as `hem`, labelled "HSM").
  - OSG VGM (inferred).
  - Kennametal publishes no HEM table, only its Ae/D factor rule and one dynamic-milling case study.
- **17-4 PH HEM** at 1/8–1": Helical HVSS-6, Emuge, Garr, Kyocera SGS, Seco (P12/H12), YG-1, Kennametal (derived), and Helical's 36 HRC guidebook case.
- **Micro Ti/Inconel/H13:**
  - Harvey: variable-helix high-temp alloys, plus hardened-steel sheets from 0.015".
  - OSG: HP441 and AE-MS-H.
  - Kennametal: KenCut MM (H only).
  - Seco: JME542 (0.4 and 0.8 mm).
  - Kyocera SGS: micro catalog.
- **Long reach:**
  - Harvey: 3×–15× reach sheets for Ti, Inconel and 17-4 (LB only).
  - OSG: VGM5-LN with its printed L/D reduction chart.
  - Seco: LV3/LV5 rules.
  - Kennametal: necked HARVI I TE metric with "reach > 5×D: fz −30%".
  - Helical: HVTI-RN-6 at 3×D.
  - Sandvik: necked Dura.

**Still missing**
- **HEM below 1/8".** At 1/32" every HEM cell has a single group (Garr X3 "Profile/Trochoidal"). At 1/16" only Ti and Inconel have two groups (Harvey SF_711700 and Garr). No vendor prints HEM at 1/64". This matches Harvey's guidance that HEM below 1/32" is not recommended.
- **H13 at 45–50 HRC HEM.** Only Seco H8 (38–64 HRC) covers it, at 1/4" and 1/2". Helical's hardened-steel HEM sheet (HVHS-6) covers 50–60 HRC without naming H13 and was not used.
- **6061 and 1018/1045 micro.** Nothing below 1/16" for 6061.
- **Harvey neck diameters.** Not published on Harvey's tool pages, so Harvey's long-reach rows lack neck diameter.
- **Generic reach reductions.** Helical says only that IPT "should be reduced" past 3×D, with no number. Harvey publishes per-reach sheets instead of a factor.
- **Sources not reached:**
  - Iscar: its site is behind a Cloudflare challenge.
  - Harvey Performance's official HEM Guidebook: gated by a lead form, not submitted.
  - Seco's online cutting-data engine: reports itself offline. The Seco catalog PDF was used instead.
  - OSG AE-VMSX: Lists 8240/8340 are 404 on osgtool.com, and the Cloudinary copy is blocked.
  - Kennametal master catalog: both copies 404.

## 2. What the data already says about v1 and about the physics

### Compare whole cuts, not chip loads (revised 2026-10-15 with the user)

A first pass compared chip load alone and called Harvey's generic charts (SF_73000/72000) "1/3 of every other source". That was misleading. The generic charts take 3·D deep at 0.25·D wide with a small chip, while Harvey's material-specific sheet SF_875400 takes 0.6·D × 0.4·D with a 2.5× larger chip. By removal rate the two Harvey sheets **agree**.

Below, each 17-4 PH side/rough row is at the same diameter. The physics columns come from `physics_v2/forces.py` with P5.0.Z.PH, K_r = 0.4, 35° helix and no runout:
- **F_lat** is the mean lateral force on the tool, which drives deflection and breakage.
- **MRR/F** is removal per unit of lateral force (in³/min per kN).

v1 is the same 17-4 H1025, Standard Roughing, aggressiveness-50 run as before.

| D | Source (hardness) | SFM | fz | ap/D × ae/D | MRR in³/min | F_lat N | MRR/F |
|---|---|---|---|---|---|---|---|
| 1/16" | Harvey SF_73000 (29–37 HRC) | 150 | 0.00010 | 3.0 × 0.25 | 0.011 | 46 | 0.23 |
| | Harvey SF_875400 (300–350 HBn) | 140 | 0.00026 | 0.6 × 0.40 | 0.008 | 29 | 0.28 |
| | OSG 3604 (< 32 HRC, all stainless) | 229 | 0.00040 | 1.5 × 0.05 | 0.007 | 17 | 0.39 |
| | Helical HEV-5 (21–36 HRC) | 200 | 0.00040 | 2.0 × 0.22 | 0.043 | 105 | 0.41 |
| | **v1** | 329 | 0.00038 | 0.10 × 0.50 | 0.006 | 8 | 0.75 |
| 1/4" | Harvey SF_73000 (29–37 HRC) | 150 | 0.00039 | 3.0 × 0.25 | 0.168 | 541 | 0.31 |
| | Harvey SF_875400 (300–350 HBn) | 140 | 0.00105 | 0.6 × 0.40 | 0.135 | 354 | 0.38 |
| | OSG AE-VMS 8200 | 300 | 0.00117 | 1.5 × 0.20 | 0.402 | 530 | 0.76 |
| | Helical HEV-5 (21–36 HRC) | 200 | 0.00130 | 2.0 × 0.23 | 0.559 | 1064 | 0.53 |
| | Kennametal HARVI I TE (35–43 HRC) | 205 | 0.00110 | 1.5 × 0.50 | 0.646 | 1109 | 0.58 |
| | **v1** | 344 | 0.00090 | 0.09 × 0.50 | 0.053 | 57 | 0.94 |
| 1/2" | Harvey SF_73000 (29–37 HRC) | 150 | 0.00078 | 3.0 × 0.25 | 0.670 | 1869 | 0.36 |
| | OSG AE-VMS 8200 | 265 | 0.00193 | 1.5 × 0.20 | 1.17 | 1573 | 0.75 |
| | Helical HEV-5 (21–36 HRC) | 200 | 0.00260 | 2.5 × 0.23 | 2.79 | 4598 | 0.61 |
| | **v1** | 344 | 0.00180 | 0.16 × 0.50 | 0.379 | 349 | 1.08 |

What this shows:

- **Within Harvey,** generic and specific sheets give about the same removal rate (1/4": 0.17 vs 0.13 in³/min). They split it differently between depth and chip load.
- **Across vendors at 1/8–1/2",** Harvey removes about 2–4× less than Helical and Kennametal. OSG falls in between, close to Harvey at 1/16".
  - Most of the gap is **speed**: Harvey runs 140–150 SFM where others run 200–300 SFM.
  - Speed adds removal without adding force in this model, so MRR/F rises with SFM.
  - The rest is the **tool load each vendor accepts**: Helical and Kennametal put 2–3× Harvey's lateral force on a 1/4" tool.
- **Hardness bands differ and must be compared like for like.** Harvey's lowest ferrous column is 29–37 HRC, which covers H900–H1025 17-4. Helical's is 21–36 HRC, Kennametal's ≤ 35 HRC, and OSG gives none. Harvey's own sheet drops from 140 to 80 SFM going from 300–350 to 400–425 HBn.
- **v1 is not "too aggressive" by removal or force.**
  - v1's MRR is at or below the lowest vendor at every diameter: 1/4" gives 0.053 against 0.13–0.65.
  - Its tool load is 5–20× lower than any vendor's.
  - It gets there with SFM 1.5–2.5× too high and a depth 10–30× too shallow.
  - v1's problem is the shape of the cut, plus SFM: too fast and too shallow. The size of the cut is not the problem.

**Open question:** do vendors differ in the lateral load they accept for the same tool, or does the force model miss something (K_r, edge force, hardness)? That is what calibration has to settle. A useful check is tool deflection or bending stress for each row on its own catalog geometry, using C3/C4 from design §3.4.

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

1. ~~17-4 Condition A~~ **Decided 2026-10-15:** every 17-4 condition uses P5.0.Z.AN scaled by real hardness, as Sandvik's ToolGuide does (`sandvik_toolguide_probes.md`).
2. ~~Harvey's generic charts~~ **Decided 2026-10-15:** kept at normal weight. By removal rate they agree with Harvey's material-specific sheet (§2).
3. ~~**C5 rating**~~ **Decided 2026-10-15:** the continuous rating for sustained cuts.
