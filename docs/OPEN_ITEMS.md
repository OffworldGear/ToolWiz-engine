# ToolWiz: open items

_Last updated 2026-10-15, branch `toolwiz/hardening` (not merged to master)._

## Next major work: cutting model v2

The design is in `docs/PHYSICS_MODEL_DESIGN.md`. Implement it in a new chat, one step per session (§6 of the design). The user answered the §7 questions on 2026-10-15; the decisions are recorded there.

Why: ToolWiz v1 is GWizard's tables plus stacked rules. For tools of 1/8" and smaller in steel it is 2–7× Harvey's published feeds (`docs/research/harvey_micro_data.md`). It runs a heavy chip at a shallow depth where Harvey runs a thin chip deep, which is why the 1/16" rougher's programs are so large.

**Step 1 (data) done 2026-10-15.** Findings: `docs/research/v2_data_findings.md`. Decisions needed before calibration (its §6):
- 17-4 Condition A → Sandvik P5.0.Z.HT or P5.0.Z.PH.
- How to weight Harvey's generic charts.
- C5: the continuous or the 10-minute spindle rating.

Next is step 2, the force model module.

## User actions

- **Correct T12 in Fusion** (1/16" 4FL rougher). Its Shaft diameter is 0.0625; most likely it should be 0.125, and the neck should match the real tool. With a 1/8" shank the adaptive stepdown goes from 0.0019" to about 0.0125".
- **Fusion roughing passes on micro tools:** Fine Stepdown was about 0.005 mm (it follows the maximum stepdown) and Tolerance was 0.010 mm. Suggested values are 0.025 mm tolerance and a fine stepdown of at least 0.05–0.1 mm. Tell me whether the Fine Stepdown field shows a formula.
- **Set holder runout** (TIR at the tool tip) in Machine & Cut Parameters. The default is 0.0002" for micro tools unless overridden.
- **Confirm the 16k torque curve** (received 2026-10-15, in `machines/speedio_s500x2.json`) against the Brother spindle output chart, and decide whether v2 limits cuts by the continuous or the 10-minute rating (design §7.3).
- **Machine profiles (done 2026-10-15):** pick the machine and spindle in Machine & Cut Parameters; "Edit machines…" sets max rpm, power ratings and torque curve points.
  - Built-in profiles are in `machines/`; user profiles are in `data/machines/` (not committed).
  - Max RPM, Max HP and runout overrides are stored per machine in `data/machine_settings.json`.
  - The Fusion add-in uses the active machine through the server. Not yet checked in Fusion.
- **Later: Blum laser runout.** Measure runout per tool on the Blum and write it to the tool library, making TIR per-tool with the machine setting as fallback. Not implemented.
- **Restore the real tool library:** it is still only in `backups/`. `data/working_library.json` is a local file that is deliberately not committed.
- **Rotate the Gemini API key:** it appeared in `server.log`.
- **Merge** `toolwiz/hardening` into `master` when you're happy: https://github.com/OffworldGear/ToolWiz-engine/compare/master...toolwiz/hardening

## Fusion add-in

- **"(custom)" after Replace:** the linked-formula fix still needs a confirmation run. The preset "Use stepdown/stepover" flags are logged; if they come back False, implement setting them.
- **Ask the user:** which stepover field on Steep and Shallow looked unlinked?
- **Option (offered, not built):** the add-in could set Fine Stepdown to at least ¼ of the stepdown and never under 0.05 mm whenever it writes a stepdown.
- **Audit log `op_path`:** for operations inside patterns, the `preset_link` event uses the pattern name ("Pattern1 (3) > …") while snapshots use the setup name. Unify them.
- **Done (2026-10-03 to 10-15):**
  - audit trail, side-effect detection and Snapshot/Compare;
  - Replace warning for shared presets;
  - Stock to Leave strength dropdowns;
  - selecting highlighted operations in folders and patterns;
  - logging of calculation geometry and results;
  - shank and runout alerts in the confirmation;
  - the launcher now restarts a stale server.

## Physics (v1, until v2 replaces it)

All of these were added 2026-10-13 to 10-15; v2 reviews each one:
- coating rule from GWizard's TiAlN rating;
- slot ×0.8;
- slot deflection limit raised to the adaptive level;
- OSG long-reach SFM line and chip-load trade, both on equivalent stickout;
- shank default and warning;
- scaled roughing floor;
- runout as a machine setting.

Still open:
- **Plain carbide + AlTiN raises SFM** in 8620 (+37%), copper (+25%) and ductile iron (+19%) under GWizard's TiAlN rating. The user hasn't decided whether to cap it at the old ×1.4.
- **The runout warning** (TIR ≥ 0.5·fz) is stricter than Harvey's "runout ≤ 2% of D". v2 replaces it with the worst-flute limit.
- **Benchmark harness:**
  - It sends no cut width, so `/api/calculate` defaults to 0.25" and prices small tools as full slots.
  - The micro rows model the shank as equal to the cutting diameter.
  - It allows 1.3× slack on SFM.
  - v2 replaces it with the sourced dataset.
- **Drills, thread mills and indexables** still use a flat ×1.4 coating factor for steels. Check them for double counting.

## Data

- **ToughMet 3 (Annealed)** is listed at 485 HB, which is implausible; it needs a datasheet value.
- **The M33×3.5 thread row** is an outlier.

## Workflow and UX

- **Digital Twin Library Manager review** (a separate chat): source of truth, round trip, conflicts, write-back. Its "identical tool" check ignores tool number, holder, reach and pitch.
- **Import Digital Twin** writes a staging JSON file instead of updating the source library.
