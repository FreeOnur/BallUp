from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class BaseSchema(BaseModel):
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)


class IdMixin(BaseSchema):
    id: UUID


class TimestampMixin(BaseSchema):
    created_at: datetime
    updated_at: datetime
