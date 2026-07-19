import os
import unittest

from pydantic import ValidationError

os.environ["ENVIRONMENT"] = "development"

from app.config import Settings


class SettingsTest(unittest.TestCase):
    def test_production_rejects_insecure_jwt_secrets(self) -> None:
        insecure_secrets = (
            "",
            "too-short",
            Settings.DEVELOPMENT_JWT_SECRET,
        )

        for jwt_secret in insecure_secrets:
            with self.subTest(jwt_secret=jwt_secret):
                with self.assertRaisesRegex(
                    ValidationError,
                    "JWT_SECRET must be at least 32 characters",
                ):
                    Settings(
                        _env_file=None,
                        environment="production",
                        jwt_secret=jwt_secret,
                    )

    def test_production_accepts_strong_jwt_secret(self) -> None:
        settings = Settings(
            _env_file=None,
            environment="production",
            jwt_secret="x" * Settings.MINIMUM_JWT_SECRET_LENGTH,
        )

        self.assertEqual(
            settings.jwt_secret,
            "x" * Settings.MINIMUM_JWT_SECRET_LENGTH,
        )

    def test_development_allows_development_jwt_secret(self) -> None:
        settings = Settings(
            _env_file=None,
            environment="development",
            jwt_secret=Settings.DEVELOPMENT_JWT_SECRET,
        )

        self.assertEqual(settings.jwt_secret, Settings.DEVELOPMENT_JWT_SECRET)


if __name__ == "__main__":
    unittest.main()
