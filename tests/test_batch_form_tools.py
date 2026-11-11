"""/api/twin/batch_generate must not write end-mill strategies to slot mills or other form tools."""
import copy
import json
import os
import sys
import tempfile

import pytest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
import app as app_module  # noqa: E402
from app import app  # noqa: E402
from backup_manager import BackupManager  # noqa: E402
from toolwiz_common.tool_strategy import END_MILL_STRATEGIES  # noqa: E402

TI_LIB = os.path.join(os.path.dirname(__file__), "..", "data", "shop_library",
                      "Offworldgear_TI_Steel1_Updated4_20261019_125408_v6.json")
HDR = {"X-ToolWiz-Client": "x"}
MM = 1 / 25.4
FORM_TYPES = {"slot mill", "dovetail mill", "lollipop mill", "chamfer mill", "drill", "spot drill"}


@pytest.fixture()
def env(monkeypatch):
    tmp = tempfile.TemporaryDirectory()
    bm = BackupManager(base_dir=tmp.name)
    monkeypatch.setattr(app_module, "bm", bm)
    with open(TI_LIB, encoding="utf-8") as f:
        lib = json.load(f)
    yield app.test_client(), bm, lib
    tmp.cleanup()


def _generate(env, tools, **body):
    client, bm, lib = env
    lib = dict(lib, tools=tools)
    bm.save_working_library(lib, "Test_Lib")
    payload = {"tool_indices": "all", "family": "Titanium Alloy", "alloy": "CPM MagnaCut (Annealed ~22 HRC)",
               "clean_existing_for_material": True}
    payload.update(body)
    r = client.post("/api/twin/batch_generate", json=payload, headers=HDR)
    assert r.status_code == 200, r.get_json()
    j = r.get_json()
    assert j["success"]
    return j, bm.load_working_library()["tools"]


def _new_presets(tool, label="CPM MagnaCut (Annealed ~22 HRC)"):
    return [p for p in (tool.get("start-values") or {}).get("presets", []) if p["name"].startswith(label + " - ")]


def test_slot_mills_get_t_slot_presets_only(env):
    slot = [t for t in env[2]["tools"] if t["type"] == "slot mill"]
    j, tools = _generate(env, copy.deepcopy(slot))
    assert len(tools) == 3
    for t, orig in zip(tools, slot):
        presets = _new_presets(t)
        names = [p["name"] for p in presets]
        assert names == ["CPM MagnaCut (Annealed ~22 HRC) - T-Slot Full Slot"], names
        for strat in END_MILL_STRATEGIES:
            assert not any(n.endswith(" - " + strat) for n in names)
        p = presets[0]
        g = t["geometry"]
        kerf = g["LCF"]
        assert p["operation_type"] == "T-Slot Full Slot"
        assert p["stepdown"] == pytest.approx(kerf, rel=1e-6)                 # kerf
        assert 0 < p["stepover"] <= g["DC"] / 2 + 1e-9
        assert p["stepover"] > 0 and p["n"] > 0 and p["v_f"] > 0 and p["f_z"] > 0
        assert p["v_f"] == pytest.approx(p["n"] * p["f_z"] * g["NOF"], rel=0.02)
    # the 6 mm x 0.5 mm cutter: 0.5 mm stepdown, stepover below the 1.5 mm neck clearance
    six = _new_presets(tools[0])[0]
    assert six["stepdown"] == pytest.approx(0.5, rel=1e-6)
    assert six["stepover"] <= 1.5 + 1e-9
    assert any("axial-step" in s["reason"] for s in j["skipped"])             # faces unknown -> reported


def test_axial_step_preset_when_cutter_cuts_both_faces(env):
    tool = copy.deepcopy([t for t in env[2]["tools"] if t["type"] == "slot mill"][2])
    tool["description"] += " STAGGERED TOOTH"
    j, tools = _generate(env, [tool])
    names = [p["name"] for p in _new_presets(tools[0])]
    assert names == ["CPM MagnaCut (Annealed ~22 HRC) - T-Slot Full Slot",
                     "CPM MagnaCut (Annealed ~22 HRC) - T-Slot Axial Step"]
    ax = _new_presets(tools[0])[1]
    g = tool["geometry"]
    assert ax["stepdown"] == pytest.approx(0.8 * g["LCF"], rel=1e-6) and ax["stepdown"] <= g["LCF"]
    assert ax["v_f"] == pytest.approx(ax["n"] * ax["f_z"] * g["NOF"], rel=0.02)


def test_other_form_tools_are_skipped_with_a_reason(env):
    forms = [t for t in env[2]["tools"] if t["type"] in ("dovetail mill", "lollipop mill", "chamfer mill")]
    assert len(forms) == 5
    j, tools = _generate(env, copy.deepcopy(forms))
    assert j["total_presets_injected"] == 0 and j["updated_tools_count"] == 0
    assert len(j["skipped"]) == 5 and all("end-mill strategies" in s["reason"] for s in j["skipped"])
    for t in tools:
        assert not _new_presets(t)


def test_end_mills_still_get_their_four_strategies_and_form_tools_never_do(env):
    j, tools = _generate(env, copy.deepcopy(env[2]["tools"]))
    for t in tools:
        names = [p["name"] for p in _new_presets(t)]
        if t["type"] in ("flat end mill", "bull nose end mill", "ball end mill"):
            assert len(names) == 4, (t["description"], names)
        if t["type"] in FORM_TYPES:
            for strat in END_MILL_STRATEGIES:
                assert not any(n.endswith(" - " + strat) for n in names), (t["description"], names)
        if t["type"] == "drill":
            assert [n.rsplit(" - ", 1)[1] for n in names] == ["Drilling"]
