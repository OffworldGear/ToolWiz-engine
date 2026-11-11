"""Fills ``CutResult.holder_advice`` and ``CutResult.tool_advice`` from ``toolwiz_common.tooling_advisor``.

Called once at the end of ``pipeline.run_cut``. Lengths are inches, speeds rpm / SFM, chip load inches per
tooth. Results are cached on rounded inputs so the hook adds well under a millisecond to a calculation.
Advice never blocks a calculation: any advisor error leaves the fields empty.
"""
from __future__ import annotations

import copy
from functools import lru_cache
from typing import Any, Dict, List, Optional

from toolwiz_common import tooling_advisor as _adv


@lru_cache(maxsize=512)
def _holder(diameter: float, runout: float, fz: float, flutes: int, rpm: float, operation: str,
            stickout: Optional[float], max_rpm: float, sfm: Optional[float]) -> Dict[str, Any]:
    return _adv.holder_advice(diameter, runout, fz, flutes, rpm, operation, stickout,
                              max_rpm=max_rpm, sfm_target=sfm)


@lru_cache(maxsize=512)
def _tools(family: str, diameter: float, operation: str, flutes: int, coating: str) -> List[Dict[str, Any]]:
    return _adv.tool_advice(family, diameter, operation, flutes, coating)


def _r(x: Optional[float], n: int) -> Optional[float]:
    return None if x is None else round(float(x), n)


def holder_advice_for(result: Any, req: Any) -> Optional[Dict[str, Any]]:
    """Holder advice for a finished cut: diameter, runout, chip load (``result.adj_ipt``), rpm, flutes,
    operation, stickout and target SFM. None for hole tools, taps or a cut without a feed."""
    if result.is_hole_tool or result.is_tapping or not result.adj_ipt or result.adj_ipt <= 0 or result.diameter <= 0:
        return None
    try:
        out = _holder(_r(result.diameter, 5), _r((result.runout_in if getattr(result, 'runout_in', None) is not None else req.runout) or 0.0, 6), _r(result.adj_ipt, 6),
                      int(req.flutes or 2), _r(result.rpm, 0), str(result.operation or req.operation or "side"),
                      _r(req.stickout, 4) if req.stickout else None, _r(req.max_rpm or 16000.0, 0),
                      _r(result.target_sfm, 1) if result.target_sfm else None)
        return copy.deepcopy(out)
    except Exception:
        return None


def tool_advice_for(result: Any, req: Any) -> List[Dict[str, Any]]:
    """Tool-series advice for the request's family, diameter and operation; [] when nothing applies."""
    if result.is_hole_tool or result.is_tapping or not req.family:
        return []
    try:
        return copy.deepcopy(_tools(str(req.family), _r(result.diameter, 5), str(result.operation or req.operation),
                                    int(req.flutes or 2), str(req.coating or "")))
    except Exception:
        return []


def fill_advice(result: Any, req: Any) -> Any:
    """Set ``result.holder_advice`` and ``result.tool_advice`` (``req`` is the normalized CutRequest)."""
    result.holder_advice = holder_advice_for(result, req)
    result.tool_advice = tool_advice_for(result, req)
    return result
