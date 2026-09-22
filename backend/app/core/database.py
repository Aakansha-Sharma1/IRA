import logging
from typing import AsyncGenerator, Optional
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from sqlalchemy import text
from app.core.config import settings

logger = logging.getLogger("ira.database")

engine = create_async_engine(
    settings.DATABASE_URL,
    echo=False,
    future=True,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20,
)

AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False,
)

is_connected: bool = False


async def connect_to_database() -> bool:
    global is_connected
    try:
        async with engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
        is_connected = True
        logger.info("Connected to PostgreSQL successfully at %s", settings.DATABASE_URL)
        return True
    except Exception as e:
        is_connected = False
        logger.error(
            "\n" + "=" * 60 + "\n"
            "[IRA BACKEND] POSTGRESQL NOT CONNECTED!\n"
            f"Could not connect to PostgreSQL at: {settings.DATABASE_URL}\n"
            f"Error: {e}\n"
            "Please ensure PostgreSQL service is running and DATABASE_URL is correct.\n"
            + "=" * 60 + "\n"
        )
        return False


async def close_database_connection():
    global is_connected
    if engine:
        await engine.dispose()
        is_connected = False
        logger.info("PostgreSQL database connection pool closed.")


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        try:
            yield session
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
