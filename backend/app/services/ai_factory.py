from app.core.config import Settings
from app.services.ai_service import AIService, AIServiceError
from app.services.gemini_ai_service import GeminiAIService


def create_ai_service(settings: Settings) -> AIService:
    provider = (settings.AI_PROVIDER or "gemini").strip().lower()
    if provider == "gemini":
        return GeminiAIService(settings)
    raise AIServiceError(
        f"Unsupported AI provider '{provider}'. Configure AI_PROVIDER=gemini.",
        status_code=503,
    )
