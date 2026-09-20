import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/parent_pin_screen.dart';
import '../../features/onboarding/screens/add_child_screen.dart';
import '../../features/onboarding/screens/year_group_screen.dart';
import '../../features/onboarding/screens/subjects_screen.dart';
import '../../features/parent/screens/parent_shell.dart';
import '../../features/parent/screens/parent_dashboard_screen.dart';
import '../../features/parent/screens/scan_library_screen.dart';
import '../../features/parent/screens/ocr_review_screen.dart';
import '../../features/parent/screens/choose_output_screen.dart';
import '../../features/parent/screens/study_set_ready_screen.dart';
import '../../features/parent/screens/edit_flashcards_screen.dart';
import '../../features/parent/screens/edit_quiz_screen.dart';
import '../../features/parent/screens/switch_kid_mode_screen.dart';
import '../../features/parent/screens/practice_questions_screen.dart';
import '../../features/parent/screens/study_sets_screen.dart';
import '../../features/parent/screens/curriculum_topic_screen.dart';
import '../../features/parent/screens/parent_progress_screen.dart';
import '../../features/parent/screens/practice_areas_screen.dart';
import '../../features/parent/screens/settings_screen.dart';
import '../../features/parent/screens/subscription_screen.dart';
import '../../features/kid/parent_guard.dart';
import '../../features/kid/screens/kid_shell.dart';
import '../../features/kid/screens/kid_dashboard_screen.dart';
import '../../features/kid/screens/learning_path_screen.dart';
import '../../features/kid/screens/flashcard_study_screen.dart';
import '../../features/kid/screens/quiz_screen.dart';
import '../../features/kid/screens/quiz_result_screen.dart';
import '../../features/kid/screens/rewards_screen.dart';
import '../../features/kid/screens/type_answer_screen.dart';
import '../../features/kid/screens/writing_studio_screen.dart';
import '../../features/kid/screens/phonics_listen_screen.dart';
import '../../features/kid/screens/speak_aloud_screen.dart';
import '../config/app_constants.dart';

part 'app_router.g.dart';

// ── Route name constants ───────────────────────────────────
abstract class AppRoutes {
  static const splash        = '/';
  static const onboarding    = '/onboarding';
  static const parentPin     = '/parent-pin';
  static const addChild      = '/add-child';
  static const yearGroup     = '/year-group';
  static const subjects      = '/subjects';
  static const parent        = '/parent';
  static const scan          = '/parent/scan';
  static const ocrReview     = '/parent/scan/review';
  static const chooseOutput  = '/parent/scan/output';
  static const studySetReady = '/parent/scan/ready';
  static const editCards     = '/parent/edit-cards';
  static const editQuiz      = '/parent/edit-quiz';
  static const switchKid     = '/parent/switch-kid';
  static const practiceQ     = '/parent/practice-questions';
  static const studySets     = '/parent/study-sets';
  static const curriculum    = '/parent/curriculum';
  static const progress      = '/parent/progress';
  static const practiceAreas = '/parent/practice-areas';
  static const settings      = '/parent/settings';
  static const subscription  = '/parent/settings/subscription';
  static const kid           = '/kid';
  static const learningPath  = '/kid/learning-path';
  static const flashcards    = '/kid/flashcards';
  static const quiz          = '/kid/quiz';
  static const quizResult    = '/kid/quiz/result';
  static const rewards       = '/kid/rewards';
  static const typeAnswer    = '/kid/type-answer';
  static const writingStudio = '/kid/writing-studio';
  static const phonicsListen = '/kid/phonics-listen';
  static const speakAloud    = '/kid/speak-aloud';
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: _globalRedirect,
    routes: [
      // ── Onboarding ─────────────────────────────────────
      GoRoute(path: AppRoutes.splash,     builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.parentPin,  builder: (_, __) => const ParentPinScreen()),
      GoRoute(path: AppRoutes.addChild,   builder: (_, __) => const AddChildScreen()),
      GoRoute(path: AppRoutes.yearGroup,  builder: (_, __) => const YearGroupScreen()),
      GoRoute(path: AppRoutes.subjects,   builder: (_, __) => const SubjectsScreen()),

      // ── Parent Mode (ShellRoute for bottom nav) ────────
      ShellRoute(
        builder: (context, state, child) => ParentShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.parent,   builder: (_, __) => const ParentDashboardScreen()),
          GoRoute(path: AppRoutes.scan,     builder: (_, __) => const ScanLibraryScreen()),
          GoRoute(path: AppRoutes.studySets,builder: (_, __) => const StudySetsScreen()),
          GoRoute(path: AppRoutes.progress, builder: (_, __) => const ParentProgressScreen()),
          GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsScreen()),
        ],
      ),
      // Parent screens outside shell (full-screen, no bottom nav)
      GoRoute(
        path: AppRoutes.ocrReview,
        builder: (_, state) => OcrReviewScreen(scanId: state.uri.queryParameters['scanId']),
      ),
      GoRoute(
        path: AppRoutes.chooseOutput,
        builder: (_, state) => ChooseOutputScreen(scanId: state.uri.queryParameters['scanId']),
      ),
      GoRoute(path: AppRoutes.studySetReady, builder: (_, __) => const StudySetReadyScreen()),
      GoRoute(path: AppRoutes.editCards,     builder: (_, __) => const EditFlashcardsScreen()),
      GoRoute(path: AppRoutes.editQuiz,      builder: (_, __) => const EditQuizScreen()),
      GoRoute(path: AppRoutes.switchKid,     builder: (_, __) => const SwitchKidModeScreen()),
      GoRoute(path: AppRoutes.practiceQ,     builder: (_, __) => const PracticeQuestionsScreen()),
      GoRoute(
        path: AppRoutes.curriculum,
        builder: (_, state) => CurriculumTopicScreen(subject: state.uri.queryParameters['subject']),
      ),
      GoRoute(path: AppRoutes.practiceAreas, builder: (_, __) => const PracticeAreasScreen()),
      GoRoute(path: AppRoutes.subscription,  builder: (_, __) => const SubscriptionScreen()),

      // ── Kid Mode (ShellRoute for bottom nav) ──────────
      ShellRoute(
        builder: (context, state, child) => KidShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.kid,      builder: (_, __) => const KidDashboardScreen()),
          GoRoute(path: AppRoutes.rewards,  builder: (_, __) => const RewardsScreen()),
        ],
      ),
      // Kid screens outside shell — wrapped in KidGuard so the hardware back
      // button / swipe-back triggers the Parent PIN guard, not a silent exit.
      GoRoute(path: AppRoutes.learningPath, builder: (_, __) => const KidGuard(child: LearningPathScreen())),
      GoRoute(path: AppRoutes.flashcards,   builder: (_, __) => const KidGuard(child: FlashcardStudyScreen())),
      GoRoute(path: AppRoutes.quiz,         builder: (_, __) => const KidGuard(child: QuizScreen())),
      GoRoute(path: AppRoutes.quizResult,   builder: (_, __) => const KidGuard(child: QuizResultScreen())),
      GoRoute(path: AppRoutes.typeAnswer,   builder: (_, __) => const KidGuard(child: TypeAnswerScreen())),
      GoRoute(path: AppRoutes.writingStudio,builder: (_, __) => const KidGuard(child: WritingStudioScreen())),
      GoRoute(path: AppRoutes.phonicsListen,builder: (_, __) => const KidGuard(child: PhonicsListenScreen())),
      GoRoute(path: AppRoutes.speakAloud,   builder: (_, __) => const KidGuard(child: SpeakAloudScreen())),
    ],

    // Custom slide transition on every route
    observers: [_RouteObserver()],
  );
}

/// Launch-time flags, read **once** at startup (see [initStartupFlags]) and
/// held in memory. The redirect reads these synchronously so it never touches
/// storage on every navigation event.
class StartupFlags {
  static bool onboardingDone = false;
  static bool pinSet = false;
}

/// Reads the onboarding / PIN flags from storage a single time. Call this in
/// `main()` before `runApp`.
Future<void> initStartupFlags() async {
  final prefs = await SharedPreferences.getInstance();
  StartupFlags.onboardingDone = prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
  StartupFlags.pinSet = prefs.getBool(AppConstants.keyParentPinSet) ?? false;
}

/// Global redirect — deliberately **only** gates the initial launch
/// destination (splash). Every in-app route, including the whole scan flow,
/// returns null so navigation is never bounced mid-flow.
String? _globalRedirect(BuildContext context, GoRouterState state) {
  // Only the launch destination is gated; everything else proceeds freely.
  if (state.matchedLocation != AppRoutes.splash) return null;

  if (!StartupFlags.onboardingDone) return AppRoutes.onboarding;
  if (!StartupFlags.pinSet) return AppRoutes.parentPin;
  return null; // returning user — let the splash screen route onward
}

class _RouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Could add analytics tracking here
  }
}
