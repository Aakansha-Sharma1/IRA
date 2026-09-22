import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.database import connect_to_database, close_database_connection, is_connected
from app.api.routes.auth import router as auth_router
from app.api.routes.profile import router as profile_router

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)
logger = logging.getLogger("ira.main")


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Initializing IRA Backend with PostgreSQL...")
    connected = await connect_to_database()
    if not connected:
        logger.warning(
            "\n" + "!" * 70 + "\n"
            "IRA Backend started with POSTGRESQL NOT CONNECTED!\n"
            f"Configured Database URL: {settings.DATABASE_URL}\n"
            "Auth and Profile endpoints will fail until PostgreSQL is reachable.\n"
            + "!" * 70
        )
    else:
        logger.info("PostgreSQL database connection established successfully.")
    yield
    await close_database_connection()
    logger.info("IRA Backend shutdown complete.")


app = FastAPI(
    title="IRA AI Backend",
    version="1.0.0",
    description="PostgreSQL-backed Authentication & Companion Backend for IRA AI",
    lifespan=lifespan,
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS if isinstance(settings.CORS_ORIGINS, list) else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# API v1 Routers
app.include_router(auth_router, prefix="/api/v1")
app.include_router(profile_router, prefix="/api/v1")


@app.get("/health", tags=["System"])
@app.get("/api/v1/health", tags=["System"])
async def health_check():
    from app.core import database
    return {
        "status": "healthy" if database.is_connected else "degraded",
        "database": "connected" if database.is_connected else "disconnected",
        "engine": "postgresql",
        "environment": settings.ENVIRONMENT,
        "database_url": settings.DATABASE_URL.split("@")[-1] if "@" in settings.DATABASE_URL else settings.DATABASE_URL,
    }
