from sarvamai import AsyncSarvamAI

from app.core.config import Settings
from app.services.ai_service import AIService, AIServiceError, ChatTurn


class SarvamAIService(AIService):
    def __init__(self, settings: Settings):
        api_key = (settings.SARVAM_API_KEY or "").strip()
        if not api_key:
            raise AIServiceError(
                "Sarvam API key is not configured. Set SARVAM_API_KEY in the backend environment.",
                status_code=503,
            )
        self.client = AsyncSarvamAI(api_subscription_key=api_key)
        self.model = (
            settings.SARVAM_MODEL or "sarvam-105b-conversations"
        ).strip()
        self.max_tokens = max(64, settings.SARVAM_MAX_TOKENS)
        self.temperature = settings.IRA_TEMPERATURE

    async def generate_reply(
        self,
        *,
        system_prompt: str,
        history: list[ChatTurn],
    ) -> str:
        messages = [
            {"role": "system", "content": system_prompt},
            *[
                {"role": turn.role, "content": turn.content}
                for turn in history
            ],
        ]
        try:
            response = await self.client.chat.completions(
                model=self.model,
                messages=messages,
                max_tokens=self.max_tokens,
                temperature=self.temperature,
            )
        except Exception as exc:
            raise AIServiceError(
                "The Sarvam AI service failed to generate a reply."
            ) from exc

        content = response.choices[0].message.content
        if not content:
            raise AIServiceError("The Sarvam AI service returned an empty reply.")
        return content


__all__ = ["SarvamAIService"]
