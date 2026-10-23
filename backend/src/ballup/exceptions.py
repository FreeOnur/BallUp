from fastapi import HTTPException


class DetailedHTTPException(HTTPException):
    def __init__(
        self,
        status_code: int,
        detail: str,
        headers: dict[str, str] | None = None,
    ) -> None:
        super().__init__(status_code=status_code, detail=detail, headers=headers)


class BadRequestException(DetailedHTTPException):
    def __init__(self, detail: str = "Bad request", headers: dict[str, str] | None = None) -> None:
        super().__init__(status_code=400, detail=detail, headers=headers)


class UnauthorizedException(DetailedHTTPException):
    def __init__(self, detail: str = "Unauthorized", headers: dict[str, str] | None = None) -> None:
        super().__init__(status_code=401, detail=detail, headers=headers)


class ForbiddenException(DetailedHTTPException):
    def __init__(self, detail: str = "Forbidden", headers: dict[str, str] | None = None) -> None:
        super().__init__(status_code=403, detail=detail, headers=headers)


class NotFoundException(DetailedHTTPException):
    def __init__(self, detail: str = "Not found", headers: dict[str, str] | None = None) -> None:
        super().__init__(status_code=404, detail=detail, headers=headers)


class ConflictException(DetailedHTTPException):
    def __init__(self, detail: str = "Conflict", headers: dict[str, str] | None = None) -> None:
        super().__init__(status_code=409, detail=detail, headers=headers)
