"""Brand first (owner decisions 2026-11-12): brand mapping, the vendor guardrail's lookup order, the 0/50/100 % range
mapping, HEM vs traditional roughing separation, and the vendor_basis result field on every endpoint."""
import json
import os
import sys

import pytest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from toolwiz_common import brand  # noqa: E402
from physics_v2 import optimize as o  # noqa: E402

FAM = "Stainless - PH Series (17-4)"
HDR = {"X-ToolWiz-Client": "unit-test"}


# ---- brand mapping ---------------------------------------------------------------------------------------------------

@pytest.mark.parametrize("text,key", [
    ("Harvey Tool", "harvey"), ("harvey", "harvey"), ("HARVEY TOOL 942308", "harvey"), ("Harvey Performance", "harvey"),
    ("Helical Solutions", "helical"), ("Helical", "helical"), ("SGS", "kyocera_sgs"), ("Kyocera SGS", "kyocera_sgs"),
    ("Kyocera SGS Precision Tools", "kyocera_sgs"), ("SGS Z-Carb", "kyocera_sgs"), ("Sandvik Coromant", "sandvik"),
    ("Emuge-Franken", "emuge"), ("Emuge Franken", "emuge"), ("YG-1", "yg1"), ("yg1", "yg1"), ("Titan USA", "titan"),
    ("Seco Tools", "seco"), ("OSG", "osg"), ("Kennametal", "kennametal"), ("Garr Tool", "garr"),
])
def test_brand_aliases(text, key):
    assert brand.resolve(text) == key


@pytest.mark.parametrize("text", ["Klot (Amazon Ebay)", "KK DUK AliExpress or Temu", "SpeTool Amazon", "Speed Tiger", "Haas",
                                  "Maritool", "", None, "   ", "Titanium end mill", "Harvey or Kennametal"])
def test_unbranded_and_unknown_text(text):
    assert brand.resolve(text) is None


def test_brand_sources_request_then_fusion_vendor():
    assert brand.from_sources("Helical", {"vendor": "Harvey Tool"}) == ("helical", "Helical", "request")
    assert brand.from_sources(None, {"vendor": "Harvey Tool"}) == ("harvey", "Harvey Tool", "fusion vendor")
    assert brand.from_sources("  ", {"vendor": "Klot (Amazon Ebay)"}) == (None, "Klot (Amazon Ebay)", "fusion vendor")
    assert brand.from_sources(None, {"geometry": {}}) == (None, None, None)


# ---- 0 / 50 / 100 % mapping ------------------------------------------------------------------------------------------

def test_range_mapping_bottom_middle_top_monotone_and_continuous():
    rng = (100.0, 160.0, 190.0)
    assert o.range_at(rng, 0.0) == pytest.approx(100.0)
    assert o.range_at(rng, 0.5) == pytest.approx(160.0)
    assert o.range_at(rng, 1.0) == pytest.approx(190.0)
    xs = [i / 200 for i in range(201)]
    ys = [o.range_at(rng, x) for x in xs]
    assert all(b >= a for a, b in zip(ys, ys[1:]))
    assert max(abs(b - a) for a, b in zip(ys, ys[1:])) < 1.0   # no jump anywhere (continuous)
    assert o.range_at(rng, -1) == 100.0 and o.range_at(rng, 2) == 190.0


def test_c14_cap_uses_range_when_present_else_the_old_scale():
    cons = {"sfm": 160.0, "ranges": {"sfm": (100.0, 160.0, 190.0)}}
    assert o.c14_cap(cons, "sfm", o.Margins(0.5, scheme="consensus")) == pytest.approx(160.0)
    assert o.c14_cap(cons, "sfm", o.Margins(1.0, scheme="consensus")) == pytest.approx(190.0)
    old = {"sfm": 160.0}
    assert o.c14_cap(old, "sfm", o.Margins(0.5, scheme="consensus")) == pytest.approx(o.consensus_scale(0.5) * 160.0)


# ---- lookup order on a synthetic table -------------------------------------------------------------------------------

BANDS = [{"band": "1/8-3/16", "d_min": 0.1, "d_max": 0.2}, {"band": "1/4-3/8", "d_min": 0.2, "d_max": 0.4}]
ENG = [["light", 0.0, 0.1], ["medium", 0.1, 0.25], ["heavy", 0.25, 0.99], ["slot", 0.99, 1e9]]


def row(sfm, fz_over_d=0.004):
    return [0.76 * sfm, sfm, 1.1 * sfm, 0.76 * fz_over_d, fz_over_d, 1.1 * fz_over_d, 1.0, 2.0, 3.0]


def table(vendors=None, consensus=None):
    return {"bands": BANDS, "engagement_classes": ENG, "hb_bin": 50, "min_vendor_groups": 2,
            "vendors": {k: {"cells": v} for k, v in (vendors or {}).items()},
            "consensus": {"cells": consensus or {}}}


def key(cls, eng="medium", band="1/4-3/8", hbin=7):
    return f"{FAM}|{hbin}|{band}|{cls}|{eng}"


def test_brand_first_then_default_then_consensus_then_none():
    t = table(vendors={"seco": {key("hem"): [row(560)]}, "helical": {key("hem"): [row(300)]},
                       "harvey": {key("rough"): [row(150)]}},
              consensus={key("hem"): {"A": [row(400)], "B": [row(500)]}, key("side"): {"A": [row(200)], "B": [row(260)]}})
    b = o.vendor_lookup(t, "seco", FAM, 356.0, 0.25, "adaptive", 0.2)
    assert (b["mode"], b["vendor"], b["chart_class"], b["sfm"]) == ("brand", "seco", "hem", 560)
    d = o.vendor_lookup(t, None, FAM, 356.0, 0.25, "adaptive", 0.2)
    assert (d["mode"], d["vendor"], d["chart_class"], d["sfm"]) == ("default", "helical", "hem", 300)
    # a brand without charts for the cut falls to the default, and says why
    k = o.vendor_lookup(t, "kennametal", FAM, 356.0, 0.25, "adaptive", 0.2)
    assert k["mode"] == "default" and k["brand_missing"]
    # no default rows for slotting: the cross-vendor consensus (none here for slot) -> None (physics only)
    assert o.vendor_lookup(t, None, FAM, 356.0, 0.25, "slot", 1.0) is None
    # rough: Harvey's roughing chart is the default
    r = o.vendor_lookup(t, None, FAM, 356.0, 0.25, "rough", 0.2)
    assert (r["mode"], r["vendor"], r["chart_class"]) == ("default", "harvey+helical", "rough")
    t2 = table(consensus={key("side"): {"A": [row(200)], "B": [row(260)]}})
    c = o.vendor_lookup(t2, None, FAM, 356.0, 0.25, "rough", 0.2)
    assert c["mode"] == "consensus" and c["sfm"] == pytest.approx(230.0) and c["ranges"]["sfm"][2] == pytest.approx(1.1 * 260)


def test_hem_and_roughing_never_share_a_chart():
    # a vendor with only roughing and side rows has no HEM chart: an adaptive cut must not read them
    t = table(vendors={"kennametal": {key("rough"): [row(250)], key("side"): [row(300)]}})
    assert o.vendor_lookup(t, "kennametal", FAM, 356.0, 0.25, "adaptive", 0.05) is None
    # a vendor with only HEM rows has no roughing chart: a roughing cut must not read them
    t = table(vendors={"seco": {key("hem"): [row(560)]}})
    assert o.vendor_lookup(t, "seco", FAM, 356.0, 0.25, "rough", 0.3) is None
    # roughing reads the vendor's roughing chart first, its side-milling chart only when it has no roughing rows
    t = table(vendors={"kennametal": {key("rough"): [row(250)], key("side", "heavy"): [row(300)]}})
    assert o.vendor_lookup(t, "kennametal", FAM, 356.0, 0.25, "rough", 0.3)["chart_class"] == "rough"
    t = table(vendors={"seco": {key("side"): [row(300)]}})
    assert o.vendor_lookup(t, "seco", FAM, 356.0, 0.25, "rough", 0.3)["chart_class"] == "side"


def test_widening_within_the_vendor_before_giving_up():
    # rows two hardness bins away and one diameter band away are still the vendor's own chart
    t = table(vendors={"osg": {key("hem", band="1/8-3/16", hbin=9): [row(420)]}})
    b = o.vendor_lookup(t, "osg", FAM, 356.0, 0.25, "adaptive", 0.2)
    assert b["mode"] == "brand" and b["widening"] == "+ hardness bins within 100 HB"


def test_real_table_hem_and_rough_buckets_are_separate():
    t = o._limits(o.VENDOR_TABLE_DEFAULT_PATH)
    for v in t["vendors"].values():
        for k in v["cells"]:
            assert k.split("|")[3] in ("hem", "rough", "side", "slot", "finish")
    assert any(k.split("|")[3] == "rough" for k in t["vendors"]["harvey"]["cells"])
    assert any(k.split("|")[3] == "hem" for k in t["vendors"]["helical"]["cells"])
    assert t["single_value_spread"] == [0.76, 1.10]


def test_vendor_table_reproduces_the_consensus_table():
    sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "tools"))
    import build_vendor_consensus as b
    assert b.check(o._limits(o.VENDOR_TABLE_DEFAULT_PATH)) == []


# ---- the engine and the pipeline -------------------------------------------------------------------------------------

def _run(op, a, brand_text=None, family=FAM, D=0.25, z=4, stick=0.75, fusion_tool=None, **kw):
    import app
    from pipeline import CutRequest, run_cut
    prof = app.active_machine()
    return run_cut(app.physics, CutRequest(
        family=family, alloy="", tool="Carbide Endmill", diameter=D, flutes=z, flute_length=3 * D, stickout=stick,
        operation=op, aggressiveness=a, max_rpm=16000, max_hp=7, model="v2", machine_profile=prof, coating="AlTiN",
        brand=brand_text, fusion_tool=fusion_tool, **kw))


def test_17_4_adaptive_never_exceeds_the_top_of_the_vendor_range():
    """Regression (741 SFM at 100 % against 463 at 80 %): at a wider engagement the C14 bucket had rows only two hardness
    bins away, the guardrail vanished and the speed jumped to the physics value. Now every aggressiveness has a vendor
    basis and the speed stays at or under the top of its range."""
    for a in (0.8, 0.9, 0.95, 1.0):
        r = _run("Adaptive Roughing", a)
        vb = r.vendor_basis
        assert vb["mode"] in ("brand", "default", "consensus"), (a, vb)
        assert r.sfm <= vb["sfm_range"][2] * 1.001, (a, r.sfm, vb)
        assert vb["chart_class"] == "hem"


@pytest.mark.parametrize("brand_text,mode,vendor", [(None, "default", "harvey+helical"), ("Helical", "brand", "helical"),
                                                    ("Kennametal", "brand", "kennametal"), ("Klot (Amazon Ebay)", "default", "harvey+helical")])
def test_vendor_basis_on_roughing(brand_text, mode, vendor):
    r = _run("Roughing", 0.5, brand_text)
    vb = r.vendor_basis
    assert (vb["mode"], vb["vendor"], vb["chart_class"]) == (mode, vendor, "rough")
    assert vb["brand_text"] == (brand_text or None)
    lo, mid, hi = vb["sfm_range"]
    assert lo <= mid <= hi and len(vb["fz_range"]) == 3 and vb["rows"] >= 1
    assert r.sfm <= mid * 1.001   # 50 % = the middle of the range, physics may only lower it
    assert vb["note"].startswith("Vendor basis:")
    if brand_text and mode == "default":
        assert brand_text in vb["note"]


def test_aggressiveness_moves_through_the_vendor_range():
    lo = _run("Roughing", 0.0, "Kennametal")
    hi = _run("Roughing", 1.0, "Kennametal")
    assert lo.sfm <= lo.vendor_basis["sfm_range"][0] * 1.001
    assert hi.sfm <= hi.vendor_basis["sfm_range"][2] * 1.001
    assert hi.sfm > lo.sfm


def test_fusion_tool_vendor_is_the_brand():
    ft = {"type": "flat end mill", "unit": "inches", "vendor": "Kennametal",
          "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.75, "SFDM": 0.25, "LB": 0.75}}
    r = _run("Roughing", 0.5, None, fusion_tool=ft)
    assert r.vendor_basis["mode"] == "brand" and r.vendor_basis["vendor"] == "kennametal"
    assert r.vendor_basis["brand_source"] == "fusion vendor"


def test_v1_result_has_a_none_basis():
    import app
    from pipeline import CutRequest, run_cut
    r = run_cut(app.physics, CutRequest(family=FAM, diameter=0.25, operation="Roughing", model="v1", brand="Helical"))
    assert r.vendor_basis["mode"] == "none" and r.vendor_basis["brand_text"] == "Helical"


def test_operation_map_keeps_hem_and_traditional_roughing_apart():
    import v2_bridge
    m = v2_bridge.OPERATION_MAP
    for name in ("adaptive roughing", "2d adaptive clearing", "3d adaptive clearing", "trochoidal", "dynamic milling", "hem"):
        assert m[name] == "adaptive", name
    for name in ("roughing", "standard roughing", "pocket", "2d pocket", "pocket clearing", "2d contour (roughing)"):
        assert m[name] == "rough", name


def test_api_calculate_takes_brand_and_returns_vendor_basis():
    import app
    body = {"family": FAM, "alloy": "", "tool": "Carbide Endmill", "coating": "AlTiN", "geometry": "Square",
            "operation": "Adaptive Roughing", "diameter": 0.25, "flutes": 4, "fluteLength": 0.75, "stickout": 0.75,
            "aggressiveness": 50, "model": "v2", "brand": "Kyocera SGS"}
    with app.app.test_client() as c:
        d = c.post("/api/calculate", json=body, headers=HDR).get_json()
        assert d["success"] and d["vendor_basis"]["mode"] == "brand" and d["vendor_basis"]["vendor"] == "kyocera_sgs"
        d = c.post("/api/calculate_for_fusion", json=dict(body, brand=""), headers=HDR).get_json()
        assert d["success"] and d["vendor_basis"]["brand_text"] is None and d["vendor_basis"]["mode"] in ("default", "consensus")


def test_mcp_and_advisor_tools_accept_brand():
    import mcp_server
    schema = next(t for t in mcp_server.MCP_TOOLS if t["name"] == "toolwiz_calculate_cut")["inputSchema"]
    assert "brand" in schema["properties"]
    out = mcp_server.call_mcp_tool_by_name("toolwiz_calculate_cut", {"family": FAM, "diameter": 0.25, "operation": "Roughing",
                                                                     "model": "v2", "brand": "Helical"})
    assert out["vendor_basis"]["vendor"] == "helical"
    from advisor_chat import tools as T
    specs = {t.name: t for t in T.TOOLS}
    assert "brand" in specs["toolwiz_calculate"].input_schema["properties"]
    assert "brand" in specs["runout_sensitivity"].input_schema["properties"]


def test_setup_advisor_brand_assumption():
    import setup_advisor as sa
    assert "brand" in sa.ASSUMPTION_KEYS
    rec = sa.normalize_assumption({"key": "brand", "value": "Helical"})
    assert rec["value"] == "Helical" and rec["override"] is False
    assert sa.parse_tool({"vendor": "Harvey Tool", "geometry": {"DC": 0.25, "NOF": 3, "LCF": 0.75}})["vendor"] == "Harvey Tool"
