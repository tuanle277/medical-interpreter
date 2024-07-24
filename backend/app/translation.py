import argparse
from transformers import MBartForConditionalGeneration, MBart50Tokenizer
from gemini import GeminiClient
import os

def translate_text(text, visual_context):
    model_name = "backend/models/fine-tuned-vinai-translate-vi2en-v2"
    tokenizer = MBart50Tokenizer.from_pretrained(model_name)
    model = MBartForConditionalGeneration.from_pretrained(model_name)
    # gemini_client = GeminiClient()
    
    # understanding_level = gemini_client.get_understanding(visual_context)
    input_ids = tokenizer.encode(f'translate Vietnamese to English with context: {text}', return_tensors='pt')
                                 
                                #  They are this much undestanding: {understanding_level}', 
    outputs = model.generate(input_ids)
    translation = tokenizer.decode(outputs[0], skip_special_tokens=True)
    return translation

def main():
    parser = argparse.ArgumentParser(description="Translate Vietnamese text to English with visual context")
    parser.add_argument('--model', type=str, required=True, help='The path to the model')    
    args = parser.parse_args()

    if args.model == "fine-tuned":
        translation = translate_text("../models/fine-tuned-vinai-translate-vi2en-v2", args.text, args.visual_context)
    elif args.model == "raw":
        translation = translate_text("vinai/vinai-translate-vi2en-v2", args.text, args.visual_context)
    else:
        raise NotImplementedError("Not implemented yet")
    
    print(f'Translation: {translation}')

if __name__ == '__main__':
    main()