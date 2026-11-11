"""
ToolWiz Tool Merger & Deduplication Engine
===========================================
Intelligently merges, deduplicates, and manages Fusion 360 tool libraries.
Supports multi-library consolidation, canonical geometric signatures,
preset preservation, per-tool aggressiveness overrides, and stale preset cleanup.
"""

import copy
import json
import re
import uuid
from typing import Dict, List, Tuple, Any, Optional

from toolwiz_common import to_inches, tool_unit as _tool_unit, UnitError, ToolKind, classify

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

    # Normalize tool type. Exact Fusion types are classified first (a substring test would read "tapered mill"
    # as a tap and "spot drill" as a twist drill); free text falls back to keyword matching.
    kind = classify(geo.get("type", t_dict.get("type")))
    _KIND_NAMES = {ToolKind.FLAT: "flat_endmill", ToolKind.BALL: "ball_endmill", ToolKind.BULL: "bullnose_endmill",
                   ToolKind.RADIUS: "bullnose_endmill", ToolKind.DRILL: "drill", ToolKind.TAP: "tap",
                   ToolKind.THREAD_MILL: "thread_mill", ToolKind.CHAMFER: "chamfer_mill",
                   ToolKind.SLOT: "slot_mill"}
    if kind in _KIND_NAMES:
        norm_type = _KIND_NAMES[kind]
    elif kind is not ToolKind.UNKNOWN:
        norm_type = kind.value
    elif "flat" in tool_type or tool_type == "end mill":
        norm_type = "flat_endmill"
    elif "ball" in tool_type:
        norm_type = "ball_endmill"
    elif "bull" in tool_type or "radius" in tool_type:
        norm_type = "bullnose_endmill"
    elif "drill" in tool_type:
        norm_type = "drill"
    elif "thread" in tool_type:
        norm_type = "thread_mill"
    elif re.search(r"\btap\b", tool_type):
        norm_type = "tap"
    elif "chamfer" in tool_type or "engrav" in tool_type:
        norm_type = "chamfer_mill"
    elif "slot" in tool_type or "t-slot" in tool_type or "woodruff" in tool_type:
        norm_type = "slot_mill"
    else:
        norm_type = tool_type.replace(" ", "_")

    try:
        unit = _tool_unit(t_dict)
        if geo.get("DC") in (None, ""):
            raise ValueError("tool has no DC")     # never guess a diameter: such a tool is never merged
        dc_in = round(to_inches(geo["DC"], unit), 4)
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

    # Form-defining fields: two chamfer mills of one diameter and different angles, two drills with different
    # point angles or two taps of different pitch are different tools. Added only when present, so a plain
    # end mill keeps its short signature.
    extra = ""
    for key, tag in (("TA", "ta"), ("SIG", "sig"), ("tip-diameter", "tip")):
        try:
            v = float(geo.get(key) or 0.0) if key != "tip-diameter" else to_inches(geo[key], unit)
        except (UnitError, ValueError, TypeError, KeyError):
            v = 0.0
        if v:
            extra += f"|{tag}:{v:.4f}"
    try:
        tp = to_inches(geo["TP"], unit) if geo.get("TP") not in (None, "", 0) else 0.0
    except (UnitError, ValueError, TypeError):
        tp = 0.0
    if tp:
        extra += f"|tp:{tp:.5f}"
    if geo.get("HAND") is False:
        extra += "|lh"

    if prod_id and len(prod_id) > 2:
        return f"id:{vendor}:{prod_id}|{norm_type}|dia:{dc_in:.4f}|fl:{nof}|lcf:{lcf_in:.3f}|re:{re_in:.4f}{extra}"

    return f"geo:{norm_type}|dia:{dc_in:.4f}|fl:{nof}|lcf:{lcf_in:.3f}|re:{re_in:.4f}|sf:{sf_in:.3f}{extra}"


def _feed_number(v: Any) -> float:
    """Numeric value of a preset feed ("60", 60, "60 in/min", "60 ipm"); 0.0 when it cannot be read."""
    if isinstance(v, (int, float)) and not isinstance(v, bool):
        return float(v)
    m = re.match(r"\s*([-+]?(?:\d+\.?\d*|\.\d+))", str(v or ""))
    return float(m.group(1)) if m else 0.0


def normalize_preset_key(preset: Dict[str, Any]) -> str:
    """Creates a normalized comparison key for a cutting preset to prevent duplicate presets."""
    name = str(preset.get("name", "")).strip().lower()
    mat_query = str(preset.get("material", {}).get("query", "")).strip().lower() if isinstance(preset.get("material"), dict) else ""
    return f"{name}|{mat_query}"


def _preset_values(p: Dict[str, Any]) -> Tuple[float, ...]:
    """Cutting numbers of a preset, used to tell a true duplicate from a same-named preset with other values."""
    return tuple(round(_feed_number(p.get(k)), 4) for k in ("n", "v_f", "f_z", "stepdown", "stepover"))


def merge_presets_lists(primary_presets: List[Dict[str, Any]], secondary_presets: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Merges presets from two tools. Every primary preset is kept (including same-named ones within the
    primary list). A secondary preset is dropped only when it duplicates a kept preset (same name, material
    and cutting numbers); one with the same name but different numbers is kept under a numbered name
    ("Roughing (2)") with a fresh guid, so neither copy's data is lost. A secondary preset with real
    feeds replaces a primary one that has a zero feed.
    """
    merged: List[Dict[str, Any]] = [copy.deepcopy(p) for p in primary_presets]
    by_key: Dict[str, List[int]] = {}
    for i, p in enumerate(merged):
        by_key.setdefault(normalize_preset_key(p), []).append(i)

    for p in secondary_presets:
        key = normalize_preset_key(p)
        idxs = by_key.get(key)
        if not idxs:
            merged.append(copy.deepcopy(p))
            by_key[key] = [len(merged) - 1]
            continue
        vals = _preset_values(p)
        if any(_preset_values(merged[i]) == vals for i in idxs):
            continue                                              # true duplicate
        if all(_feed_number(merged[i].get("v_f")) == 0 for i in idxs) and _feed_number(p.get("v_f")) > 0:
            merged[idxs[0]] = copy.deepcopy(p)
            continue
        dup = copy.deepcopy(p)
        dup["name"] = f"{str(p.get('name', 'Preset')).strip()} ({len(idxs) + 1})"
        dup["guid"] = str(uuid.uuid4())
        merged.append(dup)
        idxs.append(len(merged) - 1)
    return merged


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
        post = t.get("post-process") or t.get("postProcess") or {}
        try:
            if int((post.get("number") if isinstance(post, dict) else 0) or 0) > 0:
                score += 15
        except (TypeError, ValueError):
            pass
        if t.get("holder"):
            score += 10
        if t.get("vendor"):
            score += 5
        if t.get("product-id"):
            score += 5
        presets = t.get("start-values", {}).get("presets", [])
        score += len(presets)
        return score

    return copy.deepcopy(max(tools_group, key=score_tool))


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

        # If matching target material to replace: the preset's material must BE the target (query or the
        # "<material> - " name prefix, or the material recorded in its toolwiz tag). A substring test would
        # also delete the owner's own presets whose names merely mention the material ("304" in "6304").
        if target_material_to_replace:
            target_norm = target_material_to_replace.strip().lower()
            tag = p.get("toolwiz") if isinstance(p.get("toolwiz"), dict) else {}
            tag_mat = str(tag.get("material", "")).strip().lower()
            if (mat_query == target_norm or p_name == target_norm or p_name.startswith(target_norm + " - ")
                    or (tag_mat and tag_mat == target_norm)):
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
