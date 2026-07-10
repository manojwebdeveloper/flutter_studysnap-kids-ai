import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';

const _amber = Color(0xFFF59E0B);
const _amberBg = Color(0xFFFEF3C7);
const _amberDark = Color(0xFFB45309);
const _greenSaid = Color(0xFF16A34A);

class SpeakAloudScreen extends StatefulWidget {
  const SpeakAloudScreen({super.key});
  @override
  State<SpeakAloudScreen> createState() => _SpeakAloudScreenState();
}

class _SpeakAloudScreenState extends State<SpeakAloudScreen> {
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
              child: _progressBar(0.75),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  children: [
                    _sentenceCard(),
                    _micArea(),
                    _feedbackCard(),
                  ],
                ),
              ),
            ),
            _bottomBar(context),
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
                  Text('READING · SAY IT ALOUD',
                      style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: AppColours.kidMuted, letterSpacing: 0.4)),
                  Text('Speak Up', style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                ],
              ),
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
                gradient: LinearGradient(colors: [AppColours.kidPink, AppColours.kidPurple]),
              ),
            ),
          ),
        ),
      );

  // ── Sentence card ──────────────────────────────────────
  Widget _sentenceCard() => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColours.kidPink.withOpacity(0.33), width: 3),
          boxShadow: [BoxShadow(color: AppColours.kidPink.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _pill('READ THIS ALOUD', AppColours.kidPink, Colors.white),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColours.kidBlue.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    children: [
                      const Text('🔊', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text('Hear it first',
                          style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900, color: AppColours.kidBlueDark)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            RichText(
              text: TextSpan(
                style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w900, height: 1.5),
                children: [
                  const TextSpan(text: 'The squirrels ', style: TextStyle(color: _greenSaid)),
                  const TextSpan(text: 'hid the ', style: TextStyle(color: _greenSaid)),
                  TextSpan(
                    text: 'acorns',
                    style: TextStyle(color: _amber, background: Paint()..color = _amberBg),
                  ),
                  const TextSpan(text: ' under the tree.', style: TextStyle(color: _greenSaid)),
                ],
              ),
            ),
          ],
        ),
      );

  // ── Mic area ───────────────────────────────────────────
  Widget _micArea() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(15, (i) {
              final spoken = i < 9;
              // Varying bar heights for a waveform look.
              final heights = [10.0, 18.0, 26.0, 16.0, 30.0, 22.0, 34.0, 20.0, 28.0, 16.0, 24.0, 14.0, 20.0, 12.0, 18.0];
              return Container(
                width: 4,
                height: heights[i],
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: spoken ? AppColours.kidPink : AppColours.kidMuted.withOpacity(0.44),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColours.kidPink, AppColours.kidPurple],
              ),
              boxShadow: [
                const BoxShadow(color: AppColours.kidPurpleDark, offset: Offset(0, 6)),
                BoxShadow(color: AppColours.kidPink.withOpacity(0.18), spreadRadius: 10),
                BoxShadow(color: AppColours.kidPink.withOpacity(0.10), spreadRadius: 20),
              ],
            ),
            child: const Center(child: Text('🎤', style: TextStyle(fontSize: 42))),
          ),
          const SizedBox(height: 12),
          Text('Listening…',
              style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: AppColours.kidPink)),
          const SizedBox(height: 16),
        ],
      );

  // ── Feedback card ──────────────────────────────────────
  Widget _feedbackCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColours.kidGreen.withOpacity(0.33), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('So close! 6 of 7 words clear',
                          style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                      Text('One word to practise',
                          style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColours.kidMuted)),
                    ],
                  ),
                ),
                Text('86%', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: AppColours.kidGreenDark)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: _amberBg, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Text('acorns', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: _amberDark)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('AY-kornz',
                        style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: _amberDark)),
                  ),
                  GestureDetector(
                    onTap: () => HapticFeedback.selectionClick(),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Center(child: Text('🔊', style: TextStyle(fontSize: 14))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  // ── Bottom bar ─────────────────────────────────────────
  Widget _bottomBar(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: GestureDetector(
                onTap: () => HapticFeedback.lightImpact(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColours.kidPink.withOpacity(0.44), width: 2.5),
                  ),
                  child: Center(
                    child: Text('🔄 Try Again',
                        style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: AppColours.kidPink)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 14,
              child: Kid3dButton(
                label: 'Next →',
                onPressed: () => context.go(AppRoutes.learningPath),
                colour: AppColours.kidGreen,
                darkColour: AppColours.kidGreenDark,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );

  Widget _pill(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900, color: fg, letterSpacing: 0.4)),
      );
}
