import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/ai_generator_providers.dart';
import '../../models/study_set_request.dart';

/// Internal-only helper for manually verifying that the currently active AI
/// provider's API key actually works. Not wired into any UI — call it once
/// keys have been added to `.env`, e.g. from a temporary debug button or a
/// one-off script:
///
/// ```dart
/// final container = ProviderContainer();
/// await AppEnv.load();
/// await testActiveAiGenerator(container);
/// ```
///
/// Sends [sampleText] through the active provider (see
/// `activeAiContentGeneratorProvider`) requesting a single flashcard, and
/// prints whether it succeeded or failed.
Future<void> testActiveAiGenerator(
  ProviderContainer container, {
  String sampleText = 'The cat sat on the mat.',
}) async {
  final provider = container.read(activeAiProviderProvider);
  final generator = container.read(activeAiContentGeneratorProvider);

  debugPrint('[AI TEST] provider=$provider — sending sample text…');

  final result = await generator.generate(
    StudySetRequest(
      ocrText: sampleText,
      subject: 'English',
      yearGroup: 'Year 2',
      ageLevel: 'Age 6–7',
      outputs: const ['flashcards'],
    ),
  );

  result.when(
    success: (data) => debugPrint(
      '[AI TEST] provider=$provider — SUCCESS — title="${data.title}", '
      'flashcards=${data.flashcards.length}',
    ),
    failure: (error) => debugPrint('[AI TEST] provider=$provider — FAILURE — ${error.message}'),
  );
}
