import 'dart:convert';
import '../../../core/config/app_constants.dart';
import '../../../core/config/app_env.dart';
import '../../../core/error/result.dart';
import '../../../core/network/api_client.dart';
import '../../models/study_set_request.dart';
import '../../models/study_set_response.dart';

/// Calls the Anthropic Claude API to generate study content
/// (flashcards, quiz questions, explanations) from OCR-extracted text.
class ClaudeService {
  ClaudeService(this._client);

  final ApiClient _client;

  /// Generates a complete study set from worksheet text.
  ///
  /// [ocrText]    — the extracted text from the scanned worksheet
  /// [subject]    — e.g. 'Maths', 'English'
  /// [yearGroup]  — e.g. 'Year 4'
  /// [outputs]    — which content types to generate
  Future<Result<StudySetResponse>> generateStudySet(
    StudySetRequest request,
  ) async {
    final prompt = _buildPrompt(request);

    final result = await _client.post(
      '/messages',
      {
        'model': AppEnv.claudeModel,
        'max_tokens': AppConstants.claudeMaxTokens,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      },
    );

    return result.when(
      success: (data) {
        try {
          final content = data['content'] as List<dynamic>;
          final text = content
              .whereType<Map<String, dynamic>>()
              .where((b) => b['type'] == 'text')
              .map((b) => b['text'] as String)
              .join('');

          // Strip markdown fences if present
          final cleaned = text
              .replaceAll(RegExp(r'```json\s*'), '')
              .replaceAll(RegExp(r'```\s*'), '')
              .trim();

          final json = jsonDecode(cleaned) as Map<String, dynamic>;
          return Result.success(StudySetResponse.fromJson(json));
        } catch (e, st) {
          return Result.failure(
            GenerationException(
              'Failed to parse Claude response: $e',
              stackTrace: st,
            ),
          );
        }
      },
      failure: (error) => Result.failure(error),
    );
  }

  String _buildPrompt(StudySetRequest request) {
    final outputsList = request.outputs.join(', ');

    return '''
You are an expert educational content creator specialising in UK primary school curriculum.

WORKSHEET TEXT (OCR extracted):
"""
${request.ocrText}
"""

CONTEXT:
- Subject: ${request.subject}
- Year Group: ${request.yearGroup}
- Age Level: ${request.ageLevel}
- Outputs requested: $outputsList

TASK:
Analyse the worksheet text and generate study content appropriate for the age level.
Return ONLY valid JSON with no markdown fences or additional text.

JSON SCHEMA:
{
  "title": "string — descriptive title for this study set",
  "subject": "string",
  "yearGroup": "string",
  "ageLevel": "string",
  "topicDetected": "string — main curriculum topic detected",
  "flashcards": [
    {
      "question": "string",
      "answer": "string",
      "difficulty": "easy|medium|hard"
    }
  ],
  "quizQuestions": [
    {
      "questionText": "string",
      "options": ["string", "string", "string", "string"],
      "correctIndex": 0,
      "explanation": "string — why this answer is correct in kid-friendly language",
      "type": "multiple_choice|true_false"
    }
  ],
  "simpleExplanation": "string — topic explained in simple, age-appropriate language (2-3 paragraphs)",
  "parentExplanation": "string — how the parent can explain this topic at home",
  "practiceQuestions": [
    {
      "question": "string",
      "markScheme": "string",
      "marks": 1
    }
  ],
  "topicsCovered": ["string"]
}

RULES:
- Generate ${request.outputs.contains('flashcards') ? '10-12' : '0'} flashcards
- Generate ${request.outputs.contains('quiz') ? '8' : '0'} quiz questions
- Generate ${request.outputs.contains('practiceQuestions') ? '20' : '0'} practice questions
- Use age-appropriate vocabulary for ${request.yearGroup} (${request.ageLevel})
- All explanations must be encouraging and positive
- Quiz questions must test genuine understanding, not just recall
- Return ONLY the JSON object, nothing else
''';
  }
}
