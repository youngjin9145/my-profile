import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

class RevealOnScroll extends StatefulWidget {
  const RevealOnScroll({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll> {
  final Key _key = UniqueKey();
  bool _shown = false;

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_shown && info.visibleFraction > 0.25) {
      setState(() => _shown = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: _onVisibilityChanged,
      child: _shown
          ? widget.child
              .animate(delay: widget.delay)
              .fadeIn(duration: 500.ms, curve: Curves.easeOut)
              .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOut)
          : Opacity(opacity: 0, child: widget.child,)
    );
  }
}
