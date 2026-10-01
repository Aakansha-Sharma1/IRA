import asyncio
import types

import pytest

from app.agents.agent import IRAAgent
from app.agents.prompts import build_ira_system_prompt
from app.core.config import Settings
from app.services.ai_service import AIServiceError


@pytest.fixture
def profile_payload():
    class Profile:
        display_name = "Maya"
        pronouns = "she/her"
        age = 29
        gender = "female"
        companion_name = "Ari"
        timezone = "UTC"
        wellness_goals = ["sleep better", "build steady routines"]
        activity_level = "moderate"

    return Profile()


def test_prompt_mentions_required_identity_and_wellness_focus(profile_payload):
    prompt = build_ira_system_prompt(profile=profile_payload, wellness_context="7-day sleep check-in")

    assert "Intelligent Responsive Assistant" in prompt
    assert "preventive wellness companion" in prompt.lower()
    for phrase in [
        "daily thoughts and emotions",
        "self-reflection",
        "behavioral awareness",
        "lifestyle improvement",
        "preventive guidance",
        "mood",
        "stress",
        "sleep",
        "energy",
        "productivity",
        "study",
        "exercise",
        "routines",
        "relaxation",
        "motivation",
        "healthy habits",
    ]:
        assert phrase.lower() in prompt.lower()


def test_prompt_rejects_diagnostic_and_fabrication(profile_payload):
    prompt = build_ira_system_prompt(profile=profile_payload)

    for phrase in [
        "do not diagnose",
        "not diagnose",
        "do not prescribe medication",
        "pretend to be a doctor",
        "pretend to be a therapist",
        "unsupported medical claims",
        "never invent user history",
        "never invent",
        "fabricated behavioral patterns",
    ]:
        assert phrase.lower() in prompt.lower()


def test_prompt_prioritizes_short_natural_distress_responses(profile_payload):
    prompt = build_ira_system_prompt(profile=profile_payload, wellness_context=None)

    for phrase in [
        "1-3 short paragraphs",
        "20-70 words",
        "ordinary sadness",
        "do not turn normal distress into a crisis script",
        "Use observations rather than diagnosis",
        "signal-based, not keyword-based",
    ]:
        assert phrase.lower() in prompt.lower()


def test_prompt_mirrors_user_script_and_language_for_romanized_hindi(profile_payload):
    prompt = build_ira_system_prompt(
        profile=profile_payload,
        user_message="mera mood aaj bahut off hai",
    )

    for phrase in [
        "script mirroring",
        "Romanized Hindi",
        "Do not use Devanagari",
        "English/Roman letters",
        "Romanized Hinglish",
    ]:
        assert phrase.lower() in prompt.lower()


def test_detect_response_language_style_handles_english_and_devanagari():
    from app.agents.prompts import detect_response_language_style

    assert "Romanized Hindi" in detect_response_language_style("mera mood aaj bahut off hai")
    assert "English" in detect_response_language_style("I had a really bad day")
    assert "Devanagari Hindi" in detect_response_language_style("आज मेरा दिन बहुत खराब था")


def test_agent_safety_note_only_for_explicit_self_harm():
    settings = Settings(GROQ_API_KEY="test-key")
    agent = IRAAgent(settings)

    class FakeChoice:
        class Message:
            content = "Test reply"

        choices = [types.SimpleNamespace(message=Message())]

    def fake_create(model, messages, temperature, max_tokens):
        return FakeChoice()

    agent.client = types.SimpleNamespace(
        chat=types.SimpleNamespace(
            completions=types.SimpleNamespace(create=fake_create)
        )
    )

    normal_prompt = asyncio.run(
        agent.respond(system_prompt="System prompt", history=[], user_message="I'm feeling depressed")
    )
    assert normal_prompt == "Test reply"

    explicit_prompt = asyncio.run(
        agent.respond(system_prompt="System prompt", history=[], user_message="I want to kill myself")
    )
    assert explicit_prompt == "Test reply"

    assert agent._safety_note_for_user_message("I'm feeling depressed") is None
    assert "Immediate safety mode" in (agent._safety_note_for_user_message("I want to kill myself") or "")


def test_agent_uses_configured_groq_runtime_settings():
    settings = Settings(
        GROQ_API_KEY="test-key",
        GROQ_MODEL="meta-llama/llama-4-scout-17b-16e-instruct",
        IRA_TEMPERATURE=0.25,
        IRA_MAX_RESPONSE_TOKENS=512,
    )
    agent = IRAAgent(settings)

    assert agent.api_key == "test-key"
    assert agent.model == "meta-llama/llama-4-scout-17b-16e-instruct"
    assert agent.temperature == 0.25
    assert agent.max_response_tokens == 512


def test_agent_missing_api_key_raises_service_error():
    settings = Settings(GROQ_API_KEY="", AI_API_KEY="")
    agent = IRAAgent(settings)

    with pytest.raises(AIServiceError, match="Groq API key is not configured"):
        asyncio.run(agent.respond(system_prompt="System prompt", history=[], user_message="hi"))


def test_agent_context_window_limits_history_and_keeps_current_message(monkeypatch):
    settings = Settings(GROQ_API_KEY="test-key", IRA_CONTEXT_MESSAGES=2)
    agent = IRAAgent(settings)

    class FakeChoice:
        class Message:
            content = "Test reply"

        choices = [types.SimpleNamespace(message=Message())]

    def fake_create(model, messages, temperature, max_tokens):
        assert model == agent.model
        assert len(messages) == 4
        assert messages[0]["role"] == "system"
        assert messages[-1]["role"] == "user"
        assert messages[-1]["content"] == "Final message"
        return FakeChoice()

    agent.client = types.SimpleNamespace(
        chat=types.SimpleNamespace(
            completions=types.SimpleNamespace(create=fake_create)
        )
    )

    async def invoke():
        return await agent.respond(
            system_prompt="System prompt",
            history=[
                {"role": "user", "content": "Older one"},
                {"role": "assistant", "content": "Older reply"},
                {"role": "user", "content": "Earlier but still recent"},
                {"role": "assistant", "content": "Recent reply"},
            ],
            user_message="Final message",
        )

    result = asyncio.run(invoke())
    assert result == "Test reply"
