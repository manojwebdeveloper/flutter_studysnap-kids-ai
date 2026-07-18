import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/repositories/mappers.dart';
import '../../../domain/entities/badge_entity.dart';
import '../../../domain/entities/flashcard_entity.dart';
import '../../../domain/entities/progress_entity.dart';
import '../../../domain/entities/quiz_question_entity.dart';
import '../../../domain/entities/study_set_entity.dart';
import '../../kid/providers/kid_provider.dart';
import 'parent_provider.dart';

// ═══════════════════════════════════════════════════════
// STUDY-SET CONTENT (edit flashcards / edit quiz screens)
// ═══════════════════════════════════════════════════════

/// Real flashcards for a given study set.
final flashcardsBySetProvider =
    FutureProvider.autoDispose.family<List<FlashcardEntity>, String>((ref, setId) async {
  final rows = await ref.watch(flashcardsDaoProvider).getBySet(setId);
  return rows.map(Mappers.flashcardFromRow).toList();
});

/// Real quiz questions for a given study set.
final quizQuestionsBySetProvider =
    FutureProvider.autoDispose.family<List<QuizQuestionEntity>, String>((ref, setId) async {
  final rows = await ref.watch(quizDaoProvider).getBySet(setId);
  return rows.map(Mappers.quizQuestionFromRow).toList();
});

// ═══════════════════════════════════════════════════════
// PROGRESS SUMMARY (parent progress screen)
// ═══════════════════════════════════════════════════════

class ProgressSummary {
  const ProgressSummary({
    required this.sessions,
    required this.subjectScores,
    required this.recentQuizzes,
  });

  final List<ProgressEntity> sessions;
  final Map<String, double> subjectScores; // subject -> average %
  final List<ProgressEntity> recentQuizzes; // newest first, max 5

  bool get isEmpty => sessions.isEmpty;
}

/// Real learning-progress summary for the currently selected child.
/// Returns an empty summary (isEmpty == true) when the child has no
/// recorded sessions yet, so screens can render an encouraging empty state.
final childProgressProvider =
    FutureProvider.autoDispose<ProgressSummary>((ref) async {
  final child = ref.watch(selectedChildNotifierProvider).valueOrNull;
  if (child == null) {
    return const ProgressSummary(sessions: [], subjectScores: {}, recentQuizzes: []);
  }

  final rows = await ref.watch(progressDaoProvider).getByChild(child.id);
  final sessions = rows.map(Mappers.progressFromRow).toList();

  final sets = ref.watch(studySetsStreamProvider).valueOrNull ??
      const <StudySetEntity>[];
  final subjectById = {for (final s in sets) s.id: s.subject};

  final quizzes = sessions.where((s) => s.activityType == 'quiz').toList();
  final bySubject = <String, List<double>>{};
  for (final q in quizzes) {
    final subject = subjectById[q.studySetId];
    if (subject == null) continue;
    (bySubject[subject] ??= <double>[]).add(q.percentage);
  }
  final subjectScores = <String, double>{
    for (final e in bySubject.entries)
      e.key: e.value.reduce((a, b) => a + b) / e.value.length,
  };

  return ProgressSummary(
    sessions: sessions,
    subjectScores: subjectScores,
    recentQuizzes: quizzes.take(5).toList(),
  );
});

/// Number of approved study sets for a given child (shown on the
/// switch-to-kid-mode learner cards).
final approvedSetCountProvider =
    FutureProvider.autoDispose.family<int, String>((ref, childId) async {
  final res = await ref.watch(studySetsRepositoryProvider).getApproved(childId);
  return res.dataOrNull?.length ?? 0;
});

// ═══════════════════════════════════════════════════════
// BADGES (kid rewards screen)
// ═══════════════════════════════════════════════════════

/// The eight app-defined achievement definitions (mirrors the badges seeded
/// into the DB). Their earned state is derived from the child's REAL data
/// below — never hardcoded.
const _badgeDefs = [
  ('🥇', 'Maths Starter'),
  ('⭐', 'Spelling Star'),
  ('🃏', 'Flashcard Hero'),
  ('🔬', 'Science Explorer'),
  ('🏆', 'Quiz Champion'),
  ('🔥', '7-Day Learner'),
  ('✏️', 'Practice Pro'),
  ('🚀', 'Super Learner'),
];

/// Real earned/locked badge state for the active kid, computed from the
/// child's XP, streak and recorded sessions.
final kidBadgesProvider =
    FutureProvider.autoDispose<List<BadgeEntity>>((ref) async {
  final child = ref.watch(activeChildProvider).valueOrNull;
  final earned = List<bool>.filled(_badgeDefs.length, false);

  if (child != null) {
    final rows = await ref.watch(progressDaoProvider).getByChild(child.id);
    final sessions = rows.map(Mappers.progressFromRow).toList();
    final sets = ref.watch(approvedSetsProvider).valueOrNull ??
        const <StudySetEntity>[];
    final subjectById = {for (final s in sets) s.id: s.subject};

    final quizzes = sessions.where((s) => s.activityType == 'quiz').toList();
    final flashcards =
        sessions.where((s) => s.activityType == 'flashcard').toList();
    bool perfect(ProgressEntity q) => q.total > 0 && q.score == q.total;
    int subjectQuizzes(String subj) =>
        quizzes.where((q) => subjectById[q.studySetId] == subj).length;

    final flashcardCount = flashcards.fold<int>(0, (s, f) => s + f.total);
    final practiceAnswered =
        quizzes.fold<int>(0, (s, q) => s + q.total) + flashcardCount;

    earned[0] = subjectQuizzes('Maths') >= 1;
    earned[1] = quizzes.any(
        (q) => subjectById[q.studySetId] == 'Spelling' && perfect(q));
    earned[2] = flashcardCount >= 50;
    earned[3] = subjectQuizzes('Science') >= 5;
    earned[4] = quizzes.where(perfect).length >= 10;
    earned[5] = child.streak >= 7;
    earned[6] = practiceAnswered >= 100;
    earned[7] = child.xp >= 1000;
  }

  return [
    for (var i = 0; i < _badgeDefs.length; i++)
      BadgeEntity(
        id: 'badge_$i',
        emoji: _badgeDefs[i].$1,
        label: _badgeDefs[i].$2,
        description: '',
        requiredCount: 0,
        category: 'general',
        isEarned: earned[i],
      ),
  ];
});
