from typing import List

from fastapi import APIRouter, Depends, status

from app.core.dependencies import get_current_user, get_mood_service
from app.schemas.auth import UserResponse
from app.schemas.mood import MoodEntryCreate, MoodEntryResponse, MoodEntryUpdate
from app.services.mood_service import MoodService

router = APIRouter(prefix="/moods", tags=["Mood Tracking"])


@router.post(
    "",
    response_model=MoodEntryResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create a mood check-in for the authenticated user",
)
async def create_mood(
    req: MoodEntryCreate,
    current_user: UserResponse = Depends(get_current_user),
    service: MoodService = Depends(get_mood_service),
) -> MoodEntryResponse:
    return await service.create_mood(current_user.id, req)


@router.get(
    "",
    response_model=List[MoodEntryResponse],
    status_code=status.HTTP_200_OK,
    summary="List mood entries for the authenticated user",
)
async def list_moods(
    current_user: UserResponse = Depends(get_current_user),
    service: MoodService = Depends(get_mood_service),
) -> List[MoodEntryResponse]:
    return await service.list_moods(current_user.id)


@router.get(
    "/{mood_id}",
    response_model=MoodEntryResponse,
    status_code=status.HTTP_200_OK,
    summary="Get a single mood entry owned by the authenticated user",
)
async def get_mood(
    mood_id: str,
    current_user: UserResponse = Depends(get_current_user),
    service: MoodService = Depends(get_mood_service),
) -> MoodEntryResponse:
    return await service.get_mood(current_user.id, mood_id)


@router.put(
    "/{mood_id}",
    response_model=MoodEntryResponse,
    status_code=status.HTTP_200_OK,
    summary="Update an owned mood check-in",
)
async def update_mood(
    mood_id: str,
    req: MoodEntryUpdate,
    current_user: UserResponse = Depends(get_current_user),
    service: MoodService = Depends(get_mood_service),
) -> MoodEntryResponse:
    return await service.update_mood(current_user.id, mood_id, req)
