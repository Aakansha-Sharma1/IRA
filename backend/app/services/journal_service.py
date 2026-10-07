from fastapi import HTTPException, status
from app.repositories.journal_repository import JournalRepository
from app.schemas.journal import JournalEntryCreate, JournalEntryResponse, JournalEntryUpdate


class JournalService:
    def __init__(self, repository: JournalRepository):
        self.repository = repository

    async def list(self, user_id: str):
        return [JournalEntryResponse.model_validate(x) for x in await self.repository.list_for_user(user_id)]

    async def get(self, user_id: str, entry_id: str):
        item = await self.repository.get_owned(user_id, entry_id)
        if not item:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Journal entry not found.")
        return JournalEntryResponse.model_validate(item)

    async def create(self, user_id: str, request: JournalEntryCreate):
        return JournalEntryResponse.model_validate(await self.repository.create(user_id, request.title, request.content, request.mood))

    async def update(self, user_id: str, entry_id: str, request: JournalEntryUpdate):
        item = await self.repository.get_owned(user_id, entry_id)
        if not item:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Journal entry not found.")
        return JournalEntryResponse.model_validate(await self.repository.update(item, **request.model_dump(exclude_unset=True)))

    async def delete(self, user_id: str, entry_id: str):
        item = await self.repository.get_owned(user_id, entry_id)
        if not item:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Journal entry not found.")
        await self.repository.delete(item)
