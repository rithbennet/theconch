# TheConch Super App - Backend

### The Over-Engineed Brain of Profound Nonsense

This repository contains the server-side application for TheConch Super App. It's a Python backend built with FastAPI that serves as the core logic engine, handling requests from the mobile app, interfacing with various AI and data services, and ultimately producing beautifully spoken, unhelpful advice.

---

## ✨ Core Responsibilities

- **Receive Requests:** Listens for HTTP requests from the Flutter mobile app.
- **Process Logic:** Orchestrates calls to external APIs for AI-powered tasks.
- **Scrape Data:** Fetches real-world location data (only to ignore it).
- **Generate Audio:** Converts AI-generated text into high-quality speech.
- **Serve Responses:** Delivers the final audio files back to the app.

## ⚙️ Tech Stack

- **Framework:** [FastAPI](https://fastapi.tiangolo.com/)
- **Language:** Python 3.10+
- **AI Text Generation:** [Google Gemini API](https://ai.google.dev/)
- **AI Voice Synthesis:** [ElevenLabs API](https://elevenlabs.io/)
- **Web Scraping:** [SerpApi](https://serpapi.com/) for reliable Google Local results.
- **Environment:** `python-dotenv` for managing secrets.
- **Server:** `uvicorn` for ASGI server implementation.

---

## 🚀 Setup and Installation

Follow these steps to get the backend server running locally.

### 1. Prerequisites

- Python 3.10 or newer
- `pip` package manager

### 2. Clone the Repository

```bash
git clone <your-repo-url>
cd theconch_backend
```

### 3. Set Up Virtual Environment

It is highly recommended to use a virtual environment.

```bash
# Create the virtual environment
python3 -m venv venv

# Activate it (macOS/Linux)
source venv/bin/activate

# Activate it (Windows)
# venv\Scripts\activate
```

### 4. Install Dependencies

```bash
pip install -r requirements.txt
```

### 5. Configure Environment Variables

You will need API keys for the services used.

1.  Make a copy of the example environment file:
    ```bash
    cp .env.example .env
    ```
2.  Open the `.env` file and add your secret keys:
    ```
    GEMINI_API_KEY="YOUR_GOOGLE_GEMINI_API_KEY"
    ELEVENLABS_API_KEY="YOUR_ELEVENLABS_API_KEY"
    SERPAPI_API_KEY="YOUR_SERPAPI_API_KEY"
    ```

### 6. Add Static Audio Files

Ensure you have the pre-generated audio files for the Classic Conch feature placed in the correct directory:

- `audio/classic/yes.mp3`
- `audio/classic/no.mp3`
- `audio/classic/maybe_someday.mp3`
- ...etc.

---

## 🏃 Running the Server

### Local Development

To run the server with live reloading (restarts automatically on code changes):

```bash
uvicorn main:app --reload
```

The server will be running at `http://127.0.0.1:8000`.

### Interactive API Docs

Once the server is running, navigate to **`http://127.0.0.1:8000/docs`** in your browser to access the interactive API documentation (powered by Swagger UI). You can test all endpoints directly from this page.

### Hackathon Deployment (ngrok)

To expose your local server to the internet for the Flutter app to connect to:

1.  Make sure the `uvicorn` server is running.
2.  In a new terminal, run:
    ```bash
    ngrok http 8000
    ```
3.  `ngrok` will provide a public `https://...` forwarding URL. This is the base URL for your API.

---

## 🌐 API Endpoints

**Base URL:** The `ngrok` URL (e.g., `https://1a2b-3c4d-5e6f.ngrok-free.app`)

### 1. Classic Conch

- **Endpoint:** `GET /api/classic`
- **Request Body:** None
- **Success Response:** `200 OK` with an `audio/mpeg` file.

### 2. Culinary Oracle

- **Endpoint:** `POST /api/what-to-eat`
- **Request Body:**
  ```json
  {
    "latitude": 34.0522,
    "longitude": -118.2437
  }
  ```
- **Success Response:** `200 OK` with an `audio/mpeg` file.

### 3. Abyss of Ambiguity

- **Endpoint:** `POST /api/ask-anything`
- **Request Body:**
  ```json
  {
    "question": "Is getting bangs the answer?"
  }
  ```
- **Success Response:** `200 OK` with an `audio/mpeg` file.
