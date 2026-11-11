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

from toolwiz_common import to_inches, tool_unit as _tool_unit, UnitError

def parse_dimension_in(val: Any, unit: str = "") -> float:
    """Normalizes a dimension (number, or string with optional unit suffix) into inches.

    Deterministic: raises toolwiz_common.UnitError if the unit cannot be determined
    (no magnitude heuristics).
    """
    return to_inches(val, unit)


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
    if not isinstance(geo, dict):
        geo = {}
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

    try:
        unit = _tool_unit(t_dict)
        dc_in = round(to_inches(geo.get("DC", 0.25), unit), 4)
        nof = int(geo.get("NOF", 4))
        lcf_in = round(to_inches(geo.get("LCF", 0.75), unit), 3)
        re_in = round(to_inches(geo.get("RE", 0.0), unit), 4)
        sfdm = geo.get("SFDM")
        if sfdm in (None, ""):
            sfdm = geo.get("SF", geo.get("DC", 0.25))
        sf_in = round(to_inches(sfdm, unit), 3)
    except (UnitError, ValueError, TypeError):
        # Unit or dimensions unknown: never guess; make the signature unique so it is never merged.
        return "nosig:" + str(uuid.uuid4())

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
    Preserves holder objects and prevents merging distinct positive tool numbers or holders.
    
    Returns:
        (deduplicated_tools_list, summary_report)
    """
    def _get_t_num(t: dict) -> int:
        post = t.get("post-process") or t.get("postProcess") or {}
        if isinstance(post, dict) and post.get("number") is not None:
            try:
                val = int(post.get("number"))
                return val if val > 0 else 0
            except:
                pass
        return 0

    def _get_holder_id(t: dict) -> str:
        h = t.get("holder", {})
        if isinstance(h, dict):
            return str(h.get("guid") or h.get("description") or "").strip()
        return str(h).strip()

    holders: List[Dict[str, Any]] = []
    clusters: List[List[Dict[str, Any]]] = []

    for raw_t in tools_list:
        t_dict = json.loads(raw_t) if isinstance(raw_t, str) else dict(raw_t)
        if t_dict.get("type") == "holder":
            holders.append(t_dict)
            continue

        sig = compute_tool_signature(t_dict)
        t_num = _get_t_num(t_dict)
        h_id = _get_holder_id(t_dict)

        # Find existing cluster with identical signature where can_merge is True
        matched_cluster = None
        for cluster in clusters:
            first_t = cluster[0]
            if compute_tool_signature(first_t) == sig:
                # Check compatibility with all members in cluster
                can_merge = True
                for member in cluster:
                    m_num = _get_t_num(member)
                    m_hid = _get_holder_id(member)
                    if t_num > 0 and m_num > 0 and t_num != m_num:
                        can_merge = False
                        break
                    if h_id and m_hid and h_id != m_hid:
                        can_merge = False
                        break
                if can_merge:
                    matched_cluster = cluster
                    break

        if matched_cluster is not None:
            matched_cluster.append(t_dict)
        else:
            clusters.append([t_dict])

    master_tools: List[Dict[str, Any]] = []
    total_duplicates_found = 0
    total_presets_consolidated = 0
    merged_details: List[Dict[str, Any]] = []

    for group in clusters:
        sig = compute_tool_signature(group[0])
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

    # Append preserved holder objects back into master_tools
    master_tools.extend(holders)

    report = {
        "initial_tool_count": len(tools_list),
        "unique_tools_count": len(master_tools),
        "duplicates_removed": total_duplicates_found,
        "holders_preserved": len(holders),
        "merged_details": merged_details
    }

    return master_tools, report


def merge_multiple_libraries(
    libraries: List[Dict[str, Any]],
    master_library_name: str = "Master_Shop_Tool_Crib",
    deduplicate: bool = False
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
