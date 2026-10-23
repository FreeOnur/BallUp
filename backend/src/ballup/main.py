from fastapi import FastAPI
from pydantic import BaseModel

from ballup.core.config import get_settings


class HealthOut(BaseModel):
    status: str


def create_app() -> FastAPI:
    settings = get_settings()
    docs_enabled = settings.env != "production"
    app = FastAPI(
        title="BallUp API",
        docs_url="/docs" if docs_enabled else None,
        redoc_url="/redoc" if docs_enabled else None,
        openapi_url="/openapi.json" if docs_enabled else None,
    )

    @app.get("/health", response_model=HealthOut, tags=["system"])
    async def health() -> HealthOut:
        """Liveness check for Docker, the deploy script and Uptime Kuma."""
        return HealthOut(status="ok")

    return app


app = create_app()
