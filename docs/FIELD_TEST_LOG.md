# ToolWiz field test log

One running list while the owner tests ToolWiz on real setups. Started 2026-11-14, on `78b0ded` (add-in as installed
from `0220a74`; no add-in change since). Fix rounds are paused: the cloud session does not push to
`toolwiz/v4-advisor` during the test, so the code under test stays the same.

Rules for this file:
- Add entries as they come up. Don't send them to the cloud session one by one.
- Commit and push when the owner says the testing session is over.
- Push straight away only for something unsafe: a wrong value written to Fusion, a crash, a result that would break a tool.
- The aim is to find anything bigger that is wrong. Cosmetic points are logged, marked as such, and left.

Severity: **unsafe**, **blocked** (the owner couldn't do what they wanted), **wrong** (a result the owner disagrees
with, but could work around), **cosmetic**.

## Entries

| # | Date | Setup > operation | What happened | What was expected | Exact text or numbers | Severity |
|---|---|---|---|---|---|---|
| 1 | 2026-11-14 | Op2EndCap7075 > 2D Contour206 (3), (7) | The "Ramp is off" note says "at each depth" on single-depth slots. | "would ease the entry" without "at each depth". | "Turning on Ramp in Fusion would ease the entry at each depth; ToolWiz's ramp angle for this tool would be 3.0 deg." | cosmetic |
| 2 | 2026-11-14 | Op1EndCap7075, Setup Advisor dialog, apply at 60 % | Worked. Confirmation: "ToolWiz will change 34 parameter(s) on 11 operation(s)". Result: 34 applied on 11 ops, none failed. | Same. | Every value in the dialog equals the server's plan at aggressiveness 0.6 (checked op by op). No ramp angle and no stock to leave in the list; the owner's 2 deg ramp angles untouched. | pass |
| 3 | 2026-11-14 | Op1EndCap7075 > Flat34 (negative stock to leave for anodize); also 2D Contour7 (EndCapCleanUP), 2D Contour239 (4), FrameEndCapBevelsCounterBoreScallop4 (6) (all 1/16 in, 4 flute, 0.5 in stickout) | The applied "recommended" plan writes only feed and rpm, and the feed is for ToolWiz's own engagement, not the op's. Feed doubled on four finishing ops. On Flat34 the same run says the op's own engagement allows 3.17 in/min. | The feed written should fit the engagement the op will cut, or the plan should say it assumes a 0.002 in skim. The two numbers on Flat34 should not contradict. | All four: 25.56 in/min at 11999 rpm (0.00053 in/tooth) -> 51.03 at 16000 (0.00080), CleanUP from 32.30. ToolWiz's basis: ap 0.1875, ae 0.00197 in ("Finishing"). Flat34's real engagement: stepover 0.01875, stepdown 0.0394; `keep_engagement` 3.17 in/min; STOP "chip load … ratio of 10.9x". Scallop (6): stepover 0.0049, `keep_engagement` 28.77. Contours: stepover not in the snapshot; the adaptives before them leave 0.0059 in, three times the 0.00197 assumed. Flat33 (4) (1/8 in): 63.42 -> 74.87, `keep_engagement` 28.23, STOP 3.0x. | wrong (owner to judge whether it's unsafe; not cut yet) |
| 4 | 2026-11-14 | Op1EndCap7075 > Trace1 (2) (T19, Chamfer 4fl 90deg altin) | A chamfer-mill trace is analysed as roughing with a 1/4 in flat end mill. It gets a STOP and a "different tool" suggestion to replace the chamfer mill with an end mill. | Treated like 2D Chamfer (edge op): no roughing numbers, no tool swap. | Kind `rough`; ToolWiz: "Roughing", ap 0.25, ae 0.0718, MRR 1.568 in3/min. Applied: feed 146.70 -> 87.36 in/min, plunge 13.12 -> 25.97, rpm 12224 -> 16000. "[STOP] Chip load is more than double ToolWiz's … ratio of 2.2x". "[info] A different tool is 91% faster for this cut (1/4 3-Flute Carbide Endmill) … cycle time 0.04 min against 0.04 min". | **big error** (owner) |
| 5 | 2026-11-14 | Op1EndCap7075 > FrameEndCapBevelsCounterBoreScallop4 (6) (T6, 1/16 in ball) | "Different tool" suggests a flat end mill for a ball-mill scallop op, with an implausible gain. | No flat end mill offered for a 3D scallop pass. | "[info] A different tool is 3026% faster for this cut (1/16" Flat Endmill) … 3 flutes instead of 4 gives 31.3x the finish rate at the same Ra and wall targets." | **big error** (owner: "even though it is just a recommendation") |
| 6 | 2026-11-14 | Op1EndCap7075 > Adaptive48 (3), (4) | The recommended plan cuts the removal rate by about 73 %. Noted for the owner's judgement, not as a defect. | — | Stepdown 0.45 -> 0.2812 in, optimal load 0.0375 -> 0.0121 / 0.0125 in, feed 50.19 -> 66.56 / 65.65 in/min, rpm 11999 -> 16000. MRR 0.847 -> 0.227 in3/min. | fine (owner: "I am fine with the updated Adaptive if the speeds and feeds are more sensible. That is the main reason I want the setup analyzer function!") |
| 7 | 2026-11-14 | Setup Advisor result dialog | Old values are shown as raw expressions, unlike the confirmation dialog. | Rounded values as in the confirmation ("50.19 in/min", "11999 rpm"). | "tool_feedCutting: 50.1921790628448in/min -> 47.74 in/min", "tool_spindleSpeed: 11999.11612839420377 -> 16000 rpm", "12224. -> 16000 rpm", the plunge formula printed in full. | cosmetic |

## Causes found in the code (entries 3 to 5), `78b0ded`

Reported to the cloud session "Continue ToolWiz from the handoff note" on 2026-11-14 at the owner's request.

**Entry 3, finishing feed not computed for the real cut.** The owner asked why no feed was computed for the 1/16 in
finishing ops' own cuts.
- `_apply_plans` (`setup_advisor.py` ~922 to 946): for kind `finish` the `recommended` plan is only
  `tool_spindleSpeed` and `tool_feedCutting`, taken from `rec`. `rec` is ToolWiz's run with no engagement from the op,
  so it uses the "Finishing" default: ap = the flute length (0.1875 in on the 1/16 in flat, 0.25 on the ball, 0.5 on
  the 1/8 in) and ae = 0.00197 in (0.05 mm). The engagement is not written and not compared with the op.
- The feed for the op's own cut (`usr`, the `keep_engagement` plan) exists only when the op has both a stepdown and a
  stepover. A single-pass 2D contour has no stepover, so on 2D Contour7 (EndCapCleanUP) and 2D Contour239 (4) no feed
  for the real cut was computed at all. Nothing links the contour to the stock the earlier op leaves (0.0059 in here).
  Kind `contour` ops get a note saying so; these `finish` ops get none.
- On Flat34 and the scallop the real-cut feed was computed (3.17 and 28.77 in/min), but the pre-ticked plan is the
  default-engagement one (51.03). Flat34's 3.17 in/min (0.00005 in/tooth) looks wrong in its own right: I believe the
  wall-finishing model is being applied to a floor pass (Flat strategy, 0.019 in stepover, 0.039 in stepdown).

**Entry 4, Trace1 with a chamfer mill.** `classify_op` (~262 to 294) returns `edge` only when the *strategy* contains
chamfer, deburr or engrave. Strategy `trace` falls through to `rough`; the tool type ("chamfer mill") is not looked
at. `_run_endmill` (~539) passes the engine only `geometry` = "Square" or "Radiused" (and `_fusion_tool_dict`, ~474,
only "flat end mill" or "bull nose end mill"), so the chamfer mill is computed as a 1/4 in square end mill.

**Entry 5, flat end mill offered for a ball-mill scallop.** Same cause: the ball end mill is computed as a square
end mill. The "different tool" comparison offered a flat end mill for a scallop op, so it evidently does not filter
candidates by tool type or strategy (I did not read that code).


- The Setup Advisor dialog on `78b0ded` for PrepEndCapStock and Op2EndCap7075: the three "Ramp is off" notes, single
  recommendation on Face1, no stock cautions on 2D Contour1 and 2D Contour7 (EndCapOutline) (8). (Op1EndCap7075 seen,
  entry 2.)
- The Speeds & Feeds result dialog: the chart sentence under "Ramp angle" ("limit 6.5 deg at 50% …").
- A real Claude Code client on `/api/mcp`.
- A peck or deep-drill op for the "Peck Drilling (Deep Hole)" label.

## Open questions for the owner

- When ToolWiz keeps the owner's ramp angle (inside the tolerance), should it still propose its ramp feed? Today the
  feed is dropped with the angle (e.g. 3D Adaptive Roughing2 (2): 40.79 in/min stays, 39.31 not proposed).
- The Speeds & Feeds auto-setter writes ToolWiz's ramp angle into the preset and links the op to it, which overwrites
  a custom angle on the op. Keep that, or leave a custom angle alone?

## Cloud session fixes, 2026-11-14 (server only; the add-in is unchanged: pull and restart the server)

Regression tests: `tests/test_field_log_2026_11_14.py`. Rules are written up in `docs/SETUP_ADVISOR.md`
("Tool form and finishing engagement").

| Entry | What changed | For the shop PC to re-check in live Fusion |
|---|---|---|
| 3 | A finishing op is offered speed and feed only for its own stepdown and stepover. ToolWiz's 0.002 in skim feed is never written. No stepover on the op: nothing is offered, and a note says why and gives the skim numbers for reference. A pass too heavy for the wall tolerance: CAUTION `finish_cut_too_heavy`, nothing offered, no chip-load STOP against a rubbing feed. | Flat34, Flat33 (4), Scallop4 (6): the plan feed equals `at_current_engagement`, or there is no plan plus the CAUTION. 2D Contour7 and 2D Contour239 (4): no plan, the note. Please record `limited_by` for Flat34 at its own engagement: the 3.17 in/min was not reproduced here (19.44 in/min with a 0.5 in stickout and 0.125 in shank; 5.85 with 0.75 in stickout, limited by "wall error"). |
| 4 | A form tool (by Fusion tool type) makes the op kind `edge` on any strategy. | Trace1 (2) and Op2 Trace1 (3): no numbers, no plan, no tool suggestion, the "Form tool (chamfer mill)" note. |
| 5 | A ball end mill is sent to the engine and to the tool comparison as a ball. | Scallop4 (6) and Adaptive48 (4): no flat end mill offered. |
| 1 | "at each depth" is left out when multiple depths are off. | Op2 2D Contour206 (3), (7). |
| 7 | Not changed (cosmetic, needs an add-in change). | — |

**The owner's document still holds the values applied before these fixes.** The feeds written to the four 1/16 in finishing
ops (51.03 in/min), to Flat33 (4) (74.87) and to Trace1 (2) (87.36 in/min, 16000 rpm, plunge 25.97) came from the faulty
plan. Run the advisor again after the restart, or put the earlier values back, before regenerating or cutting.

Not verified here: live Fusion, the dialog, the owner's real tool data. Open point for the owner: on a floor-only pass
(Flat) the wall tolerance still limits the feed; whether a floor pass should ignore it is an engine question for after the
freeze.
