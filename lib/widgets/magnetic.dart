import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Magnetic extends StatefulWidget {
  const Magnetic({super.key, required this.child, this.strength = 0.3});

  final Widget child;
  final double strength;

  @override
  State<Magnetic> createState() => _MagneticState();
}

class _MagneticState extends State<Magnetic> {
  Offset _offset = Offset.zero;

  void _onHover(PointerHoverEvent event) {
    final size = context.size;
    if (size == null) return;

    final center = Offset(size.width / 2, size.height / 2);

    setState(() {
      _offset = (event.localPosition - center) * widget.strength;
    });
  }

  void _reset() => setState(() => _offset = Offset.zero);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => _onHover(event),
      onExit: (_) => _reset(),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 120),
        transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
        child: widget.child,
      ),
    );
  }
}
