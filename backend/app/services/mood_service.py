from datetime import date

from fastapi import HTTPException, status

from app.repositories.mood_repository import MoodRepository
from app.schemas.mood import MoodEntryCreate, MoodEntryResponse, MoodEntryUpdate


class MoodService:
    def __init__(self, mood_repo: MoodRepository):
        self.mood_repo = mood_repo

    async def create_mood(self, user_id: str, req: MoodEntryCreate) -> MoodEntryResponse:
        existing = await self.mood_repo.get_by_user_and_date(user_id, req.entry_date)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="A mood check-in already exists for this date.",
            )

        mood_entry = await self.mood_repo.create(
            user_id=user_id,
            mood=req.mood,
            intensity=req.intensity,
            note=req.note,
            entry_date=req.entry_date,
        )
        return MoodEntryResponse.model_validate(mood_entry)

    async def list_moods(self, user_id: str) -> list[MoodEntryResponse]:
        moods = await self.mood_repo.list_for_user(user_id)
        return [MoodEntryResponse.model_validate(item) for item in moods]

    async def get_mood(self, user_id: str, mood_id: str) -> MoodEntryResponse:
        mood_entry = await self.mood_repo.get_owned(user_id, mood_id)
        if not mood_entry:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Mood entry not found.",
            )
        return MoodEntryResponse.model_validate(mood_entry)

    async def update_mood(self, user_id: str, mood_id: str, req: MoodEntryUpdate) -> MoodEntryResponse:
        mood_entry = await self.mood_repo.get_owned(user_id, mood_id)
        if not mood_entry:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Mood entry not found.",
            )

        payload = req.model_dump(exclude_unset=True)
        if "entry_date" in payload:
            existing = await self.mood_repo.get_by_user_and_date(user_id, payload["entry_date"])
            if existing and existing.id != mood_id:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="A mood check-in already exists for this date.",
                )

        updated = await self.mood_repo.update(mood_entry, **payload)
        return MoodEntryResponse.model_validate(updated)

    async def get_today_mood(self, user_id: str, entry_date: date) -> MoodEntryResponse | None:
        mood_entry = await self.mood_repo.get_by_user_and_date(user_id, entry_date)
        if not mood_entry:
            return None
        return MoodEntryResponse.model_validate(mood_entry)
