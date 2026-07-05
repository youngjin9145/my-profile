import 'dart:math' as math;

/// Original 5-row block-letter ASCII font for the boot banner.
/// Only the glyphs needed for "I AM ATOMIC" are defined. This is hand-authored
/// original art, not a reproduction of any external source.
const int _rows = 5;

const Map<String, List<String>> _glyphs = {
  ' ': ['   ', '   ', '   ', '   ', '   '],
  'I': ['███', ' █ ', ' █ ', ' █ ', '███'],
  'A': [' ██ ', '█  █', '████', '█  █', '█  █'],
  'M': ['█   █', '██ ██', '█ █ █', '█   █', '█   █'],
  'T': ['█████', '  █  ', '  █  ', '  █  ', '  █  '],
  'O': [' ███ ', '█   █', '█   █', '█   █', ' ███ '],
  'C': [' ████', '█    ', '█    ', '█    ', ' ████'],
};

/// Renders [word] as [_rows] lines of block text, each padded to equal width
/// so the result is a clean rectangle that centres nicely.
List<String> asciiBanner(String word) {
  final lines = List.filled(_rows, '');
  for (var i = 0; i < word.length; i++) {
    final g = _glyphs[word[i].toUpperCase()] ?? _glyphs[' ']!;
    for (var r = 0; r < _rows; r++) {
      lines[r] += (i == 0 ? '' : ' ') + g[r];
    }
  }
  final w = lines.map((l) => l.length).reduce(math.max);
  return [for (final l in lines) l.padRight(w)];
}
