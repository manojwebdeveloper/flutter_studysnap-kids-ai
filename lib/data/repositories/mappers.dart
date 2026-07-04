import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/tables/children_table.dart';
import '../../core/database/tables/study_sets_table.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/entities/study_set_entity.dart';

const _uuid = Uuid();

/// Converts between Drift database rows and domain entities.
/// All mapping lives here — screens and providers never touch raw DB types.
abstract class Mappers {
  // ── CHILD ───────────────────────────────────────────────

  static ChildEntity childFromRow(ChildrenTableData row) => ChildEntity(
    id: row.id,
    nickname: row.nickname,
    avatar: row.avatar,
    yearGroup: row.yearGroup,
    subjects: (jsonDecode(row.subjects) as List).cast<String>(),
    xp: row.xp,
    stars: row.stars,
    streak: row.streak,
    lastStudiedAt: row.lastStudiedAt,
    createdAt: row.createdAt,
  );

  static ChildrenTableCompanion childToCompanion(ChildEntity e) =>
      ChildrenTableCompanion(
        id: Value(e.id),
        nickname: Value(e.nickname),
        avatar: Value(e.avatar),
        yearGroup: Value(e.yearGroup),
        subjects: Value(jsonEncode(e.subjects)),
        xp: Value(e.xp),
        stars: Value(e.stars),
        streak: Value(e.streak),
        lastStudiedAt: Value(e.lastStudiedAt),
        createdAt: Value(e.createdAt),
      );

  // ── STUDY SET ───────────────────────────────────────────

  static StudySetEntity studySetFromRow(StudySetsTableData row) => StudySetEntity(
    id: row.id,
    childId: row.childId,
    title: row.title,
    subject: row.subject,
    yearGroup: row.yearGroup,
    source: row.source,
    status: row.status,
    isApproved: row.isApproved,
    cardCount: row.cardCount,
    questionCount: row.questionCount,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  static StudySetsTableCompanion studySetToCompanion(StudySetEntity e) =>
      StudySetsTableCompanion(
        id: Value(e.id),
        childId: Value(e.childId),
        title: Value(e.title),
        subject: Value(e.subject),
        yearGroup: Value(e.yearGroup),
        source: Value(e.source),
        status: Value(e.status),
        isApproved: Value(e.isApproved),
        cardCount: Value(e.cardCount),
        questionCount: Value(e.questionCount),
        createdAt: Value(e.createdAt),
        updatedAt: Value(e.updatedAt),
      );

  // ── FLASHCARD ───────────────────────────────────────────

  static FlashcardEntity flashcardFromRow(FlashcardsTableData row) =>
      FlashcardEntity(
        id: row.id,
        studySetId: row.studySetId,
        question: row.question,
        answer: row.answer,
        difficulty: row.difficulty,
        orderIndex: row.orderIndex,
      );

  static FlashcardsTableCompanion flashcardToCompanion(FlashcardEntity e) =>
      FlashcardsTableCompanion(
        id: Value(e.id),
        studySetId: Value(e.studySetId),
        question: Value(e.question),
        answer: Value(e.answer),
        difficulty: Value(e.difficulty),
        orderIndex: Value(e.orderIndex),
      );

  // ── QUIZ QUESTION ───────────────────────────────────────

  static QuizQuestionEntity quizQuestionFromRow(QuizQuestionsTableData row) =>
      QuizQuestionEntity(
        id: row.id,
        studySetId: row.studySetId,
        questionText: row.questionText,
        options: (jsonDecode(row.options) as List).cast<String>(),
        correctIndex: row.correctIndex,
        explanation: row.explanation,
        type: row.type,
        orderIndex: row.orderIndex,
      );

  static QuizQuestionsTableCompanion quizQuestionToCompanion(
    QuizQuestionEntity e,
  ) =>
      QuizQuestionsTableCompanion(
        id: Value(e.id),
        studySetId: Value(e.studySetId),
        questionText: Value(e.questionText),
        options: Value(jsonEncode(e.options)),
        correctIndex: Value(e.correctIndex),
        explanation: Value(e.explanation),
        type: Value(e.type),
        orderIndex: Value(e.orderIndex),
      );

  // ── PROGRESS ────────────────────────────────────────────

  static ProgressEntity progressFromRow(ProgressTableData row) => ProgressEntity(
    id: row.id,
    childId: row.childId,
    studySetId: row.studySetId,
    activityType: row.activityType,
    score: row.score,
    total: row.total,
    xpEarned: row.xpEarned,
    starsEarned: row.starsEarned,
    durationSecs: row.durationSecs,
    completedAt: row.completedAt,
  );

  static ProgressTableCompanion progressToCompanion(ProgressEntity e) =>
      ProgressTableCompanion(
        id: Value(e.id),
        childId: Value(e.childId),
        studySetId: Value(e.studySetId),
        activityType: Value(e.activityType),
        score: Value(e.score),
        total: Value(e.total),
        xpEarned: Value(e.xpEarned),
        starsEarned: Value(e.starsEarned),
        durationSecs: Value(e.durationSecs),
        completedAt: Value(e.completedAt),
      );
}
