import asyncio

from sqlalchemy.ext.asyncio import AsyncSession

from ballup.core import database
from ballup.core.config import get_settings


def test_engine_and_sessionmaker_are_created_once(monkeypatch) -> None:
    sentinel = object()
    calls = {"engine": 0}

    def fake_engine(url: str, *, pool_pre_ping: bool) -> object:
        calls["engine"] += 1
        assert url == get_settings().database_url
        assert pool_pre_ping is True
        return sentinel

    def fake_sessionmaker(engine: object, *, expire_on_commit: bool) -> str:
        assert engine is sentinel
        assert expire_on_commit is False
        return "maker"

    monkeypatch.setattr(database, "create_async_engine", fake_engine)
    monkeypatch.setattr(database, "async_sessionmaker", fake_sessionmaker)
    monkeypatch.setattr(database, "_engine", None)
    monkeypatch.setattr(database, "_sessionmaker", None)

    assert database.get_engine() is sentinel
    assert database.get_engine() is sentinel
    assert calls["engine"] == 1

    assert database.get_sessionmaker() == "maker"
    assert database.get_sessionmaker() == "maker"


def test_get_session_yields_the_session_from_the_factory(monkeypatch) -> None:
    class FakeSession:
        async def __aenter__(self) -> AsyncSession:
            return self  # type: ignore[return-value]

        async def __aexit__(self, *_exc: object) -> None:
            return None

    monkeypatch.setattr(database, "get_sessionmaker", lambda: FakeSession)

    async def take() -> object:
        async for session in database.get_session():
            return session
        return None

    assert asyncio.run(take()) is not None
