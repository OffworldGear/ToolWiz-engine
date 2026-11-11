"""Widths measured from the op's selection / B-Rep (toolwiz_common.cam_geometry_inspector), with Fusion objects mocked."""
import unittest
from types import SimpleNamespace

from toolwiz_common import CM_TO_IN, contour_effective_width_in, measure_op_widths
from toolwiz_common import cam_geometry_inspector as cgi


def pt(x, y, z):
    return SimpleNamespace(x=x / CM_TO_IN, y=y / CM_TO_IN, z=z / CM_TO_IN)


def bb(x0, y0, z0, x1, y1, z1):
    return SimpleNamespace(minPoint=pt(x0, y0, z0), maxPoint=pt(x1, y1, z1))


def vec(x, y, z):
    return SimpleNamespace(x=float(x), y=float(y), z=float(z))


def plane(n, p, box, edges=None, loops=None, area=None):
    f = SimpleNamespace(normal=vec(*n), pointOnFace=pt(*p), boundingBox=box, geometry=SimpleNamespace(), edges=edges or [])
    if loops is not None:
        f.loops = loops
        f.area = area
    return f


def cyl(r, c, axis=(0, 0, 1), concave=True, z=(-0.5, 0)):
    return SimpleNamespace(geometry=SimpleNamespace(radius=r / CM_TO_IN, axis=vec(*axis), origin=pt(c[0], c[1], 0)),
                           pointOnFace=pt(c[0] + r, c[1], -0.25), is_concave=concave, boundingBox=bb(c[0] - r, c[1] - r, z[0], c[0] + r, c[1] + r, z[1]),
                           normal=None)


def slot_walls(width=0.4, length=3.0, depth=0.5):
    # walls of a slot along X, y from 0 to width; the air is between them: outward normals face each other
    w1 = plane((0, 1, 0), (1, 0, -depth / 2), bb(0, 0, -depth, length, 0, 0))
    w2 = plane((0, -1, 0), (1, width, -depth / 2), bb(0, width, -depth, length, width, 0))
    return w1, w2


class TestEffectiveWidth(unittest.TestCase):
    def test_formula(self):
        self.assertAlmostEqual(contour_effective_width_in(0.25, 4, 0.06), 0.25 + 3 * 0.06)
        self.assertAlmostEqual(contour_effective_width_in(0.25, 1, 0.06), 0.25)
        self.assertAlmostEqual(contour_effective_width_in(0.25, None, None), 0.25)
        self.assertIsNone(contour_effective_width_in(None, 3, 0.1))


class TestGaps(unittest.TestCase):
    def test_parallel_walls_gap_and_length(self):
        g = cgi.measure_wall_gaps(slot_walls(0.4, 3.0))
        self.assertEqual(len(g), 1)
        self.assertAlmostEqual(g[0]["gap_in"], 0.4, places=4)
        self.assertEqual(g[0]["kind"], "parallel_walls")
        self.assertAlmostEqual(g[0]["length_in"], 3.0, places=3)
        self.assertAlmostEqual(g[0]["height_in"], 0.5, places=3)

    def test_solid_between_is_not_a_channel(self):
        w1 = plane((0, -1, 0), (1, 0, -0.25), bb(0, 0, -0.5, 3, 0, 0))     # a rib: normals point away from each other
        w2 = plane((0, 1, 0), (1, 0.1, -0.25), bb(0, 0.1, -0.5, 3, 0.1, 0))
        self.assertEqual(cgi.measure_wall_gaps([w1, w2]), [])

    def test_bore_and_annular_groove(self):
        self.assertAlmostEqual(cgi.measure_wall_gaps([cyl(0.25, (0, 0))])[0]["gap_in"], 0.5, places=4)
        g = cgi.measure_wall_gaps([cyl(0.5, (0, 0)), cyl(0.3, (0, 0), concave=False)])
        self.assertEqual([x["kind"] for x in g], ["concentric_cylinders"])
        self.assertAlmostEqual(g[0]["gap_in"], 0.2, places=4)


class TestTslotDepth(unittest.TestCase):
    def test_groove_depth(self):
        kerf = 0.0625
        # groove between z=-0.30 and z=-0.2375 (kerf), opening wall at y=0 (normal -y, toward the cutter), back wall at y=0.2 (normal -y)
        roof = plane((0, 0, -1), (0.1, 0.1, -0.2375), bb(0, 0, -0.2375, 3, 0.2, -0.2375))     # groove roof faces down into the air
        floor = plane((0, 0, 1), (0.1, 0.1, -0.30), bb(0, 0, -0.30, 3, 0.2, -0.30))
        back = plane((0, -1, 0), (1, 0.2, -0.27), bb(0, 0.2, -0.30, 3, 0.2, -0.2375))
        opening = plane((0, -1, 0), (1, 0.0, -0.1), bb(0, 0, -0.2375, 3, 0, 0))
        r = cgi.measure_tslot_radial_depth([roof, floor, back, opening], kerf)
        self.assertIsNotNone(r)
        self.assertAlmostEqual(r["radial_depth_in"], 0.2, places=3)
        self.assertEqual(r["grooves"], 1)
        self.assertIsNone(cgi.measure_tslot_radial_depth([roof, floor, back, opening], 0.5))   # wrong kerf: no groove


class Loop:
    def __init__(self, edges, outer):
        self.edges, self.isOuter = edges, outer


def edge(length, radius=None, faces=None):
    return SimpleNamespace(length=length / CM_TO_IN, geometry=SimpleNamespace(radius=None if radius is None else radius / CM_TO_IN), faces=faces or [])


class TestPocketAndSelection(unittest.TestCase):
    def pocket_floor(self):
        # 3 x 2 pocket, r = 0.125 corners (4 arcs + 4 lines), one round island of circumference 1.0
        arcs = [edge(0.2, 0.125) for _ in range(4)]
        lines = [edge(2.75), edge(1.75), edge(2.75), edge(1.75)]
        isl = [edge(1.0, 0.16)]
        floor = plane((0, 0, 1), (1.5, 1, -0.5), bb(0, 0, -0.5, 3, 2, -0.5), loops=[Loop(arcs + lines, True), Loop(isl, False)], area=5.0 / CM_TO_IN ** 2)
        return floor

    def op_with(self, sel_geometry, pname="pockets"):
        sel = SimpleNamespace(inputGeometry=sel_geometry)
        val = SimpleNamespace(getCurveSelections=lambda: [sel])
        params = SimpleNamespace(itemByName=lambda n: SimpleNamespace(value=val) if n == pname else None)
        return SimpleNamespace(parameters=params)

    def test_pocket_metrics_from_selected_floor_face(self):
        m = measure_op_widths(self.op_with([self.pocket_floor()]), 0.25)
        self.assertAlmostEqual(m["pocket_area_in2"], 5.0, places=3)
        self.assertAlmostEqual(m["pocket_perimeter_in"], 0.8 + 9.0, places=3)
        self.assertAlmostEqual(m["pocket_island_perimeter_in"], 1.0, places=3)
        self.assertAlmostEqual(m["pocket_min_corner_radius_in"], 0.125, places=4)   # the island's own radius is not a corner

    def test_chain_edges_reach_the_floor_and_walls(self):
        floor = self.pocket_floor()
        w1, w2 = slot_walls(0.4, 3.0)
        e = SimpleNamespace(length=1.0, geometry=SimpleNamespace(), faces=[floor, w1, w2])
        m = measure_op_widths(self.op_with([e], "contours"), 0.25)
        self.assertAlmostEqual(m["channel_width_in"], 0.4, places=4)
        self.assertIn("pocket_area_in2", m)

    def test_unreadable_selection_measures_nothing(self):
        self.assertEqual(measure_op_widths(SimpleNamespace(parameters=None), 0.25), {})
        bad = SimpleNamespace(parameters=SimpleNamespace(itemByName=lambda n: (_ for _ in ()).throw(RuntimeError("x"))))
        self.assertEqual(measure_op_widths(bad, 0.25), {})
        self.assertEqual(measure_op_widths(self.op_with([]), 0.25), {})


if __name__ == "__main__":
    unittest.main()
