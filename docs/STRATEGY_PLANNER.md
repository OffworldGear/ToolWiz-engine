# Strategy planner

`POST /api/strategy/compare` (`strategy_planner.compare`) answers: for this feature and these tools, which strategy gives the
shortest cycle time without a big difference in tool wear? Features: `profile_cutout` (contour around a part with tabs),
`slot` (fixed width) and `tslot` (T-slot / keyseat cutters). Every speed, feed, depth, width, ramp and stock-to-leave value comes
from ToolWiz: `pipeline.run_cut` with the v2 model for end mills and `tslot_model` for slot mills, at the request's
aggressiveness and runout. The planner only adds geometry (paths), a cycle-time model and a tool-wear estimate. Lengths are
inches, feeds IPM, times minutes.

## Request

```json
{"family": "Aluminum - Wrought (6061)", "alloy": "6061-T6", "aggressiveness": 0.5, "runout": 0.0002, "model": "v2",
 "feature": {"type": "profile_cutout", "depth": 0.25, "length": 12.0,
             "tabs": {"count": 4, "width": 0.1, "height": 0.04, "style": "3d"}, "channel_width": 0.125},
 "candidate_tools": [{"diameter": 0.125, "flutes": 2, "flute_length": 0.375, "shank_diameter": 0.125, "stickout": 0.6,
                      "coating": "Uncoated", "geometry": "Square"}]}
```

* `profile_cutout`: `depth` = part thickness, `length` = perimeter, optional `tabs` (`style` `3d` or `2d`), optional
  `channel_width` (default `max(1.5 x smallest D, largest candidate D)`).
* `slot`: `width`, `depth`, `length`.
* `tslot`: `slot_height` (Z extent), `radial_depth`, `length`; candidates are `{"id": "klot_8x0.5"}` (any id in
  `data/shop_tools.json`) or `{"geometry": {"diameter_mm", "kerf_mm", "neck_diameter_mm", "reach_mm", "shank_diameter_mm", "teeth", ...}}`.
* Errors return 400 `{"success": false, "error": "..."}`; the `X-ToolWiz-Client` header is required.

The response has `options` (each: `name`, `tool`, `strategy`, `levels`, `ap`, `ae`, `rpm`, `feed_ipm`, `path_length_in`,
`cycle_time_min`, `relative_tool_life`, `tool_wear_per_part`, `risks`, `notes`, `fusion_hints`, `phases`), `recommended`,
`reasoning`, `assumptions`, `skipped`, `tab_advice`, `wear_ratio_limit`.

## Options

| Feature | Option | What it is |
|---|---|---|
| profile_cutout | `contour_slot` | Largest candidate, full-width slot around the part (kerf = tool diameter), levels = ceil(depth / ToolWiz slotting ap) |
| profile_cutout | `contour_slot_small_tool` | Same with each smaller candidate (narrower kerf, less material, more levels) |
| profile_cutout | `adaptive` | Smaller candidate clearing a channel of width W_c with ToolWiz adaptive numbers (only when W_c >= 1.25 x D) |
| slot | `contour_slot` | D = W: one full slot |
| slot | `contour_slot_side_passes` | D < W: centre slot + side roughing passes (ToolWiz Roughing ap/ae) + finishing of both walls |
| slot | `adaptive` | D < W: adaptive in the slot leaving ToolWiz's stock, both walls finished (finishing time included) |
| tslot | `tslot` | One option per cutter: Z cuts x radial passes from `tslot_model` |

## Cycle time

Per part: `T = cutting path / feed + ramp entries + links + approach/retract`.

* Link feed = 2 x cutting feed, capped at the machine's maximum cutting feed (30,000 mm/min, `machines/speedio_s500x2.json`);
  rapid 50 m/min; retract height 0.1 in.
* Levels have equal depth `depth / ceil(depth / ap)`. Each level starts with a ToolWiz ramp entry (ramp angle and ramp feed;
  the plunge feed when there is no ramp). On a contour or slot the ramp's horizontal run `ap / tan(angle)` replaces cutting path.
* Tabs: a level whose bottom is deeper than `thickness - tab height` goes around the tabs and skips `count x (tab width + D)` of
  tool-centre path (the slot ends are rounded by the tool). 3D tabs lift over the tab at link feed; 2D tabs retract at rapid and
  re-ramp at every tab. Levels above the tab zone are full closed contours.
* Adaptive path model. In a channel of width `W_c` the tool centre runs trochoidal loops of radius `r = (W_c - D)/2`, advancing
  the ToolWiz optimal load `ae` per loop (loops = path / ae). Cutting centre path per loop = `max(pi r + ae, W_c)` (the leading
  half circle plus the advance, and never less than the volume balance `W_c x ae / ae`, so the time can never beat volume / ToolWiz's
  MRR); the return half circle `pi r` is not cutting and runs at link feed. The adaptive time is dominated by this: a narrow channel
  forces a light `ae` (about 0.1 D) and long arcs.
* T-slot: Z cuts (`axial_plan.cuts`, steps of 0.8 x kerf with the cutter faces cutting at the model's face feed, otherwise one
  retract-and-re-enter level per kerf) x radial passes (`ceil(radial depth / radial depth per pass)`) x length / lateral feed.
* Not included: tool changes, load/unload, tab removal, air time between parts, spoilboard over-cut.

## Tool life

One consistent model, with the engagement counted once. For each cutting phase:

    life  = min( (v_life / v_used)^(1/n) , 10 )          wear = in-cut minutes / life

* `v_used` is the SFM ToolWiz chose. `v_life` is the speed at which this tool reaches the reference life *for this engagement*:
  `physics_v2.optimize.taylor_speed_m_min` at the phase's engagement angle (C7's life speed, with T/T_ref = 1 and the 50 % speed scale).
  That function already contains the engagement speed factor (a light cut has a higher life speed), so a lightly engaged edge is credited
  there and nowhere else. `n = material.taylor_n`.
* The earlier version multiplied life by 0.5 / (engagement angle / 2 pi). That counted the light engagement a second time (once in
  `v_life`, once as an edge-time share) and it flattered adaptive; it has been removed. Wear is simply the minutes the edge spends cutting
  divided by T, where T is the Taylor life at the actual speed relative to the C7 life speed for that engagement.
* The ratio is capped at 10x. When the 16,000 rpm spindle holds a small tool far below its life speed (aluminium) the law extrapolates to
  lives of 100-1000x, which means nothing; beyond the cap chipping, built-up edge and breakage dominate. With the cap, wear in those cases is
  proportional to cutting minutes. Each phase reports `taylor_life_ratio` (capped) and `taylor_life_ratio_uncapped`.
* `relative_tool_life` = in-cut minutes / wear (time-weighted over phases). `tool_wear_per_part` = wear normalized so the least-wear feasible
  option is 1.0. Only ratios mean anything.

### Wear confidence and the shop's measured tool lives

Every response has `wear_confidence` and `wear_confidence_reason`.

* **"low"**: `material.taylor_n` is a placeholder (0.25 from one Ti-6Al-4V shoulder-milling paper, carbide range 0.2-0.5, applied to every
  family) and no measured lives exist for the family. The recommendation still applies the wear-ratio rule, but `reasoning` states the time
  difference first, then the wear estimate with its confidence, then the fastest option as the alternative whenever it is not recommended.
* **"measured"**: `cutlog.toollife_calibration(family)` found enough logged tool lives. Those replace `v_life` (the median SFM of the records)
  and, with enough speed spread, `n`.

How to log tool life. `cutlog.py` did not store tool life (it stores predicted and measured wall error), so a new table `toollife` was added
to the same database (existing tables and endpoints are unchanged). Log one row per tool when it is retired:

    POST /api/toollife   (header X-ToolWiz-Client)
    {{"family": "Titanium Alloy", "alloy": "Ti-6Al-4V", "operation": "Slotting", "tool_description": "1/8 2FL",
     "diameter_in": 0.125, "flutes": 2, "rpm": 4500, "feed_ipm": 2.9, "doc_in": 0.05, "woc_in": 0.125,
     "life_minutes": 45, "parts": 30, "end_reason": "worn", "notes": "VB 0.2 mm"}}

`life_minutes` is the spindle-on cutting time the tool lasted; `end_reason` is worn, chipped, broken or still_good. `GET /api/toollife?family=...`
lists records and the calibration; `DELETE /api/toollife/<id>` removes one. Rules: only worn and chipped records count (a broken tool says nothing
about wear life; a still-good one is censored). At least **3** records for a family give a measured life (median life at the median SFM); at
least **5** records whose fastest and slowest SFM differ by at least 1.25x also give a fitted exponent (least squares of ln v on ln T, accepted
only if 0.1 <= n <= 0.6). The calibration is per family. Pass `"use_cutlog": false` in the request to ignore the log.

## Recommendation

The fastest feasible option whose `tool_wear_per_part` is within `1.1 / 1.3 / 2.0` (aggressiveness `0 / 0.5 / 1.0`, linear between) of
the least-wear option. `reasoning` states the rule, the chosen option's time and wear, the time saved versus the least-wear option,
faster options that were rejected, infeasible options and why, and the chosen option's risks (runout regime, chip near the rubbing limit,
holder class, provisional geometry, planned tool). An option is infeasible when ToolWiz finds no safe cut (end mills) or the model raises
a critical finding (T-slot neck clearance exceeded, slot height under the kerf).

`fusion_hints` per option: Fusion strategy, `maximumStepdown`, optimal load / stepover, multiple depths, tab settings (`useTabs`,
`tabWidth`, `tabHeight`, tab positioning), ramp (angle, feeds, helical diameter), stock to leave (`useStockToLeave`, `stockToLeave`,
`verticalStockToLeave`: ToolWiz's recommendation = 1.5 x predicted wall deflection + springback, rounded up to 0.0005 in) and a finishing-pass
suggestion for true-to-size parts. Parameter names follow the Fusion API as used elsewhere in the add-in; check them in your Fusion version.

## Worked example for the shop

Job: a 0.25 in thick part, 12 in perimeter, 4 tabs 0.100 in wide and 0.040 in high (3D), candidate tools 0.125 in 2FL (flute
0.375, stickout 0.6) and 0.0625 in 2FL (flute 0.1875, stickout 0.4), v2 model, 50 % aggressiveness, runout 0.0002 in, Speedio S500X2 16k.
Adaptive channel 0.125 in (the large tool's kerf). Times are per part. Wear confidence is low in every example (no logged tool lives).
Removing the engagement double count changed only the wear column and, in a few cases, the pick (see "Before").

#### 6061-T6
| Option | levels | ap (in) | ae (in) | rpm | feed (ipm) | cutting path (in) | cycle (min) | rel. life | wear/part |
|---|---|---|---|---|---|---|---|---|---|
| contour_slot 0.125in 2FL | 3 | 0.0837 | 0.1250 | 16000 | 13.57 | 35 | 2.63 | 10.0 | 1.00 |
| contour_slot_small_tool 0.0625in 2FL | 6 | 0.0418 | 0.0625 | 16000 | 7.00 | 71 | 10.26 | 10.0 | 3.93 |
| adaptive 0.0625in 2FL in 0.125 in channel | 2 | 0.1250 | 0.0063 | 16000 | 11.82 | 468 | 55.20 | 10.0 | 15.26 |

- Time: recommended contour_slot 0.125in 2FL takes 2.63 min per part; the others take contour_slot_small_tool 0.0625in 2FL 10.26 min; adaptive 0.0625in 2FL in 0.125 in channel 55.20 min (up to 21.0x as long as the recommendation).
- Wear (confidence: low): the recommendation wears the tool 1.00x the least-wear option (contour_slot 0.125in 2FL, itself); allowed 1.30x at aggressiveness 0.50 (1.1 at 0, 1.3 at 0.5, 2.0 at 1.0). material.taylor_n = 0.25 is a literature placeholder (one Ti-6Al-4V paper, carbide range 0.2-0.5) and no measured tool lives are logged for Aluminum - Wrought (6061); log tool lives at POST /api/toollife (at least 3 per family) to calibrate.
- Because the wear estimate is low-confidence, weigh the time difference above more than the wear ratio.
- contour_slot_small_tool 0.0625in 2FL: 10.26 min, wear 3.93x.
- adaptive 0.0625in 2FL in 0.125 in channel: 55.20 min, wear 15.26x.
- contour_slot 0.125in 2FL: holder: needs ultra-class runout (required TIR 0.00011 in); recommended: micro collet chuck (Mega Micro), shrink fit, powRgrip, hydraulic

(aggressiveness 0.0: recommended **contour_slot 0.125in 2FL**, limit 1.10x)

(aggressiveness 1.0: recommended **contour_slot 0.125in 2FL**, limit 2.00x)

#### Ti-6Al-4V
| Option | levels | ap (in) | ae (in) | rpm | feed (ipm) | cutting path (in) | cycle (min) | rel. life | wear/part |
|---|---|---|---|---|---|---|---|---|---|
| contour_slot 0.125in 2FL | 5 | 0.0500 | 0.1250 | 4498 | 2.88 | 59 | 20.71 | 1.6 | 1.00 |
| contour_slot_small_tool 0.0625in 2FL | 13 | 0.0204 | 0.0625 | 9607 | 4.21 | 154 | 37.01 | 1.3 | 2.33 |
| adaptive 0.0625in 2FL in 0.125 in channel | 2 | 0.1875 | 0.0063 | 13772 | 7.16 | 470 | 91.58 | 1.3 | 4.17 |

- Time: recommended contour_slot 0.125in 2FL takes 20.71 min per part; the others take contour_slot_small_tool 0.0625in 2FL 37.01 min; adaptive 0.0625in 2FL in 0.125 in channel 91.58 min (up to 4.4x as long as the recommendation).
- Wear (confidence: low): the recommendation wears the tool 1.00x the least-wear option (contour_slot 0.125in 2FL, itself); allowed 1.30x at aggressiveness 0.50 (1.1 at 0, 1.3 at 0.5, 2.0 at 1.0). material.taylor_n = 0.25 is a literature placeholder (one Ti-6Al-4V paper, carbide range 0.2-0.5) and no measured tool lives are logged for Titanium Alloy; log tool lives at POST /api/toollife (at least 3 per family) to calibrate.
- Because the wear estimate is low-confidence, weigh the time difference above more than the wear ratio.
- contour_slot_small_tool 0.0625in 2FL: 37.01 min, wear 2.33x.
- adaptive 0.0625in 2FL in 0.125 in channel: 91.58 min, wear 4.17x.
- contour_slot 0.125in 2FL: holder: needs ultra-class runout (required TIR 0.00008 in); recommended: micro collet chuck (Mega Micro), shrink fit, powRgrip, hydraulic

#### Titanium Grade 1
| Option | levels | ap (in) | ae (in) | rpm | feed (ipm) | cutting path (in) | cycle (min) | rel. life | wear/part |
|---|---|---|---|---|---|---|---|---|---|
| contour_slot 0.125in 2FL | 5 | 0.0500 | 0.1250 | 6442 | 4.36 | 59 | 13.64 | 1.4 | 1.00 |
| contour_slot_small_tool 0.0625in 2FL | 12 | 0.0219 | 0.0625 | 13207 | 5.14 | 143 | 27.94 | 1.3 | 2.27 |
| adaptive 0.0625in 2FL in 0.125 in channel | 2 | 0.1875 | 0.0062 | 16000 | 11.83 | 472 | 55.72 | 2.5 | 1.67 |

- Time: recommended contour_slot 0.125in 2FL takes 13.64 min per part; the others take contour_slot_small_tool 0.0625in 2FL 27.94 min; adaptive 0.0625in 2FL in 0.125 in channel 55.72 min (up to 4.1x as long as the recommendation).
- Wear (confidence: low): the recommendation wears the tool 1.00x the least-wear option (contour_slot 0.125in 2FL, itself); allowed 1.30x at aggressiveness 0.50 (1.1 at 0, 1.3 at 0.5, 2.0 at 1.0). material.taylor_n = 0.25 is a literature placeholder (one Ti-6Al-4V paper, carbide range 0.2-0.5) and no measured tool lives are logged for Titanium Alloy; log tool lives at POST /api/toollife (at least 3 per family) to calibrate.
- Because the wear estimate is low-confidence, weigh the time difference above more than the wear ratio.
- contour_slot_small_tool 0.0625in 2FL: 27.94 min, wear 2.27x.
- adaptive 0.0625in 2FL in 0.125 in channel: 55.72 min, wear 1.67x.
- contour_slot 0.125in 2FL: holder: needs ultra-class runout (required TIR 0.00008 in); recommended: micro collet chuck (Mega Micro), shrink fit, powRgrip, hydraulic

#### 17-4 PH
| Option | levels | ap (in) | ae (in) | rpm | feed (ipm) | cutting path (in) | cycle (min) | rel. life | wear/part |
|---|---|---|---|---|---|---|---|---|---|
| contour_slot 0.125in 2FL | 9 | 0.0312 | 0.1250 | 3936 | 2.91 | 106 | 36.85 | 1.7 | 1.00 |
| contour_slot_small_tool 0.0625in 2FL | 19 | 0.0135 | 0.0625 | 8520 | 3.67 | 225 | 61.92 | 1.3 | 2.31 |
| adaptive 0.0625in 2FL in 0.125 in channel | 2 | 0.1250 | 0.0070 | 11988 | 7.76 | 420 | 75.58 | 1.3 | 2.05 |

At 50 % the slot is both fastest and least wear, so it is chosen; adaptive is 2.1x slower.

#### Across aggressiveness (recommended / time / wear)
At 0.0 and 1.0 the 0.125 contour slot is recommended in 6061, Ti-6Al-4V, Ti Grade 1 and 17-4. Examples: Ti-6Al-4V 57 min (1.00x) at 0.0, 14 min at 1.0;
Grade 1 36 min vs adaptive 77 min (1.70x wear) at 0.0.

#### Before (edge-fraction factor, wear/part of the contour slot / small slot / adaptive)
6061 1.00 / 3.93 / 3.13 (adaptive looked better than it is); Ti-6Al-4V 1.17 / 2.72 / 1.00 (adaptive had least wear, slot accepted at 1.17x);
17-4 2.24 / 5.18 / 1.00 (adaptive was recommended at 75.6 min); T-slot Harvey 1.00, 6x2 1.21, 8x1.6 2.35, 8x0.5 5.80, 4x0.5 10.04.
After: 6061 1.00 / 3.93 / 15.26; Ti-6Al-4V 1.00 / 2.33 / 4.17; 17-4 1.00 / 2.31 / 2.05; T-slot Harvey 1.00, 6x2 1.36, 8x1.6 3.06, 8x0.5 7.56, 4x0.5 11.30.
Conclusion change: in 17-4 the slot is now recommended (36.9 min instead of 75.6 min adaptive), because adaptive no longer gets a double engagement credit.

#### T-slot in Ti-6Al-4V (slot height 0.0787 in = 2 mm, radial depth 0.030 in, length 2 in)
| Cutter | Z cuts | radial passes | ae (in) | rpm | feed (ipm) | cycle (min) | rel. life | wear/part | neck defl (in) | feasible |
|---|---|---|---|---|---|---|---|---|---|---|
| klot_8x0.5 | 5 | 2 | 0.0150 | 1513 | 2.16 | 9.39 | 10.0 | 7.56 | 0.00001 | yes |
| harvey_867330 | 2 | 1 | 0.0300 | 1270 | 3.37 | 1.24 | 10.0 | 1.00 | 0.00001 | yes |
| klot_8x1.6 | 2 | 2 | 0.0150 | 1513 | 2.16 | 3.80 | 10.0 | 3.06 | 0.00003 | yes |
| klot_4x0.5 | 5 | 3 | 0.0100 | 3025 | 2.16 | 14.02 | 10.0 | 11.30 | 0.00001 | yes |
| klot_6x2 | 1 | 2 | 0.0150 | 2017 | 2.38 | 1.69 | 10.0 | 1.36 | 0.00005 | yes |

- Time: recommended harvey_867330: Harvey Tool 867330: 3/8 x 1/16 staggered-tooth keyseat cutter (planned replacement) takes 1.24 min per part; the others take klot_6x2: 6mm x 2mm Titanium Coated Carbide T Slot End Mill Cutter 1.69 min; klot_8x1.6: 8mm x 1.6mm Klot/Harfington T-slot cutter (possible fallback) 3.80 min; klot_8x0.5: 8mm x 0.5mm Klot/Harfington solid carbide T-slot cutter 9.39 min; klot_4x0.5: 4mm x 0.5mm Klot/Harfington solid carbide T-slot cutter 14.02 min (up to 11.3x as long as the recommendation).
- Wear (confidence: low): the recommendation wears the tool 1.00x the least-wear option (harvey_867330: Harvey Tool 867330: 3/8 x 1/16 staggered-tooth keyseat cutter (planned replacement), itself); allowed 1.30x at aggressiveness 0.50 (1.1 at 0, 1.3 at 0.5, 2.0 at 1.0). material.taylor_n = 0.25 is a literature placeholder (one Ti-6Al-4V paper, carbide range 0.2-0.5) and no measured tool lives are logged for Titanium Alloy; log tool lives at POST /api/toollife (at least 3 per family) to calibrate.
- Because the wear estimate is low-confidence, weigh the time difference above more than the wear ratio.
- klot_6x2: 6mm x 2mm Titanium Coated Carbide T Slot End Mill Cutter: 1.69 min, wear 1.36x.
- klot_8x1.6: 8mm x 1.6mm Klot/Harfington T-slot cutter (possible fallback): 3.80 min, wear 3.06x.
- klot_8x0.5: 8mm x 0.5mm Klot/Harfington solid carbide T-slot cutter: 9.39 min, wear 7.56x.
- klot_4x0.5: 4mm x 0.5mm Klot/Harfington solid carbide T-slot cutter: 14.02 min, wear 11.30x.
- harvey_867330: Harvey Tool 867330: 3/8 x 1/16 staggered-tooth keyseat cutter (planned replacement): Runout vs chip load: Runout 0.00020" is 60% of the chip load (0.00033"): one tooth will do most of the cutting. Use a precision holder.
- harvey_867330: Harvey Tool 867330: 3/8 x 1/16 staggered-tooth keyseat cutter (planned replacement): planned tool (not owned yet)
- harvey_867330: Harvey Tool 867330: 3/8 x 1/16 staggered-tooth keyseat cutter (planned replacement) vs the fastest feasible alternative (klot_6x2: 6mm x 2mm Titanium Coated Carbide T Slot End Mill Cutter): cycle time 26% shorter, wear 1.00x vs 1.36x. Basis: vendor data: the T-slot model is calibrated on Harvey keyseat speed/feed sheets and this is a Harvey part (tests/benchmarks/tslot/harvey.json).
- klot_8x0.5: 8mm x 0.5mm Klot/Harfington solid carbide T-slot cutter: provisional geometry (neck_diameter, reach, tooth_form, shank_diameter, teeth, oal, coating) - measure neck diameter, reach and tooth form before trusting the neck deflection and pass count.
- klot_8x1.6: 8mm x 1.6mm Klot/Harfington T-slot cutter (possible fallback): provisional geometry (neck_diameter, reach, tooth_form, shank_diameter, teeth, oal, coating) - measure neck diameter, reach and tooth form before trusting the neck deflection and pass count.
- klot_4x0.5: 4mm x 0.5mm Klot/Harfington solid carbide T-slot cutter: provisional geometry (neck_diameter, reach, tooth_form, shank_diameter, teeth, oal, coating) - measure neck diameter, reach and tooth form before trusting the neck deflection and pass count.
- klot_6x2: 6mm x 2mm Titanium Coated Carbide T Slot End Mill Cutter: provisional geometry (neck_diameter, reach, tooth_form) - measure neck diameter, reach and tooth form before trusting the neck deflection and pass count.

All T-slot cutters sit at the 10x cap (the 16k-capped speeds are far below the life speed), so wear per part there is proportional to cutting
minutes: the ranking is the cycle-time ranking. The Harvey is both fastest and least wear.

## Assumptions to confirm

1. Contour path length is the stated perimeter; tab skip = tab width + D of centre path; cuts end exactly at the thickness.
2. Link feed 2 x cutting feed (cap 30,000 mm/min), rapid 50 m/min, retract 0.1 in.
3. Adaptive loop model above; channel width default; adaptive in a cutout leaves stock on the part wall and the wall finish is NOT in its
   time (it is for the fixed-width slot).
4. Tool-life model: Taylor law at ToolWiz's SFM vs C7's life speed for the engagement, taylor_n placeholder (confidence low), 10x cap; log tool lives to calibrate.
5. T-slot cycle model and the T-slot job parameters (slot height, radial depth, length) are inputs: results depend on them.
6. Provisional cutter geometry in `data/shop_tools.json` (neck, reach, tooth form) is flagged in every affected option.
