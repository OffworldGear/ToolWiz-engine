"""Exact classification of Fusion 360 tool type strings."""
from enum import Enum


class ToolKind(Enum):
    FLAT = "flat"
    BALL = "ball"
    BULL = "bull"
    CHAMFER = "chamfer"
    FACE = "face"
    SLOT = "slot"
    RADIUS = "radius"
    DOVETAIL = "dovetail"
    TAPERED = "tapered"
    LOLLIPOP = "lollipop"
    FORM = "form"
    THREAD_MILL = "thread_mill"
    DRILL = "drill"
    SPOT_DRILL = "spot_drill"
    CENTER_DRILL = "center_drill"
    REAMER = "reamer"
    TAP = "tap"
    BORE = "bore"
    COUNTERBORE = "counterbore"
    COUNTERSINK = "countersink"
    PROBE = "probe"
    HOLDER = "holder"
    UNKNOWN = "unknown"


_MAP = {
    "flat end mill": ToolKind.FLAT,
    "end mill": ToolKind.FLAT,
    "ball end mill": ToolKind.BALL,
    "bull nose end mill": ToolKind.BULL,
    "chamfer mill": ToolKind.CHAMFER,
    "face mill": ToolKind.FACE,
    "slot mill": ToolKind.SLOT,
    "radius mill": ToolKind.RADIUS,
    "dovetail mill": ToolKind.DOVETAIL,
    "tapered mill": ToolKind.TAPERED,
    "lollipop mill": ToolKind.LOLLIPOP,
    "form mill": ToolKind.FORM,
    "thread mill": ToolKind.THREAD_MILL,
    "drill": ToolKind.DRILL,
    "spot drill": ToolKind.SPOT_DRILL,
    "center drill": ToolKind.CENTER_DRILL,
    "reamer": ToolKind.REAMER,
    "tap right hand": ToolKind.TAP,
    "tap left hand": ToolKind.TAP,
    "boring bar": ToolKind.BORE,
    "counter bore": ToolKind.COUNTERBORE,
    "counter sink": ToolKind.COUNTERSINK,
    "probe": ToolKind.PROBE,
    "holder": ToolKind.HOLDER,
}

_HOLE = frozenset({
    ToolKind.DRILL, ToolKind.SPOT_DRILL, ToolKind.CENTER_DRILL, ToolKind.REAMER,
    ToolKind.TAP, ToolKind.BORE, ToolKind.COUNTERBORE, ToolKind.COUNTERSINK,
})
_MILLING = frozenset({
    ToolKind.FLAT, ToolKind.BALL, ToolKind.BULL, ToolKind.CHAMFER, ToolKind.FACE,
    ToolKind.SLOT, ToolKind.RADIUS, ToolKind.DOVETAIL, ToolKind.TAPERED,
    ToolKind.LOLLIPOP, ToolKind.FORM, ToolKind.THREAD_MILL,
})


def classify(fusion_type) -> ToolKind:
    """Map a Fusion 'type' string to a ToolKind (exact lowercase match; else UNKNOWN)."""
    if not isinstance(fusion_type, str):
        return ToolKind.UNKNOWN
    return _MAP.get(" ".join(fusion_type.strip().lower().split()), ToolKind.UNKNOWN)


def is_hole_kind(k: ToolKind) -> bool:
    return k in _HOLE


def is_tap_kind(k: ToolKind) -> bool:
    return k is ToolKind.TAP


def is_milling_kind(k: ToolKind) -> bool:
    """UNKNOWN, HOLDER and PROBE are never milling."""
    return k in _MILLING
