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
                f"Based on the facial expression in this image, analyze the emotional tone of the person. Provide a number from 0 to 1, with 1 being very positive and 0 being very negative. Also, provide a brief summary of the person's emotional state.",
            ]
        )
        return response['content']

    def summarize_conversation(self, conversation):
        response = model.generate_content(
            [
                f"Here is a conversation: {conversation}. Please summarize the key points discussed in this conversation. The summary should be concise and capture all the important aspects.",
            ]
        )
        return response['content']

    def real_time_diagnostics(self, conversation):
        response = model.generate_content(
            [
                f"A patient mentioned the following symptoms in a conversation: {conversation}. Based on these symptoms, suggest potential conditions or diagnostic tests. Provide a list of possible diagnoses and tests.",
            ]
        )
        return response['content']

# # Example usage:
# gemini_client = GeminiClient()

# # Emotion Analysis Example
# emotion_response = gemini_client.get_understanding("path/to/image.jpg")
# print(emotion_response)

# # Summarization Example
# summary_response = gemini_client.summarize_conversation("Doctor: How are you feeling? Patient: I have a headache and feel nauseous.")
# print(summary_response)

# # Real-Time Diagnostics Example
# diagnostics_response = gemini_client.real_time_diagnostics("Patient: I have a headache and feel nauseous.")
# print(diagnostics_response)
