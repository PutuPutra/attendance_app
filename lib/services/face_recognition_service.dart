import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceRecognitionService {
  Interpreter? _interpreter;
  bool _isInitialized = false;
  int _frameCount = 0;
  static const int frameSkip = 2; // Process every 3rd frame

  static const String modelPath = 'assets/models/mobilefacenet.tflite';
  static const int inputSize = 112;
  static const int embeddingSize = 192;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load model
      final interpreterOptions = InterpreterOptions();

      // Use delegates for performance
      // Delegates removed for compatibility

      _interpreter = await Interpreter.fromAsset(
        modelPath,
        options: interpreterOptions,
      );

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize face recognition: $e');
    }
  }

  Future<List<double>?> extractEmbedding(File imageFile) async {
    if (!_isInitialized || _interpreter == null) {
      throw Exception('Face recognition not initialized');
    }

    _frameCount++;
    if (_frameCount % (frameSkip + 1) != 0) {
      return null; // Skip frame
    }

    // Decode image
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    // Preprocess image
    final processedImage = _preprocessImage(image);

    // Run inference
    final output = List<List<double>>.filled(
      1,
      List.filled(embeddingSize, 0.0),
    );
    _interpreter!.run(processedImage, output);

    // L2 normalize
    final embedding = output[0];
    final norm = sqrt(embedding.map((e) => e * e).reduce((a, b) => a + b));
    return embedding.map((e) => e / norm).toList();
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Resize to 112x112
    final resized = img.copyResize(image, width: inputSize, height: inputSize);

    // Normalize to [-1, 1]
    final input = List.generate(
      inputSize,
      (y) => List.generate(inputSize, (x) {
        final pixel = resized.getPixel(x, y);
        final r = pixel.r / 127.5 - 1.0;
        final g = pixel.g / 127.5 - 1.0;
        final b = pixel.b / 127.5 - 1.0;
        return [r, g, b];
      }),
    );

    return [input];
  }

  double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;

    double dot = 0.0, normA = 0.0, normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    return dot / (sqrt(normA) * sqrt(normB));
  }

  void dispose() {
    _interpreter?.close();
    _isInitialized = false;
  }
}
