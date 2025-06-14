# routes/food.py
from fastapi import APIRouter, HTTPException
from models.requests import FoodQuestion
from models.responses import ConchResponse
from services.llm_service import get_llm_response, get_food_prompt
from services.tts_service import generate_audio_for_text, is_voice_available

router = APIRouter(prefix="/api", tags=["food"])


@router.post("/what-to-eat", response_model=ConchResponse)
async def get_food_suggestion(request: FoodQuestion):
    """
    Generates a mystical food suggestion using ElevenLabs TTS.
    Supports voice selection with automatic fallback to default voice.
    """
    try:
        # Create a food-specific prompt with constraint
        constraint_text = f" The mortal seeks guidance with constraint: {request.constraint}" if request.constraint else ""
        user_prompt = f"Provide mystical food wisdom.{constraint_text}"
        
        # Use the food-specific system prompt
        system_prompt = get_food_prompt()
        response = get_llm_response(user_prompt, system_prompt)
        
        # Use voice from request
        voice = request.voice
        
        # Validate voice and fallback if needed
        if not is_voice_available(voice):
            print(f"Warning: Voice '{voice}' not available. Using 'sarah' as fallback.")
            voice = 'sarah'
        
        # Generate audio with proper filename
        audio_path = generate_audio_for_text(response, voice)
        
        return ConchResponse(
            message=response,
            audio_url=audio_path
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
