

def test_version_is_shown_on_the_page_and_api():
    import app as A
    c = A.app.test_client()
    v = c.get("/api/version").get_json()
    assert v["success"] and v["label"]
    html = c.get("/").get_data(as_text=True)
    assert 'id="buildInfo"' in html and v["label"] in html
