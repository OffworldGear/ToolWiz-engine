"""One tool profile, built from Fusion's own fields, feeding the physics, the drawing and every endpoint.

The profile is a list of axial :class:`Segment` objects (inches, measured from the tip) that tile
``[0, stickout]`` exactly: flutes, an optional reduced neck, then the shank out to the holder.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional

from .geometry import ToolGeometry, default_shank, shank_looks_wrong

SHANK_WARNING = ("Shank diameter equals the cutting diameter on a tool under 1/8\": the tool is modelled "
                 "as a thin rod all the way to the holder. Miniature end mills normally have a 1/8\" shank; "
                 "if yours does, correct the tool's shaft diameter (Fusion: Cutter tab > Shaft diameter).")

_EPS = 1e-9


@dataclass
class Segment:
    kind: str        # "flute" | "neck" | "shank"
    start: float     # inches from the tip
    end: float
    d0: float        # diameter at start
    d1: float        # diameter at end (== d0 unless tapered)
    fluted: bool

    @property
    def length(self) -> float:
        return self.end - self.start

    def to_dict(self) -> Dict[str, Any]:
        return {"kind": self.kind, "start": round(self.start, 6), "end": round(self.end, 6),
                "d0": round(self.d0, 6), "d1": round(self.d1, 6), "fluted": self.fluted}


@dataclass
class ToolProfile:
    geometry: ToolGeometry
    segments: List[Segment]
    stickout: float
    stickout_source: str
    warnings: List[str] = field(default_factory=list)

    @classmethod
    def from_fusion(cls, tool_dict: dict, stickout_override=None) -> "ToolProfile":
        g = ToolGeometry.from_fusion(tool_dict, stickout_override=stickout_override)
        lb = g.stickout
        lcf = g.flute_length
        dc = g.diameter
        sl = g.shoulder_length or 0.0
        warnings: List[str] = []

        has_neck = sl > lcf * 1.01 and sl > 0.0
        if shank_looks_wrong(dc, g.shank_diameter):
            warnings.append(SHANK_WARNING)
        if lb < lcf - _EPS:
            warnings.append("Holder over flutes")
        elif has_neck and lb < sl - _EPS:
            warnings.append("Holder over neck")

        segments: List[Segment] = []
        pos = 0.0

        # Flutes [0, min(LCF, LB)]; a tapered mill grows from the tip diameter to DC at LCF.
        f_end = min(lcf, lb)
        if f_end > _EPS:
            tip = g.tip_diameter
            if g.taper_angle > 0.0 and tip and tip > 0.0:
                d0 = tip
            else:
                d0 = dc
            d1 = d0 + (dc - d0) * (f_end / lcf) if lcf > 0 else dc
            segments.append(Segment("flute", 0.0, f_end, d0, d1, True))
            pos = f_end

        # Reduced neck [LCF, min(shoulder-length, LB)]
        if has_neck and pos < lb - _EPS:
            n_end = min(sl, lb)
            if n_end > pos + _EPS:
                nd = g.shoulder_diameter if (g.shoulder_diameter and g.shoulder_diameter > 0.0) else dc
                segments.append(Segment("neck", pos, n_end, nd, nd, False))
                pos = n_end

        # Shank out to the holder
        if lb > pos + _EPS:
            sd = g.shank_diameter if g.shank_diameter > 0.0 else dc
            segments.append(Segment("shank", pos, lb, sd, sd, False))
            pos = lb

        # Snap so the tiling is exact
        if segments:
            segments[-1].end = lb
        return cls(geometry=g, segments=segments, stickout=lb,
                   stickout_source=g.stickout_source, warnings=warnings)

    @classmethod
    def from_legacy(cls, diameter: float, flutes: int, flute_length: float,
                    shank_diameter: Optional[float], stickout: float,
                    has_relieved_neck: bool = False, neck_diameter: Optional[float] = None,
                    neck_length: Optional[float] = None, taper_angle: float = 0.0,
                    corner_radius: float = 0.0, geometry_kind: str = "flat end mill") -> "ToolProfile":
        """Map the old request fields onto a Fusion-shaped dict (one code path).

        No relieved neck -> the shank starts right after the flutes. ``neck_length`` is
        tip-to-shoulder (Fusion 'shoulder-length'). The old request carries no tip diameter, so a
        taper angle alone leaves the flutes at DC (as the pipeline modelled them before).
        """
        shank = shank_diameter if (shank_diameter and shank_diameter > 0) else default_shank(diameter)
        geo: Dict[str, Any] = {
            "DC": float(diameter), "NOF": int(flutes), "LCF": float(flute_length or 0.0),
            "SFDM": float(shank), "LB": float(stickout), "RE": float(corner_radius or 0.0),
        }
        if taper_angle and taper_angle > 0.0:
            geo["TA"] = float(taper_angle)
        if has_relieved_neck and neck_length and neck_length > 0.0:
            geo["shoulder-length"] = float(neck_length)
            geo["shoulder-diameter"] = float(neck_diameter) if (neck_diameter and neck_diameter > 0) else float(shank)
        tool = {"type": geometry_kind, "unit": "inches", "geometry": geo}
        return cls.from_fusion(tool, stickout_override=stickout)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "segments": [s.to_dict() for s in self.segments],
            "stickout": round(self.stickout, 6),
            "stickout_source": self.stickout_source,
            "warnings": list(self.warnings),
        }
