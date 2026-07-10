import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';

const _greyscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);

enum _Mode { type, draw }

class WritingStudioScreen extends StatefulWidget {
  const WritingStudioScreen({super.key});
  @override
  State<WritingStudioScreen> createState() => _WritingStudioScreenState();
}

class _WritingStudioScreenState extends State<WritingStudioScreen>
    with SingleTickerProviderStateMixin {
  _Mode _mode = _Mode.type;
  int _tool = 0; // 0 pencil, 1 crayon, 2 eraser, 3 undo
  late AnimationController _cursor;

  @override
  void initState() {
    super.initState();
    _cursor = AnimationController(vsync: this, duration: const Duration(milliseconds: 550))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.kidBackground,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _progressBar(0.2),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: _promptCard(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _modeToggle(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _mode == _Mode.type ? _typeSurface() : _drawSurface(),
              ),
            ),
            _bottomBar(context),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────
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
                  Text('ENGLISH · CREATIVE WRITING',
                      style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: AppColours.kidMuted, letterSpacing: 0.4)),
                  Text('Writing Studio', style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                ],
              ),
            ),
            Row(
              children: List.generate(5, (i) {
                const heart = Text('❤️', style: TextStyle(fontSize: 18));
                return Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: i < 3 ? heart : const Opacity(opacity: 0.35, child: ColorFiltered(colorFilter: _greyscale, child: heart)),
                );
              }),
            ),
          ],
        ),
      );

  Widget _progressBar(double value) => ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 2)],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColours.kidPurple, AppColours.kidPurpleDark]),
              ),
            ),
          ),
        ),
      );

  // ── Prompt card ────────────────────────────────────────
  Widget _promptCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColours.kidPurple, AppColours.kidBlue],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("TODAY'S PROMPT",
                style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.85), letterSpacing: 0.6)),
            const SizedBox(height: 3),
            Text('Describe your dream treehouse',
                style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white, height: 1.3)),
            const SizedBox(height: 8),
            Row(
              children: [
                _goalPill('🎯 3 sentences'),
                const SizedBox(width: 8),
                _goalPill('✨ Use 2 adjectives'),
              ],
            ),
          ],
        ),
      );

  Widget _goalPill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.22), borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
      );

  // ── Mode toggle ────────────────────────────────────────
  Widget _modeToggle() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 2)],
        ),
        child: Row(
          children: [
            _toggleTab('⌨️ Type', _Mode.type),
            _toggleTab('✏️ Draw', _Mode.draw),
          ],
        ),
      );

  Widget _toggleTab(String label, _Mode mode) {
    final active = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active ? AppColours.kidPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 14, fontWeight: FontWeight.w900, color: active ? Colors.white : AppColours.kidMuted)),
          ),
        ),
      ),
    );
  }

  // ── Type surface ───────────────────────────────────────
  Widget _typeSurface() => Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          border: Border.all(color: AppColours.kidPurple.withOpacity(0.33), width: 2),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _RuledLinesPainter())),
            Padding(
              padding: const EdgeInsets.all(16),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700, color: AppColours.kidInk, height: 31 / 18),
                  children: [
                    const TextSpan(text: 'My treehouse is up in a '),
                    TextSpan(
                        text: 'giant',
                        style: TextStyle(background: Paint()..color = AppColours.kidGreen.withOpacity(0.3))),
                    const TextSpan(text: ' oak tree. It has a rope ladder and a secret door. '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: FadeTransition(
                        opacity: _cursor,
                        child: Container(width: 2, height: 20, color: AppColours.kidPurple),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Row(
                children: [
                  _chip('🌟 Great start!', AppColours.kidGreen.withOpacity(0.14), AppColours.kidGreenDark),
                  const Spacer(),
                  _chip('18 words', AppColours.kidBackground, AppColours.kidMuted),
                ],
              ),
            ),
          ],
        ),
      );

  // ── Draw surface ───────────────────────────────────────
  Widget _drawSurface() => Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          border: Border.all(color: AppColours.kidPurple.withOpacity(0.33), width: 2),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _SchoolLinesPainter())),
            Positioned.fill(child: CustomPaint(painter: _HandwritingPainter())),
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _toolBtn(0, Icons.edit, AppColours.kidPurple),
                  _toolBtn(1, Icons.brush, AppColours.kidMuted),
                  _toolBtn(2, Icons.cleaning_services, AppColours.kidMuted),
                  _toolBtn(3, Icons.undo, AppColours.kidMuted),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _toolBtn(int idx, IconData icon, Color activeColour) {
    final active = _tool == idx;
    return GestureDetector(
      onTap: () => setState(() => _tool = idx),
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: active ? AppColours.kidPurple : const Color(0xFFEDEFF3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 20, color: active ? Colors.white : AppColours.kidMuted),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
      );

  // ── Bottom bar ─────────────────────────────────────────
  Widget _bottomBar(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColours.line)),
        ),
        child: Kid3dButton(
          label: '✅ Done. Read it back to me',
          onPressed: () => context.go(AppRoutes.learningPath),
          colour: AppColours.kidPurple,
          darkColour: AppColours.kidPurpleDark,
        ),
      );
}

// Type mode: grey ruled lines every 31px.
class _RuledLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColours.kidMuted.withOpacity(0.18)
      ..strokeWidth = 1;
    for (double y = 46; y < size.height - 40; y += 31) {
      canvas.drawLine(Offset(12, y), Offset(size.width - 12, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Draw mode: 4-line school ruled lines, alternating blue / pink.
class _SchoolLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()
      ..color = AppColours.kidBlue.withOpacity(0.25)
      ..strokeWidth = 1;
    final pink = Paint()
      ..color = AppColours.kidPink.withOpacity(0.25)
      ..strokeWidth = 1;
    int i = 0;
    for (double y = 40; y < size.height - 50; y += 26) {
      canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), i.isEven ? blue : pink);
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// A sample handwriting stroke path ("hi").
class _HandwritingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColours.kidPurple
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(40, 40)
      ..lineTo(40, 100)
      ..moveTo(40, 74)
      ..cubicTo(48, 60, 70, 60, 70, 78)
      ..lineTo(70, 100)
      ..moveTo(100, 62)
      ..lineTo(100, 100)
      ..moveTo(100, 44)
      ..lineTo(100, 46);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
