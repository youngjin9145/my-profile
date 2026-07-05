import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_portfolio/models/lang.dart';
import 'package:shadow_portfolio/theme/theme_variant.dart';
import 'package:shadow_portfolio/state/app_settings.dart';
import 'package:shadow_portfolio/state/app_scope.dart';
import 'package:shadow_portfolio/sections/about_section.dart';

void main() {
  testWidgets('AboutSection swaps to Korean when lang toggles', (tester) async {
    final settings = AppSettings(lang: Lang.en, theme: ThemeVariant.githubDark);
    await tester.pumpWidget(MaterialApp(
      home: AppScope(
        settings: settings,
        child: const Scaffold(body: SingleChildScrollView(child: AboutSection())),
      ),
    ));
    expect(find.textContaining('App developer by trade'), findsOneWidget);
    settings.toggleLang();
    await tester.pump();
    expect(find.textContaining('직업은 앱 개발자'), findsOneWidget);
  });
}
