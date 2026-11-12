# ToolWiz Engine

ToolWiz is a speeds-and-feeds engine, CAM advisor and tool-library manager for a Brother Speedio S500X2
(BT30, 16,000 rpm). It runs as a local web app and a Fusion 360 add-in, and both use the same server and
the same numbers.

## What it does

- **Speeds and feeds from physics, checked against vendors.** The default cutting model (v2) computes
  per-flute chip loads with runout, cutting forces, tool deflection and bending stress on the real tool
  profile, spindle power, and tool life. It picks the cut with the highest material removal that passes
  every limit and stays inside the vendors' published depth and width envelope. The vendor guardrail is
  **brand first**: give the tool's brand (the `brand` field, a Brand box in the web form, or the Fusion tool's
  vendor) and ToolWiz uses that vendor's own charts; with no brand, or a brand that has no charts, it uses the
  more conservative Helical HEM / Harvey + Helical charts, else the cross-vendor consensus. 50% aggressiveness is
  the middle of that chart's published range, 0% its bottom, 100% its top; physics limits cap every value. HEM
  (adaptive) and traditional roughing (pockets, roughing contours) use separate charts. Every result says which in
  `vendor_basis` (shown as "Vendor basis: ..." under the result).
  3,423 cited vendor rows (Harvey, Helical, OSG, Sandvik, Seco, Kennametal, Emuge, Garr, Kyocera SGS,
  YG-1) validate it; see `docs/V3_EVALUATION.md`. Titan USA micro-tool rows are staged in
  `tests/benchmarks/v2_staged/` and not yet used.
- **Micro tools.** Runout is modelled per flute: results say how many flutes actually cut and what runout
  would bring all of them in, and recommend the holder class (ER, ER-UP, SK, hydraulic, shrink fit,
  powRgrip, micro chuck) and, when the 16k spindle is too slow, a spindle speeder.
- **T-slot and keyseat cutters**, including staggered-tooth cutters that cut up and down in Z, validated
  against 437 Harvey and Ingersoll rows.
- **Roughing and finishing objectives.** Roughing defaults to maximum removal. Finishing has three modes:
  clean-up, surface finish (target Ra) and accuracy (wall tolerance). Every roughing result recommends the
  radial and axial stock to leave for a true-to-size finish pass.
- **Strategy planner.** Compares contour slotting with tabs, a smaller tool, and adaptive clearing, or
  T-slot cutters, on cycle time and tool wear per part, and gives the Fusion settings.
- **Setup advisor.** Checks every operation of a Fusion setup against ToolWiz and suggests better
  strategies. An optional LLM explains the findings; any number it writes that ToolWiz did not compute is
  rejected.
- **Tool libraries.** Merge libraries from documents, hub, cloud and local; build preset libraries per
  material set (for example non-ferrous, and steels and exotics); audit libraries for unsafe presets.
- **Tool recommendations** for specific vendor series when the vendor data shows a large gain.

## Install and run

```bash
pip install -r requirements.txt
```

```bash
python app.py
```

Open http://127.0.0.1:5000/. To install the Fusion 360 add-in:

```bash
python install_addin.py
```

Then restart Fusion and enable ToolWizFusionAddin (Utilities > Add-Ins). The add-in needs the server running.

## Documentation

| Topic | File |
|---|---|
| Fusion add-in commands and workflow | `docs/ADDIN_USER_GUIDE.md` |
| Strategy planner (tab milling vs adaptive, T-slot cutters) | `docs/STRATEGY_PLANNER.md` |
| Slot roughing decision study: high-feed vs square / bull-nose slotting vs HEM (Ti, 17-4, 6061; 1/8" and 1/16") | `docs/SLOT_ROUGHING_STUDY.md` |
| Setup advisor, LLM guard and bridge contract | `docs/SETUP_ADVISOR.md` |
| Tool recommender: "is another tool much faster?" (library, other brands, flute counts, larger tools) | `docs/TOOL_RECOMMENDER.md` |
| Tool libraries, master library builder, API | `docs/TOOL_LIBRARY_NOTES.md` |
| Audit of the owner's titanium library | `docs/SHOP_LIBRARY_AUDIT.md` |
| Evaluation: vendor conformance, stability, timings | `docs/V3_EVALUATION.md` |
| Design decisions and work packages | `docs/V3_IMPLEMENTATION_PLAN.md`, `docs/REVIEW_AND_FIX_PLAN.md` |
| v2 physics model | `docs/PHYSICS_MODEL_DESIGN.md`, `docs/research/` |

## Tests

```bash
python -m pytest -q
```

The suite pins the legacy v1 model for older tests (`tests/conftest.py`); v2 tests select it explicitly.
The vendor conformance test (`tests/test_vendor_conformance.py`) takes a few minutes; set
`TOOLWIZ_FULL_CONFORMANCE=1` to run every row instead of the stratified sample.

## API security

The server binds to 127.0.0.1. Every state-changing request under `/api/` must send a non-empty
`X-ToolWiz-Client` header (the web page sends `web`, the add-in `fusion-addin`); an `Origin` header, if
present, must be the local server.

```bash
curl -X POST http://127.0.0.1:5000/api/calculate -H "Content-Type: application/json" -H "X-ToolWiz-Client: curl" -d '{"family":"Steel - Tool (H13)","diameter":0.25}'
```

## Machine profile

`machines/speedio_s500x2.json` describes the spindle, power curve and holder stiffness. The holder
stiffness is provisional until measured; replace it with measured values for better deflection results.
Enter your measured runout (TIR at the tool tip) per tool: results for tools under 1/8" depend on it. With no runout in the
request the engine assumes 0.0001" for tools of 1/8" and below and 0.0002" above, or the class of the Fusion tool's holder when
its description names one (SK/SX/SKC collet chucks, hydraulic, shrink fit, powRgrip, micro chucks 0.0001"; ER-UP 0.0002";
standard ER 0.0004"; Weldon 0.0012"). The API reports `runout_in` and `runout_source` ("request", "holder: <class>" or
"default by diameter"); an explicit runout always wins.

## Main modules

| Module | Role |
|---|---|
| `pipeline.py` | One calculation pipeline used by every endpoint |
| `physics_v2/` | v2 physics model and optimizer |
| `v2_bridge.py` | Connects the pipeline to v2; model selection (default v2) |
| `gwizard_physics.py` | Legacy v1 tables and rules; used for tool types v2 does not cover |
| `tslot_model.py` | T-slot / keyseat cutter model |
| `finish_modes.py` | Finishing objectives (clean-up, surface, accuracy) |
| `strategy_planner.py`, `strategy_tslot.py` | Strategy comparison |
| `setup_advisor.py`, `toolwiz_common/numeric_guard.py` | Setup advisor and LLM number guard |
| `toolwiz_common/tooling_advisor.py` | Holder and tool-series advice |
| `master_library.py`, `library_audit.py`, `tool_merger.py` | Tool libraries |
| `mcp_server.py`, `fusion_bridge.py` | MCP server and Fusion bridge |
| `app.py`, `routes_*.py` | Flask endpoints |
| `templates/`, `static/` | Web app |
| `ToolWizFusionAddin/` | Fusion 360 add-in |
