from typing import List, Optional
from fastapi import APIRouter, Depends, status

from app.core.dependencies import get_conversation_service, get_current_user
from app.schemas.auth import UserResponse
from app.schemas.conversation import (
    ConversationCreate,
    ConversationDetail,
    ConversationSummary,
    SendMessageRequest,
    SendMessageResponse,
)
from app.services.conversation_service import ConversationService

router = APIRouter(prefix="/conversations", tags=["Conversations"])


@router.post(
    "",
    response_model=ConversationSummary,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new conversation for the authenticated user",
)
async def create_conversation(
    req: Optional[ConversationCreate] = None,
    current_user: UserResponse = Depends(get_current_user),
    service: ConversationService = Depends(get_conversation_service),
) -> ConversationSummary:
    payload = req or ConversationCreate()
    return await service.create_conversation(current_user.id, payload)


@router.get(
    "",
    response_model=List[ConversationSummary],
    status_code=status.HTTP_200_OK,
    summary="List conversations owned by the authenticated user",
)
async def list_conversations(
    current_user: UserResponse = Depends(get_current_user),
    service: ConversationService = Depends(get_conversation_service),
) -> List[ConversationSummary]:
    return await service.list_conversations(current_user.id)


@router.get(
    "/{conversation_id}",
    response_model=ConversationDetail,
    status_code=status.HTTP_200_OK,
    summary="Get a conversation and its messages",
)
async def get_conversation(
    conversation_id: str,
    current_user: UserResponse = Depends(get_current_user),
    service: ConversationService = Depends(get_conversation_service),
) -> ConversationDetail:
    return await service.get_conversation(current_user.id, conversation_id)


@router.post(
    "/{conversation_id}/messages",
    response_model=SendMessageResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Send a user message and persist a real AI reply",
)
async def send_message(
    conversation_id: str,
    req: SendMessageRequest,
    current_user: UserResponse = Depends(get_current_user),
    service: ConversationService = Depends(get_conversation_service),
) -> SendMessageResponse:
    return await service.send_message(current_user.id, conversation_id, req.content)


@router.delete(
    "/{conversation_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete a conversation owned by the authenticated user",
)
async def delete_conversation(
    conversation_id: str,
    current_user: UserResponse = Depends(get_current_user),
    service: ConversationService = Depends(get_conversation_service),
) -> None:
    await service.delete_conversation(current_user.id, conversation_id)
