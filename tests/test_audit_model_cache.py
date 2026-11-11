"""The library audit checks a build with the build's own cutting model and reuses the build's cuts.

Uses three tools (flat end mill, slot mill, drill) of the owner's real library and two materials, so it stays
small. ``run_cut`` is counted by wrapping ``master_library.run_cut`` (the one place a cut is computed)."""
import copy
import json
import os

import pytest

import app as app_module
import library_audit as LA
import master_library as ml
from app import app
from toolwiz_common import classify, is_hole_kind, is_milling_kind, tool_unit

HDR = {"X-ToolWiz-Client": "x"}
LIB = os.path.join(os.path.dirname(__file__), "..", "data", "shop_library", "Offworldgear_TI_Steel1_Updated4_20261019_125408_v6.json")
MATERIALS = ["al6061", "ti64"]
STRATEGIES = ["Roughing", "Finishing"]
MAX_RPM, MAX_HP, RUNOUT = 16000, 10, 0.0002


def _owner_tools():
    with open(LIB, encoding="utf-8") as f:
        lib = json.load(f)
    out = []
    for ty in ("flat end mill", "slot mill", "drill"):
        out.append(copy.deepcopy(next(t for t in lib["tools"] if t.get("type") == ty)))
    return out


def _sets(materials=MATERIALS):
    return ml.select_sets(ml.load_material_sets(None), None, materials)


def _build(model, tools=None, cache=None):
    return ml.build_libraries(tools or _owner_tools(), [], _sets(), strategies=STRATEGIES, aggressiveness=50,
                              physics=app_module.physics, max_rpm=MAX_RPM, max_hp=MAX_HP, runout=RUNOUT,
                              model=model, cache=cache)


def _audit(lib, model, cache=None):
    return ml.audit_and_prune(lib, app_module.physics, aggressiveness=50, max_rpm=MAX_RPM, max_hp=MAX_HP,
                              runout=RUNOUT, model=model, cache=cache)


@pytest.fixture()
def run_cut_calls(monkeypatch):
    """Every ``run_cut`` call made through master_library, recorded as its CutRequest."""
    calls = []
    real = ml.run_cut

    def counting(physics, req):
        calls.append(req)
        return real(physics, req)

    monkeypatch.setattr(ml, "run_cut", counting)
    return calls


# ---------------------------------------------------------------- the audit uses the build's model
def test_v2_build_audits_with_v2_and_drops_no_chip_load_presets():
    libs = _build("v2")
    assert libs and all(l["toolwiz_presets"] > 0 for l in libs)
    for lib in libs:
        audit = _audit(lib, "v2")
        assert [d for d in audit["dropped"] if d["code"] == "chip_load_too_high"] == []
        assert audit["summary"]["toolwiz_STOP"] == 0


def test_audit_recommendation_matches_the_generated_chip_load_within_1_percent():
    cache = {}
    libs = _build("v2", cache=cache)
    physics = app_module.physics
    checked = 0
    for lib in libs:
        rec = LA._Recommender(physics, MAX_RPM, MAX_HP, RUNOUT, 0.5, "v2", None, cache=cache)
        for idx, tool in enumerate(lib["tools"]):
            kind = classify(tool["type"])
            if not (is_milling_kind(kind) or is_hole_kind(kind)):
                continue
            scale = 1.0 / 25.4 if tool_unit(tool) == "millimeters" else 1.0
            for p in tool["start-values"]["presets"]:
                if not ml.is_toolwiz_preset(p):
                    continue
                mat = LA.material_of_preset(p, physics)
                r = rec.get(idx, tool, kind, mat["family"], mat["alloy"], LA.classify_operation(p))
                assert r is not None, p["name"]
                fz_preset = float(p["f_z"]) * scale
                assert abs(fz_preset - r["fz_in"]) / r["fz_in"] < 0.01, (p["name"], fz_preset, r["fz_in"])
                checked += 1
    assert checked >= 2 * len(STRATEGIES)


# ---------------------------------------------------------------- the audit reuses the build's cuts
def test_audit_with_the_build_cache_computes_no_cut_the_build_already_made(run_cut_calls):
    cache = {}
    libs = _build("v2", cache=cache)
    built = len(run_cut_calls)
    assert built > 0
    run_cut_calls.clear()
    for lib in libs:
        _audit(lib, "v2", cache=cache)
    assert run_cut_calls == []          # every audited cut is one the build made


def test_audit_without_the_build_cache_recomputes(run_cut_calls):
    libs = _build("v2", cache={})
    run_cut_calls.clear()
    _audit(libs[0], "v2")
    assert len(run_cut_calls) > 0 and all(r.model == "v2" for r in run_cut_calls)


def test_audit_runs_every_cut_with_the_build_model(run_cut_calls):
    cache = {}
    libs = _build("v2", cache=cache)
    run_cut_calls.clear()
    # a cache the build did not fill (e.g. another model) must not be used for a v2 audit
    _audit(copy.deepcopy(libs[0]), "v2", cache={})
    assert run_cut_calls and {r.model for r in run_cut_calls} == {"v2"}


# ---------------------------------------------------------------- POST /api/twin/audit
@pytest.fixture()
def client(monkeypatch, tmp_path):
    from backup_manager import BackupManager
    monkeypatch.setattr(app_module, "bm", BackupManager(base_dir=str(tmp_path)))
    monkeypatch.delenv("TOOLWIZ_MODEL", raising=False)
    return app.test_client()


def _post_audit(client, body):
    r = client.post("/api/twin/audit", json=body, headers=HDR)
    assert r.status_code == 200, r.get_json()
    return r.get_json()


def test_twin_audit_honours_model_in_the_body(client, run_cut_calls):
    lib = _build("v2")[0]
    tools = [t for t in lib["tools"] if t.get("type") != "holder"]
    run_cut_calls.clear()
    out = _post_audit(client, {"tools": tools, "model": "v2", "material": "Aluminum - Wrought (6061)"})
    assert out["success"] and run_cut_calls
    assert {r.model for r in run_cut_calls} == {"v2"}

    run_cut_calls.clear()
    _post_audit(client, {"tools": tools})           # no model in the body: the app's default (v1)
    assert {r.model for r in run_cut_calls} == {"v1"}
