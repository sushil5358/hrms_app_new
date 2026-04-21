import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/faceservice.dart';


class FaceScanScreen extends StatefulWidget {
  final String mode; // 'register' or 'attendance'
  final String? employeeId;
  final String? employeeName;
  final Function(Map<String, dynamic>)? onAttendanceVerified;

  const FaceScanScreen({
    super.key,
    required this.mode,
    this.employeeId,
    this.employeeName,
    this.onAttendanceVerified,
  });

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  CameraController? _controller;
  late FaceDetector _faceDetector;
  final FaceRecognitionService _faceService = FaceRecognitionService();

  bool _processing = false;
  bool _faceFound = false;
  bool _isSaving = false;
  String _statusMessage = "Position your face in the frame";
  int _captureCount = 0;
  final int _requiredCaptures = 3; // For registration, capture multiple samples

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableLandmarks: true,
        enableContours: true,
      ),
    );
    _initCamera();
    _initService();
  }

  Future<void> _initService() async {
    await _faceService.initDatabase();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();

      final front = cams.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );

      _controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup:
        Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      if (!mounted) return;

      await _controller!.startImageStream(_processCameraImage);
      setState(() {});
    } catch (e) {
      _showErrorDialog('Camera Error', 'Failed to initialize camera: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_processing || _faceFound || _isSaving) return;
    _processing = true;

    try {
      final inputImage = _toInputImage(image, _controller!);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        // Check face quality (simple check - face should be well-centered and sized)
        final face = faces.first;
        final boundingBox = face.boundingBox;

        // Basic quality check: face should cover at least 15% of the frame
        final frameArea = image.width * image.height;
        final faceArea = boundingBox.width * boundingBox.height;

        if (faceArea / frameArea > 0.15) {
          _faceFound = true;
          await _controller?.stopImageStream();

          // Capture the face image
          await _captureFaceImage();
        } else {
          setState(() {
            _statusMessage = "Move closer to camera";
          });
        }
      } else {
        setState(() {
          _statusMessage = "No face detected";
        });
      }
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      _processing = false;
    }
  }

  Future<void> _captureFaceImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      setState(() {
        _isSaving = true;
        _statusMessage = widget.mode == 'register'
            ? "Capturing face sample ${_captureCount + 1}/$_requiredCaptures"
            : "Verifying face...";
      });

      // Capture image
      final XFile picture = await _controller!.takePicture();
      final File imageFile = File(picture.path);

      if (widget.mode == 'register') {
        // Register new employee
        if (widget.employeeId != null && widget.employeeName != null) {
          _captureCount++;

          // First capture - register the face
          final success = await _faceService.registerEmployeeFace(
            widget.employeeId!,
            widget.employeeName!,
            imageFile,
          );

          if (success && mounted) {
            if (_captureCount < _requiredCaptures) {
              // Continue capturing more samples
              setState(() {
                _faceFound = false;
                _isSaving = false;
              });
              await _controller?.startImageStream(_processCameraImage);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Sample $_captureCount/$_requiredCaptures captured. Please look at camera again."),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              // All samples captured
              _showSuccessDialog(
                'Registration Successful',
                'Face registered successfully for ${widget.employeeName}',
              );
            }
          } else {
            _showErrorDialog('Registration Failed', 'Failed to register face. Please try again.');
          }
        }
      } else {
        // Attendance punch in/out
        final verification = await _faceService.verifyFace(imageFile);

        if (verification != null && mounted) {
          // Successfully verified
          widget.onAttendanceVerified?.call({
            'success': true,
            'employeeId': verification['id'],
            'employeeName': verification['name'],
            'similarity': verification['similarity'],
          });

          Navigator.pop(context, {
            'success': true,
            'employeeId': verification['id'],
            'employeeName': verification['name'],
            'similarity': verification['similarity'],
          });
        } else {
          _showErrorDialog(
            'Verification Failed',
            'No matching face found. Please try again or contact HR.',
          );
        }
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to process face: $e');
    } finally {
      if (mounted && widget.mode == 'attendance') {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputImage _toInputImage(CameraImage image, CameraController controller) {
    // Get image rotation
    final rotation = InputImageRotationValue.fromRawValue(
      controller.description.sensorOrientation,
    ) ?? InputImageRotation.rotation0deg;

    // Get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.nv21;

    // Combine all planes into one bytes array
    final bytes = _concatenatePlanes(image.planes);

    // Create metadata
    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = <int>[];
    for (final plane in planes) {
      allBytes.addAll(plane.bytes);
    }
    return Uint8List.fromList(allBytes);
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.mode == 'attendance') {
                Navigator.pop(context);
              } else {
                setState(() {
                  _faceFound = false;
                  _isSaving = false;
                });
                _controller?.startImageStream(_processCameraImage);
              }
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                "Initializing camera...",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.mode == 'register' ? 'Face Registration' : 'Face Verification',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Camera preview
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize!.width,
                height: _controller!.value.previewSize!.height,
                child: CameraPreview(_controller!),
              ),
            ),
          ),

          // Dark overlay with cutout for face guide
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: CustomPaint(
              painter: FaceOverlayPainter(
                faceDetected: _faceFound,
                progress: _captureCount / _requiredCaptures,
              ),
              child: Container(),
            ),
          ),

          // Progress indicator for registration
          if (widget.mode == 'register')
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Capture Progress",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          _requiredCaptures,
                              (index) => Container(
                            width: 40,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: index < _captureCount
                                  ? Colors.green
                                  : Colors.grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$_captureCount of $_requiredCaptures samples",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Status message at bottom
          Positioned(
            left: 20,
            right: 20,
            bottom: 50,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: _faceFound ? Colors.green : Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isSaving)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    if (_isSaving) const SizedBox(width: 12),
                    Icon(
                      _faceFound ? Icons.face : Icons.face_retouching_off,
                      color: _faceFound ? Colors.green : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _faceFound ? Colors.green : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Instruction at top
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.mode == 'register'
                    ? "Position your face in the oval and hold still\nWe'll capture multiple angles for better recognition"
                    : "Position your face in the oval for verification",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for face overlay guide
class FaceOverlayPainter extends CustomPainter {
  final bool faceDetected;
  final double progress;

  FaceOverlayPainter({required this.faceDetected, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Draw semi-transparent overlay
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Calculate oval dimensions (centered, covering about 60% of screen)
    final double ovalWidth = size.width * 0.7;
    final double ovalHeight = size.height * 0.45;
    final Rect ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: ovalWidth,
      height: ovalHeight,
    );

    // Cut out the oval area (clear)
    canvas.save();
    canvas.clipPath(Path()..addOval(ovalRect));
    canvas.drawColor(Colors.transparent, BlendMode.clear);
    canvas.restore();

    // Draw oval border
    final borderPaint = Paint()
      ..color = faceDetected ? Colors.green : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawOval(ovalRect, borderPaint);

    // Draw progress indicator (if registering)
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = Colors.green.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      final progressRect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: ovalWidth * progress,
        height: ovalHeight * progress,
      );
      canvas.drawOval(progressRect, progressPaint);
    }

    // Draw corner guides
    final cornerPaint = Paint()
      ..color = faceDetected ? Colors.green : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(ovalRect.left, ovalRect.top + cornerLength),
      Offset(ovalRect.left, ovalRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(ovalRect.left, ovalRect.top),
      Offset(ovalRect.left + cornerLength, ovalRect.top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(ovalRect.right - cornerLength, ovalRect.top),
      Offset(ovalRect.right, ovalRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(ovalRect.right, ovalRect.top),
      Offset(ovalRect.right, ovalRect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(ovalRect.left, ovalRect.bottom - cornerLength),
      Offset(ovalRect.left, ovalRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(ovalRect.left, ovalRect.bottom),
      Offset(ovalRect.left + cornerLength, ovalRect.bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(ovalRect.right - cornerLength, ovalRect.bottom),
      Offset(ovalRect.right, ovalRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(ovalRect.right, ovalRect.bottom),
      Offset(ovalRect.right, ovalRect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}