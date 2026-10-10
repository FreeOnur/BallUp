from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="BallUp API")


class HealthOut(BaseModel):
    status: str


@app.get("/health", response_model=HealthOut, tags=["system"])
async def health() -> HealthOut:
    """Liveness check for Docker, the deploy script and Uptime Kuma."""
    return HealthOut(status="ok")
