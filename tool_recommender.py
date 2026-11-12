"""Tool recommender: "is another tool much faster for this cut?" (docs/TOOL_RECOMMENDER.md).

``recommend(body)`` reruns the ToolWiz engine (``pipeline.run_cut``) for one cut with alternative tools that fit the same
feature and reports an alternative only when the gain is large (default 30 %). Pure functions, no Flask. Lengths are
inches, feeds IPM, speeds rpm / SFM, removal rates in^3/min.

Candidates (priority order, at most ``MAX_RUNS`` engine runs per request, deterministic):

* **library**: the owner's own end mills (``data/shop_library/*.json``, ``data/working_library.json``) that fit the feature.
* **catalog, same diameter**: other brands that have a chart for this material and operation, with the flute counts and
  flute lengths that exist in their cited benchmark rows at that diameter (``data/model_v2/catalog_geometries.json``).
* **catalog, other flute counts** of the current brand (or of any brand when the current tool is unbranded).
* **catalog, larger diameters** up to the feature limit.
* a second pass combining the best brand with the other flute counts and the largest diameter.

Scoring: roughing kinds by material removal rate (and cycle time when a volume or a toolpath length is given); finishing by the
rate at which the finish mode's Ra and wall targets are met (feed x stepover for a floor or 3D surface, feed x depth for a wall).

Honesty rules (they are part of every result):

* A brand gain reflects that vendor's PUBLISHED chart ("the OSG chart allows 1.8x the removal rate"), not a measured tool test.
* A catalog candidate is a geometry from a cited catalog row, not a guarantee that the exact part number exists or is in stock.
* A tool with no brand, or a brand ToolWiz has no chart for, is compared on the conservative default chart.
* ToolWiz does not (yet) limit chip space by flute count in the engine: a flute-count increase in a full slot carries a caveat that is
  dropped automatically when the engine result contains a ``chip_space`` block. This module has no flute-count physics of its own.

Every number in a result comes from a ``pipeline.run_cut`` result.
"""
from __future__ import annotations

import copy
import glob
import json
import math
import os
import threading
from collections import OrderedDict
from functools import lru_cache
from typing import Any, Dict, List, Optional, Tuple

ROOT = os.path.dirname(os.path.abspath(__file__))
CATALOG_PATH = os.path.join(ROOT, "data", "model_v2", "catalog_geometries.json")
LIBRARY_DIR = os.path.join(ROOT, "data", "shop_library")
WORKING_LIBRARY = os.path.join(ROOT, "data", "working_library.json")

DEFAULT_MIN_GAIN_PCT = 30.0
MAX_RUNS = 40                      # engine runs per request (the current tool's run included)
MAX_ALTERNATIVES = 6
MAX_BELOW = 3
MAX_LIBRARY_CANDIDATES = 8
MAX_LARGER_SIZES = 3
MAX_FLUTE_VARIANTS = 3
MAX_COMBINED = 6
EDGE_BREAK_MAX_FRACTION = 0.15     # same rule as setup_advisor: a corner radius up to this fraction of D is an edge break
DIAMETER_TOL = 0.06                # a catalog row is "at" a diameter when its DC is within this fraction
SAME_DIAMETER_TOL = 0.01
RESULT_CACHE_SIZE = 64
DEFAULT_RUNOUT_FALLBACK = 0.0002

# standard sizes (in) the larger-diameter search steps through
STANDARD_DIAMETERS = (0.0156, 0.0312, 0.0469, 0.0625, 0.0781, 0.0938, 0.125, 0.1562, 0.1875, 0.25, 0.3125, 0.375, 0.5, 0.625,
                      0.75, 1.0)
NONFERROUS = ("aluminum", "copper", "brass", "bronze", "magnesium", "zinc", "plastic")
NOT_END_MILL = ("lollipop", "face", "chamfer", "dovetail", "taper", "slot mill", "keyseat", "t-slot", "woodruff", "drill", "tap",
                "ream", "thread", "holder", "probe", "bore", "spot", "engrav", "v-bit", "saw", "circle segment")
ALUMINUM_ONLY = ("aluminum", "aluminium", "plastic", "wood", "acrylic", "delrin", "graphite")

# engine operation per request operation word; kind: slot | adaptive | rough | finish | face
_OP_WORDS = (("slot", "Slotting", "slot"), ("adaptive", "Adaptive Roughing", "adaptive"), ("dynamic", "Adaptive Roughing", "adaptive"),
             ("hem", "Adaptive Roughing", "adaptive"), ("trochoid", "Adaptive Roughing", "adaptive"),
             ("finish", "Finishing", "finish"), ("scallop", "Finishing", "finish"), ("face", "Facing", "face"),
             ("facing", "Facing", "face"), ("pocket", "Roughing", "rough"), ("rough", "Roughing", "rough"),
             ("contour", "Roughing", "rough"), ("profile", "Roughing", "rough"), ("side", "Roughing", "rough"))
# vendor chart classes the engine reads per kind (physics_v2.optimize.VENDOR_CHART_CLASSES) and the benchmark-row operations
_KIND_ROW_OPS = {"slot": ("slot",), "adaptive": ("hem",), "rough": ("rough", "side"), "finish": ("finish", "side"),
                 "face": ("rough", "side")}
_KIND_CLASS_WORD = {"slot": "slotting", "adaptive": "HEM", "rough": "roughing", "finish": "finishing", "face": "roughing"}

DISCLAIMERS = [
    "A brand gain reflects that vendor's published chart for this material and operation, not a measured tool test: the chart is the "
    "vendor's starting value.",
    "A catalog candidate is a geometry (flute count, flute length) from a cited vendor catalog row, not a guarantee that the exact part "
    "number exists or is in stock.",
    "Every number comes from a ToolWiz engine run with the same material, aggressiveness, runout, machine and stickout rule for the "
    "current tool and for each candidate.",
]


# ===================================================================================================================
# input
# ===================================================================================================================

def _num(body: Dict[str, Any], *keys: str, positive: bool = False, nonneg: bool = False, default: Optional[float] = None) -> Optional[float]:
    for k in keys:
        v = body.get(k)
        if v is None or v == "":
            continue
        if isinstance(v, bool):
            raise ValueError(f"'{k}' must be a number")
        try:
            f = float(v)
        except (TypeError, ValueError):
            raise ValueError(f"'{k}' must be a number") from None
        if f != f or f in (float("inf"), float("-inf")):
            raise ValueError(f"'{k}' must be a finite number")
        if positive and f <= 0:
            raise ValueError(f"'{k}' must be > 0")
        if nonneg and f < 0:
            raise ValueError(f"'{k}' must be >= 0")
        return f
    return default


def _flag(body: Dict[str, Any], key: str, default: Optional[bool] = None) -> Optional[bool]:
    v = body.get(key)
    if v is None or v == "":
        return default
    if isinstance(v, bool):
        return v
    if isinstance(v, str) and v.strip().lower() in ("true", "false", "1", "0", "yes", "no"):
        return v.strip().lower() in ("true", "1", "yes")
    raise ValueError(f"'{key}' must be true or false")


def op_info(operation: str) -> Tuple[str, str]:
    """(engine operation name, kind) for a request operation: kind is slot | adaptive | rough | finish | face."""
    s = str(operation or "").strip().lower()
    if not s:
        raise ValueError("'operation' is required (Slotting, Adaptive Roughing, Roughing, Finishing, ...)")
    for word, eng, kind in _OP_WORDS:
        if word in s:
            return eng, kind
    raise ValueError(f"operation {operation!r} is not one the recommender covers (slotting, adaptive, roughing, pocket, contour, finishing, facing)")


def _sources(body: Dict[str, Any]) -> Tuple[bool, bool]:
    src = body.get("sources")
    if src is None:
        return True, True
    if isinstance(src, str):
        src = [s for s in src.replace(",", " ").split() if s]
    if not isinstance(src, (list, tuple)) or not all(isinstance(s, str) for s in src):
        raise ValueError("'sources' must be a list such as [\"library\", \"catalog\"]")
    low = {s.strip().lower() for s in src}
    bad = low - {"library", "catalog"}
    if bad:
        raise ValueError(f"unknown source(s) {sorted(bad)}: use \"library\" and/or \"catalog\"")
    return "library" in low, "catalog" in low


def parse_request(body: Dict[str, Any]) -> Dict[str, Any]:
    """Validate and normalize a request body into the spec ``recommend`` works from. Accepts the flat keys documented in
    docs/TOOL_RECOMMENDER.md and the web calculator's names (fluteLength, shankDiameter, cornerRadius, cutDepth, cutWidth, ...)."""
    if not isinstance(body, dict):
        raise ValueError("JSON object body required")
    fusion = body.get("fusion_tool") if isinstance(body.get("fusion_tool"), dict) else None
    geo = (fusion or {}).get("geometry") if isinstance((fusion or {}).get("geometry"), dict) else {}
    f_unit = 1.0 / 25.4 if str((fusion or {}).get("unit") or "").lower().startswith("mill") else 1.0

    def g(k):
        v = geo.get(k)
        return float(v) * f_unit if isinstance(v, (int, float)) and not isinstance(v, bool) else None

    family = str(body.get("family") or "").strip()
    if not family:
        raise ValueError("'family' (the ToolWiz material family, e.g. 'Titanium Alloy') is required")
    engine_op, kind = op_info(body.get("operation"))
    D = _num(body, "diameter", "diameter_in", positive=True) or g("DC")
    if not D:
        raise ValueError("'diameter' (inches) is required")
    z = _num(body, "flutes", positive=True)
    z = z if z is not None else g("NOF")
    if z is not None and z != int(z):
        raise ValueError("'flutes' must be a whole number")
    agg = _num(body, "aggressiveness", default=0.5)
    agg = agg / 100.0 if agg > 1.0 else agg
    if not 0.0 <= agg <= 1.0:
        raise ValueError("'aggressiveness' must be between 0 and 1 (or 0 to 100 as a percentage)")
    geometry = str(body.get("geometry") or "").strip().lower()
    cr = _num(body, "corner_radius", "cornerRadius", nonneg=True)
    cr = cr if cr is not None else (g("RE") or 0.0)
    model = str(body.get("model") or "v2").lower()
    if model not in ("v1", "v2"):
        raise ValueError("'model' must be 'v1' or 'v2'")
    min_gain = _num(body, "min_gain_pct", default=DEFAULT_MIN_GAIN_PCT, nonneg=True)
    max_runs = int(_num(body, "max_runs", positive=True, default=MAX_RUNS))
    use_library, use_catalog = _sources(body)
    fm = body.get("finish_mode", body.get("finishMode"))
    if fm is not None and fm != "" and str(fm).lower() not in ("none", "cleanup", "surface", "accuracy"):
        raise ValueError("'finish_mode' must be none, cleanup, surface or accuracy")
    ra = _num(body, "target_ra", "target_ra_uin", "targetRa", positive=True)
    wall = _num(body, "wall_tolerance", "wallTolerance", positive=True)
    spec = {
        "family": family, "alloy": str(body.get("alloy") or "").strip(), "operation": engine_op, "kind": kind,
        "operation_text": str(body.get("operation")), "aggressiveness": agg, "model": model,
        "runout": _num(body, "runout", "runout_in", nonneg=True),
        "max_rpm": _num(body, "max_rpm", "maxRpm", positive=True), "max_hp": _num(body, "max_hp", "maxHp", positive=True),
        "tool": {
            "diameter": D, "flutes": int(z) if z else None,
            "flute_length": _num(body, "flute_length", "fluteLength", positive=True) or g("LCF"),
            "shank_diameter": _num(body, "shank_diameter", "shankDiameter", positive=True) or g("SFDM"),
            "stickout": _num(body, "stickout", positive=True) or g("LB"),
            "corner_radius": cr,
            "coating": (str(body.get("coating")).strip() if body.get("coating") not in (None, "") else None),
            "brand": (str(body.get("brand") or "").strip() or ((fusion or {}).get("vendor") if fusion else None) or None),
            "geometry": geometry, "is_carbide": body.get("isCarbide", body.get("is_carbide")) is not False,
            "description": str(body.get("description") or "").strip() or None,
        },
        "feature": {
            "max_diameter": _num(body, "max_diameter_in", "max_diameter", positive=True),
            "min_reach": _num(body, "min_reach_in", "min_reach", positive=True),
            "full_slot": _flag(body, "full_slot"),
            "include_larger": _flag(body, "include_larger"),
            "keep_corner_radius": _flag(body, "keep_corner_radius"),
            "cut_depth": _num(body, "cut_depth", "cutDepth", positive=True),
            "cut_width": _num(body, "cut_width", "cutWidth", positive=True),
            "toolpath_length": _num(body, "toolpath_length_in", "toolpath_length", positive=True),
            "depth": _num(body, "depth_in", "feature_depth", positive=True),
            "volume": _num(body, "volume_in3", positive=True),
            "area": _num(body, "area_in2", positive=True),
        },
        "finish": {"mode": (str(fm).lower() if fm not in (None, "") else None), "target_ra": ra, "wall_tolerance": wall},
        "use_library": use_library, "use_catalog": use_catalog, "min_gain_pct": min_gain, "max_runs": max_runs,
        "library_tools": body.get("library_tools") if isinstance(body.get("library_tools"), list) else None,
    }
    if spec["feature"]["full_slot"] is None:
        spec["feature"]["full_slot"] = kind == "slot"
    if kind == "finish":
        spec["feature"]["full_slot"] = False
    return spec


# ===================================================================================================================
# data: the catalog (cited benchmark geometries) and the owner's library
# ===================================================================================================================

@lru_cache(maxsize=1)
def _catalog_rows() -> List[Dict[str, Any]]:
    with open(CATALOG_PATH, encoding="utf-8") as fh:
        doc = json.load(fh)
    fields = doc["fields"]
    out = []
    for r in doc["rows"]:
        e = dict(zip(fields, r))
        out.append(e)
    return out


@lru_cache(maxsize=1)
def _vendor_chart_classes() -> Dict[str, Dict[str, set]]:
    """vendor -> family -> set of chart classes the engine has square-end cells for (consensus_by_vendor.json)."""
    path = os.path.join(ROOT, "data", "model_v2", "consensus_by_vendor.json")
    with open(path, encoding="utf-8") as fh:
        doc = json.load(fh)
    out: Dict[str, Dict[str, set]] = {}
    for vendor, v in (doc.get("vendors") or {}).items():
        fam_map: Dict[str, set] = {}
        for key in (v.get("cells") or {}):
            parts = key.split("|")
            if len(parts) >= 5:
                fam_map.setdefault(parts[0], set()).add(parts[3])
        out[vendor] = fam_map
    return out


def vendor_has_chart(vendor: str, family: str, kind: str) -> bool:
    classes = {"slot": ("slot",), "adaptive": ("hem",), "rough": ("rough", "side"), "finish": ("finish",), "face": ("rough", "side")}[kind]
    have = _vendor_chart_classes().get(vendor, {}).get(family, set())
    return any(c in have for c in classes)


def catalog_geometries(family: str, kind: str, diameter: float, *, vendor: Optional[str] = None, tol: float = DIAMETER_TOL,
                       min_flute_length: float = 0.0) -> List[Dict[str, Any]]:
    """Cited square-end geometries for a material family and operation kind near ``diameter`` (within ``tol``). One entry per
    (vendor, series, flutes, flute length), sorted for determinism. ``min_flute_length`` drops tools too short for the reach."""
    ops = _KIND_ROW_OPS[kind]
    seen, out = set(), []
    for e in _catalog_rows():
        if e["family"] != family or e["op"] not in ops:
            continue
        if vendor is not None and e["vendor"] != vendor:
            continue
        if abs(e["dc"] - diameter) > tol * diameter:
            continue
        lcf = e.get("lcf")
        if min_flute_length and (lcf is None or lcf < min_flute_length - 1e-9):
            continue
        key = (e["vendor"], e["series"], e["flutes"], lcf)
        if key in seen:
            continue
        seen.add(key)
        out.append(e)
    out.sort(key=lambda e: (e["vendor"], e["flutes"], e["lcf"] if e["lcf"] is not None else 9e9, str(e["series"])))
    return out


def short_series(series: Optional[str]) -> Optional[str]:
    if not series:
        return None
    s = str(series)
    for sep in (" (", ", "):
        if sep in s:
            s = s.split(sep, 1)[0]
    if len(s) > 40:
        s = s[:40].rsplit(" ", 1)[0]
    return s


_LIB_LOCK = threading.Lock()


def library_paths() -> List[str]:
    paths = sorted(glob.glob(os.path.join(LIBRARY_DIR, "*.json")))
    if os.path.exists(WORKING_LIBRARY):
        paths.append(WORKING_LIBRARY)
    return paths


def _library_fingerprint() -> Tuple:
    out = []
    for p in library_paths():
        try:
            out.append((p, os.path.getmtime(p), os.path.getsize(p)))
        except OSError:
            continue
    return tuple(out)


def load_library_tools(paths: Optional[List[str]] = None) -> List[Dict[str, Any]]:
    """The owner's end mills as parsed tool dicts (``setup_advisor.parse_tool``) plus ``library`` and ``raw_type``. Tools of the same
    size, flute count, flute length, corner radius and vendor that appear in several libraries are listed once."""
    import setup_advisor
    seen, out = set(), []
    for p in (paths if paths is not None else library_paths()):
        try:
            with open(p, encoding="utf-8") as fh:
                doc = json.load(fh)
        except (OSError, ValueError):
            continue
        tools = doc.get("tools") if isinstance(doc, dict) else doc
        tools = tools if tools is not None else (doc.get("data") if isinstance(doc, dict) else [])
        if isinstance(tools, dict):
            tools = list(tools.values())
        lib = str((doc.get("library_name") if isinstance(doc, dict) else None) or os.path.basename(p))
        for t in tools or []:
            if not isinstance(t, dict):
                continue
            pt = setup_advisor.parse_tool(t)
            if not pt.get("diameter_in"):
                continue
            pt["raw_type"] = str(t.get("type") or "")
            pt["library"] = lib
            pt["is_carbide"] = _is_carbide(t)
            key = (round(pt["diameter_in"], 4), pt.get("flutes"), round(pt.get("flute_length_in") or 0, 3),
                   round(pt.get("corner_radius_in") or 0, 4), (pt.get("vendor") or "").lower(), pt["raw_type"])
            if key in seen:
                continue
            seen.add(key)
            out.append(pt)
    return out


def _is_carbide(t: Dict[str, Any]) -> bool:
    bmc = str(t.get("BMC") or "").lower()
    text = (str(t.get("description") or "") + " " + bmc + " " + str(t.get("GRADE") or "")).lower()
    return not any(k in text for k in ("hss", "high speed", "cobalt"))


# ===================================================================================================================
# candidates
# ===================================================================================================================

def _is_square(cr: float, d: float) -> bool:
    return (cr or 0.0) <= EDGE_BREAK_MAX_FRACTION * d + 1e-12


def _geometry_of(tool_type: str, cr: float, d: float) -> str:
    t = tool_type.lower()
    if "ball" in t:
        return "Ball"
    return "Square" if _is_square(cr, d) else "Radiused"


def _brand_label(text: Optional[str]) -> Optional[str]:
    return text if text else None


def _default_stickout(d: float, need: float, shank: float) -> float:
    return round(max(need + 0.5 * shank, 4.0 * d), 5)


class Cut:
    """The resolved cut: spec, machine and the stickout / engagement rules every candidate is run under."""

    def __init__(self, spec: Dict[str, Any], machine: Dict[str, Any]):
        self.spec = spec
        self.machine = machine
        self.kind = spec["kind"]
        self.finishing = self.kind == "finish"
        t, f = spec["tool"], spec["feature"]
        self.notes: List[str] = []                 # assumptions, plain sentences
        self.D0 = t["diameter"]
        z = t["flutes"]
        if not z:
            z = 4
            self.notes.append("flute count of the current tool not given: 4 assumed")
        self.z0 = z
        self.cr0_raw = t["corner_radius"] or 0.0
        self.geometry0 = ("Ball" if "ball" in (t["geometry"] or "") else
                          "Radiused" if (t["geometry"] in ("radiused", "bull nose", "bullnose", "bull") and not _is_square(self.cr0_raw, self.D0))
                          else _geometry_of("", self.cr0_raw, self.D0))
        self.cr0 = 0.0 if self.geometry0 == "Square" else self.cr0_raw
        if self.cr0_raw and self.geometry0 == "Square":
            self.notes.append(f"corner radius {self.cr0_raw:.4f} in is {self.cr0_raw / self.D0 * 100:.0f}% of the diameter: treated as an edge break "
                              "(square end mill), the same rule the Setup Advisor uses, so the vendor charts apply")
        self.flen0 = t["flute_length"] or round(3.0 * self.D0, 5)
        if not t["flute_length"]:
            self.notes.append("flute length of the current tool not given: 3 x D assumed")
        self.shank0 = t["shank_diameter"] or (max(self.D0, 0.125) if self.D0 < 0.125 else self.D0)
        self.keep_radius = f["keep_corner_radius"] if f["keep_corner_radius"] is not None else self.geometry0 == "Radiused"
        self.limit = f["max_diameter"]
        self.min_reach = f["min_reach"]
        self.need = self.min_reach if self.min_reach else self.flen0      # the reach the stickout rule is built on
        self.hard_reach = self.min_reach or 0.0                           # the flute length a candidate must have
        if not self.min_reach:
            self.notes.append(f"no feature depth given: candidates are chosen with a flute length close to the current tool's ({self.flen0:.4g} in) "
                              "and flagged when shorter; give the depth (min_reach_in) to filter them")
        self.full_slot = bool(f["full_slot"])
        self.stick_given = t["stickout"]
        if self.stick_given:
            self.notes.append(f"stickout: every candidate is run at the current tool's stickout ({self.stick_given:.4g} in), raised only when the "
                              "feature depth needs more reach")
        else:
            self.notes.append("stickout not given: every tool is run at max(reach + half the shank, 4 x diameter), so it scales with the diameter")
        self.runout = spec["runout"]
        if self.runout is None:
            from toolwiz_common.runout import default_runout
            self.runout, src = default_runout(self.D0, None)
            self.notes.append(f"runout not given: {self.runout:.4f} in ({src} of the current tool) for every candidate (same holder)")
        else:
            self.notes.append(f"runout {self.runout:.4f} in for every candidate (same holder)")
        eng = ("each tool at ToolWiz's recommended depth and width" if f["cut_depth"] is None and f["cut_width"] is None
               else "the given depth and width scaled with the tool diameter" + (" (finishing: kept as given)" if self.finishing else ""))
        self.notes.append(f"engagement: {eng}" + ("; a full slot is as wide as each tool" if self.full_slot else ""))
        self.notes.append(f"same material, operation and aggressiveness ({spec['aggressiveness'] * 100:.0f}%) and machine ({machine['max_rpm']:,.0f} rpm "
                          "limit) for every candidate")
        if spec["tool"]["coating"]:
            self.notes.append(f"catalog candidates are run with the current tool's coating ({spec['tool']['coating']}); library tools with their own")
        else:
            self.notes.append("coating of the current tool not given: no coating factor for the current tool or the catalog candidates")
        self.larger_allowed = bool(f["include_larger"]) if f["include_larger"] is not None else not (self.full_slot and self.limit is None)
        self.limit_known = self.limit is not None
        if self.full_slot and self.limit is None:
            self.notes.append("full slot with no width limit given: the slot is taken to be as wide as the current tool, so only same-diameter "
                              "alternatives are tried")
        elif self.limit is None and self.larger_allowed:
            self.notes.append("no feature size limit given: larger tools are tried up to twice the current diameter, assuming the feature "
                              "(slot width, inside corner radius) allows it; check the part before changing")
        self.brand0_text = t["brand"]
        from toolwiz_common import brand as brandmod
        self.brand0_key = brandmod.resolve(self.brand0_text) if self.brand0_text else None

    # -- the stickout rule ----------------------------------------------------------------------------------------
    def stickout_for(self, d: float, shank: float, own: Optional[float] = None) -> float:
        if own:
            base = own
        elif self.stick_given:
            base = self.stick_given
        else:
            return _default_stickout(d, self.need, shank)
        if self.min_reach and base < self.min_reach + 0.0625:
            base = self.min_reach + 0.0625
        return round(base, 5)

    # -- the engagement rule --------------------------------------------------------------------------------------
    def engagement(self, d: float, flute_length: float) -> Tuple[Optional[float], Optional[float]]:
        f = self.spec["feature"]
        scale = 1.0 if self.finishing else d / self.D0
        depth = f["cut_depth"] * scale if f["cut_depth"] else None
        if depth is None and self.finishing and (f["depth"] or self.min_reach):
            depth = f["depth"] or self.min_reach           # a wall is finished over its whole height (one pass when the flute reaches)
        if depth is not None:
            depth = min(depth, flute_length)
        if self.full_slot:
            width = d
        else:
            width = f["cut_width"] * scale if f["cut_width"] else None
        return depth, width


def _candidate(cut: Cut, *, source: str, diameter: float, flutes: int, flute_length: float, shank: float, brand_text: Optional[str],
               brand_key: Optional[str], corner_radius: float, geometry: str, coating: Optional[str], stickout: Optional[float] = None,
               series: Optional[str] = None, part_number: Optional[str] = None, catalog_coating: Optional[str] = None,
               catalog_ref: Optional[Dict[str, Any]] = None, library: Optional[Dict[str, Any]] = None, geometry_note: Optional[str] = None,
               is_carbide: bool = True) -> Dict[str, Any]:
    return {"source": source, "diameter": diameter, "flutes": int(flutes), "flute_length": flute_length, "shank": shank,
            "brand_text": brand_text, "brand_key": brand_key, "corner_radius": corner_radius, "geometry": geometry, "coating": coating,
            "stickout": cut.stickout_for(diameter, shank, stickout), "series": series, "part_number": part_number,
            "catalog_coating": catalog_coating, "catalog_ref": catalog_ref, "library": library, "geometry_note": geometry_note,
            "is_carbide": is_carbide}


def current_candidate(cut: Cut) -> Dict[str, Any]:
    t = cut.spec["tool"]
    c = _candidate(cut, source="current", diameter=cut.D0, flutes=cut.z0, flute_length=cut.flen0, shank=cut.shank0,
                   brand_text=cut.brand0_text, brand_key=cut.brand0_key, corner_radius=cut.cr0, geometry=cut.geometry0,
                   coating=t["coating"], stickout=t["stickout"], is_carbide=t["is_carbide"])
    return c


def _fits(cut: Cut, d: float, flute_length: Optional[float], reach: Optional[float] = None) -> Optional[str]:
    """None when a tool of diameter ``d`` and this flute length fits the feature, else the reason it does not."""
    if cut.limit is not None and d > cut.limit * 1.0001:
        return f"{d:.4g} in is wider than the {cut.limit:.4g} in the feature allows"
    if d < cut.D0 * (1 - SAME_DIAMETER_TOL):
        return f"{d:.4g} in is smaller than the current tool (never faster, and a slot would be left uncut)"
    if d > cut.D0 * (1 + SAME_DIAMETER_TOL):
        if not cut.larger_allowed:
            return f"{d:.4g} in is larger than the current tool and no feature limit was given"
        if cut.limit is None and d > 2.0 * cut.D0 * 1.0001:
            return f"{d:.4g} in is more than twice the current diameter (no feature limit given)"
    if cut.full_slot and cut.limit is None and d > cut.D0 * (1 + SAME_DIAMETER_TOL):
        return f"{d:.4g} in would not fit the slot (taken as the current tool's width)"
    r = reach if reach is not None else flute_length
    if cut.hard_reach and (r is None or r < cut.hard_reach - 1e-9):
        return f"flute length {r if r is not None else 'unknown'} in is shorter than the {cut.hard_reach:.4g} in reach the feature needs"
    return None


def library_candidates(cut: Cut, tools: List[Dict[str, Any]], limit: int = MAX_LIBRARY_CANDIDATES) -> Tuple[List[Dict[str, Any]], List[str]]:
    """Library end mills that fit the feature, widest first (at most ``limit``), and why the others were left out."""
    out, skipped = [], []
    nonferrous = cut.spec["family"].lower().startswith(NONFERROUS)
    ball = cut.geometry0 == "Ball"
    for t in tools:
        desc = (t.get("description") or t.get("raw_type") or "tool")
        label = f"{('T' + str(t['number']) + ' ') if t.get('number') else ''}{desc}"
        rtype = (t.get("raw_type") or "").lower()
        text = (rtype + " " + desc).lower()
        if any(k in text for k in NOT_END_MILL) or "mill" not in rtype and "end" not in text:
            continue
        if "ball" in rtype and not ball:
            continue
        if ball and "ball" not in rtype:
            continue
        if any(k in text for k in ALUMINUM_ONLY) and not nonferrous:
            skipped.append(f"{label}: made for aluminum or plastics, not {cut.spec['family']}")
            continue
        d = t["diameter_in"]
        z = t.get("flutes")
        flen = t.get("flute_length_in") or round(3.0 * d, 5)
        reach = max(flen, t.get("reach_in") or 0.0)
        reason = _fits(cut, d, flen, reach)
        if reason:
            if "smaller than the current tool" not in reason:
                skipped.append(f"{label}: {reason}")
            continue
        shank = t.get("shank_diameter_in") or (max(d, 0.125) if d < 0.125 else d)
        cr = t.get("corner_radius_in") or 0.0
        geo = "Ball" if "ball" in rtype else _geometry_of(rtype, cr, d)
        cr_eff = 0.0 if geo == "Square" else cr
        brand_text = t.get("vendor")
        from toolwiz_common import brand as brandmod
        key = brandmod.resolve(brand_text) if brand_text else None
        cand = _candidate(cut, source="library", diameter=d, flutes=z or 4, flute_length=flen, shank=shank, brand_text=brand_text,
                          brand_key=key, corner_radius=cr_eff, geometry=geo, coating=t.get("coating"), stickout=t.get("stickout_in"),
                          library={"number": t.get("number"), "description": desc, "library": t.get("library")},
                          is_carbide=t.get("is_carbide", True))
        cand["_notes"] = ([] if z else ["flute count not in the library: 4 assumed"])
        if abs(d - cut.D0) <= SAME_DIAMETER_TOL * cut.D0 and z == cut.z0 and abs(flen - cut.flen0) < 1e-3 \
                and (cut.brand0_text or "").lower() == (brand_text or "").lower() and abs(cr_eff - cut.cr0) < 1e-4:
            continue                                   # the current tool itself
        out.append(cand)
    out.sort(key=lambda c: (-c["diameter"], c["flutes"], str(c["library"]["description"])))
    return out[:limit], skipped


def _pick_lcf(cut: Cut, geos: List[Dict[str, Any]]) -> Dict[str, Any]:
    """The geometry whose flute length is the smallest one that reaches the current tool's, else the longest available."""
    longer = [e for e in geos if (e["lcf"] or 0) >= cut.flen0 - 1e-9]
    if longer:
        return min(longer, key=lambda e: (e["lcf"] or 9e9, str(e["series"])))
    return max(geos, key=lambda e: ((e["lcf"] or 0), str(e["series"])))


def _by_flutes(cut: Cut, geos: List[Dict[str, Any]], prefer: Optional[int]) -> List[Dict[str, Any]]:
    by_z: Dict[int, List[Dict[str, Any]]] = {}
    for e in geos:
        by_z.setdefault(e["flutes"], []).append(e)
    counts = sorted(by_z, key=lambda z: (z != prefer, z < (prefer or z), abs(z - (prefer or z)), z))
    return [_pick_lcf(cut, by_z[z]) for z in counts]


def _vendor_flute_options(cut: Cut, vendor: str, d: float, prefer: Optional[int]) -> List[Dict[str, Any]]:
    """One geometry per flute count that exists for the vendor near ``d`` (flute length chosen by ``_pick_lcf``): the preferred count
    first, then the next higher, then the nearest lower."""
    return _by_flutes(cut, catalog_geometries(cut.spec["family"], cut.kind, d, vendor=vendor, min_flute_length=cut.hard_reach), prefer)


def _catalog_candidate(cut: Cut, e: Dict[str, Any], *, brand_key: Optional[str], brand_text: Optional[str], d: Optional[float] = None,
                       corner_radius: float = 0.0, geometry: str = "Square") -> Dict[str, Any]:
    dd = e["dc"] if d is None else d
    shank = e.get("shank") or (max(dd, 0.125) if dd < 0.125 else dd)
    return _candidate(cut, source="catalog", diameter=dd, flutes=e["flutes"], flute_length=e["lcf"] or round(3.0 * dd, 5), shank=shank,
                      brand_text=brand_text, brand_key=brand_key, corner_radius=corner_radius, geometry=geometry,
                      coating=cut.spec["tool"]["coating"], series=short_series(e["series"]), part_number=e.get("part_number"),
                      catalog_coating=e.get("coating"),
                      catalog_ref={"vendor": e["vendor"], "series": e["series"], "part_number": e.get("part_number"),
                                   "row": e.get("row_id"), "document": e.get("doc_id"), "catalog_diameter": e["dc"]})


def larger_sizes(cut: Cut) -> List[float]:
    if not cut.larger_allowed:
        return []
    top = cut.limit if cut.limit is not None else 2.0 * cut.D0
    sizes = [s for s in STANDARD_DIAMETERS if s > cut.D0 * (1 + 0.04) and s <= top * 1.0001]
    if not sizes:
        return []
    picks = [sizes[-1]]
    if len(sizes) > 1:
        picks.append(sizes[0])
    if len(sizes) > 2:
        mid = min(sizes[1:-1], key=lambda s: abs(math.log(s / math.sqrt(sizes[0] * sizes[-1]))))
        picks.append(mid)
    return sorted(set(picks), reverse=True)[:MAX_LARGER_SIZES]


# ===================================================================================================================
# engine runs
# ===================================================================================================================

class Runner:
    """Runs ``pipeline.run_cut`` for candidates; counts uncached runs against a per-request cap (and an optional shared budget)."""

    def __init__(self, physics, cut: Cut, cache: Optional[Dict[Any, Any]] = None, budget: Optional[Dict[str, int]] = None,
                 max_runs: int = MAX_RUNS):
        self.physics, self.cut = physics, cut
        self.cache = cache if cache is not None else {}
        self.budget = budget
        self.max_runs = max_runs
        self.runs = 0
        self.finish_targets: Dict[str, Any] = {}

    def exhausted(self) -> bool:
        return self.runs >= self.max_runs or (self.budget is not None and self.budget.get("runs", 0) <= 0)

    def request(self, c: Dict[str, Any]):
        from pipeline import CutRequest
        cut = self.cut
        sp = cut.spec
        depth, width = cut.engagement(c["diameter"], c["flute_length"])
        geo = c["geometry"]
        ft = {"type": "ball end mill" if geo == "Ball" else ("bull nose end mill" if geo == "Radiused" else "flat end mill"), "unit": "inches",
              "geometry": {"DC": c["diameter"], "NOF": c["flutes"], "LCF": c["flute_length"], "SFDM": c["shank"], "LB": c["stickout"],
                           **({"RE": c["corner_radius"]} if c["corner_radius"] else {})}}
        fin = dict(self.finish_targets) if cut.finishing else {}
        fin.setdefault("mode", sp["finish"]["mode"])
        fin.setdefault("target_ra", sp["finish"]["target_ra"])
        fin.setdefault("wall_tolerance", sp["finish"]["wall_tolerance"])
        return CutRequest(
            family=sp["family"], alloy=sp["alloy"], operation=sp["operation"], coating=c["coating"] or "Uncoated",
            apply_coating=bool(c["coating"]), geometry=geo, diameter=c["diameter"], flutes=c["flutes"], flute_length=c["flute_length"],
            shank_diameter=c["shank"], corner_radius=c["corner_radius"], stickout=c["stickout"], aggressiveness=sp["aggressiveness"],
            max_rpm=cut.machine["max_rpm"], max_hp=cut.machine["max_hp"], runout=cut.runout, cut_depth=depth, cut_width=width,
            fusion_tool=ft, model=sp["model"], brand=c["brand_text"], is_carbide=c["is_carbide"],
            finish_mode=fin.get("mode"), target_ra=fin.get("target_ra"), wall_tolerance=fin.get("wall_tolerance"),
            machine_profile=cut.machine["profile"] if (cut.machine.get("profile") or {}).get("spindle_options") else None)

    def key(self, req) -> Tuple:
        return (req.family, req.alloy, req.operation, req.geometry, round(req.diameter, 5), req.flutes, round(req.flute_length, 5),
                round(req.shank_diameter or 0, 5), round(req.corner_radius, 5), round(req.stickout or 0, 5), req.coating, req.apply_coating,
                req.brand, req.aggressiveness, req.max_rpm, req.max_hp, req.runout, req.cut_depth, req.cut_width, req.model,
                req.finish_mode, req.target_ra, req.wall_tolerance, req.is_carbide)

    def run(self, c: Dict[str, Any]):
        """The engine result for the candidate, or None when the run cap (or the shared budget) is used up or the engine refused."""
        from pipeline import run_cut
        req = self.request(c)
        k = self.key(req)
        if k in self.cache:
            return self.cache[k]
        if self.exhausted():
            return None
        self.runs += 1
        if self.budget is not None:
            self.budget["runs"] = self.budget.get("runs", 0) - 1
        try:
            res = run_cut(self.physics, req)
        except Exception as e:      # the engine could not run this candidate: it is not a candidate
            res = {"error": f"{type(e).__name__}: {e}"[:200]}
        self.cache[k] = res
        return res


# ===================================================================================================================
# scoring
# ===================================================================================================================

def _has_chip_space(res: Any) -> bool:
    """True when the engine result carries a ``chip_space`` block (the engine limits chip space by flute count itself)."""
    if res is None or isinstance(res, dict):
        return False
    if getattr(res, "chip_space", None):
        return True
    v2 = getattr(res, "v2", None)
    return isinstance(v2, dict) and bool(v2.get("chip_space"))


def _chip_space_block(res: Any) -> Optional[Dict[str, Any]]:
    if getattr(res, "chip_space", None):
        return res.chip_space
    v2 = getattr(res, "v2", None)
    return v2.get("chip_space") if isinstance(v2, dict) and v2.get("chip_space") else None


def _basis(res: Any) -> Optional[Dict[str, Any]]:
    vb = getattr(res, "vendor_basis", None)
    if not isinstance(vb, dict):
        return None
    return {k: vb.get(k) for k in ("mode", "vendor", "vendor_name", "chart_class", "rows", "brand_text", "brand_key", "note")}


METRIC_LABELS = {
    "mrr_in3_min": "material removal rate (in^3/min)",
    "slot_advance_in2_min": "slot advance rate: feed x depth per level (in^2/min), the rate the toolpath moves through the feature depth",
    "finish_wall_area_rate_in2_min": "wall finish rate: feed x depth per pass (in^2/min) at the finish targets",
    "finish_area_rate_in2_min": "finish rate: feed x stepover (in^2/min) at the finish targets",
}


def _depth_per_level(cut: Cut, doc: float) -> float:
    """Depth the toolpath advances per Z level: the feature depth over the number of levels when the depth is known."""
    depth = cut.spec["feature"]["depth"] or cut.min_reach
    if depth and doc > 0:
        return depth / max(1, math.ceil(depth / doc - 1e-9))
    return doc


def _rate(cut: Cut, res: Any) -> Tuple[float, str]:
    """(rate, metric name) of a result. Roughing: the material removal rate, except in a full slot whose width is the tool's own (a
    free kerf: a bigger tool cuts a wider slot, so MRR would credit work the part does not need), where it is feed x depth per
    level. Finishing: the rate at which the finish mode's Ra and wall targets are met (feed x stepover for a floor or 3D surface,
    feed x depth per level for a wall)."""
    if cut.finishing:
        fin = getattr(res, "finish", None) or {}
        if fin.get("surface_kind") in ("floor", "surface3d"):
            return res.feed_ipm * (fin.get("stepover_in") or res.woc), "finish_area_rate_in2_min"
        return res.feed_ipm * _depth_per_level(cut, res.doc), "finish_wall_area_rate_in2_min"
    if cut.full_slot:
        return res.feed_ipm * _depth_per_level(cut, res.doc), "slot_advance_in2_min"
    if res.doc > 0:
        return res.mrr * _depth_per_level(cut, res.doc) / res.doc, "mrr_in3_min"      # no credit for depth beyond the feature
    return res.mrr, "mrr_in3_min"


def _meets(res: Any) -> Tuple[bool, Optional[str]]:
    fin = getattr(res, "finish", None)
    if not fin or fin.get("target_ra_uin") is None:
        return True, None
    bad = []
    if fin["predicted_ra_uin"] > fin["target_ra_uin"] * 1.001:
        bad.append(f"Ra {fin['predicted_ra_uin']:.0f} uin above the {fin['target_ra_uin']:.0f} uin target")
    if fin["predicted_wall_error_in"] > fin["wall_tolerance_in"] * 1.001:
        bad.append(f"wall error {fin['predicted_wall_error_in']:.5f} in above the {fin['wall_tolerance_in']:.4f} in tolerance")
    return (not bad), "; ".join(bad) or None


def _cycle_time(cut: Cut, res: Any, rate: float) -> Optional[float]:
    """Minutes for the whole feature: volume (or area, finishing) over the rate, else toolpath length x depth levels / feed."""
    f = cut.spec["feature"]
    if f["volume"] and not cut.finishing and rate > 0:
        return f["volume"] / rate
    if cut.finishing and f["area"] and rate > 0:
        return f["area"] / rate
    if f["toolpath_length"] and res.feed_ipm > 0:
        depth = f["depth"] or cut.min_reach
        levels = max(1, math.ceil(depth / res.doc - 1e-9)) if (depth and res.doc) else 1
        return f["toolpath_length"] * levels / res.feed_ipm
    return None


def _summary(cut: Cut, c: Dict[str, Any], res: Any) -> Dict[str, Any]:
    rate, metric = _rate(cut, res)
    fz = (res.feed_ipm / (res.rpm * c["flutes"])) if res.rpm and c["flutes"] else None
    out = {
        "rpm": round(res.rpm), "sfm": round(res.sfm, 1), "feed_ipm": round(res.feed_ipm, 3), "chip_load_ipt": round(fz, 6) if fz else None,
        "ap_in": round(res.doc, 5), "ae_in": round(res.woc, 5), "mrr_in3_min": round(res.mrr, 5),
        "rate": round(rate, 5), "rate_metric": metric, "is_spindle_limited": bool(res.is_spindle_limited),
        "limited_by": res.limited_by, "feasible": bool(res.feasible), "deflection_in": round(res.deflection, 6),
        "runout_in": res.runout_in, "vendor_basis": _basis(res), "model": res.model,
    }
    t = _cycle_time(cut, res, rate)
    if t is not None:
        out["cycle_time_min"] = round(t, 4)
    fin = getattr(res, "finish", None)
    if fin:
        out["finish"] = {k: fin.get(k) for k in ("mode", "surface_kind", "predicted_ra_uin", "target_ra_uin", "predicted_wall_error_in",
                                                 "wall_tolerance_in", "stepover_in", "limited_by")}
        ok, why = _meets(res)
        out["finish"]["meets_targets"] = ok
        if why:
            out["finish"]["misses"] = why
    cs = _chip_space_block(res)
    if cs:
        out["chip_space"] = cs
    return out


def _tool_dict(c: Dict[str, Any]) -> Dict[str, Any]:
    return {"diameter_in": c["diameter"], "flutes": c["flutes"], "flute_length_in": c["flute_length"], "shank_diameter_in": c["shank"],
            "stickout_in": c["stickout"], "corner_radius_in": c["corner_radius"] or 0.0, "coating": c["coating"],
            "brand": c["brand_text"], "geometry": c["geometry"]}


def _fmt_d(d: float) -> str:
    return f"{d:.4g}"


def _chart_name(c: Dict[str, Any]) -> str:
    from toolwiz_common import brand as brandmod
    return brandmod.short_name(c["brand_key"]) if c.get("brand_key") else (c.get("brand_text") or "")


def _ratio_text(ratio: float) -> str:
    return f"{ratio:.1f}x"


def _base_chart_text(cut: Cut, cur_sm: Dict[str, Any]) -> str:
    vb = cur_sm.get("vendor_basis") or {}
    mode = vb.get("mode")
    if mode == "brand":
        return f"the {vb.get('vendor_name')} chart of the current tool"
    if mode == "default":
        return "the conservative default chart ToolWiz uses for the current tool"
    if mode == "consensus":
        return "the cross-vendor consensus ToolWiz uses for the current tool"
    return "the physics limits ToolWiz uses for the current tool (it has no chart for this cut)"


def _up(text: str) -> str:
    return text[:1].upper() + text[1:]


def _why(cut: Cut, c: Dict[str, Any], res: Any, ratio: float, sm: Dict[str, Any], cur_sm: Dict[str, Any], changes: Dict[str, bool]) -> str:
    """One plain sentence naming what changed (brand chart, flute count, diameter, end form) and the ratio ToolWiz computed."""
    fam, kind_word = cut.spec["family"], _KIND_CLASS_WORD[cut.kind]
    rx = _ratio_text(ratio)
    what = ("finish rate at the same Ra and wall targets" if cut.finishing else
            "slot advance rate (feed x depth per level)" if cut.full_slot else "removal rate")
    extras = []
    if changes.get("flutes"):
        extras.append(f"{c['flutes']} flutes instead of {cut.z0}")
    if changes.get("diameter"):
        extras.append(f"a {_fmt_d(c['diameter'])} in diameter instead of {_fmt_d(cut.D0)} in")
    if changes.get("square"):
        extras.append("a square end (the corner radius is dropped)")
    tail = " and ".join(extras)
    if changes.get("brand") and (sm["vendor_basis"] or {}).get("mode") == "brand":
        name = _chart_name(c)
        base = _base_chart_text(cut, cur_sm)
        return (f"The {name} chart for {fam} {kind_word} (the vendor's published chart, not a measured tool test) allows {rx} the {what} of "
                f"{base}" + (f", with {tail}" if tail else "") + ".")
    if c["source"] == "library":
        lib = c["library"]
        who = f"your {('T' + str(lib['number']) + ' ') if lib.get('number') else ''}{lib['description']}"
        return f"{_up(who)} fits the feature: {tail or 'its own geometry'} gives {rx} the {what}."
    return f"{_up(tail or 'a different catalog geometry')} gives {rx} the {what}."


def _chip_space_caveat(cut: Cut, c: Dict[str, Any], res: Any, cur_res: Any) -> Optional[str]:
    """The flute-count caveat, for a flute-count increase in a full slot only. The engine's chip-room check (C15, result block
    ``chip_space``) passes most normal-depth slots; what makes more flutes look better is that the chip-load limit is the same
    for every flute count, while vendors run fewer-flute tools at higher chip loads in slots (docs/research/chip_space.md)."""
    if c["flutes"] <= cut.z0 or not cut.full_slot:
        return None
    if _has_chip_space(res) or _has_chip_space(cur_res):
        return (f"Flute-count gain is optimistic: ToolWiz checks chip room, but it gives a {c['flutes']}-flute and a {cut.z0}-flute tool "
                "the same chip load per tooth. Vendors run fewer-flute tools at higher chip loads in full slots, most of all in "
                "aluminum. Try the feed in steps and watch chip evacuation.")
    return ("ToolWiz does not yet limit chip space by flute count: in a full slot a " f"{c['flutes']}-flute tool has less room for chips than a "
            f"{cut.z0}-flute one, so this flute-count gain is optimistic. Check chip evacuation (flood or air blast) and try the feed in steps.")


def _caveats(cut: Cut, c: Dict[str, Any], res: Any, cur_res: Any, changes: Dict[str, bool], sm: Dict[str, Any]) -> List[str]:
    out: List[str] = []
    if changes.get("brand") and (sm["vendor_basis"] or {}).get("mode") == "brand":
        out.append(f"The gain reflects {_chart_name(c)}'s published chart for this material and operation, not a measured tool test.")
    if c["source"] == "catalog":
        ref = c.get("catalog_ref") or {}
        where = f" (series {c['series']}" + (f", e.g. part number {c['part_number']}" if c.get("part_number") else "") + ")" if c.get("series") else ""
        out.append(f"A geometry from a cited catalog row{where}: confirm the exact part number exists and is in stock before relying on it.")
        if c.get("catalog_coating"):
            out.append(f"The catalog tool is sold with a {c['catalog_coating']} coating; ToolWiz ran it with "
                       + (f"the current tool's coating ({cut.spec['tool']['coating']})." if cut.spec["tool"]["coating"] else "no coating factor."))
        if c.get("geometry_note"):
            out.append(c["geometry_note"])
    if not cut.min_reach and c["flute_length"] < cut.flen0 - 1e-6:
        out.append(f"Flute length {c['flute_length']:.4g} in is shorter than the current tool's {cut.flen0:.4g} in: check it reaches the full depth of the feature.")
    if c["source"] == "library":
        out.extend(c.get("_notes") or [])
        cur_coat = cut.spec["tool"]["coating"]
        if (c["coating"] or None) != (cur_coat or None):
            out.append(f"Coating differs from the current tool's ({c['coating'] or 'unknown'} against {cur_coat or 'unknown'}); the coating "
                       "factor is applied only when the coating is known.")
        if c["brand_text"] and not c["brand_key"]:
            out.append(f"Brand \"{c['brand_text']}\" has no charts in ToolWiz: this tool is run on the conservative default chart.")
    if changes.get("square"):
        out.append(f"The current tool's corner radius ({cut.cr0_raw:.4f} in) is dropped: vendor charts are square-end charts. Keep the radius "
                   "if the part needs it (keep_corner_radius).")
    if changes.get("diameter") and cut.limit is None:
        out.append("No feature size limit was given: this assumes the slot width or inside corner radius allows a tool this large.")
    if changes.get("diameter") and cut.limit is not None:
        out.append(f"Fits the {_fmt_d(cut.limit)} in limit you gave; check the toolpath still clears the part (corners, tabs).")
    cs = _chip_space_caveat(cut, c, res, cur_res)
    if cs:
        out.append(cs)
    if sm["is_spindle_limited"]:
        out.append(f"Spindle-limited at {sm['rpm']:,} rpm: the speed is the machine's limit, not the chart's.")
    if cut.spec["tool"]["brand"] and not cut.brand0_key and changes.get("brand"):
        out.append(f"The current tool's brand \"{cut.spec['tool']['brand']}\" has no charts in ToolWiz, so it was compared on the conservative default chart.")
    return out


# ===================================================================================================================
# the recommender
# ===================================================================================================================

_RESULTS: "OrderedDict[str, Dict[str, Any]]" = OrderedDict()
_RESULTS_LOCK = threading.Lock()


def clear_cache() -> None:
    with _RESULTS_LOCK:
        _RESULTS.clear()


def _cache_key(body: Dict[str, Any], machine: Dict[str, Any]) -> str:
    keep = {k: v for k, v in body.items() if k != "library_tools"}
    lib = body.get("library_tools")
    return json.dumps([keep, machine["max_rpm"], machine["max_hp"], json.dumps(lib, sort_keys=True, default=str) if lib is not None else _library_fingerprint(),
                       os.path.getmtime(CATALOG_PATH)], sort_keys=True, default=str)


def recommend(body: Dict[str, Any], *, physics: Any = None, machine_profile: Optional[Dict[str, Any]] = None,
              library_tools: Optional[List[Dict[str, Any]]] = None, run_cache: Optional[Dict[Any, Any]] = None,
              budget: Optional[Dict[str, int]] = None, max_library: int = MAX_LIBRARY_CANDIDATES) -> Dict[str, Any]:
    """Alternatives for one cut. ``body``: see docs/TOOL_RECOMMENDER.md. ``library_tools`` are parsed library tools (default: the owner's
    libraries); ``run_cache`` is a dict shared across calls (the Setup Advisor passes its own), ``budget`` a shared ``{"runs": n}`` that
    every uncached engine run decrements. Raises ValueError on bad input."""
    import strategy_planner
    spec = parse_request(body)
    machine = strategy_planner.machine_defaults(machine_profile)
    if spec["max_rpm"]:
        machine = dict(machine, max_rpm=spec["max_rpm"])
    if spec["max_hp"]:
        machine = dict(machine, max_hp=spec["max_hp"])
    use_result_cache = run_cache is None and budget is None and library_tools is None
    ck = None
    if use_result_cache:
        ck = _cache_key(body, machine)
        with _RESULTS_LOCK:
            hit = _RESULTS.get(ck)
            if hit is not None:
                _RESULTS.move_to_end(ck)
                return copy.deepcopy(hit)
    physics = physics or strategy_planner._physics()
    out = _recommend(spec, machine, physics, library_tools, run_cache, budget, max_library)
    if ck is not None:
        with _RESULTS_LOCK:
            _RESULTS[ck] = copy.deepcopy(out)
            while len(_RESULTS) > RESULT_CACHE_SIZE:
                _RESULTS.popitem(last=False)
    return out


def _recommend(spec, machine, physics, library_tools, run_cache, budget, max_library=MAX_LIBRARY_CANDIDATES) -> Dict[str, Any]:
    cut = Cut(spec, machine)
    runner = Runner(physics, cut, run_cache, budget, spec["max_runs"])
    cur = current_candidate(cut)
    cur_res = runner.run(cur)
    if cur_res is None or isinstance(cur_res, dict):
        raise ValueError("ToolWiz could not run the current tool: " + (cur_res.get("error") if isinstance(cur_res, dict) else "run budget used up"))
    if cut.finishing and getattr(cur_res, "finish", None):
        fin = cur_res.finish
        runner.finish_targets = {"mode": fin.get("mode"), "target_ra": fin.get("target_ra_uin"), "wall_tolerance": fin.get("wall_tolerance_in")}
    cur_sm = _summary(cut, cur, cur_res)
    cur_rate = cur_sm["rate"]
    cur_sm["tool"] = _tool_dict(cur)
    cur_sm["brand"] = {"text": cut.brand0_text, "key": cut.brand0_key}
    cur_sm["basis"] = _basis_sentence(cut, cur_res)

    skipped: List[str] = []
    evals: List[Dict[str, Any]] = []
    seen = set()

    def consider(c: Dict[str, Any], changes: Dict[str, bool]) -> Optional[Dict[str, Any]]:
        key = (c["source"] == "library", round(c["diameter"], 4), c["flutes"], round(c["flute_length"], 3), c["brand_key"] or (c["brand_text"] or "").lower(),
               round(c["corner_radius"], 4), (c["library"] or {}).get("description"))
        if key in seen:
            return None
        seen.add(key)
        res = runner.run(c)
        if res is None:
            skipped.append("engine-run cap reached: " + _label(c) + " not evaluated")
            return None
        if isinstance(res, dict):
            skipped.append(f"{_label(c)}: ToolWiz could not run it ({res.get('error')})")
            return None
        sm = _summary(cut, c, res)
        if not sm["feasible"] and cur_sm["feasible"]:
            skipped.append(f"{_label(c)}: no safe cut found (limited by {sm['limited_by'] or 'unknown'})")
            return None
        if cut.finishing and not sm["finish"]["meets_targets"] and (cur_sm.get("finish") or {}).get("meets_targets", True):
            skipped.append(f"{_label(c)}: cannot meet the finish targets ({sm['finish'].get('misses')})")
            return None
        if changes.get("brand") and (sm["vendor_basis"] or {}).get("mode") != "brand":
            skipped.append(f"{_label(c)}: ToolWiz has no {_chart_name(c)} chart for this cut, so the numbers are the default chart's")
            return None
        ratio = (sm["rate"] / cur_rate) if cur_rate > 0 else float("inf")
        ev = {"cand": c, "res": res, "sm": sm, "ratio": ratio, "changes": changes}
        evals.append(ev)
        return ev

    # ---- (a) the owner's library ------------------------------------------------------------------------------------
    lib_skipped: List[str] = []
    n_lib = 0
    if spec["use_library"]:
        tools = library_tools if library_tools is not None else (spec["library_tools"] if spec["library_tools"] is not None else load_library_tools())
        if spec["library_tools"] is not None and library_tools is None:
            import setup_advisor
            tools = [dict(setup_advisor.parse_tool(t), raw_type=str((t or {}).get("type") or "flat end mill"), library="request") for t in tools if isinstance(t, dict)]
        cands, lib_skipped = library_candidates(cut, tools, max_library)
        n_lib = len(cands)
        for c in cands:
            changes = {"diameter": abs(c["diameter"] - cut.D0) > SAME_DIAMETER_TOL * cut.D0, "flutes": c["flutes"] != cut.z0,
                       "brand": False, "square": False}
            consider(c, changes)
    skipped.extend(lib_skipped[:6])

    # ---- (b)-(d) the catalog ------------------------------------------------------------------------------------------
    catalog_notes: List[str] = []
    if spec["use_catalog"] and cut.geometry0 != "Ball":
        _catalog_phase(cut, runner, consider, catalog_notes)
    elif spec["use_catalog"]:
        catalog_notes.append("Ball-nose tools: vendor charts are for square-end tools, so the catalog is not searched; only your library was.")
    skipped.extend(catalog_notes)

    # ---- assemble -------------------------------------------------------------------------------------------------------
    alts = []
    for ev in evals:
        c, sm = ev["cand"], ev["sm"]
        gain = (ev["ratio"] - 1.0) * 100.0
        entry = _alternative(cut, c, ev, cur_res, cur_sm, gain)
        alts.append(entry)
    passing = [a for a in alts if a["gain_pct"] >= spec["min_gain_pct"]]
    below = [a for a in alts if a["gain_pct"] < spec["min_gain_pct"]]
    order = lambda a: (a["short_flute"], -a["gain_pct"], 0 if a["source"] == "library" else 1, a["diameter"], a["flutes"], str(a.get("brand") or ""))
    passing.sort(key=order)
    below.sort(key=order)
    best_lib = next((a for a in passing if a["source"] == "library"), None)
    best_cat = next((a for a in passing if a["source"] == "catalog"), None)
    out: Dict[str, Any] = {
        "success": True, "model": spec["model"], "family": spec["family"], "alloy": spec["alloy"], "operation": spec["operation"],
        "kind": "finishing" if cut.finishing else "roughing", "rate_metric": cur_sm["rate_metric"],
        "rate_metric_label": METRIC_LABELS[cur_sm["rate_metric"]], "min_gain_pct": spec["min_gain_pct"],
        "aggressiveness": spec["aggressiveness"], "current": cur_sm, "alternatives": passing[:MAX_ALTERNATIVES],
        "best_library": best_lib, "best_catalog": best_cat,
        "below_threshold": below[:MAX_BELOW], "not_recommended_reasons": [],
        "assumptions": list(cut.notes), "disclaimers": list(DISCLAIMERS),
        "skipped": skipped[:12],
        "engine_runs": runner.runs, "run_cap": spec["max_runs"], "candidates_evaluated": len(evals),
        "library_tools_fitting": n_lib, "feature": {k: v for k, v in spec["feature"].items() if v is not None},
    }
    if not cut.brand0_key:
        out["disclaimers"].append(
            (f"The current tool's brand \"{cut.brand0_text}\" has no charts in ToolWiz, so" if cut.brand0_text else "The current tool has no brand, so")
            + " it is compared on the conservative default chart (Harvey and Helical charts); a brand gain below is against that chart.")
    if not passing:
        out["not_recommended_reasons"] = _reasons(cut, cur_res, cur_sm, alts, spec, n_lib, lib_skipped, catalog_notes)
        out["summary"] = ("No tool change is worth it: " + out["not_recommended_reasons"][0]) if out["not_recommended_reasons"] else \
            "No tool change is worth it for this cut."
    else:
        top = passing[0]
        out["summary"] = (f"{len(passing)} alternative{'s' if len(passing) != 1 else ''} at least {spec['min_gain_pct']:.0f}% better: the best is "
                          f"+{top['gain_pct']:.0f}% ({_label_alt(top)}). {top['why']}")
    return out


_METRIC_SHORT = {"mrr_in3_min": ("MRR", "in3/min"), "slot_advance_in2_min": ("slot advance rate", "in2/min"),
                 "finish_wall_area_rate_in2_min": ("wall finish rate", "in2/min"), "finish_area_rate_in2_min": ("finish rate", "in2/min")}


def describe_alternative(alt: Dict[str, Any], current: Dict[str, Any]) -> str:
    """One sentence with the numbers ToolWiz computed for an alternative against the current tool (used by the Setup Advisor)."""
    name, unit = _METRIC_SHORT[alt["rate_metric"]]
    bits = [f"{alt['rpm']:,} rpm", f"{alt['feed']:.2f} IPM", f"{alt['ap']:.4f} x {alt['ae']:.4f} in"]
    tail = f"{name} {alt['rate']:.4f} {unit} against {current['rate']:.4f} now (+{alt['gain_pct']:.0f}%)"
    if alt.get("cycle_time_min") is not None and current.get("cycle_time_min") is not None:
        tail += f", cycle time {alt['cycle_time_min']:.2f} min against {current['cycle_time_min']:.2f} min"
    return f"{_label_alt(alt)}: " + ", ".join(bits) + "; " + tail


def _label(c: Dict[str, Any]) -> str:
    base = f"{c['flutes']}FL {_fmt_d(c['diameter'])} in"
    if c["source"] == "library":
        lib = c["library"]
        return f"{('T' + str(lib['number']) + ' ') if lib.get('number') else ''}{lib['description']}"
    return f"{_chart_name(c) or 'any brand'} {base}"


def label_alternative(a: Dict[str, Any]) -> str:
    return _label_alt(a)


def _label_alt(a: Dict[str, Any]) -> str:
    if a["source"] == "library":
        return a["library_tool"]["description"]
    return f"{a.get('brand') or 'any brand'} {a['flutes']}-flute {_fmt_d(a['diameter'])} in"


def _basis_sentence(cut: Cut, res: Any) -> str:
    vb = _basis(res) or {}
    mode = vb.get("mode")
    if mode == "brand":
        return f"The current tool is compared on {vb.get('vendor_name')}'s own {vb.get('chart_class')} chart."
    if mode == "default":
        who = (f"Its brand \"{cut.brand0_text}\" has no charts in ToolWiz" if cut.brand0_text and not cut.brand0_key
               else (f"{_display(cut.brand0_key)} has no chart for this cut" if cut.brand0_key else "No brand was given"))
        return f"{who}, so the current tool is compared on the conservative default chart ({vb.get('vendor_name')})."
    if mode == "consensus":
        return "The current tool is compared on the cross-vendor consensus of the published charts (no brand chart for this end form or cut)."
    return "ToolWiz has no vendor chart for this cut: the numbers are physics limits only, so a brand change cannot change them."


def _alternative(cut: Cut, c: Dict[str, Any], ev: Dict[str, Any], cur_res: Any, cur_sm: Dict[str, Any], gain: float) -> Dict[str, Any]:
    sm, res, changes = ev["sm"], ev["res"], ev["changes"]
    brand = (_chart_name(c) or None) if c["brand_key"] or c["brand_text"] else None
    entry: Dict[str, Any] = {
        "source": c["source"], "brand": brand, "brand_key": c["brand_key"],
        "series": c.get("series") if changes.get("brand") else None, "diameter": c["diameter"],
        "flutes": c["flutes"], "flute_length": c["flute_length"], "shank_diameter": c["shank"], "stickout": c["stickout"],
        "corner_radius": c["corner_radius"] or 0.0, "coating": c["coating"],
        "rpm": sm["rpm"], "feed": sm["feed_ipm"], "feed_ipm": sm["feed_ipm"], "ap": sm["ap_in"], "ae": sm["ae_in"], "mrr": sm["mrr_in3_min"],
        "rate": sm["rate"], "rate_metric": sm["rate_metric"], "gain_pct": round(gain, 1), "gain_ratio": round(ev["ratio"], 2),
        "time_saved_pct": round((1.0 - 1.0 / ev["ratio"]) * 100.0, 1) if ev["ratio"] > 0 else None,
        "short_flute": bool(not cut.min_reach and c["flute_length"] < cut.flen0 - 1e-6),
        "limited_by": sm["limited_by"], "feasible": sm["feasible"], "is_spindle_limited": sm["is_spindle_limited"],
        "deflection_in": sm["deflection_in"], "vendor_basis": sm["vendor_basis"], "changes": [k for k, v in changes.items() if v],
    }
    if sm.get("cycle_time_min") is not None and cur_sm.get("cycle_time_min"):
        entry["cycle_time_min"] = sm["cycle_time_min"]
        entry["cycle_time_saved_pct"] = round((1.0 - sm["cycle_time_min"] / cur_sm["cycle_time_min"]) * 100.0, 1)
    if sm.get("finish"):
        entry["finish"] = sm["finish"]
    if sm.get("chip_space"):
        entry["chip_space"] = sm["chip_space"]
    if c["source"] == "library":
        entry["library_tool"] = dict(c["library"])
    else:
        entry["catalog_ref"] = c.get("catalog_ref")
        entry["part_number_example"] = c.get("part_number") if changes.get("brand") else None
        if not changes.get("brand"):
            entry["geometry_source"] = "flute count and flute length taken from a cited catalog row (numbers are on the current tool's chart)"
    entry["why"] = _why(cut, c, res, ev["ratio"], sm, cur_sm, changes)
    entry["caveats"] = _caveats(cut, c, res, cur_res, changes, sm)
    return entry


def _catalog_phase(cut: Cut, runner: Runner, consider, notes: List[str]) -> None:
    fam, kind = cut.spec["family"], cut.kind
    real_radius = cut.geometry0 == "Radiused"
    cr_keep = cut.cr0 if real_radius else 0.0
    geo = "Radiused" if real_radius else "Square"
    # Vendor charts are square-end charts: a real corner radius is compared on the shaped-tool consensus whatever the brand, so brand
    # candidates are square-end tools and are only tried when the radius may be dropped.
    brand_ok = not real_radius or not cut.keep_radius
    drop_radius = real_radius and brand_ok
    # (c) other flute counts of the current brand (any brand when unbranded), at this diameter
    flute_pick: List[Dict[str, Any]] = []
    for e in _vendor_options_any(cut, cut.D0, cut.brand0_key):
        if e["flutes"] != cut.z0 and e["flutes"] not in [p["flutes"] for p in flute_pick]:
            flute_pick.append(e)
    for e in flute_pick[:MAX_FLUTE_VARIANTS]:
        c = _catalog_candidate(cut, e, brand_key=cut.brand0_key, brand_text=cut.brand0_text, d=cut.D0, corner_radius=cr_keep, geometry=geo)
        consider(c, {"flutes": True, "diameter": False, "brand": False, "square": False})
    # (b) other brands at this diameter
    best_brand = None
    if brand_ok:
        for v in sorted(v for v in _vendor_chart_classes() if v != cut.brand0_key):
            name = _chart_name({"brand_key": v})
            if not vendor_has_chart(v, fam, kind):
                notes.append(f"{name}: no {_KIND_CLASS_WORD[kind]} chart for {fam} in ToolWiz's data")
                continue
            opts = _vendor_flute_options(cut, v, cut.D0, cut.z0)
            if not opts:
                notes.append(f"{name}: no catalog tool near {_fmt_d(cut.D0)} in for {fam}" + (f" with a {cut.hard_reach:.4g} in flute" if cut.hard_reach else ""))
                continue
            e = opts[0]
            c = _catalog_candidate(cut, e, brand_key=v, brand_text=_display(v), d=cut.D0, corner_radius=0.0, geometry="Square")
            ev = consider(c, {"brand": True, "flutes": e["flutes"] != cut.z0, "diameter": False, "square": drop_radius})
            if ev and (best_brand is None or ev["ratio"] > best_brand["ratio"]):
                best_brand = ev
    else:
        notes.append(f"This tool has a real corner radius ({cut.cr0:.4g} in, {cut.cr0 / cut.D0 * 100:.0f}% of D): ToolWiz's vendor charts are "
                     "square-end charts, so another brand of the same radiused tool cannot change the numbers (pass keep_corner_radius false "
                     "to compare square-end tools).")
    # (d) larger diameters
    sizes = larger_sizes(cut)
    for s in sizes:
        e = _pick_size_geometry(cut, s)
        if e is None:
            notes.append(f"{_fmt_d(s)} in: no catalog tool for {fam} at that size" + (f" with a {cut.hard_reach:.4g} in flute" if cut.hard_reach else ""))
            continue
        c = _catalog_candidate(cut, e, brand_key=cut.brand0_key, brand_text=cut.brand0_text, d=s, corner_radius=cr_keep, geometry=geo)
        consider(c, {"diameter": True, "flutes": e["flutes"] != cut.z0, "brand": False, "square": False})
    # second pass: the best brand with its other flute counts and with the larger diameters
    if best_brand is not None:
        v = best_brand["cand"]["brand_key"]
        for e in _vendor_flute_options(cut, v, cut.D0, cut.z0)[1:MAX_COMBINED]:
            c = _catalog_candidate(cut, e, brand_key=v, brand_text=_display(v), d=cut.D0, corner_radius=0.0, geometry="Square")
            consider(c, {"brand": True, "flutes": e["flutes"] != cut.z0, "diameter": False, "square": drop_radius})
        for s in sizes:
            opts = _vendor_flute_options(cut, v, s, cut.z0)
            if not opts:
                continue
            e = opts[0]
            c = _catalog_candidate(cut, e, brand_key=v, brand_text=_display(v), d=s, corner_radius=0.0, geometry="Square")
            consider(c, {"brand": True, "diameter": True, "flutes": e["flutes"] != cut.z0, "square": drop_radius})


def _display(key: str) -> str:
    from toolwiz_common import brand as brandmod
    return brandmod.display_name(key)


def _vendor_options_any(cut: Cut, d: float, vendor: Optional[str]) -> List[Dict[str, Any]]:
    """One geometry per flute count at ``d``: from the current brand's rows when branded (and it has any), else from every vendor's."""
    geos = catalog_geometries(cut.spec["family"], cut.kind, d, vendor=vendor, min_flute_length=cut.hard_reach) if vendor else []
    if not geos:
        geos = catalog_geometries(cut.spec["family"], cut.kind, d, min_flute_length=cut.hard_reach)
    return _by_flutes(cut, geos, cut.z0)


def _pick_size_geometry(cut: Cut, s: float) -> Optional[Dict[str, Any]]:
    opts = _vendor_options_any(cut, s, cut.brand0_key)
    if not opts:
        return None
    for e in opts:                                  # the current flute count when it exists at that size
        if e["flutes"] == cut.z0:
            return e
    return opts[0]


def _reasons(cut: Cut, cur_res: Any, cur_sm: Dict[str, Any], alts: List[Dict[str, Any]], spec: Dict[str, Any], n_lib: int,
             lib_skipped: List[str], catalog_notes: List[str]) -> List[str]:
    out: List[str] = []
    brand_alts = [a for a in alts if "brand" in a["changes"] and "flutes" not in a["changes"]]
    flute_alts = [a for a in alts if a["changes"] == ["flutes"]]
    dia_alts = [a for a in alts if "diameter" in a["changes"]]
    thr = spec["min_gain_pct"]
    mode = (cur_sm["vendor_basis"] or {}).get("mode")
    best = lambda xs: max((a["gain_pct"] for a in xs), default=None)
    if cur_sm["is_spindle_limited"]:
        out.append(f"spindle-limited at {cur_sm['rpm']:,} rpm: brand makes no difference in {spec['family']} at this diameter, because the "
                   "machine's speed limit sets the feed, not a chart"
                   + (f" (best brand gain at your flute count {best(brand_alts):.0f}%)." if brand_alts else "."))
    elif mode == "none":
        out.append(f"ToolWiz has no vendor chart for {spec['family']} {_KIND_CLASS_WORD[cut.kind]} at this diameter: brand makes no difference "
                   f"(the cut is limited by {cur_sm['limited_by'] or 'physics'}).")
    elif brand_alts:
        out.append(f"no other brand's chart is {thr:.0f}% better at this diameter (best: +{best(brand_alts):.0f}%); the cut is limited by "
                   f"{cur_sm['limited_by'] or 'the current limits'}.")
    elif cut.geometry0 == "Radiused":
        out.append("this tool has a real corner radius, and ToolWiz's vendor charts are square-end charts, so another brand cannot change the numbers.")
    if flute_alts:
        out.append(f"other flute counts gain at most {best(flute_alts):.0f}% (below {thr:.0f}%).")
    if dia_alts:
        out.append(f"larger tools gain at most {best(dia_alts):.0f}% (below {thr:.0f}%).")
    elif not cut.larger_allowed:
        out.append("no larger tool is tried: " + ("the slot is as wide as the current tool." if cut.full_slot else "the feature allows no larger diameter."))
    elif cut.limit is not None and cut.limit <= cut.D0 * (1 + 0.04):
        out.append(f"no larger tool fits: the feature limit is {_fmt_d(cut.limit)} in.")
    if spec["use_library"]:
        lib_alts = [a for a in alts if a["source"] == "library"]
        if lib_alts:
            out.append(f"none of your library tools is {thr:.0f}% better (best: +{best(lib_alts):.0f}%).")
        elif n_lib == 0:
            out.append("none of your library end mills fits this feature" + (f" ({lib_skipped[0]})." if lib_skipped else "."))
    if cur_sm["rate"] <= 0:
        out.append("the current tool has no feasible cut at these settings; check the tool and stickout first.")
    if not out:
        out.append(f"no candidate tool is {thr:.0f}% better than the current one.")
    return out
