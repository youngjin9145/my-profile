import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// "스크롤 내려" 힌트 — 아래로 통통 튀는 화살표 + 라벨.
class ScrollHint extends StatelessWidget {
  const ScrollHint({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('scroll', style: textTheme.bodySmall?.copyWith(color: AppColors.textDim)),
        const SizedBox(height: 2),
        const Icon(Icons.keyboard_arrow_down, color: AppColors.green, size: 28),
      ],
    )
        .animate(onPlay: (c) => c.repeat(reverse: true)) // 무한 왕복 반복
        .moveY(begin: 0, end: 8, duration: 700.ms, curve: Curves.easeInOut); // 위아래 8px
  }
}
