# ToolWiz: open items

_Last updated 2026-10-03, branch `toolwiz/hardening`._

## Fusion add-in: preset behaviour
- **"(custom)" after Replace.** Latest fix: linked preset fields (ramp spindle speed, entry and exit feed, feed per tooth, feed per rev) keep Fusion's formulas instead of numbers. Needs a confirmation run in Fusion.
- **Preset "Use stepdown / Use stepover" checkboxes.** Fusion doesn't expose these as preset parameters. A diagnostic now logs them from the tool JSON. If they come back `False`, implement setting them (JSON path, with tool-count checks).
- **Ask the user:** which stepover field on Steep and Shallow looked unlinked? The main stepover = `tool_stepover`; finishing stepover and cusp height are Fusion's own formulas.
- **Unexplained strategy changes on operations the user didn't touch.** Probably a false alarm: on 2026-10-03 the user found they had been looking at a different setup. The audit trail and the Replace warning still go in, as a safeguard; if it happens again, Snapshot / Compare will show what changed.
- **One operation had a 0.0747 in/min cutting feed** before a run. Spot-check other recently touched operations.

## Physics / benchmarks
- **The vendor benchmark harness doesn't send a cut width.** `/api/calculate` then defaults to 0.25", so tools of 1/4" and smaller are priced as full slots, even on adaptive rows: no HEM boost, and since 2026-10-13 the slot speed reduction. The web page and Fusion always send a width, so real use isn't affected. Treating a missing width as "recommended" (tried 2026-10-13) puts `harvey_micro_adaptive_1_32` at a 90 IPM feed against a 60 (×1.3) maximum, and that row's targets are unverified anyway. Fix the harness and that row together.
- **The benchmark harness allows SFM up to 1.30× the vendor maximum and down to 0.80× the minimum.** That slack hides cuts that are too fast; for example, the 1/16" slot passed at 348 SFM against a 280 maximum. Tighten it once the micro rows are verified.
- **The coating factor now follows GWizard's per-material "TiAlN Carbide Endmill" rating, for carbide end mills only.** Drills, thread mills and indexables still use the flat ×1.4 for steels, so check those against vendor data (HP drills may be double-counted the same way).
- **No stainless slotting benchmark exists.** Add one from a vendor chart, e.g. Harvey or Helical, 1/8" 4FL AlTiN in 17-4 PH, slotting.

## Data
- **ToughMet 3 (Annealed)** is listed at 485 HB, which is implausible. It needs a datasheet value.
- **The four "Harvey micro adaptive" benchmark rows** still carry unverified legacy SFM/feed targets. Their DOC/WOC targets were replaced with the HEM Guidebook envelope.
- **Torque curve for the 16k spindle** isn't published. Only the power limit is enforced.

## Workflow / UX
- **Digital Twin Library Manager review.** Do it in a new chat: local vs cloud/Hub vs document libraries, the round trip, source of truth, conflicts.
- **Import Digital Twin** writes a staging JSON file instead of updating the source library. Design a safe write-back.
- **The user's real library** is still only in `backups/` (latest `Offworldgear_TI_Steel1…v12`). `data/working_library.json` is the one-tool test stub and is deliberately not committed.

## Repository
- **Merge** `toolwiz/hardening` into `master` once the user has used it (PR link in the push output).
