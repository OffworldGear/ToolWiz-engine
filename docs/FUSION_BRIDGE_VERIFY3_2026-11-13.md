# Fusion bridge fixes, rounds 3 and 4 plus the ramp angle fix: shop PC verification (2026-11-13)

Verifies `64ab2c3` (round 3 `5e36c12`, round 4 `c2a7907`, ramp angle `c7b1ee2`) against live Fusion on the shop PC.
Before checking, I reinstalled the add-in with `install_addin.py`, the owner restarted it in Fusion, and I started the
server (`/api/version`: `64ab2c3`, `dirty` only because of the owner's uncommitted `data/working_library.json`).
Follow-up to [FUSION_BRIDGE_VERIFY2_2026-11-13.md](FUSION_BRIDGE_VERIFY2_2026-11-13.md).

Advisor runs: `POST /api/setup_advisor {"from_bridge": true, "family": "Aluminum - Wrought (6061)", "alloy": "7075"}`
(aggressiveness 0.5, machine max 16000 rpm). The owner also ran the Setup Advisor dialog on PrepEndCapStock and
**applied** its four pre-ticked recommendations (their choice). So PrepEndCapStock's ramp angles and 2D Contour1's feed
in the snapshot below are the values after that apply.

## Windows tests

`tests/test_v2_ramp.py`, `test_verify2_report_2026_11_13.py`, `test_verify3_report_2026_11_13.py`,
`test_addin_twlogic.py`, `test_mcp_http.py`: **124 passed**.

## Round 3

| # | Result |
|---|---|
| 1 Cycle type | **Pass.** Drill4 (5) `cycle_type: "drilling"` → "Drilling"; Drill33 (2) `"drilling"` → "Drilling"; taps Drill27 (4) and Drill34 (2) `"tapping"` → "Tapping (Form / Roll)". `cycle_type_expr` holds the default formula (the one with `'reaming'` in it), as expected. **Not tested:** this document has no peck or deep-drill op, so "Peck Drilling (Deep Hole)" couldn't be checked. |
| 2 2D Contour1 | **Pass.** Kind `contour`, note "measured channel 0.2429 in wide and 0.0177 in long is not treated as a slot", no High Engagement caution. |
| 3 2D Contour2 | **Pass.** No High Engagement caution. |
| 4 Snapshot coating | **Pass.** `coating: null`, `coating_source: "not set"` on every op whose tool doesn't name a coating. `"AlTiN"` / `"tool"` only on the three ops whose tool descriptions say "altin"/"AlTiN" (2D Chamfer1, Adaptive48 (4), Trace1 (2)/(3)). The advisor's caution now reads "The tool library says this cutter is coated ("ti coated") but not which coating…" and points to the user guide section. |

## Round 4

| # | Result |
|---|---|
| 5 Evaluated current values in the dialog | **Pass for what was seen.** The owner's apply result: `tool_rampAngle: 18.2 deg -> 7.1 deg`, `18.6 deg -> 3.0 deg`, `tool_feedCutting: 75.98 in/min -> 87.36 in/min`. So `tool_rampAngle` and feeds evaluate correctly in the dialog. Not seen: an rpm line, a length line and the "(replaces the link …)" note, because PrepEndCapStock's plans had none of those. |
| 6 Owner's stock and ramp angle kept | **Fails for the ramp angle, see A. Stock: see B.** |
| 7 Whole-word coating | **Pass in practice.** No tool in this library has "cutting" or "fluting" in its description. Coated tools are found only where the description names the coating. |
| 8 User guide | The coating caution points to "Recording coating and tool material". |

## Ramp angle fix (`c7b1ee2`), advisor values (aggressiveness 50 %)

| Tool | D | Flute length | FL / D | Flutes | Ramp angle |
|---|---|---|---|---|---|
| T2 "1/4\" Flat Endmill" | 0.250" | 0.4375" | 1.75 | 4 | **6.44 deg** (3D Adaptive Roughing2, 2D Contour1) |
| T1 "1/8\" Flat Endmill" | 0.125" | 0.500" | 4.0 | 4 | **2.97 deg** (bottom of range, ≥ 3 x D) |
| T12 "1/16\" Flat Endmill" (micro) | 0.0625" | 0.1875" | 3.0 | 4 | **2.97 deg** (bottom of range, ≥ 3 x D) |
| "Chamfer 4fl 90deg altin" (Trace1) | 0.250" | 0.250" | 1.0 | 4 | 6.44 deg |

The owner's dialog (the add-in's own aggressiveness setting, apparently 60 %) gave T2 **7.1 deg** and T1 **3.0 deg**, which
matches the expected 7.1 deg at 60 %. All are far below the old 18.2 to 18.8 deg. I didn't run the Speeds & Feeds
auto-setter: it writes into presets and ops. The advisor result has no "Ramp angle from the … chart" sentence (no match
in the JSON), so if that sentence should also reach the advisor's findings or notes, it doesn't yet.

## New findings

### A. The snapshot reads the ramp angle as radians, but Fusion gives degrees (owner's 2 deg becomes 114.59 deg)

`ToolWizFusionAddin.py` ~5826, in the snapshot op builder:

```python
ramp_deg = None      # current ramp angle: Fusion's evaluated value is in radians
...
ramp_deg = math.degrees(_rv)
```

Live values are 57.3 x too large: every op with the owner's 2 deg shows `tool_rampAngle: "114.59 deg"` (2 x 57.2958). After
the apply, 3D Adaptive Roughing2 shows `"406.80 deg"` (7.1 x 57.3) and 2D Chamfer1 shows `"1042.78 deg"` (18.2). The value
Fusion returns for `tool_rampAngle` is already in degrees. The add-in's own preset code says so (~1761, "plain degrees, as
Fusion stores it"), and the tool library presets carry `"ramp-angle": 2`. The dialog's display path gets this right
(`18.2 deg -> 7.1 deg`).

**Effect:** the round-4 rule "propose a ramp angle only when ToolWiz's is lower" compares against 114.59 deg. So every 2 deg
op in Op1EndCap7075 / Op2EndCap7075 gets a proposal that **raises** the owner's angle: 2D Contour7 (EndCapOutline) (7),
(8), (9) and (11), Adaptive48 (3)/(4), Adaptive49 (2), 2D Contour239 (3), 2D Contour206 (3)/(4)/(7), 2D Contour64 (2) →
3.0 deg; Trace1 (2)/(3) → 6.4 deg. The expected note "Ramp angle kept at your 2.0 deg …" never appears.

**Suggested fix:** use the value as degrees (drop `math.degrees`), and fix the comment. Please also check `twlogic.display_current`
and `current_param_values` stay consistent: the dialog evidently treats it as degrees already. Add a test with a
`tool_rampAngle` value of 2 that must become "2.00 deg" and must block a 3.0 deg proposal.

### B. Stock to leave is still proposed on 2D Contour7 (EndCapOutline) (7)

Expected (round 4): no stock line, and the note "Stock to leave kept at your 0.0039 in …". Actual: the plan has
`stockToLeave: "0.00250 in"` and `verticalStockToLeave: "0.00197 in"`, and there's no "kept" note. The snapshot params
for this op have **no** `stockToLeave`, and `current.stock_radial_in` / `stock_axial_in` are `null`. That's the
`stock.get("active")` path, so the op's stock-to-leave checkbox is most likely **off**: the dialog earlier showed the
parameter itself as `0.1mm`. With stock unset, the advisor still proposes stock on a `contour` kind op, while the rule
says roughing only. The same happens on 2D Contour7 (EndCapOutline) (9)/(11), 2D Contour206 (4) and 2D Contour64 / (2),
all kind `contour`, and `verticalStockToLeave` alone on 2D Contour7 (EndCapOutline) (8). (Trace1 (2)/(3) also get stock,
but they're kind `rough`, so that follows the rule.)

**Suggested fix:** don't propose stock to leave on a non-roughing op at all. When the checkbox is off, say "stock to
leave is off on this operation" and don't propose it (writing `stockToLeave` does nothing unless the box is ticked).
The owner can confirm the checkbox state.

### C. "Kept" notes that change nothing (minor)

3D Adaptive Roughing2: "Stock to leave kept at your 0.0050 in; ToolWiz would leave 0.0050 in." and the same for vertical
stock 0.0025 / 0.0025. When the values are equal, leave the note out: the "N parameter(s) already match" count covers it.

### D. 4-flute "High Engagement" caution at 10 % of diameter (question)

3D Adaptive Roughing2 (2), T1 1/8" 4FL: "[CAUTION] 4-Flute Tool in Aluminum with High Engagement … At WOC = 0.0121"
(10% D)". The same caution appears on most finishing ops in Op1/Op2 (Flat33, Flat34, the scallops, 2D Contour239 (4)).
10 % radial engagement isn't high. If this caution is really about micro tools and chip packing, the title and threshold
should say so. Otherwise it fires on almost every 4-flute op in aluminum, which buries it.

### E. Ramp angle proposed on ops that never ramp (from the owner)

The owner: "2D Contour 2 is the only thing that could benefit from a ramp. Chamfer doesn't need a ramp." Today the advisor
puts `tool_rampAngle` (and `tool_feedRamp`) into the plan of nearly every cutting op: contours that enter from outside
the stock, Trace (a chamfer mill), and 2D Chamfer1's preset. In PrepEndCapStock only 2D Contour2 ramps into material.
**Suggested fix:** propose a ramp angle only when the op actually ramps. That means Fusion's ramp / helical entry is on
(e.g. `rampType` / `doRamp`-style parameters, or adaptive / pocket ops whose entry is a ramp or helix), not a contour or
chamfer entering from outside with a lead-in. Never propose one for chamfer, trace, engrave or deburr kinds. If the snapshot
can't tell, read the op's entry parameters into it first. When it isn't proposed, add a note like "Not proposed: ramp angle,
because this operation does not ramp."

## Still not done

- A real Claude Code client on `/api/mcp`: needs a new session on this PC.
- A peck or deep-drill op to check the "Peck Drilling (Deep Hole)" label: none in this document.

Read-only against Fusion except the owner's own apply on PrepEndCapStock.
