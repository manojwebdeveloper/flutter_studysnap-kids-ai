import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Logo
            const LogoMark()
                .animate()
                .scale(begin: const Offset(.6, .6), duration: 500.ms, curve: Curves.elasticOut, delay: 100.ms),

            const SizedBox(height: 28),

            const Text('StudySnap',
              style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: AppColours.textDark, letterSpacing: -.5),
            ).animate(delay: 250.ms).fadeIn(duration: 350.ms).slideY(begin: .3, end: 0),

            const SizedBox(height: 6),

            const Text('KIDS · AI',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColours.blue, letterSpacing: 3),
            ).animate(delay: 350.ms).fadeIn(duration: 350.ms).slideY(begin: .3, end: 0),

            const SizedBox(height: 14),

            const Text('Scan worksheets into quizzes\nand flashcards',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ).animate(delay: 420.ms).fadeIn(duration: 350.ms),

            const SizedBox(height: 52),

            const Text('SCAN · LEARN · PRACTISE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColours.textMuted, letterSpacing: 3),
            ).animate(delay: 480.ms).fadeIn(duration: 350.ms),

            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: PrimaryButton(
            label: 'Get Started',
            onPressed: () => context.go(AppRoutes.onboarding),
          ).animate(delay: 540.ms).fadeIn(duration: 350.ms).slideY(begin: .2, end: 0),
        ),
      ),
    );
  }
}
