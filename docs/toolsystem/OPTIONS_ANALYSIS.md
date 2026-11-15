# Tool management: options compared (2026-11-15)

For the owner's decision. Implementation is on hold until he picks. `PLAN.md` describes option B and will be revised
to match the choice.

## What the research could and could not establish

- **Fusion:** document tools are copies, not links; Autodesk staff confirmed this on their forum, and no "update from
  library" feature was found in the release notes read. Forum users fix drift by deleting and re-picking tools. The
  API can update a document's tool and its operations; unproven on the owner's files (local test pending).
- **Hub library write through the API:** unproven (local test pending).
- **Brother C00** (from the owner's manuals and app): the control holds length, wear, life limit, life used and name
  for 99 tools, pocket assignments, and spare-tool groups. Reading works. Writing is unproven.
- **Podcast** (Within Tolerance, "My Tool Library Is Better Than Yours", Justin Gray, 6 episodes Jun to Nov 2026):
  show notes only, no transcripts. Themes: presets so feeds and speeds are not redone per program; the same carbide
  in a different holder is a different tool; the library mirrors the physical crib and is audited continuously;
  standard tools; Kanban cards and tool tags; holder comparison with Rego-Fix. Numbering, tool life and CAM-to-machine
  sync are not in the notes.
- **Other shops:** the only measured case found (Applied Engineering, Modern Machine Shop) logged tool life by hand for
  two years before automating, and tracks by tool number, not job. Commercial tool-management systems (TDM, Zoller)
  advertise links to other CAM systems and to Siemens and FANUC controls; no Fusion or Brother link and no prices
  were confirmed. ProShop treats a tool plus holder plus stickout as one numbered assembly. Nothing reliable was
  found on how small shops with a laser setter work, or on what Saunders, Pierson or Grimsmo do.

## The options

**A. Fusion hub library is the master; discipline only.** Tools, numbers and presets are kept by hand in the hub
library. Documents are fixed by hand. The machine's tool table is kept at the machine. No new software.

**B. Our own master feeds Fusion and the machine.** A tool sheet in the repository is the truth; Fusion and the
control are copies written from it. (What `PLAN.md` describes today.)

**C. Each fact has one home; our software is the bridge and the auditor.** Fusion's hub library is the master for
what a tool is and how it cuts (geometry, holder, stickout, number, presets). The control is the master for what is
physically loaded (length, wear, life, pocket, spare groups). Our software holds no master data: it generates and
proposes presets, checks documents and the control against the library, snapshots both into the repository (which
gives the history and change log), and keeps the per-cutter history and trust levels as a side record.

**D. Buy a tool-management or shop-management system** (TDM, Zoller TMS, WinTool, ProShop).

**E. The control leads; Fusion follows.** Fixed tool numbers, tool life and spare tools set up on the Brother, Fusion
just calls the numbers. A paper or spreadsheet tool list. No software beyond what exists.

## Comparison

| | A. Fusion, by hand | B. Our master | C. One home per fact | D. Bought system | E. Control leads |
|---|---|---|---|---|---|
| Shop keeps running if our software breaks | Yes | No: the master is stuck in a file only software edits | Yes: Fusion and the control are complete without it | Depends on vendor | Yes |
| Fits how he works (edits tools in Fusion) | Yes | No: Fusion edits become "drift" to reconcile | Yes | No: a third place to edit | Partly |
| Document drift | By hand, document by document | Automated | Automated | Not solved (no Fusion link found) | By hand |
| Dialed-in presets with trust levels and change log | By hand, no log | Yes | Yes | No | No |
| Tool life and overnight running | Set at the machine, no history | Yes | Yes | Not confirmed for Brother | Yes at the machine, no history |
| Rests on unproven things | Nothing | Hub write, document update, later control write | Same, but each has a manual fallback | Integration and price unknown | Nothing |
| Upkeep over years | His time, every change | Highest: software owns the truth | Medium: software can lag without harm | Subscription and vendor | His time |
| Cost | None | Build time | Build time | Unknown, likely high for one machine | None |

## Recommendation: C, built in stages that are each useful alone

This changes the earlier recommendation of B. Reasons:

1. He is not a programmer. In B, a broken sync leaves the truth in a file he cannot comfortably edit. In C the worst
   case is option A plus E: the shop still runs correctly by hand.
2. He edits tools in Fusion and will keep doing so while dialing in. C makes that the right place; B makes it a
   conflict.
3. The control already does tool life and spare tools well. Copying that into our own database adds a second truth.
4. Everything B offered is kept: history and the change log come from snapshots; trust levels and per-cutter
   records sit in a side record that nothing else depends on.

What C costs: Fusion's tool record has no fields for trust level or cutter history, so those live outside Fusion; a
written rule is needed for which side owns each field; and automatic preset publishing depends on the hub write test
(fallback: he imports a library file by hand).

Stages:
1. **Process, no software:** numbering scheme, standard tool list, one holder per tool, holder and stickout as part of
   the tool's identity, life limits and spare groups on the control. (This is A plus E, done deliberately.)
2. **Auditor, read only:** drift report for documents, library audit, machine snapshot, history in the repository.
3. **Preset proposals:** generated presets with trust levels and the change log; he accepts into the hub library.
4. **Document fixing**, after the copy test passes.
5. **Tool life history and overnight running;** writing to the control last, if ever needed.

## Decided the same way under any option

Numbering by tool type with fixed pockets for standard tools; tool plus holder plus stickout as one identity; active
materials only as presets; chamfer presets from manufacturer or owner-approved values; a weekly audit habit.

## What would change the recommendation

- Hub write fails and stays failed: C still works with hand import; B loses its main advantage.
- A second machine or an employee: the case for a bought system (D) or a stronger central master (B) grows.
- The document update test fails: document fixing stays manual under every option, and the drift report matters more.
