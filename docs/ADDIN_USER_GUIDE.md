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
For a contour cut-out with tabs, a slot, a closed pocket (adaptive vs offset roughing, helical entry, rest machining of corners, wall and floor finish; see `docs/STRATEGY_PLANNER.md`), or a T-slot job: prefill from an operation (depth from its heights, length from its toolpath) or
type the job, tick the candidate tools (document tools, or the shop's T-slot cutters from `/api/shop_tools`) and compare. The result
table gives levels, ap, ae, rpm, feed, minutes per part, relative tool life and wear, the recommendation with the reasoning, and Fusion
settings (tabs, stepdown, optimal load, ramp, stock to leave).

### Multiple stepovers, measured widths
- **2D Contour with multiple stepovers** ("Roughing Passes" with "Maximum Stepover" and "Number of Stepovers" on the Passes tab): the first pass is a
  full-width slot (ae = D), the others are side passes (ae = stepover), so **one feed cannot suit both**. The Setup Advisor reads the toggle, count and
  stepover, shows the effective cut width `D + (N - 1) x stepover`, computes ToolWiz for the slot pass (the limiting one, and the safe numbers for the op) and for the side
  passes, and compares a split into a slot op + a side-pass op, and adaptive. The **Auto-Setter** writes the slot-pass speed and feed for such an op (stepdown as set,
  your stepovers kept) and tells you what the side passes could run. Slotting means full radial width (ae = D); a wider cut against one wall is side milling
  (traditional roughing at 30-60 % D, or adaptive at 5-30 % D).
- **Measured widths.** The snapshot carries, per field, whether it was `measured` (read from Fusion) and the advisor lists them ("Widths and geometry used"):
  effective cut width (from the op's parameters), slot / channel width (smallest gap between opposing parallel walls or concentric cylinders bounding the op's selected
  geometry), T-slot radial depth (a negative radial stock to leave, else the groove found in the B-Rep), pocket area / outer perimeter / smallest corner radius (from the selected
  floor face). Anything missing is `assumed` or skipped. When a width is measured the advisor runs the strategy comparison by itself.
- **What to check once in Fusion (the parameter ids are not in Autodesk's published API docs).** Open an op with multiple stepovers, run *Setup Advisor*, then look at
  `%APPDATA%/ToolWiz/addin.log` or `GET /api/fusion_bridge/state` > the op's `geometry.stepover_params_seen` (every parameter id containing "step", "pass" or "rough"). The add-in
  reads `doMultiplePasses` / `useRoughingPasses` (toggle), `maximumRoughingSteps` (count) and `maximumStepover`; if yours are named differently the op is
  analysed as an ordinary contour (no effective width): send that list so the names can be added. Selected geometry is read through
  `CadContours2dParameterValue.getCurveSelections()` and each selection's `inputGeometry`
  ([Autodesk: CAM parameters](https://help.autodesk.com/cloudhelp/ENU/Fusion-360-API/files/CAMParameters_UM.htm)); confirm that a measured slot width appears for a contour
  whose chain you picked in the UI, and that the pocket area matches the pocket.

### Modelling a T-slot / keyseat cutter in Fusion so ToolWiz reads it
ToolWiz builds the shop T-slot cutter list (`data/shop_tools.json`) from your Fusion library: in the Digital Twin tab press **Refresh shop T-slot cutters** (or run
`python shop_tool_builder.py <library file name>`; `GET /api/shop_tools?library=<name>` previews). Create the cutter as a **Slot mill** (Fusion type "slot mill") and fill:
1. **Diameter** (DC) = head diameter; **Flute length** (LCF) = the head thickness (the kerf / slot height cut); **Number of flutes** (NOF) = the number of teeth on the head.
2. **Shaft** tab (the neck): add segments listed from the head upward. Segment 1: height = the neck length below the head (the reach), **lower diameter = the neck diameter**,
   upper diameter = the neck diameter (or the shank diameter if the neck tapers up). Add a last segment at the **shank diameter** up to the holder. Example (Klot 6 x 0.5 mm): 10 mm
   at 3 mm, then 10 mm at 3 mm tapering to 6 mm. ToolWiz reads neck diameter = first segment's lower diameter, reach = up to where the diameter has grown 5 %, shank = the widest segment.
   Without shaft segments ToolWiz falls back to the shoulder fields, then to the shank, and marks neck and reach provisional.
3. **Tooth form.** Put the word **"staggered"** in the description for a staggered-tooth cutter (teeth alternate faces, half the teeth per face), or **"double"** / **"up down"** for a
   double-sided straight-tooth cutter (every tooth cuts both faces). For anything else add a `toolwiz` block to the tool JSON:
   `"toolwiz": {"tooth_form": "staggered" | "straight", "cutting_faces": ["periphery", "top", "bottom"], "teeth_per_face": 4}`. With neither, the tooth form is unknown and treated as staggered
   (the conservative case) and stays flagged provisional.
4. Optional: vendor, product id, coating (BMC / description such as "ti coated" gives Titanium) and overall length.
Library-derived cutters are marked `source: "fusion library"` and are regenerated on every refresh: correct the tool in Fusion, never in `shop_tools.json`. Planned (not owned)
cutters such as the Harvey 867330 stay as they are.

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
- Runout matters: with no runout given the server assumes 0.0001 in for tools of 1/8 in and below and 0.0002 in above (or the class of the tool's holder description: SK/SX chucks, hydraulic, shrink fit 0.0001 in; ER-UP 0.0002; ER 0.0004; Weldon 0.0012), reports it as `runout_source`, and a micro tool may still cut with fewer flutes and ToolWiz will say so; enter the measured TIR. A runout the dialog sends always wins.
- Provisional T-slot geometry (neck, reach, tooth form) is flagged: measure it before trusting the passes.
- Fusion API calls that need a recent Fusion (hub library location, `ToolLibraries.updateToolLibrary`, `Documents.open(file, False)`) are guarded; when unavailable the
  command says so or falls back to a file.
- Logs: `%APPDATA%/ToolWiz/addin.log`; audit trail: `audit.jsonl`; reverts of advisor changes: `revert_<time>.json`.
