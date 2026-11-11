# Setup advisor (WP-B3)

Audits a Fusion 360 CAM setup against ToolWiz and explains it. **The LLM never produces numbers**: every speed, feed, chip load,
rpm, depth, width, stock or time in the result comes from a ToolWiz call (`pipeline.run_cut`, `tslot_model`,
`strategy_planner.compare`, `toolwiz_common.tooling_advisor`) or is arithmetic on those results. The optional narrative may only
repeat numbers that are in the result and is thrown away otherwise (`toolwiz_common/numeric_guard.py`).

Units: lengths inches, feeds IPM, speeds rpm / SFM, times minutes, MRR in^3/min.

## Endpoints (all need the `X-ToolWiz-Client` header)

### `POST /api/setup_advisor`

```json
{"setup": {...}, "family": "Titanium Alloy", "alloy": "Ti-6Al-4V (Grade 5, Annealed)",
 "aggressiveness": 0.5, "runout": 0.0002, "model": "v2", "use_llm": false, "strategies": true}
```

* `setup`: the add-in's snapshot (below). Omit it, or send `"from_bridge": true`, to use the live state the add-in last pushed to
  `POST /api/fusion_bridge/state` (400 when the add-in never pushed one).
* `family` / `alloy`: ToolWiz material (required unless every op carries its own `family`; `setup.family` / `setup.material` also work).
* `aggressiveness`: a fraction 0..1 (0.5 = relatively safe) or a percentage above 1 (50). Default 0.5.
* `runout`: holder TIR in inches (default: the active machine's). `model`: `v1`/`v2` (default: the app's selected model; the
  `setup_advisor.advise()` function itself defaults to v2, which is needed for stock-to-leave advice and the reduced-flute regime).
* `strategies: false` skips the strategy planner (faster). `use_llm: true` adds the narrative; `apiKey` overrides `GEMINI_API_KEY`.
* 400 `{"success": false, "error"}` on bad input.

Result:

```json
{"success": true, "generated_at": "...", "document": "...", "settings": {"family", "alloy", "aggressiveness", "runout_in", "model", "machine_max_rpm"},
 "summary": {"operations": 4, "stop": 5, "caution": 19, "info": 1, "verdict": "STOP|CAUTION|PASS"},
 "operations": [{"op_id", "name", "setup", "strategy", "kind", "tool": {...},
                 "current": {"rpm", "feed_ipm", "stepdown_in", "stepover_in", "stock_radial_in", "stock_axial_in", "chip_load_ipt", "mrr_in3_min"},
                 "geometry": {...},
                 "toolwiz": {"recommended": {...}, "at_current_engagement": {...} | null, "tslot": {...} | null},
                 "findings": [{"severity": "STOP|CAUTION|INFO", "code", "title", "detail", "recommendation", "numbers": {...}}],
                 "apply_plan": {"recommended": {"<Fusion parameter>": "<expression>"}, "keep_engagement": {...}} | null,
                 "notes": ["assumed fields, model fallback..."]}],
 "setup_findings": [ same finding shape ],
 "strategy_suggestions": [{"op_id", "name", "feature", "recommended", "recommended_option", "current_option", "same_as_current",
                           "time_saved_min", "time_saved_pct", "reasoning", "tab_advice", "options": [...]}],
 "strategy_notes": ["why a comparison was skipped"],
 "narrative": "text or null", "narrative_check": {"ok": true, "rejected_numbers": [], "checked": 0, "attempts": 1}, "narrative_note": "text or null"}
```

`toolwiz.recommended` is ToolWiz at its own recommended engagement (`engagement_source: "recommended"`); `at_current_engagement` is
ToolWiz run on the operation's own stepdown / stepover (`engagement_source: "user"`). Both carry rpm, sfm, feed, programmed chip load,
ap / ae, MRR, deflection, feasibility, limiting constraint, runout regime (`flutes_cutting`, `tir_all_flutes_in`), stock to leave,
ramp / plunge, `holder_advice`, `tool_advice`. For slot mills `tslot` carries the T-slot model's numbers (kerf, Z step, radial depth per
pass, lateral / axial feed, neck deflection, provisional geometry).

### `GET /api/setup_advisor/last`

The latest result (kept in memory); 404 until one exists.

### `POST /api/setup_advisor/apply`

```json
{"op_id": "Setup1 > Adaptive pocket", "params": {"tool_spindleSpeed": "11522 rpm", "stockToLeave": "0.00300 in"},
 "reason": "ToolWiz setup advisor", "wait": 0}
```

Every parameter name must be on the allow-list and every value must equal (after unit conversion, within 0.5 % or half the last digit)
a value in that op's `apply_plan` of the **last** advisor result (`recommended` or `keep_engagement`). Otherwise 400 with
`rejected: {name: reason}` and nothing is sent. On success the bridge action `apply_operation_parameters` is queued
(`wait` seconds blocks for the add-in's result, default 0 returns `{"success": true, "queued": true, "request_id"}`; poll
`GET /api/fusion_bridge/result/<request_id>`). The response lists `accepted`.

## What the add-in sends: the `setup` snapshot

`{"document": "name", "ops": [op, ...]}` (a list, or the add-in's `snapshot_document` dict keyed by `"Setup > Op"` paths). Missing
fields are tolerated: an op without a tool or engagement is listed and gets fewer checks. Per op (all optional except `name`):

| Field | Meaning |
|---|---|
| `op_id` / `path` | Identifier the add-in can resolve again (`"Setup > Operation"`); used by `apply`. |
| `name`, `setup`, `strategy` | Fusion operation name, setup name, `op.strategy` (`adaptive2d`, `contour2d`, `pocket2d`, `face`, `parallel`, ...). |
| `tool` | Fusion tool JSON (`type`, `description`, `unit`, `geometry{DC,NOF,LCF,SFDM,LB,RE,...}`, `post-process.number`), or a flat dict (`diameter_in`/`diameter_mm`, `flutes`, `flute_length_in`, `shank_diameter_in`, `stickout_in`, `corner_radius_in`, `coating`, `kerf_in` for slot mills, `neck_diameter_in`, `reach_in`), or just a description string. Optional `holder` (string or `{description, runout_in}`) and `coating`. |
| `params` (or `cut_params`, or the same keys at the top level) | `tool_spindleSpeed`, `tool_feedCutting`, `maximumStepdown`, `optimalLoad` / `stepover`, `stockToLeave`, `verticalStockToLeave`; each an expression string with units (`"0.25 in"`, `"6 mm"`, `"108 in/min"`, `"12000 rpm"`), a `{expr, value}` dict, or a plain number read as inches / IPM / rpm. Flat aliases `rpm`, `feed_ipm`, `stepdown_in`, `stepover_in`, `stock_to_leave_in`, `axial_stock_in` (and `*_mm`) work too. |
| `geometry` | Measured feature geometry (inches or `*_mm`): `slot_width_in`, `channel_width_in`, `depth_in` (or `top_height_in` and `bottom_height_in`), `toolpath_length_in`, `tabs {count, width_in, height_in, style}`, and for T-slots `slot_height_in` and `radial_depth_in`. Needed for the strategy comparison; without them the op is analysed but no strategy is suggested (`strategy_notes` says what is missing). |
| `rest_machining` | `true`/`false` when the op uses rest machining (setup-level check). |
| `family`, `alloy` | Per-op material override. |

Operation `kind` (derived, or send `kind`): `adaptive`, `slot` (2D contour or slot whose width is about the tool diameter), `contour`,
`pocket`, `rough`, `face`, `finish`, `tslot` (slot mill / keyseat / T-slot tool type), `hole` (not analysed). A corner radius up to 15 % of the
diameter is treated as an edge break (square end mill) so the v2 model applies; a larger radius runs ToolWiz's bull-nose path (v1).

**For the add-in agent** the current `get_setup_summary` carries only the tool description and `SNAPSHOT_PARAMS`; the advisor needs, per op: the tool
geometry JSON (`op.tool.toJson()`), the holder name, `stockToLeave` and `verticalStockToLeave` (not in `SNAPSHOT_PARAMS` today), the op's
heights and toolpath length where Fusion exposes them, `rest_machining`, and `op_id` = the `"Setup > Op"` path.

## Findings

Per operation, each with `severity`, `code`, `title`, `detail`, `recommendation` and the ToolWiz `numbers` it quotes:

| Severity | Codes |
|---|---|
| STOP | `toolwiz_infeasible` (no safe cut at ToolWiz's own recommendation), `infeasible_at_engagement` (none at the op's stepdown / stepover), `chip_load_high` (programmed chip load more than 2x ToolWiz's), `rpm_over_machine`, `stepdown_over_flute`, T-slot: `stepdown_over_kerf`, `tslot_radial_high` (> 2x ToolWiz per pass), `feed_high`, `tslot_critical` |
| CAUTION | `chip_load_off`, `rpm_off`, `feed_off` (more than 40 % from ToolWiz), `stepdown_high`, `stepover_high` (> 1.4x recommended), `stock_radial_low`, `stock_axial_low` (below ToolWiz's recommended stock to leave), `reduced_flutes` (runout regime), `chip_near_rubbing`, `holder_runout` / `holder_type` (measured TIR or holder type against `holder_advice`), `tslot_provisional`, `tslot_warning`, plus the `oversight_*` findings of `oversight_engine` (tool / coating fit, shaft rub, deep slot, knife-edge window, unknown coating) |
| INFO | `time_saving` (ToolWiz's recommended engagement removes material N x faster: both MRRs quoted), `strategy` (the planner's recommended strategy is at least 10 % faster at similar wear), `holder_unknown`, `not_analysed`, `no_tool`, `toolwiz_error` |

Setup-level (`setup_findings`, from `oversight_engine.evaluate_setup_oversight` plus the add-in's `audit` issues when sent as `setup.audit`):
micro tool after a much larger rougher without rest machining; finishing before roughing; roughing that leaves no stock for the finishing op or less
than ToolWiz's recommended stock; stock left but no finishing operation; roughing to size with no finishing pass; avoidable tool changes.

## Strategy suggestions

For 2D contour / slot ops, and adaptive ops in a narrow channel (`channel_width_in` up to 3 x D), the advisor calls `strategy_planner.compare`
(see `docs/STRATEGY_PLANNER.md`): feature `slot` (width from the slot / channel, else the tool diameter) or `profile_cutout` (when the contour has
`tabs`), depth from the op heights, length from the toolpath length; candidates are the op's tool plus the other end mills of the setup that fit.
Slot-mill ops use the T-slot comparison with the op's cutter and the shop cutters of `data/shop_tools.json` whose kerf fits the slot height. The
suggestion reports the recommended option, the option matching the op's current approach, `time_saved_min` / `time_saved_pct`, the planner's
reasoning and all options; planned (not owned) shop cutters and provisional geometry are flagged in the options' `risks`.

## LLM narrative

`use_llm: true` builds a prompt only from the deterministic result (`setup_advisor.llm_view`): prioritised plain advice and strategy reasoning,
explicitly forbidden from introducing numbers. The reply is checked with `numeric_guard.check_numbers`; on failure one retry with a stricter prompt
naming the rejected numbers, then `narrative: null`, `narrative_check: {"ok": false, "rejected_numbers": [...]}` and the deterministic findings. No
API key (`GEMINI_API_KEY`): `narrative: null` with a note. The advisor never calls the LLM unless `use_llm` is true.

### Numeric guard (`toolwiz_common/numeric_guard.py`)

Extracts every number (decimals, `12,000`, `1/16`, `1 1/2`, with or without a unit) and requires each to match a number in the grounding JSON
(including digits inside its strings, so `6061-T6` grounds its own digits) within the larger of 0.5 % and half the last printed digit. Conversions are
applied only to numbers with units: in <-> mm, in/min <-> mm/min, SFM <-> m/min, in/tooth <-> mm/tooth, % <-> 0..1 ratios, min <-> s, in^3/min <-> cm^3/min. A
number with a unit must match a grounded number of the same quantity class (judged from the JSON key suffix such as `feed_ipm`, `chip_load_ipt`, `*_in`, or the unit
next to the number in a string), so `0.003 IPT` is not satisfied by a `0.003 in` stock to leave. A bare number must equal a grounded number (so small counts
need to appear in the JSON). Identifiers glued to letters (`2D`, `T6`, `4FL`), list markers and URLs are not numbers. Examples:

| Text | Grounding contains | Result |
|---|---|---|
| `13,800 rpm` | `rpm: 13821` | accepted (within 0.5 %) |
| `1.5875 mm` | `diameter_in: 0.0625` | accepted (in -> mm) |
| `365 mm/min` | `feed_ipm: 14.37` | accepted (IPM -> mm/min) |
| `0.003 IPT` | `stock_to_leave_in: 0.003`, `chip_load_ipt: 0.0012` | rejected (a length is not a chip load) |
| `Run 18000 rpm` | `rpm: 13821` | rejected |

## Bridge contract: `apply_operation_parameters`

Added to `fusion_bridge.ALLOWED_ACTIONS`. Command the add-in receives from `GET /api/fusion_bridge/next`:

```json
{"request_id": "...", "action": "apply_operation_parameters",
 "params": {"op_id": "Setup1 > Adaptive pocket",
            "params": {"tool_spindleSpeed": "11522 rpm", "tool_feedCutting": "4.45 in/min", "maximumStepdown": "0.02313 in", "optimalLoad": "0.00625 in",
                       "stockToLeave": "0.00300 in", "verticalStockToLeave": "0.00197 in"},
            "reason": "ToolWiz setup advisor recommendation", "advisor_generated_at": "2026-11-11T17:54:17"}}
```

Allowed parameter names (`fusion_bridge.APPLY_ALLOWED_PARAMS`, enforced by the server, enforce again in the add-in): `tool_spindleSpeed`, `tool_feedCutting`,
`tool_feedPlunge`, `tool_feedRamp`, `tool_rampAngle`, `rampAngle`, `helicalRampDiameter`, `maximumStepdown`, `stepdown`, `maximumStepover`, `stepover`,
`optimalLoad`, `stockToLeave`, `verticalStockToLeave`, `tabWidth`, `tabHeight`. Values are expression strings with units. The add-in must:

1. find the op by `op_id` (the `"Setup > Op"` path, as `_find_cam_operation` does);
2. **ask the user to confirm** (show each parameter's current and new value, the `reason`, and that the values come from ToolWiz);
3. write each parameter through the audited-command path (same as `apply_stock_to_leave`), skipping (not failing) a parameter the op does not have;
4. post the result to `POST /api/fusion_bridge/result`:

```json
{"request_id": "...", "result": {"ok": true, "applied": {"tool_spindleSpeed": {"old": "12000 rpm", "new": "11522 rpm"}},
                                  "skipped": {"optimalLoad": "operation has no such parameter"}, "error": null}}
```

`ok` is false (with `error`) when the user declines or the op is not found. The server returns this result as the apply response when `wait` > 0.

## MCP

`mcp_server.py` (stdio and `/api/mcp`): the `initialize` result carries `instructions` forbidding invented numbers (every number must come from a
`toolwiz_*` call), and every tool description repeats the rule. Tools: `toolwiz_calculate_cut`, `toolwiz_predict_stock_compensation`,
`toolwiz_search_materials`, `toolwiz_holistic_oversight`, `toolwiz_curate_tool_library`, `toolwiz_strategy_compare` (`/api/strategy/compare`),
`toolwiz_holder_advice` (`/api/advice/holder`), `toolwiz_tool_advice` (`/api/advice/tools`), `toolwiz_setup_advisor` (`/api/setup_advisor`, live Fusion state when
`setup` is omitted), `toolwiz_library_audit` (`/api/twin/audit`), `toolwiz_master_library_build` (`action: "start"` -> `/api/twin/build_sets`, `action: "status"` +
`job_id` -> `/api/twin/build_sets/<job_id>`), and the Fusion bridge tools `fusion_get_setup_summary`, `fusion_inspect_operation`, `fusion_audit_setup_sequence`,
`fusion_get_toolpath_status`, `fusion_apply_stock_to_leave`.

## AI chat (`/api/ai_chat`)

`ai_machinist.query_ai_machinist`: for a speed / feed / depth question without a result in the context, ToolWiz's numbers are computed
(`toolwiz_numbers_for`) and added to the prompt as the only numbers the model may quote. A live Gemini reply passes the same numeric guard against the
context, the ToolWiz numbers and the user's own question; on failure the reply is replaced by the deterministic ToolWiz numbers plus a short note
(`mode: "guard_fallback"`, `numeric_check` in the response). The offline expert (no API key) is deterministic code and is not guarded.
`ai_machinist.generate_text`, `is_available` and `ask_machinist` (guarded) are the shared helpers; the oversight engine's optional second opinion
now works (it called two functions that did not exist).
