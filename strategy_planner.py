"""Strategy planner: contour slotting vs adaptive vs small-tool slotting, and T-slot cutter comparison.

``compare(request)`` implements ``POST /api/strategy/compare`` (docs/V3_IMPLEMENTATION_PLAN.md, docs/STRATEGY_PLANNER.md).
All lengths are inches, feeds IPM (inches per minute), speeds rpm / SFM, chip loads inches per tooth, times
minutes. Every speed, feed, depth and width of an option comes from ToolWiz (``pipeline.run_cut`` with the
requested cutting model, ``tslot_model`` for T-slot cutters); this module only turns those numbers into a path,
a cycle time and a tool-wear estimate. Nothing here invents a cutting number.

Feature types
-------------
``profile_cutout``  through-cut around a part (kerf free = tool diameter), optional tabs
``slot``            fixed width W
``tslot``           T-slot / keyseat job (slot height, radial depth, length), candidate cutters by shop id or geometry

Cycle time = cutting path / feed + ramp entries + links (see ``_levels``), with link feed =
``LINK_FEED_FACTOR`` x cutting feed capped at the machine's maximum cutting feed, rapid and retract height from
the machine profile (defaults: 50 m/min, 0.1 in).

Tool wear: per phase, in-cut minutes / ``life`` where ``life = min((v_life / v_used)^(1/n), 10)``; ``v_life`` is
physics_v2's Taylor speed (``optimize.taylor_speed_m_min``) at the phase's engagement angle with the 50 %
aggressiveness speed scale (it already credits light engagement), ``v_used`` the SFM ToolWiz chose, ``n`` =
``material.taylor_n``. With logged tool lives (cutlog) v_life and n are measured. Wear per part is normalized so the
least-wear option is 1.0. ``wear_confidence`` is "low" on the placeholder exponent, "measured" with a calibration.
"""
from __future__ import annotations

import copy
import json
import math
import os
from typing import Any, Dict, List, Optional, Tuple

ROOT = os.path.dirname(os.path.abspath(__file__))

FT_PER_M = 3.280839895
MM_PER_IN = 25.4
LINK_FEED_FACTOR = 2.0            # link feed = 2 x cutting feed, capped at the machine's max cutting feed
DEFAULT_RAPID_M_MIN = 50.0
DEFAULT_MAX_FEED_MM_MIN = 30000.0
DEFAULT_RETRACT_IN = 0.1
ADAPTIVE_MIN_CHANNEL_OVER_D = 1.25   # a channel narrower than this x D is cut as a slot, not trochoidally
BASELINE_AGGRESSIVENESS = 0.5     # tool life is relative to the 50 % speed level
WEAR_RATIO_POINTS = ((0.0, 1.1), (0.5, 1.3), (1.0, 2.0))   # allowed wear / least wear at aggressiveness a
MAX_CANDIDATES = 8
TAYLOR_LIFE_CAP = 10.0            # Taylor T/T_ref is credited up to this multiple of the baseline (see _life)
FEATURE_TYPES = ("profile_cutout", "slot", "tslot")

_PHYSICS = None


def _physics():
    """A shared GWizardPhysics instance (the app passes its own; this is for library use and tests)."""
    global _PHYSICS
    if _PHYSICS is None:
        from gwizard_physics import GWizardPhysics
        _PHYSICS = GWizardPhysics(os.path.join(ROOT, "materials_database_clean.json"))
    return _PHYSICS


# --------------------------------------------------------------------------------------------------
# input handling
# --------------------------------------------------------------------------------------------------

def _num(d: Dict[str, Any], key: str, *, default: Optional[float] = None, positive: bool = False,
         nonneg: bool = False, where: str = "") -> Optional[float]:
    """A finite float from ``d[key]`` (``default`` when absent); ValueError with a clear message otherwise."""
    v = d.get(key)
    label = f"{where}{key}"
    if v is None or v == "":
        return default
    if isinstance(v, bool):
        raise ValueError(f"'{label}' must be a number")
    try:
        f = float(v)
    except (TypeError, ValueError):
        raise ValueError(f"'{label}' must be a number") from None
    if f != f or f in (float("inf"), float("-inf")):
        raise ValueError(f"'{label}' must be a finite number")
    if positive and f <= 0:
        raise ValueError(f"'{label}' must be > 0")
    if nonneg and f < 0:
        raise ValueError(f"'{label}' must be >= 0")
    return f


def machine_defaults(machine_profile: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """Machine numbers the planner needs: max rpm / hp, rapid (in/min), max cutting feed (in/min), retract (in).

    ``machine_profile`` is an ``app.active_machine()`` dict (max_rpm, max_hp present) or a raw machine JSON;
    None loads machines/speedio_s500x2.json (active spindle). Falls back to 16,000 rpm, 10 hp."""
    prof = machine_profile
    if not prof or not prof.get("spindle_options"):
        try:
            with open(os.path.join(ROOT, "machines", "speedio_s500x2.json"), encoding="utf-8") as fh:
                raw = json.load(fh)
        except Exception:
            raw = {}
        merged = dict(raw)
        if prof:
            merged.update({k: v for k, v in prof.items() if k not in ("spindle_options",)})
        prof = merged
    sp = (prof.get("spindle_options") or {}).get(prof.get("active_spindle")) or {}
    max_rpm = prof.get("max_rpm") or sp.get("max_rpm") or 16000.0
    max_hp = prof.get("max_hp") or ((sp.get("power_kw_continuous") or 0) * 1.341) or 10.0
    rapid = prof.get("rapid_m_min")
    if isinstance(rapid, dict):
        rapid = rapid.get("x") or (min(float(v) for v in rapid.values()) if rapid else None)
    rapid_m = float(rapid) if rapid else DEFAULT_RAPID_M_MIN
    feed_mm = prof.get("max_cutting_feed_mm_min") or DEFAULT_MAX_FEED_MM_MIN
    return {"max_rpm": float(max_rpm), "max_hp": float(max_hp),
            "rapid_ipm": rapid_m * 1000.0 / MM_PER_IN, "max_feed_ipm": float(feed_mm) / MM_PER_IN,
            "retract_in": DEFAULT_RETRACT_IN, "profile": prof}


def _tool_spec(t: Dict[str, Any], idx: int) -> Dict[str, Any]:
    """Validated end-mill candidate: diameter, flutes, flute_length, shank_diameter, stickout, coating, geometry."""
    if not isinstance(t, dict):
        raise ValueError(f"candidate_tools[{idx}] must be an object")
    w = f"candidate_tools[{idx}]."
    d = _num(t, "diameter", positive=True, where=w)
    if d is None:
        raise ValueError(f"'{w}diameter' is required")
    fl = _num(t, "flutes", default=2, positive=True, where=w)
    if fl != int(fl):
        raise ValueError(f"'{w}flutes' must be a whole number")
    flen = _num(t, "flute_length", default=round(3.0 * d, 5), positive=True, where=w)
    shank = _num(t, "shank_diameter", default=d, positive=True, where=w)
    stick = _num(t, "stickout", positive=True, where=w)
    if stick is None:
        stick = max(flen + 0.5 * shank, 4.0 * d)
    return {"diameter": d, "flutes": int(fl), "flute_length": flen, "shank_diameter": shank, "stickout": stick,
            "coating": str(t.get("coating") or "Uncoated"), "geometry": str(t.get("geometry") or "Square"),
            "tool": str(t.get("tool") or "Carbide Endmill"), "name": str(t.get("name") or "")}


def _tool_label(t: Dict[str, Any]) -> str:
    d = t["diameter"]
    return f"{t.get('name') or ''} {d:.4g}in {t['flutes']}FL".strip()


def _fusion_tool(t: Dict[str, Any]) -> Dict[str, Any]:
    """Fusion-style tool dict (inches) so the pipeline takes diameter, flutes, flute length, shank and stickout from it."""
    return {"type": "flat end mill", "unit": "inches",
            "geometry": {"DC": t["diameter"], "NOF": t["flutes"], "LCF": t["flute_length"],
                         "SFDM": t["shank_diameter"], "LB": t["stickout"]}}


def build_cut_request(req: Dict[str, Any], tool: Dict[str, Any], operation: str, cut_depth: Optional[float] = None,
                      cut_width: Optional[float] = None, machine: Optional[Dict[str, Any]] = None):
    """The ``pipeline.CutRequest`` the planner runs for one end-mill candidate and operation
    ("Slotting", "Adaptive Roughing", "Roughing", "Finishing"). ``cut_depth`` / ``cut_width`` are inches
    (None: ToolWiz's recommended engagement). Public so tests and callers can reproduce an option's numbers."""
    from pipeline import CutRequest
    m = machine or machine_defaults()
    return CutRequest(
        family=req["family"], alloy=req.get("alloy", ""), tool=tool.get("tool", "Carbide Endmill"),
        geometry=tool["geometry"], operation=operation, coating=tool["coating"], diameter=tool["diameter"],
        flutes=tool["flutes"], flute_length=tool["flute_length"], shank_diameter=tool["shank_diameter"],
        stickout=tool["stickout"], aggressiveness=req["aggressiveness"], max_rpm=m["max_rpm"], max_hp=m["max_hp"],
        runout=req["runout"], cut_depth=cut_depth, cut_width=cut_width, fusion_tool=_fusion_tool(tool),
        model=req["model"], machine_profile=m["profile"] if m.get("profile", {}).get("spindle_options") else None)


def _validate(request: Dict[str, Any]) -> Dict[str, Any]:
    """Normalize and validate the /api/strategy/compare body; ValueError with a clear message on bad input."""
    if not isinstance(request, dict):
        raise ValueError("JSON object body required")
    family = str(request.get("family") or "").strip()
    if not family:
        raise ValueError("'family' is required (a ToolWiz material family, e.g. 'Aluminum - Wrought (6061)')")
    agg = _num(request, "aggressiveness", default=0.5)
    if agg is None or not 0.0 <= agg <= 1.0:
        raise ValueError("'aggressiveness' must be between 0 and 1 (0.5 = relatively safe)")
    runout = _num(request, "runout", default=0.0002, nonneg=True)
    model = str(request.get("model") or "v2").lower()
    if model not in ("v1", "v2"):
        raise ValueError("'model' must be 'v1' or 'v2'")
    feat = request.get("feature")
    if not isinstance(feat, dict):
        raise ValueError("'feature' object is required")
    ftype = str(feat.get("type") or "").lower()
    if ftype == "pocket":
        raise ValueError("feature type 'pocket' is not supported yet; use profile_cutout, slot or tslot")
    if ftype not in FEATURE_TYPES:
        raise ValueError(f"feature.type must be one of {', '.join(FEATURE_TYPES)}")
    cands = request.get("candidate_tools")
    if not isinstance(cands, list) or not cands:
        raise ValueError("'candidate_tools' must be a non-empty list")
    if len(cands) > MAX_CANDIDATES:
        raise ValueError(f"at most {MAX_CANDIDATES} candidate tools")
    return {"family": family, "alloy": str(request.get("alloy") or ""), "aggressiveness": float(agg),
            "runout": float(runout), "model": model, "use_cutlog": request.get("use_cutlog", True) is not False, "feature": feat, "candidates": cands, "ftype": ftype}


def _feature_dims(feat: Dict[str, Any], ftype: str) -> Dict[str, Any]:
    depth = _num(feat, "depth", positive=True, where="feature.")
    length = _num(feat, "length", positive=True, where="feature.")
    if depth is None and ftype != "tslot":
        raise ValueError("'feature.depth' is required (part thickness / slot depth, inches)")
    if length is None and ftype != "tslot":
        raise ValueError("'feature.length' is required (perimeter or slot length, inches)")
    out: Dict[str, Any] = {"depth": depth, "length": length}
    if ftype == "profile_cutout":
        tabs = feat.get("tabs")
        t = {"count": 0, "width": 0.0, "height": 0.0, "style": "3d"}
        if tabs:
            if not isinstance(tabs, dict):
                raise ValueError("'feature.tabs' must be an object {count, width, height}")
            t["count"] = int(_num(tabs, "count", default=0, nonneg=True, where="feature.tabs."))
            t["width"] = _num(tabs, "width", default=0.0, nonneg=True, where="feature.tabs.")
            t["height"] = _num(tabs, "height", default=0.0, nonneg=True, where="feature.tabs.")
            t["style"] = str(tabs.get("style") or "3d").lower()
            if t["style"] not in ("3d", "2d"):
                raise ValueError("'feature.tabs.style' must be '3d' or '2d'")
            if t["count"] > 0 and (t["width"] <= 0 or t["height"] <= 0):
                raise ValueError("tabs need 'width' and 'height' > 0 when 'count' > 0")
            if t["count"] > 0 and t["height"] >= depth:
                raise ValueError("tab height must be less than the part thickness (feature.depth)")
        out["tabs"] = t
        out["channel_width"] = _num(feat, "channel_width", positive=True, where="feature.")
    elif ftype == "slot":
        w = _num(feat, "width", positive=True, where="feature.")
        if w is None:
            raise ValueError("'feature.width' is required for a slot (inches)")
        out["width"] = w
    return out


# --------------------------------------------------------------------------------------------------
# ToolWiz calls, tool-life model
# --------------------------------------------------------------------------------------------------

def _run(physics, req, tool, operation, machine, cut_depth=None, cut_width=None):
    from pipeline import run_cut
    return run_cut(physics, build_cut_request(req, tool, operation, cut_depth, cut_width, machine))


def _material(physics, req):
    """LifeModel for the request: physics_v2 Material for the family at its alloy hardness (None when the family
    isn't calibrated) plus the shop's measured tool-life calibration when there is enough logged data."""
    mat = None
    try:
        from physics_v2 import params
        hb = None
        try:
            hb = physics.resolve_alloy_hardness(req["family"], req["alloy"]) if req["alloy"] else None
        except Exception:
            hb = None
        mat = params.material(req["family"], hb=hb, coating=req.get("coating"))
    except Exception:
        mat = None
    cal = None
    if req.get("use_cutlog", True):
        try:
            import cutlog
            cal = cutlog.toollife_calibration(req["family"])
        except Exception:
            cal = None
    return LifeModel(mat, cal, req["family"])


def _engagement_angle(ae: float, d: float) -> float:
    """Engagement angle (rad) of radial depth ``ae`` on diameter ``d``: acos(1 - 2 ae / d); pi for a full slot."""
    if ae >= d:
        return math.pi
    return math.acos(max(-1.0, min(1.0, 1.0 - 2.0 * ae / d)))


class LifeModel:
    """Tool-life model for one request: the v2 Material (Taylor law) and, when the shop has logged enough tool
    lives for this family (cutlog.toollife_calibration), the measured calibration. ``confidence`` is "measured"
    with a calibration, else "low" because material.taylor_n is a literature placeholder."""

    def __init__(self, material, cal=None, family=""):
        self.material, self.cal, self.family = material, cal, family

    @property
    def confidence(self) -> str:
        return "measured" if self.cal else "low"

    def why(self) -> str:
        if self.cal:
            c = self.cal
            fit = f"Taylor exponent fitted from the records (n = {c['taylor_n']:.2f})" if c.get("taylor_n") else \
                f"measured median life {c['life_ref_min']:.0f} min at {c['v_ref_sfm']:.0f} SFM, exponent from the model"
            return f"{c['n_records']} logged tool lives for {self.family}: {fit}."
        n = self.material.taylor_n if self.material is not None else None
        return (f"material.taylor_n = {n if n is not None else '?'} is a literature placeholder (one Ti-6Al-4V paper, "
                f"carbide range 0.2-0.5) and no measured tool lives are logged for {self.family or 'this family'}; "
                f"log tool lives at POST /api/toollife (at least {_min_life()} per family) to calibrate.")


def _min_life() -> int:
    try:
        import cutlog
        return cutlog.MIN_LIFE_RECORDS
    except Exception:
        return 3


def _life(model, sfm: float, d: float, ae: float) -> Dict[str, Optional[float]]:
    """Relative tool life of one phase (dimensionless), one consistent model.

    ``taylor`` = (v_life / v_used)^(1/n): v_used is the SFM ToolWiz chose; v_life is the speed at which the tool
    reaches the reference life for THIS engagement, physics_v2.optimize.taylor_speed_m_min at the phase's engagement
    angle (it already contains the engagement speed factor, so a light cut has a higher v_life) with T/T_ref = 1
    and the 50 % consensus speed scale. n = material.taylor_n. With a shop calibration, v_life is the measured
    SFM and n the fitted exponent when there is one. ``taylor`` is capped at TAYLOR_LIFE_CAP: when the spindle's
    rpm limit holds a small tool far below its life speed the law extrapolates to absurd lives (>1000x); beyond the
    cap other wear modes (chipping, built-up edge, breakage) dominate, so no more is credited. Wear of the phase
    = in-cut minutes / life (no separate engagement-time factor: the engagement is already in v_life)."""
    phi = _engagement_angle(ae, d)
    material, cal = model.material, model.cal
    if sfm <= 0 or (material is None and not cal):
        return {"taylor": None, "taylor_raw": None, "life": None, "phi_deg": math.degrees(phi)}
    v_used = sfm / FT_PER_M
    n = (cal or {}).get("taylor_n") or (material.taylor_n if material is not None else 0.25)
    if cal:
        v_life = cal["v_ref_sfm"] / FT_PER_M
    else:
        from physics_v2 import optimize as o
        v_life = o.taylor_speed_m_min(material, phi, 1.0, d * MM_PER_IN, o.consensus_scale(BASELINE_AGGRESSIVENESS))
    raw = (v_life / v_used) ** (1.0 / n)
    taylor = min(raw, TAYLOR_LIFE_CAP)
    return {"taylor": taylor, "taylor_raw": raw, "life": taylor, "phi_deg": math.degrees(phi)}


def allowed_wear_ratio(aggressiveness: float) -> float:
    """Allowed (wear per part of the chosen option) / (least wear): 1.1 at aggressiveness 0, 1.3 at 0.5, 2.0 at 1.0
    (linear between)."""
    a = max(0.0, min(1.0, aggressiveness))
    for (x0, y0), (x1, y1) in zip(WEAR_RATIO_POINTS, WEAR_RATIO_POINTS[1:]):
        if a <= x1:
            return y0 + (y1 - y0) * (a - x0) / (x1 - x0)
    return WEAR_RATIO_POINTS[-1][1]


# --------------------------------------------------------------------------------------------------
# path / time model
# --------------------------------------------------------------------------------------------------

class _M:
    """Machine motion assumptions (inches, IPM)."""
    def __init__(self, md: Dict[str, Any]):
        self.rapid = md["rapid_ipm"]
        self.max_feed = md["max_feed_ipm"]
        self.retract = md["retract_in"]

    def link_feed(self, feed: float) -> float:
        return min(LINK_FEED_FACTOR * feed, self.max_feed)


def _ramp_entry(res, ap: float) -> Dict[str, float]:
    """One entry of depth ``ap`` with ToolWiz's ramp (angle, ramp feed) or its plunge feed: horizontal length,
    3-D length and time (min)."""
    ang, rf, pf = res.ramp_angle or 0.0, res.ramp_feed or 0.0, res.plunge_feed or 0.0
    if ang > 0 and rf > 0:
        a = math.radians(ang)
        seg = ap / math.sin(a)
        return {"h": ap / math.tan(a), "seg": seg, "time": seg / rf, "kind": f"ramp {ang:.1f} deg"}
    if pf > 0:
        return {"h": 0.0, "seg": ap, "time": ap / pf, "kind": "plunge"}
    return {"h": 0.0, "seg": ap, "time": 0.0, "kind": "none"}


def _levels(m: _M, res, depth: float, ap: float, path: float, tabs: Optional[Dict[str, Any]], d_tool: float,
            cut_fn, ramp_replaces_cut: bool, nothing_after_tab_zone: bool = False) -> Dict[str, Any]:
    """Time and lengths of a multi-level pass along ``path`` (a closed contour or a slot, inches).

    ``ap`` is ToolWiz's depth per level; levels = ceil(depth / ap) of equal depth. ``cut_fn(path_in)`` returns
    (cut length, non-cutting return length at link feed) for one level. Levels whose bottom is deeper than
    (depth - tab height) go around the tabs: path - count x (tab width + tool diameter), one segment per tab;
    3-D tabs lift over the tab at link feed, 2-D tabs retract to the retract height, rapid across and re-ramp.
    Each level (and each 2-D tab segment) starts with a ToolWiz ramp entry whose horizontal run replaces
    cutting length when ``ramp_replaces_cut``. Returns minutes and inches by category."""
    levels = max(1, math.ceil(depth / ap - 1e-9))
    ap_eff = depth / levels
    feed = res.feed_ipm
    lf = m.link_feed(feed)
    n_tab = int(tabs["count"]) if tabs else 0
    tab_style = tabs["style"] if tabs else "3d"
    skip = (tabs["width"] + d_tool) if tabs else 0.0
    ramp = _ramp_entry(res, ap_eff)
    t_cut = t_ramp = t_link = 0.0
    cut_len = link_len = ramp_len = 0.0
    tabbed_levels = 0
    for k in range(1, levels + 1):
        bottom = k * ap_eff
        tabbed = n_tab > 0 and bottom > depth - tabs["height"] + 1e-9
        p = max(0.0, path - n_tab * skip) if tabbed else path
        cl, rl = cut_fn(p)
        ramps = n_tab if (tabbed and tab_style == "2d") else 1
        if tabbed:
            tabbed_levels += 1
            if tab_style == "3d":
                over = n_tab * skip
                link_len += over
                t_link += over / lf
            else:
                t_link += n_tab * (2.0 * m.retract + skip) / m.rapid
        rh_full = ramp["h"] * ramps
        frac = 1.0
        if ramp_replaces_cut and rh_full > 0:
            frac = min(1.0, cl / rh_full)      # a ramp longer than the segment is cut steeper over what is there
        cl_net = cl - (rh_full * frac if ramp_replaces_cut else 0.0)
        t_cut += cl_net / feed
        cut_len += cl_net
        ramp_len += ramp["seg"] * ramps * frac
        t_ramp += ramp["time"] * ramps * frac
        link_len += rl
        t_link += rl / lf
    t_pos = 2.0 * m.retract / m.rapid      # approach and final retract of the whole feature
    return {"levels": levels, "ap_eff": ap_eff, "tabbed_levels": tabbed_levels, "cut_in": cut_len,
            "ramp_in": ramp_len, "link_in": link_len, "t_cut": t_cut, "t_ramp": t_ramp, "t_link": t_link + t_pos,
            "ramp_kind": ramp["kind"], "link_feed": lf}


def _adaptive_geometry(w_channel: float, d: float, ae: float) -> Dict[str, float]:
    """Trochoidal loop geometry in a channel of width ``w_channel`` for a tool of diameter ``d`` and step ``ae``.

    The tool centre circles with radius r = (W_c - D) / 2 and advances ``ae`` along the channel per loop (loops =
    L / ae). Centre-path length cutting per loop = max(pi r + ae, W_c): the leading half circle plus the advance,
    and never less than W_c, the length a volume balance needs (ae x W_c removed per loop at engagement ae, so the
    time is never below volume / ToolWiz's MRR). The return half circle (pi r) is not cutting and runs at link feed."""
    r = (w_channel - d) / 2.0
    cut = max(math.pi * r + ae, w_channel)
    return {"radius": r, "cut_per_loop": cut, "return_per_loop": math.pi * r, "step": ae}


# --------------------------------------------------------------------------------------------------
# option assembly (end mills)
# --------------------------------------------------------------------------------------------------

def _risks(res, tool, extra: Optional[List[str]] = None) -> List[str]:
    """Warnings worth showing for an option from the ToolWiz result: infeasible, runout regime, chip near the
    rubbing limit, holder advice, provisional / long-reach notes."""
    out: List[str] = []
    if not res.feasible:
        out.append(f"ToolWiz found no safe cut for this tool ({res.limited_by or 'unknown limit'}); the numbers are not safe to run")
    if res.model == "v2" and res.runout_regime == "reduced_flutes":
        out.append(f"runout regime: reduced flutes ({res.flutes_cutting} of {tool['flutes']} cut at this feed); "
                   f"all flutes cut only at TIR <= {res.tir_all_flutes_in:.5f} in" if res.tir_all_flutes_in is not None
                   else "runout regime: reduced flutes")
    for t in res.tips:
        title = t.get("title", "")
        if title == "Chip near the rubbing limit":
            out.append("chip near the rubbing limit: " + t.get("message", ""))
    ha = res.holder_advice
    if ha and ha.get("class") in ("precision", "ultra"):
        out.append(f"holder: needs {ha['class']}-class runout (required TIR {ha['required_tir_in']:.5f} in); "
                   f"recommended: {', '.join(ha.get('recommended') or [])}")
    if res.model != "v2":
        out.append("cutting model v1 (v2 not selected or not applicable): speeds are less reliable for small tools")
    return out + (extra or [])


def _phase(name, res, tool, material, *, cut_min, ramp_min, ae, ap, note=""):
    """One cutting phase of an option: ToolWiz numbers, in-cut minutes and the tool-life model."""
    life = _life(material, res.sfm, tool["diameter"], ae)
    return {"name": name, "operation": res.operation, "rpm": round(res.rpm), "sfm": round(res.sfm, 1),
            "feed_ipm": round(res.feed_ipm, 3), "fz_in": round(res.adj_ipt, 6), "ap": round(ap, 5), "ae": round(ae, 5),
            "in_cut_min": cut_min + ramp_min, "engagement_angle_deg": round(life["phi_deg"], 1),
            "taylor_life_ratio": None if life["taylor"] is None else round(life["taylor"], 3),
            "taylor_life_ratio_uncapped": None if life["taylor"] is None else round(life["taylor_raw"], 3),
            "relative_life": None if life["life"] is None else round(life["life"], 3), "note": note,
            "_life": life["life"]}


def _finish_phase(physics, req, tool, machine, m, material, depth, length, stock, sides, name="wall finishing"):
    """Wall finishing pass(es) with ToolWiz 'Finishing' numbers (stock = the radial stock left, inches).
    Returns (phase, extra minutes dict, res) or None when ToolWiz cannot finish at that engagement."""
    wall = min(depth, tool["flute_length"])
    res = _run(physics, req, tool, "Finishing", machine, cut_depth=wall, cut_width=max(stock, 1e-4))
    levels = max(1, math.ceil(depth / wall - 1e-9))
    path = length * sides * levels
    t_cut = path / res.feed_ipm if res.feed_ipm > 0 else 0.0
    ramp = _ramp_entry(res, min(depth, wall))
    t_ramp = ramp["time"] * sides * levels
    t_link = (2.0 * m.retract / m.rapid) * sides
    ph = _phase(name, res, tool, material, cut_min=t_cut, ramp_min=t_ramp, ae=max(stock, 1e-4), ap=wall,
                note=f"{sides} wall pass(es) x {levels} level(s) at stock {stock:.4f} in")
    return ph, {"cut_in": path, "ramp_in": ramp["seg"] * sides * levels, "link_in": 0.0, "t_cut": t_cut,
                "t_ramp": t_ramp, "t_link": t_link}, res


def _finish_option(name, strategy, tool, main_res, phases, agg, *, levels, ap, ae, kerf, lengths, times, risks,
                   notes, hints, stock, feasible, extra=None):
    """Assemble the option dict from phases and lengths/times (minutes, inches)."""
    cycle = times["t_cut"] + times["t_ramp"] + times["t_link"]
    in_cut = sum(p["in_cut_min"] for p in phases)
    wear_terms = [(p["in_cut_min"], p["_life"]) for p in phases]
    wear = None
    if all(l for _, l in wear_terms):
        wear = sum(t / l for t, l in wear_terms)
    for p in phases:
        p.pop("_life", None)
    main = max(phases, key=lambda p: p["in_cut_min"])
    opt = {
        "name": name, "strategy": strategy,
        "tool": {"diameter": tool["diameter"], "flutes": tool["flutes"], "flute_length": tool["flute_length"],
                 "shank_diameter": tool["shank_diameter"], "stickout": tool["stickout"],
                 "coating": tool["coating"], "geometry": tool["geometry"]},
        "levels": levels, "ap": ap, "ae": ae, "rpm": main["rpm"], "feed_ipm": main["feed_ipm"], "sfm": main["sfm"],
        "fz_in": main["fz_in"], "kerf_in": kerf,
        "path_length_in": round(lengths["cut_in"] + lengths["ramp_in"], 3),
        "link_length_in": round(lengths["link_in"], 3),
        "cycle_time_min": cycle, "cutting_minutes": in_cut,
        "time_breakdown_min": {"cutting": times["t_cut"], "ramp_entries": times["t_ramp"], "links_and_retracts": times["t_link"]},
        "wear_raw": wear, "relative_tool_life": (in_cut / wear) if wear else None,
        "feasible": bool(feasible), "risks": risks, "notes": notes, "phases": phases,
        "stock_to_leave_in": stock, "fusion_hints": hints,
    }
    if extra:
        opt.update(extra)
    return opt


def _stock(res) -> Dict[str, Optional[float]]:
    return {"radial": res.recommended_radial_stock_in, "axial": res.recommended_axial_stock_in}


def _ramp_hint(res) -> Dict[str, Any]:
    h = {"type": "ramp" if (res.ramp_angle or 0) > 0 else "plunge", "ramp_angle_deg": round(res.ramp_angle or 0.0, 2),
         "ramp_feed_ipm": round(res.ramp_feed or 0.0, 3), "plunge_feed_ipm": round(res.plunge_feed or 0.0, 4),
         "fusion_params": ["rampType", "rampAngle", "helicalRampDiameter", "rampFeedrate", "plungeFeedrate"]}
    if res.ramp_diameter is not None:
        h["helical_ramp_diameter_in"] = round(res.ramp_diameter, 5)
    return h


def _tab_hint(tabs: Optional[Dict[str, Any]], ap_eff: float, d: float, depth: float) -> Optional[Dict[str, Any]]:
    if not tabs or not tabs["count"]:
        return None
    return {"fusion_group": "Tabs", "useTabs": True, "tabWidth_in": tabs["width"], "tabHeight_in": tabs["height"],
            "tabPositioning": f"{tabs['count']} tabs, evenly spaced (set 'Tab Positioning' to a fixed count)",
            "tab_style": "3D tabs (tool lifts over the tab)" if tabs["style"] == "3d" else "2D tabs (tool retracts over the tab)"}


def _tab_advice(tabs, depth: float, ap_eff: float, d: float, thickness_ok: bool = True) -> List[str]:
    """Practical tab advice. Numbers quoted are the planner's own (levels, ap, tab sizes), not new cutting data."""
    if not tabs or not tabs["count"]:
        return ["No tabs: the part is free after the last level; use vacuum or fixturing, or add tabs."]
    adv = [f"Tab height {tabs['height']:.4f} in vs part thickness {depth:.4f} in "
           f"({tabs['height'] / depth:.0%}); the bottom {tabs['height']:.4f} in is the only region where the path is interrupted."]
    if tabs["height"] < ap_eff - 1e-9:
        adv.append(f"Tab height is less than one level ({ap_eff:.4f} in): the last level still skips the tabs, but the tab "
                   f"is only {tabs['height']:.4f} in thick. Make the tab height at least one level so it is not machined "
                   f"through by the last stepdown.")
    else:
        adv.append("Tab height is at least one level, so the final stepdown stays above the tab top and the tab survives.")
    adv.append("3D tabs keep the tool at the cut and lift over the tab (shorter cycle, one contour, no re-entry); 2D tabs "
               "retract at every tab and need a re-ramp at each (slower, more entries) but are simpler to simulate. "
               f"This comparison used {tabs['style'].upper()} tabs.")
    adv.append("Stagger the tabs around the part (not all on one side) and keep them away from thin features and corners; "
               "tabs on a straight edge are easiest to remove.")
    adv.append("Remove the tabs after the cutout with a separate finishing contour of the part wall (or by hand and deburr): "
               "the tab stub is what the last pass at true size should clean up.")
    return adv


# ---- profile cutout / slot option builders ---------------------------------------------------------

def _contour_option(physics, req, tool, machine, m, material, dims, ftype, strategy, name, label_notes=None):
    """Full-width contour slot with ``tool``: kerf = tool diameter (profile cutout) or the slot itself (slot, D = W)."""
    res = _run(physics, req, tool, "Slotting", machine)
    D = tool["diameter"]
    depth, P = dims["depth"], dims["length"]
    tabs = dims.get("tabs") if ftype == "profile_cutout" else None
    ap = min(res.doc, tool["flute_length"]) if res.doc > 0 else tool["flute_length"]
    lv = _levels(m, res, depth, ap, P, tabs, D, lambda p: (p, 0.0), True)
    ph = _phase("contour slot", res, tool, material, cut_min=lv["t_cut"], ramp_min=lv["t_ramp"], ae=D, ap=lv["ap_eff"])
    notes = list(label_notes or [])
    notes.append(f"{lv['levels']} levels of {lv['ap_eff']:.4f} in (ToolWiz slotting ap {res.doc:.4f} in); entry: {lv['ramp_kind']}")
    if tabs and tabs["count"]:
        notes.append(f"{lv['tabbed_levels']} of {lv['levels']} levels go around {tabs['count']} {tabs['style'].upper()} tabs "
                     f"(centre-path skip {tabs['width'] + D:.4f} in each)")
    hints = {"fusion_strategy": "2D Contour (full-width slot; tool centred on the cut line)" if ftype == "profile_cutout"
             else "2D Contour or Slot (tool diameter = slot width)",
             "tool_diameter_in": D, "kerf_in": D,
             "multiple_depths": {"useStepdown": True, "maximumStepdown_in": round(ap, 5), "levels": lv["levels"]},
             "stepover": "none (full-width slot)", "optimal_load_in": None,
             "ramp": _ramp_hint(res), "tabs": _tab_hint(tabs, lv["ap_eff"], D, depth),
             "stock_to_leave": {"radial_in": 0.0, "axial_in": 0.0,
                                "toolwiz_recommendation_in": _stock(res),
                                "note": "A full slot cuts to size, so no stock is left. If the wall must be true to size, rough with the "
                                        "ToolWiz stock to leave and add a finishing contour."},
             "finishing_pass": "Optional one-pass wall finish with ToolWiz 'Finishing' numbers if the part wall must be true to size.",
             "feed_rpm_source": "pipeline.run_cut Slotting (ToolWiz)"}
    times = {k: lv[k] for k in ("t_cut", "t_ramp", "t_link")}
    return _finish_option(name, strategy, tool, res, [ph], req["aggressiveness"], levels=lv["levels"], ap=round(res.doc, 5),
                          ae=D, kerf=D, lengths=lv, times=times, risks=_risks(res, tool), notes=notes, hints=hints,
                          stock=_stock(res), feasible=res.feasible, extra={"tabbed_levels": lv["tabbed_levels"],
                                                                         "_ap_eff": lv["ap_eff"]}), res


def _adaptive_option(physics, req, tool, machine, m, material, dims, ftype, name, w_channel, finish_walls):
    """Adaptive (trochoidal) clearing of a channel of width ``w_channel`` with ``tool``; for a fixed-width slot both
    walls are then finished (``finish_walls``). The ToolWiz adaptive numbers give ap, ae (optimal load), rpm, feed."""
    res = _run(physics, req, tool, "Adaptive Roughing", machine)
    D = tool["diameter"]
    depth, P = dims["depth"], dims["length"]
    tabs = dims.get("tabs") if ftype == "profile_cutout" else None
    stock = res.recommended_radial_stock_in or 0.0
    w_eff = w_channel - (2.0 * stock if finish_walls else 0.0)
    ae = max(res.woc, 1e-5)
    ap = min(res.doc, tool["flute_length"])
    geo = _adaptive_geometry(w_eff, D, ae)

    def cut_fn(p):
        loops = p / ae
        return loops * geo["cut_per_loop"], loops * geo["return_per_loop"]

    lv = _levels(m, res, depth, ap, P, tabs, D, cut_fn, False)
    ph = _phase("adaptive clearing", res, tool, material, cut_min=lv["t_cut"], ramp_min=lv["t_ramp"], ae=ae, ap=lv["ap_eff"])
    phases = [ph]
    lengths = {k: lv[k] for k in ("cut_in", "ramp_in", "link_in")}
    times = {k: lv[k] for k in ("t_cut", "t_ramp", "t_link")}
    risks = _risks(res, tool)
    notes = [f"channel {w_channel:.4f} in wide ({w_channel / D:.2f} x D): trochoid circle radius {geo['radius']:.4f} in, "
             f"step {ae:.4f} in per loop = ToolWiz optimal load, {P / ae:.0f} loops per level, {lv['levels']} levels of "
             f"{lv['ap_eff']:.4f} in",
             f"cutting arc {geo['cut_per_loop']:.4f} in and return arc {geo['return_per_loop']:.4f} in per loop "
             f"(return at link feed {lv['link_feed']:.0f} ipm)"]
    if res.ramp_diameter is not None and res.ramp_diameter > w_eff - D + 1e-9:
        risks.append(f"ToolWiz helical ramp diameter {res.ramp_diameter:.4f} in does not fit the channel "
                     f"(centre travel {max(0.0, w_eff - D):.4f} in): ramp along the channel instead")
    if tabs and tabs["count"]:
        notes.append(f"{lv['tabbed_levels']} of {lv['levels']} levels go around {tabs['count']} {tabs['style'].upper()} tabs")
    fin_res = None
    if finish_walls:
        fin = _finish_phase(physics, req, tool, machine, m, material, depth, P, stock, 2, "wall finishing (both walls)")
        ph2, tm, fin_res = fin
        phases.append(ph2)
        for k in ("cut_in", "ramp_in", "link_in"):
            lengths[k] += tm[k]
        for k in ("t_cut", "t_ramp", "t_link"):
            times[k] += tm[k]
        notes.append(f"both walls finished leaving stock {stock:.4f} in per side (ToolWiz recommendation); included in the time")
        if not fin_res.feasible:
            risks.append("ToolWiz finishing at this stock is not feasible for this tool")
    hints = {"fusion_strategy": "2D Adaptive Clearing", "tool_diameter_in": D,
             "multiple_depths": {"useStepdown": True, "maximumStepdown_in": round(ap, 5), "levels": lv["levels"]},
             "optimal_load_in": round(ae, 5), "stepover": "optimalLoad (the adaptive optimal load)",
             "ramp": _ramp_hint(res), "tabs": _tab_hint(tabs, lv["ap_eff"], D, depth),
             "stock_to_leave": {"radial_in": stock, "axial_in": res.recommended_axial_stock_in,
                                "fusion_params": ["useStockToLeave", "stockToLeave", "verticalStockToLeave"],
                                "note": "ToolWiz recommendation: 1.5 x predicted wall deflection + springback, rounded up to 0.0005 in."},
             "finishing_pass": ("Add a 2D Contour finishing pass on the walls at ToolWiz 'Finishing' numbers (one pass at full wall height "
                                "if the flute length allows); it is included in this option's time." if finish_walls else
                                "For a true-to-size part wall add a 2D Contour finishing pass (not included in this time)."),
             "feed_rpm_source": "pipeline.run_cut Adaptive Roughing (ToolWiz)"}
    return _finish_option(name, "adaptive", tool, res, phases, req["aggressiveness"], levels=lv["levels"], ap=round(res.doc, 5),
                          ae=round(ae, 5), kerf=w_channel, lengths=lengths, times=times, risks=risks, notes=notes,
                          hints=hints, stock=_stock(res), feasible=res.feasible and (fin_res.feasible if fin_res else True),
                          extra={"tabbed_levels": lv["tabbed_levels"], "channel_width_in": w_channel,
                                 "_ap_eff": lv["ap_eff"]}), res


def _slot_sidepass_option(physics, req, tool, machine, m, material, dims, name, width):
    """Slot of width W cut with a smaller tool D: a full-width centre slot, side roughing passes on both sides
    (ToolWiz 'Roughing' ap/ae, leaving the ToolWiz stock) and a finishing pass on each wall."""
    D = tool["diameter"]
    depth, L = dims["depth"], dims["length"]
    slot = _run(physics, req, tool, "Slotting", machine)
    rough = _run(physics, req, tool, "Roughing", machine)
    ap_s = min(slot.doc, tool["flute_length"])
    lv = _levels(m, slot, depth, ap_s, L, None, D, lambda p: (p, 0.0), True)
    ph_s = _phase("centre slot", slot, tool, material, cut_min=lv["t_cut"], ramp_min=lv["t_ramp"], ae=D, ap=lv["ap_eff"])
    stock = rough.recommended_radial_stock_in or 0.0
    side = max(0.0, (width - D) / 2.0)
    ae_r = max(rough.woc, 1e-5)
    n_r = max(1, math.ceil(max(side - stock, 0.0) / ae_r - 1e-9)) if side > stock else 0
    ap_r = min(rough.doc, tool["flute_length"])
    lr = _levels(m, rough, depth, ap_r, L * n_r * 2, None, D, lambda p: (p, 0.0), True) if n_r else None
    phases = [ph_s]
    lengths = {k: lv[k] for k in ("cut_in", "ramp_in", "link_in")}
    times = {k: lv[k] for k in ("t_cut", "t_ramp", "t_link")}
    notes = [f"centre slot: {lv['levels']} levels of {lv['ap_eff']:.4f} in; side width per side {side:.4f} in"]
    if lr:
        ph_r = _phase("side roughing", rough, tool, material, cut_min=lr["t_cut"], ramp_min=lr["t_ramp"], ae=ae_r, ap=lr["ap_eff"])
        phases.append(ph_r)
        for k in ("cut_in", "ramp_in", "link_in"):
            lengths[k] += lr[k]
        for k in ("t_cut", "t_ramp", "t_link"):
            times[k] += lr[k]
        notes.append(f"side roughing: {n_r} radial pass(es) per side of {ae_r:.4f} in, {lr['levels']} levels of {lr['ap_eff']:.4f} in "
                     f"(ToolWiz Roughing), leaving {stock:.4f} in")
    ph_f, tm, fres = _finish_phase(physics, req, tool, machine, m, material, depth, L, stock if side > 0 else 0.0, 2,
                                   "wall finishing (both walls)")
    phases.append(ph_f)
    for k in ("cut_in", "ramp_in", "link_in"):
        lengths[k] += tm[k]
    for k in ("t_cut", "t_ramp", "t_link"):
        times[k] += tm[k]
    risks = _risks(slot, tool)
    if not rough.feasible:
        risks.append("ToolWiz roughing is not feasible for this tool (side passes)")
    hints = {"fusion_strategy": "2D Contour (centre slot) + 2D Contour/Pocket side passes + wall finish",
             "tool_diameter_in": D,
             "multiple_depths": {"useStepdown": True, "maximumStepdown_in": round(ap_s, 5), "levels": lv["levels"],
                                 "side_pass_stepdown_in": round(ap_r, 5)},
             "optimal_load_in": round(ae_r, 5), "stepover": "side passes at the ToolWiz roughing stepover",
             "ramp": _ramp_hint(slot), "tabs": None,
             "stock_to_leave": {"radial_in": stock, "axial_in": rough.recommended_axial_stock_in,
                                "toolwiz_recommendation_in": _stock(rough),
                                "fusion_params": ["useStockToLeave", "stockToLeave", "verticalStockToLeave"]},
             "finishing_pass": "Finish both walls at ToolWiz 'Finishing' numbers (included in the time).",
             "feed_rpm_source": "pipeline.run_cut Slotting / Roughing / Finishing (ToolWiz)"}
    return _finish_option(name, "contour_slot_side_passes", tool, slot, phases, req["aggressiveness"], levels=lv["levels"],
                          ap=round(slot.doc, 5), ae=D, kerf=width, lengths=lengths, times=times, risks=risks, notes=notes,
                          hints=hints, stock=_stock(rough), feasible=slot.feasible and rough.feasible and fres.feasible,
                          extra={"_ap_eff": lv["ap_eff"]}), slot


# --------------------------------------------------------------------------------------------------
# ranking
# --------------------------------------------------------------------------------------------------

def _rank(options: List[Dict[str, Any]], agg: float) -> Tuple[Optional[Dict[str, Any]], List[str], float, Optional[float]]:
    """Normalize wear (least wear among feasible options = 1.0), pick the recommendation by the wear-ratio rule.
    Returns (recommended option or None, reasoning lines, allowed ratio, least raw wear)."""
    allowed = allowed_wear_ratio(agg)
    pool = [o for o in options if o["feasible"] and o.get("wear_raw")]
    base = pool or [o for o in options if o.get("wear_raw")]
    least = min((o["wear_raw"] for o in base), default=None)
    for o in options:
        if o.get("wear_raw") and least:
            o["tool_wear_per_part"] = o["wear_raw"] / least
        else:
            o["tool_wear_per_part"] = None
    reasoning: List[str] = []
    ok = [o for o in pool if o["tool_wear_per_part"] <= allowed + 1e-9]
    if not ok:
        return None, ["No feasible option has a computable wear estimate."], allowed, least
    best = min(ok, key=lambda o: o["cycle_time_min"])
    return best, reasoning, allowed, least


def _reasoning(options, best, allowed, agg, ftype, model=None) -> List[str]:
    """Reasoning lines: the time difference first, then the wear estimate with its confidence, then the fastest
    option named as the alternative when it is not the recommendation, then the other options and the risks."""
    lines: List[str] = []
    if best is None:
        lines.append("No option could be recommended: every option is infeasible or has no tool-life estimate (see each option's risks).")
        return lines
    conf = model.confidence if model is not None else "low"
    feas = [o for o in options if o["feasible"]]
    fastest = min(feas, key=lambda o: o["cycle_time_min"])
    least = min((o for o in feas if o.get("tool_wear_per_part")), key=lambda o: o["tool_wear_per_part"])
    others = [o for o in feas if o is not best]
    # 1. time
    if others:
        slowest = max(others, key=lambda o: o["cycle_time_min"])
        parts = [f"{o['name']} {o['cycle_time_min']:.2f} min" for o in sorted(others, key=lambda o: o["cycle_time_min"])]
        lines.append(f"Time: recommended {best['name']} takes {best['cycle_time_min']:.2f} min per part; the others take "
                     f"{'; '.join(parts)} (up to {slowest['cycle_time_min'] / best['cycle_time_min']:.1f}x as long as the recommendation).")
        if best is not fastest:
            lines.append(f"Time difference to the fastest option ({fastest['name']}, {fastest['cycle_time_min']:.2f} min): "
                         f"the recommendation is {best['cycle_time_min'] - fastest['cycle_time_min']:.2f} min per part slower.")
    else:
        lines.append(f"Time: {best['name']} is the only feasible option, {best['cycle_time_min']:.2f} min per part.")
    # 2. wear with confidence
    why = model.why() if model is not None else ""
    lines.append(f"Wear (confidence: {conf}): the recommendation wears the tool {best['tool_wear_per_part']:.2f}x the least-wear option "
                 f"({least['name']}{', itself' if best is least else ''}); allowed {allowed:.2f}x at aggressiveness {agg:.2f} "
                 f"(1.1 at 0, 1.3 at 0.5, 2.0 at 1.0). {why}")
    if conf == "low":
        lines.append("Because the wear estimate is low-confidence, weigh the time difference above more than the wear ratio.")
    # 3. fastest as the alternative
    if fastest is not best:
        lines.append(f"Alternative: the fastest option is {fastest['name']} ({fastest['cycle_time_min']:.2f} min); it was not chosen "
                     f"because it wears the tool {fastest['tool_wear_per_part']:.2f}x the least-wear option, above the {allowed:.2f}x limit.")
    elif best is not least:
        lines.append(f"Alternative: the least-wear option is {least['name']} ({least['cycle_time_min']:.2f} min, wear 1.00x).")
    for o in sorted(others, key=lambda o: o["cycle_time_min"]):
        lines.append(f"{o['name']}: {o['cycle_time_min']:.2f} min, wear {o['tool_wear_per_part']:.2f}x.")
    for o in options:
        if not o["feasible"]:
            w = o.get("critical") or o["risks"][:1]
            lines.append(f"{o['name']} excluded: not feasible ({'; '.join(w)}).")
    lines.extend(f"{best['name']}: {r}" for r in best["risks"])
    return lines


# --------------------------------------------------------------------------------------------------
# compare: profile_cutout / slot
# --------------------------------------------------------------------------------------------------

def _compare_endmill(req, dims, physics, machine, m):
    ftype = req["ftype"]
    tools = sorted((_tool_spec(t, i) for i, t in enumerate(req["candidates"])), key=lambda t: -t["diameter"])
    material = req["_life_model"]
    options: List[Dict[str, Any]] = []
    skipped: List[str] = []
    assumptions: List[str] = []
    if ftype == "profile_cutout":
        d_large = tools[0]["diameter"]
        d_small = tools[-1]["diameter"]
        w_c = dims.get("channel_width") or max(1.5 * d_small, d_large)
        dims["w_channel"] = w_c
        for i, t in enumerate(tools):
            D = t["diameter"]
            primary = i == 0
            strat = "contour_slot" if primary else "contour_slot_small_tool"
            nm = f"{strat} {_tool_label(t)}"
            o, _ = _contour_option(physics, req, t, machine, m, material, dims, ftype, strat, nm,
                                   [f"kerf {D:.4f} in (free for a cutout: the part spacing sets the real limit)"])
            options.append(o)
            if w_c >= ADAPTIVE_MIN_CHANNEL_OVER_D * D:
                a, _ = _adaptive_option(physics, req, t, machine, m, material, dims, ftype,
                                        f"adaptive {_tool_label(t)} in {w_c:.4g} in channel", w_c, finish_walls=False)
                options.append(a)
            else:
                skipped.append(f"adaptive with {_tool_label(t)} skipped: channel {w_c:.4f} in is under "
                               f"{ADAPTIVE_MIN_CHANNEL_OVER_D} x D (it would be cut as a slot)")
        assumptions.append(f"Adaptive channel width {w_c:.4f} in (default max(1.5 x smallest D, largest candidate D) so the "
                           f"adaptive channel is at least as wide as the large tool's kerf; override with feature.channel_width).")
    else:
        W = dims["width"]
        for t in tools:
            D = t["diameter"]
            nm = _tool_label(t)
            if D > W * 1.0001:
                skipped.append(f"{nm} skipped: tool diameter {D:.4f} in is larger than the slot width {W:.4f} in")
                continue
            if abs(D - W) <= 0.01 * W:
                o, _ = _contour_option(physics, req, t, machine, m, material, dims, ftype, "contour_slot",
                                       f"contour_slot {nm}", ["tool diameter = slot width: one full slot cuts to size"])
                options.append(o)
            else:
                o, _ = _slot_sidepass_option(physics, req, t, machine, m, material, dims, f"contour_slot+side passes {nm}", W)
                options.append(o)
                if W >= ADAPTIVE_MIN_CHANNEL_OVER_D * D:
                    a, _ = _adaptive_option(physics, req, t, machine, m, material, dims, ftype,
                                            f"adaptive {nm} in {W:.4g} in slot", W, finish_walls=True)
                    options.append(a)
        assumptions.append("A slot of fixed width: the contour slot with D < W adds side roughing and a wall finish on both "
                           "sides; adaptive leaves the ToolWiz stock and both walls are finished (finishing included in the time).")
    if not options:
        raise ValueError("no candidate tool can cut this feature (every tool is wider than the slot)")
    return options, skipped, assumptions


def _common_assumptions(m: _M, req, ftype) -> List[str]:
    a = [
        f"Units: inches, IPM, minutes. Rapid {m.rapid / 39.3701:.0f} m/min, retract height {m.retract} in, link feed = "
        f"{LINK_FEED_FACTOR:g} x cutting feed capped at the machine's maximum cutting feed ({m.max_feed * MM_PER_IN:.0f} mm/min).",
        "Speeds, feeds, ap, ae, ramp angle/feed and stock to leave are ToolWiz's (pipeline.run_cut, model "
        f"{req['model']}) at aggressiveness {req['aggressiveness']:.2f} and runout {req['runout']:g} in; the planner invents no cutting numbers.",
        "Cycle time per part = cutting path / feed + ramp entries (ToolWiz ramp angle and ramp feed; plunge feed when there is "
        "no ramp) + links (3D tab lifts at link feed, 2D tab retracts at rapid, trochoid return arcs at link feed) + one approach "
        "and retract. Levels of equal depth = ceil(depth / ToolWiz ap); each level starts with one ramp entry, the ramp's horizontal "
        "run replaces cutting length on that level. Tool changes, part load/unload, tab removal and air time between parts are not included.",
        "Tool life: in-cut minutes / life, life = min((v_life / v_used)^(1/n), 10). v_life is the v2 Taylor "
        "speed (physics_v2.optimize.taylor_speed_m_min) at that phase's engagement angle with the 50 % speed scale; v_used the SFM ToolWiz chose; "
        "n = the family's taylor_n (a placeholder, carbide range 0.2-0.5). The Taylor ratio is capped at 10 x (when the spindle's rpm cap holds speed far below the life speed the law extrapolates to absurd lives). The engagement is "
        "counted once, inside v_life. Wear per part is normalized to the "
        "least-wear option = 1.0; only ratios mean anything.",
        "Recommendation rule: the fastest feasible option whose wear per part <= allowed ratio x least wear; allowed = 1.1 at "
        "aggressiveness 0, 1.3 at 0.5, 2.0 at 1.0 (linear between).",
    ]
    if ftype == "profile_cutout":
        a.append("Profile cutout: contour path length = the stated perimeter (tool centre on the cut line, curvature ignored). Tabs: "
                 "levels whose bottom is deeper than (thickness - tab height) skip count x (tab width + tool diameter) of centre path "
                 "(the slot ends are rounded by the tool); the cut goes exactly to the part thickness (no spoilboard over-cut).")
        a.append("Adaptive path model: the tool centre runs trochoidal loops of radius r = (W_c - D) / 2 down a channel of width W_c, "
                 "advancing the ToolWiz optimal load ae per loop (loops = path / ae). Cutting centre-path per loop = max(pi r + ae, W_c) "
                 "(leading half circle plus advance, never below the volume balance W_c x ae / ae); the return half circle pi r is "
                 "non-cutting at link feed. A channel under 1.25 x D is not run adaptively.")
    else:
        a.append("Slot: path length per level = the stated slot length (open ends, levels alternate direction with a ramp, no retract between levels).")
    return a


def compare(request: Dict[str, Any], physics: Any = None, machine_profile: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """Compare machining strategies for a feature (docs/V3_IMPLEMENTATION_PLAN.md, POST /api/strategy/compare).

    request: ``{"family", "alloy", "aggressiveness" (0-1), "runout" (in), "model" ("v2"), "feature": {...},
    "candidate_tools": [...]}``. Lengths in inches. Raises ValueError with a clear message on bad input.

    Returns ``{"options": [...], "recommended": name or None, "reasoning": [...], "assumptions": [...],
    "skipped": [...], "tab_advice": [...], "wear_ratio_limit": float}``. Each option has name, tool, strategy,
    levels, ap, ae, rpm, feed_ipm, path_length_in, cycle_time_min (per part, minutes), relative_tool_life,
    tool_wear_per_part (least-wear option = 1.0), risks, notes, fusion_hints and its phases."""
    req = _validate(request)
    physics = physics or _physics()
    machine = machine_defaults(machine_profile)
    m = _M(machine)
    ftype = req["ftype"]
    req["_life_model"] = _material(physics, req)
    if ftype == "tslot":
        from strategy_tslot import compare_tslot
        out = compare_tslot(req, physics, machine, m)
    else:
        dims = _feature_dims(req["feature"], ftype)
        options, skipped, extra_ass = _compare_endmill(req, dims, physics, machine, m)
        best, _, allowed, _ = _rank(options, req["aggressiveness"])
        for o in options:
            o["cycle_time_min"] = round(o["cycle_time_min"], 4)
            o["cutting_minutes"] = round(o["cutting_minutes"], 4)
            o["time_breakdown_min"] = {k: round(v, 4) for k, v in o["time_breakdown_min"].items()}
        reasoning = _reasoning(options, best, allowed, req["aggressiveness"], ftype, req["_life_model"])
        tab_adv = []
        if ftype == "profile_cutout":
            ap_eff = (best or options[0]).get("_ap_eff") or options[0]["ap"]
            tab_adv = _tab_advice(dims["tabs"], dims["depth"], ap_eff, options[0]["tool"]["diameter"])
        out = {"options": options, "recommended": best["name"] if best else None, "reasoning": reasoning,
               "assumptions": _common_assumptions(m, req, ftype) + extra_ass, "skipped": skipped,
               "tab_advice": tab_adv, "wear_ratio_limit": allowed}
        # holder / tool advice of the recommended option for the narrative
        if best:
            out["recommended_details"] = {"holder_advice_hint": [r for r in best["risks"] if r.startswith("holder")]}
    for o in out["options"]:
        o.pop("wear_raw", None)
        o.pop("_ap_eff", None)
        if o.get("tool_wear_per_part") is not None:
            o["tool_wear_per_part"] = round(o["tool_wear_per_part"], 3)
        if o.get("relative_tool_life") is not None:
            o["relative_tool_life"] = round(o["relative_tool_life"], 3)
    out.update({"feature": {k: v for k, v in req["feature"].items()}, "family": req["family"], "alloy": req["alloy"],
                "aggressiveness": req["aggressiveness"], "runout": req["runout"], "model": req["model"],
                "wear_confidence": req["_life_model"].confidence, "wear_confidence_reason": req["_life_model"].why()})
    return out
