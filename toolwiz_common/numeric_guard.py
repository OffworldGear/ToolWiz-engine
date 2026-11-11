"""Numeric guard: reject LLM text that contains a number no ToolWiz tool result supports.

Rule (owner requirement): the LLM never produces numbers. Every speed, feed, chip load, rpm, depth, width,
stock or time it prints must come from a ToolWiz result. ``check_numbers(text, grounding)`` extracts every
number from ``text`` (decimals, thousands separators, fractions such as ``1/16`` or ``1 1/2``, with or without
units) and requires each one to match a number present in ``grounding`` (any JSON-able object; numbers in its
string values count too, so material names such as ``6061-T6`` ground their own digits).

Matching (see ``_factors``):
  * tolerance = max(0.5 % of the printed value, half a unit of the last printed digit), i.e. rounding is allowed;
  * unit conversions are applied only for numbers carrying a unit: in <-> mm, in/min <-> mm/min,
    SFM <-> m/min, in/tooth <-> mm/tooth, % <-> a 0..1 ratio, min <-> s;
  * a bare number (no unit) must equal a grounded number (small counts such as "3 operations" therefore need
    the 3 to appear in the grounding);
  * signs are ignored (``-0.0005`` matches ``0.0005``).
Not numbers for this purpose: identifiers glued to letters (``2D``, ``3D``, ``T6``, ``V2``, ``1st``), markdown list
markers at the start of a line, and digits inside URLs.

Pure standard library; lengths are whatever the grounding uses (the guard only compares magnitudes).
"""
from __future__ import annotations

import bisect
import re
from dataclasses import dataclass
from typing import Any, Dict, Iterable, List, Optional, Sequence

MM_PER_IN = 25.4
M_PER_FT = 0.3048

_NUM = r"\d{1,3}(?:,\d{3})+(?:\.\d+)?|\d+(?:\.\d+)?|\.\d+"

# unit text (lower case) -> canonical unit. Longest alternatives first.
_UNITS = {
    "in/min": "ipm", "in./min": "ipm", "ipm": "ipm", "inches/min": "ipm", "inch/min": "ipm",
    "mm/min": "mm/min", "m/min": "m/min", "sfm": "sfm", "smm": "m/min", "rpm": "rpm",
    "ipt": "ipt", "in/tooth": "ipt", "mm/tooth": "mm/tooth", "ipr": "ipt", "in/rev": "ipt", "mm/rev": "mm/tooth",
    "inches": "in", "inch": "in", "in": "in", '"': "in", "”": "in", "mm": "mm", "cm": "cm", "m": "m",
    "%": "%", "x": "x", "×": "x", "hp": "hp", "kw": "kw",
    "minutes": "min", "minute": "min", "min": "min", "mins": "min",
    "seconds": "s", "second": "s", "secs": "s", "sec": "s", "s": "s",
    "°": "deg", "deg": "deg", "degrees": "deg", "degree": "deg",
    "flutes": "count", "flute": "count", "fl": "count", "thou": "thou", "mils": "thou", "mil": "thou",
    "um": "um", "µm": "um", "microns": "um", "micron": "um",
}
_UNIT_RE = "|".join(re.escape(u) for u in sorted(_UNITS, key=len, reverse=True))

_TOKEN = re.compile(
    r"(?:(?<![\w.,/])|(?<=\d[xX\u00d7]))"
    r"(?:(?P<mix>\d+)[ ](?P<mn>\d+)/(?P<md>\d+)(?![\d/])"
    r"|(?P<fn>\d+)/(?P<fd>\d+)(?![\d/])"
    r"|(?P<num>" + _NUM + r"))"
    r"(?P<unit>\s?(?:" + _UNIT_RE + r")(?![A-Za-z]))?",
    re.IGNORECASE)
_NEXT_LETTER = re.compile(r"[A-Za-z]")
_LIST_MARKER = re.compile(r"(?m)^(\s*)(\d{1,2})[.)]\s+")
_URL = re.compile(r"https?://\S+")
_RAW = re.compile(r"\d+\s+\d+/\d+|\d+/\d+|" + _NUM)


@dataclass
class NumberToken:
    """One number found in a text: ``text`` as printed, ``value`` (non-negative), ``decimals`` printed, ``unit``."""
    text: str
    value: float
    decimals: int
    unit: Optional[str]


def _to_float(s: str) -> float:
    return float(s.replace(",", ""))


def _decimals(s: str) -> int:
    s = s.replace(",", "")
    return len(s.split(".", 1)[1]) if "." in s else 0


def extract_numbers(text: str) -> List[NumberToken]:
    """Every checkable number in ``text`` (identifiers like ``2D``/``T6``, list markers and URLs are skipped)."""
    if not text:
        return []
    text = _URL.sub(" ", str(text))
    text = _LIST_MARKER.sub(r"\1", text)
    out: List[NumberToken] = []
    for m in _TOKEN.finditer(text):
        end = m.end()
        unit_raw = m.group("unit")
        if not unit_raw and end < len(text) and _NEXT_LETTER.match(text[end]):
            continue                              # glued identifier: 2D, 3D, 4V, 1st
        if m.group("mix"):
            den = int(m.group("md"))
            if den == 0:
                continue
            val, dec = int(m.group("mix")) + int(m.group("mn")) / den, 6
        elif m.group("fn"):
            den = int(m.group("fd"))
            if den == 0:
                continue
            val, dec = int(m.group("fn")) / den, 6
        else:
            val, dec = _to_float(m.group("num")), _decimals(m.group("num"))
        unit = _UNITS.get(unit_raw.strip().lower()) if unit_raw else None
        out.append(NumberToken(m.group(0).strip(), val, dec, unit))
    return out


def raw_numbers(text: str) -> List[float]:
    """All digit groups of ``text`` (no identifier filtering); used to ground numbers that live inside strings."""
    vals: List[float] = []
    for m in _RAW.finditer(str(text)):
        s = m.group(0)
        try:
            if " " in s and "/" in s:
                whole, frac = s.split(None, 1)
                n, d = frac.split("/")
                vals.append(int(whole) + int(n) / int(d))
            elif "/" in s:
                n, d = s.split("/")
                vals.append(int(n) / int(d))
            else:
                vals.append(_to_float(s))
        except (ValueError, ZeroDivisionError):
            continue
    return vals


def collect_numbers(obj: Any, out: Optional[List[float]] = None, _depth: int = 0) -> List[float]:
    """Absolute values of every number in a JSON-able object, including digits inside its string values."""
    if out is None:
        out = []
    if _depth > 40:
        return out
    if isinstance(obj, bool) or obj is None:
        return out
    if isinstance(obj, (int, float)):
        if obj == obj and obj not in (float("inf"), float("-inf")):
            out.append(abs(float(obj)))
    elif isinstance(obj, str):
        out.extend(raw_numbers(obj))
    elif isinstance(obj, dict):
        for v in obj.values():
            collect_numbers(v, out, _depth + 1)
    elif isinstance(obj, (list, tuple, set)):
        for v in obj:
            collect_numbers(v, out, _depth + 1)
    return out


def _factors(unit: Optional[str]) -> Sequence[float]:
    """Multipliers f such that ``printed = grounded * f`` is an acceptable reading of a number with this unit."""
    if unit in ("in", "ipm", "ipt"):
        return (1.0, 1.0 / MM_PER_IN)            # grounded in mm (or mm/min, mm/tooth)
    if unit in ("mm", "mm/min", "mm/tooth"):
        return (1.0, MM_PER_IN)                  # grounded in inches
    if unit == "cm":
        return (1.0, MM_PER_IN / 10.0, 1.0 / 10.0)
    if unit == "m/min":
        return (1.0, M_PER_FT)                   # grounded in SFM
    if unit == "sfm":
        return (1.0, 1.0 / M_PER_FT)             # grounded in m/min
    if unit == "%":
        return (1.0, 100.0)                      # grounded as a 0..1 ratio
    if unit == "min":
        return (1.0, 1.0 / 60.0)
    if unit == "s":
        return (1.0, 60.0)
    if unit == "thou":
        return (1.0, 1000.0)                     # 0.001 in written as 1 thou
    if unit == "um":
        return (1.0, 25400.0, 1000.0)
    return (1.0,)


class Grounding:
    """Sorted pool of the numbers a text is allowed to contain."""

    def __init__(self, values: Iterable[float]):
        self.values = sorted(v for v in values if v == v)

    def matches(self, tok: NumberToken) -> bool:
        v = tok.value
        tol = max(0.005 * v, 0.5 * 10.0 ** (-tok.decimals) if tok.decimals < 6 else 0.0005 * v + 1e-12)
        for f in _factors(tok.unit):
            lo, hi = (v - tol) / f, (v + tol) / f
            i = bisect.bisect_left(self.values, lo - 1e-12)
            if i < len(self.values) and self.values[i] <= hi + 1e-12:
                return True
        return False


def check_numbers(text: str, grounding: Any, extra_texts: Iterable[str] = ()) -> Dict[str, Any]:
    """Check every number in ``text`` against ``grounding`` (+ digits in ``extra_texts``, e.g. the user's question).

    Returns ``{"ok": bool, "rejected_numbers": [str, ...], "checked": int}``; ``rejected_numbers`` lists each
    offending number as printed (de-duplicated, in order of appearance)."""
    pool = collect_numbers(grounding)
    for t in extra_texts or ():
        pool.extend(raw_numbers(t))
    g = Grounding(pool)
    rejected: List[str] = []
    toks = extract_numbers(text)
    for tok in toks:
        if tok.value == 0:
            continue
        if not g.matches(tok) and tok.text not in rejected:
            rejected.append(tok.text)
    return {"ok": not rejected, "rejected_numbers": rejected, "checked": len(toks)}
