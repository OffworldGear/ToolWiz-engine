# ToolWiz Fusion add-in: user guide (v2.0)

The add-in lives in the Manufacture workspace, **CAM Manage** panel. It talks to the ToolWiz server on `127.0.0.1:5000`
(start ToolWiz first: `py app.py`). Every command uses the **same cutting model as the web page** (it reads
`/api/model_settings` and sends `model` explicitly; the model is shown in each dialog). Install with
`python install_addin.py`, then restart Fusion or enable it in Scripts and Add-Ins (Shift+S).

**Principle.** ToolWiz is the single source of truth for cutting data. The add-in never invents numbers: speeds, feeds, depths,
stock to leave and warnings all come from the server. Nothing is written to a document without your confirmation, and every
write is audited (`%APPDATA%/ToolWiz/audit.jsonl`) and undoable with Fusion's Undo.

## Recommended workflow

1. **Build master libraries per material set** (Master Library Builder): one library per set, e.g. `ToolWiz - Non-ferrous` and
   `ToolWiz - Steels & exotics`, with audited presets for each material and strategy at 50 % aggressiveness.
2. **Select presets** in your operations (Fusion's Cutting Data tab), or run **ToolWiz Speeds & Feeds** on an operation for a
   one-off calculation.
3. **Setup Advisor before posting**: review the whole setup, fix STOP findings, apply what you agree with.
4. Cut. Then **Log Cut Result** with the measured wall error so ToolWiz calibrates itself to your machine.

## Commands

### ToolWiz Speeds & Feeds (auto-setter)
Calculates cutting data for the selected operation and writes it to the operation's tool preset (in place, no new tool).
- Sends the model, **runout** (the tool's own `toolwiz.runout_in` / `runout_mm` if present, else the field in the dialog,
  default 0.0002 in), carbide/HSS from the tool material, and the complete Fusion tool (geometry, shaft, holder, description,
  so slot mills / T-slot cutters and stickout are read correctly).
- **Engagement.** Roughing operations (Adaptive, pockets, slotting, high feed, roughing contours) default to ToolWiz's
  maximum-removal stepdown / stepover / optimal load, which is written. Tick *Keep the operation's own stepdown / stepover* to
  compute rpm and feed for what the operation already has (engagement source "user").
- **Finishing operations** show *Finish mode*: Clean-up (default), Surface finish (target Ra, default 32 uin, shown in the
  document's unit) or Accuracy (wall tolerance, default 0.0002 in). The choice is remembered per operation for the session. The result shows the
  predicted Ra, cusp height, predicted wall error and advice when the server provides them.
- **T-slot cutters** get a cut type (full slot, side cut, both sides, axial step for up/down cutting), slot height and radial depth.
- The **result dialog** lists: rpm, feed, chip load, engagement source, what limited the cut, flutes cutting and runout regime with
  the runout needed for all flutes, recommended radial/axial stock to leave (with a Yes/No offer, or the checkbox, to apply it), holder
  advice, tool advice, the T-slot plan (radial passes, Z steps, axial feed, provisional-geometry warning) and every warning. **Critical
  warnings require an explicit Yes before anything is written.**

### Stock to Leave Manager
Batch view of every operation that has stock to leave. Finishing ops get ToolWiz's negative wall/floor compensation (strength
25-100 %, trim, calibration status); each finishing row is checked against the roughing op before it (wall tolerance logic: a roughing
op that leaves too little stock, or less than the finishing engagement, is flagged). Tick *Include roughing ops* to fill in ToolWiz's
**recommended stock to leave per roughing operation** (1.5 x predicted deflection + springback, at least 0.05 mm), calculated with each
op's own tool, runout, model and stepdown/stepover.

### Setup Advisor
Pick a setup, material, aggressiveness, runout and finish mode (optionally an AI narrative) and run. The add-in pushes the setup
(strategy, full tool and holder, feeds and speeds, stepdown/stepover, stock to leave, heights, toolpath length when a toolpath exists, tabs,
rest machining) to `POST /api/setup_advisor`. The results dialog lists findings per operation (STOP / CAUTION / info), setup-level findings, strategy
suggestions (e.g. contour slot with tabs vs adaptive, with time saved) and, only when the numeric guard passed (`narrative_check.ok`), the
narrative marked "numbers verified". Tick the recommendations to apply (per operation: ToolWiz's recommended engagement and cutting data, or ToolWiz's cutting data
for your current engagement); the box below lists **exactly which parameters change, old -> new**. After a final confirmation the changes are sent to
`/api/setup_advisor/apply` and written by the audited `apply_operation_parameters` bridge action. Regenerate toolpaths afterwards.
The live setup is also pushed to the server (`/api/fusion_bridge/state`) each time the advisor or the MCP `get_setup_summary` runs.

### Strategy Planner
For a contour cut-out with tabs, a slot, or a T-slot job: prefill from an operation (depth from its heights, length from its toolpath) or
type the job, tick the candidate tools (document tools, or the shop's T-slot cutters from `/api/shop_tools`) and compare. The result
table gives levels, ap, ae, rpm, feed, minutes per part, relative tool life and wear, the recommendation with the reasoning, and Fusion
settings (tabs, stepdown, optimal load, ramp, stock to leave).

### Master Library Builder
Choose sources (every library found: local, cloud, hub, open documents; optionally the documents of hub projects), a tool filter (types,
diameter range), material sets and materials, strategies, aggressiveness, runout, and where to import (local or cloud). The server builds in the
background; Fusion shows a cancellable progress dialog and stays responsive. Each result library is imported as `ToolWiz - <set>`;
**a library of the same name is updated in place** and only presets ToolWiz wrote before are replaced (yours are kept). The summary shows
the audit (STOP presets are dropped and listed), cautions and skipped items.

### Library Audit
Audits a library (open document, local, cloud or hub) against ToolWiz: STOP / CAUTION / info per tool and preset, worst tools first. For
a tool in the open document, *Select operations* selects the operations that use it.

### Export / Import Digital Twin
Export harvests the tool libraries of **open documents, local, cloud and hub libraries** into the server's working library (Master Tool Crib), tagged
with their source. The optional **hub project scan** opens every design of the chosen projects read-only and invisibly, reads its tool library and closes
it without saving (progress dialog, cancel any time; slow for big projects). Import writes the server's library into Fusion by name, updating a
library of the same name in place (falls back to a file in the local library folder when the Fusion API call is unavailable).

### Log Cut Result, Clean Up Duplicate Tools, Document Snapshot / Compare
- Log Cut: records measured wall error, spindle load and chatter; the tool's guid is stored with the note.
- Clean Up: removes unused exact duplicates (never a tool used by an operation); each removal is checked by guid against the plan.
- Snapshot: saves/compares every operation's tool, preset, speeds, feeds, stepdown/stepover and stock to leave (a change made outside ToolWiz is shown too).

## Safety notes
- A critical warning, "no safe cut", or an advisor change always asks first. Declining writes nothing.
- The bridge action only writes these parameters: spindle speed, cutting/plunge/ramp feed, ramp angle, helical ramp diameter, stepdown,
  stepover, optimal load, stock to leave (radial, axial), tab width/height. Anything else is refused. Switching on "Stock to leave" is done automatically when you apply a stock value and is stated in the confirmation.
- Runout matters: with the default 0.0002 in a micro tool may cut with fewer flutes and ToolWiz will say so; enter the measured TIR.
- Provisional T-slot geometry (neck, reach, tooth form) is flagged: measure it before trusting the passes.
- Fusion API calls that need a recent Fusion (hub library location, `ToolLibraries.updateToolLibrary`, `Documents.open(file, False)`) are guarded; when unavailable the
  command says so or falls back to a file.
- Logs: `%APPDATA%/ToolWiz/addin.log`; audit trail: `audit.jsonl`; reverts of advisor changes: `revert_<time>.json`.
