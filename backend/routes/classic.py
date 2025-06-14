# routes/classic.py
import random
from fastapi import APIRouter, HTTPException
from models.requests import VoiceChoice
from models.responses import ConchResponse
from services.tts_service import get_speech_from_text

router = APIRouter(prefix="/api", tags=["classic"])


@router.post("/classic", response_model=ConchResponse)
async def get_classic_conch_answer(voice_choice: VoiceChoice):
    """
    Provides a classic Yes/No style answer with customizable voice.
    Returns audio file using the specified voice.
    Available voices: british_lady (pre-recorded), Rachel, Antoni, Arnold, Bella, Josh (via ElevenLabs)
    """
    try:
        # Match our answers to available audio files for british_lady
        if voice_choice.voice == "british_lady":
            answer = random.choice(["yes", "No", "Maybe", "Definitely not"])
        else:
            answer = random.choice(["Yes", "No", "Maybe", "Ask again later", "Definitely not"])
            
        audio_path = get_speech_from_text(
            answer, 
            f"classic_{voice_choice.voice.lower()}_response.mp3",
            voice=voice_choice.voice
        )
        return ConchResponse(
            message=answer,
            audio_url=audio_path
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
