# routes/__init__.py
from .classic import router as classic_router
from .food import router as food_router
from .open_ended import router as open_ended_router
from .voices import router as voices_router

__all__ = ["classic_router", "food_router", "open_ended_router", "voices_router"]
