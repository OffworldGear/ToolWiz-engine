import unittest
from types import SimpleNamespace

from app import app, physics
from pipeline import CutRequest, run_cut
from toolwiz_common import (
    CM_TO_IN,
    calc_corner_engagement,
    calc_thin_wall_compliance_factor,
    inspect_operation_geometry,
)


def _pt(x_in, y_in, z_in):
    """Build a mock Point3D in Fusion's internal cm units from inch coordinates."""
    return SimpleNamespace(x=x_in / CM_TO_IN, y=y_in / CM_TO_IN, z=z_in / CM_TO_IN)


def _vec(x, y, z):
    return SimpleNamespace(x=float(x), y=float(y), z=float(z))


def _bbox(x0_in, y0_in, z0_in, x1_in, y1_in, z1_in):
    return SimpleNamespace(minPoint=_pt(x0_in, y0_in, z0_in), maxPoint=_pt(x1_in, y1_in, z1_in))


class TestCamGeometryInspector(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.client = app.test_client()
        cls.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def test_holder_collision_detected_when_stickout_shorter_than_feature_depth(self):
        setup = SimpleNamespace(stockBoundingBox=_bbox(-2, -2, -1.0, 2, 2, 0.0))
        floor_face = SimpleNamespace(
            boundingBox=_bbox(-1, -1, -0.85, 1, 1, -0.85),
            normal=_vec(0, 0, 1),
            pointOnFace=_pt(0, 0, -0.85),
            geometry=None,
        )
        op = SimpleNamespace(selected_faces=[floor_face], parentSetup=setup)

        # Feature is 0.85" deep -> requires 0.95" reach (with 0.10" clearance), but tool stickout is 0.75"
        rep = inspect_operation_geometry(op, setup=setup, tool_diameter_in=0.25, stickout_in=0.75)
        self.assertAlmostEqual(rep.feature_depth_in, 0.85, places=4)
        self.assertAlmostEqual(rep.required_reach_in, 0.95, places=4)
        self.assertTrue(rep.stickout_collision)
        titles = [w["title"] for w in rep.warnings]
        self.assertIn("Holder Clearance / Stickout Too Short", titles)

        # Pipeline marks the cut infeasible when stickout_collision occurs
        res = run_cut(physics, CutRequest(
            family="Titanium Alloy",
            alloy="Ti-6Al-4V (Grade 5, Annealed)",
            diameter=0.25,
            flutes=4,
            flute_length=0.50,
            stickout=0.75,
            feature_geometry=rep.to_dict(),
        ))
        self.assertFalse(res.feasible)
        self.assertEqual(res.limited_by, "holder_clearance")

    def test_excessive_stickout_reports_choke_up_stiffness_gain(self):
        setup = SimpleNamespace(stockBoundingBox=_bbox(-2, -2, -1.0, 2, 2, 0.0))
        floor_face = SimpleNamespace(
            boundingBox=_bbox(-1, -1, -0.30, 1, 1, -0.30),
            normal=_vec(0, 0, 1),
            pointOnFace=_pt(0, 0, -0.30),
            geometry=None,
        )
        op = SimpleNamespace(selected_faces=[floor_face], parentSetup=setup)

        # Feature depth 0.30" -> required reach 0.40", tool stickout 1.00" (0.60" excess)
        rep = inspect_operation_geometry(op, setup=setup, tool_diameter_in=0.25, stickout_in=1.00)
        self.assertFalse(rep.stickout_collision)
        self.assertAlmostEqual(rep.excess_stickout_in, 0.60, places=4)
        self.assertGreater(rep.choke_up_stiffness_gain_pct, 80.0)
        titles = [w["title"] for w in rep.warnings]
        self.assertIn("Excessive Stickout vs Feature Depth", titles)

    def test_concave_internal_corner_radius_and_convex_boss_filtering(self):
        # 1/4" cutter (R_tool = 0.125") entering a 0.140" concave corner vs a 0.080" convex boss
        concave_fillet = SimpleNamespace(
            boundingBox=_bbox(0, 0, -0.5, 0.2, 0.2, 0.0),
            pointOnFace=_pt(0.140, 0.0, -0.25),
            normal=_vec(-1, 0, 0),  # points toward axis at (0,0) -> concave!
            geometry=SimpleNamespace(
                radius=0.140 / CM_TO_IN,
                origin=_pt(0.0, 0.0, -0.25),
                axis=_vec(0, 0, 1),
            ),
        )
        convex_boss = SimpleNamespace(
            boundingBox=_bbox(0, 0, -0.5, 0.2, 0.2, 0.0),
            pointOnFace=_pt(0.080, 0.0, -0.25),
            normal=_vec(1, 0, 0),  # points away from axis at (0,0) -> convex boss!
            geometry=SimpleNamespace(
                radius=0.080 / CM_TO_IN,
                origin=_pt(0.0, 0.0, -0.25),
                axis=_vec(0, 0, 1),
            ),
        )
        op = SimpleNamespace(selected_faces=[concave_fillet, convex_boss])
        rep = inspect_operation_geometry(
            op, tool_diameter_in=0.25, stickout_in=0.75, nominal_woc_in=0.025
        )
        # Convex boss (0.080") is ignored; concave fillet (0.140") is selected
        self.assertAlmostEqual(rep.min_corner_radius_in, 0.140, places=4)
        self.assertTrue(rep.corner_overload)
        self.assertLess(rep.corner_feed_scale, 0.70)
        self.assertGreater(rep.corner_woc_spike_in, 0.025)

    def test_thin_wall_and_thin_floor_opposing_planes_and_stock_compensation(self):
        # Two opposing vertical walls 0.040" (1.0 mm) apart, 0.60" tall
        wall_a = SimpleNamespace(
            boundingBox=_bbox(0.0, 0.0, -0.60, 0.0, 1.0, 0.0),
            normal=_vec(-1, 0, 0),
            pointOnFace=_pt(0.0, 0.5, -0.30),
            geometry=None,
        )
        wall_b = SimpleNamespace(
            boundingBox=_bbox(0.040, 0.0, -0.60, 0.040, 1.0, 0.0),
            normal=_vec(1, 0, 0),
            pointOnFace=_pt(0.040, 0.5, -0.30),
            geometry=None,
        )
        op = SimpleNamespace(selected_faces=[wall_a, wall_b])
        rep = inspect_operation_geometry(op, tool_diameter_in=0.25, stickout_in=0.75)
        self.assertAlmostEqual(rep.min_wall_thickness_in, 0.040, places=4)
        self.assertTrue(rep.is_thin_wall)
        self.assertGreater(rep.workpiece_compliance_factor, 1.2)

        # Verify /api/stock_compensation increases compensation and flags Thin Wall in advisory
        base_op = {
            "id": "op1",
            "name": "2D Contour Wall Finish",
            "strategy": "contour2d",
            "unit": "in",
            "length_unit": "in",
            "feed_unit": "ipm",
            "diameter": 0.25,
            "flutes": 4,
            "fluteLength": 0.75,
            "shankDiameter": 0.25,
            "stickout": 0.85,
            "rpm": 4000,
            "feedrate": 20.0,
            "doc": 0.50,
            "woc": 0.010,
        }
        r_rigid = self.client.post("/api/stock_compensation", json={
            "family": "Titanium Alloy",
            "alloy": "Ti-6Al-4V (Grade 5, Annealed)",
            "operations": [base_op],
        }).get_json()["results"][0]

        r_thin = self.client.post("/api/stock_compensation", json={
            "family": "Titanium Alloy",
            "alloy": "Ti-6Al-4V (Grade 5, Annealed)",
            "operations": [{**base_op, "feature_geometry": rep.to_dict()}],
        }).get_json()["results"][0]

        self.assertGreater(r_thin["total_error_in"], r_rigid["total_error_in"])
        self.assertIn("Thin Wall", r_thin["advisory"])

    def test_calculate_for_fusion_returns_corner_feed_and_brep_alerts(self):
        resp = self.client.post("/api/calculate_for_fusion", json={
            "family": "Stainless - PH (17-4 PH)",
            "alloy": "17-4 PH (H900 ~44 HRC)",
            "operation": "3D Adaptive Roughing",
            "diameter": 0.25,
            "flutes": 4,
            "fluteLength": 0.75,
            "shankDiameter": 0.25,
            "stickout": 0.85,
            "feature_geometry": {
                "feature_depth_in": 0.50,
                "min_corner_radius_in": 0.135,
                "min_wall_thickness_in": 0.045,
            },
        })
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertTrue(data["success"])
        self.assertIn("feature_geometry", data)
        self.assertIsNotNone(data.get("corner_feed"))
        self.assertLess(data["corner_feed"], data["feed"])
        alert_titles = [a["title"] for a in data.get("alerts", [])]
        self.assertIn("Tight Internal Corner Engagement Spike", alert_titles)
        self.assertIn("Thin-Wall Workpiece Compliance Detected", alert_titles)

    def test_tooth_apex_and_air_gap_vertical_planes_do_not_trigger_false_thin_wall(self):
        # 1. Air gap / gullet between two teeth facing each other (normals point toward each other -> proj > 0)
        flank_a = SimpleNamespace(
            boundingBox=_bbox(0.0, 0.0, -0.15, 0.0, 0.20, 0.0),
            normal=_vec(1, 0, 0),
            pointOnFace=_pt(0.0, 0.10, -0.075),
            geometry=None,
        )
        flank_b = SimpleNamespace(
            boundingBox=_bbox(0.030, 0.0, -0.15, 0.030, 0.20, 0.0),
            normal=_vec(-1, 0, 0),
            pointOnFace=_pt(0.030, 0.10, -0.075),
            geometry=None,
        )
        # 2. Two vertical faces at different Y locations on the frame whose infinite planes are 0.0020" apart
        remote_a = SimpleNamespace(
            boundingBox=_bbox(0.0, 0.0, -0.15, 0.0, 0.05, 0.0),
            normal=_vec(-1, 0, 0),
            pointOnFace=_pt(0.0, 0.025, -0.075),
            geometry=None,
        )
        remote_b = SimpleNamespace(
            boundingBox=_bbox(0.0020, 1.50, -0.15, 0.0020, 1.55, 0.0),
            normal=_vec(1, 0, 0),
            pointOnFace=_pt(0.0020, 1.525, -0.075),
            geometry=None,
        )
        # 3. Thin horizontal web elsewhere on the frame (0.0248" thick), inspected during a 2D Contour op
        floor_top = SimpleNamespace(
            boundingBox=_bbox(0.0, 0.0, -0.1000, 0.5, 0.5, -0.1000),
            normal=_vec(0, 0, 1),
            pointOnFace=_pt(0.25, 0.25, -0.1000),
            geometry=None,
        )
        floor_bot = SimpleNamespace(
            boundingBox=_bbox(0.0, 0.0, -0.1248, 0.5, 0.5, -0.1248),
            normal=_vec(0, 0, -1),
            pointOnFace=_pt(0.25, 0.25, -0.1248),
            geometry=None,
        )
        op = SimpleNamespace(
            name="2D Contour20 (TeethFinishingPath)",
            strategy="contour2d",
            selected_faces=[flank_a, flank_b, remote_a, remote_b, floor_top, floor_bot],
        )
        rep = inspect_operation_geometry(op, tool_diameter_in=0.040, stickout_in=0.375)
        self.assertIsNone(rep.min_wall_thickness_in)
        self.assertFalse(rep.is_thin_wall)
        self.assertIsNone(rep.min_floor_thickness_in)
        self.assertFalse(rep.is_thin_floor)
        titles = [w["title"] for w in rep.warnings]
        self.assertNotIn("Thin-Wall Workpiece Compliance Detected", titles)
        self.assertNotIn("Thin-Floor Workpiece Compliance Detected", titles)

    def test_thin_wall_threshold_scales_with_micro_tool_diameter(self):
        # A 0.045" wall is thin for a 0.250" end mill, but > 1.1x D (rigid) for a 0.040" micro end mill
        tw_quarter, _, _ = calc_thin_wall_compliance_factor(0.045, wall_height_in=0.12, tool_diameter_in=0.250)
        tw_micro, _, _ = calc_thin_wall_compliance_factor(0.045, wall_height_in=0.12, tool_diameter_in=0.040)
        tw_micro_thin, _, _ = calc_thin_wall_compliance_factor(0.018, wall_height_in=0.12, tool_diameter_in=0.040)
        self.assertTrue(tw_quarter)
        self.assertFalse(tw_micro)
        self.assertTrue(tw_micro_thin)

    def test_evaluator_outward_normal_prevents_convex_fillet_and_reversed_plane_false_positives(self):
        # Simulate real Fusion BRepFace objects where:
        # - Cylinder geometry has .axis = (0,0,1), while face.evaluator.getNormalAtPoint returns the outward normal
        # - Plane geometry has raw .normal unaffected by isParamReversed, while evaluator returns the true outward normal
        convex_tooth_tip_fillet = SimpleNamespace(
            boundingBox=_bbox(0.0, 0.0, -0.12, 0.008, 0.008, 0.0),
            pointOnFace=_pt(0.0039 * 2.54, 0.0, -0.06),
            evaluator=SimpleNamespace(getNormalAtPoint=lambda pt: (True, _vec(1, 0, 0))),
            geometry=SimpleNamespace(
                radius=0.0039 * 2.54,
                axis=_vec(0, 0, 1),
                origin=_pt(0.0, 0.0, -0.06),
            ),
        )
        concave_tooth_root = SimpleNamespace(
            boundingBox=_bbox(0.0, 0.0, -0.12, 0.12, 0.12, 0.0),
            pointOnFace=_pt(0.060 * 2.54, 0.0, -0.06),
            evaluator=SimpleNamespace(getNormalAtPoint=lambda pt: (True, _vec(-1, 0, 0))),
            geometry=SimpleNamespace(
                radius=0.060 * 2.54,
                axis=_vec(0, 0, 1),
                origin=_pt(0.0, 0.0, -0.06),
            ),
        )
        # Air gullet faces where geometry.normal was inverted due to isParamReversed=True,
        # but evaluator.getNormalAtPoint points outward into the gullet (toward each other)
        gullet_a = SimpleNamespace(
            boundingBox=_bbox(0.0, 0.0, -0.12, 0.0, 0.10, 0.0),
            pointOnFace=_pt(0.0, 0.05, -0.06),
            isParamReversed=True,
            evaluator=SimpleNamespace(getNormalAtPoint=lambda pt: (True, _vec(1, 0, 0))),
            geometry=SimpleNamespace(normal=_vec(-1, 0, 0), origin=_pt(0.0, 0.05, -0.06)),
        )
        gullet_b = SimpleNamespace(
            boundingBox=_bbox(0.0069 * 2.54, 0.0, -0.12, 0.0069 * 2.54, 0.10, 0.0),
            pointOnFace=_pt(0.0069 * 2.54, 0.05, -0.06),
            isParamReversed=True,
            evaluator=SimpleNamespace(getNormalAtPoint=lambda pt: (True, _vec(-1, 0, 0))),
            geometry=SimpleNamespace(normal=_vec(1, 0, 0), origin=_pt(0.0069 * 2.54, 0.05, -0.06)),
        )
        op = SimpleNamespace(
            name="Adaptive15 (RoughTeethFinal)",
            strategy="adaptive2d",
            selected_faces=[convex_tooth_tip_fillet, concave_tooth_root, gullet_a, gullet_b],
        )
        rep = inspect_operation_geometry(op, tool_diameter_in=0.040, stickout_in=0.375)
        self.assertAlmostEqual(rep.min_corner_radius_in, 0.060, places=3)
        self.assertIsNone(rep.min_wall_thickness_in)
        self.assertFalse(rep.is_thin_wall)
        self.assertFalse(rep.is_thin_floor)


if __name__ == "__main__":
    unittest.main()
