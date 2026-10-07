from fastapi import APIRouter, Depends, Response, status
from app.core.dependencies import get_current_user
from app.core.database import get_db
from app.schemas.auth import UserResponse
from app.schemas.journal import JournalEntryCreate, JournalEntryResponse, JournalEntryUpdate
from app.repositories.journal_repository import JournalRepository
from app.services.journal_service import JournalService
from sqlalchemy.ext.asyncio import AsyncSession

router = APIRouter(prefix="/journal", tags=["Journal"])


def get_service(session: AsyncSession = Depends(get_db)) -> JournalService:
    return JournalService(JournalRepository(session))


@router.get("", response_model=list[JournalEntryResponse])
async def list_entries(current_user: UserResponse = Depends(get_current_user), service: JournalService = Depends(get_service)):
    return await service.list(current_user.id)


@router.post("", response_model=JournalEntryResponse, status_code=status.HTTP_201_CREATED)
async def create_entry(request: JournalEntryCreate, current_user: UserResponse = Depends(get_current_user), service: JournalService = Depends(get_service)):
    return await service.create(current_user.id, request)


@router.get("/{entry_id}", response_model=JournalEntryResponse)
async def get_entry(entry_id: str, current_user: UserResponse = Depends(get_current_user), service: JournalService = Depends(get_service)):
    return await service.get(current_user.id, entry_id)


@router.put("/{entry_id}", response_model=JournalEntryResponse)
async def update_entry(entry_id: str, request: JournalEntryUpdate, current_user: UserResponse = Depends(get_current_user), service: JournalService = Depends(get_service)):
    return await service.update(current_user.id, entry_id, request)


@router.delete("/{entry_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_entry(entry_id: str, current_user: UserResponse = Depends(get_current_user), service: JournalService = Depends(get_service)):
    await service.delete(current_user.id, entry_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
