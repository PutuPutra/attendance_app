import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'l10n/app_localizations.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class FaceScanScreen extends StatefulWidget {
  final String type;
  final List<CameraDescription> cameras;
  final User currentUser;

  const FaceScanScreen({
    super.key,
    required this.type,
    required this.cameras,
    required this.currentUser,
  });

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
  late bool isRegistration;

  @override
  void initState() {
    super.initState();
    isRegistration = widget.currentUser.faceImagePath == null;
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
    setState(() {
      _isDetecting = true;
    });

    final localizations = AppLocalizations.of(context)!;
    final userService = UserService();

    try {
      final image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        if (isRegistration) {
          final filePath = await userService.saveFaceImage(
            widget.currentUser.id,
            File(image.path),
          );
          final updatedUser = widget.currentUser.copyWith(
            faceImagePath: filePath,
          );
          await userService.updateUser(widget.currentUser.id, updatedUser);
          setState(() {
            _status = 'Face registered successfully';
            _isDetecting = false;
          });
        } else {
          setState(() {
            _status = 'Face detected for attendance';
            _isDetecting = false;
          });
        }
      } else {
        setState(() {
          _status = localizations.noFaceDetected;
          _isDetecting = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = localizations.error(e.toString());
        _isDetecting = false;
      });
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
                        onPressed: () async => await _detectFaces(context),
                        child: Text(
                          isRegistration
                              ? 'Register Face'
                              : localizations.scanFace,
                        ),
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
