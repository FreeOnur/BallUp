from collections.abc import Sequence
from dataclasses import dataclass
from datetime import datetime
from uuid import UUID

from sqlalchemy import Select, func, select, tuple_, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.sql.dml import Update

from ballup.core.models import Entity
from ballup.exceptions import NotFoundException

DEFAULT_LIMIT = 50
MAX_LIMIT = 100


@dataclass(frozen=True, slots=True)
class Cursor:
    created_at: datetime
    id: UUID


class BaseService[ModelT: Entity]:
    model: type[ModelT]
    not_found_exception: type[NotFoundException] = NotFoundException

    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    def _alive(self, statement: Select[ModelT]) -> Select[ModelT]:
        deleted_at = getattr(self.model, "deleted_at", None)
        if deleted_at is None:
            return statement
        return statement.where(deleted_at.is_(None))

    def _bounded_limit(self, limit: int) -> int:
        return min(max(limit, 1), MAX_LIMIT)

    def list_statement(
        self,
        *,
        cursor: Cursor | None = None,
        limit: int = DEFAULT_LIMIT,
    ) -> Select[ModelT]:
        statement = self._alive(select(self.model))
        if cursor is not None:
            statement = statement.where(
                tuple_(self.model.created_at, self.model.id) < tuple_(cursor.created_at, cursor.id)
            )
        return statement.order_by(self.model.created_at.desc(), self.model.id.desc()).limit(
            self._bounded_limit(limit)
        )

    def soft_delete_statement(self, entity_id: UUID) -> Update:
        if getattr(self.model, "deleted_at", None) is None:
            message = f"{self.model.__name__} has no deleted_at"
            raise TypeError(message)
        return update(self.model).where(self.model.id == entity_id).values(deleted_at=func.now())

    async def get(self, entity_id: UUID) -> ModelT:
        statement = self._alive(select(self.model).where(self.model.id == entity_id))
        entity = (await self.session.execute(statement)).scalar_one_or_none()
        if entity is None:
            raise self.not_found_exception()
        return entity

    async def list(
        self,
        *,
        cursor: Cursor | None = None,
        limit: int = DEFAULT_LIMIT,
    ) -> Sequence[ModelT]:
        result = await self.session.execute(self.list_statement(cursor=cursor, limit=limit))
        return result.scalars().all()

    async def create(self, entity: ModelT) -> ModelT:
        self.session.add(entity)
        await self.session.flush()
        return entity

    async def update(self, entity: ModelT) -> ModelT:
        self.session.add(entity)
        await self.session.flush()
        return entity

    async def soft_delete(self, entity_id: UUID) -> None:
        await self.session.execute(self.soft_delete_statement(entity_id))
        await self.session.flush()
