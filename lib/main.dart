import 'package:flutter/material.dart';
import 'package:shadow_portfolio/widgets/reveal_on_scroll.dart';
import 'theme/app_theme.dart';
import 'state/app_settings.dart';
import 'state/app_scope.dart';
import 'state/settings_store.dart';
import 'boot/boot_gate.dart';
import 'widgets/custom_cursor.dart';
import 'widgets/scroll_hint.dart';
import 'widgets/settings_bar.dart';
import 'sections/hero_section.dart';
import 'sections/terminal_section.dart';
import 'sections/about_section.dart';
import 'sections/skills_section.dart';
import 'sections/projects_section.dart';
import 'sections/contact_section.dart';
import 'data/profile_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final loaded = await SettingsStore.load(); // 저장된 언어/테마 로드 (없으면 브라우저 로케일)
  runApp(ShadowPortfolioApp(
    settings: AppSettings(
      lang: loaded.lang,
      theme: loaded.theme,
      onChanged: SettingsStore.save, // 변경 시 자동 영속
    ),
  ));
}

class ShadowPortfolioApp extends StatelessWidget {
  const ShadowPortfolioApp({super.key, required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      settings: settings,
      child: ListenableBuilder(
        listenable: settings, // 설정 바뀌면 MaterialApp 재빌드
        builder: (context, _) => MaterialApp(
          title: ProfileData.handle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.forVariant(settings.theme), // 선택된 테마 반영
          home: BootGate(child: const CustomCursor(child: HomePage())),
        ),
      ),
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
                          SizedBox(height: 40),
                          RevealOnScroll(child: TerminalSection()),
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
              // 설정 바 — 우상단 고정 (EN|KO 토글)
              const Positioned(
                top: 20,
                right: 20,
                child: SafeArea(child: SettingsBar()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
