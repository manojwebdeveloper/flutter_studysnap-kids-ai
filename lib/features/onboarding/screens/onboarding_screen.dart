import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  void _next() {
    if (_page < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go(AppRoutes.parentPin);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: _controller,
          onPageChanged: (i) => setState(() => _page = i),
          children: [
            _OnboardPage(
              page: _page,
              title: 'Scan Any Worksheet',
              body:
                  'Take a photo of school notes, spelling lists or revision pages. Best with good light and a flat page.',
              cta: 'Next',
              art: const _ArtPage1(),
              onSkip: () => context.go(AppRoutes.parentPin),
              onNext: _next,
            ),
            _OnboardPage(
              page: _page,
              title: 'Create Flashcards & Quizzes',
              body:
                  'Turn worksheets into age-friendly flashcards, quizzes and simple explanations.',
              cta: 'Next',
              art: const _ArtPage2(),
              onSkip: () => context.go(AppRoutes.parentPin),
              onNext: _next,
            ),
            _OnboardPage(
              page: _page,
              title: 'Track Learning Progress',
              body:
                  'See quiz scores, weak topics, stars, streaks and recent learning at a glance.',
              cta: 'Get Started',
              art: const _ArtPage3(),
              onSkip: () => context.go(AppRoutes.parentPin),
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page scaffold ─────────────────────────────────────────

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({
    required this.page,
    required this.title,
    required this.body,
    required this.cta,
    required this.art,
    required this.onSkip,
    required this.onNext,
  });

  final int page;
  final String title, body, cta;
  final Widget art;
  final VoidCallback onSkip, onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(3, (i) {
                  final active = i == page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 6),
                    width: active ? 24 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? AppColours.blue : AppColours.line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
              TextButton(
                onPressed: onSkip,
                child: const Text('Skip',
                    style: TextStyle(color: AppColours.muted, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          art,
          Padding(
            padding: const EdgeInsets.only(top: 36),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColours.ink,
                letterSpacing: -0.6,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(body,
              style: const TextStyle(fontSize: 16, color: AppColours.muted, height: 1.5)),
          const SizedBox(height: 24),
          PrimaryButton(label: cta, onPressed: onNext),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Page 1 art ────────────────────────────────────────────

class _ArtPage1 extends StatelessWidget {
  const _ArtPage1();

  Widget _bar(double frac) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: frac,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppColours.subtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );

  Widget _corner({double? top, double? left, double? right, double? bottom}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
            bottom: bottom != null ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
            left: left != null ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
            right: right != null ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          // Tilted worksheet card
          Positioned(
            left: 40,
            top: 30,
            child: Transform.rotate(
              angle: -6 * math.pi / 180,
              child: Container(
                width: 160,
                height: 220,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColours.line),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('YEAR 4 · MATHS',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColours.blue, letterSpacing: 0.6)),
                    const SizedBox(height: 5),
                    const Text('Fractions Practice',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColours.ink)),
                    _bar(0.90),
                    _bar(0.70),
                    _bar(0.85),
                    _bar(0.60),
                    _bar(0.80),
                    _bar(0.50),
                    _bar(0.75),
                  ],
                ),
              ),
            ),
          ),
          // Phone card
          Positioned(
            right: 30,
            bottom: 0,
            child: Transform.rotate(
              angle: 8 * math.pi / 180,
              child: Container(
                width: 150,
                height: 220,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColours.ink,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: AppColours.blue.withOpacity(0.33), blurRadius: 32, offset: const Offset(0, 16)),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColours.blue, AppColours.purple],
                    ),
                  ),
                  child: Stack(
                    children: [
                      _corner(top: 12, left: 12),
                      _corner(top: 12, right: 12),
                      _corner(bottom: 12, left: 12),
                      _corner(bottom: 12, right: 12),
                      const Center(child: Text('📷', style: TextStyle(fontSize: 36))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 2 art ────────────────────────────────────────────

class _ArtPage2 extends StatelessWidget {
  const _ArtPage2();

  Widget _outputCard(String label, String value, Color tint, Color bg) => Container(
        width: 130,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: tint.withOpacity(0.18), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: tint, letterSpacing: 0.5)),
            const SizedBox(height: 3),
            Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.ink)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: -4 * math.pi / 180,
                child: Container(
                  width: 100,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColours.line),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Center(
                    child: Text('WORK\nSHEET',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColours.muted, letterSpacing: 1)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              appSvg('M5 12h14M13 6l6 6-6 6', size: 24, stroke: AppColours.purple, strokeWidth: 2),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _outputCard('FLASHCARD', 'What is ½ of 10?', AppColours.blue, AppColours.blueLight),
                  const SizedBox(height: 8),
                  _outputCard('QUIZ', '8 questions', AppColours.purple, AppColours.purpleLight),
                  const SizedBox(height: 8),
                  _outputCard('EXPLAINER', 'Simple words', AppColours.teal, AppColours.tealLight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page 3 art ────────────────────────────────────────────

class _ArtPage3 extends StatelessWidget {
  const _ArtPage3();

  Widget _bar(double frac) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80 * frac,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColours.blue, AppColours.purple],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      );

  Widget _stat(String emoji, String value, String label) => Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColours.ink)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColours.muted, fontWeight: FontWeight.w700)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColours.line),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(color: AppColours.blueLight, shape: BoxShape.circle),
                      child: const Center(child: Text('🚀', style: TextStyle(fontSize: 18))),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("This Week",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColours.ink)),
                        Text('Year 4 · Maths + English',
                            style: TextStyle(fontSize: 12, color: AppColours.muted)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 80,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _bar(0.40),
                      _bar(0.65),
                      _bar(0.50),
                      _bar(0.80),
                      _bar(0.70),
                      _bar(0.90),
                      _bar(0.75),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _stat('⭐', '240', 'Stars')),
                    Expanded(child: _stat('🔥', '4 days', 'Streak')),
                    Expanded(child: _stat('🏆', '3', 'Badges')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
