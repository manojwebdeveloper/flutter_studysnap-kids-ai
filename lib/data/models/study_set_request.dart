import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_set_request.freezed.dart';
part 'study_set_request.g.dart';
part 'study_set_response.freezed.dart';
part 'study_set_response.g.dart';

// ─────────────────────────────────────────────────────────
// REQUEST
// ─────────────────────────────────────────────────────────

@freezed
class StudySetRequest with _$StudySetRequest {
  const factory StudySetRequest({
    // Worksheet content — provide either (or both): extracted OCR text,
    // and/or the path to a worksheet page image for providers that support
    // vision input.
    String? ocrText,
    String? imagePath,
    required String subject,
    required String yearGroup,
    required String ageLevel,
    required List<String> outputs,
    // outputs: 'flashcards' | 'quiz' | 'explanation' | 'practiceQuestions' | 'parentGuide'
  }) = _StudySetRequest;

  factory StudySetRequest.fromJson(Map<String, dynamic> json) =>
      _$StudySetRequestFromJson(json);
}

// ─────────────────────────────────────────────────────────
// RESPONSE
// ─────────────────────────────────────────────────────────

@freezed
class StudySetResponse with _$StudySetResponse {
  const factory StudySetResponse({
    required String title,
    required String subject,
    required String yearGroup,
    required String ageLevel,
    required String topicDetected,
    @Default([]) List<FlashcardModel> flashcards,
    @Default([]) List<QuizQuestionModel> quizQuestions,
    @Default('') String simpleExplanation,
    @Default('') String parentExplanation,
    @Default([]) List<PracticeQuestionModel> practiceQuestions,
    @Default([]) List<String> topicsCovered,
  }) = _StudySetResponse;

  factory StudySetResponse.fromJson(Map<String, dynamic> json) =>
      _$StudySetResponseFromJson(json);
}

@freezed
class FlashcardModel with _$FlashcardModel {
  const factory FlashcardModel({
    required String question,
    required String answer,
    @Default('easy') String difficulty,
  }) = _FlashcardModel;

  factory FlashcardModel.fromJson(Map<String, dynamic> json) =>
      _$FlashcardModelFromJson(json);
}

@freezed
class QuizQuestionModel with _$QuizQuestionModel {
  const factory QuizQuestionModel({
    required String questionText,
    required List<String> options,
    required int correctIndex,
    required String explanation,
    @Default('multiple_choice') String type,
  }) = _QuizQuestionModel;

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionModelFromJson(json);
}

@freezed
class PracticeQuestionModel with _$PracticeQuestionModel {
  const factory PracticeQuestionModel({
    required String question,
    required String markScheme,
    @Default(1) int marks,
  }) = _PracticeQuestionModel;

  factory PracticeQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$PracticeQuestionModelFromJson(json);
}
