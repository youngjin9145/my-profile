// A basic smoke test: pump the app and make sure it renders without crashing.
// We'll grow this as real sections land.
import 'package:flutter_test/flutter_test.dart';

import 'package:shadow_portfolio/main.dart';

void main() {
  testWidgets('App boots and shows the booting line', (WidgetTester tester) async {
    await tester.pumpWidget(const ShadowPortfolioApp());

    expect(find.textContaining('booting'), findsOneWidget);
  });
}
