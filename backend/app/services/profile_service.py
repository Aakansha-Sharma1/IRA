from typing import Optional
from fastapi import HTTPException, status

from app.repositories.profile_repository import ProfileRepository
from app.schemas.profile import ProfileCreate, ProfileUpdate, ProfileResponse


class ProfileService:
    def __init__(self, profile_repo: ProfileRepository):
        self.profile_repo = profile_repo

    async def get_profile(self, user_id: str) -> ProfileResponse:
        profile = await self.profile_repo.get_by_user_id(user_id)
        if not profile:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Profile not found for this user."
            )
        return ProfileResponse.model_validate(profile)

    async def create_profile(self, user_id: str, req: ProfileCreate) -> ProfileResponse:
        existing = await self.profile_repo.get_by_user_id(user_id)
        if existing:
            # If already exists, update with new onboarding data
            update_data = req.model_dump(exclude_unset=True)
            updated = await self.profile_repo.update_profile(existing, update_data)
            return ProfileResponse.model_validate(updated)

        profile = await self.profile_repo.create_profile(
            user_id=user_id,
            display_name=req.display_name,
            age=req.age,
            gender=req.gender,
            timezone_str=req.timezone,
            wellness_goals=req.wellness_goals,
            sleep_hours_target=req.sleep_hours_target,
            activity_level=req.activity_level,
            onboarding_completed=req.onboarding_completed,
        )
        return ProfileResponse.model_validate(profile)

    async def update_profile(self, user_id: str, req: ProfileUpdate) -> ProfileResponse:
        profile = await self.profile_repo.get_by_user_id(user_id)
        if not profile:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Profile not found. Please complete onboarding first."
            )
        update_data = req.model_dump(exclude_unset=True)
        updated = await self.profile_repo.update_profile(profile, update_data)
        return ProfileResponse.model_validate(updated)
