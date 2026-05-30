import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_cursor.dart';
import 'sections/hero_section.dart';

void main() {
  runApp(const ShadowPortfolioApp());
}

class ShadowPortfolioApp extends StatelessWidget {
  const ShadowPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cid Kagenou',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const CustomCursor(child: HomePage()),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 80),
              child: Column(children: [HeroSection()]),
            ),
          ),
        ),
      ),
    );
  }
}
