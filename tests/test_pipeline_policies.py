import math
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import app as app_module
from pipeline import CutRequest, run_cut

P = app_module.physics


class TestPipelinePolicies(unittest.TestCase):
    def test_chamfer_rpm_uses_major_diameter(self):
        # Shallow chamfer: contact diameter is small, but vendors size RPM on the major diameter.
        r = run_cut(P, CutRequest(family="Aluminum - Wrought (6061)", tool="Carbide Endmill", geometry="Chamfer",
                                  operation="Chamfering", diameter=0.5, flutes=4, flute_length=0.25,
                                  stickout=1.0, cut_depth=0.02, cut_width=0.02, max_rpm=60000))
        self.assertLess(r.effective_diameter, 0.5)
        expected_rpm = r.target_sfm * 12.0 / (math.pi * 0.5)
        self.assertAlmostEqual(r.rpm, expected_rpm, delta=expected_rpm * 0.01)

    def test_ball_nose_still_uses_contact_diameter(self):
        r = run_cut(P, CutRequest(family="Aluminum - Wrought (6061)", geometry="Ball", operation="Finishing",
                                  diameter=0.5, flutes=2, flute_length=1.0, stickout=1.5,
                                  cut_depth=0.02, cut_width=0.02, max_rpm=60000))
        self.assertGreater(r.rpm, r.target_sfm * 12.0 / (math.pi * 0.5) * 1.5)

    def test_apply_coating_false_skips_multiplier(self):
        base = dict(family="Steel - Medium Carbon (1045)", tool="HP Carbide Twist Drill", geometry="Square",
                    operation="Drilling", coating="AlTiN", diameter=0.25, flutes=2, flute_length=1.0,
                    stickout=1.5, max_rpm=60000)
        with_c = run_cut(P, CutRequest(**base))
        without = run_cut(P, CutRequest(**base, apply_coating=False))
        self.assertGreater(with_c.rpm, without.rpm * 1.2)
        step = [s for s in without.provenance if s["step"] == "coating"][0]
        self.assertEqual(step["multiplier"], 1.0)


class TestBatchTapPolicy(unittest.TestCase):
    def setUp(self):
        self.client = app_module.app.test_client()
        self.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
        import tempfile
        from backup_manager import BackupManager
        self.tmp = tempfile.TemporaryDirectory()
        self._bm = app_module.bm
        app_module.bm = BackupManager(base_dir=self.tmp.name)

    def tearDown(self):
        app_module.bm = self._bm
        self.tmp.cleanup()

    def tap_rpm(self, description):
        tool = {"guid": "t", "type": "tap right hand", "unit": "inches", "description": description,
                "geometry": {"DC": 0.25, "NOF": 4, "LCF": 0.75, "TP": 0.05}, "post-process": {"number": 5}}
        self.client.post("/api/twin/export_receive", json={"library_name": "T", "tools": [tool]})
        self.client.post("/api/twin/batch_generate", json={"tool_indices": "all", "family": "Steel - Low Carbon (1020)",
                                                           "alloy": "1018", "strategies": ["Roughing"]})
        lib = self.client.get("/api/twin/get_import_payload").get_json()["library"]
        return lib["tools"][0]["start-values"]["presets"][0]["n"]

    def test_form_multiplier_only_for_form_taps(self):
        cut = self.tap_rpm("1/4-20 spiral point tap")
        form = self.tap_rpm("1/4-20 form tap")
        self.assertGreater(form, cut * 1.5)


if __name__ == "__main__":
    unittest.main()
