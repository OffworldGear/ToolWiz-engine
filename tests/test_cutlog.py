import os
import shutil
import tempfile
import unittest

from flask import Flask, jsonify, request

import cutlog

H = {"X-ToolWiz-Client": "test"}


def make_app(db_path):
    app = Flask(__name__)

    @app.before_request
    def guard():
        if request.method in ("POST", "PUT", "PATCH", "DELETE") and request.path.startswith("/api/"):
            if not (request.headers.get("X-ToolWiz-Client") or "").strip():
                return jsonify({"success": False, "error": "Missing header"}), 403

    cutlog.register(app, db_path=db_path)
    return app


def valid_cut(**over):
    d = dict(family="Aluminum", operation="Finishing", diameter_in=0.5, flutes=3,
             stickout_in=1.5, rpm=12000, feed_ipm=60, doc_in=1.0, woc_in=0.01,
             predicted_deflection_in=0.0008, predicted_springback_in=0.0002,
             predicted_total_error_in=0.001)
    d.update(over)
    return d


class Base(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.db = os.path.join(self.tmp, "sub", "cutlog.db")  # also tests dir creation
        self.app = make_app(self.db)
        self.c = self.app.test_client()

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def post(self, **over):
        return self.c.post("/api/cutlog", json=valid_cut(**over), headers=H)

    def log(self, family, measured, predicted=0.001, **kw):
        r = self.post(family=family, measured_wall_error_in=measured,
                      predicted_total_error_in=predicted, **kw)
        self.assertEqual(r.status_code, 201, r.get_json())


class TestValidation(Base):
    def test_header_required(self):
        r = self.c.post("/api/cutlog", json=valid_cut())
        self.assertEqual(r.status_code, 403)

    def test_minimal_ok(self):
        r = self.post()
        self.assertEqual(r.status_code, 201)
        self.assertIn("id", r.get_json())

    def test_missing_required_each(self):
        for key in valid_cut():
            d = valid_cut()
            del d[key]
            r = self.c.post("/api/cutlog", json=d, headers=H)
            self.assertEqual(r.status_code, 400, key)
            self.assertIn(key, r.get_json()["error"])

    def test_range_violations(self):
        bad = [dict(diameter_in=0), dict(diameter_in=6.5), dict(diameter_in=-1),
               dict(rpm=0), dict(rpm=60001), dict(flutes=0), dict(flutes=2.5),
               dict(spindle_load_pct=-1), dict(spindle_load_pct=201),
               dict(feed_ipm=0), dict(stickout_in=0), dict(doc_in=-0.1),
               dict(predicted_total_error_in=-0.001), dict(measured_wall_error_in=5)]
        for over in bad:
            self.assertEqual(self.post(**over).status_code, 400, over)

    def test_type_violations(self):
        bad = [dict(diameter_in="0.5"), dict(rpm=True), dict(chatter="yes"),
               dict(surface_ok=1), dict(family=""), dict(family=5),
               dict(source="pigeon"), dict(notes=["x"])]
        for over in bad:
            self.assertEqual(self.post(**over).status_code, 400, over)

    def test_non_finite_rejected(self):
        r = self.c.post("/api/cutlog", data='{"diameter_in": NaN}',
                        content_type="application/json", headers=H)
        self.assertEqual(r.status_code, 400)

    def test_non_json_and_non_object(self):
        r = self.c.post("/api/cutlog", data="nope", headers=H)
        self.assertEqual(r.status_code, 400)
        r = self.c.post("/api/cutlog", json=[1, 2], headers=H)
        self.assertEqual(r.status_code, 400)

    def test_boundaries_accepted(self):
        self.assertEqual(self.post(diameter_in=6, rpm=60000, spindle_load_pct=200).status_code, 201)
        self.assertEqual(self.post(spindle_load_pct=0).status_code, 201)


class TestCrud(Base):
    def test_insert_list_delete(self):
        ids = []
        for fam in ("Aluminum", "Steel", "Aluminum"):
            r = self.post(family=fam, alloy="6061", chatter=False, surface_ok=True,
                          source="fusion", tool_number=7, notes="n",
                          measured_wall_error_in=0.001, spindle_load_pct=40)
            ids.append(r.get_json()["id"])
        rows = self.c.get("/api/cutlog").get_json()["cuts"]
        self.assertEqual([r["id"] for r in rows], ids[::-1])  # newest first
        self.assertIs(rows[0]["chatter"], False)
        self.assertIs(rows[0]["surface_ok"], True)
        self.assertEqual(rows[0]["source"], "fusion")
        self.assertTrue(rows[0]["created_at"])
        self.assertEqual(len(self.c.get("/api/cutlog?family=aluminum").get_json()["cuts"]), 2)
        self.assertEqual(len(self.c.get("/api/cutlog?limit=1").get_json()["cuts"]), 1)
        r = self.c.delete(f"/api/cutlog/{ids[0]}", headers=H)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(len(self.c.get("/api/cutlog").get_json()["cuts"]), 2)
        self.assertEqual(self.c.delete(f"/api/cutlog/{ids[0]}", headers=H).status_code, 404)
        self.assertEqual(self.c.delete("/api/cutlog/1").status_code, 403)

    def test_defaults_and_nulls(self):
        self.post()
        row = self.c.get("/api/cutlog").get_json()["cuts"][0]
        self.assertEqual(row["source"], "web")
        self.assertIsNone(row["chatter"])
        self.assertIsNone(row["measured_wall_error_in"])

    def test_bad_limit(self):
        for v in ("0", "abc", "5000"):
            self.assertEqual(self.c.get(f"/api/cutlog?limit={v}").status_code, 400)

    def test_calibration_endpoint(self):
        for _ in range(3):
            self.log("Aluminum", 0.002)
        self.log("Steel", 0.001)
        cal = self.c.get("/api/calibration").get_json()["calibration"]
        by = {c["family"]: c for c in cal}
        self.assertEqual(by["Aluminum"]["status"], "provisional")
        self.assertAlmostEqual(by["Aluminum"]["error_factor"], 2.0)
        self.assertEqual(by["Steel"]["status"], "insufficient")
        self.assertIsNone(by["Steel"]["error_factor"])
        only = self.c.get("/api/calibration?family=steel").get_json()["calibration"]
        self.assertEqual(len(only), 1)
        for key in ("family", "n", "error_factor", "error_factor_ci", "chatter_rate",
                    "mean_spindle_load", "suggested_aggressiveness_delta", "status"):
            self.assertIn(key, by["Aluminum"])


def rows_from(pairs):
    return [{"measured_wall_error_in": m, "predicted_total_error_in": p} for m, p in pairs]


class TestMath(unittest.TestCase):
    def test_median_and_outliers(self):
        rows = rows_from([(0.001, 0.001), (0.002, 0.001), (0.003, 0.001),
                          (0.00001, 0.001),   # ratio 0.01 -> dropped
                          (0.1, 0.001),       # ratio 100 -> dropped
                          (-0.001, 0.001),    # negative -> dropped
                          (None, 0.001),      # no measurement: ineligible
                          (0.001, 1e-6)])     # predicted too small: ineligible
        ratios, dropped = cutlog.collect_ratios(rows)
        self.assertEqual(sorted(ratios), [1.0, 2.0, 3.0])
        self.assertEqual(dropped, 3)
        self.assertAlmostEqual(cutlog.median_factor(ratios), 2.0)
        cal = cutlog.compute_calibration("X", rows)
        self.assertEqual(cal["n"], 3)
        self.assertEqual(cal["dropped_outliers"], 3)
        self.assertAlmostEqual(cal["error_factor"], 2.0)

    def test_ratio_bounds_inclusive(self):
        ratios, dropped = cutlog.collect_ratios(rows_from([(0.00005, 0.001), (0.02, 0.001)]))
        self.assertEqual(len(ratios), 2)
        self.assertEqual(dropped, 0)

    def test_ci_brackets_median_and_deterministic(self):
        ratios = [0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.0, 0.95]
        ci = cutlog.bootstrap_ci(ratios)
        self.assertEqual(ci, cutlog.bootstrap_ci(ratios))
        self.assertLessEqual(ci[0], cutlog.median_factor(ratios))
        self.assertGreaterEqual(ci[1], cutlog.median_factor(ratios))
        self.assertIsNone(cutlog.bootstrap_ci([1.0, 2.0]))

    def test_status_thresholds(self):
        self.assertEqual(cutlog.status_for(0), "insufficient")
        self.assertEqual(cutlog.status_for(2), "insufficient")
        self.assertEqual(cutlog.status_for(3), "provisional")
        self.assertEqual(cutlog.status_for(9), "provisional")
        self.assertEqual(cutlog.status_for(10), "calibrated")
        two = cutlog.compute_calibration("X", rows_from([(0.001, 0.001)] * 2))
        self.assertEqual(two["status"], "insufficient")
        self.assertIsNone(two["error_factor"])
        self.assertIsNone(two["error_factor_ci"])
        ten = cutlog.compute_calibration("X", rows_from([(0.001, 0.001)] * 10))
        self.assertEqual(ten["status"], "calibrated")

    def test_clamp(self):
        self.assertEqual(cutlog.clamp_factor(0.1), 0.5)
        self.assertEqual(cutlog.clamp_factor(10), 2.0)
        self.assertEqual(cutlog.clamp_factor(1.3), 1.3)
        cal = cutlog.compute_calibration("X", rows_from([(0.01, 0.001)] * 3))
        self.assertAlmostEqual(cal["error_factor"], 10.0)
        self.assertEqual(cal["applied_factor"], 2.0)

    def test_aggressiveness(self):
        d = cutlog.suggest_aggressiveness_delta
        self.assertEqual(d(5, 0.25, 50), -10)
        self.assertEqual(d(5, 0.0, 95), -10)
        self.assertEqual(d(10, 0.0, 50), 5)
        self.assertEqual(d(9, 0.0, 50), 0)
        self.assertEqual(d(10, 0.0, 60), 0)
        self.assertEqual(d(10, 0.1, 50), 0)
        self.assertEqual(d(10, 0.2, 50), 0)
        self.assertEqual(d(10, None, None), 0)
        self.assertEqual(d(10, 0.0, None), 0)
        self.assertEqual(d(0, 0.5, None), -10)

    def test_chatter_and_load_means(self):
        rows = [{"chatter": True, "spindle_load_pct": 100},
                {"chatter": False, "spindle_load_pct": 50},
                {"chatter": None, "spindle_load_pct": None}]
        self.assertAlmostEqual(cutlog.chatter_rate(rows), 0.5)
        self.assertAlmostEqual(cutlog.mean_spindle_load(rows), 75)
        self.assertIsNone(cutlog.chatter_rate([]))


class TestApply(Base):
    def test_noop_below_three(self):
        self.log("Titanium", 0.002)
        self.log("Titanium", 0.002)
        out, info = cutlog.apply_calibration("Titanium", 0.001, db_path=self.db)
        self.assertEqual(out, 0.001)
        self.assertFalse(info["applied"])
        self.assertEqual(info["status"], "insufficient")
        self.assertEqual(info["n"], 2)

    def test_noop_unknown_family_and_bad_input(self):
        self.assertEqual(cutlog.apply_calibration("Nope", 0.001, db_path=self.db)[0], 0.001)
        self.assertEqual(cutlog.apply_calibration("Nope", None, db_path=self.db)[0], None)

    def test_applies_and_clamps(self):
        for _ in range(3):
            self.log("Titanium", 0.0015)
        out, info = cutlog.apply_calibration("titanium", 0.002, db_path=self.db)
        self.assertAlmostEqual(out, 0.003)
        self.assertTrue(info["applied"])
        self.assertFalse(info["clamped"])
        for _ in range(4):
            self.log("Brass", 0.01)
        out, info = cutlog.apply_calibration("Brass", 0.002, db_path=self.db)
        self.assertAlmostEqual(out, 0.004)  # 10x clamped to 2x
        self.assertTrue(info["clamped"])
        self.assertAlmostEqual(info["raw_factor"], 10.0)

    def test_uses_registered_default_path(self):
        for _ in range(3):
            self.log("Steel", 0.0005)
        out, info = cutlog.apply_calibration("Steel", 0.002)  # no db_path: uses register()'s
        self.assertAlmostEqual(out, 0.001)


if __name__ == "__main__":
    unittest.main()


class TestSuggestionNeedsEvidence(unittest.TestCase):
    def test_single_chatter_row_gives_no_advice(self):
        self.assertEqual(cutlog.suggest_aggressiveness_delta(0, 1.0, None, n_outcomes=1), 0)

    def test_three_rows_with_chatter_back_off(self):
        self.assertEqual(cutlog.suggest_aggressiveness_delta(0, 0.67, None, n_outcomes=3), -10)


def tearDownModule():
    # register() stores the temp db path module-wide; don't leak it into other test modules.
    cutlog._configured_db_path = None
