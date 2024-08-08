from dotenv import load_dotenv
import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from camera import Camera
from translation import translate_text
from gemini import GeminiClient
from concurrent.futures import ThreadPoolExecutor
from functools import lru_cache

load_dotenv()

app = Flask(__name__)
CORS(app)

visual_context_global = "neutral"

# Initialize the camera and Gemini client
camera = Camera()
gemini_client = GeminiClient()
executor = ThreadPoolExecutor()

@app.route('/interpret', methods=['POST'])
def interpret():
    data = request.get_json()  # No need to await this, it's synchronous
    speech_text = data['speech_text']

    # Use cached translation if available
    translation = executor.submit(cached_translate_text, speech_text, visual_context_global).result()
    print(f"Original text: {speech_text}, translated text: {translation}")

    return jsonify({"translation": translation})

@app.route('/analyze', methods=['POST'])
def analyze():
    image_bytes = request.data  # This is synchronous as well
    with open('temp_image.jpg', 'wb') as f:
        f.write(image_bytes)

    # Run emotion analysis asynchronously
    understanding = executor.submit(gemini_client.get_understanding, 'temp_image.jpg').result()
    
    # Update visual context asynchronously
    executor.submit(update_visual_context, understanding)
    
    return jsonify({'understanding': understanding})

@app.route('/summarize', methods=['POST'])
def summarize():
    data = request.get_json()
    conversation = data['conversation']

    # Summarize conversation asynchronously
    summary = executor.submit(gemini_client.summarize_conversation, conversation).result()
    
    return jsonify({'summary': summary})

@app.route('/diagnose', methods=['POST'])
def diagnose():
    data = request.get_json()
    conversation = data['conversation']

    # Diagnose conversation asynchronously
    diagnostics = executor.submit(gemini_client.real_time_diagnostics, conversation).result()
    
    return jsonify({'diagnostics': diagnostics})

@lru_cache(maxsize=100)
def cached_translate_text(text, visual_context):
    # Translate using the API and cache the result
    return translate_text(text, visual_context)

def update_visual_context(understanding):
    global visual_context_global
    visual_context_global = understanding if understanding else "neutral"

if __name__ == '__main__':
    # Start the visual analysis thread
    camera.start_capture(update_visual_context)
    app.run(debug=True)
