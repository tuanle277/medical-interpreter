import 'package:flutter/material.dart';

class DetailedConversationScreen extends StatelessWidget {
  final String patientId;
  final DateTime dateTime;
  final String doctorId;
  final String userMessage;
  final String translatedMessage;
  final double understandingLevel;
  final String emotionSummary;
  final String conversationSummary;
  final String diagnostics;

  DetailedConversationScreen({
    required this.patientId,
    required this.dateTime,
    required this.doctorId,
    required this.userMessage,
    required this.translatedMessage,
    required this.understandingLevel,
    required this.emotionSummary,
    required this.conversationSummary,
    required this.diagnostics,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient ID: $patientId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8.0),
              Text('Date: ${dateTime.toLocal()}'.split('.')[0], style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8.0),
              Text('Doctor ID: $doctorId', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16.0),
              const Text('User Message:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(userMessage, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16.0),
              const Text('Translated Message:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(translatedMessage, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16.0),
              const Text('Understanding Level:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(understandingLevel.toString(), style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16.0),
              const Text('Emotion Summary:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(emotionSummary, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16.0),
              const Text('Conversation Summary:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(conversationSummary, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16.0),
              const Text('Diagnostics:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(diagnostics, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
