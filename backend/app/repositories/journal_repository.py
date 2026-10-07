from datetime import datetime, timezone
import uuid
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.journal_entry import JournalEntry


class JournalRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def list_for_user(self, user_id: str) -> list[JournalEntry]:
        result = await self.session.execute(
            select(JournalEntry).where(JournalEntry.user_id == user_id).order_by(JournalEntry.updated_at.desc())
        )
        return list(result.scalars().all())

    async def get_owned(self, user_id: str, entry_id: str) -> JournalEntry | None:
        result = await self.session.execute(
            select(JournalEntry).where(JournalEntry.id == entry_id, JournalEntry.user_id == user_id)
        )
        return result.scalar_one_or_none()

    async def create(self, user_id: str, title: str, content: str, mood: str | None) -> JournalEntry:
        now = datetime.now(timezone.utc)
        item = JournalEntry(id=str(uuid.uuid4()), user_id=user_id, title=title.strip(), content=content, mood=mood, created_at=now, updated_at=now)
        self.session.add(item)
        await self.session.commit()
        await self.session.refresh(item)
        return item

    async def update(self, item: JournalEntry, **fields) -> JournalEntry:
        for key, value in fields.items():
            if value is not None or key == "mood":
                setattr(item, key, value.strip() if isinstance(value, str) else value)
        item.updated_at = datetime.now(timezone.utc)
        await self.session.commit()
        await self.session.refresh(item)
        return item

    async def delete(self, item: JournalEntry) -> None:
        await self.session.delete(item)
        await self.session.commit()
