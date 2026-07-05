import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_portfolio/models/lang.dart';
import 'package:shadow_portfolio/models/l10n.dart';

void main() {
  test('L10n.of returns the language-specific string', () {
    const t = L10n('Hello', '안녕');
    expect(t.of(Lang.en), 'Hello');
    expect(t.of(Lang.ko), '안녕');
  });
}
