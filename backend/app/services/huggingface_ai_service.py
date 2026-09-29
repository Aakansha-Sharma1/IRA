import logging
from typing import List

from app.core.config import Settings
from app.services.ai_service import AIService, AIServiceError, ChatTurn

logger = logging.getLogger("ira.huggingface")


class HuggingFaceAIService(AIService):
    def __init__(self, settings: Settings):
        self._model_id = (settings.HF_MODEL_ID or "").strip()
        self._token = (settings.HF_TOKEN or "").strip()
        self._max_new_tokens = max(64, int(settings.HF_MAX_NEW_TOKENS or 256))
        self._temperature = float(settings.HF_TEMPERATURE or 0.7)
        self._top_p = float(settings.HF_TOP_P or 0.9)

    async def generate_reply(
        self,
        *,
        system_prompt: str,
        history: List[ChatTurn],
    ) -> str:
        if not self._model_id:
            raise AIServiceError(
                "Hugging Face model is not configured. Set HF_MODEL_ID on the backend.",
                status_code=503,
            )

        try:
            from transformers import pipeline
        except Exception as exc:  # pragma: no cover - depends on installed environment
            logger.exception("Transformers is unavailable")
            raise AIServiceError(
                "Hugging Face Transformers is not installed in the backend environment.",
                status_code=503,
            ) from exc

        if not history:
            raise AIServiceError("Conversation context is empty.", status_code=400)

        try:
            pipe = pipeline(
                "text-generation",
                model=self._model_id,
                token=self._token or None,
                device=-1,
            )
        except Exception as exc:  # pragma: no cover - runtime dependency may be unavailable
            logger.exception("Failed to load Hugging Face model %s", self._model_id)
            raise AIServiceError(
                f"Unable to load Hugging Face model '{self._model_id}'.",
                status_code=503,
            ) from exc

        prompt_lines = [system_prompt]
        for turn in history:
            role_label = "Assistant" if turn.role == "assistant" else "User"
            prompt_lines.append(f"{role_label}: {turn.content}")
        prompt_lines.append("Assistant:")
        prompt = "\n".join(prompt_lines)

        try:
            result = pipe(
                prompt,
                max_new_tokens=self._max_new_tokens,
                temperature=self._temperature,
                top_p=self._top_p,
                do_sample=self._temperature > 0,
                return_full_text=False,
            )
        except Exception as exc:  # pragma: no cover - inference may fail depending on environment
            logger.exception("Hugging Face inference failed for model %s", self._model_id)
            raise AIServiceError(
                "Hugging Face inference failed while generating a response.",
                status_code=502,
            ) from exc

        if not result:
            raise AIServiceError(
                "The Hugging Face model did not produce a usable reply.",
                status_code=502,
            )

        generated = result[0].get("generated_text") if isinstance(result, list) else str(result)
        if not generated or not str(generated).strip():
            raise AIServiceError(
                "The Hugging Face model did not generate a usable reply.",
                status_code=502,
            )

        text = str(generated).strip()
        if "Assistant:" in text:
            text = text.split("Assistant:", 1)[-1].strip()
        return text or "I’m here to help with your wellness check-in."
