import 'dart:ui' show PlatformDispatcher;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lang.dart';
import '../theme/theme_variant.dart';

class SettingsStore {
  static const _kLang = 'lang';
  static const _kTheme = 'theme';

  /// Loads saved settings, or derives defaults (browser locale → ko/en).
  static Future<({Lang lang, ThemeVariant theme})> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = switch (prefs.getString(_kLang)) {
      'ko' => Lang.ko,
      'en' => Lang.en,
      _ => _browserDefaultLang(),
    };
    final theme = ThemeVariant.values.firstWhere(
      (v) => v.name == prefs.getString(_kTheme),
      orElse: () => ThemeVariant.githubDark,
    );
    return (lang: lang, theme: theme);
  }

  static Future<void> save(Lang lang, ThemeVariant theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLang, lang.name);
    await prefs.setString(_kTheme, theme.name);
  }

  static Lang _browserDefaultLang() {
    final code = PlatformDispatcher.instance.locale.languageCode;
    return code == 'ko' ? Lang.ko : Lang.en;
  }
}
