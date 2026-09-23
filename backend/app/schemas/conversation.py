from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field


class ConversationCreate(BaseModel):
    title: Optional[str] = Field(None, max_length=200)


class ConversationSummary(BaseModel):
    id: str
    title: str
    created_at: datetime
    updated_at: datetime

    model_config = {
        "from_attributes": True,
        "populate_by_name": True,
    }


class MessageResponse(BaseModel):
    id: str
    conversation_id: str
    role: str
    content: str
    created_at: datetime

    model_config = {
        "from_attributes": True,
        "populate_by_name": True,
    }


class ConversationDetail(ConversationSummary):
    messages: List[MessageResponse] = Field(default_factory=list)


class SendMessageRequest(BaseModel):
    content: str = Field(..., min_length=1, max_length=4000)


class SendMessageResponse(BaseModel):
    user_message: MessageResponse
    assistant_message: MessageResponse
