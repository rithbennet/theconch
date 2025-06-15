# services/tts_service.py
import os
from typing import Optional
from elevenlabs.client import ElevenLabs
from elevenlabs import VoiceSettings
from config.settings import settings

# Try to import audio processing libraries for reverb effects
try:
    import librosa
    import soundfile as sf
    import numpy as np
    AUDIO_PROCESSING_AVAILABLE = True
except ImportError:
    AUDIO_PROCESSING_AVAILABLE = False
    print("Audio processing libraries not available. Install librosa and soundfile for reverb effects.")


def add_godly_reverb(audio_path: str, reverb_decay: float = 0.8, room_size: float = 0.9) -> str:
    """
    Add godly reverb effect to an audio file for divine, ethereal atmosphere
    Creates a rich, heavenly reverb like a voice speaking from the heavens
    
    Args:
        audio_path: Path to the original audio file
        reverb_decay: Reverb decay factor (0.0-1.0, default 0.8 for rich reverb)
        room_size: Simulated room size (0.0-1.0, default 0.9 for cathedral-like space)
        
    Returns:
        Path to the processed audio file with godly reverb
    """
    if not AUDIO_PROCESSING_AVAILABLE:
        print("Audio processing not available, returning original file")
        return audio_path
    
    try:
        # Load the audio file
        audio, sample_rate = librosa.load(audio_path, sr=None) # type: ignore
        
        # Create multiple reverb tails at different delays for rich, godly sound
        reverb_delays = [0.03, 0.07, 0.13, 0.19, 0.29, 0.41, 0.53]  # Prime numbers for natural sound
        reverb_gains = [0.6, 0.5, 0.4, 0.35, 0.3, 0.25, 0.2]  # Decreasing gains
        
        # Calculate the longest delay to size the output buffer
        max_delay = max(reverb_delays)
        max_delay_samples = int(max_delay * sample_rate)
        
        # Create output buffer with room for reverb tail
        reverb_length = int(sample_rate * 2.0 * room_size)  # 2 seconds max reverb tail
        output_audio = np.zeros(len(audio) + reverb_length) # type: ignore
        
        # Add the original audio
        output_audio[:len(audio)] = audio
        
        # Add multiple reverb reflections for rich, divine sound
        for delay, gain in zip(reverb_delays, reverb_gains):
            delay_samples = int(delay * sample_rate)
            adjusted_gain = gain * reverb_decay
            
            # Add reverb reflection
            end_idx = delay_samples + len(audio)
            if end_idx <= len(output_audio):
                output_audio[delay_samples:end_idx] += audio * adjusted_gain
        
        # Add diffused reverb tail for heavenly atmosphere
        for i in range(3):  # Multiple layers of diffusion
            tail_delay = int(sample_rate * (0.1 + i * 0.15))  # Increasing delays
            tail_gain = reverb_decay * (0.3 - i * 0.08)  # Decreasing gains
            
            if tail_delay + len(audio) <= len(output_audio):
                # Add filtered reverb tail (simulate frequency response of large space)
                filtered_audio = audio * tail_gain
                output_audio[tail_delay:tail_delay + len(audio)] += filtered_audio
        
        # Apply gentle low-pass filtering to simulate air absorption (makes it more ethereal)
        # Simple moving average for high-frequency rolloff
        kernel_size = 3
        kernel = np.ones(kernel_size) / kernel_size # type: ignore
        output_audio = np.convolve(output_audio, kernel, mode='same') # type: ignore
        
        # Normalize to prevent clipping while preserving dynamics
        max_val = np.max(np.abs(output_audio)) # type: ignore
        if max_val > 0.95:
            output_audio = output_audio * (0.95 / max_val)
        
        # Create output filename
        base_name, ext = os.path.splitext(audio_path)
        reverb_path = f"{base_name}_godly_reverb{ext}"
        
        # Save the processed audio
        sf.write(reverb_path, output_audio, sample_rate) # type: ignore
        
        print(f"Godly reverb effect applied: {reverb_path}")
        return reverb_path
        
    except Exception as e:
        print(f"Error applying godly reverb effect: {e}")
        return audio_path


def get_speech_from_text(text: str, filename: str, voice: str = "deep_ah") -> str:
    """
    Generate audio from text using ElevenLabs API
    
    Args:
        text: The text to convert to speech
        filename: Desired filename for the output
        voice: Voice to use for generation
        
    Returns:
        Path to the audio file
    """
    print(f"Generating speech: {text} using voice: {voice}")
    
    # Use ElevenLabs API for all voices (only deep_ah is available now)
    try:
        if not settings.ELEVENLABS_API_KEY:
            print("Warning: ELEVENLABS_API_KEY not found. Using placeholder audio.")
            return f"audio/classic/{voice.lower()}_placeholder.mp3"
        
        client = ElevenLabs(api_key=settings.ELEVENLABS_API_KEY)
        
        # Map voice names to ElevenLabs voice IDs
        voice_mapping = {
            "deep_ah": "Tj9l48J9AJbry5yCP5eW", # Matthew Schmitz - Nosferatu Ancient Vampire Lord
        }
        
        # Get the voice ID, default to deep_ah (vampire voice) if not found
        voice_id = voice_mapping.get(voice.lower(), "Tj9l48J9AJbry5yCP5eW")
        
        # Generate audio with highest quality settings optimized for vampire voice
        # Using the finest model available with enhanced settings for gothic horror
        audio = client.generate(
            text=text,
            voice=voice_id,
            model="eleven_turbo_v2_5",  # Highest quality model available
            voice_settings=VoiceSettings(
                stability=0.6,           # Higher stability for dramatic effect
                similarity_boost=0.9,    # Maximum voice characteristics preservation
                style=0.3,               # Slight style enhancement for gothic character
                use_speaker_boost=True   # Enhanced clarity for deep voice
            )
        )
        
        # Ensure the generated audio directory exists
        os.makedirs(settings.GENERATED_AUDIO_DIR, exist_ok=True)
        output_path = os.path.join(settings.GENERATED_AUDIO_DIR, filename)
        
        # Save the audio file
        with open(output_path, "wb") as f:
            for chunk in audio:
                f.write(chunk)
        
        # Apply godly reverb effect for vampire voice
        if voice.lower() == "deep_ah":
            print("Applying divine reverb effect for vampire voice...")
            output_path = add_godly_reverb(output_path, reverb_decay=0.85, room_size=0.95)
        
        print(f"Audio generated successfully: {output_path}")
        return f"/{output_path}"
        
    except Exception as e:
        print(f"Error generating audio with ElevenLabs: {e}")
        # Fallback to placeholder
        return f"audio/classic/{voice.lower()}_placeholder.mp3"


def generate_audio_for_text(text: str, voice: str = "deep_ah") -> str:
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
        print(f"Warning: Voice '{voice}' not available. Using 'deep_ah' as fallback.")
        voice = "deep_ah"
    
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
        "deep_ah": "Deep Ah - Nosferatu Ancient Vampire Lord (Matthew Schmitz) - Deep male voice with eastern European accent for gothic horror"
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
