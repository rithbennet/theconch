### **TheConch Backend: Hackathon-Optimized Task List**

This revised plan prioritizes deploying a working, mock API to unblock the frontend team immediately, then building the real services behind the scenes.

### **Phase 1: Mock API & Immediate Deployment (Goal: Unblock Frontend in < 1 Hour)**

**Objective:** Get a live, public URL with the correct API "shape" into the hands of the frontend team.

- [ ] **Setup (15 mins):**

  - [ ] Create the project directory, `venv`, `requirements.txt`, and `.gitignore`.
  - [ ] `pip install` only `fastapi`, `uvicorn`, and `python-dotenv`.
  - [ ] Create the `.env` file (can be empty for now).
  - [ ] Add one placeholder `.mp3` file to `audio/placeholder.mp3`.

- [ ] **Create Mock API (`main.py`) (30 mins):**

  - [ ] Define the Pydantic models (`FoodQuestion`, `OpenQuestion`) at the top of `main.py`.
  - [ ] Implement all three endpoints (`/api/classic`, `/api/what-to-eat`, `/api/ask-anything`).
  - **Crucial:** In the `POST` endpoints, simply `print()` the incoming request data to verify it's being received correctly.
  - **Crucial:** Make **every** endpoint return an immediate `FileResponse` pointing to your single `audio/placeholder.mp3`.

- [ ] **Deploy & Share (15 mins):**
  - [ ] Run the server: `uvicorn main:app --reload`.
  - [ ] Expose the server: `ngrok http 8000`.
  - [ ] **CRITICAL FINAL STEP:** Share the public `ngrok` URL with the frontend team. They are now unblocked.

---

### **Phase 2: Real Service Implementation (Parallel Work: 1-2 Hours)**

**Objective:** Build the real logic in separate service files while the frontend team works against your mock API.

- [ ] **Update Dependencies:**

  - [ ] Add `google-generativeai`, `elevenlabs`, and `google-search-results-serpapi` to `requirements.txt` and install them.
  - [ ] Populate your `.env` file with the real API keys.

- [ ] **Scraping Service (`services/scraping_service.py`):**

  - [ ] Implement `find_restaurants_near(lat, lon)` using SerpApi.
  - [ ] Add basic error handling (return a fallback string like `"a mysterious place"` on failure).

- [ ] **LLM Service (`services/llm_service.py`):**

  - [ ] Implement `get_food_suggestion_text(restaurant_list)` with the "ignore" prompt.
  - [ ] Implement `get_cryptic_answer_text(question)` with the "proverb" prompt.

- [ ] **TTS Service (`services/tts_service.py`):**
  - [ ] Implement `generate_audio_from_text(text, output_filename)`.
  - [ ] Use `os.makedirs('audio/generated', exist_ok=True)` to ensure the output directory exists.
  - **Pro-tip:** For caching, a simple `if os.path.exists(filepath): return filepath` check is faster to implement than a hash and is perfect for a hackathon.

---

### **Phase 3: Integration & Live Logic (1-2 Hours)**

**Objective:** Swap the mock logic in `main.py` with the real service calls.

- [ ] **Refactor `main.py`:**

  - [ ] Add `import` statements for all your new services.
  - [ ] Move Pydantic models to `models/request_models.py` if desired for cleanliness.

- [ ] **Integrate `/api/what-to-eat`:**

  - [ ] Call `scraping_service.find_restaurants_near()`.
  - [ ] Pass the result to `llm_service.get_food_suggestion_text()`.
  - [ ] Pass the LLM text to `tts_service.generate_audio_from_text()`.
  - [ ] Return a `FileResponse` with the path to the newly generated audio.

- [ ] **Integrate `/api/ask-anything`:**

  - [ ] Call `llm_service.get_cryptic_answer_text()`.
  - [ ] Pass the result to `tts_service.generate_audio_from_text()`.
  - [ ] Return the `FileResponse`.

- [ ] **Add Robust Error Handling:**
  - [ ] Wrap the logic in your main endpoints with `try...except` blocks.
  - [ ] Return a `fastapi.HTTPException` with a status code like `500` if any service fails.

---

### **Phase 4: End-to-End Testing & Handoff (0.5-1 Hour)**

**Objective:** Verify the fully integrated system and ensure a smooth handoff to the frontend team.

- [ ] Open the browser to the auto-generated `/docs` page.
- [ ] **Test All Endpoints Thoroughly:**
  - [ ] Test `/api/classic` (should still be fast).
  - [ ] Test `/api/what-to-eat` with valid coordinates and check the server logs to see the full process.
  - [ ] Test `/api/ask-anything` with a sample question.
  - [ ] Test endpoints with invalid data (e.g., missing fields) to ensure your `HTTPException` handling works.
- [ ] **Final Step:** Notify the frontend team that "V2 of the API is live" at the **same `ngrok` URL**. The real, dynamic responses should now be flowing into their already-built app.
