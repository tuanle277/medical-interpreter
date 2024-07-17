import 'package:flutter/material.dart';
import 'interpreter_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Interpreter'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Start Interpreter'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InterpreterScreen()),
            );
          },
        ),
      ),
    );
  }
}
