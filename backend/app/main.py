from dotenv import load_dotenv
import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from camera import Camera
from translation import translate_text
from gemini import GeminiClient

load_dotenv()

app = Flask(__name__)
CORS(app)

visual_context_global = "neutral"

# Initialize the camera
camera = Camera()

@app.route('/interpret', methods=['POST'])
def interpret():
    data = request.get_json()
    speech_text = data['speech_text']
    
    # Translate speech text
    visual_context = visual_context_global
    translation = translate_text(speech_text, visual_context)
    
    return jsonify({"translation": translation})

@app.route('/analyze', methods=['POST'])
def analyze():
    image_bytes = request.data
    with open('temp_image.jpg', 'wb') as f:
        f.write(image_bytes)
    gemini_client = GeminiClient()
    response = gemini_client.analyze('temp_image.jpg')
    understanding = gemini_client.get_understanding('temp_image.jpg')
    return jsonify({'understanding': understanding})

def update_visual_context(emotions, understanding):
    global visual_context_global
    visual_context_global = understanding if understanding else "neutral"

if __name__ == '__main__':
    # Start the visual analysis thread
    camera.start_capture(update_visual_context)
    app.run(debug=True)
