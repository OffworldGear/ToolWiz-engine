# Shop tooling system: project brief (written 2026-11-15)

For the Claude session that takes this project. It is a separate project from the ToolWiz feature freeze on
`toolwiz/v4-advisor`. Read `docs/HANDOFF.md` first for the working rules, then this file.

**How to work.** Start with advice and questions, not code. The owner wants to go through the open questions and
brainstorm first, then approve a plan, then build with as much automation as is sensible. He is a machinist, not a
programmer: plain language, and say what was and was not verified. Work on your own branch off `toolwiz/v4-advisor`
(for example `toolsystem/main`); do not push to `toolwiz/v4-advisor` or `master`, and open no pull request unless asked.
Heavy jobs run in the cloud; cheaper subagents for data and UI work.

## What the owner wants

A tooling system for the whole shop that is simple, works well, and stays correct over time:

- one source of truth for tools,
- reflected in Fusion and in the Brother Speedio S500X2 (and future machines),
- with speeds, feeds, depth and width of cut that are actually dialed in,
- and a log of every large change to axial depth, radial depth and ramp angle, with the reason.

He also asks for advice on tool holders and tooling to buy as he moves into manufacturing the new ratchet knife
project.

## Facts the owner gave

**Machine.** Brother Speedio S500X2, BT30, 16,000 rpm, C00 controller. The controller tracks 99 tools; the changer
holds 21. The 99-tool limit may be a constraint, so tool life tracking may need tools to be shuffled between numbers.
The owner can interface with the C00 controller through an app that runs locally on the shop PC.

**Source of truth.** His view: the Fusion **hub** library should be the master, because cloud libraries are going
away. An alternative he is open to: the master lives in our own database, and Fusion and the machine both read from
it. Either way, one source of truth. Fusion may be the best option.
(Technical note from the first look at the code: the add-in can read hub libraries but today writes only local and
cloud ones, `import_library_by_name` in `ToolWizFusionAddin/ToolWizFusionAddin.py`. Writing to the hub is unproven.)

**Existing speeds and feeds.** Nothing in the current libraries is dialed in. The presets are Fusion defaults, or
values from ToolWiz, G-Wizard or manufacturer data that he entered. Assume all of it can be replaced. Manufacturer
data, where it exists, makes this easy. He is willing to approve some values by hand where that makes sense.

**Fusion's stock presets.** They generally work but are very broad: "Stainless Steel" is probably fine for 303 and
304 and may be too aggressive for 17-4. Replace the Fusion defaults.

**Numbering.** He wants a numbering strategy. Most carousel pockets should hold standard tools for stainless,
titanium and steel. Tools for finishing aluminium, copper and the like would be swapped in, he hopes only a few.
He asks for help designing a simple and highly functional system.

**Tools.** Nearly all carbide with AlTiN coating, except the drills. Fusion's material list has no carbide coatings,
so the coating goes in the tool description (convention in `docs/ADDIN_USER_GUIDE.md`, "Recording coating and tool
material"). Tool 1 and the 1/16 in end mill are Haas tools; Haas publishes its own speeds and feeds on its website,
and the owner understands the tools are made by YG-1. The 1/16 in ball mill is a cheap import. Cheap carbide has
been better than he expected. SK / SX collet chucks run about 0.003 mm.

**Materials to cover** (better too many than too few; some are no longer used):

- Aluminium 6061 and 7075
- Stainless 17-4 and 303 (304 possible later)
- Titanium grade 5
- Zirconium 702 and 704
- Black Titanium (55 % zirconium, 45 % titanium)
- AEB-L, MagnaCut, A2: annealed and hardened (he cuts nothing hardened today, but might)
- Bronze 932 and 954
- Copper: he wrote "410 and C145" (C145 is tellurium copper; ask what "410" means, possibly C110)
- ZrCuTi, Timascus, Damascus steel: wildcards; start from conservative versions of the base materials
- Nitronic 60, ToughMet, Brass 360

**T-slot cutters** mainly cut the frame, 1/16 in (1.6 mm) thick: titanium, Black Titanium, and maybe aluminium,
bronze, copper or 303 / 304 later. They do not need every material.

**Strategies per tool.** Every tool should have presets for all the cutting strategies it could be used for, and
none it could not: a chamfer mill, engraver or T-slot cutter never adaptive-roughs.

**Document tools drift from the library (owner, 2026-11-15).** "Each file has its own local copies of the tooling and
if I need to change one thing it is hard to manually do it to all the documents. It would be great to automate that."
A live example from the field test: his 1/16 in flat (T12) and ball (T6) end mills have 1/8 in shanks, but the document
he was cutting from had them at 0.0625 in, so ToolWiz under-fed every operation using them. The same document has tool
number 2 defined twice with different flute length and stickout. Keeping every document's tools in step with the
master, automatically and with a report, is a core requirement, not an extra.

**Chamfers.** A chamfer mill on a Trace or 2D Chamfer is always a finishing pass, and often the most visible surface
on the part. ToolWiz has no chamfer-mill model today (the Setup Advisor skips these operations), so chamfer presets
need a source: manufacturer data or values he approves by hand.

**Scallop practice.** He wants a standard practice of not running Scallop until roughing is completely finished.

## What already exists in this repository

- `master_library.py`, `routes_master_library.py`: merge libraries, de-duplicate, generate tagged ToolWiz presets per
  material set, audit and prune. `docs/TOOL_LIBRARY_NOTES.md` describes it.
- `library_audit.py`, `docs/SHOP_LIBRARY_AUDIT.md`: the audit of the owner's library (105 presets that would break a
  tool or make no sense; Fusion stock presets up to 35,000 rpm on a 16,000 rpm spindle).
- `tool_library_curator.py`: safe geometry repairs.
- `data/material_sets.json`: the two default material sets; several of the owner's materials are missing from it.
- `data/shop_library/`: three saved library files (may be older than what is in Fusion now). Seen in them: wrong
  material labels (a carbide tool marked HSS), duplicate tools, tool numbers 0, 4, 11 and 21 each used by several
  tools, many tools with no vendor.
- The add-in: harvest of local, cloud and hub libraries and document tools; `import_library_by_name`;
  `update_tool_fields` (coating, description and a few text fields on a document tool; not yet proven in live
  Fusion). There is no action yet that replaces a document's tool from a library.
- Engine limits to keep in mind (`docs/HANDOFF.md`): ball and bull-nose tools have no per-brand charts; micro tools
  and hard materials are the weakest areas; Haas is not mapped to any vendor chart.

## Steps the owner has agreed to in outline

| Step | What happens | Writes to Fusion? |
|---|---|---|
| A. Harvest | Read every library and the tools in the documents on the shop PC; push the snapshot. | No |
| B. Tool sheet | Merge duplicates; one row per physical tool (number, brand, carbide or HSS, coating, geometry, stickout, holder). The owner corrects it. | No |
| C. Presets and change log | Regenerate presets per tool, material and applicable strategy; compare with the old ones; log large changes with the reason. | No |
| D. Publish the master | Back up, then write the cleaned library to the single source of truth. | Library only |
| E. Replace document tools | Per document: dry-run report, owner confirms in Fusion, then replace. Prove it on a copy first. | Documents |

Step E is new and is the risky part: every operation must stay attached to its tool, and toolpaths need regenerating.

## Questions to work through with the owner first

1. Master in the Fusion hub, or in our own database that feeds Fusion and the machine? What does each cost to keep
   working over years? Can the add-in write hub libraries at all?
2. Numbering: which numbers are permanent carousel tools (1 to 21), which are shelf tools, and how the 99 controller
   slots are used. How does a tool keep its identity and its life count when it moves between numbers?
3. Tool life: what the C00 controller can report and accept through the owner's local app, and what should be
   tracked (minutes in cut, parts, breakage, regrinds).
4. Which materials are active now, and which are kept only for completeness. What "410" copper is.
5. Which strategies each tool type gets.
6. Where manufacturer data exists for his tools (Haas publishes theirs) and how he approves values by hand.
7. What counts as a "large" change for the log (first suggestion: more than 25 % on axial or radial depth, more than
   1 degree or 15 % on ramp angle).
8. Holders and tooling to buy for the ratchet knife project.
