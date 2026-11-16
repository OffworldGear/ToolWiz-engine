# ToolWiz shop workflow (DRAFT for the owner to correct)

Written 2026-11-16 by the cloud session from the owner's description. Nothing here is final until he says so.
Steps marked **(not built)** describe where the workflow is going; the tool library they need is the tool-system
project (`docs/TOOL_SYSTEM_PROJECT_BRIEF.md`), and the declared strategies are the draft in
`docs/STRATEGY_DEFINITIONS.md`.

The point of a fixed workflow: ToolWiz does not have to cover every situation. The owner works in a known order, each
tool does one job, and the Setup Advisor warns when a step was missed or done wrong.

## The workflow the owner wants

1. **The master tool library is the starting point.** Every tool in it matches the real tool (shank, flute length,
   stickout, holder, coating, brand) and already carries one cutting-data preset for each material he cuts and each
   strategy that tool can be used for. A preset is named material plus strategy, for example
   "Grade 5 Ti - Adaptive Roughing". **(not built)**
2. **Program the toolpaths in Fusion.** For each toolpath he picks the tool from the master library, or swaps the
   tool the toolpath uses for the one in the master library, and links the preset for the cut he is making. He sets
   the operation type, heights, stepdown, stepover and stock to leave. **(swap from the master: not built)**
3. **Only when a preset is missing:** he adds it, either with the Speeds & Feeds add-in on that toolpath, or in the
   digital twin library on the tool. Either way the new preset goes onto the tool in the master library
   automatically. Once the library is built out, Speeds & Feeds should rarely be needed. **(automatic update of the
   master: not built)**
4. **Regenerate the toolpaths.**
5. **Setup Advisor on the whole setup.** It looks for anything overlooked or done wrong and makes suggestions.
6. **He applies what he accepts, regenerates, and runs the advisor again** until nothing is left that he disagrees
   with.

Later, as its own project: Claude creates the toolpaths for a part from a file he provides, picking tools from the
master library, as a head start that he reviews. Probably a conversation in chat carried out through the Fusion
connection, guided by a written guidelines file. Not being worked on now.

## Until the library is built out (how to work today)

1. Check the tools in the document against the real tools. The advisor flags a small tool whose shank equals its
   cutting diameter and a tool with no coating; it does not yet flag a tool number with two definitions.
2. Program the toolpaths.
3. Run Speeds & Feeds on each cutting toolpath. Confirm the strategy it starts on, read the before-and-after preview,
   press OK. This links a preset named material plus strategy.
4. Regenerate.
5. Run the Setup Advisor. Do not apply a plan while toolpaths are regenerating or right after editing a tool; run it
   again first.

## What each tool is responsible for

| Tool | Its job | Not its job |
|---|---|---|
| Master library | The one good copy of every tool and its presets | |
| Speeds & Feeds add-in | One toolpath: calculate for the chosen strategy, show a preview, write the preset | Judging the setup as a whole |
| Digital twin library | Adding or changing a preset on a tool without opening a toolpath | |
| Setup Advisor | The whole setup: was the workflow followed, do the operations fit together | Deciding what kind of cut an operation is |

## What the advisor warns about

| Step | Warning | Today |
|---|---|---|
| Tools | Small tool with shank equal to cutting diameter | yes |
| Tools | No coating recorded | yes |
| Tools | Holder not suited to the runout the cut needs | yes |
| Tools | One tool number with two definitions in the document | no |
| Tools | Document tool differs from the master library | no (needs the master) |
| Preset | No ToolWiz preset on a cutting toolpath ("Speeds & Feeds was not run here") | no |
| Preset | A ToolWiz preset for another kind of cut | yes |
| Preset | A preset for another material than the setup's | no |
| Preset | Values changed by hand since the preset was written | no |
| Toolpath | Not measured (being regenerated or invalid) | yes |
| Setup | Finishing before roughing; stock left with no finishing pass; roughing to size | yes |
| Setup | Small tool after a much larger one with no rest pass | yes |
| Setup | Finishing pass finds more stock than it expects | partly (heavy finishing pass) |
| Setup | Tapping feed does not match rpm x pitch | yes |
| Setup | Spindle speed above the machine limit; stepdown longer than the flutes | yes |
| Setup | Shallow ramp angle on a cut that is itself too aggressive | yes |

## Rules already agreed (2026-11-13 to 16)

- The advisor never raises a ramp angle. Speeds & Feeds raises one only when it lowers the feed or the depth of cut
  in the same change, and says so in its preview.
- Ramp and plunge feed are set on every cutting operation and never above the cutting feed.
- The owner's stock to leave is kept.
- A chamfer mill is always a finishing pass and always has a lead-in.
- Scallop is not run until roughing is completely finished.
- Tool grade: name-brand tools are HP, tools with no name brand are standard.
- A light 2D Contour pass with positive stock to leave is a semi-finishing pass.
- Fusion's generic presets ("Aluminum - Roughing") are not ToolWiz strategies.

## Open questions for the owner

1. Once a toolpath has a ToolWiz preset, should the advisor still propose different speeds and feeds for it, or only
   warn and point to the preset? (Suggested: warn only, so a feed is set in one place.)
2. Operations ToolWiz does not calculate (engraving, dovetail, lollipop, thread mill): silent, or a reminder that they
   were not checked?
3. Should drills and taps carry ToolWiz presets too, so the advisor can expect one on every cutting toolpath?
4. Which brands count as name brands beyond the charted makers and Haas (Maritool, Speed Tiger, SpeTool, Klot)?
