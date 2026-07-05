import 'package:flutter/foundation.dart';
import '../models/lang.dart';
import '../theme/theme_variant.dart';

typedef SettingsChanged = void Function(Lang lang, ThemeVariant theme);

class AppSettings extends ChangeNotifier {
  Lang lang;
  ThemeVariant theme;
  final SettingsChanged? onChanged;

  AppSettings({required this.lang, required this.theme, this.onChanged});

  void setLang(Lang l) {
    if (l == lang) return;
    lang = l;
    _changed();
  }

  void toggleLang() => setLang(lang == Lang.en ? Lang.ko : Lang.en);

  void setTheme(ThemeVariant v) {
    if (v == theme) return;
    theme = v;
    _changed();
  }

  void _changed() {
    onChanged?.call(lang, theme);
    notifyListeners();
  }
}
