from fastapi.testclient import TestClient

from ballup.core.config import get_settings
from ballup.main import create_app


def test_docs_are_hidden_in_production(monkeypatch) -> None:
    monkeypatch.setenv("BALLUP_ENV", "production")
    get_settings.cache_clear()
    client = TestClient(create_app())

    assert client.get("/docs").status_code == 404
    assert client.get("/redoc").status_code == 404
    assert client.get("/openapi.json").status_code == 404
    get_settings.cache_clear()


def test_docs_are_available_in_development(monkeypatch) -> None:
    monkeypatch.setenv("BALLUP_ENV", "development")
    get_settings.cache_clear()
    client = TestClient(create_app())

    assert client.get("/docs").status_code == 200
    assert client.get("/openapi.json").status_code == 200
    get_settings.cache_clear()
