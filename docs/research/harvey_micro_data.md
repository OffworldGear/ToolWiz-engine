# Harvey Tool published data for micro end mills (research, 2026-10-15)

## How the data was collected

- **Source:** Harvey Speeds & Feeds sheets linked from the tool pages.
- **Reading method:** cells were read from rendered pages and pdftotext. Steel values were cross-checked against the text; the aluminum values come from the page image only.
- **Use:** calibration and validation data for the v2 model (`docs/PHYSICS_MODEL_DESIGN.md`), not model inputs.

## Caveats printed on the sheets

- The values are suggested starting values that may be increased.
- Chip loads are for uncoated cutters. Coated cutters may run 10–20% higher.
- Ferrous materials at 28 HRC or softer may also run 10–20% higher.
- The lowest steel hardness column is 29–37 HRC.

## Data compared with ToolWiz v1

ToolWiz v1 settings for this comparison: 1/8" shank, 3×D stickout, aggressiveness 50%, no spindle cap.

| Case | Harvey sheet and cells | SFM | Chip load (in/tooth) | Feed (no RPM cap) | Axial × radial depth | ToolWiz v1 |
|---|---|---|---|---|---|---|
| 1/32" 3FL uncoated, 6061, roughing | SF_47800 (3× reach, stub flute), wrought Al, Roughing, 0.031" column. Tool #47831 | 1000 | 0.00053 (slot 0.00042) | 122,230 RPM / ~194 IPM | 0.45D × 0.33D | (not compared; ToolWiz is below Harvey here) |
| 1/16" 4FL, H13 tool steel, roughing | SF_73000 (4FL stub/std), tool steels D/H/M/T/S, 29–37 HRC, Roughing, 0.062" column | 150 | 0.00010 (+10–20% coated or soft: ~0.00012) | 9,167 RPM / 3.7–4.4 IPM | 3D (0.1875") × 0.13D (0.0081") | 240 SFM, 0.00054, 31.7 IPM, 0.0125" × 0.0156" |
| 1/16" 2FL, 4140, slot | SF_72000 (2FL), carbon steels 1030–1095 / 4xxx, 29–37 HRC, Slotting, 0.062" column | 200 | 0.00021 (+10–20%: ~0.00025) | 12,223 RPM / 5.1–6.2 IPM | 0.14D (0.0088") × full width | 274 SFM, 0.00036, 12.1 IPM, 0.0106" deep |
| 3/32" 4FL, 4140, roughing | SF_73000, carbon steels, 29–37 HRC, Roughing, 0.093" column | 200 | 0.00023 (+10–20%: ~0.00027) | 8,149 RPM / 7.5–9.2 IPM | 3D (0.281") × 0.13D (0.0122") | 378 SFM, 0.00069, 42.7 IPM, 0.0366" × 0.0164" |

Alternative sheet: SF_34600 (8× reach, tool #34631). Aluminum Roughing at 0.031" is 0.00033 at 0.28D radial × 0.30D axial and 1000 SFM; Slotting is 0.00026.

## Related Harvey guidance

- **Miniature end mills** (In the Loupe, 2020): slotting step-down 5–15% of D; runout ≤ 2% of D; doubling stickout gives 8× the deflection, doubling the diameter 16× less.
- **HEM Guidebook:** up to 2×D axial depth; HEM below 1/16" is "possible but risky"; not recommended below 1/32".

## Links

- SF_73000: https://harveyperformance.widen.net/content/zieqxftuea/pdf/SF_73000.pdf
- SF_72000: https://harveyperformance.widen.net/content/rptnkylsjh/pdf/SF_72000.pdf
- SF_47800: https://harveyperformance.widen.net/content/xbh3p3cfxq/pdf/SF_47800.pdf
- SF_34600: https://harveyperformance.widen.net/content/t9e9bowehs/pdf/SF_34600.pdf
- Miniature guide: https://www.harveyperformance.com/in-the-loupe/how-to-optimize-results-while-machining-with-miniature-end-mills/
- HEM Guidebook: https://www.basstool.com/pdf/promos/HEM_Guidebook.pdf
