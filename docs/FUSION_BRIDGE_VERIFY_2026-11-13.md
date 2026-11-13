# Fusion bridge fixes: shop PC verification and new findings (2026-11-13)

Follow-up to [FUSION_BRIDGE_LOCAL_TEST_2026-11-13.md](FUSION_BRIDGE_LOCAL_TEST_2026-11-13.md). This verifies `9f0eeaf` on the shop
PC (Windows 11, Python 3.14.2) against live Fusion. The add-in was reinstalled with `install_addin.py` and restarted in Fusion,
and the server was restarted. Document: "EndCapOnlyManufacture (~recovered)", 45 ops.

## Verified

| Check | Result |
|---|---|
| (a) second `python app.py` exits | **Pass.** It exits with code 1 after 1 s: "ToolWiz is already running on http://127.0.0.1:5000 (…)". This also happened for real: Antigravity relaunches `py app.py` (via `powershell -Command "… py app.py"` under its language_server) whenever the server stops. Its copy won the port, and mine exited cleanly. |
| (b) `addin_polling` with no snapshot | **Pass.** `addin_polling: true`, `addin_last_poll_age_s: 0.2`, `snapshot_present: false` right after the restart. |
| (c) labels | **Pass for probe, chamfer, engrave and deburr:** Probe WCS* → "Probing (no cutting)"; 2D Chamfer1 → "Chamfer / Deburr"; Engrave17/12 → "Engraving"; Deburr8/9 → "Chamfer / Deburr". None is_roughing, and the advisor reported "2D Chamfer1 (chamfer2d) - no findings". **T7 drill: new bug, see 1.** T8 tap ops are still "Tapping (Form / Roll)" (correct). |
| (d) real client on `/api/mcp` | **Partly.** No `claude` CLI on this PC. A replay of the Claude Code handshake (Accept `application/json, text/event-stream`, client protocolVersion 2025-06-18) gets: initialize 200 JSON with server protocolVersion 2024-11-05; `notifications/initialized` 202; GET 405; tools/list 21 tools. A real client session is still to do. |

## New findings

### 1. T7 drill ops are now labeled "Reaming"

`Op1EndCap7075 > Drill4 (5)` and `Op2EndCap7075 > Drill33 (2)`: Fusion strategy `drill`, tool type `drill`, kind `drill`,
description "1.45mm carbide drill for M1.6 form tap". The tap branch is now correctly skipped (drill_like), but the
next test in `infer_strategy_for_op()` (~3430) returns 'Reaming':

```
if kind == 'reamer' or 'ream' in desc_low or 'ream' in op_strat or 'ream' in op_name or 'ream' in cycle_expr:
```

The description, op name and strategy don't contain "ream", and kind is `drill`. So it must be `cycle_expr`, the expression
of the op's `cycleType` parameter. That parameter isn't in the snapshot, so I couldn't read it. Either the Fusion cycle
really is a reaming cycle (then the label is fine, but say so), or a cycle expression contains "ream" for another reason.
Expected: "Drilling". Please include `cycleType` in the snapshot op entry (or in `inspect_operation`) so this can be
checked, and add a test with this tool and op.

### 2. Setup Advisor apply: 31 of 36 "changes" write the value already there

The owner applied the advisor's recommendations on PrepEndCapStock (all boxes pre-checked). The confirmation listed "36
parameter(s) on 5 operation(s)". The result dialog reported 33 applied and 2 skipped, but only two values changed:
- Face1 `tool_feedCutting` 535.29 → 140.77 in/min (the STOP finding)
- 3D Adaptive Roughing2 (2) `tool_feedCutting` 65.74 → 66.64 in/min

Everything else was `x -> x` (stepdowns, stock, plunge, ramp, ramp angle, rpm). This buries the real changes in both
dialogs and in the audit log, and each no-op is still a Fusion write. **Suggested fix:** drop a parameter from the apply plan
when the new expression evaluates equal (within display rounding) to the current one. Show "no change" counts separately.
If an op has nothing left to change, leave it out.

### 3. Two recommendations per op, both pre-checked, conflicting

Each op gets "[INFO] …: ToolWiz recommended engagement and cutting data" and "[INFO] …: ToolWiz cutting data for the
current stepdown/stepover". Both are checked by default, and both set the feed with slightly different values. The
confirmation then shows "Conflicting recommendations (the later one wins)":
3D Adaptive Roughing2 131.66 vs 132.02; (2) 66.56 vs 66.64; 2D Contour2 47.74 vs 47.78 in/min.
**Suggested fix:** make the two mutually exclusive per op (radio, or check only one by default, probably "for the current
stepdown/stepover"). Don't let both reach the apply plan.

### 4. Recommendations for parameters the op doesn't have or has disabled

- 2D Contour2: `stepover: ? -> 0.02722 in`, then skipped: "operation has no such parameter". The advisor recommended a
  stepover for a 2D contour (the "?" shows it couldn't read a current value either).
- 2D Contour1: `maximumStepdown: tool_stepdown -> 0.25000 in`, then skipped: "parameter is disabled on this operation".
  The add-in skipped both correctly, but the advisor shouldn't propose them. Build the apply plan only from parameters that
  exist and are enabled on the op. This information is available when the snapshot is taken.

### 5. Contour engagement read as 100 % of diameter

2D Contour1 (1/4 4-flute): "[CAUTION] 4-Flute Tool in Aluminum with High Engagement … At WOC = 0.2500" (100% D)". A 2D
contour's radial engagement is the stock it removes per pass, not the tool diameter. It looks like the advisor falls back
to WOC = D when the contour has no stepover. Please check `setup_advisor`'s WOC source for contour2d. The same caution on 2D
Contour2 says 0.0272" (22 % D), which matches the stepover it tried to apply in 4.

### 6. "Uncoated" flagged as an unknown coating

Every op shows "[CAUTION] Tool Coating Unknown or Ambiguous – … unspecified or generic (Uncoated)". The recommendation
itself lists "Uncoated" as a valid exact coating. If the tool library says Uncoated explicitly, treat it as known
(INFO at most). If "Uncoated" is just the default for "nothing set", the snapshot should tell the two apart.

### Not a code issue (for the owner)

2D Contour2's holder is "Maritool CAT40-ER32-2.35", while the probe ops use a BT30 holder. If the machine is BT30, the
library holder for that tool is wrong, and the runout CAUTION based on it may not apply.

## Tests on this PC

Pulled through `457cd9f`, which has only test and doc changes, so no restart was needed. Per the agreed division of
work, I'll run only the Windows / live-Fusion checks here.
