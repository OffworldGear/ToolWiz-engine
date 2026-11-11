"""v2 benchmark dataset (tests/benchmarks/v2): every row is cited, complete and internally consistent.

Schema: tests/benchmarks/v2/SCHEMA.md. These checks guard the data itself; they don't run the engine.
"""
import glob
import json
import math
import os
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
V2_DIR = os.path.join(ROOT, "tests", "benchmarks", "v2")
OPERATIONS = {"slot", "side", "rough", "hem", "finish", "ramp"}
RAMP_KINDS = {"helical", "linear", "plunge", "any"}
RAMP_RANGES = ("angle_deg", "hole_diameter_over_D", "pitch_over_D", "ramp_feed_factor", "plunge_feed_factor")
TOOL_FIELDS = ("part_number", "series", "tool_material", "coating", "flutes", "end", "corner_radius",
               "helix_deg", "variable_pitch", "DC", "LCF", "neck_diameter", "LB", "SFDM", "OAL",
               "geometry_url", "missing")


def load_families():
    with open(os.path.join(ROOT, "materials_database_clean.json"), encoding="utf-8") as fh:
        return {f["name"] for f in json.load(fh)["material_families"]}


def load_files():
    out = {}
    for path in sorted(glob.glob(os.path.join(V2_DIR, "*.json"))):
        with open(path, encoding="utf-8") as fh:
            out[os.path.basename(path)] = json.load(fh)
    return out


def positive(x):
    return isinstance(x, (int, float)) and not isinstance(x, bool) and math.isfinite(x) and x > 0


class TestV2BenchmarkDataset(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.files = load_files()
        cls.families = load_families()

    def rows(self):
        for name, data in self.files.items():
            for row in data.get("rows", []):
                yield name, data, row

    def test_files_have_vendor_and_documents(self):
        for name, data in self.files.items():
            with self.subTest(file=name):
                self.assertTrue(data.get("vendor"))
                self.assertTrue(data.get("vendor_group"))
                for doc in data.get("documents", []):
                    self.assertTrue(doc.get("doc_id"))
                    self.assertTrue(str(doc.get("url", "")).startswith("http"), doc.get("doc_id"))
                    self.assertTrue(doc.get("date_accessed"), doc.get("doc_id"))

    def test_row_ids_unique(self):
        seen = set()
        for name, _, row in self.rows():
            rid = row.get("id")
            self.assertTrue(rid, name)
            self.assertNotIn(rid, seen, rid)
            seen.add(rid)

    def test_rows_cite_a_listed_document_and_quote_cells(self):
        for name, data, row in self.rows():
            with self.subTest(row=row.get("id")):
                docs = {d["doc_id"] for d in data.get("documents", [])}
                src = row["source"]
                self.assertIn(src["doc_id"], docs)
                self.assertTrue(str(src.get("cells", "")).strip(), "cells must quote the published values")
                self.assertIn(src.get("read_method"), {"text", "image"})
                if "derivation" in src:
                    self.assertTrue(str(src["derivation"]).strip(), "derivation must state the vendor rule applied")

    def test_tool_geometry_complete_or_declared_missing(self):
        for name, _, row in self.rows():
            tool = row["tool"]
            with self.subTest(row=row.get("id")):
                for field in TOOL_FIELDS:
                    self.assertIn(field, tool)
                missing = set(tool["missing"])
                for field in ("DC", "LCF", "SFDM", "OAL"):
                    if field not in missing:
                        self.assertTrue(positive(tool[field]), field)
                self.assertTrue(positive(tool["DC"]), "DC is required")
                self.assertIsInstance(tool["flutes"], int)
                if positive(tool["LCF"]) and positive(tool["OAL"]):
                    self.assertLess(tool["LCF"], tool["OAL"])
                for field, value in tool.items():
                    if value is None and field not in ("neck_diameter", "LB", "part_number"):
                        self.assertIn(field, missing, f"{field} is null but not listed in missing")

    def test_material_maps_to_a_toolwiz_family(self):
        for name, _, row in self.rows():
            with self.subTest(row=row.get("id")):
                mat = row["material"]
                self.assertIn(mat["toolwiz_family"], self.families)
                self.assertTrue(mat.get("vendor_label"))

    def test_cut_values(self):
        for name, _, row in self.rows():
            with self.subTest(row=row.get("id")):
                self.assertIn(row["operation"], OPERATIONS)
                cut = row["cut"]
                for key in ("sfm", "fz"):
                    vals = [cut[key].get(k) for k in ("min", "max", "nominal")]
                    if row["operation"] == "ramp":
                        # Ramp rows may give only an angle; a given value must still be positive.
                        self.assertTrue(all(v is None or positive(v) for v in vals), f"{key} must be positive")
                        continue
                    self.assertTrue(any(positive(v) for v in vals), f"{key} has no value")
                    lo, hi = cut[key].get("min"), cut[key].get("max")
                    if positive(lo) and positive(hi):
                        self.assertLessEqual(lo, hi)
                dc = row["tool"]["DC"]
                if positive(cut.get("ae")):
                    self.assertLessEqual(cut["ae"], dc * 1.0001)
                if row["operation"] == "slot" and positive(cut.get("ae")):
                    self.assertAlmostEqual(cut["ae"], dc, delta=dc * 0.01)
                self.assertIn("published", cut)

    def test_ramp_rows(self):
        n = 0
        for name, _, row in self.rows():
            if row["operation"] != "ramp":
                self.assertNotIn("ramp", row)
                continue
            n += 1
            with self.subTest(row=row.get("id")):
                rp = row.get("ramp")
                self.assertIsInstance(rp, dict, "ramp rows carry a ramp block")
                self.assertIn(rp.get("kind"), RAMP_KINDS)
                values = []
                for key in RAMP_RANGES:
                    rng = rp.get(key)
                    self.assertIsInstance(rng, dict, key)
                    vals = [rng.get(k) for k in ("min", "max", "nominal")]
                    for v in vals:
                        self.assertTrue(v is None or positive(v), f"{key} must be positive")
                    lo, hi = rng.get("min"), rng.get("max")
                    if positive(lo) and positive(hi):
                        self.assertLessEqual(lo, hi, key)
                    values += [v for v in vals if v is not None]
                self.assertTrue(values, "a ramp row needs at least one numeric ramp value")
                for k in ("min", "max", "nominal"):
                    a = rp["angle_deg"].get(k)
                    self.assertTrue(a is None or a <= 90.0, "ramp angle is from the horizontal, ≤ 90°")
                    h = rp["hole_diameter_over_D"].get(k)
                    self.assertTrue(h is None or h >= 1.0, "a bore is at least the tool diameter")
                if any(rp[f].get(k) is not None for f in ("ramp_feed_factor", "plunge_feed_factor")
                       for k in ("min", "max", "nominal")):
                    self.assertTrue(str(rp.get("feed_factor_basis") or "").strip(), "feed factors name their base")
        self.assertGreater(n, 0, "the dataset has ramp rows")


if __name__ == "__main__":
    unittest.main()
