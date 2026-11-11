"""T-slot / keyseat / undercut benchmark dataset (tests/benchmarks/tslot): every row is cited, complete and consistent.

Schema: tests/benchmarks/tslot/SCHEMA.md. These checks guard the data itself; they don't run the engine.
"""
import glob
import json
import math
import os
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TSLOT_DIR = os.path.join(ROOT, "tests", "benchmarks", "tslot")
OPERATIONS = {"full_slot", "side_cut", "axial_face", "double_face", "deburr"}
FACES = {"periphery", "bottom", "top"}
TOOTH_FORMS = {"straight", "staggered", None}
CORNER_STYLES = {"square", "corner_radius", "full_radius", "chamfer", "tip_radius"}
TOOL_FIELDS = ("part_number", "series", "style", "product_name", "tool_material", "coating", "teeth", "tooth_form",
               "cutting_faces", "cutting_faces_basis", "cutter_diameter", "cutter_thickness", "neck_diameter",
               "neck_length", "shank_diameter", "OAL", "corner_radius", "corner_style", "included_angle_deg",
               "max_radial_depth", "geometry_url", "missing")
REQUIRED_POSITIVE = ("cutter_diameter", "cutter_thickness")
OPTIONAL_NULL = ("included_angle_deg", "max_radial_depth")
CUT_RANGES = ("sfm", "fz", "ae_radial", "ap_axial", "axial_feed")
CUT_MISSING_ALLOWED = {"ae_radial", "ap_axial", "axial_feed", "passes"}


def load_families():
    with open(os.path.join(ROOT, "materials_database_clean.json"), encoding="utf-8") as fh:
        return {f["name"] for f in json.load(fh)["material_families"]}


def load_files():
    out = {}
    for path in sorted(glob.glob(os.path.join(TSLOT_DIR, "*.json"))):
        with open(path, encoding="utf-8") as fh:
            out[os.path.basename(path)] = json.load(fh)
    return out


def positive(x):
    return isinstance(x, (int, float)) and not isinstance(x, bool) and math.isfinite(x) and x > 0


def vals(rng):
    return [rng.get(k) for k in ("min", "max", "nominal")]


class TestTslotBenchmarkDataset(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.files = load_files()
        cls.families = load_families()

    def rows(self):
        for name, data in self.files.items():
            for row in data.get("rows", []):
                yield name, data, row

    def test_there_are_files_and_rows(self):
        self.assertTrue(self.files)
        self.assertGreater(sum(len(d["rows"]) for d in self.files.values()), 50)

    def test_files_have_vendor_and_documents(self):
        for name, data in self.files.items():
            with self.subTest(file=name):
                self.assertTrue(data.get("vendor"))
                self.assertTrue(data.get("vendor_group"))
                self.assertTrue(data.get("documents"))
                for doc in data["documents"]:
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
                docs = {d["doc_id"] for d in data["documents"]}
                src = row["source"]
                self.assertIn(src["doc_id"], docs)
                self.assertTrue(str(src.get("cells", "")).strip())
                self.assertTrue(str(src.get("table", "")).strip())
                self.assertIn(src.get("read_method"), {"text", "image"})
                if "derivation" in src:
                    self.assertTrue(str(src["derivation"]).strip())

    def test_tool_geometry(self):
        for name, _, row in self.rows():
            tool = row["tool"]
            with self.subTest(row=row.get("id")):
                for field in TOOL_FIELDS:
                    self.assertIn(field, tool)
                missing = set(tool["missing"])
                for field in REQUIRED_POSITIVE:
                    self.assertTrue(positive(tool[field]), field)
                for field in ("neck_diameter", "neck_length", "shank_diameter", "OAL"):
                    if field in missing:
                        self.assertIsNone(tool[field], field)
                    else:
                        self.assertTrue(positive(tool[field]), f"{field} must be positive or listed in missing")
                for field, value in tool.items():
                    if value is None and field not in OPTIONAL_NULL:
                        self.assertIn(field, missing, f"{field} is null but not listed in missing")
                self.assertTrue(tool["part_number"])
                self.assertTrue(str(tool["geometry_url"]).startswith("http"))
                self.assertIsInstance(tool["teeth"], int)
                self.assertGreater(tool["teeth"], 0)
                self.assertIn(tool["tooth_form"], TOOTH_FORMS)
                self.assertIn(tool["corner_style"], CORNER_STYLES)
                faces = tool["cutting_faces"]
                self.assertTrue(faces)
                self.assertTrue(set(faces) <= FACES)
                self.assertEqual(len(set(faces)), len(faces))
                self.assertTrue(str(tool["cutting_faces_basis"]).strip())
                if positive(tool["neck_diameter"]):
                    self.assertLess(tool["neck_diameter"], tool["cutter_diameter"] * 1.0001)
                if positive(tool["shank_diameter"]) and positive(tool["OAL"]):
                    self.assertLess(tool["shank_diameter"], tool["OAL"])
                if positive(tool["max_radial_depth"]):
                    self.assertLess(tool["max_radial_depth"], tool["cutter_diameter"])
                if tool["included_angle_deg"] is not None:
                    self.assertTrue(0 < tool["included_angle_deg"] <= 180)

    def test_staggered_tooth_cutters_cut_on_both_sides(self):
        """Staggered-tooth cutters are the up-and-down class: periphery, top and bottom, teeth_per_face stated."""
        n = 0
        for name, _, row in self.rows():
            tool = row["tool"]
            if tool["tooth_form"] != "staggered":
                self.assertNotIn("teeth_per_face", tool)
                continue
            n += 1
            with self.subTest(row=row.get("id")):
                self.assertEqual(set(tool["cutting_faces"]), {"periphery", "top", "bottom"})
                tpf = tool["teeth_per_face"]
                self.assertIsInstance(tpf, int)
                self.assertTrue(0 < tpf <= tool["teeth"])
                self.assertTrue(str(tool.get("teeth_per_face_basis", "")).strip())
                if "teeth_per_face" in tool["missing"]:
                    self.assertIn("stagger rule", tool["teeth_per_face_basis"])
                    self.assertEqual(tpf, tool["teeth"] // 2)
        self.assertGreater(n, 0)

    def test_material_maps_to_a_toolwiz_family(self):
        for name, _, row in self.rows():
            with self.subTest(row=row.get("id")):
                mat = row["material"]
                self.assertIn(mat["toolwiz_family"], self.families)
                self.assertTrue(mat.get("vendor_label"))
                self.assertTrue(mat.get("representative_alloy"))

    def test_cut_values(self):
        for name, _, row in self.rows():
            with self.subTest(row=row.get("id")):
                self.assertIn(row["operation"], OPERATIONS)
                cut = row["cut"]
                dc = row["tool"]["cutter_diameter"]
                for key in CUT_RANGES:
                    self.assertIn(key, cut)
                for key in ("sfm", "fz"):
                    v = vals(cut[key])
                    self.assertTrue(any(positive(x) for x in v), f"{key} has no value")
                    self.assertTrue(all(x is None or positive(x) for x in v), key)
                for key in CUT_RANGES:
                    v = vals(cut[key])
                    self.assertTrue(all(x is None or positive(x) for x in v), key)
                    lo, hi = cut[key].get("min"), cut[key].get("max")
                    if positive(lo) and positive(hi):
                        self.assertLessEqual(lo, hi, key)
                faces = cut["faces_engaged"]
                self.assertTrue(faces)
                self.assertTrue(set(faces) <= set(row["tool"]["cutting_faces"]), "engaged faces must be cutting faces")
                if row["operation"] == "double_face":
                    self.assertTrue({"top", "bottom"} <= set(faces))
                if row["operation"] == "axial_face":
                    self.assertTrue(set(faces) & {"top", "bottom"})
                ae = cut["ae_radial"]
                for x in vals(ae):
                    if positive(x):
                        self.assertLessEqual(x, dc / 2 * 1.0001 + 1e-9 if False else dc * 1.0001)
                ap = cut["ap_axial"]
                for x in vals(ap):
                    if positive(x) and row["operation"] == "full_slot":
                        self.assertLessEqual(x, row["tool"]["cutter_thickness"] * 1.0001)
                self.assertIn("published", cut)
                self.assertTrue(str(cut["fz_basis"]).strip())
                self.assertIsInstance(cut["adjustments"], list)
                for adj in cut["adjustments"]:
                    self.assertTrue(adj.get("condition"))
                    f = adj["factor"]
                    self.assertTrue(positive(f.get("min")) and positive(f.get("max")) and f["min"] <= f["max"])
                    self.assertTrue(str(adj.get("published", "")).strip())

    def test_cut_missing_lists_are_honest(self):
        for name, _, row in self.rows():
            with self.subTest(row=row.get("id")):
                cut = row["cut"]
                missing = set(cut["missing"])
                self.assertTrue(missing <= CUT_MISSING_ALLOWED)
                for key in ("ae_radial", "ap_axial", "axial_feed"):
                    has = any(positive(x) for x in vals(cut[key]))
                    if key in missing:
                        self.assertFalse(has, f"{key} is listed missing but has a value")
                    else:
                        self.assertTrue(has, f"{key} is null but not listed in cut.missing")
                passes = cut["passes"]
                has_p = any(positive(passes.get(k)) for k in ("min", "max", "nominal"))
                if "passes" in missing:
                    self.assertFalse(has_p)
                else:
                    self.assertTrue(has_p)
                    self.assertTrue(str(passes.get("published", "")).strip())

    def test_published_ae_multiple_matches_the_inch_value(self):
        """When the vendor prints 'k x Dia' for the radial depth, the inch value is k x cutter diameter."""
        import re
        for name, _, row in self.rows():
            pub = (row["cut"].get("published") or {}).get("ae_radial")
            nominal = row["cut"]["ae_radial"].get("nominal")
            if not pub or not positive(nominal):
                continue
            m = re.fullmatch(r"\s*(\.?\d*\.?\d+)\s*x\s*Dia\s*", pub)
            if m:
                with self.subTest(row=row.get("id")):
                    self.assertAlmostEqual(nominal, float(m.group(1)) * row["tool"]["cutter_diameter"], delta=1e-4)

    def test_derived_rows_state_their_rule(self):
        for name, _, row in self.rows():
            with self.subTest(row=row.get("id")):
                cut = row["cut"]
                if cut["fz"].get("nominal") is not None and "x .80" in str(cut["fz_basis"]):
                    self.assertIn("derivation", row["source"])

    def test_dataset_covers_key_materials_and_faces(self):
        fams = {r["material"]["toolwiz_family"] for _, _, r in self.rows()}
        self.assertTrue(any(f.startswith("Aluminum") for f in fams))
        self.assertTrue(any(f.startswith("Steel") for f in fams))
        self.assertTrue(any(f.startswith("Stainless") for f in fams))
        faces = {tuple(sorted(r["tool"]["cutting_faces"])) for _, _, r in self.rows()}
        self.assertTrue(any({"top", "bottom"} <= set(f) for f in faces), "need double-sided cutters")


if __name__ == "__main__":
    unittest.main()
