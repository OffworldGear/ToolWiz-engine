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
| 8 | 2026-11-14 | Op2EndCap7075, Setup Advisor dialog, apply at 60 % | Worked. Confirmation: "ToolWiz will change 40 parameter(s) on 14 operation(s)". Result: 40 applied on 14 ops, none failed. Header: "2 STOP, 26 CAUTION, 11 info finding(s) in 20 operation(s)." | Same. | Every value equals the server's plan at 0.6. No ramp angle, no stock to leave. The "Ramp is off" INFO is in the data for 2D Contour206 (3) and (7); not visible in the screenshot. | pass |
| 9 | 2026-11-14 | Op2EndCap7075: Flat34 (-.005 for anodize), Flat33 (5), Flat33 (6), EndCapBevelsCounterBoreScallop4 (7), BoreScallop4 (9), Trace1 (3) | Entries 3, 4 and 5 again on the second setup. | As entries 3 to 5. | Flat34 (1/16 in): 32.30 -> 51.03 in/min; `keep_engagement` 2.05; "[STOP] … ToolWiz gets 0.00003 in/tooth (2.05 IPM at 16000 rpm) for the same engagement, a ratio of 21.0x". Flat33 (5) (1/4 in): 92.00 -> 132.04, basis ap 0.75 / ae 0.00197, op has stepover 0.075 / stepdown 0.039, `keep_engagement` 83.87 at 15584 rpm. Flat33 (6) (1/8 in): 50.19 -> 74.87, `keep_engagement` 42.82. Scallop4 (7) (1/16 in ball): 25.56 -> 51.03, `keep_engagement` 42.02. BoreScallop4 (9): 25.56 -> 51.03, `keep_engagement` 65.41. Trace1 (3) (chamfer mill): 146.70 -> 87.36, plunge 13.12 -> 25.97, same STOP and "91% faster" tool swap as Trace1 (2). | as 3, 4, 5 |
| 10 | 2026-11-14 | Op2EndCap7075: 2D Contour206 (4), 2D Contour64, 2D Contour64 (2), 2D Contour7 (EndCapOutline) (8), (9) (kind `contour`, single pass, no stepover) | Same root as entry 3: the feed written is for a radial engagement ToolWiz assumes. These went down or barely moved, so no concern for the cut. | A feed for the stock the contour really removes. | 1/16 in contours: 25.56 / 32.30 -> 30.47 in/min, basis "Roughing" ap 0.0625, ae 0.00327. 1/8 in outlines: 50.19 -> 47.74, basis ap 0.1995, ae 0.0272. | wrong (low impact here) |
| 11 | 2026-11-14 | Op1EndCap7075 after regenerate | Cycle time with the lighter adaptives. For the owner's picture, not a defect. | — | Setup 12:41 -> 12:44. Adaptive48 (3) 0:36 -> 1:02, Adaptive48 (4) 0:21 -> 0:35 (browser times, from the screenshots). | info |

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

## Cloud session, 2026-11-15: the owner's answers (server only; pull and restart)

- **Flat / Horizontal ops are floor finishing in the advisor**, as in the Speeds & Feeds dialog (owner: "The Flat data in
  Op0 and Op1 should be generated by ToolWiz. If it is wrong then there might be a bug." It was: the dialog used
  "Floor Finishing (Skim)", the advisor wall "Finishing"). Re-check Flat34 and Flat33 (4): no STOP against the dialog's own
  numbers; the plan feed equals `at_current_engagement`, whose `operation` is "Floor Finishing (Skim)".
- **Ramp feed and plunge feed are always in the plan**, also when the ramp angle is kept or Ramp is off. Re-check
  3D Adaptive Roughing2 (2): `tool_feedRamp` is proposed, the 2 deg angle is untouched.
- **New CAUTION `ramp_shallow_cut_aggressive`** when the ramp angle is below 60 % of ToolWiz's limit and the op is also
  above ToolWiz on chip load, feed, stepdown, stepover or ramp feed.
- **SK / SX collet chucks: 0.003 mm (0.000118 in)**; `runout_source` reads "holder: SK/SX collet".
- **Too-heavy guard** now also applies when a finish mode (accuracy, surface) was chosen in the dialog.

Requests to the shop PC session (the cloud session cannot message it):
1. For Flat34 and Scallop4 (6), record from the advisor result: `toolwiz.at_current_engagement` (`operation`, `feed_ipm`,
   `limited_by`), the finish mode chosen in the dialog, and the tool's stickout and shank as the snapshot sent them.
2. Open the Speeds & Feeds dialog on Scallop4 (6) and record its feed and rpm: the dialog uses the older scallop operation
   and may give a much higher feed than the advisor (about 88 against 33 in/min here). Do not apply it.
3. Entry 7 (raw expressions in the result dialog) is still open; it needs an add-in change.

## Shop PC re-check of `9e918c9` and `e8790a7`, 2026-11-14 evening (shop time)

Pulled, server restarted (`/api/version`: `e8790a7`), add-in not reinstalled, fresh setup summary (45 ops). Windows
tests (`test_field_log_2026_11_14.py`, `test_runout_defaults.py`, the verify tests, `test_v2_ramp.py`,
`test_addin_twlogic.py`, `test_mcp_http.py`): **180 passed**. Advisor at aggressiveness 0.6, read-only.

**The document now holds the values the owner applied from the faulty plan** (entries 2 and 8), so "current" below is
51.03 in/min at 16000 rpm on the 1/16 in finishing ops, not the original 25.56 at 11999. Summary: 2 STOP, 24 CAUTION,
13 info. Both STOPs are the two Flat34 ops against their applied 51.03 in/min.

| Entry | Result |
|---|---|
| 3 Flat ops | **Pass.** Plan feed equals `at_current_engagement`, operation "Floor Finishing (Skim)" (v1, `limited_by` "geometry_rule"): Flat34 (Op1 and Op2) 22.21 in/min, Flat33 (4) 44.41, Flat33 (6) 44.41, Flat33 (5) 88.82. The plan holds `tool_feedCutting` only (rpm already 16000). |
| 3 Scallops | **Pass.** Plan feed equals `at_current_engagement` (wall "Finishing", v2): Scallop4 (6) 28.77, Scallop4 (7) 42.02, BoreScallop4 (9) 65.41. |
| 3 Single-pass finish contours | **Pass.** 2D Contour7 (EndCapCleanUP) and 2D Contour239 (4): no plan, and the note "No speed or feed is proposed: this finishing pass has no stepover in Fusion, … For reference only, ToolWiz's finishing numbers for a 0.0020 in skim over a 0.1875 in depth are 51.03 in/min at 16000 rpm; a heavier cut needs a lower feed." |
| 4 Form tool | **Pass.** Trace1 (2) and Trace1 (3): kind `edge`, no numbers, no plan, no finding, no tool suggestion. Note: "Form tool (chamfer mill): ToolWiz's end-mill model does not describe it, so this operation is not checked as a roughing or finishing cut and nothing is proposed for it." |
| 5 Ball mills | **Pass.** No "different tool" finding on Scallop4 (6), Scallop4 (7), BoreScallop4 (9) or Adaptive48 (4). |
| 1 "at each depth" | **Pass.** 2D Contour206 (3), (7): "Turning on Ramp in Fusion would ease the entry; ToolWiz's ramp angle for this tool would be 3.0 deg." 2D Contour2 (multiple depths) keeps "at each depth". |
| Ramp feed always proposed | **Pass, with one difference from the request.** `tool_feedRamp` is now in the plan of 13 ops, including ops with Ramp off (2D Contour206 (3), (7), (4), 2D Contour64, 64 (2): 17.83 in/min) and ops whose 2 deg angle is kept (Adaptive48 (3), Adaptive49 (2), the EndCapOutline contours: 40.79; Adaptive48 (4): 53.45). No plan contains a ramp angle. 3D Adaptive Roughing2 (2) has no plan: its angle is 3.0 deg (applied on 2026-11-13, not 2 deg) and its ramp feed already equals ToolWiz's 40.79. |
| `ramp_shallow_cut_aggressive`, `finish_cut_too_heavy` | Neither fires on this document. The owner's 2.0 deg against a 3.0 deg limit is 67 %, above the 60 % threshold. |

### Answers to the cloud session's requests

1. From the advisor result (my call sent no finish mode; `settings`: aggressiveness 0.6, model v2, runout 0.0001 in,
   machine_max_rpm 16000; what the dialog sends is not visible to me):

| Op | `at_current_engagement` | Tool as the snapshot sent it |
|---|---|---|
| Op1 Flat34 (negative stock to leave for anodize) | "Floor Finishing (Skim)", v1, 22.206 in/min, 16000 rpm, 0.000347 in/tooth, ap 0.03937, ae 0.01875, `limited_by` "geometry_rule" | "1/16" Flat Endmill", flat end mill, D 0.0625, 4 flutes, flute length 0.1875, **shank 0.0625**, stickout 0.5, holder "BT40 - B4C3-0020" |
| Op1 FrameEndCapBevelsCounterBoreScallop4 (6) | "Finishing", v2, 28.771 in/min, 16000 rpm, 0.00045 in/tooth, ap 0.25, ae 0.00492, `limited_by` "C2, C6, C7, wall error" | "1/16" Ball Endmill", ball end mill, D 0.0625, 4 flutes, flute length 0.25, **shank 0.0625**, stickout 0.5, holder "Maritool BT30-ER20-60" |

   The shank is the likely reason the cloud session got 19.44 where the shop PC got 3.17 in/min on Flat34 before the
   fix: the library gives a 0.0625 in shank, not 0.125. Question for the owner (entry 12).
   Before the fix (`78b0ded`, document as originally programmed) Flat34's `limited_by` was not recorded, and the
   original values are overwritten now, so it can't be re-read.
2. The Speeds & Feeds dialog on Scallop4 (6): the owner's to open; asked.
3. Noted.

### New entries from this re-check

| # | Date | Setup > operation | What happened | What was expected | Exact text or numbers | Severity |
|---|---|---|---|---|---|---|
| 12 | 2026-11-14 | T12 "1/16" Flat Endmill", T6 "1/16" Ball Endmill" (tool library) | The snapshot gives a 0.0625 in shank at 0.5 in stickout. If the real tools have a 0.125 in shank, ToolWiz over-estimates deflection and under-feeds every op with them. | The library's shank matches the tool. | shank 0.0625, stickout 0.5, flute length 0.1875 / 0.25. | **answered: the real tools have a 1/8 in shank** (owner, 2026-11-14: "Yes, 1/8\" shank"). The Fusion tool data is wrong for T12 (10 ops) and T6 (5 ops); they are the only end mills in the document with a shank under 0.125 in. The owner corrects the shank in Fusion; ToolWiz does not write tool geometry. |
| 13 | 2026-11-14 | Op2EndCap7075 > Flat33 (5) (Flat, 1/4 in) | The "different tool" comparison still measures a Flat op as wall finishing, while the advisor now treats it as floor finishing. | The comparison uses the same operation as the advice. | "[info] A different tool is 54% faster for this cut (Harvey 4-flute 0.25 in) … 15,584 rpm, 203.79 IPM, 0.2438 x 0.0020 in; wall finish rate 49.6804 in2/min against 32.1893 now (+54%)". | wrong (recommendation only) |
| 14 | 2026-11-14 | Flat34, original values | Could not re-check "no STOP against the dialog's own numbers": the originals are overwritten. By arithmetic the original 25.56 in/min at 11999 rpm is 0.00053 in/tooth against ToolWiz's 0.00035 now, a ratio of 1.5x, which would be a CAUTION (over 40 %), not a STOP. | — | 25.56 / (11999 x 4) = 0.000533; 22.21 / (16000 x 4) = 0.000347. | info |
| 15 | 2026-11-14 | T2 "1/4" Flat Endmill" | The document has two definitions under tool number 2: flute length 0.4375 / stickout 0.75 (PrepEndCapStock: 3D Adaptive Roughing2, 2D Contour1) and flute length 0.75 / stickout 1.0 (Op2EndCap7075: Flat33 (5)). ToolWiz computes each as given. | — | Shank 0.25 on both. | question for the owner (two tools, or one with stale data?) |

### What re-running the advisor does not put right in the owner's document

These hold values from the faulty plan and now get no plan, so they stay as they are unless the owner restores them:
- 2D Contour7 (EndCapCleanUP): 51.03 in/min at 16000 rpm (was 32.30 at 11999).
- 2D Contour239 (4): 51.03 in/min at 16000 rpm (was 25.56 at 11999).
- Trace1 (2) and Trace1 (3): 87.36 in/min, plunge 25.97, 16000 rpm (was 146.70, 13.12, 12224).

## Cloud session, 2026-11-15 (second round): the owner's answers. THE ADD-IN CHANGED: reinstall it

- **Ramp feed and plunge feed on every cutting op**, finishing and facing included (owner: "ramp feedrates should be set
  regardless of whether we are ramping or not. Same goes for plunging").
- **Scallop / parallel / morphed / ramp / flow ops in the Speeds & Feeds dialog now default to "Finishing"**, the same
  wall-finishing numbers the advisor gives (owner: "we should go with the advisor's recommendations"). Add-in change.
- **Entry 7**: the result dialog rounds old values ("50.19 in/min", "11999 rpm"). Add-in change.
- **Entry 13**: no "different tool" comparison on a Flat / Horizontal op.
- **Entry 12**: new INFO `shank_equals_diameter` on a tool under 1/8 in whose shank equals its cutting diameter, once per
  tool. It should show on T12 and T6 until the owner corrects the shank.
- **Chamfer-mill Trace** (owner: "chamfers are always finishing paths"): the note now reads "Chamfer pass with a chamfer
  mill (a finishing cut): ToolWiz has no model for this tool yet ...". Still nothing checked or proposed.
- Entry 10 (single-pass roughing contours): left as it is; the owner says they are rare.

Re-check for the shop PC: reinstall the add-in, restart the server; Speeds & Feeds on Scallop4 (6) starts on "Finishing";
finishing plans carry tool_feedPlunge (and tool_feedRamp where ToolWiz gives one); the result dialog shows rounded old
values; Flat33 (5) has no "different tool" finding; T12 and T6 carry the shank INFO.

## Shop PC re-check of `d16cd7d`, 2026-11-14 evening (shop time)

Pulled; Windows tests **185 passed**; add-in files reinstalled with `install_addin.py`; server restarted
(`/api/version`: `d16cd7d`); fresh setup summary (45 ops); advisor at 0.6, read-only. **The owner has not restarted the
add-in in Fusion yet**, so the two add-in items are not checked. The document still holds the values applied from the
faulty plan, and T12 / T6 still have the 0.0625 in shank. Summary: 2 STOP, 24 CAUTION, 15 info.

| Item | Result |
|---|---|
| Entry 12, `shank_equals_diameter` | **Pass.** Two INFOs, once per tool: T12 (on Op1 Flat34) and T6 (on Op1 Scallop4 (6)). "The tool is entered with a 0.0625 in shank, the same as its 0.0625 in cutting diameter. Most tools this small have a 1/8 in (or 3 mm) shank. With the thin shank ToolWiz predicts much more bending and lowers the feeds of every operation that uses this tool." |
| Entry 13, no tool comparison on Flat ops | **Pass.** Flat33 (5) has no "different tool" finding. |
| Ramp and plunge feed on finishing and facing ops | **Pass.** Flat33 (4), (6): `tool_feedCutting` 44.41, `tool_feedPlunge` 33.92, `tool_feedRamp` 50.88. Flat33 (5): 88.82 / 67.84 / 101.76. Scallop4 (6): 28.77 / 6.59 / 36.22; Scallop4 (7): 42.02 / 6.59 / 36.22; BoreScallop4 (9): 65.41 / 6.59 / 36.22. Face1: no plan, because its feed, plunge and ramp already equal ToolWiz's (140.77 / 70.39 / 105.58 at 13280 rpm). See entry 17 for Flat34. |
| Chamfer-mill Trace note | **Pass.** Trace1 (2), (3): "Chamfer pass with a chamfer mill (a finishing cut): ToolWiz has no model for this tool yet, so the operation is not checked and nothing is proposed for it. Your speeds and feeds are left as they are." No plan. |
| Speeds & Feeds default "Finishing" on scallop ops (add-in) | Not checked: needs the add-in restart, then the owner opens the dialog on Scallop4 (6). |
| Entry 7, rounded old values in the result dialog (add-in) | Not checked: needs the add-in restart and an apply by the owner. |

Flat34 and Scallop4 (6) with the 0.0625 in shank, for comparison after the owner corrects it: Flat34 22.21 in/min
("Floor Finishing (Skim)", `limited_by` "geometry_rule"); Scallop4 (6) 28.77 in/min ("Finishing", `limited_by`
"C2, C6, C7, wall error").

### New entries

| # | Date | Setup > operation | What happened | What was expected | Exact text or numbers | Severity |
|---|---|---|---|---|---|---|
| 16 | 2026-11-14 | Op2EndCap7075 > 2D Contour206 (4) (contour, single pass, stock off) | A "different tool" finding appeared that was not there on `e8790a7`. It claims a gain while its own cycle time is longer, and quotes a removal rate on an op whose note says none is worked out. | No comparison on a single-pass finishing contour, or numbers that agree with each other. | "[info] A different tool is 230% faster for this cut (1/16" Flat Endmill) - Best of your library: 1/16" Flat Endmill: 16,000 rpm, 23.84 IPM, 0.0625 x 0.0138 in; MRR 0.0065 in3/min against 0.0020 now (+230%), cycle time 0.09 min against 0.07 min." Same op's note: "No stepover on this operation … so no chip load or material removal rate is worked out at a width." | wrong (recommendation only) |
| 17 | 2026-11-14 | Op1EndCap7075 > Flat34 (and any op whose plunge feed is a formula of the cutting feed) | The plan lowers `tool_feedCutting` but leaves `tool_feedPlunge` out, because the plunge feed today (17.01 = 51.03 / 3, the Fusion formula) is close to ToolWiz's 16.96. After the apply the formula gives 22.21 / 3 = 7.40 in/min, not 16.96. A second advisor run would then propose it. | The comparison allows for a parameter that follows another one in the same plan. | Document: `tool_feedPlunge` 17.010 in/min (formula `tool_feedCutting/3`), ToolWiz 16.96. Plan: `{"tool_feedCutting": "22.21 in/min"}`. | wrong (low impact: the plunge ends up slower, not faster) |

## Shop PC re-check after the add-in restart and the shank correction, 2026-11-15 (shop time)

The owner restarted the add-in and set the shank of T12 (1/16" Flat Endmill) and T6 (1/16" Ball Endmill) to 0.125 in
in Fusion (`tool_shaftDiameter` ".125 in"; the snapshot gives SFDM 0.125 and a shaft segment 0.0625 to 0.125 over
0.5 in). Server `d16cd7d`, fresh setup summary, advisor at 0.6, read-only. Summary: 2 STOP, 27 CAUTION, 10 info. The
document still holds the feeds applied from the faulty plan. Toolpath status at the time: Op1 regenerated (Scallop4 (6)
had no toolpath yet), most of Op2 out of date.

| Item | Result |
|---|---|
| New add-in code loaded | **Pass.** The snapshot's `strategy_label` (what `infer_strategy_for_op` returns, the dialog's starting point) is now "Finishing" on Scallop4 (6), Scallop4 (7) and BoreScallop4 (9); it was "3D Contouring / Scallop Finishing" before the restart. |
| Speeds & Feeds dialog on Scallop4 (6) starts on "Finishing" | Label checked through the snapshot only. The dialog itself (a saved strategy preference can override the label) and its feed and rpm still need the owner to open it. |
| Entry 7, rounded old values in the result dialog | Not checked: needs an apply by the owner. |
| Entry 12, shank note | **Pass.** No `shank_equals_diameter` finding on T12 or T6 any more. |
| Entry 16, contradictory "different tool" finding | Gone with the corrected shank: no `better_tool` finding anywhere (3 before). Not reproduced, so not shown fixed. |

Feeds with the 0.125 in shank against the 0.0625 in shank (all at 16000 rpm, own engagement):

| Operation | 0.0625 in shank | 0.125 in shank |
|---|---|---|
| Flat34 (Op1 and Op2) | 22.21 in/min, `geometry_rule` | 22.21 in/min, `geometry_rule` (deflection 0.000344 to 0.000095 in on Op1) |
| Scallop4 (6) | 28.77 in/min, "C2, C6, C7, wall error" | **33.14 in/min**, "C2, C6, C7"; plunge 6.59, ramp 36.22 unchanged |
| Scallop4 (7) | 42.02 in/min | 42.02 in/min |
| BoreScallop4 (9) | 65.41 in/min | 65.41 in/min |
| Slots 2D Contour239 (3), 2D Contour206 (3), (7) | 17.38 in/min "Slotting", ap 0.0090 | 17.38 in/min "Slotting", ap 0.0355 |
| 2D Contour206 (4), 2D Contour64, 2D Contour64 (2) | 30.47 in/min "Roughing", ae 0.0033 | **21.55 in/min** "Roughing", ae 0.0138 (entry 18) |

### New entries

| # | Date | Setup > operation | What happened | What was expected | Exact text or numbers | Severity |
|---|---|---|---|---|---|---|
| 18 | 2026-11-15 | Op2EndCap7075 > 2D Contour206 (4), 2D Contour64, 2D Contour64 (2) (single-pass contours, T12) | Entry 10 again, now with an effect. With the stiffer shank ToolWiz picks a wider radial cut for these ops (0.0138 in, was 0.0033) and so a lower feed. The plan now lowers the feed from 30.47 to 21.55 in/min and a CAUTION compares the op's chip load with ToolWiz's "at its recommended engagement", although the op's own radial engagement is unknown (its note says so). A stiffer tool ends up with a slower feed. | No feed change and no chip-load caution where the radial engagement is unknown, or a feed that does not drop when the tool gets stiffer. | Plan: `{"tool_feedCutting": "21.55 in/min", "tool_feedRamp": "17.83 in/min"}`. "[caution] Chip load is more than 40% above ToolWiz's - The operation's programmed chip load is 0.00048 in/tooth (30.47 IPM at 16000 rpm, 4 flutes); ToolWiz gets 0.00034 in/tooth (21.55 IPM at 16000 rpm) at its recommended engagement, a ratio of 1.4x." Before: `limited_by` "C7, C8, C14f"; now "C2, C7, C8". | wrong (errs slow) |
| 19 | 2026-11-15 | All ten T12 ops, for one run | A run taken about when the owner changed the T12 shank had no measured geometry for the T12 ops (`toolpath_length_in`, `channel_width_in`, pocket values all missing). Without it the three slots were treated as side cuts: "Roughing" at 21.55 in/min proposed where "Slotting" gives 17.38, and the "Ramp is off" INFO on the two Op2 slots was gone. Nothing in the output said the measurement was missing. A run 2.5 minutes later had the geometry and the slot advice back. Cause not confirmed; my guess is the toolpaths were being regenerated. | A note (or no feed proposal) when an op's toolpath or measured geometry is missing, since the advice depends on it. | First run: 2D Contour239 (3), 2D Contour206 (3), (7) plan `{"tool_feedCutting": "21.55 in/min", "tool_feedRamp": "17.83 in/min"}`, `operation` "Roughing", ae 0.0138. Second run: `{"tool_feedRamp": "17.83 in/min"}`, "Slotting", ae 0.0625. | wrong (a 24% faster feed proposed on full-width slots with a 1/16 in tool, only while the geometry is missing) |

Not tested, noted only: the add-in's `strategy_label` for Trace1 (2) and (3) (chamfer mill) is "Finishing", before and
after the restart. The advisor does not use that label, but the Speeds & Feeds dialog starts from it.

## Op1EndCap7075 apply on `d16cd7d` with the restarted add-in, 2026-11-15 (shop time)

The owner ran the Setup Advisor on Op1EndCap7075 in Fusion (60%), applied everything and sent the three dialogs. All Op1
toolpaths were generated. Before this run he had also changed two holders in Fusion: T12 from "BT40 - B4C3-0020" to
"Maritool BT30-ER16-60", and T1 in Op1 and Op2 from "Maritool CAT40-ER32-2.35" to "Maritool BT30-ER16-60" (T1 in
PrepEndCapStock still has the CAT40 holder, so tool number 1 now has two definitions, like tool 2 in entry 15).

| Item | Result |
|---|---|
| Plan in the dialog against the server plan | **Pass.** "ToolWiz will change 12 parameter(s) on 8 operation(s)", the same 12 as `/api/setup_advisor` at 0.6: `tool_feedRamp` on 2D Contour7 (7), (11), Adaptive48 (3) (50.20 to 40.79), Adaptive48 (4) (50.20 to 53.45), 2D Contour239 (3) (25.56 to 17.83); Flat33 (4) 74.87 to 44.41 / plunge 24.96 to 33.92 / ramp 63.43 to 50.88; Flat34 51.03 to 22.21; Scallop4 (6) 51.03 to 33.14 / plunge 17.01 to 6.59 / ramp 25.56 to 36.22. |
| Values in the document after the apply | **Pass.** A fresh snapshot has all 12. Fusion's own form for Scallop4 (6) shows 16000 rpm, cutting 841.756 mm/min (33.14 in/min), ramp 919.988 mm/min (36.22), plunge 167.386 mm/min (6.59). |
| Findings after the apply | Op1: 0 STOP (was 1, Flat34), 13 CAUTION, 2 info. The two `chip_load_off` cautions (Flat33 (4), Scallop4 (6)) are gone. The remaining cautions are holder and coating ones. Whole document: 1 STOP (Op2 Flat34, not applied yet), 36 CAUTION, 10 info. The CAUTION count rose from 27 because of the holder change: every T12 op now gets a `holder_type` caution for the ER16 collet chuck (11 more). |
| Entry 7, rounded old values in the result dialog | **Pass** for plain values ("tool_feedRamp: 50.20 in/min -> 40.79 in/min"). A formula is shown as its text, cut short: "tool_feedPlunge: (tool_type=='drill' \|\| tool_type=='reamer' \|\| tool_isDepo... -> 33.92 in/min", where the confirmation dialog says "24.96 in/min (replaces a formula)". As written in `tidy_old_value`; cosmetic. |
| Entry 17, Flat34 plunge feed | **Confirmed.** After the apply `tool_feedPlunge` is 7.403 in/min (the formula followed the new 22.21 cutting feed). The next advisor run proposes `{"tool_feedPlunge": "16.96 in/min"}` for Flat34, the only plan left in Op1. |
| Speeds & Feeds dialog on Scallop4 (6) starts on "Finishing" | Still not checked. The owner opened Fusion's own operation form, not the "ToolWiz Speeds & Feeds" command. |

Still holding values from the faulty first plan in Op1, with no plan offered (as listed under "What re-running the
advisor does not put right"): 2D Contour7 (EndCapCleanUP) 51.03 in/min, 2D Contour239 (4) 51.03 in/min, Trace1 (2)
87.36 in/min / plunge 25.97.

## Speeds & Feeds on Scallop4 (6), `d16cd7d`, 2026-11-15 (shop time)

The owner opened "ToolWiz Speeds & Feeds" on Op1EndCap7075 > FrameEndCapBevelsCounterBoreScallop4 (6) (T6, 1/16 in ball
end mill) and sent the dialog and the result box. I had asked him to cancel without applying; the dialog shows no
numbers before OK, so he pressed OK and the operation was written.

| Item | Result |
|---|---|
| Dialog starts on "Finishing" | **Pass.** Strategy "Finishing", aggressiveness 60, "Keep the operation's own stepdown / stepover" ticked, finish mode "Clean-up". |
| Feed and rpm against the advisor | **Pass.** Result box: "16,000 RPM · 33.1 IPM · 0.0005 IPT", WOC 0.0049 in. The advisor has 33.14 in/min at 16000 rpm for the same op. |
| What the OK wrote (snapshot before and after) | Preset on the op "Aluminum - Roughing" to a new "7075 (T6, T651) - Finishing" (T6 now has 30 presets, was 29); `tool_rampAngle` 2.00 to 2.97 deg; `stepover` "0.125 mm" to "tool_stepover" (0.00492 in, the same value); the preset's `tool_stepdown` 0.25 in (the op saw 0.140625 in before). Feeds and rpm unchanged (33.14 / ramp 36.22 / plunge 6.59 / 16000). The result box also says "Feed Optimization reduced feedrate set to 6.63 IPM"; the snapshot does not carry that parameter, so it is not verified. The toolpath is valid after the command. The other T6 presets changed in the 15th digit only (the tool was rewritten in place); Deburr8 (2) on the same tool kept a valid toolpath. |
| Advisor after the OK | No plan for the op, same two cautions (holder, coating). Whole document unchanged: 1 STOP, 36 CAUTION, 10 info. |

### New entries

| # | Date | Setup > operation | What happened | What was expected | Exact text or numbers | Severity |
|---|---|---|---|---|---|---|
| 20 | 2026-11-15 | Speeds & Feeds dialog, any operation (seen on Op1EndCap7075 > Scallop4 (6)) | Reported by the owner: the dialog never shows a suggested feed that he then accepts. He picks the options, presses OK, and the changes are made; the numbers appear only in the result box afterwards. The code agrees: `run_autoset` calculates, then writes the preset and the operation, then shows the report. It asks first only when the result is infeasible or a shared preset would be replaced. | The calculated rpm, feed and the list of changes shown first, with OK to apply and Cancel to leave the operation alone, as the Setup Advisor does ("ToolWiz will change 12 parameter(s) on 8 operation(s)"). | Owner: "you never see a suggested feed rate that is then accepted. You just select it and hit okay and then it makes the changes." This OK added a preset to T6, relinked the op to it, changed the ramp angle and, by the report, the Feed Optimization reduced feed. | design gap (owner's request; writes with no preview) |
| 21 | 2026-11-15 | Speeds & Feeds dialog, T6 | The dialog preselects "AlTiN (Black)" as the tool coating. The advisor says of the same tool that the coating is unknown ("ti coated") and that it applied no coating factor and did not guess. The dialog falls back to AlTiN when no coating is detected (`initial_geo.get("coating", "AlTiN")`), and sends it to the calculation. | The same answer in both places: unknown, or a blank choice the owner has to make. | Advisor: "Tool Coating Unknown or Ambiguous — Flagged (Not Guessed)". Dialog: Tool Coating "AlTiN (Black)". No effect on this feed (33.1 against 33.14, the spindle is at its 16000 rpm limit). | wrong (a guessed coating; no effect seen here) |

Noted only, not judged:

- In "Clean-up" mode the dialog still shows "Target surface finish (Ra) 0.81 um" and "Wall tolerance 0.0051 mm", but the
  result uses clean-up's own targets ("Predicted Ra about 24 uin (target 63), wall error 0.00069" (tolerance 0.0010")").
  `finish_fields` sends the Ra only in "Surface finish" mode and the tolerance only in "Accuracy" mode.
- The engagement for this ball-mill scallop pass is "ADOC 0.2500 in, RDOC 0.0049 in" in the dialog and `ap_in` 0.25 in
  the advisor (before and after this OK), which is the flute length, 4 x D; `limited_by` includes the flute length. The
  wall-error and thin-wall checks are worked at that depth.
- The result box has a "Plunge feed" check that speaks of "micro adaptive operations" on this scallop op.

### Owner's decision on entry 20, 2026-11-15: add the preview now

The owner asked for entry 20 to be fixed now, as an exception to the field-test pause. His words: "I think a preview
would be great if it shows before and after results! Go ahead and add it." The pause still holds for everything else.

What he asked for, and what the shop PC saw this command write:

- Before anything is written, the Speeds & Feeds command shows each value it will change with its current value and its
  new value (before and after), and offers OK to apply or Cancel. Cancel leaves the operation, the tool and its presets
  untouched.
- The list should cover everything the OK writes, not only rpm and feed. On Scallop4 (6) that was: the preset (a new
  "7075 (T6, T651) - Finishing" added to the tool and linked in place of "Aluminum - Roughing"), `tool_rampAngle`
  2.00 to 2.97 deg, `stepover` "0.125 mm" to "tool_stepover", and by the report the Feed Optimization reduced feed
  (6.63 IPM). `run_autoset` also writes ramp, plunge and transition feeds, stepdown, fine stepdown and the helical
  ramp diameter on other operations.
- Values that do not change are best said so in one line ("rpm and feeds already match"), as the advisor does.

The shop PC will re-check on live Fusion once it is pushed: the preview on Scallop4 (6) and on one roughing op, Cancel
writing nothing (snapshot before and after), and OK writing exactly the listed values.

## Cloud session, 2026-11-15: Speeds & Feeds preview (entry 20). THE ADD-IN CHANGED: reinstall and restart it

After the calculation and before any write, the command shows one box: first line "QUESTION: apply these ToolWiz values
to <operation>? OK writes them; Cancel changes nothing.", then ToolWiz's result, "Will change (N):" with old -> new per
value (preset link, rpm, the feeds, ramp angle, stepdown, stepover, Passes-tab switches, reduced feedrate, fine stepdown,
helical ramp diameter, the operation's own rampAngle link, stock to leave when ticked), then "Already at ToolWiz's
value, not changed (M): ...". Only OK writes. Tests: `tests/test_addin_autoset_preview.py`.

Not changed: what the command writes. It still raises a ramp angle (2.00 -> 2.97 deg on Scallop4 (6)); the preview now
shows it. Whether it should stop doing that is with the owner.

Re-check for the shop PC: the preview on Scallop4 (6) and on one roughing op; Cancel writes nothing (snapshot before and
after, preset count on the tool unchanged); OK writes exactly the listed values. Please also note any value the command
writes that the preview did not list.

Also in this push: `docs/SETUP_ADVISOR.md`, last section, answers the owner's question whether the advisor and the dialog
give the same results (a table of where they agree and differ).

## Cloud session, 2026-11-15 (third round): chamfers and scallops. THE ADD-IN CHANGED: reinstall and restart it

Owner: "the chamfer mill speeds and feeds that I got from GWizard and Tool Wiz previously worked fine for chamfers", "the
app for tool wiz seemed to give the correct info for profiling/scallop work", "these things should be working. Fix them."

- **Chamfer mills** (2D Chamfer, Trace, 2D Contour): both the Speeds & Feeds dialog and the advisor use the web
  calculator's "Chamfering". Advisor kind `chamfer`; plan = rpm, feed, ramp feed, plunge feed only. The dialog has a new
  "Chamfering" strategy, starts a chamfer mill on it, writes no stepdown / stepover / ramp angle, and always sends the
  standard grade. 1/4 in 4-flute chamfer mill, 7075, 60 %: 10171 rpm, 120.77 in/min (0.0030 in/tooth: the chip load of
  Trace1's original 146.70 at 12224), plunge 43.12, ramp 64.69.
- **Scallop-type ops** (scallop, parallel, morphed, ramp, flow, pencil, spiral, radial, steep and shallow, blend, project):
  both tools use "3D Contouring / Scallop Finishing". THIS REVERSES the earlier change of the same day (dialog on
  "Finishing"). 1/16 in ball, 7075, 60 %, stepover 0.0049: 88.55 in/min at 16000 (was 33.14), plunge 16.96, ramp 25.44.
- **Trace with an end mill** is a finishing pass in the advisor (as in the dialog).
- **Open, for the owner:** the dialog's Tool Performance Grade defaults to HP, which raises every v1 result about 1.44x
  over the advisor's (Flat 22.2 -> 32.0, Scallop 88.5 -> 127.5). See docs/SETUP_ADVISOR.md, "Dialog and advisor".

Re-check for the shop PC (read-only first): advisor on Trace1 (2), (3) and the scallop ops: kind, operation, plan;
Speeds & Feeds on Trace1 (2) starts on "Chamfering" and on Scallop4 (6) on "3D Contouring / Scallop Finishing"; note
the grade the dialog shows and its result next to the advisor's. Do not apply the scallop or chamfer values until the
owner has seen them: they are much higher than what is in the document now.
