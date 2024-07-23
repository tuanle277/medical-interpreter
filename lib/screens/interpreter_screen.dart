import 'package:flutter/material.dart';
import '../widgets/camera_view.dart';
import '../widgets/understanding_indicator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class InterpreterScreen extends StatefulWidget {
  @override
  _InterpreterScreenState createState() => _InterpreterScreenState();
}

class _InterpreterScreenState extends State<InterpreterScreen> {
  double understandingLevel = 0.0;
  List<Face> faces = [];
  bool isListening = false;
  late stt.SpeechToText _speech;
  String _speechText = '';
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _updateUnderstandingLevel(double newLevel) {
    setState(() {
      understandingLevel = newLevel;
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

  void _sendSpeechForTranslation(String speechText) async {
    // Replace 'your_backend_ip' with the actual IP address of your backend server
    final response = await http.post(
      Uri.parse('http://your_backend_ip:5000/interpret'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'speech_text': speechText}),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      _updateUnderstandingLevel(double.parse(result['understanding'] ?? '0.0'));
      _addMessage('Interpreter', result['translation'] ?? '');
    }
  }

  void _addMessage(String sender, String text) {
    setState(() {
      _messages.add(ChatMessage(sender: sender, text: text));
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: CameraView(
                        customPaint: CustomPaint(
                          painter: FacePainter(faces, understandingLevel),
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

                            // Replace 'your_backend_ip' with the actual IP address of your backend server
                            final response = await http.post(
                              Uri.parse('http://your_backend_ip:5000/analyze'),
                              headers: {'Content-Type': 'application/octet-stream'},
                              body: bytes,
                            );

                            if (response.statusCode == 200) {
                              final result = json.decode(response.body);
                              _updateUnderstandingLevel(double.parse(result['understanding'] ?? '0.0'));
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
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(16.0),
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
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 32.0),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: _messages.map((message) => _buildChatBubble(message)).toList(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(isListening ? Icons.mic : Icons.mic_none, color: Colors.teal, size: 40),
                          onPressed: isListening ? _stopListening : _startListening,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),

            child: UnderstandingIndicator(understandingLevel: understandingLevel),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    bool isUser = message.sender == 'You';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: const TextStyle(fontSize: 16, color: Colors.black),
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
