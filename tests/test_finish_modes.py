"""Finish modes (finish_modes.py): cleanup | surface | accuracy."""
import math
import unittest

import app
import finish_modes
from pipeline import CutRequest, run_cut

AL = "Aluminum - Wrought (6061)"
ST = "Steel - Medium Carbon Alloy (4130)"


def req(mode=None, d=0.25, z=4, family=AL, op="Wall Finishing (Deep DOC)", geometry="Square", **kw):
    base = dict(family=family, alloy="", tool="HP Carbide Endmill", coating="Uncoated" if family == AL else "AlTiN",
                geometry=geometry, operation=op, diameter=d, flutes=z, flute_length=3 * d, shank_diameter=max(d, 0.125),
                helix_angle=35.0, stickout=max(0.75, 3 * d), aggressiveness=0.5, max_rpm=16000.0, max_hp=10.0,
                runout=0.0002, cut_depth=min(0.5, 2 * d), cut_width=0.01, model="v2", finish_mode=mode)
    base.update(kw)
    return CutRequest(**base)


class TestCuspPhysics(unittest.TestCase):
    def test_cusp_formula_is_the_circle_sagitta(self):
        # Boothroyd & Knight, Fundamentals of Machining and Machine Tools: cusp h = f^2/(8 r); for a circle of radius R the
        # exact sagitta over a chord s is R - sqrt(R^2 - s^2/4), which the formula matches to 0.2 % at s/R = 0.16.
        R, s = 0.0625, 0.01
        self.assertAlmostEqual(finish_modes.cusp(s, R) / finish_modes.sagitta(s, R), 1.0, delta=0.003)

    def test_ball_nose_scallop_on_a_flat_floor(self):
        r = run_cut(app.physics, req("surface", d=0.125, z=2, op="3D Contouring / Scallop Finishing", geometry="Ball Nose",
                                     model="v1", cut_depth=0.01, cut_width=0.02, target_ra=16.0))
        f = r.finish
        self.assertEqual(f["tool_kind"], "ball")
        step = f["stepover_in"]
        self.assertAlmostEqual(finish_modes.cusp(step, 0.0625), step * step / (8 * 0.0625))
        # the stepover was cut back to meet Ra 16 uin: h <= 4 x 16e-6
        self.assertLessEqual(f["predicted_cusp_in"], 4 * 16e-6 * 1.001)
        self.assertGreaterEqual(f["predicted_cusp_in"], 0.0)


class TestModes(unittest.TestCase):
    def run_modes(self, **kw):
        return {m: run_cut(app.physics, req(m, **kw)) for m in ("cleanup", "surface", "accuracy")}

    def test_defaults(self):
        r = run_cut(app.physics, req(None))
        self.assertEqual(r.finish["mode"], "cleanup")
        self.assertEqual(r.finish["target_ra_uin"], 63.0)
        self.assertEqual(r.finish["wall_tolerance_in"], 0.001)

    def test_surface_lowers_fz_to_meet_ra_and_cleanup_is_fastest(self):
        m = self.run_modes(d=0.25, z=4)
        self.assertLessEqual(m["surface"].adj_ipt, m["cleanup"].adj_ipt * 1.0001)
        self.assertLessEqual(m["surface"].finish["predicted_ra_uin"], 32.0 * 1.02)
        self.assertLessEqual(m["cleanup"].finish["predicted_ra_uin"], 63.0 * 1.02)
        self.assertGreaterEqual(m["cleanup"].feed_ipm, m["surface"].feed_ipm * 0.999)
        self.assertGreaterEqual(m["cleanup"].feed_ipm, m["accuracy"].feed_ipm * 0.999)

    def test_surface_ra_target_is_user_settable(self):
        a = run_cut(app.physics, req("surface", target_ra=16.0))
        b = run_cut(app.physics, req("surface", target_ra=32.0))
        self.assertLessEqual(a.adj_ipt, b.adj_ipt * 1.0001)
        self.assertLessEqual(a.finish["predicted_ra_uin"], 16.0 * 1.02)

    def test_accuracy_meets_the_wall_error_by_cutting_back(self):
        m = self.run_modes(d=0.25, z=4, family=ST, stickout=1.5, cut_depth=0.75)
        acc, clean = m["accuracy"], m["cleanup"]
        self.assertLessEqual(acc.finish["predicted_wall_error_in"], 0.0002 * 1.05)
        self.assertLessEqual(acc.feed_ipm * acc.woc, clean.feed_ipm * clean.woc * 1.0001)
        self.assertEqual(acc.finish["wall_tolerance_in"], 0.0002)

    def test_wall_tolerance_override(self):
        r = run_cut(app.physics, req("accuracy", family=ST, stickout=1.5, cut_depth=0.75, wall_tolerance=0.0005))
        self.assertEqual(r.finish["wall_tolerance_in"], 0.0005)
        self.assertLessEqual(r.finish["predicted_wall_error_in"], 0.0005 * 1.05)

    def test_runout_makes_marks_coarser_by_z(self):
        hi = run_cut(app.physics, req("surface", d=0.0625, z=2, runout=0.0005, cut_depth=0.1, cut_width=0.002))
        self.assertAlmostEqual(hi.finish["effective_mark_spacing_in"], 2 * hi.adj_ipt, places=9)

    def test_endpoint_accepts_and_returns_the_block(self):
        c = app.app.test_client()
        c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
        body = dict(family=AL, tool="Carbide Endmill", geometry="Square", operation="Wall Finishing (Deep DOC)", diameter=0.25,
                    flutes=4, fluteLength=0.75, stickout=1.0, shankDiameter=0.25, aggressiveness=50, maxRpm=16000, maxHp=10,
                    model="v2", finishMode="accuracy", targetRa=20, wallTolerance=0.0003)
        for url in ("/api/calculate", "/api/calculate_for_fusion"):
            j = c.post(url, json=body).get_json()
            self.assertEqual(j["finish"]["mode"], "accuracy", url)
            self.assertEqual(j["finish"]["target_ra_uin"], 20.0)
            self.assertEqual(j["finish"]["wall_tolerance_in"], 0.0003)


if __name__ == "__main__":
    unittest.main()


def test_finish_mode_keeps_base_ipt_and_mrr_model():
    """A finish target that narrows the stepover must not overwrite base_ipt with the thinned chip load,
    and must scale (not recompute) the engine's MRR so geometry corrections such as ball-nose survive."""
    import json, os
    from app import app as flask_app
    c = flask_app.test_client()
    c.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
    body = {"family": "Steel - Tool (H13)", "alloy": "", "tool": "Carbide Endmill", "coating": "AlTiN",
            "geometry": "Ball", "operation": "3D Contouring / Scallop Finishing", "diameter": 0.125, "flutes": 2,
            "cutDepth": 0.005, "cutWidth": 0.02, "stickout": 0.5, "fluteLength": 0.25, "shankDiameter": 0.125,
            "model": "v1", "aggressiveness": 50, "runout": 0.0002}
    base = c.post("/api/calculate", json=dict(body, finishMode="cleanup", targetRa=1000)).get_json()
    tight = c.post("/api/calculate", json=dict(body, finishMode="surface", targetRa=8)).get_json()
    assert base["success"] and tight["success"]
    assert tight["base_ipt"] <= base["base_ipt"] + 1e-9          # never inflated by the finish step
    assert tight["adj_ipt"] <= base["adj_ipt"] + 1e-9
    assert tight["mrr"] <= base["mrr"] + 1e-9


def _face(extra=None, **kw):
    """The owner's Face1 case: 5/16" 4-flute, 0.015" corner radius, a 0.1 mm skim at half-diameter stepover."""
    import app as A
    body = {"family": "Aluminum - Wrought (6061)", "operation": "Facing", "diameter": 0.3125, "flutes": 4, "fluteLength": 0.75,
            "shankDiameter": 0.3125, "stickout": 1.0, "cornerRadius": 0.015, "geometry": "Radiused", "aggressiveness": 50,
            "cutDepth": 0.003937, "cutWidth": 0.15625, "coating": "AlTiN"}
    body.update(kw)
    body.update(extra or {})
    return A.app.test_client().post("/api/calculate", json=body, headers={"X-ToolWiz-Client": "t"}).get_json()


def test_facing_defaults_to_no_finish_target_and_keeps_the_stepover():
    """Regression: a bull-nose tool on a facing pass was cut to a 0.0055" stepover by the Ra scallop limit."""
    r = _face()
    assert r["success"] and r["finish"]["mode"] == "none" and r["finish"]["limited_by"] is None
    assert r["finish"]["target_ra_uin"] is None and r["finish"]["surface_kind"] == "floor"
    assert abs(r["rec_woc"] - 0.15625) < 1e-6


def test_flat_bottom_tools_leave_no_floor_scallop_inside_their_flat():
    import finish_modes as fm
    D, r = 0.3125, 0.015
    flat = D - 2 * r
    assert fm.stepover_scallop("floor", "bull", 0.15625, D, r)[0] == 0.0
    assert fm.stepover_scallop("floor", "flat", 0.30, D, None) == (0.0, None)
    h, ae_max = fm.stepover_scallop("floor", "bull", flat + 0.01, D, r)
    assert abs(h - 0.01 ** 2 / (8 * r)) < 1e-12 and abs(ae_max(h) - (flat + 0.01)) < 1e-9
    assert fm.stepover_scallop("floor", "ball", 0.02, 0.25, 0.125)[0] > 0      # a ball still scallops a floor
    assert fm.stepover_scallop("surface3d", "bull", 0.02, D, r)[0] > 0          # and a bull nose a 3D surface
    # even an explicit finish mode does not shrink a facing stepover that stays on the tool's flat
    for mode in ("cleanup", "surface"):
        res = _face({"finishMode": mode})
        assert res["finish"]["mode"] == mode and abs(res["rec_woc"] - 0.15625) < 1e-6
        assert "stepover scallop" not in (res["finish"]["limited_by"] or "")


def test_finish_named_facing_still_gets_the_cleanup_mode():
    assert _face(operation="Finish Facing")["finish"]["mode"] == "cleanup"
