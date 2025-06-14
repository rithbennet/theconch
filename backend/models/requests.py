# models/requests.py
from pydantic import BaseModel


class OpenQuestion(BaseModel):
    question: str


class FoodQuestion(BaseModel):
    constraint: str | None = None  # Optional constraint


class VoiceChoice(BaseModel):
    voice: str = "british_lady"  # Changed default to british_lady since we have those files
