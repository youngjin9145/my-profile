import 'package:flutter/material.dart';
import 'package:shadow_portfolio/widgets/reveal_on_scroll.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_cursor.dart';
import 'sections/hero_section.dart';
import 'sections/about_section.dart';
import 'sections/skills_section.dart';
import 'sections/projects_section.dart';
import 'sections/contact_section.dart';

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
      body: SelectionArea(
        child: DefaultSelectionStyle(
          mouseCursor: SystemMouseCursors.none,
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                  child: Column(
                    children: [
                      HeroSection(),
                      SizedBox(height: 100),
                      RevealOnScroll(child: AboutSection()),
                      SizedBox(height: 100),
                      RevealOnScroll(child: SkillsSection()),
                      SizedBox(height: 100),
                      RevealOnScroll(child: ProjectsSection()),
                      SizedBox(height: 100),
                      RevealOnScroll(child: ContactSection()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
