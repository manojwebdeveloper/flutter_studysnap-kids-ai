/// All application-wide constants.
/// No magic strings or numbers anywhere else in the codebase.
abstract class AppConstants {
  // ── App ────────────────────────────────────────────────
  static const String appName       = 'StudySnap Kids AI';
  static const String appVersion    = '1.0.0';

  // ── Free plan limits ───────────────────────────────────
  static const int freeScanLimit    = 3;
  static const int freeChildLimit   = 1;

  // ── Subscription ───────────────────────────────────────
  static const String premiumMonthlyId = 'studysnap_premium_monthly';
  static const double premiumPrice     = 4.99;
  static const String premiumCurrency  = 'GBP';
  static const int trialDays           = 7;

  // ── Storage keys (SharedPreferences) ──────────────────
  static const String keyOnboardingDone   = 'onboarding_complete';
  static const String keySelectedChildId  = 'selected_child_id';
  static const String keyParentPinSet     = 'parent_pin_set';
  static const String keyIsPremium        = 'is_premium';
  static const String keyScanCount        = 'scan_count';
  static const String keyTheme            = 'app_theme';

  // ── Secure storage keys ────────────────────────────────
  static const String secureKeyParentPin  = 'parent_pin';
  static const String secureKeyAuthToken  = 'auth_token';

  // ── Database ───────────────────────────────────────────
  static const String dbName             = 'studysnap.db';
  static const int    dbVersion          = 1;

  // ── API ────────────────────────────────────────────────
  static const Duration apiTimeout       = Duration(seconds: 30);
  static const int      apiMaxRetries    = 3;
  static const String   claudeModel      = 'claude-sonnet-4-6';
  static const int      claudeMaxTokens  = 4096;

  // ── Onboarding ─────────────────────────────────────────
  static const List<String> avatarEmojis = [
    '🚀', '⭐', '🐱', '🐶', '🦖', '🤖', '🦄', '🪐',
  ];

  static const List<String> yearGroups = [
    'Reception', 'Year 1', 'Year 2', 'Year 3',
    'Year 4',    'Year 5', 'Year 6', 'Year 7+',
  ];

  static const List<String> yearGroupAges = [
    'Age 4–5', 'Age 5–6', 'Age 6–7', 'Age 7–8',
    'Age 8–9', 'Age 9–10', 'Age 10–11', 'Age 11–13',
  ];

  // ── Subjects ───────────────────────────────────────────
  static const List<Map<String, String>> subjects = [
    {'emoji': '➗', 'label': 'Maths',     'colour': 'blue'},
    {'emoji': '📖', 'label': 'English',   'colour': 'purple'},
    {'emoji': '🧪', 'label': 'Science',   'colour': 'teal'},
    {'emoji': '✏️', 'label': 'Spelling',  'colour': 'amber'},
    {'emoji': '📚', 'label': 'Reading',   'colour': 'blue'},
    {'emoji': '🏺', 'label': 'History',   'colour': 'purple'},
    {'emoji': '🌍', 'label': 'Geography', 'colour': 'teal'},
    {'emoji': '🗣',  'label': 'Languages', 'colour': 'amber'},
    {'emoji': '➕', 'label': 'Other',     'colour': 'blue'},
  ];

  // ── Kid Mode ───────────────────────────────────────────
  static const int   maxHearts         = 5;
  static const int   xpPerFlashcard    = 5;
  static const int   xpPerQuizCorrect  = 10;
  static const int   xpPerLesson       = 30;
  static const int   xpLevelThreshold  = 500;
  static const int   starsPerQuiz      = 16;

  // ── OCR ────────────────────────────────────────────────
  static const double ocrLowConfidence = 0.85;

  // ── Animation durations ────────────────────────────────
  static const Duration animFast    = Duration(milliseconds: 150);
  static const Duration animNormal  = Duration(milliseconds: 260);
  static const Duration animSlow    = Duration(milliseconds: 400);

  // ── UI ─────────────────────────────────────────────────
  static const double cardRadius    = 20.0;
  static const double btnRadius     = 16.0;
  static const double chipRadius    = 999.0;
  static const double avatarRadius  = 18.0;
  static const double screenPadH   = 20.0;

  // ── Spacing scale (4pt grid) ───────────────────────────
  static const double space4  = 4.0;
  static const double space8  = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // ── Responsive / large screens (iPad, foldables) ───────
  /// Content wider than this is centred and capped so text lines and
  /// controls stay comfortable on iPad and large Android tablets.
  static const double contentMaxWidth = 560.0;

  // ── Accessibility ──────────────────────────────────────
  /// Minimum touch-target size (Apple HIG 44pt / Material 48dp → use 48).
  static const double minTapTarget = 48.0;
}
