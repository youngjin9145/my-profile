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

extension TermX on BuildContext {
  TerminalColors get term => Theme.of(this).extension<TerminalColors>()!;
}
