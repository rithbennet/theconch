# models/responses.py
from pydantic import BaseModel
from typing import Optional


class RestaurantLocation(BaseModel):
    name: str
    address: str
    latitude: float
    longitude: float
    rating: float
    type: str
    price_level: Optional[str] = None
    google_maps_url: str  # Direct navigation link for Flutter app


class ConchResponse(BaseModel):
    message: str
    audio_url: str
    restaurant: Optional[RestaurantLocation] = None
