# services/llm_service.py
import google.generativeai as genai  # type: ignore
from config.settings import settings

# Configure Gemini AI with API key
genai.configure(api_key=settings.GEMINI_API_KEY)  # type: ignore

# Create a model instance globally
model = genai.GenerativeModel('gemini-2.5-flash-preview-05-20')  # type: ignore


def get_llm_response(prompt: str, system_prompt: str = "") -> str:
    """
    Get response from Google Gemini LLM
    
    Args:
        prompt: The user's question or prompt
        system_prompt: Optional system prompt to set context
        
    Returns:
        Generated text response
    """
    print(f"Sending to LLM: {prompt}")
    try:
        # Combine system prompt with user prompt if provided
        full_prompt = f"{system_prompt}\n\nUser question: {prompt}" if system_prompt else prompt
        response = model.generate_content(full_prompt)
        return response.text
    except Exception as e:
        print(f"Error in LLM response: {str(e)}")
        return "The magic conch is experiencing technical difficulties..."


def get_cryptic_answer_prompt() -> str:
    """
    Returns the system prompt for generating cryptic, unhelpful answers
    """
    return """You are the All-Knowing, All-Ignoring Magic Conch - an ancient, apathetic oracle with cosmic authority.
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
