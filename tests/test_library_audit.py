"""library_audit and POST /api/twin/audit on the owner's real libraries and on small synthetic tools."""
import copy
import json
import os
import sys
import tempfile

import pytest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
import app as app_module  # noqa: E402
import library_audit as LA  # noqa: E402
from app import app  # noqa: E402
from backup_manager import BackupManager  # noqa: E402

LIB_DIR = os.path.join(os.path.dirname(__file__), "..", "data", "shop_library")
TI_LIB = os.path.join(LIB_DIR, "Offworldgear_TI_Steel1_Updated4_20261019_125408_v6.json")
HDR = {"X-ToolWiz-Client": "x"}
MAGNA = "CPM MagnaCut (Annealed ~22 HRC)"


@pytest.fixture(scope="module")
def lib():
    with open(TI_LIB, encoding="utf-8") as f:
        return json.load(f)


@pytest.fixture(scope="module")
def report(lib):
    return LA.audit_library(lib, app_module.physics, material="Titanium Alloy")


def _find(report, tool_prefix, preset=None, code=None, severity=None):
    return [f for f in report["findings"]
            if f["tool"].startswith(tool_prefix) and (preset is None or f["preset"] == preset)
            and (code is None or f["code"] == code) and (severity is None or f["severity"] == severity)]


def test_report_shape(report, lib):
    s = report["summary"]
    assert s["tools"] == len(lib["tools"]) - 1             # the holder entry is not a tool
    assert s["STOP"] + s["CAUTION"] + s["INFO"] == len(report["findings"])
    for f in report["findings"]:
        assert f["severity"] in ("STOP", "CAUTION", "INFO") and f["message"] and f["code"]
    assert len(report["tools"]) == s["tools"]


def test_impossible_magnacut_adaptive_preset_on_the_6mm_slot_mill_is_stop(report):
    name = f"{MAGNA} - Adaptive Roughing"
    stops = {f["code"]: f for f in _find(report, "6mm x .5mm", name, severity="STOP")}
    assert {"stepdown_over_cutting_length", "end_mill_strategy_on_form_tool", "chip_load_too_high"} <= set(stops)
    sd = stops["stepdown_over_cutting_length"]
    assert sd["preset_value"] == pytest.approx(23.954, abs=1e-3) and sd["toolwiz_value"] == pytest.approx(0.5)
    # Roughing / Slotting presets have a stepover wider than the (D - neck) / 2 = 1.5 mm reach
    over = _find(report, "6mm x .5mm", f"{MAGNA} - Slotting", code="stepover_over_limit")[0]
    assert over["toolwiz_value"] == pytest.approx(1.5, abs=1e-6)


def test_every_old_end_mill_preset_on_every_form_tool_is_stop(report):
    for tool in ("6mm x .5mm", "8mm x 1mm", "3/8 x 1/32", ".5 DIA Lollipop", "Chamfer 4fl", "HAAS 0.5000"):
        for strat in ("Adaptive Roughing", "Roughing", "Finishing", "Slotting"):
            assert _find(report, tool, f"{MAGNA} - {strat}", code="end_mill_strategy_on_form_tool", severity="STOP"), (tool, strat)


def test_findings_on_other_checks(report):
    assert _find(report, "1/32 Diameter 4 Flute", "Stainless", code="missing_feed", severity="STOP")   # all-zero preset
    assert _find(report, "1/16\" Dia. Carbide End Mill", code="rpm_over_max", severity="CAUTION")      # 35,141 rpm on 16k machine
    assert _find(report, "6mm x .5mm", code="er_holder", severity="CAUTION")
    assert _find(report, "6mm x .5mm", code="runout_missing", severity="INFO")
    assert any(f["code"] == "no_presets_for_material" for f in report["findings"])


def test_drill_presets_use_plunge_feed(report):
    assert not _find(report, "3/16", "Titanium - Drilling", code="missing_feed")


def test_unit_less_tool_is_reported_not_crashed(lib):
    bad = {"type": "flat end mill", "description": "no unit", "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.5, "SF": 0.25}}
    r = LA.audit_library({"tools": [bad]}, app_module.physics)
    assert [f["code"] for f in r["findings"]] == ["unreadable_tool"]


# ---- generated presets must be clean ---------------------------------------------------------------

@pytest.fixture()
def generated(monkeypatch, lib):
    tmp = tempfile.TemporaryDirectory()
    bm = BackupManager(base_dir=tmp.name)
    monkeypatch.setattr(app_module, "bm", bm)
    bm.save_working_library(copy.deepcopy(lib), "Test_Lib")
    c = app.test_client()
    r = c.post("/api/twin/batch_generate", headers=HDR, json={
        "tool_indices": "all", "family": "Stainless - 400 Series (420)", "alloy": MAGNA,
        "clean_existing_for_material": True})
    assert r.get_json()["success"]
    yield c, bm.load_working_library()
    tmp.cleanup()


def test_generated_presets_have_no_stop(generated):
    c, lib2 = generated
    rep = LA.audit_library(lib2, app_module.physics)
    mine = [f for f in rep["findings"] if f["preset"] and f["preset"].startswith(MAGNA + " - ")]
    for f in mine:
        assert f["severity"] != "STOP", f
    # slot mills: T-slot presets exist and are clean; no end-mill strategy remains under that material
    slot_stops = [f for f in rep["findings"] if f["tool"].startswith(("6mm x .5mm", "8mm x 1mm", "3/8 x 1/32"))
                  and f["preset"] and f["preset"].startswith(MAGNA + " - T-Slot")]
    assert not slot_stops
    for t in lib2["tools"]:
        if t["type"] == "slot mill":
            names = [p["name"] for p in t["start-values"]["presets"] if p["name"].startswith(MAGNA)]
            assert names == [f"{MAGNA} - T-Slot Full Slot"]


def test_endpoint_audits_posted_library_and_working_library(generated, lib):
    c, lib2 = generated
    r = c.post("/api/twin/audit", json={}, headers=HDR)                  # working library
    assert r.status_code == 200 and r.get_json()["success"]
    assert r.get_json()["summary"]["tools"] == len(lib2["tools"]) - 1
    r2 = c.post("/api/twin/audit", json=lib, headers=HDR)                 # library as the body
    assert r2.status_code == 200 and r2.get_json()["summary"]["STOP"] > 0
    r3 = c.post("/api/twin/audit", json={"library": lib, "material": "Titanium Alloy"}, headers=HDR)
    assert r3.get_json()["summary"]["tools"] == r2.get_json()["summary"]["tools"]


def test_endpoint_without_any_library_is_400(monkeypatch):
    tmp = tempfile.TemporaryDirectory()
    monkeypatch.setattr(app_module, "bm", BackupManager(base_dir=tmp.name))
    r = app.test_client().post("/api/twin/audit", json={}, headers=HDR)
    assert r.status_code == 400 and not r.get_json()["success"]
    tmp.cleanup()


# ---- synthetic checks -------------------------------------------------------------------------------

def _endmill(**over):
    t = {"type": "flat end mill", "unit": "inches", "description": "1/4 4fl", "BMC": "carbide",
         "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.5, "SFDM": 0.25, "LB": 1.5},
         "start-values": {"presets": []}}
    t.update(over)
    return t


def _preset(**kw):
    p = {"name": "Titanium - Roughing", "material": {"query": "", "category": "all"}, "n": 6000, "f_z": 0.001,
         "v_f": 24.0, "stepdown": 0.5, "stepover": 0.05, "use-stepdown": True, "use-stepover": True}
    p.update(kw)
    return p


def _audit(tool):
    return LA.audit_library({"tools": [tool]}, app_module.physics)


def _codes(r, severity=None):
    return {f["code"] for f in r["findings"] if severity is None or f["severity"] == severity}


def test_feed_inconsistent_and_over_max_rpm_and_missing_feed():
    t = _endmill()
    t["start-values"]["presets"] = [_preset(v_f=48.0), _preset(name="Titanium - Slotting", n=20000, v_f=80.0),
                                    _preset(name="Titanium - Finishing", v_f=0)]
    r = _audit(t)
    assert "feed_inconsistent" in _codes(r, "STOP") and "missing_feed" in _codes(r, "STOP")
    assert "rpm_over_max" in _codes(r, "CAUTION")


def test_stepdown_and_stepover_limits():
    t = _endmill()
    t["start-values"]["presets"] = [_preset(stepdown=0.6, stepover=0.3)]
    assert {"stepdown_over_cutting_length", "stepover_over_limit"} <= _codes(_audit(t), "STOP")
    t["start-values"]["presets"] = [_preset(stepdown=0.5, stepover=0.25)]
    assert not ({"stepdown_over_cutting_length", "stepover_over_limit"} & _codes(_audit(t)))


def test_chip_load_bands():
    t = _endmill()
    ref_codes = {}
    for label, fz in (("hi", 0.02), ("mid_hi", None), ("lo", 0.00001)):
        if fz is None:
            continue
        t["start-values"]["presets"] = [_preset(f_z=fz, v_f=6000 * fz * 4)]
        ref_codes[label] = _codes(_audit(t))
    assert "chip_load_too_high" in ref_codes["hi"]
    assert "chip_load_low" in ref_codes["lo"]


def test_duplicate_presets_and_unrecognised_material():
    t = _endmill()
    t["start-values"]["presets"] = [_preset(), _preset(name="Titanium - Slotting"), _preset(),
                                    _preset(name="Unobtainium - Roughing", material={"query": "Unobtainium"})]
    r = _audit(t)
    assert "duplicate_preset" in _codes(r, "CAUTION")
    assert any(f["code"] == "not_compared" and f["preset"] == "Unobtainium - Roughing" and f["severity"] == "INFO"
               for f in r["findings"])


def test_long_stickout_and_er_collet_on_micro_tool():
    t = _endmill(description="1/32 2fl", holder={"description": "BT30-ER16-60", "product-id": "BT30-ER16-60"})
    t["geometry"] = {"DC": 0.03125, "NOF": 2, "LCF": 0.047, "SFDM": 0.125, "LB": 0.5}
    t["start-values"]["presets"] = [_preset(f_z=0.0001, v_f=1.0, n=5000, stepdown=0.01, stepover=0.005)]
    r = _audit(t)
    assert {"long_stickout", "er_holder"} <= _codes(r, "CAUTION")
    t["holder"] = {"description": "Haas shrink fit"}
    assert "er_holder" not in _codes(_audit(t))
    t["geometry"]["LB"] = 0.1
    assert "long_stickout" not in _codes(_audit(t))


def test_info_when_no_preset_for_selected_material():
    t = _endmill()
    t["start-values"]["presets"] = [_preset(name="Aluminum - Roughing")]
    r = LA.audit_library({"tools": [t]}, app_module.physics, material="Titanium Alloy")
    assert "no_presets_for_material" in _codes(r, "INFO")


def test_classify_operation_and_material():
    assert LA.classify_operation({"name": "X - Slotting / Tab Milling"}) == "Slotting"
    assert LA.classify_operation({"name": "x", "operation_type": "Adaptive Roughing"}) == "Adaptive Roughing"
    assert LA.classify_operation({"name": "M - T-Slot Axial Step"}) == "T-Slot Axial Step"
    assert LA.resolve_material("Ti-6Al-4V (Grade 5) (Annealed) [334 HB]", physics=app_module.physics) == {
        "family": "Titanium Alloy", "alloy": "Ti-6Al-4V (Grade 5) (Annealed) [334 HB]"}
    assert LA.resolve_material("17-4 PH (Annealed) [330 HB]")["family"] == "Stainless - PH Series (17-4)"
    assert LA.resolve_material("Default preset") is None
