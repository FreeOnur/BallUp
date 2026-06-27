import unittest

from pydantic import ValidationError

from app.config import Settings


class SettingsTest(unittest.TestCase):
    def test_development_allows_default_jwt_secret(self) -> None:
        settings = Settings(_env_file=None, environment="development")

        self.assertEqual(settings.environment, "development")

    def test_production_requires_strong_jwt_secret(self) -> None:
        invalid_secrets = [
            "",
            "change-me-min-32-chars",
            "dev-only-change-in-production-min-32-chars",
            "too-short",
        ]

        for jwt_secret in invalid_secrets:
            with self.subTest(jwt_secret=jwt_secret):
                with self.assertRaises(ValidationError):
                    Settings(
                        _env_file=None,
                        environment="production",
                        jwt_secret=jwt_secret,
                    )

    def test_production_accepts_random_jwt_secret(self) -> None:
        settings = Settings(
            _env_file=None,
            environment="production",
            jwt_secret="0123456789abcdef0123456789abcdef",
        )

        self.assertEqual(settings.jwt_secret, "0123456789abcdef0123456789abcdef")


if __name__ == "__main__":
    unittest.main()
