"""Shop T-slot cutters generated from a Fusion library (shop_tool_builder) and the /api/shop_tools library options."""
import copy
import json
import os
import sys

import pytest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, ROOT)
import app as appmod  # noqa: E402
import shop_tool_builder as stb  # noqa: E402
import tslot_model  # noqa: E402

LIB = os.path.join(ROOT, "data", "shop_library", "Offworldgear_TI_Steel1_Updated4_20261019_125408_v6.json")
HDR = {"X-ToolWiz-Client": "t"}


@pytest.fixture(scope="module")
def entries():
    return {e["id"]: e for e in stb.entries_from_library(stb.load_library(LIB))}


def test_owner_library_slot_mills(entries):
    assert sorted(entries) == ["fusion_haas_9p525x0p7874", "fusion_klot_6x0p5", "fusion_klot_8x1"]
    k = entries["fusion_klot_6x0p5"]
    assert (k["diameter_mm"], k["kerf_mm"], k["neck_diameter_mm"], k["reach_mm"], k["teeth"]) == (6.0, 0.5, 3.0, 10.0, 4)
    assert k["shank_diameter_mm"] == 6.0 and k["source"] == "fusion library" and k["planned"] is False
    k8 = entries["fusion_klot_8x1"]
    assert (k8["kerf_mm"], k8["neck_diameter_mm"], k8["reach_mm"]) == (1.0, 4.0, 3.5)
    h = entries["fusion_haas_9p525x0p7874"]
    assert h["diameter_mm"] == pytest.approx(9.525) and h["kerf_mm"] == pytest.approx(0.031 * 25.4, abs=1e-3)
    assert h["neck_diameter_mm"] == pytest.approx(0.187 * 25.4, abs=1e-3) and h["reach_mm"] == pytest.approx(0.5625 * 25.4, abs=1e-3)
    assert h["teeth"] == 8 and h["shank_diameter_mm"] == pytest.approx(9.525)
    for e in entries.values():                  # measured fields are not provisional; only the unknown tooth form is
        assert e["provisional"] == ["tooth_form"]


def slot_tool(desc, toolwiz=None, segments=True):
    t = {"type": "slot mill", "description": desc, "unit": "millimeters", "vendor": "Acme", "guid": "g1",
         "geometry": {"DC": 10, "LCF": 1.5, "NOF": 6, "SFDM": 4, "LB": 30, "OAL": 60}, "BMC": "carbide"}
    if segments:
        t["shaft"] = {"segments": [{"height": 6, "lower-diameter": 4, "upper-diameter": 4}, {"height": 4, "lower-diameter": 4, "upper-diameter": 10}]}
    if toolwiz:
        t["toolwiz"] = toolwiz
    return t


@pytest.mark.parametrize("desc,form,faces", [
    ("10x1.5 staggered keyseat", "staggered", ["periphery", "top", "bottom"]),
    ("10x1.5 double sided slot mill", "straight", ["periphery", "top", "bottom"]),
    ("10x1.5 up/down slot mill", "straight", ["periphery", "top", "bottom"]),
    ("10x1.5 Up Down slot mill", "straight", ["periphery", "top", "bottom"]),
    ("10x1.5 slot mill", None, None),
])
def test_tooth_form_from_description(desc, form, faces):
    e = stb.entry_from_tool(slot_tool(desc))
    assert e["tooth_form"] == form
    assert (e["cutting_faces"] == faces) if faces else ("tooth_form" in e["provisional"])


def test_toolwiz_block_wins_over_description():
    e = stb.entry_from_tool(slot_tool("staggered keyseat", {"tooth_form": "straight", "cutting_faces": ["periphery"], "teeth_per_face": 6}))
    assert (e["tooth_form"], e["cutting_faces"], e["teeth_per_face"]) == ("straight", ["periphery"], 6)
    assert e["provisional"] == []


def test_without_shaft_segments_neck_and_reach_are_provisional():
    e = stb.entry_from_tool(slot_tool("10x1.5 slot mill", segments=False))
    assert "neck_diameter" in e["provisional"] and "reach" in e["provisional"]


def test_non_slot_tools_are_skipped():
    assert stb.entry_from_tool({"type": "flat end mill", "unit": "millimeters", "geometry": {"DC": 6, "LCF": 12, "NOF": 3, "SFDM": 6}}) is None


def test_generated_entries_run_in_the_tslot_model(entries, tmp_path):
    doc = stb.merge_shop_tools({"tools": []}, list(entries.values()), "x.json")
    p = tmp_path / "shop_tools.json"
    p.write_text(json.dumps(doc))
    tools = tslot_model.load_shop_tools(str(p))
    out = tslot_model.compute_shop_tool(appmod.physics, "fusion_klot_6x0p5", "Titanium Alloy", path=str(p))
    assert out["rpm"] > 0 and out["lateral_feed_ipm"] > 0 and set(tools) == set(entries)


def test_merge_keeps_planned_replaces_same_geometry_and_flags_hand_entered(entries):
    existing = {"_comment": "c", "tools": [
        {"id": "klot_6x0p5_old", "diameter_mm": 6.0, "kerf_mm": 0.5, "planned": False, "provisional": ["neck_diameter"]},
        {"id": "harvey_867330", "diameter_mm": 9.525, "kerf_mm": 1.5748, "planned": True},
        {"id": "klot_6x2", "diameter_mm": 6.0, "kerf_mm": 2.0, "planned": False}]}
    doc = stb.merge_shop_tools(existing, list(entries.values()), "lib.json")
    ids = [t["id"] for t in doc["tools"]]
    assert "klot_6x0p5_old" not in ids and "fusion_klot_6x0p5" in ids
    h = next(t for t in doc["tools"] if t["id"] == "harvey_867330")
    assert h["planned"] is True and not h.get("not_in_library")
    assert next(t for t in doc["tools"] if t["id"] == "klot_6x2")["not_in_library"] is True
    assert doc["_comment"] == "c" and doc["library_source"] == "lib.json"
    again = stb.merge_shop_tools(doc, list(entries.values()), "lib.json")      # idempotent
    assert [t["id"] for t in again["tools"]] == ids


def test_committed_shop_tools_file_has_the_library_cutters_and_harvey():
    tools = tslot_model.load_shop_tools()
    assert {"fusion_klot_6x0p5", "fusion_klot_8x1", "fusion_haas_9p525x0p7874", "harvey_867330"} <= set(tools)
    assert tools["fusion_klot_6x0p5"]["source"] == "fusion library" and tools["harvey_867330"]["planned"] is True


def test_resolve_library_names():
    assert stb.resolve_library_path("Offworldgear").endswith("v6.json")
    assert stb.resolve_library_path("working").endswith("working_library.json")
    for bad in ("../../etc/passwd", "nope", ""):
        with pytest.raises(ValueError):
            stb.resolve_library_path(bad)


def test_route_preview_and_refresh(tmp_path, monkeypatch):
    c = appmod.app.test_client()
    j = c.get("/api/shop_tools?library=Offworldgear").get_json()
    assert j["success"] and not j["written"] and "fusion_klot_8x1" in j["library_added"]
    assert c.get("/api/shop_tools?library=zzz").status_code == 400
    target = tmp_path / "st.json"
    target.write_text(json.dumps({"tools": [{"id": "keep", "diameter_mm": 1, "kerf_mm": 1}]}))
    monkeypatch.setattr(stb, "SHOP_TOOLS_PATH", str(target))
    r = c.post("/api/shop_tools/refresh", json={"library": "Offworldgear"}, headers=HDR).get_json()
    assert r["success"] and r["written"]
    saved = json.loads(target.read_text())
    assert {t["id"] for t in saved["tools"]} >= {"keep", "fusion_klot_6x0p5"}
    assert c.post("/api/shop_tools/refresh", json={"library": "zzz"}, headers=HDR).status_code == 400
    assert c.post("/api/shop_tools/refresh", json={"library": "x"}).status_code in (400, 403)   # client header required
