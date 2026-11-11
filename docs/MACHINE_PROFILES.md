# Machine profiles (v4)

A machine profile (`machines/*.json`, user copies in `data/machines/`) describes the machine the cut is for. The
editor ("Edit machines..." on the Speeds & Feeds page, or "Edit..." in the machine switcher at the top of the page)
edits all of it. Every field below is optional; a profile without the new fields behaves as before.

| Field | Meaning |
|---|---|
| `brand`, `model`, `controller` | text, shown in the switcher |
| `spindle_taper` | one of BT30, BBT30, CAT40, BT40, BBT40, HSK-A63, HSK-E40, HSK-E32, ISO30, R8, ER-spindle, other |
| `dual_contact` | true / false for the machine; a spindle option can carry its own `dual_contact` (the Speedio 16k is non-dual-contact) |
| `max_cutting_feed_mm_min`, `rapid_m_min {x,y,z}` | machine feed limits |
| `through_spindle_coolant_bar` | optional |
| `spindle_options.*` | `max_rpm`, power (continuous / 10 min / peak), torque curves per duty rating, `base_rpm` |
| `holder_stiffness` | `{k_n_um, ktheta_nm_urad, status}`: measured or override value |

**Simple mode** (editor, or `"simple": {"peak_torque_nm", "base_rpm", "continuous_kw"}` on a spindle in the API):
generates the continuous curve (constant torque up to the base rpm, constant power above) and a momentary curve at
the peak torque up to the base rpm. The curves are stored as `derived`; edit the points for the real chart.

## Holder / spindle stiffness default

`v2_bridge.machine_for` reads `holder_stiffness` from the profile. A profile that has none but names a
`spindle_taper` gets an **estimate** from the taper class and the dual-contact flag, marked `derived` (never saved
back, so changing the taper changes the estimate). A profile with neither keeps the engine's own default. The editor
shows the value in use, whether it is an override or an estimate, and an override field ("Use taper estimate"
clears it).

Method (all values are estimates, mark them as such): the BT40 holder / 16 mm carbide tool joint identified by
Ozsahin, Erturk, Ozguven and Budak (2009), Int. J. Mach. Tools Manuf. 49:25-35, Table 2 (k = 51.6 N/um,
ktheta = 0.126 N*m/urad) is the anchor. It is scaled by a taper factor and put in series with the spindle body
radial stiffness of 80 N/um (NK Enginex ATC-BT30 spindle specification, vendor minimum, the same source the Speedio
profile uses).

| Taper | Contact | Factor on BT40 joint | k (N/um) | ktheta (N*m/urad) |
|---|---|---:|---:|---:|
| BT30 | single | 0.7 | 24.9 | 0.088 |
| BBT30 | dual | 0.91 | 29.6 | 0.115 |
| CAT40 | single | 1 | 31.4 | 0.126 |
| BT40 | single | 1 | 31.4 | 0.126 |
| BBT40 | dual | 1.3 | 36.5 | 0.164 |
| HSK-A63 | dual | 1.8 | 43.0 | 0.227 |
| HSK-E40 | dual | 1.2 | 34.9 | 0.151 |
| HSK-E32 | dual | 0.9 | 29.4 | 0.113 |
| ISO30 | single | 0.7 | 24.9 | 0.088 |
| R8 | single | 0.5 | 19.5 | 0.063 |
| ER-spindle | single | 0.9 | 29.4 | 0.113 |
| other | single | 0.6 | 22.3 | 0.076 |

Where the factors come from. No open table of radial stiffness in N/um per taper class was found, so the factors
are engineering estimates guided by these published statements, not values read from a table:

- HSK radial stiffness is "up to five times" that of 7/24 steep-taper systems because of the flange face contact
  (Moldmaking Technology, "HSK: The Critical Link in High-Speed Milling"; Machinery.co.uk, "Interface choice").
  "Up to" is a best case, so HSK-A63 is set to a conservative 1.8x.
- Aoyama and Inasaki (2001), "Performances of HSK tool interfaces under high rotational speed", CIRP Annals 50(1):
  281-284: HSK static radial stiffness is higher than a 7/24 taper on the same spindle, and the difference grows
  with spindle speed (centrifugal growth loosens the 7/24 taper and tightens HSK). Only the abstract was read.
- WZL measurements quoted by Machinery.co.uk: Capto C6 has 1.65 times the interface stiffness of HSK-A63 (context
  for HSK ranking; not used as a factor).
- Dual contact (BBT, BIG-PLUS) adds flange face contact on a 7/24 taper; Big Daishowa calls it the choice for
  deeper, heavier cuts but gives no number. The 1.3x factor is an estimate.
- Taper size: 30 taper (31.75 mm gauge diameter) against 40 taper (44.45 mm) is scaled 0.7x; R8 0.5x and "other"
  0.6x are conservative guesses.

Replace any estimate with a measured value (dial indicator and push-load test) in the override field.

The Speedio S500X2 profile keeps its own provisional value (31.4 N/um, 0.126 N*m/urad: 80 N/um spindle in series with
the BT40 joint of Ozsahin et al.); the BT30 single-contact estimate above (24.9 N/um) is lower and is shown next to it
in the editor.

## Shop shank rule (tool geometry defaults)

`toolwiz_common.geometry.default_shank(diameter, unit="inches")` (diameter and result in the tool's own unit):

| Tool unit | Diameter | Shank |
|---|---|---|
| inch | D <= 1/8" | 1/8" |
| inch | 1/8" < D < 1/4" | 1/4" |
| inch | D >= 1/4" | D |
| mm | D <= 3 mm | 4 mm |
| mm | 3 mm < D < 6 mm | 6 mm |
| mm | D >= 6 mm | D |

All tools are assumed to taper from the shank diameter to the cutting diameter (the existing assumed-taper logic in
`toolwiz_common/tool_profile.py`). `shank_looks_wrong(diameter, shank, unit)` is true when the shank is smaller than the
rule's shank. `tool_library_curator.py` proposes the rule's shank (and writes the continuous taper segments) for such
flat, ball, bull-nose and radius end mills, and `library_audit.py` reports them as CAUTION `shank_suspect` with the
proposed value. Web requests (`/api/calculate`) carry no tool kind, so they keep the original check (a tool under 1/8"
whose shank equals its diameter) for the on-page warning.

In the owner's library (`Offworldgear_TI_Steel1_Updated4_20261019_125408_v6.json`) two tools are flagged: index 2 and
index 12, both "1/16" Flat Endmill" with a 0.0625" shank (proposed 0.125"). The other two libraries in
`data/shop_library/` have none.
