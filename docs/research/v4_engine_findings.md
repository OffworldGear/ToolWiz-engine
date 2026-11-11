# v2 engine, V4 round (engine agent): what changed and why

Branch `v4/e1-engine`. Numbers are the conformance run at aggressiveness 50 %, runout 0.0001" (gated), model v2, on 2,420 in-scope square-end rows.

## 1. Speed law against engagement

Diagnosis (planner, engine at 50 % against the vendor group median at the same engagement): HEM SFM 0.80x (p25-p75 0.67-0.92), traditional roughing 1.19x, side 0.83x, slot 0.94x.

What the data say (tools/calibrate_v2.py rows, 1,271 square rows in 528 charts):

| Question | Finding |
|---|---|
| Is the engagement exponent k wrong? | Within charts (same document, tool, material, hardness) k = 0.156 (1/16-3/32 up to 1/2" bands alike). Per vendor: Emuge 0.13, Kennametal 0.07, OSG 0.17, Sandvik 0.19, Kyocera 0.22, YG-1 0.27, Harvey and Garr 0.00 (they print one SFM for slot, side and rough of a tool). Pooled equal-vendor weight is what the engine uses. |
| Does a hinge help? | Credit only below ae = D/2, the radial chip-thinning onset (h_max = fz*2*sqrt(ae/D*(1-ae/D))). Within-chart rmse 0.1150 (k = 0.216) against 0.1193 with no hinge on the training rows; hold-out 0.1043 against 0.1039, i.e. no gain beyond noise. Kept at ae_ref = 0.5 as the physically motivated form (no speed credit for heavy cuts), `Material.vc_engagement_ae_ref`. |
| Floor a0 (the lightest engagement given credit)? | Grid 0.01-0.08; 0.05 is best in every variant (train and hold-out). Kept. |
| Where does the 0.80x / 1.19x come from then? | Between-chart, by toolpath type: fitted jointly with the family levels against the bucket vendor medians (L1, training rows), the HEM level is 1.153x and the side/rough level 0.896x of slot, at the same engagement. Within the same chart HEM/side = 1.40 at ae 0.05 against 0.5 (model 1.43): the HEM credit is carried by which vendors publish HEM sheets (Kyocera, YG-1, Sandvik, OSG run faster) and by their coatings, not by a steeper law. Harvey (the only vendor with "rough" rows) runs rough at its slot SFM and is 0.30-0.48 log-units below the pooled law in every operation. |

Change: `Material.vc_op_factor` ((rough, 0.896), (adaptive, 1.153), slot 1) multiplies the C7 level (`operation_speed_factor`, `taylor_speed_m_min(..., operation)`); fitted in `calibrate_v2.fit_level_consensus` (finishing rows get a column of their own so they do not pull the others; its factor is not applied). Speed-law fit alone (median |ln| of predicted/vendor SFM): training 0.325 -> 0.308, hold-out 0.275 -> 0.250. The speed offset that lands the 75 % output on the vendor median moved 1.025 -> 1.05; the per-family refit (`speed_by_family.json`) was redone against the new law (applied: 420, 4130, Ti). The factor is empirical: it should be read as "vendor HEM sheets run 15 % faster than the engagement law", not as a measured thermal effect.

Result at 50 % (conformance, per group, 289 groups): HEM SFM 0.92x, rough 1.20x (see below), side 0.82x, slot 0.95x. HEM passes 93.0 % (was 85.9 %), side 94.3 %, slot 95.8 %, overall 92.4 % (was 90.3 %).

Rough does not reach 85 % (83.0 %, 8 of 47 groups fail, gate 85 %). Every failing rough group is SFM above the Harvey span, and the binding check is the vendor consensus, not C7: High Temp Nickel 0.30-0.60 (3 groups: 66 SFM, the cap is 0.92 x the median of Harvey 50 and Sandvik 94 = 72; the Harvey rows span 38-62 after tolerance), 17-4 1/4-1/2 and > 1/2 at ae 0.1-0.3 (302 and 273 against 109-250, C14v again), 1045 at <= 1/32 (361 against 150-250, C7), H13 at <= 1/16 (133 and 191 against 45-75, C14v). All rough rows are one vendor group (Harvey Performance); the engine anchors to the cross-vendor median, which is 20-50 % above Harvey's own rough sheets in these materials. Closing the gap would mean anchoring "rough" to one vendor, which breaks the two-independent-vendors rule (R-C). Left as a strict xfail with this cause.

HEM chip load: the groups' fz ratio is 0.89-0.90, and C14f (0.92 x the vendor median chip load) is the binding check in 50 of 71 groups, C2 in 16 (ratio 1.01). C3 is not binding for any HEM group at the group's median engagement. The residual 4 groups below 0.55 are tiny tools held by C11, the 200 IPM adaptive feed cap, or the spindle. Vendors' HEM fz is the programmed feed per tooth with the thinning already compensated; nothing in the engine multiplies it again. So HEM feed (SFM x fz ratios) is 0.78x, set by the two 0.92 caps and the group spread, not by a defect.

## 2. Titan rows

`tests/benchmarks/v2_staged/titan.json` (70 rows, corner-radius micro mills, Harvey Performance) is in `tests/benchmarks/v2/`. All tools that read the rows now filter on `tool.end` (square only for provisional limits, chip limits, invariants, engagement envelope, calibration, series performance; legacy spelling "corner radius" normalized by `v2_provisional_limits.end_of`). Regenerated: provisional_limits.json, chip_limits.json, invariants.json, engagement_envelope.json (unchanged), consensus.json (unchanged), materials.json (new speed_operation block), tools.json, speed_by_family.json, calibration_report.json (`--quick`), calibration_rows.json, tool_series_performance.json, and the new consensus_shaped.json.

## 3. Runout defaults

`toolwiz_common/runout.py`; documented in README, ADDIN_USER_GUIDE, REVIEW_AND_FIX_PLAN D10. Explicit request runout wins; else the Fusion tool's `holder.description` class (SK/SX/SKC collet chucks, hydraulic, shrink fit, powRgrip, micro chucks 0.0001"; ER-UP 0.0002"; ER 0.0004"; Weldon 0.0012"); else 0.0001" for D <= 1/8" and 0.0002" above. `runout_in` and `runout_source` ("request", "holder: <class>", "default by diameter") are in `/api/calculate`, `/api/calculate_for_fusion` and `pipeline.CutResult`. The web page and the add-in dialog still send their own 0.0002" field, so for them the source is "request" until they stop sending a default (planner/UI branches).

## 4. Micro gate (D <= 1/16")

78.0 % (gate 85 %), unchanged. Remaining failures and binding checks: High Temp Nickel (slot <= 1/32, side <= 1/32, hem 1/32-1/16, rough x2: SFM 66-115 against 21-94, C7 and C14v: the family level is fitted across all diameters and the diameter term has the wrong sign for HEM-poor micro nickel), 1020 side 1/32-1/16 (SFM 551 against 34-286, C7), 316 side <= 1/32 (no cut, C14m), 4130 side 1/32-1/16 (fz, C2), H13 side <= 1/32 (fz, C1/C2 floor at 13 rows) and rough x2 (C14v), Ti hem 1/32-1/16 (SFM 245 against 120-225 and fz, C4). No physics fix has a clear diagnosis; the earlier note's conclusion (force model consistent with Kienzle at tiny chips) stands.

## 5. Ball and bull-nose end mills

Model (physics_v2/endforms.py, `optimize.ShapedEngagement`; `Tool.corner_radius_in`, 0 square, D/2 ball):

* Profile r(z) = R - rc + sqrt(rc^2 - (rc - z)^2) in the corner (z < rc), R above; sin kappa = (r - (R - rc))/rc is the lead angle of the edge. Effective diameter at ap: D_eff = 2 r(ap).
* Speed: C7 sets v_c at D_eff (rpm = v_c/(pi D_eff)); C14 compares the SFM on the nominal diameter with the vendor's (vendors print nominal-diameter SFM; the contact SFM is reported as `contact_sfm`).
* The edge is cut into axial slices (10 over the corner, up to 40 over the cylinder so no slice lags more than 0.08 rad of helix). Each slice has its own radius, local radial engagement ae_j = clamp(ae - (r(ap) - r_j), 0, 2 r_j) (the wall sits ae inside the cutting radius at the depth of cut), engagement arc, helix lag tan(beta)/r(z), and chip h_n = sin kappa x (runout chip). Slice force dF_t = (K_tc(h_n) h + K_te / sin kappa) dz, in-plane dF_r = (K_r K_tc h sin kappa + K_re) dz: the edge element dz/sin kappa times the thinner chip keeps the chip area fz sin(phi) dz of a cylinder, so a corner radius -> 0 reproduces the square tool (mean force within 3 %, peak within 12 %, tested). The thinner chip only raises kc (size effect) and lowers C2's chip (axial chip thinning: a bull nose with ap < rc takes more fz, as a high-feed cutter does). Deflection and stress use the same load and centroid as before.
* C14: tables per end form (`consensus_shaped.json`, built by `tools/build_shaped_consensus.py` from ball rows (1,456) and bull rows with R >= 1 % of D (1,281)); one vendor group is accepted there (the ball and bull data are mostly Harvey), and a bucket with none falls back to the square table. The chip-limit and engagement-envelope tables are the square ones.
* Scope: `v2_bridge.NOT_SQUARE` no longer lists ball, bull or radius; a radius under 1 % of D is an edge break and the tool stays square. 3D finishing operation names map to the finish operation, so `finish_modes` adds the scallop (cusp h = ae^2/(8 R_eff)) check on the v2 result; adaptive and 3D roughing run through the same engagement path.
* Cost: a shaped `loads` call is about 1.5 ms (square 0.8 ms); an adaptive call stays near 1 s.

Conformance, ungated (the groups meet neither the 90 % overall nor 85 % per operation targets): ball 71.4 % of 161 groups (slot 81.1, rough 73.1, finish 77.0, side 0 of 5, hem 0 of 6), bull 73.2 % of 209 (slot 87.5, rough 70.3, finish 73.9, side 64.7, hem 57.9). SFM is at 0.92x the group median by construction. The failures are chip load below the vendor floor in HEM and ball side groups at deep ap (C3 and C4 bind at ap up to D; HTN and Ti HEM fz 0.27-0.8x), H13 ball side (SFM 216 against 45-125: the same cap for every diameter band, so the bucket comes from the square table; not isolated further), and 1020 / nickel finish groups (C14f). Nothing was tuned on these groups.
