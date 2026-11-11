# Sandvik CoroPlus ToolGuide probes: 17-4 PH hardness

_Research with the user, 2026-10-15. Source: CoroPlus ToolGuide cutting-data screens (Solution board → Cutting data), from screenshots the user supplied. Purpose: Sandvik publishes no hardness correction for kc1. Its calculator applies one, and its power and torque outputs reveal it._

## Setup

- **Tool:** CoroMill Dura 1K344-0200-XC 1730. DC 0.0787" (2 mm), 4 flutes (vf = fz·z·n checks out), APMX 0.177", 6 mm shank.
- **Feature:** rectangular pocket in solid material, 0.5 × 0.5", R 0.05", depth 0.126". External emulsion 10%.
- **Material:** ToolGuide "17-4PH", ISO P, at the hardness entered. The calculator shows no MC code.

## Readings (quoted from the screens)

| Run | Step | VC ft/min | FZ in | N 1/min | VFM in/min | AE in | AP in | HEX in | QQ in³/min | PPC HP | MMC (N·m) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 200 HB, "Multitask machine - Small" | Helical milling | 249 | 0.0003 | 12100 | 14.5 | 0.0787 | 0.0312 | 0.0003 | 0.0179 | 0.0571 | 0.0336 |
| 200 HB | Pre-machining (dynamic) | 440 | 0.000618 | 21300 | 52.7 | 0.0078 | 0.125 | 0.000369 | 0.0514 | 0.0821 | 0.0274 |
| 345 HB, "Universal machining center" 37.5 HP, 18000 1/min | Helical milling | 142 | 0.0003 | 6880 | 8.26 | 0.0787 | 0.021 | 0.0003 | 0.00683 | 0.0273 | 0.0283 |
| 345 HB | Pre-machining (conventional, full slot, 6 axial passes) | 142 | 0.0003 | 6880 | 8.26 | 0.0787 | 0.021 | 0.0003 | 0.0137 | 0.0273 | 0.0283 |
| **45 NCD 16** (not 17-4) 420 HB, Universal machining center, **compressed air** | Helical milling | 212 | 0.0003 | 10300 | 12.4 | 0.0787 | 0.025 | 0.0003 | 0.0122 | 0.046 | 0.0318 |
| 45 NCD 16, 420 HB | Pre-machining (dynamic); **rpm at the machine's 18000 cap** | 371 | 0.000691 | 18000 | 49.7 | 0.00619 | 0.125 | 0.000372 | 0.0385 | 0.0727 | 0.0288 |
| **17-4 PH 345 HB**, Universal machining center, emulsion | Pre-machining (dynamic) | 256 | 0.000683 | 12400 | 33.9 | 0.00634 | 0.125 | 0.000372 | 0.0269 | 0.0537 | 0.0308 |

Overview at 345 HB: tool life count 5.58 features; machining time 3:33.8.

## Derived (reviewer's arithmetic)

Specific cutting force implied by Sandvik's own power: kc = PPC[kW]·60·10⁶ / QQ[mm³/min].

| Comparison | kc at 200 HB | kc at 345 HB | Ratio |
|---|---|---|---|
| Helical milling (same strategy in both runs) | 8710 | 10913 | **1.253** |
| Pre-machining (dynamic at 200, full slot at 345; same mean chip h_m = 0.000191") | 4361 | 5441 | **1.248** |

The helical step's absolute kc reflects how Sandvik defines QQ for helical entry. Only its ratio is used.

**Hardness and force.**
- Sandvik scales force by about ×1.25 from 200 to 345 HB. That is kc ∝ HB^0.41.
- Sandvik's own MC table gives P5.0.Z.AN (200 HB, 1800) → P5.0.Z.HT (330 HB, 2300) = ×1.28, and → P5.0.Z.PH (330 HB, 2800) = ×1.56.
- So the calculator treats 17-4 PH as the annealed ferritic/martensitic group scaled by hardness, which lands on the **HT** level, not the PH row.

**Hardness and speed.**
- At a fixed fz of 0.0003", Sandvik drops vc from 249 to 142 SFM (×0.57), which is vc ∝ HB^−1.03.
- 142 SFM at 345 HB matches Harvey SF_875400's 140 SFM for 17-4 at 300–350 HBn, from an independent vendor.

**Model check (`physics_v2/forces.py`, P5.0.Z.AN, 0° rake, K_r 0.4).**
- At equal mean chip, Sandvik's kc is 0.79× the model's in both runs: 200 HB dynamic (ae 0.1·D), and 345 HB full slot after ×1.25 hardness scaling.
- The ratio is the same at very different engagements, so the h_m + Kienzle structure matches Sandvik's.
- The constant 0.79 is a tool/rake factor to calibrate. By Sandvik's 1%/° rule it would be about 21° of rake, which is high for a steel end mill.

## Sandvik holds the mean chip constant

In every pre-machining case the mean chip thickness h_m = fz·(1 − cos φe)/φe is **0.000191" (0.0049 mm)** for this 2 mm tool:
- 17-4 PH at 200 HB, dynamic, ae 0.10·D, fz 0.000618;
- 17-4 PH at 345 HB, full slot, fz 0.0003;
- 45 NCD 16 at 420 HB, dynamic, ae 0.079·D, fz 0.000691.

The strategy, engagement, material and hardness all change; the mean chip does not. Sandvik raises fz to undo chip thinning and doesn't reduce it for hardness. Hardness lowers the speed. This is the tooth-strength / chip-thickness limit (C2 in design §3.5) expressed as a constant h_m per tool size.

## Family-specific hardness exponents

45 NCD 16 (a Ni-Cr-Mo low-alloy steel, Sandvik P2, not stainless) at 420 HB has an implied dynamic kc of 5156 N/mm² at the same h_m.
- Using P2.5.Z.HT (2000 at 330 HB) with the same 0.79 tool factor gives 4838. That implies kc ∝ HB^0.26 from 330 to 420 HB.
  - **Correction (step 4, 2026-10-17):** that arithmetic used mc 0.21. Sandvik prints mc **0.25** for P2.5.Z.HT. With 0.25 the model gives 8066 N/mm² at this h_m, so the ratio is 0.64, not 0.79. The calculator behaves as if mc were 0.21 for this steel too. Calibration therefore takes the tool factor from the three 17-4 readings only (0.791). See `v2_calibration_findings.md` §1.
- Sandvik's own table gives exactly 0.26 for P2 (P2.1.Z.AN → P2.5.Z.HT), and 0.49 for P5 (P5.0.Z.AN → HT) against the calculator's 0.41 for 17-4.

**Working hypothesis:** the calculator's hardness correction is about the exponent implied by each family's own annealed/hardened rows. Speed also stays higher for the low-alloy steel (212 SFM at 420 HB helical) than for 17-4 (142 at 345 HB). Stainless carries its own speed penalty on top of hardness.

## Like-for-like 17-4 dynamic (200 vs 345 HB)

Both runs use the dynamic strategy and emulsion, and neither is limited by rpm (21300 and 12400 against 30000 and 18000 caps). The 345 HB run keeps the same mean chip (0.000191").

| | 200 HB | 345 HB | Ratio |
|---|---|---|---|
| Implied kc (N/mm²) | 4361 | 5450 | **1.250** (p = 0.41) |
| Dynamic vc (SFM) | 440 | 256 | **0.582** (vc ∝ HB^−0.99) |
| Helical (full engagement) vc | 249 | 142 | 0.570 |
| Dynamic / full-engagement speed | 1.77 | 1.80 | |

What this confirms:
- **Force rises ×1.25 from 200 to 345 HB.** Three independent comparisons agree (1.248, 1.250, 1.253).
- **Speed falls about in proportion to hardness** (exponent ≈ −1.0), the same for dynamic and full engagement.
- **Engagement raises speed by a constant factor.** At about 9–10% tooth contact (ae 0.08–0.10·D, φe 33–37°), Sandvik runs **1.8×** the full-engagement speed at both hardnesses. This is the first sourced number for the HEM thermal speed effect (C7, design §3.5 and §3.7 "HEM thermal SFM boost"). It is one engagement level, so the shape vs ae is still unknown.

## Not yet known

- **A third 17-4 point** (H900, about 420 HB / 44 HRC) to confirm the curve shape. The 45 NCD 16 run is a different family.
- **A consistent setup.** The machine (rpm cap) and coolant changed between runs. Speeds can only be compared with the same machine and coolant.
- **Speed vs engagement.** Only two engagement levels so far: full, and about 0.09·D. Runs at about 0.2, 0.3 and 0.5·D (Change cutting data) would give the curve.
