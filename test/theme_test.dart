import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_portfolio/theme/theme_variant.dart';
import 'package:shadow_portfolio/theme/app_theme.dart';
import 'package:shadow_portfolio/theme/terminal_colors.dart';

void main() {
  // GoogleFonts (via AppTheme.forVariant) needs the binding initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('each variant yields a distinct accent color', () {
    final gh = AppTheme.forVariant(ThemeVariant.githubDark).extension<TerminalColors>()!;
    final mx = AppTheme.forVariant(ThemeVariant.matrixGreen).extension<TerminalColors>()!;
    expect(gh.accent, isNot(mx.accent));
  });
}
