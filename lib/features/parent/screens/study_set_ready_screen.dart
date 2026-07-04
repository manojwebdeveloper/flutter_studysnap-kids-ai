// Re-exports so the router import paths resolve correctly.
// All implementations live in choose_output_screen.dart
// (StudySetReadyScreen, EditFlashcardsScreen, EditQuizScreen)
// and switch_kid_mode_screen.dart (everything else).

export 'choose_output_screen.dart'
    show StudySetReadyScreen, EditFlashcardsScreen, EditQuizScreen;
