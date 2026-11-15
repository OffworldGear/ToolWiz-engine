# Cutting strategy definitions (DRAFT for the owner's review)

Status: draft written by the shop PC session on 2026-11-15 from a discussion with the owner. It is not a work request.
Nothing here is decided until the owner says so. Numbers marked "starting value" are common-practice values proposed
by the shop PC session; they are not vendor data and have not been cut on the owner's machine.

Shared with the cloud session on 2026-11-15 on the owner's instruction ("Send it"), as a draft to read. The decisions at
the end are still open and are the owner's.

## The idea

Today ToolWiz works out what a cut is by reading the Fusion operation: its type, stepdown, stepover, heights and
measured geometry. That guess is where most of the field-test problems came from (entries 10, 18 and 19: a 2D Contour
can be a slot, a wall finish or a roughing pass, and nothing in Fusion says which).

The owner's proposal: the cut is declared, not inferred. Each cutting strategy has a written definition. ToolWiz
calculates for the declared strategy and checks that the operation fits it. The owner's words: "I want to make things a
little simpler and less subject to interpretation."

## How a strategy is declared

The declared strategy is the cutting-data preset linked to the operation. Presets are stored with the tool in the
library, ToolWiz controls their names, and a name carries both the material and the strategy, for example
"Grade 5 Ti - Adaptive Roughing" or "7075 (T6, T651) - Slotting". ToolWiz already writes names in this form.

An operation always has a preset, but it can be the wrong one. So the advisor's job changes from guessing to checking:

| Check | Example from EndCapOnlyManufacture on 2026-11-15 |
|---|---|
| The preset name is a known material and a known strategy | "GWizStainless304" on the two tapping ops and "Default preset" on the engrave ops are not |
| The preset's material is the material the setup is cut in | "GWizStainless304" in a 7075 setup; Fusion's generic "Aluminum - Roughing" names the family but not the alloy |
| The strategy is allowed for the tool type | a slotting preset on a ball end mill would not be |
| The strategy is one the Fusion operation type can be (table below) | "Aluminum - Roughing" on the three scallop finishing ops is not |
| The operation uses the preset's stepdown and stepover, or stays inside the strategy's limits | Fusion shows "(custom)" when it does not |
| A finishing pass finds the stock it expects | the scallop finish assumes 0.003 in; the roughing before it leaves 0.0059 in |

Where a check fails the advisor says so and proposes no feed for that operation. It does not reinterpret the cut.

## One list of strategies

There are three lists today: the web calculator's, the Speeds & Feeds dialog's and the advisor's "kind". This table
would replace all three. "Engagement" is what the strategy means; a tool's vendor chart replaces the starting values
where the tool has one.

| Strategy | What it is for | Engagement (starting values) | Stock | Today |
|---|---|---|---|---|
| Adaptive Roughing | Bulk removal with a constant light side load | Stepover 8 to 15 % of D, depth up to 2 x D (flute length at most); feed raised for chip thinning | Leaves roughing stock | web, dialog |
| Standard Roughing | Conventional pocketing and profiling where adaptive does not fit | Stepover 30 to 50 % of D, depth up to 1 x D (0.5 x D in stainless and titanium) | Leaves roughing stock | web; dialog calls it "Roughing" |
| Slotting / Tab Milling | Full-width cuts taken in small stepdowns; also clearing what roughing could not reach past a screw or a vise jaw | Width = D; depth per pass up to 0.5 x D for tools of 1/8 in and under (0.25 x D in stainless and titanium), up to 1 x D for larger tools in aluminum | Leaves roughing stock on the walls | web, dialog |
| Rest Roughing (corner cleanup) | A smaller tool removing what a larger one left in corners | Engagement is unknown and spikes in corners, so calculated as a full-width cut at up to 0.5 x D deep | Leaves roughing stock | new |
| Bore Roughing (helical, no predrill) | Opening a hole by helical interpolation from solid | Helix at 1 to 3 deg; programmed feed = edge feed x (bore diameter - D) / bore diameter | Leaves roughing stock | new |
| Facing | Cleaning the top of the stock | Stepover 50 to 75 % of D, shallow | None | web, dialog |
| Semi-Finishing: wall, floor, 3D contour | Evening out the roughing stock so the finish pass sees a constant load | Removes the roughing stock; depth and stepover between roughing and finishing | Expects roughing stock, leaves finishing stock | web has one "Semi-Finishing"; 3D contour is new |
| Wall Finishing | Final pass on vertical walls | Radial cut = the finishing stock; depth up to the flute length; limited by deflection | Expects finishing stock, leaves none | web; dialog calls it "Finishing" |
| Floor Finishing (Skim) | Final pass on flat floors | Depth = the finishing stock; stepover 30 to 60 % of D | Expects finishing stock, leaves none | web, dialog |
| 3D Contour Finishing (Scallop) | Final pass on sculpted surfaces with a ball or bull-nose tool | Depth = the finishing stock; stepover from the cusp height wanted | Expects finishing stock, leaves none | web, dialog |
| Bore Finishing | Final pass on a bore wall | Radial cut = the finishing stock; the same feed correction as Bore Roughing | Expects finishing stock | new |
| Chamfering / Deburr | Edge breaks and chamfers with a chamfer mill or ball | By the tool, at the chamfer width | None | web "Chamfering", dialog |
| Engraving | Lettering and marks | By the tool, at the line depth | None | dialog |
| Drilling, Peck Drilling, Reaming, Tapping | Hole making | By the tool | None | dialog |

Not strategies:

- **High feed.** A high-feed end mill is a kind of tool, not a kind of cut. It is used with Adaptive Roughing, Standard
  Roughing or Slotting, and its much lower depth of cut comes from the maker's data, which the owner supplies (he plans
  these tools for stainless and titanium only). With no data ToolWiz says so and proposes nothing. The web calculator's
  "High Feed Milling" strategy would become a property of the tool.
- **Tap style.** Fusion stores the owner's form tap as "tap right hand"; only its description says "Form". Thread mill is
  its own tool type in Fusion. Form, spiral-flute and spiral-point would be stored once on the tool, not chosen for each
  operation, so the four tapping entries in the dialog become one.
- **Plain "Finishing", plain "Roughing" and "Unknown"** go away: the first two are split or renamed above, and an
  unrecognised preset is a failed check, not a strategy.

## Which strategies a Fusion operation can be

| Fusion operation | Can be |
|---|---|
| 2D or 3D Adaptive | Adaptive Roughing, Rest Roughing |
| 2D Pocket | Standard Roughing, Rest Roughing |
| 2D Contour | Slotting, Standard Roughing, Rest Roughing, Semi-Finishing (wall), Wall Finishing, Chamfering (chamfer mill) |
| Trace | Slotting, Chamfering, Engraving |
| Face | Facing |
| Flat, Horizontal | Semi-Finishing (floor), Floor Finishing |
| Scallop, Parallel, 3D Contour, Pencil, Ramp, Flow, Morph, Spiral, Radial, Steep and Shallow, Blend, Project | Semi-Finishing (3D contour), 3D Contour Finishing |
| Bore, Circular | Bore Roughing, Bore Finishing |
| 2D Chamfer, Deburr | Chamfering / Deburr |
| Engrave | Engraving |
| Drill | Drilling, Peck Drilling, Reaming, Tapping (by tool type) |

## Stock to leave (proposal; the owner asked for one)

The owner's practice: 0.1 mm after roughing for tools from 1/4 in down to 1/16 in, sometimes 0.02 mm, which he
thinks of as a semi-finishing stock.

What decides it: the stock has to be more than the unevenness roughing leaves (tool deflection and scallops), and
thick enough that the finishing tool cuts a real chip on every flute (several times the holder's runout and the edge
radius). It also has to be thin enough that a small finishing tool is not loaded like a rougher. So it follows the size
of the tool that removes it, and stainless and titanium need a little more, because they work-harden when the tool
rubs.

Starting values, radial, by the diameter of the tool that will remove the stock (the same value for axial stock on
floors):

| Tool that removes it | Left by roughing | Left by semi-finishing, aluminum | Left by semi-finishing, stainless and titanium |
|---|---|---|---|
| 1/16 in | 0.05 mm (0.002 in) | 0.025 mm (0.001 in) | 0.03 mm (0.0012 in) |
| 1/8 in | 0.10 mm (0.004 in) | 0.04 mm (0.0015 in) | 0.05 mm (0.002 in) |
| 1/4 in | 0.15 mm (0.006 in) | 0.05 mm (0.002 in) | 0.08 mm (0.003 in) |
| 3/8 in and over | 0.20 mm (0.008 in) | 0.05 mm (0.002 in) | 0.10 mm (0.004 in) |

- The owner's 0.1 mm matches the 1/8 in row and is fine at 1/4 in. For a 1/16 in finishing tool it is twice what the
  table gives.
- 0.02 mm is close to the runout of an ER collet, so one flute may do all the cutting. It works as a final skim in
  aluminum; it is too thin for stainless and titanium.
- The engine already reports a stock from the deflection it predicts for the roughing pass
  (`recommended_radial_stock_in`). The table would be the least it uses; where the predicted deflection asks for more,
  that wins.
- These are to be corrected from real cuts with Log Cut Result.

## When presets are made (not decided)

The owner: "We will need to decide when we create or update the tool in the tool library or if it needs to happen in
the setup." Two places it can happen:

- **In the library.** When a tool is added or updated, ToolWiz makes one preset for each material the owner cuts and
  each strategy the tool type allows. The setup then only links them.
- **In the setup.** The Speeds & Feeds dialog adds a missing preset when the owner asks for it, as it does today.

The shop PC session's suggestion: the library is the source, the dialog can add a missing one (shown in its preview),
and the advisor never creates a preset on its own. A tool or a material may have no preset for a strategy; the advisor
then says so.

## Decisions needed from the owner

1. The stock-to-leave table: accept, change, or leave stock out of the first version.
2. Which materials get presets (the list he cuts), and what to do with Fusion's generic presets ("Aluminum - Roughing")
   already on his tools: treat as not ToolWiz strategies, or map them.
3. Whether thread milling is needed as a strategy.
4. Whether Bore Roughing and Bore Finishing are both wanted, or only the roughing one he named.
5. The order of work: this is a large change to the calculator, the dialog and the advisor, and the field test of the
   Speeds & Feeds preview is not finished.
