# routes/open_ended.py
from fastapi import APIRouter, HTTPException
from models.requests import OpenQuestion
from models.responses import ConchResponse
from services.llm_service import get_llm_response, get_cryptic_answer_prompt
from services.tts_service import generate_audio_for_text, is_voice_available

router = APIRouter(prefix="/api", tags=["open-ended"])


@router.post("/ask-anything", response_model=ConchResponse)
async def get_open_ended_answer(request: OpenQuestion):
    """
    Generates a cryptic, unhelpful answer to a user's question using ElevenLabs TTS.
    Supports voice selection with automatic fallback to default voice.
    """
    try:
        # Generate the cryptic response
        system_prompt = get_cryptic_answer_prompt()
        response = get_llm_response(request.question, system_prompt)
        
        # Use voice from request or default to a mystical voice
        voice = getattr(request, 'voice', 'fin')  # Fin has an elderly, mystical quality
        
        # Validate voice and fallback if needed
        if not is_voice_available(voice):
            print(f"Warning: Voice '{voice}' not available. Using 'fin' as fallback.")
            voice = 'fin'
        
        # Generate audio with proper filename
        audio_path = generate_audio_for_text(response, voice)
        
        return ConchResponse(
            message=response,
            audio_url=audio_path
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
