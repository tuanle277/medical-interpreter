// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'package:medical_interpreter_new/lib/screens/interpreter_screen.dart';  // Adjust the import according to your project structure

// // Generate a MockClient using the Mockito package.
// // Create a new file called `interpreter_screen_test.mocks.dart` with the command:
// // `flutter pub run build_runner build`
// @GenerateMocks([http.Client])
// void main() {
//   group('API Tests', () {
//     test('Test /interpret endpoint', () async {
//       final client = MockClient();

//       // Mock the HTTP response for the /interpret endpoint
//       when(client.post(
//         Uri.parse('http://your_backend_ip:5000/interpret'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'speech_text': 'Hello, how are you?'}),
//       )).thenAnswer((_) async => http.Response(
//           json.encode({'translation': 'Bonjour, comment ça va?', 'understanding': '0.8'}), 200));

//       final response = await client.post(
//         Uri.parse('http://your_backend_ip:5000/interpret'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'speech_text': 'Hello, how are you?'}),
//       );

//       expect(response.statusCode, 200);
//       final responseBody = json.decode(response.body);
//       expect(responseBody['translation'], 'Bonjour, comment ça va?');
//       expect(responseBody['understanding'], '0.8');
//     });

//     test('Test /analyze endpoint', () async {
//       final client = MockClient();

//       // Mock the HTTP response for the /analyze endpoint
//       when(client.post(
//         Uri.parse('http://your_backend_ip:5000/analyze'),
//         headers: {'Content-Type': 'application/octet-stream'},
//         body: anyNamed('body'),
//       )).thenAnswer((_) async => http.Response(
//           json.encode({'understanding': 'neutral'}), 200));

//       final testImageBytes = <int>[];  // Replace with actual byte data of a test image

//       final response = await client.post(
//         Uri.parse('http://your_backend_ip:5000/analyze'),
//         headers: {'Content-Type': 'application/octet-stream'},
//         body: testImageBytes,
//       );

//       expect(response.statusCode, 200);
//       final responseBody = json.decode(response.body);
//       expect(responseBody['understanding'], 'neutral');
//     });
//   });
// }
