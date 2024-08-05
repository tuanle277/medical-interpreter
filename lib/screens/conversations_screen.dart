import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detailed_conversation_screen.dart';

class ConversationsScreen extends StatefulWidget {
  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('conversations')
            .orderBy('timestamp', descending: true) // Ensure conversations are sorted
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Comprehensive Error Handling
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}'); // Log the error for debugging
            return Center(
              child: Text(
                'An error occurred while fetching conversations.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty Data Handling
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No conversations found.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final conversations = snapshot.data!.docs;

          // Debugging: Print the number of documents retrieved
          print('Conversations loaded: ${conversations.length}');

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final timestamp = (conversation['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              final understandingLevel = (conversation['understanding_level'] as num?)?.toDouble() ?? 0.0;
              final emotionSummary = conversation['emotion_summary'] ?? 'No emotion summary';
              final conversationSummary = conversation['conversation_summary'] ?? 'No conversation summary';

              // Debugging: Print each conversation's data
              print('Conversation: ${conversation.data()}');

              return ConversationCard(
                patientId: conversation['patient_id'] ?? 'Unknown ID',
                dateTime: timestamp,
                doctorId: conversation['doctor_id'] ?? 'Unknown Doctor',
                userMessage: conversation['user_message'] ?? 'No message',
                translatedMessage: conversation['translated_message'] ?? 'No translation',
                understandingLevel: understandingLevel,
                emotionSummary: emotionSummary,
                conversationSummary: conversationSummary,
              );
            },
          );
        },
      ),
    );
  }
}

class ConversationCard extends StatelessWidget {
  final String patientId;
  final DateTime dateTime;
  final String doctorId;
  final String userMessage;
  final String translatedMessage;
  final double understandingLevel;
  final String emotionSummary;
  final String conversationSummary;

  ConversationCard({
    required this.patientId,
    required this.dateTime,
    required this.doctorId,
    required this.userMessage,
    required this.translatedMessage,
    required this.understandingLevel,
    required this.emotionSummary,
    required this.conversationSummary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedConversationScreen(
              patientId: patientId,
              dateTime: dateTime,
              doctorId: doctorId,
              userMessage: userMessage,
              translatedMessage: translatedMessage,
              understandingLevel: understandingLevel,
              emotionSummary: emotionSummary,
              conversationSummary: conversationSummary,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient ID: $patientId', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Date: ${dateTime.toLocal()}'.split('.')[0]),
              Text('Doctor ID: $doctorId'),
              const SizedBox(height: 8.0),
              Text('User Message: $userMessage'),
              Text('Translated Message: $translatedMessage'),
              const SizedBox(height: 8.0),
              Text('Understanding Level: $understandingLevel'),
              const SizedBox(height: 8.0),
              Text('Emotion Summary: $emotionSummary'), // Display emotion summary
              const SizedBox(height: 8.0),
              Text('Conversation Summary: $conversationSummary'), // Display conversation summary
            ],
          ),
        ),
      ),
    );
  }
}
