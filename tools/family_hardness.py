"""Representative hardness (HB) of a material family, for vendor rows that publish only an upper bound.

"<= 28 HRC", "up to 30 HRC" or "max 280 HB" is a class limit, not the material's hardness. The representative value is the
hardness of the alloy named in the family label (e.g. 1020 in "Steel - Low Carbon (1020)") in its usual supply condition, from the
ToolWiz alloy table (gwizard_physics.specific_alloys): the median over that alloy's annealed / normalized / hot rolled / as-rolled
rows, else over all its rows; families whose label names no alloy use the median over the family's alloys. Row hardness is then
min(representative, published upper bound). Rows that publish a minimum, a range or a single value keep the given value.
"""
import functools
import os
import re
import statistics
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

from gwizard_physics import ASTMHardnessConverter  # noqa: E402

SUPPLY = ("hot rolled", "normalized", "annealed", "as rolled", "solution", "cold drawn")


@functools.lru_cache(maxsize=1)
def _alloys():
    import app   # the alloy table is loaded by the app's physics object
    return list(app.physics.specific_alloys)


@functools.lru_cache(maxsize=None)
def representative_hb(family):
    rows = [a for a in _alloys() if a.get("family") == family]
    m = re.search(r"\(([^)]+)\)", family or "")
    token = m.group(1).lower() if m else None
    named = [a for a in rows if token and str(a.get("alloy", "")).lower().replace(" ph", "").startswith(token.replace(" ph", ""))] if token else []
    pool = named or rows
    supply = [a for a in pool if any(s in str(a.get("condition", "")).lower() for s in SUPPLY)]
    vals = [ASTMHardnessConverter.parse_hardness(a.get("hardness")) for a in (supply or pool)]
    vals = [v for v in vals if v]
    return statistics.median(vals) if vals else None


def row_hb(hardness, family=None):
    """Brinell of a vendor row: given value(s) as published; an upper bound only (min missing) is capped representative hardness."""
    if not hardness:
        return None
    lo, hi, scale = hardness.get("min"), hardness.get("max"), (hardness.get("scale") or "").upper()
    vals = [v for v in (lo, hi) if v is not None]
    if not vals or not scale:
        return None

    def to_hb(v):
        if scale == "HRC":
            return ASTMHardnessConverter.hrc_to_brinell(v)
        if scale == "HRB":
            return ASTMHardnessConverter.hrb_to_brinell(v)
        if "RM" in scale or "N/MM" in scale:
            return v / 3.38
        return float(v)
    if lo is None and hi is not None and family:
        rep = representative_hb(family)
        if rep:
            return min(rep, to_hb(hi))
    return to_hb(sum(vals) / len(vals))
