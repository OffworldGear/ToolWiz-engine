import os
import io
import json
import math
import uuid
import re
import copy
import logging
from flask import Flask, render_template, request, jsonify, send_file
from werkzeug.exceptions import HTTPException
from gwizard_physics import GWizardPhysics, is_tap_tool_type, is_drilling_tool_type
from pipeline import CutRequest, run_cut
from toolwiz_common.tool_strategy import plan_strategies, slot_faces
from ai_machinist import query_ai_machinist, get_available_gemini_models
from toolwiz_common import (
    ToolKind, classify, is_hole_kind, is_tap_kind, is_milling_kind,
    ToolGeometry, ToolProfile, default_stickout, default_shank, to_inches, UnitError, safe_eval_length,
    tool_unit as tool_unit_of,
    calc_thin_wall_compliance_factor,
)

safe_eval_expr = safe_eval_length  # backwards-compatible alias

app = Flask(__name__)
app.config["MAX_CONTENT_LENGTH"] = 50 * 1024 * 1024  # 50 MB upload/request cap

import cutlog
cutlog.register(app)
import fusion_bridge
fusion_bridge.register(app)
from routes_advice import bp as advice_bp; app.register_blueprint(advice_bp)
from routes_library import bp as library_bp; app.register_blueprint(library_bp)
from routes_master_library import bp as master_library_bp; app.register_blueprint(master_library_bp)
import machine_profiles

# Initialize physics engine
db_path = os.path.join(os.path.dirname(__file__), "materials_database_clean.json")
physics = GWizardPhysics(db_path)

# ---------------------------------------------------------------------------
# Machine profile (defaults for max RPM / max HP)
# ---------------------------------------------------------------------------
MACHINE_PROFILE_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "machines", "speedio_s500x2.json")
KW_TO_HP = 1.341
FALLBACK_MAX_RPM = 16000.0
FALLBACK_MAX_HP = 10.0


def _derive_limits(profile, active=None):
    """Profile copy with active_spindle, max_rpm and max_hp taken from the active spindle."""
    profile = dict(profile or {})
    max_rpm, max_hp = FALLBACK_MAX_RPM, FALLBACK_MAX_HP
    spindles = profile.get("spindle_options") or {}
    if active not in spindles:
        active = profile.get("active_spindle")
    try:
        spindle = spindles.get(active) or {}
        if spindle.get("max_rpm"):
            max_rpm = float(spindle["max_rpm"])
        if spindle.get("power_kw_continuous"):
            max_hp = round(float(spindle["power_kw_continuous"]) * KW_TO_HP, 2)
    except (TypeError, ValueError, AttributeError):
        max_rpm, max_hp = FALLBACK_MAX_RPM, FALLBACK_MAX_HP
    profile["active_spindle"] = active
    profile["max_rpm"] = max_rpm
    profile["max_hp"] = max_hp
    return profile


def load_machine_profile(path=MACHINE_PROFILE_PATH):
    """Load the machine profile and derive default max RPM / HP from the active spindle."""
    profile = {}
    try:
        with open(path, "r", encoding="utf-8") as fh:
            profile = json.load(fh)
    except (OSError, ValueError) as exc:
        logging.getLogger(__name__).warning("Machine profile %s unavailable: %s", path, exc)
        profile = {}
    return _derive_limits(profile if isinstance(profile, dict) else {})


MACHINE = load_machine_profile()

# User overrides for machine limits live on the server so the web UI and the Fusion add-in
# share them. Profile values are the defaults; data/machine_settings.json holds overrides.
MACHINE_SETTINGS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "machine_settings.json")
MACHINE_LIMIT_BOUNDS = {"max_rpm": (100.0, 60000.0), "max_hp": (0.1, 100.0), "runout": (0.0, 0.002)}
DEFAULT_RUNOUT_IN = 0.0002   # TIR at the cutting edge (good ER collet / milling chuck)


def _validated_overrides(raw):
    out = {}
    for key, (lo, hi) in MACHINE_LIMIT_BOUNDS.items():
        try:
            val = float((raw or {}).get(key))
        except (TypeError, ValueError, AttributeError):
            continue
        if lo <= val <= hi:
            out[key] = val
    return out


def active_machine(settings=None):
    """The selected machine profile (machines/ or data/machines/) with its active spindle's limits.

    Falls back to the default machine, then to any profile, then to the built-in fallback limits."""
    settings = settings or machine_profiles.read_settings(MACHINE_SETTINGS_PATH)
    profiles = machine_profiles.list_profiles()
    mid = settings["active_machine"]
    if mid not in profiles:
        default = machine_profiles.DEFAULT_MACHINE_ID
        mid = default if default in profiles else next(iter(profiles), None)
    if mid is None:
        prof = _derive_limits({})
        prof.update(machine_id=None, builtin=False, modified=False)
        return prof
    entry = profiles[mid]
    chosen = (settings["machines"].get(mid) or {}).get("active_spindle")
    prof = _derive_limits(entry["profile"], chosen)
    prof.update(machine_id=mid, builtin=entry["builtin"], modified=entry["modified"])
    return prof


def load_machine_overrides(path=None):
    """Return validated user overrides {max_rpm?, max_hp?, runout?} for the active machine."""
    settings = machine_profiles.read_settings(path or MACHINE_SETTINGS_PATH)
    mid = active_machine(settings).get("machine_id")
    return _validated_overrides(settings["machines"].get(mid) or {})


def _spindle_summary(machine):
    sp = (machine.get("spindle_options") or {}).get(machine.get("active_spindle")) or {}
    curves = {}
    for rating in machine_profiles.RATINGS:
        pts = machine_profiles.rating_points(sp, rating)
        if pts:
            stored = ((sp.get("torque_curve") or {}).get("ratings") or {}).get(rating)
            curves[rating] = {"points": pts,
                              "derived": True if stored is None else bool(stored.get("derived", False)),
                              "label": machine_profiles.RATING_LABELS[rating]}
    return {
        "key": machine.get("active_spindle"),
        "label": sp.get("label") or machine.get("active_spindle"),
        "base_rpm": sp.get("base_rpm"),
        "power_kw_continuous": sp.get("power_kw_continuous"),
        "power_kw_10min": sp.get("power_kw_10min"),
        "power_kw_peak": sp.get("power_kw_peak"),
        "max_torque_nm_momentary": sp.get("max_torque_nm_momentary"),
        "torque_curves": curves,
    }


def machine_limits():
    """Effective limits: user override if set, else the active spindle's profile value."""
    settings = machine_profiles.read_settings(MACHINE_SETTINGS_PATH)
    machine = active_machine(settings)
    ov = _validated_overrides(settings["machines"].get(machine.get("machine_id")) or {})
    return {
        "max_rpm": ov.get("max_rpm", machine["max_rpm"]),
        "max_hp": ov.get("max_hp", machine["max_hp"]),
        "runout": ov.get("runout", machine.get("runout", DEFAULT_RUNOUT_IN)),
        "profile_max_rpm": machine["max_rpm"],
        "profile_max_hp": machine["max_hp"],
        "overridden": sorted(ov.keys()),
        "machine_id": machine.get("machine_id"),
        "machine": machine.get("machine"),
        "spindle": _spindle_summary(machine),
    }

ALLOWED_ORIGINS = ("http://127.0.0.1:5000", "http://localhost:5000") + tuple(
    o.strip().rstrip("/") for o in os.environ.get("TOOLWIZ_EXTRA_ORIGINS", "").split(",") if o.strip())
CLIENT_HEADER = "X-ToolWiz-Client"


@app.before_request
def csrf_guard():
    """Drive-by / CSRF protection for state-changing API calls.

    Browsers cannot attach a custom header cross-origin without a CORS preflight
    (which this server never grants), so requiring X-ToolWiz-Client blocks drive-by
    form posts. A present Origin header must additionally be our own origin.
    """
    if request.method in ("POST", "PUT", "PATCH", "DELETE") and request.path.startswith("/api/"):
        if not (request.headers.get(CLIENT_HEADER) or "").strip():
            return jsonify({"success": False, "error": f"Missing {CLIENT_HEADER} header"}), 403
        origin = request.headers.get("Origin")
        if origin is not None and origin.rstrip("/") not in ALLOWED_ORIGINS:
            return jsonify({"success": False, "error": "Cross-origin request rejected"}), 403
    return None


def _json_body():
    """Request JSON body as a dict ({} when missing/invalid)."""
    data = request.get_json(silent=True)
    return data if isinstance(data, dict) else {}


def _fusion_tool_arg(obj):
    """Validated optional Fusion tool dict ({"type","unit","geometry"}) from a request object."""
    ft = obj.get("fusion_tool") if isinstance(obj, dict) else None
    if ft in (None, "", {}):
        return None
    if not isinstance(ft, dict) or not isinstance(ft.get("geometry"), dict):
        raise ValueError("fusion_tool must be an object with a 'geometry' object")
    return {k: ft[k] for k in ft}


def _fusion_payload(tool_dict):
    """The canonical {"type","unit","geometry"} slice of a raw Fusion tool dict."""
    out = {"type": tool_dict.get("type"), "unit": tool_dict.get("unit"),
           "geometry": tool_dict.get("geometry") or {}}
    if tool_dict.get("description"):
        out["description"] = tool_dict["description"]
    shaft = tool_dict.get("shaft")
    if isinstance(shaft, dict) and shaft.get("segments"):
        out["shaft"] = shaft   # slot / keyseat necks are read from the shaft segments
    return out


def _stickout_arg(data, fusion_tool, default=1.5):
    """Request stickout: with a fusion_tool it only overrides Fusion's LB when explicitly sent."""
    if fusion_tool is not None:
        v = data.get("stickout")
        return float(v) if v not in (None, "") else None
    return float(data.get("stickout", default))


def _runout_arg(data):
    """Explicit runout in inches, preserving 0.0 when sent (falsy 'or' would overwrite 0.0 with default)."""
    v = data.get("runout")
    if v not in (None, ""):
        return float(v)
    return float(machine_limits()["runout"])


def _api_error(exc):
    """Map an exception from an API handler to a JSON error response."""
    if isinstance(exc, HTTPException):
        return jsonify({"success": False, "error": exc.description or exc.name}), (exc.code or 500)
    if isinstance(exc, KeyError):
        key = exc.args[0] if exc.args else ""
        return jsonify({"success": False, "error": f"Missing required field: {key}"}), 400
    if isinstance(exc, (ValueError, TypeError)):
        return jsonify({"success": False, "error": f"Invalid input: {exc}"[:300]}), 400
    app.logger.error("Unhandled error in %s %s", request.method, request.path, exc_info=exc)
    return jsonify({"success": False, "error": "Internal server error"}), 500


@app.errorhandler(413)
def _too_large(_e):
    return jsonify({"success": False, "error": "Request too large (limit 50 MB)"}), 413

@app.route("/")
def index():
    return render_template("index.html")

@app.after_request
def add_header(response):
    """Prevent browser from caching API responses and dynamic templates"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
    return response

# Tool categories grouped by type, ordered HP -> Carbide -> HSS.
# Geometry variants (bull nose, high feed) are NOT categories: they are Geometry selections.
TOOL_GROUPS = [
    {
        "group": "End Mills",
        "tools": [
            "HP Carbide Endmill",
            "Carbide Endmill",
            "Indexable End Or Face Mill",
            "HP HSS Endmill",
            "HSS Endmill",
        ]
    },
    {
        "group": "Drills & Holemaking",
        "tools": [
            "HP Carbide Twist Drill",
            "Carbide Twist Drill",
            "Indexable Drill",
            "Cobalt Twist Drill",
            "Gun Drill",
            "HP HSS Twist Drill",
            "HSS Twist Drill",
            "HSS Spade Drill",
            "HSS Spot Drill",
        ]
    },
    {
        "group": "Reamers",
        "tools": [
            "Carbide Reamer",
            "HSS Reamer",
        ]
    },
    {
        "group": "Threading & Tapping",
        "tools": [
            "Carbide Thread Mill",
            "Tapping",
        ]
    },
    {
        "group": "Saws & Woodruff Cutters",
        "tools": [
            "Carbide Saws & Woodruff Cutters",
            "HSS Saws & Woodruff Cutters",
        ]
    },
    {
        "group": "Turning / Lathe",
        "tools": [
            "Turning: Carbide",
            "Turning: Carbide HSS",
            "Turning: HSS",
        ]
    }
]

@app.route("/api/data", methods=["GET"])
def get_data():
    """Return the data needed to populate the UI dropdowns"""
    families = list(physics.machinability.keys())
    families.sort()
    
    # Flatten tools preserving the exact grouped order (HP -> Carbide -> HSS)
    ordered_tools = []
    for g in TOOL_GROUPS:
        for t in g["tools"]:
            if t not in ordered_tools:
                ordered_tools.append(t)
        
    # Real DB category names (the Tool Material dropdown is derived from these).
    tool_categories = sorted(
        {e["tool"] for e in physics.sfm_data}
        - {"TiAlN Carbide Endmill"}
        - {e["tool"] for e in physics.sfm_data if str(e["tool"]).startswith("Turning:")}
    )

    return jsonify({
        "families": families,
        "tools": ordered_tools,
        "tool_groups": TOOL_GROUPS,
        "tool_categories": tool_categories,
        "alloys": physics.specific_alloys,
        "machine": {**active_machine(), **machine_limits()}
    })


# Which code this process loaded: the desktop launcher restarts a server whose stamp is older than
# the files on disk (a stale server otherwise keeps answering on port 5000 after an update).
from toolwiz_common.server_stamp import code_stamp as _code_stamp
import datetime as _dt
SERVER_INFO = {
    "code_stamp": _code_stamp(os.path.dirname(os.path.abspath(__file__))),
    "pid": os.getpid(),
    "started": _dt.datetime.now().isoformat(timespec="seconds"),
}


@app.route("/api/server_info", methods=["GET"])
def server_info():
    return jsonify(SERVER_INFO)


@app.route("/api/machine_limits", methods=["GET", "POST"])
def api_machine_limits():
    """GET effective limits; POST {maxRpm?, maxHp?, runout?} to override (null/"" clears back to the profile).
    runout is in inches."""
    if request.method == "GET":
        return jsonify({"success": True, **machine_limits()})
    body = _json_body()
    settings = machine_profiles.read_settings(MACHINE_SETTINGS_PATH)
    mid = active_machine(settings).get("machine_id") or machine_profiles.DEFAULT_MACHINE_ID
    entry = settings["machines"].setdefault(mid, {})
    for field, key in (("maxRpm", "max_rpm"), ("maxHp", "max_hp"), ("runout", "runout")):
        if field not in body:
            continue
        val = body[field]
        if val is None or str(val).strip() == "":
            entry.pop(key, None)
            continue
        try:
            num = float(val)
        except (TypeError, ValueError):
            return jsonify({"success": False, "error": f"{field} must be a number"}), 400
        lo, hi = MACHINE_LIMIT_BOUNDS[key]
        if not lo <= num <= hi:
            return jsonify({"success": False, "error": f"{field} must be between {lo:g} and {hi:g}"}), 400
        entry[key] = num
    machine_profiles.write_settings(MACHINE_SETTINGS_PATH, settings)
    return jsonify({"success": True, **machine_limits()})


def _machine_list(settings=None):
    settings = settings or machine_profiles.read_settings(MACHINE_SETTINGS_PATH)
    current = active_machine(settings)
    return {
        "success": True,
        "active_machine": current.get("machine_id"),
        "active_spindle": current.get("active_spindle"),
        "machines": [machine_profiles.summarize(mid, e) for mid, e in machine_profiles.list_profiles().items()],
    }


@app.route("/api/machines", methods=["GET", "POST"])
def api_machines():
    """GET the machine list and the selection. POST {id?, profile} saves a profile to data/machines/
    (a new id when id is absent); editing a built-in machine saves the user's copy under the same id."""
    if request.method == "GET":
        return jsonify(_machine_list())
    body = _json_body()
    profile, errors = machine_profiles.validate_profile(body.get("profile"))
    if errors:
        return jsonify({"success": False, "error": "; ".join(errors[:6])}), 400
    profiles = machine_profiles.list_profiles()
    mid = body.get("id")
    if mid in (None, ""):
        mid = machine_profiles.unique_id(profile["machine"], profiles)
    elif not machine_profiles.ID_RE.match(str(mid)):
        return jsonify({"success": False, "error": "invalid machine id"}), 400
    machine_profiles.save_user_profile(mid, profile)
    return jsonify({**_machine_list(), "id": mid})


@app.route("/api/machines/<mid>", methods=["GET", "DELETE"])
def api_machine(mid):
    """GET one full profile. DELETE removes the user's file; a built-in machine reverts to its shipped profile."""
    profiles = machine_profiles.list_profiles()
    if mid not in profiles:
        return jsonify({"success": False, "error": "unknown machine"}), 404
    if request.method == "GET":
        e = profiles[mid]
        return jsonify({"success": True, "id": mid, "profile": e["profile"], "builtin": e["builtin"],
                        "modified": e["modified"]})
    if not machine_profiles.delete_user_profile(mid):
        return jsonify({"success": False, "error": "This is a built-in machine with no saved edits."}), 400
    settings = machine_profiles.read_settings(MACHINE_SETTINGS_PATH)
    if mid not in machine_profiles.list_profiles():
        settings["machines"].pop(mid, None)
        if settings["active_machine"] == mid:
            settings["active_machine"] = machine_profiles.DEFAULT_MACHINE_ID
        machine_profiles.write_settings(MACHINE_SETTINGS_PATH, settings)
    return jsonify(_machine_list())


@app.route("/api/machines/select", methods=["POST"])
def api_machine_select():
    """POST {machine_id, spindle?}: make this machine (and spindle) active for the web UI and Fusion."""
    body = _json_body()
    mid = body.get("machine_id")
    profiles = machine_profiles.list_profiles()
    if mid not in profiles:
        return jsonify({"success": False, "error": "unknown machine"}), 404
    spindles = profiles[mid]["profile"].get("spindle_options") or {}
    spindle = body.get("spindle")
    if spindle not in (None, "") and spindle not in spindles:
        return jsonify({"success": False, "error": "unknown spindle for this machine"}), 400
    settings = machine_profiles.read_settings(MACHINE_SETTINGS_PATH)
    settings["active_machine"] = mid
    if spindle:
        settings["machines"].setdefault(mid, {})["active_spindle"] = spindle
    machine_profiles.write_settings(MACHINE_SETTINGS_PATH, settings)
    return jsonify({**_machine_list(settings), "limits": machine_limits()})


import v2_bridge


def _request_model(data):
    """Cutting model for this request: its own "model", else the saved setting, else TOOLWIZ_MODEL, else v1.
    Flask's test client (Host "localhost" with no port) ignores the saved setting, so a model saved from
    the web page can't change what the test suite checks."""
    is_test_client = request.host == "localhost"
    return v2_bridge.resolve_model(data.get("model"), use_saved=not is_test_client)[0]


def _tslot_args(data):
    """Optional T-slot / keyseat request fields (see tslot_model) as CutRequest keyword arguments."""
    def num(key):
        v = data.get(key)
        return float(v) if v not in (None, "") else None
    faces = data.get("cuttingFaces")
    tpf = data.get("teethPerFace")
    return dict(
        tooth_form=(str(data["toothForm"]).lower() if data.get("toothForm") else None),
        cutting_faces=([str(f).lower() for f in faces] if isinstance(faces, (list, tuple)) and faces else None),
        teeth_per_face=(int(tpf) if tpf not in (None, "") else None),
        tslot_operation=str(data.get("tslotOperation") or "full_slot").lower(),
        slot_height=num("slotHeight"),
        radial_depth_total=num("radialDepthTotal"),
    )


def _model_fields(res):
    return {"model": res.model, "model_note": res.model_note, "v1": res.v1, "v2": res.v2}


def _optional_length(data, *keys):
    """The first of data[keys] that is a positive number (inches), else None (not given by the user)."""
    for key in keys:
        val = data.get(key)
        if val is None or val == "":
            continue
        try:
            val = float(val)
        except (TypeError, ValueError):
            continue
        if val > 0:
            return val
    return None


def _runout_fields(res):
    """V3 contract fields: flutes cutting, runout regime, the runout at which all flutes cut, runout ratio, and
    whether rpm/feed were computed for the user's DOC/WOC or the recommendation."""
    def r(x, n):
        return None if x is None else round(x, n)
    return {"flutes_cutting": res.flutes_cutting, "runout_regime": res.runout_regime,
            "tir_all_flutes_in": r(res.tir_all_flutes_in, 6), "runout_ratio": r(res.runout_ratio, 4),
            "engagement_source": res.engagement_source}


@app.route("/api/model_settings", methods=["GET", "POST"])
def api_model_settings():
    """GET the cutting model in effect and where it came from; POST {model: "v1"|"v2"} saves it for the
    web page and the Fusion add-in."""
    if request.method == "POST":
        try:
            v2_bridge.save_model(_json_body().get("model"))
        except ValueError as ex:
            return jsonify({"success": False, "error": str(ex)}), 400
    model, source = v2_bridge.resolve_model(None)
    return jsonify({"success": True, "model": model, "source": source, "models": list(v2_bridge.MODELS)})


@app.route("/api/calculate", methods=["POST"])
def calculate():
    """Calculate physics engine parameters from incoming JSON data"""
    try:
        data = _json_body()
        fusion_tool = _fusion_tool_arg(data)
        diameter = float(data.get("diameter", 0.5))
        # The user's own depth and width (the sliders). Absent: v1 keeps its historical 0.25" default; v2 uses the
        # recommendation. rec_doc/rec_woc stay the recommendation either way.
        model = _request_model(data)
        absent = None if model == "v2" else 0.25
        cut_depth = _optional_length(data, "cutDepth") or absent
        cut_width = _optional_length(data, "cutWidth") or absent
        is_metric = bool(data.get("isMetric", False))
        shank_size = float(data.get("shankDiameter") or default_shank(diameter))

        req = CutRequest(
            family=data.get("family", ""),
            alloy=data.get("alloy", ""),
            tool=data.get("tool", ""),
            geometry=data.get("geometry", "Square"),
            operation=data.get("operation", "Roughing"),
            coating=data.get("coating", "Uncoated"),
            diameter=diameter,
            flutes=int(data.get("flutes", 4)),
            flute_length=float(data.get("fluteLength", 1.0)),
            shank_diameter=shank_size,
            neck_diameter=float(data.get("neckDiameter", shank_size)),
            neck_length=float(data.get("neckLength", 0.5)),
            has_relieved_neck=bool(data.get("hasRelievedNeck", False)),
            corner_radius=float(data.get("cornerRadius", 0.0)),
            taper_angle=float(data.get("taperAngle", 0.0)),
            helix_angle=float(data.get("helixAngle", 30.0)),
            stickout=_stickout_arg(data, fusion_tool),
            cutter_thickness=float(data.get("cutterThickness", 0.125)),
            is_carbide=bool(data.get("isCarbide", True)),
            aggressiveness=float(data.get("aggressiveness", 50.0)) / 100.0,  # Scale 0-100 to 0.0-1.0
            max_rpm=float(data.get("maxRpm") or machine_limits()["max_rpm"]),
            max_hp=float(data.get("maxHp") or machine_limits()["max_hp"]),
            runout=_runout_arg(data),
            cut_depth=cut_depth,
            cut_width=cut_width,
            tap_type=data.get("tapType", ""),
            pitch=float(data.get("pitch", 0.05)),
            is_metric=is_metric,
            fusion_tool=fusion_tool,
            model=model,
            machine_profile=active_machine(),
            feature_geometry=data.get("feature_geometry") if isinstance(data.get("feature_geometry"), dict) else None,
            **_tslot_args(data),
        )
        res = run_cut(physics, req)

        diameter = res.diameter
        neck_diameter = res.neck_diameter
        max_radial_reach = (diameter - neck_diameter) / 2.0 if (neck_diameter > 0.0 and neck_diameter < diameter) else diameter

        resp = {
            "success": True,
            "rpm": round(res.rpm),
            "feedrate": round(res.feed_ipm, 2),
            "mrr": round(res.mrr, 6),
            "deflection": round(res.deflection, 7),
            "springback": round(res.springback, 6),
            "total_error": round(res.total_error, 6),
            "wear_comp": round(res.wear_comp, 6),
            "radial_comp": round(res.wear_comp, 6),
            "axial_comp": round(-res.springback, 6),
            "is_floor_finish": res.is_floor_finish,
            "is_finishing": res.is_finishing,
            "sfm": round(res.sfm, 1),
            "effective_diameter": round(res.effective_diameter, 5),
            "contact_sfm": round(res.contact_sfm, 1),
            "base_ipt": round(res.base_ipt, 6),
            "adj_ipt": round(res.adj_ipt, 6),
            "ipr": round(res.ipr, 6),
            "ramp_angle": round(res.ramp_angle, 1),
            "ramp_feed": round(res.ramp_feed, 2),
            "plunge_feed": max(round(res.plunge_feed, 4), 0.0001) if res.feed_ipm > 0.0 else 0.0,
            "rec_doc": round(res.rec_doc, 4),
            "rec_woc": round(res.rec_woc, 4),
            "rec_limit": round(res.rec_limit, 7),
            "max_radial_reach": round(max_radial_reach, 5),
            "neck_diameter": round(neck_diameter, 5),
            "shank_diameter": round(res.shank_diameter, 5),
            "flute_length": round(res.flute_length, 5),
            "is_spindle_limited": res.is_spindle_limited,
            "ideal_rpm": round(res.ideal_rpm),
            "target_sfm": round(res.target_sfm, 1),
            "feasible": res.feasible,
            "limited_by": res.limited_by,
            "tips": res.tips,
            "provenance": res.provenance,
            "profile": res.profile,
            **({"feature_geometry": res.feature_geometry} if res.feature_geometry else {}),
            **({"corner_feed": res.corner_feed_ipm} if res.corner_feed_ipm is not None else {}),
            **({"tslot": res.tslot} if res.tslot else {}),
            **_model_fields(res),
            **_runout_fields(res),
        }
        if res.tap_drill:
            resp["tap_drill"] = res.tap_drill
            resp["tap_type"] = res.tap_type
        from oversight_engine import evaluate_holistic_oversight
        resp["oversight"] = evaluate_holistic_oversight(data, resp, feature_geometry=res.feature_geometry).to_dict()
        return jsonify(resp)

    except Exception as e:
        return _api_error(e)


@app.route("/api/calculate_for_fusion", methods=["POST"])
def calculate_for_fusion():
    """Endpoint specifically designed for the Fusion 360 Add-in"""
    try:
        data = _json_body()
        fusion_tool = _fusion_tool_arg(data)
        diameter = float(data.get("diameter", 0.25))
        shank_size = float(data.get("shankDiameter") or default_shank(diameter))
        pitch = data.get("pitch")

        # The operation's own stepdown / stepover (inches) when the add-in sends them (stepdown/stepover, or
        # cutDepth/cutWidth); otherwise cut_depth / cut_width stay unset and the pipeline uses the recommendation.
        user_depth = _optional_length(data, "stepdown", "cutDepth")
        user_width = _optional_length(data, "stepover", "cutWidth")
        req = CutRequest(
            family=data.get("family", ""),
            alloy=data.get("alloy", ""),
            tool=data.get("tool", "Carbide Endmill"),  # default fallback
            geometry=data.get("geometry", "Square"),
            operation=data.get("operation", "Roughing"),
            coating=data.get("coating", "Uncoated"),
            diameter=diameter,
            flutes=int(data.get("flutes", 4)),
            flute_length=float(data.get("fluteLength", 1.0)),
            shank_diameter=shank_size,
            neck_diameter=float(data.get("neckDiameter", shank_size)),
            neck_length=float(data.get("neckLength", 0.5)),
            has_relieved_neck=bool(data.get("hasRelievedNeck", False)),
            corner_radius=float(data.get("cornerRadius", 0.0)),
            taper_angle=float(data.get("taperAngle", 0.0)),
            helix_angle=float(data.get("helixAngle", 30.0)),
            stickout=_stickout_arg(data, fusion_tool),
            cutter_thickness=float(data.get("cutterThickness", 0.125)),
            is_carbide=bool(data.get("isCarbide", True)),  # Fusion tool implies carbide if not specified
            aggressiveness=float(data.get("aggressiveness", 50.0)) / 100.0,
            max_rpm=float(data.get("maxRpm") or machine_limits()["max_rpm"]),
            max_hp=float(data.get("maxHp") or machine_limits()["max_hp"]),
            runout=_runout_arg(data),
            cut_depth=user_depth,
            cut_width=user_width,
            tap_type=data.get("tapType", ""),
            pitch=float(pitch) if pitch is not None else None,
            is_metric=bool(data.get("isMetric", False)),
            fusion_tool=fusion_tool,
            model=_request_model(data),
            machine_profile=active_machine(),
            feature_geometry=data.get("feature_geometry") if isinstance(data.get("feature_geometry"), dict) else None,
            **_tslot_args(data),
        )
        res = run_cut(physics, req)

        return jsonify({
            "success": True,
            "name": f"ToolWiz: {req.family} - {req.operation}",
            "rpm": round(res.rpm),
            "feed": round(res.feed_ipm, 2),
            "sfm": round(res.sfm, 1),
            "effective_diameter": round(res.effective_diameter, 5),
            "contact_sfm": round(res.contact_sfm, 1),
            "ipt": round(res.adj_ipt, 6),
            "doc": round(res.rec_doc, 5),
            "woc": round(res.rec_woc, 5),
            # the engagement rpm/feed were computed for (the user's stepdown/stepover, else the recommendation)
            "engagement_doc": round(res.doc, 5),
            "engagement_woc": round(res.woc, 5),
            "ramp_feed": round(res.ramp_feed, 2),
            "plunge_feed": max(round(res.plunge_feed, 4), 0.0001) if res.feed_ipm > 0.0 else 0.0,
            "ramp_angle": round(res.ramp_angle, 2),
            # v2 ramp model only (None under v1): tool-centre helix diameter, its minimum, and C7's slot-engagement
            # speed (information only; ramp_feed is at the cutting rpm, which Fusion uses for the ramp)
            "ramp_diameter_in": round(res.ramp_diameter, 5) if res.ramp_diameter is not None else None,
            "ramp_min_diameter_in": round(res.ramp_min_diameter, 5) if res.ramp_min_diameter is not None else None,
            "ramp_rpm": round(res.ramp_rpm) if res.ramp_rpm is not None else None,
            "is_spindle_limited": res.is_spindle_limited,
            "ideal_rpm": round(res.ideal_rpm),
            "feasible": res.feasible,
            "limited_by": res.limited_by,
            "provenance": res.provenance,
            "profile": res.profile,
            "alerts": [{"title": t["title"], "message": t["message"]} for t in res.tips if t.get("fusion")],
            **_runout_fields(res),
            **({"feature_geometry": res.feature_geometry} if res.feature_geometry else {}),
            **({"corner_feed": res.corner_feed_ipm} if res.corner_feed_ipm is not None else {}),
            **({"tslot": res.tslot} if res.tslot else {}),
            "oversight": __import__("oversight_engine").evaluate_holistic_oversight(
                data,
                {"diameter": res.diameter, "flute_length": res.flute_length, "shank_diameter": res.shank_diameter,
                 "doc": res.rec_doc, "woc": res.rec_woc, "rpm": res.rpm, "feed_ipm": res.feed_ipm,
                 "adj_ipt": res.adj_ipt, "deflection": res.deflection, "rec_limit": res.rec_limit,
                 "feasible": res.feasible, "profile": res.profile, "v1": res.v1, "v2": res.v2},
                feature_geometry=res.feature_geometry
            ).to_dict(),
            **_model_fields(res),
        })

    except Exception as e:
        return _api_error(e)


@app.route("/api/threads/standards", methods=["GET"])
def get_thread_standards():
    """Return available thread families, sizes, and classes from the database."""
    try:
        data = physics.get_thread_standards()
        return jsonify({"success": True, **data})
    except Exception as e:
        return _api_error(e)

@app.route("/api/threads/calculate", methods=["POST"])
def calculate_thread():
    """Calculate thread specifications, G-Wizard tapping drill table, and blind hole clearance."""
    try:
        data = _json_body()
        family = data.get("family", "ISO Coarse")
        size = data.get("size", "M1.6-0.35")
        th_class = data.get("class", "6H")
        th_type = data.get("type", "Internal")
        is_form = bool(data.get("isForm", False))
        is_metric = bool(data.get("isMetric", False))
        lead_style = data.get("leadStyle", "form" if is_form else "plug")
        thread_depth = float(data.get("threadDepth", 0.0))
        material_family = data.get("materialFamily", "")

        # Look up thread definition from database
        entry = physics.lookup_thread(family, size, th_class, th_type)

        if entry:
            pitch_in = entry.get("pitch_in", 0.05)
            max_major_in = entry.get("max_major_in", 0.25)
            min_major_in = entry.get("min_major_in", max_major_in)
            max_pitch_in = entry.get("max_pitch_in", max_major_in - 0.6495 * pitch_in)
            min_pitch_in = entry.get("min_pitch_in", max_pitch_in)
            max_minor_in = entry.get("max_minor_in", max_major_in - 1.0825 * pitch_in)
            min_minor_in = entry.get("min_minor_in", max_minor_in)
        else:
            # Custom thread handling
            custom_major = float(data.get("customMajor", 0.25))
            custom_pitch = float(data.get("customPitch", 0.05))
            if is_metric:
                custom_major /= 25.4
                custom_pitch /= 25.4
            pitch_in = custom_pitch
            max_major_in = custom_major
            min_major_in = custom_major
            max_pitch_in = custom_major - 0.649519 * pitch_in
            min_pitch_in = max_pitch_in
            max_minor_in = custom_major - 1.082532 * pitch_in
            min_minor_in = max_minor_in

        # Units conversion for thread depth if supplied in metric
        depth_in = (thread_depth / 25.4) if (is_metric and thread_depth > 0) else thread_depth

        # Calculate drill table using G-Wizard formula
        drills = physics.calc_thread_drill_table(
            major_dia=max_major_in,
            pitch=pitch_in,
            is_form=is_form,
            is_metric=is_metric,
            material_family=material_family
        )

        # Calculate blind hole clearance using G-Wizard formula
        blind_hole = physics.calc_blind_hole_clearance(
            pitch=pitch_in,
            lead_style=lead_style,
            thread_depth=depth_in,
            is_metric=is_metric
        )

        pitch_mm = pitch_in * 25.4
        tpi = (1.0 / pitch_in) if pitch_in > 0 else 0.0

        thread_spec = {
            "name": f"{size} ({family}) - {th_class} {th_type}",
            "family": family,
            "size": size,
            "class": th_class,
            "type": th_type,
            "pitch_in": round(pitch_in, 5),
            "pitch_mm": round(pitch_mm, 4),
            "tpi": round(tpi, 2),
            "thread_angle": 60.0 if "BS" not in family and "Whitworth" not in family else 55.0,
            "major_max_in": round(max_major_in, 4),
            "major_min_in": round(min_major_in, 4),
            "major_max_mm": round(max_major_in * 25.4, 3),
            "major_min_mm": round(min_major_in * 25.4, 3),
            "pitch_dia_max_in": round(max_pitch_in, 4),
            "pitch_dia_min_in": round(min_pitch_in, 4),
            "pitch_dia_max_mm": round(max_pitch_in * 25.4, 3),
            "pitch_dia_min_mm": round(min_pitch_in * 25.4, 3),
            "minor_max_in": round(max_minor_in, 4),
            "minor_min_in": round(min_minor_in, 4),
            "minor_max_mm": round(max_minor_in * 25.4, 3),
            "minor_min_mm": round(min_minor_in * 25.4, 3),
        }

        # Report when the database only had a different class than requested (additive fields).
        class_used = str(entry.get("class", "")) if entry else th_class
        class_fallback = bool(entry) and bool(class_used) and class_used.upper() != str(th_class).upper()
        thread_spec["class_requested"] = th_class
        thread_spec["class_used"] = class_used or th_class

        return jsonify({
            "success": True,
            "thread": thread_spec,
            "class_used": class_used or th_class,
            "class_fallback": class_fallback,
            "blind_hole": blind_hole,
            "drills": drills
        })
    except Exception as e:
        return _api_error(e)

import zipfile
import io
import uuid
from backup_manager import BackupManager
from ToolWizFusionAddin.json_mutator import format_unit
from master_library import (
    generate_presets, effective_aggressiveness, is_toolwiz_preset,
    tool_is_carbide, db_tool_type as _batch_db_tool_type,
)
from tool_merger import (
    parse_dimension_in,
    compute_tool_signature,
    deduplicate_tools,
    merge_multiple_libraries,
    clean_tool_presets
)

bm = BackupManager()

def parse_dim(val, tool_unit=""):
    """Helper to parse tool dimensions from JSON to inches"""
    return parse_dimension_in(val, tool_unit)

def _tool_dict(raw):
    """A tool of the working library as a dict (libraries may hold tools as JSON strings)."""
    return json.loads(raw) if isinstance(raw, str) else raw


def _resolve_tool_index(tools, payload):
    """Index of the tool a request addresses, or (None, error response).

    ``tool_guid`` is the stable address: it survives deletes and re-sorts, which shift every later index.
    ``tool_index`` is the legacy address; when both are sent the guid wins (a stale index is tolerated)."""
    guid = payload.get("tool_guid")
    if guid not in (None, ""):
        for i, t in enumerate(tools):
            if str(_tool_dict(t).get("guid", "")) == str(guid):
                return i, None
        return None, (jsonify({"success": False, "error": f"No tool with guid {guid!r} in the working library."}), 404)
    idx = payload.get("tool_index")
    if idx is None:
        return None, (jsonify({"success": False, "error": "tool_guid or tool_index is required."}), 400)
    if isinstance(idx, bool) or not isinstance(idx, int):
        return None, (jsonify({"success": False, "error": "tool_index must be an integer."}), 400)
    if idx < 0 or idx >= len(tools):
        return None, (jsonify({"success": False, "error": "Invalid tool index."}), 400)
    return idx, None


def _ensure_unique_guids(tools):
    """Give every tool a non-empty, unique guid (the stable address of a tool); returns the tools as dicts."""
    seen, out = set(), []
    for raw in tools:
        t = _tool_dict(raw)
        g = str(t.get("guid") or "")
        if not g or g in seen:
            t["guid"] = str(uuid.uuid4())
        seen.add(t["guid"])
        out.append(t)
    return out


@app.route("/api/twin/export_receive", methods=["POST"])
def twin_export_receive():
    """Receives exported tool library (or multiple libraries) JSON from Fusion 360 Add-in"""
    try:
        data = _json_body()
        if not data:
            return jsonify({"success": False, "error": "No JSON payload received"}), 400
            
        libraries_list = data.get("libraries")
        auto_dedup = bool(data.get("deduplicate", False))
        
        if libraries_list and isinstance(libraries_list, list):
            lib_name = data.get("master_library_name", "Master_Shop_Tool_Crib")
            merged_data, summary = merge_multiple_libraries(libraries_list, master_library_name=lib_name, deduplicate=auto_dedup)
            if not merged_data.get("tools"):
                return jsonify({"success": False, "error": "The harvested libraries contain no tools; the working library was not replaced."}), 400
            merged_data["tools"] = _ensure_unique_guids(merged_data["tools"])
            backup_info = bm.save_working_library(merged_data, lib_name)
            return jsonify({
                "success": True,
                "library_name": lib_name,
                "tool_count": len(merged_data.get("tools", [])),
                "duplicates_merged": summary.get("duplicates_removed", summary.get("deduplication", {}).get("duplicates_removed", 0)),
                "summary": summary,
                "backup": backup_info
            })
        else:
            lib_name = data.get("library_name", "Fusion_Hub_Library")
            raw_tools = data.get("tools", [])
            report = {"duplicates_removed": 0}
            if not isinstance(raw_tools, list) or not raw_tools:
                return jsonify({"success": False, "error": "No tools in the payload; the working library was not replaced."}), 400
            if auto_dedup and raw_tools:
                cleaned_tools, report = deduplicate_tools(raw_tools, preserve_presets=True)
                data["tools"] = cleaned_tools
            data["tools"] = _ensure_unique_guids(data["tools"])
            backup_info = bm.save_working_library(data, lib_name)
            return jsonify({
                "success": True,
                "library_name": lib_name,
                "tool_count": len(data.get("tools", [])),
                "report": report,
                "backup": backup_info
            })
    except Exception as e:
        return _api_error(e)

@app.route("/api/twin/deduplicate", methods=["POST"])
def twin_deduplicate():
    """Deduplicates tools in the active working library and creates a backup snapshot"""
    try:
        data = bm.load_working_library()
        if not data or "tools" not in data:
            return jsonify({"success": False, "error": "No working library loaded to deduplicate."}), 400

        tools = data.get("tools", [])
        initial_count = len(tools)
        deduped_tools, report = deduplicate_tools(tools, preserve_presets=True)

        data["tools"] = _ensure_unique_guids(deduped_tools)
        lib_name = data.get("library_name", "Master_Shop_Tool_Crib")
        backup_info = bm.save_working_library(data, f"{lib_name}_deduped")

        return jsonify({
            "success": True,
            "library_name": lib_name,
            "initial_tool_count": initial_count,
            "tool_count": len(deduped_tools),
            "report": report,
            "backup": backup_info
        })
    except Exception as e:
        return _api_error(e)

@app.route("/api/twin/load", methods=["GET"])
def twin_load():
    """Returns active Digital Twin working library tools, per-tool aggressiveness, presets, and backup history"""
    try:
        data = bm.load_working_library()
        backups = bm.list_backups()
        
        if not data:
            return jsonify({
                "success": True,
                "has_library": False,
                "library_name": "No Library Loaded",
                "tools": [],
                "backups": backups
            })
            
        lib_name = data.get("library_name", "Digital_Twin_Library")
        raw_tools = data.get("tools", [])
        
        tool_manifest = []
        total_presets_count = 0

        for idx, t in enumerate(raw_tools):
            t_dict = json.loads(t) if isinstance(t, str) else t
            geo = t_dict.get("geometry", {})
            kind = classify(t_dict.get("type"))
            geo_error = None
            try:
                unit_label = tool_unit_of(t_dict)
            except (UnitError, ValueError, TypeError):
                unit_label = None
            try:
                g = ToolGeometry.from_fusion(t_dict, stickout_override=t_dict.get("stickout"))
                dia_in, flutes, flute_len = g.diameter, g.flutes, g.flute_length
                shank_dia, corner_rad = g.shank_diameter, g.corner_radius
                stickout, stickout_source = g.stickout, g.stickout_source
            except (UnitError, ValueError, TypeError) as ge:
                geo_error = str(ge)
                dia_in = flutes = flute_len = shank_dia = corner_rad = stickout = 0
                stickout_source = "unavailable"

            post = t_dict.get("post-process") or t_dict.get("postProcess") or {}
            t_num = post.get("number", 0) if isinstance(post, dict) else 0
            desc = t_dict.get("description", f"{dia_in:.3f}in Tool")
            t_type = t_dict.get("type") or geo.get("type") or "end mill"
            custom_aggr = t_dict.get("custom_aggressiveness", None)
            
            presets = (t_dict.get("start-values") or {}).get("presets") or []
            preset_list = []
            materials_seen = set()

            for p in presets:
                p_name = p.get("name", "Preset")
                p_guid = p.get("guid", "")
                p_mat = ""
                if isinstance(p.get("material"), dict):
                    p_mat = p["material"].get("query", "")
                if p_mat:
                    materials_seen.add(p_mat)
                elif " - " in p_name:
                    materials_seen.add(p_name.split(" - ")[0].strip())
                rpm_v = p.get("n", p.get("rpm", 0))
                vc_v, fz_v, vf_v = p.get("v_c", p.get("sfm", 0)), p.get("f_z", p.get("ipt", 0)), p.get("v_f", p.get("feed", 0))

                preset_list.append({
                    "name": p_name,
                    "guid": p_guid,
                    "operation_type": p.get("operation_type", ""),
                    "is_toolwiz": is_toolwiz_preset(p) or bool(p.get("operation_type")) or " - " in p_name,
                    "toolwiz": p.get("toolwiz") if isinstance(p.get("toolwiz"), dict) else None,
                    "material_query": p_mat,
                    "unit": unit_label,
                    "rpm": rpm_v,
                    "n": rpm_v,
                    # All numbers are the stored values in the tool's own unit (`unit`): for a millimeter tool
                    # sfm / v_c is m/min and ipt / f_z, feed / v_f, stepdown, stepover are mm. The names kept
                    # from the inch era (sfm, ipt, feed) do not mean SFM / in / IPM on a metric tool.
                    "feed": vf_v,
                    "v_f": vf_v,
                    "sfm": vc_v,
                    "v_c": vc_v,
                    "ipt": fz_v,
                    "f_z": fz_v,
                    "stepdown": p.get("stepdown", 0),
                    "stepover": p.get("stepover", 0),
                    "ramp_feed": p.get("v_f_ramp", 0),
                    "plunge_feed": p.get("v_f_plunge", 0),
                    "coolant": p.get("tool-coolant", "flood"),
                    "description": p.get("description", "")
                })

            total_presets_count += len(preset_list)
            signature = compute_tool_signature(t_dict)
            
            tool_manifest.append({
                "index": idx,
                "guid": t_dict.get("guid", ""),
                "number": t_num,
                "description": desc,
                "type": t_type,
                "diameter_in": round(dia_in, 4),
                "diameter_mm": round(dia_in * 25.4, 2),
                "flutes": flutes,
                "flute_length_in": round(flute_len, 4),
                "shank_diameter_in": round(shank_dia, 4),
                "corner_radius_in": round(corner_rad, 4),
                "stickout_in": round(stickout, 4),
                "stickout_source": stickout_source,
                "tool_kind": kind.value,
                "unit": unit_label,
                "is_metric": unit_label == "millimeters",
                "geometry_error": geo_error,
                "custom_aggressiveness": custom_aggr,
                "signature": signature,
                "presets": preset_list,
                "preset_count": len(preset_list),
                "materials": sorted(list(materials_seen))
            })
            
        return jsonify({
            "success": True,
            "has_library": True,
            "library_name": lib_name,
            "last_modified": data.get("last_modified", ""),
            "tool_count": len(tool_manifest),
            "total_presets_count": total_presets_count,
            "tools": tool_manifest,
            "backups": backups
        })
    except Exception as e:
        return _api_error(e)

@app.route("/api/twin/tool/<int:index>", methods=["GET"])
def twin_tool(index):
    """Raw Fusion tool dict at `index` of the working library (404 when out of range)."""
    try:
        data = bm.load_working_library()
        raw_tools = (data or {}).get("tools", [])
        if index < 0 or index >= len(raw_tools):
            return jsonify({"success": False, "error": f"Tool index {index} out of range"}), 404
        t = raw_tools[index]
        return jsonify({"success": True, "tool": json.loads(t) if isinstance(t, str) else t})
    except Exception as e:
        return _api_error(e)


@app.route("/api/twin/tool", methods=["GET"])
def twin_tool_by_guid():
    """Raw Fusion tool dict with ``?guid=`` (the stable address; indices shift after deletes). 404 when absent."""
    try:
        data = bm.load_working_library()
        tools = (data or {}).get("tools", [])
        idx, err = _resolve_tool_index(tools, {"tool_guid": request.args.get("guid", "")} if request.args.get("guid")
                                       else {})
        if err:
            return err
        return jsonify({"success": True, "index": idx, "tool": _tool_dict(tools[idx])})
    except Exception as e:
        return _api_error(e)


@app.route("/api/twin/backups", methods=["GET", "POST"])
def twin_backups():
    """List or restore backups"""
    try:
        if request.method == "POST":
            filename = _json_body().get("filename")
            if not filename:
                return jsonify({"success": False, "error": "Filename required"}), 400
            restored = bm.restore_backup(filename)
            return jsonify({"success": True, "restored": filename})
        else:
            return jsonify({"backups": bm.list_backups()})
    except Exception as e:
        return _api_error(e)

@app.route("/api/twin/update_tool", methods=["POST"])
def twin_update_tool():
    """Updates a single tool's number, description, custom aggressiveness override or stickout.

    Address the tool with ``tool_guid`` (stable) or the legacy ``tool_index``."""
    try:
        payload = _json_body()
        library_data = bm.load_working_library()
        if not library_data or "tools" not in library_data:
            return jsonify({"success": False, "error": "No working library loaded."}), 400
        tools = library_data["tools"]
        tool_idx, err = _resolve_tool_index(tools, payload)
        if err:
            return err
        t_dict = _tool_dict(tools[tool_idx])

        if "number" in payload:
            num = int(payload["number"])
            # Fusion's own key is "post-process"; keep a legacy "postProcess" in step only if the tool has one.
            for key in ("post-process", "postProcess"):
                if isinstance(t_dict.get(key), dict):
                    t_dict[key]["number"] = num
            if not isinstance(t_dict.get("post-process"), dict) and not isinstance(t_dict.get("postProcess"), dict):
                t_dict["post-process"] = {"number": num}

        if "description" in payload:
            t_dict["description"] = str(payload["description"]).strip()

        if "custom_aggressiveness" in payload:
            val = payload["custom_aggressiveness"]
            if val is None or val == "" or str(val).lower() == "default":
                t_dict.pop("custom_aggressiveness", None)
            else:
                t_dict["custom_aggressiveness"] = float(val)

        if "stickout" in payload and payload["stickout"] is not None:
            so = float(payload["stickout"])
            if so <= 0:
                return jsonify({"success": False, "error": "stickout must be positive (inches)."}), 400
            t_dict["stickout"] = so

        tools[tool_idx] = t_dict
        library_data["tools"] = tools
        bm.save_working_library(library_data, library_data.get("library_name", "Modified_Library"))

        return jsonify({"success": True, "tool_index": tool_idx, "tool_guid": t_dict.get("guid", "")})
    except Exception as e:
        return _api_error(e)

@app.route("/api/twin/delete_tool", methods=["POST"])
def twin_delete_tool():
    """Safely deletes a tool from the working library and creates a backup snapshot.

    Address the tool with ``tool_guid`` (stable) or the legacy ``tool_index``."""
    try:
        payload = _json_body()
        library_data = bm.load_working_library()
        if not library_data or "tools" not in library_data:
            return jsonify({"success": False, "error": "No working library loaded."}), 400
        tools = library_data["tools"]
        tool_idx, err = _resolve_tool_index(tools, payload)
        if err:
            return err

        deleted_tool = _tool_dict(tools.pop(tool_idx))
        library_data["tools"] = tools
        backup_info = bm.save_working_library(library_data, library_data.get("library_name", "Modified_Library"))

        return jsonify({
            "success": True,
            "deleted_guid": deleted_tool.get("guid", ""),
            "remaining_tools": len(tools),
            "backup": backup_info
        })
    except Exception as e:
        return _api_error(e)

@app.route("/api/twin/delete_preset", methods=["POST"])
def twin_delete_preset():
    """Deletes one preset of a tool. Address the tool with ``tool_guid`` or ``tool_index`` and the preset with
    ``preset_guid`` (non-empty). 404 when the tool or preset is not there."""
    try:
        payload = _json_body()
        preset_guid = payload.get("preset_guid")
        if not preset_guid:
            return jsonify({"success": False, "error": "preset_guid is required."}), 400

        library_data = bm.load_working_library()
        if not library_data or "tools" not in library_data:
            return jsonify({"success": False, "error": "No working library found."}), 404
        tools = library_data["tools"]
        tool_idx, err = _resolve_tool_index(tools, payload)
        if err:
            return err
        t_dict = _tool_dict(tools[tool_idx])

        presets = (t_dict.get("start-values") or {}).get("presets") or []
        kept = [p for p in presets if p.get("guid") != preset_guid]
        if len(kept) == len(presets):
            return jsonify({"success": False, "error": "Preset not found."}), 404
        t_dict["start-values"]["presets"] = kept
        tools[tool_idx] = t_dict

        library_data["tools"] = tools
        bm.save_working_library(library_data, library_data.get("library_name", "Modified_Library"))

        return jsonify({"success": True, "removed": len(presets) - len(kept)})

    except Exception as e:
        return _api_error(e)

@app.route("/api/twin/batch_generate", methods=["POST"])
def twin_batch_generate():
    """
    Batch calculates and injects multi-operation presets into selected tools.
    Supports per-tool aggressiveness overrides, clean replacement of prior presets,
    and automatic springback & wear compensation calculations.
    """
    try:
        req_data = _json_body()
        tool_indices = req_data.get("tool_indices", []) # list of integer indices or "all"
        family = req_data.get("family", "Steel - Tool (H13)")
        alloy = req_data.get("alloy", "CPM MagnaCut (Hardened ~62 HRC)")
        strategies = req_data.get("strategies", ["Adaptive Roughing", "Roughing", "Finishing", "Slotting"])
        
        base_aggressiveness = float(req_data.get("aggressiveness", req_data.get("base_aggressiveness", 50.0)))
        use_tool_overrides = bool(req_data.get("use_tool_overrides", True))
        tool_aggr_map = req_data.get("tool_aggressiveness_map", {}) # {tool_index_str: aggr_val}
        
        clean_existing_for_material = bool(req_data.get("clean_existing_for_material", True))
        clean_all_non_toolwiz = bool(req_data.get("clean_all_non_toolwiz", False))
        
        coating = req_data.get("coating", "AlTiN")
        max_rpm = float(req_data.get("maxRpm") or machine_limits()["max_rpm"])
        max_hp = float(req_data.get("maxHp") or machine_limits()["max_hp"])
        runout = _runout_arg(req_data)
        
        library_data = bm.load_working_library()
        if not library_data or "tools" not in library_data:
            return jsonify({"success": False, "error": "No working library found to modify."}), 400
            
        tools = library_data["tools"]
        guid_list = req_data.get("tool_guids")
        if guid_list is not None:
            if not isinstance(guid_list, list):
                return jsonify({"success": False, "error": "tool_guids must be a list"}), 400
            wanted = {str(g) for g in guid_list}
            indices_to_update = [i for i, t in enumerate(tools) if str(_tool_dict(t).get("guid", "")) in wanted]
        elif tool_indices == "all":
            indices_to_update = list(range(len(tools)))
        else:
            indices_to_update = [int(i) for i in tool_indices]

        custom_preset_name = req_data.get("custom_preset_name", "").strip()
        material_label = alloy if alloy else family
        material = {"label": material_label, "family": family, "alloy": alloy}
        model = _request_model(req_data)
        profile = active_machine()

        updated_tools_count = 0
        total_presets_injected = 0
        skipped = []

        for idx in indices_to_update:
            if idx < 0 or idx >= len(tools):
                continue
            t_dict = copy.deepcopy(_tool_dict(tools[idx]))
            tool_number = (t_dict.get("postProcess") or t_dict.get("post-process") or {}).get("number")

            def _skip(reason, strategy=None, idx=idx, t_dict=t_dict, tool_number=tool_number):
                row = {"tool_index": idx, "number": tool_number, "description": t_dict.get("description", ""),
                       "type": t_dict.get("type", ""), "reason": reason}
                if strategy:
                    row["strategy"] = strategy
                skipped.append(row)

            # Per-tool aggressiveness: an explicit override in tool_aggressiveness_map (keyed by tool guid or
            # index) is stored on the tool; then the tool's own override wins over the request's value.
            for key in (str(t_dict.get("guid", "")), str(idx)):
                if key and key in tool_aggr_map:
                    override_val = tool_aggr_map[key]
                    if override_val is not None and str(override_val).lower() != "default":
                        t_dict["custom_aggressiveness"] = float(override_val)
                    else:
                        t_dict.pop("custom_aggressiveness", None)
                    break
            aggressiveness = effective_aggressiveness(
                t_dict, req_data.get("aggressiveness", req_data.get("base_aggressiveness", 50.0)),
                use_tool_overrides)

            new_presets, gen_skipped = generate_presets(
                t_dict, [material], list(strategies), aggressiveness, physics=physics, max_rpm=max_rpm,
                max_hp=max_hp, runout=runout, model=model, machine_profile=profile, coating=coating,
                name_prefix=custom_preset_name or None)
            for sk in gen_skipped:
                _skip(sk["reason"], sk.get("strategy"))
            if any(sk.get("fatal") for sk in gen_skipped):
                continue    # not a cutting tool / unreadable geometry: leave the tool untouched

            if clean_existing_for_material or clean_all_non_toolwiz:
                target_mat = material_label if clean_existing_for_material else None
                t_dict, _ = clean_tool_presets(t_dict, clean_all_non_toolwiz=clean_all_non_toolwiz,
                                               target_material_to_replace=target_mat)
            presets_list = t_dict.setdefault("start-values", {}).setdefault("presets", [])
            for preset_dict in new_presets:
                tag = preset_dict.get("toolwiz") or {}

                def owned_by_toolwiz(p):
                    return is_toolwiz_preset(p) or bool(p.get("operation_type"))
                # Replace what ToolWiz wrote earlier for this material and strategy (tagged), or a same-named
                # older ToolWiz-shaped preset; the owner's own preset of that name is kept and ours renamed.
                same = next((i for i, p in enumerate(presets_list)
                             if is_toolwiz_preset(p) and p["toolwiz"].get("material") == tag.get("material")
                             and p["toolwiz"].get("strategy") == tag.get("strategy")), None)
                if same is None:
                    same = next((i for i, p in enumerate(presets_list)
                                 if p.get("name") == preset_dict["name"] and owned_by_toolwiz(p)), None)
                if same is not None:
                    preset_dict["guid"] = presets_list[same].get("guid", preset_dict["guid"])
                    preset_dict["name"] = presets_list[same].get("name", preset_dict["name"])   # keeps a " (ToolWiz)" rename
                    presets_list[same] = preset_dict       # whole preset: stale "expressions" would override the numbers
                else:
                    taken = {str(p.get("name", "")).lower() for p in presets_list}
                    if preset_dict["name"].lower() in taken:
                        n = 1
                        while True:
                            cand = f"{preset_dict['name']} (ToolWiz{'' if n == 1 else ' ' + str(n)})"
                            if cand.lower() not in taken:
                                break
                            n += 1
                        preset_dict["name"] = cand
                    presets_list.append(preset_dict)
                total_presets_injected += 1

            tools[idx] = t_dict
            if new_presets:
                updated_tools_count += 1

        seen_guids = set()
        for i, t in enumerate(tools):
            if isinstance(t, str):
                t = json.loads(t)
            g = t.get("guid", "")
            if g in seen_guids or not g:
                t["guid"] = str(uuid.uuid4())
            seen_guids.add(t["guid"])
            tools[i] = t
            
        library_data["tools"] = tools
        lib_name = library_data.get("library_name", "Master_Shop_Tool_Crib")
        backup_info = bm.save_working_library(library_data, lib_name)
        
        return jsonify({
            "success": True,
            "updated_tools_count": updated_tools_count,
            "total_presets_injected": total_presets_injected,
            "skipped": skipped,
            "backup": backup_info
        })
        
    except Exception as e:
        return _api_error(e)

@app.route("/api/twin/get_import_payload", methods=["GET"])
def twin_get_import_payload():
    """Serves the latest Digital Twin JSON payload for the Fusion Add-in to re-import"""
    try:
        data = bm.load_working_library()
        if not data:
            return jsonify({"success": False, "error": "No working library found."}), 404
        return jsonify({"success": True, "library": data})
    except Exception as e:
        return _api_error(e)

@app.route("/api/twin/upload", methods=["POST"])
def twin_upload():
    """
    Handles manual drag-and-drop file uploads.
    Supports single or MULTIPLE .tools or .json files simultaneously, with
    automatic library merging and deduplication.
    """
    try:
        uploaded_files = request.files.getlist('files') + request.files.getlist('file')
            
        if not uploaded_files or uploaded_files[0].filename == '':
            return jsonify({"success": False, "error": "No file uploaded"}), 400

        merge_mode = request.form.get("merge_mode", "merge")
        parsed_libraries = []

        for file in uploaded_files:
            filename = file.filename.lower()
            library_data = None

            if filename.endswith('.json'):
                content = file.read().decode('utf-8')
                library_data = json.loads(content)
            elif filename.endswith('.tools'):
                with zipfile.ZipFile(file, 'r') as z:
                    json_files = [n for n in z.namelist() if n.endswith('.json')]
                    if json_files:
                        with z.open(json_files[0]) as f:
                            library_data = json.loads(f.read().decode('utf-8'))
            
            if not library_data:
                continue

            tools_list = []
            if isinstance(library_data, dict) and "data" in library_data:
                tools_list = library_data["data"]
            elif isinstance(library_data, list):
                tools_list = library_data
            elif isinstance(library_data, dict) and "tools" in library_data:
                tools_list = library_data["tools"]

            lib_name = file.filename.replace('.json', '').replace('.tools', '')
            parsed_libraries.append({
                "library_name": lib_name,
                "tools": tools_list
            })

        if not parsed_libraries:
            return jsonify({"success": False, "error": "No valid tool libraries could be parsed."}), 400

        if merge_mode == "append":
            current_data = bm.load_working_library()
            if current_data and current_data.get("tools"):
                parsed_libraries.insert(0, {
                    "library_name": current_data.get("library_name", "Current_Master_Library"),
                    "tools": current_data["tools"]
                })

        master_lib_name = "Master_Shop_Tool_Crib" if len(parsed_libraries) > 1 else parsed_libraries[0]["library_name"]
        auto_dedup = merge_mode == "merge_deduplicate"
        merged_library, summary = merge_multiple_libraries(parsed_libraries, master_library_name=master_lib_name, deduplicate=auto_dedup)

        merged_library["tools"] = _ensure_unique_guids(merged_library.get("tools", []))
        backup_info = bm.save_working_library(merged_library, master_lib_name)

        return jsonify({
            "success": True,
            "library_name": master_lib_name,
            "tool_count": len(merged_library.get("tools", [])),
            "files_processed": len(parsed_libraries),
            "summary": summary,
            "backup": backup_info
        })
        
    except Exception as e:
        return _api_error(e)

@app.route("/api/twin/download", methods=["GET"])
def twin_download():
    """Provides the active Digital Twin library as a downloadable .json file formatted for Fusion 360"""
    try:
        data = bm.load_working_library()
        if not data:
            return "No active library found", 404
            
        fusion_format = {
            "data": data.get("tools", [])
        }
        
        json_str = json.dumps(fusion_format, indent=2)
        lib_name = data.get("library_name", "ToolWiz_Master_Crib")
        
        mem_file = io.BytesIO()
        mem_file.write(json_str.encode('utf-8'))
        mem_file.seek(0)
        
        return send_file(
            mem_file,
            mimetype='application/json',
            as_attachment=True,
            download_name=f"{lib_name}.json"
        )
    except Exception as e:
        app.logger.error("Library download failed", exc_info=e)
        return "Internal server error", 500

@app.route("/api/ai_chat", methods=["POST"])
def ai_chat():
    """Handles conversational AI Machinist inquiries with live ToolWiz telemetry"""
    try:
        data = _json_body()
        message = data.get("message", "").strip()
        if not message:
            return jsonify({"success": False, "error": "Message is required"}), 400
            
        context = data.get("context", {})
        api_key = data.get("apiKey", "").strip() or None
        preferred_model = data.get("model", "").strip() or None
        
        result = query_ai_machinist(message, context=context, api_key=api_key, preferred_model=preferred_model)
        return jsonify(result)
    except Exception as e:
        return _api_error(e)

@app.route("/api/ai_models", methods=["GET", "POST"])
def ai_models():
    """Returns the list of available Gemini models for the configured or provided API key"""
    try:
        data = _json_body()
        api_key = (
            request.headers.get("x-goog-api-key")
            or request.headers.get("x-api-key")
            or data.get("apiKey")
            or os.environ.get("GEMINI_API_KEY")
            or os.environ.get("GOOGLE_API_KEY")
            or ""
        )
        if not api_key:
            return jsonify({
                "success": True,
                "models": [
                    {"id": "auto", "name": "⚡ Auto-Detect Best (Recommended)"},
                    {"id": "gemini-2.5-pro", "name": "Gemini 2.5 Pro (Deep CAM Reasoning)"},
                    {"id": "gemini-2.5-flash", "name": "Gemini 2.5 Flash (Fast)"}
                ]
            })
            
        models, err = get_available_gemini_models(api_key)
        if err and "Authentication Error" in err:
            return jsonify({"success": False, "error": err}), 400
            
        result_list = [{"id": "auto", "name": "⚡ Auto-Detect Best (Recommended)"}]
        for m in (models or ["gemini-2.5-pro", "gemini-2.5-flash", "gemini-2.0-flash"]):
            clean = m.replace("models/", "").replace("gemini-", "").strip()
            parts = clean.split("-")
            words = [p.capitalize() if not (p.replace(".", "").isdigit()) else p for p in parts if p]
            friendly_name = " ".join(words)
            if not friendly_name.lower().startswith("gemini"):
                friendly_name = f"Gemini {friendly_name}"

            if "pro" in m.lower():
                label = f"{friendly_name} (Deep CAM Reasoning)"
            elif "flash" in m.lower():
                label = f"{friendly_name} (Fast)"
            else:
                label = friendly_name
            result_list.append({"id": m, "name": label})
            
        return jsonify({"success": True, "models": result_list})
    except Exception as e:
        return _api_error(e)

def clean_and_eval_stock_expr(expr_str, doc_unit="in"):
    """Evaluates dimension expressions like '(-.1) * 1mm', '(.1)*1mm', or '0mm'
    into clean, formatted numeric strings like '-0.100 mm' or '0.000 mm'.
    Uses safe AST parser without eval().
    """
    if expr_str is None or str(expr_str).strip() == "":
        return "0.000 mm" if doc_unit == "mm" else "0.0000 in"
    s = str(expr_str).strip()
    
    unit = doc_unit
    s_lower = s.lower()
    if "mm" in s_lower or "milli" in s_lower:
        unit = "mm"
    elif "in" in s_lower or '"' in s:
        unit = "in"
        
    try:
        math_str = re.sub(r'([0-9\.\)])\s*(?:mm|millimeter|millimetre|inches|inch|in|\")', r'\1 * 1.0', s, flags=re.I)
        math_str = re.sub(r'(?:mm|millimeter|millimetre|inches|inch|in|\")', r' 1.0 ', math_str, flags=re.I)
        if re.match(r'^[0-9\.\+\-\*\/\(\)\s]+$', math_str):
            val = float(safe_eval_length(math_str))
            if abs(val) < 1e-6:
                val = 0.0
            if unit == "mm":
                return f"{val:.3f} mm"
            else:
                return f"{val:.4f} in"
    except Exception:
        pass
    return s

def _stock_strength(pct):
    """User strength setting (percent, 25/50/75/100 in the add-in) as a 0..1 scale; bad input -> 1.0."""
    try:
        v = float(pct)
    except (TypeError, ValueError):
        return 1.0
    return max(0.0, min(1.0, v / 100.0))


def is_hole_op(name, strategy=""):
    """Operation that machines a hole (by name or strategy), where radial stock counts twice on diameter."""
    text = f"{name} {strategy}".lower()
    return any(k in text for k in ("bore", "hole", "circular", "helical"))


@app.route("/api/stock_compensation", methods=["POST"])
def stock_compensation():
    """Calculates tool deflection, material springback, and recommended radial/axial stock to leave
    for a batch of Fusion 360 CAM operations.
    """
    try:
        data = _json_body()
        family = data.get("family", "Aluminum - Wrought (6061)")
        alloy = data.get("alloy", "")
        comp_adjust_raw = data.get("comp_adjust_pct")
        if comp_adjust_raw is not None:
            comp_adjust_pct = max(-25.0, min(25.0, float(comp_adjust_raw)))
            comp_scalar = 1.0 + (comp_adjust_pct / 100.0)
        else:
            agg_raw = data.get("aggressiveness", 50)
            aggressiveness = float(agg_raw) / 100.0 if (float(agg_raw) > 1.0 or agg_raw == 1) else float(agg_raw)
            comp_scalar = 0.75 + (max(0.0, min(1.0, aggressiveness)) * 0.50)
            comp_adjust_pct = round((comp_scalar - 1.0) * 100.0, 1)
        mode = data.get("mode", "auto_compensate")  # auto_compensate, zero_finishing, custom
        custom_radial_offset = str(data.get("custom_radial_offset", "0.0000 in")).strip()
        custom_axial_offset = str(data.get("custom_axial_offset", "0.0000 in")).strip()
        operations = data.get("operations", [])
        radial_scale = _stock_strength(data.get("radial_pct", 100))
        axial_scale = _stock_strength(data.get("axial_pct", 100))
        
        results = []
        for op in operations:
            op_id = op.get("id", "")
            op_name = op.get("name", "Unknown Op")
            strat = op.get("strategy", "").lower()
            unit = str(op.get("unit", "")).lower()
            raw_rad = str(op.get("current_radial_stock", "")).strip()
            raw_ax = str(op.get("current_axial_stock", "")).strip()
            is_metric = "mm" in unit or "milli" in unit or "mm" in raw_rad.lower() or "mm" in raw_ax.lower()
            doc_unit = "mm" if is_metric else "in"
            
            # Explicit, deterministic units. Defaults: lengths in inches, feed in IPM.
            length_unit = str(op.get("length_unit", "in")).strip().lower()
            feed_unit = str(op.get("feed_unit", "ipm")).strip().lower()
            if length_unit in ("in", "inch", "inches"):
                len_factor = 1.0
            elif length_unit in ("mm", "millimeter", "millimeters"):
                len_factor = 1.0 / 25.4
            else:
                return jsonify({"success": False, "error": f"Operation {op_id!r}: invalid length_unit {length_unit!r} (use 'in' or 'mm')"}), 400
            if feed_unit in ("ipm", "in/min", "in_min"):
                feed_factor = 1.0
            elif feed_unit in ("mm_min", "mm/min", "mmpm"):
                feed_factor = 1.0 / 25.4
            else:
                return jsonify({"success": False, "error": f"Operation {op_id!r}: invalid feed_unit {feed_unit!r} (use 'ipm' or 'mm_min')"}), 400

            def _len_in(key, default_in):
                raw_v = op.get(key)
                return default_in if raw_v is None else float(raw_v) * len_factor

            # Geometry and cut parameters, converted to inches / IPM
            diameter = _len_in("diameter", 0.375)
            flutes = max(int(op.get("flutes", 4)), 1)
            flute_len = _len_in("fluteLength", diameter * 2.0)
            shank_dia = _len_in("shankDiameter", diameter)
            stickout = _len_in("stickout", 0.0)
            if stickout <= 0:
                stickout = default_stickout(diameter, flute_len)
            coating = op.get("coating", "Uncoated")
            geometry = op.get("geometry", "Square")

            # Fusion's own tool fields, when sent, replace the hand-mapped geometry above.
            op_fusion = _fusion_tool_arg(op)
            op_profile = None
            if op_fusion is not None:
                explicit_stick = _len_in("stickout", 0.0)
                op_profile = ToolProfile.from_fusion(op_fusion, stickout_override=explicit_stick if explicit_stick > 0 else None)
                pg = op_profile.geometry
                diameter, flutes, flute_len = pg.diameter, pg.flutes, pg.flute_length
                shank_dia, stickout = pg.shank_diameter, op_profile.stickout

            rpm = float(op.get("rpm", 0.0))
            feedrate_ipm = float(op.get("feedrate", 0.0)) * feed_factor
            doc_in = _len_in("doc", 0.0)
            woc_in = _len_in("woc", 0.0)

            zero_rad_str = "0.000 mm" if is_metric else "0.0000 in"
            zero_ax_str = "0.000 mm" if is_metric else "0.0000 in"
            default_rough_rad = "0.500 mm" if is_metric else "0.0200 in"
            default_rough_ax = "0.250 mm" if is_metric else "0.0100 in"
            
            current_radial = clean_and_eval_stock_expr(raw_rad, doc_unit) if raw_rad else default_rough_rad
            current_axial = clean_and_eval_stock_expr(raw_ax, doc_unit) if raw_ax else default_rough_ax
            
            # Identify if Finishing vs Roughing, and Floor vs Wall
            strat_lower = strat.lower()
            name_lower = op_name.lower()
            
            is_floor_finish = any(s in strat_lower for s in ["flat", "face", "horizontal", "facing", "floor"])
            is_wall_finish = any(s in strat_lower for s in [
                "contour", "scallop", "pencil", "parallel", "morf", "ramp", "flow", "spiral", "finish", "swarf", "3d"
            ])
            is_rough_strat = any(s in strat_lower for s in [
                "adaptive", "pocket", "rough", "clearing", "cavity", "rest"
            ])
            
            if is_floor_finish or is_wall_finish:
                is_finishing = True
            elif is_rough_strat:
                is_finishing = False
                is_floor_finish = False
                is_wall_finish = False
            else:
                # Strategy unrecognized; inspect operation name
                if any(s in name_lower for s in ["rough", "adaptive", "clearing"]):
                    is_finishing = False
                    is_floor_finish = False
                    is_wall_finish = False
                elif any(s in name_lower for s in ["flat", "horizontal", "face", "facing", "floor", "skim"]):
                    is_finishing = True
                    is_floor_finish = True
                    is_wall_finish = False
                elif any(s in name_lower for s in ["finish", "contour", "wall", "scallop", "3d"]):
                    is_finishing = True
                    is_floor_finish = False
                    is_wall_finish = True
                else:
                    is_finishing = False
                
            # If doc/woc or feeds/speeds are missing, use standard finishing or roughing defaults
            if is_finishing:
                if is_floor_finish:
                    if doc_in <= 0:
                        doc_in = max(0.005, min(0.015, diameter * 0.05))
                    if woc_in <= 0:
                        woc_in = diameter * 0.65  # 65% stepover for floor/face
                elif any(s in strat_lower for s in ["3d", "scallop", "parallel"]) or any(s in name_lower for s in ["3d", "scallop"]):
                    if doc_in <= 0:
                        doc_in = min(0.015, max(0.003, diameter * 0.04))
                    if woc_in <= 0:
                        woc_in = max(0.005, min(0.040, diameter * 0.10))
                else:
                    if doc_in <= 0:
                        doc_in = flute_len * 0.75 if flute_len > 0 else diameter * 1.5
                    if woc_in <= 0:
                        woc_in = max(diameter * 0.04, 0.008)  # 4% D light finishing cut
                    woc_in = min(woc_in, max(diameter * 0.10, 0.025))
            else:
                if doc_in <= 0:
                    doc_in = diameter * 1.0
                if woc_in <= 0:
                    woc_in = diameter * 0.40  # 40% D roughing
                    
            if rpm <= 0 or feedrate_ipm <= 0:
                limits = machine_limits()
                res = run_cut(physics, CutRequest(
                    family=family, alloy=alloy, tool="Carbide Endmill", geometry=geometry,
                    operation="Finishing" if is_finishing else "Roughing", coating=coating,
                    diameter=diameter, flutes=flutes, flute_length=flute_len, shank_diameter=shank_dia,
                    stickout=stickout, is_carbide=True, aggressiveness=0.5,
                    max_rpm=limits["max_rpm"], max_hp=limits["max_hp"],
                    cut_depth=doc_in, cut_width=woc_in,
                    fusion_tool=op_fusion,
                ))
                if rpm <= 0:
                    rpm = res.rpm
                if feedrate_ipm <= 0:
                    feedrate_ipm = physics.calc_feedrate(rpm, flutes, res.adj_ipt)
                    
            defl = physics.tool_deflection(
                diameter=diameter, shank_size=shank_dia, stickout=stickout, cut_depth=doc_in, cut_width=woc_in,
                feedrate=feedrate_ipm, rpm=rpm, flutes=flutes, is_carbide=True, material_family=family,
                flute_length=flute_len, operation="Finishing" if is_finishing else "Roughing",
                profile=op_profile
            )
            sb, total_err, wear_comp = physics.calc_springback_and_deflection(
                material_family=family, diameter=diameter, cut_depth=doc_in, cut_width=woc_in,
                feedrate=feedrate_ipm, rpm=rpm, flutes=flutes, deflection_inches=defl, alloy=alloy
            )
            
            # Compensation trim around populated speeds/feeds baseline (0% = 1.00x Recommended, -25%..+25% = 0.75x..1.25x)
            defl *= comp_scalar
            sb *= comp_scalar
            # Learned correction from logged real cuts for this material (no-op below 3 samples).
            corrected, calib = cutlog.apply_calibration(family, defl + sb)
            if calib.get("applied") and (defl + sb) > 0:
                scale = corrected / (defl + sb)
                defl *= scale
                sb *= scale
            op_fg = dict(op.get("feature_geometry") or {}) if isinstance(op.get("feature_geometry"), dict) else {}
            wt_in = op_fg.get("min_wall_thickness_in")
            ft_in = op_fg.get("min_floor_thickness_in")
            wh_in = op_fg.get("wall_height_in")
            is_tw, is_tf, wp_comp = calc_thin_wall_compliance_factor(
                float(wt_in) if (wt_in is not None and float(wt_in) > 0) else None,
                float(wh_in) if (wh_in is not None and float(wh_in) > 0) else None,
                float(ft_in) if (ft_in is not None and float(ft_in) > 0) else None,
            )
            if wp_comp > 1.0:
                sb *= wp_comp
                op_fg["is_thin_wall"] = bool(is_tw)
                op_fg["is_thin_floor"] = bool(is_tf)
                op_fg["workpiece_compliance_factor"] = round(wp_comp, 3)
            total_err = defl + sb
            wear_comp = -total_err
            
            if mode == "zero_finishing":
                if is_finishing:
                    rec_rad = zero_rad_str
                    rec_ax = zero_ax_str
                    advisory = "Finishing Pass\nZero Stock (0.0000)"
                else:
                    rec_rad = current_radial
                    rec_ax = current_axial
                    advisory = f"Roughing Pass\nRetaining stock ({rec_rad})"
            elif mode == "custom":
                rec_rad = clean_and_eval_stock_expr(custom_radial_offset, doc_unit) if custom_radial_offset else zero_rad_str
                rec_ax = clean_and_eval_stock_expr(custom_axial_offset, doc_unit) if custom_axial_offset else zero_ax_str
                advisory = f"Custom Batch\nRad: {rec_rad} | Ax: {rec_ax}"
            else:  # auto_compensate
                if is_finishing:
                    # Maximum safe negative radial/axial stock compensation ceiling for finishing passes
                    # Precision finish cuts should never exceed 0.0025" (0.065 mm) or 2.5% of tool diameter
                    # to prevent any risk of part gouging or scrap.
                    max_safe_comp_in = min(0.0025, max(0.0008, diameter * 0.025))
                    # The user's strength setting (25-100%) scales the predicted compensation.
                    rad_in = -min(total_err, max_safe_comp_in) * radial_scale
                    ax_in = -min(sb, max_safe_comp_in) * axial_scale
                    if is_metric:
                        rec_rad, rec_ax = f"{rad_in * 25.4:.3f} mm", f"{ax_in * 25.4:.3f} mm"
                    else:
                        rec_rad, rec_ax = f"{rad_in:.4f} in", f"{ax_in:.4f} in"
                    if is_floor_finish:
                        tip = "Tip: Use Rad +0.150mm if floor-only" if is_metric else "Tip: Use Rad +0.005\" if floor-only"
                        advisory = f"Floor Ax: {rec_ax} | Comb Rad: {rec_rad}\n{tip}"
                    else:  # Wall finishing / lateral contour
                        keep = "Keep Ax: 0.000 if floor pre-cut" if is_metric else "Keep Ax: 0.000\" if floor pre-cut"
                        advisory = f"Wall Rad: {rec_rad} | Floor Ax: {rec_ax}\n{keep}"
                    if is_hole_op(op_name, strat):
                        advisory += "\nHole: radial stock acts on both sides (diameter changes 2x)"
                    if is_tw and wt_in is not None:
                        w_lbl = f"{float(wt_in) * 25.4:.2f} mm" if is_metric else f"{float(wt_in):.4f}\""
                        advisory += f"\nThin Wall ({w_lbl}): x{wp_comp:.2f} push-off comp; use spring pass"
                    elif is_tf and ft_in is not None:
                        f_lbl = f"{float(ft_in) * 25.4:.2f} mm" if is_metric else f"{float(ft_in):.4f}\""
                        advisory += f"\nThin Floor ({f_lbl}): x{wp_comp:.2f} floor springback comp"
                else:
                    rec_rad = current_radial
                    rec_ax = current_axial
                    advisory = f"Roughing Pass\nRetaining stock ({rec_rad})"

            results.append({
                "id": op_id,
                "name": op_name,
                "strategy": strat,
                "is_finishing": is_finishing,
                "is_floor_finish": is_floor_finish,
                "is_wall_finish": is_wall_finish,
                "deflection_in": round(defl, 6),
                "springback_in": round(sb, 6),
                "total_error_in": round(total_err, 6),
                "wear_comp_offset_in": round(wear_comp, 6),
                "doc_in": round(doc_in, 5),
                "woc_in": round(woc_in, 5),
                "radial_scale": radial_scale,
                "axial_scale": axial_scale,
                "recommended_radial_stock": rec_rad,
                "recommended_axial_stock": rec_ax,
                "advisory": advisory,
                "calibration": calib,
                **({"profile": op_profile.to_dict()} if op_profile is not None else {}),
                **({"feature_geometry": op_fg} if op_fg else {}),
            })
            
        return jsonify({
            "success": True,
            "family": family,
            "alloy": alloy,
            "results": results
        })
    except Exception as e:
        return _api_error(e)

@app.route("/api/oversight_review", methods=["POST"])
def api_oversight_review():
    """Holistic shop-floor oversight review outside single-operation physics equations."""
    try:
        from oversight_engine import evaluate_holistic_oversight
        body = _json_body()
        cut_req = body.get("cut_request") or body
        cut_res = body.get("cut_result")
        if not isinstance(cut_res, dict) or not cut_res:
            fusion_tool = _fusion_tool_arg(cut_req)
            dia = float(cut_req.get("diameter", 0.25))
            req = CutRequest(
                family=cut_req.get("family", ""),
                alloy=cut_req.get("alloy", ""),
                tool=cut_req.get("tool", "Carbide Endmill"),
                coating=cut_req.get("coating", "Uncoated"),
                geometry=cut_req.get("geometry", "Square"),
                operation=cut_req.get("operation", "Roughing"),
                diameter=dia,
                flutes=int(cut_req.get("flutes", 4)),
                flute_length=float(cut_req.get("fluteLength") or (dia * 3.0)),
                shank_diameter=float(cut_req.get("shankDiameter") or default_shank(dia)),
                stickout=float(cut_req.get("stickout")) if cut_req.get("stickout") else None,
                cut_depth=float(cut_req["cutDepth"]) if cut_req.get("cutDepth") is not None else None,
                cut_width=float(cut_req["cutWidth"]) if cut_req.get("cutWidth") is not None else None,
                aggressiveness=float(cut_req.get("aggressiveness", 50.0)) / 100.0,
                fusion_tool=fusion_tool,
                model=cut_req.get("model"),
                machine_profile=active_machine(),
                feature_geometry=cut_req.get("feature_geometry") if isinstance(cut_req.get("feature_geometry"), dict) else None,
            )
            r = run_cut(physics, req)
            cut_res = {
                "diameter": r.diameter, "flute_length": r.flute_length, "shank_diameter": r.shank_diameter,
                "doc": r.doc, "woc": r.woc, "rpm": r.rpm, "feed_ipm": r.feed_ipm,
                "adj_ipt": r.adj_ipt, "deflection": r.deflection, "rec_limit": r.rec_limit,
                "feasible": r.feasible, "profile": r.profile, "v1": r.v1, "v2": r.v2,
                "feature_geometry": r.feature_geometry,
            }
        report = evaluate_holistic_oversight(
            cut_request=cut_req,
            cut_result=cut_res,
            feature_geometry=body.get("feature_geometry") or cut_res.get("feature_geometry"),
            setup_audit=body.get("setup_audit"),
            include_ai_opinion=bool(body.get("include_ai_opinion", False)),
        )
        return jsonify({"success": True, **report.to_dict()})
    except Exception as e:
        return _api_error(e)


@app.route("/api/library/curate", methods=["POST"])
def api_library_curate():
    """Inspect and auto-curate a Fusion 360 tool library (or the working library), populating missing
    shaft tapers (0.5 mm holder margin), fixing micro-tool shanks, and inferring metadata."""
    try:
        from tool_library_curator import curate_tool_library
        body = _json_body()
        use_working = bool(body.get("use_working_library", False))
        apply_working = bool(body.get("apply_to_working_library", False))
        lib_data = bm.load_working_library() if use_working else None
        if use_working and lib_data:
            source = lib_data
        else:
            source = body.get("tools") or body.get("library") or []

        report = curate_tool_library(
            source,
            fix_micro_shank=bool(body.get("fix_micro_shank", True)),
            populate_shaft_taper=bool(body.get("populate_shaft_taper", True)),
            infer_metadata_from_description=bool(body.get("infer_metadata_from_description", True)),
            use_ai=bool(body.get("use_ai", False)),
        )
        if use_working and apply_working and lib_data:
            lib_data["tools"] = report["curated_tools"]
            bm.save_working_library(lib_data, lib_data.get("library_name", "Curated_Library"))
            report["applied_to_working_library"] = True

        return jsonify({"success": True, **report})
    except Exception as e:
        return _api_error(e)


if __name__ == "__main__":
    debug_mode = os.environ.get("FLASK_DEBUG", "0") == "1"
    app.run(host="127.0.0.1", port=5000, debug=debug_mode)

