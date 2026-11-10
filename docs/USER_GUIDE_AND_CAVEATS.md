# ToolWiz & Fusion 360 Add-In: User Instruction Guide & Shop-Floor Caveats

This guide covers how to operate **ToolWiz** across the Web UI, the **Fusion 360 Add-In** (`ToolWizFusionAddin/ToolWizFusionAddin.py`), and the **Model Context Protocol (MCP) Server** (`mcp_server.py`), along with essential engineering caveats for **Speeds & Feeds**, **Stock to Leave**, and **Tool Library Management**.

---

## 1. Quick-Start Setup & Installation

### A. Starting the ToolWiz Server
The Fusion 360 Add-In, Web UI, and MCP bridge communicate with the local Flask physics server (`app.py`) on `http://127.0.0.1:5000`:
```powershell
python app.py
```

### B. Installing / Updating the Fusion 360 Add-In
Whenever the repository is updated, copy the latest add-in and shared `toolwiz_common` package into your Fusion 360 `AddIns` folder:
```powershell
python install_addin.py
```
Then in Fusion 360:
1. Press **Shift + S** (*Utilities > Scripts and Add-Ins*).
2. Select the **Add-Ins** tab -> **ToolWizFusionAddin** -> click **Stop** (if already running) and **Run** (check *Run on Startup*).
3. In the **Manufacture (CAM)** workspace, the ToolWiz commands appear in the toolbar panel.

---

## 2. How the Core Systems Work

### A. Speeds & Feeds (`v1` & `v2` Physics + Live B-Rep Inspection)
When you run **ToolWiz Auto-Set** on an operation in Fusion 360 (or calculate in the Web UI):
1. **Tool Profile & Continuous Shaft Taper**:
   - `ToolProfile.from_fusion` (`toolwiz_common/tool_profile.py`) reads the tool's cutting diameter (`DC`), flute length (`LCF`), reduced neck (`shoulder-length` / `shoulder-diameter`), shaft diameter (`SFDM`), and stickout (`LB`).
   - If the tool has explicit segments in Fusion's **Shaft** tab (`shaft.segments`), ToolWiz integrates those exact cylinders and cones.
   - If the **Shaft** tab is empty, there is no reduced neck, and `SFDM > DC` (e.g., a 1/32" or 1/16" micro-tool on a 1/8" shank), ToolWiz automatically models a **continuous conical taper** from the top of the flutes (`LCF`) up to **0.5 mm (0.0197") below the tool holder (`LB - 0.5 mm`)**, followed by a 0.5 mm straight shank into the collet.
2. **Live B-Rep Feature Inspection**:
   - `inspect_operation_geometry` (`toolwiz_common/cam_geometry_inspector.py`) inspects the operation's selected faces/contours and target body to measure:
     - **Feature Z-Depth vs. Stickout**: Flags holder collision if `feature_depth + 0.050" > stickout`, or calculates cubic stiffness gain if you can choke up on the tool by >= 0.25".
     - **Minimum Internal Corner Radius (`R_c`)**: Calculates the engagement wrap spike and populates Fusion's reduced corner feedrate (`feed_reduced`).
     - **Thin Walls (< 0.080") & Thin Floors (< 0.060")**: Uses opposite-face raycasting (`findUsingRay`) and antiparallel plane checks to compute a workpiece compliance multiplier.

### B. Stock to Leave Manager (Deflection & Springback Compensation)
- Computes tool cantilever deflection, material edge springback, and thin-wall/floor compliance for roughing, semi-finishing, and finishing passes.
- Recommends radial and axial **Stock to Leave** values so roughers never undercut the finished wall and finishing passes compensate for push-off.
- Every parameter write in Fusion is wrapped in `AuditedCommand` and logged to `~/.toolwiz/addin_audit.jsonl`.

### C. Holistic AI & Physics Oversight ("Second Opinion")
- Automatically runs `evaluate_holistic_oversight` (`oversight_engine.py`) on every calculation and via `POST /api/oversight_review` (or MCP tool `toolwiz_holistic_oversight`).
- Evaluates five shop-floor categories outside of standard single-cut equations:
  1. **Tool-to-Material & Coating Pairing** (e.g., warns with `CAUTION` when using `AlTiN` in wrought `6061` aluminum, >= 4 flutes in aluminum slotting, or `ZrN`/`Uncoated` in `17-4 PH` stainless; flags unknown or ambiguous coatings without guessing).
  2. **Shaft Taper Wall-Rubbing**: Stops you if the pocket depth exceeds `LCF`/`shoulder-length` on a tool whose shaft tapers outward (`SFDM > DC`), which would rub the tapered shaft against the vertical pocket wall.
  3. **Chip Evacuation & Thermal Shock**: Flags deep full-width slotting (`DOC / D > 1.25`) and flood-coolant thermal shock in high-SFM hard milling.
  4. **Model Divergence (`v1` vs. `v2`) & Knife-Edge Windows**: Warns when `v1` and `v2` differ by >35% or when spindle runout is >= 45% of the chip load while deflection is near its ceiling.
  5. **Setup Sequence & Rest-Machining Logic**: Flags micro-tools following >= 2.5x larger roughers without `restMaterial` enabled.

### D. Tool Library Curator (Local, Cloud/Hub & Active Setup)
- `curate_tool_library` (`tool_library_curator.py`, `POST /api/library/curate`, MCP `toolwiz_curate_tool_library`, or Fusion bridge action `curate_setup_tools`) inspects tool JSON definitions and repairs:
  - Micro-tool shanks mistakenly left at `SFDM == DC` (sets to standard 1/8" / 3.175 mm).
  - Empty `shaft.segments` when `SFDM > DC` (writes explicit frustum + straight shank segments with the 0.5 mm holder margin so **Fusion 360's own 3D viewer and Shaft & Holder collision checker** see the taper).
  - Missing `BMC` coatings (`AlTiN`, `ZrN`, `DLC`, `Uncoated`) and corner radii (`RE`) inferred from the tool description/SKU.

---

## 3. Critical Caveats & What You Must Be Aware Of

### A. Caveats for Accurate Speeds & Feeds
1. **The Assumed 0.5 mm Continuous Shaft Taper Is a Conservative Default**:
   - When Fusion's **Shaft** tab is blank on a tool where `SFDM > DC`, ToolWiz assumes a continuous straight taper from the top of the flutes (`LCF`) to 0.5 mm below the holder (`LB - 0.5 mm`).
   - **When this is slightly too flexible**: Many stub micro-tools (e.g., Harvey/Helical) use a 15-30 deg neck transition cone that reaches the full 1/8" shank diameter well before the collet if stuck out far. In that case, the continuous taper to 0.5 mm below the holder predicts slightly *higher* deflection (making ToolWiz's recommended DOC/WOC slightly more conservative/safer).
   - **When this is dangerous (Relieved-Neck Tools)**: If you are using a **long-reach, reduced-neck micro-tool** (where a thin neck slightly smaller than `DC` extends for 0.250"-0.500" above the flutes before tapering to 1/8") and you did **not** enter `shoulder-length` in Fusion, ToolWiz will think the shaft starts tapering thicker immediately above `LCF`. **Always enter `Shoulder Length` (tip-to-neck-end) in Fusion for relieved-neck tools.**
2. **Actual Stickout (`LB`) Must Match Physical Setup at the Machine**:
   - Deflection scales with the **cube** of stickout (`delta ~ L^3`). A tool stuck out 0.75" at the machine when Fusion says `LB = 0.50"` bends **3.37x more** than calculated. Always verify `Length Below Holder` (`LB`) in Fusion matches your physical gauge/collet projection.
3. **Spindle Runout (`TIR`) Dominates Micro-Tool Life (<= 0.125")**:
   - On a 1/32" (0.0312") end mill with a target chip load of 0.00025"/tooth, a standard worn ER collet with 0.0004" TIR causes one flute to take a double chip (0.00045") while the opposite flute rubs (0.00005"). Keep the **Runout** setting in Machine Settings calibrated to your actual holder (`0.0001"` for shrink-fit/hydraulic/high-precision ER, `0.0003"+` for standard ER).
4. **`v1` (GWizard Empirical Tables) vs. `v2` (Calibrated Mechanistic Optimizer)**:
   - `v2` currently covers **solid carbide square end mills** in `adaptive`, `roughing`, `slotting`, and `wall finishing` across calibrated material families. For ball nose, bull nose, chamfer, thread mills, drills, and taps, ToolWiz automatically falls back to `v1` and notes why in `model_note`.
5. **Live B-Rep Inspection Requires Selected Geometry in the CAM Operation**:
   - If an operation relies purely on automatic stock silhouettes with no selected faces, edges, or pocket contours (and no setup target body), `feature_geometry` may only see bounding-box depth. Selecting the target pocket/wall faces in Fusion gives the B-Rep inspector exact corner radii and wall thicknesses.

### B. Caveats for Stock to Leave & Deflection Compensation
1. **Negative Stock to Leave (Wear / Push-Off Compensation) Can Overcut at Corners & Entry/Exit**:
   - When ToolWiz predicts that a finishing pass will push off by e.g. `+0.0008"` due to tool deflection + material springback, compensating with a **negative** Radial Stock to Leave (`-0.0008"`) brings the straight wall into nominal tolerance. **However**, whenever the cutter slows down (tight internal corners, lead-in/lead-out arcs, or dwell points), cutting force drops, tool deflection relaxes, and a negative Stock to Leave can **gouge/undercut** at those low-force points.
   - **Best Practice**: Prefer adding a **zero-stock spring pass** (or using cutter wear compensation `G41`/`G42` at the control after measuring with a micrometer/pin gauge) rather than programming aggressive negative Stock to Leave in CAM on tight-tolerance features.
2. **Roughing Stock to Leave Must Exceed Rougher Deflection + Corner Scallops**:
   - Never set Roughing Radial Stock to Leave smaller than the rougher's own predicted deflection + surface tear-out (`>= 0.002"-0.005"` for micro tools, `>= 0.010"-0.020"` for macro tools), otherwise the finishing tool will hit bare spots or work-hardened glazed patches.
3. **Thin-Wall Raycast Measures the Final CAD B-Rep, Not In-Process Stock**:
   - `cam_geometry_inspector.py` measures wall thickness on the **finished CAD B-Rep body**. If two pockets flanking a thin wall are roughed simultaneously, use stepped Z-waterline passes so uncut stock supports the wall from behind.

### C. Caveats for Tool Library Management (Local, Cloud/Hub & Curated Shafts)
1. **Fusion 360 Cloud & Team Hub Libraries Cache In Memory**:
   - If you export a Cloud/Hub `.json` or `.tools` library, curate it with ToolWiz (`/api/library/curate`), and re-import it into Fusion 360, **operations already inside an open `.f3d` document keep their own embedded copy of the tool** until you either re-select the tool from the updated library or run the live `curate_setup_tools` bridge action on the active setup.
   - Always close the Fusion **Tool Library** dialog before writing to local library files on disk so Fusion does not overwrite your changes on dialog close.
2. **Verify Curated `shaft.segments` Against Vendor Catalogs for Undercut / Relieved-Neck Tools**:
   - The Tool Library Curator's automatic taper (`populate_shaft_taper=True`) generates a 2-segment shaft (a conical taper from `shoulder-diameter`/`DC` to `SFDM` ending 0.5 mm below `LB`, plus the upper straight shank).
   - If Fusion's **Shaft & Holder Clearance** ("Pull away" / "Trim") is enabled on a 3D multi-axis or deep-pocket operation, Fusion will use those `shaft.segments` to trim toolpaths that come too close to the tapered cone. For tools with a reduced neck, enter the vendor's exact `shoulder-length` and `shoulder-diameter` first before running the curator.
3. **Automatic Backups**:
   - Whenever ToolWiz modifies `data/working_library.json` via `/api/library/curate` (`apply_to_working_library=True`) or merges libraries, a timestamped backup is saved via `backup_manager.py` in `data/backups/`.
