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
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => isListening = true);
      _speech.listen(
        onResult: (val) => setState(() {
          _speechText = val.recognizedWords;
          if (val.hasConfidenceRating && val.confidence > 0) {
            // Process the recognized speech text
            _sendSpeechForTranslation(_speechText);
          }
        }),
      );
    }
  }

  void _stopListening() {
    setState(() => isListening = false);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interpreter'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                UnderstandingIndicator(understandingLevel: understandingLevel),
                SizedBox(height: 16.0),
                Text(
                  isListening ? 'Listening...' : 'Press the button to start listening',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                IconButton(
                  icon: Icon(isListening ? Icons.mic : Icons.mic_none),
                  onPressed: isListening ? _stopListening : _startListening,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
