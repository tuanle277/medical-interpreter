from comet_ml import Experiment  # Import comet_ml first
import pandas as pd
from transformers import MBart50TokenizerFast, MBartTokenizer, MBartForConditionalGeneration, Seq2SeqTrainer, Seq2SeqTrainingArguments
from datasets import Dataset
import logging
import os
from transformers.utils.logging import enable_progress_bar
import torch
import numpy as np
from nltk.translate.bleu_score import sentence_bleu
import sacrebleu

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
enable_progress_bar()

experiment = Experiment(
    api_key=os.getenv("COMET_API_KEY"),
    project_name=os.getenv("COMET_PROJECT_NAME"),
    workspace=os.getenv("COMET_WORKSPACE")
)

# Log hyperparameters
hyperparams = {
    "model_name": "vinai/vinai-translate-vi2en-v2",
    "max_length": 512,
    "batch_size": 4,
    "learning_rate": 2e-5,
    "weight_decay": 0.01,
    "num_train_epochs": 3,
}
experiment.log_parameters(hyperparams)

# Load your dataset
train_df = pd.read_csv('data/train_medical_conversations.csv')  # Ensure this dataset has 'source' and 'target' columns
val_df = pd.read_csv('data/val_medical_conversations.csv')

logger.info("Datasets loaded successfully.")

# Verify data
if 'source' not in train_df.columns or 'target' not in train_df.columns:
    logger.error("Columns 'source' and 'target' are required in the dataset")
    raise ValueError("Columns 'source' and 'target' are required in the dataset")

# Load tokenizer and model
model_name = "vinai/vinai-translate-vi2en-v2"
tokenizer = MBartTokenizer.from_pretrained(model_name, src_lang="vi_VN", tgt_lang="en_XX")
model = MBartForConditionalGeneration.from_pretrained(model_name)

logger.info("Tokenizer and model loaded successfully.")

# Prepare the data
def preprocess_function(examples):
    inputs = examples['source']
    targets = examples['target']
    
    # Tokenize inputs and targets
    model_inputs = tokenizer(inputs, text_target=targets, max_length=512, truncation=True, padding="max_length", return_tensors="pt")

    return model_inputs

# Create dataset
train_dataset = Dataset.from_pandas(train_df[:1000])
val_dataset = Dataset.from_pandas(val_df[:1000])

logger.info("Datasets converted to Hugging Face Dataset objects.")

# Apply preprocessing function
tokenized_train = train_dataset.map(preprocess_function, batched=True)
tokenized_val = val_dataset.map(preprocess_function, batched=True)

logger.info("Datasets tokenized successfully.")

# Enhanced feedback simulation
def get_human_feedback(predicted_translation, reference_translation):
    # BLEU score
    bleu_score = sentence_bleu([reference_translation.split()], predicted_translation.split())
    
    # Adequacy and Fluency
    adequacy = len(set(predicted_translation.split()) & set(reference_translation.split())) / len(reference_translation.split())
    fluency = 1 - len(set(predicted_translation.split()) - set(reference_translation.split())) / len(predicted_translation.split())
    
    # Simulate human feedback as a combination of BLEU, adequacy, and fluency
    feedback_score = 0.5 * bleu_score + 0.25 * adequacy + 0.25 * fluency
    
    # Convert feedback score to feedback signal
    if feedback_score > 0.7:
        feedback = 1
    elif feedback_score < 0.3:
        feedback = -1
    else:
        feedback = 0
    
    return feedback

# Custom Seq2SeqTrainer class for RLHF
class RLHFSeq2SeqTrainer(Seq2SeqTrainer):
    def compute_loss(self, model, inputs, return_outputs=False):
        labels = inputs.get("labels")
        outputs = model(**inputs)
        logits = outputs.get("logits")
        
        # Calculate loss
        loss_fct = torch.nn.CrossEntropyLoss(ignore_index=tokenizer.pad_token_id)
        loss = loss_fct(logits.view(-1, model.config.vocab_size), labels.view(-1))
        
        # Get human feedback and adjust loss
        predictions = torch.argmax(logits, dim=-1)
        for i, (pred, label) in enumerate(zip(predictions, labels)):
            pred_text = tokenizer.decode(pred, skip_special_tokens=True)
            label_text = tokenizer.decode(label, skip_special_tokens=True)
            feedback = get_human_feedback(pred_text, label_text)
            loss -= feedback * 0.1  # Adjust feedback impact as needed
        
        return (loss, outputs) if return_outputs else loss

# Training arguments
training_args = Seq2SeqTrainingArguments(
    output_dir='./results',
    eval_strategy='epoch',
    logging_strategy='steps',
    logging_steps=500,  # Reduce logging frequency
    learning_rate=hyperparams['learning_rate'],
    per_device_train_batch_size=hyperparams['batch_size'],
    per_device_eval_batch_size=hyperparams['batch_size'],
    weight_decay=hyperparams['weight_decay'],
    save_total_limit=3,
    num_train_epochs=hyperparams['num_train_epochs'],
    predict_with_generate=True,
    fp16=True,  # Use mixed precision training
    logging_dir='./logs',
    report_to="comet_ml",  # Log to Comet ML
    optim="adamw_torch"  # Use optimized AdamW optimizer
)

# Trainer
trainer = RLHFSeq2SeqTrainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_train,
    eval_dataset=tokenized_val,
    tokenizer=tokenizer
)

# Log training start
logger.info("Starting training...")
experiment.log_text("Starting training...")

# Fine-tune the model
trainer.train()

# Log training complete
logger.info("Training complete.")
experiment.log_text("Training complete.")

# Save the model
model.save_pretrained('fine-tuned-vinai-translate-vi2en-v2')
tokenizer.save_pretrained('fine-tuned-vinai-translate-vi2en-v2')

# Log model saving
logger.info("Model saved to 'fine-tuned-vinai-translate-vi2en-v2'")
experiment.log_text("Model saved to 'fine-tuned-vinai-translate-vi2en-v2'")
experiment.log_model("fine-tuned-vinai-translate-vi2en-v2", "fine-tuned-vinai-translate-vi2en-v2")
