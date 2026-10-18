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
by R14p, and never under R1.

Constraints (each a `optimize.Check`)
-------------------------------------
    R1   end-tooth chip h_a ≥ λ·r_β (no rubbing; 17-4 work-hardens; C1's basis and λ, never relaxed)
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
          "r_β of micro end mills 0.4–3.5 µm; docs/research/carbide_and_edge_radius.md §3–4. Never relaxed",
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
    C7, C8, C11, C14 at slot engagement), R1/R2 limits and the vendor ramp consensus."""

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

    def point(self, p_in):
        """The side cut as a slot of depth p (cached by p)."""
        key = round(p_in, 10)
        if key not in self._pts:
            self._pts[key] = o.CutPoint(self.side, max(p_in, 1e-6), self.tool.D)
        return self._pts[key]


def ramp_checks(rc, dh_over_D, alpha_deg, fz_in):
    """Every check for one helical ramp (inches): R1, R2, R6, R14 and the side cut's C1–C5, C7, C8, C11, C14."""
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
    # C5 with the end-tooth torque added to the side cut's (the side cut at the volume-balance depth).
    ap_eq = side_equivalent_depth(t.D, D_h, alpha_deg)
    t_side = abs(f["torque_mean_nm"]) * min(1.0, ap_eq / p) if p > 0 else 0.0
    t_end = end_torque_nm(h_a_mm, t.D_mm, t.z, rc.coeffs)
    torque = t_side + t_end
    power = torque * o.machine_profiles.rad_s(pt.rpm) / 1000.0
    out["C5"] = o.c5_spindle(torque, power, pt.rpm, rc.mach.spindle, rc.mach.rating, rc.mg.limit_margin)
    out.update({"C7": pt.c7, "C8": pt.c8, "C11": pt.c11(fz_in)})
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


_UPPER = ("C2", "C2o", "C3", "C4", "C5", "C11", "C14f", "C14m", "R2")
_LOWER = ("C1", "C10", "R1")


def _fz_window(rc, dh, alpha, rel_tol=0.01):
    """(fz_lo, fz_hi) for one (D_h, α): the lower checks (C1, R1) and the upper (C2–C5, C11, C14, R2)."""
    def ok(keys):
        def pred(fz):
            c = ramp_checks(rc, dh, alpha, fz)[0]
            return all(c[k].ok for k in keys if k in c)
        return pred
    lower_ok, upper_ok = ok(_LOWER), ok(_UPPER)
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


def _alpha_grid(lo, hi, n):
    return [lo * (hi / lo) ** (i / (n - 1)) for i in range(n)]


def optimize_ramp(tool, material, machine, aggressiveness=0.5, *, margins=None, table="default", consensus=None,
                  op_feed_ipm=None, op_rpm=None, n_alpha=16, n_dh=3, score_tol=0.01, n_theta=96, n_quad=32,
                  n_theta_final=360, n_quad_final=64, stock_to_leave_in=o.STOCK_TO_LEAVE_IN):
    """The helical entry for one tool/material/machine: ramp angle, helix diameter, ramp and plunge feed.

    Speed: C7 at slot engagement (the side cut is slot-like), capped by the machine and C14v. Objective: the
    fastest descent v_z = z·n·fz·sin α that meets every check; within `score_tol` of it the gentlest angle (the
    smallest α, so the largest fz and the shallowest side cut), then the largest helix (chip room). R14a (the
    vendor angle cap) never overrides a physics lower bound: when no angle under the cap meets R1 (and C1), the
    smallest physics-feasible angle is used and the conflict is reported. Same for R2 against R1 (the end-chip
    window is empty): h_a is set on R1's floor and R2 is reported as exceeded.

    op_feed_ipm / op_rpm: the operation's feed and spindle speed (reported; the ramp feed at the operation rpm for
    CAM setups without a separate ramp spindle speed).
    table: data/model_v2/ramp.json ("default"), a dict, or None (R2/R14 off).
    consensus: the C14 table for the side cut (as optimize.optimize).
    """
    mg = margins or o.Margins(aggressiveness, scheme="consensus")
    tab = load_table() if table == "default" else table
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
    cands, elim = [], {}
    r2_relaxed = False

    def search(allow_over_cap, relax_r2):
        found = []
        for dh in dhs:
            for a in alphas:
                if not allow_over_cap and a_cap is not None and a > a_cap * (1 + 1e-9):
                    continue
                pt = rc.point(pitch(dh * t.D, a))
                if not all(c.ok for c in (pt.c7, pt.c8, pt.c14v)):
                    for k, c in (("C7", pt.c7), ("C8", pt.c8), ("C14v", pt.c14v)):
                        if not c.ok:
                            elim[k] = elim.get(k, 0) + 1
                    continue
                win = _fz_window(rc, dh, a)
                if not win or win[1] is None or win[1] < win[0]:
                    k = "R1/C1" if not win else ",".join(
                        x for x in _UPPER if x in ramp_checks(rc, dh, a, win[0])[0]
                        and not ramp_checks(rc, dh, a, win[0])[0][x].ok) or "upper"
                    elim[k] = elim.get(k, 0) + 1
                    continue
                fz = win[1]
                vz = t.z * pt.rpm * end_chip(fz, a)
                found.append({"dh": dh, "alpha": a, "fz": fz, "fz_lo": win[0], "vz": vz, "rpm": pt.rpm})
        return found

    saved_cap = rc.h_cap
    overridden = []
    over_cap = False
    cands = search(False, False)
    if not cands and rc.h_cap is not None and rc.h_cap < rc.h_floor:
        # Empty end-chip window: R1 (physics) wins; h_a is held just above its floor (a bisection step of room).
        rc.h_cap = rc.h_floor * 1.02
        rc.h_cap_basis += f"; raised to R1's floor {rc.h_floor * 1000:.3g} µm (empty end-chip window)"
        r2_relaxed = True
        overridden.append("R2")
        conflicts.append(f"R2 ({saved_cap * 1000:.3g} µm) is below R1's rubbing floor ({rc.h_floor * 1000:.3g} µm): "
                         f"no end-chip window; h_a is set on R1's floor (physics is never relaxed; R2 is a vendor-"
                         f"median limit)")
        cands = search(False, True)
    if not cands and a_cap is not None:
        cands = search(True, r2_relaxed)
        if cands:
            over_cap = True
            overridden.append("R14a")
            conflicts.append(f"R14a: no angle under the vendor cap {a_cap:.2f}° meets the physics lower limits "
                             f"(R1 end-chip floor, C1, with fz under C2/C14f); the smallest physics-feasible angle is "
                             f"used")
    if not cands:
        return {"feasible": False, "eliminated_by": elim, "notes": rc.notes, "conflicts": conflicts,
                "provenance": [f"no feasible ramp: {elim}"]}

    if over_cap:
        # Over the vendor cap: stay as close to it as physics allows (the smallest feasible angle).
        a_min = min(c["alpha"] for c in cands)
        pool = [c for c in cands if c["alpha"] <= a_min * (1 + 1e-9)]
        ch = max(pool, key=lambda c: (c["dh"], c["vz"]))
        best = ch["vz"]
        rule = (f"over the vendor angle cap: the smallest physics-feasible angle ({ch['alpha']:.2f}°), then the "
                f"largest helix (D_h {ch['dh']:.2f}·D)")
    else:
        best = max(c["vz"] for c in cands)
        pool = [c for c in cands if c["vz"] >= (1.0 - score_tol) * best]
        a_min = min(c["alpha"] for c in pool)
        pool = [c for c in pool if c["alpha"] <= a_min * (1 + 1e-9)]
        ch = max(pool, key=lambda c: (c["dh"], c["vz"]))
        rule = (f"fastest descent v_z = z·n·fz·sin α (best {best:.3f} IPM); within {score_tol:.0%} of it the smallest "
                f"angle ({ch['alpha']:.2f}°), then the largest helix (D_h {ch['dh']:.2f}·D)")
    # Refine α between the chosen grid angle and the next one below it (same helix): the smallest angle that still
    # has an fz window (over the cap) or still reaches (1 − score_tol)·best (under it).
    lower = [a for a in alphas if a < ch["alpha"] * (1 - 1e-9)]
    if lower:
        lo_a, hi_a = lower[-1], ch["alpha"]
        target = None if over_cap else (1.0 - score_tol) * best
        for _ in range(10):
            mid = 0.5 * (lo_a + hi_a)
            pt = rc.point(pitch(ch["dh"] * t.D, mid))
            win = _fz_window(rc, ch["dh"], mid) if all(c.ok for c in (pt.c7, pt.c8, pt.c14v)) else None
            good = bool(win and win[1] is not None and win[1] >= win[0])
            if good and target is not None:
                good = t.z * pt.rpm * end_chip(win[1], mid) >= target
            if good:
                hi_a = mid
                ch = dict(ch, alpha=mid, fz=win[1], fz_lo=win[0], rpm=pt.rpm, vz=t.z * pt.rpm * end_chip(win[1], mid))
            else:
                lo_a = mid
        rule += f"; refined to {ch['alpha']:.2f}° by bisection"
    # Report at full resolution; back fz off onto the limits there if needed.
    rc_hi = RampContext(tool, material, machine, mg, tab, consensus, n_theta_final, n_quad_final, stock_to_leave_in)
    if r2_relaxed:
        rc_hi.h_cap, rc_hi.h_cap_basis = rc.h_cap, rc.h_cap_basis
    fz = ch["fz"]
    checks, pt, loads = ramp_checks(rc_hi, ch["dh"], ch["alpha"], fz)
    if not all(checks[k].ok for k in _UPPER if k in checks):
        win = _fz_window(rc_hi, ch["dh"], ch["alpha"])
        if win and win[1]:
            fz = min(fz, win[1])
            checks, pt, loads = ramp_checks(rc_hi, ch["dh"], ch["alpha"], fz)
    alpha, dh = ch["alpha"], ch["dh"]
    D_h = dh * t.D
    rpm = pt.rpm
    h_a = end_chip(fz, alpha)
    feed = fz * t.z * rpm
    vz = h_a * t.z * rpm
    # Plunge: the axial chip per tooth is the plunge feed per tooth; h_p at R2 (or, without R2, the ramp's h_a),
    # capped by R14p against the ramp's slot-like feed, never under R1.
    s = mg.consensus_cap_scale
    h_p = (saved_cap / MM) if saved_cap is not None else h_a
    plunge = h_p * t.z * rpm
    pl_chk = r14_feed("R14p", "vendor-consensus plunge feed", plunge, "plunge_feed_factor", rc.cons, s, feed)
    if pl_chk.applies and not pl_chk.ok:
        plunge = pl_chk.limit
    floor_feed = rc_hi.h_floor / MM * t.z * rpm
    if plunge < floor_feed:
        conflicts.append(f"plunge: the vendor plunge cap gives {plunge:.3f} IPM, under R1's rubbing floor; "
                         f"{floor_feed:.3f} IPM is used")
        plunge = floor_feed
    h_p = plunge / (t.z * rpm)
    checks["R14p"] = r14_feed("R14p", "vendor-consensus plunge feed", plunge, "plunge_feed_factor", rc.cons, s, feed)
    checks["R1p"] = replace(r1_end_chip_min(h_p * MM, t.edge_radius_mm, rc_hi.side.lam), id="R1p",
                            name="plunge chip (no rubbing)")
    checks["R2p"] = replace(r2_end_chip_max(h_p * MM, saved_cap, rc_hi.h_cap_basis), id="R2p",
                            name="plunge chip (end-edge limit)")
    if not checks["R2p"].ok and checks["R1p"].ok and h_p * MM <= rc_hi.h_floor * 1.0001:
        overridden.append("R2p")      # the plunge sits on R1's floor because R2 is under it
    binding = o._binding(checks)
    for k in overridden:
        if k not in binding:
            binding.append(k)
    warnings = list(rc.notes) + conflicts
    if core_diameter(t.D, D_h) > 0:
        warnings.append(f"a core of {core_diameter(t.D, D_h):.4f}\" stands in the bore")
    op_rpm_feed = fz * t.z * op_rpm if op_rpm else None
    if op_rpm and op_rpm > rpm * 1.02:
        warnings.append(f"the operation runs {op_rpm:.0f} rpm; at that speed this ramp (fz {fz:.6f}\") needs "
                        f"{op_rpm_feed:.2f} IPM and runs above C7's slot-engagement speed ({rpm:.0f} rpm); set the "
                        f"ramp spindle speed to {rpm:.0f} rpm")
    prov += [f"side cut: slot of depth p = π·D_h·tan α = {loads['ap_side_in']:.5f}\" (upper bound; volume-balance "
             f"depth {loads['ap_eq_in']:.5f}\"), speed C7 at slot engagement {rpm:.0f} rpm",
             f"end teeth: h_a = fz·sin α = {fz:.6f}·sin {alpha:.2f}° = {h_a:.2e}\" ({h_a * MM * 1000:.3g} µm); "
             f"R1 floor {rc_hi.h_floor * 1000:.3g} µm; R2 cap "
             + (f"{rc_hi.h_cap * 1000:.3g} µm" if rc_hi.h_cap is not None else "off"),
             f"helix: D_h {dh:.3f}·D = {D_h:.4f}\" (bore {bore_diameter(t.D, D_h):.4f}\"); range "
             f"[{rc.dh_range[0]:.3f}, {rc.dh_range[1]:.3f}]·D ({rc.dh_basis})",
             f"selection: {rule}"]
    prov += [f"{k}: {c.detail}" for k, c in checks.items() if c.applies]
    return {
        "feasible": all(c.ok for k, c in checks.items() if k not in overridden),
        "overridden": overridden,
        "ramp_angle_deg": alpha,
        "helix_diameter_over_D": dh, "helix_diameter_in": D_h,
        "helix_min_diameter_over_D": rc.dh_range[0], "helix_min_diameter_in": rc.dh_range[0] * t.D,
        "bore_diameter_in": bore_diameter(t.D, D_h),
        "pitch_in": loads["ap_side_in"],
        "rpm": rpm, "sfm": math.pi * t.D * rpm / 12.0,
        "fz_in": fz, "ramp_feed_ipm": feed, "descent_ipm": vz, "plunge_feed_ipm": plunge,
        "end_chip_in": h_a, "end_chip_floor_in": rc_hi.h_floor / MM,
        "end_chip_cap_in": rc_hi.h_cap / MM if rc_hi.h_cap is not None else None,
        "ramp_feed_at_op_rpm_ipm": op_rpm_feed,
        "binding": binding, "checks": {k: c.to_dict() for k, c in checks.items()},
        "violated": [k for k, c in checks.items() if not c.ok],
        "loads": loads, "consensus": rc.cons, "conflicts": conflicts, "warnings": warnings,
        "eliminated_by": elim, "candidates": len(cands), "provenance": prov,
        "aggressiveness": mg.aggressiveness,
    }
