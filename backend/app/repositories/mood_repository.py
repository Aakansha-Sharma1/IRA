import uuid
from datetime import date, datetime, timezone
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.mood_entry import MoodEntry


class MoodRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def list_for_user(self, user_id: str) -> list[MoodEntry]:
        stmt = (
            select(MoodEntry)
            .where(MoodEntry.user_id == user_id)
            .order_by(MoodEntry.entry_date.desc(), MoodEntry.created_at.desc())
        )
        result = await self.session.execute(stmt)
        return list(result.scalars().all())

    async def get_owned(self, user_id: str, mood_id: str) -> Optional[MoodEntry]:
        stmt = select(MoodEntry).where(
            MoodEntry.id == mood_id,
            MoodEntry.user_id == user_id,
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def get_by_user_and_date(self, user_id: str, entry_date: date) -> Optional[MoodEntry]:
        stmt = select(MoodEntry).where(
            MoodEntry.user_id == user_id,
            MoodEntry.entry_date == entry_date,
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def create(self, user_id: str, mood: str, intensity: int, note: Optional[str], entry_date: date) -> MoodEntry:
        now = datetime.now(timezone.utc)
        item = MoodEntry(
            id=str(uuid.uuid4()),
            user_id=user_id,
            mood=mood,
            intensity=intensity,
            note=note.strip() if note is not None else None,
            entry_date=entry_date,
            created_at=now,
            updated_at=now,
        )
        self.session.add(item)
        await self.session.commit()
        await self.session.refresh(item)
        return item

    async def update(self, mood_entry: MoodEntry, **fields) -> MoodEntry:
        for key, value in fields.items():
            if key in {"id", "user_id", "created_at"}:
                continue
            if key == "note" and value is not None:
                setattr(mood_entry, key, value.strip())
            else:
                setattr(mood_entry, key, value)
        mood_entry.updated_at = datetime.now(timezone.utc)
        await self.session.commit()
        await self.session.refresh(mood_entry)
        return mood_entry
