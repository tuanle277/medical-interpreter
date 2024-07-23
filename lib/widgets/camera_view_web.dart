// import 'package:flutter/material.dart';
// import 'package:camera_web/camera_web.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// class CameraView extends StatefulWidget {
//   final CustomPaint? customPaint;
//   final void Function(InputImage inputImage)? onImage;
//   final VoidCallback? onCameraFeedReady;
//   final VoidCallback? onDetectorViewModeChanged;
//   final void Function(CameraLensDirection direction)? onCameraLensDirectionChanged;

//   CameraView({
//     this.customPaint,
//     this.onImage,
//     this.onCameraFeedReady,
//     this.onDetectorViewModeChanged,
//     this.onCameraLensDirectionChanged,
//   });

//   @override
//   _CameraViewState createState() => _CameraViewState();
// }

// class _CameraViewState extends State<CameraView> {
//   CameraController? _controller; // Made nullable
//   Future<void>? _initializeControllerFuture; // Made nullable

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   void _initializeCamera() async {
//     try {
//       final cameras = await availableCameras();
//       final firstCamera = cameras.first;

//       _controller = CameraController(
//         firstCamera,
//         ResolutionPreset.high,
//       );

//       // Wait for initialization before starting image stream
//       _initializeControllerFuture = _controller!.initialize();

//       if (mounted) {
//         setState(() {});
//         _controller!.startImageStream(_processImage);
//       }
//     } catch (e) {
//       // Handle errors gracefully
//       print('Error initializing camera: $e');
//       // Show an error message or take alternative action
//     }
//   }

//   void _processImage(CameraImage image) async {
//     try {
//       final WriteBuffer allBytes = WriteBuffer();
//       for (Plane plane in image.planes) {
//         allBytes.putUint8List(plane.bytes);
//       }
//       final bytes = allBytes.done().buffer.asUint8List();
//       final inputImage = InputImage.fromBytes(
//         bytes: bytes,
//         inputImageData: InputImageData(
//           size: Size(image.width.toDouble(), image.height.toDouble()),
//           imageRotation: InputImageRotation.rotation0deg,
//           inputImageFormat: InputImageFormat.nv21,
//           planeData: image.planes.map(
//             (Plane plane) {
//               return InputImagePlaneMetadata(
//                 bytesPerRow: plane.bytesPerRow,
//                 height: plane.height,
//                 width: plane.width,
//               );
//             },
//           ).toList(),
//         ),
//       );

//       if (widget.onImage != null) {
//         widget.onImage!(inputImage);
//       }
//     } catch (e) {
//       print("Error processing image: $e");
//     }
//   }

//   @override
//   void dispose() {
//     _controller?.dispose(); // Dispose when not needed
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<void>(
//       future: _initializeControllerFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return Stack(
//             children: <Widget>[
//               if (_controller != null) CameraPreview(_controller!),
//               if (widget.customPaint != null) widget.customPaint!,
//             ],
//           );
//         } else {
//           return Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
// }
