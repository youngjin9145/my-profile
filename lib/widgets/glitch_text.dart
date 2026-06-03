import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Neon CRT-terminal "glitch" rendering of [text].
///
/// A VT323 pixel font with a layered cyan bloom, a magenta/cyan
/// chromatic-aberration (RGB split) edge, faint scanlines, and — when
/// [animate] is true — an occasional flicker that otherwise sits still.
/// Used for the hero name.
class GlitchText extends StatelessWidget {
  const GlitchText(
    this.text, {
    super.key,
    this.fontSize = 72,
    this.animate = true,
  });

  final String text;
  final double fontSize;
  final bool animate;

  // Neon palette — matches the approved mockup (and AppColors.cyan).
  static const Color _cyan = Color(0xFF39D0D8);
  static const Color _magenta = Color(0xFFFF2E88);

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.vt323(fontSize: fontSize, letterSpacing: 1, height: 1);

    // Bright core with a soft, layered cyan neon bloom.
    final core = base.copyWith(
      color: _cyan,
      shadows: const [
        Shadow(color: Color(0xF239D0D8), blurRadius: 2),
        Shadow(color: Color(0xB339D0D8), blurRadius: 8),
        Shadow(color: Color(0x7339D0D8), blurRadius: 18),
        Shadow(color: Color(0x4739D0D8), blurRadius: 38),
        Shadow(color: Color(0x2E39D0D8), blurRadius: 70),
      ],
    );

    // Offset colored copies create the RGB chromatic-aberration fringe:
    // magenta peeks on the left, cyan on the right, behind the core.
    final magentaGhost = base.copyWith(
      color: _magenta,
      shadows: const [Shadow(color: Color(0x8CFF2E88), blurRadius: 10)],
    );
    final cyanGhost = base.copyWith(
      color: _cyan,
      shadows: const [Shadow(color: Color(0x8C39D0D8), blurRadius: 10)],
    );

    final name = Stack(
      clipBehavior: Clip.none, // let the bloom bleed past the text box
      children: [
        Transform.translate(
          offset: const Offset(-2, 0),
          child: Opacity(opacity: .90, child: Text(text, style: magentaGhost)),
        ),
        Transform.translate(
          offset: const Offset(2, 0),
          child: Opacity(opacity: .85, child: Text(text, style: cyanGhost)),
        ),
        Text(text, style: core),
      ],
    );

    // Faint horizontal scanlines confined to the name's box.
    final withScanlines = Stack(
      clipBehavior: Clip.none,
      children: [
        name,
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _ScanlinePainter())),
        ),
      ],
    );

    if (!animate) return withScanlines;

    // Sits still ~90% of the time, then a brief CRT flicker once per cycle.
    return withScanlines
        .animate(onPlay: (c) => c.repeat())
        .custom(
          duration: 4800.ms,
          builder: (context, value, child) {
            var opacity = 1.0;
            if (value > .92 && value < .97) {
              opacity = value < .94 ? .78 : .92;
            }
            return Opacity(opacity: opacity, child: child);
          },
        );
  }
}

class _ScanlinePainter extends CustomPainter {
  static const _gap = 4.0;
  final _paint = Paint()..color = const Color(0x14000000);

  @override
  void paint(Canvas canvas, Size size) {
    for (var y = 0.0; y < size.height; y += _gap) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
