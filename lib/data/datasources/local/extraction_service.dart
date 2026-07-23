import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

/// On-device extraction from a scanned PDF page: rasterises the first page to an
/// image, then runs ML Kit text recognition. All methods fail soft (return
/// null / '') so a missing capability never crashes the review flow.
class ExtractionService {
  const ExtractionService();

  /// Minimum characters of recognised text to consider the page "text-based".
  static const textThreshold = 40;

  /// Renders the first page of [pdfPath] to a PNG file and returns its path,
  /// or null if rendering isn't possible.
  Future<String?> renderFirstPage(String pdfPath) async {
    PdfDocument? doc;
    try {
      doc = await PdfDocument.openFile(pdfPath);
      final page = await doc.getPage(1);
      final image = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.png,
      );
      await page.close();
      if (image == null) return null;

      final dir = await getTemporaryDirectory();
      final out = File(p.join(dir.path, 'scan_page_${DateTime.now().millisecondsSinceEpoch}.png'));
      await out.writeAsBytes(image.bytes);
      return out.path;
    } catch (_) {
      return null;
    } finally {
      await doc?.close();
    }
  }

  /// Runs on-device OCR over an image file. Returns '' on failure.
  Future<String> ocrImage(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(InputImage.fromFilePath(imagePath));
      return result.text.trim();
    } catch (_) {
      return '';
    } finally {
      await recognizer.close();
    }
  }

  /// True when [text] has a healthy quantity of recognised text (i.e. the page
  /// is printed text rather than a diagram/photo).
  bool looksTextBased(String text) => text.length >= textThreshold;
}
