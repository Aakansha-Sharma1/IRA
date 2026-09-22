from fastapi import HTTPException, status
from app.core.security import hash_password, verify_password, create_access_token
from app.repositories.user_repository import UserRepository
from app.schemas.auth import RegisterRequest, LoginRequest, AuthResponse, UserResponse


class AuthService:
    def __init__(self, user_repo: UserRepository):
        self.user_repo = user_repo

    async def register(self, req: RegisterRequest) -> AuthResponse:
        existing = await self.user_repo.get_by_email(req.email)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="An account with this email already exists."
            )

        hashed = hash_password(req.password)
        user = await self.user_repo.create_user(req.email, hashed)

        user_response = UserResponse(
            id=user.id,
            email=user.email,
            created_at=user.created_at,
            updated_at=user.updated_at
        )

        token = create_access_token(data={"sub": user.id, "email": user.email})

        return AuthResponse(
            access_token=token,
            token_type="bearer",
            user=user_response
        )

    async def login(self, req: LoginRequest) -> AuthResponse:
        user = await self.user_repo.get_by_email(req.email)
        if not user or not verify_password(req.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password."
            )

        user_response = UserResponse(
            id=user.id,
            email=user.email,
            created_at=user.created_at,
            updated_at=user.updated_at
        )

        token = create_access_token(data={"sub": user.id, "email": user.email})

        return AuthResponse(
            access_token=token,
            token_type="bearer",
            user=user_response
        )
