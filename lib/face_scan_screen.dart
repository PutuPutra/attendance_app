import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'l10n/app_localizations.dart';

class FaceScanScreen extends StatefulWidget {
  final String type;
  final List<CameraDescription> cameras;

  const FaceScanScreen({super.key, required this.type, required this.cameras});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  bool _isDetecting = false;
  String? _status;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      if (widget.cameras.isEmpty) {
        return;
      }
      final frontCamera = widget.cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => widget.cameras.first,
      );
      _controller = CameraController(frontCamera, ResolutionPreset.high);
      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      setState(() {}); // Refresh UI setelah init
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _detectFaces(BuildContext context) async {
    if (_isDetecting || _controller == null) return;
    _isDetecting = true;

    final localizations = AppLocalizations.of(context)!;

    try {
      final image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await _faceDetector.processImage(inputImage);

      setState(() {
        if (faces.isNotEmpty) {
          _status = localizations.faceDetectedSuccess(widget.type);
        } else {
          _status = localizations.noFaceDetected;
        }
      });
    } catch (e) {
      setState(() {
        _status = localizations.error(e.toString());
      });
    } finally {
      _isDetecting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(localizations.faceScanTitle(widget.type))),
        body: Center(
          child: Text(
            widget.cameras.isEmpty
                ? localizations.noCameraAvailable
                : localizations.cameraInitFailed(_errorMessage!),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(localizations.faceScanTitle(widget.type))),
      body: _initializeControllerFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      localizations.error(snapshot.error.toString()),
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.done &&
                    _controller != null) {
                  return Column(
                    children: [
                      Expanded(child: CameraPreview(_controller!)),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _status ?? localizations.pointCameraToFace,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _detectFaces(context),
                        child: Text(localizations.scanFace),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
    );
  }
}
