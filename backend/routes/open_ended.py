# routes/open_ended.py
from fastapi import APIRouter, HTTPException
from models.requests import OpenQuestion
from models.responses import ConchResponse
from services.llm_service import get_llm_response, get_cryptic_answer_prompt
from services.tts_service import get_speech_from_text

router = APIRouter(prefix="/api", tags=["open-ended"])


@router.post("/ask-anything", response_model=ConchResponse)
async def get_open_ended_answer(request: OpenQuestion):
    """
    Generates a cryptic, unhelpful answer to a user's question.
    Returns placeholder audio file for frontend testing.
    """
    try:
        system_prompt = get_cryptic_answer_prompt()
        response = get_llm_response(request.question, system_prompt)
        audio_path = get_speech_from_text(response, "open_response.mp3")
        return ConchResponse(
            message=response,
            audio_url="/audio/open_response.mp3"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
