"""GET /api/shop_tools (used by the Fusion add-in's Strategy Planner)."""
import app as appmod


def test_shop_tools_lists_the_owner_cutters_read_only():
    c = appmod.app.test_client()
    r = c.get("/api/shop_tools")
    assert r.status_code == 200
    body = r.get_json()
    assert body["success"] is True
    ids = {t["id"] for t in body["tools"]}
    assert "klot_6x2" in ids
    assert all("name" in t for t in body["tools"])
    assert c.post("/api/shop_tools", headers={"X-ToolWiz-Client": "test"}).status_code == 405
