import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraView extends StatefulWidget {
  final CustomPaint? customPaint;
  final void Function(InputImage inputImage)? onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final void Function(CameraLensDirection direction)? onCameraLensDirectionChanged;

  CameraView({
    this.customPaint,
    this.onImage,
    this.onCameraFeedReady,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
  });

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
        _controller.startImageStream((CameraImage image) => _processImage(image));
      }
    });
  }

  void _processImage(CameraImage image) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();
      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        inputImageData: InputImageData(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          imageRotation: InputImageRotation.rotation0deg,
          inputImageFormat: InputImageFormat.nv21,
          planeData: image.planes.map(
            (Plane plane) {
              return InputImagePlaneMetadata(
                bytesPerRow: plane.bytesPerRow,
                height: plane.height,
                width: plane.width,
              );
            },
          ).toList(),
        ),
      );

      if (widget.onImage != null) {
        widget.onImage!(inputImage);
      }
    } catch (e) {
      print("Error processing image: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: <Widget>[
              CameraPreview(_controller),
              if (widget.customPaint != null) widget.customPaint!,
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final double understandingLevel;

  FacePainter(this.faces, this.understandingLevel);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    for (Face face in faces) {
      final rect = face.boundingBox;
      canvas.drawRect(rect, paint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Understanding: ${understandingLevel.toStringAsFixed(2)}',
          style: TextStyle(
            color: understandingLevel > 0.5 ? Colors.green : Colors.red,
            fontSize: 16.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, rect.topLeft);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.faces != faces || oldDelegate.understandingLevel != understandingLevel;
  }
}