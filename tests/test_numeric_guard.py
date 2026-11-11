"""toolwiz_common.numeric_guard: numbers in LLM text must come from the ToolWiz result (rounding, unit conversion allowed)."""
import os
import sys

import pytest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, ROOT)

from toolwiz_common import numeric_guard as ng  # noqa: E402

GROUND = {
    "tool": {"description": "1/16\" 4FL end mill", "diameter_in": 0.0625, "flutes": 4},
    "material": "Ti-6Al-4V (Grade 5, Annealed)",
    "toolwiz": {"rpm": 13821, "feed_ipm": 14.37, "sfm": 226.1, "chip_load_ipt": 0.00026, "ap_in": 0.1875,
                "stock_in": 0.002, "speedup_x": 2.5, "saving_pct": 60, "time_min": 2.63, "ratio": 0.4},
    "counts": {"stop": 3, "caution": 5},
}


def ok(text, **kw):
    return ng.check_numbers(text, GROUND, **kw)


@pytest.mark.parametrize("text", [
    "Run 13821 rpm at 14.37 IPM.",
    "About 13,800 rpm is what ToolWiz gives (13821).",            # thousands separator, within 0.5 %
    "Chip load 0.00026 in/tooth, i.e. 0.0003 IPT",                  # rounding to the printed digits
    "Feed 14.4 IPM",                                                # rounded
    "Depth of cut 0.1875 in (3/16\")",                              # fraction of the same number
    "Tool is 1/16\" and 1.5875 mm in diameter",                    # in <-> mm
    "Feed 365 mm/min",                                              # IPM -> mm/min (14.37 x 25.4 = 365.0)
    "Speed 68.9 m/min",                                             # SFM -> m/min
    "Stock to leave 0.002 in (0.05 mm)",
    "That is 2.5x faster and saves 60%",
    "Roughly 40% of the cut",                                       # 0.4 ratio as a percentage
    "3 STOP findings and 5 CAUTION findings",                       # counts present in the JSON
    "Ti-6Al-4V, a 4FL tool in 2D and 3D toolpaths",                 # identifiers are not numbers
    "1. Fix the chip load\n2. Check the holder",                    # list markers
    "About 2.63 minutes per part, or 158 seconds",                  # min <-> s
])
def test_passes(text):
    r = ok(text)
    assert r["ok"], (text, r)


@pytest.mark.parametrize("text, bad", [
    ("Use 0.003 IPT for this cut", "0.003 IPT"),                    # fabricated chip load (the owner's example)
    ("Run 18000 rpm", "18000 rpm"),
    ("Feed 22 IPM", "22 IPM"),
    ("Take 0.250 in deep passes", "0.250 in"),
    ("Leave 0.010 in of stock", "0.010 in"),
    ("Cycle time 7.5 minutes", "7.5 minutes"),
    ("Speed 400 SFM", "400 SFM"),
    ("About 12 flutes", "12"),                                      # a small count that is not in the JSON
    ("Save 45%", "45%"),
    ("Use 7 mm stepover", "7 mm"),                                  # 7 mm is not any grounded length
])
def test_rejects(text, bad):
    r = ok(text)
    assert not r["ok"]
    assert any(x.startswith(bad) for x in r["rejected_numbers"]), r


def test_units_must_match_the_quantity():
    g = {"stock_to_leave_in": 0.003, "note": "leave 0.003 in of stock", "chip_load_ipt": 0.0012}
    assert ng.check_numbers("leave 0.003 in", g)["ok"]
    assert ng.check_numbers("leave 0.003", g)["ok"]                    # no unit: any grounded number
    r = ng.check_numbers("feed 0.003 IPT", g)                          # a length is not a chip load
    assert not r["ok"] and r["rejected_numbers"] == ["0.003 IPT"]
    assert ng.check_numbers("feed 0.0012 in/tooth", g)["ok"]


def test_unit_conversion_is_directional():
    # 0.1875 in grounds 4.7625 mm, not 4.7625 in
    assert ok("depth 4.76 mm")["ok"]
    assert not ok("depth 4.76 in")["ok"]


def test_numbers_in_extra_texts_are_allowed():
    r = ng.check_numbers("You asked about 0.375 in; ToolWiz says 13821 rpm.", GROUND, extra_texts=["what rpm for a 0.375 in tool?"])
    assert r["ok"], r


def test_signs_are_ignored():
    assert ng.check_numbers("stock -0.0005 in", {"x": 0.0005})["ok"]


def test_extract_numbers_tokens():
    toks = ng.extract_numbers('1 1/2 in, 3/8", .5 mm, 1,200 rpm, 40%, 2x')
    assert [round(t.value, 4) for t in toks] == [1.5, 0.375, 0.5, 1200.0, 40.0, 2.0]
    assert [t.unit for t in toks] == ["in", "in", "mm", "rpm", "%", "x"]


def test_urls_and_identifiers_skipped():
    assert ng.extract_numbers("see https://example.com/a/12345 and the 3D, 2D, T6, V2, 1st items") == []


def test_collect_numbers_reads_strings():
    vals = ng.collect_numbers({"a": "6061-T6 at 1/16 in", "b": [1, 2.5], "c": True})
    for v in (6061.0, 6.0, 0.0625, 1.0, 2.5):
        assert v in vals
    assert len(vals) == 5          # the bool is not a number
