#!/bin/bash
# ElevenLabs Integration API Test Script
# Run this after starting the server with: uvicorn main:app --reload

echo "🧪 Testing ElevenLabs Integration with TheConch API"
echo "=================================================="

# Check if server is running
if ! curl -s http://localhost:8000/ > /dev/null; then
    echo "❌ Server not running. Start with: uvicorn main:app --reload"
    exit 1
fi

echo "✅ Server is running"
echo

# Test 1: Get available voices
echo "🎭 Testing available voices..."
curl -s -X GET "http://localhost:8000/api/voices" | jq '.voices | keys'
echo

# Test 2: Classic route with different voices
echo "🎯 Testing classic route with ElevenLabs voices..."
echo "British Lady (pre-recorded):"
curl -s -X POST "http://localhost:8000/api/classic" \
     -H "Content-Type: application/json" \
     -d '{"voice": "british_lady"}' | jq '.message, .audio_url'

echo
echo "Rachel (ElevenLabs):"
curl -s -X POST "http://localhost:8000/api/classic" \
     -H "Content-Type: application/json" \
     -d '{"voice": "rachel"}' | jq '.message, .audio_url'

echo

# Test 3: Food suggestions with voice
echo "🍕 Testing food suggestions with voice..."
curl -s -X POST "http://localhost:8000/api/what-to-eat" \
     -H "Content-Type: application/json" \
     -d '{"constraint": "vegetarian", "voice": "sarah"}' | jq '.message, .audio_url'

echo

# Test 4: Open-ended questions with mystical voice
echo "🤔 Testing open-ended questions with mystical voice..."
curl -s -X POST "http://localhost:8000/api/ask-anything" \
     -H "Content-Type: application/json" \
     -d '{"question": "What is the meaning of life?", "voice": "fin"}' | jq '.message, .audio_url'

echo
echo "🎉 Integration test complete!"
echo "Check the audio/generated/ folder for new audio files."
