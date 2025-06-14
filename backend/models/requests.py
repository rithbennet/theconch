# models/requests.py
from pydantic import BaseModel


class OpenQuestion(BaseModel):
    question: str
    voice: str = "fin"  # Default to mystical elderly voice for conch


class FoodQuestion(BaseModel):
    constraint: str | None = None  # Optional constraint
    voice: str = "sarah"  # Default to pleasant voice for food recommendations


class VoiceChoice(BaseModel):
    voice: str = "british_lady"  # Changed default to british_lady since we have those files
