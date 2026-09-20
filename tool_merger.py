"""
ToolWiz Tool Merger & Deduplication Engine
===========================================
Intelligently merges, deduplicates, and manages Fusion 360 tool libraries.
Supports multi-library consolidation, canonical geometric signatures,
preset preservation, per-tool aggressiveness overrides, and stale preset cleanup.
"""

import json
import re
import uuid
from typing import Dict, List, Tuple, Any, Optional

def parse_dimension_in(val: Any, unit: str = "") -> float:
    """Normalizes any dimension (float, int, or string with units) into inches."""
    if val is None:
        return 0.25
    if isinstance(val, (int, float)):
        u = str(unit).strip().lower()
        if u in ["inches", "in", "inch"]:
            return float(val)
        elif u in ["millimeters", "mm", "millimeter"]:
            return float(val) / 25.4
        else:
            # Fallback heuristic: values > 1.5 in default metric context are likely mm
            return float(val) / 25.4 if float(val) > 1.5 else float(val)
    if isinstance(val, str):
        v = val.strip().lower()
        has_in = "in" in v
        has_mm = "mm" in v
        if has_in:
            v = v.replace("in", "").strip()
        elif has_mm:
            v = v.replace("mm", "").strip()

        if "/" in v:
            try:
                n, d = v.split("/")
                f = float(n) / float(d)
                u = str(unit).strip().lower()
                if has_mm or u in ["millimeters", "mm", "millimeter"]:
                    return f / 25.4
                return f
            except Exception:
                return 0.25

        try:
            f = float(v)
            u = str(unit).strip().lower()
            if has_mm or u in ["millimeters", "mm", "millimeter"]:
                return f / 25.4
            elif has_in or u in ["inches", "in", "inch"]:
                return f
            return f / 25.4 if f > 1.5 else f
        except Exception:
            return 0.25
    return 0.25


def compute_tool_signature(tool: Any) -> str:
    """
    Computes a canonical physical geometry signature for a tool dictionary or JSON string.
    Tools with identical signatures are physically identical cutters on the shop floor.
    Signature components:
      - Normalized tool type
      - Diameter (DC) in inches rounded to 0.0001" (0.1 thou)
      - Flute count (NOF)
      - Flute length (LCF) in inches rounded to 0.001" (1 thou)
      - Corner radius (RE) in inches rounded to 0.0001"
      - Shank diameter (SF) in inches rounded to 0.001"
      - Vendor Product ID / Order Code (if present)
    """
    t_dict = json.loads(tool) if isinstance(tool, str) else tool
    if not isinstance(t_dict, dict):
        return str(uuid.uuid4())

    # Check vendor product ID first; if explicitly matching, strong indicator
    prod_id = str(t_dict.get("product-id", "")).strip().lower()
    vendor = str(t_dict.get("vendor", "")).strip().lower()
    
    geo = t_dict.get("geometry", {})
    tool_unit = str(t_dict.get("unit", geo.get("unit", ""))).strip().lower()
    tool_type = str(geo.get("type", t_dict.get("type", "end mill"))).strip().lower()

    # Normalize tool type synonyms
    if "flat" in tool_type or tool_type == "end mill":
        norm_type = "flat_endmill"
    elif "ball" in tool_type:
        norm_type = "ball_endmill"
    elif "bull" in tool_type or "radius" in tool_type:
        norm_type = "bullnose_endmill"
    elif "drill" in tool_type:
        norm_type = "drill"
    elif "tap" in tool_type:
        norm_type = "tap"
    elif "thread" in tool_type:
        norm_type = "thread_mill"
    elif "chamfer" in tool_type or "engrav" in tool_type:
        norm_type = "chamfer_mill"
    elif "slot" in tool_type or "t-slot" in tool_type or "woodruff" in tool_type:
        norm_type = "slot_mill"
    else:
        norm_type = tool_type.replace(" ", "_")

    dc_in = round(parse_dimension_in(geo.get("DC", 0.25), tool_unit), 4)
    nof = int(geo.get("NOF", 4))
    lcf_in = round(parse_dimension_in(geo.get("LCF", 0.75), tool_unit), 3)
    re_in = round(parse_dimension_in(geo.get("RE", 0.0), tool_unit), 4)
    sf_in = round(parse_dimension_in(geo.get("SF", dc_in), tool_unit), 3)

    if prod_id and len(prod_id) > 2:
        return f"id:{vendor}:{prod_id}|{norm_type}|dia:{dc_in:.4f}|fl:{nof}|lcf:{lcf_in:.3f}|re:{re_in:.4f}"

    return f"geo:{norm_type}|dia:{dc_in:.4f}|fl:{nof}|lcf:{lcf_in:.3f}|re:{re_in:.4f}|sf:{sf_in:.3f}"


def normalize_preset_key(preset: Dict[str, Any]) -> str:
    """Creates a normalized comparison key for a cutting preset to prevent duplicate presets."""
    name = str(preset.get("name", "")).strip().lower()
    mat_query = str(preset.get("material", {}).get("query", "")).strip().lower() if isinstance(preset.get("material"), dict) else ""
    return f"{name}|{mat_query}"


def merge_presets_lists(primary_presets: List[Dict[str, Any]], secondary_presets: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Merges presets from two tools without duplicating identical operations/materials.
    Preserves all unique presets, preferring presets with rich feeds/speeds.
    """
    merged_map: Dict[str, Dict[str, Any]] = {}

    for p in primary_presets:
        key = normalize_preset_key(p)
        merged_map[key] = dict(p)

    for p in secondary_presets:
        key = normalize_preset_key(p)
        if key not in merged_map:
            merged_map[key] = dict(p)
        else:
            # If the secondary preset has non-zero feeds/speeds and primary had zeros/defaults, update
            existing = merged_map[key]
            existing_vf = float(str(existing.get("v_f", "0")).replace("in/min", "").replace("mm/min", "") or 0)
            incoming_vf = float(str(p.get("v_f", "0")).replace("in/min", "").replace("mm/min", "") or 0)
            if incoming_vf > 0 and existing_vf == 0:
                merged_map[key] = dict(p)

    return list(merged_map.values())


def select_best_tool_metadata(tools_group: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Given a list of duplicate tool representations, selects the best base definition
    (preferring valid tool numbers > 0, descriptive names, and holder info).
    """
    def score_tool(t: Dict[str, Any]) -> int:
        score = 0
        desc = t.get("description", "")
        if desc and "unnamed" not in desc.lower() and "tool" not in desc.lower():
            score += 20
        num = t.get("postProcess", {}).get("number", t.get("post-process", {}).get("number", 0))
        if num and int(num) > 0:
            score += 15
        if t.get("holder"):
            score += 10
        if t.get("vendor"):
            score += 5
        if t.get("product-id"):
            score += 5
        presets = t.get("start-values", {}).get("presets", [])
        score += len(presets)
        return score

    best_tool = dict(max(tools_group, key=score_tool))
    return best_tool


def deduplicate_tools(tools_list: List[Any], preserve_presets: bool = True) -> Tuple[List[Dict[str, Any]], Dict[str, Any]]:
    """
    Deduplicates a list of tools based on physical geometry signatures.
    Combines presets from duplicate copies into one master tool.
    
    Returns:
        (deduplicated_tools_list, summary_report)
    """
    groups: Dict[str, List[Dict[str, Any]]] = {}
    order: List[str] = []

    for raw_t in tools_list:
        t_dict = json.loads(raw_t) if isinstance(raw_t, str) else dict(raw_t)
        if t_dict.get("type") == "holder":
            continue
        sig = compute_tool_signature(t_dict)
        if sig not in groups:
            groups[sig] = []
            order.append(sig)
        groups[sig].append(t_dict)

    master_tools: List[Dict[str, Any]] = []
    total_duplicates_found = 0
    total_presets_consolidated = 0
    merged_details: List[Dict[str, Any]] = []

    for sig in order:
        group = groups[sig]
        if len(group) == 1:
            master_tools.append(group[0])
        else:
            total_duplicates_found += (len(group) - 1)
            master_tool = select_best_tool_metadata(group)

            all_presets: List[Dict[str, Any]] = []
            for t in group:
                presets = t.get("start-values", {}).get("presets", [])
                all_presets = merge_presets_lists(all_presets, presets) if preserve_presets else master_tool.get("start-values", {}).get("presets", [])

            if "start-values" not in master_tool:
                master_tool["start-values"] = {}
            master_tool["start-values"]["presets"] = all_presets

            # Merge any custom aggressiveness override
            for t in group:
                if "custom_aggressiveness" in t and t["custom_aggressiveness"] is not None:
                    master_tool["custom_aggressiveness"] = t["custom_aggressiveness"]
                    break

            total_presets_consolidated += len(all_presets)
            master_tools.append(master_tool)

            desc = master_tool.get("description", "Tool")
            t_num = master_tool.get("postProcess", {}).get("number", master_tool.get("post-process", {}).get("number", 0))
            merged_details.append({
                "signature": sig,
                "description": desc,
                "tool_number": t_num,
                "copies_merged": len(group),
                "total_presets": len(all_presets)
            })

    report = {
        "initial_tool_count": len(tools_list),
        "unique_tools_count": len(master_tools),
        "duplicates_removed": total_duplicates_found,
        "merged_details": merged_details
    }

    return master_tools, report


def merge_multiple_libraries(
    libraries: List[Dict[str, Any]],
    master_library_name: str = "Master_Shop_Tool_Crib",
    deduplicate: bool = True
) -> Tuple[Dict[str, Any], Dict[str, Any]]:
    """
    Merges multiple library dictionaries (each with 'library_name' and 'tools') into
    a single master tool library with optional geometry deduplication.
    
    Returns:
        (master_library_dict, merge_summary)
    """
    combined_tools: List[Any] = []
    source_summary = []

    for lib in libraries:
        name = lib.get("library_name", lib.get("name", "Library"))
        raw_tools = lib.get("tools", [])
        if not raw_tools and "data" in lib:
            raw_tools = lib.get("data", [])
        elif not raw_tools and "library" in lib:
            inner = lib.get("library", {})
            if isinstance(inner, dict):
                raw_tools = inner.get("tools", inner.get("data", []))
            elif isinstance(inner, list):
                raw_tools = inner
        combined_tools.extend(raw_tools)
        source_summary.append({
            "name": name,
            "tools_count": len(raw_tools)
        })

    if deduplicate:
        final_tools, dedup_report = deduplicate_tools(combined_tools, preserve_presets=True)
    else:
        final_tools = [json.loads(t) if isinstance(t, str) else t for t in combined_tools]
        dedup_report = {
            "initial_tool_count": len(combined_tools),
            "unique_tools_count": len(final_tools),
            "duplicates_removed": 0,
            "merged_details": []
        }

    master_library = {
        "library_name": master_library_name,
        "tools": final_tools,
        "source_libraries": source_summary
    }

    summary = {
        "master_library_name": master_library_name,
        "sources": source_summary,
        "total_incoming_tools": len(combined_tools),
        "final_tool_count": len(final_tools),
        "duplicates_removed": dedup_report["duplicates_removed"],
        "merged_details": dedup_report["merged_details"]
    }

    return master_library, summary


def clean_tool_presets(
    tool_dict: Dict[str, Any],
    clean_all_non_toolwiz: bool = False,
    target_material_to_replace: Optional[str] = None
) -> Tuple[Dict[str, Any], int]:
    """
    Cleans unwanted presets from a tool dictionary:
    - If target_material_to_replace is given, removes existing presets for that specific material
      so new ToolWiz presets don't pile up as duplicates.
    - If clean_all_non_toolwiz is True, removes old default presets lacking ToolWiz metadata.
    
    Returns:
        (updated_tool_dict, presets_removed_count)
    """
    if "start-values" not in tool_dict or "presets" not in tool_dict["start-values"]:
        return tool_dict, 0

    presets = tool_dict["start-values"]["presets"]
    original_count = len(presets)
    filtered_presets = []

    for p in presets:
        p_name = str(p.get("name", "")).strip().lower()
        p_desc = str(p.get("description", "")).strip().lower()
        mat_query = ""
        if isinstance(p.get("material"), dict):
            mat_query = str(p["material"].get("query", "")).strip().lower()

        # If matching target material to replace:
        if target_material_to_replace:
            target_norm = target_material_to_replace.strip().lower()
            if target_norm in p_name or target_norm in mat_query:
                continue

        # If removing non-ToolWiz presets:
        if clean_all_non_toolwiz:
            # ToolWiz presets have structured hyphenated names like "{Material} - {Strategy}"
            # or stepdown and stepover populated
            is_generic_default = p_name in ["default preset", "preset", "unnamed preset", "default"]
            if is_generic_default:
                continue

        filtered_presets.append(p)

    tool_dict["start-values"]["presets"] = filtered_presets
    return tool_dict, (original_count - len(filtered_presets))
