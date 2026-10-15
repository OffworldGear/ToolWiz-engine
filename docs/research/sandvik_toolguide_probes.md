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

## Not yet known

- **A third hardness point** (H900, about 420 HB / 44 HRC) to confirm the curve shape.
- **Dynamic at 345 HB.** At 345 HB the calculator chose conventional slotting, not dynamic. Was that a user setting or Sandvik's own choice? The machine also differed between runs.
