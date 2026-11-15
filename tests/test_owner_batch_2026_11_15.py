"""Owner's answers of 2026-11-15 (fourth round) and the held field-log items:
scallop chip load capped at the vendor chart; tool grade per tool; the strategy declared by the linked preset; a light
2D contour that leaves stock is a semi-finishing pass; tapping feed = rpm x pitch; an unmeasured 2D contour gets no plan
(entry 19); a ramp or plunge is never fed faster than the cut."""
import sys

import app as toolwiz_app
import setup_advisor as sa
from pipeline import CutRequest, run_cut, _run_cut_uncapped

FAM = "Aluminum - Wrought (6061)"
F16 = {"type": "flat end mill", "unit": "inches", "description": '1/16" Flat Endmill AlTiN',
       "geometry": {"DC": 0.0625, "NOF": 4, "LCF": 0.1875, "SFDM": 0.125, "LB": 0.5}}
B16 = {"type": "ball end mill", "unit": "inches", "description": '1/16" Ball Endmill AlTiN',
       "geometry": {"DC": 0.0625, "NOF": 4, "LCF": 0.25, "SFDM": 0.125, "LB": 0.5}}
E4 = {"type": "flat end mill", "unit": "inches", "description": "1/4 4 flute endmill AlTiN",
      "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.4375, "SFDM": 0.25, "LB": 1.5}}
S = {"tool_spindleSpeed": "11999 rpm", "tool_feedCutting": "25.56 in/min"}


def _op(name, strategy, tool, params, **extra):
    return dict({"setup": "Op1", "name": name, "path": f"Op1 > {name}", "strategy": strategy, "tool": tool, "params": params}, **extra)


def _advise(ops, **kw):
    kw.setdefault("tool_alternatives", False)
    return sa.advise({"document": "d", "ops": ops}, family=FAM, alloy="7075-T6", aggressiveness=0.6, physics=toolwiz_app.physics,
                     machine_profile=toolwiz_app.active_machine(), **kw)["operations"]


def _codes(o):
    return [f["code"] for f in o["findings"]]


# ---- scallop cap ----------------------------------------------------------------------------------------------------

def _ball_req(op, **kw):
    base = dict(family=FAM, alloy="7075-T6", operation=op, coating="AlTiN", apply_coating=True, geometry="Ball", diameter=0.0625, flutes=4,
                flute_length=0.25, shank_diameter=0.125, corner_radius=0.03125, stickout=0.5, aggressiveness=0.6, max_rpm=16000, max_hp=10,
                runout=0.0002, model="v2")
    base.update(kw)
    return CutRequest(**base)


def test_scallop_chip_load_is_capped_at_the_chart_guarded_finishing_chip_load():
    """1/16 in 4-flute ball, 7075: the v1 scallop rule gave 0.0014 in/tooth; Harvey's ball chart lists 0.00069 to 0.00103."""
    raw = _run_cut_uncapped(toolwiz_app.physics, _ball_req("3D Contouring / Scallop Finishing", cut_width=0.0049))
    capped = run_cut(toolwiz_app.physics, _ball_req("3D Contouring / Scallop Finishing", cut_width=0.0049))
    ref = run_cut(toolwiz_app.physics, _ball_req("Finishing", finish_mode="none"))
    fz_raw, fz, fz_ref = raw.feed_ipm / raw.rpm / 4, capped.feed_ipm / capped.rpm / 4, ref.feed_ipm / ref.rpm / 4
    assert ref.model == "v2" and fz_raw > 0.0012 and abs(fz - fz_ref) < 1e-6
    assert 0.00069 <= fz <= 0.00103                                   # inside Harvey's published band for this tool
    assert "vendor chart cap" in capped.limited_by and capped.ramp_feed <= capped.feed_ipm and capped.plunge_feed <= capped.feed_ipm
    o = _advise([_op("Scallop4 (6)", "scallop", B16, dict(S, stepover="0.0049 in"))])[0]
    assert abs(sa.parse_quantity(o["apply_plan"]["recommended"]["tool_feedCutting"], "feed") - capped.feed_ipm) <= 0.011


def test_cap_never_raises_a_feed_and_leaves_other_operations_alone():
    for op in ("Finishing", "Floor Finishing (Skim)", "Roughing"):
        a, b = _run_cut_uncapped(toolwiz_app.physics, _ball_req(op)), run_cut(toolwiz_app.physics, _ball_req(op))
        assert a.feed_ipm == b.feed_ipm and a.limited_by == b.limited_by
    for d, z in ((0.125, 2), (0.25, 4)):
        kw = dict(diameter=d, flutes=z, flute_length=3 * d, shank_diameter=max(d, 0.125), corner_radius=d / 2, stickout=4 * d, cut_width=0.05 * d)
        a = _run_cut_uncapped(toolwiz_app.physics, _ball_req("3D Contouring / Scallop Finishing", **kw))
        b = run_cut(toolwiz_app.physics, _ball_req("3D Contouring / Scallop Finishing", **kw))
        assert b.feed_ipm <= a.feed_ipm + 1e-9 and b.rpm == a.rpm


# ---- tool grade per tool --------------------------------------------------------------------------------------------

def test_grade_is_standard_unless_the_description_names_the_tool_high_performance():
    sys.path.insert(0, "ToolWizFusionAddin")
    import twlogic as tw
    cases = {'1/8" 4FL HI PERF EM W .015" RADIUS': True, "1/4 HP endmill AlTiN": True, "3/8 High Performance 5FL": True,
             '1/16" Dia. Carbide End Mill, 4 Flute, TiAlN Coated, HSPM1': False, '1/16" Flat Endmill AlTiN': False, "HPC-style chipbreaker": False}
    for desc, want in cases.items():
        assert sa.parse_tool({"type": "flat end mill", "description": desc})["grade_hp"] is want, desc
        assert tw.is_hp_grade(desc) is want, desc
    p = dict(S, maximumStepdown="0.0394 in", stepover="0.01875 in")
    std = _advise([_op("Flat34", "flat", F16, p)])[0]["toolwiz"]["at_current_engagement"]["feed_ipm"]
    hp = _advise([_op("Flat34", "flat", dict(F16, description='1/16" HP Flat Endmill AlTiN'), p)])[0]["toolwiz"]["at_current_engagement"]["feed_ipm"]
    assert hp > 1.2 * std                    # the older engine's HP table row; the two tools must not share a cached answer


# ---- declared strategy ----------------------------------------------------------------------------------------------

def test_strategy_declared_by_the_linked_preset_is_followed_where_the_operation_can_be_that_cut():
    assert sa.declared_strategy("7075 (T6, T651) - Finishing") == "Finishing" and sa.declared_strategy("Default preset") is None
    assert sa.declared_strategy("GWizStainless304") is None and sa.declared_strategy("Ti - 6Al - 4V") is None
    p = dict(S, maximumStepdown="0.05 in")
    o = _advise([_op("2D Contour206 (3)", "contour2d", E4, p, preset="7075 (T6, T651) - Slotting")])[0]
    assert o["kind"] == "slot" and o["declared_strategy"] == "Slotting" and o["toolwiz"]["recommended"]["operation"] == "Slotting"
    assert any(n.startswith('Strategy "Slotting" comes from the linked preset') for n in o["notes"])
    o = _advise([_op("2D Contour1", "contour2d", E4, dict(p, stepover="0.02 in"), preset="7075 (T6, T651) - Finishing")])[0]
    assert o["kind"] == "finish" and o["toolwiz"]["at_current_engagement"]["operation"] == "Finishing"
    o = _advise([_op("2D Contour1", "contour2d", E4, dict(p, stepover="0.02 in"), preset="Default preset")])[0]
    assert o["kind"] == "contour" and "declared_strategy" not in o and "preset_strategy_mismatch" not in _codes(o)


def test_a_preset_for_another_kind_of_cut_is_flagged_and_not_followed():
    o = _advise([_op("Scallop4 (6)", "scallop", B16, dict(S, stepover="0.0049 in"), preset="Aluminum - Roughing")])[0]
    f = [x for x in o["findings"] if x["code"] == "preset_strategy_mismatch"]
    assert len(f) == 1 and f[0]["severity"] == "CAUTION" and "Run ToolWiz Speeds & Feeds on this toolpath" in f[0]["recommendation"]
    assert o["kind"] == "finish" and o["toolwiz"]["at_current_engagement"]["operation"] == sa.SCALLOP_OPERATION and "declared_strategy" not in o
    o = _advise([_op("Flat34", "flat", F16, dict(S, maximumStepdown="0.0394 in", stepover="0.01875 in"), preset="7075 (T6, T651) - Finishing")])[0]
    assert "preset_strategy_mismatch" in _codes(o) and o["toolwiz"]["at_current_engagement"]["operation"] == sa.FLOOR_FINISH_OPERATION


# ---- a light 2D contour that leaves stock ---------------------------------------------------------------------------

def test_light_contour_with_positive_stock_is_a_semi_finishing_pass():
    """Owner: stock left on purpose (the part is flipped and contoured whole in Op2) is a semi-finish, not roughing."""
    o = _advise([_op("2D Contour64", "contour2d", F16, dict(S, stockToLeave="0.004 in"), stock_to_leave_enabled=True, multiple_depths=False)])[0]
    assert o["kind"] == "finish" and o["apply_plan"] is None
    assert any("treated as a semi-finishing pass" in n for n in o["notes"]) and any(n.startswith("No speed or feed is proposed") for n in o["notes"])
    o = _advise([_op("2D Contour64", "contour2d", F16, dict(S, stockToLeave="0.004 in", stepover="0.005 in"), stock_to_leave_enabled=True)])[0]
    plan = o["apply_plan"]["recommended"]
    assert o["kind"] == "finish" and "stockToLeave" not in plan and "maximumStepdown" not in plan and "stepover" not in plan
    assert plan["tool_feedCutting"] == f"{o['toolwiz']['at_current_engagement']['feed_ipm']:.2f} in/min"
    for extra in (dict(multiple_depths=True), dict(name="2D Contour rough")):                 # real material or named roughing: still roughing
        base = _op("2D Contour64", "contour2d", F16, dict(S, stockToLeave="0.004 in", maximumStepdown="0.05 in"), stock_to_leave_enabled=True)
        assert _advise([dict(base, **extra)])[0]["kind"] == "contour"
    assert _advise([_op("C", "contour2d", F16, dict(S, maximumStepdown="0.05 in", stepover="0.02 in"))])[0]["kind"] == "contour"   # no stock set


# ---- tapping --------------------------------------------------------------------------------------------------------

TAP = {"type": "tap right hand", "unit": "millimeters", "description": "M1.6x0.35 Form Tap",
       "geometry": {"DC": 1.6, "NOF": 3, "LCF": 5.0, "SFDM": 3.0, "LB": 12.0, "TP": 0.35}}


def test_tapping_feed_must_equal_rpm_times_pitch():
    for feed, bad in (("10.77 in/min", True), ("39.37 in/min", True), ("24.32 in/min", False)):
        o = _advise([_op("Tap1", "drill", TAP, {"tool_spindleSpeed": "1765 rpm", "tool_feedPlunge": feed})])[0]
        f = [x for x in o["findings"] if x["code"] == "tapping_feed_mismatch"]
        assert o["kind"] == "hole" and bool(f) is bad, feed
        if bad:
            assert f[0]["severity"] == "CAUTION" and abs(f[0]["numbers"]["required_feed_ipm"] - 24.32) < 0.01
    drill = {"type": "drill", "unit": "inches", "description": "3/16", "geometry": {"DC": 0.1875, "NOF": 2, "LCF": 1.0, "SFDM": 0.1875, "LB": 1.5}}
    o = _advise([_op("Drill1", "drill", drill, {"tool_spindleSpeed": "1765 rpm", "tool_feedPlunge": "10 in/min"})])[0]
    assert "tapping_feed_mismatch" not in _codes(o)


# ---- entry 19: an unmeasured 2D contour -----------------------------------------------------------------------------

def test_unmeasured_contour_gets_no_plan_when_the_addin_measured_the_others():
    p = dict(S, maximumStepdown="0.05 in", stepover="0.02 in")
    measured = _op("2D Contour1", "contour2d", E4, p, geometry={"toolpath_length_in": 12.0})
    blind = _op("2D Contour239 (3)", "contour2d", E4, p)
    a, b = _advise([measured, blind])
    assert "geometry_not_measured" not in _codes(a) and a["apply_plan"]
    f = [x for x in b["findings"] if x["code"] == "geometry_not_measured"]
    assert len(f) == 1 and f[0]["severity"] == "CAUTION" and b["apply_plan"] is None
    assert "geometry_not_measured" not in _codes(_advise([blind])[0])          # a snapshot without measurements at all: unchanged


# ---- ramp and plunge feed -------------------------------------------------------------------------------------------

def test_ramp_and_plunge_feed_are_never_above_the_cutting_feed_in_a_plan():
    ops = _advise([_op("Flat33 (4)", "flat", dict(F16, geometry=dict(F16["geometry"], DC=0.125, LCF=0.5)), dict(S, maximumStepdown="0.039 in", stepover="0.03 in")),
                   _op("Scallop4 (6)", "scallop", B16, dict(S, stepover="0.0049 in")),
                   _op("Pocket", "pocket2d", E4, dict(S, maximumStepdown="0.2 in", stepover="0.05 in", tool_rampAngle="2 deg"))])
    seen = 0
    for o in ops:
        p = (o["apply_plan"] or {}).get("recommended") or {}
        cut = sa.parse_quantity(p.get("tool_feedCutting"), "feed")
        for name in ("tool_feedRamp", "tool_feedPlunge"):
            if p.get(name) and cut:
                seen += 1
                assert sa.parse_quantity(p[name], "feed") <= cut + 1e-9, (o["name"], name, p)
    assert seen >= 3
