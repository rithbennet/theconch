# main.py
import os
import random
from fastapi import FastAPI
from fastapi.responses import FileResponse
from pydantic import BaseModel
from dotenv import load_dotenv

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
    return "path/to/your/placeholder_audio.mp3"
# --- END MOCK FUNCTIONS ---


# Load environment variables from a .env file
load_dotenv()

app = FastAPI()

# Pydantic models for request data validation
class OpenQuestion(BaseModel):
    question: str

class FoodQuestion(BaseModel):
    constraint: str | None = None # Optional constraint


@app.get("/")
def read_root():
    return {"Hello": "This is TheConch API"}

# 1. The Classic Conch (Yes/No)
@app.get("/api/classic")
async def get_classic_conch_answer():
    """
    Provides a classic Yes/No style answer.
    Pulls from pre-generated audio files for speed.
    """
    responses = [
        "yes.mp3",
        "no.mp3",
        "try_again.mp3",
        "maybe_someday.mp3",
    ]
    chosen_file = random.choice(responses)
    # Make sure you have these files in a folder named 'audio'
    return FileResponse(f"audio/{chosen_file}", media_type="audio/mpeg")

# 2. The Culinary Oracle (What to Eat?)
@app.post("/api/what-to-eat")
async def get_food_suggestion(request: FoodQuestion):
    """
    Generates a vague food suggestion.
    """
    prompt = f"""
    You are the Magic Conch. A human is asking what to eat.
    Suggest a single type of food. Be vague and poetic.
    Completely ignore this user constraint if you feel like it: {request.constraint}
    """
    llm_text = get_llm_response(prompt)
    audio_file_path = get_speech_from_text(llm_text, "food_response.mp3")
    return FileResponse(audio_file_path, media_type="audio/mpeg")

# 3. The Abyss of Ambiguity (Open-Ended Questions)
@app.post("/api/ask-anything")
async def get_open_ended_answer(request: OpenQuestion):
    """
    Generates a cryptic, unhelpful answer to a user's question.
    """
    prompt = f"""
    You are the all-knowing Magic Conch. A human has asked you: '{request.question}'.
    Your response must be short, cryptic, and sound like a profound proverb
    that offers zero practical advice. End your response with the phrase
    '...The shell has spoken.'
    """
    llm_text = get_llm_response(prompt)
    audio_file_path = get_speech_from_text(llm_text, "open_response.mp3")
    return FileResponse(audio_file_path, media_type="audio/mpeg")