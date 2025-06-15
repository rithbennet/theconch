# routes/classic.py
import random
from fastapi import APIRouter, HTTPException
from models.requests import VoiceChoice
from models.responses import ConchResponse
from services.tts_service import generate_audio_for_text, is_voice_available

router = APIRouter(prefix="/api", tags=["classic"])


@router.post("/classic", response_model=ConchResponse)
async def get_classic_conch_answer(voice_choice: VoiceChoice):
    """
    Provides a classic Yes/No style answer with deep_ah voice using ElevenLabs TTS.
    Only deep_ah voice is available.
    """
    try:
        # Classic conch answers
        answer = random.choice(["Yes", "No", "Maybe", "Ask again later", "Definitely not"])
        
        # Validate voice and use fallback if needed
        voice = voice_choice.voice
        if not is_voice_available(voice):
            print(f"Warning: Voice '{voice}' not available. Using 'deep_ah' as fallback.")
            voice = 'deep_ah'
        
        # Generate audio using the improved TTS service
        audio_path = generate_audio_for_text(answer, voice)
            
        return ConchResponse(
            message=answer,
            audio_url=audio_path
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
