# Runout sensitivity for micro tools

Question from the shop: "if runout goes down, does MRR go up?" for 1/16" and smaller tools.

`POST /api/runout_sensitivity` (`routes_runout.py`, `runout_sensitivity.py`) runs the same calculation as
`/api/calculate` once per runout and reports the recommended cut at each one. The Speeds & Feeds page shows
it as the "Runout sensitivity" card for tools of 1/8" and smaller (button "Show how runout changes this cut").

**The numbers below are from the engine on branch `v4/f2-machine` (model v2, Speedio S500X2 16k spindle,
aggressiveness 50, recommended engagement) and will move when the engine calibration branch merges.** Re-run the
endpoint (or the card) for current numbers.

## API

Body: the fields of `/api/calculate` (or `fusion_tool`), `aggressiveness` (0 to 100), and optionally

| Field | Meaning |
|---|---|
| `runouts` | list of TIR values in inches, 1 to 16 values, 0 to 0.005. Default `[0, 0.00005, 0.0001, 0.00015, 0.0002, 0.0003, 0.0005]` |
| `current_runout` | the shop's present holder TIR in inches. Default: the body's `runout`, else the machine runout setting |
| `model` | `v2` (default) or `v1` |

Response: `rows` (per runout: `rpm`, `feed_ipm`, `fz_in`, `ap_in`, `ae_in`, `mrr_in3_min`, `flutes_cutting`,
`runout_regime`, `limited_by`, `limited_by_words`, `feasible`), `current` (the current runout and the nearest holder
class), `holder_classes` (the cut at the typical TIR of each class in `data/holders.json`, with
`mrr_gain_vs_current_pct` for every better class that fits the tool's shank) and `summary` (plain sentences such as
"Going from 0.0002" to 0.00012" (micro collet chuck) raises MRR by 38% on this cut.").

Holder classes and their TIR (worst published value, `data/holders.json`): standard ER collet 0.00059", ER-UP
0.0002", SK/SKC 0.0002", hydraulic / shrink-fit / powRgrip 0.00012", micro collet chuck 0.00012". Nothing is
measured by ToolWiz; these are manufacturer figures.

## What the engine does with runout

With runout TIR, only the flutes that stick out furthest cut until the chip is thicker than the runout offset;
the others rub. The engine reports `flutes_cutting` (4 of 4 down to 1 of 4) and a `runout_regime`. MRR falls when
the feed per tooth has to be cut to protect the leading flute, or when fewer flutes carry the feed. MRR does not
rise when another limit (tool geometry, vendor chip-load ceiling, depth-of-cut cap, deflection) already holds the
cut: then a better holder helps accuracy and tool life but not MRR, and the endpoint says so.

## Example: 1/16" end mill, titanium, adaptive

Owner's library tool "1/16" Flat Endmill" (3 flutes, 3/16" flute length), with the shank corrected from 0.0625" to
the shop-rule 0.125" (the library has 0.0625"; see the shank rule in docs/MACHINE_PROFILES.md), Titanium Alloy, Adaptive Roughing, 50%.

| Runout | rpm | Feed (IPM) | Chip load (in/tooth) | ap x ae (in) | MRR (in³/min) | Flutes cutting | Regime | Limited by |
|---|---:|---:|---:|---|---:|---:|---|---|
| 0.00000" | 11940 | 9.32 | 0.00026 | 0.1875 x 0.00625 | 0.01092 | 3 | all_flutes | tool geometry (reach and clearance); depth-of-cut cap from vendor limits; vendor chip-load ceiling |
| 0.00005" | 11940 | 9.32 | 0.00026 | 0.1875 x 0.00625 | 0.01092 | 3 | all_flutes | tool geometry (reach and clearance); depth-of-cut cap from vendor limits; vendor chip-load ceiling |
| 0.00010" | 11940 | 9.32 | 0.00026 | 0.1875 x 0.00625 | 0.01092 | 3 | all_flutes | tool geometry (reach and clearance); depth-of-cut cap from vendor limits; vendor chip-load ceiling |
| 0.00015" | 11940 | 9.32 | 0.00026 | 0.1875 x 0.00625 | 0.01092 | 3 | all_flutes | tool geometry (reach and clearance); depth-of-cut cap from vendor limits; vendor chip-load ceiling |
| 0.00020" | 11940 | 9.32 | 0.00026 | 0.1875 x 0.00625 | 0.01092 | 2 | reduced_flutes | tool geometry (reach and clearance); depth-of-cut cap from vendor limits; vendor chip-load ceiling |
| 0.00030" | 11940 | 9.32 | 0.00026 | 0.1875 x 0.00625 | 0.01092 | 2 | reduced_flutes | tool geometry (reach and clearance); depth-of-cut cap from vendor limits; vendor chip-load ceiling |
| 0.00050" | 11940 | 9.32 | 0.00026 | 0.1875 x 0.00625 | 0.01092 | 1 | reduced_flutes | tool geometry (reach and clearance); depth-of-cut cap from vendor limits; vendor chip-load ceiling |

- Going from 0.0002" to 0.00012" (hydraulic / shrink-fit / powRgrip) changes MRR by less than 1% on this cut: it is limited by tool geometry (reach and clearance); depth-of-cut cap from vendor limits; vendor chip-load ceiling, not by runout.
- Going from 0.0002" to 0.00012" (micro collet chuck) changes MRR by less than 1% on this cut: it is limited by tool geometry (reach and clearance); depth-of-cut cap from vendor limits; vendor chip-load ceiling, not by runout.
- Upper bound: Going from 0.0002" to 0" (zero runout, not achievable) changes MRR by less than 1% on this cut: it is limited by tool geometry (reach and clearance); depth-of-cut cap from vendor limits; vendor chip-load ceiling, not by runout.

Holder classes (same cut):

| Holder class | Typical TIR | MRR (in³/min) | Gain vs 0.0002" |
|---|---:|---:|---:|
| standard ER collet | 0.00059" | 0.01092 | - |
| ER-UP collet | 0.00020" | 0.01092 | - |
| SK/SKC precision collet | 0.00020" | 0.01092 | - |
| hydraulic / shrink-fit / powRgrip | 0.00012" | 0.01092 | +0% |
| micro collet chuck | 0.00012" | 0.01092 | +0% |

In this case the cut is limited by tool geometry, the vendor depth cap and the vendor chip-load ceiling, so
runout only changes how many flutes cut (3 down to 1), not the recommended MRR. The same tool shows a real gain
elsewhere, see below.

## Owner's micro tools

MRR in in³/min at each runout (TIR); (nF) = flutes cutting. Last column: MRR change from 0.0002" (ER-UP / SK class)
to 0.00012" (hydraulic / shrink-fit / powRgrip / micro chuck). Tools from
`data/shop_library/Offworldgear_TI_Steel1_Updated4_20261019_125408_v6.json`; materials Titanium Alloy,
Stainless - PH Series (17-4), Aluminum - Wrought (6061); adaptive and slotting at 50%.

### 1/32" 2-flute flat end mill (library tool index 10)

| Material | Operation | 0" | 0.00005" | 0.0001" | 0.00015" | 0.0002" | 0.0003" | 0.0005" | 0.0002" to 0.00012" |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Titanium | adaptive | 0.00159 (2F) | 0.00126 (2F) | 0.00109 (1F) | 0.00109 (1F) | 0.00109 (1F) | 0.00109 (1F) | 0.00109 (1F) | +0% |
| Titanium | slotting | 0.00070 (2F) | 0.00070 (2F) | 0.00065 (1F) | 0.00065 (1F) | 0.00065 (1F) | 0.00065 (1F) | 0.00065 (1F) | +0% |
| 17-4 PH | adaptive | 0.00159 (2F) | 0.00099 (2F) | 0.00092 (1F) | 0.00092 (1F) | 0.00092 (1F) | 0.00092 (1F) | 0.00092 (1F) | +0% |
| 17-4 PH | slotting | 0.00072 (2F) | 0.00072 (2F) | 0.00063 (1F) | 0.00063 (1F) | 0.00063 (1F) | 0.00063 (1F) | 0.00063 (1F) | +0% |
| 6061 | adaptive | 0.00126 (2F) | 0.00126 (2F) | 0.00126 (1F) | 0.00126 (1F) | 0.00126 (1F) | 0.00126 (1F) | 0.00126 (1F) | +0% |
| 6061 | slotting | 0.00305 (2F) | 0.00152 (1F) | 0.00152 (1F) | 0.00152 (1F) | 0.00152 (1F) | 0.00152 (1F) | 0.00152 (1F) | +0% |

### 1/32" 4-flute flat end mill (library tool index 11)

| Material | Operation | 0" | 0.00005" | 0.0001" | 0.00015" | 0.0002" | 0.0003" | 0.0005" | 0.0002" to 0.00012" |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Titanium | adaptive | 0.00049 (4F) | 0.00049 (4F) | 0.00049 (4F) | 0.00049 (3F) | 0.00042 (2F) | 0.00028 (1F) | 0.00027 (1F) | +17% |
| Titanium | slotting | 0.00138 (4F) | 0.00138 (4F) | 0.00138 (4F) | 0.00138 (2F) | 0.00136 (2F) | 0.00084 (1F) | 0.00084 (1F) | +2% |
| 17-4 PH | adaptive | 0.00050 (4F) | 0.00050 (4F) | 0.00050 (4F) | 0.00040 (2F) | 0.00031 (2F) | 0.00023 (1F) | 0.00023 (1F) | +61% |
| 17-4 PH | slotting | 0.00138 (4F) | 0.00138 (4F) | 0.00138 (4F) | 0.00138 (3F) | 0.00136 (2F) | 0.00080 (1F) | 0.00080 (1F) | +2% |
| 6061 | adaptive | 0.00252 (4F) | 0.00252 (4F) | 0.00252 (4F) | 0.00252 (3F) | 0.00252 (2F) | 0.00252 (2F) | 0.00252 (1F) | +0% |
| 6061 | slotting | 0.00360 (4F) | 0.00360 (4F) | 0.00360 (4F) | 0.00360 (3F) | 0.00360 (2F) | 0.00194 (1F) | 0.00194 (1F) | +0% |

### 0.040" 4-flute flat end mill (library tool index 19)

| Material | Operation | 0" | 0.00005" | 0.0001" | 0.00015" | 0.0002" | 0.0003" | 0.0005" | 0.0002" to 0.00012" |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Titanium | adaptive | 0.00794 (4F) | 0.00794 (4F) | 0.00794 (4F) | 0.00794 (4F) | 0.00794 (3F) | 0.00794 (2F) | 0.00794 (2F) | +0% |
| Titanium | slotting | 0.00313 (4F) | 0.00313 (4F) | 0.00313 (4F) | 0.00313 (3F) | 0.00313 (2F) | 0.00302 (2F) | 0.00213 (1F) | +0% |
| 17-4 PH | adaptive | 0.00667 (4F) | 0.00667 (4F) | 0.00667 (4F) | 0.00660 (4F) | 0.00591 (3F) | 0.00540 (2F) | 0.00402 (1F) | +13% |
| 17-4 PH | slotting | 0.00488 (4F) | 0.00488 (4F) | 0.00488 (4F) | 0.00488 (4F) | 0.00485 (3F) | 0.00247 (1F) | 0.00247 (1F) | +1% |
| 6061 | adaptive | 0.00529 (4F) | 0.00529 (4F) | 0.00529 (4F) | 0.00529 (4F) | 0.00530 (3F) | 0.00529 (2F) | 0.00529 (2F) | +0% |
| 6061 | slotting | 0.01580 (4F) | 0.01580 (4F) | 0.01580 (4F) | 0.01575 (4F) | 0.01199 (2F) | 0.00761 (1F) | 0.00718 (1F) | +32% |

### 1/16" 3-flute (library shank 0.0625" corrected to 0.125") flat end mill (library tool index 2)

| Material | Operation | 0" | 0.00005" | 0.0001" | 0.00015" | 0.0002" | 0.0003" | 0.0005" | 0.0002" to 0.00012" |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Titanium | adaptive | 0.01092 (3F) | 0.01092 (3F) | 0.01092 (3F) | 0.01092 (3F) | 0.01092 (2F) | 0.01092 (2F) | 0.01092 (1F) | +0% |
| Titanium | slotting | 0.00555 (3F) | 0.00555 (3F) | 0.00555 (3F) | 0.00555 (3F) | 0.00555 (2F) | 0.00555 (2F) | 0.00555 (1F) | +0% |
| 17-4 PH | adaptive | 0.02016 (3F) | 0.02016 (3F) | 0.02016 (3F) | 0.02016 (3F) | 0.02016 (3F) | 0.02016 (2F) | 0.01686 (1F) | +0% |
| 17-4 PH | slotting | 0.01214 (3F) | 0.01214 (3F) | 0.01214 (3F) | 0.01214 (3F) | 0.01214 (3F) | 0.00883 (2F) | 0.00792 (1F) | +0% |
| 6061 | adaptive | 0.01588 (3F) | 0.01588 (3F) | 0.01588 (3F) | 0.01588 (3F) | 0.01589 (3F) | 0.01588 (2F) | 0.01329 (1F) | +0% |
| 6061 | slotting | 0.04747 (3F) | 0.04747 (3F) | 0.04747 (3F) | 0.04747 (3F) | 0.04747 (3F) | 0.04627 (2F) | 0.03035 (1F) | +0% |

## Reading the tables

- Where a column group repeats the same MRR, the cut is limited by something other than runout; a better holder
  does not raise MRR there.
- Large gains show up where the flute count drops: 1/32" 4-flute in 17-4 PH adaptive (+61% from 0.0002" to
  0.00012"), 1/16" and 0.040" end mills in 6061 slotting and 17-4 adaptive.
- At 0.0005" (a standard ER collet at its worst) most small tools are down to one cutting flute; the engine also
  lowers the feed in that regime.
- "Upper bound" sentences in the API use 0" runout, which no holder reaches.
- The 1/16" row uses the corrected 1/8" shank. With the library's 0.0625" shank the engine models a thin rod to the
  holder and the cut is more deflection-limited; `library_audit.py` reports it as `shank_suspect`.
