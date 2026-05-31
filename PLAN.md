# 🚀 Youngjin Lee's Dev Portfolio — 개발 플랜

> Flutter Web 기반 인터랙티브 개발자 프로필 사이트
> 한 단계씩 같이 만들고, 매 단계 브라우저로 실행해 눈으로 확인하며 진행한다.

**🎉 완성 & 라이브:** https://yj0.app/ — Phase 0~5 전부 완료 ✅

## 📌 확정된 스펙

- **플랫폼**: Flutter Web (Flutter 3.41.5 / Dart 3.11.3)
- **섹션**: Hero + About / Skills / Projects / Contact
- **무드**: Terminal / Dev Dark (모노스페이스, 다크 배경, 그린 포인트)
- **인터랙션**: 커스텀 커서+트레일 / 자석 호버 버튼 / 타이핑 텍스트 / 스크롤 리빌
- **배포**: GitHub Pages

## 🧰 패키지 스택

| 패키지 | 역할 |
|---|---|
| google_fonts | 모노스페이스 폰트 (JetBrains Mono) |
| flutter_animate | 페이드/슬라이드/글로우 애니메이션 |
| animated_text_kit | 타이핑(타자기) 텍스트 |
| visibility_detector | 스크롤 리빌 트리거 |
| font_awesome_flutter | 소셜 브랜드 아이콘 |
| url_launcher | 외부 링크/메일 열기 |

> 커스텀 커서 + 자석 호버는 패키지 없이 `MouseRegion`/`Listener`로 직접 구현.

---

## 🗺️ 단계별 로드맵

각 단계 끝 = **브라우저에서 실행해 확인하는 체크포인트**.

### Phase 0 — 프로젝트 스캐폴딩
- [x] `flutter create` 로 웹 프로젝트 생성
- [x] pubspec.yaml 에 패키지 6개 추가
- [x] main.dart 정리 (기본 카운터 앱 제거 → 다크 캔버스)
- [x] `flutter run -d chrome` 으로 화면 뜨는지 확인 ✅

### Phase 1 — 테마 토대 (Dev Dark 룩) ✅ 완료
- [x] `theme/app_theme.dart` — 색 팔레트 + 모노스페이스 텍스트 스타일
- [x] `widgets/terminal_window.dart` — 터미널 창 프레임 (상단 신호등 점 3개)
- [x] 샘플 화면으로 룩앤필 확인 (BootScreen에 터미널 창 표시)

### Phase 2 — 인터랙션 부품 (핵심 재미) ✅ 완료
- [x] `widgets/magnetic.dart` — 자석 호버 래퍼 (Step 2.1 ✅)
- [x] `widgets/custom_cursor.dart` — 마우스 따라다니는 커서 + 트레일 (Step 2.2 ✅)
- [x] `widgets/reveal_on_scroll.dart` — 스크롤 진입 시 등장 애니메이션 (Step 2.3 ✅)
- [x] 작은 플레이그라운드로 3개 부품 각각 동작 확인 (BootScreen 스크롤 데모, Step 2.4 ✅)

### Phase 3 — 섹션 조립 (하나씩) ✅ 완료
- [x] Hero — 타이핑 애니메이션 (`whoami` → 이름/직함) (Step 3.1 ✅)
- [x] About — 자기소개 + 리빌 (Step 3.2 ✅)
- [x] Skills — 기술 배지 + 스크롤 리빌 (Step 3.3 ✅)
- [x] Projects — 호버 인터랙션 카드 + 자석 효과 (Step 3.4 ✅)
- [x] Contact — 자석 소셜 버튼 + url_launcher (Step 3.5 ✅)
- [x] 전체 스크롤 흐름 확인 (Hero→About→Skills→Projects→Contact)

### Phase 4 — 레이아웃 & 반응형 마감 ✅ 완료
- [x] 모바일 커서 끄기(터치 감지 PointerDeviceKind) + 텍스트 선택(SelectionArea + DefaultSelectionStyle)
- [x] 데스크탑/모바일 반응형 폭·레이아웃 (maxWidth 800 → 좁은 화면 자동 대응, 모바일 스샷 확인)
- [~] 상단 내비게이션 — 일단 생략 (필요시 나중에)
- [x] 전체 폴리시 확인 (모바일 확인 + 오타 수정)

### Phase 5 — GitHub Pages 배포 ✅ 완료
- [x] `flutter build web` (base href `/my-profile/`)
- [x] GitHub 저장소 + Actions 자동 배포 (`.github/workflows/deploy.yml`)
- [x] 실제 URL 접속 확인 → https://yj0.app/

---

## 📝 Profile Content (English — goes on the site)

- **Handle**: Youngjin Lee
- **Title**: Flutter App Developer · Security Enthusiast
- **Skills**: Dart, Flutter (mobile & web app development)
- **Certifications & Awards**:
  - Industrial Engineer Information Security (Korean national certification)
  - Silver Medal — National Skills Competition (Cyber Security)
- **Interests**: Building game hacks & reverse engineering (for fun)
- **Contact**: GitHub · LinkedIn · Email ✅
- **Projects**: Survev.io Game Hack · Tarot Reader · Car Control ✅
