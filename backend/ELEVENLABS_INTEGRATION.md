# ElevenLabs TTS Integration Documentation

## Overview

The TTS service now supports both pre-recorded audio files and dynamic audio generation using ElevenLabs API.

## Setup

### 1. Environment Variables

Make sure you have your ElevenLabs API key set in your `.env` file:

```bash
ELEVENLABS_API_KEY=your_elevenlabs_api_key_here
```

### 2. Available Voices

The service supports only 1 voice:

**ElevenLabs API Voice**

- `deep_ah` - Deep Ah - Nosferatu Ancient Vampire Lord (Matthew Schmitz) - Deep male voice with eastern European accent for gothic horror
- `dorothy` - Pleasant elderly woman

## Usage

### Basic Usage

```python
from services.tts_service import generate_audio_for_text

# Generate audio with default voice (deep_ah)
audio_path = generate_audio_for_text("From the shadows, wisdom flows...")

# Generate audio with specific voice (only deep_ah available)
audio_path = generate_audio_for_text("Ancient knowledge emerges...", voice="deep_ah")
```

### Advanced Usage

```python
from services.tts_service import (
    get_speech_from_text,
    get_available_voices,
    is_voice_available,
    check_audio_file_exists
)

# Check available voices
voices = get_available_voices()
print(f"Available voices: {list(voices.keys())}")

# Validate voice before use
if is_voice_available("deep_ah"):
    audio_path = generate_audio_for_text("Ancient wisdom speaks...", "deep_ah")

    # Check if file was created successfully
    if check_audio_file_exists(audio_path):
        print(f"Audio generated successfully: {audio_path}")
```

### Manual File Control

```python
# For more control over filename
audio_path = get_speech_from_text(
    text="Custom text",
    filename="my_custom_audio.mp3",
    voice="sarah"
)
```

## How It Works

### Voice Selection Logic

1. **British Lady**: Uses pre-recorded files from `audio/classic/british_lady/`
2. **Other Voices**: Uses ElevenLabs API to generate audio dynamically
3. **Fallback**: If ElevenLabs API fails, returns a placeholder path

### File Storage

- **Pre-recorded files**: `audio/classic/british_lady/`
- **Generated files**: `audio/generated/`
- **Automatic directory creation**: Directories are created if they don't exist

### Audio Settings

The ElevenLabs integration uses optimized settings:

- **Model**: `eleven_multilingual_v2`
- **Stability**: 0.4 (balanced between consistency and expressiveness)
- **Similarity Boost**: 0.75 (maintains voice characteristics)
- **Style**: 0.0 (neutral style)
- **Speaker Boost**: Enabled (improves clarity)

## Error Handling

- **Missing API Key**: Falls back to placeholder audio
- **Invalid Voice**: Automatically switches to "deep_ah" as fallback
- **API Errors**: Gracefully handles failures and provides feedback

## Testing

Run the test suite to verify everything is working:

```bash
cd backend
source venv/bin/activate
python test_tts.py
```

## File Naming

Generated files use clean, filesystem-safe naming:

- Special characters are removed
- Spaces become underscores
- Format: `{clean_text}_{voice}.mp3`
- Example: `ancient_wisdom_deep_ah.mp3`

## Performance Notes

- First API call may take a few seconds to establish connection
- Audio files are cached (not regenerated if they already exist)
- Pre-recorded files load instantly
- Generated files are typically 2-10 seconds for short phrases
