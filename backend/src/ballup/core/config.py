from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


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


@lru_cache
def get_settings() -> Settings:
    return Settings()
