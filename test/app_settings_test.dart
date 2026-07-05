import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_portfolio/models/lang.dart';
import 'package:shadow_portfolio/theme/theme_variant.dart';
import 'package:shadow_portfolio/state/app_settings.dart';

void main() {
  test('toggleLang flips language and notifies once', () {
    final s = AppSettings(lang: Lang.en, theme: ThemeVariant.githubDark);
    var notifications = 0;
    s.addListener(() => notifications++);
    s.toggleLang();
    expect(s.lang, Lang.ko);
    expect(notifications, 1);
  });

  test('setLang to same value does not notify', () {
    final s = AppSettings(lang: Lang.en, theme: ThemeVariant.githubDark);
    var notifications = 0;
    s.addListener(() => notifications++);
    s.setLang(Lang.en);
    expect(notifications, 0);
  });

  test('setTheme changes theme and calls onChanged persistence hook', () {
    ThemeVariant? saved;
    final s = AppSettings(
      lang: Lang.en,
      theme: ThemeVariant.githubDark,
      onChanged: (lang, theme) => saved = theme,
    );
    s.setTheme(ThemeVariant.matrixGreen);
    expect(s.theme, ThemeVariant.matrixGreen);
    expect(saved, ThemeVariant.matrixGreen);
  });
}
