import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/children_table.dart';
import '../tables/study_sets_table.dart';
import '../tables/flashcards_table.dart';
import '../tables/quiz_questions_table.dart';
import '../tables/scan_library_table.dart';
import '../tables/progress_table.dart';

part 'children_dao.g.dart';
part 'study_sets_dao.g.dart';
part 'flashcards_dao.g.dart';
part 'quiz_dao.g.dart';
part 'scan_dao.g.dart';
part 'progress_dao.g.dart';

// ═══════════════════════════════════════════════════════
// CHILDREN DAO
// ═══════════════════════════════════════════════════════

@DriftAccessor(tables: [ChildrenTable])
class ChildrenDao extends DatabaseAccessor<AppDatabase>
    with _$ChildrenDaoMixin {
  ChildrenDao(super.db);

  /// Watch all children — rebuilds UI when data changes.
  Stream<List<ChildrenTableData>> watchAll() =>
      select(childrenTable).watch();

  /// Get all children once.
  Future<List<ChildrenTableData>> getAll() =>
      select(childrenTable).get();

  /// Get a single child by ID.
  Future<ChildrenTableData?> getById(String id) =>
      (select(childrenTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Insert a new child profile.
  Future<void> insertChild(ChildrenTableCompanion child) =>
      into(childrenTable).insert(child);

  /// Update an existing child (e.g. after earning XP).
  Future<void> updateChild(ChildrenTableCompanion child) =>
      update(childrenTable).replace(child);

  /// Delete a child and all their data.
  Future<void> deleteChild(String id) =>
      (delete(childrenTable)..where((t) => t.id.equals(id))).go();

  /// Increment XP and stars for a child.
  Future<void> addRewards(String id, int xp, int stars) async {
    final child = await getById(id);
    if (child == null) return;
    await updateChild(
      ChildrenTableCompanion(
        id:    Value(child.id),
        xp:    Value(child.xp + xp),
        stars: Value(child.stars + stars),
        lastStudiedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update the study streak for a child.
  Future<void> updateStreak(String id, int streak) =>
      (update(childrenTable)..where((t) => t.id.equals(id))).write(
        ChildrenTableCompanion(streak: Value(streak)),
      );
}

// ═══════════════════════════════════════════════════════
// STUDY SETS DAO
// ═══════════════════════════════════════════════════════

@DriftAccessor(tables: [StudySetsTable])
class StudySetsDao extends DatabaseAccessor<AppDatabase>
    with _$StudySetsDaoMixin {
  StudySetsDao(super.db);

  /// Watch all study sets for a child.
  Stream<List<StudySetsTableData>> watchByChild(String childId) =>
      (select(studySetsTable)
            ..where((t) => t.childId.equals(childId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  /// Get all approved sets for a child (shown in Kid Mode).
  Future<List<StudySetsTableData>> getApproved(String childId) =>
      (select(studySetsTable)
            ..where((t) =>
                t.childId.equals(childId) & t.isApproved.equals(true)))
          .get();

  /// Insert a new study set.
  Future<String> insertSet(StudySetsTableCompanion set) async {
    await into(studySetsTable).insert(set);
    return set.id.value;
  }

  /// Approve a study set so kids can see it.
  Future<void> approve(String id) =>
      (update(studySetsTable)..where((t) => t.id.equals(id))).write(
        const StudySetsTableCompanion(isApproved: Value(true)),
      );

  /// Update status of a study set.
  Future<void> updateStatus(String id, String status) =>
      (update(studySetsTable)..where((t) => t.id.equals(id))).write(
        StudySetsTableCompanion(status: Value(status)),
      );

  Future<void> deleteSet(String id) =>
      (delete(studySetsTable)..where((t) => t.id.equals(id))).go();
}

// ═══════════════════════════════════════════════════════
// FLASHCARDS DAO
// ═══════════════════════════════════════════════════════

@DriftAccessor(tables: [FlashcardsTable])
class FlashcardsDao extends DatabaseAccessor<AppDatabase>
    with _$FlashcardsDaoMixin {
  FlashcardsDao(super.db);

  /// Get all flashcards for a study set, ordered.
  Future<List<FlashcardsTableData>> getBySet(String studySetId) =>
      (select(flashcardsTable)
            ..where((t) => t.studySetId.equals(studySetId))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .get();

  /// Insert multiple flashcards at once.
  Future<void> insertAll(List<FlashcardsTableCompanion> cards) =>
      batch((b) => b.insertAll(flashcardsTable, cards));

  Future<void> deleteBySet(String studySetId) =>
      (delete(flashcardsTable)
            ..where((t) => t.studySetId.equals(studySetId)))
          .go();

  Future<void> updateCard(FlashcardsTableCompanion card) =>
      update(flashcardsTable).replace(card);

  Future<void> deleteCard(String id) =>
      (delete(flashcardsTable)..where((t) => t.id.equals(id))).go();
}

// ═══════════════════════════════════════════════════════
// QUIZ DAO
// ═══════════════════════════════════════════════════════

@DriftAccessor(tables: [QuizQuestionsTable])
class QuizDao extends DatabaseAccessor<AppDatabase> with _$QuizDaoMixin {
  QuizDao(super.db);

  Future<List<QuizQuestionsTableData>> getBySet(String studySetId) =>
      (select(quizQuestionsTable)
            ..where((t) => t.studySetId.equals(studySetId))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .get();

  Future<void> insertAll(List<QuizQuestionsTableCompanion> questions) =>
      batch((b) => b.insertAll(quizQuestionsTable, questions));

  Future<void> deleteBySet(String studySetId) =>
      (delete(quizQuestionsTable)
            ..where((t) => t.studySetId.equals(studySetId)))
          .go();
}

// ═══════════════════════════════════════════════════════
// SCAN DAO
// ═══════════════════════════════════════════════════════

@DriftAccessor(tables: [ScanLibraryTable])
class ScanDao extends DatabaseAccessor<AppDatabase> with _$ScanDaoMixin {
  ScanDao(super.db);

  Stream<List<ScanLibraryTableData>> watchByChild(String childId) =>
      (select(scanLibraryTable)
            ..where((t) => t.childId.equals(childId))
            ..orderBy([(t) => OrderingTerm.desc(t.scannedAt)]))
          .watch();

  Future<List<ScanLibraryTableData>> getByChild(String childId) =>
      (select(scanLibraryTable)
            ..where((t) => t.childId.equals(childId))
            ..orderBy([(t) => OrderingTerm.desc(t.scannedAt)]))
          .get();

  Future<ScanLibraryTableData?> getById(String id) =>
      (select(scanLibraryTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertScan(ScanLibraryTableCompanion scan) =>
      into(scanLibraryTable).insert(scan);

  Future<void> updateStatus(String id, String status) =>
      (update(scanLibraryTable)..where((t) => t.id.equals(id))).write(
        ScanLibraryTableCompanion(status: Value(status)),
      );

  Future<void> linkToStudySet(String scanId, String studySetId) =>
      (update(scanLibraryTable)..where((t) => t.id.equals(scanId))).write(
        ScanLibraryTableCompanion(studySetId: Value(studySetId)),
      );

  /// Rename a saved scan.
  Future<void> updateTitle(String id, String title) =>
      (update(scanLibraryTable)..where((t) => t.id.equals(id))).write(
        ScanLibraryTableCompanion(title: Value(title)),
      );

  /// Tag a saved scan with a subject.
  Future<void> updateSubject(String id, String subject) =>
      (update(scanLibraryTable)..where((t) => t.id.equals(id))).write(
        ScanLibraryTableCompanion(subject: Value(subject)),
      );

  /// Delete a saved scan record.
  Future<void> deleteScan(String id) =>
      (delete(scanLibraryTable)..where((t) => t.id.equals(id))).go();

  Future<int> countByChild(String childId) async {
    final count = countAll();
    final query = selectOnly(scanLibraryTable)
      ..addColumns([count])
      ..where(scanLibraryTable.childId.equals(childId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}

// ═══════════════════════════════════════════════════════
// PROGRESS DAO
// ═══════════════════════════════════════════════════════

@DriftAccessor(tables: [ProgressTable])
class ProgressDao extends DatabaseAccessor<AppDatabase>
    with _$ProgressDaoMixin {
  ProgressDao(super.db);

  Future<List<ProgressTableData>> getByChild(
    String childId, {
    DateTime? since,
  }) {
    final query = select(progressTable)
      ..where((t) => t.childId.equals(childId))
      ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]);
    if (since != null) {
      query.where((t) => t.completedAt.isBiggerOrEqualValue(since));
    }
    return query.get();
  }

  Future<void> recordSession(ProgressTableCompanion session) =>
      into(progressTable).insert(session);

  /// Average quiz score for a child, optionally filtered by subject.
  Future<double> avgScore(String childId, {String? subject}) async {
    // Join with study_sets to filter by subject when needed.
    // For now returns simple average across all sessions.
    final rows = await getByChild(childId);
    if (rows.isEmpty) return 0;
    final quizRows = rows.where((r) => r.activityType == 'quiz');
    if (quizRows.isEmpty) return 0;
    final avg = quizRows.fold<double>(
          0,
          (sum, r) => sum + (r.total > 0 ? r.score / r.total : 0),
        ) /
        quizRows.length;
    return (avg * 100).roundToDouble();
  }
}
