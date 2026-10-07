from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.repositories.todo_repository import TodoRepository
from app.schemas.auth import UserResponse
from app.schemas.todo import TodoCreate, TodoResponse, TodoUpdate
from app.services.todo_service import TodoService

router = APIRouter(prefix="/todos", tags=["Todo"])


def get_service(session: AsyncSession = Depends(get_db)) -> TodoService:
    return TodoService(TodoRepository(session))


@router.get("", response_model=list[TodoResponse])
async def list_todos(current_user: UserResponse = Depends(get_current_user), service: TodoService = Depends(get_service)):
    return await service.list(current_user.id)


@router.post("", response_model=TodoResponse, status_code=status.HTTP_201_CREATED)
async def create_todo(request: TodoCreate, current_user: UserResponse = Depends(get_current_user), service: TodoService = Depends(get_service)):
    return await service.create(current_user.id, request)


@router.get("/{item_id}", response_model=TodoResponse)
async def get_todo(item_id: str, current_user: UserResponse = Depends(get_current_user), service: TodoService = Depends(get_service)):
    return await service.get(current_user.id, item_id)


@router.put("/{item_id}", response_model=TodoResponse)
async def update_todo(item_id: str, request: TodoUpdate, current_user: UserResponse = Depends(get_current_user), service: TodoService = Depends(get_service)):
    return await service.update(current_user.id, item_id, request)


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_todo(item_id: str, current_user: UserResponse = Depends(get_current_user), service: TodoService = Depends(get_service)):
    await service.delete(current_user.id, item_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
