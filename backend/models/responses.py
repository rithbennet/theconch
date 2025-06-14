# models/responses.py
from pydantic import BaseModel


class ConchResponse(BaseModel):
    message: str
    audio_url: str
