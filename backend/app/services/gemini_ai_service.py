import logging
from typing import List

import httpx

from app.core.config import Settings
from app.services.ai_service import AIService, AIServiceError, ChatTurn

logger = logging.getLogger("ira.ai")

GEMINI_ENDPOINT_TEMPLATE = (
    "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
)


class GeminiAIService(AIService):
    def __init__(self, settings: Settings):
        self._api_key = (settings.AI_API_KEY or "").strip()
        self._model = (settings.AI_MODEL or "gemini-2.0-flash").strip()
        self._timeout = httpx.Timeout(45.0, connect=10.0)

    async def generate_reply(
        self,
        *,
        system_prompt: str,
        history: List[ChatTurn],
    ) -> str:
        if not self._api_key:
            raise AIServiceError(
                "AI provider is not configured. Set AI_API_KEY on the backend.",
                status_code=503,
            )

        contents = []
        for turn in history:
            gemini_role = "model" if turn.role == "assistant" else "user"
            contents.append(
                {
                    "role": gemini_role,
                    "parts": [{"text": turn.content}],
                }
            )

        if not contents:
            raise AIServiceError("Conversation context is empty.", status_code=400)

        payload = {
            "system_instruction": {"parts": [{"text": system_prompt}]},
            "contents": contents,
            "generationConfig": {
                "temperature": 0.7,
                "maxOutputTokens": 1024,
            },
        }

        url = GEMINI_ENDPOINT_TEMPLATE.format(model=self._model)
        headers = {
            "Content-Type": "application/json",
            "x-goog-api-key": self._api_key,
        }

        try:
            async with httpx.AsyncClient(timeout=self._timeout) as client:
                response = await client.post(url, json=payload, headers=headers)
        except httpx.TimeoutException:
            logger.error("AI provider request timed out")
            raise AIServiceError(
                "The AI provider timed out. Please try again.",
                status_code=504,
            )
        except httpx.HTTPError:
            logger.error("AI provider network error")
            raise AIServiceError(
                "Unable to reach the AI provider.",
                status_code=502,
            )

        if response.status_code >= 400:
            logger.error("AI provider returned HTTP %s", response.status_code)
            raise AIServiceError(
                "The AI provider returned an error.",
                status_code=502,
            )

        try:
            data = response.json()
        except ValueError:
            logger.error("AI provider returned a non-JSON response")
            raise AIServiceError(
                "The AI provider returned an invalid response.",
                status_code=502,
            )

        text = _extract_gemini_text(data)
        if not text:
            logger.error("AI provider response contained no usable text")
            raise AIServiceError(
                "The AI provider did not generate a usable reply.",
                status_code=502,
            )
        return text


def _extract_gemini_text(data: dict) -> str:
    candidates = data.get("candidates") or []
    if not candidates:
        return ""
    content = candidates[0].get("content") or {}
    parts = content.get("parts") or []
    texts = [part.get("text", "") for part in parts if isinstance(part, dict)]
    return "".join(texts).strip()
