"""Which cutting strategies make sense for which Fusion tool type (shared by preset generation and the audit).

End-mill strategies (Adaptive Roughing, Roughing, Finishing, Slotting) take their stepdown from the flute
length and their stepover from the diameter. Form tools (slot mill / keyseat / T-slot, dovetail,
lollipop, chamfer, thread mill, form mill) and drills cut with a different geometry, so those numbers
are meaningless for them (a 6 mm x 0.5 mm slot mill given "Adaptive Roughing" gets a 24 mm stepdown).
"""
from __future__ import annotations

from typing import Dict, List, Optional, Tuple

from .tool_types import ToolKind, is_hole_kind

END_MILL_STRATEGIES = ("Adaptive Roughing", "Roughing", "Finishing", "Slotting")

# Tool kinds that take the end-mill strategies as they are.
END_MILL_KINDS = frozenset({ToolKind.FLAT, ToolKind.BULL, ToolKind.BALL, ToolKind.RADIUS, ToolKind.TAPERED})
# Form tools that get no end-mill strategy at all.
FORM_KINDS = frozenset({ToolKind.DOVETAIL, ToolKind.LOLLIPOP, ToolKind.CHAMFER, ToolKind.THREAD_MILL,
                        ToolKind.FORM})

T_SLOT_FULL = "T-Slot Full Slot"
T_SLOT_AXIAL = "T-Slot Axial Step"


def is_end_mill_strategy(name: str) -> bool:
    """True when the operation name is one of the four end-mill strategies (case-insensitive)."""
    n = (name or "").strip().lower()
    return n in {s.lower() for s in END_MILL_STRATEGIES}


def slot_faces(tool_dict: dict) -> Tuple[Optional[str], Optional[List[str]]]:
    """(tooth_form, cutting_faces) for a slot / keyseat cutter, from its description or an explicit
    ``toolwiz`` block ({"tooth_form", "cutting_faces"}). Fusion has no field for either, so unknown is
    (None, None): the T-slot model then assumes staggered teeth, which is the conservative case."""
    tw = tool_dict.get("toolwiz") if isinstance(tool_dict, dict) else None
    if isinstance(tw, dict) and (tw.get("tooth_form") or tw.get("cutting_faces")):
        faces = tw.get("cutting_faces")
        return (str(tw["tooth_form"]).lower() if tw.get("tooth_form") else None,
                [str(f).lower() for f in faces] if faces else None)
    text = str(tool_dict.get("description") or "").lower()
    form = "staggered" if "staggered" in text else ("straight" if "straight" in text else None)
    both = any(w in text for w in ("double", "both side", "both face", "up and down", "up/down", "two-sided",
                                   "2-sided", "up cut", "down cut", "up-cut", "down-cut"))
    if form == "staggered" or both:
        return form, ["periphery", "top", "bottom"]
    if form == "straight":
        return form, ["periphery"]
    return None, None


def cuts_both_faces(tool_dict: dict) -> bool:
    """True only when the tool is known to cut on both its top and bottom faces."""
    _, faces = slot_faces(tool_dict)
    return bool(faces and "top" in faces and "bottom" in faces)


def plan_strategies(kind: ToolKind, tool_dict: dict, requested: List[str]) -> Tuple[List[Dict[str, str]], List[str]]:
    """Presets to generate for one tool: (jobs, skipped_reasons).

    Each job is {"label", "operation", "tslot_operation"} where ``label`` is the preset's operation name,
    ``operation`` the pipeline operation to run and ``tslot_operation`` the T-slot model operation (or "").
    End-mill kinds keep the requested strategies; slot mills get a T-slot full-slot preset (and an
    axial-step preset only when the tool is known to cut both faces); other form tools and drills get none
    and a reason is returned instead."""
    if kind is ToolKind.SLOT:
        jobs = [{"label": T_SLOT_FULL, "operation": "Slotting", "tslot_operation": "full_slot"}]
        reasons: List[str] = []
        if cuts_both_faces(tool_dict):
            jobs.append({"label": T_SLOT_AXIAL, "operation": "Slotting", "tslot_operation": "axial_step"})
        else:
            reasons.append("axial-step preset not written: cutting faces unknown (add 'staggered' / 'double' "
                           "to the description or a toolwiz.cutting_faces entry if the cutter cuts up and down)")
        return jobs, reasons
    if kind in END_MILL_KINDS:
        return [{"label": s, "operation": s, "tslot_operation": ""} for s in requested], []
    if kind is ToolKind.FACE:
        keep = [s for s in requested if s in ("Roughing", "Finishing")]
        dropped = [s for s in requested if s not in keep]
        return ([{"label": s, "operation": s, "tslot_operation": ""} for s in keep],
                [f"{s!r} does not apply to a face mill" for s in dropped])
    if kind in FORM_KINDS or is_hole_kind(kind):
        return [], [f"{kind.value} tool: end-mill strategies (Adaptive Roughing, Roughing, Finishing, Slotting) "
                    f"do not apply and no form-tool strategy is defined; no preset written"]
    return [], [f"no strategy defined for tool kind {kind.value}"]
