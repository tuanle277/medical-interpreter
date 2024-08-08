import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detailed_conversation_screen.dart';

class ConversationsScreen extends StatefulWidget {
  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> conversations = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    try {
      final querySnapshot = await _firestore
          .collection('conversations')
          .orderBy('timestamp', descending: true)
          .get();
      setState(() {
        conversations = querySnapshot.docs;
        isLoading = false;
      });

      // Debugging: Print the number of documents retrieved
      print('Conversations loaded: ${conversations.length}');
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred while fetching conversations.';
        isLoading = false;
      });
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              : conversations.isEmpty
                  ? const Center(
                      child: Text(
                        'No conversations found.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        final timestamp =
                            (conversation['timestamp'] as Timestamp?)?.toDate() ??
                                DateTime.now();
                        final understandingLevel =
                            (conversation['understanding_level'] as num?)?.toDouble() ?? 0.0;
                        final emotionSummary =
                            conversation['emotion_summary'] ?? 'No emotion summary';
                        final translatedMessage =
                            conversation['translated_message'] ?? 'No translated message';
                        final userMessage =
                            conversation['user_message'] ?? 'No user message';
                        final summary =
                            conversation['summary'] ?? 'No summary';
                        final diagnostics =
                            conversation['diagnostics'] ?? 'No diagnostics';
                        final doctorId =
                            conversation['doctor_id'] ?? 'Unknown Doctor';
                        final patientId =
                            conversation['patient_id'] ?? 'Unknown Patient';

                        // Debugging: Print each conversation's data
                        print('Conversation: ${conversation.data()}');

                        return ConversationCard(
                          patientId: patientId,
                          dateTime: timestamp,
                          doctorId: doctorId,
                          userMessage: userMessage,
                          translatedMessage: translatedMessage,
                          understandingLevel: understandingLevel,
                          emotionSummary: emotionSummary,
                          conversationSummary: summary,
                          diagnostics: diagnostics,
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
  final String diagnostics;

  ConversationCard({
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
              diagnostics: diagnostics,
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
              Text('Emotion Summary: $emotionSummary'),
              const SizedBox(height: 8.0),
              Text('Conversation Summary: $conversationSummary'),
              const SizedBox(height: 8.0),
              Text('Diagnostics: $diagnostics'),
            ],
          ),
        ),
      ),
    );
  }
}
