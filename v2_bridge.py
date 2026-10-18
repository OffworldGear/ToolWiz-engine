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
import os
import threading
from collections import OrderedDict

ROOT = os.path.dirname(os.path.abspath(__file__))
SETTINGS_PATH = os.path.join(ROOT, "data", "model_settings.json")
MODELS = ("v1", "v2")
KW_TO_HP = 1.341

# Operation names (web page / Fusion strategy) -> v2 operation. Others stay on v1 for now.
OPERATION_MAP = {
    "adaptive roughing": "adaptive",
    "standard roughing": "rough",
    "roughing": "rough",
    "slotting / tab milling": "slot",
    "slotting": "slot",
    "wall finishing (deep doc)": "finish",
}
NOT_SQUARE = ("ball", "bull", "radius", "chamfer", "v-bit", "engrav", "taper", "dovetail", "lollipop",
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
    """(model, source): the request, then the saved setting, then TOOLWIZ_MODEL, then v1."""
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
    return "v1", "default"


# ---------------------------------------------------------------------------
# Scope and inputs
# ---------------------------------------------------------------------------

def _families():
    from physics_v2 import params
    return params.load()["families"]


def scope(r, res):
    """(v2 operation, None) when v2.0 covers this cut, else (None, reason)."""
    if res.is_hole_tool or res.is_tapping:
        return None, "v2.0 covers end mills only (hole tool or tap)"
    geo = f"{r.geometry} {r.tool}".lower()
    if any(k in geo for k in NOT_SQUARE) or (r.corner_radius or 0.0) > 1e-6:
        return None, "v2.0 covers square end mills only (ball, bull nose, chamfer and form tools come in v2.1)"
    if not r.is_carbide:
        return None, "v2.0 models solid carbide tools only"
    op = OPERATION_MAP.get(str(r.operation).strip().lower())
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
    m = o.Machine(sp, max_rpm, "continuous", float(r.runout or 0.0002), "eccentric",
                  f"{prof.get('machine', 'machine')} ({sp.get('label') or key})",
                  feed / 25.4 if feed else None)
    hs = prof.get("holder_stiffness")
    if hs:
        from dataclasses import replace
        m = replace(m, holder_k_n_um=hs.get("k_n_um"), holder_ktheta_nm_urad=hs.get("ktheta_nm_urad"),
                    holder_basis=hs.get("status", ""))
    return m, notes


def tool_for(r):
    from physics_v2 import optimize as o
    g = r.profile.geometry
    return o.Tool(r.profile, float(g.diameter), int(g.flutes), float(g.flute_length),
                  helix_deg=float(r.helix_angle or 35.0), label=f"{g.diameter:.4f}\" {int(g.flutes)}FL")


# ---------------------------------------------------------------------------
# Optimizer call (cached: roughing/adaptive take ~2 s)
# ---------------------------------------------------------------------------

_CACHE = OrderedDict()
_CACHE_LOCK = threading.Lock()
_CACHE_SIZE = 128


def _optimize(physics, r, op, machine_profile):
    from physics_v2 import params
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
        kw["stock"] = float(r.cut_width) if r.cut_width else o.STOCK_TO_LEAVE_IN
        if r.cut_depth:
            kw["wall_height"] = min(float(r.cut_depth), tool.lcf)
    key = json.dumps({
        "fam": r.family, "hb": hb, "coat": r.coating, "op": op, "a": round(float(r.aggressiveness), 4),
        "prof": r.profile.to_dict(), "helix": r.helix_angle, "kw": kw,
        "m": [machine.label, machine.max_rpm, machine.tir_in, machine.spindle.get("power_kw_continuous"),
              machine.holder_k_n_um, machine.holder_ktheta_nm_urad, machine.max_feed_ipm],
    }, sort_keys=True, default=str)
    with _CACHE_LOCK:
        if key in _CACHE:
            _CACHE.move_to_end(key)
            return _CACHE[key], hb, notes
    material = params.material(r.family, hb=hb, coating=r.coating)
    out = params.optimize(tool, material, op, float(r.aggressiveness), machine_=machine, **kw)
    out = dict(out, ramp=_ramp(tool, material, machine, r, out))
    with _CACHE_LOCK:
        _CACHE[key] = out
        while len(_CACHE) > _CACHE_SIZE:
            _CACHE.popitem(last=False)
    return out, hb, notes


def _ramp(tool, material, machine, r, out):
    """The helical entry for this tool and material (physics_v2/ramp.py), or {"error": ...}; never raises."""
    from physics_v2 import params, ramp
    cut = out.get("cut") or {}
    try:
        return ramp.optimize_ramp(tool, material, machine, float(r.aggressiveness), consensus=params.CONSENSUS_PATH,
                                  op_feed_ipm=cut.get("feed_ipm"), op_rpm=cut.get("rpm"), coating=r.coating)
    except Exception as ex:   # the cut stands; the ramp falls back to v1's rule
        return {"feasible": False, "error": f"{type(ex).__name__}: {ex}"}


def _ramp_details(rp):
    if not rp:
        return None
    keys = ("feasible", "error", "ramp_angle_deg", "helix_diameter_over_D", "helix_diameter_in", "helix_min_diameter_over_D",
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


def _v2_details(out, hb, notes):
    checks = out.get("checks") or {}
    binding = list(out.get("binding") or [])
    shown = [k for k in binding] + [k for k in ("C14v", "C14f", "C14m") if k in checks and k not in binding]
    return {
        "operation": out.get("operation"),
        "feasible": bool(out.get("feasible")),
        "binding": binding,
        "checks": {k: _check_summary(checks[k]) for k in shown if k in checks},
        "violated": list(out.get("violated") or []),
        "eliminated_by": out.get("eliminated_by"),
        "warnings": list(out.get("warnings") or []) + notes,
        "provenance": list(out.get("provenance") or []),
        "cut": out.get("cut"),
        "max_feasible_tir_in": out.get("max_feasible_tir_in"),
        "hardness_hb": hb,
        "ramp": _ramp_details(out.get("ramp")),
    }


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
        if rp.get("plunge_note"):
            res.tips.append({"title": "v2 plunge feed", "message": rp["plunge_note"] + ".", "type": "info",
                             "fusion": True})
        return
    res.ramp_feed *= min(1.0, ratio)
    res.plunge_feed *= min(1.0, ratio)
    why = (rp or {}).get("error") or ", ".join((rp or {}).get("eliminated_by") or []) or "no ramp result"
    if res.v2 is not None and res.v2.get("ramp") is not None:
        res.v2["ramp"]["fallback"] = f"v1 ramp rule kept ({why})"
    res.tips.append({"title": "v2 ramp", "message": f"v2 found no ramp ({why}); the ramp keeps v1's rule.",
                     "type": "warning", "fusion": True})


def apply(physics, r, res, machine_profile=None):
    """Replace the v1 result's core numbers with v2's when v2 covers the cut. Never raises: a v2 error
    leaves v1 in place with the error in model_note."""
    op, why = scope(r, res)
    if op is None:
        res.model_note = f"v2 selected; v1 used because {why}."
        res.tips.insert(0, {"title": "Cutting model: v1", "message": res.model_note, "type": "info"})
        return res
    try:
        out, hb, notes = _optimize(physics, r, op, machine_profile)
    except Exception as ex:   # keep v1 rather than fail the whole calculation
        res.model_note = f"v2 selected; v1 used because the v2 calculation failed: {ex}"
        res.tips.insert(0, {"title": "Cutting model: v1 (v2 error)", "message": res.model_note,
                            "type": "warning", "fusion": True})
        return res

    v1 = {"rpm": res.rpm, "sfm": res.sfm, "feed_ipm": res.feed_ipm, "ipt": res.adj_ipt,
          "doc": res.rec_doc, "woc": res.rec_woc, "mrr": res.mrr, "deflection": res.deflection,
          "feasible": res.feasible, "limited_by": res.limited_by}
    details = _v2_details(out, hb, notes)
    res.model, res.v1, res.v2 = "v2", v1, details

    if not out.get("feasible") or not out.get("cut"):
        res.feasible = False
        reason = ", ".join(details["binding"] or details["violated"] or ["no feasible cut"])
        tir = out.get("max_feasible_tir_in")
        extra = f" It becomes feasible at runout ≤ {tir:.5f}\"." if tir else ""
        res.limited_by = f"v2: {reason}"
        res.model_note = f"v2 found no safe cut ({reason}).{extra} The numbers shown are v1's and should NOT be run as-is."
        res.tips.insert(0, {"title": "v2: no safe cut", "message": res.model_note, "type": "critical", "fusion": True})
        return res

    cut = out["cut"]
    rpm, fz, feed = float(cut["rpm"]), float(cut["fz_in"]), float(cut["feed_ipm"])
    ratio = (feed / res.feed_ipm) if res.feed_ipm else 1.0
    res.rpm = rpm
    res.sfm = res.contact_sfm = float(cut["sfm"])
    res.ideal_rpm = rpm
    res.target_sfm = float(cut["sfm"])
    c7 = (out.get("checks") or {}).get("C7") or {}
    res.is_spindle_limited = bool(c7.get("limit") and abs(float(c7.get("value", 0)) - float(c7["limit"])) < 1.0)
    res.base_ipt = res.adj_ipt = fz
    res.feed_ipm = feed
    res.ipr = fz * r.flutes
    res.doc = res.rec_doc = float(cut["ap_in"])
    res.woc = res.rec_woc = float(cut["ae_in"])
    res.mrr = float(cut["mrr_in3_min"])
    c3 = (out.get("checks") or {}).get("C3") or {}
    if c3.get("value") is not None:
        res.deflection = float(c3["value"])
        res.rec_limit = float(c3.get("limit") or res.rec_limit)
    res.total_error = res.deflection + res.springback
    _apply_ramp(res, out.get("ramp"), ratio)
    res.feasible = True
    res.limited_by = ", ".join(details["binding"]) or None
    res.provenance = []   # v1's multiplier chain no longer describes these numbers; see res.v2["provenance"]
    res.model_note = (f"v2 physics model ({op}): limited by {res.limited_by or 'none'}; "
                      f"v1 would give {v1['rpm']:.0f} rpm, {v1['feed_ipm']:.2f} IPM, DOC {v1['doc']:.4f}\", "
                      f"WOC {v1['woc']:.4f}\".")
    res.tips.insert(0, {"title": "Cutting model: v2", "message": res.model_note, "type": "info"})
    for w in details["warnings"]:
        if "rub" in w.lower() or "binds" in w.lower() or "differs" in w.lower():
            res.tips.append({"title": "v2 check", "message": w, "type": "warning", "fusion": True})
    return res
