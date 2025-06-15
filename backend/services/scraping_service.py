# services/scraping_service.py
import httpx
from config.settings import settings
from typing import List, Dict, Any, Optional
import json
import random


class RestaurantData:
    """Data class for restaurant information"""
    def __init__(self, name: str, address: str, latitude: float, longitude: float, 
                 rating: float, restaurant_type: str, price_level: Optional[str] = None):
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
        self.type = restaurant_type
        self.price_level = price_level


async def find_restaurants_near(latitude: float, longitude: float, query: str = "restaurants") -> List[RestaurantData]:
    """
    Find restaurants near the given coordinates using SerpAPI Google Local search.
    
    Args:
        latitude: User's latitude
        longitude: User's longitude
        query: Search query (default: "restaurants")
        
    Returns:
        List of RestaurantData objects or empty list on failure
    """
    try:
        if not settings.SERPAPI_API_KEY:
            print("Warning: SERPAPI_API_KEY not configured. Using fallback.")
            return []
        
        # Construct the search parameters
        params = {
            "engine": "google_maps",
            "q": query,
            "ll": f"@{latitude},{longitude},15z",
            "type": "search",
            "api_key": settings.SERPAPI_API_KEY
        }
        
        print(f"Searching for restaurants near {latitude}, {longitude} with query: '{query}'")
        
        async with httpx.AsyncClient() as client:
            response = await client.get("https://serpapi.com/search", params=params)
            
            if response.status_code != 200:
                print(f"SerpAPI request failed with status {response.status_code}")
                return []
            
            data = response.json()
            
            # Extract local results
            local_results = data.get("local_results", [])
            
            if not local_results:
                print("No local results found")
                return []
            
            # Parse the results into RestaurantData objects
            restaurants = []
            for result in local_results:
                try:
                    name = result.get("title", "Unknown establishment")
                    address = result.get("address", "Unknown location")
                    rating = float(result.get("rating", 0.0))
                    restaurant_type = result.get("type", "restaurant")
                    price_level = result.get("price", None)
                    
                    # Extract coordinates from the GPS coordinates if available
                    gps = result.get("gps_coordinates", {})
                    rest_lat = gps.get("latitude", latitude)  # Fallback to search center
                    rest_lng = gps.get("longitude", longitude)
                    
                    restaurant = RestaurantData(
                        name=name,
                        address=address,
                        latitude=float(rest_lat),
                        longitude=float(rest_lng),
                        rating=rating,
                        restaurant_type=restaurant_type,
                        price_level=price_level
                    )
                    
                    restaurants.append(restaurant)
                    
                except (ValueError, TypeError) as e:
                    print(f"Error parsing restaurant data: {e}")
                    continue
            
            print(f"Found {len(restaurants)} restaurants")
            return restaurants
            
    except Exception as e:
        print(f"Error in restaurant search: {str(e)}")
        return []


def generate_google_maps_url(restaurant: RestaurantData) -> str:
    """
    Generate a Google Maps navigation URL for the restaurant
    
    Args:
        restaurant: RestaurantData object
        
    Returns:
        Google Maps URL for navigation
    """
    # URL encode the restaurant name and address for the query
    import urllib.parse
    
    # Create a search query with name and address for better accuracy
    query = f"{restaurant.name}, {restaurant.address}"
    encoded_query = urllib.parse.quote(query)
    
    # Generate Google Maps URL with coordinates for precise location
    # This will work on both mobile and web
    maps_url = f"https://www.google.com/maps/search/?api=1&query={encoded_query}&center={restaurant.latitude},{restaurant.longitude}"
    
    print(f"Generated Google Maps URL for {restaurant.name}: {maps_url}")
    return maps_url


def select_random_restaurant(restaurants: List[RestaurantData]) -> Optional[RestaurantData]:
    """
    Randomly select a restaurant from the list.
    The magic conch doesn't care about your preferences - it's truly random!
    
    Args:
        restaurants: List of available restaurants
        
    Returns:
        Randomly selected restaurant or None if list is empty
    """
    if not restaurants:
        return None
    
    selected = random.choice(restaurants)
    print(f"The mystical forces have chosen: {selected.name} (Rating: {selected.rating}⭐)")
    return selected


def format_restaurants_for_llm(restaurants: List[RestaurantData]) -> str:
    """
    Format restaurant list for LLM consumption
    
    Args:
        restaurants: List of restaurant data
        
    Returns:
        Formatted string describing the restaurants
    """
    if not restaurants:
        return "a mysterious place where ancient flavors linger in the air"
    
    restaurant_descriptions = []
    for restaurant in restaurants[:5]:  # Limit to top 5 for LLM
        desc = f"{restaurant.name} ({restaurant.type}, {restaurant.rating}⭐)"
        if restaurant.price_level:
            desc += f" - {restaurant.price_level}"
        restaurant_descriptions.append(desc)
    
    return ", ".join(restaurant_descriptions)


async def analyze_food_intent(question: str) -> Dict[str, Any]:
    """
    Analyze the user's question to determine if it's food-related and extract search intent.
    
    Args:
        question: The user's question
        
    Returns:
        Dict with 'is_food_related', 'search_query', and 'intent' keys
    """
    try:
        from services.llm_service import get_llm_response
        
        analysis_prompt = f"""
        Analyze this question and determine:
        1. Is it food-related? (yes/no)
        2. If yes, what should I search for? (extract search terms for finding restaurants/food)
        3. What's the user's intent? (summarize what they want)
        
        Question: "{question}"
        
        Respond in this exact JSON format:
        {{
            "is_food_related": true/false,
            "search_query": "search terms for restaurants",
            "intent": "brief description of what user wants"
        }}
        """
        
        response = get_llm_response(analysis_prompt)
        
        # Try to parse the JSON response
        try:
            # Clean up the response to extract JSON
            response_clean = response.strip()
            if response_clean.startswith("```json"):
                response_clean = response_clean[7:]
            if response_clean.endswith("```"):
                response_clean = response_clean[:-3]
            
            analysis = json.loads(response_clean)
            
            return {
                "is_food_related": analysis.get("is_food_related", False),
                "search_query": analysis.get("search_query", "restaurants"),
                "intent": analysis.get("intent", "seeking food guidance")
            }
            
        except json.JSONDecodeError:
            print(f"Failed to parse LLM analysis as JSON: {response}")
            # Fallback: assume it's food-related if it contains food keywords
            food_keywords = ["food", "eat", "restaurant", "hungry", "meal", "lunch", "dinner", "breakfast", "cuisine"]
            is_food_related = any(keyword in question.lower() for keyword in food_keywords)
            
            return {
                "is_food_related": is_food_related,
                "search_query": "restaurants",
                "intent": "seeking food guidance"
            }
            
    except Exception as e:
        print(f"Error in food intent analysis: {str(e)}")
        # Safe fallback
        return {
            "is_food_related": True,  # Assume food-related to avoid annoyed responses
            "search_query": "restaurants",
            "intent": "seeking mystical food wisdom"
        }
