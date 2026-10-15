"""Machine profiles: torque curve interpolation, validation, settings migration."""
import json
import math
import os
import tempfile
import unittest

import machine_profiles as mp


def speedio_16k():
    with open(os.path.join(mp.BUILTIN_DIR, "speedio_s500x2.json"), encoding="utf-8") as fh:
        return json.load(fh)["spindle_options"]["optional_16k"]


class TestCapacity(unittest.TestCase):
    def test_speedio_16k_reproduces_the_quoted_torques(self):
        sp = speedio_16k()
        for rpm, nm in ((8000, 8.8), (12000, 5.9), (16000, 4.4)):
            self.assertAlmostEqual(mp.capacity(sp, rpm, "s3_15pct_10min")["torque_nm"], nm, places=2)
        self.assertAlmostEqual(mp.capacity(sp, 2000, "momentary")["torque_nm"], 40.0)

    def test_constant_power_segment_is_exact_between_points(self):
        # Linear torque interpolation would give 12.74 N·m at 6000 rpm; constant 7.4 kW gives 11.78.
        sp = speedio_16k()
        cap = mp.capacity(sp, 6000, "s3_15pct_10min")
        self.assertAlmostEqual(cap["power_kw"], 7.39, places=1)
        self.assertAlmostEqual(cap["torque_nm"], 7.39e3 / (6000 * 2 * math.pi / 60), delta=0.05)

    def test_continuous_rating_caps_torque_below_base_speed(self):
        cap = mp.capacity(speedio_16k(), 764)
        self.assertAlmostEqual(cap["torque_nm"], 10.82, places=2)
        self.assertLess(cap["power_kw"], 1.0)   # power-only would allow 5.1 kW

    def test_curve_built_from_power_when_no_points(self):
        sp = {"max_rpm": 12000, "base_rpm": 3000, "power_kw_continuous": 7.5}
        pts = mp.rating_points(sp)
        self.assertEqual(pts[0][0], 0.0)
        self.assertAlmostEqual(pts[0][1], 7.5e3 / (3000 * 2 * math.pi / 60), places=1)
        self.assertAlmostEqual(mp.capacity(sp, 9000)["power_kw"], 7.5, places=1)

    def test_power_only_when_nothing_else_known(self):
        cap = mp.capacity({"max_rpm": 10000, "power_kw_continuous": 5.0}, 2000)
        self.assertIsNone(cap["torque_nm"])
        self.assertEqual(cap["power_kw"], 5.0)


class TestValidation(unittest.TestCase):
    def good(self):
        return {"machine": "Test VMC", "active_spindle": "s",
                "spindle_options": {"s": {"max_rpm": 12000, "power_kw_continuous": 7.5, "base_rpm": 3000,
                                          "torque_curve": {"ratings": {"continuous": {"points": [[0, 20], [3000, 20], [12000, 6]]}}}}}}

    def test_builtin_profile_validates(self):
        with open(os.path.join(mp.BUILTIN_DIR, "speedio_s500x2.json"), encoding="utf-8") as fh:
            prof, errors = mp.validate_profile(json.load(fh))
        self.assertEqual(errors, [])
        self.assertIn("quoted", prof["spindle_options"]["optional_16k"]["torque_curve"])

    def test_good_profile(self):
        prof, errors = mp.validate_profile(self.good())
        self.assertEqual(errors, [])
        self.assertEqual(prof["spindle_options"]["s"]["torque_curve"]["ratings"]["continuous"]["points"][-1], [12000.0, 6.0])

    def test_rejects_bad_profiles(self):
        cases = []
        p = self.good(); p["spindle_options"]["s"]["torque_curve"]["ratings"]["continuous"]["points"] = [[0, 20], [5000, 10], [4000, 9]]
        cases.append(p)
        p = self.good(); del p["spindle_options"]["s"]["power_kw_continuous"]; cases.append(p)
        p = self.good(); p["spindle_options"]["s"]["torque_curve"]["ratings"]["continuous"]["points"] = [[0, 20], [20000, 5]]
        cases.append(p)   # past max rpm
        p = self.good(); p["machine"] = ""; cases.append(p)
        p = self.good(); p["spindle_options"] = {}; cases.append(p)
        p = self.good(); p["spindle_options"]["s"]["torque_curve"]["ratings"]["s6"] = {"points": [[0, 1]]}; cases.append(p)
        for case in cases:
            with self.subTest(case=case):
                prof, errors = mp.validate_profile(case)
                self.assertIsNone(prof)
                self.assertTrue(errors)


class TestSettings(unittest.TestCase):
    def test_legacy_flat_overrides_apply_to_default_machine(self):
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "machine_settings.json")
            with open(path, "w", encoding="utf-8") as fh:
                json.dump({"max_hp": 6.84, "runout": 0.0003}, fh)
            s = mp.read_settings(path)
            self.assertEqual(s["active_machine"], mp.DEFAULT_MACHINE_ID)
            self.assertEqual(s["machines"][mp.DEFAULT_MACHINE_ID], {"max_hp": 6.84, "runout": 0.0003})
            mp.write_settings(path, s)
            self.assertEqual(mp.read_settings(path), s)

    def test_user_copy_replaces_builtin_and_delete_reverts(self):
        with tempfile.TemporaryDirectory() as d:
            prof = mp.list_profiles(user_dir=d)[mp.DEFAULT_MACHINE_ID]["profile"]
            edited = dict(prof, machine="My Speedio")
            mp.save_user_profile(mp.DEFAULT_MACHINE_ID, edited, user_dir=d)
            entry = mp.list_profiles(user_dir=d)[mp.DEFAULT_MACHINE_ID]
            self.assertTrue(entry["builtin"] and entry["modified"])
            self.assertEqual(entry["profile"]["machine"], "My Speedio")
            self.assertTrue(mp.delete_user_profile(mp.DEFAULT_MACHINE_ID, user_dir=d))
            self.assertFalse(mp.list_profiles(user_dir=d)[mp.DEFAULT_MACHINE_ID]["modified"])

    def test_unique_id(self):
        self.assertEqual(mp.unique_id("Haas VF-2", {}), "haas_vf_2")
        self.assertEqual(mp.unique_id("Haas VF-2", {"haas_vf_2": 1}), "haas_vf_2_2")


if __name__ == "__main__":
    unittest.main()
