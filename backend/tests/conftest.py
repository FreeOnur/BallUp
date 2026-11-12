from collections.abc import Iterator

import pytest

from ballup.core.config import get_settings


@pytest.fixture
def fresh_settings() -> Iterator[None]:
    """Clear the cached settings before and after a test, even if it fails."""
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()
