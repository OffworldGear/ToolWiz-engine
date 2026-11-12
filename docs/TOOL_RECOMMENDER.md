# Tool recommender

"Would a different tool be much faster for this cut?" ToolWiz reruns its own engine (`pipeline.run_cut`, model v2) for one cut with alternative tools
that fit the same feature and reports an alternative only when the gain is large (default 30 %). A larger tool is almost always faster unless the cut is
fully engaged; a 3 flute tool at 16,000 rpm can beat a 5 flute tool at its recommended speed; another vendor's chart can allow 1.5 to 2.5 times the feed.
The recommender finds out which of these is true for this cut and says what changed. Code: `tool_recommender.py` (pure functions),
`routes_tool_recommender.py` (`POST /api/advice/alternative_tools`). Older `POST /api/advice/tools` (median published MRR per series) still works.

## What is compared

Every candidate is run with the same material, operation, aggressiveness, runout and machine as the current tool, and the same stickout rule:

* **Stickout.** A stickout you give is used for every candidate (raised only when the feature depth needs more reach). When none is given, every tool
  gets `max(reach + half the shank, 4 x diameter)`, so it scales with the diameter. Stickout matters a lot (the same 1/8" tool at 0.5" and at 1.0" differs
  by a factor of 3 in removal rate), which is why it is never left to differ.
* **Runout.** The runout you give, else the current tool's default (0.0001" up to 1/8", 0.0002" above), for every candidate (same holder).
* **Engagement.** Without `cut_depth` / `cut_width`, each tool at ToolWiz's recommended depth and width (a full slot is as wide as each tool). With them,
  the values are scaled with the diameter (finishing: kept as given).
* **Coating.** Catalog candidates use the current tool's coating; library tools their own.

Candidates, in this order, within `max_runs` engine runs (default and maximum 40, the current tool included; identical requests are cached and results are deterministic):

1. **Library** (`sources` has `"library"`): the owner's end mills in `data/shop_library/*.json` and `data/working_library.json` that fit. Never probes, holders, drills, taps,
   T-slot or keyseat cutters, face, chamfer, dovetail or lollipop mills, ball nose unless the current tool is a ball nose, aluminum-only tools in other
   materials, tools smaller than the current one, or the current tool itself.
2. **Catalog** (`sources` has `"catalog"`), from `data/model_v2/catalog_geometries.json` (built from the cited benchmark rows by `tools/build_catalog_geometries.py`):
   * other flute counts at this diameter (current brand, or any brand when the tool is unbranded);
   * other brands that have a chart for this material and operation in `data/model_v2/consensus_by_vendor.json`, using the flute count and the flute length
     that exist in that brand's rows near this diameter (the flute length closest to, and not shorter than, the current tool's);
   * larger diameters (standard sizes up to `max_diameter_in`; with no limit given and not a full slot, up to twice the diameter, with a caveat);
   * a second pass combining the best brand with its other flute counts and the larger sizes.

Constraints: `max_diameter_in` (slot width, or 2 x the smallest inside corner radius), `min_reach_in` (flute length the depth needs). A full slot with no
`max_diameter_in` is taken to be as wide as the current tool, so only same-diameter alternatives are tried. A corner radius up to 15 % of the diameter is an edge
break (square end, the same rule the Setup Advisor uses). A real corner radius (over 15 %) is compared on ToolWiz's shaped-tool consensus whatever the brand, so another
brand of the same radiused tool cannot change the numbers; pass `keep_corner_radius: false` to compare square-end tools.

## Scoring

* **Roughing** (adaptive, roughing, pocket, contour): the material removal rate over the feature depth (no credit for depth beyond `min_reach_in` / `depth_in`).
* **Full slot** (a free kerf: a bigger tool cuts a wider slot): feed x depth per Z level, so a wider slot is not counted as extra work.
* **Finishing**: the rate at which the finish mode's Ra and wall targets are met: feed x stepover for a floor or 3D surface, feed x depth per level for a wall. The
  candidate gets the same finish mode, Ra target and wall tolerance as the current tool (`finish_mode`, `target_ra`, `wall_tolerance`); `finish` carries the predicted Ra, wall error and
  `meets_targets`, and a candidate that cannot meet the targets is dropped.
* With `volume_in3` (roughing), `area_in2` (finishing) or `toolpath_length_in` (with the depth), `cycle_time_min` and `cycle_time_saved_pct` are added.

Infeasible candidates are dropped. Every alternative carries `feasible`, `limited_by`, `deflection_in`, `vendor_basis` and, when the engine reports one, `chip_space`.

## Honesty

* A brand gain reflects that vendor's published chart for this material and operation ("the OSG chart allows 1.8x the removal rate"), not a measured tool test.
* A catalog candidate is a geometry (flute count, flute length) from a cited catalog row, with the series and an example part number, not a guarantee that the part exists or is in stock.
* A tool with no brand, or a brand ToolWiz has no chart for ("Haas", "Amazon"), is compared on the conservative default chart (Harvey and Helical); the result says so (`current.basis`, `disclaimers`).
* Flute count in a full slot. The engine checks chip room (check C15, result block `chip_space`), and that check passes most
  normal-depth slots. What still makes more flutes look better is that the chip-load limit is the same for every flute count,
  while vendors run fewer-flute tools at higher chip loads in slots, most of all in aluminum (docs/research/chip_space.md).
  A flute-count increase in a full slot therefore carries the caveat "Flute-count gain is optimistic ...".
* When nothing passes, `not_recommended_reasons` say why in plain words, e.g. "spindle-limited at 16,000 rpm: brand makes no difference in Aluminum - Wrought (6061) at this diameter, because
  the machine's speed limit sets the feed, not a chart".

## API: `POST /api/advice/alternative_tools`

Header `X-ToolWiz-Client` required. Lengths inches. 400 `{"success": false, "error"}` on bad input. The web calculator's names (`fluteLength`, `shankDiameter`, `cornerRadius`,
`cutDepth`, `cutWidth`, `maxRpm`, `finishMode`, `targetRa`) are accepted as well.

| Field | |
|---|---|
| `family` (required), `alloy`, `operation` (required: Slotting, Adaptive Roughing, Roughing, Pocket, Contour, Finishing, Facing, ...), `aggressiveness` (0..1 or %), `runout`, `model` (default: the app's), `max_rpm`, `max_hp` | the cut and the machine |
| `diameter` (required), `flutes`, `flute_length`, `shank_diameter`, `stickout`, `corner_radius`, `coating`, `brand`, `geometry` (Ball), `description` | the current tool |
| `max_diameter_in`, `min_reach_in`, `full_slot`, `include_larger`, `keep_corner_radius`, `cut_depth`, `cut_width`, `toolpath_length_in`, `depth_in`, `volume_in3`, `area_in2` | the feature |
| `finish_mode` (none, cleanup, surface, accuracy), `target_ra` (micro-inches), `wall_tolerance` | finishing targets |
| `sources` (`["library", "catalog"]`, default both), `min_gain_pct` (default 30), `max_runs` (default 40), `library_tools` | search |

Result: `current` (tool, rpm, feed, ap, ae, rate, `basis`, `vendor_basis`, finish block), `alternatives` (sorted by gain; library first at equal gain; a tool with a shorter flute than the
current one, when no depth was given, sorts after the others) each `{source: library | catalog, brand, series, diameter, flutes, flute_length, coating, rpm, feed, ap, ae, mrr, rate,
gain_pct, gain_ratio, time_saved_pct, cycle_time_min?, vendor_basis, limited_by, feasible, deflection_in, why, caveats[], changes[], library_tool?, catalog_ref?}`, `best_library`, `best_catalog`,
`below_threshold` (the three best that missed the threshold), `not_recommended_reasons`, `summary`, `assumptions`, `disclaimers`, `skipped`, `engine_runs`, `run_cap`.

## Where it shows up

* **Web**: an "Alternative tools" card under the result (button, not on every keystroke) with optional "widest tool" and "reach" fields.
* **Setup Advisor**: one INFO `better_tool` finding and a `tool_alternatives` block per milling operation ([SETUP_ADVISOR.md](SETUP_ADVISOR.md)), using the measured slot width, corner radius and depth.
* **Advisor Chat**: tool `alternative_tools`. **MCP**: `toolwiz_alternative_tools`. All numbers come from the result (the chat's numeric guard checks them).

## Limits

* Vendor charts exist for square-end tools only; ball nose tools are searched in the owner's library only.
* The catalog is the set of tools in the cited benchmark rows (about 2,700 geometries over 11 vendors), not a vendor's full range.
* A gain is the engine's number at the chosen stickout, runout and aggressiveness; test a new tool at a lower aggressiveness first.
