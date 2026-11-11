"""Default tool-tip runout when a request gives none (toolwiz_common/runout.py; owner decision V4)."""
import pytest

import app
from pipeline import CutRequest, run_cut
from toolwiz_common import runout as ro


HDR = {"X-ToolWiz-Client": "test"}


def _req(D, **kw):
    return CutRequest(family="Aluminum - Wrought (6061)", alloy="6061-T6", tool="HP Carbide Endmill", coating="Uncoated",
                      geometry="Square", operation="Slotting", diameter=D, flutes=2, flute_length=1.5 * D,
                      shank_diameter=max(D, 0.125), stickout=1.5 * D + 0.25, model="v2", **kw)


@pytest.mark.parametrize("D,want", [(0.0156, 0.0001), (0.0625, 0.0001), (0.125, 0.0001), (0.1875, 0.0002), (0.5, 0.0002)])
def test_default_by_diameter(D, want):
    r = run_cut(app.physics, _req(D))
    assert r.runout_in == pytest.approx(want) and r.runout_source == "default by diameter"


def test_explicit_runout_wins_even_zero():
    r = run_cut(app.physics, _req(0.0625, runout=0.0005))
    assert (r.runout_in, r.runout_source) == (0.0005, "request")
    r0 = run_cut(app.physics, _req(0.0625, runout=0.0))
    assert (r0.runout_in, r0.runout_source) == (0.0, "request")


@pytest.mark.parametrize("text,label,tir", [
    ("Lyndex SK10", "precision", 0.0001), ("Pioneer SX10 collet chuck", "precision", 0.0001), ("SK6 micro chuck", "precision", 0.0001),
    ("Haimer shrink fit chuck", "precision", 0.0001), ("Rego-Fix powRgrip PG", "precision", 0.0001),
    ("Hydraulic chuck", "precision", 0.0001), ("BIG Kaiser Mega New Baby", "precision", 0.0001),
    ("ER16 UP collet", "ER-UP", 0.0002), ("ER32 Collet Holder", "standard ER", 0.0004),
    ("Weldon 3/8 end mill holder", "weldon", 0.0012)])
def test_holder_classes(text, label, tir):
    assert ro.holder_runout(text) == (label, tir)


def test_holder_from_fusion_tool_description_and_source_label():
    ft = {"type": "flat end mill", "unit": "inches", "description": "1/4 flat",
          "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.75, "OAL": 3.0, "SFDM": 0.25, "shoulder-length": 1.5},
          "holder": {"description": "ER32 Collet Holder"}}
    r = run_cut(app.physics, CutRequest(family="Aluminum - Wrought (6061)", alloy="6061-T6", operation="Slotting", model="v2",
                                        fusion_tool=ft))
    assert r.runout_in == pytest.approx(0.0004) and r.runout_source == "holder: standard ER"
    ft["holder"] = {"description": "Lyndex SK10"}
    r2 = run_cut(app.physics, CutRequest(family="Aluminum - Wrought (6061)", alloy="6061-T6", operation="Slotting", model="v2",
                                         fusion_tool=ft))
    assert r2.runout_in == pytest.approx(0.0001) and r2.runout_source == "holder: precision"
    r3 = run_cut(app.physics, CutRequest(family="Aluminum - Wrought (6061)", alloy="6061-T6", operation="Slotting", model="v2",
                                         fusion_tool=ft, runout=0.0003))
    assert (r3.runout_in, r3.runout_source) == (0.0003, "request")


def test_api_reports_runout_source():
    c = app.app.test_client()
    body = {"family": "Aluminum - Wrought (6061)", "alloy": "6061-T6", "tool": "HP Carbide Endmill", "geometry": "Square",
            "operation": "Slotting", "diameter": 0.0625, "flutes": 2, "fluteLength": 0.1875, "shankDiameter": 0.125, "stickout": 0.5,
            "model": "v2"}
    d = c.post("/api/calculate", json=body, headers=HDR).get_json()
    assert d["runout_source"] == "default by diameter" and d["runout_in"] == pytest.approx(0.0001)
    d2 = c.post("/api/calculate", json=dict(body, runout=0.0002), headers=HDR).get_json()
    assert d2["runout_source"] == "request" and d2["runout_in"] == pytest.approx(0.0002)
