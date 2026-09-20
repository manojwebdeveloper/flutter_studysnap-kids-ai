import 'dart:convert';

import '../../../core/error/result.dart';
import '../../models/study_set_request.dart';

/// The prompt wording shared by every AI provider implementation. Only the
/// request formatting (how this text — and an optional image — is packaged
/// into that provider's API call) and the response parsing (how the raw
/// reply text is pulled out of that provider's response envelope) differ
/// per provider; the instructions themselves live in exactly one place.
String buildStudyContentPrompt(StudySetRequest request) {
  final wants = request.outputs.toSet();
  final ocrText = request.ocrText?.trim() ?? '';

  final worksheetSection = ocrText.isNotEmpty
      ? 'Worksheet content (extracted text):\n"""\n$ocrText\n"""'
      : 'The worksheet page is attached as an image. Read everything a '
          'child needs to learn from it — printed text, labels, captions '
          'and questions — before producing the material below.';

  return '''
You are an experienced UK primary school teacher creating age-appropriate study material that follows the UK national curriculum.

$worksheetSection

Subject: ${request.subject}
Year group: ${request.yearGroup}
Age level: ${request.ageLevel}

Reply with STRICTLY VALID JSON ONLY — no markdown, no code fences, no commentary — matching exactly this shape (include only the arrays/fields that are requested below; leave the others empty):

{
  "title": "short topic title",
  "subject": "${request.subject}",
  "yearGroup": "${request.yearGroup}",
  "ageLevel": "${request.ageLevel}",
  "topicDetected": "the specific topic",
  "topicsCovered": ["..."],
  "flashcards": [${wants.contains('flashcards') ? '{"question": "...", "answer": "...", "difficulty": "easy"}' : ''}],
  "quizQuestions": [${wants.contains('quiz') ? '{"questionText": "...", "options": ["a","b","c","d"], "correctIndex": 0, "explanation": "...", "type": "multiple_choice"}' : ''}],
  "simpleExplanation": ${wants.contains('explanation') ? '"a kid-friendly explanation"' : '""'},
  "practiceQuestions": [${wants.contains('practiceQs') ? '{"question": "...", "markScheme": "...", "marks": 1}' : ''}],
  "parentExplanation": ${wants.contains('parentGuide') ? '"guidance for a parent"' : '""'}
}

Rules: base everything strictly on the worksheet content; keep language appropriate for ${request.ageLevel}; when requested, produce 8-12 flashcards and 6-8 quiz questions; "difficulty" is one of easy/medium/hard; "type" is multiple_choice or true_false; "correctIndex" is the 0-based index of the correct option; never invent unrelated topics.''';
}

/// Providers sometimes wrap their JSON reply in ```json fences or add stray
/// prose before/after it. Strip any fencing and isolate the first {...}
/// object so parsing is resilient to that.
String extractJsonObject(String raw) {
  var s = raw.trim();
  s = s.replaceAll(RegExp(r'^```[a-zA-Z]*\s*'), '').replaceAll(RegExp(r'\s*```$'), '').trim();
  final start = s.indexOf('{');
  final end = s.lastIndexOf('}');
  if (start >= 0 && end > start) return s.substring(start, end + 1);
  return s;
}

/// Parses a provider's raw reply text into the app's standard study-content
/// model. Malformed or empty output is a friendly [GenerationException] —
/// [providerLabel] (e.g. "GPT", "Claude", "Gemini") is used only to make
/// that message specific, never to change the parsing itself.
Result<StudySetResponse> parseStudyContentResponse(
  String? raw,
  StudySetRequest request, {
  required String providerLabel,
}) {
  if (raw == null || raw.trim().isEmpty) {
    return Result.failure(
      GenerationException('$providerLabel returned an empty response. Please try again.'),
    );
  }
  try {
    final json = jsonDecode(extractJsonObject(raw)) as Map<String, dynamic>;
    // Backfill any required fields the model may have omitted.
    json['subject'] ??= request.subject;
    json['yearGroup'] ??= request.yearGroup;
    json['ageLevel'] ??= request.ageLevel;
    json['title'] ??= request.subject;
    json['topicDetected'] ??= json['title'];
    return Result.success(StudySetResponse.fromJson(json));
  } catch (e, st) {
    return Result.failure(
      GenerationException("$providerLabel's response could not be read. Please try again.", stackTrace: st),
    );
  }
}

/// Best-effort image MIME type from a file extension, for providers that
/// need it alongside inline/base64 image data.
String mimeTypeForImagePath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.heic')) return 'image/heic';
  return 'image/jpeg';
}
