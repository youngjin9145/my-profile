# KO/EN 토글 + 인터랙티브 기능 — 설계 문서

> **대상 사이트:** [yj0.app](https://yj0.app/) — Flutter Web 개발자 프로필
> **작성일:** 2026-07-05
> **상태:** 설계 승인 완료 → 구현 플랜 대기

---

## 1. 개요 & 목표

기존 단일 스크롤 프로필(Hero → About → Skills → Projects → Contact, 터미널/다크 무드)에 아래 4개를 **추가**한다. 기존 섹션·인터랙션(커스텀 커서, 자석 호버, 글리치, 스크롤 리빌)은 그대로 유지.

| # | 기능 | 한 줄 정의 |
|---|---|---|
| F1 | **KO/EN 토글** | 전체 콘텐츠 이중언어 (문장은 번역, 기술명·고유명사·명령어는 영어 유지) |
| F2 | **인터랙티브 터미널** | Hero 아래 실제 명령어 입력 셸 (스크롤 섹션을 대체하지 않고 추가) |
| F3 | **테마 스위처** | 터미널 색테마 3종 실시간 전환 |
| F4 | **부팅 시퀀스** | 첫 로드 시 "Shadow / I Am Atomic" **오리지널 오마주** ASCII 인트로 (스킵 가능) |

**핵심 설계 원칙:** 언어(F1)와 테마(F3)는 둘 다 "앱 전역 설정"이고, **헤더 버튼**과 **터미널 명령**(F2) 양쪽에서 변경 가능해야 한다 → 하나의 `AppSettings` 컨트롤러로 일원화하는 것이 전체 아키텍처의 뼈대.

---

## 2. 아키텍처

```
main() ── shared_preferences 로드(저장된 lang/theme) ── runApp
 └ AppScope  (InheritedNotifier<AppSettings>)        ← lang + theme 상태, 변경 시 저장
    └ MaterialApp(theme: AppTheme.forVariant(settings.theme))   ← 테마 변경 = 여기서 리빌드
       └ BootGate  (부팅 시퀀스 1회 재생 → 본문)               ← F4
          └ CustomCursor
             └ HomePage (Stack)
                ├ 우상단 고정 SettingsBar  ([EN|KO] 토글 + 테마 버튼)   ← F1/F3 UI
                ├ SingleChildScrollView:
                │    HeroSection            (localized 타이핑)
                │    TerminalSection        ← F2 (NEW, Hero 바로 아래)
                │    AboutSection           (localized)
                │    SkillsSection          (localized awards; skills는 EN)
                │    ProjectsSection        (localized desc/note)
                │    ContactSection         (localized 프로즈)
                └ ScrollHint
```

**데이터 흐름:** `SettingsBar` 버튼과 `TerminalSection`의 `lang`/`theme` 명령이 **같은 `AppSettings`**를 변경 → `notifyListeners()` → 루트가 리빌드(테마 스왑) + 하위 위젯이 새 `lang`으로 텍스트 재조회. 변경 시 `shared_preferences`에 저장.

---

## 3. 컴포넌트별 설계

### 3.1 AppSettings + AppScope (전역 설정)

```dart
enum Lang { en, ko }

class AppSettings extends ChangeNotifier {
  Lang lang;
  ThemeVariant theme;
  AppSettings({required this.lang, required this.theme});

  void setLang(Lang l)        { if (l == lang) return; lang = l; _persistAndNotify(); }
  void toggleLang()           { setLang(lang == Lang.en ? Lang.ko : Lang.en); }
  void setTheme(ThemeVariant v){ if (v == theme) return; theme = v; _persistAndNotify(); }
}
```

- **제공:** `AppScope extends InheritedNotifier<AppSettings>` — `AppScope.of(context)`로 접근, `AppScope.of(context, listen:false)`로 부수효과 호출.
- **루트:** `AppSettings`를 보유하는 StatefulWidget이 `ListenableBuilder`로 `MaterialApp`을 감싸 테마 리빌드 + `AppScope`로 하위 제공.
- **기본값:** 저장값 없으면 `PlatformDispatcher.instance.locale`로 브라우저 언어 감지(ko → `Lang.ko`, else `Lang.en`), 테마는 `githubDark`.
- **영속:** `shared_preferences`(웹에서 localStorage로 동작). 로드는 `main()`에서 `runApp` 전 `await`.

### 3.2 F1 — i18n (전체 콘텐츠 이중언어)

**모델** (신규 `lib/models/l10n.dart`):
```dart
class L10n {
  final String en;
  final String ko;
  const L10n(this.en, this.ko);
  String of(Lang l) => l == Lang.ko ? ko : en;
}
```

**데이터 리팩터** (`profile_data.dart`, `project.dart`):
| 필드 | 변경 |
|---|---|
| `about` | `String` → `L10n` |
| `roles` | `List<String>` → `List<L10n>` (Hero 타이핑) |
| `awards` | `List<String>` → `List<L10n>` |
| `Project.description` | `String` → `L10n` |
| `Project.note` | `String?` → `L10n?` |
| `skills` | **유지** (Dart, Flutter… 기술명은 EN) |
| 섹션 프로즈 | 예: `"Let's build something from the shadows."` → `L10n`. 단, `$ ls skills/` 같은 **명령형 프롬프트는 EN 유지** |

**섹션 위젯:** `final lang = AppScope.of(context).lang;` 후 `ProfileData.about.of(lang)` 식으로 조회. 한국어 초안은 구현 시 작성하고 사용자가 검수.

### 3.3 F3 — 테마 시스템 (ThemeExtension)

현재 `AppColors.green` 등 **정적 상수 참조**를 테마 반응형으로 전환:

```dart
enum ThemeVariant { githubDark, matrixGreen, amberCrt }

@immutable
class TerminalColors extends ThemeExtension<TerminalColors> {
  final Color background, surface, border, accent, cyan, amber, text, textDim;
  // copyWith(...) + lerp(...) 구현 (테마 전환 애니메이션용)
}

class AppTheme {
  static ThemeData forVariant(ThemeVariant v); // TerminalColors를 extension으로 실어 반환
}

extension TermColors on BuildContext {
  TerminalColors get term => Theme.of(this).extension<TerminalColors>()!;
}
```

- **팔레트 3종:** `githubDark`(현재: bg #0D1117 / accent #3FB950), `matrixGreen`(검정 bg / 형광 그린), `amberCrt`(다크 브라운 bg / 앰버).
- **기계적 치환:** 전 위젯의 `AppColors.green→context.term.accent`, `AppColors.text→context.term.text` 등. `AppColors`는 팔레트 정의부로 축소.
- 테마 전환 = `MaterialApp.theme` 스왑 → 자동 반응형.

### 3.4 F2 — 인터랙티브 터미널

**순수 파서** (신규 `lib/terminal/command_parser.dart`) — 부수효과 없이 테스트 가능:
```dart
class CommandResult {
  final List<TerminalLine> output;   // 화면에 출력할 줄들 (텍스트+색/링크)
  final CommandEffect? effect;       // setLang / setTheme / clear / openUrl — 위젯이 실행
}
CommandResult runCommand(String input, {required Lang lang});
```

**명령어:**
| 명령 | 동작 |
|---|---|
| `help` | 명령 목록 |
| `whoami` | 이름/직함 |
| `about` | 자기소개 (localized) |
| `skills` | 기술 목록 |
| `projects` | 프로젝트 목록 |
| `awards` | 수상 내역 (localized) |
| `contact` | 소셜 링크 (클릭 가능) → `openUrl` effect |
| `lang [ko\|en]` | 언어 전환 → `setLang` effect |
| `theme [name\|list]` | 테마 전환/목록 → `setTheme` effect |
| `clear` | 스크롤백 비우기 → `clear` effect |
| `sudo hire-me` | 재미 요소 → 이메일 유도 |
| `neofetch` | ASCII 시스템 정보(오리지널) |
| (미지의 명령) | `command not found: X — type 'help'` |

**위젯** (`lib/sections/terminal_section.dart`): 기존 `TerminalWindow` 프레임 재사용, 제목 `yj@shadow: ~`. 스크롤백 리스트 + 입력(프롬프트 `visitor@yj0:~$ ` + 깜빡이는 커서). ↑/↓ 히스토리, 아무 데나 클릭 시 포커스. 스크롤백은 상한(예: 200줄)으로 캡. `effect`는 위젯이 `AppScope`/`url_launcher`로 실행.
- **위치:** Hero 바로 아래.
- **모바일:** 소프트 키보드로 동작(스크롤 섹션이 주 경로라 필수 아님).
- **Tab 자동완성:** 범위 외(후속).

### 3.5 F1/F3 UI — SettingsBar

우상단 `Positioned` 고정 바: `[EN|KO]` 토글 + 테마 순환/메뉴 버튼. `AppScope.of(context, listen:false)`로 `toggleLang()`/`setTheme()` 호출. (PLAN.md에서 생략했던 상단 내비 대신 최소 설정 클러스터 — 풀 내비 아님.)

### 3.6 F4 — 부팅 시퀀스 (오리지널 오마주, A안)

`BootGate`가 **매 페이지 로드마다**(최초 방문 1회 한정 아님) `BootSequence` 오버레이를 재생한 뒤 본문 노출. 짧고 스킵 가능하므로 반복 방문자도 부담 적음. (원하면 후속에 "세션당 1회"(sessionStorage) 옵션 추가 가능.)

**연출 시퀀스** (`flutter_animate` 타임라인, ~2.5–3.5초):
1. 부팅 로그 타이핑 (`animated_text_kit`, EN 유지) → 글리치
2. 검 치켜올리는 **오리지널** ASCII 실루엣이 회전/상승 (`flutter_animate` transform)
3. 대형 `I AM ATOMIC` ASCII 배너 슬램 — `enough_ascii_art`의 `renderFiglet()`로 생성(또는 const로 pre-bake) + `ColorizeAnimatedText`(기존 의존성)로 **보라색 그라데이션 스윕** + 글로우/셰이크
4. **보라색 ASCII 폭발**이 화면을 채움 — `CustomPainter` 그리드 확산(주) / `newton_particles`(대안)
5. 페이드 → 본문

**제약/규칙:**
- 클릭/스크롤/키로 **즉시 스킵**. `MediaQuery.disableAnimations`(prefers-reduced-motion)면 **자동 건너뜀**.
- 렌더 색상은 Flutter `TextSpan`(스팬별 색) 사용 — 매 프레임 수천 스팬 리빌드 지양, `CustomPainter`로 그리거나 그리드 크기 제한.
- 부팅 로그·`I AM ATOMIC` 문구는 EN 유지(번역 불필요).
- ⚠️ **저작권:** 원작 클립·캐릭터 외형을 **재현하지 않는다.** 오리지널 실루엣/ASCII로 "느낌"만 오마주. 짧은 문구 "I AM ATOMIC"의 텍스트 표시는 허용 범위. 팬메이드 캐릭터 ASCII(예: emojicombos) **복사 금지**.

---

## 4. 의존성 변경

| 패키지 | 용도 | 비고 |
|---|---|---|
| `shared_preferences` | lang/theme 영속(localStorage) | 신규 |
| `enough_ascii_art` | 부팅 `I AM ATOMIC` FIGlet 배너 | 신규 (순수 Dart, web✓, MPL-2.0). const pre-bake 시 런타임 제거 가능 |
| `newton_particles` | 폭발 파티클(대안) | 선택 — `CustomPainter`로 대체 가능 |

기존 `google_fonts`·`flutter_animate`·`animated_text_kit`·`visibility_detector`·`font_awesome_flutter`·`url_launcher`로 나머지 해결. (매우 초기 버전인 `animated_text_effects`(0.0.x)는 안정성 이유로 **미채택**.)

---

## 5. 에러 처리 & 엣지 케이스

- `shared_preferences` 불가 → 인메모리 기본값으로 폴백(크래시 없음).
- 터미널 `lang`/`theme` 잘못된 인자 → 유효 옵션 안내 메시지.
- 스크롤백 무한 증가 방지 → 상한 캡.
- 모바일 폭에서 배너 오버플로 → `FittedBox`/스케일.
- 부팅이 첫 상호작용을 막지 않도록 스킵은 항상 즉시 반응.

---

## 6. 테스트 (비중에 맞춰 최소)

- **유닛(TDD):** `runCommand()` 순수 함수 — 전 명령/미지 명령/인자 파싱, `effect` 정확성.
- **유닛:** `L10n.of(lang)` 해석, `AppSettings` 토글/`setTheme` 로직.
- **위젯 스모크:** 언어 토글 시 알려진 문자열 교체 확인, 테마 전환 시 `TerminalColors` 변경, 부팅 스킵 동작, reduced-motion 경로.

---

## 7. 단계별 구현 (의존순)

1. **Phase 1 — i18n 토대:** `AppSettings`+`AppScope` + `L10n` 모델 + 데이터 이중언어화 + 섹션 현지화 + `SettingsBar` 언어 토글 + 영속. → 브라우저에서 KO/EN 전환 확인.
2. **Phase 2 — 테마 시스템:** `TerminalColors` ThemeExtension + 팔레트 3종 + `AppColors` 참조 치환 + `SettingsBar` 테마 버튼. → 3종 전환 확인.
3. **Phase 3 — 터미널:** 순수 파서(TDD) + `TerminalSection` + `lang`/`theme`/`contact` effect 배선. → 명령 입력 확인.
4. **Phase 4 — 부팅 + 폴리시:** `BootSequence`(오리지널 오마주) + `BootGate` + 스킵/reduced-motion + 모바일 마감. → 인트로 확인.

터미널의 `lang`/`theme` 명령이 Phase 1·2 컨트롤러에 의존 → 이 순서. 부팅은 독립이라 마지막.

---

## 8. 범위 외 (YAGNI)

- 이스터에그/코나미 모드(이번 선택 제외), 터미널 Tab 자동완성(후속), 방문 분석, SEO/OG(별도 작업), 3종 초과 테마, 컨택트 폼, 블로그.

---

## 부록 — 리서치 근거 (부팅 방향 A안)

2026-07-05 딥리서치(23개 소스·24개 검증 주장) 결론: "그 장면 전체를 만든 기성 라이브러리는 없음". 검증된 빌딩블록 — [`enough_ascii_art`](https://pub.dev/packages/enough_ascii_art)(순수 Dart, web 태그 자동 부여, `renderFiglet()`), Flutter `TextSpan`(스팬별 색), [`ColorizeAnimatedText`](https://pub.dev/documentation/animated_text_kit/latest/animated_text_kit/ColorizeAnimatedText-class.html)(색 스윕, 기존 의존성), [`newton_particles`](https://pub.dev/packages/newton_particles)(순수 Dart 파티클). B안 변환기([chafa](https://github.com/hpjansson/chafa)/[ascii-image-converter](https://github.com/TheZoraiz/ascii-image-converter)/[aalib.js](https://github.com/mir3z/aalib.js))는 오프라인/JS-interop 성격 + 가독성·번들·저작권 리스크로 비채택. (반증됨: `bytebeats/AsciiArt`는 Dart 86%지만 실제론 기본 카운터 데모라 무용.)
