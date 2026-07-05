import 'package:flutter/material.dart';
import '../theme/terminal_colors.dart';

class TerminalWindow extends StatelessWidget {
  const TerminalWindow({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final term = context.term;
    final radius = BorderRadius.circular(10);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: term.surface,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: term.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 상단 타이틀 바
          Container(
            color: term.background,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Dot(color: Color(0xFFFF5F56)),
                    SizedBox(width: 8),
                    _Dot(color: Color(0xFFFFBD2E)),
                    SizedBox(width: 8),
                    _Dot(color: Color(0xFF27C93F)),
                  ],
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: term.textDim,
                    ),
                  ),
                ),
                const SizedBox(width: 52), // 왼쪽 점 묶음(52)과 같은 폭을 오른쪽에 비움.
              ],
            ),
          ),
          // 본문 영역
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
