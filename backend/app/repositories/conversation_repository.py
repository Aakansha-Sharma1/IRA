import uuid
from datetime import datetime, timezone
from typing import List, Optional
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.conversation import Conversation
from app.models.message import Message

MAX_CONTEXT_MESSAGES = 20


class ConversationRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create(self, user_id: str, title: str) -> Conversation:
        now = datetime.now(timezone.utc)
        conversation = Conversation(
            id=str(uuid.uuid4()),
            user_id=user_id,
            title=title,
            created_at=now,
            updated_at=now,
        )
        self.session.add(conversation)
        await self.session.commit()
        await self.session.refresh(conversation)
        return conversation

    async def list_for_user(self, user_id: str) -> List[Conversation]:
        stmt = (
            select(Conversation)
            .where(Conversation.user_id == user_id)
            .order_by(Conversation.updated_at.desc())
        )
        result = await self.session.execute(stmt)
        return list(result.scalars().all())

    async def get_owned(self, user_id: str, conversation_id: str) -> Optional[Conversation]:
        stmt = (
            select(Conversation)
            .options(selectinload(Conversation.messages))
            .where(
                Conversation.id == conversation_id,
                Conversation.user_id == user_id,
            )
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def delete_owned(self, user_id: str, conversation_id: str) -> bool:
        conversation = await self.get_owned(user_id, conversation_id)
        if not conversation:
            return False
        await self.session.delete(conversation)
        await self.session.commit()
        return True

    async def add_message(
        self,
        conversation: Conversation,
        role: str,
        content: str,
    ) -> Message:
        now = datetime.now(timezone.utc)
        message = Message(
            id=str(uuid.uuid4()),
            conversation_id=conversation.id,
            role=role,
            content=content,
            created_at=now,
        )
        conversation.updated_at = now
        self.session.add(message)
        await self.session.commit()
        await self.session.refresh(message)
        await self.session.refresh(conversation)
        return message

    async def list_recent_messages(
        self,
        conversation_id: str,
        limit: int = MAX_CONTEXT_MESSAGES,
    ) -> List[Message]:
        stmt = (
            select(Message)
            .where(Message.conversation_id == conversation_id)
            .order_by(Message.created_at.desc())
            .limit(limit)
        )
        result = await self.session.execute(stmt)
        messages = list(result.scalars().all())
        messages.reverse()
        return messages

    async def update_title(self, conversation: Conversation, title: str) -> Conversation:
        conversation.title = title
        conversation.updated_at = datetime.now(timezone.utc)
        await self.session.commit()
        await self.session.refresh(conversation)
        return conversation
