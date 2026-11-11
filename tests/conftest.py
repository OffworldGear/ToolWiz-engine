import os
import pytest


@pytest.fixture(autouse=True)
def _isolate_toolwiz_data_dir(tmp_path, monkeypatch):
    """Redirect BackupManager data/ and backups/ writes to a per-test temp directory
    so running the test suite never dirties the tracked data/working_library.json."""
    monkeypatch.setenv("TOOLWIZ_DATA_DIR", str(tmp_path))


@pytest.fixture(autouse=True)
def _legacy_tests_use_v1(monkeypatch):
    """The production default cutting model is v2 (v2_bridge.resolve_model). Most existing suites were written
    for the v1 tables, so the test environment pins v1 through TOOLWIZ_MODEL; v2 tests pass model="v2" explicitly,
    and tests of the default clear the variable (see tests/test_v2_bridge.py)."""
    monkeypatch.setenv("TOOLWIZ_MODEL", "v1")
