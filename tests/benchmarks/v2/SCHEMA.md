# v2 benchmark dataset: row schema

Design reference: `docs/PHYSICS_MODEL_DESIGN.md` §4.2. One file per vendor (`harvey.json`, `helical.json`, `osg.json`, `sandvik.json`, `kennametal.json`). These rows calibrate and validate the v2 model. They are never model inputs.

## Rules

- Every row quotes the exact published cells (`source.cells`). If a value is computed (for example, axial depth from "3×D"), keep the published form in `published` and the computed inch value next to it.
- Lengths are in inches and speeds in SFM. A metric source keeps its original values in `published` and the converted values in the numeric fields.
- Tool geometry comes from the vendor's catalog page for that part number, not from the chart. If a field isn't published, set it to `null` and list it in `missing`. Never guess.
- A chart that covers a range of tools (by diameter column) becomes one row per diameter column used, each with a real part number from that series.
- `vendor_group` is the parent company. Harvey Tool and Helical Solutions are both Harvey Performance, so they count as one source when counting the two independent vendors a cell needs.
- Print every caveat on the sheet in `vendor_notes`, such as "chip loads are for uncoated tools; coated +10–20%".
- `read_method` is `text` (pdftotext or HTML) or `image` (read from a rendered page only). Image-only rows are flagged for a second check.
- `source.derivation` (optional) is required when a value is not read straight from a cell but comes from applying the vendor's own printed rule to published cells (for example "slot IPT = side IPT x 0.8", or the vendor's Ae/D adjustment factors). It states the rule. Calibration can weight or exclude these rows. Unit conversions and rpm-to-SFM arithmetic are not derivations; put them in `notes`.

## File layout

```json
{
  "vendor": "Harvey Tool",
  "vendor_group": "Harvey Performance",
  "documents": [
    {
      "doc_id": "SF_73000",
      "title": "Speeds & Feeds: 4 flute stub and standard square end mills",
      "url": "https://...",
      "date_accessed": "2026-10-15",
      "revision": "printed revision or date, or null"
    }
  ],
  "rows": [ { "...": "see below" } ]
}
```

## Row

```json
{
  "id": "harvey_SF73000_toolsteel_29-37_rough_0.0625",
  "source": {
    "doc_id": "SF_73000",
    "page": 1,
    "table": "Tool Steels D/H/M/T/S, 29-37 HRC",
    "row_label": "Roughing",
    "column_label": "0.062",
    "cells": "SFM 150; Chip load .00010; ADOC 3 x Dia; RDOC .25 x Dia",
    "read_method": "text",
    "derivation": "optional; see Rules"
  },
  "tool": {
    "part_number": "73062",
    "series": "73000",
    "tool_material": "carbide",
    "coating": "uncoated",
    "flutes": 4,
    "end": "square",
    "corner_radius": 0.0,
    "helix_deg": 30,
    "variable_pitch": false,
    "DC": 0.0625,
    "LCF": 0.1875,
    "neck_diameter": null,
    "LB": null,
    "SFDM": 0.125,
    "OAL": 1.5,
    "geometry_url": "https://...",
    "missing": ["neck_diameter", "LB"]
  },
  "material": {
    "vendor_label": "Tool Steels D/H/M/T/S",
    "hardness": {"min": 29, "max": 37, "scale": "HRC"},
    "toolwiz_family": "Steel - Tool (H13)",
    "representative_alloy": "H13"
  },
  "operation": "slot | side | rough | hem | finish",
  "cut": {
    "ap": 0.1875,
    "ae": 0.0156,
    "sfm": {"min": null, "max": null, "nominal": 150},
    "fz": {"min": null, "max": null, "nominal": 0.0001},
    "published": {"ap": "3 x Dia", "ae": ".25 x Dia"}
  },
  "vendor_notes": ["Chip loads are for uncoated cutters; coated may run 10-20% higher"],
  "notes": "free text: anything a later reader needs"
}
```

`operation` values:
- `slot`: full-width slot.
- `side`: conventional side milling or profiling at the vendor's stated radial depth.
- `rough`: the vendor's "roughing" column when it isn't a HEM/adaptive recommendation.
- `hem`: the vendor's HEM, dynamic or trochoidal recommendation.
- `finish`: a finishing pass.

`toolwiz_family` is one of the 31 GWizard family names in `gwizard_materials.db` (`material_families.name`), for example `Stainless - PH Series (17-4)`.
