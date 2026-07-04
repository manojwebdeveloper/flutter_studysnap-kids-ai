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

  static const _pages = [_OBPage1(), _OBPage2(), _OBPage3()];

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
    } else {
      context.go(AppRoutes.parentPin);
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(alignment: Alignment.centerRight,
              child: Padding(padding: const EdgeInsets.fromLTRB(0, 8, 20, 0),
                child: TextButton(onPressed: () => context.go(AppRoutes.parentPin),
                  child: const Text('Skip', style: TextStyle(color: AppColours.textMuted, fontWeight: FontWeight.w600))),
              )),
            Expanded(child: PageView(controller: _controller,
              onPageChanged: (i) => setState(() => _page = i),
              children: _pages)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Dots
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _page == i ? 22 : 8, height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? AppColours.blue : AppColours.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ))),
            const SizedBox(height: 20),
            PrimaryButton(
              label: _page == _pages.length - 1 ? 'Get Started' : 'Next',
              onPressed: _next,
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Page layouts ──────────────────────────────────────────

class _OBPage extends StatelessWidget {
  const _OBPage({required this.illustration, required this.title, required this.body});
  final Widget illustration;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity, height: 210,
        margin: const EdgeInsets.only(top: 8, bottom: 28),
        decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(24)),
        child: ClipRRect(borderRadius: BorderRadius.circular(24), child: illustration),
      ),
      Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
          color: AppColours.textDark, letterSpacing: -.3, height: 1.25)),
      const SizedBox(height: 10),
      Text(body, style: AppTextStyles.body),
    ]),
  );
}

class _OBPage1 extends StatelessWidget {
  const _OBPage1();
  @override
  Widget build(BuildContext context) => _OBPage(
    title: 'Scan Any Worksheet',
    body: 'Take a photo of school notes, spelling lists or revision pages. Best with good light and a flat page.',
    illustration: Stack(children: [
      Positioned(right: 28, top: 20, child: Transform.rotate(angle: .09,
        child: Container(width: 118, height: 154,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.10), blurRadius: 24, offset: const Offset(0, 4))])))),
      Positioned(left: 28, top: 26, child: Transform.rotate(angle: -.07,
        child: Container(width: 152, padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.12), blurRadius: 28, offset: const Offset(0, 6))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('YEAR 4 · MATHS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColours.blue, letterSpacing: .5)),
            SizedBox(height: 5),
            Text('Fractions Practice', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColours.textDark)),
            SizedBox(height: 18),
            Text('📷', style: TextStyle(fontSize: 32)),
          ])))),
      Positioned(right: 38, bottom: 18,
        child: Container(width: 42, height: 42,
          decoration: BoxDecoration(color: AppColours.blue, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColours.blue.withOpacity(.4), blurRadius: 14, offset: const Offset(0, 4))]),
          child: const Center(child: Text('📸', style: TextStyle(fontSize: 20))))),
    ]),
  );
}

class _OBPage2 extends StatelessWidget {
  const _OBPage2();
  @override
  Widget build(BuildContext context) => _OBPage(
    title: 'Create Flashcards & Quizzes',
    body: 'Turn worksheets into age-friendly flashcards, quizzes and simple explanations.',
    illustration: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 100, height: 128,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.10), blurRadius: 20, offset: const Offset(0, 4))]),
        child: const Center(child: Text('WORK\nSHEET', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColours.textMuted, letterSpacing: 1)))),
      const SizedBox(width: 12),
      const Text('→', style: TextStyle(fontSize: 20, color: AppColours.blue, fontWeight: FontWeight.w700)),
      const SizedBox(width: 12),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _fqCard('FLASHCARD', 'What is ½ of 10?', AppColours.blue),
        const SizedBox(height: 8),
        _fqCard('QUIZ',      '8 questions',       AppColours.purple),
        const SizedBox(height: 8),
        _fqCard('EXPLAINER', 'Simple words',      AppColours.teal),
      ]),
    ]),
  );

  Widget _fqCard(String type, String label, Color colour) => Container(
    width: 155, padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border(left: BorderSide(color: colour, width: 3)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 12, offset: const Offset(0, 3))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(type, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColours.textMuted, letterSpacing: .5)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.textDark)),
    ]),
  );
}

class _OBPage3 extends StatelessWidget {
  const _OBPage3();
  @override
  Widget build(BuildContext context) => _OBPage(
    title: 'Track Learning Progress',
    body: 'See quiz scores, weak topics, stars, streaks and recent learning at a glance.',
    illustration: Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 20, offset: const Offset(0, 4))]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppColours.blueLight, shape: BoxShape.circle),
              child: const Center(child: Text('🚀', style: TextStyle(fontSize: 18)))),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text("Aarav's Week", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColours.textDark)),
              Text('Year 4 · Maths + English', style: TextStyle(fontSize: 12, color: AppColours.textMuted)),
            ]),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            _stat('⭐', '240', 'Stars'),
            _stat('🔥', '4 days', 'Streak'),
            _stat('🏆', '3', 'Badges'),
          ]),
        ]),
      )),
  );

  Widget _stat(String icon, String value, String label) => Expanded(
    child: Container(margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(color: AppColours.subtle, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColours.textDark)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColours.textMuted, fontWeight: FontWeight.w700)),
      ]),
    ),
  );
}
