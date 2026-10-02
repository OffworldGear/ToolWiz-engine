import json
import os
import sys
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, ROOT)

from toolwiz_common import ToolProfile
from gwizard_physics import GWizardPhysics
from pipeline import CutRequest, run_cut
from app import app

FAMILY = "Aluminum - Wrought (6061)"


def fusion(dc=0.0625, lcf=0.1875, sfdm=0.125, lb=0.5, nof=2, unit="inches", **extra):
    geo = {"DC": dc, "LCF": lcf, "SFDM": sfdm, "LB": lb, "NOF": nof, "shoulder-length": lcf,
           "shoulder-diameter": dc, "OAL": lb + 1.0, "RE": 0, "TA": 0, "tip-diameter": 0}
    geo.update(extra)
    return {"type": "flat end mill", "unit": unit, "geometry": geo}


def assert_tiles(tc, prof):
    segs = prof.segments
    tc.assertTrue(segs)
    tc.assertAlmostEqual(segs[0].start, 0.0, places=12)
    for a, b in zip(segs, segs[1:]):
        tc.assertAlmostEqual(a.end, b.start, places=12, msg="gap/overlap between segments")
        tc.assertGreater(a.end, a.start)
    tc.assertAlmostEqual(segs[-1].end, prof.stickout, places=12)
    tc.assertGreater(segs[-1].end, segs[-1].start)


class TestToolProfile(unittest.TestCase):
    def test_t13_full(self):
        with open(os.path.join(ROOT, 't13_full.json')) as f:
            t = json.load(f)
        prof = ToolProfile.from_fusion(t)
        assert_tiles(self, prof)
        self.assertAlmostEqual(prof.stickout, t['geometry']['LB'])
        self.assertEqual([s.kind for s in prof.segments], ['flute', 'shank'])  # shoulder-length == LCF
        self.assertTrue(prof.segments[0].fluted)
        self.assertFalse(prof.segments[1].fluted)
        self.assertEqual(prof.warnings, [])

    def test_micro_on_big_shank_has_no_phantom_neck(self):
        prof = ToolProfile.from_fusion(fusion())
        assert_tiles(self, prof)
        self.assertEqual([s.kind for s in prof.segments], ['flute', 'shank'])
        self.assertAlmostEqual(prof.segments[0].d1, 0.0625)
        self.assertAlmostEqual(prof.segments[1].d0, 0.125)
        self.assertAlmostEqual(prof.segments[1].start, 0.1875)

    def test_neck(self):
        prof = ToolProfile.from_fusion(fusion(**{"shoulder-length": 0.375, "shoulder-diameter": 0.06}))
        assert_tiles(self, prof)
        self.assertEqual([s.kind for s in prof.segments], ['flute', 'neck', 'shank'])
        neck = prof.segments[1]
        self.assertAlmostEqual(neck.start, 0.1875)
        self.assertAlmostEqual(neck.end, 0.375)
        self.assertAlmostEqual(neck.d0, 0.06)
        self.assertFalse(neck.fluted)
        self.assertAlmostEqual(prof.segments[2].start, 0.375)
        self.assertEqual(prof.warnings, [])

    def test_neck_zero_diameter_falls_back_to_dc(self):
        prof = ToolProfile.from_fusion(fusion(**{"shoulder-length": 0.375, "shoulder-diameter": 0}))
        self.assertAlmostEqual(prof.segments[1].d0, 0.0625)

    def test_tapered(self):
        prof = ToolProfile.from_fusion(fusion(dc=0.25, lcf=1.0, sfdm=0.25, lb=2.0, nof=3,
                                              TA=2.0, **{"tip-diameter": 0.1, "shoulder-length": 1.0}))
        assert_tiles(self, prof)
        fl = prof.segments[0]
        self.assertAlmostEqual(fl.d0, 0.1)
        self.assertAlmostEqual(fl.d1, 0.25)
        self.assertTrue(fl.fluted)

    def test_taper_without_tip_diameter_is_straight(self):
        prof = ToolProfile.from_fusion(fusion(dc=0.25, lcf=1.0, TA=2.0, lb=2.0))
        self.assertAlmostEqual(prof.segments[0].d0, 0.25)

    def test_metric(self):
        t = {"type": "flat end mill", "unit": "millimeters",
             "geometry": {"DC": 6.0, "LCF": 15.0, "SFDM": 6.0, "LB": 40.0, "NOF": 3,
                          "shoulder-length": 25.0, "shoulder-diameter": 5.0}}
        prof = ToolProfile.from_fusion(t)
        assert_tiles(self, prof)
        self.assertAlmostEqual(prof.stickout, 40.0 / 25.4)
        self.assertEqual([s.kind for s in prof.segments], ['flute', 'neck', 'shank'])
        self.assertAlmostEqual(prof.segments[1].d0, 5.0 / 25.4)

    def test_holder_over_flutes(self):
        prof = ToolProfile.from_fusion(fusion(lcf=0.5, lb=0.3, **{"shoulder-length": 0.5}))
        assert_tiles(self, prof)
        self.assertEqual([s.kind for s in prof.segments], ['flute'])
        self.assertIn("Holder over flutes", prof.warnings)

    def test_holder_over_flutes_taper_interpolates(self):
        prof = ToolProfile.from_fusion(fusion(dc=0.25, lcf=1.0, lb=0.5, TA=2.0, **{"tip-diameter": 0.1}))
        self.assertAlmostEqual(prof.segments[0].d1, 0.175)

    def test_holder_over_neck(self):
        prof = ToolProfile.from_fusion(fusion(lb=0.3, **{"shoulder-length": 0.5, "shoulder-diameter": 0.05}))
        assert_tiles(self, prof)
        self.assertEqual([s.kind for s in prof.segments], ['flute', 'neck'])
        self.assertAlmostEqual(prof.segments[-1].end, 0.3)
        self.assertIn("Holder over neck", prof.warnings)
        self.assertNotIn("Holder over flutes", prof.warnings)

    def test_stickout_override_and_source(self):
        prof = ToolProfile.from_fusion(fusion(), stickout_override=0.4)
        assert_tiles(self, prof)
        self.assertEqual(prof.stickout_source, "override")
        self.assertAlmostEqual(prof.stickout, 0.4)
        self.assertEqual(ToolProfile.from_fusion(fusion()).stickout_source, "fusion_LB")

    def test_to_dict(self):
        d = ToolProfile.from_fusion(fusion()).to_dict()
        self.assertEqual(set(d), {"segments", "stickout", "stickout_source", "warnings"})
        self.assertEqual(set(d["segments"][0]), {"kind", "start", "end", "d0", "d1", "fluted"})
        json.dumps(d)

    def test_from_legacy_semantics(self):
        # no relieved neck: shank starts right after the flutes
        p = ToolProfile.from_legacy(0.0625, 2, 0.1875, 0.125, 0.5)
        assert_tiles(self, p)
        self.assertEqual([s.kind for s in p.segments], ['flute', 'shank'])
        # relieved neck: neck_length is tip-to-shoulder
        p = ToolProfile.from_legacy(0.0625, 2, 0.1875, 0.125, 0.5, has_relieved_neck=True,
                                    neck_diameter=0.05, neck_length=0.375)
        assert_tiles(self, p)
        self.assertEqual([s.kind for s in p.segments], ['flute', 'neck', 'shank'])
        self.assertAlmostEqual(p.segments[1].end, 0.375)
        self.assertAlmostEqual(p.segments[1].d0, 0.05)


class TestFusionToolPipelineParity(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.physics = GWizardPhysics(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "materials_database_clean.json"))
        cls.client = app.test_client()
        cls.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def _compare(self, tool, legacy_kwargs):
        common = dict(family=FAMILY, tool="Carbide Endmill", operation="Roughing",
                      cut_depth=None, cut_width=None)
        a = run_cut(self.physics, CutRequest(fusion_tool=tool, stickout=None, **common))
        b = run_cut(self.physics, CutRequest(**legacy_kwargs, **common))
        for k in ("rpm", "feed_ipm", "rec_doc", "rec_woc", "deflection", "adj_ipt"):
            self.assertAlmostEqual(getattr(a, k), getattr(b, k),
                                   delta=max(abs(getattr(b, k)) * 0.005, 1e-9), msg=k)
        self.assertIsNotNone(a.profile)
        self.assertIn("segments", a.profile)
        return a, b

    def test_plain_tool(self):
        tool = fusion(dc=0.5, lcf=1.0, sfdm=0.5, lb=2.0, nof=4)
        self._compare(tool, dict(diameter=0.5, flutes=4, flute_length=1.0, shank_diameter=0.5, stickout=2.0))

    def test_micro_tool_on_big_shank(self):
        self._compare(fusion(), dict(diameter=0.0625, flutes=2, flute_length=0.1875,
                                     shank_diameter=0.125, stickout=0.5))

    def test_fusion_tool_overrides_conflicting_request_fields(self):
        r = run_cut(self.physics, CutRequest(family=FAMILY, fusion_tool=fusion(), stickout=None,
                                             diameter=0.5, flutes=4, flute_length=1.0, shank_diameter=0.5))
        self.assertAlmostEqual(r.diameter, 0.0625)
        self.assertAlmostEqual(r.shank_diameter, 0.125)
        self.assertAlmostEqual(r.profile["stickout"], 0.5)

    def test_neck_makes_deflection_larger(self):
        base = fusion(dc=0.25, lcf=0.5, sfdm=0.25, lb=2.0, nof=4)
        neck = fusion(dc=0.25, lcf=0.5, sfdm=0.25, lb=2.0, nof=4,
                      **{"shoulder-length": 1.5, "shoulder-diameter": 0.2})
        kw = dict(family=FAMILY, cut_depth=0.25, cut_width=0.05)
        d0 = run_cut(self.physics, CutRequest(fusion_tool=base, stickout=None, **kw)).deflection
        d1 = run_cut(self.physics, CutRequest(fusion_tool=neck, stickout=None, **kw)).deflection
        self.assertGreater(d1, d0)

    def test_endpoints_agree(self):
        tool = fusion(dc=0.25, lcf=0.75, sfdm=0.25, lb=1.5, nof=4)
        body = {"family": FAMILY, "operation": "Roughing", "tool": "Carbide Endmill", "fusion_tool": tool}
        rf = self.client.post("/api/calculate_for_fusion", json=body)
        self.assertEqual(rf.status_code, 200, rf.get_data(as_text=True))
        f = rf.get_json()
        self.assertIn("segments", f["profile"])
        rc = self.client.post("/api/calculate", json=dict(body, cutDepth=f["doc"], cutWidth=f["woc"]))
        self.assertEqual(rc.status_code, 200, rc.get_data(as_text=True))
        c = rc.get_json()
        self.assertIn("segments", c["profile"])
        self.assertEqual(c["rpm"], f["rpm"])
        self.assertAlmostEqual(c["adj_ipt"], f["ipt"], delta=f["ipt"] * 0.005)
        self.assertEqual(c["profile"], f["profile"])

    def test_bad_fusion_tool_is_400(self):
        r = self.client.post("/api/calculate", json={"fusion_tool": {"type": "flat end mill"}})
        self.assertEqual(r.status_code, 400)

    def test_stock_compensation_accepts_fusion_tool(self):
        tool = fusion(dc=0.375, lcf=0.75, sfdm=0.375, lb=1.25, nof=4)
        common = {"id": "o1", "name": "Finish Wall", "strategy": "contour2d", "unit": "inches",
                  "rpm": 4500, "feedrate": 35.0, "doc": 0.5, "woc": 0.015}
        op = dict(common, fusion_tool=tool)
        legacy = dict(common, diameter=0.375, flutes=4, fluteLength=0.75, shankDiameter=0.375, stickout=1.25)
        out = []
        for o in (op, legacy):
            r = self.client.post("/api/stock_compensation", json={"family": "Titanium Alloy", "operations": [o]})
            self.assertEqual(r.status_code, 200, r.get_data(as_text=True))
            out.append(r.get_json()["results"][0])
        self.assertIn("profile", out[0])
        self.assertAlmostEqual(out[0]["deflection_in"], out[1]["deflection_in"],
                               delta=out[1]["deflection_in"] * 0.005)

    def test_twin_tool_endpoint(self):
        r = self.client.get("/api/twin/tool/99999999")
        self.assertEqual(r.status_code, 404)
        self.assertFalse(r.get_json()["success"])
        r = self.client.get("/api/twin/tool/0")
        if r.status_code == 200:
            self.assertTrue(r.get_json()["success"])
            self.assertIn("geometry", r.get_json()["tool"])
        else:
            self.assertEqual(r.status_code, 404)  # empty library



class TestAddinFusionToolPayload(unittest.TestCase):
    def test_build_calc_payload_sends_fusion_tool(self):
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        from test_addin_common import load_addin
        addin = load_addin()
        t = fusion()
        t["extra"] = "ignored"
        geo = {"diameter": 0.0625, "flutes": 2, "fluteLength": 0.1875, "shankDiameter": 0.125,
               "cornerRadius": 0.0, "stickout": 0.5, "geometry": "Square", "raw_json": json.dumps(t)}
        p = addin.build_calc_payload(geo, FAMILY, "", "Roughing", 50, "Carbide", "AlTiN")
        self.assertEqual(set(p["fusion_tool"]), {"type", "unit", "geometry"})
        self.assertEqual(p["fusion_tool"]["geometry"]["DC"], 0.0625)
        self.assertEqual(p["diameter"], 0.0625)  # legacy fields kept
        geo.pop("raw_json")
        self.assertNotIn("fusion_tool", addin.build_calc_payload(geo, FAMILY, "", "Roughing", 50, "Carbide", "AlTiN"))


if __name__ == '__main__':
    unittest.main()
