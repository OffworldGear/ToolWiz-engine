"""Tool brand -> benchmark vendor key (owner decisions 2026-11-12, "brand first").

The vendor keys are the file names of tests/benchmarks/v2/*.json (harvey_ball_cr.json and osg_ball.json belong to harvey
and osg). Free text from a request field, an assumption or a Fusion tool's `vendor` field is matched against the
aliases below, case- and punctuation-insensitive; text that names no charted vendor ("Klot (Amazon Ebay)", "Haas",
blank) gives no brand, and the text is kept so the result can say what was ignored.

Pure stdlib: shared by the server and the Fusion add-in.
"""
import re

# key -> display name of the vendor's charts
VENDORS = {
    "harvey": "Harvey Tool",
    "helical": "Helical Solutions",
    "kennametal": "Kennametal",
    "kyocera_sgs": "Kyocera SGS",
    "osg": "OSG",
    "sandvik": "Sandvik Coromant",
    "seco": "Seco Tools",
    "emuge": "Emuge-Franken",
    "garr": "Garr Tool",
    "yg1": "YG-1",
    "titan": "Titan USA",
}

# Aliases, compared after normalize(): lower case, every run of non-alphanumerics -> one space.
ALIASES = {
    "harvey": ("harvey", "harvey tool", "harvey tools", "harveytool", "harvey performance", "harvey performance company"),
    "helical": ("helical", "helical solutions", "helical solution", "helicaltool", "helical tool"),
    "kennametal": ("kennametal", "kenna", "kennametal inc", "widia kennametal"),
    "kyocera_sgs": ("sgs", "sgs tool", "sgs tool company", "sgs precision tools", "kyocera sgs", "kyocera sgs precision tools",
                    "kyocera sgs tool", "kyocera"),
    "osg": ("osg", "osg usa", "osg corporation", "osg tap and die"),
    "sandvik": ("sandvik", "sandvik coromant", "coromant"),
    "seco": ("seco", "seco tools", "seco tool", "niagara", "niagara cutter", "seco niagara"),
    "emuge": ("emuge", "emuge franken", "emugefranken", "franken", "emuge corp"),
    "garr": ("garr", "garr tool", "garr tools"),
    "yg1": ("yg1", "yg 1", "yg one", "yg1 tool", "yg 1 tool", "ygone"),
    "titan": ("titan", "titan usa", "titan tool supply"),
}

_ALIAS_INDEX = {alias: key for key, names in ALIASES.items() for alias in names}
# Longest aliases first, so "kyocera sgs" wins over "kyocera" and "harvey performance" over "harvey".
_PHRASES = sorted(_ALIAS_INDEX, key=len, reverse=True)


def normalize(text):
    return re.sub(r"[^a-z0-9]+", " ", str(text or "").lower()).strip()


def resolve(text):
    """The vendor key for free text, or None. An exact alias wins; otherwise an alias that appears as whole words in the
    text ("Harvey Tool 942308", "SGS Z-Carb"). Text naming two different charted vendors resolves to None (ambiguous)."""
    norm = normalize(text)
    if not norm:
        return None
    if norm in _ALIAS_INDEX:
        return _ALIAS_INDEX[norm]
    padded = f" {norm} "
    found = set()
    for phrase in _PHRASES:
        if f" {phrase} " in padded:
            found.add(_ALIAS_INDEX[phrase])
            padded = padded.replace(f" {phrase} ", " ")
    return found.pop() if len(found) == 1 else None


SHORT = {"harvey": "Harvey", "helical": "Helical", "kennametal": "Kennametal", "kyocera_sgs": "Kyocera SGS", "osg": "OSG",
         "sandvik": "Sandvik", "seco": "Seco", "emuge": "Emuge", "garr": "Garr", "yg1": "YG-1", "titan": "Titan"}


def display_name(key):
    return VENDORS.get(key, key)


def short_name(key):
    return SHORT.get(key, VENDORS.get(key, key))


def from_sources(brand=None, fusion_tool=None):
    """(vendor key or None, brand text or None, source) from the request's `brand` field, else the Fusion tool dict's
    `vendor`, else nothing. source: "request" | "fusion vendor" | None. Unknown text keeps the text with key None."""
    for text, source in ((brand, "request"), (_fusion_vendor(fusion_tool), "fusion vendor")):
        if text is not None and str(text).strip():
            return resolve(text), str(text).strip(), source
    return None, None, None


def _fusion_vendor(fusion_tool):
    if not isinstance(fusion_tool, dict):
        return None
    for k in ("vendor", "brand"):
        v = fusion_tool.get(k)
        if v:
            return v
    return None


def known_vendor_names():
    """Display names for a UI datalist."""
    return [VENDORS[k] for k in VENDORS]
