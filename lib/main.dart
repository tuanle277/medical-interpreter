import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MedicalInterpreterApp());
}

class MedicalInterpreterApp extends StatelessWidget {
  const MedicalInterpreterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Interpreter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
