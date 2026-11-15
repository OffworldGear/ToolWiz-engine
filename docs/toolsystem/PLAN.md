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

## Phases (each ends with something the owner can read and approve)

1. **Staging list (our local master, temporary).** From the harvest, show the tools found in the owner's
   manufacturing documents. The owner says which to pull in; each becomes one row with a permanent tool number.
   Where the same tool differs between documents, he picks the right version. He corrects brand, coating, shank,
   stickout and holder. Nothing is written to Fusion.
2. **Presets and change log** for the staged tools: active materials x allowed strategies, trust levels
   (Calculated, Manufacturer, Ran OK, Proven), old versus new with reasons.
3. **Build the true master in the Fusion hub** from the finished staging list: backup, dry run, owner confirms.
   If the hub cannot be written by the add-in, he imports one library file by hand. From here Fusion is the master
   and the staging list becomes the digital twin.
4. **Drift report, read only, on every harvest.** Per document: tools that differ from the master and in what.
   For each difference the owner chooses "copy to master" or "reset to master".
5. **Applying those choices automatically,** after the test on a copy passes; by hand until then.
6. **Machine link, read only:** life, wear and pockets on a schedule; per-cutter history; weekly review.
7. **Overnight running:** spare-tool groups, laser breakage checks, life limits from history. Writing to the
   control last, once tool life is tracked from which program ran with which tool.

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
