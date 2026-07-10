import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';

const _lockIcon =
    'M6 10V8a6 6 0 1112 0v2M5 10h14a1 1 0 011 1v9a1 1 0 01-1 1H5a1 1 0 01-1-1v-9a1 1 0 011-1z';

enum NodeState { done, current, locked }

class _PathNode {
  const _PathNode(this.symbol, this.label, this.state, this.stars);
  final String symbol, label;
  final NodeState state;
  final int stars;
}

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});
  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  int _tab = 0;
  static const _tabs = ['Maths', 'English', 'Science 🔒'];
  static const _lockedTab = 2;

  static const _nodes = [
    _PathNode('+', 'Addition', NodeState.done, 3),
    _PathNode('−', 'Subtraction', NodeState.done, 3),
    _PathNode('×', 'Multiplication', NodeState.done, 2),
    _PathNode('½', 'Fractions', NodeState.current, 0),
    _PathNode('📐', 'Geometry', NodeState.locked, 0),
    _PathNode('0.5', 'Decimals', NodeState.locked, 0),
  ];

  static const _offsets = [60.0, 120.0, 60.0, 0.0, 60.0, 120.0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.kidBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Gradient header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColours.kidBlue, AppColours.kidPurple],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.kid),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Icon(Icons.arrow_back, color: Colors.white, size: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Learning Path',
                            style: GoogleFonts.nunito(fontSize: 21, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(999)),
                        child: Text('🔥 4', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(_tabs.length, (i) {
                      final locked = i == _lockedTab;
                      final on = _tab == i;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: locked ? null : () => setState(() => _tab = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: on
                                  ? Colors.white
                                  : Colors.white.withOpacity(locked ? 0.10 : 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(_tabs[i],
                                style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: on
                                        ? AppColours.kidBlue
                                        : Colors.white.withOpacity(locked ? 0.5 : 1))),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            // Progress strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Text('Maths · Year 4', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppColours.kidMuted)),
                  const Spacer(),
                  Text('3/8 done', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: AppColours.kidGreen)),
                ],
              ),
            ),
            // Path
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 12, bottom: 110),
                child: Column(
                  children: [
                    ..._nodes.asMap().entries.map((e) {
                      final node = e.value;
                      final prev = e.key == 0 ? null : _nodes[e.key - 1];
                      return Column(
                        children: [
                          if (e.key != 0)
                            Container(
                              margin: EdgeInsets.only(left: _offsets[e.key % _offsets.length]),
                              width: 3,
                              height: 24,
                              decoration: BoxDecoration(
                                color: prev?.state == NodeState.done ? AppColours.kidGreen.withOpacity(0.44) : AppColours.line,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.only(left: _offsets[e.key % _offsets.length]),
                            child: _NodeWidget(
                              node: node,
                              onTap: node.state == NodeState.current ? () => context.go(AppRoutes.flashcards) : null,
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 280),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColours.line, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          const Text('🔒', style: TextStyle(fontSize: 22)),
                          const SizedBox(height: 6),
                          Text('Finish Fractions to unlock the next topics!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppColours.kidMuted)),
                        ],
                      ),
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
}

class _NodeWidget extends StatefulWidget {
  const _NodeWidget({required this.node, this.onTap});
  final _PathNode node;
  final VoidCallback? onTap;
  @override
  State<_NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<_NodeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: node.state == NodeState.done
                          ? const LinearGradient(colors: [AppColours.kidGreen, AppColours.kidGreenDark])
                          : node.state == NodeState.current
                              ? const LinearGradient(colors: [AppColours.kidBlue, AppColours.kidPurple])
                              : null,
                      color: node.state == NodeState.locked ? const Color(0xFFE2E8F0) : null,
                      border: node.state == NodeState.current ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: node.state == NodeState.current
                          ? [BoxShadow(color: AppColours.kidBlue.withOpacity(0.4 * _pulse.value), blurRadius: 18, spreadRadius: 2)]
                          : node.state == NodeState.done
                              ? [BoxShadow(color: AppColours.kidGreenDark.withOpacity(0.5), blurRadius: 0, offset: const Offset(0, 4))]
                              : null,
                    ),
                    child: Center(
                      child: node.state == NodeState.locked
                          ? appSvg(_lockIcon, size: 24, stroke: AppColours.kidMuted, strokeWidth: 2)
                          : Text(node.symbol,
                              style: TextStyle(
                                  fontSize: node.symbol.length > 2 ? 18 : 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white)),
                    ),
                  ),
                ),
                if (node.state == NodeState.done)
                  const Positioned(top: -4, right: -2, child: Text('👑', style: TextStyle(fontSize: 22))),
                if (node.state == NodeState.current)
                  Positioned(
                    top: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColours.kidYellow, borderRadius: BorderRadius.circular(999)),
                      child: Text('START', style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF78350F))),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(node.label,
              style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: node.state == NodeState.locked ? AppColours.kidMuted : AppColours.kidInk)),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final earned = i < node.stars;
              const star = Text('⭐', style: TextStyle(fontSize: 11));
              return earned ? star : const Opacity(opacity: 0.3, child: ColorFiltered(colorFilter: _greyscaleLP, child: star));
            }),
          ),
        ],
      ),
    );
  }
}

const _greyscaleLP = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);
