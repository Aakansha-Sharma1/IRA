import re
from typing import Sequence

from fastapi import HTTPException, status

from app.agents.prompts import IRA_SYSTEM_PROMPT, build_ira_system_prompt
from app.core.config import settings
from app.repositories.conversation_repository import ConversationRepository
from app.repositories.mood_repository import MoodRepository
from app.repositories.profile_repository import ProfileRepository
from app.schemas.conversation import (
    ConversationCreate,
    ConversationDetail,
    ConversationSummary,
    MessageResponse,
    SendMessageResponse,
)
from app.services.ai_service import AIService, AIServiceError, ChatTurn
from app.services.wellness_context_service import WellnessContextService

DEFAULT_TITLE = "New conversation"

SYSTEM_PROMPT = IRA_SYSTEM_PROMPT


class ConversationService:
    def __init__(
        self,
        conversation_repo: ConversationRepository,
        profile_repo: ProfileRepository,
        ai_service: AIService,
        mood_repo: MoodRepository | None = None,
    ):
        self.conversation_repo = conversation_repo
        self.profile_repo = profile_repo
        self.ai_service = ai_service
        self.mood_repo = mood_repo
        self.wellness_context_service = (
            WellnessContextService(mood_repo, profile_repo) if mood_repo is not None else None
        )

    async def create_conversation(self, user_id: str, req: ConversationCreate) -> ConversationSummary:
        title = (req.title or "").strip() or DEFAULT_TITLE
        conversation = await self.conversation_repo.create(user_id=user_id, title=title)
        return ConversationSummary.model_validate(conversation)

    async def list_conversations(self, user_id: str) -> list[ConversationSummary]:
        conversations = await self.conversation_repo.list_for_user(user_id)
        return [ConversationSummary.model_validate(item) for item in conversations]

    async def get_conversation(self, user_id: str, conversation_id: str) -> ConversationDetail:
        conversation = await self.conversation_repo.get_owned(user_id, conversation_id)
        if not conversation:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Conversation not found.",
            )
        messages = [
            MessageResponse.model_validate(message)
            for message in conversation.messages
        ]
        return ConversationDetail(
            id=conversation.id,
            title=conversation.title,
            created_at=conversation.created_at,
            updated_at=conversation.updated_at,
            messages=messages,
        )

    async def delete_conversation(self, user_id: str, conversation_id: str) -> None:
        deleted = await self.conversation_repo.delete_owned(user_id, conversation_id)
        if not deleted:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Conversation not found.",
            )

    async def send_message(
        self,
        user_id: str,
        conversation_id: str,
        content: str,
    ) -> SendMessageResponse:
        conversation = await self.conversation_repo.get_owned(user_id, conversation_id)
        if not conversation:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Conversation not found.",
            )

        trimmed = content.strip()
        if not trimmed:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
                detail="Message content cannot be empty.",
            )

        user_message = await self.conversation_repo.add_message(
            conversation, role="user", content=trimmed
        )

        if conversation.title == DEFAULT_TITLE:
            generated_title = _title_from_content(trimmed)
            if generated_title != DEFAULT_TITLE:
                await self.conversation_repo.update_title(conversation, generated_title)

        history_rows = await self.conversation_repo.list_recent_messages(
            conversation.id, limit=settings.IRA_CONTEXT_MESSAGES
        )
        history = [
            ChatTurn(role=row.role, content=row.content)
            for row in history_rows
            if row.role in ("user", "assistant")
        ]

        system_prompt = await self._build_system_prompt(user_id)

        try:
            assistant_text = await self.ai_service.generate_reply(
                system_prompt=system_prompt,
                history=history,
            )
        except AIServiceError as exc:
            raise HTTPException(status_code=exc.status_code, detail=exc.message) from exc
        except Exception as exc:
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail="The AI service failed unexpectedly.",
            ) from exc

        if not assistant_text or not assistant_text.strip():
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail="The AI provider did not generate a usable reply.",
            )

        assistant_message = await self.conversation_repo.add_message(
            conversation, role="assistant", content=assistant_text.strip()
        )

        return SendMessageResponse(
            user_message=MessageResponse.model_validate(user_message),
            assistant_message=MessageResponse.model_validate(assistant_message),
        )

    async def _build_system_prompt(self, user_id: str, wellness_context: str | None = None) -> str:
        profile = await self.profile_repo.get_by_user_id(user_id)
        resolved_context = wellness_context
        if resolved_context is None and self.wellness_context_service is not None:
            resolved_context = await self.wellness_context_service.build_for_user(user_id)
        return build_ira_system_prompt(
            profile=profile,
            wellness_context=resolved_context,
            limit=settings.IRA_CONTEXT_MESSAGES,
        )


def _title_from_content(content: str) -> str:
    cleaned = " ".join(content.split()).strip()
    if not cleaned:
        return DEFAULT_TITLE

    if len(cleaned) <= 50:
        return cleaned

    return cleaned[:50].rstrip()
