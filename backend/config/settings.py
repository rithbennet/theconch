# config/settings.py
import os
from dotenv import load_dotenv

# Load environment variables from a .env file
load_dotenv()


class Settings:
    """Application settings and configuration"""
    
    # API Keys
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "")
    ELEVENLABS_API_KEY: str = os.getenv("ELEVENLABS_API_KEY", "")
    
    # Server settings
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))
    DEBUG: bool = os.getenv("DEBUG", "True").lower() == "true"
    
    # Audio settings
    AUDIO_DIR: str = "audio"
    GENERATED_AUDIO_DIR: str = "audio/generated"
    CLASSIC_AUDIO_DIR: str = "audio/classic"
    
    # CORS settings
    CORS_ORIGINS: list[str] = ["*"]  # In production, specify your frontend domains


# Create a global settings instance
settings = Settings()
