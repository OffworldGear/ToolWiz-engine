"""Default tool-tip runout (TIR) when a request gives none. Pure functions, stdlib only.

Owner decision (V4, 2026-11-11): "assume small tools will be in holders that have ~0.0001" runout at the tool". His
micro holders are Pioneer SX10 collet chucks and Lyndex SK6/SK10, upgradable to precision collets, Rego-Fix or BIG Baby
Mega. So, in this order:

1. An explicit runout in the request always wins (``runout_source`` "request").
2. The Fusion tool's holder description names a holder class: that class's TIR (``runout_source`` "holder: <class>").
3. Otherwise 0.0001" for tools of 1/8" and below and 0.0002" above (``runout_source`` "default by diameter").

Holder classes and their TIR at the tip (inches), after ``data/holders.json`` (published maxima, capability classes ultra
<= 0.00015", precision <= 0.0003", standard above):

====================================================  ========  =================================================
class                                                  TIR (in)  holders.json ids
====================================================  ========  =================================================
precision: SK/SX/SKC collet chucks, hydraulic, shrink   0.0001    sk_collet_chuck, hydraulic, shrink_fit, powrgrip,
fit, powRgrip, micro collet chucks (Mega Micro/Baby)               micro_collet_chuck (the owner's SK/SX chucks are
                                                                    used at their precision-collet value)
ultra-precision ER (ER-UP)                              0.0002    er_ultra_precision
standard ER collet, milling chuck                       0.0004    er_standard (published 0.00059 at 3xD worst case;
                                                                    the working value is the owner-stated 0.0004),
                                                                    milling_chuck (0.00039)
Weldon / side-lock                                      0.0012    weldon
====================================================  ========  =================================================
"""
import re

SMALL_TOOL_MAX_D_IN = 0.125 + 1e-9
DEFAULT_TIR_SMALL_IN = 0.0001
DEFAULT_TIR_LARGE_IN = 0.0002
SOURCES = ("request", "holder", "default by diameter")

# (label, tir_in, regex over the lower-cased holder description). The first match wins, so specific classes come first.
HOLDER_CLASSES = (
    ("ER-UP", 0.0002, r"\ber[\s-]?up\b|\ber\d{1,2}[\s-]*up\b|ultra[\s-]?precision\s+(?:er|collet)|\ber\d*[\s-]*ultra"),
    ("precision", 0.0001, r"\bs[kx]c?[\s-]?\d{0,2}\b|\bsx\d+|pioneer|lyndex|hydraulic|shrink|pow[\s-]?r?grip|rego[\s-]?fix|"
                          r"micro\s*chuck|mega\s*(?:micro|baby|new\s*baby)|big\s*kaiser|tendo|micr?run|haimer|precision\s+collet"),
    ("weldon", 0.0012, r"weldon|side[\s-]?lock|whistle"),
    ("standard ER", 0.0004, r"\ber[\s-]?\d{2}\b|\ber\d{2}\b|\ber\s*collet|\ber\b|milling\s*chuck|collet"),
)


def holder_runout(description):
    """(label, tir_in) for a holder description such as 'ER32 Collet Holder' or 'Lyndex SK10', or None when it names no
    known class (or is empty)."""
    s = str(description or "").strip().lower()
    if not s:
        return None
    for label, tir, pat in HOLDER_CLASSES:
        if re.search(pat, s):
            return label, tir
    return None


def default_runout(diameter_in, holder_description=None):
    """(tir_in, runout_source) for a request with no runout: the holder class's value when the description names one,
    else 0.0001" for tools of 1/8" and below and 0.0002" above."""
    hit = holder_runout(holder_description)
    if hit:
        return hit[1], f"holder: {hit[0]}"
    small = diameter_in is not None and 0 < float(diameter_in) <= SMALL_TOOL_MAX_D_IN
    return (DEFAULT_TIR_SMALL_IN if small else DEFAULT_TIR_LARGE_IN), "default by diameter"


def holder_description_of(tool_dict):
    """The holder description in a Fusion tool dict ("holder": {"description"} or a "holder" string), or ''."""
    if not isinstance(tool_dict, dict):
        return ""
    h = tool_dict.get("holder")
    if isinstance(h, dict):
        return str(h.get("description") or h.get("product-id") or "")
    return str(h or "")
