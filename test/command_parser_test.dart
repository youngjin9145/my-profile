import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_portfolio/models/lang.dart';
import 'package:shadow_portfolio/terminal/command.dart';
import 'package:shadow_portfolio/terminal/command_parser.dart';

void main() {
  test('help lists known commands', () {
    final r = runCommand('help', lang: Lang.en);
    expect(r.output.any((l) => l.text.contains('whoami')), isTrue);
    expect(r.effect, isNull);
  });

  test('unknown command returns not-found', () {
    final r = runCommand('foobar', lang: Lang.en);
    expect(r.output.single.text, contains('command not found'));
  });

  test('lang ko returns SetLangEffect', () {
    final r = runCommand('lang ko', lang: Lang.en);
    expect(r.effect, isA<SetLangEffect>());
    expect((r.effect as SetLangEffect).lang, Lang.ko);
  });

  test('clear returns ClearEffect', () {
    expect(runCommand('clear', lang: Lang.en).effect, isA<ClearEffect>());
  });

  test('empty input returns empty output, no effect', () {
    final r = runCommand('   ', lang: Lang.en);
    expect(r.output, isEmpty);
    expect(r.effect, isNull);
  });

  test('about respects language', () {
    expect(runCommand('about', lang: Lang.ko).output.any((l) => l.text.contains('앱 개발자')), isTrue);
  });
}
