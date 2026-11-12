import logging

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from ballup.core.app_version import EXEMPT_PATHS, AppVersionMiddleware, parse_app_version

OLD_MESSAGE = "This app version is no longer supported. Please update."


def make_client(ios: str = "", android: str = "") -> TestClient:
    app = FastAPI()
    app.add_middleware(AppVersionMiddleware, min_ios=ios, min_android=android)

    @app.get("/v1/ping")
    async def ping() -> dict[str, str]:
        return {"status": "pong"}

    @app.get("/health")
    async def health() -> dict[str, str]:
        return {"status": "ok"}

    return TestClient(app)


def headers(version: str | None, platform: str | None = "ios") -> dict[str, str]:
    result: dict[str, str] = {}
    if version is not None:
        result["X-App-Version"] = version
    if platform is not None:
        result["X-App-Platform"] = platform
    return result


@pytest.mark.parametrize(
    ("value", "expected"),
    [("1.4.2", (1, 4, 2)), ("0.0.0", (0, 0, 0)), ("123456.1.99", (123456, 1, 99))],
)
def test_parse_app_version_accepts_semver(value: str, expected: tuple[int, int, int]) -> None:
    assert parse_app_version(value) == expected


@pytest.mark.parametrize("value", ["", "1.2", "1.2.3.4", "v1.2.3", "1.2.x", "1234567.0.0"])
def test_parse_app_version_rejects_invalid(value: str) -> None:
    assert parse_app_version(value) is None


def test_versions_compare_numerically() -> None:
    low = parse_app_version("1.9.0")
    high = parse_app_version("1.10.0")
    assert low is not None
    assert high is not None
    assert low < high


def test_old_version_gets_426_with_error_format() -> None:
    response = make_client(ios="1.2.0").get("/v1/ping", headers=headers("1.1.9"))

    assert response.status_code == 426
    assert response.json() == {"error": {"code": "app_version_too_old", "message": OLD_MESSAGE}}
    assert "upgrade" not in response.headers


def test_old_version_is_blocked_on_unknown_routes() -> None:
    response = make_client(ios="1.2.0").get("/v0/gone", headers=headers("1.0.0"))

    assert response.status_code == 426


def test_current_version_passes() -> None:
    assert make_client(ios="1.2.0").get("/v1/ping", headers=headers("1.2.0")).status_code == 200


def test_newer_version_passes() -> None:
    client = make_client(ios="1.9.0")

    assert client.get("/v1/ping", headers=headers("1.10.0")).status_code == 200


def test_missing_version_header_passes() -> None:
    assert make_client(ios="1.2.0").get("/v1/ping").status_code == 200


@pytest.mark.parametrize("platform", [None, "windows", ""])
def test_missing_or_unknown_platform_passes(platform: str | None) -> None:
    response = make_client(ios="9.0.0", android="9.0.0").get(
        "/v1/ping", headers=headers("1.0.0", platform)
    )

    assert response.status_code == 200


def test_invalid_version_header_gets_400() -> None:
    response = make_client(ios="1.2.0").get("/v1/ping", headers=headers("v1.x"))

    assert response.status_code == 400
    assert response.json()["error"]["code"] == "invalid_app_version"


def test_invalid_version_header_gets_400_even_without_platform() -> None:
    response = make_client().get("/v1/ping", headers=headers("abc", None))

    assert response.status_code == 400


def test_no_min_version_configured_passes() -> None:
    client = make_client(android="2.0.0")

    assert client.get("/v1/ping", headers=headers("0.0.1", "ios")).status_code == 200
    assert client.get("/v1/ping", headers=headers("1.0.0", "android")).status_code == 426


def test_platform_header_is_case_insensitive() -> None:
    client = make_client(ios="1.2.0", android="1.2.0")

    assert client.get("/v1/ping", headers=headers("1.0.0", "IOS")).status_code == 426
    assert client.get("/v1/ping", headers=headers("1.0.0", "Android")).status_code == 426


@pytest.mark.parametrize("path", sorted(EXEMPT_PATHS))
def test_health_and_docs_never_blocked(path: str) -> None:
    client = make_client(ios="9.0.0")

    response = client.get(path, headers=headers("invalid-and-old"))

    assert response.status_code != 426
    assert response.status_code != 400


def test_exempt_paths_match_spec() -> None:
    assert {"/health", "/docs", "/docs/oauth2-redirect", "/redoc", "/openapi.json"} == EXEMPT_PATHS


@pytest.mark.usefixtures("fresh_settings")
def test_app_factory_wires_middleware_from_settings(monkeypatch) -> None:
    from ballup.main import create_app

    monkeypatch.setenv("BALLUP_MIN_APP_VERSION_IOS", "1.2.0")
    client = TestClient(create_app())

    assert client.get("/health", headers=headers("1.1.9")).status_code == 200
    assert client.get("/nope", headers=headers("1.1.9")).status_code == 426
    assert client.get("/nope", headers=headers("1.2.0")).status_code == 404


def test_middleware_rejects_invalid_min_version() -> None:
    with pytest.raises(ValueError, match="Invalid minimum app version"):
        AppVersionMiddleware(FastAPI(), min_ios="1.2")


def test_rejection_is_logged_with_platform_and_versions(caplog: pytest.LogCaptureFixture) -> None:
    with caplog.at_level(logging.WARNING, logger="ballup.core.app_version"):
        make_client(ios="1.2.0").get("/v1/ping", headers=headers("1.1.9"))

    assert "app_version_rejected platform=ios app_version=1.1.9 min_version=1.2.0" in caplog.text


@pytest.mark.parametrize("method", ["HEAD", "OPTIONS"])
def test_old_version_is_blocked_for_head_and_options(method: str) -> None:
    response = make_client(ios="1.2.0").request(method, "/v1/ping", headers=headers("1.0.0"))

    assert response.status_code == 426


@pytest.mark.parametrize("path", ["/health/", "/Health"])
def test_exempt_paths_are_matched_exactly(path: str) -> None:
    """Path variants are not exempt (exact comparison, as in the spec), so old apps get 426."""
    response = make_client(ios="1.2.0").get(path, headers=headers("1.0.0"))

    assert response.status_code == 426
