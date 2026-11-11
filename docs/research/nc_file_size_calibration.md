# G-code file size: calibration from the user's programs

_Research, 2026-10-16. Source: the user's Fusion → Brother C00 programs in `C:\Users\matti\OneDrive\Documents\Fusion 360\NC Programs\OWGRatchetPOC` (239 `.NC` files, 2,143 operations). They were parsed read-only, with operations split at Fusion's operation-name comments and tools read from `G100 T..`. The parser script stayed on the user's PC._

## Why

The user's limit is about **6 MB per program**; above that, controller memory and transfer time become a problem. v1's tiny stepdowns produced files over 25 MB. Those files are gone, so this calibration uses the programs still on disk.

## Model

**File size ≈ bytes per line × (cutting path length / mean point spacing)**, plus linking moves.

| Quantity (100 adaptive operations with > 1 m of cutting and > 1,000 lines) | Median | p10–p90 |
|---|---|---|
| Bytes per motion line | 23.1 | 21.5–26.1 |
| Mean point spacing along the cutting path | 0.22 mm | 0.10–0.40 mm |
| Bytes per inch of cutting path | 2,860 | 1,560–6,190 |

Cutting path length ≈ removal volume / (ap · ae) for adaptive roughing. So **file size ∝ volume / (ap · ae · spacing)**. Depth, width and Fusion's point spacing (set by tolerance and smoothing) carry equal weight.

## The largest adaptive operations

| Program / operation | Tool | Size | Cutting path | Z levels | Median Z spacing | Point spacing | Bytes/in |
|---|---|---|---|---|---|---|---|
| O0175 ADAPTIVE17 4 | T12 (1/16") | 3.30 MB | 6.6 m | 158 | 0.004 mm | 0.043 mm | 12,770 |
| O0043 ADAPTIVE17 34 | T1 (1/8") | 2.83 MB | 13.5 m | 109 | 0.022 mm | 0.035 mm (median) | 5,330 |
| O0835 ADAPTIVE32 11 | T13 | 2.14 MB | 24.9 m | 441 | 0.003 mm | 0.15 mm (median) | 2,190 |
| O0043 ADAPTIVE17 38 | T12 | 1.83 MB | 6.1 m | 98 | 0.022 mm | 0.044 mm (median) | 7,590 |

Spacings marked "median" are the median segment length; the O0175 value is the mean.

Several operations show hundreds of Z levels only 0.002–0.005 mm apart. That matches the Fusion adaptive "Fine stepdown" of about 0.005 mm noted in OPEN_ITEMS (2026-10-03): it follows the maximum stepdown and adds levels. Those levels multiply path length with almost no material removed.

## Consequences

- **Model side (v2 optimizer).** Estimate file size from the formula above, using point spacing from the user's typical settings (median 0.22 mm; use 0.04 mm for micro tools at tight tolerance as the bad case). Report it for every cut, and constrain it when the user's "Limit program size" option is on.
- **CAM side, independent of the model.** File size can drop several-fold at no MRR cost:
  - Raise or turn off adaptive Fine stepdown / flat-area levels.
  - For roughing, use a tolerance around 0.01–0.02 mm with smoothing on.
  - Keep tight tolerance (0.005 / 0.001 mm) for finishing passes.
  The user reports roughing tolerance is usually set to the stock to leave (0.05–0.1 mm). The point spacing seen here (0.04–0.4 mm) suggests smoothing is off or the Fine stepdown levels dominate. Check one operation in Fusion.
