import 'lang.dart';

/// A string that carries both English and Korean variants.
class L10n {
  final String en;
  final String ko;
  const L10n(this.en, this.ko);

  String of(Lang lang) => lang == Lang.ko ? ko : en;
}
