"""Cut log + per-material calibration for ToolWiz.

The machinist logs what actually happened on real cuts; this module learns a
per-family correction factor for the predicted wall error (deflection + springback)
and gives advisory-only aggressiveness guidance.

Wire-up (app.py):  import cutlog; cutlog.register(app)
Later use:         corrected, info = cutlog.apply_calibration(family, predicted)
"""
import math
import os
import random
import sqlite3
import statistics
import threading
from datetime import datetime, timezone

from flask import jsonify, request

DEFAULT_DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "cutlog.db")

# Calibration constants
MIN_PREDICTED = 1e-5
RATIO_MIN, RATIO_MAX = 0.05, 20.0
N_PROVISIONAL, N_CALIBRATED = 3, 10
FACTOR_CLAMP = (0.5, 2.0)
CHATTER_HIGH, LOAD_HIGH, LOAD_LOW = 0.2, 90.0, 60.0
BOOTSTRAP_ITERS = 1000

_configured_db_path = None
_initialized = set()
_init_lock = threading.Lock()

_SCHEMA = """
CREATE TABLE IF NOT EXISTS cutlog (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL,
    family TEXT NOT NULL,
    alloy TEXT,
    operation TEXT NOT NULL,
    tool_description TEXT,
    tool_number INTEGER,
    diameter_in REAL NOT NULL,
    flutes INTEGER NOT NULL,
    stickout_in REAL NOT NULL,
    rpm REAL NOT NULL,
    feed_ipm REAL NOT NULL,
    doc_in REAL NOT NULL,
    woc_in REAL NOT NULL,
    predicted_deflection_in REAL NOT NULL,
    predicted_springback_in REAL NOT NULL,
    predicted_total_error_in REAL NOT NULL,
    measured_wall_error_in REAL,
    spindle_load_pct REAL,
    chatter INTEGER,
    surface_ok INTEGER,
    notes TEXT,
    source TEXT NOT NULL DEFAULT 'web'
);
CREATE INDEX IF NOT EXISTS idx_cutlog_family ON cutlog (family COLLATE NOCASE, id);
"""

_COLUMNS = [
    "id", "created_at", "family", "alloy", "operation", "tool_description", "tool_number",
    "diameter_in", "flutes", "stickout_in", "rpm", "feed_ipm", "doc_in", "woc_in",
    "predicted_deflection_in", "predicted_springback_in", "predicted_total_error_in",
    "measured_wall_error_in", "spindle_load_pct", "chatter", "surface_ok", "notes", "source",
]


# --------------------------------------------------------------------------
# Database helpers
# --------------------------------------------------------------------------

def _resolve_path(db_path=None):
    return db_path or _configured_db_path or DEFAULT_DB_PATH


def _connect(db_path=None):
    path = _resolve_path(db_path)
    if path not in _initialized:
        with _init_lock:
            if path not in _initialized:
                os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
                conn = sqlite3.connect(path)
                try:
                    conn.executescript(_SCHEMA)
                    conn.commit()
                finally:
                    conn.close()
                _initialized.add(path)
    conn = sqlite3.connect(path, timeout=10)
    conn.row_factory = sqlite3.Row
    return conn


def _row_to_dict(row):
    d = {k: row[k] for k in _COLUMNS}
    for k in ("chatter", "surface_ok"):
        if d[k] is not None:
            d[k] = bool(d[k])
    return d


def fetch_rows(family=None, limit=None, db_path=None):
    """Newest-first rows as dicts, optionally filtered by family (case-insensitive)."""
    sql = "SELECT * FROM cutlog"
    args = []
    if family:
        sql += " WHERE family = ? COLLATE NOCASE"
        args.append(family)
    sql += " ORDER BY id DESC"
    if limit:
        sql += " LIMIT ?"
        args.append(int(limit))
    conn = _connect(db_path)
    try:
        return [_row_to_dict(r) for r in conn.execute(sql, args).fetchall()]
    finally:
        conn.close()


# --------------------------------------------------------------------------
# Validation
# --------------------------------------------------------------------------

class ValidationError(ValueError):
    pass


def _num(data, key, lo, hi, *, lo_exclusive=False, required=True):
    v = data.get(key)
    if v is None:
        if required:
            raise ValidationError(f"{key} is required")
        return None
    if isinstance(v, bool) or not isinstance(v, (int, float)):
        raise ValidationError(f"{key} must be a number")
    v = float(v)
    if not math.isfinite(v):
        raise ValidationError(f"{key} must be finite")
    if (v <= lo) if lo_exclusive else (v < lo):
        raise ValidationError(f"{key} must be {'>' if lo_exclusive else '>='} {lo}")
    if v > hi:
        raise ValidationError(f"{key} must be <= {hi}")
    return v


def _int(data, key, lo, hi, *, required=True):
    v = data.get(key)
    if v is None:
        if required:
            raise ValidationError(f"{key} is required")
        return None
    if isinstance(v, bool) or not isinstance(v, (int, float)):
        raise ValidationError(f"{key} must be an integer")
    if isinstance(v, float) and not (math.isfinite(v) and v.is_integer()):
        raise ValidationError(f"{key} must be an integer")
    v = int(v)
    if v < lo or v > hi:
        raise ValidationError(f"{key} must be between {lo} and {hi}")
    return v


def _str(data, key, maxlen, *, required=False):
    v = data.get(key)
    if v is None or (isinstance(v, str) and not v.strip()):
        if required:
            raise ValidationError(f"{key} is required")
        return None
    if not isinstance(v, str):
        raise ValidationError(f"{key} must be a string")
    v = v.strip()
    if len(v) > maxlen:
        raise ValidationError(f"{key} must be at most {maxlen} characters")
    return v


def _bool(data, key):
    v = data.get(key)
    if v is None:
        return None
    if not isinstance(v, bool):
        raise ValidationError(f"{key} must be true or false")
    return int(v)


def validate_cut(data):
    """Validate a POST body and return a dict of clean column values. Raises ValidationError."""
    if not isinstance(data, dict):
        raise ValidationError("JSON object body required")
    out = {
        "family": _str(data, "family", 100, required=True),
        "alloy": _str(data, "alloy", 200),
        "operation": _str(data, "operation", 100, required=True),
        "tool_description": _str(data, "tool_description", 300),
        "tool_number": _int(data, "tool_number", 0, 99999, required=False),
        "diameter_in": _num(data, "diameter_in", 0, 6, lo_exclusive=True),
        "flutes": _int(data, "flutes", 1, 100),
        "stickout_in": _num(data, "stickout_in", 0, 24, lo_exclusive=True),
        "rpm": _num(data, "rpm", 0, 60000, lo_exclusive=True),
        "feed_ipm": _num(data, "feed_ipm", 0, 5000, lo_exclusive=True),
        "doc_in": _num(data, "doc_in", 0, 6, lo_exclusive=True),
        "woc_in": _num(data, "woc_in", 0, 6, lo_exclusive=True),
        "predicted_deflection_in": _num(data, "predicted_deflection_in", 0, 1),
        "predicted_springback_in": _num(data, "predicted_springback_in", 0, 1),
        "predicted_total_error_in": _num(data, "predicted_total_error_in", 0, 1),
        "measured_wall_error_in": _num(data, "measured_wall_error_in", -1, 1, required=False),
        "spindle_load_pct": _num(data, "spindle_load_pct", 0, 200, required=False),
        "chatter": _bool(data, "chatter"),
        "surface_ok": _bool(data, "surface_ok"),
        "notes": _str(data, "notes", 2000),
    }
    source = data.get("source")
    if source is None:
        source = "web"
    if source not in ("web", "fusion"):
        raise ValidationError('source must be "web" or "fusion"')
    out["source"] = source
    return out


def insert_cut(clean, db_path=None):
    cols = list(clean.keys()) + ["created_at"]
    vals = list(clean.values()) + [datetime.now(timezone.utc).isoformat(timespec="seconds")]
    sql = f"INSERT INTO cutlog ({', '.join(cols)}) VALUES ({', '.join('?' * len(cols))})"
    conn = _connect(db_path)
    try:
        cur = conn.execute(sql, vals)
        conn.commit()
        return cur.lastrowid
    finally:
        conn.close()


def delete_cut(cut_id, db_path=None):
    conn = _connect(db_path)
    try:
        cur = conn.execute("DELETE FROM cutlog WHERE id = ?", (cut_id,))
        conn.commit()
        return cur.rowcount > 0
    finally:
        conn.close()


# --------------------------------------------------------------------------
# Calibration math (pure functions)
# --------------------------------------------------------------------------

def collect_ratios(rows):
    """Return (ratios, dropped_outliers) from rows with measured + predicted values.

    Rows lacking a measurement or with predicted <= 1e-5 are ineligible (not counted as
    dropped). Eligible rows whose ratio falls outside [0.05, 20] are dropped as outliers.
    """
    ratios, dropped = [], 0
    for r in rows:
        meas = r.get("measured_wall_error_in")
        pred = r.get("predicted_total_error_in")
        if meas is None or pred is None or pred <= MIN_PREDICTED:
            continue
        ratio = meas / pred
        if RATIO_MIN <= ratio <= RATIO_MAX:
            ratios.append(ratio)
        else:
            dropped += 1
    return ratios, dropped


def median_factor(ratios):
    return statistics.median(ratios) if ratios else None


def bootstrap_ci(ratios, iters=BOOTSTRAP_ITERS, seed=12345, alpha=0.05):
    """Deterministic (seeded) percentile-bootstrap interval for the median. None if n < 3."""
    n = len(ratios)
    if n < N_PROVISIONAL:
        return None
    rng = random.Random(seed)
    meds = sorted(statistics.median(rng.choices(ratios, k=n)) for _ in range(iters))
    lo = meds[int((alpha / 2) * (iters - 1))]
    hi = meds[int((1 - alpha / 2) * (iters - 1))]
    return [lo, hi]


def status_for(n):
    if n < N_PROVISIONAL:
        return "insufficient"
    if n < N_CALIBRATED:
        return "provisional"
    return "calibrated"


def clamp_factor(factor):
    return max(FACTOR_CLAMP[0], min(FACTOR_CLAMP[1], factor))


def chatter_rate(rows):
    vals = [r["chatter"] for r in rows if r.get("chatter") is not None]
    return (sum(1 for v in vals if v) / len(vals)) if vals else None


def mean_spindle_load(rows):
    vals = [r["spindle_load_pct"] for r in rows if r.get("spindle_load_pct") is not None]
    return (sum(vals) / len(vals)) if vals else None


MIN_OUTCOME_ROWS = 3


def suggest_aggressiveness_delta(n, chatter_rate_v, mean_load, n_outcomes=MIN_OUTCOME_ROWS):
    """Advice only (never applied automatically): -10 back off, +5 push, 0 hold.
    Needs at least MIN_OUTCOME_ROWS cuts with a chatter/load outcome before advising."""
    if n_outcomes < MIN_OUTCOME_ROWS:
        return 0
    if (chatter_rate_v is not None and chatter_rate_v > CHATTER_HIGH) or \
       (mean_load is not None and mean_load > LOAD_HIGH):
        return -10
    if (n >= N_CALIBRATED and chatter_rate_v == 0 and mean_load is not None
            and mean_load < LOAD_LOW):
        return 5
    return 0


def compute_calibration(family, rows):
    """Calibration summary for one family's rows."""
    ratios, dropped = collect_ratios(rows)
    n = len(ratios)
    status = status_for(n)
    factor = median_factor(ratios) if status != "insufficient" else None
    ci = bootstrap_ci(ratios) if status != "insufficient" else None
    cr = chatter_rate(rows)
    ml = mean_spindle_load(rows)
    return {
        "family": family,
        "n": n,
        "n_total": len(rows),
        "dropped_outliers": dropped,
        "error_factor": factor,
        "error_factor_ci": ci,
        "applied_factor": clamp_factor(factor) if factor is not None else None,
        "chatter_rate": cr,
        "mean_spindle_load": ml,
        "suggested_aggressiveness_delta": suggest_aggressiveness_delta(
            n, cr, ml,
            n_outcomes=sum(1 for r in rows
                           if r.get("chatter") is not None or r.get("spindle_load_pct") is not None)),
        "status": status,
    }


def calibration_for_family(family, db_path=None):
    return compute_calibration(family, fetch_rows(family=family, db_path=db_path))


def calibration_all(family=None, db_path=None):
    rows = fetch_rows(family=family, db_path=db_path)
    groups = {}
    for r in rows:
        groups.setdefault(r["family"].lower(), (r["family"], []))[1].append(r)
    return [compute_calibration(name, grp) for name, grp in
            sorted(groups.values(), key=lambda g: g[0].lower())]


def apply_calibration(family, predicted_total_error, db_path=None):
    """Scale a predicted wall error by the family's clamped learned factor.

    Returns (corrected, info). Unchanged (and info["applied"] False) when the family has
    fewer than 3 usable samples, or the input isn't a usable number.
    """
    info = {"family": family, "applied": False, "status": "insufficient", "n": 0,
            "factor": None, "raw_factor": None, "clamped": False}
    if (isinstance(predicted_total_error, bool)
            or not isinstance(predicted_total_error, (int, float))
            or not math.isfinite(predicted_total_error) or not family):
        return predicted_total_error, info
    cal = calibration_for_family(family, db_path=db_path)
    info["status"] = cal["status"]
    info["n"] = cal["n"]
    if cal["error_factor"] is None:
        return predicted_total_error, info
    raw = cal["error_factor"]
    factor = clamp_factor(raw)
    info.update(applied=True, factor=factor, raw_factor=raw, clamped=(factor != raw))
    return predicted_total_error * factor, info


# --------------------------------------------------------------------------
# Flask wiring
# --------------------------------------------------------------------------

def register(app, db_path=None):
    """Add the /api/cutlog and /api/calibration routes to `app`."""
    global _configured_db_path
    if db_path:
        _configured_db_path = db_path
    path = _resolve_path(db_path)
    _connect(path).close()  # create schema on first use

    def _err(msg, code=400):
        return jsonify({"success": False, "error": msg}), code

    def create_cut():
        data = request.get_json(silent=True)
        try:
            clean = validate_cut(data)
        except ValidationError as e:
            return _err(str(e))
        cut_id = insert_cut(clean, path)
        return jsonify({"success": True, "id": cut_id}), 201

    def list_cuts():
        raw = request.args.get("limit", "100")
        try:
            limit = int(raw)
        except (TypeError, ValueError):
            return _err("limit must be an integer")
        if limit < 1 or limit > 1000:
            return _err("limit must be between 1 and 1000")
        family = (request.args.get("family") or "").strip() or None
        return jsonify({"success": True, "cuts": fetch_rows(family, limit, path)})

    def remove_cut(cut_id):
        if not delete_cut(cut_id, path):
            return _err("Cut not found", 404)
        return jsonify({"success": True})

    def get_calibration():
        family = (request.args.get("family") or "").strip() or None
        return jsonify({"success": True, "calibration": calibration_all(family, path)})

    app.add_url_rule("/api/cutlog", "cutlog_create", create_cut, methods=["POST"])
    app.add_url_rule("/api/cutlog", "cutlog_list", list_cuts, methods=["GET"])
    app.add_url_rule("/api/cutlog/<int:cut_id>", "cutlog_delete", remove_cut, methods=["DELETE"])
    app.add_url_rule("/api/calibration", "cutlog_calibration", get_calibration, methods=["GET"])
