from app.core.config import Settings
from app.services.ai_service import AIService, AIServiceError
from app.services.huggingface_ai_service import HuggingFaceAIService


def create_ai_service(settings: Settings) -> AIService:
    provider = (settings.AI_PROVIDER or "huggingface").strip().lower()
    if provider == "huggingface":
        if not (settings.HF_MODEL_ID or "").strip():
            raise AIServiceError(
                "Hugging Face model is not configured. Set HF_MODEL_ID on the backend.",
                status_code=503,
            )
        return HuggingFaceAIService(settings)
    raise AIServiceError(
        f"Unsupported AI provider '{provider}'. Configure AI_PROVIDER=huggingface.",
        status_code=503,
    )
