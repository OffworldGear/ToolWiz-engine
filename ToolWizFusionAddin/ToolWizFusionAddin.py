import adsk.core, adsk.cam, adsk.fusion, traceback
import urllib.request, urllib.error, urllib.parse, json
import os, re, sys, math, time, datetime, uuid, collections, threading

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
    from . import twlogic
except (ImportError, ValueError):
    if _ADDIN_DIR not in sys.path:
        sys.path.insert(0, _ADDIN_DIR)
    import twlogic

try:
    from .toolwiz_common import ToolGeometry, UnitError, safe_eval_length, inspect_operation_geometry, is_hole_kind, is_tap_kind, \
        contour_effective_width_in, measure_op_widths
except (ImportError, ValueError):
    if (not os.path.isdir(os.path.join(_ADDIN_DIR, 'toolwiz_common'))
            and os.path.isdir(os.path.join(_REPO_ROOT, 'toolwiz_common'))
            and _REPO_ROOT not in sys.path):
        sys.path.insert(0, _REPO_ROOT)
    if _ADDIN_DIR not in sys.path:
        sys.path.insert(0, _ADDIN_DIR)
    from toolwiz_common import ToolGeometry, UnitError, safe_eval_length, inspect_operation_geometry, is_hole_kind, is_tap_kind, \
        contour_effective_width_in, measure_op_widths

# Single server base URL used by every request.
SERVER_BASE_URL = "http://127.0.0.1:5000"
CLIENT_HEADER_NAME = 'X-ToolWiz-Client'
CLIENT_HEADER_VALUE = 'fusion-addin'

app = None
ui = None
handlers = []
hidden_handlers = []   # handlers of the hidden result dialogs (kept alive, cleared on stop)

exportCommandId = 'ToolWizExportTwinCmd'
importCommandId = 'ToolWizImportTwinCmd'
calcCommandId = 'ToolWizCalcCmd'
stockCommandId = 'ToolWizStockToLeaveCmd'
logCutCommandId = 'ToolWizLogCutCmd'
cleanupCommandId = 'ToolWizCleanupDuplicatesCmd'
snapshotCommandId = 'ToolWizSnapshotCompareCmd'
advisorCommandId = 'ToolWizSetupAdvisorCmd'
strategyCommandId = 'ToolWizStrategyPlannerCmd'
masterLibCommandId = 'ToolWizMasterLibraryCmd'
libAuditCommandId = 'ToolWizLibraryAuditCmd'
# Hidden (not on the panel) result dialogs, opened from the main thread when a background request finishes.
advisorResultCommandId = 'ToolWizSetupAdvisorResultCmd'
textResultCommandId = 'ToolWizTextResultCmd'

workspaceToUse = 'CAMEnvironment'
panelToUse = 'CAMManagePanel'

available_ops_map = {}
logcut_ops_map = {}
discovered_libraries_map = {}
stock_ops_cache = {}
stock_setups_cache = {}
stock_table_input = None
_is_updating_ui = False
_stock_last_error = None
# Finish mode chosen per operation this session ({op path: {"mode", "ra_uin", "wall_in"}}). The add-in stores no
# ToolWiz data in operation attributes, so the choice is remembered per session (and reused by Setup Advisor).
_finish_prefs = {}

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
# AUDIT TRAIL (%APPDATA%/ToolWiz/audit.jsonl)
# ==============================================================================
# One JSON object per line. Every entry carries ts (ISO), session_id (one per add-in run),
# document (active document name or "?") and command (the add-in command that was running).
# Event kinds: param_change, preset_change, preset_link, tool_removed, side_effect,
# command_start, command_end, replace_decision.

_AUDIT_MAX_BYTES = 5 * 1024 * 1024
_SESSION_ID = datetime.datetime.now().strftime('%Y%m%dT%H%M%S') + '-' + uuid.uuid4().hex[:6]
_audit_command = ''
_active_cmd = None


def _audit_path():
    return os.path.join(_toolwiz_dir(), 'audit.jsonl')


def _jsonable(v):
    if v is None or isinstance(v, (bool, int, float, str)):
        return v
    if isinstance(v, (list, tuple)):
        return [_jsonable(x) for x in v]
    return str(v)


def _doc_name():
    try:
        return str(app.activeDocument.name)
    except Exception:
        return "?"


def _audit_suppressed(d):
    """True only when adsk is a unittest mock AND the target is the user's real ToolWiz folder,
    so test runs never pollute the real audit file. Never true inside Fusion."""
    try:
        real = os.path.join(os.environ.get('APPDATA') or os.path.expanduser('~'), 'ToolWiz')
        return type(adsk.core).__module__.startswith('unittest.mock') and d == real
    except Exception:
        return False


def audit(event):
    """Append ONE JSON line describing `event` (a dict) to audit.jsonl. Rotates at ~5 MB to
    audit.1.jsonl. Never raises."""
    try:
        d = _toolwiz_dir()
        if _audit_suppressed(d):
            return
        entry = {'ts': datetime.datetime.now().isoformat(timespec='seconds'),
                 'session_id': _SESSION_ID, 'document': _doc_name(), 'command': _audit_command}
        for k, v in dict(event).items():
            if k not in ('ts', 'session_id'):
                entry[k] = v
        os.makedirs(d, exist_ok=True)
        path = os.path.join(d, 'audit.jsonl')
        try:
            if os.path.exists(path) and os.path.getsize(path) > _AUDIT_MAX_BYTES:
                os.replace(path, os.path.join(d, 'audit.1.jsonl'))
        except OSError:
            pass
        with open(path, 'a', encoding='utf-8') as f:
            f.write(json.dumps(entry, default=str, ensure_ascii=False) + '\n')
    except Exception:
        pass


def _safe(fn, default=None):
    try:
        return fn()
    except Exception:
        return default


def _op_setup_name(op):
    """Name of the setup that owns `op` (walks up through folders/patterns)."""
    p = getattr(op, 'parent', None)
    first = None
    for _ in range(8):
        if p is None:
            break
        nm = _safe(lambda: p.name)
        first = first or nm
        if hasattr(p, 'allOperations'):
            return nm
        p = _safe(lambda: p.parent)
    return first or "Setup"


def _op_path(op):
    """"Setup > Operation" (the same label the dialogs use)."""
    try:
        return f"{_op_setup_name(op)} > {op.name}"
    except Exception:
        return "?"


def _tool_ident(op):
    """(tool number, description, guid) of the operation's tool; unknown parts are None."""
    d = None
    try:
        d = json.loads(op.tool.toJson())
        if not isinstance(d, dict):
            d = None
    except Exception:
        d = None
    num = _safe(lambda: extract_tool_number(op, d))
    desc = d.get('description') if d else None
    if desc is None:
        desc = _safe(lambda: op.tool.description)
    guid = d.get('guid') if d else None
    return num, (None if desc is None else str(desc)), guid


def _param_state(p):
    """(expression, value) of a CAM parameter, JSON-safe; unreadable parts are None."""
    e = _safe(lambda: p.expression)
    v = _safe(lambda: p.value.value)
    return _jsonable(e), _jsonable(v)


def _audit_param(op, name, old_expr, new_expr, old_val, new_val, ok=True, error=None, requested=None):
    try:
        num, _, _ = _tool_ident(op)
        ev = {'event': 'param_change', 'op_path': _op_path(op), 'tool_number': num, 'param': name,
              'old_expression': old_expr, 'new_expression': new_expr,
              'old_value': old_val, 'new_value': new_val, 'ok': ok}
        if requested is not None and requested != new_expr:
            ev['requested_expression'] = requested
        if error:
            ev['error'] = error
        audit(ev)
    except Exception:
        pass


def _set_expression(op, p, name, expr):
    """Write p.expression = expr on operation `op` and audit the old/new expression and value.
    The old state is captured BEFORE the write. Raises if the write fails (after auditing it)."""
    old_e, old_v = _param_state(p)
    try:
        p.expression = expr
    except Exception as ex:
        _audit_param(op, name, old_e, None, old_v, None, ok=False, error=str(ex), requested=expr)
        raise
    new_e, new_v = _param_state(p)
    _audit_param(op, name, old_e, new_e if new_e is not None else expr, old_v, new_v, requested=expr)


def _preset_ctx(op, tool, before_name, after_name):
    num, desc, _ = _tool_ident(op)
    if desc is None and tool is not None:
        desc = _safe(lambda: tool.description)
    return {'tool_number': num, 'tool_description': None if desc is None else str(desc),
            'preset_before': before_name, 'preset_after': after_name}


def _audit_preset(ctx, field, old, new, ok=True, error=None, **extra):
    try:
        ev = {'event': 'preset_change'}
        ev.update(ctx or {})
        ev.update({'field': field, 'old': _jsonable(old), 'new': _jsonable(new), 'ok': ok})
        if error:
            ev['error'] = error
        ev.update(extra)
        audit(ev)
    except Exception:
        pass


def _set_preset_param(ctx, p_obj, field, expr):
    """Write a preset parameter and audit old/new. Raises if the write fails (after auditing)."""
    old = _safe(lambda: p_obj.expression)
    try:
        p_obj.expression = expr
    except Exception as ex:
        _audit_preset(ctx, field, old, expr, ok=False, error=str(ex))
        raise
    new = _safe(lambda: p_obj.expression)
    _audit_preset(ctx, field, old, new if new is not None else expr)


def _op_preset_name(op):
    return _safe(lambda: op.toolPreset.name)


def _assign_tool_preset(op, preset, reason):
    """operation.toolPreset = preset, audited as preset_link (preset before -> after)."""
    old = _op_preset_name(op)
    num, _, _ = _tool_ident(op)
    try:
        op.toolPreset = preset
    except Exception as ex:
        audit({'event': 'preset_link', 'op_path': _op_path(op), 'tool_number': num, 'preset_before': old,
               'preset_after': _safe(lambda: preset.name), 'reason': reason, 'ok': False, 'error': str(ex)})
        raise
    new = _op_preset_name(op)
    audit({'event': 'preset_link', 'op_path': _op_path(op), 'tool_number': num, 'preset_before': old,
           'preset_after': new if new is not None else _safe(lambda: preset.name),
           'reason': reason, 'ok': True})


# ---- document snapshot ------------------------------------------------------

# Parameters recorded per operation (expression + evaluated value each).
SNAPSHOT_PARAMS = ('tool_spindleSpeed', 'tool_feedCutting', 'maximumStepdown', 'stepdown',
                   'stepover', 'optimalLoad', 'use_tool_stepdown', 'use_tool_stepover', 'fineStepdown',
                   'rampAngle', 'tool_rampAngle', 'helicalRampDiameter', 'tool_feedRamp', 'tool_feedPlunge',
                   'finishingStepover', 'maximumStepover', 'useStockToLeave', 'stockToLeave',
                   'verticalStockToLeave', 'simpleStockToLeave')


def _snapshot_op(op):
    num, desc, guid = _tool_ident(op)
    entry = {'tool_number': num, 'tool_guid': guid, 'tool_description': desc,
             'preset_name': _jsonable(_op_preset_name(op))}
    params = _safe(lambda: op.parameters)
    for name in SNAPSHOT_PARAMS:
        p = _param(params, name)
        if p is None:
            entry[name] = None
        else:
            e, v = _param_state(p)
            entry[name] = {'expr': e, 'value': v}
    return entry


def snapshot_document():
    """Read-only picture of every operation in the active document:
    {'document', 'ts', 'tool_count', 'tool_numbers', 'ops': {"Setup > Op": {...}}}.
    Never raises and never modifies anything."""
    snap = {'document': _doc_name(), 'ts': datetime.datetime.now().isoformat(timespec='seconds'),
            'tool_count': None, 'tool_numbers': [], 'ops': {}}
    try:
        cam = adsk.cam.CAM.cast(app.activeDocument.products.itemByProductType('CAMProductType'))
        if not cam:
            return snap
        for setup in cam.setups:
            for op in setup.allOperations:
                try:
                    path = f"{setup.name} > {op.name}"
                    if path in snap['ops']:      # same name twice in one setup
                        n = 2
                        while f"{path} #{n}" in snap['ops']:
                            n += 1
                        path = f"{path} #{n}"
                    snap['ops'][path] = _snapshot_op(op)
                except Exception as ex:
                    _log("Snapshot: could not read an operation", ex)
        lib = cam.documentToolLibrary
        if lib is not None:
            snap['tool_count'] = lib.count
            nums = []
            for i in range(lib.count):
                try:
                    n = extract_tool_number(None, json.loads(lib.item(i).toJson()))
                    if n is not None:
                        nums.append(n)
                except Exception:
                    pass
            snap['tool_numbers'] = sorted(nums)
    except Exception as ex:
        _log("Snapshot of the document failed", ex)
    return snap


def _ops_of(snap):
    if isinstance(snap, dict) and isinstance(snap.get('ops'), dict):
        return snap['ops']
    return snap if isinstance(snap, dict) else {}


def _flatten(entry):
    flat = {}
    for k, v in (entry or {}).items():
        if isinstance(v, dict):
            for sk, sv in v.items():
                flat[f"{k}.{sk}"] = sv
        else:
            flat[k] = v
    return flat


_NUM_EXPR = re.compile(r'^\s*([-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?)\s*([A-Za-z/]*)\s*$')


def _num_expr(x):
    """(number, unit) for a plain numeric expression like '108.14in/min' or '16000.', else None."""
    if not isinstance(x, str):
        return None
    m = _NUM_EXPR.match(x)
    return (float(m.group(1)), m.group(2).lower()) if m else None


def _same(a, b):
    if (isinstance(a, (int, float)) and isinstance(b, (int, float))
            and not isinstance(a, bool) and not isinstance(b, bool)):
        return abs(a - b) <= 1e-9 * max(1.0, abs(a), abs(b))
    # Fusion re-serialises numbers ('108.13999999999999in/min' -> '108.13999999999997in/min'):
    # the same number and unit is not a change.
    na, nb = _num_expr(a), _num_expr(b)
    if na is not None and nb is not None:
        return na[1] == nb[1] and _same(na[0], nb[0])
    return a == b


def diff_snapshots(before, after):
    """Pure. Changes between two snapshots (the dicts snapshot_document returns, or plain
    {op_path: {field: value}} dicts). Each change is a dict with 'kind' and 'path':
      op_added / op_removed        {'path'}
      preset_change                {'path', 'before', 'after'}   (preset_name changed)
      field_change                 {'path', 'field', 'before', 'after'}
      tool_count / tool_numbers    {'path': None, ...}  (document level; only if both snapshots carry them)"""
    b, a = _ops_of(before), _ops_of(after)
    changes = []
    for path in sorted(set(a) - set(b)):
        changes.append({'kind': 'op_added', 'path': path})
    for path in sorted(set(b) - set(a)):
        changes.append({'kind': 'op_removed', 'path': path})
    for path in sorted(set(a) & set(b)):
        fb, fa = _flatten(b[path]), _flatten(a[path])
        for field in sorted(set(fb) | set(fa)):
            vb, va = fb.get(field), fa.get(field)
            if _same(vb, va):
                continue
            if field == 'preset_name':
                changes.append({'kind': 'preset_change', 'path': path, 'before': vb, 'after': va})
            else:
                changes.append({'kind': 'field_change', 'path': path, 'field': field,
                                'before': vb, 'after': va})
    if isinstance(before, dict) and isinstance(after, dict):
        cb, ca = before.get('tool_count'), after.get('tool_count')
        if cb is not None and ca is not None and cb != ca:
            changes.append({'kind': 'tool_count', 'path': None, 'before': cb, 'after': ca})
        nb, na = before.get('tool_numbers'), after.get('tool_numbers')
        if isinstance(nb, list) and isinstance(na, list) and sorted(nb) != sorted(na):
            cbn, can = collections.Counter(nb), collections.Counter(na)
            changes.append({'kind': 'tool_numbers', 'path': None,
                            'added': sorted((can - cbn).elements()),
                            'removed': sorted((cbn - can).elements())})
    return changes


def classify_changes(changes, target_paths, expected_doc_changes=False):
    """Pure. Split changes into (on the command's intended targets, side effects). Document-level
    changes (tool count/numbers) are side effects unless the command is expected to cause them."""
    targets = set(target_paths or ())
    mine, other = [], []
    for c in changes:
        p = c.get('path')
        if p is None:
            (mine if expected_doc_changes else other).append(c)
        elif p in targets:
            mine.append(c)
        else:
            other.append(c)
    return mine, other


def describe_change(c):
    k, p = c.get('kind'), c.get('path')
    if k == 'op_added':
        return f"{p}: operation added"
    if k == 'op_removed':
        return f"{p}: operation removed"
    if k == 'preset_change':
        return f"{p}: preset {c.get('before')!r} -> {c.get('after')!r}"
    if k == 'field_change':
        return f"{p}: {c.get('field')} {c.get('before')!r} -> {c.get('after')!r}"
    if k == 'tool_count':
        return f"Document tool count {c.get('before')} -> {c.get('after')}"
    if k == 'tool_numbers':
        return f"Document tool numbers: added {c.get('added')}, removed {c.get('removed')}"
    return str(c)


def format_diff_summary(changes, limit=25):
    """Readable summary: counts, then the first `limit` changes."""
    if not changes:
        return "No changes."
    kinds = {}
    for c in changes:
        kinds[c['kind']] = kinds.get(c['kind'], 0) + 1
    ops = {c['path'] for c in changes if c.get('path')}
    lines = [f"{len(changes)} change(s) across {len(ops)} operation(s):"]
    labels = (('op_added', 'operations added'), ('op_removed', 'operations removed'),
              ('preset_change', 'preset changes'), ('field_change', 'field changes'),
              ('tool_count', 'tool count changes'), ('tool_numbers', 'tool number changes'))
    lines.append("  " + ", ".join(f"{kinds[k]} {txt}" for k, txt in labels if k in kinds))
    lines.append("")
    lines += [" - " + describe_change(c) for c in changes[:limit]]
    if len(changes) > limit:
        lines.append(f"... and {len(changes) - limit} more (full list in {_log_path()})")
    return "\n".join(lines)


def _change_event(c, source):
    """Audit event for a change on an intended target (recorded as a normal change)."""
    k = c.get('kind')
    if k == 'preset_change':
        return {'event': 'preset_link', 'op_path': c['path'], 'preset_before': c.get('before'),
                'preset_after': c.get('after'), 'source': source}
    if k == 'field_change':
        name, _, sub = str(c.get('field')).partition('.')
        ev = {'event': 'param_change', 'op_path': c['path'], 'param': name, 'source': source}
        if sub == 'expr':
            ev.update(old_expression=c.get('before'), new_expression=c.get('after'))
        else:
            ev.update(old_value=c.get('before'), new_value=c.get('after'))
        return ev
    return dict(c, event='param_change', source=source)


def _side_effect_event(c, intended):
    ev = {'event': 'side_effect', 'change': c.get('kind'), 'op_path': c.get('path'),
          'intended_target': intended}
    for key in ('field', 'before', 'after', 'added', 'removed'):
        if key in c:
            ev[key] = c[key]
    return ev


def format_side_effect_note(n, doc_level=False):
    tail = "; see %APPDATA%\\ToolWiz\\audit.jsonl"
    if n:
        return f"Note: {n} other operation(s) changed as a side effect{tail}"
    if doc_level:
        return f"Note: the document tool library changed as a side effect{tail}"
    return ""


class AuditedCommand:
    """snapshot before -> run -> snapshot after -> diff. Call begin() first and finish() when the
    command's writes are done (idempotent). Changes on `targets` are recorded as normal changes;
    changes elsewhere are side effects (audit + 'SIDE EFFECT:' in addin.log)."""

    def __init__(self, command, target='', targets=(), expected_doc_changes=False,
                 detect=True, snapshot_fn=None):
        self.command = command
        self.target = target
        self.targets = list(targets or ())
        self.expected_doc_changes = expected_doc_changes
        self.detect = detect
        self.snapshot_fn = snapshot_fn
        self.before = None
        self.finished = False
        self.note = ""
        self.side_effects = 0

    def _snap(self):
        try:
            return (self.snapshot_fn or snapshot_document)()
        except Exception as ex:
            _log("Snapshot failed", ex)
            return None

    def begin(self):
        global _audit_command, _active_cmd
        _audit_command = self.command
        _active_cmd = self
        if self.detect:
            self.before = self._snap()
        audit({'event': 'command_start', 'target': self.target, 'targets': self.targets})
        return self

    def finish(self, result='ok', targets=None, target=None):
        """Diff against the 'before' snapshot, audit, and return the message-box note ('' if none)."""
        global _audit_command, _active_cmd
        if self.finished:
            return self.note
        self.finished = True
        if targets is not None:
            self.targets = list(targets)
        if target is not None:
            self.target = target
        n_target, n_other = 0, 0
        try:
            after = self._snap() if (self.detect and self.before is not None) else None
            if after is not None:
                changes = diff_snapshots(self.before, after)
                mine, other = classify_changes(changes, self.targets, self.expected_doc_changes)
                n_target = len(mine)
                intended = self.targets or self.target or 'none'
                for c in mine:
                    audit(_change_event(c, 'snapshot_diff'))
                for c in other:
                    _log(f"SIDE EFFECT: {describe_change(c)} (during {self.command}; intended: {intended})")
                    audit(_side_effect_event(c, intended))
                n_other = len({c['path'] for c in other if c.get('path')})
                doc_level = any(c.get('path') is None for c in other)
                self.side_effects = n_other
                self.note = format_side_effect_note(n_other, doc_level) if other else ""
        except Exception as ex:
            _log("Side-effect detection failed", ex)
        audit({'event': 'command_end', 'target': self.target, 'result': _jsonable(result),
               'target_changes': n_target, 'side_effect_ops': n_other})
        if _active_cmd is self:
            _active_cmd = None
            _audit_command = ''
        return self.note


def _finish_active_command(result='ok'):
    """Finish the running AuditedCommand (if any) and return its note for the final message box."""
    cmd = _active_cmd
    return cmd.finish(result) if cmd is not None else ""


# ---- Replace safety ---------------------------------------------------------

def preset_names_to_modify(existing_names, replace_name, final_name):
    """Names of existing presets _upsert_preset_in_place will overwrite (and rename)."""
    existing = set(n for n in existing_names if n)
    if replace_name and replace_name != "+ Create New Preset (Auto-Named)" and replace_name in existing:
        return [replace_name]
    return [final_name] if final_name in existing else []


def find_sharing_ops(ops, target_path, tool_guid, tool_number, tool_description, preset_names):
    """Pure. Paths of OTHER operations that use the same tool (same guid, or same number and
    description) and are linked to one of `preset_names`."""
    names = set(preset_names or ())
    found = []
    for path, e in sorted((ops or {}).items()):
        if path == target_path or e.get('preset_name') not in names:
            continue
        same_guid = bool(tool_guid) and e.get('tool_guid') == tool_guid
        same_num = (tool_number is not None and e.get('tool_number') == tool_number
                    and (e.get('tool_description') or '') == (tool_description or ''))
        if same_guid or same_num:
            found.append(path)
    return found


def format_shared_preset_prompt(paths, limit=10):
    shown = list(paths)[:limit]
    listing = "\n".join(f" - {p}" for p in shown)
    if len(paths) > limit:
        listing += f"\n ... and {len(paths) - limit} more"
    return f"Replacing this preset also changes these operations:\n{listing}\n\nContinue?"


def confirm_shared_preset_replace(paths, op_path=None, preset_names=()):
    """Ask Yes/No when other operations share the preset. Returns True to continue. The decision
    is audited."""
    if not paths:
        return True
    res = ui.messageBox(format_shared_preset_prompt(paths), "ToolWiz - Preset Is Shared",
                        adsk.core.MessageBoxButtonTypes.YesNoButtonType,
                        adsk.core.MessageBoxIconTypes.WarningIconType)
    yes = res == adsk.core.DialogResults.DialogYes
    audit({'event': 'replace_decision', 'op_path': op_path, 'presets': list(preset_names),
           'shared_with': list(paths), 'decision': 'yes' if yes else 'no'})
    if not yes:
        _log(f"Replace aborted by user: preset(s) {list(preset_names)} are also used by {list(paths)}")
    return yes


def check_replace_safety(target_op, op_path, replace_name, final_name):
    """True if it is OK to proceed with the preset write (no other operation shares the preset,
    or the user said Yes)."""
    try:
        existing = [getattr(pr, 'name', None) for pr in (getattr(target_op.tool, 'presets', None) or [])]
        names = preset_names_to_modify(existing, replace_name, final_name)
        if not names:
            return True
        num, desc, guid = _tool_ident(target_op)
        cmd = _active_cmd
        ops = _ops_of(cmd.before) if (cmd is not None and cmd.before) else _ops_of(snapshot_document())
        sharing = find_sharing_ops(ops, op_path, guid, num, desc, names)
    except Exception as ex:
        _log("Replace safety check failed; continuing", ex)
        return True
    if not sharing:
        audit({'event': 'replace_decision', 'op_path': op_path, 'presets': names,
               'shared_with': [], 'decision': 'not_shared'})
        return True
    return confirm_shared_preset_replace(sharing, op_path, names)


# ---- saved snapshots (Document Snapshot / Compare command) -------------------

def _safe_doc_key(name):
    s = re.sub(r'\s+v\d+$', '', str(name or '').strip())   # Fusion appends " v12" per version
    return re.sub(r'[^A-Za-z0-9._-]+', '_', s).strip('_') or 'document'


def snapshots_dir():
    return os.path.join(_toolwiz_dir(), 'snapshots')


def save_snapshot(snap):
    """Write snap to snapshots/<safe document name>_<timestamp>.json; returns the path."""
    d = snapshots_dir()
    os.makedirs(d, exist_ok=True)
    key = _safe_doc_key(snap.get('document'))
    stamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
    path, n = os.path.join(d, f"{key}_{stamp}.json"), 1
    while os.path.exists(path):
        n += 1
        path = os.path.join(d, f"{key}_{stamp}-{n}.json")
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(snap, f, indent=1, default=str)
    return path


def latest_snapshot_path(doc_name):
    """Newest saved snapshot for the document, or None."""
    d = snapshots_dir()
    rx = re.compile(r'^' + re.escape(_safe_doc_key(doc_name)) + r'_(\d{8}_\d{6})(?:-(\d+))?\.json$')
    best, best_key = None, None
    try:
        for fn in os.listdir(d):
            m = rx.match(fn)
            if m:
                k = (m.group(1), int(m.group(2) or 1))
                if best_key is None or k > best_key:
                    best, best_key = os.path.join(d, fn), k
    except OSError:
        return None
    return best


def compare_with_last_snapshot(current=None):
    """(summary text, changes, snapshot path). path is None when there is no saved snapshot."""
    current = current or snapshot_document()
    path = latest_snapshot_path(current.get('document'))
    if path is None:
        return ("No saved snapshot exists for this document yet. Choose 'Save snapshot now' first.", [], None)
    with open(path, 'r', encoding='utf-8') as f:
        saved = json.load(f)
    changes = diff_snapshots(saved, current)
    for c in changes:
        _log("SNAPSHOT DIFF: " + describe_change(c))
    head = f"Compared with snapshot taken {saved.get('ts', '?')}\n({os.path.basename(path)})\n\n"
    return head + format_diff_summary(changes), changes, path


# ==============================================================================
# HTTP
# ==============================================================================

def _http_json(path, payload=None, timeout=5.0, retries=0, log_errors=True):
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
        if log_errors:
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
# CUTTING MODEL (same setting as the web page) AND BACKGROUND REQUESTS
# ==============================================================================

_model_cache = {"model": None, "source": None, "models": []}


def load_model_setting():
    """The cutting model in effect on the server (GET /api/model_settings): "v1" or "v2", or the last known
    value when the server cannot be reached, or None when never known (then requests carry no "model" and
    the server decides). Never hard-codes a model."""
    try:
        res = _http_json('/api/model_settings', timeout=4.0, log_errors=False)
        if isinstance(res, dict) and res.get("success") and res.get("model") in ("v1", "v2"):
            _model_cache.update(model=res["model"], source=res.get("source"), models=list(res.get("models") or []))
    except Exception as e:
        _log("Could not read /api/model_settings (using the last known model)", e)
    return _model_cache["model"]


def model_label(model=None):
    m = model or _model_cache.get("model")
    return {"v2": "Physics engine (current; internal name v2)", "v1": "Legacy tables and rules (internal name v1)"}.get(m, "server default")


ASYNC_EVENT_ID = 'ToolWizAsyncEvent'
_async_event = None
_async_handlers = []
_async_pending = {}
_async_lock = threading.Lock()


def run_async(work, on_done):
    """Run `work()` (HTTP and other work that never touches adsk) on a worker thread, then call
    `on_done(result, error)` on Fusion's main thread via a custom event (Fusion's threading rule). Falls back to
    running both inline when the custom event is not registered. Returns immediately when asynchronous."""
    if _async_event is None or app is None or not hasattr(app, 'fireCustomEvent'):
        try:
            res, err = work(), None
        except Exception as ex:
            res, err = None, ex
        on_done(res, err)
        return None
    job_id = uuid.uuid4().hex

    def runner():
        try:
            res, err = work(), None
        except Exception as ex:
            res, err = None, ex
        with _async_lock:
            _async_pending[job_id] = (on_done, res, err)
        try:
            # https://help.autodesk.com/cloudhelp/ENU/Fusion-360-API/files/core_Application_fireCustomEvent.htm
            app.fireCustomEvent(ASYNC_EVENT_ID, job_id)
        except Exception as ex:
            _log("Could not fire the async custom event", ex)

    threading.Thread(target=runner, name="ToolWizAsync", daemon=True).start()
    return job_id


_AsyncEventBase = (
    adsk.core.CustomEventHandler
    if isinstance(getattr(adsk.core, 'CustomEventHandler', None), type)
    else object
)


class ToolWizAsyncCustomEventHandler(_AsyncEventBase):
    """Main-thread end of run_async: hands a finished background result to its callback."""
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            job_id = getattr(args, 'additionalInfo', None)
            with _async_lock:
                item = _async_pending.pop(job_id, None)
            if item is None:
                return
            on_done, res, err = item
            on_done(res, err)
        except Exception as ex:
            _report_error("A background ToolWiz request failed to finish.", ex)


# Background poller for bridge commands queued on the server (/api/fusion_bridge/next). It only does HTTP and
# fires the bridge custom event; every adsk call runs in ToolWizBridgeCustomEventHandler on the main thread.
_bridge_poll_stop = threading.Event()
_bridge_poll_thread = None
BRIDGE_POLL_SECONDS = 1.0


def _bridge_poll_loop():
    delay, warned = BRIDGE_POLL_SECONDS, False
    while not _bridge_poll_stop.is_set():
        try:
            res = _http_json('/api/fusion_bridge/next', timeout=3.0, log_errors=False)
            cmd = res.get("command") if isinstance(res, dict) else None
            delay, warned = BRIDGE_POLL_SECONDS, False
            if isinstance(cmd, dict) and cmd.get("action") and app is not None:
                app.fireCustomEvent(BRIDGE_CUSTOM_EVENT_ID, json.dumps(cmd))
                continue          # more may be queued: ask again at once
        except Exception as ex:
            if not warned:
                _log("Bridge poller: server not reachable (will keep retrying quietly)", ex)
                warned = True
            delay = min(15.0, delay * 2)
        _bridge_poll_stop.wait(delay)


def start_bridge_poller():
    global _bridge_poll_thread
    if _bridge_poll_thread is not None and _bridge_poll_thread.is_alive():
        return
    _bridge_poll_stop.clear()
    _bridge_poll_thread = threading.Thread(target=_bridge_poll_loop, name="ToolWizBridgePoll", daemon=True)
    _bridge_poll_thread.start()


def stop_bridge_poller():
    global _bridge_poll_thread
    _bridge_poll_stop.set()
    _bridge_poll_thread = None


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
# REMEMBERED CHOICES (prefs shared by the Speeds & Feeds and Stock to Leave dialogs)
# ==============================================================================

def _prefs_path():
    return os.path.join(_toolwiz_dir(), 'addin_prefs.json')


# Stock to Leave strength: the predicted negative stock is scaled by this percentage.
STOCK_STRENGTH_PCTS = (25, 50, 75, 100)
STOCK_STRENGTH_DEFAULT = 50


def stock_strength_pct(dropdown, default=STOCK_STRENGTH_DEFAULT):
    """Percent chosen in a strength dropdown ('25%' ... '100%'); `default` if unreadable."""
    try:
        v = int(str(dropdown.selectedItem.name).strip().rstrip('%'))
        return v if v in STOCK_STRENGTH_PCTS else default
    except Exception:
        return default


def _add_strength_dropdown(inputs, input_id, label, selected_pct, tooltip):
    dd = inputs.addDropDownCommandInput(input_id, label, adsk.core.DropDownStyles.TextListDropDownStyle)
    for pct in STOCK_STRENGTH_PCTS:
        dd.listItems.add(f"{pct}%", pct == selected_pct)
    dd.tooltip = tooltip
    return dd


def _clean_prefs(raw):
    """Keep only the known keys with sane types. Anything else is dropped."""
    out = {}
    if not isinstance(raw, dict):
        return out
    for key in ('family', 'alloy', 'strategy'):
        v = raw.get(key)
        if isinstance(v, str) and v.strip():
            out[key] = v
    agg = raw.get('aggressiveness')
    if isinstance(agg, (int, float)) and not isinstance(agg, bool) and math.isfinite(agg):
        out['aggressiveness'] = int(max(0, min(100, round(agg))))
    for key in ('stock_radial_pct', 'stock_axial_pct'):
        v = raw.get(key)
        if isinstance(v, (int, float)) and not isinstance(v, bool) and int(v) in STOCK_STRENGTH_PCTS:
            out[key] = int(v)
    return out


def load_prefs():
    """Read the remembered choices. A missing or corrupt file simply yields {}."""
    try:
        with open(_prefs_path(), 'r', encoding='utf-8') as f:
            return _clean_prefs(json.load(f))
    except FileNotFoundError:
        return {}
    except Exception as e:
        _log("Could not read addin_prefs.json (ignored)", e)
        return {}


def save_prefs(**updates):
    """Merge `updates` (family / alloy / aggressiveness / strategy) into the saved choices.
    Empty or None values are ignored. Never raises; returns True if the file was written."""
    try:
        merged = load_prefs()
        merged.update(_clean_prefs({k: v for k, v in updates.items() if v not in (None, "")}))
        os.makedirs(_toolwiz_dir(), exist_ok=True)
        tmp = _prefs_path() + '.tmp'
        with open(tmp, 'w', encoding='utf-8') as f:
            json.dump(merged, f, indent=2)
        os.replace(tmp, _prefs_path())
        return True
    except Exception as e:
        _log("Could not save addin_prefs.json", e)
        return False


def pick_saved(saved, items, default):
    """Return `saved` when it is one of `items`, otherwise `default`."""
    return saved if (saved is not None and saved in items) else default


def _selected_name(dropdown):
    """Name of a dropdown's selected item, or "" (tolerates a missing input)."""
    try:
        return dropdown.selectedItem.name if (dropdown and dropdown.selectedItem) else ""
    except Exception:
        return ""


# ==============================================================================
# RESULT MESSAGES
# ==============================================================================

LIMIT_LABELS = {
    "deflection": "tool deflection", "power": "spindle power", "flute_length": "flute length",
    "geometry_rule": "tool geometry", "operation_depth_rule": "operation depth rule",
    # v2 constraints (physics_v2/optimize.py)
    "C1": "every flute cuts (runout)", "C2": "chip thickness (tooth strength)", "C3": "tool deflection",
    "C4": "bending stress", "C5": "spindle power/torque", "C6": "flute length", "C7": "cutting speed (tool life)",
    "C8": "slot depth", "C9": "chatter (reach)", "C10": "work-hardening chip", "C11": "feed cap",
    "C12": "stepover vs runout", "C13": "program size", "C14v": "vendor chart speed",
    "C14f": "vendor chart chip load", "C14m": "vendor chart removal rate",
    "C15": "chip room in the flutes",
}


def _limited_by_text(limited):
    prefix = ""
    if isinstance(limited, str) and limited.strip().lower().startswith("v2:"):
        prefix = "v2: "
        limited = limited.strip()[3:].strip()
    if isinstance(limited, str) and "," in limited:
        limited = [x.strip() for x in limited.split(",")]
    if isinstance(limited, (list, tuple)):
        limited = ", ".join(LIMIT_LABELS.get(str(x), str(x)) for x in limited if x)
    elif limited:
        limited = LIMIT_LABELS.get(str(limited).strip(), str(limited))
    return (prefix + str(limited).strip()) if limited else ""


def format_provenance_line(provenance, top_n=3):
    """One line with the `top_n` largest non-1.0 SFM multipliers, e.g.
    "SFM: hard-milling x0.72, coating x1.40, stickout x0.85". "" when there are none."""
    if not isinstance(provenance, (list, tuple)):
        return ""
    steps = []
    for s in provenance:
        try:
            if not isinstance(s, dict) or str(s.get("quantity", "")).lower() != "sfm":
                continue
            step = str(s.get("step", "")).strip()
            m = float(s.get("multiplier"))
            if not step or step in ("base_lookup", "spindle_cap") or not math.isfinite(m) or m <= 0:
                continue
            if round(m, 2) == 1.0:
                continue
            steps.append((abs(math.log(m)), step.replace("_", "-"), m))
        except (TypeError, ValueError):
            continue
    if not steps:
        return ""
    steps.sort(key=lambda t: -t[0])
    return "SFM: " + ", ".join(f"{name} ×{m:.2f}" for _, name, m in steps[:top_n])


def format_autoset_message(t_label, geo, material_label, strategy, rpm, feed, ipt,
                           doc=None, woc=None, limited_by=None, provenance=None, preset_note="",
                           model=None, model_note=""):
    """Concise success text for the Speeds & Feeds auto-setter. `doc` / `woc` are None when
    they were not written to the operation. `model` is the cutting model that produced the numbers."""
    lines = [
        f"{t_label} · {geo.get('diameter', 0.0):.3f}\" {geo.get('flutes', '?')}FL · {material_label} — {strategy}",
        f"{rpm:,.0f} RPM · {feed:.1f} IPM · {ipt:.4f} IPT",
    ]
    if model:
        lines.insert(1, "Model: physics engine (current)" if model == "v2" else "Model: legacy tables and rules")
        if model == "v1" and model_note:
            lines.insert(2, model_note)
    cuts = []
    if doc is not None:
        cuts.append(f"DOC {doc:.4f}\"")
    if woc is not None:
        cuts.append(f"WOC {woc:.4f}\"")
    if cuts:
        lines.append(" · ".join(cuts))
    lim = _limited_by_text(limited_by)
    if lim:
        lines.append(f"Limited by: {lim}")
    prov = format_provenance_line(provenance)
    if prov:
        lines.append(prov)
    if preset_note:
        lines.append(preset_note)
    return "\n".join(lines)


def format_stock_summary(material, applied, failed, log_path):
    """Concise apply summary for Stock to Leave. `applied` is [(label, radial, axial)],
    `failed` is [(label, [parameter names])]."""
    lines = []
    if applied:
        head = f"Stock to leave set on {len(applied)} op{'s' if len(applied) != 1 else ''}"
        lines.append(f"{head} — {material}" if material else head)
        for label, rad, ax in applied:
            lines.append(f" • {label}: Rad {rad} · Ax {ax}")
    if failed:
        if lines:
            lines.append("")
        lines.append(f"Could not write (details in {log_path}):")
        for label, names in failed:
            lines.append(f" • {label}: {', '.join(names)}")
    return "\n".join(lines)


# ==============================================================================
# CALIBRATION STATUS (cut-log feedback)
# ==============================================================================

_calibration_cache = {}


def format_calibration_status(cal):
    """Human text for one family's /api/calibration entry. "" when `cal` is unusable."""
    if not isinstance(cal, dict):
        return ""
    status = cal.get("status")
    n = cal.get("n", 0)
    if status == "calibrated":
        factor = cal.get("applied_factor") or cal.get("error_factor")
        if isinstance(factor, (int, float)) and not isinstance(factor, bool):
            return f"Calibrated from {n} cuts ×{factor:.2f}"
        return f"Calibrated from {n} cuts"
    if status == "provisional":
        return f"Provisional ({n})"
    return "Not calibrated — use Log Cut Result"


def fetch_calibration(family, use_cache=True):
    """GET /api/calibration?family=... -> the family's calibration dict (a synthetic
    "insufficient" entry when it has no logged cuts), or None on any failure."""
    if not family:
        return None
    if use_cache and family in _calibration_cache:
        return _calibration_cache[family]
    try:
        res = _http_json('/api/calibration?family=' + urllib.parse.quote(family), timeout=3.0)
        if not isinstance(res, dict) or not res.get("success"):
            return None
        cal = None
        for e in (res.get("calibration") or []):
            if isinstance(e, dict) and str(e.get("family", "")).lower() == family.lower():
                cal = e
                break
        if cal is None:
            cal = {"family": family, "n": 0, "status": "insufficient"}
        _calibration_cache[family] = cal
        return cal
    except Exception as e:
        _log(f"Calibration lookup for {family!r} failed", e)
        return None


def calibration_text_for(family, use_cache=True):
    """Status text for the UI; "" when the server could not be asked."""
    return format_calibration_status(fetch_calibration(family, use_cache))


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
    """Feed CAM parameter -> IPM using the expression's explicit unit. When the expression has
    no unit token (e.g. a metric tool in an inch document where Fusion writes a unit-less mm/min
    string on the operation), prefer Fusion's unit-independent evaluated value (mm/min)."""
    if not p:
        return 0.0
    expr = getattr(p, 'expression', None)
    v = _numeric_param_value(p)
    if expr:
        m = _FEED_RE.match(str(expr))
        if m and m.group(2):
            try:
                return parse_feed_expr_to_ipm(expr, doc_unit)
            except ValueError:
                pass
        elif m and (v is None or v <= 0):
            try:
                return parse_feed_expr_to_ipm(expr, doc_unit)
            except ValueError:
                pass
    if v is not None and v > 0:
        ipm = v / 25.4  # Fusion's evaluated feed is mm/min (confirmed: '19.2774in/min' -> 489.647)
        if ipm > MAX_PLAUSIBLE_IPM:
            _log(f"Feed expression {expr!r}: evaluated {v!r} -> {ipm:.1f} IPM is implausible; ignoring (server will compute)")
            return 0.0
        _log(f"Feed expression {expr!r}: evaluated {v!r} mm/min -> {ipm:.1f} IPM")
        return ipm
    if expr:
        try:
            return parse_feed_expr_to_ipm(expr, doc_unit)
        except ValueError:
            pass
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
    """Normalizes cutter types into clean, readable labels (e.g. Flat End Mill, Twist Drill, Tap)"""
    t_str = (raw_type or "").lower().replace('_', ' ').replace('-', ' ').strip()
    d_str = (desc or "").lower()

    if "tap" in t_str or ("tap" in d_str and "taper" not in d_str):
        if "left" in t_str or "lh" in d_str:
            return "Tap (Left Hand)"
        if "form" in t_str or "form" in d_str or "roll" in d_str:
            return "Form Tap"
        return "Tap"
    elif "spot drill" in t_str or "spot drill" in d_str or "spotting" in d_str:
        return "Spot Drill"
    elif "center drill" in t_str or "centre drill" in t_str or "center drill" in d_str:
        return "Center Drill"
    elif "counter sink" in t_str or "countersink" in t_str or "countersink" in d_str:
        return "Countersink"
    elif "counter bore" in t_str or "counterbore" in t_str or "counterbore" in d_str:
        return "Counterbore"
    elif "reamer" in t_str or "reamer" in d_str:
        return "Reamer"
    elif "boring" in t_str or t_str == "bore":
        return "Boring Bar"
    elif "drill" in t_str or ("drill" in d_str and "mill" not in d_str):
        return "Twist Drill"
    elif "chamfer" in t_str or "chamfer" in d_str:
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
        geo_dict = t_dict.get("geometry") or {}
        post_dict = t_dict.get("post-process") or t_dict.get("postProcess") or {}
        bmc_lower = " ".join(
            str(x).lower() for x in (
                t_dict.get("BMC"), t_dict.get("material"), geo_dict.get("BMC"),
                geo_dict.get("material"), post_dict.get("material")
            ) if x
        )
        grade_lower = str(t_dict.get("GRADE") or t_dict.get("grade") or geo_dict.get("grade") or "").lower()
        text_all = f"{desc_lower} {bmc_lower} {grade_lower}"

        is_carbide = twlogic.tool_is_carbide(t_dict)
        runout_in, runout_source = twlogic.tool_runout_in(t_dict)

        detected_coating = "AlTiN" if is_carbide else "Uncoated"
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

        is_hole = is_hole_kind(geo.kind)
        is_tap = is_tap_kind(geo.kind)
        if is_tap:
            geo_shape = "form" if ("form" in text_all or "roll" in text_all) else "spiral_flute"
        elif geo.kind.value == "spot_drill":
            geo_shape = "Spot Drill"
        elif geo.kind.value == "reamer":
            geo_shape = "Reamer"
        elif is_hole:
            geo_shape = "Parabolic" if "parabolic" in text_all else "Drill"
        else:
            geo_shape = "Square" if corner_radius == 0 else "Bullnose / Radiused"

        geo_payload = {
            "diameter": diameter,
            "flutes": flutes,
            "fluteLength": flute_length,
            "shankDiameter": geo.shank_diameter,
            "neckLength": geo.neck_length,
            "neckDiameter": geo.neck_diameter,
            "cornerRadius": corner_radius,
            "stickout": geo.stickout,
            "stickoutSource": geo.stickout_source,
            "coating": detected_coating,
            "is_carbide": is_carbide,
            "geometry": geo_shape,
            "kind": geo.kind.value,
            "isHoleTool": is_hole,
            "isTap": is_tap,
            "threadPitch": geo.thread_pitch,
            "desc": desc,
            "number": t_num,
            "guid": t_dict.get("guid"),
            "tool_type": cutter_type,
            "runout_in": runout_in,
            "runout_source": runout_source,
            "raw_json": raw_json
        }

        dia_mm = diameter * 25.4
        fl_mm = flute_length * 25.4
        pitch_str = ""
        if is_tap and geo.thread_pitch and geo.thread_pitch > 0:
            tpi = 1.0 / geo.thread_pitch
            pitch_mm = geo.thread_pitch * 25.4
            pitch_str = f", Pitch: {geo.thread_pitch:.4f}\" ({tpi:.1f} TPI / {pitch_mm:.2f}mm)"
        summary = (
            f"{tool_label(t_num)}: {desc} | {cutter_type} | Dia: {diameter:.3f}\" ({dia_mm:.2f}mm), "
            f"{flutes} Flutes, Flute L: {flute_length:.3f}\" ({fl_mm:.1f}mm){pitch_str}\n"
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
            _set_expression(op, p, name, str(expr_str))
            return True
    except Exception as e:
        _log(f"Could not set CAM parameter {name!r} = {expr_str!r}", e)
    return False


# Fusion's adaptive default is 10 % of the maximum stepdown, so a small written stepdown gave
# 0.005 mm fine-stepdown levels and multi-MB programs (docs/research/nc_file_size_calibration.md).
# Ours: 25 % of the stepdown, never under 0.05 mm, never above the stepdown or half the diameter.
FUSION_DEFAULT_FINE_STEPDOWN = "Math.min(tool_diameter * 0.5; maximumStepdown * 0.1)"
FINE_STEPDOWN_EXPR = ("Math.min(tool_diameter * 0.5; Math.min(maximumStepdown; "
                      "Math.max(maximumStepdown * 0.25; 0.05 mm)))")


def _norm_expr(expr):
    return "".join(str(expr or "").split()).lower()


MAX_WRITTEN_RAMP_ANGLE = 45.0   # anything steeper is a hole tool's plunge, not a ramp
FUSION_DEFAULT_RAMP_DIAMETER = "Math.max((tool_diameter - 2 * tool_cornerRadius) * 0.95; tool_diameter * 0.25)"


def ramp_angle_expr(calc_result):
    """Preset expression for tool_rampAngle (plain degrees, as Fusion stores it), or None when the server
    gave no usable ramp angle (none, zero, or a hole tool's 90° plunge)."""
    try:
        a = float(calc_result.get("ramp_angle") or 0.0)
    except (TypeError, ValueError):
        return None
    if not 0.0 < a < MAX_WRITTEN_RAMP_ANGLE:
        return None
    return f"{a:.2f}"


def apply_ramp_diameter(op, diameter_in, override_custom=False):
    """Write the helical ramp diameter the server recommends (v2 ramp model). When override_custom
    is True (used by run_autoset), any prior custom value is replaced by ToolWiz."""
    try:
        d = float(diameter_in or 0.0)
    except (TypeError, ValueError):
        d = 0.0
    if d <= 0.0:
        return None
    p = _safe(lambda: op.parameters.itemByName('helicalRampDiameter'))
    if p is None or not _safe(lambda: p.isEnabled) or not isinstance(_safe(lambda: p.expression), str):
        return None
    expr = f"{d:.4f} in"
    current = _norm_expr(_safe(lambda: p.expression))
    if current == _norm_expr(expr):
        return 'already'
    if not override_custom and current != _norm_expr(FUSION_DEFAULT_RAMP_DIAMETER):
        _log(f"  helicalRampDiameter kept (user-set): {_safe(lambda: p.expression)!r}")
        return 'kept'
    return 'written' if apply_param(op, 'helicalRampDiameter', expr) else None


FUSION_DEFAULT_MIN_ROUGHING_STEPOVER = "0.1 * maximumStepover"
MIN_ROUGHING_STEPOVER_EXPR = "Math.max(maximumStepover * 0.25; 0.025 mm)"
FUSION_DEFAULT_REDUCED_FEEDRATE = "tool_feedCutting * 0.25"


def apply_fine_stepdown_floor(op, override_custom=False):
    """Replace fine-stepdown expression on `op` with FINE_STEPDOWN_EXPR.

    When override_custom=True (used by run_autoset), any prior custom entry is overwritten by ToolWiz."""
    p = _safe(lambda: op.parameters.itemByName('fineStepdown'))
    if p is None or not _safe(lambda: p.isEnabled) or not isinstance(_safe(lambda: p.expression), str):
        return None
    current = _norm_expr(_safe(lambda: p.expression))
    if current == _norm_expr(FINE_STEPDOWN_EXPR):
        return 'already'
    if not override_custom and current != _norm_expr(FUSION_DEFAULT_FINE_STEPDOWN):
        _log(f"  fineStepdown kept (user-set): {_safe(lambda: p.expression)!r}")
        return 'kept'
    return 'written' if apply_param(op, 'fineStepdown', FINE_STEPDOWN_EXPR) else None


def _is_bool_param_false(p):
    expr = _safe(lambda: p.expression)
    return isinstance(expr, str) and _norm_expr(expr) in ('false', '0', 'no')


def _is_bool_param_true(p):
    expr = _safe(lambda: p.expression)
    return isinstance(expr, str) and _norm_expr(expr) in ('true', '1', 'yes')


def apply_passes_tab_params(op, strategy, doc_in, woc_in, calc_result=None, geo_payload=None):
    """Configure Passes Tab checkboxes and limits (Multiple Depths, Roughing Passes, Feed Optimization)
    so Fusion enforces the calculated axial DOC and radial WOC on 2D Contour and profile operations.
    Returns a list of human-readable notes describing what was configured."""
    notes = []
    params = getattr(op, 'parameters', None)
    if params is None:
        return notes

    strat = str(strategy or "").strip().lower()
    is_rough_or_semi = ("rough" in strat and "adaptive" not in strat) or ("semi" in strat)
    is_slot = "slot" in strat
    is_finish = "finish" in strat and "semi" not in strat

    fg = (calc_result or {}).get("feature_geometry") or {}
    feat_depth = fg.get("feature_depth_in")
    needs_multi_depths = is_rough_or_semi or is_slot or (
        is_finish and feat_depth is not None and doc_in and float(feat_depth) > float(doc_in) + 1e-4
    )

    # 1. Multiple Depths (axial Z stepdown enforcement)
    if needs_multi_depths and doc_in and float(doc_in) > 0:
        md_active = False
        for chk_name in ('doMultipleDepths', 'useMultipleDepths'):
            p_chk = _param(params, chk_name)
            if p_chk is not None:
                if _is_bool_param_false(p_chk):
                    apply_param(op, chk_name, 'true', force=True)
                    md_active = True
                elif _is_bool_param_true(p_chk):
                    md_active = True
        if md_active:
            p_sd = _param(params, 'maximumStepdown')
            if p_sd is not None and isinstance(_safe(lambda: p_sd.expression), str):
                try:
                    p_sd.isEnabled = True
                except Exception:
                    pass
            p_even = _param(params, 'useEvenStepdowns')
            if p_even is not None and _is_bool_param_false(p_even):
                apply_param(op, 'useEvenStepdowns', 'true', force=True)
            notes.append(f"Multiple Depths enabled (max stepdown {float(doc_in):.4f}\", even stepdowns)")

    # 2. Roughing Passes / Multiple Passes (radial XY stepover enforcement)
    if is_rough_or_semi and woc_in and float(woc_in) > 0:
        mp_active = False
        for chk_name in ('doMultiplePasses', 'useRoughingPasses'):
            p_chk = _param(params, chk_name)
            if p_chk is not None:
                if _is_bool_param_false(p_chk):
                    apply_param(op, chk_name, 'true', force=True)
                    mp_active = True
                elif _is_bool_param_true(p_chk):
                    mp_active = True
        if mp_active:
            p_so = _param(params, 'maximumStepover')
            if p_so is not None and isinstance(_safe(lambda: p_so.expression), str):
                try:
                    p_so.isEnabled = True
                except Exception:
                    pass
            p_min_so = _param(params, 'minimumRoughingStepover')
            if p_min_so is not None and isinstance(_safe(lambda: p_min_so.expression), str):
                apply_param(op, 'minimumRoughingStepover', MIN_ROUGHING_STEPOVER_EXPR, force=True)
            p_steps = _param(params, 'maximumRoughingSteps')
            if p_steps is not None and isinstance(_safe(lambda: p_steps.expression), str):
                cur_steps = _expr_number(_safe(lambda: p_steps.expression))
                if cur_steps is not None and cur_steps < 2:
                    apply_param(op, 'maximumRoughingSteps', '2', force=True)
            notes.append(f"Roughing Passes enabled (max stepover {float(woc_in):.4f}\")")
    elif is_slot:
        for chk_name in ('doMultiplePasses', 'useRoughingPasses'):
            p_chk = _param(params, chk_name)
            if p_chk is not None and _is_bool_param_true(p_chk):
                apply_param(op, chk_name, 'false', force=True)
                notes.append("Roughing Passes disabled for single-pass Slotting")

    # 3. Feed Optimization (corner slowdown enforcement when corner engagement spikes or on micro rough/slot)
    corner_feed = (calc_result or {}).get("corner_feed")
    feed = (calc_result or {}).get("feed") or (calc_result or {}).get("feedrate")
    dia = float((geo_payload or {}).get("diameter") or 0.0)
    needs_feed_opt = (
        (corner_feed is not None and feed and float(corner_feed) < float(feed) * 0.95)
        or (0.0 < dia < 0.0625 and (is_rough_or_semi or is_slot) and feed)
    )
    if needs_feed_opt and feed:
        target_cf = float(corner_feed) if (corner_feed is not None and float(corner_feed) > 0) else float(feed) * 0.50
        for chk_name in ('useFeedOptimization', 'doFeedOptimization', 'feedOptimization'):
            p_fo = _param(params, chk_name)
            if p_fo is not None and _is_bool_param_false(p_fo):
                apply_param(op, chk_name, 'true', force=True)
        p_rf = _param(params, 'reducedFeedrate')
        if p_rf is not None and isinstance(_safe(lambda: p_rf.expression), str):
            if apply_param(op, 'reducedFeedrate', f"{target_cf:.2f} in/min", force=True):
                notes.append(f"Feed Optimization reduced feedrate set to {target_cf:.2f} IPM")

    return notes

# ==============================================================================
# COMMAND 1: EXPORT DIGITAL TWIN
# ==============================================================================

def _coll_items(coll):
    """Items of a Fusion collection (count/item) or any iterable, never raising."""
    try:
        if hasattr(coll, 'count') and hasattr(coll, 'item'):
            return [coll.item(i) for i in range(coll.count)]
        return list(coll or [])
    except Exception:
        return []


def _url_name(u):
    """Display name of an adsk.core.URL (leaf name; https://help.autodesk.com/cloudhelp/ENU/Fusion-360-API/files/core_URL.htm)."""
    for attr in ('leafName', 'leafPath'):
        v = _safe(lambda: getattr(u, attr))
        if isinstance(v, str) and v:
            return v
    return _safe(lambda: u.toString()) or "library"


def _tool_library_at(tool_libs, url):
    """ToolLibraries.toolLibraryAtURL (the documented name; older code used toolLibraryAtUrl)."""
    fn = getattr(tool_libs, 'toolLibraryAtURL', None) or getattr(tool_libs, 'toolLibraryAtUrl', None)
    return fn(url) if fn else None


def _walk_library_urls(tool_libs, root, depth=0, max_depth=6):
    """Every library asset URL under `root`, recursing into sub-folders (childAssetURLs / childFolderURLs:
    https://help.autodesk.com/cloudhelp/ENU/Fusion-360-API/files/cam_ToolLibraries.htm)."""
    out = []
    try:
        out += _coll_items(tool_libs.childAssetURLs(root))
        if depth < max_depth:
            for f in _coll_items(tool_libs.childFolderURLs(root)):
                out += _walk_library_urls(tool_libs, f, depth + 1, max_depth)
    except Exception as e:
        _log(f"Listing libraries under {_url_name(root)} failed", e)
    return out


# LibraryLocations values: https://help.autodesk.com/cloudhelp/ENU/Fusion-360-API/files/cam_LibraryLocations.htm
# (Local 0, Cloud 1, Network 2 [internal], Fusion360 5 [Autodesk samples, not harvested], Hub 6). Looked up with
# getattr so a Fusion build without a value (e.g. Hub in older versions) just skips that source.
HARVEST_LOCATIONS = (("Local", "LocalLibraryLocation"), ("Cloud", "CloudLibraryLocation"), ("Hub", "HubLibraryLocation"))


def discover_libraries():
    """{display name: {"type": source, "url", "obj"}} for the local, cloud and hub tool libraries, plus the
    tool library of every open CAM document and the active document's tools in use."""
    found = {}
    try:
        tool_libs = adsk.cam.CAMManager.get().libraryManager.toolLibraries
    except Exception as e:
        _log("Tool library manager unavailable", e)
        tool_libs = None
    if tool_libs is not None:
        for label, enum_name in HARVEST_LOCATIONS:
            loc = getattr(adsk.cam.LibraryLocations, enum_name, None)
            if loc is None:
                _log(f"LibraryLocations.{enum_name} is not available in this Fusion version; {label} libraries skipped")
                continue
            try:
                root = tool_libs.urlByLocation(loc)
                if not root:
                    continue
                for u in _walk_library_urls(tool_libs, root):
                    lib = _tool_library_at(tool_libs, u)
                    if lib:
                        found[f"{label}: {_url_name(u)}"] = {"type": label.lower(), "url": u, "obj": lib}
            except Exception as e:
                _log(f"{label} tool library discovery failed", e)
    try:
        for doc in _coll_items(app.documents):
            cam = adsk.cam.CAM.cast(doc.products.itemByProductType('CAMProductType'))
            if cam:
                found[f"Open document: {_safe(lambda: doc.name) or '?'}"] = {"type": "document", "doc": doc, "cam": cam}
    except Exception as e:
        _log("Open document discovery failed", e)
    return found


def _library_tools_json(lib):
    out = []
    for i in range(lib.count):
        try:
            out.append(json.loads(lib.item(i).toJson()))
        except Exception as e:
            _log(f"Could not read tool {i} of a library", e)
    return out


def harvest_selected(selected, found):
    """Entries [{library_name, source, tools}] for the selected display names of `found`."""
    entries = []
    for name in selected:
        info = found.get(name)
        if not info:
            continue
        try:
            if info["type"] == "document":
                lib = info["cam"].documentToolLibrary
            else:
                lib = info.get("obj")
            e = twlogic.harvest_entry(name, info["type"], _library_tools_json(lib) if lib else [])
        except Exception as ex:
            _log(f"Harvesting {name!r} failed", ex)
            e = None
        if e:
            entries.append(e)
    return entries


DESIGN_EXTENSIONS = ('f3d', 'f3z', 'fusion')


def _collect_design_files(folder, path, out, depth=0, max_depth=12):
    """Append (folder path, DataFile) for every Fusion design under a DataFolder (dataFiles / dataFolders)."""
    for df in _coll_items(_safe(lambda: folder.dataFiles)):
        ext = str(_safe(lambda: df.fileExtension) or '').lower()
        if ext in DESIGN_EXTENSIONS:
            out.append((path, df))
    if depth < max_depth:
        for sub in _coll_items(_safe(lambda: folder.dataFolders)):
            _collect_design_files(sub, f"{path}/{_safe(lambda: sub.name) or '?'}", out, depth + 1, max_depth)


def hub_project_names():
    """Names of the projects in the active hub (app.data.dataProjects:
    https://help.autodesk.com/cloudhelp/ENU/Fusion-360-API/files/core_Data.htm)."""
    return [str(_safe(lambda: p.name) or '?') for p in _coll_items(_safe(lambda: app.data.dataProjects))]


def scan_hub_projects(project_names, progress=None):
    """Opt-in scan: open each design in the named hub projects READ-ONLY and invisibly
    (Documents.open(dataFile, False): https://help.autodesk.com/cloudhelp/ENU/Fusion-360-API/files/core_Documents_open.htm),
    read its document tool library, and close it WITHOUT saving. Documents that were already open are used as
    they are and left open. `progress(done, total, label)` returns False to cancel. Returns
    (entries, report) with report = {opened, skipped: [(label, reason)], cancelled}."""
    wanted = set(project_names)
    files = []
    for proj in _coll_items(_safe(lambda: app.data.dataProjects)):
        pname = str(_safe(lambda: proj.name) or '?')
        if pname in wanted:
            _collect_design_files(proj.rootFolder, pname, files)
    open_ids = {}
    for d in _coll_items(app.documents):
        did = _safe(lambda: d.dataFile.id)
        if did:
            open_ids[did] = d
    entries, report = [], {"opened": 0, "skipped": [], "cancelled": False}
    total = len(files)
    for i, (path, df) in enumerate(files):
        label = f"{path}/{_safe(lambda: df.name) or '?'}"
        if progress and progress(i, total, label) is False:
            report["cancelled"] = True
            break
        doc, we_opened = open_ids.get(_safe(lambda: df.id)), False
        try:
            if doc is None:
                doc = app.documents.open(df, False)
                we_opened = True
            if doc is None:
                report["skipped"].append((label, "could not be opened"))
                continue
            cam = adsk.cam.CAM.cast(doc.products.itemByProductType('CAMProductType'))
            if not cam:
                report["skipped"].append((label, "no CAM data"))
                continue
            e = twlogic.harvest_entry(f"Hub: {label}", "hub", _library_tools_json(cam.documentToolLibrary))
            report["opened"] += 1
            if e:
                entries.append(e)
        except Exception as ex:
            _log(f"Scanning {label!r} failed", ex)
            report["skipped"].append((label, str(ex)[:120]))
        finally:
            if we_opened and doc is not None:
                try:
                    doc.close(False)     # never save
                except Exception as ex:
                    _log(f"Could not close {label!r}", ex)
    if progress:
        progress(total, total, "done")
    return entries, report


class ToolWizExportExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            eventArgs = adsk.core.CommandEventArgs.cast(args)
            inputs = eventArgs.command.commandInputs
            lib_select = inputs.itemById('libSelect')
            scan_in = inputs.itemById('scanHubProjects')
            proj_select = inputs.itemById('hubProjects')
            selected_items = [item.name for item in lib_select.listItems if item.isSelected] if lib_select else []
            scan_names = ([i.name for i in proj_select.listItems if i.isSelected]
                          if (scan_in and scan_in.value and proj_select) else [])
            if not selected_items and not scan_names:
                ui.messageBox('Please check at least one library (or a hub project to scan) to export.')
                return

            merge_input = inputs.itemById('mergeIntoMaster')
            dedup_input = inputs.itemById('autoDeduplicate')
            merge_into_master = merge_input.value if merge_input else True
            auto_dedup = dedup_input.value if dedup_input else False

            libraries_payload = harvest_selected(selected_items, discovered_libraries_map)
            scan_note = ""
            if scan_names:
                if ui.messageBox(
                        f"Scan {len(scan_names)} hub project(s)?\\n\\nEvery Fusion design in them is opened read-only "
                        "(not visible), its tool library is read, and it is closed without saving. This can take "
                        "minutes for large projects; you can cancel.",
                        "ToolWiz hub scan", adsk.core.MessageBoxButtonTypes.YesNoButtonType,
                        adsk.core.MessageBoxIconTypes.QuestionIconType) == adsk.core.DialogResults.DialogYes:
                    prog = ui.createProgressDialog()
                    prog.isCancelButtonShown = True
                    prog.show("ToolWiz hub scan", "Scanning %v of %m designs", 0, 100, 0)

                    def _progress(done, total, label):
                        prog.maximumValue = max(1, total)
                        prog.progressValue = min(done, max(1, total))
                        prog.message = f"%v of %m: {label[-60:]}"
                        try:
                            adsk.doEvents()          # let Fusion repaint and deliver the Cancel click
                        except Exception:
                            pass
                        return not prog.wasCancelled
                    try:
                        scanned, rep = scan_hub_projects(scan_names, _progress)
                    finally:
                        prog.hide()
                    libraries_payload += scanned
                    scan_note = (f"\\nHub scan: {rep['opened']} design(s) read, {len(rep['skipped'])} skipped"
                                 + (" (cancelled)" if rep['cancelled'] else "") + ".")
                    for lab, why in rep["skipped"][:8]:
                        scan_note += f"\\n   skipped {lab}: {why}"

            total_extracted_tools = sum(len(l["tools"]) for l in libraries_payload)
            if not libraries_payload:
                ui.messageBox("No tools found in the selected libraries to export." + scan_note)
                return

            if len(libraries_payload) > 1 or merge_into_master:
                payload = {
                    "libraries": libraries_payload,
                    "master_library_name": "Master_Shop_Tool_Crib",
                    "deduplicate": auto_dedup
                }
            else:
                payload = {
                    "libraries": libraries_payload,
                    "library_name": libraries_payload[0]["library_name"],
                    "tools": libraries_payload[0]["tools"],
                    "deduplicate": auto_dedup
                }

            # Post to ToolWiz server
            try:
                res_data = _http_json('/api/twin/export_receive', payload, timeout=60.0)
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
                    dedup_info = f"Duplicates Removed & Merged: {summary.get('duplicates_removed')}\\n"

                msg = (
                    f"Tool Libraries Exported Successfully!\\n"
                    f"====================================\\n"
                    f"Target Library: {lib_display_name}\\n"
                    f"Libraries Processed: {len(libraries_payload)}\\n"
                    f"Total Unique Tools: {final_count}\\n"
                    f"{dedup_info}"
                    f"Backup Snapshot: {backup_name}{scan_note}\\n\\n"
                    f"Next Steps:\\n"
                    f"1. Open {SERVER_BASE_URL} in your browser (Digital Twin Library Manager), or\\n"
                    f"2. run 'ToolWiz Master Library Builder' here to build one library per material set.\\n"
                    f"3. Click 'Import Digital Twin' in Fusion when done."
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
            discovered_libraries_map.update(discover_libraries())

            lib_select = inputs.addDropDownCommandInput('libSelect', 'Select Libraries to Export', adsk.core.DropDownStyles.CheckBoxDropDownStyle)
            for i, name in enumerate(discovered_libraries_map.keys()):
                lib_select.listItems.add(name, i == 0)

            inputs.addBoolValueCommandInput('mergeIntoMaster', 'Merge into Master Tool Crib', True, '', True)
            inputs.addBoolValueCommandInput('autoDeduplicate', 'Deduplicate Identical Cutters (merges same-geometry tools)', True, '', False)

            projects = hub_project_names()
            if projects:
                grp = inputs.addGroupCommandInput('hubScanGroup', 'Hub project scan (optional, slow)')
                grp.isExpanded = False
                grp.children.addBoolValueInput('scanHubProjects', 'Scan the documents of the chosen hub projects', True, '', False)
                dd = grp.children.addDropDownCommandInput('hubProjects', 'Hub projects', adsk.core.DropDownStyles.CheckBoxDropDownStyle)
                for p in projects:
                    dd.listItems.add(p, False)

            info = inputs.addTextBoxCommandInput('info', '', 'Select one or more libraries above (open documents, local, cloud and hub libraries). ToolWiz will consolidate your cutters, combine unique cutting presets, and eliminate redundant duplicates.', 3, True)
            info.isFullWidth = True

        except Exception as e:
            _report_error("Command Created failed.", e)

# ==============================================================================
# COMMAND 2: IMPORT DIGITAL TWIN
# ==============================================================================

def _local_library_dir():
    """Fusion's local library folder on disk (file fallback only)."""
    base = os.environ.get('APPDATA')
    if base:
        return os.path.join(base, 'Autodesk', 'CAM360', 'libraries', 'Local')
    return os.path.join(os.path.expanduser('~'), 'Library', 'Application Support', 'Autodesk', 'CAM360', 'libraries', 'Local')


def _find_library_url(tool_libs, root, name):
    """URL of the library called `name` (file extension ignored, case-insensitive) in the root of a
    location, else None. Only exact name matches count: other libraries are never touched."""
    want = name.strip().lower()
    for u in _coll_items(tool_libs.childAssetURLs(root)):
        leaf = _url_name(u)
        if leaf.lower() == want or os.path.splitext(leaf)[0].lower() == want:
            return u
    return None


def import_library_by_name(name, tools, location="local"):
    """Import `tools` as the library `name` in Fusion's local or cloud library location. A library of the same
    name is updated IN PLACE (ToolLibraries.updateToolLibrary), otherwise it is created
    (ToolLibraries.importToolLibrary); nothing else in the location is touched, so a rebuild never creates
    duplicates. Returns (status, detail) with status "updated", "created" or "file" (fallback: the JSON was
    written to the local library folder because the API call is unavailable or failed) and raises nothing.

    API: https://help.autodesk.com/cloudhelp/ENU/Fusion-360-API/files/cam_ToolLibraries.htm
         ToolLibrary.createFromJson: https://help.autodesk.com/cloudhelp/ENU/Fusion-360-API/files/cam_ToolLibrary.htm
    """
    text = json.dumps({"data": tools})
    why = ""
    try:
        tool_libs = adsk.cam.CAMManager.get().libraryManager.toolLibraries
        enum_name = "CloudLibraryLocation" if str(location).lower() == "cloud" else "LocalLibraryLocation"
        loc = getattr(adsk.cam.LibraryLocations, enum_name)
        root = tool_libs.urlByLocation(loc)
        new_lib = adsk.cam.ToolLibrary.createFromJson(text)
        if new_lib is None:
            raise ValueError("Fusion could not parse the library JSON")
        existing = _find_library_url(tool_libs, root, name)
        if existing is not None:
            if tool_libs.updateToolLibrary(existing, new_lib):
                return "updated", _url_name(existing)
            why = "updateToolLibrary returned False"
        else:
            url = tool_libs.importToolLibrary(new_lib, root, name)
            if url:
                return "created", _url_name(url)
            why = "importToolLibrary returned no URL"
    except Exception as e:
        why = f"{type(e).__name__}: {e}"
        _log(f"Importing library {name!r} through the Fusion API failed", e)
    try:
        d = _local_library_dir()
        os.makedirs(d, exist_ok=True)
        path = os.path.join(d, f"{name.replace(':', '_').replace('/', '_')}.json")
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        _log(f"Library {name!r} written to a file instead of the Fusion API: {why}")
        return "file", path
    except Exception as e2:
        _log(f"Writing library file for {name!r} failed", e2)
        return "failed", f"{why}; file write failed: {e2}"


class ToolWizImportExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()
    def notify(self, args):
        try:
            inputs = adsk.core.CommandEventArgs.cast(args).command.commandInputs
            location = "cloud" if _selected_name(inputs.itemById('importLocation')).lower().startswith("cloud") else "local"
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

            ac = AuditedCommand('import_digital_twin', target=f"library {lib_name} ({location})").begin()
            status, detail = import_library_by_name(lib_name, tools_list, location)
            note = ac.finish(f"{status}: {len(tools_list)} tools in {lib_name}",
                             target=detail if status == "file" else None)
            verb = {"updated": f"Updated the existing {location} library in place",
                    "created": f"Created the {location} library",
                    "file": "Saved the library file to your Fusion local libraries folder (the Fusion API call was not available)",
                    "failed": "Could not import the library"}[status]
            msg = (
                f"Digital Twin Ready for Synchronization!\n"
                f"====================================\n"
                f"Library: {lib_name}\n"
                f"Tools Processed: {len(tools_list)}\n\n"
                f"{verb}:\n{detail}\n\n"
                f"A library of the same name is updated, never duplicated. Your tools contain the ToolWiz presets in their Cutting Data tab."
            )
            if note:
                msg += "\n\n" + note
            ui.messageBox(msg, 'ToolWiz Digital Twin Import')

        except Exception as e:
            _finish_active_command(f"error: {e}")
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
            dd = cmd.commandInputs.addDropDownCommandInput('importLocation', 'Import into', adsk.core.DropDownStyles.TextListDropDownStyle)
            dd.listItems.add('Local libraries', True)
            dd.listItems.add('Cloud libraries', False)
        except Exception as e:
            _report_error("Command Created failed.", e)

# ==============================================================================
# COMMAND 3: FAST CAM OPERATION AUTO-SETTER
# ==============================================================================

def tool_profile_warnings(calc_result):
    """Warnings for the confirmation: problems the server found in the tool definition (e.g. shank
    equals a micro cutting diameter) and alerts meant for Fusion (e.g. runout vs chip load)."""
    prof = (calc_result or {}).get("profile") or {}
    out = [str(w) for w in (prof.get("warnings") or []) if w]
    for a in (calc_result or {}).get("alerts") or []:
        if isinstance(a, dict) and a.get("message"):
            out.append(f"{a.get('title') or 'Note'}: {a['message']}")
    return out


def _log_calc_exchange(payload, res):
    """One line with the tool geometry sent and one with what the server recommended / what capped it."""
    try:
        ft = (payload.get("fusion_tool") or {})
        g = ft.get("geometry") or {}
        geo = ", ".join(f"{k}={g[k]}" for k in ("DC", "NOF", "LCF", "shoulder-length", "shoulder-diameter",
                                                 "SFDM", "LB", "RE", "TA") if k in g)
        _log(f"Calc request: {payload.get('family')} / {payload.get('alloy')}, {payload.get('operation')}, "
             f"{payload.get('tool')} {payload.get('coating')}, aggressiveness {payload.get('aggressiveness')}; "
             f"tool [{ft.get('unit')}] {geo}")
        _log(f"Calc result: {res.get('rpm')} RPM, {res.get('feed', res.get('feedrate'))} IPM, DOC {res.get('doc')} in, "
             f"WOC {res.get('woc')} in, limited by {res.get('limited_by')}, feasible {res.get('feasible', True)}")
    except Exception as ex:
        _log("Could not log the calculation exchange", ex)


def confirm_feasibility(calc_result):
    """Return True if it is OK to apply the result. Asks the user (Yes/No) when the server reports
    "feasible": false OR raised any CRITICAL warning (no safe cut, holder collision, neck clearance,
    holistic-oversight STOP ...): nothing is written before an explicit Yes. A missing field counts as
    feasible and a result with only warnings/notes needs no confirmation."""
    if not isinstance(calc_result, dict):
        return True
    others = [f for f in twlogic.critical_findings(calc_result) if f.get("source") != "engine"]
    infeasible = calc_result.get("feasible", True) is False
    if not infeasible and not others:
        return True
    lines = []
    if infeasible:
        limited = _limited_by_text(calc_result.get("limited_by")) or "an unspecified limit"
        lines.append(f"No safe cut found \u2014 limited by {limited}.")
    if others:
        lines.append("CRITICAL warnings from ToolWiz:" if not infeasible else "Also critical:")
        for f in others:
            lines.append(f"- {f['title']}" + (f": {f['message']}" if f["message"] else ""))
    lines.append("")
    lines.append("Apply anyway?")
    res = ui.messageBox(
        "\n".join(lines),
        "ToolWiz \u2014 Critical Warning" if others else "ToolWiz \u2014 No Safe Cut Found",
        adsk.core.MessageBoxButtonTypes.YesNoButtonType,
        adsk.core.MessageBoxIconTypes.WarningIconType
    )
    return res == adsk.core.DialogResults.DialogYes


def fusion_tool_payload(geo_payload):
    """Canonical Fusion tool slice ({"type","unit","geometry","description","shaft","holder"}) of the op's raw
    tool JSON, or None when the raw JSON is unavailable/unparseable. The server builds ONE tool profile from
    it: shaft segments give slot / T-slot necks and stickout, the description identifies T-slot cutters."""
    try:
        raw = (geo_payload or {}).get("raw_json")
        t = json.loads(raw) if isinstance(raw, str) else raw
        return twlogic.fusion_tool_for_server(t)
    except Exception:
        return None


def _inspect_op_feature_geometry(op, geo_payload=None, woc_in=None):
    """Safely inspect live B-Rep geometry (feature depth, corner radius, wall/floor thickness)
    on `op`. Returns a compact dict if any B-Rep metric was found, else None."""
    if op is None:
        return None
    try:
        dia = (geo_payload or {}).get("diameter")
        stick = (geo_payload or {}).get("stickout")
        rep = inspect_operation_geometry(op, tool_diameter_in=dia, stickout_in=stick, nominal_woc_in=woc_in)
        d = rep.to_dict()
        if any(d.get(k) is not None for k in (
            "feature_depth_in", "min_corner_radius_in", "min_wall_thickness_in", "min_floor_thickness_in"
        )):
            return d
    except Exception as ex:
        _log("B-Rep feature geometry inspection failed", ex)
    return None


def _is_hole_or_tap_mode(geo_payload, strategy):
    """True when the tool or selected strategy is a hole-making or tapping operation."""
    gp = geo_payload or {}
    if gp.get("isHoleTool") or gp.get("isTap"):
        return True
    s = str(strategy or "").strip().lower()
    return any(k in s for k in ("drill", "ream", "tap", "bore"))


def build_calc_payload(geo_payload, family, alloy, strategy, aggressiveness, selected_grade, selected_coating_raw,
                       feature_geometry=None, runout_in=None, model=None, engagement=None):
    """Build the /api/calculate_for_fusion request body (all lengths in inches).

    `runout_in`: tool runout (TIR, inches); defaults to the tool's own value, else 0.0002 in. `model`: the
    cutting model to use ("v1"/"v2"), sent explicitly when known. `engagement`: {"stepdown", "stepover"} in
    inches, the operation's own values (the server then computes rpm/feed for that engagement)."""
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

    grade = selected_grade.lower()
    is_carbide = "hss" not in grade and "cobalt" not in grade
    kind = str((geo_payload or {}).get("kind", "")).lower()
    is_tap = bool((geo_payload or {}).get("isTap")) or "tap" in str(strategy or "").lower()
    is_hole = bool((geo_payload or {}).get("isHoleTool")) or _is_hole_or_tap_mode(geo_payload, strategy)
    strat_low = str(strategy or "").lower()
    geo_name = geo_payload.get("geometry", "Square")
    tap_type = ""
    pitch_val = (geo_payload or {}).get("threadPitch")

    if is_tap:
        tool_category = "Tapping"
        raw_desc = f"{(geo_payload or {}).get('desc', '')} {(geo_payload or {}).get('tool_type', '')}".lower()
        if "form" in strat_low or "roll" in strat_low or "form" in raw_desc or "roll" in raw_desc:
            tap_type = "form"
        elif "spiral point" in strat_low or "gun" in strat_low or "spiral point" in raw_desc:
            tap_type = "spiral_point"
        elif "straight" in strat_low or "hand" in strat_low:
            tap_type = "straight_flute"
        elif "spiral flute" in strat_low or "spiral" in raw_desc:
            tap_type = "spiral_flute"
        else:
            tap_type = str(geo_name) if str(geo_name) in ("form", "spiral_flute", "spiral_point", "straight_flute") else "form"
        geo_name = tap_type
    elif kind == "reamer" or "ream" in strat_low:
        tool_category = "Carbide Reamer" if is_carbide else "HSS Reamer"
        geo_name = "Reamer"
    elif kind in ("spot_drill", "center_drill"):
        tool_category = "Carbide Twist Drill" if is_carbide else "HSS Spot Drill"
        geo_name = "Spot Drill"
    elif is_hole:
        if "hp" in grade or "high performance" in grade:
            tool_category = "HP Carbide Twist Drill"
        elif "hss" in grade:
            tool_category = "HSS Twist Drill"
        elif "cobalt" in grade:
            tool_category = "Cobalt Twist Drill"
        else:
            tool_category = "Carbide Twist Drill"
        if geo_name not in ("Drill", "Spot Drill", "Parabolic"):
            geo_name = "Drill"
    else:
        # A high-feed end mill named in the tool's description or type ("high feed", "HF", "HFM"): the server's v2 model runs
        # it as one (lead-edge chip thinning, max ap, ramp guidance) when the geometry says "High Feed".
        _desc = f"{(geo_payload or {}).get('desc', '')} {(geo_payload or {}).get('tool_type', '')}".lower()
        if re.search(r"high[\s_-]?feed|\bhfm?\b", _desc):
            geo_name = "High Feed"
        if "hp" in grade or "high performance" in grade:
            tool_category = "HP Carbide Endmill"  # bull nose / high feed is carried by "geometry"
        elif "hss" in grade:
            tool_category = "HSS Endmill"
        elif "cobalt" in grade:
            tool_category = "Cobalt Endmill"
        else:
            tool_category = "Carbide Endmill"

    ft = fusion_tool_payload(geo_payload)
    # Brand (owner decisions 2026-11-12): the tool's vendor, so the server uses that vendor's charts; sent as `brand` when the
    # fusion tool slice does not carry it (no raw tool JSON), blank = unbranded.
    brand = None
    if not (ft or {}).get("vendor"):
        try:
            raw = (geo_payload or {}).get("raw_json")
            brand = twlogic.tool_vendor(json.loads(raw) if isinstance(raw, str) else raw) or (geo_payload or {}).get("vendor")
        except Exception:
            brand = (geo_payload or {}).get("vendor")
    # Runout: the dialog's value, else the tool's own toolwiz.runout_*; otherwise it is not sent and the server
    # picks it from the holder class, else by tool diameter (0.0001 in up to 1/8 in, 0.0002 in above).
    if runout_in is None and (geo_payload or {}).get("runout_source") == "tool":
        runout_in = (geo_payload or {}).get("runout_in")
    return {
        "family": family, "alloy": alloy, "operation": strategy, "aggressiveness": aggressiveness,
        "tool": tool_category, "coating": coating_code, "isCarbide": is_carbide,
        **({"runout": float(runout_in)} if runout_in is not None else {}),
        **({"model": model} if model else {}),
        **({"brand": str(brand)} if brand else {}),
        **(engagement or {}),
        **({"fusion_tool": ft} if ft else {}),
        "diameter": geo_payload["diameter"], "flutes": geo_payload["flutes"], "fluteLength": geo_payload["fluteLength"],
        "shankDiameter": geo_payload["shankDiameter"], "cornerRadius": geo_payload["cornerRadius"],
        "stickout": geo_payload["stickout"], "geometry": geo_name,
        **({"tapType": tap_type} if tap_type else {}),
        **({"pitch": float(pitch_val)} if (is_tap and pitch_val and float(pitch_val) > 0) else {}),
        **({"feature_geometry": feature_geometry} if feature_geometry else {}),
        **({"hasRelievedNeck": True, "neckLength": geo_payload["neckLength"],
            "neckDiameter": geo_payload["neckDiameter"]} if geo_payload.get("neckLength") else {}),
    }


def _close(a, b, rel):
    try:
        return abs(float(a) - float(b)) <= abs(float(b)) * rel + 1e-9
    except (TypeError, ValueError):
        return False


def _iter_params(params):
    """Iterate a Fusion CAMParameters collection (iterable in newer APIs, count/item in older)."""
    try:
        return list(params)
    except TypeError:
        try:
            return [params.item(i) for i in range(params.count)]
        except Exception:
            return []


# Preset fields Fusion links to other fields by formula. Writing numbers into them (as earlier
# versions did) made the preset's expressions differ from the operation's formulas, and Fusion
# flags that as '(custom)' even when the values are equal. The operation's own formula is used
# when it has one; otherwise Fusion's standard link.
LINKED_PRESET_FORMULAS = {
    'tool_rampSpindleSpeed': 'tool_spindleSpeed',
    'tool_feedEntry': 'tool_feedCutting',
    'tool_feedExit': 'tool_feedCutting',
    'tool_feedPerTooth': 'tool_spindleSpeed > 0 ? tool_feedCutting/(tool_spindleSpeed * tool_numberOfFlutes) : 0.0',
    'tool_feedPerRevolution': 'tool_spindleSpeed > 0 ? tool_feedPlunge/tool_spindleSpeed : 0.0',
    'tool_surfaceSpeed': 'tool_diameter * Math.PI * tool_spindleSpeed',
}
OP_NAME_FOR_PRESET = {'tool_rampSpindleSpeed': ('tool_rampSpindleSpeed', 'tool_spindleSpeedRamp')}


def _is_formula(expr):
    return isinstance(expr, str) and 'tool_' in expr


def _restore_linked_formulas(params, target_op, ctx=None):
    """Put formulas (not numbers) back into the preset's linked fields."""
    op_params = getattr(target_op, 'parameters', None) if target_op is not None else None
    restored = []
    for name, standard in LINKED_PRESET_FORMULAS.items():
        p_obj = _param(params, name)
        if p_obj is None:
            continue
        formula = standard
        for op_name in OP_NAME_FOR_PRESET.get(name, (name,)):
            o_obj = _param(op_params, op_name)
            if o_obj is not None and _is_formula(getattr(o_obj, 'expression', None)):
                formula = o_obj.expression
                break
        try:
            if getattr(p_obj, 'expression', None) != formula:
                _set_preset_param(ctx, p_obj, name, formula)
                restored.append(name)
        except Exception as ex:
            _log(f"Could not restore formula for preset field {name!r}", ex)
    if restored:
        _log("Restored linked formulas in preset: " + ", ".join(restored))


def _set_preset_steps(params, doc_in, woc_in, ctx=None):
    """Write stepdown/stepover into a preset by matching parameter names (Fusion doesn't document
    the preset parameter ids), enabling their 'use' flags. Logs the preset's parameter names."""
    names = [getattr(p, 'name', '') for p in _iter_params(params)]
    _log("Preset parameters: " + ", ".join(n for n in names if n))
    written = []
    for p_obj in _iter_params(params):
        n = str(getattr(p_obj, 'name', '')).lower()
        try:
            field = str(getattr(p_obj, 'name', n))
            if 'use' in n and ('stepdown' in n or 'stepover' in n):
                _set_preset_param(ctx, p_obj, field, 'true')
            elif 'stepdown' in n and doc_in:
                _set_preset_param(ctx, p_obj, field, f"{doc_in:.5f} in"); written.append(n)
            elif ('stepover' in n or 'optimalload' in n) and woc_in:
                _set_preset_param(ctx, p_obj, field, f"{woc_in:.5f} in"); written.append(n)
        except Exception as ex:
            _log(f"Could not set preset parameter {n!r}", ex)
    return written


def _expr_number(expr):
    m = re.search(r'[-+]?\d*\.?\d+', str(expr or ''))
    return float(m.group(0)) if m else None


def _preset_has_value(tool, preset_name, param_name, expected_expr):
    """True if `tool` has preset `preset_name` whose `param_name` numerically equals expected_expr."""
    want = _expr_number(expected_expr)
    for pr in getattr(tool, 'presets', []) or []:
        if getattr(pr, 'name', None) != preset_name:
            continue
        try:
            p_obj = pr.parameters.itemByName(param_name)
            have = _expr_number(getattr(p_obj, 'expression', None)) if p_obj else None
        except Exception:
            have = None
        return want is None or (have is not None and abs(have - want) <= max(abs(want) * 0.001, 1e-6))
    return False


# Values that must match for an edit to count as applied. Secondary feeds (entry/exit/
# transition/ramp/plunge) are excluded: Fusion may store them as formulas such as
# 'tool_feedCutting', which made the check fail falsely and trigger a copy assignment.
VERIFY_PARAMS = ('tool_spindleSpeed', 'tool_feedCutting')


def _preset_matches(tool, preset_name, speed_values):
    """True when the named preset on `tool` holds the key values (VERIFY_PARAMS) we wrote.
    Checking only spindle speed missed lost feed edits; checking every field gave false
    negatives on formula-valued feeds."""
    verify_keys = VERIFY_PARAMS if any(k == 'tool_feedCutting' for k, _ in speed_values) else ('tool_spindleSpeed', 'tool_feedPlunge')
    for p_name, p_val in speed_values:
        if p_name not in verify_keys:
            continue
        found = False
        for pr in getattr(tool, 'presets', []) or []:
            if getattr(pr, 'name', None) != preset_name:
                continue
            found = True
            try:
                p_obj = pr.parameters.itemByName(p_name)
            except Exception:
                p_obj = None
            if p_obj is not None and not _preset_has_value(tool, preset_name, p_name, p_val):
                return False
        if not found:
            return False
    return True


def _refresh_operations_from_preset(target_op, preset_name=None):
    """Re-apply the (already updated) preset to THIS operation only, by re-linking it to the
    preset object read fresh from the operation's tool. Other operations are untouched."""
    try:
        tool = getattr(target_op, 'tool', None)
        name = preset_name or getattr(getattr(target_op, 'toolPreset', None), 'name', None)
        fresh = next((pr for pr in (getattr(tool, 'presets', []) or []) if getattr(pr, 'name', None) == name), None)
        if fresh is None:
            return False
        before = _doc_tool_count()
        _assign_tool_preset(target_op, fresh, "refresh operation from updated preset")
        after = _doc_tool_count()
        _log(f"Re-applied preset {name!r} to this operation; document tools {before} -> {after}"
             + ("  (WARNING: tool count changed)" if before is not None and after != before else ""))
        return True
    except Exception as ex:
        _log("Re-applying preset to the operation failed", ex)
        return False


def _write_tool_back(target_op, tool, preset_name, speed_values):
    """Persist edits made on the operation.tool copy by updating the EXISTING document tool in
    place (documentToolLibrary.update). The copy is never assigned to the operation: Fusion
    adds an edited copy as a new document tool (log: 64 -> 65 tools). If the in-place update
    can't be confirmed, the caller falls back to operation values."""
    try:
        cam = adsk.cam.CAM.cast(app.activeDocument.products.itemByProductType('CAMProductType'))
        lib = cam.documentToolLibrary if cam else None
        if lib is None or not hasattr(lib, 'update'):
            _log("documentToolLibrary.update not available in this Fusion version")
            return "none (no documentToolLibrary.update)"
        # updateFeedAndSpeed stays False: True would push preset values into EVERY operation using
        # this tool, silently overwriting toolpaths the user deliberately customised (64 ops in the
        # user's document differ from their presets). Only the target operation is refreshed,
        # by re-linking it below.
        result = lib.update(tool, False)
        _log(f"documentToolLibrary.update returned {result!r}")
        _audit_preset(_preset_ctx(target_op, tool, preset_name, preset_name),
                      "documentToolLibrary.update(updateFeedAndSpeed=False)", None, repr(result))
        if _preset_matches(getattr(target_op, 'tool', None), preset_name, speed_values):
            return "documentToolLibrary.update"
        return "documentToolLibrary.update (not confirmed on operation)"
    except Exception as ex_lib:
        _log("documentToolLibrary.update failed", ex_lib)
        return "none (update failed)"


def _doc_tool_count():
    """Number of tools in the document tool library (None if unavailable); used to detect copies."""
    try:
        cam = adsk.cam.CAM.cast(app.activeDocument.products.itemByProductType('CAMProductType'))
        lib = cam.documentToolLibrary if cam else None
        return lib.count if lib is not None else None
    except Exception:
        return None


def _upsert_preset_in_place(target_op, preset_name, replace_name, speed_values, doc_in=None, woc_in=None):
    """Find the preset to replace (or one already named `preset_name`) on the operation's tool,
    else add one; set its speed/feed parameters with explicit units. Returns (preset, was_updated).
    The tool object itself is never replaced, so Fusion keeps a single copy of the tool."""
    tool = getattr(target_op, 'tool', None)
    presets = getattr(tool, 'presets', None) if tool else None
    if presets is None:
        _log("Operation tool exposes no presets collection; cannot update cutting data in place")
        return None, False

    def find(name):
        if not name:
            return None
        for pr in presets:
            if getattr(pr, 'name', None) == name:
                return pr
        return None

    target = None
    if replace_name and replace_name != "+ Create New Preset (Auto-Named)":
        target = find(replace_name)
    if target is None:
        target = find(preset_name)
    was_updated = target is not None
    if target is None:
        try:
            target = presets.add()
        except Exception as ex_add:
            _log("Could not add a preset to the tool", ex_add)
            audit({'event': 'preset_change', 'field': 'presets.add', 'new': preset_name, 'ok': False,
                   'error': str(ex_add)})
            return None, False

    name_before = _safe(lambda: target.name)
    ctx = _preset_ctx(target_op, tool, name_before, preset_name)
    try:
        target.name = preset_name
        _audit_preset(ctx, 'name', name_before, _safe(lambda: target.name) or preset_name)
    except Exception as ex_name:
        _log("Could not rename preset", ex_name)
        _audit_preset(ctx, 'name', name_before, preset_name, ok=False, error=str(ex_name))
    if not was_updated:
        _audit_preset(ctx, 'preset_created', None, preset_name)
    params = getattr(target, 'parameters', None)
    if params is None:
        _log("Preset exposes no parameters; values not written")
    else:
        for p_name, p_val in speed_values:
            try:
                p_obj = params.itemByName(p_name)
                if p_obj:
                    _set_preset_param(ctx, p_obj, p_name, p_val)
                else:
                    _log(f"Preset has no parameter {p_name!r}")
            except Exception as ex_p:
                _log(f"Could not set preset parameter {p_name!r}", ex_p)
        _restore_linked_formulas(params, target_op, ctx)
        steps = _set_preset_steps(params, doc_in, woc_in, ctx)
        if not steps:
            _log("Preset has no stepdown/stepover parameters; DOC/WOC will be written to the operation")

    # operation.tool returns a COPY: edits only reach the operation when the edited tool is
    # assigned back (same tool, same id). Check the live preset's values, not just its name;
    # a replaced preset keeps its name, so a name check missed lost edits.
    live = getattr(target_op, 'tool', None)
    if live is not None and not _preset_matches(live, preset_name, speed_values):
        before = _doc_tool_count()
        method = _write_tool_back(target_op, tool, preset_name, speed_values)
        live = getattr(target_op, 'tool', None)
        after = _doc_tool_count()
        _log(f"Wrote edited tool back via {method}; document tools {before} -> {after}"
             + ("  (WARNING: tool count changed)" if before is not None and after != before else ""))
        if not _preset_matches(live, preset_name, speed_values):
            _log("Edited preset values still not visible on the operation's tool after writing it back")
    for pr in getattr(live, 'presets', []) or []:
        if getattr(pr, 'name', None) == preset_name:
            return pr, was_updated
    # Never link a preset that belongs to a detached copy of the tool: Fusion would attach
    # that copy to the document as an extra tool. The caller falls back to operation values.
    _log(f"Preset {preset_name!r} not found on the operation's tool; not linking a detached copy")
    return None, was_updated


def run_autoset(target_op, op_name, family, alloy, strategy, aggressiveness,
                target_preset_to_replace, selected_grade, selected_coating_raw,
                runout_in=None, use_op_engagement=True, apply_rec_stock=False, model=None, tslot_opts=None,
                finish_opts=None):
    """Calculate cutting data on the server and write it to the operation's tool preset.

    `runout_in`: runout from the dialog (inches), else the tool's own toolwiz.runout_*, else 0.0002 in.
    `use_op_engagement`: send the operation's own stepdown/stepover so rpm/feed are computed for them.
    `apply_rec_stock`: also write ToolWiz's recommended stock to leave to the operation (otherwise the result
    dialog offers it). `model`: cutting model to send (None: the server's setting). `tslot_opts`: T-slot
    request fields (tslotOperation, slotHeight, radialDepthTotal). `finish_opts`: {"mode", "ra_uin", "wall_in"}
    for finishing operations (sent as finishMode / targetRa / wallTolerance)."""
    geo_payload, summary_str, existing_presets = get_op_tool_info(target_op)
    if not geo_payload:
        _log(f"Auto-setter: tool geometry unreadable for {op_name}: {summary_str}")
        ui.messageBox(f'Could not read tool geometry for {op_name}:\n{summary_str}\n\nDetails: {_log_path()}',
                      'ToolWiz CAM Auto-Setter')
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

    is_hole_mode = _is_hole_or_tap_mode(geo_payload, strategy)
    is_tap_mode = bool((geo_payload or {}).get("isTap")) or "tap" in str(strategy or "").lower()
    if is_tap_mode and not (geo_payload.get("threadPitch") and float(geo_payload.get("threadPitch") or 0.0) > 0.0):
        _log(f"Auto-setter: tap tool on {op_name!r} has no thread pitch (TP) set in Fusion")
        ui.messageBox(
            "This tap has no Thread Pitch (TP) defined in its Fusion tool geometry, so ToolWiz cannot compute "
            "its synchronized tapping feedrate (RPM × Pitch).\n\n"
            "Set the Thread Pitch on the tap in the Fusion Tool Library (Cutter tab) and run this command again.",
            "ToolWiz CAM Auto-Setter"
        )
        return False

    fg = None if is_hole_mode else _inspect_op_feature_geometry(target_op, geo_payload)
    doc_unit = get_cam_document_units()
    engagement = {}
    op_doc0 = op_woc0 = 0.0
    if not is_hole_mode and use_op_engagement:
        _, _, op_doc0, op_woc0 = get_op_cut_params(target_op, doc_unit, strategy=strategy)
        engagement = twlogic.engagement_fields(op_doc0, op_woc0, True)
    # 2D Contour with multiple stepovers: the first pass is a full-width slot (ae = D), the others are side passes (ae = stepover).
    # One feed serves the whole op, so ToolWiz runs the limiting pass: the full slot at the op's stepdown (calc strategy
    # "Slotting", stepover = D). The op's own stepover is kept (never overwritten by D below).
    ms = None
    calc_strategy = strategy
    if not is_hole_mode and not twlogic.is_finishing_strategy(strategy, op_name):
        ms = read_multi_stepover(target_op, doc_unit)
        if ms and ms.get("enabled") and (ms.get("count") or 0) >= 2:
            d_tool = twlogic.num((geo_payload or {}).get("diameter"), 0.0)
            if d_tool:
                engagement = dict(twlogic.engagement_fields(op_doc0, d_tool, True)) if use_op_engagement else {"stepover": round(d_tool, 6)}
                if not use_op_engagement:
                    engagement.pop("stepdown", None)
                calc_strategy = "Slotting"
                _log(f"Auto-setter: {op_name!r} has {ms['count']} stepovers of {ms.get('stepover_in')} in: using the full-slot pass (ae = D) numbers")
            else:
                ms = None
        else:
            ms = None
    payload = build_calc_payload(geo_payload, family, alloy, calc_strategy, aggressiveness, selected_grade, selected_coating_raw,
                                 feature_geometry=fg, runout_in=runout_in, model=model or _model_cache.get("model"),
                                 engagement=engagement)
    payload["isMetric"] = twlogic.is_metric(doc_unit)
    if isinstance(payload, dict):
        payload.update(tslot_opts or {})
        if finish_opts and not is_hole_mode and twlogic.is_finishing_strategy(strategy, op_name):
            payload.update(twlogic.finish_fields(finish_opts.get("mode"), finish_opts.get("ra_uin"), finish_opts.get("wall_in")))
            _finish_prefs[op_name] = dict(finish_opts)
    tools_at_start = _doc_tool_count()
    _log_custom_diff(target_op, label="BEFORE auto-set")
    _log_op_motion_params(target_op, "BEFORE")

    try:
        calc_result = _http_json('/api/calculate_for_fusion', payload, timeout=10.0)
    except (urllib.error.URLError, OSError, ValueError):
        if ui:
            ui.messageBox(_offline_message("calculate speeds & feeds"), "Tool Wizard Server Offline")
        return False

    if not calc_result.get("success"):
        _log(f"calculate_for_fusion failed: {calc_result.get('error')}")
        ui.messageBox(f"The server could not calculate cutting data:\n{calc_result.get('error')}\n\nDetails: {_log_path()}",
                      "ToolWiz CAM Auto-Setter")
        return False

    _log_calc_exchange(payload, calc_result)
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
    if calc_result.get("engagement_source") == "user":
        # rpm/feed were computed for the operation's own stepdown/stepover: write those back (they are
        # unchanged), never the recommendation, so the feed still matches the engagement it was made for.
        doc = calc_result.get("engagement_doc") or doc
        woc = calc_result.get("engagement_woc") or woc
    ms_note = None
    if ms:
        woc = ms.get("stepover_in") or woc      # keep the op's own stepover; the calculation's ae = D is the slot pass only
        ms_note = multi_stepover_note(ms, geo_payload, calc_result, payload, aggressiveness, doc)
    if is_hole_mode:
        ramp_feed = feed
        plunge_feed = feed
    else:
        ramp_feed = calc_result.get("ramp_feed", feed * 0.5)
        plunge_feed = calc_result.get("plunge_feed", feed * 0.25)
        if plunge_feed <= 0:
            plunge_feed = ramp_feed if ramp_feed > 0 else (feed * 0.25 if feed > 0 else 5.0)
        if ramp_feed <= 0:
            ramp_feed = feed * 0.5 if feed > 0 else 10.0
    sfm = calc_result.get("sfm", 300)
    ipt = calc_result.get("ipt", 0.002)

    final_preset_name = calc_result["name"]
    if is_hole_mode:
        speed_values = [
            ('tool_spindleSpeed', f"{rpm} rpm"),
            ('tool_feedPlunge', f"{plunge_feed:.2f} in/min"),
        ]
    else:
        speed_values = [
            ('tool_spindleSpeed', f"{rpm} rpm"),
            ('tool_feedCutting', f"{feed:.2f} in/min"),
            ('tool_feedRamp', f"{ramp_feed:.2f} in/min"),
            ('tool_feedPlunge', f"{plunge_feed:.2f} in/min"),
            ('tool_feedTransition', f"{feed * 1.5:.2f} in/min"),
        ]
    ramp_expr = None if is_hole_mode else ramp_angle_expr(calc_result)
    if ramp_expr is not None:
        # Operations follow the preset (rampAngle = 'tool_rampAngle'); one with its own value keeps it.
        speed_values.append(('tool_rampAngle', ramp_expr))

    # 0. Replace safety: other operations on the same tool that are linked to the preset about to be
    #    edited/renamed would change too. Ask before touching anything; No leaves everything as is.
    if not check_replace_safety(target_op, op_name, target_preset_to_replace, final_preset_name):
        _log(f"Auto-setter: replace of a shared preset cancelled for {op_name!r}; nothing changed")
        return False

    # 1. Update (or add) the preset IN PLACE on the operation's own tool. Building a new tool
    #    from JSON (Tool.createFromJson) made Fusion add a second copy of the tool, and the
    #    JSON-written preset values were not unit-safe; preset parameters set with explicit
    #    units are converted by Fusion itself.
    preset_obj, was_updated = _upsert_preset_in_place(target_op, final_preset_name,
                                                      target_preset_to_replace, speed_values,
                                                      doc_in=None if is_hole_mode else doc,
                                                      woc_in=None if is_hole_mode else woc)
    _log(f"  after preset update: document tools {_doc_tool_count()}")

    # 2. Link the preset to the operation, unless it is already linked to it. Re-linking hands
    #    Fusion a preset object from a copy of the tool, which can add that copy as a new
    #    document tool (log: 65 -> 66 with no other write).
    preset_linked = False
    current = getattr(target_op, 'toolPreset', None)
    if preset_obj is not None and getattr(current, 'name', None) == final_preset_name:
        preset_linked = True
        _log(f"  operation already linked to {final_preset_name!r}; not re-linking")
    elif preset_obj is not None:
        try:
            _assign_tool_preset(target_op, preset_obj, "link auto-set preset to operation")
            preset_linked = True
        except Exception as ex_set:
            _log("Could not activate preset on operation", ex_set)
        _log(f"  after linking preset: document tools {_doc_tool_count()}")

    # 3. Write the operation's own feed/speed only if the linked preset did not deliver the
    #    calculated values. Writing them unconditionally is what made Fusion show a second
    #    'Preset (custom)' entry next to the real preset.
    op_rpm, op_feed, _, _ = get_op_cut_params(target_op, doc_unit, strategy=strategy)
    if preset_linked and not (_close(op_rpm, rpm, 0.01) and _close(op_feed, feed, 0.01)):
        # The preset may already hold the new values (nothing to write back) while the operation
        # still has old ones: ask Fusion to re-apply the tool's presets to its operations.
        if _refresh_operations_from_preset(target_op, final_preset_name):
            op_rpm, op_feed, _, _ = get_op_cut_params(target_op, doc_unit, strategy=strategy)
    preset_ok = preset_linked and _close(op_rpm, rpm, 0.01) and _close(op_feed, feed, 0.01)
    if not preset_ok:
        _log(f"Preset values not in effect on {op_name!r} (linked={preset_linked}, op rpm={op_rpm:.0f} "
             f"feed={op_feed:.2f} IPM vs calculated {rpm} / {feed:.2f}); writing operation parameters")
        primary_feeds = ('tool_spindleSpeed', 'tool_feedCutting', 'tool_feedPlunge') if is_hole_mode else ('tool_spindleSpeed', 'tool_feedCutting')
        for p_name, p_val in speed_values:
            apply_param(target_op, p_name, p_val, force=(p_name not in primary_feeds))
    _log_speed_sources(target_op)
    _log_custom_diff(target_op)
    tool_updated = preset_obj is not None
    if is_hole_mode:
        passes_notes = []
        fine_note = None
        ramp_dia_note = None
        woc_applied = False
        doc_applied = False
    else:
        passes_notes = apply_passes_tab_params(target_op, strategy, doc, woc,
                                               calc_result=calc_result, geo_payload=geo_payload)
        fine_note = apply_fine_stepdown_floor(target_op, override_custom=True)
        ramp_dia_note = apply_ramp_diameter(target_op, calc_result.get("ramp_diameter_in"), override_custom=True)
        if ramp_expr is not None:
            p_ra = _safe(lambda: target_op.parameters.itemByName('rampAngle'))
            if p_ra is not None and isinstance(_safe(lambda: p_ra.expression), str):
                if _norm_expr(_safe(lambda: p_ra.expression)) != 'tool_rampangle':
                    apply_param(target_op, 'rampAngle', 'tool_rampAngle', force=True)

        # DOC/WOC: the preset carries them (above). Write the operation's own step parameters only
        # if the linked preset didn't deliver them, because any operation value that differs from
        # its preset makes Fusion show 'Preset (custom)'.
        _, _, op_doc, op_woc = get_op_cut_params(target_op, doc_unit, strategy=strategy)
        woc_applied = preset_linked and _close(op_woc, woc, 0.01)
        doc_applied = preset_linked and _close(op_doc, doc, 0.01)
        if not woc_applied:
            _log(f"WOC from preset not in effect (op {op_woc:.5f} vs {woc:.5f} in); writing operation parameter")
            if "Adaptive" in strategy:
                woc_applied = bool(apply_param(target_op, 'optimalLoad', f"{woc:.5f} in"))
            elif "finish" in str(strategy).lower() and "semi" not in str(strategy).lower():
                woc_applied = bool(apply_param(target_op, 'finishingStepover', f"{woc:.5f} in")
                                   or apply_param(target_op, 'stepover', f"{woc:.5f} in")
                                   or apply_param(target_op, 'maximumStepover', f"{woc:.5f} in"))
            else:
                woc_applied = bool(apply_param(target_op, 'stepover', f"{woc:.5f} in")
                                   or apply_param(target_op, 'maximumStepover', f"{woc:.5f} in"))
        if not doc_applied:
            _log(f"DOC from preset not in effect (op {op_doc:.5f} vs {doc:.5f} in); writing operation parameter")
            doc_applied = bool(apply_param(target_op, 'maximumStepdown', f"{doc:.5f} in"))

    _log_op_motion_params(target_op, "AFTER")
    _log_preset_use_flags(target_op, final_preset_name)
    _regenerate_toolpath(target_op)
    tools_at_end = _doc_tool_count()
    _log(f"Auto-set {op_name!r}: T{t_num}, document tools {tools_at_start} -> {tools_at_end}"
         + ("  (WARNING: a tool was added)" if tools_at_start is not None and tools_at_end != tools_at_start else ""))

    preset_note = f"Preset: {final_preset_name} ({'replaced' if was_updated else 'added'} on the existing tool)"
    if not preset_ok:
        preset_note = (f"Preset: {final_preset_name} could not be updated in place, so the values were applied "
                       f"to this operation only (Fusion shows it as custom). No tool was created. "
                       f"Details: {_log_path()}")
    msg = format_autoset_message(
        tool_label(t_num), geo_payload, material_label, strategy, rpm, feed, ipt,
        doc=doc if doc_applied else None, woc=woc if woc_applied else None,
        limited_by=calc_result.get("limited_by"), provenance=calc_result.get("provenance"),
        preset_note=preset_note, model=calc_result.get("model"), model_note=calc_result.get("model_note", ""),
    )
    if passes_notes:
        msg += "\n\nPasses Tab: " + "; ".join(passes_notes) + "."
    if ms_note:
        msg += "\n\n" + ms_note
    for w in tool_profile_warnings(calc_result):
        msg += "\n\nCheck: " + w
    if ramp_expr is not None:
        msg += f"\n\nRamp angle: {float(ramp_expr):.2f}°."
    if ramp_dia_note == 'written':
        msg += f"\nHelical ramp diameter: {float(calc_result.get('ramp_diameter_in')):.4f}\"."
    elif ramp_dia_note == 'kept':
        msg += "\nHelical ramp diameter: your own value was kept."
    if fine_note == 'written':
        msg += ("\n\nFine stepdown: set to 25% of the stepdown, at least 0.05 mm "
                "(Fusion's default of 10% made very large programs).")
    elif fine_note == 'kept':
        msg += "\n\nFine stepdown: your own value was kept."
    extra = twlogic.format_advisor_sections(calc_result, flutes_total=geo_payload.get("flutes"), unit=doc_unit)
    if extra:
        msg += "\n\n" + extra
    rec_rad, rec_ax = twlogic.stock_recommendation(calc_result)
    stock_msg, offer_stock = "", False
    if not is_hole_mode and (rec_rad is not None or rec_ax is not None) and op_supports_stock_to_leave(target_op):
        rad_expr = twlogic.fmt_len(rec_rad or 0.0, doc_unit)
        ax_expr = twlogic.fmt_len(rec_ax or 0.0, doc_unit)
        if apply_rec_stock:
            failed = apply_stock_to_op(target_op, rad_expr, ax_expr)
            stock_msg = (f"Stock to leave written: radial {rad_expr}, axial {ax_expr}." if not failed
                         else f"Stock to leave could not be written: {', '.join(failed)}.")
        else:
            offer_stock = True
    note = _finish_active_command('ok')
    if note:
        msg += "\n\n" + note
    if stock_msg:
        msg += "\n\n" + stock_msg
    if offer_stock:
        res = ui.messageBox(
            msg + f"\n\nApply the recommended stock to leave (radial {rad_expr}, axial {ax_expr}) to this operation now?",
            'ToolWiz CAM Auto-Setter', adsk.core.MessageBoxButtonTypes.YesNoButtonType,
            adsk.core.MessageBoxIconTypes.QuestionIconType)
        if res == adsk.core.DialogResults.DialogYes:
            ac2 = AuditedCommand('autoset_stock', target=op_name, targets=[op_name]).begin()
            failed = apply_stock_to_op(target_op, rad_expr, ax_expr)
            note2 = ac2.finish("ok" if not failed else f"failed: {failed}")
            ui.messageBox((f"Stock to leave written: radial {rad_expr}, axial {ax_expr}." if not failed
                           else f"Stock to leave could not be written: {', '.join(failed)}.")
                          + (("\n\n" + note2) if note2 else ""), 'ToolWiz CAM Auto-Setter')
        return True
    ui.messageBox(msg, 'ToolWiz CAM Auto-Setter')
    return True


def _selected_operation():
    """The first operation among Fusion's current selections, or None."""
    try:
        sel = ui.activeSelections
        for i in range(sel.count):
            ent = sel.item(i).entity
            if ent is not None and ent.objectType == adsk.cam.Operation.classType():
                return ent
    except Exception:
        pass
    return None


def _same_entity(a, b):
    """True if a and b are the same Fusion object (equality, else matching entity tokens)."""
    if a is None or b is None:
        return False
    try:
        if a == b:
            return True
    except Exception:
        pass
    try:
        ta, tb = a.entityToken, b.entityToken
        return isinstance(ta, str) and bool(ta) and ta == tb
    except Exception:
        return False


def discover_tool_ops(camObj, ops_map):
    """Fill `ops_map` ("Setup > Op" -> operation) with every operation that has a tool.
    Returns the label to pre-select: the operation highlighted in Fusion (matched by identity, so
    operations inside folders or patterns and duplicate names work), else the first one, or None."""
    ops_map.clear()
    selected = _selected_operation()
    preselect, first = None, None
    for setup in camObj.setups:
        for op in setup.allOperations:
            if not (hasattr(op, 'tool') and op.tool):
                continue
            op_label = f"{setup.name} > {op.name}"
            if op_label in ops_map:          # same name twice in a setup: keep both selectable
                n = 2
                while f"{op_label} #{n}" in ops_map:
                    n += 1
                op_label = f"{op_label} #{n}"
            ops_map[op_label] = op
            first = first or op_label
            if preselect is None and selected is not None and _same_entity(op, selected):
                preselect = op_label
    if selected is not None and preselect is None:
        _log(f"Highlighted operation {getattr(selected, 'name', '?')!r} was not found among the "
             f"operations with a tool; defaulting to {first!r}")
    return preselect or first


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

            save_prefs(family=family, alloy=alloy, aggressiveness=aggressiveness, strategy=strategy)

            ro_input = inputs.itemById('runout')
            try:
                runout_in = twlogic.parse_runout_text(ro_input.value if ro_input else '', None)
            except ValueError as ve:
                ui.messageBox(str(ve), 'ToolWiz CAM Auto-Setter')
                return
            eng_input = inputs.itemById('useOpEngagement')
            stock_input = inputs.itemById('applyRecStock')
            tslot_opts = {}
            tdd = inputs.itemById('tslotOp')
            if tdd and getattr(tdd, 'isVisible', False) and tdd.selectedItem:
                code = dict(TSLOT_OPERATIONS).get(tdd.selectedItem.name)
                tslot_opts['tslotOperation'] = code or 'full_slot'
                for in_id, key in (('slotHeight', 'slotHeight'), ('radialDepthTotal', 'radialDepthTotal')):
                    bx = inputs.itemById(in_id)
                    txt = (bx.value or '').strip() if bx else ''
                    if txt:
                        try:
                            tslot_opts[key] = parse_length_expr_to_inches(txt, get_cam_document_units())
                        except Exception:
                            ui.messageBox(f"Cannot read {txt!r} as a length (e.g. 0.08 in or 2 mm).", 'ToolWiz CAM Auto-Setter')
                            return

            finish_opts = None
            fm_in = inputs.itemById('finishMode')
            if fm_in and getattr(fm_in, 'isVisible', False) and fm_in.selectedItem:
                try:
                    du = get_cam_document_units()
                    ra_box, tol_box = inputs.itemById('targetRa'), inputs.itemById('wallTolerance')
                    finish_opts = {
                        "mode": twlogic.finish_mode_code(fm_in.selectedItem.name),
                        "ra_uin": twlogic.parse_ra_text(ra_box.value if ra_box else '', du),
                        "wall_in": (parse_length_expr_to_inches(tol_box.value, du) if (tol_box and tol_box.value.strip())
                                    else twlogic.DEFAULT_WALL_TOL_IN),
                    }
                except (ValueError, ArithmeticError) as ve:
                    ui.messageBox(str(ve), 'ToolWiz CAM Auto-Setter')
                    return

            ac = AuditedCommand('autoset', target=op_name, targets=[op_name]).begin()
            result = 'error'
            try:
                done = run_autoset(target_op, op_name, family, alloy, strategy, aggressiveness,
                                   target_preset_to_replace, selected_grade, selected_coating_raw,
                                   runout_in=runout_in,
                                   use_op_engagement=bool(eng_input.value) if eng_input else True,
                                   apply_rec_stock=bool(stock_input.value) if stock_input else False,
                                   model=load_model_setting(), tslot_opts=tslot_opts,
                                   finish_opts=finish_opts)
                result = 'ok' if done else 'not applied'
            finally:
                ac.finish(result)

        except Exception as e:
            _report_error("Auto-Setter failed.", e)

TSLOT_OPERATIONS = [('Full slot', 'full_slot'), ('Side cut (one side)', 'side_cut'),
                    ('Both sides', 'both_sides'), ('Axial step (up/down cutting)', 'axial_step')]

STRATEGY_OPTIONS = [
    'Adaptive Roughing',
    'Roughing',
    'Finishing',
    '3D Contouring / Scallop Finishing',
    'Floor Finishing (Skim)',
    'Slotting',
    'Facing',
    'Drilling',
    'Peck Drilling (Deep Hole)',
    'Reaming',
    'Tapping (Form / Roll)',
    'Tapping (Spiral Flute - Blind Hole)',
    'Tapping (Spiral Point - Through Hole)',
    'Tapping',
]


def infer_strategy_for_op(op, geo_payload=None, saved_strategy=None):
    """Choose the default Strategy dropdown item for a CAM operation and its detected tool."""
    gp = geo_payload or {}
    kind = str(gp.get("kind", "")).lower()
    is_tap = bool(gp.get("isTap")) or kind == "tap"
    is_hole = bool(gp.get("isHoleTool"))
    desc_low = f"{gp.get('desc', '')} {gp.get('tool_type', '')}".lower()
    op_strat = str(getattr(op, 'strategy', '') or '').lower() if op is not None else ''
    op_name = str(getattr(op, 'name', '') or '').lower() if op is not None else ''
    cycle_expr = ""
    try:
        p_cyc = op.parameters.itemByName('cycleType') if (op and getattr(op, 'parameters', None)) else None
        if p_cyc and getattr(p_cyc, 'expression', None):
            cycle_expr = str(p_cyc.expression).lower()
    except Exception:
        pass

    if is_tap or 'tap' in op_strat or 'tap' in cycle_expr:
        if 'form' in desc_low or 'roll' in desc_low:
            return 'Tapping (Form / Roll)'
        if 'spiral point' in desc_low or 'gun' in desc_low:
            return 'Tapping (Spiral Point - Through Hole)'
        if 'spiral flute' in desc_low or 'spiral' in desc_low:
            return 'Tapping (Spiral Flute - Blind Hole)'
        return 'Tapping'
    if kind == 'reamer' or 'ream' in desc_low or 'ream' in op_strat or 'ream' in op_name or 'ream' in cycle_expr:
        return 'Reaming'
    if is_hole or 'drill' in op_strat:
        if any(k in cycle_expr for k in ('deep', 'chip-breaking', 'peck')) or 'peck' in op_name or 'deep' in op_name:
            return 'Peck Drilling (Deep Hole)'
        return 'Drilling'

    if 'adaptive' in op_strat:
        return 'Adaptive Roughing'
    if 'face' in op_strat or 'facing' in op_strat:
        return 'Facing'
    if 'slot' in op_strat:
        return 'Slotting'
    if 'flat' in op_strat or 'horizontal' in op_strat:
        return 'Floor Finishing (Skim)'
    if any(s in op_strat for s in ['scallop', 'parallel', 'morphed', 'ramp', 'flow']):
        return '3D Contouring / Scallop Finishing'
    if any(s in op_strat for s in ['contour', 'trace']):
        return 'Finishing'
    if 'pocket' in op_strat:
        return 'Roughing'
    if saved_strategy:
        return pick_saved(saved_strategy, STRATEGY_OPTIONS, 'Adaptive Roughing')
    return 'Adaptive Roughing'
def _sync_strategy_inputs(inputs, strategy, reset_engagement=True):
    """Show the finish-mode inputs only for finishing strategies and make roughing default to ToolWiz's own
    (maximum-removal) stepdown/stepover while finishing keeps the operation's engagement."""
    try:
        fin = twlogic.is_finishing_strategy(strategy)
        for tid in ('finishMode', 'targetRa', 'wallTolerance'):
            ti = inputs.itemById(tid)
            if ti:
                ti.isVisible = fin
        eng = inputs.itemById('useOpEngagement')
        if eng is not None and reset_engagement:
            eng.value = not twlogic.is_roughing_strategy(strategy)
    except Exception as ex:
        _log("Syncing strategy inputs failed", ex)


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
                    if strat_input:
                        inferred = infer_strategy_for_op(target_op, g_payload)
                        for itm in strat_input.listItems:
                            if itm.name == inferred:
                                itm.isSelected = True
                                break
                    _sync_strategy_inputs(inputs, _selected_name(strat_input) if strat_input else "", reset_engagement=True)
                    is_slot = bool(g_payload) and str(g_payload.get('kind', '')) == 'slot'
                    for tid in ('tslotOp', 'slotHeight', 'radialDepthTotal'):
                        ti = inputs.itemById(tid)
                        if ti:
                            ti.isVisible = is_slot
                    ro_box = inputs.itemById('runout')
                    if ro_box and g_payload and g_payload.get('runout_source') == 'tool':
                        du = get_cam_document_units()
                        ro_box.value = twlogic.fmt_len(g_payload.get('runout_in'), du, 5 if du != 'mm' else 4)
                            
            elif cmdInput.id == 'strategy':
                st = cmdInput.selectedItem.name if cmdInput.selectedItem else ""
                _sync_strategy_inputs(inputs, st)

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
                
            preselect_op_name = discover_tool_ops(camObj, available_ops_map)

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
            
            # Materials: one shared loader (server, then on-disk cache). Placed right under the
            # operation / detected tool so the first things to choose are the cut and the material.
            prefs = load_prefs()
            load_materials()
            _add_materials_notice(inputs, 'materialsNotice')

            init_family = None
            if materials_ready():
                families = _materials["families"]
                mat_input = inputs.addDropDownCommandInput('matFamily', 'Material Family', adsk.core.DropDownStyles.TextListDropDownStyle)
                default_family = "Steel - Tool (H13)" if "Steel - Tool (H13)" in families else families[0]
                init_family = pick_saved(prefs.get('family'), families, default_family)
                for m in families:
                    mat_input.listItems.add(m, m == init_family)

                alloy_input = inputs.addDropDownCommandInput('matAlloy', 'Specific Alloy', adsk.core.DropDownStyles.TextListDropDownStyle)
                init_alloys = alloys_for(init_family) or ["Standard Grade"]
                init_alloy = pick_saved(prefs.get('alloy'), init_alloys, init_alloys[0])
                for a in init_alloys:
                    alloy_input.listItems.add(a, a == init_alloy)

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
            
            strat_input = inputs.addDropDownCommandInput('strategy', 'Strategy', adsk.core.DropDownStyles.TextListDropDownStyle)
            default_strat = infer_strategy_for_op(initial_op, initial_geo, saved_strategy=prefs.get('strategy'))
            for s_name in STRATEGY_OPTIONS:
                strat_input.listItems.add(s_name, default_strat == s_name)
            
            agg_input = inputs.addIntegerSliderCommandInput('aggressiveness', 'Aggressiveness', 0, 100)
            agg_input.valueOne = prefs.get('aggressiveness', 50)
            agg_input.tooltip = ('50% = the middle of the vendor chart range (the tool brand\'s own chart, else Helical HEM / '
                                 'Harvey + Helical); 0% = bottom of the range; 100% = top of the range. Physics limits still cap '
                                 'every value.')

            # Runout (TIR): the tool's own toolwiz.runout_* value, else blank = automatic (server: holder class, else by diameter).
            doc_u = get_cam_document_units()
            ro_tool = (initial_geo or {}).get('runout_source') == 'tool'
            ro_text = twlogic.fmt_len((initial_geo or {}).get('runout_in'), doc_u, 5 if doc_u != 'mm' else 4) if ro_tool else ''
            runout_input = inputs.addStringValueInput('runout', 'Runout / TIR (from the tool)' if ro_tool else 'Runout / TIR (blank = automatic)', ro_text)
            runout_input.tooltip = ('Total indicator runout at the tool tip. Leave blank for automatic: by holder type, else 0.0001 in '
                                    'for tools up to 1/8 in and 0.0002 in above. Or enter your measured value, e.g. 0.0002 in or 0.005 mm.')
            init_strategy = infer_strategy_for_op(initial_op, initial_geo, saved_strategy=prefs.get('strategy'))
            rough0 = twlogic.is_roughing_strategy(init_strategy)
            eng_input = inputs.addBoolValueInput('useOpEngagement', "Keep the operation's own stepdown / stepover", True, '', not rough0)
            eng_input.tooltip = ("Ticked: compute rpm and feed for the engagement already set on the operation and keep it. "
                                 "Unticked: write ToolWiz's own stepdown / stepover (for roughing, the maximum removal "
                                 "rate that works reliably at this aggressiveness).")
            fin0 = _finish_prefs.get(_op_path(initial_op), {})
            fm = inputs.addDropDownCommandInput('finishMode', 'Finish mode', adsk.core.DropDownStyles.TextListDropDownStyle)
            for label, code in twlogic.FINISH_MODES:
                fm.listItems.add(label, code == fin0.get('mode', 'cleanup'))
            fm.tooltip = ('Clean-up: decent finish, maximize removal. Surface finish: limit feed marks and scallops to the '
                          'target Ra. Accuracy: limit deflection and springback to the wall tolerance.')
            ra_in = inputs.addStringValueInput('targetRa', 'Target surface finish (Ra)',
                                               twlogic.ra_uin_to_text(fin0.get('ra_uin', twlogic.DEFAULT_RA_UIN), doc_u))
            tol_in = inputs.addStringValueInput('wallTolerance', 'Wall tolerance',
                                                twlogic.fmt_len(fin0.get('wall_in', twlogic.DEFAULT_WALL_TOL_IN), doc_u, 5 if doc_u != 'mm' else 4))
            fin_vis = twlogic.is_finishing_strategy(init_strategy)
            for fi in (fm, ra_in, tol_in):
                fi.isVisible = fin_vis
            stock_input = inputs.addBoolValueInput('applyRecStock', "Also apply ToolWiz's recommended stock to leave", True, '', False)
            stock_input.tooltip = "Writes the recommended radial / axial stock to leave (true-to-size parts) to this operation."

            # T-slot / keyseat cutters: what the cut is (only shown for slot mills).
            is_slot = str((initial_geo or {}).get('kind', '')) == 'slot'
            tslot_dd = inputs.addDropDownCommandInput('tslotOp', 'T-slot cut', adsk.core.DropDownStyles.TextListDropDownStyle)
            for label, code in TSLOT_OPERATIONS:
                tslot_dd.listItems.add(label, code == 'full_slot')
            tslot_h = inputs.addStringValueInput('slotHeight', 'Slot height (Z)', '')
            tslot_h.tooltip = 'Finished slot height along Z; blank = the cutter width. Used for the Z-step plan.'
            tslot_r = inputs.addStringValueInput('radialDepthTotal', 'Total radial depth', '')
            tslot_r.tooltip = 'Total radial depth of the slot; blank = one pass at ToolWiz depth.'
            for ti in (tslot_dd, tslot_h, tslot_r):
                ti.isVisible = is_slot

            model_txt = model_label(load_model_setting())
            mbox = inputs.addTextBoxCommandInput('modelInfo', 'Cutting model',
                                                 f'{model_txt} - same setting as the ToolWiz web page.', 2, True)
            mbox.isFullWidth = True

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


# Preset parameter id -> operation parameter id(s) where Fusion uses a different name.
PRESET_TO_OP_PARAMS = {
    'tool_rampSpindleSpeed': ('tool_rampSpindleSpeed', 'tool_spindleSpeedRamp'),
    'tool_stepdown': ('tool_stepdown', 'maximumStepdown', 'stepdown'),
    'tool_stepover': ('tool_stepover', 'optimalLoad', 'stepover', 'maximumStepover', 'finishingStepover'),
    'tool_rampAngle': ('tool_rampAngle', 'rampAngle', 'rampTaperAngle', 'helicalRampAngle'),
}


def _regenerate_toolpath(op):
    """Regenerate the target operation's toolpath so Fusion's machining time reflects the new
    values (a stale toolpath kept showing the old time: 2:08 vs 2:25 after regenerating)."""
    try:
        cam = adsk.cam.CAM.cast(app.activeDocument.products.itemByProductType('CAMProductType'))
        if cam is not None and hasattr(cam, 'generateToolpath'):
            cam.generateToolpath(op)
            _log(f"Regenerating toolpath for {getattr(op, 'name', '?')!r}")
    except Exception as ex:
        _log("Toolpath regeneration request failed (regenerate manually)", ex)


def _log_preset_use_flags(op, preset_name):
    """Diagnostic: the preset's 'Use stepdown/stepover' checkboxes are not exposed as preset
    parameters, so read them from the tool's JSON. Unchecked flags make the operation ignore the
    preset's stepdown/stepover when the preset is selected."""
    try:
        t = getattr(op, 'tool', None)
        d = json.loads(t.toJson()) if t is not None else {}
        for pr in ((d.get('start-values') or {}).get('presets') or []):
            if pr.get('name') == preset_name:
                _log(f"Preset {preset_name!r} JSON: use-stepdown={pr.get('use-stepdown')!r} "
                     f"stepdown={pr.get('stepdown')!r} use-stepover={pr.get('use-stepover')!r} "
                     f"stepover={pr.get('stepover')!r}")
                return pr
        _log(f"Preset {preset_name!r} not found in the tool JSON")
    except Exception as e:
        _log("preset use-flag diagnostic failed", e)
    return None


def _log_op_motion_params(op, label):
    """Diagnostic: every operation parameter related to feeds, speeds, steps or ramps, so a
    change Fusion makes while applying a preset (e.g. clamping a stepover) is visible."""
    try:
        keys = ('feed', 'speed', 'step', 'ramp', 'plunge', 'load', 'coolant')
        rows = []
        for p_obj in _iter_params(getattr(op, 'parameters', None)):
            n = str(getattr(p_obj, 'name', ''))
            if any(k in n.lower() for k in keys):
                v = getattr(getattr(p_obj, 'value', None), 'value', None)
                rows.append(f"{n}={getattr(p_obj, 'expression', None)!r}({v!r})")
        _log(f"Operation motion parameters {label}: " + "; ".join(rows))
    except Exception as e:
        _log("operation parameter dump failed", e)


def _log_custom_diff(op, label="after auto-set"):
    """Diagnostic: list every preset field whose value differs from the operation's own
    parameter of the same name. Fusion marks the operation '(custom)' when any differ."""
    try:
        preset = getattr(op, 'toolPreset', None)
        params = getattr(preset, 'parameters', None) if preset else None
        if params is None:
            return
        diffs, unmatched = [], []
        for p_obj in _iter_params(params):
            name = getattr(p_obj, 'name', '')
            o_obj = None
            for op_name in PRESET_TO_OP_PARAMS.get(name, (name,)):
                o_obj = _param(getattr(op, 'parameters', None), op_name)
                if o_obj is not None and getattr(o_obj, 'isEnabled', True):
                    break
                o_obj = None
            if o_obj is None:
                unmatched.append(name)
                continue
            pv = getattr(getattr(p_obj, 'value', None), 'value', None)
            ov = getattr(getattr(o_obj, 'value', None), 'value', None)
            same = (pv == ov) if not (isinstance(pv, float) and isinstance(ov, float)) else abs(pv - ov) <= max(abs(pv) * 1e-6, 1e-9)
            pe, oe = getattr(p_obj, 'expression', None), getattr(o_obj, 'expression', None)
            if same and (_is_formula(pe) or _is_formula(oe)) and pe != oe:
                same = False   # same value but a number in one and a formula in the other
            if not same:
                diffs.append(f"{name}: preset {getattr(p_obj, 'expression', None)!r} vs op {getattr(o_obj, 'expression', None)!r}")
        _log(f"Preset vs operation differences {label} (cause of '(custom)'): " + ("; ".join(diffs) if diffs else "none")
             + (f"  [preset fields with no matching operation parameter: {', '.join(unmatched)}]" if unmatched else ""))
    except Exception as e:
        _log("custom diff diagnostic failed", e)


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


def get_op_cut_params(op, doc_unit="in", strategy=None):
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
        s_low = str(strategy or getattr(op, 'strategy', '') or "").strip().lower()
        is_hole_op_param = any(k in s_low for k in ("drill", "ream", "tap", "bore"))
        feed_param_names = ('tool_feedPlunge', 'tool_feedCutting') if is_hole_op_param else ('tool_feedCutting', 'tool_feedPlunge')
        for params in _speed_param_sources(op):
            p_rpm = _param(params, 'tool_spindleSpeed')
            if rpm <= 0 and not _is_fusion_default_formula(p_rpm):
                rpm = parse_cam_rpm(p_rpm)
            for fp_name in feed_param_names:
                p_feed = _param(params, fp_name)
                if feed <= 0 and p_feed is not None and not _is_fusion_default_formula(p_feed):
                    feed = parse_cam_feed_to_ipm(p_feed, doc_unit)
                    if feed > 0:
                        break
        if rpm <= 0:  # nothing but the default formula anywhere: use its evaluated value
            rpm = parse_cam_rpm(_param(getattr(op, 'parameters', None), 'tool_spindleSpeed'))
        if feed <= 0:
            for fp_name in feed_param_names:
                feed = parse_cam_feed_to_ipm(_param(getattr(op, 'parameters', None), fp_name), doc_unit)
                if feed > 0:
                    break

        # 3. Axial depth of cut (DOC) - only if parameter is enabled
        for doc_name in ['maximumStepdown', 'stepdown']:
            p = op.parameters.itemByName(doc_name)
            if p and getattr(p, 'isEnabled', True):
                doc = parse_cam_param_to_inches(p, 0.0, doc_unit)
                if doc > 0:
                    break

        # 4. Radial width of cut (WOC); prefer finishingStepover only on finishing strategies
        # (2D Contour always keeps finishingStepover=0.03mm enabled even when Roughing Passes are used).
        s_low = str(strategy or "").strip().lower()
        prefer_rough_woc = bool(s_low and not ("finish" in s_low and "semi" not in s_low))
        if not prefer_rough_woc and not s_low:
            p_mp = _param(getattr(op, 'parameters', None), 'doMultiplePasses')
            if p_mp is not None and _norm_expr(_safe(lambda: p_mp.expression)) == 'true':
                prefer_rough_woc = True

        woc_order = (
            ['stepover', 'optimalLoad', 'maximumStepover', 'finishingStepover']
            if prefer_rough_woc
            else ['finishingStepover', 'stepover', 'optimalLoad', 'maximumStepover']
        )
        for woc_name in woc_order:
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
        ft = fusion_tool_payload(geo)
        if ft:
            ops_payload[-1]["fusion_tool"] = ft
        if geo.get("runout_source") == "tool" and geo.get("runout_in") is not None:
            ops_payload[-1]["runout"] = geo["runout_in"]    # else the server defaults it by holder class / diameter
        ops_payload[-1]["isCarbide"] = bool(geo.get("is_carbide", True))
        if geo.get("guid"):
            ops_payload[-1]["tool_guid"] = geo["guid"]
        fg = op_info.get("feature_geometry") or _inspect_op_feature_geometry(op_info.get("op"), geo, woc_in=op_info.get("woc"))
        if fg:
            ops_payload[-1]["feature_geometry"] = fg
    return ops_payload


def query_toolwiz_stock_compensation(family, alloy, aggressiveness, mode, custom_rad="0.0000 in", custom_ax="0.0000 in", doc_unit="in",
                                     radial_pct=100, axial_pct=100, comp_adjust_pct=None):
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
            "radial_pct": radial_pct,
            "axial_pct": axial_pct,
            "operations": build_stock_ops_payload(stock_ops_cache, doc_unit)
        }
        if comp_adjust_pct is not None:
            payload["comp_adjust_pct"] = comp_adjust_pct
        if _model_cache.get("model"):
            payload["model"] = _model_cache["model"]
        res_data = _http_json('/api/stock_compensation', payload, timeout=8.0)
        if res_data.get("success"):
            results = res_data.get("results", [])
            _log_stock_results(results, radial_pct, axial_pct)
            return results
        _stock_last_error = str(res_data.get("error") or "server reported failure")
        _log(f"stock_compensation failed: {_stock_last_error}")
    except Exception as e:
        _stock_last_error = str(e)
        _log("stock_compensation request failed", e)
    return []

_rough_stock_cache = {}


def query_roughing_stock(family, alloy, aggressiveness, doc_unit="in", model=None):
    """ToolWiz's recommended radial/axial stock to leave for every ROUGHING operation in stock_ops_cache.
    One /api/calculate_for_fusion call per operation (its own tool, runout, stepdown/stepover, the same
    cutting model as the web page); results are cached per input set. Returns
    {op_id: {"radial_in", "axial_in", "calc"}}; operations that failed are left out (reason logged)."""
    out = {}
    model = model or _model_cache.get("model")
    for op_id, info in stock_ops_cache.items():
        geo = info.get("geo")
        if info.get("is_finishing") or not geo or _is_hole_or_tap_mode(geo, info.get("strategy")):
            continue
        key = (op_id, family, alloy, aggressiveness, model, geo.get("runout_in"), info.get("doc"), info.get("woc"))
        if key not in _rough_stock_cache:
            try:
                strat = infer_strategy_for_op(info.get("op"), geo)
                payload = build_calc_payload(
                    geo, family, alloy, strat, aggressiveness,
                    "Carbide (Standard)" if geo.get("is_carbide", True) else "High Speed Steel (HSS)",
                    geo.get("coating", "Uncoated"), runout_in=geo.get("runout_in"), model=model,
                    engagement=twlogic.engagement_fields(info.get("doc"), info.get("woc"), True))
                payload["isMetric"] = twlogic.is_metric(doc_unit)
                res = _http_json('/api/calculate_for_fusion', payload, timeout=20.0)
                if not isinstance(res, dict) or not res.get("success"):
                    raise ValueError((res or {}).get("error") or "server reported failure")
                rad, ax = twlogic.stock_recommendation(res)
                _rough_stock_cache[key] = {"radial_in": rad, "axial_in": ax, "calc": res}
            except Exception as e:
                _log(f"Recommended stock for roughing op {info.get('label')!r} failed", e)
                continue
        out[op_id] = _rough_stock_cache[key]
    return out


def refresh_stock_consistency(doc_unit="in"):
    """Finishing-op wall tolerance check across each setup, using the numbers now in the dialog: warns in the
    finishing row's advisory when the roughing op before it leaves too little (or less than the finishing
    engagement)."""
    for s_data in stock_setups_cache.values():
        seq = []
        for op_id in s_data.get("ops", []):
            info = stock_ops_cache.get(op_id) or {}
            inp = info.get("inp_rad")
            val = _safe(lambda: parse_length_expr_to_inches(inp.value, info.get("unit", doc_unit))) if inp else None
            seq.append({"label": op_id, "is_finishing": bool(info.get("is_finishing")), "rad_in": val,
                        "woc_in": info.get("woc")})
        notes = twlogic.stock_consistency_notes(seq)
        for op_id in s_data.get("ops", []):
            info = stock_ops_cache.get(op_id) or {}
            box = info.get("lbl_adv")
            if not box or not info.get("is_finishing"):
                continue
            base = str(info.get("adv_base") or "")
            extra = "\n".join("Check: " + n for n in notes.get(op_id, []))
            try:
                box.formattedText = format_cell_html((base + ("\n" + extra if extra else "")).replace("\n", "<br>"),
                                                    info.get("bg_color", "#ffffff"))
            except Exception:
                pass


def _log_stock_results(results, radial_pct, axial_pct):
    """One line per finishing op: the inputs the calculation used and what it recommends."""
    for r in results or []:
        if not r.get("is_finishing"):
            continue
        _log(f"Stock calc {r.get('name')!r} ({r.get('strategy')}): DOC {r.get('doc_in')} in, "
             f"WOC {r.get('woc_in')} in, deflection {r.get('deflection_in')} in, springback "
             f"{r.get('springback_in')} in, strength rad {radial_pct}% / ax {axial_pct}% -> "
             f"rad {r.get('recommended_radial_stock')}, ax {r.get('recommended_axial_stock')}")


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
        _set_expression(op, p, name, "true" if flag else "false")
        return True
    except Exception as e1:
        try:
            old_e, old_v = _param_state(p)
            p.value.value = bool(flag)
            new_e, new_v = _param_state(p)
            _audit_param(op, name, old_e, new_e, old_v, new_v)
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
                    _set_expression(op, p, name, str(val))
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

            eventArgs = adsk.core.CommandEventArgs.cast(args)
            inputs = eventArgs.command.commandInputs
            fam_name = _selected_name(inputs.itemById('stockMatFamily'))
            alloy_name = _selected_name(inputs.itemById('stockMatAlloy'))
            agg_in = inputs.itemById('stockAggressiveness')
            try:
                agg_val = int(agg_in.valueOne) if agg_in is not None else None
            except (TypeError, ValueError, AttributeError):
                agg_val = None
            save_prefs(family=fam_name, alloy=alloy_name, aggressiveness=agg_val,
                       stock_radial_pct=stock_strength_pct(inputs.itemById('stockRadialPct'), None),
                       stock_axial_pct=stock_strength_pct(inputs.itemById('stockAxialPct'), None))

            applied_ops = []
            failed_ops = []
            selected = [i.get('label') for i in stock_ops_cache.values()
                        if i.get("chk") and i["chk"].value and getattr(i["chk"], 'isVisible', True)]
            ac = AuditedCommand('stock_to_leave', target=", ".join(str(x) for x in selected),
                                targets=selected).begin()
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
                        failed = ['unexpected error']
                    if failed:
                        failed_ops.append((op_info['label'], failed))
                    else:
                        applied_ops.append((op_info['label'], rad_val, ax_val))

            note = ac.finish(f"applied {len(applied_ops)}, failed {len(failed_ops)}")
            if applied_ops or failed_ops:
                material = f"{fam_name} / {alloy_name}" if (fam_name and alloy_name) else fam_name
                msg = format_stock_summary(material, applied_ops, failed_ops, _log_path())
                if note:
                    msg += "\n\n" + note
                ui.messageBox(msg, 'ToolWiz Stock to Leave Manager')
            else:
                ui.messageBox('No operations were selected to update.', 'ToolWiz Stock to Leave Manager')

        except Exception as e:
            _finish_active_command(f"error: {e}")
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
            comp_input = inputs.itemById('stockCompAdjust')
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
                cal_box = inputs.itemById('stockCalibration')
                if cal_box:
                    try:
                        cal_box.text = calibration_text_for(family) or ' '
                    except Exception as e_cal:
                        _log("Updating the calibration line failed", e_cal)

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
                
            # 4. Handle Material / Compensation Trim / Mode changes
            if cmdInput.id in ['stockMatFamily', 'stockMatAlloy', 'stockCompAdjust', 'stockAggressiveness', 'stockBatchMode', 'customRadOffset', 'customAxOffset',
                               'stockRadialPct', 'stockAxialPct', 'stockIncludeRoughing']:
                if not (mat_family_input and mat_family_input.selectedItem) or not materials_ready():
                    return
                family = mat_family_input.selectedItem.name
                alloy = alloy_input.selectedItem.name if (alloy_input and alloy_input.selectedItem) else ""
                comp_adjust = None
                if comp_input:
                    slider_input = adsk.core.IntegerSliderCommandInput.cast(comp_input)
                    if slider_input:
                        comp_adjust = slider_input.valueOne
                    elif hasattr(comp_input, 'valueOne'):
                        comp_adjust = comp_input.valueOne
                    elif hasattr(comp_input, 'value'):
                        comp_adjust = comp_input.value
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
                
                calc_results = query_toolwiz_stock_compensation(
                    family, alloy, agg, mode_code, c_rad, c_ax, doc_unit=doc_u,
                    radial_pct=stock_strength_pct(inputs.itemById('stockRadialPct')),
                    axial_pct=stock_strength_pct(inputs.itemById('stockAxialPct')),
                    comp_adjust_pct=comp_adjust)
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
                            if adv_text:
                                op_info["adv_base"] = str(adv_text)
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

                    # Roughing ops: ToolWiz's recommended stock to leave (positive), when asked for.
                    inc_rough = inputs.itemById('stockIncludeRoughing')
                    rough_on = bool(inc_rough.value) if inc_rough else False
                    _is_updating_ui = True
                    try:
                        rough = query_roughing_stock(family, alloy, agg, doc_u) if rough_on else {}
                        for op_id, op_info in stock_ops_cache.items():
                            if op_info.get("is_finishing"):
                                continue
                            chk = op_info.get("chk")
                            r = rough.get(op_id)
                            if r:
                                if op_info.get("inp_rad") and r.get("radial_in") is not None:
                                    op_info["inp_rad"].value = twlogic.fmt_len(r["radial_in"], doc_u)
                                if op_info.get("inp_ax") and r.get("axial_in") is not None:
                                    op_info["inp_ax"].value = twlogic.fmt_len(r["axial_in"], doc_u)
                                text = (f"Roughing: ToolWiz recommends leaving radial {twlogic.fmt_len(r.get('radial_in'), doc_u)}, "
                                        f"axial {twlogic.fmt_len(r.get('axial_in'), doc_u)} "
                                        "(1.5 x predicted deflection + springback) so the finishing pass makes the part true to size.")
                                op_info["adv_base"] = text
                                try:
                                    op_info["lbl_adv"].formattedText = format_cell_html(text, op_info.get("bg_color", "#ffffff"))
                                except Exception:
                                    pass
                                if chk and getattr(chk, 'isVisible', True):
                                    chk.value = True
                            elif chk and cmdInput.id == 'stockIncludeRoughing' and not rough_on:
                                chk.value = False
                        if rough_on and not rough:
                            ui.messageBox("ToolWiz could not calculate recommended stock for the roughing operations. "
                                          f"Details: {_log_path()}", "ToolWiz Stock to Leave Manager")
                        refresh_stock_consistency(doc_u)
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

            # Material Dropdowns (pre-selected from the last saved choice when still valid)
            prefs = load_prefs()
            _calibration_cache.clear()
            mat_family_input = inputs.addDropDownCommandInput('stockMatFamily', 'Workpiece Material', adsk.core.DropDownStyles.TextListDropDownStyle)
            default_family = "Titanium Alloy" if "Titanium Alloy" in families else families[0]
            default_family = pick_saved(prefs.get('family'), families, default_family)
            for m in families:
                mat_family_input.listItems.add(m, m == default_family)

            alloy_input = inputs.addDropDownCommandInput('stockMatAlloy', 'Specific Alloy', adsk.core.DropDownStyles.TextListDropDownStyle)
            init_alloys = alloys_for(default_family) or ["Standard Grade"]
            init_alloy = pick_saved(prefs.get('alloy'), init_alloys, init_alloys[0])
            for a in init_alloys:
                alloy_input.listItems.add(a, a == init_alloy)

            # Calibration status for the selected family (blank when the server can't say)
            cal_box = inputs.addTextBoxCommandInput('stockCalibration', '', calibration_text_for(default_family) or ' ', 1, True)
            cal_box.isFullWidth = True

            comp_input = inputs.addIntegerSliderCommandInput('stockCompAdjust', 'Compensation Trim (% vs Recommended)', -25, 25)
            comp_input.valueOne = 0
            comp_input.tooltip = (
                '0% = Recommended compensation driven by populated speeds & feeds. '
                'Adjust down to -25% for less compensation or up to +25% for more.'
            )

            init_rad_pct = prefs.get('stock_radial_pct', STOCK_STRENGTH_DEFAULT)
            init_ax_pct = prefs.get('stock_axial_pct', STOCK_STRENGTH_DEFAULT)
            _add_strength_dropdown(inputs, 'stockRadialPct', 'Radial Stock Strength', init_rad_pct,
                                   'Use this share of the predicted negative radial (wall) stock. '
                                   'In a hole, radial stock changes the diameter by twice this amount.')
            _add_strength_dropdown(inputs, 'stockAxialPct', 'Axial Stock Strength', init_ax_pct,
                                   'Use this share of the predicted negative axial (floor) stock.')

            mode_input = inputs.addDropDownCommandInput('stockBatchMode', 'Compensation Preset', adsk.core.DropDownStyles.TextListDropDownStyle)
            mode_input.listItems.add('Auto-Compensate Finishing (Negative Stock)', True)
            mode_input.listItems.add('Zero-Out Finishing (0.0000")', False)
            mode_input.listItems.add('Batch Apply Custom Offset', False)
            rough_chk = inputs.addBoolValueInput('stockIncludeRoughing', "Include roughing ops: set ToolWiz's recommended stock to leave", True, '', False)
            rough_chk.tooltip = ("Calculates, per roughing operation, the radial and axial stock to leave that lets the "
                                 "finishing pass bring the part true to size (1.5 x predicted deflection + springback, "
                                 "at least 0.05 mm). One server calculation per roughing op, so it takes a few seconds.")
            
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
            
            # Initial calculation from Tool Wizard (0% = Recommended baseline from populated speeds & feeds)
            init_results = query_toolwiz_stock_compensation(
                default_family, init_alloy, 50, "auto_compensate", doc_unit=doc_unit,
                radial_pct=init_rad_pct, axial_pct=init_ax_pct, comp_adjust_pct=0
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
                op_info["adv_base"] = str(init_adv)
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
# COMMAND 5: LOG CUT RESULT (feeds the server's cut log / calibration)
# ==============================================================================

class LogCutError(Exception):
    """A problem the user should be told about. The message is user-facing."""


def parse_measured_error_in(text, doc_unit="in"):
    """"0.0008 in" / "0.02 mm" / "-.0005" -> inches (positive = oversize, negative = undersize).
    A unit-less number uses the document unit. Blank -> None (nothing was measured)."""
    s = (text or "").strip()
    if not s:
        return None
    hint = f"Can't read the measured wall error {s!r}. Enter a number with units, e.g. 0.0008 in or 0.02 mm."
    try:
        val = parse_length_expr_to_inches(s, doc_unit)
    except (ValueError, ArithmeticError):
        raise ValueError(hint) from None
    if not math.isfinite(val) or abs(val) > 1.0:
        raise ValueError(f"Measured wall error {s!r} is out of range (must be within +/-1 inch).")
    return val


def build_single_op_compensation_payload(family, alloy, aggressiveness, op_name, strategy, geo, cut):
    """/api/stock_compensation body for ONE operation. `cut` is (rpm, feed_ipm, doc_in, woc_in);
    everything is inches / IPM and labelled so."""
    rpm, feed, doc, woc = cut
    cache = {"op_1": {"name": op_name, "strategy": str(strategy or ""), "unit": "in", "geo": geo,
                      "rpm": rpm, "feed": feed, "doc": doc, "woc": woc}}
    return {
        "family": family, "alloy": alloy, "aggressiveness": aggressiveness,
        "mode": "auto_compensate", "unit": "in",
        "custom_radial_offset": "0.0000 in", "custom_axial_offset": "0.0000 in",
        **({"model": _model_cache["model"]} if _model_cache.get("model") else {}),
        "operations": build_stock_ops_payload(cache, "in"),
    }


def build_cutlog_payload(family, alloy, op_name, geo, cut, prediction, measured_error_in,
                         spindle_load_pct, chatter, surface_ok, notes):
    """/api/cutlog body (source "fusion"). Pure function; raises ValueError naming anything that
    is missing or unusable so the caller can tell the user instead of posting garbage.
    `prediction` is one /api/stock_compensation result (deflection_in, springback_in, total_error_in)."""
    rpm, feed, doc, woc = cut
    missing = [n for n, v in (("spindle speed", rpm), ("cutting feed", feed),
                              ("depth of cut (DOC)", doc), ("width of cut (WOC)", woc)) if not (v and v > 0)]
    if missing:
        raise ValueError("Could not read " + ", ".join(missing) + " from the operation. "
                         "Set them in the operation's parameters and try again.")
    if not geo:
        raise ValueError("Tool geometry is not available for this operation.")
    try:
        pred = {k: float(prediction[k]) for k in ("deflection_in", "springback_in", "total_error_in")}
    except (TypeError, KeyError, ValueError):
        raise ValueError("The server's prediction did not include deflection / springback / total error.") from None

    t_num = geo.get("number")
    load = None
    if spindle_load_pct is not None and float(spindle_load_pct) > 0:  # 0 means "not recorded"
        load = float(spindle_load_pct)
    payload = {
        "family": family,
        "alloy": alloy or None,
        "operation": str(op_name or "Operation")[:100],
        "tool_description": (str(geo["desc"])[:300] if geo.get("desc") else None),
        "tool_number": t_num if isinstance(t_num, int) and not isinstance(t_num, bool) and t_num >= 0 else None,
        "diameter_in": geo["diameter"],
        "flutes": geo["flutes"],
        "stickout_in": geo["stickout"],
        "rpm": rpm,
        "feed_ipm": feed,
        "doc_in": doc,
        "woc_in": woc,
        "predicted_deflection_in": pred["deflection_in"],
        "predicted_springback_in": pred["springback_in"],
        "predicted_total_error_in": pred["total_error_in"],
        "measured_wall_error_in": measured_error_in,
        "spindle_load_pct": load,
        "chatter": bool(chatter),
        "surface_ok": bool(surface_ok),
        "notes": (((notes or "").strip() + (f"\n[tool guid {geo['guid']}]" if geo.get("guid") else "")).strip()[:2000] or None),
        "source": "fusion",
    }
    return payload


def _post_or_raise(path, payload, what, timeout=8.0):
    """POST to the server; turn connection failures and {"success": false} into LogCutError."""
    try:
        res = _http_json(path, payload, timeout=timeout)
    except (urllib.error.URLError, OSError, ValueError) as e:
        _log(f"Log Cut Result: could not {what}", e)
        raise LogCutError(f"Could not reach the ToolWiz server to {what}.\n"
                          f"Start Tool Wizard (py app.py) and try again.\n\nDetails: {_log_path()}") from None
    if not isinstance(res, dict) or not res.get("success"):
        err = res.get("error") if isinstance(res, dict) else res
        _log(f"Log Cut Result: server refused to {what}: {err}")
        raise LogCutError(f"The server could not {what}:\n{err}\n\nDetails: {_log_path()}")
    return res


def format_cutlog_confirmation(t_label, op_name, measured_error_in, predicted_total_in, family, cal_text):
    """One confirmation line plus the family's calibration status."""
    meas = f'measured {measured_error_in:+.4f}"' if measured_error_in is not None else "no measurement"
    lines = [f"Logged: {t_label} · {op_name} — {meas}, predicted {predicted_total_in:.4f}\""]
    if cal_text:
        lines.append(f"{family}: {cal_text}")
    return "\n".join(lines)


def log_cut_result(op, op_label, family, alloy, measured_text, load_pct, chatter, surface_ok, notes,
                   aggressiveness=50):
    """Predict the cut on the server, log it with the machinist's outcome, and return the
    confirmation text. Raises LogCutError (user-facing message) on any problem."""
    op_name = op_label.split(" > ", 1)[-1]
    doc_unit = get_cam_document_units()
    try:
        measured = parse_measured_error_in(measured_text, doc_unit)
    except ValueError as e:
        raise LogCutError(str(e)) from None

    geo, summary, _ = get_op_tool_info(op)
    if not geo:
        _log(f"Log Cut Result: tool geometry unreadable for {op_label}: {summary}")
        raise LogCutError(f"Could not read the tool geometry for {op_label}:\n{summary}\n\nDetails: {_log_path()}")
    cut = get_op_cut_params(op, doc_unit)

    comp_payload = build_single_op_compensation_payload(
        family, alloy, aggressiveness, op_name, getattr(op, 'strategy', ''), geo, cut)
    comp = _post_or_raise('/api/stock_compensation', comp_payload, "predict the wall error")
    results = comp.get("results") or []
    if not results:
        _log(f"Log Cut Result: no prediction returned for {op_label}")
        raise LogCutError(f"The server returned no prediction for {op_label}.\n\nDetails: {_log_path()}")
    prediction = results[0]

    try:
        payload = build_cutlog_payload(family, alloy, op_name, geo, cut, prediction, measured,
                                       load_pct, chatter, surface_ok, notes)
    except ValueError as e:
        _log(f"Log Cut Result: {e}")
        raise LogCutError(f"{e}\n\nDetails: {_log_path()}") from None
    _post_or_raise('/api/cutlog', payload, "save the cut")

    _calibration_cache.pop(family, None)
    cal_text = calibration_text_for(family, use_cache=False)
    return format_cutlog_confirmation(tool_label(geo.get("number")), op_name, measured,
                                      payload["predicted_total_error_in"], family, cal_text)


class ToolWizLogCutExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            inputs = adsk.core.CommandEventArgs.cast(args).command.commandInputs
            op_label = _selected_name(inputs.itemById('logTargetOp'))
            op = logcut_ops_map.get(op_label)
            if not op:
                ui.messageBox('No valid CAM operation selected.', 'ToolWiz Log Cut Result')
                return
            family = _selected_name(inputs.itemById('logMatFamily'))
            alloy = _selected_name(inputs.itemById('logMatAlloy'))
            if not family:
                ui.messageBox('Please select a material family.', 'ToolWiz Log Cut Result')
                return
            measured_in = inputs.itemById('logMeasured')
            load_in = inputs.itemById('logLoad')
            chatter_in = inputs.itemById('logChatter')
            surface_in = inputs.itemById('logSurfaceOk')
            notes_in = inputs.itemById('logNotes')

            prefs = load_prefs()
            try:
                msg = log_cut_result(
                    op, op_label, family, alloy,
                    measured_in.value if measured_in else "",
                    load_in.valueOne if load_in else 0,
                    bool(chatter_in.value) if chatter_in else False,
                    bool(surface_in.value) if surface_in else True,
                    notes_in.value if notes_in else "",
                    aggressiveness=prefs.get('aggressiveness', 50))
            except LogCutError as e:
                ui.messageBox(str(e), 'ToolWiz Log Cut Result')
                return
            save_prefs(family=family, alloy=alloy)
            ui.messageBox(msg, 'ToolWiz Log Cut Result')
        except Exception as e:
            _report_error("Log Cut Result failed.", e)


class ToolWizLogCutInputChangedHandler(adsk.core.InputChangedEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            eventArgs = adsk.core.InputChangedEventArgs.cast(args)
            if eventArgs.input.id == 'logMatFamily':
                alloy_input = eventArgs.inputs.itemById('logMatAlloy')
                if alloy_input:
                    alloy_input.listItems.clear()
                    alloys = alloys_for(_selected_name(eventArgs.input)) or ["Standard Grade"]
                    for i, a in enumerate(alloys):
                        alloy_input.listItems.add(a, i == 0)
        except Exception as e:
            _log("Log Cut Result input-changed handler failed", e)


class ToolWizLogCutCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            cmd = args.command
            cmd.isExecutedWhenPreEmpted = False
            cmd.isRepeatable = False
            cmd.isAutoExecute = False
            try:
                cmd.okButtonText = 'Log Cut'
            except Exception:
                pass
            onExecute = ToolWizLogCutExecuteHandler()
            cmd.execute.add(onExecute)
            handlers.append(onExecute)
            onInputChanged = ToolWizLogCutInputChangedHandler()
            cmd.inputChanged.add(onInputChanged)
            handlers.append(onInputChanged)

            inputs = cmd.commandInputs
            camObj = adsk.cam.CAM.cast(app.activeDocument.products.itemByProductType('CAMProductType'))
            if not camObj:
                ui.messageBox('Please switch to the Manufacture (CAM) workspace with an active setup.')
                return
            preselect = discover_tool_ops(camObj, logcut_ops_map)
            if not logcut_ops_map:
                ui.messageBox('No operations with tools found in active document.')
                return

            op_input = inputs.addDropDownCommandInput('logTargetOp', 'Operation', adsk.core.DropDownStyles.TextListDropDownStyle)
            for label in logcut_ops_map.keys():
                op_input.listItems.add(label, label == preselect)

            prefs = load_prefs()
            load_materials()
            _add_materials_notice(inputs, 'logMaterialsNotice')
            if not materials_ready():
                return
            families = _materials["families"]
            fam_input = inputs.addDropDownCommandInput('logMatFamily', 'Material Family', adsk.core.DropDownStyles.TextListDropDownStyle)
            init_family = pick_saved(prefs.get('family'), families, families[0])
            for m in families:
                fam_input.listItems.add(m, m == init_family)
            alloy_input = inputs.addDropDownCommandInput('logMatAlloy', 'Specific Alloy', adsk.core.DropDownStyles.TextListDropDownStyle)
            init_alloys = alloys_for(init_family) or ["Standard Grade"]
            init_alloy = pick_saved(prefs.get('alloy'), init_alloys, init_alloys[0])
            for a in init_alloys:
                alloy_input.listItems.add(a, a == init_alloy)

            inputs.addStringValueInput('logMeasured', 'Measured wall error', '')
            tip = inputs.addTextBoxCommandInput(
                'logMeasuredTip', '',
                'e.g. 0.0008 in or 0.02 mm. Positive = oversize, negative = undersize. Leave blank if not measured.',
                2, True)
            tip.isFullWidth = True
            load_input = inputs.addIntegerSliderCommandInput('logLoad', 'Spindle load % (0 = not recorded)', 0, 150)
            load_input.valueOne = 0
            inputs.addBoolValueInput('logChatter', 'Chatter', True, '', False)
            inputs.addBoolValueInput('logSurfaceOk', 'Surface OK', True, '', True)
            notes_input = inputs.addStringValueInput('logNotes', 'Notes', '')
            try:
                notes_input.isMultiLine = True
            except Exception:
                pass
        except Exception as e:
            _report_error("Log Cut Result failed to open.", e)


# ==============================================================================
# ADD-IN RUN / STOP
# ==============================================================================

# ==============================================================================
# COMMAND 6: CLEAN UP DUPLICATE TOOLS (document tool library)
# ==============================================================================

def _tool_signature(t):
    """Identity of a physical tool: type, unit, tool number, description and geometry."""
    g = t.get('geometry', {}) or {}
    pp = t.get('post-process') or t.get('postProcess') or {}

    def r(k):
        v = g.get(k)
        try:
            return round(float(v), 5)
        except (TypeError, ValueError):
            return v
    return (str(t.get('type', '')).lower(), str(t.get('unit', '')).lower(), pp.get('number'),
            str(t.get('description', '')).strip().lower(),
            r('DC'), r('NOF'), r('LCF'), r('shoulder-length'), r('shoulder-diameter'), r('SFDM'),
            r('RE'), r('TA'), r('OAL'), r('LB'))


def _preset_names(t):
    presets = ((t.get('start-values') or {}).get('presets') or [])
    return {p.get('name') for p in presets if isinstance(p, dict) and p.get('name')}


def plan_duplicate_cleanup(entries):
    """Pure planner. entries: [{'index': int, 'tool': dict (tool JSON), 'used': bool}].
    Returns (remove, skipped). Rules: only exact duplicates (same _tool_signature); tools used by
    an operation are never removed; one copy of every group is always kept; a copy holding presets
    the kept tool(s) don't have is skipped, so no cutting data is lost. Holders are ignored."""
    groups = {}
    for e in entries:
        if str(e['tool'].get('type', '')).lower() == 'holder':
            continue
        groups.setdefault(_tool_signature(e['tool']), []).append(e)
    remove, skipped = [], []
    for members in groups.values():
        if len(members) < 2:
            continue
        used = [m for m in members if m['used']]
        keeper = used[0] if used else max(members, key=lambda m: (len(_preset_names(m['tool'])), -m['index']))
        kept = used or [keeper]
        kept_presets = set().union(*(_preset_names(m['tool']) for m in kept))
        for m in members:
            if m['used'] or m is keeper:
                continue
            pp = m['tool'].get('post-process') or m['tool'].get('postProcess') or {}
            info = {'index': m['index'], 'number': pp.get('number'), 'guid': m['tool'].get('guid'),
                    'description': m['tool'].get('description', ''), 'keep_index': keeper['index']}
            extra = _preset_names(m['tool']) - kept_presets
            if extra:
                skipped.append(dict(info, reason="has presets the kept tool lacks: " + ", ".join(sorted(extra))))
            else:
                remove.append(info)
    return remove, skipped


def _collect_document_tools():
    """(library, [{'index', 'tool', 'used'}]) for the active document. 'used' compares tool guids
    with every operation's tool; without guids the tool counts as used (fail safe)."""
    cam = adsk.cam.CAM.cast(app.activeDocument.products.itemByProductType('CAMProductType'))
    if not cam:
        return None, []
    lib = cam.documentToolLibrary
    used_guids, used_sigs = set(), set()
    for setup in cam.setups:
        for op in setup.allOperations:
            t = getattr(op, 'tool', None)
            if not t:
                continue
            try:
                d = json.loads(t.toJson())
            except Exception:
                continue
            # Every operation tool protects its signature too, so a guid mismatch between the
            # operation's tool copy and the library entry can never expose an in-use tool.
            used_sigs.add(_tool_signature(d))
            if d.get('guid'):
                used_guids.add(d['guid'])
    entries = []
    for i in range(lib.count):
        d = json.loads(lib.item(i).toJson())
        used = (d.get('guid') in used_guids) if d.get('guid') else True
        entries.append({'index': i, 'tool': d, 'used': used, 'sig_used': _tool_signature(d) in used_sigs})
    # A group whose signature is used by an operation keeps every member that is (or may be) in
    # use; if no member matched by guid, treat the whole group as in use (fail safe).
    by_sig = {}
    for e in entries:
        by_sig.setdefault(_tool_signature(e['tool']), []).append(e)
    for members in by_sig.values():
        if members[0]['sig_used'] and not any(m['used'] for m in members):
            for m in members:
                m['used'] = True
    return lib, entries


def _cleanup_report(remove, skipped):
    lines = []
    for r in remove:
        lines.append(f"Remove: {tool_label(r['number'])} {r['description']} "
                     f"(duplicate of library item {r['keep_index'] + 1})")
    for k in skipped:
        lines.append(f"Keep:   {tool_label(k['number'])} {k['description']}: {k['reason']}")
    return "\n".join(lines) if lines else "No unused duplicate tools found."


class ToolWizCleanupCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            cmd = args.command
            cmd.isExecutedWhenPreEmpted = False
            cmd.isRepeatable = False
            on_exec = ToolWizCleanupExecuteHandler()
            cmd.execute.add(on_exec)
            handlers.append(on_exec)
            lib, entries = _collect_document_tools()
            if lib is None:
                ui.messageBox('Open a document with CAM data (Manufacture workspace) first.', 'ToolWiz Clean Up')
                return
            remove, skipped = plan_duplicate_cleanup(entries)
            head = (f"{len(remove)} unused duplicate tool(s) will be removed from this document's tool library "
                    f"({lib.count} tools now). Tools used by operations are never removed. "
                    f"Click OK to remove them, or Cancel to leave everything as is.\n\n")
            box = cmd.commandInputs.addTextBoxCommandInput(
                'cleanupPlan', 'Plan', head + _cleanup_report(remove, skipped),
                min(20, 4 + len(remove) + len(skipped)), True)
            box.isFullWidth = True
        except Exception as e:
            _report_error("Clean Up dialog failed.", e)


class ToolWizCleanupExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            lib, entries = _collect_document_tools()   # re-plan on the current state
            if lib is None:
                return
            remove, skipped = plan_duplicate_cleanup(entries)
            before = lib.count
            removed, failed = 0, 0
            ac = AuditedCommand('cleanup_duplicates', target=f"{len(remove)} planned tool removal(s)",
                                expected_doc_changes=True).begin()
            for r in sorted(remove, key=lambda x: x['index'], reverse=True):   # highest index first
                ok = False
                # Address the tool by guid: if the library changed since planning, the index may now point at
                # another tool, so a guid mismatch skips the removal.
                cur = _safe(lambda: json.loads(lib.item(r['index']).toJson()).get('guid'))
                if r.get('guid') and cur and cur != r['guid']:
                    _log(f"Clean Up: library item {r['index']} is no longer guid {r['guid']}; not removed")
                    audit({'event': 'tool_removed', 'library_index': r['index'], 'guid': r['guid'], 'ok': False,
                           'error': 'guid mismatch'})
                    failed += 1
                    continue
                try:
                    if hasattr(lib, 'remove'):
                        ok = bool(lib.remove(r['index']))
                    else:
                        ok = bool(lib.item(r['index']).deleteMe())
                except Exception as ex:
                    _log(f"Could not remove tool at library index {r['index']}", ex)
                audit({'event': 'tool_removed', 'library_index': r['index'], 'guid': r.get('guid'), 'tool_number': r.get('number'),
                       'description': r.get('description'), 'kept_index': r.get('keep_index'), 'ok': ok})
                removed += 1 if ok else 0
                failed += 0 if ok else 1
            _log(f"Clean Up: removed {removed}, failed {failed}, skipped {len(skipped)}; "
                 f"document tools {before} -> {lib.count}")
            msg = f"Removed {removed} duplicate tool(s); {lib.count} tools remain."
            if failed:
                msg += f"\n{failed} could not be removed (see {_log_path()})."
            if skipped:
                msg += f"\n{len(skipped)} duplicate(s) kept because they hold presets the kept tool lacks."
            note = ac.finish(f"removed {removed}, failed {failed}, skipped {len(skipped)}")
            if note:
                msg += "\n\n" + note
            ui.messageBox(msg, 'ToolWiz Clean Up')
        except Exception as e:
            _finish_active_command(f"error: {e}")
            _report_error("Clean Up failed.", e)


# ==============================================================================
# COMMAND 7: DOCUMENT SNAPSHOT / COMPARE
# ==============================================================================

SNAPSHOT_SAVE = "Save snapshot now"
SNAPSHOT_COMPARE = "Compare with last saved snapshot"


def run_snapshot_action(action, snapshot_fn=None):
    """Save or compare a snapshot of the active document. Returns the message to show.
    Read-only with respect to the Fusion document (only files under %APPDATA%/ToolWiz change)."""
    ac = AuditedCommand('document_snapshot', target=action, detect=False).begin()
    result = 'error'
    try:
        snap = (snapshot_fn or snapshot_document)()
        if not snap.get('ops'):
            result = 'no operations'
            return "The active document has no CAM operations to snapshot."
        if action == SNAPSHOT_COMPARE:
            text, changes, path = compare_with_last_snapshot(snap)
            result = f"compared: {len(changes)} change(s)" if path else 'no saved snapshot'
            return text
        path = save_snapshot(snap)
        result = 'saved'
        ac.target = path
        return (f"Snapshot saved: {len(snap['ops'])} operation(s), {snap.get('tool_count')} document tool(s).\n"
                f"{path}\n\nWork, or open other files, then run this command again and choose "
                f"'{SNAPSHOT_COMPARE}' to see exactly what changed.")
    finally:
        ac.finish(result)


class ToolWizSnapshotCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            cmd = args.command
            cmd.isExecutedWhenPreEmpted = False
            cmd.isRepeatable = False
            on_exec = ToolWizSnapshotExecuteHandler()
            cmd.execute.add(on_exec)
            handlers.append(on_exec)
            inputs = cmd.commandInputs
            dd = inputs.addDropDownCommandInput('snapAction', 'Action', adsk.core.DropDownStyles.TextListDropDownStyle)
            dd.listItems.add(SNAPSHOT_SAVE, True, '')
            dd.listItems.add(SNAPSHOT_COMPARE, False, '')
            box = inputs.addTextBoxCommandInput(
                'snapInfo', '',
                "Save a snapshot of every operation (tool, preset, speed, feed, stepdown, stepover) in this "
                "document, then compare later to see exactly what changed, including changes ToolWiz did not make. "
                f"Snapshots are kept in {snapshots_dir()}", 4, True)
            box.isFullWidth = True
        except Exception as e:
            _report_error("Snapshot dialog failed.", e)


class ToolWizSnapshotExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            eventArgs = adsk.core.CommandEventArgs.cast(args)
            action = _selected_name(eventArgs.command.commandInputs.itemById('snapAction')) or SNAPSHOT_SAVE
            ui.messageBox(run_snapshot_action(action), 'ToolWiz Document Snapshot')
        except Exception as e:
            _report_error("Document snapshot failed.", e)


# ==============================================================================
# SHARED HELPERS FOR THE v3 COMMANDS (setup snapshot, result dialogs, op lookup)
# ==============================================================================

def _active_cam():
    try:
        return adsk.cam.CAM.cast(app.activeDocument.products.itemByProductType('CAMProductType'))
    except Exception:
        return None


def _iter_ops_unique():
    """[(setup name, unique "Setup > Op" path, op)] for every operation of the active document. Paths are made
    unique with a " #n" suffix exactly like snapshot_document, so an op_id means the same op everywhere."""
    out, seen = [], set()
    cam = _active_cam()
    if not cam:
        return out
    for setup in _coll_items(cam.setups):
        s_name = _safe(lambda: setup.name) or "Setup"
        for op in _coll_items(setup.allOperations):
            path = f"{s_name} > {_safe(lambda: op.name) or 'Op'}"
            if path in seen:
                n = 2
                while f"{path} #{n}" in seen:
                    n += 1
                path = f"{path} #{n}"
            seen.add(path)
            out.append((s_name, path, op))
    return out


def _op_by_id(op_id):
    """(setup name, path, op) for an op_id ("Setup > Op" path as produced by _iter_ops_unique), else
    (None, None, None). A plain operation name is accepted when it is unambiguous."""
    q = str(op_id or "").strip()
    ops = _iter_ops_unique()
    for s_name, path, op in ops:
        if path == q:
            return s_name, path, op
    named = [t for t in ops if str(_safe(lambda: t[2].name) or "") == q]
    return named[0] if len(named) == 1 else (None, None, None)


def _signed_len_in(p, doc_unit="in"):
    """Length parameter -> inches, negatives allowed (heights/depths). Fusion's evaluated value is cm."""
    if not p:
        return None
    v = _numeric_param_value(p)
    if v is not None:
        return v / 2.54
    try:
        return parse_length_expr_to_inches(getattr(p, 'expression', None), doc_unit)
    except Exception:
        return None


HEIGHT_PARAMS = (('top', 'topHeight_value'), ('bottom', 'bottomHeight_value'), ('clearance', 'clearanceHeight_value'),
                 ('retract', 'retractHeight_value'), ('feed', 'feedHeight_value'))
RAPID_CM_PER_S = 5000.0 / 60.0   # 50 m/min, the planner's rapid rate


def _toolpath_length_in(op):
    """Cutting (feed) distance of the op's toolpath in inches, or None. CAM.getMachiningTime ->
    MachiningTime.feedDistance (cm): https://help.autodesk.com/cloudhelp/ENU/Fusion-360-API/files/cam_MachiningTime.htm"""
    try:
        if not getattr(op, 'hasToolpath', False):
            return None
        cam = _active_cam()
        mt = cam.getMachiningTime(op, 100, RAPID_CM_PER_S, 0)
        d = twlogic.num(getattr(mt, 'feedDistance', None))
        return d / 2.54 if d is not None else None
    except Exception as ex:
        _log("Toolpath length unavailable", ex)
        return None


def _stock_values_in(op, doc_unit="in"):
    out = {}
    for key, names in (("radial", ('stockToLeave', 'radialStockToLeave')), ("axial", ('verticalStockToLeave', 'axialStockToLeave'))):
        for n in names:
            p = _param(getattr(op, 'parameters', None), n)
            if p is not None:
                out[key] = _signed_len_in(p, doc_unit)
                break
    out["active"] = bool(is_op_stock_to_leave_active(op)) if getattr(op, 'parameters', None) else False
    return out


def _expr_in(value_in, unit="in"):
    return None if value_in is None else f"{value_in:.5f} in"


def _rest_machining_flag(op):
    """True/False from the operation's rest-machining parameter, None when it has none."""
    p = _param(getattr(op, 'parameters', None), 'doRestMachining')
    if p is None:
        return None
    return _norm_expr(_safe(lambda: p.expression)) == 'true'


def _tab_geometry(op, length_in, doc_unit):
    """Tabs {count, width_in, height_in} when the op uses tabs. Width and height are read from tabWidth /
    tabHeight; the count is the tabCount parameter, else toolpath length / tabDistance (best effort)."""
    p = getattr(op, 'parameters', None)
    use = _param(p, 'useTabs')
    if use is None or _norm_expr(_safe(lambda: use.expression)) != 'true':
        return None
    width = _signed_len_in(_param(p, 'tabWidth'), doc_unit)
    height = _signed_len_in(_param(p, 'tabHeight'), doc_unit)
    count = None
    pc = _param(p, 'tabCount')
    cnt = twlogic.num(_safe(lambda: pc.value.value)) if pc is not None else None
    if cnt:
        count = int(cnt)
    else:
        dist = _signed_len_in(_param(p, 'tabDistance'), doc_unit)
        if dist and dist > 0 and length_in:
            count = max(1, int(round(length_in / dist)))
    return {"count": count, "width_in": width, "height_in": height}


# 2D Contour "Roughing passes" / multiple stepovers. The Autodesk 2D Contour reference names the Passes-tab fields "Roughing
# Passes" (toggle), "Maximum Stepover" and "Number of Stepovers"
# (https://help.autodesk.com/cloudhelp/ENU/Fusion-CAM/files/GUID75B6821B-DE26-4E3B-AF10-4A54131CD9E4.htm) but lists no parameter
# ids. The ids below are the ones this add-in already writes for those fields (apply_passes_tab_params) plus plausible aliases;
# each is read guarded. VERIFY on your Fusion: right-click the field > Edit Expression, or read `stepover_params_seen` in the
# Setup Advisor snapshot (every parameter whose id contains "step", "pass" or "rough").
MULTI_STEPOVER_FLAGS = ('doMultiplePasses', 'useRoughingPasses', 'doMultipleStepovers', 'useMultipleStepovers')
MULTI_STEPOVER_COUNTS = ('maximumRoughingSteps', 'numberOfStepovers', 'numberOfRoughingSteps', 'roughingStepCount')
MULTI_STEPOVER_SIZES = ('maximumStepover', 'roughingStepover', 'stepover')


def read_multi_stepover(op, doc_unit="in"):
    """{"enabled", "count", "stepover_in", "params": {...ids found}, "source": "measured"} for an operation that has a roughing
    passes / multiple stepovers toggle (2D Contour, Pocket), else None. `count` is the Number of Stepovers (None when unreadable),
    `stepover_in` the Maximum Stepover in inches."""
    params = getattr(op, 'parameters', None)
    if params is None:
        return None
    flag_name = next((n for n in MULTI_STEPOVER_FLAGS if _param(params, n) is not None), None)
    if flag_name is None:
        return None
    enabled = bool(_is_bool_param_true(_param(params, flag_name)))
    count, count_name = None, None
    for n in MULTI_STEPOVER_COUNTS:
        p = _param(params, n)
        if p is None:
            continue
        v = twlogic.num(_safe(lambda: p.value.value))
        if v is None:
            v = _expr_number(_safe(lambda: p.expression))
        if v is not None:
            count, count_name = int(round(v)), n
            break
    so, so_name = None, None
    for n in MULTI_STEPOVER_SIZES:
        p = _param(params, n)
        if p is not None and _safe(lambda: p.isEnabled, True) is not False:
            v = _signed_len_in(p, doc_unit)
            if v and v > 0:
                so, so_name = v, n
                break
    return {"enabled": enabled, "count": count, "stepover_in": so, "source": "measured",
            "params": {"flag": flag_name, "count": count_name, "stepover": so_name}}


def multi_stepover_note(ms, geo_payload, calc_result, payload, aggressiveness, doc_in):
    """Text for the Auto-Setter result when the op has multiple stepovers: the feed written is the full-slot pass's (ae = D, the
    limiting pass); a second server call gives the side passes' feed (ae = stepover) so the owner sees what is left on the table."""
    n, so = ms.get("count"), ms.get("stepover_in")
    d = twlogic.num((geo_payload or {}).get("diameter"), 0.0)
    feed_slot, rpm_slot = calc_result.get("feed"), calc_result.get("rpm")
    side = None
    try:
        p2 = dict(payload)
        p2["operation"] = "Roughing"
        p2["stepover"] = round(float(so), 6)
        if doc_in:
            p2["stepdown"] = round(float(doc_in), 6)
        side = _http_json('/api/calculate_for_fusion', p2, timeout=10.0)
        if not side.get("success"):
            side = None
    except Exception as ex:
        _log("Multiple stepovers: side-pass calculation failed", ex)
    lines = [f"Multiple stepovers ({n} stepovers of {so:.4f} in on a {d:.4f} in tool): the first pass is a FULL SLOT (ae = D = {d:.4f} in), "
             f"the other {n - 1} are side passes (ae = {so:.4f} in). One feed serves the whole operation, so ToolWiz's limiting pass, "
             f"the full slot, sets it: {rpm_slot} rpm, {feed_slot:.2f} IPM."]
    if side and side.get("feed"):
        lines.append(f"The side passes alone could run {side['feed']:.2f} IPM at {side.get('rpm')} rpm. For the shortest cycle, "
                     "split the operation: a full-slot contour at the slot feed plus a side-pass contour at the side feed, or use "
                     "2D Adaptive Clearing (open the Setup Advisor for the times).")
    lines.append("Slotting means full radial width (ae = D). A wider cut against one wall is side milling: traditional roughing at "
                 "30-60% D, or adaptive at 5-30% D.")
    return " ".join(lines)


def stepover_params_seen(op, limit=40):
    """{id: expression} of the op's parameters whose id contains "step", "pass" or "rough" (diagnostic for read_multi_stepover)."""
    out = {}
    try:
        for p in _iter_params(op.parameters):
            nm = str(_safe(lambda: p.name) or "")
            if nm and any(k in nm.lower() for k in ('step', 'pass', 'rough')):
                out[nm] = _safe(lambda: p.expression)
                if len(out) >= limit:
                    break
    except Exception as ex:
        _log("stepover_params_seen failed", ex)
    return out


def op_geometry(op, geo, kind, doc_unit="in"):
    """Feature geometry the advisor's strategy comparison needs (docs/SETUP_ADVISOR.md `geometry`), inches.
    Reliable: top_height_in, bottom_height_in, depth_in (heights), toolpath_length_in (needs a generated
    toolpath), tabs (when the op uses tabs; the count is best effort). Best effort: slot_height_in for slot-mill
    (T-slot) operations = the cutter's flute length (its kerf). NOT derived: slot_width_in, channel_width_in and
    radial_depth_in (Fusion exposes no feature width for a 2D contour; use the Strategy Planner command)."""
    p = getattr(op, 'parameters', None)
    top = _signed_len_in(_param(p, 'topHeight_value'), doc_unit)
    bot = _signed_len_in(_param(p, 'bottomHeight_value'), doc_unit)
    length = _toolpath_length_in(op)
    g = {"top_height_in": top, "bottom_height_in": bot,
         "depth_in": abs(top - bot) if (top is not None and bot is not None) else None,
         "toolpath_length_in": length}
    tabs = _tab_geometry(op, length, doc_unit)
    if tabs:
        g["tabs"] = tabs
    if kind == "slot" and geo and geo.get("fluteLength"):
        g["slot_height_in"] = geo["fluteLength"]
    # Widths. Each value carries its provenance in g["sources"]: "measured" (read from Fusion: op parameters or the op's selected
    # B-Rep geometry) -- anything the advisor needs and cannot find here it assumes itself and labels "assumed".
    src = {}
    dia = twlogic.num((geo or {}).get("diameter")) if geo else None
    try:
        ms = read_multi_stepover(op, doc_unit)
        if ms:
            g["multi_stepover"] = ms
            if ms["enabled"] and (ms["count"] or 0) >= 2 and ms["stepover_in"]:
                w = contour_effective_width_in(dia, ms["count"], ms["stepover_in"])
                if w:
                    g["effective_cut_width_in"] = w
                    src["effective_cut_width_in"] = "measured"
        seen = stepover_params_seen(op)
        if seen:
            g["stepover_params_seen"] = seen
    except Exception as ex:
        _log("Multiple stepover read failed", ex)
    try:
        # Selected-geometry measurements: https://help.autodesk.com/cloudhelp/ENU/Fusion-360-API/files/CAMParameters_UM.htm
        meas = measure_op_widths(op, dia, (geo or {}).get("fluteLength") if kind == "slot" else None,
                                 "tslot" if kind == "slot" else None)
        for k, v in meas.items():
            g[k] = v
            if k.endswith("_in") or k.endswith("_in2"):
                src[k] = "measured"
        if kind == "slot":
            stock = _stock_values_in(op, doc_unit)
            rad = stock.get("radial") if stock.get("active") else None
            if rad is not None and rad < 0:
                g["radial_depth_in"] = -rad          # a negative radial stock to leave pushes the cutter into the wall
                src["radial_depth_in"] = "measured"
            elif meas.get("radial_depth_brep_in") and meas.get("radial_depth_grooves") == 1:
                g["radial_depth_in"] = meas["radial_depth_brep_in"]
                src["radial_depth_in"] = "measured"
    except Exception as ex:
        _log("B-Rep width measurement failed", ex)
    if src:
        g["sources"] = src
    return {k: v for k, v in g.items() if v is not None}


def op_advisor_entry(op, path, doc_unit="in", defaults=None):
    """One operation of the Setup Advisor / bridge snapshot, in the field names of docs/SETUP_ADVISOR.md:
    op_id (= "Setup > Op" path), name, setup, strategy (op.strategy), tool (the Fusion tool JSON, parsed),
    holder {description}, coating, params (expression strings: spindle speed, feeds, stepdown, stepover /
    optimal load, stockToLeave, verticalStockToLeave), geometry, rest_machining. Extras the advisor ignores:
    strategy_label, is_roughing / is_finishing and finishMode / targetRa / wallTolerance for finishing ops."""
    geo, summary, presets = get_op_tool_info(op)
    strat_raw = str(_safe(lambda: op.strategy) or "")
    strat_label = infer_strategy_for_op(op, geo)
    op_name = _safe(lambda: op.name) or path
    rpm, feed, doc, woc = get_op_cut_params(op, doc_unit, strategy=strat_label)
    params_obj = getattr(op, 'parameters', None)
    stock = _stock_values_in(op, doc_unit)
    plunge = parse_cam_feed_to_ipm(_param(params_obj, 'tool_feedPlunge'), doc_unit)
    ramp = parse_cam_feed_to_ipm(_param(params_obj, 'tool_feedRamp'), doc_unit)
    params = {}
    if rpm:
        params["tool_spindleSpeed"] = f"{rpm:.0f} rpm"
    if feed:
        params["tool_feedCutting"] = f"{feed:.3f} in/min"
    if plunge:
        params["tool_feedPlunge"] = f"{plunge:.3f} in/min"
    if ramp:
        params["tool_feedRamp"] = f"{ramp:.3f} in/min"
    if doc:
        params["maximumStepdown"] = _expr_in(doc)
    if woc:
        params["optimalLoad" if "adaptive" in strat_raw.lower() or "adaptive" in strat_label.lower() else "stepover"] = _expr_in(woc)
    if stock.get("active"):
        if stock.get("radial") is not None:
            params["stockToLeave"] = _expr_in(stock["radial"])
        if stock.get("axial") is not None:
            params["verticalStockToLeave"] = _expr_in(stock["axial"])
    entry = {
        "op_id": path, "path": path, "name": op_name, "setup": path.split(" > ", 1)[0], "strategy": strat_raw,
        "strategy_label": strat_label,
        "is_roughing": twlogic.is_roughing_strategy(strat_label, str(op_name)),
        "is_finishing": twlogic.is_finishing_strategy(strat_label, str(op_name)),
        "suppressed": bool(_safe(lambda: op.isSuppressed, False)),
        "params": params,
        "rest_machining": _rest_machining_flag(op),
        "preset": _jsonable(_op_preset_name(op)),
        "heights": {k: _signed_len_in(_param(params_obj, n), doc_unit) for k, n in HEIGHT_PARAMS},
    }
    raw = {}
    if geo:
        try:
            raw = json.loads(geo.get("raw_json") or "{}")
        except Exception:
            raw = {}
        entry["tool"] = raw or None
        hold = raw.get("holder") if isinstance(raw.get("holder"), dict) else None
        if hold:
            entry["holder"] = {"description": str(hold.get("description") or hold.get("product-id") or "")}
            ro, ro_src = geo.get("runout_in"), geo.get("runout_source")
            if ro_src == "tool" and ro is not None:
                entry["holder"]["runout_in"] = ro
        entry["coating"] = geo.get("coating")
        entry["geometry"] = op_geometry(op, geo, geo.get("kind"), doc_unit)
        entry["tool_summary"] = {"number": geo.get("number"), "guid": geo.get("guid"), "kind": geo.get("kind"),
                                 "runout_in": geo.get("runout_in"), "runout_source": geo.get("runout_source")}
    else:
        entry["tool"] = None
        entry["tool_error"] = summary
        entry["geometry"] = op_geometry(op, None, None, doc_unit)
    fin = dict(defaults or {})
    fin.update(_finish_prefs.get(path, {}))
    if entry["is_finishing"] and fin:
        entry.update(twlogic.finish_fields(fin.get("mode"), fin.get("ra_uin"), fin.get("wall_in")))
    return entry


def build_setup_snapshot(setup_name=None, doc_unit=None, finish_defaults=None):
    """The active document's setup (or `setup_name`) as the Setup Advisor request's `setup` object:
    {"document", "name", "setups", "unit", "ops": [op_advisor_entry...]} (the advisor reads `ops`)."""
    doc_unit = doc_unit or get_cam_document_units()
    ops, names = [], []
    for s_name, path, op in _iter_ops_unique():
        if setup_name and s_name != setup_name:
            continue
        if s_name not in names:
            names.append(s_name)
        try:
            ops.append(op_advisor_entry(op, path, doc_unit, finish_defaults))
        except Exception as ex:
            _log(f"Setup snapshot: could not read {path}", ex)
    return {"name": setup_name or (names[0] if len(names) == 1 else ", ".join(names)), "setups": names,
            "document": _doc_name(), "unit": doc_unit, "ops": ops}


def push_live_state(snap=None):
    """POST the setup snapshot to /api/fusion_bridge/state so the server (MCP, setup advisor with
    from_bridge) sees the live setup. Quiet on failure; returns True when posted. Called from the main thread
    by the Setup Advisor command and by the get_setup_summary bridge action."""
    try:
        snap = snap or build_setup_snapshot()
        cam = _active_cam()
        lib = getattr(cam, 'documentToolLibrary', None) if cam else None
        res = _http_json('/api/fusion_bridge/state', {
            "document": snap.get("document"), "setups": snap.get("setups"), "ops": snap.get("ops"),
            "tool_count": getattr(lib, 'count', None)}, timeout=5.0, log_errors=False)
        return bool(isinstance(res, dict) and res.get("success"))
    except Exception as ex:
        _log("Pushing the live setup state failed", ex)
        return False


def current_param_expressions(changes):
    """{op_id: {param: current expression}} for the parameters in `changes`, read from Fusion."""
    cur = {}
    for op_id, params in changes.items():
        _, _, op = _op_by_id(op_id)
        for name in params:
            p = _param(getattr(op, 'parameters', None), name) if op is not None else None
            cur.setdefault(op_id, {})[name] = (_safe(lambda: p.expression) if p is not None else None) or "?"
    return cur


_preapproved = {}   # (op_id, frozenset(params.items())) -> True: the user already confirmed in the advisor dialog


def preapprove_changes(changes):
    for op_id, params in changes.items():
        _preapproved[(op_id, frozenset(params.items()))] = True


def format_apply_confirmation(path, old_new, skipped, reason):
    lines = [f"ToolWiz wants to change {len(old_new)} parameter(s) on:", f"  {path}", ""]
    for name, (old, new) in old_new.items():
        lines.append(f"  {name}: {old} -> {new}")
    for name, why in skipped.items():
        lines.append(f"  (skipped {name}: {why})")
    lines += ["", f"Reason: {reason or 'ToolWiz recommendation'}",
              "These values come from ToolWiz's calculation. Each change is audited and Fusion's Undo reverts it. Apply?"]
    return "\n".join(lines)


def apply_operation_parameters(op_id, params, reason="", confirm=True, advisor_generated_at=None):
    """Bridge action `apply_operation_parameters` (docs/SETUP_ADVISOR.md): write {Fusion parameter name:
    expression} to ONE operation after the user confirms.

    Steps: find the op by its "Setup > Op" path; re-check the allow-list (twlogic.ALLOWED_PARAMS) and the
    expressions; skip (not fail) parameters the op lacks or that are disabled; show the user each parameter's
    old and new value and ask Yes/No (skipped when the user already confirmed the same values in the Setup
    Advisor dialog); write through the audited path (AuditedCommand + one audit line per parameter, like
    apply_stock_to_leave). Writing stockToLeave / verticalStockToLeave also switches on "Stock to leave" (and
    unlocks separate radial/axial values) when it is off, which the confirmation states. Each write is an
    ordinary Fusion edit, so Fusion's Undo reverts it; the old expressions are also saved to revert_<time>.json.

    Returns {ok, success, applied: {name: {old, new}}, skipped: {name: reason}, error, operation}."""
    def fail(msg, skipped=None):
        return {"ok": False, "success": False, "applied": {}, "skipped": skipped or {}, "error": msg}
    s_name, path, op = _op_by_id(op_id)
    if op is None:
        return fail(f"Operation {op_id!r} not found.")
    accepted, rejected = twlogic.validate_parameter_changes(params if isinstance(params, dict) else {})
    skipped = {r["param"]: r["reason"] for r in rejected}
    plan = {}
    for name, expr in accepted.items():
        p = _param(getattr(op, 'parameters', None), name)
        if p is None:
            skipped[name] = "operation has no such parameter"
        elif not getattr(p, 'isEnabled', True) and name not in ('stockToLeave', 'verticalStockToLeave'):
            skipped[name] = "parameter is disabled on this operation"
        else:
            plan[name] = (p, _safe(lambda: p.expression), expr)
    if not plan:
        r = fail("nothing to apply", skipped)
        r["operation"] = path
        return r
    key = (op_id, frozenset((n, plan[n][2]) for n in plan))
    pre = any(k[0] == op_id and k[1] >= frozenset(key[1]) for k in _preapproved)
    if confirm and not pre:
        text = format_apply_confirmation(path, {n: (o, e) for n, (_, o, e) in plan.items()}, skipped,
                                         reason + (f" (advisor result of {advisor_generated_at})" if advisor_generated_at else ""))
        ans = ui.messageBox(text, "ToolWiz - apply recommended parameters", adsk.core.MessageBoxButtonTypes.YesNoButtonType,
                            adsk.core.MessageBoxIconTypes.QuestionIconType)
        if ans != adsk.core.DialogResults.DialogYes:
            audit({'event': 'apply_declined', 'op_path': path, 'params': sorted(plan)})
            r = fail("declined by the user", skipped)
            r["operation"] = path
            return r
    for k in [k for k in _preapproved if k[0] == op_id]:
        _preapproved.pop(k, None)
    ac = AuditedCommand('apply_operation_parameters', target=path, targets=[path]).begin()
    audit({'event': 'apply_confirmed', 'op_path': path, 'reason': reason, 'advisor_generated_at': advisor_generated_at,
           'params': {n: plan[n][2] for n in plan}})
    applied, previous, error = {}, {}, None
    try:
        if any(n in plan for n in ('stockToLeave', 'verticalStockToLeave')) and not is_op_stock_to_leave_active(op):
            for chk in ('useStockToLeave', 'isStockToLeave'):
                _set_bool_param(op, chk, True)
            _set_bool_param(op, 'simpleStockToLeave', False)
        for name in sorted(plan):
            p, old_e, expr = plan[name]
            try:
                _set_expression(op, p, name, expr)
                applied[name] = {"old": old_e, "new": _safe(lambda: p.expression) or expr}
                previous[name] = old_e
            except Exception as ex:
                skipped[name] = f"Fusion rejected the value: {ex}"
    except Exception as ex:
        error = str(ex)
    note = ac.finish("ok" if applied and not error else f"applied {len(applied)}, skipped {len(skipped)}"
                     + (f", error {error}" if error else ""))
    if previous:
        try:
            rp = os.path.join(_toolwiz_dir(), f"revert_{datetime.datetime.now().strftime('%Y%m%dT%H%M%S')}.json")
            with open(rp, 'w', encoding='utf-8') as f:
                json.dump({"operation": path, "reason": reason, "previous": previous, "applied": applied}, f, indent=2)
        except Exception as ex:
            _log("Could not write the revert file", ex)
    ok = bool(applied) and not error
    return {"ok": ok, "success": ok, "operation": path, "reason": reason, "applied": applied, "skipped": skipped,
            "previous": previous, "audit_note": note, "error": error or (None if applied else "nothing was applied")}


# ---- update_tool_fields (bridge action, Advisor Chat): coating / BMC / GRADE / description keywords of a document tool ----

def _doc_tool_matches(lib, number=None, guid=None):
    """[(library index, tool JSON dict)] of the document-library tools with this guid (preferred) or tool number."""
    out = []
    for i in range(getattr(lib, 'count', 0) or 0):
        d = _safe(lambda: json.loads(lib.item(i).toJson()))
        if not isinstance(d, dict):
            continue
        if guid:
            if d.get('guid') == guid:
                out.append((i, d))
        elif number is not None and _safe(lambda: extract_tool_number(None, d)) == number:
            out.append((i, d))
    return out


def format_tool_fields_confirmation(label, description, changes, skipped, reason, n_ops):
    lines = [f"ToolWiz wants to change tool {label} in this document's tool library:", f"  {description}", ""]
    for name, ch in changes.items():
        lines.append(f"  {name}: {ch.get('old')!s} -> {ch.get('new')!s}")
    for name, why in skipped.items():
        lines.append(f"  (skipped {name}: {why})")
    lines += ["", f"Reason: {reason or 'ToolWiz Advisor Chat'}"]
    if n_ops:
        lines.append(f"The change applies to the tool itself, so it affects all {n_ops} operation(s) that use it (no speed or feed values change).")
    lines.append("Each change is audited and Fusion's Undo reverts it. Apply?")
    return "\n".join(lines)


def update_tool_fields(tool_number=None, tool_guid=None, fields=None, reason="", confirm=True):
    """Bridge action `update_tool_fields`: write allow-listed fields (coating, BMC, GRADE, comment, description or description
    keywords such as "staggered") of ONE tool of the document tool library after the user confirms.

    Steps: find the tool by guid (preferred) or tool number (an ambiguous number is refused); re-check the allow-list
    (twlogic.validate_tool_fields); work out old -> new; ask Yes/No showing each change; write through the audited path
    (AuditedCommand + one audit line per field) with the tool JSON round trip `Tool.createFromJson` +
    `DocumentToolLibrary.update(tool, False)` (updateFeedAndSpeed False: operation values are not touched); re-read the tool to
    confirm what Fusion kept. Each change can be reverted with Fusion's Undo; the old values are also saved to revert_<time>.json.

    Returns {ok, success, applied: {field: {old, new}}, skipped: {field: reason}, error, tool: {number, guid, description}}."""
    def fail(msg, skipped=None, tool=None):
        return {"ok": False, "success": False, "applied": {}, "skipped": skipped or {}, "error": msg, "tool": tool}
    label = tool_label(tool_number) if tool_number is not None else f"guid {tool_guid}"
    cam = _active_cam()
    lib = getattr(cam, 'documentToolLibrary', None) if cam else None
    if lib is None:
        return fail("No active CAM document with a tool library (open the Manufacture workspace).")
    accepted, rejected = twlogic.validate_tool_fields(fields if isinstance(fields, dict) else {})
    skipped = {r["field"]: r["reason"] for r in rejected}
    if not accepted:
        return fail("nothing to apply", skipped)
    matches = _doc_tool_matches(lib, number=tool_number, guid=tool_guid)
    if not matches:
        return fail(f"Tool {label} was not found in the document tool library.", skipped)
    if len(matches) > 1:
        names = "; ".join(str(d.get('description') or '?')[:40] for _, d in matches[:4])
        return fail(f"{len(matches)} tools in the library have number {tool_number} ({names}); it cannot be told which one to change.", skipped)
    idx, td = matches[0]
    info = {"number": tool_number, "guid": td.get('guid'), "description": td.get('description')}
    if not td.get('guid'):
        return fail("This tool has no guid, so Fusion cannot be asked to update exactly this tool.", skipped, info)
    new_td, changes = twlogic.apply_tool_field_changes(td, accepted)
    for f in accepted:
        key = f if f in ("coating", "BMC", "GRADE", "comment", "description") else "description"
        if key not in changes:
            skipped[f] = "already as requested"
    if not changes:
        return {"ok": True, "success": True, "applied": {}, "skipped": skipped, "error": None, "tool": info}
    if confirm:
        n_ops = _safe(lambda: lib.operationsByTool(lib.item(idx)).count)
        text = format_tool_fields_confirmation(label, td.get('description') or '', changes, skipped, reason,
                                               n_ops if isinstance(n_ops, int) else None)
        ans = ui.messageBox(text, "ToolWiz - change tool fields", adsk.core.MessageBoxButtonTypes.YesNoButtonType,
                            adsk.core.MessageBoxIconTypes.QuestionIconType)
        if ans != adsk.core.DialogResults.DialogYes:
            audit({'event': 'tool_fields_declined', 'tool_number': tool_number, 'tool_guid': td.get('guid'), 'fields': sorted(changes)})
            return fail("declined by the user", skipped, info)
    ac = AuditedCommand('update_tool_fields', target=label, expected_doc_changes=True).begin()
    audit({'event': 'tool_fields_confirmed', 'tool_number': tool_number, 'tool_guid': td.get('guid'), 'reason': reason,
           'changes': {k: v for k, v in changes.items()}})
    before_count = _safe(lambda: lib.count)
    error = None
    try:
        if not hasattr(lib, 'update') or not hasattr(adsk.cam.Tool, 'createFromJson'):
            raise RuntimeError("this Fusion version has no DocumentToolLibrary.update / Tool.createFromJson")
        new_tool = adsk.cam.Tool.createFromJson(json.dumps(new_td))
        result = lib.update(new_tool, False)
        _log(f"update_tool_fields {label}: documentToolLibrary.update returned {result!r}")
    except Exception as ex:
        error = str(ex)
        _log("update_tool_fields failed", ex)
    applied = {}
    after = _doc_tool_matches(lib, guid=td.get('guid')) if not error else []
    kept = after[0][1] if after else None
    for name, ch in changes.items():
        if error:
            audit({'event': 'tool_field_change', 'tool_number': tool_number, 'tool_guid': td.get('guid'), 'field': name,
                   'old': ch.get('old'), 'new': ch.get('new'), 'ok': False, 'error': error})
            continue
        if name == "coating":
            ok_f = kept is None or twlogic.coating_in_text(" ".join(str(kept.get(k) or "") for k in ("description", "BMC", "GRADE"))) == ch['new']
        else:
            ok_f = kept is None or str(kept.get(name) or "") == str(ch['new'] or "")
        audit({'event': 'tool_field_change', 'tool_number': tool_number, 'tool_guid': td.get('guid'), 'field': name,
               'old': ch.get('old'), 'new': ch.get('new'), 'ok': ok_f})
        if ok_f:
            applied[name] = {"old": ch.get('old'), "new": ch.get('new')}
        else:
            skipped[name] = "Fusion did not keep the new value"
    after_count = _safe(lambda: lib.count)
    warn = ""
    if before_count is not None and after_count is not None and after_count != before_count:
        warn = f" WARNING: the tool count changed from {before_count} to {after_count}; check the tool library (Undo reverts it)."
        _log(warn)
    note = ac.finish("ok" if applied and not error else f"applied {len(applied)}, skipped {len(skipped)}" + (f", error {error}" if error else ""))
    if applied:
        try:
            rp = os.path.join(_toolwiz_dir(), f"revert_{datetime.datetime.now().strftime('%Y%m%dT%H%M%S')}.json")
            with open(rp, 'w', encoding='utf-8') as f:
                json.dump({"tool": label, "guid": td.get('guid'), "reason": reason,
                           "previous": {k: v["old"] for k, v in applied.items()}, "applied": applied}, f, indent=2)
        except Exception as ex:
            _log("Could not write the revert file", ex)
    ok = bool(applied) and not error
    err = error or (None if applied else "nothing was applied")
    return {"ok": ok, "success": ok, "applied": applied, "skipped": skipped, "tool": info, "audit_note": (note + warn).strip(),
            "error": (err + warn) if err else None}


# ---- get_viewport_image (bridge action, Advisor Chat): a screenshot of the active viewport for a vision-capable model ----

_VIEWPORT_MAX_BYTES = 3 * 1024 * 1024


def get_viewport_image(width=1280, height=800):
    """Save the active viewport to a temporary PNG (Viewport.saveAsImageFile(filename, width, height); 0 = the viewport's own size;
    https://help.autodesk.com/cloudhelp/ENU/Fusion-360-API/files/core_Viewport_saveAsImageFile.htm), return it base64 encoded and
    delete the file. Read-only: nothing in the document changes."""
    import base64
    vp = getattr(app, 'activeViewport', None) if app else None
    if vp is None or not hasattr(vp, 'saveAsImageFile'):
        return {"ok": False, "success": False, "error": "Fusion has no active viewport (open a document and make a view visible)."}
    w = int(width) if isinstance(width, int) and 0 <= width <= 4096 else 1280
    h = int(height) if isinstance(height, int) and 0 <= height <= 4096 else 800
    path = os.path.join(_toolwiz_dir(), f"viewport_{uuid.uuid4().hex[:8]}.png")
    try:
        os.makedirs(_toolwiz_dir(), exist_ok=True)
        if not vp.saveAsImageFile(path, w, h) or not os.path.exists(path):
            return {"ok": False, "success": False, "error": "Fusion could not save the viewport image."}
        size = os.path.getsize(path)
        if size > _VIEWPORT_MAX_BYTES:
            return {"ok": False, "success": False, "error": f"The viewport image is too large to send ({size // 1024} KB); make the Fusion window smaller."}
        with open(path, 'rb') as f:
            data = base64.b64encode(f.read()).decode('ascii')
        audit({'event': 'viewport_image', 'bytes': size, 'width': w, 'height': h})
        return {"ok": True, "success": True, "media_type": "image/png", "data_base64": data, "width": w, "height": h}
    except Exception as ex:
        _log("get_viewport_image failed", ex)
        return {"ok": False, "success": False, "error": f"Could not capture the viewport: {ex}"}
    finally:
        try:
            if os.path.exists(path):
                os.remove(path)
        except OSError:
            pass


# ---- generic read-only result dialog (opened from the main thread when a background request finishes) -------

_text_result = {"title": "", "text": "", "jumps": []}


def show_text_result(title, text, jumps=None):
    """Show `text` in a scrollable ToolWiz dialog. `jumps` is [(label, guid)] for an optional 'select the
    operations that use this tool' control. Falls back to a message box when the dialog is unavailable."""
    _text_result.update(title=title, text=text, jumps=list(jumps or []))
    try:
        cd = ui.commandDefinitions.itemById(textResultCommandId)
        if cd is not None:
            cd.execute()
            return
    except Exception as ex:
        _log("Result dialog unavailable; using a message box", ex)
    ui.messageBox(text, title)


def select_ops_using_tool(guid):
    """Select (in Fusion's browser) every operation that uses the tool with this guid. Returns the count."""
    sel = ui.activeSelections
    sel.clear()
    n = 0
    for _, path, op in _iter_ops_unique():
        t = getattr(op, 'tool', None)
        try:
            g = json.loads(t.toJson()).get('guid') if t else None
        except Exception:
            g = None
        if g and g == guid:
            sel.add(op)
            n += 1
    return n


class ToolWizTextResultExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            inputs = adsk.core.CommandEventArgs.cast(args).command.commandInputs
            dd = inputs.itemById('resultJump')
            if dd is not None and dd.selectedItem and getattr(dd, 'isVisible', True):
                label = dd.selectedItem.name
                guid = dict(_text_result["jumps"]).get(label)
                if guid:
                    n = select_ops_using_tool(guid)
                    ui.messageBox(f"Selected {n} operation(s) that use this tool." if n else
                                  "No operation in this document uses that tool. Find it in the Tool Library "
                                  f"dialog ({label}).", "ToolWiz")
        except Exception as e:
            _report_error("Could not jump to the tool.", e)


class ToolWizTextResultCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            cmd = args.command
            cmd.isExecutedWhenPreEmpted = False
            try:
                cmd.okButtonText = 'Close' if not _text_result["jumps"] else 'Select operations'
            except Exception:
                pass
            on_exec = ToolWizTextResultExecuteHandler()
            cmd.execute.add(on_exec)
            hidden_handlers.append(on_exec)
            inputs = cmd.commandInputs
            text = _text_result["text"] or ""
            box = inputs.addTextBoxCommandInput('resultText', _text_result["title"] or 'ToolWiz', text,
                                                max(6, min(28, text.count("\n") + 2)), True)
            box.isFullWidth = True
            if _text_result["jumps"]:
                dd = inputs.addDropDownCommandInput('resultJump', 'Jump to tool', adsk.core.DropDownStyles.TextListDropDownStyle)
                for i, (label, _g) in enumerate(_text_result["jumps"]):
                    dd.listItems.add(label, i == 0)
        except Exception as e:
            _report_error("Result dialog failed.", e)


# ==============================================================================
# v3 COMMANDS: shared dialog pieces
# ==============================================================================

def _add_material_inputs(inputs, prefix, prefs, optional=False):
    """Family + alloy dropdowns with ids <prefix>MatFamily / <prefix>MatAlloy. With optional=True the family
    list starts with '(any material)'. Returns False when no material list is available."""
    load_materials()
    _add_materials_notice(inputs, f'{prefix}MaterialsNotice')
    if not materials_ready():
        return False
    families = _materials["families"]
    fam = inputs.addDropDownCommandInput(f'{prefix}MatFamily', 'Material Family', adsk.core.DropDownStyles.TextListDropDownStyle)
    saved = pick_saved(prefs.get('family'), families, None)
    init_family = saved if (saved or not optional) else None
    if not optional and init_family is None:
        init_family = families[0]
    if optional:
        fam.listItems.add('(any material)', init_family is None)
    for m in families:
        fam.listItems.add(m, m == init_family)
    alloy = inputs.addDropDownCommandInput(f'{prefix}MatAlloy', 'Specific Alloy', adsk.core.DropDownStyles.TextListDropDownStyle)
    init_alloys = alloys_for(init_family or families[0]) or ["Standard Grade"]
    init_alloy = pick_saved(prefs.get('alloy'), init_alloys, init_alloys[0])
    for a_ in init_alloys:
        alloy.listItems.add(a_, a_ == init_alloy)
    return True


class ToolWizV3InputChangedHandler(adsk.core.InputChangedEventHandler):
    """Keeps every <prefix>MatAlloy list in step with its <prefix>MatFamily choice."""
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            ea = adsk.core.InputChangedEventArgs.cast(args)
            iid = ea.input.id
            if iid.endswith('MatFamily'):
                alloy = ea.inputs.itemById(iid[:-len('MatFamily')] + 'MatAlloy')
                if alloy:
                    alloy.listItems.clear()
                    alloys = alloys_for(_selected_name(ea.input)) or ["Standard Grade"]
                    for i, a in enumerate(alloys):
                        alloy.listItems.add(a, i == 0)
        except Exception as e:
            _log("v3 input-changed handler failed", e)


def _family_alloy(inputs, prefix):
    fam = _selected_name(inputs.itemById(f'{prefix}MatFamily'))
    if fam.startswith('('):
        fam = ""
    return fam, (_selected_name(inputs.itemById(f'{prefix}MatAlloy')) if fam else "")


def _new_command(args, handler_cls, with_input_changed=True, ok_text=None):
    """Common commandCreated boilerplate: returns (cmd, inputs)."""
    cmd = args.command
    cmd.isExecutedWhenPreEmpted = False
    cmd.isRepeatable = False
    cmd.isAutoExecute = False
    if ok_text:
        try:
            cmd.okButtonText = ok_text
        except Exception:
            pass
    on_exec = handler_cls()
    cmd.execute.add(on_exec)
    handlers.append(on_exec)
    if with_input_changed:
        on_chg = ToolWizV3InputChangedHandler()
        cmd.inputChanged.add(on_chg)
        handlers.append(on_chg)
    return cmd, cmd.commandInputs


def _server_error_box(what, err):
    """Message for a failed background request (offline / HTTP error)."""
    if isinstance(err, (urllib.error.URLError, OSError, ValueError)):
        ui.messageBox(_offline_message(what), "Tool Wizard Server Offline")
    else:
        _report_error(f"ToolWiz could not {what}.", err)


def _int_slider(inputs, input_id):
    inp = inputs.itemById(input_id)
    try:
        return int(inp.valueOne) if inp is not None else 50
    except Exception:
        return 50


# ==============================================================================
# COMMAND 8: SETUP ADVISOR
# ==============================================================================

_advisor_state = {"parsed": None, "recs": [], "reason": "ToolWiz Setup Advisor"}


class ToolWizSetupAdvisorCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            cmd, inputs = _new_command(args, ToolWizSetupAdvisorExecuteHandler, ok_text='Run Advisor')
            cam = _active_cam()
            if not cam or not _coll_items(cam.setups):
                ui.messageBox('Please switch to the Manufacture (CAM) workspace with an active setup.', 'ToolWiz Setup Advisor')
                return
            names = [_safe(lambda: s.name) or '?' for s in _coll_items(cam.setups)]
            sel = _selected_operation()
            pre = _op_setup_name(sel) if sel is not None else names[0]
            dd = inputs.addDropDownCommandInput('advSetup', 'Setup', adsk.core.DropDownStyles.TextListDropDownStyle)
            for n in names:
                dd.listItems.add(n, n == pre)
            if len(names) > 1:
                dd.listItems.add('(all setups)', False)
            prefs = load_prefs()
            if not _add_material_inputs(inputs, 'adv', prefs):
                return
            agg = inputs.addIntegerSliderCommandInput('advAggressiveness', 'Aggressiveness', 0, 100)
            agg.valueOne = prefs.get('aggressiveness', 50)
            doc_u = get_cam_document_units()
            inputs.addStringValueInput('advRunout', 'Runout / TIR (blank = each tool\'s own, else 0.0002 in)', '')
            inputs.addBoolValueInput('advLlm', 'Add an AI narrative (numbers are verified against ToolWiz results)', True, '', False)
            fm = inputs.addDropDownCommandInput('advFinishMode', 'Finish mode for finishing ops', adsk.core.DropDownStyles.TextListDropDownStyle)
            for label, code in twlogic.FINISH_MODES:
                fm.listItems.add(label, code == 'cleanup')
            fm.tooltip = ('Applies to finishing operations that you did not set individually with the Speeds & Feeds '
                          'command (that choice is remembered per operation for this session).')
            inputs.addStringValueInput('advRa', 'Target surface finish (Ra)', twlogic.ra_uin_to_text(twlogic.DEFAULT_RA_UIN, doc_u))
            inputs.addStringValueInput('advTol', 'Wall tolerance', twlogic.fmt_len(twlogic.DEFAULT_WALL_TOL_IN, doc_u, 5 if doc_u != 'mm' else 4))
            box = inputs.addTextBoxCommandInput(
                'advInfo', '',
                f'Pushes this setup (strategy, tool, holder, feeds, stepdown/stepover, stock to leave, heights, toolpath '
                f'length) to ToolWiz for review. Model: {model_label(load_model_setting())}. Nothing is changed in '
                'Fusion until you tick recommendations and confirm.', 4, True)
            box.isFullWidth = True
        except Exception as e:
            _report_error("Setup Advisor failed to open.", e)


class ToolWizSetupAdvisorExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            inputs = adsk.core.CommandEventArgs.cast(args).command.commandInputs
            if not materials_ready():
                ui.messageBox(_materials.get("notice") or "Material list unavailable.", "ToolWiz Setup Advisor")
                return
            family, alloy = _family_alloy(inputs, 'adv')
            setup_name = _selected_name(inputs.itemById('advSetup'))
            setup_name = None if setup_name.startswith('(') else setup_name
            agg = _int_slider(inputs, 'advAggressiveness')
            doc_u = get_cam_document_units()
            try:
                runout = twlogic.parse_runout_text(inputs.itemById('advRunout').value, None)
                fin = {"mode": twlogic.finish_mode_code(_selected_name(inputs.itemById('advFinishMode'))),
                       "ra_uin": twlogic.parse_ra_text(inputs.itemById('advRa').value, doc_u),
                       "wall_in": parse_length_expr_to_inches(inputs.itemById('advTol').value, doc_u)}
            except (ValueError, ArithmeticError) as ve:
                ui.messageBox(str(ve), 'ToolWiz Setup Advisor')
                return
            use_llm = bool(inputs.itemById('advLlm').value)
            save_prefs(family=family, alloy=alloy, aggressiveness=agg)
            snap = build_setup_snapshot(setup_name, doc_u, fin)
            if not snap["ops"]:
                ui.messageBox('This setup has no operations to review.', 'ToolWiz Setup Advisor')
                return
            push_live_state()
            body = {"setup": snap, "family": family, "alloy": alloy, "aggressiveness": agg / 100.0,
                    "use_llm": use_llm, "unit": doc_u}
            if runout is not None:
                body["runout"] = runout
            model = load_model_setting()
            if model:
                body["model"] = model
            audit({'event': 'setup_advisor_request', 'ops': len(snap["ops"]), 'use_llm': use_llm})
            ui.messageBox(f"Sending {len(snap['ops'])} operation(s) to ToolWiz. The results dialog opens when "
                          "the review is done; you can keep working meanwhile.", "ToolWiz Setup Advisor")
            run_async(lambda: _http_json('/api/setup_advisor', body, timeout=240.0), _advisor_done)
        except Exception as e:
            _report_error("Setup Advisor failed.", e)


def _advisor_done(res, err):
    if err is not None:
        _server_error_box("run the setup advisor", err)
        return
    parsed = twlogic.parse_advisor_response(res)
    if not parsed["ok"]:
        ui.messageBox(f"The setup advisor returned an error:\n{(res or {}).get('error') or res}", "ToolWiz Setup Advisor")
        return
    _advisor_state.update(parsed=parsed, recs=twlogic.extract_recommendations(parsed))
    try:
        cd = ui.commandDefinitions.itemById(advisorResultCommandId)
        if cd is None:
            raise RuntimeError("result command missing")
        cd.execute()
    except Exception as ex:
        _log("Advisor result dialog unavailable", ex)
        show_text_result("ToolWiz Setup Advisor", twlogic.format_advisor_summary(parsed))


def _selected_rec_ids(inputs):
    dd = inputs.itemById('advRecs')
    if dd is None:
        return set()
    names = {i.name for i in dd.listItems if i.isSelected}
    return {r["id"] for r in _advisor_state["recs"] if _rec_label(r) in names}


def _rec_label(r):
    return f"[{r['severity']}] {r['title']}"[:110]


def _changes_preview(inputs):
    ids = _selected_rec_ids(inputs)
    changes, conflicts = twlogic.merge_selected_changes(_advisor_state["recs"], ids)
    if not changes:
        return changes, "Nothing selected."
    lines = twlogic.summarize_changes(changes, current_param_expressions(changes))
    if conflicts:
        lines += ["", "Conflicting recommendations (the later one wins):"] + conflicts
    return changes, "\n".join(lines)


class ToolWizSetupAdvisorResultCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            cmd = args.command
            cmd.isExecutedWhenPreEmpted = False
            try:
                cmd.okButtonText = 'Apply selected'
            except Exception:
                pass
            on_exec = ToolWizSetupAdvisorResultExecuteHandler()
            cmd.execute.add(on_exec)
            on_chg = ToolWizSetupAdvisorResultChangedHandler()
            cmd.inputChanged.add(on_chg)
            hidden_handlers.extend([on_exec, on_chg])
            parsed = _advisor_state["parsed"]
            inputs = cmd.commandInputs
            text = twlogic.format_advisor_summary(parsed)
            box = inputs.addTextBoxCommandInput('advSummary', 'Findings', text, max(8, min(26, text.count("\n") + 2)), True)
            box.isFullWidth = True
            recs = _advisor_state["recs"]
            if recs:
                dd = inputs.addDropDownCommandInput('advRecs', 'Recommendations to apply', adsk.core.DropDownStyles.CheckBoxDropDownStyle)
                for r in recs:
                    dd.listItems.add(_rec_label(r), False)
                pv = inputs.addTextBoxCommandInput('advChanges', 'Parameters that will change', 'Nothing selected.', 6, True)
                pv.isFullWidth = True
            else:
                inputs.addTextBoxCommandInput('advNone', '', 'No recommendation carries parameter changes that can be '
                                              'applied automatically. Use the findings above when editing the operations.', 3, True)
        except Exception as e:
            _report_error("Advisor results failed to open.", e)


class ToolWizSetupAdvisorResultChangedHandler(adsk.core.InputChangedEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            ea = adsk.core.InputChangedEventArgs.cast(args)
            if ea.input.id == 'advRecs':
                _, text = _changes_preview(ea.inputs)
                pv = ea.inputs.itemById('advChanges')
                if pv:
                    pv.text = text
        except Exception as e:
            _log("Advisor result input-changed failed", e)


class ToolWizSetupAdvisorResultExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            inputs = adsk.core.CommandEventArgs.cast(args).command.commandInputs
            ids = _selected_rec_ids(inputs)
            changes, text = _changes_preview(inputs)
            if not changes:
                return
            n_params = sum(len(p) for p in changes.values())
            ok = ui.messageBox(
                f"ToolWiz will change {n_params} parameter(s) on {len(changes)} operation(s):\n\n{text}\n\n"
                "Each change is audited and can be undone with Fusion's Undo; the old values are saved to a revert "
                "file. Apply?", "ToolWiz Setup Advisor", adsk.core.MessageBoxButtonTypes.YesNoButtonType,
                adsk.core.MessageBoxIconTypes.QuestionIconType)
            if ok != adsk.core.DialogResults.DialogYes:
                return
            reqs = twlogic.build_apply_requests(changes, _advisor_state["reason"])
            preapprove_changes(changes)     # the user just confirmed these exact values; the bridge action does not ask again

            def work():
                out = []
                for body in reqs:
                    try:
                        out.append((body["op_id"], _http_json('/api/setup_advisor/apply', body, timeout=150.0), None))
                    except Exception as ex:
                        out.append((body["op_id"], None, ex))
                return out
            run_async(work, _advisor_apply_done)
        except Exception as e:
            _report_error("Applying recommendations failed.", e)


def _advisor_apply_done(out, err):
    """Main-thread end of the apply: one /api/setup_advisor/apply response per operation. The server checks the
    values against its last advisor result and queues the bridge action; the add-in's bridge handler (on the
    main thread, while this request waits in a worker) writes them and returns {ok, applied, skipped, error}."""
    try:
        if err is not None:
            _server_error_box("apply the recommendations", err)
            return
        results, notes = [], []
        for op_id, res, ex in out or []:
            if ex is not None:
                results.append({"op_id": op_id, "applied": [], "skipped": [], "error":
                                "ToolWiz server unreachable or too old for /api/setup_advisor/apply: " + str(ex)})
                continue
            r = twlogic.normalize_apply_result(res)
            r["op_id"] = op_id
            if isinstance(res, dict) and res.get("success") is False and not r["error"]:
                r["error"] = str(res.get("error") or "the apply request failed")
            results.append(r)
        ui.messageBox(f"Setup Advisor changes:\n\n{twlogic.format_apply_results(results)}\n\n"
                      "Regenerate the toolpaths before posting.", "ToolWiz Setup Advisor")
    except Exception as e:
        _report_error("Applying recommendations failed.", e)


# ==============================================================================
# COMMAND 9: STRATEGY PLANNER
# ==============================================================================

FEATURE_TYPES = [("Contour cut-out around a part (tabs)", "profile_cutout"), ("Slot (fixed width)", "slot"),
                 ("T-slot / keyseat", "tslot")]


def _op_depth_in(op, doc_unit="in"):
    p = getattr(op, 'parameters', None)
    top, bot = _signed_len_in(_param(p, 'topHeight_value'), doc_unit), _signed_len_in(_param(p, 'bottomHeight_value'), doc_unit)
    return abs(top - bot) if (top is not None and bot is not None) else None


class ToolWizStrategyCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            cmd, inputs = _new_command(args, ToolWizStrategyExecuteHandler, ok_text='Compare')
            cam = _active_cam()
            if not cam:
                ui.messageBox('Please switch to the Manufacture (CAM) workspace.', 'ToolWiz Strategy Planner')
                return
            ops_map = {}
            pre = discover_tool_ops(cam, ops_map)
            global strategy_ops_map
            strategy_ops_map = ops_map
            dd = inputs.addDropDownCommandInput('stratOp', 'Prefill from operation', adsk.core.DropDownStyles.TextListDropDownStyle)
            dd.listItems.add('(none - enter the job below)', not pre)
            for label in ops_map:
                dd.listItems.add(label, label == pre)
            doc_u = get_cam_document_units()
            op = ops_map.get(pre)
            depth = _op_depth_in(op, doc_u) if op is not None else None
            length = _toolpath_length_in(op) if op is not None else None
            ft = inputs.addDropDownCommandInput('stratFeature', 'Feature', adsk.core.DropDownStyles.TextListDropDownStyle)
            for i, (label, code) in enumerate(FEATURE_TYPES):
                ft.listItems.add(label, i == 0)
            inputs.addStringValueInput('stratDepth', 'Depth / part thickness', twlogic.fmt_len(depth, doc_u) if depth else '')
            inputs.addStringValueInput('stratLength', 'Contour length / slot length', twlogic.fmt_len(length, doc_u) if length else '')
            inputs.addStringValueInput('stratWidth', 'Slot width (slot) or channel width (optional)', '')
            inputs.addIntegerSpinnerCommandInput('stratTabs', 'Tabs (count, 0 = none)', 0, 200, 1, 0)
            inputs.addStringValueInput('stratTabWidth', 'Tab width', twlogic.fmt_len(0.1, doc_u))
            inputs.addStringValueInput('stratTabHeight', 'Tab height', twlogic.fmt_len(0.04, doc_u))
            inputs.addStringValueInput('stratSlotHeight', 'T-slot: slot height (Z)', '')
            inputs.addStringValueInput('stratRadial', 'T-slot: radial depth', '')
            prefs = load_prefs()
            if not _add_material_inputs(inputs, 'strat', prefs):
                return
            agg = inputs.addIntegerSliderCommandInput('stratAggressiveness', 'Aggressiveness', 0, 100)
            agg.valueOne = prefs.get('aggressiveness', 50)
            inputs.addStringValueInput('stratRunout', 'Runout / TIR (blank = default 0.0002 in)', '')
            # Candidate cutters: the document's tools (and, for T-slots, the shop cutters from /api/shop_tools).
            cands = inputs.addDropDownCommandInput('stratCandidates', 'Candidate tools', adsk.core.DropDownStyles.CheckBoxDropDownStyle)
            global strategy_candidates
            strategy_candidates = {}
            for label, t in _document_tool_candidates():
                strategy_candidates[label] = t
                cands.listItems.add(label, False)
            shop = inputs.addDropDownCommandInput('stratShop', 'T-slot shop cutters', adsk.core.DropDownStyles.CheckBoxDropDownStyle)
            global strategy_shop_tools
            strategy_shop_tools = {}
            try:
                res = _http_json('/api/shop_tools', timeout=4.0, log_errors=False)
                for t in (res.get('tools') or []) if isinstance(res, dict) else []:
                    label = f"{t.get('name') or t.get('id')}" + (" (planned)" if t.get('planned') else "")
                    strategy_shop_tools[label] = t.get('id')
                    shop.listItems.add(label, False)
            except Exception as ex:
                _log("Shop tool list unavailable (older server?)", ex)
                shop.listItems.add('(shop tool list unavailable)', False)
            box = inputs.addTextBoxCommandInput(
                'stratInfo', '', 'Tick two or more candidate tools. For a cut-out the planner compares a contour slot, '
                'smaller-tool slots and adaptive, on cycle time and tool wear, and gives Fusion settings (tabs, stepdown, '
                'optimal load, ramp). Tick shop cutters to compare T-slot cutters.', 4, True)
            box.isFullWidth = True
        except Exception as e:
            _report_error("Strategy Planner failed to open.", e)


strategy_ops_map = {}
strategy_candidates = {}
strategy_shop_tools = {}


def _document_tool_candidates():
    """[(label, Fusion tool dict)] for milling tools in the document tool library."""
    out = []
    cam = _active_cam()
    lib = getattr(cam, 'documentToolLibrary', None) if cam else None
    for i in range(getattr(lib, 'count', 0) or 0):
        try:
            t = json.loads(lib.item(i).toJson())
        except Exception:
            continue
        if str(t.get('type', '')).lower() in ('holder', 'probe'):
            continue
        g = t.get('geometry') or {}
        num_ = (t.get('post-process') or t.get('postProcess') or {}).get('number')
        out.append((f"{tool_label(num_)}: {t.get('description', '')} ({g.get('DC', '?')} {t.get('unit', '')})"[:90], t))
    return out


class ToolWizStrategyExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            inputs = adsk.core.CommandEventArgs.cast(args).command.commandInputs
            if not materials_ready():
                ui.messageBox(_materials.get("notice") or "Material list unavailable.", "ToolWiz Strategy Planner")
                return
            doc_u = get_cam_document_units()

            def length(iid, required=False):
                txt = (inputs.itemById(iid).value or '').strip()
                if not txt:
                    if required:
                        raise ValueError(f"Please fill in: {inputs.itemById(iid).name}.")
                    return None
                return parse_length_expr_to_inches(txt, doc_u)
            kind = dict(FEATURE_TYPES).get(_selected_name(inputs.itemById('stratFeature')), 'profile_cutout')
            family, alloy = _family_alloy(inputs, 'strat')
            agg = _int_slider(inputs, 'stratAggressiveness')
            try:
                runout = twlogic.parse_runout_text(inputs.itemById('stratRunout').value, None)
                tabs_n = int(inputs.itemById('stratTabs').value)
                if kind == "tslot":
                    feature = twlogic.strategy_feature_from_inputs(
                        kind, None, length('stratLength', True), slot_height_in=length('stratSlotHeight', True),
                        radial_depth_in=length('stratRadial', True))
                else:
                    tabs = {"count": tabs_n, "width": length('stratTabWidth'), "height": length('stratTabHeight')} if tabs_n else None
                    feature = twlogic.strategy_feature_from_inputs(
                        kind, length('stratDepth', True), length('stratLength', True),
                        width_in=length('stratWidth', kind == "slot"), tabs=tabs)
            except (ValueError, ArithmeticError) as ve:
                ui.messageBox(str(ve), 'ToolWiz Strategy Planner')
                return
            cands = []
            if kind == "tslot":
                for label, tid in strategy_shop_tools.items():
                    if any(i.name == label and i.isSelected for i in inputs.itemById('stratShop').listItems):
                        cands.append({"id": tid})
            else:
                for item in inputs.itemById('stratCandidates').listItems:
                    if item.isSelected and item.name in strategy_candidates:
                        c = twlogic.tool_candidate_from_fusion(strategy_candidates[item.name])
                        if c:
                            cands.append(c)
            if not cands:
                ui.messageBox("Tick at least one candidate tool (document tools for a cut-out / slot, shop cutters for a T-slot).",
                              'ToolWiz Strategy Planner')
                return
            body = {"family": family, "alloy": alloy, "aggressiveness": agg / 100.0, "feature": feature,
                    "candidate_tools": cands}
            if runout is not None:
                body["runout"] = runout
            model = load_model_setting()
            if model:
                body["model"] = model
            save_prefs(family=family, alloy=alloy, aggressiveness=agg)
            run_async(lambda: _http_json('/api/strategy/compare', body, timeout=180.0),
                      lambda res, err: _strategy_done(res, err, doc_u))
        except Exception as e:
            _report_error("Strategy Planner failed.", e)


def _strategy_done(res, err, doc_u):
    if err is not None:
        _server_error_box("compare strategies", err)
        return
    if not isinstance(res, dict) or not res.get("success"):
        ui.messageBox(f"The planner could not compare these tools:\n{(res or {}).get('error')}", "ToolWiz Strategy Planner")
        return
    show_text_result("ToolWiz Strategy Planner", twlogic.format_strategy_result(res, doc_u))


# ==============================================================================
# COMMAND 10: MASTER LIBRARY BUILDER
# ==============================================================================

MASTER_TOOL_TYPES = ["flat end mill", "bull nose end mill", "ball end mill", "slot mill", "chamfer mill", "face mill",
                     "drill", "reamer", "tap right hand", "spot drill", "thread mill", "boring bar"]
MASTER_STRATEGIES = ["Adaptive Roughing", "Roughing", "Finishing", "Slotting"]
ML_POLL_SECONDS = 1.5
ML_MAX_POLL_ERRORS = 5
_ml_sets = {}        # label -> set id
_ml_materials = {}   # label -> material id


def _scan_hub_with_progress(scan_names, title="ToolWiz hub scan"):
    """Ask, then scan the named hub projects with a cancellable progress dialog. Returns (entries, note)."""
    if ui.messageBox(
            f"Scan {len(scan_names)} hub project(s)?\n\nEvery Fusion design in them is opened read-only (not visible), "
            "its tool library is read, and it is closed without saving. This can take minutes for large projects; "
            "you can cancel.", title, adsk.core.MessageBoxButtonTypes.YesNoButtonType,
            adsk.core.MessageBoxIconTypes.QuestionIconType) != adsk.core.DialogResults.DialogYes:
        return [], ""
    prog = ui.createProgressDialog()
    prog.isCancelButtonShown = True
    prog.show(title, "Scanning %v of %m designs", 0, 100, 0)

    def _progress(done, total, label):
        prog.maximumValue = max(1, total)
        prog.progressValue = min(done, max(1, total))
        prog.message = f"%v of %m: {label[-60:]}"
        try:
            adsk.doEvents()          # let Fusion repaint and deliver the Cancel click
        except Exception:
            pass
        return not prog.wasCancelled
    try:
        scanned, rep = scan_hub_projects(scan_names, _progress)
    finally:
        prog.hide()
    note = (f"\nHub scan: {rep['opened']} design(s) read, {len(rep['skipped'])} skipped"
            + (" (cancelled)" if rep['cancelled'] else "") + ".")
    for lab, why in rep["skipped"][:8]:
        note += f"\n   skipped {lab}: {why}"
    return scanned, note


class ToolWizMasterLibraryCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            cmd, inputs = _new_command(args, ToolWizMasterLibraryExecuteHandler, with_input_changed=False, ok_text='Build libraries')
            global discovered_libraries_map
            discovered_libraries_map.clear()
            discovered_libraries_map.update(discover_libraries())
            src = inputs.addDropDownCommandInput('mlSources', 'Sources (tools are merged and de-duplicated)', adsk.core.DropDownStyles.CheckBoxDropDownStyle)
            for name in discovered_libraries_map:
                src.listItems.add(name, True)
            projects = hub_project_names()
            if projects:
                grp = inputs.addGroupCommandInput('hubScanGroup', 'Hub project scan (optional, slow)')
                grp.isExpanded = False
                grp.children.addBoolValueInput('scanHubProjects', 'Also scan the documents of the chosen hub projects', True, '', False)
                dd = grp.children.addDropDownCommandInput('hubProjects', 'Hub projects', adsk.core.DropDownStyles.CheckBoxDropDownStyle)
                for p in projects:
                    dd.listItems.add(p, False)
            doc_u = get_cam_document_units()
            types = inputs.addDropDownCommandInput('mlTypes', 'Tool types (none ticked = all)', adsk.core.DropDownStyles.CheckBoxDropDownStyle)
            for t in MASTER_TOOL_TYPES:
                types.listItems.add(t, False)
            inputs.addStringValueInput('mlDiaMin', f'Smallest diameter (blank = no limit; {doc_u})', '')
            inputs.addStringValueInput('mlDiaMax', f'Largest diameter (blank = no limit; {doc_u})', '')
            # Material sets from the server (editable on the web page).
            _ml_sets.clear()
            _ml_materials.clear()
            sets_dd = inputs.addDropDownCommandInput('mlSets', 'Material sets (one library each)', adsk.core.DropDownStyles.CheckBoxDropDownStyle)
            mat_dd = inputs.addDropDownCommandInput('mlMaterials', 'Materials (none ticked = every material of the sets)', adsk.core.DropDownStyles.CheckBoxDropDownStyle)
            try:
                res = _http_json('/api/twin/material_sets', timeout=6.0)
                for s in ((res or {}).get('material_sets') or {}).get('sets') or []:
                    label = s.get('name') or s.get('id')
                    _ml_sets[label] = s.get('id')
                    sets_dd.listItems.add(label, True)
                    for m in s.get('materials') or []:
                        ml = f"{label.replace('ToolWiz - ', '')}: {m.get('label') or m.get('id')}"
                        _ml_materials[ml] = m.get('id')
                        mat_dd.listItems.add(ml, False)
            except Exception as ex:
                _log("Material sets unavailable", ex)
                ui.messageBox(_offline_message("list the material sets"), "Tool Wizard Server Offline")
            strat = inputs.addDropDownCommandInput('mlStrategies', 'Strategies', adsk.core.DropDownStyles.CheckBoxDropDownStyle)
            for st in MASTER_STRATEGIES:
                strat.listItems.add(st, True)
            prefs = load_prefs()
            agg = inputs.addIntegerSliderCommandInput('mlAggressiveness', 'Aggressiveness', 0, 100)
            agg.valueOne = prefs.get('aggressiveness', 50)
            inputs.addStringValueInput('mlRunout', 'Runout / TIR (blank = each tool\'s own, else 0.0002 in)', '')
            loc = inputs.addDropDownCommandInput('mlLocation', 'Import the libraries into', adsk.core.DropDownStyles.TextListDropDownStyle)
            loc.listItems.add('Local libraries', True)
            loc.listItems.add('Cloud libraries', False)
            box = inputs.addTextBoxCommandInput(
                'mlInfo', '',
                f'Builds one library per material set ("ToolWiz - <set>") with ToolWiz presets for every selected '
                f'material and strategy, audited (no STOP). Model: {model_label(load_model_setting())}. Rebuilding updates '
                f'the library of the same name in place and replaces only presets ToolWiz wrote earlier. The build runs on '
                f'the server; Fusion stays usable and shows progress.', 5, True)
            box.isFullWidth = True
        except Exception as e:
            _report_error("Master Library Builder failed to open.", e)


def _checked(inputs, input_id):
    dd = inputs.itemById(input_id)
    return [i.name for i in dd.listItems if i.isSelected] if dd is not None else []


class ToolWizMasterLibraryExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            inputs = adsk.core.CommandEventArgs.cast(args).command.commandInputs
            doc_u = get_cam_document_units()
            selected = _checked(inputs, 'mlSources')
            scan_in = inputs.itemById('scanHubProjects')
            scan_names = _checked(inputs, 'hubProjects') if (scan_in and scan_in.value) else []
            if not selected and not scan_names:
                ui.messageBox('Please tick at least one source.', 'ToolWiz Master Library Builder')
                return
            try:
                runout = twlogic.parse_runout_text(inputs.itemById('mlRunout').value, None)
                tf = {}
                types = _checked(inputs, 'mlTypes')
                if types:
                    tf["types"] = types
                for iid, key in (('mlDiaMin', 'diameter_min'), ('mlDiaMax', 'diameter_max')):
                    txt = (inputs.itemById(iid).value or '').strip()
                    if txt:
                        tf[key] = parse_length_expr_to_inches(txt, doc_u) * (25.4 if twlogic.is_metric(doc_u) else 1.0)
                if "diameter_min" in tf or "diameter_max" in tf:
                    tf["diameter_unit"] = "mm" if twlogic.is_metric(doc_u) else "in"
            except (ValueError, ArithmeticError) as ve:
                ui.messageBox(str(ve), 'ToolWiz Master Library Builder')
                return
            libs = harvest_selected(selected, discovered_libraries_map)
            note = ""
            if scan_names:
                scanned, note = _scan_hub_with_progress(scan_names)
                libs += scanned
            if not libs:
                ui.messageBox("No tools found in the selected sources." + note, 'ToolWiz Master Library Builder')
                return
            sets = [_ml_sets[n] for n in _checked(inputs, 'mlSets') if n in _ml_sets]
            mats = [_ml_materials[n] for n in _checked(inputs, 'mlMaterials') if n in _ml_materials]
            strategies = _checked(inputs, 'mlStrategies')
            agg = _int_slider(inputs, 'mlAggressiveness')
            location = "cloud" if _selected_name(inputs.itemById('mlLocation')).lower().startswith("cloud") else "local"
            save_prefs(aggressiveness=agg)
            body = twlogic.build_sets_request(libs, sets, mats, strategies, agg, model=load_model_setting(),
                                              runout=runout, tool_filter=tf)
            audit({'event': 'master_library_start', 'libraries': len(libs), 'tools': sum(len(l['tools']) for l in libs),
                   'sets': sets, 'materials': mats, 'location': location})
            prog = None
            try:
                prog = ui.createProgressDialog()
                prog.isCancelButtonShown = True
                prog.show("ToolWiz master library", "Starting the build on the server...", 0, 100, 0)
            except Exception as ex:
                _log("Progress dialog unavailable", ex)
            run_async(lambda: _http_json('/api/twin/build_sets', body, timeout=120.0),
                      lambda res, err: _ml_started(res, err, location, prog, note))
        except Exception as e:
            _report_error("Master Library Builder failed.", e)


def _ml_hide(prog):
    try:
        if prog is not None:
            prog.hide()
    except Exception:
        pass


def _ml_started(res, err, location, prog, note):
    if err is not None:
        _ml_hide(prog)
        _server_error_box("start the master library build", err)
        return
    job = (res or {}).get("job_id") if isinstance(res, dict) else None
    if not job:
        _ml_hide(prog)
        ui.messageBox(f"The server did not start the build:\n{(res or {}).get('error') or res}", "ToolWiz Master Library Builder")
        return
    _ml_poll(job, location, prog, note, 0)


def _ml_poll(job, location, prog, note, errors):
    def work():
        time.sleep(ML_POLL_SECONDS)
        return _http_json(f"/api/twin/build_sets/{job}", timeout=20.0, log_errors=False)
    run_async(work, lambda res, err: _ml_polled(job, location, prog, note, errors, res, err))


def _ml_polled(job, location, prog, note, errors, res, err):
    try:
        if prog is not None and getattr(prog, 'wasCancelled', False) is True:
            _ml_hide(prog)
            ui.messageBox(f"Stopped waiting for the build. It keeps running on the server (job {job}); "
                          "run the command again to import it when it is done is not supported - rebuild instead.",
                          "ToolWiz Master Library Builder")
            return
        if err is not None or not isinstance(res, dict):
            if errors + 1 >= ML_MAX_POLL_ERRORS:
                _ml_hide(prog)
                _server_error_box("read the build progress", err or ValueError("bad response"))
                return
            _ml_poll(job, location, prog, note, errors + 1)
            return
        state = res.get("state")
        if state == "error" or res.get("success") is False:
            _ml_hide(prog)
            ui.messageBox(f"The build failed:\n{res.get('error')}", "ToolWiz Master Library Builder")
            return
        if state != "done":
            pct, text = twlogic.format_build_progress(res)
            if prog is not None:
                try:
                    prog.progressValue = int(pct)
                    prog.message = text
                except Exception:
                    pass
            _ml_poll(job, location, prog, note, 0)
            return
        result = res.get("result") or {}
        libs = result.get("libraries") or []
        if prog is not None:
            try:
                prog.message = "Downloading the libraries..."
            except Exception:
                pass

        def fetch():
            out = {}
            for lib in libs:
                url = lib.get("download_url")
                if url:
                    out[lib.get("name")] = _http_json(url, timeout=180.0)
            return out
        run_async(fetch, lambda d, e: _ml_import(result, d, e, location, prog, note))
    except Exception as ex:
        _ml_hide(prog)
        _report_error("Master library progress failed.", ex)


def _ml_import(result, downloads, err, location, prog, note):
    _ml_hide(prog)
    if err is not None:
        _server_error_box("download the built libraries", err)
        return
    lines = []
    ac = AuditedCommand('master_library_import', target=f"{len(downloads)} ToolWiz librar(ies) in {location}", detect=False).begin()
    for name, data in (downloads or {}).items():
        tools = (data or {}).get("data") if isinstance(data, dict) else None
        if not tools:
            lines.append(f"{name}: download had no tools ({(data or {}).get('error') if isinstance(data, dict) else data})")
            continue
        status, detail = import_library_by_name(name, tools, location)
        lines.append({"updated": f"{name}: updated in place ({len(tools)} tools)",
                      "created": f"{name}: created ({len(tools)} tools)",
                      "file": f"{name}: written to {detail} (Fusion API unavailable: import it from the Tool Library)",
                      "failed": f"{name}: FAILED - {detail}"}[status])
    ac.finish(f"{len(lines)} librar(ies) processed")
    show_text_result("ToolWiz Master Library Builder",
                     "\n".join(lines) + "\n\n" + twlogic.format_build_result(result) + note)


# ==============================================================================
# COMMAND 11: LIBRARY AUDIT
# ==============================================================================

class ToolWizLibraryAuditCreatedHandler(adsk.core.CommandCreatedEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            cmd, inputs = _new_command(args, ToolWizLibraryAuditExecuteHandler, ok_text='Audit')
            global discovered_libraries_map
            discovered_libraries_map.clear()
            discovered_libraries_map.update(discover_libraries())
            if not discovered_libraries_map:
                ui.messageBox('No tool libraries were found.', 'ToolWiz Library Audit')
                return
            active = _doc_name()
            dd = inputs.addDropDownCommandInput('auSource', 'Library', adsk.core.DropDownStyles.TextListDropDownStyle)
            names = list(discovered_libraries_map)
            pre = next((n for n in names if n == f"Open document: {active}"), names[0])
            for n in names:
                dd.listItems.add(n, n == pre)
            prefs = load_prefs()
            if not _add_material_inputs(inputs, 'au', prefs, optional=True):
                return
            agg = inputs.addIntegerSliderCommandInput('auAggressiveness', 'Aggressiveness', 0, 100)
            agg.valueOne = prefs.get('aggressiveness', 50)
            inputs.addStringValueInput('auRunout', 'Runout / TIR (blank = default 0.0002 in)', '')
            box = inputs.addTextBoxCommandInput(
                'auInfo', '', 'Checks every tool and preset against ToolWiz (chip load, speeds, stepdown, holder, '
                f'stickout, duplicate presets). Model: {model_label(load_model_setting())}. Nothing is changed.', 3, True)
            box.isFullWidth = True
        except Exception as e:
            _report_error("Library Audit failed to open.", e)


class ToolWizLibraryAuditExecuteHandler(adsk.core.CommandEventHandler):
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            inputs = adsk.core.CommandEventArgs.cast(args).command.commandInputs
            name = _selected_name(inputs.itemById('auSource'))
            entries = harvest_selected([name], discovered_libraries_map)
            if not entries:
                ui.messageBox(f"{name} holds no tools.", 'ToolWiz Library Audit')
                return
            tools = entries[0]["tools"]
            family, _ = _family_alloy(inputs, 'au')
            agg = _int_slider(inputs, 'auAggressiveness')
            try:
                runout = twlogic.parse_runout_text(inputs.itemById('auRunout').value, None)
            except ValueError as ve:
                ui.messageBox(str(ve), 'ToolWiz Library Audit')
                return
            body = {"library": {"tools": tools}, "aggressiveness": agg}
            if family:
                body["material"] = family
            if runout is not None:
                body["runout"] = runout
            model = load_model_setting()
            if model:
                body["model"] = model
            is_doc = discovered_libraries_map[name]["type"] == "document"
            run_async(lambda: _http_json('/api/twin/audit', body, timeout=300.0),
                      lambda res, err: _audit_done(res, err, name, tools, is_doc))
        except Exception as e:
            _report_error("Library Audit failed.", e)


def _audit_done(res, err, name, tools, is_doc):
    if err is not None:
        _server_error_box("audit the library", err)
        return
    if not isinstance(res, dict) or not res.get("success"):
        ui.messageBox(f"The audit failed:\n{(res or {}).get('error')}", "ToolWiz Library Audit")
        return
    text, jumps = twlogic.format_audit_report(res)
    jump_guids = []
    for label, idx in jumps:
        g = twlogic.tool_guid(tools[idx]) if 0 <= idx < len(tools) else None
        if g:
            jump_guids.append((label, g))
    head = f"Audit of {name}\n" + ("" if is_doc else "(jump-to-tool selects operations in this document that use the same tool guid)\n")
    show_text_result("ToolWiz Library Audit", head + text, jump_guids)


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
    (logCutCommandId, 'Log Cut Result',
     'Record the measured wall error, spindle load and chatter of a real cut so ToolWiz can calibrate its predictions.',
     'ToolWizLogCutCreatedHandler'),
    (cleanupCommandId, 'Clean Up Duplicate Tools',
     'Remove unused duplicate tools from the document tool library (tools used by operations are never removed).',
     'ToolWizCleanupCreatedHandler'),
    (snapshotCommandId, 'Document Snapshot / Compare',
     'Save a snapshot of every operation in this document and compare later to see exactly what changed.',
     'ToolWizSnapshotCreatedHandler'),
    (advisorCommandId, 'ToolWiz Setup Advisor',
     'Review the whole setup (strategy, tool, holder, feeds, stock, heights) and apply the recommended parameter changes.',
     'ToolWizSetupAdvisorCreatedHandler'),
    (strategyCommandId, 'ToolWiz Strategy Planner',
     'Compare contour slot, small-tool slot and adaptive (tab milling) or T-slot cutters on cycle time and tool wear.',
     'ToolWizStrategyCreatedHandler'),
    (masterLibCommandId, 'ToolWiz Master Library Builder',
     'Merge every tool library, build one ToolWiz library per material set with audited presets and import it into Fusion.',
     'ToolWizMasterLibraryCreatedHandler'),
    (libAuditCommandId, 'ToolWiz Library Audit',
     'Audit a tool library against ToolWiz: STOP / CAUTION / info per tool and preset.',
     'ToolWizLibraryAuditCreatedHandler'),
]

# Result dialogs are opened by the add-in itself (never placed on the panel).
HIDDEN_COMMAND_SPECS = [
    (advisorResultCommandId, 'ToolWiz Setup Advisor Results', 'Setup Advisor findings and recommendations.',
     'ToolWizSetupAdvisorResultCreatedHandler'),
    (textResultCommandId, 'ToolWiz Results', 'ToolWiz result text.', 'ToolWizTextResultCreatedHandler'),
]


# ==============================================================================
# TWO-WAY CUSTOMEVENT BRIDGE (Main-Thread Safe Execution for MCP & AI Co-Pilot)
# ==============================================================================

BRIDGE_CUSTOM_EVENT_ID = 'ToolWizMCPBridgeEvent'
_bridge_custom_event = None
_bridge_handlers = []


def _iter_all_cam_operations():
    """Yield (setup_name, op_path, op) for every CAM operation in the active document."""
    try:
        doc = app.activeDocument if app else None
        cam = adsk.cam.CAM.cast(doc.products.itemByProductType('CAMProductType')) if doc else None
        setups = getattr(cam, 'setups', None) if cam else None
        if not setups:
            return
        for s_idx in range(setups.count):
            setup = setups.item(s_idx)
            s_name = getattr(setup, 'name', f'Setup {s_idx + 1}')
            all_ops = getattr(setup, 'allOperations', None)
            if not all_ops:
                continue
            for o_idx in range(all_ops.count):
                op = all_ops.item(o_idx)
                o_name = getattr(op, 'name', f'Op {o_idx + 1}')
                yield s_name, f"{s_name} > {o_name}", op
    except Exception as ex:
        _log("Iterating CAM operations for bridge failed", ex)


def _find_cam_operation(query):
    """Find a CAM operation by name, 'Setup > Op' path, or 0-based index."""
    q_str = str(query or "").strip()
    ops = list(_iter_all_cam_operations())
    if not ops:
        return None, None, None
    if not q_str:
        return ops[0]
    for s_name, path, op in ops:
        if getattr(op, 'name', '') == q_str or path == q_str:
            return s_name, path, op
    q_low = q_str.lower()
    for s_name, path, op in ops:
        if q_low in getattr(op, 'name', '').lower() or q_low in path.lower():
            return s_name, path, op
    try:
        idx = int(q_str)
        if 0 <= idx < len(ops):
            return ops[idx]
    except (TypeError, ValueError):
        pass
    return None, None, None


def dispatch_bridge_action(action, params=None):
    """Execute a structured bridge action on Fusion's main UI thread and return a JSON-serializable dict."""
    params = dict(params or {})
    if action == "get_setup_summary":
        # Rich per-op snapshot (op_id, tool JSON, holder, coating, params incl. stock to leave, rest machining,
        # geometry) in the field names of docs/SETUP_ADVISOR.md; also pushed to /api/fusion_bridge/state.
        snap = build_setup_snapshot()
        lib = getattr(_active_cam(), 'documentToolLibrary', None)
        push_live_state(snap)
        return {
            "success": True,
            "document": snap.get("document"),
            "tool_count": getattr(lib, 'count', None),
            "setups": snap.get("setups"),
            "ops": snap.get("ops"),
        }

    if action == "inspect_operation":
        s_name, path, op = _find_cam_operation(params.get("operation"))
        if op is None:
            return {"success": False, "error": f"Operation {params.get('operation')!r} not found in active document."}
        geo_payload, summary_str, presets = get_op_tool_info(op)
        rpm, feed, doc, woc = get_op_cut_params(op, "in")
        dia = (geo_payload or {}).get("diameter")
        stick = (geo_payload or {}).get("stickout")
        fg = inspect_operation_geometry(op, tool_diameter_in=dia, stickout_in=stick, nominal_woc_in=woc).to_dict()
        return {
            "success": True,
            "setup": s_name,
            "path": path,
            "name": getattr(op, 'name', ''),
            "strategy": getattr(op, 'strategy', ''),
            "tool": geo_payload,
            "tool_summary": summary_str,
            "presets": presets,
            "cut_params": {"rpm": rpm, "feed_ipm": feed, "doc_in": doc, "woc_in": woc},
            "feature_geometry": fg,
        }

    if action == "audit_setup_sequence":
        target_setup = str(params.get("setup") or "").strip().lower()
        issues = []
        audited_ops = []
        prev_rough_dia = None
        prev_rough_rad_stock = None

        for s_name, path, op in _iter_all_cam_operations():
            if target_setup and target_setup not in s_name.lower():
                continue
            geo_payload, _, _ = get_op_tool_info(op)
            rpm, feed, doc, woc = get_op_cut_params(op, "in")
            dia = (geo_payload or {}).get("diameter") or 0.0
            stick = (geo_payload or {}).get("stickout") or 0.0
            strat = str(getattr(op, 'strategy', '') or '').lower()
            op_name = str(getattr(op, 'name', '') or '')

            fg = inspect_operation_geometry(
                op, tool_diameter_in=dia if dia > 0 else None,
                stickout_in=stick if stick > 0 else None,
                nominal_woc_in=woc if woc > 0 else None,
            ).to_dict()

            # Read radial stock-to-leave if present
            rad_stock_in = None
            p_rad = _param(getattr(op, 'parameters', None), 'stockToLeave') or _param(getattr(op, 'parameters', None), 'radialStockToLeave')
            if p_rad is not None:
                rad_stock_in = parse_cam_param_to_inches(p_rad, 0.0, "in")

            is_rough = any(k in strat or k in op_name.lower() for k in ("adaptive", "rough", "pocket", "clearing"))
            is_finish = any(k in strat or k in op_name.lower() for k in ("contour", "finish", "scallop", "parallel", "flat", "horizontal"))

            # Sequence check 1: micro-tool following a >=2.5x larger rougher without intermediate rest tool
            if dia > 0 and dia <= 0.125 and prev_rough_dia is not None and prev_rough_dia >= dia * 2.5:
                issues.append({
                    "operation": path,
                    "severity": "warning",
                    "kind": "micro_rest_machining_gap",
                    "message": (
                        f"Micro-tool ({dia:.4f}\" dia) follows a {prev_rough_dia:.4f}\" roughing tool "
                        f"({prev_rough_dia / dia:.1f}x diameter step). Ensure rest-machining is enabled "
                        f"or add an intermediate semi-finishing tool to prevent full-slot shock in corners."
                    ),
                })

            # Sequence check 2: finishing pass entering zero or negative roughing stock
            if is_finish and prev_rough_rad_stock is not None and prev_rough_rad_stock <= 0.0005:
                issues.append({
                    "operation": path,
                    "severity": "warning",
                    "kind": "insufficient_roughing_stock_for_finish",
                    "message": (
                        f"Preceding roughing operation left {prev_rough_rad_stock:.4f}\" radial stock. "
                        f"Leave at least +0.005\" (0.125 mm) uniform stock for the finishing pass."
                    ),
                })

            # Include B-Rep warnings from inspect_operation_geometry
            for w in fg.get("warnings") or []:
                issues.append({
                    "operation": path,
                    "severity": w.get("type", "warning"),
                    "kind": "brep_geometry",
                    "title": w.get("title"),
                    "message": w.get("message"),
                })

            if is_rough and dia > 0:
                prev_rough_dia = dia
                if rad_stock_in is not None:
                    prev_rough_rad_stock = rad_stock_in

            audited_ops.append({
                "path": path,
                "name": op_name,
                "strategy": strat,
                "diameter_in": dia,
                "stickout_in": stick,
                "rpm": rpm,
                "feed_ipm": feed,
                "doc_in": doc,
                "woc_in": woc,
                "radial_stock_in": rad_stock_in,
                "feature_geometry": fg,
            })

        return {
            "success": True,
            "operations_audited": len(audited_ops),
            "issues": issues,
            "operations": audited_ops,
        }

    if action == "get_toolpath_status":
        q = str(params.get("operation") or "").strip().lower()
        statuses = []
        for s_name, path, op in _iter_all_cam_operations():
            if q and q not in path.lower() and q not in str(getattr(op, 'name', '')).lower():
                continue
            statuses.append({
                "setup": s_name,
                "path": path,
                "name": getattr(op, 'name', ''),
                "strategy": getattr(op, 'strategy', ''),
                "hasToolpath": bool(getattr(op, 'hasToolpath', False)),
                "isToolpathValid": bool(getattr(op, 'isToolpathValid', False)),
                "hasWarning": bool(getattr(op, 'hasWarning', False)),
                "hasError": bool(getattr(op, 'hasError', False)),
                "isSuppressed": bool(getattr(op, 'isSuppressed', False)),
            })
        return {"success": True, "operations": statuses}

    if action == "apply_stock_to_leave":
        target_q = params.get("operation")
        rad_val = str(params.get("radial_stock") or "0.0000 in").strip()
        ax_val = str(params.get("axial_stock") or "0.0000 in").strip()
        s_name, path, op = _find_cam_operation(target_q)
        if op is None:
            return {"success": False, "error": f"Operation {target_q!r} not found."}
        ac = AuditedCommand('mcp_stock_to_leave', target=path, targets=[path]).begin()
        try:
            failed = apply_stock_to_op(op, rad_val, ax_val)
            note = ac.finish("ok" if not failed else f"failed: {failed}")
            return {
                "success": len(failed) == 0,
                "operation": path,
                "radial_stock": rad_val,
                "axial_stock": ax_val,
                "failed_params": failed,
                "audit_note": note,
            }
        except Exception as ex:
            ac.finish(f"error: {ex}")
            return {"success": False, "error": str(ex)}

    if action == "apply_operation_parameters":
        # params: {op_id, params: {<Fusion parameter name>: <expression>}, reason}
        return apply_operation_parameters(params.get("op_id") or params.get("operation"),
                                          params.get("params"), params.get("reason") or "",
                                          advisor_generated_at=params.get("advisor_generated_at"))

    if action == "update_tool_fields":
        # params: {tool_number | tool_guid, fields: {coating, BMC, GRADE, comment, description, add_keywords, remove_keywords}, reason}
        return update_tool_fields(params.get("tool_number"), params.get("tool_guid"), params.get("fields"), params.get("reason") or "")

    if action == "get_viewport_image":
        return get_viewport_image(params.get("width", 1280), params.get("height", 800))

    if action == "curate_setup_tools":
        doc = getattr(app, 'activeDocument', None)
        cam_prod = doc.products.itemByProductType('CAMProductType') if doc and getattr(doc, 'products', None) else None
        cam = adsk.cam.CAM.cast(cam_prod) if cam_prod else None
        if not cam:
            return {"success": False, "error": "No active CAM workspace"}
        target_setup_name = str(params.get("setup") or "").strip()
        apply_changes = bool(params.get("apply", False))
        raw_tools = []
        op_refs = []
        seen_sigs = set()
        for s_idx in range(cam.setups.count):
            setup = cam.setups.item(s_idx)
            s_name = getattr(setup, "name", f"Setup {s_idx + 1}")
            if target_setup_name and s_name.lower() != target_setup_name.lower():
                continue
            ops = getattr(setup, "allOperations", None)
            if not ops:
                continue
            for o_idx in range(ops.count):
                op = ops.item(o_idx)
                t = getattr(op, "tool", None)
                if t is not None and hasattr(t, "toJson"):
                    try:
                        td = json.loads(t.toJson())
                        sig = td.get("guid") or td.get("description") or str(o_idx)
                        if sig not in seen_sigs:
                            seen_sigs.add(sig)
                            raw_tools.append(td)
                        op_refs.append((op, td))
                    except Exception:
                        pass
        curation = _http_json('/api/library/curate', {
            "tools": raw_tools,
            "fix_micro_shank": bool(params.get("fix_micro_shank", True)),
            "populate_shaft_taper": bool(params.get("populate_shaft_taper", True)),
            "infer_metadata_from_description": bool(params.get("infer_metadata_from_description", True)),
        }, timeout=10.0)
        applied_ops = 0
        if apply_changes and curation.get("success") and hasattr(adsk.cam.Tool, "createFromJson"):
            by_desc = {r.get("description"): r.get("curated_tool") for r in (curation.get("results") or []) if r.get("modified")}
            for op, orig_td in op_refs:
                d_key = str(orig_td.get("description") or orig_td.get("product-id") or "Unnamed Tool").strip()
                new_td = by_desc.get(d_key)
                if new_td:
                    try:
                        op.tool = adsk.cam.Tool.createFromJson(json.dumps(new_td))
                        applied_ops += 1
                    except Exception as ex_t:
                        _log("Applying curated tool JSON failed", ex_t)
        curation["applied_operations"] = applied_ops
        return curation

    if action == "snapshot_compare":
        mode = SNAPSHOT_SAVE if str(params.get("mode", "")).lower() == "save" else SNAPSHOT_COMPARE
        text = run_snapshot_action(mode)
        return {"success": True, "mode": mode, "report": text}

    return {"success": False, "error": f"Unknown bridge action {action!r}"}


_CustomEventBase = (
    adsk.core.CustomEventHandler
    if isinstance(getattr(adsk.core, 'CustomEventHandler', None), type)
    else object
)


class ToolWizBridgeCustomEventHandler(_CustomEventBase):
    """Executes queued MCP/bridge requests on Fusion 360's main UI thread."""
    def __init__(self):
        super().__init__()

    def notify(self, args):
        try:
            info = getattr(args, 'additionalInfo', None)
            payload = json.loads(info) if isinstance(info, str) and info else {}
            req_id = payload.get("request_id")
            action = payload.get("action")
            params = payload.get("params") or {}
            res = dispatch_bridge_action(action, params)
            if req_id:
                try:
                    _http_json('/api/fusion_bridge/result', {"request_id": req_id, "result": res}, timeout=5.0)
                except Exception as ex_post:
                    _log("Posting bridge CustomEvent result failed", ex_post)
        except Exception as ex:
            _log("Bridge CustomEvent execution failed", ex)


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
    for cid, _, _, _ in HIDDEN_COMMAND_SPECS:
        cmdDef = ui.commandDefinitions.itemById(cid)
        if cmdDef:
            cmdDef.deleteMe()
    global _bridge_custom_event, _async_event
    stop_bridge_poller()
    for ev_id in (BRIDGE_CUSTOM_EVENT_ID, ASYNC_EVENT_ID):
        try:
            if app and hasattr(app, 'unregisterCustomEvent'):
                app.unregisterCustomEvent(ev_id)
        except Exception:
            pass
    _bridge_custom_event = None
    _async_event = None
    _bridge_handlers.clear()
    _async_handlers.clear()
    hidden_handlers.clear()


def _add_button(cid, name, tooltip):
    """addButtonDefinition with this command's icon folder (resources/<command id>/16x16.png, 32x32.png) when
    the folder exists next to this file."""
    res = os.path.join(_ADDIN_DIR, 'resources', cid)
    if os.path.isdir(res):
        try:
            return ui.commandDefinitions.addButtonDefinition(cid, name, tooltip, res)
        except TypeError:
            pass
    return ui.commandDefinitions.addButtonDefinition(cid, name, tooltip)


def _running_under_mock():
    try:
        return type(adsk.core).__module__.startswith('unittest.mock')
    except Exception:
        return False


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
            cmdDef = _add_button(cid, name, tooltip)
            on_created = globals()[handler_cls]()
            cmdDef.commandCreated.add(on_created)
            handlers.append(on_created)
            if panel:
                panel.controls.addCommand(cmdDef)
        for cid, name, tooltip, handler_cls in HIDDEN_COMMAND_SPECS:
            cmdDef = _add_button(cid, name, tooltip)
            on_created = globals()[handler_cls]()
            cmdDef.commandCreated.add(on_created)
            hidden_handlers.append(on_created)

        global _bridge_custom_event, _async_event
        try:
            if hasattr(app, 'registerCustomEvent'):
                _bridge_custom_event = app.registerCustomEvent(BRIDGE_CUSTOM_EVENT_ID)
                if _bridge_custom_event is not None and hasattr(_bridge_custom_event, 'add'):
                    on_bridge = ToolWizBridgeCustomEventHandler()
                    _bridge_custom_event.add(on_bridge)
                    _bridge_handlers.append(on_bridge)
                _async_event = app.registerCustomEvent(ASYNC_EVENT_ID)
                if _async_event is not None and hasattr(_async_event, 'add'):
                    on_async = ToolWizAsyncCustomEventHandler()
                    _async_event.add(on_async)
                    _async_handlers.append(on_async)
        except Exception as ex_ce:
            _log("Could not register CustomEvent bridge", ex_ce)
        if _bridge_custom_event is not None and not _running_under_mock():
            start_bridge_poller()

    except Exception as e:
        _report_error("Add-in start failed.", e)

def stop(context):
    try:
        _remove_ui()
        handlers.clear()
    except Exception as e:
        _report_error("Add-in stop failed.", e)

