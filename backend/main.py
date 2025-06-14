# main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

# Import configuration
from config.settings import settings

# Import route modules
from routes import classic_router, food_router, open_ended_router, voices_router, voices_router

# Create FastAPI application
app = FastAPI(
    title="TheConch API",
    description="The All-Knowing, All-Ignoring Magic Conch Backend",
    version="1.0.0"
)

# Mount the audio directory to serve static files
app.mount("/audio", StaticFiles(directory=settings.AUDIO_DIR), name="audio")

# Add CORS middleware for frontend access
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include all route modules
app.include_router(classic_router)
app.include_router(food_router)
app.include_router(open_ended_router)
app.include_router(voices_router)


@app.get("/")
def read_root():
    return {"Hello": "This is TheConch API"}
