"""Structure and arithmetic of tools/physics_vs_charts_study.py on a quick sample (the full study is a tool run, not a test)."""
import json
import os
import subprocess
import sys

import pytest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


@pytest.fixture(scope="module")
def study(tmp_path_factory):
    out = tmp_path_factory.mktemp("study") / "s.json"
    subprocess.run([sys.executable, os.path.join(ROOT, "tools", "physics_vs_charts_study.py"), "--quick", "--sample", "4",
                    "--out", str(out)], cwd=ROOT, check=True, capture_output=True, timeout=900)
    with open(out, encoding="utf-8") as fh:
        return json.load(fh)


def test_structure(study):
    assert study["meta"]["quick"] and study["meta"]["errors"] == 0
    assert {"aggregate", "second_pass", "whatif", "unnamed_probe", "coverage", "groups"} <= set(study)
    assert set(study["aggregate"]) == {f"{m}|{a}" for m in ("test60k", "speedio") for a in (0.5, 0.0, 1.0)}
    for g in study["groups"]:
        for k in ("test60k|0.5|a", "test60k|0.5|b", "test60k|0.5|c", "speedio|0.5|a", "speedio|1.0|b"):
            assert k in g["runs"], k


def test_shares_and_ratios(study):
    for sec in study["aggregate"].values():
        n = sec["n_groups"]
        assert n > 0
        for q in ("sfm", "fz"):
            r = sec["physics_only_vs_range"][q]
            assert sum(v["count"] for v in r.values()) == n
            assert abs(sum(v["pct"] for v in r.values()) - 100.0) < 0.5 + n * 0.05
        assert sum(sec["speed_decider"].values()) == n
        assert sum(sec["chip_category"].values()) == n
        for q in sec["ratio_b_over_chart_median"].values():
            assert q["min"] > 0
        assert sec["vendor_binds_both"]["count"] <= min(sec["vendor_binds_speed"]["count"], sec["vendor_binds_chip"]["count"])


def test_coverage_arithmetic(study):
    cov = study["coverage"]
    assert sum(cov["histogram_vendors"].values()) == cov["cells_total"] == len(cov["cells"])
    assert abs(sum(cov["pct"].values()) - 100.0) < 0.3


def test_unnamed_grade_probe(study):
    assert study["unnamed_probe"] and all(p["identical"] for p in study["unnamed_probe"])
