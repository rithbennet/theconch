# routes/voices.py
from fastapi import APIRouter
from services.tts_service import get_available_voices, is_voice_available

router = APIRouter(prefix="/api", tags=["voices"])


@router.get("/voices")
async def get_voices():
    """
    Get all available voices for TTS generation.
    Returns a dictionary mapping voice names to descriptions.
    """
    return {
        "voices": get_available_voices(),
        "total_count": len(get_available_voices())
    }


@router.get("/voices/{voice_name}/available")
async def check_voice_availability(voice_name: str):
    """
    Check if a specific voice is available.
    """
    return {
        "voice": voice_name,
        "available": is_voice_available(voice_name)
    }
