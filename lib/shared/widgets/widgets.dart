import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/config/app_constants.dart';
import '../../core/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════
// RESPONSIVE BODY — centres & caps content on iPad / tablets
// ═══════════════════════════════════════════════════════

/// Wraps page content so it never stretches uncomfortably wide on large
/// screens (iPad, large Android tablets, foldables). On phones it is a
/// no-op. Follows Apple HIG & Material adaptive-layout guidance.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = AppConstants.contentMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

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
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onPressed!();
              }
            : null,
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
    final container = Container(
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
    );

    if (onTap == null) return container;

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap!();
        },
        child: container,
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
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return Semantics(
      button: true,
      label: label ?? 'Back',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppConstants.minTapTarget,
            minWidth: AppConstants.minTapTarget,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                // Platform-correct affordance: chevron on iOS, arrow on Android.
                isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
                color: AppColours.blue,
                size: 20,
              ),
              if (label != null) ...[
                const SizedBox(width: 2),
                Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColours.blue,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// NAV BACK ICON BUTTON — adaptive AppBar leading
// ═══════════════════════════════════════════════════════

/// AppBar `leading` back button that shows the platform-correct icon
/// (iOS chevron vs Material arrow), a 48dp tap target, and a localised
/// "Back" tooltip/semantics. Use where back navigation is custom
/// (e.g. `context.go(...)`) rather than a plain pop.
class NavBackIconButton extends StatelessWidget {
  const NavBackIconButton({super.key, required this.onPressed, this.colour = AppColours.blue});
  final VoidCallback onPressed;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return IconButton(
      icon: Icon(
        isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
        color: colour,
        size: 20,
      ),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: onPressed,
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

// ═══════════════════════════════════════════════════════
// SVG ICON HELPER
// ═══════════════════════════════════════════════════════

String _svgHex(Color c) {
  // ignore: deprecated_member_use
  final rgb = c.value & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0')}';
}

/// Renders a single SVG path. Pass [stroke] for outline icons (round
/// linecap/linejoin) or [fill] for solid icons. viewBox is 24×24.
Widget appSvg(
  String path, {
  required double size,
  Color? stroke,
  Color? fill,
  double strokeWidth = 2,
}) {
  final fillAttr = fill != null ? _svgHex(fill) : 'none';
  final strokeAttr = stroke != null
      ? 'stroke="${_svgHex(stroke)}" stroke-width="$strokeWidth" '
          'stroke-linecap="round" stroke-linejoin="round"'
      : '';
  final doc =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">'
      '<path d="$path" fill="$fillAttr" $strokeAttr/></svg>';
  return SvgPicture.string(doc, width: size, height: size);
}

// ═══════════════════════════════════════════════════════
// LOGO MARK (splash)
// ═══════════════════════════════════════════════════════

class LogoMark extends StatelessWidget {
  const LogoMark({super.key});

  static const _bookPath =
      'M3 6a2 2 0 012-2h8a4 4 0 014 4v12a3 3 0 00-3-3H5a2 2 0 01-2-2V6z';
  static const _starPath =
      'M12 2l3 7h7l-5.5 4.5L18 21l-6-4-6 4 1.5-7.5L2 9h7l3-7z';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      height: 108,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColours.blue, AppColours.purple],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColours.blue.withOpacity(0.44),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: appSvg(_bookPath, size: 52, stroke: Colors.white, strokeWidth: 2),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColours.amber,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColours.amber.withOpacity(0.66),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(child: appSvg(_starPath, size: 18, fill: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// KID STAT BUBBLE
// ═══════════════════════════════════════════════════════

class KidStatBubble extends StatelessWidget {
  const KidStatBubble({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
  });
  final String emoji, value, label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          Text(value,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.75))),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SUBJECT PROGRESS ROW (kid)
// ═══════════════════════════════════════════════════════

class SubjectProgressRow extends StatelessWidget {
  const SubjectProgressRow({
    super.key,
    required this.subject,
    required this.emoji,
    required this.colour,
    required this.done,
    required this.total,
  });
  final String subject, emoji;
  final Color colour;
  final int done, total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colour.withOpacity(0.22), width: 2),
        boxShadow: [
          BoxShadow(color: colour.withOpacity(0.18), offset: const Offset(0, 3), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colour.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject,
                    style: GoogleFonts.nunito(
                        fontSize: 15, fontWeight: FontWeight.w900, color: AppColours.kidInk)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: colour.withOpacity(0.14),
                    valueColor: AlwaysStoppedAnimation<Color>(colour),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.chevron_right, color: colour),
        ],
      ),
    );
  }
}
