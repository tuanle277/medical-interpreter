from dotenv import load_dotenv
import os
import vertexai
from vertexai.generative_models import GenerativeModel, Part

load_dotenv()
gemini_api_key = os.getenv("GEMINI_API_KEY")
gemini_project_id = os.getenv("GEMINI_PROJECT_ID")
gemini_location = os.getenv("GEMINI_LOCATION")

vertexai.init(project=gemini_project_id, location=gemini_location)

model = GenerativeModel("gemini-1.5-flash-001")

class GeminiClient:
    def __init__(self):
        self.api_key = gemini_api_key
        self.gemini = model

    def get_understanding(self, image_path):
        response = model.generate_content(
            [
                Part.from_uri(
                    image_path,
                    mime_type="image/jpeg",
                ),
                f"Based on the facial expression in this image, What is the understanding level of the person shown in {image_path}? Provide an indicative number from 0 to 1, with 1 being very understood and 0 being not understood completely, return only the number, be as precise as possible, analyze every frame",
            ]
        )
        return response['content']

