// ─────────────────────────────────────────────────────────
// study_sets_table.dart
// ─────────────────────────────────────────────────────────
import 'package:drift/drift.dart';
import 'children_table.dart';

/// A generated study set (from a scan or curriculum).
class StudySetsTable extends Table {
  @override
  String get tableName => 'study_sets';

  TextColumn get id          => text()();
  TextColumn get childId     => text().references(ChildrenTable, #id)();
  TextColumn get title       => text()();
  TextColumn get subject     => text()(); // 'Maths' | 'English' | etc.
  TextColumn get yearGroup   => text()();
  TextColumn get source      => text()(); // 'scanned' | 'curriculum'
  TextColumn get status      => text().withDefault(const Constant('pending'))();
  // 'pending' | 'approved' | 'needs_review'
  BoolColumn get isApproved  => boolean().withDefault(const Constant(false))();
  IntColumn  get cardCount   => integer().withDefault(const Constant(0))();
  IntColumn  get questionCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────
// flashcards_table.dart
// ─────────────────────────────────────────────────────────

/// Individual flashcard belonging to a study set.
class FlashcardsTable extends Table {
  @override
  String get tableName => 'flashcards';

  TextColumn get id          => text()();
  TextColumn get studySetId  => text().references(StudySetsTable, #id)();
  TextColumn get question    => text()();
  TextColumn get answer      => text()();
  TextColumn get difficulty  => text().withDefault(const Constant('easy'))();
  // 'easy' | 'medium' | 'hard'
  IntColumn  get orderIndex  => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────
// quiz_questions_table.dart
// ─────────────────────────────────────────────────────────

/// Multiple-choice / true-false question in a study set.
class QuizQuestionsTable extends Table {
  @override
  String get tableName => 'quiz_questions';

  TextColumn get id            => text()();
  TextColumn get studySetId    => text().references(StudySetsTable, #id)();
  TextColumn get questionText  => text()();
  TextColumn get options       => text()(); // JSON array of strings
  IntColumn  get correctIndex  => integer()();
  TextColumn get explanation   => text()();
  TextColumn get type          => text().withDefault(const Constant('multiple_choice'))();
  // 'multiple_choice' | 'true_false'
  IntColumn  get orderIndex    => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────
// scan_library_table.dart
// ─────────────────────────────────────────────────────────

/// Record of each worksheet scan performed by a parent.
class ScanLibraryTable extends Table {
  @override
  String get tableName => 'scan_library';

  TextColumn get id            => text()();
  TextColumn get childId       => text().references(ChildrenTable, #id)();
  TextColumn get title         => text()();
  TextColumn get subject       => text()();
  TextColumn get imagePath     => text().nullable()(); // local file path
  TextColumn get extractedText => text().nullable()();
  RealColumn get confidence    => real().withDefault(const Constant(0.0))();
  TextColumn get scanMethod    => text()(); // 'photo' | 'upload' | 'paste' | 'scan'
  TextColumn get status        => text().withDefault(const Constant('pending'))();
  // 'pending' | 'approved' | 'needs_review'
  TextColumn get studySetId    => text().nullable()();
  TextColumn get pdfPath       => text().nullable()(); // saved multi-page PDF
  IntColumn  get pageCount     => integer().withDefault(const Constant(0))();
  DateTimeColumn get scannedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────
// progress_table.dart
// ─────────────────────────────────────────────────────────

/// Tracks a child's performance per study session.
class ProgressTable extends Table {
  @override
  String get tableName => 'progress';

  TextColumn get id           => text()();
  TextColumn get childId      => text().references(ChildrenTable, #id)();
  TextColumn get studySetId   => text().references(StudySetsTable, #id)();
  TextColumn get activityType => text()(); // 'flashcard' | 'quiz' | 'lesson'
  IntColumn  get score        => integer().withDefault(const Constant(0))();
  IntColumn  get total        => integer().withDefault(const Constant(0))();
  IntColumn  get xpEarned     => integer().withDefault(const Constant(0))();
  IntColumn  get starsEarned  => integer().withDefault(const Constant(0))();
  IntColumn  get durationSecs => integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────
// badges_table.dart
// ─────────────────────────────────────────────────────────

/// Static badge definitions (seeded on first launch).
class BadgesTable extends Table {
  @override
  String get tableName => 'badges';

  TextColumn get id              => text()();
  TextColumn get label           => text()();
  TextColumn get emoji           => text()();
  TextColumn get description     => text()();
  IntColumn  get requiredCount   => integer()();
  TextColumn get category        => text()(); // 'maths'|'spelling'|'streak'|etc.

  @override
  Set<Column> get primaryKey => {id};
}
