# services/tts_service.py
import os
from typing import Optional
from elevenlabs.client import ElevenLabs
from elevenlabs import VoiceSettings
from config.settings import settings


def get_speech_from_text(text: str, filename: str, voice: str = "british_lady") -> str:
    """
    Generate audio from text using either pre-recorded files or ElevenLabs API
    
    Args:
        text: The text to convert to speech
        filename: Desired filename for the output
        voice: Voice to use for generation
        
    Returns:
        Path to the audio file
    """
    print(f"Generating speech: {text} using voice: {voice}")
    
    # During development, we'll use our pre-recorded audio files for british_lady
    if voice == "british_lady":
        # Convert the answer to match our audio file names
        text_lower = text.lower()
        if text_lower == "definitely not":
            file_name = "Definietly_not.mp3"  # Matching the existing file name
        else:
            file_name = f"{text}.mp3"
        return f"/audio/classic/british_lady/{file_name}"
    
    # For other voices, use ElevenLabs API
    try:
        if not settings.ELEVENLABS_API_KEY:
            print("Warning: ELEVENLABS_API_KEY not found. Using placeholder audio.")
            return f"audio/classic/{voice.lower()}_placeholder.mp3"
        
        client = ElevenLabs(api_key=settings.ELEVENLABS_API_KEY)
        
        # Map voice names to ElevenLabs voice IDs
        voice_mapping = {
            "rachel": "21m00Tcm4TlvDq8ikWAM",  # Rachel
            "drew": "29vD33N1CtxCmqQRPOHJ",    # Drew
            "clyde": "2EiwWnXFnvU5JabPnv8n",   # Clyde
            "paul": "5Q0t7uMcjvnagumLfvZi",    # Paul
            "domi": "AZnzlk1XvdvUeBnXmlld",    # Domi
            "dave": "CYw3kZ02Hs0563khs1Fj",    # Dave
            "fin": "D38z5RcWu1voky8WS1ja",     # Fin
            "sarah": "EXAVITQu4vr4xnSDxMaL",   # Sarah
            "antoni": "ErXwobaYiN019PkySvjV",  # Antoni
            "thomas": "GBv7mTt0atIp3Br8iCZE",  # Thomas
            "emily": "LcfcDJNUP1GQjkzn1xUU",   # Emily
            "elli": "MF3mGyEYCl7XYWbV9V6O",    # Elli
            "callum": "N2lVS1w4EtoT3dr4eOWO",  # Callum
            "patrick": "ODq5zmih8GrVes37Dizd",  # Patrick
            "harry": "SOYHLrjzK2X1ezoPC6cr",   # Harry
            "liam": "TX3LPaxmHKxFdv7VOQHJ",    # Liam
            "dorothy": "ThT5KcBeYPX3keUQqHPh", # Dorothy
        }
        
        # Get the voice ID, default to Rachel if not found
        voice_id = voice_mapping.get(voice.lower(), "21m00Tcm4TlvDq8ikWAM")
        
        # Generate audio with optimized settings
        audio = client.generate(
            text=text,
            voice=voice_id,
            model="eleven_multilingual_v2",
            voice_settings=VoiceSettings(
                stability=0.4,
                similarity_boost=0.75,
                style=0.0,
                use_speaker_boost=True
            )
        )
        
        # Ensure the generated audio directory exists
        os.makedirs(settings.GENERATED_AUDIO_DIR, exist_ok=True)
        output_path = os.path.join(settings.GENERATED_AUDIO_DIR, filename)
        
        # Save the audio file
        with open(output_path, "wb") as f:
            for chunk in audio:
                f.write(chunk)
        
        print(f"Audio generated successfully: {output_path}")
        return f"/{output_path}"
        
    except Exception as e:
        print(f"Error generating audio with ElevenLabs: {e}")
        # Fallback to placeholder
        return f"audio/classic/{voice.lower()}_placeholder.mp3"


def generate_audio_for_text(text: str, voice: str = "british_lady") -> str:
    """
    Generate audio file for given text with proper file naming
    
    Args:
        text: Text to convert to speech
        voice: Voice to use
        
    Returns:
        URL path to the generated audio file
    """
    # Validate voice
    if not is_voice_available(voice):
        print(f"Warning: Voice '{voice}' not available. Using 'rachel' as fallback.")
        voice = "rachel"
    
    # Create a safe filename from the text
    safe_text = clean_filename(text)
    filename = f"{safe_text}_{voice}.mp3"
    
    return get_speech_from_text(text, filename, voice)


def get_available_voices() -> dict[str, str]:
    """
    Get a dictionary of available voices and their descriptions
    
    Returns:
        Dictionary mapping voice names to descriptions
    """
    return {
        "british_lady": "Pre-recorded British lady voice (development)",
        "rachel": "Rachel - Natural and versatile",
        "drew": "Drew - Well-rounded and warm",
        "clyde": "Clyde - War veteran",
        "paul": "Paul - Authoritative and confident",
        "domi": "Domi - Strong and assertive",
        "dave": "Dave - Conversational British accent",
        "fin": "Fin - Elderly Irish man",
        "sarah": "Sarah - Soft and pleasant",
        "antoni": "Antoni - Well-rounded American accent",
        "thomas": "Thomas - Calm and reliable",
        "emily": "Emily - Calm and pleasant",
        "elli": "Elli - Emotional and expressive",
        "callum": "Callum - Hoarse and intense",
        "patrick": "Patrick - Pleasant and engaging",
        "harry": "Harry - Anxious and stressed",
        "liam": "Liam - Calm and soothing",
        "dorothy": "Dorothy - Pleasant elderly woman"
    }


def is_voice_available(voice: str) -> bool:
    """
    Check if a voice is available for generation
    
    Args:
        voice: Voice name to check
        
    Returns:
        True if voice is available, False otherwise
    """
    available_voices = get_available_voices()
    return voice.lower() in available_voices


def clean_filename(text: str, max_length: int = 50) -> str:
    """
    Create a clean filename from text
    
    Args:
        text: Input text
        max_length: Maximum length for the filename
        
    Returns:
        Clean filename string
    """
    # Remove special characters and limit length
    safe_text = "".join(c for c in text[:max_length] if c.isalnum() or c in (' ', '-', '_')).rstrip()
    return safe_text.replace(' ', '_').lower()


def check_audio_file_exists(file_path: str) -> bool:
    """
    Check if an audio file exists
    
    Args:
        file_path: Path to the audio file
        
    Returns:
        True if file exists, False otherwise
    """
    # Remove leading slash if present for local file checking
    local_path = file_path.lstrip('/')
    return os.path.exists(local_path)
