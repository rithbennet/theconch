#!/usr/bin/env python3
"""
Quick test script for the Magic Conch API endpoints.
Run this after starting your FastAPI server with: uvicorn main:app --reload
"""

import requests
import json

BASE_URL = "http://localhost:8000"

def test_endpoints():
    print("🐚 Testing Magic Conch API Endpoints 🐚\n")
    
    # Test 1: Root endpoint
    print("1. Testing root endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/")
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.json()}\n")
    except Exception as e:
        print(f"   Error: {e}\n")
    
    # Test 2: Classic Conch (GET)
    print("2. Testing /api/classic (GET)...")
    try:
        response = requests.get(f"{BASE_URL}/api/classic")
        print(f"   Status: {response.status_code}")
        print(f"   Content-Type: {response.headers.get('content-type')}")
        print(f"   Content-Length: {len(response.content)} bytes\n")
    except Exception as e:
        print(f"   Error: {e}\n")
    
    # Test 3: Food suggestion (POST)
    print("3. Testing /api/what-to-eat (POST)...")
    try:
        data = {"constraint": "vegetarian"}
        response = requests.post(f"{BASE_URL}/api/what-to-eat", json=data)
        print(f"   Status: {response.status_code}")
        print(f"   Content-Type: {response.headers.get('content-type')}")
        print(f"   Content-Length: {len(response.content)} bytes\n")
    except Exception as e:
        print(f"   Error: {e}\n")
    
    # Test 4: Open question (POST)
    print("4. Testing /api/ask-anything (POST)...")
    try:
        data = {"question": "What is the meaning of life?"}
        response = requests.post(f"{BASE_URL}/api/ask-anything", json=data)
        print(f"   Status: {response.status_code}")
        print(f"   Content-Type: {response.headers.get('content-type')}")
        print(f"   Content-Length: {len(response.content)} bytes\n")
    except Exception as e:
        print(f"   Error: {e}\n")

if __name__ == "__main__":
    test_endpoints()
