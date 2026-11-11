"""Helical ramp entry for square end mills (v2): geometry, end-tooth chip, constraints R1–R14 and `optimize_ramp`.

Design: docs/research/v2_ramp_findings.md. Pure functions plus one optimizer. The side (peripheral) cut reuses
`physics_v2.optimize` (C1–C5, C7, C8, C11, C14) at slot engagement; the end (bottom) cut and the helix are new.

Geometry (tool-centre helix; Fusion's "helical ramp diameter" and "ramping angle" are taken on this path)
------------------------------------------------------------------------------------------------------
    D           tool diameter, R = D/2
    D_h         helix diameter of the tool centre;  bore (hole) diameter D_hole = D_h + D
    core        a standing core of diameter D_h − D remains when D_h > D (bore > 2·D)
    α           ramp angle of the tool-centre path:  pitch p = π·D_h·tan α  (axial advance per helix turn)
    fz          feed per tooth along the tool-centre path (the CAM ramp feed / (z·n))
    h_a         axial chip of every end tooth = the descent per tooth = fz·sin α
    v_z         descent rate = z·n·fz·sin α = z·n·h_a

End teeth. The bottom face is over floor material at every instant (the tool-centre path lies inside the bore),
and every end tooth sweeps every floor point under the face once per tooth period while the tool drops h_a, so
each end tooth removes a uniform axial layer h_a. The cutting velocity of an end edge is in the bottom plane, so
h_a is also the chip thickness normal to it. With the end edges reaching the centre (centre cutting), all z end
teeth cut over 0 ≤ r ≤ R: torque T_end = z·(kc(h_a)·h_a + K_te)·R²/2 (an upper bound when only some edges reach
the centre). h_a is uniform over the face, so the end cut adds no net lateral force. A dished end (concave
1–3°) raises the trailing-half chip towards fz·(sin α + tan δ); it is not modelled, which keeps R1 conservative.

Side teeth. The tool translates along a circle; its rigid motion relative to the bore per tooth is a rotation
Δθ = fz·cos α/(D_h/2) about the helix axis. The normal displacement of a peripheral point at angle β from the
outward radial is Δθ·(D_h/2)·sin β (the R-dependent part is tangential), so the side chip is fz·cos α·sin β:
a full-slot chip distribution (maximum fz·cos α at the front) whatever D_h. The uncut height in front of the
tool is the helical floor of the previous turn, at most p. C3/C4 take the side cut as a slot of depth p (an upper
bound); the volume balance gives the equivalent depth used for power:
    side area rate = v_z·(A_bore − π·D²/4),  A_bore = π/4·(D_hole² − core²)
    ap_eq = tan α·(A_bore − π·D²/4)/D        (0.625·p at D_h = 0.5·D, 0.75·p at D_h = D)

Plunge. α = 90°: the axial chip per tooth h_p is the plunge feed per tooth and only the end edges cut, so R1 and
R2 bound it as they bound h_a. The plunge feed is z·n·h_p with h_p at R2 (the fastest the end edges take), capped
by R14p (which wins over R1, as R14a does; without a vendor plunge factor R1 is a floor).

Speeds. fz and α are chosen at C7's slot-engagement speed; the feeds are returned at the operation's spindle speed,
which Fusion uses for the ramp (user decision 2026-10-18), with C5 and C11 re-checked there.

Constraints (each a `optimize.Check`)
-------------------------------------
    R1   end-tooth chip h_a ≥ λ·r_β (no rubbing; 17-4 work-hardens; C1's basis and λ). r_β by coating and diameter
         (`edge_radius`). With a vendor consensus angle (R14a) the cap wins: R1 is enforced while an angle under the
         cap meets it, otherwise it is a reported warning (user decision 2026-10-18)
    R2   end-tooth chip ≤ the end-edge limit: the vendor-median plunge chip per tooth h_p/D by diameter band
         (data/model_v2/ramp.json `end_chip`; vendor plunge tables are the only published loads on the end edges
         alone), scaled by aggressiveness like C2. Vendors' ramp-angle limits put 3–5× less chip on the end edges
         than their plunge tables, so the angle limit is R14a's business, not R2's
    R6   helix: D_h ≤ D (no standing core for a centre-cutting tool) and the vendor-consensus bore range
    C1–C5, C7, C8, C11, C14 on the side cut (slot, ap = p); C5 includes the end-tooth torque
    R14  vendor-consensus ramp guardrail (≥ 2 independent vendor groups, widened stepwise): R14a α ≤ s·median of
         the vendors' (maximum) ramp angle; R14p plunge feed ≤ s·median plunge/slot feed factor × the ramp feed (the
         ramp's side cut is a slot, so its feed is the slot feed at the ramp speed). The vendors' ramp/slot feed
         factor (median ≈ 1) is not a separate check: the ramp fz already sits at the slot limits (C2, C14f)
"""
import json
import math
import os
from dataclasses import replace

from physics_v2 import forces
from physics_v2 import optimize as o

MM = o.MM_PER_IN
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAMP_PATH = os.path.join(ROOT, "data", "model_v2", "ramp.json")

SRC = {
    "R1": "End-tooth chip h_a = fz·sin α ≥ λ·r_β (no ploughing): C1's basis, λ 0.2–0.4 (Wojciechowski 2022; Li 2021), "
          "r_β by coating and diameter (ramp.edge_radius; docs/research/carbide_and_edge_radius.md §3). Enforced, except "
          "that a vendor consensus angle cap wins over it (user decision 2026-10-18); then it is a rubbing warning",
    "R2": "End-edge chip limit: axial chip per end tooth ≤ the vendor-median plunge chip per tooth h_p/D for this "
          "diameter band (OSG, Kennametal, Kyocera SGS plunge tables; Seco drilling factor × slot fz; "
          "data/model_v2/ramp.json, tools/calibrate_v2_ramp.py), × the aggressiveness scale as C2",
    "R6": "Helix: D_h ≤ D so no core stands in a bore over 2·D (centre-cutting tool); bore within the vendor-consensus "
          "minimum/maximum bore/D (data/model_v2/ramp.json)",
    "R14": "Vendor ramp consensus (user rule 2026-10-17 as C14): ramp angle ≤ consensus_scale(a) × the median over "
           "≥ 2 independent vendor groups of their (maximum) ramp angle, widened stepwise (diameter band, hardness, "
           "family-wide); plunge feed ≤ scale × median plunge/slot feed factor × the ramp (slot-like) feed",
}

ALPHA_MIN_DEG = 0.25
ALPHA_MAX_DEG = 30.0
DH_MAX_OVER_D = 1.0          # bore ≤ 2·D: no standing core (R6)
DH_MIN_OVER_D = 0.1          # fallback floor when no vendor minimum is available (R6)
RAMP_WIDENING = ("exact bucket", "+ neighbouring diameter band", "+ neighbouring hardness bin", "family-wide")
RAMP_FIELDS = ("angle_deg", "hole_min_over_D", "hole_max_over_D", "ramp_feed_factor", "plunge_feed_factor")


# ---------------------------------------------------------------------------
# Geometry (pure)
# ---------------------------------------------------------------------------

def pitch(D_h, alpha_deg):
    """Axial advance per helix turn of the tool centre: p = π·D_h·tan α (units of D_h)."""
    return math.pi * D_h * math.tan(math.radians(alpha_deg))


def angle_for_pitch(D_h, p):
    return math.degrees(math.atan(p / (math.pi * D_h)))


def bore_diameter(D, D_h):
    return D + D_h


def core_diameter(D, D_h):
    """Diameter of the core left standing in the bore (0 when D_h ≤ D)."""
    return max(0.0, D_h - D)


def end_chip(fz, alpha_deg):
    """Axial chip of each end tooth: the descent per tooth, h_a = fz·sin α (fz along the tool-centre path)."""
    return fz * math.sin(math.radians(alpha_deg))


def bore_area(D, D_h):
    return math.pi / 4.0 * (bore_diameter(D, D_h) ** 2 - core_diameter(D, D_h) ** 2)


def side_equivalent_depth(D, D_h, alpha_deg):
    """Volume-balance side depth ap_eq = tan α·(A_bore − π·D²/4)/D: what the peripheral flutes remove per unit of
    horizontal travel and of width D."""
    return math.tan(math.radians(alpha_deg)) * (bore_area(D, D_h) - math.pi * D * D / 4.0) / D


def end_torque_nm(h_a_mm, D_mm, z, coeffs):
    """Torque of the end teeth (N·m): z·(kc(h_a)·h_a + K_te)·R²/2, every end edge cutting from the centre."""
    if h_a_mm <= 0:
        return 0.0
    R = D_mm / 2.0
    return z * (coeffs.kc(h_a_mm) * h_a_mm + coeffs.k_te) * R * R / 2.0 / 1000.0


def end_thrust_n(h_a_mm, D_mm, z, coeffs):
    """Axial thrust of the end teeth (N), taking the thrust/tangential ratio as K_r (reported only)."""
    if h_a_mm <= 0:
        return 0.0
    return z * (coeffs.k_r * coeffs.kc(h_a_mm) * h_a_mm + coeffs.k_re) * D_mm / 2.0


# ---------------------------------------------------------------------------
# Data (calibration output)
# ---------------------------------------------------------------------------

_CACHE = {}


def load_table(path=None):
    """data/model_v2/ramp.json, or None when it doesn't exist (R2 and R14 are then inactive and say so)."""
    path = path or RAMP_PATH
    if path not in _CACHE:
        try:
            with open(path, encoding="utf-8") as fh:
                _CACHE[path] = json.load(fh)
        except OSError:
            _CACHE[path] = None
    return _CACHE[path]


def end_chip_limit(table, D_in):
    """R2's band for a diameter: {"band", "h_a_over_D", "n", "groups", ...} or None."""
    if not table or not table.get("end_chip"):
        return None
    return o._band_for(table["end_chip"]["bands"], D_in)


def consensus_lookup(table, family, hb, D_in, min_groups=None):
    """The vendor ramp consensus, field by field: each field widens on its own (diameter band, then the
    neighbouring hardness bins, then family-wide) until ≥ min_groups independent vendor groups give it. Each
    group's median over its pooled rows, then the median over groups. Cells are keyed "family|HB bin|band"; rows
    without a published hardness are in bin "x" and join from the hardness step on. Returns {field: {...}}
    (fields that never reach min_groups are absent)."""
    if not table or not table.get("consensus"):
        return {}
    cons = table["consensus"]
    min_groups = min_groups or cons.get("min_vendor_groups", o.CONSENSUS_MIN_GROUPS)
    band = o._band_for(cons["bands"], D_in)
    if band is None or hb is None:
        return {}
    bands = [b["band"] for b in cons["bands"]]
    hbin = int(hb // cons["hb_bin"])
    cells = cons["cells"]
    fam_keys = [k for k in cells if k.split("|")[0] == family]
    out = {}
    for i, field in enumerate(RAMP_FIELDS):
        for step, label in enumerate(RAMP_WIDENING):
            if step == 3:
                keys = fam_keys
            else:
                bset = o._neighbours(bands, band["band"], step >= 1)
                # Rows whose vendor states no hardness (bin "x") join at the hardness-widening step.
                hset = [str(hbin - 1), str(hbin), str(hbin + 1), "x"] if step >= 2 else [str(hbin)]
                keys = ["|".join((family, h, b)) for b in bset for h in hset]
            pooled = {}
            for k in keys:
                for vg, rows in (cells.get(k) or {}).items():
                    vals = [r[i] for r in rows if r[i] is not None]
                    if vals:
                        pooled.setdefault(vg, []).extend(vals)
            if len(pooled) >= min_groups:
                meds = {vg: o._median(v) for vg, v in pooled.items()}
                out[field] = {"median": o._median(list(meds.values())), "group_medians": meds,
                              "widening": label, "step": step, "n_rows": sum(len(v) for v in pooled.values()),
                              "key": "|".join((family, str(hbin), band["band"]))}
                break
    return out


# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

def r1_end_chip_min(h_a_mm, edge_radius_mm, lam):
    lim = lam * edge_radius_mm
    return o.Check("R1", "end-tooth chip (no rubbing)", "min", h_a_mm, lim, "mm", SRC["R1"],
                   detail=f"h_a = fz·sin α = {h_a_mm * 1000:.3g} µm vs λ·r_β = {lam:.3g}·{edge_radius_mm * 1000:.2g} µm "
                          f"= {lim * 1000:.3g} µm")


def r2_end_chip_max(h_a_mm, limit_mm, basis=""):
    if limit_mm is None:
        return o.Check("R2", "end-tooth chip (end-edge limit)", "max", h_a_mm, None, "mm", SRC["R2"], applies=False,
                       detail="no end-chip limit for this diameter (data/model_v2/ramp.json missing or empty)")
    return o.Check("R2", "end-tooth chip (end-edge limit)", "max", h_a_mm, limit_mm, "mm", SRC["R2"],
                   detail=f"h_a = {h_a_mm * 1000:.3g} µm vs {limit_mm * 1000:.3g} µm ({basis})")


def r6_helix(dh_over_D, lo, hi, basis=""):
    """R6 as a 'max' check on the excursion outside [lo, hi] (value = D_h/D, limit = the violated bound)."""
    if dh_over_D > hi * (1 + 1e-9):
        return o.Check("R6", "helix diameter", "max", dh_over_D, hi, "D_h/D", SRC["R6"], detail=basis)
    return o.Check("R6", "helix diameter", "min", dh_over_D, lo, "D_h/D", SRC["R6"],
                   detail=f"D_h/D {dh_over_D:.3f} in [{lo:.3f}, {hi:.3f}]; {basis}")


def r14_angle(alpha_deg, cons, scale):
    c = cons.get("angle_deg")
    if not c:
        return o.Check("R14a", "vendor-consensus ramp angle", "max", alpha_deg, None, "deg", SRC["R14"],
                       applies=False, detail="fewer than 2 vendor groups publish a ramp angle for this cut, even "
                                             "family-wide; the physics angle stands")
    lim = scale * c["median"]
    return o.Check("R14a", "vendor-consensus ramp angle", "max", alpha_deg, lim, "deg", SRC["R14"],
                   detail=f"α {alpha_deg:.2f}° vs {scale:.2f} × vendor median {c['median']:.2f}° = {lim:.2f}° "
                          f"(bucket {c['key']}, {c['widening']}, {c['n_rows']} rows, groups "
                          + ", ".join(f"{g} {v:g}°" for g, v in sorted(c["group_medians"].items())) + ")")


def r14_feed(cid, name, feed_ipm, field, cons, scale, base_feed_ipm):
    """Feed ≤ scale × the vendor-median factor × the base feed (the slot-like ramp feed at the ramp speed)."""
    c = cons.get(field)
    if not c or not base_feed_ipm:
        why = ("no base feed given" if c else "fewer than 2 vendor groups publish this feed factor")
        return o.Check(cid, name, "max", feed_ipm, None, "IPM", SRC["R14"], applies=False, detail=why)
    lim = scale * c["median"] * base_feed_ipm
    return o.Check(cid, name, "max", feed_ipm, lim, "IPM", SRC["R14"],
                   detail=f"{feed_ipm:.2f} IPM vs {scale:.2f} × vendor median factor {c['median']:.2f} × slot-like "
                          f"ramp feed {base_feed_ipm:.2f} = {lim:.2f} IPM ({c['widening']}, groups "
                          + ", ".join(sorted(c["group_medians"])) + ")")


# ---------------------------------------------------------------------------
# One ramp: every check
# ---------------------------------------------------------------------------

class RampContext:
    """Everything fixed for one tool, material, machine and margin set: the side cut's slot context (C1–C5,
    C7, C8, C11, C14 at slot engagement), R1/R2 limits and the vendor ramp consensus. The tool's edge radius is
    the one R1 and the side C1 use (optimize_ramp sets it from `edge_radius` unless overridden)."""

    def __init__(self, tool, material, machine, margins, table=None, consensus=None, n_theta=96, n_quad=32,
                 stock_to_leave_in=o.STOCK_TO_LEAVE_IN):
        self.tool, self.mat, self.mach, self.mg = tool, material, machine, margins
        self.side = o._Context(tool, material, machine, "slot", margins, n_theta, n_quad, consensus=consensus,
                               stock_to_leave_in=stock_to_leave_in, effective_feed_ipm=None)
        self.notes = list(self.side.notes)
        self.table = table
        self.coeffs = self.side.coeffs
        self.h_floor = self.side.lam * tool.edge_radius_mm
        band = end_chip_limit(table, tool.D)
        self.r2_band = band
        if band:
            self.h_cap = band["h_a_over_D"] * tool.D_mm * margins.limit_scale
            self.h_cap_basis = (f"vendor median plunge chip h_p/D {band['h_a_over_D']:.2e} in {band['band']} (n {band['n']}, "
                                f"{len(band.get('groups', []))} groups) ×{margins.limit_scale:.2f}")
        else:
            self.h_cap, self.h_cap_basis = None, ""
            self.notes.append("R2 inactive: no end-chip limit (data/model_v2/ramp.json)")
        self.cons = consensus_lookup(table, material.family, material.hb, tool.D) if material.family else {}
        lo = DH_MIN_OVER_D
        hi = DH_MAX_OVER_D
        basis = [f"D_h ≤ {DH_MAX_OVER_D:g}·D (bore ≤ 2·D, no core)"]
        if "hole_min_over_D" in self.cons:
            lo = max(lo, self.cons["hole_min_over_D"]["median"] - 1.0)
            basis.append(f"vendor median minimum bore {self.cons['hole_min_over_D']['median']:.2f}·D "
                         f"({self.cons['hole_min_over_D']['widening']})")
        else:
            basis.append(f"no vendor minimum bore; floor D_h ≥ {DH_MIN_OVER_D:g}·D")
        if "hole_max_over_D" in self.cons:
            hi = min(hi, self.cons["hole_max_over_D"]["median"] - 1.0)
            basis.append(f"vendor median maximum bore {self.cons['hole_max_over_D']['median']:.2f}·D")
        if lo > hi:
            self.notes.append(f"R6: the vendor minimum bore ({lo + 1:.2f}·D) is above the no-core limit "
                              f"({hi + 1:.2f}·D); D_h is held at {hi:.2f}·D")
            lo = hi
        self.dh_range, self.dh_basis = (lo, hi), "; ".join(basis)
        self._pts = {}
        self._p_free = None

    def point(self, p_in):
        """The side cut as a slot of depth p (cached by p)."""
        key = round(p_in, 10)
        if key not in self._pts:
            self._pts[key] = o.CutPoint(self.side, max(p_in, 1e-6), self.tool.D)
        return self._pts[key]

    def p_free_limits(self, rel_tol=1e-4):
        """(fz_C1, fz_cheap): the side cut's limits that don't depend on the slot depth p. C1/C10 and C2 depend on
        the chips at slot engagement (ae = D) with runout; C11, C14f and C14m are proportional to fz at a fixed rpm
        (C14m's cap scales with ap·ae like the MRR). Only C3–C5 need the forces at (p, fz)."""
        if self._p_free is None:
            pt = self.point(self.tool.D * 0.01)

            def low_ok(fz):
                return all(c.ok for c in pt.lower_checks(fz).values())

            def cheap_ok(fz):
                if not pt.c11(fz).ok:
                    return False
                if not all(c.ok for c in pt.c2_checks(fz).values()):
                    return False
                return all(c.ok for c in pt.c14_checks(fz).values())
            lo = o._bisect_min(low_ok, 1e-7, o.FZ_MAX_IN, rel_tol)
            hi = None
            if cheap_ok(1e-7):
                a, b = 1e-7, o.FZ_MAX_IN
                if cheap_ok(b):
                    hi = b
                else:
                    while b / a > 1.0 + rel_tol:
                        m = math.sqrt(a * b)
                        a, b = (m, b) if cheap_ok(m) else (a, m)
                    hi = a
            self._p_free = (lo, hi)
        return self._p_free


def ramp_checks(rc, dh_over_D, alpha_deg, fz_in, spindle_rpm=None):
    """Every check for one helical ramp (inches): R1, R2, R6, R14 and the side cut's C1–C5, C7, C8, C11, C14.

    spindle_rpm: the speed the ramp actually runs at (the operation's, user decision D4, 2026-10-18); C5 and C11 are
    checked there. None: C7's slot-engagement speed."""
    t = rc.tool
    D_h = dh_over_D * t.D
    p = pitch(D_h, alpha_deg)
    pt = rc.point(p)
    s = rc.mg.consensus_cap_scale
    h_a_mm = end_chip(fz_in, alpha_deg) * MM
    fc, f, beam = pt.force_checks(fz_in)
    out = {}
    out.update(pt.lower_checks(fz_in))
    out.update(pt.c2_checks(fz_in))
    out.update(fc)
    rpm = spindle_rpm or pt.rpm
    torque, t_side, t_end, ap_eq = _torque(rc, D_h, alpha_deg, p, f, h_a_mm)
    power = torque * o.machine_profiles.rad_s(rpm) / 1000.0
    out["C5"] = o.c5_spindle(torque, power, rpm, rc.mach.spindle, rc.mach.rating, rc.mg.limit_margin)
    out.update({"C7": pt.c7, "C8": pt.c8,
                "C11": o.c11_feed(fz_in * t.z * rpm, rc.mach.max_feed_ipm, None)})
    if rc.side.consensus is not None:
        out["C14v"] = pt.c14v
        out.update(pt.c14_checks(fz_in))
    out["R1"] = r1_end_chip_min(h_a_mm, t.edge_radius_mm, rc.side.lam)
    out["R2"] = r2_end_chip_max(h_a_mm, rc.h_cap, rc.h_cap_basis)
    out["R6"] = r6_helix(dh_over_D, rc.dh_range[0], rc.dh_range[1], rc.dh_basis)
    out["R14a"] = r14_angle(alpha_deg, rc.cons, s)
    loads = {"torque_side_nm": t_side, "torque_end_nm": t_end, "power_w": power * 1000.0,
             "thrust_end_n": end_thrust_n(h_a_mm, t.D_mm, t.z, rc.coeffs),
             "lateral_peak_n": f["peak_n"], "deflection_in": beam["delta_in"],
             "wall_deflection_in": beam["wall"]["max_in"], "ap_side_in": p, "ap_eq_in": ap_eq}
    return out, pt, loads


def _torque(rc, D_h, alpha_deg, p, f, h_a_mm):
    """Side torque at the volume-balance depth plus the end-tooth torque (N·m)."""
    t = rc.tool
    ap_eq = side_equivalent_depth(t.D, D_h, alpha_deg)
    t_side = abs(f["torque_mean_nm"]) * min(1.0, ap_eq / p) if p > 0 else 0.0
    t_end = end_torque_nm(h_a_mm, t.D_mm, t.z, rc.coeffs)
    return t_side + t_end, t_side, t_end, ap_eq


_UPPER = ("C2", "C2o", "C3", "C4", "C5", "C11", "C14f", "C14m", "R2")
_LOWER = ("C1", "C10", "R1")


def _fz_window(rc, dh, alpha, enforce_r1=True, rel_tol=1e-4):
    """(fz_lo, fz_hi) for one (D_h, α) by brute force: every check through `ramp_checks` at each trial fz. The
    reference for `_fz_window_fast` (optimize_ramp(method="exhaustive"))."""
    lower = _LOWER if enforce_r1 else ("C1", "C10")

    def ok(keys):
        def pred(fz):
            c = ramp_checks(rc, dh, alpha, fz)[0]
            return all(c[k].ok for k in keys if k in c)
        return pred
    lower_ok, upper_ok = ok(lower), ok(_UPPER)
    lo = o._bisect_min(lower_ok, 1e-7, o.FZ_MAX_IN, rel_tol)
    if lo is None:
        return None
    if not upper_ok(lo):
        return (lo, None)
    a, b = lo, lo * 2.0
    while b < o.FZ_MAX_IN and upper_ok(b):
        a, b = b, b * 2.0
    b = min(b, o.FZ_MAX_IN)
    if upper_ok(b):
        return (lo, b)
    while b / a > 1.0 + rel_tol:
        m = math.sqrt(a * b)
        if upper_ok(m):
            a = m
        else:
            b = m
    return (lo, a)


def _forces_ok(rc, dh, alpha, fz):
    """C3, C4 and C5 (side + end torque, at C7's ramp speed) at one (D_h, α, fz): the only checks that need forces."""
    t = rc.tool
    D_h = dh * t.D
    p = pitch(D_h, alpha)
    pt = rc.point(p)
    fc, f, _ = pt.force_checks(fz)
    if not (fc["C3"].ok and fc["C4"].ok):
        return False
    torque = _torque(rc, D_h, alpha, p, f, end_chip(fz, alpha) * MM)[0]
    power = torque * o.machine_profiles.rad_s(pt.rpm) / 1000.0
    return o.c5_spindle(torque, power, pt.rpm, rc.mach.spindle, rc.mach.rating, rc.mg.limit_margin).ok


def _fz_window_fast(rc, dh, alpha, enforce_r1=True, rel_tol=1e-4):
    """(fz_lo, fz_hi) as `_fz_window`, from the p-independent limits (computed once per context), R1/R2 in closed
    form (h_a = fz·sin α) and a force check at the top of the window; the forces are bisected only when C3–C5 bind."""
    c1, cheap = rc.p_free_limits(rel_tol)
    if c1 is None:
        return None
    sa = math.sin(math.radians(alpha))
    lo = max(c1, rc.h_floor / MM / sa) if enforce_r1 else c1
    if lo > o.FZ_MAX_IN:
        return None
    hi = cheap
    if hi is not None and rc.h_cap is not None:
        hi = min(hi, rc.h_cap / MM / sa)
    if hi is None or hi < lo * (1 - 1e-12):
        return (lo, None)
    if _forces_ok(rc, dh, alpha, hi):
        return (lo, hi)
    if not _forces_ok(rc, dh, alpha, lo):
        return (lo, None)
    a, b = lo, hi
    while b / a > 1.0 + rel_tol:
        m = math.sqrt(a * b)
        if _forces_ok(rc, dh, alpha, m):
            a = m
        else:
            b = m
    return (lo, a)


WINDOWS = {"fast": _fz_window_fast, "exhaustive": _fz_window}


def _alpha_grid(lo, hi, n):
    return [lo * (hi / lo) ** (i / (n - 1)) for i in range(n)]


# r_β of new solid carbide end mills (docs/research/carbide_and_edge_radius.md §3; user decision D1, 2026-10-18).
# Micro (D ≤ 1/8"): Liang et al., Micromachines 2018, D = 0.5 mm UF09 carbide, ~1 µm coatings: AlCrN 0.90, AlTiN 1.2,
# TiN 1.5 µm. Coatings without a measured value (Si-doped, DLC, proprietary/unspecified) take the AlTiN value, the
# middle of 0.9–1.5. Uncoated: the median of the three measured new micro tools (Liang 0.41, Afazov 1.5, Jäckel 3.5).
# Macro (D ≥ 1/4"): 3.5 µm, the only measured new coated end mill above 1 mm (Wojciechowski et al. 2024, 8 mm
# TiAlN ball end). Between 1/8" and 1/4": log-linear in D. No source gives r_β against diameter; this is the
# least-assumption bridge between the two measured scales.
EDGE_RADIUS_MICRO_UM = {"AlCrN": 0.90, "AlTiN/TiAlN": 1.2, "TiN": 1.5, "Si-doped": 1.2, "DLC": 1.2,
                        "unspecified": 1.2, "uncoated": 1.5}
EDGE_RADIUS_MACRO_UM = 3.5
EDGE_RADIUS_D_MICRO_IN = 0.125
EDGE_RADIUS_D_MACRO_IN = 0.25


def coating_class(label):
    """Coating class for r_β: optimize's classes plus TiN (Liang's third coating)."""
    from physics_v2 import params
    if label and "tin" == str(label).strip().lower():
        return "TiN"
    return label if label in EDGE_RADIUS_MICRO_UM else params.coating_class(label)


def edge_radius(D_in, coating=None):
    """(r_β mm, basis) for a new solid carbide end mill of diameter D_in and the given coating label or class."""
    cc = coating_class(coating)
    micro = EDGE_RADIUS_MICRO_UM.get(cc, EDGE_RADIUS_MICRO_UM["unspecified"])
    if D_in <= EDGE_RADIUS_D_MICRO_IN:
        r, how = micro, f"micro end mill, {cc}: {micro:g} µm (Liang et al. 2018, D 0.5 mm"
        how += ", ~1 µm coating)" if cc in ("AlCrN", "AlTiN/TiAlN", "TiN") else (
            "; uncoated median of Liang 0.41, Afazov 1.5, Jäckel 3.5 µm)" if cc == "uncoated"
            else "; no measured value for this coating, the AlTiN value)")
    elif D_in >= EDGE_RADIUS_D_MACRO_IN:
        r, how = EDGE_RADIUS_MACRO_UM, f"{EDGE_RADIUS_MACRO_UM:g} µm (Wojciechowski et al. 2024, 8 mm TiAlN, new)"
    else:
        x = math.log(D_in / EDGE_RADIUS_D_MICRO_IN) / math.log(EDGE_RADIUS_D_MACRO_IN / EDGE_RADIUS_D_MICRO_IN)
        r = micro * (EDGE_RADIUS_MACRO_UM / micro) ** x
        how = (f"log-linear in D between {micro:g} µm at 1/8\" ({cc}, Liang 2018) and {EDGE_RADIUS_MACRO_UM:g} µm at "
               f"1/4\" (Wojciechowski 2024): {r:.2f} µm")
    return r / 1000.0, how


PLUNGE_NOTE = ("Fusion uses the plunge feed for every vertical feed move from the feed height down, in air too; at this "
               "slow plunge feed a 1 mm (0.04\") feed height in micro adaptive operations saves time")


def optimize_ramp(tool, material, machine, aggressiveness=0.5, *, margins=None, table="default", consensus=None,
                  op_feed_ipm=None, op_rpm=None, coating=None, edge_radius_mm=None, n_alpha=16, n_dh=5,
                  score_tol=0.01, n_theta=96, n_quad=32, n_theta_final=360, n_quad_final=64,
                  stock_to_leave_in=o.STOCK_TO_LEAVE_IN, method="fast"):
    """The helical entry for one tool/material/machine: ramp angle, helix diameter, ramp and plunge feed.

    Speed: C7 at slot engagement (the side cut is slot-like), capped by the machine and C14v, chooses fz and α; the
    feeds returned are at the operation's spindle speed `op_rpm` (Fusion runs the ramp at the cutting speed, user
    decision D4), with C5 and C11 re-checked there; without op_rpm, at C7's speed. Objective: the fastest descent
    v_z = z·n·fz·sin α; within `score_tol` of it the gentlest angle, then the largest helix.

    Precedence (user decision D2, 2026-10-18): with a vendor consensus angle (R14a, ≥ 2 groups) the cap wins. R1 is
    enforced while some angle under the cap meets it; when none does, R1 becomes a reported warning (end teeth under
    the minimum chip), as rubbing flutes are in finishing. Without a vendor consensus angle, physics as before: R1 is
    enforced, and when R2 is under R1's floor the end chip sits on the floor. The plunge follows the same rule with
    R14p.

    edge_radius_mm: r_β override; default `edge_radius(D, coating)` (D1). method: "fast" (default) or "exhaustive"
    (every check by brute force; the reference the fast search is tested against).
    op_feed_ipm: the operation's feed (reported). table: data/model_v2/ramp.json ("default"), a dict, or None (R2/R14
    off). consensus: the C14 table for the side cut (as optimize.optimize).
    """
    mg = margins or o.Margins(aggressiveness, scheme="consensus")
    tab = load_table() if table == "default" else table
    if edge_radius_mm is None:
        r_b, r_b_basis = edge_radius(tool.D, coating)
    else:
        r_b, r_b_basis = float(edge_radius_mm), "given"
    tool = replace(tool, edge_radius_mm=r_b)
    window = WINDOWS[method]
    rc = RampContext(tool, material, machine, mg, tab, consensus, n_theta, n_quad, stock_to_leave_in)
    t = tool
    dh_lo, dh_hi = rc.dh_range
    dhs = sorted({dh_hi} | ({dh_lo + (dh_hi - dh_lo) * i / (n_dh - 1) for i in range(n_dh)} if dh_hi > dh_lo else set()),
                 reverse=True)
    alphas = _alpha_grid(ALPHA_MIN_DEG, ALPHA_MAX_DEG, n_alpha)
    a_cap = rc.cons.get("angle_deg")
    a_cap = mg.consensus_cap_scale * a_cap["median"] if a_cap else None
    if a_cap is not None:
        alphas = sorted(set(alphas) | {a_cap})
    conflicts, prov = [], []
    elim = {}

    def geometry_ok(pt):
        bad = [k for k, c in (("C7", pt.c7), ("C8", pt.c8), ("C14v", pt.c14v)) if not c.ok]
        for k in bad:
            elim[k] = elim.get(k, 0) + 1
        return not bad

    def search(under_cap, enforce_r1):
        found = []
        for dh in dhs:
            for a in alphas:
                if under_cap and a_cap is not None and a > a_cap * (1 + 1e-9):
                    continue
                pt = rc.point(pitch(dh * t.D, a))
                if not geometry_ok(pt):
                    continue
                win = window(rc, dh, a, enforce_r1)
                if not win or win[1] is None or win[1] < win[0]:
                    key = "R1/C1" if not win else "upper (C2–C5, C11, C14, R2)"
                    elim[key] = elim.get(key, 0) + 1
                    continue
                found.append({"dh": dh, "alpha": a, "fz": win[1], "fz_lo": win[0], "rpm": pt.rpm,
                              "vz": t.z * pt.rpm * end_chip(win[1], a)})
        return found

    overridden, r1_warning = [], False
    saved_cap = rc.h_cap
    enforce_r1 = True
    cands = search(True, True)
    if not cands and a_cap is not None:
        # D2: the vendor cap wins; R1 is reported.
        enforce_r1, r1_warning = False, True
        cands = search(True, False)
        if cands:
            conflicts.append(f"R1: no angle under the vendor cap {a_cap:.2f}° (R14a) gives the end teeth λ·r_β = "
                             f"{rc.h_floor * 1000:.3g} µm with fz under C2/C14f; the vendor cap wins (user decision "
                             f"2026-10-18) and the end teeth run under the minimum chip (rubbing warning)")
    elif not cands and rc.h_cap is not None and rc.h_cap < rc.h_floor:
        # No vendor consensus angle: physics as before. Empty end-chip window: R1 wins over R2.
        rc.h_cap = rc.h_floor * 1.02
        rc.h_cap_basis += f"; raised to R1's floor {rc.h_floor * 1000:.3g} µm (empty end-chip window)"
        overridden.append("R2")
        conflicts.append(f"R2 ({saved_cap * 1000:.3g} µm) is below R1's rubbing floor ({rc.h_floor * 1000:.3g} µm) and no "
                         f"vendor consensus angle exists: h_a is set on R1's floor (physics)")
        cands = search(False, True)
    if a_cap is None:
        prov.append("R14a: no vendor consensus angle (fewer than 2 groups even family-wide); the angle is physics-only")
    if not cands:
        return {"feasible": False, "eliminated_by": elim, "notes": rc.notes, "conflicts": conflicts,
                "provenance": prov + [f"no feasible ramp: {elim}"]}

    best = max(c["vz"] for c in cands)
    pool = [c for c in cands if c["vz"] >= (1.0 - score_tol) * best]
    a_min = min(c["alpha"] for c in pool)
    pool = [c for c in pool if c["alpha"] <= a_min * (1 + 1e-9)]
    ch = max(pool, key=lambda c: (c["dh"], c["vz"]))
    rule = (f"fastest descent v_z = z·n·fz·sin α (best {best:.3f} IPM at C7's speed); within {score_tol:.0%} of it the "
            f"smallest angle ({ch['alpha']:.2f}°), then the largest helix (D_h {ch['dh']:.2f}·D)")
    # Refine α between the chosen grid angle and the next one below it (same helix): the smallest angle that still
    # reaches (1 − score_tol)·best.
    lower = [a for a in alphas if a < ch["alpha"] * (1 - 1e-9)]
    if lower:
        lo_a, hi_a = lower[-1], ch["alpha"]
        target = (1.0 - score_tol) * best
        for _ in range(10):
            mid = 0.5 * (lo_a + hi_a)
            pt = rc.point(pitch(ch["dh"] * t.D, mid))
            win = window(rc, ch["dh"], mid, enforce_r1) if all(c.ok for c in (pt.c7, pt.c8, pt.c14v)) else None
            good = bool(win and win[1] is not None and win[1] >= win[0])
            if good:
                good = t.z * pt.rpm * end_chip(win[1], mid) >= target
            if good:
                hi_a = mid
                ch = dict(ch, alpha=mid, fz=win[1], fz_lo=win[0], rpm=pt.rpm, vz=t.z * pt.rpm * end_chip(win[1], mid))
            else:
                lo_a = mid
        rule += f"; refined to {ch['alpha']:.2f}° by bisection"
    # Re-check at full resolution; back fz off onto the limits there if needed.
    rc_hi = RampContext(tool, material, machine, mg, tab, consensus, n_theta_final, n_quad_final, stock_to_leave_in)
    rc_hi.h_cap, rc_hi.h_cap_basis = rc.h_cap, rc.h_cap_basis
    fz = ch["fz"]
    checks, pt, loads = ramp_checks(rc_hi, ch["dh"], ch["alpha"], fz)
    if not all(checks[k].ok for k in _UPPER if k in checks):
        win = window(rc_hi, ch["dh"], ch["alpha"], enforce_r1)
        if win and win[1]:
            fz = min(fz, win[1])
            checks, pt, loads = ramp_checks(rc_hi, ch["dh"], ch["alpha"], fz)
    alpha, dh = ch["alpha"], ch["dh"]
    D_h = dh * t.D
    rpm_c7 = pt.rpm
    rpm = float(op_rpm) if op_rpm else rpm_c7
    if op_rpm:
        checks, pt, loads = ramp_checks(rc_hi, dh, alpha, fz, spindle_rpm=rpm)
    h_a = end_chip(fz, alpha)
    feed = fz * t.z * rpm
    vz = h_a * t.z * rpm
    # Plunge: the axial chip per tooth is the plunge feed per tooth; h_p at R2 (or, without R2, the ramp's h_a),
    # capped by R14p against the ramp feed. With a vendor plunge factor the cap wins over R1 (D2); without one, R1
    # is a floor.
    s = mg.consensus_cap_scale
    h_p = (saved_cap / MM) if saved_cap is not None else h_a
    plunge = h_p * t.z * rpm
    pl_chk = r14_feed("R14p", "vendor-consensus plunge feed", plunge, "plunge_feed_factor", rc.cons, s, feed)
    if pl_chk.applies and not pl_chk.ok:
        plunge = pl_chk.limit
    floor_feed = rc_hi.h_floor / MM * t.z * rpm
    warned = ["R1"] if r1_warning else []
    if plunge < floor_feed * (1 - 1e-9):
        if pl_chk.applies:
            warned.append("R1p")
            conflicts.append(f"plunge: the vendor plunge cap ({plunge:.3f} IPM) is under R1's rubbing floor "
                             f"({floor_feed:.3f} IPM); the vendor cap wins (rubbing warning)")
        else:
            conflicts.append(f"plunge: {plunge:.3f} IPM is under R1's rubbing floor; {floor_feed:.3f} IPM is used")
            plunge = floor_feed
    h_p = plunge / (t.z * rpm)
    checks["R14p"] = r14_feed("R14p", "vendor-consensus plunge feed", plunge, "plunge_feed_factor", rc.cons, s, feed)
    checks["R1p"] = replace(r1_end_chip_min(h_p * MM, t.edge_radius_mm, rc_hi.side.lam), id="R1p",
                            name="plunge chip (no rubbing)")
    checks["R2p"] = replace(r2_end_chip_max(h_p * MM, saved_cap, rc_hi.h_cap_basis), id="R2p",
                            name="plunge chip (end-edge limit)")
    if not checks["R2p"].ok and checks["R1p"].ok and h_p * MM <= rc_hi.h_floor * 1.0001:
        overridden.append("R2p")      # the plunge sits on R1's floor because R2 is under it
    binding = [k for k in o._binding(checks) if k not in warned]
    for k in overridden:
        if k not in binding:
            binding.append(k)
    warnings = list(rc.notes)
    if "R1" in warned and not checks["R1"].ok:
        warnings.append(f"WARNING: the end teeth run under the minimum chip: h_a {h_a * MM * 1000:.3g} µm < λ·r_β "
                        f"{rc_hi.h_floor * 1000:.3g} µm (rubbing; the vendor angle cap wins)")
    if "R1p" in warned and not checks["R1p"].ok:
        warnings.append(f"WARNING: the plunge chip {h_p * MM * 1000:.3g} µm is under λ·r_β {rc_hi.h_floor * 1000:.3g} µm "
                        f"(rubbing; the vendor plunge cap wins)")
    warnings += conflicts
    if core_diameter(t.D, D_h) > 0:
        warnings.append(f"a core of {core_diameter(t.D, D_h):.4f}\" stands in the bore")
    if op_rpm and rpm > rpm_c7 * 1.02:
        warnings.append(f"the ramp runs at the operation's {rpm:.0f} rpm ({math.pi * t.D * rpm / 12.0:.0f} SFM), above "
                        f"C7's slot-engagement speed {rpm_c7:.0f} rpm ({math.pi * t.D * rpm_c7 / 12.0:.0f} SFM); fz and "
                        f"the chips are as designed, tool life in the entry is shorter")
    prov += [f"edge radius r_β {r_b * 1000:.3g} µm ({r_b_basis}); λ {rc_hi.side.lam:g} → minimum chip "
             f"{rc_hi.h_floor * 1000:.3g} µm",
             f"side cut: slot of depth p = π·D_h·tan α = {loads['ap_side_in']:.5f}\" (upper bound; volume-balance "
             f"depth {loads['ap_eq_in']:.5f}\"), C7 slot-engagement speed {rpm_c7:.0f} rpm; feeds at {rpm:.0f} rpm"
             + (" (the operation's, D4)" if op_rpm else ""),
             f"end teeth: h_a = fz·sin α = {fz:.6f}·sin {alpha:.2f}° = {h_a:.2e}\" ({h_a * MM * 1000:.3g} µm); "
             f"R1 floor {rc_hi.h_floor * 1000:.3g} µm ({'warning only, D2' if r1_warning else 'enforced'}); R2 cap "
             + (f"{rc_hi.h_cap * 1000:.3g} µm" if rc_hi.h_cap is not None else "off"),
             f"helix: D_h {dh:.3f}·D = {D_h:.4f}\" (bore {bore_diameter(t.D, D_h):.4f}\"); range "
             f"[{rc.dh_range[0]:.3f}, {rc.dh_range[1]:.3f}]·D ({rc.dh_basis})",
             f"selection ({method} search): {rule}",
             f"plunge: {PLUNGE_NOTE}"]
    prov += [f"{k}: {c.detail}" for k, c in checks.items() if c.applies]
    return {
        "feasible": all(c.ok for k, c in checks.items() if k not in overridden and k not in warned),
        "overridden": overridden, "warned": [k for k in warned if not checks[k].ok],
        "r1_warning": "R1" in warned and not checks["R1"].ok,
        "ramp_angle_deg": alpha,
        "helix_diameter_over_D": dh, "helix_diameter_in": D_h,
        "helix_min_diameter_over_D": rc.dh_range[0], "helix_min_diameter_in": rc.dh_range[0] * t.D,
        "bore_diameter_in": bore_diameter(t.D, D_h),
        "pitch_in": loads["ap_side_in"],
        "rpm": rpm_c7, "sfm": math.pi * t.D * rpm_c7 / 12.0, "spindle_rpm": rpm,
        "fz_in": fz, "ramp_feed_ipm": feed, "descent_ipm": vz, "plunge_feed_ipm": plunge,
        "ramp_feed_at_c7_rpm_ipm": fz * t.z * rpm_c7, "ramp_feed_at_op_rpm_ipm": fz * t.z * op_rpm if op_rpm else None,
        "end_chip_in": h_a, "end_chip_floor_in": rc_hi.h_floor / MM,
        "end_chip_cap_in": rc_hi.h_cap / MM if rc_hi.h_cap is not None else None,
        "edge_radius_mm": r_b, "edge_radius_basis": r_b_basis,
        "binding": binding, "checks": {k: c.to_dict() for k, c in checks.items()},
        "violated": [k for k, c in checks.items() if not c.ok and k not in warned],
        "loads": loads, "consensus": rc.cons, "conflicts": conflicts, "warnings": warnings,
        "plunge_note": PLUNGE_NOTE,
        "eliminated_by": elim, "candidates": len(cands), "provenance": prov,
        "aggressiveness": mg.aggressiveness, "method": method,
    }
