from __future__ import annotations

import asyncio
from typing import Sequence

from groq import Groq

from app.agents.prompts import (
    DEFAULT_SYSTEM_PROMPT,
    build_ira_system_prompt,
    build_language_script_instruction,
    build_user_context,
    build_wellness_context,
)
from app.core.config import Settings
from app.services.ai_service import AIServiceError, ChatTurn


class IRAAgent:
    def __init__(self, settings: Settings):
        self.settings = settings
        self.api_key = (settings.GROQ_API_KEY or settings.AI_API_KEY or "").strip()
        self.model = (settings.GROQ_MODEL or settings.AI_MODEL or "qwen/qwen3.8-27b").strip()
        self.context_messages = max(1, int(getattr(settings, "IRA_CONTEXT_MESSAGES", 12) or 12))
        self.max_response_tokens = max(64, int(getattr(settings, "IRA_MAX_RESPONSE_TOKENS", 350) or 350))
        self.temperature = float(getattr(settings, "IRA_TEMPERATURE", 0.7) or 0.7)
        self.client = Groq(api_key=self.api_key) if self.api_key else None

    @classmethod
    def from_settings(cls, settings: Settings) -> "IRAAgent":
        return cls(settings)

    def _safety_note_for_user_message(self, user_message: str) -> str | None:
        if not user_message:
            return None

        text = user_message.strip().lower()
        if not text:
            return None

        explicit_patterns = [
            "i want to kill myself",
            "i want to hurt myself",
            "i am going to kill myself",
            "i am going to hurt myself",
            "i want to die",
            "i am going to end my life",
            "i have a plan to kill myself",
            "i'm going to end my life",
            "i'm going to hurt myself",
            "kill myself",
            "hurt myself",
            "end my life",
            "suicide",
            "plan to kill myself",
        ]

        if any(pattern in text for pattern in explicit_patterns):
            return (
                "Immediate safety mode: respond briefly and humanly, encourage the user not to act on the impulse, "
                "move away from anything they could use to hurt themselves, get someone they trust nearby, and contact "
                "emergency or crisis support if immediate danger is present."
            )

        return None

    async def respond(
        self,
        *,
        system_prompt: str | None = None,
        history: Sequence[ChatTurn] | None = None,
        profile: object | None = None,
        conversation_history: Sequence[object] | None = None,
        user_message: str = "",
        wellness_context: str | None = None,
    ) -> str:
        if not self.api_key or self.client is None:
            raise AIServiceError(
                "Groq API key is not configured. Set GROQ_API_KEY in the backend environment.",
                status_code=503,
            )

        if system_prompt is None:
            system_prompt = build_ira_system_prompt(
                profile=profile,
                wellness_context=wellness_context,
                conversation_history=list(conversation_history or []),
                limit=self.context_messages,
                user_message=user_message,
            )
        else:
            style_instruction = build_language_script_instruction(user_message)
            if style_instruction:
                system_prompt = f"{system_prompt}\n\n{style_instruction}"

        safety_note = self._safety_note_for_user_message(user_message)
        if safety_note:
            system_prompt = f"{system_prompt}\n\n{safety_note}"

        recent_history = list(history or conversation_history or [])
        recent_history = recent_history[-self.context_messages:]

        messages: list[dict[str, str]] = [{"role": "system", "content": system_prompt or DEFAULT_SYSTEM_PROMPT}]

        for item in recent_history:
            if isinstance(item, dict):
                role = item.get("role") or "user"
                content = item.get("content") or ""
            else:
                role = getattr(item, "role", None) or "user"
                content = getattr(item, "content", None) or ""
            if role in {"user", "assistant"} and str(content).strip():
                messages.append({"role": role, "content": str(content).strip()})

        if user_message and user_message.strip():
            current_message = user_message.strip()
            if not messages or messages[-1].get("role") != "user" or messages[-1].get("content") != current_message:
                messages.append({"role": "user", "content": current_message})

        try:
            response = await asyncio.to_thread(
                self._request_completion,
                messages,
            )
        except Exception as exc:  # pragma: no cover - defensive fallback
            raise AIServiceError(f"Groq request failed: {exc}", status_code=502) from exc

        text = response.strip()
        if not text:
            raise AIServiceError("The Groq AI provider did not generate a usable reply.", status_code=502)
        return text

    def _request_completion(self, messages: list[dict[str, str]]) -> str:
        completion = self.client.chat.completions.create(
            model=self.model,
            messages=messages,
            temperature=self.temperature,
            max_tokens=self.max_response_tokens,
        )
        if not getattr(completion, "choices", None):
            raise AIServiceError("The Groq provider returned an empty response payload.", status_code=502)

        choice = completion.choices[0]
        message = getattr(choice, "message", None)
        content = getattr(message, "content", None) if message is not None else None
        if not isinstance(content, str):
            raise AIServiceError("The Groq provider returned a malformed response payload.", status_code=502)
        text = content.strip()
        if not text:
            raise AIServiceError("The Groq provider returned an empty response.", status_code=502)
        return text


__all__ = [
    "IRAAgent",
    "DEFAULT_SYSTEM_PROMPT",
    "build_ira_system_prompt",
    "build_user_context",
    "build_wellness_context",
]
