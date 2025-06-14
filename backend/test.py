import google.generativeai as genai
from dotenv import load_dotenv
import os

load_dotenv()

# Configure the API key
genai.configure(api_key=os.getenv("GEMINI_API_KEY")) # type: ignore

# Create a model instance
model = genai.GenerativeModel('gemini-2.5-flash-preview-05-20') # type: ignore

# Generate content
response = model.generate_content("Explain how AI works in a few words")

print(response.text)