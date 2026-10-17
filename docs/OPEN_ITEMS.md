# ToolWiz: open items

_Last updated 2026-10-15, branch `toolwiz/hardening` (not merged to master)._

## Next major work: cutting model v2

The design is in `docs/PHYSICS_MODEL_DESIGN.md`. Implement it in a new chat, one step per session (§6 of the design). The user answered the §7 questions on 2026-10-15; the decisions are recorded there.

Why: ToolWiz v1 is GWizard's tables plus stacked rules. For tools of 1/8" and smaller in steel it is 2–7× Harvey's published feeds (`docs/research/harvey_micro_data.md`). It runs a heavy chip at a shallow depth where Harvey runs a thin chip deep, which is why the 1/16" rougher's programs are so large.

**Done 2026-10-15:** step 1 (data, `docs/research/v2_data_findings.md`) and step 2 (`physics_v2/forces.py`).
- All data decisions are made: 17-4 → P5.0.Z.AN scaled by hardness; Harvey generic charts at normal weight; C5 on the continuous rating.
- The optimizer objective is agreed (design §3.6): MRR, with speed set from tool life.

**Done 2026-10-16:** step 3, constraints and optimizer (`physics_v2/optimize.py`, `docs/research/v2_optimizer_findings.md`). T12 and T1 adaptive come out deep (full LCF) and narrow, limited by C3.

**Round 2 done 2026-10-16** (user decisions):
- C1 on every flute, eccentric runout;
- provisional C3/C4 from the vendor rows (`data/model_v2/provisional_limits.json`);
- C11 feed caps and C12 ae ≥ 2·TIR.

Results are in `docs/research/v2_optimizer_findings.md` (Round 2). Open:
- Program size: at the C3-limited feed, toolpath length is free in the time objective. T12's v2 cut has 28 % more toolpath per in³ than v1.
- Finishing at 0.0002" TIR is infeasible under every-flute C1 plus v1's tolerance limit; a rule is needed.
- A measured TIR (Blum) moves every micro result.

**Round 3 done 2026-10-16.** Vendors design to the worst-flute chip (h_worst ≈ 0.005·D in every band), not to deflection or stress. The C4 flute root now uses the deflection's own fluted section. Proposed, not applied: C2 from the chip invariant, C4 = carbide fatigue, C3 = a process requirement. Under that basis T12 runs 3·D × 0.12·D at 6× v1's MRR with 8× less toolpath. See `docs/research/v2_optimizer_findings.md` (Round 3).

**Program size and finishing (2026-10-16), from the user's NC files:**
- Program-size model 23.1 bytes/line × L_cut/s; optional C13 "Limit program size" (6 MB).
- Finishing C3 = the user's wall tolerance (0.005 mm default), with the wall error reported as mean (Blum-compensable) and ripple.
- At 0.0002" TIR no finishing pass holds 5 µm; at 0.0001" a 0.002" stock pass does.
- CAM-side: Fusion Fine Stepdown 0.002–0.005 mm made the largest files; keep it at least ¼ of the stepdown and never under 0.05 mm.

**Round 4 done 2026-10-16: adopted basis.**
- C2 = vendor-median worst-flute chip/D per band.
- C3 = wall deflection ≤ 50 % of the stock to leave (roughing) or the wall tolerance (finishing).
- C4 = carbide fatigue 1425 MPa on the fluted section.
- The vendor-median C3/C4 limits are reported only.

**Round 5 done 2026-10-17:**
- Merged `toolwiz/v2-data2` (1,466 side and 628 slot rows evaluated); C2 limits regenerated.
- Review fixes B1–B8.
- Finishing: C1 needs only the wall flute; the wall tolerance is a target; an optional hard part tolerance.
- Micro tools report the max feasible TIR.

Step 3 is ready to review and merge (`toolwiz/v2-step3`). Open with the user: the C2 basis for micro tools (the nominal basis was evaluated, not adopted), measured runout. Calibration item: the Kienzle size effect at µm chips (stress outliers in Ni micro rows).

**Step 4 done 2026-10-17** (`toolwiz/v2-step4`, `tools/calibrate_v2.py`). The parameters are proposed in `data/model_v2/materials.json` and `tools.json`, not adopted. Ten decisions for the user are in `docs/research/v2_calibration_findings.md` §9: the tool factor, the 17-4 speed hardness exponent (1.82 fitted vs 1.0 prior), the engagement law, the aggressiveness map, and a data-based §5 gate.

Next is step 5, pipeline integration, once those decisions are made.

## User actions

- **Correct T12 in Fusion** (1/16" 4FL rougher). Its Shaft diameter is 0.0625; most likely it should be 0.125, and the neck should match the real tool. With a 1/8" shank the adaptive stepdown goes from 0.0019" to about 0.0125".
- **Fusion roughing passes on micro tools:** Fine Stepdown was about 0.005 mm (it follows the maximum stepdown) and Tolerance was 0.010 mm. Suggested values are 0.025 mm tolerance and a fine stepdown of at least 0.05–0.1 mm. Tell me whether the Fine Stepdown field shows a formula.
- **Set holder runout** (TIR at the tool tip) in Machine & Cut Parameters. The default is 0.0002" for micro tools unless overridden.
- **Confirm the 16k torque curve** (received 2026-10-15, in `machines/speedio_s500x2.json`) against the Brother spindle output chart. v2 limits sustained cuts by the continuous rating (decided 2026-10-15).
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
- **Fine stepdown follows the add-in's stepdown (confirmed 2026-10-16 from addin.log).** Fusion's adaptive default is `fineStepdown = Math.min(tool_diameter * 0.5; maximumStepdown * 0.1)`, and `maximumStepdown = tool_stepdown`, which is the preset value the add-in writes.
  - So a 0.0019" stepdown on T12 gave 0.0048 mm fine-stepdown levels. That explains the hundreds of 0.002–0.005 mm Z levels in the big programs (`docs/research/nc_file_size_calibration.md`).
  - The add-in never writes fineStepdown, tolerance, smoothing or any holder/shaft clearance setting.
  - The log also shows 9 operations where maximumStepdown evaluated to 0 (preset stepdown 0).
  - **Built 2026-10-16:** Auto-Set replaces Fusion's default fine-stepdown expression with 25% of the stepdown, at least 0.05 mm, never above the stepdown or half the diameter.
    - A value the user typed is kept.
    - The change is audited, and fineStepdown is included in snapshots.
    - Needs a check in Fusion (reload the add-in, Auto-Set an adaptive op, look at Passes > Fine stepdown).
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
