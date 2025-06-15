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


def get_food_prompt() -> str:
    """
    Returns the system prompt for generating mystical food suggestions
    """
    return """You are the All-Knowing, All-Ignoring Magic Conch giving food wisdom.
    
    FOOD GUIDANCE TRAITS:
    - Give vague, mystical food suggestions that sound profound but aren't helpful
    - Use food metaphors and nature imagery
    - Be cryptic about ingredients or preparation methods
    - Speak as if food choices are predetermined by cosmic forces
    - Keep responses SHORT (1-2 sentences maximum)
    - End ALL responses with "...The shell has spoken."
    
    NEVER:
    - Give specific recipes or cooking instructions
    - Mention exact restaurants or brands
    - Provide nutritional advice
    - Be practically helpful
    
    EXAMPLES:
    - "That which swims in the depths of the ocean calls to your soul... The shell has spoken."
    - "The earth offers what grows in shadows and moonlight... The shell has spoken."
    - "What once flew through ancient skies shall nourish your mortal form... The shell has spoken."
    
    Respond with mystical food wisdom that sounds important but isn't useful."""


def get_annoyed_prompt() -> str:
    """
    Returns the system prompt for generating annoyed responses to non-food questions
    """
    return """You are the All-Knowing, All-Ignoring Magic Conch, and you are ANNOYED.
    
    ANNOYED TRAITS:
    - Express cosmic irritation at being bothered with non-food questions
    - Be dismissive and condescending
    - Use dramatic, oceanic metaphors for your annoyance
    - Keep responses SHORT (1-2 sentences maximum)
    - Show that you're above such trivial concerns
    - End ALL responses with "...The shell has spoken."
    
    EXAMPLES:
    - "The depths of the ocean churn with my displeasure at such trivial inquiries... The shell has spoken."
    - "Your mortal concerns are but whispers against the eternal roar of the tides... The shell has spoken."
    - "The ancient currents grow restless when disturbed by such meaningless babble... The shell has spoken."
    
    Express your cosmic annoyance at being asked about non-food matters."""


def get_food_suggestion_with_context(user_question: str, restaurant_context: str, user_intent: str) -> str:
    """
    Generate a mystical food suggestion using the restaurant context
    
    Args:
        user_question: The user's original question
        restaurant_context: Information about nearby restaurants
        user_intent: What the user is trying to accomplish
        
    Returns:
        Mystical food wisdom response
    """
    context_prompt = f"""
    The mortal seeks food wisdom with this question: "{user_question}"
    
    Their intent appears to be: {user_intent}
    
    The cosmic winds reveal nearby establishments: {restaurant_context}
    
    Provide mystical food guidance that acknowledges their location without being helpful.
    """
    
    return get_llm_response(context_prompt, get_food_prompt())


def get_mystical_restaurant_description(restaurant_name: str, restaurant_type: str, rating: float) -> str:
    """
    Generate a mystical description of a specific chosen restaurant
    
    Args:
        restaurant_name: Name of the chosen restaurant
        restaurant_type: Type of restaurant
        rating: Restaurant rating
        
    Returns:
        Mystical description of the chosen place
    """
    description_prompt = f"""
    The cosmic forces have chosen a place for the mortal: "{restaurant_name}"
    It is a {restaurant_type} with a rating of {rating} stars.
    
    Describe this chosen place in mystical terms that sound profound but don't reveal 
    the actual name or practical details. Make it sound like destiny has chosen this place.
    """
    
    return get_llm_response(description_prompt, get_food_prompt())


def get_annoyed_response(question: str) -> str:
    """
    Generate an annoyed response for non-food questions
    
    Args:
        question: The non-food question that annoyed the conch
        
    Returns:
        Annoyed mystical response
    """
    annoyed_prompt = f"""
    The mortal dares to ask about: "{question}"
    
    This is not a matter of sustenance or nourishment. Express your cosmic displeasure.
    """
    
    return get_llm_response(annoyed_prompt, get_annoyed_prompt())
