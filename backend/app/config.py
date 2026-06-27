from typing import Self

from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


INSECURE_JWT_SECRETS = {
    "",
    "change-me",
    "change-me-min-32-chars",
    "dev-only-change-in-production-min-32-chars",
}
MIN_PRODUCTION_JWT_SECRET_LENGTH = 32


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "postgresql://baller:baller@localhost:5432/baller"
    jwt_secret: str = "dev-only-change-in-production-min-32-chars"
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
    def validate_production_secrets(self) -> Self:
        if self.environment.lower() != "production":
            return self

        jwt_secret = self.jwt_secret.strip()
        if (
            jwt_secret in INSECURE_JWT_SECRETS
            or len(jwt_secret) < MIN_PRODUCTION_JWT_SECRET_LENGTH
        ):
            raise ValueError(
                "JWT_SECRET must be set to a random value of at least "
                "32 characters in production."
            )

        return self


settings = Settings()
