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
}
