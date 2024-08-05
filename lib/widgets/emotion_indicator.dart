import 'package:flutter/material.dart';

// This widget displays a colored square around the face based on the emotion detected.

class EmotionIndicator extends StatelessWidget {
  final double emotionLevel; // Represents the sentiment score (0.0 - 1.0)
  final String emotionLabel; // Represents the detected emotion as a label (e.g., "Happy", "Sad", "Neutral")

  EmotionIndicator({required this.emotionLevel, required this.emotionLabel});

  @override
  Widget build(BuildContext context) {
    Color indicatorColor;

    if (emotionLevel > 0.7) {
      indicatorColor = Colors.green; // Positive emotion
    } else if (emotionLevel > 0.4) {
      indicatorColor = Colors.yellow; // Neutral emotion
    } else {
      indicatorColor = Colors.red; // Negative emotion
    }

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: indicatorColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(66, 54, 53, 53),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Emotion: $emotionLabel',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          SizedBox(height: 8.0),
          Text(
            'Emotion Level: ${emotionLevel.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
