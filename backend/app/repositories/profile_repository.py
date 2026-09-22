import uuid
from datetime import datetime, timezone
from typing import Optional, List, Dict, Any
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.profile import Profile


class ProfileRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_user_id(self, user_id: str) -> Optional[Profile]:
        stmt = select(Profile).where(Profile.user_id == user_id)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def create_profile(
        self,
        user_id: str,
        display_name: str,
        age: Optional[int] = None,
        gender: Optional[str] = None,
        timezone_str: str = "UTC",
        wellness_goals: Optional[List[str]] = None,
        sleep_hours_target: Optional[float] = 8.0,
        activity_level: Optional[str] = "moderate",
        onboarding_completed: bool = True,
    ) -> Profile:
        now = datetime.now(timezone.utc)
        profile = Profile(
            id=str(uuid.uuid4()),
            user_id=user_id,
            display_name=display_name.strip(),
            age=age,
            gender=gender.strip() if gender else None,
            timezone=timezone_str.strip() if timezone_str else "UTC",
            wellness_goals=wellness_goals or [],
            sleep_hours_target=sleep_hours_target,
            activity_level=activity_level,
            onboarding_completed=onboarding_completed,
            created_at=now,
            updated_at=now,
        )
        self.session.add(profile)
        await self.session.commit()
        await self.session.refresh(profile)
        return profile

    async def update_profile(
        self,
        profile: Profile,
        update_data: Dict[str, Any],
    ) -> Profile:
        now = datetime.now(timezone.utc)
        for field, value in update_data.items():
            if hasattr(profile, field) and field not in ("id", "user_id", "created_at"):
                setattr(profile, field, value)
        profile.updated_at = now
        await self.session.commit()
        await self.session.refresh(profile)
        return profile
