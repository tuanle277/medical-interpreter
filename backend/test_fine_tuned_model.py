from transformers import MBartForConditionalGeneration, MBart50TokenizerFast
import sacrebleu
import pandas as pd
from tqdm import tqdm
import logging
from comet_ml import Experiment  # Import comet_ml
import os

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Comet experiment
experiment = Experiment(
    api_key=os.getenv("COMET_API_KEY"),
    project_name=os.getenv("COMET_PROJECT_NAME"),
    workspace=os.getenv("COMET_WORKSPACE")
)

# Load the fine-tuned model
model_name = 'fine-tuned-vinai-translate-vi2en-v2'
tokenizer = MBart50TokenizerFast.from_pretrained(model_name)
model = MBartForConditionalGeneration.from_pretrained(model_name)

# Define language codes
src_lang = "vi_VN"
tgt_lang = "en_XX"

# Load the dataset
data = pd.read_csv('../../data/test_medical_conversations.csv')[:1000]

# Split the dataset into chunks
chunk_size = 200
chunks = [data[i:i + chunk_size] for i in range(0, len(data), chunk_size)]

def translate_text(text, src_lang, tgt_lang):
    tokenizer.src_lang = src_lang
    encoded_input = tokenizer(text, return_tensors="pt")
    generated_tokens = model.generate(**encoded_input, forced_bos_token_id=tokenizer.lang_code_to_id[tgt_lang])
    translation = tokenizer.batch_decode(generated_tokens, skip_special_tokens=True)[0]
    return translation

if __name__ == "__main__":
    for i, chunk in enumerate(chunks):
        logger.info(f"Starting the translation process for chunk {i + 1}...")
        experiment.log_text(f"Starting the translation process for chunk {i + 1}...")

        # Prepare the evaluation data
        source_texts = chunk['source'].tolist()
        reference_texts = chunk['target'].tolist()

        # Translate the source texts with a progress bar
        translated_texts = []
        for text in tqdm(source_texts, desc=f"Translating chunk {i + 1}"):
            translated_texts.append(translate_text(text, src_lang, tgt_lang))

        # Calculate BLEU score
        bleu = sacrebleu.corpus_bleu(translated_texts, [reference_texts])

        # Log BLEU score to Comet
        experiment.log_metric(f"BLEU score chunk {i + 1}", bleu.score)

        # Print a few example translations and log to Comet
        logger.info(f"Translation examples for chunk {i + 1}:")
        experiment.log_text(f"Translation examples for chunk {i + 1}:")
        for src, ref, trans in zip(source_texts[:5], reference_texts[:5], translated_texts[:5]):
            example_translation = f"\nSource (VI): {src}\nReference (EN): {ref}\nTranslated (EN): {trans}"
            print(example_translation)
            experiment.log_text(example_translation)

        # Print BLEU score
        print(f"\nBLEU score for chunk {i + 1}: {bleu.score}")
        logger.info(f"BLEU score for chunk {i + 1}: {bleu.score}")
        experiment.log_text(f"BLEU score for chunk {i + 1}: {bleu.score}")

        logger.info(f"Translation process for chunk {i + 1} complete.")
        experiment.log_text(f"Translation process for chunk {i + 1} complete.")