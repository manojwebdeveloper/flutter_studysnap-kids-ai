import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/error/result.dart';
import '../../../core/providers/app_providers.dart';
import '../../../domain/entities/child_entity.dart';
import '../../../domain/entities/study_set_entity.dart';
import '../../../domain/entities/scan_entity.dart';
import '../../../data/models/study_set_request.dart';
import '../../../data/repositories/mappers.dart';

part 'parent_provider.g.dart';

const _uuid = Uuid();

// ── Selected child ────────────────────────────────────────

@riverpod
class SelectedChildNotifier extends _$SelectedChildNotifier {
  @override
  Future<ChildEntity?> build() async {
    final prefs    = await SharedPreferences.getInstance();
    final childId  = prefs.getString(AppConstants.keySelectedChildId);
    // Guard: reject null, empty, or obviously-wrong values (e.g. a route
    // string or a debug log line accidentally stored instead of a UUID).
    if (childId == null ||
        childId.isEmpty ||
        childId.startsWith('/') ||
        childId.startsWith('[')) {
      return null;
    }
    final result   = await ref.watch(childrenRepositoryProvider).getById(childId);
    return result.dataOrNull;
  }

  Future<void> selectChild(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keySelectedChildId, childId);
    ref.invalidateSelf();
  }
}

// ── Children list ─────────────────────────────────────────

@riverpod
Stream<List<ChildEntity>> childrenStream(ChildrenStreamRef ref) =>
    ref.watch(childrenRepositoryProvider).watchAll();

// ── Study sets for selected child ─────────────────────────

@riverpod
Stream<List<StudySetEntity>> studySetsStream(StudySetsStreamRef ref) {
  final childAsync = ref.watch(selectedChildNotifierProvider);
  return childAsync.when(
    data: (child) => child != null
        ? ref.watch(studySetsRepositoryProvider).watchByChild(child.id)
        : const Stream.empty(),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
}

// ── Scan library for selected child ───────────────────────

@riverpod
Stream<List<ScanEntity>> scanLibraryStream(ScanLibraryStreamRef ref) {
  final childAsync = ref.watch(selectedChildNotifierProvider);
  return childAsync.when(
    data: (child) => child != null
        ? ref.watch(scanDaoProvider).watchByChild(child.id).map(
            (rows) => rows.map((r) => ScanEntity(
              id: r.id, childId: r.childId, title: r.title,
              subject: r.subject, imagePath: r.imagePath,
              extractedText: r.extractedText, confidence: r.confidence,
              scanMethod: r.scanMethod, status: r.status,
              studySetId: r.studySetId, scannedAt: r.scannedAt,
            )).toList())
        : const Stream.empty(),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
}

// ── Scan count (for free plan limit) ──────────────────────

@riverpod
Future<int> scanCount(ScanCountRef ref) async {
  final childAsync = ref.watch(selectedChildNotifierProvider);
  final child = childAsync.valueOrNull;
  if (child == null) return 0;
  final result = await ref.watch(scanDaoProvider).countByChild(child.id);
  return result;
}

// ── OCR Review state ───────────────────────────────────────

class OcrReviewState {
  const OcrReviewState({
    this.scanId = '',
    this.extractedText = '',
    this.confidence = 0.0,
    this.imagePath,
    this.subject = 'Maths',
    this.isEdited = false,
  });
  final String scanId;
  final String extractedText;
  final double confidence;
  final String? imagePath;
  final String subject;
  final bool isEdited;

  OcrReviewState copyWith({
    String? scanId, String? extractedText, double? confidence,
    String? imagePath, String? subject, bool? isEdited,
  }) => OcrReviewState(
    scanId: scanId ?? this.scanId,
    extractedText: extractedText ?? this.extractedText,
    confidence: confidence ?? this.confidence,
    imagePath: imagePath ?? this.imagePath,
    subject: subject ?? this.subject,
    isEdited: isEdited ?? this.isEdited,
  );
}

@riverpod
class OcrReviewNotifier extends _$OcrReviewNotifier {
  @override
  OcrReviewState build() => const OcrReviewState();

  void setResult({
    required String scanId,
    required String text,
    required double confidence,
    String? imagePath,
    String subject = 'Maths',
  }) => state = state.copyWith(
    scanId: scanId, extractedText: text,
    confidence: confidence, imagePath: imagePath, subject: subject,
  );

  void editText(String text) =>
      state = state.copyWith(extractedText: text, isEdited: true);

  void setSubject(String subject) => state = state.copyWith(subject: subject);
}

// ── Choose output state ───────────────────────────────────

class ChooseOutputState {
  const ChooseOutputState({
    this.flashcards    = true,
    this.quiz          = true,
    this.explanation   = true,
    this.practiceQs    = true,
    this.parentGuide   = false,
    this.ageLevel      = 'Year 3–4',
    this.isGenerating  = false,
    this.error,
  });
  final bool flashcards, quiz, explanation, practiceQs, parentGuide;
  final String ageLevel;
  final bool isGenerating;
  final String? error;

  List<String> get selectedOutputs => [
    if (flashcards)  'flashcards',
    if (quiz)        'quiz',
    if (explanation) 'explanation',
    if (practiceQs)  'practiceQuestions',
    if (parentGuide) 'parentGuide',
  ];

  ChooseOutputState copyWith({
    bool? flashcards, bool? quiz, bool? explanation,
    bool? practiceQs, bool? parentGuide, String? ageLevel,
    bool? isGenerating, String? error,
  }) => ChooseOutputState(
    flashcards: flashcards ?? this.flashcards,
    quiz: quiz ?? this.quiz,
    explanation: explanation ?? this.explanation,
    practiceQs: practiceQs ?? this.practiceQs,
    parentGuide: parentGuide ?? this.parentGuide,
    ageLevel: ageLevel ?? this.ageLevel,
    isGenerating: isGenerating ?? this.isGenerating,
    error: error,
  );
}

@riverpod
class ChooseOutputNotifier extends _$ChooseOutputNotifier {
  @override
  ChooseOutputState build() => const ChooseOutputState();

  void toggle(String type) => state = switch (type) {
    'flashcards'   => state.copyWith(flashcards: !state.flashcards),
    'quiz'         => state.copyWith(quiz: !state.quiz),
    'explanation'  => state.copyWith(explanation: !state.explanation),
    'practiceQs'   => state.copyWith(practiceQs: !state.practiceQs),
    'parentGuide'  => state.copyWith(parentGuide: !state.parentGuide),
    _              => state,
  };

  void setAgeLevel(String level) => state = state.copyWith(ageLevel: level);

  /// Calls Claude API and saves the study set to the local DB.
  Future<bool> generate(String ocrText, String subject, String yearGroup) async {
    state = state.copyWith(isGenerating: true);

    final request = StudySetRequest(
      ocrText: ocrText,
      subject: subject,
      yearGroup: yearGroup,
      ageLevel: state.ageLevel,
      outputs: state.selectedOutputs,
    );

    final result = await ref.read(generationRepositoryProvider).generateStudySet(request);

    return await result.when(
      success: (response) async {
        // Create study set record
        final child    = ref.read(selectedChildNotifierProvider).valueOrNull;
        if (child == null) { state = state.copyWith(isGenerating: false, error: 'No child selected'); return false; }

        final setId = _uuid.v4();
        final studySet = StudySetEntity(
          id: setId, childId: child.id,
          title: response.title, subject: response.subject,
          yearGroup: response.yearGroup, source: 'scanned',
          status: 'pending', isApproved: false,
          cardCount: response.flashcards.length,
          questionCount: response.quizQuestions.length,
          createdAt: DateTime.now(), updatedAt: DateTime.now(),
        );

        await ref.read(studySetsRepositoryProvider).create(studySet);

        // Save flashcards to DB
        if (response.flashcards.isNotEmpty) {
          final cards = response.flashcards.asMap().entries.map((e) =>
              FlashcardEntity(
                id: _uuid.v4(),
                studySetId: setId,
                question: e.value.question,
                answer: e.value.answer,
                difficulty: e.value.difficulty,
                orderIndex: e.key,
              )).toList();
          await ref
              .read(flashcardsDaoProvider)
              .insertAll(cards.map(Mappers.flashcardToCompanion).toList());
        }

        // Save quiz questions to DB
        if (response.quizQuestions.isNotEmpty) {
          final questions = response.quizQuestions.asMap().entries.map((e) =>
              QuizQuestionEntity(
                id: _uuid.v4(),
                studySetId: setId,
                questionText: e.value.questionText,
                options: e.value.options,
                correctIndex: e.value.correctIndex,
                explanation: e.value.explanation,
                type: e.value.type,
                orderIndex: e.key,
              )).toList();
          await ref
              .read(quizDaoProvider)
              .insertAll(questions.map(Mappers.quizQuestionToCompanion).toList());
        }

        state = state.copyWith(isGenerating: false);
        return true;
      },
      failure: (error) {
        state = state.copyWith(isGenerating: false, error: error.message);
        return false;
      },
    );
  }
}
