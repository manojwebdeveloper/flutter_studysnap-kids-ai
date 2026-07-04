import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════
// PRIMARY BUTTON (Parent Mode)
// ═══════════════════════════════════════════════════════

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.colour = AppColours.blue,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: enabled ? colour : AppColours.subtle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled ? AppColours.primaryShadow(colour) : [],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: 8)],
                    Text(label, style: AppTextStyles.btnLabel.copyWith(
                      color: enabled ? Colors.white : AppColours.textMuted,
                    )),
                  ],
                ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// KID 3D BUTTON (Kid Mode)
// ═══════════════════════════════════════════════════════

class Kid3dButton extends StatefulWidget {
  const Kid3dButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.colour = AppColours.kidBlue,
    this.darkColour = AppColours.kidBlueDark,
    this.icon,
    this.width = double.infinity,
    this.fontSize = 17,
  });

  final String label;
  final VoidCallback onPressed;
  final Color colour;
  final Color darkColour;
  final Widget? icon;
  final double width;
  final double fontSize;

  @override
  State<Kid3dButton> createState() => _Kid3dButtonState();
}

class _Kid3dButtonState extends State<Kid3dButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { HapticFeedback.lightImpact(); setState(() => _pressed = true); },
      onTapUp: (_) { setState(() => _pressed = false); widget.onPressed(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.width,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
        transform: _pressed ? Matrix4.translationValues(0, 4, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.colour,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _pressed
              ? AppColours.kid3dShadowPressed(widget.darkColour)
              : AppColours.kid3dShadow(widget.colour, widget.darkColour),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 8)],
            Text(widget.label, style: AppTextStyles.kidBtn(size: widget.fontSize)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// APP CARD
// ═══════════════════════════════════════════════════════

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.borderColour,
    this.borderWidth = 1,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color? borderColour;
  final double borderWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColours.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColour ?? AppColours.line,
            width: borderWidth,
          ),
        ),
        child: child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SECTION LABEL
// ═══════════════════════════════════════════════════════

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.topPadding = 18});
  final String text;
  final double topPadding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: topPadding, bottom: 9),
    child: Text(text.toUpperCase(), style: AppTextStyles.sectionLabel),
  );
}

// ═══════════════════════════════════════════════════════
// SUBJECT BADGE (coloured pill)
// ═══════════════════════════════════════════════════════

class SubjectBadge extends StatelessWidget {
  const SubjectBadge(this.subject, {super.key});
  final String subject;

  static const _colours = {
    'Maths':     (Color(0xFFEFF6FF), Color(0xFF2563EB)),
    'English':   (Color(0xFFF5F3FF), Color(0xFF7C3AED)),
    'Science':   (Color(0xFFF0FDFA), Color(0xFF14B8A6)),
    'Spelling':  (Color(0xFFFFFBEB), Color(0xFFF59E0B)),
    'Reading':   (Color(0xFFEFF6FF), Color(0xFF2563EB)),
    'History':   (Color(0xFFF5F3FF), Color(0xFF7C3AED)),
    'Geography': (Color(0xFFF0FDFA), Color(0xFF14B8A6)),
    'Languages': (Color(0xFFFFFBEB), Color(0xFFF59E0B)),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colours[subject] ?? (AppColours.subtle, AppColours.textMuted);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
      child: Text(subject, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ═══════════════════════════════════════════════════════
// STATUS PILL (Live / Review / Pending)
// ═══════════════════════════════════════════════════════

class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, colour) = switch (status) {
      'approved' => ('✓ Live',         AppColours.green),
      'needs_review' => ('● Review',   AppColours.amber),
      'pending'  => ('● Pending',      AppColours.amber),
      _          => (status,           AppColours.textMuted),
    };
    return Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colour));
  }
}

// ═══════════════════════════════════════════════════════
// BACK BUTTON (iOS-style)
// ═══════════════════════════════════════════════════════

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.label, this.onPressed});
  final String? label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.of(context).pop(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_back_ios, color: AppColours.blue, size: 20),
          if (label != null)
            Text(label!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColours.blue)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// XP PROGRESS BAR
// ═══════════════════════════════════════════════════════

class XpProgressBar extends StatelessWidget {
  const XpProgressBar({super.key, required this.progress, this.height = 9});
  final double progress; // 0.0 to 1.0
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(99),
      ),
      child: FractionallySizedBox(
        widthFactor: progress.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColours.kidBlue, AppColours.kidYellow],
            ),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// PROGRESS BAR (parent mode)
// ═══════════════════════════════════════════════════════

class ScoreProgressBar extends StatelessWidget {
  const ScoreProgressBar({super.key, required this.value, this.colour = AppColours.blue});
  final double value; // 0.0–1.0
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: AppColours.subtle,
        borderRadius: BorderRadius.circular(99),
      ),
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: colour,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}
