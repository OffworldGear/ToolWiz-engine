# Carbide and cutting-edge physical constants for ToolWiz

Date accessed: 2026-10-15. Every number below is either quoted from a source or is arithmetic on two quoted numbers (marked "computed"). Full quotes, page/table refs and URLs are in `data/carbide_edge_sources.json` (184 entries). Gathered by a research agent; the CERATIZIT table was re-checked by the reviewing model against the catalog text. Source documents are not kept in the repo; each entry carries its URL. For design §3.4/§3.5 (C1, C4).

Legend: **P** = primary source read in full or in the relevant table; **S** = secondary (a paper or vendor quoting someone else); **A** = abstract/snippet only (paywalled, not read).

---

## 1. Mechanical properties of submicron / ultrafine WC-Co (end-mill rod grades)

### Best-supported table: CERATIZIT p-line catalog 05/2024, p.22 (P; table checked against the rendered page)

Typical values, uncoated carbide. Grain classes per the catalog's own p.23 table: ultrafine 0.2 to <0.5 um, submicron 0.5 to <0.8 um (individual grade grain size is not given).

| Grade | Class | Co [m%] | Density [g/cm3] | HV30 | TRS [MPa] | K1C Shetty [MPa m^1/2] | E [GPa] | Poisson |
|---|---|---|---|---|---|---|---|---|
| CTU08L | ultrafine | 4.2 | 15.05 | 2200 | 3700 | 8.4 | 646 | 0.202 |
| TSF22 | ultrafine | 8.2 | 14.55 | 1930 | 4400 | 9.2 | 596 | 0.210 |
| TSF44 | ultrafine | 12.0 | 14.10 | 1730 | 4600 | 9.8 | 547 | 0.218 |
| CTS12D | submicron | 6.0 | 14.80 | 1820 | 3600 | 9.3 | 624 | 0.205 |
| CTS15D | submicron | 7.5 | 14.70 | 1750 | 3700 | 9.5 | 605 | 0.208 |
| CTS18D | submicron | 9.0 | 14.55 | 1590 | 3650 | 10.7 | 586 | 0.211 |
| CTS20D | submicron | 10.0 | 14.38 | 1600 | 4000 | 10.4 | 570 | 0.214 |
| CT-GS20Y | submicron | 10.0 | 14.44 | 1580 | 3800 | 10.6 | 577 | 0.213 |
| CTS24Z | submicron | 12.0 | 14.10 | 1570 | 4000 | 11.3 | 549 | 0.217 |
| CTS30D | submicron | 15.0 | 13.84 | 1400 | 4300 | 13.2 | 512 | 0.223 |

Also CERATIZIT CTU13L brochure (P): ultrafine, 6.5 m% binder, 14.72 g/cm3, HV30 2080, TRS 3800 MPa, K1C (Shetty) 8.7, "Modulus of elasticity" 618 GPa, "Transverse contraction" 0.206.

Catalog caveat (p.23, quoted): K1C "depend[s] to a high degree on the sample geometry and sample preparation. A direct comparison with parameters which have been determined by means of a different method is therefore not admissible."

### Corroborating vendor data

- **Hyperion K10F rod leaflet (P, typical):** WC 90 / Co 10 wt%, 0.8 um, density 14.4, HV30 1620, TRS 3700 MPa, K1C (Palmqvist) 10.8.
- **Mitsubishi Materials Hardmetal TM102G (2026-07-10), p.8 (P):** rod grades, Co 6-12 mass%, grain <0.4 to <1.0 um. TRS 3.2-4.4 GPa; fracture toughness 6.5-9.7 MPa m^1/2 (method not stated); HV 1550-2000. Examples: QF10 (<0.4 um, 8% Co) 4.2 GPa / 6.5; TF15 (<0.9 um, 10% Co) 4.0 GPa / 9.7; MF20 (<0.6 um, 12% Co) 4.4 GPa / 7.3. The last column is headed only "GPa" (values 520-630); p.7 of the same catalog plots the same unlabeled values as "HRA-Young's Modulus", so I read it as E (inference). MF10 (8% Co) at 520 GPa looks low against QF10 (8% Co) at 600.
- **Fooladi Mahani/Llanes 2025, Table 1 (P, 4-point bending, 20/40 mm spans, >=15 specimens):** U10 5.9% Co, 0.6 um WC: flexural strength 2770 +/- 431 MPa, K1C 9.6 (Vickers indentation); U20 9.6% Co, 0.7 um: 3017 +/- 505, 10.9; U40 15.6% Co, 0.4 um: 3849 +/- 190, 13.6.
- **Preis 2004 thesis, Table 2.1 (P):** WC-10Co, 2.0 um (coarser than micro grades), HRA 87.5, RTZ 2.2 GPa, E = 670 GPa; WC-15Co 2.1 um, RTZ 2.7, E = 600. The 670 GPa value is an outlier against the CERATIZIT 570-577 GPa for 10% Co; single source, method not stated.

### TRS depends strongly on specimen and test (important for any fatigue ratio)

- Hyperion (P, quoted): the rotary-tool industry uses a cylindrical specimen O3.25 x 38 mm; "the TRS values obtained from the cylindrical specimens exceed the level of the square specimens by about 20%. Thus, caution must be used when data are compared." ISO 3327 / EN 23 327 is the rectangular chamfered bar.
- Mitsubishi lists the same grade TF15 at TRS 4.0 GPa as a rod (p.8) and 2.5 GPa as a plate (p.12). The rod/plate ratio of 1.6 is bigger than Hyperion's 20%; no explanation in the catalog.
- 4-point bending (Fooladi) gives lower strengths (2.8-3.0 GPa for 6-10% Co) than rod-vendor TRS (3.6-4.0 GPa for similar Co). Different test, different volume.

### Compressive strength

- Hyperion (P): "A cemented carbide grade with a small WC grain size and a low binder content has a typical compressive strength approaching 7000 N/mm2" (EN 24 506 / ISO 4506).
- CERATIZIT p.121 (P): "almost 7,000 N/mm2" for small grain, low binder.
- Distributor Moser listing for Sandvik H10F (10% Co, 0.8 um): compressive 6,250 N/mm2, TRS 4,300 N/mm2 (S, distributor; test standard not stated).
- Not found: a manufacturer table of compressive strength for 8-12% Co submicron grades (both Hyperion and CERATIZIT give it only as a graph).
- Compression-compression fatigue (Hyperion and CERATIZIT agree): 65-85% of static compressive strength at 2x10^6 cycles, pulsating compression.

### Density, Poisson

Density 14.1-15.05 g/cm3 over 4-15% Co (CERATIZIT); 14.4 (Hyperion K10F, 10% Co). Poisson 0.202-0.223 (CERATIZIT, rising with Co).

---

## 2. Fatigue strength / TRS ratio

The primary source for the ratio at the cycle count you want is **Sakagami, Kouno, Yamamoto (Dijet), J. Jpn. Soc. Powder Powder Metallurgy 54(4):260-263 (2007)**, open access, English abstract plus tables/figures in English (P; main text is in Japanese, my reading of it is flagged).

Test (as I read p.260): three-point bending fatigue, specimens 6x12x33 mm (ground, #200 diamond wheel), span 28 mm, sine wave 10 Hz, **load from 0 to max stress (R = 0)**, fatigue limit = no failure at **10^7 cycles**, HIP-treated WC-0.5-1.0% Cr3C2-Co. TRS from 4x8x24 mm bars, 20 mm span, n=5 (so TRS and fatigue use different specimen sizes).

| Alloy | WC starting powder | Co [mass%] | TRS [GPa] | Fatigue limit [GPa] | Ratio (paper's printed %) |
|---|---|---|---|---|---|
| 10F | fine, 1.2 um | 10 | 4.05 | 2.22 | 54.8% |
| 15F | fine, 1.2 um | 15 | 3.79 | 2.00 | 52.8% |
| 10C | coarse, 4.9 um | 10 | 3.08 | 1.55 | 50.3% |
| 15C | coarse, 4.9 um | 15 | 2.93 | 1.49 | 50.9% |
| 22C | coarse, 4.9 um | 22 | 2.78 | 1.27 | 45.7% |

Quoted conclusion: "45~55% of the transverse-rupture strength was equivalent to the bending fatigue limit." Higher-TRS (finer, lower-Co) alloys had the higher ratio. Note 1.2 um is the starting powder size, not the sintered grain size.

Independent checks (secondary, all via Preis 2004 TalTech thesis, which reviews and also adds its own tests):

| Source | Material | Test | Ratio |
|---|---|---|---|
| Preis 2004 own data (P) | WC-10Co 2.0 um | 3-pt, ISO 3327/ASTM B406, R = 0, 10^7 | 1.23/2.2 = 0.56 (computed) |
| Preis 2004 own data (P) | WC-15Co 2.1 um | same | 1.56/2.7 = 0.58 (computed) |
| Schleinkofer et al. 1996 via Preis (S) | WC-6Co-TiC-(Ta,Nb)C | cantilever, **R = -1**, 10^7 | 960/2498 = 0.38 (computed) |
| same | 12% Co grade B | R = -1, 10^7 | 900/2734 = 0.33 (computed) |
| Kursawe et al. 2001 via Preis (S) | WC-7Co / WC-15Co | 10^6 cycles, R not stated in the extract | 1200/2840 = 0.42; 1300/3178 = 0.41 (computed) |
| Brookes 1982; Schedler 1998 via Preis (S) | WC-Co 5-25% Co | 10^8 cycles (Brookes) | "around 30%"; "30-40%" |
| Miyake 1968; Davies 1972 via Preis (S) | WC-Co | 5x10^6 | 0.7-0.8; 0.6 (Preis attributes the spread to test-method imperfection) |

Reading across: **R = 0 bending, 10^7 cycles, ground specimens: 0.46-0.58, fine/low-Co at the top (0.53-0.58).** Fully reversed (R = -1) and older compilations: 0.30-0.42. Load ratio matters: the fatigue limit is stated as max stress for R = 0, which is not the same as stress amplitude.

Physical form behind the ratio (S, Preis summarising Torres, Anglada, Llanes 2000): fatigue limit Se = (Kth/KIc) x RTZ, where Kth/KIc is the "fatigue sensitivity"; agreement with experiment within 10%. Observed WC-10Co (Torres et al. via Preis Table 1.5): Se = 1827 +/- 92 MPa (R = 0.1), 1783 +/- 70 (R = 0.4), 2112 +/- 70 (R = 0.7) as max stress. I could not retrieve the Llanes/Torres/Anglada paper (paywalled); a search snippet of its abstract gave 2742 MPa flexural strength for a fine-grained WC-10Co, which would make the R = 0.1 ratio about 0.67, but I could not confirm it is the same material, so I am not using it.

Other fatigue facts found: "No definite fatigue strength limit... has been found as in the case of steel" (Hyperion, compression). Fooladi 2025 fatigue tests were only on pre-indented specimens, R = 0.1, 5 Hz, 2x10^5 run-out: no pristine fatigue limit there.

---

## 3. Cutting-edge radius r_beta of solid carbide end mills

No source gives r_beta as a function of diameter. What exists is a handful of measured points; the micro-tool numbers are small (0.4-3.5 um) and conflict with each other.

| Tool | Condition | r_beta [um] | Method | Source |
|---|---|---|---|---|
| D = 0.5 mm, 2-flute, UF09 carbide (0.5 um, 9% Co), ground | uncoated | 0.41 | Keyence VK-X100 3D laser microscope + SEM | Liang et al., Micromachines 2018 (P) |
| same | AlCrN-based, ~1 um coating | 0.90 | same | same |
| same | AlTiN-based (Balzers Latuma), ~1 um | 1.2 | same | same |
| same | TiN, ~1 um | 1.5 | same | same |
| D = 0.5 mm, solid carbide, new | 4340 steel study | 1.5 (to 25 after 600 mm of cutting) | not stated | Afazov via Wojciechowski arXiv (S) |
| D = 1 mm, 2-flute, Zecha Peakcook 599-based | uncoated, as received | 3.5 +/- 0.3 (S_avg) | Alicona EdgeMaster focus variation, form-factor method | Jackel et al., Prod. Eng. 2024 (P) |
| same, after PVD-etching + HiPIMS TiAlSiN | edge also modified by etching | 5.20-8.25 (S_avg); text says coating alone enlarges S by layer thickness | same | same |
| D = 8 mm ball-end, TiAlN-coated carbide, new | hardened L6 tests | 3.5 (28 when VB = 0.15 mm) | Alicona IF-EdgeMaster | Wojciechowski et al. arXiv:2403.15554 (P) |
| R390-type PVD-TiAlN carbide insert (not an end mill) | production edge | 24.404 +/- 0.848 | Olympus OLS4000 3D laser microscope | Assis et al., euspen 2012 (P) |
| Ground carbide cutting edge before preparation | inserts, general | ~5 | citing Denkena 2013 | Slaninkova et al., MM Sci. J. 2023 (S) |
| Prepared coated inserts | blasting/brushing targets | 25 +/- 5 and 40 +/- 5 | Alicona IF-EdgeMaster | same (inserts only) |

Literature statements (S): "new, unused carbide micro milling tools have a cutting edge radius between 1 and 20 um, depending on whether they are coated or uncoated" (Balazs & Takacs 2020, citing their ref [3]); "currently of the order of 1-4 um in micro-milling" (Ducobu 2017 citing their ref [5]); a TiAlN-coated micro mill with 3.0-3.5 um radius used on Ti6Al4V (K and Mathew, via Balazs & Takacs).

Coated vs uncoated: only Liang et al. (D = 0.5 mm) and Jackel et al. (D = 1 mm) give a coating effect on end mills, and they agree in direction (the coating thickens the edge). The magnitudes are small (about +0.5 to +1.1 um at ~1 um coating on a 0.5 mm tool).

**Not found:** a measured r_beta for 1/4 in to 1 in solid carbide end mills (coated or uncoated), and manufacturer edge-hone specifications. The only macro-scale values are the insert numbers above (5 um as-ground, 20-25 um prepared and coated), and a trade-blog remark of 5-20 um hone for carbide that I did not archive because it is a blog. The standard review (Denkena and Biermann, CIRP Annals 63(2), 2014) is paywalled and I could not retrieve it. Aramcharoen & Mativenga 2009 is paywalled (abstract elided at Semantic Scholar); I only have it second-hand via Li et al. 2021.

---

## 4. Minimum chip thickness ratio lambda = h_min / r_beta

### Review table (Wojciechowski, Materials 15:59, 2022, Table 1; open access; secondary, as it re-tabulates others' work)

Review's own conclusion: "independent of selected input process parameters, the normalized minimum uncut chip thickness is contained within the range of 0.08 <= k <= 0.63."

| Material | k = h_min/r_n | Method, process (author, year) |
|---|---|---|
| Steel 1045 | 0.3 | experiment, micro-milling (Kang 2011) |
| Steel 1045 | 0.29 | experiment, micro-milling (Cuba Ramos 2012) |
| Steel 1045 | 0.22-0.36 | experiment, milling (Oliveira 2015) |
| Steel 1045 | 0.25 | FEM, micro-milling (Chen 2017) |
| Steel 45 | 0.2 | FEM, micro-milling (Ding 2011) |
| Ferritic-pearlitic steel | 0.14-0.43 | FEM, micro-milling (Vogler 2004) |
| Steel 4340 | 0.26 | FEM, turning (Woon 2008) |
| Steel 4340 and Al 2024-T6 | 0.29-0.45 | FEM, micro-milling (Ozel 2009) |
| Steel 1040 / Al 6082-T6 | 0.2-0.4 | analytic, turning (Liu 2006) |
| Steel C45 (micro end milling vs cutting speed) | 0.17-0.29 | k rises with speed (review Sec. 3) |
| Steel 45, steel 1.3505 | 0.15-0.63 | analytic, turning (Jankowiak 1993) |
| Steel C55 | 0.08 | analytic, turning (Storch 2012) |
| Al 6061 | 0.23 | analytic, micro-milling (Malekian, Park, Jun 2012) |
| Al 6082 | 0.08 | experiment, turning, CBN tool (Rahman 2017) |
| Al / Cu / brass | 0.2-0.4 | analytic, turning (Son 2005) |
| Copper | 0.25 (analytic, Lai 2008); 0.33 (experiment, Camara 2016) | micro-milling |
| Brass 360 | 0.3 | experiment, micro-milling (Kim 2004) |
| Cu-Mg-Mn | 0.2-0.4 | experiment, turning (Yuan 1996) |

The review also says k rises with cutting speed regardless of material (Liu, Ozel, Przestacki).

### Direct end-mill data

- **Li, Cheng, Zheng, Liu, Mech. Sci. 12:487 (2021), open access, FE (Deform-3D) plus experiment, D = 0.5 mm TiAlN micro end mills, r_e = 1, 3, 5, 7 um, Cu H59 / 304 stainless / 6061 Al.** Peripheral edge, process 1 (MUCT in um from Table 5; ratio computed): r_e = 1: Cu 0.4, 304 0.4, Al 0.3-0.4 (ratio 0.3-0.4); r_e = 3: Cu 1.2, 304 1.2, Al 0.9 (0.3-0.4); r_e = 5: 1.5 (Cu), 1.5-2.0 (304), 1.5 (Al) (0.3-0.4); r_e = 7: 2.0 (Cu), 2.5 (304), 2.0 (Al) (0.29-0.36). Experiments (Table 7) agree to within about 0.5 um. Their fit: MUCT = -0.0187 r_e^2 + 0.4050 r_e + 0.0488 um (process 1; 0.43 at r_e = 1, 0.28 at r_e = 7, computed). The end (axial) cutting edge needs larger thickness: 0.8, 1.5, 3.5, 4.5 um for r_e = 1, 3, 5, 7 (ratio 0.5-0.8) and is material-independent in their data; stainless needed the highest MUCT among the three on the peripheral edge, but only by about 0.5 um.
- **Titanium:** Ducobu, Riviere-Lorphevre, Filippi, Meccanica 52:1577 (2017) (P): annealed Ti6Al4V, orthogonal cutting, carbide tool r = 10 um, vc 30 m/min: "the minimum chip thickness would be between 2.5 and 5 um"; force-ratio inversion at about 5 um; "A chip is undoubtedly formed when h/r is larger than 0.5." So lambda = 0.25-0.5 (abstract: "at minimum 25%"). Second-hand: Vipindas et al. 2018, Ti-6Al-4V micro end milling, "critical feed per tooth value is about 1/3 of the cutting edge radius" (via Li et al.; S).
- **Hardened steel:** Wojciechowski et al. (arXiv:2403.15554), D = 8 mm TiAlN ball-end mill, AISI L6 58 HRC, r_n = 3.5 um: k = 0.66-0.80 (0.78 new tool). Roughly double the soft-steel values; ball-end and hardness both differ from the others.
- **Range often quoted:** "between 5 and 38 % of the tool edge radius, depending on the machined material" (Filiz et al. and Chae, Park, Freiheit 2006, as quoted in Ducobu 2017; S, Chae not accessed).
- Size-effect/surface-finish rules (S): size effect strong when UCT/r < 1, best finish with UCT = r_e for H13 (Aramcharoen & Mativenga 2009, via Li et al.); Assis et al. 2012 (P): surface roughness minimum at f_t ~ r_e (ultrafine-grain 0.16% C steel, r_e = 24.4 um coated insert).

**Reading:** for steel, aluminum, copper, brass, stainless in soft/medium condition the sourced values cluster at 0.2-0.4 (extremes 0.08-0.45); the design's 0.2-0.4 assumption is supported. The 0.08 figures are from turning of Al/steel (not milling) and 5% / 38% are Chae's range which I could not verify. Hardened steel (0.66-0.8) and the titanium orthogonal result (0.25-0.5) sit at or above the top of that band. Dependence on edge radius itself (ratio is not constant: 0.43 to 0.28 in the Li fit) and on cutting speed is documented.

---

## 5. Core (web) diameter ratio d_core / D

No catalog or paper with measured values found; the sources are patent embodiments and one vendor training page (design targets, not measurements).

| Flutes / use | d_core / D | Source |
|---|---|---|
| Standard solid end mill (4-flute example) | "usually about 60%" | Mitsubishi Materials technical course "Web thickness" (vendor, S) |
| 2 or 3 flutes, slotting | 50-65% (EP 1 072 345); 40-55% (YG-1, US 11,554,426) | patents |
| 2 flutes | at least 60% | New Tech Cutting Tools, US 10,335,870 (high-load design) |
| 3 flutes | at least 60% | same |
| 4 flutes | at least 58% (illustrated about 68%); roughing side milling 55-70% (EP 1 072 345); rough side cutting 50-65% (YG-1) | patents |
| 5 flutes | at least 61%, more preferably at least 64% | US 10,335,870 |
| 6 flutes | at least 63%, more preferably at least 65% | same |
| 4-6 flutes finishing, short | 65-75% (EP 1 072 345); finish side cutting 60-85% (YG-1) | patents |
| 5-8 flutes deep finishing / maximum rigidity | 75-85% | EP 1 072 345 |

Qualitative agreement: more flutes means larger core (Maford catalog; University of Florida handout). Chip space vs rigidity trade-off stated in EP 1 072 345 [0007] and Mitsubishi. Core taper (smaller near the tip) is also used (EP 1 072 345; US 10,828,706 background).

Micro end mills (D <= 1/8 in): no published web ratio found.

---

## Summary table: best values to carry into ToolWiz

| Quantity | Best value | Range | Key citation | Confidence |
|---|---|---|---|---|
| E, WC-Co 6-12% Co, submicron | 570 GPa at 10% Co; 624 at 6%; 549 at 12% | 547-646 over 4-12% Co; falls with Co | CERATIZIT p-line p.22 | good (vendor, 10 grades, plus CTU13L 618 at 6.5%) |
| TRS (rod vendor, cylindrical-type) | 3.6-4.0 GPa for 6-12% Co | 3.2-4.6 | CERATIZIT p.22; Mitsubishi p.8; Hyperion K10F 3.7 | good, but test geometry matters (+20% vs ISO 3327 bar) |
| TRS (ISO 3327-type bar) | ~2.5 GPa class | 2.5 (Mitsubishi plates), 2.2-2.7 (Preis 2 um grades) | Mitsubishi p.12; Preis p.29 | medium; submicron ISO 3327 values not found |
| TRS (4-pt, 40/20 mm) | 2.8-3.0 GPa at 6-10% Co | 2.77-3.85 | Fooladi 2025 | good, 3 grades |
| K1C | ~10 MPa m^1/2 at 10% Co | 8.4-11.3 for 4-12% Co (Shetty); 10.8 (Hyperion Palmqvist) | CERATIZIT p.22; Hyperion K10F | good; method-dependent, do not mix |
| Density | 14.4-14.55 g/cm3 at 9-10% Co | 14.1-15.05 | CERATIZIT; Hyperion | good |
| Poisson | 0.21 | 0.202-0.223 | CERATIZIT | good |
| Compressive strength | ~6250-7000 MPa | "almost 7,000" small grain, low Co | Hyperion; CERATIZIT p.121; Moser (H10F) | thin: one numeric grade-specific value, distributor |
| Fatigue limit / TRS, R = 0 bending, 10^7 | 0.53-0.55 (fine WC, 10-15% Co) | 0.46-0.58 | Sakagami 2007; Preis 2004 | decent: 2 independent R=0 sets |
| Fatigue limit / TRS, R = -1 or 10^6-10^8 | 0.33-0.42 | 0.30-0.42 | Preis (Schleinkofer, Kursawe, Brookes, Schedler) | secondary only |
| r_beta, D = 0.5-1 mm, uncoated | 0.4 to 3.5 um | 1-4 um typical statement | Liang 2018; Jackel 2024; Ducobu 2017 | weak: 2 measurements that disagree by 8x |
| r_beta, coated D = 0.5 mm | 0.9-1.5 um (1 um coating) | +0.5 to +1.1 um vs uncoated | Liang 2018 | single source |
| r_beta, macro (1/4-1 in) | not found | insert ~5 um ground, 20-25 um prepared+coated | Slaninkova 2023; Assis 2012 | missing for end mills |
| lambda (soft/medium steel) | 0.2-0.4 (centre 0.25-0.3) | 0.08-0.63 | Wojciechowski 2022 Table 1 | good (about 10 studies) |
| lambda (stainless 304, D 0.5 mm) | 0.3-0.4 | 0.29-0.4 | Li 2021 (FE+exp) | single study |
| lambda (aluminum) | 0.23-0.3 | 0.08-0.4 | Malekian 2012; Li 2021; Son 2005 | medium |
| lambda (copper/brass) | 0.25-0.33 | 0.2-0.4 | Lai; Camara; Kim 2004 (via review) | medium |
| lambda (Ti6Al4V) | 0.25-0.5 | ~1/3 (Vipindas, S) | Ducobu 2017 | single primary, orthogonal r = 10 um |
| lambda (hardened steel, ball-end) | 0.66-0.80 | | Wojciechowski arXiv | single, preprint |
| Core ratio 2-3 flute | 50-60% (use ~60% standard) | 40-65% | Mitsubishi; EP 1 072 345; YG-1; US 10,335,870 | patents/vendor text only |
| Core ratio 4 flute | 58-65% | 50-70% | same | patents/vendor text only |
| Core ratio 5 flute | 61-64% | | US 10,335,870 | single patent |

## Gaps and single-source items

- No measured end-mill r_beta vs diameter, none for 1/4-1 in tools, no edge-hone spec from a manufacturer (Denkena/Biermann 2014, Aramcharoen & Mativenga 2009, Chae 2006, Bissacco 2008, Oliveira 2015 are all paywalled; accessed only via citations or not at all).
- Llanes/Torres/Anglada fatigue papers are paywalled; their numbers come via the Preis thesis (secondary). Sakagami's methods text is Japanese (my reading).
- Submicron grades' E: only CERATIZIT gives a full table; Mitsubishi's E column is unlabeled; Preis's 670 GPa is an outlier.
- Compressive strength: one numeric grade value (distributor).
- Titanium lambda: one primary orthogonal experiment (r = 10 um) and one second-hand micro-milling ratio; stainless: one FE+experiment study at r_e <= 7 um; no data for Inconel or Ti in end mills.
- Core ratios are patent design targets; no measured catalog values; none for micro end mills.
- Mitsubishi's older (2021) rod catalog URLs return 404; the 2026-07-10 version is the one cited.
