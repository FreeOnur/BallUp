from functools import lru_cache

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

from ballup.core.app_version import parse_app_version


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_prefix="BALLUP_",
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    env: str = "development"
    log_level: str = "INFO"
    database_url: str = "postgresql+asyncpg://ballup:ballup@127.0.0.1:5432/ballup"
    redis_url: str = "redis://localhost:6379/0"
    s3_endpoint: str = ""
    s3_bucket: str = ""
    s3_access_key_id: str = ""
    s3_secret_access_key: str = ""
    min_app_version_ios: str = ""
    min_app_version_android: str = ""

    @field_validator("min_app_version_ios", "min_app_version_android")
    @classmethod
    def _valid_min_app_version(cls, value: str) -> str:
        if value and parse_app_version(value) is None:
            msg = "must look like MAJOR.MINOR.PATCH (digits only) or be empty"
            raise ValueError(msg)
        return value


@lru_cache
def get_settings() -> Settings:
    return Settings()
