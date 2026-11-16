# Shop tooling system: plan (2026-11-15; owner: "Plan looks good")

Branch `toolsystem/main`. Nothing here is built yet. Each phase still ends with the owner's approval; every write to
Fusion or the machine still needs a backup, a dry run and his confirmation. Brief: `docs/TOOL_SYSTEM_PROJECT_BRIEF.md`.

## Decisions so far (owner, 2026-11-15)

- Tool numbers 1 to 99 are defined in the C00 control; any pocket can hold any tool number (T99 = Blum TC-52 probe).
- Active materials: 17-4 annealed, titanium grade 5, Black Ti, MagnaCut annealed, AEB-L annealed, bronze (written
  "C154"; assumed C954, to confirm), tellurium copper C14500. Everything else is kept in the master but gets no Fusion
  presets until asked for. The owner can narrow materials further per tool.
- Strategies per tool type: as proposed; bull-nose tools with a good radius also get 3D contour.
- Change log: more than 25 % on axial or radial depth, more than 1 degree or 15 % on ramp angle, and any change more
  aggressive by over 10 %.
- Tool setters: Blum laser NT and Z Nano; move everything to the laser over time; wear can be measured.
- Goal: unattended running overnight (frames run about 1 h 45 min each, three per batch).
- Holders: Rego-Fix powRgrip under consideration for finishing tools; no decision.
- Added to the brief on `toolwiz/v4-advisor` (commit d16cd7d), relayed by the field-test session:
  - Keeping every document's tools in step with the master, automatically and with a report, is a core requirement.
    Example: T12 and T6 (1/16 in tools, 1/8 in shanks) were 0.0625 in shank in a document, so every operation was
    under-fed; the same document has tool 2 defined twice.
  - Chamfer mills on Trace or 2D Chamfer are finishing passes on visible surfaces. ToolWiz has no chamfer model, so
    chamfer presets come from manufacturer data or the owner's approved values, never from a calculation.
  - Standard practice: no Scallop until roughing is completely finished.

- Owner's second round, 2026-11-15: bronze is C954 (C932 also in the active list, low use). Machine link starts
  read only; writing to the control is wanted later, once tool life is tracked from which program ran with which
  tool and for how long (the communications app can see programs running). Not every Fusion file in his working
  folder is in use; he is building one manufacturing-ready document per part. Chamfer: he sometimes roughs with 2D
  contours, so the Scallop-order check may be hard or unnecessary: keep it report only and low priority; chamfer
  modelling may be fixed in ToolWiz itself later.
- Work on `OffworldGear/BrotherC00CommandControl` goes on a new branch of that repository.

## Checked facts

- Fusion API has a hub library location; write access to it is unproven (test 1 below).
- Fusion API documents `DocumentToolLibrary.update` (updates a tool and all operations using it). Whether toolpaths
  need regenerating is unconfirmed (test in phase 5).
- Brother manuals are in `OffworldGear/BrotherC00CommandControl` (`manual_texts/`). Confirmed there: tool groups
  (T901 style) with automatic change to a spare tool when life expires; tool data file `TOLS..` holding length, wear,
  life limit, life warning, life used and name; `ATCTL` holding pocket to tool number.
- The owner's SpeedioMonitor app reads live tool life, wear and lengths over the network, and pulls the tool, pocket
  and group files by FTP on demand. It does not write to the control today. It has its own `master_library` table,
  which must not become a second master.

## Chosen approach (owner, 2026-11-15): option C of `OPTIONS_ANALYSIS.md`

- **Fusion's hub library is the master** for what a tool is and how it cuts. Tools are tracked by tool number.
- **The control is the master** for what is physically loaded (length, wear, life, pocket, spare groups).
- **Our copy is a digital twin:** an active copy of the master, kept in step by harvest, used for reference, checks,
  history and for preparing changes outside Fusion. It is never the truth once the hub master exists.
- Document tools are copies with no link to the library. So there is a standing process: an important change made
  to a tool in a document is copied back to the master (the master's tool with that number is updated in place, so
  no old version is left behind), or the document tool is reset to the master. Nothing is left differing silently.

## Phases (revised with the owner, 2026-11-15, later; each ends with something he reads and approves)

Settled: start a NEW tool list; do not inherit existing Fusion tool data. Tool numbers are arbitrary and the
numbers already used in his Fusion documents are kept. Three rules only: one number = one tool + holder + stickout;
a number is not reused while an in-production setup still calls it; no tool 0. Must fit in 99 (T99 probe, T98
master gauge; spare tools for overnight running each need a number). The control's table is reliable only for
numbers 1 to 21 (length, wear, life), 98 and 99; its descriptions are not. Length is set on the tool setter and wear
by the laser, at the machine. Geometry comes from the manufacturer's part number or measurement (the T12 / T6 shank
error was Fusion's default of shank = tool diameter).

1. **Setup picker and tool list.** The add-in harvests tools only from the setups the owner selects, and remembers
   that selection as "in production". Result: a list of tool numbers in use, with conflicts shown (one number
   defined two ways), numbers used versus the 99 limit, and a cross-check against the control for 1 to 21.
2. **Geometry, then holders.** A checklist per tool number (shank, flute length, stickout, holder, brand, part
   number, coating); the owner fills it at the machine. Nothing is written to Fusion.
3. **Materials and strategies.** ToolWiz presets for the active materials and allowed strategies, each marked
   Calculated, Manufacturer or Proven. A preset that already works in a setup can be captured as Proven instead of
   being replaced. Change log against the old values.
4. **Build the master in the Fusion hub:** backup, dry run, owner confirms (hand import if the hub cannot be written).
5. **Tools back into setups, deliberately, per part.** Per tool: update from master, or keep as is (a recorded,
   accepted difference; recent working setups will mostly stay). Proven on a copy first.
6. **Drift report** on every harvest of the in-production setups.
7. **Machine link, read only; then overnight running.** As before; writing to the control last.

Pilot: not yet. Candidate is the End Cap (aluminium version now, cut with AlTiN tools; a 17-4 version follows, which
exercises two materials on the same tools).

## Dependency: strategy definitions draft (not decided)

`docs/STRATEGY_DEFINITIONS.md` on `toolwiz/v4-advisor` (commit 762d77c, a draft by the shop PC session) proposes that
each operation's cut is declared by its linked preset, named "<material> - <strategy>" from one list of 14
strategies, stored with the tool in the library. If the owner adopts it, phase 3 of this plan must use exactly that
strategy list and naming, and the master library becomes the place presets are made. It would also add fields
recorded on the tool: high-feed (yes / no), tap style, and possibly the performance grade. Phase 3 should not be
built until the owner has decided the draft's open points; phases 1 and 2 do not depend on it.

## Requirements from the workflow draft (`docs/WORKFLOW.md` on `toolwiz/v4-advisor`, 2026-11-16; draft)

What the owner's target workflow asks of the master library:

- Every tool matches the real tool and carries one preset per material he cuts and per strategy the tool allows,
  so Speeds & Feeds is rarely needed once the library is built out.
- **Swap from the master:** exchange the tool a toolpath uses for the master's tool. Not built; depends on the
  document-tool test on a copy.
- **A preset added in the Speeds & Feeds dialog or in the digital twin goes onto the master's tool automatically.**
  Not built; depends on the hub write test. "Automatically" here means without a separate step for the owner; the
  dialog's preview is the dry run and his OK is the confirmation, and a backup of the library is taken first.
- **Vendor field must be right on every tool:** name brand (Haas counts) = HP grade, no name brand or a marketplace
  name = standard. Add vendor and grade to the phase 2 checklist.
- **One fixed material label per alloy.** The advisor follows a preset only when its material part equals the
  alloy or family text exactly. The label list must be fixed before any preset is generated (phase 3).
- Fusion's generic presets are not carried into the master.
- Advisor warnings that need the master: document tool differs from master; one number with two definitions.

The two unproven writes (hub library, document tool) now gate the core of the workflow, not just convenience. The
shop PC tests 1 and 5 below are the most important open items.

## Requests for the shop PC session

1. Hub write test: with the add-in, create a throwaway library "ZZ_ToolWiz_write_test" with one tool in the hub
   location, read it back, delete it. Report the exact error if it fails. Touch nothing else.
2. Fresh harvest of all libraries and open-document tools; push the snapshot to this branch.
3. From SpeedioMonitor, one on-demand FTP sync with the machine idle; copy the tool, pocket and group files to
   `data/machine_snapshots/<date>/` on this branch. Read only.
4. Document inventory (read only): list every Fusion document in the owner's working folder with its last-modified
   date, number of setups and operations, and the tools it holds. The owner then marks each one in use, retired or
   unsure; only "in use" documents are ever touched.
5. Can document tools be changed automatically? On a COPY of one small in-use document (the one with the 1/16 in
   tools at the wrong shank is ideal): correct one tool's shank diameter through the add-in
   (`DocumentToolLibrary.update`), then report: did every operation stay attached to its tool, which toolpaths were
   marked out of date, did regenerating work, did presets survive. Delete the copy afterwards or leave it clearly
   named. Never the original.
Write results to `docs/toolsystem/LOCAL_REPORT_<date>.md`.
