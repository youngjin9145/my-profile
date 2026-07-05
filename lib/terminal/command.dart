import 'package:flutter/painting.dart' show Color;

import '../models/lang.dart';
import '../theme/theme_variant.dart';

/// 파서가 반환하는 부수효과 — 실제 적용은 TerminalSection 위젯이 담당.
/// 파서 자체는 순수 함수로 유지한다.
sealed class CommandEffect {}

class SetLangEffect extends CommandEffect {
  final Lang lang;
  SetLangEffect(this.lang);
}

class SetThemeEffect extends CommandEffect {
  final ThemeVariant theme;
  SetThemeEffect(this.theme);
}

class ClearEffect extends CommandEffect {
  ClearEffect();
}

class OpenUrlEffect extends CommandEffect {
  final String url;
  OpenUrlEffect(this.url);
}

/// 터미널 출력 한 줄. [color]는 위젯이 채워도 되지만, 순수 파서는
/// 색을 지정하지 않고 [url]만 채운다(링크 줄).
class TerminalLine {
  final String text;
  final Color? color;
  final String? url;
  const TerminalLine(this.text, {this.color, this.url});
}

/// 명령 실행 결과 — 출력 줄들 + 선택적 부수효과.
class CommandResult {
  final List<TerminalLine> output;
  final CommandEffect? effect;
  const CommandResult(this.output, {this.effect});
}
