from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field


class ProfileCreate(BaseModel):
    display_name: str = Field(..., min_length=1, max_length=100, description="User's preferred name or pseudonym")
    companion_name: str = Field("IRA", min_length=1, max_length=100, description="The name of the user's AI companion")
    age: Optional[int] = Field(None, ge=13, le=120, description="Age between 13 and 120")
    gender: Optional[str] = Field(None, max_length=50)
    pronouns: str = Field("she/her", min_length=1, max_length=50, description="The user's pronouns")
    timezone: str = Field("UTC", max_length=100)
    wellness_goals: List[str] = Field(default_factory=list, description="Primary wellness goals")
    sleep_hours_target: Optional[float] = Field(8.0, ge=3.0, le=16.0, description="Target sleep hours (3-16)")
    activity_level: Optional[str] = Field("moderate", max_length=50)
    onboarding_completed: bool = Field(True, description="Whether onboarding has been completed")


class ProfileUpdate(BaseModel):
    display_name: Optional[str] = Field(None, min_length=1, max_length=100)
    companion_name: Optional[str] = Field(None, min_length=1, max_length=100)
    age: Optional[int] = Field(None, ge=13, le=120)
    gender: Optional[str] = Field(None, max_length=50)
    pronouns: Optional[str] = Field(None, min_length=1, max_length=50)
    timezone: Optional[str] = Field(None, max_length=100)
    wellness_goals: Optional[List[str]] = None
    sleep_hours_target: Optional[float] = Field(None, ge=3.0, le=16.0)
    activity_level: Optional[str] = Field(None, max_length=50)
    onboarding_completed: Optional[bool] = None


class ProfileResponse(BaseModel):
    id: str
    user_id: str
    display_name: str
    companion_name: str
    age: Optional[int] = None
    gender: Optional[str] = None
    pronouns: str
    timezone: str
    wellness_goals: List[str]
    sleep_hours_target: Optional[float] = None
    activity_level: Optional[str] = None
    onboarding_completed: bool
    created_at: datetime
    updated_at: datetime

    model_config = {
        "from_attributes": True,
        "populate_by_name": True,
    }
