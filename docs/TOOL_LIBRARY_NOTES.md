# Tool library (Digital Twin) review and the master library builder

WP-B5. The master library builder extends the existing Digital Twin feature (`/api/twin/*`, `tool_merger.py`,
`backup_manager.py`, `tool_library_curator.py`, `toolwiz_common/tool_strategy.py`, `library_audit.py`) rather than
adding a parallel one. This note lists what the review of that backend found and what was changed, then the new API.

## 1. Defects found in the existing feature, and what was done

| # | Where | Defect | Fix |
|---|---|---|---|
| 1 | `tool_merger.compute_tool_signature` | Form-defining fields were not in the signature: two chamfer mills (30 vs 45 deg), drills with different point angles, taps of different pitch, left/right-hand tools merged into one tool on dedupe (data loss). `"tap" in "tapered mill"` signed tapered mills as taps; `"drill"` matched spot, center and twist drills alike. A missing DC defaulted to 0.25 in, a missing NOF to 4, so unrelated broken tools merged. | Exact Fusion types are classified first (`classify`); `TA`, `SIG`, `tip-diameter`, `TP`, left hand are added to the signature when present (plain end mills keep their short signature); a tool with no DC gets a unique signature (never merged). |
| 2 | `tool_merger.merge_presets_lists` | Presets were keyed by name + material query in a dict: two same-named presets inside one tool collapsed to one, and a same-named preset from a copy with other numbers was silently dropped. `float(str(v_f).replace("in/min", ""))` raised on values such as `"60 ipm"` and aborted the whole dedupe. | Every primary preset is kept; a secondary one is dropped only when name, material and numbers match; a same-name different-numbers preset is kept as `Name (2)` with a new guid; feeds are parsed safely. Merged presets are deep copies (the old code wrote the merged list into the input tool's nested dict). |
| 3 | `tool_merger.clean_tool_presets` | `target in preset_name or target in material_query`: substring match. Replacing material `304` deleted the owner's own `6304 steel ...` presets. | The preset's material (query, `Material - ` name prefix or `toolwiz.material`) must equal the target. |
| 4 | `tool_merger.select_best_tool_metadata` / `score_tool` | `int(number)` raised on a non-numeric tool number; the "best" tool was a shallow copy. | Safe parse, deep copy. |
| 5 | `tool_library_curator.curate_tool_dict` | A tool with no unit was silently given `"inches"` and then repaired in those units, against the rule that units are never guessed (a metric tool would be scaled wrongly by 25.4). | The tool is returned unchanged with a warning. |
| 6 | `backup_manager.create_backup` | The `_vN` suffix was `len(existing) + 1`. Once pruning keeps 15 files every new backup is `_v16` (the shop library files are named `_v16`), so version numbers repeat. | Next version is the highest on disk plus one. |
| 7 | `app.py` tool addressing | `update_tool`, `delete_tool`, `delete_preset`, `batch_generate` and `GET /api/twin/tool/<index>` address tools by list index; after one delete every later index points at another tool, so the page edits or deletes the wrong tool. Tools with an empty or duplicate guid could not be addressed at all. | `tool_guid` (and `tool_guids`, and guid keys in `tool_aggressiveness_map`) are accepted and win over `tool_index`; `GET /api/twin/tool?guid=`; `/api/twin/load` returns `guid`; every save from export / upload / dedupe gives each tool a unique non-empty guid. Indices still work. |
| 8 | `delete_preset`, `delete_tool`, `update_tool` | `delete_preset` answered 200 with `success: false` for a missing tool or preset, and an empty `preset_guid` matched every preset without a guid. `update_tool` with `number` created a second `postProcess` key next to Fusion's `post-process`. | 404 / 400 with proper messages; empty preset guid refused; the Fusion key `post-process` is updated, no stray key. |
| 9 | `export_receive` | A harvest that found 0 tools (add-in failure) replaced the working library with an empty one. | 400, working library untouched. |
| 10 | `batch_generate` | (a) An existing preset of the same name was updated with `dict.update`: a Fusion preset that has an `expressions` block keeps it, and Fusion evaluates the expressions, so the new numbers were ignored on import. (b) The owner's own preset with the same name was overwritten. (c) `int(aggressiveness * 100)` truncated (29% -> 28%). (d) Presets were never marked as ToolWiz's, so "clean for material" could only guess. (e) A boring bar got a drilling preset; reamers were named `Drilling`. (f) The preset numbers were unrounded floats (`0.48000000000000004`). | (a) the preset is replaced whole (guid kept); (b) only presets ToolWiz wrote (tagged, or an older one with an `operation_type`) are replaced, the owner's is kept and ours is named `... (ToolWiz)`; (c) rounded; (d) every generated preset carries a `toolwiz` tag; (e) boring bars skipped, reamers named `Reaming`; (f) values rounded (rpm int, v_c 2 dp, f_z 6 dp, feeds 3 dp, depths 4-5 dp). |
| 11 | `/api/twin/load` | Preset numbers named `sfm`, `ipt`, `feed` are in the tool's unit (m/min and mm for a metric tool). The page converts them itself, so they were left as they are; `unit` and the `toolwiz` tag were added to each preset row and `is_toolwiz` now uses the tag. | Documented; `unit` added. |

Not changed (judgement calls): `merge_multiple_libraries` still keeps every tool when `deduplicate` is false; the
working library is still a read-modify-write file without a lock (single user, one request at a time in practice);
`list_backups` still opens every backup file.

## 2. Material sets

`data/material_sets.json` ships the two default sets; `GET /api/twin/material_sets` returns the user's edited copy
(`<TOOLWIZ_DATA_DIR>/data/material_sets.json`) or the defaults, `POST` validates and saves, `{"reset": true}` returns
to the defaults. A material is `{id, label, family, alloy, note}`: `family` is a family of
`materials_database_clean.json` (a key of `physics.machinability`), `alloy` is a string that
`GWizardPhysics.match_alloy` resolves to one `specific_alloys` row of that family (verified for every default;
`resolve_alloy_hardness` in brackets), `label` is the short name used in preset names and in the Fusion material query.

| Set | id | Family | Alloy string -> row (HB) |
|---|---|---|---|
| Non-ferrous | al6061 | Aluminum - Wrought (6061) | `6061-T6` -> 6061 T6, T651 (95) |
| | al7075 | Aluminum - Wrought (6061) | `7075-T6` -> 7075 T6, T651 (150) |
| | brass_c36000 | Brass | C36000 Free-Cutting Brass H02 Temper (143) |
| | bronze_c54400 | Copper Alloy - Wrought | C54400 Phosphor Bronze Hard (140) |
| | bronze_c63000 | Copper Alloy - Wrought | C63000 Nickel-Aluminum Bronze HR50 (208) |
| | copper_c11000 | Copper Alloy - Wrought | C11000 ETP Copper Hard (80) |
| Steels & exotics | s4140_prehard | Steel - Medium Carbon Alloy (4130) | 4140 normalized (302, about 32 HRC) |
| | ss304 / ss316 | Stainless - 300 Series (316) | 304 / 316 Austenitic Annealed (150) |
| | ph174 | Stainless - PH Series (17-4) | 17-4 PH H 1150 (330) |
| | ti64 | Titanium Alloy | Ti-6Al-4V (Grade 5) Annealed (334) |
| | zr702 | Zirconium 702 (Commercially Pure) | family level: the database has no `specific_alloys` row for zirconium 702 (only machinability / speed / chip-load tables, 150-180 BHN) |
| | tool_steel_hard | Steel - Tool (H13) | D-2 Hardened + Tempered 1000 (577, about 54 HRC) |
| | magnacut_ann / magnacut_hard | Steel - Tool (H13) | CPM MagnaCut Annealed ~22 HRC (200) / Hardened ~62 HRC (688) |
| | black_ti_5545 | Black Titanium 5545 | Black Titanium 5545 (316) |

4140 "pre-hard ~30 HRC" is the `normalized` row because 4140 HT (321 HB) and oil quenched (311 HB) are harder.
304 and 316 have the same database hardness, so their presets are identical (the audit lists that as a
`duplicate_preset` CAUTION).

## 3. Master library builder

`master_library.py` (pure functions) and `routes_master_library.py` (blueprint, one registration line in `app.py`).

* **Merge** (`merge_libraries`). Input `{"libraries": [{"library_name", "source": "document|hub|cloud|local|upload", "tools": [...]}]}`
  (tools as dicts or JSON strings). 1. The curator's safe geometry repairs run first (shank of micro tools, missing LCF / LB /
  shoulder / OAL, shaft taper; no coating or corner-radius inference, no unit guessing) and are reported. 2. Tools are grouped by
  `compute_tool_signature`. 3. Inside a group, tools whose effective stickout (LB, else assembly gauge, else default), assembly
  gauge or holder gauge differ by more than 10% (relative to the larger) stay separate and are named
  `<description> [stickout 1.500 in]`; the others merge: best tool as base, presets are the union (see defect 2), custom
  aggressiveness and holder kept. Every merged tool has `toolwiz.provenance` = `[{library, source, guid, number}]` and
  `toolwiz.libraries`. Holders are kept once (by guid or description). Guids are made unique.
* **Preset generation** (`generate_presets(tool, materials, strategies, aggressiveness, ...)`): the single implementation, also
  used by `/api/twin/batch_generate`. It runs `pipeline.run_cut` with the Fusion tool dict as `fusion_tool` (real diameter, flutes,
  flute length, shank, neck, stickout), asks `toolwiz_common.tool_strategy.plan_strategies` which presets apply (T-slot presets for
  slot mills, one hole preset for drills / taps / reamers, none for other form tools), and writes the values in the tool's own unit
  (inch tool: ft/min, in/tooth, in/min, inches; mm tool: m/min, mm/tooth, mm/min, mm). Pipeline results are cached per (tool
  geometry hash, stickout, material, strategy, aggressiveness, model, runout, limits, coating) in a job-wide dict.
* **Tag**: every generated preset has `"toolwiz": {"generator": "toolwiz-master-library", "version", "material", "material_id",
  "family", "alloy", "strategy", "aggressiveness" (percent), "model", "runout_in", "stickout_in", "date"}`. A rebuild strips
  exactly the presets that have this object and keeps all others byte for byte. If a generated name equals one of the owner's
  preset names it becomes `<name> (ToolWiz)`.
* **Names**: `<Material label> - <Strategy>` (`6061-T6 - Roughing`, `Ti-6Al-4V - T-Slot Full Slot`, `Brass C36000 - Drilling`);
  description: `<name> (Aggressiveness: 50%, stickout 21.00 mm, runout 0.005 mm, model v1)`.
* **Audit** (`audit_and_prune`): `library_audit.audit_library` runs on each built library. A STOP finding on a ToolWiz preset drops
  that preset and is reported (`audit.dropped_presets` with code and message). The returned summary counts what remains
  (`toolwiz_STOP` is 0 by construction, it is not re-audited). By default only the ToolWiz presets are audited (the owner's
  presets are not ours to fix, and auditing them about doubles the time with the v2 model); `"audit_owner_presets": true`
  audits everything and lists STOP findings on the owner's own presets in `owner_preset_stop_findings` (never touched).
  The audit compares chip load with the ToolWiz value for the preset's material family, so an exotic alloy whose audit
  family is coarser (Black Ti 5545 audits as "Titanium Alloy") can be dropped when its chip load is more than twice that
  family value; the drop is reported with the numbers.

### Endpoints

```
GET  /api/twin/material_sets                      -> {"success", "source": "default|user", "material_sets": {"sets": [...]}}
POST /api/twin/material_sets   {"material_sets": {...}} | {"reset": true}     400 {"errors": [...]} on an unresolvable alloy
POST /api/twin/master_library/merge               merge only; {"libraries": [...], "save_working": true?, "repair": true?, "deduplicate": true?}
POST /api/twin/build_sets                         start a job            -> 202 {"job_id", "tools", "sets", "status_url"}
GET  /api/twin/build_sets/<job_id>                progress / result
GET  /api/twin/build_sets/<job_id>/download?set=<set id or library name>     Fusion import JSON {"data": [...]}
```

`POST /api/twin/build_sets` body (every key optional; tools come from `libraries`, else from the working library):

```json
{"libraries": [{"library_name": "Main_Milling_Hub_Library", "source": "hub", "tools": [ ... ]}],
 "use_working_library": false,
 "filter": {"types": ["flat end mill", "slot mill"], "diameter_min": 3, "diameter_max": 12, "diameter_unit": "mm",
            "libraries": ["Main_Milling_Hub_Library"], "sources": ["hub"], "tool_ids": ["<guid>"]},
 "sets": ["non_ferrous"], "materials": ["al6061", "ti64"],
 "strategies": ["Adaptive Roughing", "Roughing", "Finishing", "Slotting"],
 "aggressiveness": 50, "runout": 0.0002, "maxRpm": 16000, "maxHp": 10, "model": "v1",
 "use_tool_overrides": true, "repair": true, "deduplicate": true, "include_holders": true}
```

`GET /api/twin/build_sets/<id>` while running:

```json
{"success": true, "job_id": "c05ca0352e87", "state": "running", "phase": "generating",
 "progress": {"tools_done": 7, "tools_total": 22, "current_tool": "1/4 Flat Endmill", "percent": 31.8},
 "elapsed_s": 1.4, "request": {"sets": [...], "materials": [...], "strategies": [...], "aggressiveness": 50.0, "model": "v1", "tools": 22}}
```

When `state` is `done` it also carries:

```json
"result": {"merge": {"sources": [...], "tools_in": 27, "tools_out": 26, "duplicates_merged": 1, "holders": 1,
                      "repaired_tools": 9, "stickout_variants": [], "merged_details": [...], "repairs": [...], "unreadable": []},
           "libraries": [{"id": "non_ferrous", "name": "ToolWiz - Non-ferrous", "tool_count": 22, "holder_count": 1,
                          "preset_count": 599, "toolwiz_preset_count": 280, "previous_toolwiz_presets_replaced": 0,
                          "materials": ["6061-T6", "..."],
                          "audit": {"summary": {"STOP": 105, "CAUTION": 231, "INFO": 70, "tools": 22, "presets": 599, "toolwiz_STOP": 0},
                                    "cautions_by_code": {"chip_load_low": 69}, "dropped_presets": [],
                                    "owner_preset_stop_findings": [{"tool", "preset", "code", "message"}]},
                          "skipped": [{"tool", "number", "type", "material", "strategy", "reason"}],
                          "backup": {"filename": "ToolWiz-Nonferrous_20261111_120000_v1.json"},
                          "download_url": "/api/twin/build_sets/c05ca0352e87/download?set=non_ferrous"}],
           "timing": {"generate_s": 2.2, "total_s": 4.3}}
```

On `error`, `error` holds the message. 400 for: unknown set / material id, bad strategy, aggressiveness not in (0, 100],
negative runout, malformed filter, no tools (none sent and no working library, or the filter matches nothing; the message lists the
tool types present), libraries not a list of objects with a `tools` list. 404 unknown job or set, 409 download before the job is done.
Jobs live in memory (the last 20); each built library is also saved through `BackupManager` (`GET /api/twin/backups`) as
`{"library_name", "tools": [...], "toolwiz_build": {...}}`, so it can be restored as the working library.

### What the clients need

* **Add-in (WP-C1)**: harvest open documents, hub, cloud and local libraries into
  `{"libraries": [{"library_name", "source", "tools"}]}`, `POST /api/twin/build_sets`, poll the status URL, then for each entry of
  `result.libraries` `GET download_url` and import `{"data": [...]}` as a named library (`name`), replacing the library of that
  name on a rebuild. Tool `guid`s are kept for the base tool of a merged group; the merged tool lists the guids it replaced in
  `toolwiz.provenance`.
* **Web (WP-C2)**: `GET material_sets` for the pickers (edit with `POST`), `merge` for a sources preview (counts, stickout variants,
  repairs), `build_sets` + polling for progress, the per-library audit summary (`toolwiz_STOP`, `cautions_by_code`,
  `dropped_presets`, `owner_preset_stop_findings`), the skipped list, and the download links.
  Address tools by `guid` in every `/api/twin/*` call.
