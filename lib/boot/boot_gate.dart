import 'package:flutter/material.dart';
import 'boot_sequence.dart';

/// Plays [BootSequence] on each fresh page load, then reveals [child].
/// Honours reduced-motion (skips the intro entirely).
class BootGate extends StatefulWidget {
  const BootGate({super.key, required this.child});

  final Widget child;

  @override
  State<BootGate> createState() => _BootGateState();
}

class _BootGateState extends State<BootGate> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    if (_done || MediaQuery.of(context).disableAnimations) {
      return widget.child;
    }
    return BootSequence(onDone: () => setState(() => _done = true));
  }
}
