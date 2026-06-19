import unittest

from pydantic import ValidationError

from app.config import Settings


class SettingsValidationTest(unittest.TestCase):
    def build_settings(self, *, environment: str, jwt_secret: str) -> Settings:
        return Settings(
            environment=environment,
            jwt_secret=jwt_secret,
            _env_file=None,
        )

    def test_allows_default_development_jwt_secret(self) -> None:
        settings = self.build_settings(
            environment="development",
            jwt_secret="dev-only-change-in-production-min-32-chars",
        )

        self.assertEqual(settings.environment, "development")

    def test_rejects_blank_production_jwt_secret(self) -> None:
        with self.assertRaises(ValidationError):
            self.build_settings(environment="production", jwt_secret="")

    def test_rejects_placeholder_production_jwt_secret(self) -> None:
        with self.assertRaises(ValidationError):
            self.build_settings(
                environment="production",
                jwt_secret="change-me-min-32-chars",
            )

    def test_rejects_short_production_jwt_secret(self) -> None:
        with self.assertRaises(ValidationError):
            self.build_settings(environment="production", jwt_secret="too-short")

    def test_accepts_strong_production_jwt_secret(self) -> None:
        settings = self.build_settings(
            environment="production",
            jwt_secret="production-secret-with-32-plus-chars",
        )

        self.assertEqual(settings.environment, "production")


if __name__ == "__main__":
    unittest.main()
