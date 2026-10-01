import asyncio

from app.agents.agent import IRAAgent
from app.core.config import Settings
from app.services.ai_service import AIService, ChatTurn


class GroqAIService(AIService):
    def __init__(self, settings: Settings):
        self.agent = IRAAgent.from_settings(settings)

    async def generate_reply(
        self,
        *,
        system_prompt: str,
        history: list[ChatTurn],
    ) -> str:
        return await self.agent.respond(system_prompt=system_prompt, history=history)


__all__ = ["GroqAIService"]
