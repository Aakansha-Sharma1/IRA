from __future__ import annotations

from collections import Counter
from typing import Sequence

from app.repositories.mood_repository import MoodRepository
from app.repositories.profile_repository import ProfileRepository


class WellnessContextService:
    def __init__(
        self,
        mood_repo: MoodRepository,
        profile_repo: ProfileRepository | None = None,
    ):
        self.mood_repo = mood_repo
        self.profile_repo = profile_repo

    async def build_for_user(self, user_id: str) -> str | None:
        profile = await self.profile_repo.get_by_user_id(user_id) if self.profile_repo else None
        entries = await self.mood_repo.list_for_user(user_id)
        recent_entries = entries[:7]

        parts: list[str] = []

        if recent_entries:
            low_count = sum(
                1 for entry in recent_entries if entry.mood in {"very_low", "low"}
            )
            if low_count:
                parts.append(
                    f"Mood was low in {low_count} of the last {len(recent_entries)} check-ins."
                )

            intensity_values = [entry.intensity for entry in recent_entries]
            if intensity_values:
                avg_intensity = sum(intensity_values) / len(intensity_values)
                if avg_intensity <= 2.5:
                    parts.append("Energy and mood have been lower than usual recently.")
                elif avg_intensity >= 3.5:
                    parts.append("Recent check-ins suggest the user has been feeling relatively steady.")

        if profile and getattr(profile, "wellness_goals", None):
            goals = [goal.strip() for goal in profile.wellness_goals if str(goal).strip()]
            if goals:
                primary_goal = goals[0]
                parts.append(f"The user's wellness goal is {primary_goal}.")

        if profile and getattr(profile, "activity_level", None):
            parts.append(f"The user's activity preference is {profile.activity_level}.")

        if not parts:
            return None

        return "Recent wellness context:\n- " + "\n- ".join(parts)
