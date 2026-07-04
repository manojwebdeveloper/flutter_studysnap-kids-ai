import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/error/result.dart';

/// Wraps the native iOS document scanner (VNDocumentCameraViewController).
/// On Android falls back to ML Kit Document Scanner.
///
/// Returns a list of local file paths — one per scanned page.
class DocumentScannerService {
  /// Requests camera permission and launches the native scanner UI.
  /// Returns [Result.success] with a list of image paths on success.
  Future<Result<List<String>>> scan() async {
    // 1. Check camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      return const Result.failure(
        ScanException('Camera permission is required to scan worksheets.'),
      );
    }

    try {
      // 2. Launch native scanner
      final paths = await CunningDocumentScanner.getPictures(
        noOfPages: 10,        // allow multi-page worksheets
        isGalleryImportAllowed: true,
      );

      if (paths == null || paths.isEmpty) {
        // User cancelled — not an error
        return const Result.failure(
          ScanException('No pages scanned. Please try again.'),
        );
      }

      return Result.success(paths);
    } catch (e, st) {
      return Result.failure(
        ScanException('Scanning failed: $e', stackTrace: st),
      );
    }
  }
}
