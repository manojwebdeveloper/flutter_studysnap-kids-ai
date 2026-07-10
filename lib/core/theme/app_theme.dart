import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────
// COLOURS
// ─────────────────────────────────────────────────────────

abstract class AppColours {
  // Parent Mode
  static const blue        = Color(0xFF2563EB);
  static const blueLight   = Color(0xFFEFF6FF);
  static const blueMid     = Color(0xFFDBEAFE);
  static const purple      = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFF5F3FF);
  static const teal        = Color(0xFF14B8A6);
  static const tealLight   = Color(0xFFF0FDFA);
  static const bg          = Color(0xFFF8FAFC);
  static const card        = Color(0xFFFFFFFF);
  static const subtle      = Color(0xFFF1F5F9);
  static const textDark    = Color(0xFF111827);
  static const textInk     = Color(0xFF1F2937);
  static const textMuted   = Color(0xFF6B7280);
  static const line        = Color(0xFFE5E7EB);
  static const green       = Color(0xFF22C55E);
  static const greenLight  = Color(0xFFF0FDF4);
  static const amber       = Color(0xFFF59E0B);
  static const amberLight  = Color(0xFFFFFBEB);
  static const red         = Color(0xFFEF4444);
  static const redLight    = Color(0xFFFEF2F2);

  // ── Spec-named aliases (identical values) ────────────────
  static const background  = bg;        // #F8FAFC
  static const ink         = textDark;  // #111827
  static const ink2        = textInk;   // #1F2937
  static const muted       = textMuted; // #6B7280

  // Kid Mode
  static const kidBlue      = Color(0xFF38BDF8);
  static const kidBlueDark  = Color(0xFF0284C7);
  static const kidYellow    = Color(0xFFFACC15);
  static const kidPurple    = Color(0xFFA78BFA);
  static const kidPurpleDark= Color(0xFF7C3AED);
  static const kidGreen     = Color(0xFF4ADE80);
  static const kidGreenDark = Color(0xFF16A34A);
  static const kidPink      = Color(0xFFFB7185);
  static const kidBg        = Color(0xFFF0F9FF);
  static const kidBackground = kidBg;              // #F0F9FF
  static const kidInk        = Color(0xFF1E293B);  // #1E293B
  static const kidMuted      = Color(0xFF64748B);  // #64748B

  // Shadows
  static List<BoxShadow> primaryShadow(Color c) => [
    BoxShadow(color: c.withOpacity(.28), blurRadius: 18, offset: const Offset(0, 6)),
  ];

  static List<BoxShadow> cardShadow() => [
    BoxShadow(color: textDark.withOpacity(.06), blurRadius: 20, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> kid3dShadow(Color colour, Color dark) => [
    BoxShadow(color: dark, offset: const Offset(0, 5), blurRadius: 0),
    BoxShadow(color: colour.withOpacity(.30), blurRadius: 20, offset: const Offset(0, 8)),
  ];

  static List<BoxShadow> kid3dShadowPressed(Color dark) => [
    BoxShadow(color: dark, offset: const Offset(0, 1), blurRadius: 0),
  ];
}

// ─────────────────────────────────────────────────────────
// TEXT STYLES
// ─────────────────────────────────────────────────────────

abstract class AppTextStyles {
  // Parent — system font (SF Pro Rounded on iOS)
  static TextStyle screenTitle({double size = 24}) => TextStyle(
    fontSize: size, fontWeight: FontWeight.w800,
    color: AppColours.textDark, letterSpacing: -.3,
  );

  static const topBarTitle = TextStyle(
    fontSize: 21, fontWeight: FontWeight.w800,
    color: AppColours.textDark, letterSpacing: -.2,
  );

  static TextStyle cardHeading({double size = 15}) => TextStyle(
    fontSize: size, fontWeight: FontWeight.w800, color: AppColours.textDark,
  );

  static const body = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColours.textMuted, height: 1.55,
  );

  static const bodySmall = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w600,
    color: AppColours.textMuted, height: 1.55,
  );

  static const sectionLabel = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w800,
    color: AppColours.textMuted, letterSpacing: .8,
  );

  static const caption = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w600, color: AppColours.textMuted,
  );

  static const btnLabel = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700,
    color: Colors.white, letterSpacing: .1,
  );

  // Kid — Nunito
  static TextStyle kidHeading({double size = 24}) => GoogleFonts.nunito(
    fontSize: size, fontWeight: FontWeight.w900,
    color: AppColours.textDark, letterSpacing: -.3,
  );

  static TextStyle kidBody({double size = 14}) => GoogleFonts.nunito(
    fontSize: size, fontWeight: FontWeight.w700,
    color: AppColours.textMuted, height: 1.55,
  );

  static TextStyle kidQuestion({double size = 26}) => GoogleFonts.nunito(
    fontSize: size, fontWeight: FontWeight.w900,
    color: AppColours.textDark, height: 1.3,
  );

  static TextStyle kidBtn({double size = 17}) => GoogleFonts.nunito(
    fontSize: size, fontWeight: FontWeight.w900, color: Colors.white,
  );

  static TextStyle kidLabel({double size = 10}) => GoogleFonts.nunito(
    fontSize: size, fontWeight: FontWeight.w800, color: AppColours.textMuted,
  );
}

// ─────────────────────────────────────────────────────────
// THEME
// ─────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColours.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColours.blue,
      brightness: Brightness.light,
      background: AppColours.bg,
      surface: AppColours.card,
      primary: AppColours.blue,
      secondary: AppColours.purple,
      tertiary: AppColours.teal,
      error: AppColours.red,
    ),
    cardTheme: CardThemeData(
      color: AppColours.card, elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColours.line),
      ),
      margin: EdgeInsets.zero,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColours.card,
      foregroundColor: AppColours.textDark,
      elevation: 0, scrolledUnderElevation: 0,
      titleTextStyle: AppTextStyles.topBarTitle,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColours.line, thickness: 1, space: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: AppColours.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColours.line, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColours.line, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColours.blue, width: 2),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColours.card,
      selectedItemColor: AppColours.blue,
      unselectedItemColor: AppColours.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );
}
