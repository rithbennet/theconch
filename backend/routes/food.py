# routes/food.py
from fastapi import APIRouter, HTTPException
from models.requests import FoodQuestion
from models.responses import ConchResponse
from services.llm_service import get_llm_response
from services.tts_service import get_speech_from_text

router = APIRouter(prefix="/api", tags=["food"])


@router.post("/what-to-eat", response_model=ConchResponse)
async def get_food_suggestion(request: FoodQuestion):
    """
    Generates a vague food suggestion.
    Returns placeholder audio file for frontend testing.
    """
    try:
        prompt = f"Suggest a food to eat {f'with constraint: {request.constraint}' if request.constraint else ''}"
        response = get_llm_response(prompt)
        audio_path = get_speech_from_text(response, "food_response.mp3")
        return ConchResponse(
            message=response,
            audio_url="/audio/food_response.mp3"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
