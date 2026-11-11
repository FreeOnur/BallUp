"""Force update: reject app versions below a per-platform minimum (spec app-version.md).

Pure ASGI middleware, so it runs before routing (also for routes that no longer exist) and
does not interfere with streaming responses. It is not a security feature: clients can omit
the headers, which is why a missing header is allowed.
"""

import json
import logging
import re
from collections.abc import Mapping

from starlette.datastructures import Headers
from starlette.types import ASGIApp, Receive, Scope, Send

logger = logging.getLogger(__name__)

AppVersion = tuple[int, int, int]

VERSION_HEADER = "x-app-version"
PLATFORM_HEADER = "x-app-platform"

EXEMPT_PATHS = frozenset({"/health", "/docs", "/docs/oauth2-redirect", "/redoc", "/openapi.json"})

_VERSION_RE = re.compile(r"^(\d{1,6})\.(\d{1,6})\.(\d{1,6})$", re.ASCII)

TOO_OLD_MESSAGE = "This app version is no longer supported. Please update."
INVALID_MESSAGE = "The X-App-Version header must look like MAJOR.MINOR.PATCH."


def parse_app_version(value: str) -> AppVersion | None:
    """Parse ``MAJOR.MINOR.PATCH`` (digits only) into a tuple, or return None if invalid."""
    match = _VERSION_RE.fullmatch(value)
    if match is None:
        return None
    major, minor, patch = (int(part) for part in match.groups())
    return major, minor, patch


class AppVersionMiddleware:
    def __init__(self, app: ASGIApp, min_ios: str = "", min_android: str = "") -> None:
        self.app = app
        minimums: dict[str, AppVersion] = {}
        for platform, raw in (("ios", min_ios), ("android", min_android)):
            if not raw:
                continue
            parsed = parse_app_version(raw)
            if parsed is None:
                msg = f"Invalid minimum app version for {platform}: {raw!r}"
                raise ValueError(msg)
            minimums[platform] = parsed
        self.minimums: Mapping[str, AppVersion] = minimums

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http" or scope["path"] in EXEMPT_PATHS:
            await self.app(scope, receive, send)
            return

        headers = Headers(scope=scope)
        raw_version = headers.get(VERSION_HEADER)
        if raw_version is None:
            await self.app(scope, receive, send)
            return

        version = parse_app_version(raw_version)
        if version is None:
            await _send_error(send, 400, "invalid_app_version", INVALID_MESSAGE)
            return

        platform = headers.get(PLATFORM_HEADER, "").lower()
        minimum = self.minimums.get(platform)
        if minimum is not None and version < minimum:
            logger.warning(
                "app_version_rejected",
                extra={
                    "platform": platform,
                    "app_version": raw_version,
                    "min_version": ".".join(str(part) for part in minimum),
                },
            )
            await _send_error(send, 426, "app_version_too_old", TOO_OLD_MESSAGE)
            return

        await self.app(scope, receive, send)


async def _send_error(send: Send, status: int, code: str, message: str) -> None:
    body = json.dumps({"error": {"code": code, "message": message}}).encode()
    await send(
        {
            "type": "http.response.start",
            "status": status,
            "headers": [
                (b"content-type", b"application/json"),
                (b"content-length", str(len(body)).encode()),
            ],
        }
    )
    await send({"type": "http.response.body", "body": body})
