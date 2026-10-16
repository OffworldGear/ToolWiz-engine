# ToolWiz cutting model v2: design

_Status: draft for review, 2026-10-15. Branch `toolwiz/hardening`. Author: Claude, with the user's decisions._

## 1. Why a new model

Today ToolWiz works like this:
- GWizard's empirical tables (SFM and chip load by material, tool class and diameter) are the base.
- Multipliers and rules are stacked on top of them.
- Only the deflection part is physics: a cantilever integral over the tool profile.

Every new case has needed a new patch. The two weeks to 2026-10-15 added:
- a slot SFM ×0.8;
- the OSG long-reach SFM line and chip-load bands;
- a chip-load-for-depth trade;
- per-operation deflection limits;
- micro floors;
- a coating rule.

Each one is a calibration, not physics. When they disagree with vendors, nothing explains why.

The evidence that the base itself is wrong for small tools comes from Harvey's published Speeds & Feeds sheets (see `docs/research/harvey_micro_data.md`). For 1/16"–3/32" tools in steel, ToolWiz gives:
- SFM 1.4–1.9× Harvey's;
- chip load 1.4–4.5× Harvey's;
- feed 2–7× Harvey's.

**Update (2026-10-15, data step, revised with the user):** comparing whole cuts, not chip loads, v1 is not too aggressive by removal rate or tool load. At 1/4" in 17-4, v1 removes 0.05 in³/min where vendors remove 0.13–0.65, at 5–20× less lateral force. v1's SFM is 1.5–2.5× high and its depth 10–30× shallow. Harvey's generic and material-specific sheets agree on removal rate. Harvey runs 2–4× below Helical and Kennametal, mostly through lower SFM. See `docs/research/v2_data_findings.md` §2.

ToolWiz runs a heavy chip at a shallow depth. Harvey runs a thin chip, deep and narrow. That difference is behind the user's "tiny stepdown, giant G-code" problem on the 1/16" rougher.

**Goal:** compute every cut from physics. That means chip geometry, force, deflection, stress and power, with explicit limits. Use vendor data (Harvey, Helical, OSG, Sandvik, Kennametal) only to calibrate and validate the model, never as a lookup table.

**Rule (user, 2026-10-15):** don't copy one vendor's tables. Understand the physics, and use the data to confirm it.

## 2. Scope

- **v2.0:** solid end mills (square, bull nose, ball) for slotting, side milling and roughing, adaptive/HEM, and finishing passes.
- **Later:** chamfer mills, form tools, drills, taps and thread mills.
- **Unchanged:** these keep their current rules until they have their own model:
  - drills keep GWizard's length rules;
  - taps keep the pitch-based feed;
  - saws, T-slot and keyseat cutters keep their current engagement rules.

## 3. Model

All lengths are in inches internally; the notation below uses mm and N where the source formulas do. Each quantity shows in the provenance ("Why this number?").

### 3.1 Engagement and chip geometry

| Quantity | Formula |
|---|---|
| Engagement angle, side milling (ae ≤ D) | φe = arccos(1 − 2·ae/D); a full slot is φe = π |
| Maximum chip thickness | h_max = fz·sin(φe) when ae < D/2, otherwise h_max = fz |
| Mean chip thickness (Sandvik form) | h_m = fz · (ae/D) / (φe/2) for κr = 90° |
| Teeth in cut (average) | z_c = z·φe/(2π) |
| Teeth in cut with helix overlap | z_c' = z_c + ap·tan(β)/(π·D/z), capped at z |
| Ball and bull nose | effective diameter at depth ap (exists today), with axial chip thinning for ball nose |

### 3.2 Forces: mechanistic (Altintas) with the Kienzle size effect

| Force | Formula |
|---|---|
| Specific cutting force | kc(h) = kc1.1 · h^(−mc) · K_γ · K_wear, with h in mm |
| Tangential, per engaged tooth | F_t = kc(h_m)·ap·h_m + K_te·ap (the K_te term is the edge/ploughing force) |
| Radial | F_r = K_r·F_t + K_re·ap, with K_r about 0.3–0.6 by material and rake |
| Lateral force on the tool | Average over the engagement arc of the vector sum of all engaged teeth (Altintas, *Manufacturing Automation*, ch. 2), split into feed-direction and normal components |
| Power | P = F_t,total·v_c |
| Torque | T = P/ω, checked against the active machine's spindle torque curve (§4.1) |

Notes:
- **Replacement:** this replaces today's power-based force (`calc_cutting_forces`: `unit_hp × MRR → hp → F_t = 33000·hp/SFM`), which ignores the size effect and the edge force.
- **Data:** Sandvik publishes kc1.1 and mc per material group (MC codes in the Sandvik Coromant Technical Guide). Map the 31 GWizard families to them. Use GWizard `unit_hp` only as a cross-check.
- **Hardness:** hardness scales kc1.1 the way Sandvik's hardness columns do. This replaces today's SFM/IPT hardness scaling where it is about force. Hardness also still lowers the speed (§3.6).

### 3.3 Runout

- Flute k sees chip h_k = fz + Δr_k. In the worst case (2 flutes, runout in phase) that is fz + TIR on one flute and fz − TIR on the other.
- The **worst flute** carries the chip-thickness and force limits (§3.5).
- Below fz ≈ TIR, one flute cuts and the others rub. This is the main cause of micro-tool breakage per Bao & Tansel (2000).
- TIR is a machine/holder setting. It's stored now in `data/machine_settings.json` as `runout`, with a default of 0.0002".
- **To check:** today's warning (TIR ≥ 0.5·fz) against Harvey's "runout ≤ 2% of D". The model makes the warning unnecessary, because the limit acts directly.

### 3.4 Tool stiffness and stress

- **Deflection:** keep the existing exact integral over `ToolProfile` segments (flute core, neck, shank, tapers).
- **Load position:** apply the lateral load at the load centroid (about ap/2 from the tip, adjusted for helix) rather than at the tip as today. A tip load overstates deflection for deep cuts.
- **Bending stress:** σ = M·c/I at each critical section: the flute root (core diameter about 0.6–0.75·D depending on flute count) and every diameter step (neck to shank). Take the maximum.
- **Equivalent stickout:** keep `BeamDeflectionEngine.equivalent_stickout` for any rule that still needs an L/D (chatter, below).

### 3.5 Constraints

Every constraint names its source. "Empirical" means kept deliberately until it can be modeled.

| # | Constraint | Basis | Data needed |
|---|---|---|---|
| C1 | h_max(worst flute) ≥ λ·r_β (no ploughing) | Minimum chip thickness: λ ≈ 0.2–0.4 by material (Ducobu et al.; Chae et al. review) | Edge radius r_β by coating and size (uncoated micro ≈ 1–3 µm; PVD adds a few µm) |
| C2 | h_max(worst flute) ≤ h_tooth(D, material, coating) | Tooth and edge strength: the flute land section grows with D. Fit h_tooth = c_mat·D^n | Chip-load-vs-diameter curves from **several** vendors (Harvey, Helical, OSG, Sandvik) |
| C3 | Deflection ≤ δ_allow(operation, D, aggressiveness) | Accuracy and breakage | Today's limits, reviewed |
| C4 | σ_max ≤ s·σ_fatigue(carbide) | Breakage | Carbide transverse rupture strength (TRS) about 3–4.5 GPa; fatigue fraction from the literature |
| C5 | P ≤ P_spindle(rpm) and T ≤ T_spindle(rpm) | Machine | Spindle curve (Speedio 16k) |
| C6 | ap ≤ LCF; ae ≤ D; ae fixed for finishing passes (stock) | Geometry | — |
| C7 | v_c from Taylor tool life (v_c·T^n = C) at the chosen life; rpm ≤ machine max | Thermal and wear | C and n per material × tool material × coating, anchored to vendor SFM; GWizard SFM as a prior |
| C8 | Full-slot micro depth ≤ k_slot·D | **Empirical:** chip packing (Harvey miniature guide: step down 5–15% of D when slotting) | Vendor slot depths |
| C9 | Stickout-related speed reduction | **Empirical:** chatter. OSG overhang tables applied to the equivalent stickout. Replace with stability lobes if the user ever measures the tool's vibration response | — |
| C10 | Work-hardening alloys: h ≥ h_wh (cut under the hardened layer) | **Empirical:** vendor guidance | Per-alloy values |

### 3.6 Choosing the cut

- **Decision variables:**
  - fz;
  - ap;
  - ae, which is fixed for slots (D) and for finishing (the stock);
  - v_c, from C7 and capped by rpm.
- **Objective:** maximize removal rate, with a credit for fewer Z levels (the user's G-code concern):
  - score = MRR / (1 + t_level·v_f / (ap·L_path)).
  - With no part data, use a fixed small credit, set so that "deep with a thin chip" wins over "shallow with a heavy chip" when removal is about equal (the 10% rule the user approved on 2026-10-13).
- **Agreed with the user (2026-10-15):**
  - **Speed is not a free variable.** v_c comes from C7 (tool life at the alloy's real hardness and the engagement), and only then is MRR maximized over fz, ap and ae. If speed were free, MRR would always drive it to max rpm, since in the force model speed adds removal without adding force.
  - **The objective depends on the operation.**
    - Roughing and adaptive maximize MRR, with the Z-level credit from the real depth.
    - Finishing maximizes feed at the fixed ap and ae of the stock, with deflection held within tolerance and the chip above C1.
    - Slotting has ae fixed at D; it maximizes over fz and ap, with C8 capping ap.
  - **Robust optimum.** Pick a point with a margin from each binding limit (set by aggressiveness), preferring a point where MRR is flat. Then an error in an uncertain limit (runout, K_r, the tool factor) costs little MRR rather than a tool.
- **Aggressiveness** sets the safety margins, not multipliers on the result: the δ_allow fraction, the stress fraction s, the tool-life target, and λ.
- **Expected behavior:** for micro side milling, C2 (tooth strength) and runout pin fz low, deflection then allows a large ap, and the optimum is deep and narrow. That is Harvey's micro roughing pattern. It should come out of the model, not be hard-coded. If it doesn't, something is missing from the model.

### 3.7 What happens to today's rules

| Today | v2 |
|---|---|
| GWizard SFM and IPT tables | Prior and cross-check for C7 and C2. Not the base. |
| Hardness scaling (linear to 45 HRC, then the vendor curve) | Moves into kc1.1(HB) and Taylor C(HB) |
| Coating rule (GWizard TiAlN rating) | Taylor C per coating; r_β per coating |
| Slot SFM ×0.8 | Falls out of C7 at full engagement (heat). Remove if the model shows it. |
| Chip thinning | §3.1 (identical physics, now explicit) |
| HEM thermal SFM boost | C7 with engagement-dependent heat (needs data); keep the empirical value until then |
| Reach SFM line, OSG | C9 (empirical, explicit) |
| Reach chip-load floor and depth trade | Removed: replaced by the optimizer and C2 |
| Deflection limits per operation | C3 (review the values) |
| Micro deflection floors | C3 plus C1/C2 |
| MCT table | C1 |
| Runout warning | C1/C2 on the worst flute; the warning text stays |
| Aggressiveness ×0.6–1.4 on SFM and IPT | Safety margins (above) |

## 4. Data and calibration

### 4.1 Parameter sets

All parameter sets live in versioned JSON under `data/model_v2/`, each with a `source` field:
- `materials.json`: kc1.1, mc, K_r, K_te, Taylor C/n, λ, h_wh, and the GWizard family → Sandvik MC group mapping.
- `tools.json`: r_β by coating and diameter; c_mat and n for h_tooth; core-diameter ratio by flute count; carbide E, TRS and fatigue fraction.
- Machine profiles (`machines/*.json`, one per machine, user-editable): max rpm, power by duty rating, and the torque curve as [rpm, N·m] points per rating, with power interpolated linearly between points. The Speedio 16k curve is in `machines/speedio_s500x2.json`. Runout stays a machine setting with a per-tool override (Blum measurement later).

### 4.2 Benchmark dataset

`tests/benchmarks/v2/*.json`, one row per published recommendation:
- vendor, document, page or table, exact cells quoted, URL, date accessed;
- tool part number and full geometry, including shank, neck and LOC;
- material and condition;
- operation, ap, ae, SFM, fz.

**Coverage target:**
- **Diameters:** 1/64, 1/32, 1/16, 1/8, 1/4, 1/2, 1".
- **Materials:** 6061, 1018/1045, 4140 annealed, 17-4/316, Ti-6Al-4V, H13 at 45–50 HRC, Inconel 718.
- **Operations:** slot, side or rough, HEM, finish.
- **Vendors:** at least two independent vendors per cell.

### 4.3 Fitting

- Fit with least squares on log error over the calibration rows, keeping 30% of rows back for validation.
- Report the residuals by vendor, diameter band and material.
- A parameter that only one vendor's data supports gets marked as such.

### 4.4 Local calibration

The existing `cutlog.py` adjusts the user's own results from cuts they log, on top of the model.

## 5. Validation (acceptance gate for the switch)

- **Benchmark rows:** within the vendor's published range ±10%, with no 1.3× slack (today's harness allows SFM up to 1.30× the maximum). Rows outside get a written explanation. Never loosen a target to pass.
- **Spread:** median absolute log error per diameter band ≤ 25%, and no systematic bias by vendor or band.
- **Side-by-side comparison:** v1 and v2 on every benchmark, plus the user's real tools:
  - T1: 1/8" 4FL, LCF 0.5, LB 0.6;
  - T12: 1/16" 4FL with the corrected 1/8" shank;
  - the 17-7 PH jobs.
  Review it with the user before switching.
- **Existing tests:** the 451 tests stay green or are deliberately rewritten. Rewritten tests are listed in the PR.

## 6. Implementation plan (each step in its own session or PR)

1. **Data first.** Build the v2 benchmark dataset (§4.2). Source the Sandvik kc1.1/mc table and carbide properties. Research is in `docs/research/`. **Done 2026-10-15:** 578 rows, findings and open decisions in `docs/research/v2_data_findings.md`.
2. **Force model module** `physics_v2/forces.py`, with unit tests against textbook examples (Altintas) and Sandvik power examples.
3. **Constraint and optimizer module** `physics_v2/optimize.py` (pure functions), plus the provenance of which constraint is binding. **Done 2026-10-16:** T12 and T1 come out deep and narrow, limited by C3 (v1's deflection limits); findings and open decisions in `docs/research/v2_optimizer_findings.md`.
4. **Calibration script** `tools/calibrate_v2.py`, which writes `data/model_v2/*.json` and a residual report.
5. **Pipeline integration** behind `TOOLWIZ_MODEL=v2` (v1 stays the default). The web page and Fusion show which model produced the numbers.
6. **Comparison report** (an HTML artifact) for the user's review, then the switch to v2 and v1's retirement.

## 7. Decisions (user, 2026-10-15)

1. **Tool life:** vendor-typical. Taylor C is anchored so that default aggressiveness reproduces the vendors' published SFM; other aggressiveness settings trade life for speed.
2. **Z-level credit:** use the operation's real depth (top to bottom height) when the add-in can read it; otherwise the fixed credit from the 10% rule (2026-10-13).
3. **Spindle torque curve:** supplied by the user for the 16k spindle and stored in `machines/speedio_s500x2.json` (`torque_curve`): 5.1 kW continuous, 7.4 kW for 10 min / 15% ED, 40 N·m momentary up to the ~4,500 rpm base speed. The quoted high-speed torques (8.8 / 5.9 / 4.4 N·m at 8k / 12k / 16k) equal the 7.4 kW rating. To be checked against the Brother spindle output chart.
   - **Decided (user, 2026-10-15):** C5 uses the continuous rating for sustained cutting. Below base speed it is constant torque, about 10.8 N·m, which is far tighter than a power-only check: at 764 rpm (1" tool at 200 SFM) the torque cap is 0.87 kW, against 5.1 kW for power alone.
   - **Other machines:** ToolWiz must accept spindle data for any machine (user, 2026-10-15). Machine profiles hold max rpm, power by duty rating and torque curve points, entered by the user; the Speedio file is one profile among several.
4. **Runout:** 0.0002" TIR for micro tools unless the user enters an override. Later goal: the Blum laser measures runout per tool and writes it to the tool library, so TIR becomes a per-tool value with the machine setting as fallback. Not implemented yet.
5. **Scope:** chamfer mills and ball and bull-nose finishing move to v2.1. v2.0 is square end mills: slot, side/rough, adaptive/HEM and finish.

## 8. References

**Machining physics:**
- Altintas, Y. *Manufacturing Automation* (Cambridge), ch. 2 (mechanistic milling forces), ch. 3–4 (stability).
- Machinery's Handbook, 31st ed., Machining Econometrics: equivalent chip thickness, minimum mean chip thickness about 0.02–0.04 mm for macro end and face milling. https://online.flippingbook.com/view/954192180/1380/
- Sandvik Coromant Technical Guide: kc1.1 and mc by MC material group; mean chip thickness and power formulas.

**Micro milling:**
- Chae, Park & Freiheit (2006), *Investigation of micro-cutting operations*, Int. J. Machine Tools & Manufacture: review; minimum chip thickness 5–38% of edge radius.
- Ducobu et al.: minimum chip thickness in micro-milling. https://orbi.umons.ac.be/bitstream/20.500.12907/23470/1/LAMDAMAP2009_Ducobu_François.pdf
- Size effect and minimum chip thickness in micromilling (FAPESP). https://bv.fapesp.br/pt/publicacao/104739/size-effect-and-minimum-chip-thickness-in-micromilling
- Bao & Tansel (2000), *Modeling micro-end-milling operations Part II: tool run-out*. https://web.eng.fiu.edu/wbao/JournalPapers/Modeling%20micro-end-milling%20operations%20Part%20II-%20tool%20run-out.pdf
- Micro-milling review, Int. J. Adv. Manuf. Technol. https://link.springer.com/article/10.1007/s00170-020-06445-w

**Vendor data (calibration and validation only):**
- Harvey Tool Speeds & Feeds sheets SF_73000, SF_72000, SF_47800, SF_34600 (links in `docs/research/harvey_micro_data.md`).
- Harvey, *How to optimize results with miniature end mills* (slot step-down 5–15% D; runout ≤ 2% D). https://www.harveyperformance.com/in-the-loupe/how-to-optimize-results-while-machining-with-miniature-end-mills/
- Harvey/Helical HEM Guidebook (HEM up to 2×D axial; risky below 1/16"; not below 1/32"). https://www.basstool.com/pdf/promos/HEM_Guidebook.pdf
- OSG EXOCARB AM-HFC List 4970 and PHOENIX guides (overhang reductions). https://osgtool.com/content/literature/8002024CA/Tech%20pg.%20List%20(s)-%204970.pdf
