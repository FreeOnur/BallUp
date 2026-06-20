import unittest

from pydantic import ValidationError

from app.config import Settings


class SettingsTest(unittest.TestCase):
    def test_development_generates_ephemeral_jwt_secret_when_missing(self) -> None:
        settings = Settings(_env_file=None, environment="development")

        self.assertGreaterEqual(len(settings.jwt_secret), 32)

    def test_rejects_missing_production_jwt_secret(self) -> None:
        with self.assertRaises(ValidationError):
            Settings(_env_file=None, environment="production", jwt_secret="")

    def test_rejects_placeholder_jwt_secret(self) -> None:
        with self.assertRaises(ValidationError):
            Settings(
                _env_file=None,
                environment="production",
                jwt_secret="change-me-min-32-chars",
            )


if __name__ == "__main__":
    unittest.main()
