"""Live CAD/CAM B-Rep geometry inspector for Fusion 360 operations.

Extracts three shop-critical geometric metrics from a Fusion 360 ``adsk.cam.Operation``
and its parent ``adsk.cam.Setup`` / ``adsk.fusion.BRepBody`` models:

1. **Feature Z-Depth & Required Stickout** (``feature_depth_in``, ``required_reach_in``,
   ``stickout_collision``, ``excess_stickout_in``) — detects whether the toolholder will collide
   with the top of stock before reaching the bottom of the cut, or whether the tool has
   excessive stickout that can be choked up to reduce deflection ($\\propto L^3$).
2. **Minimum Internal Corner Radius** (``min_corner_radius_in``, ``corner_woc_spike_in``,
   ``corner_feed_scale``, ``corner_overload``) — finds tight concave vertical fillets in the cut
   zone where radial engagement spikes toward $180^\\circ$ and calculates the recommended corner
   feed reduction factor.
3. **Thin-Wall & Thin-Floor Compliance** (``min_wall_thickness_in``, ``min_floor_thickness_in``,
   ``wall_height_in``, ``is_thin_wall``, ``is_thin_floor``, ``workpiece_compliance_factor``) —
   measures wall/floor thickness via opposing B-Rep face analysis and raycasting so
   ``Stock to Leave Manager`` and ``run_cut`` can account for workpiece push-off.

All returned linear dimensions are normalized to **inches** (Fusion's internal B-Rep database
unit is centimeters: ``1 cm = 1 / 2.54 in``). Pure-Python duck-typing allows full unit testing
without Fusion 360 running.
"""
from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import Any, Dict, Iterable, List, Optional, Tuple

CM_TO_IN = 1.0 / 2.54
HOLDER_CLEARANCE_IN = 0.100          # 0.100" (2.54 mm) minimum safe Z clearance from stock top to holder
EXCESS_STICKOUT_THRESHOLD_IN = 0.25  # report choke-up opportunity when stickout exceeds required reach by > 0.25"
THIN_WALL_THRESHOLD_IN = 0.080       # 0.080" (~2.0 mm) thin-wall threshold
THIN_FLOOR_THRESHOLD_IN = 0.060      # 0.060" (~1.5 mm) thin-floor threshold
THIN_WALL_SLENDERNESS_RATIO = 8.0    # wall height / thickness >= 8:1 is slender
CORNER_OVERLOAD_RATIO = 0.70         # tool_radius / corner_radius >= 0.70 causes severe engagement spike


@dataclass
class OperationGeometryReport:
    """Normalized B-Rep & CAM geometry metrics (all lengths in inches)."""
    feature_depth_in: Optional[float] = None
    required_reach_in: Optional[float] = None
    stickout_collision: bool = False
    excess_stickout_in: float = 0.0
    choke_up_stiffness_gain_pct: float = 0.0

    min_corner_radius_in: Optional[float] = None
    corner_ratio: Optional[float] = None         # R_tool / R_corner
    corner_woc_spike_in: Optional[float] = None  # effective radial engagement inside the tightest corner
    corner_feed_scale: float = 1.0               # recommended corner feed multiplier (0.20 .. 1.00)
    corner_overload: bool = False

    min_wall_thickness_in: Optional[float] = None
    min_floor_thickness_in: Optional[float] = None
    wall_height_in: Optional[float] = None
    is_thin_wall: bool = False
    is_thin_floor: bool = False
    workpiece_compliance_factor: float = 1.0     # >= 1.0 multiplier on elastic push-off for thin walls

    inspected_faces_count: int = 0
    warnings: List[Dict[str, Any]] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "feature_depth_in": round(self.feature_depth_in, 5) if self.feature_depth_in is not None else None,
            "required_reach_in": round(self.required_reach_in, 5) if self.required_reach_in is not None else None,
            "stickout_collision": bool(self.stickout_collision),
            "excess_stickout_in": round(self.excess_stickout_in, 5),
            "choke_up_stiffness_gain_pct": round(self.choke_up_stiffness_gain_pct, 1),
            "min_corner_radius_in": (
                round(self.min_corner_radius_in, 5) if self.min_corner_radius_in is not None else None
            ),
            "corner_ratio": round(self.corner_ratio, 3) if self.corner_ratio is not None else None,
            "corner_woc_spike_in": (
                round(self.corner_woc_spike_in, 5) if self.corner_woc_spike_in is not None else None
            ),
            "corner_feed_scale": round(self.corner_feed_scale, 3),
            "corner_overload": bool(self.corner_overload),
            "min_wall_thickness_in": (
                round(self.min_wall_thickness_in, 5) if self.min_wall_thickness_in is not None else None
            ),
            "min_floor_thickness_in": (
                round(self.min_floor_thickness_in, 5) if self.min_floor_thickness_in is not None else None
            ),
            "wall_height_in": round(self.wall_height_in, 5) if self.wall_height_in is not None else None,
            "is_thin_wall": bool(self.is_thin_wall),
            "is_thin_floor": bool(self.is_thin_floor),
            "workpiece_compliance_factor": round(self.workpiece_compliance_factor, 3),
            "inspected_faces_count": int(self.inspected_faces_count),
            "warnings": list(self.warnings),
        }


# ---------------------------------------------------------------------------
# Pure-math kinematic & structural helpers
# ---------------------------------------------------------------------------

def calc_corner_engagement(
    tool_diameter_in: float,
    corner_radius_in: float,
    nominal_woc_in: float,
) -> Tuple[float, float, bool]:
    """Calculate the effective radial engagement spike and recommended feed scale inside a concave corner.

    When a cutter of radius $R_t = D/2$ enters an internal corner of radius $R_c$ while taking a
    nominal stepover $a_e$, the tool center follows an arc of radius $R_c - R_t$ while the uncut
    stock corner has radius $R_c - a_e$.

    Returns ``(effective_corner_woc_in, corner_feed_scale, is_overloaded)``.
    """
    if tool_diameter_in <= 0 or corner_radius_in <= 0:
        return nominal_woc_in, 1.0, False

    r_tool = tool_diameter_in * 0.5
    woc = max(0.0, min(nominal_woc_in, tool_diameter_in))
    if woc <= 0:
        woc = tool_diameter_in * 0.10

    ratio = r_tool / corner_radius_in
    if r_tool >= corner_radius_in - 1e-6:
        # Tool radius >= corner radius: tool slams into 180-deg full-slot engagement in the corner
        eff_woc = tool_diameter_in
        feed_scale = max(0.20, min(1.0, (woc / eff_woc) ** 0.65)) if eff_woc > 0 else 0.25
        return eff_woc, feed_scale, True

    # 1. Internal arc peripheral-to-centerline velocity ratio: (R_c - R_t) / R_c
    #    In an internal corner of radius R_c, the cutting periphery moves R_c / (R_c - R_t) faster
    #    than the programmed tool centerline.
    arc_kinematic_scale = (corner_radius_in - r_tool) / corner_radius_in

    # 2. Maximum radial engagement spike entering the fillet:
    #    As the cutter transitions into the corner, effective radial depth increases inversely with (1 - R_t/R_c)
    eff_woc = min(tool_diameter_in, woc / max(arc_kinematic_scale, 0.05))

    # Combined corner feed scale (kinematic arc factor + engagement arc factor), bounded to [0.20, 1.0]
    if r_tool > 0 and eff_woc > woc + 1e-6:
        angle_nom = math.acos(max(-1.0, min(1.0, 1.0 - woc / r_tool)))
        angle_cor = math.acos(max(-1.0, min(1.0, 1.0 - eff_woc / r_tool)))
        engagement_scale = angle_nom / max(angle_cor, 1e-6)
    else:
        engagement_scale = 1.0

    feed_scale = max(0.20, min(1.0, arc_kinematic_scale * (0.5 + 0.5 * engagement_scale)))

    is_overloaded = bool(ratio >= CORNER_OVERLOAD_RATIO or eff_woc >= 2.0 * woc)
    return eff_woc, feed_scale, is_overloaded


def is_wall_only_operation(strategy_or_name: Optional[str]) -> bool:
    """Return True when the operation cuts side walls / through-contours rather than a pocket floor."""
    s = str(strategy_or_name or "").strip().lower()
    if not s:
        return False
    if any(k in s for k in ("teeth", "tab", "profile")):
        return True
    if any(k in s for k in ("pocket", "adaptive", "face", "flat", "horizontal", "floor", "scallop", "parallel")):
        return False
    return any(k in s for k in ("contour", "wall finish", "slot", "swarf", "chamfer", "trace"))


def calc_thin_wall_compliance_factor(
    wall_thickness_in: Optional[float],
    wall_height_in: Optional[float] = None,
    floor_thickness_in: Optional[float] = None,
    tool_diameter_in: Optional[float] = None,
    check_floor: bool = True,
) -> Tuple[bool, bool, float]:
    """Compute thin-wall / thin-floor flags and the workpiece compliance multiplier (>= 1.0).

    A thin cantilever wall deflects proportionally to $(h / t)^3$. We bound the multiplier to
    ``[1.0, 2.5]`` so downstream stock compensation remains conservative and never gouges.
    When ``tool_diameter_in`` is provided, the thin-wall threshold scales relative to cutter
    diameter (``min(0.080", max(0.012", 0.60 * D))``) so micro-tools do not falsely flag features
    that are thick relative to the cutter.
    """
    is_thin_wall = False
    is_thin_floor = False
    factor = 1.0

    wall_thresh = THIN_WALL_THRESHOLD_IN
    if tool_diameter_in is not None and float(tool_diameter_in) > 0:
        wall_thresh = min(THIN_WALL_THRESHOLD_IN, max(0.012, float(tool_diameter_in) * 0.60))

    if wall_thickness_in is not None and wall_thickness_in > 0:
        h = wall_height_in if (wall_height_in is not None and wall_height_in > 0) else (
            min(0.50, float(tool_diameter_in) * 3.0) if (tool_diameter_in and tool_diameter_in > 0) else 0.50
        )
        slenderness = h / wall_thickness_in
        slender_cap = max(wall_thresh * 1.5, THIN_WALL_THRESHOLD_IN * 0.75) if (tool_diameter_in and tool_diameter_in > 0) else 1.0
        if wall_thickness_in < wall_thresh or (slenderness >= THIN_WALL_SLENDERNESS_RATIO and wall_thickness_in < slender_cap):
            is_thin_wall = True
            t_ratio = max(1.0, wall_thresh / max(wall_thickness_in, 0.008))
            s_ratio = max(1.0, slenderness / THIN_WALL_SLENDERNESS_RATIO)
            factor = min(2.5, 1.0 + 0.25 * (t_ratio - 1.0) + 0.20 * (s_ratio - 1.0))

    if check_floor and floor_thickness_in is not None and 0 < floor_thickness_in < THIN_FLOOR_THRESHOLD_IN:
        is_thin_floor = True
        f_ratio = max(1.0, THIN_FLOOR_THRESHOLD_IN / max(floor_thickness_in, 0.015))
        factor = max(factor, min(2.0, 1.0 + 0.30 * (f_ratio - 1.0)))

    return is_thin_wall, is_thin_floor, factor


# ---------------------------------------------------------------------------
# Fusion 360 B-Rep & CAM extraction helpers (safe with duck-typed mocks)
# ---------------------------------------------------------------------------

def _iter_collection(col) -> List[Any]:
    if col is None:
        return []
    try:
        return list(col)
    except TypeError:
        try:
            return [col.item(i) for i in range(col.count)]
        except Exception:
            return []


def _bbox_z_bounds_cm(bbox) -> Optional[Tuple[float, float]]:
    if bbox is None:
        return None
    try:
        z_min = float(bbox.minPoint.z)
        z_max = float(bbox.maxPoint.z)
        if z_max >= z_min:
            return z_min, z_max
    except Exception:
        pass
    return None


def _point_coords_cm(pt) -> Optional[Tuple[float, float, float]]:
    if pt is None:
        return None
    try:
        return float(pt.x), float(pt.y), float(pt.z)
    except Exception:
        return None


def _vec_coords(vec) -> Optional[Tuple[float, float, float]]:
    if vec is None:
        return None
    try:
        x, y, z = float(vec.x), float(vec.y), float(vec.z)
        mag = math.hypot(x, y, z)
        if mag > 1e-12:
            return x / mag, y / mag, z / mag
    except Exception:
        pass
    return None


def _extract_setup_bodies(setup) -> List[Any]:
    """Return all BRepBody objects associated with a Fusion CAM Setup."""
    bodies: List[Any] = []
    if setup is None:
        return bodies
    for attr in ("models", "bodies"):
        col = getattr(setup, attr, None)
        for item in _iter_collection(col):
            # Item may be a BRepBody directly, or a Component/Occurrence exposing bRepBodies
            if hasattr(item, "faces"):
                bodies.append(item)
            elif hasattr(item, "bRepBodies"):
                bodies.extend(_iter_collection(item.bRepBodies))
    return bodies


def _extract_faces_from_op_and_setup(op, setup=None) -> List[Any]:
    """Collect BRepFace objects from an operation's selections or fallback to the parent setup's bodies."""
    faces: List[Any] = []
    # 1. Explicit faces attached to operation (or mock test fixture)
    direct_faces = getattr(op, "selected_faces", None) or getattr(op, "faces", None)
    if direct_faces:
        faces.extend(_iter_collection(direct_faces))

    # 2. Check CAD geometry selections inside op.parameters (e.g. contours, pocketSelections, faces)
    params = getattr(op, "parameters", None)
    if params is not None and not faces:
        for pname in ("faces", "pocketSelections", "contours", "model", "geometry"):
            try:
                p = params.itemByName(pname) if hasattr(params, "itemByName") else None
                val = getattr(p, "value", None) if p is not None else None
                sel_list = getattr(val, "value", None) if val is not None else None
                for sel in _iter_collection(sel_list):
                    if hasattr(sel, "faces") and not hasattr(sel, "pointOnFace"):
                        faces.extend(_iter_collection(sel.faces))
                    elif hasattr(sel, "geometry") and hasattr(sel, "boundingBox"):
                        faces.append(sel)
                    elif hasattr(sel, "faces"):
                        faces.extend(_iter_collection(sel.faces))
            except Exception:
                pass

    # 3. Fallback to setup model bodies
    if not faces and setup is not None:
        for body in _extract_setup_bodies(setup):
            faces.extend(_iter_collection(getattr(body, "faces", None)))

    return faces


def _face_normal_and_point_cm(face) -> Tuple[Optional[Tuple[float, float, float]], Optional[Tuple[float, float, float]]]:
    """Extract outward unit normal and a representative point (cm) on a BRepFace."""
    # 1. Direct normal / point attributes (supported on mocks and simplified wrappers)
    norm = _vec_coords(getattr(face, "normal", None))
    pt = _point_coords_cm(getattr(face, "pointOnFace", None) or getattr(face, "centroid", None))

    # 2. Fusion BRepFace.evaluator.getNormalAtPoint (always oriented outward from the solid BRepBody,
    # accounting for face.isParamReversed on planes as well as curved cylindrical/conical surfaces).
    if norm is None and hasattr(face, "evaluator"):
        try:
            ev = face.evaluator
            p_eval = getattr(face, "pointOnFace", None)
            if p_eval is not None and hasattr(ev, "getNormalAtPoint"):
                ok, n_vec = ev.getNormalAtPoint(p_eval)
                if ok:
                    norm = _vec_coords(n_vec)
        except Exception:
            pass

    # 3. Analytic surface normal fallback (only Plane.normal, never Cylinder.axis which is an axis, not a normal)
    geom = getattr(face, "geometry", None)
    if norm is None and geom is not None and getattr(geom, "radius", None) is None:
        norm = _vec_coords(getattr(geom, "normal", None))
        if norm is not None and bool(getattr(face, "isParamReversed", False)):
            norm = (-norm[0], -norm[1], -norm[2])
    if pt is None and geom is not None:
        pt = _point_coords_cm(getattr(geom, "origin", None))

    if pt is None:
        bb = getattr(face, "boundingBox", None)
        if bb is not None and hasattr(bb, "minPoint") and hasattr(bb, "maxPoint"):
            try:
                pt = (
                    0.5 * (float(bb.minPoint.x) + float(bb.maxPoint.x)),
                    0.5 * (float(bb.minPoint.y) + float(bb.maxPoint.y)),
                    0.5 * (float(bb.minPoint.z) + float(bb.maxPoint.z)),
                )
            except Exception:
                pass
    return norm, pt


def _is_concave_vertical_cylinder(face, geom) -> Tuple[bool, Optional[float]]:
    """Return ``(True, radius_in)`` when ``face`` is a vertical/near-vertical concave cylindrical fillet."""
    if geom is None:
        return False, None
    radius_cm = getattr(geom, "radius", None)
    if radius_cm is None:
        return False, None
    try:
        r_in = float(radius_cm) * CM_TO_IN
    except (TypeError, ValueError):
        return False, None
    # Ignore invalid or microscopic edge-break / deburr fillets (< 0.005")
    if r_in < 0.005:
        return False, None

    # Check cylinder axis is near-vertical (aligned with Z) if axis is exposed
    axis = _vec_coords(getattr(geom, "axis", None))
    if axis is not None and abs(axis[2]) < 0.70:
        # Horizontal fillet (e.g., floor bullnose), not a vertical wall corner
        return False, None

    # Explicit concavity flag (if provided on face or geometry)
    is_concave = getattr(face, "is_concave", None)
    if is_concave is None:
        is_concave = getattr(geom, "is_concave", None)
    if is_concave is False:
        return False, None
    if is_concave is True:
        return True, r_in

    # In Fusion B-Rep, a cylindrical face whose surface normal points TOWARD the cylinder axis is
    # an internal (concave) fillet/hole; one pointing AWAY from the axis is a convex boss/tooth tip.
    origin = _point_coords_cm(getattr(geom, "origin", None))
    pt = _point_coords_cm(getattr(face, "pointOnFace", None))
    norm, _ = _face_normal_and_point_cm(face)
    if origin is not None and pt is not None and norm is not None:
        to_axis_x = origin[0] - pt[0]
        to_axis_y = origin[1] - pt[1]
        dot = to_axis_x * norm[0] + to_axis_y * norm[1]
        if dot <= 1e-6:
            # Normal points away from axis (convex boss/tip) or has no XY component -> not concave
            return False, None
    elif norm is None:
        return False, None

    return True, r_in


def _bbox_overlap_2d(bb1, bb2, plane: str = "xy", tol_cm: float = 0.2) -> bool:
    """True if two BoundingBox3D objects overlap when projected onto the given plane."""
    if bb1 is None or bb2 is None:
        return True
    try:
        if plane == "xy":
            return (
                float(bb1.minPoint.x) <= float(bb2.maxPoint.x) + tol_cm
                and float(bb2.minPoint.x) <= float(bb1.maxPoint.x) + tol_cm
                and float(bb1.minPoint.y) <= float(bb2.maxPoint.y) + tol_cm
                and float(bb2.minPoint.y) <= float(bb1.maxPoint.y) + tol_cm
            )
        if plane == "z":
            return (
                float(bb1.minPoint.z) <= float(bb2.maxPoint.z) + tol_cm
                and float(bb2.minPoint.z) <= float(bb1.maxPoint.z) + tol_cm
            )
    except Exception:
        pass
    return True


def _tangential_overlap_xy(bb1, bb2, norm: Tuple[float, float, float]) -> bool:
    """True if two vertical face bounding boxes overlap across a positive span along their XY wall tangent."""
    if bb1 is None or bb2 is None:
        return True
    try:
        nx, ny = float(norm[0]), float(norm[1])
        mag = math.hypot(nx, ny)
        if mag <= 1e-9:
            return True
        tx, ty = -ny / mag, nx / mag
        c1 = [
            tx * float(bb1.minPoint.x) + ty * float(bb1.minPoint.y),
            tx * float(bb1.minPoint.x) + ty * float(bb1.maxPoint.y),
            tx * float(bb1.maxPoint.x) + ty * float(bb1.minPoint.y),
            tx * float(bb1.maxPoint.x) + ty * float(bb1.maxPoint.y),
        ]
        c2 = [
            tx * float(bb2.minPoint.x) + ty * float(bb2.minPoint.y),
            tx * float(bb2.minPoint.x) + ty * float(bb2.maxPoint.y),
            tx * float(bb2.maxPoint.x) + ty * float(bb2.minPoint.y),
            tx * float(bb2.maxPoint.x) + ty * float(bb2.maxPoint.y),
        ]
        t1_min, t1_max = min(c1), max(c1)
        t2_min, t2_max = min(c2), max(c2)
        overlap = min(t1_max, t2_max) - max(t1_min, t2_min)
        if (t1_max - t1_min) > 0.02 and (t2_max - t2_min) > 0.02:
            return overlap >= 0.01
        return overlap >= -1e-4
    except Exception:
        return True


def _point_in_bbox_3d(pt: Tuple[float, float, float], bb, tol_cm: float = 0.02) -> bool:
    """True if 3D point ``pt`` (cm) lies within ``bb`` (expanded by ``tol_cm``)."""
    if bb is None:
        return True
    try:
        return (
            float(bb.minPoint.x) - tol_cm <= pt[0] <= float(bb.maxPoint.x) + tol_cm
            and float(bb.minPoint.y) - tol_cm <= pt[1] <= float(bb.maxPoint.y) + tol_cm
            and float(bb.minPoint.z) - tol_cm <= pt[2] <= float(bb.maxPoint.z) + tol_cm
        )
    except Exception:
        return True


def _z_overlap_in(bb1, bb2) -> Optional[float]:
    """Return the shared Z-overlap height (in inches) of two bounding boxes, or None if unavailable."""
    b1 = _bbox_z_bounds_cm(bb1)
    b2 = _bbox_z_bounds_cm(bb2)
    if b1 is None or b2 is None:
        return None
    ov_cm = min(b1[1], b2[1]) - max(b1[0], b2[0])
    return max(0.0, ov_cm * CM_TO_IN)


def _measure_thickness_from_faces(
    faces: Iterable[Any],
) -> Tuple[Optional[float], Optional[float], Optional[float]]:
    """Measure ``(min_wall_thickness_in, min_floor_thickness_in, max_wall_height_in)`` from B-Rep faces.

    Supports both:
    1. Explicit ``wall_thickness_cm`` / ``floor_thickness_cm`` attributes or raycast hits, and
    2. Anti-parallel planar face pairs ($\\hat{n}_1 \\cdot \\hat{n}_2 \\le -0.98$) where the vector
       between the two faces points inward through the solid body (i.e. opposite to $\\hat{n}_1$)
       and projecting straight across the wall thickness lands inside the opposing face's bounds.
    """
    vertical_planes: List[Tuple[Tuple[float, float, float], Tuple[float, float, float], Any, float]] = []
    horizontal_planes: List[Tuple[Tuple[float, float, float], Tuple[float, float, float], Any]] = []

    min_wall_in: Optional[float] = None
    min_floor_in: Optional[float] = None
    max_wall_height_in: Optional[float] = None
    thin_wall_height_in: Optional[float] = None

    for f in faces:
        # Check direct thickness annotations if present
        wt_cm = getattr(f, "wall_thickness_cm", None)
        if wt_cm is not None and float(wt_cm) > 0:
            w_in = float(wt_cm) * CM_TO_IN
            min_wall_in = w_in if min_wall_in is None else min(min_wall_in, w_in)
        ft_cm = getattr(f, "floor_thickness_cm", None)
        if ft_cm is not None and float(ft_cm) > 0:
            fl_in = float(ft_cm) * CM_TO_IN
            min_floor_in = fl_in if min_floor_in is None else min(min_floor_in, fl_in)

        bb = getattr(f, "boundingBox", None)
        z_bounds = _bbox_z_bounds_cm(bb)
        h_in = ((z_bounds[1] - z_bounds[0]) * CM_TO_IN) if z_bounds is not None else 0.0

        # Skip cylindrical/conical faces for planar pair matching unless they have no radius
        geom = getattr(f, "geometry", None)
        if geom is not None and getattr(geom, "radius", None) is not None:
            continue

        norm, pt = _face_normal_and_point_cm(f)
        if norm is None or pt is None:
            continue

        if abs(norm[2]) <= 0.20:
            # Vertical or near-vertical wall
            vertical_planes.append((norm, pt, bb, h_in))
            if h_in > 0:
                max_wall_height_in = h_in if max_wall_height_in is None else max(max_wall_height_in, h_in)
        elif abs(norm[2]) >= 0.90:
            # Horizontal floor / ceiling
            horizontal_planes.append((norm, pt, bb))

    # Pairwise opposing vertical walls: n1 . n2 <= -0.98 and (pt2 - pt1) . n1 < 0 (solid lies between them)
    for i in range(len(vertical_planes)):
        n1, p1, bb1, h1 = vertical_planes[i]
        for j in range(i + 1, len(vertical_planes)):
            n2, p2, bb2, h2 = vertical_planes[j]
            dot_n = n1[0] * n2[0] + n1[1] * n2[1] + n1[2] * n2[2]
            if dot_n > -0.98:
                continue
            if not _bbox_overlap_2d(bb1, bb2, plane="z", tol_cm=0.02):
                continue
            dx, dy, dz = p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2]
            # Signed projection along n1: outward normal n1 points away from the solid, so the opposite
            # wall of a solid rib/fin must lie in the -n1 direction (proj < 0). If proj > 0, the two
            # faces bound an open air gap / slot / tooth gullet rather than a solid thin wall.
            proj = dx * n1[0] + dy * n1[1] + dz * n1[2]
            if proj >= -1e-5:
                continue
            t_cm = -proj
            # Normal raycast check: projecting p1 along -n1 by t_cm must land inside bb2 (or p2 + t_cm*n1 in bb1)
            p1_opp = (p1[0] - t_cm * n1[0], p1[1] - t_cm * n1[1], p1[2])
            p2_opp = (p2[0] + t_cm * n1[0], p2[1] + t_cm * n1[1], p2[2])
            if not (_point_in_bbox_3d(p1_opp, bb2, tol_cm=0.02) or _point_in_bbox_3d(p2_opp, bb1, tol_cm=0.02)):
                continue
            if not _tangential_overlap_xy(bb1, bb2, n1):
                continue
            dist_in = t_cm * CM_TO_IN
            # Require a true standing wall (shared Z height >= max(0.025", 1.5 * thickness))
            z_ov_in = _z_overlap_in(bb1, bb2)
            if z_ov_in is not None and z_ov_in < max(0.025, 1.5 * dist_in):
                continue
            if 0.005 <= dist_in < 1.0:
                pair_h = z_ov_in if (z_ov_in is not None and z_ov_in > 0) else max(h1, h2)
                if min_wall_in is None or dist_in < min_wall_in:
                    min_wall_in = dist_in
                    if pair_h > 0:
                        thin_wall_height_in = pair_h

    # Pairwise opposing horizontal floors/webs (solid must lie between them: (z2 - z1) * n1_z < 0)
    for i in range(len(horizontal_planes)):
        n1, p1, bb1 = horizontal_planes[i]
        for j in range(i + 1, len(horizontal_planes)):
            n2, p2, bb2 = horizontal_planes[j]
            dot_n = n1[0] * n2[0] + n1[1] * n2[1] + n1[2] * n2[2]
            if dot_n > -0.98:
                continue
            proj_z = (p2[2] - p1[2]) * n1[2]
            if proj_z >= -1e-5:
                continue
            t_z_cm = -proj_z
            p1_opp_z = (p1[0], p1[1], p1[2] - t_z_cm * n1[2])
            p2_opp_z = (p2[0], p2[1], p2[2] + t_z_cm * n1[2])
            if not (_point_in_bbox_3d(p1_opp_z, bb2, tol_cm=0.0) or _point_in_bbox_3d(p2_opp_z, bb1, tol_cm=0.0)):
                continue
            dz_in = t_z_cm * CM_TO_IN
            if 0.005 <= dz_in < 1.0:
                min_floor_in = dz_in if min_floor_in is None else min(min_floor_in, dz_in)

    return min_wall_in, min_floor_in, (thin_wall_height_in or max_wall_height_in)


def inspect_operation_geometry(
    op: Any,
    setup: Any = None,
    tool_diameter_in: Optional[float] = None,
    stickout_in: Optional[float] = None,
    nominal_woc_in: Optional[float] = None,
    is_metric: bool = False,
) -> OperationGeometryReport:
    """Inspect a Fusion 360 ``adsk.cam.Operation`` and its B-Rep geometry.

    Safe to call on real Fusion API objects or lightweight unit-test mocks; never raises.
    """
    report = OperationGeometryReport()
    if op is None:
        return report

    if setup is None:
        setup = getattr(op, "parentSetup", None) or getattr(op, "setup", None)

    faces = _extract_faces_from_op_and_setup(op, setup)
    report.inspected_faces_count = len(faces)

    # 1. Feature Z-Depth & Required Stickout
    stock_top_z_cm: Optional[float] = None
    bottom_z_cm: Optional[float] = None

    if setup is not None:
        sb = _bbox_z_bounds_cm(getattr(setup, "stockBoundingBox", None))
        if sb is not None:
            stock_top_z_cm = sb[1]
        else:
            for body in _extract_setup_bodies(setup):
                bb = _bbox_z_bounds_cm(getattr(body, "boundingBox", None))
                if bb is not None:
                    stock_top_z_cm = bb[1] if stock_top_z_cm is None else max(stock_top_z_cm, bb[1])

    # Check operation bottom height parameter or face Z bounds
    op_bottom_cm = getattr(op, "bottom_z_cm", None)
    if op_bottom_cm is not None:
        bottom_z_cm = float(op_bottom_cm)
    for f in faces:
        fb = _bbox_z_bounds_cm(getattr(f, "boundingBox", None))
        if fb is not None:
            bottom_z_cm = fb[0] if bottom_z_cm is None else min(bottom_z_cm, fb[0])
            if stock_top_z_cm is None:
                stock_top_z_cm = fb[1]
            else:
                stock_top_z_cm = max(stock_top_z_cm, fb[1])

    if stock_top_z_cm is not None and bottom_z_cm is not None and stock_top_z_cm >= bottom_z_cm:
        depth_in = (stock_top_z_cm - bottom_z_cm) * CM_TO_IN
        if depth_in > 1e-5:
            report.feature_depth_in = depth_in
            report.required_reach_in = depth_in + HOLDER_CLEARANCE_IN
            if stickout_in is not None and stickout_in > 0:
                if report.required_reach_in > stickout_in + 1e-4:
                    report.stickout_collision = True
                    if is_metric:
                        msg = (
                            f"Feature depth is {depth_in * 25.4:.2f} mm (requires >= "
                            f"{report.required_reach_in * 25.4:.2f} mm stickout with clearance), "
                            f"but tool stickout is only {stickout_in * 25.4:.2f} mm. "
                            f"Holder collision risk!"
                        )
                    else:
                        msg = (
                            f"Feature depth is {depth_in:.3f}\" (requires >= {report.required_reach_in:.3f}\" "
                            f"stickout with clearance), but tool stickout is only {stickout_in:.3f}\". "
                            f"Holder collision risk!"
                        )
                    report.warnings.append({
                        "title": "Holder Clearance / Stickout Too Short",
                        "message": msg,
                        "type": "critical",
                        "fusion": True,
                    })
                elif stickout_in - report.required_reach_in >= EXCESS_STICKOUT_THRESHOLD_IN:
                    report.excess_stickout_in = stickout_in - report.required_reach_in
                    # Cantilever beam stiffness scales as 1 / L^3
                    stiffness_ratio = (stickout_in / max(report.required_reach_in, 0.05)) ** 3
                    gain_pct = (1.0 - (1.0 / max(stiffness_ratio, 1.0))) * 100.0
                    report.choke_up_stiffness_gain_pct = gain_pct
                    if is_metric:
                        msg = (
                            f"Feature depth only requires {report.required_reach_in * 25.4:.1f} mm stickout, "
                            f"but tool is set to {stickout_in * 25.4:.1f} mm. Choking up by "
                            f"{report.excess_stickout_in * 25.4:.1f} mm reduces tool deflection by {gain_pct:.0f}%."
                        )
                    else:
                        msg = (
                            f"Feature depth only requires {report.required_reach_in:.3f}\" stickout, "
                            f"but tool is set to {stickout_in:.3f}\". Choking up by "
                            f"{report.excess_stickout_in:.3f}\" reduces tool deflection by {gain_pct:.0f}%."
                        )
                    report.warnings.append({
                        "title": "Excessive Stickout vs Feature Depth",
                        "message": msg,
                        "type": "info",
                        "fusion": True,
                    })

    # 2. Minimum Internal Corner Radius
    min_corner_in: Optional[float] = None
    for f in faces:
        geom = getattr(f, "geometry", None)
        is_conc, r_in = _is_concave_vertical_cylinder(f, geom)
        if is_conc and r_in is not None:
            # Filter out large sweeping curves (> 2.5x tool diameter) when tool diameter is known
            if tool_diameter_in and tool_diameter_in > 0 and r_in > tool_diameter_in * 2.5:
                continue
            min_corner_in = r_in if min_corner_in is None else min(min_corner_in, r_in)

    if min_corner_in is not None and min_corner_in > 0:
        report.min_corner_radius_in = min_corner_in
        if tool_diameter_in is not None and tool_diameter_in > 0:
            r_tool = tool_diameter_in * 0.5
            report.corner_ratio = r_tool / min_corner_in
            woc = nominal_woc_in if (nominal_woc_in is not None and nominal_woc_in > 0) else tool_diameter_in * 0.15
            eff_woc, feed_scale, overloaded = calc_corner_engagement(tool_diameter_in, min_corner_in, woc)
            report.corner_woc_spike_in = eff_woc
            report.corner_feed_scale = feed_scale
            report.corner_overload = overloaded
            if overloaded:
                if is_metric:
                    r_txt = f"{min_corner_in * 25.4:.2f} mm"
                    t_txt = f"{r_tool * 25.4:.2f} mm"
                else:
                    r_txt = f"{min_corner_in:.4f}\""
                    t_txt = f"{r_tool:.4f}\""
                if r_tool > min_corner_in + 1e-5:
                    msg = (
                        f"Selected feature has a {r_txt} internal corner radius, which is smaller than "
                        f"the cutter radius ({t_txt}). The cutter cannot clean this corner and will "
                        f"slam into a full-width spike if unguarded. Enable Feed Optimization ("
                        f"{feed_scale * 100:.0f}% corner feed) or use a smaller rest-machining tool."
                    )
                else:
                    msg = (
                        f"Internal corner radius ({r_txt}) is tight relative to cutter radius ({t_txt}, "
                        f"{report.corner_ratio * 100:.0f}% ratio). Radial engagement spikes in the corner; "
                        f"reduce corner feedrate to {feed_scale * 100:.0f}% via Fusion Feed Optimization."
                    )
                report.warnings.append({
                    "title": "Tight Internal Corner Engagement Spike",
                    "message": msg,
                    "type": "warning",
                    "fusion": True,
                })

    # 3. Thin-Wall & Thin-Floor Compliance
    op_strat_name = f"{getattr(op, 'strategy', '') or ''} {getattr(op, 'name', '') or ''}"
    check_floor = not is_wall_only_operation(op_strat_name)
    min_wall_in, min_floor_in, max_wall_h_in = _measure_thickness_from_faces(faces)
    if not check_floor:
        min_floor_in = None
    report.min_wall_thickness_in = min_wall_in
    report.min_floor_thickness_in = min_floor_in
    report.wall_height_in = max_wall_h_in

    is_tw, is_tf, comp_factor = calc_thin_wall_compliance_factor(
        min_wall_in, max_wall_h_in, min_floor_in,
        tool_diameter_in=tool_diameter_in,
        check_floor=check_floor,
    )
    report.is_thin_wall = is_tw
    report.is_thin_floor = is_tf
    report.workpiece_compliance_factor = comp_factor

    if is_tw and min_wall_in is not None:
        w_txt = f"{min_wall_in * 25.4:.2f} mm" if is_metric else f"{min_wall_in:.4f}\""
        report.warnings.append({
            "title": "Thin-Wall Workpiece Compliance Detected",
            "message": (
                f"B-Rep inspection detected a thin wall ({w_txt} thickness). Workpiece elastic push-off "
                f"increases total wall error by ~{(comp_factor - 1.0) * 100:.0f}%. Use light radial passes, "
                f"waterline/stepped Z support, and a spring pass."
            ),
            "type": "warning",
            "fusion": True,
        })
    if is_tf and min_floor_in is not None:
        f_txt = f"{min_floor_in * 25.4:.2f} mm" if is_metric else f"{min_floor_in:.4f}\""
        report.warnings.append({
            "title": "Thin-Floor Workpiece Compliance Detected",
            "message": (
                f"B-Rep inspection detected a thin pocket floor ({f_txt} thickness). Axial tool thrust "
                f"will deflect the floor downward and leave it proud on springback."
            ),
            "type": "warning",
            "fusion": True,
        })

    return report


# ---------------------------------------------------------------------------
# Cut widths measured from the operation's selection and B-Rep (setup advisor, docs/SETUP_ADVISOR.md)
# ---------------------------------------------------------------------------
#
# Fusion API objects used (all reads, each guarded with try / hasattr; Autodesk's Fusion API reference):
#   * op.parameters.itemByName('contours' | 'pockets' | 'stockContours').value -> CadContours2dParameterValue,
#     .getCurveSelections() -> CurveSelections (a collection of ChainSelection / PocketSelection / FaceContourSelection /
#     SilhouetteSelection), each with .inputGeometry (the selected BRepEdge / SketchCurve / BRepFace objects)
#     https://help.autodesk.com/cloudhelp/ENU/Fusion-360-API/files/CAMParameters_UM.htm
#   * BRepFace.geometry (Plane / Cylinder), .area (cm^2), .loops, .edges, .boundingBox, .evaluator
#   * BRepLoop.isOuter, .edges;  BRepEdge.length (cm), .geometry (Line3D / Arc3D / Circle3D: .radius), .faces
# Whether getCurveSelections() can be read back on an existing operation and what inputGeometry holds for each selection type
# has to be confirmed on the owner's Fusion (docs/ADDIN_USER_GUIDE.md, "Measured widths"); every failure yields no field.

CM2_TO_IN2 = CM_TO_IN * CM_TO_IN
SELECTION_PARAMS = ("pockets", "contours", "stockContours")
MIN_GAP_IN = 0.01
MAX_GAP_IN = 24.0


def contour_effective_width_in(tool_diameter_in: Optional[float], count: Optional[int], stepover_in: Optional[float]) -> Optional[float]:
    """Effective cut width of a 2D Contour with multiple stepovers: D + (N - 1) x stepover (N >= 1)."""
    if not tool_diameter_in or tool_diameter_in <= 0:
        return None
    n = int(count or 1)
    if n <= 1 or not stepover_in or stepover_in <= 0:
        return float(tool_diameter_in)
    return float(tool_diameter_in) + (n - 1) * float(stepover_in)


def _key(obj) -> Any:
    tok = getattr(obj, "entityToken", None)
    return tok if isinstance(tok, str) and tok else id(obj)


def selection_entities(op) -> Dict[str, List[Any]]:
    """``{"faces": [...], "edges": [...], "other": n}``: the geometry selected by the op's contours / pockets parameter
    (see the section comment above). Empty lists when the parameter or the selections cannot be read."""
    out: Dict[str, List[Any]] = {"faces": [], "edges": [], "other": 0}
    params = getattr(op, "parameters", None)
    if params is None or not hasattr(params, "itemByName"):
        return out
    seen = set()
    for pname in SELECTION_PARAMS:
        try:
            p = params.itemByName(pname)
            val = getattr(p, "value", None) if p is not None else None
            if val is None or not hasattr(val, "getCurveSelections"):
                continue
            sels = val.getCurveSelections()
        except Exception:
            continue
        for sel in _iter_collection(sels):
            try:
                geo = getattr(sel, "inputGeometry", None)
            except Exception:
                geo = None
            for ent in _iter_collection(geo):
                k = _key(ent)
                if k in seen:
                    continue
                seen.add(k)
                if hasattr(ent, "loops") and hasattr(ent, "area"):
                    out["faces"].append(ent)
                elif hasattr(ent, "length") and (hasattr(ent, "faces") or hasattr(ent, "geometry")):
                    out["edges"].append(ent)
                else:
                    out["other"] += 1
    return out


def _is_planar_horizontal(face) -> Optional[int]:
    """+1 for an upward-facing planar face (a pocket floor), -1 downward, None otherwise."""
    geom = getattr(face, "geometry", None)
    if geom is not None and getattr(geom, "radius", None) is not None:
        return None
    norm, _ = _face_normal_and_point_cm(face)
    if norm is None or abs(norm[2]) < 0.98:
        return None
    return 1 if norm[2] > 0 else -1


def _face_loops(face) -> List[Any]:
    return _iter_collection(getattr(face, "loops", None))


def _loop_edges(loop) -> List[Any]:
    return _iter_collection(getattr(loop, "edges", None))


def _adjacent_faces(entities: Dict[str, List[Any]]) -> List[Any]:
    """Selected faces, the faces next to selected edges, and (for a selected floor face) the faces next to its loop edges."""
    faces: Dict[Any, Any] = {}

    def add(f):
        if f is not None:
            faces.setdefault(_key(f), f)
    for f in entities["faces"]:
        add(f)
    for e in entities["edges"]:
        for f in _iter_collection(getattr(e, "faces", None)):
            add(f)
    for f in list(faces.values()):
        if _is_planar_horizontal(f):
            for lp in _face_loops(f):
                for e in _loop_edges(lp):
                    for g in _iter_collection(getattr(e, "faces", None)):
                        add(g)
    return list(faces.values())


def _expand_ring(faces: List[Any]) -> List[Any]:
    """``faces`` plus every face sharing an edge with one of them (a groove is reached from its opening wall)."""
    out: Dict[Any, Any] = {_key(f): f for f in faces}
    for f in faces:
        for e in _iter_collection(getattr(f, "edges", None)):
            for g in _iter_collection(getattr(e, "faces", None)):
                out.setdefault(_key(g), g)
    return list(out.values())


def _vertical_cylinder(face) -> Optional[Tuple[float, Optional[Tuple[float, float]], Optional[bool]]]:
    """(radius_in, axis point xy cm, concave | None) of a vertical cylindrical face, else None."""
    geom = getattr(face, "geometry", None)
    r_cm = getattr(geom, "radius", None) if geom is not None else None
    if r_cm is None:
        return None
    try:
        r_in = float(r_cm) * CM_TO_IN
    except (TypeError, ValueError):
        return None
    axis = _vec_coords(getattr(geom, "axis", None))
    if axis is not None and abs(axis[2]) < 0.70:
        return None
    org = _point_coords_cm(getattr(geom, "origin", None))
    conc = getattr(face, "is_concave", None)
    if conc is None:
        conc = getattr(geom, "is_concave", None)
    if conc is None:
        pt = _point_coords_cm(getattr(face, "pointOnFace", None))
        norm, _ = _face_normal_and_point_cm(face)
        if org is not None and pt is not None and norm is not None:
            conc = ((org[0] - pt[0]) * norm[0] + (org[1] - pt[1]) * norm[1]) > 1e-6
    return r_in, (None if org is None else (org[0], org[1])), conc


def measure_wall_gaps(faces: Iterable[Any]) -> List[Dict[str, Any]]:
    """Open gaps (channels) bounded by opposing walls among ``faces``, inches.

    * pair of vertical planar faces whose outward normals face each other (n1 . n2 <= -0.98) and whose gap lies in the air
      (the other face is in the +n1 direction; the solid-between case is the thin wall of ``_measure_thickness_from_faces``),
      overlapping in height and along the wall: ``{"gap_in", "height_in", "length_in", "kind": "parallel_walls"}``;
    * a concave vertical cylinder alone (a bore / round slot end): ``{"gap_in": 2 R, "kind": "bore"}``; with a convex cylinder
      on the same axis inside it (an annular groove): ``{"gap_in": R_o - R_i, "kind": "concentric_cylinders"}``.
    """
    planes: List[Tuple[Tuple[float, float, float], Tuple[float, float, float], Any, float]] = []
    cyls: List[Tuple[float, Optional[Tuple[float, float]], Optional[bool], Any]] = []
    for f in faces:
        cyl = _vertical_cylinder(f)
        if cyl is not None:
            cyls.append(cyl + (getattr(f, "boundingBox", None),))
            continue
        geom = getattr(f, "geometry", None)
        if geom is not None and getattr(geom, "radius", None) is not None:
            continue
        norm, pt = _face_normal_and_point_cm(f)
        if norm is None or pt is None or abs(norm[2]) > 0.20:
            continue
        bb = getattr(f, "boundingBox", None)
        zb = _bbox_z_bounds_cm(bb)
        planes.append((norm, pt, bb, ((zb[1] - zb[0]) * CM_TO_IN) if zb else 0.0))
    out: List[Dict[str, Any]] = []
    for i in range(len(planes)):
        n1, p1, bb1, _h1 = planes[i]
        for j in range(i + 1, len(planes)):
            n2, p2, bb2, _h2 = planes[j]
            if n1[0] * n2[0] + n1[1] * n2[1] + n1[2] * n2[2] > -0.98:
                continue
            proj = (p2[0] - p1[0]) * n1[0] + (p2[1] - p1[1]) * n1[1] + (p2[2] - p1[2]) * n1[2]
            if proj <= 1e-5:
                continue                      # solid between the faces: a wall, not a channel
            if not _bbox_overlap_2d(bb1, bb2, plane="z", tol_cm=0.02) or not _tangential_overlap_xy(bb1, bb2, n1):
                continue
            gap = proj * CM_TO_IN
            z_ov = _z_overlap_in(bb1, bb2)
            if not MIN_GAP_IN <= gap <= MAX_GAP_IN or (z_ov is not None and z_ov < 0.02):
                continue
            out.append({"gap_in": gap, "height_in": z_ov, "length_in": _tangential_extent_in(bb1, bb2, n1),
                        "kind": "parallel_walls"})
    used = set()
    for a, (r_o, c_o, conc_o, bb_o) in enumerate(cyls):
        if conc_o is not True or r_o < 0.005:
            continue
        inner = None
        for b, (r_i, c_i, conc_i, _bb) in enumerate(cyls):
            if b != a and conc_i is False and r_i < r_o and c_o and c_i and math.hypot(c_o[0] - c_i[0], c_o[1] - c_i[1]) < 0.02:
                inner = (b, r_i)
                break
        if inner is not None:
            used.add(inner[0])
            out.append({"gap_in": r_o - inner[1], "height_in": None, "length_in": None, "kind": "concentric_cylinders"})
        else:
            out.append({"gap_in": 2.0 * r_o, "height_in": None, "length_in": None, "kind": "bore"})
    return out


def _tangential_extent_in(bb1, bb2, norm) -> Optional[float]:
    """Length (in) over which two wall bounding boxes overlap along the wall tangent."""
    try:
        nx, ny = float(norm[0]), float(norm[1])
        mag = math.hypot(nx, ny)
        tx, ty = -ny / mag, nx / mag

        def span(bb):
            xs = (float(bb.minPoint.x), float(bb.maxPoint.x))
            ys = (float(bb.minPoint.y), float(bb.maxPoint.y))
            c = [tx * x + ty * y for x in xs for y in ys]
            return min(c), max(c)
        a, b = span(bb1), span(bb2)
        ov = min(a[1], b[1]) - max(a[0], b[0])
        return ov * CM_TO_IN if ov > 0 else None
    except Exception:
        return None


def measure_tslot_radial_depth(faces: Iterable[Any], kerf_in: Optional[float], tol: float = 0.10) -> Optional[Dict[str, Any]]:
    """Radial depth of a T-slot groove from B-Rep faces: a pair of opposing horizontal planar faces (groove roof and floor, air
    between) whose gap equals the cutter kerf within ``tol`` and which overlap in plan, the vertical planar face spanning that
    gap (the groove back wall) and the parallel vertical wall the groove opens in (same outward normal, nearer the cutter).
    Returns ``{"radial_depth_in", "kerf_in", "grooves"}`` for the deepest unambiguous groove, or None. ``grooves`` > 1 means
    the faces hold several candidate grooves (the caller marks the value ambiguous)."""
    if not kerf_in or kerf_in <= 0:
        return None
    flats, walls = [], []
    for f in faces:
        geom = getattr(f, "geometry", None)
        if geom is not None and getattr(geom, "radius", None) is not None:
            continue
        norm, pt = _face_normal_and_point_cm(f)
        if norm is None or pt is None:
            continue
        bb = getattr(f, "boundingBox", None)
        if abs(norm[2]) >= 0.98:
            flats.append((norm, pt, bb))
        elif abs(norm[2]) <= 0.2:
            walls.append((norm, pt, bb))
    grooves: List[float] = []
    for i in range(len(flats)):
        n1, p1, b1 = flats[i]
        for j in range(i + 1, len(flats)):
            n2, p2, b2 = flats[j]
            if n1[2] * n2[2] > -0.9:
                continue
            proj = (p2[2] - p1[2]) * n1[2]
            if proj <= 1e-5:
                continue                       # solid between: not a groove
            gap = proj * CM_TO_IN
            if abs(gap - kerf_in) > tol * kerf_in or not _bbox_overlap_2d(b1, b2, plane="xy", tol_cm=0.0):
                continue
            zlo, zhi = (p1[2], p2[2]) if p1[2] < p2[2] else (p2[2], p1[2])
            for nb, pb, bbb in walls:           # back wall: spans the groove height, normal toward the opening
                zb = _bbox_z_bounds_cm(bbb)
                if zb is None or abs(zb[0] - zlo) > 0.03 or abs(zb[1] - zhi) > 0.03:
                    continue
                if not _bbox_overlap_2d(bbb, b1, plane="xy", tol_cm=0.02):
                    continue
                for no, po, bbo in walls:       # opening wall: same normal, in front of the back wall, taller than the groove
                    if no is nb or nb[0] * no[0] + nb[1] * no[1] < 0.98:
                        continue
                    zo = _bbox_z_bounds_cm(bbo)
                    if zo is None or not (zo[1] > zhi + 0.03 or zo[0] < zlo - 0.03):
                        continue
                    d = ((po[0] - pb[0]) * nb[0] + (po[1] - pb[1]) * nb[1]) * CM_TO_IN
                    if 0.005 <= d <= 12.0 and _tangential_overlap_xy(bbb, bbo, nb):
                        grooves.append(d)
    if not grooves:
        return None
    return {"radial_depth_in": max(grooves), "kerf_in": kerf_in, "grooves": len(set(round(g, 3) for g in grooves))}


def measure_pocket(entities: Dict[str, List[Any]]) -> Dict[str, Any]:
    """Pocket metrics from the selected floor face(s) (the selection itself or the upward planar face next to the selected
    edges): ``pocket_area_in2`` (the face area, holes for islands already excluded), ``pocket_perimeter_in`` (outer loop),
    ``pocket_island_perimeter_in`` (inner loops), ``pocket_min_corner_radius_in`` (smallest arc edge of the outer loop; none for a
    single full circle). Empty dict when no floor face is found."""
    floors = [f for f in _adjacent_faces(entities) if _is_planar_horizontal(f) == 1]
    if not floors:
        return {}
    area = per = isl = 0.0
    radii: List[float] = []
    for f in floors:
        try:
            area += float(getattr(f, "area")) * CM2_TO_IN2
        except Exception:
            pass
        for lp in _face_loops(f):
            edges = _loop_edges(lp)
            length = sum(float(getattr(e, "length", 0.0) or 0.0) for e in edges) * CM_TO_IN
            outer = getattr(lp, "isOuter", True)
            if outer:
                per += length
                if len(edges) > 1:
                    for e in edges:
                        r = getattr(getattr(e, "geometry", None), "radius", None)
                        if r is not None and float(r) * CM_TO_IN >= 0.005:
                            radii.append(float(r) * CM_TO_IN)
            else:
                isl += length
    out: Dict[str, Any] = {}
    if area > 0:
        out["pocket_area_in2"] = area
    if per > 0:
        out["pocket_perimeter_in"] = per
    if isl > 0:
        out["pocket_island_perimeter_in"] = isl
    if radii:
        out["pocket_min_corner_radius_in"] = min(radii)
    return out


def measure_op_widths(op, tool_diameter_in: Optional[float] = None, kerf_in: Optional[float] = None,
                      kind: Optional[str] = None) -> Dict[str, Any]:
    """Widths and pocket metrics of an operation measured from its selected geometry (inches). Keys present only when measured:

    ``channel_width_in`` (smallest gap between opposing walls bounding the selection, plus ``channel_kind``,
    ``channel_height_in``, ``channel_length_in``, ``channel_gaps_in`` all gaps found), ``radial_depth_brep_in`` (T-slot groove,
    only for slot cutters: ``kind == "tslot"``), and the ``pocket_*`` fields of ``measure_pocket``. Never raises; the faces are
    those of the op's own selection only (an op without a readable selection measures nothing: the setup's bodies are not
    searched because every wall pair in them would qualify)."""
    out: Dict[str, Any] = {}
    try:
        ents = selection_entities(op)
        if not (ents["faces"] or ents["edges"]):
            return out
        faces = _adjacent_faces(ents)
        gaps = measure_wall_gaps(faces)
        if tool_diameter_in:
            fits = [g for g in gaps if g["gap_in"] >= 0.9 * tool_diameter_in]
            gaps = fits or gaps
        if gaps:
            best = min(gaps, key=lambda g: g["gap_in"])
            out["channel_width_in"] = best["gap_in"]
            out["channel_kind"] = best["kind"]
            if best.get("height_in"):
                out["channel_height_in"] = best["height_in"]
            if best.get("length_in"):
                out["channel_length_in"] = best["length_in"]
            if len(gaps) > 1:
                out["channel_gaps_in"] = sorted(round(g["gap_in"], 5) for g in gaps)[:6]
        if kind == "tslot" and kerf_in:
            td = measure_tslot_radial_depth(_expand_ring(_expand_ring(faces)), kerf_in)
            if td:
                out["radial_depth_brep_in"] = td["radial_depth_in"]
                out["radial_depth_grooves"] = td["grooves"]
        out.update(measure_pocket(ents))
    except Exception:
        return {}
    return out
