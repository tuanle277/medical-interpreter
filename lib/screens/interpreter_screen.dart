import 'package:flutter/material.dart';
import '../widgets/camera_view.dart';
import '../widgets/understanding_indicator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart'; // Import for glowing avatar

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
    debugPrint("Debug time");
    _sendSpeechForTranslation("Translate this for debugging");
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
    debugPrint("This is the original text " + speechText);
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/interpret'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'speech_text': speechText}),
    );

    debugPrint("This is what we want to know " + response.statusCode.toString());
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final padding = mediaQuery.padding;

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
                              Uri.parse('http://127.0.0.1:5000/analyze'),
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
                        AvatarGlow(  // Glowing avatar for the microphone
                          // endRadius: screenWidth * 0.1, // Adjust the radius as needed
                          glowColor: Colors.teal,
                          child: CircleAvatar(
                            radius: screenWidth * 0.03, // Adjust the radius as needed
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
            child: UnderstandingIndicator(understandingLevel: understandingLevel),
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
