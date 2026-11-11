"""Pure helpers for the ToolWiz Fusion add-in (no `adsk` import, so they are unit-testable without Fusion).

The add-in file (ToolWizFusionAddin.py) does every Fusion call on Fusion's main thread; this module only
builds request bodies, reads server responses and formats text. Lengths are inches and feeds IPM unless a
function says otherwise (converted only when text is produced for the user, in the document's unit).
"""
import json
import math
import re

DEFAULT_RUNOUT_IN = 0.0002
MAX_RUNOUT_IN = 0.01
SEVERITIES = ("STOP", "CAUTION", "INFO")
SEV_RANK = {"STOP": 0, "CAUTION": 1, "INFO": 2}
SEV_LABEL = {"STOP": "STOP", "CAUTION": "CAUTION", "INFO": "info"}


# ==============================================================================
# small utilities
# ==============================================================================

def num(x, default=None):
    """float(x) when it is a finite number (bool excluded), else `default`."""
    if isinstance(x, bool):
        return default
    try:
        v = float(x)
    except (TypeError, ValueError):
        return default
    return v if math.isfinite(v) else default


def is_metric(unit):
    return str(unit or "").lower().startswith(("mm", "milli", "metric"))


def fmt_len(value_in, unit="in", digits=None):
    """Inches -> text in the document unit ('0.0050 in' / '0.127 mm'); '-' for None."""
    v = num(value_in)
    if v is None:
        return "-"
    if is_metric(unit):
        return f"{v * 25.4:.{3 if digits is None else digits}f} mm"
    return f"{v:.{4 if digits is None else digits}f} in"


def fmt_feed(ipm, unit="in"):
    v = num(ipm)
    if v is None:
        return "-"
    return f"{v * 25.4:.0f} mm/min" if is_metric(unit) else f"{v:.1f} IPM"


def sev_of(text):
    """Normalise a severity word to STOP / CAUTION / INFO."""
    t = str(text or "").strip().upper()
    if t in ("STOP", "CRITICAL", "ERROR"):
        return "STOP"
    if t in ("CAUTION", "WARNING", "WARN"):
        return "CAUTION"
    return "INFO"


def sort_by_severity(items, key="severity"):
    return sorted(items, key=lambda d: SEV_RANK.get(sev_of(d.get(key)), 3))


# ==============================================================================
# tool dict helpers (Fusion tool JSON)
# ==============================================================================

def tool_runout_in(tool_dict, default=DEFAULT_RUNOUT_IN):
    """(runout in inches, source) for a Fusion tool JSON dict.

    A per-tool value lives in the tool's own "toolwiz" block as `runout_in` (inches), `runout_mm`, or
    `runout` (in the tool's unit). Anything missing, negative or implausible (> 0.01 in) gives the default
    with source "default"; a usable value gives source "tool".
    """
    tw = tool_dict.get("toolwiz") if isinstance(tool_dict, dict) else None
    if isinstance(tw, dict):
        v = num(tw.get("runout_in"))
        if v is None and num(tw.get("runout_mm")) is not None:
            v = num(tw.get("runout_mm")) / 25.4
        if v is None and num(tw.get("runout")) is not None:
            unit = str(tool_dict.get("unit") or "").lower()
            v = num(tw.get("runout")) / (25.4 if is_metric(unit) else 1.0)
        if v is not None and 0.0 <= v <= MAX_RUNOUT_IN:
            return v, "tool"
    return default, "default"


def parse_runout_text(text, default=None):
    """'0.0002 in', '0.005 mm', '.0002' (inches) -> inches; blank -> default; bad -> ValueError."""
    s = str(text or "").strip().lower()
    if not s:
        return default
    m = re.match(r'^([-+]?(?:\d+\.?\d*|\.\d+))\s*(mm|millimeters?|in|inch|inches|")?$', s)
    if not m:
        raise ValueError(f"Cannot read runout {text!r}. Enter a number with units, e.g. 0.0002 in or 0.005 mm.")
    v = float(m.group(1))
    if m.group(2) and m.group(2).startswith("m"):
        v /= 25.4
    if v < 0 or v > MAX_RUNOUT_IN:
        raise ValueError(f"Runout {text!r} is out of range (0 to {MAX_RUNOUT_IN} in).")
    return v


_HSS_RE = re.compile(r"\b(hss|hss-e|hsse|hss-co|cobalt|high[\s-]?speed|m2|m35|m42)\b")


def tool_is_carbide(tool_dict):
    """True unless the tool's material fields (BMC / material / grade) or description say HSS or cobalt.
    Fusion stores the base material as BMC ("carbide", "hss", ...)."""
    t = tool_dict if isinstance(tool_dict, dict) else {}
    geo = t.get("geometry") if isinstance(t.get("geometry"), dict) else {}
    post = t.get("post-process") or t.get("postProcess") or {}
    parts = [t.get("description"), t.get("BMC"), t.get("material"), geo.get("BMC"), geo.get("material"),
             post.get("material") if isinstance(post, dict) else None,
             t.get("GRADE"), t.get("grade"), geo.get("grade")]
    text = " ".join(str(p).lower() for p in parts if p)
    if "carbide" in text:
        return True
    return not _HSS_RE.search(text)


def fusion_tool_for_server(tool_dict):
    """The Fusion tool slice the server's ToolProfile reads: type, unit, geometry, description, shaft
    segments (slot / T-slot necks and stickout) and the holder (for reach / collision checks). Returns None
    when the dict has no geometry object."""
    t = tool_dict if isinstance(tool_dict, dict) else None
    if not t or not isinstance(t.get("geometry"), dict):
        return None
    out = {"type": t.get("type"), "unit": t.get("unit"), "geometry": t["geometry"]}
    if t.get("description"):
        out["description"] = t["description"]
    if isinstance(t.get("shaft"), dict) and t["shaft"].get("segments"):
        out["shaft"] = t["shaft"]
    if isinstance(t.get("holder"), dict) and t["holder"]:
        out["holder"] = t["holder"]
    if t.get("BMC"):
        out["BMC"] = t["BMC"]
    return out


def tool_guid(tool_dict):
    g = tool_dict.get("guid") if isinstance(tool_dict, dict) else None
    return str(g) if g else None


# ==============================================================================
# auto-setter: request pieces and the result report
# ==============================================================================

def engagement_fields(doc_in, woc_in, use_op_engagement):
    """The user's own stepdown / stepover (inches) for the request, or {} when the operation has none or the
    user chose the recommendation."""
    if not use_op_engagement:
        return {}
    out = {}
    d, w = num(doc_in, 0.0), num(woc_in, 0.0)
    if d and d > 0:
        out["stepdown"] = round(d, 6)
    if w and w > 0:
        out["stepover"] = round(w, 6)
    return out


_CRITICAL_TITLE_RE = re.compile(
    r"infeasible|no safe cut|collision|stickout too short|neck clearance|clearance exceeded|critical|"
    r"will break|exceeds .*limit", re.I)


def alert_level(alert):
    """'critical' | 'warning' | 'info' for one alert/tip dict. The server's `type` wins; the Fusion alert list
    carries no type, so then the title decides."""
    t = str((alert or {}).get("type") or "").lower()
    if t in ("critical", "warning", "info"):
        return t
    if _CRITICAL_TITLE_RE.search(str((alert or {}).get("title") or "")):
        return "critical"
    return "warning"


def collect_findings(calc):
    """Every warning the server returned for one cut as [{level, source, title, message}], most severe first:
    alerts, tool profile warnings, T-slot warnings, holistic oversight findings, plus an infeasible-cut entry."""
    calc = calc if isinstance(calc, dict) else {}
    out, seen = [], set()

    def add(level, source, title, message):
        title, message = str(title or "").strip(), str(message or "").strip()
        key = (title.lower(), message.lower())
        if not (title or message) or key in seen:
            return
        seen.add(key)
        out.append({"level": level, "source": source, "title": title, "message": message})

    for w in ((calc.get("profile") or {}).get("warnings") or []):
        add("warning", "tool", "Tool definition", w)
    for a in calc.get("alerts") or []:
        if isinstance(a, dict):
            add(alert_level(a), "alert", a.get("title"), a.get("message"))
    ts = calc.get("tslot") or {}
    for w in (ts.get("warnings") or []) if isinstance(ts, dict) else []:
        if isinstance(w, dict):
            add(alert_level(w), "tslot", w.get("title"), w.get("message"))
    ov = calc.get("oversight") or {}
    for f in (ov.get("findings") or []) if isinstance(ov, dict) else []:
        if isinstance(f, dict):
            lvl = {"STOP": "critical", "CAUTION": "warning"}.get(sev_of(f.get("severity")), "info")
            msg = f.get("detail") or ""
            if f.get("recommendation"):
                msg = (msg + " " if msg else "") + "Recommendation: " + str(f["recommendation"])
            add(lvl, "oversight", f.get("title"), msg)
    if calc.get("feasible") is False:
        add("critical", "engine", "No safe cut found",
            f"Limited by {calc.get('limited_by') or 'an unspecified limit'}. The numbers are a minimum-engagement "
            "fallback and should not be run as-is.")
    rank = {"critical": 0, "warning": 1, "info": 2}
    out.sort(key=lambda d: rank.get(d["level"], 3))
    return out


def critical_findings(calc):
    return [f for f in collect_findings(calc) if f["level"] == "critical"]


def runout_lines(calc, flutes_total=None, unit="in"):
    """Flutes cutting, runout regime and the runout needed for all flutes."""
    calc = calc or {}
    lines = []
    fc = calc.get("flutes_cutting")
    if fc is not None:
        tot = f" of {flutes_total}" if flutes_total else ""
        regime = calc.get("runout_regime")
        reg = {"all_flutes": "all flutes cut", "reduced_flutes": "reduced flutes (runout lets only some flutes cut)"}.get(regime, regime or "")
        lines.append(f"Flutes cutting: {fc}{tot}" + (f" - {reg}" if reg else ""))
    tir = num(calc.get("tir_all_flutes_in"))
    if tir is not None:
        lines.append(f"Runout needed for all flutes to cut at this feed: {fmt_len(tir, unit, 5 if not is_metric(unit) else 4)}"
                     + (f" (runout ratio {calc.get('runout_ratio'):.2f})" if num(calc.get("runout_ratio")) is not None else ""))
    return lines


def stock_recommendation(calc):
    """(radial_in, axial_in) ToolWiz recommends leaving on a roughing operation, None when absent."""
    c = calc or {}
    return num(c.get("recommended_radial_stock_in")), num(c.get("recommended_axial_stock_in"))


def stock_lines(calc, unit="in"):
    r, a = stock_recommendation(calc)
    if r is None and a is None:
        return []
    return [f"Recommended stock to leave (true-to-size finishing): radial {fmt_len(r, unit)}, axial {fmt_len(a, unit)}"]


def holder_lines(holder):
    if not isinstance(holder, dict) or not holder:
        return []
    lines = []
    head = f"Holder: {holder.get('class', '?')} class"
    if num(holder.get("required_tir_in")) is not None:
        head += f", required TIR {holder['required_tir_in']:.5f} in"
    lines.append(head)
    if holder.get("recommended"):
        lines.append("  Recommended: " + ", ".join(map(str, holder["recommended"])))
    if holder.get("acceptable"):
        lines.append("  Acceptable: " + ", ".join(map(str, holder["acceptable"])))
    if holder.get("avoid"):
        lines.append("  Avoid: " + ", ".join(map(str, holder["avoid"])))
    if holder.get("reason"):
        lines.append("  " + str(holder["reason"]))
    if holder.get("high_speed_spindle"):
        lines.append("  High-speed spindle: " + str(holder["high_speed_spindle"]))
    return lines


def tool_advice_lines(advice):
    out = []
    for a in (advice or []):
        if not isinstance(a, dict):
            continue
        s = f"Tool: {a.get('vendor', '')} {a.get('series', '')}".strip()
        if a.get("expected_gain"):
            s += f" ({a['expected_gain']})"
        out.append(s)
        if a.get("why"):
            out.append("  " + str(a["why"]))
    return out


def tslot_lines(ts, unit="in"):
    """T-slot output: radial passes, Z steps, axial feed and the provisional-geometry warning."""
    if not isinstance(ts, dict) or not ts:
        return []
    plan = ts.get("axial_plan") or {}
    lines = [f"T-slot / keyseat cutter: {ts.get('operation', 'full_slot')}"]
    lines.append(f"  Radial passes: {ts.get('radial_passes')} x {fmt_len(ts.get('radial_depth_per_pass_in'), unit)} "
                 f"(total {fmt_len(ts.get('radial_depth_total_in'), unit)})")
    if plan:
        z = f"  Z: {plan.get('cuts')} cut(s)"
        if num(plan.get("z_step_in")):
            z += f", step {fmt_len(plan['z_step_in'], unit)}"
        if plan.get("method"):
            z += f" - {plan['method']}"
        lines.append(z)
    if num(ts.get("axial_feed_ipm")) is not None:
        lines.append(f"  Axial (Z) feed: {fmt_feed(ts['axial_feed_ipm'], unit)}; lateral feed {fmt_feed(ts.get('lateral_feed_ipm'), unit)}")
    if num(ts.get("neck_clearance_in")) is not None:
        lines.append(f"  Neck clearance: {fmt_len(ts['neck_clearance_in'], unit)}")
    prov = ts.get("provisional") or []
    if prov:
        lines.append("  WARNING provisional geometry (assumed, not measured): " + ", ".join(map(str, prov))
                     + ". Measure neck diameter, reach and tooth form before trusting these passes.")
    return lines


def format_advisor_sections(calc, flutes_total=None, unit="in", engagement_used=None):
    """Everything the auto-setter result dialog shows beyond the speeds line: engagement source, limiter,
    flutes cutting / runout regime, stock to leave, holder and tool advice, T-slot output and every
    warning. Returns text ('' when the server returned nothing extra)."""
    calc = calc or {}
    parts = []
    src = calc.get("engagement_source")
    if src:
        src_txt = "the operation's own stepdown/stepover" if src == "user" else "ToolWiz recommendation"
        eng = f"Engagement source: {src_txt}"
        if num(calc.get("engagement_doc")) is not None and num(calc.get("engagement_woc")) is not None:
            eng += f" (ADOC {fmt_len(calc['engagement_doc'], unit)}, RDOC {fmt_len(calc['engagement_woc'], unit)})"
        parts.append(eng)
        if src == "user" and num(calc.get("doc")) is not None:
            parts.append(f"ToolWiz recommends ADOC {fmt_len(calc.get('doc'), unit)}, RDOC {fmt_len(calc.get('woc'), unit)}")
    parts += format_finish_lines(calc.get("finish"), unit)
    parts += runout_lines(calc, flutes_total, unit)
    parts += stock_lines(calc, unit)
    parts += holder_lines(calc.get("holder_advice"))
    parts += tool_advice_lines(calc.get("tool_advice"))
    parts += tslot_lines(calc.get("tslot"), unit)
    finds = collect_findings(calc)
    if finds:
        parts.append("")
        for f in finds:
            tag = {"critical": "CRITICAL", "warning": "Warning", "info": "Note"}[f["level"]]
            parts.append(f"{tag}: {f['title']}" + (f" - {f['message']}" if f["message"] else ""))
    return "\n".join(parts).strip()


def format_critical_confirmation(calc):
    """Text for the explicit confirmation shown BEFORE anything is written, or '' when nothing is critical."""
    crit = critical_findings(calc)
    if not crit:
        return ""
    lines = ["ToolWiz raised CRITICAL warnings for this cut:", ""]
    for f in crit:
        lines.append(f"- {f['title']}" + (f": {f['message']}" if f["message"] else ""))
    lines += ["", "Write these cutting data to the operation anyway?"]
    return "\n".join(lines)


# ==============================================================================
# stock-to-leave manager
# ==============================================================================

def is_roughing_strategy(strategy, op_name=""):
    """Non-finishing milling: adaptive, pocket clearing, slotting, high feed, roughing contour, T-slot."""
    s = f"{strategy} {op_name}".lower()
    if "finish" in s and "rough" not in s:
        return False
    return any(k in s for k in ("adaptive", "rough", "pocket", "clearing", "bulk", "slot", "high feed", "high-feed"))


# ==============================================================================
# finish modes (cleanup | surface | accuracy)
# ==============================================================================

FINISH_MODES = (("Clean-up (maximize removal, decent finish)", "cleanup"),
                ("Surface finish (target Ra)", "surface"),
                ("Accuracy (wall tolerance)", "accuracy"))
DEFAULT_RA_UIN = 32.0
DEFAULT_WALL_TOL_IN = 0.0002

_FINISH_WORDS = ("finish", "flat", "horizontal", "parallel", "scallop", "pencil", "morph", "spiral", "radial",
                 "skim", "floor", "ramp", "contour")


def is_finishing_strategy(strategy, op_name=""):
    """Finishing operations (2D contour finishing, flat/horizontal, parallel, scallop, pencil ...). A strategy
    that is roughing (see is_roughing_strategy) is not finishing."""
    s = f"{strategy} {op_name}".lower()
    if "rough" in s or "adaptive" in s or "pocket" in s or "slot" in s:
        return False
    return any(k in s for k in _FINISH_WORDS)


def ra_uin_to_text(ra_uin, unit="in"):
    v = num(ra_uin)
    if v is None:
        return ""
    return f"{v * 0.0254:.2f} um" if is_metric(unit) else f"{v:.0f} uin"


def parse_ra_text(text, unit="in", default=DEFAULT_RA_UIN):
    """'32', '32 uin', '0.8 um' -> micro-inches. Blank -> default. A bare number is in the document's Ra unit
    (um for a metric document, uin otherwise)."""
    s = str(text or "").strip().lower()
    if not s:
        return default
    m = re.match(r"^([-+]?(?:\d+\.?\d*|\.\d+))\s*(uin|\u00b5in|microinch(?:es)?|um|\u00b5m|micron(?:s)?|micrometers?)?$", s)
    if not m:
        raise ValueError(f"Cannot read surface finish {text!r}. Enter e.g. 32 uin or 0.8 um.")
    v = float(m.group(1))
    u = m.group(2) or ("um" if is_metric(unit) else "uin")
    if u.startswith(("um", "\u00b5m", "micron", "micromet")):
        v /= 0.0254
    if v <= 0 or v > 1000:
        raise ValueError(f"Surface finish {text!r} is out of range.")
    return v


def finish_mode_code(label):
    return dict(FINISH_MODES).get(label) or (label if label in dict((c, c) for _, c in FINISH_MODES) else "cleanup")


def finish_fields(mode, ra_uin=None, wall_tol_in=None):
    """Request fields for /api/calculate_for_fusion. `finishMode` always; targetRa (micro-inches) only for
    mode 'surface'; wallTolerance (inches) only for 'accuracy'."""
    mode = finish_mode_code(mode)
    out = {"finishMode": mode}
    if mode == "surface":
        out["targetRa"] = float(ra_uin if num(ra_uin) else DEFAULT_RA_UIN)
    if mode == "accuracy":
        out["wallTolerance"] = float(wall_tol_in if num(wall_tol_in) else DEFAULT_WALL_TOL_IN)
    return out


def format_finish_lines(finish, unit="in"):
    """The response `finish` block: predicted Ra, cusp height, predicted wall error, limiter and advice.
    Absent (older server / roughing) gives []."""
    if not isinstance(finish, dict) or not finish:
        return []
    lines = [f"Finish mode: {finish.get('mode', '?')}"]
    bits = []
    if num(finish.get("predicted_ra_uin")) is not None:
        bits.append(f"predicted Ra {ra_uin_to_text(finish['predicted_ra_uin'], unit)}"
                    + (f" (target {ra_uin_to_text(finish['target_ra_uin'], unit)})" if num(finish.get("target_ra_uin")) is not None else ""))
    if num(finish.get("predicted_cusp_in")) is not None:
        bits.append(f"cusp height {fmt_len(finish['predicted_cusp_in'], unit, 6 if not is_metric(unit) else 5)}")
    if num(finish.get("predicted_wall_error_in")) is not None:
        bits.append(f"predicted wall error {fmt_len(finish['predicted_wall_error_in'], unit, 5 if not is_metric(unit) else 4)}"
                    + (f" (tolerance {fmt_len(finish['wall_tolerance_in'], unit, 5 if not is_metric(unit) else 4)})" if num(finish.get("wall_tolerance_in")) is not None else ""))
    for b in bits:
        lines.append("  " + b)
    if finish.get("limited_by"):
        lines.append(f"  limited by: {_limit_text(finish['limited_by'])}")
    adv = finish.get("advice")
    for a in (adv if isinstance(adv, list) else ([adv] if adv else [])):
        lines.append("  " + str(a))
    return lines


def _limit_text(x):
    return ", ".join(map(str, x)) if isinstance(x, (list, tuple)) else str(x)


def stock_consistency_notes(ops):
    """Finishing-op wall tolerance logic across one setup. `ops` is an ordered list of dicts
    {label, is_finishing, rad_in, ax_in, woc_in}. Warns when the preceding roughing op leaves less
    stock than the finishing pass's radial engagement (the finishing pass would cut air or the
    roughing would cut the wall) and when the roughing op leaves almost nothing. Returns {label: [notes]}."""
    notes = {}
    last_rough = None
    for o in ops:
        if not o.get("is_finishing"):
            if num(o.get("rad_in")) is not None:
                last_rough = o
            continue
        if last_rough is None:
            continue
        r = num(last_rough.get("rad_in"), 0.0) or 0.0
        w = num(o.get("woc_in"), 0.0) or 0.0
        lab = o.get("label")
        if r <= 0.0005:
            notes.setdefault(lab, []).append(
                f"The roughing op before this leaves {r:.4f} in radial stock: the finishing pass cannot true up the wall.")
        elif w > 0 and w > r * 1.25:
            notes.setdefault(lab, []).append(
                f"Finishing radial engagement {w:.4f} in is more than the {r:.4f} in the roughing op leaves: "
                "the finishing pass will take a heavier cut than planned and deflect more.")
    return notes


# ==============================================================================
# Setup Advisor
# ==============================================================================

def parse_advisor_response(res):
    """Normalise /api/setup_advisor's JSON: {ok, error, operations, setup_findings, strategy_suggestions,
    narrative, narrative_verified (True only when narrative_check.ok), rejected_numbers}."""
    res = res if isinstance(res, dict) else {}
    nc = res.get("narrative_check") if isinstance(res.get("narrative_check"), dict) else {}
    narrative = res.get("narrative") if isinstance(res.get("narrative"), str) and res.get("narrative").strip() else None
    return {
        "ok": bool(res.get("success", True)) and isinstance(res.get("operations"), list),
        "error": res.get("error"),
        "operations": [o for o in (res.get("operations") or []) if isinstance(o, dict)],
        "setup_findings": [f for f in (res.get("setup_findings") or []) if isinstance(f, dict)],
        "strategy_suggestions": [s for s in (res.get("strategy_suggestions") or []) if isinstance(s, dict)],
        "narrative": narrative,
        "narrative_verified": bool(narrative) and nc.get("ok") is True,
        "rejected_numbers": list(nc.get("rejected_numbers") or []),
    }


def _finding_line(f):
    s = f"[{SEV_LABEL[sev_of(f.get('severity'))]}] {f.get('title', '')}".rstrip()
    if f.get("detail"):
        s += f" - {f['detail']}"
    if f.get("recommendation") and isinstance(f["recommendation"], str):
        s += f"\n      Recommendation: {f['recommendation']}"
    return s


def format_advisor_summary(parsed):
    """Readable text of the whole advisor result (findings per op, setup findings, suggestions, narrative)."""
    lines = []
    counts = {"STOP": 0, "CAUTION": 0, "INFO": 0}
    for o in parsed["operations"]:
        for f in o.get("findings") or []:
            counts[sev_of(f.get("severity"))] += 1
    for f in parsed["setup_findings"]:
        counts[sev_of(f.get("severity"))] += 1
    lines.append(f"{counts['STOP']} STOP, {counts['CAUTION']} CAUTION, {counts['INFO']} info finding(s) "
                 f"in {len(parsed['operations'])} operation(s).")
    for f in sort_by_severity(parsed["setup_findings"]):
        lines.append("Setup: " + _finding_line(f))
    for o in parsed["operations"]:
        fl = sort_by_severity(o.get("findings") or [])
        head = f"{o.get('name') or o.get('op_id')} ({o.get('strategy', '')})"
        lines.append("")
        lines.append(head if fl else head + " - no findings")
        for f in fl:
            lines.append("   " + _finding_line(f))
    if parsed["strategy_suggestions"]:
        lines.append("")
        lines.append("Strategy suggestions")
        for s in parsed["strategy_suggestions"]:
            lines.append("  - " + strategy_suggestion_text(s))
    if parsed["narrative"]:
        lines.append("")
        lines.append("Narrative" + (" (numbers verified against ToolWiz results)" if parsed["narrative_verified"] else
                                   " (NOT verified: do not rely on numbers in it)"))
        lines.append(parsed["narrative"])
        if parsed["rejected_numbers"] and not parsed["narrative_verified"]:
            lines.append("Numbers not found in ToolWiz results: " + ", ".join(map(str, parsed["rejected_numbers"][:12])))
    return "\n".join(lines)


def strategy_suggestion_text(s):
    s = s or {}
    text = str(s.get("title") or s.get("summary") or s.get("strategy") or s.get("name") or "Suggestion")
    for k in ("detail", "reason", "description"):
        if s.get(k):
            text += f": {s[k]}"
            break
    saved = s.get("time_saved_min", s.get("time_saved"))
    if num(saved) is not None:
        text += f" (saves about {num(saved):.1f} min per part)"
    elif s.get("time_saved_text"):
        text += f" ({s['time_saved_text']})"
    return text


_PARAM_KEYS = ("apply", "apply_params", "fusion_params", "parameters", "params", "changes")


def _dict_changes(obj):
    """{param: expression} from a dict of strings/numbers, else {}."""
    if not isinstance(obj, dict):
        return {}
    out = {}
    for k, v in obj.items():
        if isinstance(k, str) and isinstance(v, (str, int, float)) and not isinstance(v, bool):
            out[k] = str(v)
        elif isinstance(k, str) and isinstance(v, bool):
            out[k] = "true" if v else "false"
    return out


def extract_changes(item, default_op_id=None):
    """Parameter changes carried by one finding / suggestion as {op_id: {param: expression}}.

    Accepted shapes (any of the keys in _PARAM_KEYS, on the item or inside its "recommendation" dict):
    {"op_id", "params": {...}} | {"params": {...}} (op from default_op_id) | a list of the former.
    """
    found = {}

    def merge(op_id, params):
        p = _dict_changes(params)
        if op_id and p:
            found.setdefault(op_id, {}).update(p)

    def scan(d, op_id):
        if not isinstance(d, dict):
            return
        for key in _PARAM_KEYS:
            v = d.get(key)
            if isinstance(v, dict):
                if isinstance(v.get("params"), dict):
                    merge(v.get("op_id") or op_id, v["params"])
                else:
                    merge(d.get("op_id") or op_id, v)
            elif isinstance(v, list):
                for e in v:
                    if isinstance(e, dict):
                        merge(e.get("op_id") or d.get("op_id") or op_id, e.get("params") or e.get("parameters"))

    base = (item or {}).get("op_id") or default_op_id
    scan(item, base)
    rec = (item or {}).get("recommendation")
    if isinstance(rec, dict):
        scan(rec, rec.get("op_id") or base)
    return found


def extract_recommendations(parsed):
    """Applicable recommendations of an advisor result: [{id, op_id, title, severity, detail, changes}], one per
    finding/suggestion that carries parameter changes for Fusion. `changes` is {op_id: {param: expression}}."""
    recs = []

    def add(kind, item, default_op, title, sev):
        ch = extract_changes(item, default_op)
        if ch:
            recs.append({"id": f"r{len(recs) + 1}", "kind": kind, "op_id": default_op, "title": title,
                         "severity": sev, "detail": str(item.get("detail") or item.get("reason") or ""),
                         "changes": ch})

    for f in parsed["setup_findings"]:
        add("setup", f, None, str(f.get("title") or "Setup finding"), sev_of(f.get("severity")))
    for o in parsed["operations"]:
        for f in o.get("findings") or []:
            add("finding", f, o.get("op_id"), f"{o.get('name') or o.get('op_id')}: {f.get('title', '')}", sev_of(f.get("severity")))
    for s in parsed["strategy_suggestions"]:
        add("strategy", s, s.get("op_id"), strategy_suggestion_text(s), "INFO")
    return recs


def merge_selected_changes(recs, selected_ids):
    """Combine the changes of the chosen recommendations: {op_id: {param: expression}} (later wins) and the
    list of conflicts (same op + parameter with different expressions)."""
    merged, conflicts = {}, []
    for r in recs:
        if r["id"] not in selected_ids:
            continue
        for op_id, params in r["changes"].items():
            cur = merged.setdefault(op_id, {})
            for k, v in params.items():
                if k in cur and cur[k] != v:
                    conflicts.append(f"{op_id}: {k} {cur[k]} vs {v}")
                cur[k] = v
    return merged, conflicts


def summarize_changes(changes, current=None):
    """Exactly which parameters will change: lines 'Op: param: old -> new'. `current` is
    {op_id: {param: current expression}} (from Fusion); unknown olds show '?'."""
    lines = []
    for op_id, params in changes.items():
        for k, v in params.items():
            old = ((current or {}).get(op_id) or {}).get(k, "?")
            lines.append(f"{op_id}: {k}: {old} -> {v}")
    return lines


def build_apply_request(changes, reason="ToolWiz Setup Advisor", recommendations=None):
    """/api/setup_advisor/apply body: the bridge commands ({op_id, params, reason}) for the chosen changes."""
    return {"changes": [{"op_id": op, "params": p, "reason": reason} for op, p in changes.items()],
            "selected": [r["id"] for r in (recommendations or [])],
            "recommendations": [{"id": r["id"], "title": r["title"]} for r in (recommendations or [])]}


def parse_apply_response(res):
    """Normalise the apply response: (executed_by_server, results). `results` is a list of
    {op_id, applied, skipped, error}; `executed_by_server` is True when it carries bridge results."""
    res = res if isinstance(res, dict) else {}
    items = res.get("results")
    if isinstance(items, list):
        out = []
        for r in items:
            if not isinstance(r, dict):
                continue
            inner = r.get("result") if isinstance(r.get("result"), dict) else r
            out.append({"op_id": r.get("op_id") or inner.get("op_id") or inner.get("operation"),
                        "applied": inner.get("applied") or [], "skipped": inner.get("skipped") or [],
                        "error": inner.get("error") or (None if inner.get("ok", inner.get("success", True)) else "failed")})
        return True, out
    return False, []


def format_apply_results(results):
    lines = []
    for r in results:
        a = r.get("applied") or []
        s = r.get("skipped") or []
        head = f"{r.get('op_id')}: {len(a)} applied" + (f", {len(s)} skipped" if s else "")
        if r.get("error"):
            head += f" - {r['error']}"
        lines.append(head)
        for x in a:
            lines.append("   " + (x if isinstance(x, str) else f"{x.get('param')}: {x.get('old')} -> {x.get('new')}"))
        for x in s:
            lines.append("   skipped " + (x if isinstance(x, str) else f"{x.get('param')}: {x.get('reason')}"))
    return "\n".join(lines)


# ==============================================================================
# apply_operation_parameters (bridge action): validation
# ==============================================================================

ALLOWED_PARAMS = frozenset((
    "tool_spindleSpeed", "tool_feedCutting", "tool_feedRamp", "tool_feedPlunge", "tool_feedTransition",
    "tool_feedEntry", "tool_feedExit", "tool_feedRetract", "tool_rampSpindleSpeed", "tool_rampAngle",
    "maximumStepdown", "stepdown", "optimalLoad", "stepover", "maximumStepover", "finishingStepover",
    "minimumStepover", "fineStepdown", "stockToLeave", "radialStockToLeave", "verticalStockToLeave",
    "axialStockToLeave", "useStockToLeave", "isStockToLeave", "simpleStockToLeave", "rampAngle",
    "helicalRampDiameter", "numberOfStepdowns", "doMultiplePasses", "numberOfStepovers", "useStepdown",
    "useStepover", "minimumCutRadius", "smoothingDeviation", "tolerance", "useTabs", "tabWidth", "tabHeight",
    "tabDistance", "tabPositioning", "tabCount", "useStockToLeaveFloor",
))
_EXPR_OK = re.compile(r"^[A-Za-z0-9_\s.+\-*/();,<>=?:'%^]+$")


def validate_parameter_changes(params):
    """Split a {name: expression} request into (accepted, skipped). Skipped entries are
    {param, reason}: not in the allowed list, empty, or an expression with characters Fusion expressions
    never need."""
    ok, skipped = {}, []
    for name, expr in (params or {}).items():
        e = str(expr).strip() if expr is not None else ""
        if name not in ALLOWED_PARAMS:
            skipped.append({"param": name, "reason": "parameter is not on the add-in's allowed list"})
        elif not e:
            skipped.append({"param": name, "reason": "empty expression"})
        elif len(e) > 200 or not _EXPR_OK.match(e):
            skipped.append({"param": name, "reason": "unsupported characters in expression"})
        else:
            ok[name] = e
    return ok, skipped


# ==============================================================================
# Strategy planner
# ==============================================================================

def strategy_feature_from_inputs(kind, depth_in, length_in, width_in=None, tabs=None, slot_height_in=None,
                                 radial_depth_in=None):
    """The `feature` object for /api/strategy/compare (inches)."""
    f = {"type": kind}
    if kind == "profile_cutout":
        f.update(depth=depth_in, length=length_in)
        if tabs and tabs.get("count"):
            f["tabs"] = tabs
        if width_in:
            f["channel_width"] = width_in
    elif kind == "slot":
        f.update(width=width_in, depth=depth_in, length=length_in)
    elif kind == "tslot":
        f.update(slot_height=slot_height_in, radial_depth=radial_depth_in, length=length_in)
    else:
        raise ValueError(f"Unknown feature type {kind!r}")
    return f


def tool_candidate_from_fusion(tool_dict):
    """A /api/strategy/compare candidate (inches) from a Fusion tool dict, or None when unreadable. Uses
    the tool's own unit; geometry keys DC, NOF, LCF, SFDM, LB."""
    g = (tool_dict or {}).get("geometry") or {}
    f = 1.0 / 25.4 if is_metric((tool_dict or {}).get("unit")) else 1.0
    dc = num(g.get("DC"))
    if not dc or dc <= 0:
        return None
    c = {"diameter": round(dc * f, 6), "flutes": int(num(g.get("NOF"), 2) or 2)}
    for key, fk in (("LCF", "flute_length"), ("SFDM", "shank_diameter"), ("LB", "stickout")):
        v = num(g.get(key))
        if v and v > 0:
            c[fk] = round(v * f, 6)
    if "stickout" not in c:
        v = num(g.get("OAL"))
        if v and v > 0:
            c["stickout"] = round(v * f * 0.6, 6)
    return c


def format_strategy_result(res, unit="in"):
    """Options table, recommendation and Fusion hints as text."""
    res = res if isinstance(res, dict) else {}
    opts = res.get("options") or []
    lines = []
    if not opts:
        return "No options returned."
    hdr = f"{'Option':<46}{'levels':>6}{'ap':>9}{'ae':>9}{'rpm':>7}{'feed':>8}{'min/part':>9}{'life':>7}{'wear':>6}"
    lines.append(hdr)
    for o in opts:
        mark = "*" if o.get("name") == res.get("recommended") else " "
        name = str(o.get("name", ""))[:44]
        lines.append(f"{mark}{name:<45}{o.get('levels', '-')!s:>6}{_n(o.get('ap'), 4):>9}{_n(o.get('ae'), 4):>9}"
                     f"{_n(o.get('rpm'), 0):>7}{_n(o.get('feed_ipm'), 1):>8}{_n(o.get('cycle_time_min'), 2):>9}"
                     f"{_n(o.get('relative_tool_life'), 1):>7}{_n(o.get('tool_wear_per_part'), 2):>6}")
    lines.append("(* = recommended; ap/ae in inches, feed IPM, wear relative to the least-wear option)")
    if res.get("recommended"):
        lines += ["", f"RECOMMENDED: {res['recommended']}"]
    for r in res.get("reasoning") or []:
        lines.append("  - " + str(r))
    rec = next((o for o in opts if o.get("name") == res.get("recommended")), None)
    if rec:
        lines += ["", "Fusion settings for the recommended option"] + fusion_hint_lines(rec.get("fusion_hints"), unit)
        for r in rec.get("risks") or []:
            lines.append("  risk: " + str(r))
    for t in res.get("tab_advice") or []:
        lines.append("Tabs: " + str(t))
    if res.get("assumptions"):
        lines += ["", "Assumptions"] + ["  - " + str(a) for a in res["assumptions"]]
    return "\n".join(lines)


def _n(v, d):
    x = num(v)
    return "-" if x is None else f"{x:.{d}f}"


def fusion_hint_lines(hints, unit="in"):
    """Fusion hints (tabs, stepdown, optimal load, ramp, stock) as '  name: value' lines."""
    if not isinstance(hints, dict) or not hints:
        return ["  (none)"]
    lines = []

    def walk(prefix, d):
        for k, v in d.items():
            if isinstance(v, dict):
                walk(f"{prefix}{k}.", v)
            elif v not in (None, "", []):
                lines.append(f"  {prefix}{k}: {v}")
    walk("", hints)
    return lines or ["  (none)"]


# ==============================================================================
# Master library builder
# ==============================================================================

def library_source_label(location_name):
    return {"LocalLibraryLocation": "local", "CloudLibraryLocation": "cloud", "HubLibraryLocation": "hub",
            "NetworkLibraryLocation": "hub"}.get(location_name, "local")


def harvest_entry(name, source, tools):
    """One {"library_name", "source", "tools"} entry; tools without a guid are left as they are, duplicates by
    guid inside one library are dropped. Returns None for an empty library."""
    seen, out = set(), []
    for t in tools or []:
        if not isinstance(t, dict):
            continue
        g = tool_guid(t)
        if g:
            if g in seen:
                continue
            seen.add(g)
        out.append(t)
    return {"library_name": str(name), "source": source, "tools": out} if out else None


def build_sets_request(libraries, sets, materials, strategies, aggressiveness, model=None, runout=None,
                       tool_filter=None, **extra):
    """POST /api/twin/build_sets body. `sets`/`materials`/`strategies` empty means 'all' (key omitted)."""
    body = {"libraries": libraries, "aggressiveness": aggressiveness}
    if sets:
        body["sets"] = list(sets)
    if materials:
        body["materials"] = list(materials)
    if strategies:
        body["strategies"] = list(strategies)
    if model:
        body["model"] = model
    if runout is not None:
        body["runout"] = runout
    if tool_filter:
        body["filter"] = tool_filter
    body.update(extra)
    return body


def format_build_progress(status):
    """(percent, text) for a /api/twin/build_sets/<id> status body."""
    st = status if isinstance(status, dict) else {}
    pr = st.get("progress") or {}
    pct = num(pr.get("percent"), 0.0)
    phase = st.get("phase") or st.get("state") or "working"
    cur = pr.get("current_tool")
    text = f"{phase}: {pr.get('tools_done', 0)} of {pr.get('tools_total', '?')} tools"
    if cur:
        text += f" - {cur}"
    return pct, text


def format_build_result(result):
    """Audit summary and skipped items of a finished build as text."""
    result = result if isinstance(result, dict) else {}
    lines = []
    m = result.get("merge") or {}
    if m:
        lines.append(f"Merged {m.get('tools_in', '?')} tools into {m.get('tools_out', '?')} "
                     f"({m.get('duplicates_merged', 0)} duplicates merged, {m.get('repaired_tools', 0)} geometry repairs).")
        for sv in (m.get("stickout_variants") or [])[:10]:
            lines.append(f"  kept separate (stickout differs): {sv if isinstance(sv, str) else json.dumps(sv)[:120]}")
    for lib in result.get("libraries") or []:
        au = (lib.get("audit") or {})
        sm = au.get("summary") or {}
        lines.append("")
        lines.append(f"{lib.get('name')}: {lib.get('tool_count')} tools, {lib.get('preset_count')} presets "
                     f"({lib.get('toolwiz_preset_count')} by ToolWiz, {lib.get('previous_toolwiz_presets_replaced', 0)} old ToolWiz presets replaced)")
        lines.append(f"  audit: {sm.get('toolwiz_STOP', 0)} STOP in ToolWiz presets, {sm.get('CAUTION', 0)} CAUTION, {sm.get('INFO', 0)} info")
        for code, n in (au.get("cautions_by_code") or {}).items():
            lines.append(f"    caution {code}: {n}")
        for d in (au.get("dropped_presets") or [])[:15]:
            lines.append(f"  dropped (audit STOP): {d.get('tool')} / {d.get('preset')}: {d.get('message') or d.get('code')}")
        for f in (au.get("owner_preset_stop_findings") or [])[:10]:
            lines.append(f"  your own preset, left untouched: {f.get('tool')} / {f.get('preset')}: {f.get('message') or f.get('code')}")
        sk = lib.get("skipped") or []
        if sk:
            lines.append(f"  skipped {len(sk)} item(s):")
            for s in sk[:25]:
                lines.append(f"    {s.get('tool')} ({s.get('type')}) {s.get('material', '')} {s.get('strategy', '')}: {s.get('reason')}")
            if len(sk) > 25:
                lines.append(f"    ... and {len(sk) - 25} more")
    return "\n".join(lines).strip()


# ==============================================================================
# Library audit
# ==============================================================================

def format_audit_report(report, limit_per_tool=8):
    """STOP / CAUTION / INFO per tool and preset, tools with the worst findings first.
    Returns (text, jump_targets) where jump_targets is [(label, tool_index)] for the tools listed."""
    report = report if isinstance(report, dict) else {}
    sm = report.get("summary") or {}
    lines = [f"{sm.get('STOP', 0)} STOP, {sm.get('CAUTION', 0)} CAUTION, {sm.get('INFO', 0)} info "
             f"in {sm.get('tools', '?')} tools / {sm.get('presets', '?')} presets."]
    jumps = []
    rows = []
    for row in report.get("tools") or []:
        fs = row.get("findings") or []
        if not fs:
            continue
        worst = min(SEV_RANK.get(sev_of(f.get("severity")), 3) for f in fs)
        rows.append((worst, row, fs))
    rows.sort(key=lambda t: (t[0], t[1].get("index", 0)))
    for _, row, fs in rows:
        label = f"#{row.get('index', 0) + 1} {row.get('description') or row.get('type') or 'tool'}"
        jumps.append((label, row.get("index", 0)))
        lines.append("")
        lines.append(label)
        for f in sort_by_severity(fs)[:limit_per_tool]:
            where = f" [preset: {f['preset']}]" if f.get("preset") else ""
            lines.append(f"  [{SEV_LABEL[sev_of(f.get('severity'))]}] {f.get('message', '')}{where}")
        if len(fs) > limit_per_tool:
            lines.append(f"  ... {len(fs) - limit_per_tool} more")
    return "\n".join(lines), jumps


def find_tool_index_by_guid(tools, guid):
    for i, t in enumerate(tools or []):
        if tool_guid(t) == guid:
            return i
    return None
