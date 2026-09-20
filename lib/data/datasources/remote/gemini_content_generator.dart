import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/config/app_env.dart';
import '../../../core/error/result.dart';
import '../../models/study_set_request.dart';
import '../../../domain/repositories/ai_content_generator.dart' show AiContentGenerator;
import 'ai_content_shared.dart';

/// Turns scanned-worksheet content into structured study content using
/// Google Gemini's generateContent endpoint (with inline image data for an
/// attached worksheet image). The API key is read from the env
/// (GEMINI_API_KEY) — never hardcoded — and a missing key is a friendly
/// failure, not a crash.
///
/// This is one of the three interchangeable [AiContentGenerator]
/// implementations selected via `activeAiContentGeneratorProvider`; it is
/// independent of the legacy `GeminiService` already wired into the scan
/// flow.
class GeminiContentGenerator implements AiContentGenerator {
  GeminiContentGenerator();

  GenerativeModel? _model;

  GenerativeModel? _client() {
    final key = AppEnv.geminiApiKey;
    if (key.isEmpty) return null;
    return _model ??= GenerativeModel(model: AppEnv.geminiModel, apiKey: key);
  }

  @override
  Future<Result<StudySetResponse>> generate(StudySetRequest request) async {
    final model = _client();
    if (model == null) {
      return const Result.failure(
        GenerationException('No Gemini API key found. Add GEMINI_API_KEY to your .env file.'),
      );
    }

    try {
      final parts = <Part>[TextPart(buildStudyContentPrompt(request))];

      final imagePath = request.imagePath;
      if (imagePath != null && imagePath.isNotEmpty) {
        final bytes = await File(imagePath).readAsBytes();
        parts.add(DataPart(mimeTypeForImagePath(imagePath), bytes));
      }

      final response = await model.generateContent([Content.multi(parts)]);
      return parseStudyContentResponse(response.text, request, providerLabel: 'Gemini');
    } catch (e, st) {
      return Result.failure(
        GenerationException('Gemini generation failed. Please try again.', stackTrace: st),
      );
    }
  }
}
