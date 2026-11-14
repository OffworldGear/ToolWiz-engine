# Fusion bridge fixes, round 5 (findings A to F): shop PC verification (2026-11-14)

Verifies `0220a74` (fix commit `8ad2b0d`) against live Fusion on the shop PC. Before checking, I reinstalled the add-in
with `install_addin.py`, the owner restarted it in Fusion, and I restarted the server (`/api/version`: `0220a74`).
Follow-up to [FUSION_BRIDGE_VERIFY3_2026-11-13.md](FUSION_BRIDGE_VERIFY3_2026-11-13.md).

Advisor run: `POST /api/setup_advisor {"from_bridge": true, "family": "Aluminum - Wrought (6061)", "alloy": "7075"}`,
all three setups, aggressiveness 0.5. Read-only against Fusion. Summary: 8 STOP, **50 CAUTION** (was 65), 11 info.

## Windows tests

`tests/test_verify4_report_2026_11_14.py`, `test_verify3_…`, `test_verify2_…`, `test_v2_ramp.py`,
`test_addin_twlogic.py`, `test_mcp_http.py`: **138 passed**.

## Results

| # | Result |
|---|---|
| A Ramp angle in degrees | **Pass.** Every op with the owner's 2 deg now shows `params.tool_rampAngle: "2.00 deg"` (expression `2.`). PrepEndCapStock shows the values applied yesterday: `"7.10 deg"` (expression `7.1 deg`) and `"3.00 deg"`; 2D Chamfer1 `"18.20 deg"`. No plan raises an angle. Where a ramp is allowed, the note reads "Ramp angle kept at your 2.0 deg; ToolWiz's limit is 3.0 deg." (2D Contour7 (EndCapOutline) (7)/(9)/(11), Adaptive48 (3)/(4), Adaptive49 (2), 2D Contour239 (3)). |
| B Stock to leave | **Pass.** `stock_to_leave_enabled` is `false` on 2D Contour7 (EndCapOutline) (7)/(9)/(11), 2D Contour206 (4), 2D Contour64 / (2) and Trace1 (2)/(3): "Stock to leave is off on this operation (finishing to size): not proposed; ToolWiz would leave 0.0025 in." No stock in their plans. 2D Contour7 (EndCapOutline) (8), 2D Contour1 and 2D Contour2 (enabled): "Stock to leave not proposed: this contour is not clearly a roughing pass; …". |
| C "Kept" notes only when different | **Pass.** 3D Adaptive Roughing2 (0.0050 / 0.0050) has no "kept" note now. The remaining ones differ (0.0059 vs 0.0025). |
| D 4-flute High Engagement | **Pass.** It's left only on Face1 (WOC 0.1562", 50 % D) and the slots 2D Contour239 (3), 2D Contour206 (3)/(7) (100 % D). Gone from all finishing ops and from 3D Adaptive Roughing2 (2) (10 % D). |
| E Ramp only where it matters | **Works as coded. One point differs from the expectation, see 1.** No ramp angle in any edge, probe, hole, finish or trace plan. Contours with ramp on but single depth: "light finishing pass: ramp angle not proposed" (2D Contour7 (8), 2D Contour206 (4), 2D Contour64 / (2)). Contours with ramp off: "Not proposed: ramp angle, because this operation does not ramp." |
| F Chart sentence | **Pass in the advisor notes.** E.g. "Ramp angle from the Helical chart for aluminum (no brand given; conservative default): 3 to 10 deg, 6.5 at 50% (0 % bottom, 50 % middle 6.5, 100 % top). Rows: 3 (5-flute, 2-2.5×D reach; + neighbouring hardness bin)." The Speeds & Feeds dialog wasn't opened (it's the owner's to run). |

### What I couldn't read

The live `.value.value` of `tool_rampAngle`: the snapshot's `ramp.raw` carries expressions only. Indirect evidence from
round 3: the old `math.degrees()` code turned the owner's 2 into 114.59 and 18.2 into 1042.78, so Fusion's evaluated value
is the plain number of degrees (2.0, 18.2). That also explains the dialog: its "18.2 deg" came from the expression or from
the value unconverted.

## The real ramp parameters (for E)

The guessed names work: `doRamp` and `rampType` exist. Dumps from `ramp.raw`:

| Op | `ramp.enabled` | `ramp.type` | `multiple_depths` | Key raw values |
|---|---|---|---|---|
| 2D Contour2 (contour2d) | **false** | profile | true | `doRamp = false`, `rampType = 'profile'`, `alwaysMakeContourRamp = doRamp`, `rampAngle = tool_rampAngle`, `tool_rampAngle = 3.0 deg`, `maximumRampZStepdown = maximumStepdown > 0 ? maximumStepdown : tool_fluteLength` |
| 2D Contour1 (contour2d) | false | profile | false | same shape, `doRamp = false`, `tool_rampAngle = 7.1 deg` |
| 2D Contour7 (EndCapOutline) (7) | true | profile | true | `doRamp = true`, `rampType = 'profile'`, `maximumRampZStepdown = 1mm`, `rampClearanceHeight = .1mm`, `tool_rampAngle = 2.` |
| 3D Adaptive Roughing2 (adaptive) | true | helix | null | `doRamp = true`, `rampType = 'helix'`, `helicalRampDiameter = 0.2500 in`, `rampTaperAngle = 1deg`, `allowHelicalRamps = rampType != 'predrill'`, `tool_rampAngle = 7.1 deg` |
| Flat33 (4) (flat) | true | helix | true | `doRamp = true`, `rampType = 'helix'`, `zigzagRampLength = tool_diameter * 2` |
| 2D Chamfer1 (chamfer2d) | null | null | null | no `doRamp` / `rampType`; only `entry_*` lead-in parameters, plus the tool-level `tool_rampAngle = 18.2 deg`, `tool_rampType = 'helix'` |

Notes: `tool_rampType = 'helix'` is on every op (probes and drills too), so it says nothing about the op. The op-level
`rampAngle` is the link `tool_rampAngle` everywhere seen. `multiple_depths` is `null` on adaptive, scallop, chamfer and
deburr ops.

## Findings

### 1. PrepEndCapStock: 2D Contour2 gets no ramp proposal, because its ramp is switched off in Fusion

Expected: "only 2D Contour2 gets a ramp proposal." Actual:
- **2D Contour2:** `doRamp = false`, so "Not proposed: ramp angle, because this operation does not ramp." Its plan is
  `maximumStepdown` and `tool_feedPlunge` only. That's consistent with the owner's words: it "could benefit from a ramp",
  i.e. it doesn't ramp today. It has multiple depths on, 0.199" stepdowns, and plunges.
- **3D Adaptive Roughing2:** gets `tool_rampAngle: 6.4 deg` (its 7.1 deg was applied yesterday at the dialog's 60 %; the
  advisor here ran at 50 %). It's a helix-entry adaptive, so by the rule it qualifies.
- 3D Adaptive Roughing2 (2): at 3.0 deg already, nothing proposed.

**Suggestion (owner's intent):** when a contour has multiple depths (or otherwise removes real material) and
`doRamp` is false, say so as an INFO: "This contour takes N depths and plunges; turning on Ramp (Linking > Ramp) would
ease the entry. ToolWiz's ramp angle would be 3.0 deg." Don't write `doRamp` from the plan unless the owner asks for
that. Also, should the adaptive's 7.1 → 6.4 deg be proposed at all? It comes only from 60 % vs 50 % aggressiveness.
Consider a tolerance (say 1 deg or 15 %) before proposing a lower angle.

### 2. The chart sentence and the plan disagree by a rounding step (minor)

3D Adaptive Roughing2: the sentence says "6.5 at 50%", while the plan and `ramp_angle_deg` say 6.44 → "6.4 deg". Same
source number, rounded two ways. Also "Rows: 3 (5-flute, …)" for a 4-flute tool may puzzle the owner; a few words on
why 5-flute rows apply would help.

### 3. Two identical plans on one op (minor)

Face1: `keep_engagement` and `recommended` are both `{tool_feedCutting: 125.29 in/min, tool_spindleSpeed: 12529 rpm}`.
2D Contour7 (EndCapCleanUP): both `{49.40 in/min, 16000 rpm}`. When the two plans are equal, show one.

### 4. Stock cautions on a contour the advisor treats as not roughing (question)

2D Contour1 and 2D Contour7 (EndCapOutline) (8): "[CAUTION] Radial stock to leave is below ToolWiz's recommendation"
(0.0020 vs 0.0050 in), next to the note "this contour is not clearly a roughing pass". If it isn't roughing, the stock
caution probably shouldn't fire either. And "ToolWiz would leave 0.0025 in" appears on 2D Contour2, which already leaves
0.0025 in (same value: the note could be dropped, as in C).

## Still not done

- The Speeds & Feeds dialog's "Ramp angle" sentence and the Setup Advisor dialog with these fixes: the owner's to open.
- A real Claude Code client on `/api/mcp`: needs a new session on this PC.
- A peck or deep-drill op for the "Peck Drilling (Deep Hole)" label: none in this document.
