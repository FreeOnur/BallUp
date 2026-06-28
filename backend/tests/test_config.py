import unittest

from pydantic import ValidationError

from app.config import Settings


class SettingsTest(unittest.TestCase):
    def test_development_allows_default_jwt_secret(self) -> None:
        settings = Settings(environment="development")

        self.assertEqual(settings.environment, "development")

    def test_production_rejects_example_jwt_secret(self) -> None:
        with self.assertRaises(ValidationError):
            Settings(environment="production", jwt_secret="change-me-min-32-chars")

    def test_production_rejects_short_jwt_secret(self) -> None:
        with self.assertRaises(ValidationError):
            Settings(environment="production", jwt_secret="short")

    def test_production_accepts_long_unique_jwt_secret(self) -> None:
        settings = Settings(
            environment="production",
            jwt_secret="replace-this-with-a-random-64-character-production-secret",
        )

        self.assertEqual(settings.environment, "production")


if __name__ == "__main__":
    unittest.main()
