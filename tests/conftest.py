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


@pytest.fixture(autouse=True)
def _isolate_ai_settings(tmp_path, monkeypatch):
    """Advisor Chat: keys and saved chats go to a per-test temp directory, and no real provider key leaks in from the
    environment (the provider layer is mocked in tests; a real LLM is never called)."""
    monkeypatch.setenv("TOOLWIZ_AI_SETTINGS_PATH", str(tmp_path / "ai_settings.json"))
    monkeypatch.setenv("TOOLWIZ_ADVISOR_CHATS_DIR", str(tmp_path / "advisor_chats"))
    for k in ("ANTHROPIC_API_KEY", "GEMINI_API_KEY", "GOOGLE_API_KEY"):
        monkeypatch.delenv(k, raising=False)


@pytest.fixture(autouse=True)
def _isolate_machine_settings(tmp_path, monkeypatch):
    """The owner's own machine overrides (data/machine_settings.json, e.g. a saved runout) and custom machines
    (data/machines/) must not change test results, and tests must never write to them."""
    import app as toolwiz_app
    import machine_profiles
    monkeypatch.setattr(toolwiz_app, "MACHINE_SETTINGS_PATH", str(tmp_path / "machine_settings.json"))
    monkeypatch.setattr(machine_profiles, "USER_DIR", str(tmp_path / "machines"))
