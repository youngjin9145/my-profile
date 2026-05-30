import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._(); // private 생성자로 인스턴스 생성 막음.

  // 배경 계열
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color border = Color(0xFF30363D);

  // 포인트 색
  static const Color green = Color(0xFF3FB950);
  static const Color cyan = Color(0xFF39D0D8);
  static const amber = Color(0xFFE3B341);

  // 글자 색
  static const Color text = Color(0xFFC9D1D9);
  static const Color textDim = Color(0xFF8B949E);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark();

    final mono = GoogleFonts.jetBrainsMonoTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: mono.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.green,
        secondary: AppColors.cyan,
        surface: AppColors.surface,
      )
    );
  }
}
