from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import List


@dataclass(frozen=True)
class ChatTurn:
    role: str
    content: str


class AIServiceError(Exception):
    def __init__(self, message: str, status_code: int = 502):
        super().__init__(message)
        self.message = message
        self.status_code = status_code


class AIService(ABC):
    """Backend-only AI generation contract. Flutter never calls a provider directly."""

    @abstractmethod
    async def generate_reply(
        self,
        *,
        system_prompt: str,
        history: List[ChatTurn],
    ) -> str:
        raise NotImplementedError
