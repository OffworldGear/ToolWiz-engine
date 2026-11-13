# Fusion bridge fixes, round 2: shop PC verification (2026-11-13)

Verifies `34cddc3` against live Fusion on the shop PC (Windows 11, Python 3.14.2). Before checking, the add-in was
reinstalled and restarted in Fusion, and the server was restarted. Follow-up to
[FUSION_BRIDGE_VERIFY_2026-11-13.md](FUSION_BRIDGE_VERIFY_2026-11-13.md).

The advisor run here used `POST /api/setup_advisor {"from_bridge": true, "family": "Aluminum - Wrought (6061)"}`. The
material is a stand-in: the setups are 7075, and I didn't find the 7075 entry. So only labels, notes and plan contents
are judged below, not the numbers.

## Windows tests

All pass:
- `tests/test_vendor_conformance.py` + `tests/test_v2_stability.py`: **138 passed, 12 xfailed** (4 min)
- `test_runout_defaults.py`, `test_advisor_chat.py::test_keys_are_write_only_over_the_api`,
  `test_verify_report_2026_11_13.py`, `test_local_bridge_report_2026_11_13.py`, `test_mcp_http.py`, `test_addin_twlogic.py`: **75 passed**

## The six findings

| # | Result |
|---|---|
| 1 Drill labeled Reaming | **Fixed.** Drill4 (5) and Drill33 (2) are now "Drilling", and the T8 taps are still "Tapping (Form / Roll)". The exact `cycle_type` explains the old match: it's Fusion's default *formula*, which contains the word `'reaming'` as a branch. Drill4 (5): `tool_isMill ? ('drilling') : ((tool_type == 'tap right hand' \|\| tool_type == 'tap left hand') ? 'tapping' : ((tool_type == 'reamer')?('reaming'):'drilling'))`. Drill33 (2) has the same with an `isDrillingRefTrimming ? drillingReference.cycleType : …` prefix. Any substring test on `cycle_expr` (`'tap'`, `'ream'`, `'peck'`, `'deep'`, `'chip-breaking'`) can be fooled the same way. Suggest evaluating the parameter's **value** (`p_cyc.value`) instead of its expression. |
| 2 x -> x changes | Plan side looks right: notes say "5 parameter(s) already match ToolWiz's values and are not listed." **Dialog check pending:** the owner has to open the dialog. |
| 3 Conflicting recommendations | Plan side: one `recommended` and one `keep_engagement` plan per op. **Dialog check (pre-tick, mutual exclusion) pending.** |
| 4 Parameters the op lacks | **Fixed.** 2D Contour2: "Not proposed: stepover, because this operation has no stepover…". 2D Contour1: "Not proposed: maximumStepdown, because this operation has no stepdown (multiple depths are off)." Neither appears in its plan. |
| 5 Contour WOC = D | **Not fixed for 2D Contour1.** The op is classified kind **`slot`**, not `contour`, so it still gets "High Engagement … WOC = 0.2500" (100% D)". See A. |
| 6 Coating | Messages now say "(not set)", and the caution appears once per tool. **What the owner's tools have:** nothing explicit. Every cutting tool has Fusion `BMC: "ti coated"` and `GRADE: "Mill Generic"` (drill: BMC `carbide`, GRADE `generic`). Only two descriptions name a coating: "Chamfer 4fl 90deg altin" and "1/8\" Ball Endmill HRC55 AlTiN". See C. |

## New findings

### A. 2D Contour1 is classified as a slot from a channel that's narrower than the tool

`classify_op` turns a contour into `slot` when the measured width is about the tool diameter or less. For 2D Contour1 (1/4"
tool) the geometry reads `channel_width_in 0.2429`, `channel_length_in 0.0177`, `is_slot: false`, plus a pocket of area
5.18 in² and perimeter 10.15 in. A tool can't cut a channel narrower than itself, and 0.018" long isn't a slot. This is a
short gap measured somewhere along an outside profile. Suggest: ignore a measured channel narrower than the tool (or
shorter than about one diameter) when classifying. Also respect `is_slot: false` from the geometry inspector.

### B. "High Engagement" caution fires at 0 % engagement

2D Contour2 (kind `contour`, no stepover, so per fix 5 no at-width run): "[CAUTION] 4-Flute Tool in Aluminum with High
Engagement … At WOC = 0.0000" (0% D)". The 4-flute caution should be skipped when the width is unknown or zero.

### C. The add-in still assumes AlTiN for carbide

`ToolWizFusionAddin.py` ~1669: `detected_coating = "AlTiN" if is_carbide else "Uncoated"`. So every snapshot op above
reports `coating: "AlTiN"`, even though the advisor (correctly) says "not set". The two disagree, and the add-in's own
calculator dialog would use AlTiN. `ti coated` is Fusion's generic "some titanium-based coating" and doesn't tell
TiN / TiCN / TiAlN / AlTiN apart. Suggest: default to unknown (None / "not set"), map `ti coated` to "coated, type
unknown", and keep AlTiN only when the text says so.

### Still not done

- (d) a real Claude Code client on `/api/mcp`: needs a new session on this PC.
- Fixes 2 and 3 in the Fusion dialog: waiting on the owner.
