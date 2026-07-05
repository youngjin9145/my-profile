# KO/EN 토글 + 인터랙티브 기능 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 기존 Flutter Web 프로필에 KO/EN 전체 번역, 인터랙티브 터미널, 테마 스위처 3종, "Shadow/Atomic" 오리지널 부팅 인트로를 추가한다.

**Architecture:** `AppSettings`(lang+theme, ChangeNotifier)를 `AppScope`(InheritedNotifier)로 트리에 제공 → 헤더 버튼과 터미널 명령이 같은 상태를 변경. 테마는 `ThemeExtension<TerminalColors>`로 `MaterialApp.theme` 스왑. 선택은 `shared_preferences`로 영속. 부팅은 순수 Dart(`enough_ascii_art` + `flutter_animate` + `CustomPainter`) 오리지널 오마주.

**Tech Stack:** Flutter Web, Dart. 신규: `shared_preferences`, `enough_ascii_art`. 기존: `google_fonts`, `flutter_animate`, `animated_text_kit`, `url_launcher`, `font_awesome_flutter`, `visibility_detector`.

**Spec:** `docs/superpowers/specs/2026-07-05-i18n-and-interactive-features-design.md`

---

## Shared Contracts (전 페이즈 공통 — 이름/시그니처 고정)

```dart
enum Lang { en, ko }                                  // lib/models/lang.dart
class L10n { final String en, ko; const L10n(this.en, this.ko); String of(Lang l) => l == Lang.ko ? ko : en; }
enum ThemeVariant { githubDark, matrixGreen, amberCrt } // lib/theme/theme_variant.dart

class AppSettings extends ChangeNotifier {            // lib/state/app_settings.dart
  Lang lang; ThemeVariant theme;
  void setLang(Lang l); void toggleLang(); void setTheme(ThemeVariant v);
}
class AppScope extends InheritedNotifier<AppSettings> { // lib/state/app_scope.dart
  static AppSettings of(BuildContext c, {bool listen = true});
}
class TerminalColors extends ThemeExtension<TerminalColors> { // lib/theme/terminal_colors.dart
  final Color background, surface, border, accent, cyan, amber, text, textDim;
}
extension TermX on BuildContext { TerminalColors get term; } // in terminal_colors.dart

// lib/terminal/command.dart
sealed class CommandEffect {}
class SetLangEffect  extends CommandEffect { final Lang lang; const SetLangEffect(this.lang); }
class SetThemeEffect extends CommandEffect { final ThemeVariant theme; const SetThemeEffect(this.theme); }
class ClearEffect    extends CommandEffect { const ClearEffect(); }
class OpenUrlEffect  extends CommandEffect { final String url; const OpenUrlEffect(this.url); }
class TerminalLine { final String text; final Color? color; final String? url; const TerminalLine(this.text, {this.color, this.url}); }
class CommandResult { final List<TerminalLine> output; final CommandEffect? effect; const CommandResult(this.output, {this.effect}); }

CommandResult runCommand(String input, {required Lang lang}); // lib/terminal/command_parser.dart
```

**Color mapping (Phase 2 리팩터):** `AppColors.green → context.term.accent`; 나머지 동일명 `AppColors.X → context.term.X` (`background/surface/border/cyan/amber/text/textDim`).

---

## File Structure

**신규**
- `lib/models/lang.dart` — Lang enum
- `lib/models/l10n.dart` — L10n 값 타입
- `lib/state/app_settings.dart` — 전역 설정(ChangeNotifier)
- `lib/state/app_scope.dart` — InheritedNotifier 제공자
- `lib/state/settings_store.dart` — shared_preferences 로드/저장
- `lib/theme/theme_variant.dart` — ThemeVariant enum + 메타(라벨)
- `lib/theme/terminal_colors.dart` — ThemeExtension + `context.term`
- `lib/terminal/command.dart` — CommandResult/TerminalLine/Effect
- `lib/terminal/command_parser.dart` — 순수 `runCommand`
- `lib/sections/terminal_section.dart` — 터미널 UI
- `lib/widgets/settings_bar.dart` — 우상단 EN|KO + 테마 버튼
- `lib/boot/boot_gate.dart` — 부팅 게이트
- `lib/boot/boot_sequence.dart` — 부팅 애니메이션
- `lib/boot/atomic_painter.dart` — 보라색 ASCII 폭발 CustomPainter
- 테스트: `test/command_parser_test.dart`, `test/l10n_test.dart`, `test/app_settings_test.dart`, `test/i18n_widget_test.dart`, `test/theme_test.dart`

**수정**
- `pubspec.yaml` — deps 2개
- `lib/theme/app_theme.dart` — `forVariant()` + 팔레트 3종
- `lib/data/profile_data.dart` — 이중언어화
- `lib/models/project.dart` — description/note → L10n
- `lib/main.dart` — 부팅 로드, AppScope, SettingsBar, TerminalSection 배선
- `lib/sections/{hero,about,skills,projects,contact}_section.dart` — localize + `context.term`
- `lib/widgets/{terminal_window,glitch_text,scroll_hint,custom_cursor}.dart` — `context.term`

---

# Phase 1 — i18n 토대

### Task 1: 의존성 추가

**Files:** Modify: `pubspec.yaml:37-42`

- [ ] **Step 1: deps 추가** — `pubspec.yaml`의 `dependencies:` 블록에서 `url_launcher: ^6.3.2` 아래에 추가:

```yaml
  shared_preferences: ^2.3.5
  enough_ascii_art: ^1.1.2
```

- [ ] **Step 2: 설치** — Run: `flutter pub get` · Expected: `Got dependencies!` (에러 없음)
- [ ] **Step 3: Commit** — `git add pubspec.yaml pubspec.lock && git commit -m "chore(deps): add shared_preferences + enough_ascii_art"`

### Task 2: Lang + L10n 모델 (TDD)

**Files:** Create `lib/models/lang.dart`, `lib/models/l10n.dart`, `test/l10n_test.dart`

- [ ] **Step 1: 실패 테스트** — `test/l10n_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_portfolio/models/lang.dart';
import 'package:shadow_portfolio/models/l10n.dart';

void main() {
  test('L10n.of returns the language-specific string', () {
    const t = L10n('Hello', '안녕');
    expect(t.of(Lang.en), 'Hello');
    expect(t.of(Lang.ko), '안녕');
  });
}
```

- [ ] **Step 2: 실패 확인** — Run: `flutter test test/l10n_test.dart` · Expected: FAIL (`lang.dart`/`l10n.dart` 없음)
- [ ] **Step 3: 구현** — `lib/models/lang.dart`:

```dart
enum Lang { en, ko }
```

`lib/models/l10n.dart`:

```dart
import 'lang.dart';

/// A string that carries both English and Korean variants.
class L10n {
  final String en;
  final String ko;
  const L10n(this.en, this.ko);

  String of(Lang lang) => lang == Lang.ko ? ko : en;
}
```

- [ ] **Step 4: 통과 확인** — Run: `flutter test test/l10n_test.dart` · Expected: PASS
- [ ] **Step 5: Commit** — `git add lib/models/lang.dart lib/models/l10n.dart test/l10n_test.dart && git commit -m "feat(i18n): add Lang enum and L10n value type"`

### Task 3: AppSettings (TDD, 영속은 콜백 주입)

**Files:** Create `lib/state/app_settings.dart`, `test/app_settings_test.dart`

- [ ] **Step 1: 실패 테스트** — `test/app_settings_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_portfolio/models/lang.dart';
import 'package:shadow_portfolio/theme/theme_variant.dart';
import 'package:shadow_portfolio/state/app_settings.dart';

void main() {
  test('toggleLang flips language and notifies once', () {
    final s = AppSettings(lang: Lang.en, theme: ThemeVariant.githubDark);
    var notifications = 0;
    s.addListener(() => notifications++);
    s.toggleLang();
    expect(s.lang, Lang.ko);
    expect(notifications, 1);
  });

  test('setLang to same value does not notify', () {
    final s = AppSettings(lang: Lang.en, theme: ThemeVariant.githubDark);
    var notifications = 0;
    s.addListener(() => notifications++);
    s.setLang(Lang.en);
    expect(notifications, 0);
  });

  test('setTheme changes theme and calls onChanged persistence hook', () {
    ThemeVariant? saved;
    final s = AppSettings(
      lang: Lang.en,
      theme: ThemeVariant.githubDark,
      onChanged: (lang, theme) => saved = theme,
    );
    s.setTheme(ThemeVariant.matrixGreen);
    expect(s.theme, ThemeVariant.matrixGreen);
    expect(saved, ThemeVariant.matrixGreen);
  });
}
```

- [ ] **Step 2: 실패 확인** — Run: `flutter test test/app_settings_test.dart` · Expected: FAIL (`theme_variant.dart`/`app_settings.dart` 없음). (Task 4에서 theme_variant를 만드니, 이 태스크에서 먼저 최소 stub `lib/theme/theme_variant.dart`에 `enum ThemeVariant { githubDark, matrixGreen, amberCrt }`를 생성해도 됨.)
- [ ] **Step 3: 구현** — 먼저 `lib/theme/theme_variant.dart`:

```dart
enum ThemeVariant { githubDark, matrixGreen, amberCrt }
```

그리고 `lib/state/app_settings.dart`:

```dart
import 'package:flutter/foundation.dart';
import '../models/lang.dart';
import '../theme/theme_variant.dart';

typedef SettingsChanged = void Function(Lang lang, ThemeVariant theme);

class AppSettings extends ChangeNotifier {
  Lang lang;
  ThemeVariant theme;
  final SettingsChanged? onChanged;

  AppSettings({required this.lang, required this.theme, this.onChanged});

  void setLang(Lang l) {
    if (l == lang) return;
    lang = l;
    _changed();
  }

  void toggleLang() => setLang(lang == Lang.en ? Lang.ko : Lang.en);

  void setTheme(ThemeVariant v) {
    if (v == theme) return;
    theme = v;
    _changed();
  }

  void _changed() {
    onChanged?.call(lang, theme);
    notifyListeners();
  }
}
```

- [ ] **Step 4: 통과 확인** — Run: `flutter test test/app_settings_test.dart` · Expected: PASS
- [ ] **Step 5: Commit** — `git add lib/state/app_settings.dart lib/theme/theme_variant.dart test/app_settings_test.dart && git commit -m "feat(state): add AppSettings controller with persistence hook"`

### Task 4: SettingsStore (shared_preferences 로드/저장)

**Files:** Create `lib/state/settings_store.dart`

- [ ] **Step 1: 구현** (얇은 래퍼라 위젯 테스트로 커버; 유닛 테스트 생략) — `lib/state/settings_store.dart`:

```dart
import 'dart:ui' show PlatformDispatcher;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lang.dart';
import '../theme/theme_variant.dart';

class SettingsStore {
  static const _kLang = 'lang';
  static const _kTheme = 'theme';

  /// Loads saved settings, or derives defaults (browser locale → ko/en).
  static Future<({Lang lang, ThemeVariant theme})> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = switch (prefs.getString(_kLang)) {
      'ko' => Lang.ko,
      'en' => Lang.en,
      _ => _browserDefaultLang(),
    };
    final theme = ThemeVariant.values.firstWhere(
      (v) => v.name == prefs.getString(_kTheme),
      orElse: () => ThemeVariant.githubDark,
    );
    return (lang: lang, theme: theme);
  }

  static Future<void> save(Lang lang, ThemeVariant theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLang, lang.name);
    await prefs.setString(_kTheme, theme.name);
  }

  static Lang _browserDefaultLang() {
    final code = PlatformDispatcher.instance.locale.languageCode;
    return code == 'ko' ? Lang.ko : Lang.en;
  }
}
```

- [ ] **Step 2: 분석 확인** — Run: `flutter analyze lib/state/settings_store.dart` · Expected: `No issues found!`
- [ ] **Step 3: Commit** — `git add lib/state/settings_store.dart && git commit -m "feat(state): add SettingsStore for persistence + locale default"`

### Task 5: AppScope 제공자

**Files:** Create `lib/state/app_scope.dart`

- [ ] **Step 1: 구현** — `lib/state/app_scope.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'app_settings.dart';

class AppScope extends InheritedNotifier<AppSettings> {
  const AppScope({super.key, required AppSettings settings, required super.child})
      : super(notifier: settings);

  static AppSettings of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<AppScope>()
        : context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }
}
```

- [ ] **Step 2: 분석 확인** — Run: `flutter analyze lib/state/app_scope.dart` · Expected: `No issues found!`
- [ ] **Step 3: Commit** — `git add lib/state/app_scope.dart && git commit -m "feat(state): add AppScope InheritedNotifier"`

### Task 6: profile_data + Project 이중언어화

**Files:** Modify `lib/models/project.dart`, `lib/data/profile_data.dart`

- [ ] **Step 1: Project 모델** — `lib/models/project.dart`를 교체:

```dart
import 'l10n.dart';

class Project {
  const Project({
    required this.name,
    required this.description,
    required this.tech,
    required this.image,
    this.link,
    this.note,
  });

  final String name;          // 고유명사 — 번역 안 함
  final L10n description;
  final List<String> tech;    // 기술명 — 번역 안 함
  final String image;
  final String? link;
  final L10n? note;
}
```

- [ ] **Step 2: profile_data** — `lib/data/profile_data.dart`에서 `import '../models/l10n.dart';` 추가하고, 아래 필드를 `L10n`으로 변경(한국어 초안 포함; 톤은 이후 사용자 검수). `handle`/`terminalTitle`/`skills`/링크는 그대로. 예:

```dart
  static const about = L10n(
    'App developer by trade, security tinkerer by obsession.\n\n'
    'I craft cross-platform apps with Flutter & Dart, and spend my off-hours '
    'reverse-engineering games and poking at systems to learn how they really work.\n\n'
    'I like building things — and understanding them well enough to take them apart.',
    '직업은 앱 개발자, 취미는 보안 만지작거리기.\n\n'
    'Flutter와 Dart로 크로스플랫폼 앱을 만들고, 남는 시간엔 게임을 리버스 엔지니어링하며 '
    '시스템이 실제로 어떻게 돌아가는지 파고듭니다.\n\n'
    '무언가를 만드는 것도, 그걸 뜯어볼 만큼 제대로 이해하는 것도 좋아합니다.',
  );

  static const List<L10n> roles = [
    L10n('Flutter App Developer', 'Flutter 앱 개발자'),
    L10n('Security Enthusiast', '보안 애호가'),
    L10n('Game Hacker (for fun)', '게임 해커 (취미로)'),
  ];

  static const List<L10n> awards = [
    L10n('Industrial Engineer Information Security', '정보보안산업기사'),
    L10n('Silver — National Skills Competition (Cyber Security)',
         '은상 — 전국기능경기대회 (사이버 보안)'),
    L10n('Golden — Regional Skills Competition (Mobile App)',
         '금상 — 지방기능경기대회 (모바일 앱)'),
  ];
```

`projects`의 각 `description:`/`note:`를 `L10n(en, ko)`로 감싼다. 예(survev):

```dart
    Project(
      name: 'Survev.io Game Hack',
      description: L10n(
        'Aimbot & ESP for survev.io, an open-source browser game — a reverse-engineering exercise.',
        '오픈소스 브라우저 게임 survev.io용 에임봇 & ESP — 리버스 엔지니어링 연습작.',
      ),
      tech: ['JavaScript'],
      image: 'assets/projects/survev.png',
      note: L10n(
        'Built & tested in an isolated environment only — never used against real players.',
        '격리된 환경에서만 제작·테스트 — 실제 유저 대상 사용 없음.',
      ),
    ),
```

(tarot: `'Card-pick tarot app with multiple spreads — birth-date, love, and more.'` → `'여러 스프레드를 지원하는 카드 선택 타로 앱 — 생년월일, 연애 등.'`; car: `'Vehicle remote-control prototype built with sample data.'` → `'샘플 데이터로 만든 차량 원격제어 프로토타입.'`)

- [ ] **Step 3: 컴파일 깨짐 확인(예상됨)** — Run: `flutter analyze lib/data lib/models` · Expected: 아직 섹션들이 `String`을 기대해 에러 — 다음 태스크에서 해소.
- [ ] **Step 4: Commit** — `git add lib/models/project.dart lib/data/profile_data.dart && git commit -m "feat(i18n): make profile content bilingual (L10n)"`

### Task 7: 섹션 현지화 (about/hero/skills/projects/contact)

**Files:** Modify `lib/sections/about_section.dart`, `hero_section.dart`, `skills_section.dart`, `projects_section.dart`, `contact_section.dart`

각 섹션 `build` 상단에 `final lang = AppScope.of(context).lang;` 추가 후 아래로 교체:

- [ ] **Step 1: about** — `about_section.dart:24-25` `Text(ProfileData.about, …)` → `Text(ProfileData.about.of(lang), …)`. 파일 상단 `import '../state/app_scope.dart';` 추가, `build`에 `final lang = AppScope.of(context).lang;`.
- [ ] **Step 2: hero** — `hero_section.dart`의 roles 루프 `role` → `role.of(lang)` (line 52-55 `for (final role in ProfileData.roles) TypewriterAnimatedText(role.of(lang), …)`). `import '../state/app_scope.dart';` + `final lang = AppScope.of(context).lang;`. (`handle`/`whoami`/`cat roles.txt`는 그대로.)
- [ ] **Step 3: skills** — awards 루프 `award` → `award.of(lang)` (skills_section.dart:40-56, `Text(award.of(lang), …)`). `import`/`lang` 동일. `skills` 배지·프롬프트는 그대로.
- [ ] **Step 4: projects** — `projects_section.dart`: `Text(project.name …)` 유지, `project.note` 사용부(line 114-122)를 `if (project.note != null) … Text('// ${project.note!.of(lang)}', …)`. description은 현재 카드에 미표시이므로 표시 추가는 선택(YAGNI: 유지). `import`/`lang` 추가하되 `lang`은 note에서 사용. tech 태그·`ls projects/`·`🔒 Private`는 그대로.
- [ ] **Step 5: contact** — 프로즈 `"Let's build something from the shadows."`를 `ProfileData`에 `static const contactTagline = L10n("Let's build something from the shadows.", '그림자 속에서 무언가 만들어봅시다.');`로 추가하고 `contact_section.dart:27-30`에서 `Text(ProfileData.contactTagline.of(lang), …)`. `$ ./contact.sh`·버튼 라벨(GitHub 등)은 그대로. `import`/`lang` 추가.
- [ ] **Step 6: 전체 분석** — Run: `flutter analyze lib` · Expected: `No issues found!`
- [ ] **Step 7: Commit** — `git add lib/sections lib/data/profile_data.dart && git commit -m "feat(i18n): localize all sections via AppScope lang"`

### Task 8: main.dart 배선 (AppScope + 부팅 로드 stub) + SettingsBar 언어 토글

**Files:** Modify `lib/main.dart`; Create `lib/widgets/settings_bar.dart`

- [ ] **Step 1: SettingsBar (언어만; 테마 버튼은 Phase 2)** — `lib/widgets/settings_bar.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/lang.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';

class SettingsBar extends StatelessWidget {
  const SettingsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);
    final onColor = AppColors.textDim; // Phase 2에서 context.term.textDim 으로 교체
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Pill(
          label: settings.lang == Lang.en ? 'EN' : 'KO',
          onTap: () => AppScope.of(context, listen: false).toggleLang(),
          color: onColor,
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.onTap, required this.color});
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(label, style: TextStyle(color: color, fontSize: 13)),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: main.dart** — `main()`를 async로 바꿔 설정 로드 후 `AppScope`로 감싸고, `HomePage`의 Stack 우상단에 `SettingsBar`를 얹는다. `main.dart`를 아래로 교체(핵심부):

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final loaded = await SettingsStore.load();
  runApp(ShadowPortfolioApp(
    settings: AppSettings(
      lang: loaded.lang,
      theme: loaded.theme,
      onChanged: SettingsStore.save,
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
        listenable: settings,
        builder: (context, _) => MaterialApp(
          title: ProfileData.handle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark, // Phase 2에서 AppTheme.forVariant(settings.theme)
          home: const CustomCursor(child: HomePage()),
        ),
      ),
    );
  }
}
```

`HomePage`의 `Stack` children에 스크롤 힌트와 함께 우상단 고정 추가:

```dart
              Positioned(
                top: 20,
                right: 20,
                child: SafeArea(child: const SettingsBar()),
              ),
```

필요한 import 추가: `state/app_settings.dart`, `state/app_scope.dart`, `state/settings_store.dart`, `widgets/settings_bar.dart`.

- [ ] **Step 3: 실행 확인** — Run: `flutter run -d chrome` (또는 `flutter build web`) · Expected: 빌드 성공, 우상단 `EN` 클릭 시 About/Hero/Awards가 한국어로 토글.
- [ ] **Step 4: i18n 위젯 테스트** — `test/i18n_widget_test.dart`:

```dart
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
```

- [ ] **Step 5: 테스트 통과** — Run: `flutter test test/i18n_widget_test.dart` · Expected: PASS
- [ ] **Step 6: Commit** — `git add lib/main.dart lib/widgets/settings_bar.dart test/i18n_widget_test.dart && git commit -m "feat(i18n): wire AppScope + language toggle in SettingsBar"`

---

# Phase 2 — 테마 시스템

### Task 9: TerminalColors ThemeExtension + context.term (TDD)

**Files:** Create `lib/theme/terminal_colors.dart`, `test/theme_test.dart`

- [ ] **Step 1: 실패 테스트** — `test/theme_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_portfolio/theme/theme_variant.dart';
import 'package:shadow_portfolio/theme/app_theme.dart';
import 'package:shadow_portfolio/theme/terminal_colors.dart';

void main() {
  test('each variant yields a distinct accent color', () {
    final gh = AppTheme.forVariant(ThemeVariant.githubDark).extension<TerminalColors>()!;
    final mx = AppTheme.forVariant(ThemeVariant.matrixGreen).extension<TerminalColors>()!;
    expect(gh.accent, isNot(mx.accent));
  });
}
```

- [ ] **Step 2: 실패 확인** — Run: `flutter test test/theme_test.dart` · Expected: FAIL
- [ ] **Step 3: 구현** — `lib/theme/terminal_colors.dart`:

```dart
import 'package:flutter/material.dart';

@immutable
class TerminalColors extends ThemeExtension<TerminalColors> {
  final Color background, surface, border, accent, cyan, amber, text, textDim;
  const TerminalColors({
    required this.background, required this.surface, required this.border,
    required this.accent, required this.cyan, required this.amber,
    required this.text, required this.textDim,
  });

  @override
  TerminalColors copyWith({Color? background, Color? surface, Color? border,
      Color? accent, Color? cyan, Color? amber, Color? text, Color? textDim}) =>
      TerminalColors(
        background: background ?? this.background, surface: surface ?? this.surface,
        border: border ?? this.border, accent: accent ?? this.accent,
        cyan: cyan ?? this.cyan, amber: amber ?? this.amber,
        text: text ?? this.text, textDim: textDim ?? this.textDim,
      );

  @override
  TerminalColors lerp(ThemeExtension<TerminalColors>? other, double t) {
    if (other is! TerminalColors) return this;
    return TerminalColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      cyan: Color.lerp(cyan, other.cyan, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      text: Color.lerp(text, other.text, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
    );
  }
}

extension TermX on BuildContext {
  TerminalColors get term => Theme.of(this).extension<TerminalColors>()!;
}
```

- [ ] **Step 4: app_theme.dart 확장** — `lib/theme/app_theme.dart`에 팔레트 3종 + `forVariant` 추가(기존 `AppColors`는 유지하되 githubDark 값과 동일). `AppTheme` 클래스에:

```dart
  static const _palettes = {
    ThemeVariant.githubDark: TerminalColors(
      background: Color(0xFF0D1117), surface: Color(0xFF161B22), border: Color(0xFF30363D),
      accent: Color(0xFF3FB950), cyan: Color(0xFF39D0D8), amber: Color(0xFFE3B341),
      text: Color(0xFFC9D1D9), textDim: Color(0xFF8B949E)),
    ThemeVariant.matrixGreen: TerminalColors(
      background: Color(0xFF0A0F0A), surface: Color(0xFF0F160F), border: Color(0xFF1F3A1F),
      accent: Color(0xFF39FF14), cyan: Color(0xFF7CFFB2), amber: Color(0xFF9EFF6E),
      text: Color(0xFFC8FFC8), textDim: Color(0xFF5C8A5C)),
    ThemeVariant.amberCrt: TerminalColors(
      background: Color(0xFF1A1206), surface: Color(0xFF241A0A), border: Color(0xFF3D2E12),
      accent: Color(0xFFFFB000), cyan: Color(0xFFFFD27F), amber: Color(0xFFFFCC66),
      text: Color(0xFFFFDFA6), textDim: Color(0xFFB58A4C)),
  };

  static ThemeData forVariant(ThemeVariant v) {
    final p = _palettes[v]!;
    final base = ThemeData.dark();
    final mono = GoogleFonts.jetBrainsMonoTextTheme(base.textTheme);
    return base.copyWith(
      scaffoldBackgroundColor: p.background,
      extensions: [p],
      textTheme: mono.apply(bodyColor: p.text, displayColor: p.text),
      colorScheme: base.colorScheme.copyWith(
        primary: p.accent, secondary: p.cyan, surface: p.surface),
    );
  }
```

`import 'theme_variant.dart';` + `import 'terminal_colors.dart';` 추가.

- [ ] **Step 5: 통과 확인** — Run: `flutter test test/theme_test.dart` · Expected: PASS
- [ ] **Step 6: Commit** — `git add lib/theme/terminal_colors.dart lib/theme/app_theme.dart test/theme_test.dart && git commit -m "feat(theme): add TerminalColors ThemeExtension + 3 palettes"`

### Task 10: AppColors 참조를 context.term 으로 치환

**Files:** Modify (46곳/10파일): `lib/widgets/{terminal_window,glitch_text,scroll_hint,custom_cursor}.dart`, `lib/sections/{hero,about,skills,projects,contact}_section.dart`

- [ ] **Step 1: 치환 규칙 적용** — 각 파일에서 `AppColors.green`→`context.term.accent`, `AppColors.{background,surface,border,cyan,amber,text,textDim}`→`context.term.X`. `build(context)` 스코프 안에서만 접근 가능하므로, `const` 위젯/`StatelessWidget`의 정적 상수 위치에 쓰인 경우 해당 위젯에서 `context`를 받아 처리하거나 부모에서 색을 주입. (`terminal_window.dart`의 `_Dot`은 신호등 하드코딩 색이라 변경 불필요.) `import '../theme/app_theme.dart';`는 `AppColors`를 더 안 쓰면 `import '../theme/terminal_colors.dart';`로 교체.
- [ ] **Step 2: settings_bar.dart도 교체** — Task 8 Step 1의 `AppColors.*`를 `context.term.*`로.
- [ ] **Step 3: 분석** — Run: `flutter analyze lib` · Expected: `No issues found!` (미사용 import 경고 0)
- [ ] **Step 4: 실행 확인** — Run: `flutter build web` · Expected: 성공
- [ ] **Step 5: Commit** — `git add lib && git commit -m "refactor(theme): read colors from context.term (ThemeExtension)"`

### Task 11: main.dart 테마 반영 + SettingsBar 테마 버튼

**Files:** Modify `lib/main.dart`, `lib/widgets/settings_bar.dart`, `lib/theme/theme_variant.dart`

- [ ] **Step 1: theme_variant 라벨** — `lib/theme/theme_variant.dart`에 확장 추가:

```dart
extension ThemeVariantMeta on ThemeVariant {
  String get label => switch (this) {
    ThemeVariant.githubDark => 'gh-dark',
    ThemeVariant.matrixGreen => 'matrix',
    ThemeVariant.amberCrt => 'amber',
  };
  ThemeVariant get next =>
      ThemeVariant.values[(index + 1) % ThemeVariant.values.length];
}
```

- [ ] **Step 2: main.dart** — `theme: AppTheme.dark` → `theme: AppTheme.forVariant(settings.theme)`.
- [ ] **Step 3: SettingsBar 테마 버튼** — `SettingsBar`의 Row에 언어 pill 옆에 테마 순환 pill 추가:

```dart
        const SizedBox(width: 8),
        _Pill(
          label: settings.theme.label,
          onTap: () => AppScope.of(context, listen: false).setTheme(settings.theme.next),
          color: context.term.accent,
        ),
```

`import '../theme/terminal_colors.dart';` 및 `import '../theme/theme_variant.dart';` 추가.

- [ ] **Step 4: 실행 확인** — Run: `flutter run -d chrome` · Expected: 테마 pill 클릭 시 gh-dark→matrix→amber 순환, 전 섹션 색 전환.
- [ ] **Step 5: Commit** — `git add lib/main.dart lib/widgets/settings_bar.dart lib/theme/theme_variant.dart && git commit -m "feat(theme): live theme switcher in SettingsBar"`

---

# Phase 3 — 인터랙티브 터미널

### Task 12: command 모델 + 순수 파서 (TDD)

**Files:** Create `lib/terminal/command.dart`, `lib/terminal/command_parser.dart`, `test/command_parser_test.dart`

- [ ] **Step 1: 실패 테스트** — `test/command_parser_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_portfolio/models/lang.dart';
import 'package:shadow_portfolio/terminal/command.dart';
import 'package:shadow_portfolio/terminal/command_parser.dart';

void main() {
  test('help lists known commands', () {
    final r = runCommand('help', lang: Lang.en);
    expect(r.output.any((l) => l.text.contains('whoami')), isTrue);
    expect(r.effect, isNull);
  });

  test('unknown command returns not-found', () {
    final r = runCommand('foobar', lang: Lang.en);
    expect(r.output.single.text, contains('command not found'));
  });

  test('lang ko returns SetLangEffect', () {
    final r = runCommand('lang ko', lang: Lang.en);
    expect(r.effect, isA<SetLangEffect>());
    expect((r.effect as SetLangEffect).lang, Lang.ko);
  });

  test('clear returns ClearEffect', () {
    expect(runCommand('clear', lang: Lang.en).effect, isA<ClearEffect>());
  });

  test('empty input returns empty output, no effect', () {
    final r = runCommand('   ', lang: Lang.en);
    expect(r.output, isEmpty);
    expect(r.effect, isNull);
  });

  test('about respects language', () {
    expect(runCommand('about', lang: Lang.ko).output.any((l) => l.text.contains('앱 개발자')), isTrue);
  });
}
```

- [ ] **Step 2: 실패 확인** — Run: `flutter test test/command_parser_test.dart` · Expected: FAIL
- [ ] **Step 3: command.dart** — Shared Contracts의 `command.dart` 블록을 그대로 생성.
- [ ] **Step 4: command_parser.dart 구현** — `runCommand`: 입력 trim→소문자 첫 토큰 분기. 반환 규칙: 빈 입력→`CommandResult([])`; `help`→명령 설명 줄들; `whoami`→handle+roles; `about`→`ProfileData.about.of(lang)` 줄들; `skills`/`projects`/`awards`→목록; `contact`→링크 4개(각 `TerminalLine(label, url: ...)`); `lang ko|en`→`SetLangEffect`; `theme <name>`→매칭 시 `SetThemeEffect` 아니면 목록; `clear`→`ClearEffect`; `sudo hire-me`→이메일 안내 + `OpenUrlEffect('mailto:...')`; `neofetch`→오리지널 ASCII 정보; 그 외→`command not found: <cmd> — type 'help'`. (색은 `TerminalLine.color`에 넣지 말고 위젯에서 `context.term`으로 렌더 — 파서는 순수 유지, 링크만 `url`.)
- [ ] **Step 5: 통과 확인** — Run: `flutter test test/command_parser_test.dart` · Expected: PASS
- [ ] **Step 6: Commit** — `git add lib/terminal test/command_parser_test.dart && git commit -m "feat(terminal): pure command parser (TDD)"`

### Task 13: TerminalSection 위젯

**Files:** Create `lib/sections/terminal_section.dart`; Modify `lib/main.dart`

- [ ] **Step 1: 위젯 구현** — `TerminalWindow` 프레임 재사용, 제목 `yj@shadow: ~`. 상태: `List<TerminalLine> _scrollback`(상한 200), `TextEditingController`, `List<String> _history` + 인덱스. `_submit(input)`: `_history`에 추가 → `runCommand(input, lang: AppScope.of(context,listen:false).lang)` → `result.effect` 처리(`SetLangEffect`→`setLang`, `SetThemeEffect`→`setTheme`, `ClearEffect`→`_scrollback.clear()`, `OpenUrlEffect`→`launchUrl`) → 프롬프트 에코(`visitor@yj0:~$ $input`)와 `result.output`을 `_scrollback`에 append → 하한 초과 시 앞부분 제거. 입력 위 `Focus`/`KeyboardListener`로 ↑/↓ 히스토리. 링크 줄은 탭 시 `launchUrl`. 색은 `context.term`(prompt=accent, 일반=text, dim=textDim). `TextField`는 테두리 없이 커서 깜빡임.
- [ ] **Step 2: main.dart 삽입** — `HomePage`의 Column에서 `HeroSection()` 바로 아래에 삽입:

```dart
                          const SizedBox(height: 40),
                          const RevealOnScroll(child: TerminalSection()),
```

`import '../sections/terminal_section.dart';`(main은 상대경로 `sections/terminal_section.dart`).

- [ ] **Step 3: 실행 확인** — Run: `flutter run -d chrome` · Expected: 터미널에 `help`, `about`, `theme matrix`, `lang ko`, `clear` 입력 동작. `theme`/`lang` 명령이 헤더 버튼과 동일하게 반영.
- [ ] **Step 4: Commit** — `git add lib/sections/terminal_section.dart lib/main.dart && git commit -m "feat(terminal): interactive TerminalSection below hero"`

---

# Phase 4 — 부팅 시퀀스 (오리지널 오마주)

### Task 14: AtomicPainter (보라색 ASCII 폭발)

**Files:** Create `lib/boot/atomic_painter.dart`

- [ ] **Step 1: 구현** — `CustomPainter`가 `progress`(0→1)에 따라 중앙에서 바깥으로 ASCII 글리프(`*`, `#`, `▓`, `@`)를 보라색 계열(`Color(0xFF9D4EDD)`~`Color(0xFFC77DFF)`)로 그리드에 채운다. 셀 크기 고정(예: 14px)으로 그리드 수 제한(성능), 매 프레임 `TextPainter` 재사용/캐시. `shouldRepaint`는 `progress` 변경 시 true. 개별 위젯 수천 개 대신 단일 `CustomPaint`로 렌더(성능 함정 회피).
- [ ] **Step 2: 분석** — Run: `flutter analyze lib/boot/atomic_painter.dart` · Expected: `No issues found!`
- [ ] **Step 3: Commit** — `git add lib/boot/atomic_painter.dart && git commit -m "feat(boot): AtomicPainter purple ASCII blast"`

### Task 15: BootSequence 애니메이션

**Files:** Create `lib/boot/boot_sequence.dart`

- [ ] **Step 1: 구현** — `StatefulWidget`, `onDone` 콜백. `flutter_animate` 타임라인: (a) 부팅 로그 라인들 타이핑(`animated_text_kit` `TypewriterAnimatedText`, EN) → (b) 오리지널 검 실루엣(문자열 상수, **원작 미재현**) `flutter_animate`로 rotate/translate 상승 → (c) `enough_ascii_art.renderFiglet('I AM ATOMIC', font)` 결과를 monospace `Text`로 표시 + 보라색 `Animate` scale/glow → (d) `AtomicPainter`를 `AnimationController`로 progress 0→1 → (e) `onDone()`. 총 ~2.5–3.5초. 화면 어디든 `GestureDetector`(tap)/`Focus`(key)/스크롤 감지로 즉시 `onDone`. `MediaQuery.of(context).disableAnimations`면 `initState`에서 바로 `onDone`. FIGlet 폰트는 assets에 `.flf` 하나 추가하거나, 배너 문자열을 const로 pre-bake(런타임 의존성 회피). ⚠️ 검/폭발/문자 모두 **오리지널** — 팬 아트/원작 프레임 복사 금지.
- [ ] **Step 2: 분석** — Run: `flutter analyze lib/boot/boot_sequence.dart` · Expected: `No issues found!`
- [ ] **Step 3: Commit** — `git add lib/boot/boot_sequence.dart assets && git commit -m "feat(boot): original Shadow/Atomic ASCII boot sequence"`

### Task 16: BootGate + main 배선

**Files:** Create `lib/boot/boot_gate.dart`; Modify `lib/main.dart`

- [ ] **Step 1: BootGate** — `lib/boot/boot_gate.dart`: `StatefulWidget`으로 `bool _booted=false`, `child` 보유. `!_booted`면 `BootSequence(onDone: () => setState(()=>_booted=true))` 전체화면, 아니면 `child`. `disableAnimations`면 초기값 `_booted=true`.
- [ ] **Step 2: main 삽입** — `MaterialApp.home`을 `BootGate(child: CustomCursor(child: HomePage()))`로 감싼다. `import 'boot/boot_gate.dart';`.
- [ ] **Step 3: 실행 확인** — Run: `flutter run -d chrome` · Expected: 첫 로드 시 부팅 인트로 재생 후 본문. 클릭/키로 스킵. OS 애니메이션 끄기(reduced-motion) 시 즉시 본문.
- [ ] **Step 4: Commit** — `git add lib/boot/boot_gate.dart lib/main.dart && git commit -m "feat(boot): BootGate plays intro on each load, skippable + reduced-motion"`

### Task 17: 모바일 마감 + 최종 검증

**Files:** Modify (필요 시) `boot_sequence.dart`, `terminal_section.dart`

- [ ] **Step 1: 모바일 폭** — `flutter run -d chrome` 후 DevTools 모바일(375px)에서 배너 `FittedBox` 스케일, 터미널 입력/스크롤 확인. 오버플로 있으면 수정.
- [ ] **Step 2: 전체 테스트** — Run: `flutter test` · Expected: 전 테스트 PASS
- [ ] **Step 3: 전체 분석** — Run: `flutter analyze` · Expected: `No issues found!`
- [ ] **Step 4: 웹 빌드** — Run: `flutter build web` · Expected: 성공
- [ ] **Step 5: Commit** — `git add -A && git commit -m "polish: mobile boot/terminal layout + final verification"`

---

## Self-Review

- **Spec 커버리지:** F1 i18n(Task 2,6,7,8) / F2 터미널(Task 12,13) / F3 테마(Task 9,10,11) / F4 부팅(Task 14,15,16,17) / AppSettings·AppScope·영속(Task 3,4,5) / SettingsBar(Task 8,11) — 스펙 §3 전 항목 매핑됨.
- **타입 일관성:** `Lang`, `L10n.of`, `AppSettings.{setLang,toggleLang,setTheme}`, `AppScope.of`, `TerminalColors`+`context.term`, `ThemeVariant.{label,next}`, `runCommand`/`CommandResult`/`*Effect` — Shared Contracts와 전 태스크 일치 확인.
- **순서 의존성:** Phase 2/3의 `lang`/`theme` 명령·색상이 Phase 1의 AppSettings/AppScope, Phase 2의 TerminalColors에 의존 → 페이즈 순서 준수. 부팅(Phase 4)은 독립.
- **저작권:** 부팅은 오리지널 오마주만(Task 15,16 명시), 원작/팬아트 미복사.
- **알려진 재량 항목:** 한국어 번역 톤·팔레트 색값·FIGlet 폰트는 구현 중 사용자 검수 여지.
