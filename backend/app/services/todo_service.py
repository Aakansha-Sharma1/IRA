from fastapi import HTTPException, status
from app.repositories.todo_repository import TodoRepository
from app.schemas.todo import TodoCreate, TodoResponse, TodoUpdate


class TodoService:
    def __init__(self, repository: TodoRepository):
        self.repository = repository

    async def list(self, user_id: str):
        return [TodoResponse.model_validate(x) for x in await self.repository.list_for_user(user_id)]

    async def get(self, user_id: str, item_id: str):
        item = await self.repository.get_owned(user_id, item_id)
        if not item:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Todo not found.")
        return TodoResponse.model_validate(item)

    async def create(self, user_id: str, request: TodoCreate):
        return TodoResponse.model_validate(await self.repository.create(user_id, **request.model_dump()))

    async def update(self, user_id: str, item_id: str, request: TodoUpdate):
        item = await self.repository.get_owned(user_id, item_id)
        if not item:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Todo not found.")
        return TodoResponse.model_validate(await self.repository.update(item, **request.model_dump(exclude_unset=True)))

    async def delete(self, user_id: str, item_id: str):
        item = await self.repository.get_owned(user_id, item_id)
        if not item:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Todo not found.")
        await self.repository.delete(item)
