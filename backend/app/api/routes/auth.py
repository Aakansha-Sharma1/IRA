from fastapi import APIRouter, Depends, status
from app.core.dependencies import get_auth_service, get_current_user
from app.services.auth_service import AuthService
from app.schemas.auth import RegisterRequest, LoginRequest, AuthResponse, UserResponse

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post(
    "/register",
    response_model=AuthResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new user account"
)
async def register(
    req: RegisterRequest,
    auth_service: AuthService = Depends(get_auth_service)
) -> AuthResponse:
    return await auth_service.register(req)


@router.post(
    "/login",
    response_model=AuthResponse,
    status_code=status.HTTP_200_OK,
    summary="Authenticate existing user"
)
async def login(
    req: LoginRequest,
    auth_service: AuthService = Depends(get_auth_service)
) -> AuthResponse:
    return await auth_service.login(req)


@router.get(
    "/me",
    response_model=UserResponse,
    status_code=status.HTTP_200_OK,
    summary="Get current authenticated user profile"
)
async def get_me(
    current_user: UserResponse = Depends(get_current_user)
) -> UserResponse:
    return current_user


@router.post(
    "/logout",
    status_code=status.HTTP_200_OK,
    summary="Log out user and invalidate client session"
)
async def logout():
    # Stateless JWT: client clears token from secure storage.
    return {"message": "Successfully logged out"}
