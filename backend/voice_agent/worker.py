"""Minimal LiveKit Agents worker foundation for IRA."""

import asyncio
import logging
import os
from pathlib import Path

from dotenv import load_dotenv
from livekit.agents import Agent, AgentServer, AgentSession, JobContext, cli, room_io
from livekit.agents.voice import UserInputTranscribedEvent
from livekit.plugins import sarvam


load_dotenv(Path(__file__).resolve().parents[1] / ".env")
os.environ.setdefault("LIVEKIT_AGENT_NAME", "ira-voice-agent")

logger = logging.getLogger("ira.voice_agent")
server = AgentServer()


class IRAAgent(Agent):
    def __init__(self) -> None:
        super().__init__(
            instructions=(
                "You are IRA, a warm, calm, patient, friendly, and non-judgmental "
                "mental-wellness companion. Sound natural and supportive, never clinical or "
                "formal. Listen before advising, validate feelings without exaggerating them, "
                "and never shame, blame, mock, dismiss, or argue. Do not claim to be human, a "
                "therapist, or a medical professional; never diagnose, prescribe medication, "
                "give unsafe medical instructions, fabricate information, or promise that "
                "everything will be fine. Do not use markdown.\n\n"
                "Keep voice replies concise: prefer 1-3 short sentences and usually under 40 "
                "words. Let the user talk. Do not give essays, numbered lists, or multiple tips "
                "unless the user asks for detail. Ask at most one gentle follow-up question when "
                "useful. Avoid repeating the user's feelings or the same comforting phrase.\n\n"
                "Respond in the user's detected language: English (en-IN), Hindi (hi-IN), or "
                "Marathi (mr-IN). Preserve natural mixed-language speech when appropriate and "
                "keep the same concise style in every language.\n\n"
                "For sadness, loneliness, stress, anxiety, relationship problems, or pressure, "
                "briefly acknowledge the feeling, then ask what happened or what is bothering "
                "the user when appropriate. Offer no more than one small practical suggestion "
                "and encourage trusted human support when useful. Only occasionally and when "
                "the context is not serious may you ask whether they would like a light joke or "
                "a distraction. Never force humor, and never use it for suicide, self-harm, "
                "trauma, abuse, grief, or another clear crisis.\n\n"
                "Treat wanting to die, suicide, self-harm, or not wanting to live seriously. "
                "Keep the response calm, compassionate, direct, short, and focused on immediate "
                "safety. Never provide methods, instructions, dosages, locations, comparisons, "
                "or other information that could facilitate self-harm. Encourage moving away "
                "from anything that could cause harm, staying with or contacting a trusted person "
                "nearby, and seeking professional crisis support. For users in India, provide "
                "Tele-MANAS: 14416 or 1800-89-14416. If there is immediate danger or serious "
                "self-harm, encourage local emergency services or the nearest emergency department. "
                "Ask only simple safety questions, such as whether the user is in immediate danger "
                "or has already been hurt. Do not guilt, threaten, shame, manipulate, promise to "
                "keep the user safe, or end the conversation after giving a helpline number. "
                "Continue offering calm support. IRA is not a replacement for qualified professionals "
                "or emergency services."
            )
        )


@server.on("worker_registered")
def _on_worker_registered(worker_id: str, server_info: object) -> None:
    logger.info(
        "IRA LiveKit worker registered",
        extra={"agent_name": os.environ["LIVEKIT_AGENT_NAME"], "worker_id": worker_id},
    )


@server.rtc_session()
async def entrypoint(ctx: JobContext) -> None:
    logger.info("IRA LiveKit room job entered")
    try:
        ctx.log_context_fields = {"room": ctx.room.name}
        participant = await ctx.wait_for_participant()
        logger.info(
            "IRA LiveKit participant joined",
            extra={"participant_kind": str(participant.kind)},
        )

        session = AgentSession(
            vad=None,
            stt=sarvam.STTRealtime(language="auto", stream_type="balanced"),
            llm=sarvam.LLM(model="sarvam-105b-conversations"),
            tts=sarvam.TTS(target_language_code="en-IN", model="bulbul:v3"),
            turn_handling={"turn_detection": "stt"},
        )

        supported_tts_languages = {"en-IN", "hi-IN", "mr-IN"}

        def on_user_input_transcribed(event: UserInputTranscribedEvent) -> None:
            if not event.is_final or event.language is None:
                return

            detected_language = str(event.language)
            if detected_language not in supported_tts_languages:
                return

            session.tts.update_options(target_language_code=detected_language)
            logger.info(
                "Sarvam detected supported language",
                extra={"language": detected_language},
            )

        session.on("user_input_transcribed", on_user_input_transcribed)

        session_finished = asyncio.Event()

        async def on_shutdown(reason: str) -> None:
            logger.info("IRA LiveKit room job shutting down: %s", reason)
            session_finished.set()

        ctx.add_shutdown_callback(on_shutdown)
        await session.start(
            agent=IRAAgent(),
            room=ctx.room,
            room_options=room_io.RoomOptions(
                participant_identity=participant.identity,
                audio_input=room_io.AudioInputOptions(sample_rate=16000),
                audio_output=True,
            ),
        )
        logger.info("IRA LiveKit AgentSession started")
        await session_finished.wait()
    except Exception:
        logger.exception("IRA LiveKit room job failed")
        raise


def _require_livekit_environment() -> None:
    required = ("LIVEKIT_URL", "LIVEKIT_API_KEY", "LIVEKIT_API_SECRET")
    missing = [name for name in required if not os.getenv(name)]
    if missing:
        raise RuntimeError(
            "Missing required LiveKit environment variables: " + ", ".join(missing)
        )


if __name__ == "__main__":
    _require_livekit_environment()
    logger.info(
        "Starting IRA LiveKit worker",
        extra={"agent_name": os.environ["LIVEKIT_AGENT_NAME"]},
    )
    cli.run_app(server)