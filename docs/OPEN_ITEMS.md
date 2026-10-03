# ToolWiz: open items

_Last updated 2026-10-03, branch `toolwiz/hardening`._

## Fusion add-in: preset behaviour
- **"(custom)" after Replace.** Latest fix: linked preset fields (ramp spindle speed, entry and exit feed, feed per tooth, feed per rev) keep Fusion's formulas instead of numbers. Needs a confirmation run in Fusion.
- **Preset "Use stepdown / Use stepover" checkboxes.** Fusion doesn't expose these as preset parameters. A diagnostic now logs them from the tool JSON. If they come back `False`, implement setting them (JSON path, with tool-count checks).
- **Ask the user:** which stepover field on Steep and Shallow looked unlinked? The main stepover = `tool_stepover`; finishing stepover and cusp height are Fusion's own formulas.
- **Unexplained strategy changes on operations the user didn't touch.** Probably a false alarm: on 2026-10-03 the user found they had been looking at a different setup. The audit trail and the Replace warning still go in, as a safeguard; if it happens again, Snapshot / Compare will show what changed.
- **One operation had a 0.0747 in/min cutting feed** before a run. Spot-check other recently touched operations.

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
