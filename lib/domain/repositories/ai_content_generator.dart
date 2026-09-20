import '../../core/error/result.dart';
import '../../data/models/study_set_request.dart';

/// A single interface behind which every AI content-generation provider
/// (OpenAI GPT, Anthropic Claude, Google Gemini) is hidden.
///
/// The rest of the app must depend only on this interface — never on a
/// specific provider's implementation. Which concrete implementation is
/// active is decided in exactly one place: see `activeAiContentGeneratorProvider`
/// in `core/providers/ai_generator_providers.dart`.
abstract interface class AiContentGenerator {
  /// Turns worksheet content — [request.ocrText] and/or [request.imagePath]
  /// — into the app's standard structured study content
  /// ([StudySetResponse]: flashcards, quiz questions, a simple explanation,
  /// practice questions and a parent guide), honouring [request.outputs].
  ///
  /// Always returns a [Result] — a missing API key or a malformed reply from
  /// the provider is a friendly [Result.failure], never a thrown exception.
  Future<Result<StudySetResponse>> generate(StudySetRequest request);
}
