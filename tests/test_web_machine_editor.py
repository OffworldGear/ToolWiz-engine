"""Machine selector / machine-profile editor: page markup and the API round trips it relies on."""
import copy
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import app as app_module
import machine_profiles

PAGE_IDS = [
    "machineSelect", "spindleSelect", "editMachinesBtn", "spindleSummary",
    "machineEditorModal", "machineEdName", "machineEdNotes", "machineEdSpindle",
    "machineEdLabel", "machineEdMaxRpm", "machineEdBaseRpm", "machineEdPowerCont",
    "machineEdPower10", "machineEdPowerPeak", "machineEdTorque",
    "machineEdPts_continuous", "machineEdPts_s3_15pct_10min", "machineEdPts_momentary",
    "machineEdChart", "machineEdMsg",
]

PAGE_FUNCTIONS = [
    "renderSpindleSummary", "loadMachineList", "renderMachineSelectors", "selectMachine",
    "onMachineSelectChange", "onSpindleSelectChange", "openMachineEditor", "closeMachineEditor",
    "loadMachineIntoEditor", "newMachineProfile", "addMachineSpindle", "removeMachineSpindle",
    "fillMachineCurvesFromPower", "drawMachineEdChart", "saveMachineProfile", "deleteMachineProfile",
    "parsePointsText", "powerCurvePoints",
]


def make_profile(name="Test Mill", max_rpm=12000, kw=4.0, **extra):
    spindle = {"label": "Main", "max_rpm": max_rpm, "base_rpm": 3000, "power_kw_continuous": kw,
               "power_kw_10min": kw * 1.4, "max_torque_nm_momentary": 30}
    spindle.update(extra)
    return {"machine": name, "notes": "unit test", "active_spindle": "main", "spindle_options": {"main": spindle}}


class TestMachineEditor(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self._settings = app_module.MACHINE_SETTINGS_PATH
        self._user_dir = machine_profiles.USER_DIR
        app_module.MACHINE_SETTINGS_PATH = os.path.join(self.tmp.name, "machine_settings.json")
        machine_profiles.USER_DIR = os.path.join(self.tmp.name, "machines")
        self.client = app_module.app.test_client()
        self.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"

    def tearDown(self):
        app_module.MACHINE_SETTINGS_PATH = self._settings
        machine_profiles.USER_DIR = self._user_dir
        self.tmp.cleanup()

    def save(self, profile, mid=None):
        body = {"profile": profile}
        if mid:
            body["id"] = mid
        return self.client.post("/api/machines", json=body)

    def machine(self, mid):
        return next(m for m in self.client.get("/api/machines").get_json()["machines"] if m["id"] == mid)

    # -- page ------------------------------------------------------------------------------------
    def test_page_has_editor_elements_and_functions(self):
        html = self.client.get("/").get_data(as_text=True)
        for eid in PAGE_IDS:
            self.assertIn(f'id="{eid}"', html, eid)
        for fn in PAGE_FUNCTIONS:
            self.assertIn(f"function {fn}(", html, fn)
        self.assertIn('id="machineEdMsg" class="cutlog-msg" role="status"', html)

    # -- API round trips -------------------------------------------------------------------------
    def test_list_includes_speedio(self):
        data = self.client.get("/api/machines").get_json()
        self.assertTrue(data["success"])
        speedio = next(m for m in data["machines"] if m["id"] == "speedio_s500x2")
        self.assertTrue(speedio["builtin"])
        self.assertFalse(speedio["modified"])
        self.assertTrue(speedio["spindles"])

    def test_save_new_machine_select_and_limits(self):
        r = self.save(make_profile(max_rpm=12000, kw=4.0))
        self.assertEqual(r.status_code, 200)
        body = r.get_json()
        mid = body["id"]
        self.assertNotEqual(mid, "speedio_s500x2")
        self.assertIn(mid, [m["id"] for m in body["machines"]])
        self.assertFalse(self.machine(mid)["builtin"])
        sel = self.client.post("/api/machines/select", json={"machine_id": mid})
        self.assertEqual(sel.status_code, 200)
        limits = sel.get_json()["limits"]
        self.assertEqual(sel.get_json()["active_machine"], mid)
        self.assertEqual(limits["machine_id"], mid)
        self.assertEqual(limits["max_rpm"], 12000)
        self.assertAlmostEqual(limits["max_hp"], 4.0 * 1.341, places=2)
        again = self.client.get("/api/machine_limits").get_json()
        self.assertEqual(again["max_rpm"], 12000)
        self.assertEqual(again["spindle"]["key"], "main")
        self.assertEqual(self.client.get("/api/data").get_json()["machine"]["max_rpm"], 12000)

    def test_select_unknown_machine_or_spindle_is_rejected(self):
        self.assertEqual(self.client.post("/api/machines/select", json={"machine_id": "nope"}).status_code, 404)
        r = self.client.post("/api/machines/select", json={"machine_id": "speedio_s500x2", "spindle": "nope"})
        self.assertEqual(r.status_code, 400)

    def test_curve_points_round_trip(self):
        curve = {"ratings": {"continuous": {"points": [[0, 12.7], [3000, 12.7], [12000, 3.18]], "derived": True,
                                            "power_kw": 4.0, "note": "from power"}}}
        r = self.save(make_profile(torque_curve=curve))
        mid = r.get_json()["id"]
        got = self.client.get(f"/api/machines/{mid}").get_json()["profile"]
        rating = got["spindle_options"]["main"]["torque_curve"]["ratings"]["continuous"]
        self.assertEqual(rating["points"], [[0, 12.7], [3000, 12.7], [12000, 3.18]])
        self.assertTrue(rating["derived"])
        self.assertEqual(rating["note"], "from power")
        self.client.post("/api/machines/select", json={"machine_id": mid})
        curves = self.client.get("/api/machine_limits").get_json()["spindle"]["torque_curves"]
        self.assertIn("continuous", curves)

    def test_invalid_profiles_are_rejected(self):
        decreasing = {"ratings": {"continuous": {"points": [[0, 10], [5000, 10], [4000, 8]]}}}
        r = self.save(make_profile(torque_curve=decreasing))
        self.assertEqual(r.status_code, 400)
        self.assertFalse(r.get_json()["success"])
        self.assertIn("increase", r.get_json()["error"])

        no_power = make_profile()
        del no_power["spindle_options"]["main"]["power_kw_continuous"]
        r = self.save(no_power)
        self.assertEqual(r.status_code, 400)
        self.assertIn("continuous power", r.get_json()["error"])

        r = self.save(make_profile(name="  "))
        self.assertEqual(r.status_code, 400)
        self.assertFalse(os.path.isdir(machine_profiles.USER_DIR) and os.listdir(machine_profiles.USER_DIR))

    def test_edit_builtin_saves_user_copy_and_delete_reverts(self):
        full = self.client.get("/api/machines/speedio_s500x2").get_json()
        self.assertFalse(full["modified"])
        original_name = full["profile"]["machine"]
        profile = copy.deepcopy(full["profile"])
        profile["machine"] = "Speedio (my edit)"
        profile["notes"] = "edited in test"
        r = self.save(profile, mid="speedio_s500x2")
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.get_json()["id"], "speedio_s500x2")
        self.assertTrue(os.path.exists(os.path.join(machine_profiles.USER_DIR, "speedio_s500x2.json")))
        edited = self.client.get("/api/machines/speedio_s500x2").get_json()
        self.assertTrue(edited["modified"])
        self.assertTrue(edited["builtin"])
        self.assertEqual(edited["profile"]["machine"], "Speedio (my edit)")
        # Unknown profile fields survive the round trip.
        self.assertEqual(edited["profile"]["taper"], full["profile"]["taper"])
        self.assertTrue(self.machine("speedio_s500x2")["modified"])

        d = self.client.delete("/api/machines/speedio_s500x2")
        self.assertEqual(d.status_code, 200)
        reverted = self.client.get("/api/machines/speedio_s500x2").get_json()
        self.assertFalse(reverted["modified"])
        self.assertEqual(reverted["profile"]["machine"], original_name)
        # Nothing left to revert.
        self.assertEqual(self.client.delete("/api/machines/speedio_s500x2").status_code, 400)

    def test_delete_user_machine_falls_back_to_default(self):
        mid = self.save(make_profile()).get_json()["id"]
        self.client.post("/api/machines/select", json={"machine_id": mid})
        d = self.client.delete(f"/api/machines/{mid}")
        self.assertEqual(d.status_code, 200)
        self.assertEqual(d.get_json()["active_machine"], machine_profiles.DEFAULT_MACHINE_ID)
        self.assertNotIn(mid, [m["id"] for m in d.get_json()["machines"]])
        self.assertEqual(self.client.get(f"/api/machines/{mid}").status_code, 404)

    def test_overrides_are_per_machine(self):
        mid = self.save(make_profile(kw=4.0)).get_json()["id"]
        r = self.client.post("/api/machine_limits", json={"maxHp": 9.5, "maxRpm": 8000}).get_json()
        self.assertEqual(r["machine_id"], "speedio_s500x2")
        self.assertEqual(r["max_hp"], 9.5)

        limits = self.client.post("/api/machines/select", json={"machine_id": mid}).get_json()["limits"]
        self.assertEqual(limits["machine_id"], mid)
        self.assertAlmostEqual(limits["max_hp"], 4.0 * 1.341, places=2)
        self.assertEqual(limits["max_rpm"], 12000)
        self.assertEqual(limits["overridden"], [])

        # An override set on the second machine does not leak back to the first.
        self.client.post("/api/machine_limits", json={"maxHp": 3.3})
        back = self.client.post("/api/machines/select", json={"machine_id": "speedio_s500x2"}).get_json()["limits"]
        self.assertEqual(back["max_hp"], 9.5)
        self.assertEqual(back["max_rpm"], 8000)
        self.assertEqual(self.client.post("/api/machines/select", json={"machine_id": mid}).get_json()["limits"]["max_hp"], 3.3)

    def test_requires_client_header(self):
        bare = app_module.app.test_client()
        self.assertEqual(bare.post("/api/machines", json={"profile": make_profile()}).status_code, 403)
        self.assertEqual(bare.post("/api/machines/select", json={"machine_id": "speedio_s500x2"}).status_code, 403)


if __name__ == "__main__":
    unittest.main()
