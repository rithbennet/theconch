#!/usr/bin/env python3
"""
ElevenLabs Voice Demo Script
Demonstrates different voices available in the TTS service
"""

import sys
from pathlib import Path

# Add the backend directory to the Python path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

from services.tts_service import generate_audio_for_text, get_available_voices


def demo_voices():
    """Demo different voice personalities"""
    print("🎭 ElevenLabs Voice Personality Demo")
    print("=" * 50)
    
    # Sample texts for the deep_ah voice only
    demos = [
        ("deep_ah", "From the shadows of time immemorial, wisdom flows... The shell has spoken."),
    ]
    
    print(f"Available voices: {len(get_available_voices())}")
    print("\nGenerating demo audio files...")
    print("-" * 30)
    
    for voice, text in demos:
        try:
            print(f"🎤 {voice.title()}: ", end="", flush=True)
            result = generate_audio_for_text(text, voice)
            print(f"✅ Generated: {result}")
        except Exception as e:
            print(f"❌ Error: {e}")
    
    print("\n🎵 Demo complete! Check the audio/generated/ folder for files.")
    print("\nTip: You can use the deep_ah voice in your API requests:")
    print('POST /api/classic {"voice": "deep_ah"}')
    print('POST /api/what-to-eat {"constraint": "vegan", "voice": "deep_ah"}')


def test_conch_responses():
    """Test classic conch responses with different voices"""
    print("\n🐚 The Conch Speaks in Many Voices")
    print("=" * 50)
    
    conch_responses = [
        "Yes",
        "No", 
        "Maybe",
        "Ask again later",
        "Definitely not"
    ]
    
    test_voices = ["deep_ah"]
    
    for i, response in enumerate(conch_responses):
        voice = test_voices[0]  # Only use deep_ah
        try:
            print(f"🔮 '{response}' in {voice}'s voice: ", end="", flush=True)
            result = generate_audio_for_text(response, voice)
            print(f"✅ {result}")
        except Exception as e:
            print(f"❌ Error: {e}")


if __name__ == "__main__":
    demo_voices()
    test_conch_responses()
    
    print("\n" + "="*50)
    print("🚀 Ready to use ElevenLabs TTS in your API!")
    print("Make sure your ELEVENLABS_API_KEY is set in .env")
    print("Run your FastAPI server: uvicorn main:app --reload")
