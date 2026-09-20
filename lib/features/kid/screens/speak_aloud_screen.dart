import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';

/// "Speak Up" — a read-aloud activity. Real speech recognition and scoring
/// aren't wired up yet, so this shows a friendly empty state instead of the
/// sample sentence and fabricated "86%" accuracy score it used to display.
class SpeakAloudScreen extends StatelessWidget {
  const SpeakAloudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.kidBackground,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            const Expanded(
              child: KidEmptyState(
                emoji: '🎤',
                title: 'No reading activities yet',
                message: 'Ask a grown-up to scan a worksheet — reading activities will appear here!',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 20, 6),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.go(AppRoutes.learningPath),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: const Center(child: Icon(Icons.close, size: 20, color: AppColours.kidInk)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('READING',
                      style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: AppColours.kidMuted, letterSpacing: 0.4)),
                  Text('Speak Up', style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                ],
              ),
            ),
          ],
        ),
      );
}
