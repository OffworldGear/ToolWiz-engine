# Fusion bridge fixes, round 6 (VERIFY4 findings 1 to 4): shop PC verification (2026-11-14)

Verifies `92b766a` against live Fusion on the shop PC. Server-side change only, so the add-in was not reinstalled; I
pulled, restarted the server (`/api/version`: `92b766a`), and asked the add-in for a fresh setup summary (the restart
clears the bridge snapshot, so `/api/setup_advisor` answers 400 until one is pushed).
Follow-up to [FUSION_BRIDGE_VERIFY4_2026-11-14.md](FUSION_BRIDGE_VERIFY4_2026-11-14.md).

Advisor run: `POST /api/setup_advisor {"from_bridge": true, "family": "Aluminum - Wrought (6061)", "alloy": "7075"}`,
all three setups (45 ops, the same document and ops as round 5), aggressiveness 0.5. Read-only against Fusion.
Summary: 8 STOP, **46 CAUTION** (was 50), 12 info (was 11).

## Windows tests

`tests/test_verify5_report_2026_11_14.py`, `test_verify4_…`, `test_verify3_…`, `test_verify2_…`, `test_v2_ramp.py`,
`test_addin_twlogic.py`, `test_mcp_http.py`: **146 passed**.

## Results

| # | Result |
|---|---|
| 1a `ramp_off` INFO | **Pass.** Exactly one, on PrepEndCapStock > 2D Contour2: "Ramp is off on this operation. Turning on Ramp in Fusion would ease the entry at each depth; ToolWiz's ramp angle for this tool would be 3.0 deg." Recommendation: "Turn on Ramp in Fusion if you want it (ToolWiz does not change this setting)." Its plan is `maximumStepdown` and `tool_feedPlunge` only; no `doRamp`, no ramp angle. It does not appear on any other op. |
| 1b Ramp tolerance | **Pass.** 3D Adaptive Roughing2 (7.1 deg) is no longer offered 6.4 deg: `tool_rampAngle` and `tool_feedRamp` are gone from its plan. No plan in the document contains `tool_rampAngle` now. See note A for a side effect. |
| 2 Chart sentence | **Rows text: pass. Rounding: still differs, see finding 1.** New text: "Based on 3 Helical chart rows for 5-flute tools, the closest published tools with at least as many flutes as this 4-flute tool, 2-2.5×D reach (+ neighbouring hardness bin)." |
| 3 Duplicate plans | **Pass.** Face1 and 2D Contour7 (EndCapCleanUP) list `recommended` only. No op has two equal plans (13 ops have both plans, all different; 17 have one; 15 have none). |
| 4 Stock messages | **Pass.** The four cautions are gone: `stock_radial_low` and `stock_axial_low` on 2D Contour1 and on 2D Contour7 (EndCapOutline) (8). No stock finding is left anywhere in the document. 2D Contour2 has no stock note now. The remaining stock notes all show two different values. |

Difference from round 5, findings: those four cautions gone, the one `ramp_off` INFO new, nothing else changed.
Difference in plans: the four ops named above (3D Adaptive Roughing2, 3D Adaptive Roughing2 (2), Face1,
2D Contour7 (EndCapCleanUP)), nothing else.

## Findings

### 1. The chart sentence and the angle still differ: 6.5 against 6.44 (the cause)

Both numbers, 3D Adaptive Roughing2 and 2D Contour1 (same tool):
- `toolwiz.recommended.ramp_basis`: "… 3.0 to 10.0 deg, **6.5** at 50% (0 % bottom, 50 % middle 6.5, 100 % top) …"
- `toolwiz.recommended.ramp_angle_deg`: **6.44** (shown as 6.4 deg wherever it is formatted to one decimal).

It is not a rounding of one number. The sentence prints the chart limit (`cap_deg`, 6.5). The angle is what
`optimize_ramp` picks under that limit: "within `score_tol` (1 %) of the fastest descent, the smallest angle", refined
by bisection (`physics_v2/ramp.py` ~903 to 928). That lands about 1 % under the cap: 6.44 under 6.5, and 2.97 under 3.0
on the long-reach tools. 2.97 happens to print as 3.0, so only the 6.5 case shows.

The plan no longer shows 6.4 on this document (the tolerance removes it), so the owner sees the pair only if a plan or
the Speeds & Feeds dialog prints the angle next to the sentence. Options: say both in the sentence ("chart limit 6.5
deg; ToolWiz uses 6.4 deg"), or return the cap itself when the pick is within 1 % of it.

### 2. Wording (minor)

- "Based on **1** Helical chart **rows**": singular needed when N is 1 (2D Contour2, 2D Contour7 (EndCapOutline),
  2D Contour239 (3) and the other long-reach tools).
- The `ramp_off` detail starts with its own title ("Ramp is off on this operation" | "Ramp is off on this operation.
  Turning on …"). In a dialog that prints title then detail, the sentence appears twice.
- 2D Contour2 carries both the INFO and the note "Not proposed: ramp angle, because this operation does not ramp."
  Consistent, but they say the same thing twice.

### 3. Question for the owner: slots with ramp off

`ramp_off` is for kind `contour` only. Two ops classed `slot` also have `doRamp = false`:

| Op | Tool D | Channel | Depth (top to bottom) | Multiple depths |
|---|---|---|---|---|
| Op2EndCap7075 > 2D Contour206 (3) | 0.0625 in | 0.0630 in (100 % D) | 0.126 in | off |
| Op2EndCap7075 > 2D Contour206 (7) | 0.0625 in | 0.0630 in (100 % D) | 3.045 in (heights span the stock; the real cut depth isn't in the snapshot) | off |

They get "Not proposed: ramp angle, because this operation does not ramp." and no `ramp_off`. I can't tell from the
snapshot whether the tool enters from open stock or plunges into the slot. Not a defect against the fix as specified;
the owner's statement so far covers PrepEndCapStock only ("2D Contour 2 is the only thing that could benefit from a
ramp"). For reference, the other ramp-off ops: 2D Contour1 (contour, single depth, 0.122 in deep, D 0.25) and
2D Contour239 (4) (finish, single depth): no `ramp_off`, as intended.

## Notes

**A. The ramp feed goes with the angle.** When the angle is inside the tolerance, `tool_feedRamp` is dropped too.
3D Adaptive Roughing2 (2) is at ToolWiz's 3.0 deg already; in round 5 its plan still had `tool_feedRamp: 39.31 in/min`
(the op's preset has 40.79), now it does not. 3D Adaptive Roughing2 keeps 82.29 in/min at 7.1 deg, where ToolWiz would
use 79.45 at 6.44. Small differences; say if the ramp feed should still be proposed when only the angle is kept.

**B. Silent keep.** 3D Adaptive Roughing2 now has no ramp line at all (no "kept" note, no chart sentence). That
matches the code comment ("the owner's angle stays, silently").

## Still not done

- The Setup Advisor dialog and the Speeds & Feeds result dialog with these fixes: the owner's to open. The add-in is
  unchanged since `0220a74`, so the new INFO goes through the existing finding rendering, which I haven't seen.
- A real Claude Code client on `/api/mcp`: needs a new session on this PC.
- A peck or deep-drill op for the "Peck Drilling (Deep Hole)" label: none in this document.
