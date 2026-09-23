from fastapi import HTTPException, status

from app.repositories.conversation_repository import ConversationRepository, MAX_CONTEXT_MESSAGES
from app.repositories.profile_repository import ProfileRepository
from app.schemas.conversation import (
    ConversationCreate,
    ConversationDetail,
    ConversationSummary,
    MessageResponse,
    SendMessageResponse,
)
from app.services.ai_service import AIService, AIServiceError, ChatTurn

DEFAULT_TITLE = "New conversation"

SYSTEM_PROMPT = (
    "You are IRA, a preventive wellness companion. "
    "Offer supportive, practical, non-clinical conversation about everyday wellbeing. "
    "Do not diagnose diseases, prescribe medication, or claim to be a medical professional. "
    "If the user describes a medical emergency, encourage them to seek appropriate professional help. "
    "Keep replies concise, warm, and grounded in what the user shares."
)


class ConversationService:
    def __init__(
        self,
        conversation_repo: ConversationRepository,
        profile_repo: ProfileRepository,
        ai_service: AIService,
    ):
        self.conversation_repo = conversation_repo
        self.profile_repo = profile_repo
        self.ai_service = ai_service

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
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Message content cannot be empty.",
            )

        user_message = await self.conversation_repo.add_message(
            conversation, role="user", content=trimmed
        )

        if conversation.title == DEFAULT_TITLE:
            await self.conversation_repo.update_title(
                conversation, _title_from_content(trimmed)
            )

        history_rows = await self.conversation_repo.list_recent_messages(
            conversation.id, limit=MAX_CONTEXT_MESSAGES
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

    async def _build_system_prompt(self, user_id: str) -> str:
        profile = await self.profile_repo.get_by_user_id(user_id)
        if not profile:
            return SYSTEM_PROMPT

        goals = ", ".join(profile.wellness_goals) if profile.wellness_goals else "not specified"
        activity = profile.activity_level or "not specified"
        timezone_value = profile.timezone or "UTC"
        display_name = profile.display_name or "friend"

        context = (
            f"{SYSTEM_PROMPT}\n\n"
            "Known companion context provided by the user during onboarding:\n"
            f"- Preferred name: {display_name}\n"
            f"- Timezone: {timezone_value}\n"
            f"- Wellness focus: {goals}\n"
            f"- Activity preference: {activity}\n"
            "Use this only as light personalization. Do not invent medical history."
        )
        return context


def _title_from_content(content: str) -> str:
    cleaned = " ".join(content.split())
    if not cleaned:
        return DEFAULT_TITLE
    if len(cleaned) <= 48:
        return cleaned
    return cleaned[:45].rstrip() + "..."
