"""v1/v2 cutting-model switch (design §6 step 5).

v1 (GWizard tables + rules) always runs first. When v2 is selected and the cut is in v2.0's scope (a carbide
square end mill, an operation v2 models, a calibrated material family), the physics optimizer
(physics_v2.params / optimize) replaces rpm, chip load, feed, DOC and WOC, and the helical-entry model
(physics_v2/ramp.py) replaces the ramp angle, ramp and plunge feeds and adds the helix diameter and ramp spindle
speed (details in ``result.v2["ramp"]``); v1's numbers are kept in ``result.v1`` for comparison. Out of scope, v1 stands and ``result.model_note`` says why.

Model choice, highest first: the request's ``model``; the saved setting (data/model_settings.json, set from
the web page and used by the Fusion add-in through the server); the TOOLWIZ_MODEL environment variable; v1.
"""
import copy
import json
import math
import os
import threading
from collections import OrderedDict

ROOT = os.path.dirname(os.path.abspath(__file__))
SETTINGS_PATH = os.path.join(ROOT, "data", "model_settings.json")
MODELS = ("v1", "v2")
KW_TO_HP = 1.341

# Operation names (web page / Fusion strategy) -> v2 operation. Others stay on v1 for now.
OPERATION_MAP = {
    # HEM: constant-engagement toolpaths (low radial, deep axial) -> the vendors' HEM charts
    "adaptive roughing": "adaptive", "adaptive clearing": "adaptive", "2d adaptive clearing": "adaptive",
    "3d adaptive clearing": "adaptive", "adaptive": "adaptive", "trochoidal": "adaptive", "trochoidal milling": "adaptive",
    "dynamic": "adaptive", "dynamic milling": "adaptive", "hem": "adaptive", "high efficiency milling": "adaptive",
    "3d adaptive": "adaptive",
    # traditional roughing (wider radial): offset pockets and roughing contours -> the vendors' roughing charts (owner
    # decision 4, 2026-11-12: a pocket is not HEM; before, pockets were mapped to adaptive)
    "pocket clearing": "rough", "pocket": "rough", "2d pocket": "rough", "3d pocket": "rough",
    "standard roughing": "rough", "roughing": "rough", "contour (roughing)": "rough", "2d contour (roughing)": "rough",
    "roughing contour": "rough", "contour roughing": "rough", "3d roughing": "rough", "rest roughing": "rough",
    # slots
    "slotting / tab milling": "slot", "slotting": "slot", "slot": "slot", "slot milling": "slot",
    # finishing
    "wall finishing (deep doc)": "finish", "wall finishing": "finish", "finishing": "finish",
    "3d finishing": "finish", "finishing (3d)": "finish", "scallop": "finish", "3d scallop": "finish", "parallel": "finish",
    "contour finishing": "finish", "3d contour": "finish", "3d contouring": "finish", "pencil": "finish",
}
# High-feed end mills (physics_v2/highfeed.py): an operation named for high-feed milling maps to a slot when it says so, else
# to roughing (pocket / facing-style passes); only a high-feed tool runs it on v2 (a square or bull-nose tool keeps v1's rule).
HIGH_FEED_OPERATIONS = ("high feed", "high-feed", "highfeed", "hfm")
NOT_SQUARE = ("chamfer", "v-bit", "engrav", "taper", "dovetail", "lollipop",
              "t-slot", "keyseat", "woodruff", "thread", "drill", "ream", "tap", "saw", "face", "form")


# ---------------------------------------------------------------------------
# Model selection
# ---------------------------------------------------------------------------

def _norm(model):
    m = str(model or "").strip().lower()
    return m if m in MODELS else None


def saved_model(path=None):
    try:
        with open(path or SETTINGS_PATH, encoding="utf-8") as fh:
            return _norm(json.load(fh).get("model"))
    except (OSError, ValueError, AttributeError):
        return None


def save_model(model, path=None):
    m = _norm(model)
    if m is None:
        raise ValueError(f"model must be one of {', '.join(MODELS)}")
    path = path or SETTINGS_PATH
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as fh:
        json.dump({"model": m}, fh, indent=2)
    os.replace(tmp, path)
    return m


def resolve_model(requested=None, use_saved=True, path=None):
    """(model, source): the request, then the saved setting, then TOOLWIZ_MODEL, then v2 (the physics model)."""
    m = _norm(requested)
    if m:
        return m, "request"
    if use_saved:
        m = saved_model(path)
        if m:
            return m, "saved setting"
    m = _norm(os.environ.get("TOOLWIZ_MODEL"))
    if m:
        return m, "TOOLWIZ_MODEL"
    return "v2", "default"


# ---------------------------------------------------------------------------
# Scope and inputs
# ---------------------------------------------------------------------------

def _families():
    from physics_v2 import params
    return params.load()["families"]


def is_high_feed(r):
    """True when the request names a high-feed end mill (geometry "High Feed", or tool text with high feed / HF / HFM)."""
    from physics_v2 import highfeed
    return highfeed.is_high_feed(r.geometry, r.tool)


def scope(r, res):
    """(v2 operation, None) when v2.0 covers this cut, else (None, reason)."""
    if res.is_hole_tool or res.is_tapping:
        return None, "v2.0 covers end mills only (hole tool or tap)"
    geo = f"{r.geometry} {r.tool}".lower()
    if any(k in geo for k in NOT_SQUARE):
        return None, "v2 covers square, bull-nose and ball end mills (chamfer, form, taper and other tools stay on v1)"
    if not r.is_carbide:
        return None, "v2.0 models solid carbide tools only"
    name = str(r.operation).strip().lower()
    op = OPERATION_MAP.get(name)
    hf = is_high_feed(r)
    if op is None and any(k in name for k in HIGH_FEED_OPERATIONS):
        if not hf:
            return None, ("high-feed milling with a square or bull-nose tool stays on v1 (v2 models it with a high-feed end "
                          "mill: geometry \"High Feed\")")
        op = "slot" if ("slot" in name or "window" in name) else "rough"
    if hf and op == "finish":
        return None, "a high-feed end mill roughs; v2 does not finish with it (v1 stands)"
    if op is None:
        return None, f"v2.0 doesn't model the {r.operation!r} operation yet (adaptive, roughing, slotting and wall finishing)"
    if r.family not in _families():
        return None, f"no calibrated v2 data for {r.family!r}"
    if r.profile is None:
        return None, "no tool profile"
    return op, None


def machine_for(r, machine_profile=None):
    """optimize.Machine from the active machine profile, the request's limits (max rpm, max hp, runout) and
    the profile's holder stiffness. Falls back to the built-in Speedio 16k profile."""
    from physics_v2 import optimize as o
    import machine_profiles
    prof = machine_profile
    if not prof or not prof.get("spindle_options"):
        with open(os.path.join(machine_profiles.BUILTIN_DIR, "speedio_s500x2.json"), encoding="utf-8") as fh:
            prof = json.load(fh)
    key = prof.get("active_spindle")
    spindles = prof.get("spindle_options") or {}
    sp = copy.deepcopy(spindles.get(key) or next(iter(spindles.values())))
    notes = []
    # A Max HP override below the profile's continuous power scales the continuous curve down with it.
    p_kw = float(sp.get("power_kw_continuous") or 0.0)
    if p_kw > 0 and r.max_hp and r.max_hp / KW_TO_HP < p_kw * 0.999:
        f = (r.max_hp / KW_TO_HP) / p_kw
        sp["power_kw_continuous"] = p_kw * f
        rating = ((sp.get("torque_curve") or {}).get("ratings") or {}).get("continuous")
        if rating and rating.get("points"):
            rating["points"] = [[rpm, t * f] for rpm, t in rating["points"]]
        notes.append(f"continuous power scaled to the Max HP override ({r.max_hp:.2f} hp)")
    max_rpm = float(sp.get("max_rpm") or r.max_rpm or 16000.0)
    if r.max_rpm and r.max_rpm < max_rpm:
        max_rpm = float(r.max_rpm)
    feed = prof.get("max_cutting_feed_mm_min")
    tir_in = float(r.runout if r.runout is not None else 0.0002)
    m = o.Machine(sp, max_rpm, "continuous", tir_in, "eccentric",
                  f"{prof.get('machine', 'machine')} ({sp.get('label') or key})",
                  feed / 25.4 if feed else None)
    hs = prof.get("holder_stiffness")
    if hs:
        from dataclasses import replace
        m = replace(m, holder_k_n_um=hs.get("k_n_um"), holder_ktheta_nm_urad=hs.get("ktheta_nm_urad"),
                    holder_basis=hs.get("status", ""))
    return m, notes


EDGE_BREAK_OVER_D = 0.01   # a corner radius below 1 % of D is an edge break: the tool is modelled as square


def corner_radius_in(r, diameter):
    """The corner radius (in) the v2 model uses: D/2 for a ball nose, the request's radius for a bull nose, 0 for a square
    end (and for an edge-break radius under 1 % of D)."""
    geo = f"{r.geometry} {r.tool}".lower()
    if "ball" in geo:
        return diameter / 2.0
    rc = float(r.corner_radius or 0.0)
    if rc < EDGE_BREAK_OVER_D * diameter:
        return 0.0
    return min(rc, diameter / 2.0)


def high_feed_geometry(r):
    """physics_v2.highfeed.Geometry of a high-feed request (max ap, lead angle or programming radius from the request,
    defaults marked assumed), else None."""
    if not is_high_feed(r):
        return None
    from physics_v2 import highfeed
    D = float(r.profile.geometry.diameter)
    return highfeed.resolve(D, getattr(r, "max_ap", None), getattr(r, "lead_angle", None), float(r.corner_radius or 0.0))


def tool_for(r):
    from physics_v2 import optimize as o
    g = r.profile.geometry
    hf = high_feed_geometry(r)
    return o.Tool(r.profile, float(g.diameter), int(g.flutes), float(g.flute_length),
                  helix_deg=float(r.helix_angle or 35.0),
                  corner_radius_in=0.0 if hf else corner_radius_in(r, float(g.diameter)),
                  label=f"{g.diameter:.4f}\" {int(g.flutes)}FL" + (" high-feed" if hf else ""), high_feed=hf)


# ---------------------------------------------------------------------------
# Optimizer call (cached: roughing/adaptive take ~2 s)
# ---------------------------------------------------------------------------

_CACHE = OrderedDict()
_CACHE_LOCK = threading.Lock()
_CACHE_SIZE = 128


def _setup(physics, r, op, machine_profile):
    """(hb, tool, machine, notes, finish kwargs) shared by the recommendation and the user-engagement calls."""
    from physics_v2 import optimize as o
    hb = None
    try:
        hb = physics.resolve_alloy_hardness(r.family, r.alloy) if r.alloy else None
    except Exception:
        hb = None
    tool = tool_for(r)
    machine, notes = machine_for(r, machine_profile)
    kw = {}
    if op == "finish":
        import finish_modes
        kw["wall_tolerance_in"] = finish_modes.resolve(r)[2]
        kw["stock"] = float(r.cut_width) if r.cut_width else o.STOCK_TO_LEAVE_IN
        if r.cut_depth:
            kw["wall_height"] = min(float(r.cut_depth), tool.lcf)
    return hb, tool, machine, notes, kw


def _cache_key(r, op, hb, machine, kw, extra=None):
    return json.dumps({
        "fam": r.family, "hb": hb, "coat": r.coating, "op": op, "a": round(float(r.aggressiveness), 4),
        "prof": r.profile.to_dict(), "helix": r.helix_angle,
        # the profile's segments carry no flute count or end form: without these a 5-flute tool got a 2-flute answer
        "z": int(r.profile.geometry.flutes), "d": float(r.profile.geometry.diameter),
        "rc": round(corner_radius_in(r, float(r.profile.geometry.diameter)), 6), "carbide": bool(getattr(r, "is_carbide", True)), "kw": kw, "extra": extra, "brand": getattr(r, "brand_key", None),
        # C15 chip space reads flutes, D, family, operation, aggressiveness and the user's ap/ae (all above) and its
        # parameter file: a recalibrated file must not be answered from the cache
        "cs": _chip_space_version(),
        # flute-aware chip load (C2 / C14 × F(flutes)): a refitted file must not be answered from the cache
        "cf": _data_version("chip_by_flutes.json"),
        # high-feed chart class level (C7 and C2 for high-feed tools): a refitted file must not be answered from the cache
        "hl": _data_version("high_feed_level.json"),
        # high-feed end mill: lead angle, max ap and the programming radius they came from (None for other tools)
        "hf": (lambda g: [g.lead_deg, g.apmx_in, g.programming_radius_in, list(g.assumed)] if g else None)(high_feed_geometry(r)),
        "m": [machine.label, machine.max_rpm, machine.tir_in, machine.spindle.get("power_kw_continuous"),
              machine.holder_k_n_um, machine.holder_ktheta_nm_urad, machine.max_feed_ipm],
    }, sort_keys=True, default=str)


def _chip_space_version():
    """The C15 parameter file's identity (version and the packing per group) for the cache key."""
    try:
        from physics_v2 import chipspace
        p = chipspace.load()
        return [p.get("version"), sorted((g, v.get("K")) for g, v in (p.get("packing") or {}).items())]
    except (OSError, ValueError):
        return None


def _data_version(name):
    """A data/model_v2 file's version (None when absent)."""
    try:
        with open(os.path.join(ROOT, "data", "model_v2", name), encoding="utf-8") as fh:
            return json.load(fh).get("version")
    except (OSError, ValueError):
        return None


def _cached(key, compute):
    with _CACHE_LOCK:
        if key in _CACHE:
            _CACHE.move_to_end(key)
            return _CACHE[key]
    out = compute()
    with _CACHE_LOCK:
        _CACHE[key] = out
        while len(_CACHE) > _CACHE_SIZE:
            _CACHE.popitem(last=False)
    return out


def _optimize(physics, r, op, machine_profile):
    """The optimizer's recommendation (ap, ae, rpm, fz) for this tool, material and machine, with its ramp."""
    from physics_v2 import params
    hb, tool, machine, notes, kw = _setup(physics, r, op, machine_profile)

    def compute():
        material = params.material(r.family, hb=hb, coating=r.coating)
        out = params.optimize(tool, material, op, float(r.aggressiveness), machine_=machine, robust=False,
                              robustness=False, brand=getattr(r, "brand_key", None), **kw)
        return dict(out, ramp=_ramp(tool, material, machine, r, out))
    return _cached(_cache_key(r, op, hb, machine, kw), compute), hb, notes


def _optimize_user(physics, r, op, machine_profile, ap, ae):
    """rpm and feed for the user's own ap and ae (physics_v2.optimize.evaluate_user_engagement), with its ramp."""
    from physics_v2 import params
    hb, tool, machine, notes, kw = _setup(physics, r, op, machine_profile)

    def compute():
        material = params.material(r.family, hb=hb, coating=r.coating)
        out = params.evaluate_user_engagement(tool, material, op, ap, ae, float(r.aggressiveness), machine_=machine,
                                              brand=getattr(r, "brand_key", None))
        return dict(out, ramp=_ramp(tool, material, machine, r, out))
    return _cached(_cache_key(r, op, hb, machine, kw, ("user", round(ap, 7), round(ae, 7))), compute), hb, notes


def _ramp(tool, material, machine, r, out):
    """The helical entry for this tool and material (physics_v2/ramp.py), or {"error": ...}; never raises. A high-feed end
    mill (not center cutting) gets its entry guidance from physics_v2/highfeed.py instead."""
    from physics_v2 import params, ramp
    cut = out.get("cut") or {}
    if tool.high_feed is not None:
        if not cut:
            return {"feasible": False, "error": "no cut"}
        from physics_v2 import highfeed
        return highfeed.entry_guidance(tool.high_feed, float(cut["feed_ipm"]), float(cut["rpm"]))
    try:
        return ramp.optimize_ramp(tool, material, machine, float(r.aggressiveness), consensus=params.CONSENSUS_PATH,
                                  op_feed_ipm=cut.get("feed_ipm"), op_rpm=cut.get("rpm"), coating=r.coating)
    except Exception as ex:   # the cut stands; the ramp falls back to v1's rule
        return {"feasible": False, "error": f"{type(ex).__name__}: {ex}"}


def _ramp_details(rp):
    if not rp:
        return None
    keys = ("feasible", "error", "high_feed", "basis", "ramp_angle_deg", "helix_diameter_over_D", "helix_diameter_in", "helix_min_diameter_over_D",
            "helix_min_diameter_in", "bore_diameter_in", "pitch_in", "rpm", "sfm", "spindle_rpm", "fz_in", "ramp_feed_ipm",
            "ramp_feed_at_c7_rpm_ipm", "descent_ipm", "plunge_feed_ipm", "end_chip_in", "end_chip_floor_in",
            "end_chip_cap_in", "edge_radius_mm", "edge_radius_basis", "r1_warning", "binding", "overridden", "warned",
            "conflicts", "warnings", "plunge_note", "provenance", "eliminated_by")
    out = {k: rp.get(k) for k in keys if k in rp}
    checks = rp.get("checks") or {}
    shown = list(rp.get("binding") or []) + [k for k in ("R1", "R2", "R6", "R14a", "R1p") if k in checks]
    out["checks"] = {k: _check_summary(checks[k]) for k in dict.fromkeys(shown) if k in checks}
    return out


def _check_summary(c):
    return {k: c.get(k) for k in ("id", "name", "value", "limit", "units", "ok", "margin", "detail")}


def _cut_summary(out):
    cut = (out or {}).get("cut")
    if not cut:
        return None
    return {k: cut.get(k) for k in ("ap_in", "ae_in", "ap_over_D", "ae_over_D", "rpm", "sfm", "fz_in", "feed_ipm",
                                    "mrr_in3_min")}


def _v2_details(out, hb, notes, recommended=None):
    checks = out.get("checks") or {}
    binding = list(out.get("binding") or [])
    shown = [k for k in binding] + [k for k in ("C14v", "C14f", "C14m", "C14lo", "C15") if k in checks and k not in binding]
    return {
        "operation": out.get("operation"),
        "feasible": bool(out.get("feasible")),
        "engagement_source": out.get("engagement_source", "recommended"),
        "binding": binding,
        "checks": {k: _check_summary(checks[k]) for k in shown if k in checks},
        "violated": list(out.get("violated") or []),
        "violations": list(out.get("violations") or []),
        "eliminated_by": out.get("eliminated_by"),
        "warnings": list(out.get("warnings") or []) + notes,
        "provenance": list(out.get("provenance") or []),
        "cut": out.get("cut"),
        "recommended": recommended if recommended is not None else _cut_summary(out),
        "chip_floor_relaxed": bool(out.get("chip_floor_relaxed")),
        "max_feasible_tir_in": out.get("max_feasible_tir_in"),
        "hardness_hb": hb,
        "ramp": _ramp_details(out.get("ramp")),
    }


# ---------------------------------------------------------------------------
# Vendor basis (owner decisions 2026-11-12)
# ---------------------------------------------------------------------------

CHART_WORDS = {"hem": "HEM", "rough": "roughing", "side": "side-milling", "slot": "slotting", "finish": "finishing"}


def _vendor_name(key):
    from toolwiz_common import brand
    if not key:
        return None
    return " + ".join(brand.short_name(k) for k in key.split("+"))


def vendor_basis_block(vb, r, res=None, op=None):
    """The result's `vendor_basis`: which vendor charts set the v2 guardrail, in plain words. vb: the engine's
    optimize.vendor_basis (None when v2 did not produce the result)."""
    from toolwiz_common import brand
    text, key = getattr(r, "brand_text", None), getattr(r, "brand_key", None)
    out = {"mode": "none", "vendor": None, "vendor_name": None, "brand_text": text, "brand_key": key,
           "brand_source": getattr(r, "brand_source", None), "chart_class": None, "rows": 0, "sfm_range": None,
           "fz_range": None, "bucket": None, "widening": None}
    if not vb or vb.get("mode") in (None, "off"):
        why = ("the v1 model has no vendor guardrail" if (res is None or getattr(res, "model", "v1") != "v2")
               else "the vendor guardrail is off")
        out["note"] = f"No vendor chart used: {why}."
        return out
    mode = vb["mode"]
    cls = vb.get("chart_class")
    word = CHART_WORDS.get(cls, cls or "")
    out.update({k: vb.get(k) for k in ("mode", "vendor", "chart_class", "rows", "sfm_range", "fz_range", "bucket",
                                       "widening", "flute_aware", "flute_factor", "row_flutes")})
    out["vendor_name"] = _vendor_name(vb.get("vendor"))
    if not text:
        why = "no brand given"
    elif not key:
        why = f"brand \"{text}\" has no vendor charts"
    else:
        why = f"{brand.display_name(key)} has {vb.get('brand_missing') or 'no chart for this cut'}"
    if mode == "brand":
        out["note"] = f"Vendor basis: {out['vendor_name']} {word} chart (brand \"{text}\")."
    elif mode == "default":
        out["note"] = f"Vendor basis: {out['vendor_name']} {word} chart ({why}; conservative default)."
    elif mode == "consensus":
        rows = "side-milling and roughing" if cls == "side" and op == "rough" else word
        hh = "" if key in ("harvey", "helical") else "; Harvey/Helical have no chart for this cut"
        out["note"] = (f"Vendor basis: cross-vendor consensus of {rows} charts ({why}{hh})." if vb.get("sfm_range") else
                       f"Vendor basis: cross-vendor consensus of {rows} charts for this end form ({why}).")
    elif r is not None and is_high_feed(r):
        out["note"] = "Vendor basis: none: no vendor chart for high-feed tools yet; physics limits only."
    else:
        out["note"] = f"Vendor basis: none: no vendor chart matches this cut ({why}); physics limits only."
    return out


def chip_space_block(cs, res=None):
    """The result's `chip_space` (C15): the engine's block (utilisation, limiting, sentence, ...) or, when v2 did not
    produce the result, {"applies": False, "note"}."""
    if not cs:
        why = ("the v1 model has no chip-space check" if (res is None or getattr(res, "model", "v1") != "v2")
               else "no chip-space check for this cut")
        return {"applies": False, "limiting": False, "utilisation": None, "note": why}
    keys = ("applies", "limiting", "utilisation", "limit", "fill_of_limit", "full_slot", "flutes", "material_group",
            "packing_K", "depth_factor", "core_ratio", "gullet_area_in2", "chip_area_in2", "max_fz_in",
            "max_fz_by_flutes_in", "sentence", "basis", "note", "flute_aware", "flute_factor", "flute_basis")
    return {k: cs[k] for k in keys if k in cs}


# ---------------------------------------------------------------------------
# Apply
# ---------------------------------------------------------------------------

def _apply_ramp(res, rp, ratio):
    """Ramp angle, helix diameter, ramp speed and feeds from the v2 ramp model; when it has no answer, v1's rule
    scaled with the feed (never above v1's own values), as before the ramp model."""
    if rp and rp.get("ramp_angle_deg") is not None and rp.get("feasible"):
        res.ramp_angle = float(rp["ramp_angle_deg"])
        res.ramp_feed = float(rp["ramp_feed_ipm"])
        res.plunge_feed = float(rp["plunge_feed_ipm"])
        res.ramp_diameter = float(rp["helix_diameter_in"])
        res.ramp_min_diameter = float(rp["helix_min_diameter_in"])
        res.ramp_rpm = float(rp["rpm"])   # C7's slot-engagement speed, information only: Fusion ramps at the cutting speed
        if rp.get("conflicts"):
            res.tips.append({"title": "v2 ramp", "message": "; ".join(rp["conflicts"]), "type": "warning",
                             "fusion": True})
        # the feed-height note is for micro tools (slow plunge feeds); a high-feed tool's "Do not plunge" always shows
        if rp.get("plunge_note") and (float(getattr(res, "diameter", None) or 1.0) <= 0.125 or rp["plunge_note"].startswith("Do not plunge")):
            res.tips.append({"title": "Plunge feed", "message": rp["plunge_note"] + ".", "type": "info",
                             "fusion": True})
        return
    res.ramp_feed *= min(1.0, ratio)
    res.plunge_feed *= min(1.0, ratio)
    why = (rp or {}).get("error") or ", ".join((rp or {}).get("eliminated_by") or []) or "no ramp result"
    if res.v2 is not None and res.v2.get("ramp") is not None:
        res.v2["ramp"]["fallback"] = f"v1 ramp rule kept ({why})"
    res.tips.append({"title": "v2 ramp", "message": f"v2 found no ramp ({why}); the ramp keeps v1's rule.",
                     "type": "warning", "fusion": True})


def _pos(x):
    return float(x) if x is not None and float(x) > 0 else None


def _fmt_violation(v):
    over = v.get("over_by")
    amount = f" ({over:+.0%} against the limit)" if over is not None and math.isfinite(over) else ""
    return (f"{v['id']} {v['name']}: {v['value']:.5g} {v['units']} against {v['limit']:.5g} {v['units']}"
            if v.get("limit") is not None else f"{v['id']} {v['name']}") + amount


def _runout_tips(res, cut, tir_in, z):
    """The reduced-flutes warning (names the runout at which every flute cuts)."""
    n = cut.get("flutes_cutting")
    if n is None or not z or n >= z:
        return
    t_all = cut.get("tir_all_flutes_in")
    need = (f"All flutes cut at runout of {t_all:.5f}\" or less" if t_all and t_all > 0
            else "No runout is low enough for every flute to cut at this feed")
    ratio = cut.get("runout_ratio")
    res.tips.append({
        "title": "Reduced flutes cutting",
        "message": (f"Only {n} of {z} flutes form a chip at {cut['fz_in']:.5f}\" per tooth with {tir_in:.5f}\" runout"
                    + (f" (tooth-to-tooth offset is {ratio:.0%} of the chip load)" if ratio else "")
                    + f"; the other flute(s) rub, which shortens tool life and roughens the wall. {need}: "
                      f"use a lower-runout holder or tool, or accept the reduced-flute cut."),
        "type": "warning", "fusion": True})


def _high_feed_tips(r, res, cut, out):
    """A high-feed end mill: entry (ramp / helix, no plunge), wall and floor stock, depth per level, assumed geometry and
    the axial load, as plain tips; the stock to leave is the larger of the deflection rule's and the lead edge's."""
    from physics_v2 import highfeed
    g = high_feed_geometry(r)
    rp = out.get("ramp") or highfeed.entry_guidance(g, float(cut["feed_ipm"]), float(cut["rpm"]))
    radial, axial = highfeed.wall_stock(g, float(cut["ap_in"]), float(cut["ae_in"]))
    res.recommended_radial_stock_in = max(res.recommended_radial_stock_in or 0.0, radial)
    res.recommended_axial_stock_in = max(res.recommended_axial_stock_in or 0.0, axial)
    res.tips = [t for t in res.tips if t.get("title") != "Stock to leave"]
    hfo = out.get("high_feed") or {}
    cut_ref = dict(cut, _square_chart_sfm=hfo.get("square_end_chart_sfm"),
                   _vendor_mode=(out.get("vendor_basis") or {}).get("mode"), _spindle_limited=hfo.get("spindle_limited"))
    res.tips.extend(highfeed.tips(g, cut_ref, rp, (out.get("high_feed") or {}).get("axial_peak_n")))
    if res.v2 is not None:
        res.v2["high_feed"] = dict(out.get("high_feed") or {}, radial_stock_in=radial, axial_stock_in=axial)


def apply(physics, r, res, machine_profile=None):
    """Replace the v1 result's core numbers with v2's when v2 covers the cut. Never raises: a v2 error
    leaves v1 in place with the error in model_note.

    With an explicit depth and width (r.cut_depth / r.cut_width) rpm and feed are computed for that engagement
    (engagement_source "user") while rec_doc / rec_woc stay the optimizer's recommendation."""
    op, why = scope(r, res)
    if op is None:
        res.model_note = f"v2 selected; v1 used because {why}."
        res.tips.insert(0, {"title": "Cutting model: v1", "message": res.model_note, "type": "info"})
        return res
    try:
        out_rec, hb, notes = _optimize(physics, r, op, machine_profile)
        out, recommended = out_rec, None
        user_given = _pos(r.cut_depth) is not None or _pos(r.cut_width) is not None
        if op != "finish" and user_given:
            rc = out_rec.get("cut") if out_rec.get("feasible") else None
            ap_u = _pos(r.cut_depth) or (rc["ap_in"] if rc else None)
            ae_u = _pos(r.cut_width) or (rc["ae_in"] if rc else None)
            if ap_u and ae_u:
                out, hb, notes = _optimize_user(physics, r, op, machine_profile, ap_u, ae_u)
                recommended = _cut_summary(out_rec) if rc else None
    except Exception as ex:   # keep v1 rather than fail the whole calculation
        res.model_note = f"v2 selected; v1 used because the v2 calculation failed: {ex}"
        res.tips.insert(0, {"title": "Cutting model: v1 (v2 error)", "message": res.model_note,
                            "type": "warning", "fusion": True})
        return res

    v1 = {"rpm": res.rpm, "sfm": res.sfm, "feed_ipm": res.feed_ipm, "ipt": res.adj_ipt,
          "doc": res.rec_doc, "woc": res.rec_woc, "mrr": res.mrr, "deflection": res.deflection,
          "feasible": res.feasible, "limited_by": res.limited_by}
    details = _v2_details(out, hb, notes, recommended)
    res.model, res.v1, res.v2 = "v2", v1, details
    res.vendor_basis = vendor_basis_block(out.get("vendor_basis"), r, res, op)
    res.chip_space = chip_space_block(out.get("chip_space"), res)
    res.engagement_source = out.get("engagement_source", "recommended")
    if op == "finish" and user_given:
        res.engagement_source = "user"

    if not out.get("feasible") or not out.get("cut"):
        res.feasible = False
        reason = ", ".join(details["binding"] or details["violated"] or ["no feasible cut"])
        tir = out.get("max_feasible_tir_in")
        extra = f" It becomes feasible at runout ≤ {tir:.5f}\"." if tir else ""
        if out.get("engagement_source") != "user":
            res.limited_by = f"v2: {reason}"
            res.model_note = (f"v2 found no safe cut ({reason}).{extra} The numbers shown are v1's and should NOT be "
                              f"run as-is.")
            res.tips.insert(0, {"title": "v2: no safe cut", "message": res.model_note, "type": "critical",
                                "fusion": True})
            return res

    cut = out["cut"]
    rpm, fz, feed = float(cut["rpm"]), float(cut["fz_in"]), float(cut["feed_ipm"])
    ratio = (feed / res.feed_ipm) if res.feed_ipm else 1.0
    res.rpm = rpm
    res.sfm = float(cut["sfm"])                       # on the nominal diameter, as vendors print it
    res.contact_sfm = float(cut.get("contact_sfm") or cut["sfm"])   # at the effective cutting diameter (ball and bull nose)
    if cut.get("effective_diameter_in"):
        res.effective_diameter = float(cut["effective_diameter_in"])
    res.ideal_rpm = rpm
    res.target_sfm = float(cut["sfm"])
    c7 = (out.get("checks") or {}).get("C7") or {}
    res.is_spindle_limited = bool(c7.get("limit") and abs(float(c7.get("value", 0)) - float(c7["limit"])) < 1.0)
    res.base_ipt = res.adj_ipt = fz
    res.feed_ipm = feed
    res.ipr = fz * r.flutes
    res.doc = float(cut["ap_in"])
    res.woc = float(cut["ae_in"])
    rec = recommended if recommended is not None else _cut_summary(out)
    if out.get("engagement_source") != "user" or recommended is not None:
        res.rec_doc, res.rec_woc = float(rec["ap_in"]), float(rec["ae_in"])
    res.mrr = float(cut["mrr_in3_min"])
    c3 = (out.get("checks") or {}).get("C3") or {}
    if c3.get("value") is not None:
        res.deflection = float(c3["value"])
        res.rec_limit = float(c3.get("limit") or res.rec_limit)
    res.total_error = res.deflection + res.springback
    hf = out.get("high_feed")
    if op in ("rough", "adaptive", "slot"):
        mm = 1.0 / 25.4
        # Floor: a finish pass needs enough stock to cut cleanly instead of rubbing: 2 % of the diameter radially
        # (0.002" to 0.010"), half of that axially (at least 0.002").
        D_in = float(r.diameter or 0.0)
        floor_r = min(max(0.02 * D_in, 0.05 * mm), 0.010)
        floor_a = max(0.5 * floor_r, 0.05 * mm)
        radial = max(floor_r, 1.5 * res.deflection + res.springback)
        axial = max(floor_a, 1.5 * abs(res.springback))
        res.recommended_radial_stock_in = math.ceil(radial / 0.0005 - 1e-9) * 0.0005
        res.recommended_axial_stock_in = axial
        res.tips.append({"title": "Stock to leave",
                         "message": (f"Leave at least {res.recommended_radial_stock_in:.4f}\" radial / "
                                     f"{res.recommended_axial_stock_in:.4f}\" axial for the finish pass "
                                     f"(1.5 × the predicted wall deflection plus springback, and at least 2 % of the "
                                     f"tool diameter so the finish pass cuts instead of rubbing)."),
                         "type": "info", "fusion": True})
    if hf:
        _high_feed_tips(r, res, cut, out)
    res.flutes_cutting = cut.get("flutes_cutting")
    res.runout_regime = cut.get("runout_regime")
    res.tir_all_flutes_in = cut.get("tir_all_flutes_in")
    res.runout_ratio = cut.get("runout_ratio")
    _apply_ramp(res, out.get("ramp"), ratio)
    res.feasible = bool(out.get("feasible"))
    res.limited_by = ", ".join(details["binding"] + list(out.get("ae_below_envelope_min") or [])) or None
    res.provenance = []   # v1's multiplier chain no longer describes these numbers; see res.v2["provenance"]
    src = "your depth and width" if res.engagement_source == "user" else "the recommended depth and width"
    res.model_note = (f"v2 physics model ({op}, {src}): limited by {res.limited_by or 'none'}; "
                      f"v1 would give {v1['rpm']:.0f} rpm, {v1['feed_ipm']:.2f} IPM, DOC {v1['doc']:.4f}\", "
                      f"WOC {v1['woc']:.4f}\".")
    res.tips.insert(0, {"title": "Cutting model: v2", "message": res.model_note, "type": "info"})
    if out.get("engagement_source") == "user" and not out.get("feasible"):
        bad = "; ".join(_fmt_violation(v) for v in details["violations"]) or "a limit"
        rec_txt = (f" The recommended cut is DOC {rec['ap_in']:.4f}\", WOC {rec['ae_in']:.4f}\"." if recommended
                   else "")
        res.limited_by = f"v2: {', '.join(details['violated'])}"
        res.tips.insert(0, {"title": "Your depth and width exceed a limit",
                            "message": (f"At DOC {cut['ap_in']:.4f}\" and WOC {cut['ae_in']:.4f}\" the cut exceeds: "
                                        f"{bad}. The feed shown is the best this engagement allows and is NOT safe "
                                        f"as it stands.{rec_txt}"),
                            "type": "critical", "fusion": True})
    n_tips = len(res.tips)
    _runout_tips(res, cut, float(cut.get("tir_in") or r.runout or 0.0), r.flutes)
    reduced_tip = len(res.tips) > n_tips
    for w in details["warnings"]:
        lw = w.lower()
        if "near the rubbing limit" in lw:
            res.tips.append({"title": "Chip near the rubbing limit", "message": w, "type": "warning", "fusion": True})
            continue
        if "rub" in lw or "binds" in lw or "differs" in lw or "relaxed" in lw or "preferred minimum" in lw:
            if reduced_tip and "rub" in lw:
                continue   # the reduced-flutes tip says it
            res.tips.append({"title": "v2 check", "message": w, "type": "warning", "fusion": True})
    return res
