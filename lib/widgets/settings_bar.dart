import 'package:flutter/material.dart';
import '../models/lang.dart';
import '../state/app_scope.dart';
import '../theme/terminal_colors.dart';
import '../theme/theme_variant.dart';

/// 우상단 고정 설정 바 — EN|KO 언어 토글 + 테마 순환 버튼.
class SettingsBar extends StatelessWidget {
  const SettingsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);
    final onColor = context.term.textDim;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Pill(
          label: settings.lang == Lang.en ? 'EN' : 'KO',
          onTap: () => AppScope.of(context, listen: false).toggleLang(),
          color: onColor,
        ),
        const SizedBox(width: 8),
        _Pill(
          label: settings.theme.label,
          onTap: () =>
              AppScope.of(context, listen: false).setTheme(settings.theme.next),
          color: context.term.accent,
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.onTap, required this.color});
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: context.term.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.term.border),
          ),
          child: Text(label, style: TextStyle(color: color, fontSize: 13)),
        ),
      ),
    );
  }
}
