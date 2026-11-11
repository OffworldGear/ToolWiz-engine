"""Shop T-slot cutters from a Fusion tool library (single source of truth: the owner's Fusion library).

``entries_from_library(library)`` reads every ``slot mill`` (and keyseat / T-slot / Woodruff form tool, see
``toolwiz_common.tool_profile.is_slot_head``) of a Fusion library and returns ``data/shop_tools.json`` entries, lengths in
millimetres:

    kerf_mm            = LCF (head thickness)
    diameter_mm        = DC
    neck_diameter_mm,
    reach_mm           = from the shaft segments via ``tool_profile.slot_neck`` (first segment's lower diameter; head top face to
                         the end of the neck), else the shoulder fields, else the shank (then the field is provisional)
    shank_diameter_mm  = the widest shaft segment (the shank the neck grows into), else SFDM
    teeth              = NOF
    tooth_form,        = the tool's ``toolwiz`` block (``tooth_form`` "staggered" | "straight", ``cutting_faces``, ``teeth_per_face``)
    cutting_faces        else keywords in the description: "staggered" -> staggered; "double" / "up down" / "up-down" / "both sides"
                         -> straight (every tooth cuts both faces); otherwise unknown (provisional, treated as staggered)

Library-derived entries carry ``"source": "fusion library"`` and ``provisional`` lists only what the library does not give.
``merge_shop_tools`` keeps planned cutters and legacy hand-entered entries (flagged ``not_in_library`` once a library is merged) and
replaces an entry with the same id or the same diameter and kerf.
"""
from __future__ import annotations

import json
import os
import re
from typing import Any, Dict, List, Optional

ROOT = os.path.dirname(os.path.abspath(__file__))
SHOP_TOOLS_PATH = os.path.join(ROOT, "data", "shop_tools.json")
LIB_DIR = os.path.join(ROOT, "data", "shop_library")
WORKING_LIBRARY = os.path.join(ROOT, "data", "working_library.json")
MM_PER_IN = 25.4
FACES_BOTH = ["periphery", "top", "bottom"]
_STAGGERED = ("staggered", "stagger")
_DOUBLE = ("double", "up down", "up-down", "up/down", "updown", "both sides", "both faces", "two sided", "2 sided")


def _tools_of(library: Any) -> List[Dict[str, Any]]:
    if isinstance(library, dict):
        t = library.get("tools", library.get("data"))
        library = t if t is not None else []
    if isinstance(library, dict):
        library = list(library.values())
    return [t for t in (library or []) if isinstance(t, dict)]


def resolve_library_path(name: str) -> str:
    """A library name from the request (never a free path): ``working`` -> data/working_library.json, else a file name in
    data/shop_library (``.json`` optional, a unique case-insensitive prefix is enough). ValueError when unknown."""
    n = os.path.basename(str(name or "").strip())
    if not n:
        raise ValueError("library name required")
    if n.lower() in ("working", "working_library", "working_library.json"):
        if not os.path.exists(WORKING_LIBRARY):
            raise ValueError("no working library file (data/working_library.json)")
        return WORKING_LIBRARY
    files = sorted(f for f in os.listdir(LIB_DIR) if f.lower().endswith(".json")) if os.path.isdir(LIB_DIR) else []
    exact = [f for f in files if f.lower() in (n.lower(), n.lower() + ".json")]
    hits = exact or [f for f in files if f.lower().startswith(n.lower())]
    if len(hits) != 1:
        raise ValueError(f"library {n!r} not found in data/shop_library (have: {', '.join(files) or 'none'}; or 'working')")
    return os.path.join(LIB_DIR, hits[0])


def load_library(path: str) -> Any:
    with open(path, "r", encoding="utf-8") as fh:
        return json.load(fh)


def _slug(s: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", s.lower()).strip("_")


def _coating(tool: Dict[str, Any]) -> str:
    s = " ".join(str(tool.get(k) or "") for k in ("BMC", "description")).lower()
    for key, name in (("tialn", "TiAlN"), ("altin", "AlTiN"), ("ticn", "TiCN"), ("alcrn", "AlCrN"), ("zrn", "ZrN"), ("diamond", "Diamond")):
        if key in s:
            return name
    if "ti coated" in s or "titanium" in s or re.search(r"\btin\b", s):
        return "Titanium"
    return "Uncoated"


def tooth_info(tool: Dict[str, Any]) -> Dict[str, Any]:
    """tooth_form / cutting_faces / teeth_per_face from the tool's ``toolwiz`` block, else the description keywords."""
    tw = tool.get("toolwiz") if isinstance(tool.get("toolwiz"), dict) else {}
    form, faces, tpf, how = None, None, None, None
    if tw.get("tooth_form") in ("staggered", "straight"):
        form, how = tw["tooth_form"], "toolwiz block"
    if isinstance(tw.get("cutting_faces"), list):
        faces = [f for f in tw["cutting_faces"] if f in FACES_BOTH] or None
    if isinstance(tw.get("teeth_per_face"), (int, float)) and tw["teeth_per_face"] > 0:
        tpf = int(tw["teeth_per_face"])
    text = str(tool.get("description") or "").lower()
    if form is None:
        if any(k in text for k in _STAGGERED):
            form, how = "staggered", "description keyword 'staggered'"
        elif any(k in text for k in _DOUBLE):
            form, how = "straight", "description keyword 'double' / 'up down'"
    if form and faces is None:
        faces = list(FACES_BOTH)
    return {"tooth_form": form, "cutting_faces": faces, "teeth_per_face": tpf, "how": how}


def is_slot_cutter(tool: Dict[str, Any]) -> bool:
    from toolwiz_common.tool_profile import is_slot_head
    from toolwiz_common.tool_types import classify
    return is_slot_head(tool, classify(tool.get("type")))


def entry_from_tool(tool: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """One shop_tools.json entry (mm) for a Fusion slot-mill dict, or None when it is not a usable slot cutter."""
    from toolwiz_common.tool_profile import ToolProfile
    from toolwiz_common.units import tool_unit, to_inches
    if not is_slot_cutter(tool):
        return None
    try:
        prof = ToolProfile.from_fusion(tool)
    except Exception:
        return None
    sl, g = prof.slot or {}, prof.geometry
    if not sl or not g.diameter or not g.flute_length:
        return None
    unit = tool_unit(tool)
    mm = MM_PER_IN
    src = sl.get("source")
    prov: List[str] = []
    if src != "shaft_segments":
        prov += ["neck_diameter", "reach"]
    # shank = the widest shaft segment (Fusion's SFDM of these cutters is the neck, not the shank)
    shank_in = None
    segs = ((tool.get("shaft") or {}).get("segments") or []) if isinstance(tool.get("shaft"), dict) else []
    for sd in segs:
        for k in ("lower-diameter", "upper-diameter"):
            try:
                v = to_inches(sd.get(k), unit)
            except Exception:
                continue
            shank_in = v if shank_in is None else max(shank_in, v)
    if shank_in is None or shank_in < sl["neck_diameter"] * 0.999:
        shank_in = sl.get("shank_diameter") or g.shank_diameter
        prov.append("shank_diameter")
    ti = tooth_info(tool)
    if ti["tooth_form"] is None:
        prov.append("tooth_form")
    geo = tool.get("geometry") or {}
    oal = geo.get("OAL")
    try:
        oal_mm = to_inches(oal, unit) * mm if oal not in (None, "") else None
    except Exception:
        oal_mm = None
    vendor = str(tool.get("vendor") or "").strip()
    desc = str(tool.get("description") or "").strip()
    d_mm, k_mm = g.diameter * mm, g.flute_length * mm
    ident = f"fusion_{_slug(vendor.split('(')[0]) or 'lib'}_{d_mm:.4g}x{k_mm:.4g}".replace(".", "p")
    out = {
        "id": ident, "name": f"{desc[:70]} ({vendor.split('(')[0].strip() + ', ' if vendor else ''}Fusion library)", "planned": False, "source": "fusion library",
        "source_url": None, "source_note": f"Fusion library tool {desc!r}" + (f", vendor {vendor}" if vendor else "") +
        f", guid {tool.get('guid')}. Kerf = LCF, neck / reach from the shaft segments ({src}), teeth = NOF."
        + (f" Tooth form from {ti['how']}." if ti["how"] else " Tooth form not stated: treated as staggered."),
        "library_guid": tool.get("guid"), "tool_number": (tool.get("post-process") or {}).get("number"),
        "diameter_mm": round(d_mm, 4), "kerf_mm": round(k_mm, 4), "shank_diameter_mm": round(shank_in * mm, 4),
        "shank_length_mm": None, "oal_mm": round(oal_mm, 3) if oal_mm else None,
        "teeth": int(g.flutes), "tooth_form": ti["tooth_form"], "cutting_faces": ti["cutting_faces"] or list(FACES_BOTH),
        "teeth_per_face": ti["teeth_per_face"], "coating": _coating(tool),
        "tool_material": "carbide" if "carbide" in str(tool.get("BMC") or "carbide").lower() or "coated" in str(tool.get("BMC") or "").lower() else str(tool.get("BMC")),
        "neck_diameter_mm": round(sl["neck_diameter"] * mm, 4), "reach_mm": round(sl["reach"] * mm, 4),
        "provisional": prov,
    }
    return out


def entries_from_library(library: Any) -> List[Dict[str, Any]]:
    """Shop entries for every slot cutter of a Fusion library dict / tool list; duplicate ids get ``_2``, ``_3``."""
    out: List[Dict[str, Any]] = []
    seen: Dict[str, int] = {}
    for t in _tools_of(library):
        e = entry_from_tool(t)
        if not e:
            continue
        seen[e["id"]] = seen.get(e["id"], 0) + 1
        if seen[e["id"]] > 1:
            e["id"] = f"{e['id']}_{seen[e['id']]}"
        out.append(e)
    return out


def _same_geometry(a: Dict[str, Any], b: Dict[str, Any]) -> bool:
    return (abs(a["diameter_mm"] - b["diameter_mm"]) <= 0.03 * a["diameter_mm"]
            and abs(a["kerf_mm"] - b["kerf_mm"]) <= 0.03 * max(a["kerf_mm"], 1e-6))


def merge_shop_tools(existing: Dict[str, Any], entries: List[Dict[str, Any]], library_name: Optional[str] = None) -> Dict[str, Any]:
    """The shop_tools.json document with library ``entries`` merged in. Library entries replace an existing entry with the same id or
    the same diameter and kerf (planned entries are never replaced: a planned cutter stays planned); every other existing
    entry is kept, flagged ``not_in_library`` when it is a hand-entered entry that this library does not contain."""
    doc = dict(existing or {})
    old = [t for t in doc.get("tools", []) if isinstance(t, dict)]
    kept: List[Dict[str, Any]] = []
    for t in old:
        if any((e["id"] == t.get("id") or (not t.get("planned") and _same_geometry(e, t))) for e in entries):
            continue
        t = dict(t)
        if library_name and t.get("source") != "fusion library" and not t.get("planned"):
            t["not_in_library"] = True
        elif t.get("source") == "fusion library":
            t["not_in_library"] = True            # an earlier library tool that is no longer in this library
        kept.append(t)
    taken = {t.get("id") for t in kept}
    new = []
    for e in entries:
        e = dict(e)
        e.pop("not_in_library", None)
        while e["id"] in taken:
            e["id"] += "_x"
        taken.add(e["id"])
        new.append(e)
    doc["tools"] = new + kept
    if library_name:
        doc["library_source"] = library_name
    return doc


def refresh_shop_tools(library_name: str, write: bool = True, path: Optional[str] = None) -> Dict[str, Any]:
    """Build entries from the named library (see ``resolve_library_path``), merge them into data/shop_tools.json and
    (``write``) save it. Returns ``{"library", "added": [ids], "tools": [...], "written": bool}``."""
    lib_path = resolve_library_path(library_name)
    entries = entries_from_library(load_library(lib_path))
    target = path or SHOP_TOOLS_PATH
    try:
        with open(target, "r", encoding="utf-8") as fh:
            existing = json.load(fh)
    except (OSError, ValueError):
        existing = {"tools": []}
    doc = merge_shop_tools(existing, entries, os.path.basename(lib_path))
    if write:
        tmp = target + ".tmp"
        with open(tmp, "w", encoding="utf-8") as fh:
            json.dump(doc, fh, indent=1, ensure_ascii=False)
            fh.write("\n")
        os.replace(tmp, target)
    return {"library": os.path.basename(lib_path), "added": [e["id"] for e in entries], "tools": doc["tools"], "written": bool(write)}


if __name__ == "__main__":      # python shop_tool_builder.py <library name or 'working'> [--dry-run]
    import sys
    r = refresh_shop_tools(sys.argv[1] if len(sys.argv) > 1 else "Offworldgear", write="--dry-run" not in sys.argv)
    print(json.dumps({k: v for k, v in r.items() if k != "tools"}, indent=1))
