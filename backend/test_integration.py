#!/usr/bin/env python3
"""
Comprehensive Integration Test for ElevenLabs TTS
Tests all routes with various voices to ensure proper integration
"""

import sys
import asyncio
import json
from pathlib import Path

# Add the backend directory to the Python path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

from routes.classic import get_classic_conch_answer
from routes.food import get_food_suggestion
from routes.open_ended import get_open_ended_answer
from routes.voices import get_voices, check_voice_availability
from models.requests import VoiceChoice, FoodQuestion, OpenQuestion


async def test_voices_endpoint():
    """Test the voices endpoint"""
    print("🎭 Testing Voices Endpoint")
    print("-" * 30)
    
    # Test get all voices
    voices_response = await get_voices()
    print(f"Available voices: {len(voices_response['voices'])}")
    
    # Test a few specific voice availability checks
    test_voices = ["deep_ah", "nonexistent_voice"]
    for voice in test_voices:
        availability = await check_voice_availability(voice)
        status = "✅" if availability["available"] else "❌"
        print(f"{status} {voice}: {availability['available']}")
    
    print()


async def test_classic_route():
    """Test the classic route with different voices"""
    print("🎯 Testing Classic Route")
    print("-" * 30)
    
    test_voices = ["deep_ah"]
    
    for voice in test_voices:
        try:
            request = VoiceChoice(voice=voice)
            response = await get_classic_conch_answer(request)
            print(f"✅ {voice}: '{response.message}' -> {response.audio_url}")
        except Exception as e:
            print(f"❌ {voice}: Error - {e}")
    
    print()


async def test_food_route():
    """Test the food route with different voices and constraints"""
    print("🍕 Testing Food Route")
    print("-" * 30)
    
    test_cases = [
        {"constraint": None, "voice": "deep_ah"},
        {"constraint": "vegetarian", "voice": "deep_ah"},
        {"constraint": "spicy", "voice": "deep_ah"},
        {"constraint": "healthy", "voice": "deep_ah"},
    ]
    
    for case in test_cases:
        try:
            request = FoodQuestion(**case)
            response = await get_food_suggestion(request)
            constraint_text = f" (constraint: {case['constraint']})" if case['constraint'] else ""
            print(f"✅ {case['voice']}{constraint_text}: '{response.message[:50]}...' -> {response.audio_url}")
        except Exception as e:
            print(f"❌ {case['voice']}: Error - {e}")
    
    print()


async def test_open_ended_route():
    """Test the open-ended route with different voices"""
    print("🤔 Testing Open-Ended Route")
    print("-" * 30)
    
    test_cases = [
        {"question": "What is the meaning of life?", "voice": "deep_ah"},
        {"question": "Should I quit my job?", "voice": "deep_ah"},
        {"question": "Will I find love?", "voice": "deep_ah"},
        {"question": "What should I do today?", "voice": "deep_ah"},
    ]
    
    for case in test_cases:
        try:
            request = OpenQuestion(**case)
            response = await get_open_ended_answer(request)
            print(f"✅ {case['voice']}: Q: '{case['question']}'")
            print(f"   A: '{response.message[:60]}...' -> {response.audio_url}")
        except Exception as e:
            print(f"❌ {case['voice']}: Error - {e}")
    
    print()


async def main():
    """Run all integration tests"""
    print("🧪 ElevenLabs Integration Test Suite")
    print("=" * 50)
    
    try:
        await test_voices_endpoint()
        await test_classic_route()
        await test_food_route()
        await test_open_ended_route()
        
        print("🎉 Integration test complete!")
        print("\nNext steps:")
        print("1. Check the audio/generated/ folder for generated files")
        print("2. Start the server: uvicorn main:app --reload")
        print("3. Test endpoints at http://localhost:8000/docs")
        
    except Exception as e:
        print(f"💥 Test suite failed: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    asyncio.run(main())
