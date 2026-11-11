# T-slot / keyseat / undercut cutter benchmark dataset: row schema

Extends `tests/benchmarks/v2/SCHEMA.md`. All v2 rules apply: exact published cells in `source.cells`, real part numbers with catalog geometry, `null` plus a `missing` entry for anything unpublished, never guess, one file per vendor, lengths in inches, speeds in SFM, `source.derivation` when a value comes from applying the vendor's own printed rule. These rows validate the T-slot / undercut model. They are never model inputs.

A separate folder is used because a side-cutting disc on a neck has geometry (cutter thickness, neck, faces) and operations (axial face cutting) that do not fit the end-mill row of v2.

## File layout

Same as v2: `{"vendor", "vendor_group", "documents": [...], "rows": [...]}`. Document entries carry `doc_id, title, url, date_accessed, revision`.

## Row

```json
{
  "id": "harvey_HAT2_970315_al_wrought_970362",
  "source": {"doc_id": "...", "page": 1, "table": "...", "row_label": "...", "column_label": "0.250",
             "cells": "SFM 1000; Chip Load (IPT) .00151; Radial .12 x Dia; Axial Full Width",
             "read_method": "text | image", "derivation": "optional"},
  "tool": {
    "part_number": "970362", "series": "9703xx",
    "style": "keyseat_type_I | keyseat_type_II | keyseat_reduced_shank_type_II | keyseat_hardened_steel | t_slot | t_slot_full_radius | t_slot_stagger | double_angle | undercut | back_chamfer | dovetail",
    "product_name": "catalog title",
    "tool_material": "carbide", "coating": "uncoated",
    "teeth": 4,
    "tooth_form": "straight | staggered | null",
    "cutting_faces": ["periphery", "bottom", "top"],
    "cutting_faces_basis": "why these faces (vendor statement), or 'inferred' with the evidence",
    "cutter_diameter": 0.25,
    "cutter_thickness": 0.062,
    "neck_diameter": 0.125,
    "neck_length": 0.375,
    "shank_diameter": 0.25,
    "OAL": 2.5,
    "corner_radius": 0.0,
    "corner_style": "square | corner_radius | full_radius | chamfer | tip_radius",
    "included_angle_deg": null,
    "max_radial_depth": 0.053,
    "geometry_url": "https://...",
    "missing": ["tooth_form"]
  },
  "material": {"vendor_label": "...", "hardness": {"min": null, "max": 28, "scale": "HRC"} , "toolwiz_family": "...", "representative_alloy": "6061"},
  "operation": "full_slot | side_cut | axial_face | double_face | deburr",
  "cut": {
    "faces_engaged": ["periphery", "bottom"],
    "sfm": {"min": null, "max": null, "nominal": 1000},
    "fz": {"min": null, "max": null, "nominal": 0.00151},
    "fz_basis": "what the chip load refers to (per tooth, one side engaged ...)",
    "ae_radial": {"min": null, "max": null, "nominal": 0.03},
    "ap_axial": {"min": null, "max": null, "nominal": 0.062},
    "axial_feed": {"min": null, "max": null, "nominal": null},
    "passes": {"min": null, "max": null, "nominal": null, "published": null},
    "adjustments": [{"condition": "...", "factor": {"min": 0.5, "max": 0.6}, "published": "...", "applies_to": "fz | ae_radial"}],
    "published": {"ae_radial": ".12 x Dia", "ap_axial": "Full Width"},
    "missing": ["axial_feed", "passes"]
  },
  "vendor_notes": ["every caveat printed on the sheet"],
  "notes": "free text"
}
```

## Field meanings

- `cutter_diameter` (DC), `cutter_thickness` (CW, the kerf / slot width the cutter makes), `neck_diameter` (the narrowed section behind the head; for a reduced-shank cutter with no separate neck figure it is `null` and listed in `missing`), `neck_length` (reach under the head), `shank_diameter`, `OAL`.
- `teeth`: number of flutes/teeth on the head. `tooth_form`: `straight` (all teeth cut the full width) or `staggered` (alternate teeth, one side then the other; vendors say "stagger tooth"). `null` + `missing` when the vendor does not publish it.
- `cutting_faces`: which faces of the head have cutting edges: `periphery` (outer diameter), `bottom` (face toward the shank is the "top"; the face away from the shank is the "bottom"), `top`. A "double-sided" cutter that can cut while moving both up and down in Z has both `bottom` and `top`. `cutting_faces_basis` states the vendor evidence; when it is an inference from the catalog application list it says so.
- `max_radial_depth`: the catalog's own maximum radial depth of cut for the part (distinct from the per-pass `ae_radial`).
- `operation`:
  - `full_slot`: the whole cutter thickness is engaged and the cutter plunges or traverses radially (keyseat or T-slot cut).
  - `side_cut`: partial-width (one-sided or wall) cutting or profiling with the periphery.
  - `axial_face`: cutting with one face while moving in Z (back chamfer, undercut face cut, widening).
  - `double_face`: both faces engaged (V-groove, double-sided cutting while moving up and down).
  - `deburr`: edge break.
- `cut.faces_engaged`: faces that the published datum assumes are cutting.
- `cut.ae_radial`: radial depth per pass in inches (the depth the cutter goes into the wall per pass). If the vendor prints a multiple of diameter, keep the printed form in `cut.published` and the computed inch value here. `cut.ap_axial`: axial (along the neck) extent engaged, usually the cutter thickness ("Full Width").
- `cut.axial_feed`: feed or chip load for axial (Z) cutting with a face, when published; otherwise all null and `axial_feed` in `cut.missing`.
- `cut.passes`: the vendor's number-of-passes guidance, when printed.
- `cut.adjustments`: printed multipliers that change the posted value (both-sides engagement, neck-length ratio, flute count). The posted `fz.nominal` is not multiplied by them.
- `cut.missing` lists which of `ae_radial`, `ap_axial`, `axial_feed`, `passes` are unpublished (all-null).
- `tool.missing` lists any null tool field (other than optional `included_angle_deg` and `max_radial_depth`, which are only required to appear in `missing` when the style normally publishes them).

## Material mapping

`material.toolwiz_family` must exist in `materials_database_clean.json` (`material_families`), same as v2.
