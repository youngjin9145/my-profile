import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/app_scope.dart';
import '../terminal/command.dart';
import '../terminal/command_parser.dart';
import '../theme/terminal_colors.dart';
import '../widgets/terminal_window.dart';

/// Hero 아래에 놓이는 인터랙티브 터미널.
/// 실제 명령을 입력받아 [runCommand]로 파싱하고, 반환된 [CommandEffect]를
/// 여기(위젯)에서 적용한다 — 파서는 순수하게 유지.
class TerminalSection extends StatefulWidget {
  const TerminalSection({super.key});

  @override
  State<TerminalSection> createState() => _TerminalSectionState();
}

class _TerminalSectionState extends State<TerminalSection> {
  /// 스크롤백 상한 — 무한 증가 방지(스펙 §5).
  static const _maxLines = 200;

  /// 프롬프트 문자열 — 입력 필드 앞과 에코 줄에 공통으로 쓴다.
  static const _prompt = 'visitor@yj0:~\$ ';

  final List<TerminalLine> _scrollback = [];
  final List<String> _history = []; // 실행한 명령들(위/아래 화살표로 탐색)
  int _historyIndex = 0; // _history.length == 현재(빈 입력) 위치

  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 시작 안내 — 무엇을 칠 수 있는지 힌트.
    _scrollback.add(
      const TerminalLine("Type 'help' to get started."),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 스크롤백 끝에 줄들을 추가하고 상한을 넘으면 앞부분을 잘라낸다.
  void _append(Iterable<TerminalLine> lines) {
    _scrollback.addAll(lines);
    if (_scrollback.length > _maxLines) {
      _scrollback.removeRange(0, _scrollback.length - _maxLines);
    }
  }

  void _submit(String raw) {
    final input = raw.trimRight();

    // 명령 히스토리에 기록(빈 줄 제외, 직전과 중복이면 생략).
    final trimmed = input.trim();
    if (trimmed.isNotEmpty &&
        (_history.isEmpty || _history.last != trimmed)) {
      _history.add(trimmed);
    }
    _historyIndex = _history.length;

    final result = runCommand(input, lang: AppScope.of(context, listen: false).lang);

    setState(() {
      // 프롬프트 + 입력 에코.
      _append([TerminalLine('$_prompt$input')]);
      // clear 이펙트는 스크롤백을 비우므로 출력/에코를 남기지 않는다.
      final effect = result.effect;
      if (effect is ClearEffect) {
        _scrollback.clear();
      } else {
        _append(result.output);
      }
    });

    _applyEffect(result.effect);

    _controller.clear();
    _inputFocus.requestFocus();
    _scrollToBottom();
  }

  /// 파서가 기술한 부수효과를 실제로 적용(설정 변경/링크 열기).
  void _applyEffect(CommandEffect? effect) {
    switch (effect) {
      case SetLangEffect(:final lang):
        AppScope.of(context, listen: false).setLang(lang);
      case SetThemeEffect(:final theme):
        AppScope.of(context, listen: false).setTheme(theme);
      case OpenUrlEffect(:final url):
        _open(url);
      case ClearEffect():
      case null:
        break;
    }
  }

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// 다음 프레임에 스크롤을 맨 아래로 — 새 출력이 보이도록.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  /// ↑/↓ 로 명령 히스토리를 탐색.
  void _recallHistory(int delta) {
    if (_history.isEmpty) return;
    final next = (_historyIndex + delta).clamp(0, _history.length);
    if (next == _historyIndex) return;
    setState(() {
      _historyIndex = next;
      final text = next == _history.length ? '' : _history[next];
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _recallHistory(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _recallHistory(1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final term = context.term;

    return TerminalWindow(
      title: 'yj@shadow: ~',
      // 아무 데나 탭하면 입력에 포커스.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _inputFocus.requestFocus,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 스크롤백 — 높이 제한 + 자체 스크롤.
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: Scrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final line in _scrollback) _OutputLine(line: line),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _InputRow(
              prompt: _prompt,
              controller: _controller,
              focusNode: _inputFocus,
              onKey: _onKey,
              onSubmitted: _submit,
              accent: term.accent,
              text: term.text,
            ),
          ],
        ),
      ),
    );
  }
}

/// 스크롤백 한 줄 — 링크 줄이면 탭 가능(밑줄 + 강조색), 아니면 일반 텍스트.
class _OutputLine extends StatelessWidget {
  const _OutputLine({required this.line});

  final TerminalLine line;

  @override
  Widget build(BuildContext context) {
    final term = context.term;
    final textTheme = Theme.of(context).textTheme;
    final isPrompt = line.text.startsWith('visitor@yj0:~\$');
    final baseColor = isPrompt ? term.accent : term.text;

    final style = textTheme.bodyMedium?.copyWith(
      color: line.url != null ? term.cyan : baseColor,
      decoration: line.url != null ? TextDecoration.underline : null,
      decorationColor: term.cyan,
      height: 1.4,
    );

    final content = Text(
      line.text.isEmpty ? ' ' : line.text,
      style: style,
    );

    if (line.url == null) {
      return SizedBox(width: double.infinity, child: content);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(
          Uri.parse(line.url!),
          mode: LaunchMode.externalApplication,
        ),
        child: SizedBox(width: double.infinity, child: content),
      ),
    );
  }
}

/// 프롬프트 + 입력 필드 한 줄. 테두리 없는 [TextField]에 커서만 깜빡인다.
class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.prompt,
    required this.controller,
    required this.focusNode,
    required this.onKey,
    required this.onSubmitted,
    required this.accent,
    required this.text,
  });

  final String prompt;
  final TextEditingController controller;
  final FocusNode focusNode;
  final KeyEventResult Function(FocusNode, KeyEvent) onKey;
  final ValueChanged<String> onSubmitted;
  final Color accent;
  final Color text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final promptStyle = textTheme.bodyMedium?.copyWith(color: accent);
    final inputStyle = textTheme.bodyMedium?.copyWith(color: text);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(prompt, style: promptStyle),
        Expanded(
          child: Focus(
            onKeyEvent: onKey,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: false,
              style: inputStyle,
              cursorColor: accent,
              cursorWidth: 8,
              cursorRadius: Radius.zero,
              maxLines: 1,
              textInputAction: TextInputAction.done,
              // 시스템 자동완성/제안 UI 억제(터미널스럽게).
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: onSubmitted,
            ),
          ),
        ),
      ],
    );
  }
}
