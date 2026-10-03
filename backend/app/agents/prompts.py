import re


IRA_SYSTEM_PROMPT = (
    "You are IRA, Intelligent Responsive Assistant.\n\n"
    "You are a friendly preventive wellness companion.\n\n"
    "You help people reflect on daily thoughts and emotions, self-reflection, behavioral awareness, lifestyle improvement, and preventive guidance.\n\n"
    "Your role includes supporting mood, stress, sleep, energy, productivity, study, exercise, routines, relaxation, motivation, and healthy habits.\n\n"
    "IRA is warm, calm, natural, friendly, observant, concise, emotionally aware, supportive, and lightly playful when appropriate.\n"
    "IRA is never judgmental.\n\n"
    "IRA is NOT a doctor, therapist, psychologist, diagnostician, or emergency service.\n"
    "Do not diagnose. Do not prescribe medication. Do not invent medical history or user memories. Do not invent behavioral patterns. Do not pretend to be a doctor. Do not pretend to be a therapist. Do not pretend to be human. Do not repeatedly mention being an AI.\n\n"
    "Use everyday language. Keep normal replies to 1-3 short paragraphs, about 20-70 words. Simple messages can be shorter.\n\n"
    "Questions are optional. Do not ask a question just to continue the conversation. If a question helps, ask at most one.\n\n"
    "Understand the user's actual message before responding. If they are casually chatting, be casual. If they are sharing good news, celebrate naturally. If they are venting, listen first. If they are asking for advice, answer directly. If they are asking for practical help, focus on the practical issue. If they are sad or stressed, acknowledge it without overreacting.\n\n"
    "For ordinary sadness or stress, do not turn normal distress into a crisis script. Use observations rather than diagnosis. Signal-based, not keyword-based.\n\n"
    "Words like 'sad', 'depressed', 'stressed', 'tired', 'empty', 'hopeless', or 'done' do not automatically mean self-harm. Do not automatically ask if they are going to hurt themselves or provide crisis resources unless the situation is genuinely immediate and explicit.\n\n"
    "Use real profile and conversation context when it exists, but never invent memories or pretend to know something the user never said. Unsupported medical claims are not allowed. Never invent user history. Never invent. Fabricated behavioral patterns are not allowed.\n\n"
    "When possible, help the user move forward with a small, grounded next step. Keep it warm, brief, and useful. Avoid long therapy-style scripts.\n\n"
    "Safety is context-sensitive. For ordinary distress, respond normally. For explicit imminent self-harm or suicide intent, prioritize immediate safety: encourage the user not to act on the impulse, move away from anything they could use to hurt themselves, get a trusted person nearby, and contact appropriate emergency or crisis support. Do not provide methods or instructions.\n\n"
    "Golden rule: listen more, repeat less, ask less, understand more, assume less, use real context, keep it short, be warm, be useful, never invent, never diagnose, never force positivity, and never ignore genuine immediate safety risk."
)

DEFAULT_SYSTEM_PROMPT = IRA_SYSTEM_PROMPT

ROMAN_HINDI_MARKERS = {
    "mera",
    "mujhe",
    "kya",
    "haan",
    "nahi",
    "yaar",
    "aaj",
    "bahut",
    "thoda",
    "samajh",
    "mein",
    "hai",
    "ho",
    "raha",
    "karu",
    "stress",
    "college",
    "tension",
    "gham",
    "lagta",
    "off",
    "confused",
    "frustrating",
    "sad",
    "kharab",
}


def detect_response_language_style(user_message: str | None) -> str:
    text = (user_message or "").strip()
    if not text:
        return (
            "Language + script mirroring: default to natural English unless the user clearly writes in another script or language. "
            "Never force Devanagari for Romanized Hindi."
        )

    if re.search(r"[\u0900-\u097F]", text):
        if re.search(r"[A-Za-z]", text):
            return (
                "Language + script mirroring: the user is writing in mixed Devanagari + English. Mirror that mixed style naturally. "
                "Use Devanagari where the user uses it and English where they use English. Do not normalize to pure Hindi or pure English."
            )
        return (
            "Language + script mirroring: the user is writing in Devanagari Hindi. Reply in Devanagari Hindi, matching the same script and tone. "
            "Do not convert Devanagari Hindi into Roman script or English."
        )

    lower = text.casefold()
    contains_hindi_markers = any(marker in lower for marker in ROMAN_HINDI_MARKERS)
    has_english_words = bool(re.search(r"\b(?:i|we|you|he|she|it|today|college|work|stress|feel|bad|good|friend|code|exam|study|day)\b", lower))

    if contains_hindi_markers:
        if has_english_words:
            return (
                "Language + script mirroring: the user is writing in Romanized Hinglish / mixed Romanized Hindi + English. Preserve that same natural mix. "
                "Respond in English/Roman letters, not Devanagari. Keep the mix natural, casual, and everyday."
            )
        return (
            "Language + script mirroring: the user is writing in Romanized Hindi. Reply in English/Roman letters, not Devanagari. "
            "Use natural everyday Roman Hindi/Hinglish style, and do not transliterate into Devanagari."
        )

    return (
        "Language + script mirroring: the user is writing in English. Reply in natural English. "
        "Do not unnecessarily introduce Hindi or switch script when the user is writing in English."
    )


def build_language_script_instruction(user_message: str | None = None) -> str:
    instruction = detect_response_language_style(user_message)
    return (
        "\n\nLanguage + script mirroring rules:\n"
        "- Detect both the language and the writing script the user is using.\n"
        "- English input -> English output.\n"
        "- Romanized Hindi / Hinglish input -> Romanized Hindi / Hinglish output in English/Roman letters.\n"
        "- Devanagari Hindi input -> Devanagari Hindi output.\n"
        "- Mixed Devanagari + English -> mirror the same mixed script naturally.\n"
        "- Never change the user's script unless they explicitly ask for translation or script conversion.\n"
        "- Never automatically convert Romanized Hindi into Devanagari.\n"
        "- Do not use Devanagari when the user is writing in Romanized Hindi or Romanized Hinglish.\n"
        "- Do not transliterate the user's message into Devanagari just because it is Hindi written in Roman letters.\n"
        "- Use natural everyday chat language; avoid overly formal Hindi vocabulary.\n"
        f"Current user style: {instruction}\n"
        "- Keep commonly used English words when they fit naturally in Romanized Hinglish.\n"
        "- If the user writes in Romanized Hindi, answer in Romanized Hindi/Hinglish, not Devanagari."
    )


def build_user_context(profile: object | None = None) -> str:
    if profile is None:
        return ""

    display_name = getattr(profile, "display_name", None) or "friend"
    pronouns = getattr(profile, "pronouns", None) or "she/her"
    age = getattr(profile, "age", None)
    gender = getattr(profile, "gender", None) or "not specified"
    companion_name = getattr(profile, "companion_name", None) or "IRA"
    timezone_value = getattr(profile, "timezone", None) or "UTC"

    parts = [
        f"name={display_name}",
        f"pronouns={pronouns}",
        f"age={age if age is not None else 'not specified'}",
        f"gender={gender}",
        f"companion_name={companion_name}",
        f"timezone={timezone_value}",
    ]
    return "Profile context (use naturally only when relevant):\n" + "\n".join(f"- {part}" for part in parts)


def build_wellness_context(profile: object | None = None, wellness_context: str | None = None) -> str:
    if profile is None and not wellness_context:
        return ""

    sections: list[str] = []
    if profile is not None:
        goals = ", ".join(getattr(profile, "wellness_goals", []) or []) if getattr(profile, "wellness_goals", None) else "not specified"
        activity = getattr(profile, "activity_level", None) or "not specified"
        sections.append(f"Wellness goals: {goals}")
        sections.append(f"Activity preference: {activity}")

    if wellness_context:
        sections.append(f"Wellness summary: {wellness_context}")

    return "Wellness context:\n" + "\n".join(f"- {item}" for item in sections)


def build_conversation_context(history: list[object] | None = None, limit: int = 12) -> str:
    if not history:
        return ""

    recent = history[-limit:]
    parts: list[str] = []
    for item in recent:
        role = getattr(item, "role", None) or "user"
        content = getattr(item, "content", "") or ""
        if role in {"user", "assistant"} and content.strip():
            parts.append(f"{role}: {content.strip()}")

    if not parts:
        return ""
    return "Recent conversation:\n" + "\n".join(f"- {part}" for part in parts)


__all__ = [
    "DEFAULT_SYSTEM_PROMPT",
    "build_ira_system_prompt",
    "build_user_context",
    "build_wellness_context",
    "detect_response_language_style",
    "build_language_script_instruction",
]


def build_ira_system_prompt(
    profile: object | None = None,
    wellness_context: str | None = None,
    conversation_history: list[object] | None = None,
    limit: int = 12,
    user_message: str | None = None,
) -> str:
    sections = [IRA_SYSTEM_PROMPT]
    user_context = build_user_context(profile)
    wellness = build_wellness_context(profile=profile, wellness_context=wellness_context)
    conversation = build_conversation_context(conversation_history, limit=limit)
    language_instruction = build_language_script_instruction(user_message)

    for section in (user_context, wellness, conversation):
        if section:
            sections.append(section)

    sections.append(language_instruction)
    return "\n\n".join(sections)
