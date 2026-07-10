import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Widget _dot(double opacity) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColours.blue.withOpacity(opacity),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Radial glow — blue, centred 50% 35%
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.3),
                    radius: 0.9,
                    colors: [Color(0x1A2563EB), Color(0x002563EB)],
                  ),
                ),
              ),
            ),
            // Radial glow — purple, centred 50% 80%
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, 0.6),
                    radius: 0.9,
                    colors: [Color(0x1A7C3AED), Color(0x007C3AED)],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    const LogoMark(),
                    const SizedBox(height: 28),
                    const Text(
                      'StudySnap',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColours.ink,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'KIDS · AI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColours.purple,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Scan worksheets into quizzes and flashcards',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(fontSize: 16, color: AppColours.muted),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _dot(0.3),
                        const SizedBox(width: 6),
                        _dot(0.5),
                        const SizedBox(width: 6),
                        _dot(0.7),
                      ],
                    ),
                    const Spacer(flex: 4),
                    const Text(
                      'SCAN · LEARN · PRACTISE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColours.muted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Get Started',
                      onPressed: () => context.go(AppRoutes.onboarding),
                    ),
                    const SizedBox(height: 40),
                  ],
                ).animate().fadeIn(duration: 600.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
