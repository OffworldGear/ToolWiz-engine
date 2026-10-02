"""Normalised tool geometry (all lengths in inches)."""
from dataclasses import dataclass
from typing import Optional

from .tool_types import ToolKind, classify, is_milling_kind
from .units import to_inches, tool_unit


def default_stickout(diameter: float, flute_length: float = 0.0) -> float:
    """max(3.0*D*1.05, 1.05*flute_length); always > 0 for positive diameter."""
    return max(3.0 * diameter * 1.05, 1.05 * (flute_length or 0.0))


@dataclass
class ToolGeometry:
    diameter: float
    flutes: int
    flute_length: float
    shank_diameter: float
    corner_radius: float
    stickout: float
    stickout_source: str  # override | fusion_LB | fusion_gauge | default
    taper_angle: float = 0.0
    thread_pitch: Optional[float] = None
    kind: ToolKind = ToolKind.UNKNOWN
    # Reduced neck between flutes and shank (Fusion 'shoulder-length' / 'shoulder-diameter');
    # None when the tool steps straight from flutes to shank.
    neck_length: Optional[float] = None
    neck_diameter: Optional[float] = None

    @classmethod
    def from_fusion(cls, tool: dict, stickout_override=None) -> "ToolGeometry":
        """Build from a Fusion tool dict. stickout_override is in inches."""
        unit = tool_unit(tool)
        geo = tool.get("geometry") or {}
        kind = classify(tool.get("type"))

        def raw(key):
            v = geo.get(key)
            if v in (None, ""):
                v = tool.get(key) if key == "assemblyGaugeLength" else None
            return v

        def length(key, default=None):
            v = raw(key)
            if v in (None, ""):
                return default
            return to_inches(v, unit)

        dia = length("DC")
        if dia is None or dia <= 0:
            raise ValueError("tool has no positive DC (diameter)")
        flute_len = length("LCF", 0.0) or 0.0
        if flute_len < 0:
            flute_len = 0.0
        shank = length("SFDM")
        if shank is None or shank <= 0:
            shank = length("SF")
        if shank is None or shank <= 0:
            shank = dia
        rad = length("RE", 0.0) or 0.0

        nof = geo.get("NOF")
        try:
            flutes = int(float(nof)) if nof not in (None, "") else 0
        except (TypeError, ValueError):
            flutes = 0
        if flutes <= 0:
            flutes = 4 if is_milling_kind(kind) else 2

        try:
            taper = float(geo.get("TA")) if geo.get("TA") not in (None, "") else 0.0
        except (TypeError, ValueError):
            taper = 0.0

        tp = length("TP")
        if tp is not None and tp <= 0:
            tp = None

        stick, src = None, None
        ov = None
        if stickout_override not in (None, ""):
            try:
                ov = float(stickout_override)
            except (TypeError, ValueError):
                ov = None
        if ov is not None and ov > 0:
            stick, src = ov, "override"
        if stick is None:
            lb = length("LB")
            if lb is not None and lb > 0:
                stick, src = lb, "fusion_LB"
        if stick is None:
            gauge = length("assemblyGaugeLength")
            if gauge is not None and gauge > 0:
                stick, src = gauge, "fusion_gauge"
        if stick is None:
            stick, src = default_stickout(dia, flute_len), "default"

        neck_len = neck_dia = None
        sl, sd = length("shoulder-length"), length("shoulder-diameter")
        if sl and sd and sl > flute_len * 1.01 and 0.0 < sd < shank * 0.999:
            neck_len, neck_dia = sl, sd

        return cls(diameter=dia, flutes=flutes, flute_length=flute_len, shank_diameter=shank,
                   corner_radius=rad, stickout=stick, stickout_source=src,
                   taper_angle=taper, thread_pitch=tp, kind=kind,
                   neck_length=neck_len, neck_diameter=neck_dia)
