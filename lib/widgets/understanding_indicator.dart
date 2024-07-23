import 'package:flutter/material.dart';

// This for a square around the face

class UnderstandingIndicator extends StatelessWidget {
  final double understandingLevel;

  UnderstandingIndicator({required this.understandingLevel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
      color: understandingLevel > 0.5 ? Colors.green : Colors.red,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
      child: Text(
        'Understanding Level: ${understandingLevel.toStringAsFixed(2)}',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}

