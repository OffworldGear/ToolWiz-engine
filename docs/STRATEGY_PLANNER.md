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

Per phase: `life = (v_life / v_used)^(1/n) x 0.5 / edge_fraction`, in-cut minutes / life = wear.

* `v_life` = `physics_v2.optimize.taylor_speed_m_min` at the phase's engagement angle, with T/T_ref = 1 and the 50 % speed scale
  (so the baseline is the 50 % aggressiveness speed); `v_used` = the SFM ToolWiz chose; `n = material.taylor_n` (a placeholder, carbide
  0.2-0.5).
* `edge_fraction` = engagement angle / 2 pi (slot 0.5). The factor `0.5 / edge_fraction` credits a lightly engaged edge; the
  Taylor speed already credits light engagement, so this probably flatters adaptive: treat it as a stated approximation.
* The Taylor ratio is capped at 10 x. When the 16,000 rpm spindle holds a small tool far below its life speed (aluminium) the law
  extrapolates to lives of 100-1000x, which means nothing; beyond 10 x other wear modes (chipping, built-up edge, breakage) dominate.
  Each phase reports `taylor_life_ratio` (capped) and `taylor_life_ratio_uncapped`.
* `relative_tool_life` = in-cut minutes / wear (time-weighted over phases; 1.0 = a full slot at the baseline speed).
  `tool_wear_per_part` = wear normalized so the least-wear feasible option is 1.0. Only the ratios mean anything.

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
0.375, stickout 0.6) and 0.0625 in 2FL (flute 0.1875, stickout 0.4), v2 model, runout 0.0002 in, machine = Speedio S500X2 16k
(config `machines/speedio_s500x2.json`). Adaptive channel 0.125 in (the large tool's kerf). Times are per part.

### 6061-T6, aggressiveness 0.5

| Option | levels | ap (in) | ae (in) | rpm | feed (ipm) | cutting path (in) | cycle (min) | rel. life | wear/part |
|---|---|---|---|---|---|---|---|---|---|
| contour_slot 0.125in 2FL | 3 | 0.0837 | 0.1250 | 16000 | 13.57 | 35 | 2.63 | 10.0 | 1.00 |
| contour_slot_small_tool 0.0625in 2FL | 6 | 0.0418 | 0.0625 | 16000 | 7.00 | 71 | 10.26 | 10.0 | 3.93 |
| adaptive 0.0625in 2FL in 0.125 in channel | 2 | 0.1250 | 0.0063 | 16000 | 11.82 | 468 | 55.20 | 48.8 | 3.13 |

Recommended: **contour_slot 0.125in 2FL**

- Rule: choose the fastest option whose wear per part is within 1.30x of the least-wear option (aggressiveness 0.50: 1.1 at 0, 1.3 at 0.5, 2.0 at 1.0).
- Recommended: contour_slot 0.125in 2FL - 2.63 min per part, and it is also the least-wear option (wear per part 1.00).
- contour_slot_small_tool 0.0625in 2FL: 10.26 min, wear 3.93x.
- adaptive 0.0625in 2FL in 0.125 in channel: 55.20 min, wear 3.13x.
- contour_slot 0.125in 2FL: holder: needs ultra-class runout (required TIR 0.00011 in); recommended: micro collet chuck (Mega Micro), shrink fit, powRgrip, hydraulic

(aggressiveness 0.0: recommended **contour_slot 0.125in 2FL**, limit 1.10x)

(aggressiveness 1.0: recommended **contour_slot 0.125in 2FL**, limit 2.00x)

Option notes:
- contour_slot 0.125in 2FL: kerf 0.1250 in (free for a cutout: the part spacing sets the real limit); 3 levels of 0.0833 in (ToolWiz slotting ap 0.0837 in); entry: ramp 18.2 deg; 1 of 3 levels go around 4 3D tabs (centre-path skip 0.2250 in each)
- contour_slot_small_tool 0.0625in 2FL: kerf 0.0625 in (free for a cutout: the part spacing sets the real limit); 6 levels of 0.0417 in (ToolWiz slotting ap 0.0418 in); entry: ramp 18.2 deg; 1 of 6 levels go around 4 3D tabs (centre-path skip 0.1625 in each)
- adaptive 0.0625in 2FL in 0.125 in channel: channel 0.1250 in wide (2.00 x D): trochoid circle radius 0.0312 in, step 0.0062 in per loop = ToolWiz optimal load, 1920 loops per level, 2 levels of 0.1250 in; cutting arc 0.1250 in and return arc 0.0982 in per loop (return at link feed 24 ipm); 1 of 2 levels go around 4 3D tabs

Tab advice:
- Tab height 0.0400 in vs part thickness 0.2500 in (16%); the bottom 0.0400 in is the only region where the path is interrupted.
- Tab height is less than one level (0.0833 in): the last level still skips the tabs, but the tab is only 0.0400 in thick. Make the tab height at least one level so it is not machined through by the last stepdown.
- 3D tabs keep the tool at the cut and lift over the tab (shorter cycle, one contour, no re-entry); 2D tabs retract at every tab and need a re-ramp at each (slower, more entries) but are simpler to simulate. This comparison used 3D tabs.
- Stagger the tabs around the part (not all on one side) and keep them away from thin features and corners; tabs on a straight edge are easiest to remove.
- Remove the tabs after the cutout with a separate finishing contour of the part wall (or by hand and deburr): the tab stub is what the last pass at true size should clean up.


**Reading it.** In 6061 the 16,000 rpm spindle caps the speed, so the 0.125 slot is fastest and, because the 1/16 tools run at half the SFM
yet the life credit is capped, wear per part is simply proportional to cutting minutes (the 1/8 slot cuts 2.6 min against 10 and 39
for the others). Aggressiveness 0 and 1 give the same pick. Adaptive in a 0.125 in channel is about 20x slower than the slot because the ToolWiz
adaptive optimal load is only 0.1 D and the channel is only twice the tool diameter.

### Ti-6Al-4V, aggressiveness 0.5

| Option | levels | ap (in) | ae (in) | rpm | feed (ipm) | cutting path (in) | cycle (min) | rel. life | wear/part |
|---|---|---|---|---|---|---|---|---|---|
| contour_slot 0.125in 2FL | 5 | 0.0500 | 0.1250 | 4498 | 2.88 | 59 | 20.71 | 1.6 | 1.17 |
| contour_slot_small_tool 0.0625in 2FL | 13 | 0.0204 | 0.0625 | 9607 | 4.21 | 154 | 37.01 | 1.3 | 2.72 |
| adaptive 0.0625in 2FL in 0.125 in channel | 2 | 0.1875 | 0.0063 | 13772 | 7.16 | 470 | 91.58 | 6.2 | 1.00 |

Recommended: **contour_slot 0.125in 2FL**

- Rule: choose the fastest option whose wear per part is within 1.30x of the least-wear option (aggressiveness 0.50: 1.1 at 0, 1.3 at 0.5, 2.0 at 1.0).
- Recommended: contour_slot 0.125in 2FL - 20.71 min per part, wear per part 1.17x the least-wear option (adaptive 0.0625in 2FL in 0.125 in channel, 91.58 min).
- Time saved versus the least-wear option: 70.87 min per part (77% less) at the cost of 1.17x the tool wear per part.
- contour_slot_small_tool 0.0625in 2FL: 37.01 min, wear 2.72x.
- adaptive 0.0625in 2FL in 0.125 in channel: 91.58 min, wear 1.00x.
- contour_slot 0.125in 2FL: holder: needs ultra-class runout (required TIR 0.00008 in); recommended: micro collet chuck (Mega Micro), shrink fit, powRgrip, hydraulic


**Reading it.** In titanium the 1/16 adaptive has the longest edge life (1.0) but takes 4.4x the slot's time. The 1/8 contour slot wears the tool
1.17x as much and saves 71 minutes per part, which is inside the 1.3x limit at 50 %. At aggressiveness 0 (limit 1.1x) ToolWiz's gentler numbers make the 1/8 slot wear 2.2x the adaptive option (57 min vs 134 min per
part), so the rule picks the adaptive 1/16; at 1.0 (limit 2.0x) the 1/8 slot is picked (14 min, wear 1.57x). The owner's question is therefore a
question of how much extra wear is acceptable. The 1/16 contour slot is both slower
than the 1/8 slot and wears more per part (it needs 13 levels at ap 0.0204 in).

### 17-4 PH, aggressiveness 0.5

| Option | levels | ap (in) | ae (in) | rpm | feed (ipm) | cutting path (in) | cycle (min) | rel. life | wear/part |
|---|---|---|---|---|---|---|---|---|---|
| contour_slot 0.125in 2FL | 9 | 0.0312 | 0.1250 | 3936 | 2.91 | 106 | 36.85 | 1.7 | 2.24 |
| contour_slot_small_tool 0.0625in 2FL | 19 | 0.0135 | 0.0625 | 8520 | 3.67 | 225 | 61.92 | 1.3 | 5.18 |
| adaptive 0.0625in 2FL in 0.125 in channel | 2 | 0.1250 | 0.0070 | 11988 | 7.76 | 420 | 75.58 | 5.8 | 1.00 |

Recommended: **adaptive 0.0625in 2FL in 0.125 in channel**


In 17-4 at 50 % the 1/8 slot wears 2.2x as much as the adaptive option, over the 1.3x limit, so the adaptive 1/16 is chosen even though it is
2x slower (76 vs 37 min). At aggressiveness 1.0 (limit 2.0x) the slot is chosen (17.8 min, wear 1.63x). A tool-life ratio of this size rests on the
placeholder Taylor exponent; see the assumptions.

### T-slot in Ti-6Al-4V (slot height 0.0787 in = 2 mm, radial depth 0.030 in, length 2 in)

| Cutter | Z cuts | radial passes | ae (in) | rpm | feed (ipm) | cycle (min) | rel. life | wear/part | neck defl (in) | feasible |
|---|---|---|---|---|---|---|---|---|---|---|
| klot_8x0.5 | 5 | 2 | 0.0150 | 1513 | 2.16 | 9.39 | 71.4 | 5.80 | 0.00001 | yes |
| harvey_867330 | 2 | 1 | 0.0300 | 1270 | 3.37 | 1.24 | 54.8 | 1.00 | 0.00001 | yes |
| klot_8x1.6 | 2 | 2 | 0.0150 | 1513 | 2.16 | 3.80 | 71.4 | 2.35 | 0.00003 | yes |
| klot_4x0.5 | 5 | 3 | 0.0100 | 3025 | 2.16 | 14.02 | 61.7 | 10.04 | 0.00001 | yes |
| klot_6x2 | 1 | 2 | 0.0150 | 2017 | 2.38 | 1.69 | 61.7 | 1.21 | 0.00005 | yes |

Recommended: **harvey_867330: Harvey Tool 867330: 3/8 x 1/16 staggered-tooth keyseat cutter (planned replacement)**

- Rule: choose the fastest option whose wear per part is within 1.30x of the least-wear option (aggressiveness 0.50: 1.1 at 0, 1.3 at 0.5, 2.0 at 1.0).
- Recommended: harvey_867330: Harvey Tool 867330: 3/8 x 1/16 staggered-tooth keyseat cutter (planned replacement) - 1.24 min per part, and it is also the least-wear option (wear per part 1.00).
- klot_6x2: 6mm x 2mm Titanium Coated Carbide T Slot End Mill Cutter: 1.69 min, wear 1.21x.
- klot_8x1.6: 8mm x 1.6mm Klot/Harfington T-slot cutter (possible fallback): 3.80 min, wear 2.35x.
- klot_8x0.5: 8mm x 0.5mm Klot/Harfington solid carbide T-slot cutter: 9.39 min, wear 5.80x.
- klot_4x0.5: 4mm x 0.5mm Klot/Harfington solid carbide T-slot cutter: 14.02 min, wear 10.04x.
- harvey_867330: Harvey Tool 867330: 3/8 x 1/16 staggered-tooth keyseat cutter (planned replacement): Runout vs chip load: Runout 0.00020" is 60% of the chip load (0.00033"): one tooth will do most of the cutting. Use a precision holder.
- harvey_867330: Harvey Tool 867330: 3/8 x 1/16 staggered-tooth keyseat cutter (planned replacement): planned tool (not owned yet)
- harvey_867330: Harvey Tool 867330: 3/8 x 1/16 staggered-tooth keyseat cutter (planned replacement) vs the fastest feasible alternative (klot_6x2: 6mm x 2mm Titanium Coated Carbide T Slot End Mill Cutter): cycle time 26% shorter, wear 1.00x vs 1.21x. Basis: vendor data: the T-slot model is calibrated on Harvey keyseat speed/feed sheets and this is a Harvey part (tests/benchmarks/tslot/harvey.json).
- klot_8x0.5: 8mm x 0.5mm Klot/Harfington solid carbide T-slot cutter: provisional geometry (neck_diameter, reach, tooth_form, shank_diameter, teeth, oal, coating) - measure neck diameter, reach and tooth form before trusting the neck deflection and pass count.
- klot_8x1.6: 8mm x 1.6mm Klot/Harfington T-slot cutter (possible fallback): provisional geometry (neck_diameter, reach, tooth_form, shank_diameter, teeth, oal, coating) - measure neck diameter, reach and tooth form before trusting the neck deflection and pass count.
- klot_4x0.5: 4mm x 0.5mm Klot/Harfington solid carbide T-slot cutter: provisional geometry (neck_diameter, reach, tooth_form, shank_diameter, teeth, oal, coating) - measure neck diameter, reach and tooth form before trusting the neck deflection and pass count.
- klot_6x2: 6mm x 2mm Titanium Coated Carbide T Slot End Mill Cutter: provisional geometry (neck_diameter, reach, tooth_form) - measure neck diameter, reach and tooth form before trusting the neck deflection and pass count.

**Reading it.** The job is a T-slot 2 mm (0.0787 in) high, 0.030 in deep, 2 in long. The Harvey 867330 (kerf 1.575 mm, 8 flutes, staggered) needs
2 Z cuts and one radial pass of 0.030 in; the Klot 8 x 0.5 needs 5 Z cuts of 0.4 mm and 2 radial passes; the Klot 8 x 1.6 needs 2 Z cuts and
2 radial passes because the model limits its radial depth to 0.015 in. Neck deflections are negligible (the model's radial depth, not stiffness,
sets the passes). The Klot 4 x 0.5 and 8 x 0.5 are provisional (neck, reach, tooth form assumed) and physics only; the Harvey has vendor data
(Harvey sheet SF_867300 calibrates the model family) but its 0.0002 in runout is 60 % of the chip load, so a precision holder matters.

## Assumptions to confirm

1. Contour path length is the stated perimeter; tab skip = tab width + D of centre path; cuts end exactly at the thickness.
2. Link feed 2 x cutting feed (cap 30,000 mm/min), rapid 50 m/min, retract 0.1 in.
3. Adaptive loop model above; channel width default; adaptive in a cutout leaves stock on the part wall and the wall finish is NOT in its
   time (it is for the fixed-width slot).
4. Tool-life model: Taylor law at ToolWiz's SFM, taylor_n placeholder, 10x cap, edge-fraction factor.
5. T-slot cycle model and the T-slot job parameters (slot height, radial depth, length) are inputs: results depend on them.
6. Provisional cutter geometry in `data/shop_tools.json` (neck, reach, tooth form) is flagged in every affected option.
