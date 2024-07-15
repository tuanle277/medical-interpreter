from transformers import MBartForConditionalGeneration, MBart50Tokenizer
from gemini import GeminiClient
import os

# Correctly define the model path
model_name = os.path.join(os.path.dirname(__file__), '../models/fine-tuned-vinai-translate-vi2en-v2')

tokenizer = MBart50Tokenizer.from_pretrained(model_name)
model = MBartForConditionalGeneration.from_pretrained(model_name)

gemini_client = GeminiClient()

def translate_text(text, visual_context):
    understanding_level = gemini_client.get_understanding(visual_context)
    input_ids = tokenizer.encode(f'translate Vietnamese to English with context: {text} Context: {understanding_level}', return_tensors='pt')
    outputs = model.generate(input_ids)
    translation = tokenizer.decode(outputs[0], skip_special_tokens=True)
    return translation
