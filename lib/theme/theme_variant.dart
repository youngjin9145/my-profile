enum ThemeVariant { githubDark, matrixGreen, amberCrt }

extension ThemeVariantMeta on ThemeVariant {
  String get label => switch (this) {
    ThemeVariant.githubDark => 'gh-dark',
    ThemeVariant.matrixGreen => 'matrix',
    ThemeVariant.amberCrt => 'amber',
  };
  ThemeVariant get next =>
      ThemeVariant.values[(index + 1) % ThemeVariant.values.length];
}
