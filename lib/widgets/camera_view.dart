import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:universal_io/io.dart' as io;

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
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<Face> _faces = [];
  double _understandingLevel = 0.0;
  String? _errorMessage; // To display camera initialization errors

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _controller?.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {});
        _controller?.startImageStream(_processImage);
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error initializing camera: $e";
      });
    }
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
    _controller?.dispose(); // Dispose when not needed
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
              if (_controller != null) CameraPreview(_controller!),
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

class FaceDetectorPainter extends CustomPainter {
  final List<Face> faces;
  final Size absoluteImageSize;
  final InputImageRotation imageRotation;

  FaceDetectorPainter(this.faces, this.absoluteImageSize, [this.imageRotation = InputImageRotation.rotation0deg]);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.greenAccent;

    for (final Face face in faces) {
      canvas.drawRect(
        _scaleRect(
          rect: face.boundingBox,
          imageSize: absoluteImageSize,
          widgetSize: size,
          rotation: imageRotation,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces; 
  }

  // Helper function to scale the bounding box to the widget size
  Rect _scaleRect({
    required Rect rect,
    required Size imageSize,
    required Size widgetSize,
    required InputImageRotation rotation,
  }) {
    // Adjust the rectangle based on the image rotation
    if (rotation == InputImageRotation.rotation90deg || rotation == InputImageRotation.rotation270deg) {
      final bufferHeight = imageSize.height;
      final bufferWidth = imageSize.width;
      imageSize = Size(bufferWidth, bufferHeight);
    }

    // Calculate scale factors
    final double scaleX = widgetSize.width / imageSize.width;
    final double scaleY = widgetSize.height / imageSize.height;

    return Rect.fromLTRB(
      rect.left.toDouble() * scaleX,
      rect.top.toDouble() * scaleY,
      rect.right.toDouble() * scaleX,
      rect.bottom.toDouble() * scaleY, 
    );
  }
}
