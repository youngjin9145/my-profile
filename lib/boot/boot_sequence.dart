import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ascii_banner.dart';
import 'atomic_painter.dart';

/// A short, skippable boot intro — an ORIGINAL stylised homage: a terminal
/// boot log, a rising ASCII blade, then a purple "I AM ATOMIC" ASCII banner
/// over a screen-filling purple ASCII blast. No external frame/character is
/// reproduced; all art here is hand-authored or procedural.
class BootSequence extends StatefulWidget {
  const BootSequence({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<BootSequence> createState() => _BootSequenceState();
}

class _BootSequenceState extends State<BootSequence>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _finished = false;

  static const Color _accent = Color(0xFF9D4EDD);

  static const List<String> _bootLog = [
    r'> booting yj0.app ...',
    r'> loading kernel modules ......... [ OK ]',
    r'> mounting /shadow ............... [ OK ]',
    r'> decrypting persona ............. [ OK ]',
    r'> charging atomic core ...',
  ];

  // Original abstract ASCII blade (not a reproduction).
  static const List<String> _blade = [
    r'      /\      ',
    r'      ||      ',
    r'      ||      ',
    r'    __||__    ',
    r'      \/      ',
  ];

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) _finish();
      });
    _c.forward();
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    // Defer to after the current frame so we never dispose the controller
    // from inside its own status/tick callback.
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onDone());
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _seg(double t, double a, double b, {Curve curve = Curves.linear}) {
    return curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    // CanvasKit does not resolve the generic 'monospace' keyword, so use the
    // real registered JetBrains Mono family (same font as the site, and it
    // carries the block/box-drawing glyphs the ASCII art needs).
    final mono = GoogleFonts.jetBrainsMono().fontFamily;

    return Focus(
      autofocus: true,
      onKeyEvent: (_, _) {
        _finish();
        return KeyEventResult.handled;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _finish,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final overlay = 1.0 - _seg(t, 0.92, 1.0);
            final logOpacity = 1.0 - _seg(t, 0.46, 0.56);
            final logLines = (_seg(t, 0.03, 0.42) * _bootLog.length).ceil();
            final blink = (t * 18).floor().isEven;
            final bladeOpacity =
                _seg(t, 0.30, 0.40) * (1.0 - _seg(t, 0.52, 0.62));
            final bladeLift = (1.0 - _seg(t, 0.30, 0.50)) * 40.0;
            final bannerOpacity = _seg(t, 0.50, 0.58);
            final bannerScale =
                0.6 + 0.4 * _seg(t, 0.50, 0.66, curve: Curves.easeOutBack);
            final atomic = _seg(t, 0.52, 0.98);
            final flash = (1.0 - (t - 0.50).abs() / 0.045).clamp(0.0, 1.0);

            return Opacity(
              opacity: overlay,
              child: ColoredBox(
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (atomic > 0)
                      CustomPaint(painter: AtomicPainter(atomic, mono)),
                    if (logOpacity > 0.01)
                      Padding(
                        padding: const EdgeInsets.all(28),
                        child: Opacity(
                          opacity: logOpacity,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var i = 0;
                                    i < logLines && i < _bootLog.length;
                                    i++)
                                  Text(
                                    _bootLog[i] +
                                        (i == logLines - 1 && blink ? ' _' : ''),
                                    style: TextStyle(
                                      fontFamily: mono,
                                      fontSize: 14,
                                      height: 1.6,
                                      color: const Color(0xFF39D0D8),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (bladeOpacity > 0.01)
                      Center(
                        child: Transform.translate(
                          offset: Offset(0, bladeLift),
                          child: Opacity(
                            opacity: bladeOpacity,
                            child: _asciiBlock(_blade, _accent, 18, mono),
                          ),
                        ),
                      ),
                    if (bannerOpacity > 0.01)
                      Center(
                        child: Opacity(
                          opacity: bannerOpacity,
                          child: Transform.scale(
                            scale: bannerScale,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _asciiBlock(
                                        asciiBanner('I AM'), Colors.white, 22, mono),
                                    const SizedBox(height: 10),
                                    _asciiBlock(
                                        asciiBanner('ATOMIC'), _accent, 22, mono),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (flash > 0.01)
                      IgnorePointer(
                        child: ColoredBox(
                          color: _accent.withValues(alpha: flash * 0.6),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 24,
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: 0.5 * (1 - _seg(t, 0.8, 1.0)),
                          child: Text(
                            '> click / press any key to skip',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: mono,
                              fontSize: 12,
                              color: const Color(0xFF8B949E),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _asciiBlock(
      List<String> lines, Color color, double size, String? family) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final l in lines)
          Text(
            l,
            style: TextStyle(
              fontFamily: family,
              fontSize: size,
              height: 1.0,
              color: color,
              shadows: [Shadow(color: color, blurRadius: 18)],
            ),
          ),
      ],
    );
  }
}
