import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class CustomCursor extends StatefulWidget {
  const CustomCursor({super.key, required this.child});

  final Widget child;

  @override
  _CustomCursorState createState() => _CustomCursorState();
}

class _CustomCursorState extends State<CustomCursor> {
  Offset _mouse = Offset.zero;

  void _onHover(PointerHoverEvent event) {
    setState(() => _mouse = event.localPosition);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.none,
      onHover: (event) => _onHover(event),
      child: Stack(
        children: [
          widget.child,

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
                    color: AppColors.green.withValues(alpha: 0.5),
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.green,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
