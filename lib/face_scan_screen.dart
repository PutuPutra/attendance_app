import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'l10n/app_localizations.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/face_recognition_service.dart';

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
      enableContours: false,
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.1,
    ),
  );
  final FaceRecognitionService _faceRecognitionService =
      FaceRecognitionService();
  bool _isProcessing = false;
  String? _status;
  String? _errorMessage;
  late bool isRegistration;
  List<List<double>> collectedEmbeddings = [];
  int _frameCount = 0;
  static const int _requiredEmbeddings =
      1; // Save immediately after first capture
  double _lastHeadYaw = 0.0;
  bool _headTurnDetected = false;
  bool _lookedLeft = false;
  bool _livenessVerified = false;
  User? _recognizedUser;

  @override
  void initState() {
    super.initState();
    isRegistration = widget.currentUser.faceEmbeddings == null;
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      // Initialize face recognition service first
      await _faceRecognitionService.initialize();
      // Then initialize camera
      await _initCamera();
    } catch (e) {
      setState(() {
        _errorMessage = 'Service initialization failed: ${e.toString()}';
      });
    }
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
      _controller = CameraController(frontCamera, ResolutionPreset.medium);
      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      _startImageStream();
      setState(() {});
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
    _faceRecognitionService.dispose();
    super.dispose();
  }

  bool _isFaceQualityGood(Face face) {
    // Check if face is facing camera (head angles small)
    final x = face.headEulerAngleX ?? 0.0;
    final y = face.headEulerAngleY ?? 0.0;
    final z = face.headEulerAngleZ ?? 0.0;
    if (x.abs() > 20 || y.abs() > 30 || z.abs() > 20) return false;

    // Check eyes open (relaxed threshold)
    final leftEye = face.leftEyeOpenProbability ?? 0.0;
    final rightEye = face.rightEyeOpenProbability ?? 0.0;
    if (leftEye < 0.3 || rightEye < 0.3) return false;

    return true;
  }

  bool _detectLiveness(Face face) {
    final leftEye = face.leftEyeOpenProbability ?? 1.0;

    // Detect eye blink (low probability indicates closed eye)
    if (leftEye < 0.5) {
      _lookedLeft = true; // Reuse variable for simplicity
    }

    // Liveness verified if user blinked
    _headTurnDetected = _lookedLeft;

    return _headTurnDetected;
  }

  void _showNameInputDialog(BuildContext context, User updatedUser) {
    final localizations = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: updatedUser.username);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.enterFaceName),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: localizations.faceName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              final userService = UserService();
              final userWithName = updatedUser.copyWith(
                faceName: nameController.text,
              );
              await userService.updateUser(userWithName.id, userWithName);
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Back to home
            },
            child: Text(localizations.save),
          ),
        ],
      ),
    );
  }

  Future<void> _detectFaces(BuildContext context) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    if (!isRegistration) {
      _livenessVerified = false;
      _headTurnDetected = false;
      _lookedLeft = false;
    }

    // Reset head movement detection for this scan attempt
    _lastHeadYaw = 0.0;

    try {
      // Take single picture for both detection and embedding
      final imageFile = await _controller!.takePicture();
      final inputImage = InputImage.fromFile(File(imageFile.path));

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;

        if (isRegistration) {
          if (_isFaceQualityGood(face)) {
            // Use same image for embedding extraction
            final embeddings = await _faceRecognitionService.extractEmbedding(
              File(imageFile.path),
            );
            if (embeddings != null) {
              collectedEmbeddings.add(embeddings);
              setState(() {
                _status = 'Face captured successfully! Saving data...';
              });
              if (collectedEmbeddings.length >= _requiredEmbeddings) {
                // Average embeddings (though we only have one)
                final averagedEmbeddings = _averageEmbeddings(
                  collectedEmbeddings,
                );
                final userService = UserService();
                final filePath = await userService.saveFaceImage(
                  widget.currentUser.id,
                  File(imageFile.path),
                );
                final updatedUser = widget.currentUser.copyWith(
                  faceImagePath: filePath,
                  faceEmbeddings: averagedEmbeddings,
                );
                await userService.updateUser(
                  widget.currentUser.id,
                  updatedUser,
                );
                _controller!.stopImageStream();
                setState(() {
                  _status =
                      'Face registered successfully! You can now use face recognition.';
                });
                // Navigate back after short delay
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                });
              }
            } else {
              setState(() {
                _status = 'Failed to process face. Please try again.';
              });
            }
          } else {
            setState(() {
              _status =
                  'Adjust face: ensure good lighting, face straight, eyes open.';
            });
          }
        } else {
          // Recognition - compare with all registered faces
          if (_isFaceQualityGood(face)) {
            // Extract embedding from same image
            final currentEmbeddings = await _faceRecognitionService
                .extractEmbedding(File(imageFile.path));
            if (currentEmbeddings != null) {
              // Load all users with face data
              final userService = UserService();
              final allUsers = await userService.loadUsers();
              final usersWithFaces = allUsers
                  .where(
                    (user) =>
                        user.faceEmbeddings != null &&
                        user.faceEmbeddings!.isNotEmpty,
                  )
                  .toList();

              // Find best match
              User? bestMatch;
              double bestSimilarity = 0.0;

              for (final user in usersWithFaces) {
                final similarity = _faceRecognitionService.cosineSimilarity(
                  user.faceEmbeddings!,
                  currentEmbeddings,
                );

                if (similarity > bestSimilarity) {
                  bestSimilarity = similarity;
                  bestMatch = user;
                }
              }

              if (bestSimilarity > 0.55) {
                // Match found - show user info and allow attendance recording
                setState(() {
                  _recognizedUser = bestMatch;
                  _status =
                      'Face recognized! ID: ${bestMatch!.id}, Name: ${bestMatch.faceName ?? bestMatch.username}. Tap "Record Attendance" to confirm.';
                });
              } else {
                setState(() {
                  _recognizedUser = null;
                  _status = 'Face not recognized. Please try again.';
                });
              }
            } else {
              setState(() {
                _status = 'Failed to process face. Please try again.';
              });
            }
          } else {
            setState(() {
              _status =
                  'Adjust face: ensure good lighting, face straight, eyes open.';
            });
          }
        }
      } else {
        setState(() {
          _status = 'No face detected. Point camera at your face.';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _recordAttendance() async {
    if (_recognizedUser == null) return;

    setState(() => _isProcessing = true);

    try {
      // Take attendance photo
      final imageFile = await _controller!.takePicture();
      final userService = UserService();
      await userService.recordAttendance(
        _recognizedUser!.id,
        widget.type,
        File(imageFile.path),
      );

      _controller!.stopImageStream();
      setState(() {
        _status = 'Attendance recorded successfully!';
      });

      // Show success message with date/time
      final now = DateTime.now();
      final dateTimeStr =
          '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance recorded at $dateTimeStr'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navigate back after short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      setState(() {
        _status = 'Error recording attendance: ${e.toString()}';
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _startImageStream() {
    _controller!.startImageStream((CameraImage image) async {
      if (_isProcessing) return;
      _frameCount++;
      if (_frameCount % 2 == 0 && !isRegistration && !_livenessVerified) {
        final inputImage = _inputImageFromCameraImage(image);
        if (inputImage != null) {
          final faces = await _faceDetector.processImage(inputImage);
          if (faces.isNotEmpty) {
            final face = faces.first;
            if (_isFaceQualityGood(face)) {
              _detectLiveness(face);
              if (_headTurnDetected) {
                setState(() => _livenessVerified = true);
              }
            }
          }
        }
      }
    });
  }

  List<double> _averageEmbeddings(List<List<double>> embeddingsList) {
    if (embeddingsList.isEmpty) return [];
    final length = embeddingsList.first.length;
    final averaged = List<double>.filled(length, 0.0);
    for (final emb in embeddingsList) {
      for (int i = 0; i < length; i++) {
        averaged[i] += emb[i];
      }
    }
    for (int i = 0; i < length; i++) {
      averaged[i] /= embeddingsList.length;
    }
    return averaged;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = sensorOrientation;
      if (_controller!.description.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + 180) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // For Android, use YUV_420_888 format directly
    if (Platform.isAndroid) {
      final format = InputImageFormat.yuv420;
      final yBuffer = image.planes[0].bytes;
      final uBuffer = image.planes[1].bytes;
      final vBuffer = image.planes[2].bytes;

      // Concatenate all planes for YUV_420_888
      final bytes = Uint8List.fromList(yBuffer + uBuffer + vBuffer);

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } else if (Platform.isIOS) {
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;
      final plane = image.planes.first;
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.faceScanTitle(widget.type)),
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  widget.cameras.isEmpty
                      ? localizations.noCameraAvailable
                      : localizations.cameraInitFailed(_errorMessage!),
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.faceScanTitle(widget.type)),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _initializeControllerFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            localizations.error(snapshot.error.toString()),
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.done &&
                    _controller != null) {
                  return SafeArea(
                    child: Column(
                      children: [
                        // Camera Preview with overlay
                        Expanded(
                          child: Stack(
                            children: [
                              CameraPreview(_controller!),
                              // Face detection overlay
                              if (_status != null &&
                                  _status!.contains('No face detected'))
                                Positioned(
                                  top: 50,
                                  left: 20,
                                  right: 20,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _status!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              // User info overlay for recognition
                              if (!isRegistration && _recognizedUser != null)
                                Positioned(
                                  bottom: 120,
                                  left: 20,
                                  right: 20,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Face Recognized!',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'ID: ${_recognizedUser!.id}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'Name: ${_recognizedUser!.faceName ?? _recognizedUser!.username}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Status and Controls
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // User Info for Registration
                              if (isRegistration)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: theme.primaryColor,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'User ID: ${widget.currentUser.id}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: theme.primaryColor,
                                              ),
                                            ),
                                            Text(
                                              'Name: ${widget.currentUser.username}',
                                              style: TextStyle(
                                                color: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Status Text
                              Text(
                                _status ??
                                    (isRegistration
                                        ? 'Position your face in the center and ensure good lighting.'
                                        : (!_livenessVerified
                                              ? 'Blink your eyes to verify liveness.'
                                              : 'Liveness verified. Press scan to recognize face.')),
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 20),

                              // Action Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: _isProcessing
                                      ? null
                                      : (isRegistration ||
                                                _livenessVerified ||
                                                _recognizedUser != null
                                            ? () {
                                                if (_recognizedUser != null) {
                                                  _recordAttendance();
                                                } else {
                                                  _detectFaces(context);
                                                }
                                              }
                                            : null),
                                  icon: Icon(
                                    isRegistration
                                        ? Icons.camera_alt
                                        : (_recognizedUser != null
                                              ? Icons.check_circle
                                              : Icons.verified_user),
                                    size: 24,
                                  ),
                                  label: Text(
                                    isRegistration
                                        ? 'Capture Face'
                                        : (_recognizedUser != null
                                              ? 'Record Attendance'
                                              : (_livenessVerified
                                                    ? 'Scan Face'
                                                    : 'Verifying Liveness...')),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _recognizedUser != null
                                        ? Colors.green
                                        : (_livenessVerified
                                              ? theme.primaryColor
                                              : Colors.grey),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
    );
  }
}
