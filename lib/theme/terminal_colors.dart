import 'package:flutter/material.dart';

@immutable
class TerminalColors extends ThemeExtension<TerminalColors> {
  final Color background, surface, border, accent, cyan, amber, text, textDim;
  const TerminalColors({
    required this.background,
    required this.surface,
    required this.border,
    required this.accent,
    required this.cyan,
    required this.amber,
    required this.text,
    required this.textDim,
  });

  @override
  TerminalColors copyWith({
    Color? background,
    Color? surface,
    Color? border,
    Color? accent,
    Color? cyan,
    Color? amber,
    Color? text,
    Color? textDim,
  }) =>
      TerminalColors(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        border: border ?? this.border,
        accent: accent ?? this.accent,
        cyan: cyan ?? this.cyan,
        amber: amber ?? this.amber,
        text: text ?? this.text,
        textDim: textDim ?? this.textDim,
      );

  @override
  TerminalColors lerp(ThemeExtension<TerminalColors>? other, double t) {
    if (other is! TerminalColors) return this;
    return TerminalColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      cyan: Color.lerp(cyan, other.cyan, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      text: Color.lerp(text, other.text, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
    );
  }
}

/// githubDark 팔레트 — 테마 확장이 없을 때(예: 위젯 테스트의 맨 MaterialApp)
/// 쓰이는 기본값. AppColors 원본 값과 동일하게 유지.
const _fallback = TerminalColors(
  background: Color(0xFF0D1117),
  surface: Color(0xFF161B22),
  border: Color(0xFF30363D),
  accent: Color(0xFF3FB950),
  cyan: Color(0xFF39D0D8),
  amber: Color(0xFFE3B341),
  text: Color(0xFFC9D1D9),
  textDim: Color(0xFF8B949E),
);

extension TermX on BuildContext {
  TerminalColors get term =>
      Theme.of(this).extension<TerminalColors>() ?? _fallback;
}
