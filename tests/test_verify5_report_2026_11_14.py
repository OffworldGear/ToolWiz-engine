"""Fixes for docs/FUSION_BRIDGE_VERIFY4_2026-11-14.md (findings 1 to 4): ramp-off INFO and ramp tolerance, one rounding and
plain row wording in the ramp sentence, no duplicate plans, no contradictory stock messages."""
import json
import os
import sys
from types import SimpleNamespace

import setup_advisor as sa
from test_addin_common import load_addin, param, ParamsByName
from test_verify4_report_2026_11_14 import _advise, _op, _one, _tw_ramp, P, RAMP_ON, ENDMILL
from physics_v2 import ramp as vr

RAMP_OFF = {"enabled": False, "type": "profile", "raw": {"doRamp": "false", "rampType": "'profile'"}}


def _codes(o):
    return [f["code"] for f in o["findings"]]


# ---- 1. ramp off ----------------------------------------------------------------------------------------------------

def test_contour_with_depths_and_ramp_off_gets_info_and_no_plan_entry():
    ang = _tw_ramp()
    plan, notes, o = _one(_op("2D Contour2", "contour2d", dict(P, tool_rampAngle="3.0 deg"), ramp=RAMP_OFF, multiple_depths=True))
    f = [x for x in o["findings"] if x["code"] == "ramp_off"]
    assert len(f) == 1 and f[0]["severity"] == "INFO"
    assert f[0]["detail"].startswith("Turning on Ramp in Fusion would ease the entry at each depth;")
    assert "doRamp" not in json.dumps(o["apply_plan"]) and "tool_rampAngle" not in plan
    assert f"{f[0]['numbers']['toolwiz_ramp_angle_deg']:.1f} deg" in f[0]["detail"] and ang > 0


def test_ramp_off_info_only_where_material_is_removed():
    _, _, o = _one(_op("Finish", "contour2d", dict(P, stepover="0.01 in"), ramp=RAMP_OFF, multiple_depths=False))
    assert "ramp_off" not in _codes(o)
    _, _, o = _one(_op("C", "contour2d", dict(P), ramp=RAMP_ON, multiple_depths=True))
    assert "ramp_off" not in _codes(o)


def test_lower_ramp_angle_needs_more_than_tolerance():
    ang = _tw_ramp()
    inside = max(1.0, 0.15 * (ang + 0.9))
    cur = ang + min(0.9, inside - 0.01)            # lower by < max(1 deg, 15 %): the owner's angle stays, silently
    plan, notes, _ = _one(_op("Op", "pocket2d", dict(P, tool_rampAngle=f"{cur:.2f} deg")))
    assert "tool_rampAngle" not in plan and not any(n.startswith("Ramp angle kept") for n in notes)
    cur = ang + max(1.0, 0.15 * ang) + 3.0         # clearly above: lowered
    plan, _, _ = _one(_op("Op", "pocket2d", dict(P, tool_rampAngle=f"{cur:.2f} deg")))
    assert plan["tool_rampAngle"] == f"{ang:.1f} deg"


def test_addin_ignores_tool_rampType():
    a = load_addin()
    tool = dict(ENDMILL, **{"post-process": {"number": 1}})
    op = SimpleNamespace(name="P", strategy="pocket2d", tool=SimpleNamespace(toJson=lambda: json.dumps(tool)),
                         parameters=ParamsByName({"tool_rampType": param("'helix'"), "tool_spindleSpeed": param("12000 rpm")}))
    r = a.read_ramp_entry(op)
    assert r["enabled"] is None and r["type"] is None
    op.parameters = ParamsByName({"tool_rampType": param("'helix'"), "doRamp": param("false", False), "rampType": param("'profile'")})
    r = a.read_ramp_entry(op)
    assert r["enabled"] is False and r["type"] == "profile"


# ---- 2. chart sentence ----------------------------------------------------------------------------------------------

def test_deg_rounding_matches_plan_and_rows_wording_is_plain():
    assert vr.fmt_deg(6.44) == "6.4" and vr.fmt_deg(3) == "3.0" and sa._expr("angle", round(6.4449, 2)) == f"{vr.fmt_deg(6.4449)} deg"
    _, notes, o = _one(_op("Op", "pocket2d", dict(P, tool_rampAngle="30 deg")))
    txt = o["toolwiz"]["recommended"]["ramp_basis"]
    assert "Rows:" not in txt and "chart rows" in txt and "at least as many flutes" in txt


# ---- 3. identical plans ---------------------------------------------------------------------------------------------

def test_identical_plans_keep_only_recommended():
    op = {"current": {"rpm": None, "feed_ipm": None}, "current_extra": {}, "kind": "face"}
    plans = {"recommended": {"tool_spindleSpeed": "9000 rpm", "tool_feedCutting": "20.00 in/min"},
             "keep_engagement": {"tool_spindleSpeed": "9000 rpm", "tool_feedCutting": "20.00 in/min"}}
    op.update(name="x", rich=False, stock_enabled=None, geometry={}, tool={})
    out = sa._finalize_plans(op, plans, [])
    assert list(out) == ["recommended"]
    plans["keep_engagement"]["tool_feedCutting"] = "19.00 in/min"
    assert set(sa._finalize_plans(op, plans, [])) == {"recommended", "keep_engagement"}


# ---- 4. stock messages ----------------------------------------------------------------------------------------------

def test_no_stock_caution_where_stock_not_proposed():
    for extra in ({"stock_to_leave_enabled": True}, {"stock_to_leave_enabled": False}):
        prm = dict(P, stockToLeave="0.0020 in")
        _, notes, o = _one(_op("2D Contour1", "contour2d", prm, ramp=RAMP_ON, multiple_depths=False, **extra))
        assert "stock_radial_low" not in _codes(o), extra


def test_stock_note_only_when_value_differs():
    want = None
    for st in (0.002, 0.0025, 0.003):
        _, notes, o = _one(_op("2D Contour2", "contour2d", dict(P, stockToLeave=f"{st} in"), ramp=RAMP_ON, multiple_depths=False,
                               stock_to_leave_enabled=False))
        want = want or o["toolwiz"]["recommended"]["stock_to_leave_radial_in"]
    st = round(want, 4)
    _, notes, _ = _one(_op("2D Contour2", "contour2d", dict(P, stockToLeave=f"{st:.4f} in"), ramp=RAMP_ON, multiple_depths=False,
                           stock_to_leave_enabled=False))
    assert not any(n.startswith("Stock to leave") for n in notes)
    _, notes, _ = _one(_op("2D Contour2", "contour2d", dict(P, stockToLeave=f"{st + 0.01:.4f} in"), ramp=RAMP_ON, multiple_depths=False,
                           stock_to_leave_enabled=False))
    assert any(n.startswith("Stock to leave") and "would leave" in n for n in notes)


def test_slot_with_ramp_off_also_gets_the_ramp_off_info():
    """Owner decision 2026-11-14 ("Yes, add it"): the 1/16 in slot contours with doRamp false get the same INFO as a contour
    that removes material; never a doRamp or ramp angle in the plan, and no duplicate "does not ramp" note."""
    import app as toolwiz_app
    import setup_advisor as sa
    tool = {"type": "flat end mill", "unit": "inches", "description": "1/16 4FL AlTiN",
            "geometry": {"DC": 0.0625, "NOF": 4, "LCF": 0.1875, "SFDM": 0.125, "LB": 0.3}}
    op = {"setup": "S", "name": "2D Contour206 (3)", "path": "S > 2D Contour206 (3)", "strategy": "contour2d", "tool": tool,
          "params": {"tool_spindleSpeed": "9000 rpm", "tool_feedCutting": "5 in/min", "tool_rampAngle": "2 deg"},
          "geometry": {"is_slot": True, "slot_width_in": 0.063, "depth_in": 0.126},
          "ramp": {"enabled": False, "type": "profile", "raw": {}}, "multiple_depths": False}
    res = sa.advise({"document": "d", "ops": [op]}, family="Aluminum - Wrought (6061)", alloy="", physics=toolwiz_app.physics,
                    machine_profile=toolwiz_app.active_machine())
    o = res["operations"][0]
    assert o["kind"] == "slot"
    f = [x for x in o["findings"] if x["code"] == "ramp_off"]
    assert len(f) == 1 and f[0]["severity"] == "INFO" and "ToolWiz's ramp angle for this tool would be" in f[0]["detail"]
    plans = o["apply_plan"] or {}
    assert all("tool_rampAngle" not in p and "doRamp" not in p for p in plans.values())
    assert not any("does not ramp" in n for n in o["notes"])


def test_chart_sentence_names_the_limit_and_uses_the_singular():
    from physics_v2 import ramp
    basis = {"vendor_name": "Helical", "rows": 1, "row_flutes": [5], "tool_flutes": 4, "row_reach_over_D": None}
    import inspect
    src = inspect.getsource(ramp)
    assert "chart row\" + (\"\" if basis['rows'] == 1 else \"s\")" in src and "the angle used is at or just under the limit" in src
