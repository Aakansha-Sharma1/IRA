from datetime import datetime, timezone
import uuid
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.todo_item import TodoItem


class TodoRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def list_for_user(self, user_id: str) -> list[TodoItem]:
        result = await self.session.execute(
            select(TodoItem).where(TodoItem.user_id == user_id).order_by(TodoItem.is_completed, TodoItem.due_date, TodoItem.created_at.desc())
        )
        return list(result.scalars().all())

    async def get_owned(self, user_id: str, item_id: str) -> TodoItem | None:
        result = await self.session.execute(
            select(TodoItem).where(TodoItem.id == item_id, TodoItem.user_id == user_id)
        )
        return result.scalar_one_or_none()

    async def create(self, user_id: str, **fields) -> TodoItem:
        now = datetime.now(timezone.utc)
        item = TodoItem(id=str(uuid.uuid4()), user_id=user_id, created_at=now, updated_at=now, **fields)
        self.session.add(item)
        await self.session.commit()
        await self.session.refresh(item)
        return item

    async def update(self, item: TodoItem, **fields) -> TodoItem:
        for key, value in fields.items():
            if value is not None or key in {"description", "due_date"}:
                setattr(item, key, value.strip() if isinstance(value, str) else value)
        item.updated_at = datetime.now(timezone.utc)
        await self.session.commit()
        await self.session.refresh(item)
        return item

    async def delete(self, item: TodoItem) -> None:
        await self.session.delete(item)
        await self.session.commit()
