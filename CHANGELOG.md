# Changelog

All notable changes to the ToolWiz Engine project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2026-09-18

### Fixed
- **Tool Deflection Alert Alignment & Auto-Set Physics Safety (`gwizard_physics.py`, `app.py`, & `templates/index.html`)**:
  - **Dynamic Operation-Aware Deflection Limits**: Resolved a critical issue where `app.py` hardcoded the safe deflection limit to a mirror-finish tolerance (`diameter * 0.002` = $0.00013"$) regardless of whether the operation was roughing, slotting, or adaptive. Replaced with `calc_deflection_limit(diameter, operation, aggressiveness, is_carbide)` incorporating G-Wizard roughing allowances and a micro-tool compliance floor ($0.00035"$) to prevent false deflection danger alerts on sub-100 microinch cuts.
  - **Auto-Set Safe Cut Guarantee (`recommend_cut_parameters`)**: Ensured `recommend_cut_parameters` never recommends cuts that exceed allowable deflection. If minimum axial DOC at full radial immersion exceeds the deflection limit (e.g. in tough alloys like Nitronic 60 or high stickout), the optimizer automatically steps down radial engagement (WOC) until deflection is strictly within the safe threshold.
  - **Tool Category & Carbide Checkbox Synchronization (`templates/index.html`)**: Automatically synchronized the `Tool is Solid Carbide (Stiffer)` checkbox with the selected Tool Category (checking it for "Carbide" / "HP Carbide" tools and unchecking for "HSS"), preventing accidental HSS modulus (30 Mpsi) from tripling calculated deflection on carbide tooling.
  - **Dedicated Unit Test**: Added `test_auto_set_dials_deflection_safety` in `tests/test_auto_set_advisory.py` verifying that micro-tools in tough alloys with extended stickout never exceed safe deflection limits when using Auto-Set.
- **AI Chat Response Truncation Resolution (`ai_machinist.py`)**:
  - Replaced single-part extraction (`parts[0].get("text", "")`) with complete parts stream concatenation (`"".join(p.get("text", "") for p in parts if "text" in p)`), preventing multi-chunk Google Gemini API responses from cutting off mid-sentence.
  - Increased `maxOutputTokens` from 2048 to 4096 to ensure extensive machining physics analyses, CAM setup recommendations, and code callouts render completely without truncation.
- **Auto-Set Indicator Manual Selection Integrity & Out-of-Spec Guardrail Alignment**:
  - **Ratio Quick-Set Override Resolution (`setFluteRatio`)**: Resolved an issue in `templates/index.html` where clicking quick-ratio buttons (`3xD`, `4xD`, `5xD`) explicitly set `autoSetTracker.fluteLength = true` and `autoSetTracker.stickout = true`, re-triggering the flashing `[⚡ Auto]` badge despite deliberate user selection. Ratio button clicks are now treated as explicit manual selections (`autoSetTracker = false`), immediately hiding auto-set badges and persisting the choice.
  - **Datalist Selection Event Catch (`onchange`)**: Added `onchange="markManualEdit('fluteLength'); calculate()"` to `<input id="fluteLength">`, ensuring standard flute length picks from `<datalist id="flute_list">` reliably clear the auto-set badge in browsers where datalist selection fires `change` without `input`.
  - **Out-of-Spec Safety Guardrail Protection (`checkOutOfSpecGeometry`)**: Gated flute length and stickout re-normalization so that user-edited parameters are preserved. Re-normalization now only acts when parameters are in auto-set state or exceed extreme mechanical thresholds ($> 12\times D$), allowing standard long-flute cutters ($5\times D$, $6\times D$) without unwanted resets.
  - **Excessive Stickout Auto-Taming Protection (`applyRecommendations`)**: Restricted stickout auto-taming to only trigger when stickout is currently auto-set, preventing manual stickout overrides from being overwritten when running "Auto-Set Dials".
  - **Formal Testing Protocol (TP-01 to TP-10)**: Created dedicated test suite in `tests/test_auto_set_indicators.py` verifying state tracker transitions, ratio buttons, datalists, and out-of-spec bounds.
- **Neck Clearance Collision Alert Precision & Flute Depth Gating**:
  - **Eliminated Hidden DOM Neck Diameter Defaults**: Fixed an issue in `templates/index.html` where standard end mills without relieved necks transmitted a hidden default `<input id="neckDiameter">` value ($0.125"$) to `/api/calculate`. When using tools like $3.2\text{ mm}$ ($0.12598"$), this created an artificial $0.0006"$ ($0.0125\text{ mm}$) neck step that falsely triggered collision alerts for standard cuts.
  - **Physical Axial Engagement Gating (`gwizard_physics.py`)**: Gated the Neck Clearance Collision rule so that neck clearance checks are strictly applied to dedicated form cutters (e.g. T-Slot, Woodruff, Keyseat, Lollipop, Dovetail) or when axial cut depth physically plunges deeper than the cutter's flute length (`cut_depth > flute_length * 1.001`). When cutting within the flutes, the tool neck remains in free air above the workpiece wall and cannot collide.
  - **Backend Neck Normalization (`app.py`)**: Explicitly normalized `neck_diameter = diameter` in `/api/calculate` and `/api/fusion_calculate` whenever `hasRelievedNeck` is unchecked and the tool is not a form cutter.
- **Plunge Feed Rate Zero-Value Resolution Across Add-in, Physics Engine, and Web UI**:
  - **Fusion 360 CAM Parameter Disabling Trap (`isEnabled` fix)**: Resolved the root cause in `ToolWizFusionAddin.py` where Fusion 360 disabled `tool_feedPlunge` in the UI when helical ramping was active (`p.isEnabled == False`), causing `apply_param` to silently bypass writing the plunge feedrate and leaving Fusion's internal default of `0 in/min`. Added `force=True` to `apply_param` for all feedrate parameters (`tool_feedPlunge`, `tool_feedRamp`, `tool_feedEntry`, `tool_feedExit`, `tool_feedTransition`, `tool_spindleSpeedRamp`) so parameters are always written directly to the operation.
  - **Physics Engine Fallback Floor (`calc_ramping`)**: Guaranteed that whenever cutting feedrate is positive ($> 0$), `plunge_feed` will never evaluate to zero (automatically defaulting to `ramp_feed` if positive, or $0.25\times \text{feedrate}$ as a safe lower bound).
  - **Digital Twin & Preset Generation (`json_mutator.py` & `app.py`)**: Ensured all generated and mutated tool presets strictly map non-zero `v_f_plunge` and `v_f_ramp` values into tool JSON structures, preventing imported presets from defaulting to `0`.
  - **Web UI ReferenceError Resolution (`col3Unit is not defined`)**: Fixed a critical client-side JavaScript bug in `templates/index.html` where `const col3Unit = document.getElementById('ramp_col3_unit');` was omitted from declaration. In every calculation, evaluating `if (col3Unit)` threw an uncaught `ReferenceError: col3Unit is not defined`, aborting script execution immediately before `document.getElementById('plunge_feed').innerText` was reached and leaving Plunge Feed frozen at the static placeholder `"0 IPM"`.
  - **Dynamic Web UI Decimal Formatting**: Replaced static `.toFixed(1)` formatting in `templates/index.html` with dynamic decimal scaling (`formatFeed()`), preventing micro-tool plunge feedrates (e.g. $0.0375\text{ IPM}$) from truncating to `"0.0"`.

### Added
- **ToolWiz AI Machinist Live Co-Pilot & Context-Aware Chat Assistant**:
  - **Live Telemetry Injection**: Automatically bundles active ToolWiz parameters (material alloy, machinability rating, cutter diameter, flute length, stickout, operation, DOC, WOC, RPM, SFM, feedrate, IPT, calculated deflection, spindle load, and physics advisor alerts) into every AI prompt.
  - **Dual Intelligence Modes (Google Gemini 2.5 Flash + Offline Knowledge Engine)**: Integrates directly with Google Gemini 2.5 Flash via `httpx` for deep, conversational CAM and machining reasoning. Includes an offline expert machining knowledge engine that answers critical CAM strategy questions (negative stock to leave, floor push-off, springback, chatter mitigation) even when no API key is set.
  - **Ergonomic Slide-Out Drawer & Launcher Buttons**:
    - Header launcher button `[✨ 💬 AI Machinist (Co-Pilot)]` in the main navigation bar.
    - Floating launcher pill at bottom-right of viewport for zero-scroll 1-click access across all views.
    - Inline consultation card in Column 3 (`#tipsContainer`) linking directly to AI advice.
  - **Interactive Quick-Action Suggestion Chips**: One-click prompt chips addressing common complex machining inquiries:
    - *"Should I do negative stock to leave on flats during finishing since deflection is low but springback may occur?"*
    - *"What entry ramping angle and strategy is optimal for this cutter in this alloy?"*
    - *"How can I mitigate chatter with this stickout and flute length?"*
    - *"Should I use climb or conventional milling for finishing this workpiece?"*
  - **AI Model Selector & Active Model Transparency**:
    - **Interactive Model Dropdown**: Added model selection dropdowns in both the AI chat drawer header (`#aiDrawerModelSelect`) and the settings modal (`#aiSettingsModelSelect`), allowing instant switching between `⚡ Auto-Detect Best`, `Gemini 2.5 Pro (Deep CAM Reasoning)`, and `Gemini 2.5 Flash (Fast)`.
    - **Active Model Verification Badge**: Displays the exact model that generated the answer on every response bubble header (`.ai-model-tag`), with distinct styling badges for Pro, Flash, and Offline Knowledge Engine.
    - **Dynamic Model Discovery (`GET /api/ai_models`)**: Integrates with Google's `ModelService.ListModels` to automatically discover available models authorized on the user's API key and prevent 404 retired model errors.
    - **Physics-Informed System Prompt & Fallbacks**: Encoded first-principles CAM engineering logic into the system instructions and offline fallback engine for flat floor finishing, workpiece elastic springback vs. lateral deflection, spring passes, and negative axial stock safeguards.
  - **Client API Key Configuration**: Dedicated settings modal (`⚙️`) allowing users to store their Google Gemini API key securely in browser `localStorage` or configure `GEMINI_API_KEY` on the server.
- **Automatic "Auto-Set Dials" Execution on Tool Diameter Change**:
  - **Automated Dials Calibration**: Automatically executes "Auto-Set Dials" (`applyRecommendations()`) whenever a new tool diameter is set — whether selected from the standard datalist dropdown, typed into the numeric dialog, or transferred from the Thread & Tap calculator.
  - **Dynamic Depth Alignment**: Immediately aligns Axial Depth of Cut (DOC) and Radial Width of Cut (WOC) sliders and numeric inputs to the optimal physics recommendations calculated for the new tool geometry, lighting up the glowing amber `[⚡ Auto]` badges.
  - **Unit-Toggle Immunity**: Normalizes physical diameter in inches (`lastHandledDiaInches`) to prevent false auto-set triggers during pure unit switches between Imperial and Metric.
- **3-Column Ergonomic UI Overhaul & Dedicated Machining Advisor Column**:
  - **Relocated Advisor to 3rd Column**: Moved the Machining Advisor & Guidance panel (`#tipsContainer`) out of the center column into a dedicated **3rd Column** on the right side of the dashboard, resolving vertical crowding across the entire Speeds & Feeds view.
  - **Sticky Viewport Tracking**: Configured the 3rd column with sticky viewport anchoring (`position: sticky; top: 1rem; max-height: calc(100vh - 2.5rem); overflow-y: auto;`) and custom dark scrollbars so live physics guidance and critical alerts stay locked in view as parameters are tuned.
  - **Promoted Entry Dynamics (Ramp & Plunge Feeds)**: Grouped Ramp Angle, Ramp Feed, and Plunge Feed directly below Spindle Speed and Cutting Feedrate in Column 2, putting all primary CNC machine motion values front and center without requiring scrolling past advisory notes.
  - **Expanded Viewport Width**: Increased `.container` max-width to `1720px` (`width: 96%`) to utilize widescreen 1080p and 1440p monitors, preventing horizontal overflow while eliminating >500px of dead margin space.
  - **Responsive Breakpoint Hierarchy**: Seamlessly degrades from 3 columns on desktop ($\ge 1280\text{px}$) to 2 columns on tablets/laptops ($900\text{px} - 1279\text{px}$) and 1 column on mobile devices ($< 900\text{px}$).
  - **Inline Target Cut & Auto-Set Dials**: Added an inline Target Cut indicator and 1-click `"⚡ Auto-Set Dials"` button directly above the Axial Depth of Cut slider in Column 1 for zero-scroll cut depth optimization.
  - **Interactive Advisory Linking**: Clicking `"Details →"` on the Wear Compensation badge in Column 2 smoothly scrolls and triggers a glowing pulse animation (`@keyframes tipHighlightGlow`) on the corresponding Wear Compensation card in Column 3.
  - **CSS Cache Busted (`?v=3.2`)**: Version query bumped to ensure browsers immediately fetch the new 3-column layout.
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
