from datetime import UTC, datetime
from uuid import UUID

from ballup.core.config import get_settings
from ballup.core.schemas import IdMixin, TimestampMixin


def test_settings_read_ballup_prefix(monkeypatch) -> None:
    monkeypatch.setenv("BALLUP_ENV", "test")
    monkeypatch.setenv("BALLUP_LOG_LEVEL", "DEBUG")
    get_settings.cache_clear()

    settings = get_settings()

    assert settings.env == "test"
    assert settings.log_level == "DEBUG"
    get_settings.cache_clear()


def test_settings_ignore_unprefixed_env(monkeypatch) -> None:
    monkeypatch.setenv("ENV", "production")
    get_settings.cache_clear()

    assert get_settings().env == "development"
    get_settings.cache_clear()


def test_schema_reads_attributes_from_an_object() -> None:
    class Card(IdMixin, TimestampMixin):
        pass

    created_at = datetime(2026, 1, 1, tzinfo=UTC)
    updated_at = datetime(2026, 1, 2, tzinfo=UTC)
    card_id = UUID("01932a7e-8b2c-7d4e-8f10-123456789abc")

    class Row:
        def __init__(self) -> None:
            self.id = card_id
            self.created_at = created_at
            self.updated_at = updated_at

    card = Card.model_validate(Row())

    assert card.id == card_id
    assert card.created_at == created_at
    assert card.updated_at == updated_at
