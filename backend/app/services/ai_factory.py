from app.core.config import Settings
from app.services.ai_service import AIService, AIServiceError
from app.services.sarvam_ai_service import SarvamAIService


def create_ai_service(settings: Settings) -> AIService:
    provider = (settings.AI_PROVIDER or "sarvam").strip().lower()
    if provider == "sarvam":
        return SarvamAIService(settings)
    raise AIServiceError(
        f"Unsupported AI provider '{provider}'. Configure AI_PROVIDER=sarvam.",
        status_code=503,
    )
