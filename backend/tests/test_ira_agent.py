import pytest

from app.agents.prompts import build_ira_system_prompt


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


def test_prompt_mentions_occasional_mental_wellness_breathing_suggestion():
    prompt = build_ira_system_prompt(
        user_message="I've been overwhelmed and can't calm down."
    )

    assert "occasionally suggest a short breathing exercise in Mental Wellness" in prompt
    assert "Crisis behavior always takes precedence" in prompt


def test_detect_response_language_style_handles_english_and_devanagari():
    from app.agents.prompts import detect_response_language_style

    assert "Romanized Hindi" in detect_response_language_style("mera mood aaj bahut off hai")
    assert "English" in detect_response_language_style("I had a really bad day")
    assert "Devanagari Hindi" in detect_response_language_style("आज मेरा दिन बहुत खराब था")
