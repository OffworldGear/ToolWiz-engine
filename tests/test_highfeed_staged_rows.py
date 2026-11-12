"""Sanity checks for the staged high-feed end mill benchmark rows (tests/benchmarks/v2_staged/highfeed_*.json)."""
import glob
import json
import math
import os
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STAGED = os.path.join(ROOT, "tests", "benchmarks", "v2_staged")
SFM_RANGE = {  # plausible published SFM per family (min, max)
    "Titanium Alloy": (50, 600),
    "High Temp Nickel Alloy": (30, 400),
    "Cobalt Chrome (CoCr ASTM F75)": (30, 400),
    "Stainless - PH Series (17-4)": (50, 700),
    "Stainless - 300 Series (316)": (50, 800),
    "Stainless - 400 Series (420)": (50, 900),
    "Steel - Tool (H13)": (50, 900),
}
DEFAULT_SFM = (50, 1500)
OPS = {"slot", "side", "rough", "hem", "finish"}


def num(x):
    return isinstance(x, (int, float)) and not isinstance(x, bool) and math.isfinite(x)


class TestHighFeedStaged(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.files = {}
        for p in sorted(glob.glob(os.path.join(STAGED, "highfeed_*.json"))):
            with open(p, encoding="utf-8") as fh:
                cls.files[os.path.basename(p)] = json.load(fh)
        with open(os.path.join(ROOT, "materials_database_clean.json"), encoding="utf-8") as fh:
            cls.families = {f["name"] for f in json.load(fh)["material_families"]}

    def test_files_exist(self):
        self.assertGreaterEqual(len(self.files), 3)

    def test_rows(self):
        ids = set()
        for name, data in self.files.items():
            self.assertTrue(data.get("vendor") and data.get("vendor_group"), name)
            self.assertTrue(data.get("schema_extensions"), name)
            docs = {d["doc_id"]: d for d in data["documents"]}
            for d in docs.values():
                self.assertTrue(d["url"].startswith("https://"), d["doc_id"])
            self.assertTrue(data["rows"], name)
            for r in data["rows"]:
                rid = r.get("id")
                with self.subTest(file=name, row=rid):
                    self.assertNotIn(rid, ids)
                    ids.add(rid)
                    s, t, m, c = r["source"], r["tool"], r["material"], r["cut"]
                    self.assertIn(s["doc_id"], docs)
                    self.assertTrue(s["url"].startswith("https://"))
                    self.assertTrue(s.get("page") not in (None, ""))
                    for k in ("table", "row_label", "column_label", "cells"):
                        self.assertTrue(s.get(k), k)
                    self.assertIn(s["read_method"], ("text", "image"))
                    self.assertEqual(t["end"], "high_feed")
                    for k in ("part_number", "series", "coating", "flutes", "SFDM"):
                        self.assertTrue(t.get(k) is not None, k)
                    self.assertTrue(num(t["DC"]) and 0 < t["DC"] <= 0.75)
                    self.assertIn(m["toolwiz_family"], self.families)
                    self.assertIn(r["operation"], OPS)
                    self.assertTrue(num(c["ap"]) and 0 < c["ap"] <= 0.2 * t["DC"] + 1e-9)
                    self.assertTrue(num(c["ae"]) and 0 < c["ae"] <= t["DC"] + 1e-9)
                    self.assertTrue(num(c["fz"]["nominal"]) and c["fz"]["nominal"] > 0)
                    self.assertLess(c["fz"]["nominal"], 0.05)
                    lo, hi = SFM_RANGE.get(m["toolwiz_family"], DEFAULT_SFM)
                    self.assertTrue(lo <= c["sfm"]["nominal"] <= hi, c["sfm"])
                    for k in ("min", "max"):
                        if c["sfm"].get(k) is not None:
                            self.assertTrue(lo * 0.5 <= c["sfm"][k] <= hi * 1.5)
                    self.assertTrue(c.get("published"))


if __name__ == "__main__":
    unittest.main()
