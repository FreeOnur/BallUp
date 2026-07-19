from typing import ClassVar, Self

from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    DEVELOPMENT_JWT_SECRET: ClassVar[str] = "dev-only-change-in-production-min-32-chars"
    MINIMUM_JWT_SECRET_LENGTH: ClassVar[int] = 32

    database_url: str = "postgresql://baller:baller@localhost:5432/baller"
    jwt_secret: str = DEVELOPMENT_JWT_SECRET
    jwt_access_minutes: int = 15
    jwt_refresh_days: int = 30
    cors_origins: str = "http://localhost:*"
    environment: str = "development"

    b2_key_id: str = ""
    b2_app_key: str = ""
    b2_bucket: str = "courtfinder-image"
    b2_endpoint: str = "https://s3.eu-central-003.backblazeb2.com"
    b2_region: str = "eu-central-003"

    @model_validator(mode="after")
    def require_secure_production_jwt_secret(self) -> Self:
        if self.environment.strip().lower() == "development":
            return self

        secret = self.jwt_secret.strip()
        if (
            len(secret) < self.MINIMUM_JWT_SECRET_LENGTH
            or secret == self.DEVELOPMENT_JWT_SECRET
        ):
            raise ValueError(
                "JWT_SECRET must be at least 32 characters and must not use "
                "the development default in production"
            )
        return self


settings = Settings()
