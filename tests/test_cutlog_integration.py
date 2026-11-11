import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import app as app_module
import cutlog

FAM = "Stainless - 300 Series (316)"
OP = {"id": "1", "name": "Wall Finish", "strategy": "contour", "diameter": 0.25, "flutes": 4,
      "fluteLength": 0.75, "shankDiameter": 0.25, "stickout": 1.0, "rpm": 9500, "feedrate": 20,
      "doc": 0.5, "woc": 0.01}


class TestCalibrationInStockComp(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.db = os.path.join(self.tmp.name, "cutlog.db")
        self._orig = cutlog._DEFAULT_DB if hasattr(cutlog, "_DEFAULT_DB") else None
        cutlog.register.__globals__  # module loaded
        self.client = app_module.app.test_client()
        self.client.environ_base["HTTP_X_TOOLWIZ_CLIENT"] = "test"
        self._apply = cutlog.apply_calibration
        cutlog_apply = self._apply
        cutlog.apply_calibration = lambda fam, pred, db_path=None: cutlog_apply(fam, pred, db_path=self.db)

    def tearDown(self):
        cutlog.apply_calibration = self._apply
        self.tmp.cleanup()

    def stock(self):
        r = self.client.post("/api/stock_compensation", json={"family": FAM, "operations": [OP]}).get_json()
        return r["results"][0]

    def test_uncalibrated_is_unchanged_then_calibrated_scales(self):
        before = self.stock()
        self.assertFalse(before["calibration"]["applied"])
        pred = before["total_error_in"]
        for _ in range(3):
            cutlog.insert_cut({"family": FAM, "operation": "contour", "diameter_in": 0.25, "flutes": 4,
                               "stickout_in": 1.0, "rpm": 9500, "feed_ipm": 20, "doc_in": 0.5, "woc_in": 0.01,
                               "predicted_deflection_in": pred * 0.4, "predicted_springback_in": pred * 0.6,
                               "predicted_total_error_in": pred, "measured_wall_error_in": pred * 1.5},
                              db_path=self.db)
        after = self.stock()
        self.assertTrue(after["calibration"]["applied"])
        self.assertAlmostEqual(after["total_error_in"], pred * 1.5, delta=pred * 0.02)


if __name__ == "__main__":
    unittest.main()
