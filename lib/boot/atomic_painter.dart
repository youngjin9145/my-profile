import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Paints an expanding purple ASCII shock-blast radiating from the centre.
/// [progress] 0→1 grows the blast radius; glyphs densify toward the core.
/// Original, procedural, abstract effect — not a reproduction of any frame.
///
/// [fontFamily] must be a REGISTERED monospace family (e.g. the app's
/// JetBrains Mono). CanvasKit does not resolve the generic 'monospace'
/// keyword, so passing it would break glyph shaping/alignment.
class AtomicPainter extends CustomPainter {
  AtomicPainter(this.progress, this.fontFamily);

  final double progress;
  final String? fontFamily;

  static const double _cell = 18.0; // px per character cell (bounds glyph count)
  static const List<String> _glyphs = ['·', ':', '+', '*', '#', '▓', '█'];
  static const List<Color> _purples = [
    Color(0xFF5A189A),
    Color(0xFF7B2CBF),
    Color(0xFF9D4EDD),
    Color(0xFFC77DFF),
    Color(0xFFE0AAFF),
  ];

  // Cache of laid-out painters, one per (glyph, colour) pair, rebuilt only when
  // the font family changes, so paint() never re-lays-out text per cell.
  static List<List<TextPainter>>? _cache;
  static String? _cacheFamily;
  static List<List<TextPainter>> _painters(String? family) {
    if (_cache != null && _cacheFamily == family) return _cache!;
    _cacheFamily = family;
    return _cache = [
      for (final g in _glyphs)
        [
          for (final c in _purples)
            TextPainter(
              text: TextSpan(
                text: g,
                style: TextStyle(
                  fontFamily: family,
                  fontSize: _cell,
                  height: 1.0,
                  color: c,
                ),
              ),
              textDirection: TextDirection.ltr,
            )..layout(),
        ],
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final painters = _painters(fontFamily);
    final cols = (size.width / _cell).ceil();
    final rows = (size.height / _cell).ceil();
    final cx = cols / 2.0;
    final cy = rows / 2.0;
    final maxDist = math.sqrt(cx * cx + cy * cy);
    final front = progress * maxDist * 1.08; // current blast radius, in cells

    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final dx = x + 0.5 - cx;
        final dy = y + 0.5 - cy;
        final d = math.sqrt(dx * dx + dy * dy);
        if (d > front) continue;
        final depth = ((front - d) / maxDist).clamp(0.0, 1.0);
        final h = _hash(x, y);
        if (depth < 0.05 && h > 0.5) continue; // sparse flicker at the edge
        final gi = (depth * (_glyphs.length - 1) + h * 1.5)
            .clamp(0, _glyphs.length - 1)
            .floor();
        final ci = (depth * (_purples.length - 1))
            .clamp(0, _purples.length - 1)
            .floor();
        painters[gi][ci].paint(canvas, Offset(x * _cell, y * _cell));
      }
    }
  }

  // Deterministic per-cell pseudo-random in [0,1) (stable across frames).
  double _hash(int x, int y) {
    var n = (x * 374761393 + y * 668265263) & 0x7fffffff;
    n = (n ^ (n >> 13)) * 1274126177 & 0x7fffffff;
    return (n % 1000) / 1000.0;
  }

  @override
  bool shouldRepaint(AtomicPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.fontFamily != fontFamily;
}
