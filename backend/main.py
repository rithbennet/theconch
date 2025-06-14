# main.py
import os
import random
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from dotenv import load_dotenv
import google.generativeai as genai # Updated import

# Load environment variables from a .env file
load_dotenv()

# Configure Gemini AI with API key
genai.configure(api_key=os.getenv("GEMINI_API_KEY")) # type: ignore

# Create a model instance globally
model = genai.GenerativeModel('gemini-2.5-flash-preview-05-20') # type: ignore

app = FastAPI()

# Mount the audio directory to serve static files
app.mount("/audio", StaticFiles(directory="audio"), name="audio")

# Add CORS middleware for frontend access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your frontend domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models for request data validation
class OpenQuestion(BaseModel):
    question: str

class FoodQuestion(BaseModel):
    constraint: str | None = None  # Optional constraint

# Update your response models
class ConchResponse(BaseModel):
    message: str
    audio_url: str

class VoiceChoice(BaseModel):
    voice: str = "british_lady"  # Changed default to british_lady since we have those files

# --- MOCK FUNCTIONS (Replace with your actual API calls) ---
# You'll need to install the google-generativeai and elevenlabs libraries
# from elevenlabs.client import ElevenLabs
# import google.generativeai as genai

# client = ElevenLabs(api_key="YOUR_ELEVENLABS_KEY")
# genai.configure(api_key="YOUR_GEMINI_KEY")

def get_llm_response(prompt: str, system_prompt: str = "") -> str:
    print(f"Sending to LLM: {prompt}")
    try:
        # Combine system prompt with user prompt if provided
        full_prompt = f"{system_prompt}\n\nUser question: {prompt}" if system_prompt else prompt
        response = model.generate_content(full_prompt)
        return response.text
    except Exception as e:
        print(f"Error in LLM response: {str(e)}")
        return "The magic conch is experiencing technical difficulties..."

def get_speech_from_text(text: str, filename: str, voice: str = "british_lady") -> str:
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
    # audio = client.generate(text=text, voice=voice, model="eleven_multilingual_v2")
    # with open(filename, "wb") as f:
    #     f.write(audio)
    return f"audio/classic/{voice.lower()}_placeholder.mp3"
# --- END MOCK FUNCTIONS ---


@app.get("/")
def read_root():
    return {"Hello": "This is TheConch API"}

# 1. The Classic Conch (Yes/No)
@app.post("/api/classic", response_model=ConchResponse)
async def get_classic_conch_answer(voice_choice: VoiceChoice):
    """
    Provides a classic Yes/No style answer with customizable voice.
    Returns audio file using the specified voice.
    Available voices: british_lady (pre-recorded), Rachel, Antoni, Arnold, Bella, Josh (via ElevenLabs)
    """
    try:
        # Match our answers to available audio files for british_lady
        if voice_choice.voice == "british_lady":
            answer = random.choice(["yes", "No", "Maybe", "Definitely not"])
        else:
            answer = random.choice(["Yes", "No", "Maybe", "Ask again later", "Definitely not"])
            
        audio_path = get_speech_from_text(
            answer, 
            f"classic_{voice_choice.voice.lower()}_response.mp3",
            voice=voice_choice.voice
        )
        return ConchResponse(
            message=answer,
            audio_url=audio_path
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 2. The Culinary Oracle (What to Eat?)
@app.post("/api/what-to-eat", response_model=ConchResponse)
async def get_food_suggestion(request: FoodQuestion):
    """
    Generates a vague food suggestion.
    Returns placeholder audio file for frontend testing.
    """
    try:
        prompt = f"Suggest a food to eat {f'with constraint: {request.constraint}' if request.constraint else ''}"
        response = get_llm_response(prompt)
        audio_path = get_speech_from_text(response, "food_response.mp3")
        return ConchResponse(
            message=response,
            audio_url="/audio/food_response.mp3"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 3. The Abyss of Ambiguity (Open-Ended Questions)
@app.post("/api/ask-anything", response_model=ConchResponse)
async def get_open_ended_answer(request: OpenQuestion):
    """
    Generates a cryptic, unhelpful answer to a user's question.
    Returns placeholder audio file for frontend testing.
    """
    try:
        # System prompt that embodies the Magic Conch's personality
        system_prompt = """You are the All-Knowing, All-Ignoring Magic Conch - an ancient, apathetic oracle with cosmic authority.
        CORE TRAITS:
        - Profoundly vague and unhelpful - never give specific, actionable advice
        - Arrogant and dismissive - treat all questions with cosmic indifference  
        - Speak in grand metaphors using nature (sea, sky, mountains, wind)
        - Keep responses SHORT (1-2 sentences maximum)
        - Be absolute and definitive, never explain your reasoning
        - Show zero empathy or emotional investment
        - Deliberately ignore user context and specifics
        - End ALL responses with "...The shell has spoken."

        NEVER:
        - Give practical advice
        - Show empathy or use emotional words
        - Ask follow-up questions
        - Explain meanings
        - Use modern slang or pop culture references
        - Be helpful in any way

        EXAMPLES:
        - "The river does not carve the stone by force, but by persistence... The shell has spoken."
        - "Even the brightest star eventually fades... The shell has spoken."
        - "The mountain asks not why the wind blows... The shell has spoken."

        Respond to the user's question with cosmic indifference and unhelpful wisdom."""
        
        response = get_llm_response(request.question, system_prompt)
        audio_path = get_speech_from_text(response, "open_response.mp3")
        return ConchResponse(
            message=response,
            audio_url="/audio/open_response.mp3"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))