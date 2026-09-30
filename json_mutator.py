"""
Canonical JSON mutator module.
Re-exports from ToolWizFusionAddin.json_mutator to maintain a single source of truth.
"""
from ToolWizFusionAddin.json_mutator import (
    format_unit,
    mutate_tool_json,
    MutatedToolResult
)

__all__ = ["format_unit", "mutate_tool_json", "MutatedToolResult"]
