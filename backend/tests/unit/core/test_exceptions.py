from ballup.exceptions import (
    BadRequestException,
    ConflictException,
    ForbiddenException,
    NotFoundException,
    UnauthorizedException,
)


def test_exception_status_codes() -> None:
    assert BadRequestException().status_code == 400
    assert UnauthorizedException().status_code == 401
    assert ForbiddenException().status_code == 403
    assert NotFoundException().status_code == 404
    assert ConflictException().status_code == 409


def test_exception_detail_can_be_replaced() -> None:
    error = NotFoundException(detail="Court not found")

    assert error.detail == "Court not found"
