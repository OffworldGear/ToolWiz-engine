"""Tests for toolwiz_common.tooling_advisor, the generated series-performance data and /api/advice/*."""
import glob
import json
import math
import os
import subprocess
import sys

import pytest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, ROOT)

from toolwiz_common import tooling_advisor as adv  # noqa: E402

HDR = {"X-ToolWiz-Client": "unit-test"}
CONTRACT = {"required_tir_in", "class", "recommended", "acceptable", "avoid", "reason",
            "high_speed_spindle", "sources"}


def _all_row_ids():
    ids = set()
    for f in glob.glob(os.path.join(ROOT, "tests", "benchmarks", "v2", "*.json")):
        with open(f, encoding="utf-8") as fh:
            ids.update(r["id"] for r in json.load(fh)["rows"])
    return ids


def test_required_tir_formula():
    assert adv.required_tir_in(0.0002, 2) == pytest.approx(0.25 * 0.0002)
    assert adv.required_tir_in(0.003, 4) == pytest.approx(0.25 * 0.003 / math.sin(math.pi / 4))


def test_micro_tool_needs_ultra_class():
    r = adv.holder_advice(1 / 32, 0.0002, 0.0002, 2, 16000, "slot", 0.2)
    assert set(r) == CONTRACT
    assert r["class"] == "ultra"
    for name in ("shrink fit", "hydraulic", "powRgrip"):
        assert name in r["recommended"]
    assert "standard ER collet" in r["avoid"]
    assert "standard ER collet" not in r["recommended"] + r["acceptable"]
    assert "indicator" in r["reason"]


def test_half_inch_four_flute_accepts_standard_er():
    r = adv.holder_advice(0.5, 0.0003, 0.003, 4, 8000, "side", 1.5)
    assert r["class"] == "standard"
    assert "standard ER collet" in r["recommended"] + r["acceptable"]
    assert "Weldon/side-lock holder" in r["avoid"]
    assert r["high_speed_spindle"] is None


def test_heavy_roughing_prefers_stiff_holders_over_hydraulic():
    r = adv.holder_advice(0.5, 0.0002, 0.004, 4, 8000, "rough", 1.5)
    assert "shrink fit" in r["recommended"] and "milling chuck" in r["recommended"]
    assert "hydraulic" not in r["recommended"]
    assert "hydraulic" in r["acceptable"]
    assert "pull-out" in r["reason"]


def test_small_tool_roughing_does_not_trigger_heavy_rule():
    r = adv.holder_advice(0.25, 0.0002, 0.001, 4, 8000, "rough", 1.0)
    assert "hydraulic" in r["recommended"] + r["acceptable"]


def test_speeder_for_micro_tool_capped_at_16k():
    r = adv.holder_advice(1 / 32, 0.0002, 0.0002, 2, 16000, "slot", 0.2, max_rpm=16000, sfm_target=500)
    assert r["high_speed_spindle"]
    assert "BIG KAISER" in r["high_speed_spindle"] and "Nakanishi" in r["high_speed_spindle"]
    assert any("static.machinetools.com" in s or "nakanishi" in s for s in r["sources"])
    # Not needed when the spindle reaches the target
    r2 = adv.holder_advice(0.25, 0.0002, 0.001, 4, 16000, "side", 1.0, max_rpm=16000, sfm_target=900)
    assert r2["high_speed_spindle"] is None


def test_holder_input_validation():
    with pytest.raises(ValueError):
        adv.holder_advice(0, 0.0002, 0.001, 2, 8000, "side", 1.0)
    with pytest.raises(ValueError):
        adv.holder_advice(0.25, 0.0002, 0.0, 2, 8000, "side", 1.0)


def test_runout_summary():
    s = adv.runout_summary(0.25, 0.0004, 0.001, 4)
    assert s["ok"] is False
    assert s["ratio"] == pytest.approx(0.0004 * math.sin(math.pi / 4) / 0.001)


def test_data_driven_tool_advice_evidence_exists():
    ids = _all_row_ids()
    seen = 0
    for fam, d, op in (("Steel - Medium Carbon Alloy (4130)", 0.25, "hem"),
                       ("Stainless - 300 Series (316)", 0.125, "side"),
                       ("Titanium Alloy", 0.25, "hem")):
        out = adv.tool_advice(fam, d, op)
        assert 0 < len(out) <= 4
        for t in out:
            assert set(t) == {"vendor", "series", "applies_to", "why", "expected_gain", "evidence"}
            for e in t["evidence"]:
                assert e in ids
                seen += 1
    assert seen > 0


def test_performance_json_meets_rule():
    with open(os.path.join(ROOT, "data", "tool_series_performance.json"), encoding="utf-8") as fh:
        perf = json.load(fh)
    ids = _all_row_ids()
    for key, b in perf["buckets"].items():
        for e in b["recommended"]:
            assert e["gain_vs_bucket_median"] >= 1.3
            assert e["rows"] >= 2
            assert set(e["evidence"]) <= ids


def test_generator_is_deterministic(tmp_path):
    path = os.path.join(ROOT, "data", "tool_series_performance.json")
    before = open(path, "rb").read()
    subprocess.run([sys.executable, os.path.join(ROOT, "tools", "build_tool_series_performance.py")],
                   check=True, capture_output=True)
    assert open(path, "rb").read() == before


def test_curated_notes_have_citations_and_no_prices():
    with open(os.path.join(ROOT, "data", "tool_series.json"), encoding="utf-8") as fh:
        notes = json.load(fh)["series"]
    for s in notes:
        assert s["citation_url"].startswith("https://")
        assert "$" not in json.dumps(s)
    with open(os.path.join(ROOT, "data", "holders.json"), encoding="utf-8") as fh:
        holders = json.load(fh)
    for h in holders["holders"]:
        assert h["tir_mm"] > 0 and h["sources"]
        assert all(s in holders["sources"] for s in h["sources"])


def test_curated_tslot_and_micro_aluminum():
    t = adv.tool_advice("Aluminum - Wrought (6061)", 0.25, "tslot")
    assert t and "Keyseat" in t[0]["series"] and "harveytool.com" in t[0]["why"]
    a = adv.tool_advice("Aluminum - Wrought (6061)", 1 / 16, "slot")
    assert a and all(x["vendor"] for x in a)


def test_tool_advice_bad_operation():
    with pytest.raises(ValueError):
        adv.tool_advice("Aluminum - Wrought (6061)", 0.25, "bogus")


# ------------------------------------------------------------------ endpoints
@pytest.fixture(scope="module")
def client():
    from app import app
    return app.test_client()


def test_holder_endpoint(client):
    body = {"diameter": 0.03125, "runout_in": 0.0002, "fz_in": 0.0002, "rpm": 16000,
            "operation": "slot", "stickout": 0.2, "flutes": 2, "taper": "BT30", "sfm_target": 500}
    r = client.post("/api/advice/holder", json=body, headers=HDR)
    assert r.status_code == 200
    j = r.get_json()
    assert set(j) == CONTRACT and j["class"] == "ultra" and j["high_speed_spindle"]


def test_holder_endpoint_bad_input(client):
    r = client.post("/api/advice/holder", json={"fz_in": 0.001}, headers=HDR)
    assert r.status_code == 400 and "diameter" in r.get_json()["error"]
    r = client.post("/api/advice/holder", json={"diameter": "x", "fz_in": 0.001}, headers=HDR)
    assert r.status_code == 400
    r = client.post("/api/advice/holder", json={"diameter": 0.25}, headers=HDR)
    assert r.status_code == 400 and "fz_in" in r.get_json()["error"]
    r = client.post("/api/advice/holder", data="nope", headers=HDR)
    assert r.status_code == 400
    assert client.post("/api/advice/holder", json={"diameter": 0.25, "fz_in": 0.001}).status_code == 403


def test_tools_endpoint(client):
    r = client.post("/api/advice/tools", json={"family": "Stainless - 300 Series (316)", "diameter": 0.125,
                                               "operation": "side"}, headers=HDR)
    assert r.status_code == 200
    tools = r.get_json()["tools"]
    assert isinstance(tools, list) and 0 < len(tools) <= 4
    ids = _all_row_ids()
    assert all(e in ids for t in tools for e in t["evidence"])


def test_tools_endpoint_bad_input(client):
    for body in ({"family": "x", "operation": "slot"},
                 {"diameter": 0.25, "operation": "slot"},
                 {"family": "Aluminum - Wrought (6061)", "diameter": 0.25},
                 {"family": "Aluminum - Wrought (6061)", "diameter": 0.25, "operation": "bogus"},
                 {"family": "Aluminum - Wrought (6061)", "diameter": -1, "operation": "slot"}):
        r = client.post("/api/advice/tools", json=body, headers=HDR)
        assert r.status_code == 400, body
        assert r.get_json()["error"]
