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
    print(f"\nVoice 'rachel' available: {is_voice_available('rachel')}")
    print(f"Voice 'nonexistent' available: {is_voice_available('nonexistent')}")
    

def test_british_lady_prerecorded():
    """Test the pre-recorded british_lady voice"""
    print("\n=== Testing Pre-recorded British Lady ===")
    
    test_phrases = ["yes", "no", "maybe", "definitely not"]
    
    for phrase in test_phrases:
        result = get_speech_from_text(phrase, f"test_{phrase}.mp3", "british_lady")
        print(f"'{phrase}' -> {result}")
        
        # Check if the file exists
        file_exists = check_audio_file_exists(result)
        print(f"  File exists: {file_exists}")


def test_elevenlabs_integration():
    """Test ElevenLabs API integration"""
    print("\n=== Testing ElevenLabs Integration ===")
    
    if not settings.ELEVENLABS_API_KEY:
        print("❌ ELEVENLABS_API_KEY not found in environment variables")
        print("Please set your ElevenLabs API key in .env file")
        return
    
    print("✅ ElevenLabs API key found")
    
    # Test with a short phrase and different voices
    test_text = "Hello, this is a test of the ElevenLabs integration."
    test_voices = ["rachel", "drew", "sarah"]
    
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
        ("Short text", "rachel"),
        ("This is a longer piece of text to test filename generation and audio quality", "sarah"),
        ("Text with special characters! @#$%^&*()", "drew"),
        ("", "rachel"),  # Empty text
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
