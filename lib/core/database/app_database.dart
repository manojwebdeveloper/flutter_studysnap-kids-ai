import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/children_table.dart';
import 'tables/study_sets_table.dart';
import 'tables/flashcards_table.dart';
import 'tables/quiz_questions_table.dart';
import 'tables/scan_library_table.dart';
import 'tables/progress_table.dart';
import 'tables/badges_table.dart';
import 'daos/children_dao.dart';
import 'daos/study_sets_dao.dart';
import 'daos/flashcards_dao.dart';
import 'daos/quiz_dao.dart';
import 'daos/scan_dao.dart';
import 'daos/progress_dao.dart';

part 'app_database.g.dart';

/// The single Drift database instance for the entire app.
/// All local data (children, study sets, flashcards, quiz questions,
/// scans, progress, badges) lives here.
///
/// Generate code after changes:
/// ```
/// dart run build_runner build --delete-conflicting-outputs
/// ```
@DriftDatabase(
  tables: [
    ChildrenTable,
    StudySetsTable,
    FlashcardsTable,
    QuizQuestionsTable,
    ScanLibraryTable,
    ProgressTable,
    BadgesTable,
  ],
  daos: [
    ChildrenDao,
    StudySetsDao,
    FlashcardsDao,
    QuizDao,
    ScanDao,
    ProgressDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Increment this whenever the schema changes and add a migration step.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedInitialData();
        },
        onUpgrade: (m, from, to) async {
          // v2: saved-scan PDF path + page count.
          if (from < 2) {
            await m.addColumn(scanLibraryTable, scanLibraryTable.pdfPath);
            await m.addColumn(scanLibraryTable, scanLibraryTable.pageCount);
          }
        },
        beforeOpen: (details) async {
          // Enable foreign key constraints.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Seeds badges and any static data on first launch.
  Future<void> _seedInitialData() async {
    await into(badgesTable).insertAll([
      BadgesTableCompanion.insert(
        id: const Value('badge_maths_starter'),
        label: 'Maths Starter',
        emoji: '🥇',
        description: 'Complete your first Maths quiz',
        requiredCount: 1,
        category: 'maths',
      ),
      BadgesTableCompanion.insert(
        id: const Value('badge_spelling_star'),
        label: 'Spelling Star',
        emoji: '⭐',
        description: 'Get 100% on a Spelling quiz',
        requiredCount: 1,
        category: 'spelling',
      ),
      BadgesTableCompanion.insert(
        id: const Value('badge_flashcard_hero'),
        label: 'Flashcard Hero',
        emoji: '🃏',
        description: 'Complete 50 flashcards',
        requiredCount: 50,
        category: 'general',
      ),
      BadgesTableCompanion.insert(
        id: const Value('badge_science_explorer'),
        label: 'Science Explorer',
        emoji: '🔬',
        description: 'Complete 5 Science quizzes',
        requiredCount: 5,
        category: 'science',
      ),
      BadgesTableCompanion.insert(
        id: const Value('badge_quiz_champion'),
        label: 'Quiz Champion',
        emoji: '🏆',
        description: 'Score 100% on 10 quizzes',
        requiredCount: 10,
        category: 'general',
      ),
      BadgesTableCompanion.insert(
        id: const Value('badge_7_day_learner'),
        label: '7-Day Learner',
        emoji: '🔥',
        description: 'Study 7 days in a row',
        requiredCount: 7,
        category: 'streak',
      ),
      BadgesTableCompanion.insert(
        id: const Value('badge_practice_pro'),
        label: 'Practice Pro',
        emoji: '✏️',
        description: 'Complete 100 practice questions',
        requiredCount: 100,
        category: 'general',
      ),
      BadgesTableCompanion.insert(
        id: const Value('badge_super_learner'),
        label: 'Super Learner',
        emoji: '🚀',
        description: 'Earn 1000 XP',
        requiredCount: 1000,
        category: 'xp',
      ),
    ]);
  }
}

/// Opens a connection to the SQLite database file on disk.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir  = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'studysnap.db'));
    return NativeDatabase.createInBackground(file);
  });
}
