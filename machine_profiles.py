"""Machine profiles: spindle limits (max rpm, power by duty rating, torque curve) for any machine.

Built-in profiles ship in machines/*.json. Profiles the user creates or edits are saved in
data/machines/*.json; a user file with the same id as a built-in one takes its place
(deleting it reverts to the built-in). The active machine, its active spindle and the user's
per-machine overrides (max rpm, max hp, runout) live in data/machine_settings.json:

    {"active_machine": "speedio_s500x2",
     "machines": {"speedio_s500x2": {"active_spindle": "optional_16k", "max_hp": 6.84}}}

Older settings files hold the overrides at the top level ({"max_hp": 6.84}); those apply to
DEFAULT_MACHINE_ID.

Torque curves are [rpm, N·m] points per duty rating. Power (T·omega) is interpolated linearly
in rpm between points, which is exact for both constant-torque and constant-power segments.
"""
import json
import math
import os
import re

ROOT = os.path.dirname(os.path.abspath(__file__))
BUILTIN_DIR = os.path.join(ROOT, "machines")
USER_DIR = os.path.join(ROOT, "data", "machines")
DEFAULT_MACHINE_ID = "speedio_s500x2"
TEST_PROFILE_PREFIX = "test_"   # machines/test_*.json are test fixtures, never listed to users
KW_TO_HP = 1.341

ID_RE = re.compile(r"^[a-z0-9][a-z0-9_-]{0,47}$")
RATINGS = ("continuous", "s3_15pct_10min", "momentary")
RATING_LABELS = {"continuous": "Continuous (S1)", "s3_15pct_10min": "10 min / S3", "momentary": "Momentary / peak"}
RPM_BOUNDS = (100.0, 60000.0)
POWER_KW_BOUNDS = (0.05, 200.0)
TORQUE_NM_BOUNDS = (0.01, 5000.0)
MAX_POINTS = 64
MAX_TEXT = 4000

# Spindle taper / tool interface classes offered in the editor.
TAPERS = ("BT30", "BBT30", "CAT40", "BT40", "BBT40", "HSK-A63", "HSK-E40", "HSK-E32", "ISO30", "R8",
          "ER-spindle", "other")
FEED_BOUNDS_MM_MIN = (1.0, 500000.0)
RAPID_BOUNDS_M_MIN = (0.1, 2000.0)
COOLANT_BAR_BOUNDS = (0.0, 400.0)

# ---------------------------------------------------------------------------
# Default holder / spindle stiffness by taper class (ESTIMATES, used only when a profile has no
# holder_stiffness of its own).
#
# Anchor (published): Ozsahin, Erturk, Ozguven, Budak (2009), Int. J. Machine Tools & Manufacture
#   49:25-35, Table 2 - identified BT40 holder / 16 mm carbide tool joint: k = 51.6 N/um,
#   ktheta = 0.126 N*m/urad (the same source machines/speedio_s500x2.json already cites).
# Spindle body radial stiffness 80 N/um (NK Enginex ATC-BT30 spindle spec, vendor minimum), in series.
# Relative factors on the anchor are engineering ESTIMATES, because no table of N/um per taper was
# found in open literature. What the literature does say, used to pick them:
#   - HSK radial stiffness "up to five times" that of 7/24 taper systems because of the face contact
#     (Moldmaking Technology, "HSK: The Critical Link in High-Speed Milling"; Machinery.co.uk,
#     "Interface choice"); we use a conservative 1.8x for HSK-A63, far below that upper bound.
#   - Aoyama & Inasaki (2001), CIRP Annals 50(1):281-284: HSK static radial stiffness exceeds the 7/24
#     taper on the same spindle, and the gap widens with spindle speed (centrifugal growth loosens
#     the 7/24 taper, tightens HSK).
#   - Dual-contact 7/24 (BBT, BIG-PLUS) adds flange face contact: Big Daishowa describes it as the
#     rigid choice for heavy cuts, without numbers; a 1.3x factor is our estimate.
#   - Taper size: stiffness taken to scale roughly with the gauge diameter relative to the 40 taper
#     (BT30 31.75 mm vs BT40 44.45 mm big end): 0.7x for 30 taper.
# ---------------------------------------------------------------------------
SPINDLE_BODY_K_N_UM = 80.0
ANCHOR_JOINT_K_N_UM = 51.6
ANCHOR_JOINT_KTHETA = 0.126
DUAL_CONTACT_FACTOR = 1.3
TAPER_STIFFNESS_FACTOR = {   # relative to the BT40 anchor, in the class's native contact (BBT/HSK: dual)
    "BT30": 0.7, "BBT30": 0.91, "ISO30": 0.7,
    "CAT40": 1.0, "BT40": 1.0, "BBT40": 1.3,
    "HSK-A63": 1.8, "HSK-E40": 1.2, "HSK-E32": 0.9,
    "R8": 0.5, "ER-spindle": 0.9, "other": 0.6,
}
DUAL_CONTACT_BY_TAPER = {"BBT30": True, "BBT40": True, "HSK-A63": True, "HSK-E40": True, "HSK-E32": True}
STIFFNESS_CITATIONS = (
    "Anchor: Ozsahin, Erturk, Ozguven, Budak 2009, Int J Mach Tools Manuf 49:25 (BT40 joint 51.6 N/um, "
    "0.126 N*m/urad); spindle body >=80 N/um (NK Enginex ATC-BT30 vendor spec) in series. Taper factors "
    "are estimates: HSK up to 5x the 7/24 radial stiffness (Moldmaking Technology; Machinery.co.uk, "
    "'Interface choice'), HSK exceeds 7/24 and gains with speed (Aoyama & Inasaki 2001, CIRP Annals 50(1):281); "
    "dual-contact adds face contact (Big Daishowa).")


def rad_s(rpm):
    return float(rpm) * 2.0 * math.pi / 60.0


def slugify(name):
    slug = re.sub(r"[^a-z0-9]+", "_", str(name).lower()).strip("_")[:40]
    return slug or "machine"


# ---------------------------------------------------------------------------
# Loading
# ---------------------------------------------------------------------------

def is_dual_contact(profile, spindle=None):
    """Dual-contact flag: the spindle's own flag, else the machine's, else the taper class default
    (BBT/HSK are dual contact by design), else False."""
    for src in (spindle or {}, profile or {}):
        if isinstance(src.get("dual_contact"), bool):
            return src["dual_contact"]
    return DUAL_CONTACT_BY_TAPER.get((profile or {}).get("spindle_taper"), False)


def default_holder_stiffness(taper, dual_contact=None):
    """Estimated {k_n_um, ktheta_nm_urad, status, derived: True} for a taper class, or None for an
    unknown class. See the block comment above for the sources; every number is an estimate."""
    if taper not in TAPER_STIFFNESS_FACTOR:
        return None
    if dual_contact is None:
        dual_contact = DUAL_CONTACT_BY_TAPER.get(taper, False)
    f = TAPER_STIFFNESS_FACTOR[taper]
    # HSK and BBT already include the face contact in their factor; the flag only adds it to plain
    # 7/24 classes that the user marks dual-contact (and removes it from BBT marked non-dual).
    native = DUAL_CONTACT_BY_TAPER.get(taper, False)
    if bool(dual_contact) and not native:
        f *= DUAL_CONTACT_FACTOR
    elif not bool(dual_contact) and native:
        f /= DUAL_CONTACT_FACTOR if not taper.startswith("HSK") else 1.5
    joint = ANCHOR_JOINT_K_N_UM * f
    k = 1.0 / (1.0 / SPINDLE_BODY_K_N_UM + 1.0 / joint)
    return {"k_n_um": round(k, 1), "ktheta_nm_urad": round(ANCHOR_JOINT_KTHETA * f, 3),
            "status": (f"ESTIMATE from taper class {taper}"
                       f"{' (dual contact)' if dual_contact else ' (single contact)'}: {STIFFNESS_CITATIONS}"),
            "derived": True}


def effective_holder_stiffness(profile):
    """(stiffness dict or None, source): "profile" when the profile carries its own holder_stiffness
    (measured, provisional or user override), "taper_default" when derived from its spindle_taper and
    dual-contact flag, None when neither exists (old behaviour: the engine's own default)."""
    hs = (profile or {}).get("holder_stiffness")
    if isinstance(hs, dict) and hs.get("k_n_um") and not hs.get("derived"):
        return hs, "profile"
    taper = (profile or {}).get("spindle_taper")
    if taper:
        sp = ((profile or {}).get("spindle_options") or {}).get((profile or {}).get("active_spindle")) or {}
        d = default_holder_stiffness(taper, is_dual_contact(profile, sp))
        if d:
            return d, "taper_default"
    return None, None


def _with_derived_stiffness(profile):
    """Profiles that name a spindle_taper but carry no holder_stiffness get the estimated default, flagged
    derived (never saved back: validate_profile drops derived stiffness), so engine consumers see it."""
    if isinstance(profile, dict) and not profile.get("holder_stiffness"):
        hs, src = effective_holder_stiffness(profile)
        if src == "taper_default":
            profile = dict(profile, holder_stiffness=hs)
    return profile


def _read_dir(path):
    out = {}
    try:
        names = sorted(os.listdir(path))
    except OSError:
        return out
    for name in names:
        if not name.endswith(".json"):
            continue
        mid = name[:-5]
        if not ID_RE.match(mid):
            continue
        try:
            with open(os.path.join(path, name), "r", encoding="utf-8") as fh:
                data = json.load(fh)
        except (OSError, ValueError):
            continue
        if isinstance(data, dict) and isinstance(data.get("spindle_options"), dict):
            out[mid] = _with_derived_stiffness(data)
    return out


def list_profiles(builtin_dir=None, user_dir=None):
    """{id: {"profile", "builtin", "modified"}}; a user file replaces a built-in of the same id."""
    builtin = {mid: p for mid, p in _read_dir(builtin_dir or BUILTIN_DIR).items()
               if not mid.startswith(TEST_PROFILE_PREFIX)}
    user = _read_dir(user_dir or USER_DIR)
    out = {mid: {"profile": p, "builtin": True, "modified": False} for mid, p in builtin.items()}
    for mid, p in user.items():
        out[mid] = {"profile": p, "builtin": mid in builtin, "modified": mid in builtin}
    return out


# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

def _num(val, field, lo, hi, errors, required=False):
    if val is None or (isinstance(val, str) and not val.strip()):
        if required:
            errors.append(f"{field} is required")
        return None
    try:
        num = float(val)
    except (TypeError, ValueError):
        errors.append(f"{field} must be a number")
        return None
    if not math.isfinite(num) or not lo <= num <= hi:
        errors.append(f"{field} must be between {lo:g} and {hi:g}")
        return None
    return num


def _text(val, limit=MAX_TEXT):
    return str(val)[:limit] if val not in (None, "") else None


def _points(raw, field, max_rpm, errors):
    if not isinstance(raw, list) or not raw:
        errors.append(f"{field}: at least one [rpm, N·m] point is required")
        return None
    if len(raw) > MAX_POINTS:
        errors.append(f"{field}: at most {MAX_POINTS} points")
        return None
    pts = []
    for i, pt in enumerate(raw):
        if not isinstance(pt, (list, tuple)) or len(pt) != 2:
            errors.append(f"{field} point {i + 1}: expected [rpm, N·m]")
            return None
        rpm = _num(pt[0], f"{field} point {i + 1} rpm", 0.0, max_rpm or RPM_BOUNDS[1], errors, True)
        nm = _num(pt[1], f"{field} point {i + 1} torque", *TORQUE_NM_BOUNDS, errors, True)
        if rpm is None or nm is None:
            return None
        if pts and rpm <= pts[-1][0]:
            errors.append(f"{field}: rpm must increase from point to point")
            return None
        pts.append([rpm, nm])
    return pts


def simple_spindle_fields(peak_torque_nm, base_rpm, continuous_kw, max_rpm):
    """Spindle fields from the simple mode (peak torque, base rpm, continuous power): constant-power
    continuous curve above base speed (constant torque below it), momentary curve at peak torque up to
    base speed (power held constant above it by capacity()). Marked derived."""
    base = min(float(base_rpm), float(max_rpm))
    peak_kw = round(float(peak_torque_nm) * rad_s(base) / 1000.0, 2)
    note = "Generated from peak torque, base rpm and continuous power (simple mode); not a quoted curve."
    return {
        "base_rpm": base, "power_kw_continuous": float(continuous_kw), "max_torque_nm_momentary": float(peak_torque_nm),
        "power_kw_peak": max(peak_kw, float(continuous_kw)),
        "torque_curve": {"source": "Simple mode: " + note, "ratings": {
            "continuous": {"power_kw": float(continuous_kw), "derived": True, "note": note,
                           "points": points_from_power(continuous_kw, base, max_rpm)},
            "momentary": {"power_kw": max(peak_kw, float(continuous_kw)), "derived": True, "note": note,
                          "points": [[0.0, float(peak_torque_nm)], [base, float(peak_torque_nm)]]}}},
    }


def validate_spindle(key, raw, errors):
    if not ID_RE.match(str(key)):
        errors.append(f"spindle key '{key}' must be lowercase letters, digits, _ or -")
        return None
    if not isinstance(raw, dict):
        errors.append(f"spindle '{key}' must be an object")
        return None
    pre = f"spindle '{key}'"
    if isinstance(raw.get("simple"), dict) and raw.get("power_kw_continuous") in (None, ""):
        raw = dict(raw, power_kw_continuous=raw["simple"].get("continuous_kw"))
    sp = {}
    label = _text(raw.get("label"), 80)
    if label:
        sp["label"] = label
    sp["max_rpm"] = _num(raw.get("max_rpm"), f"{pre} max_rpm", *RPM_BOUNDS, errors, True)
    sp["power_kw_continuous"] = _num(raw.get("power_kw_continuous"), f"{pre} continuous power",
                                     *POWER_KW_BOUNDS, errors, True)
    for field in ("power_kw_10min", "power_kw_peak"):
        sp[field] = _num(raw.get(field), f"{pre} {field}", *POWER_KW_BOUNDS, errors)
    sp["max_torque_nm_momentary"] = _num(raw.get("max_torque_nm_momentary"), f"{pre} momentary torque",
                                         *TORQUE_NM_BOUNDS, errors)
    sp["base_rpm"] = _num(raw.get("base_rpm"), f"{pre} base rpm", 1.0, sp["max_rpm"] or RPM_BOUNDS[1], errors)
    if isinstance(raw.get("dual_contact"), bool):
        sp["dual_contact"] = raw["dual_contact"]
    simple = raw.get("simple")
    if isinstance(simple, dict) and raw.get("torque_curve") in (None, {}, ""):
        peak = _num(simple.get("peak_torque_nm"), f"{pre} simple peak torque", *TORQUE_NM_BOUNDS, errors, True)
        base = _num(simple.get("base_rpm"), f"{pre} simple base rpm", 1.0, sp["max_rpm"] or RPM_BOUNDS[1], errors, True)
        kw = _num(simple.get("continuous_kw"), f"{pre} simple continuous power", *POWER_KW_BOUNDS, errors, True)
        if None not in (peak, base, kw) and sp["max_rpm"]:
            sp.update(simple_spindle_fields(peak, base, kw, sp["max_rpm"]))
            raw = dict(raw, torque_curve=sp["torque_curve"])
    curve = raw.get("torque_curve")
    if curve not in (None, {}, ""):
        if not isinstance(curve, dict) or not isinstance(curve.get("ratings", {}), dict):
            errors.append(f"{pre} torque_curve must be an object with 'ratings'")
        else:
            ratings = {}
            for rname, rdef in (curve.get("ratings") or {}).items():
                if rname not in RATINGS:
                    errors.append(f"{pre}: unknown rating '{rname}' (use {', '.join(RATINGS)})")
                    continue
                if not isinstance(rdef, dict):
                    errors.append(f"{pre} rating '{rname}' must be an object")
                    continue
                pts = _points(rdef.get("points"), f"{pre} {rname}", sp["max_rpm"], errors)
                if pts is None:
                    continue
                r = {"points": pts}
                pkw = _num(rdef.get("power_kw"), f"{pre} {rname} power", *POWER_KW_BOUNDS, errors)
                if pkw is not None:
                    r["power_kw"] = pkw
                r["derived"] = bool(rdef.get("derived", False))
                note = _text(rdef.get("note"), 500)
                if note:
                    r["note"] = note
                ratings[rname] = r
            out_curve = {"ratings": ratings}
            for field in ("source", "format", "quoted"):
                txt = _text(curve.get(field))
                if txt:
                    out_curve[field] = txt
            if ratings:
                sp["torque_curve"] = out_curve
    return {k: v for k, v in sp.items() if v is not None}


def validate_profile(raw):
    """(clean_profile, errors). Unknown top-level text fields are kept (trimmed); numbers are checked."""
    errors = []
    if not isinstance(raw, dict):
        return None, ["profile must be an object"]
    name = _text(raw.get("machine"), 80)
    if not name or not name.strip():
        errors.append("machine name is required")
    spindles_raw = raw.get("spindle_options")
    if not isinstance(spindles_raw, dict) or not spindles_raw:
        errors.append("at least one spindle is required")
        spindles_raw = {}
    if len(spindles_raw) > 12:
        errors.append("at most 12 spindles")
    spindles = {}
    for key, sp in spindles_raw.items():
        clean = validate_spindle(key, sp, errors)
        if clean is not None:
            spindles[key] = clean
    active = raw.get("active_spindle")
    if spindles and active not in spindles:
        active = next(iter(spindles))
    profile = {"machine": (name or "").strip(), "spindle_options": spindles, "active_spindle": active}
    for field in ("source", "taper", "notes"):
        txt = _text(raw.get(field))
        if txt:
            profile[field] = txt
    for field, lim in (("brand", 80), ("model", 80), ("controller", 80)):
        txt = _text(raw.get(field), lim)
        if txt and txt.strip():
            profile[field] = txt.strip()
    taper = raw.get("spindle_taper")
    if taper not in (None, ""):
        if taper in TAPERS:
            profile["spindle_taper"] = taper
        else:
            errors.append(f"spindle_taper must be one of {', '.join(TAPERS)}")
    if isinstance(raw.get("dual_contact"), bool):
        profile["dual_contact"] = raw["dual_contact"]
    feed = _num(raw.get("max_cutting_feed_mm_min"), "max cutting feed", *FEED_BOUNDS_MM_MIN, errors)
    if feed is not None:
        profile["max_cutting_feed_mm_min"] = feed
    rapid = raw.get("rapid_m_min")
    if isinstance(rapid, dict):
        r = {ax: _num(rapid.get(ax), f"rapid {ax}", *RAPID_BOUNDS_M_MIN, errors) for ax in ("x", "y", "z")}
        r = {k: v for k, v in r.items() if v is not None}
        if r:
            profile["rapid_m_min"] = r
    elif isinstance(rapid, (int, float)) and not isinstance(rapid, bool):
        v = _num(rapid, "rapids", *RAPID_BOUNDS_M_MIN, errors)
        if v is not None:
            profile["rapid_m_min"] = {"x": v, "y": v, "z": v}
    tsc = _num(raw.get("through_spindle_coolant_bar"), "through-spindle coolant pressure", *COOLANT_BAR_BOUNDS, errors)
    if tsc is not None:
        profile["through_spindle_coolant_bar"] = tsc
    hs = raw.get("holder_stiffness")
    if isinstance(hs, dict) and not hs.get("derived"):
        k = _num(hs.get("k_n_um"), "holder stiffness k", 0.5, 5000.0, errors)
        kt = _num(hs.get("ktheta_nm_urad"), "holder stiffness ktheta", 0.001, 100.0, errors)
        if k is not None:
            clean = {"k_n_um": k}
            if kt is not None:
                clean["ktheta_nm_urad"] = kt
            for f in ("status", "used_by"):
                t = _text(hs.get(f), 1200)
                if t:
                    clean[f] = t
            clean.setdefault("status", "User override")
            profile["holder_stiffness"] = clean
    return (profile if not errors else None), errors


# ---------------------------------------------------------------------------
# Saving
# ---------------------------------------------------------------------------

def save_user_profile(mid, profile, user_dir=None):
    if not ID_RE.match(mid):
        raise ValueError("invalid machine id")
    d = user_dir or USER_DIR
    os.makedirs(d, exist_ok=True)
    path = os.path.join(d, mid + ".json")
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as fh:
        json.dump(profile, fh, indent=2, ensure_ascii=False)
        fh.write("\n")
    os.replace(tmp, path)
    return path


def delete_user_profile(mid, user_dir=None):
    """Remove the user's file for this id. Returns True if a file was removed."""
    if not ID_RE.match(mid):
        return False
    path = os.path.join(user_dir or USER_DIR, mid + ".json")
    try:
        os.remove(path)
        return True
    except FileNotFoundError:
        return False


def unique_id(name, existing):
    base = slugify(name)
    mid, n = base, 2
    while mid in existing:
        mid = f"{base}_{n}"
        n += 1
    return mid


# ---------------------------------------------------------------------------
# Torque curve
# ---------------------------------------------------------------------------

def points_from_power(power_kw, base_rpm, max_rpm, n_high=4):
    """Constant torque up to base_rpm, then constant power to max_rpm (the usual motor curve)."""
    power_kw, base_rpm, max_rpm = float(power_kw), float(base_rpm), float(max_rpm)
    base_rpm = min(base_rpm, max_rpm)
    t_base = round(power_kw * 1000.0 / rad_s(base_rpm), 2)
    pts = [[0.0, t_base], [base_rpm, t_base]]
    if max_rpm > base_rpm:
        for i in range(1, n_high + 1):
            rpm = base_rpm + (max_rpm - base_rpm) * i / n_high
            pts.append([round(rpm), round(power_kw * 1000.0 / rad_s(rpm), 2)])
    return pts


def rating_points(spindle, rating="continuous"):
    """[rpm, N·m] points for a rating: the stored curve, else one built from power and base rpm."""
    curve = ((spindle.get("torque_curve") or {}).get("ratings") or {}).get(rating)
    if curve and curve.get("points"):
        return [list(map(float, p)) for p in curve["points"]]
    power = {"continuous": spindle.get("power_kw_continuous"),
             "s3_15pct_10min": spindle.get("power_kw_10min")}.get(rating)
    if power and spindle.get("base_rpm") and spindle.get("max_rpm"):
        return points_from_power(power, spindle["base_rpm"], spindle["max_rpm"])
    if rating == "momentary" and spindle.get("max_torque_nm_momentary") and spindle.get("base_rpm"):
        t = float(spindle["max_torque_nm_momentary"])
        return [[0.0, t], [float(spindle["base_rpm"]), t]]
    return None


def capacity(spindle, rpm, rating="continuous"):
    """Spindle capacity at rpm for a rating: {"torque_nm", "power_kw", "basis"} or None.

    Power is interpolated linearly between points (exact for constant-torque and constant-power
    segments). Above the last point the power is held constant; at rpm 0 the first point's
    torque applies. With no curve and no base rpm, only power is known (torque None).
    """
    rpm = max(0.0, float(rpm))
    pts = rating_points(spindle, rating)
    if not pts:
        power = {"continuous": spindle.get("power_kw_continuous"),
                 "s3_15pct_10min": spindle.get("power_kw_10min"),
                 "momentary": spindle.get("power_kw_peak")}.get(rating)
        if not power:
            return None
        return {"torque_nm": None, "power_kw": float(power), "basis": "power only (no torque curve)"}
    if rpm <= pts[0][0]:
        t = pts[0][1]
        return {"torque_nm": t, "power_kw": t * rad_s(rpm) / 1000.0, "basis": "torque curve"}
    power_at = [(r, t * rad_s(r) / 1000.0) for r, t in pts]
    if rpm >= pts[-1][0]:
        p = power_at[-1][1]
        return {"torque_nm": p * 1000.0 / rad_s(rpm), "power_kw": p,
                "basis": "torque curve (constant power past last point)"}
    for (r0, p0), (r1, p1) in zip(power_at, power_at[1:]):
        if r0 <= rpm <= r1:
            p = p0 + (p1 - p0) * (rpm - r0) / (r1 - r0)
            return {"torque_nm": p * 1000.0 / rad_s(rpm), "power_kw": p, "basis": "torque curve"}
    return None


# ---------------------------------------------------------------------------
# Settings (active machine, per-machine overrides)
# ---------------------------------------------------------------------------

def read_settings(path):
    try:
        with open(path, "r", encoding="utf-8") as fh:
            raw = json.load(fh)
    except (OSError, ValueError):
        raw = {}
    if not isinstance(raw, dict):
        raw = {}
    machines = raw.get("machines") if isinstance(raw.get("machines"), dict) else {}
    settings = {"active_machine": raw.get("active_machine") or DEFAULT_MACHINE_ID,
                "machines": {k: dict(v) for k, v in machines.items() if isinstance(v, dict)}}
    legacy = {k: raw[k] for k in ("max_rpm", "max_hp", "runout") if k in raw}
    if legacy:
        settings["machines"].setdefault(DEFAULT_MACHINE_ID, {})
        for k, v in legacy.items():
            settings["machines"][DEFAULT_MACHINE_ID].setdefault(k, v)
    return settings


def write_settings(path, settings):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as fh:
        json.dump({"active_machine": settings["active_machine"], "machines": settings["machines"]}, fh, indent=2)
    os.replace(tmp, path)


def summarize(mid, entry):
    p = entry["profile"]
    return {
        "id": mid,
        "name": p.get("machine") or mid,
        "builtin": entry["builtin"],
        "modified": entry["modified"],
        "active_spindle": p.get("active_spindle"),
        "brand": p.get("brand"), "model": p.get("model"),
        "spindle_taper": p.get("spindle_taper"),
        "dual_contact": is_dual_contact(p, (p.get("spindle_options") or {}).get(p.get("active_spindle"))),
        "spindles": [{"key": k, "label": s.get("label") or k, "max_rpm": s.get("max_rpm"),
                      "power_kw_continuous": s.get("power_kw_continuous")}
                     for k, s in (p.get("spindle_options") or {}).items()],
    }
