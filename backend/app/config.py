from typing import Self

from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


_DEV_JWT_SECRET = "dev-only-change-in-production-min-32-chars"
_MIN_PRODUCTION_JWT_SECRET_LENGTH = 32
_UNSAFE_PRODUCTION_JWT_SECRETS = {
    "",
    _DEV_JWT_SECRET,
    "change-me-min-32-chars",
}


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "postgresql://baller:baller@localhost:5432/baller"
    jwt_secret: str = _DEV_JWT_SECRET
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
    def validate_production_jwt_secret(self) -> Self:
        if self.environment.lower() != "production":
            return self

        jwt_secret = self.jwt_secret.strip()
        if (
            jwt_secret != self.jwt_secret
            or jwt_secret in _UNSAFE_PRODUCTION_JWT_SECRETS
            or len(jwt_secret) < _MIN_PRODUCTION_JWT_SECRET_LENGTH
        ):
            raise ValueError(
                "JWT_SECRET must be a non-placeholder value with at least "
                f"{_MIN_PRODUCTION_JWT_SECRET_LENGTH} characters in production"
            )

        return self


settings = Settings()
