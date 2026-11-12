# ToolWiz v3: implementation plan (trusted advisor)

Branch: `toolwiz/v3-advisor` (cut from `claude/relaxed-planck-jj379u` at `7818fcf`).
Every work package (WP) is done on its own branch `v3/<wp-id>` in its own git worktree and merged
into `toolwiz/v3-advisor` by the planner. Read `docs/REVIEW_AND_FIX_PLAN.md` Parts 4 and 5 first.

## Goals (from the owner)

1. Good starting speeds and feeds. **Aggressiveness 50% = relatively safe**: chip load about 0.92 x
   the vendor median for the bucket, engagement (ADOC, RDOC) inside the vendor envelope for that
   operation. 75% = vendor median. 100% = about 1.10 x vendor median with deeper engagement and
   accepted faster wear. (These anchors already exist as `CONSENSUS_SCALE_POINTS` in
   `physics_v2/optimize.py`; keep them.) *Superseded for the vendor guardrail by the owner decisions of 2026-11-12
   (50 % = the middle of the vendor's range; see below).*
2. When the test suite runs, the engine at 50% must fall inside the vendors' published ranges
   (acceptance test `tests/test_vendor_conformance.py`, defined below).
3. Micro tools (1/16" and below) handled by physics: deflection, stress and per-flute runout.
4. T-slot / keyseat cutters, including cutters with teeth on both faces (up and down cutting).
5. Tab milling: contour slotting around parts with tabs, compared against adaptive with a smaller
   tool, on cycle time and tool life.
6. Advice and warnings: tool series from specific manufacturers when it matters, holder type when
   runout matters (ER, precision ER, SK/SKC, hydraulic, shrink fit, Rego-Fix powRgrip, milling
   chuck), stock to leave so parts come off true to size, strategy advice.
7. Every Fusion add-in command updated, not just the auto-setter. Web app updated to match.
8. Optional LLM layer over the Fusion MCP bridge that advises on toolpaths. **It never produces
   numbers**: every speed, feed, depth, width or stock value it shows comes from a ToolWiz tool
   call and is checked against that call's result before display.

## Rules for every agent

- Work only in your worktree and on your branch. Commit there. Do not push. Do not merge.
- Physics first. Vendor data calibrates and validates; it is never pasted in as a lookup table,
  except the explicit consensus ceiling (C14) that already exists.
- Never loosen a test tolerance or edit a vendor row to make a test pass. If you cannot meet a
  target, stop and report the failing cases.
- Cite every number you add (URL or file + table).
- Lengths inside the engine are inches, feeds IPM, speed RPM/SFM. Convert only at the edges.
- `python -m pytest -q` must pass before every commit (baseline: 684 passed, 1 skipped).
- Keep files you don't own untouched except for the single registration lines named below.
- Use Flask blueprints for new endpoints (`routes_<name>.py`), registered with one line in
  `app.py` (`app.register_blueprint(...)`) next to the existing registrations.
- Write docstrings that say what a function does and its units. No changelog prose in code.
- End commit messages with:
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` and
  `Claude-Session: https://claude.ai/code/session_01Xpug32ECRa6dnjrtNjCdCp`

## API contracts (fixed; all agents code against these)

### Additions to `/api/calculate`, `/api/calculate_for_fusion` and `pipeline.CutResult`

| Field | Type | Owner | Meaning |
|---|---|---|---|
| `flutes_cutting` | int or null | WP-A1 | Flutes that form a chip at the chosen feed under the given runout |
| `runout_regime` | `"all_flutes"`, `"reduced_flutes"` or null | WP-A1 | v2 regime used (see REVIEW Part 5.3 item 1) |
| `tir_all_flutes_in` | float or null | WP-A1 | Largest runout at which every flute would cut at this feed |
| `runout_ratio` | float or null | WP-A1 | Tooth-to-tooth radial offset / feed per tooth |
| `engagement_source` | `"user"` or `"recommended"` | WP-A1 | Whether rpm/feed were computed for the user's DOC/WOC or the recommendation |
| `holder_advice` | object (below) | WP-B1 wires it in | From `toolwiz_common.tooling_advisor.holder_advice` |
| `tool_advice` | list (below) | WP-B1 wires it in | From `toolwiz_common.tooling_advisor.tool_advice` |

When the request carries explicit `cutDepth`/`cutWidth` from the user (the web sliders, or a Fusion
operation's own stepdown/stepover), rpm and feed must be computed for that engagement
(`engagement_source: "user"`), while `rec_doc`/`rec_woc` remain the optimizer's recommendation.

`holder_advice`:
```json
{"required_tir_in": 0.0001, "class": "standard|precision|ultra",
 "recommended": ["shrink fit", "hydraulic", "powRgrip"], "acceptable": ["SK/SKC precision collet"],
 "avoid": ["standard ER collet"], "reason": "text", "high_speed_spindle": "text or null",
 "sources": ["..."]}
```

`tool_advice` (list, possibly empty):
```json
[{"vendor": "Harvey Tool", "series": "...", "applies_to": "text", "why": "text",
  "expected_gain": "e.g. +40% MRR vs consensus in this bucket", "evidence": ["benchmark row ids"]}]
```

### New endpoints

| Endpoint | Owner | Body | Returns |
|---|---|---|---|
| `POST /api/advice/holder` | WP-A2 | `diameter, runout_in, fz_in, rpm, operation, stickout, flutes, taper` | `holder_advice` |
| `POST /api/advice/tools` | WP-A2 | `family, diameter, operation, flutes?, coating?` | `{"tools": tool_advice}` |
| `POST /api/strategy/compare` | WP-B1 | see below | see below |
| `POST /api/setup_advisor` | WP-B3 | `{setup, family, alloy, aggressiveness, runout, use_llm}` | see below |

`/api/strategy/compare` body:
```json
{"family": "...", "alloy": "...", "aggressiveness": 0.5, "runout": 0.0002, "model": "v2",
 "feature": {"type": "profile_cutout|slot|pocket", "width": 0.125, "depth": 0.25, "length": 12.0,
             "tabs": {"count": 4, "width": 0.1, "height": 0.02}},
 "candidate_tools": [{"diameter": 0.125, "flutes": 2, "flute_length": 0.375, "shank_diameter": 0.125,
                      "stickout": 0.6, "coating": "Uncoated", "geometry": "Square"}]}
```
Returns `{"options": [ {"name", "tool", "strategy": "contour_slot|contour_slot_small_tool|adaptive|...",
"levels", "ap", "ae", "rpm", "feed_ipm", "path_length_in", "cycle_time_min", "relative_tool_life",
"tool_wear_per_part", "risks": [], "notes": []} ], "recommended": "<name>", "reasoning": [..],
"assumptions": [..]}`. Cycle time includes the cutting path, the trochoidal loop overhead, ramp-in,
and linking at a stated rapid/link feed. Tool life is relative to the 50% baseline via the v2 Taylor
law (C7).

`/api/setup_advisor` returns `{"operations": [{"op_id", "name", "strategy", "current": {...},
"toolwiz": {...from the pipeline...}, "findings": [{"severity": "STOP|CAUTION|INFO", "title",
"detail", "recommendation"}]}], "setup_findings": [...], "strategy_suggestions": [...],
"narrative": "text or null", "narrative_check": {"ok": bool, "rejected_numbers": [...]}}`.

## Acceptance test: `tests/test_vendor_conformance.py` (owner WP-A1)

Data: `tests/benchmarks/v2/*.json` (plus any rows added by WP-A3). Machine: a test-only profile
with max rpm 60,000 and ample power, so vendor speeds are reachable. Runout 0.0002". Model v2.
Aggressiveness 0.5. Vendor tool geometry from the row (DC, LCF, flutes, helix, SFDM; stickout = LB
if given else LCF + 0.5 x SFDM).

1. **Fixed engagement (per row; rows of operation slot, side, hem, rough).** Request with the
   row's own ap and ae. Pass when
   - SFM is within [0.75 x vendor min, 1.25 x vendor max] (min = max = nominal when only nominal),
   - fz is within [0.60 x vendor min, 1.25 x vendor max].
   Pass rate must be >= 90% overall, and >= 85% separately for each operation and for tools at
   or below 1/16".
2. **Recommended engagement (per cell).** Cell = (material family, operation, diameter band:
   <=1/32, 1/32-1/16, 1/16-1/8, 1/8-1/4, 1/4-1/2, >1/2) with at least 3 rows. Pass when the
   engine's ae/D is within [0.8 x cell min, 1.25 x cell max] (side, hem, rough) and its ap/D is
   within [0.5 x cell min, 1.25 x cell max] (slot, hem). Pass rate >= 85% of cells.
3. Print a table of failures. These tolerances are fixed by the planner. Do not change them.

### Revision 2026-11-11 (after WP-A1 round 1)

Part 1 above was mis-specified: it compared one consensus-anchored engine value with each
individual vendor row, although vendors in the same bucket span about 2.4x (p10-p90) in chip load.
Measured: 0.92 x bucket median fz lands inside [0.60, 1.25] x the individual row only 72% of the
time, before SFM is checked. Replacement (tolerances unchanged, applied to the range vendors span):

1. **Per group** = (family, operation, diameter band, engagement class: slot | ae/D <= 0.10 |
   0.10-0.30 | 0.30-0.60 | > 0.60), >= 2 rows. The engine runs once per group at the group's median
   ap/D and ae/D on the group's median tool. Pass: SFM in [0.75 x group min, 1.25 x group max] and
   fz in [0.60 x group min, 1.25 x group max]. Groups whose minimum SFM needs > 60,000 rpm compare
   SFM with the achievable value (reported as spindle-limited). Targets: >= 90% of groups, >= 85%
   per operation and for D <= 1/16". The per-row numbers are printed as a diagnostic only.
2. Cell test (recommended engagement) unchanged.

Engine decisions made with this revision:
- C3 for rough/adaptive/slot = k x D, k = 0.5% + 1.0% x aggressiveness, with no fixed
  stock-to-leave cap. Part accuracy comes from the finishing pass: the engine outputs a recommended
  radial and axial stock to leave = max(0.05 mm, 1.5 x predicted deflection + springback).
- C2 on the nominal chip, with the worst-flute overload check (C2o) retained.
- When the chip-load floor exceeds the vendor ceiling (tiny tools), the ceiling wins, with a
  warning naming the need for a low-runout holder or more rpm.
- Stability continuity is judged relative to the chip: feed changes < 15% between TIR = 0 and
  TIR = 0.1 x fz.
- An adaptive v2 call must take <= 2 s, because the master library builder makes thousands of calls.

### Owner decisions, 2026-11-11 (later)

**Conformance runout.** The vendor-range test runs at 0.0001" TIR (vendor conditions: precision
holder), like the rigid test machine. Users' results always use their own runout (default 0.0002"
or measured), so ER-collet micro tools keep reduced feeds and holder warnings.

**Roughing objective.** Every non-finishing operation (adaptive, 2D/3D pocket clearing, slotting,
high feed, roughing contours, T-slot) defaults to the maximum material removal rate that works
reliably at 50%. Reliability = all hard limits and the vendor envelope at that aggressiveness.
Selection: the highest-MRR candidate; prefer the cut closest to the vendor medians only among
candidates within 3% of the best MRR (was 10%). The user can still override DOC/WOC.

**Finishing objective: finish modes.** Request fields `finishMode`, `targetRa` (micro-inches,
optional), `wallTolerance` (inches, optional):

| Mode | Purpose | Default target |
|---|---|---|
| `cleanup` (default) | Decent finish on a wall or floor that isn't critical; maximize MRR | Ra 63 uin (1.6 um), wall error <= 0.001" |
| `surface` | Best visible finish: limit feed marks and scallops | Ra 16-32 uin (0.4-0.8 um; default 32), user-settable |
| `accuracy` | Size-critical walls/floors: limit deflection and springback | wall error <= 0.0002" (5 um), user-settable |

Physics per mode (engine): peripheral wall finish from feed per tooth with runout (effective feed
mark spacing becomes z x fz when one flute generates the wall), cusp h = f^2/(8R); floor finish
from stepover and corner radius; ball/bull scallop h = ae^2/(8R_eff); Ra ~ h/4 (state the
approximation); wall error from the deflection model plus springback. Each mode maximizes MRR
subject to its targets and all hard limits. Response block `finish`: {mode,
predicted_ra_uin, predicted_cusp_in, predicted_wall_error_in, target_ra_uin, wall_tolerance_in,
limited_by, advice}. Advice includes spring-pass guidance (not in work-hardening alloys),
climb vs conventional, and the stock to leave from roughing that the finish pass needs.

### Owner decisions, 2026-11-12

A per-vendor comparison (`tools/vendor_compare.py`) showed that one cross-vendor average is wrong for specific brands
(roughing 1.32x Harvey's typical speed and above Harvey's published maximum in 41 of 54 groups; HEM 0.56-0.88x of most
vendors but 1.43x Harvey and 1.51x Helical). Decisions:

1. **Brand first.** When the tool's brand is known and that vendor has chart rows for the cut (same chart class;
   widened by diameter band, engagement and hardness within that vendor before giving up), the vendor guardrail (C14)
   uses that vendor's own values, not the cross-vendor average. Brand comes from the request field `brand`, else the
   Fusion tool's `vendor` (`toolwiz_common/brand.py`).
2. **No brand, or a brand with no charts** (most of the owner's library: "Klot (Amazon Ebay)", "KK DUK AliExpress or
   Temu", "SpeTool Amazon", "Speed Tiger", "Haas", "Maritool", blank): the more conservative Harvey Performance charts,
   Helical for HEM, Harvey + Helical for traditional roughing and the other operations where they have rows; where they
   have none, the cross-vendor consensus. "Conservative" is about speed: chip load still goes through every physics limit
   (C1-C8), never relaxed.
3. **50 % aggressiveness = the middle of the vendor's published range**, 0 % its bottom, 100 % its top (range = min..max
   over the bucket rows' min/nominal/max; middle = median of the nominal values; a single published value spans
   0.76-1.10x of it). Monotone and continuous (linear between the three points). Physics limits still cap everything.
   **This supersedes the 0.92 x median anchor of Goal 1 for the vendor guardrail (C14v, C14f, C14m).** The physics
   scales on C7 (tool-life speed level) and C2 (chip invariant) keep `CONSENSUS_SCALE_POINTS`, since relaxing them would
   relax a physics limit.
4. **HEM and traditional roughing are distinguished everywhere**: adaptive / HEM / dynamic / trochoidal toolpaths read
   the vendors' HEM charts; pockets, roughing contours and "Roughing" read the roughing charts (a vendor's side-milling
   chart when it has no roughing chart); they never share a bucket. The result field `vendor_basis` names the chart class
   used.

Implementation: `data/model_v2/consensus_by_vendor.json` (`tools/build_vendor_consensus.py`),
`physics_v2/optimize.vendor_lookup`, `range_at`, `c14_cap`; result field `vendor_basis`; notes and measured effect in
`docs/V4_ENGINE_NOTES.md`.

## Work packages

### Phase 1 (parallel)

**WP-A1 Engine (owner: `physics_v2/`, `v2_bridge.py`, `pipeline.py` result fields,
`tools/v2_invariants.py`, `data/model_v2/`, `machines/test_*.json`, new tests).**
M1-M4 of REVIEW Part 5.4 (reduced-flute regime, diameter-scaled deflection allowance, operation
envelopes plus slot depth table plus chip-load floor, consensus-anchored selection and local
refinement), the user-engagement path, the result fields above, the stability tests of M4 and the
conformance test above. M7 (chatter) is optional and off by default.

**WP-A2 Tooling advisor (owner: `toolwiz_common/tooling_advisor.py`, `data/holders.json`,
`data/tool_series.json`, `routes_advice.py`, its tests).** Holder rules from cited vendor TIR
specs; recommends a high-speed spindle attachment when the 16k spindle caps SFM badly on micro
tools. Tool series recommendations derived from the benchmark dataset (series that beat the
bucket consensus MRR by a material margin), plus curated application notes with citations.

**WP-A3 Data (owner: `tests/benchmarks/v2/*.json` new vendor files, `tests/benchmarks/tslot/`,
`tests/benchmarks/v2/SCHEMA.md` additions, `tests/test_v2_benchmark_dataset.py` additions).**
T-slot / keyseat cutter data (including double-sided cutters), more micro-tool data from vendors
with accessible charts (e.g. Performance Micro Tool, Lakeshore Carbide, Datron, Micro 100), and
any slotting data useful for tab milling. Same schema and citation rules.

### Phase 2 (after Phase 1 merges)

**WP-B1 Strategy planner and wiring (owner: `strategy_planner.py`, `routes_strategy.py`, wiring
`holder_advice`/`tool_advice` into `pipeline.py`).** Tab milling vs adaptive vs small-tool slot
comparison; stock-to-leave advice for true-to-size parts tied to the deflection model.

**WP-B2 T-slot and v1 clean-up (owner: `gwizard_physics.py`, T-slot parts of `pipeline.py`,
`tests/test_tslot_*.py`).** Up/down (face) cutting for T-slot and keyseat cutters. Owner decision
2026-11-11: staggered-tooth keyseat cutters (Harvey: "relieved to allow cutting on both sides of
head") are the up/down cutter class. Teeth alternate faces, so each face (and each periphery side
under a staggered layout) has about half the teeth: axial face cutting uses `teeth_per_face = z/2`
for feed per tooth, and peripheral slotting chip load follows the vendor's staggered-tooth data.
Owner's shop T-slot cutter (used for up and down cutting; must be a named test case and a preset in
`data/shop_tools.json`): "6mm x 2mm Titanium Coated Carbide T Slot End Mill Cutter"
(https://www.harfington.com/products/p-1341326): D 6 mm, cutting depth (kerf) 2 mm, shank 6 mm,
shank length 31 mm, OAL 50 mm, 4 flutes, solid carbide, "titanium" coating. Neck diameter, reach
and tooth form are not published (owner to measure; until then take neck = 3.5 mm and reach = 10 mm
as provisional, flagged in the output). No vendor cutting data exists for it: its numbers come from
the physics, checked for plausibility against Harvey keyseat data of similar diameter.
If its teeth are not staggered (every tooth has both face edges), `teeth_per_face = z`; conformance
against `tests/benchmarks/tslot/`; M6 of REVIEW Part 5.4 (roughing limit step, ramp from the
un-thinned chip load, docstring).

**WP-B3 LLM advisor and MCP (owner: `setup_advisor.py`, `routes_setup_advisor.py`,
`mcp_server.py`, `fusion_bridge.py`, `ai_machinist.py`).** Deterministic findings first; the LLM
narrative is optional, grounded on tool results, and checked by a numeric guard that rejects any
number not present in the tool results. MCP tools for strategy compare, holder and tool advice and
the setup advisor, with MCP instructions that forbid inventing numbers.

### Owner's T-slot cutters (2026-11-11)

| Tool | Status | Jobs |
|---|---|---|
| Klot/Harfington 6 mm x 2 mm, 4 flute, carbide, up/down cutting | in use | T-slots |
| Klot/Harfington 4 mm x 0.5 mm, carbide | in use | T-slots in 17-4 PH and titanium |
| Klot/Harfington 8 mm x 0.5 mm, carbide | in use | one-depth T-slot in titanium |
| Harvey Tool 3/8" x 0.0625" keyseat | planned replacement for the 8 x 0.5 | same titanium job |
| Klot/Harfington 8 mm x 1.6 mm | fallback if the Harvey is not worth it | same titanium job |

WP-B2 adds them to `data/shop_tools.json`. WP-B1's strategy planner must be able to compare
these cutters on the same job (cycle time, chip load, deflection, relative tool life) so the owner
can judge whether the Harvey cutter is worth it, and the advisor should flag when a premium
cutter's benefit comes from published vendor data versus physics alone.

### Master library builder (owner request 2026-11-11)

The owner wants one master library of every tool across open documents, hub/team libraries, cloud
and local libraries, populated with ToolWiz presets for selected materials and strategies, written
as separate libraries per **material set** (same tools, different presets). Default sets
(`data/material_sets.json`, editable):
- **Non-ferrous:** 6061-T6, 7075-T6, brass C36000, bronze (C54400 phosphor, C63000 Ni-Al),
  copper C11000.
- **Steels & exotics:** 4140 pre-hard ~30 HRC, 304/316, 17-4 PH, Ti-6Al-4V, zirconium 702,
  hardened tool steel (~50-60 HRC), CPM MagnaCut annealed and hardened, Black Titanium 5545.

**WP-B5 (server; owner: `master_library.py`, `routes_master_library.py`, `data/material_sets.json`,
tests).** Merge harvested libraries (dedupe by cutter geometry, but keep separate entries when the
holder/stickout differs by > 10%, since presets depend on stickout); per tool, plan strategies with
`toolwiz_common.tool_strategy`; generate presets for each selected material x strategy with the
pipeline; tag ToolWiz-owned presets so a rebuild replaces only those and keeps the owner's own;
run `library_audit` on the result (zero STOP required); write one Fusion-importable library per
set. Selective by tools (type, diameter range, source library, ids), sets, materials, strategies
and aggressiveness. Runs as a background job with progress and a result cache.

**WP-C1 additions (add-in).** Harvest from every source: the open documents' tool libraries,
hub/team libraries, cloud and local libraries, and an opt-in scan of a chosen hub project's
documents. Send them to WP-B5, then import the generated libraries into Fusion as named libraries
(e.g. `ToolWiz - Non-ferrous`, `ToolWiz - Steels & exotics`), updating in place on rebuild.

**WP-C2 additions (web).** A Master Library page: sources, tool filter, set and material pickers,
strategy picker, aggressiveness, progress, results with the audit, and download.

### Phase 3 (after Phase 2 merges)

**WP-C1 Fusion add-in (owner: `ToolWizFusionAddin/`).** Every command: auto-setter, stock to
leave, export, import, log cut, cleanup duplicates, snapshot compare, plus a new Setup Advisor /
Strategy command. Same model as the web page. Show warnings, holder and tool advice, runout regime.

**WP-C2 Web app (owner: `templates/index.html`, `static/`).** Show the new fields, a Strategy
Planner panel (tab milling), T-slot face-cutting inputs, holder/tool advice cards, the same model
default as the add-in, and the setup advisor.

### Phase 4

**WP-D Evaluation.** Full test suite, conformance report, micro-tool sweep, stability sweep,
written to `docs/V3_EVALUATION.md`.
