import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Shared building blocks for Parent Mode screens.
/// UI only — no providers or business logic here.

// Per-child accent palette (entities carry no colour, so derive one by index).
const List<Color> _childPalette = [
  AppColours.blue,
  AppColours.purple,
  AppColours.teal,
  AppColours.amber,
  AppColours.kidPink,
];

Color childColour(int index) => _childPalette[index % _childPalette.length];

/// Small rounded pill label.
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, required this.bg, required this.fg});
  final String text;
  final Color bg, fg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(
          text,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
        ),
      );
}

/// Section header with an optional trailing action link.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.actionLabel, this.onAction});
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColours.ink),
          ),
          const Spacer(),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColours.blue),
              ),
            ),
        ],
      );
}

/// A child avatar — emoji inside a tinted, ringed circle.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.emoji,
    this.size = 44,
    this.colour = AppColours.blue,
  });
  final String emoji;
  final double size;
  final Color colour;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colour.withOpacity(0.14),
          shape: BoxShape.circle,
          border: Border.all(color: colour.withOpacity(0.35), width: 2),
        ),
        child: Center(child: Text(emoji, style: TextStyle(fontSize: size * 0.5))),
      );
}

/// A tinted rounded square holding an icon or emoji (list-row leading).
class IconSquare extends StatelessWidget {
  const IconSquare({
    super.key,
    required this.child,
    this.colour = AppColours.blue,
    this.size = 42,
    this.radius = 13,
  });
  final Widget child;
  final Color colour;
  final double size, radius;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colour.withOpacity(0.14),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Center(child: child),
      );
}
