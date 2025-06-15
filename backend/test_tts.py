#!/usr/bin/env python3
"""
Test script for ElevenLabs TTS integration
"""

import os
import sys
from pathlib import Path

# Add the backend directory to the Python path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

from services.tts_service import (
    get_speech_from_text,
    generate_audio_for_text,
    get_available_voices,
    is_voice_available,
    check_audio_file_exists
)
from config.settings import settings


def test_voice_utilities():
    """Test voice utility functions"""
    print("=== Testing Voice Utilities ===")
    
    # Test available voices
    voices = get_available_voices()
    print(f"Available voices ({len(voices)}):")
    for voice, description in voices.items():
        print(f"  - {voice}: {description}")
    
    # Test voice availability
    print(f"\nVoice 'deep_ah' available: {is_voice_available('deep_ah')}")
    print(f"Voice 'nonexistent' available: {is_voice_available('nonexistent')}")
    

def test_british_lady_prerecorded():
    """Test has been removed - british_lady voice no longer available"""
    print("\n=== British Lady Voice Removed ===")
    print("Only deep_ah voice is available now")


def test_elevenlabs_integration():
    """Test ElevenLabs API integration"""
    print("\n=== Testing ElevenLabs Integration ===")
    
    if not settings.ELEVENLABS_API_KEY:
        print("❌ ELEVENLABS_API_KEY not found in environment variables")
        print("Please set your ElevenLabs API key in .env file")
        return
    
    print("✅ ElevenLabs API key found")
    
    # Test with a short phrase using only deep_ah voice
    test_text = "From the shadows of eternity, ancient wisdom flows... The shell has spoken."
    test_voices = ["deep_ah"]
    
    for voice in test_voices:
        print(f"\nTesting voice: {voice}")
        try:
            result = generate_audio_for_text(test_text, voice)
            print(f"  Generated: {result}")
            
            # Check if file was created
            file_exists = check_audio_file_exists(result)
            print(f"  File created: {file_exists}")
            
        except Exception as e:
            print(f"  ❌ Error: {e}")


def test_file_generation():
    """Test file generation with various inputs"""
    print("\n=== Testing File Generation ===")
    
    test_cases = [
        ("From the abyss of time, wisdom emerges", "deep_ah"),
        ("The ancient spirits whisper through the ethereal void of existence and transcendence", "deep_ah"),
        ("Text with special characters! @#$%^&*()", "deep_ah"),
        ("", "deep_ah"),  # Empty text
    ]
    
    for text, voice in test_cases:
        print(f"\nTesting: '{text[:30]}...' with {voice}")
        try:
            result = generate_audio_for_text(text, voice)
            print(f"  Result: {result}")
        except Exception as e:
            print(f"  ❌ Error: {e}")


def main():
    """Run all tests"""
    print("🎵 TheConch TTS Service Test Suite 🎵\n")
    
    # Check if audio directories exist
    print("=== Environment Check ===")
    print(f"Generated audio directory: {settings.GENERATED_AUDIO_DIR}")
    print(f"Classic audio directory: {settings.CLASSIC_AUDIO_DIR}")
    
    # Create directories if they don't exist
    os.makedirs(settings.GENERATED_AUDIO_DIR, exist_ok=True)
    os.makedirs(settings.CLASSIC_AUDIO_DIR, exist_ok=True)
    
    # Run tests
    test_voice_utilities()
    test_british_lady_prerecorded()
    test_elevenlabs_integration()
    test_file_generation()
    
    print("\n✅ Test suite completed!")
    print("\nTo set up ElevenLabs:")
    print("1. Copy .env.example to .env")
    print("2. Add your ElevenLabs API key to ELEVENLABS_API_KEY")
    print("3. Run this test again to verify the integration")


if __name__ == "__main__":
    main()
