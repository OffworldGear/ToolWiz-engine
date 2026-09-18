# Changelog

All notable changes to the ToolWiz Engine project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2026-09-18

### Fixed
- **Plunge Feed Rate Zero-Value Resolution Across Add-in, Physics Engine, and Web UI**:
  - **Fusion 360 CAM Parameter Disabling Trap (`isEnabled` fix)**: Resolved the root cause in `ToolWizFusionAddin.py` where Fusion 360 disabled `tool_feedPlunge` in the UI when helical ramping was active (`p.isEnabled == False`), causing `apply_param` to silently bypass writing the plunge feedrate and leaving Fusion's internal default of `0 in/min`. Added `force=True` to `apply_param` for all feedrate parameters (`tool_feedPlunge`, `tool_feedRamp`, `tool_feedEntry`, `tool_feedExit`, `tool_feedTransition`, `tool_spindleSpeedRamp`) so parameters are always written directly to the operation.
  - **Physics Engine Fallback Floor (`calc_ramping`)**: Guaranteed that whenever cutting feedrate is positive ($> 0$), `plunge_feed` will never evaluate to zero (automatically defaulting to `ramp_feed` if positive, or $0.25\times \text{feedrate}$ as a safe lower bound).
  - **Digital Twin & Preset Generation (`json_mutator.py` & `app.py`)**: Ensured all generated and mutated tool presets strictly map non-zero `v_f_plunge` and `v_f_ramp` values into tool JSON structures, preventing imported presets from defaulting to `0`.
  - **Dynamic Web UI Decimal Formatting**: Replaced static `.toFixed(1)` formatting in `templates/index.html` with dynamic decimal scaling (`formatFeed()`), preventing micro-tool plunge feedrates (e.g. $0.0375\text{ IPM}$) from truncating to `"0.0"`.

### Added
- **High-Visibility Pulsing 'Auto-Set' Parameter Badges & Smart State Persistence**:
  - **High-Contrast Amber Glow & Breathing Indicator**: Tool parameters currently populated with system or catalog defaults (`Tool Stickout`, `Flute Length`, `Flute Count`, `Helix Angle`, `Corner Radius`, and recommended `Axial Depth` / `Radial Width`) display a prominent, unmistakable amber badge `[⚡ Auto]` with an animated pulsing dot and glowing outline (`@keyframes autoSetGlow`).
  - **"Auto-Set Dials" Integration**: Clicking the prominent "⚡ Auto-Set Dials" (`applyRecommendations()`) button dynamically flags `Axial Depth of Cut` and `Radial Width of Cut` with pulsing amber `[⚡ Auto]` badges, giving instantaneous visual confirmation that the cut dials were set by physics recommendations.
  - **Click-to-Confirm & One-Click "Confirm All"**:
    - Clicking any `[⚡ Auto]` badge turns it emerald green with a checkmark `✓` before smoothly dismissing.
    - Added header status pill `[⚡ X Auto-Set] · [Confirm All]` to acknowledge all defaults simultaneously.
    - Directly typing or dragging a dial slider immediately clears the auto-set badge via `markManualEdit()` and records the parameter as user-edited.
  - **State Persistence Bug Fix (`localStorage`)**: Resolved an issue where returning users' saved `localStorage` states inadvertently cleared all auto-set flags on page reload. State tracking now explicitly distinguishes between `userEdited` parameters and system defaults so auto-set indicators remain reliably visible until confirmed or modified.
  - **CSS Cache-Busting & Embedded Fallback Styles**: Added `?v=3.1` query versioning to `/static/style.css` and embedded key `@keyframes autoSetGlow` rules directly in `<head>` to guarantee instant rendering across cached browser sessions.
  - **Out-of-Spec Smart Scaling (Layer 1 Guardrail)**: Automatically intervenes only when geometry values become wildly out of physical spec upon diameter or tool changes (e.g. stickout $> 5.5\times D$, flute length $> 4.5\times D$, or stickout $<$ flute length), re-normalizing them to safe shop proportions and pulsing the `Auto` badge.
  - **Machining Advisor Geometry Sanity Audits**: Added active physics rules flagging extended stickout ($> 3.5\times D$), severe stickout ($> 4.5\times D$), 4+ flutes in aluminum roughing, and collet chuck clamping across cutting flutes.
- **High Feed Milling (HFM) & Window Machining Integration**:
  - **Dynamic UI Gating**: High Feed options (`High Feed Milling` and `High Feed Slotting / Window Profiling`) are strictly gated and visible only when a High Feed capable cutter (`High Feed Mill` or `Bullnose / Radiused`) is selected. Auto-reverts safely if the user switches to a Square End Mill or Drill.
  - **New Tool Variants**: Added `HP Carbide High Feed Endmill`, `Carbide High Feed Endmill`, `HP Carbide Bull Nose Endmill`, and `Carbide Bull Nose Endmill` to the End Mills tool category group.
  - **Axial Chip Thinning Factor (ACTF)**: Physics engine computes instantaneous axial chip thinning ($ACTF = \frac{1}{\sin(\kappa_r)}$) for low lead angles ($\sim 12^\circ - 15^\circ$, delivering $3.5\times - 5.0\times$ feed boosts) and circular bullnose radius geometry ($DOC < R_{corner}$).
  - **Force Decomposition & Deflection**: Incorporates axial load redirection (~85% axial into machine spindle), scaling down lateral tool deflection force ($F_{lateral} \ll F_{radial}$).
  - **Window Machining / Slotting with Tabs**: First-class support for full slotting ($WOC = 1.0\times D$) at shallow DOC for cutting part profiles; Advisor provides specialized guidance on near-zero lateral force protecting delicate holding tabs, paired with compressed air blast recommendations.
  - **Red Critical Rule Violation Warnings**: Machining Advisor dynamically inspects cut geometry and flags hard violations in **RED** (`type: "critical"`):
    - Square End Mill selected with High Feed strategy.
    - Bullnose tool with undefined/zero corner radius ($R \le 0.001"$).
    - Depth of cut exceeding safe high-feed threshold ($DOC > 0.05\times D$ for dedicated high feed mills).
    - Depth of cut exceeding 35% of bullnose corner radius ($DOC > 0.35\times R_{corner}$).
  - **Ramping Angle Clamping**: Automatically limits ramping angle to $\le 1.5^\circ$ for high feed cutters to prevent tool heel dragging.
  - **Industrial Vendor High Feed Benchmarks**: Expanded automated benchmark matrix (`tests/benchmarks/vendor_catalog_data.json` and `tests/test_vendor_strategy_matrix.py`) from 21 to 25 test cases, validating against published catalog data from Helical Solutions (HFM-4 in 4140 Steel and 304 Stainless, and window profiling with tabs) and Harvey Tool (Miniature High Feed series in 6061-T6 Aluminum).
- **Permanent Machining Advisor & Guidance Panel**:
  - Repositioned Machining Advisor directly beneath Material Removal Rate and Tool Deflection (above Ramp & Plunge Feed).
  - Permanently visible at all times, with dynamic status pills and zero-scroll placement.
  - Active physics diagnostics for material springback, tool wear compensation offsets, and work-hardening cleanup pass minimums.
  - Optimal operating confirmation badge when feeds, speeds, chip load, and deflection are balanced within safe envelopes.
- **Tool Categories Grouped by Tool Type**:
  - Reorganized Tool Category selector into <optgroup> clusters (End Mills, Drills & Holemaking, Reamers, Threading & Tapping, Saws & Woodruff Cutters, Turning / Lathe).
  - Enforced strict hierarchical ordering: High Performance (HP) -> Standard Carbide -> High Speed Steel (HSS).
  - Added support for Carbide Reamer and categorized all 22 cutter variants.
- **Unified Form Controls & Dialog Boxes**:
  - Implemented .tool-dialog-input glassmorphic styling across all input fields, eliminating stark-white unstyled browser defaults.
  - Unified Tool Diameter, Flute Length, Flute Count, Helix Angle, Tool Stickout, Shank Diameter, Neck Geometry, Cutter Thickness, Corner Radius, and Machine Parameters.
  - Integrated dual keyboard input and tactile range slider controls for Flute Count, Helix Angle, and Stickout.
  - Restyled Flute Length quick ratio buttons (3xD, 4xD, 5xD) with .btn-ratio.
- **Force-Modulated Springback & Tool Wear Compensation**:
  - Integrated radial cutting force feedback into springback deflection modeling.
  - Dynamic tool wear compensation (-Total Error) offset calculation for CNC controller D-offset (G41/G42) and CAM radial stock-to-leave.
  - Dedicated springback profiles for Nitronic 60, Titanium, Inconel, 300-series Stainless, Delrin/Acetal, and PEEK.
  - In work-hardening materials like Nitronic 60, Advisor alerts users against taking zero-offset spring passes to prevent edge rubbing and burnishing.
- **Anti-Caching Headers**:
  - Configured Cache-Control: no-cache, no-store, must-revalidate, Pragma: no-cache, and Expires: 0 headers to ensure browsers immediately load updated templates and styles.

### Validated & Tested
- Comprehensive 17-suite test coverage (60+ unit tests) passing 100%:
  - 	est_nitronic_60_regime.py: Verified Nitronic 60 springback, wear compensation, work hardening, and multi-cut regimes.
  - 	est_vendor_strategy_matrix.py: All 21/21 vendor benchmarks passed against Harvey Tool and Helical standards.
  - 	est_tool_families_validation.py: Verified T-Slot, Dovetail, Chamfer, and spindle RPM limited micro-tool kinematics.

## [1.2.0] - 2026-09-10

### Added
- **Thread & Tap Calculator**:
  - Added ISO Coarse/Fine, UNC, UNF, and custom thread parameter calculators.
  - Added G-Wizard tapping drill size grid and blind hole clearance calculations.
  - Differentiated Form Taps (cold forming) vs Cut Taps with calibrated RPM and feedrate formulas.
- **T-Slot, Dovetail, and Chamfer Mill Support**:
  - Automated radial reach enforcement (Max Reach = (D - d_neck) / 2) and cutter thickness locking.
  - Depth-based effective cutting diameter calculation for angled chamfer mills.
- **Spindle RPM Limitation Kinematics**:
  - Machine spindle ceiling clamping (e.g. 16,000 RPM Brother Speedio spindle).
  - Synchronized feedrate downscaling preserving constant chip load (IPT) and preventing rubbing.
  - Spindle RPM limited diagnostic notification.

## [1.1.0] - 2026-08-26

### Added
- **Dynamic 2D SVG CAD Tool & Cut Geometry Visualizer**:
  - Real-time proportional cross-section rendering of tool shank, relieved neck, flutes, collet, and workpiece cut engagement.
  - Live collision warnings for neck clearance and toolholder overhang.
- **Digital Twin Integration**:
  - Fusion 360 Tool Library synchronization and batch parameter injection.
  - Real-time tool library search and multi-tool selection.

## [1.0.0] - 2026-07-24

### Added
- Initial release of ToolWiz Engine for Brother Speedio S500X2.
- Core GWizard reverse-engineered physics engine:
  - Deflection cantilever calculation.
  - Radial Chip Thinning Factor (RCTF).
  - Minimum chip thickness rubbing protection.
  - Tortoise to Hare aggressiveness scaling.
- Material database with 60+ material families and specific alloy overrides.
