import adsk.core, adsk.cam, adsk.fusion, traceback
import urllib.request, urllib.error, json
import os, re, sys, math, time, datetime

# ---------------------------------------------------------------------------
# Imports of sibling modules. Installed layout: json_mutator.py and toolwiz_common/
# sit next to this file. Repo layout: toolwiz_common/ lives one level up.
# ---------------------------------------------------------------------------
_ADDIN_DIR = os.path.dirname(os.path.abspath(__file__))
_REPO_ROOT = os.path.dirname(_ADDIN_DIR)

try:
    from . import json_mutator
except (ImportError, ValueError):
    if _ADDIN_DIR not in sys.path:
        sys.path.insert(0, _ADDIN_DIR)
    import json_mutator

try:
    from .toolwiz_common import ToolGeometry, UnitError, safe_eval_length
except (ImportError, ValueError):
    if (not os.path.isdir(os.path.join(_ADDIN_DIR, 'toolwiz_common'))
            and os.path.isdir(os.path.join(_REPO_ROOT, 'toolwiz_common'))
            and _REPO_ROOT not in sys.path):
        sys.path.insert(0, _REPO_ROOT)
    if _ADDIN_DIR not in sys.path:
        sys.path.insert(0, _ADDIN_DIR)
    from toolwiz_common import ToolGeometry, UnitError, safe_eval_length

# Single server base URL used by every request.
SERVER_BASE_URL = "http://127.0.0.1:5000"
CLIENT_HEADER_NAME = 'X-ToolWiz-Client'
CLIENT_HEADER_VALUE = 'fusion-addin'

app = None
ui = None
handlers = []

exportCommandId = 'ToolWizExportTwinCmd'
importCommandId = 'ToolWizImportTwinCmd'
calcCommandId = 'ToolWizCalcCmd'
stockCommandId = 'ToolWizStockToLeaveCmd'

workspaceToUse = 'CAMEnvironment'
panelToUse = 'CAMManagePanel'

available_ops_map = {}
discovered_libraries_map = {}
stock_ops_cache = {}
stock_setups_cache = {}
stock_table_input = None
_is_updating_ui = False
_stock_last_error = None

# Shared material state, filled by load_materials() for BOTH the Speeds & Feeds
# and the Stock to Leave commands.
_materials = {"families": [], "alloys": {}, "status": "none", "cached_at": None, "notice": None}

_LOG_MAX_BYTES = 1000000


# ==============================================================================
# LOGGING
# ==============================================================================

def _toolwiz_dir():
    base = os.environ.get('APPDATA') or os.path.expanduser('~')
    return os.path.join(base, 'ToolWiz')


def _log_path():
    return os.path.join(_toolwiz_dir(), 'addin.log')


def _log(msg, exc=None):
    """Append a line (and optional traceback) to %APPDATA%/ToolWiz/addin.log. Never raises.
    `exc` may be an exception instance or True (use the active exception)."""
    try:
        d = _toolwiz_dir()
        os.makedirs(d, exist_ok=True)
        path = _log_path()
        try:
            if os.path.exists(path) and os.path.getsize(path) > _LOG_MAX_BYTES:
                os.replace(path, path + '.1')
        except OSError:
            pass
        text = f"{datetime.datetime.now().isoformat(timespec='seconds')} {msg}\n"
        if exc is not None:
            if isinstance(exc, BaseException):
                text += ''.join(traceback.format_exception(type(exc), exc, exc.__traceback__))
            else:
                text += traceback.format_exc()
        with open(path, 'a', encoding='utf-8') as f:
            f.write(text)
    except Exception:
        pass


def _report_error(context, exc=None):
    """Log the active/given exception and show the user a short message."""
    _log(context, exc if exc is not None else True)
    try:
        if ui:
            detail = f"\n{exc}" if exc is not None else ""
            ui.messageBox(f"{context}{detail}\n\nDetails were written to:\n{_log_path()}", "ToolWiz")
    except Exception:
        pass


# ==============================================================================
# HTTP
# ==============================================================================

def _http_json(path, payload=None, timeout=5.0, retries=0):
    """GET (payload None) or POST JSON to the ToolWiz server and return the decoded JSON.

    Always sends the X-ToolWiz-Client header. An HTTP error that carries a JSON body
    (e.g. 400 {"success": false, "error": ...}) returns that body. Connection errors
    are retried `retries` times, then re-raised.
    """
    url = SERVER_BASE_URL + path
    data = json.dumps(payload).encode('utf-8') if payload is not None else None
    last_exc = None
    for attempt in range(retries + 1):
        req = urllib.request.Request(url, data=data)
        req.add_header(CLIENT_HEADER_NAME, CLIENT_HEADER_VALUE)
        if data is not None:
            req.add_header('Content-Type', 'application/json; charset=utf-8')
        try:
            resp = urllib.request.urlopen(req, timeout=timeout)
            try:
                return json.loads(resp.read().decode('utf-8'))
            finally:
                try:
                    resp.close()
                except Exception:
                    pass
        except urllib.error.HTTPError as e:
            body = None
            try:
                body = json.loads(e.read().decode('utf-8'))
            except Exception:
                pass
            try:
                e.close()
            except Exception:
                pass
            if isinstance(body, dict):
                return body
            last_exc = e
        except (urllib.error.URLError, OSError, ValueError) as e:
            last_exc = e
        _log(f"HTTP {'POST' if data is not None else 'GET'} {path} failed (attempt {attempt + 1}/{retries + 1})", last_exc)
        if attempt < retries:
            time.sleep(0.3)
    raise last_exc


def _offline_message(action):
    return (
        f"Cannot connect to the Tool Wizard backend at {SERVER_BASE_URL}.\n\n"
        f"Tool Wizard must be running on your machine to {action}.\n\n"
        "To start it:\n"
        "1. Open a terminal in your Tool Wizard directory.\n"
        "2. Run: py app.py (or click your Tool Wizard desktop shortcut).\n"
        "3. Re-run this command once the server is started."
    )


# ==============================================================================
# MATERIALS (single shared loader)
# ==============================================================================

def _materials_cache_path():
    return os.path.join(_toolwiz_dir(), 'materials_cache.json')


def _build_materials(families, alloys_raw):
    """Return (families, {family: ["alloy (condition)", ...]})."""
    alloys = {}
    for a in alloys_raw or []:
        if not isinstance(a, dict):
            continue
        fam = a.get("family", "")
        alloy = a.get("alloy", "")
        cond = a.get("condition", "")
        name = f"{alloy} ({cond})" if cond else alloy
        if fam and name:
            lst = alloys.setdefault(fam, [])
            if name not in lst:
                lst.append(name)
    return list(families), alloys


def _save_materials_cache(families, alloys_raw):
    try:
        os.makedirs(_toolwiz_dir(), exist_ok=True)
        path = _materials_cache_path()
        tmp = path + '.tmp'
        with open(tmp, 'w', encoding='utf-8') as f:
            json.dump({
                "saved_at": datetime.datetime.now().isoformat(timespec='seconds'),
                "families": families,
                "alloys": alloys_raw,
            }, f)
        os.replace(tmp, path)
    except Exception as e:
        _log("Could not write materials cache", e)


def _read_materials_cache():
    """Return (families, alloys_raw, saved_at) or None."""
    try:
        with open(_materials_cache_path(), 'r', encoding='utf-8') as f:
            c = json.load(f)
        fams = c.get("families")
        if isinstance(fams, list) and fams:
            return fams, c.get("alloys") or [], str(c.get("saved_at", ""))
    except FileNotFoundError:
        pass
    except Exception as e:
        _log("Could not read materials cache", e)
    return None


def load_materials():
    """Load material families + alloys. Used by BOTH the Speeds & Feeds and Stock to Leave commands.

    GET /api/data (10 s timeout, 1 retry). On success the result is cached to
    %APPDATA%/ToolWiz/materials_cache.json. On failure the cache is used and a notice is set;
    with no cache either, status is "none" and calculation must not be allowed.
    Updates and returns the module-level `_materials` dict.
    """
    global _materials
    try:
        data = _http_json('/api/data', timeout=10.0, retries=1)
        families = data.get("families") if isinstance(data, dict) else None
        if not isinstance(families, list) or not families:
            raise ValueError("server returned no material families")
        alloys_raw = data.get("alloys") or []
        fams, alloys = _build_materials(families, alloys_raw)
        _save_materials_cache(families, alloys_raw)
        global _machine_max_rpm
        try:
            _machine_max_rpm = float((data.get("machine") or {}).get("max_rpm") or 0) or None
        except (TypeError, ValueError):
            _machine_max_rpm = None
        _materials = {"families": fams, "alloys": alloys, "status": "online", "cached_at": None, "notice": None}
        return _materials
    except Exception as e:
        _log("Material list fetch from server failed", e)

    cached = _read_materials_cache()
    if cached:
        fams, alloys = _build_materials(cached[0], cached[1])
        when = cached[2][:16].replace('T', ' ') or "earlier"
        _materials = {
            "families": fams, "alloys": alloys, "status": "cache", "cached_at": when,
            "notice": f"Server offline — using material list cached {when}",
        }
    else:
        _materials = {
            "families": [], "alloys": {}, "status": "none", "cached_at": None,
            "notice": ("Cannot load materials: the ToolWiz server is offline and no cached material list exists. "
                       f"Start ToolWiz (py app.py at {SERVER_BASE_URL}) and reopen this command. "
                       "Calculation is disabled."),
        }
    return _materials


def materials_ready():
    return _materials.get("status") in ("online", "cache") and bool(_materials.get("families"))


def alloys_for(family):
    return _materials.get("alloys", {}).get(family, [])


def _add_materials_notice(inputs, input_id):
    """Show the offline / no-cache notice (if any) as a text box."""
    notice = _materials.get("notice")
    if notice:
        title = 'Error' if _materials.get("status") == "none" else 'Warning'
        box = inputs.addTextBoxCommandInput(input_id, title, notice, 3, True)
        box.isFullWidth = True


# ==============================================================================
# UNIT-EXPLICIT PARSING OF FUSION EXPRESSIONS / CAM PARAMETERS
# ==============================================================================

_NUM = r'[-+]?(?:\d+\.?\d*|\.\d+)'
_LEN_TOKEN_RE = re.compile(r'(?<![A-Za-z_])(millimeters?|millimetres?|inches|inch|mm|in)(?![A-Za-z_])|"', re.IGNORECASE)
_FEED_RE = re.compile(r'^\s*(' + _NUM + r')\s*(in\s*/\s*min|ipm|mm\s*/\s*min|mmpm)?\s*$', re.IGNORECASE)
_RPM_RE = re.compile(r'^\s*(' + _NUM + r')\s*(rpm|r\s*/\s*min)?\s*$', re.IGNORECASE)


def _is_metric_unit(unit):
    u = str(unit or "").strip().lower()
    return u.startswith("mm") or u.startswith("milli")


def _length_units_in(expr):
    found = set()
    for m in _LEN_TOKEN_RE.finditer(expr):
        found.add('mm' if m.group(0).lower().startswith(('mm', 'milli')) else 'in')
    return found


def parse_length_expr_to_inches(expr, default_unit="in"):
    """Evaluate a Fusion length expression to inches. An explicit unit token in the
    expression wins; only a unit-less expression uses `default_unit` (the document unit).
    Raises ValueError if it cannot be evaluated or mixes units."""
    if expr is None:
        raise ValueError("no expression")
    s = str(expr).strip()
    units = _length_units_in(s)
    if len(units) > 1:
        raise ValueError(f"mixed units in {s!r}")
    unit = next(iter(units)) if units else ('mm' if _is_metric_unit(default_unit) else 'in')
    val = safe_eval_length(s)
    return val / 25.4 if unit == 'mm' else val


def parse_feed_expr_to_ipm(expr, doc_unit="in"):
    """'250 in/min' -> 250, '6350 mm/min' -> 250. A unit-less number uses the document unit."""
    m = _FEED_RE.match(str(expr) if expr is not None else "")
    if not m:
        raise ValueError(f"cannot parse feed {expr!r}")
    val = float(m.group(1))
    unit = re.sub(r'\s+', '', (m.group(2) or '')).lower()
    metric = unit.startswith('mm') if unit else _is_metric_unit(doc_unit)
    return val / 25.4 if metric else val


def parse_rpm_expr(expr):
    m = _RPM_RE.match(str(expr) if expr is not None else "")
    if not m:
        raise ValueError(f"cannot parse spindle speed {expr!r}")
    return float(m.group(1))


def _numeric_param_value(p):
    try:
        v = p.value.value
        if isinstance(v, (int, float)) and not isinstance(v, bool):
            return float(v)
    except Exception:
        pass
    return None


def parse_cam_param_to_inches(p, default=0.0, doc_unit="in"):
    """Length CAM parameter -> inches. Fusion stores evaluated lengths in cm (database unit),
    which is unit-independent; otherwise the expression is parsed by its explicit unit tokens."""
    if not p:
        return default
    val_cm = _numeric_param_value(p)
    if val_cm is not None and val_cm > 0:
        return val_cm / 2.54
    try:
        expr = getattr(p, 'expression', None)
        if expr:
            return parse_length_expr_to_inches(expr, doc_unit)
    except ValueError:
        pass
    return default


def parse_cam_feed_to_ipm(p, doc_unit="in"):
    """Feed CAM parameter -> IPM using the expression's explicit unit. Falls back to the
    evaluated value (Fusion database unit cm/s) only when the expression is not a plain number."""
    if not p:
        return 0.0
    expr = getattr(p, 'expression', None)
    if expr:
        try:
            return parse_feed_expr_to_ipm(expr, doc_unit)
        except ValueError:
            pass
    v = _numeric_param_value(p)
    if v is not None and v > 0:
        ipm = v / 25.4  # Fusion's evaluated feed is mm/min (confirmed: '19.2774in/min' -> 489.647)
        if ipm > MAX_PLAUSIBLE_IPM:
            _log(f"Feed expression {expr!r}: evaluated {v!r} -> {ipm:.1f} IPM is implausible; ignoring (server will compute)")
            return 0.0
        _log(f"Feed expression {expr!r}: evaluated {v!r} mm/min -> {ipm:.1f} IPM")
        return ipm
    return 0.0


# Guards for Fusion evaluated values whose internal units are not confirmed.
MAX_PLAUSIBLE_RPM = 30000.0   # used only when the server's machine max RPM is unknown
_machine_max_rpm = None       # set from /api/data "machine.max_rpm" by load_materials()


def _rpm_ceiling():
    return _machine_max_rpm * 1.05 if _machine_max_rpm else MAX_PLAUSIBLE_RPM
MAX_PLAUSIBLE_IPM = 2000.0


def parse_cam_rpm(p):
    """Spindle-speed CAM parameter -> RPM using the expression. Falls back to the evaluated
    value (plain RPM - confirmed in Fusion 2026-09-30: the default formula resolving to 5000rpm
    evaluates to 5000.0) only when the expression is not a plain number."""
    if not p:
        return 0.0
    expr = getattr(p, 'expression', None)
    if expr:
        try:
            return parse_rpm_expr(expr)
        except ValueError:
            pass
    v = _numeric_param_value(p)
    if v is not None and v > 0:
        rpm = v
        if not (1.0 <= rpm <= _rpm_ceiling()):
            _log(f"Spindle expression {expr!r}: evaluated {v!r} -> {rpm:.0f} RPM is implausible; ignoring (server will compute)")
            return 0.0
        _log(f"Spindle expression {expr!r}: evaluated {v!r} RPM")
        return rpm
    return 0.0


def format_cutter_type(raw_type, desc=""):
    """Normalizes cutter types into clean, readable labels (e.g. Flat End Mill, T-Slot Cutter, Chamfer Mill)"""
    t_str = (raw_type or "").lower().replace('_', ' ').replace('-', ' ').strip()
    d_str = (desc or "").lower()
    
    if "chamfer" in t_str or "chamfer" in d_str:
        return "Chamfer Mill"
    elif "t-slot" in t_str or "t slot" in t_str or "tslot" in t_str or "tslot" in d_str:
        return "T-Slot Cutter"
    elif "dovetail" in t_str or "dovetail" in d_str:
        return "Dovetail Cutter"
    elif "thread" in t_str or "thread" in d_str:
        return "Thread Mill"
    elif "ball" in t_str or "ball" in d_str:
        return "Ball End Mill"
    elif "bull" in t_str or "bull" in d_str or "corner rad" in d_str:
        return "Bull Nose Mill"
    elif "face" in t_str or "face" in d_str:
        return "Face Mill"
    elif "slot" in t_str or "slot" in d_str:
        return "Slot Mill"
    elif "flat" in t_str or "end mill" in t_str or "endmill" in d_str:
        return "Flat End Mill"
    elif t_str:
        return t_str.title()
    return "Flat End Mill"

def extract_tool_number(op, t_dict=None):
    """Extracts the tool number from tool JSON, tool object, or operation CAMParameters.
    Returns None when the number is unknown (never 0 or 1 as a guess)."""
    # 1. Tool JSON dictionary (authoritative definition from library)
    if t_dict and isinstance(t_dict, dict):
        post = (
            t_dict.get("post-process")
            or t_dict.get("postProcess")
            or t_dict.get("post_process")
            or {}
        )
        if isinstance(post, dict):
            num = post.get("number")
            if num is not None:
                try:
                    val = int(num)
                    if val > 0:
                        return val
                except Exception:
                    pass
        if "number" in t_dict:
            try:
                val = int(t_dict["number"])
                if val > 0:
                    return val
            except Exception:
                pass

    # 2. Direct property or JSON on tool object
    if op and hasattr(op, 'tool') and op.tool:
        try:
            if hasattr(op.tool, 'number'):
                val = int(op.tool.number)
                if val > 0:
                    return val
        except Exception:
            pass
        if not t_dict and hasattr(op.tool, 'toJson'):
            try:
                raw_json = op.tool.toJson()
                tj = json.loads(raw_json)
                post = tj.get("post-process") or tj.get("postProcess") or {}
                if isinstance(post, dict) and post.get("number") is not None:
                    val = int(post.get("number"))
                    if val > 0:
                        return val
            except Exception:
                pass

    # 3. Operation CAM parameters (fallback)
    if op and hasattr(op, 'parameters') and op.parameters:
        for p_name in ['tool_number', 'tool_toolNumber', 'toolNumber']:
            try:
                p = op.parameters.itemByName(p_name)
                if p:
                    if hasattr(p, 'value') and hasattr(p.value, 'value') and p.value.value is not None:
                        try:
                            val = int(float(p.value.value))
                            if val > 0:
                                return val
                        except Exception:
                            pass
                    if getattr(p, 'expression', None):
                        try:
                            m = re.search(r'(\d+)', str(p.expression))
                            if m:
                                val = int(m.group(1))
                                if val > 0:
                                    return val
                        except Exception:
                            pass
            except Exception:
                pass

    return None

def tool_label(t_num):
    return f"T{t_num}" if t_num is not None and t_num > 0 else "T? (no tool number)"


def describe_stickout(geo):
    """Human text for the stickout and where it came from."""
    src = geo.stickout_source
    if src == "default":
        ratio = geo.stickout / geo.diameter if geo.diameter else 0.0
        note = f"Auto {ratio:.2f}×D — verify"
    elif src == "fusion_LB":
        note = "Fusion LB"
    elif src == "fusion_gauge":
        note = "Fusion gauge length"
    else:
        note = "override"
    return f'Stickout {geo.stickout:.3f}" ({note})'


def get_op_tool_info(op):
    """Extracts tool metadata and geometry (inches) via toolwiz_common.ToolGeometry.
    Returns (geo_payload | None, summary_or_error_text, preset_names)."""
    if not op or not hasattr(op, 'tool') or not op.tool:
        return None, "No Tool Found", []

    try:
        t = op.tool
        raw_json = t.toJson()
        t_dict = json.loads(raw_json)
        geo = ToolGeometry.from_fusion(t_dict)
    except UnitError as e:
        _log("Tool unit could not be determined", e)
        return None, f"Cannot read tool geometry: {e}. Set the tool's unit to inches or millimeters in Fusion.", []
    except Exception as e:
        _log("Tool geometry extraction failed", e)
        return None, f"Error extracting tool: {e}", []

    try:
        diameter = geo.diameter
        flutes = geo.flutes
        flute_length = geo.flute_length
        corner_radius = geo.corner_radius
        desc = t_dict.get("description", f"{diameter:.3f}in Endmill")
        t_num = extract_tool_number(op, t_dict)
        raw_type = t_dict.get("type", "")
        cutter_type = format_cutter_type(raw_type, desc)

        presets = t_dict.get("start-values", {}).get("presets", [])
        preset_names = [p.get("name", "Unnamed Preset") for p in presets if p.get("name")]

        desc_lower = desc.lower()
        bmc_lower = str(t_dict.get("BMC", "")).lower()
        grade_lower = str(t_dict.get("GRADE", "")).lower()
        text_all = f"{desc_lower} {bmc_lower} {grade_lower}"

        detected_coating = "AlTiN" if ("carbide" in bmc_lower or "carbide" in desc_lower) else "Uncoated"
        if "altin" in text_all:
            detected_coating = "AlTiN"
        elif "tialn" in text_all:
            detected_coating = "TiAlN"
        elif "ticn" in text_all:
            detected_coating = "TiCN"
        elif "tin" in text_all:
            detected_coating = "TiN"
        elif "zrn" in text_all:
            detected_coating = "ZrN"
        elif "dlc" in text_all or "diamond" in text_all:
            detected_coating = "Diamond"
        elif "uncoated" in text_all or "bright" in text_all:
            detected_coating = "Uncoated"

        is_carbide = ("carbide" in bmc_lower or "carbide" in desc_lower or "generic" in grade_lower)

        geo_payload = {
            "diameter": diameter,
            "flutes": flutes,
            "fluteLength": flute_length,
            "shankDiameter": geo.shank_diameter,
            "cornerRadius": corner_radius,
            "stickout": geo.stickout,
            "stickoutSource": geo.stickout_source,
            "coating": detected_coating,
            "is_carbide": is_carbide,
            "geometry": "Square" if corner_radius == 0 else "Bullnose / Radiused",
            "desc": desc,
            "number": t_num,
            "tool_type": cutter_type,
            "raw_json": raw_json
        }

        dia_mm = diameter * 25.4
        fl_mm = flute_length * 25.4
        summary = (
            f"{tool_label(t_num)}: {desc} | {cutter_type} | Dia: {diameter:.3f}\" ({dia_mm:.2f}mm), "
            f"{flutes} Flutes, Flute L: {flute_length:.3f}\" ({fl_mm:.1f}mm)\n"
            f"{describe_stickout(geo)}"
        )
        return geo_payload, summary, preset_names
    except Exception as e:
        _log("Tool info formatting failed", e)
        return None, f"Error extracting tool: {e}", []

def apply_param(op, name, expr_str, force=False):
    """Safely updates a single CAMParameter on an Operation. Returns True if written."""
    try:
        p = op.parameters.itemByName(name)
        if p and (p.isEnabled or force):
            p.expression = str(expr_str)
            return True
    except Exception as e:
        _log(f"Could not set CAM parameter {name!r} = {expr_str!r}", e)
    return False

# ==============================================================================
# COMMAND 1: EXPORT DIGITAL TWIN
# ==============================================================================

class ToolWizExportExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            eventArgs = adsk.core.CommandEventArgs.cast(args)
            inputs = eventArgs.command.commandInputs
            lib_select = inputs.itemById('libSelect')
            if not lib_select:
                ui.messageBox('Please select library items to export.')
                return
                
            selected_items = [item.name for item in lib_select.listItems if item.isSelected]
            if not selected_items:
                ui.messageBox('Please check at least one library to export.')
                return

            merge_input = inputs.itemById('mergeIntoMaster')
            dedup_input = inputs.itemById('autoDeduplicate')
            merge_into_master = merge_input.value if merge_input else True
            auto_dedup = dedup_input.value if dedup_input else True

            libraries_payload = []
            total_extracted_tools = 0

            for selected_name in selected_items:
                lib_info = discovered_libraries_map.get(selected_name)
                if not lib_info:
                    continue
                    
                tools_json_list = []
                if lib_info["type"] == "document":
                    camObj = adsk.cam.CAM.cast(app.activeDocument.products.itemByProductType('CAMProductType'))
                    seen_tools = set()
                    if camObj:
                        for setup in camObj.setups:
                            for op in setup.allOperations:
                                if hasattr(op, 'tool') and op.tool:
                                    t_json = op.tool.toJson()
                                    t_dict = json.loads(t_json)
                                    t_desc = t_dict.get("description", "")
                                    t_num = extract_tool_number(op, t_dict)
                                    key = f"{t_num}_{t_desc}"
                                    if key not in seen_tools:
                                        seen_tools.add(key)
                                        tools_json_list.append(t_dict)
                else:
                    lib_obj = lib_info.get("obj")
                    if lib_obj:
                        for i in range(lib_obj.count):
                            t = lib_obj.item(i)
                            tools_json_list.append(json.loads(t.toJson()))

                if tools_json_list:
                    total_extracted_tools += len(tools_json_list)
                    libraries_payload.append({
                        "library_name": selected_name,
                        "tools": tools_json_list
                    })

            if not libraries_payload:
                ui.messageBox("No tools found in the selected libraries to export.")
                return

            if len(libraries_payload) > 1 or merge_into_master:
                payload = {
                    "libraries": libraries_payload,
                    "master_library_name": "Master_Shop_Tool_Crib",
                    "deduplicate": auto_dedup
                }
            else:
                payload = {
                    "library_name": libraries_payload[0]["library_name"],
                    "tools": libraries_payload[0]["tools"],
                    "deduplicate": auto_dedup
                }

            # Post to ToolWiz server
            try:
                res_data = _http_json('/api/twin/export_receive', payload, timeout=30.0)
            except (urllib.error.URLError, OSError, ValueError):
                if ui:
                    ui.messageBox(_offline_message("export tool libraries"), "Tool Wizard Server Offline")
                return

            if res_data.get("success"):
                lib_display_name = res_data.get("library_name", "Master_Shop_Tool_Crib")
                final_count = res_data.get("tool_count", total_extracted_tools)
                backup_name = res_data.get("backup", {}).get("filename", "")
                
                dedup_info = ""
                summary = res_data.get("summary") or res_data.get("report") or {}
                if summary.get("duplicates_removed", 0) > 0:
                    dedup_info = f"Duplicates Removed & Merged: {summary.get('duplicates_removed')}\n"

                msg = (
                    f"Tool Libraries Exported Successfully!\n"
                    f"====================================\n"
                    f"Target Library: {lib_display_name}\n"
                    f"Libraries Processed: {len(libraries_payload)}\n"
                    f"Total Unique Tools: {final_count}\n"
                    f"{dedup_info}"
                    f"Backup Snapshot: {backup_name}\n\n"
                    f"Next Steps:\n"
                    f"1. Open {SERVER_BASE_URL} in your browser.\n"
                    f"2. Switch to 'Digital Twin Library Manager'.\n"
                    f"3. Select material & tweak aggressiveness per tool or material.\n"
                    f"4. Click 'Import Digital Twin' in Fusion when done."
                )
                ui.messageBox(msg, 'ToolWiz Digital Twin Export')
            else:
                ui.messageBox(f"Export failed: {res_data.get('error')}")
                
        except Exception as e:
            _report_error("Digital Twin Export failed.", e)

class ToolWizExportCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            cmd = args.command
            cmd.isExecutedWhenPreEmpted = False
            cmd.isRepeatable = False
            cmd.isAutoExecute = False
            onExecute = ToolWizExportExecuteHandler()
            cmd.execute.add(onExecute)
            handlers.append(onExecute)
            
            inputs = cmd.commandInputs
            global discovered_libraries_map
            discovered_libraries_map.clear()
            
            camMgr = adsk.cam.CAMManager.get()
            toolLibs = camMgr.libraryManager.toolLibraries
            
            # 1. Cloud Libraries
            try:
                cloud_url = toolLibs.urlByLocation(adsk.cam.LibraryLocations.CloudLibraryLocation)
                if cloud_url:
                    child_urls = toolLibs.childAssetURLs(cloud_url)
                    for i in range(child_urls.count if hasattr(child_urls, 'count') else len(child_urls)):
                        u = child_urls.item(i) if hasattr(child_urls, 'item') else child_urls[i]
                        lib = toolLibs.toolLibraryAtUrl(u)
                        if lib:
                            name = f"Cloud: {u.leafPath if hasattr(u, 'leafPath') else u.toString()}"
                            discovered_libraries_map[name] = {"type": "cloud", "url": u, "obj": lib}
            except Exception as e:
                _log("Cloud tool library discovery failed", e)
                
            # 2. Local Libraries
            try:
                local_url = toolLibs.urlByLocation(adsk.cam.LibraryLocations.LocalLibraryLocation)
                if local_url:
                    child_urls = toolLibs.childAssetURLs(local_url)
                    for i in range(child_urls.count if hasattr(child_urls, 'count') else len(child_urls)):
                        u = child_urls.item(i) if hasattr(child_urls, 'item') else child_urls[i]
                        lib = toolLibs.toolLibraryAtUrl(u)
                        if lib:
                            name = f"Local: {u.leafPath if hasattr(u, 'leafPath') else u.toString()}"
                            discovered_libraries_map[name] = {"type": "local", "url": u, "obj": lib}
            except Exception as e:
                _log("Local tool library discovery failed", e)
                
            # 3. Active Document Tools (Always accessible)
            discovered_libraries_map["Active Document: All Tools in Use"] = {"type": "document", "obj": None}
            
            lib_select = inputs.addDropDownCommandInput('libSelect', 'Select Libraries to Export', adsk.core.DropDownStyles.CheckBoxDropDownStyle)
            for i, name in enumerate(discovered_libraries_map.keys()):
                lib_select.listItems.add(name, i == 0)

            inputs.addBoolValueCommandInput('mergeIntoMaster', 'Merge into Master Tool Crib', True, '', True)
            inputs.addBoolValueCommandInput('autoDeduplicate', 'Deduplicate Identical Cutters', True, '', True)
                
            info = inputs.addTextBoxCommandInput('info', '', 'Select one or more libraries above. ToolWiz will consolidate your cutters, combine unique cutting presets, and eliminate redundant duplicates.', 3, True)
            info.isFullWidth = True
            
        except Exception as e:
            _report_error("Command Created failed.", e)

# ==============================================================================
# COMMAND 2: IMPORT DIGITAL TWIN
# ==============================================================================

class ToolWizImportExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            # Fetch latest mutated library JSON from ToolWiz server
            try:
                res_data = _http_json('/api/twin/get_import_payload', timeout=30.0)
            except (urllib.error.URLError, OSError, ValueError):
                if ui:
                    ui.messageBox(_offline_message("import tool libraries"), "Tool Wizard Server Offline")
                return
            
            if not res_data.get("success") or not res_data.get("library"):
                ui.messageBox("No modified Digital Twin library found on ToolWiz server.\nPlease generate presets in ToolWiz first.")
                return
                
            library_data = res_data["library"]
            lib_name = library_data.get("library_name", "ToolWiz_Twin_Library")
            tools_list = library_data.get("tools", [])
            
            if not tools_list:
                ui.messageBox("The Digital Twin library has 0 tools.")
                return
                
            # Save local staging copy
            local_appdata = os.environ.get('APPDATA', '')
            staging_dir = os.path.join(local_appdata, 'Autodesk', 'CAM360', 'libraries', 'Local')
            os.makedirs(staging_dir, exist_ok=True)
            staging_file = os.path.join(staging_dir, f"{lib_name.replace(':', '_')}.json")
            
            with open(staging_file, "w", encoding="utf-8") as f:
                json.dump({"data": tools_list}, f, indent=2)
                
            msg = (
                f"Digital Twin Ready for Synchronization!\n"
                f"====================================\n"
                f"Library: {lib_name}\n"
                f"Tools Processed: {len(tools_list)}\n\n"
                f"The updated library has been saved to your Fusion Local Libraries directory:\n"
                f"📂 {staging_file}\n\n"
                f"Your tools now contain all material presets (Roughing, Adaptive, Finishing, Slotting) in their Cutting Data tab!"
            )
            ui.messageBox(msg, 'ToolWiz Digital Twin Import')
            
        except Exception as e:
            _report_error("Digital Twin Import failed.", e)

class ToolWizImportCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            cmd = args.command
            cmd.isExecutedWhenPreEmpted = False
            cmd.isRepeatable = False
            cmd.isAutoExecute = False
            onExecute = ToolWizImportExecuteHandler()
            cmd.execute.add(onExecute)
            handlers.append(onExecute)
        except Exception as e:
            _report_error("Command Created failed.", e)

# ==============================================================================
# COMMAND 3: FAST CAM OPERATION AUTO-SETTER
# ==============================================================================

def confirm_feasibility(calc_result):
    """Return True if it is OK to apply the result. When the server reports
    "feasible": false, ask the user (Yes/No). A missing field counts as feasible."""
    if not isinstance(calc_result, dict) or calc_result.get("feasible", True) is not False:
        return True
    limited = calc_result.get("limited_by") or "an unspecified limit"
    if isinstance(limited, (list, tuple)):
        limited = ", ".join(str(x) for x in limited)
    res = ui.messageBox(
        f"No safe cut found — limited by {limited}. Apply anyway?",
        "ToolWiz — No Safe Cut Found",
        adsk.core.MessageBoxButtonTypes.YesNoButtonType,
        adsk.core.MessageBoxIconTypes.WarningIconType
    )
    return res == adsk.core.DialogResults.DialogYes


def build_calc_payload(geo_payload, family, alloy, strategy, aggressiveness, selected_grade, selected_coating_raw):
    """Build the /api/calculate_for_fusion request body (all lengths in inches)."""
    coat = selected_coating_raw.lower()
    coating_code = "AlTiN"
    if "tialn" in coat:
        coating_code = "TiAlN"
    elif "altin" in coat:
        coating_code = "AlTiN"
    elif "ticn" in coat:
        coating_code = "TiCN"
    elif "tin" in coat:
        coating_code = "TiN"
    elif "zrn" in coat:
        coating_code = "ZrN"
    elif "dlc" in coat or "diamond" in coat:
        coating_code = "Diamond"
    elif "uncoated" in coat or "bright" in coat:
        coating_code = "Uncoated"

    is_bullnose = geo_payload.get("cornerRadius", 0.0) > 0.001
    grade = selected_grade.lower()
    if "hp" in grade or "high performance" in grade:
        tool_category = "HP Carbide Bull Nose Endmill" if is_bullnose else "HP Carbide Endmill"
    elif "hss" in grade:
        tool_category = "HSS Endmill"
    elif "cobalt" in grade:
        tool_category = "Cobalt Endmill"
    else:
        tool_category = "Carbide Bull Nose Endmill" if is_bullnose else "Carbide Endmill"

    return {
        "family": family, "alloy": alloy, "operation": strategy, "aggressiveness": aggressiveness,
        "tool": tool_category, "coating": coating_code,
        "diameter": geo_payload["diameter"], "flutes": geo_payload["flutes"], "fluteLength": geo_payload["fluteLength"],
        "shankDiameter": geo_payload["shankDiameter"], "cornerRadius": geo_payload["cornerRadius"],
        "stickout": geo_payload["stickout"], "geometry": geo_payload["geometry"]
    }


def run_autoset(target_op, op_name, family, alloy, strategy, aggressiveness,
                target_preset_to_replace, selected_grade, selected_coating_raw):
    """Calculate cutting data on the server and write it to the operation's tool preset."""
    geo_payload, summary_str, existing_presets = get_op_tool_info(target_op)
    if not geo_payload:
        ui.messageBox(f'Could not read tool geometry: {summary_str}')
        return False

    t_num = geo_payload.get("number")
    if t_num is None:
        ui.messageBox(
            "The tool used by this operation has no tool number, so ToolWiz cannot tell which tool to update.\n\n"
            "Assign a tool number in Fusion (Tool dialog > Post Process tab) and run this command again.\n"
            "ToolWiz never changes tool numbers or offsets.",
            "ToolWiz CAM Auto-Setter"
        )
        return False

    payload = build_calc_payload(geo_payload, family, alloy, strategy, aggressiveness, selected_grade, selected_coating_raw)

    try:
        calc_result = _http_json('/api/calculate_for_fusion', payload, timeout=10.0)
    except (urllib.error.URLError, OSError, ValueError):
        if ui:
            ui.messageBox(_offline_message("calculate speeds & feeds"), "Tool Wizard Server Offline")
        return False

    if not calc_result.get("success"):
        ui.messageBox(f"ToolWiz Calculation Error: {calc_result.get('error')}")
        return False

    if not confirm_feasibility(calc_result):
        return False

    material_label = alloy if alloy else family
    calc_result["name"] = f"{material_label} - {strategy}"
    calc_result["material_query"] = material_label
    calc_result["material_category"] = "metal"
    calc_result["flutes"] = geo_payload.get("flutes", 4)

    rpm = calc_result.get("rpm", 5000)
    feed = calc_result.get("feed", 30.0)
    doc = calc_result.get("doc", 0.25)
    woc = calc_result.get("woc", 0.05)
    ramp_feed = calc_result.get("ramp_feed", feed * 0.5)
    plunge_feed = calc_result.get("plunge_feed", feed * 0.25)
    if plunge_feed <= 0:
        plunge_feed = ramp_feed if ramp_feed > 0 else (feed * 0.25 if feed > 0 else 5.0)
    if ramp_feed <= 0:
        ramp_feed = feed * 0.5 if feed > 0 else 10.0
    sfm = calc_result.get("sfm", 300)
    ipt = calc_result.get("ipt", 0.002)

    # Mutate tool JSON (preset injection only; tool number / offsets are never touched)
    mutated_json, final_preset_name, was_updated = json_mutator.mutate_tool_json(
        geo_payload["raw_json"], calc_result, target_preset_to_replace=target_preset_to_replace
    )

    # Re-instantiate Tool with the mutated JSON and assign to operation & library
    tool_updated = False
    new_tool = None
    try:
        if hasattr(adsk, 'cam') and hasattr(adsk.cam, 'Tool') and hasattr(adsk.cam.Tool, 'createFromJson'):
            new_tool = adsk.cam.Tool.createFromJson(mutated_json)
            if new_tool:
                target_op.tool = new_tool
                tool_updated = True
    except Exception as ex_tool:
        _log("Tool.createFromJson / assigning tool to operation failed", ex_tool)

    # Fallback to direct tool presets collection manipulation if createFromJson was not used
    if not tool_updated:
        try:
            cur_tool = getattr(target_op, 'tool', None)
            if cur_tool and hasattr(cur_tool, 'presets'):
                target_preset = None
                if target_preset_to_replace and target_preset_to_replace != "+ Create New Preset (Auto-Named)":
                    for pr in cur_tool.presets:
                        if pr.name == target_preset_to_replace:
                            target_preset = pr
                            break
                if not target_preset:
                    for pr in cur_tool.presets:
                        if pr.name == final_preset_name:
                            target_preset = pr
                            break
                if not target_preset:
                    target_preset = cur_tool.presets.add()
                if target_preset:
                    target_preset.name = final_preset_name
                    if hasattr(target_preset, 'parameters') and target_preset.parameters:
                        for p_name, p_val in [
                            ('tool_spindleSpeed', f"{rpm} rpm"),
                            ('tool_spindleSpeedRamp', f"{rpm} rpm"),
                            ('tool_feedCutting', f"{feed:.2f} in/min"),
                            ('tool_feedEntry', f"{feed:.2f} in/min"),
                            ('tool_feedExit', f"{feed:.2f} in/min"),
                            ('tool_feedRamp', f"{ramp_feed:.2f} in/min"),
                            ('tool_feedPlunge', f"{plunge_feed:.2f} in/min"),
                            ('tool_feedTransition', f"{feed * 1.5:.2f} in/min")
                        ]:
                            try:
                                p_obj = target_preset.parameters.itemByName(p_name)
                                if p_obj:
                                    p_obj.expression = p_val
                            except Exception as ex_p:
                                _log(f"Could not set preset parameter {p_name!r}", ex_p)
                    target_op.tool = cur_tool
                    tool_updated = True
        except Exception as ex_preset:
            _log("Direct preset manipulation failed", ex_preset)

    # Activate the newly created / updated preset on the operation
    preset_linked = False
    try:
        active_tool = getattr(target_op, 'tool', None)
        if active_tool and hasattr(active_tool, 'presets'):
            for pr in active_tool.presets:
                if pr.name == final_preset_name:
                    try:
                        target_op.toolPreset = pr
                        preset_linked = True
                    except Exception as ex_set:
                        _log("Could not activate preset on operation", ex_set)
                    break
    except Exception as ex_link:
        _log("Preset link step failed", ex_link)

    # Update Document Tool Library if accessible
    try:
        cam_prod = app.activeDocument.products.itemByProductType('CAMProductType')
        if cam_prod:
            cam_obj = adsk.cam.CAM.cast(cam_prod)
            if cam_obj and hasattr(cam_obj, 'documentToolLibrary') and cam_obj.documentToolLibrary:
                doc_lib = cam_obj.documentToolLibrary
                if hasattr(doc_lib, 'update') and target_op.tool:
                    doc_lib.update(target_op.tool, False)
    except Exception as ex_doclib:
        _log("Document tool library update failed", ex_doclib)

    applied = [
        f"Spindle Speed: {rpm:,} RPM ({sfm:.1f} SFM)",
        f"Cutting Feed: {feed:.2f} in/min ({ipt:.4f} IPT)"
    ]

    # Explicitly apply feeds & speeds as operation parameter values so the active toolpath uses them
    apply_param(target_op, 'tool_spindleSpeed', f"{rpm} rpm")
    apply_param(target_op, 'tool_spindleSpeedRamp', f"{rpm} rpm", force=True)
    apply_param(target_op, 'tool_feedCutting', f"{feed:.2f} in/min")
    apply_param(target_op, 'tool_feedEntry', f"{feed:.2f} in/min", force=True)
    apply_param(target_op, 'tool_feedExit', f"{feed:.2f} in/min", force=True)
    apply_param(target_op, 'tool_feedRamp', f"{ramp_feed:.2f} in/min", force=True)
    apply_param(target_op, 'tool_feedPlunge', f"{plunge_feed:.2f} in/min", force=True)
    apply_param(target_op, 'tool_feedTransition', f"{feed * 1.5:.2f} in/min", force=True)

    # Apply operation-specific cut step parameters (not stored in tool presets)
    if "Adaptive" in strategy:
        if apply_param(target_op, 'optimalLoad', f"{woc:.4f} in"):
            applied.append(f"Optimal Load (WOC): {woc:.4f} in")
    else:
        if apply_param(target_op, 'stepover', f"{woc:.4f} in") or apply_param(target_op, 'maximumStepover', f"{woc:.4f} in"):
            applied.append(f"Stepover (WOC): {woc:.4f} in")

    if apply_param(target_op, 'maximumStepdown', f"{doc:.4f} in"):
        applied.append(f"Max Stepdown (DOC): {doc:.4f} in")

    action_desc = "Updated in-place" if was_updated else "Created new preset"
    link_desc = "Linked as active preset" if preset_linked else ("Added to tool presets" if tool_updated else "Parameters applied")
    applied_summary = "\n".join([f" • {item}" for item in applied])
    t_disp = tool_label(t_num)
    msg = (
        f"Tool Cutting Data & Preset Applied!\n"
        f"====================================\n"
        f"Tool: {t_disp} ({geo_payload.get('desc', 'Endmill')})\n"
        f"Material: {material_label}\n"
        f"Preset: {final_preset_name}\n"
        f"Status: {action_desc} ({link_desc})\n"
        f"Target Operation: {op_name}\n\n"
        f"{applied_summary}\n\n"
        f"Ramp Feed: {ramp_feed:.2f} in/min | Plunge Feed: {plunge_feed:.2f} in/min\n\n"
        f"This preset is now attached to Tool {t_disp}'s Cutting Data tab for use across your entire document."
    )
    ui.messageBox(msg, 'ToolWiz CAM Auto-Setter')
    return True


class ToolWizExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            eventArgs = adsk.core.CommandEventArgs.cast(args)
            inputs = eventArgs.command.commandInputs

            if not materials_ready():
                ui.messageBox(_materials.get("notice") or "Material list unavailable. Calculation is disabled.",
                              "ToolWiz")
                return

            op_input = inputs.itemById('targetOp')
            preset_action_input = inputs.itemById('presetAction')
            grade_input = inputs.itemById('toolGrade')
            coat_input = inputs.itemById('toolCoating')
            family_input = inputs.itemById('matFamily')
            alloy_input = inputs.itemById('matAlloy')
            strat_input = inputs.itemById('strategy')
            agg_input = inputs.itemById('aggressiveness')

            if not op_input or not family_input or not strat_input or not agg_input:
                ui.messageBox('Error: Dialog inputs could not be read.')
                return

            op_name = op_input.selectedItem.name if op_input.selectedItem else ""
            target_op = available_ops_map.get(op_name)
            if not target_op:
                ui.messageBox('No valid CAM operation selected!')
                return

            if not family_input.selectedItem:
                ui.messageBox('Please select a material family.')
                return
            family = family_input.selectedItem.name
            alloy = alloy_input.selectedItem.name if (alloy_input and alloy_input.selectedItem) else ""
            strategy = strat_input.selectedItem.name if strat_input.selectedItem else "Adaptive Roughing"
            aggressiveness = agg_input.valueOne

            preset_choice = preset_action_input.selectedItem.name if (preset_action_input and preset_action_input.selectedItem) else "+ Create New Preset (Auto-Named)"
            target_preset_to_replace = preset_choice.replace("Replace: ", "").strip() if preset_choice.startswith("Replace: ") else None

            selected_grade = grade_input.selectedItem.name if (grade_input and grade_input.selectedItem) else "HP High Performance Carbide"
            selected_coating_raw = coat_input.selectedItem.name if (coat_input and coat_input.selectedItem) else "AlTiN (Black)"

            run_autoset(target_op, op_name, family, alloy, strategy, aggressiveness,
                        target_preset_to_replace, selected_grade, selected_coating_raw)

        except Exception as e:
            _report_error("Auto-Setter failed.", e)

class ToolWizInputChangedHandler(adsk.core.InputChangedEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            eventArgs = adsk.core.InputChangedEventArgs.cast(args)
            inputs = eventArgs.inputs
            cmdInput = eventArgs.input
            
            if cmdInput.id == 'targetOp':
                op_name = cmdInput.selectedItem.name if cmdInput.selectedItem else ""
                target_op = available_ops_map.get(op_name)
                tool_info_box = inputs.itemById('toolInfo')
                preset_action_input = inputs.itemById('presetAction')
                grade_input = inputs.itemById('toolGrade')
                coat_input = inputs.itemById('toolCoating')
                strat_input = inputs.itemById('strategy')
                if target_op:
                    g_payload, summary_str, existing_presets = get_op_tool_info(target_op)
                    if tool_info_box: tool_info_box.text = summary_str
                    if preset_action_input:
                        preset_action_input.listItems.clear()
                        preset_action_input.listItems.add("+ Create New Preset (Auto-Named)", True)
                        for p in existing_presets:
                            preset_action_input.listItems.add(f"Replace: {p}", False)
                    if g_payload:
                        det_c = g_payload.get("coating", "AlTiN")
                        if coat_input:
                            for itm in coat_input.listItems:
                                itm.isSelected = (det_c.lower() in itm.name.lower())
                        if grade_input:
                            is_carb = g_payload.get("is_carbide", True)
                            for itm in grade_input.listItems:
                                if is_carb and "HP" in itm.name:
                                    itm.isSelected = True
                                elif not is_carb and "HSS" in itm.name:
                                    itm.isSelected = True
                    if strat_input and hasattr(target_op, 'strategy'):
                        op_strat = str(target_op.strategy).lower()
                        for itm in strat_input.listItems:
                            if 'adaptive' in op_strat and 'adaptive' in itm.name.lower():
                                itm.isSelected = True
                                break
                            elif ('face' in op_strat or 'facing' in op_strat) and 'facing' in itm.name.lower():
                                itm.isSelected = True
                                break
                            elif ('flat' in op_strat or 'horizontal' in op_strat) and 'floor' in itm.name.lower():
                                itm.isSelected = True
                                break
                            elif any(s in op_strat for s in ['scallop', 'parallel', 'morphed', 'ramp', 'flow']) and '3d' in itm.name.lower():
                                itm.isSelected = True
                                break
                            elif any(s in op_strat for s in ['contour', 'trace']) and itm.name.lower() == 'finishing':
                                itm.isSelected = True
                                break
                            elif 'pocket' in op_strat and itm.name.lower() == 'roughing':
                                itm.isSelected = True
                                break
                            
            elif cmdInput.id == 'matFamily':
                family = cmdInput.selectedItem.name if cmdInput.selectedItem else ""
                alloy_input = inputs.itemById('matAlloy')
                if alloy_input:
                    alloy_input.listItems.clear()
                    alloys = alloys_for(family)
                    if not alloys:
                        alloy_input.listItems.add("Standard Grade", True)
                    else:
                        for i, a in enumerate(alloys):
                            alloy_input.listItems.add(a, True if i == 0 else False)
        except Exception as e:
            _log("Speeds & Feeds input-changed handler failed", e)

class ToolWizCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            cmd = args.command
            cmd.isExecutedWhenPreEmpted = False
            cmd.isRepeatable = False
            cmd.isAutoExecute = False
            onExecute = ToolWizExecuteHandler()
            cmd.execute.add(onExecute)
            handlers.append(onExecute)
            
            onInputChanged = ToolWizInputChangedHandler()
            cmd.inputChanged.add(onInputChanged)
            handlers.append(onInputChanged)
            
            inputs = cmd.commandInputs
            global available_ops_map
            available_ops_map.clear()
            
            camObj = adsk.cam.CAM.cast(app.activeDocument.products.itemByProductType('CAMProductType'))
            if not camObj:
                ui.messageBox('Please switch to the Manufacture (CAM) workspace with an active setup.')
                return
                
            preselect_op_name = None
            try:
                sel = ui.activeSelections
                if sel.count > 0:
                    ent = sel.item(0).entity
                    if ent.objectType == adsk.cam.Operation.classType():
                        parent_setup = ent.parent
                        setup_name = parent_setup.name if parent_setup else "Setup"
                        preselect_op_name = f"{setup_name} > {ent.name}"
            except:
                pass
                
            for setup in camObj.setups:
                for op in setup.allOperations:
                    if hasattr(op, 'tool') and op.tool:
                        op_label = f"{setup.name} > {op.name}"
                        available_ops_map[op_label] = op
                        if not preselect_op_name:
                            preselect_op_name = op_label
                            
            if not available_ops_map:
                ui.messageBox('No operations with tools found in active document.')
                return
                
            op_input = inputs.addDropDownCommandInput('targetOp', 'Target Operation', adsk.core.DropDownStyles.TextListDropDownStyle)
            for op_label in available_ops_map.keys():
                op_input.listItems.add(op_label, op_label == preselect_op_name)
                
            initial_op = available_ops_map.get(preselect_op_name)
            initial_geo, initial_summary, existing_presets = get_op_tool_info(initial_op)
            tool_info_box = inputs.addTextBoxCommandInput('toolInfo', 'Detected Tool', initial_summary, 3, True)
            tool_info_box.isFullWidth = True
            
            preset_input = inputs.addDropDownCommandInput('presetAction', 'Cutting Data Preset', adsk.core.DropDownStyles.TextListDropDownStyle)
            preset_input.listItems.add('+ Create New Preset (Auto-Named)', True)
            for p in existing_presets:
                preset_input.listItems.add(f"Replace: {p}", False)
                
            tool_grade_input = inputs.addDropDownCommandInput('toolGrade', 'Tool Performance Grade', adsk.core.DropDownStyles.TextListDropDownStyle)
            is_carbide = initial_geo.get("is_carbide", True) if initial_geo else True
            tool_grade_input.listItems.add('HP High Performance Carbide', is_carbide)
            tool_grade_input.listItems.add('Carbide (Standard)', False)
            tool_grade_input.listItems.add('High Speed Steel (HSS)', not is_carbide)
            tool_grade_input.listItems.add('Cobalt (M42)', False)

            tool_coating_input = inputs.addDropDownCommandInput('toolCoating', 'Tool Coating', adsk.core.DropDownStyles.TextListDropDownStyle)
            det_coat = initial_geo.get("coating", "AlTiN") if initial_geo else "AlTiN"
            coating_options = [
                ('AlTiN (Black)', 'AlTiN'),
                ('TiAlN (Dark Violet)', 'TiAlN'),
                ('TiN (Gold)', 'TiN'),
                ('TiCN', 'TiCN'),
                ('ZrN', 'ZrN'),
                ('Diamond / DLC', 'Diamond'),
                ('Uncoated / Bright', 'Uncoated')
            ]
            for label, code in coating_options:
                tool_coating_input.listItems.add(label, code.lower() == det_coat.lower())
            
            # Materials: one shared loader (server, then on-disk cache)
            load_materials()
            _add_materials_notice(inputs, 'materialsNotice')

            if materials_ready():
                families = _materials["families"]
                mat_input = inputs.addDropDownCommandInput('matFamily', 'Material Family', adsk.core.DropDownStyles.TextListDropDownStyle)
                default_family = "Steel - Tool (H13)" if "Steel - Tool (H13)" in families else families[0]
                for m in families:
                    mat_input.listItems.add(m, m == default_family)

                alloy_input = inputs.addDropDownCommandInput('matAlloy', 'Specific Alloy', adsk.core.DropDownStyles.TextListDropDownStyle)
                init_alloys = alloys_for(default_family) or ["Standard Grade"]
                for i, a in enumerate(init_alloys):
                    alloy_input.listItems.add(a, i == 0)

            strat_input = inputs.addDropDownCommandInput('strategy', 'Strategy', adsk.core.DropDownStyles.TextListDropDownStyle)
            op_strat = str(getattr(initial_op, 'strategy', '')).lower() if initial_op else ""
            default_strat = 'Adaptive Roughing'
            if 'adaptive' in op_strat:
                default_strat = 'Adaptive Roughing'
            elif 'face' in op_strat or 'facing' in op_strat:
                default_strat = 'Facing'
            elif 'flat' in op_strat or 'horizontal' in op_strat:
                default_strat = 'Floor Finishing (Skim)'
            elif any(s in op_strat for s in ['scallop', 'parallel', 'morphed', 'ramp', 'flow']):
                default_strat = '3D Contouring / Scallop Finishing'
            elif any(s in op_strat for s in ['contour', 'trace']):
                default_strat = 'Finishing'
            elif 'pocket' in op_strat:
                default_strat = 'Roughing'

            strat_input.listItems.add('Adaptive Roughing', default_strat == 'Adaptive Roughing')
            strat_input.listItems.add('Roughing', default_strat == 'Roughing')
            strat_input.listItems.add('Finishing', default_strat == 'Finishing')
            strat_input.listItems.add('3D Contouring / Scallop Finishing', default_strat == '3D Contouring / Scallop Finishing')
            strat_input.listItems.add('Floor Finishing (Skim)', default_strat == 'Floor Finishing (Skim)')
            strat_input.listItems.add('Slotting', default_strat == 'Slotting')
            strat_input.listItems.add('Facing', default_strat == 'Facing')
            
            agg_input = inputs.addIntegerSliderCommandInput('aggressiveness', 'Aggressiveness', 0, 100)
            agg_input.valueOne = 50
            
        except Exception as e:
            _report_error("Command Created failed.", e)

# ==============================================================================
# COMMAND 4: STOCK TO LEAVE & DEFLECTION MANAGER
# ==============================================================================

def op_supports_stock_to_leave(op):
    """Checks if an operation supports stock to leave parameters."""
    if not op or not hasattr(op, 'parameters') or not op.parameters:
        return False
    strat = getattr(op, 'strategy', '').lower()
    op_name = getattr(op, 'name', '').lower()
    # Exclude hole-making operations (drilling, tapping, boring, reaming)
    if any(h in strat for h in ['drill', 'tap', 'bore', 'thread', 'hole', 'circular', 'ream']):
        return False
    if op_name.startswith('drill') or op_name.startswith('tap') or 'drill' in op_name:
        if any(h in strat for h in ['drill', 'bore', 'hole', 'tap']):
            return False
            
    for p_name in ['stockToLeave', 'radialStockToLeave', 'useStockToLeave', 'isStockToLeave']:
        p = op.parameters.itemByName(p_name)
        if p is not None:
            return True
    return False

def get_cam_document_units():
    """Detects whether active CAM workspace / document is in millimeters or inches."""
    try:
        des = app.activeDocument.products.itemByProductType('DesignProductType')
        if des and hasattr(des, 'unitsManager') and des.unitsManager:
            u = str(des.unitsManager.defaultLengthUnits).lower()
            if any(m in u for m in ['mm', 'millimeter', 'milli']):
                return "mm"
            if any(m in u for m in ['in', 'inch']):
                return "in"
    except:
        pass
    try:
        prod = app.activeProduct
        if prod and hasattr(prod, 'unitsManager') and prod.unitsManager:
            u = str(prod.unitsManager.defaultLengthUnits).lower()
            if any(m in u for m in ['mm', 'millimeter', 'milli']):
                return "mm"
            if any(m in u for m in ['in', 'inch']):
                return "in"
    except:
        pass
    try:
        camObj = app.activeDocument.products.itemByProductType('CAMProductType')
        if camObj and hasattr(camObj, 'unitsManager') and camObj.unitsManager:
            u = str(camObj.unitsManager.defaultLengthUnits).lower()
            if any(m in u for m in ['mm', 'millimeter', 'milli']):
                return "mm"
            if any(m in u for m in ['in', 'inch']):
                return "in"
    except:
        pass
    try:
        doc = app.activeDocument
        if doc and hasattr(doc, 'unitsManager') and doc.unitsManager:
            u = str(doc.unitsManager.defaultLengthUnits).lower()
            if any(m in u for m in ['mm', 'millimeter', 'milli']):
                return "mm"
            if any(m in u for m in ['in', 'inch']):
                return "in"
    except:
        pass
    return "in"

def _format_stock_value(val, unit):
    if abs(val) < 1e-6:
        val = 0.0
    return f"{val:.3f} mm" if unit == "mm" else f"{val:.4f} in"


def clean_and_eval_stock_expr(expr_str, doc_unit="in"):
    """Evaluates dimension expressions like '(-.1) * 1mm', '(.1)*1mm', or '0mm'
    into clean, formatted numeric strings like '-0.100 mm' or '0.000 mm'.

    The unit is taken from an explicit unit token in the expression; only a unit-less
    expression falls back to `doc_unit`. Arithmetic uses toolwiz_common.safe_eval_length
    (no eval). Expressions that reference Fusion parameters are evaluated by Fusion's
    units manager as a last resort.
    """
    if expr_str is None or str(expr_str).strip() == "":
        return "0.000 mm" if doc_unit == "mm" else "0.0000 in"
    s = str(expr_str).strip()

    units = _length_units_in(s)
    if len(units) == 1:
        unit = next(iter(units))
    else:
        unit = "mm" if _is_metric_unit(doc_unit) else "in"

    if len(units) <= 1:
        try:
            return _format_stock_value(safe_eval_length(s), unit)
        except ValueError:
            pass

    # Expression with parameter references: let Fusion's units manager evaluate it.
    try:
        prod = app.activeProduct if app else None
        if prod and hasattr(prod, 'unitsManager') and prod.unitsManager:
            # evaluateExpression returns database units (centimeters)
            val_cm = float(prod.unitsManager.evaluateExpression(s, unit))
            return _format_stock_value(val_cm * 10.0 if unit == "mm" else val_cm / 2.54, unit)
    except Exception as e:
        _log(f"Could not evaluate stock expression {s!r}", e)

    return s

def is_op_stock_to_leave_active(op):
    """Determines whether Stock to Leave is actively checked / enabled on an operation."""
    if not op or not hasattr(op, 'parameters') or not op.parameters:
        return False
        
    for chk_name in ['useStockToLeave', 'isStockToLeave']:
        p_chk = op.parameters.itemByName(chk_name)
        if p_chk is not None:
            # 1. Check expression string
            if hasattr(p_chk, 'expression') and p_chk.expression is not None:
                expr = str(p_chk.expression).strip().lower()
                if expr in ['true', '1', 'yes']:
                    return True
                if expr in ['false', '0', 'no']:
                    return False
            # 2. Check value object
            try:
                v = getattr(p_chk, 'value', None)
                if v is not None:
                    if hasattr(v, 'value'):
                        return bool(v.value)
                    return bool(v)
            except:
                pass
                
    # 3. Fallback: check if radial parameter exists and is enabled
    for r_name in ['stockToLeave', 'radialStockToLeave']:
        p_rad = op.parameters.itemByName(r_name)
        if p_rad is not None:
            if hasattr(p_rad, 'isEnabled'):
                return bool(p_rad.isEnabled)
                
    return False

def get_op_stock_values(op, doc_unit="in"):
    """Retrieves current radial and axial stock to leave expressions cleanly formatted.
    Returns (is_active, rad_val, ax_val).
    If Stock to Leave is not actively checked, returns (False, zero_str, zero_str).
    """
    zero_str = "0.000 mm" if doc_unit == "mm" else "0.0000 in"
    is_active = is_op_stock_to_leave_active(op)
    
    rad_val = zero_str
    for r_name in ['stockToLeave', 'radialStockToLeave']:
        p = op.parameters.itemByName(r_name)
        if p is not None and p.expression:
            rad_val = clean_and_eval_stock_expr(p.expression, doc_unit)
            break
            
    ax_val = zero_str
    for a_name in ['verticalStockToLeave', 'axialStockToLeave']:
        p = op.parameters.itemByName(a_name)
        if p is not None and p.expression:
            raw_ax = str(p.expression).strip()
            # If axial stock references radial stock expression (e.g. 'stockToLeave'), resolve to rad_val
            if raw_ax in ['stockToLeave', 'radialStockToLeave', 'useStockToLeave']:
                ax_val = rad_val
            else:
                ax_val = clean_and_eval_stock_expr(raw_ax, doc_unit)
            break
            
    if not is_active:
        return False, zero_str, zero_str
        
    return True, rad_val, ax_val

def _param(params, name):
    try:
        return params.itemByName(name) if params else None
    except Exception:
        return None


def _speed_param_sources(op):
    """Parameter collections to read speeds from, in priority order: operation, then linked preset."""
    sources = []
    if getattr(op, 'parameters', None):
        sources.append(op.parameters)
    preset = getattr(op, 'toolPreset', None)
    preset_params = getattr(preset, 'parameters', None) if preset else None
    if preset_params:
        sources.append(preset_params)
    return sources


def _is_fusion_default_formula(p):
    """True for Fusion's placeholder speed/feed formula (e.g. "tool_type == 'probe' ? 0 : ... 5000rpm")."""
    expr = str(getattr(p, 'expression', '') or '') if p is not None else ''
    return 'tool_type' in expr


def _log_speed_sources(op):
    """Diagnostic: record where spindle/feed values come from for this operation."""
    try:
        preset = getattr(op, 'toolPreset', None)
        lines = [f"Speed sources for op {getattr(op, 'name', '?')!r}: preset={getattr(preset, 'name', None)!r}"]
        for label, params in (("preset", getattr(preset, 'parameters', None) if preset else None),
                              ("op", getattr(op, 'parameters', None))):
            for name in ('tool_spindleSpeed', 'tool_feedCutting'):
                p = _param(params, name)
                if p is not None:
                    val = getattr(getattr(p, 'value', None), 'value', None)
                    lines.append(f"  {label}.{name}: expr={getattr(p, 'expression', None)!r} value={val!r}")
        _log("\n".join(lines))
    except Exception as e:
        _log("Speed source diagnostic failed", e)


def get_op_cut_params(op, doc_unit="in"):
    """Extracts (rpm, feed_ipm, doc_in, woc_in) from an operation.

    Units come from the explicit unit tokens in each parameter's expression (in/min, mm/min,
    in, mm, rpm). Only a unit-less expression falls back to `doc_unit`. Values are never
    rescaled based on their magnitude. Results are always RPM, IPM and inches.
    """
    rpm = 0.0
    feed = 0.0
    doc = 0.0
    woc = 0.0
    try:
        # 1-2. Spindle speed (RPM) and cutting feed (IPM). The operation's own parameters are
        # authoritative (they are what gets posted; in real documents they often differ from the
        # linked preset). The preset is used only when the op still holds Fusion's default formula.
        _log_speed_sources(op)
        for params in _speed_param_sources(op):
            p_rpm = _param(params, 'tool_spindleSpeed')
            if rpm <= 0 and not _is_fusion_default_formula(p_rpm):
                rpm = parse_cam_rpm(p_rpm)
            p_feed = _param(params, 'tool_feedCutting')
            if feed <= 0 and not _is_fusion_default_formula(p_feed):
                feed = parse_cam_feed_to_ipm(p_feed, doc_unit)
        if rpm <= 0:  # nothing but the default formula anywhere: use its evaluated value
            rpm = parse_cam_rpm(_param(getattr(op, 'parameters', None), 'tool_spindleSpeed'))
        if feed <= 0:
            feed = parse_cam_feed_to_ipm(_param(getattr(op, 'parameters', None), 'tool_feedCutting'), doc_unit)

        # 3. Axial depth of cut (DOC) - only if parameter is enabled
        for doc_name in ['maximumStepdown', 'stepdown']:
            p = op.parameters.itemByName(doc_name)
            if p and getattr(p, 'isEnabled', True):
                doc = parse_cam_param_to_inches(p, 0.0, doc_unit)
                if doc > 0:
                    break

        # 4. Radial width of cut (WOC); finishing stepover first (2D Contour / finishing ops)
        for woc_fin in ['finishingStepover']:
            p = op.parameters.itemByName(woc_fin)
            if p and getattr(p, 'isEnabled', True):
                woc = parse_cam_param_to_inches(p, 0.0, doc_unit)
                if woc > 0:
                    break

        if woc <= 0:
            for woc_name in ['stepover', 'optimalLoad', 'maximumStepover']:
                p = op.parameters.itemByName(woc_name)
                if p and getattr(p, 'isEnabled', True):
                    woc = parse_cam_param_to_inches(p, 0.0, doc_unit)
                    if woc > 0:
                        break
    except Exception as e:
        _log("Reading operation cut parameters failed", e)

    return rpm, feed, doc, woc

def build_stock_ops_payload(ops_cache, doc_unit="in"):
    """Per-op request bodies for /api/stock_compensation. Lengths are converted to inches and
    feeds to IPM BEFORE sending, and labelled so with length_unit='in' / feed_unit='ipm'.
    Operations whose tool geometry could not be read are skipped (never guessed)."""
    ops_payload = []
    for op_id, op_info in ops_cache.items():
        geo = op_info.get("geo")
        if not geo:
            continue
        op_unit = op_info.get("unit", doc_unit)
        zero_val = "0.000 mm" if op_unit == "mm" else "0.0000 in"
        ops_payload.append({
            "id": op_id,
            "name": op_info["name"],
            "strategy": op_info["strategy"],
            "unit": op_unit,  # display unit for the stock-to-leave strings only
            "length_unit": "in",
            "feed_unit": "ipm",
            "diameter": geo["diameter"],
            "flutes": geo["flutes"],
            "fluteLength": geo["fluteLength"],
            "shankDiameter": geo["shankDiameter"],
            "stickout": geo["stickout"],
            "coating": geo.get("coating", "Uncoated"),
            "geometry": geo.get("geometry", "Square"),
            "rpm": op_info.get("rpm", 0.0),
            "feedrate": op_info.get("feed", 0.0),
            "doc": op_info.get("doc", 0.0),
            "woc": op_info.get("woc", 0.0),
            "current_radial_stock": op_info.get("current_radial", zero_val),
            "current_axial_stock": op_info.get("current_axial", zero_val)
        })
    return ops_payload


def query_toolwiz_stock_compensation(family, alloy, aggressiveness, mode, custom_rad="0.0000 in", custom_ax="0.0000 in", doc_unit="in"):
    """Queries the server's /api/stock_compensation for all cached operations.
    Returns the results list, or [] on failure (reason stored in _stock_last_error and logged)."""
    global _stock_last_error
    _stock_last_error = None
    try:
        payload = {
            "family": family,
            "alloy": alloy,
            "aggressiveness": aggressiveness,
            "mode": mode,
            "unit": doc_unit,
            "custom_radial_offset": custom_rad,
            "custom_axial_offset": custom_ax,
            "operations": build_stock_ops_payload(stock_ops_cache, doc_unit)
        }
        res_data = _http_json('/api/stock_compensation', payload, timeout=8.0)
        if res_data.get("success"):
            return res_data.get("results", [])
        _stock_last_error = str(res_data.get("error") or "server reported failure")
        _log(f"stock_compensation failed: {_stock_last_error}")
    except Exception as e:
        _stock_last_error = str(e)
        _log("stock_compensation request failed", e)
    return []

def find_table_input(inputs, table, input_id):
    """Finds an input control in either dialog inputs or table commandInputs"""
    item = inputs.itemById(input_id)
    if not item and table and hasattr(table, 'commandInputs'):
        item = table.commandInputs.itemById(input_id)
    return item

def escape_html(text):
    """Escapes HTML special characters for safe formattedText rendering."""
    if not text:
        return ""
    return str(text).replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')

def format_cell_html(text, bg_color=None, align="left"):
    """Wraps text in a formatted HTML table container with custom background color and padding."""
    if not bg_color:
        return text
    inner_text = text if (text and text.strip()) else "&nbsp;"
    return (
        f'<table width="100%" bgcolor="{bg_color}" cellpadding="3" cellspacing="0" '
        f'style="background-color:{bg_color}; border-radius:3px;">'
        f'<tr><td align="{align}" style="color:#222222; font-size:11px; font-family:sans-serif;">'
        f'{inner_text}'
        f'</td></tr></table>'
    )

def add_cell_text(parent_inputs, item_id, text, num_rows=1, is_read_only=True, bg_color=None, align="left"):
    """Helper to create formatted text with background contrast or fallback to string value input for table cells."""
    formatted = format_cell_html(text, bg_color, align) if bg_color else text
    try:
        return parent_inputs.addTextBoxCommandInput(item_id, '', formatted, num_rows, is_read_only)
    except:
        plain_text = text.replace('<b>', '').replace('</b>', '').replace('<br>', ' ').replace('<br/>', ' ')
        inp = parent_inputs.addStringValueInput(item_id, '', plain_text)
        inp.isReadOnly = is_read_only
        return inp



def _set_bool_param(op, name, flag):
    """Set a boolean CAM parameter; log (and return False) if it cannot be written."""
    p = op.parameters.itemByName(name)
    if not p:
        return True
    try:
        p.expression = "true" if flag else "false"
        return True
    except Exception as e1:
        try:
            p.value.value = bool(flag)
            return True
        except Exception as e2:
            _log(f"Could not set boolean CAM parameter {name!r} (expression: {e1}; value: {e2})")
            return False


def apply_stock_to_op(op, rad_val, ax_val):
    """Write stock-to-leave values to one operation. Returns a list of parameter names that
    could not be written (empty on success)."""
    failed = []
    # 1. Enable Stock to Leave checkbox
    for chk_name in ['useStockToLeave', 'isStockToLeave']:
        if not _set_bool_param(op, chk_name, True):
            failed.append(chk_name)
    # 2. Unlock independent radial and axial stock
    if not _set_bool_param(op, 'simpleStockToLeave', False):
        failed.append('simpleStockToLeave')
    # 3. Radial stock, 4. Axial stock
    for names, val in ((['stockToLeave', 'radialStockToLeave'], rad_val),
                       (['verticalStockToLeave', 'axialStockToLeave'], ax_val)):
        for name in names:
            p = op.parameters.itemByName(name)
            if p:
                try:
                    p.expression = str(val)
                except Exception as e:
                    _log(f"Could not set {name!r} = {val!r}", e)
                    failed.append(name)
                break
    return failed


class ToolWizStockExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            if not materials_ready():
                ui.messageBox(_materials.get("notice") or "Material list unavailable. Calculation is disabled.",
                              "ToolWiz Stock to Leave Manager")
                return

            applied_ops = []
            failed_ops = []
            for op_id, op_info in stock_ops_cache.items():
                chk = op_info.get("chk")
                if chk and chk.value and getattr(chk, 'isVisible', True):
                    inp_rad = op_info.get("inp_rad")
                    inp_ax = op_info.get("inp_ax")

                    rad_raw = inp_rad.value.strip() if inp_rad else op_info["current_radial"]
                    ax_raw = inp_ax.value.strip() if inp_ax else op_info["current_axial"]

                    doc_u = op_info.get("unit", "in")
                    rad_val = clean_and_eval_stock_expr(rad_raw, doc_u)
                    ax_val = clean_and_eval_stock_expr(ax_raw, doc_u)

                    try:
                        failed = apply_stock_to_op(op_info["op"], rad_val, ax_val)
                    except Exception as e:
                        _log(f"Applying stock to leave to {op_info.get('label')} failed", e)
                        failed = ['(unexpected error)']
                    if failed:
                        failed_ops.append(f" • {op_info['label']}: could not set {', '.join(failed)}")
                    else:
                        applied_ops.append(f" • {op_info['label']}: Radial {rad_val} | Axial {ax_val}")

            if applied_ops or failed_ops:
                msg = ""
                if applied_ops:
                    msg += (
                        f"Stock to Leave Compensation Applied!\n"
                        f"====================================\n"
                        f"Operations Updated: {len(applied_ops)}\n\n"
                        f"{chr(10).join(applied_ops)}\n\n"
                        f"Deflection and material springback compensation values are now active in your toolpaths."
                    )
                if failed_ops:
                    msg += (
                        f"\n\nSome parameters could not be written (see {_log_path()}):\n"
                        f"{chr(10).join(failed_ops)}"
                    )
                ui.messageBox(msg.strip(), 'ToolWiz Stock to Leave Manager')
            else:
                ui.messageBox('No operations were selected to update.', 'ToolWiz Stock to Leave Manager')

        except Exception as e:
            _report_error("Stock Manager apply failed.", e)

class ToolWizStockInputChangedHandler(adsk.core.InputChangedEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        global _is_updating_ui
        if _is_updating_ui:
            return
        cmdInput = None
        try:
            eventArgs = adsk.core.InputChangedEventArgs.cast(args)
            inputs = eventArgs.inputs
            cmdInput = eventArgs.input
            if not cmdInput:
                return
                
            mat_family_input = adsk.core.DropDownCommandInput.cast(inputs.itemById('stockMatFamily'))
            alloy_input = adsk.core.DropDownCommandInput.cast(inputs.itemById('stockMatAlloy'))
            agg_input = inputs.itemById('stockAggressiveness')
            mode_input = adsk.core.DropDownCommandInput.cast(inputs.itemById('stockBatchMode'))
            custom_rad = inputs.itemById('customRadOffset')
            custom_ax = inputs.itemById('customAxOffset')
            
            # 1. Update Alloy Dropdown if Material Family changed
            if cmdInput.id == 'stockMatFamily':
                family = cmdInput.selectedItem.name if cmdInput.selectedItem else ""
                if alloy_input:
                    alloy_input.listItems.clear()
                    alloys = alloys_for(family)
                    if not alloys:
                        alloy_input.listItems.add("Standard Grade", True)
                    else:
                        for i, a in enumerate(alloys):
                            alloy_input.listItems.add(a, i == 0)
                            
            # 2. Toggle custom offset input visibility
            if cmdInput.id == 'stockBatchMode':
                is_custom = mode_input.selectedItem.name == 'Batch Apply Custom Offset' if mode_input.selectedItem else False
                if custom_rad: custom_rad.isVisible = is_custom
                if custom_ax: custom_ax.isVisible = is_custom
                
            # 3. Handle Setup Master ON/OFF Switches
            if cmdInput.id == 'setup_master_toggle':
                master_sw = adsk.core.BoolValueCommandInput.cast(cmdInput)
                is_master_active = master_sw.value if master_sw else getattr(cmdInput, 'value', True)
                
                _is_updating_ui = True
                try:
                    for s_name, s_data in stock_setups_cache.items():
                        sw_id = s_data.get("sw_id")
                        sw_input = adsk.core.BoolValueCommandInput.cast(inputs.itemById(sw_id))
                        if sw_input:
                            sw_input.value = is_master_active
                        
                        for op_id in s_data.get("ops", []):
                            op_info = stock_ops_cache.get(op_id)
                            if not op_info:
                                continue
                            
                            # Update Checkbox (Col 0)
                            chk = op_info.get("chk")
                            if chk:
                                if not is_master_active:
                                    chk.value = False
                                else:
                                    chk.value = op_info.get("is_finishing", False)
                                    
                            # Set isVisible on all cells in the row to collapse or show the row in the table
                            for cell in op_info.get("cells", []):
                                try:
                                    cell.isVisible = is_master_active
                                except:
                                    pass
                finally:
                    _is_updating_ui = False
                return

            if cmdInput.id.startswith('setup_sw_'):
                sw = adsk.core.BoolValueCommandInput.cast(cmdInput)
                is_active = sw.value if sw else getattr(cmdInput, 'value', True)
                
                target_setup = None
                for s_name, s_data in stock_setups_cache.items():
                    if s_data.get("sw_id") == cmdInput.id:
                        target_setup = s_data
                        break
                        
                if target_setup:
                    _is_updating_ui = True
                    try:
                        for op_id in target_setup.get("ops", []):
                            op_info = stock_ops_cache.get(op_id)
                            if not op_info:
                                continue
                            
                            # Update Checkbox (Col 0)
                            chk = op_info.get("chk")
                            if chk:
                                if not is_active:
                                    chk.value = False
                                else:
                                    chk.value = op_info.get("is_finishing", False)
                                    
                            # Set isVisible on all cells in the row to collapse or show the row in the table
                            for cell in op_info.get("cells", []):
                                try:
                                    cell.isVisible = is_active
                                except:
                                    pass

                        # Sync master toggle checkbox state
                        master_sw = adsk.core.BoolValueCommandInput.cast(inputs.itemById('setup_master_toggle'))
                        if master_sw:
                            all_checked = all(
                                getattr(inputs.itemById(s['sw_id']), 'value', False)
                                for s in stock_setups_cache.values()
                                if inputs.itemById(s['sw_id'])
                            )
                            master_sw.value = all_checked
                    finally:
                        _is_updating_ui = False
                return
                
            # 4. Handle Material / Aggressiveness / Mode changes
            if cmdInput.id in ['stockMatFamily', 'stockMatAlloy', 'stockAggressiveness', 'stockBatchMode', 'customRadOffset', 'customAxOffset']:
                if not (mat_family_input and mat_family_input.selectedItem) or not materials_ready():
                    return
                family = mat_family_input.selectedItem.name
                alloy = alloy_input.selectedItem.name if (alloy_input and alloy_input.selectedItem) else ""
                agg = 50
                if agg_input:
                    slider_input = adsk.core.IntegerSliderCommandInput.cast(agg_input)
                    if slider_input:
                        agg = slider_input.valueOne
                    elif hasattr(agg_input, 'valueOne'):
                        agg = agg_input.valueOne
                    elif hasattr(agg_input, 'value'):
                        agg = agg_input.value
                mode_choice = mode_input.selectedItem.name if (mode_input and mode_input.selectedItem) else "Auto-Compensate Finishing (Negative Stock)"
                
                mode_code = "auto_compensate"
                if "Zero-Out" in mode_choice:
                    mode_code = "zero_finishing"
                elif "Custom" in mode_choice:
                    mode_code = "custom"
                
                doc_u = "in"
                for o_info in stock_ops_cache.values():
                    doc_u = o_info.get("unit", "in")
                    break
                zero_str = "0.000 mm" if doc_u == "mm" else "0.0000 in"
                c_rad = custom_rad.value if custom_rad else zero_str
                c_ax = custom_ax.value if custom_ax else zero_str
                
                calc_results = query_toolwiz_stock_compensation(family, alloy, agg, mode_code, c_rad, c_ax, doc_unit=doc_u)
                if not calc_results and _stock_last_error:
                    ui.messageBox(
                        f"ToolWiz could not calculate stock compensation:\n{_stock_last_error}\n\nDetails: {_log_path()}",
                        "ToolWiz Stock to Leave Manager")
                if calc_results:
                    _is_updating_ui = True
                    try:
                        for res in calc_results:
                            op_id = res.get("id")
                            op_info = stock_ops_cache.get(op_id)
                            if not op_info:
                                continue
                                
                            rad_val = res.get("recommended_radial_stock")
                            ax_val = res.get("recommended_axial_stock")
                            adv_text = res.get("advisory")
                            is_fin = res.get("is_finishing", False)
                            op_info["is_finishing"] = is_fin
                            
                            inp_r = op_info.get("inp_rad")
                            inp_a = op_info.get("inp_ax")
                            lbl_adv = op_info.get("lbl_adv")
                            chk = op_info.get("chk")
                            
                            if inp_r and rad_val is not None:
                                inp_r.value = clean_and_eval_stock_expr(str(rad_val), doc_u)
                            if inp_a and ax_val is not None:
                                inp_a.value = clean_and_eval_stock_expr(str(ax_val), doc_u)
                            if lbl_adv and adv_text:
                                adv_html = str(adv_text).replace('\n', '<br>')
                                bg_col = op_info.get("bg_color", "#ffffff")
                                formatted_val = format_cell_html(adv_html, bg_col)
                                adv_box = adsk.core.TextBoxCommandInput.cast(lbl_adv)
                                if adv_box:
                                    adv_box.formattedText = formatted_val
                                elif hasattr(lbl_adv, 'formattedText'):
                                    lbl_adv.formattedText = formatted_val
                                elif hasattr(lbl_adv, 'value'):
                                    lbl_adv.value = str(adv_text)

                                    
                            if cmdInput.id == 'stockBatchMode' and chk and "Finishing" in mode_choice and chk.isVisible:
                                chk.value = is_fin
                    finally:
                        _is_updating_ui = False
                        
        except Exception as e:
            _log(f"Stock Manager input-changed error on {getattr(cmdInput, 'id', 'unknown')}", e)


class ToolWizStockCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            cmd = args.command
            cmd.isExecutedWhenPreEmpted = False
            cmd.isRepeatable = False
            cmd.isAutoExecute = False
            onExecute = ToolWizStockExecuteHandler()
            cmd.execute.add(onExecute)
            handlers.append(onExecute)
            
            onInputChanged = ToolWizStockInputChangedHandler()
            cmd.inputChanged.add(onInputChanged)
            handlers.append(onInputChanged)
            
            inputs = cmd.commandInputs
            global stock_ops_cache, stock_setups_cache, stock_table_input
            stock_ops_cache.clear()
            stock_setups_cache.clear()
            stock_table_input = None
            
            camObj = adsk.cam.CAM.cast(app.activeDocument.products.itemByProductType('CAMProductType'))
            if not camObj:
                ui.messageBox('Please switch to the Manufacture (CAM) workspace with an active setup.')
                return
                
            doc_unit = get_cam_document_units()
            
            # Scan setups and operations
            op_idx = 0
            for setup in camObj.setups:
                setup_name = setup.name
                for op in setup.allOperations:
                    try:
                        if op_supports_stock_to_leave(op):
                            op_idx += 1
                            op_id = f"op_{op_idx}"
                            op_label = f"{setup_name} > {op.name}"
                            geo_payload, tool_summary, _ = get_op_tool_info(op)
                            is_active, rad_val, ax_val = get_op_stock_values(op, doc_unit)
                            # Per-operation display unit: explicit unit of an active stock value, else the document unit
                            op_unit = doc_unit
                            if is_active and ("mm" in str(rad_val).lower() or "mm" in str(ax_val).lower()):
                                op_unit = "mm"
                            rpm, feed, doc, woc = get_op_cut_params(op, op_unit)
                            strat = getattr(op, 'strategy', 'contour2d')

                            if geo_payload:
                                t_num = geo_payload.get('number')
                                t_dia = geo_payload.get('diameter', 0.0)
                                t_flutes = geo_payload.get('flutes', 0)
                                t_type = geo_payload.get('tool_type', 'Flat End Mill')
                                t_lbl = f"T{t_num}" if t_num else "T?"
                                tool_short = f"{t_lbl}: {t_dia:.3f}\" {t_type} ({t_flutes}FL)"
                            else:
                                tool_short = (tool_summary or "Tool").split('|')[0].strip()

                            if setup_name not in stock_setups_cache:
                                s_idx = len(stock_setups_cache)
                                stock_setups_cache[setup_name] = {
                                    "sw_id": f"setup_sw_{s_idx}",
                                    "ops": [],
                                    "name": setup_name,
                                    "idx": s_idx
                                }
                            stock_setups_cache[setup_name]["ops"].append(op_id)

                            stock_ops_cache[op_id] = {
                                "op": op,
                                "op_id": op_id,
                                "setup_name": setup_name,
                                "label": op_label,
                                "name": op.name,
                                "strategy": strat,
                                "tool_summary": tool_short,
                                "unit": op_unit,
                                # None when the tool geometry could not be read: such ops are never sent to the server
                                "geo": geo_payload,
                                "geo_error": None if geo_payload else tool_summary,
                                "stock_active": is_active,
                                "current_radial": rad_val,
                                "current_axial": ax_val,
                                "rpm": rpm,
                                "feed": feed,
                                "doc": doc,
                                "woc": woc
                            }
                    except Exception as e:
                        _log(f"Scanning operation {getattr(op, 'name', '?')} for stock to leave failed", e)

            if not stock_ops_cache:
                ui.messageBox('No operations supporting Stock to Leave were found in the active document.')
                return

            # Materials: one shared loader (server, then on-disk cache)
            load_materials()
            _add_materials_notice(inputs, 'stockMaterialsNotice')
            if not materials_ready():
                return
            families = _materials["families"]

            # Instructions Header
            intro_box = inputs.addTextBoxCommandInput(
                'stockIntro', '',
                '<b>ToolWiz Stock to Leave & Deflection Manager</b><br>'
                'Pre-populates recommended <b>negative radial stock to leave</b> on finishing toolpaths '
                'based on predicted cutter deflection and workpiece elastic springback.',
                2, True
            )
            intro_box.isFullWidth = True

            # Material Dropdowns
            mat_family_input = inputs.addDropDownCommandInput('stockMatFamily', 'Workpiece Material', adsk.core.DropDownStyles.TextListDropDownStyle)
            default_family = "Titanium Alloy" if "Titanium Alloy" in families else families[0]
            for m in families:
                mat_family_input.listItems.add(m, m == default_family)
                
            alloy_input = inputs.addDropDownCommandInput('stockMatAlloy', 'Specific Alloy', adsk.core.DropDownStyles.TextListDropDownStyle)
            init_alloys = alloys_for(default_family) or ["Standard Grade"]
            for i, a in enumerate(init_alloys):
                alloy_input.listItems.add(a, i == 0)
                
            agg_input = inputs.addIntegerSliderCommandInput('stockAggressiveness', 'Aggressiveness', 0, 100)
            agg_input.valueOne = 50
            
            mode_input = inputs.addDropDownCommandInput('stockBatchMode', 'Compensation Preset', adsk.core.DropDownStyles.TextListDropDownStyle)
            mode_input.listItems.add('Auto-Compensate Finishing (Negative Stock)', True)
            mode_input.listItems.add('Zero-Out Finishing (0.0000")', False)
            mode_input.listItems.add('Batch Apply Custom Offset', False)
            
            zero_str = "0.000 mm" if doc_unit == "mm" else "0.0000 in"
            custom_rad = inputs.addStringValueInput('customRadOffset', 'Custom Radial Stock', zero_str)
            custom_ax = inputs.addStringValueInput('customAxOffset', 'Custom Axial Stock', zero_str)
            custom_rad.isVisible = False
            custom_ax.isVisible = False
            
            # Setup Master ON/OFF switches (if multiple setups exist)
            if len(stock_setups_cache) > 1:
                setup_group = inputs.addGroupCommandInput('setupGroup', 'Setups to Include')
                setup_group.isExpanded = True
                setup_group.children.addBoolValueInput(
                    'setup_master_toggle', '<b>Select / Deselect All Setups</b>', True, '', True
                )
                for s_name, s_data in stock_setups_cache.items():
                    s_ops = s_data["ops"]
                    sw_id = s_data["sw_id"]
                    setup_group.children.addBoolValueInput(
                        sw_id, f'{s_name} ({len(s_ops)} ops)', True, '', True
                    )
            
            # Initial calculation from Tool Wizard
            init_results = query_toolwiz_stock_compensation(
                default_family, init_alloys[0] if init_alloys else "", 50, "auto_compensate", doc_unit=doc_unit
            )
            res_map = {r.get("id"): r for r in init_results} if init_results else {}
            
            # Column ratios (7 columns): Apply, Toolpath Operation, Cutter, Current Stock To Leave, New Radial Stock, New Axial Stock, ToolWiz Advisory
            col_ratio = '2:10:6:5:4:4:7'
            
            # 1. Fixed Header Table (Never scrolls away)
            header_table = inputs.addTableCommandInput('stockHeaderTable', 'Operations List', 7, col_ratio)
            header_table.isFullWidth = True
            header_table.minimumVisibleRows = 1
            header_table.maximumVisibleRows = 1
            header_table.hasGrid = False
            header_table.columnSpacing = 4
            header_table.rowSpacing = 3
            header_table.tablePresentationStyle = adsk.core.TablePresentationStyles.transparentBackgroundTablePresentationStyle
            
            # Row 0 of Header Table (2-line wrapping headers with clean header background)
            hdr_bg = "#d9e1e8"
            h_apply = add_cell_text(header_table.commandInputs, 'hdr_apply', '', 2, True, hdr_bg, align="center")
            header_table.addCommandInput(h_apply, 0, 0)
            
            h_op = add_cell_text(header_table.commandInputs, 'hdr_op', '<b>Toolpath Operation</b>', 2, True, hdr_bg)
            header_table.addCommandInput(h_op, 0, 1)
            
            h_tool = add_cell_text(header_table.commandInputs, 'hdr_tool', '<b>Cutter</b>', 2, True, hdr_bg)
            header_table.addCommandInput(h_tool, 0, 2)
            
            h_curr = add_cell_text(header_table.commandInputs, 'hdr_curr', f'<b>Current Stock<br>To Leave ({doc_unit})</b>', 2, True, hdr_bg)
            header_table.addCommandInput(h_curr, 0, 3)
            
            h_rad = add_cell_text(header_table.commandInputs, 'hdr_rad', f'<b>New Radial<br>Stock ({doc_unit})</b>', 2, True, hdr_bg)
            header_table.addCommandInput(h_rad, 0, 4)
            
            h_ax = add_cell_text(header_table.commandInputs, 'hdr_ax', f'<b>New Axial<br>Stock ({doc_unit})</b>', 2, True, hdr_bg)
            header_table.addCommandInput(h_ax, 0, 5)
            
            h_adv = add_cell_text(header_table.commandInputs, 'hdr_adv', '<b>ToolWiz Physics<br>Advisory</b>', 2, True, hdr_bg)
            header_table.addCommandInput(h_adv, 0, 6)
            
            # 2. Scrollable Operations Table
            table = inputs.addTableCommandInput('stockTable', '', 7, col_ratio)
            stock_table_input = table
            table.isFullWidth = True
            table.minimumVisibleRows = 4
            table.maximumVisibleRows = 6
            table.hasGrid = False
            table.columnSpacing = 4
            table.rowSpacing = 3
            table.tablePresentationStyle = adsk.core.TablePresentationStyles.transparentBackgroundTablePresentationStyle
            
            # Rows 0..N-1: Operations
            row_idx = 0
            for op_id, op_info in stock_ops_cache.items():
                calc_r = res_map.get(op_id, {})
                init_rad = clean_and_eval_stock_expr(calc_r.get("recommended_radial_stock", op_info["current_radial"]), doc_unit)
                init_ax = clean_and_eval_stock_expr(calc_r.get("recommended_axial_stock", op_info["current_axial"]), doc_unit)
                if calc_r.get("advisory"):
                    init_adv = calc_r.get("advisory")
                elif not op_info.get("geo"):
                    init_adv = f"Not calculated - {op_info.get('geo_error')}"
                elif _stock_last_error:
                    init_adv = f"ToolWiz calculation unavailable: {_stock_last_error}"
                else:
                    init_adv = "Ready"
                is_finish_op = calc_r.get("is_finishing", False)
                op_info["is_finishing"] = is_finish_op
                op_info["row_idx"] = row_idx
                
                # Alternating row contrast: White on even rows, Light Gray on odd rows
                bg_color = "#ffffff" if (row_idx % 2 == 0) else "#e8edf2"
                op_info["bg_color"] = bg_color
                
                # Col 0: Checkbox (finishing ops checked by default, roughing unchecked)
                chk = table.commandInputs.addBoolValueInput(f'chk_{op_id}', '', True, '', is_finish_op)
                table.addCommandInput(chk, row_idx, 0)
                
                # Col 1: Op Label (2-line auto-wrapping rich text with row background contrast)
                s_clean = escape_html(op_info.get('setup_name', ''))
                n_clean = escape_html(op_info.get('name', ''))
                op_html = f"{s_clean}<br><b>{n_clean}</b>"
                lbl_op = add_cell_text(table.commandInputs, f'lbl_op_{op_id}', op_html, 2, True, bg_color)
                table.addCommandInput(lbl_op, row_idx, 1)
                
                # Col 2: Tool with Cutter Type (2-line auto-wrapping text with row background contrast)
                tool_html = escape_html(op_info.get("tool_summary", ""))
                lbl_tool = add_cell_text(table.commandInputs, f'lbl_tool_{op_id}', tool_html, 2, True, bg_color)
                table.addCommandInput(lbl_tool, row_idx, 2)
                
                # Col 3: Current Stock To Leave (Comparison column with row background contrast)
                if op_info.get("stock_active", False):
                    curr_rad = op_info["current_radial"]
                    curr_ax = op_info["current_axial"]
                    curr_html = f"Rad: {curr_rad}<br>Ax: {curr_ax}"
                else:
                    curr_html = ""
                lbl_curr = add_cell_text(table.commandInputs, f'lbl_curr_{op_id}', curr_html, 2, True, bg_color)
                table.addCommandInput(lbl_curr, row_idx, 3)
                
                # Col 4: Editable New Radial Stock
                inp_rad = table.commandInputs.addStringValueInput(f'inp_rad_{op_id}', '', str(init_rad))
                table.addCommandInput(inp_rad, row_idx, 4)
                
                # Col 5: Editable New Axial Stock
                inp_ax = table.commandInputs.addStringValueInput(f'inp_ax_{op_id}', '', str(init_ax))
                table.addCommandInput(inp_ax, row_idx, 5)
                
                # Col 6: Multi-line Advisory (Formatted 2-line wrapped text with row background contrast)
                adv_html = str(init_adv).replace('\n', '<br>')
                lbl_adv = add_cell_text(table.commandInputs, f'lbl_adv_{op_id}', adv_html, 2, True, bg_color)
                table.addCommandInput(lbl_adv, row_idx, 6)


                
                # Store direct references in op_info for lightning-fast, 100% reliable UI manipulation
                op_info["chk"] = chk
                op_info["inp_rad"] = inp_rad
                op_info["inp_ax"] = inp_ax
                op_info["lbl_adv"] = lbl_adv
                op_info["cells"] = [chk, lbl_op, lbl_tool, lbl_curr, inp_rad, inp_ax, lbl_adv]
                
                row_idx += 1


                
        except Exception as e:
            _report_error("Stock Manager failed to open.", e)

# ==============================================================================
# ADD-IN RUN / STOP
# ==============================================================================

COMMAND_SPECS = [
    (exportCommandId, 'Export Digital Twin',
     'Exports selected Hub / Cloud / Local library to ToolWiz with automated backup.', 'ToolWizExportCreatedHandler'),
    (importCommandId, 'Import Digital Twin',
     'Imports modified Digital Twin library from ToolWiz into Fusion with presets.', 'ToolWizImportCreatedHandler'),
    (calcCommandId, 'ToolWiz Speeds & Feeds',
     'Calculates and injects cutting parameters directly into selected CAM operation.', 'ToolWizCreatedHandler'),
    (stockCommandId, 'Stock to Leave Manager',
     'Batch inspect and apply Stock to Leave with automatic ToolWiz deflection & springback compensation.',
     'ToolWizStockCreatedHandler'),
]


def _remove_ui():
    """Delete this add-in's toolbar controls and command definitions (if present)."""
    workSpace = ui.workspaces.itemById(workspaceToUse)
    panel = workSpace.toolbarPanels.itemById(panelToUse) if workSpace else None
    for cid, _, _, _ in COMMAND_SPECS:
        if panel:
            ctrl = panel.controls.itemById(cid)
            if ctrl:
                ctrl.deleteMe()
        cmdDef = ui.commandDefinitions.itemById(cid)
        if cmdDef:
            cmdDef.deleteMe()


def run(context):
    global app, ui
    app = adsk.core.Application.get()
    ui = app.userInterface

    try:
        # Always rebuild the command definitions. Reusing an existing definition would keep
        # commandCreated handlers from a previously loaded copy of this add-in (e.g. an old
        # install still in memory), and every dialog would then be built twice.
        _remove_ui()
        handlers.clear()

        workSpace = ui.workspaces.itemById(workspaceToUse)
        panel = workSpace.toolbarPanels.itemById(panelToUse) if workSpace else None
        for cid, name, tooltip, handler_cls in COMMAND_SPECS:
            cmdDef = ui.commandDefinitions.addButtonDefinition(cid, name, tooltip)
            on_created = globals()[handler_cls]()
            cmdDef.commandCreated.add(on_created)
            handlers.append(on_created)
            if panel:
                panel.controls.addCommand(cmdDef)

    except Exception as e:
        _report_error("Add-in start failed.", e)

def stop(context):
    try:
        _remove_ui()
        handlers.clear()
    except Exception as e:
        _report_error("Add-in stop failed.", e)

