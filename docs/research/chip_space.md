# Chip space and flute count (check C15)

_Branch `v4/h1-chipspace`, 2026-11-12. Code: `physics_v2/chipspace.py`, check C15 in `physics_v2/optimize.py`, parameters
`data/model_v2/chip_space.json` written by `tools/calibrate_chip_space.py`. Tests: `tests/test_v2_chip_space.py`._

## 1. Question and short answer

The v2 engine had no limit that depends on flute count, so in a slot the chip per tooth came out the same for 2 to 7
flutes and the feed and MRR rose in proportion to the flute count. The question was whether a chip-space (gullet) limit,
calibrated on what vendors publish, should stop that.

Short answer, from the data below:

* Vendors run every flute count close to the same gullet fill. In a full slot the ratio of gullet area to chip area,
  S = A_g / (fz·ae), has a lower envelope of about 6 to 8 in every material group and for 2 to 5 flutes. In aluminium,
  where vendors' slot chip loads are largest, the published chip load per tooth falls with flute count about as the
  gullet area does: fz/D about 0.018-0.025 (2 flutes), 0.006-0.012 (3), 0.008-0.009 (4). No vendor in the dataset
  publishes a full slot in aluminium with 5 or more flutes.
* The engine's chip in a 6061 slot at 50 % is 0.0046·D, set by C2 (a chip limit that does not depend on flute count),
  and that is half of what vendors run on 3- and 4-flute tools. At that chip a 5-flute uses 76 % of its allowed gullet
  fill at full depth, a 6-flute 85 %, and a 7-flute 100 % (now C15-limited). So C15 binds where vendors publish nothing:
  6-7 flutes in a full aluminium slot, and 5-7 flutes in aluminium slots deeper than about 1.5·D. It does not bind in
  steel, stainless or titanium slots at the engine's chip loads, nor in any HEM cut.
* The MRR of a 5-flute 1/4" slot in 6061 (5.6 in³/min at 16,000 rpm) is not physically wrong by chip room: Emuge
  publishes a 4-flute 1/4" full slot 1·D deep at 0.002" per tooth (6.1 in³/min at its 795 SFM), with a gullet fill
  close to the vendor envelope. What makes "more flutes" always win in the engine is that the 2- and 3-flute tools are
  held to the same chip as the 5-flute by C2. With C2 out of the way, C15 alone gives the vendors' chip loads by flute
  count and the 2- and 3-flute tools remove more than the 5-flute (section 6). Making C2 flute-aware would raise the
  few-flute chip, i.e. relax an existing limit; that is an owner decision and was not done here.

## 2. Sources

What was read directly:

| Source | What it says (quoted or paraphrased) | Used for |
|---|---|---|
| Sandvik Coromant, "Groove or slot milling" (knowledge page, sandvik.coromant.com/en-us/knowledge/milling/groove-or-slot-milling, read 2026-11-12) | Full slotting with an end mill is demanding; "The axial cutting depth should be generally reduced to around 70% of the edge length"; "Make sure to evacuate chips out of the groove"; "Use compressed air to avoid chip congestion"; "Use coarse pitch cutters". No tooth-count rule. | Depth term exists; coolant/air assumption |
| Patent CA 3 000 831 C, "End mill having teeth and associated flutes with correlated physical parameters" (patents.google.com, read 2026-11-12) | "increasing the number of teeth reduces available flute space"; 5-11 teeth, 7 "the most preferred number of teeth taking into account flute space"; flute depth about 10-14 % of D at the rear and 16-20 % at the front (core about 0.6-0.8·D). | 7-flute core ratio; flute space falls with tooth count |
| "How Flute Count Influences End Mill Performance", mfgrobots.com (read 2026-11-12; text matches Harvey's In The Loupe article but carries no credit) | "increasing the number of flutes on a tool limits the size that the flute valleys can be"; "the larger the core, the stronger a tool will be"; 2 flutes for aluminium and non-ferrous, 4 for steel; HEM "can achieve extreme MRR with a very small step over". | Qualitative: more flutes, smaller valleys |
| `docs/research/carbide_and_edge_radius.md` §5 (repo, earlier research) | Core ratio by flute count from patents (EP 1 072 345, US 11,554,426, US 10,335,870) and Mitsubishi ("usually about 60 %" for 4 flutes). | Core table |
| `tests/benchmarks/v2/*.json` (repo, 6133 vendor rows with cited cells) | Full-slot rows by flute count and material (section 4). | Calibration of K and the depth term |

Seen only as search-engine extracts (the pages could not be fetched: harveyperformance.com answers automated requests
with a captcha page). Treat these as unverified:

* Harvey Performance, In The Loupe: "the lower the flute count, the larger the flute valley ... allows for larger chips
  with heavier depths of cut, ideal for soft or gummy materials like aluminum"; for slotting stainless "4 flute tools are
  the best choice because the lower flute count allows for more efficient chip evacuation"; 3 flutes for slotting
  aluminium; miniature slotting tools favour 4-5 flutes for core strength even in aluminium; HEV-5 (5 flutes) for HEM and
  finishing, "above average" in slotting.
* Sandvik CoroMill 316 two-tooth head: "Use when big chip space is needed (for example full slot)".
* Broaching practice: gullet area must exceed the uncut chip area by a "chip space number" (a Springer broaching chapter
  gives about 5-8 for steel and 3-7 for non-ferrous metals; a Materials Science Forum paper defines the gullet-to-chip
  ratio as π·h²/(4·a_f·L) > 1). These numbers were not checked against the originals and are not used numerically; they
  only support the form of the check (gullet area ≥ K × uncut chip area, K of a few to ten).

Not found: any vendor or handbook table of gullet area or chip packing by flute count for end mills, any measured core
ratio for micro end mills, and any vendor rule that ties a flute count to a maximum slot depth.

## 3. Model

**Chip per tooth.** Per unit length of edge, one tooth removes the crescent between its path and the previous tooth's:
area fz·ae. This is exactly the mean chip thickness times the arc length (Sandvik h_m = fz·(ae/D)/(φe/2), arc = φe·D/2).
The chip volume per tooth is fz·ae·ap, but the gullet holding it is also ap long, so the comparison is per unit length.

**Gullet area.** A_g = φ_void·(π/4)·D²·(1 − c_z²)/z: the annulus between the core circle c_z·D and the cutting diameter,
split among z flutes, of which φ_void is open gullet. Core ratio c_z (design values, `core_ratio_by_flutes`):

| flutes | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|
| c_z | 0.55 | 0.58 | 0.60 | 0.64 | 0.66 | 0.70 | 0.72 |
| z·A_g relative to 2 flutes | 1.00 | 0.95 | 0.92 | 0.85 | 0.81 | 0.73 | 0.69 |

φ_void = 0.55 is my estimate; it scales every flute count alike and cancels in the calibration (K is fitted with the
same value), so only the ratios in the last row matter. A user-entered `Tool.core_ratio` overrides the table.

**Packing.** The curled, loosely packed chip needs K times its uncut area. K depends on the material (long gummy
aluminium chips pack worse than short steel chips; titanium chips are thin and segmented) and is calibrated per material
group (section 5). Chip compression ratios were not used numerically.

**Radial engagement.** In a side cut the tooth leaves the stock on an open side and the chip leaves the gullet there,
so the gullet only has to hold one tooth's chip: fz·ae, which is small for light radial cuts. That is why many-flute
tools are sold for HEM: at ae 0.05-0.15·D the chip area is 7-20 times smaller than in a full slot at the same fz.

**Slot depth.** In a full slot (ae ≥ 0.95·D) the chip has no open side; it has to climb the flute and leave at the
top of the slot. K is raised for deep slots: K_eff = K·(1 + k_d·max(0, ap/D − a0)), a0 = 0.5, k_d = 0.5 (estimates;
sensitivity below). Sandvik's "reduce axial depth to about 70 % of the edge length" and "use compressed air" for full
slots say the same qualitatively.

**Coolant / air.** The vendor rows assume the vendor's recommended coolant or air blast, so K includes it. The engine
has no coolant input; a dry slot without air would need a larger K. Not modelled.

**Check.** u = K_eff·fz·ae/A_g ≤ u_limit(a), u_limit = consensus_scale(a)/consensus_scale(1): 1.0 at aggressiveness 1
(the most packed published slot), 0.84 at 50 %, 0.69 at 0. Aggressiveness scales it because K is the extreme of the
vendor data and the geometry is a design estimate; the margin is the one the engine keeps on its other vendor-anchored
limit, C2. Finishing passes are exempt. C15 is an upper limit on fz (in `upper_ok`, like C2), so the optimizer trades
depth and chip load against it and reports it in `binding` / `limited_by`.

## 4. What vendors publish (full slots, square end, `tests/benchmarks/v2`)

`python3 tools/calibrate_chip_space.py --table`; S = A_g/(fz·ae) with the geometry above (larger = more room).

| group | flutes | slot rows | vendors | ap/D median / max | fz/D median / max | S min / median |
|---|---|---|---|---|---|---|
| non-ferrous | 2 | 6 | Harvey 1, OSG 5 | 0.60 / 1.00 | 0.0179 / 0.0250 | 6.0 / 8.5 |
| non-ferrous | 3 | 9 | Helical 2, OSG 3, YG-1 4 | 1.00 / 1.00 | 0.0087 / 0.0120 | 8.0 / 11.0 |
| non-ferrous | 4 | 11 | Emuge 5, Harvey 1, Sandvik 2, Seco 3 | 0.50 / 1.00 | 0.0080 / 0.0088 | 7.8 / 8.6 |
| non-ferrous | 5+ | 0 | none | | | |
| steel | 2 | 11 | Harvey 1, Kennametal 6, Seco 4 | 0.30 / 0.50 | 0.0040 / 0.0127 | 11.9 / 37.5 |
| steel | 3 | 9 | Garr 6, Harvey 1, Seco 2 | 1.00 / 1.00 | 0.0072 / 0.0112 | 8.5 / 13.3 |
| steel | 4 | 147 | 9 vendors | 1.00 / 1.60 | 0.0042 / 0.0112 | 6.2 / 16.3 |
| steel | 5 | 54 | Harvey 33, Helical 9, Kennametal 4, Kyocera SGS 8 | 0.15 / 1.00 | 0.0016 / 0.0072 | 7.1 / 31.6 |
| stainless | 2 | 15 | Harvey 2, Kennametal 3, Seco 10 | 0.32 / 0.50 | 0.0127 / 0.0127 | 11.9 / 11.9 |
| stainless | 3 | 48 | Garr 8, Harvey 30, Kennametal 3, OSG 5, Seco 2 | 0.28 / 1.00 | 0.0036 / 0.0112 | 8.5 / 26.3 |
| stainless | 4 | 190 | 9 vendors | 0.60 / 1.50 | 0.0035 / 0.0096 | 7.2 / 19.9 |
| stainless | 5 | 47 | Emuge 6, Helical 17, Kennametal 8, Kyocera SGS 8, YG-1 8 | 0.53 / 1.25 | 0.0032 / 0.0054 | 9.4 / 15.9 |
| Ti-Ni-Co | 2 | 3 | Seco 3 | 0.36 / 0.36 | 0.0127 / 0.0127 | 11.9 / 11.9 |
| Ti-Ni-Co | 3 | 60 | Garr 6, Harvey 54 | 0.33 / 1.00 | 0.0034 / 0.0112 | 8.5 / 28.4 |
| Ti-Ni-Co | 4 | 164 | 8 vendors | 0.50 / 1.60 | 0.0032 / 0.0096 | 7.2 / 21.9 |
| Ti-Ni-Co | 5 | 42 | 8 vendors | 0.75 / 1.60 | 0.0029 / 0.0051 | 10.0 / 17.4 |

Readings:

* Nobody publishes 5+ flute full slots in aluminium. Helical publishes 5-flute aluminium HEM (6 rows, S ≥ 35).
* In aluminium the published chip falls with flute count and S stays at 6-11 for 2, 3 and 4 flutes: the vendors' slot
  chip loads in aluminium are chip-space limited.
* In steels, stainless and titanium the median S is 14-22: those slot chip loads are limited by something else (edge
  strength, heat), and only a few rows come near the envelope (Garr's 1/16" slots at 1.0-1.5·D, Helical HEV-5 at 0.5·D).
* Light radial cuts never come near it: the lowest S of any vendor HEM row is about 13 (aluminium, 3 flutes), 17
  (stainless, 8 flutes), 18 (steel, 5 flutes; 7 flutes 22), 25 (titanium, 5 flutes), against a limit of S ≥ 5-7 at 50 %.

## 5. Calibration

K per group = the smallest S/depth_factor among the group's full-slot rows (rounded down), so at aggressiveness 1 no
published slot is outside the limit (`test_no_published_full_slot_is_outside_the_limit_at_full_aggressiveness`):

| group | K | row that sets it | p10 / median of the group |
|---|---|---|---|
| non-ferrous | 5.739 | OSG Blizzard 2 flutes 1/2", 0.6·D, fz 0.025·D | 6.37 / 7.97 |
| steel | 4.113 | Garr VRX 4 flutes 1/16" H13, 1.5·D, fz 0.0112·D | 8.86 / 13.99 |
| stainless | 4.799 | Garr VRX 4 flutes 1/16" 17-4, 1.5·D | 11.09 / 16.57 |
| Ti-Ni-Co | 4.799 | Garr VRX 4 flutes 1/16" Ti-6Al-4V, 1.5·D | 11.73 / 21.60 |

The steel, stainless and titanium values rest on one vendor's micro slots (Garr, 1/16"); without them the envelope is
about 7 (Helical HEV-5, Garr X3). The lower K only makes C15 more permissive there, where it does not bind anyway.
Aluminium packs worse than steel (K 5.7 against 4.1), as expected for long gummy chips.

Depth term: the smallest normalised S in aluminium for k_d = 0 / 0.5 / 0.67 / 1.0 is 6.03 / 5.74 / 5.65 / 5.31. With
k_d 0.5 the 2-flute slots at 0.6·D (OSG) and the 3-flute slots at 1·D (YG-1) normalise to the same packing (5.7-6.4),
which is why 0.5 was kept. The data cannot separate k_d well (few aluminium slots deeper than 1·D); it is an estimate.

**Check of the calibration.** With C2 and the vendor guardrail switched off, so that only C15 limits the chip, a 1/4"
full slot 1·D deep in 6061 at 50 % gives fz/D 0.0176 (2 flutes), 0.0111 (3), 0.0080 (4), 0.0060 (5), 0.0047 (6), 0.0037
(7), and MRR 8.8 / 8.4 / 8.1 / 7.4 / 7.1 / 6.4 in³/min at 16,000 rpm. The 2-, 3- and 4-flute chip loads are the vendors'
(table above), and the per-revolution chip room falls with flute count as z·A_g does
(`test_chip_space_alone_favours_fewer_flutes_in_a_6061_slot`).

## 6. Effect on the engine

Full before/after table in `docs/V4_ENGINE_NOTES.md` ("Chip space"). At 50 %, Speedio 16k: unchanged except 6061 7-flute
full slots and deep 6061 slots with 5-7 flutes (C15 binds); 17-4 and titanium slots and every adaptive (HEM) cut
unchanged (C15 at 12-60 % of its limit in slots, under 20 % in HEM).

The flute-count comparison the tool recommender needs is still dominated by C2 in aluminium: C2 holds a 2-flute to the
same 0.0046·D chip as a 5-flute, where vendors run a 2-flute at 0.018-0.025·D. The chip-space model supplies the
physics for a flute-aware chip limit in aluminium slots (`result.chip_space.max_fz_in` and `max_fz_by_flutes_in` give
each flute count's chip-room limit), but raising C2 for few-flute tools relaxes an existing limit and needs the owner.

## 7. What is my estimate rather than a source

* φ_void = 0.55 (cancels in the calibration), a0 = 0.5·D, k_d = 0.5, the 0.95·D full-slot threshold.
* The core ratios for 3, 6 and 8 flutes are interpolated between the patent values; 7 flutes is the middle of
  CA 3 000 831 C's flute depth.
* The aggressiveness map (borrowed from C2's consensus scale).
* Using the nominal chip (no runout) and the nominal diameter for ball and bull-nose tools.
* No coolant input: the calibration assumes vendor-recommended coolant or air.
