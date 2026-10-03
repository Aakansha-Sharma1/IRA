from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException, status
from livekit import api

from app.core.config import settings
from app.core.dependencies import get_current_user
from app.schemas.auth import UserResponse

router = APIRouter(prefix="/voice", tags=["Voice"])


@router.post("/session", status_code=status.HTTP_200_OK)
async def create_voice_session(
    current_user: UserResponse = Depends(get_current_user),
) -> dict[str, str]:
    if not all(
        (settings.LIVEKIT_URL, settings.LIVEKIT_API_KEY, settings.LIVEKIT_API_SECRET)
    ):
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="LiveKit voice service is not configured.",
        )

    room_name = f"ira-voice-{uuid4().hex}"
    participant_identity = f"{current_user.id}-{uuid4().hex}"
    token = (
        api.AccessToken(
            api_key=settings.LIVEKIT_API_KEY,
            api_secret=settings.LIVEKIT_API_SECRET,
        )
        .with_identity(participant_identity)
        .with_name(current_user.email)
        .with_grants(
            api.VideoGrants(
                room_join=True,
                room=room_name,
                can_publish=True,
                can_subscribe=True,
            )
        )
    )

    livekit_api = api.LiveKitAPI(
        url=settings.LIVEKIT_URL,
        api_key=settings.LIVEKIT_API_KEY,
        api_secret=settings.LIVEKIT_API_SECRET,
    )
    try:
        await livekit_api.agent_dispatch.create_dispatch(
            api.CreateAgentDispatchRequest(
                agent_name="ira-voice-agent",
                room=room_name,
            )
        )
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="LiveKit voice dispatch could not be created.",
        ) from exc
    finally:
        await livekit_api.aclose()

    return {
        "url": settings.LIVEKIT_URL,
        "token": token.to_jwt(),
        "room": room_name,
        "participant_identity": participant_identity,
    }