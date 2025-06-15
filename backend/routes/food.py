# routes/food.py
from fastapi import APIRouter, HTTPException
from models.requests import FoodQuestion
from models.responses import ConchResponse, RestaurantLocation
from services.llm_service import get_mystical_restaurant_description, get_annoyed_response
from services.tts_service import generate_audio_for_text, is_voice_available
from services.scraping_service import analyze_food_intent, find_restaurants_near, select_random_restaurant, generate_google_maps_url

router = APIRouter(prefix="/api", tags=["food"])


@router.post("/what-to-eat", response_model=ConchResponse)
async def get_food_suggestion(request: FoodQuestion):
    """
    Generates location-aware mystical food suggestions with specific restaurant selection.
    The conch randomly chooses a restaurant from 1-star to 5-star places.
    If the question isn't food-related, responds with an annoyed voice.
    """
    try:
        print(f"Received food question: '{request.question}' at location: {request.latitude}, {request.longitude}")
        
        # Analyze if the question is actually food-related
        intent_analysis = await analyze_food_intent(request.question)
        
        if not intent_analysis["is_food_related"]:
            print("Question is not food-related. Generating annoyed response.")
            # Generate annoyed response for non-food questions
            response_text = get_annoyed_response(request.question)
            
            # Use the vampire voice for annoyed responses - perfect for gothic irritation
            voice = "deep_ah"  # The vampire voice sounds perfectly annoyed
            
            # No restaurant suggestion for non-food questions
            restaurant_data = None
        else:
            print(f"Food-related question detected. Intent: {intent_analysis['intent']}")
            
            # Find restaurants near the user's location if coordinates provided
            restaurants = []
            restaurant_data = None
            
            if request.latitude is not None and request.longitude is not None:
                print(f"Searching for restaurants near {request.latitude}, {request.longitude}")
                search_query = intent_analysis.get("search_query", "restaurants")
                restaurants = await find_restaurants_near(
                    request.latitude, 
                    request.longitude, 
                    search_query
                )
                
                # Select a random restaurant from the results
                selected_restaurant = select_random_restaurant(restaurants)
                
                if selected_restaurant:
                    # Generate Google Maps URL for navigation
                    maps_url = generate_google_maps_url(selected_restaurant)
                    
                    # Create restaurant data for the response
                    restaurant_data = RestaurantLocation(
                        name=selected_restaurant.name,
                        address=selected_restaurant.address,
                        latitude=selected_restaurant.latitude,
                        longitude=selected_restaurant.longitude,
                        rating=selected_restaurant.rating,
                        type=selected_restaurant.type,
                        price_level=selected_restaurant.price_level,
                        google_maps_url=maps_url
                    )
                    
                    # Generate mystical description of the chosen restaurant
                    response_text = get_mystical_restaurant_description(
                        selected_restaurant.name,
                        selected_restaurant.type,
                        selected_restaurant.rating
                    )
                else:
                    print("No restaurants found, using mystical fallback")
                    response_text = "The winds whisper of distant places where sustenance awaits beyond the veil of knowing... The shell has spoken."
            else:
                print("No location provided, using mystical fallback")
                response_text = "The cosmic currents flow toward unknown destinations where nourishment calls to those who seek... The shell has spoken."
            
            # Use the requested voice for food suggestions
            voice = request.voice
        
        # Validate voice and fallback if needed
        if not is_voice_available(voice):
            print(f"Warning: Voice '{voice}' not available. Using 'deep_ah' as fallback.")
            voice = 'deep_ah'
        
        # Generate audio with proper filename
        audio_path = generate_audio_for_text(response_text, voice)
        
        return ConchResponse(
            message=response_text,
            audio_url=audio_path,
            restaurant=restaurant_data
        )
        
    except Exception as e:
        print(f"Error in food suggestion endpoint: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
