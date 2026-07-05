import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/terminal_colors.dart';

class CustomCursor extends StatefulWidget {
  const CustomCursor({super.key, required this.child});

  final Widget child;

  @override
  State<CustomCursor> createState() => _CustomCursorState();
}

class _CustomCursorState extends State<CustomCursor> {
  Offset _mouse = Offset.zero;
  bool _hasMouse = false;

  void _handlePointer(PointerEvent event) {
    if (event.kind == PointerDeviceKind.mouse) {
      setState(() {
        _mouse = event.localPosition;
        _hasMouse = true;
      });
    } else if (_hasMouse) {
      setState(() => _hasMouse = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final term = context.term;
    return Listener(
      onPointerHover: _handlePointer,
      onPointerMove: _handlePointer,
      onPointerDown: _handlePointer,
      child: MouseRegion(
        cursor: _hasMouse ? SystemMouseCursors.none : MouseCursor.defer,
        child: Stack(
          children: [
            widget.child,
            if (_hasMouse) ...[
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                left: _mouse.dx - 18,
                top: _mouse.dy - 18,
                child: IgnorePointer(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: term.accent.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: _mouse.dx - 4,
                top: _mouse.dy - 4,
                child: IgnorePointer(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: term.accent,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
