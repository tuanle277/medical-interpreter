import 'package:flutter/material.dart';
import '../widgets/camera_view.dart';
import '../widgets/emotion_indicator.dart'; // Updated to use EmotionIndicator
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InterpreterScreen extends StatefulWidget {
  @override
  _InterpreterScreenState createState() => _InterpreterScreenState();
}

class _InterpreterScreenState extends State<InterpreterScreen> {
  double emotionLevel = 0.0;  // Updated from understandingLevel
  String emotionLabel = 'Neutral';  // Added to represent the detected emotion
  List<Face> faces = [];
  bool isListening = false;
  late stt.SpeechToText _speech;
  String _speechText = '';
  final List<ChatMessage> _messages = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _updateEmotionLevel(double newLevel, String newLabel) {  // Updated to handle emotion
    setState(() {
      emotionLevel = newLevel;
      emotionLabel = newLabel;
    });
  }

  void _updateFaces(List<Face> newFaces) {
    setState(() {
      faces = newFaces;
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => debugPrint('onStatus: $val'),
      onError: (val) => debugPrint('onError: $val'),
    );
    if (available) {
      setState(() => isListening = true);
      _speech.listen(
        onResult: (val) => setState(() {
          _speechText = val.recognizedWords;
        }),
      );
    }
  }

  void _stopListening() {
    setState(() {
      isListening = false;
      if (_speechText.isNotEmpty) {
        _addMessage('You', _speechText);
        _sendSpeechForTranslation(_speechText);
      }
    });
    _speech.stop();
  }

  void _summarizeConversation() async {
    final conversation = _messages.map((msg) => "${msg.sender}: ${msg.text}").join("\n");
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/summarize'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'conversation': conversation}),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final summary = result['summary'];
      _addMessage('Summary', summary);
    }
  }

  void _diagnoseBasedOnSymptoms() async {
    final conversation = _messages.map((msg) => msg.text).join("\n");
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/diagnose'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'conversation': conversation}),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final diagnostics = result['diagnostics'];
      _addMessage('Diagnostics', diagnostics);
    }
  }

  void _sendSpeechForTranslation(String speechText) async {
    debugPrint("This is the original text " + speechText);
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/interpret'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'speech_text': speechText}),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      _updateEmotionLevel(double.parse(result['emotion_level'] ?? '0.0'), result['emotion_label'] ?? 'Neutral');
      _addMessage('Interpreter', result['translation'] ?? '');

      _diagnoseBasedOnSymptoms();
      _summarizeConversation();

      // Save conversation to Firestore
      await _firestore.collection('conversations').add({
        'patient_id': 'example_patient_id',
        'doctor_id': 'example_doctor_id',
        'user_message': speechText,
        'translated_message': result['translation'],
        'emotion_level': double.parse(result['emotion_level'] ?? '0.0'),
        'emotion_label': result['emotion_label'],
        'timestamp': Timestamp.now(),
      });
    }
  }

  void _addMessage(String sender, String text) {
    setState(() {
      _messages.add(ChatMessage(sender: sender, text: text));
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Interpreter: Vietnamese - English', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      child: CameraView(
                        customPaint: CustomPaint(
                          painter: FaceDetectorPainter(faces, Size(screenWidth, screenHeight)),
                        ),
                        onImage: (inputImage) async {
                          final faceDetector = FaceDetector(
                            options: FaceDetectorOptions(
                              enableContours: true,
                              enableClassification: true,
                            ),
                          );

                          final List<Face> detectedFaces = await faceDetector.processImage(inputImage);

                          if (detectedFaces.isNotEmpty) {
                            _updateFaces(detectedFaces);

                            // Convert inputImage to bytes for backend processing
                            final bytes = inputImage.bytes;

                            final response = await http.post(
                              Uri.parse('http://127.0.0.1:5000/analyze'),
                              headers: {'Content-Type': 'application/octet-stream'},
                              body: bytes,
                            );

                            if (response.statusCode == 200) {
                              final result = json.decode(response.body);
                              _updateEmotionLevel(double.parse(result['emotion_level'] ?? '0.0'), result['emotion_label'] ?? 'Neutral');
                            }
                          }

                          faceDetector.close();
                        },
                        onCameraFeedReady: () {},
                        onDetectorViewModeChanged: () {},
                        onCameraLensDirectionChanged: (direction) {},
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(screenWidth * 0.04),
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          isListening ? 'Listening...' : 'Press the button to start listening',
                          style: TextStyle(fontSize: screenWidth * 0.02, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: _messages.map((message) => _buildChatBubble(message, screenWidth)).toList(),
                            ),
                          ),
                        ),
                        AvatarGlow(
                          glowColor: Colors.teal,
                          child: CircleAvatar(
                            radius: screenWidth * 0.03,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(isListening ? Icons.mic : Icons.mic_none,
                                  color: Colors.teal,
                                  size: screenWidth * 0.04),
                              onPressed: isListening ? _stopListening : _startListening,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.06),
            child: EmotionIndicator(emotionLevel: emotionLevel, emotionLabel: emotionLabel), // Updated to use EmotionIndicator
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, double screenWidth) {
    bool isUser = message.sender == 'You';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
        padding: EdgeInsets.all(screenWidth * 0.02),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: TextStyle(fontSize: screenWidth * 0.02, color: Colors.black),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String sender;
  final String text;

  ChatMessage({required this.sender, required this.text});
}
