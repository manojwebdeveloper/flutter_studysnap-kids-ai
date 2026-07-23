import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/config/app_env.dart';
import '../../../core/error/result.dart';
import '../../../domain/repositories/repositories.dart';
import '../../models/study_set_request.dart';

/// Turns scanned-worksheet text (or an image of the page) into structured
/// study content using Google Gemini. The API key is read from the env
/// (GEMINI_API_KEY) — never hardcoded.
class GeminiService implements GenerationRepository {
  GeminiService();

  GenerativeModel? _model;

  GenerativeModel _client() {
    final key = AppEnv.geminiApiKey;
    if (key.isEmpty) {
      throw const GenerationException(
        'No Gemini API key found. Add GEMINI_API_KEY to your .env file.',
      );
    }
    return _model ??= GenerativeModel(model: AppEnv.geminiModel, apiKey: key);
  }

  // ── Generation (text) ───────────────────────────────────

  @override
  Future<Result<StudySetResponse>> generateStudySet(StudySetRequest request) async {
    try {
      final resp = await _client().generateContent([Content.text(_buildPrompt(request))]);
      return _parse(resp.text, request);
    } on GenerationException catch (e) {
      return Result.failure(e);
    } catch (e, st) {
      return Result.failure(
        GenerationException('Gemini generation failed. Please try again.', stackTrace: st),
      );
    }
  }

  // ── Vision (image-heavy pages: diagrams, maps, photos) ──

  /// Sends the page image to Gemini's vision input and returns a rich plain-text
  /// transcription/description that can then feed [generateStudySet].
  Future<Result<String>> describeImage(
    File image, {
    required String subject,
    required String yearGroup,
  }) async {
    try {
      final bytes = await image.readAsBytes();
      final prompt =
          'You are a UK primary school teacher. This is a $subject worksheet or teaching '
          'image for $yearGroup. Transcribe and describe everything a child needs to learn '
          'from it — printed text, labels on diagrams, captions, questions and key facts — '
          'as clear plain text. Do not add commentary or headings.';
      final resp = await _client().generateContent([
        Content.multi([TextPart(prompt), DataPart(_mimeFor(image.path), bytes)]),
      ]);
      final text = resp.text?.trim() ?? '';
      if (text.isEmpty) {
        return const Result.failure(
          GenerationException('Gemini could not read this image. Try another page.'),
        );
      }
      return Result.success(text);
    } on GenerationException catch (e) {
      return Result.failure(e);
    } catch (e, st) {
      return Result.failure(
        GenerationException('Gemini vision failed. Please try again.', stackTrace: st),
      );
    }
  }

  // ── Prompt ──────────────────────────────────────────────

  String _buildPrompt(StudySetRequest r) {
    final wants = r.outputs.toSet();
    return '''
You are an experienced UK primary school teacher creating age-appropriate study material that follows the UK national curriculum.

Worksheet content:
"""
${r.ocrText}
"""

Subject: ${r.subject}
Year group: ${r.yearGroup}
Age level: ${r.ageLevel}

Reply with STRICTLY VALID JSON ONLY — no markdown, no code fences, no commentary — matching exactly this shape (include only the arrays that are requested; leave the others empty):

{
  "title": "short topic title",
  "subject": "${r.subject}",
  "yearGroup": "${r.yearGroup}",
  "ageLevel": "${r.ageLevel}",
  "topicDetected": "the specific topic",
  "topicsCovered": ["..."],
  "flashcards": [${wants.contains('flashcards') ? '{"question": "...", "answer": "...", "difficulty": "easy"}' : ''}],
  "quizQuestions": [${wants.contains('quiz') ? '{"questionText": "...", "options": ["a","b","c","d"], "correctIndex": 0, "explanation": "...", "type": "multiple_choice"}' : ''}],
  "simpleExplanation": ${wants.contains('explanation') ? '"a kid-friendly explanation"' : '""'},
  "practiceQuestions": [${wants.contains('practiceQs') ? '{"question": "...", "markScheme": "...", "marks": 1}' : ''}],
  "parentExplanation": ${wants.contains('parentGuide') ? '"guidance for a parent"' : '""'}
}

Rules: base everything strictly on the worksheet content above; keep language appropriate for ${r.ageLevel}; when requested, produce 8-12 flashcards and 6-8 quiz questions; "difficulty" is one of easy/medium/hard; "type" is multiple_choice or true_false; "correctIndex" is the 0-based index of the correct option; never invent unrelated topics.''';
  }

  // ── Defensive parsing ───────────────────────────────────

  Result<StudySetResponse> _parse(String? raw, StudySetRequest request) {
    if (raw == null || raw.trim().isEmpty) {
      return const Result.failure(
        GenerationException('Gemini returned an empty response. Please try again.'),
      );
    }
    try {
      final json = jsonDecode(_extractJson(raw)) as Map<String, dynamic>;
      // Backfill any required fields the model may have omitted.
      json['subject'] ??= request.subject;
      json['yearGroup'] ??= request.yearGroup;
      json['ageLevel'] ??= request.ageLevel;
      json['title'] ??= request.subject;
      json['topicDetected'] ??= json['title'];
      return Result.success(StudySetResponse.fromJson(json));
    } catch (e, st) {
      return Result.failure(
        GenerationException("Gemini's response could not be read. Please try again.", stackTrace: st),
      );
    }
  }

  /// Models sometimes wrap JSON in ```json fences or add stray prose. Strip any
  /// fencing and isolate the first {...} object.
  String _extractJson(String raw) {
    var s = raw.trim();
    s = s.replaceAll(RegExp(r'^```[a-zA-Z]*\s*'), '').replaceAll(RegExp(r'\s*```$'), '').trim();
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start >= 0 && end > start) return s.substring(start, end + 1);
    return s;
  }

  String _mimeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
