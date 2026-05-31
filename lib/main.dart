import 'package:flutter/material.dart';
import 'package:shadow_portfolio/widgets/reveal_on_scroll.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_cursor.dart';
import 'widgets/scroll_hint.dart';
import 'sections/hero_section.dart';
import 'sections/about_section.dart';
import 'sections/skills_section.dart';
import 'sections/projects_section.dart';
import 'sections/contact_section.dart';
import 'data/profile_data.dart';

void main() {
  runApp(const ShadowPortfolioApp());
}

class ShadowPortfolioApp extends StatelessWidget {
  const ShadowPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ProfileData.handle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const CustomCursor(child: HomePage()),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _controller = ScrollController(); // 스크롤 위치 추적용
  bool _scrolled = false; // 스크롤 시작했나?

  @override
  void initState() {
    super.initState();
    // 스크롤이 움직일 때마다 호출 → 40px 넘게 내렸으면 힌트 끔
    _controller.addListener(() {
      final scrolled = _controller.offset > 40;
      if (scrolled != _scrolled) {
        setState(() => _scrolled = scrolled);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // 컨트롤러 정리 (메모리 누수 방지)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultSelectionStyle(
        mouseCursor: SystemMouseCursors.none,
        child: SelectionArea(
          // Stack: 스크롤 내용 위에 힌트를 '고정'으로 얹기
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _controller, // 컨트롤러 연결
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
              // 스크롤 힌트 — 화면 아래 중앙에 고정, 스크롤하면 사라짐
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: IgnorePointer( // 클릭 가로채지 않게
                  child: AnimatedOpacity(
                    opacity: _scrolled ? 0 : 1, // 스크롤하면 0(투명)
                    duration: const Duration(milliseconds: 300),
                    child: const Center(child: ScrollHint()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
