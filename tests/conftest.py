import os
import pytest


@pytest.fixture(autouse=True)
def _isolate_toolwiz_data_dir(tmp_path, monkeypatch):
    """Redirect BackupManager data/ and backups/ writes to a per-test temp directory
    so running the test suite never dirties the tracked data/working_library.json."""
    monkeypatch.setenv("TOOLWIZ_DATA_DIR", str(tmp_path))
