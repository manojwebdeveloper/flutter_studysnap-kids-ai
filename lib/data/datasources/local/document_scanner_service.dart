import 'dart:io';

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';

import '../../../core/error/result.dart';

/// A successfully scanned multi-page document, exported as a single PDF.
class ScannedPdf {
  const ScannedPdf({required this.pdfPath, required this.pageCount});

  /// Absolute path to the PDF the native scanner produced (in a temp/cache dir).
  final String pdfPath;

  /// Number of pages captured.
  final int pageCount;
}

/// Launches the native multi-page document scanner — ML Kit Document Scanner
/// on Android, VisionKit on iOS — with automatic edge detection, deskew and
/// multi-page capture, and returns the pages as a single PDF file.
///
/// No OCR, text extraction or AI happens here — this only produces a PDF.
class DocumentScannerService {
  const DocumentScannerService();

  /// Launches the scanner and returns the captured PDF.
  ///
  /// - [Result.success] with a [ScannedPdf] when pages were captured.
  /// - [Result.success] with `null` when the user cancelled — this is a
  ///   normal outcome, not an error.
  /// - [Result.failure] when the scanner is unavailable (e.g. a simulator,
  ///   or missing Play Services) or an unexpected error occurs.
  Future<Result<ScannedPdf?>> scanToPdf({int maxPages = 10}) async {
    try {
      final dynamic raw =
          await FlutterDocScanner().getScannedDocumentAsPdf(page: maxPages);

      // A null result means the user backed out before capturing anything.
      if (raw == null) return const Result.success(null);

      final scanned = _parse(raw);
      // Nothing usable came back — treat as a quiet cancel rather than an error.
      if (scanned == null) return const Result.success(null);

      if (!File(scanned.pdfPath).existsSync()) {
        return const Result.failure(
          ScanException('The scan could not be saved. Please try again.'),
        );
      }
      return Result.success(scanned);
    } on PlatformException catch (e, st) {
      // The native scanner is unavailable (simulator, missing Play Services,
      // unsupported device). Surface a friendly, non-crashing failure.
      return Result.failure(
        ScanException(
          'The document scanner isn\'t available on this device.',
          stackTrace: st,
        ),
      );
    } catch (e, st) {
      return Result.failure(
        ScanException('Scanning failed. Please try again.', stackTrace: st),
      );
    }
  }

  /// The plugin returns a platform-specific shape (a Map on Android, a String
  /// or List on iOS depending on version). Normalise it into a file path plus
  /// a page count, tolerating `file://` URIs.
  ScannedPdf? _parse(dynamic raw) {
    String? path;
    var pages = 0;

    if (raw is Map) {
      for (final entry in raw.entries) {
        final key = entry.key.toString().toLowerCase();
        final value = entry.value;
        if (value is String &&
            (key.contains('uri') || key.contains('path') || key.contains('pdf'))) {
          path = value;
        } else if (value is int && (key.contains('count') || key.contains('page'))) {
          pages = value;
        } else if (value is String && (key.contains('count') || key.contains('page'))) {
          pages = int.tryParse(value) ?? pages;
        }
      }
    } else if (raw is String) {
      path = raw;
    } else if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is String) path = first;
      pages = raw.length;
    }

    if (path == null || path.isEmpty) return null;
    return ScannedPdf(pdfPath: _toFilePath(path), pageCount: pages > 0 ? pages : 1);
  }

  String _toFilePath(String raw) =>
      raw.startsWith('file://') ? Uri.parse(raw).toFilePath() : raw;
}
