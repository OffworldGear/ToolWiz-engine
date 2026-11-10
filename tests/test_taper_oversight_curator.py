"""Unit tests for:
1. Continuous shaft taper (0.5 mm below holder) & explicit `shaft.segments` in ToolProfile.
2. Holistic Oversight Engine (`oversight_engine.py`, `/api/oversight_review`, MCP `toolwiz_holistic_oversight`).
3. Tool Library Curator (`tool_library_curator.py`, `/api/library/curate`, MCP `toolwiz_curate_tool_library`).
"""
import unittest

from app import app
from gwizard_physics import BeamDeflectionEngine
from mcp_server import call_mcp_tool_by_name, list_mcp_tools
from oversight_engine import evaluate_holistic_oversight
from tool_library_curator import curate_tool_dict, curate_tool_library
from toolwiz_common import HOLDER_TAPER_MARGIN_IN, ToolProfile


class TestContinuousShaftTaperAndExplicitSegments(unittest.TestCase):
    def test_continuous_taper_to_half_mm_below_holder_increases_deflection(self):
        tool = {
            "type": "flat end mill",
            "unit": "inches",
            "geometry": {
                "DC": 0.03125,
                "NOF": 3,
                "LCF": 0.09375,
                "SFDM": 0.125,
                "LB": 0.40,
            },
        }
        prof_taper = ToolProfile.from_fusion(tool)
        prof_step = ToolProfile.from_fusion(tool, assume_shaft_taper=False)

        self.assertEqual(prof_taper.shaft_source, "assumed_taper")
        self.assertEqual([s.kind for s in prof_taper.segments], ["flute", "taper", "shank"])
        taper_seg = prof_taper.segments[1]
        shank_seg = prof_taper.segments[2]
        self.assertAlmostEqual(taper_seg.start, 0.09375, places=6)
        self.assertAlmostEqual(taper_seg.end, 0.40 - HOLDER_TAPER_MARGIN_IN, places=6)
        self.assertAlmostEqual(taper_seg.d0, 0.03125, places=6)
        self.assertAlmostEqual(taper_seg.d1, 0.125, places=6)
        self.assertAlmostEqual(shank_seg.length, HOLDER_TAPER_MARGIN_IN, places=6)

        defl_taper = BeamDeflectionEngine.deflection_from_segments(2.0, prof_taper.segments, 3, 30.0, True)
        defl_step = BeamDeflectionEngine.deflection_from_segments(2.0, prof_step.segments, 3, 30.0, True)
        # Gradual taper is significantly more compliant than an instant step to 1/8" at LCF
        self.assertGreater(defl_taper, defl_step * 1.7)

    def test_explicit_fusion_shaft_segments_parsed_and_match_curated_taper(self):
        raw_tool = {
            "type": "flat end mill",
            "unit": "inches",
            "description": "1/16 4FL AlTiN Stub",
            "geometry": {
                "DC": 0.0625,
                "NOF": 4,
                "LCF": 0.1875,
                "SFDM": 0.125,
                "LB": 0.50,
                "OAL": 1.50,
            },
        }
        curated = curate_tool_dict(raw_tool).curated_tool
        self.assertIn("shaft", curated)
        self.assertTrue(len(curated["shaft"]["segments"]) >= 2)

        prof_assumed = ToolProfile.from_fusion(raw_tool)
        prof_explicit = ToolProfile.from_fusion(curated)
        self.assertEqual(prof_explicit.shaft_source, "explicit_shaft")

        d_assumed = BeamDeflectionEngine.deflection_from_segments(3.0, prof_assumed.segments, 4, 30.0, True)
        d_explicit = BeamDeflectionEngine.deflection_from_segments(3.0, prof_explicit.segments, 4, 30.0, True)
        self.assertAlmostEqual(d_assumed, d_explicit, delta=d_assumed * 0.002)


class TestHolisticOversightEngine(unittest.TestCase):
    def test_altin_in_aluminum_and_wall_rubbing_flagged_as_stop(self):
        req = {
            "family": "Aluminum - Wrought (6061)",
            "alloy": "6061-T6",
            "operation": "Slotting",
            "coating": "AlTiN",
            "diameter": 0.0625,
            "flutes": 4,
            "fluteLength": 0.1875,
            "shankDiameter": 0.125,
        }
        res = {
            "diameter": 0.0625,
            "flute_length": 0.1875,
            "shank_diameter": 0.125,
            "doc": 0.12,
            "woc": 0.0625,
            "rpm": 16000,
            "feed_ipm": 20.0,
            "adj_ipt": 0.0003,
            "deflection": 0.0002,
            "rec_limit": 0.0004,
            "feasible": True,
            "profile": {
                "segments": [
                    {"kind": "flute", "start": 0.0, "end": 0.1875, "d0": 0.0625, "d1": 0.0625, "fluted": True},
                    {"kind": "taper", "start": 0.1875, "end": 0.4803, "d0": 0.0625, "d1": 0.125, "fluted": False},
                    {"kind": "shank", "start": 0.4803, "end": 0.50, "d0": 0.125, "d1": 0.125, "fluted": False},
                ]
            },
        }
        # Feature depth 0.30" exceeds flute length 0.1875" with no reduced neck -> taper rubs wall
        fgeo = {"feature_depth_in": 0.30}
        report = evaluate_holistic_oversight(req, res, feature_geometry=fgeo)
        self.assertEqual(report.verdict, "STOP")
        altin_finding = next(f for f in report.findings if "AlTiN" in f.title)
        self.assertEqual(altin_finding.severity, "CAUTION")  # Warn, do not block AlTiN in aluminum
        wall_finding = next(f for f in report.findings if "Rub Vertical Feature Wall" in f.title)
        self.assertEqual(wall_finding.severity, "STOP")
        titles = [f.title for f in report.findings]
        self.assertTrue(any("Deep Full-Width Slot" in t for t in titles))

        # Unknown / ambiguous coating is flagged (not guessed)
        ambig_rep = evaluate_holistic_oversight(
            {"family": "Aluminum - Wrought (6061)", "coating": "ti coated", "diameter": 0.25, "flutes": 3},
            {"diameter": 0.25, "flute_length": 0.75, "shank_diameter": 0.25, "doc": 0.2, "woc": 0.05, "feasible": True},
        )
        self.assertEqual(ambig_rep.verdict, "CAUTION")
        self.assertTrue(any("Unknown or Ambiguous" in f.title for f in ambig_rep.findings))

    def test_oversight_endpoint_and_mcp_tool(self):
        with app.test_client() as client:
            resp = client.post(
                "/api/oversight_review",
                json={
                    "family": "Stainless - PH Series (17-4)",
                    "alloy": "17-4 PH (H1025)",
                    "operation": "Adaptive Roughing",
                    "coating": "ZrN",
                    "diameter": 0.25,
                    "flutes": 2,
                    "fluteLength": 0.75,
                    "shankDiameter": 0.25,
                },
                headers={"X-ToolWiz-Client": "unit-test"},
            )
            self.assertEqual(resp.status_code, 200)
            data = resp.get_json()
            self.assertTrue(data["success"])
            self.assertEqual(data["verdict"], "CAUTION")
            self.assertTrue(any("Non-Thermal Coating" in f["title"] for f in data["findings"]))

        mcp_res = call_mcp_tool_by_name(
            "toolwiz_holistic_oversight",
            {
                "family": "Aluminum - Wrought (6061)",
                "operation": "Adaptive Roughing",
                "coating": "Uncoated",
                "diameter": 0.25,
                "flutes": 3,
            },
        )
        self.assertTrue(mcp_res["success"])
        self.assertEqual(mcp_res["verdict"], "PASS")


class TestToolLibraryCurator(unittest.TestCase):
    def test_curate_fixes_micro_shank_adds_taper_and_infers_coating_and_radius(self):
        broken_micro = {
            "type": "bull nose end mill",
            "unit": "inches",
            "description": "Harvey 1/32\" 4FL AlTiN Bullnose R0.005",
            "post-process": {"number": 14},
            "geometry": {
                "DC": 0.03125,
                "NOF": 4,
                "LCF": 0.09375,
                "SFDM": 0.03125,  # Mistakenly left at DC!
                "LB": 0.35,
            },
        }
        report = curate_tool_library([broken_micro])
        self.assertEqual(report["total_tools"], 1)
        self.assertEqual(report["modified_tools"], 1)
        curated = report["curated_tools"][0]
        self.assertAlmostEqual(curated["geometry"]["SFDM"], 0.125, places=5)
        self.assertAlmostEqual(curated["geometry"]["RE"], 0.005, places=5)
        self.assertEqual(curated["BMC"], "AlTiN")
        self.assertIn("shaft", curated)
        segs = curated["shaft"]["segments"]
        self.assertEqual(len(segs), 2)
        self.assertAlmostEqual(segs[0]["lower-diameter"], 0.03125, places=5)
        self.assertAlmostEqual(segs[0]["upper-diameter"], 0.125, places=5)

        # Unknown or ambiguous coating in description is flagged, never guessed
        unknown_coat_tool = {
            "type": "flat end mill",
            "unit": "inches",
            "description": "1/4\" 3FL Carbide Endmill",
            "BMC": "ti coated",
            "geometry": {"DC": 0.25, "NOF": 3, "LCF": 0.75, "SFDM": 0.25, "LB": 1.25, "OAL": 2.5},
        }
        u_res = curate_tool_dict(unknown_coat_tool)
        self.assertEqual(u_res.curated_tool["BMC"], "ti coated")
        self.assertFalse(any(c.field == "BMC" for c in u_res.changes))
        self.assertTrue(any("flagged for manual verification without guessing" in w for w in u_res.warnings))

        ambig_coat_tool = {
            "type": "flat end mill",
            "unit": "inches",
            "description": "1/4\" 3FL AlTiN / ZrN Endmill",
            "BMC": "carbide",
            "geometry": {"DC": 0.25, "NOF": 3, "LCF": 0.75, "SFDM": 0.25, "LB": 1.25, "OAL": 2.5},
        }
        a_res = curate_tool_dict(ambig_coat_tool)
        self.assertEqual(a_res.curated_tool["BMC"], "carbide")
        self.assertTrue(any("Ambiguous tool coating" in w for w in a_res.warnings))

    def test_curate_endpoint_and_mcp_tool(self):
        tool_Names = [t["name"] for t in list_mcp_tools()]
        self.assertIn("toolwiz_holistic_oversight", tool_Names)
        self.assertIn("toolwiz_curate_tool_library", tool_Names)

        mcp_res = call_mcp_tool_by_name(
            "toolwiz_curate_tool_library",
            {
                "tools": [
                    {
                        "type": "flat end mill",
                        "unit": "millimeters",
                        "description": "1.5mm 3FL ZrN Micro Endmill",
                        "geometry": {"DC": 1.5, "NOF": 3, "LCF": 4.5, "SFDM": 1.5, "LB": 12.0},
                    }
                ]
            },
        )
        self.assertTrue(mcp_res["success"])
        self.assertEqual(mcp_res["modified_tools"], 1)
        ct = mcp_res["curated_tools"][0]
        self.assertAlmostEqual(ct["geometry"]["SFDM"], 3.175, places=3)
        self.assertEqual(ct["BMC"], "ZrN")
        self.assertTrue(len(ct["shaft"]["segments"]) == 2)


if __name__ == "__main__":
    unittest.main()
