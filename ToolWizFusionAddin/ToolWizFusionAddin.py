import adsk.core, adsk.cam, adsk.fusion, traceback
import urllib.request, urllib.error, urllib.parse, json
import os, re, sys, math, time, datetime, uuid, collections

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
logCutCommandId = 'ToolWizLogCutCmd'
cleanupCommandId = 'ToolWizCleanupDuplicatesCmd'
snapshotCommandId = 'ToolWizSnapshotCompareCmd'

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
                   'stepover', 'optimalLoad', 'use_tool_stepdown', 'use_tool_stepover')


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
}


def _limited_by_text(limited):
    if isinstance(limited, (list, tuple)):
        limited = ", ".join(LIMIT_LABELS.get(str(x), str(x)) for x in limited if x)
    elif limited:
        limited = LIMIT_LABELS.get(str(limited).strip(), str(limited))
    return str(limited).strip() if limited else ""


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
                           doc=None, woc=None, limited_by=None, provenance=None, preset_note=""):
    """Concise success text for the Speeds & Feeds auto-setter. `doc` / `woc` are None when
    they were not written to the operation."""
    lines = [
        f"{t_label} · {geo.get('diameter', 0.0):.3f}\" {geo.get('flutes', '?')}FL · {material_label} — {strategy}",
        f"{rpm:,.0f} RPM · {feed:.1f} IPM · {ipt:.4f} IPT",
    ]
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
            "neckLength": geo.neck_length,
            "neckDiameter": geo.neck_diameter,
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
            _set_expression(op, p, name, str(expr_str))
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
            auto_dedup = dedup_input.value if dedup_input else False

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
            inputs.addBoolValueCommandInput('autoDeduplicate', 'Deduplicate Identical Cutters (merges same-geometry tools)', True, '', False)
                
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
                
            ac = AuditedCommand('import_digital_twin', target='ToolWiz server library').begin()
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
            
            existed = os.path.exists(staging_file)
            with open(staging_file, "w", encoding="utf-8") as f:
                json.dump({"data": tools_list}, f, indent=2)
            note = ac.finish(f"wrote {len(tools_list)} tools to staging file"
                             + (" (overwrote existing file)" if existed else ""), target=staging_file)
                
            msg = (
                f"Digital Twin Ready for Synchronization!\n"
                f"====================================\n"
                f"Library: {lib_name}\n"
                f"Tools Processed: {len(tools_list)}\n\n"
                f"The updated library has been saved to your Fusion Local Libraries directory:\n"
                f"📂 {staging_file}\n\n"
                f"Your tools now contain all material presets (Roughing, Adaptive, Finishing, Slotting) in their Cutting Data tab!"
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


def fusion_tool_payload(geo_payload):
    """Canonical {"type","unit","geometry"} slice of the op's raw Fusion tool JSON, or None when
    the raw JSON is unavailable/unparseable. The server builds ONE tool profile from it."""
    try:
        raw = (geo_payload or {}).get("raw_json")
        t = json.loads(raw) if isinstance(raw, str) else raw
        if isinstance(t, dict) and isinstance(t.get("geometry"), dict):
            return {"type": t.get("type"), "unit": t.get("unit"), "geometry": t["geometry"]}
    except Exception:
        pass
    return None


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

    grade = selected_grade.lower()
    if "hp" in grade or "high performance" in grade:
        tool_category = "HP Carbide Endmill"  # bull nose / high feed is carried by "geometry"
    elif "hss" in grade:
        tool_category = "HSS Endmill"
    elif "cobalt" in grade:
        tool_category = "Cobalt Endmill"
    else:
        tool_category = "Carbide Endmill"

    ft = fusion_tool_payload(geo_payload)
    return {
        "family": family, "alloy": alloy, "operation": strategy, "aggressiveness": aggressiveness,
        "tool": tool_category, "coating": coating_code,
        **({"fusion_tool": ft} if ft else {}),
        "diameter": geo_payload["diameter"], "flutes": geo_payload["flutes"], "fluteLength": geo_payload["fluteLength"],
        "shankDiameter": geo_payload["shankDiameter"], "cornerRadius": geo_payload["cornerRadius"],
        "stickout": geo_payload["stickout"], "geometry": geo_payload["geometry"],
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
                _set_preset_param(ctx, p_obj, field, f"{doc_in:.4f} in"); written.append(n)
            elif ('stepover' in n or 'optimalload' in n) and woc_in:
                _set_preset_param(ctx, p_obj, field, f"{woc_in:.4f} in"); written.append(n)
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
    for p_name, p_val in speed_values:
        if p_name not in VERIFY_PARAMS:
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
                target_preset_to_replace, selected_grade, selected_coating_raw):
    """Calculate cutting data on the server and write it to the operation's tool preset."""
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

    payload = build_calc_payload(geo_payload, family, alloy, strategy, aggressiveness, selected_grade, selected_coating_raw)
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
    ramp_feed = calc_result.get("ramp_feed", feed * 0.5)
    plunge_feed = calc_result.get("plunge_feed", feed * 0.25)
    if plunge_feed <= 0:
        plunge_feed = ramp_feed if ramp_feed > 0 else (feed * 0.25 if feed > 0 else 5.0)
    if ramp_feed <= 0:
        ramp_feed = feed * 0.5 if feed > 0 else 10.0
    sfm = calc_result.get("sfm", 300)
    ipt = calc_result.get("ipt", 0.002)

    final_preset_name = calc_result["name"]
    speed_values = [
        ('tool_spindleSpeed', f"{rpm} rpm"),
        ('tool_feedCutting', f"{feed:.2f} in/min"),
        ('tool_feedRamp', f"{ramp_feed:.2f} in/min"),
        ('tool_feedPlunge', f"{plunge_feed:.2f} in/min"),
        ('tool_feedTransition', f"{feed * 1.5:.2f} in/min"),
    ]

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
                                                      doc_in=doc, woc_in=woc)
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
    op_rpm, op_feed, _, _ = get_op_cut_params(target_op, "in")
    if preset_linked and not (_close(op_rpm, rpm, 0.01) and _close(op_feed, feed, 0.01)):
        # The preset may already hold the new values (nothing to write back) while the operation
        # still has old ones: ask Fusion to re-apply the tool's presets to its operations.
        if _refresh_operations_from_preset(target_op, final_preset_name):
            op_rpm, op_feed, _, _ = get_op_cut_params(target_op, "in")
    preset_ok = preset_linked and _close(op_rpm, rpm, 0.01) and _close(op_feed, feed, 0.01)
    if not preset_ok:
        _log(f"Preset values not in effect on {op_name!r} (linked={preset_linked}, op rpm={op_rpm:.0f} "
             f"feed={op_feed:.2f} IPM vs calculated {rpm} / {feed:.2f}); writing operation parameters")
        for p_name, p_val in speed_values:
            apply_param(target_op, p_name, p_val, force=(p_name not in ('tool_spindleSpeed', 'tool_feedCutting')))
    _log_speed_sources(target_op)
    _log_custom_diff(target_op)
    tool_updated = preset_obj is not None
    _log_op_motion_params(target_op, "AFTER")
    _log_preset_use_flags(target_op, final_preset_name)
    _regenerate_toolpath(target_op)
    tools_at_end = _doc_tool_count()
    _log(f"Auto-set {op_name!r}: T{t_num}, document tools {tools_at_start} -> {tools_at_end}"
         + ("  (WARNING: a tool was added)" if tools_at_start is not None and tools_at_end != tools_at_start else ""))

    # DOC/WOC: the preset carries them (above). Write the operation's own step parameters only
    # if the linked preset didn't deliver them, because any operation value that differs from
    # its preset makes Fusion show 'Preset (custom)'.
    _, _, op_doc, op_woc = get_op_cut_params(target_op, "in")
    woc_applied = preset_linked and _close(op_woc, woc, 0.01)
    doc_applied = preset_linked and _close(op_doc, doc, 0.01)
    if not woc_applied:
        _log(f"WOC from preset not in effect (op {op_woc:.4f} vs {woc:.4f} in); writing operation parameter")
        if "Adaptive" in strategy:
            woc_applied = bool(apply_param(target_op, 'optimalLoad', f"{woc:.4f} in"))
        else:
            woc_applied = bool(apply_param(target_op, 'stepover', f"{woc:.4f} in")
                               or apply_param(target_op, 'maximumStepover', f"{woc:.4f} in"))
    if not doc_applied:
        _log(f"DOC from preset not in effect (op {op_doc:.4f} vs {doc:.4f} in); writing operation parameter")
        doc_applied = bool(apply_param(target_op, 'maximumStepdown', f"{doc:.4f} in"))

    preset_note = f"Preset: {final_preset_name} ({'replaced' if was_updated else 'added'} on the existing tool)"
    if not preset_ok:
        preset_note = (f"Preset: {final_preset_name} could not be updated in place, so the values were applied "
                       f"to this operation only (Fusion shows it as custom). No tool was created. "
                       f"Details: {_log_path()}")
    msg = format_autoset_message(
        tool_label(t_num), geo_payload, material_label, strategy, rpm, feed, ipt,
        doc=doc if doc_applied else None, woc=woc if woc_applied else None,
        limited_by=calc_result.get("limited_by"), provenance=calc_result.get("provenance"),
        preset_note=preset_note,
    )
    for w in tool_profile_warnings(calc_result):
        msg += "\n\nCheck: " + w
    note = _finish_active_command('ok')
    if note:
        msg += "\n\n" + note
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

            ac = AuditedCommand('autoset', target=op_name, targets=[op_name]).begin()
            result = 'error'
            try:
                done = run_autoset(target_op, op_name, family, alloy, strategy, aggressiveness,
                                   target_preset_to_replace, selected_grade, selected_coating_raw)
                result = 'ok' if done else 'not applied'
            finally:
                ac.finish(result)

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
            op_strat = str(getattr(initial_op, 'strategy', '')).lower() if initial_op else ""
            default_strat = 'Adaptive Roughing'
            strat_names = ['Adaptive Roughing', 'Roughing', 'Finishing', '3D Contouring / Scallop Finishing',
                           'Floor Finishing (Skim)', 'Slotting', 'Facing']
            if not any(k in op_strat for k in ['adaptive', 'face', 'facing', 'flat', 'horizontal', 'scallop',
                                               'parallel', 'morphed', 'ramp', 'flow', 'contour', 'trace', 'pocket']):
                # Nothing recognisable in the operation: fall back to the last strategy used.
                default_strat = pick_saved(prefs.get('strategy'), strat_names, default_strat)
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
            agg_input.valueOne = prefs.get('aggressiveness', 50)

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
        ft = fusion_tool_payload(geo)
        if ft:
            ops_payload[-1]["fusion_tool"] = ft
    return ops_payload


def query_toolwiz_stock_compensation(family, alloy, aggressiveness, mode, custom_rad="0.0000 in", custom_ax="0.0000 in", doc_unit="in",
                                     radial_pct=100, axial_pct=100):
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
                
            # 4. Handle Material / Aggressiveness / Mode changes
            if cmdInput.id in ['stockMatFamily', 'stockMatAlloy', 'stockAggressiveness', 'stockBatchMode', 'customRadOffset', 'customAxOffset',
                               'stockRadialPct', 'stockAxialPct']:
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
                
                calc_results = query_toolwiz_stock_compensation(
                    family, alloy, agg, mode_code, c_rad, c_ax, doc_unit=doc_u,
                    radial_pct=stock_strength_pct(inputs.itemById('stockRadialPct')),
                    axial_pct=stock_strength_pct(inputs.itemById('stockAxialPct')))
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

            init_agg = prefs.get('aggressiveness', 50)
            agg_input = inputs.addIntegerSliderCommandInput('stockAggressiveness', 'Aggressiveness', 0, 100)
            agg_input.valueOne = init_agg

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
                default_family, init_alloy, init_agg, "auto_compensate", doc_unit=doc_unit,
                radial_pct=init_rad_pct, axial_pct=init_ax_pct
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
        "notes": ((notes or "").strip()[:2000] or None),
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
            info = {'index': m['index'], 'number': pp.get('number'),
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
                try:
                    if hasattr(lib, 'remove'):
                        ok = bool(lib.remove(r['index']))
                    else:
                        ok = bool(lib.item(r['index']).deleteMe())
                except Exception as ex:
                    _log(f"Could not remove tool at library index {r['index']}", ex)
                audit({'event': 'tool_removed', 'library_index': r['index'], 'tool_number': r.get('number'),
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

