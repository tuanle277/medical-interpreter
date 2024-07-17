import 'package:flutter/material.dart';

class UnderstandingIndicator extends StatelessWidget {
  final double understandingLevel;

  UnderstandingIndicator({required this.understandingLevel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: understandingLevel > 0.5 ? Colors.green : Colors.red,
      child: Text(
        'Understanding Level: ${understandingLevel.toStringAsFixed(2)}',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}
