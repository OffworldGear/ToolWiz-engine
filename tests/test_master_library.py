"""Master library builder (WP-B5): merge, stickout variants, preset generation, rebuild, job API, material sets.

The owner's real libraries in data/shop_library/ are read-only fixtures.
"""
import copy
import glob
import json
import math
import os
import threading
import time

import pytest

import app as app_module
import master_library as ml
from app import app
from backup_manager import BackupManager
from tool_merger import compute_tool_signature, merge_presets_lists, clean_tool_presets

HDR = {"X-ToolWiz-Client": "x"}
LIB_DIR = os.path.join(os.path.dirname(__file__), "..", "data", "shop_library")
SOURCES = {"Main_Milling": "hub", "Master_Shop": "local", "Offworldgear": "cloud"}


def _libraries():
    out = []
    for path in sorted(glob.glob(os.path.join(LIB_DIR, "*.json"))):
        with open(path, encoding="utf-8") as f:
            d = json.load(f)
        src = next(v for k, v in SOURCES.items() if os.path.basename(path).startswith(k))
        out.append({"library_name": d["library_name"], "source": src, "tools": d["tools"]})
    return out


@pytest.fixture(scope="module")
def merged():
    return ml.merge_libraries(copy.deepcopy(_libraries()))


@pytest.fixture()
def client(monkeypatch, tmp_path):
    monkeypatch.setattr(app_module, "bm", BackupManager(base_dir=str(tmp_path)))
    return app.test_client()


def _one_of_each(tools, types):
    out = []
    for ty in types:
        out.append(copy.deepcopy(next(t for t in tools if t["type"] == ty)))
    return out


TYPES = ["flat end mill", "bull nose end mill", "ball end mill", "slot mill", "drill", "lollipop mill"]


def _sets(ids=None, materials=None):
    return ml.select_sets(ml.load_material_sets(None), ids, materials)


def _build(tools, sets, **kw):
    kw.setdefault("strategies", list(ml.END_MILL_STRATEGIES))
    return ml.build_libraries(tools, [], sets, aggressiveness=50, physics=app_module.physics, max_rpm=16000,
                              max_hp=10, runout=0.0002, **kw)


def _audit(lib, **kw):
    return ml.audit_and_prune(lib, app_module.physics, aggressiveness=50, max_rpm=16000, max_hp=10,
                              runout=0.0002, **kw)


# ---------------------------------------------------------------- material sets
def test_default_material_sets_resolve_and_match_the_plan():
    doc = ml.load_material_sets(None)
    norm, errors = ml.validate_material_sets(doc, app_module.physics)
    assert errors == []
    ids = {s["id"]: [m["id"] for m in s["materials"]] for s in norm["sets"]}
    assert [s["name"] for s in norm["sets"]] == ["ToolWiz - Non-ferrous", "ToolWiz - Steels & exotics"]
    assert len(ids["non_ferrous"]) == 6 and len(ids["steels_exotics"]) == 10
    for s in norm["sets"]:
        for m in s["materials"]:
            if m["alloy"]:
                assert app_module.physics.resolve_alloy_hardness(m["family"], m["alloy"]) > 0, m
    # label is unique inside a set (it is the preset-name prefix)
    for s in norm["sets"]:
        labels = [m["label"] for m in s["materials"]]
        assert len(labels) == len(set(labels))


def test_material_sets_endpoint_roundtrip_and_validation(client):
    r = client.get("/api/twin/material_sets")
    assert r.status_code == 200 and r.get_json()["source"] == "default"
    doc = r.get_json()["material_sets"]
    bad = copy.deepcopy(doc)
    bad["sets"][0]["materials"][0]["alloy"] = "not an alloy"
    r = client.post("/api/twin/material_sets", json=bad, headers=HDR)
    assert r.status_code == 400 and "errors" in r.get_json()
    bad2 = copy.deepcopy(doc)
    bad2["sets"][0]["materials"][0]["family"] = "No Such Family"
    assert client.post("/api/twin/material_sets", json=bad2, headers=HDR).status_code == 400
    assert client.post("/api/twin/material_sets", json={"sets": []}, headers=HDR).status_code == 400
    good = copy.deepcopy(doc)
    good["sets"][0]["materials"] = good["sets"][0]["materials"][:2]
    r = client.post("/api/twin/material_sets", json=good, headers=HDR)
    assert r.status_code == 200 and r.get_json()["source"] == "user"
    got = client.get("/api/twin/material_sets").get_json()
    assert got["source"] == "user" and len(got["material_sets"]["sets"][0]["materials"]) == 2
    r = client.post("/api/twin/material_sets", json={"reset": True}, headers=HDR)
    assert r.get_json()["source"] == "default"


# ---------------------------------------------------------------- merge
def test_merge_all_three_libraries_with_provenance(merged):
    out, rep = merged
    assert [s["library_name"] for s in rep["sources"]] == [l["library_name"] for l in _libraries()]
    assert [s["source"] for s in rep["sources"]] == ["hub", "local", "cloud"]
    assert rep["tools_in"] == sum(s["tools"] for s in rep["sources"]) == 27
    assert rep["tools_out"] == len(out["tools"]) <= rep["tools_in"]
    assert rep["holders"] == 1 and len(out["holders"]) == 1
    guids = [t["guid"] for t in out["tools"]]
    assert all(guids) and len(guids) == len(set(guids))
    libs_seen = set()
    for t in out["tools"]:
        prov = t["toolwiz"]["provenance"]
        assert prov and all(p["library"] and p["source"] in ("hub", "local", "cloud") for p in prov)
        libs_seen |= set(t["toolwiz"]["libraries"])
    assert libs_seen == {l["library_name"] for l in _libraries()}
    # a duplicate across libraries keeps both provenance entries
    assert rep["duplicates_merged"] == rep["tools_in"] - rep["tools_out"]
    for d in rep["merged_details"]:
        assert d["copies_merged"] >= 2 and len(d["libraries"]) >= 1


def test_merge_reports_curator_repairs_and_never_guesses_units(merged):
    _, rep = merged
    assert rep["repaired_tools"] >= 1
    assert any("no recognisable unit" in w for r in rep["repairs"] for w in r["warnings"])
    for r in rep["repairs"]:
        assert all(c["field"] != "unit" for c in r["changes"])


def _endmill(**over):
    t = {"guid": "g-" + str(over.get("lb", 1)), "type": "flat end mill", "unit": "inches", "description": "1/4 flat",
         "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.75, "SFDM": 0.25, "LB": over.get("lb", 1.0), "OAL": 3.0,
                      "shoulder-length": 0.75, "shoulder-diameter": 0.25},
         "post-process": {"number": 1}, "start-values": {"presets": over.get("presets", [])}}
    return t


def test_stickout_variants_stay_separate_and_are_named(merged):
    a, b, c = _endmill(lb=1.0), _endmill(lb=1.08), _endmill(lb=1.5)
    for t, g in ((a, "a"), (b, "b"), (c, "c")):
        t["guid"] = g
    libs = [{"library_name": "L1", "source": "document", "tools": [a]},
            {"library_name": "L2", "source": "cloud", "tools": [b, c]}]
    out, rep = ml.merge_libraries(libs, repair=False)
    assert rep["tools_in"] == 3 and rep["tools_out"] == 2       # 1.0 and 1.08 merge (8%), 1.5 is 50% longer
    descs = sorted(t["description"] for t in out["tools"])
    assert len(set(descs)) == 2 and all("[stickout" in d for d in descs)
    assert any("1.000 in" in d for d in descs) and any("1.500 in" in d for d in descs)
    assert len(rep["stickout_variants"]) == 1
    merged_tool = next(t for t in out["tools"] if "1.000 in" in t["description"])
    assert merged_tool["toolwiz"]["libraries"] == ["L1", "L2"]
    assert all(t["toolwiz"]["stickout_variant"] for t in out["tools"])
    # exactly 10% is still the same entry; just over is not
    f = lambda lb: ml._stickout_facts(_endmill(lb=lb))
    assert not ml.stickout_differs(f(1.0), f(1.1111))
    assert ml.stickout_differs(f(1.0), f(1.13))
    # assembly gauge counts as well
    g1, g2 = _endmill(lb=1.0), _endmill(lb=1.0)
    g1["geometry"]["assemblyGaugeLength"], g2["geometry"]["assemblyGaugeLength"] = 3.0, 4.0
    assert ml.stickout_differs(ml._stickout_facts(g1), ml._stickout_facts(g2))


def test_dedupe_keeps_all_presets_of_the_copies():
    p1 = {"guid": "p1", "name": "Rough", "n": 5000, "v_f": 40, "f_z": 0.002, "material": {"query": "Al"}}
    p2 = {"guid": "p2", "name": "Rough", "n": 7000, "v_f": 60, "f_z": 0.002, "material": {"query": "Al"}}
    dup = copy.deepcopy(p1)
    merged = merge_presets_lists([p1, copy.deepcopy(p1)], [dup, p2])
    assert [p["name"] for p in merged] == ["Rough", "Rough", "Rough (3)"]    # primary kept whole, true duplicate dropped
    assert merged[2]["guid"] != "p2" and merged[2]["v_f"] == 60


def test_signature_separates_form_tools_that_used_to_merge():
    def tool(typ, **geo):
        g = {"DC": 0.5, "NOF": 2, "LCF": 0.5, "SFDM": 0.5}
        g.update(geo)
        return {"type": typ, "unit": "inches", "geometry": g}
    assert compute_tool_signature(tool("chamfer mill", TA=30)) != compute_tool_signature(tool("chamfer mill", TA=45))
    assert compute_tool_signature(tool("drill", SIG=118)) != compute_tool_signature(tool("drill", SIG=135))
    assert compute_tool_signature(tool("tap right hand", TP=0.05)) != compute_tool_signature(tool("tap right hand", TP=0.0625))
    assert compute_tool_signature(tool("tapered mill")) != compute_tool_signature(tool("tap right hand"))
    assert compute_tool_signature(tool("spot drill")) != compute_tool_signature(tool("drill"))
    assert compute_tool_signature(tool("flat end mill")) == compute_tool_signature(tool("flat end mill"))


def test_clean_presets_is_not_a_substring_match():
    t = {"start-values": {"presets": [
        {"name": "6304 steel finishing - mine", "material": {"query": ""}},
        {"name": "304 - Roughing", "material": {"query": "304"}, "toolwiz": {"material": "304"}},
        {"name": "Ti-6Al-4V - Roughing", "material": {"query": "Ti-6Al-4V"}}]}}
    out, removed = clean_tool_presets(t, target_material_to_replace="304")
    assert removed == 1
    assert [p["name"] for p in out["start-values"]["presets"]] == ["6304 steel finishing - mine", "Ti-6Al-4V - Roughing"]


# ---------------------------------------------------------------- generation
def test_generation_for_both_sets_is_clean_and_in_the_tool_unit(merged):
    out, _ = merged
    tools = _one_of_each(out["tools"], TYPES)
    # make sure both unit systems are covered (Ti library has inch and mm tools of the common types)
    mm_flat = next(copy.deepcopy(t) for t in out["tools"] if t["type"] == "flat end mill" and t["unit"] == "millimeters")
    tools.append(mm_flat)
    units = {t["unit"] for t in tools}
    assert units == {"inches", "millimeters"}
    libs = _build(tools, _sets())
    assert [l["name"] for l in libs] == ["ToolWiz - Non-ferrous", "ToolWiz - Steels & exotics"]
    for lib in libs:
        audit = _audit(lib)
        assert audit["summary"]["toolwiz_STOP"] == 0
        assert lib["toolwiz_presets"] > 0
        mats = {m["label"] for m in next(s for s in _sets() if s["id"] == lib["id"])["materials"]}
        for t in lib["tools"]:
            presets = [p for p in t["start-values"]["presets"] if ml.is_toolwiz_preset(p)]
            names = [p["name"] for p in presets]
            assert len(names) == len(set(names)), names
            kind = t["type"]
            if kind in ("lollipop mill",):
                assert not presets
                continue
            assert presets, kind
            d_native = float(t["geometry"]["DC"])
            for p in presets:
                assert p["name"].split(" - ")[0] in mats
                tag = p["toolwiz"]
                assert tag["generator"] == ml.GENERATOR and tag["aggressiveness"] == 50.0 and tag["model"]
                assert tag["material"] == p["material"]["query"]
                assert "Aggressiveness: 50%" in p["description"] and "stickout" in p["description"]
                assert p["n"] > 0 and p["v_f"] > 0 and p["v_c"] > 0
                if kind != "drill":
                    # n x f_z x flutes = v_f in the tool's unit (mm/min for a mm tool)
                    flutes = t["geometry"]["NOF"]
                    assert p["v_f"] == pytest.approx(p["n"] * p["f_z"] * flutes, rel=0.02), p["name"]
                    assert p["stepdown"] > 0 and p["stepover"] > 0
                if kind in ("flat end mill", "bull nose end mill"):
                    # surface speed at the nominal diameter: ft/min for inch tools, m/min for mm tools
                    expect = math.pi * d_native * p["n"] / (12.0 if t["unit"] == "inches" else 1000.0)
                    assert p["v_c"] == pytest.approx(expect, rel=0.03), (t["description"], p["name"])
                    if t["unit"] == "millimeters":
                        assert p["stepdown"] <= float(t["geometry"]["LCF"]) * 1.001      # mm, not inches
                        assert p["stepover"] <= d_native * 1.001
                    # a 1/4" - 6 mm class tool: chip load in mm is ~25x the inch value, so never < 0.001 mm
                    if t["unit"] == "millimeters":
                        assert p["f_z"] > 0.001
            if kind == "slot mill":
                assert any(p["operation_type"] == "T-Slot Full Slot" for p in presets)
                assert not any(p["operation_type"] in ml.END_MILL_STRATEGIES for p in presets)
            if kind == "drill":
                assert all(p["name"].endswith(" - Drilling") for p in presets)


def test_generated_presets_use_the_tools_real_stickout(merged):
    out, _ = merged
    t = copy.deepcopy(next(t for t in out["tools"] if t["type"] == "flat end mill" and t["unit"] == "inches"))
    short, long_ = copy.deepcopy(t), copy.deepcopy(t)
    short["geometry"]["LB"] = float(t["geometry"]["LCF"]) * 1.1
    long_["geometry"]["LB"] = float(t["geometry"]["DC"]) * 8
    mats = [{"id": "ti64", "label": "Ti-6Al-4V", "family": "Titanium Alloy", "alloy": "Ti-6Al-4V (Grade 5) Annealed"}]
    kw = dict(physics=app_module.physics, max_rpm=16000, max_hp=10, runout=0.0002)
    ps, _ = ml.generate_presets(short, mats, ["Roughing"], 0.5, **kw)
    pl, _ = ml.generate_presets(long_, mats, ["Roughing"], 0.5, **kw)
    assert ps[0]["toolwiz"]["stickout_in"] < pl[0]["toolwiz"]["stickout_in"]
    assert pl[0]["v_f"] <= ps[0]["v_f"] and (pl[0]["stepdown"] < ps[0]["stepdown"] or pl[0]["v_f"] < ps[0]["v_f"])


def test_cache_is_used_across_identical_tools(merged):
    out, _ = merged
    t1 = copy.deepcopy(next(t for t in out["tools"] if t["type"] == "flat end mill"))
    t2 = copy.deepcopy(t1)
    t2["guid"] = "other"
    cache = {}
    mats = _sets(["non_ferrous"], ["al6061"])[0]["materials"]
    kw = dict(physics=app_module.physics, max_rpm=16000, max_hp=10, runout=0.0002, cache=cache)
    ml.generate_presets(t1, mats, ["Roughing"], 0.5, **kw)
    n = len(cache)
    assert n >= 1
    ml.generate_presets(t2, mats, ["Roughing"], 0.5, **kw)
    assert len(cache) == n


# ---------------------------------------------------------------- rebuild
def test_rebuild_replaces_toolwiz_presets_and_keeps_the_owners(merged):
    out, _ = merged
    tools = _one_of_each(out["tools"], ["flat end mill", "ball end mill"])
    mine = {"guid": "mine-1", "name": "My Ti trick", "n": 1234, "v_f": 12.5, "f_z": 0.003,
            "material": {"category": "all", "query": "Ti-6Al-4V", "use-hardness": False},
            "expressions": {"tool_feedCutting": "12.5 ipm"}}
    clash = {"guid": "mine-2", "name": "Ti-6Al-4V - Roughing", "n": 999, "v_f": 9, "f_z": 0.001,
             "material": {"query": "Ti-6Al-4V"}}
    tools[0]["start-values"]["presets"] = [mine, clash] + tools[0]["start-values"]["presets"]
    own_before = [copy.deepcopy(p) for t in tools for p in t["start-values"]["presets"]]
    sets = _sets(["steels_exotics"], ["ti64", "ss316"])
    first = _build(tools, sets)[0]
    n_tw = first["toolwiz_presets"]
    assert n_tw > 0
    # the owner's presets are byte-identical, the clash keeps its name and ours is renamed
    flat = first["tools"][0]["start-values"]["presets"]
    assert next(p for p in flat if p.get("guid") == "mine-1") == mine
    assert next(p for p in flat if p.get("guid") == "mine-2") == clash
    assert any(p["name"] == "Ti-6Al-4V - Roughing (ToolWiz)" for p in flat)
    for p in own_before:
        assert any(q == p for t in first["tools"] for q in t["start-values"]["presets"])
    # rebuild from the built library: old ToolWiz presets are replaced, not duplicated
    rebuilt_in, _ = ml.merge_libraries([{"library_name": "ToolWiz - Steels & exotics", "source": "document",
                                         "tools": first["tools"]}], repair=False)
    second = _build(rebuilt_in["tools"], sets, now=None)[0]
    assert second["toolwiz_presets"] == n_tw
    assert second["removed_old_toolwiz"] == n_tw
    for t in second["tools"]:
        tw = [p for p in t["start-values"]["presets"] if ml.is_toolwiz_preset(p)]
        assert len({p["guid"] for p in tw}) == len(tw)
    flat2 = second["tools"][0]["start-values"]["presets"]
    assert next(p for p in flat2 if p.get("guid") == "mine-1") == mine
    assert sum(1 for p in flat2 if p.get("guid") in ("mine-1", "mine-2")) == 2
    # fewer materials on a later build: the other ToolWiz presets disappear
    third = _build(second["tools"], _sets(["steels_exotics"], ["ti64"]))[0]
    mats = {p["toolwiz"]["material"] for t in third["tools"] for p in t["start-values"]["presets"] if ml.is_toolwiz_preset(p)}
    assert mats == {"Ti-6Al-4V"}


# ---------------------------------------------------------------- job API
def _wait(client, job_id, timeout=120):
    t0 = time.time()
    while time.time() - t0 < timeout:
        s = client.get(f"/api/twin/build_sets/{job_id}").get_json()
        if s["state"] in ("done", "error"):
            return s
        time.sleep(0.05)
    raise AssertionError("job did not finish")


def test_job_api_happy_path(client):
    libs = _libraries()
    body = {"libraries": libs, "filter": {"types": ["flat end mill", "slot mill", "drill"], "diameter_max": 0.5},
            "materials": ["al6061", "ti64"], "strategies": ["Roughing", "Finishing"], "aggressiveness": 50}
    r = client.post("/api/twin/build_sets", json=body, headers=HDR)
    assert r.status_code == 202, r.get_json()
    jid = r.get_json()["job_id"]
    n_tools = r.get_json()["tools"]
    assert 1 <= n_tools <= 12
    s = _wait(client, jid)
    assert s["state"] == "done", s
    assert s["progress"]["tools_done"] == s["progress"]["tools_total"] == n_tools and s["progress"]["percent"] == 100
    res = s["result"]
    assert [l["id"] for l in res["libraries"]] == ["non_ferrous", "steels_exotics"]
    for lib in res["libraries"]:
        assert lib["tool_count"] == n_tools and lib["toolwiz_preset_count"] > 0
        assert lib["audit"]["summary"]["toolwiz_STOP"] == 0
        assert lib["materials"] and isinstance(lib["skipped"], list)
        assert lib["backup"]["filename"]
        d = client.get(lib["download_url"])
        assert d.status_code == 200
        data = json.loads(d.data)
        assert list(data) == ["data"] and len([t for t in data["data"] if t["type"] != "holder"]) == n_tools
        names = {p["name"].split(" - ")[0] for t in data["data"] for p in t.get("start-values", {}).get("presets", []) if "toolwiz" in p}
        assert names <= {"6061-T6", "Ti-6Al-4V"}
    # per-set download by library name, and the builds show in the backups
    d = client.get(f"/api/twin/build_sets/{jid}/download?set=ToolWiz - Non-ferrous")
    assert d.status_code == 200
    backups = [b["library_name"] for b in client.get("/api/twin/backups").get_json()["backups"]]
    assert "ToolWiz - Non-ferrous" in backups and "ToolWiz - Steels & exotics" in backups
    assert client.get(f"/api/twin/build_sets/{jid}/download").status_code == 400       # two libraries, no ?set=
    assert client.get(f"/api/twin/build_sets/{jid}/download?set=nope").status_code == 404


def test_job_progress_and_download_before_done(client, monkeypatch):
    gate, started = threading.Event(), threading.Event()
    real = ml.build_libraries

    def slow(tools, holders, sets, **kw):
        prog = kw["progress"]
        prog(0, len(tools), tools[0]["description"])
        started.set()
        gate.wait(10)
        return real(tools, holders, sets, **kw)
    monkeypatch.setattr(ml, "build_libraries", slow)
    body = {"libraries": _libraries(), "filter": {"types": ["ball end mill"]}, "sets": ["non_ferrous"],
            "materials": ["al6061"], "strategies": ["Finishing"]}
    jid = client.post("/api/twin/build_sets", json=body, headers=HDR).get_json()["job_id"]
    assert started.wait(10)
    s = client.get(f"/api/twin/build_sets/{jid}").get_json()
    assert s["state"] == "running" and s["progress"]["current_tool"] and "result" not in s
    assert client.get(f"/api/twin/build_sets/{jid}/download").status_code == 409
    gate.set()
    assert _wait(client, jid)["state"] == "done"


@pytest.mark.parametrize("patch", [
    {"sets": ["nope"]}, {"materials": ["nope"]}, {"strategies": ["Plunge"]}, {"strategies": []},
    {"aggressiveness": 0}, {"aggressiveness": 250}, {"aggressiveness": "fast"}, {"runout": -1},
    {"filter": {"types": ["no such tool"]}}, {"filter": []}, {"filter": {"diameter_min": "big"}},
    {"filter": {"tool_ids": "abc"}}, {"libraries": "x"}, {"libraries": [{"library_name": "a"}]},
    {"sets": "non_ferrous"},
])
def test_job_api_bad_input_is_400(client, patch):
    body = {"libraries": _libraries()}
    body.update(patch)
    r = client.post("/api/twin/build_sets", json=body, headers=HDR)
    assert r.status_code == 400, (patch, r.status_code, r.get_json())
    assert r.get_json()["success"] is False and r.get_json()["error"]


def test_job_api_without_tools_and_unknown_job(client):
    r = client.post("/api/twin/build_sets", json={}, headers=HDR)
    assert r.status_code == 400 and "No tools" in r.get_json()["error"]
    assert client.get("/api/twin/build_sets/zzz").status_code == 404
    assert client.get("/api/twin/build_sets/zzz/download").status_code == 404
    assert client.post("/api/twin/build_sets", data="not json", headers=HDR).status_code == 400


def test_job_uses_the_working_library_when_no_libraries_are_sent(client):
    lib = _libraries()[0]
    app_module.bm.save_working_library({"library_name": "WL", "tools": lib["tools"]}, "WL")
    r = client.post("/api/twin/build_sets", json={"sets": ["non_ferrous"], "materials": ["al6061"],
                                                  "strategies": ["Roughing"]}, headers=HDR)
    assert r.status_code == 202
    s = _wait(client, r.get_json()["job_id"])
    assert s["state"] == "done" and s["result"]["merge"]["sources"][0]["source"] == "working"


def test_merge_endpoint_preview_and_save(client):
    body = {"libraries": _libraries()}
    r = client.post("/api/twin/master_library/merge", json=body, headers=HDR)
    j = r.get_json()
    assert r.status_code == 200 and j["tools_out"] <= j["tools_in"] == 27 and "backup" not in j
    assert app_module.bm.load_working_library() is None
    body["save_working"] = True
    j = client.post("/api/twin/master_library/merge", json=body, headers=HDR).get_json()
    assert j["backup"]["filename"]
    wl = app_module.bm.load_working_library()
    assert wl["library_name"] == "Master_Shop_Tool_Crib" and len(wl["tools"]) == j["tools_out"] + j["holders"]


# ---------------------------------------------------------------- existing Digital Twin fixes
def _seed(client, n=3):
    tools = [_endmill(lb=1.0 + i) for i in range(n)]
    for i, t in enumerate(tools):
        t["guid"] = f"guid-{i}"
        t["description"] = f"tool {i}"
        t["start-values"]["presets"] = [{"guid": f"pg-{i}", "name": "P", "n": 1000, "v_f": 10, "f_z": 0.0025}]
    app_module.bm.save_working_library({"library_name": "Seed", "tools": tools}, "Seed")


def test_tools_are_addressed_by_guid_and_survive_deletes(client):
    _seed(client)
    r = client.post("/api/twin/delete_tool", json={"tool_guid": "guid-0"}, headers=HDR)
    assert r.status_code == 200 and r.get_json()["deleted_guid"] == "guid-0"
    # index 0 is now guid-1; a guid-addressed update still hits guid-2
    r = client.post("/api/twin/update_tool", json={"tool_guid": "guid-2", "description": "renamed"}, headers=HDR)
    assert r.status_code == 200
    descs = {t["guid"]: t["description"] for t in app_module.bm.load_working_library()["tools"]}
    assert descs == {"guid-1": "tool 1", "guid-2": "renamed"}
    assert client.post("/api/twin/delete_tool", json={"tool_guid": "guid-0"}, headers=HDR).status_code == 404
    assert client.post("/api/twin/delete_tool", json={}, headers=HDR).status_code == 400
    assert client.post("/api/twin/delete_tool", json={"tool_index": 99}, headers=HDR).status_code == 400
    assert client.get("/api/twin/tool?guid=guid-1").get_json()["tool"]["description"] == "tool 1"
    assert client.get("/api/twin/tool?guid=nope").status_code == 404
    m = client.get("/api/twin/load").get_json()["tools"]
    assert [t["guid"] for t in m] == ["guid-1", "guid-2"]


def test_delete_preset_by_guid_and_404s(client):
    _seed(client)
    r = client.post("/api/twin/delete_preset", json={"tool_guid": "guid-1", "preset_guid": "pg-1"}, headers=HDR)
    assert r.status_code == 200
    assert client.post("/api/twin/delete_preset", json={"tool_guid": "guid-1", "preset_guid": "pg-1"},
                       headers=HDR).status_code == 404
    assert client.post("/api/twin/delete_preset", json={"tool_guid": "guid-1", "preset_guid": ""},
                       headers=HDR).status_code == 400
    assert client.post("/api/twin/delete_preset", json={"preset_guid": "pg-1"}, headers=HDR).status_code == 400


def test_update_tool_number_uses_the_fusion_key(client):
    _seed(client)
    client.post("/api/twin/update_tool", json={"tool_guid": "guid-0", "number": 42}, headers=HDR)
    t = app_module.bm.load_working_library()["tools"][0]
    assert t["post-process"]["number"] == 42 and "postProcess" not in t


def test_export_receive_refuses_an_empty_harvest_and_fixes_guids(client):
    _seed(client)
    r = client.post("/api/twin/export_receive", json={"libraries": [{"library_name": "x", "tools": []}]}, headers=HDR)
    assert r.status_code == 400
    assert len(app_module.bm.load_working_library()["tools"]) == 3            # not wiped
    t1, t2 = _endmill(), _endmill()
    t1["guid"] = t2["guid"] = ""
    r = client.post("/api/twin/export_receive", json={"libraries": [{"library_name": "x", "tools": [t1, t2]}]},
                    headers=HDR)
    assert r.status_code == 200
    guids = [t["guid"] for t in app_module.bm.load_working_library()["tools"]]
    assert all(guids) and len(set(guids)) == 2


def test_batch_generate_tags_presets_and_keeps_an_owners_same_named_preset(client):
    _seed(client, 1)
    wl = app_module.bm.load_working_library()
    wl["tools"][0]["start-values"]["presets"].append(
        {"guid": "own", "name": "6061-T6 - Roughing", "n": 1, "v_f": 1, "f_z": 0.001})
    app_module.bm.save_working_library(wl, "Seed")
    body = {"tool_guids": ["guid-0"], "family": "Aluminum - Wrought (6061)", "alloy": "6061-T6",
            "strategies": ["Roughing"], "clean_existing_for_material": False}
    for _ in range(2):                                   # twice: the second run replaces, never piles up
        r = client.post("/api/twin/batch_generate", json=body, headers=HDR)
        assert r.status_code == 200 and r.get_json()["total_presets_injected"] == 1
    presets = app_module.bm.load_working_library()["tools"][0]["start-values"]["presets"]
    assert next(p for p in presets if p["guid"] == "own")["n"] == 1
    mine = [p for p in presets if ml.is_toolwiz_preset(p)]
    assert len(mine) == 1 and mine[0]["name"] == "6061-T6 - Roughing (ToolWiz)"
    assert mine[0]["toolwiz"]["strategy"] == "Roughing"


def test_batch_generate_replaces_a_stale_preset_without_leaving_its_expressions(client):
    _seed(client, 1)
    wl = app_module.bm.load_working_library()
    wl["tools"][0]["start-values"]["presets"] = [
        {"guid": "old", "name": "6061-T6 - Roughing", "operation_type": "Roughing", "n": 1, "v_f": 1,
         "expressions": {"tool_feedCutting": "1 ipm"}}]
    app_module.bm.save_working_library(wl, "Seed")
    client.post("/api/twin/batch_generate", json={"tool_indices": "all", "family": "Aluminum - Wrought (6061)",
                                                  "alloy": "6061-T6", "strategies": ["Roughing"],
                                                  "clean_existing_for_material": False}, headers=HDR)
    p = app_module.bm.load_working_library()["tools"][0]["start-values"]["presets"][0]
    assert p["guid"] == "old" and "expressions" not in p and p["n"] > 1000


def test_backup_versions_keep_increasing_after_pruning(tmp_path):
    bm = BackupManager(base_dir=str(tmp_path), max_backups=2)
    versions = [bm.create_backup("Lib", {"tools": []})["version"] for _ in range(5)]
    assert versions == [1, 2, 3, 4, 5]


def test_aggressiveness_normalisation():
    n = ml.normalize_aggressiveness
    assert n(1) == 0.01 and n(1.0) == 1.0 and n(50) == 0.5 and n(50.0) == 0.5 and n(0.75) == 0.75
