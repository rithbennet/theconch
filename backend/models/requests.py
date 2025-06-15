# models/requests.py
from pydantic import BaseModel


class OpenQuestion(BaseModel):
    question: str
    voice: str = "deep_ah"  # Default to mystical vampire voice for conch


class FoodQuestion(BaseModel):
    question: str  # What the user is asking about food
    latitude: float | None = None  # User's latitude
    longitude: float | None = None  # User's longitude
    voice: str = "deep_ah"  # Default to vampire voice for mystical food recommendations


class VoiceChoice(BaseModel):
    voice: str = "deep_ah"  # Only deep_ah voice is available
