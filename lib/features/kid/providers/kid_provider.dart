import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../domain/entities/child_entity.dart';
import '../../../domain/entities/flashcard_entity.dart';
import '../../../domain/entities/quiz_question_entity.dart';
import '../../../domain/entities/study_set_entity.dart';

part 'kid_provider.g.dart';

const _uuid = Uuid();

// ── Active child (re-expose for Kid Mode) ─────────────────

@riverpod
Stream<ChildEntity?> activeChild(ActiveChildRef ref) async* {
  yield* ref.watch(childrenRepositoryProvider).watchAll().map(
    (list) => list.isEmpty ? null : list.first,
  );
}

// ── Approved study sets for kid ───────────────────────────

@riverpod
Future<List<StudySetEntity>> approvedSets(ApprovedSetsRef ref) async {
  final children = await ref.watch(childrenRepositoryProvider).getAll();
  if (children.dataOrNull == null || children.dataOrNull!.isEmpty) return [];
  final child = children.dataOrNull!.first;
  final result = await ref.watch(studySetsRepositoryProvider).getApproved(child.id);
  return result.dataOrNull ?? [];
}

// ═══════════════════════════════════════════════════════
// FLASHCARD SESSION STATE
// ═══════════════════════════════════════════════════════

class FlashcardSessionState {
  const FlashcardSessionState({
    this.cards = const [],
    this.currentIndex = 0,
    this.isFlipped = false,
    this.gotCount = 0,
    this.missedCount = 0,
    this.isComplete = false,
    this.studySetId = '',
    this.studySetTitle = '',
    this.subject = '',
  });

  final List<FlashcardEntity> cards;
  final int currentIndex;
  final bool isFlipped;
  final int gotCount;
  final int missedCount;
  final bool isComplete;
  final String studySetId;
  final String studySetTitle;
  final String subject;

  FlashcardEntity? get current =>
      cards.isEmpty ? null : cards[currentIndex];

  int get total => cards.length;
  int get remaining => total - currentIndex - 1;
  double get progress => total == 0 ? 0 : (currentIndex + 1) / total;

  int get xpEarned => gotCount * AppConstants.xpPerFlashcard;
  int get starsEarned => (gotCount / total * 16).round();

  FlashcardSessionState copyWith({
    List<FlashcardEntity>? cards,
    int? currentIndex,
    bool? isFlipped,
    int? gotCount,
    int? missedCount,
    bool? isComplete,
    String? studySetId,
    String? studySetTitle,
    String? subject,
  }) =>
      FlashcardSessionState(
        cards: cards ?? this.cards,
        currentIndex: currentIndex ?? this.currentIndex,
        isFlipped: isFlipped ?? this.isFlipped,
        gotCount: gotCount ?? this.gotCount,
        missedCount: missedCount ?? this.missedCount,
        isComplete: isComplete ?? this.isComplete,
        studySetId: studySetId ?? this.studySetId,
        studySetTitle: studySetTitle ?? this.studySetTitle,
        subject: subject ?? this.subject,
      );
}

@riverpod
class FlashcardSessionNotifier extends _$FlashcardSessionNotifier {
  @override
  FlashcardSessionState build() => const FlashcardSessionState();

  /// Load cards for a given study set.
  Future<void> loadSet(StudySetEntity set) async {
    final dao    = ref.read(flashcardsDaoProvider);
    final rows   = await dao.getBySet(set.id);
    final cards  = rows.map((r) => FlashcardEntity(
      id: r.id, studySetId: r.studySetId,
      question: r.question, answer: r.answer,
      difficulty: r.difficulty, orderIndex: r.orderIndex,
    )).toList();

    // If no DB cards yet, use sample data so the screen works
    final effective = cards.isNotEmpty ? cards : _sampleCards(set.id);

    state = FlashcardSessionState(
      cards: effective, studySetId: set.id,
      studySetTitle: set.title, subject: set.subject,
    );
  }

  void flip() => state = state.copyWith(isFlipped: !state.isFlipped);

  /// Rate the current card and advance.
  Future<void> rate(bool knew) async {
    final next = FlashcardSessionState(
      cards: state.cards,
      currentIndex: state.currentIndex,
      isFlipped: false,
      gotCount:   state.gotCount   + (knew ? 1 : 0),
      missedCount: state.missedCount + (knew ? 0 : 1),
      isComplete: false,
      studySetId: state.studySetId,
      studySetTitle: state.studySetTitle,
      subject: state.subject,
    );

    if (state.currentIndex >= state.total - 1) {
      // Session complete — save progress
      state = next.copyWith(isComplete: true);
      await _saveProgress();
    } else {
      state = next.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  Future<void> _saveProgress() async {
    final childRes = await ref.read(childrenRepositoryProvider).getAll();
    final child    = childRes.dataOrNull?.firstOrNull;
    if (child == null) return;

    // TODO: record session to DB when ProgressTableCompanion is generated
    // await ref.read(progressDaoProvider).recordSession(...);
    await ref.read(childrenRepositoryProvider).addRewards(
      child.id, xp: state.xpEarned, stars: state.starsEarned,
    );
  }

  void reset() => state = const FlashcardSessionState();

  List<FlashcardEntity> _sampleCards(String setId) => [
    FlashcardEntity(id: '1', studySetId: setId, question: 'What is a denominator?',
      answer: 'The bottom number — how many equal parts the whole is split into.', orderIndex: 0),
    FlashcardEntity(id: '2', studySetId: setId, question: 'What is a numerator?',
      answer: 'The top number — it shows how many of those parts you have.', orderIndex: 1),
    FlashcardEntity(id: '3', studySetId: setId, question: 'Are ½ and 2/4 equivalent?',
      answer: 'Yes! Both equal one half. Same value, different appearance.', orderIndex: 2),
    FlashcardEntity(id: '4', studySetId: setId, question: 'What is ½ of 10?',
      answer: '5 — split 10 into 2 equal groups and take one.', orderIndex: 3),
    FlashcardEntity(id: '5', studySetId: setId, question: 'What does the fraction 3/4 mean?',
      answer: '3 out of 4 equal parts of a whole.', orderIndex: 4),
  ];
}

// ═══════════════════════════════════════════════════════
// QUIZ SESSION STATE
// ═══════════════════════════════════════════════════════

class QuizSessionState {
  const QuizSessionState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedIndex,
    this.answered = false,
    this.correctCount = 0,
    this.isComplete = false,
    this.secondsRemaining = 180, // 3 min default
    this.studySetId = '',
    this.studySetTitle = '',
    this.subject = '',
    this.answerHistory = const [],
  });

  final List<QuizQuestionEntity> questions;
  final int currentIndex;
  final int? selectedIndex;
  final bool answered;
  final int correctCount;
  final bool isComplete;
  final int secondsRemaining;
  final String studySetId;
  final String studySetTitle;
  final String subject;
  final List<bool> answerHistory; // true=correct, false=wrong per question

  QuizQuestionEntity? get current =>
      questions.isEmpty ? null : questions[currentIndex];

  int get total => questions.length;
  double get progress => total == 0 ? 0 : (currentIndex + 1) / total;
  bool get isLastQuestion => currentIndex >= total - 1;

  bool? get isCorrect => selectedIndex == null
      ? null
      : selectedIndex == current?.correctIndex;

  int get xpEarned => correctCount * AppConstants.xpPerQuizCorrect;
  int get starsEarned => AppConstants.starsPerQuiz * correctCount ~/ total;

  String get timerDisplay {
    final m = secondsRemaining ~/ 60;
    final s = secondsRemaining % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  QuizSessionState copyWith({
    List<QuizQuestionEntity>? questions,
    int? currentIndex,
    int? selectedIndex,
    bool? answered,
    int? correctCount,
    bool? isComplete,
    int? secondsRemaining,
    String? studySetId,
    String? studySetTitle,
    String? subject,
    List<bool>? answerHistory,
  }) =>
      QuizSessionState(
        questions: questions ?? this.questions,
        currentIndex: currentIndex ?? this.currentIndex,
        selectedIndex: selectedIndex ?? this.selectedIndex,
        answered: answered ?? this.answered,
        correctCount: correctCount ?? this.correctCount,
        isComplete: isComplete ?? this.isComplete,
        secondsRemaining: secondsRemaining ?? this.secondsRemaining,
        studySetId: studySetId ?? this.studySetId,
        studySetTitle: studySetTitle ?? this.studySetTitle,
        subject: subject ?? this.subject,
        answerHistory: answerHistory ?? this.answerHistory,
      );
}

@riverpod
class QuizSessionNotifier extends _$QuizSessionNotifier {
  Timer? _timer;

  @override
  QuizSessionState build() => const QuizSessionState();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadSet(StudySetEntity set, {int durationSeconds = 180}) async {
    _timer?.cancel();
    final dao   = ref.read(quizDaoProvider);
    final rows  = await dao.getBySet(set.id);
    final questions = rows.map((r) => QuizQuestionEntity(
      id: r.id, studySetId: r.studySetId,
      questionText: r.questionText,
      options: (r.options as List).cast<String>(),
      correctIndex: r.correctIndex, explanation: r.explanation,
      type: r.type, orderIndex: r.orderIndex,
    )).toList();

    final effective = questions.isNotEmpty ? questions : _sampleQuestions(set.id);

    state = QuizSessionState(
      questions: effective, studySetId: set.id,
      studySetTitle: set.title, subject: set.subject,
      secondsRemaining: durationSeconds,
    );

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.secondsRemaining > 0) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        _timer?.cancel();
        _complete();
      }
    });
  }

  void answer(int index) {
    if (state.answered) return;
    final correct = index == state.current?.correctIndex;
    state = state.copyWith(
      selectedIndex: index,
      answered: true,
      correctCount: state.correctCount + (correct ? 1 : 0),
      answerHistory: [...state.answerHistory, correct],
    );
  }

  Future<void> next() async {
    if (state.isLastQuestion) {
      _timer?.cancel();
      await _complete();
    } else {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        selectedIndex: null,
        answered: false,
      );
    }
  }

  Future<void> _complete() async {
    state = state.copyWith(isComplete: true);
    final childRes = await ref.read(childrenRepositoryProvider).getAll();
    final child    = childRes.dataOrNull?.firstOrNull;
    if (child == null) return;
    await ref.read(childrenRepositoryProvider).addRewards(
      child.id, xp: state.xpEarned, stars: state.starsEarned,
    );
  }

  void reset() {
    _timer?.cancel();
    state = const QuizSessionState();
  }

  List<QuizQuestionEntity> _sampleQuestions(String setId) => [
    QuizQuestionEntity(id: 'q1', studySetId: setId, questionText: 'What is ½ of 10?',
      options: ['2', '5', '10', '20'], correctIndex: 1,
      explanation: '½ of 10 means we split 10 into 2 equal groups and take one — that\'s 5.', orderIndex: 0),
    QuizQuestionEntity(id: 'q2', studySetId: setId, questionText: 'Are 1/2 and 2/4 equivalent fractions?',
      options: ['True', 'False'], correctIndex: 0,
      explanation: 'Both fractions equal one half — they look different but have the same value.', type: 'true_false', orderIndex: 1),
    QuizQuestionEntity(id: 'q3', studySetId: setId, questionText: 'The bottom number of a fraction is called the…',
      options: ['Numerator', 'Denominator', 'Equator', 'Divisor'], correctIndex: 1,
      explanation: 'Denominator names the parts the whole is split into.', orderIndex: 2),
    QuizQuestionEntity(id: 'q4', studySetId: setId, questionText: 'What fraction is shaded if 3 out of 8 parts are coloured?',
      options: ['3/5', '5/8', '3/8', '8/3'], correctIndex: 2,
      explanation: '3 shaded out of 8 total parts = 3/8.', orderIndex: 3),
    QuizQuestionEntity(id: 'q5', studySetId: setId, questionText: 'Which fraction is larger: 2/5 or 3/5?',
      options: ['2/5', '3/5', 'They\'re equal', 'Can\'t tell'], correctIndex: 1,
      explanation: 'Same denominator — the bigger numerator (3) means the bigger fraction.', orderIndex: 4),
  ];
}
