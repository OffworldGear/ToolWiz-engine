"""toolwiz_common: pure-stdlib helpers shared by the ToolWiz server and the Fusion add-in."""
from .tool_types import (
    ToolKind, classify, is_hole_kind, is_tap_kind, is_milling_kind,
)
from .units import UnitError, to_inches, tool_unit
from .geometry import ToolGeometry, default_stickout, default_shank, shank_looks_wrong, MICRO_SHANK_IN
from .tool_profile import HOLDER_TAPER_MARGIN_IN, HOLDER_TAPER_MARGIN_MM, Segment, ToolProfile
from .expr import safe_eval_length
from .cam_geometry_inspector import (
    CM_TO_IN,
    OperationGeometryReport,
    inspect_operation_geometry,
    calc_corner_engagement,
    calc_thin_wall_compliance_factor,
    is_wall_only_operation,
    contour_effective_width_in,
    measure_op_widths,
)

__all__ = [
    "ToolKind", "classify", "is_hole_kind", "is_tap_kind", "is_milling_kind",
    "UnitError", "to_inches", "tool_unit",
    "ToolGeometry", "default_stickout", "default_shank", "shank_looks_wrong", "MICRO_SHANK_IN", "HOLDER_TAPER_MARGIN_IN", "HOLDER_TAPER_MARGIN_MM", "Segment", "ToolProfile", "safe_eval_length",
    "CM_TO_IN", "OperationGeometryReport", "inspect_operation_geometry", "calc_corner_engagement", "calc_thin_wall_compliance_factor", "is_wall_only_operation",
    "contour_effective_width_in", "measure_op_widths",
]
