import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_entity.freezed.dart';
part 'study_set_entity.freezed.dart';
part 'flashcard_entity.freezed.dart';
part 'quiz_question_entity.freezed.dart';
part 'scan_entity.freezed.dart';
part 'progress_entity.freezed.dart';
part 'badge_entity.freezed.dart';

// ─────────────────────────────────────────────────────────
// CHILD
// ─────────────────────────────────────────────────────────

@freezed
class ChildEntity with _$ChildEntity {
  const factory ChildEntity({
    required String id,
    required String nickname,
    required String avatar,
    required String yearGroup,
    required List<String> subjects,
    @Default(0) int xp,
    @Default(0) int stars,
    @Default(0) int streak,
    DateTime? lastStudiedAt,
    required DateTime createdAt,
  }) = _ChildEntity;

  const ChildEntity._();

  /// XP needed to reach the next level.
  int get xpToNextLevel => 500 - (xp % 500);

  /// Current level (every 500 XP = 1 level).
  int get level => (xp / 500).floor() + 1;

  /// Progress to next level as 0.0–1.0.
  double get levelProgress => (xp % 500) / 500;
}

// ─────────────────────────────────────────────────────────
// STUDY SET
// ─────────────────────────────────────────────────────────

@freezed
class StudySetEntity with _$StudySetEntity {
  const factory StudySetEntity({
    required String id,
    required String childId,
    required String title,
    required String subject,
    required String yearGroup,
    required String source,   // 'scanned' | 'curriculum'
    required String status,   // 'pending' | 'approved' | 'needs_review'
    @Default(false) bool isApproved,
    @Default(0) int cardCount,
    @Default(0) int questionCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _StudySetEntity;
}

// ─────────────────────────────────────────────────────────
// FLASHCARD
// ─────────────────────────────────────────────────────────

@freezed
class FlashcardEntity with _$FlashcardEntity {
  const factory FlashcardEntity({
    required String id,
    required String studySetId,
    required String question,
    required String answer,
    @Default('easy') String difficulty,
    @Default(0) int orderIndex,
  }) = _FlashcardEntity;
}

// ─────────────────────────────────────────────────────────
// QUIZ QUESTION
// ─────────────────────────────────────────────────────────

@freezed
class QuizQuestionEntity with _$QuizQuestionEntity {
  const factory QuizQuestionEntity({
    required String id,
    required String studySetId,
    required String questionText,
    required List<String> options,
    required int correctIndex,
    required String explanation,
    @Default('multiple_choice') String type,
    @Default(0) int orderIndex,
  }) = _QuizQuestionEntity;
}

// ─────────────────────────────────────────────────────────
// SCAN
// ─────────────────────────────────────────────────────────

@freezed
class ScanEntity with _$ScanEntity {
  const factory ScanEntity({
    required String id,
    required String childId,
    required String title,
    required String subject,
    String? imagePath,
    String? extractedText,
    @Default(0.0) double confidence,
    required String scanMethod,  // 'photo' | 'upload' | 'paste'
    @Default('pending') String status,
    String? studySetId,
    required DateTime scannedAt,
  }) = _ScanEntity;
}

// ─────────────────────────────────────────────────────────
// PROGRESS
// ─────────────────────────────────────────────────────────

@freezed
class ProgressEntity with _$ProgressEntity {
  const factory ProgressEntity({
    required String id,
    required String childId,
    required String studySetId,
    required String activityType,
    required int score,
    required int total,
    @Default(0) int xpEarned,
    @Default(0) int starsEarned,
    @Default(0) int durationSecs,
    required DateTime completedAt,
  }) = _ProgressEntity;

  const ProgressEntity._();

  double get percentage => total > 0 ? (score / total) * 100 : 0;
}

// ─────────────────────────────────────────────────────────
// BADGE
// ─────────────────────────────────────────────────────────

@freezed
class BadgeEntity with _$BadgeEntity {
  const factory BadgeEntity({
    required String id,
    required String label,
    required String emoji,
    required String description,
    required int requiredCount,
    required String category,
    @Default(false) bool isEarned,
    @Default(false) bool isNew,
  }) = _BadgeEntity;
}
