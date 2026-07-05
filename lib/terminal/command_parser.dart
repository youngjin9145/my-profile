import '../data/profile_data.dart';
import '../models/l10n.dart';
import '../models/lang.dart';
import '../theme/theme_variant.dart';
import 'command.dart';

/// 순수 함수: 입력 문자열을 파싱해 출력 줄 + 선택적 부수효과를 반환.
/// 부수효과(setLang/setTheme/clear/launchUrl)는 여기서 실행하지 않고
/// [CommandEffect]로 기술만 하며, TerminalSection 위젯이 적용한다.
CommandResult runCommand(String input, {required Lang lang}) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    return const CommandResult([]);
  }

  // 첫 토큰 = 명령어(소문자), 나머지 = 인자.
  final parts = trimmed.split(RegExp(r'\s+'));
  final cmd = parts.first.toLowerCase();
  final args = parts.skip(1).toList();

  switch (cmd) {
    case 'help':
      return _help();
    case 'whoami':
      return _whoami(lang);
    case 'about':
      return _lines(ProfileData.about.of(lang));
    case 'skills':
      return _skills();
    case 'projects':
      return _projects(lang);
    case 'awards':
      return _awards(lang);
    case 'contact':
      return _contact();
    case 'lang':
      return _lang(args, lang);
    case 'theme':
      return _theme(args);
    case 'clear':
      return CommandResult(const [], effect: ClearEffect());
    case 'sudo':
      return _sudo(args, lang);
    case 'neofetch':
      return _neofetch(lang);
    default:
      return CommandResult([
        TerminalLine("command not found: $cmd — type 'help'"),
      ]);
  }
}

/// 문자열을 줄 단위(`\n`)로 쪼개 TerminalLine 리스트로.
CommandResult _lines(String text) {
  return CommandResult(
    text.split('\n').map((l) => TerminalLine(l)).toList(),
  );
}

CommandResult _help() {
  const commands = <(String, String)>[
    ('help', 'Show this list of commands'),
    ('whoami', 'Who am I? — handle and roles'),
    ('about', 'A short bio'),
    ('skills', 'Tech I work with'),
    ('projects', 'Things I have built'),
    ('awards', 'Certifications and awards'),
    ('contact', 'Ways to reach me'),
    ('lang <en|ko>', 'Switch language'),
    ('theme <name>', 'Switch color theme'),
    ('neofetch', 'System info, terminal-style'),
    ('sudo hire-me', 'The real reason you are here'),
    ('clear', 'Clear the screen'),
  ];
  return CommandResult([
    const TerminalLine('Available commands:'),
    for (final (name, desc) in commands)
      TerminalLine('  ${name.padRight(16)}$desc'),
  ]);
}

CommandResult _whoami(Lang lang) {
  return CommandResult([
    TerminalLine(ProfileData.handle),
    for (final role in ProfileData.roles) TerminalLine('  - ${role.of(lang)}'),
  ]);
}

CommandResult _skills() {
  return CommandResult([
    const TerminalLine('Skills:'),
    for (final skill in ProfileData.skills) TerminalLine('  • $skill'),
  ]);
}

CommandResult _projects(Lang lang) {
  return CommandResult([
    const TerminalLine('Projects:'),
    for (final p in ProfileData.projects) ...[
      TerminalLine('  ${p.name}  [${p.tech.join(', ')}]'),
      TerminalLine('    ${p.description.of(lang)}'),
      if (p.link != null) TerminalLine('    ${p.link}', url: p.link),
    ],
  ]);
}

CommandResult _awards(Lang lang) {
  return CommandResult([
    const TerminalLine('Awards & certifications:'),
    for (final a in ProfileData.awards) TerminalLine('  ★ ${a.of(lang)}'),
  ]);
}

CommandResult _contact() {
  // 각 링크는 url을 채워 위젯이 탭 시 launchUrl 하도록 한다.
  return CommandResult([
    const TerminalLine('GitHub', url: ProfileData.github),
    const TerminalLine('LinkedIn', url: ProfileData.linkedin),
    const TerminalLine('Instagram', url: ProfileData.instagram),
    TerminalLine(ProfileData.email, url: 'mailto:${ProfileData.email}'),
  ]);
}

CommandResult _lang(List<String> args, Lang current) {
  const usage = L10n('usage: lang <en|ko>', '사용법: lang <en|ko>');
  if (args.isEmpty) {
    return CommandResult([TerminalLine(usage.of(current))]);
  }
  switch (args.first.toLowerCase()) {
    case 'en':
      return CommandResult(
        const [TerminalLine('Language → English')],
        effect: SetLangEffect(Lang.en),
      );
    case 'ko':
      return CommandResult(
        const [TerminalLine('언어 → 한국어')],
        effect: SetLangEffect(Lang.ko),
      );
    default:
      return CommandResult([TerminalLine(usage.of(current))]);
  }
}

CommandResult _theme(List<String> args) {
  // 라벨(gh-dark/matrix/amber) 또는 enum 이름(githubDark 등)으로 매칭.
  ThemeVariant? match;
  if (args.isNotEmpty) {
    final key = args.first.toLowerCase();
    for (final v in ThemeVariant.values) {
      if (v.label.toLowerCase() == key || v.name.toLowerCase() == key) {
        match = v;
        break;
      }
    }
  }
  if (match != null) {
    return CommandResult(
      [TerminalLine('Theme → ${match.label}')],
      effect: SetThemeEffect(match),
    );
  }
  return CommandResult([
    const TerminalLine('usage: theme <name>'),
    TerminalLine(
      '  available: ${ThemeVariant.values.map((v) => v.label).join(', ')}',
    ),
  ]);
}

CommandResult _sudo(List<String> args, Lang lang) {
  final sub = args.isEmpty ? '' : args.first.toLowerCase();
  if (sub == 'hire-me') {
    const line = L10n(
      "Great choice. Opening a line to my inbox…",
      '탁월한 선택입니다. 메일함으로 연결합니다…',
    );
    return CommandResult(
      [
        TerminalLine(line.of(lang)),
        TerminalLine(ProfileData.email, url: 'mailto:${ProfileData.email}'),
      ],
      effect: OpenUrlEffect('mailto:${ProfileData.email}'),
    );
  }
  final target = args.isEmpty ? 'command' : args.join(' ');
  return CommandResult([
    TerminalLine("sudo: $target: command not found — try 'sudo hire-me'"),
  ]);
}

CommandResult _neofetch(Lang lang) {
  // 오리지널 ASCII 아트 + 시스템 정보(오마주, 원작 미복사).
  const art = <String>[
    r'      .__.      ',
    r'     (|  |)     ',
    r'      \__/      ',
    r'     /|  |\     ',
    r'    (_|  |_)    ',
  ];
  final info = <(String, String)>[
    ('user', ProfileData.handle),
    ('shell', 'yj-sh 1.0'),
    ('lang', lang == Lang.ko ? 'ko_KR' : 'en_US'),
    ('stack', 'Flutter · Dart'),
    ('focus', 'Apps · Reverse Engineering · Security'),
  ];
  final lines = <TerminalLine>[];
  final rows = art.length > info.length ? art.length : info.length;
  for (var i = 0; i < rows; i++) {
    final left = i < art.length ? art[i] : ' ' * art.first.length;
    if (i < info.length) {
      final (k, v) = info[i];
      lines.add(TerminalLine('$left  $k: $v'));
    } else {
      lines.add(TerminalLine(left));
    }
  }
  return CommandResult(lines);
}
