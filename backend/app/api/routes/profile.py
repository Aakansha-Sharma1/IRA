from fastapi import APIRouter, Depends, status
from app.core.dependencies import get_current_user, get_profile_service
from app.services.profile_service import ProfileService
from app.schemas.auth import UserResponse
from app.schemas.profile import ProfileCreate, ProfileUpdate, ProfileResponse

router = APIRouter(prefix="/profile", tags=["User Profile"])


@router.get(
    "",
    response_model=ProfileResponse,
    status_code=status.HTTP_200_OK,
    summary="Get current user profile"
)
async def get_profile(
    current_user: UserResponse = Depends(get_current_user),
    profile_service: ProfileService = Depends(get_profile_service),
) -> ProfileResponse:
    """Retrieve profile for the authenticated user. User ID is extracted strictly from JWT."""
    return await profile_service.get_profile(current_user.id)


@router.post(
    "",
    response_model=ProfileResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create or initialize user profile (Onboarding)"
)
async def create_profile(
    req: ProfileCreate,
    current_user: UserResponse = Depends(get_current_user),
    profile_service: ProfileService = Depends(get_profile_service),
) -> ProfileResponse:
    """Persist user profile collected during onboarding. Bound securely to JWT authenticated identity."""
    return await profile_service.create_profile(current_user.id, req)


@router.put(
    "",
    response_model=ProfileResponse,
    status_code=status.HTTP_200_OK,
    summary="Update user profile"
)
async def update_profile(
    req: ProfileUpdate,
    current_user: UserResponse = Depends(get_current_user),
    profile_service: ProfileService = Depends(get_profile_service),
) -> ProfileResponse:
    """Update profile fields for the authenticated user. User ID is extracted strictly from JWT."""
    return await profile_service.update_profile(current_user.id, req)
