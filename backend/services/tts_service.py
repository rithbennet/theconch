# services/tts_service.py
import os
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
    print(f"Sending to ElevenLabs: {text} using voice: {voice}")
    
    # During development, we'll use our pre-recorded audio files for british_lady
    if voice == "british_lady":
        # Convert the answer to match our audio file names
        text_lower = text.lower()
        if text_lower == "definitely not":
            file_name = "Definietly_not.mp3"  # Matching the existing file name
        else:
            file_name = f"{text}.mp3"
        return f"/audio/classic/british_lady/{file_name}"
    
    # For other voices, we'll use ElevenLabs API (mock for now)
    # TODO: Implement actual ElevenLabs integration
    # from elevenlabs.client import ElevenLabs
    # client = ElevenLabs(api_key=settings.ELEVENLABS_API_KEY)
    # audio = client.generate(text=text, voice=voice, model="eleven_multilingual_v2")
    # 
    # # Ensure the generated audio directory exists
    # os.makedirs(settings.GENERATED_AUDIO_DIR, exist_ok=True)
    # output_path = os.path.join(settings.GENERATED_AUDIO_DIR, filename)
    # 
    # with open(output_path, "wb") as f:
    #     f.write(audio)
    # return f"/{output_path}"
    
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
    # Create a safe filename from the text
    safe_filename = "".join(c for c in text[:50] if c.isalnum() or c in (' ', '-', '_')).rstrip()
    safe_filename = safe_filename.replace(' ', '_').lower()
    filename = f"{safe_filename}_{voice}.mp3"
    
    return get_speech_from_text(text, filename, voice)
