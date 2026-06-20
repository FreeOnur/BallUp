import secrets

from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


_PLACEHOLDER_JWT_SECRETS = {
    "change-me-min-32-chars",
    "dev-only-change-in-production-min-32-chars",
}


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "postgresql://baller:baller@localhost:5432/baller"
    jwt_secret: str = ""
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
    def validate_jwt_secret(self) -> "Settings":
        jwt_secret = self.jwt_secret.strip()
        is_development = self.environment.lower() == "development"

        if not jwt_secret and is_development:
            self.jwt_secret = secrets.token_urlsafe(48)
            return self

        if (
            len(jwt_secret) < 32
            or jwt_secret in _PLACEHOLDER_JWT_SECRETS
            or "change-me" in jwt_secret.lower()
        ):
            raise ValueError(
                "JWT_SECRET must be at least 32 random characters and cannot be a placeholder"
            )

        self.jwt_secret = jwt_secret
        return self


settings = Settings()
