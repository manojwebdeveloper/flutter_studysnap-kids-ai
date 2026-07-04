import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/result.dart';
import '../../../domain/entities/scan_entity.dart';

/// On-device OCR using Google ML Kit.
/// Privacy-first: nothing leaves the device during text extraction.
class OcrService {
  OcrService() : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;
  static const _uuid = Uuid();

  /// Processes an image file and returns a [ScanEntity] with extracted text.
  ///
  /// [imagePath]  — local path to the scanned image
  /// [childId]    — which child this scan belongs to
  /// [subject]    — subject selected by parent
  Future<Result<ScanEntity>> processImage({
    required String imagePath,
    required String childId,
    required String subject,
  }) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognised = await _recognizer.processImage(inputImage);

      // Compute overall confidence score
      double totalConf  = 0;
      int    blockCount = 0;
      final buffer = StringBuffer();

      for (final block in recognised.blocks) {
        for (final line in block.lines) {
          buffer.writeln(line.text);
          for (final element in line.elements) {
            totalConf += element.confidence ?? 0.9;
            blockCount++;
          }
        }
        buffer.writeln();
      }

      final avgConfidence = blockCount > 0 ? totalConf / blockCount : 0.9;
      final extractedText = buffer.toString().trim();

      if (extractedText.isEmpty) {
        return const Result.failure(
          ScanException('No text detected. Try a clearer image with good lighting.'),
        );
      }

      final scan = ScanEntity(
        id: _uuid.v4(),
        childId: childId,
        title: _inferTitle(extractedText, subject),
        subject: subject,
        imagePath: imagePath,
        extractedText: extractedText,
        confidence: avgConfidence,
        scanMethod: 'photo',
        status: 'pending',
        scannedAt: DateTime.now(),
      );

      return Result.success(scan);
    } catch (e, st) {
      return Result.failure(
        ScanException('OCR processing failed: $e', stackTrace: st),
      );
    }
  }

  /// Infers a title from the first meaningful line of OCR text.
  String _inferTitle(String text, String subject) {
    final lines = text.split('\n')
        .map((l) => l.trim())
        .where((l) => l.length > 5 && l.length < 80)
        .toList();
    if (lines.isEmpty) return '$subject Worksheet';
    final first = lines.first;
    // Remove common worksheet prefixes
    return first
        .replaceAll(RegExp(r'^(name|date|class|worksheet)[:\s]*', caseSensitive: false), '')
        .trim()
        .isEmpty
        ? '$subject Worksheet'
        : first;
  }

  void dispose() => _recognizer.close();
}
