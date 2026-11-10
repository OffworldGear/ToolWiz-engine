# ToolWiz code review and fix plan

Reviewed 2026-11-10 at commit `0ff47f9`: the Flask server (`app.py`, `gwizard_physics.py`,
`tool_merger.py`, `backup_manager.py`, `ai_machinist.py`), the web app (`templates/index.html`)
and the Fusion add-in (`ToolWizFusionAddin/`).

Part 1 is the review. Part 2 is the fix plan, split into work packages that a smaller agent can
execute one at a time. Part 3 lists the decisions only the owner can make.

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
