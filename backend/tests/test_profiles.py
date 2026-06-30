import contextlib
import unittest
from uuid import uuid4

from app.routers import profiles


class CapturingCursor:
    def __init__(self) -> None:
        self.executed: list[tuple[str, tuple[object, ...]]] = []

    def execute(self, sql: str, params: tuple[object, ...]) -> None:
        self.executed.append((sql, params))

    def fetchone(self) -> dict[str, object]:
        return {
            "id": str(uuid4()),
            "username": "existing",
            "avatar_url": "avatar.png",
            "age": None,
            "location": None,
            "gender": None,
            "skill_level": None,
        }


class FakeConnection:
    def __init__(self, cursor: CapturingCursor) -> None:
        self._cursor = cursor

    def cursor(self) -> CapturingCursor:
        return self._cursor


class ProfileUpdateTests(unittest.TestCase):
    def test_omitted_username_is_not_converted_to_empty_string(self) -> None:
        cursor = CapturingCursor()

        @contextlib.contextmanager
        def fake_get_conn():
            yield FakeConnection(cursor)

        original_get_conn = profiles.get_conn
        profiles.get_conn = fake_get_conn
        try:
            profiles.upsert_my_profile(
                profiles.ProfileUpdate(avatar_url="avatar.png"),
                uuid4(),
            )
        finally:
            profiles.get_conn = original_get_conn

        sql, params = cursor.executed[0]
        self.assertIn("VALUES (%s, COALESCE(%s, '')", sql)
        self.assertIn("username = COALESCE(%s, profiles.username)", sql)
        self.assertIsNone(params[1])
        self.assertIsNone(params[-1])


if __name__ == "__main__":
    unittest.main()
