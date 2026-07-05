// A basic smoke test: pump the app and make sure it renders without crashing.
// We'll grow this as real sections land.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shadow_portfolio/main.dart';
import 'package:shadow_portfolio/models/lang.dart';
import 'package:shadow_portfolio/theme/theme_variant.dart';
import 'package:shadow_portfolio/state/app_settings.dart';

void main() {
  testWidgets('App boots and shows the hero prompt', (WidgetTester tester) async {
    // ShadowPortfolioApp 는 이제 settings 를 요구 → 테스트용 기본값 주입.
    await tester.pumpWidget(ShadowPortfolioApp(
      settings: AppSettings(lang: Lang.en, theme: ThemeVariant.githubDark),
    ));

    expect(find.textContaining('whoami'), findsOneWidget);

    // 히어로의 AnimatedTextKit 이 무한 반복 타이머를 걸어둠 → 빈 위젯으로 교체해
    // 트리를 정리하고, 교체 직전 예약된 타이머가 만료되도록 시간을 넉넉히 진행시킨 뒤 종료.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
