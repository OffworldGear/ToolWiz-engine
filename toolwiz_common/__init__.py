"""toolwiz_common: pure-stdlib helpers shared by the ToolWiz server and the Fusion add-in."""
from .tool_types import (
    ToolKind, classify, is_hole_kind, is_tap_kind, is_milling_kind,
)
from .units import UnitError, to_inches, tool_unit
from .geometry import ToolGeometry, default_stickout
from .tool_profile import Segment, ToolProfile
from .expr import safe_eval_length

__all__ = [
    "ToolKind", "classify", "is_hole_kind", "is_tap_kind", "is_milling_kind",
    "UnitError", "to_inches", "tool_unit",
    "ToolGeometry", "default_stickout", "Segment", "ToolProfile", "safe_eval_length",
]
