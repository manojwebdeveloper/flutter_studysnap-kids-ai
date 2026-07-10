import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';

const _checkPath = 'M5 13l4 4L19 7';

class _Option {
  const _Option(this.word, this.sound, this.tint);
  final String word, sound;
  final Color tint;
}

class PhonicsListenScreen extends StatefulWidget {
  const PhonicsListenScreen({super.key});
  @override
  State<PhonicsListenScreen> createState() => _PhonicsListenScreenState();
}

class _PhonicsListenScreenState extends State<PhonicsListenScreen> {
  int? _selected;
  static const _correct = 0;

  static const _options = [
    _Option('rain', 'ai says /ay/', AppColours.kidGreen),
    _Option('ran', 'short a /a/', AppColours.kidBlue),
    _Option('red', 'short e /e/', AppColours.kidPurple),
    _Option('run', 'short u /u/', AppColours.kidPink),
  ];

  bool get _answered => _selected != null;
  bool get _gotIt => _selected == _correct;

  void _pick(int i) {
    HapticFeedback.lightImpact();
    setState(() => _selected = i);
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
              child: _progressBar(0.6),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _speakerButton(),
                    const SizedBox(height: 14),
                    Text('Tap to hear', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                    const SizedBox(height: 8),
                    _slowPill(),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Which word did you hear?',
                          style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.35,
                      children: List.generate(_options.length, (i) => _optionCard(i)),
                    ),
                    if (_answered && _gotIt) ...[
                      const SizedBox(height: 14),
                      _feedbackCard(),
                    ],
                    const SizedBox(height: 20),
                    if (_answered && _gotIt)
                      Kid3dButton(
                        label: 'Next →',
                        onPressed: () => context.go(AppRoutes.learningPath),
                        colour: AppColours.kidGreen,
                        darkColour: AppColours.kidGreenDark,
                      ),
                  ],
                ),
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
                  Text('PHONICS · LONG VOWELS',
                      style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: AppColours.kidMuted, letterSpacing: 0.4)),
                  Text('Listen & Pick', style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
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
                gradient: LinearGradient(colors: [AppColours.kidGreen, AppColours.kidGreenDark]),
              ),
            ),
          ),
        ),
      );

  Widget _speakerButton() => GestureDetector(
        onTap: () => HapticFeedback.mediumImpact(),
        child: SizedBox(
          width: 190,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColours.kidGreen, AppColours.kidBlue],
                  ),
                  boxShadow: [
                    const BoxShadow(color: AppColours.kidGreenDark, offset: Offset(0, 8)),
                    BoxShadow(color: AppColours.kidGreen.withOpacity(0.15), spreadRadius: 12),
                    BoxShadow(color: AppColours.kidGreen.withOpacity(0.44), blurRadius: 32, offset: const Offset(0, 14)),
                  ],
                ),
                child: const Center(child: Text('🔊', style: TextStyle(fontSize: 54))),
              ),
              Positioned(
                right: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _wave(14, 0.9),
                    const SizedBox(height: 4),
                    _wave(22, 0.6),
                    const SizedBox(height: 4),
                    _wave(10, 0.35),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _wave(double w, double opacity) => Container(
        width: w,
        height: 4,
        decoration: BoxDecoration(
          color: AppColours.kidGreen.withOpacity(opacity),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _slowPill() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 2)],
        ),
        child: Text('🐢 Hear it slowly',
            style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: AppColours.kidMuted)),
      );

  Widget _optionCard(int i) {
    final opt = _options[i];
    final showCorrect = _answered && i == _correct;
    return GestureDetector(
      onTap: _answered ? null : () => _pick(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: showCorrect ? AppColours.kidGreen : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: showCorrect ? null : Border.all(color: opt.tint.withOpacity(0.33), width: 2.5),
          boxShadow: showCorrect
              ? const [BoxShadow(color: AppColours.kidGreenDark, offset: Offset(0, 5))]
              : [BoxShadow(color: opt.tint.withOpacity(0.22), offset: const Offset(0, 3))],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(opt.word,
                    style: GoogleFonts.nunito(
                        fontSize: 24, fontWeight: FontWeight.w900, color: showCorrect ? Colors.white : AppColours.kidInk)),
                const SizedBox(height: 4),
                Text(opt.sound,
                    style: GoogleFonts.nunito(
                        fontSize: 11, fontWeight: FontWeight.w800, color: showCorrect ? Colors.white.withOpacity(0.9) : opt.tint)),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: showCorrect
                  ? Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Center(child: appSvg(_checkPath, size: 14, stroke: AppColours.kidGreen, strokeWidth: 3)),
                    )
                  : Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(color: opt.tint.withOpacity(0.15), shape: BoxShape.circle),
                      child: const Center(child: Text('🔊', style: TextStyle(fontSize: 11))),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feedbackCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColours.kidGreen.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColours.kidGreen.withOpacity(0.44), width: 1.5),
        ),
        child: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text('That\'s right! "rain" has the long /ay/ sound.',
                  style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppColours.kidGreenDark, height: 1.4)),
            ),
          ],
        ),
      );
}
