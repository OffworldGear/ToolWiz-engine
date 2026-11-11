"""The owner's real Fusion libraries (data/shop_library) through the profile and /api/calculate.

Slot mills (T-slot / keyseat cutters) must be read with kerf = LCF and the neck taken from the shaft
segments; every cutting tool in the three libraries must give a finite, positive rpm and feed.
"""
import glob
import json
import math
import os
import sys

import pytest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
import app as app_module  # noqa: E402
from app import app  # noqa: E402
from toolwiz_common.tool_profile import ToolProfile  # noqa: E402
from toolwiz_common.tool_types import ToolKind, classify  # noqa: E402

LIB_DIR = os.path.join(os.path.dirname(__file__), "..", "data", "shop_library")
TI_LIB = os.path.join(LIB_DIR, "Offworldgear_TI_Steel1_Updated4_20261019_125408_v6.json")
HDR = {"X-ToolWiz-Client": "x"}
TI = "Titanium Alloy"
PH = "Stainless - PH Series (17-4)"
AL = "Aluminum - Wrought (6061)"
MM = 1 / 25.4


def _load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)["tools"]


def _by_desc(prefix):
    return next(t for t in _load(TI_LIB) if t["type"] == "slot mill" and t["description"].startswith(prefix))


# tool prefix -> (kerf, neck diameter, reach below the head), inches. Fusion LCF; first shaft segment's
# lower diameter; head top face to the end of the neck transition (sum of shaft segment heights).
EXPECTED = {
    "6mm x .5mm": (0.5 * MM, 3 * MM, 10 * MM),
    "8mm x 1mm": (1 * MM, 4 * MM, 3.5 * MM),
    "3/8 x 1/32 Keyseat": (0.031, 0.187, 0.5625),
}


@pytest.fixture(scope="module")
def client():
    c = app.test_client()
    c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
    return c


def _slot_body(tool, family, **extra):
    body = {"family": family, "operation": "Slotting", "aggressiveness": 50, "fusion_tool": tool,
            "tool": "Carbide Endmill", "geometry": "T-Slot", "tslotOperation": "full_slot",
            "radialDepthTotal": 0.04, "runout": 0.0002}
    body.update(extra)
    return body


@pytest.mark.parametrize("prefix", list(EXPECTED))
def test_slot_mill_profile_geometry(prefix):
    tool = _by_desc(prefix)
    prof = ToolProfile.from_fusion(tool)
    kerf, neck, reach = EXPECTED[prefix]
    assert prof.slot is not None
    assert prof.slot["kerf"] == pytest.approx(kerf, rel=1e-6)
    assert prof.slot["neck_diameter"] == pytest.approx(neck, rel=1e-6)
    assert prof.slot["reach"] == pytest.approx(reach, rel=1e-6)
    assert prof.slot["teeth"] == tool["geometry"]["NOF"]
    # the segments still tile [0, stickout] exactly
    assert prof.segments[0].start == 0.0
    for a, b in zip(prof.segments, prof.segments[1:]):
        assert a.end == pytest.approx(b.start)
    assert prof.segments[-1].end == pytest.approx(prof.stickout)


@pytest.mark.parametrize("prefix", list(EXPECTED))
@pytest.mark.parametrize("family", [TI, PH])
def test_slot_mill_calculate(client, prefix, family):
    tool = _by_desc(prefix)
    kerf, neck, reach = EXPECTED[prefix]
    r = client.post("/api/calculate", json=_slot_body(tool, family), headers=HDR)
    assert r.status_code == 200, r.get_json()
    j = r.get_json()
    assert j["success"]
    assert j["rec_doc"] == pytest.approx(kerf, abs=6e-5)          # kerf is the cutting width, not 0.125"
    assert j["flute_length"] == pytest.approx(kerf, abs=6e-5)
    assert j["neck_diameter"] == pytest.approx(neck, abs=6e-5)
    assert j["max_radial_reach"] == pytest.approx((tool["geometry"]["DC"] * (1 if tool["unit"] == "inches" else MM) - neck) / 2, abs=6e-5)
    g = j["tslot"]["geometry"]
    assert g["kerf"] == pytest.approx(kerf, rel=1e-6)
    assert g["neck_diameter"] == pytest.approx(neck, rel=1e-6)
    assert g["reach"] == pytest.approx(reach, rel=1e-6)
    assert j["tslot"]["teeth"] == tool["geometry"]["NOF"]
    for k in ("rpm", "feedrate"):
        assert math.isfinite(j[k]) and j[k] > 0


def test_haas_keyseat_deflection_is_real(client):
    j = client.post("/api/calculate", json=_slot_body(_by_desc("3/8 x 1/32 Keyseat"), TI), headers=HDR).get_json()
    assert j["deflection"] > 1e-6          # was ~2e-7 when the neck was read as the full 0.375"
    assert j["tslot"]["deflection_in"] > 1e-6


def test_slot_mill_without_description_or_shaft_still_uses_lcf(client):
    tool = {"type": "slot mill", "unit": "millimeters",
            "geometry": {"DC": 10, "LCF": 2, "NOF": 6, "SFDM": 6, "LB": 30}}
    j = client.post("/api/calculate", json=_slot_body(tool, TI), headers=HDR).get_json()
    assert j["success"] and j["rec_doc"] == pytest.approx(2 * MM, abs=6e-5)


# ---- every tool in the three libraries -------------------------------------------------------------

_GEO = {ToolKind.SLOT: "T-Slot", ToolKind.DOVETAIL: "Dovetail", ToolKind.LOLLIPOP: "Lollipop",
        ToolKind.CHAMFER: "Chamfer", ToolKind.BALL: "Ball Nose", ToolKind.BULL: "Bull Nose",
        ToolKind.FLAT: "Square"}
_OPS = {ToolKind.FLAT: ["Adaptive Roughing", "Slotting"], ToolKind.BULL: ["Adaptive Roughing", "Slotting"],
        ToolKind.BALL: ["Adaptive Roughing", "Slotting"], ToolKind.SLOT: ["Slotting"],
        ToolKind.LOLLIPOP: ["Finishing"], ToolKind.DOVETAIL: ["Finishing"], ToolKind.CHAMFER: ["Finishing"],
        ToolKind.TAPERED: ["Finishing"], ToolKind.FACE: ["Roughing"], ToolKind.DRILL: ["Drilling"],
        ToolKind.SPOT_DRILL: ["Drilling"]}


def _all_tools():
    out = []
    for path in sorted(glob.glob(os.path.join(LIB_DIR, "*.json"))):
        for i, t in enumerate(_load(path)):
            if classify(t.get("type")) is not ToolKind.HOLDER:
                out.append((os.path.basename(path)[:14], i, t))
    return out


def _body_for(t, family, op):
    kind = classify(t["type"])
    body = {"family": family, "operation": op, "aggressiveness": 50, "fusion_tool": app_module._fusion_payload(t),
            "tool": app_module._batch_db_tool_type(kind, t, app_module.tool_is_carbide(t)),
            "geometry": _GEO.get(kind, "Square"), "runout": 0.0002, "isCarbide": app_module.tool_is_carbide(t)}
    if kind is ToolKind.SPOT_DRILL:
        body["geometry"] = "Spot Drill"
    if kind is ToolKind.SLOT:
        body.update(tslotOperation="full_slot", radialDepthTotal=0.04)
    return body


@pytest.mark.parametrize("lib,idx,tool", _all_tools(), ids=lambda v: v if isinstance(v, str) else (str(v) if isinstance(v, int) else ""))
@pytest.mark.parametrize("family", [TI, AL])
def test_every_library_tool_calculates(client, lib, idx, tool, family):
    kind = classify(tool["type"])
    for op in _OPS.get(kind, ["Roughing"]):
        r = client.post("/api/calculate", json=_body_for(tool, family, op), headers=HDR)
        if not tool.get("unit") and not (tool.get("geometry") or {}).get("unit"):
            # a tool with no unit is refused with a clear 400, never a 500 or a guess
            assert r.status_code == 400 and "unit" in r.get_json()["error"]
            continue
        j = r.get_json()
        assert r.status_code == 200 and j["success"], (tool["description"], op, j)
        assert math.isfinite(j["rpm"]) and j["rpm"] > 0, (tool["description"], op)
        assert math.isfinite(j["feedrate"]) and j["feedrate"] > 0, (tool["description"], op)
