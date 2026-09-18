# Changelog

All notable changes to the ToolWiz Engine project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2026-09-18

### Added
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
