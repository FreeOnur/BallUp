import unittest
from datetime import datetime, timezone
from uuid import uuid4

from fastapi import HTTPException
from pydantic import ValidationError

from app.config import Settings
from app.routers import auth


class SettingsSecurityTest(unittest.TestCase):
    def test_production_rejects_empty_jwt_secret(self) -> None:
        with self.assertRaises(ValidationError) as error:
            Settings(environment="production", jwt_secret="")

        self.assertIn("JWT_SECRET must be at least 32 characters", str(error.exception))

    def test_production_rejects_development_jwt_secret(self) -> None:
        with self.assertRaises(ValidationError) as error:
            Settings(
                environment="production",
                jwt_secret="dev-only-change-in-production-min-32-chars",
            )

        self.assertIn("JWT_SECRET must not use the development default", str(error.exception))


class _FakeCursor:
    def __init__(self, delete_row: dict[str, str] | None) -> None:
        self._delete_row = delete_row
        self._next_row: dict[str, str] | None = None
        self.statements: list[tuple[str, tuple[object, ...]]] = []

    def execute(self, query: str, params: tuple[object, ...]) -> None:
        self.statements.append((query, params))
        if query.lstrip().upper().startswith("DELETE"):
            self._next_row = self._delete_row

    def fetchone(self) -> dict[str, str] | None:
        return self._next_row


class _FakeConnection:
    def __init__(self, delete_row: dict[str, str] | None) -> None:
        self.cursor_instance = _FakeCursor(delete_row)

    def __enter__(self) -> "_FakeConnection":
        return self

    def __exit__(self, *_args: object) -> None:
        return None

    def cursor(self) -> _FakeCursor:
        return self.cursor_instance


class RefreshTokenSecurityTest(unittest.TestCase):
    def setUp(self) -> None:
        self._original_get_conn = auth.get_conn
        self._original_generate_refresh_token = auth.generate_refresh_token
        self._original_hash_refresh_token = auth.hash_refresh_token
        self._original_refresh_expires_at = auth.refresh_expires_at
        self._original_create_access_token = auth.create_access_token

    def tearDown(self) -> None:
        auth.get_conn = self._original_get_conn
        auth.generate_refresh_token = self._original_generate_refresh_token
        auth.hash_refresh_token = self._original_hash_refresh_token
        auth.refresh_expires_at = self._original_refresh_expires_at
        auth.create_access_token = self._original_create_access_token

    def test_refresh_consumes_existing_token_with_atomic_delete(self) -> None:
        user_id = uuid4()
        expires_at = datetime(2026, 1, 1, tzinfo=timezone.utc)
        fake_conn = _FakeConnection({"user_id": str(user_id), "email": "player@example.com"})

        auth.get_conn = lambda: fake_conn
        auth.generate_refresh_token = lambda: "new-refresh"
        auth.hash_refresh_token = lambda token: f"hash:{token}"
        auth.refresh_expires_at = lambda: expires_at
        auth.create_access_token = lambda user, email: f"access:{user}:{email}"

        response = auth.refresh(auth.RefreshRequest(refresh_token="old-refresh"))

        self.assertEqual(response.refresh_token, "new-refresh")
        self.assertEqual(response.user_id, str(user_id))
        self.assertEqual(response.access_token, f"access:{user_id}:player@example.com")

        statements = fake_conn.cursor_instance.statements
        self.assertEqual(len(statements), 2)
        delete_sql, delete_params = statements[0]
        self.assertIn("DELETE FROM refresh_tokens", delete_sql)
        self.assertIn("RETURNING rt.user_id, u.email", delete_sql)
        self.assertNotIn("SELECT", delete_sql.upper())
        self.assertEqual(delete_params, ("hash:old-refresh",))
        self.assertEqual(statements[1][1], (str(user_id), "hash:new-refresh", expires_at))

    def test_refresh_rejects_missing_token_without_issuing_replacement(self) -> None:
        fake_conn = _FakeConnection(None)

        auth.get_conn = lambda: fake_conn
        auth.hash_refresh_token = lambda token: f"hash:{token}"
        auth.generate_refresh_token = self._fail_if_called
        auth.create_access_token = self._fail_if_called

        with self.assertRaises(HTTPException) as error:
            auth.refresh(auth.RefreshRequest(refresh_token="already-used"))

        self.assertEqual(error.exception.status_code, 401)
        self.assertEqual(len(fake_conn.cursor_instance.statements), 1)

    @staticmethod
    def _fail_if_called(*_args: object) -> str:
        raise AssertionError("should not issue replacement tokens")
