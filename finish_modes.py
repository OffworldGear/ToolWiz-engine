"""Finish modes: none | cleanup | surface | accuracy (V3 plan, "Owner decisions, 2026-11-11 (later)"; "none" 2026-11-12).

A finishing result (v2 or v1) is checked against the mode's targets and, where it misses, fz and/or the stepover are reduced
until it meets them; each mode keeps the highest MRR that satisfies its targets.

    mode      purpose                                   default targets
    none      stock prep / facing with no finish need   no targets: nothing is reduced, the predicted Ra is only reported
    cleanup   decent, non-critical wall or floor        Ra 63 uin, wall error <= 0.001"
    surface   best visible finish (feed marks, scallops) Ra 32 uin (user-settable), wall error <= 0.001"
    accuracy  size-critical walls and floors            wall error <= 0.0002", Ra 63 uin

Physics (inches; all approximations are stated in the result's `approximation`):
  * Peripheral wall, straight flutes or helix on a flat end mill. Marks repeat every z_eff * fz, z_eff = z, or 1 when runout is
    large enough that one flute generates the wall (tooth-to-tooth offset TIR*sin(pi/z) over fz above 0.5). Cusp
    h = s^2 / (8 R) with R = D/2 (circle sagitta; Boothroyd & Knight, Fundamentals of Machining and Machine Tools, the
    f^2/(8 r) nose-radius cusp, here with the cutter radius).
  * 3D surface with a ball or bull nose: scallop between passes h = ae^2 / (8 R_eff), R_eff = D/2 (ball) or the corner
    radius (bull).
  * Flat floor (facing, floor finishing): a ball leaves the same scallop. A flat-bottomed tool (flat or bull nose) leaves
    none while the stepover is within its flat, D - 2r; beyond that the corner radii overlap and leave
    h = (ae - (D - 2r))^2 / (8 r). A flat end mill with no corner radius leaves no stepover scallop, only the feed marks.
  * Facing defaults to mode "none" unless the operation name says "finish" or a mode / target was requested: stock prep
    needs no finish, and a finish target there only shortens the stepover.
  * Ra ~ h / 4 for a triangular/circular-arc cusp profile (same references; an approximation, the real Ra also depends on edge
    sharpness, built-up edge and vibration).
  * Wall error = predicted deflection + springback; it scales as ae * fz^(1 - mc) with mc ~ 0.25 (Kienzle), so fz is cut back
    first (down to 40 %), then the radial engagement.
"""
import math

MODES = ("none", "cleanup", "surface", "accuracy")
NO_TARGET = 1e9      # "none": a target no cut can miss
DEFAULTS = {"none": {"ra": NO_TARGET, "wall": NO_TARGET}, "cleanup": {"ra": 63.0, "wall": 0.001}, "surface": {"ra": 32.0, "wall": 0.001},
            "accuracy": {"ra": 63.0, "wall": 0.0002}}
FORCE_EXPONENT = 0.75          # force ~ fz^(1 - mc), mc ~ 0.25
MIN_FZ_SCALE = 0.4
APPROXIMATION = ("Ra ~ h/4 (cusp height h = s^2/(8R)) is a geometric approximation; real Ra also depends on edge sharpness, "
                 "built-up edge and vibration. Wall error = deflection + springback from the cutting model.")
SANITY_NOTE = "cusp from the circle sagitta R - sqrt(R^2 - (s/2)^2) = s^2/(8R) for s << R"


def cusp(spacing, radius):
    """Cusp height h = s^2 / (8 R) (inches) for marks or passes spaced s apart on a cutter of radius R."""
    return spacing * spacing / (8.0 * radius) if radius > 0 else 0.0


def sagitta(spacing, radius):
    """Exact circle sagitta R - sqrt(R^2 - (s/2)^2) the cusp formula approximates."""
    return radius - math.sqrt(max(radius * radius - spacing * spacing / 4.0, 0.0))


def resolve(r):
    """(mode, Ra target uin, wall tolerance in) of a request: the mode's defaults unless the user set them."""
    ra = getattr(r, "target_ra", None)
    wall = getattr(r, "wall_tolerance", None)
    mode = str(getattr(r, "finish_mode", None) or "").strip().lower()
    if mode not in MODES:
        op = str(getattr(r, "operation", "") or "").lower()
        facing = ("face" in op or "facing" in op) and "finish" not in op
        mode = "none" if facing and not (ra and ra > 0) and not (wall and wall > 0) else "cleanup"
    d = DEFAULTS[mode]
    if mode == "none":
        return mode, d["ra"], d["wall"]
    return mode, float(ra) if ra and ra > 0 else d["ra"], float(wall) if wall and wall > 0 else d["wall"]


def _tool_kind(r, res):
    geo = f"{r.geometry} {r.tool}".lower()
    op = str(res.operation or r.operation).lower()
    if "ball" in geo:
        return "ball", r.diameter / 2.0
    if "bull" in geo or (r.corner_radius or 0.0) > 1e-6:
        return "bull", max(float(r.corner_radius or 0.0), 1e-6)
    return "flat", None


def _surface_kind(r, res, tool_kind):
    op = str(res.operation or r.operation).lower()
    if any(k in op for k in ("3d", "scallop", "contouring", "parallel", "pencil", "morph", "spiral", "radial", "steep", "blend")):
        return "surface3d"
    if res.is_floor_finish:
        return "floor"       # flat floor: a flat or bull-nose tool cuts it with its flat bottom
    if tool_kind in ("ball", "bull"):
        return "surface3d"
    return "wall"


def stepover_scallop(kind, tool_kind, ae, D, r_eff):
    """(cusp height, largest stepover for cusp h_max as a function) of the stepover scallop; (0, None) when there is none."""
    if kind == "surface3d" and r_eff:
        return cusp(ae, r_eff), (lambda h: math.sqrt(8.0 * r_eff * h))
    if kind == "floor":
        if tool_kind == "ball":
            return cusp(ae, r_eff), (lambda h: math.sqrt(8.0 * r_eff * h))
        if tool_kind == "bull":
            flat = max(D - 2.0 * r_eff, 0.0)
            return (cusp(ae - flat, r_eff) if ae > flat else 0.0), (lambda h: flat + math.sqrt(8.0 * r_eff * h))
    return 0.0, None


def _work_hardens(physics, r):
    try:
        from gwizard_physics import alloy_work_hardens
        return bool(alloy_work_hardens(r.family, r.alloy, physics.machinability.get(r.family)))
    except Exception:
        return False


def apply(physics, r, res):
    """Meet the finish mode's targets on a finishing result and attach `res.finish`. Returns the block."""
    mode, ra_target, wall_tol = resolve(r)
    D, z = res.diameter or r.diameter, int(r.flutes)
    tool_kind, r_eff = _tool_kind(r, res)
    kind = _surface_kind(r, res, tool_kind)
    R = D / 2.0
    fz, rpm = res.adj_ipt, res.rpm
    limited = []
    h_max = 4.0 * ra_target * 1e-6   # largest cusp for the Ra target (Ra ~ h/4)

    # runout: one flute generating the wall makes the marks z times coarser
    tir = float(r.runout or 0.0)
    delta = tir * math.sin(math.pi / z) if z > 0 else 0.0
    one_flute = fz > 0 and delta / fz > 0.5
    z_eff = z if one_flute else 1

    fz_scale = ae_scale = 1.0
    ae = res.woc
    if fz > 0 and rpm > 0:
        # feed marks (wall, floor and 3D all leave them along the path)
        s_marks = z_eff * fz
        r_marks = R if kind != "surface3d" else (r_eff or R)
        if cusp(s_marks, r_marks) > h_max:
            s_max = math.sqrt(8.0 * r_marks * h_max)
            fz_scale = min(fz_scale, s_max / z_eff / fz)
            limited.append("Ra (feed marks)")
        # stepover scallop (floor and 3D)
        h_so, ae_max = stepover_scallop(kind, tool_kind, ae, D, r_eff)
        if ae_max is not None and h_so > h_max and ae > 0:
            ae_scale = min(ae_scale, ae_max(h_max) / ae)
            limited.append("Ra (stepover scallop)")
        # wall error
        err = res.deflection + res.springback
        if err > wall_tol > 0:
            k = wall_tol / err
            f_need = k ** (1.0 / FORCE_EXPONENT)
            f_scale = max(f_need, MIN_FZ_SCALE)
            remaining = k / (f_scale ** FORCE_EXPONENT)
            fz_scale = min(fz_scale, f_scale)
            ae_scale = min(ae_scale, min(1.0, remaining))
            limited.append("wall error")
    new_fz, new_ae = fz * fz_scale, ae * ae_scale
    if fz_scale < 1.0 - 1e-9 or ae_scale < 1.0 - 1e-9:
        # base_ipt is the chip load before chip thinning: scale it, don't replace it with the thinned value.
        res.base_ipt *= fz_scale
        res.adj_ipt = new_fz
        res.feed_ipm = rpm * z * new_fz
        res.ipr = new_fz * z
        res.woc = new_ae
        if abs(res.rec_woc - ae) < 1e-12:
            res.rec_woc = new_ae
        # Scale the MRR the engine already computed (keeps its geometry corrections, e.g. ball-nose).
        res.mrr *= fz_scale * ae_scale
        force = (fz_scale ** FORCE_EXPONENT) * ae_scale
        res.deflection *= force
        res.springback *= force
        res.total_error = res.deflection + res.springback
        res.limited_by = ", ".join(limited) if not res.limited_by else f"{res.limited_by}, " + ", ".join(limited)
    s_marks = z_eff * new_fz
    r_marks = R if kind != "surface3d" else (r_eff or R)
    h_marks = cusp(s_marks, r_marks)
    h_step = stepover_scallop(kind, tool_kind, new_ae, D, r_eff)[0]
    h = max(h_marks, h_step)
    advice = []
    hardens = _work_hardens(physics, r)
    if hardens:
        advice.append("No spring pass: this alloy work-hardens; take one decisive finish pass with a sharp tool.")
    else:
        advice.append("A spring pass (repeat the finish pass with no added stock) removes the deflection residue on walls.")
    advice.append("Climb mill the finish pass; use conventional only where backlash or fixture lift-off demands it.")
    stock = getattr(res, "recommended_radial_stock_in", None)
    advice.append(f"Leave {stock:.4f}\" radial from roughing for this finish pass."
                  if stock else "Leave 0.005\" radial (0.12 mm) from roughing unless the roughing result states otherwise.")
    if one_flute:
        advice.append("Runout makes one flute generate the surface: feed marks are z x fz apart. A low-runout holder lets "
                      "the feed rise at the same Ra.")
    no_target = mode == "none"
    block = {"mode": mode, "surface_kind": kind, "tool_kind": tool_kind,
             "predicted_ra_uin": round(h / 4.0 * 1e6, 2), "predicted_cusp_in": h,
             "predicted_wall_error_in": res.deflection + res.springback, "target_ra_uin": None if no_target else ra_target,
             "wall_tolerance_in": None if no_target else wall_tol, "limited_by": ", ".join(limited) if limited else None,
             "effective_mark_spacing_in": s_marks, "stepover_in": new_ae, "advice": advice,
             "approximation": APPROXIMATION}
    res.finish = block
    if no_target:
        block["advice"] = ["No finish target (stock prep): the stepover and feed are not reduced for surface finish. Choose a "
                           "finish mode if this face must look good or hold size."]
        res.tips.append({"title": "Finish mode: none (stock prep)",
                         "message": f"No finish target. Predicted Ra about {block['predicted_ra_uin']:.0f} uin at these numbers.",
                         "type": "info", "fusion": True})
        return block
    res.tips.append({"title": f"Finish mode: {mode}",
                     "message": (f"Predicted Ra about {block['predicted_ra_uin']:.0f} uin (target {ra_target:.0f}), wall error "
                                 f"{block['predicted_wall_error_in']:.5f}\" (tolerance {wall_tol:.4f}\")"
                                 + (f"; limited by {block['limited_by']}" if limited else "") + "."),
                     "type": "info", "fusion": True})
    return block
