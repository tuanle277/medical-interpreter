# Real-Time Medical Interpreter

## Overview

Real-Time Medical Interpreter is an advanced mobile application designed to facilitate seamless communication between doctors and patients who speak different languages. The app uses state-of-the-art AI technologies for real-time translation, emotion analysis, conversation summarization, and real-time diagnostics. It supports Vietnamese-English translations, making it a valuable tool for medical professionals working in multilingual environments.

## Features

### 1. Real-Time Translation
- **Bidirectional Translation**: Supports Vietnamese to English and English to Vietnamese translations.
- **Context-Aware Translation**: Incorporates visual cues and context to improve translation accuracy.

### 2. Emotion and Sentiment Analysis
- **Real-Time Emotion Detection**: Analyzes the facial expressions of both the doctor and the patient to determine the emotional tone.
- **Emotional Context**: Provides real-time feedback on the emotional state of the conversation, aiding doctors in adjusting their communication style accordingly.

### 3. Smart Summarization and Documentation
- **Automatic Summarization**: Generates a concise summary of the conversation, highlighting key points discussed.
- **Documentation**: Saves the summary and detailed conversation for future reference, which can be shared with other healthcare providers or the patient.

### 4. Real-Time Diagnostics and Suggestions
- **AI-Powered Diagnostics**: Analyzes the conversation to suggest potential diagnoses based on the symptoms mentioned.
- **Immediate Feedback**: Provides real-time suggestions for tests or treatments based on the ongoing conversation.

### 5. Firebase Integration
- **Cloud Storage**: All conversations, summaries, and emotion analyses are securely stored in Firebase Firestore.
- **Real-Time Sync**: Conversations are updated in real-time across all devices.

## Technical Details

### Backend
- **Flask**: The backend is powered by Flask, a lightweight web framework in Python.
- **Gemini AI**: Utilizes Google's Gemini API for advanced NLP and vision capabilities, including translation, emotion analysis, and diagnostics.
- **Asynchronous Processing**: The backend uses asynchronous processing to handle multiple requests concurrently, ensuring minimal latency.
- **In-Memory Caching**: Implements caching to speed up repeated translation requests.

### Frontend
- **Flutter**: The mobile application is built using Flutter, enabling cross-platform compatibility.
- **Speech Recognition**: Integrates `speech_to_text` for converting spoken language into text in real time.
- **Face Detection**: Uses Google ML Kit's Face Detection to analyze facial expressions during conversations.
- **Firebase Firestore**: For real-time database management and cloud storage of conversation data.

## Installation and Setup

### Prerequisites
- **Flutter**: Install Flutter SDK from [here](https://flutter.dev/docs/get-started/install).
- **Python**: Ensure you have Python 3.7 or above installed.
- **Node.js**: Required for Firebase Admin SDK.

### Backend Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/real-time-medical-interpreter.git
   cd real-time-medical-interpreter/backend
   ```
