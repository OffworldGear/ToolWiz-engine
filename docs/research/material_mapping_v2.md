# GWizard families → Sandvik MC groups (proposal for v2 force data)

_Research, 2026-10-15. For design §3.2 and §4.1 (`data/model_v2/materials.json`). Status: proposal, with the PH stainless decision made (see that section). Nothing in the engine uses it yet._

## Source

- **kc1 and mc:** Sandvik Coromant, *Workpiece materials* (MC code tables), https://www.sandvik.coromant.com/en-gb/knowledge/materials/workpiece-materials, accessed 2026-10-15. The full table, cross-checks and quoted cells are in `kc_mc_survey.md` and `data/kc_mc_sources.json`.
- **Verification:** eight rows were re-read from the live page by the reviewing model and match exactly: P5.0.Z.AN, P5.0.Z.HT, P5.0.Z.PH, M1.0.Z.AQ, M1.0.Z.PH, P2.5.Z.HT, S2.0.Z.AG, H1.1.Z.HA.
- **Reference conditions (Sandvik):** kc1 is for a neutral edge at 0° rake. The formula image on Sandvik's "specific cutting force" page gives kc = kc1·hm^(−mc)·(1 − γ0/100), i.e. 1% lower per degree of positive rake. Sandvik states no reference cutting speed and no h range for mc.
- **Sandvik's ISO split differs from GWizard's codes.** Ferritic, martensitic and martensitic-PH stainless are ISO **P** (P5) in Sandvik's scheme, not M. GWizard's "K1" is grey iron, but Sandvik K1 is malleable. GWizard's "S4" is cobalt-chrome, but Sandvik S4 is titanium.

## Mapping

Families that span annealed and hardened conditions map by the alloy's condition (GWizard's `alloys.condition` and `hardness_bhn`), not by family alone.

| GWizard family | Sandvik MC group(s) | kc1 / mc at Sandvik's HB | Rule and notes |
|---|---|---|---|
| Aluminum - Wrought (6061) | N1.2.Z.AG | 650 / 0.25 at 100 HB | T-tempers are aged. Non-heat-treated wrought (1100, 3003, 5052): N1.2.Z.UT 400 / 0.25. |
| Aluminum - Cast | N1.3.C.UT / N1.3.C.AG; N1.4.C.NS if Si ≥ 13% | 600 / 700 / 700, mc 0.25 | By condition and Si. |
| Brass | N3.3.U.UT (leaded, Pb > 1%); N3.2.C.UT (cast, Pb ≤ 1%) | 550 / 0.25 | Free-cutting brass (C360) → N3.3.U.UT. |
| Copper Alloy - Wrought | N3.1.U.UT | 1350 / 0.25 at 100 HB | Non-leaded copper. High-strength bronzes (> 225 HB): N3.4.C.UT has **no kc1** (gap). |
| Magnesium Alloy | N2.0.C.UT | **no kc1** | Gap. |
| Cast Iron - Gray | K2.1.C.UT (≤ ~200 HB), K2.2.C.UT (high tensile) | 900 / 1100, mc 0.28 | |
| Cast Iron - Ductile | K3.1 ferritic / K3.2 ferritic-pearlitic / K3.3 pearlitic / K3.4 martensitic | 870 / 1200 / 1440 / 1650, mc 0.28 | By grade (65-45-12 → K3.1/K3.2; 80-55-06 → K3.3). |
| Steel - Low Carbon (1020) | P1.1.Z.AN; P1.1.Z.HT if hardened | 1500 / 1770, mc 0.25 | Free-cutting (12L14, 1215): P1.4.Z.AN 1180. |
| Steel - Medium Carbon (1045) | P1.2.Z.AN / P1.2.Z.HT | 1700 / 1820 | |
| Steel - High Carbon (1090) | P1.3.Z.AN / P1.3.Z.HT | 1750 / 2000 | |
| Steel - Low Carbon Alloy (8620) | P2.1.Z.AN; P2.5.Z.HT if hardened and tempered | 1700 / 2000 | |
| Steel - Medium Carbon Alloy (4130/4140) | P2.2.Z.AN; P2.5.Z.HT for heat-treated | 1950 at 240 HB / 2000 at 330 HB | "4140 HT" → P2.5.Z.HT. |
| Steel - High Carbon Alloy (52100) | P2.3.Z.AN | 2020 at 260 HB | |
| Steel - Tool (H13) | P3.0.Z.AN (annealed) / P3.0.Z.HT (to ~45 HRC) / H1.1–H1.4 (50, 55, 60, 63 HRC) | 1950 / 3100 / 3090–4750 | HSS grades (M2, M42): P3.1.Z.AN 2360. |
| Stainless - 300 Series (316) | M1.0.Z.AQ | 2000 / 0.21 | 303: M1.1.Z.AQ#2 1800. 321/347: M1.3.Z.AQ 1800. |
| Stainless - 400 Series (420) | P5.0.Z.AN / P5.0.Z.HT | 1800 / 2300, mc 0.21 | 416: P5.1.Z.AN 1650. |
| **Stainless - PH Series (17-4)** | see the next table | | **By alloy and condition.** |
| Titanium Alloy | S4.1.Z.UT (CP grades) / S4.2 (α, near-α) / S4.3 (α-β: Ti-6Al-4V) / S4.4 (β) | 1300 / 0.23 for CP; **1400 with no mc** for S4.2–S4.4 | mc is missing for every Ti alloy row. Seco/Walter/Europa values in the survey can fill it (to decide). |
| Nickel Alloy (Monel 400, Ni 200, 825) | S2.0.Z.AN | 2650 / 0.25 at 250 HB | Sandvik has no separate group for non-HRSA nickel; this overstates soft Ni 200. |
| High Temp Nickel Alloy (718, Waspaloy) | S2.0.Z.AG (aged); S2.0.Z.AN (solution annealed) | 2900 / 2650 | A-286 (iron-based): S1.0.U.AN / AG 2400 / 2500. |
| Cobalt Chrome (F75) | S3.0.C.NS (cast) / S3.0.Z.AN | 3100 / 2700 | |
| Tungsten | S5.0.U.NS | **no kc1** | Gap. |
| Composite, Graphite, Plastics, Wax, Woods | none | — | Outside the Kienzle model. Keep v1 rules (design §2). |

### Decision (user, 2026-10-15): 17-4 PH follows Sandvik's own placement

Sandvik's CoroPlus ToolGuide files 17-4 PH in the annealed ferritic/martensitic group at a default 200 HB and scales force with the hardness entered. That gives ×1.25 from 200 to 345 HB, about kc ∝ HB^0.41; see `sandvik_toolguide_probes.md`.

- 17-4, 15-5, 13-8 and Custom 455/465 in every condition: **P5.0.Z.AN (1800 / 0.21 at 200 HB)**, scaled to the alloy's real HB.
- The hardness exponent per ISO family is taken from that family's own annealed/hardened Sandvik rows (P5: 0.49 from the table, 0.41 from the calculator; P2: 0.26 from both). The calibration step fits the final value.
- P5.0.Z.PH (2800) is **not** used for 17-4. The table below is kept for the record and superseded for kc.
- 17-7 PH Condition A stays austenitic (M1.0.Z.AQ, scaled by HB).

### PH stainless (original proposal, superseded for kc)

| GWizard alloy and condition | HB (GWizard) | Sandvik group | kc1 / mc | Why |
|---|---|---|---|---|
| 17-4, 15-5, 13-8, Custom 465: H900 to H1150-M | 301–487 | P5.0.Z.PH | 2800 / 0.21 at 330 HB | Martensitic PH, aged. |
| 17-4, 15-5, 13-8, Custom 455/465: Annealed (Condition A) | 295–386 | P5.0.Z.HT | 2300 / 0.21 at 330 HB | Condition A is solution-treated martensite, not aged. This is a judgment call; P5.0.Z.PH is the conservative choice. **User to decide.** |
| 17-7 PH Annealed (Condition A) | 162 | M1.0.Z.AQ | 2000 / 0.21 at 200 HB | Semi-austenitic: austenitic in Condition A. |
| 17-7 PH precipitation hardened (TH1050, RH950) | 433 | P5.0.Z.PH | 2800 / 0.21 | Martensitic after transformation and aging. M1.0.Z.PH (2400) is the alternative if Sandvik meant semi-austenitic PH there. |
| 17-7 PH cold rolled (Condition C) | 378 | P5.0.Z.HT | 2300 / 0.21 | Cold-rolled martensite, not aged. |
| Incoloy A-286 | 304 | S1.0.U.AN / S1.0.U.AG | 2400 / 2500 | Iron-based superalloy, not a stainless. It is listed in GWizard's PH family. |

Sandvik never names an alloy, so every row above is our reading of Sandvik's class descriptions. None is a quoted assignment.

## Hardness inside a group (open)

No source surveyed gives a hardness correction for kc1. Sandvik instead gives a separate row per condition, each at a nominal HB. Within a group the implied exponent p in kc1 ∝ HB^p varies widely between pairs of Sandvik rows (derived from the quoted rows):

| Pair | p |
|---|---|
| P1.1 AN → HT | 0.40 |
| P1.2 AN → HT | 0.68 |
| P1.3 AN → HT | 0.29 |
| P2.1 AN → P2.5 HT | 0.26 |
| P3.0 AN → HT | 0.72 |
| P5.0 AN → HT | 0.49 |
| P5.0 AN → PH | 0.88 |
| M1.0 AQ → PH | 0.45 |
| S2.0 AN → AG | 0.27 |

- **Proposal:** use the condition's own group row at its nominal HB. Scale with HB^p only for the distance from that nominal HB, with one p per ISO class fitted in the calibration step (§6 step 4).
- **Not this:** GWizard's single machinability factor, or a universal exponent.
- **Status:** a decision for the calibration step, not now.

## Gaps

- **No kc1 at all:** magnesium (N2), high-strength bronze (N3.4), tungsten (S5), ADI (K5), sintered steel (P4).
- **No mc:** the titanium alloy groups (S4.2–S4.4). Use another source's mc, or fit it from vendor power data.
- **Kennametal:** publishes no kc1/mc table. The second sources used are Seco/Niagara, Walter, Europa and Westermann (see the survey).
- **Walter:** equals Sandvik exactly for most N, S and H groups, so it is not an independent check there.
