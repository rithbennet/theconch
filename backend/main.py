# main.py
import os
import random
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel
from dotenv import load_dotenv

# Load environment variables from a .env file
load_dotenv()

app = FastAPI()

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

# --- MOCK FUNCTIONS (Replace with your actual API calls) ---
# You'll need to install the google-generativeai and elevenlabs libraries
# from elevenlabs.client import ElevenLabs
# import google.generativeai as genai

# client = ElevenLabs(api_key="YOUR_ELEVENLABS_KEY")
# genai.configure(api_key="YOUR_GEMINI_KEY")

def get_llm_response(prompt: str) -> str:
    print(f"Sending to LLM: {prompt}")
    # This is where you would call the Gemini API
    # model = genai.GenerativeModel('gemini-pro')
    # response = model.generate_content(prompt)
    # return response.text
    return "This is a placeholder response from the LLM."

def get_speech_from_text(text: str, filename: str) -> str:
    print(f"Sending to ElevenLabs: {text}")
    # This is where you would call the ElevenLabs API
    # audio = client.generate(text=text, voice="Rachel", model="eleven_multilingual_v2")
    # with open(filename, "wb") as f:
    #     f.write(audio)
    # For the hackathon, we can just return a placeholder file
    return "audio/placeholder.mp3"
# --- END MOCK FUNCTIONS ---


@app.get("/")
def read_root():
    return {"Hello": "This is TheConch API"}

# 1. The Classic Conch (Yes/No)
@app.get("/api/classic")
async def get_classic_conch_answer():
    """
    Provides a classic Yes/No style answer.
    Returns placeholder audio file for frontend testing.
    """
    print("Classic Conch endpoint called - returning placeholder audio")
    return FileResponse("audio/placeholder.mp3", media_type="audio/mpeg")

# 2. The Culinary Oracle (What to Eat?)
@app.post("/api/what-to-eat")
async def get_food_suggestion(request: FoodQuestion):
    """
    Generates a vague food suggestion.
    Returns placeholder audio file for frontend testing.
    """
    print(f"Food suggestion endpoint called with data: {request}")
    print(f"Constraint: {request.constraint}")
    return FileResponse("audio/placeholder.mp3", media_type="audio/mpeg")

# 3. The Abyss of Ambiguity (Open-Ended Questions)
@app.post("/api/ask-anything")
async def get_open_ended_answer(request: OpenQuestion):
    """
    Generates a cryptic, unhelpful answer to a user's question.
    Returns placeholder audio file for frontend testing.
    """
    print(f"Open-ended question endpoint called with data: {request}")
    print(f"Question: {request.question}")
    return FileResponse("audio/placeholder.mp3", media_type="audio/mpeg")