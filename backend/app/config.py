from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


_DEV_JWT_SECRET = "dev-only-change-in-production-min-32-chars"
_MIN_PRODUCTION_JWT_SECRET_LENGTH = 32


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
    def validate_production_secrets(self) -> "Settings":
        if self.environment.lower() != "production":
            return self

        if len(self.jwt_secret.strip()) < _MIN_PRODUCTION_JWT_SECRET_LENGTH:
            raise ValueError("JWT_SECRET must be at least 32 characters in production")
        if self.jwt_secret == _DEV_JWT_SECRET:
            raise ValueError("JWT_SECRET must not use the development default in production")

        return self


settings = Settings()
