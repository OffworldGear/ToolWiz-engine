"""Deterministic unit conversion. No magnitude heuristics: unknown units raise UnitError."""
import re

_INCH = {"inches", "inch", "in", '"'}
_MM = {"millimeters", "millimeter", "mm"}


class UnitError(ValueError):
    """Raised when a unit cannot be determined."""


def normalize_unit(unit):
    """Return 'inches', 'millimeters', or None if unrecognised."""
    if unit is None:
        return None
    u = str(unit).strip().lower()
    if u in _INCH:
        return "inches"
    if u in _MM:
        return "millimeters"
    return None


_NUM = r"[-+]?(?:\d+\.?\d*|\.\d+)"
_STR_RE = re.compile(
    r"^\s*(?P<num>" + _NUM + r"(?:\s*/\s*" + _NUM + r")?)\s*(?P<u>mm|millimeters?|inches|inch|in|\")?\s*$",
    re.IGNORECASE,
)


def _parse_number(txt):
    if "/" in txt:
        n, d = txt.split("/")
        d = float(d)
        if d == 0:
            raise UnitError("zero denominator in fraction")
        return float(n) / d
    return float(txt)


def to_inches(val, unit=None) -> float:
    """Convert a number or string (optionally with unit suffix) to inches.

    A unit suffix inside a string wins over `unit`. If neither gives a unit,
    UnitError is raised.
    """
    if isinstance(val, bool) or val is None:
        raise UnitError("cannot convert %r" % (val,))
    suffix = None
    if isinstance(val, (int, float)):
        num = float(val)
    elif isinstance(val, str):
        m = _STR_RE.match(val)
        if not m:
            raise UnitError("cannot parse length %r" % (val,))
        num = _parse_number(re.sub(r"\s+", "", m.group("num")))
        suffix = m.group("u")
    else:
        raise UnitError("cannot convert %r" % (val,))
    u = normalize_unit(suffix) if suffix else None
    if u is None:
        u = normalize_unit(unit)
    if u is None:
        raise UnitError("unknown unit %r for value %r" % (unit, val))
    return num / 25.4 if u == "millimeters" else num


def tool_unit(tool: dict) -> str:
    """Return 'inches' or 'millimeters' from tool['unit'] or tool['geometry']['unit']."""
    cands = []
    if isinstance(tool, dict):
        cands.append(tool.get("unit"))
        geo = tool.get("geometry")
        if isinstance(geo, dict):
            cands.append(geo.get("unit"))
    for c in cands:
        u = normalize_unit(c)
        if u:
            return u
    raise UnitError("tool has no recognisable 'unit' (expected inches or millimeters)")
