"""
Safe Migration Script: MongoDB -> PostgreSQL
Transfers user accounts from MongoDB 'ira_ai.users' into PostgreSQL 'users' table.
Preserves user IDs, email, bcrypt password hashes, and timestamps.
"""
import asyncio
from datetime import datetime, timezone
import logging
from pymongo import MongoClient
import asyncpg

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("mongo_to_postgres")

MONGO_URL = "mongodb://localhost:27017"
MONGO_DB = "ira_ai"
PG_DSN = "postgresql://postgres@127.0.0.1:5432/ira_db"


async def migrate():
    logger.info("Connecting to MongoDB at %s...", MONGO_URL)
    mongo_client = MongoClient(MONGO_URL, serverSelectionTimeoutMS=3000)
    mongo_db = mongo_client[MONGO_DB]
    mongo_users = list(mongo_db["users"].find())
    logger.info("Discovered %d user(s) in MongoDB '%s.users'", len(mongo_users), MONGO_DB)

    if not mongo_users:
        logger.info("No MongoDB users found to migrate.")
        return

    logger.info("Connecting to PostgreSQL at %s...", PG_DSN)
    pg_conn = await asyncpg.connect(PG_DSN)

    migrated_count = 0
    skipped_count = 0

    try:
        for u in mongo_users:
            user_id = str(u.get("id") or u["_id"])
            email = str(u.get("email", "")).lower().strip()
            password_hash = str(u.get("password_hash", ""))
            created_at = u.get("created_at") or datetime.now(timezone.utc)
            updated_at = u.get("updated_at") or created_at

            # Ensure timezone-aware datetime for PostgreSQL
            if created_at.tzinfo is None:
                created_at = created_at.replace(tzinfo=timezone.utc)
            if updated_at.tzinfo is None:
                updated_at = updated_at.replace(tzinfo=timezone.utc)

            # Check if user already exists in PostgreSQL
            existing = await pg_conn.fetchrow(
                "SELECT id, email FROM users WHERE email = $1 OR id = $2",
                email, user_id
            )
            if existing:
                logger.info("User '%s' (id=%s) already exists in PostgreSQL. Skipping.", email, user_id)
                skipped_count += 1
                continue

            await pg_conn.execute(
                """
                INSERT INTO users (id, email, password_hash, created_at, updated_at)
                VALUES ($1, $2, $3, $4, $5)
                """,
                user_id, email, password_hash, created_at, updated_at
            )
            logger.info("Migrated user '%s' (id=%s) to PostgreSQL successfully.", email, user_id)
            migrated_count += 1

        logger.info("Migration finished: %d migrated, %d skipped, %d total.", migrated_count, skipped_count, len(mongo_users))
    finally:
        await pg_conn.close()
        mongo_client.close()


if __name__ == "__main__":
    asyncio.run(migrate())
