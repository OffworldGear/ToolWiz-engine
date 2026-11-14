# Fusion bridge fixes, round 7 (VERIFY5 findings 1 to 3): shop PC verification (2026-11-14)

Verifies `78b0ded` against live Fusion on the shop PC. Server-side change only: pulled, server restarted
(`/api/version`: `78b0ded`), add-in not reinstalled, fresh setup summary pushed (45 ops, 3 setups, same document).
Follow-up to [FUSION_BRIDGE_VERIFY5_2026-11-14.md](FUSION_BRIDGE_VERIFY5_2026-11-14.md).

Advisor run: `POST /api/setup_advisor {"from_bridge": true, "family": "Aluminum - Wrought (6061)", "alloy": "7075"}`,
aggressiveness 0.5. Read-only against Fusion. Summary: 8 STOP, 46 CAUTION (unchanged), **14 info** (was 12).

## Windows tests

`tests/test_verify5_report_2026_11_14.py`, `test_verify4_…`, `test_verify3_…`, `test_verify2_…`, `test_v2_ramp.py`,
`test_addin_twlogic.py`, `test_mcp_http.py`: **148 passed**.

## Results

| # | Result |
|---|---|
| 1 Chart sentence names the limit | **Pass.** "… 3.0 to 10.0 deg, limit 6.5 deg at 50% (0 % bottom, 50 % middle 6.5, 100 % top; the angle used is at or just under the limit). Based on 3 Helical chart rows for 5-flute tools, …" on 3D Adaptive Roughing2, 2D Contour1, Trace1 (2)/(3); `ramp_angle_deg` 6.44 there, unchanged. |
| 2a Singular | **Pass.** "Based on 1 Helical chart row for 5-flute tools, …" on all 25 ops with a single-row basis. |
| 2b No repeated title | **Pass.** Title "Ramp is off on this operation", detail "Turning on Ramp in Fusion would ease the entry at each depth; ToolWiz's ramp angle for this tool would be 3.0 deg." |
| 2c No double statement | **Pass.** The three ops with the INFO no longer carry "Not proposed: ramp angle, because this operation does not ramp." 2D Contour1 (ramp off, single depth, no INFO) still does, as intended. |
| 3 `ramp_off` on slots | **Pass.** New on Op2EndCap7075 > 2D Contour206 (3) and 2D Contour206 (7), with 3.0 deg (`toolwiz_ramp_angle_deg` 2.97). Still on PrepEndCapStock > 2D Contour2. Three in total, no others. |

Difference from round 6: the two new INFOs, the reworded one, and the note changes above. **No plan changed.** No plan
in the document contains `tool_rampAngle`, `tool_feedRamp`, `doRamp` or `rampType`. The slots' plans are
`tool_feedCutting`, `tool_feedPlunge` and `tool_spindleSpeed` only.

## One cosmetic point

On the two slots, multiple depths are off, so "would ease the entry **at each depth**" reads slightly off: there is one
depth. "would ease the entry" is enough there.

## Still open (unchanged)

- For the owner: whether `tool_feedRamp` should still be proposed when the angle is kept inside the tolerance.
- The Setup Advisor dialog and the Speeds & Feeds result dialog with these fixes: the owner's to open.
- A real Claude Code client on `/api/mcp`; a peck or deep-drill op for the "Peck Drilling (Deep Hole)" label.
