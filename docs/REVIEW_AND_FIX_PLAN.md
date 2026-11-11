# ToolWiz code review and fix plan

Reviewed 2026-11-10 at commit `0ff47f9`: the Flask server (`app.py`, `gwizard_physics.py`,
`tool_merger.py`, `backup_manager.py`, `ai_machinist.py`), the web app (`templates/index.html`)
and the Fusion add-in (`ToolWizFusionAddin/`).

Part 1 is the review. Part 2 is the fix plan, split into work packages that a smaller agent can
execute one at a time. Part 3 lists the decisions only the owner can make.

**Update 2026-11-11.** Parts 1–3 describe `master` at `0ff47f9` and are kept as written. Part 4
re-checks every finding against `toolwiz/hardening` at `24f6998`, which also contains the v2
physics engine that Parts 1–3 never saw. Part 5 is the design for micro-tool handling and
replaces WP-4, WP-5 and WP-6 of Part 2: that work should now be done in v2, not v1.

Every number below was produced by running the engine, not by reading the code alone. Reproduce
with `python scripts/micro_tool_sweep.py` (add `--stickout 0.5` for a realistic 1/8" shank
gauge length).

Baseline test status: `pytest tests` gives 72 passed, 1 failed (the failure needs a live server
on port 5000). `pytest` from the repository root does not run at all (see finding S3).

---

## Part 1 — Review

### 1.1 Answers to the three questions asked

**Are micro tools (1/16" and smaller) too conservative in adaptive roughing and slotting?**
Yes for adaptive, and the cause is not the physics. Slotting is mixed: too shallow in steel,
but deep enough to break the tool below about 1/32".

| Tool, material, auto-set at 50% | DOC | WOC | Deflection used | MRR (in³/min) |
|---|---|---|---|---|
| 1/16" 2FL, 6061, **Adaptive** | 0.10 × D | 0.41 × D | 5% of the limit | 0.0035 |
| 1/16" 2FL, 6061, **Slotting** | 0.84 × D | 1.00 × D | 98% of the limit | 0.0525 |
| 1/16" 4FL, 4130, Adaptive | 0.10 × D | 0.40 × D | 47% | 0.0051 |
| 1/16" 4FL, 4130, Slotting | 0.08 × D | 1.00 × D | 88% | 0.0080 |
| 0.010" 2FL, 6061, Slotting | 3.00 × D (full flute) | 1.00 × D | 84% | — |

Adaptive removes 15 times less material than slotting with the same 1/16" tool in aluminum.
Four separate defects produce this, in order of impact:

1. **Stepped shanks are modelled as a thin pin (finding P1).** With a real gauge length, a
   1/32" tool on a 1/8" shank is computed as 51 times more flexible than it is; a 0.010" tool,
   1,800 times.
2. **The stickout penalty uses stickout ÷ cutting diameter (P2).** A 1/16" tool at 0.5"
   stickout is "8 × D", so chipload is cut by 85% (feed 21 → 3.2 IPM) and the tool rubs.
3. **Adaptive depth is a fixed heuristic, not a search (P3).** DOC is capped at 0.08–0.10 × D
   below 1/16" regardless of how little deflection is used.
4. **The aggressiveness slider cannot change micro-tool depth (P4).** The deflection limit is
   pinned at a fixed 0.00035–0.0004" for every tool up to 1/8".

**Is the runout logic working?** No. There is no runout logic. The value travels from the UI
through `app.py` into `get_base_ipt(..., runout=...)` (`gwizard_physics.py:1736`) and is never
read. Setting runout to 0, 0.0002", 0.001" or 0.005" on a 1/32" tool returns identical RPM,
feed, chipload, depth and warnings. The Fusion add-in never sends runout at all. (Finding P5.)

**Where can the output be completely wrong?** Findings marked **Critical** below: C1–C6.

### 1.2 Critical — wrong speeds, feeds or machine data

**C1. The alloy's heat-treat condition is ignored.** `apply_alloy_hardness_scaling`
(`gwizard_physics.py:2054`) accepts a row when the alloy name is a substring of the request, so
the first condition listed for an alloy always wins. 440C Hardened (610 HB) gets the Annealed
(230 HB) speed; 17-4 H900 gets H1150-M; 6061-T6 gets 6061-O. 175 of 775 alloys have more than
one condition with different hardness. Hardened material is run at annealed speeds.

**C2. The hardness curve is anchored at the softest alloy in the family.** The multiplier is
`(minBHN / hardness) ^ (cexp / 15)`, and `minBHN` for wrought aluminum is 20. Any real alloy is
therefore derated: 7075 gets SFM × 0.39 and chipload × 0.56 relative to the family base, and
once C1 is fixed 6061-T6 (95 HB) would get SFM × 0.26. C1 and C2 must be fixed together.

**C3. "Cobalt (M42)" in the Fusion add-in is calculated as carbide.** The add-in sends
`tool: "Cobalt Endmill"` (`ToolWizFusionAddin.py:657`), which is not in the database. The
fallback maps it to "Carbide Endmill" because `/api/calculate_for_fusion` hardcodes
`is_carbide = True` (`app.py:366`). Result in 4130: 280 SFM instead of about 105. The same
hardcode makes an HSS tool three times stiffer than it is in the deflection model.

**C4. Batch preset generation treats every tool as high-performance carbide.**
`twin_batch_generate` sets `is_carbide = True` (`app.py:949`), uses "HP Carbide Twist Drill"
for every drill, reamer, spot drill, countersink and counterbore (`app.py:1001`) and "Carbide
Endmill" for every mill (`app.py:1070`). An HSS drill in 4130 is written at 248 SFM instead
of 70. Reamers get drill speeds and feeds.

**C5. The Fusion endpoint rounds DOC and WOC to 0.001".** `app.py:430-431` uses
`round(rec_doc, 3)`. For a 0.005" tool the add-in then writes `optimalLoad = 0.0000 in`; for
every tool at or below 1/32" the stepdown becomes exactly 0.001", up to 100% off. The feed was
computed for the unrounded values, so chip thinning no longer matches the cut.

**C6. The auto-setter overwrites the tool's length and diameter offsets.**
`json_mutator.py:96-98` sets `number`, `length-offset` and `diameter-offset` to the tool
number every time a preset is applied, and `extract_tool_number` falls back to `1` when it
cannot read a number. A tool that deliberately uses a different H or D offset is silently
changed. This is a crash risk at the machine and should be removed outright.

### 1.3 Major — physics defects (micro tools first)

**P1. Stepped-shank stiffness.** When "Relieved Neck" is unchecked, the UI sends
`neckDiameter = cutting diameter` and `neckLength = 0.5` (`index.html:2252-2253`), and
`app.py:135,173` defaults to the same. `calculate_deflection` (`gwizard_physics.py:787-789`)
then treats everything between the flutes and 0.5" as a neck of the cutting diameter, so the
shank diameter is ignored for the first half inch.

| Cutting dia, 1/8" shank, 0.5" stickout | Modelled compliance | Correct stepped compliance | Error |
|---|---|---|---|
| 0.010" | 0.943 in/lb | 0.000525 in/lb | 1,797× |
| 0.020" | 0.0591 | 0.000282 | 210× |
| 1/32" | 0.00998 | 0.000194 | 51× |
| 1/16" | 0.000663 | 0.000114 | 6× |

The three server paths disagree: `/api/calculate` and `/api/calculate_for_fusion` have this
bug; `twin_batch_generate` passes no neck and happens to get the stepped model right.

**P2. Stickout penalty.** `apply_chatter_penalty` (`gwizard_physics.py:2103-2112`) uses
`stickout / diameter` with a 3.5 × D threshold, cutting SFM to as little as 20% and chipload to
15%. That is meaningless for a micro tool on a 1/8" shank. The UI hides the problem by forcing
stickout to 3 × D (0.09" for a 1/32" tool, which cannot be held) and resetting any manual value
above 12 × D (`index.html:1398-1400`), so a real 0.5" gauge length cannot be entered for tools
under 0.042". `/api/calculate_for_fusion` applies no stickout penalty at all.

**P3. Adaptive optimizer.** `recommend_cut_parameters` (`gwizard_physics.py:882-898, 954-970`)
blends WOC from 45% of D at 1/32" to 10–18% at 1/4" and caps DOC at
`0.08 + (macro − 0.08) × t^2.305`. The search only walks up to that cap. A 1/8" tool in 6061
gets 0.35 × D at 33% WOC. The exponent 2.305 reproduces the benchmark file exactly (see T2), so
the tests lock this behaviour in.

**P4. Deflection limit.** `calc_deflection_limit` (`gwizard_physics.py:625-631`):
- Roughing and slotting use `0.002 × D × (0.2 + aggressiveness)` capped at 0.001". The
  docstring directly above says 0.006–0.010 × D clamped to 0.0004–0.0020". A 1/2" end mill
  slotting 4130 is recommended 0.010" deep; roughing at 50% WOC, 0.030" deep.
- A floor of 0.00035" applies only at or below 1/8", so the limit drops from 0.00035" at
  0.125" to 0.00018" at 0.126". A 3/16" tool is allowed less depth than a 1/8" tool.
- The floor is absolute, so it is 3.5% of diameter on a 0.010" tool and the slider has no
  effect on any tool up to 1/8".

**P5. Runout is unused** (see 1.1).

**P6. No breakage check.** The module docstring (`gwizard_physics.py:31`) claims bending-stress
and rupture-strength margins; none exist. Because of the absolute floor in P4, auto-set
slotting produces about 54 ksi at 1/16", 108 ksi at 1/32", 169 ksi at 0.020" and 285–337 ksi at
0.010" (force at the tip, fluted section). Tools under 1/32" are being sent toward fracture
while 1/16" tools are held back.

**P7. Ramp and plunge feeds are derived from the chip-thinned feed.** `calc_ramping`
(`gwizard_physics.py:1981-1992`) takes 50–75% of the cutting feed, which already includes
radial chip thinning (up to 5.5×) and the 1.3× adaptive factor. Ramping is a full-width cut,
so the tool ramps at 1.1× (steel) to 1.6× (aluminum) the slotting chipload on an adaptive
pass, and up to about 4× on a shallow ball-nose pass. The preset also hardcodes
`"ramp-angle": 2.0` (`json_mutator.py:87`) instead of the computed angle, which is lower for
micro tools.

**P8. Cutting-force calibration.** `unit_hp` is copied from the G-Wizard `mf` field: 4130 is
1.8, H13 2.1, 316 1.5. Handbook unit power for these is roughly 0.8–1.1 hp/in³/min, so steel
forces may be about double. Separately, the whole force is applied at the tool tip; for a
2 × D deep adaptive cut at 3.5 × D stickout that overstates deflection about 2.7×. I have not
confirmed what `mf` means in G-Wizard, so treat the first point as needing verification.

**P9. Drilling flute count.** The web UI leaves the flute slider at 4 when a drill is selected
and the server multiplies by it: a 1/4" HSS drill in 4130 gets 0.0066 IPR instead of 0.0033.

### 1.4 Major — Fusion add-in and units

- **F1.** `parse_dim_to_inches` (`ToolWizFusionAddin.py:79`) and `parse_dimension_in`
  (`tool_merger.py:26, 54`) guess the unit when none is given: above 1.5 is millimetres,
  otherwise inches. A 1.0 mm tool becomes 1.0".
- **F2.** Missing shank diameter defaults to `diameter × 25.4` and is then read in the tool's
  unit (`ToolWizFusionAddin.py:233`), giving a 1.59" shank on a 1/16" inch tool.
- **F3.** Stock compensation guesses feed units: above 150 IPM (server, `app.py:1493`) or
  above 120 (add-in, lines 1304 and 1317) is assumed to be mm/min and divided by 25.4. Real
  aluminum adaptive feeds exceed both.
- **F4.** Stock compensation multiplies the computed deflection and springback by
  0.6–1.4 depending on the aggressiveness slider (`app.py:1541`). Deflection at a given feed
  and speed does not depend on a preference slider.
- **F5.** `math` is used but never imported in the add-in (`ToolWizFusionAddin.py:1286`). The
  error is swallowed by a bare `except`, so the RPM fallback silently returns 0.
- **F6.** Unit toggle in the web UI rounds diameter and shank to 0.1 mm and back to 0.001"
  (`index.html:2056, 2060`). Toggling 0.010" to metric and back gives 0.012".
- **F7.** DOC/WOC sliders have a 0.001" minimum and step over a 0–2" range
  (`index.html:272, 280`), which is unusable for micro tools.
- **F8.** The add-in offers the auto-setter on every operation with a tool, including drills
  and taps, and always calculates them as a square or bull-nose end mill.

### 1.5 Structure, tests and documentation

- **S1. Four copies of the calculation pipeline.** `/api/calculate`, `/api/calculate_for_fusion`,
  `twin_batch_generate` and `stock_compensation` each rebuild lookup → hardness → penalty →
  aggressiveness → coating → RPM → chipload → feed with different steps and defaults. Most of
  the Critical findings are disagreements between these copies.
- **S2. Duplicated helpers.** Two diverged `json_mutator.py` files, three dimension parsers,
  two copies of `clean_and_eval_stock_expr`, and preset dictionaries built by hand in
  `app.py` as well as in the mutator.
- **S3. Tests.** Seventeen ad-hoc `test_*.py` scripts sit in the repository root; several
  call a live server at import time, so `pytest` fails during collection. Running `pytest tests`
  overwrites the tracked `data/working_library.json` and writes into `backups/`.
- **T2. Vendor benchmarks look fitted to the code.** `tests/benchmarks/vendor_catalog_data.json`
  attributes targets to Harvey and Helical part numbers, but the micro targets match the code's
  output, not typical catalog practice (for example 1/16" adaptive DOC must be
  0.0055–0.0065"). I could not retrieve the vendor charts in this session to confirm, so
  treat these targets as unverified.
- **S4. Size and layering.** `gwizard_physics.py` is 2,279 lines, `index.html` 4,583 lines with
  74 inline functions, the add-in 2,094 lines with 38 bare `except:` blocks and the server URL
  repeated nine times. `recommend_cut_parameters` is one 220-line function with 20 parameters.
- **S5. Documentation drift.** Class and module docstrings are good, but several describe
  behaviour that does not exist (stress margins, deflection limits, runout). The README lists
  only Flask (the AI module needs `httpx`), there is no `requirements.txt`, and the changelog
  cites test files that are not in the repository (`test_nitronic_60_regime.py`).
- **S6. Repository contents.** 193 MB of bundled JRE and decompiler binaries under `tools/`,
  and 1,920 decompiled G-Wizard ActionScript files under `gwizard_source/`.

### 1.6 Minor

- The Gemini API key is sent in the URL query string (`ai_machinist.py:359, 473`); `httpx`
  errors include the URL and are returned to the browser as `str(e)`.
- `clean_and_eval_stock_expr` uses `eval` behind a character whitelist that still allows
  `9**9**9**9` (`app.py:1388`).
- `/api/twin/upload` accepts multipart posts with no origin check, so any web page open in the
  same browser can replace the working library.
- All API errors return HTTP 200 with `success: false` and the raw exception text.
- `parse_hardness` takes the largest number in the string; `"4140 - Pre-Hardened (~30 HRC)"`
  parses as 4140 HRC when no database row matches.
- "HP Carbide Endmill" chipload is lower than standard "Carbide Endmill" in 316 and 4130, and
  carbide chipload is lower than HSS in titanium. The data rows look hand-edited.
- Adaptive passes at or below 15% WOC are flagged as finishing (`app.py:248`) and get a wear
  compensation tip.
- The batch endpoint treats an aggressiveness of exactly 1 as 100% (`app.py:967`).
- The add-in manifest description still says "via MCP and Custom Events".

---

## Part 2 — Fix plan

### Rules for every work package

1. Work on branch `claude/relaxed-planck-jj379u`. One work package per commit.
2. Before and after: run `python -m pytest tests -q` and `python scripts/micro_tool_sweep.py`.
   Paste both sweeps' relevant rows into the commit message.
3. Do not change `materials_database_clean.json` values unless the package says so.
4. Do not edit `tests/benchmarks/vendor_catalog_data.json` to make a test pass. If a benchmark
   fails because of an intended change, mark that case `xfail` with the package ID as the
   reason and list it in the commit message. WP-12 resolves them.
5. Units inside the engine are inches, IPM, RPM. Convert only at the edges.
6. Stop and report instead of guessing when a step says "owner decision".

Order: WP-0 → WP-1 → WP-2 → WP-3 → WP-4 → WP-5 → WP-6 → WP-7 → WP-8 → WP-9 → WP-10 →
WP-11 → WP-12. WP-1 packages are independent of each other. WP-5 depends on WP-2, 3, 4.

### WP-0 — Make the tests safe to run (small)

- Add `requirements.txt` (`flask`, `httpx`) and `requirements-dev.txt` (`pytest`).
- Add `pytest.ini` with `testpaths = tests`.
- Let `BackupManager` take its base directory from the environment variable
  `TOOLWIZ_DATA_DIR` when set. Add `tests/conftest.py` that points it at a temporary
  directory before `app` is imported.
- Move root `test_*.py` files that have assertions into `tests/`; move the rest into
  `scripts/dev/`. Mark the live-server test in `tests/test_stock_manager_mock.py` so it uses
  the Flask test client.
- **Done when:** `pytest` from the root passes, and `git status` is clean afterwards.

### WP-1 — Local correctness fixes (each small, independent)

| ID | Change | Done when |
|---|---|---|
| 1a | `app.py:430-431`: return `doc` and `woc` rounded to 5 places. In the add-in, format with `:.5f`. | Fusion endpoint for a 0.005" tool returns non-zero `woc`; 1/32" adaptive `doc` equals the web value. |
| 1b | `/api/calculate_for_fusion`: read `isCarbide` from the payload. Add-in: send `isCarbide` (false for HSS and cobalt) and send `"HSS Endmill"` for cobalt until a cobalt row exists. | 1/4" cobalt in 4130 returns under 120 SFM. |
| 1c | `json_mutator.py`: delete lines 91–98 (the `post-process` block). Keep one copy of the file (the add-in's); make `app.py` import it; delete the root copy and update `tests/test_fusion_json.py`. | A tool with `length-offset` 12 and number 5 keeps both after mutation. New test asserts it. |
| 1d | `twin_batch_generate`: derive `is_carbide` from the tool's `BMC` field (same rule as `ToolWizFusionAddin.py:273`). Pick the database tool by type: drill, spot drill, reamer, tap; use HSS rows when not carbide. Skip tool types with no matching row and report them in the response. | HSS drill in 4130 gives 60–80 SFM; reamer gets the reamer row. |
| 1e | Add-in: `import math`. Replace `geo.get("SF", diameter * 25.4)` with a lookup that falls back to `diameter` (already in inches). | Unit test on `get_op_tool_info` logic with SF missing. |
| 1f | Dimension parsing: when no unit is known, do not guess. Read `unit` from the tool, then from the library's first tool, else raise a clear error. Apply in the add-in and `tool_merger.py`; make `app.parse_dim` the single shared function. | A unitless `1.0` raises; `1.0` with `millimeters` gives 0.03937. |
| 1g | `index.html` `toggleUnit`: convert with 4 decimals in mm and 5 in inches for diameter, shank, neck, corner radius. Keep the true inch value in a `data-inches` attribute and convert from it. | 0.010" → mm → inch returns 0.0100. |
| 1h | Web UI: when the tool is a drill, set flutes to 2 and mark it auto-set. Server: for drill tool types ignore `flutes` above 3. | 1/4" HSS drill in 4130 returns about 0.0033 IPR. |
| 1i | Stock compensation: delete the feed-unit guesses (`app.py:1486-1494`, add-in 1304 and 1317). The add-in must read the evaluated value (cm/s) first and convert exactly. Delete the aggressiveness scaling at `app.py:1540-1545`. | 200 IPM in an inch document is passed through as 200. |

### WP-2 — Correct stepped-shank stiffness (medium) — fixes P1

- In `/api/calculate` and `/api/calculate_for_fusion`: when the tool has no relieved neck and
  is not a form cutter, call the deflection and recommendation functions with
  `neck_diameter=None, neck_length=flute_length`. Keep a separate `tip_neck_diameter = diameter`
  for `generate_advanced_strategies` so the neck-collision tip stays quiet.
- In `BeamDeflectionEngine.calculate_deflection`: when `shank_dia > diameter` and there is no
  neck, model the transition as a cone from `diameter` to `shank_dia` with a 15° half angle
  using the existing `calc_tapered_neck_integral`, clipped to the stickout. Then the shank.
- Web UI: stop sending `neckLength`/`neckDiameter` when "Relieved Neck" is unchecked.
- **Done when:** a new unit test reproduces the "Correct" column of the table in P1 within
  ±25% (the cone adds a little compliance), and a tool whose shank equals its cutting diameter
  gives the same deflection as before, within 1%.

### WP-3 — Stickout penalty based on real stiffness (medium) — fixes P2

- Add `BeamDeflectionEngine.effective_stickout(...)`:
  `stickout × (C_actual / C_reference) ^ (1/3)`, where `C_actual` is the tool's tip compliance
  (deflection per pound, after WP-2) and `C_reference` is the compliance of the same tool with
  its shank diameter set equal to the cutting diameter. For an ordinary tool the two are equal
  and the result is the stickout itself.
- `apply_chatter_penalty` uses `effective_stickout / diameter` instead of
  `stickout / diameter`. Thresholds and slopes stay as they are.
- Apply the penalty in `/api/calculate_for_fusion` as well.
- Web UI `checkOutOfSpecGeometry`: when shank is larger than cutting diameter, default
  stickout to `max(flute_length + 0.25", 0.5")` and never reset a manual value below 1.5".
- **Done when:** 1/16" 2FL, 1/8" shank, 0.1875" flute, 0.5" stickout in 6061 adaptive has
  `base_ipt` at least 75% of the 0.22" stickout value (today it is 15%); any tool whose shank
  equals its cutting diameter gets exactly the same penalty as before.

### WP-4 — Deflection limit and breakage limit (medium) — fixes P4, P6

- `calc_deflection_limit`, roughing and slotting branch: implement the documented rule,
  `limit = D × (0.006 + 0.004 × aggressiveness)`, clamped to 0.0020" maximum. Remove the
  `diameter <= 0.125` floor. Adaptive branch: same rule with a 0.0030" maximum.
- Add `BeamDeflectionEngine.bending_stress(force, ...)`: maximum of `M × c / I` over the
  fluted section root and each step, with the force at the tip.
- Add `CuttingMechanics.allowable_stress(is_carbide, aggressiveness)`: carbide
  `100 + 100 × aggressiveness` ksi, HSS/cobalt `80 + 60 × aggressiveness` ksi. **Owner
  decision D2** confirms these.
- `recommend_cut_parameters`: a candidate is unsafe when deflection, power **or** stress
  exceeds its limit. Return which limit stopped the search; include it in the API response as
  `rec_limited_by` (`deflection`, `stress`, `power`, `flute_length`, `rule`).
- Add a "Tool Breakage Risk" critical tip when the user's own cut exceeds the stress limit.
- Update the docstrings to match.
- **Done when:** the limit is monotonic in diameter from 0.005" to 1" (new test); auto-set
  slotting stress is at or below the allowable for every row of the sweep; changing
  aggressiveness from 0 to 100 changes the recommended DOC for a 1/16" tool.

### WP-5 — Replace the adaptive and slotting heuristics with a constrained search (large) — fixes P3

Depends on WP-2, 3, 4. Rewrite only the adaptive and slotting branches of
`recommend_cut_parameters`; move them into a new function each.

Adaptive:
1. Candidate WOC ratios: non-ferrous `[0.08, 0.10, 0.15, 0.20, 0.25]`, steels and stainless
   `[0.05, 0.07, 0.10, 0.15]`, titanium and nickel `[0.04, 0.06, 0.08, 0.10]`.
2. For each, find the largest DOC up to `min(flute_length, 2 × D)` that passes deflection,
   stress and power, using the existing step loop.
3. Reject a candidate whose true chip thickness is below the minimum chip thickness.
4. Choose the highest MRR. On a tie within 5%, prefer the deeper cut.
5. Delete the `t ** 2.305` blend and the 45% micro stepover.

Slotting:
1. WOC = D. DOC cap by material: non-ferrous 1.0 × D, steels 0.5 × D, stainless, titanium and
   nickel 0.5 × D; multiply by 0.5 for tools under 1/8". **Owner decision D1** confirms caps.
2. Largest DOC under the cap that passes deflection, stress and power.

- **Done when:** for every row of the sweep, adaptive either uses at least 60% of one limit or
  reaches the depth cap (report `rec_limited_by`); adaptive MRR for the 1/16" 2FL 6061 case is
  at least five times today's 0.0035 in³/min; results fall inside the provisional bands in
  Part 3 D1; MRR is non-decreasing in aggressiveness.

### WP-6 — Implement runout (medium) — fixes P5

Definitions: `TIR` is the runout input. Tooth-to-tooth radial difference
`delta = TIR × sin(π / flutes)`. Nominal chip thickness `h` is the true chip thickness after
chip thinning.

- `h_peak = min(h + delta, flutes × h)` and `h_low = max(0, h − delta)`.
- Add `CuttingKinematics.runout_chip_load(h, tir, flutes)` returning both plus
  `ratio = delta / h`.
- Chipload derate, milling tools only: when `ratio > 0.5`, multiply chipload by
  `max(0.6, 1.5 / (1 + ratio))`. **Owner decision D3** confirms the threshold and floor. Note
  that the default 0.0002" is already about 70% of the chip thickness on a 1/32" tool, so the
  default itself triggers a derate there.
- Use `h_peak / h` to scale the force in the stress check (WP-4), not in the deflection check.
- Tips: warning when `ratio > 0.5`; critical when `ratio > 1.0` or `TIR > 0.01 × D`; add
  "only one flute is cutting" when `h_low` is below the minimum chip thickness.
- Return `runout_ratio`, `peak_chipload` in `/api/calculate`. Show them in the UI next to the
  chipload.
- Remove the unused `runout` parameter from `get_base_ipt`; pass runout where it is used.
- Add a runout field (default 0.0002") to the add-in dialog and send it.
- **Done when:** on a 1/32" 2FL tool slotting 6061, runout 0 → 0.0002" → 0.001" gives strictly
  decreasing feed and escalating tips; runout 0 reproduces the pre-change numbers exactly; a 1/2" tool at
  0.0002" is unchanged within 2%.

### WP-7 — Ramp and plunge feeds (small) — fixes P7

- `calc_ramping` takes the un-thinned chipload (after hardness, penalty, aggressiveness and
  runout derate) plus RPM and flutes. Ramp feed = `rpm × flutes × chipload × factor`, plunge
  likewise, keeping the existing material factors.
- Return `ramp_angle` from `/api/calculate_for_fusion`; use it in `json_mutator.py` instead of
  2.0.
- **Done when:** ramp feed is never above the slotting feed for the same tool; plunge feed is
  never zero when cutting feed is positive (existing test keeps passing).

### WP-8 — Alloy condition and hardness anchoring (medium) — fixes C1, C2

- Matching: normalize the request into `(alloy, condition)`; accept `"A (C)"` and `"A - C"`.
  Match the exact alloy and a condition whose comma-separated tokens include the requested
  one. Fall back to the alloy's hardest listed condition (conservative) and add an info tip
  naming the condition used. Remove the substring match.
- `parse_hardness`: when "HRC" is present use the number immediately before it.
- Add `ref_bhn` per family in a new `family_reference_hardness.json`, loaded by
  `GWizardPhysics`. Fill it with the hardness of the alloy named in the family label in its
  usual supply condition; where none is named use the median of the family's alloys.
  **Owner decision D4** reviews this table before merge.
- Scaling becomes `(ref_bhn / hardness) ^ (cexp / 15)`, clamped to 0.05–1.0.
- Add-in: remove the hardcoded `alloys_dict`; when the server is offline show
  "Standard Grade" only.
- **Done when:** 440C Annealed and Hardened give different SFM, hardened lower; 6061-T6 gives
  a multiplier of 1.0; 7075-T6 gives at least 0.85; every alloy with several conditions has
  non-increasing SFM with hardness (table-driven test over all 175).

### WP-9 — One calculation pipeline (large) — fixes S1

- New module `cut_pipeline.py` with a `CutRequest` dataclass (all inputs, inches) and
  `compute_cut(physics, request) -> CutResult`. Move the body of `/api/calculate` into it
  unchanged first, with a test that the endpoint's JSON is identical before and after for 30
  recorded payloads.
- Then make `/api/calculate_for_fusion`, `twin_batch_generate` and `stock_compensation` build a
  `CutRequest` and call it. Each endpoint keeps only parsing, unit conversion and response
  shaping.
- Build presets in one place (`json_mutator`).
- **Done when:** the same tool, material and operation give the same RPM, feed, DOC and WOC
  through all three calculation endpoints (new test), and `app.py` has no direct calls to
  `get_base_sfm` or `get_base_ipt`.

### WP-10 — Force calibration (medium, after owner input) — P8

- Apply the cutting force at `DOC / 2` above the tip in `calculate_deflection` (integrate from
  the load point and add the rigid-body tip extension).
- **Owner decision D5:** replace `unit_hp` for steels, stainless and titanium with handbook
  unit-power values, or keep `mf`. Do not change the data without that decision.

### WP-11 — Structure, UI and documentation (medium)

- Add-in: one `SERVER_URL` constant; replace bare `except:` with `except Exception` plus a log
  line to a file in the add-in folder; filter the auto-setter's operation list to milling
  operations; update the manifest description.
- Split `gwizard_physics.py` into a package (`kinematics`, `mechanics`, `deflection`,
  `optimizer`, `advisor`, `threads`, `facade`) with the facade re-exporting today's names.
- Move the inline script of `index.html` to `static/app.js` unchanged; set DOC/WOC slider
  range to `0 … 4 × D` with step `D / 500` whenever diameter changes.
- Security: send the Gemini key in the `x-goog-api-key` header; replace `eval` with a small
  arithmetic parser or `ast`-based evaluator that rejects `**`; require a custom header on
  `/api/twin/upload`; return HTTP 400/500 with a generic message and log the detail.
- Rewrite the README (install, run, test, architecture, add-in install) and correct the
  changelog entries that cite missing tests.

### WP-12 — Rebuild the vendor benchmarks (needs owner data)

- Replace each target in `vendor_catalog_data.json` with values copied from the vendor's
  published chart, adding `source_url` and the date read. Use realistic stickout and shank
  values.
- Remove the `xfail` marks added under rule 4.

---

## Part 3 — Owner decisions

| ID | Decision | Recommended default |
|---|---|---|
| D1 | Target bands for auto-set at 50%. These are my engineering estimates, not catalog data, and need your confirmation or vendor numbers. | Slotting DOC: aluminum 0.5–1.0 × D (0.25–0.5 under 1/8"); steel 0.25–0.5 (0.1–0.25 under 1/8"); stainless and titanium 0.2–0.5 (0.1–0.25 under 1/8"). Adaptive: WOC 5–15% in steels, 8–25% in aluminum; DOC 1–2 × D at or above 1/8", 0.5–1.5 × D below, subject to the stress limit. |
| D2 | Roughing deflection limit and allowable bending stress. | Deflection 0.6–1.0% of diameter across the slider, capped at 0.002" (0.003" adaptive). Stress: carbide 100–200 ksi, HSS/cobalt 80–140 ksi. |
| D3 | Runout derate threshold and floor. | Derate when tooth-to-tooth runout exceeds 50% of chip thickness, never below 60% of nominal chipload. |
| D4 | Reference hardness per material family. | Hardness of the family's named alloy in its usual supply condition (6061-T6 = 95 HB). |
| D5 | Whether `mf` is a valid unit-power value for steels. | Compare three steels against Machinery's Handbook before changing data. |
| D6 | Whether `tools/` and `gwizard_source/` belong in the repository. | Remove both from the tree; keep a script that fetches the tools if still needed. |

---

## Part 4 — Review of `toolwiz/hardening` (2026-11-11, commit `24f6998`)

Method: the branch's own suite (`pytest`: 682 passed, 3 failed), `scripts/micro_tool_sweep.py`,
direct calls to every endpoint, and `scripts/v2_candidate_probe.py` for the v2 optimizer.

### 4.1 Status of the Part 1 findings

| Finding | Status | Evidence |
|---|---|---|
| C1 condition ignored | Fixed | 440C Annealed SFM × 1.13, Hardened × 0.75 |
| C2 hardness anchor | Fixed | 6061-T6 × 0.97, 7075-T6 × 0.80. Softer-than-reference alloys are now sped up (6061-O × 1.17); confirm that is wanted |
| C3 cobalt as carbide | Fixed in the add-in | Cobalt with `isCarbide: false` gives 105 SFM. The endpoint still defaults to carbide when the field is absent |
| C4 batch all HP carbide | Fixed | Reads tool material; drills, reamers and taps use their own rows |
| C5 Fusion rounding | Fixed | 0.005" tool: stepover 0.00125" |
| C6 offsets overwritten | Fixed | `json_mutator.py` no longer touches `post-process` |
| P1 stepped shank | Fixed | Tool profile segments drive deflection |
| P2 stickout penalty | Fixed | 1/16" at 0.5" stickout: 15.6 IPM against 24.0 short (was 3.2 against 21) |
| P3 adaptive heuristic (v1) | Fixed | 1/16" 6061: 2 × D at 25% stepover |
| P4 deflection limit (v1) | **Partly** | Adaptive and slotting scale with diameter and the slider works. "Roughing" still drops from 0.00035" at 0.125" to 0.00018" at 0.126", and a 1/2" tool in 4130 at 50% stepover still gets 0.12 × D |
| P5 runout unused | **v1: no. v2: yes** | v1 only adds a tip; feed and depth are identical from 0 to 0.005". v2 models runout per flute (see Part 5) |
| P6 no breakage check | **v1: no. v2: yes** | v1 docstring still claims one. v2 has a fatigue-stress check (C4) |
| P7 ramp from thinned feed (v1) | **Open** | Adaptive ramp feed is 1.13–1.64 × the slotting feed for the same tool |
| P8 force calibration | Superseded | v2 uses Kienzle coefficients and applies the load at its centroid |
| P9 drill flutes | Fixed | 2 and 4 flutes give the same feed |
| F1–F5, F7, F8 | Fixed | Unit guesses, shank default, feed guesses, `math` import, slider step, hole operations |
| F4 aggressiveness scaling of stock compensation | Replaced | Now an explicit strength setting |
| F6 unit toggle rounding | Not checked | |
| S1 pipeline duplication | Fixed | `pipeline.py`; `stock_compensation` still assumes carbide (`app.py:1911, 1923`) |
| S3 tests | Fixed | `pytest` runs from the root and writes to a temp directory |
| S6 repository contents | Open | `tools/` (193 MB) and `gwizard_source/` remain; 17 root-level test scripts remain |
| Minor: `eval`, API key in URL, upload CSRF, HTTP status | Fixed | |

### 4.2 New problems on this branch

**N1. The web page and the Fusion add-in use different engines by default.**
`templates/index.html:271` selects v2 and sends `model: "v2"`. The add-in sends no model, and
`v2_bridge.resolve_model` falls back to v1. The same tool gets different numbers in the two
clients until someone changes the selector on the page, which saves a setting both then follow.

**N2. v2 chooses impractical cuts.** Examples (LOC 3 × D, 1/8" shank or larger):

| Case | v2 result |
|---|---|
| 1/4" 4FL, 6061, adaptive, runout 0 | 3 × D deep, 0.90 × D wide, 20 IPM (0.0003" per tooth) |
| 1/16" 3FL, 6061, adaptive, runout 0 | 3 × D deep, 0.90 × D wide, 9 IPM |
| 1/4" 4FL, 4130, slotting, runout 0 | 3 × D deep (0.75" slot), 1.6 IPM (0.00007" per tooth) |
| 1/8" 3FL, 6061, slotting, any runout | 3 × D deep slot |

The cause is in the selection, not the force model. Part 5.2 explains it.

**N3. v2 output jumps with small input changes.** 1/16" 3FL adaptive in 6061: feed
9.3 → 13.9 → 9.7 → 4.7 IPM as runout goes 0 → 0.0001" → 0.0002" → 0.0005", with stepover
flipping between 45% and 90% of diameter. Zero runout gives the worst answers, and
`v2_bridge.py:136` now lets zero through.

**N4. v2 rejects most micro tools at the default runout.** At 0.0002", 2-flute tools at or
below 1/32" return "no safe cut" in aluminum and steel adaptive and in aluminum slotting, and
the response carries v1 numbers with a warning not to run them. A 1/32" tool becomes feasible at
about 0.00013", a 0.020" tool at 0.00008", a 0.010" tool at 0.00003".

**N5. Three tests fail.** `test_addin_server.py::test_set_preset_steps_matches_names` expects
4-decimal strings (the code now writes 5); `test_web_model_switch.py` expects the old
"v2 (physics, beta)" label; `test_tool_profile.py::test_t13_full` needs `t13_full.json`, which
is git-ignored.

**N6. The server detects the test client.** `app.py:462-467` ignores the saved model when the
host is `localhost` with no port. Tests therefore never exercise the path real users hit.
Pass the settings path into the app from `conftest.py` instead.

**N7. This document was corrupted** on the hardening branch by a save in the wrong encoding
(every ×, — and ³). The copy on `claude/relaxed-planck-jj379u` is the good one.

### 4.3 Correction to my earlier advice

I recommended keeping v1 as the default. That was right as a stop-gap and wrong as a
direction. v1 has no model of a micro tool: no per-flute runout, no breakage limit, forces from
a unit-power constant. v2 has all three, built on 1,466 vendor rows. Its defects are in how it
picks among feasible cuts and in three limit definitions. Fix those and make v2 the default for
both clients; keep v1 as the fallback for tool types v2 does not cover.

---

## Part 5 — Micro tools: deflection and runout in the physics engine

### 5.1 What v2 already does correctly

- **Runout per flute** (`physics_v2/optimize.py`, `Engagement`): each flute sits at its own
  radius, so each has its own radial engagement and chip thickness, including flutes that miss
  the stock entirely. The worst phase of the runout is searched (`runout_offsets_worst`).
- **Forces**: Kienzle specific force at each flute's own chip thickness, integrated along the
  helix, giving force, torque and the height of the load on the tool for each rotation angle.
- **Deflection**: stepped beam from the real tool profile, load applied at its centroid, holder
  compliance in series (`CutPoint._beam`).
- **Breakage**: principal stress at each critical section against a carbide fatigue limit
  (C4, 1425 MPa).
- **Chip limits**: minimum chip thickness from edge radius (C1); worst-flute chip against the
  vendor median for the diameter band (C2).

This is the right model for a micro tool. Nothing here needs replacing.

### 5.2 Why it still gives bad answers

Measured with `scripts/v2_candidate_probe.py`.

**Cause A — every flute is required to cut.** C1 is applied to the thinnest flute. With
runout T, a 2-flute tool needs a feed per tooth above roughly T before the low flute touches,
while C2 caps the high flute. On a 1/16" tool at 0.0002" the feasible feed window at 5% stepover
is 0.000464–0.000538". Below 1/32" the window closes and the optimizer reports "no safe cut".
In practice a small tool at ordinary runout cuts on one flute; that costs tool life, not the
tool. Forcing `c1_flute="wall"` (the generating flute only) makes every case in N4 feasible.

**Cause B — the objective is flat in depth, and the tie-breaks pick the extreme.** Once
deflection (C3) binds, going deeper moves the load toward the shank, so depth costs almost no
deflection and the feed falls in proportion. For the 1/4" slot in 4130:

| Depth | Feed (IPM) | Feed per tooth | MRR (in³/min) |
|---|---|---|---|
| 0.25 × D | 17.7 | 0.00075" | 0.277 |
| 1 × D | 3.5 | 0.00015" | 0.217 |
| 3 × D | 1.7 | 0.00007" | 0.313 |

All three are within about 30% in MRR. The rule "deepest cut within 10% of the best score",
followed by the robustness tie-break (`optimize.py:1896-1916`), then picks the deepest and
widest candidate at the smallest chip. The same flatness makes the choice flip when any input
moves (N3).

**Cause C — nothing stops a deep, wide cut except deflection.** There is no chip-evacuation
limit for slots at or above 1/8" (C8 stops there), no upper bound on "adaptive" stepover below
0.9 × D, no lower bound on chip load other than the rubbing limit (0.000024" on the 1/4" tool),
and no chatter limit.

**Cause D — the deflection allowance does not scale.** C3 is 50% of a fixed 0.05 mm stock to
leave, 0.00098" for every tool. That is 0.4% of a 1/4" tool, 1.6% of a 1/16" tool and 10% of a
0.010" tool, where the stress check takes over at about 3.5%.

### 5.3 Design

Keep the model. Change four things.

**1. Two runout regimes, never "no safe cut" for runout alone.**
- *All flutes cutting*: as now (C1 on the thinnest flute).
- *Reduced flutes*: when that is infeasible, re-solve with C1 on the wall-generating flute.
  C2 and C4 still use the worst flute's true chip, which the engagement model already computes
  as up to `z × fz`. Report the number of flutes cutting, the runout at which all flutes would
  cut (`max_feasible_tir`), and a tool-life warning.
- Results must be continuous as runout goes to zero and non-increasing in runout.

**2. Deflection allowance tied to diameter.**
`C3 allow = min(50% of stock to leave, k × D)`, with `k` from 0.5% to 1.5% across the
aggressiveness slider (1.0% at 50%). Above 3/32" the stock-to-leave term governs as now.
C4 stays as the breakage guard. Owner decision D7.

**3. Operation envelopes and a chip-load floor, so depth cannot be bought by starving the chip.**
- Adaptive: stepover between `max(2 × TIR, 0.05 × D)` and `0.30 × D` (0.40 × D non-ferrous).
- Roughing: stepover up to 0.50 × D. Slotting: stepover = D.
- Slot depth cap for every diameter, taken from the vendor slot rows (628 exist) as the median
  depth/D per diameter band and material family, scaled by aggressiveness. Extends C8.
- Chip-load floor: feed per tooth at least 50% of the vendor consensus for the bucket (C14
  already looks this up as a ceiling), or twice the rubbing limit where no consensus exists.

**4. A selection rule that is not flat.**
Among candidates within 10% of the best MRR, choose the one closest to vendor consensus in
depth/D and feed per tooth (log distance), not the deepest. Use the robustness margins only to
break exact ties. Then refine locally so the result does not sit on a grid node.

**Later, optional — chatter limit (C15).** A stability estimate needs only quantities v2 already
has: limiting depth ≈ `2 × k × ζ × (1 + ζ) / (K_t × N)`, with `k` the static tip stiffness,
`ζ` an assumed damping ratio (0.02–0.03), `K_t` the specific force and `N` the mean number of
teeth in the cut. It is uncertain by about a factor of two, so treat it as a soft cap scaled by
aggressiveness and calibrate `ζ` against the vendor depth data before enabling it.

### 5.4 Work packages (replace WP-4, WP-5, WP-6)

Rules of Part 2 apply. Work in `physics_v2/optimize.py` unless stated. Run
`python -m pytest tests/test_v2_optimize.py tests/test_v2_bridge.py -q` and the probe before
and after each package.

| ID | Change | Done when |
|---|---|---|
| M0 | Fix N5, N6. Make both clients request the same model: the add-in sends `model` read from `/api/model_settings`. Until M1–M4 land, set the page default back to v1. | `pytest` is green; a fresh install gives identical numbers in page and add-in. |
| M1 | Reduced-flute regime. In `optimize`, when no candidate survives and the eliminations are C1/C2 only, re-run once with `c1_flute="wall"` (generalize the existing C14 fallback at lines 1857–1881). Add `flutes_cutting` and the feasible-runout value to the result and to `/api/calculate`. `v2_bridge` must not fall back to v1 for this case. | Every row of N4 returns `feasible: true` with a warning. For 2-flute tools 0.010"–1/4" in 6061 and 4130, feed is non-increasing over runout 0, 0.00005", 0.0001", 0.0002", 0.0005", and the step from 0 to 0.00005" changes feed by less than 15%. |
| M2 | C3 allowance `min(stock term, k × D)` in `_Context` (near line 1295). `k` in `params.py`. | Probe shows `C3 allow` = 0.000625" for a 1/16" tool at 50%; 1/4" unchanged. |
| M3 | Envelopes and floor. Stepover bounds per operation at lines 1829–1830. Slot depth cap table generated by a new function in `tools/v2_invariants.py` into `data/model_v2/slot_depth.json`; `slot_depth_ratio` reads it. Chip-load floor added to `lower_checks` as a new check `C14lo`. | Adaptive never returns stepover above 0.40 × D. 1/4" 4130 slot depth is at or below the table value and feed per tooth is at least 50% of consensus. No case in the sweep returns feed per tooth below twice the rubbing limit. |
| M4 | Selection rule of 5.3 item 4, replacing lines 1895–1916. Keep `_refine_ae`. | For 1/16", 1/8", 1/4" in 6061 and 4130, adaptive and slotting: changing runout, stickout or aggressiveness by 10% changes depth, stepover and feed by less than 25% each. The Part 4 N2 table no longer reproduces. |
| M5 | Make v2 the default for both clients (`resolve_model` default and the page). Remove the "beta" wording everywhere or keep it everywhere. Update `tests/test_web_model_switch.py`. | Same request through page payload and add-in payload returns the same model and numbers. |
| M6 | v1 clean-up for the tool types v2 does not cover: fix the "Roughing" limit step at 1/8" (`gwizard_physics.py`, `calc_deflection_limit`), compute ramp and plunge feed from the un-thinned chipload (WP-7), delete the stress claim from the module docstring. | Limit is monotonic in diameter for all operations; ramp feed never exceeds slotting feed. |
| M7 | Optional: C15 chatter cap as in 5.3, off by default behind a parameter. | With it on, no adaptive result exceeds the estimated limiting depth at 50% aggressiveness. |

### 5.5 Additional owner decisions

| ID | Decision | Recommended default |
|---|---|---|
| D7 | Micro deflection allowance `k`. | 0.5–1.5% of diameter across the slider. |
| D8 | Whether a reduced-flute cut is offered automatically or only after a prompt. | Offer it automatically with a warning and the runout needed for all flutes to cut. |
| D9 | Chip-load floor as a fraction of vendor consensus. | 50%. |
| D10 | Default runout. 0.0002" puts every tool under about 3/64" in the reduced-flute regime. | Keep 0.0002" as the default and make the field prominent for tools under 1/8". (V4, owner: 0.0001" for tools of 1/8" and below and 0.0002" above when no runout is given, or the holder class from the Fusion tool's holder description; `toolwiz_common/runout.py`, `runout_source` in the API.) |
