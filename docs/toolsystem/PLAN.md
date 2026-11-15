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

## Phases (each ends with something the owner can read and approve)

1. **Harvest and machine snapshot** (read only). Fresh Fusion harvest; FTP pull of tool, pocket and group files.
2. **Tool sheet.** One row per tool type (number 1 to 99), plus one record per physical cutter. Owner corrects it.
   Numbering: 1 to 17 permanent, 18 to 21 guest or spare-tool pockets, 22 to 98 shelf blocks by type, 99 probe.
3. **Presets and change log.** Active materials x allowed strategies per tool. Trust level on every preset:
   Calculated, Manufacturer, Ran OK (set automatically from machine evidence), Proven (owner's click; never
   overwritten). Old versus new comparison with reasons. Chamfer presets: manufacturer or owner-approved only.
   Also a document check, report only: a Scallop operation ordered before roughing is finished is flagged.
4. **Publish to Fusion.** Backup, dry run, owner confirms, write to hub (or Local if the hub test fails).
5. **Keep documents in step with the master** (core requirement). First a read-only drift report for every
   document: which tools differ from the master and in what (shank, flute length, stickout, number, presets), and
   duplicate tool numbers. Then the fix: on a copy first; dry-run report; owner confirms in Fusion. After that the
   drift check runs on every harvest, so a document that falls out of step is reported the same day.
6. **Machine link.** Read life, wear and pockets on a schedule; per-cutter history; weekly review screen. Writing
   names and life limits to the control comes last and only after a proven test on an unused tool number.
7. **Unattended running.** Spare tools through Brother tool groups for tools that cannot last a night; laser
   breakage checks; life limits set from measured history.

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
