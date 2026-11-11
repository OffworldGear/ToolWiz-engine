# kc1.1 / mc source survey for ToolWiz (Kienzle model)

Research, 2026-10-15 (gathered by a research agent; eight Sandvik rows re-verified against the live page). See `material_mapping_v2.md` for the proposed GWizard mapping. Every number below is copied from a quoted source cell (see `kc_mc_sources.json` for the quoted cell text per row). No interpolation. The only arithmetic is (a) the Seco ksi to N/mm2 unit conversion (x 6.894757) and (b) the ratio and implied-kc columns in section 5, which are labelled DERIVED.

Model reminder: kc(h) = kc1.1 * h^(-mc), h in mm, kc in N/mm2. Source abbreviations: **SV** Sandvik Coromant, **SE** Seco/Niagara SMG, **WA** Walter, **EU** Europa Tabellenbuch, **WE** Westermann, **IS** Iscar.

## 1. Headline findings

* **Sandvik Coromant (primary) publishes a full MC-code table** with kc1, mc and a nominal hardness per code on its public web page *Workpiece materials*: 96 rows (ISO P, M, K, N, S, H); 82 rows have a kc1 value, 76 have both kc1 and mc. It uses the **new MC code system** (P1.1.Z.AN style), not the old CMC numbers. The old Technical Guide PDF I could download (Milling, D22-D25, CMC 01.x/05.x) only gives a power constant K per ae/Dc and fz, **not kc1/mc** (see section 6).
* **17-4 PH sits in ISO P, not M, in Sandvik's scheme**: row `P5.0.Z.PH` = *stainless steel ferritic/martensitic, main group, forged/rolled/cold drawn, PH ('precepitation hardened' sic)*, **330 HB, kc1 = 2800 N/mm2, mc = 0.21**. Sandvik's own prose confirms the placement: 'ISO P - Steel ... including steel castings and ferritic and martensitic stainless steels'. The austenitic PH row is `M1.0.Z.PH` (300 HB, 2400, 0.21). Note: the source labels 17-4 only by class; the mapping of 17-4 PH to P5.0.Z.PH is my reading (17-4 is a martensitic PH grade), the page does not name any alloy.
* **Second sources** (all with quoted cells): Walter Technical Compendium 2024 (33 groups), Seco/Niagara SMG table (22 groups, 20 with values; in ksi), Europa *Tabellenbuch fuer Zerspantechnik* (17 group rows + 57 named-alloy rows), Westermann sample page (21 alloy rows), Iscar (1 worked value). **Kennametal: no kc1/mc table found** in its public turning catalogue (4010 Master Catalog text searched for kc/specific cutting force/Kienzle: nothing). Kennametal is therefore a documented gap.
* **Independence caveat**: Walter's values equal Sandvik's exactly for many non-ferrous, superalloy and hardened-steel groups (N, S, H all ratio 1.00 for most pairs, mc = 0.25 throughout). Walter is therefore a weak independent check there. Seco, Europa and Westermann are numerically independent lineages (Seco in lbf/in2, Europa/Westermann from German turning tests, rake basis +6 deg).
* **Reference rake differs**: Sandvik, Seco, Iscar, Walter ('neutral cutting edge geometry') are 0 deg rake. Europa and Westermann base values are for gamma0 = +6 deg (steel) and +2 deg (cast iron). Do not mix these without correcting. See section 4.
* **Not published**: no hardness-correction rule from Sandvik (or any source here); no stated h range of validity for mc in Sandvik/Seco/Walter. Seco tells you only that the BHN is a *selection aid* for the material group.

## 2. Sandvik Coromant: all rows (MC code system)

Source: <https://www.sandvik.coromant.com/en-gb/knowledge/materials/workpiece-materials> (document id SV-WEB), tables 'MC codes for steels / stainless steel / cast iron / N-materials / S-materials / hardened steel'. Accessed 2026-10-15 via browser DOM extraction (the raw HTML is a JS app; WebFetch output was cross-checked against the DOM text and matched). Hardness column is headed **'nom'** (nominal hardness). Reference conditions: kc1 valid for a neutral insert, rake 0 deg (SV-SCF). Reference cutting speed/tool material: not stated. h range for mc: not stated. Source typos are kept and flagged in the Note column.

| MC code | Description | nom hardness | kc1 N/mm2 | mc | Note |
|---|---|---|---|---|---|
| P1.1.Z.AN | Steel, unalloyed (Mn<1.65) | unalloyed Mn<1.65 / 1 / <=0.25% C / forged/rolled/cold drawn / AN / annealed | 125 HB | 1500 | 0.25 |  |
| P1.1.Z.HT | Steel, unalloyed (Mn<1.65) | 1 / HT / hardened+tempered | 190 HB | 1770 | 0.25 |  |
| P1.2.Z.AN | Steel, unalloyed (Mn<1.65) | 2 / >0.25... <=0.55% C / forged/rolled/cold drawn / AN / annealed | 190 HB | 1700 | 0.25 |  |
| P1.2.Z.HT | Steel, unalloyed (Mn<1.65) | 2 / HT / hardened+tempered | 210 HB | 1820 | 0.25 |  |
| P1.3.Z.AN | Steel, unalloyed (Mn<1.65) | 3 / high carbon, >0.55% C / forged/rolled/cold drawn / AN / annealed | 190 HB | 1750 | 0.25 |  |
| P1.3.Z.HT | Steel, unalloyed (Mn<1.65) | 3 / HT / hardened+tempered | 300 HB | 2000 | 0.25 |  |
| P1.4.Z.AN | Steel, unalloyed (Mn<1.65) | 4 / free cutting steel / forged/rolled/cold drawn / AN / annealed | 220 HB | 1180 | 0.25 |  |
| P1.5.C.HT | Steel, unalloyed (Mn<1.65) | 5 / all carbon content (cast) / cast / HT / untreated | 150 HB | 1400 | 0.25 |  |
| P1.5.C.AN | Steel, unalloyed (Mn<1.65) | 5 / AN / hardened+tempered | 300 HB | 2880 | 0.25 |  |
| P2.1.Z.AN | Steel, low alloyed (<=5% alloying) | low alloyed (alloying elements <=5%) / 1 / <=0.25% C / forged/rolled/cold drawn / AN / annealed | 175 HB | 1700 | 0.25 |  |
| P2.2.Z.AN | Steel, low alloyed (<=5% alloying) | 2 / >0.25... <=0.55% C / AN | 240 HB | 1950 | 0.25 |  |
| P2.3.Z.AN | Steel, low alloyed (<=5% alloying) | 3 / high carbon, >0.55% C / AN | 260 HB | 2020 | 0.25 |  |
| P2.4.Z.AN | Steel, low alloyed (<=5% alloying) | 4 / free cutting steel / AN | 225 HB | - | - | No kc1 printed. |
| P2.5.Z.HT | Steel, low alloyed (<=5% alloying) | 5 / all carbon content (hard ended and tempered) / forged/rolled/cold drawn / HT / hardened+tempered | 330 HB | 2000 | 0.25 |  |
| P2.6.Z.UT | Steel, low alloyed (<=5% alloying) | 6 / all carbon content (cast) / cast / UT / untreated | 200 HB | 1600 | 0.25 |  |
| P2.6.Z.HT | Steel, low alloyed (<=5% alloying) | 6 / HT / hardened+tempered | 380 HB | 3200 | 0.25 |  |
| P3.0.Z.AN | Steel, high alloyed (>5%) | high alloyed (alloying elements >5%) / 0 / main group / forged/rolled/cold drawn / AN / annealed | 200 HB | 1950 | 0.25 |  |
| P3.0.Z.HT | Steel, high alloyed (>5%) | 0 / HT / hardened+tempered | 380 HB | 3100 | 0.25 |  |
| P3.0.C.UT | Steel, high alloyed (>5%) | 0 / cast / UT / untreated | 200 HB | 1950 | 0.25 |  |
| P3.0.C.HT | Steel, high alloyed (>5%) | 0 / HT / hardened+tempered | 340 HB | 3040 | 0.25 |  |
| P3.1.Z.AN | Steel, high alloyed (>5%) | 1 / HSS / forged/rolled/cold drawn / AN / annealed | 250 HB | 2360 | 0.25 |  |
| P3.2.C.AQ | Steel, high alloyed (>5%) | 2 / Manganese steel / cast / AQ / annealed/quenched or annealed | 300 HB | 3000 | 0.25 |  |
| P4.0.S.NS | Sintered steels | sintered steels / 0 / main group / sintered / NS / not specified | 150 HB | - | - | No kc1 printed. |
| P5.0.Z.AN | Stainless steel, ferritic/martensitic (incl. PH) | stainless steel ferritic/martensitic / 0 / main group / forged/rolled/cold/drawn / AN / annealed | 200 HB | 1800 | 0.21 |  |
| P5.0.Z.HT | Stainless steel, ferritic/martensitic (incl. PH) | 0 / HT / hardened+tempered | 330 HB | 2300 | 0.21 |  |
| P5.0.Z.PH | Stainless steel, ferritic/martensitic (incl. PH) | 0 / PH / precepitation hardened | 330 HB | 2800 | 0.21 |  |
| P5.0.C.UT | Stainless steel, ferritic/martensitic (incl. PH) | 0 / cast / UT / untreated | 250 HB | 1900 | 0.25 | Code printed 'P5.O.C.UT' (letter O) on source page; normalised to P5.0.C.UT. |
| P5.0.C.HT | Stainless steel, ferritic/martensitic (incl. PH) | 0 / HT / hardened+tempered | 330 HB | 2100 | - | Printed mc '.025' is an apparent typo (neighbouring cast-stainless rows are 0.25); NOT adopted - treat mc as missing. |
| P5.1.Z.AN | Stainless steel, ferritic/martensitic (incl. PH) | 1 / free cutting steel / forged/rolled/cold / AN / annealed | 200 HB | 1650 | 0.21 |  |
| M1.0.Z.AQ | Stainless, austenitic | austenitic / 0 / main group / forged/rolled/cold /drawn / AQ / annealed/quenched or annealed | 200 HB | 2000 | 0.21 |  |
| M1.0.Z.PH | Stainless, austenitic | 0 / PH / precepitation hardened | 300 HB | 2400 | 0.21 |  |
| M1.0.C.UT | Stainless, austenitic | 0 / cast / UT / untreated | 200 HB | 1800 | 0.25 |  |
| M1.1.Z.AQ | Stainless, austenitic | 1 / machinability improved (as SANMAC) / forged/rolled/cold/drawn / AQ / annealed/quenched or annealed | 200 HB | 2000 | 0.21 | Code M1.1.Z.AQ appears twice on the page (sub-group 1 'machinability improved (as SANMAC)' and sub-group 2 'free cutting steel'); the second is presumably M1.2 but is printed as M1.1. |
| M1.1.Z.AQ#2 | Stainless, austenitic | 2 / free cutting steel / AQ | 200 HB | 1800 | 0.21 | Code M1.1.Z.AQ appears twice on the page (sub-group 1 'machinability improved (as SANMAC)' and sub-group 2 'free cutting steel'); the second is presumably M1.2 but is printed as M1.1. |
| M1.3.Z.AQ | Stainless, austenitic | 3 / Ti-stabilized / AQ | 200 HB | 1800 | 0.21 |  |
| M1.3.C.AQ | Stainless, austenitic | 3 / cast / AQ | 200 HB | 1800 | 0.25 |  |
| M2.0.Z.AQ | Stainless, super-austenitic (Ni>=20%) | super-austenitic Ni>=20% / 0 / main group / forged/rolled/cold/drawn / AQ | 200 HB | 2300 | 0.21 |  |
| M2.0.C.AQ | Stainless, super-austenitic (Ni>=20%) | 0 / cast / AQ | 200 HB | 2150 | 0.25 | Hardness printed '200 B' (sic); read as 200 HB. |
| M3.1.Z.AQ | Stainless, duplex | duplex(austenitic/ferritic) / 1 / >60% ferrite (rule of thumb N<0.10%) / forged/rolled/cold/drawn / AQ / annealed/quenched or annealed | 230 HB | 2000 | 0.21 |  |
| M3.1.C.AQ | Stainless, duplex | 1 / cast / AQ | 230 HB | 1800 | 0.25 |  |
| M3.2.Z.AQ | Stainless, duplex | 2 / <60% ferrite (rule of thumb N>=0.10%) / forged/rolled/cold/drawn / AQ | 260 HB | 2400 | 0.21 |  |
| M3.2.C.AQ | Stainless, duplex | 2 / cast / AQ | 260 HB | 2200 | 0.25 |  |
| K1.1.C.NS | Cast iron, malleable | malleable / 1 / low tensile / cast / NS / not specified | 200 HB | 780 | 0.28 |  |
| K1.2.C.NS | Cast iron, malleable | 2 / high tensile / NS | 260 HB | 1020 | 0.28 |  |
| K2.1.C.UT | Cast iron, grey | grey / 1 / low tensile / cast / UT / untreated | 180 HB | 900 | 0.28 |  |
| K2.2.C.UT | Cast iron, grey | 2 / high tensile / UT | 245 HB | 1100 | 0.28 |  |
| K2.3.C.UT | Cast iron, grey | 3 / austenitic / UT | 175 HB | 1300 | 0.28 |  |
| K3.1.C.UT | Cast iron, nodular | nodular / 1 / ferritic / cast / UT / untreated | 155 HB | 870 | 0.28 |  |
| K3.2.C.UT | Cast iron, nodular | 2 / ferritic/perlitic / UT | 215 HB | 1200 | 0.28 |  |
| K3.3.C.UT | Cast iron, nodular | 3 / perlitic / UT | 265 HB | 1440 | 0.28 |  |
| K3.4.C.UT | Cast iron, nodular | 4 / martensitic / UT | 330 HB | 1650 | 0.28 |  |
| K3.5.C.UT | Cast iron, nodular | 5 / austenitic / UT | 190 HB | - | - | No kc1 printed. |
| K4.1.C.UT | Cast iron, CGI | CGI / 1 / low tensile (perlite <90%) / cast / UT / untreated | 160 HB | 680 | 0.43 |  |
| K4.2.C.UT | Cast iron, CGI | 2 / high tensile (perlite >=90%) / UT | 230 HB | 750 | 0.41 |  |
| K5.1.C.NS | Cast iron, ADI | ADI / 1 / low tensile / cast / NS / not specified | 300 HB | - | - | No kc1 printed. |
| K5.2.C.NS | Cast iron, ADI | 2 / high tensile / NS | 400 HB | - | - | No kc1 printed. |
| K5.3.C.NS | Cast iron, ADI | 3 / extra high tensile / NS | 460 HB | - | - | No kc1 printed. |
| N1.1.Z.UT | Aluminium alloys | aluminium based alloys / 1 / commerically pure / cast / UT / untreated | 30 HB | 350 | 0.25 |  |
| N1.2.Z.UT | Aluminium alloys | 2 / AlSi alloys, Si<=1% / UT | 60 HB | 400 | 0.25 |  |
| N1.2.Z.AG | Aluminium alloys | 2 / AG / aged | 100 HB | 650 | 0.25 |  |
| N1.2.S.UT | Aluminium alloys | 2 / sintered / UT / untreated | 75 HB | 410 | 0.25 |  |
| N1.2.C.NS | Aluminium alloys | 2 / cast / NS / not specified | 80 HB | 410 | 0.25 |  |
| N1.3.C.UT | Aluminium alloys | 3 / AlSi cast alloys, Si<=1% and <13% / UT / untreated | 75 HB | 600 | 0.25 |  |
| N1.3.C.AG | Aluminium alloys | 3 / AG / aged | 90 HB | 700 | 0.25 |  |
| N1.4.C.NS | Aluminium alloys | 4 / AlSi cast alloys, Si>=13% / NS / not specified | 130 HB | 700 | 0.25 |  |
| N2.0.C.UT | Magnesium alloys | magnesium based alloys / 0 / main group / cast / UT / untreated | 70 HB | - | - | No kc1 printed. |
| N3.1.U.UT | Copper alloys | copper based alloys / 1 / non-leaded copper alloys (incl. electrolytic copper) / not specified / UT / untreated | 100 HB | 1350 | 0.25 |  |
| N3.2.C.UT | Copper alloys | 2 / leaded brass & bronzes (Pb<=1%) / cast / UT | 90 HB | 550 | 0.25 |  |
| N3.3.S.UT | Copper alloys | 2 / sintered / UT | 35 HB | - | - | No kc1 printed. |
| N3.3.U.UT | Copper alloys | 3 / free cutting copper based alloys (Pb>1%) / notspecified / UT | 110 HB | 550 | 0.25 |  |
| N3.4.C.UT | Copper alloys | 4 / high strength bronzes (>225HB) / cast / UT | 300 HB | - | - | No kc1 printed. |
| N4.0.C.UT | Zinc alloys | zinc based alloys / 0 / m ain group / cast / UT / untreated | 70 HB | - | - | No kc1 printed. |
| S1.0.U.AN | HRSA iron-based | iron-based alloys / 1 / main group / not specified / AN / annealed | 200 HB | 2400 | 0.25 |  |
| S1.0.U.AG | HRSA iron-based | 2 / AG / aged | 280 HB | 2500 | 0.25 |  |
| S2.0.Z.AN | HRSA nickel-based | nickel based alloys / 0 / main group / forged/rolled/cold drawn / AN / annealed | 250 HB | 2650 | 0.25 |  |
| S2.0.Z.AG | HRSA nickel-based | 0 / AG / aged | 350 HB | 2900 | 0.25 |  |
| S2.0.Z.UT | HRSA nickel-based | 0 / UT / untreated | 275 HB | 2750 | 0.25 |  |
| S2.0.C.NS | HRSA nickel-based | 0 / cast / NS / not specified | 320 HB | 3000 | 0.25 |  |
| S3.0.Z.AN | HRSA cobalt-based | cobalt based alloys / 0 / main group / forged/rolled/cold drawn / AN / annealed | 200 HB | 2700 | 0.25 |  |
| S3.0.Z.AG | HRSA cobalt-based | 0 / AG / aged | 300 HB | 3000 | 0.25 |  |
| S3.0.C.NS | HRSA cobalt-based | 0 / cast / NS / not specified | 320 HB | 3100 | 0.25 |  |
| S4.1.Z.UT | Titanium alloys | titanium based alloys / 1 / commercially pure(>99.5% Ti) / forged/rolled/cold drawn / UT / untreated | 200 HB | 1300 | 0.23 |  |
| S4.2.Z.AN | Titanium alloys | 2 / alpha- and near alpha alloys / AN / annealed | 320 HB | 1400 | - | mc not printed. |
| S4.3.Z.AN | Titanium alloys | 3 / alpha/beta alloys / AN | 330 HB | 1400 | - | mc not printed. |
| S4.3.Z.AG | Titanium alloys | 3 / AG / aged | 375 HB | 1400 | - | mc not printed. |
| S4.4.Z.AN | Titanium alloys | 4 / beta alloys / AN / annealed | 330 HB | 1400 | - | mc not printed. |
| S4.4.Z.AG | Titanium alloys | 4 / AG / aged | 410 HB | 1400 | - | mc not printed. |
| S5.0.U.NS | Tungsten-based | tungsten based / 0 / main group / not specified / NS / not specified | 120 HB | - | - | No kc1 printed. |
| S6.0.U.NS | Molybdenum-based | molybdenum based / 0 / main group / not specified / NS / not specified | 200 HB | - | - | No kc1 printed. |
| H1.1.Z.HA | Hardened steel | steels (extra hard) / 1 / Hardness level 50 / forged/rolled/cold drown / HA / hardened (+tempered) | 50 HRc | 3090 | 0.25 |  |
| H1.2.Z.HA | Hardened steel | 2 / Hardness level 55 / HA | 55 HRc | 3690 | 0.25 |  |
| H1.3.Z.HA | Hardened steel | 3 / Hardness level 60 / HA | 60 HRc | 4330 | 0.25 |  |
| H1.4.Z.HA | Hardened steel | 4 / Hardness level 63 / HA | 63 HRc | 4750 | 0.25 |  |
| H2.0.C.UT | Chilled cast iron | chilled cast iron / 0 / main group / cast / UT / untreated | 55 HRc | 3450 | 0.28 |  |
| H3.0.C.UT | Stellites | stellites / 0 / main group / cast / UT / not specified | 40 HRc | - | - | No kc1 printed. |
| H4.0.S.AN | Ferro-TiC | Ferro-TiC / 0 / main group / s intered / AN / annealed | 67 HRc | - | - | No kc1 printed. |

Sandvik codes: process Z = forged/rolled/cold drawn, C = cast, S = sintered, U = not specified; heat treatment AN annealed, HT hardened+tempered, UT untreated, AQ annealed/quenched or annealed, AG aged, PH precipitation hardened, HA hardened, NS not specified. (From the table cells.)

### Sandvik rules quoted

* Rake: "The kc1 value is valid for a neutral insert with a rake angle, γ0, = 0°; other values must be considered to compensate for this. For example, if the rake angle is more positive than 0 degrees, the actual kc value will decrease." Formula image on the same page: **kc = kc1 x hm^(-mc) x (1 - γ0/100)**, i.e. 1% per degree of rake. Source: <https://www.sandvik.coromant.com/en-gb/knowledge/materials/specific-cutting-force>.
* Chip thickness: "If the actual chip thickness, hm, is, for example, 0.3 mm, the kc value will be higher" (consistent with kc = kc1 hm^-mc; no h validity range given).
* kc1 spread: "The kc1 value is different for the six material groups, and also varies within each group." Steel header on the materials page: "Specific cutting force kc1: 1400-3100 N/mm" (as printed).
* Hardness correction: **none published** on either page (searched page text for kc1/nom/correction/reference). Only the per-code nominal hardness is given.

## 3. Precipitation-hardening stainless (17-4 PH): where each source puts it

| Source | Row | Hardness / strength basis | kc1 | mc | Quote |
|---|---|---|---|---|---|
| SV | **P5.0.Z.PH** (ferritic/martensitic stainless, PH) | 330 HB | **2800** | **0.21** | `P5.0.Z.PH ¦ 5 ¦ 0 ¦ Z ¦ PH ¦ precepitation hardened ¦ 330 HB ¦ 2800 ¦ 0.21` |
| SV | M1.0.Z.PH (austenitic, PH) | 300 HB | 2400 | 0.21 | `M1.0.Z.PH ¦ 1 ¦ 0 ¦ Z ¦ PH ¦ precepitation hardened ¦ 300 HB ¦ 2400 ¦ 0.21` (¦ = table cell separator) |
| SV (bracketing) | P5.0.Z.AN / P5.0.Z.HT (ferritic/mart. annealed / hardened+tempered) | 200 / 330 HB | 1800 / 2300 | 0.21 / 0.21 | same table |
| WA | M2 'Stainless, austenitic steels, precipitation hardened (PH steels)' | Rm 700-1500 N/mm2 | 2400 | 0.21 | Walter has PH only as an austenitic M2 row |
| WA | P15 'Stainless ferritic/martensitic steels, heat-treated' | Rm 800-1400 N/mm2 | 2200 | 0.25 | closest Walter row to 17-4 by metallurgy |
| SE | no PH row; text only | - | - | - | "common pH hardened stainless steels such as 13-8, 15-5 and 17-4. When heat treated to a range of 32-42 HRc, these materials have a machining characteristic like common tool steel." (printed p.18, Stabilizer 2.0 tip 4). SMG 5/6 (4340, D2; 'Martensitic stainless steels' listed in their descriptions) are 1903 and 1999.5 N/mm2 (converted), mc 0.24; mapping is inference. |
| EU | no PH row; 'martensitische rostfreie Staehle' in group `< 900` Rm | Rm < 900 | 2500 | 0.27 | also X46Cr13/X30Cr13 1820/0.26 (Tabelle 2) |

So **only Sandvik explicitly lists a PH variant of the ferritic/martensitic stainless class (P5.0.Z.PH), and gives it the highest kc1 in the stainless block (2800 vs 2300 hardened+tempered and 1800 annealed)**. The Sandvik 'nom' 330 HB is roughly 35 HRc by the usual conversion (conversion is my note, not from the source), i.e. inside Seco's quoted 32-42 HRc working window. Other 17-4 conditions (H900 ~ 40+ HRc) are outside the stated 330 HB reference; Sandvik gives no hardness-correction rule, so any hardness scaling would be a ToolWiz modelling decision, not a sourced one.

## 4. Second-source tables, with reference conditions

### 4.1 Walter Technical Compendium 2024 (WA-TC), printed p.F9 (PDF p.11)

<https://cdn.walter-tools.com/files/sitecollectiondocuments/downloads/global/manuals/en-gb/technical-compendium-general-2024-en.pdf>. Source comment (quoted): "The information consists of standard values and refers to a neutral cutting edge geometry. The condition of the material and the cutting edge geometry considerably influences the cutting forces." Hardness basis: Rm range (N/mm2) only for steels/stainless/cast iron. No stated speed/tool or h range.

| Walter group | Description | Rm min-max | kc1.1 | mc |
|---|---|---|---|---|
| P1, P6 | Non-alloyed and low-alloy steels, C > 0.25%, low and medium tensile strength | 350-750 | 1500 | 0.21 |
| P2, P3, P4, P7, P14 | Non-alloyed and low-alloy steels, C > 0.55%, not heat-treated | 400-900 | 1700 | 0.25 |
| P5, P8, P11, P12 | Low and high-alloy steels, low heat treatment level | 750-1100 | 2000 | 0.25 |
| P15 | Stainless ferritic/martensitic steels, heat-treated | 800-1400 | 2200 | 0.25 |
| P9 | Low and high-alloy steels, medium heat treatment level | 1100-1400 | 2500 | 0.25 |
| P10, P13 | Low and high-alloy steels, high heat treatment level | 1200-1600 | 3000 | 0.25 |
| M1 | Stainless, austenitic steels | 400-900 | 1800 | 0.21 |
| M3 | Stainless, austenitic/ferritic steels + duplex | 600-1000 | 2000 | 0.21 |
| M2 | Stainless, austenitic steels, precipitation hardened (PH steels) | 700-1500 | 2400 | 0.21 |
| K1, K3, K7 | Grey cast iron + CGI + malleable cast iron with low tensile strength | 200-400 | 800 | 0.28 |
| K2, K5 | Ductile cast iron with low tensile strength + malleable cast iron with higher tensile strength | 400-600 | 950 | 0.28 |
| K4 | Grey cast iron with higher tensile strength | 300-400 | 1200 | 0.28 |
| K6 | Ductile cast iron with high tensile strength + ADI with high tensile strength, non-alloyed + alloyed | 600-800 | 1400 | 0.28 |
| N1 | Wrought aluminium alloy, not hardened | no Rm / hardness given | 350 | 0.25 |
| N2 | Wrought aluminium alloy, hardened | no Rm / hardness given | 600 | 0.25 |
| N3 | Cast aluminium alloy < 12% Si, not hardened | no Rm / hardness given | 600 | 0.25 |
| N4, N5 | Cast aluminium alloy < 12% Si, hardened, cast aluminium alloy >= 12% | no Rm / hardness given | 700 | 0.25 |
| N7, N8, N9 | Pure copper, copper alloy (brass, bronze) with low tensile strength | no Rm / hardness given | 550 | 0.25 |
| N10 | High tensile copper alloys, bronze with high tensile strength | no Rm / hardness given | 1000 | 0.25 |
| S1 | Heat-resistant alloys, iron-based, annealed | no Rm / hardness given | 2400 | 0.25 |
| S2 | Heat-resistant alloys, iron-based, hardened | no Rm / hardness given | 2500 | 0.25 |
| S6 | Pure titanium | no Rm / hardness given | 1300 | 0.25 |
| S7, S8 | Titanium alloys, alpha, alpha/beta and beta alloys | no Rm / hardness given | 1500 | 0.25 |
| S3 | Heat-resistant alloys, nickel-cobalt-based, annealed | no Rm / hardness given | 2800 | 0.25 |
| S4 | Heat-resistant alloys, nickel-cobalt-based, hardened | no Rm / hardness given | 2900 | 0.25 |
| S5 | Heat-resistant alloys, nickel-cobalt-based, cast | no Rm / hardness given | 3000 | 0.25 |
| H1 | Hardened steels 46-52 HRC | 46-52 HRC | 3000 | 0.25 |
| H2 | Hardened steels 52-58 HRC | 52-58 HRC | 3700 | 0.25 |
| H3 | Hardened steels 58-62 HRC | 58-62 HRC | 4300 | 0.25 |
| H4 | Hardened cast iron 50-60 HRC | 50-60 HRC | 3500 | 0.25 |
| O1, O2 | Thermoplasts and thermosetting plastics, without abrasive fillers | no Rm / hardness given | 150 | 0.20 |
| O3, O4, O5 | Fibre-reinforced plastics | no Rm / hardness given | 300 | 0.30 |
| O6 | Graphite | no Rm / hardness given | 400 | 0.25 |

### 4.2 Seco Material Groups (SE-NC), Niagara Cutter Solid Round Tooling Technical Guide, printed p.15 (PDF p.17)

<https://www.stoughtoolsales.com/Seco-Literature/Solid-Round-Tooling-Catalog-Technical-Guide.pdf> (file is a Niagara Cutter / Seco catalogue). kc1.1 is printed in **x 1000 lbf/in2**; the N/mm2 column is converted (x 6.894757) and flagged DERIVED. Rake: "kc.1-values with 0 degree effective cutting rake angle. For other rake angles, reduce the kc1.1-value by 1% for every degree increase in the cutting rake angle and vice versa." BHN "is only an aid in the selection of the material group". The ISO letter column is as printed (SMG 7 shown under H; M rows have no BHN).

| SMG (ISO) | Representative material / description | BHN | kc1.1 printed (ksi) | kc1.1 N/mm2 DERIVED | mc |
|---|---|---|---|---|---|
| SMG 1 (ISO P) | 1010 | Very soft carbon steels / Purely ferritic steels | <135 | 196 | 1351.4 | 0.21 |
| SMG 2 (ISO P) | 1140 | Free-cutting steels | 120 < 210 | 218 | 1503.1 | 0.22 |
| SMG 3 (ISO P) | 1045 | Structural steels. Ordinary carbon steels with low to medium carbon content (<0,5%C) | 135 < 165 | 218 | 1503.1 | 0.25 |
| SMG 4 (ISO P) | 4140 | Carbon steels with high carbon content (>0,5%C) / Medium hard steels for toughening / Ordinary low-alloy steels / Ferritic and martensitic stainless steels | 165 < 210 | 247 | 1703.0 | 0.24 |
| SMG 5 (ISO P) | 4340 | Normal tool steels / Harder steels for toughening / Martensitic stainless steels | 210 < 270 | 276 | 1903.0 | 0.24 |
| SMG 6 (ISO P) | D2 | Difficult tool steels / High-alloy steels with high hardness / Martensitic stainless steels | 270 < 360 | 290 | 1999.5 | 0.24 |
| SMG 7 (ISO H) | A128 Grade A | Difficult high-strength steels with 42 to 56 HRc hardness / Hardened steels from material group 3-6 / Martensitic stainless steels | > 360 | 421 | 2902.7 | 0.22 |
| SMG 8 (ISO M) | 304 | Easy-cutting stainless steels / Free-cutting stainless steels / Calcium-treated stainless steels | not given | 254 | 1751.3 | 0.22 |
| SMG 9 (ISO M) | 316 | Moderately difficult stainless steels / Austenitic and duplex stainless steels | not given | 276 | 1903.0 | 0.20 |
| SMG 10 (ISO M) | 310 | Difficult stainless steels / Austenitic and duplex stainless steels | not given | 297 | 2047.7 | 0.20 |
| SMG 11 (ISO M) | 330 | Very difficult stainless steels / Austenitic and duplex stainless steels | not given | 312 | 2151.2 | 0.20 |
| SMG 12 (ISO K) | 60-40-18 | Medium hard cast iron / Grey cast iron | not given | 167 | 1151.4 | 0.22 |
| SMG 13 (ISO K) | A536 80-55-06 | Low-alloy cast iron / Malleable cast iron / Nodular cast iron | not given | 178 | 1227.3 | 0.25 |
| SMG 14 (ISO K) | A536 100-70-03 | Moderately difficult alloy cast iron / Moderately difficult malleable cast iron / Nodular cast iron | not given | 196 | 1351.4 | 0.28 |
| SMG 15 (ISO K) | A536 120-90-02 | Difficult high-alloy cast iron / Difficult malleable cast iron / Nodular cast iron | not given | 213 | 1468.6 | 0.30 |
| SMG 16 (ISO N) | A380 | Aluminum alloys: Low Si | not given | 101 | 696.4 | 0.25 |
| SMG 17 (ISO N) | B390.0 | Aluminum alloys: High Si | not given | 101 | 696.4 | 0.27 |
| SMG 18 (ISO N) | CA937 | Copper alloys | not given | - | - | - |
| SMG 19 (ISO S) | Discalloy | Fe-based superalloys | not given | - | - | - |
| SMG 20 (ISO S) | Stellite 21 | Co-based superalloys | not given | 377 | 2599.3 | 0.24 |
| SMG 21 (ISO S) | Inconel 718 (bar, forge, ring) | Ni-based superalloys | not given | 479 | 3302.6 | 0.24 |
| SMG 22 (ISO S) | Ti6Al-4V (annealed) | Titanium alloys | not given | 210 | 1447.9 | 0.23 |

### 4.3 Europa Tabellenbuch fuer Zerspantechnik, 1. Aufl. (EU-TB)

<https://www.newbooks-services.de/MediaFiles/Texts/3/9783808514733_Excerpt_004.pdf> (publisher excerpt, Europa-Nr. 14733). Values are "fuer das Drehen ermittelte kc-Richtwerte (nach Kienzle und Koenig)", tabulated k for h = 0.06 ... 1.60 mm (so mc is anchored to that range). **Base rake gamma0 = +6 deg for steel, +2 deg for cast iron**; correction Kγ = 1 - (γ - γ0)/100; Kvc = 1.0 for carbide at 60-300 m/min; Kver = 1.2-1.5 for tool wear; Ksp 1.0 (OD turning) to 1.3 (parting). Also 'kc ≈ (4 bis 6) · Rm'. Pages: p.207 (group approximations), p.208 (correction factors), p.209 Tabelle 1, p.210 Tabelle 2.

Approximation table by Zerspanungshauptgruppe (printed p.207):

| ISO band | Description (German, ae/ue/oe transliterated) | Rm N/mm2 | kc1.1 | mc |
|---|---|---|---|---|
| P | Unlegierte, weiche Baustaehle mit niedrigem Kohlenstoffgehalt | < 450 | 1800 | 0.20 |
| P | Unlegierte Staehle mit geringem bis mittlerem Kohlenstoffgehalt, C < 0,5 % Einsatzstaehle, Verguetungsstaehle, Automatenstaehle | < 550 | 2000 | 0.20 |
| P | Niedrig legierte Staehle mit geringem bis mittlerem Kohlenstoffgehalt, Einsatzstaehle, Verguetungsstaehle, Stahlguss, ferritische rostfreie Staehle, Nitrierstahl | < 700 | 2200 | 0.24 |
| P | Normalharte Werkzeugstaehle, Kaltarbeitsstaehle, haertere Verguetungsstaehle, martensitische rostfreie Staehle | < 900 | 2500 | 0.27 |
| P | Schwer zerspanbare Werkzeugstaehle, hochlegierte Staehle, harter Stahlguss | < 1200 | 2750 | 0.25 |
| P | Hochfeste Staehle, gehaertete Staehle, schwer zerspanbare Staehle | > 1200 | 2850 | 0.23 |
| M | Gut bearbeitbare rostfreie Staehle | not given | 1800 | 0.24 |
| M | Austenitische rostfreie Staehle | not given | 2000 | 0.20 |
| K | Grauguss, GJL | not given | 1050 | 0.23 |
| K | Kugelgraphitguss, GJS, Temperguss, Niedrig legierter Guss | not given | 1150 | 0.25 |
| K | Gusseisen mittlerer Haerte, Temperguss, Niedrig legierter Guss | not given | 1500 | 0.28 |
| K | Hoeher legierter Guss, Temperguss, schwer zerspanbar | not given | 1900 | 0.19 |
| N | Gut zerspanbare NE-Legierungen, Aluminium, Magnesium, Messing | not given | 470 | 0.27 |
| N | Aluminiumlegierungen mit hohem Si-Anteil (> 16 % Si) | not given | 680 | 0.27 |
| S | Nickel-, Kobalt-Eisenlegierungen, Warmfeste Staehle, Haerte < 30 HRC | not given | 2500 | 0.22 |
| S | Nickel-, Kobalt-Eisenlegierungen, Warmfeste Staehle, Haerte > 30 HRC | not given | 3200 | 0.24 |
| S | Titanlegierungen | not given | 1400 | 0.22 |

Named alloys (Tabelle 1 p.209, Tabelle 2 p.210) - stainless, superalloy, titanium and key steels shown here; the remaining rows are in the JSON:

| Material | kc1.1 | mc | Table |
|---|---|---|---|
| 16MnCr5 | 2100 | 0.26 | Tabelle 1 |
| C45 | 1680 | 0.26 | Tabelle 1 |
| C45E | 1850 | 0.14 | Tabelle 1 |
| 34CrMo4 | 2240 | 0.21 | Tabelle 1 |
| 42CrMo4 | 2500 | 0.26 | Tabelle 1 |
| 100Cr6 | 1410 | 0.39 | Tabelle 1 |
| X210Cr12 | 1820 | 0.26 | Tabelle 1 |
| 90MnCrV | 2300 | 0.21 | Tabelle 1 |
| X46Cr13 | 1820 | 0.26 | Tabelle 2 |
| X30Cr13 | 1820 | 0.26 | Tabelle 2 |
| NiCr20TiAl | 2088 | 0.29 | Tabelle 2 |
| X5CrNi18-10 | 2350 | 0.21 | Tabelle 2 |
| X10CrNiMo18-10 | 2550 | 0.18 | Tabelle 2 |
| X5CrNiMo17-12-2 | 2600 | 0.19 | Tabelle 2 |
| GJS-600 | 1480 | 0.17 | Tabelle 2 |
| GJL-250 | 1160 | 0.26 | Tabelle 2 |
| TiAl6V4 | 1370 | 0.21 | Tabelle 2 |

### 4.4 Westermann, Fertigen mit Werkzeugmaschinen, p.143 (WE-FW)

<https://c.wgr.de/f/pdf/978-3-14-235025-7-1-l.pdf>. Stated conditions (quoted): "Die Werte wurden im Drehversuch ermittelt und gelten u.a. fuer folgende Bedingungen: HM-Werkzeug, vc = 100...120 m/min, α0 = 5°, γ0 = 6° fuer langspanende Werkstoffe, γ0 = 2° fuer kurzspanende Werkstoffe, κr = 60°." h range tabulated: 0.05-2.5 mm. kc1.1 is the column h = 1.0 marked 'kc 1.1'. 'Nichtrostende Staehle' (generic stainless): **2550, mc 0.18**. The page also prints a vc correction factor K (1.25 for vc > 10...30, 1.1 for > 30...80, 1.0 for > 80 m/min). The page contains typos (EN-GJL-200 kc1.1 '120'; 'Al-Sn' row duplicating S 235 JR); those rows are excluded. Westermann C 45 E (2220/0.14) disagrees with Europa C45E (1850/0.14) - same mc, different kc1.1 - so textbook lineages are not mutually consistent either.

### 4.5 Iscar (IS-UG), p.57 worked example only

Annealed H13 (1.2344): kc1 = 2450 N/mm2, mc = 0.23, example rake 10 deg, Eq. 8.7 kc = kc1 x hm^(-mc) x (1 - γ/100). "kc1 relates to cutting material with a tool bearing a zero rake angle." Read via WebFetch summary only (lower confidence). No table.

### 4.6 Reference-condition summary

| Source | Rake basis | Speed / tool basis | h range for mc | Hardness basis |
|---|---|---|---|---|
| SV | 0 deg (neutral insert) | not stated | not stated | nominal HB (HRc for H) per code; no correction rule |
| SE | 0 deg; 1%/deg | not stated | not stated | BHN band as selection aid |
| WA | 'neutral cutting edge geometry' | not stated | not stated | Rm band |
| EU | +6 deg steel / +2 deg cast iron; Kγ = 1-(γ-γ0)/100 | HM 60-300 m/min Kvc = 1.0 | 0.06-1.60 mm (table) | none (alloy names) |
| WE | +6 deg long-chip / +2 deg short-chip, α0 5 deg, κr 60 deg | HM, vc 100-120 m/min | 0.05-2.5 mm (table) | none |
| IS | 0 deg; 1%/deg | not stated | not stated | none |

## 5. Sandvik vs second sources: ratios (DERIVED)

Ratio R = (other kc1.1) / (Sandvik kc1). Pairings are by metallurgical description and nominal hardness; they are my judgement calls and are listed so each can be challenged. Hardness bases differ (Sandvik 'nom' HB vs Walter Rm vs Seco BHN band), so ratios near 0.9-1.1 are within pairing uncertainty.

**Walter** (n = 30 pairs; median R = 1.000, min 0.741, max 1.091)

| Sandvik code (nom, kc1 / mc) | Other | Other kc1.1 / mc | R |
|---|---|---|---|
| P1.1.Z.AN (125 HB; 1500 / 0.25) | Walter P1, P6 | 1500 / 0.21 | 1.000 |
| P1.2.Z.AN (190 HB; 1700 / 0.25) | Walter P1, P6 | 1500 / 0.21 | 0.882 |
| P1.3.Z.AN (190 HB; 1750 / 0.25) | Walter P2, P3, P4, P7, P14 | 1700 / 0.25 | 0.971 |
| P2.5.Z.HT (330 HB; 2000 / 0.25) | Walter P5, P8, P11, P12 | 2000 / 0.25 | 1.000 |
| P3.0.Z.HT (380 HB; 3100 / 0.25) | Walter P10, P13 | 3000 / 0.25 | 0.968 |
| P5.0.Z.HT (330 HB; 2300 / 0.21) | Walter P15 | 2200 / 0.25 | 0.957 |
| M1.0.Z.AQ (200 HB; 2000 / 0.21) | Walter M1 | 1800 / 0.21 | 0.900 |
| M3.1.Z.AQ (230 HB; 2000 / 0.21) | Walter M3 | 2000 / 0.21 | 1.000 |
| M3.2.Z.AQ (260 HB; 2400 / 0.21) | Walter M3 | 2000 / 0.21 | 0.833 |
| M1.0.Z.PH (300 HB; 2400 / 0.21) | Walter M2 | 2400 / 0.21 | 1.000 |
| K2.1.C.UT (180 HB; 900 / 0.28) | Walter K1, K3, K7 | 800 / 0.28 | 0.889 |
| K2.2.C.UT (245 HB; 1100 / 0.28) | Walter K4 | 1200 / 0.28 | 1.091 |
| K3.2.C.UT (215 HB; 1200 / 0.28) | Walter K2, K5 | 950 / 0.28 | 0.792 |
| K3.3.C.UT (265 HB; 1440 / 0.28) | Walter K6 | 1400 / 0.28 | 0.972 |
| N1.1.Z.UT (30 HB; 350 / 0.25) | Walter N1 | 350 / 0.25 | 1.000 |
| N1.3.C.UT (75 HB; 600 / 0.25) | Walter N3 | 600 / 0.25 | 1.000 |
| N1.3.C.AG (90 HB; 700 / 0.25) | Walter N4, N5 | 700 / 0.25 | 1.000 |
| N3.2.C.UT (90 HB; 550 / 0.25) | Walter N7, N8, N9 | 550 / 0.25 | 1.000 |
| N3.1.U.UT (100 HB; 1350 / 0.25) | Walter N10 | 1000 / 0.25 | 0.741 |
| S1.0.U.AN (200 HB; 2400 / 0.25) | Walter S1 | 2400 / 0.25 | 1.000 |
| S1.0.U.AG (280 HB; 2500 / 0.25) | Walter S2 | 2500 / 0.25 | 1.000 |
| S2.0.Z.AN (250 HB; 2650 / 0.25) | Walter S3 | 2800 / 0.25 | 1.057 |
| S2.0.Z.AG (350 HB; 2900 / 0.25) | Walter S4 | 2900 / 0.25 | 1.000 |
| S2.0.C.NS (320 HB; 3000 / 0.25) | Walter S5 | 3000 / 0.25 | 1.000 |
| S4.1.Z.UT (200 HB; 1300 / 0.23) | Walter S6 | 1300 / 0.25 | 1.000 |
| S4.3.Z.AN (330 HB; 1400 / -) | Walter S7, S8 | 1500 / 0.25 | 1.071 |
| H1.1.Z.HA (50 HRc; 3090 / 0.25) | Walter H1 | 3000 / 0.25 | 0.971 |
| H1.2.Z.HA (55 HRc; 3690 / 0.25) | Walter H2 | 3700 / 0.25 | 1.003 |
| H1.3.Z.HA (60 HRc; 4330 / 0.25) | Walter H3 | 4300 / 0.25 | 0.993 |
| H2.0.C.UT (55 HRc; 3450 / 0.28) | Walter H4 | 3500 / 0.25 | 1.014 |

**Seco** (n = 12 pairs; median R = 0.969, min 0.876, max 1.139)

| Sandvik code (nom, kc1 / mc) | Other | Other kc1.1 / mc | R |
|---|---|---|---|
| P1.1.Z.AN (125 HB; 1500 / 0.25) | SMG 1 (ISO P) | 1351 / 0.21 | 0.901 |
| P2.1.Z.AN (175 HB; 1700 / 0.25) | SMG 4 (ISO P) | 1703 / 0.24 | 1.002 |
| P2.2.Z.AN (240 HB; 1950 / 0.25) | SMG 5 (ISO P) | 1903 / 0.24 | 0.976 |
| P2.5.Z.HT (330 HB; 2000 / 0.25) | SMG 6 (ISO P) | 2000 / 0.24 | 1.000 |
| H1.1.Z.HA (50 HRc; 3090 / 0.25) | SMG 7 (ISO H) | 2903 / 0.22 | 0.939 |
| M1.0.Z.AQ (200 HB; 2000 / 0.21) | SMG 9 (ISO M) | 1903 / 0.20 | 0.952 |
| M1.0.Z.AQ (200 HB; 2000 / 0.21) | SMG 8 (ISO M) | 1751 / 0.22 | 0.876 |
| M2.0.Z.AQ (200 HB; 2300 / 0.21) | SMG 10 (ISO M) | 2048 / 0.20 | 0.890 |
| N1.3.C.AG (90 HB; 700 / 0.25) | SMG 16 (ISO N) | 696 / 0.25 | 0.995 |
| S3.0.Z.AN (200 HB; 2700 / 0.25) | SMG 20 (ISO S) | 2599 / 0.24 | 0.963 |
| S2.0.Z.AG (350 HB; 2900 / 0.25) | SMG 21 (ISO S) | 3303 / 0.24 | 1.139 |
| S4.3.Z.AN (330 HB; 1400 / -) | SMG 22 (ISO S) | 1448 / 0.23 | 1.034 |

**Europa app.** (n = 9 pairs; median R = 1.000, min 0.943, max 1.200)

| Sandvik code (nom, kc1 / mc) | Other | Other kc1.1 / mc | R |
|---|---|---|---|
| P1.1.Z.AN (125 HB; 1500 / 0.25) | Zerspanungshauptgruppe P#0 | 1800 / 0.20 | 1.200 |
| P5.0.Z.HT (330 HB; 2300 / 0.21) | Zerspanungshauptgruppe P#3 | 2500 / 0.27 | 1.087 |
| M1.0.Z.AQ (200 HB; 2000 / 0.21) | Zerspanungshauptgruppe M#1 | 2000 / 0.20 | 1.000 |
| M1.1.Z.AQ#2 (200 HB; 1800 / 0.21) | Zerspanungshauptgruppe M#0 | 1800 / 0.24 | 1.000 |
| S2.0.Z.AN (250 HB; 2650 / 0.25) | Zerspanungshauptgruppe S#0 | 2500 / 0.22 | 0.943 |
| S2.0.Z.AG (350 HB; 2900 / 0.25) | Zerspanungshauptgruppe S#1 | 3200 / 0.24 | 1.103 |
| S4.3.Z.AN (330 HB; 1400 / -) | Zerspanungshauptgruppe S#2 | 1400 / 0.22 | 1.000 |
| N1.4.C.NS (130 HB; 700 / 0.25) | Zerspanungshauptgruppe N#1 | 680 / 0.27 | 0.971 |
| K2.1.C.UT (180 HB; 900 / 0.28) | Zerspanungshauptgruppe K#0 | 1050 / 0.23 | 1.167 |

**Europa T1/T2** (n = 10 pairs; median R = 1.019, min 0.788, max 1.300)

| Sandvik code (nom, kc1 / mc) | Other | Other kc1.1 / mc | R |
|---|---|---|---|
| P5.0.Z.AN (200 HB; 1800 / 0.21) | X46Cr13 | 1820 / 0.26 | 1.011 |
| P5.0.Z.AN (200 HB; 1800 / 0.21) | X30Cr13 | 1820 / 0.26 | 1.011 |
| M1.0.Z.AQ (200 HB; 2000 / 0.21) | X5CrNi18-10 | 2350 / 0.21 | 1.175 |
| M1.0.Z.AQ (200 HB; 2000 / 0.21) | X5CrNiMo17-12-2 | 2600 / 0.19 | 1.300 |
| S2.0.Z.AN (250 HB; 2650 / 0.25) | NiCr20TiAl | 2088 / 0.29 | 0.788 |
| S4.3.Z.AN (330 HB; 1400 / -) | TiAl6V4 | 1370 / 0.21 | 0.979 |
| K2.2.C.UT (245 HB; 1100 / 0.28) | GJL-250 | 1160 / 0.26 | 1.055 |
| K3.3.C.UT (265 HB; 1440 / 0.28) | GJS-600 | 1480 / 0.17 | 1.028 |
| P1.2.Z.AN (190 HB; 1700 / 0.25) | C45 | 1680 / 0.26 | 0.988 |
| P2.1.Z.AN (175 HB; 1700 / 0.25) | 16MnCr5 | 2100 / 0.26 | 1.235 |

**Westermann** (n = 4 pairs; median R = 1.255, min 1.055, max 1.306)

| Sandvik code (nom, kc1 / mc) | Other | Other kc1.1 / mc | R |
|---|---|---|---|
| M1.0.Z.AQ (200 HB; 2000 / 0.21) | Nichtrostende Staehle | 2550 / 0.18 | 1.275 |
| P1.2.Z.AN (190 HB; 1700 / 0.25) | C 45 E | 2220 / 0.14 | 1.306 |
| P2.1.Z.AN (175 HB; 1700 / 0.25) | 16 Mn Cr 6 | 2100 / 0.26 | 1.235 |
| K2.2.C.UT (245 HB; 1100 / 0.28) | EN-GJL-250 | 1160 / 0.26 | 1.055 |

Reading: Walter (n=30) median 1.00, but largely identical to Sandvik for N/S/H, so it validates little there. Seco (n=12) median 0.97 with true independence; the largest deviation is Inconel 718 (SMG 21, R = 1.14, Seco's single nickel row vs Sandvik aged 350 HB) and SMG 8/austenitic (0.88). Europa/Westermann run 1.0-1.3 high for steels and austenitic stainless. Their base rake is +6 deg, so a printed value corresponds to kc0 x 0.94; their 0-deg-equivalent is therefore about 6% higher still, which widens the gap against Sandvik/Seco rather than closing it. This is a basis difference, not a reconciliation.

Implied kc(h) for the stainless candidates (DERIVED, kc1 h^-mc, no rake/hardness corrections applied; Europa value at its +6 deg basis):

| Row | kc1 / mc | kc(0.05) | kc(0.1) | kc(0.2) |
|---|---|---|---|---|
| SV P5.0.Z.PH | 2800 / 0.21 | 5253 | 4541 | 3926 |
| SV P5.0.Z.HT | 2300 / 0.21 | 4315 | 3730 | 3225 |
| SV M1.0.Z.PH | 2400 / 0.21 | 4502 | 3892 | 3365 |
| SV M1.0.Z.AQ | 2000 / 0.21 | 3752 | 3244 | 2804 |
| WA P15 ferritic/martensitic HT | 2200 / 0.25 | 4652 | 3912 | 3290 |
| WA M2 PH (austenitic) | 2400 / 0.21 | 4502 | 3892 | 3365 |
| EU X46Cr13 (6 deg basis) | 1820 / 0.26 | 3966 | 3312 | 2766 |
| EU X5CrNi18-10 (6 deg basis) | 2350 / 0.21 | 4408 | 3811 | 3295 |
| SE SMG 6 (D2, 'martensitic stainless') | 1999.5 / 0.24 | 4104 | 3475 | 2942 |

## 6. Gaps

* **Sandvik rows with no kc1** (14): P2.4.Z.AN (low-alloy free-cutting), P4.0.S.NS (sintered steel), K3.5.C.UT (austenitic nodular), K5.1/5.2/5.3 (ADI), N2.0.C.UT (Mg), N3.3.S.UT, N3.4.C.UT (high-strength bronze), N4.0.C.UT (Zn), S5.0.U.NS (W), S6.0.U.NS (Mo), H3.0.C.UT (stellite), H4.0.S.AN (Ferro-TiC). Sandvik has no ADI, magnesium, zinc, tungsten, molybdenum values.
* **Sandvik rows with kc1 but no mc** (6): P5.0.C.HT (mc printed '.025', apparent typo, not adopted), S4.2.Z.AN, S4.3.Z.AN, S4.3.Z.AG, S4.4.Z.AN, S4.4.Z.AG (all titanium alloys except pure Ti S4.1.Z.UT 0.23). Cross-source mc for Ti alloys: Walter 0.25, Europa TiAl6V4 0.21 / group 0.22, Seco Ti6Al-4V 0.23 - these are other sources' values, not Sandvik's.
* **Sandvik duplicate code**: M1.1.Z.AQ appears twice (SANMAC 2000 vs free-cutting 1800); the second is presumably M1.2 but is not labelled so. Recorded as `M1.1.Z.AQ#2`.
* **Old CMC code system**: no kc1/mc table with CMC numbers (01.1, 05.21 ...) was found in accessible Sandvik documents. The Milling Technical Guide (D22-D25) has the formula kc = kc1 x hm^-mc but no table; its 'Constant K' power table is a different quantity.
* **Hardness correction**: not published by Sandvik, Seco, Walter or Europa in any accessible page. Seco's footnote warns the BHN is only a selection aid for worked material. For 17-4 PH in conditions other than 330 HB (e.g. H900, H1150), no source gives a kc1 correction.
* **Not covered by any source here**: 17-4 PH by name (only class rows); Sandvik gives no h range; Seco/Walter/Sandvik give no reference vc or tool material for kc1.
* **Kennametal**: no kc1/mc table in the 4010 Turning Master Catalog text (grepped 'kc', 'specific cutting force', 'Kienzle', 'unit power'). Kennametal's published power model appears to use a unit-power constant instead; not pursued. Gap.
* **Walter/Seco gaps**: Seco SMG 18 (copper) and 19 (Fe-based superalloys) have no values; Seco has no PH row.

## 7. Per-source coverage

| Source | Rows | Rows with kc1 and mc | Notes |
|---|---|---|---|
| SV-WEB (Sandvik MC codes) | 96 | 76 (82 with kc1) | P 23, stainless 20, K 15, N 15, S 16, H 7 |
| SE-NC (Seco SMG) | 22 | 20 | ksi converted; no PH |
| WA-TC (Walter) | 33 | 33 | Rm bands; PH only as austenitic M2 |
| EU-TB (Europa) | 17 group rows + 57 alloys = 74 | 74 | +6 deg basis |
| WE-FW (Westermann) | 21 | 21 | +6 deg basis; typos |
| IS-UG (Iscar) | 1 | 1 | lower confidence |

## 8. Files and provenance

* Machine-readable: `data/kc_mc_sources.json` (251 records including 4 rule/note records).
* Source documents were read in the research session's scratch folder and are not kept in the repo; each record carries its URL and page. Tables whose pdftotext layout was scrambled (Seco p.15, Walter p.F9, Europa pp.207-210, Westermann p.143) were read from rendered page images and checked against the text layer.
