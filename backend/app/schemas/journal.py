from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


class JournalEntryCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    content: str = Field(..., min_length=1)
    mood: Optional[str] = Field(None, max_length=20)


class JournalEntryUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    content: Optional[str] = Field(None, min_length=1)
    mood: Optional[str] = Field(None, max_length=20)


class JournalEntryResponse(BaseModel):
    id: str
    user_id: str
    title: str
    content: str
    mood: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
