"""Pocket strategies for ``strategy_planner.compare`` (feature type ``pocket``).

Lengths inches, feeds IPM, times minutes. Every speed, feed, ap, ae, ramp, plunge and stock value is ToolWiz's
(``pipeline.run_cut``); this module only adds geometry (areas, path lengths), a cycle-time model and the tool-wear
bookkeeping shared with the other feature types (``strategy_planner._phase`` / ``_finish_option``).

Feature (a closed pocket, inches)::

    {"type": "pocket", "depth": 0.5, "length": 3.0, "width": 2.0, "corner_radius": 0.125,
     "island_area": 0.8, "island_perimeter": 3.2,          # optional
     "finish_mode": "cleanup", "target_ra": 63, "wall_tolerance": 0.001}   # optional (finish_modes.py)
    or  {"type": "pocket", "depth": 0.5, "area": 5.7, "perimeter": 9.6, "corner_radius": 0.125}

Geometry model (documented in docs/STRATEGY_PLANNER.md "Pockets")::

    A_gross = L W - (4 - pi) r^2          P_outer = 2 (L + W) - (8 - 2 pi) r        (rounded rectangle)
    island: A_i, P_i (default P_i = 2 sqrt(pi A_i), a round island)
    A_net = A_gross - A_i                  P_walls = P_outer + P_i
    s = ToolWiz radial stock, a = ToolWiz axial stock;  A_clear = A_net - s P_walls;  depth_rough = depth - a
    area + perimeter given: L + W = P/2 + (4 - pi) r, L W = A + (4 - pi) r^2 (rectangle assumption, smaller root = W)

Options per candidate tool (D <= narrowest width):
  * adaptive clearing: cut length per level = A_clear / ae + P_walls (ToolWiz Adaptive Roughing ae = optimal load;
    one perimeter pass), helical entry once per level;
  * offset / zig-zag roughing: ToolWiz Roughing ap / ae; the first pass is a full-width slot (ToolWiz Slotting numbers at
    the same ap, length D + max(L_c - W_c, 0) per level) and the rest of the area is cleared at A / ae;
  * wall finish (ToolWiz Finishing at the radial stock) and floor finish (ToolWiz Finishing at the axial stock, stepover =
    ToolWiz roughing ae) with the request's finish mode.
Corner engagement spikes (``cam_geometry_inspector.calc_corner_engagement``) slow the corner moves of both options.
"""
from __future__ import annotations

import math
from typing import Any, Dict, List, Optional

CORNERS = 4          # a rounded rectangle; the planner has no other pocket outline


def pocket_dims(feat: Dict[str, Any]) -> Dict[str, Any]:
    """Validated pocket geometry (see module doc); ValueError with a clear message on bad input."""
    from strategy_planner import _num
    w_ = "feature."
    depth = _num(feat, "depth", positive=True, where=w_)
    if depth is None:
        raise ValueError("'feature.depth' is required (pocket depth, inches)")
    L, W = _num(feat, "length", positive=True, where=w_), _num(feat, "width", positive=True, where=w_)
    area, perim = _num(feat, "area", positive=True, where=w_), _num(feat, "perimeter", positive=True, where=w_)
    r = _num(feat, "corner_radius", nonneg=True, where=w_)
    r_assumed = r is None
    r = 0.0 if r is None else r
    ia = _num(feat, "island_area", nonneg=True, where=w_) or 0.0
    ip = _num(feat, "island_perimeter", nonneg=True, where=w_)
    mode = "rectangle"
    if L and W:
        if W > L:
            L, W = W, L
        if r > W / 2.0 + 1e-9:
            raise ValueError("'feature.corner_radius' cannot exceed half the pocket width")
        area_g = L * W - (4.0 - math.pi) * r * r
        p_out = 2.0 * (L + W) - (8.0 - 2.0 * math.pi) * r
    elif area and perim:
        mode = "area+perimeter"
        half = perim / 2.0 + (4.0 - math.pi) * r          # L + W of the rectangle behind the rounded outline
        a_rect = area + (4.0 - math.pi) * r * r           # its area without the corner cut-offs
        disc = (half / 2.0) ** 2 - a_rect
        if disc < -1e-9 * a_rect and not ip:
            raise ValueError("'feature.perimeter' is too short for 'feature.area' (perimeter^2 must be >= 16 x area)")
        if disc < 0:                  # an island removed area the outer perimeter does not know about: hydraulic width 4 A / P
            W = 4.0 * area / perim
            L = area / W
        else:
            W = half / 2.0 - math.sqrt(disc)
            L = half - W
        area_g, p_out = area, perim
    else:
        raise ValueError("a pocket needs 'length' and 'width', or 'area' and 'perimeter' (inches)")
    if ia > 0 and ip is None:
        ip = 2.0 * math.sqrt(math.pi * ia)
    ip = ip or 0.0
    if ia >= area_g:
        raise ValueError("'feature.island_area' must be smaller than the pocket area")
    return {"depth": depth, "length": L, "width": W, "corner_radius": r, "corner_radius_assumed": r_assumed,
            "area_gross": area_g, "perimeter_outer": p_out, "island_area": ia, "island_perimeter": ip,
            "area_net": area_g - ia, "perimeter_walls": p_out + ip, "geometry_mode": mode,
            "finish_mode": feat.get("finish_mode"), "target_ra": _num(feat, "target_ra", positive=True, where=w_),
            "wall_tolerance": _num(feat, "wall_tolerance", positive=True, where=w_)}


def _entry(slot_res, ap: float, d_tool: float, w_avail: float) -> Dict[str, Any]:
    """Entry per level: ToolWiz's helical ramp (Slotting ramp angle, ramp feed, helix diameter) when the helix hole
    (helix diameter + D) fits the narrowest width, else ToolWiz's plunge feed (pre-drill if the tool cannot plunge)."""
    ang, rf, pf = slot_res.ramp_angle or 0.0, slot_res.ramp_feed or 0.0, slot_res.plunge_feed or 0.0
    hd = slot_res.ramp_diameter
    hole = (hd + d_tool) if hd else None
    if ang > 0 and rf > 0 and (hole is None or hole <= w_avail + 1e-9):
        seg = ap / math.sin(math.radians(ang))
        return {"seg": seg, "time": seg / rf, "fits": True, "hole": hole,
                "kind": f"helical ramp {ang:.1f} deg" + (f", helix dia {hd:.4f} in (hole {hole:.4f} in)" if hd else "")}
    if pf > 0:
        return {"seg": ap, "time": ap / pf, "fits": False, "hole": hole, "kind": "plunge (helix does not fit)"}
    return {"seg": ap, "time": 0.0, "fits": False, "hole": hole, "kind": "none"}


def _corner(tool, r_wall: float, stock: float, ae: float):
    """(effective corner ae, feed scale, overloaded, reachable) for the roughing path in a corner of wall radius r_wall
    (after ``stock`` is left the corner radius is r_wall - stock)."""
    from toolwiz_common.cam_geometry_inspector import calc_corner_engagement
    D = tool["diameter"]
    r_eff = max(r_wall - stock, 1e-6)
    eff, scale, over = calc_corner_engagement(D, r_eff, ae)
    return eff, scale, over, (D / 2.0 <= r_eff + 1e-9)


def _rest_note(tool, r_wall: float) -> Optional[Dict[str, Any]]:
    D = tool["diameter"]
    if D / 2.0 > r_wall + 1e-9:
        return {"needed": True, "tool_radius_in": D / 2.0, "corner_radius_in": r_wall,
                "max_rest_tool_diameter_in": 2.0 * r_wall if r_wall > 0 else None,
                "note": (f"Tool radius {D / 2:.4f} in is larger than the smallest corner radius {r_wall:.4f} in: the corner "
                         f"stays rounded at the tool radius. Add a rest-machining pass with a tool of diameter <= "
                         f"{2 * r_wall:.4f} in (Fusion: 'Rest Machining' > 'From previous operation')." if r_wall > 0 else
                         "Sharp internal corners (corner radius 0): no round tool cleans them; rest-machine with the smallest tool "
                         "or accept the corner radius (design for a corner relief).")}
    return None


def _floor_phase(physics, req, tool, machine, m, material, dims, a_stock, ae_floor, name="floor finishing"):
    from strategy_planner import _run, _phase
    res = _run(physics, req, tool, "Finishing", machine, cut_depth=max(a_stock, 1e-4), cut_width=ae_floor)
    path = dims["area_net"] / ae_floor
    t_cut = path / res.feed_ipm if res.feed_ipm > 0 else 0.0
    ph = _phase(name, res, tool, material, cut_min=t_cut, ramp_min=0.0, ae=ae_floor, ap=max(a_stock, 1e-4),
                note=f"floor stock {a_stock:.4f} in, stepover {ae_floor:.4f} in (ToolWiz roughing stepover)")
    return ph, {"cut_in": path, "t_cut": t_cut}, res


def _build(physics, req, tool, machine, m, material, dims, kind: str):
    """One pocket option (kind 'adaptive' or 'offset') with ``tool``, finishing included."""
    from strategy_planner import _run, _phase, _finish_phase, _finish_option, _risks, _stock, _ramp_hint, _tool_label
    D = tool["diameter"]
    depth = dims["depth"]
    rough = _run(physics, req, tool, "Roughing", machine)               # stepover for floor finish, stock, offset roughing
    main = _run(physics, req, tool, "Adaptive Roughing", machine) if kind == "adaptive" else rough
    s = rough.recommended_radial_stock_in or 0.0
    a = rough.recommended_axial_stock_in or 0.0
    ap_t = min(main.doc, tool["flute_length"])
    depth_r = max(depth - a, 1e-4)
    levels = max(1, math.ceil(depth_r / ap_t - 1e-9))
    ap_eff = depth_r / levels
    ae = max(main.woc, 1e-5)
    Pw = dims["perimeter_walls"]
    W_c, L_c = max(dims["width"] - 2 * s, 1e-4), max(dims["length"] - 2 * s, 1e-4)
    A_clear = max(dims["area_net"] - s * Pw, dims["area_net"] * 0.05)
    slot_res = _run(physics, req, tool, "Slotting", machine, cut_depth=min(ap_eff, tool["flute_length"]))
    entry = _entry(slot_res, ap_eff, D, W_c)
    feed = main.feed_ipm
    phases: List[Dict[str, Any]] = []
    notes: List[str] = []
    risks = _risks(main, tool)
    # --- roughing path per level
    if kind == "adaptive":
        cut_len = A_clear / ae + Pw
        t_level = cut_len / feed
        notes.append(f"adaptive path per level = A_clear / ae + P_walls = {A_clear:.3f} / {ae:.4f} + {Pw:.3f} = {cut_len:.1f} in "
                     f"(ToolWiz optimal load {ae:.4f} in = {ae / D:.0%} D, ap {ap_eff:.4f} in, {levels} level(s))")
        slot_len = 0.0
    else:
        slot_len = D + max(L_c - W_c, 0.0)
        a_slot = slot_len * D
        rest_len = max(A_clear - a_slot, 0.0) / ae
        cut_len = slot_len + rest_len
        slot_ap = min(ap_eff, tool["flute_length"])
        t_slot = slot_len / slot_res.feed_ipm if slot_res.feed_ipm > 0 else 0.0
        t_level = t_slot + rest_len / feed
        notes.append(f"offset roughing per level: first pass is a FULL SLOT (ae = D = {D:.4f} in) of {slot_len:.2f} in at ToolWiz "
                     f"slotting feed {slot_res.feed_ipm:.1f} ipm for ap {slot_ap:.4f} in, then {rest_len:.1f} in at ToolWiz roughing "
                     f"stepover {ae:.4f} in ({ae / D:.0%} D), feed {feed:.1f} ipm")
        if not slot_res.feasible:
            risks.append("ToolWiz finds no safe full-slot cut at this ap for the entry pass: lower the stepdown or enter with a smaller tool")
    # --- corners
    eff, scale, over, reach = _corner(tool, dims["corner_radius"], s, ae)
    corner_pen = 0.0
    r_wall = dims["corner_radius"]
    if not reach:
        notes.append(f"tool radius {D / 2:.4f} in >= path corner radius {max(r_wall - s, 0):.4f} in: the tool cannot enter the wall corners "
                     f"(no corner spike, corners left for rest machining)")
    elif eff > ae * 1.05:
        corner_pen = CORNERS * D * (1.0 / (feed * scale) - 1.0 / feed)
        notes.append(f"corner engagement spike: in a {r_wall:.4f} in wall corner (path corner {max(r_wall - s, 0):.4f} in after "
                     f"{s:.4f} in stock) ae rises from {ae:.4f} to {eff:.4f} in; Feed Optimization at {scale:.0%} of feed over "
                     f"~{D:.3f} in at each of {CORNERS} corners adds {corner_pen * levels:.3f} min")
        if over:
            risks.append(f"corner engagement spike to {eff:.4f} in (tool {D:.4f} in, corner {r_wall:.4f} in): enable Fusion Feed "
                         f"Optimization ({scale:.0%} corner feed) or use a smaller tool")
    t_level += corner_pen
    t_rough = t_level * levels
    t_ramp = entry["time"] * levels
    if not entry["fits"]:
        risks.append(f"helical entry hole {entry['hole']:.4f} in does not fit the {W_c:.4f} in pocket after stock: entry is a plunge "
                     f"(needs a centre-cutting tool) or pre-drill / ramp along the pocket" if entry["hole"] else "no helical entry data")
    notes.append(f"entry per level: {entry['kind']}")
    ph = _phase("adaptive clearing" if kind == "adaptive" else "offset roughing", main, tool, material,
                cut_min=t_rough - (slot_len / slot_res.feed_ipm * levels if kind != "adaptive" and slot_res.feed_ipm > 0 else 0.0),
                ramp_min=t_ramp, ae=ae, ap=ap_eff, note=f"{levels} level(s) x {cut_len:.1f} in")
    phases.append(ph)
    lengths = {"cut_in": cut_len * levels, "ramp_in": entry["seg"] * levels, "link_in": 0.0}
    times = {"t_cut": t_rough, "t_ramp": t_ramp, "t_link": 2.0 * m.retract / m.rapid}
    if kind != "adaptive":
        phases.append(_phase("full-slot entry pass", slot_res, tool, material, cut_min=slot_len / slot_res.feed_ipm * levels
                             if slot_res.feed_ipm > 0 else 0.0, ramp_min=0.0, ae=D, ap=ap_eff,
                             note=f"{slot_len:.2f} in per level at ae = D"))
    # --- finishing
    fin_res = None
    fr = _finish_phase(physics, req, tool, machine, m, material, depth, Pw, s, 1, "wall finishing")
    phw, tmw, fin_res = fr
    phases.append(phw)
    lengths["cut_in"] += tmw["cut_in"]
    lengths["ramp_in"] += tmw["ramp_in"]
    times["t_cut"] += tmw["t_cut"]
    times["t_ramp"] += tmw["t_ramp"]
    times["t_link"] += tmw["t_link"]
    phf, tmf, floor_res = _floor_phase(physics, req, tool, machine, m, material, dims, a, max(rough.woc, 1e-4))
    phases.append(phf)
    lengths["cut_in"] += tmf["cut_in"]
    times["t_cut"] += tmf["t_cut"]
    times["t_link"] += 2.0 * m.retract / m.rapid
    notes.append(f"walls finished at stock {s:.4f} in (P_walls = {Pw:.2f} in), floor finished at stock {a:.4f} in; both included in the time")
    fin_info = getattr(fin_res, "finish", None) or {}
    if fin_info:
        notes.append(f"finish mode {fin_info.get('mode')}: predicted wall Ra {fin_info.get('predicted_ra_uin')} uin, "
                     f"wall error {fin_info.get('predicted_wall_error_in')} in (targets Ra {fin_info.get('target_ra_uin')} uin, "
                     f"wall {fin_info.get('wall_tolerance_in')} in)")
    if not fin_res.feasible or not floor_res.feasible:
        risks.append("ToolWiz finishing is not feasible for this tool at the stock left")
    rest = _rest_note(tool, r_wall)
    if rest:
        risks.append("rest machining needed (not in the time): " + rest["note"])
    hints = {
        "fusion_strategy": ("2D Adaptive Clearing (pocket boundary selected; tool containment: inside)" if kind == "adaptive"
                            else "2D Pocket (Pocket strategy: offset, or zig-zag for a long narrow pocket) with 'Roughing passes' stepover"),
        "tool_diameter_in": D,
        "multiple_depths": {"useStepdown": True, "maximumStepdown_in": round(ap_t, 5), "levels": levels},
        "optimal_load_in": round(ae, 5) if kind == "adaptive" else None,
        "stepover": ("optimalLoad (the adaptive optimal load)" if kind == "adaptive" else
                     f"maximumStepover {ae:.4f} in; the first (centre) pass is a full slot: enter by helix and lower the feed there"),
        "ramp": _ramp_hint(slot_res), "tabs": None,
        "stock_to_leave": {"radial_in": s, "axial_in": a, "fusion_params": ["useStockToLeave", "stockToLeave", "verticalStockToLeave"],
                           "toolwiz_recommendation_in": _stock(rough)},
        "finishing_pass": "Wall: 2D Contour on the pocket walls at ToolWiz 'Finishing' numbers; floor: 2D Pocket / Face finishing pass "
                          "(both included in the time)." ,
        "rest_machining": rest or {"needed": False},
        "corner_feed": {"scale": round(scale if reach else 1.0, 3), "effective_ae_in": round(eff, 5), "fusion_params": ["useFeedOptimization", "cornerFeed"]},
        "feed_rpm_source": "pipeline.run_cut " + ("Adaptive Roughing" if kind == "adaptive" else "Roughing / Slotting") + " / Finishing (ToolWiz)",
    }
    strat = "pocket_adaptive" if kind == "adaptive" else "pocket_offset"
    name = f"{strat} {_tool_label(tool)}"
    opt = _finish_option(name, strat, tool, main, phases, req["aggressiveness"], levels=levels, ap=round(ap_t, 5), ae=round(ae, 5),
                         kerf=dims["width"], lengths=lengths, times=times, risks=risks, notes=notes, hints=hints,
                         stock=_stock(rough), feasible=main.feasible and fin_res.feasible and floor_res.feasible and
                         (slot_res.feasible or kind == "adaptive"),
                         extra={"rest_machining_needed": bool(rest), "corner_feed_scale": round(scale if reach else 1.0, 3),
                                "_ap_eff": ap_eff})
    return opt


def compare_pocket_options(req, dims, physics, machine, m):
    """(options, skipped, assumptions) of a pocket for the candidate end mills of ``req``."""
    from strategy_planner import _tool_spec, _tool_label
    tools = sorted((_tool_spec(t, i) for i, t in enumerate(req["candidates"])), key=lambda t: -t["diameter"])
    material = req["_life_model"]
    options: List[Dict[str, Any]] = []
    skipped: List[str] = []
    W = dims["width"]
    for t in tools:
        D = t["diameter"]
        if D > W * 1.0001:
            skipped.append(f"{_tool_label(t)} skipped: tool diameter {D:.4f} in is wider than the pocket ({W:.4f} in)")
            continue
        options.append(_build(physics, req, t, machine, m, material, dims, "adaptive"))
        options.append(_build(physics, req, t, machine, m, material, dims, "offset"))
    if not options:
        raise ValueError("no candidate tool fits this pocket (every tool is wider than the pocket)")
    r = dims["corner_radius"]
    assumptions = [
        (f"Pocket {dims['length']:.3f} x {dims['width']:.3f} in" if dims["geometry_mode"] == "rectangle" else
         f"Pocket from area and perimeter: equivalent rectangle {dims['length']:.3f} x {dims['width']:.3f} in (rectangle assumption)")
        + f", depth {dims['depth']:.3f} in, corner radius {r:.4f} in"
        + (" (not given: assumed 0, so every tool leaves the corners for rest machining)" if dims["corner_radius_assumed"] else "")
        + f"; net area {dims['area_net']:.3f} in^2, wall length {dims['perimeter_walls']:.3f} in"
        + (f" (island {dims['island_area']:.3f} in^2, perimeter {dims['island_perimeter']:.3f} in)" if dims["island_area"] else "") + ".",
        "Pocket path model: adaptive = (A_clear / ae + P_walls) per level; offset = full-slot first pass of length D + (L_c - W_c)^+ at "
        "ToolWiz slotting numbers, then (A_clear - slot area) / ae at ToolWiz roughing numbers; A_clear = A_net - s P_walls with s the "
        "ToolWiz radial stock; levels = ceil((depth - axial stock) / ap). Entry: ToolWiz helical ramp once per level (plunge if the helix "
        "does not fit). Corner moves: calc_corner_engagement feed scale over ~D at each of 4 corners. Links between passes are not modelled.",
        "Finishing (included): walls at ToolWiz 'Finishing' with the radial stock, floor at ToolWiz 'Finishing' with the axial stock and the "
        "ToolWiz roughing stepover; finish mode " + str(dims.get("finish_mode") or "cleanup") + " (finish_modes.py).",
        "Rest machining of corners (tool radius > corner radius) is reported, not timed.",
    ]
    return options, skipped, assumptions
