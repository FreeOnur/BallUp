import asyncio
from datetime import UTC, datetime
from typing import cast
from uuid import UUID

from sqlalchemy import String
from sqlalchemy.dialects import postgresql
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import Mapped, mapped_column

from ballup.core.models import Entity, SoftDeleteMixin
from ballup.core.service import BaseService, Cursor
from ballup.exceptions import NotFoundException


class Sample(SoftDeleteMixin, Entity):
    __tablename__ = "samples"

    name: Mapped[str] = mapped_column(String(50))


class Plain(Entity):
    __tablename__ = "plains"

    name: Mapped[str] = mapped_column(String(50))


class SampleService(BaseService[Sample]):
    model = Sample


class PlainService(BaseService[Plain]):
    model = Plain


def _sql(statement: object) -> str:
    compiled = statement.compile(dialect=postgresql.dialect())  # type: ignore[attr-defined]
    return str(compiled)


def test_id_and_timestamps_come_from_the_database() -> None:
    table = Sample.__table__

    assert "uuidv7()" in str(table.c.id.server_default.arg)
    assert "now()" in str(table.c.created_at.server_default.arg)
    assert "now()" in str(table.c.updated_at.server_default.arg)
    assert table.c.updated_at.onupdate is None
    assert table.c.deleted_at.nullable is True


def test_list_uses_cursor_and_hides_deleted_rows() -> None:
    service = SampleService(cast(AsyncSession, None))
    cursor = Cursor(
        created_at=datetime(2026, 1, 1, tzinfo=UTC),
        id=UUID("01932a7e-8b2c-7d4e-8f10-123456789abc"),
    )

    sql = _sql(service.list_statement(cursor=cursor, limit=500))

    assert "LIMIT" in sql
    assert "deleted_at IS NULL" in sql
    assert "created_at" in sql
    assert "ORDER BY" in sql


def test_list_limit_stays_inside_the_page_bounds() -> None:
    service = PlainService(cast(AsyncSession, None))

    assert service._bounded_limit(50) == 50
    assert service._bounded_limit(500) == 100
    assert service._bounded_limit(0) == 1
    assert "deleted_at" not in _sql(service.list_statement(limit=50))


def test_soft_delete_sets_deleted_at_in_sql() -> None:
    service = SampleService(cast(AsyncSession, None))
    entity_id = UUID("01932a7e-8b2c-7d4e-8f10-123456789abc")

    sql = _sql(service.soft_delete_statement(entity_id))

    assert "deleted_at" in sql
    assert "now()" in sql


def test_soft_delete_rejects_models_without_the_column() -> None:
    service = PlainService(cast(AsyncSession, None))

    try:
        service.soft_delete_statement(UUID("01932a7e-8b2c-7d4e-8f10-123456789abc"))
    except TypeError as error:
        assert "deleted_at" in str(error)
    else:
        raise AssertionError("expected TypeError")


class FakeResult:
    def __init__(self, entity: Sample | None = None, rows: list[Sample] | None = None) -> None:
        self.entity = entity
        self.rows = rows or []

    def scalar_one_or_none(self) -> Sample | None:
        return self.entity

    def scalars(self) -> FakeResult:
        return self

    def all(self) -> list[Sample]:
        return self.rows


class FakeSession:
    def __init__(self, result: FakeResult | None = None) -> None:
        self.result = result or FakeResult()
        self.added: list[object] = []
        self.statements: list[object] = []
        self.flushed = 0

    async def execute(self, statement: object) -> FakeResult:
        self.statements.append(statement)
        return self.result

    def add(self, entity: object) -> None:
        self.added.append(entity)

    async def flush(self) -> None:
        self.flushed += 1


def test_get_returns_the_row() -> None:
    entity = Sample(name="court")
    session = FakeSession(FakeResult(entity=entity))
    service = SampleService(cast(AsyncSession, session))

    found = asyncio.run(service.get(UUID("01932a7e-8b2c-7d4e-8f10-123456789abc")))

    assert found is entity


def test_list_returns_rows() -> None:
    entity = Sample(name="court")
    session = FakeSession(FakeResult(rows=[entity]))
    service = SampleService(cast(AsyncSession, session))

    rows = asyncio.run(service.list())

    assert rows == [entity]


def test_soft_delete_executes_and_flushes() -> None:
    session = FakeSession()
    service = SampleService(cast(AsyncSession, session))
    entity_id = UUID("01932a7e-8b2c-7d4e-8f10-123456789abc")

    asyncio.run(service.soft_delete(entity_id))

    assert session.flushed == 1
    assert session.statements


def test_get_raises_when_the_row_is_missing() -> None:
    session = FakeSession()
    service = SampleService(cast(AsyncSession, session))

    try:
        asyncio.run(service.get(UUID("01932a7e-8b2c-7d4e-8f10-123456789abc")))
    except NotFoundException as error:
        assert error.status_code == 404
    else:
        raise AssertionError("expected NotFoundException")


def test_create_and_update_flush_without_setting_timestamps() -> None:
    session = FakeSession()
    service = SampleService(cast(AsyncSession, session))
    entity = Sample(name="court")

    created = asyncio.run(service.create(entity))
    updated = asyncio.run(service.update(entity))

    assert created is entity
    assert updated is entity
    assert session.added == [entity, entity]
    assert session.flushed == 2
