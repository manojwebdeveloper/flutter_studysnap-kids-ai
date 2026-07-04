import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});
  @override State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  int _selectedTab = 0; // 0=Maths, 1=English, 2=Science(locked)
  static const _tabs = ['Maths', 'English', 'Science 🔒'];

  static const _nodes = [
    _PathNode('+',   'Addition',       NodeState.done,    ['⭐', '⭐', '⭐']),
    _PathNode('−',   'Subtraction',    NodeState.done,    ['⭐', '⭐', '⭐']),
    _PathNode('×',   'Multiplication', NodeState.done,    ['⭐', '⭐', '☆']),
    _PathNode('½',   'Fractions',      NodeState.current, ['☆', '☆', '☆']),
    _PathNode('📐',  'Geometry',       NodeState.locked,  ['☆', '☆', '☆']),
    _PathNode('0.5', 'Decimals',       NodeState.locked,  ['☆', '☆', '☆']),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.kidBg,
      body: SafeArea(child: Column(children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(children: [
            GestureDetector(onTap: () => context.go(AppRoutes.kid),
              child: const Icon(Icons.arrow_back_ios, color: AppColours.textDark, size: 22)),
            const SizedBox(width: 8),
            Text('Learning Path 🔥',
              style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: AppColours.textDark)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: BoxDecoration(color: AppColours.amberLight, borderRadius: BorderRadius.circular(99)),
              child: Text('🔥 4', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF92400E)))),
          ]),
        ),

        // Subject tabs
        SizedBox(height: 44, child: ListView.builder(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 20),
          itemCount: _tabs.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: i == 2 ? null : () => setState(() => _selectedTab = i),
            child: AnimatedContainer(duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedTab == i ? AppColours.kidBlue : Colors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: _selectedTab == i ? AppColours.kidBlue : AppColours.line, width: 1.5)),
              child: Text(_tabs[i], style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800,
                color: _selectedTab == i ? Colors.white : i == 2 ? AppColours.textMuted.withOpacity(.5) : AppColours.textMuted))),
          ))),

        // Sub-label
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Maths · Year 4', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppColours.textMuted)),
            Text('3/8 done', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppColours.kidBlue)),
          ])),

        // Path nodes
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(children: _nodes.asMap().entries.map((e) {
            final node    = e.value;
            final isLast  = e.key == _nodes.length - 1;
            return Column(children: [
              _NodeWidget(node: node, onTap: node.state == NodeState.current
                  ? () => context.go(AppRoutes.flashcards) : null)
                  .animate(delay: Duration(milliseconds: e.key * 80)).fadeIn(duration: 250.ms).scale(begin: const Offset(.85, .85)),
              if (!isLast) AnimatedContainer(duration: 300.ms,
                width: 4, height: 32,
                decoration: BoxDecoration(
                  color: node.state == NodeState.done ? AppColours.kidGreen : AppColours.line,
                  borderRadius: BorderRadius.circular(2))),
            ]);
          }).toList()),
        )),
      ])),
    );
  }
}

// ── Node widget ───────────────────────────────────────────

enum NodeState { done, current, locked }

class _PathNode {
  const _PathNode(this.symbol, this.label, this.state, this.stars);
  final String symbol, label;
  final NodeState state;
  final List<String> stars;
}

class _NodeWidget extends StatefulWidget {
  const _NodeWidget({required this.node, this.onTap});
  final _PathNode node;
  final VoidCallback? onTap;
  @override State<_NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<_NodeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final (bg, border, textColour) = switch (node.state) {
      NodeState.done    => (AppColours.greenLight,   AppColours.kidGreen,  AppColours.textDark),
      NodeState.current => (AppColours.blueLight,    AppColours.kidBlue,   AppColours.textDark),
      NodeState.locked  => (AppColours.subtle,       AppColours.line,      AppColours.textMuted),
    };

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, child) => Container(
            width: 76, height: 76,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(color: border, width: 4),
              boxShadow: node.state == NodeState.current
                  ? [BoxShadow(color: AppColours.kidBlue.withOpacity(.35 * _pulse.value), blurRadius: 18, spreadRadius: 2)]
                  : [],
            ),
            child: Stack(alignment: Alignment.center, children: [
              if (node.state == NodeState.done)
                const Positioned(top: -12, child: Text('👑', style: TextStyle(fontSize: 16))),
              if (node.state == NodeState.current)
                Positioned(top: -12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColours.kidYellow, borderRadius: BorderRadius.circular(99)),
                  child: Text('START', style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF78350F))))),
              Text(node.symbol, style: TextStyle(fontSize: node.symbol.length > 2 ? 18 : 26,
                fontWeight: FontWeight.w900, color: textColour)),
            ]),
          ),
        ),
        const SizedBox(height: 5),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: node.stars.map((s) => Text(s, style: const TextStyle(fontSize: 14))).toList()),
        const SizedBox(height: 3),
        Text(node.label, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800,
          color: node.state == NodeState.current ? AppColours.kidBlue
               : node.state == NodeState.locked  ? AppColours.textMuted
               : AppColours.textDark)),
        const SizedBox(height: 4),
      ]),
    );
  }
}
