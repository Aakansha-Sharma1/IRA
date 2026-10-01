from app.core.config import Settings
from app.services.ai_service import AIService, AIServiceError
from app.services.groq_ai_service import GroqAIService


def create_ai_service(settings: Settings) -> AIService:
    provider = (settings.AI_PROVIDER or "groq").strip().lower()
    if provider == "groq":
        return GroqAIService(settings)
    raise AIServiceError(
        f"Unsupported AI provider '{provider}'. Configure AI_PROVIDER=groq.",
        status_code=503,
    )
