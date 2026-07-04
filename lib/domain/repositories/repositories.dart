import '../entities/child_entity.dart';
import '../entities/study_set_entity.dart';
import '../entities/flashcard_entity.dart';
import '../entities/quiz_question_entity.dart';
import '../entities/scan_entity.dart';
import '../entities/progress_entity.dart';
import '../entities/badge_entity.dart';
import '../../core/error/result.dart';
import '../../data/models/study_set_request.dart';

// ─────────────────────────────────────────────────────────
// CHILDREN REPOSITORY
// ─────────────────────────────────────────────────────────

abstract interface class ChildrenRepository {
  Stream<List<ChildEntity>> watchAll();
  Future<Result<List<ChildEntity>>> getAll();
  Future<Result<ChildEntity?>> getById(String id);
  Future<Result<void>> create(ChildEntity child);
  Future<Result<void>> update(ChildEntity child);
  Future<Result<void>> delete(String id);
  Future<Result<void>> addRewards(String id, {required int xp, required int stars});
  Future<Result<void>> updateStreak(String id, int streak);
}

// ─────────────────────────────────────────────────────────
// STUDY SETS REPOSITORY
// ─────────────────────────────────────────────────────────

abstract interface class StudySetsRepository {
  Stream<List<StudySetEntity>> watchByChild(String childId);
  Future<Result<List<StudySetEntity>>> getApproved(String childId);
  Future<Result<String>> create(StudySetEntity set);
  Future<Result<void>> approve(String id);
  Future<Result<void>> updateStatus(String id, String status);
  Future<Result<void>> delete(String id);
}

// ─────────────────────────────────────────────────────────
// FLASHCARDS REPOSITORY
// ─────────────────────────────────────────────────────────

abstract interface class FlashcardsRepository {
  Future<Result<List<FlashcardEntity>>> getBySet(String studySetId);
  Future<Result<void>> insertAll(List<FlashcardEntity> cards);
  Future<Result<void>> update(FlashcardEntity card);
  Future<Result<void>> delete(String id);
  Future<Result<void>> deleteBySet(String studySetId);
}

// ─────────────────────────────────────────────────────────
// QUIZ REPOSITORY
// ─────────────────────────────────────────────────────────

abstract interface class QuizRepository {
  Future<Result<List<QuizQuestionEntity>>> getBySet(String studySetId);
  Future<Result<void>> insertAll(List<QuizQuestionEntity> questions);
  Future<Result<void>> deleteBySet(String studySetId);
}

// ─────────────────────────────────────────────────────────
// SCAN REPOSITORY
// ─────────────────────────────────────────────────────────

abstract interface class ScanRepository {
  Stream<List<ScanEntity>> watchByChild(String childId);
  Future<Result<List<ScanEntity>>> getByChild(String childId);
  Future<Result<void>> create(ScanEntity scan);
  Future<Result<void>> updateStatus(String id, String status);
  Future<Result<void>> linkToStudySet(String scanId, String studySetId);
  Future<Result<int>> countByChild(String childId);
}

// ─────────────────────────────────────────────────────────
// PROGRESS REPOSITORY
// ─────────────────────────────────────────────────────────

abstract interface class ProgressRepository {
  Future<Result<List<ProgressEntity>>> getByChild(String childId, {DateTime? since});
  Future<Result<void>> record(ProgressEntity session);
  Future<Result<double>> avgScore(String childId, {String? subject});
}

// ─────────────────────────────────────────────────────────
// GENERATION REPOSITORY (Claude API)
// ─────────────────────────────────────────────────────────

abstract interface class GenerationRepository {
  Future<Result<StudySetResponse>> generateStudySet(StudySetRequest request);
}

// ─────────────────────────────────────────────────────────
// AUTH REPOSITORY (Parent PIN)
// ─────────────────────────────────────────────────────────

abstract interface class AuthRepository {
  Future<Result<void>> setPin(String pin);
  Future<Result<bool>> verifyPin(String pin);
  Future<bool> hasPin();
  Future<Result<void>> clearPin();
  Future<Result<bool>> authenticateWithBiometrics();
}
