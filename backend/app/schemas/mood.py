from datetime import date, datetime
from typing import Literal, Optional

from pydantic import BaseModel, Field

MoodValue = Literal["very_low", "low", "neutral", "good", "very_good"]


class MoodEntryCreate(BaseModel):
    mood: MoodValue = Field(..., description="A single daily mood value.")
    intensity: int = Field(..., ge=1, le=5, description="Mood intensity from 1 to 5.")
    note: Optional[str] = Field(
        default=None,
        max_length=280,
        description="Optional short note about the day's context.",
    )
    entry_date: date = Field(..., description="The date for this mood check-in.")


class MoodEntryUpdate(BaseModel):
    mood: Optional[MoodValue] = Field(None, description="Updated mood value.")
    intensity: Optional[int] = Field(None, ge=1, le=5, description="Updated intensity from 1 to 5.")
    note: Optional[str] = Field(None, max_length=280, description="Optional note update.")
    entry_date: Optional[date] = Field(None, description="Updated check-in date.")


class MoodEntryResponse(BaseModel):
    id: str
    user_id: str
    mood: str
    intensity: int
    note: Optional[str] = None
    entry_date: date
    created_at: datetime
    updated_at: datetime

    model_config = {
        "from_attributes": True,
        "populate_by_name": True,
    }
