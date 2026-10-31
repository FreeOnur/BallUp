# syntax=docker/dockerfile:1

# ---- build: resolve dependencies and install the project into /app/.venv ----
FROM python:3.15-slim-trixie AS builder
COPY --from=ghcr.io/astral-sh/uv:0.12.24 /uv /uvx /bin/

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=0

WORKDIR /app

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project --no-dev

COPY pyproject.toml uv.lock ./
COPY src ./src
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-dev --no-editable

# ---- runtime: only the virtualenv, no build tools, non-root ----
FROM python:3.15-slim-trixie AS runtime

RUN groupadd --system --gid 10001 ballup \
 && useradd --system --uid 10001 --gid ballup --no-create-home --shell /usr/sbin/nologin ballup

COPY --from=builder --chown=ballup:ballup /app/.venv /app/.venv
COPY --chown=ballup:ballup alembic.ini /app/alembic.ini
COPY --chown=ballup:ballup migrations /app/migrations

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
USER ballup
EXPOSE 8000

CMD ["uvicorn", "ballup.main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers", "--forwarded-allow-ips", "*"]
